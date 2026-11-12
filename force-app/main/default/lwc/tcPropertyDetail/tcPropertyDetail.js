import { LightningElement, api, wire } from 'lwc';
import getPropertySummary from '@salesforce/apex/TC_PropertyUIController.getPropertySummary';
import { formatCurrency, formatNumber, reduceErrors } from 'c/tcUtils';

/** Property 360 header: image, address, key building facts, occupancy and location map. */
export default class TcPropertyDetail extends LightningElement {
    @api recordId;
    data;
    error;

    @wire(getPropertySummary, { propertyId: '$recordId' })
    wired({ data, error }) {
        this.data = data;
        this.error = error ? reduceErrors(error) : undefined;
    }

    get p() { return (this.data && this.data.property) || {}; }
    get loading() { return !this.data && !this.error; }
    get hasImage() { return !!this.p.TC_Primary_Image_URL__c; }
    get address() {
        const p = this.p;
        return [p.TC_Street__c, p.TC_City__c, [p.TC_State__c, p.TC_Postal_Code__c].filter(Boolean).join(' ')].filter(Boolean).join(', ');
    }
    get chips() {
        const p = this.p;
        return [p.TC_Property_Type__c, p.TC_Property_Subtype__c, p.TC_Building_Class__c ? `Class ${p.TC_Building_Class__c}` : null, p.TC_Building_Status__c, p.TC_Submarket__c]
            .filter(Boolean).map((c) => ({ key: c, label: c }));
    }
    get occupancy() { return Number(this.p.TC_Occupancy__c || 0); }
    get occupancyLabel() { return `${this.occupancy.toFixed(1)}%`; }
    get gaugeStyle() { return `width:${Math.min(100, this.occupancy)}%`; }
    get stats() {
        const p = this.p;
        const d = this.data || {};
        return [
            { key: 'size', label: 'Total size', value: `${formatNumber(p.TC_Total_Size__c)} SF` },
            { key: 'floors', label: 'Floors', value: formatNumber(p.TC_Number_of_Floors__c) },
            { key: 'built', label: 'Year built', value: p.TC_Year_Built__c ? String(p.TC_Year_Built__c) : '—' },
            { key: 'avail', label: 'Available', value: `${formatNumber(p.TC_Available_SF__c)} SF` },
            { key: 'rate', label: 'Avg asking rate', value: p.TC_Avg_Asking_Rate__c ? `${formatCurrency(p.TC_Avg_Asking_Rate__c)}/SF` : '—' },
            { key: 'units', label: 'Units', value: formatNumber(d.unitCount) },
            { key: 'leases', label: 'Active leases', value: formatNumber(d.activeLeases) },
            { key: 'exp', label: 'Expiring in 12 mo', value: formatNumber(d.expiring12) },
            { key: 'deals', label: 'Open deals', value: formatNumber(d.openDeals) },
            { key: 'inq', label: 'Open inquiries', value: formatNumber(d.openInquiries) }
        ];
    }
    get owner() { return this.p.TC_Owner_Landlord__r ? this.p.TC_Owner_Landlord__r.Name : null; }
    get mapMarkers() {
        const p = this.p;
        if (p.TC_Location__Latitude__s && p.TC_Location__Longitude__s) {
            return [{ location: { Latitude: p.TC_Location__Latitude__s, Longitude: p.TC_Location__Longitude__s }, title: p.Name, description: this.address }];
        }
        if (p.TC_Street__c && p.TC_City__c) {
            return [{ location: { Street: p.TC_Street__c, City: p.TC_City__c, State: p.TC_State__c, PostalCode: p.TC_Postal_Code__c, Country: p.TC_Country__c || 'United States' }, title: p.Name }];
        }
        return [];
    }
    get hasMap() { return this.mapMarkers.length > 0; }
}
