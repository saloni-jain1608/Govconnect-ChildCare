({
    ontesteventalert : function(component, event, helper) {
        alert('pass');
        var actionAPI = component.find("quickActionAPI");
        //var fields = {CLQ_Document_Status__c: {value: "Denied"}};
        //Quick Action with target field values
        var args = {actionName: "CLQ_CAP_Documents__c.Test", entityName: "CLQ_CAP_Documents__c"};
        actionAPI.selectAction(args).then(function(result){
            actionAPI.invokeAction(args);
            console.log(result);
            console.log(JSON.stringify(result));
        }).catch(function(e){
            console.error(e.errors);
        });
    }
})