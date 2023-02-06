import { LightningElement, api, track,wire } from 'lwc';
import onLoad from "@salesforce/apex/CLQ_OnsiteReviewFindingControllerLWC.onLoad";
import loadData from "@salesforce/apex/CLQ_OnsiteReviewFindingControllerLWC.loadData";
import createRulesInspected from "@salesforce/apex/CLQ_OnsiteReviewFindingControllerLWC.createRulesInspected";
import popupOnLoad from "@salesforce/apex/CLQ_OnsiteReviewFindingControllerLWC.popupOnLoad";
import onCancel from "@salesforce/apex/CLQ_OnsiteReviewFindingControllerLWC.onCancel";
import { NavigationMixin } from 'lightning/navigation';

export default class OnsiteReviewFindingLwc extends NavigationMixin(LightningElement) {
    @api inspid;
    @track isLoading=false;
    @track popupresult;
    domainwrapperlist;
    @track selectedInspectedRule;
    @track selectedRule;
    @track resultselected;
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
        onLoad({InspId:this.inspid})
        .then(data=>{
            console.log('data from Onload:',data);
            createRulesInspected({InspId:this.inspid})
            .then(data1=>{
                loadData({InspId:this.inspid})
                .then(res=>{
                    this.isLoading=false;
                    var wrapperlist=[];
                    console.log('res from loadData:',res);
                    res.forEach(ele=>{
                        var rulelist=[];
                        ele.rulelist.forEach(ele1=>{
                            rulelist.push({"selectedInspectedRule":ele1.ruleRecord.Id,"Name":ele1.ruleRecord.CLQ_Domain_Rule__r.CLQ_Rule__r.Name,"rating":ele1.rating,"point":ele1.point,"selectedRule":ele1.ruleRecord.CLQ_Domain_Rule__c,"resultselected":ele1.ruleRecord.CLQ_Result__c,'showRule':ele1.showRule});
                        })
                        console.log("rulelist==>", rulelist);
                        wrapperlist.push({"DomainName":ele.domainName,"rulelist":rulelist, "domainID":ele.domainID});
                    })
                    this.domainwrapperlist=wrapperlist;
                    console.log("domainwrapperlist:", this.domainwrapperlist);

                })
                .catch(error=>{
                    this.isLoading=false;
                    console.log('error from loadData:',error);
                })
            })
            .catch(error1=>{
                this.isLoading=false;
                console.log('error from createRulesInspected:',error1);
            })
        })
        .catch(error2=>{
            this.isLoading=false;
            console.log('error from onload:',error2);
        })
    }

    handleRowAction(event) {
        this.isLoading=true;
        console.log("row event:",event.detail.action.name)
        if (event.detail.action.name === 'Edit') {
            
            console.log("row detail event selectedRule:",event.detail.row.selectedRule);
            console.log("row detail event selectedInspectedRule:",event.detail.row.selectedInspectedRule);
            console.log("row detail event resultselected:",event.detail.row.resultselected);
            this.selectedInspectedRule=event.detail.row.selectedInspectedRule;
            this.selectedRule=event.detail.row.selectedRule;
            this.resultselected=event.detail.row.resultselected;
            popupOnLoad({selectedRule:this.selectedRule,selectedInspectedRule:this.selectedInspectedRule,resultselected:this.resultselected,InspId:this.inspid})
            .then(result=>{
                this.isLoading=false;
                console.log("result from popup:",result);
                //this.popupresult=result;
                const modal = this.template.querySelector('c-onsite-review-finding-popup-lwc');
                modal.popupresult=result;
                modal.inspid=this.inspid;
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
        this.isLoading=true;
        onCancel({InspId:this.inspid})
        .then(data=>{
            this.isLoading=false;
            console.log("data on cancel:",data);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.inspid,
                    objectApiName: 'CLQ_Inspection__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error=>{
            this.isLoading=false;
            console.log('error on cancel:',error);
        })
      
        

}
}