import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
//import styles from '@salesforce/resourceUrl/styles_vdss';
import vdss_static_resources from '@salesforce/resourceUrl/VDSSPortalStaticResources';
import loginUserId from '@salesforce/user/Id';
import getUserPrograms from '@salesforce/apex/vdssCommunityProgramsMain.getUserPrograms';
import getDynamicApplicationMetadata from '@salesforce/apex/vdssCommunityProgramsMain.getDynamicApplicationMetadata';
import withdrawProgram from '@salesforce/apex/vdssCommunityProgramsMain.withdrawProgram';
import Fetch_lang_metadata from '@salesforce/apex/vdssCommunityProgramsMain.Fetch_lang_metadata';
import getSelectedLanguage from '@salesforce/apex/vdssCommunityProgramsMain.getSelectedLanguage';
import updateLanguage from '@salesforce/apex/vdssCommunityProgramsMain.updateLanguage';

export default class Vdss_allprogramslwccmp extends NavigationMixin(LightningElement) {

    image_CardBg = vdss_static_resources + '/VDSS_StaticResources/images/CardBackground.png';
    @track all_programs;
    @track LanguageData;
    @track LangSelected;
    @track Programs='Programs';
    @track Program_Status='Program Status';
    @track License_Status='License Status';
    @track License_Type='License Type';
    @track License_Begin_Date='License Begin Date';
    @track License_End_Date='License End Date';
    @track Action_Required='Action Required';
    @track Click_here='Click here';
    @track Create_an_Application='Create an Application'
    applicationPageId;
    actionRequired;
    isProgramLicensed = false;
    showWithdrawPopup = false;
    withdrawCardDetails = {};
    //withdrawStatus = false;
    textBoxValue = "";
    //Labels start
    withdrawPopupHeader = "Withdraw Application";
    popupQuesLabel= "Do you really want to withdraw this application?";
    popupComments = "Please Enter Comments:";
    popupCommentsPlaceholder = "Type here...";
    noBtnLabel = "No";
    yesBtnLabel = "Yes";
    //Labels End
    value = this.LangSelected;
    
    get options() {
        return [
            { label: 'English', value: 'English' },
            { label: 'Spanish', value: 'Spanish' },
            { label: 'German', value: 'German' },
        ];
    }


    // Create new application flow
    handle_CreateNewApplication(event) {
        //applicationPageId = '';

        console.log("--- Navigating to application program page -->");
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            //type: 'standard__namedPage',
            attributes: {
                pageName: 'program-license',
               
            },
            state: {
                selectedProgramId: '',
                languageselected: this.LangSelected
            }
        });
        console.log("<--- Navigating successful -->");
    }

    //Edit an existing application
    handle_EditApplication(event) {
        //event.preventDefault();
        //event.stopPropagation();

        var selectedProgramId = event.currentTarget.dataset.id;
        console.log('selectedProgramId ==> ' + selectedProgramId);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'program-license'
            },
            state: {
                selectedProgramId: selectedProgramId
            }
        });

        console.log('Navigation Successful');
    }

    // initialize component
    connectedCallback() {

        //registerListener("changedLanguage",this.handleChangedLanguage,this);
        getSelectedLanguage()
        .then(lang=>{
            console.log('language selected=>',lang);
            this.LangSelected=lang;
            this.value=lang;
            this. FetchTranslatedMetadata();
        })
        

        console.log('--- Logged In User Id connectedcallback ---> ' + loginUserId);
        // Get all programs associated with the logged in user
        getUserPrograms({ userId: loginUserId })
            .then(data => {

                console.log(' ==== SUCCESS DATA =====');
                console.log(data); 

                //this.all_programs = data.programDetails;
                this.all_programs = JSON.parse(data);
                console.log('programs:',JSON.parse(data));
                //this.actionRequired = data.actionRequired;
                /*this.all_programs.forEach((eachCard) => {
                    if(eachCard.ProgramStatus === 'Withdrawn') {
                        eachCard.withdrawStatus = true;
                    } else {
                        eachCard.withdrawStatus = false;
                    }
                });*/
            })
            .catch(error => {
                console.log("error", error);
            });
    }
    

    handleChangedLanguage(language){
        console.log('language selected from program license:',language);
        this.LangSelected=language;
    }

    //on load
    renderedCallback() {

        Promise.all([
            loadStyle(this, vdss_static_resources + '/VDSS_StaticResources/css/styles_vdss.css') //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');

        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });

        console.log('--- Logged In User Id ---> ' + loginUserId);
    }

    flipCardHorizontal(event) {
        let programId = event.currentTarget.dataset.flipbtnid;
        console.log('Event Called --> ' + programId);
        
        
        //modal.changeLabelData();
        
        let flipCard = this.template.querySelector(`[data-flipid="${programId}"]`); 
        console.log('Flipped --> ' + JSON.stringify(flipCard.style.transform));
        

        let flipped = false;
        if(flipCard.style.transform === 'rotateY(180deg)') {
            flipCard.style.transform = "rotateY(0deg)";
        } else {
            flipCard.style.transform = "rotateY(180deg)";
        }
        
    }

    removeCard(event) {
        try {
            this.withdrawCardDetails = event.detail;
            this.showWithdrawPopup = true;
            //this.textBoxValue = "";
        } catch(e) {
            console.log(e.stack);
        }
    }

    //Function to close the withdraw application  popup
    closePopup = (event) => {
        try {
            this.textBoxValue = "";
            this.showWithdrawPopup = false;
        } catch(e) {
            console.log(e.stack);
        }
    }

    //Function to withdraw the application and remove the program card
    withdrawApplication = (event) => {
        try {
            var cardData = this.withdrawCardDetails;
            var allProgCopy = JSON.parse(JSON.stringify(this.all_programs));
            var index = allProgCopy.findIndex((element) => { 
                //event.currentTarget.dataset.flipbtnid = element.Id; // to flip the card
                return (element.Id === cardData.cardId);
            });

            withdrawProgram({ recId: allProgCopy[index].Id, withdrawReason: this.textBoxValue })
            .then(data => {
                if (data === 'SUCCESS') {
                    allProgCopy[index].ProgramStatus = "Withdrawn";
                    allProgCopy[index].isWithdrawn = true;
                    this.all_programs = allProgCopy;
                    this.textBoxValue = "";
                    this.showWithdrawPopup = false;
                }
            })
            .catch(error => {
                console.log("error", error);
            });

            /*console.log('allProg length-> ', this.all_programs.length);
            console.log('allprog -> ', this.all_programs);
            var cardData = this.withdrawCardDetails;
            var allProgCopy = this.all_programs;
            var  index = allProgCopy.findIndex((element) => { 
                //event.currentTarget.dataset.flipbtnid = element.Id; // to flip the card
                return (element.Id === cardData.cardId);
            });
            //console.log('index is ',index);
            allProgCopy[index].ProgramStatus = "Withdrawn";
            allProgCopy[index].isWithdrawn = true;
            //allProgCopy.splice(index, 1); // use to remove the element from data
            this.all_programs = allProgCopy;
            console.log('removed allprog length -> ', this.all_programs.length);
            console.log('removed allprog -> ', this.all_programs);
            //this.flipCardHorizontal(event);
            this.showWithdrawPopup = false;*/


        } catch(e) {
            console.log(e.stack); 
        }
    }

    handleTextBox = (event) => {
        try {
            var inputVal = event.detail.value;
            this.textBoxValue = inputVal;
        } catch(e) {
            console.log(e.stack);
        }
    }

    handleLanguageChange(event) {
        var value = event.detail.value;
        this.LangSelected=value;
        updateLanguage({language:this.LangSelected})
        .then(data=>{
            console.log('updated successfully');
        })
        .catch(error=>{
            console.log('error->',error);
        });
        this. FetchTranslatedMetadata();
    }

    FetchTranslatedMetadata(){
        Fetch_lang_metadata({language:this.LangSelected})
        .then(data=>{
            console.log('Metadata data:',data);
            this.LanguageData=data;
            this.Programs = this.LanguageData.find(data => data.Label === 'Programs')!=undefined?this.LanguageData.find(data => data.Label === 'Programs').Language_Selected__c:'Programs'; 
            this.Program_Status = this.LanguageData.find(data => data.Label === 'Program Status')!=undefined?this.LanguageData.find(data => data.Label === 'Program Status').Language_Selected__c:'Program Status'; 
            this.License_Status = this.LanguageData.find(data => data.Label === 'License Status')!=undefined?this.LanguageData.find(data => data.Label === 'License Status').Language_Selected__c:'License Status'; 
            this.License_Type = this.LanguageData.find(data => data.Label === 'License Type')!=undefined?this.LanguageData.find(data => data.Label === 'License Type').Language_Selected__c:'License Type'; 
            this.License_Begin_Date = this.LanguageData.find(data => data.Label === 'License Begin Date')!=undefined?this.LanguageData.find(data => data.Label === 'License Begin Date').Language_Selected__c:'License Begin Date'; 
            this.License_End_Date = this.LanguageData.find(data => data.Label === 'License End Date')!=undefined?this.LanguageData.find(data => data.Label === 'License End Date').Language_Selected__c:'License End Date'; 
            this.Action_Required = this.LanguageData.find(data => data.Label === 'Action Required')!=undefined?this.LanguageData.find(data => data.Label === 'Action Required').Language_Selected__c:'Action Required'; 
            this.Click_here = this.LanguageData.find(data => data.Label === 'Click here')!=undefined?this.LanguageData.find(data => data.Label === 'Click here').Language_Selected__c:'Click here'; 
            this.Create_an_Application = this.LanguageData.find(data => data.Label === 'Create an Application')!=undefined?this.LanguageData.find(data => data.Label === 'Create an Application').Language_Selected__c:'Create an Application'; 

            var modal=this.template.querySelectorAll('c-vdss_programoptionslwccmp');
            modal.forEach(element => {
            element.languagedata=this.LanguageData;
            element.languageselected=this.LangSelected;
            element.changeLabelData();
          });
        })
    }
}