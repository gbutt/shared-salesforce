public class LoggerUtils {
    public static String buildErrorString(Exception ex) {
        return 'Error : ' + ex + ' \nCause : ' + ex.getStackTraceString();
    }

    public static String[] collectErrors(Database.SaveResult[] results) {
        String[] errors = new String[] {};
        for (Database.SaveResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.SaveResult result) {
        Database.Error[] errors = result.getErrors();
        return formatErrors(errors);
    }

    public static String[] collectErrors(Database.UpsertResult[] results) {
        String[] errors = new String[] {};
        for (Database.UpsertResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.UpsertResult result) {
        Database.Error[] errors = result.getErrors();
        return formatErrors(errors);
    }

    public static String[] collectErrors(Database.DeleteResult[] results) {
        String[] errors = new String[] {};
        for (Database.DeleteResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.DeleteResult result) {
        Database.Error[] errors = result.getErrors();
        return formatErrors(errors);
    }

    private static String formatErrors(Database.Error[] errors) {
        String[] errorMessages = new String[] {};
        for (Database.Error error : errors) {
            String[] fields = new String[] {};
            if (error.getFields() != null) {
                fields = error.getFields();
            }
            errorMessages.add('Status Code: ' + error.getStatusCode() + '; Message: ' + error.getMessage() + '; Fields: [' + String.join(fields, ', ') + ']');
        }
        return String.join(errorMessages, '; ');
    }
}