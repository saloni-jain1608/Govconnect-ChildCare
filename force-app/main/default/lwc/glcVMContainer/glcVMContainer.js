import { LightningElement, api, wire } from 'lwc';
import { consoleLog, handleApexImpCall } from 'c/glcBaseModule';
import getInitData from "@salesforce/apex/CLQ_VisitModeController_Lightning.getInitData";
import saveData from "@salesforce/apex/CLQ_VisitModeController_Lightning.saveData";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import INSPECTION_TYPE from '@salesforce/schema/CLQ_Inspection__c.CLQ_Inspection_Type__c';
import INSPECTION_STATUS from '@salesforce/schema/CLQ_Inspection__c.CLQ_Inspection_Status__c';
import INSPECTION_OWNER from '@salesforce/schema/CLQ_Inspection__c.OwnerId';
import INSPECTION_ID from '@salesforce/schema/CLQ_Inspection__c.Id';
import INSPECTION_VISIT_STATUS from '@salesforce/schema/CLQ_Inspection__c.CLQ_Visit_Status__c';
import INSPECTION_CAP_GENERATED from '@salesforce/schema/CLQ_Inspection__c.CLQ_CAP_Generated__c';
import CLQ_NonCompliant_Results from '@salesforce/label/c.CLQ_NonCompliant_Results';
import { NavigationMixin } from 'lightning/navigation';

export default class GlcVMContainer extends NavigationMixin(LightningElement) {

    //@api recordId = 'a1H6w0000004bLX';
    @api recordId;
    domainOptions;
    filterOptions;
    resultOptions;
    ruleResultOptions;
    domainWrapperList = [];
    inspectionNumber = 'Inspection# 000009';
    activeSectionName;
    showSpinner = true;
    currentUserId = Id;
    visitComplete = false;
    //inspectionType;
    //inspectionOwner;
    showFilter = false;

    //Search and Filter
    searchResult = '';
    searchDomain = '';
    applyResult = '';
    searched = false;

    @wire(getRecord, { recordId: '$recordId', fields: [INSPECTION_TYPE, INSPECTION_OWNER, INSPECTION_STATUS,INSPECTION_VISIT_STATUS] })
    inspectionRecord;

    /*@wire(getRecord, { recordId: recordId, fields: FIELDS })
    inspectionRecord({ error, data }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else {
            console.log(JSON.stringify(data));
            this.inspectionType = data.fields.CLQ_Inspection_Type__c.value;
            this.inspectionOwner = data.fields.OwnerId.value;
        }
    }*/

    constructor() {
        super();
        this.template.addEventListener('resultChange', this.handleResultChange.bind(this));
        this.template.addEventListener('findingComplete', this.handleFindingComplete.bind(this));
    }

    connectedCallback() {
        handleApexImpCall(this, getInitData, (promiseresult) => {

            console.log(JSON.stringify(promiseresult.objectData));

            if (promiseresult.objectData != null) {

                if (promiseresult.objectData.domainOptions != null) {
                    this.domainOptions = promiseresult.objectData.domainOptions;
                }

                if (promiseresult.objectData.filterOptions != null) {
                    this.filterOptions = promiseresult.objectData.filterOptions;
                }

                if (promiseresult.objectData.resultOptions != null) {
                    this.resultOptions = promiseresult.objectData.resultOptions;
                }

                if (promiseresult.objectData.domainRuleWrapperList != null) {
                    this.domainWrapperList = promiseresult.objectData.domainRuleWrapperList;
                }

                if (promiseresult.objectData.inspectionNumber != null) {
                    this.inspectionNumber = promiseresult.objectData.inspectionNumber;
                }

                this.showSpinner = false;

            }

        },
            {
                "inspectionRecId": this.recordId
            });
    }

    handleSectionToggle(event) {
        this.activeSectionName = event.detail.openSections;
    }

    handleResultChange(event) {
        const { ruleRecord } = event.detail;
        let domainWrapperListUpdated = JSON.parse(JSON.stringify(this.domainWrapperList));
        domainWrapperListUpdated.forEach(domain => {
            domain.rulelist.forEach(rule => {
                if (rule.ruleRecord.Id === ruleRecord.Id) {
                    rule.ruleRecord = ruleRecord;
                    console.log('Inside Update Part');
                }
            });
        });
        this.domainWrapperList = domainWrapperListUpdated;
        console.log('Domain Wrapper List --> ' + JSON.stringify(this.domainWrapperList));
    }

    handleFindingComplete(event) {
        console.log('Handle Finding Complete called');
        const { ruleRecord, findingCode, findingDescription, findingTADescription } = event.detail;
        let domainWrapperListUpdated = JSON.parse(JSON.stringify(this.domainWrapperList));
        domainWrapperListUpdated.forEach(domain => {
            domain.rulelist.forEach(rule => {
                if (rule.ruleRecord.Id === ruleRecord.Id) {
                    rule.ruleRecord = ruleRecord;
                    rule.sfindingCode = findingCode;
                    rule.sfindingDescription = findingDescription;
                    rule.sfindingTADescription = findingTADescription;
                    console.log('Inside Update Part');
                }
            });
        });
        this.domainWrapperList = domainWrapperListUpdated;
        console.log('Domain Wrapper List --> ' + JSON.stringify(this.domainWrapperList));
    }

    handleSave() {
        console.log('JSON --> ' + JSON.stringify(this.domainWrapperList));
        this.showSpinner = true;

        let requestBeforeApexCall = JSON.parse(JSON.stringify(this.domainWrapperList));
        requestBeforeApexCall.forEach(domain => {
            domain.rulelist.forEach(rule => {
                console.log('Inside Rule');
                let ruleRecUpd = rule.ruleRecord;
                console.log('Inside Rule');
                if (ruleRecUpd.Findings__r && ruleRecUpd.Findings__r.length > 0) {
                    ruleRecUpd.Findings__r = this.rewriteArray(ruleRecUpd.Findings__r);
                    rule.ruleRecord = ruleRecUpd;
                }
            });
        });

        console.log('Execution Complete');

        handleApexImpCall(this, saveData, (promiseresult) => {

            console.log(JSON.stringify(promiseresult.objectData));

            if (promiseresult.objectData != null && promiseresult.objectData.saveStatus === 'Success') {
                if (!this.visitComplete) {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Visit Data Saved Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                }
                this.showSpinner = false;
                if (this.visitComplete) {
                    this.handleVisitCompletion();
                }
            }

        },
            {
                "domainRuleWrapperListJson": JSON.stringify(requestBeforeApexCall)
            });
    }

    handleComplete() {
        let bValidationSuccess = true;
        console.log(JSON.stringify(this.currentUserId));
        console.log(JSON.stringify(this.inspectionOwner));
        if (this.inspectionOwner != this.currentUserId) {
            bValidationSuccess = false;
        }

        if (!bValidationSuccess) {
            this.showNotification('Error', 'Only Inspection Owner can complete the visit mode', 'error');
            return;
        }

        //Result Validation

        if (bValidationSuccess) {
            this.domainWrapperList.forEach(domain => {
                domain.rulelist.forEach(rule => {
                    console.log(rule.ruleRecord.CLQ_Result__c);
                    if (!rule.ruleRecord.CLQ_Result__c) {
                        bValidationSuccess = false;
                    }
                });
            });
        }

        if (!bValidationSuccess) {
            this.showNotification('Error', 'Update the result for all applicable rules. At least one Rule does not have a Result selected.', 'error');
            return;
        }

        let nonComplainceResults = CLQ_NonCompliant_Results.split(';');
        if (bValidationSuccess) {
            this.domainWrapperList.forEach(domain => {
                domain.rulelist.forEach(rule => {
                    console.log(rule.sfindingCode);
                    if (!rule.sfindingCode && nonComplainceResults.includes(rule.ruleRecord.CLQ_Result__c)) {
                        bValidationSuccess = false;
                    }
                });
            });
        }

        if (!bValidationSuccess) {
            this.showNotification('Error', 'Select at-least one finding for all Non-Compliant or Substantiated rules', 'error');
            return;
        }

        this.visitComplete = true;
        this.handleSave();
    }

    handleVisitCompletion() {

        console.log('Visit Completion Fired');
        const selectedEvent = new CustomEvent('visitCompleted', { detail: { completed: "true" } });
        this.dispatchEvent(selectedEvent);
        /*this.showSpinner = true;
        const fields = {};

        fields[INSPECTION_ID.fieldApiName] = this.recordId;
        fields[INSPECTION_VISIT_STATUS.fieldApiName] = 'Visit Completed';
        if (this.inspectionStatus != 'Approved' && this.inspectionStatus != 'Closed' && this.inspectionStatus != 'Revised') {
            fields[INSPECTION_CAP_GENERATED.fieldApiName] = true;
        }
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showNotification('Success', 'Visit Completed Successfully', 'success');
                this.showSpinner = false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'CLQ_Inspection__c', // objectApiName is optional
                        actionName: 'view'
                    }
                });

            })
            .catch(error => {
                console.log(JSON.stringify(error));
                this.showSpinner = false;
            });*/
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CLQ_Inspection__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    handleSearchResultChange(event) {
        this.searchResult = event.detail.value;
        this.searched = false;
    }

    handleSearchDomainChange(event) {
        this.searchDomain = event.detail.value;
        this.searched = false;
    }

    handleApplyResultChange(event) {
        this.applyResult = event.detail.value;
    }

    handleSearch() {
        let searchResultInput = this.template.querySelector('[data-id="search-result-input"]');
        searchResultInput.reportValidity();

        let searchDomainInput = this.template.querySelector('[data-id="search-domain-input"]');
        searchDomainInput.reportValidity();

        let bValid = false;

        if (searchResultInput.value && searchDomainInput.value) {
            bValid = true;
        }

        if (bValid) {

            let updatedDomainWrapperList = JSON.parse(JSON.stringify(this.domainWrapperList));
            this.showSpinner = true;

            console.log(this.searchResult);
            console.log(this.searchDomain);

            if (this.searchResult === 'All' && this.searchDomain === 'All') {
                updatedDomainWrapperList.forEach(domain => {
                    domain.showDomain = true;
                    domain.rulelist.forEach(rule => {
                        rule.showRule = true;
                    });
                });
            } else if (this.searchResult != 'All' && this.searchDomain === 'All') {
                updatedDomainWrapperList.forEach(domain => {
                    let bShowDomain = false;
                    domain.rulelist.forEach(rule => {
                        if (this.searchResult === rule.ruleRecord.CLQ_Result__c) {
                            rule.showRule = true;
                            bShowDomain = true;
                        } else {
                            rule.showRule = false;
                        }
                        domain.showDomain = bShowDomain;
                    });
                });
            } else if (this.searchResult === 'All' && this.searchDomain != 'All') {
                updatedDomainWrapperList.forEach(domain => {
                    if (domain.domainName === this.searchDomain) {
                        domain.showDomain = true;
                        domain.rulelist.forEach(rule => {
                            rule.showRule = true;
                        });
                    } else {
                        domain.showDomain = false;
                        domain.rulelist.forEach(rule => {
                            rule.showRule = false;
                        });
                    }
                });
            } else {
                updatedDomainWrapperList.forEach(domain => {
                    let bShowDomain = false;
                    domain.rulelist.forEach(rule => {
                        if (domain.domainName === this.searchDomain && this.searchResult === rule.ruleRecord.CLQ_Result__c) {
                            rule.showRule = true;
                            bShowDomain = true;
                        } else {
                            rule.showRule = false;
                        }
                        domain.showDomain = bShowDomain;
                    });
                });
            }

            this.domainWrapperList = updatedDomainWrapperList;
            this.showSpinner = false;
            this.searched = true;
        }
    }

    handleApply() {
        let applyResultInput = this.template.querySelector('[data-id="apply-result-input"]');
        applyResultInput.reportValidity();

        let bValid = false;

        if (applyResultInput.value) {
            bValid = true;
        }

        if (bValid) {
            let updatedDomainWrapperList = JSON.parse(JSON.stringify(this.domainWrapperList));
            this.showSpinner = true;

            updatedDomainWrapperList.forEach(domain => {

                if (domain.showDomain) {
                    domain.rulelist.forEach(rule => {
                        if (rule.showRule) {
                            rule.ruleRecord.CLQ_Result__c = this.applyResult;
                        }
                    });
                }
            });

            this.domainWrapperList = updatedDomainWrapperList;
            this.showSpinner = false;

        }
    }

    showNotification(toastTitle, toastMessage, toastVariant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant
        });
        this.dispatchEvent(evt);
    }

    rewriteArray(lstRecords) {
        console.log('Rewrite Called');
        let returnObj = {};
        returnObj.totalSize = lstRecords.length;
        returnObj.done = true;
        returnObj.records = lstRecords;
        /*lstRecords.forEach(record => {
            returnObj.records.push(record);
        });*/
        return returnObj;
    }

    toggleFilter() {
        this.showFilter = !this.showFilter;
        if (!this.showFilter) {
            this.clearFilter();
        }
    }

    clearFilter() {

        this.showSpinner = true;

        let updatedDomainWrapperList = JSON.parse(JSON.stringify(this.domainWrapperList));

        updatedDomainWrapperList.forEach(domain => {
            domain.showDomain = true;
            domain.rulelist.forEach(rule => {
                rule.showRule = true;
            });
        });

        this.domainWrapperList = updatedDomainWrapperList;
        this.showSpinner = false;
    }

    get searchResultValues() {
        let options = [];
        if (this.filterOptions) {
            this.filterOptions.forEach(option => {
                options.push({
                    label: option,
                    value: option
                });
            });
        }
        return options;
    }

    get searchDomainValues() {
        let options = [];
        if (this.domainOptions) {
            this.domainOptions.forEach(option => {
                options.push({
                    label: option,
                    value: option
                });
            });
        }
        return options;
    }

    get applyResultValues() {
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

    get contentClass() {
        if (this.showFilter) {
            return 'slds-col slds-size_9-of-12';
        }
        return 'slds-col slds-size_12-of-12';
    }

    get filterClass() {
        if (this.showFilter) {
            return 'slds-col slds-size_3-of-12';
        }
        return '';
    }

    get displayData() {
        if (this.searched && this.searchDomain && this.searchResult) {

        } else {
            return this.domainWrapperList;
        }
    }

    get inspectionType() {
        return getFieldValue(this.inspectionRecord.data, INSPECTION_TYPE);
    }

    get inspectionOwner() {
        return getFieldValue(this.inspectionRecord.data, INSPECTION_OWNER);
    }

    get inspectionStatus() {
        return getFieldValue(this.inspectionRecord.data, INSPECTION_STATUS);
    }

    get inspectionVisitStatus() {
        return getFieldValue(this.inspectionRecord.data, INSPECTION_VISIT_STATUS);
    }


}