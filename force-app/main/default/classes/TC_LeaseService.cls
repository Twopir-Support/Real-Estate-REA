/**
 * Lease logic: landlord and unit defaults, overlap check per unit, rent table generation,
 * unit occupancy sync, status sweep (Pending -> Active -> Expired).
 */
public inherited sharing class TC_LeaseService {
    public static Boolean suppressRentTableGeneration = false;
    public static final Set<String> OCCUPYING = new Set<String>{ 'Active', 'Holdover' };

    /** Before insert/update: default landlord from the property owner and unit details from the unit. */
    public static void applyDefaults(List<TC_Lease__c> leases) {
        Set<Id> propIds = TC_TriggerHandler.idsOf(leases, 'TC_Property__c');
        Set<Id> unitIds = TC_TriggerHandler.idsOf(leases, 'TC_Unit__c');
        Map<Id, TC_Property__c> props = propIds.isEmpty() ? new Map<Id, TC_Property__c>()
            : new Map<Id, TC_Property__c>([SELECT Id, TC_Owner_Landlord__c FROM TC_Property__c WHERE Id IN :propIds]);
        Map<Id, TC_Unit__c> units = unitIds.isEmpty() ? new Map<Id, TC_Unit__c>()
            : new Map<Id, TC_Unit__c>([SELECT Id, Name, TC_Floor__c, TC_Unit_Type__c FROM TC_Unit__c WHERE Id IN :unitIds]);
        for (TC_Lease__c l : leases) {
            if (l.TC_Owner_Landlord__c == null && props.containsKey(l.TC_Property__c)) {
                l.TC_Owner_Landlord__c = props.get(l.TC_Property__c).TC_Owner_Landlord__c;
            }
            TC_Unit__c u = units.get(l.TC_Unit__c);
            if (u != null) {
                if (String.isBlank(l.TC_Unit_Name__c)) { l.TC_Unit_Name__c = u.Name; }
                if (l.TC_Floor__c == null) { l.TC_Floor__c = u.TC_Floor__c; }
                if (String.isBlank(l.TC_Unit_Type__c) && u.TC_Unit_Type__c != 'Common Area') { l.TC_Unit_Type__c = u.TC_Unit_Type__c; }
            }
            if (String.isBlank(l.TC_Total_Rent_Calculation__c)) {
                l.TC_Total_Rent_Calculation__c = TC_RentTableService.ANNUAL_RATIO;
            }
        }
    }

    /** Before insert/update: no two occupying leases may overlap on the same unit. */
    public static void preventOverlaps(List<TC_Lease__c> leases) {
        if (!TC_Settings.isActive('TC_VAL_Unit_Lease_Overlap')) {
            return;
        }
        List<TC_Lease__c> candidates = new List<TC_Lease__c>();
        for (TC_Lease__c l : leases) {
            if (l.TC_Unit__c != null && OCCUPYING.contains(l.TC_Status__c) && l.TC_Commencement_Date__c != null && l.TC_Expiration_Date__c != null) {
                candidates.add(l);
            }
        }
        if (candidates.isEmpty()) {
            return;
        }
        Set<Id> unitIds = TC_TriggerHandler.idsOf(candidates, 'TC_Unit__c');
        Set<Id> selfIds = new Set<Id>();
        for (TC_Lease__c l : candidates) {
            if (l.Id != null) {
                selfIds.add(l.Id);
            }
        }
        List<TC_Lease__c> others = [
            SELECT Id, Name, TC_Unit__c, TC_Commencement_Date__c, TC_Expiration_Date__c
            FROM TC_Lease__c
            WHERE TC_Unit__c IN :unitIds AND TC_Status__c IN :OCCUPYING AND Id NOT IN :selfIds
        ];
        List<TC_Lease__c> pool = new List<TC_Lease__c>(others);
        for (TC_Lease__c l : candidates) {
            for (TC_Lease__c o : pool) {
                if (o.TC_Unit__c == l.TC_Unit__c && o.TC_Commencement_Date__c <= l.TC_Expiration_Date__c && o.TC_Expiration_Date__c >= l.TC_Commencement_Date__c) {
                    l.TC_Unit__c.addError('This unit already has an active lease for overlapping dates' + (o.Name == null ? '.' : ' (' + o.Name + ').'));
                    break;
                }
            }
            pool.add(l);
        }
    }

    /** After insert: generate the rent table from the lease terms when the lease has none. */
    public static void generateRentTables(List<TC_Lease__c> leases) {
        if (suppressRentTableGeneration || !TC_Settings.isActive('TC_AUTO_Generate_Rent_Table')) {
            return;
        }
        Set<Id> ids = new Set<Id>();
        for (TC_Lease__c l : leases) {
            if (l.TC_Lease_Rate__c != null) {
                ids.add(l.Id);
            }
        }
        TC_RentTableService.generateForLeases(ids, false);
    }

    /** After DML: point each unit at its current occupying lease, or mark it vacant. */
    public static void syncUnits(Set<Id> unitIds) {
        unitIds.remove(null);
        if (unitIds.isEmpty()) {
            return;
        }
        Map<Id, TC_Unit__c> units = new Map<Id, TC_Unit__c>([SELECT Id, TC_Status__c, TC_Current_Lease__c, TC_Current_Tenant__c, TC_Lease_Expiration__c FROM TC_Unit__c WHERE Id IN :unitIds]);
        Map<Id, TC_Lease__c> current = new Map<Id, TC_Lease__c>();
        Date today = Date.today();
        for (TC_Lease__c l : [
            SELECT Id, TC_Unit__c, TC_Tenant__c, TC_Expiration_Date__c, TC_Commencement_Date__c
            FROM TC_Lease__c
            WHERE TC_Unit__c IN :unitIds AND TC_Status__c IN :OCCUPYING
            ORDER BY TC_Commencement_Date__c DESC
        ]) {
            if (!current.containsKey(l.TC_Unit__c) || (l.TC_Commencement_Date__c <= today && current.get(l.TC_Unit__c).TC_Commencement_Date__c > today)) {
                current.put(l.TC_Unit__c, l);
            }
        }
        List<TC_Unit__c> updates = new List<TC_Unit__c>();
        for (TC_Unit__c u : units.values()) {
            TC_Lease__c l = current.get(u.Id);
            TC_Unit__c upd = new TC_Unit__c(Id = u.Id);
            if (l != null) {
                upd.TC_Status__c = 'Occupied';
                upd.TC_Current_Lease__c = l.Id;
                upd.TC_Current_Tenant__c = l.TC_Tenant__c;
                upd.TC_Lease_Expiration__c = l.TC_Expiration_Date__c;
            } else {
                upd.TC_Status__c = (u.TC_Status__c == 'Under Renovation' || u.TC_Status__c == 'Not Leasable') ? u.TC_Status__c : 'Vacant';
                upd.TC_Current_Lease__c = null;
                upd.TC_Current_Tenant__c = null;
                upd.TC_Lease_Expiration__c = null;
            }
            if (upd.TC_Status__c != u.TC_Status__c || upd.TC_Current_Lease__c != u.TC_Current_Lease__c
                    || upd.TC_Current_Tenant__c != u.TC_Current_Tenant__c || upd.TC_Lease_Expiration__c != u.TC_Lease_Expiration__c) {
                updates.add(upd);
            }
        }
        if (!updates.isEmpty()) {
            update updates;
        }
    }

    /** Daily sweep: Pending leases that have commenced become Active; Active leases past expiration become Expired. */
    public static Integer sweepStatuses() {
        Date today = Date.today();
        List<TC_Lease__c> updates = new List<TC_Lease__c>();
        for (TC_Lease__c l : [SELECT Id, TC_Status__c, TC_Commencement_Date__c, TC_Expiration_Date__c FROM TC_Lease__c
                              WHERE (TC_Status__c = 'Active' AND TC_Expiration_Date__c < :today)
                                 OR (TC_Status__c = 'Pending' AND TC_Commencement_Date__c <= :today) LIMIT 5000]) {
            updates.add(new TC_Lease__c(Id = l.Id, TC_Status__c = l.TC_Status__c == 'Active' ? 'Expired' : 'Active'));
        }
        if (!updates.isEmpty()) {
            update updates;
        }
        return updates.size();
    }
}
