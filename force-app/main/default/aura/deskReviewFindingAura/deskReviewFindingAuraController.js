({
    doInit:function(component,event,helper){
        component.set("v.ProgTransBool",false);
        component.set("v.InspectBool",false);
        var ref=component.get('v.pageReference');
        var record=ref.state.c__recordId;
        var recordtype=ref.state.c__rectype;
        
        console.log("record:",record);
        console.log("recordtype:",recordtype);
        component.set("v.recordId",record);
        component.set("v.recordtype",recordtype);
        if(recordtype=="CLQ_Program_Transaction__c"){
            component.set("v.ProgTransBool",true);
             var deskReviewComp=component.find('deskReviewCompId');
             deskReviewComp.loadDataApx();
        }
        if(recordtype=="CLQ_Inspection__c"){
            component.set("v.InspectBool",true);
            var onsiteReviewComp=component.find('onsiteReviewCompId');
             onsiteReviewComp.loadDataApx();
        }
       
    }
})