import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchProperties from '@salesforce/apex/TC_PropertyUIController.searchProperties';
import { formatCurrency, formatNumber, reduceErrors } from 'c/tcUtils';

const TYPES = ['Office', 'Retail', 'Industrial', 'Multifamily', 'Land', 'Hospitality', 'Mixed Use', 'Special Purpose'];
const STORAGE_KEY = 'tcPropertySearch.criteria';

const COLUMNS = [
    { label: 'Property', fieldName: 'link', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } },
    { label: 'Type', fieldName: 'TC_Property_Type__c', initialWidth: 110 },
    { label: 'Class', fieldName: 'TC_Building_Class__c', initialWidth: 70 },
    { label: 'City', fieldName: 'TC_City__c' },
    { label: 'Submarket', fieldName: 'TC_Submarket__c' },
    { label: 'Size (SF)', fieldName: 'TC_Total_Size__c', type: 'number', cellAttributes: { alignment: 'right' } },
    { label: 'Available (SF)', fieldName: 'TC_Available_SF__c', type: 'number', cellAttributes: { alignment: 'right' } },
    { label: 'Occupancy', fieldName: 'occupancy', type: 'percent', typeAttributes: { maximumFractionDigits: 1 } },
    { label: 'Avg Rate', fieldName: 'TC_Avg_Asking_Rate__c', type: 'currency' }
];

/** Property search: filters, radius search around a property or coordinates, results grid and map; criteria saved per user (browser). */
export default class TcPropertySearch extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    criteria = { propertyType: '', buildingClass: '', city: '', market: '', minSize: null, maxSize: null, minAvailable: null, maxRate: null, hasAvailability: false, radiusMiles: null, latitude: null, longitude: null };
    results;
    selectedId;
    loading = false;
    error;

    connectedCallback() {
        try {
            const saved = window.localStorage.getItem(STORAGE_KEY);
            if (saved) this.criteria = { ...this.criteria, ...JSON.parse(saved) };
        } catch (e) {
            // storage unavailable: start with defaults
        }
        this.search();
    }

    get typeOptions() { return [{ label: 'Any', value: '' }, ...TYPES.map((t) => ({ label: t, value: t }))]; }
    get classOptions() { return [{ label: 'Any', value: '' }, { label: 'A', value: 'A' }, { label: 'B', value: 'B' }, { label: 'C', value: 'C' }]; }

    handleField(e) {
        const field = e.target.dataset.field;
        const value = e.target.type === 'checkbox' || e.target.type === 'toggle' ? e.target.checked : e.detail.value;
        const numeric = ['minSize', 'maxSize', 'minAvailable', 'maxRate', 'radiusMiles', 'latitude', 'longitude'];
        this.criteria = { ...this.criteria, [field]: numeric.includes(field) ? (value === '' || value === null ? null : Number(value)) : value };
    }

    async search() {
        this.loading = true;
        this.error = undefined;
        try {
            window.localStorage.setItem(STORAGE_KEY, JSON.stringify(this.criteria));
        } catch (e) {
            // ignore storage errors
        }
        try {
            const res = await searchProperties({ criteria: this.criteria });
            this.results = res.map((p) => ({ ...p, link: '/' + p.Id, occupancy: p.TC_Occupancy__c != null ? p.TC_Occupancy__c / 100 : null }));
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    reset() {
        this.criteria = { propertyType: '', buildingClass: '', city: '', market: '', minSize: null, maxSize: null, minAvailable: null, maxRate: null, hasAvailability: false, radiusMiles: null, latitude: null, longitude: null };
        this.search();
    }

    handleKey(e) { if (e.key === 'Enter') this.search(); }

    handleRowSelection(e) {
        const rows = e.detail.selectedRows;
        this.selectedId = rows.length ? rows[0].Id : undefined;
    }
    get centerDisabled() { return !this.selectedId; }
    useSelectedAsCenter() {
        const p = (this.results || []).find((r) => r.Id === this.selectedId);
        if (p && p.TC_Location__Latitude__s) {
            this.criteria = { ...this.criteria, latitude: p.TC_Location__Latitude__s, longitude: p.TC_Location__Longitude__s, radiusMiles: this.criteria.radiusMiles || 5, city: '', market: '' };
            this.search();
        }
    }

    get count() { return this.results ? this.results.length : 0; }
    get countLabel() { return `${this.count} ${this.count === 1 ? 'property' : 'properties'}`; }
    get hasResults() { return this.count > 0; }
    get radiusLabel() {
        const c = this.criteria;
        return c.latitude && c.radiusMiles ? `Within ${c.radiusMiles} mi of ${Number(c.latitude).toFixed(4)}, ${Number(c.longitude).toFixed(4)}` : '';
    }
    get markers() {
        return (this.results || []).filter((p) => p.TC_Location__Latitude__s).map((p) => ({
            value: p.Id,
            location: { Latitude: p.TC_Location__Latitude__s, Longitude: p.TC_Location__Longitude__s },
            title: p.Name,
            description: `${p.TC_Property_Type__c || ''} · ${formatNumber(p.TC_Total_Size__c)} SF · ${formatNumber(p.TC_Available_SF__c)} SF available${p.TC_Avg_Asking_Rate__c ? ' · ' + formatCurrency(p.TC_Avg_Asking_Rate__c) + '/SF' : ''}`,
            icon: 'custom:custom24'
        }));
    }
    get hasMarkers() { return this.markers.length > 0; }
    handleMarker(e) {
        const id = e.target.selectedMarkerValue;
        if (id) this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: id, actionName: 'view' } });
    }
}
