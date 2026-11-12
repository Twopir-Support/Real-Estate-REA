/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_SaleHandler and the TC services. */
trigger TC_SaleTrigger on TC_Sale__c (before insert, before update) {
    new TC_RecordHandlers.TC_SaleHandler().run();
}
