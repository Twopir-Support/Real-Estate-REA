/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_LeasePeriodHandler and the TC services. */
trigger TC_LeasePeriodTrigger on TC_Lease_Period__c (before insert, before update) {
    new TC_RecordHandlers.TC_LeasePeriodHandler().run();
}
