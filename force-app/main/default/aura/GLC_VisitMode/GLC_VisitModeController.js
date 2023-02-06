({
    doInit: function (component, event, helper) {
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        if (pageRef != null) {
            var state = pageRef.state;

            // state holds any query params
            console.log('state = ' + JSON.stringify(state));
            if (state.inContextOfRef != undefined) {
                var base64Context = state.inContextOfRef;
                console.log('base64Context = ' + base64Context);
                if (base64Context.startsWith("1\.")) {
                    base64Context = base64Context.substring(2);
                    console.log('base64Context = ' + base64Context);
                }
                var addressableContext = JSON.parse(window.atob(base64Context));
                console.log('addressableContext = ' + JSON.stringify(addressableContext));
                component.set("v.recordId", addressableContext.attributes.recordId);
            } else {
                component.set("v.recordId", state.c__recordId);
            }
        }
    },

    handleVisitCompeltion: function (component, event, helper) {
        console.log('Visit completion aura');
        component.set("v.sign", true);
        component.set("v.renderRules", false);
    },

    closeSignModal: function (component, event, helper) {
        console.log('Parent Event Handled');
        var recordId = component.get("v.recordId");
        var visitComplete = event.getParam('visitFullyComplete');
        if (visitComplete) {
            component.set("v.sign", false);
            component.set("v.render", true);
        } else {
            component.set("v.sign", false);
            component.set("v.renderRules", true);
        }
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})