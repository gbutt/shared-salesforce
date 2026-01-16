public class Loggers {
    public static Boolean forceFlushAsync;

    public class SystemLogger extends LoggerBase {
        protected override void writeLogItems(List<LogItem> items) {
            System.debug('Logs flushed');
        }
    }

    public without sharing class ObjectLogger extends LoggerBase {
        protected override void writeLogItems(List<LogItem> items) {
            List<Log__c> entries = new List<Log__c> {};
            for (LogItem item : items) {
                Log__c entry = new Log__c(
                    Category__c = item.category
                    , Log_Level__c = item.logLevel.name()
                    , Message__c = item.message.left(131072)
                    , Log_Time__c = item.logTime
                    , Log_User__c = UserInfo.getUserId()
                );
                entries.add(entry);
            }
            Database.insert(entries, false);
        }
    }

    public class EventLogger extends LoggerBase {
        protected override void writeLogItems(List<LogItem> items) {
            List<LogEvent__e> events = new List<LogEvent__e> {};
            for (LogItem item : items) {
                LogEvent__e event = new LogEvent__e(
                    Category__c = item.category
                    , Log_Level__c = item.logLevel.name()
                    , Message__c = item.message.left(131072)
                    , Log_Time__c = item.logTime
                );
                events.add(event);
            }
            PventDispatcher.publishEvents(events);
        }
    }

    public without sharing class AggregateObjectLogger extends AggregateLogger {
        protected override void writeAggregateItem(LogItem aggregateItem) {
            Log__c entry = new Log__c(
                Category__c = aggregateItem.category
                , Log_Level__c = aggregateItem.logLevel.name()
                , Message__c = aggregateItem.message.left(131072)
                , Log_Time__c = aggregateItem.logTime
                , Log_User__c = UserInfo.getUserId()
            );
            Database.insert(entry, false);
        }
    }

    public class AggregateEventLogger extends AggregateLogger {
        protected override void writeAggregateItem(LogItem aggregateItem) {
            LogEvent__e event = new LogEvent__e(
                Category__c = aggregateItem.category
                , Log_Level__c = aggregateItem.logLevel.name()
                , Message__c = aggregateItem.message.left(131072)
                , Log_Time__c = aggregateItem.logTime
            );
            PventDispatcher.publishEvent(event);
        }
    }

    public abstract class AggregateLogger extends LoggerBase {
        protected abstract void writeAggregateItem(LogItem aggregateItem);
        protected override void writeLogItems(List<LogItem> items) {
            LogItem aggregateItem;
            if (items.size() == 1) {
                aggregateItem = items[0];
                aggregateItem.message = aggregateItem.printLog();
            } else {
                LogItem lastLogEntry = items[items.size() - 1];
                LoggingLevel maxLogLevel = lastLogEntry.logLevel;
                List<String> messages = new List<String> {};
                for (LogItem item : items) {
                    messages.add(item.printLog());
                    if (item.logLevel.ordinal() > maxLogLevel.ordinal()) {
                        maxLogLevel = item.logLevel;
                    }
                }
                aggregateItem = new LogItem(
                    maxLogLevel
                    , String.join(messages, '\n')
                    , lastLogEntry.category
                );
            }
            writeAggregateItem(aggregateItem);
        }
    }

    public abstract class LoggerBase implements Logger {
        @TestVisible
        private List<LogItem> queue {get; set;}
        private LoggingLevel logThreshold {get; set;}
        private LoggingLevel flushThreshold {get; set;}
        private String category {get; set;}

        public LoggerBase() {
            queue = new List<LogItem> {};
        }

        protected abstract void writeLogItems(List<LogItem> items);

        public virtual LoggingLevel getLogThreshold() {
            return logThreshold != null ? logThreshold : LoggingLevel.DEBUG;
        }

        public void setLogThreshold(LoggingLevel logThreshold) {
            this.logThreshold = logThreshold;
        }

        public virtual LoggingLevel getFlushThreshold() {
            return flushThreshold != null ? flushThreshold : LoggingLevel.WARN;
        }

        public void setFlushThreshold(LoggingLevel flushThreshold) {
            this.flushThreshold = flushThreshold;
        }

        public virtual String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public Boolean isDebugEnabled() {
            return LoggingLevel.DEBUG.ordinal() >= this.logThreshold.ordinal();
        }

        public void flush() {
            if (shouldFlushAsync()) {
                flushAsync();
            } else {
                flushImmediately();
            }
        }

        public void flushIf(LoggingLevel threshold) {
            for (LogItem item : this.queue) {
                if (item.logLevel.ordinal() >= threshold.ordinal()) {
                    flush();
                    return;
                }
            }
        }

        protected void flushAsync() {
            if (queue.size() == 0) {
                return;
            }

            // flush logs in a queueable/schedulable
            AsyncLogFlushQueueable myQueueable = new AsyncLogFlushQueueable(this);
            QueueableDispatcher.enqueueOrScheduleTask(myQueueable, AsyncLogFlushQueueableChain.class);
        }

        protected void flushImmediately() {
            if (queue.size() == 0) {
                return;
            }

            List<LogItem> items = queue;
            queue = new List<LogItem> {};
            writeLogItems(items);
        }

        public void debug(Object obj) {
            doLog(LoggingLevel.DEBUG, obj);
        }

        public void info(Object obj) {
            doLog(LoggingLevel.INFO, obj);
        }

        public void warn(Object obj) {
            obj = checkException(obj);
            doLog(LoggingLevel.WARN, obj);
        }

        public void error(Object obj) {
            obj = checkException(obj);
            doLog(LoggingLevel.ERROR, obj);
        }

        private void doLog(LoggingLevel logLevel, Object message) {
            LogItem item = new LogItem(logLevel, message, getCategory());
            if (item.logLevel.ordinal() >= getLogThreshold().ordinal()) {
                queue.add(item);
            }
            if (getFlushThreshold() != LoggingLevel.NONE && item.logLevel.ordinal() >= getFlushThreshold().ordinal()) {
                flush();
            }
        }

        private Object checkException(Object obj) {
            if (obj instanceof Exception) {
                Exception ex = (Exception)obj;
                String errorMessage = LoggerUtils.buildErrorString(ex);
                return errorMessage;
            }
            return obj;
        }

        private Boolean shouldFlushAsync() {
            // if (Test.isRunningTest() == false && Limits.getDmlStatements() == Limits.getLimitDmlStatements()) {
            //     return true;
            // }
            return Loggers.forceFlushAsync == true;
        }
    }

    public class LogItem {
        public LoggingLevel logLevel {get; set;}
        public String message {get; set;}
        public String category {get; set;}
        public Datetime logTime {get; set;}
        public String logLineTemplate {get; set;}

        private LogItem() {
            this.logLineTemplate = '{0} - {1} |{2}| {3}';
            this.logTime = Datetime.now();
        }
        public LogItem(LoggingLevel logLevel, Object message, String category) {
            this();
            this.logLevel = logLevel;
            this.message = getMessageString(message);
            this.category = category;
            System.debug(logLevel, logTime.formatGmt('HH:mm:ss.SSS') + ' - ' + message);
        }

        public String getMessageString(Object message) {
            String logMessage;
            if (message instanceof String) {
                logMessage = (String)message;
            } else if (message instanceof Exception) {
                Exception ex = (Exception)message;
                logMessage = String.valueOf(message);
                logMessage += '\nCause: ' + ex.getStackTraceString();
            } else {
                logMessage = JSON.serialize(message);
            }
            return logMessage;
        }

        public String printLog() {
            return String.format(logLineTemplate, new List<String> {
                logTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
                category,
                logLevel.name(),
                message
            });
        }
    }

    public class AsyncLogFlushQueueableChain extends QueueableChain {}
    public class AsyncLogFlushQueueable implements Queueable {
        LoggerBase logger;
        public AsyncLogFlushQueueable(LoggerBase logger) {
            this.logger = logger;
        }

        public void execute(QueueableContext context) {
            this.logger.flushImmediately();
        }
    }
}