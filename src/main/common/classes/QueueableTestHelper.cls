@IsTest(IsParallel =true)
public class QueueableTestHelper {
    public static TestQueueableExecutor executor {get; set;}

    public static void setupTestExecutor() {
        executor = new TestQueueableExecutor();
        QueueableDispatcher.executor = executor;
    }

    public static List<QueueableChain> getEnqueuedChains() {
        return executor.enqueuedChains;
    }

    public static List<Queueable> getEnqueuedTasks() {
        List<Queueable> tasks = new List<Queueable>();
        for (QueueableChain chain : getEnqueuedChains()) {
            for (Queueable task : chain.queueableStack) {
                tasks.add(task);
            }
        }
        return tasks;
    }

    public static List<String> getEnqueuedTaskNames() {
        List<String> taskNames = new List<String>();
        for (Queueable task : getEnqueuedTasks()) {
            taskNames.add(ClassUtils.getName(task));
        }
        return taskNames;
    }

    public static void executeTasks() {
        for (Queueable task : getEnqueuedTasks()) {
            task.execute(null);
        }
        setupTestExecutor();
    }

    public class TestQueueableExecutor extends QueueableDispatcher.QueueableExecutor {
        public List<QueueableChain> enqueuedChains {get; set;}

        public TestQueueableExecutor() {
            enqueuedChains = new List<TestQueueableChain> {};
        }

        public override void addToApexJobQueue(QueueableChain taskChain) {
            enqueuedChains.add(taskChain);
        }
    }

    public class TestQueueableChain extends QueueableChain {}
}