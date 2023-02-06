({
    doInit : function(component, event, helper) {       
        // $A.get("e.force:closeQuickAction").fire(); 
        try {
            var action = component.get("c.updateCAPonQuickActionClick");
            action.setParams({ 
                strRecordId : component.get("v.recordId"),
                strQuickAction:'Approve'
            });
            
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                console.log(response.getState());
                console.log(response.getError());
                if(response.getState() == 'SUCCESS') {
                    let strResult = response.getReturnValue();
                    if(strResult.data.boolStatus == 'true') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Action Plan is Approved Succesfully.',
                            mode: 'dismissible',
                            type:'success'
                        });
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        window.setTimeout(function(){
                            window.location.reload(); 
                        },2000);
                    } else if(strResult.data.boolStatus == 'false') {
                        window.setTimeout(function(){
                            window.location.reload(); 
                        },1000);
                    }                    
                }
            });
            $A.enqueueAction(action);
        } catch(ex) {
            console.log(ex);
        }
        
        
    },
    
})