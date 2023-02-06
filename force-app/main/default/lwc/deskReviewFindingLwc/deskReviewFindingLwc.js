import { LightningElement, api, track,wire } from 'lwc';
import loadData from "@salesforce/apex/CLQ_DeskReviewFindingControllerLWC.loadData";
import createRulesInspected from "@salesforce/apex/CLQ_DeskReviewFindingControllerLWC.createRulesInspected";
import popupOnLoad from "@salesforce/apex/CLQ_DeskReviewFindingControllerLWC.popupOnLoad";
import { NavigationMixin } from 'lightning/navigation';

export default class DeskReviewFindingLwc extends NavigationMixin(LightningElement) {

    @api progtransid;
    @track isLoading=false;
    @track popupresult;
    domainwrapperlist;
    @track selectedInspectedRule;
    @track selectedRule;
    @track columns = [{
        label: 'Rule Name',
        fieldName: 'Name',
        type: 'text'
       
    },
    {
        label: 'Selected Rating',
        fieldName: 'rating',
        type: 'text'
       
    },
    {
        label: 'Selected Points',
        fieldName: 'point',
        type: 'text',
        
    },
    {
        label: '',
        fieldName: '',
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:insert_template',
            name: 'Edit',
        }
       
    },
   
   
];

    connectedCallback(){
        this.loadDataApx();
    }

    @api
    loadDataApx(){
        this.isLoading=true;
        createRulesInspected({ProgTransactionId: this.progtransid })
        .then(result1=>{
            loadData( { ProgTransactionId: this.progtransid })
            .then(result=>{
                this.isLoading=false;
                var wrapperlist=[];
                console.log('onload data:',result);
                console.log('onload data record:', result.length);
                result.forEach(ele=>{
                    var rulelist=[];
                    ele.rulelist.forEach(ele1=>{
                        rulelist.push({"selectedInspectedRule":ele1.ruleRecord.Id,"Name":ele1.ruleRecord.CLQ_Domain_Rule__r.CLQ_Rule__r.Name,"rating":ele1.rating,"point":ele1.point,"selectedRule":ele1.ruleRecord.CLQ_Domain_Rule__c,"resultselected":ele1.ruleRecord.CLQ_Result__c});
                    })
                    console.log("rulelist==>", rulelist);
                    wrapperlist.push({"DomainName":ele.domainName,"rulelist":rulelist, "domainID":ele.domainID});
                })
                this.domainwrapperlist=wrapperlist;
                console.log("domainwrapperlist:", this.domainwrapperlist);

            })
            .catch(error=>{
                this.isLoading=false;
                console.log('onload error:',error);
            });

        })
        .catch(error1=>{
            this.isLoading=false;
            console.log('error in rules inspected:', error1);
        })
        
    
    }

    

    handleRowAction(event) {
        this.isLoading=true;
        console.log("row event:",event.detail.action.name)
        if (event.detail.action.name === 'Edit') {
            
            console.log("row detail event selectedRule:",event.detail.row.selectedRule);
            console.log("row detail event selectedInspectedRule:",event.detail.row.selectedInspectedRule);
            this.selectedInspectedRule=event.detail.row.selectedInspectedRule;
            this.selectedRule=event.detail.row.selectedRule;
            popupOnLoad({"selectedRule":this.selectedRule,"selectedInspectedRule":this.selectedInspectedRule,"ProgTransactionId":this.progtransid})
            .then(result=>{
                this.isLoading=false;
                console.log("result from popup:",result);
                //this.popupresult=result;
                const modal = this.template.querySelector('c-desk-review-finding-popup-lwc');
                modal.popupresult=result;
                modal.progtransid=this.progtransid;
                modal.selectedRule=this.selectedRule;
                modal.show();
                
            })
            .catch(error=>{
                this.isLoading=false;
                console.log("error from popup:",error);
            })
            
  
        }
    }

    handlePopupEvent(event){
        console.log("event from popup:",event.detail.status);
        if(event.detail.status=='success'){
            this.loadDataApx();
        }
    }

    handleback(){
      
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.progtransid,
                    objectApiName: 'CLQ_Program_Transaction__c',
                    actionName: 'view'
                }
            });
    
    }
        
   
}