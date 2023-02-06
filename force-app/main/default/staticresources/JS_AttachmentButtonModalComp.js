/*******************************************************************************
* Name          :   JS_AttachmentButtonModalComp
* Author        :   Dylan Bohlender <dbohlender@deloitte.com>
* Copyright     :   2016 Deloitte LLP
* Date          :   11/29/2016
* Group         :   JavaScript Static Resource
* Description   :   Client-side logic for PGFAttachmentButtonModalComp
*-------------------------------------------------------------------------------
UPDATES
Version         Developer               Date            Description             
--------------------------------------------------------------------------------
0.1             Dylan Bohlender         11/29/2016      Initial creation
0.2             Dylan Bohlender         11/30/2016      Arch. v1 - methods
0.3             Dylan Bohlender         12/01/2016      LoadEvents first draft
0.4             Dylan Bohlender         12/02/2016      Remote: Check MIME Type
0.5             Dylan Bohlender         12/03/2016      Add Attach click
0.6             Dylan Bohlender         12/04/2016      Save/Cancel click
0.7             Dylan Bohlender         12/05/2016      Remote: Cr. Std. Doc.
0.8             Dylan Bohlender         12/06/2016      Remote: Insert Att. WS
1.0             Dylan Bohlender         12/07/2016      v1 cleanup & TODOs
1.1             Dylan Bohlender         12/09/2016      DataTable hiding
1.2             Dylan Bohlender         12/09/2016      Bugfix - val() to text()
1.3             Dylan Bohlender         12/19/2016      Bugfix - cancel click
1.4             Dylan Bohlender         12/19/2016      Bugfix - button hiding
1.5             Dylan Bohlender         12/20/2016      Bugfix - IE FileReader
1.6             Dylan Bohlender         12/21/2016      File upload chunking
1.7             Dylan Bohlender         12/22/2016      Reorganization
1.8             J. Scott Cromie         01/03/2017      update maxFileSize to 10MB
--------------------------------------------------------------------------------
*******************************************************************************/

// Start things off with a defensive semicolon
;ATTACHMENTBUTTONMODALCOMP = {

    maxStringSize: 6000000,    // Maximum String size is 6,000,000 characters
    maxFileSize: 10485760,      // After Base64 Encoding, this is the max file size
    chunkSize: 950000,         // Maximum Javascript Remoting message size is 1,000,000 characters


    /***************************************************************************
    loadEvents
    FUNCTION (No Return)
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    ***************************************************************************/
    loadEvents: function(domRecordId) {
        var fileContents;
        /***********************************************************************
        [id^=addApprAtt]
        CLICK EVENT HANDLER
        Purpose: Primary Button Click (Shows Modal)
        ***********************************************************************/
        $("[id^=addApprAtt]").on("click", function(e) {
            $("#saveModal" + domRecordId).hide();
            $("#cloneModal" + domRecordId).hide();
            ATTACHMENTBUTTONMODALCOMP.cancelButtonClick(e, domRecordId);
            $("#attachmentFileName" + domRecordId).show();

            ATTACHMENTBUTTONMODALCOMP.r_getApprovedDocs(
                domRecordId, 
                function(docRecords) {                                                                        // TODO: Properly Build the DataTable DOM
                    // Success - Docs Callback (Call if 1 or more Approved Documents)

                    // Hide the DOM for the Data Table (TEMPORARY)
                    $("#theDataTable" + domRecordId).hide();
                    
                    // Build the DOM for the Data Table
                    /*
                    $('#theDataTable' + domRecordId).DataTable({
                        destroy: true,
                        dom: 'Bfrtip',
                        buttons: [{
                            text: 'Add new button',
                            action: function(e, dt, node, config) {
                                dt.button().add(1, {
                                    text: 'Button ' + (counter++)
                                })
                            }
                        }]
                    });
                    */
                },
                function() {
                    // Success - No Docs Callback (Call if 0 Approved Documents)
                    
                    // Hide the DOM for the Data Table
                    $("#theDataTable" + domRecordId).hide();
                },
                function(errorMessage) {
                    // Error Callback (Call if error in VF Call)
                    OH_MODAL_UTILITY.errorMessageModal(errorMessage);
                }
            );
        });

        /***********************************************************************
        [id^=addAttachmentBtn]
        CLICK EVENT HANDLER
        Purpose: "Add Attachment" Button Click
        ***********************************************************************/
        $("[id^=addAttachmentBtn]").on("change", function(e) {
            $("#saveModal" + domRecordId).hide();
            $("#cloneModal" + domRecordId).hide();
            console.log('addAttach called');
            ATTACHMENTBUTTONMODALCOMP.addAttachmentClick(
                e,
                domRecordId,
                function(fileName) {
                    // Success - Attachment Added
                    $("#saveModal" + domRecordId).show();
                    var fileNameControl = $("#attachmentFileName" + domRecordId);
                    var fileTypeButtonControl = $("#addApprAtt" + domRecordId);
                    var replaceButtonControl = $("#replaceAttachBtn" + domRecordId);
                    var addButtonControl = $("#addAttachmentBtn" + domRecordId);

                    //Set the control and localStorage values
                    fileTypeButtonControl.label = fileTypeButtonControl.label + ": (selected)";
                    fileNameControl.show().text(fileName);
                },
                function(message) {
                    // Failure - Attachment Not Added
                    $("#saveModal" + domRecordId).hide();
                    OH_MODAL_UTILITY.errorMessageModal(message);
                }
            );
        });

        /***********************************************************************
        [id^=replaceAttBtn]
        CLICK EVENT HANDLER
        Purpose: "Replace Attachment" Button Click
        ***********************************************************************/
        $("[id^=replaceAttBtn]").on("change", function(e) {
            $("#saveModal" + domRecordId).hide();
            $("#cloneModal" + domRecordId).hide();
            console.log('ReplaceAttach called');
            ATTACHMENTBUTTONMODALCOMP.addAttachmentClick(
                e,
                domRecordId,
                function(fileName) {
                    // Success - Attachment Added
                    $("#saveModal" + domRecordId).show();
                    var fileNameControl = $("#attachmentFileName" + domRecordId);
                    var fileTypeButtonControl = $("#addApprAtt" + domRecordId);
                    var replaceButtonControl = $("#replaceAttachBtn" + domRecordId);
                    var addButtonControl = $("#addAttachmentBtn" + domRecordId);

                    //Set the control and localStorage values
                    fileTypeButtonControl.label = fileTypeButtonControl.label + ": (selected)";
                    fileNameControl.show().text(fileName);
                },
                function(message) {
                    // Failure - Attachment Not Added
                    $("#saveModal" + domRecordId).hide();
                    OH_MODAL_UTILITY.errorMessageModal(message);
                }
                );
        });

        /***********************************************************************
        [id^=saveModal]
        CLICK EVENT HANDLER
        Purpose: "Save" Button Click
        ***********************************************************************/
        $("[id^=saveModal]").on("click", function(e) {
            ATTACHMENTBUTTONMODALCOMP.saveButtonClick(
                e,
                domRecordId,
                function(result, fileName) {
                    // Success - Attachment & Related Records Saved to SFDC

                    // Update UI
                    $("#attDiv" + domRecordId).find(".dataTableHolder").find(".AttachmentValidationContainer").find("#AttachmentName").val(fileName);
                    $("#attDiv" + domRecordId).find(".dataTableHolder").find(".AttachmentValidationContainer").find("#AttachmentCompleted").val('YES');
                    $("#hiddenAttId" + domRecordId).val(result.attachmentId);
                    $("#attachmentFileName" + domRecordId).show().find('.name').text(fileName);
                    $("#loadedFileName" + domRecordId).text(fileName);
                    $("#addAttachBtn" + domRecordId).hide();
                    $("#replaceAttachBtn" + domRecordId).show();

                    // Add the "(added)" text and checkmark
                    var buttonText = $("#addApprAtt" + domRecordId).text();
                    if(buttonText.substring(buttonText.length - 8) !== ' (added)') {
                        $("#addApprAtt" + domRecordId).text(buttonText + ' (added)');
                        $("#addApprAtt" + domRecordId).addClass('attachment-uploaded');
                    }

                    $("#attachmentFileName" + domRecordId).show().find('.name').text($("#attachmentFileName" + domRecordId).find('.name') + ': (' + fileName + ' selected.)');
                    $("#addApprAtt" + domRecordId).show();

                    OH_MODAL_UTILITY.successMessageModal(result.message, 'Success', null, null);
                },
                function(message) {
                    // Failure - Attachment & Related Records NOT Saved to SFDC
                    $("#attachmentFileName" + domRecordId).hide().find('.name').val("");
                    $("#addApprAtt" + domRecordId).show();

                    OH_MODAL_UTILITY.errorMessageModal(message);
                });
        });

        /***********************************************************************
        [id^=cloneModal]
        CLICK EVENT HANDLER
        Purpose: "Clone" Button Click
        ***********************************************************************/
        $("[id^=cloneModal]").on("click", function(e) {
            //You have the Standard Document Id to clone from the stdDocId control
            var controlId = $(this).attr("id");
            var btnSaveRecord = $("#saveModal" + domRecordId);
            var btnCloneRecord = $("#cloneModal" + domRecordId);
            var stdDocDetId = null; //idObj.stdDetailId;
            var stdDocId = $("#stdDocId" + domRecordId).text();
            //method call here!                                                                                // TODO: Build clone method for selected Approved Document
        });

        /***********************************************************************
        [id^=cancelModal]
        CLICK EVENT HANDLER
        Purpose: "Cancel" Button Click
        ***********************************************************************/
        $("[id^=cancelModal]").on("click", function(e) {
            $("#addAttachmentComment" + domRecordId).val('');
            $("#attachmentFileName" + domRecordId).val('');
            //$("#attachmentFileName" + domRecordId).val('').hide();
            $("#addApprAtt" + domRecordId).show();
            ATTACHMENTBUTTONMODALCOMP.cancelButtonClick(e, domRecordId);
        });


        /***********************************************************************
        [id^=documentListModal]
        SHOW MODAL EVENT HANDLER
        Purpose: Handles logic fired on showing the modal (legacy code)
                 Currently commented out because Approved Document functionality
                 hasn't yet been built out.
        ***********************************************************************/
        /*$("[id^=documentListModal]").on('show.bs.modal', function (event) {
            console.log('calling show bs modal');
            var btn = $(event.relatedTarget) // Button that triggered the modal
            var btnId = btn.attr("id");
            var idObj = domRecordId;
            var stdDocDetId = idObj.stdDetailId;
            //adjust column headers on the datatable.
            var dataTable = $(this).closest('table').attr('id');
            $("#" + dataTable).DataTable().columns.adjust().draw();
            var modal = $(this);
            //Turn the row click event on when the modal is entered.
            $('.dataTableHolder tbody').on('click.DT', 'tr', function(e) {
                var datatableId = $(this).closest('table').attr('id');
                var dataRow = $("#" + datatableId).DataTable().row(this._DT_RowIndex).data();
                var stdParentId = dataRow.Id;
                var stdParentName = dataRow.Name;
                datatableId = datatableId.substring(datatableId.length - 18);
                $("#attachmentFileName" + datatableId).text(stdParentName);
                $("#attachmentFileName" + datatableId).show();
                $("#saveModal" + datatableId).hide();
                $("#cloneModal" + datatableId).show();
                $("#stdDocId" + datatableId).text(stdParentId);
                console.log('Got the Standard Document Id: ' + $("#attachmentFileName" + datatableId).text() + '!');
            });
            modal.find("[attachmentFileName"+stdDocDetId+"]").val('');
        });*/
    },


    /***************************************************************************
    r_getApprovedDocs
    FUNCTION (No Return)
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    docsCallback: callback function if there are Approved Documents fetched
    nodocsCallback: callback function if no Approved Documents are fetched
    errorCallback: callback function if there is an error in the remote call
    ***************************************************************************/
    r_getApprovedDocs: function(domRecordId, docsCallback, nodocsCallback, errorCallback) {
        // Toggle on the Spinner while we perform server async
        OH_NOTIFICATIONS.spinnerStart();

        // Make VF Remoting Call
        Visualforce.remoting.Manager.invokeAction(
            'PGFAttachmentUtilityCtlr.getApprovedDocs',
            domRecordId,
            function (result, event) {
                // Toggle off the Spinner since our server async is done and we'll do no more
                OH_NOTIFICATIONS.spinnerStop();

                if (event.status) { // VF Remoting Success
                    if (result && result.records && (result.records.length > 0)) { // If 1+ documents returned, call docsCallback
                        docsCallback(result.records);
                    }
                    else {                                                         // Else call nodocsCallback
                        nodocsCallback();
                    }
                }
                else {              // VF Remoting Failure/Error/Other
                    errorCallback(event.message);
                }
            },
            { escape: true, timeout: 120000}
        );
    },


    /***************************************************************************
    r_checkMIMEType
    FUNCTION (No Return)
    fileExtension: Extension of file as parsed by FileReader
    successCallback: callback function to return Salesforce result
    errorCallback: callback function if there is an error in the remote call
    ***************************************************************************/
    r_checkMIMEType: function(fileExtension, successCallback, errorCallback) {
        // Toggle on the Spinner while we perform server async
        OH_NOTIFICATIONS.spinnerStart();

        // Make VF Remoting Call
        Visualforce.remoting.Manager.invokeAction(
            'PGFAttachmentUtilityCtlr.checkMIMEType',
            fileExtension,
            function (result, event) {
                // Toggle off the Spinner since our server async is done and we'll do no more
                OH_NOTIFICATIONS.spinnerStop();

                if (event.status) { // VF Remoting Success
                    if(result.length > 0) { // If MIME type returned, call successCallback
                        successCallback(result);
                    }
                    else {                  // Else call errorCallback
                        errorCallback('This file type is not supported.</br>Valid file types are:  doc, docx, htm, html, jpeg, jpg, pdf, png, rtf, text, tif, tiff, txt, xls, xlsx</br>Please try again with a valid file type.');
                    }
                }
                else {              // VF Remoting Failure/Error/Other
                    errorCallback(event.message);
                }
            },
            {escape: true, timeout: 120000}
        );
    },


    /***************************************************************************
    r_uploadChunkedDocument
    FUNCTION (No Return)
    fileId: Salesforce Id of Document record
    fileName: Name of file
    fileContents: Base64 serialized attachment data chunk
    successCallback: Callback function to return Salesforce result
    errorCallback: Callback function if there is an error in the remote call
    ***************************************************************************/
    r_uploadChunkedDocument: function(fileId, fileName, fileContents, successCallback, errorCallback) {
        // Toggle on the Spinner while we perform server async
        OH_NOTIFICATIONS.spinnerStart();

        // Make VF Remoting Call
        Visualforce.remoting.Manager.invokeAction(
            'PGFAttachmentUtilityCtlr.uploadChunkedDocument',
            fileId,
            fileName,
            fileContents,
            function (result, event) {
                // Toggle off the Spinner since our server async is done and we'll do no more
                OH_NOTIFICATIONS.spinnerStop();

                if (event.status) { // VF Remoting Success
                    successCallback(result);
                }
                else {              // VF Remoting Failure/Error/Other
                    errorCallback(event.message);
                }
            },
            {buffer: true, escape: true, timeout: 120000}
        );
    },


    /***************************************************************************
    r_createStandardDocumentRecord
    FUNCTION (No Return)
    attId: attachment Record Id
    filename: name of attached file
    filedesc: description of attached file (comments box)
    fileContents: base64 serialized attachment data
    MIMEType: MIME type of attached file
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    successCallback: callback function to return Salesforce result
    errorCallback: callback function if there is an error in the remote call
    ***************************************************************************/
    r_createStandardDocumentRecord: function(attId, filename, filedesc, MIMEType, docUploadResult, domRecordId, successCallback, errorCallback) {
        // Toggle on the Spinner while we perform server async
        OH_NOTIFICATIONS.spinnerStart();

        // Make VF Remoting Call
//        console.log('Calling SFDC - PGFAttachmentUtilityCtlr.createStandardDocumentRecord(\'' + attId + '\',\'' + filename + '\',\'' + filedesc + '\',\'' + MIMEType + '\',\'' + domRecordId + '\');');
        Visualforce.remoting.Manager.invokeAction(
            'PGFAttachmentUtilityCtlr.createStandardDocumentRecord',
            attId,
            filename,
            filedesc,
            MIMEType,
            domRecordId,
            function (result, event) {
                // Toggle off the Spinner since our server async is done and we'll do no more
                OH_NOTIFICATIONS.spinnerStop();

                if (event.status) { // VF Remoting Success
                    if(result) { // If Document Result Message returned, call successCallback
                        successCallback(result);
                    }
                    else {                  // Else call errorCallback
                        errorCallback('The webservice did not return. Please try again.');
                    }
                }
                else {              // VF Remoting Failure/Error/Other
                    errorCallback(event.message);
                }
            },
            {escape: true, timeout: 120000}
        );
    },


    /***************************************************************************
    r_insertAttachmentWSwithUID
    FUNCTION (No Return)
    standardDocumentId: Salesforce Id of the Standard Document record
    attachmentId: Salesforce Id of the Attachment record
    successCallback: callback function to indicate success
    errorCallback: callback function if there is an error in the remote call
    ***************************************************************************/
    r_insertAttachmentWSwithUID: function(standardDocumentId, attachmentId,UID, transactionDocId, executionType, successCallback, failureCallback) {
        // Toggle on the Spinner while we perform server async
        OH_NOTIFICATIONS.spinnerStart();

        Visualforce.remoting.Manager.invokeAction(
            'OCLQS_IntegrationUtility.insertAttachmentWSwithUID',
            standardDocumentId,
            attachmentId,
            UID,
            transactionDocId,
            executionType,
            function(result, event) {
                // Toggle off the Spinner since our server async is done and we'll do no more
                ATTACHMENTBUTTONMODALCOMP.logMessages('\n\nOnBase integration response:\n' +JSON.stringify(result) + '\n\n');  
                OH_NOTIFICATIONS.spinnerStop();

                // Try/Catch in case the JSON parse fails
                var resultObj;
                try {
                    // Parse the JSON returned by the OCLQS_IntegrationUtility class
                    resultObj = JSON.parse(result);
                }
                catch (e) {
                    console.log(e);
                    ATTACHMENTBUTTONMODALCOMP.logMessages('\n\nCaught an error parsing the JSON from the OnBase webservice.:\n');
                    failureCallback('Upload Error - try to re-upload the document, if problem persists, please contact the System Administrator');
                }

                // Run the appropriate callack
                if(resultObj) {
                    if(resultObj.success) {
                        successCallback();
                    }
                    else {
                        ATTACHMENTBUTTONMODALCOMP.logMessages(resultObj.errorMessage);
                        failureCallback(resultObj.errorMessage);
                    }
                }
                else {
                    ATTACHMENTBUTTONMODALCOMP.logMessages('The remote document repository did not update with your uploaded Attachment. Please try again.');
                    failureCallback('The remote document repository did not update with your uploaded Attachment. Please try again.');
                }
            },
            {escape: false, timeout: 120000}
        );
    },

    /***************************************************************************
    uploadDocument
    FUNCTION (No Return)
    fileName: Name of file
    fileContents: Base64 serialized attachment data chunk
    successCallback: Callback function on success
    errorCallback: Callback function on failure
    ***************************************************************************/
    uploadAttachment: function(fileName, fileContents, successCallback, errorCallback) {
        OH_NOTIFICATIONS.spinnerStart();
      //create Attachment object with required fields
      var att = new sforce.SObject("Attachment");
      att.Name = fileName;

      var tempSD = new sforce.SObject("CLQ_Standard_Document__c");
      tempSD.Name = 'temp_**_' + fileName;
      tempSD.CLQ_Integration_File_Name__c = 'temp_**_' + fileName;
      tempSD.CLQ_Document_Affiliation__c = 'Program';
      att.body = fileContents;
      ATTACHMENTBUTTONMODALCOMP.logMessages('Ready to create SFDC attachment now with content size ' + att.body.length + ' Bytes');
      var theTempSD = sforce.connection.create([tempSD]);
      
      if (theTempSD[0].success === 'false') {
        errorMessage = theTempSD[0].errors.message;
        console.log(errorMessage);
        errorCallback(errorMessage);
      } else {
 //       console.log('Created Temp SD Id: ' + theTempSD[0].id);
        att.ParentId = theTempSD[0].id;
        sforce.connection.create([att], {
          onSuccess : function(result){
          OH_NOTIFICATIONS.spinnerStop();
 //           console.log('Created attachment Id: ' + JSON.stringify(result));
            successCallback(result);
          },
            
          onFailure : function(errorMessage){
            console.log('Error when creating the attachment in "uploadAttachment"');
            errorCallback(errorMessage);
          }
        });
      }
    },


    /***************************************************************************
    uploadChunkedDocument
    FUNCTION (No Return)
    fileName: Name of file
    fileContents: Base64 serialized attachment data chunk
    successCallback: Callback function on success
    errorCallback: Callback function on failure
    ***************************************************************************/
    uploadChunkedDocument: function(fileName, fileContents, successCallback, errorCallback) {
        // Set up tracker variables
        var fileSize = fileContents.length;
        var positionIndex = 0;
        var doneUploading = false;

        // Recursive function that wraps async remoted calls and calls successCallback to exit
        function uploadDocument(docId) {
            var currentChunk = "";
            if(fileSize <= positionIndex + ATTACHMENTBUTTONMODALCOMP.chunkSize) {
                currentChunk = fileContents.substring(positionIndex);
                doneUploading = true;
            }
            else {
                currentChunk = fileContents.substring(positionIndex, positionIndex + ATTACHMENTBUTTONMODALCOMP.chunkSize);
            }

 //           console.log("Uploading " + currentChunk.length + " chars of " + fileSize);
            ATTACHMENTBUTTONMODALCOMP.r_uploadChunkedDocument(
                docId,
                fileName,
                currentChunk,
                function(result) {
                    if(doneUploading === true) {
                        successCallback(result);
                    }
                    else {
                        positionIndex += ATTACHMENTBUTTONMODALCOMP.chunkSize;
                        uploadDocument(result);
                    }
                },
                function(errorMessage) {
                    errorCallback(errorMessage);
                }
            );
        }
        // Initialize recursive call
        uploadDocument(null);
    },


    /***************************************************************************
    addAttachmentClick
    FUNCTION (No Return)
    e: event passed from jQuery
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    successCallback: success callback function
    failureCallback: failure callback function
    ***************************************************************************/
    addAttachmentClick: function(e, domRecordId, successCallback, failureCallback) {
        localStorage.msgCount = '0'; //counter for logging flag check(Nishit)
        localStorage.enableLogs = 'false';//flag to check enabled logging from Integration Setting(Nishit)
        // Clear out local storage
        delete localStorage.oldStdDocId;
        delete localStorage.fileName;
        delete localStorage.conMIMEType;
        delete localStorage.currentId;
        delete localStorage.UID; //Added by sanjeev for logging purpose
        delete localStorage.oldTransDocName;
        localStorage.oldFileName = $("#attachmentFileName" + domRecordId).text().trim();
        localStorage.UID = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "getUID", {}); //Added by sanjeev for getting UID for logging
        localStorage.oldStdDocId = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "getOldStdDocId", {transactionDocId: domRecordId});
        localStorage.oldTransDocName = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "getOldTransDocName", {sObjDocId: domRecordId});
        ATTACHMENTBUTTONMODALCOMP.logMessages(ATTACHMENTBUTTONMODALCOMP.getBrowserDetials() );
        var  MAXFILESIZEINMB = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "maxFileSizeAllowed", {});
        if(MAXFILESIZEINMB == null || MAXFILESIZEINMB == "") {
            MAXFILESIZEINMB = 10;
        }
        var MAXFILESIZEINBYTES = MAXFILESIZEINMB * 1048576; //10 MB limit
        // Variables
        var theFileList = e.target.files;
        var theFile = theFileList[0];
        if (theFile.size <= 0 ){
            fileContents = null;
            OH_NOTIFICATIONS.spinnerStop();
            ATTACHMENTBUTTONMODALCOMP.logMessages('Attachment file is empty: Size is ' + theFile.size + ' Bytes');
            OH_MODAL_UTILITY.errorMessageModal('Document is empty. Please upload a valid document.','Document Empty');
            return false;
        }
        else if(theFile && theFile.size <= MAXFILESIZEINBYTES) {
            var reader = new FileReader();

            reader.onload = function(event) {
                var fileBlobControl = $("#fileBlobControl" + domRecordId);
                
                fileBlobControl.hide();  //ensure the control is hidden when the file comes in.
                
                fileContents = (String(event.target.result)).substr(String((event.target.result)).indexOf(',') + 1);
                //ATTACHMENTBUTTONMODALCOMP.logMessages('Attachment size(string) is: '+fileContents.length + ' Bytes');//log messages to the screen console and integration log INT-008.6(Nishit)
                //fileBlobControl[0].innerText = fileContents;
            };
            //reader.readAsArrayBuffer(theFile); // Read file to produce Base64 string
            reader.readAsDataURL(theFile); //reads the file content and spits the data as a URL representing the file's data as a base64 encoded string (Nishit)

            var theFileName = theFile.name;
            var theFileExtension = ATTACHMENTBUTTONMODALCOMP.getFileExt(theFileName);
            if(typeof theFileExtension === 'undefined' || theFileExtension === null || theFileExtension === '' ) {
                fileContents = null;
                OH_NOTIFICATIONS.spinnerStop();
                ATTACHMENTBUTTONMODALCOMP.logMessages('File extension missing: ' + theFileExtension + ' File Name: '+theFileName);
                failureCallback('File extension is missing. Please try again with a valid file type.');
                return false;
            }
            //Validation: File Name Length
             if (theFileName.length > 80) {
                fileContents = null;
                OH_NOTIFICATIONS.spinnerStop();
                ATTACHMENTBUTTONMODALCOMP.logMessages('Attachment name "'+theFileName+'" is greater then 80 chars.\nFileName Length: ' + theFileName.length );
                failureCallback('Maximum file name length is greater than 80 characters. Please rename the file and try again.');
                return false;
              }
            //MIME Type Validation
            ATTACHMENTBUTTONMODALCOMP.r_checkMIMEType(
                theFileExtension,
                function(result) {
                    // Success - MIME Callback (Call if MIME Type returned)
                    localStorage.fileName = theFileName;
                    localStorage.conMIMEType = result[0].MIME_Type__c;
                    localStorage.currentId = domRecordId;

                    successCallback(theFileName);
                },
                function(errorMessage) {
                    // Failure - Error Callback (Call if 0 Mime Types returned or if error in VF Call)
                    failureCallback(errorMessage);
                    return false;
                }
            );
        }
        else if(theFile){
            failureCallback("Maximum document upload size is 10 MB. Please reduce the size of the document and try again.");
            return false;
        }
      /*localStorage.fileName   = theFileName;
      localStorage.conMIMEType  = conMIMEType;
      localStorage.currentId    = currentId;*/

      //ATTACHMENTBUTTONMODALCOMP.logMessages('Local Storage Values\nFileName: ' + localStorage.fileName + '\nMimeType : '+localStorage.conMIMEType + '\nHTML Button Id: '+localStorage.currentId + '\nPassed all validations,continue..');
    },


    /***************************************************************************
    saveButtonClick
    FUNCTION (No Return)
    e: event passed from jQuery
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    successCallback: success callback function
    failureCallback: failure callback function
    ***************************************************************************/
    saveButtonClick: function(e, domRecordId, successCallback, failureCallback) {
        // By this time the localStorage obect has fileName & conMIMEType
        var fileName = localStorage.fileName;
        var conMIMEType = localStorage.conMIMEType;
        var fileDesc = $('#addAttachmentComment' + domRecordId).text();
        var fileBlobControl = $("#fileBlobControl" + domRecordId);
        //Check if document name is present
        if( typeof fileName === 'undefined' || fileName === null || fileName === "" || fileName.length === 0 ){
            OH_NOTIFICATIONS.spinnerStop(); //sanjeev   
            failureCallback('Document missing. Please attach a document.');
            return;
        }//endif-no file selected

        if( fileContents === "" || fileContents === null ){
            OH_NOTIFICATIONS.spinnerStop(); //sanjeev   
            failureCallback('Document missing. Please attach a document.');
            return;
        }

        //Check if mimetype is getting lost
        if(conMIMEType === null || conMIMEType === ""){
            OH_NOTIFICATIONS.spinnerStop(); //sanjeev   
            OH_MODAL_UTILITY.errorMessageModal('Upload issue.  Please add/replace the document and try again.');
            return;
        }//endif-mimetype is lost
        ATTACHMENTBUTTONMODALCOMP.logMessages('In saveButtonClick: the length of the file is: ' + fileContents.length);//log messages (Nishit)
        // Upload fileData to Salesforce as a Document by calling helper function
   //     ATTACHMENTBUTTONMODALCOMP.uploadChunkedDocument(
          ATTACHMENTBUTTONMODALCOMP.uploadAttachment(
            fileName,
            fileContents,
            function(docUploadResult) {
                // Success callback - we uploaded the chunked Document
                // Pass the Id of the fully-saved Document to createStandardDocumentRecord
//                console.log('File Upload Half Complete!');
//                console.log('entering r_createStandardDocumentRecord(' + docUploadResult[0].id + ',' + fileName + ',' + fileDesc + ',' + JSON.stringify(docUploadResult) + ',' + conMIMEType + ',' + domRecordId + ',successCB, failureCB)');
                ATTACHMENTBUTTONMODALCOMP.r_createStandardDocumentRecord(
                    docUploadResult[0].id,
                    fileName,
                    fileDesc,
                    conMIMEType,
                    docUploadResult,
                    domRecordId,
                    function(result) {
                        // Success - create Standard Document Callback
                        // NOTE: If we caught a server error, we'll still fire this callback because the transaction will complete.
                        //       In that case, we need to display a user-friendly error message we set up on the back-end.
                        ATTACHMENTBUTTONMODALCOMP.logMessages('\nCreate Standard Document Result: ' + JSON.stringify(result));
                        if(result.success) {
                            ATTACHMENTBUTTONMODALCOMP.r_insertAttachmentWSwithUID(
                                result.standardDocumentId,
                                result.attachmentId,
                                localStorage.UID,
                                domRecordId,
                                'Revise',
                                function() {
                                    // Success - insert Attachment to Webservice Callback
//                                    console.log('File Upload Fully Complete!');
                                    successCallback(result, fileName);
                                },
                                function(integrationErrorMessage) {
                                    // Failure - insert Attachment to Webservice Callback
                                    
                                    var res = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "reLinkTransDoc", {
                                                            transactionDocId: domRecordId,
                                                            standardDocId: localStorage.oldStdDocId,
                                                            transDocName: localStorage.oldTransDocName
                                    })
                                    ATTACHMENTBUTTONMODALCOMP.logMessages(integrationErrorMessage);
                                    //OH_MODAL_UTILITY.errorMessageModal(integrationErrorMessage);
                                    failureCallback(integrationErrorMessage);
                                }
                            );
                        }
                        else {
                            ATTACHMENTBUTTONMODALCOMP.logMessages(result.message);
                            failureCallback(result.message);
                        }
                    },
                    function(errorMessage) {
                        // Failure - Error Callback (Call if 0 Mime Types returned or if error in VF Call)
                        failureCallback(errorMessage);
                    }
                );
            },
            function(errorMessage) {
                // Failure callback - we didn't upload the original Document
                failureCallback(errorMessage);
            }
        );
    },


    /***************************************************************************
    cancelButtonClick
    FUNCTION (No Return)
    e: event passed from jQuery
    domRecordId: Record Id string passed from PGFAttachmentButtonModalComp. Can
                 be a Salesforce Id but is not necessarily one. Pass this to
                 all remoting calls as the "recordIdString" parameter.
    ***************************************************************************/
    cancelButtonClick: function(e, domRecordId) {
        $("#attachmentFileName" + domRecordId).text($("#loadedFileName"+ domRecordId).text().trim());
        // Clear data from local storage
        delete localStorage.fileName;
        delete localStorage.conMIMEType;
        delete localStorage.currentId;
        delete localStorage.UID;
        delete localStorage.msgCount;
        delete localStorage.enableLogs;
        //clear file contents   
        if(typeof fileContents != 'undefined' ){fileContents = null;}
        $("#replaceAttBtn"+domRecordId).val('');
    },

    //function to log console messages and also to log console messages in integration log INT-008.6(Nishit)
  logMessages: function(consoleMessage) {
        localStorage.msgCount = localStorage.msgCount + 1;
        if(localStorage.msgCount == '01') {
        console.log('localStorage.msgCount '+localStorage.msgCount);
            //uLogIdd = null;
            localStorage.enableLogs = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "isEnableConsoleLogs", {});
        }
        if(localStorage.enableLogs == 'true') {
          localStorage.UID = sforce.apex.execute("OCLQS_ONBASE_UploadFile", "logBrowserConsole", {
                UID: localStorage.UID,
                message: '(Revise) '+consoleMessage + '\n' 
          });
          console.log('ReviseLog_'+localStorage.msgCount+' >:'+consoleMessage);
        }
        
    return;
  },

  getFileExt: function (filename){
    var ext = filename.split('.').pop();
    if(ext == filename){ return ""};
    return ext;
  },

  getBrowserDetials: function (){
    var nVer = navigator.appVersion;
    var nAgt = navigator.userAgent;
    var browserName  = navigator.appName;
    var fullVersion  = ''+parseFloat(navigator.appVersion); 
    var majorVersion = parseInt(navigator.appVersion,10);
    var nameOffset,verOffset,ix;

    // In Opera 15+, the true version is after "OPR/" 
    if ((verOffset=nAgt.indexOf("OPR/"))!=-1) {
     browserName = "Opera";
     fullVersion = nAgt.substring(verOffset+4);
    }
    // In older Opera, the true version is after "Opera" or after "Version"
    else if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
     browserName = "Opera";
     fullVersion = nAgt.substring(verOffset+6);
     if ((verOffset=nAgt.indexOf("Version"))!=-1) 
       fullVersion = nAgt.substring(verOffset+8);
    }
    // In MSIE, the true version is after "MSIE" in userAgent
    else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
     browserName = "Microsoft Internet Explorer";
     fullVersion = nAgt.substring(verOffset+5);
    }
    // In Chrome, the true version is after "Chrome" 
    else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
     browserName = "Chrome";
     fullVersion = nAgt.substring(verOffset+7);
    }
    // In Safari, the true version is after "Safari" or after "Version" 
    else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
     browserName = "Safari";
     fullVersion = nAgt.substring(verOffset+7);
     if ((verOffset=nAgt.indexOf("Version"))!=-1) 
       fullVersion = nAgt.substring(verOffset+8);
    }
    // In Firefox, the true version is after "Firefox" 
    else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
     browserName = "Firefox";
     fullVersion = nAgt.substring(verOffset+8);
    }
    // In most other browsers, "name/version" is at the end of userAgent 
    else if ((nameOffset=nAgt.lastIndexOf(' ')+1) < (verOffset=nAgt.lastIndexOf('/'))) 
    {
     browserName = nAgt.substring(nameOffset,verOffset);
     fullVersion = nAgt.substring(verOffset+1);
     if (browserName.toLowerCase()==browserName.toUpperCase()) {
      browserName = navigator.appName;
     }
    }
    // trim the fullVersion string at semicolon/space if present
    if ((ix=fullVersion.indexOf(";"))!=-1)
       fullVersion=fullVersion.substring(0,ix);
    if ((ix=fullVersion.indexOf(" "))!=-1)
       fullVersion=fullVersion.substring(0,ix);

    majorVersion = parseInt(''+fullVersion,10);
    if (isNaN(majorVersion)) {
     fullVersion  = ''+parseFloat(navigator.appVersion); 
     majorVersion = parseInt(navigator.appVersion,10);
    }

     var details = '\nUser Browser Details:\n--------------------------\n' + 'Browser name  = '+browserName+'\n';
     details = details + 'Full version  = '+fullVersion+'\n';
     details = details + 'Major version = '+majorVersion+'\n';
     details = details + 'navigator.appName = '+navigator.appName + '\n';
     details = details + 'navigator.userAgent = '+navigator.userAgent+'\n------------------------------\n\n';
     return details;
  } 
}