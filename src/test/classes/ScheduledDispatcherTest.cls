@isTest(IsParallel=false)
private class ScheduledDispatcherTest {

	@IsTest
    static void can_schedule_new_job() {
		DateTime fireTime = DateTime.Now().addSeconds(10);
		String nextFireCron = ScheduledDispatcher.createCronExpressionFromDateTime(fireTime);

		Test.startTest();
		ScheduledDispatcher.scheduleJob(SchedulableWrapperTest.TestSchedulable.class, null, nextFireCron);
		Test.stopTest();

		String jobName = SchedulableWrapperTest.TestSchedulable.class.getName();
		List<CronTrigger> jobs = [
			SELECT Id, CronJobDetail.Name, State, NextFireTime
			FROM CronTrigger
            WHERE CronJobDetail.Name LIKE '%TestSchedulable%'
		];

		system.assert(jobs.size() == 1);
		system.debug('Job State: ' + jobs[0].State);
		system.assert(jobs[0].State == 'WAITING');
	}
}