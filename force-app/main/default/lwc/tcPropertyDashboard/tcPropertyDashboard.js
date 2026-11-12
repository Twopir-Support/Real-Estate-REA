import { LightningElement, wire } from 'lwc';
import getDashboard from '@salesforce/apex/TC_PropertyUIController.getDashboard';
import { formatCurrency, formatNumber, reduceErrors } from 'c/tcUtils';

const TYPES = ['Office', 'Retail', 'Industrial', 'Multifamily', 'Land', 'Hospitality', 'Mixed Use', 'Special Purpose'];

export default class TcPropertyDashboard extends LightningElement {
    market = '';
    propertyType = '';
    data;
    error;

    @wire(getDashboard, { market: '$market', propertyType: '$propertyType' })
    wired({ data, error }) {
        this.data = data;
        this.error = error ? reduceErrors(error) : undefined;
    }

    get loading() { return !this.data && !this.error; }

    get marketOptions() {
        const markets = (this.data && this.data.markets) || [];
        return [{ label: 'All markets', value: '' }, ...markets.map((m) => ({ label: m, value: m }))];
    }
    get typeOptions() {
        return [{ label: 'All property types', value: '' }, ...TYPES.map((t) => ({ label: t, value: t }))];
    }
    handleMarket(e) { this.market = e.detail.value; }
    handleType(e) { this.propertyType = e.detail.value; }

    get kpis() {
        const d = this.data || {};
        const occ = Number(d.occupancy || 0);
        return [
            { key: 'props', label: 'Properties', value: formatNumber(d.properties), hint: `${formatNumber(d.totalSf, true)} SF total` },
            { key: 'occ', label: 'Occupancy', value: `${occ.toFixed(1)}%`, hint: `${formatNumber(d.leasedSf, true)} SF leased`, state: occ < 80 ? 'warn' : 'good' },
            { key: 'avail', label: 'Available', value: `${formatNumber(d.availableSf, true)} SF`, hint: `${formatNumber(d.activeListings)} active listings` },
            { key: 'pipe', label: 'Pipeline fees', value: formatCurrency(d.pipelineFee, true), hint: `${formatNumber(d.openDeals)} open deals` },
            { key: 'weighted', label: 'Weighted fees', value: formatCurrency(d.weightedFee, true), hint: 'by stage probability' },
            { key: 'won', label: 'Won this year', value: formatCurrency(d.wonFeeYtd, true), hint: `${formatNumber(d.wonYtd)} deals` },
            { key: 'exp', label: 'Expiring in 12 months', value: `${formatNumber(d.expiringSf12, true)} SF`, hint: 'active leases', state: Number(d.expiringSf12) > 0 ? 'warn' : '' },
            { key: 'inq', label: 'Open inquiries', value: formatNumber(d.openInquiries), hint: 'New and Active' }
        ].map((k) => ({ ...k, cls: `kpi ${k.state ? 'kpi_' + k.state : ''}` }));
    }

    get occupancySeries() { return (this.data && this.data.occupancyByType) || []; }
    get pipelineSeries() { return (this.data && this.data.pipelineByStage) || []; }
    get expirationSeries() { return (this.data && this.data.expirationsByYear) || []; }
    get sourceSeries() { return (this.data && this.data.inquiriesBySource) || []; }
}
