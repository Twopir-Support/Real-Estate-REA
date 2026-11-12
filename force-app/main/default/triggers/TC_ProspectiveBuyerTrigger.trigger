/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_ProspectiveBuyerHandler and the TC services. */
trigger TC_ProspectiveBuyerTrigger on TC_Prospective_Buyer__c (after insert, after update) {
    new TC_RecordHandlers.TC_ProspectiveBuyerHandler().run();
}
