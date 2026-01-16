public class PventDispatcher {

    @TestVisible
    private static List<SObject> publishedEvents = new List<SObject>();

    public static void publishEvent(SObject event) {
        publishEvents(new List<SObject> {event});
    }

    public static void publishEvents(List<SObject> events) {
        if (Test.isRunningTest()) {
            publishedEvents.addAll(events);
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(events);
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(LoggingLevel.ERROR, 'Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
    }
}
