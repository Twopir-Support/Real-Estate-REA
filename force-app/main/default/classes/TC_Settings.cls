/**
 * Cached, test-overridable access to TC configuration held in custom metadata:
 * automation toggles, deal stage probabilities, object field mappings and name formats.
 */
public inherited sharing class TC_Settings {
    @TestVisible
    private static Map<String, Boolean> automationOverrides = new Map<String, Boolean>();

    private static Map<String, Decimal> stageProbabilityCache;

    /** Is the named automation/validation active (optionally for a record type DeveloperName)? */
    public static Boolean isActive(String settingName, String recordTypeDevName) {
        if (automationOverrides.containsKey(settingName)) {
            return automationOverrides.get(settingName);
        }
        TC_Automation_Setting__mdt s = TC_Automation_Setting__mdt.getInstance(settingName);
        if (s == null || !s.TC_Active__c) {
            return false;
        }
        if (String.isBlank(s.TC_Record_Types__c) || String.isBlank(recordTypeDevName)) {
            return true;
        }
        return splitList(s.TC_Record_Types__c).contains(recordTypeDevName);
    }

    public static Boolean isActive(String settingName) {
        return isActive(settingName, null);
    }

    /** Default probability (0-100) for a deal stage, or null when the stage is unknown. */
    public static Decimal stageProbability(String stage) {
        if (stageProbabilityCache == null) {
            stageProbabilityCache = new Map<String, Decimal>();
            for (TC_Deal_Stage_Setting__mdt s : TC_Deal_Stage_Setting__mdt.getAll().values()) {
                stageProbabilityCache.put(s.TC_Stage__c, s.TC_Probability__c);
            }
        }
        return stageProbabilityCache.get(stage);
    }

    /** Ordered list of deal stages (by sort order) for the pipeline UI. */
    public static List<String> orderedStages() {
        List<TC_Deal_Stage_Setting__mdt> rows = TC_Deal_Stage_Setting__mdt.getAll().values();
        Map<Decimal, String> byOrder = new Map<Decimal, String>();
        for (TC_Deal_Stage_Setting__mdt s : rows) {
            byOrder.put(s.TC_Sort_Order__c, s.TC_Stage__c);
        }
        List<Decimal> keys = new List<Decimal>(byOrder.keySet());
        keys.sort();
        List<String> stages = new List<String>();
        for (Decimal k : keys) {
            stages.add(byOrder.get(k));
        }
        return stages;
    }

    /** Active field mappings of a mapping group (e.g. DEAL_TO_LEASE), in DeveloperName order. */
    public static List<TC_Object_Field_Mapping__mdt> fieldMappings(String mappingGroup) {
        List<String> names = new List<String>();
        Map<String, TC_Object_Field_Mapping__mdt> byName = new Map<String, TC_Object_Field_Mapping__mdt>();
        for (TC_Object_Field_Mapping__mdt m : TC_Object_Field_Mapping__mdt.getAll().values()) {
            if (m.TC_Active__c && m.TC_Mapping_Group__c == mappingGroup) {
                names.add(m.DeveloperName);
                byName.put(m.DeveloperName, m);
            }
        }
        names.sort();
        List<TC_Object_Field_Mapping__mdt> result = new List<TC_Object_Field_Mapping__mdt>();
        for (String n : names) {
            result.add(byName.get(n));
        }
        return result;
    }

    /** Active name format for an object API name, or null. */
    public static TC_Object_Name_Mapping__mdt nameMapping(String objectApiName) {
        for (TC_Object_Name_Mapping__mdt m : TC_Object_Name_Mapping__mdt.getAll().values()) {
            if (m.TC_Active__c && m.TC_Object__c == objectApiName) {
                return m;
            }
        }
        return null;
    }

    /** Stacking plan configuration (Default record). */
    public static TC_Stacking_Plan_Setting__mdt stackingPlan() {
        return TC_Stacking_Plan_Setting__mdt.getInstance('TC_Default');
    }

    public static Set<String> splitList(String csv) {
        Set<String> out = new Set<String>();
        if (String.isBlank(csv)) {
            return out;
        }
        for (String s : csv.split(',')) {
            if (String.isNotBlank(s)) {
                out.add(s.trim());
            }
        }
        return out;
    }

    /** DeveloperName of a record type Id for the given object, or null. */
    public static String recordTypeDevName(SObjectType objType, Id recordTypeId) {
        if (recordTypeId == null) {
            return null;
        }
        Schema.RecordTypeInfo info = objType.getDescribe().getRecordTypeInfosById().get(recordTypeId);
        return info == null ? null : info.getDeveloperName();
    }

    public static Id recordTypeId(SObjectType objType, String devName) {
        Schema.RecordTypeInfo info = objType.getDescribe().getRecordTypeInfosByDeveloperName().get(devName);
        return info == null ? null : info.getRecordTypeId();
    }
}
