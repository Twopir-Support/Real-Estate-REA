/** Tests for the configuration engines (naming, field mapping, settings) and smaller handlers. */
@IsTest
private class TC_PlatformServicesTest {

    @IsTest
    static void fieldMappingCoercesStaticValues() {
        System.assertEquals(true, TC_FieldMappingService.coerce('true', Schema.DisplayType.BOOLEAN));
        System.assertEquals(Date.newInstance(2026, 1, 2), TC_FieldMappingService.coerce('2026-01-02', Schema.DisplayType.DATE));
        System.assertEquals(12.5, TC_FieldMappingService.coerce('12.5', Schema.DisplayType.CURRENCY));
        System.assertEquals('NNN', TC_FieldMappingService.coerce('NNN', Schema.DisplayType.PICKLIST));
        System.assert(TC_FieldMappingService.groupApplies('DEAL_TO_LEASE', 'TC_Tenant_Representation'));
        System.assert(!TC_FieldMappingService.groupApplies('DEAL_TO_LEASE', 'TC_Consulting'));
        System.assert(TC_FieldMappingService.sourceFields('DEAL_TO_SALE').contains('TC_Sale_Price__c'));
        TC_Lease__c target = new TC_Lease__c(TC_Status__c = 'Pending');
        TC_FieldMappingService.apply('DEAL_TO_LEASE', new TC_Deal__c(TC_Size__c = 900), target, 'TC_Tenant_Representation', true);
        System.assertEquals('Pending', target.TC_Status__c, 'onlyBlankTargets keeps existing values');
        System.assertEquals(900, target.TC_Size__c);
    }

    @IsTest
    static void settingsAndStages() {
        System.assertEquals(50, TC_Settings.stageProbability('LOI'));
        System.assertEquals(null, TC_Settings.stageProbability('Nope'));
        List<String> stages = TC_Settings.orderedStages();
        System.assertEquals('Prospect', stages[0]);
        System.assertEquals('Executed', stages[stages.size() - 1]);
        System.assert(!TC_Settings.isActive('TC_VAL_Inside_Broker_100'), 'Off by default, as in AscendixRE');
        System.assert(TC_Settings.isActive('TC_AUTO_Record_Naming'));
        System.assert(!TC_Settings.isActive('Does_Not_Exist'));
        System.assertEquals(new Set<String>{ 'a', 'b' }, TC_Settings.splitList(' a, b ,'));
        System.assertNotEquals(null, TC_Settings.stackingPlan());
        System.assertNotEquals(null, TC_Settings.nameMapping('TC_Lease__c'));
        System.assertEquals(null, TC_Settings.recordTypeDevName(TC_Deal__c.SObjectType, null));
    }

    @IsTest
    static void namingDisabledLeavesNamesAlone() {
        TC_Settings.automationOverrides.put('TC_AUTO_Record_Naming', false);
        Account a = TC_TestDataFactory.account('Owner', 'Owner/Landlord');
        TC_Property__c p = TC_TestDataFactory.property('No Name Tower', a.Id);
        TC_Sale__c s = new TC_Sale__c(Name = 'Manual Name', TC_Property__c = p.Id, TC_Sale_Date__c = Date.today(), TC_Sale_Price__c = 1000000);
        insert s;
        System.assertEquals('Manual Name', [SELECT Name FROM TC_Sale__c WHERE Id = :s.Id].Name);
        TC_Settings.automationOverrides.remove('TC_AUTO_Record_Naming');
        TC_Sale__c auto = new TC_Sale__c(TC_Property__c = p.Id, TC_Sale_Date__c = Date.newInstance(2025, 5, 1), TC_Sale_Price__c = 1000000);
        insert auto;
        System.assert([SELECT Name FROM TC_Sale__c WHERE Id = :auto.Id].Name.startsWith('No Name Tower - Sale'));
    }

    @IsTest
    static void termSheetInheritsFromDealSource() {
        Account lender = TC_TestDataFactory.account('First Lender Bank', 'Lender');
        TC_Capital_Source__c cs = new TC_Capital_Source__c(Name = 'First Lender - Core', TC_Account__c = lender.Id, TC_Source_Type__c = 'Bank');
        insert cs;
        TC_Deal__c d = new TC_Deal__c(Name = 'Refi', RecordTypeId = TC_TestDataFactory.rt(TC_Deal__c.SObjectType, 'TC_Capital_Markets'), TC_Client__c = lender.Id, TC_Loan_Amount__c = 5000000, TC_Stage__c = 'Prospect');
        insert d;
        TC_Deal_Source__c src = new TC_Deal_Source__c(TC_Deal__c = d.Id, TC_Capital_Source__c = cs.Id);
        insert src;
        TC_Term_Sheet__c ts = new TC_Term_Sheet__c(Name = 'Quote 1', TC_Deal_Source__c = src.Id, TC_Interest_Rate__c = 6.25, TC_Loan_Amount__c = 5000000);
        insert ts;
        ts = [SELECT TC_Deal__c, TC_Capital_Source__c, TC_Lender_Name__c FROM TC_Term_Sheet__c WHERE Id = :ts.Id];
        System.assertEquals(d.Id, ts.TC_Deal__c);
        System.assertEquals(cs.Id, ts.TC_Capital_Source__c);
        System.assertEquals('First Lender - Core', ts.TC_Lender_Name__c);
    }

    @IsTest
    static void primaryProspectiveBuyerFillsDealBuyer() {
        Account seller = TC_TestDataFactory.account('Seller', 'Seller');
        Account buyer = TC_TestDataFactory.account('Buyer Fund', 'Buyer');
        Contact bc = TC_TestDataFactory.contact(buyer.Id, 'Buyer');
        TC_Property__c p = TC_TestDataFactory.property('Sale Tower', seller.Id);
        TC_Deal__c d = TC_TestDataFactory.buildSaleDeal(seller.Id, p.Id, 'TC_Seller_Representation');
        insert d;
        TC_Prospective_Buyer__c first = new TC_Prospective_Buyer__c(TC_Deal__c = d.Id, TC_Contact__c = bc.Id, TC_Account__c = buyer.Id, TC_Primary__c = true);
        insert first;
        TC_Deal__c saved = [SELECT TC_Buyer__c, TC_Buyer_Contact__c, TC_Client_Role__c FROM TC_Deal__c WHERE Id = :d.Id];
        System.assertEquals(buyer.Id, saved.TC_Buyer__c);
        System.assertEquals(bc.Id, saved.TC_Buyer_Contact__c);
        System.assertEquals('Seller', saved.TC_Client_Role__c);
        TC_Prospective_Buyer__c second = new TC_Prospective_Buyer__c(TC_Deal__c = d.Id, TC_Contact__c = bc.Id, TC_Primary__c = false);
        insert second;
        second.TC_Primary__c = true;
        update second;
        System.assertEquals(false, [SELECT TC_Primary__c FROM TC_Prospective_Buyer__c WHERE Id = :first.Id].TC_Primary__c, 'Only one primary buyer');
    }

    @IsTest
    static void handlerBypassAndHelpers() {
        TC_TriggerHandler.bypass('TC_SaleHandler');
        Account a = TC_TestDataFactory.account('Owner', 'Owner/Landlord');
        TC_Property__c p = TC_TestDataFactory.property('Bypass Tower', a.Id);
        TC_Sale__c s = new TC_Sale__c(Name = 'Kept', TC_Property__c = p.Id, TC_Sale_Date__c = Date.today(), TC_Sale_Price__c = 5);
        insert s;
        TC_TriggerHandler.clearBypass('TC_SaleHandler');
        System.assertEquals('Kept', [SELECT Name FROM TC_Sale__c WHERE Id = :s.Id].Name);
        System.assertEquals(0, TC_TriggerHandler.idsOf(null, 'Id').size());
        System.assertEquals('TC_SaleHandler', new TC_RecordHandlers.TC_SaleHandler().handlerName());
    }
}
