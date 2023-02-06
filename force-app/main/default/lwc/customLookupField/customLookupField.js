import { LightningElement ,api } from 'lwc';

export default class CustomLookupField extends LightningElement {
    @api childObjectApiName = 'CLQ_Program_Transaction__c'; //Contact is the default value
    @api targetFieldApiName = 'CLQ_ProgTrans_County__c'; //AccountId is the default value
    @api fieldLabel = 'Your field label here';
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }
}