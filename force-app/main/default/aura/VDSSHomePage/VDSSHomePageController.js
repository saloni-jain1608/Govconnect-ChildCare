({
    doInit : function(component, event, helper){ 
        var page;
        var action = component.get('c.isrendered');
        action.setCallback(this,function(result){
            component.set('v.rendered',result.getReturnValue());
            if(result.getReturnValue()){
                page = 'landingpage';
            }
            else{
                page = 'vdss-login';
            }
            window.location = page;
        });
        $A.enqueueAction(action);
    } 
	
 })