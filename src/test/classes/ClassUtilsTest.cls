@IsTest(isParallel=true)
public class ClassUtilsTest {
	@IsTest
	static void it_should_get_class_name() {
        GeneralException ex = new GeneralException();
        System.assertEquals('GeneralException', ClassUtils.getName(ex));
	}
}