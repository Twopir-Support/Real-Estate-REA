/**
 * Base class for every TC trigger handler.
 * One logic-less trigger per object calls new XxxHandler().run(); the handler routes the
 * trigger context to the overridden methods. Honours the TC_Bypass_Settings__c hierarchy
 * setting (for data loads) and a per-handler programmatic bypass.
 */
public virtual inherited sharing class TC_TriggerHandler {
    private static Set<String> bypassedHandlers = new Set<String>();

    public static void bypass(String handlerName) { bypassedHandlers.add(handlerName); }
    public static void clearBypass(String handlerName) { bypassedHandlers.remove(handlerName); }

    /** True when the org/user/profile-level bypass setting switches TC triggers off. */
    public static Boolean triggersBypassed() {
        TC_Bypass_Settings__c s = TC_Bypass_Settings__c.getInstance();
        return s != null && s.TC_Bypass_Triggers__c == true;
    }

    public void run() {
        if (triggersBypassed() || bypassedHandlers.contains(handlerName())) {
            return;
        }
        switch on Trigger.operationType {
            when BEFORE_INSERT { beforeInsert(Trigger.new); }
            when BEFORE_UPDATE { beforeUpdate(Trigger.new, Trigger.oldMap); }
            when BEFORE_DELETE { beforeDelete(Trigger.old); }
            when AFTER_INSERT { afterInsert(Trigger.new); }
            when AFTER_UPDATE { afterUpdate(Trigger.new, Trigger.oldMap); }
            when AFTER_DELETE { afterDelete(Trigger.old); }
            when AFTER_UNDELETE { afterUndelete(Trigger.new); }
        }
    }

    @TestVisible
    private String handlerName() {
        String n = String.valueOf(this).substringBefore(':');
        return n.contains('.') ? n.substringAfterLast('.') : n;
    }

    protected virtual void beforeInsert(List<SObject> newList) {}
    protected virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void beforeDelete(List<SObject> oldList) {}
    protected virtual void afterInsert(List<SObject> newList) {}
    protected virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    protected virtual void afterDelete(List<SObject> oldList) {}
    protected virtual void afterUndelete(List<SObject> newList) {}

    /** Helper: did any of the given fields change on this record? */
    protected Boolean changed(SObject rec, Map<Id, SObject> oldMap, List<String> fields) {
        if (oldMap == null) {
            return true;
        }
        SObject old = oldMap.get(rec.Id);
        for (String f : fields) {
            if (rec.get(f) != old.get(f)) {
                return true;
            }
        }
        return false;
    }

    /** Helper: collect non-null Id values of a field. */
    public static Set<Id> idsOf(List<SObject> records, String field) {
        Set<Id> ids = new Set<Id>();
        if (records == null) {
            return ids;
        }
        for (SObject r : records) {
            Object v = r.get(field);
            if (v != null) {
                ids.add((Id) v);
            }
        }
        return ids;
    }
}
