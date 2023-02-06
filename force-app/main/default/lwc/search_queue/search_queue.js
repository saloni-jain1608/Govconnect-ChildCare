import { LightningElement,track, wire, api} from 'lwc';
// import server side apex class method 
import getBgList from '@salesforce/apex/fetchAllRelatedRecords.getBgList';
// import standard toast event 
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import Background_Check_Object from '@salesforce/schema/Background_Check__c';
import Application_Type_Field from '@salesforce/schema/Background_Check__c.Application_Type__c';
import Juvenile_Field from '@salesforce/schema/Background_Check__c.Juvenile__c';
import BackgroundCheckStatus_Field from '@salesforce/schema/Background_Check__c.Background_Check_Status__c';

//declaring columns for the lightning-datatable

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];
const columns = [
    { label: 'Consent Recd Date', fieldName: 'Consent_Received_Date__c', hideDefaultActions: "true",sortable: "true" },
    { label: 'First Name', fieldName: 'First_Name__c', hideDefaultActions: "true", sortable: "true" },
    { label: 'Last Name', fieldName: 'Last_Name__c', hideDefaultActions: "true", sortable: "true" },
    { label: 'Phone Number', fieldName: 'Phone_Number__c', hideDefaultActions: "true", sortable: "true" },
    { label: 'Email Address', fieldName: 'Email_Address__c', hideDefaultActions: "true",sortable: "true" },
    { label: 'Application Type', fieldName: 'Application_Type__c', hideDefaultActions: "true", sortable: "true" },
    {type: 'button', typeAttributes: {
        label: 'Process Application',
        name: 'View',
        title: 'Process Application',
        disabled: false,
        value: 'Process Application',
        iconPosition: 'left',
        variant: 'Base'
    }},
    /* {
        type: 'action',
        typeAttributes: { rowActions: actions }
    } */
    
    
];


export default class search_queue extends NavigationMixin(LightningElement) {
    
    @track contactsRecord = [];
    @track contactsFullRecords = [];
    @track idsList;
    @track firstName = '';
    @track lastName = '';
    @track ssn = '';
    @track dob = '';
    @track facilityName = '';
    @track facilityNum = '';
    @track countyList='';
    @track applicantName='';
    @track county = '';
    @track pageSize = 10;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track isPrev = true;
    @track isNext = true;
    @track isDisplay = false;
    @track isSearchclickedAlready = false;
    @track isLoading = false;
    @track sortBy;
    @track sortDirection;
    @track applicationType = '';
    @track juvenile = '';
    @track bgCheckStatus = '';
    @track consentReceivedDate = '';
    @api currentId ;
    @track currentParentIndex;
   @track  showform = true;
   
    columns = columns;
    @wire(getObjectInfo, { objectApiName: Background_Check_Object })
    objectInfo;

    @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: Application_Type_Field
    })
    appTypePicklistValues;

    @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: Juvenile_Field,BackgroundCheckStatus_Field
    })
    juvenilePicklistValues;

    @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: BackgroundCheckStatus_Field
    })
    bgStatusPicklistValues;

    
    applicationTypeChanged(event){
        this.applicationType = event.detail.value;
    }

    juvenileChanged(event){
        this.juvenile = event.detail.value;
    }

    statusChanged(event){
        this.bgCheckStatus = event.detail.value;
    }
    
    handleAccountSelection(event){
       this.county = event.detail;
    }

    /* edit(row) {
        alert(row);
        this.template.querySelector('c-navigate-to-lwc').despatch(row);
    } */
    //handle next
    handleNext(){
        this.pageNumber = this.pageNumber+1;
        this.copyValuestoCurrentPage();
    }
 
    //handle prev
    handlePrev(){
        this.pageNumber = this.pageNumber-1;
        this.copyValuestoCurrentPage();
    }

    copyValuestoCurrentPage(){
        let temp = [];
        for(let i=0;i<this.pageSize;i++){
            temp.push(this.contactsFullRecords[(this.pageNumber-1)*this.pageSize+i]);
            if(this.totalRecords == ((this.pageNumber-1)*this.pageSize+i +1) ){
                this.contactsRecord = temp;
                break;
            }
        }
        this.contactsRecord = temp;
        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
    }


    viewRecord(event) {
        this.currentId = event.detail.row.Id;
        console.log('Detail row'+event.detail.row);
        for(let i=0;i<this.totalRecords;i++){
            if(this.contactsFullRecords[i].Id == this.currentId){
                this.currentParentIndex = i;
                break;
            }
        }
        
        console.log(this.currentParentIndex);
        
        /*const actionName = event.detail.action.name;
        const row = event.detail.row;
        alert(actionName);
        alert(row);
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'edit':
                alert('hi');
               // this.edit(row);
             //  this.template.querySelector("c-child-component").despatch(row);
                
               this[NavigationMixin.Navigate]({
                type: "standard__navItemPage",
                attributes: {
                    apiName: "Background_detail",
                },
                state: {
                    recordList : this.idsList,
                    recordId : event.detail.row.Id,
                    currentIndex : 3,
                    
                }
            });
                break;
            default:
        } */
        //Navigate to Account record page
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.detail.row.Id,
                "objectApiName": "Background_Check__c",
                "actionName": "view"
            },
        }); 
        
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "Background_detail",
            },
            state: {
                recordId : event.detail.row.Id,
            }
        }); 
        let cmpDef = {
            componentDef: "c:childComponent"
        }
        let encodeDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodeDef
            },
        });*/

        this.showform = false;
    }

    // call apex method on button click 
    handleSearchKeyword() {
       //This logic is for resetting values when user tries to change input without clicking clear
        if(this.isSearchclickedAlready == true ){
            this.pageNumber = 1;
            this.totalRecords = 0;
            this.totalPages = 0;
            this.isPrev = true;
            this.isNext = true;
            this.isDisplay = false;
        }
        this.firstName = this.template.querySelector('lightning-input[data-id="in1"]').value;
        this.lastName = this.template.querySelector("lightning-input[data-id=in2]").value;
        this.ssn = this.template.querySelector("lightning-input[data-id=in3]").value;
        this.dob = this.template.querySelector("lightning-input[data-id=in4]").value;
        this.facilityName = this.template.querySelector("lightning-input[data-id=in5]").value;
        this.facilityNum = this.template.querySelector("lightning-input[data-id=in6]").value;
        this.applicantName = this.template.querySelector("lightning-input[data-id=in7]").value;
        //this.county = this.template.querySelector("lightning-input[data-id=in9]").value;
        this.consentReceivedDate = this.template.querySelector("lightning-input[data-id=in10]").value;

        console.log('hi  '+ this.firstName);
        console.log('lastName  '+ this.lastName);
        console.log('ssn  '+ this.ssn);
        console.log('dob  '+ this.dob);
        console.log('ssn  '+ this.facilityName);
        console.log('county  '+ this.county);

        let bgCheckRecord = { 'sobjectType': 'Background_Check__c' };
        bgCheckRecord.First_Name__c = this.firstName;
        bgCheckRecord.Last_Name__c = this.lastName;
        bgCheckRecord.ssn__c = this.ssn;
        bgCheckRecord.Date_of_Birth__c = this.dob;
        
        if (this.firstName !== '' || this.lastName !== '' || this.ssn !== '' || (this.dob !=='' && this.dob !== null) || this.facilityNum !== '' || this.facilityName !== '' || this.county !== '' || this.applicantName !== '' || this.applicationType !== '' || (this.consentReceivedDate !=='' && this.consentReceivedDate !== null) || this.juvenile !== '' || this.bgCheckStatus !== '') {
            getBgList({
                backgroundcheckRecord: bgCheckRecord,
                firstName: this.firstName,
                lastName: this.lastName,
                ssn: this.ssn,
                dob: (this.dob == '') ? null : this.dob,
                facilityName: this.facilityName,
                facilityNum: this.facilityNum,
                applicantName: this.applicantName,
                county: this.county,
                applicationType: this.applicationType,
                consentReceivedDate : (this.consentReceivedDate == '') ? null : this.consentReceivedDate, 
                juvenile : this.juvenile,
                bgCheckStatus : this.bgCheckStatus
                })
                .then(result => {
                    // set @track contacts variable with return contact list from server 
                    var resultData = JSON.parse(result); 
                    this.contactsFullRecords = resultData.bgFullrecords;
                    this.totalRecords = resultData.totalRecords;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                    console.log('contact record -->'+ this.contactsFullRecords[0].Name);
                    //setting display flag to true if resultant records are greater than 0
                    console.log('Total Records'+this.totalRecords)
                    if(this.totalRecords> 0){
                        this.isDisplay = true;
                        this.copyValuestoCurrentPage();
                    }
                    let tempids = [];
                    for(let i=0;i<this.totalRecords;i++){
                        tempids.push(this.contactsFullRecords[i].Id);
                    }
                    this.idsList = tempids;
                    console.log('Ids List'+this.idsList);
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.contactsRecord = null;
                });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
        
        //This flag is to reset the pagenumber when user clicks search for the second time without clearning the old filter
        console.log('AT Line 305'+this.totalRecords);
        this.isSearchclickedAlready = true;
        
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.contactsFullRecords));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.contactsFullRecords = parseData;
        this.copyValuestoCurrentPage();
    }   

    closeform(){
        this.showform = true;
    }

    handleClearKeyword(){
        //reset all values to default on clearing filter criteria
        
        this.isDisplay = false;
        this.pageNumber = 1;
        this.totalRecords = 0;
        this.totalPages = 0;
        this.isPrev = true;
        this.isNext = true;
        this.template.querySelector('lightning-input[data-id="in1"]').value = '';
        this.template.querySelector("lightning-input[data-id=in2]").value = '';
        this.template.querySelector("lightning-input[data-id=in3]").value = '';
        this.template.querySelector("lightning-input[data-id=in4]").value = '' ;
        this.template.querySelector("lightning-input[data-id=in5]").value = '' ;
        this.template.querySelector("lightning-input[data-id=in6]").value = '';
        this.template.querySelector("lightning-input[data-id=in7]").value = '';
        //this.template.querySelector("lightning-input[data-id=in9]").value = '';
        this.template.querySelector("c-custom-lookup").handleRemovePill();
        this.template.querySelector("lightning-input[data-id=in10]").value = '';
        this.applicationType = '';
        this.juvenile = '';
        this.bgCheckStatus = '';
        this.contactsRecord = [];
        
    }
}