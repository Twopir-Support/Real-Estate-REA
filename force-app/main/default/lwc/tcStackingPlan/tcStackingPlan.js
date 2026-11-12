import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getStackingPlan from '@salesforce/apex/TC_PropertyUIController.getStackingPlan';
import { expirationColor, formatDate, formatNumber, reduceErrors } from 'c/tcUtils';

/** Stacking plan: floors top-down, units sized by SF, leases coloured by expiration year, vacancies highlighted. */
export default class TcStackingPlan extends NavigationMixin(LightningElement) {
    @api recordId;
    data;
    error;
    yearFilter = '';

    @wire(getStackingPlan, { propertyId: '$recordId' })
    wired({ data, error }) {
        this.data = data;
        this.error = error ? reduceErrors(error) : undefined;
    }

    get loading() { return !this.data && !this.error; }
    get enabled() { return this.data && this.data.enabled; }
    get hasFloors() { return this.data && this.data.floors && this.data.floors.length > 0; }

    get years() {
        const set = new Set();
        ((this.data && this.data.floors) || []).forEach((f) => f.blocks.forEach((b) => b.expYear && set.add(b.expYear)));
        return [...set].sort();
    }
    get yearOptions() {
        return [{ label: 'All expirations', value: '' }, ...this.years.map((y) => ({ label: `Expiring ${y}`, value: y }))];
    }
    handleYear(e) { this.yearFilter = e.detail.value; }

    get legend() {
        const vac = (this.data && this.data.vacancyColor) || '#F4D03F';
        return [
            ...this.years.map((y) => ({ key: y, label: y, style: `background:${expirationColor(y)}` })),
            { key: 'avail', label: 'Available', style: `background:${vac}` },
            { key: 'vacant', label: 'Vacant (not marketed)', style: 'background:#C9D3D8' },
            { key: 'unknown', label: 'Not recorded', style: 'background:repeating-linear-gradient(45deg,#eef2f4,#eef2f4 4px,#dde4e8 4px,#dde4e8 8px)' }
        ];
    }

    get floors() {
        const vac = (this.data && this.data.vacancyColor) || '#F4D03F';
        return ((this.data && this.data.floors) || []).map((f) => {
            const total = Number(f.totalSf) || 1;
            const occ = f.totalSf ? Math.round((Number(f.leasedSf) / total) * 100) : 0;
            return {
                floor: f.floor,
                label: `Floor ${f.floor}`,
                meta: `${formatNumber(f.totalSf)} SF · ${occ}% leased`,
                blocks: f.blocks.map((b) => {
                    let bg = '#C9D3D8';
                    let fg = '#15232B';
                    if (b.kind === 'lease') { bg = expirationColor(b.expYear); fg = '#FFFFFF'; }
                    if (b.kind === 'available') { bg = vac; }
                    if (b.kind === 'unknown') { bg = 'repeating-linear-gradient(45deg,#eef2f4,#eef2f4 4px,#dde4e8 4px,#dde4e8 8px)'; fg = '#5A6B75'; }
                    const dim = this.yearFilter && b.expYear !== this.yearFilter;
                    const width = Math.max(4, (Number(b.sf) / total) * 100);
                    return {
                        key: b.key,
                        recordId: b.recordId,
                        label: b.label,
                        sublabel: b.sublabel,
                        sf: `${formatNumber(b.sf)} SF`,
                        title: `${b.label}${b.sublabel ? ' · ' + b.sublabel : ''} · ${formatNumber(b.sf)} SF${b.expiration ? ' · expires ' + formatDate(b.expiration) : ''}`,
                        clickable: !!b.recordId,
                        cls: `block ${b.recordId ? 'block_link' : ''} ${dim ? 'block_dim' : ''}`,
                        style: `flex: ${width} 1 0; background:${bg}; color:${fg};`
                    };
                })
            };
        });
    }

    openBlock(e) {
        const id = e.currentTarget.dataset.id;
        if (id) {
            this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: id, actionName: 'view' } });
        }
    }
    handleKey(e) {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            this.openBlock(e);
        }
    }
}
