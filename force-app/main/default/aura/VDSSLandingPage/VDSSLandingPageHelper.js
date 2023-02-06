({
	loginRegister: function(component, btnName) {
        try {
            //var btnName = event.getSource().get("v.name");
            switch (btnName) {
                case "login-btn":
                    //this.sessionStorageSetItem("login", "Yes");
                    //this.localStorageSetItem("login", "Yes");// By Aneesh for defect - 32729 : Session storage is not working in IE
                    var loginURL = 'login';//component.get("v.loginUrl");
                    window.location = loginURL;
                    break;
                case "register-btn":
                    //this.sessionStorageSetItem("login", "No");
                    //this.localStorageSetItem("login", "No");// By Aneesh for defect - 32729 : Session storage is not working in IE
                    var registerURL = 'login';//component.get("v.registerUrl");
                    window.location = registerURL;
                    break;
			    default:
                    break;
            }
        } catch (e) {
            this.consoleLog(e.stack, true);
        }
    },

})