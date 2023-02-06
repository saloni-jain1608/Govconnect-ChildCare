import { LightningElement, api } from 'lwc';

export default class CustomTextArea extends LightningElement {
    @api textareaval;
    @api recordid;
    textareahandler(event){
        console.log('event from textarea:', event.target.value);
        console.log('event id from textarea:', event.target.id);
        const event1 = new CustomEvent('customtextarea', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordid: event.target.id,
                textareaval: event.target.value
            },
        });
        this.dispatchEvent(event1);
    }
}