import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPipeline from '@salesforce/apex/TC_DealUIController.getPipeline';
import updateStage from '@salesforce/apex/TC_DealUIController.updateStage';
import { formatCurrency, formatDate, formatNumber, reduceErrors } from 'c/tcUtils';

export default class TcDealPipeline extends NavigationMixin(LightningElement) {
    recordType = '';
    myDealsOnly = false;
    wiredResult;
    data;
    error;
    dragId;
    overStage;

    @wire(getPipeline, { recordTypeDevName: '$recordType', myDealsOnly: '$myDealsOnly' })
    wired(result) {
        this.wiredResult = result;
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = reduceErrors(result.error);
        }
    }

    get loading() { return !this.data && !this.error; }
    get typeOptions() {
        const types = (this.data && this.data.recordTypes) || [];
        return [{ label: 'All deal types', value: '' }, ...types];
    }
    handleType(e) { this.recordType = e.detail.value; }
    handleMine(e) { this.myDealsOnly = e.target.checked; }

    get columns() {
        if (!this.data) return [];
        const deals = this.data.deals || [];
        return this.data.stages.map((stage) => {
            const inStage = deals.filter((d) => d.TC_Stage__c === stage);
            const fee = inStage.reduce((s, d) => s + (d.TC_Gross_Fee_Amount__c || 0), 0);
            const sf = inStage.reduce((s, d) => s + (d.TC_Size__c || 0), 0);
            return {
                stage,
                count: inStage.length,
                fee: formatCurrency(fee, true),
                sf: sf ? `${formatNumber(sf, true)} SF` : '',
                cls: `column ${this.overStage === stage ? 'column_over' : ''}`,
                cards: inStage.map((d) => ({
                    id: d.Id,
                    name: d.Name,
                    type: d.RecordType ? d.RecordType.Name : '',
                    client: d.TC_Client__r ? d.TC_Client__r.Name : '',
                    property: d.TC_Property__r ? d.TC_Property__r.Name : '',
                    fee: formatCurrency(d.TC_Gross_Fee_Amount__c, true),
                    weighted: formatCurrency(d.TC_Weighted_Fee__c, true),
                    close: formatDate(d.TC_Est_Close_Date__c),
                    broker: d.TC_Lead_Broker__r ? d.TC_Lead_Broker__r.Name : '',
                    overdue: d.TC_Est_Close_Date__c && new Date(d.TC_Est_Close_Date__c) < new Date(new Date().toDateString())
                })).map((c) => ({ ...c, closeCls: c.overdue ? 'close close_overdue' : 'close' }))
            };
        });
    }
    get totalLabel() {
        const deals = (this.data && this.data.deals) || [];
        const fee = deals.reduce((s, d) => s + (d.TC_Gross_Fee_Amount__c || 0), 0);
        const w = deals.reduce((s, d) => s + (d.TC_Weighted_Fee__c || 0), 0);
        return `${deals.length} open deals · ${formatCurrency(fee, true)} in fees · ${formatCurrency(w, true)} weighted`;
    }

    handleDragStart(e) {
        this.dragId = e.currentTarget.dataset.id;
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', this.dragId);
    }
    handleDragOver(e) {
        e.preventDefault();
        this.overStage = e.currentTarget.dataset.stage;
    }
    handleDragLeave() { this.overStage = undefined; }
    async handleDrop(e) {
        e.preventDefault();
        const stage = e.currentTarget.dataset.stage;
        const id = this.dragId || e.dataTransfer.getData('text/plain');
        this.overStage = undefined;
        this.dragId = undefined;
        const deal = (this.data.deals || []).find((d) => d.Id === id);
        if (!deal || deal.TC_Stage__c === stage) return;
        await this.moveDeal(id, stage, deal.Name);
    }
    async handleMoveMenu(e) {
        const id = e.currentTarget.dataset.id;
        const stage = e.detail.value;
        const deal = (this.data.deals || []).find((d) => d.Id === id);
        if (deal && deal.TC_Stage__c !== stage) await this.moveDeal(id, stage, deal.Name);
    }
    get stageMenu() { return ((this.data && this.data.stages) || []).map((s) => ({ label: `Move to ${s}`, value: s })); }

    async moveDeal(id, stage, name) {
        try {
            await updateStage({ dealId: id, stage });
            this.dispatchEvent(new ShowToastEvent({ title: 'Stage updated', message: `${name} moved to ${stage}.`, variant: 'success' }));
            await refreshApex(this.wiredResult);
        } catch (err) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Could not move the deal', message: reduceErrors(err), variant: 'error' }));
        }
    }

    openDeal(e) {
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: e.currentTarget.dataset.id, actionName: 'view' } });
    }
    newDeal() {
        this[NavigationMixin.Navigate]({ type: 'standard__objectPage', attributes: { objectApiName: 'TC_Deal__c', actionName: 'new' } });
    }
}
