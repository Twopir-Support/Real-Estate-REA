@IsTest
private class TC_UIControllerTest {

    @TestSetup
    static void setup() {
        Account owner = TC_TestDataFactory.account('Owner LLC', 'Owner/Landlord');
        Account tenant = TC_TestDataFactory.account('Tenant Inc', 'Tenant');
        TC_Property__c p = TC_TestDataFactory.property('UI Tower', owner.Id);
        List<TC_Unit__c> units = TC_TestDataFactory.units(p.Id, 3, 2);
        insert TC_TestDataFactory.buildLease(p.Id, units[0].Id, tenant.Id, Date.today().addMonths(-12), 48);
        TC_Listing__c l = TC_TestDataFactory.listing(p.Id, 'TC_Lease', 'Active');
        TC_TestDataFactory.availability(p.Id, units[1].Id, l.Id);
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant.Id, p.Id);
        insert d;
        insert TC_TestDataFactory.buildCommission(d.Id, 'TC_Inside_Broker', 100);
    }

    static TC_Property__c prop() { return [SELECT Id FROM TC_Property__c LIMIT 1]; }
    static TC_Deal__c deal() { return [SELECT Id FROM TC_Deal__c LIMIT 1]; }

    @IsTest
    static void propertySummaryAndScorecards() {
        Map<String, Object> s = TC_PropertyUIController.getPropertySummary(prop().Id);
        System.assertEquals(6, s.get('unitCount'));
        System.assertEquals(1, s.get('activeLeases'));
        System.assertEquals(5, TC_DealUIController.getScorecard(prop().Id).size());
        System.assertEquals(5, TC_DealUIController.getScorecard(deal().Id).size());
        System.assertEquals(5, TC_DealUIController.getScorecard([SELECT Id FROM TC_Lease__c LIMIT 1].Id).size());
        System.assertEquals(5, TC_DealUIController.getScorecard([SELECT Id FROM TC_Listing__c LIMIT 1].Id).size());
        System.assertEquals(3, TC_DealUIController.getScorecard([SELECT Id FROM Account LIMIT 1].Id).size());
    }

    @IsTest
    static void stackingPlanBuildsFloorsTopDown() {
        Map<String, Object> plan = TC_PropertyUIController.getStackingPlan(prop().Id);
        List<TC_PropertyUIController.Floor> floors = (List<TC_PropertyUIController.Floor>) plan.get('floors');
        System.assertEquals(10, floors.size(), 'Number of Floors drives the skeleton');
        System.assertEquals(10, floors[0].floor, 'Top floor first');
        TC_PropertyUIController.Floor first = floors[floors.size() - 1];
        Set<String> kinds = new Set<String>();
        for (TC_PropertyUIController.Block b : first.blocks) { kinds.add(b.kind); }
        System.assert(kinds.contains('lease'), String.valueOf(kinds));
        System.assert(kinds.contains('available'), String.valueOf(kinds));
        System.assert(kinds.contains('unknown'), 'Floor filled up to average floor size');
        System.assertEquals(true, plan.get('enabled'));
    }

    @IsTest
    static void searchByFiltersAndRadius() {
        TC_PropertyUIController.SearchCriteria c = new TC_PropertyUIController.SearchCriteria();
        c.propertyType = 'Office';
        c.city = 'Dall';
        c.hasAvailability = true;
        c.latitude = 32.78;
        c.longitude = -96.80;
        c.radiusMiles = 5;
        c.minSize = 1000;
        c.maxSize = 500000;
        System.assertEquals(1, TC_PropertyUIController.searchProperties(c).size());
        c.radiusMiles = null;
        c.latitude = null;
        c.buildingClass = 'C';
        System.assertEquals(0, TC_PropertyUIController.searchProperties(c).size());
        System.assertEquals(1, TC_PropertyUIController.searchProperties(null).size());
    }

    @IsTest
    static void dashboards() {
        Map<String, Object> d = TC_PropertyUIController.getDashboard(null, null);
        System.assertEquals(1, d.get('properties'));
        System.assertEquals(1, d.get('openDeals'));
        System.assert(((List<Object>) d.get('pipelineByStage')).size() > 0);
        Map<String, Object> filtered = TC_PropertyUIController.getDashboard('Dallas-Fort Worth', 'Office');
        System.assertEquals(1, filtered.get('properties'));
        System.assertNotEquals(null, TC_DealUIController.getCommissionDashboard(null).get('year'));
        Map<String, Object> cd = TC_DealUIController.getCommissionDashboard(Date.today().addDays(60).year());
        System.assertEquals(true, cd.get('canSeeHouse'));
        System.assertEquals(1, ((List<Object>) cd.get('byBroker')).size());
    }

    @IsTest
    static void pipelineStageAndClose() {
        Map<String, Object> p = TC_DealUIController.getPipeline('TC_Tenant_Representation', true);
        System.assertEquals(1, ((List<TC_Deal__c>) p.get('deals')).size());
        System.assert(!((List<String>) p.get('stages')).contains('Executed'));
        TC_DealUIController.updateStage(deal().Id, 'Touring');
        System.assertEquals('Touring', [SELECT TC_Stage__c FROM TC_Deal__c].TC_Stage__c);
        Map<String, Object> info = TC_DealUIController.getCloseInfo(deal().Id);
        System.assert(((List<String>) info.get('willCreate')).size() > 0);
        TC_Deal__c d = [SELECT Id FROM TC_Deal__c LIMIT 1];
        update new TC_Deal__c(Id = d.Id, TC_Tenant__c = [SELECT Id FROM Account WHERE Name = 'Tenant Inc'].Id);
        Map<String, Object> res = TC_DealUIController.closeDeal(d.Id, 'Won', Date.today(), null, null);
        System.assertEquals(1, ((List<Object>) res.get('created')).size(), 'Lease created on close');
        try {
            TC_DealUIController.closeDeal(d.Id, 'Maybe', null, null, null);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @IsTest
    static void rentTableAndCommissions() {
        Id dealId = deal().Id;
        System.assertEquals(5, TC_DealUIController.generateRentTable(dealId, true));
        Map<String, Object> rt = TC_DealUIController.getRentTable(dealId);
        System.assertEquals(5, ((List<SObject>) rt.get('rows')).size());
        System.assertEquals(true, rt.get('isDeal'));
        Map<String, Object> leaseRt = TC_DealUIController.getRentTable([SELECT Id FROM TC_Lease__c LIMIT 1].Id);
        System.assertEquals(4, ((List<SObject>) leaseRt.get('rows')).size());
        Map<String, Object> com = TC_DealUIController.getCommissions(dealId);
        System.assertEquals(1, ((List<TC_Commission__c>) com.get('rows')).size());
        List<TC_Commission__c> rows = TC_DealUIController.newCommissionRows(dealId, 'TC_Co_Broker', 1);
        rows[0].TC_Fee_Percent__c = 25;
        rows[0].TC_Account__c = [SELECT Id FROM Account LIMIT 1].Id;
        TC_DealUIController.saveCommissions(rows);
        System.assertEquals(2, [SELECT COUNT() FROM TC_Commission__c]);
        TC_Commission__c bad = TC_DealUIController.newCommissionRows(dealId, 'TC_Co_Broker', 1)[0];
        bad.TC_Fee_Percent__c = 90;
        bad.TC_Account__c = rows[0].TC_Account__c;
        try {
            TC_DealUIController.saveCommissions(new List<TC_Commission__c>{ bad });
            System.assert(false, 'Over 100% must fail');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @IsTest
    static void termSheetsInquiryAndRecordHelpers() {
        System.assertEquals(0, TC_DealUIController.getTermSheets(deal().Id).size());
        TC_Inquiry__c i = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_Last_Name__c = 'Kim', TC_Company_Name__c = 'Kim Co', TC_Property_Type__c = 'Office',
            TC_Size_Min__c = 2000, TC_Size_Max__c = 3000, TC_Max_Rate__c = 40, TC_Preferred_City__c = 'Dallas', TC_Source__c = 'Website');
        insert i;
        List<TC_InquiryService.Match> m = TC_RecordUIController.findMatches(i.Id);
        System.assertEquals(1, m.size());
        System.assertEquals(1, TC_RecordUIController.saveMatches(i.Id, new List<Id>{ m[0].listingId }));
        Map<String, Object> info = TC_RecordUIController.getConvertInfo(i.Id);
        System.assertEquals(2, ((List<Object>) info.get('listings')).size());
        TC_InquiryService.ConvertResult r = TC_RecordUIController.convertInquiry(i.Id, m[0].listingId, true);
        System.assertNotEquals(null, r.dealId);
        try {
            TC_RecordUIController.convertInquiry(i.Id, null, true);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        Id propId = prop().Id;
        update new TC_Property__c(Id = propId, TC_Primary_Image_URL__c = 'https://example.com/a.jpg');
        System.assertEquals(1, TC_RecordUIController.getImages(propId).size());
        insert new TC_Relationship__c(TC_User__c = UserInfo.getUserId(), TC_Relationship_Type__c = 'Analyst', TC_Property__c = propId);
        System.assertEquals('TC_Property__c', TC_RecordUIController.relationshipField(propId));
        System.assertEquals(1, TC_RecordUIController.getRelationships(propId).size());
        System.assertEquals(0, TC_RecordUIController.getRelationships(UserInfo.getUserId()).size());
    }

    @IsTest
    static void documents() {
        Id propId = prop().Id;
        System.assertEquals(2, TC_RecordUIController.getDocumentOptions(propId).size());
        System.assertEquals(1, TC_RecordUIController.getDocumentOptions([SELECT Id FROM TC_Listing__c LIMIT 1].Id).size());
        Id docId = TC_RecordUIController.generateDocument(propId, 'TC_Property_Flyer', 'Flyer');
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :propId AND ContentDocumentId = :docId]);
        try {
            TC_RecordUIController.generateDocument(propId, 'Evil_Page', null);
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
        PageReference pr = Page.TC_Property_Flyer;
        pr.getParameters().put('id', propId);
        Test.setCurrentPage(pr);
        TC_DocumentController c = new TC_DocumentController();
        System.assertEquals(1, c.spaces.size());
        System.assertEquals(1, c.leases.size());
        pr.getParameters().put('id', [SELECT Id FROM TC_Listing__c LIMIT 1].Id);
        System.assertNotEquals(null, new TC_DocumentController().listing);
        TC_Inquiry__c i = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_Last_Name__c = 'Tour', TC_Listing__c = [SELECT Id FROM TC_Listing__c LIMIT 1].Id, TC_Source__c = 'Phone');
        insert i;
        pr.getParameters().put('id', i.Id);
        System.assertEquals(1, new TC_DocumentController().stops.size());
    }
}
