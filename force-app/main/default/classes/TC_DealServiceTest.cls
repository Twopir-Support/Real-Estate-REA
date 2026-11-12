@IsTest
private class TC_DealServiceTest {

    @TestSetup
    static void setup() {
        Account owner = TC_TestDataFactory.account('Lone Star Holdings', 'Owner/Landlord');
        TC_TestDataFactory.account('Acme Tenant Co', 'Tenant');
        TC_TestDataFactory.property('Uptown Tower', owner.Id);
    }

    static Account tenant() { return [SELECT Id FROM Account WHERE Name = 'Acme Tenant Co']; }
    static TC_Property__c prop() { return [SELECT Id FROM TC_Property__c LIMIT 1]; }

    @IsTest
    static void newTenantRepDealGetsDefaultsAndClientFields() {
        Contact c = TC_TestDataFactory.contact(tenant().Id, 'Rivera');
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, prop().Id);
        d.TC_Client_Contact__c = c.Id;
        Test.startTest();
        insert d;
        Test.stopTest();
        d = [SELECT TC_Probability__c, TC_Lead_Broker__c, TC_Client_Role__c, TC_Client_Contact_Role__c, TC_Tenant__c, TC_Tenant_Contact__c,
                    TC_Gross_Deal_Value__c, TC_Gross_Fee_Amount__c FROM TC_Deal__c WHERE Id = :d.Id];
        System.assertEquals(10, d.TC_Probability__c, 'Prospect stage defaults to 10%');
        System.assertEquals(UserInfo.getUserId(), d.TC_Lead_Broker__c, 'Lead broker defaults to the owner');
        System.assertEquals('Tenant', d.TC_Client_Role__c);
        System.assertEquals('Tenant', d.TC_Client_Contact_Role__c);
        System.assertEquals(tenant().Id, d.TC_Tenant__c, 'Tenant copies from Client on tenant rep deals');
        System.assertEquals(c.Id, d.TC_Tenant_Contact__c);
        // 5,000 SF x $30 with 3% escalations over 5 years is roughly $796k
        System.assert(d.TC_Gross_Deal_Value__c > 790000 && d.TC_Gross_Deal_Value__c < 800000, 'Gross deal value: ' + d.TC_Gross_Deal_Value__c);
        System.assertEquals((d.TC_Gross_Deal_Value__c * 0.04).setScale(2), d.TC_Gross_Fee_Amount__c, 'Fee is 4% of deal value');
    }

    @IsTest
    static void stageChangeMovesProbabilityUnlessOverridden() {
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, prop().Id);
        insert d;
        d.TC_Stage__c = 'LOI';
        update d;
        System.assertEquals(50, [SELECT TC_Probability__c FROM TC_Deal__c WHERE Id = :d.Id].TC_Probability__c);
        d.TC_Stage__c = 'Negotiation';
        d.TC_Probability__c = 65;
        update d;
        System.assertEquals(65, [SELECT TC_Probability__c FROM TC_Deal__c WHERE Id = :d.Id].TC_Probability__c, 'Manual override wins');
    }

    @IsTest
    static void perSquareFootFeeMethod() {
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, prop().Id);
        d.TC_Gross_Fee_Method__c = 'By $ per SF';
        d.TC_Gross_Fee_Rate_per_UOM__c = 2.5;
        insert d;
        System.assertEquals(12500, [SELECT TC_Gross_Fee_Amount__c FROM TC_Deal__c WHERE Id = :d.Id].TC_Gross_Fee_Amount__c);
    }

    @IsTest
    static void perSquareFootFeeRejectedOnSaleDeal() {
        TC_Deal__c d = TC_TestDataFactory.buildSaleDeal(tenant().Id, prop().Id, 'TC_Seller_Representation');
        d.TC_Gross_Fee_Method__c = 'By $ per SF';
        d.TC_Gross_Fee_Rate_per_UOM__c = 1;
        Database.SaveResult sr = Database.insert(d, false);
        System.assert(!sr.isSuccess(), 'The $ per SF method is lease-only');
    }

    @IsTest
    static void lostDealRequiresReason() {
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, prop().Id);
        insert d;
        d.TC_Status__c = 'Lost';
        Database.SaveResult sr = Database.update(d, false);
        System.assert(!sr.isSuccess(), 'Lost reason is required');
        d.TC_Lost_Reason__c = 'Pricing';
        update d;
        TC_Deal__c saved = [SELECT TC_Probability__c, TC_Actual_Close_Date__c FROM TC_Deal__c WHERE Id = :d.Id];
        System.assertEquals(0, saved.TC_Probability__c);
        System.assertEquals(Date.today(), saved.TC_Actual_Close_Date__c);
    }

    @IsTest
    static void wonTenantRepDealCreatesLeaseWithRentTableAndClosesSpace() {
        TC_Property__c p = prop();
        TC_Unit__c unit = TC_TestDataFactory.units(p.Id, 1, 1)[0];
        TC_Availability__c space = TC_TestDataFactory.availability(p.Id, unit.Id, null);
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, p.Id);
        d.TC_Space__c = space.Id;
        insert d;
        TC_RentTableService.generateForDeals(new Set<Id>{ d.Id }, true);
        insert TC_TestDataFactory.buildCommission(d.Id, 'TC_Inside_Broker', 100);

        Test.startTest();
        d.TC_Status__c = 'Won';
        update d;
        Test.stopTest();

        List<TC_Lease__c> leases = [SELECT Id, Name, TC_Tenant__c, TC_Size__c, TC_Status__c, (SELECT Id FROM Lease_Periods__r) FROM TC_Lease__c WHERE TC_Deal__c = :d.Id];
        System.assertEquals(1, leases.size(), 'One lease created on close');
        System.assertEquals(tenant().Id, leases[0].TC_Tenant__c);
        System.assertEquals(5, leases[0].Lease_Periods__r.size(), 'Deal rent table copied to the lease');
        System.assert(leases[0].Name.contains('Uptown Tower'), 'Lease named from the name mapping: ' + leases[0].Name);
        System.assertEquals('Closed', [SELECT TC_Status__c FROM TC_Availability__c WHERE Id = :space.Id].TC_Status__c);
        TC_Deal__c saved = [SELECT TC_Stage__c, TC_Probability__c, TC_Actual_Value__c FROM TC_Deal__c WHERE Id = :d.Id];
        System.assertEquals('Executed', saved.TC_Stage__c);
        System.assertEquals(100, saved.TC_Probability__c);
        System.assertNotEquals(null, saved.TC_Actual_Value__c);
        System.assertEquals('Earned', [SELECT TC_Status__c FROM TC_Commission__c WHERE TC_Deal__c = :d.Id].TC_Status__c);
        // Closing again (e.g. re-open and win) must not duplicate the lease.
        d.TC_Status__c = 'Open';
        update d;
        d.TC_Status__c = 'Won';
        update d;
        System.assertEquals(1, [SELECT COUNT() FROM TC_Lease__c WHERE TC_Deal__c = :d.Id]);
    }

    @IsTest
    static void wonSellerRepDealCreatesSale() {
        TC_Deal__c d = TC_TestDataFactory.buildSaleDeal(tenant().Id, prop().Id, 'TC_Seller_Representation');
        insert d;
        d.TC_Status__c = 'Won';
        update d;
        TC_Sale__c s = [SELECT TC_Sale_Price__c, TC_Sale_Date__c, TC_Property__c FROM TC_Sale__c WHERE TC_Deal__c = :d.Id];
        System.assertEquals(20000000, s.TC_Sale_Price__c);
        System.assertEquals(Date.today(), s.TC_Sale_Date__c);
        System.assertEquals(600000, [SELECT TC_Gross_Fee_Amount__c FROM TC_Deal__c WHERE Id = :d.Id].TC_Gross_Fee_Amount__c, '3% of sale price');
    }

    @IsTest
    static void wonListingPursuitCreatesListingOfMappedType() {
        TC_Deal__c d = TC_TestDataFactory.buildSaleDeal(tenant().Id, prop().Id, 'TC_Listing_Pursuit');
        d.TC_Deal_Sub_Type__c = 'Sale Listing - Exclusive';
        insert d;
        d.TC_Status__c = 'Won';
        update d;
        TC_Listing__c l = [SELECT RecordType.DeveloperName, TC_Exclusive__c, TC_Owner_Landlord__c, TC_Status__c, TC_Market__c FROM TC_Listing__c WHERE TC_Deal__c = :d.Id];
        System.assertEquals('TC_Sale', l.RecordType.DeveloperName);
        System.assert(l.TC_Exclusive__c);
        System.assertEquals(tenant().Id, l.TC_Owner_Landlord__c, 'Client becomes the listing owner');
        System.assertEquals('Draft', l.TC_Status__c);
        System.assertEquals('Dallas-Fort Worth', l.TC_Market__c, 'Property fields prefill the listing');
        System.assertEquals('TC_Sale_or_Lease', TC_DealService.listingRecordType('Sale or Lease'));
        System.assertEquals('TC_Lease', TC_DealService.listingRecordType(null));
    }

    @IsTest
    static void insideBrokerHundredPercentRuleWhenEnabled() {
        TC_Settings.automationOverrides.put('TC_VAL_Inside_Broker_100', true);
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenant().Id, prop().Id);
        insert d;
        d.TC_Status__c = 'Won';
        Database.SaveResult noBroker = Database.update(d, false);
        System.assert(!noBroker.isSuccess(), 'Needs at least one inside broker');
        insert TC_TestDataFactory.buildCommission(d.Id, 'TC_Inside_Broker', 60);
        Database.SaveResult partial = Database.update(d, false);
        System.assert(!partial.isSuccess(), 'Inside broker splits must total 100%');
        System.assert(partial.getErrors()[0].getMessage().contains('60'), partial.getErrors()[0].getMessage());
    }

    @IsTest
    static void bulkInsertOf200Deals() {
        List<TC_Deal__c> deals = new List<TC_Deal__c>();
        Id tenantId = tenant().Id;
        Id propId = prop().Id;
        for (Integer i = 0; i < 200; i++) {
            TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(tenantId, propId);
            d.Name = 'Bulk ' + i;
            deals.add(d);
        }
        Test.startTest();
        insert deals;
        for (TC_Deal__c d : deals) {
            d.TC_Stage__c = 'Touring';
        }
        update deals;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM TC_Deal__c WHERE TC_Probability__c = 30]);
    }

    @IsTest
    static void financingDealValueIsLoanAmount() {
        TC_Deal__c d = new TC_Deal__c(Name = 'Refi', RecordTypeId = TC_TestDataFactory.rt(TC_Deal__c.SObjectType, 'TC_Financing'),
            TC_Client__c = tenant().Id, TC_Loan_Amount__c = 10000000, TC_Gross_Fee_Percent__c = 1, TC_Gross_Fee_Method__c = 'Percent', TC_Stage__c = 'Prospect');
        insert d;
        d = [SELECT TC_Gross_Deal_Value__c, TC_Gross_Fee_Amount__c, TC_Client_Role__c FROM TC_Deal__c WHERE Id = :d.Id];
        System.assertEquals(10000000, d.TC_Gross_Deal_Value__c);
        System.assertEquals(100000, d.TC_Gross_Fee_Amount__c);
        System.assertEquals('Borrower', d.TC_Client_Role__c);
    }

    @IsTest
    static void brokerCannotSeeHouseOrNetCommission() {
        User u = TC_TestDataFactory.brokerUser();
        System.runAs(u) {
            System.assert(Schema.sObjectType.TC_Deal__c.isCreateable(), 'Brokers create deals');
            System.assert(!Schema.sObjectType.TC_Commission__c.fields.TC_House__c.isAccessible(), 'House is hidden from brokers');
            System.assert(!Schema.sObjectType.TC_Commission__c.fields.TC_Net_Commission__c.isAccessible(), 'Net is hidden from brokers');
            System.assert(Schema.sObjectType.TC_Commission__c.fields.TC_Gross_Commission__c.isAccessible(), 'Gross is visible');
            System.assert(!Schema.sObjectType.TC_Commission__c.isDeletable(), 'Brokers cannot delete commissions');
        }
    }
}
