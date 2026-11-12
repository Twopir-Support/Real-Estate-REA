/**
 * Trigger handlers for every TC object. Each trigger is one line: new TC_RecordHandlers.X().run();
 * Handlers only route to services; business logic lives in the TC_*Service classes.
 */
public inherited sharing class TC_RecordHandlers {

    // ------------------------------------------------------------ Property
    public class TC_PropertyHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { defaultType((List<TC_Property__c>) newList); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { defaultType((List<TC_Property__c>) newList); }
        protected override void afterInsert(List<SObject> newList) { TC_PropertyRollupService.recalculateAccounts(TC_TriggerHandler.idsOf(newList, 'TC_Owner_Landlord__c')); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Id> accts = new Set<Id>();
            for (SObject r : newList) {
                if (changed(r, oldMap, new List<String>{ 'TC_Owner_Landlord__c', 'TC_Total_Size__c' })) {
                    accts.add((Id) r.get('TC_Owner_Landlord__c'));
                    accts.add((Id) oldMap.get(r.Id).get('TC_Owner_Landlord__c'));
                }
            }
            TC_PropertyRollupService.recalculateAccounts(accts);
        }
        protected override void afterDelete(List<SObject> oldList) { TC_PropertyRollupService.recalculateAccounts(TC_TriggerHandler.idsOf(oldList, 'TC_Owner_Landlord__c')); }
        private void defaultType(List<TC_Property__c> props) {
            for (TC_Property__c p : props) {
                if (p.TC_Property_Type__c == null && p.RecordTypeId != null) {
                    Schema.RecordTypeInfo info = TC_Property__c.SObjectType.getDescribe().getRecordTypeInfosById().get(p.RecordTypeId);
                    if (info != null && !info.isMaster()) {
                        p.TC_Property_Type__c = info.getName();
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------ Availability
    public class TC_AvailabilityHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { defaults((List<TC_Availability__c>) newList); TC_NamingService.apply(newList, TC_Availability__c.SObjectType); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { defaults((List<TC_Availability__c>) newList); TC_NamingService.apply(newList, TC_Availability__c.SObjectType); }
        protected override void afterInsert(List<SObject> newList) { rollup(newList, null); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { rollup(newList, oldMap); }
        protected override void afterDelete(List<SObject> oldList) { rollup(oldList, null); }
        protected override void afterUndelete(List<SObject> newList) { rollup(newList, null); }
        private void defaults(List<TC_Availability__c> rows) {
            Set<Id> unitIds = TC_TriggerHandler.idsOf(rows, 'TC_Unit__c');
            if (unitIds.isEmpty()) {
                return;
            }
            Map<Id, TC_Unit__c> units = new Map<Id, TC_Unit__c>([SELECT Id, Name, TC_Floor__c, TC_Size__c FROM TC_Unit__c WHERE Id IN :unitIds]);
            for (TC_Availability__c a : rows) {
                TC_Unit__c u = units.get(a.TC_Unit__c);
                if (u == null) { continue; }
                if (String.isBlank(a.TC_Unit_Name__c)) { a.TC_Unit_Name__c = u.Name; }
                if (a.TC_Floor__c == null) { a.TC_Floor__c = u.TC_Floor__c; }
                if (a.TC_Size__c == null) { a.TC_Size__c = u.TC_Size__c; }
            }
        }
        private void rollup(List<SObject> rows, Map<Id, SObject> oldMap) {
            Set<Id> props = TC_TriggerHandler.idsOf(rows, 'TC_Property__c');
            Set<Id> listings = TC_TriggerHandler.idsOf(rows, 'TC_Listing__c');
            if (oldMap != null) {
                props.addAll(TC_TriggerHandler.idsOf(oldMap.values(), 'TC_Property__c'));
                listings.addAll(TC_TriggerHandler.idsOf(oldMap.values(), 'TC_Listing__c'));
            }
            TC_PropertyRollupService.recalculateProperties(props);
            TC_PropertyRollupService.recalculateListings(listings);
        }
    }

    // ------------------------------------------------------------ Listing
    public class TC_ListingHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) {
            prefillFromProperty((List<TC_Listing__c>) newList);
            TC_NamingService.apply(newList, TC_Listing__c.SObjectType);
        }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_NamingService.apply(newList, TC_Listing__c.SObjectType); }
        protected override void afterInsert(List<SObject> newList) { TC_PropertyRollupService.recalculateProperties(TC_TriggerHandler.idsOf(newList, 'TC_Property__c')); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Id> props = new Set<Id>();
            for (SObject r : newList) {
                if (changed(r, oldMap, new List<String>{ 'TC_Status__c', 'TC_Property__c' })) {
                    props.add((Id) r.get('TC_Property__c'));
                    props.add((Id) oldMap.get(r.Id).get('TC_Property__c'));
                }
            }
            TC_PropertyRollupService.recalculateProperties(props);
        }
        protected override void afterDelete(List<SObject> oldList) { TC_PropertyRollupService.recalculateProperties(TC_TriggerHandler.idsOf(oldList, 'TC_Property__c')); }
        /** AscendixRE behaviour: Property fields pre-populate a new Listing (create only, blank fields only). */
        private void prefillFromProperty(List<TC_Listing__c> listings) {
            Set<Id> propIds = TC_TriggerHandler.idsOf(listings, 'TC_Property__c');
            if (propIds.isEmpty()) {
                return;
            }
            Set<String> fields = TC_FieldMappingService.sourceFields('PROPERTY_TO_LISTING');
            fields.add('Id');
            Map<Id, SObject> props = new Map<Id, SObject>(Database.query('SELECT ' + String.join(new List<String>(fields), ',') + ' FROM TC_Property__c WHERE Id IN :propIds'));
            for (TC_Listing__c l : listings) {
                SObject p = props.get(l.TC_Property__c);
                if (p != null) {
                    TC_FieldMappingService.apply('PROPERTY_TO_LISTING', p, l, null, true);
                }
            }
        }
    }

    // ------------------------------------------------------------ Lease
    public class TC_LeaseHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) {
            TC_LeaseService.applyDefaults((List<TC_Lease__c>) newList);
            TC_LeaseService.preventOverlaps((List<TC_Lease__c>) newList);
            TC_NamingService.apply(newList, TC_Lease__c.SObjectType);
        }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            TC_LeaseService.applyDefaults((List<TC_Lease__c>) newList);
            TC_LeaseService.preventOverlaps((List<TC_Lease__c>) newList);
            TC_NamingService.apply(newList, TC_Lease__c.SObjectType);
        }
        protected override void afterInsert(List<SObject> newList) {
            TC_LeaseService.generateRentTables((List<TC_Lease__c>) newList);
            sync(newList, null);
        }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { sync(newList, oldMap); }
        protected override void afterDelete(List<SObject> oldList) { sync(oldList, null); }
        protected override void afterUndelete(List<SObject> newList) { sync(newList, null); }
        private void sync(List<SObject> rows, Map<Id, SObject> oldMap) {
            Set<Id> units = TC_TriggerHandler.idsOf(rows, 'TC_Unit__c');
            Set<Id> props = TC_TriggerHandler.idsOf(rows, 'TC_Property__c');
            if (oldMap != null) {
                units.addAll(TC_TriggerHandler.idsOf(oldMap.values(), 'TC_Unit__c'));
                props.addAll(TC_TriggerHandler.idsOf(oldMap.values(), 'TC_Property__c'));
            }
            TC_LeaseService.syncUnits(units);
            TC_PropertyRollupService.recalculateProperties(props);
        }
    }

    // ------------------------------------------------------------ Lease / Deal periods
    public class TC_LeasePeriodHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { TC_RentTableService.calculate(newList, 'TC_Lease__c'); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_RentTableService.calculate(newList, 'TC_Lease__c'); }
    }

    public class TC_DealPeriodHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { TC_RentTableService.calculate(newList, 'TC_Deal__c'); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_RentTableService.calculate(newList, 'TC_Deal__c'); }
        protected override void afterInsert(List<SObject> newList) { TC_DealService.recalculateFromPeriods(TC_TriggerHandler.idsOf(newList, 'TC_Deal__c')); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_DealService.recalculateFromPeriods(TC_TriggerHandler.idsOf(newList, 'TC_Deal__c')); }
        protected override void afterDelete(List<SObject> oldList) { TC_DealService.recalculateFromPeriods(TC_TriggerHandler.idsOf(oldList, 'TC_Deal__c')); }
    }

    // ------------------------------------------------------------ Deal
    public class TC_DealHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) {
            TC_DealService.applyDefaults((List<TC_Deal__c>) newList, null);
            TC_DealService.calculateFees((List<TC_Deal__c>) newList);
        }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            TC_DealService.applyDefaults((List<TC_Deal__c>) newList, oldMap);
            TC_DealService.calculateFees((List<TC_Deal__c>) newList);
            TC_DealService.validateInsideBrokerSplit((List<TC_Deal__c>) newList, oldMap);
        }
        protected override void afterInsert(List<SObject> newList) { TC_DealService.processClosedDeals((List<TC_Deal__c>) newList, null); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Id> feeChanged = new Set<Id>();
            for (SObject r : newList) {
                if (changed(r, oldMap, new List<String>{ 'TC_Gross_Fee_Amount__c' })) {
                    feeChanged.add(r.Id);
                }
            }
            TC_CommissionService.recalculate(feeChanged);
            TC_DealService.processClosedDeals((List<TC_Deal__c>) newList, oldMap);
        }
    }

    // ------------------------------------------------------------ Commission
    public class TC_CommissionHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { TC_CommissionService.validateAndDefault((List<TC_Commission__c>) newList); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_CommissionService.validateAndDefault((List<TC_Commission__c>) newList); }
        protected override void afterInsert(List<SObject> newList) { TC_CommissionService.recalculate(TC_TriggerHandler.idsOf(newList, 'TC_Deal__c')); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            Set<Id> deals = new Set<Id>();
            for (SObject r : newList) {
                if (changed(r, oldMap, new List<String>{ 'TC_Fee_Method__c', 'TC_Fee_Percent__c', 'TC_Fee_Amount__c', 'TC_House_Fee_Percent__c', 'RecordTypeId' })) {
                    deals.add((Id) r.get('TC_Deal__c'));
                }
            }
            TC_CommissionService.recalculate(deals);
        }
        protected override void afterDelete(List<SObject> oldList) { TC_CommissionService.recalculate(TC_TriggerHandler.idsOf(oldList, 'TC_Deal__c')); }
    }

    // ------------------------------------------------------------ Inquiry / Prospective Listing
    public class TC_InquiryHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { TC_InquiryService.applyDefaults((List<TC_Inquiry__c>) newList); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_InquiryService.applyDefaults((List<TC_Inquiry__c>) newList); }
        protected override void afterInsert(List<SObject> newList) { TC_InquiryService.syncListingToProspects((List<TC_Inquiry__c>) newList, null); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_InquiryService.syncListingToProspects((List<TC_Inquiry__c>) newList, oldMap); }
    }

    public class TC_ProspectiveListingHandler extends TC_TriggerHandler {
        protected override void afterInsert(List<SObject> newList) { TC_InquiryService.enforceSinglePrimary((List<TC_Prospective_Listing__c>) newList, null); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_InquiryService.enforceSinglePrimary((List<TC_Prospective_Listing__c>) newList, oldMap); }
    }

    // ------------------------------------------------------------ Prospective Buyer
    /** The primary prospective buyer fills the deal's Buyer fields when they are blank (AscendixRE). */
    public class TC_ProspectiveBuyerHandler extends TC_TriggerHandler {
        protected override void afterInsert(List<SObject> newList) { handle((List<TC_Prospective_Buyer__c>) newList, null); }
        protected override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { handle((List<TC_Prospective_Buyer__c>) newList, oldMap); }
        private void handle(List<TC_Prospective_Buyer__c> rows, Map<Id, SObject> oldMap) {
            Map<Id, TC_Prospective_Buyer__c> primaryByDeal = new Map<Id, TC_Prospective_Buyer__c>();
            for (TC_Prospective_Buyer__c r : rows) {
                TC_Prospective_Buyer__c old = oldMap == null ? null : (TC_Prospective_Buyer__c) oldMap.get(r.Id);
                if (r.TC_Primary__c && (old == null || !old.TC_Primary__c)) {
                    primaryByDeal.put(r.TC_Deal__c, r);
                }
            }
            if (primaryByDeal.isEmpty()) {
                return;
            }
            List<TC_Prospective_Buyer__c> clear = new List<TC_Prospective_Buyer__c>();
            Set<Id> keep = new Set<Id>();
            for (TC_Prospective_Buyer__c r : primaryByDeal.values()) { keep.add(r.Id); }
            for (TC_Prospective_Buyer__c r : [SELECT Id FROM TC_Prospective_Buyer__c WHERE TC_Deal__c IN :primaryByDeal.keySet() AND TC_Primary__c = true AND Id NOT IN :keep]) {
                clear.add(new TC_Prospective_Buyer__c(Id = r.Id, TC_Primary__c = false));
            }
            if (!clear.isEmpty()) {
                update clear;
            }
            List<TC_Deal__c> deals = new List<TC_Deal__c>();
            for (TC_Deal__c d : [SELECT Id, TC_Buyer__c, TC_Buyer_Contact__c FROM TC_Deal__c WHERE Id IN :primaryByDeal.keySet()]) {
                TC_Prospective_Buyer__c pb = primaryByDeal.get(d.Id);
                Boolean dirty = false;
                if (d.TC_Buyer__c == null && pb.TC_Account__c != null) { d.TC_Buyer__c = pb.TC_Account__c; dirty = true; }
                if (d.TC_Buyer_Contact__c == null && pb.TC_Contact__c != null) { d.TC_Buyer_Contact__c = pb.TC_Contact__c; dirty = true; }
                if (dirty) { deals.add(d); }
            }
            if (!deals.isEmpty()) {
                update deals;
            }
        }
    }

    // ------------------------------------------------------------ Term Sheet / Sale
    /** Term sheets inherit the capital source, lender name and deal from their deal source. */
    public class TC_TermSheetHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { inherit((List<TC_Term_Sheet__c>) newList); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { inherit((List<TC_Term_Sheet__c>) newList); }
        private void inherit(List<TC_Term_Sheet__c> rows) {
            Set<Id> srcIds = TC_TriggerHandler.idsOf(rows, 'TC_Deal_Source__c');
            Map<Id, TC_Deal_Source__c> sources = new Map<Id, TC_Deal_Source__c>([SELECT Id, TC_Deal__c, TC_Capital_Source__c, TC_Capital_Source__r.Name FROM TC_Deal_Source__c WHERE Id IN :srcIds]);
            for (TC_Term_Sheet__c t : rows) {
                TC_Deal_Source__c s = sources.get(t.TC_Deal_Source__c);
                if (s != null) {
                    t.TC_Deal__c = s.TC_Deal__c;
                    t.TC_Capital_Source__c = s.TC_Capital_Source__c;
                    t.TC_Lender_Name__c = s.TC_Capital_Source__r.Name;
                }
            }
        }
    }

    public class TC_SaleHandler extends TC_TriggerHandler {
        protected override void beforeInsert(List<SObject> newList) { TC_NamingService.apply(newList, TC_Sale__c.SObjectType); }
        protected override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) { TC_NamingService.apply(newList, TC_Sale__c.SObjectType); }
    }
}
