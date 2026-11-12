import { LightningElement, api, wire } from 'lwc';
import getScorecard from '@salesforce/apex/TC_DealUIController.getScorecard';
import { formatValue, reduceErrors } from 'c/tcUtils';

/** Record scorecard: up to five roll-up KPI tiles for the current record (AscendixRE Scorecard equivalent). */
export default class TcScorecard extends LightningElement {
    @api recordId;
    @api title = 'Scorecard';
    tiles = [];
    error;

    @wire(getScorecard, { recordId: '$recordId' })
    wired({ data, error }) {
        if (data) {
            this.tiles = data.map((t, i) => ({ key: `${t.label}-${i}`, label: t.label, value: formatValue(t.value, t.format, true) }));
            this.error = undefined;
        } else if (error) {
            this.error = reduceErrors(error);
        }
    }
    get hasTiles() { return this.tiles.length > 0; }
}
