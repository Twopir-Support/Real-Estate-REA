/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_DealPeriodHandler and the TC services. */
trigger TC_DealPeriodTrigger on TC_Deal_Period__c (before insert, before update, after insert, after update, after delete) {
    new TC_RecordHandlers.TC_DealPeriodHandler().run();
}
