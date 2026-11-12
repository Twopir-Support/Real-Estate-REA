@IsTest
private class TC_LeaseServiceTest {

    @TestSetup
    static void setup() {
        Account owner = TC_TestDataFactory.account('Owner LLC', 'Owner/Landlord');
        TC_TestDataFactory.account('Tenant Inc', 'Tenant');
        TC_Property__c p = TC_TestDataFactory.property('Lease Tower', owner.Id);
        TC_TestDataFactory.units(p.Id, 2, 2);
    }

    static TC_Property__c prop() { return [SELECT Id, TC_Owner_Landlord__c FROM TC_Property__c LIMIT 1]; }
    static Account tenant() { return [SELECT Id FROM Account WHERE Name = 'Tenant Inc']; }
    static List<TC_Unit__c> units() { return [SELECT Id, Name FROM TC_Unit__c ORDER BY Name]; }

    @IsTest
    static void activeLeaseOccupiesUnitAndRollsUpToProperty() {
        TC_Unit__c u = units()[0];
        TC_Lease__c l = TC_TestDataFactory.buildLease(prop().Id, u.Id, tenant().Id, Date.today().addMonths(-6), 60);
        Test.startTest();
        insert l;
        Test.stopTest();
        TC_Unit__c su = [SELECT TC_Status__c, TC_Current_Tenant__c, TC_Current_Lease__c, TC_Lease_Expiration__c FROM TC_Unit__c WHERE Id = :u.Id];
        System.assertEquals('Occupied', su.TC_Status__c);
        System.assertEquals(tenant().Id, su.TC_Current_Tenant__c);
        System.assertEquals(l.Id, su.TC_Current_Lease__c);
        TC_Lease__c sl = [SELECT TC_Unit_Name__c, TC_Floor__c, TC_Unit_Type__c FROM TC_Lease__c WHERE Id = :l.Id];
        System.assertEquals(u.Name, sl.TC_Unit_Name__c, 'Unit details copied to the lease');
        System.assertEquals('Office', sl.TC_Unit_Type__c);
        TC_Property__c p = [SELECT TC_Leased_SF__c, TC_Occupancy__c FROM TC_Property__c LIMIT 1];
        System.assertEquals(2500, p.TC_Leased_SF__c);
        System.assertEquals(2.5, p.TC_Occupancy__c.setScale(1), '2,500 of 100,000 SF = 2.5% (Apex reads percent fields in percent units)');
        // Terminating frees the unit
        l.TC_Status__c = 'Terminated';
        update l;
        System.assertEquals('Vacant', [SELECT TC_Status__c FROM TC_Unit__c WHERE Id = :u.Id].TC_Status__c);
        System.assertEquals(0, [SELECT TC_Leased_SF__c FROM TC_Property__c LIMIT 1].TC_Leased_SF__c);
        delete l;
        undelete l;
    }

    @IsTest
    static void overlappingActiveLeasesOnSameUnitAreRejected() {
        TC_Unit__c u = units()[0];
        insert TC_TestDataFactory.buildLease(prop().Id, u.Id, tenant().Id, Date.today().addMonths(-6), 60);
        TC_Lease__c clash = TC_TestDataFactory.buildLease(prop().Id, u.Id, tenant().Id, Date.today().addMonths(12), 24);
        Database.SaveResult sr = Database.insert(clash, false);
        System.assert(!sr.isSuccess(), 'Overlap must be blocked');
        System.assert(sr.getErrors()[0].getMessage().contains('overlapping'), sr.getErrors()[0].getMessage());
        // A future lease after expiry is fine
        insert TC_TestDataFactory.buildLease(prop().Id, u.Id, tenant().Id, Date.today().addMonths(60), 12);
        // Two overlapping leases in one transaction are also caught
        TC_Unit__c u2 = units()[1];
        Database.SaveResult[] both = Database.insert(new List<TC_Lease__c>{
            TC_TestDataFactory.buildLease(prop().Id, u2.Id, tenant().Id, Date.today(), 12),
            TC_TestDataFactory.buildLease(prop().Id, u2.Id, tenant().Id, Date.today().addMonths(3), 12)
        }, false);
        System.assert(both[0].isSuccess() != both[1].isSuccess(), 'Exactly one of the pair fails');
    }

    @IsTest
    static void leaseValidationRules() {
        TC_Lease__c backwards = TC_TestDataFactory.buildLease(prop().Id, null, tenant().Id, Date.today(), 12);
        backwards.TC_Expiration_Date__c = Date.today().addDays(-1);
        System.assert(!Database.insert(backwards, false).isSuccess(), 'Expiration before commencement');
        TC_Lease__c notice = TC_TestDataFactory.buildLease(prop().Id, null, tenant().Id, Date.today(), 12);
        notice.TC_Option_Notice_Date__c = Date.today().addYears(2);
        System.assert(!Database.insert(notice, false).isSuccess(), 'Option notice after expiration');
    }

    @IsTest
    static void bypassSettingSkipsValidationAndTriggers() {
        insert new TC_Bypass_Settings__c(SetupOwnerId = UserInfo.getUserId(), TC_Bypass_Triggers__c = true, TC_Bypass_Validation_Rules__c = true);
        TC_Lease__c l = TC_TestDataFactory.buildLease(prop().Id, units()[0].Id, tenant().Id, Date.today(), 12);
        l.TC_Option_Notice_Date__c = Date.today().addYears(3);
        insert l;
        System.assertEquals(0, [SELECT COUNT() FROM TC_Lease_Period__c], 'Triggers bypassed: no rent table');
        System.assertEquals('Vacant', [SELECT TC_Status__c FROM TC_Unit__c WHERE Id = :units()[0].Id].TC_Status__c);
        System.assert(TC_TriggerHandler.triggersBypassed());
    }

    @IsTest
    static void dailySweepExpiresAndActivatesLeases() {
        TC_Lease__c old = TC_TestDataFactory.buildLease(prop().Id, units()[0].Id, tenant().Id, Date.today().addYears(-3), 24);
        TC_Lease__c pending = TC_TestDataFactory.buildLease(prop().Id, units()[1].Id, tenant().Id, Date.today().addDays(-1), 24);
        pending.TC_Status__c = 'Pending';
        insert new List<TC_Lease__c>{ old, pending };
        Test.startTest();
        System.schedule('TC Daily Test', '0 0 2 * * ?', new TC_DailyScheduler());
        TC_DailyScheduler.run();
        Test.stopTest();
        System.assertEquals('Expired', [SELECT TC_Status__c FROM TC_Lease__c WHERE Id = :old.Id].TC_Status__c);
        System.assertEquals('Active', [SELECT TC_Status__c FROM TC_Lease__c WHERE Id = :pending.Id].TC_Status__c);
        System.assertEquals('Occupied', [SELECT TC_Status__c FROM TC_Unit__c WHERE Id = :units()[1].Id].TC_Status__c);
    }

    @IsTest
    static void availabilityRollsUpToPropertyAndListing() {
        TC_Property__c p = prop();
        TC_Listing__c l = TC_TestDataFactory.listing(p.Id, 'TC_Lease', 'Active');
        TC_Availability__c a = TC_TestDataFactory.availability(p.Id, units()[0].Id, l.Id);
        TC_Availability__c sa = [SELECT Name, TC_Unit_Name__c, TC_Floor__c FROM TC_Availability__c WHERE Id = :a.Id];
        System.assert(sa.Name.startsWith('Lease Tower'), 'Named from mapping: ' + sa.Name);
        System.assertEquals(1, sa.TC_Floor__c, 'Floor copied from unit');
        TC_Property__c sp = [SELECT TC_Available_SF__c, TC_Avg_Asking_Rate__c, TC_Active_Listings__c FROM TC_Property__c WHERE Id = :p.Id];
        System.assertEquals(2500, sp.TC_Available_SF__c);
        System.assertEquals(32, sp.TC_Avg_Asking_Rate__c);
        System.assertEquals(1, sp.TC_Active_Listings__c);
        System.assertEquals(2500, [SELECT TC_Total_Available_SF__c FROM TC_Listing__c WHERE Id = :l.Id].TC_Total_Available_SF__c);
        a.TC_Status__c = 'Off Market';
        update a;
        System.assertEquals(0, [SELECT TC_Available_SF__c FROM TC_Property__c WHERE Id = :p.Id].TC_Available_SF__c);
        delete a;
        undelete a;
        l.TC_Status__c = 'Withdrawn';
        update l;
        System.assertEquals(0, [SELECT TC_Active_Listings__c FROM TC_Property__c WHERE Id = :p.Id].TC_Active_Listings__c);
        delete l;
    }

    @IsTest
    static void propertyDefaultsTypeAndOwnerPortfolio() {
        TC_Property__c p = [SELECT TC_Property_Type__c, TC_Owner_Landlord__c FROM TC_Property__c LIMIT 1];
        System.assertEquals('Office', p.TC_Property_Type__c, 'Type defaults from record type');
        System.assertEquals(100000, [SELECT TC_Portfolio_SF__c FROM Account WHERE Id = :p.TC_Owner_Landlord__c].TC_Portfolio_SF__c);
        p.TC_Owner_Landlord__c = tenant().Id;
        update p;
        System.assertEquals(0, [SELECT TC_Portfolio_SF__c FROM Account WHERE Name = 'Owner LLC'].TC_Portfolio_SF__c);
        System.assertEquals(100000, [SELECT TC_Portfolio_SF__c FROM Account WHERE Id = :tenant().Id].TC_Portfolio_SF__c);
    }

    @IsTest
    static void contactFollowUpSequence() {
        Contact c = TC_TestDataFactory.contact(tenant().Id, 'Followup');
        c.TC_Automated_Follow_up_Tasks__c = true;
        c.TC_Follow_up_Sequence__c = '30-60-90 Days';
        update c;
        System.assertEquals(1, TC_DailyScheduler.createFollowUps());
        Contact s = [SELECT TC_Follow_up_Step__c, TC_Next_Follow_up_Date__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals(1, s.TC_Follow_up_Step__c);
        System.assertEquals(Date.today().addDays(30), s.TC_Next_Follow_up_Date__c);
        System.assertEquals(0, TC_DailyScheduler.createFollowUps(), 'Nothing due until the next date');
        System.assertEquals(null, TC_DailyScheduler.nextDate('30-60-90 Days', 3, Date.today()));
        System.assertEquals(Date.today().addMonths(3), TC_DailyScheduler.nextDate('Quarterly', 1, Date.today()));
        System.assertEquals(Date.today().addMonths(1), TC_DailyScheduler.nextDate('Monthly', 1, Date.today()));
    }
}
