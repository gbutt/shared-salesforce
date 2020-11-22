trigger Event_LogEventTrigger on LogEvent__e(after insert) {
    LogEventHandler.runHandler();
}