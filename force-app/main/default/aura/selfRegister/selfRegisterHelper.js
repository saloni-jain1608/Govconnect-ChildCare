({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.get("v.firstnameval");
        var lastname = component.get("v.lastnameval");
        var email = component.get("v.emailval");
        var includePassword = component.get("v.includePasswordField");
        var password = component.get("v.passwordval");
        var confirmPassword = component.get("v.repasswordval");
        var accName = component.get("v.accountnameval");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = "/s/home-landing-page";//component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                          password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:true, accName: accName});
          action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          //alert("return value = "+ rtnValue);
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
          }
       });
    $A.enqueueAction(action);
    },

    handleinputchange : function (component, event, helpler) {
        try{
            var value = event.currentTarget.value;
            var name = event.currentTarget.name;
            if(name === "firstname"){
                component.set("v.firstnameval",value);
            }
            if(name === "lastname"){
                component.set("v.lastnameval",value);
            }
            if(name === "accName"){
                component.set("v.accountnameval",value);
            }
            if(name === "email"){
                component.set("v.emailval",value);
            }
            if(name === "password"){
                component.set("v.passwordval",value);
            }
            if(name === "confirmpassword"){
                component.set("v.repasswordval",value);
            }
        }
        catch(e){
            console.log(e.stack);
        }
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }    
})