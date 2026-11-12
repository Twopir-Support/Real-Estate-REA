/** Verifies the TC record-triggered flows and the commission flow hook end to end. */
@IsTest
private class TC_FlowAutomationTest {

    @TestSetup
    static void setup() {
        Account a = TC_TestDataFactory.account('Flow Tenant', 'Tenant');
        TC_TestDataFactory.property('Flow Tower', a.Id);
    }

    @IsTest
    static void newInquiryGetsFollowUpTask() {
        TC_Inquiry__c i = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_First_Name__c = 'Ana', TC_Last_Name__c = 'Ruiz', TC_Source__c = 'Website');
        Test.startTest();
        insert i;
        Test.stopTest();
        List<Task> tasks = [SELECT Subject, ActivityDate, Priority FROM Task WHERE WhatId = :i.Id];
        System.assertEquals(1, tasks.size(), 'TC_Inquiry_New_Follow_Up creates one task');
        System.assert(tasks[0].Subject.contains('Ana Ruiz'), tasks[0].Subject);
        System.assertEquals(Date.today().addDays(1), tasks[0].ActivityDate);
    }

    @IsTest
    static void bypassSettingStopsFlows() {
        insert new TC_Bypass_Settings__c(SetupOwnerId = UserInfo.getUserId(), TC_Bypass_Flows__c = true);
        TC_Inquiry__c i = new TC_Inquiry__c(TC_Inquiry_Type__c = 'Lease', TC_Last_Name__c = 'Bypass', TC_Source__c = 'Phone');
        insert i;
        System.assertEquals(0, [SELECT COUNT() FROM Task WHERE WhatId = :i.Id]);
    }

    @IsTest
    static void dealStageChangesCreateTasks() {
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM TC_Property__c LIMIT 1].Id);
        insert d;
        Test.startTest();
        d.TC_Stage__c = 'LOI';
        update d;
        d.TC_Stage__c = 'Lease / PSA Out';
        update d;
        Test.stopTest();
        List<Task> tasks = [SELECT Subject FROM Task WHERE WhatId = :d.Id ORDER BY CreatedDate];
        System.assertEquals(2, tasks.size());
        System.assert(tasks[0].Subject.startsWith('Send the LOI'));
        System.assert(tasks[1].Subject.startsWith('Collect executed'));
    }

    @IsTest
    static void commissionHookDefaultsHousePercent() {
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal([SELECT Id FROM Account LIMIT 1].Id, [SELECT Id FROM TC_Property__c LIMIT 1].Id);
        insert d;
        TC_Commission__c c = TC_CommissionService.newRows(d.Id, 'TC_Inside_Broker', 1)[0];
        c.TC_Broker__c = UserInfo.getUserId();
        c.TC_Fee_Percent__c = 100;
        TC_DealUIController.saveCommissions(new List<TC_Commission__c>{ c });
        System.assertEquals(30, [SELECT TC_House_Fee_Percent__c FROM TC_Commission__c WHERE TC_Deal__c = :d.Id].TC_House_Fee_Percent__c, 'Flow hook set the default house %');
    }
}
