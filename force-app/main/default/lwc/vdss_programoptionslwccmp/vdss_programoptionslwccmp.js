import { LightningElement,api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Vdss_programoptionslwccmp extends NavigationMixin(LightningElement) {
    @api programStatus;
    @api capRaised = false;
    @api languageselected;
    @api languagedata;
    isProgramLicensed;
    @api cardId;
    @api appId;
    @track disablecontinueapp;
    @api programSubmissionStatus;
    @api Document_Upload='Document Upload';
    @api Continue_Application='Continue Application';
    @api Withdraw_Application='Withdraw Application';

    @api
    changeLabelData(){
        console.log('language data:',this.languagedata);
       
        this.Document_Upload=this.languagedata.find(data => data.Label === 'Document Upload').Language_Selected__c; 
        this.Continue_Application=this.languagedata.find(data => data.Label === 'Continue Application').Language_Selected__c; 
        this.Withdraw_Application=this.languagedata.find(data => data.Label === 'Withdraw Application').Language_Selected__c;
        
    }

    connectedCallback(){
        
        console.log('--- License Status --- '+this.programStatus);
        if(this.programStatus=='Licensed'){
            this.isProgramLicensed=true;
        }
        if(this.programSubmissionStatus!='Not Submitted'){
            this.disablecontinueapp=true;
        }
    }

    downloadlicense(event){
        window.open("/vdss1/resource/1608198738000/License?");
        /*this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/DownloadLicense?selectedProgramId=' + this.cardId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        }); */
    }

    downloadInspectionReport(event){
        window.open("/dss/resource/1609748576000/Licensing_Inspection_Summary_Report?");
    }

    //Nir start
    continueApplication(event) {
        //event.preventDefault();
        //event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'program-license'
            },
            state: {
                selectedProgramId: this.cardId,
                programTransactionId: this.appId,
                languageselected: this.languageselected
            }
        });
    }

    withdrawApplication = (event) => { 
        try {
            const withdrawCard = new CustomEvent("removecard", {
                detail: {
                    cardId: this.cardId,
                    prgmTrascnId: this.appId,
                    prgmStat: this.programStatus,
                    cardType: event.currentTarget.dataset.name,
                }
            });
            // Dispatches the event.
            this.dispatchEvent(withdrawCard);
        } catch(e) {
            console.log(e.stack);
        }
    }
    //Nir End

}