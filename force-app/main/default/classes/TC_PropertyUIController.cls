/**
 * LWC controller for property-centred UI: property summary, stacking plan, property search
 * (filters + radius) and the brokerage dashboard. Runs with sharing and USER_MODE queries so
 * users only see records and fields they are allowed to.
 */
public with sharing class TC_PropertyUIController {

    // ---------------------------------------------------------------- property summary
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPropertySummary(Id propertyId) {
        TC_Property__c p = [
            SELECT Id, Name, RecordType.Name, TC_Property_Type__c, TC_Property_Subtype__c, TC_Building_Class__c, TC_Building_Status__c,
                   TC_Street__c, TC_City__c, TC_State__c, TC_Postal_Code__c, TC_Country__c, TC_Location__Latitude__s, TC_Location__Longitude__s,
                   TC_Market__c, TC_Submarket__c, TC_Total_Size__c, TC_Number_of_Floors__c, TC_Year_Built__c, TC_Leased_SF__c,
                   TC_Available_SF__c, TC_Occupancy__c, TC_Active_Listings__c, TC_Avg_Asking_Rate__c, TC_Primary_Image_URL__c,
                   TC_Owner_Landlord__r.Name, TC_Website__c
            FROM TC_Property__c WHERE Id = :propertyId WITH USER_MODE
        ];
        Map<String, Object> out = new Map<String, Object>{ 'property' => p };
        out.put('unitCount', [SELECT COUNT() FROM TC_Unit__c WHERE TC_Property__c = :propertyId WITH USER_MODE]);
        out.put('activeLeases', [SELECT COUNT() FROM TC_Lease__c WHERE TC_Property__c = :propertyId AND TC_Status__c IN ('Active', 'Holdover') WITH USER_MODE]);
        out.put('expiring12', [SELECT COUNT() FROM TC_Lease__c WHERE TC_Property__c = :propertyId AND TC_Status__c = 'Active' AND TC_Expiration_Date__c <= NEXT_N_MONTHS:12 WITH USER_MODE]);
        out.put('openDeals', [SELECT COUNT() FROM TC_Deal__c WHERE TC_Property__c = :propertyId AND TC_Status__c = 'Open' WITH USER_MODE]);
        out.put('openInquiries', [SELECT COUNT() FROM TC_Inquiry__c WHERE TC_Property__c = :propertyId AND TC_Status__c IN ('New', 'Active') WITH USER_MODE]);
        return out;
    }

    // ---------------------------------------------------------------- stacking plan
    public class Block {
        @AuraEnabled public String key;
        @AuraEnabled public Id recordId;
        @AuraEnabled public String label;
        @AuraEnabled public String sublabel;
        @AuraEnabled public Decimal sf;
        @AuraEnabled public String kind;        // lease | available | vacant | unknown
        @AuraEnabled public String expYear;
        @AuraEnabled public Date expiration;
        @AuraEnabled public Integer position;
    }
    public class Floor {
        @AuraEnabled public Integer floor;
        @AuraEnabled public Decimal totalSf = 0;
        @AuraEnabled public Decimal leasedSf = 0;
        @AuraEnabled public List<Block> blocks = new List<Block>();
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getStackingPlan(Id propertyId) {
        TC_Property__c p = [SELECT Id, Name, RecordType.DeveloperName, TC_Number_of_Floors__c, TC_Average_Floor_Size__c, TC_Total_Size__c FROM TC_Property__c WHERE Id = :propertyId WITH USER_MODE];
        TC_Stacking_Plan_Setting__mdt cfg = TC_Settings.stackingPlan();
        Boolean enabled = cfg == null || !cfg.TC_Active__c || String.isBlank(cfg.TC_Record_Types__c)
            || TC_Settings.splitList(cfg.TC_Record_Types__c).contains(p.RecordType.DeveloperName);
        Map<Integer, Floor> floors = new Map<Integer, Floor>();
        Integer topFloor = p.TC_Number_of_Floors__c == null ? 0 : p.TC_Number_of_Floors__c.intValue();

        Map<Id, TC_Availability__c> availByUnit = new Map<Id, TC_Availability__c>();
        List<TC_Availability__c> looseAvail = new List<TC_Availability__c>();
        for (TC_Availability__c a : [SELECT Id, Name, TC_Unit__c, TC_Unit_Name__c, TC_Floor__c, TC_Size__c, TC_Lease_Rate__c, TC_Date_Available__c FROM TC_Availability__c WHERE TC_Property__c = :propertyId AND TC_Status__c = 'Available' WITH USER_MODE]) {
            if (a.TC_Unit__c != null) { availByUnit.put(a.TC_Unit__c, a); } else { looseAvail.add(a); }
        }
        for (TC_Unit__c u : [SELECT Id, Name, TC_Floor__c, TC_Size__c, TC_Status__c, TC_Position__c, TC_Current_Lease__c, TC_Current_Tenant__r.Name, TC_Lease_Expiration__c
                             FROM TC_Unit__c WHERE TC_Property__c = :propertyId WITH USER_MODE ORDER BY TC_Floor__c, TC_Position__c, Name]) {
            Integer f = u.TC_Floor__c.intValue();
            Block b = new Block();
            b.key = u.Id;
            b.sf = u.TC_Size__c;
            b.position = u.TC_Position__c == null ? 99 : u.TC_Position__c.intValue();
            if (u.TC_Current_Lease__c != null) {
                b.kind = 'lease';
                b.recordId = u.TC_Current_Lease__c;
                b.label = u.TC_Current_Tenant__r == null ? u.Name : u.TC_Current_Tenant__r.Name;
                b.sublabel = u.Name;
                b.expiration = u.TC_Lease_Expiration__c;
                b.expYear = u.TC_Lease_Expiration__c == null ? null : String.valueOf(u.TC_Lease_Expiration__c.year());
            } else if (availByUnit.containsKey(u.Id)) {
                TC_Availability__c a = availByUnit.get(u.Id);
                b.kind = 'available';
                b.recordId = a.Id;
                b.label = 'Available';
                b.sublabel = u.Name + (a.TC_Lease_Rate__c == null ? '' : ' · $' + a.TC_Lease_Rate__c.setScale(2) + '/SF');
            } else {
                b.kind = 'vacant';
                b.recordId = u.Id;
                b.label = u.TC_Status__c == 'Vacant' ? 'Vacant' : u.TC_Status__c;
                b.sublabel = u.Name;
            }
            floorFor(floors, f).blocks.add(b);
            topFloor = Math.max(topFloor, f);
        }
        // Leases recorded with a floor but no unit (AscendixRE builds plans from floors + leases)
        for (TC_Lease__c l : [SELECT Id, TC_Tenant__r.Name, TC_Floor__c, TC_Size__c, TC_Unit_Name__c, TC_Expiration_Date__c FROM TC_Lease__c
                              WHERE TC_Property__c = :propertyId AND TC_Unit__c = null AND TC_Floor__c != null AND TC_Status__c IN ('Active', 'Holdover') WITH USER_MODE]) {
            Block b = new Block();
            b.key = l.Id; b.recordId = l.Id; b.kind = 'lease'; b.sf = l.TC_Size__c; b.position = 50;
            b.label = l.TC_Tenant__r.Name; b.sublabel = l.TC_Unit_Name__c;
            b.expiration = l.TC_Expiration_Date__c;
            b.expYear = String.valueOf(l.TC_Expiration_Date__c.year());
            floorFor(floors, l.TC_Floor__c.intValue()).blocks.add(b);
            topFloor = Math.max(topFloor, l.TC_Floor__c.intValue());
        }
        for (TC_Availability__c a : looseAvail) {
            if (a.TC_Floor__c == null) { continue; }
            Block b = new Block();
            b.key = a.Id; b.recordId = a.Id; b.kind = 'available'; b.sf = a.TC_Size__c; b.position = 60;
            b.label = 'Available'; b.sublabel = a.TC_Unit_Name__c;
            floorFor(floors, a.TC_Floor__c.intValue()).blocks.add(b);
            topFloor = Math.max(topFloor, a.TC_Floor__c.intValue());
        }
        // Fill each floor up to the average floor size with a "not recorded" block.
        List<Floor> ordered = new List<Floor>();
        for (Integer f = topFloor; f >= 1; f--) {
            Floor fl = floorFor(floors, f);
            for (Block b : fl.blocks) {
                fl.totalSf += b.sf == null ? 0 : b.sf;
                if (b.kind == 'lease') { fl.leasedSf += b.sf == null ? 0 : b.sf; }
            }
            if (p.TC_Average_Floor_Size__c != null && fl.totalSf < p.TC_Average_Floor_Size__c) {
                Block gap = new Block();
                gap.key = 'gap-' + f; gap.kind = 'unknown'; gap.sf = p.TC_Average_Floor_Size__c - fl.totalSf; gap.position = 999;
                gap.label = 'Not recorded';
                fl.blocks.add(gap);
                fl.totalSf = p.TC_Average_Floor_Size__c;
            }
            sortBlocks(fl.blocks);
            ordered.add(fl);
        }
        return new Map<String, Object>{
            'enabled' => enabled,
            'propertyName' => p.Name,
            'floors' => ordered,
            'vacancyColor' => cfg == null || String.isBlank(cfg.TC_Vacancy_Color__c) ? '#F4D03F' : cfg.TC_Vacancy_Color__c
        };
    }

    private static Floor floorFor(Map<Integer, Floor> floors, Integer f) {
        if (!floors.containsKey(f)) {
            Floor fl = new Floor();
            fl.floor = f;
            floors.put(f, fl);
        }
        return floors.get(f);
    }

    private static void sortBlocks(List<Block> blocks) {
        for (Integer i = 1; i < blocks.size(); i++) {
            Block key = blocks[i];
            Integer j = i - 1;
            while (j >= 0 && blocks[j].position > key.position) {
                blocks[j + 1] = blocks[j];
                j--;
            }
            blocks[j + 1] = key;
        }
    }

    // ---------------------------------------------------------------- search
    public class SearchCriteria {
        @AuraEnabled public String propertyType { get; set; }
        @AuraEnabled public String buildingClass { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String market { get; set; }
        @AuraEnabled public Decimal minSize { get; set; }
        @AuraEnabled public Decimal maxSize { get; set; }
        @AuraEnabled public Decimal minAvailable { get; set; }
        @AuraEnabled public Decimal maxRate { get; set; }
        @AuraEnabled public Boolean hasAvailability { get; set; }
        @AuraEnabled public Decimal latitude { get; set; }
        @AuraEnabled public Decimal longitude { get; set; }
        @AuraEnabled public Decimal radiusMiles { get; set; }
    }

    @AuraEnabled
    public static List<TC_Property__c> searchProperties(SearchCriteria criteria) {
        List<String> clauses = new List<String>();
        Map<String, Object> binds = new Map<String, Object>();
        if (criteria != null) {
            if (String.isNotBlank(criteria.propertyType)) { clauses.add('TC_Property_Type__c = :ptype'); binds.put('ptype', criteria.propertyType); }
            if (String.isNotBlank(criteria.buildingClass)) { clauses.add('TC_Building_Class__c = :bclass'); binds.put('bclass', criteria.buildingClass); }
            if (String.isNotBlank(criteria.city)) { clauses.add('TC_City__c LIKE :city'); binds.put('city', '%' + criteria.city.trim() + '%'); }
            if (String.isNotBlank(criteria.market)) { clauses.add('(TC_Market__c LIKE :mkt OR TC_Submarket__c LIKE :mkt)'); binds.put('mkt', '%' + criteria.market.trim() + '%'); }
            if (criteria.minSize != null) { clauses.add('TC_Total_Size__c >= :minSize'); binds.put('minSize', criteria.minSize); }
            if (criteria.maxSize != null) { clauses.add('TC_Total_Size__c <= :maxSize'); binds.put('maxSize', criteria.maxSize); }
            if (criteria.minAvailable != null) { clauses.add('TC_Available_SF__c >= :minAvail'); binds.put('minAvail', criteria.minAvailable); }
            if (criteria.maxRate != null) { clauses.add('TC_Avg_Asking_Rate__c <= :maxRate'); binds.put('maxRate', criteria.maxRate); }
            if (criteria.hasAvailability == true) { clauses.add('TC_Available_SF__c > 0'); }
            if (criteria.latitude != null && criteria.longitude != null && criteria.radiusMiles != null && criteria.radiusMiles > 0) {
                clauses.add('DISTANCE(TC_Location__c, GEOLOCATION(:lat, :lng), \'mi\') < :radius');
                binds.put('lat', criteria.latitude);
                binds.put('lng', criteria.longitude);
                binds.put('radius', criteria.radiusMiles);
            }
        }
        String soql = 'SELECT Id, Name, TC_Property_Type__c, TC_Building_Class__c, TC_Street__c, TC_City__c, TC_State__c, TC_Market__c, TC_Submarket__c, '
            + 'TC_Total_Size__c, TC_Available_SF__c, TC_Occupancy__c, TC_Avg_Asking_Rate__c, TC_Active_Listings__c, TC_Location__Latitude__s, TC_Location__Longitude__s, '
            + 'TC_Owner_Landlord__r.Name FROM TC_Property__c'
            + (clauses.isEmpty() ? '' : ' WHERE ' + String.join(clauses, ' AND '))
            + ' ORDER BY Name LIMIT 200';
        return (List<TC_Property__c>) Database.queryWithBinds(soql, binds, AccessLevel.USER_MODE);
    }

    // ---------------------------------------------------------------- dashboard
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboard(String market, String propertyType) {
        String pf = '';
        Map<String, Object> binds = new Map<String, Object>();
        if (String.isNotBlank(market)) { pf += ' AND TC_Market__c = :market'; binds.put('market', market); }
        if (String.isNotBlank(propertyType)) { pf += ' AND TC_Property_Type__c = :ptype'; binds.put('ptype', propertyType); }
        Map<String, Object> out = new Map<String, Object>();

        AggregateResult pa = ((List<AggregateResult>) Database.queryWithBinds(
            'SELECT COUNT(Id) n, SUM(TC_Total_Size__c) total, SUM(TC_Leased_SF__c) leased, SUM(TC_Available_SF__c) avail, SUM(TC_Active_Listings__c) listings FROM TC_Property__c WHERE Id != null' + pf,
            binds, AccessLevel.USER_MODE))[0];
        Decimal total = nz(pa.get('total'));
        Decimal leased = nz(pa.get('leased'));
        out.put('properties', pa.get('n'));
        out.put('totalSf', total);
        out.put('leasedSf', leased);
        out.put('availableSf', nz(pa.get('avail')));
        out.put('activeListings', nz(pa.get('listings')));
        out.put('occupancy', total == 0 ? 0 : (leased / total * 100).setScale(1));

        List<Map<String, Object>> byType = new List<Map<String, Object>>();
        for (AggregateResult ar : (List<AggregateResult>) Database.queryWithBinds(
                'SELECT TC_Property_Type__c t, SUM(TC_Total_Size__c) total, SUM(TC_Leased_SF__c) leased FROM TC_Property__c WHERE TC_Property_Type__c != null' + pf + ' GROUP BY TC_Property_Type__c ORDER BY TC_Property_Type__c',
                binds, AccessLevel.USER_MODE)) {
            Decimal t = nz(ar.get('total'));
            byType.add(new Map<String, Object>{ 'label' => ar.get('t'), 'value' => t == 0 ? 0 : (nz(ar.get('leased')) / t * 100).setScale(1) });
        }
        out.put('occupancyByType', byType);

        String dealFilter = '';
        if (String.isNotBlank(market)) { dealFilter += ' AND TC_Property__r.TC_Market__c = :market'; }
        if (String.isNotBlank(propertyType)) { dealFilter += ' AND TC_Property__r.TC_Property_Type__c = :ptype'; }
        Map<String, Decimal> feeByStage = new Map<String, Decimal>();
        Decimal pipeline = 0;
        Decimal weighted = 0;
        Integer openDeals = 0;
        for (AggregateResult ar : (List<AggregateResult>) Database.queryWithBinds(
                'SELECT TC_Stage__c s, COUNT(Id) n, SUM(TC_Gross_Fee_Amount__c) fee, SUM(TC_Weighted_Fee__c) w FROM TC_Deal__c WHERE TC_Status__c = \'Open\'' + dealFilter + ' GROUP BY TC_Stage__c',
                binds, AccessLevel.USER_MODE)) {
            feeByStage.put((String) ar.get('s'), nz(ar.get('fee')));
            pipeline += nz(ar.get('fee'));
            weighted += nz(ar.get('w'));
            openDeals += (Integer) ar.get('n');
        }
        List<Map<String, Object>> stageSeries = new List<Map<String, Object>>();
        for (String s : TC_Settings.orderedStages()) {
            if (s == 'Executed') { continue; }
            stageSeries.add(new Map<String, Object>{ 'label' => s, 'value' => feeByStage.containsKey(s) ? feeByStage.get(s) : 0 });
        }
        out.put('pipelineByStage', stageSeries);
        out.put('pipelineFee', pipeline);
        out.put('weightedFee', weighted);
        out.put('openDeals', openDeals);
        AggregateResult won = ((List<AggregateResult>) Database.queryWithBinds(
            'SELECT COUNT(Id) n, SUM(TC_Gross_Fee_Amount__c) fee FROM TC_Deal__c WHERE TC_Status__c = \'Won\' AND TC_Actual_Close_Date__c = THIS_YEAR' + dealFilter,
            binds, AccessLevel.USER_MODE))[0];
        out.put('wonYtd', won.get('n'));
        out.put('wonFeeYtd', nz(won.get('fee')));

        String leaseFilter = '';
        if (String.isNotBlank(market)) { leaseFilter += ' AND TC_Property__r.TC_Market__c = :market'; }
        if (String.isNotBlank(propertyType)) { leaseFilter += ' AND TC_Property__r.TC_Property_Type__c = :ptype'; }
        Map<Integer, Decimal> sfByYear = new Map<Integer, Decimal>();
        Integer thisYear = Date.today().year();
        for (Integer y = thisYear; y < thisYear + 6; y++) { sfByYear.put(y, 0); }
        Decimal expiring12 = 0;
        Date in12 = Date.today().addMonths(12);
        for (TC_Lease__c l : (List<TC_Lease__c>) Database.queryWithBinds(
                'SELECT TC_Size__c, TC_Expiration_Date__c FROM TC_Lease__c WHERE TC_Status__c IN (\'Active\', \'Holdover\') AND TC_Expiration_Date__c >= TODAY' + leaseFilter + ' LIMIT 5000',
                binds, AccessLevel.USER_MODE)) {
            Integer y = l.TC_Expiration_Date__c.year();
            if (sfByYear.containsKey(y)) { sfByYear.put(y, sfByYear.get(y) + nz(l.TC_Size__c)); }
            if (l.TC_Expiration_Date__c <= in12) { expiring12 += nz(l.TC_Size__c); }
        }
        List<Map<String, Object>> expSeries = new List<Map<String, Object>>();
        for (Integer y : sfByYear.keySet()) { expSeries.add(new Map<String, Object>{ 'label' => String.valueOf(y), 'value' => sfByYear.get(y) }); }
        out.put('expirationsByYear', expSeries);
        out.put('expiringSf12', expiring12);

        List<Map<String, Object>> bySource = new List<Map<String, Object>>();
        for (AggregateResult ar : [SELECT TC_Source__c s, COUNT(Id) n FROM TC_Inquiry__c WHERE CreatedDate = LAST_N_DAYS:365 AND TC_Source__c != null WITH USER_MODE GROUP BY TC_Source__c ORDER BY COUNT(Id) DESC]) {
            bySource.add(new Map<String, Object>{ 'label' => ar.get('s'), 'value' => ar.get('n') });
        }
        out.put('inquiriesBySource', bySource);
        out.put('openInquiries', [SELECT COUNT() FROM TC_Inquiry__c WHERE TC_Status__c IN ('New', 'Active') WITH USER_MODE]);

        List<String> markets = new List<String>();
        for (AggregateResult ar : [SELECT TC_Market__c m FROM TC_Property__c WHERE TC_Market__c != null WITH USER_MODE GROUP BY TC_Market__c ORDER BY TC_Market__c LIMIT 50]) {
            markets.add((String) ar.get('m'));
        }
        out.put('markets', markets);
        return out;
    }

    private static Decimal nz(Object v) {
        return v == null ? 0 : (Decimal) v;
    }
}
