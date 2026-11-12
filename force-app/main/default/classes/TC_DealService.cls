/**
 * Deal business logic:
 *  - defaults: lead broker, probability by stage, client role and party auto-population
 *  - gross deal value and gross fee (Percent / Amount / By $ per SF)
 *  - Close Deal: on Won, create Lease (tenant/landlord rep), Sale (buyer/seller rep) or
 *    Listing (listing pursuit) through TC_Object_Field_Mapping__mdt, close the Availability,
 *    copy the rent table to the lease, and update commissions.
 */
public inherited sharing class TC_DealService {
    public static final Set<String> LEASE_TYPES = new Set<String>{ 'TC_Tenant_Representation', 'TC_Landlord_Representation', 'TC_Lease_Administration' };
    public static final Set<String> SALE_TYPES = new Set<String>{ 'TC_Seller_Representation', 'TC_Buyer_Representation', 'TC_Listing_Pursuit' };
    public static final Set<String> FINANCE_TYPES = new Set<String>{ 'TC_Capital_Markets', 'TC_Financing' };

    @TestVisible
    private static Boolean closing = false;

    public static String rtName(TC_Deal__c d) {
        return TC_Settings.recordTypeDevName(TC_Deal__c.SObjectType, d.RecordTypeId);
    }

    // ---------------------------------------------------------------- before insert / update
    public static void applyDefaults(List<TC_Deal__c> deals, Map<Id, SObject> oldMap) {
        for (TC_Deal__c d : deals) {
            TC_Deal__c old = oldMap == null ? null : (TC_Deal__c) oldMap.get(d.Id);
            if (d.TC_Lead_Broker__c == null) {
                d.TC_Lead_Broker__c = d.OwnerId != null && String.valueOf(d.OwnerId).startsWith('005') ? d.OwnerId : UserInfo.getUserId();
            }
            if (String.isBlank(d.TC_Status__c)) {
                d.TC_Status__c = 'Open';
            }
            // Probability follows the stage unless the user changed it in the same save.
            Boolean stageChanged = old == null || d.TC_Stage__c != old.TC_Stage__c;
            Boolean probChanged = old != null && d.TC_Probability__c != old.TC_Probability__c;
            if ((old == null && d.TC_Probability__c == null) || (stageChanged && !probChanged && old != null)) {
                Decimal p = TC_Settings.stageProbability(d.TC_Stage__c);
                if (p != null) {
                    d.TC_Probability__c = p;
                }
            }
            if (d.TC_Status__c == 'Won') {
                d.TC_Probability__c = 100;
                if (d.TC_Actual_Close_Date__c == null) {
                    d.TC_Actual_Close_Date__c = Date.today();
                }
                if (old == null || old.TC_Status__c != 'Won') {
                    d.TC_Stage__c = 'Executed';
                }
            } else if (d.TC_Status__c == 'Lost') {
                d.TC_Probability__c = 0;
                if (d.TC_Actual_Close_Date__c == null) {
                    d.TC_Actual_Close_Date__c = Date.today();
                }
            }
            if (old == null) {
                populateClientFields(d);
            }
        }
    }

    /** Client field auto-population (only blank fields are filled), as documented by AscendixRE. */
    @TestVisible
    private static void populateClientFields(TC_Deal__c d) {
        String rt = rtName(d);
        if (!TC_Settings.isActive('TC_AUTO_Client_Field_Population', rt)) {
            return;
        }
        String role;
        if (rt == 'TC_Tenant_Representation') {
            role = 'Tenant';
            if (d.TC_Tenant__c == null) { d.TC_Tenant__c = d.TC_Client__c; }
            if (d.TC_Tenant_Contact__c == null) { d.TC_Tenant_Contact__c = d.TC_Client_Contact__c; }
        } else if (rt == 'TC_Landlord_Representation' || rt == 'TC_Listing_Pursuit' || rt == 'TC_Property_Management') {
            role = 'Owner/Landlord';
            if (d.TC_Owner_Landlord__c == null) { d.TC_Owner_Landlord__c = d.TC_Client__c; }
            if (d.TC_Owner_Landlord_Contact__c == null) { d.TC_Owner_Landlord_Contact__c = d.TC_Client_Contact__c; }
        } else if (rt == 'TC_Seller_Representation') {
            role = 'Seller';
        } else if (rt == 'TC_Buyer_Representation') {
            role = 'Buyer';
            if (d.TC_Buyer__c == null) { d.TC_Buyer__c = d.TC_Client__c; }
            if (d.TC_Buyer_Contact__c == null) { d.TC_Buyer_Contact__c = d.TC_Client_Contact__c; }
        } else if (FINANCE_TYPES.contains(rt)) {
            role = 'Borrower';
        }
        if (role != null) {
            if (String.isBlank(d.TC_Client_Role__c)) { d.TC_Client_Role__c = role; }
            if (String.isBlank(d.TC_Client_Contact_Role__c) && d.TC_Client_Contact__c != null) { d.TC_Client_Contact_Role__c = role; }
        }
    }

    /** Gross deal value and gross fee amount. Needs rent-table totals for lease deals. */
    public static void calculateFees(List<TC_Deal__c> deals) {
        Map<Id, Decimal> periodTotals = new Map<Id, Decimal>();
        Set<Id> ids = new Set<Id>();
        for (TC_Deal__c d : deals) {
            if (d.Id != null) {
                ids.add(d.Id);
            }
        }
        if (!ids.isEmpty()) {
            for (AggregateResult ar : [SELECT TC_Deal__c dealId, SUM(TC_Total_Rent__c) total FROM TC_Deal_Period__c WHERE TC_Deal__c IN :ids GROUP BY TC_Deal__c]) {
                periodTotals.put((Id) ar.get('dealId'), (Decimal) ar.get('total'));
            }
        }
        for (TC_Deal__c d : deals) {
            String rt = rtName(d);
            Decimal value;
            if (LEASE_TYPES.contains(rt) || rt == null && d.TC_Lease_Rate__c != null) {
                if (periodTotals.containsKey(d.Id)) {
                    value = periodTotals.get(d.Id);
                } else if (d.TC_Lease_Commencement__c != null && d.TC_Lease_Expiration__c != null && d.TC_Size__c != null && d.TC_Lease_Rate__c != null) {
                    TC_RentTableService.Terms t = new TC_RentTableService.Terms();
                    t.commencement = d.TC_Lease_Commencement__c;
                    t.expiration = d.TC_Lease_Expiration__c;
                    t.size = d.TC_Size__c;
                    t.rate = d.TC_Lease_Rate__c;
                    t.escalationPct = d.TC_Escalation__c;
                    t.periodMonths = d.TC_Period_Length_Months__c == null ? null : d.TC_Period_Length_Months__c.intValue();
                    t.freeMonths = d.TC_Free_Rent_Months__c == null ? null : d.TC_Free_Rent_Months__c.intValue();
                    value = TC_RentTableService.estimateTotal(t, d.TC_Total_Rent_Calculation__c);
                }
            } else if (SALE_TYPES.contains(rt)) {
                value = d.TC_Sale_Price__c != null ? d.TC_Sale_Price__c : d.TC_Listing_Price__c;
            } else if (FINANCE_TYPES.contains(rt)) {
                value = d.TC_Loan_Amount__c;
            } else {
                value = d.TC_Actual_Value__c;
            }
            d.TC_Gross_Deal_Value__c = value;

            if (d.TC_Gross_Fee_Method__c == 'By $ per SF') {
                d.TC_Gross_Fee_Amount__c = (d.TC_Size__c != null && d.TC_Gross_Fee_Rate_per_UOM__c != null)
                    ? (d.TC_Size__c * d.TC_Gross_Fee_Rate_per_UOM__c).setScale(2, RoundingMode.HALF_UP) : null;
            } else if (d.TC_Gross_Fee_Method__c == 'Percent' || String.isBlank(d.TC_Gross_Fee_Method__c)) {
                d.TC_Gross_Fee_Amount__c = (value != null && d.TC_Gross_Fee_Percent__c != null)
                    ? (value * d.TC_Gross_Fee_Percent__c / 100).setScale(2, RoundingMode.HALF_UP) : null;
            }
            if (d.TC_Status__c == 'Won' && d.TC_Actual_Value__c == null) {
                d.TC_Actual_Value__c = value;
            }
        }
    }

    /** Optional rule (off by default): a Won deal needs inside broker splits totalling 100%. */
    public static void validateInsideBrokerSplit(List<TC_Deal__c> deals, Map<Id, SObject> oldMap) {
        List<TC_Deal__c> won = new List<TC_Deal__c>();
        for (TC_Deal__c d : deals) {
            TC_Deal__c old = (TC_Deal__c) oldMap.get(d.Id);
            if (d.TC_Status__c == 'Won' && old.TC_Status__c != 'Won' && TC_Settings.isActive('TC_VAL_Inside_Broker_100', rtName(d))) {
                won.add(d);
            }
        }
        if (won.isEmpty()) {
            return;
        }
        Id insideRt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, 'TC_Inside_Broker');
        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        Map<Id, TC_Deal__c> wonMap = new Map<Id, TC_Deal__c>(won);
        for (TC_Commission__c c : [SELECT TC_Deal__c, TC_Fee_Percent__c FROM TC_Commission__c WHERE TC_Deal__c IN :wonMap.keySet() AND RecordTypeId = :insideRt]) {
            Decimal cur = totals.containsKey(c.TC_Deal__c) ? totals.get(c.TC_Deal__c) : 0;
            totals.put(c.TC_Deal__c, cur + (c.TC_Fee_Percent__c == null ? 0 : c.TC_Fee_Percent__c));
        }
        for (TC_Deal__c d : won) {
            if (!totals.containsKey(d.Id)) {
                d.addError('Add at least one Inside Broker commission before closing this deal as Won.');
            } else if (totals.get(d.Id) != 100) {
                d.addError('Inside Broker fee percents must total 100% before closing this deal as Won (currently ' + totals.get(d.Id).setScale(2) + '%).');
            }
        }
    }

    // ---------------------------------------------------------------- after update: close deal
    public static void processClosedDeals(List<TC_Deal__c> deals, Map<Id, SObject> oldMap) {
        List<TC_Deal__c> newlyWon = new List<TC_Deal__c>();
        Set<Id> statusChanged = new Set<Id>();
        for (TC_Deal__c d : deals) {
            TC_Deal__c old = oldMap == null ? null : (TC_Deal__c) oldMap.get(d.Id);
            if (old == null || d.TC_Status__c != old.TC_Status__c) {
                statusChanged.add(d.Id);
            }
            if (d.TC_Status__c == 'Won' && (old == null || old.TC_Status__c != 'Won')) {
                newlyWon.add(d);
            }
        }
        if (!newlyWon.isEmpty() && !closing && TC_Settings.isActive('TC_AUTO_Close_Deal_Create_Records')) {
            closing = true;
            try {
                createCloseRecords(newlyWon);
            } finally {
                closing = false;
            }
        }
        if (!statusChanged.isEmpty()) {
            TC_CommissionService.applyDealStatus(statusChanged);
        }
    }

    private static void createCloseRecords(List<TC_Deal__c> wonDeals) {
        Set<String> fields = new Set<String>{ 'Id', 'RecordTypeId', 'Name', 'TC_Space__c', 'TC_Deal_Sub_Type__c', 'TC_Property__c', 'TC_Tenant__c', 'TC_Lease_Commencement__c', 'TC_Lease_Expiration__c', 'TC_Size__c', 'TC_Sale_Price__c' };
        for (String g : new List<String>{ 'DEAL_TO_LEASE', 'DEAL_TO_SALE', 'DEAL_TO_LISTING' }) {
            fields.addAll(TC_FieldMappingService.sourceFields(g));
        }
        Set<Id> ids = new Map<Id, TC_Deal__c>(wonDeals).keySet();
        List<TC_Deal__c> deals = Database.query('SELECT ' + String.join(new List<String>(fields), ',') + ' FROM TC_Deal__c WHERE Id IN :ids');

        // Do not create a second lease/sale/listing if one already points to the deal.
        Set<Id> hasLease = TC_TriggerHandler.idsOf([SELECT TC_Deal__c FROM TC_Lease__c WHERE TC_Deal__c IN :ids], 'TC_Deal__c');
        Set<Id> hasSale = TC_TriggerHandler.idsOf([SELECT TC_Deal__c FROM TC_Sale__c WHERE TC_Deal__c IN :ids], 'TC_Deal__c');
        Set<Id> hasListing = TC_TriggerHandler.idsOf([SELECT TC_Deal__c FROM TC_Listing__c WHERE TC_Deal__c IN :ids], 'TC_Deal__c');

        List<TC_Lease__c> leases = new List<TC_Lease__c>();
        List<TC_Sale__c> sales = new List<TC_Sale__c>();
        List<TC_Listing__c> listings = new List<TC_Listing__c>();
        Map<Id, TC_Availability__c> spaces = new Map<Id, TC_Availability__c>();
        for (TC_Deal__c d : deals) {
            String rt = rtName(d);
            if (d.TC_Property__c != null && !hasLease.contains(d.Id) && TC_FieldMappingService.groupApplies('DEAL_TO_LEASE', rt) && d.TC_Tenant__c != null
                    && d.TC_Lease_Commencement__c != null && d.TC_Lease_Expiration__c != null && d.TC_Size__c != null) {
                leases.add((TC_Lease__c) TC_FieldMappingService.apply('DEAL_TO_LEASE', d, new TC_Lease__c(), rt, false));
            }
            if (d.TC_Property__c != null && !hasSale.contains(d.Id) && TC_FieldMappingService.groupApplies('DEAL_TO_SALE', rt) && d.TC_Sale_Price__c != null) {
                sales.add((TC_Sale__c) TC_FieldMappingService.apply('DEAL_TO_SALE', d, new TC_Sale__c(), rt, false));
            }
            if (d.TC_Property__c != null && !hasListing.contains(d.Id) && TC_FieldMappingService.groupApplies('DEAL_TO_LISTING', rt)) {
                TC_Listing__c l = (TC_Listing__c) TC_FieldMappingService.apply('DEAL_TO_LISTING', d, new TC_Listing__c(), rt, false);
                l.Name = (d.Name + ' Listing').left(80);
                l.RecordTypeId = TC_Settings.recordTypeId(TC_Listing__c.SObjectType, listingRecordType(d.TC_Deal_Sub_Type__c));
                l.TC_Exclusive__c = d.TC_Deal_Sub_Type__c != null && d.TC_Deal_Sub_Type__c.contains('- Exclusive');
                l.TC_Sublease__c = d.TC_Deal_Sub_Type__c == 'Sublease';
                listings.add(l);
            }
            if (d.TC_Space__c != null) {
                spaces.put(d.TC_Space__c, (TC_Availability__c) TC_FieldMappingService.apply('DEAL_TO_AVAILABILITY', d, new TC_Availability__c(Id = d.TC_Space__c), rt, false));
            }
        }
        Map<Id, Id> dealToLease = new Map<Id, Id>();
        if (!leases.isEmpty()) {
            TC_LeaseService.suppressRentTableGeneration = true;
            try {
                insert leases;
            } finally {
                TC_LeaseService.suppressRentTableGeneration = false;
            }
            for (TC_Lease__c l : leases) {
                dealToLease.put(l.TC_Deal__c, l.Id);
            }
            if (TC_Settings.isActive('TC_AUTO_Lease_Rent_Table_From_Deal')) {
                TC_RentTableService.copyDealPeriodsToLeases(dealToLease);
            }
            // Leases whose deal had no rent table get one generated from their terms.
            Set<Id> withoutPeriods = new Set<Id>(dealToLease.values());
            withoutPeriods.removeAll(TC_TriggerHandler.idsOf([SELECT TC_Lease__c FROM TC_Lease_Period__c WHERE TC_Lease__c IN :dealToLease.values()], 'TC_Lease__c'));
            if (!withoutPeriods.isEmpty() && TC_Settings.isActive('TC_AUTO_Generate_Rent_Table')) {
                TC_RentTableService.generateForLeases(withoutPeriods, false);
            }
        }
        if (!sales.isEmpty()) {
            insert sales;
        }
        if (!listings.isEmpty()) {
            insert listings;
        }
        if (!spaces.isEmpty()) {
            update spaces.values();
        }
    }

    /** Listing Pursuit Deal Sub Type -> Listing record type (documented AscendixRE mapping). */
    @TestVisible
    private static String listingRecordType(String subType) {
        if (subType == null) {
            return 'TC_Lease';
        }
        if (subType == 'Sale or Lease') {
            return 'TC_Sale_or_Lease';
        }
        if (subType.startsWith('Sale')) {
            return 'TC_Sale';
        }
        return 'TC_Lease';
    }

    /** Re-run fee calculation for deals whose rent table changed. */
    public static void recalculateFromPeriods(Set<Id> dealIds) {
        if (dealIds == null || dealIds.isEmpty()) {
            return;
        }
        List<TC_Deal__c> deals = [
            SELECT Id, RecordTypeId, TC_Status__c, TC_Size__c, TC_Lease_Rate__c, TC_Lease_Commencement__c, TC_Lease_Expiration__c,
                   TC_Escalation__c, TC_Period_Length_Months__c, TC_Free_Rent_Months__c, TC_Total_Rent_Calculation__c,
                   TC_Sale_Price__c, TC_Listing_Price__c, TC_Loan_Amount__c, TC_Actual_Value__c, TC_Gross_Fee_Method__c,
                   TC_Gross_Fee_Percent__c, TC_Gross_Fee_Rate_per_UOM__c, TC_Gross_Fee_Amount__c, TC_Gross_Deal_Value__c
            FROM TC_Deal__c WHERE Id IN :dealIds
        ];
        Map<Id, Decimal> before = new Map<Id, Decimal>();
        for (TC_Deal__c d : deals) {
            before.put(d.Id, d.TC_Gross_Deal_Value__c);
        }
        calculateFees(deals);
        List<TC_Deal__c> changed = new List<TC_Deal__c>();
        for (TC_Deal__c d : deals) {
            if (d.TC_Gross_Deal_Value__c != before.get(d.Id)) {
                changed.add(d);
            }
        }
        if (!changed.isEmpty()) {
            update changed;
        }
    }
}
