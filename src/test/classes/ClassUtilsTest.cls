@IsTest(isParallel=true)
public class ClassUtilsTest {
	@IsTest
	static void it_should_get_class_name() {
        GeneralException ex = new GeneralException();
        Assert.areEqual('GeneralException', ClassUtils.getName(ex));
	}
}