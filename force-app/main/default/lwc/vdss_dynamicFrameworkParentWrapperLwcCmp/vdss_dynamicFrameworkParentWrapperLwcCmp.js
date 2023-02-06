import { LightningElement, track, api, wire } from 'lwc';

import getDynamicApplicationMetadata from '@salesforce/apex/vdssCommunityProgramsMain.getDynamicApplicationMetadata';
import loginUserId from '@salesforce/user/Id';

export default class Vdss_dynamicFrameworkParentWrapperLwcCmp extends LightningElement {

    @api applicationPageId;
    selectedProgramId;
    @api jsonData;
    isJsonDataRetrieved=false;
    programTransactionId;
    @track Lang_Selected;
    isLoading=true;;


    connectedCallback(){

       

        console.log(" === Calling Backend to Fetch Data ===>");

        //this.applicationPageId="a2B6w000000GvLgEAK";
        this.selectedProgramId = this.getUrlParam(window.location.href, 'selectedProgramId');
        this.programTransactionId = this.getUrlParam(window.location.href, 'programTransactionId');
        this.Lang_Selected = this.getUrlParam(window.location.href, 'languageselected');
        
        console.log(this.selectedProgramId + '--' + this.programTransactionId);
        
        

        getDynamicApplicationMetadata( { applicationType : 'Licensing - New Application', selectedProgramId : this.selectedProgramId, userId: loginUserId, programTransactionId: this.programTransactionId, language: this.Lang_Selected } )
        .then(data => {
            
            console.log(" ==== connectedCallback SUCCESS in retrieving DATA =====");
            console.log(data);
            this.isLoading=false;
            //console.log(JSON.stringify(data));

            this.jsonData = JSON.parse(data);
            this.jsonData.Sections.forEach((section) => {
                if(section.Status === 'Completed') {
                    section.isCompleted = true;
                } else {
                    section.isCompleted = false;
                }
            }); 

           
            this.isJsonDataRetrieved = true;
        })
        .catch(error => {
            console.log(" ==== connectedCallback ERROR in retrieving DATA =====", error);
        });
    }

    getUrlParam(url, key) {
        return new URL(url).searchParams.get(key);
    }
}