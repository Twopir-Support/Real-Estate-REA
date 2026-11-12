/**
 * Inquiry logic:
 *  - Convert Inquiry: creates (or reuses) Account and Contact and creates a Deal, carrying the
 *    requirement and the primary prospective listing over (AscendixRE "Convert Inquiry")
 *  - Prospective Listings: changing the Inquiry's Listing adds it as the primary prospective
 *    listing; only one prospective listing per inquiry can be primary
 *  - Find Matches (TC extra): scores active listings against the requirement
 */
public inherited sharing class TC_InquiryService {

    public class ConvertResult {
        @AuraEnabled public Id accountId;
        @AuraEnabled public Id contactId;
        @AuraEnabled public Id dealId;
        @AuraEnabled public String warning;
    }

    // ---------------------------------------------------------------- triggers
    public static void applyDefaults(List<TC_Inquiry__c> inquiries) {
        Set<Id> contactIds = TC_TriggerHandler.idsOf(inquiries, 'TC_Contact__c');
        Map<Id, Contact> contacts = contactIds.isEmpty() ? new Map<Id, Contact>()
            : new Map<Id, Contact>([SELECT Id, AccountId, FirstName, LastName, Email, Phone FROM Contact WHERE Id IN :contactIds]);
        Set<Id> listingIds = TC_TriggerHandler.idsOf(inquiries, 'TC_Listing__c');
        Map<Id, TC_Listing__c> listings = listingIds.isEmpty() ? new Map<Id, TC_Listing__c>()
            : new Map<Id, TC_Listing__c>([SELECT Id, TC_Property__c FROM TC_Listing__c WHERE Id IN :listingIds]);
        for (TC_Inquiry__c i : inquiries) {
            Contact c = contacts.get(i.TC_Contact__c);
            if (c != null) {
                if (i.TC_Company__c == null) { i.TC_Company__c = c.AccountId; }
                if (String.isBlank(i.TC_Last_Name__c)) { i.TC_Last_Name__c = c.LastName; }
                if (String.isBlank(i.TC_First_Name__c)) { i.TC_First_Name__c = c.FirstName; }
                if (String.isBlank(i.TC_Email__c)) { i.TC_Email__c = c.Email; }
                if (String.isBlank(i.TC_Phone__c)) { i.TC_Phone__c = c.Phone; }
            }
            if (i.TC_Property__c == null && listings.containsKey(i.TC_Listing__c)) {
                i.TC_Property__c = listings.get(i.TC_Listing__c).TC_Property__c;
            }
        }
    }

    /** After insert/update: a changed Listing field becomes the primary prospective listing. */
    public static void syncListingToProspects(List<TC_Inquiry__c> inquiries, Map<Id, SObject> oldMap) {
        Map<Id, Id> inquiryToListing = new Map<Id, Id>();
        for (TC_Inquiry__c i : inquiries) {
            TC_Inquiry__c old = oldMap == null ? null : (TC_Inquiry__c) oldMap.get(i.Id);
            if (i.TC_Listing__c != null && (old == null || old.TC_Listing__c != i.TC_Listing__c)) {
                inquiryToListing.put(i.Id, i.TC_Listing__c);
            }
        }
        if (inquiryToListing.isEmpty()) {
            return;
        }
        Map<String, TC_Prospective_Listing__c> existing = new Map<String, TC_Prospective_Listing__c>();
        for (TC_Prospective_Listing__c pl : [SELECT Id, TC_Inquiry__c, TC_Listing__c, TC_Primary__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c IN :inquiryToListing.keySet()]) {
            existing.put(pl.TC_Inquiry__c + ':' + pl.TC_Listing__c, pl);
        }
        List<TC_Prospective_Listing__c> upserts = new List<TC_Prospective_Listing__c>();
        for (Id inqId : inquiryToListing.keySet()) {
            TC_Prospective_Listing__c pl = existing.get(inqId + ':' + inquiryToListing.get(inqId));
            if (pl == null) {
                upserts.add(new TC_Prospective_Listing__c(TC_Inquiry__c = inqId, TC_Listing__c = inquiryToListing.get(inqId), TC_Primary__c = true, TC_Status__c = 'New'));
            } else if (!pl.TC_Primary__c) {
                pl.TC_Primary__c = true;
                upserts.add(pl);
            }
        }
        upsert upserts;
    }

    /** After insert/update of prospective listings: keep a single primary per inquiry. */
    public static void enforceSinglePrimary(List<TC_Prospective_Listing__c> rows, Map<Id, SObject> oldMap) {
        Map<Id, Id> primaryByInquiry = new Map<Id, Id>();
        for (TC_Prospective_Listing__c r : rows) {
            TC_Prospective_Listing__c old = oldMap == null ? null : (TC_Prospective_Listing__c) oldMap.get(r.Id);
            if (r.TC_Primary__c && (old == null || !old.TC_Primary__c)) {
                primaryByInquiry.put(r.TC_Inquiry__c, r.Id);
            }
        }
        if (primaryByInquiry.isEmpty()) {
            return;
        }
        List<TC_Prospective_Listing__c> clear = new List<TC_Prospective_Listing__c>();
        for (TC_Prospective_Listing__c r : [SELECT Id, TC_Inquiry__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c IN :primaryByInquiry.keySet() AND TC_Primary__c = true AND Id NOT IN :primaryByInquiry.values()]) {
            clear.add(new TC_Prospective_Listing__c(Id = r.Id, TC_Primary__c = false));
        }
        if (!clear.isEmpty()) {
            update clear;
        }
    }

    // ---------------------------------------------------------------- convert
    public static ConvertResult convert(Id inquiryId, Id listingId, Boolean createDeal) {
        TC_Inquiry__c inq = [
            SELECT Id, Name, TC_Status__c, TC_Inquiry_Type__c, TC_Contact__c, TC_Company__c, TC_First_Name__c, TC_Last_Name__c,
                   TC_Email__c, TC_Phone__c, TC_Company_Name__c, TC_Listing__c, TC_Property__c, TC_Size_Min__c, TC_Size_Max__c,
                   TC_Price_Max__c, TC_Max_Rate__c, TC_Date_Needed__c, TC_Broker_Company__c, TC_Broker_Contact__c, OwnerId,
                   (SELECT TC_Listing__c FROM Prospective_Listings__r WHERE TC_Primary__c = true LIMIT 1)
            FROM TC_Inquiry__c WHERE Id = :inquiryId
        ];
        if (inq.TC_Status__c == 'Converted') {
            throw new TC_Exception('This inquiry has already been converted.');
        }
        ConvertResult res = new ConvertResult();
        Savepoint sp = Database.setSavepoint();
        try {
            Id accountId = inq.TC_Company__c;
            if (accountId == null) {
                String accName = String.isNotBlank(inq.TC_Company_Name__c) ? inq.TC_Company_Name__c
                    : ((inq.TC_First_Name__c == null ? '' : inq.TC_First_Name__c + ' ') + inq.TC_Last_Name__c);
                Account a = new Account(Name = accName.trim(), TC_CRE_Roles__c = inq.TC_Inquiry_Type__c == 'Sale' ? 'Buyer' : 'Tenant');
                insert a;
                accountId = a.Id;
            }
            Id contactId = inq.TC_Contact__c;
            if (contactId == null) {
                Contact c = new Contact(FirstName = inq.TC_First_Name__c, LastName = inq.TC_Last_Name__c, Email = inq.TC_Email__c,
                    Phone = inq.TC_Phone__c, AccountId = accountId, TC_Contact_Category__c = 'Prospect', TC_Relationship_Type__c = 'Prospect');
                insert c;
                contactId = c.Id;
            }
            res.accountId = accountId;
            res.contactId = contactId;

            Id dealListing = listingId;
            if (dealListing == null && !inq.Prospective_Listings__r.isEmpty()) {
                dealListing = inq.Prospective_Listings__r[0].TC_Listing__c;
            }
            if (dealListing == null) {
                dealListing = inq.TC_Listing__c;
            }
            if (createDeal != false) {
                Id propertyId = inq.TC_Property__c;
                if (dealListing != null) {
                    TC_Listing__c l = [SELECT Id, TC_Property__c FROM TC_Listing__c WHERE Id = :dealListing];
                    propertyId = l.TC_Property__c;
                    Integer others = [SELECT COUNT() FROM TC_Deal__c WHERE TC_Listing__c = :dealListing AND TC_Status__c = 'Open'];
                    if (others > 0) {
                        res.warning = 'The selected listing is already on ' + others + ' other open deal(s).';
                    }
                }
                String rt = inq.TC_Inquiry_Type__c == 'Sale' ? 'TC_Buyer_Representation' : 'TC_Tenant_Representation';
                Account acc = [SELECT Name FROM Account WHERE Id = :accountId];
                TC_Deal__c d = new TC_Deal__c(
                    Name = (acc.Name + ' - ' + inq.TC_Inquiry_Type__c + ' Requirement').left(120),
                    RecordTypeId = TC_Settings.recordTypeId(TC_Deal__c.SObjectType, rt),
                    TC_Client__c = accountId, TC_Client_Contact__c = contactId, TC_Inquiry__c = inq.Id,
                    TC_Listing__c = dealListing, TC_Property__c = propertyId, TC_Size__c = inq.TC_Size_Max__c != null ? inq.TC_Size_Max__c : inq.TC_Size_Min__c,
                    TC_Lease_Rate__c = inq.TC_Inquiry_Type__c == 'Lease' ? inq.TC_Max_Rate__c : null,
                    TC_Listing_Price__c = inq.TC_Inquiry_Type__c == 'Sale' ? inq.TC_Price_Max__c : null,
                    TC_Stage__c = 'Prospect', TC_Status__c = 'Open', TC_Source__c = 'Inquiry',
                    TC_Est_Close_Date__c = inq.TC_Date_Needed__c != null ? inq.TC_Date_Needed__c : Date.today().addDays(90)
                );
                insert d;
                res.dealId = d.Id;
            }
            update new TC_Inquiry__c(Id = inq.Id, TC_Status__c = 'Converted', TC_Contact__c = contactId, TC_Company__c = accountId,
                TC_Converted_Deal__c = res.dealId, TC_Converted_Date__c = Date.today());
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
        return res;
    }

    // ---------------------------------------------------------------- find matches (TC extra)
    public class Match {
        @AuraEnabled public Id listingId;
        @AuraEnabled public String listingName;
        @AuraEnabled public String propertyName;
        @AuraEnabled public String city;
        @AuraEnabled public Decimal availableSf;
        @AuraEnabled public Decimal askingRate;
        @AuraEnabled public Decimal askingPrice;
        @AuraEnabled public Integer score;
        @AuraEnabled public List<String> reasons = new List<String>();
    }

    /** Scores active listings against the inquiry requirement (0-100). */
    public static List<Match> scoreMatches(Id inquiryId, Integer maxResults) {
        TC_Inquiry__c inq = [SELECT Id, TC_Inquiry_Type__c, TC_Property_Type__c, TC_Size_Min__c, TC_Size_Max__c, TC_Max_Rate__c,
                                    TC_Price_Min__c, TC_Price_Max__c, TC_Preferred_City__c, TC_Preferred_Market__c
                             FROM TC_Inquiry__c WHERE Id = :inquiryId];
        List<Match> matches = new List<Match>();
        for (TC_Listing__c l : [
            SELECT Id, Name, RecordType.DeveloperName, TC_Property_Type__c, TC_Total_Available_SF__c, TC_Asking_Rate__c, TC_Asking_Price__c,
                   TC_Market__c, TC_Property__r.Name, TC_Property__r.TC_City__c, TC_Property__r.TC_Market__c, TC_Property__r.TC_Total_Size__c
            FROM TC_Listing__c WHERE TC_Status__c = 'Active' LIMIT 500
        ]) {
            Match m = new Match();
            m.listingId = l.Id;
            m.listingName = l.Name;
            m.propertyName = l.TC_Property__r.Name;
            m.city = l.TC_Property__r.TC_City__c;
            m.availableSf = l.TC_Total_Available_SF__c;
            m.askingRate = l.TC_Asking_Rate__c;
            m.askingPrice = l.TC_Asking_Price__c;
            Integer s = 0;
            String rt = l.RecordType.DeveloperName;
            Boolean typeFits = inq.TC_Inquiry_Type__c == 'Sale' ? (rt == 'TC_Sale' || rt == 'TC_Sale_or_Lease') : (rt == 'TC_Lease' || rt == 'TC_Sale_or_Lease');
            if (typeFits) { s += 10; m.reasons.add('Listing type fits a ' + inq.TC_Inquiry_Type__c + ' requirement'); }
            if (inq.TC_Property_Type__c != null && inq.TC_Property_Type__c == l.TC_Property_Type__c) { s += 30; m.reasons.add('Property type: ' + l.TC_Property_Type__c); }
            Decimal sf = inq.TC_Inquiry_Type__c == 'Sale' ? l.TC_Property__r.TC_Total_Size__c : l.TC_Total_Available_SF__c;
            if (sf != null && (inq.TC_Size_Min__c == null || sf >= inq.TC_Size_Min__c * 0.9) && (inq.TC_Size_Max__c == null || sf <= inq.TC_Size_Max__c * 1.25 || inq.TC_Inquiry_Type__c == 'Lease')) {
                if (inq.TC_Size_Min__c != null || inq.TC_Size_Max__c != null) { s += 25; m.reasons.add('Size fits (' + sf.setScale(0).format() + ' SF)'); }
            }
            if (inq.TC_Inquiry_Type__c == 'Lease' && inq.TC_Max_Rate__c != null && l.TC_Asking_Rate__c != null && l.TC_Asking_Rate__c <= inq.TC_Max_Rate__c) {
                s += 20; m.reasons.add('Asking rate within budget');
            }
            if (inq.TC_Inquiry_Type__c == 'Sale' && l.TC_Asking_Price__c != null
                    && (inq.TC_Price_Max__c == null || l.TC_Asking_Price__c <= inq.TC_Price_Max__c)
                    && (inq.TC_Price_Min__c == null || l.TC_Asking_Price__c >= inq.TC_Price_Min__c)) {
                s += 20; m.reasons.add('Asking price within range');
            }
            if ((inq.TC_Preferred_City__c != null && inq.TC_Preferred_City__c.equalsIgnoreCase(l.TC_Property__r.TC_City__c))
                    || (inq.TC_Preferred_Market__c != null && inq.TC_Preferred_Market__c.equalsIgnoreCase(l.TC_Property__r.TC_Market__c))) {
                s += 15; m.reasons.add('Preferred location');
            }
            m.score = s;
            if (s >= 40) {
                matches.add(m);
            }
        }
        // sort by score desc (simple insertion sort; lists are small)
        for (Integer i = 1; i < matches.size(); i++) {
            Match key = matches[i];
            Integer j = i - 1;
            while (j >= 0 && matches[j].score < key.score) {
                matches[j + 1] = matches[j];
                j--;
            }
            matches[j + 1] = key;
        }
        Integer cap = maxResults == null ? 10 : maxResults;
        while (matches.size() > cap) {
            matches.remove(matches.size() - 1);
        }
        return matches;
    }

    /** Saves the top matches as Prospective Listings (skipping listings already on the inquiry). */
    public static Integer saveMatches(Id inquiryId, List<Match> matches) {
        Set<Id> existing = TC_TriggerHandler.idsOf([SELECT TC_Listing__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :inquiryId], 'TC_Listing__c');
        List<TC_Prospective_Listing__c> rows = new List<TC_Prospective_Listing__c>();
        for (Match m : matches) {
            if (!existing.contains(m.listingId)) {
                rows.add(new TC_Prospective_Listing__c(TC_Inquiry__c = inquiryId, TC_Listing__c = m.listingId, TC_Status__c = 'New',
                    TC_Match_Score__c = m.score, TC_Description__c = String.join(m.reasons, '; ').left(255)));
            }
        }
        if (!rows.isEmpty()) {
            insert rows;
        }
        return rows.size();
    }
}
