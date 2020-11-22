public interface Logger {
    LoggingLevel getLogThreshold();
    void setLogThreshold(LoggingLevel logThreshold);

    LoggingLevel getFlushThreshold();
    void setFlushThreshold(LoggingLevel flushThreshold);

    String getCategory();
    void setCategory(String category);

    Boolean isDebugEnabled();

    void debug(Object obj);
    void info(Object obj);
    void warn(Object obj);
    void error(Object obj);
    void flush();
    void flushIf(LoggingLevel threshold);
}