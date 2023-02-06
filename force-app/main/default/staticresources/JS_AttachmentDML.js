/***********************************************************************
//  ATTACHMENT_DML - Contains all DML operatiions for attachments piece
//  contains:  createStandardDocumentRecord
//             createTransactionDocumentRecord
//             createAttachmentRecord
//             replaceAttchment
/***********************************************************************/

;ATTACHMENT_DML = {
    /******************************************************************************
    //  createStandardDocumentRecord
    //  Inputs: divId - the control which has the comment in it.
    //   Outputs: none
    //****************************************************************************/
    addComment: function(divId) {

      var idObj = ATTACHMENTCOMPNS.getIdObject(divId);
      var uniqueId = idObj.uniqueId;
      var stdDetailId = idObj.stdDetailId;
      var gUserInfo = JSON.parse($("#oclqs_global_info").val()).uRecord;
      var divId = stdDetailId;
      var programId = ProgramIdString.textContent.trim();
      var strComments = $("#addAttachmentComment" + uniqueId)[0].value;
      var strConId = idObj.contactId;
      var userFullName = gUserInfo.FirstName + ' ' + gUserInfo.LastName; 
      var currDateTime = new Date().toISOString(); 
        
      var existsSOQL = "Select Id"; 
      existsSOQL +=    ", Name";
      existsSOQL +=    ", CLQ_Document__c";
      existsSOQL +=    " from CLQ_Transaction_Document__c";
      existsSOQL +=    " where CLQ_Program_Transaction__c = '" + TransactionIdString.innerHTML.trim() + "'";
      existsSOQL +=    " and Program_Documents__c = '" + programId + "'";
      existsSOQL +=    " and CLQ_Standard_Detail_Document__c = '" + stdDetailId + "'";
      if (strConId) existsSOQL +=    " and CLQ_Contact__c = '" + strConId + "'";
      existsSOQL +=    " and CLQ_Portal_Marked_for_Delete__c <> true"

      var existingTD = sforce.connection.query(existsSOQL).getArray("records");
      if(existingTD.length > 0) {
        td = sforce.connection.retrieve("Id, CLQ_All_Comments__c", "CLQ_Transaction_Document__c", [existingTD[0].Id])[0];
        if(td) {
          if (strComments) {
            td.CLQ_All_Comments__c = (td.CLQ_All_Comments__c) ? td.CLQ_All_Comments__c + '<br><br><br>' : '';
            td.CLQ_All_Comments__c += strComments + '<br><br>' + userFullName + '<br>' + currDateTime;  
            var updTD = sforce.connection.update([td])[0]; 
            if (!updTD.success) {
              throw (updTD);
            }
          }
        }
      }  
    },


    /******************************************************************************
    //  createStandardDocumentRecord
    //  Inputs: divId - the controlId that triggered this event
    //          incomingFile - the metadata for the file coming in to the system.
    //          --consists of: name (the file name)
    //                         mimeType (the MIME Type of the file, as interpreted 
    //                                     by the browser)
    //   Outputs: success - the Standard Document complete with Id
    //            failure - error object with SFDC error code and message
    //****************************************************************************/
    createStandardDocumentRecord: function(divId, incomingFile) {
        var idObj = ATTACHMENTCOMPNS.getIdObject(divId);

        var stdDetailId = idObj.stdDetailId;
        var divId = stdDetailId;
        var programId = ProgramIdString.textContent.trim();

        var gUserInfo = JSON.parse($("#oclqs_global_info").val()).uRecord;
        var userId = gUserInfo.Id;
        if (incomingFile) {
          var fileName = incomingFile.name;
          var MIMEType = incomingFile.MIMEType;
        } else {
//            console.log('There was no incomingFile parameter for createStandardDocumentRecord');
            throw "No incomingFile passed to createStandardDocumentRecord";
        }
        var accountId = gUserInfo.AccountId;
        var contactId = idObj.contactId;

        //Get the document type from SFDC
        var docTypeResult = sforce.connection.retrieve("CLQ_Integration_Document_Type__c", "CLQ_Standard_Detail__c", [stdDetailId])[0].CLQ_Integration_Document_Type__c;

        var sd = new sforce.SObject("CLQ_Standard_Document__c");
    /************************************************************************/
    // Standard Document Fields                                             //
    //      Document Name:        CLQ_Integration_File_Name__c              //
    //      Organization:         CLQ_Organization__c                       //
    //      Program:              CLQ_Program__c                            //
    //      Owner                 OwnerId                                   //
    //      Document Affiliation: CLQ_Document_Affiliation__c               //
    //      Document Type:        CLQ_Integration_Document_Type__c          //
    //      MIME Type:            CLQ_Integration_Doc_MIMEType__c           //
    /************************************************************************/
         sd.Name = fileName;
         sd.CLQ_Integration_File_Name__c = fileName;
         sd.CLQ_Organization__c = accountId;
         sd.CLQ_Program__c = programId;
         sd.OwnerId = userId;
         sd.CLQ_Document_Affiliation__c = 'Program';
         sd.CLQ_Integration_Document_Type__c = docTypeResult;
         sd.CLQ_Integration_Doc_MIMEType__c = MIMEType;

         try {
           var newSD = sforce.connection.create([sd])[0];
           if (newSD.success) {
     //        console.log('createStandardDocumentRecord(' + divId + ',' + JSON.stringify(incomingFile) + ') created ' + JSON.stringify(newSD));
             return {success: true,
                     sd: sforce.connection.retrieve("Id, CLQ_Integration_File_Name__c, CLQ_Organization__c, CLQ_Program__c, OwnerId, CLQ_Document_Affiliation__c, CLQ_Integration_Document_Type__c, CLQ_Integration_Doc_MIMEType__c", "CLQ_Standard_Document__c", [newSD.id])[0]}
           } else {
              throw(newSD);
           }
         } catch (sfdcCreateError) {
           return {success: false,
                   errorMessage: JSON.stringify(sfdcCreateError)};
         }
    },


    /******************************************************************************
    //  createTransactionDocumentRecord
    //  Inputs: sd - The Standard Document record that this Transaction Document
    //               should be attached to.
    //          incomingFile - the metadata for the file coming in to the system.
    //          --consists of: name (the file name)
    //                         mimeType (the MIME Type of the file, as interpreted 
    //                                     by the browser)
    //   Outputs: success - the Transaction Document complete with Id
    //            failure - error object with SFDC error code and message
    //****************************************************************************/
    createTransactionDocumentRecord: function(divId, sd, incomingFile) {

        var idObj = ATTACHMENTCOMPNS.getIdObject(divId);
        var uniqueId = idObj.uniqueId;
        var stdDetailId = idObj.stdDetailId;
        var divId = stdDetailId;
        var programId = ProgramIdString.textContent.trim();
        var strComments = $("#addAttachmentComment" + uniqueId)[0].value;
        var strConId = idObj.contactId;
        
        //check if the txn doc already exists.  If it does, associate the SD to it.
        var existsSOQL = "Select Id"; 
        existsSOQL +=    ", Name";
        existsSOQL +=    ", CLQ_Portal_Document_Comments__c";
        existsSOQL +=    ", CLQ_All_Comments__c";
        existsSOQL +=    ", CLQ_Document__c";
        existsSOQL +=    " from CLQ_Transaction_Document__c";
        existsSOQL +=    " where CLQ_Program_Transaction__c = '" + TransactionIdString.innerHTML.trim() + "'";
        existsSOQL +=    " and Program_Documents__c = '" + programId + "'";
        existsSOQL +=    " and CLQ_Standard_Detail_Document__c = '" + stdDetailId + "'";
        if (strConId) existsSOQL +=    " and CLQ_Contact__c = '" + strConId + "'";
        existsSOQL +=    " and CLQ_Portal_Marked_for_Delete__c <> true"

        var tdResults = sforce.connection.query(existsSOQL).getArray("records");

        if (tdResults.length > 0) {
            var gUserInfo = JSON.parse($("#oclqs_global_info").val()).uRecord;
            var userName = gUserInfo.FirstName + ' ' + gUserInfo.LastName; 
            var currDTime = new Date().toISOString(); 

          try {
            for (var thisTD in tdResults) {

              tdResults[thisTD].Name = sd.CLQ_Integration_File_Name__c;
              tdResults[thisTD].CLQ_Document__c = sd.Id;
              tdResults[thisTD].CLQ_Portal_Document_Comments__c = strComments;
              if(strComments) {
                tdResults[thisTD].CLQ_All_Comments__c = (tdResults[thisTD].CLQ_All_Comments__c) ? tdResults[thisTD].CLQ_All_Comments__c + '<br><br><br>' : '';
                tdResults[thisTD].CLQ_All_Comments__c += tdResults[thisTD].CLQ_Portal_Document_Comments__c + '<br><br>' + userName + '<br>' + currDTime;
              }
               
              tdResults[thisTD].CLQ_Document_Status__c = (sd.CLQ_Standard_Document_Status__c) ? sd.CLQ_Standard_Document_Status__c : 'Attached';
              tdResults[thisTD].CLQ_Approved_Points__c = sd.CLQ_Document_Points__c;
              tdResults[thisTD].CLQ_Approved_Rating__c = sd.CLQ_Document_Rating__c;
            }
            var tdUpdResult = sforce.connection.update(tdResults);
            if (tdUpdResult[0].success) {
              return {success: true,
                      td:      tdResults[0]}
            } else {
               throw "Could not update transaction " + tdUpdResults[0].Id + " with standard document " + sd.Id + ": " + JSON.stringify(tdUpdResults[0]);
            }
          } catch (sfdcCreateError) {
            return {success:      false,
                    errorMessage: JSON.stringify(sfdcCreateError)};
          }
        } else {
            var gUserInfo = JSON.parse($("#oclqs_global_info").val()).uRecord;
            var userId = gUserInfo.Id;
            var accountId = gUserInfo.AccountId;
            var contactId = idObj.contactId;
            var userFullName = gUserInfo.FirstName + ' ' + gUserInfo.LastName; 
            var currDateTime = new Date().toISOString(); 

            if (incomingFile) {
                var fileName = incomingFile.name;
                var MIMEType = incomingFile.MIMEType;
                var fileSize = incomingFile.fileSize;
            } else {
     //           console.log('There was no incomingFile parameter for createStandardDocumentRecord');
                throw "No incomingFile passed to createStandardDocumentRecord";
            }
            var accountId = gUserInfo.AccountId;
            var contactId = idObj.contactId;


        
            var td = new sforce.SObject("CLQ_Transaction_Document__c");
            /************************************************************************/
            // Transaction Document Fields                                          //
            //      Transaction Document Name:  Name                                //
            //      Program Transaction:        CLQ_Program_Transaction__c          //
            //      Document Status:            CLQ_Document_Status__c              // 
            //      Standard Detail Document:   CLQ_Standard_Detail_Document__c     //
            //      Document Comments:          CLQ_Portal_Document_Comments__c     //
            //      All Comments:               CLQ_All_Comments__c                 //
            //      Contact:                    CLQ_Contact__c                      //
            //      Approved Points:            CLQ_Approved_Points__c              //
            //      Approved Rating:            CLQ_Approved_Rating__c              //
            /************************************************************************/

            td.Name = fileName;
            td.CLQ_Document__c = sd.Id;
            td.CLQ_Portal_Document_Comments__c = strComments;
            td.Program_Documents__c = programId;
            td.CLQ_Standard_Detail_Document__c = stdDetailId;
            td.CLQ_Program_Transaction__c = TransactionIdString.innerHTML.trim();
            td.CLQ_Document_Status__c = (sd.CLQ_Standard_Document_Status__c) ? sd.CLQ_Standard_Document_Status__c : 'Attached';
            td.CLQ_Approved_Points__c = sd.CLQ_Document_Points__c;
            td.CLQ_Approved_Rating__c = sd.CLQ_Document_Rating__c;

            if (contactId) {
                td.CLQ_Contact__c = contactId;
            }
            
             try {
                var newTD = sforce.connection.create([td])[0];
                console.log('SUCC: '+newTD.success);
                if (newTD.success) {
                   console.log('aaacreateTransactionDocumentRecord(' + JSON.stringify(sd) + ',' + JSON.stringify(incomingFile) + ') created ' + JSON.stringify(newTD));
                    // Due to an issue with the order of operations on the comments, we have to pull the record back from SFDC and update all comments.
                    if(newTD != null && newTD.id != null) {
                        td = sforce.connection.retrieve("Id, CLQ_Portal_Document_Comments__c, CLQ_All_Comments__c", "CLQ_Transaction_Document__c", [newTD.id])[0];
                    }
                    if(td) {
                    console.log('TDDDDDDDDDDD');
                      if (td.CLQ_Portal_Document_Comments__c) {
                        td.CLQ_All_Comments__c = (td.CLQ_All_Comments__c) ? td.CLQ_All_Comments__c + '<br><br><br>' : '';
                        td.CLQ_All_Comments__c += td.CLQ_Portal_Document_Comments__c + '<br><br>' + userFullName + '<br>' + currDateTime;  
                        var updTD = sforce.connection.update([td])[0]; 
                        if (updTD.success) {
      //                      console.log('updated comments with ' + td.CLQ_All_Comments__c);
                            td = sforce.connection.retrieve("Id, Name, CLQ_Program_Transaction__c, CLQ_Document_Status__c, CLQ_Standard_Detail_Document__c, CLQ_Portal_Document_Comments__c, CLQ_All_Comments__c, CLQ_Contact__c ", "CLQ_Transaction_Document__c", [updTD.id]);
                            return {success: true,
                                    td:      td} 
                        } else {
                        console.log('FAIL');
                            throw (updTD);
                        }
                      } else {
                        //If you don't need to do any mumbo jumbo with the comments, just return the new 
                        return {success: true,
                                td:      td}
                      }
                    } else {
                        throw 'Could not retrieve the new transaction document record with Id: ' + newTD.id + '.';
                    }
                } else {
                console.log('FIRST IF');
                    //Couldn't create the initial txn document
                    throw(newTD);
                }
            } catch (sfdcCreateError) {
                return {success:      false,
                        errorMessage: sfdcCreateError};
            }
        }
    }
}
