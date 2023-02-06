$(function() {
    // Date picker
    if ($('.customDateNow').length > 0) {  //defensive error handling
        $('.customDateNow').datepicker({
         onSelect: function()
         {
             $(this).closest(".shade-container").removeClass("error") ;
         }
      });
    }
    //14701 - Added the date picker for Access End date
    if ($('.customDateNow1').length > 0) {  //defensive error handling
        $('.customDateNow1').datepicker();
    }
    if ($('.customDateTime').length >0) { //defensive error handling
      $('.customDateTime').datetimepicker({}).on('dp.change', function (ev) {
            $(this).parent().removeClass("error") ;
            $(this).parent().removeClass("errorElement") ;
            // LOGIC TO HANDLE ANIMATION
            $(this).parent().find(".InputLabel").removeClass('InputLabel_Out').addClass('InputLabel_In');//your function call
        });
    }

    // Date picker
    // $('.customDatePicker').datepicker({
        // onSelect: function(){
        //     $(this).parent().removeClass("error") ;
        //     $(this).parent().removeClass("errorElement") ;
        //     var curDate = $(this).val();
        //     var date = new Date(curDate);
        //     var day = '' + date.getDate();
        //     if(day.length < 2) {
        //         day = '0' + day;
        //     }
        //     var month = '' + (date.getMonth() + 1);
        //     if(month.length < 2) {month = '0' + month;}
        //     var year = '' + date.getFullYear();
        //     $(this).val(year + '-' + month + '-' + day);
        //     console.log(year + '-' + month + '-' + day);
        // }
    // });

    // Hide suggested date
    $(".dateFormat").hide();

    //apply lookup style on element that has a lookup field
    $('.lookupInput').find('input').attr('disabled', true);
    $('.lookupInput').find('a').removeClass().addClass("lookup-icon glyphicon glyphicon-search");
});


OCLQS_UTILS = 
    {
        correctDateError : function(element)
        {
            try
            {
                var elementValue = element.val() ;
                if(typeof elementValue != 'undefined' && elementValue != '')
                {
                    var dtValue = new Date(elementValue) ;
                    if(dtValue =="Invalid Date")
                    {
                        element.closest(".shade-container").addClass("error") ;
                    }else
                    {
                        element.closest(".shade-container").removeClass("error") ;
                    }
                }else
                {
                    element.closest(".shade-container").addClass("error") ;
                }
            }catch(e){}
        }
    }

OH_NOTIFICATIONS = {

    spinnerStart : function(){

        // IF SPINNER IS ALREADY started , go back
        if($("#oh_app_page_spinner_inline_div").length > 0 )
        {
            return false ;
        }

        var overlaySpinner = $("<div>").attr({"id":"oh_app_page_spinner_inline_div", "z-index": 99999}).addClass("spinner")
        .append($("<div>").addClass("spinner-icon"));
        $("body").append(overlaySpinner);
     },

    spinnerStop  : function(){
        $("#oh_app_page_spinner_inline_div").remove();
    },

    showSuccessMessage : function(title,errorMessage,targetElement){
        var err = $("<div>").addClass("alert alert-success").attr("role","alert").append(
            $("<span>").addClass("glyphicon glyphicon-exclamation-sign").attr("aria-hidden",true).html($("<b>").html(" " + title )),
            $("<p>").html(errorMessage)).attr("title","Click to hide this  message ");
        targetElement.html(err).show();
        targetElement.click(function(){
            $(this).hide();
        });
    },

    showWarningMessage : function(title,errorMessage,targetElement){
        var err = $("<div>").addClass("alert alert-warning").attr("role","alert").append(
            $("<span>").addClass("glyphicon glyphicon-exclamation-sign").attr("aria-hidden",true).html($("<b>").html(" " + title )),
            $("<p>").html(errorMessage)).attr("title","Click to hide this  message ");
        targetElement.html(err).show();
        targetElement.click(function(){
            $(this).hide();
        });
    },

    showErrorMessage : function(title,errorMessage,targetElement)
    {
        var err = $("<div>").addClass("alert alert-danger").attr("role","alert").append(
            $("<span>").addClass("glyphicon glyphicon-exclamation-sign").attr("aria-hidden",true).html($("<b>").html(" " + title )),
            $("<p>").html(errorMessage)).attr("title","Click to hide this  message ");
        targetElement.html(err).show();
        targetElement.click(function(){
            $(this).hide();
        });
    }
}



;OH_MODAL_UTILITY = {
    openDeleteConfirmationModal : function(deleteConfirmationMessage , deleteWarningTitle , callBackParameters , callbackFunctionOnDelete )
    {
        bootbox.dialog({
        message:deleteConfirmationMessage ,
        title: deleteWarningTitle,
        onEscape: function() {},
        backdrop: true,

        /**
       * @optional Boolean
       * @default: true
       * show a close button
       */
        closeButton: false,
        animate: true,
        className: "my-modal",
        buttons: {
            cancel: {
                label: "Cancel",
                className: "btn btn-tertiary",
                callback: function() { }
            },
            continue: {
                    label: "Delete",
                    className: "btn btn-primary",
                    callback: function()
                    {
                        if(typeof callbackFunctionOnDelete === "function")
                        {
                            callbackFunctionOnDelete(callBackParameters);
                        }
                    }
            }
           }
          });


    },

    openContinueConfirmationModal : function(contConfirmationMessage , contWarningTitle , callBackParameters , callbackFunctionOnContinue )
    {
        bootbox.dialog({
        message:contConfirmationMessage ,
        title: contWarningTitle,
        onEscape: function() {},
        backdrop: true,

        /**
       * @optional Boolean
       * @default: true
       * show a close button
       */
        closeButton: false,
        animate: true,
        className: "my-modal",
        buttons: {
            cancel: {
                label: "Cancel",
                className: "btn btn-tertiary",
                callback: function() { }
            },
            continue: {
                    label: "Continue",
                    className: "btn btn-primary",
                    callback: function()
                    {
                        if(typeof callbackFunctionOnContinue === "function")
                        {
                            callbackFunctionOnContinue(callBackParameters);
                        }
                    }
            }
           }
          });


    },

    openCancelConfirmationModal : function(cancelConfirmationMessage , cancelWarningTitle , callBackParameters , callbackFunctionOnCancel )
    {
        bootbox.dialog({
        message:cancelConfirmationMessage ,
        title: cancelWarningTitle,
        onEscape: function() {},
        backdrop: true,

        /**
       * @optional Boolean
       * @default: true
       * show a close button
       */
        closeButton: false,
        animate: true,
        className: "my-modal",
        buttons: {
            cancel: {
                label: "No",
                className: "btn btn-tertiary",
                callback: function() { }
            },
            continue: {
                    label: "Yes",
                    className: "btn btn-primary",
                    callback: function()
                    {
                        if(typeof callbackFunctionOnCancel === "function")
                        {
                            callbackFunctionOnCancel(callBackParameters);
                        }
                    }
            }
           }
          });


    },

    errorMessageModal : function(errorMessage , errorTitle)
    {
        bootbox.dialog({
            message:errorMessage ,
            title: errorTitle,
            onEscape: function() {},
            backdrop: true,

            /**
           * @optional Boolean
           * @default: true
           * show a close button
           */
            closeButton: false,
            animate: true,
            className: "my-modal",
            buttons: {
                cancel: {
                        label: "OK",
                        className: "btn btn-primary",
                        callback: function() {}
                }
            }
        });


    },

     successMessageModal : function(successMessage , successTitle, callackParameters, callbackFunctionOnOk)
    {
        bootbox.dialog({
            message:successMessage ,
            title: successTitle,
            onEscape: function() {},
            backdrop: true,

            /**
           * @optional Boolean
           * @default: true
           * show a close button
           */
            closeButton: false,
            animate: true,
            className: "my-modal",
            buttons: {
                cancel: {
                        label: "OK",
                        className: "btn btn-primary",
                        callback: function() {
                            if(typeof callbackFunctionOnOk === "function"){
                                callbackFunctionOnOk(callackParameters);
                            }
                        }
                }
            }
        });


    },

    openModalWithOptions : function(modalContent,modalTitle){
        bootbox.dialog({
            onEscape: true,
            backdrop: undefined,
            closeButton: false,
            animate: true,
            message : modalContent ,
            title : modalTitle,
            className: "my-modal"
        });
    },

    openModalWithOptions2 : function(modalContent,modalTitle){
        bootbox.dialog({
            onEscape: function() {},
            backdrop: true,
            closeButton: false,
            animate: true,
            message : modalContent ,
            title : modalTitle,
            className: "my-modal"
        });
    }
}



;OH_GLOBALINFO = {
    getProfileId :function()
    {
        if(typeof licGlobalObj !== "undefined")
        {
            return licGlobalObj.contactId ;
        }else{
            return null ;
        }
    },

    getLicenseId : function()
    {
        if(typeof licGlobalObj !== "undefined")
        {
            return licGlobalObj.licenseId ;
        }else{
        return null ;
       }
    }
}

;OH_ID_UTILITY = {
    escVFId : function(myid)
    {
     return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
    }
}


jQuery.fn.extend({
      bindAnimatedForm: function() {
        this.find(".animated-input-group").each(function(index,val)
        {
            if($(val).find('input:text').hasClass('inAnimate')){
                 $(val).find(".InputLabel").removeClass('InputLabel_Out').addClass('InputLabel_In');
                return
            }
            // BIND RESPECTIVE EVENTS TO EACH ELEMNENTS
            if($(val).find("input:text").length == 1 || $(val).find("input:password").length == 1 || $(val).find("textarea").length == 1)
            {
                var inputElement = null;
                if($(val).find("input:text").length == 1){
                  inputElement = $(val).find("input:text");
                } else if($(val).find("input:password").length == 1){
                  inputElement = $(val).find("input:password");
                } else if ($(val).find("textarea")){
                  inputElement = $(val).find("textarea");
                } else {
                  inputElement = null;
                }

                // var inputElement = $(val).find("input:text").length == 1 ? $(val).find("input:text") : $(val).find("textarea") ;

                if(inputElement.val() == '')
                {
                    $(val).find(".InputLabel").removeClass("InputLabel_In").addClass("InputLabel_Out") ;
                }else
                {
                    $(val).find(".InputLabel").removeClass("InputLabel_Out").addClass("InputLabel_In") ;
                }

                inputElement.on('focus',function()
                {
                    $(val).find(".shade").addClass("activeSpan");
                    $(val).find(".InputLabel").removeClass("InputLabel_Out").addClass("InputLabel_In") ;
                });

                // Below function is required , DO NOT REMOVE - BW

                 inputElement.on('blur',function()
                 {
                     $(val).find(".shade").removeClass("activeSpan");

                     if($(this).val().trim().length == 0 )
                     {
                         $(val).find(".InputLabel").removeClass('InputLabel_In').addClass('InputLabel_Out');
                     }else
                     {
                         $(val).find(".InputLabel").removeClass('InputLabel_Out').addClass('InputLabel_In');
                     }
                 });

                 // To validate Numeric inputs
                 if($(val).hasClass("NumberOnly"))
                 {
                    inputElement.on("keyup",function(e)
                    {
                        if($.isNumeric($(this).val()) == false )
                        {
                            $(this).val('') ;
                        }
                    });
                 }

            }else if($(val).find("select").length == 1)
            {
                $(val).find(".InputLabel").removeClass("InputLabel_Out").addClass("InputLabel_In") ;
            }
            ///***********  BINDING ENDS *********
        });
      },
      unBindAnimatedForm: function()
        {
            // ADD SOME CODE TO REMOVE ALL BINDINGS
        }
    });

    ;OCLQS_SERVERPROCESSING =
    {

        processServerOperationResult : function(serverResultId)
        {
            var pageResult = JSON.parse($("#" + serverResultId + "").val());
            console.debug(pageResult);
            if(pageResult.isSuccess == false )
            {
                var showPopUp = false ;
                var messageBody = '' ;
                if(pageResult.messages.length > 0 )
                {
                    showPopUp = true ;
                    messageBody = pageResult.messages.join('<br/>') ;
                }

                if(pageResult.debugMessages.length > 0 )
                {
                    showPopUp = true ;
                    messageBody = messageBody + '<br/><b>Debug Info</b> <br/>' +  pageResult.debugMessages.join('<br/>') ;
                }

                if(showPopUp)
                {
                    var title = '<b style="color:red;">'+  pageResult.operationName + '</b>' ;
                    OH_MODAL_UTILITY.errorMessageModal(messageBody ,title);
                }
            }
        }

    }
