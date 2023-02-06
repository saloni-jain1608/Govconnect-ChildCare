({
	myAction : function(component, event, helper) {
		
	},
    loginRegisterButton: function(component, event, helper) {
        helper.loginRegister(component, event.getSource().get("v.name"));
    },
})