@IsTest(IsParallel=true)
public class LoggerFactoryTest {

    @IsTest
    static void it_should_return_default_logger() {
        Logger log = LoggerFactory.getInstance('whatever');
        Logger newlog = LoggerFactory.getInstance('something');

        System.assertEquals('whatever', log.getCategory());
        System.assertEquals('something', newlog.getCategory());
    }

    @IsTest
    static void it_should_build_logger_from_config() {
        LoggerConfig__mdt config = new LoggerConfig__mdt(
            MasterLabel = 'LoggerFactoryTest'
            ,Log_Threshold__c = 'INFO'
            ,Flush_Threshold__c = 'WARN'
            ,Logger_Class__c = 'LoggerFactoryTest.TestLogger'
        );
        LoggerFactory.LoggerBlueprint blueprint = new LoggerFactory.LoggerBlueprint(config);

        // when
        Logger log = blueprint.createLogger();

        // then
        System.assert(log instanceof TestLogger);
        System.assertEquals(LoggingLevel.INFO, log.getLogThreshold());
    }

    @IsTest
    static void it_should_get_configured_logger() {
        LoggerConfig__mdt config = new LoggerConfig__mdt(
            MasterLabel = 'LoggerFactoryTest.TestInnerClass'
            ,Log_Threshold__c = 'INFO'
            ,Flush_Threshold__c = 'WARN'
            ,Logger_Class__c = 'LoggerFactoryTest.TestLogger'
        );

        // when
        // LoggerFactory.allowTestInstance = true;
        LoggerFactory.initializeLoggerBlueprints(new LoggerConfig__mdt[]{config});

        // then
        System.assert(LoggerFactory.loggerBlueprints.containsKey('DEFAULT'), LoggerFactory.loggerBlueprints.keyset());
        System.assert(LoggerFactory.loggerBlueprints.containsKey('LOGGERFACTORYTEST.TESTINNERCLASS'));

        // then - assert LoggerFactoryTest logger
        Logger log = LoggerFactory.getInstance(TestInnerClass.class.getName());
        System.assert(log instanceof TestLogger);
        System.assertEquals(LoggingLevel.INFO, log.getLogThreshold());
        System.assertEquals('LoggerFactoryTest.TestInnerClass', log.getCategory());

        // then - assert default logger
        log = LoggerFactory.getInstance('whatever');
        System.assert(log instanceof Loggers.SystemLogger);
        System.assertEquals(LoggingLevel.DEBUG, log.getLogThreshold());
        System.assertEquals('whatever', log.getCategory());
    }

    @IsTest
    static void it_should_fail_if_current_loggers_are_misconfigured() {
        LoggerConfig__mdt[] configs = [SELECT MasterLabel, Log_Threshold__c, Logger_Class__c, Flush_Threshold__c FROM LoggerConfig__mdt];

        for (LoggerConfig__mdt config : configs) {
            LoggerFactory.LoggerBlueprint blueprint = new LoggerFactory.LoggerBlueprint(config);
            Logger log = blueprint.createLogger();
        }

        // then - no exceptions thrown
    }

    public class TestInnerClass {

    }

    public class TestLogger extends Loggers.LoggerBase {
        public override void writeLogItems(LogItem[] items) {
            System.debug('Logs flushed');
        }
    }
}