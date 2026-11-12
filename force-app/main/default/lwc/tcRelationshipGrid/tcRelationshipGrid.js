import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { refreshApex } from '@salesforce/apex';
import getRelationships from '@salesforce/apex/TC_RecordUIController.getRelationships';
import relationshipField from '@salesforce/apex/TC_RecordUIController.relationshipField';
import { formatDate, reduceErrors } from 'c/tcUtils';

/** Relationship grid: internal users linked to this record and the role each plays. */
export default class TcRelationshipGrid extends NavigationMixin(LightningElement) {
    @api recordId;
    rows = [];
    field;
    wiredRows;
    error;

    @wire(relationshipField, { recordId: '$recordId' })
    wiredField({ data }) { if (data) this.field = data; }

    @wire(getRelationships, { recordId: '$recordId' })
    wired(result) {
        this.wiredRows = result;
        if (result.data) {
            this.rows = result.data.map((r) => ({ id: r.Id, user: r.TC_User__r ? r.TC_User__r.Name : '', role: r.TC_Relationship_Type__c, since: formatDate(r.TC_Start_Date__c) }));
            this.error = undefined;
        } else if (result.error) {
            this.error = reduceErrors(result.error);
        }
    }

    get hasRows() { return this.rows.length > 0; }
    get supported() { return !!this.field; }

    handleNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName: 'TC_Relationship__c', actionName: 'new' },
            state: { defaultFieldValues: encodeDefaultFieldValues({ [this.field]: this.recordId }), navigationLocation: 'RELATED_LIST' }
        });
    }
    handleRefresh() { refreshApex(this.wiredRows); }
    openRow(e) {
        this[NavigationMixin.Navigate]({ type: 'standard__recordPage', attributes: { recordId: e.currentTarget.dataset.id, actionName: 'view' } });
    }
}
