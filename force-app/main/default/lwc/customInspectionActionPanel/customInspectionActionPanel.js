import { LightningElement, api, track, wire } from 'lwc';
import { consoleLog, handleApexImpCall } from 'c/glcBaseModule';
import getActions from "@salesforce/apex/CustomLWCActionPanelController.getActions";
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'CLQ_Inspection__c.Inspection_Record_Type__c',
];

export default class CustomInspectionActionPanel extends LightningElement {

    @api recordId;
    @api objectApiName = 'CLQ_Inspection__c';
    @api objectLabel;
    @track actions = [];
    @track CLQ_Inspection;

   

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({error, data}) {
        if (error) {
            
        } else if (data) {
            // Process record data
            this.CLQ_Inspection = data;
            handleApexImpCall(this, getActions, (promiseresult) => {

                console.log(JSON.stringify(promiseresult.objectData));
    
                this.actions = promiseresult.objectData.lstConfigs;
                for(let action in this.actions){
                    if(action != undefined){
                      console.log('data=',this.actions[action].Show_Record_Types__c);
                      this.actions[action].isShow = false;
                      if(this.name != null && this.name != undefined && this.actions[action].Show_Record_Types__c != undefined && this.actions[action].Show_Record_Types__c != null &&
                        this.actions[action].Show_Record_Types__c.includes(this.name)){
                          this.actions[action].isShow = true;
                      }
                    }
                }
                console.log('names==',this.name)
            },
                {
                    "sObjectApiName": this.objectApiName
                });
        }
    }
    

    get name() {
        return this.CLQ_Inspection.fields.Inspection_Record_Type__c.value;
    }

    connectedCallback() {
        
    }

    get cardTitle() {
        return `${this.objectLabel} Actions`;
    }
}