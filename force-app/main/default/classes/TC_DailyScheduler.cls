/**
 * Nightly job: lease status sweep (Pending -> Active, Active -> Expired) and contact follow-up
 * sequences (AscendixRE "Automated Follow-up Tasks"). Schedule with:
 *   System.schedule('TC Daily', '0 0 2 * * ?', new TC_DailyScheduler());
 */
public with sharing class TC_DailyScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        run();
    }

    public static void run() {
        TC_LeaseService.sweepStatuses();
        createFollowUps();
    }

    /** Creates the next follow-up Task for contacts enrolled in a sequence whose date has arrived. */
    public static Integer createFollowUps() {
        Date today = Date.today();
        List<Contact> due = [
            SELECT Id, OwnerId, Name, AccountId, TC_Follow_up_Sequence__c, TC_Follow_up_Step__c, TC_Next_Follow_up_Date__c
            FROM Contact
            WHERE TC_Automated_Follow_up_Tasks__c = true AND TC_Follow_up_Sequence__c != null
              AND (TC_Next_Follow_up_Date__c = null OR TC_Next_Follow_up_Date__c <= :today)
            LIMIT 2000
        ];
        List<Task> tasks = new List<Task>();
        for (Contact c : due) {
            Integer step = c.TC_Follow_up_Step__c == null ? 1 : c.TC_Follow_up_Step__c.intValue() + 1;
            tasks.add(new Task(OwnerId = c.OwnerId, WhoId = c.Id, Subject = 'Follow-up #' + step + ' with ' + c.Name,
                ActivityDate = today, Status = 'Not Started', Priority = 'Normal', Type = 'Call'));
            c.TC_Follow_up_Step__c = step;
            c.TC_Next_Follow_up_Date__c = nextDate(c.TC_Follow_up_Sequence__c, step, today);
            if (c.TC_Next_Follow_up_Date__c == null) {
                c.TC_Automated_Follow_up_Tasks__c = false;
            }
        }
        if (!tasks.isEmpty()) {
            insert tasks;
            update due;
        }
        return tasks.size();
    }

    @TestVisible
    private static Date nextDate(String sequence, Integer stepJustDone, Date today) {
        if (sequence == '30-60-90 Days') {
            return stepJustDone >= 3 ? null : today.addDays(30);
        }
        if (sequence == 'Monthly') {
            return today.addMonths(1);
        }
        if (sequence == 'Quarterly') {
            return today.addMonths(3);
        }
        return null;
    }
}
