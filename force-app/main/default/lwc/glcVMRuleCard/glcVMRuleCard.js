import { LightningElement, api, track } from 'lwc';
import { consoleLog, handleApexImpCall } from 'c/glcBaseModule';
import loadFindings from "@salesforce/apex/CLQ_VisitModeController_Lightning.loadFindings";

export default class GlcVMRuleCard extends LightningElement {
    @api ruleRecord = {
        "attributes": {
            "type": "CLQ_Rules_Inspected__c",
            "url": "/services/data/v50.0/sobjects/CLQ_Rules_Inspected__c/a1a6w000000H3u0AAC"
        },
        "Id": "a1a6w000000H3u0AAC",
        "IsDeleted": false,
        "Name": "RI#-000121",
        "CreatedDate": "2020-11-19T20:02:50.000+0000",
        "CreatedById": "0056w000000EEV0AAO",
        "LastModifiedDate": "2020-11-29T15:40:12.000+0000",
        "LastModifiedById": "0056w000000EEV0AAO",
        "SystemModstamp": "2020-11-29T15:40:12.000+0000",
        "LastViewedDate": "2020-11-29T15:40:12.000+0000",
        "LastReferencedDate": "2020-11-29T15:40:12.000+0000",
        "CLQ_Inspection_No__c": "a1H6w0000004bLXEAY",
        "CLQ_Alleged_Rule__c": false,
        "CLQ_Domain_Rule__c": "a1A6w0000008c6REAQ",
        "CLQ_LRNC__c": 0,
        "CLQ_MRNC__c": 0,
        "CLQ_Result__c": "Non-Compliant",
        "CLQ_Risk_Points__c": 12.00,
        "CLQ_Rule_Short_Name__c": "3301-37:02:05 Health & Safety",
        "CLQ_SRNC__c": 12,
        "CLQ_hasSeriousRiskFinding__c": false,
        "CLQ_isFocused__c": false,
        "CLQ_Allegation_Description__c": "This is a very bad allegation",
        "Findings__r": {
            "totalSize": 2,
            "done": true,
            "records": [{
                "attributes": {
                    "type": "CLQ_Findings__c",
                    "url": "/services/data/v50.0/sobjects/CLQ_Findings__c/a1E6w000003YXmoEAG"
                },
                "CLQ_Rules_Inspected__c": "a1a6w000000H3u0AAC",
                "Id": "a1E6w000003YXmoEAG",
                "CLQ_Domain_Rule_Finding__c": "a196w00000004EwAAI",
                "CLQ_Description__c": "On  the day of the inspection and a review of medication and medication records, the wrong medication dosage was administered to a child.",
                "CLQ_Domain_Rule_Finding__r": {
                    "attributes": {
                        "type": "CLQ_Domain_Rule_Finding__c",
                        "url": "/services/data/v50.0/sobjects/CLQ_Domain_Rule_Finding__c/a196w00000004EwAAI"
                    },
                    "CLQ_Standard_Finding__c": "a1j6w0000004HSjAAM",
                    "Id": "a196w00000004EwAAI",
                    "CLQ_Standard_Finding__r": {
                        "attributes": {
                            "type": "CLQ_Standard_Findings__c",
                            "url": "/services/data/v50.0/sobjects/CLQ_Standard_Findings__c/a1j6w0000004HSjAAM"
                        },
                        "CLQ_Finding_Code__c": "02 O5b",
                        "Name": "Wrong medication dosage administered",
                        "Id": "a1j6w0000004HSjAAM"
                    }
                }
            }, {
                "attributes": {
                    "type": "CLQ_Findings__c",
                    "url": "/services/data/v50.0/sobjects/CLQ_Findings__c/a1E6w000003YXmpEAG"
                },
                "CLQ_Rules_Inspected__c": "a1a6w000000H3u0AAC",
                "Id": "a1E6w000003YXmpEAG",
                "CLQ_Domain_Rule_Finding__c": "a196w00000004D5AAI",
                "CLQ_Description__c": "On the day of the inspection and a review of medication records it was noted that medication was administered to the wrong child.",
                "CLQ_Domain_Rule_Finding__r": {
                    "attributes": {
                        "type": "CLQ_Domain_Rule_Finding__c",
                        "url": "/services/data/v50.0/sobjects/CLQ_Domain_Rule_Finding__c/a196w00000004D5AAI"
                    },
                    "CLQ_Standard_Finding__c": "a1j6w0000004HSSAA2",
                    "Id": "a196w00000004D5AAI",
                    "CLQ_Standard_Finding__r": {
                        "attributes": {
                            "type": "CLQ_Standard_Findings__c",
                            "url": "/services/data/v50.0/sobjects/CLQ_Standard_Findings__c/a1j6w0000004HSSAA2"
                        },
                        "CLQ_Finding_Code__c": "02 O5a",
                        "Name": "Medication dispensed to wrong child",
                        "Id": "a1j6w0000004HSSAA2"
                    }
                }
            }]
        },
        "CLQ_Domain_Rule__r": {
            "attributes": {
                "type": "CLQ_Domain_Rule__c",
                "url": "/services/data/v50.0/sobjects/CLQ_Domain_Rule__c/a1A6w0000008c6REAQ"
            },
            "CLQ_Rule__c": "a1Z6w0000001t1YEAQ",
            "CLQ_Domain__c": "a1B6w000000WcoNEAS",
            "Id": "a1A6w0000008c6REAQ",
            "CLQ_Rule__r": {
                "attributes": {
                    "type": "CLQ_Rule__c",
                    "url": "/services/data/v50.0/sobjects/CLQ_Rule__c/a1Z6w0000001t1YEAQ"
                },
                "Name": "3301-37:02",
                "CLQ_Description__c": "Child is left unattended outside of facility/building or during a swimming activity A child left unattended on a field trip or in a vehicle or, otherwise, transportation policies are not followed.",
                "CLQ_Description_Text__c": "Child is left unattended outside of facility/building or during a swimming activity A child left unattended on a field trip or in a vehicle or, otherwise, transportation policies are not followed.",
                "CLQ_Short_Name__c": "3301-37:02:05 Health & Safety",
                "CLQ_Long_Name__c": "Compliance And Investigation",
                "Id": "a1Z6w0000001t1YEAQ"
            },
            "CLQ_Domain__r": {
                "attributes": {
                    "type": "CLQ_Domain__c",
                    "url": "/services/data/v50.0/sobjects/CLQ_Domain__c/a1B6w000000WcoNEAS"
                },
                "Name": "00 License & Approvals",
                "Id": "a1B6w000000WcoNEAS"
            }
        }
    };

    @api sfindingCode = 'Medication dispensed to wrong child<br>Wrong medication dosage administered';

    @api resultOptions = [];
    showModal = false;
    @track findingWrapperList;

    constructor() {
        super();
        this.template.addEventListener('findingPopupResponse', this.handleFindingResponse.bind(this));
    }

    connectedCallback() {
        console.log(JSON.stringify(this.resultOptions));
        console.log(JSON.stringify(this.resultOptions));
        console.log(JSON.stringify(this.resultOptions));
    }

    handleResultChange(event) {
        console.log('Method Called');
        let selectedResult = event.detail.value;
        let ruleRecModified = JSON.parse(JSON.stringify(this.ruleRecord));
        console.log(JSON.stringify(ruleRecModified));
        ruleRecModified.CLQ_Result__c = selectedResult;
        this.ruleRecord = ruleRecModified;
        if (selectedResult != '--None--') {
            const selectedEvent = new CustomEvent('resultChange', { detail: { ruleRecord: ruleRecModified }, bubbles: true });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleEditFindings() {
        handleApexImpCall(this, loadFindings, (promiseresult) => {
            console.log('findings are ->' + JSON.stringify(promiseresult.objectData));

            if (promiseresult.objectData != null && promiseresult.objectData.popupWrapperList != null) {
                this.findingWrapperList = promiseresult.objectData.popupWrapperList;
                this.showModal = true;
            }

        },
            {
                "selectedRule": this.ruleRecord.CLQ_Domain_Rule__c,
                "selectedInspectedRule": this.ruleRecord.Id,
                "resultSelected": this.ruleRecord.CLQ_Result__c,
                "inspectionRecordId": this.ruleRecord.CLQ_Inspection_No__c
            });
    }

    handleFindingResponse(event) {
        console.log('Rule Card Handler Called');
        const { findingResponse, type } = event.detail;
        if (type === 'Complete') {
            console.log(findingResponse);
            console.log(JSON.stringify(findingResponse));
            let ruleRecModified = JSON.parse(JSON.stringify(this.ruleRecord));
            this.sfindingCode = findingResponse.sfindingCode;
            console.log('After finidng Code');
            let findingDescription = findingResponse.sfindingDescription;
            let findingTADescription = findingResponse.sfindingTADescription;
            ruleRecModified.CLQ_Risk_Points__c = findingResponse.nonCompliancePoint;
            ruleRecModified.CLQ_SRNC__c = findingResponse.srncPoint;
            ruleRecModified.CLQ_LRNC__c = findingResponse.lrncPoint;
            ruleRecModified.CLQ_MRNC__c = findingResponse.mrncPoint;
            if (findingResponse.newriskLevel && findingResponse.newriskLevel.includes('Serious')) {
                console.log('Inside');
                ruleRecModified.CLQ_hasSeriousRiskFinding__c = true;
            }
            this.ruleRecord = ruleRecModified;
            const selectedEvent = new CustomEvent('findingComplete', { detail: { ruleRecord: ruleRecModified, findingCode: this.sfindingCode, findingDescription: findingDescription, findingTADescription: findingTADescription }, bubbles: true });
            this.dispatchEvent(selectedEvent);
        }
        this.closeModal();
    }

    closeModal() {
        this.showModal = false;
    }

    get showAllegationDescription() {
        if (this.ruleRecord.CLQ_Allegation_Description__c) {
            return true;
        }
        return false;
    }

    get resultOptionValues() {
        let options = [];
        if (this.resultOptions) {
            this.resultOptions.forEach(option => {
                options.push({
                    label: option,
                    value: option
                });
            });
        }
        return options;
    }
}