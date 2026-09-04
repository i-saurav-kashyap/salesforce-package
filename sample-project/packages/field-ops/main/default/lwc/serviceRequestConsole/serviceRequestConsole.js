import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getOpenRequests from '@salesforce/apex/ServiceRequestConsoleController.getOpenRequests';
import completeRequests from '@salesforce/apex/ServiceRequestConsoleController.completeRequests';

// Custom labels are namespaced automatically when the package is installed.
import CREATED from '@salesforce/label/c.Ops_Request_Created';

const COLUMNS = [
    { label: 'Number', fieldName: 'Name', initialWidth: 120 },
    { label: 'Summary', fieldName: 'Summary__c' },
    { label: 'Status', fieldName: 'Status__c', initialWidth: 130 },
    { label: 'Priority', fieldName: 'Priority__c', initialWidth: 110 },
    { label: 'Due', fieldName: 'Due_Date__c', type: 'date-local', initialWidth: 120 }
];

export default class ServiceRequestConsole extends LightningElement {
    @api maxRows = 50;

    columns = COLUMNS;
    @track rows = [];
    errorMessage;
    isLoading = true;
    selectedIds = [];
    wiredResult;

    labels = { created: CREATED };

    @wire(getOpenRequests, { maxRows: '$maxRows' })
    handleWire(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.rows = data;
            this.errorMessage = undefined;
        } else if (error) {
            this.rows = [];
            this.errorMessage = error?.body?.message ?? 'Unexpected error';
        }
        this.isLoading = false;
    }

    get hasRows() {
        return !this.isLoading && this.rows.length > 0;
    }

    get isEmpty() {
        return !this.isLoading && !this.errorMessage && this.rows.length === 0;
    }

    get nothingSelected() {
        return this.selectedIds.length === 0;
    }

    handleSelection(event) {
        this.selectedIds = event.detail.selectedRows.map((row) => row.Id);
    }

    async handleComplete() {
        this.isLoading = true;
        try {
            await completeRequests({ requestIds: this.selectedIds });
            this.selectedIds = [];
            await refreshApex(this.wiredResult);
            this.toast('Success', 'Requests completed.', 'success');
        } catch (e) {
            this.toast('Could not complete', e?.body?.message ?? 'Unexpected error', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleOpenModal() {
        this.dispatchEvent(new CustomEvent('newrequest'));
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
