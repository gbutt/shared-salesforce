/***
Adapted from the great Dan Appleman.
For more on this and many other great patterns - buy his book - http://advancedapex.com/
This class can be used to schedule any scheduled job without risk of locking the class.
DO NOT CHANGE THIS CLASS! It is locked by the scheduler. Instead make changes to ScheduledHelper or your own IScheduleDispatched class
To use:
	1) Create a new class to handle your job. This class should implement SchedulableWrapper.IScheduleDispatched
	2) Create a new instance of SchedulableWrapper with the type of your new class.
	3) Schedule the SchedulableWrapper instead of directly scheduling your new class.
	See ScheduledRenewalsHandler for a working example.
***/
global class SchedulableWrapper implements Schedulable {

    public interface I {
		void setState(Map<String, Object> state);
		void execute(SchedulableContext sc);
	}

	private Type targetType;
	private Map<String, Object> state;

	public SchedulableWrapper(Type targetType, Map<String, Object> state) {
		System.debug('Creating new dispatcher for class: ' + targetType.getName());
		this.targetType = targetType;
		this.state = state;
	}

	global void execute(SchedulableContext sc) {
		I instance = ((I)targetType.newInstance());
		instance.setState(state);
		instance.execute(sc);
	}
}