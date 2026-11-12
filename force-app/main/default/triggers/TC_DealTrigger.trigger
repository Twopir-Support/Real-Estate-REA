/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_DealHandler and the TC services. */
trigger TC_DealTrigger on TC_Deal__c (before insert, before update, after insert, after update) {
    new TC_RecordHandlers.TC_DealHandler().run();
}
