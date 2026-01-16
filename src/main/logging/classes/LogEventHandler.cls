public without sharing class LogEventHandler extends BaseProcessor {
    List<LogEvent__e> events {get; set;}

    public LogEventHandler(List<LogEvent__e> events) {
        this.events = events;
    }

    protected override void doExecute() {
        List<Log__c> entries = new List<Log__c> {};
        for (LogEvent__e event : events) {
            Log__c entry = new Log__c(
                Category__c = event.Category__c
                , Log_Level__c = event.Log_Level__c
                , Message__c = event.Message__c
                , Log_User__c = event.CreatedById
                , Log_Time__c = event.Log_Time__c
            );
            entries.add(entry);
        }
        List<Database.SaveResult> results = Database.insert(entries, false);
        for (Database.SaveResult result : results) {
            if (result.isSuccess() == false) {
                System.debug(LoggingLevel.ERROR, JSON.serialize(result));
            }
        }
    }

    public static void runHandler() {
        new LogEventHandler(Trigger.new).execute();
    }
}