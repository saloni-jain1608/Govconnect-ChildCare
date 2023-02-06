({
    init: function (component, event, helper) {
        console.log('init method'+component.get("v.pageReference"));
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),sParameterName;        
        for (var i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');            
            if (sParameterName[0] === 'recordid') {
                console.log('id+'+sParameterName[1]);
                component.set("v.recordId",sParameterName[1]);
            }
        }
        /*var pageReference = component.get("v.pageReference");
		component.set("v.recordId", pageReference.state.accountName);*/
        console.log('sURLVariables+'+sURLVariables);
        //helper.eraseHelper(component, event, helper);
        
    },
    
    erase: function (component, event, helper) {
        console.log('erase called');
        helper.eraseHelper(component, event, helper);
    },
    
    save: function (component, event, helper) {
        console.log('Save Method Called');
        
        helper.saveHelper(component, event, helper);
        
    },
    onNext: function (component, event, helper) {
        component.set("v.showSign", true);
    },
    closeModal: function (component, event, helper) {
        helper.closeAndNavigate(component, false);
    },
    cancelModal: function (component, event, helper) {
        console.log('Cancel Modal Called');
        /*var navService = component.find("navService");        
        var pageReference = {            
            type: "comm__namedPage",
            attributes: {
                pageName: "home-landing-page"
            }
        };
        navService.navigate(pageReference);*/
        window.location.href = "/dss/s/home-landing-page";
    },
    showSpinner: function (component, event, helper) {
        component.set("v.Spinner", true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.Spinner", false);
    }
})