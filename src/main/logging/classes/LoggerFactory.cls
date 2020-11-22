public without sharing class LoggerFactory {
    @TestVisible
    private static Map<String, LoggerBlueprint> loggerBlueprints {get; set;}
    private static Map<String, LoggingLevel> logLevels {get; set;}
    private static final LoggerBlueprint DEFAULT_LOGGER_BLUEPRINT;
    private static final Logger log;

    static {
        log = new Loggers.SystemLogger();
        log.setCategory(LoggerFactory.class.getName());
        DEFAULT_LOGGER_BLUEPRINT = new LoggerBlueprint();
        logLevels = buildLogLevelsMap();
        LoggerConfig__mdt[] configs = [SELECT MasterLabel, Log_Threshold__c, Logger_Class__c, Flush_Threshold__c FROM LoggerConfig__mdt];
        initializeLoggerBlueprints(configs);
    }

    public static Logger getInstance(Type category) {
        return getInstance(category.getName());
    }

    public static Logger getInstance(String category) {
        LoggerBlueprint blueprint = getBlueprint(category);
        Logger log;
        try {
            log = blueprint.createLogger();
        } catch (Exception ex) {
            log.error(ex);
            // default to SystemLogger
            log = DEFAULT_LOGGER_BLUEPRINT.createLogger();
        }
        log.setCategory(category);
        return log;
    }

    // PRIVATE METHODS
    private static LoggerBlueprint getBlueprint(String category) {
        LoggerBlueprint blueprint = loggerBlueprints.get(category.toUpperCase());
        if (blueprint == null) {
            blueprint = loggerBlueprints.get('DEFAULT');
        }
        return blueprint;
    }

    private static void setBlueprint(String category, LoggerBlueprint blueprint) {
        loggerBlueprints.put(category.toUpperCase(), blueprint);
    }

    @TestVisible
    private static void initializeLoggerBlueprints(LoggerConfig__mdt[] configs) {
        loggerBlueprints = new Map<String, LoggerBlueprint> {
            'DEFAULT' => DEFAULT_LOGGER_BLUEPRINT
        };
        for (LoggerConfig__mdt config : configs) {
            try {
                LoggerBlueprint blueprint = new LoggerBlueprint(config);
                setBlueprint(config.MasterLabel, blueprint);
            } catch (Exception ex) {
                log.error(ex);
            }
        }
    }

    private static Map<String, LoggingLevel> buildLogLevelsMap() {
        Map<String, LoggingLevel> logLevelsMap = new Map<String, LoggingLevel>();
        for (LoggingLevel level : LoggingLevel.values()) {
            logLevelsMap.put(level.name().toUpperCase(), level);
        }
        return logLevelsMap;
    }

    public class LoggerBlueprint {
        public Type loggerType {get; set;}
        public LoggingLevel logThreshold {get; set;}
        public LoggingLevel flushThreshold {get; set;}

        public LoggerBlueprint() {
            this.loggerType = Loggers.SystemLogger.class;
            this.logThreshold = LoggingLevel.DEBUG;
            this.flushThreshold = LoggingLevel.WARN;
        }
        public LoggerBlueprint(LoggerConfig__mdt config) {
            this.loggerType = Type.forName(config.Logger_Class__c);
            if (config.Log_Threshold__c != null) {
                this.logThreshold = logLevels.get(config.Log_Threshold__c.toUpperCase());
            }
            if (config.Flush_Threshold__c != null) {
                this.flushThreshold = logLevels.get(config.Flush_Threshold__c.toUpperCase());
            }
        }

        public Logger createLogger() {
            Logger log = (Logger)loggerType.newInstance();
            log.setLogThreshold(logThreshold);
            log.setFlushThreshold(flushThreshold);
            return log;
        }
    }
}