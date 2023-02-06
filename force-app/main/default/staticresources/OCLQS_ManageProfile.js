OCLQS_MANAGEPROFILE = 
{
 //   showPhoneBlock : function ()
   // {        
     //   if($("select[id*='selectList']").val() == 'Yes'){
            
       //     $(".phoneElement").show();
        //}else{
          //  $(".phoneElement").hide();
        //}
    //},
	showAcceptButton : function ()
    {
        $(".savePhone").show();
        
    },
	openBlockerModal : function(messageIn , titleIn , btns )
	{
		bootbox.dialog({
            onEscape: false,
            backdrop: undefined,
            closeButton: true,
            animate: true,
            closeButton : false ,
            message : messageIn ,
            title : titleIn,
            className: "my-modal",
            buttons: btns 
        });	
	},
	
	getBothButtons : function()
	{
		return {
		        Dashboard: {
		            label: "Go To Dashboard",
		            className: "button button-alt",
		            callback: function () {
		            	oclsqs_cp.goToDashboard();
		            }
		        },
		        OK: {
		            label: "OK",
		            className: "btn btn-primary",
		            callback: function () {
		            	return null ;
		            }
		        }
		    };
	},
	
	getOneButton : function()
	{
		return {
	        OK: {
	            label: "OK",
	            className: "btn btn-primary",
	            callback: function () {
	            	return null ;
	            }
	        }
	    };
	},
    processPhoneResult : function(){
        
  
        bootbox.confirm({
            message: "Are you sure you want to proceed with changes ?",
            buttons: {
                confirm: {
                    label: 'Accept',
                    className: 'btn-success'
                },
                cancel: {
                    label: 'Decline',
                    className: 'btn-danger'
                }
            },
            callback: function (result) {
                if(result == true){
                   oclsqs_cp.savePhoneFinal();
                }else{
                    return null;
                }
                
            }
        });        
	},  processPhoneResult1 : function(){
      var phoneres = JSON.parse($("#mprofileResultJSONHidden").val()) ;  
      if(phoneres.isSuccess == true && phoneres.userUpdated == true )
		{
			modalButtons = OCLQS_MANAGEPROFILE.getBothButtons() ; 
		}else
		{
			//Generic block to handle just errors
			modalButtons = OCLQS_MANAGEPROFILE.getOneButton() ;
		}
		
		OCLQS_MANAGEPROFILE.openBlockerModal(phoneres.messages.join('<br/>'), '<b>' + phoneres.title  + '</b>' , modalButtons);
	}
    ,
	processPasswordResult : function()
	{
		var passwordRes = JSON.parse($("#mprofileResultJSONHidden").val()) ;
		var modalButtons ;
		
		if(passwordRes.isSuccess)
		{
			modalButtons = OCLQS_MANAGEPROFILE.getBothButtons() ;
		}else
		{
			modalButtons = OCLQS_MANAGEPROFILE.getOneButton() ;
		}	
	
		OCLQS_MANAGEPROFILE.openBlockerModal(passwordRes.messages.join('<br/>'), '<b>' + passwordRes.title  + '</b>' , modalButtons);
	},
	
	openPopUp : function()
	{
		if($("select[id*='selectList']").val() == 'Yes'){
			
			$(".agreementElement").show();
		}else{
			$(".agreementElement").hide();
		//	$(".phoneElement").hide();
		}
    },
	
	processProfileResult : function()
	{
		var profileRes = JSON.parse($("#mprofileResultJSONHidden").val()) ;
		var modalButtons ;
		if(profileRes.isSuccess == true 
			&& profileRes.userUpdated == true  
			&& profileRes.contactUpdated == true )
		{
			modalButtons = OCLQS_MANAGEPROFILE.getBothButtons() ; 
			OCLQS_MANAGEPROFILE.openBlockerModal(profileRes.messages.join('<br/>'), '<b>' + profileRes.title  + '</b>' , modalButtons);
		}else if(profileRes.isSuccess == true 
			&& profileRes.userUpdated == false  
			&& profileRes.contactUpdated == true)
		{
			//Contact Updated , but need to update user record 
			oclsqs_cp.saveUserRecord();
		}else
		{
			//Generic block to handle just errors
			modalButtons = OCLQS_MANAGEPROFILE.getOneButton() ;
			OCLQS_MANAGEPROFILE.openBlockerModal(profileRes.messages.join('<br/>'), '<b>' + profileRes.title  + '</b>' , modalButtons);
		}
	},
	
	processFinalProfileResult : function()
	{
		var profileRes = JSON.parse($("#mprofileResultJSONHidden").val()) ;
		if(profileRes.isSuccess == true && profileRes.userUpdated == true )
		{
			modalButtons = OCLQS_MANAGEPROFILE.getBothButtons() ; 
		}else
		{
			//Generic block to handle just errors
			modalButtons = OCLQS_MANAGEPROFILE.getOneButton() ;
		}
		
		OCLQS_MANAGEPROFILE.openBlockerModal(profileRes.messages.join('<br/>'), '<b>' + profileRes.title  + '</b>' , modalButtons);
	},
    
	
	bindLoadEvents : function()
	{
		$(".savePassword").on('click',function(){
			changePasswordValidator.performValidation() ;
		});
		
		$(".saveProfile").on('click',function(){
			profileValidator.performValidation() ;
		});
        
        //15817
        $(".savePhone").on('click',function(){
            
            phoneValidator.performValidation() ;
		});
        
	}
}

var changePasswordValidator = null;
var passwordManager = null ;
var profileValidator = null ;
var phoneValidator = null; //15817

$(document).ready(function()
{
    	passwordManager = new PasswordManager({
        container: $("#passwordStrengthPlaceHolder"),
        customTestCases: 
	        [
	            {
	                caseName: 'firstLast',
	                type: 'custom',
	                field: 'firstlast',
	                customTestCase: function (isValid, password) {
	                    var testString = password.toLowerCase();
	                    var hasFirst = null;
	                    var hasLast = null;
	                    $("#lastName").val().toLowerCase() == ""
	                        ? hasLast = false
	                        : hasLast = testString.indexOf($("#lastName").val().toLowerCase()) > -1
	                    $("#firstName").val().toLowerCase() == ""
	                        ? hasFirst = false
	                        : hasFirst = testString.indexOf($("#firstName").val().toLowerCase()) > -1
	
	                    return !hasFirst && !hasLast;
	                }
	            },
	            {
	                caseName : 'SpecialCharacter',
	                type : 'custom',
	                field : 'SpecialCharacter' , 
	                customTestCase: function (isValid, password)
	                {
	                    var testString = password.toLowerCase();
	                    var hasSpecialChar = false;
	                    var pattern = /^([@^&*()|~`{}\[\]:;?,.])$/;
	                    var strongRegex = new RegExp("^(?=.*[@^&*()|~`{}?;:,\"/.])");
	
	                    if(strongRegex.test($("[id$='password']").val())) {
	                        hasSpecialChar = false;
	                        return hasSpecialChar;
	                    } else {
	                        hasSpecialChar = true;
	                        return hasSpecialChar;
	                    }
	                }
	            } 
	        ]
    	});
    	
    	
    	var fieldsListPassword = 
    		[
                  {
                      id: "password",
                      watch: true,
                      name: "Password",
                      required: false,
                      event: 'keyup keydown blur',
                      customValidator: function (validator) {
                          validator.isValid = passwordManager.isValidCritera(validator.element.val())
                          //validator.isValid = true;
                          validator.isValid
                              ? validator.error = null
                              : validator.error = validator.name + " is not up to specification"
                      }
                  }, {
                      id: "confirmPassword",
                      watch: true,
                      name: "Confirm Password",
                      required: false,
                      event: 'blur',
                      customValidator: function (validator) {
                          if (validator.element.val() == validator.engineScope._validatorsMap["password"].element.val()) {
                              validator.isValid = true;
                              //validator.error = null;
                          } else {
                              validator.isValid = false;
                              validator.error = "Password not matching"
                          }
                      }
                  }
    	    ] ;
    	
    	var fieldObjectPassword = 
    		{
                onValidationSuccess: function () 
                {
                	oclsqs_cp.changePasswordAF($("[id$='password']").val()); 
                },
                defaultStyle: function (element, isValid) {
                    if (isValid) {
                        element.closest(".shade-container").removeClass("error");
                    } else {
                        element.closest(".shade-container").addClass("error");
                    }
                },

                fields: fieldsListPassword
            };

    	changePasswordValidator = new ValidationEngine(fieldObjectPassword);
    	
    	
        var fieldsListProfile = [
               {
                  id: "email",
                  watch: true,
                  name: "E-mail Address",
                  validator: "Email",
                  required: false
              }, {
                  id: "confirmEmail",
                  watch: true,
                  name: "Confirm Email",
                  validator: "Email",
                  required: false,
                  customValidator: function (validator) {

                      if (validator.element.val() == validator.engineScope._validatorsMap["email"].element.val()) {
                          validator.isValid = true;
                          validator.error = null;
                          $("#usernameReadOnly").html( validator.element.val() );
                      } else {
                          validator.isValid = false;
                          validator.error = validator.name + " not matching"
                          $("#usernameReadOnly").html(validator.element.val());
                      }
                  }
              }
          ];
    	
        
    	var fieldObjectProfile = 
		{
            onValidationSuccess: function () 
            {
            	oclsqs_cp.SaveProfile() ; 
            },
            defaultStyle: function (element, isValid) {
                if (isValid) {
                    element.closest(".shade-container").removeClass("error");
                } else {
                    element.closest(".shade-container").addClass("error");
                }
            },

            fields: fieldsListProfile
        };
    	
    	profileValidator = new ValidationEngine(fieldObjectProfile) ;
    	
       // if($("input[name$='rdoSMSPrivacy']:checked").val()=='No' || $("input[name$='rdoSMSTerm']:checked").val()=='No' || $("input[name$='rdoSMSopt']:checked").val()=='No')
     //      {
    	fieldListPhone = [
            {
                  id: "phonenumber",
                  watch: true,
                  name: "Phone Number",
                  validator: "Phone",
                  required: false
                  
            }
        ];
           //}
    	var fieldObjectPhone =
            {
                onValidationSuccess: function () 
            {
               
            	oclsqs_cp.savePhone() ; 
            },
            defaultStyle: function (element, isValid) {
                if (isValid) {
                    element.closest(".shade-container").removeClass("error");
                } else {
                    element.closest(".shade-container").addClass("error");
                }
            },

            fields: fieldListPhone
            }
                
            
    	phoneValidator = new ValidationEngine(fieldObjectPhone);
    
    
    	OCLQS_MANAGEPROFILE.bindLoadEvents() ;
    //	OCLQS_MANAGEPROFILE.showPhoneBlock();//15817
		OCLQS_MANAGEPROFILE.openPopUp();
    	
    	
});

