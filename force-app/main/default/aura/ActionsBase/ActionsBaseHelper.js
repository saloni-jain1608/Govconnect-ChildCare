({
    closeModalFromBase: function (component, event) {

        $A.get("e.force:closeQuickAction").fire();
        
    }
})