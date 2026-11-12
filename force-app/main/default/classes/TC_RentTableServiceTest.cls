@IsTest
private class TC_RentTableServiceTest {

    @IsTest
    static void scheduleWithEscalationAndFreeRent() {
        TC_RentTableService.Terms t = new TC_RentTableService.Terms();
        t.commencement = Date.newInstance(2026, 1, 1);
        t.expiration = Date.newInstance(2028, 12, 31);
        t.rate = 30;
        t.escalationPct = 3;
        t.freeMonths = 3;
        List<TC_RentTableService.Period> s = TC_RentTableService.buildSchedule(t);
        System.assertEquals(4, s.size(), '3 years, first year split into free + paid');
        System.assert(s[0].freeRent);
        System.assertEquals(Date.newInstance(2026, 3, 31), s[0].toDate);
        System.assertEquals(Date.newInstance(2026, 4, 1), s[1].fromDate);
        System.assertEquals(30.00, s[1].rate);
        System.assertEquals(30.90, s[2].rate, 'Year 2 escalated 3%');
        System.assertEquals(31.83, s[3].rate, 'Year 3 escalated again');
        System.assertEquals(Date.newInstance(2028, 12, 31), s[3].toDate);
        System.assertEquals(0, TC_RentTableService.buildSchedule(null).size());
    }

    @IsTest
    static void annualRatioAndMonthlyRateMethods() {
        TC_Deal_Period__c annual = new TC_Deal_Period__c(TC_From__c = Date.newInstance(2025, 1, 1), TC_To__c = Date.newInstance(2025, 6, 30), TC_Rate__c = 24);
        TC_RentTableService.calculateOne(annual, 1000, TC_RentTableService.ANNUAL_RATIO);
        System.assertEquals(2000, annual.TC_Rent_Per_Month__c, '24 x 1000 / 12');
        System.assertEquals(6.00, annual.TC_Duration_Months__c);
        System.assertEquals(11901.37, annual.TC_Total_Rent__c, '181/365 x 24,000');
        TC_Deal_Period__c monthly = new TC_Deal_Period__c(TC_From__c = Date.newInstance(2025, 1, 1), TC_To__c = Date.newInstance(2025, 6, 30), TC_Rate__c = 24);
        TC_RentTableService.calculateOne(monthly, 1000, TC_RentTableService.MONTHLY_RATE);
        System.assertEquals(12000, monthly.TC_Total_Rent__c, '6 months x 2,000');
        TC_Deal_Period__c free = new TC_Deal_Period__c(TC_From__c = Date.newInstance(2025, 1, 1), TC_To__c = Date.newInstance(2025, 1, 31), TC_Rate__c = 24, TC_Free_Rent__c = true);
        TC_RentTableService.calculateOne(free, 1000, null);
        System.assertEquals(0, free.TC_Total_Rent__c);
        System.assertEquals(1.50, TC_RentTableService.durationMonths(Date.newInstance(2025, 1, 1), Date.newInstance(2025, 2, 15)));
    }

    @IsTest
    static void reviewFlagsGapsOverlapsAndBlankRent() {
        List<SObject> rows = new List<SObject>{
            new TC_Lease_Period__c(TC_Period_Number__c = 2, TC_From__c = Date.newInstance(2025, 3, 1), TC_To__c = Date.newInstance(2025, 12, 31), TC_Rate__c = 20),
            new TC_Lease_Period__c(TC_Period_Number__c = 1, TC_From__c = Date.newInstance(2025, 1, 1), TC_To__c = Date.newInstance(2025, 1, 31), TC_Rate__c = 20),
            new TC_Lease_Period__c(TC_Period_Number__c = 3, TC_From__c = Date.newInstance(2025, 12, 1), TC_To__c = Date.newInstance(2026, 12, 31))
        };
        List<String> warnings = TC_RentTableService.review(rows);
        System.assertEquals(3, warnings.size(), String.join(warnings, ' | '));
        System.assert(String.join(warnings, ' ').contains('Gap'));
        System.assert(String.join(warnings, ' ').contains('overlaps'));
        System.assert(String.join(warnings, ' ').contains('no rent'));
    }

    @IsTest
    static void leaseGetsGeneratedRentTableAndTotal() {
        Account owner = TC_TestDataFactory.account('Owner', 'Owner/Landlord');
        Account tenant = TC_TestDataFactory.account('Tenant', 'Tenant');
        TC_Property__c p = TC_TestDataFactory.property('Rent Tower', owner.Id);
        TC_Lease__c l = TC_TestDataFactory.buildLease(p.Id, null, tenant.Id, Date.newInstance(2025, 1, 1), 36);
        Test.startTest();
        insert l;
        Test.stopTest();
        TC_Lease__c saved = [SELECT TC_Total_Rent__c, TC_Owner_Landlord__c, (SELECT TC_Rate__c FROM Lease_Periods__r ORDER BY TC_From__c) FROM TC_Lease__c WHERE Id = :l.Id];
        System.assertEquals(3, saved.Lease_Periods__r.size());
        System.assertEquals(30.90, saved.Lease_Periods__r[1].TC_Rate__c);
        System.assert(saved.TC_Total_Rent__c > 230000, 'Roll-up of period totals: ' + saved.TC_Total_Rent__c);
        System.assertEquals(owner.Id, saved.TC_Owner_Landlord__c, 'Landlord defaults from the property owner');
        // Regenerate with replace
        System.assertEquals(3, TC_RentTableService.generateForLeases(new Set<Id>{ l.Id }, true));
        System.assertEquals(0, TC_RentTableService.generateForLeases(new Set<Id>{ l.Id }, false), 'Existing table is kept');
    }

    @IsTest
    static void periodNeedsRateOrRent() {
        Account a = TC_TestDataFactory.account('Owner', 'Owner/Landlord');
        TC_Property__c p = TC_TestDataFactory.property('VR Tower', a.Id);
        TC_Deal__c d = TC_TestDataFactory.buildLeaseDeal(a.Id, p.Id);
        insert d;
        Database.SaveResult sr = Database.insert(new TC_Deal_Period__c(TC_Deal__c = d.Id, TC_From__c = Date.today(), TC_To__c = Date.today().addMonths(12)), false);
        System.assert(!sr.isSuccess(), 'Blank rate and rent per month are rejected');
        Database.SaveResult backwards = Database.insert(new TC_Deal_Period__c(TC_Deal__c = d.Id, TC_From__c = Date.today(), TC_To__c = Date.today().addDays(-5), TC_Rate__c = 10), false);
        System.assert(!backwards.isSuccess(), 'End before start is rejected');
        // Deal periods drive the gross deal value
        TC_RentTableService.generateForDeals(new Set<Id>{ d.Id }, true);
        Decimal sum = (Decimal) [SELECT SUM(TC_Total_Rent__c) s FROM TC_Deal_Period__c WHERE TC_Deal__c = :d.Id][0].get('s');
        System.assertEquals(sum, [SELECT TC_Gross_Deal_Value__c FROM TC_Deal__c WHERE Id = :d.Id].TC_Gross_Deal_Value__c);
    }
}
