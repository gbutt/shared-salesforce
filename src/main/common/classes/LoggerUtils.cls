public class LoggerUtils {
    public static String buildErrorString(Exception ex) {
        return 'Error : ' + ex + ' \nCause : ' + ex.getStackTraceString();
    }

    public static List<String> collectErrors(List<Database.SaveResult> results) {
        List<String> errors = new List<String> {};
        for (Database.SaveResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.SaveResult result) {
        List<Database.Error> errors = result.getErrors();
        return formatErrors(errors);
    }

    public static List<String> collectErrors(List<Database.UpsertResult> results) {
        List<String> errors = new List<String> {};
        for (Database.UpsertResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.UpsertResult result) {
        List<Database.Error> errors = result.getErrors();
        return formatErrors(errors);
    }

    public static List<String> collectErrors(List<Database.DeleteResult> results) {
        List<String> errors = new List<String> {};
        for (Database.DeleteResult result : results) {
            if (result.isSuccess() == false) {
                errors.add(formatErrors(result));
            }
        }
        return errors;
    }

    public static String formatErrors(Database.DeleteResult result) {
        List<Database.Error> errors = result.getErrors();
        return formatErrors(errors);
    }

    private static String formatErrors(List<Database.Error> errors) {
        List<String> errorMessages = new List<String> {};
        for (Database.Error error : errors) {
            List<String> fields = new List<String> {};
            if (error.getFields() != null) {
                fields = error.getFields();
            }
            errorMessages.add('Status Code: ' + error.getStatusCode() + '; Message: ' + error.getMessage() + '; Fields: [' + String.join(fields, ', ') + ']');
        }
        return String.join(errorMessages, '; ');
    }
}