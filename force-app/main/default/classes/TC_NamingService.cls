/**
 * Builds record names from TC_Object_Name_Mapping__mdt (format like "{0} - {1}").
 * Source fields may be local fields, a parent's Name via "Lookup__r.Name", or "RecordType.Name".
 * Runs in before insert/update. Only fills blank names unless the mapping says Overwrite.
 */
public inherited sharing class TC_NamingService {

    public static void apply(List<SObject> records, SObjectType objType) {
        if (!TC_Settings.isActive('TC_AUTO_Record_Naming')) {
            return;
        }
        String objName = objType.getDescribe().getName();
        TC_Object_Name_Mapping__mdt mapping = TC_Settings.nameMapping(objName);
        if (mapping == null || String.isBlank(mapping.TC_Format__c)) {
            return;
        }
        List<SObject> targets = new List<SObject>();
        for (SObject r : records) {
            String current = (String) r.get('Name');
            if (mapping.TC_Overwrite__c || String.isBlank(current) || current == '-' || (r.Id != null && current == String.valueOf(r.Id))) {
                targets.add(r);
            }
        }
        if (targets.isEmpty()) {
            return;
        }
        List<String> paths = new List<String>(mapping.TC_Source_Fields__c.split(','));
        // Resolve parent Names in bulk: lookup field -> (Id -> Name)
        Map<String, Map<Id, String>> parentNames = new Map<String, Map<Id, String>>();
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        for (String p : paths) {
            p = p.trim();
            if (p.contains('__r.')) {
                String lookupField = p.substringBefore('__r.') + '__c';
                Schema.SObjectField f = fieldMap.get(lookupField.toLowerCase());
                if (f == null) {
                    continue;
                }
                Set<Id> ids = TC_TriggerHandler.idsOf(targets, lookupField);
                Map<Id, String> names = new Map<Id, String>();
                if (!ids.isEmpty()) {
                    String refObj = f.getDescribe().getReferenceTo()[0].getDescribe().getName();
                    for (SObject parent : Database.query('SELECT Id, Name FROM ' + refObj + ' WHERE Id IN :ids')) {
                        names.put(parent.Id, (String) parent.get('Name'));
                    }
                }
                parentNames.put(lookupField, names);
            }
        }
        for (SObject r : targets) {
            List<String> values = new List<String>();
            for (String p : paths) {
                values.add(resolve(r, p.trim(), objType, parentNames, mapping.TC_Default_Value__c));
            }
            String name = String.format(mapping.TC_Format__c, values).normalizeSpace();
            name = name.removeEnd(' -').removeEnd('()').trim();
            r.put('Name', name.left(80));
        }
    }

    private static String resolve(SObject r, String path, SObjectType objType, Map<String, Map<Id, String>> parentNames, String defaultValue) {
        Object v;
        if (path == 'RecordType.Name') {
            Id rtId = (Id) r.get('RecordTypeId');
            Schema.RecordTypeInfo info = rtId == null ? null : objType.getDescribe().getRecordTypeInfosById().get(rtId);
            v = info == null ? null : info.getName();
        } else if (path.contains('__r.')) {
            String lookupField = path.substringBefore('__r.') + '__c';
            Id parentId = (Id) r.get(lookupField);
            Map<Id, String> names = parentNames.get(lookupField);
            v = (parentId == null || names == null) ? null : names.get(parentId);
        } else {
            v = r.get(path);
        }
        if (v == null) {
            return defaultValue == null ? '' : defaultValue;
        }
        if (v instanceof Date) {
            return ((Date) v).format();
        }
        if (v instanceof Decimal) {
            return ((Decimal) v).setScale(0).format();
        }
        return String.valueOf(v);
    }
}
