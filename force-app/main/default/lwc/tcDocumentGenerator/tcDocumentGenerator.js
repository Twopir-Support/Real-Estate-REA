import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentOptions from '@salesforce/apex/TC_RecordUIController.getDocumentOptions';
import generateDocument from '@salesforce/apex/TC_RecordUIController.generateDocument';
import { reduceErrors } from 'c/tcUtils';

/** Generates PDF documents (flyer, lease comp report, tour book) and saves them as Files on the record. */
export default class TcDocumentGenerator extends NavigationMixin(LightningElement) {
    @api recordId;
    options = [];
    selected;
    working = false;

    @wire(getDocumentOptions, { recordId: '$recordId' })
    wired({ data }) {
        if (data) {
            this.options = data;
            this.selected = data.length ? data[0].value : undefined;
        }
    }

    get hasOptions() { return this.options.length > 0; }
    get comboOptions() { return this.options.map((o) => ({ label: o.label, value: o.value })); }
    get current() { return this.options.find((o) => o.value === this.selected); }
    get previewUrl() { return this.current ? `/apex/${this.current.page}?id=${this.recordId}` : null; }

    handleSelect(e) { this.selected = e.detail.value; }

    async handleGenerate() {
        if (!this.current) return;
        this.working = true;
        try {
            const docId = await generateDocument({ recordId: this.recordId, pageName: this.current.page, title: this.current.label });
            this.dispatchEvent(new ShowToastEvent({ title: `${this.current.label} saved`, message: 'The PDF was added to Files on this record.', variant: 'success' }));
            this[NavigationMixin.Navigate]({ type: 'standard__namedPage', attributes: { pageName: 'filePreview' }, state: { selectedRecordId: docId } });
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Could not create the document', message: reduceErrors(e), variant: 'error' }));
        } finally {
            this.working = false;
        }
    }
}
