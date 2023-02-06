import { LightningElement, api } from 'lwc';
import { consoleLog, handleApexImpCall } from 'c/glcBaseModule';
import saveFindings from "@salesforce/apex/CLQ_VisitModeController_Lightning.saveFindings";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GlcVMEditFindings extends LightningElement {
    @api popupWrapperList;
    @api ruleName;
    @api ruleResult;
    @api ruleRecordId;
    @api inspectionRecId;

    handleSave() {

        let textAreaList = this.template.querySelectorAll('lightning-textarea');
        let mapFindingCodeDesc = new Map();
        let bHasChanges = false;

        textAreaList.forEach(textArea => {
            console.log('Inside For');
            let findingCode = textArea.getAttribute('data-id');
            console.log('Finding Id --> ' + findingCode);
            mapFindingCodeDesc.set(findingCode, textArea.value);
        });

        let updatedPopupWrapperList = JSON.parse(JSON.stringify(this.popupWrapperList));
        updatedPopupWrapperList.forEach(wrapperVar => {
            let findingCode = wrapperVar.sFindingCode;
            if (mapFindingCodeDesc.has(findingCode)) {
                bHasChanges = true;
                wrapperVar.finding.CLQ_Description__c = mapFindingCodeDesc.get(findingCode);
            }
        });

        if (bHasChanges) {
            this.popupWrapperList = updatedPopupWrapperList;
        }

        console.log('JSON Request --> ' + JSON.stringify(this.popupWrapperList));

        handleApexImpCall(this, saveFindings, (promiseresult) => {

            const evt = new ShowToastEvent({
                title: 'Success',
                message: 'Findings Saved Successfully',
                variant: 'success'
            });
            this.dispatchEvent(evt);

            let findingResponse = promiseresult.objectData;

            const selectedEvent = new CustomEvent('findingPopupResponse', { detail: { findingResponse: findingResponse, type: 'Complete' }, bubbles: true });
            this.dispatchEvent(selectedEvent);

        },
            {
                "selectedInspectedRule": this.ruleRecordId,
                "resultSelected": this.ruleResult,
                "popupWrapperListJson": JSON.stringify(this.popupWrapperList),
                "inspectionRecordId": this.inspectionRecId
            });
    }

    handleCancel() {
        const selectedEvent = new CustomEvent('findingPopupResponse', { detail: { findingResponse: null, type: 'Close' }, bubbles: true });
        this.dispatchEvent(selectedEvent);
    }



}