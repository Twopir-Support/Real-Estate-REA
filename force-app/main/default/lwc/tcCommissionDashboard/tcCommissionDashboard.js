import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCommissionDashboard from '@salesforce/apex/TC_DealUIController.getCommissionDashboard';
import { formatCurrency, formatDate, reduceErrors } from 'c/tcUtils';

export default class TcCommissionDashboard extends NavigationMixin(LightningElement) {
    year = new Date().getFullYear();
    data;
    error;

    @wire(getCommissionDashboard, { year: '$year' })
    wired({ data, error }) {
        this.data = data;
        this.error = error ? reduceErrors(error) : undefined;
    }

    get loading() { return !this.data && !this.error; }
    get yearOptions() {
        const y = new Date().getFullYear();
        return [y - 1, y, y + 1].map((v) => ({ label: String(v), value: String(v) }));
    }
    get yearValue() { return String(this.year); }
    handleYear(e) { this.year = Number(e.detail.value); }

    get tiles() {
        const d = this.data || {};
        return [
            { key: 'p', label: 'Projected', value: formatCurrency(d.projected, true) },
            { key: 'e', label: 'Earned / invoiced', value: formatCurrency(d.earned, true) },
            { key: 'pd', label: 'Paid', value: formatCurrency(d.paid, true) },
            { key: 'b', label: 'Balance due', value: formatCurrency(d.balance, true) }
        ];
    }
    get brokerSeries() { return (this.data && this.data.byBroker) || []; }
    get statusSeries() { return (this.data && this.data.byStatus) || []; }
    get brokerTitle() { return `Inside broker gross commission (${this.year})`; }
    get canSeeHouse() { return this.data && this.data.canSeeHouse; }
    get houseRows() {
        return this.brokerSeries.map((r) => ({ key: r.label, label: r.label, gross: formatCurrency(r.value), house: formatCurrency(r.house) }));
    }
    get upcoming() {
        return ((this.data && this.data.upcoming) || []).map((c) => ({
            id: c.Id,
            name: c.Name,
            deal: c.TC_Deal__r ? c.TC_Deal__r.Name : '',
            payee: c.TC_Broker__r ? c.TC_Broker__r.Name : c.TC_Account__r ? c.TC_Account__r.Name : '',
            type: c.RecordType ? c.RecordType.Name : '',
            amount: formatCurrency(c.TC_Gross_Commission__c),
            due: formatDate(c.TC_Due_Date__c),
            status: c.TC_Status__c
        }));
    }
    get hasUpcoming() { return this.upcoming.length > 0; }

    openRecord(e) {
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: e.currentTarget.dataset.id, actionName: 'view' } });
    }
}
