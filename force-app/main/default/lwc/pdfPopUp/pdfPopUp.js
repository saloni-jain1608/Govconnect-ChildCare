import { LightningElement,track,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @api isModalOpen = false;
    @api vfpageurl;
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        const selectedEvent = new CustomEvent("pdfmodalevent", {
            detail: 'ok'
          });
    
          this.dispatchEvent(selectedEvent);
    }
}