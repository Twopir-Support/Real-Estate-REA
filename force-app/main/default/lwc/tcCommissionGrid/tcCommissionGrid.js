import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getCommissions from '@salesforce/apex/TC_DealUIController.getCommissions';
import newCommissionRows from '@salesforce/apex/TC_DealUIController.newCommissionRows';
import saveCommissions from '@salesforce/apex/TC_DealUIController.saveCommissions';
import { formatCurrency, reduceErrors } from 'c/tcUtils';

/** Commission grid on the Deal: totals, existing splits with inline edit, and bulk entry of up to 30 rows of one type. */
export default class TcCommissionGrid extends LightningElement {
    @api recordId;
    data;
    rows = [];
    draftValues = [];
    newRows = [];
    newType = 'TC_Inside_Broker';
    newCount = 1;
    loading = true;
    error;

    connectedCallback() { this.load(); }

    async load() {
        this.loading = true;
        try {
            this.data = await getCommissions({ dealId: this.recordId });
            this.rows = this.data.rows.map((r) => ({
                ...r,
                typeName: r.RecordType ? r.RecordType.Name : '',
                payee: r.TC_Broker__r ? r.TC_Broker__r.Name : r.TC_Contact__r ? r.TC_Contact__r.Name : r.TC_Account__r ? r.TC_Account__r.Name : '',
                link: '/' + r.Id
            }));
            this.error = undefined;
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    get columns() {
        const cols = [
            { label: 'Commission', fieldName: 'link', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } },
            { label: 'Type', fieldName: 'typeName' },
            { label: 'Payee', fieldName: 'payee' },
            { label: 'Method', fieldName: 'TC_Fee_Method__c', initialWidth: 90 },
            { label: 'Fee %', fieldName: 'TC_Fee_Percent__c', type: 'number', editable: true, typeAttributes: { maximumFractionDigits: 3 }, initialWidth: 90 },
            { label: 'Fee Amount', fieldName: 'TC_Fee_Amount__c', type: 'currency', editable: true },
            { label: 'Gross', fieldName: 'TC_Gross_Commission__c', type: 'currency' }
        ];
        if (this.data && this.data.canSeeHouse) {
            cols.push({ label: 'House %', fieldName: 'TC_House_Fee_Percent__c', type: 'number', editable: true, initialWidth: 90 });
            cols.push({ label: 'House', fieldName: 'TC_House__c', type: 'currency' });
            cols.push({ label: 'Net', fieldName: 'TC_Net_Commission__c', type: 'currency' });
        }
        cols.push({ label: 'Status', fieldName: 'TC_Status__c', initialWidth: 100 });
        return cols;
    }

    get summary() {
        const d = (this.data && this.data.deal) || {};
        return [
            { key: 'g', label: 'Gross fee', value: formatCurrency(d.TC_Gross_Fee_Amount__c) },
            { key: 'n', label: 'Net deal fee', value: formatCurrency(d.TC_Net_Deal_Fee__c) },
            { key: 's', label: 'Inside broker split', value: `${Number(d.TC_Total_Commission_Split__c || 0).toFixed(2)}%`, warn: Number(d.TC_Total_Commission_Split__c || 0) !== 100 && this.rows.length > 0 }
        ].map((s) => ({ ...s, cls: s.warn ? 'sum-item sum-item_warn' : 'sum-item' }));
    }
    get hasRows() { return this.rows.length > 0; }
    get typeOptions() { return ((this.data && this.data.recordTypes) || []).map((t) => ({ label: t.label, value: t.value })); }
    get hasNewRows() { return this.newRows.length > 0; }
    get newTypeLabel() { const t = this.typeOptions.find((o) => o.value === this.newType); return t ? t.label : ''; }
    get isUserType() { return this.newType === 'TC_Inside_Broker'; }
    get showHouse() { return this.isUserType && this.data && this.data.canSeeHouse; }

    handleNewType(e) { this.newType = e.detail.value; }
    handleNewCount(e) { this.newCount = Number(e.detail.value); }

    async addRows() {
        try {
            const rows = await newCommissionRows({ dealId: this.recordId, recordTypeDevName: this.newType, count: this.newCount });
            this.newRows = rows.map((r, i) => ({ ...r, key: `n${Date.now()}${i}` }));
        } catch (e) {
            this.toast('Could not add rows', reduceErrors(e), 'error');
        }
    }
    cancelNew() { this.newRows = []; }

    handleNewField(e) {
        const { key, field } = e.target.dataset;
        const value = e.detail.recordId !== undefined ? e.detail.recordId : e.detail.value;
        this.newRows = this.newRows.map((r) => (r.key === key ? { ...r, [field]: value } : r));
    }

    async saveNew() {
        const rows = this.newRows.map(({ key, ...rest }) => rest).filter((r) => r.TC_Fee_Percent__c || r.TC_Fee_Amount__c);
        if (!rows.length) {
            this.toast('Nothing to save', 'Enter a fee percent or amount on at least one row.', 'warning');
            return;
        }
        await this.persist(rows, () => { this.newRows = []; });
    }

    async handleSave(e) {
        const rows = e.detail.draftValues.map((d) => ({ ...d, sobjectType: 'TC_Commission__c' }));
        await this.persist(rows, () => { this.draftValues = []; });
    }

    async persist(rows, onDone) {
        this.loading = true;
        try {
            await saveCommissions({ rows });
            onDone();
            this.toast('Commissions saved', `${rows.length} commission(s) saved.`, 'success');
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            await this.load();
        } catch (err) {
            this.loading = false;
            this.toast('Could not save commissions', reduceErrors(err), 'error');
        }
    }

    toast(title, message, variant) { this.dispatchEvent(new ShowToastEvent({ title, message, variant })); }
}
