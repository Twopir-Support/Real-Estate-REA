import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import findMatches from '@salesforce/apex/TC_RecordUIController.findMatches';
import saveMatches from '@salesforce/apex/TC_RecordUIController.saveMatches';
import { formatCurrency, formatNumber, reduceErrors } from 'c/tcUtils';

/** Find Matches (TC extra): scores active listings against the inquiry and adds the chosen ones as Prospective Listings. */
export default class TcInquiryMatches extends NavigationMixin(LightningElement) {
    @api recordId;
    matches;
    selected = new Set();
    loading = false;
    error;

    async handleFind() {
        this.loading = true;
        this.error = undefined;
        try {
            const res = await findMatches({ inquiryId: this.recordId });
            this.selected = new Set(res.map((m) => m.listingId));
            this.matches = res;
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    get searched() { return Array.isArray(this.matches); }
    get hasMatches() { return this.searched && this.matches.length > 0; }
    get cards() {
        return (this.matches || []).map((m) => ({
            ...m,
            key: m.listingId,
            checked: this.selected.has(m.listingId),
            scoreCls: `score ${m.score >= 80 ? 'score_high' : m.score >= 60 ? 'score_mid' : ''}`,
            facts: [m.city, m.availableSf ? `${formatNumber(m.availableSf)} SF available` : null, m.askingRate ? `${formatCurrency(m.askingRate)}/SF` : null, m.askingPrice ? formatCurrency(m.askingPrice, true) : null].filter(Boolean).join(' · '),
            reasonText: (m.reasons || []).join(' · ')
        }));
    }
    get selectedCount() { return this.selected.size; }
    get saveDisabled() { return this.selected.size === 0; }

    toggle(e) {
        const id = e.target.dataset.id;
        const next = new Set(this.selected);
        if (e.target.checked) next.add(id); else next.delete(id);
        this.selected = next;
    }

    async handleSave() {
        this.loading = true;
        try {
            const n = await saveMatches({ inquiryId: this.recordId, listingIds: [...this.selected] });
            this.dispatchEvent(new ShowToastEvent({ title: 'Prospective listings added', message: n ? `${n} listing(s) added to this inquiry.` : 'These listings were already on the inquiry.', variant: 'success' }));
            await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            this.matches = undefined;
        } catch (e) {
            this.error = reduceErrors(e);
        } finally {
            this.loading = false;
        }
    }

    openListing(e) {
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: e.currentTarget.dataset.id, actionName: 'view' } });
    }
}
