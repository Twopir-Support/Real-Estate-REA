/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_ProspectiveListingHandler and the TC services. */
trigger TC_ProspectiveListingTrigger on TC_Prospective_Listing__c (after insert, after update) {
    new TC_RecordHandlers.TC_ProspectiveListingHandler().run();
}
