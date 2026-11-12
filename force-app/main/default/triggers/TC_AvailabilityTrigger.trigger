/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_AvailabilityHandler and the TC services. */
trigger TC_AvailabilityTrigger on TC_Availability__c (before insert, before update, after insert, after update, after delete, after undelete) {
    new TC_RecordHandlers.TC_AvailabilityHandler().run();
}
