/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_LeaseHandler and the TC services. */
trigger TC_LeaseTrigger on TC_Lease__c (before insert, before update, after insert, after update, after delete, after undelete) {
    new TC_RecordHandlers.TC_LeaseHandler().run();
}
