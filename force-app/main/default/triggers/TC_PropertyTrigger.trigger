/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_PropertyHandler and the TC services. */
trigger TC_PropertyTrigger on TC_Property__c (before insert, before update, after insert, after update, after delete) {
    new TC_RecordHandlers.TC_PropertyHandler().run();
}
