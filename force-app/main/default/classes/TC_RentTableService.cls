/**
 * Rent tables (TC_Deal_Period__c on deals, TC_Lease_Period__c on leases), mirroring the
 * AscendixRE Rent Table:
 *  - generate periods from term, rate, escalation and free rent (12-month periods by default)
 *  - calculate each period: duration, rent per month and total rent using the
 *    Annual Ratio Rent (default) or Monthly Rate method
 *  - review a table for gaps, overlaps and blank rent (non-blocking warnings)
 *  - copy a deal's rent table to the lease created when the deal closes
 */
public inherited sharing class TC_RentTableService {
    public static final String ANNUAL_RATIO = 'Annual Ratio Rent';
    public static final String MONTHLY_RATE = 'Monthly Rate';

    public class Terms {
        public Date commencement;
        public Date expiration;
        public Decimal size;
        public Decimal rate;            // $/SF/yr in year one
        public Decimal escalationPct;   // e.g. 3 = 3% per period
        public Integer periodMonths;    // default 12
        public Integer freeMonths;      // free rent at the start of the term
    }

    public class Period {
        public Integer periodNumber;
        public Date fromDate;
        public Date toDate;
        public Decimal rate;
        public Boolean freeRent = false;
    }

    // ---------------------------------------------------------------- generation
    /** Builds the period schedule for a set of lease terms (no DML). */
    public static List<Period> buildSchedule(Terms t) {
        List<Period> result = new List<Period>();
        if (t == null || t.commencement == null || t.expiration == null || t.expiration < t.commencement) {
            return result;
        }
        Integer len = (t.periodMonths == null || t.periodMonths <= 0) ? 12 : t.periodMonths;
        Integer free = t.freeMonths == null ? 0 : Math.max(0, t.freeMonths);
        Decimal esc = t.escalationPct == null ? 0 : t.escalationPct / 100;
        Decimal rate = t.rate == null ? 0 : t.rate;
        Date start = t.commencement;
        Integer idx = 0;
        Integer n = 1;
        while (start <= t.expiration && idx < 600) {
            Date periodEnd = start.addMonths(len).addDays(-1);
            if (periodEnd > t.expiration) {
                periodEnd = t.expiration;
            }
            Decimal factor = Decimal.valueOf(Math.pow((1 + esc).doubleValue(), Double.valueOf(idx)));
            Decimal periodRate = (rate * factor).setScale(2, RoundingMode.HALF_UP);
            // Split the first period(s) to carve out free rent months.
            if (free > 0) {
                Date freeEnd = start.addMonths(Math.min(free, len)).addDays(-1);
                if (freeEnd > periodEnd) {
                    freeEnd = periodEnd;
                }
                Period fp = new Period();
                fp.periodNumber = n++;
                fp.fromDate = start;
                fp.toDate = freeEnd;
                fp.rate = periodRate;
                fp.freeRent = true;
                result.add(fp);
                free -= Math.min(free, len);
                if (freeEnd < periodEnd) {
                    Period rest = new Period();
                    rest.periodNumber = n++;
                    rest.fromDate = freeEnd.addDays(1);
                    rest.toDate = periodEnd;
                    rest.rate = periodRate;
                    result.add(rest);
                }
            } else {
                Period p = new Period();
                p.periodNumber = n++;
                p.fromDate = start;
                p.toDate = periodEnd;
                p.rate = periodRate;
                result.add(p);
            }
            start = periodEnd.addDays(1);
            idx++;
        }
        return result;
    }

    /** Converts a schedule into Deal or Lease Period records for the given parent. */
    public static List<SObject> toRecords(List<Period> schedule, Id parentId) {
        List<SObject> records = new List<SObject>();
        Boolean isDeal = parentId.getSObjectType() == TC_Deal__c.SObjectType;
        for (Period p : schedule) {
            SObject rec = isDeal ? (SObject) new TC_Deal_Period__c(TC_Deal__c = parentId) : (SObject) new TC_Lease_Period__c(TC_Lease__c = parentId);
            rec.put('TC_Period_Number__c', p.periodNumber);
            rec.put('TC_From__c', p.fromDate);
            rec.put('TC_To__c', p.toDate);
            rec.put('TC_Rate__c', p.rate);
            rec.put('TC_Free_Rent__c', p.freeRent);
            records.add(rec);
        }
        return records;
    }

    /** Generates (replacing any existing) rent table rows for leases. Returns rows inserted. */
    public static Integer generateForLeases(Set<Id> leaseIds, Boolean replaceExisting) {
        if (leaseIds == null || leaseIds.isEmpty()) {
            return 0;
        }
        List<TC_Lease__c> leases = [
            SELECT Id, TC_Commencement_Date__c, TC_Expiration_Date__c, TC_Size__c, TC_Lease_Rate__c,
                   TC_Escalation__c, TC_Period_Length_Months__c, TC_Free_Rent_Months__c,
                   (SELECT Id FROM Lease_Periods__r)
            FROM TC_Lease__c WHERE Id IN :leaseIds
        ];
        List<SObject> toDelete = new List<SObject>();
        List<SObject> toInsert = new List<SObject>();
        for (TC_Lease__c l : leases) {
            if (!l.Lease_Periods__r.isEmpty()) {
                if (!replaceExisting) {
                    continue;
                }
                toDelete.addAll(l.Lease_Periods__r);
            }
            Terms t = new Terms();
            t.commencement = l.TC_Commencement_Date__c;
            t.expiration = l.TC_Expiration_Date__c;
            t.size = l.TC_Size__c;
            t.rate = l.TC_Lease_Rate__c;
            t.escalationPct = l.TC_Escalation__c;
            t.periodMonths = l.TC_Period_Length_Months__c == null ? null : l.TC_Period_Length_Months__c.intValue();
            t.freeMonths = l.TC_Free_Rent_Months__c == null ? null : l.TC_Free_Rent_Months__c.intValue();
            toInsert.addAll(toRecords(buildSchedule(t), l.Id));
        }
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        return toInsert.size();
    }

    /** Generates (replacing any existing) rent table rows for deals. Returns rows inserted. */
    public static Integer generateForDeals(Set<Id> dealIds, Boolean replaceExisting) {
        if (dealIds == null || dealIds.isEmpty()) {
            return 0;
        }
        List<TC_Deal__c> deals = [
            SELECT Id, TC_Lease_Commencement__c, TC_Lease_Expiration__c, TC_Size__c, TC_Lease_Rate__c,
                   TC_Escalation__c, TC_Period_Length_Months__c, TC_Free_Rent_Months__c,
                   (SELECT Id FROM Deal_Periods__r)
            FROM TC_Deal__c WHERE Id IN :dealIds
        ];
        List<SObject> toDelete = new List<SObject>();
        List<SObject> toInsert = new List<SObject>();
        for (TC_Deal__c d : deals) {
            if (!d.Deal_Periods__r.isEmpty()) {
                if (!replaceExisting) {
                    continue;
                }
                toDelete.addAll(d.Deal_Periods__r);
            }
            Terms t = new Terms();
            t.commencement = d.TC_Lease_Commencement__c;
            t.expiration = d.TC_Lease_Expiration__c;
            t.size = d.TC_Size__c;
            t.rate = d.TC_Lease_Rate__c;
            t.escalationPct = d.TC_Escalation__c;
            t.periodMonths = d.TC_Period_Length_Months__c == null ? null : d.TC_Period_Length_Months__c.intValue();
            t.freeMonths = d.TC_Free_Rent_Months__c == null ? null : d.TC_Free_Rent_Months__c.intValue();
            toInsert.addAll(toRecords(buildSchedule(t), d.Id));
        }
        if (!toDelete.isEmpty()) {
            delete toDelete;
        }
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        return toInsert.size();
    }

    // ---------------------------------------------------------------- calculation
    /**
     * Before insert/update on period records: fills Duration, Rent Per Month and Total Rent.
     * parentField is TC_Deal__c or TC_Lease__c.
     */
    public static void calculate(List<SObject> periods, String parentField) {
        Set<Id> parentIds = TC_TriggerHandler.idsOf(periods, parentField);
        Map<Id, SObject> parents = new Map<Id, SObject>();
        if (!parentIds.isEmpty()) {
            String obj = parentField == 'TC_Deal__c' ? 'TC_Deal__c' : 'TC_Lease__c';
            for (SObject p : Database.query('SELECT Id, TC_Size__c, TC_Total_Rent_Calculation__c FROM ' + obj + ' WHERE Id IN :parentIds')) {
                parents.put(p.Id, p);
            }
        }
        for (SObject rec : periods) {
            SObject parent = parents.get((Id) rec.get(parentField));
            Decimal size = parent == null ? null : (Decimal) parent.get('TC_Size__c');
            String method = parent == null ? null : (String) parent.get('TC_Total_Rent_Calculation__c');
            calculateOne(rec, size, method);
        }
    }

    @TestVisible
    private static void calculateOne(SObject rec, Decimal size, String method) {
        Date f = (Date) rec.get('TC_From__c');
        Date t = (Date) rec.get('TC_To__c');
        if (f == null || t == null || t < f) {
            return;
        }
        Decimal duration = durationMonths(f, t);
        rec.put('TC_Duration_Months__c', duration);
        Decimal rate = (Decimal) rec.get('TC_Rate__c');
        Decimal perMonth = (Decimal) rec.get('TC_Rent_Per_Month__c');
        if (rate != null && size != null) {
            perMonth = (rate * size / 12).setScale(2, RoundingMode.HALF_UP);
            rec.put('TC_Rent_Per_Month__c', perMonth);
        }
        Boolean free = rec.get('TC_Free_Rent__c') == true;
        if (free || perMonth == null) {
            rec.put('TC_Total_Rent__c', free ? 0 : null);
            return;
        }
        Decimal total;
        if (method == MONTHLY_RATE) {
            total = duration * perMonth;
        } else {
            Integer days = f.daysBetween(t) + 1;
            Integer daysInYear = Date.isLeapYear(f.year()) ? 366 : 365;
            total = (Decimal.valueOf(days) / daysInYear) * perMonth * 12;
        }
        rec.put('TC_Total_Rent__c', total.setScale(2, RoundingMode.HALF_UP));
    }

    /** Whole months plus a fraction of a 30-day month, to 2 decimals. */
    public static Decimal durationMonths(Date f, Date t) {
        Date endExclusive = t.addDays(1);
        Integer months = f.monthsBetween(endExclusive);
        if (f.addMonths(months) > endExclusive) {
            months--;
        }
        Integer remDays = f.addMonths(months).daysBetween(endExclusive);
        return (months + Decimal.valueOf(remDays) / 30).setScale(2, RoundingMode.HALF_UP);
    }

    // ---------------------------------------------------------------- review
    /** Non-blocking review: gaps, overlaps and blank rent. Returns human-readable warnings. */
    public static List<String> review(List<SObject> periods) {
        List<String> warnings = new List<String>();
        List<SObject> sorted = sortByFrom(periods);
        for (Integer i = 0; i < sorted.size(); i++) {
            SObject p = sorted[i];
            if (p.get('TC_Free_Rent__c') != true && p.get('TC_Rate__c') == null && p.get('TC_Rent_Per_Month__c') == null) {
                warnings.add('Period ' + label(p, i) + ' has no rent.');
            }
            if (i > 0) {
                Date prevTo = (Date) sorted[i - 1].get('TC_To__c');
                Date thisFrom = (Date) p.get('TC_From__c');
                if (prevTo != null && thisFrom != null) {
                    if (thisFrom > prevTo.addDays(1)) {
                        warnings.add('Gap between ' + prevTo.format() + ' and ' + thisFrom.format() + '.');
                    } else if (thisFrom <= prevTo) {
                        warnings.add('Period ' + label(p, i) + ' overlaps the previous period.');
                    }
                }
            }
        }
        return warnings;
    }

    private static String label(SObject p, Integer i) {
        Object n = p.get('TC_Period_Number__c');
        return n == null ? String.valueOf(i + 1) : String.valueOf(((Decimal) n).intValue());
    }

    private static List<SObject> sortByFrom(List<SObject> periods) {
        List<SObject> remaining = new List<SObject>(periods);
        List<SObject> sorted = new List<SObject>();
        while (!remaining.isEmpty()) {
            Integer best = 0;
            for (Integer i = 1; i < remaining.size(); i++) {
                Date a = (Date) remaining[i].get('TC_From__c');
                Date b = (Date) remaining[best].get('TC_From__c');
                if (a != null && (b == null || a < b)) {
                    best = i;
                }
            }
            sorted.add(remaining.remove(best));
        }
        return sorted;
    }

    // ---------------------------------------------------------------- inheritance
    /** Copies each deal's rent table to its lease. dealToLease maps Deal Id -> Lease Id. */
    public static void copyDealPeriodsToLeases(Map<Id, Id> dealToLease) {
        if (dealToLease == null || dealToLease.isEmpty()) {
            return;
        }
        Set<Id> dealIds = dealToLease.keySet();
        List<TC_Lease_Period__c> copies = new List<TC_Lease_Period__c>();
        for (TC_Deal_Period__c dp : [
            SELECT TC_Deal__c, TC_Period_Number__c, TC_From__c, TC_To__c, TC_Rate__c, TC_Rent_Per_Month__c, TC_Free_Rent__c
            FROM TC_Deal_Period__c WHERE TC_Deal__c IN :dealIds ORDER BY TC_From__c
        ]) {
            copies.add(new TC_Lease_Period__c(
                TC_Lease__c = dealToLease.get(dp.TC_Deal__c),
                TC_Period_Number__c = dp.TC_Period_Number__c,
                TC_From__c = dp.TC_From__c,
                TC_To__c = dp.TC_To__c,
                TC_Rate__c = dp.TC_Rate__c,
                TC_Rent_Per_Month__c = dp.TC_Rent_Per_Month__c,
                TC_Free_Rent__c = dp.TC_Free_Rent__c
            ));
        }
        if (!copies.isEmpty()) {
            insert copies;
        }
    }

    /** Estimated total rent over the term without saved periods (used for deal value). */
    public static Decimal estimateTotal(Terms t, String method) {
        Decimal total = 0;
        for (Period p : buildSchedule(t)) {
            if (p.freeRent || t.size == null) {
                continue;
            }
            SObject tmp = new TC_Deal_Period__c(TC_From__c = p.fromDate, TC_To__c = p.toDate, TC_Rate__c = p.rate);
            calculateOne(tmp, t.size, method);
            Decimal v = (Decimal) tmp.get('TC_Total_Rent__c');
            total += v == null ? 0 : v;
        }
        return total;
    }
}
