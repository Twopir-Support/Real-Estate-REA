// TC sample data, step 4 of 4: inquiries (with matched prospective listings, two converted, one
// disqualified), capital sources with deal sources and term sheets, sale comps, market rents and
// internal relationships.
// Run after step 3:  sf apex run -o REA-Dev -f scripts/apex/sample-data-4-inquiries-capital-comps.apex

final String MARK = '[TC Sample]';
Map<String, Id> acct = new Map<String, Id>();
for (Account a : [SELECT Id, Name FROM Account WHERE Site = :MARK]) { acct.put(a.Name, a.Id); }
Map<String, Id> prop = new Map<String, Id>();
for (TC_Property__c p : [SELECT Id, Name FROM TC_Property__c WHERE TC_Owner_Landlord__r.Site = :MARK]) { prop.put(p.Name, p.Id); }
if (prop.isEmpty()) { throw new TC_Exception('Run steps 1 to 3 first.'); }
if ([SELECT COUNT() FROM TC_Capital_Source__c WHERE TC_Account__c IN :acct.values()] > 0) { throw new TC_Exception('Step 4 has already run.'); }
Map<Id, Id> firstContact = new Map<Id, Id>();
for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Account.Site = :MARK ORDER BY Name]) {
    if (!firstContact.containsKey(c.AccountId)) { firstContact.put(c.AccountId, c.Id); }
}
Map<Id, Id> listingByProp = new Map<Id, Id>();
for (TC_Listing__c l : [SELECT Id, TC_Property__c FROM TC_Listing__c WHERE TC_Property__c IN :prop.values() AND TC_Status__c = 'Active']) { listingByProp.put(l.TC_Property__c, l.Id); }

// ---------------------------------------------------------------- inquiries
// type, first, last, company, source, property type, min, max, max rate, max price, city, listing property, broker co
List<Object[]> rows = new List<Object[]>{
    new Object[]{ 'Lease', 'Grace', 'Holt', 'Lumen Robotics', 'Website', 'Office', 8000, 12000, 46, null, 'Austin', 'Domain Gateway', null },
    new Object[]{ 'Lease', 'Felix', 'Moreau', 'Tidewater Consulting', 'Listing Portal', 'Office', 4000, 6000, 30, null, 'Dallas', 'Preston Center Plaza', null },
    new Object[]{ 'Lease', 'Iris', 'Calloway', 'Northwind Legal', 'Sign Call', 'Office', 10000, 22000, 45, null, 'Dallas', 'Uptown Commerce Tower', null },
    new Object[]{ 'Lease', 'Mateo', 'Serrano', 'Bright Path Pediatrics', 'Referral', 'Retail', 3000, 6000, 40, null, 'Houston', 'Galleria West Center', 'Bayou City Realty Partners' },
    new Object[]{ 'Lease', 'Wren', 'Atwood', 'Spark Climbing Gym', 'Phone', 'Retail', 6000, 9000, 28, null, 'Cedar Park', 'Lakeline Square', null },
    new Object[]{ 'Lease', 'Dev', 'Raman', 'Velocity Parcel', 'Outside Broker', 'Industrial', 80000, 150000, 7.5, null, 'Grand Prairie', 'DFW Logistics Park Building 2', 'Crescent Brokerage Group' },
    new Object[]{ 'Lease', 'Sofia', 'Lindgren', 'Cedar & Oak Furniture', 'Email', 'Industrial', 30000, 50000, 7, null, 'Houston', 'Pinemont Distribution Center', null },
    new Object[]{ 'Sale', 'Hugo', 'Brandt', 'Brandt Holdings', 'Referral', 'Industrial', 100000, 250000, null, 30000000, 'Austin', 'Southpark Commerce Center', null },
    new Object[]{ 'Sale', 'Amara', 'Nwosu', 'Keel Street Capital', 'Event', 'Land', null, null, null, 20000000, 'Frisco', 'Frisco Station Land', null },
    new Object[]{ 'Lease', 'Theo', 'Park', 'Quantum Ledger', 'Website', 'Office', 15000, 25000, 48, null, 'Austin', null, null },
    new Object[]{ 'Lease', 'Lena', 'Voss', 'Harvest Table Bistro', 'Sign Call', 'Retail', 2500, 4000, 38, null, 'Houston', null, null },
    new Object[]{ 'Lease', 'Rafael', 'Ortega', 'Ortega Dental', 'Phone', 'Office', 3000, 5000, 32, null, 'Dallas', null, null },
    new Object[]{ 'Sale', 'Claire', 'Dubois', 'Dubois Family Trust', 'Referral', 'Industrial', 150000, 300000, null, 28000000, 'Houston', null, null },
    new Object[]{ 'Lease', 'Kai', 'Morales', 'Morales Print Co', 'Listing Portal', 'Industrial', 40000, 60000, 7, null, 'Houston', 'Pinemont Distribution Center', null },
    new Object[]{ 'Lease', 'Nora', 'Quinn', 'Quinn Architects', 'Website', 'Office', 4000, 9000, 36, null, 'Austin', null, null }
};
List<TC_Inquiry__c> inqs = new List<TC_Inquiry__c>();
Integer i = 0;
for (Object[] r : rows) {
    Id listing = r[11] == null ? null : listingByProp.get(prop.get((String) r[11]));
    Id brokerCo = r[12] == null ? null : acct.get((String) r[12]);
    inqs.add(new TC_Inquiry__c(TC_Inquiry_Type__c = (String) r[0], TC_First_Name__c = (String) r[1], TC_Last_Name__c = (String) r[2], TC_Company_Name__c = (String) r[3],
        TC_Email__c = ((String) r[1] + '.' + (String) r[2]).toLowerCase() + '@example.com', TC_Phone__c = '(555) 014-' + String.valueOf(2000 + i),
        TC_Source__c = (String) r[4], TC_Property_Type__c = (String) r[5], TC_Size_Min__c = (Integer) r[6], TC_Size_Max__c = (Integer) r[7],
        TC_Max_Rate__c = (Decimal) r[8], TC_Price_Max__c = (Decimal) r[9], TC_Preferred_City__c = (String) r[10], TC_Listing__c = listing,
        TC_Property__c = r[11] == null ? prop.get('Uptown Commerce Tower') : null,
        TC_Broker_Company__c = brokerCo, TC_Broker_Contact__c = brokerCo == null ? null : firstContact.get(brokerCo),
        TC_Status__c = Math.mod(i, 3) == 0 ? 'New' : 'Active', TC_Date_Needed__c = Date.today().addMonths(3 + Math.mod(i, 6)),
        TC_Notes__c = 'Sample requirement. ' + MARK));
    i++;
}
insert inqs;
// Score every inquiry and save the matches as prospective listings
Integer matched = 0;
for (TC_Inquiry__c q : inqs) {
    matched += TC_InquiryService.saveMatches(q.Id, TC_InquiryService.scoreMatches(q.Id, 4));
}
// Convert two, disqualify one
TC_InquiryService.convert(inqs[0].Id, null, true);
TC_InquiryService.convert(inqs[5].Id, null, true);
update new TC_Inquiry__c(Id = inqs[11].Id, TC_Status__c = 'Disqualified', TC_Disqualified_Reason__c = 'No Longer Looking');

// ---------------------------------------------------------------- capital sources
List<TC_Capital_Source__c> sources = new List<TC_Capital_Source__c>{
    new TC_Capital_Source__c(Name = 'First Lone Star Bank - CRE Term Loans', TC_Account__c = acct.get('First Lone Star Bank'), TC_Contact__c = firstContact.get(acct.get('First Lone Star Bank')),
        TC_Source_Type__c = 'Bank', TC_Capital_Types__c = 'Senior Debt;Construction Loan', TC_Property_Types__c = 'Office;Retail;Industrial', TC_Target_Markets__c = 'Dallas-Fort Worth, Austin',
        TC_Min_Deal_Size__c = 5000000, TC_Max_Deal_Size__c = 75000000, TC_Max_LTV__c = 65, TC_Min_DSCR__c = 1.25, TC_Target_Rate__c = 6.4, TC_Typical_Term_Years__c = 5, TC_Status__c = 'Active'),
    new TC_Capital_Source__c(Name = 'Republic Life - Core Fixed Rate', TC_Account__c = acct.get('Republic Life Insurance Co'), TC_Contact__c = firstContact.get(acct.get('Republic Life Insurance Co')),
        TC_Source_Type__c = 'Life Company', TC_Capital_Types__c = 'Senior Debt', TC_Property_Types__c = 'Office;Industrial;Multifamily', TC_Target_Markets__c = 'Texas major metros',
        TC_Min_Deal_Size__c = 20000000, TC_Max_Deal_Size__c = 150000000, TC_Max_LTV__c = 60, TC_Min_DSCR__c = 1.35, TC_Target_Rate__c = 5.9, TC_Typical_Term_Years__c = 10, TC_Status__c = 'Active'),
    new TC_Capital_Source__c(Name = 'Cypress Debt Fund - Bridge', TC_Account__c = acct.get('Cypress Debt Fund'), TC_Contact__c = firstContact.get(acct.get('Cypress Debt Fund')),
        TC_Source_Type__c = 'Debt Fund', TC_Capital_Types__c = 'Bridge Loan;Mezzanine', TC_Property_Types__c = 'Office;Retail;Hospitality', TC_Target_Markets__c = 'Sun Belt',
        TC_Min_Deal_Size__c = 10000000, TC_Max_Deal_Size__c = 120000000, TC_Max_LTV__c = 75, TC_Min_DSCR__c = 1.10, TC_Target_Rate__c = 8.75, TC_Typical_Term_Years__c = 3, TC_Status__c = 'Active'),
    new TC_Capital_Source__c(Name = 'Alamo Agency Lending - Multifamily', TC_Account__c = acct.get('Alamo Agency Lending'), TC_Source_Type__c = 'Agency', TC_Capital_Types__c = 'Senior Debt',
        TC_Property_Types__c = 'Multifamily', TC_Min_Deal_Size__c = 3000000, TC_Max_Deal_Size__c = 60000000, TC_Max_LTV__c = 75, TC_Min_DSCR__c = 1.25, TC_Target_Rate__c = 5.6, TC_Typical_Term_Years__c = 10, TC_Status__c = 'Active'),
    new TC_Capital_Source__c(Name = 'Mesa Industrial Fund - JV Equity', TC_Account__c = acct.get('Mesa Industrial Fund'), TC_Source_Type__c = 'Private Equity', TC_Capital_Types__c = 'Joint Venture Equity;Preferred Equity',
        TC_Property_Types__c = 'Industrial', TC_Min_Deal_Size__c = 5000000, TC_Max_Deal_Size__c = 40000000, TC_Target_Rate__c = 14, TC_Status__c = 'Active')
};
insert sources;
TC_Deal__c refi = [SELECT Id FROM TC_Deal__c WHERE Name = 'Uptown Commerce Tower - Refinance' LIMIT 1];
List<TC_Deal_Source__c> dsrc = new List<TC_Deal_Source__c>{
    new TC_Deal_Source__c(TC_Deal__c = refi.Id, TC_Capital_Source__c = sources[0].Id, TC_Contact__c = sources[0].TC_Contact__c, TC_Status__c = 'Term Sheet Received', TC_Date_Contacted__c = Date.today().addDays(-30)),
    new TC_Deal_Source__c(TC_Deal__c = refi.Id, TC_Capital_Source__c = sources[1].Id, TC_Contact__c = sources[1].TC_Contact__c, TC_Status__c = 'Term Sheet Received', TC_Date_Contacted__c = Date.today().addDays(-28)),
    new TC_Deal_Source__c(TC_Deal__c = refi.Id, TC_Capital_Source__c = sources[2].Id, TC_Contact__c = sources[2].TC_Contact__c, TC_Status__c = 'Term Sheet Received', TC_Date_Contacted__c = Date.today().addDays(-25)),
    new TC_Deal_Source__c(TC_Deal__c = refi.Id, TC_Capital_Source__c = sources[3].Id, TC_Status__c = 'Declined', TC_Date_Contacted__c = Date.today().addDays(-25), TC_Notes__c = 'Multifamily only.')
};
insert dsrc;
insert new List<TC_Term_Sheet__c>{
    new TC_Term_Sheet__c(Name = 'First Lone Star - 5yr floating', TC_Deal_Source__c = dsrc[0].Id, TC_Quote_Date__c = Date.today().addDays(-14), TC_Loan_Amount__c = 90000000, TC_Interest_Rate__c = 6.35,
        TC_Rate_Type__c = 'Floating', TC_Term_Years__c = 5, TC_Amortization_Years__c = 30, TC_LTV__c = 62, TC_DSCR__c = 1.30, TC_Recourse__c = 'Partial Recourse', TC_Origination_Fee__c = 0.75, TC_Prepayment__c = '1% in year 1, open thereafter'),
    new TC_Term_Sheet__c(Name = 'Republic Life - 10yr fixed', TC_Deal_Source__c = dsrc[1].Id, TC_Quote_Date__c = Date.today().addDays(-10), TC_Loan_Amount__c = 95000000, TC_Interest_Rate__c = 5.85,
        TC_Rate_Type__c = 'Fixed', TC_Term_Years__c = 10, TC_Amortization_Years__c = 30, TC_LTV__c = 60, TC_DSCR__c = 1.40, TC_Recourse__c = 'Non-Recourse', TC_Origination_Fee__c = 0.50, TC_Prepayment__c = 'Yield maintenance'),
    new TC_Term_Sheet__c(Name = 'Cypress - 3yr bridge', TC_Deal_Source__c = dsrc[2].Id, TC_Quote_Date__c = Date.today().addDays(-7), TC_Loan_Amount__c = 105000000, TC_Interest_Rate__c = 8.60,
        TC_Rate_Type__c = 'Floating', TC_Term_Years__c = 3, TC_Amortization_Years__c = 0, TC_LTV__c = 70, TC_DSCR__c = 1.10, TC_Recourse__c = 'Non-Recourse', TC_Origination_Fee__c = 1.00, TC_Prepayment__c = '12-month minimum interest')
};
insert new TC_Deal_Property__c(TC_Deal__c = refi.Id, TC_Property__c = prop.get('Uptown Commerce Tower'), TC_Allocated_Value__c = 158000000, TC_Primary__c = true);

// ---------------------------------------------------------------- sale comps and market rents
insert new List<TC_Sale__c>{
    new TC_Sale__c(TC_Property__c = prop.get('Preston Center Plaza'), TC_Sale_Date__c = Date.today().addYears(-3).addMonths(-2), TC_Sale_Price__c = 21500000, TC_Listing_Price__c = 23000000, TC_Size__c = 90000, TC_Cap_Rate__c = 6.9, TC_NOI__c = 1483500, TC_Sale_Type__c = 'Investment', TC_Buyer__c = acct.get('Lone Star Property Holdings'), TC_Seller__c = acct.get('Brazos Development Group'), TC_Comp_Only__c = true),
    new TC_Sale__c(TC_Property__c = prop.get('Katy Freeway Marketplace'), TC_Sale_Date__c = Date.today().addYears(-2).addMonths(-5), TC_Sale_Price__c = 17800000, TC_Size__c = 85000, TC_Cap_Rate__c = 7.2, TC_NOI__c = 1281600, TC_Sale_Type__c = 'Investment', TC_Buyer__c = acct.get('Gulf Coast Realty Trust'), TC_Comp_Only__c = true),
    new TC_Sale__c(TC_Property__c = prop.get('DFW Logistics Park Building 2'), TC_Sale_Date__c = Date.today().addYears(-1).addMonths(-3), TC_Sale_Price__c = 58500000, TC_Size__c = 450000, TC_Cap_Rate__c = 5.4, TC_NOI__c = 3159000, TC_Sale_Type__c = 'Investment', TC_Buyer__c = acct.get('Prairie Logistics REIT'), TC_Comp_Only__c = true),
    new TC_Sale__c(TC_Property__c = prop.get('Congress Avenue Lofts'), TC_Sale_Date__c = Date.today().addYears(-4), TC_Sale_Price__c = 16200000, TC_Size__c = 45000, TC_Cap_Rate__c = 6.1, TC_Sale_Type__c = 'Investment', TC_Buyer__c = acct.get('Bluebonnet Capital Partners'), TC_Comp_Only__c = true),
    new TC_Sale__c(TC_Property__c = prop.get('Riverside Flex Park'), TC_Sale_Date__c = Date.today().addYears(-5).addMonths(-1), TC_Sale_Price__c = 8900000, TC_Size__c = 60000, TC_Cap_Rate__c = 7.6, TC_Sale_Type__c = 'Owner-User', TC_Buyer__c = acct.get('Lone Star Property Holdings'), TC_Comp_Only__c = true)
};
Date eff = Date.today().toStartOfMonth().addMonths(-1);
insert new List<TC_Market_Rent__c>{
    new TC_Market_Rent__c(Name = 'Uptown Office Class A', TC_Market__c = 'Dallas-Fort Worth', TC_Submarket__c = 'Uptown', TC_Property_Type__c = 'Office', TC_Building_Class__c = 'A', TC_Rent_Type__c = 'Full Service', TC_Effective_Date__c = eff, TC_Low_Rate__c = 40, TC_High_Rate__c = 58, TC_Average_Rate__c = 46.5, TC_Vacancy_Rate__c = 17.8, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Preston Center Office Class B', TC_Market__c = 'Dallas-Fort Worth', TC_Submarket__c = 'Preston Center', TC_Property_Type__c = 'Office', TC_Building_Class__c = 'B', TC_Rent_Type__c = 'Full Service', TC_Effective_Date__c = eff, TC_Low_Rate__c = 25, TC_High_Rate__c = 33, TC_Average_Rate__c = 28.75, TC_Vacancy_Rate__c = 15.2, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Domain Office Class A', TC_Market__c = 'Austin', TC_Submarket__c = 'The Domain', TC_Property_Type__c = 'Office', TC_Building_Class__c = 'A', TC_Rent_Type__c = 'Full Service', TC_Effective_Date__c = eff, TC_Low_Rate__c = 42, TC_High_Rate__c = 55, TC_Average_Rate__c = 47.25, TC_Vacancy_Rate__c = 21.4, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Austin CBD Creative Office', TC_Market__c = 'Austin', TC_Submarket__c = 'CBD', TC_Property_Type__c = 'Office', TC_Building_Class__c = 'B', TC_Rent_Type__c = 'Modified Gross', TC_Effective_Date__c = eff, TC_Low_Rate__c = 30, TC_High_Rate__c = 40, TC_Average_Rate__c = 34.5, TC_Vacancy_Rate__c = 19.9, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Galleria Retail', TC_Market__c = 'Houston', TC_Submarket__c = 'Galleria', TC_Property_Type__c = 'Retail', TC_Building_Class__c = 'A', TC_Rent_Type__c = 'NNN', TC_Effective_Date__c = eff, TC_Low_Rate__c = 32, TC_High_Rate__c = 48, TC_Average_Rate__c = 38.5, TC_Vacancy_Rate__c = 5.1, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Energy Corridor Retail', TC_Market__c = 'Houston', TC_Submarket__c = 'Energy Corridor', TC_Property_Type__c = 'Retail', TC_Building_Class__c = 'B', TC_Rent_Type__c = 'NNN', TC_Effective_Date__c = eff, TC_Low_Rate__c = 19, TC_High_Rate__c = 28, TC_Average_Rate__c = 23.5, TC_Vacancy_Rate__c = 6.4, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Great Southwest Industrial', TC_Market__c = 'Dallas-Fort Worth', TC_Submarket__c = 'Great Southwest', TC_Property_Type__c = 'Industrial', TC_Building_Class__c = 'A', TC_Rent_Type__c = 'NNN', TC_Effective_Date__c = eff, TC_Low_Rate__c = 6.25, TC_High_Rate__c = 8.0, TC_Average_Rate__c = 7.1, TC_Vacancy_Rate__c = 9.3, TC_Source__c = 'TC research'),
    new TC_Market_Rent__c(Name = 'Houston Northwest Industrial', TC_Market__c = 'Houston', TC_Submarket__c = 'Northwest', TC_Property_Type__c = 'Industrial', TC_Building_Class__c = 'B', TC_Rent_Type__c = 'NNN', TC_Effective_Date__c = eff, TC_Low_Rate__c = 5.5, TC_High_Rate__c = 7.25, TC_Average_Rate__c = 6.4, TC_Vacancy_Rate__c = 7.0, TC_Source__c = 'TC research')
};

// ---------------------------------------------------------------- relationships (internal user roles)
Id me = UserInfo.getUserId();
insert new List<TC_Relationship__c>{
    new TC_Relationship__c(TC_User__c = me, TC_Relationship_Type__c = 'Listing Agent', TC_Property__c = prop.get('Uptown Commerce Tower'), TC_Start_Date__c = Date.today().addYears(-2)),
    new TC_Relationship__c(TC_User__c = me, TC_Relationship_Type__c = 'Listing Agent', TC_Property__c = prop.get('Domain Gateway'), TC_Start_Date__c = Date.today().addYears(-1)),
    new TC_Relationship__c(TC_User__c = me, TC_Relationship_Type__c = 'Account Manager', TC_Account__c = acct.get('Lone Star Property Holdings'), TC_Start_Date__c = Date.today().addYears(-3)),
    new TC_Relationship__c(TC_User__c = me, TC_Relationship_Type__c = 'Account Manager', TC_Account__c = acct.get('Gulf Coast Realty Trust'), TC_Start_Date__c = Date.today().addYears(-2)),
    new TC_Relationship__c(TC_User__c = me, TC_Relationship_Type__c = 'Transaction Coordinator', TC_Deal__c = refi.Id, TC_Start_Date__c = Date.today().addDays(-30))
};
System.debug('Step 4 done: ' + inqs.size() + ' inquiries, ' + matched + ' prospective listings, ' + sources.size() + ' capital sources, 3 term sheets, 5 sale comps, 8 market rents, 5 relationships.');
