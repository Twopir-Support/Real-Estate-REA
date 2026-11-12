// TC sample data, step 1 of 4: companies, people, properties and units.
// All companies and people are fictional. Sample companies carry Site = "[TC Sample]"; every other
// sample record hangs off them, so sample-data-cleanup.apex removes only this set.
// Run: sf apex run -o REA-Dev -f scripts/apex/sample-data-1-accounts-properties.apex

final String MARK = '[TC Sample]';
if ([SELECT COUNT() FROM Account WHERE Site = :MARK] > 0) {
    throw new TC_Exception('Sample data is already loaded. Run sample-data-cleanup.apex first to reload it.');
}

// ---------------------------------------------------------------- accounts
List<String[]> acctRows = new List<String[]>{
    // name, roles, industry, city
    new String[]{ 'Lone Star Property Holdings', 'Owner/Landlord', 'Real Estate', 'Dallas' },
    new String[]{ 'Bluebonnet Capital Partners', 'Owner/Landlord;Investor', 'Financial Services', 'Austin' },
    new String[]{ 'Gulf Coast Realty Trust', 'Owner/Landlord', 'Real Estate', 'Houston' },
    new String[]{ 'Prairie Logistics REIT', 'Owner/Landlord', 'Real Estate', 'Dallas' },
    new String[]{ 'Hill Country Retail Ventures', 'Owner/Landlord;Seller', 'Real Estate', 'Austin' },
    new String[]{ 'Brazos Development Group', 'Developer;Seller', 'Construction', 'Houston' },
    new String[]{ 'Northgate Software', 'Tenant', 'Technology', 'Dallas' },
    new String[]{ 'Meridian Health Partners', 'Tenant', 'Healthcare', 'Dallas' },
    new String[]{ 'Copperline Engineering', 'Tenant', 'Engineering', 'Austin' },
    new String[]{ 'Sable & Finch LLP', 'Tenant', 'Legal', 'Dallas' },
    new String[]{ 'Trailhead Outfitters', 'Tenant', 'Retail', 'Houston' },
    new String[]{ 'Juniper Coffee Roasters', 'Tenant', 'Food & Beverage', 'Austin' },
    new String[]{ 'Atlas Freight Systems', 'Tenant', 'Transportation', 'Dallas' },
    new String[]{ 'Redwood Analytics', 'Tenant', 'Technology', 'Austin' },
    new String[]{ 'Harbor Point Insurance', 'Tenant', 'Insurance', 'Houston' },
    new String[]{ 'Cobalt Fitness Clubs', 'Tenant', 'Recreation', 'Houston' },
    new String[]{ 'Pioneer Dental Group', 'Tenant', 'Healthcare', 'Austin' },
    new String[]{ 'Vantage Wealth Advisors', 'Tenant', 'Financial Services', 'Dallas' },
    new String[]{ 'Summit Learning Centers', 'Tenant', 'Education', 'Dallas' },
    new String[]{ 'Ironworks Manufacturing', 'Tenant', 'Manufacturing', 'Austin' },
    new String[]{ 'Prism Media Studio', 'Tenant', 'Media', 'Austin' },
    new String[]{ 'Keystone Staffing', 'Tenant', 'Professional Services', 'Houston' },
    new String[]{ 'Greenleaf Grocers', 'Tenant', 'Retail', 'Houston' },
    new String[]{ 'Orbit Electronics', 'Tenant', 'Retail', 'Austin' },
    new String[]{ 'Clearwater Labs', 'Tenant', 'Biotechnology', 'Austin' },
    new String[]{ 'Falcon Aerospace Parts', 'Tenant', 'Manufacturing', 'Dallas' },
    new String[]{ 'Westbrook Family Office', 'Buyer;Investor', 'Financial Services', 'Dallas' },
    new String[]{ 'Mesa Industrial Fund', 'Buyer;Investor', 'Financial Services', 'Houston' },
    new String[]{ 'First Lone Star Bank', 'Lender', 'Banking', 'Dallas' },
    new String[]{ 'Republic Life Insurance Co', 'Lender', 'Insurance', 'Houston' },
    new String[]{ 'Cypress Debt Fund', 'Lender', 'Financial Services', 'Austin' },
    new String[]{ 'Alamo Agency Lending', 'Lender', 'Financial Services', 'Dallas' },
    new String[]{ 'Crescent Brokerage Group', 'Brokerage Firm', 'Real Estate', 'Dallas' },
    new String[]{ 'Capitol Commercial Advisors', 'Brokerage Firm', 'Real Estate', 'Austin' },
    new String[]{ 'Bayou City Realty Partners', 'Brokerage Firm', 'Real Estate', 'Houston' }
};
List<Account> accounts = new List<Account>();
for (String[] r : acctRows) {
    accounts.add(new Account(Name = r[0], TC_CRE_Roles__c = r[1], Industry = r[2], BillingCity = r[3], BillingState = 'TX', BillingCountry = 'United States', Site = MARK, Description = 'TC sample data (fictional company). ' + MARK));
}
insert accounts;
Map<String, Id> acct = new Map<String, Id>();
for (Account a : accounts) { acct.put(a.Name, a.Id); }

// ---------------------------------------------------------------- contacts (two per company)
List<String> firsts = new List<String>{ 'Avery', 'Jordan', 'Morgan', 'Riley', 'Casey', 'Taylor', 'Jamie', 'Quinn', 'Rowan', 'Skyler', 'Elena', 'Marcus', 'Priya', 'Diego', 'Hannah', 'Owen', 'Leah', 'Samuel', 'Nadia', 'Victor' };
List<String> lasts = new List<String>{ 'Bennett', 'Okafor', 'Delgado', 'Nakamura', 'Holloway', 'Patel', 'Sinclair', 'Ramirez', 'Whitaker', 'Chen', 'Albright', 'Moreno', 'Kowalski', 'Fischer', 'Grant', 'Ibarra', 'Lindqvist', 'Mercer', 'Oduya', 'Thornton' };
List<String> titles = new List<String>{ 'Director of Real Estate', 'CFO', 'VP Facilities', 'Managing Partner', 'Asset Manager', 'Office Manager' };
List<Contact> contacts = new List<Contact>();
Integer n = 0;
for (Account a : accounts) {
    for (Integer k = 0; k < 2; k++) {
        String fn = firsts[Math.mod(n, firsts.size())];
        String ln = lasts[Math.mod(n * 7 + 3, lasts.size())];
        String roles = a.TC_CRE_Roles__c;
        String rel = roles.contains('Brokerage') ? 'Broker' : roles.contains('Lender') || roles.contains('Investor') ? 'Investor' : roles.contains('Tenant') ? 'Client' : 'Partner';
        contacts.add(new Contact(FirstName = fn, LastName = ln, AccountId = a.Id, Title = titles[Math.mod(n, titles.size())],
            Email = (fn + '.' + ln + n).toLowerCase() + '@example.com', Phone = '(555) 01' + String.valueOf(10 + Math.mod(n, 89)).leftPad(2, '0') + '-' + String.valueOf(1000 + n),
            TC_Relationship_Type__c = rel, TC_Contact_Category__c = rel == 'Broker' ? 'Broker' : 'Client', Description = MARK,
            TC_Automated_Follow_up_Tasks__c = Math.mod(n, 9) == 0, TC_Follow_up_Sequence__c = Math.mod(n, 9) == 0 ? '30-60-90 Days' : null));
        n++;
    }
}
insert contacts;

// ---------------------------------------------------------------- properties
Map<String, Id> rt = new Map<String, Id>();
for (Schema.RecordTypeInfo i : TC_Property__c.SObjectType.getDescribe().getRecordTypeInfos()) { rt.put(i.getDeveloperName(), i.getRecordTypeId()); }
List<TC_Property__c> props = new List<TC_Property__c>{
    new TC_Property__c(Name = 'Uptown Commerce Tower', RecordTypeId = rt.get('TC_Office'), TC_Property_Subtype__c = 'CBD', TC_Building_Class__c = 'A', TC_Building_Status__c = 'Existing',
        TC_Street__c = '2400 Cedar Springs Rd', TC_City__c = 'Dallas', TC_State__c = 'TX', TC_Postal_Code__c = '75201', TC_Country__c = 'United States', TC_Location__Latitude__s = 32.7990, TC_Location__Longitude__s = -96.8010,
        TC_Market__c = 'Dallas-Fort Worth', TC_Region__c = 'North Texas', TC_Submarket__c = 'Uptown', TC_Owner_Landlord__c = acct.get('Lone Star Property Holdings'), TC_Listing_Broker_Company__c = acct.get('Crescent Brokerage Group'),
        TC_Number_of_Floors__c = 18, TC_Average_Floor_Size__c = 22000, TC_Total_Size__c = 396000, TC_Year_Built__c = 2009, TC_Year_Renovated__c = 2021, TC_Parking_Spaces__c = 1200, TC_Zoning__c = 'PD-193',
        TC_Description__c = 'Class A tower in Uptown with structured parking, fitness centre and conference facility. ' + MARK, TC_Location_Description__c = 'Walkable to the Katy Trail and McKinney Avenue retail.'),
    new TC_Property__c(Name = 'Preston Center Plaza', RecordTypeId = rt.get('TC_Office'), TC_Property_Subtype__c = 'Suburban', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '8150 Westchester Dr', TC_City__c = 'Dallas', TC_State__c = 'TX', TC_Postal_Code__c = '75225', TC_Country__c = 'United States', TC_Location__Latitude__s = 32.8620, TC_Location__Longitude__s = -96.8040,
        TC_Market__c = 'Dallas-Fort Worth', TC_Region__c = 'North Texas', TC_Submarket__c = 'Preston Center', TC_Owner_Landlord__c = acct.get('Lone Star Property Holdings'),
        TC_Number_of_Floors__c = 6, TC_Average_Floor_Size__c = 15000, TC_Total_Size__c = 90000, TC_Year_Built__c = 1998, TC_Parking_Spaces__c = 320, TC_Description__c = 'Six-storey suburban office building near Preston Center. ' + MARK),
    new TC_Property__c(Name = 'Domain Gateway', RecordTypeId = rt.get('TC_Office'), TC_Property_Subtype__c = 'Suburban', TC_Building_Class__c = 'A', TC_Building_Status__c = 'Existing',
        TC_Street__c = '11600 Alterra Pkwy', TC_City__c = 'Austin', TC_State__c = 'TX', TC_Postal_Code__c = '78758', TC_Country__c = 'United States', TC_Location__Latitude__s = 30.4020, TC_Location__Longitude__s = -97.7250,
        TC_Market__c = 'Austin', TC_Region__c = 'Central Texas', TC_Submarket__c = 'The Domain', TC_Owner_Landlord__c = acct.get('Bluebonnet Capital Partners'), TC_Listing_Broker_Company__c = acct.get('Capitol Commercial Advisors'),
        TC_Number_of_Floors__c = 12, TC_Average_Floor_Size__c = 20000, TC_Total_Size__c = 240000, TC_Year_Built__c = 2017, TC_Parking_Spaces__c = 900, TC_Description__c = 'Twelve-storey office tower at The Domain, popular with technology tenants. ' + MARK),
    new TC_Property__c(Name = 'Congress Avenue Lofts', RecordTypeId = rt.get('TC_Office'), TC_Property_Subtype__c = 'Creative / Loft', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '710 Congress Ave', TC_City__c = 'Austin', TC_State__c = 'TX', TC_Postal_Code__c = '78701', TC_Country__c = 'United States', TC_Location__Latitude__s = 30.2690, TC_Location__Longitude__s = -97.7430,
        TC_Market__c = 'Austin', TC_Region__c = 'Central Texas', TC_Submarket__c = 'CBD', TC_Owner_Landlord__c = acct.get('Bluebonnet Capital Partners'),
        TC_Number_of_Floors__c = 5, TC_Average_Floor_Size__c = 9000, TC_Total_Size__c = 45000, TC_Year_Built__c = 1925, TC_Year_Renovated__c = 2015, TC_Description__c = 'Historic brick building converted to creative office lofts downtown. ' + MARK),
    new TC_Property__c(Name = 'Galleria West Center', RecordTypeId = rt.get('TC_Retail'), TC_Property_Subtype__c = 'Power Center', TC_Building_Class__c = 'A', TC_Building_Status__c = 'Existing',
        TC_Street__c = '5115 Westheimer Rd', TC_City__c = 'Houston', TC_State__c = 'TX', TC_Postal_Code__c = '77056', TC_Country__c = 'United States', TC_Location__Latitude__s = 29.7390, TC_Location__Longitude__s = -95.4630,
        TC_Market__c = 'Houston', TC_Region__c = 'Gulf Coast', TC_Submarket__c = 'Galleria', TC_Owner_Landlord__c = acct.get('Gulf Coast Realty Trust'), TC_Listing_Broker_Company__c = acct.get('Bayou City Realty Partners'),
        TC_Number_of_Floors__c = 1, TC_Average_Floor_Size__c = 120000, TC_Total_Size__c = 120000, TC_Year_Built__c = 2004, TC_Parking_Spaces__c = 650, TC_Description__c = 'Power centre across from the Galleria with national anchors. ' + MARK),
    new TC_Property__c(Name = 'Katy Freeway Marketplace', RecordTypeId = rt.get('TC_Retail'), TC_Property_Subtype__c = 'Strip Center', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '14520 Memorial Dr', TC_City__c = 'Houston', TC_State__c = 'TX', TC_Postal_Code__c = '77079', TC_Country__c = 'United States', TC_Location__Latitude__s = 29.7840, TC_Location__Longitude__s = -95.6220,
        TC_Market__c = 'Houston', TC_Region__c = 'Gulf Coast', TC_Submarket__c = 'Energy Corridor', TC_Owner_Landlord__c = acct.get('Gulf Coast Realty Trust'),
        TC_Number_of_Floors__c = 1, TC_Average_Floor_Size__c = 85000, TC_Total_Size__c = 85000, TC_Year_Built__c = 2001, TC_Description__c = 'Neighbourhood strip centre on the Energy Corridor. ' + MARK),
    new TC_Property__c(Name = 'Lakeline Square', RecordTypeId = rt.get('TC_Retail'), TC_Property_Subtype__c = 'Neighborhood Center', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '11200 Lakeline Mall Dr', TC_City__c = 'Cedar Park', TC_State__c = 'TX', TC_Postal_Code__c = '78613', TC_Country__c = 'United States', TC_Location__Latitude__s = 30.4790, TC_Location__Longitude__s = -97.7980,
        TC_Market__c = 'Austin', TC_Region__c = 'Central Texas', TC_Submarket__c = 'Cedar Park', TC_Owner_Landlord__c = acct.get('Hill Country Retail Ventures'),
        TC_Number_of_Floors__c = 2, TC_Average_Floor_Size__c = 30000, TC_Total_Size__c = 60000, TC_Year_Built__c = 2008, TC_Description__c = 'Two-level neighbourhood centre with grocery anchor. ' + MARK),
    new TC_Property__c(Name = 'DFW Logistics Park Building 2', RecordTypeId = rt.get('TC_Industrial'), TC_Property_Subtype__c = 'Warehouse / Distribution', TC_Building_Class__c = 'A', TC_Building_Status__c = 'Existing',
        TC_Street__c = '3300 Great Southwest Pkwy', TC_City__c = 'Grand Prairie', TC_State__c = 'TX', TC_Postal_Code__c = '75052', TC_Country__c = 'United States', TC_Location__Latitude__s = 32.7460, TC_Location__Longitude__s = -97.0050,
        TC_Market__c = 'Dallas-Fort Worth', TC_Region__c = 'North Texas', TC_Submarket__c = 'Great Southwest', TC_Owner_Landlord__c = acct.get('Prairie Logistics REIT'), TC_Listing_Broker_Company__c = acct.get('Crescent Brokerage Group'),
        TC_Number_of_Floors__c = 1, TC_Total_Size__c = 450000, TC_Land_Area_Acres__c = 28, TC_Year_Built__c = 2020, TC_Description__c = 'Cross-dock distribution building, 36 ft clear height, 92 dock doors. ' + MARK),
    new TC_Property__c(Name = 'Pinemont Distribution Center', RecordTypeId = rt.get('TC_Industrial'), TC_Property_Subtype__c = 'Warehouse / Distribution', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '6800 Pinemont Dr', TC_City__c = 'Houston', TC_State__c = 'TX', TC_Postal_Code__c = '77092', TC_Country__c = 'United States', TC_Location__Latitude__s = 29.8340, TC_Location__Longitude__s = -95.4630,
        TC_Market__c = 'Houston', TC_Region__c = 'Gulf Coast', TC_Submarket__c = 'Northwest', TC_Owner_Landlord__c = acct.get('Prairie Logistics REIT'),
        TC_Number_of_Floors__c = 1, TC_Total_Size__c = 220000, TC_Land_Area_Acres__c = 14, TC_Year_Built__c = 1996, TC_Description__c = 'Multi-tenant distribution centre near Loop 610. ' + MARK),
    new TC_Property__c(Name = 'Southpark Commerce Center', RecordTypeId = rt.get('TC_Industrial'), TC_Property_Subtype__c = 'Manufacturing', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '4500 E Ben White Blvd', TC_City__c = 'Austin', TC_State__c = 'TX', TC_Postal_Code__c = '78741', TC_Country__c = 'United States', TC_Location__Latitude__s = 30.2140, TC_Location__Longitude__s = -97.7200,
        TC_Market__c = 'Austin', TC_Region__c = 'Central Texas', TC_Submarket__c = 'Southeast', TC_Owner_Landlord__c = acct.get('Brazos Development Group'),
        TC_Number_of_Floors__c = 1, TC_Total_Size__c = 180000, TC_Land_Area_Acres__c = 12, TC_Year_Built__c = 2012, TC_Description__c = 'Light manufacturing building near the airport. ' + MARK),
    new TC_Property__c(Name = 'Riverside Flex Park', RecordTypeId = rt.get('TC_Industrial'), TC_Property_Subtype__c = 'Flex / R&D', TC_Building_Class__c = 'B', TC_Building_Status__c = 'Existing',
        TC_Street__c = '1400 Turtle Creek Blvd', TC_City__c = 'Dallas', TC_State__c = 'TX', TC_Postal_Code__c = '75207', TC_Country__c = 'United States', TC_Location__Latitude__s = 32.7920, TC_Location__Longitude__s = -96.8240,
        TC_Market__c = 'Dallas-Fort Worth', TC_Region__c = 'North Texas', TC_Submarket__c = 'Design District', TC_Owner_Landlord__c = acct.get('Lone Star Property Holdings'),
        TC_Number_of_Floors__c = 2, TC_Average_Floor_Size__c = 30000, TC_Total_Size__c = 60000, TC_Year_Built__c = 1985, TC_Year_Renovated__c = 2018, TC_Description__c = 'Two-storey flex buildings with showroom frontage. ' + MARK),
    new TC_Property__c(Name = 'Frisco Station Land', RecordTypeId = rt.get('TC_Land'), TC_Property_Subtype__c = 'Commercial Land', TC_Building_Status__c = 'Proposed',
        TC_Street__c = '6000 Warren Pkwy', TC_City__c = 'Frisco', TC_State__c = 'TX', TC_Postal_Code__c = '75034', TC_Country__c = 'United States', TC_Location__Latitude__s = 33.1110, TC_Location__Longitude__s = -96.8200,
        TC_Market__c = 'Dallas-Fort Worth', TC_Region__c = 'North Texas', TC_Submarket__c = 'Frisco', TC_Owner_Landlord__c = acct.get('Brazos Development Group'),
        TC_Land_Area_Acres__c = 25, TC_Zoning__c = 'Mixed Use', TC_Description__c = '25-acre mixed-use development site on the Dallas North Tollway. ' + MARK)
};
insert props;
Map<String, Id> prop = new Map<String, Id>();
for (TC_Property__c p : props) { prop.put(p.Name, p.Id); }

// ---------------------------------------------------------------- unit profiles
insert new List<TC_Unit_Profile__c>{
    new TC_Unit_Profile__c(Name = 'Standard Office Suite', TC_Unit_Type__c = 'Office', TC_Typical_Size__c = 5000, TC_Typical_Rate__c = 32, TC_Description__c = MARK),
    new TC_Unit_Profile__c(Name = 'Half-Floor Office', TC_Unit_Type__c = 'Office', TC_Typical_Size__c = 11000, TC_Typical_Rate__c = 38, TC_Description__c = MARK),
    new TC_Unit_Profile__c(Name = 'Inline Retail Shop', TC_Unit_Type__c = 'Retail', TC_Typical_Size__c = 2400, TC_Typical_Rate__c = 28, TC_Description__c = MARK)
};

// ---------------------------------------------------------------- units
// building name, floors, units per floor, unit size
List<Object[]> plan = new List<Object[]>{
    new Object[]{ 'Uptown Commerce Tower', 18, 2, 11000, 'Office' },
    new Object[]{ 'Domain Gateway', 12, 2, 10000, 'Office' },
    new Object[]{ 'Preston Center Plaza', 6, 3, 5000, 'Office' },
    new Object[]{ 'Congress Avenue Lofts', 5, 2, 4500, 'Office' },
    new Object[]{ 'Galleria West Center', 1, 10, 12000, 'Retail' },
    new Object[]{ 'Katy Freeway Marketplace', 1, 8, 10625, 'Retail' },
    new Object[]{ 'Lakeline Square', 2, 4, 7500, 'Retail' },
    new Object[]{ 'Riverside Flex Park', 2, 4, 7500, 'Flex' }
};
List<TC_Unit__c> units = new List<TC_Unit__c>();
for (Object[] b : plan) {
    Integer floors = (Integer) b[1];
    Integer per = (Integer) b[2];
    for (Integer f = 1; f <= floors; f++) {
        for (Integer u = 1; u <= per; u++) {
            String suite = ((String) b[4]) == 'Retail' ? 'Shop ' + (f == 1 ? '' : String.valueOf(f)) + String.valueOf(100 + u) : 'Suite ' + f + String.valueOf(u).leftPad(2, '0');
            units.add(new TC_Unit__c(Name = suite, TC_Property__c = prop.get((String) b[0]), TC_Floor__c = f, TC_Position__c = u,
                TC_Size__c = (Integer) b[3], TC_Unit_Type__c = (String) b[4], TC_Status__c = 'Vacant'));
        }
    }
}
insert units;
System.debug('Step 1 done: ' + accounts.size() + ' accounts, ' + contacts.size() + ' contacts, ' + props.size() + ' properties, ' + units.size() + ' units.');
