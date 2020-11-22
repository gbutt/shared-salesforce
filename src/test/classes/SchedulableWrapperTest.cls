@IsTest
public class SchedulableWrapperTest {

    @IsTest
    static void it_should_create_new_instance_of_scheduled_wrappper() {
		Map<String,Object> testState = new Map<String,Object>{
			'executed' => false
		};
		SchedulableWrapper dispatcher = new SchedulableWrapper(TestSchedulable.class, testState);
		system.assert(dispatcher != null);

		dispatcher.execute(null);
		System.assertEquals(true, (Boolean)testState.get('executed'));
	}

    public class TestSchedulable implements SchedulableWrapper.I {
		public Map<String, Object> state {get;set;}
		public void setState(Map<String, Object> state) {
			this.state = state;
		}
		public void execute(SchedulableContext sc) {
			if (state != null) {
				state.put('executed', true);
			}
		}
	}
}