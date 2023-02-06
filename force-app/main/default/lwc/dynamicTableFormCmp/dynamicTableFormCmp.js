import { LightningElement, api, track, wire } from 'lwc';
import delegateRequest from '@salesforce/apex/RequestController.delegateRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Fetch_lang_metadata from '@salesforce/apex/vdssCommunityProgramsMain.Fetch_lang_metadata';

export default class DynamicTableFormCmp extends LightningElement {
    @api subSectionInfo;
    @api programId;
    @api programTransactionId;
    @api languageselected;
    @track languagedata;
    @track New_Record='New Record';
    @track Close='Close';
    @track Cancel='Cancel';
    @track Save_Record='Save Record';
    @track Create_New='Create New';
    @track Next='Next';
    @track showtable=false;
    queryParams;
    tableHeaders;
    tableData = [];
    showModal = false;
    showMultiModel = false;
    objectApiName = '';
    lookupObjectApiName = '';
    formFields = [];
    parentFormFields = [];
    recordTypeId = '';
    hasRecordType = false;
    hasParentForm = false;
    showParentForm = true;
    parentRecordId;
    tableFields = [];

    @wire(Fetch_lang_metadata,{language:'$languageselected'})
    langData({ error, data }){
        if(data){
            console.log('Metadata in dynamicformtable:',data);
            this.languagedata=data;
            this.New_Record=this.languagedata.find(data => data.English__c === 'New Record').Language_Selected__c; 
            this.Close=this.languagedata.find(data => data.English__c === 'Close').Language_Selected__c; 
            this.Cancel=this.languagedata.find(data => data.English__c === 'Cancel').Language_Selected__c; 
            this.Save_Record=this.languagedata.find(data => data.English__c === 'Save Record').Language_Selected__c; 
            this.Create_New=this.languagedata.find(data => data.English__c === 'Create New').Language_Selected__c; 
            this.Next=this.languagedata.find(data => data.English__c === 'Next').Language_Selected__c;
        }
        else if (error) {
            window.console.log('error ====> ' + JSON.stringify(error));
        }
    }

  

    connectedCallback() {
        /*Fetch_lang_metadata({language:this.languageselected})
        .then(data=>{
            console.log('Metadata in dynamicformtable:',data);
            this.languagedata=data;
            this.New_Record=this.languagedata.find(data => data.English__c === 'New Record').Language_Selected__c; 
            this.Close=this.languagedata.find(data => data.English__c === 'Close').Language_Selected__c; 
            this.Cancel=this.languagedata.find(data => data.English__c === 'Cancel').Language_Selected__c; 
            this.Save_Record=this.languagedata.find(data => data.English__c === 'Save Record').Language_Selected__c; 
            this.Create_New=this.languagedata.find(data => data.English__c === 'Create New').Language_Selected__c; 
            this.Next=this.languagedata.find(data => data.English__c === 'Next').Language_Selected__c;
        })*/
        //this.queryParams = this.getQueryParameters();
        console.log('subsection info:',this.subSectionInfo);
        let formComponents = this.subSectionInfo.FormComponents;
        let tableInfo = this.subSectionInfo.TableInfo;

        if (tableInfo != null && tableInfo.length > 0) {
            for (let i = 0; i < tableInfo.length; i++) {
                this.tableFields.push(tableInfo[i].FieldName);
            }
        }

        console.log('table fields:', JSON.stringify(this.tableFields));

        if (formComponents != null && formComponents.length > 0) {
            for (let i = 0; i < formComponents.length; i++) {
                console.log('formComponents:',formComponents[i]);
                if (formComponents[i].FieldName.indexOf('__r') > 0) {
                    this.hasParentForm = true;
                    this.parentFormFields.push({'FieldName':formComponents[i].FieldName.split(".")[1],'Label':formComponents[i].Label});
                } else {
                    
                    console.log('fieldname:',formComponents[i].FieldName);
                    this.formFields.push({'FieldName':formComponents[i].FieldName,'Label':formComponents[i].Label});
                }
            }
        }

        this.getTableData();
    }

    @api getTableData() {
        console.log('===================Calling getTableData===========================');
        console.log('program transaction id:',this.programTransactionId);
        let request = {
            objectName: this.subSectionInfo.ObjectName,
            tableInfo: this.subSectionInfo.TableInfo,
            whereClause: this.subSectionInfo.WhereClause,
            recordTypeName: this.subSectionInfo.RecordType,
            programID: this.programId,
            programTransactionID: this.programTransactionId
        }

        //this.isLoading = true;
        delegateRequest({ className: 'DynamicTableFormCtrl', methodName: 'getTableData', jsonParam: JSON.stringify(request), validationMethodName: null, bValidate: false })
            .then(result => {
                console.log('getTableData:',result);
                
                this.isLoading = false;

                let response = JSON.parse(result);
                this.recordTypeId = response.data.RecordTypeId;
                if (this.recordTypeId != '') {
                    this.hasRecordType = true;
                }
                this.tableHeaders = response.data.TableHeaders;
                console.log('tabledata:',response.data.TableData.length);
                if(response.data.TableData.length != 0){
                    this.showtable=true;
                }
                this.tableData = [];
                for (let i = 0; i < response.data.TableData.length > 0; i++) {
                    let tableRow = {};
                    tableRow.Id = i;


                    let tableKeys = Object.keys(response.data.TableData[i]);
                    let tableColumns = [];

                    for (let k = 0; k < this.tableFields.length; k++) {
                        let tableField = this.tableFields[k];

                        console.log('Line 91: ' + tableField);

                        if (tableField.indexOf('__r') > 0) {
                            let parentRelation = tableField.split(".")[0];
                            let parentField = tableField.split(".")[1];

                            console.log('Line 97: ' + parentRelation);
                            console.log('Line 98: ' + parentField);

                            for (let j = 0; j < tableKeys.length; j++) {
                                let tableKey = tableKeys[j];

                                if (tableKey != 'Id' && tableKey != 'attributes') {
                                    if (parentRelation == tableKey) {
                                        let parentData = response.data.TableData[i][tableKey];
                                        tableColumns.push(parentData[parentField]);

                                        console.log('Line 108: ' + parentData[parentField]);
                                        break;
                                    }
                                }
                            }
                        } else {
                            for (let j = 0; j < tableKeys.length; j++) {
                                let tableKey = tableKeys[j];

                                if (tableKey != 'Id' && tableKey != 'attributes') {
                                    if (tableField == tableKey) {
                                        tableColumns.push(response.data.TableData[i][tableKey]);

                                        console.log('Line 121: ' + response.data.TableData[i][tableKey]);
                                        break;
                                    }
                                }
                            }
                        }

                    }

                    tableRow.Columns = tableColumns;
                    this.tableData.push(tableRow);

                    console.log('Line 133: ' + this.tableData);
                }
            }).catch(error => {
                this.isLoading = false;
                console.log(error);
            });
    }

    handleNewClick(event) {
        this.objectApiName = this.subSectionInfo.ObjectName;
        this.showModal = true;
    }

    handleNewMultiClick(event) {
        this.objectApiName = this.subSectionInfo.ObjectName;
        this.lookupObjectApiName = this.subSectionInfo.LookupObjectName;
        this.showMultiModel = true;
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    closeModal(event) {
        this.showModal = false;
        this.showMultiModel = false;
        this.showParentForm = true;
    }

    handleClick(event) {
        console.log(event.target.dataset);
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        if (this.objectApiName == 'CLQ_Role__c') {
            fields.CLQ_Program_Transaction_Source__c = this.programTransactionId;
            fields.CLQ_Program__c = this.programId;
        } else {
            fields.CLQ_Program_Transaction__c = this.programTransactionId;
            fields.CLQ_Program__c = this.programId;
        }

        if (this.recordTypeId != '') {
            //fields.recordTypeId = this.recordTypeId;
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showModal = false;
        //this.getTableData();
    }

    handleChildSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        if (this.objectApiName == 'CLQ_Role__c') {
            fields.CLQ_Contact__c = this.parentRecordId;
            fields.CLQ_Program_Transaction_Source__c = this.programTransactionId;
            fields.CLQ_Program__c = this.programId;
        } else {
            fields.CLQ_Program_Transaction__c = this.programTransactionId;
            fields.CLQ_Program__c = this.programId;
        }

        if (this.recordTypeId != '') {
            //fields.recordTypeId = this.recordTypeId;
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showModal = false;
        //this.getTableData();
    }

    handleParentSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        console.log(event);
        this.showToastMessage('Status', 'Record created successfully', 'success', 'dismissable');
        this.getTableData();
    }

    handleChildSuccess(event) {
        console.log(event);
        this.showToastMessage('Status', 'Record created successfully', 'success', 'dismissable');
        this.showMultiModel = false;
        this.showParentForm = true;
        this.getTableData();
    }

    handleParentSuccess(event) {
        console.log(event);
        this.showParentForm = false;
        this.parentRecordId = event.detail.id;
    }

    handleError(event) {
        console.log(JSON.stringify(event.detail));
        if (event.detail.message != 'The requested resource does not exist') {
            this.showToastMessage('Status', event.detail.message, 'error', 'sticky');
        } else {
            this.showToastMessage('Status', 'Record created successfully', 'success', 'dismissable');
        }
        this.getTableData();
    }

    handleChildError(event) {
        console.log(JSON.stringify(event.detail));
        if (event.detail.message != 'The requested resource does not exist') {
            this.showToastMessage('Status', event.detail.message, 'error', 'sticky');
        } else {
            this.showToastMessage('Status', 'Record created successfully', 'success', 'dismissable');
        }
        this.getTableData();
    }

    handleParentError(event) {
        console.log(JSON.stringify(event.detail));
        this.showToastMessage('Status', event.detail.message, 'error', 'sticky');
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
}