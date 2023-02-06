({
    doInit: function(component, event, helper) {
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

    refreshView: function() {
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },

    reInit: function() {
        $A.get('e.force:refreshView').fire();
    }
})