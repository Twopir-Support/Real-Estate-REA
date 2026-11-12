import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getImages from '@salesforce/apex/TC_RecordUIController.getImages';
import { reduceErrors } from 'c/tcUtils';

/** Image gallery: primary image plus uploaded image files, with upload (AscendixRE Image Viewer equivalent). */
export default class TcImageViewer extends LightningElement {
    @api recordId;
    images = [];
    index = 0;
    wiredImages;
    error;

    @wire(getImages, { recordId: '$recordId' })
    wired(result) {
        this.wiredImages = result;
        if (result.data) {
            this.images = result.data.map((img, i) => ({ ...img, key: `${i}-${img.url}` }));
            this.index = 0;
            this.error = undefined;
        } else if (result.error) {
            this.error = reduceErrors(result.error);
        }
    }

    get hasImages() { return this.images.length > 0; }
    get current() { return this.images[this.index] || {}; }
    get counter() { return `${this.index + 1} of ${this.images.length}`; }
    get multiple() { return this.images.length > 1; }
    get thumbs() { return this.images.map((img, i) => ({ ...img, cls: `thumb ${i === this.index ? 'thumb_active' : ''}`, idx: i })); }

    prev() { this.index = (this.index - 1 + this.images.length) % this.images.length; }
    next() { this.index = (this.index + 1) % this.images.length; }
    pick(e) { this.index = Number(e.currentTarget.dataset.idx); }

    handleUpload(e) {
        const n = e.detail.files.length;
        this.dispatchEvent(new ShowToastEvent({ title: 'Images uploaded', message: `${n} image(s) added.`, variant: 'success' }));
        refreshApex(this.wiredImages);
    }
}
