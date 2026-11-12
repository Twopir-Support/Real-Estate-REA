/**
 * Commission engine (TC_Commission__c, child of TC_Deal__c).
 *
 *  Deal Gross Fee (TC_Gross_Fee_Amount__c)
 *    - Co-Broker and Expense commissions are paid out of the gross fee first
 *      (Fee Percent of the gross fee, or a fixed Fee Amount)
 *    = Net Deal Fee (TC_Net_Deal_Fee__c)
 *    - Inside Broker and Analyst commissions share the net deal fee by Fee Percent
 *      (or a fixed Fee Amount)
 *  House = Inside Broker gross commission x Fee Percent (House)
 *  Net Commission (formula) = Gross - House - Direct Expenses
 *
 * Validations (per TC_Automation_Setting__mdt, mirroring AscendixRE):
 *  - TC_VAL_Commission_Split_100: Analyst + Co-Broker + Expense percents may not exceed 100%
 *  - Inside Broker percents may never exceed 100%
 */
public inherited sharing class TC_CommissionService {
    public static final String INSIDE = 'TC_Inside_Broker';
    public static final String ANALYST = 'TC_Analyst';
    public static final String CO_BROKER = 'TC_Co_Broker';
    public static final String EXPENSE = 'TC_Expense';

    @TestVisible
    private static Boolean running = false;

    public static String rtName(TC_Commission__c c) {
        return TC_Settings.recordTypeDevName(TC_Commission__c.SObjectType, c.RecordTypeId);
    }

    /** Before insert/update: default record type, fee method and house percent; validate split totals. */
    public static void validateAndDefault(List<TC_Commission__c> commissions) {
        Id insideRt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, INSIDE);
        for (TC_Commission__c c : commissions) {
            if (c.RecordTypeId == null) {
                c.RecordTypeId = insideRt;
            }
            if (String.isBlank(c.TC_Fee_Method__c)) {
                c.TC_Fee_Method__c = 'Percent';
            }
            if (String.isBlank(c.TC_Status__c)) {
                c.TC_Status__c = 'Projected';
            }
        }
        if (running) {
            return;
        }
        Set<Id> dealIds = TC_TriggerHandler.idsOf(commissions, 'TC_Deal__c');
        Map<Id, Decimal> outsideTotal = new Map<Id, Decimal>();
        Map<Id, Decimal> insideTotal = new Map<Id, Decimal>();
        Set<Id> inTrigger = new Set<Id>();
        for (TC_Commission__c c : commissions) {
            if (c.Id != null) {
                inTrigger.add(c.Id);
            }
        }
        for (TC_Commission__c c : [SELECT Id, TC_Deal__c, RecordTypeId, TC_Fee_Method__c, TC_Fee_Percent__c FROM TC_Commission__c WHERE TC_Deal__c IN :dealIds AND Id NOT IN :inTrigger]) {
            accumulate(c, outsideTotal, insideTotal);
        }
        for (TC_Commission__c c : commissions) {
            accumulate(c, outsideTotal, insideTotal);
        }
        Boolean checkOutside = TC_Settings.isActive('TC_VAL_Commission_Split_100');
        for (TC_Commission__c c : commissions) {
            String rt = rtName(c);
            if (rt == INSIDE && insideTotal.get(c.TC_Deal__c) > 100) {
                c.addError('Inside Broker fee percents on this deal would total ' + insideTotal.get(c.TC_Deal__c).setScale(2) + '%. They cannot exceed 100%.');
            } else if (rt != INSIDE && checkOutside && outsideTotal.get(c.TC_Deal__c) > 100) {
                c.addError('Analyst, Co-Broker and Expense splits on this deal would total ' + outsideTotal.get(c.TC_Deal__c).setScale(2) + '%. They cannot exceed 100%.');
            }
        }
    }

    private static void accumulate(TC_Commission__c c, Map<Id, Decimal> outsideTotal, Map<Id, Decimal> insideTotal) {
        if (c.TC_Fee_Method__c == 'Amount') {
            if (!outsideTotal.containsKey(c.TC_Deal__c)) { outsideTotal.put(c.TC_Deal__c, 0); }
            if (!insideTotal.containsKey(c.TC_Deal__c)) { insideTotal.put(c.TC_Deal__c, 0); }
            return;
        }
        Decimal pct = c.TC_Fee_Percent__c == null ? 0 : c.TC_Fee_Percent__c;
        Map<Id, Decimal> target = rtName(c) == INSIDE ? insideTotal : outsideTotal;
        Map<Id, Decimal> other = rtName(c) == INSIDE ? outsideTotal : insideTotal;
        target.put(c.TC_Deal__c, (target.containsKey(c.TC_Deal__c) ? target.get(c.TC_Deal__c) : 0) + pct);
        if (!other.containsKey(c.TC_Deal__c)) {
            other.put(c.TC_Deal__c, 0);
        }
    }

    /** Recalculates gross/house on every commission of the deals, and the deal's net fee totals. */
    public static void recalculate(Set<Id> dealIds) {
        if (running || dealIds == null || dealIds.isEmpty()) {
            return;
        }
        running = true;
        try {
            Map<Id, TC_Deal__c> deals = new Map<Id, TC_Deal__c>([
                SELECT Id, TC_Gross_Fee_Amount__c, TC_Net_Deal_Fee__c, TC_Total_Commission_Split__c,
                       (SELECT Id, RecordTypeId, TC_Fee_Method__c, TC_Fee_Percent__c, TC_Fee_Amount__c, TC_House_Fee_Percent__c,
                               TC_Gross_Commission__c, TC_House__c
                        FROM Commissions__r)
                FROM TC_Deal__c WHERE Id IN :dealIds
            ]);
            List<TC_Commission__c> commUpdates = new List<TC_Commission__c>();
            List<TC_Deal__c> dealUpdates = new List<TC_Deal__c>();
            for (TC_Deal__c d : deals.values()) {
                Decimal fee = d.TC_Gross_Fee_Amount__c == null ? 0 : d.TC_Gross_Fee_Amount__c;
                Decimal outsidePaid = 0;
                Decimal insidePct = 0;
                Map<Id, Decimal> gross = new Map<Id, Decimal>();
                for (TC_Commission__c c : d.Commissions__r) {
                    String rt = rtName(c);
                    if (rt == CO_BROKER || rt == EXPENSE) {
                        Decimal g = amountOrPercent(c, fee);
                        gross.put(c.Id, g);
                        outsidePaid += g;
                    }
                }
                Decimal netFee = fee - outsidePaid;
                for (TC_Commission__c c : d.Commissions__r) {
                    String rt = rtName(c);
                    if (rt == INSIDE || rt == ANALYST) {
                        gross.put(c.Id, amountOrPercent(c, netFee));
                        if (rt == INSIDE && c.TC_Fee_Method__c != 'Amount' && c.TC_Fee_Percent__c != null) {
                            insidePct += c.TC_Fee_Percent__c;
                        }
                    }
                }
                for (TC_Commission__c c : d.Commissions__r) {
                    Decimal g = gross.get(c.Id);
                    Decimal house = (rtName(c) == INSIDE && g != null && c.TC_House_Fee_Percent__c != null)
                        ? (g * c.TC_House_Fee_Percent__c / 100).setScale(2, RoundingMode.HALF_UP) : (rtName(c) == INSIDE ? 0 : null);
                    if (g != c.TC_Gross_Commission__c || house != c.TC_House__c) {
                        commUpdates.add(new TC_Commission__c(Id = c.Id, TC_Gross_Commission__c = g, TC_House__c = house));
                    }
                }
                if (netFee != d.TC_Net_Deal_Fee__c || insidePct != d.TC_Total_Commission_Split__c) {
                    dealUpdates.add(new TC_Deal__c(Id = d.Id, TC_Net_Deal_Fee__c = netFee, TC_Total_Commission_Split__c = insidePct));
                }
            }
            if (!commUpdates.isEmpty()) {
                update commUpdates;
            }
            if (!dealUpdates.isEmpty()) {
                update dealUpdates;
            }
        } finally {
            running = false;
        }
    }

    private static Decimal amountOrPercent(TC_Commission__c c, Decimal base) {
        if (c.TC_Fee_Method__c == 'Amount') {
            return c.TC_Fee_Amount__c;
        }
        if (c.TC_Fee_Percent__c == null || base == null) {
            return null;
        }
        return (base * c.TC_Fee_Percent__c / 100).setScale(2, RoundingMode.HALF_UP);
    }

    /** Deal Won -> Projected commissions become Earned; Lost -> unpaid commissions are Cancelled. */
    public static void applyDealStatus(Set<Id> dealIds) {
        List<TC_Commission__c> updates = new List<TC_Commission__c>();
        for (TC_Commission__c c : [SELECT Id, TC_Status__c, TC_Deal__r.TC_Status__c FROM TC_Commission__c WHERE TC_Deal__c IN :dealIds]) {
            String dealStatus = c.TC_Deal__r.TC_Status__c;
            if (dealStatus == 'Won' && c.TC_Status__c == 'Projected') {
                updates.add(new TC_Commission__c(Id = c.Id, TC_Status__c = 'Earned'));
            } else if (dealStatus == 'Lost' && c.TC_Status__c != 'Paid' && c.TC_Status__c != 'Cancelled') {
                updates.add(new TC_Commission__c(Id = c.Id, TC_Status__c = 'Cancelled'));
            } else if (dealStatus == 'Open' && (c.TC_Status__c == 'Earned' || c.TC_Status__c == 'Cancelled')) {
                updates.add(new TC_Commission__c(Id = c.Id, TC_Status__c = 'Projected'));
            }
        }
        if (!updates.isEmpty()) {
            Boolean prev = running;
            running = true;
            try {
                update updates;
            } finally {
                running = prev;
            }
        }
    }

    /** Builds unsaved commission rows for the bulk-entry grid (up to 30 at once, as in AscendixRE). */
    public static List<TC_Commission__c> newRows(Id dealId, String recordTypeDevName, Integer count) {
        Integer n = Math.min(Math.max(count == null ? 1 : count, 1), 30);
        Id rt = TC_Settings.recordTypeId(TC_Commission__c.SObjectType, recordTypeDevName);
        List<TC_Commission__c> rows = new List<TC_Commission__c>();
        for (Integer i = 0; i < n; i++) {
            rows.add(new TC_Commission__c(TC_Deal__c = dealId, RecordTypeId = rt, TC_Fee_Method__c = 'Percent', TC_Status__c = 'Projected'));
        }
        return rows;
    }
}
