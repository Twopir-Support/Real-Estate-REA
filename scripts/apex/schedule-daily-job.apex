// Schedules the TC nightly job (lease status sweep + contact follow-up sequences) at 02:00 daily.
// Safe to re-run: skips scheduling when the job already exists.
List<CronTrigger> existing = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'TC Daily Job'];
if (existing.isEmpty()) {
    System.schedule('TC Daily Job', '0 0 2 * * ?', new TC_DailyScheduler());
    System.debug('Scheduled TC Daily Job');
} else {
    System.debug('TC Daily Job already scheduled');
}
