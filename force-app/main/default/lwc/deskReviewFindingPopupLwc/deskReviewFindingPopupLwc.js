import { LightningElement,api,track } from 'lwc';
import savePopUp from "@salesforce/apex/CLQ_DeskReviewFindingControllerLWC.savePopUp";



export default class DeskReviewFindingPopupLwc extends LightningElement {

    showModal = false;
    @api popupresult;
    @api progtransid;
    @api selectedRule;

    @track columns = [{
        label: 'Select',
        type: 'customCheckbox',
        fieldName: 'isSelected',
        typeAttributes: {
            isSelected: { fieldName: 'isSelected' },
            recordid:{fieldName:'Id'}
        },
       
    },
    {
        label: 'Standard Findings',
        fieldName: 'sfindingName',
        type: 'text'
       
    },
    {
        label: 'Rating',
        fieldName: 'rating',
        type: 'text',
        
    },
    {
        label: 'Point',
        fieldName: 'point',
        type: 'text',
    },
    {
        label: 'Description',
        fieldName: 'description',
        type: 'customTextArea',
        typeAttributes: {
            description: { fieldName: 'description' },
            recordid:{fieldName:'Id'}
        },
       
    },
];

    connectedCallback(){
        
        
    }

  
@track popupresmod=[];
    @api show() {
        this.popupresmod=[];
        this.showModal = true;
        console.log("popupresult:",this.popupresult[0].rating);
        this.popupresult.forEach(ele=>{
            this.popupresmod.push({'Id':ele.standardFindings.CLQ_Standard_Finding__c,'isSelected':ele.isSelected,'standardFindings':ele.standardFindings,'rating':ele.rating,'point':ele.point,'description':ele.description,'sfindingName':ele.sfindingName,'sMetOrNotMet':ele.sMetOrNotMet});
        })
        console.log('popupresmod:',this.popupresmod);
        this.popupresult=this.popupresmod;
        
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        this.hide();
    }

    handleCloseModal(){
        this.hide();
    }
    handlecheckboxevent(event){
        console.log('event from checkbox event:',event.detail.recordid, event.detail.checkboxval);
        var recid=event.detail.recordid ;
        console.log('recid',recid.substring(0,18));
        var selected=event.detail.checkboxval;
        this.popupresmod.forEach(ele=>{
            if(ele.Id==recid.substring(0,18)){
                if(selected==true){
                    this.popupresmod.forEach(ele1=>{
                        if(ele1.isSelected==true){
                            ele1.isSelected=false;
                        }
                    })
                    ele.isSelected=true;
                }
            }
        })
        const modal = this.template.querySelector('c-custom-lightning-table');
        this.popupresult=this.popupresmod;
        modal.data=this.popupresult;
        console.log('popupresult after checkbox event:',this.popupresult);
    }

    handleTextAreaEvent(event){
        console.log('event from textarea event:',event.detail.recordid, event.detail.textareaval);
        var recid=event.detail.recordid ;
        console.log('recid',recid.substring(0,18));
        var descriptionval=event.detail.textareaval;
        this.popupresmod.forEach(ele=>{
            if(ele.Id==recid.substring(0,18)){
                    ele.description=descriptionval;
                    var ele1=JSON.parse(JSON.stringify( ele.standardFindings));
                    ele1.CLQ_Description__c=descriptionval;
                    ele.standardFindings=ele1;
                    ;
                }
        })
        this.popupresult=this.popupresmod;
        console.log('popupresult after Textarea event:',this.popupresult);

    }

    handleSave(){
        console.log('popupresult after save:',this.popupresult);
        savePopUp({selectedRule:this.selectedRule,ProgTransactionId:this.progtransid,popupWrapperList:this.popupresult})
        .then(data=>{
            console.log('data from savepopup:',data);
            const event1 = new CustomEvent('popuponsave', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    status:'success' 
                },
            });
            this.dispatchEvent(event1);
            this.hide();
        })
        .catch(error=>{
            console.log('error from savepopup:',error);
        })

    }
   

}