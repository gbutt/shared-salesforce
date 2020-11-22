@IsTest(IsParallel=true)
public class QueueableDispatcherTest {

	@IsTest
    static void it_should_schedule_chain() {
        // setup - mock the queueable executor
        QueueableTestHelper.setupTestExecutor();

        // given - a queueable and a chain
        QueueableChain chain = new TestQueueableChain();
        TestQueueable task = new TestQueueable();
        chain.enqueue(task);

        // when - we enqueue the chain
        QueueableDispatcher.enqueueChain(chain);

        // then - the chain is intercepted and stored in a list for inspection
        // basically every call that would call System.enqueueJob will instead be added the the enqueuedChains static property
        QueueableChain[] enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(1, enqueuedChains.size());
        System.assertEquals(chain, enqueuedChains[0]);
        System.assertEquals(task, enqueuedChains[0].queueableStack[0]);
    }

	@IsTest
	static void it_should_push_new_chain_onto_currently_executing_chain() {
        // setup - mock the queueable executor
        QueueableTestHelper.setupTestExecutor();

        // given - two chains
		QueueableChain chain1 = new TestQueueableChain();
		TestQueueable task1 = new TestQueueable();
        chain1.enqueue(task1);
		QueueableChain chain2 = new TestQueueableChain();
		TestQueueable task2 = new TestQueueable();
        chain2.enqueue(task2);

        // given - chain1 is the currently executing chain
        QueueableDispatcher.currentlyExecutingChain = chain1;

		// when - we enqueue chain 2
		QueueableDispatcher.enqueueChain(chain2);

		// then - chain2 is pushed onto chain1
		QueueableChain[] enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(0, enqueuedChains.size());
		System.assertEquals(task2, QueueableDispatcher.currentlyExecutingChain.queueableStack[0]);
		System.assertEquals(task1, QueueableDispatcher.currentlyExecutingChain.queueableStack[1]);
	}

	public class TestQueueableChain extends QueueableChain {}

    public class TestQueueable implements Queueable {
        public Boolean hasExecuted {get;set;}
        public Exception exceptionToThrow {get;set;}
        public SObject dmlToRollback {get;set;}
        public void execute(QueueableContext context) {
            hasExecuted = true;
            if (dmlToRollback != null) {
                insert dmlToRollback;
            }
            if (exceptionToThrow != null) {
                throw exceptionToThrow;
            }
        }
    }
}