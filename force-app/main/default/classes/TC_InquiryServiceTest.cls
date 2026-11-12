@IsTest
private class TC_InquiryServiceTest {

    @TestSetup
    static void setup() {
        Account owner = TC_TestDataFactory.account('Owner LLC', 'Owner/Landlord');
        TC_Property__c p = TC_TestDataFactory.property('Match Tower', owner.Id);
        TC_Listing__c l = TC_TestDataFactory.listing(p.Id, 'TC_Lease', 'Active');
        TC_TestDataFactory.availability(p.Id, null, l.Id);
    }

    static TC_Listing__c listing() { return [SELECT Id, TC_Property__c FROM TC_Listing__c LIMIT 1]; }

    static TC_Inquiry__c newInquiry() {
        return new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_First_Name__c = 'Dana', TC_Last_Name__c = 'Lopez', TC_Email__c = 'dana@example.com',
            TC_Company_Name__c = 'Lopez Analytics', TC_Property_Type__c = 'Office', TC_Size_Min__c = 2000, TC_Size_Max__c = 3000,
            TC_Max_Rate__c = 35, TC_Preferred_City__c = 'Dallas', TC_Source__c = 'Website');
    }

    @IsTest
    static void listingOnInquiryBecomesPrimaryProspectiveListing() {
        TC_Inquiry__c i = newInquiry();
        i.TC_Listing__c = listing().Id;
        insert i;
        TC_Prospective_Listing__c pl = [SELECT TC_Primary__c, TC_Listing__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :i.Id];
        System.assert(pl.TC_Primary__c);
        System.assertEquals(listing().TC_Property__c, [SELECT TC_Property__c FROM TC_Inquiry__c WHERE Id = :i.Id].TC_Property__c, 'Property defaults from listing');
        // A second primary unchecks the first
        TC_Property__c p2 = TC_TestDataFactory.property('Second Tower', null);
        TC_Listing__c l2 = TC_TestDataFactory.listing(p2.Id, 'TC_Lease', 'Active');
        insert new TC_Prospective_Listing__c(TC_Inquiry__c = i.Id, TC_Listing__c = l2.Id, TC_Primary__c = true, TC_Status__c = 'New');
        System.assertEquals(1, [SELECT COUNT() FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :i.Id AND TC_Primary__c = true]);
        System.assertEquals(l2.Id, [SELECT TC_Listing__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :i.Id AND TC_Primary__c = true].TC_Listing__c);
    }

    @IsTest
    static void convertCreatesAccountContactAndDeal() {
        TC_Inquiry__c i = newInquiry();
        i.TC_Listing__c = listing().Id;
        insert i;
        Test.startTest();
        TC_InquiryService.ConvertResult r = TC_InquiryService.convert(i.Id, null, true);
        Test.stopTest();
        System.assertEquals('Lopez Analytics', [SELECT Name FROM Account WHERE Id = :r.accountId].Name);
        System.assertEquals('dana@example.com', [SELECT Email FROM Contact WHERE Id = :r.contactId].Email);
        TC_Deal__c d = [SELECT RecordType.DeveloperName, TC_Client__c, TC_Listing__c, TC_Property__c, TC_Size__c, TC_Inquiry__c, TC_Tenant__c FROM TC_Deal__c WHERE Id = :r.dealId];
        System.assertEquals('TC_Tenant_Representation', d.RecordType.DeveloperName);
        System.assertEquals(listing().Id, d.TC_Listing__c, 'Primary prospective listing carried over');
        System.assertEquals(3000, d.TC_Size__c);
        System.assertEquals(r.accountId, d.TC_Tenant__c);
        TC_Inquiry__c si = [SELECT TC_Status__c, TC_Converted_Deal__c, TC_Contact__c FROM TC_Inquiry__c WHERE Id = :i.Id];
        System.assertEquals('Converted', si.TC_Status__c);
        System.assertEquals(r.dealId, si.TC_Converted_Deal__c);
        try {
            TC_InquiryService.convert(i.Id, null, true);
            System.assert(false, 'Second conversion must fail');
        } catch (TC_Exception e) {
            System.assert(e.getMessage().contains('already been converted'));
        }
    }

    @IsTest
    static void convertWarnsWhenListingIsOnAnotherOpenDeal() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact c = TC_TestDataFactory.contact(a.Id, 'Existing');
        TC_Deal__c other = TC_TestDataFactory.buildLeaseDeal(a.Id, listing().TC_Property__c);
        other.TC_Listing__c = listing().Id;
        insert other;
        TC_Inquiry__c i = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Sale', TC_Contact__c = c.Id, TC_Source__c = 'Phone', TC_Price_Max__c = 30000000);
        insert i;
        System.assertEquals(a.Id, [SELECT TC_Company__c FROM TC_Inquiry__c WHERE Id = :i.Id].TC_Company__c, 'Company defaults from contact');
        TC_InquiryService.ConvertResult r = TC_InquiryService.convert(i.Id, listing().Id, true);
        System.assertNotEquals(null, r.warning);
        System.assertEquals(c.Id, r.contactId, 'Existing contact reused');
        System.assertEquals('TC_Buyer_Representation', [SELECT RecordType.DeveloperName FROM TC_Deal__c WHERE Id = :r.dealId].RecordType.DeveloperName);
    }

    @IsTest
    static void findMatchesScoresAndSaves() {
        TC_Inquiry__c i = newInquiry();
        insert i;
        List<TC_InquiryService.Match> matches = TC_InquiryService.scoreMatches(i.Id, 5);
        System.assertEquals(1, matches.size());
        System.assertEquals(100, matches[0].score, 'Type, property type, size, rate and city all fit: ' + matches[0].reasons);
        System.assertEquals(1, TC_InquiryService.saveMatches(i.Id, matches));
        System.assertEquals(0, TC_InquiryService.saveMatches(i.Id, matches), 'No duplicates');
        System.assertEquals(100, [SELECT TC_Match_Score__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :i.Id].TC_Match_Score__c);
    }

    @IsTest
    static void inquiryValidation() {
        TC_Inquiry__c bad = newInquiry();
        bad.TC_Size_Max__c = 1000;
        System.assert(!Database.insert(bad, false).isSuccess(), 'Size max below min');
        TC_Inquiry__c dq = newInquiry();
        insert dq;
        dq.TC_Status__c = 'Disqualified';
        System.assert(!Database.update(dq, false).isSuccess(), 'Disqualify needs a reason');
        dq.TC_Disqualified_Reason__c = 'No Budget';
        update dq;
        TC_Inquiry__c anon = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_Source__c = 'Phone');
        System.assert(!Database.insert(anon, false).isSuccess(), 'Needs a last name or contact');
    }
}
