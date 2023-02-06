({
    doInit: function (component, event, helper) {
        var t = document.getElementById("signature");
        console.log('value of t ' + t);
        if (t != null) {
            t.height = '200';
            t.width = '564';
            var signaturePad = new SignaturePad(t, {
                backgroundColor: 'rgb(255, 255, 255)'
            });
            signaturePad.clear();
        }
    },
    eraseHelper: function (component, event, helper) {
        
        var t = document.getElementById("signature");
        console.log('value of t ' + t);
        if (t != null) {
            t.height = '200';
            t.width = '564';
            var signaturePad = new SignaturePad(t, {
                backgroundColor: 'rgb(255, 255, 255)'
            });
            signaturePad.clear();
        }
    },
    saveHelper: function (component, event, helper) {
        var pad = document.getElementById("signature");
        var recordId = component.get("v.recordId");        
        
        var dataUrl = pad.toDataURL();
        var strDataURI = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");
        var action = component.get("c.updateApplicationStatus");
        
        action.setParams({
            signature: strDataURI,
            recordId: recordId,
            
        });
        
        component.set("v.Spinner", true);
        action.setCallback(this, function (res) {
            var state = res.getState();
            console.log("state++"+JSON.stringify(state));
            if (state === "SUCCESS") {
                //Fire Event to close and redirect
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Application have been successfully saved."
                });
                toastEvent.fire();
                /*var navService = component.find("navService");
                // Sets the route to /lightning/o/Account/home
                var pageReference = {
                    type: 'comm__namedPage',
                    attributes: {
                        "pageName": "home-landing-page"
                    }
                };
                navService.navigate(pageReference);*/
                window.location.href = "/dss/s/home-landing-page";
            }
            else{
                
            }
            component.set("v.Spinner", false);
        });
        
        $A.enqueueAction(action);
        
        
        //cmp.set("v.pageReference", pageReference);
        
    },
    closeAndNavigate: function(component, visitDone) {
        console.log('Close and Navigate Called --> ' + visitDone);
        
        
    }
})