/*
    An abstract class that chains queueables so they execute one at a time.
    You need to extend this class for one very important reason:
    if you do not extend it then all of your queueables will be registered as type = QueueableChain
    and that will make debugging your flex queue more difficult.


    Usage:

    // concrete class
    public class MyQueueableChain extends QueueableChain {}

    // schedule a single queueable
    MyQueueableChain chain = new MyQueueableChain(myQueueable);
    QueueableDispatcher.schedule(chain);

    // schedule multiple queueables in a chain
    MyQueueableChain chain = new MyQueueableChain(new List<Queueable>{ queueable1, queueable2, ... });
    QueueableDispatcher.schedule(chain);


    Benefits:
    1. Queueable chains do not block your flex queue with a swarm of pending queueables.
    2. You can schedule several new queueables from within a queueable context. They just get added to the chain.
    3. While testing, you can inspect the queueables that were scheduled for execution.
    4. Provides a single way to schedule all of your queueables.
    5. New queueables actually take priority over existing queueables in the chain.
    6. You can override the onError method for custom error handling


    Testing:

    You can inspect the queueableStack property to see what queueables have been scheduled.
    This allows you to assert the queueables were scheduled without having to execute them with a call to Test.stopTest

    A big problem with testing queueables is that you cannot execute more than one queueable within a test.
    To compensate for this we have a TestQueueableExecutor that will loop and execute every queueable in the chain.
    But really it is better to not execute the queueables at all. Your tests will be faster and safer.

    QueueableChain.executor = new TestQueueableExecutor();
*/
public abstract class QueueableChain implements Queueable, Database.AllowsCallouts {

    // instance properties

    public List<Queueable> queueableStack {get;set;}
    public Boolean stopOnError {get;set;}
    public Boolean rollbackOnError {get;set;}

    // constructors
    public QueueableChain() {
        this.stopOnError = false;
        this.rollbackOnError = true;
        this.queueableStack = new List<Queueable>{};
    }

    public QueueableChain(Queueable task) {
        this();
        this.queueableStack = new List<Queueable>{task};
    }

    public QueueableChain(List<Queueable> tasks) {
        this();
        this.queueableStack = tasks;
    }

    public void enqueue(Queueable task) {
        this.queueableStack.add(task);
    }

    // note - new tasks are prioritized first!
    public void pushTasks(QueueableChain newChain) {
        List<Queueable> tempStack = newChain.queueableStack.clone();
        tempStack.addAll(this.queueableStack);
        this.queueableStack = tempStack;
    }

    public void execute(QueueableContext context) {
        QueueableDispatcher.currentlyExecutingChain = this;
        try {
            executeNextQueueable(context);
        } catch (Exception ex) {
            if (stopOnError) {
                throw ex;
            }
        }
        scheduleRemainingTasks();
    }

    protected virtual void onError(Exception ex, String jobName) {
        // you will probably want to capture this error in a persitent manner, such as writing it to an object
        // log.error(ex);
        system.debug(ex);
    }

    private void executeNextQueueable(QueueableContext context) {
        Queueable nextQueueable = queueableStack.remove(0);
        Exception caught = null;
        Savepoint sp = null;
        if (rollbackOnError) {
            sp = Database.setSavepoint();
        }
        try {
            nextQueueable.execute(context);
        } catch (Exception ex) {
            if (sp != null) {
                Database.rollback(sp);
            }
            String jobName = String.valueOf(nextQueueable).split(':')[0];
            onError(ex, jobName);
            throw ex;
        }
    }

    private void scheduleRemainingTasks() {
        if (queueableStack.size() > 0) {
            QueueableDispatcher.unsafeEnqueueChain(this);
        }
    }
}