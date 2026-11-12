/**
 * Copies values from a source record to a target record using TC_Object_Field_Mapping__mdt
 * (static or dynamic mappings, optionally scoped by source record type). Mirrors the
 * AscendixRE Object Field Mapping engine used by the Close Deal process.
 */
public inherited sharing class TC_FieldMappingService {

    /** Does the mapping group apply to a source record of this record type? */
    public static Boolean groupApplies(String mappingGroup, String sourceRecordTypeDevName) {
        for (TC_Object_Field_Mapping__mdt m : TC_Settings.fieldMappings(mappingGroup)) {
            if (String.isBlank(m.TC_Record_Types__c)
                    || TC_Settings.splitList(m.TC_Record_Types__c).contains(sourceRecordTypeDevName)) {
                return true;
            }
        }
        return false;
    }

    /** Source field API names (dynamic mappings only) needed to apply a group. */
    public static Set<String> sourceFields(String mappingGroup) {
        Set<String> fields = new Set<String>();
        for (TC_Object_Field_Mapping__mdt m : TC_Settings.fieldMappings(mappingGroup)) {
            if (String.isNotBlank(m.TC_Source_Field__c)) {
                fields.add(m.TC_Source_Field__c);
            }
        }
        return fields;
    }

    /**
     * Applies a mapping group. When onlyBlankTargets is true, target fields that already
     * hold a value are left alone (used for "prefill on create" behaviour).
     */
    public static SObject apply(String mappingGroup, SObject source, SObject target, String sourceRecordTypeDevName, Boolean onlyBlankTargets) {
        Map<String, Schema.SObjectField> targetFields = target.getSObjectType().getDescribe().fields.getMap();
        for (TC_Object_Field_Mapping__mdt m : TC_Settings.fieldMappings(mappingGroup)) {
            if (String.isNotBlank(m.TC_Record_Types__c) && sourceRecordTypeDevName != null
                    && !TC_Settings.splitList(m.TC_Record_Types__c).contains(sourceRecordTypeDevName)) {
                continue;
            }
            Schema.SObjectField tf = targetFields.get(m.TC_Target_Field__c.toLowerCase());
            if (tf == null) {
                continue;
            }
            if (onlyBlankTargets && target.get(m.TC_Target_Field__c) != null) {
                continue;
            }
            Object value;
            if (String.isNotBlank(m.TC_Static_Value__c)) {
                value = coerce(m.TC_Static_Value__c, tf.getDescribe().getType());
            } else if (source != null && String.isNotBlank(m.TC_Source_Field__c)) {
                value = source.get(m.TC_Source_Field__c);
            }
            if (value != null) {
                target.put(m.TC_Target_Field__c, value);
            }
        }
        return target;
    }

    @TestVisible
    private static Object coerce(String raw, Schema.DisplayType t) {
        switch on t {
            when BOOLEAN { return Boolean.valueOf(raw); }
            when DATE { return Date.valueOf(raw); }
            when DOUBLE, CURRENCY, PERCENT, INTEGER, LONG { return Decimal.valueOf(raw); }
            when else { return raw; }
        }
    }
}
