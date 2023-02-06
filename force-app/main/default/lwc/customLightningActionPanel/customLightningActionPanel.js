import { LightningElement, api, track } from 'lwc';
import { consoleLog, handleApexImpCall } from 'c/glcBaseModule';
import getActions from "@salesforce/apex/CustomLWCActionPanelController.getActions";

export default class CustomLightningActionPanel extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api objectLabel;
    @track actions = [];
    /*buttonLabel;
    className;
    classMethod;
    componentType;
    componentApiName;
    validationRequired;
    validationMethod;*/

    connectedCallback() {
        handleApexImpCall(this, getActions, (promiseresult) => {

            console.log(JSON.stringify(promiseresult.objectData));

            this.actions = promiseresult.objectData.lstConfigs;

        },
            {
                "sObjectApiName": this.objectApiName
            });
    }

    get cardTitle() {
        return `${this.objectLabel} Actions`;
    }

}