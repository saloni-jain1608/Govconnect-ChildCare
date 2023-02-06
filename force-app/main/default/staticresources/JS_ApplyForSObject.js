// Santosh Tripathi			05/14/2020			TFS#16760, 16762, 16740, 16741, 16742, 16743, 16744, 16745, 16746 - Portal Enhancements

 // TODO: remove
 OH_NOTIFICATIONS.spinnerStart();

 // Global variables
 var licGlobalObj = '';
 var currentSec = 1;
 var progressBarWidget;
 var validationMapper = {};
 var attachmentsList = '';
 var validationObj = '';
 var isFirstInsert = true;
 var isFirstRerender = true;
 var submitting = false;
 
 // OCLQS
 var programId = '';
 var transactionId = '';
 var starRating = '';
 var saveflag=0; //TFS#15120
 var formChanged = false;
 var confirmerSortie = false;
 // On document ready
   $(function() {
 
     window.addEventListener("beforeunload", function(e) {
       if((window.location.href.indexOf('pgfapplyforsobject') > -1) && !submitting) {
         var confirmationMessage = 'It looks like you have been editing something. '
                                 + 'If you leave before saving, your changes will be lost2.';
 
         (e || window.event).returnValue = confirmationMessage; //Gecko + IE
         return confirmationMessage;
       }
     });



     
     $(document).on('change', 'select', function() {
         confirmerSortie = true;
     });
     
     $(document).on('change keypress', 'input', function() {
         confirmerSortie = true;
     });
     
     $(document).on('change keypress', 'textarea', function() {
         confirmerSortie = true;
     });
 
     // Disable read-only fields
     $(".read-only .form-control").attr("disabled", "disabled");
 
     // Bind animated form
     $(".dynComp").bindAnimatedForm();
 
     // Initialize progressbar
     progressBarWidget = $("#progressBarWidget").progressbar({
         navigate: function(event, data) {
           try {
               //TFS#15120 starts
                if(saveflag==1) 
                {
                 var ExitWarning = 'It looks like you have been editing something. Please save or cancel the changes before Navigating away.';
                 alert(ExitWarning);
                     return ;
                  }
               saveflag=0;
              //TFS#15120 ends
             if((progressBarWidget.progressbar("getReviewSection") != data.nextSection) || (!isFirstInsert)) {
 
               if(validationMapper.applicationFields.validator.errors().length <= 0) {
                 OH_NOTIFICATIONS.spinnerStart();
                 saveAndContinue(data.currentSection, data.nextSection);
               }
               else {
                 OH_MODAL_UTILITY.errorMessageModal(validationMapper.applicationFields.validator.errorHtml());
               }
             }
             isFirstInsert = false;
           }catch(e) {OH_MODAL_UTILITY.errorMessageModal(e);}
         }
     });
 
     // Show first section
     $("#section1").show();
 
     // Hide suggested date
     $(".dateFormat").hide();
     
     //Call function to perform UI adjustments
     APPLYFORSOBJECT.performUIAdjustments();
     // Load events
     APPLYFORSOBJECT.loadEvents();
 
     // Build validation object
     APPLYFORSOBJECT.buildValidationObject();
 
     attachmentsList = $("#jsonAtt").text();
     try {
       attachmentsList = JSON.parse(attachmentsList);
       ATTACHMENTCOMPNS.loadRecords();
     }
     catch(e) {}
     console.log('--->Attachments: ');
     console.log(attachmentsList);
 
     //QUESTIONSCOMPNS.getDepedentFields();
     questionsList = $("#jsonQue").text();
     try {
       questionsList = JSON.parse(questionsList);
       QUESTIONSCOMPNS.loadRecords();
     }
     catch(e) { console.log(e); }
 
     transactionId = $("#TransactionIdString").text();
     programId = $("#ProgramIdString").text();
   });
 
 
 ;APPLYFORSOBJECT = {
 
   initialize: function() {
           try {
             licGlobalObj = JSON.parse($("#licGlobalString").text());
            }
           catch(e) {
             OH_MODAL_UTILITY.errorMessageModal('Invalid data in licGlobalObj. Please check.');
           }
 
           try {
             validationObj = JSON.parse($("#validationString").text());
           }
           catch(e) {
             OH_MODAL_UTILITY.errorMessageModal('Invalid data in validationObj. Please check.');
           }
           console.log('--->Validation object: ');
           console.log(validationObj);
 
           // Stop spinner
           OH_NOTIFICATIONS.spinnerStop();
         },
 
   getEstStarRating: function() {
     return starRating;
   },
 
   loadSUTQReviewComponent :function()
   {
     //Means SUTQ review component is available on page /framework
     if($("#isSUTQRatingComponentAvailableOnPage").length == 1 )
     {
       OCLQS_SUTQREVIEW_COMP.initializeSUTQReviewComp() ;
     }
   },
 
 
 
   loadEvents: function() {
     // Continue button
     $("#saveAndContinue").on("click", function() {
        //TFS#15120 starts
         if(saveflag==1) 
        {
         var ExitWarning = 'It looks like you have been editing something. Please save or cancel the changes before Navigating away.';
         alert(ExitWarning);
             return ;
        }
         saveflag=0;
         ////TFS#15120 ends
         if(validationMapper.applicationFields.validator.errors().length <= 0) {
 
           // console.log(progressBarWidget.progressbar("getNextSection"));
           // console.log(progressBarWidget.progressbar("getReviewSection"));
           // if(progressBarWidget.progressbar("getNextSection") == progressBarWidget.progressbar("getReviewSection")) {
           //   console.log("--->Handle just continue");
           //   PBAR.handleJustContinue();
           // }
           OH_NOTIFICATIONS.spinnerStart();
           var currentSection = 0;
           currentSection = progressBarWidget.progressbar("getActiveSection");
           var nextSection1 = progressBarWidget.progressbar("getNextSection");
           saveAndContinue(currentSection, nextSection1);
           isFirstInsert = false;
         }
         else {
           OH_MODAL_UTILITY.errorMessageModal(validationMapper.applicationFields.validator.errorHtml());
         }
     });
     
     $("#singleSubmitOnly").on("click",function(e)
     {
          saveflag=0; //TFS#15120
          //TFS#14797 starts
          APPLYFORSOBJECT.buildValidationObject(); 
          if(document.title=='License Closure' || document.title=='Day Camp Approval Closure' || document.title=='Out of State Registration Closure' || document.title=='Day Camp Registration Closure' || document.title=='Licensing Closure')
          {
            var PickList = $("label:contains('Closure Reason')").next();
            var Reason = $("label:contains('Other Closure Reason')").next();
             
            if($j(PickList).find('option:selected').text()=='Other' && $j(Reason).val()=='') 
            {
              // alert('Please enter other closure reason');
                OH_MODAL_UTILITY.errorMessageModal('Please enter other closure reason');
               return;
            }
          }
         else{ //TFS#16800
             
             if(document.title=='Notice of Reopening')
          {             
              
              var planreopen = $("label:contains('plan to reopen')").attr('for');                
              var dateoperation = $("label:contains('date do you intend to begi')").attr('for');
              if($j('[id="' + planreopen + '"]').val() == 'Yes' && $j('[id="' + dateoperation + '"]').val() == '')
              {
                  OH_MODAL_UTILITY.errorMessageModal('Please enter the date');
                 return;
              }
              var start= new Date($j('[id="' + dateoperation + '"]').val());
         var end= new Date('2020-05-31');
            
              if(start < end)
              {
                  OH_MODAL_UTILITY.errorMessageModal('Date can not be earlier than May-31-2020');
                 return;
              }
              
              
          }
         }
         
         //TFS#14797 Ends
          
       if(validationMapper.applicationFields.validator.errors().length <= 0) 
       {
         submitting = true;
         OH_APPLYFORLICENSE.processSingleSectionSubmit();
       }
         else {
           OH_MODAL_UTILITY.errorMessageModal(validationMapper.applicationFields.validator.errorHtml()); 
       }
     });
 
     // 13782- Save and later button
     $(".saveAndLater").on("click", function() {
         //TFS#15120 starts
        if(saveflag==1) 
        {
         var ExitWarning = 'It looks like you have been editing something. Please save or cancel the changes before Navigating away.';
         alert(ExitWarning);
             return ;
        }
          saveflag=0;
         //TFS#15120 ends
       submitting = true;
       OH_NOTIFICATIONS.spinnerStart();
       OH_APPLYFORLICENSE.saveAndLater();
     });
     
     // 13782 - Save button
     $(".saveButton").on("click", function() {
      

      //$j('#myModal').dialog('open');
      
       
      if( document.title == 'Update Facility Information'){        
        if(confirmerSortie) {
          $j("#ConfirmModalDialog").dialog({        
            resizable: true,    
            autoOpen: false,    
            height:200,    
            width: 500,    
            modal: true,    
            buttons: {    
                "Confirm": function() {
                  $j( this ).dialog( "close" );
                    // Call here your actionFunction
                  saveflag=0; //TFS#15120
                  submitting = true;
                  OH_NOTIFICATIONS.spinnerStart();
                  OH_APPLYFORLICENSE.quickSave();
                  confirmerSortie = false;
                },    
                Cancel: function() {    
                    $j( this ).dialog( "close" );    
                }   
            }    
        });
        $j('#ConfirmModalDialog').dialog('open');
        $j('.ui-dialog-titlebar').css('background','#3d7aa9');
        $j('.ui-dialog-titlebar').css('border','2px solid #3d7aa9');
        $j('.ui-button').css('background','#3d7aa9');
        $j('.ui-button').css('border','2px solid #3d7aa9'); 
        $j('.ui-button').css('color','#fff');   
        } else {
          saveflag=0; //TFS#15120
          submitting = true;
          OH_NOTIFICATIONS.spinnerStart();
          OH_APPLYFORLICENSE.quickSave();
        }
      }       
    });
 
   },
 
   buildValidationObject: function() {
     validationMapper.applicationFields = {};
     validationMapper.applicationFields.validationObject = {};
     validationMapper.applicationFields.validationObject.fields = [];
     $.each(validationObj, function(i, val1) {
       if(progressBarWidget.progressbar("getActiveSection") == val1.orderNumber) {
         $.each(val1.subSectionObjMap, function(j, val2) {
             $.each(val2.fieldObjMap, function(k, val3) {
               validationMapper.applicationFields.validationObject.fields.push({
                 element : val3.sType == 'Text' ? $("#vald" + val3.id + " input") : $("#vald" + val3.id + " select"),
                 required : false,
                 name : val3.label,
                 validator : val3.validator,
                 watch : true
               });
             });
         });
       }        
       //TFS#14797 starts
       else if(val1.name == 'Approval Closure' || val1.name=='Registration Closure' || val1.name == 'License Closure') //TFS#16800
       {
 
         $.each(val1.subSectionObjMap, function(j, val2) {
             $.each(val2.fieldObjMap, function(k, val3) {
             var varValidator = null;
             var varelement =  val3.sType == 'Date' ? $("#vald" + val3.id + " input") : $("#vald" + val3.id + " select");
           if(val3.sType == 'Date' || val3.sType == 'Picklist' || val3.sType == 'Multi-Select'){
                         
                  varValidator = function (validator) 
                             {
                               var dateVal = varelement.val();
                               if (typeof(dateVal)!='undefined' && dateVal.length > 0)
                               {
                                   validator.isValid = true;
                                   validator.error = null;
                                   varelement.parent().parent().removeClass("errorElement");
                               } else if(typeof(dateVal)!='undefined') 
                               {
                                               validator.isValid = false;
                                  varelement.parent().parent().addClass("errorElement");
                               }
                             }
              
                 } 
             
               validationMapper.applicationFields.validationObject.fields.push({
                 element : varelement,
                 required : val3.required,
                 name : val3.label,
                 watch : true,
                 customValidator:varValidator ,
                   event:'input mouseenter'
               });
             });
         });
       }     
       //TFS#16800
       else if(val1.name == 'Notice of Reopening') 
       {
 
         $.each(val1.subSectionObjMap, function(j, val2) {
             $.each(val2.fieldObjMap, function(k, val3) {
             var varValidator = null;
             var varelement =  val3.sType == 'Date' ? $("#vald" + val3.id + " input") : $("#vald" + val3.id + " select");
           if(val3.sType == 'Picklist' || val3.sType == 'Multi-Select'){
                         
                  varValidator = function (validator) 
                             {
                               var dateVal = varelement.val();
                               if (typeof(dateVal)!='undefined' && dateVal.length > 0)
                               {
                                   validator.isValid = true;
                                   validator.error = null;
                                   varelement.parent().parent().removeClass("errorElement");
                               } else if(typeof(dateVal)!='undefined') 
                               {
                                               validator.isValid = false;
                                  varelement.parent().parent().addClass("errorElement");
                               }
                             }
              
                 } 
             
               validationMapper.applicationFields.validationObject.fields.push({
                 element : varelement,
                 required : val3.required,
                 name : val3.label,
                 watch : true,
                 customValidator:varValidator ,
                   event:'input mouseenter'
               });
             });
         });
       } 
       // Updated to validate the fields for pages without progress bar like the update contact informartion page - 11246
       else
       {
         console.log('Prad**Inside else');
         $.each(val1.subSectionObjMap, function(j, val2) {
             $.each(val2.fieldObjMap, function(k, val3) {
               validationMapper.applicationFields.validationObject.fields.push({
                 element : val3.sType == 'Text' ? $("#vald" + val3.id + " input") : $("#vald" + val3.id + " select"),
                 required : false,
                 name : val3.label,
                 validator : val3.validator,
                 watch : true
               });
             });
         });
       }
     });
     validationMapper.applicationFields.validator = new ValidationEngine(validationMapper.applicationFields.validationObject);
   },
   performUIAdjustments : function()
   {
     $.each($(".pgf-read-only") , function(index,val)
     {
       if($(val).find(".lookupInput").length == 1 ) 
       {
         $(val).find(".lookupInput").find("a").remove();
       }
     }) ;
     
     $.each($(".blank-space"),function(index,val)
    {
       try
       {
         var currentClasses = $(val).attr("class").trim() ;
         var spaceCount = currentClasses.substr(currentClasses.length - 1) ;
         var spacingClassName = "form-group col-sm-" + spaceCount  ;
         var newHeight = $(val).height() ; 
         if(newHeight == 0 ) // Means there is our fev table component
         {
           if($(val).find("input:text").length == 1 ) // means normal text field 
           {
             newHeight = 65 ;
           }else if($(val).find(".multiSelectPicklistTable").length == 1 ) // means multiselect picklist
           {
             newHeight = 235 ;
           }else if($(val).find("select").length == 1) // Normal picklist field
           {
             newHeight = 65 ;
           } //TFS#16760, 16762, 16740, 16741, 16742, 16743, 16744, 16745, 16746 - Portal Enhancements - Start
                   else if($(val).find("input:checkbox").length == 1) // Normal checkbox field
           {
             newHeight = 65 ;
                   }  //TFS#16760, 16762, 16740, 16741, 16742, 16743, 16744, 16745, 16746 - Portal Enhancements - End                   
                   else if ($(val).find("textarea").length == 1) // Standard TextArea field
           {
             newHeight = 187 ;
           }
           else
            {
             newHeight = 65 ; 
           }
         }
         
         var dummyDiv = $("<div>").addClass(spacingClassName).css("height",newHeight) ;
         $(val).after(dummyDiv) ;
       }catch(e)
       {
         console.log('Some thing went wrong during UI adjustments , which didnt worth for troubleshoot' + e ) ;
       }
     });
   }
 }
 ;CANCEL_PT = {
   cancelApplication :function ()
   {
          saveflag=0;
     submitting = true;
       var commentSection = 'Please confirm that you want to Cancel.' ;
       var modalButtons = {
           exit: {
               label: "Exit",
               className: "button button-alt",
               callback: function () {
                   return null;
               }
           },
           withdraw: {
               label: "Confirm to Cancel",
               className: "btn btn-primary",
               callback: function () {
                   cancelApplication();
               }
           }
       };
       oclqs_modal_utility.btnMessageModal(commentSection, 'Confirmation', modalButtons);
   }
 }
 ;CANCEL_APPLICATION = {
   cancelRevision :function ()
   {
     submitting = true;
       var commentSection = 'Please confirm that you want to Cancel your application revision' ;
       var modalButtons = {
           exit: {
               label: "Exit",
               className: "button button-alt",
               callback: function () {
                   return null;
               }
           },
           withdraw: {
               label: "Confirm to Cancel",
               className: "btn btn-primary",
               callback: function () {
                   cancelRevision();
               }
           }
       };
       oclqs_modal_utility.btnMessageModal(commentSection, 'Confirmation', modalButtons);
   }
 }
 ;ACTIONS = {
       displayCancelDialog: function(e) {
           bootbox.dialog({
             message: "Are you sure you want to cancel?",
             title: "Confirm Exit",
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
                 label: "Exit",
                 className: "btn btn-tertiary",
                 callback: function(e) {
                   e.prevenDefault();
                 }
               },
               continue: {
                 label: "Continue Editing",
                 className: "btn btn-primary",
                 callback: function(e) {
                   return e;
                 }
               }
             }
           });
       },
 
       displaySaveExitDialog: function() {
 
       var pageResult = JSON.parse($("#singleSectPageRes").val());
       if(pageResult.isSuccess == false )
       return false ;
 
           bootbox.dialog({
             message: "Are you sure you want to save and come back later?",
             title: "Confirm Exit",
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
                 label: "Exit",
                 className: "btn btn-tertiary",
                 callback: function() { window.location.href = "/OCLQS_Dashboard"; }
               },
               continue: {
                 label: "Continue Editing",
                 className: "btn btn-primary",
                 callback: function() { }
               }
             }
           });
       }
   }