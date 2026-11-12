import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getConvertInfo from '@salesforce/apex/TC_RecordUIController.getConvertInfo';
import convertInquiry from '@salesforce/apex/TC_RecordUIController.convertInquiry';
import { reduceErrors } from 'c/tcUtils';

/** Convert Inquiry: creates or reuses Account and Contact, optionally creates a Deal with the chosen listing. */
export default class TcConvertInquiry extends NavigationMixin(LightningElement) {
    _recordId;
    info;
    listingId = '';
    createDeal = true;
    loading = false;
    error;

    @api
    get recordId() { return this._recordId; }
    set recordId(v) {
        this._recordId = v;
        if (v) this.load();
    }

    async load() {
        this.loading = true;
        try {
            this.info = await getConvertInfo({ inquiryId: this._recordId });
            this.listingId = this.info.primaryListing || '';
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    get inquiry() { return (this.info && this.info.inquiry) || {}; }
    get converted() { return this.inquiry.TC_Status__c === 'Converted'; }
    get showConvert() { return !!this.info && !this.converted; }
    get who() {
        const i = this.inquiry;
        return [i.TC_Contact__r ? i.TC_Contact__r.Name : [i.TC_First_Name__c, i.TC_Last_Name__c].filter(Boolean).join(' '),
            i.TC_Company__r ? i.TC_Company__r.Name : i.TC_Company_Name__c].filter(Boolean).join(' · ');
    }
    get accountAction() { return this.inquiry.TC_Company__r ? `Use existing account ${this.inquiry.TC_Company__r.Name}` : 'Create a new account'; }
    get contactAction() { return this.inquiry.TC_Contact__r ? `Use existing contact ${this.inquiry.TC_Contact__r.Name}` : 'Create a new contact'; }
    get listingOptions() { return (this.info && this.info.listings) || []; }
    get dealTypeLabel() { return this.inquiry.TC_Inquiry_Type__c === 'Sale' ? 'Buyer Representation' : 'Tenant Representation'; }

    handleListing(e) { this.listingId = e.detail.value; }
    handleCreateDeal(e) { this.createDeal = e.target.checked; }

    async handleConvert() {
        this.loading = true;
        this.error = undefined;
        try {
            const res = await convertInquiry({ inquiryId: this._recordId, listingId: this.listingId || null, createDeal: this.createDeal });
            this.dispatchEvent(new ShowToastEvent({ title: 'Inquiry converted', message: res.warning || 'Account, contact' + (res.dealId ? ' and deal' : '') + ' are ready.', variant: res.warning ? 'warning' : 'success' }));
            this.dispatchEvent(new CloseActionScreenEvent());
            this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: res.dealId || res.accountId, actionName: 'view' } });
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }
    close() { this.dispatchEvent(new CloseActionScreenEvent()); }
}
