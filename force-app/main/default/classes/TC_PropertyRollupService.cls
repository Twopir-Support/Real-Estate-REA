/**
 * Maintains Apex roll-ups that standard roll-up summaries cannot express (lookup relationships):
 *  Property: Leased SF (Active + Holdover leases), Available SF and Avg Asking Rate (Available
 *            availabilities), Active Listings
 *  Listing:  Total Available SF (linked Available availabilities)
 *  Account:  Portfolio SF (total size of properties it owns)
 *
 * Declared without sharing on purpose: an aggregate must count every child record, including
 * ones the running user cannot see, and only Apex-maintained read-only fields are written.
 */
public without sharing class TC_PropertyRollupService {

    public static void recalculateProperties(Set<Id> propertyIds) {
        propertyIds = clean(propertyIds);
        if (propertyIds.isEmpty()) {
            return;
        }
        Map<Id, TC_Property__c> props = new Map<Id, TC_Property__c>();
        for (Id pid : propertyIds) {
            props.put(pid, new TC_Property__c(Id = pid, TC_Leased_SF__c = 0, TC_Available_SF__c = 0, TC_Active_Listings__c = 0, TC_Avg_Asking_Rate__c = null));
        }
        for (AggregateResult ar : [SELECT TC_Property__c pid, SUM(TC_Size__c) sf FROM TC_Lease__c WHERE TC_Property__c IN :propertyIds AND TC_Status__c IN ('Active', 'Holdover') GROUP BY TC_Property__c]) {
            props.get((Id) ar.get('pid')).TC_Leased_SF__c = (Decimal) ar.get('sf');
        }
        for (AggregateResult ar : [SELECT TC_Property__c pid, SUM(TC_Size__c) sf, AVG(TC_Lease_Rate__c) rate FROM TC_Availability__c WHERE TC_Property__c IN :propertyIds AND TC_Status__c = 'Available' GROUP BY TC_Property__c]) {
            TC_Property__c p = props.get((Id) ar.get('pid'));
            p.TC_Available_SF__c = (Decimal) ar.get('sf');
            Decimal rate = (Decimal) ar.get('rate');
            p.TC_Avg_Asking_Rate__c = rate == null ? null : rate.setScale(2, RoundingMode.HALF_UP);
        }
        for (AggregateResult ar : [SELECT TC_Property__c pid, COUNT(Id) n FROM TC_Listing__c WHERE TC_Property__c IN :propertyIds AND TC_Status__c = 'Active' GROUP BY TC_Property__c]) {
            props.get((Id) ar.get('pid')).TC_Active_Listings__c = (Integer) ar.get('n');
        }
        TC_TriggerHandler.bypass('TC_PropertyHandler');
        try {
            update props.values();
        } finally {
            TC_TriggerHandler.clearBypass('TC_PropertyHandler');
        }
    }

    public static void recalculateListings(Set<Id> listingIds) {
        listingIds = clean(listingIds);
        if (listingIds.isEmpty()) {
            return;
        }
        Map<Id, TC_Listing__c> listings = new Map<Id, TC_Listing__c>();
        for (Id lid : listingIds) {
            listings.put(lid, new TC_Listing__c(Id = lid, TC_Total_Available_SF__c = 0));
        }
        for (AggregateResult ar : [SELECT TC_Listing__c lid, SUM(TC_Size__c) sf FROM TC_Availability__c WHERE TC_Listing__c IN :listingIds AND TC_Status__c = 'Available' GROUP BY TC_Listing__c]) {
            listings.get((Id) ar.get('lid')).TC_Total_Available_SF__c = (Decimal) ar.get('sf');
        }
        TC_TriggerHandler.bypass('TC_ListingHandler');
        try {
            update listings.values();
        } finally {
            TC_TriggerHandler.clearBypass('TC_ListingHandler');
        }
    }

    public static void recalculateAccounts(Set<Id> accountIds) {
        accountIds = clean(accountIds);
        if (accountIds.isEmpty()) {
            return;
        }
        Map<Id, Account> accts = new Map<Id, Account>();
        for (Id aid : accountIds) {
            accts.put(aid, new Account(Id = aid, TC_Portfolio_SF__c = 0));
        }
        for (AggregateResult ar : [SELECT TC_Owner_Landlord__c aid, SUM(TC_Total_Size__c) sf FROM TC_Property__c WHERE TC_Owner_Landlord__c IN :accountIds GROUP BY TC_Owner_Landlord__c]) {
            accts.get((Id) ar.get('aid')).TC_Portfolio_SF__c = (Decimal) ar.get('sf');
        }
        update accts.values();
    }

    private static Set<Id> clean(Set<Id> ids) {
        Set<Id> out = new Set<Id>();
        if (ids != null) {
            for (Id i : ids) {
                if (i != null) {
                    out.add(i);
                }
            }
        }
        return out;
    }
}
