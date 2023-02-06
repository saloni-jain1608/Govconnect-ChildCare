import { LightningElement, api, track } from 'lwc';

export default class CustomCheckbox extends LightningElement {
    @api checkboxval;
    @api recordid;
    checkboxhandler(event){
        console.log('event from checkbox:', event.target.checked);
        console.log('event id from checkbox:', event.target.id);
        const event1 = new CustomEvent('customcheckbox', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordid: event.target.id,
                checkboxval: event.target.checked
            },
        });
        this.dispatchEvent(event1);
    }
}