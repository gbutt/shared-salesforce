public class ClassUtils {

    public static String getName(Object instance) {
        return String.valueOf(instance).split(':')[0];
    }

}