import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from "lightning/uiRecordApi";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getAccountFields from '@salesforce/apex/AccountFieldMetadata.getAccountFields';

export default class AccCloneNew extends NavigationMixin(LightningElement) {
    @api recordId;
    @track defaultValues;
    @track fieldsListFromApex = [];
    @track fieldsListFromApexWithObj = [];

    // Fetch fields dynamically from Apex
    @wire(getAccountFields)
    wiredFields({ error, data }) {
        if (data) {
            this.fieldsListFromApex = data;
            this.fieldsListFromApexWithObj = this.fieldsListFromApex.map(field => `Account.${field}`);

            console.log('Fields from Custom Setting:', this.fieldsListFromApexWithObj);
        } else if (error) {
            console.error('Error fetching custom setting fields:', error);
        }
    }

    // Fetch Account Data only after field list is populated
    @wire(getRecord, { recordId: "$recordId", fields: "$fieldsListFromApexWithObj" })
    account({ error, data }) {
        if (data && this.fieldsListFromApexWithObj.length > 0) {
            console.log('Fetched Account Data:', JSON.stringify(data));

            let fieldValues = {};
            this.fieldsListFromApex.forEach(field => {
                if (data.fields[field]) {
                    fieldValues[field] = data.fields[field].value;
                }
            });

            // Ensure Name and Phone are properly mapped
            fieldValues['Clone_Account_Id__c'] = this.recordId;  
            this.defaultValues = encodeDefaultFieldValues(fieldValues);
            this.handleNavigation();
        } else if (error) {
            console.error('Error fetching account record:', error);
        }
    }

    handleNavigation() {
        console.log('Cloning with Fields:', this.defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: this.defaultValues
            }
        });

        this.closeAction();
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}