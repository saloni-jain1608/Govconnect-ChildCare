import { LightningElement, api } from 'lwc';
import delegateRequest from '@salesforce/apex/RequestController.delegateRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const tool_columns = [
    { label: 'Selected', fieldName: 'isSelected', type: 'boolean', hideDefaultActions: true },
    { label: 'Recommended', fieldName: 'isRecommended', type: 'boolean', hideDefaultActions: true },
    { label: 'Name', fieldName: 'Name', type: 'text', hideDefaultActions: true },
    { label: 'Description', fieldName: 'Description', type: 'text', hideDefaultActions: true }
];

export default class InspectionTool extends NavigationMixin(LightningElement) {
    inspection_tool_columns = tool_columns;
    @api recordId;
    inspectionTools;
    fullScopeInspectionTool;
    isLoading = false;
    selectedTools = [];

    connectedCallback() {
        this.isLoading = true;
        delegateRequest({ className: 'InspectionToolCtrl', methodName: 'getInspectionTools', jsonParam: this.recordId })
            .then(result => {
                this.isLoading = false;
                console.log(result);
                let response = JSON.parse(result);

                this.inspectionTools = response.data.inspectionTools;
                this.fullScopeInspectionTool = response.data.fullScopeInspectionTool;
            }).catch(error => {
                this.isLoading = false;
                console.log(error);
            });
    }

    getSelectedInspectionTool(event) {
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedTools.push(selectedRows[i]);
        }
    }

    handleSaveClick(event) {
        let requestParams = {
            recordId: this.recordId,
            inspectionTools: this.selectedTools,
            fullScopeInspectionToolId: this.fullScopeInspectionTool.Id
        }

        console.log(requestParams);

        delegateRequest({ className: 'InspectionToolCtrl', methodName: 'saveInspectionTools', jsonParam: JSON.stringify(requestParams) })
            .then(result => {
                this.isLoading = false;
                console.log(result);
                let response = JSON.parse(result);

                if (response.status == "OK") {
                    this.showToastMessage('Status', 'Inspection rules loaded successfully', 'success');
                } else {
                    this.showToastMessage('Status', response.errors[0], 'warning');
                }
            }).catch(error => {
                this.isLoading = false;
                this.showToastMessage('Status', 'An error occurred while processing the request', 'error');
                console.log(error);
            });
    }

    handleCancelClick(event) {
        this.navigateToInspection();
    }

    /* Shows toast message
     * @param title Title for toast message
     * @param message Message for toast message
     * @param variant Variant for toast message
     */
    showToastMessage = (title, message, variant) => {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    };

    navigateToInspection() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CLQ_Inspection__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}