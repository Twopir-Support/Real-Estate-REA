/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_ListingHandler and the TC services. */
trigger TC_ListingTrigger on TC_Listing__c (before insert, before update, after insert, after update, after delete) {
    new TC_RecordHandlers.TC_ListingHandler().run();
}
