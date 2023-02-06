import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Vdss_dynamicQnFramework_InstructionPage extends NavigationMixin(LightningElement) {
    @api instructionText="";
    @api languagedata;
    @track Instructions='Instructions';
    @track Cancel='Cancel';
    @track Continue_to_Application='Continue To Application';

    connectedCallback(){
        this.setButtonLabels();
    }
  
    @api
    setButtonLabels() {
       // console.log('setButtonLables data:',this.languagedata);
       if(this.languagedata.find(data => data.English__c === 'Instructions')!=undefined){
        this.Instructions=this.languagedata.find(data => data.English__c === 'Instructions').Language_Selected__c; 
        this.Cancel=this.languagedata.find(data => data.English__c === 'Cancel').Language_Selected__c; 
        this.Continue_to_Application=this.languagedata.find(data => data.English__c === 'Continue To Application').Language_Selected__c; 
       }
    }

    handle_ContinueFlow(event){
        const continueApplicationEvent = new CustomEvent("continuetoapplication", {
            //detail: this.progressValue
            detail: event.currentTarget.dataset.id
        });
        // Dispatches the event.
        this.dispatchEvent(continueApplicationEvent);
    }
    
    handle_CancelFlow(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home-landing-page'
            }
        });
    }
   

}