import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import getRentTable from '@salesforce/apex/TC_DealUIController.getRentTable';
import generateRentTable from '@salesforce/apex/TC_DealUIController.generateRentTable';
import { formatCurrency, reduceErrors } from 'c/tcUtils';

const COLUMNS = [
    { label: '#', fieldName: 'TC_Period_Number__c', type: 'number', initialWidth: 60 },
    { label: 'From', fieldName: 'TC_From__c', type: 'date-local', editable: true },
    { label: 'To', fieldName: 'TC_To__c', type: 'date-local', editable: true },
    { label: 'Months', fieldName: 'TC_Duration_Months__c', type: 'number', typeAttributes: { minimumFractionDigits: 2 } },
    { label: 'Rate ($/SF/yr)', fieldName: 'TC_Rate__c', type: 'currency', editable: true },
    { label: 'Rent / Month', fieldName: 'TC_Rent_Per_Month__c', type: 'currency', editable: true },
    { label: 'Total Rent', fieldName: 'TC_Total_Rent__c', type: 'currency' },
    { label: 'Free Rent', fieldName: 'TC_Free_Rent__c', type: 'boolean', editable: true, initialWidth: 90 }
];

/** Rent table for a Deal or Lease: view, inline edit, generate from terms, and review for gaps/overlaps. */
export default class TcRentTable extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    rows = [];
    warnings = [];
    total = 0;
    method;
    draftValues = [];
    loading = true;
    error;

    connectedCallback() { this.load(); }

    async load() {
        this.loading = true;
        try {
            const res = await getRentTable({ parentId: this.recordId });
            this.rows = res.rows;
            this.warnings = (res.warnings || []).map((w, i) => ({ key: i, text: w }));
            this.total = res.total;
            this.method = res.parent && res.parent.TC_Total_Rent_Calculation__c;
            this.error = undefined;
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    get hasRows() { return this.rows.length > 0; }
    get hasWarnings() { return this.warnings.length > 0; }
    get totalLabel() { return formatCurrency(this.total); }
    get methodLabel() { return this.method || 'Annual Ratio Rent'; }

    async handleGenerate() {
        let replace = false;
        if (this.hasRows) {
            replace = await LightningConfirm.open({ message: 'Replace the current rent table with periods generated from the lease terms (commencement, expiration, rate, escalation and free rent)?', label: 'Regenerate rent table', theme: 'warning' });
            if (!replace) return;
        }
        this.loading = true;
        try {
            const n = await generateRentTable({ parentId: this.recordId, replaceExisting: replace });
            this.toast('Rent table generated', `${n} period(s) created.`, 'success');
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            await this.load();
        } catch (e) {
            this.loading = false;
            this.toast('Could not generate the rent table', reduceErrors(e), 'error');
        }
    }

    async handleSave(event) {
        const drafts = event.detail.draftValues;
        this.loading = true;
        try {
            await Promise.all(drafts.map((d) => updateRecord({ fields: { ...d } })));
            this.draftValues = [];
            this.toast('Rent table saved', `${drafts.length} period(s) updated.`, 'success');
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            await this.load();
        } catch (e) {
            this.loading = false;
            this.toast('Could not save', reduceErrors(e), 'error');
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
