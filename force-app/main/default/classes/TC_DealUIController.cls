/**
 * LWC controller for deal UI: Kanban pipeline, Close Deal dialog, rent tables, commission grid,
 * term sheet comparison, record scorecards and the commission dashboard.
 * with sharing + USER_MODE data access throughout.
 */
public with sharing class TC_DealUIController {

    // ---------------------------------------------------------------- pipeline
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPipeline(String recordTypeDevName, Boolean myDealsOnly) {
        List<String> clauses = new List<String>{ 'TC_Status__c = \'Open\'' };
        Map<String, Object> binds = new Map<String, Object>();
        if (String.isNotBlank(recordTypeDevName)) { clauses.add('RecordType.DeveloperName = :rt'); binds.put('rt', recordTypeDevName); }
        if (myDealsOnly == true) { clauses.add('TC_Lead_Broker__c = :me'); binds.put('me', UserInfo.getUserId()); }
        List<TC_Deal__c> deals = (List<TC_Deal__c>) Database.queryWithBinds(
            'SELECT Id, Name, RecordType.Name, TC_Stage__c, TC_Client__r.Name, TC_Property__r.Name, TC_Size__c, TC_Gross_Fee_Amount__c, TC_Weighted_Fee__c, '
            + 'TC_Probability__c, TC_Est_Close_Date__c, TC_Lead_Broker__r.Name FROM TC_Deal__c WHERE ' + String.join(clauses, ' AND ')
            + ' ORDER BY TC_Est_Close_Date__c NULLS LAST LIMIT 500', binds, AccessLevel.USER_MODE);
        List<String> stages = new List<String>();
        for (String s : TC_Settings.orderedStages()) {
            if (s != 'Executed') { stages.add(s); }
        }
        List<Map<String, String>> types = new List<Map<String, String>>();
        for (Schema.RecordTypeInfo info : TC_Deal__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (!info.isMaster() && info.isAvailable()) {
                types.add(new Map<String, String>{ 'label' => info.getName(), 'value' => info.getDeveloperName() });
            }
        }
        return new Map<String, Object>{ 'stages' => stages, 'deals' => deals, 'recordTypes' => types };
    }

    @AuraEnabled
    public static void updateStage(Id dealId, String stage) {
        TC_Deal__c d = new TC_Deal__c(Id = dealId, TC_Stage__c = stage);
        Database.update(d, AccessLevel.USER_MODE);
    }

    // ---------------------------------------------------------------- close deal
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getCloseInfo(Id dealId) {
        TC_Deal__c d = [SELECT Id, Name, RecordTypeId, RecordType.Name, TC_Status__c, TC_Gross_Deal_Value__c, TC_Gross_Fee_Amount__c, TC_Space__c, TC_Space__r.Name,
                               TC_Property__c, TC_Tenant__c, TC_Sale_Price__c, TC_Lease_Commencement__c, TC_Lease_Expiration__c, TC_Size__c
                        FROM TC_Deal__c WHERE Id = :dealId WITH USER_MODE];
        String rt = TC_DealService.rtName(d);
        List<String> willCreate = new List<String>();
        List<String> missing = new List<String>();
        if (TC_FieldMappingService.groupApplies('DEAL_TO_LEASE', rt)) {
            if (d.TC_Property__c == null) { missing.add('Property'); }
            if (d.TC_Tenant__c == null) { missing.add('Tenant'); }
            if (d.TC_Lease_Commencement__c == null || d.TC_Lease_Expiration__c == null) { missing.add('Lease Commencement / Expiration'); }
            if (d.TC_Size__c == null) { missing.add('Size'); }
            willCreate.add('Lease with rent table');
        }
        if (TC_FieldMappingService.groupApplies('DEAL_TO_SALE', rt)) {
            if (d.TC_Property__c == null) { missing.add('Property'); }
            if (d.TC_Sale_Price__c == null) { missing.add('Sale Price'); }
            willCreate.add('Sale record');
        }
        if (TC_FieldMappingService.groupApplies('DEAL_TO_LISTING', rt)) {
            if (d.TC_Property__c == null) { missing.add('Property'); }
            willCreate.add('Listing');
        }
        if (d.TC_Space__c != null) {
            willCreate.add('Mark space ' + d.TC_Space__r.Name + ' as Closed');
        }
        Schema.DescribeFieldResult lost = TC_Deal__c.TC_Lost_Reason__c.getDescribe();
        List<String> reasons = new List<String>();
        for (Schema.PicklistEntry e : lost.getPicklistValues()) { reasons.add(e.getValue()); }
        return new Map<String, Object>{ 'deal' => d, 'recordType' => d.RecordType.Name, 'willCreate' => willCreate, 'missing' => new List<String>(new Set<String>(missing)), 'lostReasons' => reasons };
    }

    @AuraEnabled
    public static Map<String, Object> closeDeal(Id dealId, String status, Date closeDate, Decimal actualValue, String lostReason) {
        if (status != 'Won' && status != 'Lost') {
            throw new AuraHandledException('Choose Won or Lost.');
        }
        TC_Deal__c d = new TC_Deal__c(Id = dealId, TC_Status__c = status, TC_Actual_Close_Date__c = closeDate == null ? Date.today() : closeDate);
        if (actualValue != null) { d.TC_Actual_Value__c = actualValue; }
        if (status == 'Lost') { d.TC_Lost_Reason__c = lostReason; }
        try {
            Database.update(d, AccessLevel.USER_MODE);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        List<Map<String, String>> created = new List<Map<String, String>>();
        for (TC_Lease__c l : [SELECT Id, Name FROM TC_Lease__c WHERE TC_Deal__c = :dealId WITH USER_MODE]) { created.add(new Map<String, String>{ 'id' => l.Id, 'label' => 'Lease: ' + l.Name }); }
        for (TC_Sale__c s : [SELECT Id, Name FROM TC_Sale__c WHERE TC_Deal__c = :dealId WITH USER_MODE]) { created.add(new Map<String, String>{ 'id' => s.Id, 'label' => 'Sale: ' + s.Name }); }
        for (TC_Listing__c l : [SELECT Id, Name FROM TC_Listing__c WHERE TC_Deal__c = :dealId WITH USER_MODE]) { created.add(new Map<String, String>{ 'id' => l.Id, 'label' => 'Listing: ' + l.Name }); }
        return new Map<String, Object>{ 'created' => created };
    }

    // ---------------------------------------------------------------- rent table
    @AuraEnabled
    public static Map<String, Object> getRentTable(Id parentId) {
        Boolean isDeal = parentId.getSObjectType() == TC_Deal__c.SObjectType;
        List<SObject> rows;
        SObject parent;
        if (isDeal) {
            parent = [SELECT Id, TC_Size__c, TC_Total_Rent_Calculation__c, TC_Lease_Rate__c, TC_Lease_Commencement__c, TC_Lease_Expiration__c, TC_Gross_Deal_Value__c FROM TC_Deal__c WHERE Id = :parentId WITH USER_MODE];
            rows = [SELECT Id, Name, TC_Period_Number__c, TC_From__c, TC_To__c, TC_Duration_Months__c, TC_Rate__c, TC_Rent_Per_Month__c, TC_Total_Rent__c, TC_Free_Rent__c FROM TC_Deal_Period__c WHERE TC_Deal__c = :parentId WITH USER_MODE ORDER BY TC_From__c];
        } else {
            parent = [SELECT Id, TC_Size__c, TC_Total_Rent_Calculation__c, TC_Lease_Rate__c, TC_Commencement_Date__c, TC_Expiration_Date__c, TC_Total_Rent__c FROM TC_Lease__c WHERE Id = :parentId WITH USER_MODE];
            rows = [SELECT Id, Name, TC_Period_Number__c, TC_From__c, TC_To__c, TC_Duration_Months__c, TC_Rate__c, TC_Rent_Per_Month__c, TC_Total_Rent__c, TC_Free_Rent__c FROM TC_Lease_Period__c WHERE TC_Lease__c = :parentId WITH USER_MODE ORDER BY TC_From__c];
        }
        Decimal total = 0;
        for (SObject r : rows) { total += r.get('TC_Total_Rent__c') == null ? 0 : (Decimal) r.get('TC_Total_Rent__c'); }
        return new Map<String, Object>{
            'isDeal' => isDeal, 'parent' => parent, 'rows' => rows, 'total' => total,
            'warnings' => TC_RentTableService.review(rows),
            'objectApiName' => isDeal ? 'TC_Deal_Period__c' : 'TC_Lease_Period__c'
        };
    }

    @AuraEnabled
    public static Integer generateRentTable(Id parentId, Boolean replaceExisting) {
        Boolean isDeal = parentId.getSObjectType() == TC_Deal__c.SObjectType;
        SObjectType childType = isDeal ? TC_Deal_Period__c.SObjectType : TC_Lease_Period__c.SObjectType;
        if (!childType.getDescribe().isCreateable() || (replaceExisting == true && !childType.getDescribe().isDeletable())) {
            throw new AuraHandledException('You do not have permission to change this rent table.');
        }
        try {
            return isDeal ? TC_RentTableService.generateForDeals(new Set<Id>{ parentId }, replaceExisting == true)
                          : TC_RentTableService.generateForLeases(new Set<Id>{ parentId }, replaceExisting == true);
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    // ---------------------------------------------------------------- commissions
    @AuraEnabled
    public static Map<String, Object> getCommissions(Id dealId) {
        TC_Deal__c d = [SELECT Id, Name, TC_Gross_Fee_Amount__c, TC_Net_Deal_Fee__c, TC_Total_Commission_Split__c, TC_Gross_Fee_Method__c, TC_Gross_Deal_Value__c, TC_Status__c FROM TC_Deal__c WHERE Id = :dealId WITH USER_MODE];
        Boolean canSeeHouse = Schema.sObjectType.TC_Commission__c.fields.TC_House__c.isAccessible();
        String fields = 'Id, Name, RecordTypeId, RecordType.DeveloperName, RecordType.Name, TC_Broker__c, TC_Broker__r.Name, TC_Account__c, TC_Account__r.Name, TC_Contact__c, TC_Contact__r.Name, '
            + 'TC_Fee_Method__c, TC_Fee_Percent__c, TC_Fee_Amount__c, TC_House_Fee_Percent__c, TC_Gross_Commission__c, TC_Direct_Expenses__c, TC_Status__c, TC_Description__c'
            + (canSeeHouse ? ', TC_House__c, TC_Net_Commission__c' : '');
        List<TC_Commission__c> rows = Database.query('SELECT ' + fields + ' FROM TC_Commission__c WHERE TC_Deal__c = :dealId WITH USER_MODE ORDER BY RecordType.Name, CreatedDate');
        List<Map<String, String>> types = new List<Map<String, String>>();
        for (Schema.RecordTypeInfo info : TC_Commission__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (!info.isMaster() && info.isAvailable()) {
                types.add(new Map<String, String>{ 'label' => info.getName(), 'value' => info.getDeveloperName(), 'id' => info.getRecordTypeId() });
            }
        }
        return new Map<String, Object>{ 'deal' => d, 'rows' => rows, 'canSeeHouse' => canSeeHouse, 'recordTypes' => types };
    }

    @AuraEnabled
    public static List<TC_Commission__c> newCommissionRows(Id dealId, String recordTypeDevName, Integer count) {
        return TC_CommissionService.newRows(dealId, recordTypeDevName, count);
    }

    @AuraEnabled
    public static void saveCommissions(List<TC_Commission__c> rows) {
        List<TC_Commission__c> inserts = new List<TC_Commission__c>();
        List<TC_Commission__c> updates = new List<TC_Commission__c>();
        for (TC_Commission__c c : rows) {
            if (c.Id == null) { inserts.add(c); } else { updates.add(c); }
        }
        try {
            if (!inserts.isEmpty()) { Database.insert(inserts, AccessLevel.USER_MODE); }
            if (!updates.isEmpty()) { Database.update(updates, AccessLevel.USER_MODE); }
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    // ---------------------------------------------------------------- term sheets
    @AuraEnabled(cacheable=true)
    public static List<TC_Term_Sheet__c> getTermSheets(Id dealId) {
        return [SELECT Id, Name, TC_Lender_Name__c, TC_Quote_Date__c, TC_Loan_Amount__c, TC_Interest_Rate__c, TC_Rate_Type__c, TC_Term_Years__c,
                       TC_Amortization_Years__c, TC_LTV__c, TC_DSCR__c, TC_Recourse__c, TC_Origination_Fee__c, TC_Prepayment__c, TC_Deal_Source__r.TC_Status__c
                FROM TC_Term_Sheet__c WHERE TC_Deal__c = :dealId WITH USER_MODE ORDER BY TC_Interest_Rate__c NULLS LAST LIMIT 20];
    }

    // ---------------------------------------------------------------- scorecards
    public class Tile {
        @AuraEnabled public String label;
        @AuraEnabled public Object value;
        @AuraEnabled public String format; // currency | number | percent | text
        public Tile(String label, Object value, String format) { this.label = label; this.value = value; this.format = format; }
    }

    @AuraEnabled(cacheable=true)
    public static List<Tile> getScorecard(Id recordId) {
        SObjectType t = recordId.getSObjectType();
        List<Tile> tiles = new List<Tile>();
        if (t == TC_Deal__c.SObjectType) {
            TC_Deal__c d = [SELECT TC_Gross_Deal_Value__c, TC_Gross_Fee_Amount__c, TC_Net_Deal_Fee__c, TC_Probability__c, TC_Weighted_Fee__c FROM TC_Deal__c WHERE Id = :recordId WITH USER_MODE];
            tiles.add(new Tile('Gross Deal Value', d.TC_Gross_Deal_Value__c, 'currency'));
            tiles.add(new Tile('Gross Fee', d.TC_Gross_Fee_Amount__c, 'currency'));
            tiles.add(new Tile('Net Deal Fee', d.TC_Net_Deal_Fee__c, 'currency'));
            tiles.add(new Tile('Weighted Fee', d.TC_Weighted_Fee__c, 'currency'));
            tiles.add(new Tile('Commissions', [SELECT COUNT() FROM TC_Commission__c WHERE TC_Deal__c = :recordId WITH USER_MODE], 'number'));
        } else if (t == TC_Property__c.SObjectType) {
            TC_Property__c p = [SELECT TC_Total_Size__c, TC_Occupancy__c, TC_Available_SF__c, TC_Avg_Asking_Rate__c FROM TC_Property__c WHERE Id = :recordId WITH USER_MODE];
            tiles.add(new Tile('Total Size (SF)', p.TC_Total_Size__c, 'number'));
            tiles.add(new Tile('Occupancy', p.TC_Occupancy__c == null ? null : p.TC_Occupancy__c / 100, 'percent'));
            tiles.add(new Tile('Available (SF)', p.TC_Available_SF__c, 'number'));
            tiles.add(new Tile('Avg Asking Rate', p.TC_Avg_Asking_Rate__c, 'currency'));
            tiles.add(new Tile('Open Deals', [SELECT COUNT() FROM TC_Deal__c WHERE TC_Property__c = :recordId AND TC_Status__c = 'Open' WITH USER_MODE], 'number'));
        } else if (t == TC_Lease__c.SObjectType) {
            TC_Lease__c l = [SELECT TC_Size__c, TC_Annual_Rent__c, TC_Total_Rent__c, TC_Term_Months__c, TC_Days_to_Expiration__c FROM TC_Lease__c WHERE Id = :recordId WITH USER_MODE];
            tiles.add(new Tile('Size (SF)', l.TC_Size__c, 'number'));
            tiles.add(new Tile('Annual Base Rent', l.TC_Annual_Rent__c, 'currency'));
            tiles.add(new Tile('Total Rent', l.TC_Total_Rent__c, 'currency'));
            tiles.add(new Tile('Term (Months)', l.TC_Term_Months__c, 'number'));
            tiles.add(new Tile('Days to Expiration', l.TC_Days_to_Expiration__c, 'number'));
        } else if (t == TC_Listing__c.SObjectType) {
            TC_Listing__c l = [SELECT TC_Total_Available_SF__c, TC_Asking_Rate__c, TC_Asking_Price__c, TC_Days_on_Market__c FROM TC_Listing__c WHERE Id = :recordId WITH USER_MODE];
            tiles.add(new Tile('Available (SF)', l.TC_Total_Available_SF__c, 'number'));
            tiles.add(new Tile('Asking Rate', l.TC_Asking_Rate__c, 'currency'));
            tiles.add(new Tile('Asking Price', l.TC_Asking_Price__c, 'currency'));
            tiles.add(new Tile('Days on Market', l.TC_Days_on_Market__c, 'number'));
            tiles.add(new Tile('Prospective Inquiries', [SELECT COUNT() FROM TC_Prospective_Listing__c WHERE TC_Listing__c = :recordId WITH USER_MODE], 'number'));
        } else if (t == Account.SObjectType) {
            tiles.add(new Tile('Open Deals (Client)', [SELECT COUNT() FROM TC_Deal__c WHERE TC_Client__c = :recordId AND TC_Status__c = 'Open' WITH USER_MODE], 'number'));
            tiles.add(new Tile('Active Leases (Tenant)', [SELECT COUNT() FROM TC_Lease__c WHERE TC_Tenant__c = :recordId AND TC_Status__c = 'Active' WITH USER_MODE], 'number'));
            tiles.add(new Tile('Properties Owned', [SELECT COUNT() FROM TC_Property__c WHERE TC_Owner_Landlord__c = :recordId WITH USER_MODE], 'number'));
        }
        return tiles;
    }

    // ---------------------------------------------------------------- commission dashboard
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCommissionDashboard(Integer year) {
        Integer y = year == null ? Date.today().year() : year;
        Date startD = Date.newInstance(y, 1, 1);
        Date endD = Date.newInstance(y, 12, 31);
        Boolean canSeeHouse = Schema.sObjectType.TC_Commission__c.fields.TC_House__c.isAccessible();
        Map<String, Object> out = new Map<String, Object>{ 'canSeeHouse' => canSeeHouse, 'year' => y };
        List<Map<String, Object>> byBroker = new List<Map<String, Object>>();
        String agg = 'SELECT TC_Broker__r.Name b, SUM(TC_Gross_Commission__c) g' + (canSeeHouse ? ', SUM(TC_House__c) h' : '')
            + ' FROM TC_Commission__c WHERE RecordType.DeveloperName = \'TC_Inside_Broker\' AND TC_Status__c != \'Cancelled\''
            + ' AND (TC_Deal__r.TC_Est_Close_Date__c >= :startD OR TC_Deal__r.TC_Actual_Close_Date__c >= :startD)'
            + ' AND (TC_Deal__r.TC_Est_Close_Date__c <= :endD OR TC_Deal__r.TC_Actual_Close_Date__c <= :endD)'
            + ' GROUP BY TC_Broker__r.Name ORDER BY SUM(TC_Gross_Commission__c) DESC NULLS LAST LIMIT 20';
        for (AggregateResult ar : (List<AggregateResult>) Database.queryWithBinds(agg, new Map<String, Object>{ 'startD' => startD, 'endD' => endD }, AccessLevel.USER_MODE)) {
            Map<String, Object> row = new Map<String, Object>{ 'label' => ar.get('b') == null ? 'Unassigned' : ar.get('b'), 'value' => ar.get('g') };
            if (canSeeHouse) { row.put('house', ar.get('h')); }
            byBroker.add(row);
        }
        out.put('byBroker', byBroker);
        List<Map<String, Object>> byStatus = new List<Map<String, Object>>();
        Decimal projected = 0, earned = 0, paid = 0, balance = 0;
        for (AggregateResult ar : [SELECT TC_Status__c s, SUM(TC_Gross_Commission__c) g, SUM(TC_Amount_Paid__c) p FROM TC_Commission__c WHERE TC_Status__c != 'Cancelled' WITH USER_MODE GROUP BY TC_Status__c]) {
            Decimal g = ar.get('g') == null ? 0 : (Decimal) ar.get('g');
            String s = (String) ar.get('s');
            byStatus.add(new Map<String, Object>{ 'label' => s, 'value' => g });
            if (s == 'Projected') { projected += g; }
            if (s == 'Earned' || s == 'Invoiced') { earned += g; }
            if (s == 'Paid') { paid += g; }
            if (s != 'Paid') { balance += g - (ar.get('p') == null ? 0 : (Decimal) ar.get('p')); }
        }
        out.put('byStatus', byStatus);
        out.put('projected', projected);
        out.put('earned', earned);
        out.put('paid', paid);
        out.put('balance', balance);
        out.put('upcoming', [SELECT Id, Name, TC_Deal__r.Name, TC_Broker__r.Name, TC_Account__r.Name, RecordType.Name, TC_Gross_Commission__c, TC_Due_Date__c, TC_Status__c
                             FROM TC_Commission__c WHERE TC_Status__c IN ('Earned', 'Invoiced') WITH USER_MODE ORDER BY TC_Due_Date__c NULLS LAST LIMIT 10]);
        return out;
    }
}
