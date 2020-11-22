public without sharing class ScheduledDispatcher {

    // cron expression that fires the first day of every month at midnight
    public static final String CRON_MIDNIGHT_FIRST_OF_THE_MONTH = '0 0 0 1 * ?';

    // creates cron expression for a fire-once job that will execute at the specified datetime
	public static String createCronExpressionFromDateTime(DateTime fireTime) {
		List<String> timeParts = new List<String>();
		timeParts.add(String.valueof(fireTime.second()));
		timeParts.add(String.valueof(fireTime.minute()));
		timeParts.add(String.valueof(fireTime.hour()));
		timeParts.add(String.valueof(fireTime.day()));
		timeParts.add(String.valueof(fireTime.month()));
		timeParts.add('?');
		timeParts.add(String.valueof(fireTime.year()));

		return String.join(timeParts, ' ');
	}

    // schedules a job to execute once in the next couple seconds
	public static void scheduleJobImmediate(Type targetType, Map<String, Object> state) {
        String jobName = targetType.getName().replaceAll('\\W', '');
		scheduleJobImmediate(targetType, state, jobName);
	}
	public static void scheduleJobImmediate(Type targetType, Map<String, Object> state, String jobName) {
		Datetime soon = Datetime.now().addSeconds(2);
		String cronExpression = createCronExpressionFromDateTime(soon);
		scheduleJob(targetType, state, cronExpression, jobName);
	}

    // schedules a new job with the type, state and name at the specified cronExpression.
    // optionally aborts existing jobs with the same jobName.
    public static void scheduleJob(Type targetType, Map<String, Object> state, String cronExpression) {
        String jobName = targetType.getName().replaceAll('\\W', '');
        scheduleJob(targetType, state, cronExpression, jobName);
    }
	public static void scheduleJob(Type targetType, Map<String, Object> state, String cronExpression, String jobName) {
        jobName += '-' + IdUtils.uuid();
		SchedulableWrapper scheduledWrapper = new SchedulableWrapper(targetType, state);
        system.debug('scheduling ' + jobName + ' at ' + cronExpression);
		System.schedule(jobName, cronExpression, scheduledWrapper);
	}
}