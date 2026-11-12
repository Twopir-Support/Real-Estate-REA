@IsTest
private class TC_CommissionServiceTest {

    @TestSetup
    static void setup() {
        Account client = TC_TestDataFactory.account('Client Co', 'Seller');
        TC_TestDataFactory.account('Outside Brokerage', 'Brokerage Firm');
        TC_Property__c p = TC_TestDataFactory.property('Plaza One', client.Id);
        TC_Deal__c d = TC_TestDataFactory.buildSaleDeal(client.Id, p.Id, 'TC_Seller_Representation');
        insert d; // gross fee = 3% x 20,000,000 = 600,000
    }

    static TC_Deal__c deal() { return [SELECT Id, TC_Gross_Fee_Amount__c FROM TC_Deal__c LIMIT 1]; }

    @IsTest
    static void coBrokerComesOffTheTopThenInsideBrokersSplitTheNet() {
        Id dealId = deal().Id;
        TC_Commission__c co = TC_TestDataFactory.buildCommission(dealId, 'TC_Co_Broker', 50);
        TC_Commission__c expense = TC_TestDataFactory.buildCommission(dealId, 'TC_Expense', null);
        expense.TC_Fee_Method__c = 'Amount';
        expense.TC_Fee_Amount__c = 10000;
        TC_Commission__c ib1 = TC_TestDataFactory.buildCommission(dealId, 'TC_Inside_Broker', 70);
        TC_Commission__c ib2 = TC_TestDataFactory.buildCommission(dealId, 'TC_Inside_Broker', 30);
        Test.startTest();
        insert new List<TC_Commission__c>{ co, expense, ib1, ib2 };
        Test.stopTest();

        Map<Id, TC_Commission__c> saved = new Map<Id, TC_Commission__c>([SELECT Id, TC_Gross_Commission__c, TC_House__c, TC_Net_Commission__c, TC_Commission_Type__c FROM TC_Commission__c]);
        System.assertEquals(300000, saved.get(co.Id).TC_Gross_Commission__c, 'Co-broker: 50% of 600,000');
        System.assertEquals(10000, saved.get(expense.Id).TC_Gross_Commission__c, 'Expense: fixed amount');
        // Net deal fee = 600,000 - 300,000 - 10,000 = 290,000
        System.assertEquals(203000, saved.get(ib1.Id).TC_Gross_Commission__c, 'Inside broker 1: 70% of net');
        System.assertEquals(60900, saved.get(ib1.Id).TC_House__c, 'House: 30% of gross');
        System.assertEquals(142100, saved.get(ib1.Id).TC_Net_Commission__c);
        System.assertEquals(87000, saved.get(ib2.Id).TC_Gross_Commission__c);
        TC_Deal__c d = [SELECT TC_Net_Deal_Fee__c, TC_Total_Commission_Split__c FROM TC_Deal__c WHERE Id = :dealId];
        System.assertEquals(290000, d.TC_Net_Deal_Fee__c);
        System.assertEquals(100, d.TC_Total_Commission_Split__c);
    }

    @IsTest
    static void commissionsFollowFeeChanges() {
        TC_Deal__c d = deal();
        insert TC_TestDataFactory.buildCommission(d.Id, 'TC_Inside_Broker', 100);
        d.TC_Gross_Fee_Percent__c = 2;
        update d;
        System.assertEquals(400000, [SELECT TC_Gross_Commission__c FROM TC_Commission__c].TC_Gross_Commission__c);
        TC_Commission__c c = [SELECT Id FROM TC_Commission__c];
        c.TC_Fee_Percent__c = 50;
        update c;
        System.assertEquals(200000, [SELECT TC_Gross_Commission__c FROM TC_Commission__c].TC_Gross_Commission__c);
        delete c;
        System.assertEquals(0, [SELECT TC_Total_Commission_Split__c FROM TC_Deal__c].TC_Total_Commission_Split__c);
    }

    @IsTest
    static void outsideSplitsCannotExceedHundredPercent() {
        Id dealId = deal().Id;
        insert TC_TestDataFactory.buildCommission(dealId, 'TC_Co_Broker', 80);
        Database.SaveResult sr = Database.insert(TC_TestDataFactory.buildCommission(dealId, 'TC_Analyst', 30), false);
        System.assert(!sr.isSuccess(), 'Analyst + co-broker would be 110%');
        System.assert(sr.getErrors()[0].getMessage().contains('110'), sr.getErrors()[0].getMessage());
    }

    @IsTest
    static void insideSplitsCannotExceedHundredPercent() {
        Id dealId = deal().Id;
        Database.SaveResult[] results = Database.insert(new List<TC_Commission__c>{
            TC_TestDataFactory.buildCommission(dealId, 'TC_Inside_Broker', 60),
            TC_TestDataFactory.buildCommission(dealId, 'TC_Inside_Broker', 50)
        }, false);
        System.assert(!results[0].isSuccess() || !results[1].isSuccess(), 'Inside brokers would total 110%');
    }

    @IsTest
    static void insideBrokerNeedsUserAndAmountMethodNeedsAmount() {
        Id dealId = deal().Id;
        TC_Commission__c c = TC_TestDataFactory.buildCommission(dealId, 'TC_Inside_Broker', 10);
        c.TC_Broker__c = null;
        System.assert(!Database.insert(c, false).isSuccess(), 'Inside broker requires a user');
        TC_Commission__c a = TC_TestDataFactory.buildCommission(dealId, 'TC_Co_Broker', null);
        a.TC_Fee_Method__c = 'Amount';
        System.assert(!Database.insert(a, false).isSuccess(), 'Amount method requires an amount');
    }

    @IsTest
    static void statusFollowsDealOutcome() {
        TC_Deal__c d = deal();
        insert TC_TestDataFactory.buildCommission(d.Id, 'TC_Inside_Broker', 100);
        d.TC_Status__c = 'Lost';
        d.TC_Lost_Reason__c = 'Timing';
        update d;
        System.assertEquals('Cancelled', [SELECT TC_Status__c FROM TC_Commission__c].TC_Status__c);
        d.TC_Status__c = 'Open';
        d.TC_Actual_Close_Date__c = null;
        update d;
        System.assertEquals('Projected', [SELECT TC_Status__c FROM TC_Commission__c].TC_Status__c);
    }

    @IsTest
    static void bulkEntryRowsAreCappedAtThirty() {
        List<TC_Commission__c> rows = TC_CommissionService.newRows(deal().Id, 'TC_Analyst', 45);
        System.assertEquals(30, rows.size());
        System.assertEquals(TC_TestDataFactory.rt(TC_Commission__c.SObjectType, 'TC_Analyst'), rows[0].RecordTypeId);
        System.assertEquals(1, TC_CommissionService.newRows(deal().Id, 'TC_Analyst', null).size());
    }
}
