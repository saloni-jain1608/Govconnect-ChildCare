import { LightningElement,api } from 'lwc';
import pubsub from 'c/pubsub' ; 
export default class Applicationnavigation extends LightningElement {



   @api value = 'program information';

    get options() {
        return [
            { label: 'Program Information', value: 'program information' },
            { label: 'Business Entity', value: 'business entity' },
            { label: 'Required Attached Checklist', value: 'required attached checklist' },
			{ label: 'Fees', value: 'fees' },
			{ label: 'E Signature', value: 'e signature' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
		window.console.log('Event Firing..... ');
        let message = {
            "message" : this.value
        }
        pubsub.fire('simplevt', message );
        window.console.log('Event Fired ');
    }
}