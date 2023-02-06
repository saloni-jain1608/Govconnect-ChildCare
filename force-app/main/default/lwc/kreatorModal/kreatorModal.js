import { LightningElement, api, track } from 'lwc';

const HIDE_MODAL = 'slds-hide';
export default class KreatorModal extends LightningElement {
    @api size;
    @api modalName;
    @track class;

    closeIconsList;
    isRendered = false;

    get className() {
        this.setClassName();
        return this.class;
    }

    @api 
    get openModal(){
        return;
    }
    
    set openModal(value){
        if(value && value===this.modalName) {
             this.modalClass = '';
        }
        else this.modalClass = HIDE_MODAL;
    }

    renderedCallback(){
        if(!this.isRendered){
            this.setClassName();
            this.isRendered = true;
        }
    }

    setClassName(){
        switch (this.size) {
            case "small":
                this.class = 'slds-modal slds-fade-in-open slds-modal_small ';
                break;
            case "medium":
                this.class = 'slds-modal slds-fade-in-open slds-modal_medium ';
                break;
            case "large":
                this.class = 'slds-modal slds-fade-in-open slds-modal_large ';
                break;
            default:
                this.class = 'slds-modal slds-fade-in-open slds-modal_medium ';
        }
    }

    
}