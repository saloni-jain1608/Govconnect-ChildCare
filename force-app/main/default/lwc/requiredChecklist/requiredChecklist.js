import { LightningElement,api,wire,track } from 'lwc';
import getRequiredQuestions from '@salesforce/apex/RequiredCheckListItems.getChecklistRecords';
export default class RequiredChecklist extends LightningElement {

    @track questions;
    @track error;
    connectedCallback(){
        this.getQuestions();
    }
    getQuestions(){
        var setQuestions =[];
        getRequiredQuestions()
        .then(result => {
            this.questions = result;
            console.log('questions are '+JSON.stringify(this.questions));
        })
        .catch(error => {
            this.error = error;
        });
    }
}