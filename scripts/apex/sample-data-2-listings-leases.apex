// TC sample data, step 2 of 4: listings, available spaces and leases (with generated rent tables).
// Run after step 1:  sf apex run -o REA-Dev -f scripts/apex/sample-data-2-listings-leases.apex

final String MARK = '[TC Sample]';
Map<String, Id> prop = new Map<String, Id>();
for (TC_Property__c p : [SELECT Id, Name FROM TC_Property__c WHERE TC_Owner_Landlord__r.Site = :MARK]) { prop.put(p.Name, p.Id); }
if (prop.isEmpty()) { throw new TC_Exception('Run step 1 first.'); }
if ([SELECT COUNT() FROM TC_Lease__c WHERE TC_Property__c IN :prop.values()] > 0) { throw new TC_Exception('Step 2 has already run.'); }

Map<String, Id> acct = new Map<String, Id>();
List<Id> tenants = new List<Id>();
for (Account a : [SELECT Id, Name, TC_CRE_Roles__c FROM Account WHERE Site = :MARK ORDER BY Name]) {
    acct.put(a.Name, a.Id);
    if (a.TC_CRE_Roles__c == 'Tenant') { tenants.add(a.Id); }
}
Map<Id, Id> firstContact = new Map<Id, Id>();
for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Account.Site = :MARK ORDER BY Name]) {
    if (!firstContact.containsKey(c.AccountId)) { firstContact.put(c.AccountId, c.Id); }
}
Id me = UserInfo.getUserId();
Map<String, Id> lrt = new Map<String, Id>();
for (Schema.RecordTypeInfo i : TC_Listing__c.SObjectType.getDescribe().getRecordTypeInfos()) { lrt.put(i.getDeveloperName(), i.getRecordTypeId()); }

// ---------------------------------------------------------------- listings
// property, type, asking rate, asking price, rent type, broker company
List<Object[]> lrows = new List<Object[]>{
    new Object[]{ 'Uptown Commerce Tower', 'TC_Lease', 44.50, null, 'Full Service', 'Crescent Brokerage Group' },
    new Object[]{ 'Domain Gateway', 'TC_Lease', 47.00, null, 'Full Service', 'Capitol Commercial Advisors' },
    new Object[]{ 'Preston Center Plaza', 'TC_Lease', 29.00, null, 'Full Service', 'Crescent Brokerage Group' },
    new Object[]{ 'Galleria West Center', 'TC_Lease', 39.00, null, 'NNN', 'Bayou City Realty Partners' },
    new Object[]{ 'Lakeline Square', 'TC_Lease', 27.00, null, 'NNN', 'Capitol Commercial Advisors' },
    new Object[]{ 'DFW Logistics Park Building 2', 'TC_Lease', 7.25, null, 'NNN', 'Crescent Brokerage Group' },
    new Object[]{ 'Pinemont Distribution Center', 'TC_Sale_or_Lease', 6.50, 24000000, 'NNN', 'Bayou City Realty Partners' },
    new Object[]{ 'Southpark Commerce Center', 'TC_Sale', null, 27500000, null, 'Capitol Commercial Advisors' },
    new Object[]{ 'Frisco Station Land', 'TC_Sale', null, 18000000, null, 'Crescent Brokerage Group' }
};
List<TC_Listing__c> listings = new List<TC_Listing__c>();
Integer li = 0;
for (Object[] r : lrows) {
    Id brokerCo = acct.get((String) r[5]);
    listings.add(new TC_Listing__c(Name = ((String) r[0]) + (((String) r[1]) == 'TC_Sale' ? ' - For Sale' : ((String) r[1]) == 'TC_Sale_or_Lease' ? ' - Sale or Lease' : ' - For Lease'),
        TC_Property__c = prop.get((String) r[0]), RecordTypeId = lrt.get((String) r[1]), TC_Status__c = 'Active', TC_Exclusive__c = true,
        TC_Asking_Rate__c = (Decimal) r[2], TC_Asking_Price__c = (Decimal) r[3], TC_Rent_Type__c = (String) r[4],
        TC_Listing_Broker_Company__c = brokerCo, TC_Listing_Broker_Contact__c = firstContact.get(brokerCo), TC_Listing_Broker__c = me,
        TC_Listing_Date__c = Date.today().addDays(-30 - li * 17), TC_Expiration_Date__c = Date.today().addDays(60 + li * 41)));
    li++;
}
insert listings;
Map<Id, TC_Listing__c> listingByProp = new Map<Id, TC_Listing__c>();
for (TC_Listing__c l : listings) { listingByProp.put(l.TC_Property__c, l); }

// ---------------------------------------------------------------- leases on units (about 3 of every 4 units)
Map<String, Decimal> rateByProp = new Map<String, Decimal>{
    'Uptown Commerce Tower' => 41, 'Domain Gateway' => 44, 'Preston Center Plaza' => 27, 'Congress Avenue Lofts' => 33,
    'Galleria West Center' => 36, 'Katy Freeway Marketplace' => 23, 'Lakeline Square' => 25, 'Riverside Flex Park' => 15.5 };
Map<String, String> typeByProp = new Map<String, String>{
    'Uptown Commerce Tower' => 'Full Service', 'Domain Gateway' => 'Full Service', 'Preston Center Plaza' => 'Full Service', 'Congress Avenue Lofts' => 'Modified Gross',
    'Galleria West Center' => 'NNN', 'Katy Freeway Marketplace' => 'NNN', 'Lakeline Square' => 'NNN', 'Riverside Flex Park' => 'Modified Gross' };
List<Integer> terms = new List<Integer>{ 60, 84, 120, 36, 60, 72 };
List<TC_Lease__c> leases = new List<TC_Lease__c>();
List<TC_Availability__c> spaces = new List<TC_Availability__c>();
Integer i = 0;
for (TC_Unit__c u : [SELECT Id, Name, TC_Floor__c, TC_Size__c, TC_Property__c, TC_Property__r.Name FROM TC_Unit__c WHERE TC_Property__c IN :prop.values() ORDER BY TC_Property__r.Name, TC_Floor__c, TC_Position__c]) {
    String pname = u.TC_Property__r.Name;
    Decimal rate = rateByProp.get(pname);
    if (Math.mod(i, 4) == 3) {
        // vacant: market it when the building has a listing
        TC_Listing__c l = listingByProp.get(u.TC_Property__c);
        spaces.add(new TC_Availability__c(TC_Property__c = u.TC_Property__c, TC_Unit__c = u.Id, TC_Listing__c = l == null ? null : l.Id,
            TC_Availability_Type__c = Math.mod(i, 13) == 0 ? 'Sublease' : 'Direct', TC_Status__c = l == null ? 'Off Market' : 'Available',
            TC_Size__c = u.TC_Size__c, TC_Min_Divisible__c = Math.round(u.TC_Size__c / 2), TC_Lease_Rate__c = rate + 1.5, TC_Rent_Type__c = typeByProp.get(pname) == 'Modified Gross' ? 'Modified Gross' : typeByProp.get(pname),
            TC_Date_Available__c = Date.today().addDays(Math.mod(i * 11, 90) - 30), TC_Min_Term_Months__c = 36,
            TC_Space_Use__c = pname.contains('Flex') ? 'Flex' : (rate > 30 || pname.contains('Plaza') || pname.contains('Lofts') ? 'Office' : 'Retail')));
    } else {
        Integer term = terms[Math.mod(i, terms.size())];
        Date comm = Date.today().addMonths(-(Math.mod(i * 7, 52) + 2)).toStartOfMonth();
        // a handful of leases expire within the next 18 months, to drive renewals and reminders
        if (Math.mod(i, 9) == 0) { term = comm.monthsBetween(Date.today().addMonths(Math.mod(i, 4) * 6 + 5)); }
        if (term < 12) { term = 12; }
        Id tenant = tenants[Math.mod(i * 5 + 3, tenants.size())];
        leases.add(new TC_Lease__c(Name = '-', TC_Property__c = u.TC_Property__c, TC_Unit__c = u.Id, TC_Tenant__c = tenant, TC_Tenant_Contact__c = firstContact.get(tenant),
            TC_Lease_Type__c = typeByProp.get(pname), TC_Rent_Type__c = typeByProp.get(pname) == 'Modified Gross' ? 'Modified Gross' : typeByProp.get(pname), TC_Status__c = 'Active',
            TC_Size__c = u.TC_Size__c, TC_Lease_Rate__c = rate - Math.mod(i, 3), TC_Escalation__c = 3, TC_Free_Rent_Months__c = Math.mod(i, 5) == 0 ? 3 : 0,
            TC_TI_Allowance__c = rate > 30 ? 45 : 15, TC_Security_Deposit__c = (u.TC_Size__c * rate / 12).setScale(0),
            TC_Commencement_Date__c = comm, TC_Expiration_Date__c = comm.addMonths(term).addDays(-1),
            TC_Renewal_Option__c = Math.mod(i, 2) == 0, TC_Option_Notice_Date__c = Math.mod(i, 2) == 0 ? comm.addMonths(term).addMonths(-9) : null));
    }
    i++;
}
// industrial leases without units
List<Object[]> ind = new List<Object[]>{
    new Object[]{ 'DFW Logistics Park Building 2', 'Atlas Freight Systems', 210000, 6.95, 120, -20 },
    new Object[]{ 'DFW Logistics Park Building 2', 'Falcon Aerospace Parts', 120000, 7.10, 84, -8 },
    new Object[]{ 'Pinemont Distribution Center', 'Greenleaf Grocers', 95000, 6.10, 60, -30 },
    new Object[]{ 'Pinemont Distribution Center', 'Keystone Staffing', 30000, 6.60, 36, -26 },
    new Object[]{ 'Pinemont Distribution Center', 'Orbit Electronics', 50000, 6.40, 60, -14 },
    new Object[]{ 'Southpark Commerce Center', 'Ironworks Manufacturing', 120000, 8.25, 120, -40 },
    new Object[]{ 'Southpark Commerce Center', 'Clearwater Labs', 60000, 12.50, 84, -10 }
};
for (Object[] r : ind) {
    Date comm = Date.today().addMonths((Integer) r[5]).toStartOfMonth();
    Id tenant = acct.get((String) r[1]);
    leases.add(new TC_Lease__c(Name = '-', TC_Property__c = prop.get((String) r[0]), TC_Tenant__c = tenant, TC_Tenant_Contact__c = firstContact.get(tenant),
        TC_Lease_Type__c = 'NNN', TC_Rent_Type__c = 'NNN', TC_Status__c = 'Active', TC_Size__c = (Integer) r[2], TC_Lease_Rate__c = (Decimal) r[3], TC_Escalation__c = 3.5,
        TC_Commencement_Date__c = comm, TC_Expiration_Date__c = comm.addMonths((Integer) r[4]).addDays(-1), TC_Unit_Type__c = 'Warehouse', TC_TI_Allowance__c = 5));
}
// industrial and land availabilities
spaces.add(new TC_Availability__c(TC_Property__c = prop.get('DFW Logistics Park Building 2'), TC_Listing__c = listingByProp.get(prop.get('DFW Logistics Park Building 2')).Id, TC_Unit_Name__c = 'Bays 41-60',
    TC_Availability_Type__c = 'Direct', TC_Status__c = 'Available', TC_Size__c = 120000, TC_Min_Divisible__c = 40000, TC_Lease_Rate__c = 7.25, TC_Rent_Type__c = 'NNN', TC_Date_Available__c = Date.today(), TC_Space_Use__c = 'Industrial'));
spaces.add(new TC_Availability__c(TC_Property__c = prop.get('Pinemont Distribution Center'), TC_Listing__c = listingByProp.get(prop.get('Pinemont Distribution Center')).Id, TC_Unit_Name__c = 'Building C',
    TC_Availability_Type__c = 'Direct', TC_Status__c = 'Available', TC_Size__c = 45000, TC_Lease_Rate__c = 6.50, TC_Rent_Type__c = 'NNN', TC_Date_Available__c = Date.today().addDays(45), TC_Space_Use__c = 'Industrial'));
spaces.add(new TC_Availability__c(TC_Property__c = prop.get('Southpark Commerce Center'), TC_Listing__c = listingByProp.get(prop.get('Southpark Commerce Center')).Id, TC_Unit_Name__c = 'Entire building',
    TC_Availability_Type__c = 'For Sale', TC_Status__c = 'Available', TC_Size__c = 180000, TC_Asking_Price__c = 27500000, TC_Space_Use__c = 'Industrial'));
spaces.add(new TC_Availability__c(TC_Property__c = prop.get('Frisco Station Land'), TC_Listing__c = listingByProp.get(prop.get('Frisco Station Land')).Id, TC_Unit_Name__c = 'Tract A (25 acres)',
    TC_Availability_Type__c = 'For Sale', TC_Status__c = 'Available', TC_Size__c = 1089000, TC_Asking_Price__c = 18000000, TC_Space_Use__c = 'Land'));

insert spaces;
insert leases;
System.debug('Step 2 done: ' + listings.size() + ' listings, ' + spaces.size() + ' availabilities, ' + leases.size() + ' leases, '
    + [SELECT COUNT() FROM TC_Lease_Period__c WHERE TC_Lease__r.TC_Property__c IN :prop.values()] + ' rent periods.');
