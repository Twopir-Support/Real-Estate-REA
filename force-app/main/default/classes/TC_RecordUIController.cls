/**
 * LWC controller for record-level helpers: inquiry conversion and matching, image gallery,
 * relationship grid and PDF document generation.
 */
public with sharing class TC_RecordUIController {

    // ---------------------------------------------------------------- inquiry
    @AuraEnabled
    public static Map<String, Object> getConvertInfo(Id inquiryId) {
        TC_Inquiry__c i = [SELECT Id, Name, TC_Status__c, TC_Inquiry_Type__c, TC_First_Name__c, TC_Last_Name__c, TC_Company_Name__c, TC_Contact__r.Name, TC_Company__r.Name,
                                  (SELECT TC_Listing__c, TC_Listing__r.Name, TC_Primary__c FROM Prospective_Listings__r ORDER BY TC_Primary__c DESC, CreatedDate)
                           FROM TC_Inquiry__c WHERE Id = :inquiryId WITH USER_MODE];
        List<Map<String, String>> listings = new List<Map<String, String>>{ new Map<String, String>{ 'label' => '--None--', 'value' => '' } };
        String primary = '';
        for (TC_Prospective_Listing__c pl : i.Prospective_Listings__r) {
            listings.add(new Map<String, String>{ 'label' => pl.TC_Listing__r.Name + (pl.TC_Primary__c ? ' (Primary)' : ''), 'value' => pl.TC_Listing__c });
            if (pl.TC_Primary__c) { primary = pl.TC_Listing__c; }
        }
        return new Map<String, Object>{ 'inquiry' => i, 'listings' => listings, 'primaryListing' => primary };
    }

    @AuraEnabled
    public static TC_InquiryService.ConvertResult convertInquiry(Id inquiryId, Id listingId, Boolean createDeal) {
        if (!Schema.sObjectType.Account.isCreateable() || !Schema.sObjectType.Contact.isCreateable() || (createDeal != false && !Schema.sObjectType.TC_Deal__c.isCreateable())) {
            throw new AuraHandledException('You do not have permission to convert inquiries.');
        }
        try {
            return TC_InquiryService.convert(inquiryId, listingId, createDeal);
        } catch (TC_Exception e) {
            throw new AuraHandledException(e.getMessage());
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static List<TC_InquiryService.Match> findMatches(Id inquiryId) {
        return TC_InquiryService.scoreMatches(inquiryId, 10);
    }

    @AuraEnabled
    public static Integer saveMatches(Id inquiryId, List<Id> listingIds) {
        if (!Schema.sObjectType.TC_Prospective_Listing__c.isCreateable()) {
            throw new AuraHandledException('You do not have permission to add prospective listings.');
        }
        Set<Id> wanted = new Set<Id>(listingIds);
        List<TC_InquiryService.Match> keep = new List<TC_InquiryService.Match>();
        for (TC_InquiryService.Match m : TC_InquiryService.scoreMatches(inquiryId, 50)) {
            if (wanted.contains(m.listingId)) { keep.add(m); }
        }
        return TC_InquiryService.saveMatches(inquiryId, keep);
    }

    // ---------------------------------------------------------------- images
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getImages(Id recordId) {
        List<Map<String, String>> images = new List<Map<String, String>>();
        SObjectType t = recordId.getSObjectType();
        if (t.getDescribe().fields.getMap().containsKey('tc_primary_image_url__c')) {
            SObject rec = Database.query('SELECT TC_Primary_Image_URL__c FROM ' + t.getDescribe().getName() + ' WHERE Id = :recordId WITH USER_MODE');
            String url = (String) rec.get('TC_Primary_Image_URL__c');
            if (String.isNotBlank(url)) {
                images.add(new Map<String, String>{ 'url' => url, 'title' => 'Primary image', 'primary' => 'true' });
            }
        }
        for (ContentDocumentLink l : [SELECT ContentDocument.Title, ContentDocument.LatestPublishedVersionId, ContentDocument.FileExtension
                                      FROM ContentDocumentLink WHERE LinkedEntityId = :recordId
                                      AND ContentDocument.FileExtension IN ('png', 'jpg', 'jpeg', 'gif', 'webp') WITH USER_MODE LIMIT 50]) {
            images.add(new Map<String, String>{
                'url' => '/sfc/servlet.shepherd/version/download/' + l.ContentDocument.LatestPublishedVersionId,
                'title' => l.ContentDocument.Title, 'primary' => 'false'
            });
        }
        return images;
    }

    // ---------------------------------------------------------------- relationships
    @AuraEnabled(cacheable=true)
    public static List<TC_Relationship__c> getRelationships(Id recordId) {
        String field = relationshipField(recordId);
        if (field == null) {
            return new List<TC_Relationship__c>();
        }
        return Database.query('SELECT Id, Name, TC_User__c, TC_User__r.Name, TC_Relationship_Type__c, TC_Start_Date__c FROM TC_Relationship__c WHERE ' + field + ' = :recordId WITH USER_MODE ORDER BY TC_Relationship_Type__c LIMIT 100');
    }

    /** Lookup field on TC_Relationship__c that points to this record's object, or null. */
    @AuraEnabled(cacheable=true)
    public static String relationshipField(Id recordId) {
        String objName = recordId.getSObjectType().getDescribe().getName();
        for (Schema.SObjectField f : TC_Relationship__c.SObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult d = f.getDescribe();
            if (d.getType() == Schema.DisplayType.REFERENCE && d.isCustom() && d.getName() != 'TC_User__c'
                    && d.getReferenceTo().size() == 1 && d.getReferenceTo()[0].getDescribe().getName() == objName) {
                return d.getName();
            }
        }
        return null;
    }

    // ---------------------------------------------------------------- documents
    public class DocOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String page;
        public DocOption(String label, String value, String page) { this.label = label; this.value = value; this.page = page; }
    }

    @AuraEnabled(cacheable=true)
    public static List<DocOption> getDocumentOptions(Id recordId) {
        SObjectType t = recordId.getSObjectType();
        List<DocOption> opts = new List<DocOption>();
        if (t == TC_Property__c.SObjectType) {
            opts.add(new DocOption('Property Flyer', 'flyer', 'TC_Property_Flyer'));
            opts.add(new DocOption('Lease Comp Report', 'leasecomp', 'TC_Lease_Comp_Report'));
        } else if (t == TC_Listing__c.SObjectType) {
            opts.add(new DocOption('Listing Flyer', 'flyer', 'TC_Property_Flyer'));
        } else if (t == TC_Inquiry__c.SObjectType) {
            opts.add(new DocOption('Tour Book', 'tourbook', 'TC_Tour_Book'));
        }
        return opts;
    }

    @AuraEnabled
    public static Id generateDocument(Id recordId, String pageName, String title) {
        Set<String> allowed = new Set<String>{ 'TC_Property_Flyer', 'TC_Lease_Comp_Report', 'TC_Tour_Book' };
        if (!allowed.contains(pageName)) {
            throw new AuraHandledException('Unknown document type.');
        }
        if (!Schema.sObjectType.ContentVersion.isCreateable()) {
            throw new AuraHandledException('You do not have permission to save files.');
        }
        PageReference pr = new PageReference('/apex/' + pageName);
        pr.getParameters().put('id', recordId);
        Blob pdf = Test.isRunningTest() ? Blob.valueOf('PDF') : pr.getContentAsPDF();
        String safeTitle = String.isBlank(title) ? pageName.replace('TC_', '').replace('_', ' ') : title;
        ContentVersion cv = new ContentVersion(Title = safeTitle + ' ' + Date.today().format(), PathOnClient = safeTitle.replaceAll('[^A-Za-z0-9]+', '_') + '.pdf',
            VersionData = pdf, FirstPublishLocationId = recordId);
        Database.insert(cv, AccessLevel.USER_MODE);
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
    }
}
