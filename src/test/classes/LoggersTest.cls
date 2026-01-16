@IsTest(IsParallel =true)
public class LoggersTest {
    @IsTest
    static void LogItem_should_print_line() {
        Loggers.LogItem item = new Loggers.LogItem(LoggingLevel.DEBUG, 'Test Message', 'LoggersTest');
        String result = item.printLog();
        System.assert(result.endsWith(' - LoggersTest |DEBUG| Test Message'), result);
    }

    @IsTest
    static void LogItem_should_print_line_with_stacktrace() {
        // throw and catch a null pointer exception
        Exception caught;
        try {
            caught.getMessage();
        } catch (Exception ex) {
            caught = ex;
        }
        Loggers.LogItem item = new Loggers.LogItem(LoggingLevel.DEBUG, caught, 'LoggersTest');
        List<String> results = item.printLog().split('\n');
        System.assert(results[0].endsWith(' - LoggersTest |DEBUG| System.NullPointerException: Attempt to de-reference a null object'), results[0]);
        System.assert(results[1].startsWith('Cause: Class.LoggersTest.LogItem_should_print_line_with_stacktrace: line '), results[1]);
    }

    @IsTest
    static void LoggerBase_should_get_log_threshold() {
        TestLogger log = new TestLogger();
        System.assertEquals(LoggingLevel.DEBUG, log.getLogThreshold());
        log.setLogThreshold(LoggingLevel.INFO);
        System.assertEquals(LoggingLevel.INFO, log.getLogThreshold());
    }

    @IsTest
    static void LoggerBase_should_get_flush_threshold() {
        TestLogger log = new TestLogger();
        System.assertEquals(LoggingLevel.WARN, log.getFlushThreshold());
        log.setFlushThreshold(LoggingLevel.INFO);
        System.assertEquals(LoggingLevel.INFO, log.getFlushThreshold());
    }

    @IsTest
    static void LoggerBase_should_get_category() {
        TestLogger log = new TestLogger();
        System.assertEquals(null, log.getCategory());
        log.setCategory('Test');
        System.assertEquals('Test', log.getCategory());
    }

    @IsTest
    static void LoggerBase_should_log_debug() {
        TestLogger log = new TestLogger('Test');
        log.debug('Test Message');
        System.assertEquals(1, log.queue.size());
        Loggers.LogItem item = log.queue[0];
        System.assertEquals('Test', item.category);
        System.assertEquals(LoggingLevel.DEBUG, item.logLevel);
        System.assertEquals('Test Message', item.message);
    }

    @IsTest
    static void LoggerBase_should_not_log_debug_when_threshold_is_higher() {
        TestLogger log = new TestLogger('Test');
        log.setLogThreshold(LoggingLevel.INFO);
        log.debug('Test Message');
        System.assertEquals(0, log.queue.size());
    }

    @IsTest
    static void LoggerBase_should_flush_when_flush_threshold_is_reached() {
        TestLogger log = new TestLogger('Test');
        log.setFlushThreshold(LoggingLevel.INFO);
        log.debug('Test Message');
        System.assertEquals(1, log.queue.size());
        log.info('Test Message');
        System.assertEquals(0, log.queue.size());
        System.assertEquals(2, log.flushedItems.size());
    }

    @IsTest
    static void LoggerBase_should_not_flush_when_flush_threshold_is_none() {
        TestLogger log = new TestLogger('Test');
        log.setFlushThreshold(LoggingLevel.NONE);
        log.error('Test Message');
        System.assertEquals(1, log.queue.size());
        System.assertEquals(0, log.flushedItems.size());
    }

    @IsTest
    static void it_should_flush_if_threshold_param_is_met() {
        TestLogger log = new TestLogger('Test');
        log.setFlushThreshold(LoggingLevel.NONE);

        log.flushIf(LoggingLevel.ERROR);
        System.assertEquals(0, log.queue.size());
        System.assertEquals(0, log.flushedItems.size());

        log.debug('Test Message');
        System.assertEquals(1, log.queue.size());
        System.assertEquals(0, log.flushedItems.size());

        log.flushIf(LoggingLevel.INFO);
        System.assertEquals(1, log.queue.size());
        System.assertEquals(0, log.flushedItems.size());

        log.info('Test Message');
        System.assertEquals(2, log.queue.size());
        System.assertEquals(0, log.flushedItems.size());
        log.flushIf(LoggingLevel.INFO);
        System.assertEquals(0, log.queue.size());
        System.assertEquals(2, log.flushedItems.size());

        log.warn('Test Message');
        System.assertEquals(1, log.queue.size());
        System.assertEquals(2, log.flushedItems.size());
        log.flushIf(LoggingLevel.INFO);
        System.assertEquals(0, log.queue.size());
        System.assertEquals(3, log.flushedItems.size());
    }

    @IsTest
    static void AggregateLogger_should_combine_log_entries() {
        TestAggregateLogger log = new TestAggregateLogger('Test');
        log.info('Test Info');
        log.debug('Test Debug');
        System.assertEquals(2, log.queue.size());
        log.flush();
        System.assertEquals(0, log.queue.size());
        System.assertNotEquals(null, log.aggregateItem);
        System.assertEquals('Test', log.aggregateItem.category);
        System.assertEquals(LoggingLevel.INFO, log.aggregateItem.logLevel);
        List<String> messages = log.aggregateItem.message.split('\n');
        System.assertEquals(2, messages.size());
        System.assert(messages[0].endsWith(' - Test |INFO| Test Info'));
        System.assert(messages[1].endsWith(' - Test |DEBUG| Test Debug'));
    }

    @IsTest
    static void AggregateLogger_should_combine_single_log_entries() {
        TestAggregateLogger log = new TestAggregateLogger('Test');
        log.debug('Test Debug');
        System.assertEquals(1, log.queue.size());
        log.flush();
        System.assertEquals(0, log.queue.size());
        System.assertNotEquals(null, log.aggregateItem);
        System.assertEquals('Test', log.aggregateItem.category);
        System.assertEquals(LoggingLevel.DEBUG, log.aggregateItem.logLevel);
        List<String> messages = log.aggregateItem.message.split('\n');
        System.assertEquals(1, messages.size());
        System.assert(messages[0].endsWith(' - Test |DEBUG| Test Debug'));
    }

    @IsTest
    static void ObjectLogger_should_write_entries_to_log_object() {
        Loggers.ObjectLogger log = new Loggers.ObjectLogger();
        log.setCategory('Test');

        log.debug('Test Debug');
        log.info('Test Info');
        log.flush();

        List<Log__c> logEntries = [SELECT Category__c, Log_Level__c, Message__c, Log_Time__c, Log_User__c FROM Log__c ORDER BY Log_Time__c];
        System.assertEquals(2, logEntries.size());
        Log__c entry = logEntries[0];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('DEBUG', entry.Log_Level__c);
        System.assertEquals('Test Debug', entry.Message__c);
        System.assertEquals(UserInfo.getUserId(), entry.Log_User__c);

        entry = logEntries[1];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('INFO', entry.Log_Level__c);
        System.assertEquals('Test Info', entry.Message__c);
        System.assertEquals(UserInfo.getUserId(), entry.Log_User__c);
    }

    @IsTest
    static void AggregateObjectLogger_should_write_aggregate_entry_to_log_object() {
        Loggers.AggregateObjectLogger log = new Loggers.AggregateObjectLogger();
        log.setCategory('Test');

        log.debug('Test Debug');
        log.info('Test Info');
        log.flush();

        List<Log__c> logEntries = [SELECT Category__c, Log_Level__c, Message__c, Log_Time__c, Log_User__c FROM Log__c ORDER BY Log_Time__c];
        System.assertEquals(1, logEntries.size());
        Log__c entry = logEntries[0];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('INFO', entry.Log_Level__c);
        System.assertEquals(UserInfo.getUserId(), entry.Log_User__c);
        List<String> messages = entry.Message__c.split('\n');
        System.assert(messages[0].endsWith(' - Test |DEBUG| Test Debug'));
        System.assert(messages[1].endsWith(' - Test |INFO| Test Info'));
    }

    @IsTest
    static void EventLogger_should_write_entries_to_log_events() {
        Loggers.EventLogger log = new Loggers.EventLogger();
        log.setCategory('Test');

        log.debug('Test Debug');
        log.info('Test Info');
        log.flush();

        System.assertEquals(2, PventDispatcher.publishedEvents.size());
        LogEvent__e entry = (LogEvent__e)PventDispatcher.publishedEvents[0];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('DEBUG', entry.Log_Level__c);
        System.assertEquals('Test Debug', entry.Message__c);

        entry = (LogEvent__e)PventDispatcher.publishedEvents[1];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('INFO', entry.Log_Level__c);
        System.assertEquals('Test Info', entry.Message__c);
    }

    @IsTest
    static void AggregateEventLogger_should_write_aggregate_entry_to_log_event() {
        Loggers.AggregateEventLogger log = new Loggers.AggregateEventLogger();
        log.setCategory('Test');

        log.debug('Test Debug');
        log.info('Test Info');
        log.flush();

        System.assertEquals(1, PventDispatcher.publishedEvents.size());
        LogEvent__e entry = (LogEvent__e)PventDispatcher.publishedEvents[0];
        System.assertEquals('Test', entry.Category__c);
        System.assertEquals('INFO', entry.Log_Level__c);
        List<String> messages = entry.Message__c.split('\n');
        System.assert(messages[0].endsWith(' - Test |DEBUG| Test Debug'));
        System.assert(messages[1].endsWith(' - Test |INFO| Test Info'));
    }

    public class TestLogger extends Loggers.LoggerBase {
        public List<Loggers.LogItem> flushedItems {get; set;}
        public TestLogger() {
            super();
            flushedItems = new List<Loggers.LogItem> {};
        }
        public TestLogger(String category) {
            this();
            setCategory(category);
        }
        protected override void writeLogItems(List<LogItem> items) {
            flushedItems.addAll(items);
        }
    }

    public class TestAggregateLogger extends Loggers.AggregateLogger {
        public LogItem aggregateItem {get; set;}
        public TestAggregateLogger() {
            super();
        }
        public TestAggregateLogger(String category) {
            this();
            setCategory(category);
        }
        protected override void writeAggregateItem(LogItem aggregateItem) {
            this.aggregateItem = aggregateItem;
        }
    }

    public static List<Log__c> findErrorLogs() {
        return [SELECT Message__c FROM Log__c WHERE Log_Level__c = 'ERROR'];
    }

    public static void assertNoErrorLogs() {
        List<Log__c> errorLogs = findErrorLogs();
        System.assertEquals(0, errorLogs.size(), errorLogs);
    }
}