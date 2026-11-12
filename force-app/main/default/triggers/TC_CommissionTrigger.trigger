/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_CommissionHandler and the TC services. */
trigger TC_CommissionTrigger on TC_Commission__c (before insert, before update, after insert, after update, after delete) {
    new TC_RecordHandlers.TC_CommissionHandler().run();
}
