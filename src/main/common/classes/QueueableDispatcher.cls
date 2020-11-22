/*


 */
public class QueueableDispatcher {
    // static properties
    @TestVisible
    private static QueueableExecutor executor {
        get {
            if (executor == null) {
                executor = new QueueableExecutor();
            }
            return executor;
        }
        set;
    }

    public static QueueableChain currentlyExecutingChain {get; set;}

    public static Boolean canEnqueue() {
        return Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();
    }

    public static void enqueueChain(QueueableChain taskChain) {
        executor.execute(taskChain);
    }

    public static void enqueueTask(Queueable task, Type chainType) {
        system.debug(LoggingLevel.INFO, 'enqueueing task for ' + chainType.getName());
        if (currentlyExecutingChain != null) {
            currentlyExecutingChain.enqueue(task);
        } else {
            QueueableChain chain = (QueueableChain)chainType.newInstance();
            chain.enqueue(task);
            enqueueChain(chain);
        }
    }

    public static void enqueueSchedulable(Queueable task, String jobName) {
        system.debug(LoggingLevel.INFO, 'scheduling task for ' + jobName);
        ScheduledDispatcher.scheduleJobImmediate(ScheduledHandler.class, new Map<String, Object> {'queueable' => task}, jobName);
    }

    public static void enqueueSchedulable(Queueable task, String jobName, DateTime scheduledTime) {
        system.debug(LoggingLevel.INFO, 'scheduling task for ' + jobName);
        String cronExpression = ScheduledDispatcher.createCronExpressionFromDateTime(scheduledTime);
        ScheduledDispatcher.scheduleJob(ScheduledHandler.class, new Map<String, Object> {'queueable' => task}, cronExpression, jobName);
    }

    public static void enqueueOrScheduleTask(Queueable task, Type chainType) {
        String jobName = chainType.getName().replaceAll('\\W', '');
        enqueueOrScheduleTask(task, chainType, jobName);
    }
    public static void enqueueOrScheduleTask(Queueable task, Type chainType, String jobName) {
        if (QueueableDispatcher.canEnqueue()) {
            try {
                QueueableDispatcher.enqueueTask(task, chainType);
            } catch (AsyncException aex) {
                QueueableDispatcher.enqueueSchedulable(task, jobName);
            }
        } else {
            QueueableDispatcher.enqueueSchedulable(task, jobName);
        }
    }

    public static void unsafeEnqueueChain(QueueableChain taskChain) {
        executor.addToApexJobQueue(taskChain);
    }

    // this class wraps system.enqueueJob to help with unit testing
    public virtual class QueueableExecutor {
        public void execute(QueueableChain taskChain) {
            if (currentlyExecutingChain == null) {
                addToApexJobQueue(taskChain);
            } else {
                currentlyExecutingChain.pushTasks(taskChain);
            }
        }

        public virtual void addToApexJobQueue(QueueableChain taskChain) {
            System.enqueueJob(taskChain);
        }
    }

    public class ScheduledHandler implements SchedulableWrapper.I {
        public Map<String, Object> state {get; set;}
        public void setState(Map<String, Object> state) {
            this.state = state;
        }
        public void execute(SchedulableContext sc) {
            ((Queueable)state.get('queueable')).execute(null);
        }
    }
}