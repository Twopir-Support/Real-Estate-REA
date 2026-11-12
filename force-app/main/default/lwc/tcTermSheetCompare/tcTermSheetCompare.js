import { LightningElement, api, wire } from 'lwc';
import getTermSheets from '@salesforce/apex/TC_DealUIController.getTermSheets';
import { formatCurrency, formatDate, reduceErrors } from 'c/tcUtils';

const ROWS = [
    { key: 'lender', label: 'Lender', get: (t) => t.TC_Lender_Name__c },
    { key: 'quote', label: 'Quote date', get: (t) => formatDate(t.TC_Quote_Date__c) },
    { key: 'amount', label: 'Loan amount', get: (t) => formatCurrency(t.TC_Loan_Amount__c) },
    { key: 'rate', label: 'Interest rate', get: (t) => (t.TC_Interest_Rate__c != null ? `${Number(t.TC_Interest_Rate__c).toFixed(3)}%` : '—'), best: 'min', num: (t) => t.TC_Interest_Rate__c },
    { key: 'type', label: 'Rate type', get: (t) => t.TC_Rate_Type__c || '—' },
    { key: 'term', label: 'Term (years)', get: (t) => t.TC_Term_Years__c ?? '—' },
    { key: 'amort', label: 'Amortization (years)', get: (t) => t.TC_Amortization_Years__c ?? '—' },
    { key: 'ltv', label: 'LTV', get: (t) => (t.TC_LTV__c != null ? `${t.TC_LTV__c}%` : '—'), best: 'max', num: (t) => t.TC_LTV__c },
    { key: 'dscr', label: 'DSCR', get: (t) => t.TC_DSCR__c ?? '—' },
    { key: 'recourse', label: 'Recourse', get: (t) => t.TC_Recourse__c || '—' },
    { key: 'fee', label: 'Origination fee', get: (t) => (t.TC_Origination_Fee__c != null ? `${t.TC_Origination_Fee__c}%` : '—'), best: 'min', num: (t) => t.TC_Origination_Fee__c },
    { key: 'prepay', label: 'Prepayment', get: (t) => t.TC_Prepayment__c || '—' },
    { key: 'status', label: 'Source status', get: (t) => (t.TC_Deal_Source__r ? t.TC_Deal_Source__r.TC_Status__c : '—') }
];

/** Side-by-side comparison of every term sheet on a capital markets deal; best values highlighted. */
export default class TcTermSheetCompare extends LightningElement {
    @api recordId;
    sheets = [];
    error;

    @wire(getTermSheets, { dealId: '$recordId' })
    wired({ data, error }) {
        if (data) { this.sheets = data; this.error = undefined; }
        if (error) { this.error = reduceErrors(error); }
    }

    get hasSheets() { return this.sheets.length > 0; }
    get headers() { return this.sheets.map((s) => ({ key: s.Id, label: s.Name, link: '/' + s.Id })); }
    get rows() {
        return ROWS.map((r) => {
            let bestVal;
            if (r.best) {
                const vals = this.sheets.map(r.num).filter((v) => v !== null && v !== undefined);
                if (vals.length > 1) bestVal = r.best === 'min' ? Math.min(...vals) : Math.max(...vals);
            }
            return {
                key: r.key,
                label: r.label,
                cells: this.sheets.map((s) => ({ key: `${r.key}-${s.Id}`, value: r.get(s), cls: bestVal !== undefined && r.num(s) === bestVal ? 'best' : '' }))
            };
        });
    }
}
