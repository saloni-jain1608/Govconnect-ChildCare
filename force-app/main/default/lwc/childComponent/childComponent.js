import { api, LightningElement, track } from 'lwc';
import First_Name from '@salesforce/schema/Background_Check__c.First_Name__c';
import Last_Name from '@salesforce/schema/Background_Check__c.Last_Name__c';
import SSN from '@salesforce/schema/Background_Check__c.SSN__c';
import Phone_Number from '@salesforce/schema/Background_Check__c.Phone_Number__c';
import Email_Address from '@salesforce/schema/Background_Check__c.Email_Address__c';
import DOB from '@salesforce/schema/Background_Check__c.Date_of_Birth__c';
import Role from '@salesforce/schema/Background_Check__c.Role__c';
import Consent_Received_Date from '@salesforce/schema/Background_Check__c.Consent_Received_Date__c';
import Application_Type from '@salesforce/schema/Background_Check__c.Application_Type__c';
import Status from '@salesforce/schema/Background_Check__c.Background_Check_Status__c';
import Race from '@salesforce/schema/Background_Check__c.Race__c';
import Gender from '@salesforce/schema/Background_Check__c.Gender__c';
import Juvenile from '@salesforce/schema/Background_Check__c.Juvenile__c';
import Consent_Due_Date from '@salesforce/schema/Background_Check__c.Consent_Due_Date__c';
import { NavigationMixin } from 'lightning/navigation';
import CH_Record_Found from '@salesforce/schema/Background_Check__c.CH_Record_Found__c';
import CH_Check_Date from '@salesforce/schema/Background_Check__c.CH_Check_Date__c';
import CH_Initials from '@salesforce/schema/Background_Check__c.CH_Initials__c';
import FingerPrint_Record_Found from '@salesforce/schema/Background_Check__c.Fingerprint_Record_Found_New__c';
import FingerPrint_Notice_Reason from '@salesforce/schema/Background_Check__c.FingerPrint_Notice_Reason__c';
import Fingerprint_Check_Date from '@salesforce/schema/Background_Check__c.Fingerprint_Check_Date__c';
import Fingerprint_Initials from '@salesforce/schema/Background_Check__c.Fingerprint_Initials__c';
import CPI_Record_Found from '@salesforce/schema/Background_Check__c.CPI_Record_Found__c';
import CPI_Check_Date from '@salesforce/schema/Background_Check__c.CPI_Check_Date__c';
import CPI_Initials from '@salesforce/schema/Background_Check__c.CPI_Initials__c';
import SOR_Record_Found from '@salesforce/schema/Background_Check__c.SOR_Record_Found__c';
import SOR_Check_Date from '@salesforce/schema/Background_Check__c.SOR_Check_Date__c';
import SOR_Initials from '@salesforce/schema/Background_Check__c.CH_Initials__c';

export default class ChildComponent extends NavigationMixin(LightningElement) {

    // Expose a field to make it available in the template
    bodyFields = [First_Name,Last_Name,Gender,Race,SSN,DOB,Phone_Number, Email_Address,Role, Consent_Received_Date,
    Application_Type,Status,Juvenile, Consent_Due_Date];
    fingerPrintFields = [FingerPrint_Record_Found,FingerPrint_Notice_Reason, Fingerprint_Check_Date, Fingerprint_Initials];
    cpiFields = [CPI_Record_Found,CPI_Check_Date,CPI_Initials];
    chFields = [CH_Record_Found, CH_Check_Date, CH_Initials];
    sorFields = [SOR_Record_Found, SOR_Check_Date, SOR_Initials];
    
    // Flexipage provides recordId and objectApiName
    @api currentChildId;
    @api objectApiName;
    @api currentIndex;
    @api recordList = [];
    @track isNextChild = false;
    @track isPreviousChild = false
    @api recordId;
    @track openFingerPrintPopup = false;
    @track openCPIPopup = false;
    @track openCriminalHistoryPopup = false;
    @track openSORPopup = false;
    @track isModalOpen = false;
    //@track isOpenChildProtective = false;
    @track isOpenCriminalHistory = true;
    @track isOpenSexOffender = true;

    connectedCallback(){
        console.log(this.recordList);
        if((this.currentIndex+1) >= this.recordList.length){
            this.isNextChild = true;
        }
        if((this.currentIndex) <= 0){
            this.isPreviousChild = true;
        }        
    }
   

    handleNext()
    {
       
        this.currentIndex+=1;
        console.log('recordList -- >'+ this.recordList);
        this.currentChildId = this.recordList[this.currentIndex];
        if((this.currentIndex+1) >= this.recordList.length){
            this.isNextChild = true;
        }
        console.log(this.recordList);
        this.isPreviousChild = false; 
   }

   handlePrevious(){
    this.currentIndex-=1;
        console.log('recordList -- >'+ this.recordList);
    

    this.currentChildId = this.recordList[this.currentIndex];
    if((this.currentIndex) <= 0){
        this.isPreviousChild = true;
        
    }
    this.isNextChild = false;
   }

    openFingerPrint(){
        this.isModalOpen = true;
        this.openFingerPrintPopup  = true;
    }

    openChildProtective(){
        this.isModalOpen = true;
        this.openCPIPopup  = true;
    }

    openCriminalHistory(){
        this.isModalOpen = true;
        this.openCriminalHistoryPopup  = true;
    }

    openSexOffender(){
        this.isModalOpen = true;
        this.openSORPopup  = true;
    }



closeModal() {
    // to close modal set isModalOpen tarck value as false
    console.log("Close Modal");
    this.isModalOpen = false;
    this.openFingerPrintPopup = false;
    this.openCPIPopup = false;
    this.openCriminalHistoryPopup = false;
    this.openSORPopup = false;
    
}

}