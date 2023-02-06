import { LightningElement, track, api, wire } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
import vdss_static_resources from '@salesforce/resourceUrl/VDSSPortalStaticResources';
import saveDynamicApplicationData from '@salesforce/apex/vdssCommunityProgramsMain.saveDynamicApplicationData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateLanguage from '@salesforce/apex/vdssCommunityProgramsMain.updateLanguage';
import Fetch_lang_metadata from '@salesforce/apex/vdssCommunityProgramsMain.Fetch_lang_metadata';
import attachPDFtoApplication from '@salesforce/apex/vdssCommunityProgramsMain.attachPDFtoApplication';
// importing to get the record details based on record id
import { getRecord } from 'lightning/uiRecordApi';
// impoting USER id
import USER_ID from '@salesforce/user/Id';


export default class ProgramLicenseForm extends NavigationMixin(LightningElement) {
    //jsonData = {pagename:"page1",sections:[{name:"Program Details",subsections:[{name:"Program Address & Contact Information",class:"slds-m-top_small slds-m-right_small slds-size--1-of-4",fields:[{name:"Proposed Open Date",isText:true,type:"text",required:true,options:""},{name:"Program Name",isText:true,type:"text",required:true,options:""},{name:"State",isPicklist:true,type:"picklist",required:false,options:[{label:"State1",value:"State1"},{label:"State2",value:"State2"}]}]},{name:"Mailing Address",class:"slds-m-top_small slds-m-right_small slds-size--1-of-3",fields:[{name:"Mailing Address",type:"text",required:true,options:""},{name:"Mailing Address 2",type:"text",required:true,options:""}]}]},{name:"Ownership",subsections:[{name:"Ownership Address & Contact Information",class:"slds-m-top_small slds-m-right_small slds-size--1-of-3",fields:[{name:"Proposed Open Date",type:"text",required:true,options:""},{name:"Program Name",type:"text",required:true,options:""}]},{name:"Ownership Address",class:"slds-m-top_small slds-m-right_small slds-size--1-of-4",fields:[{name:"Mailing Address",type:"text",required:true,options:""},{name:"Mailing Address 2",type:"text",required:true,options:""}]}]}]};
    @api jsonData;
    @track langmetadata;
    @api languageselected;
    @api isdatavalid = false;
    hasRendered = true;
    canContinueToApplication = true;
    @track subSectionData = [];
    sectionId;
    isjsonLoaded = true;
    @track selecteditem;
    @track backBtnDisable = true;
    @track SubmitBtnDisable=false;
    @api programApplicationId;
    @api programId = '';
    @track isFormModified = false;
    @track queryParams;
    @track programTransactionId;
    @track fieldMap=new Map([]);
    activeSection;
    selectedSectionIndex = 0;
    applicationStatus = 'Not Submitted';
    isLoading = true;
    showSubmitterInformation = false;
    currentDateTime;
    currentUserName;
    fromContToApplBtn = ''; // NIR
    //statCompleted = false; //NIR

    backBtnLabel = 'Back';
    continueBtnLabel = 'Save & Continue';
    @track TranslatecontinueBtnLabel='Save & Continue';
    @track Submitted_Date='Submitted Date';
    @track Submitted_By='Submitted By';
    @track objUser = {};
    @track value;
    @track sectionName;
    siteURL;
    @api vfsections;
    @track showPDF=false;
    @track flagpdf=false;
    get options() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Spanish', value: 'Spanish' },
            { label: 'German', value: 'German' },
        ];
    }

    @wire(getRecord, { recordId: USER_ID, fields: ['User.FirstName', 'User.LastName', 'User.Name', 'User.Alias', 'User.IsActive'] })
    userData({ error, data }) {
        if (data) {
            window.console.log('data ====> ' + JSON.stringify(data));
            //this.isLoading=false;
            let objCurrentData = data.fields;

            this.currentUserName = objCurrentData.FirstName.value + ' ' + objCurrentData.LastName.value;

            this.objUser = {
                FirstName: objCurrentData.FirstName.value,
                LastName: objCurrentData.LastName.value,
                Name: objCurrentData.Name.value,
                Alias: objCurrentData.Alias.value,
                IsActive: objCurrentData.IsActive.value,
            }
        } else if (error) {
            window.console.log('error ====> ' + JSON.stringify(error))
        }
    }

    //jsonData;
    connectedCallback() {
        console.log('programApplicationId:',this.programApplicationId);
        this.value = this.languageselected;
        Fetch_lang_metadata({language:this.languageselected})
            .then(data=>{
                this.isLoading=false;
                console.log('Metadata data:',data);
                this.langmetadata=data;
                this.canContinueToApplication=false;
                this.setJsonData();
                
        })
       
        

        //this.currentUserName = this.objUser.FirstName+ ' '+ this.objUser.LastName;

    }

    setJsonData(){
                this.jsonData = JSON.parse(JSON.stringify(this.jsonData));
                this.jsonData.Sections.forEach(sec=>{
                    sec.SubSections.forEach(subsec=>{
                        subsec.Fields.forEach(field=>{
                            this.fieldMap.set(field.FieldApi,field.Value);
                            })
                        })
                    })
        
                    console.log('fieldmap:',this.fieldMap);
                console.log('Program License Program Id --> ' + this.programId);
                console.log("init+" + JSON.stringify(this.jsonData));
                if(this.jsonData.Instructions_to_Application!=null){
                    var InstData=this.langmetadata.find(data => data.Field_Api_Name__c ===  'Instructions_to_Application' && this.jsonData.ProgramRecordType==data.ObjectAPIName__c);
                    if(InstData!=undefined){
                        this.jsonData.Instructions_to_Application=InstData.Language_Selected__c;
                    }
                }
                var PageTitle=this.langmetadata.find(data => data.English__c ===  this.jsonData.PageTitle || data.German_Translate__c==this.jsonData.PageTitle || data.Spanish_Translate__c==this.jsonData.PageTitle);
                var continuebtn=this.langmetadata.find(data => data.English__c ===  this.continueBtnLabel);
                var backbtn=this.langmetadata.find(data => data.English__c ===  this.backBtnLabel || data.German_Translate__c==this.backBtnLabel || data.Spanish_Translate__c==this.backBtnLabel);
                var SubDate=this.langmetadata.find(data => data.English__c ===  this.Submitted_Date || data.German_Translate__c==this.Submitted_Date || data.Spanish_Translate__c==this.Submitted_Date);
                var SubBy=this.langmetadata.find(data => data.English__c ===  this.Submitted_By || data.German_Translate__c==this.Submitted_By || data.Spanish_Translate__c==this.Submitted_By);
                if(PageTitle!=undefined){
                    this.jsonData.PageTitle=PageTitle.Language_Selected__c;
                }
        
                //console.log("PageTitle+",  PageTitle.Language_Selected__c + continuebtn.Language_Selected__c + continuebtn.Language_Selected__c);
                if(continuebtn!=undefined && backbtn!=undefined && SubDate!=undefined && SubBy!=undefined){
                    this.TranslatecontinueBtnLabel=continuebtn.Language_Selected__c;
                    this.backBtnLabel=backbtn.Language_Selected__c;
                    this.Submitted_Date=SubDate.Language_Selected__c;
                    this.Submitted_By=SubBy.Language_Selected__c;
                }
              
                this.activeSection = this.jsonData.Sections[0].Id;
                
                if (this.jsonData.Sections.length > 1) {
                    //this.backBtnDisable=false;
                    //this.continueBtnLabel = ''
                } else {
                    this.continueBtnLabel='Sign & Submit';
                    this.TranslatecontinueBtnLabel = this.langmetadata.find(data => data.English__c === 'Sign & Submit').Language_Selected__c ;
                    this.backBtnDisable = true;
                }
                //get current date time
                var todayDate = new Date();
                this.currentDateTime = todayDate.getMonth() + '/' + todayDate.getDate() + '/' + todayDate.getFullYear();
    }

    @track Program_Details='Program Details';
    SectionLogic(){
        try{
        console.log("json data before: " + JSON.stringify(this.jsonData));
        var initialJsonData = JSON.parse(JSON.stringify(this.jsonData));
        var progSec = initialJsonData.Sections.find(data => data.Label === this.Program_Details);
        var progSubSec = progSec.SubSections.find(data => data.Label === 'Program Address & Contact Information');
        var secLabel=this.langmetadata.find(data => data.English__c ===   progSec.Label || data.German_Translate__c==progSec.Label || data.Spanish_Translate__c==progSec.Label);
        if(secLabel!=undefined){
            progSec.Label=secLabel.Language_Selected__c;
            this.Program_Details=secLabel.Language_Selected__c;
         }

        if(progSubSec!=undefined){
            var SubsecLabel=this.langmetadata.find(data => data.English__c === progSubSec.Label);
            console.log("SubsecLabel " + SubsecLabel.Label);        
            if(SubsecLabel!=undefined){
                progSubSec.Label=SubsecLabel.Language_Selected__c;   
            }
        }
        if(progSubSec != null && progSubSec != undefined && progSubSec.Fields != null && progSubSec.Fields != undefined && progSubSec.Fields.length > 0){
            progSubSec.Fields.forEach((elem) => {
                if (elem.FieldApi === "CLQ_Proposed_Open_Date__c") {
                    
                    var retreivedArr = elem.Value.split(" ");
                    console.log("array of date value " + retreivedArr);
                    elem.Value = retreivedArr[0];
                    console.log("date part of array of date value " + elem.Value);
                }

                this.langmetadata.forEach(lang=>{
                    if(lang.Field_Api_Name__c==elem.FieldApi && lang.ObjectAPIName__c==elem.ObjectApi){
                        elem.Label_Lang=lang.Language_Selected__c;
                    }
                });

                if(elem.PicklistValues!=null){
                    elem.PicklistValues.forEach(picklist=>{
                        //console.log('picklist',picklist);
                        this.langmetadata.forEach(lang1=>{
                            if(lang1.English__c==picklist.label){
                                picklist.label=lang1.Language_Selected__c;
                            }
                        });
                    })
                }
            });
        }
        //console.log('date here ', initialJsonData);
        this.jsonData = initialJsonData;
        console.log("json data after: " + JSON.stringify(this.jsonData));
        this.jsonData.Sections.forEach(ele=>{
            var secLabel=this.langmetadata.find(data => data.English__c ===  ele.Label || data.German_Translate__c==ele.Label || data.Spanish_Translate__c==ele.Label);
            if(secLabel!=undefined){
                ele.Label=secLabel.Language_Selected__c;
         }
        })

        //Nir Start
        // code to handle the display and highlight of Left nav section and Section data 
        if (this.fromContToApplBtn === '') { 
            var selectedSection = this.sectionName;
            console.log("result1++4",selectedSection);
            const result = this.jsonData.Sections.find(data => data.Id === selectedSection);
            
            this.subSectionData = this.TranslateSubsection(result);
            //this.subSectionData=result;
            //this.sectionId = selectedSection;
            this.activeSection = result.Id;
            this.selectedSectionIndex = this.updatedIndex(result);
            this.handleButtons(result);
        } else if (this.fromContToApplBtn === 'continuebtn-prescreen') {
            var fullSecnData = this.jsonData.Sections;
            var draftSecns = [];
            fullSecnData.forEach((element) => {
                if (element.Status === 'Draft') {
                    draftSecns.push(element);
                }
            });
            if(draftSecns.length ==0){
                draftSecns.push(fullSecnData[fullSecnData.length-1]);
            }
           
            if (draftSecns.length === fullSecnData.length) {
                var selectedSection = this.sectionName;
                const result = this.jsonData.Sections.find(data => data.Id === selectedSection);
                console.log("result1++5"+JSON.stringify(result));
                this.subSectionData = this.TranslateSubsection(result);
                //this.subSectionData=result;
                //this.sectionId = selectedSection;
                this.activeSection = result.Id;
                this.selectedSectionIndex = this.updatedIndex(result);
                this.handleButtons(result);
            } else if (draftSecns.length < fullSecnData.length) {
                draftSecns.sort((a, b) => {
                    //if(a.OrderNumber < b.OrderNumber) { return -1; }
                    //if(a.OrderNumber > b.OrderNumber) { return 1; }
                    //return 0;
                    return a.OrderNumber - b.OrderNumber;
                })
                this.subSectionData = draftSecns[0];
                this.activeSection = draftSecns[0].Id;
                this.selectedSectionIndex = this.updatedIndex(draftSecns[0]);
                this.handleButtons(draftSecns[0]);
            }
            this.fromContToApplBtn = '';
        }
        //Nir End 
        /*var selectedSection = event.detail.name;
        const result = this.jsonData.Sections.find(data => data.Id === selectedSection);
        this.subSectionData = result;
        //this.sectionId = selectedSection;*/
    } catch(e) {
        console.log(e.stack);
    }
    }
  
 
   
    handleSection(event) {
            console.log('sectionName:', this.sectionName);
            this.sectionName=event.detail.name;
            if(this.langmetadata!=undefined){
            this.SectionLogic();
            }
            //AAkriti
            // Code to append only date to the input field from date-time value retreived from backend
           
    }

    TranslateSubsection(result){
        console.log('this.result in translate:',result);
        result.SubSections.forEach(res=>{
            console.log('res:',res);
            if(res.TextBlockBody!=null){
                console.log('res label:',res.Label);
                var resTxtBlock=this.langmetadata.find(data => data.Label === res.Label);
                console.log('resTxtBlock:',resTxtBlock);
                if(resTxtBlock!=undefined){
                    res.TextBlockBody=resTxtBlock.Language_Selected__c;
                }
           }
                var resLabel=this.langmetadata.find(data => data.English__c === res.Label || data.German_Translate__c===res.Label || data.Spanish_Translate__c===res.Label);
                if(resLabel!=undefined){
                    res.Label=resLabel.Language_Selected__c;
                }
                if(res.FormComponents!=null){
                    res.FormComponents.forEach(form=>{
                        this.langmetadata.forEach(lang2=>{
                            if((form.Label==lang2.English__c || lang2.German_Translate__c==form.Label || lang2.Spanish_Translate__c==form.Label)  && form.FieldName==lang2.Field_Api_Name__c){
                                form.Label=lang2.Language_Selected__c;
                            }
                        })
                    })
                }

            if(res.TableInfo!=null){
                res.TableInfo.forEach(form=>{
                    this.langmetadata.forEach(lang2=>{
                        if((form.Label==lang2.English__c || lang2.German_Translate__c==form.Label || lang2.Spanish_Translate__c==form.Label) && form.FieldName==lang2.Field_Api_Name__c){
                            form.Label=lang2.Language_Selected__c;
                        }
                    })
                })
            }

           
           res.Fields.forEach(field=>{
                this.langmetadata.forEach(lang=>{
                    if(lang.Field_Api_Name__c==field.FieldApi && lang.ObjectAPIName__c==field.ObjectApi){
                        field.Label_Lang=lang.Language_Selected__c;
                    }
                })
                if(field.PicklistValues!=null){
                    field.PicklistValues.forEach(picklist=>{
                        this.langmetadata.forEach(lang1=>{
                            if(lang1.English__c==picklist.label || lang1.German_Translate__c==picklist.label || lang1.Spanish_Translate__c==picklist.label){
                                picklist.label=lang1.Language_Selected__c;
                            }
                        });
                    })
                   
                }
            })  
        })
        return result;
    }

    updatedIndex = (receiveResult) => {
        try{
            var updatedIndex = this.jsonData.Sections.findIndex(elem => elem.Id === receiveResult.Id);
            return updatedIndex;
        } catch(e) {
            console.log(e.stack);
        }
    }

    handleitem(event) {
        console.log("event.currentTarget.dataset.id+" + event.currentTarget.dataset.id);
        this.selecteditem = event.currentTarget.dataset.id;
        console.log("+++=");
        console.log("event.currentTarget.dataset.name+" + event.currentTarget.dataset.name);
        this.selectedSectionIndex = event.currentTarget.dataset.name;
        console.log("selectedSectionIndex++" + this.selectedSectionIndex + 1);
        console.log("length++" + this.jsonData.Sections.length);
        this.backBtnDisable = false;
        /*if(+this.selectedSectionIndex + +1 === this.jsonData.PGFSection__c.length){
            this.continueBtnLabel = 'Submit';
        }
        if(this.selectedSectionIndex == 0){
            this.backBtnDisable=true;
        }
        if(+this.selectedSectionIndex + +1 !== this.jsonData.PGFSection__c.length){
            this.continueBtnLabel = 'Continue';
        }*/
        console.log("check1");
        const result = this.jsonData.Sections[this.selectedSectionIndex];
        this.handleButtons(result);
        console.log("check2");
    }

    handleSaveDraft(event) {

        var isdatavalid = this.checkValidityOfData();
        if (isdatavalid) {
            this.isLoading = true;
            saveDynamicApplicationData({
                jsonData: JSON.stringify(this.jsonData),
                programApplicationId: this.programApplicationId,
                applicationStatus: this.applicationStatus
            })
                .then(data => {

                    this.programApplicationId = data[0];
                    this.programId = data[1];
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Application have been successfully saved.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;


                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            pageName: 'home-landing-page'
                        }
                    });

                })
                .catch(error => {
                    console.log(" ==== connectedCallback ERROR in retrieving DATA =====", error);
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: error.body.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;
                });
        }
    }

    checkValidityOfData(event) {

        //Check for section validations on Continue button click
        this.isdatavalid = [...this.template.querySelectorAll('c-vdss_dynamicframeworkcmplwc_subsections')]
            .reduce((allValid, childCmp) => {
                if (childCmp.validateInputs()) {
                    return allValid;
                }
                return false;
            }, true);

        //If sections have issue.
        if (!(this.isdatavalid)) {
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'There are errors in this page. Please fix the errors before navigating further.',
                variant: 'error'
            });
            this.dispatchEvent(event);
        }

        return this.isdatavalid;
    }

  
    handlepdfmodalevent(event){
        if(event.detail=='ok'){
            this.flagpdf=false;
            this.applicationStatus='Submitted';
            this.handleContinueLogic('Sign & Submit');
        }
    }

    handleContinue(event){
        var btnId = event.target.dataset.id;
        console.log('btnId...'+btnId);
        this.flagpdf=true;
        this.handleContinueLogic(btnId);
    }
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    @track urlWithParameters;
    handleContinueLogic(btnId) {
        try{
            //Check for field validations on Continue button click
            
            var isdatavalid = this.checkValidityOfData();
            //var isApplicationSaved=false;
            this.isLoading = true;

            //if all validation are a success
            if (isdatavalid) {

                console.log("==== Validation success ======");

                var SectionData = this.jsonData.Sections[this.selectedSectionIndex];
                console.log('sectiondata:',SectionData);
                if(SectionData.Label=='Administrator'){
                    SectionData.Status = 'Completed';
                    SectionData.isCompleted = true;
                    this.isFormModified=true;
                }

                //Receive updated json from subsections
                //this.template.querySelectorAll("c-vdss_dynamicframeworkcmplwc_subsections")
                /*this.template.querySelectorAll("c-vdss_dynamicframeworkcmplwc_subsections")
                    .forEach(element => {
                        var arraydata = element.getUpdatedSubSectionJson();
                    });*/

                console.log('--- JSON updated ---> ' + JSON.stringify(this.jsonData));

                console.log('Form Modifeid in Continue --> ' + this.isFormModified);

                //If something is modified in the form, save the data and continue
                if (this.isFormModified || btnId == 'Sign & Submit') {
                    //save data into backend

                    if (btnId == 'Submit') {
                        //this.applicationStatus = 'Submitted';
                        //alert(this.applicationStatus);
                    } else if (btnId == 'Sign & Submit') {
                        //this.applicationStatus = 'Submitted';
                    }

                    console.log(this.activeSection);
                    /*this.jsonData.Sections.forEach((section) => {
                        console.log(section);
                        if (section.Id === this.activeSection) {
                            section.Status = 'Completed';
                            section.isCompleted = true;
                        }
                    });*/
                    //Nir Start 
                    var getCompleted = this.jsonData.Sections[this.selectedSectionIndex];
                    getCompleted.Status = 'Completed';
                    getCompleted.isCompleted = true;
                    //Nir End
                    console.log('programApplicationId:',this.programApplicationId);
                    //Changes By Ankush
                    if(this.programApplicationId=='' ||  this.programApplicationId==null){
                    this.queryParams = this.getQueryParameters();
                    this.programApplicationId=this.queryParams.programTransactionId != null && this.queryParams.programTransactionId != undefined ? this.queryParams.programTransactionId : '';
                    console.log('programApplicationId:',this.programApplicationId);
                }
                    console.log('applicationStatus:',this.applicationStatus);
                    saveDynamicApplicationData({
                        jsonData: JSON.stringify(this.jsonData),
                        programApplicationId: this.programApplicationId,
                        applicationStatus: this.applicationStatus
                    })
                        .then(data => {

                            this.programApplicationId = data[0];
                            this.programId = data[1];
                            this.isFormModified = false;
                            
                            //Navigate based on button click - Continue / Submit
                            if (btnId == 'Sign & Submit') {
                                this.isLoading = false;
                                const result = this.jsonData.Sections[this.selectedSectionIndex];
                                console.log("result1++6"+JSON.stringify(result));
                                this.subSectionData = this.TranslateSubsection(result);
                                //this.subSectionData=result;
                                this.handleButtons(result);
                                if(this.flagpdf==true){
                               
                                this.urlWithParameters = window.location.href.replace("/s/program-license?", "/ReviewPdfPage?");
                                let Programid = this.getUrlParamValue(this.urlWithParameters, 'selectedProgramId');
                                console.log('programId in url=>'+Programid);
                                console.log('programId=>'+this.programId);
                                console.log('programApplicationId=>'+this.programApplicationId);
                                if(Programid=='' && (this.programId!='' || this.programId!=undefined) && (this.programApplicationId!='' ||this.programApplicationId!=undefined)){
                                    this.urlWithParameters = window.location.href.replace("/s/program-license?selectedProgramId", "/ReviewPdfPage?");
                                    this.urlWithParameters=this.urlWithParameters+'&selectedProgramId='+this.programId+'&programTransactionId='+this.programApplicationId;
                                }
                                 
                                console.log('urlWithParameters...'+this.urlWithParameters);
                                const Pfdmodal=this.template.querySelector('c-pdf-pop-up');
                                Pfdmodal.isModalOpen=true;
                                Pfdmodal.vfpageurl=this.urlWithParameters;
                                }
                                
                            if(this.applicationStatus=='Submitted'){

                                attachPDFtoApplication({recordId:this.programApplicationId,pdfUrl:this.urlWithParameters})
                                .then(data=>{
                                    console.log('pdf attached');
                                })
                                .catch(error=>{
                                    console.log('error from pdf attachement:',error);
                                })
                                //update the status of the pragram application
                                const event = new ShowToastEvent({
                                    title: 'Success!',
                                    message: 'Application have been submitted successfully.',
                                    variant: 'success'
                                });
                                this.dispatchEvent(event);

                                this[NavigationMixin.Navigate]({
                                    type: 'comm__namedPage',
                                    attributes: {
                                        //pageName: 'esignature'
                                        pageName: 'home-landing-page'
                                    },
                                    state: {
                                        recordid: this.programApplicationId
                                    }
                                });
                            }

                            } else {
                                this.selectedSectionIndex = +this.selectedSectionIndex + +1;
                                const result = this.jsonData.Sections[this.selectedSectionIndex];
                                console.log("result1++6"+JSON.stringify(result));
                                this.subSectionData = this.TranslateSubsection(result);
                                //this.subSectionData=result;
                                this.handleButtons(result);

                                //isApplicationSaved=false;
                                this.isLoading = false;
                            }
                        })
                        .catch(error => {
                            console.error('error=>',error);
                            const event = new ShowToastEvent({
                                title: 'Error!',
                                message: error.body.message,
                                variant: 'error'
                            });
                            this.dispatchEvent(event);
                            this.isLoading = false;
                        });
                } else {
                    
                    this.selectedSectionIndex = +this.selectedSectionIndex + +1;
                    const result = this.jsonData.Sections[this.selectedSectionIndex];
                    console.log("result++2"+JSON.stringify(result));
                    this.subSectionData = this.TranslateSubsection(result);
                    //this.subSectionData=result;
                    this.handleButtons(result);

                    //isApplicationSaved=false;
                    this.isLoading = false;
                }

            } else {
                this.isLoading = false;
            }
        } catch(e) {
            console.log(e.stack);
        }
    }

    handleBack(event) {
        this.selectedSectionIndex = parseInt(this.selectedSectionIndex) - parseInt(1);
        const result = this.jsonData.Sections[this.selectedSectionIndex];
        console.log("result++3"+JSON.stringify(result));
        this.subSectionData = this.TranslateSubsection(result);
        //this.subSectionData=result;
        this.handleButtons(result);
    }

    handleButtons(selectedSection) {

        console.log("--- Upcoming Section Id ---> " + selectedSection.Id + " " + selectedSection.Label);
        this.activeSection = selectedSection.Id; //Side Panel navigation
        if(this.programId=='' && selectedSection.OrderNumber!='1'){
            this.SubmitBtnDisable=true;
            }
            else{
                this.SubmitBtnDisable=false;
            }
        if (+this.selectedSectionIndex + +1 === this.jsonData.Sections.length) {
            for(let i=0;i<5;i++){
                console.log('sections in json==>',this.jsonData.Sections[i].isCompleted);
                if(this.jsonData.Sections[i].isCompleted==false){
                    this.SubmitBtnDisable=true;
                }
            }
            this.continueBtnLabel='Sign & Submit';
            this.TranslatecontinueBtnLabel =this.langmetadata.find(data => data.English__c === 'Sign & Submit').Language_Selected__c ;
            this.backBtnDisable = false;
            this.showSubmitterInformation = true;

            var todayDate = new Date();
            var dd = String(todayDate.getDate()).padStart(2, '0');
            var mm = String(todayDate.getMonth() + 1).padStart(2, '0');
            var yyyy = todayDate.getFullYear();
            this.currentDateTime = mm + '/' + dd + '/' + yyyy;
        } else {
            this.showSubmitterInformation = false;
        }

        if (+this.selectedSectionIndex + +1 !== this.jsonData.Sections.length) {
            this.continueBtnLabel='Save & Continue';
            var continuebtn=this.langmetadata.find(data => data.English__c ===  'Save & Continue');
            if(continuebtn!=undefined){
            this.TranslatecontinueBtnLabel = continuebtn.Language_Selected__c;
            }
            this.backBtnDisable = false;
        }
        if (this.selectedSectionIndex == 0) {
            this.backBtnDisable = true;
        }
    }

    handleContinueToApplication(event) {
        this.fromContToApplBtn = event.detail; //Nir
        this.canContinueToApplication = true;
        
        //this.isLoading = true;
        event.preventDefault();
        event.stopPropagation();
    }

    //on load
    renderedCallback() {
        Promise.all([
            loadStyle(this, vdss_static_resources + '/VDSS_StaticResources/css/styles_vdss.css') //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
            //console.log("renderedCallback ---> "+this.jsonBody);
            //initializeComp();

        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });

        //this.activeSection = this.jsonData.Sections[0].Id;
    }

    handleValueChange(event) {
        try {
            /*console.log('Value Changed --> ' + JSON.stringify(event.detail));
            var section = this.jsonData.Sections.find(data => data.Id === this.activeSection);
            console.log('Entire Json --> ' + JSON.stringify(this.jsonData));
            var subsectiondata = section.SubSections.find(data => data.Id === event.detail.subsectionid);
            console.log('Just Breaking --> ' + JSON.stringify(subsectiondata));
            var subsectionfield = subsectiondata.Fields.find(data => data.Label === event.detail.fieldname);
            console.log('SubSectionField Value --> ' + JSON.stringify(subsectionfield));
            subsectionfield.Value = event.detail.value;
            this.isFormModified = true;
            console.log('Form Modified? --> ' + this.isFormModified);*/
            var deepCopy = JSON.parse(JSON.stringify(this.jsonData));
            console.log("deepcopy is ", deepCopy);
            //var section = deepCopy.Sections.find(data => data.Id === this.activeSection);
            var section = deepCopy.Sections.find(data => data.Id === deepCopy.Sections[this.selectedSectionIndex].Id)
            console.log('section ', section);
            var subsectiondata = section.SubSections.find(data => data.Id === event.detail.subsectionid);
            console.log('subsectiondata ', subsectiondata);
            console.log('event.detail.fieldname  ', event.detail.fieldname );
            var subsectionfield = subsectiondata.Fields.find(data => data.Label === event.detail.fieldname);

            if(subsectionfield!=undefined && subsectionfield.copy_options!=undefined){
                subsectionfield.Value=event.detail.checked;
                this.fieldMap.set(subsectionfield.FieldApi,subsectionfield.Value);
                let options = JSON.parse(subsectionfield.copy_options);
                deepCopy= this.copy_data(deepCopy,options,event.detail.checked);
            }

            //Added by Ankush
            if(subsectionfield==undefined && (subsectiondata.ComponentType=='FileUpload'||subsectiondata.ComponentType=='Signature')){
                //subsectiondata.Fields.push({'Label':event.detail.fieldname,'Value':''});
                //subsectionfield=subsectiondata.Fields.find(data => data.Label ===event.detail.fieldname);
                var getCompleted = deepCopy.Sections[this.selectedSectionIndex];
                console.log("result of doc section:"+JSON.stringify(getCompleted));
                getCompleted.Status = 'Completed';
                getCompleted.isCompleted = true;
                this.isFormModified = true;
                this.jsonData = deepCopy;
                return;
            }


            console.log('subsectionfield ', subsectionfield);
            if(subsectionfield.Type!='Checkbox'){
                subsectionfield.Value = event.detail.value;
                this.fieldMap.set(subsectionfield.FieldApi, subsectionfield.Value);
            }
            console.log('subsectiondata after update ', subsectiondata);
            this.jsonData = deepCopy;
            console.log('jsonData copied is ', this.jsonData);
            this.isFormModified = true;
            console.log('Form Modified? --> ' + this.isFormModified);

        } catch(e) {
            console.log(e.stack);
        }

    }

    copy_data(deepCopy,options,copy){
        if(copy){
        deepCopy.Sections.forEach(sec=>{
            sec.SubSections.forEach(subsec=>{
                subsec.Fields.forEach(field=>{
                    options.operations.forEach(op=>{
                        if(op.type=='SOURCE_TO_TARGET'){
                            if(field.FieldApi==op.target){
                                field.Value=this.fieldMap.get(op.source);
                                this.fieldMap.set(field.FieldApi, field.Value);
                            }
                        }
                    })
                    })
                })
            })
        }
        else{
            deepCopy.Sections.forEach(sec=>{
                sec.SubSections.forEach(subsec=>{
                    subsec.Fields.forEach(field=>{
                        options.operations.forEach(op=>{
                            if(op.type=='SOURCE_TO_TARGET'){
                                if(field.FieldApi==op.target){
                                    field.Value='';
                                    this.fieldMap.set(field.FieldApi, field.Value);
                                }
                            }
                        })
                        })
                    })
                })
        }
            this.subSectionData=deepCopy.Sections.find(data => data.Id === deepCopy.Sections[this.selectedSectionIndex].Id)
            return deepCopy;

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

    handleLanguageChange(event){
        console.log('lang selected:', event.target.value);
        var language=event.target.value;
        this.languageselected=language;
        updateLanguage({language:language})
        .then(data=>{
            console.log('updated successfully');
        })
        .catch(error=>{
            console.log('error->',error);
        });
        var languagedata=JSON.parse(JSON.stringify(this.langmetadata));
        languagedata.forEach(lang=>{
            if(language=='Spanish'){
                lang.Language_Selected__c=lang.Spanish_Translate__c;
            }
            else if(language=='German'){
                lang.Language_Selected__c=lang.German_Translate__c;
            }
            else{
                lang.Language_Selected__c=lang.English__c;
            }
        });
        this.langmetadata=languagedata;
        this.setJsonData();
        console.log('language data:',this.langmetadata);
        if(this.canContinueToApplication==true){
            this.SectionLogic();
        }
        else{
            const InstructionModal=this.template.querySelector('c-vdss_dynamic-qn-framework_-instruction-page');
            InstructionModal.languagedata=languagedata;
            InstructionModal.setButtonLabels();
            
        }
        

    }

    openPdf(){
        var urlWithParameters;
        
        urlWithParameters = window.location.href.replace("/s/program-license?", "/ReviewPdfPage?");
        console.log('programId=>'+this.programId);
        console.log('programApplicationId=>'+this.programApplicationId);
        if((this.programId!='' || this.programId!=undefined) && (this.programApplicationId!='' ||this.programApplicationId!=undefined)){
            urlWithParameters=urlWithParameters+'selectedProgramId='+this.programId+'&programTransactionId='+this.programApplicationId;
        }
        console.log('urlWithParameters...'+urlWithParameters);
        const Pfdmodal=this.template.querySelector('c-pdf-pop-up');
        Pfdmodal.isModalOpen=true;
        Pfdmodal.vfpageurl=urlWithParameters;

    }


}