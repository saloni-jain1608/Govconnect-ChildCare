import { LightningElement } from 'lwc';
import delegateRequest from '@salesforce/apex/RequestController.delegateRequest';
import SHORT_TERM_ACTION from '@salesforce/schema/CLQ_Corrective_Action_Plan__c.CLQ_Short_term_Action_Taken__c';
import PLANNED_CHANGES_IN_SYSTEM from '@salesforce/schema/CLQ_Corrective_Action_Plan__c.CLQ_Planned_changes_in_system_Procedure__c';
import RESPONSIBLE_PERSON from '@salesforce/schema/CLQ_Corrective_Action_Plan__c.CLQ_Responsibleperson_for_Implementation__c';
import INSPECTION_NAME from '@salesforce/schema/CLQ_Inspection__c.Name';
import INSPECTION_TYPE from '@salesforce/schema/CLQ_Inspection__c.CLQ_Inspection_Type__c';
import INSPECTION_STATUS from '@salesforce/schema/CLQ_Inspection__c.CLQ_Inspection_Status__c';
import VISIT_STATUS from '@salesforce/schema/CLQ_Inspection__c.CLQ_Visit_Status__c';
import REVIEWER_COMMENT from '@salesforce/schema/CLQ_Corrective_Action_Plan__c.CLQ_Reviewer_Comments__c'; 

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CapSummary extends LightningElement {
    queryParams;
    inspectionCaps;
    mode = 'edit';
    inspectionID;
    fields = [SHORT_TERM_ACTION, PLANNED_CHANGES_IN_SYSTEM, RESPONSIBLE_PERSON];
    inspectionFIelds = [INSPECTION_NAME, INSPECTION_TYPE, INSPECTION_STATUS, VISIT_STATUS];
    CapDisableFields = [ REVIEWER_COMMENT];
    isSaving = false;
    isLoading = false;
    activeActionCap = [];
    activeUnderProcessCap = [];
    activeApprovedCap = [];
    showFileModal = false;
    documentId;

    get acceptedFormats() {
        return ['.pdf'];
    }

    getCAPInfo() {
        this.isSaving = true;
        this.inspectionID = this.queryParams.inspectionId != null && this.queryParams.inspectionId != undefined ? this.queryParams.inspectionId : '';
        //a1H6w0000004cCrEAI
        if (this.inspectionID != '') {
            delegateRequest({ className: 'CAPSummaryCtrl', methodName: 'getInspectionCaps', jsonParam: this.inspectionID, validationMethodName: '', bValidate: false })
                .then(result => {
                    console.log(result);
                    this.isLoading = false;
                    this.isSaving = false;
                    let response = JSON.parse(result);

                    this.inspectionCaps = response.data.CAPS;
                }).catch(error => {
                    this.isLoading = false;
                    this.isSaving = false;
                    console.log(error);
                });
        }
    }

    connectedCallback() {
        this.queryParams = this.getQueryParameters();
        this.isLoading = true;
        this.getCAPInfo();
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        this.isSaving = true;
        console.log(event.target.id);
        const fields = event.detail.fields;
        fields.CLQ_CAP_Status__c = 'Submitted';
        fields.CLQ_Review_Requested__c = 'Yes';
        this.template.querySelector(`lightning-record-form[id="${event.target.id}"]`).submit(fields);
    }

    handleSuccess(event) {
        this.isSaving = false;
        const evt = new ShowToastEvent({
            title: "CAP",
            message: "CAP updated successfully",
            variant: "success"
        });
        this.dispatchEvent(evt);

        this.getCAPInfo();
    }

    /* Shows toast message
     * @param title Title for toast message
     * @param message Message for toast message
     * @param variant Variant for toast message
     */
    showToastMessage = (title, message, variant, mode) => {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    };

    handleError(event) {
        this.isSaving = false;
        console.log(JSON.stringify(event.detail));
        this.showToastMessage('Status', event.detail.message, 'error', 'sticky');
    }

    /**
     * Obtains query parameters from window.location.search
     */
    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    closeModal(event) {
        this.showFileModal = false;
    }

    handleUploadDocument(event) {
        let capId = event.target.name;
        this.documentId = capId;
        this.showFileModal = true;
        console.log(capId);
    }

    handleUploadFinished(event) {
        this.showFileModal = false;
        this.showToastMessage('Status', 'File uploaded successfully', 'success', 'dismissable');
        const uploadedFiles = event.detail.files;

        let request = {
            fileName: uploadedFiles.Name,
            documentId: uploadedFiles.documentId,
            capId: this.documentId,
            inspectionId: this.inspectionID
        }

        delegateRequest({ className: 'CAPSummaryCtrl', methodName: 'createCAPDocument', jsonParam: JSON.stringify(request) })
            .then(result => {
                console.log(result);
                this.isLoading = false;
                this.isSaving = false;
                let response = JSON.parse(result);

                this.getCAPInfo();

            }).catch(error => {
                this.isLoading = false;
                this.isSaving = false;
                console.log(error);
            });

    }

    handleActionToggleSection(event) {

    }

    handleUnderProcessToggleSection(event) {

    }

    handleApprovedToggleSection(event) {

    }
}