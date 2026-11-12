import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getCloseInfo from '@salesforce/apex/TC_DealUIController.getCloseInfo';
import closeDeal from '@salesforce/apex/TC_DealUIController.closeDeal';
import { formatCurrency, reduceErrors } from 'c/tcUtils';

/** Close Deal quick action: Won/Lost, close date, actual value; shows what records will be created. */
export default class TcCloseDeal extends NavigationMixin(LightningElement) {
    _recordId;
    info;
    status = 'Won';
    closeDate = new Date().toISOString().slice(0, 10);
    actualValue;
    lostReason;
    created;
    loading = false;
    error;

    @api
    get recordId() { return this._recordId; }
    set recordId(value) {
        this._recordId = value;
        if (value) this.load();
    }

    async load() {
        this.loading = true;
        try {
            this.info = await getCloseInfo({ dealId: this._recordId });
            this.actualValue = this.info.deal.TC_Gross_Deal_Value__c;
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    get statusOptions() { return [{ label: 'Won', value: 'Won' }, { label: 'Lost', value: 'Lost' }]; }
    get isWon() { return this.status === 'Won'; }
    get isLost() { return this.status === 'Lost'; }
    get reasonOptions() { return ((this.info && this.info.lostReasons) || []).map((r) => ({ label: r, value: r })); }
    get willCreate() { return ((this.info && this.info.willCreate) || []).map((w) => ({ key: w, label: w })); }
    get hasWillCreate() { return this.isWon && this.willCreate.length > 0; }
    get missing() { return (this.info && this.info.missing) || []; }
    get missingText() { return this.missing.join(', '); }
    get hasMissing() { return this.isWon && this.missing.length > 0; }
    get alreadyClosed() { return this.info && this.info.deal && this.info.deal.TC_Status__c !== 'Open'; }
    get feeLabel() { return this.info ? formatCurrency(this.info.deal.TC_Gross_Fee_Amount__c) : ''; }
    get createdList() { return (this.created || []).map((c) => ({ key: c.id, ...c })); }
    get done() { return !!this.created; }

    handleStatus(e) { this.status = e.detail.value; }
    handleDate(e) { this.closeDate = e.detail.value; }
    handleValue(e) { this.actualValue = e.detail.value; }
    handleReason(e) { this.lostReason = e.detail.value; }

    async handleSave() {
        if (this.isLost && !this.lostReason) {
            this.error = 'Choose a Lost Reason.';
            return;
        }
        this.loading = true;
        this.error = undefined;
        try {
            const res = await closeDeal({ dealId: this._recordId, status: this.status, closeDate: this.closeDate, actualValue: this.actualValue, lostReason: this.lostReason });
            this.created = res.created || [];
            await notifyRecordUpdateAvailable([{ recordId: this._recordId }]);
            this.dispatchEvent(new ShowToastEvent({ title: `Deal closed as ${this.status}`, message: this.created.length ? `${this.created.length} related record(s) created.` : '', variant: 'success' }));
            if (!this.created.length) this.close();
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    openCreated(e) {
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: e.currentTarget.dataset.id, actionName: 'view' } });
        this.close();
    }
    close() { this.dispatchEvent(new CloseActionScreenEvent()); }
}
