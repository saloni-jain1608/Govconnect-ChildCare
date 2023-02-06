import { LightningElement,api,track} from 'lwc';
import pubsub from 'c/pubsub' ; 

export default class Applicationform extends LightningElement {
	@api message;
	@api strHeader;
	@track boolShowProgramInformation
	@track boolShowRequiredChecklist
    connectedCallback(){
        this.regiser();
    }
    regiser(){
        window.console.log('event registered ');
        pubsub.register('simplevt', this.handleEvent.bind(this));
    }
    handleEvent(messageFromEvt){
        window.console.log('event handled ',messageFromEvt.message);
		
		if(messageFromEvt.message) {
			if(messageFromEvt.message ==  'program information') {
				console.log('INHERE');
				this.boolShowProgramInformation = true;
				this.message = 'Program Informatiom';
				this.strHeader = 'PROGRAM INFORMATION (THIS SECTION MUST BE COMPLETED IN ITS ENTIRETY)';
			} else if(messageFromEvt.message ==  'business entity') {
			this.message = 'Business Entity';
			} else if(messageFromEvt.message ==  'required attached checklist') {
			this.message = 'Required Attached Checklist';			
			this.boolShowRequiredChecklist = true;
			this.strHeader ='PART 3: REQUIRED ATTACHMENTS';
			} else if(messageFromEvt.message ==  'fees') {
			this.message = 'Fees';
			} else if(messageFromEvt.message ==  'e signature') {
			this.message = 'E Signature';
			}
		}
    }

}