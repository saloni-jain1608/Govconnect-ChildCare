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
        var recommendedTotalCapacity = component.get("v.recommendedTotCapacity");
        var recommendedTotalCapacityUnderTH = component.get("v.recommendedTotCapacityUnderTH");
        var representativeName = component.get("v.repName");
        var representativeEmail = component.get("v.repEmail");

        var dataUrl = pad.toDataURL();
        var strDataURI = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");
        var action = component.get("c.signDocuments");

        action.setParams({
            signature: strDataURI,
            recordId: recordId,
            approvedTotCapacity: recommendedTotalCapacity,
            approvedTotCapacityUnderTH: recommendedTotalCapacityUnderTH,
            siteRepName: representativeName,
            siteRepEmail: representativeEmail
        });

        component.set("v.Spinner", true);
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                //Fire Event to close and redirect
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Visit Completed Successfully"
                });
                toastEvent.fire();
                helper.closeAndNavigate(component, true);
            }
        });

        $A.enqueueAction(action);
    },
    closeAndNavigate: function(component, visitDone) {
        console.log('Close and Navigate Called --> ' + visitDone);
        var compEvent = component.getEvent("closeSignature");
        compEvent.setParams({ "closeModal": true, "visitFullyComplete": visitDone });
        console.log('Component Set for Firing');
        compEvent.fire();

    }
})