import { LightningElement } from 'lwc';

export default class InspectionDetails extends LightningElement {
    value = 'inProgress';

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Cancelled', value: 'cancelled' },
            { label: 'Compeleted', value: 'compeleted' },
            { label: 'Denied', value: 'denied' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }


    handleChangeCheckBox(event) {
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        for (i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
    }
  
}