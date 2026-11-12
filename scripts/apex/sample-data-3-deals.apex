// TC sample data, step 3 of 4: deals across business lines and stages, rent tables, commissions,
// prospective buyers, offers, and a few deals closed Won (creating leases, a sale and a listing) or Lost.
// Run after step 2:  sf apex run -o REA-Dev -f scripts/apex/sample-data-3-deals.apex

final String MARK = '[TC Sample]';
Map<String, Id> acct = new Map<String, Id>();
for (Account a : [SELECT Id, Name FROM Account WHERE Site = :MARK]) { acct.put(a.Name, a.Id); }
if (acct.isEmpty()) { throw new TC_Exception('Run steps 1 and 2 first.'); }
if ([SELECT COUNT() FROM TC_Deal__c WHERE TC_Client__c IN :acct.values()] > 0) { throw new TC_Exception('Step 3 has already run.'); }
Map<String, Id> prop = new Map<String, Id>();
for (TC_Property__c p : [SELECT Id, Name FROM TC_Property__c WHERE TC_Owner_Landlord__r.Site = :MARK]) { prop.put(p.Name, p.Id); }
Map<Id, Id> firstContact = new Map<Id, Id>();
for (Contact c : [SELECT Id, AccountId FROM Contact WHERE Account.Site = :MARK ORDER BY Name]) {
    if (!firstContact.containsKey(c.AccountId)) { firstContact.put(c.AccountId, c.Id); }
}
Map<Id, Id> spaceByProp = new Map<Id, Id>();
for (TC_Availability__c a : [SELECT Id, TC_Property__c FROM TC_Availability__c WHERE TC_Property__c IN :prop.values() AND TC_Status__c = 'Available' ORDER BY Name]) {
    if (!spaceByProp.containsKey(a.TC_Property__c)) { spaceByProp.put(a.TC_Property__c, a.Id); }
}
Map<Id, Id> listingByProp = new Map<Id, Id>();
for (TC_Listing__c l : [SELECT Id, TC_Property__c FROM TC_Listing__c WHERE TC_Property__c IN :prop.values()]) { listingByProp.put(l.TC_Property__c, l.Id); }
Map<String, Id> rt = new Map<String, Id>();
for (Schema.RecordTypeInfo i : TC_Deal__c.SObjectType.getDescribe().getRecordTypeInfos()) { rt.put(i.getDeveloperName(), i.getRecordTypeId()); }

TC_Deal__c leaseDeal(String name, String type, String client, String property, String stage, Integer sf, Decimal rate, Integer startMonths, Integer termMonths, Decimal feePct) {
    Date comm = Date.today().addMonths(startMonths).toStartOfMonth();
    Id c = acct.get(client);
    Id p = prop.get(property);
    return new TC_Deal__c(Name = name, RecordTypeId = rt.get(type), TC_Client__c = c, TC_Client_Contact__c = firstContact.get(c), TC_Property__c = p,
        TC_Space__c = spaceByProp.get(p), TC_Listing__c = listingByProp.get(p), TC_Stage__c = stage, TC_Status__c = 'Open', TC_Size__c = sf, TC_Lease_Rate__c = rate,
        TC_Rent_Type__c = 'Full Service', TC_Escalation__c = 3, TC_Lease_Commencement__c = comm, TC_Lease_Expiration__c = comm.addMonths(termMonths).addDays(-1),
        TC_Period_Length_Months__c = 12, TC_Total_Rent_Calculation__c = 'Annual Ratio Rent', TC_Gross_Fee_Method__c = 'Percent', TC_Gross_Fee_Percent__c = feePct,
        TC_Est_Close_Date__c = Date.today().addDays(30 + Math.abs(startMonths) * 10), TC_Source__c = 'Existing Client', TC_Lead_Broker_Role__c = 'Lead', TC_Deal_Sub_Type__c = 'New Lease');
}
TC_Deal__c saleDeal(String name, String type, String client, String property, String stage, Decimal price, Decimal feePct, String subType) {
    Id c = acct.get(client);
    Id p = prop.get(property);
    return new TC_Deal__c(Name = name, RecordTypeId = rt.get(type), TC_Client__c = c, TC_Client_Contact__c = firstContact.get(c), TC_Property__c = p,
        TC_Listing__c = listingByProp.get(p), TC_Stage__c = stage, TC_Status__c = 'Open', TC_Sale_Price__c = price, TC_Listing_Price__c = price == null ? null : price * 1.05,
        TC_Gross_Fee_Method__c = 'Percent', TC_Gross_Fee_Percent__c = feePct, TC_Est_Close_Date__c = Date.today().addDays(75), TC_Source__c = 'Referral',
        TC_Lead_Broker_Role__c = 'Lead', TC_Deal_Sub_Type__c = subType);
}

List<TC_Deal__c> deals = new List<TC_Deal__c>{
    leaseDeal('Northgate Software - Uptown Expansion', 'TC_Tenant_Representation', 'Northgate Software', 'Uptown Commerce Tower', 'Negotiation', 22000, 43.50, 3, 84, 4),
    leaseDeal('Redwood Analytics - Domain HQ', 'TC_Tenant_Representation', 'Redwood Analytics', 'Domain Gateway', 'LOI', 20000, 46.00, 4, 120, 4),
    leaseDeal('Meridian Health - Preston Clinic', 'TC_Tenant_Representation', 'Meridian Health Partners', 'Preston Center Plaza', 'Touring', 10000, 28.50, 6, 60, 4),
    leaseDeal('Prism Media - Congress Lofts', 'TC_Tenant_Representation', 'Prism Media Studio', 'Congress Avenue Lofts', 'Pitch / Proposal', 9000, 34.00, 5, 60, 4),
    leaseDeal('Copperline Engineering - Domain Relocation', 'TC_Tenant_Representation', 'Copperline Engineering', 'Domain Gateway', 'Lease / PSA Out', 10000, 45.00, 2, 84, 4),
    leaseDeal('Sable & Finch - Uptown Renewal', 'TC_Tenant_Representation', 'Sable & Finch LLP', 'Uptown Commerce Tower', 'Lease / PSA Out', 11000, 42.00, 1, 60, 3.5),
    leaseDeal('Uptown Tower - Floor 17 Leasing', 'TC_Landlord_Representation', 'Lone Star Property Holdings', 'Uptown Commerce Tower', 'Prospect', 11000, 44.50, 6, 84, 5),
    leaseDeal('Galleria West - Inline Shops', 'TC_Landlord_Representation', 'Gulf Coast Realty Trust', 'Galleria West Center', 'Touring', 12000, 39.00, 4, 120, 5),
    leaseDeal('Lakeline Square - Pad Site', 'TC_Landlord_Representation', 'Hill Country Retail Ventures', 'Lakeline Square', 'Negotiation', 7500, 27.00, 3, 120, 5),
    leaseDeal('Cobalt Fitness - Katy Freeway', 'TC_Tenant_Representation', 'Cobalt Fitness Clubs', 'Katy Freeway Marketplace', 'LOI', 21250, 22.00, 4, 120, 4),
    leaseDeal('Atlas Freight - DFW Bays 41-60', 'TC_Tenant_Representation', 'Atlas Freight Systems', 'DFW Logistics Park Building 2', 'Touring', 120000, 7.25, 3, 84, 4),
    leaseDeal('Juniper Coffee - Congress Ground Floor', 'TC_Tenant_Representation', 'Juniper Coffee Roasters', 'Congress Avenue Lofts', 'Prospect', 4500, 36.00, 6, 60, 4),
    saleDeal('Pinemont Distribution - Disposition', 'TC_Seller_Representation', 'Prairie Logistics REIT', 'Pinemont Distribution Center', 'Negotiation', 23500000, 2.5, 'Disposition'),
    saleDeal('Southpark Commerce - Sale', 'TC_Seller_Representation', 'Brazos Development Group', 'Southpark Commerce Center', 'Lease / PSA Out', 26800000, 2.5, 'Disposition'),
    saleDeal('Westbrook - Frisco Land Acquisition', 'TC_Buyer_Representation', 'Westbrook Family Office', 'Frisco Station Land', 'LOI', 17250000, 3, 'Acquisition'),
    saleDeal('Mesa Industrial - Southpark Purchase', 'TC_Buyer_Representation', 'Mesa Industrial Fund', 'Southpark Commerce Center', 'Touring', 26800000, 2, 'Acquisition'),
    saleDeal('Riverside Flex Park - Listing Pitch', 'TC_Listing_Pursuit', 'Lone Star Property Holdings', 'Riverside Flex Park', 'Pitch / Proposal', null, 3, 'Sale or Lease'),
    saleDeal('Katy Freeway Marketplace - Listing Pitch', 'TC_Listing_Pursuit', 'Gulf Coast Realty Trust', 'Katy Freeway Marketplace', 'Prospect', null, 5, 'Lease Listing - Exclusive'),
    new TC_Deal__c(Name = 'Uptown Commerce Tower - Refinance', RecordTypeId = rt.get('TC_Capital_Markets'), TC_Client__c = acct.get('Lone Star Property Holdings'),
        TC_Client_Contact__c = firstContact.get(acct.get('Lone Star Property Holdings')), TC_Property__c = prop.get('Uptown Commerce Tower'), TC_Stage__c = 'Negotiation', TC_Status__c = 'Open',
        TC_Loan_Amount__c = 95000000, TC_Gross_Fee_Method__c = 'Percent', TC_Gross_Fee_Percent__c = 0.75, TC_Est_Close_Date__c = Date.today().addDays(60), TC_Deal_Sub_Type__c = 'Refinance'),
    new TC_Deal__c(Name = 'Bluebonnet - Portfolio Strategy', RecordTypeId = rt.get('TC_Consulting'), TC_Client__c = acct.get('Bluebonnet Capital Partners'), TC_Stage__c = 'Pitch / Proposal',
        TC_Status__c = 'Open', TC_Actual_Value__c = 85000, TC_Gross_Fee_Method__c = 'Amount', TC_Gross_Fee_Amount__c = 85000, TC_Est_Close_Date__c = Date.today().addDays(45))
};
// Deals that will be closed below
TC_Deal__c wonA = leaseDeal('Vantage Wealth - Preston Center Lease', 'TC_Tenant_Representation', 'Vantage Wealth Advisors', 'Preston Center Plaza', 'Lease / PSA Out', 5000, 27.50, 1, 60, 4);
wonA.TC_Space__c = null;
TC_Deal__c wonB = leaseDeal('Summit Learning - Domain Lease', 'TC_Tenant_Representation', 'Summit Learning Centers', 'Domain Gateway', 'Lease / PSA Out', 10000, 44.00, 1, 84, 4);
wonB.TC_Space__c = null;
TC_Deal__c wonSale = saleDeal('Galleria West Pad - Sale', 'TC_Seller_Representation', 'Gulf Coast Realty Trust', 'Galleria West Center', 'Lease / PSA Out', 6400000, 3, 'Disposition');
TC_Deal__c wonPursuit = saleDeal('Pinemont - Lease Listing Pitch', 'TC_Listing_Pursuit', 'Prairie Logistics REIT', 'Pinemont Distribution Center', 'Negotiation', null, 4, 'Lease Listing - Non Exclusive');
TC_Deal__c lostA = leaseDeal('Harbor Point Insurance - Galleria Office', 'TC_Tenant_Representation', 'Harbor Point Insurance', 'Galleria West Center', 'LOI', 8000, 35.00, 3, 60, 4);
lostA.TC_Space__c = null;
TC_Deal__c lostB = saleDeal('Westbrook - Lakeline Acquisition', 'TC_Buyer_Representation', 'Westbrook Family Office', 'Lakeline Square', 'Touring', 14500000, 2, 'Acquisition');
deals.addAll(new List<TC_Deal__c>{ wonA, wonB, wonSale, wonPursuit, lostA, lostB });
insert deals;

// Rent tables on every lease deal (drives Gross Deal Value)
Set<Id> leaseDealIds = new Set<Id>();
for (TC_Deal__c d : deals) { if (d.TC_Lease_Rate__c != null && d.TC_Lease_Commencement__c != null) { leaseDealIds.add(d.Id); } }
TC_RentTableService.generateForDeals(leaseDealIds, true);

// Commissions: inside broker on every deal; co-brokers on some; an expense on one
Id insideRt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, 'TC_Inside_Broker');
Id coRt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, 'TC_Co_Broker');
Id expRt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, 'TC_Expense');
List<String> coBrokers = new List<String>{ 'Crescent Brokerage Group', 'Capitol Commercial Advisors', 'Bayou City Realty Partners' };
List<TC_Commission__c> coms = new List<TC_Commission__c>();
Integer k = 0;
for (TC_Deal__c d : deals) {
    coms.add(new TC_Commission__c(TC_Deal__c = d.Id, RecordTypeId = insideRt, TC_Broker__c = UserInfo.getUserId(), TC_Fee_Method__c = 'Percent', TC_Fee_Percent__c = 100,
        TC_House_Fee_Percent__c = 30, TC_Due_Date__c = d.TC_Est_Close_Date__c == null ? null : d.TC_Est_Close_Date__c.addDays(30), TC_Description__c = 'Lead broker'));
    if (Math.mod(k, 3) == 0 && d.TC_Gross_Fee_Method__c == 'Percent') {
        Id brokerCo = acct.get(coBrokers[Math.mod(k, 3 * coBrokers.size()) / 3]);
        coms.add(new TC_Commission__c(TC_Deal__c = d.Id, RecordTypeId = coRt, TC_Account__c = brokerCo, TC_Contact__c = firstContact.get(brokerCo),
            TC_Fee_Method__c = 'Percent', TC_Fee_Percent__c = 50, TC_Description__c = 'Cooperating broker'));
    }
    if (k == 1) {
        coms.add(new TC_Commission__c(TC_Deal__c = d.Id, RecordTypeId = expRt, TC_Fee_Method__c = 'Amount', TC_Fee_Amount__c = 2500, TC_Description__c = 'Marketing and tour expenses'));
    }
    k++;
}
insert coms;

// Prospective buyers and offers on the seller rep deals
List<TC_Prospective_Buyer__c> buyers = new List<TC_Prospective_Buyer__c>();
for (TC_Deal__c d : deals) {
    if (d.RecordTypeId == rt.get('TC_Seller_Representation')) {
        buyers.add(new TC_Prospective_Buyer__c(TC_Deal__c = d.Id, TC_Account__c = acct.get('Westbrook Family Office'), TC_Contact__c = firstContact.get(acct.get('Westbrook Family Office')), TC_Status__c = 'Offer Submitted', TC_Primary__c = true));
        buyers.add(new TC_Prospective_Buyer__c(TC_Deal__c = d.Id, TC_Account__c = acct.get('Mesa Industrial Fund'), TC_Contact__c = firstContact.get(acct.get('Mesa Industrial Fund')), TC_Status__c = 'Toured'));
    }
}
insert buyers;
List<TC_Offer__c> offers = new List<TC_Offer__c>();
for (TC_Prospective_Buyer__c b : buyers) {
    if (b.TC_Primary__c) {
        TC_Deal__c d = new Map<Id, TC_Deal__c>(deals).get(b.TC_Deal__c);
        offers.add(new TC_Offer__c(TC_Deal__c = b.TC_Deal__c, TC_Prospective_Buyer__c = b.Id, TC_Account__c = b.TC_Account__c, TC_Offer_Date__c = Date.today().addDays(-12),
            TC_Offer_Amount__c = d.TC_Sale_Price__c * 0.96, TC_Status__c = 'Countered', TC_Terms__c = '60-day due diligence, 30-day close, 3% earnest money.'));
        offers.add(new TC_Offer__c(TC_Deal__c = b.TC_Deal__c, TC_Prospective_Buyer__c = b.Id, TC_Account__c = b.TC_Account__c, TC_Offer_Date__c = Date.today().addDays(-4),
            TC_Offer_Amount__c = d.TC_Sale_Price__c, TC_Status__c = 'Accepted', TC_Terms__c = '45-day due diligence, 30-day close.'));
    }
}
insert offers;

// Close deals: Won creates a lease (tenant rep), a sale (seller rep) and a listing (listing pursuit)
wonA.TC_Status__c = 'Won';  wonA.TC_Actual_Close_Date__c = Date.today().addDays(-40);
wonB.TC_Status__c = 'Won';  wonB.TC_Actual_Close_Date__c = Date.today().addDays(-12);
wonSale.TC_Status__c = 'Won'; wonSale.TC_Actual_Close_Date__c = Date.today().addDays(-25);
wonPursuit.TC_Status__c = 'Won'; wonPursuit.TC_Actual_Close_Date__c = Date.today().addDays(-6);
lostA.TC_Status__c = 'Lost'; lostA.TC_Lost_Reason__c = 'Lost to Competitor';
lostB.TC_Status__c = 'Lost'; lostB.TC_Lost_Reason__c = 'Pricing';
update new List<TC_Deal__c>{ wonA, wonB, wonSale, wonPursuit, lostA, lostB };

System.debug('Step 3 done: ' + deals.size() + ' deals, ' + coms.size() + ' commissions, ' + buyers.size() + ' prospective buyers, ' + offers.size() + ' offers; created on close: '
    + [SELECT COUNT() FROM TC_Lease__c WHERE TC_Deal__c IN :deals] + ' lease(s), ' + [SELECT COUNT() FROM TC_Sale__c WHERE TC_Deal__c IN :deals] + ' sale(s), '
    + [SELECT COUNT() FROM TC_Listing__c WHERE TC_Deal__c IN :deals] + ' listing(s).');
