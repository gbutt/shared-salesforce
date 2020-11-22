# Log Framework

The log framework consists of several classes that allow us to capture and record logs in Salesforce without having to turn on debug logs. The framework is used by creating a Logger class for each Apex class and calling the log methods (debug, info, warn and error) to write data to logs. Log entries are kept in an in-memory queue until they are flushed. The queue is specific per apex class, so flushing the queue will only write entries that were created by that specific logger. Once a log is flushed, the entries are written to a new record on the `Log__c` object. Logs are auto-flushed when they record a warn or error entry. When an error occurs, record it with `log.error(ex)`. This will cause the log data to flush, which will create a new record in the `Log__c` object.

## Usage

-   Create an instance of the logger using the below code at the top of your apex class:

```java
private static final Logger log = LoggerFactory.getInstance(MyApexClass.class);
```

-   Use `log.debug(msg)` to capture more verbose details such as the state of an object at a point in time.
-   Use `log.info(msg)` to log informational messages.
-   Use `log.warn(msg)` to log recoverable errors, misconfigurations, etc.
-   Use `log.error(ex)` to record unexpected errors that will cause execution of the current transaction to terminate.
-   Calling log.warn or log.error will cause the logs to get flushed.
-   Log entries can be manually flushed by calling `log.flush()`.
-   All log entries will also get recorded to the standard Debug Logs in Salesforce, so use `log.debug(msg)` in place of `System.debug(msg)`, and use `log.info(msg)` in place of `System.debug(LoggingLevel.INFO,msg)` etc.

_Example_:

```java
public class SomeTriggerHandler {
    private static final Logger log = LoggerFacotry.getInstance(SomeTriggerHandler.class);

    public SomeTriggerHandler(List<SObject> newRecords) {
        log.info('Total New Records: ' + newRecords.size());
        log.debug('New Records: ' + JSON.serialize(newRecords));
    }

    public void execute() {
        if (newRecords.size() == 0) {
            log.info('No records to process.');
            return;
        }
        try {
            doAllTheThings();
        } catch (Exception ex) {
            log.error(ex);
            throw ex;
        }
    }
}
```

-   In the example above, we create a new Logger called `log`. We record some messages at log levels INFO and DEBUG.
-   When an error occurs, we record it at log level ERROR. This also causes the logs to auto-flush, and create a `Log__c` record.
-   If no error occurs then the logs will not get flushed, and no `Log__c` record is created.
-   If the Log Threshold is set to INFO instead of DEBUG then no debug logs will get recorded, even when an error occurs.
-   If we wanted to always record a `Log__c` record even in cases where no error occurs, then we would need to add a call to `log.flush()` at the end of our code.

## Logger Configuration

Loggers are configured using a custom metadata type called `LoggerConfig__mdt`.
There is a `DEFAULT ` logger that is used for all classes by default.
You can override the default logger for a specific class by creating a `LoggerConfig__mdt` for that class.

-   **MasterLabel** - should match the exact name of the class you want to override (ie. MasterLabel = MyApexClass ).
-   **Logger_Class\_\_c** - should be the name of the class you want to use for your logger (ie. Logger_Class\_\_c = Loggers.AggregateEventLogger ).
-   **Log_Threshold\_\_c** - is the minimum log level needed to record log entries. For example if you set the Log_Threshold\_\_c to INFO then it will ignore all DEBUG log entries when recording your logs to the Log\_\_c record.
-   **Flush_Threshold\_\_c** - is the log level that triggers automatic flushing of logs. For example if you set the Flush_Threshold\_\_c to DEBUG then each call to debug, info, warn and error will immediately flush the logs and create a Log\_\_c record.

## Logger Types

There are several logger types that live under `Loggers.cls`. For the most part you should only use two: `Loggers.SystemLogger` and `Loggers.AggregateEventLogger`.

-   **SystemLogger** - This logger will only write to the Debug Log. It will not create any platform events or Log\_\_c records. It is 100% safe to use in all scenarios.
-   **ObjectLogger** - This logger will create a new Log\_\_c record for every log entry in the queue.
-   **EventLogger** - This logger will create a new LogEvent\_\_e platform event for every log entry in the queue.
-   **AggregateObjectLogger** - This logger will create a single Log\_\_c record for all log entries in the queue.
-   **AggregateEventLogger** - This logger will create a single LogEvent\_\_e platform event for all log entries in the queue.

The platform event `LogEvent__e` has a trigger handler that will record the event as a record in the `Log__c` object. There is one big advantage to using a platform event for log creation: When an unhandled exception occurs, platform events do not get rolled back. Let's say we are using the ObjectLogger in the below scenario:

```java
try {
    throwsAnUnexpectedError();
} catch (Exception ex) {
    log.error(ex);
    throw ex;
}
```

In this scenario, the `ObjectLogger` would create a new record in the `Log__c` object. However, since we rethrow the exception, that `Log__c` record will not get committed to Salesforce.
