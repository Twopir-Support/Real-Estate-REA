/* Logic-less trigger: all behaviour lives in TC_RecordHandlers.TC_InquiryHandler and the TC services. */
trigger TC_InquiryTrigger on TC_Inquiry__c (before insert, before update, after insert, after update) {
    new TC_RecordHandlers.TC_InquiryHandler().run();
}
