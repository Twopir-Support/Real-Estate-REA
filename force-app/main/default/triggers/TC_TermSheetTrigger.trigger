/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_TermSheetHandler and the TC services. */
trigger TC_TermSheetTrigger on TC_Term_Sheet__c (before insert, before update) {
    new TC_RecordHandlers.TC_TermSheetHandler().run();
}
