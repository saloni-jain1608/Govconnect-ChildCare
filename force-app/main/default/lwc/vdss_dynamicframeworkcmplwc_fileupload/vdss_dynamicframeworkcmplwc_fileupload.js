import { LightningElement,api,track } from 'lwc';
import createTransactionDocumentRecord from '@salesforce/apex/vdssCommunityProgramsMain.createTransactionDocumentRecord';
import fetchuploadedtransdocs from '@salesforce/apex/vdssCommunityProgramsMain.fetchuploadedtransdocs';
import Fetch_lang_metadata from '@salesforce/apex/vdssCommunityProgramsMain.Fetch_lang_metadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Vdss_dynamicframeworkcmplwc_fileupload extends LightningElement {

    queryParams;
    @api recordId='';
    isLoading=false;
    isModalOpen;fileUploadedSuccessfully;
    @api programTransactionId;
    @api currdocumentName;
    @api languageselected;
    @track languagedata;
    isDoc1Uploaded;
    isDoc2Uploaded;
    isDoc3Uploaded;
    @track UploadedDocumentId;
    @track documentId;
    @track Plan_of_operation='Plan of operation';
    @track Budget_details='Budget details';
    @track Building_approval='Building approval';
    @track File_uploaded_successfully='File uploaded successfully.';
    @track upload_documents_each_type ='Please upload documents of each type.'
    


    get acceptedFormats() {
        return ['.pdf'];
    }

    connectedCallback(){
        Fetch_lang_metadata({language:this.languageselected})
        .then(data=>{
            //console.log('Metadata data:',data);
            this.languagedata=data;
            this.Plan_of_operation=this.languagedata.find(data => data.English__c === 'Plan of operation').Language_Selected__c; 
            this.Budget_details=this.languagedata.find(data => data.English__c === 'Budget details').Language_Selected__c; 
            this.Building_approval=this.languagedata.find(data => data.English__c === 'Building approval').Language_Selected__c; 
            this.File_uploaded_successfully=this.languagedata.find(data => data.English__c === 'File uploaded successfully.').Language_Selected__c; 
            this.upload_documents_each_type=this.languagedata.find(data => data.English__c === 'Please upload documents of each type.').Language_Selected__c; 
         })

        
        
        if(this.programTransactionId=='' ||  this.programTransactionId==null){
        this.queryParams = this.getQueryParameters();
        this.programTransactionId=this.queryParams.programTransactionId != null && this.queryParams.programTransactionId != undefined ? this.queryParams.programTransactionId : '';
        }
        console.log('programTransactionId:', this.programTransactionId );
        if(this.programTransactionId !=''||this.programTransactionId !=null){
        fetchuploadedtransdocs({TransDocId:this.programTransactionId})
        .then(data=>{
            console.log("data from uploaded Trans Docs:", data);
            data.forEach(ele=>{
                if(ele.Name=='Plan of operation'){
                    this.isDoc1Uploaded = true;
                }
                if(ele.Name=='Budget details'){
                    this.isDoc2Uploaded = true;
                }
                if(ele.Name=='Building approval'){
                    this.isDoc3Uploaded = true;
                }
            })
        })
        .catch(error => {
            console.log('error on file data:',error);
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please Complete Program Details section first',
                variant: 'error'
            });
            this.dispatchEvent(event);
            //alert("error");
        });
       
    }
    }

    handleInitiateFileUpload(event){
      
        this.currdocumentName = event.currentTarget.dataset.documentname; 
       
        //this.isLoading=false;

        //alert("trabsaction data sending--> "+this.programTransactionId+' --- '+documentName);
        console.log('curr document name:', this.currdocumentName );
        console.log('programTransactionId:', this.programTransactionId );
        if(this.programTransactionId=='' ||  this.programTransactionId==null){
            
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please Complete Program Details section first',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }
        else{
            this.isModalOpen=true;
        }
       
        
        //create transaction document record
       
    }
    closeModal(event){
        this.isModalOpen=false;
    }

    handleUploadFinished(event){
        this.isLoading=true;
        this.fileUploadedSuccessfully=true;
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles:', uploadedFiles );
        this.UploadedDocumentId= uploadedFiles[0].documentId;
        var DocName=uploadedFiles[0].name;
    
        

        if(this.currdocumentName == 'Plan of operation'){
            this.createTransactionDocRec(this.UploadedDocumentId);
            this.isDoc1Uploaded = true;
            
            const selectedEvent = new CustomEvent("valuechange", {
                detail: { value: DocName, fieldname:  'Plan of operation' }
              });
              
              // Dispatches the event.
              this.dispatchEvent(selectedEvent);
        }
        else if(this.currdocumentName == 'Budget details'){
            this.createTransactionDocRec(this.UploadedDocumentId);
            this.isDoc2Uploaded = true;
            const selectedEvent = new CustomEvent("valuechange", {
                detail: { value: DocName, fieldname: 'Budget details' }
              });
          
              // Dispatches the event.
              this.dispatchEvent(selectedEvent);
        }
        else if(this.currdocumentName == 'Building approval'){
            this.createTransactionDocRec(this.UploadedDocumentId);
            this.isDoc3Uploaded = true;
            const selectedEvent = new CustomEvent("valuechange", {
                detail: { value: DocName, fieldname: 'Building approval' }
              });
          
              // Dispatches the event.
              this.dispatchEvent(selectedEvent);
        }
        

        console.log('UploadedDocumentId:', this.UploadedDocumentId );
        console.log('curr document name:', this.currdocumentName );
       
       /*this.queryParams = this.getQueryParameters();
        this.programTransactionId=this.queryParams.programTransactionId != null && this.queryParams.programTransactionId != undefined ? this.queryParams.programTransactionId : '';
        console.log('programTransactionId:', this.programTransactionId );
        //create transaction document record
        createTransactionDocumentRecord( { programTransactionId: this.programTransactionId, documentName:  this.currdocumentName, documentId:this.UploadedDocumentId, FileName:DocName} )
            .then(data => {

                //alert("trabsaction doc Id--> "+data);
                this.documentId = data;

                //this.isModalOpen=true;
                //this.isLoading=false;
            })
            .catch(error => {
                console.log('error:',error);
                alert("error");
                //this.isLoading=false;
            });*/

            this.currdocumentName='';
            this.documentId='';
    }

    createTransactionDocRec(fileid){
        console.log('fileid:', fileid);
        createTransactionDocumentRecord( { programTransactionId: this.programTransactionId, documentName:  this.currdocumentName, documentId:fileid} )
        .then(data => {

            console.log("trabsaction doc Id--> ",data);
            this.documentId = data;
            this.isLoading=false;
           // this.isModalOpen=true;
            
        })
        .catch(error => {
            
            //this.isModalOpen=false;
            console.log('error:',error);
            alert("error");
            this.isLoading=false;
        });
    }

   

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);
        console.log('search:', search );

        if (search.indexOf('programTransactionId')>-1) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
            console.log('params:', params );
        }

        return params;
    }

    
}