@IsTest(IsParallel=true)
public class QueueableChainTest {

    @IsTest
	static void it_should_execute_single_queueable() {
		// given - a chain with a single queueable
        QueueableTestHelper.setupTestExecutor();
		TestQueueable task = new TestQueueable();
		QueueableChain chain = new QueueableTestHelper.TestQueueableChain();
        chain.enqueue(task);

		// when - the chain executes
        chain.execute(null);

		// then - the queueable is executed
        System.assertEquals(chain, QueueableDispatcher.currentlyExecutingChain);
		System.assertEquals(true, task.hasExecuted);
        // then - the chain is depleted
        List<QueueableChain> enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(0, enqueuedChains.size());
	}

    @IsTest
	static void it_should_enqueue_remaining_queueable_chain() {
		// given - a chain with two queueables
        QueueableTestHelper.setupTestExecutor();
		TestQueueable task1 = new TestQueueable();
        TestQueueable task2 = new TestQueueable();
		QueueableChain chain = new QueueableTestHelper.TestQueueableChain();
        chain.enqueue(task1);
        chain.enqueue(task2);

		// when - the chain is executed
        chain.execute(null);

		// then - the second queueable is registered in the remaining chain
		List<QueueableChain> enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(1, enqueuedChains.size());
        System.assertEquals(1, enqueuedChains[0].queueableStack.size());
        System.assertEquals(task2, enqueuedChains[0].queueableStack[0]);
	}

    @IsTest
    static void it_should_push_new_queueables() {
        // given - two chains with one queueable in each
        TestQueueable task1 = new TestQueueable();
        QueueableChain chain1 = new QueueableTestHelper.TestQueueableChain();
        chain1.enqueue(task1);
        TestQueueable task2 = new TestQueueable();
        QueueableChain chain2 = new QueueableTestHelper.TestQueueableChain();
        chain2.enqueue(task2);

		// when - we push the second chain onto the first
        chain1.pushTasks(chain2);

        // then - the chains are joined
        System.assertEquals(2, chain1.queueableStack.size());
        // then - the second chain takes priority over the first
        System.assertEquals(task2, chain1.queueableStack[0]);
        System.assertEquals(task1, chain1.queueableStack[1]);
    }

    @IsTest
    static void it_should_stop_on_error() {
        QueueableTestHelper.setupTestExecutor();
        // given - a queueable that throws an exception
        TestQueueable task1 = new TestQueueable();
        task1.exceptionToThrow = new TestException('test');
        task1.dmlToRollback = new Account(Name = 'test');
        TestQueueable task2 = new TestQueueable();
		QueueableChain chain1 = new QueueableTestHelper.TestQueueableChain();
        chain1.enqueue(task1);
        chain1.enqueue(task2);

		// when - the chain is configured to stop on error
        chain1.stopOnError = true;
        Exception caught;
        try {
            chain1.execute(null);
        } catch (Exception ex) {
            caught = ex;
        }

        // then - the exception is not handled
        System.assertNotEquals(null, caught);
        // then - the transaction is rolled back
        System.assertEquals(0, [SELECT Id FROM Account WHERE ID = :task1.dmlToRollback.Id].size());
        // then - the remaining chain is not enqueued
        List<QueueableChain> enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(0, enqueuedChains.size());
    }

    @IsTest
    static void it_should_not_rollback_on_error() {
        QueueableTestHelper.setupTestExecutor();
        // given - a queueable that throws an error
        TestQueueable task1 = new TestQueueable();
        task1.exceptionToThrow = new TestException('test');
        task1.dmlToRollback = new Account(Name = 'test');
		TestQueueable task2 = new TestQueueable();
		QueueableChain chain1 = new QueueableTestHelper.TestQueueableChain();
        chain1.enqueue(task1);
        chain1.enqueue(task2);

		// when - rollback on error is disabled
        chain1.rollbackOnError = false;
        chain1.execute(null);

        // then - no exception is thrown, and the dml is not rolled back
        System.assertEquals(1, [SELECT Id FROM Account WHERE ID = :task1.dmlToRollback.Id].size());
        // then - the remaining chain is enqueued
        List<QueueableChain> enqueuedChains = QueueableTestHelper.executor.enqueuedChains;
        System.assertEquals(1, enqueuedChains.size());
    }

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

    public class TestException extends Exception {}
}