/*************************************************************************************************************
** User Story: 
**************************************************************************************************************
** Name             : Integration_Transaction_Logs
** Description      : This class is a utility class that insert/update logs into Salesforce Transaction Monitor
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Sanjeev Chahar                 June-2016                    1.0                          Created
************************************************************************************/ 
global with sharing class Integration_Transaction_Logs {
    
    /**
** Method           : Integration_Transaction_Logs
** Description      : Constructor
** Parameter        : None
** Return Type      : None
**/
    public Integration_Transaction_Logs() { }//End Constructor
    
    public static final String Empty = '';
    public static final String newLine = '\n';
    public static final String Pass = 'Pass';
    public static final String Fail = 'Fail';
    public static final String statuscode = '200';
    public static final String oclqs = 'OCLQS-';
    public static final String errorText = ' : Error: ';
    public static final String plainBody1a = '<font color="red">';
    public static final String plainBody1b = '</font>';
    public static final String plainBodyBr = '<br><br>';
    public static final String plainBody2a = '<font color="blue">Date & Time&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody2b = 'MMMMM dd, yyyy hh:mm:ss a';
    public static final String plainBody3 = '<br><br><font color="blue">OCLQS URL&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody4a = '<font color="blue">User Impacted&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody4b = '(User Id: ';
    public static final String plainBody4c = ' ; Email: ' ;   
    public static final String plainBody4d =  ')';
    public static final String plainBody5 = '<font color="blue">Transaction Id&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody6 = '<font color="blue">Transaction Name&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody7 = '<font color="blue">Error Cause&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody8 = '<font color="blue">Error Type&nbsp;:&nbsp;&nbsp;</font>';
    public static final String plainBody9 = '<font color="blue">Error Line number&nbsp;:&nbsp;&nbsp;</font> '; 
    public static final String plainBody10 = '<font color="blue">Error Stack&nbsp;:&nbsp;&nbsp;</font> ';
    public static final String rn = '\r\n';
    public static final String br = '<br/>';
    public static final String r ='\r';
    public static final String plainBodyErrorMsg = '<font color="blue">Error Message&nbsp;:&nbsp;&nbsp;</font> ';
    public static final String newBr = '<br><br><br>';
    public static final String plainBodyErrorMsg2 = '<font color="red">*** Please do not reply to this auto-generated email ***</font>';
    public static final String email = 'mvg@deloitte.com';
    public static final String OCLQS_Notification = 'OCLQS Notification';
    public static final String kHexCharString = '0123456789abcdef';
    public static final string TRUESTR='true';

        
        /**
** Method           : LogMessage
** Description      : This method used for transaction logging
**/
        //@future(callout=true)
        public static void LogMessage(String transactionID,String uniqueID,String requestMessage,String responseMessage,String HTTPResponseCode,String transactionDetails){
            try{
                String parentId ;
                if(transactionID.trim() != null){
                    parentId  = [SELECT Id  FROM OCLQS_Transaction_Log__c where Name=:transactionID.trim()].Id;
                }
                if (String.isNotBlank(parentId)){
                    OCLQS_Transaction_Monitor__c txnMonitor = new OCLQS_Transaction_Monitor__c();
                    system.debug('parentId:'+parentId);
                    txnMonitor.User_Name__c = maxChars(UserInfo.getUserName(), 48);
                    String txnDetails = Empty;
                    String txnm_req   = Empty;
                    String txnm_res   = Empty;
                    
                    if (String.isNotBlank(uniqueID)){
                        system.debug('uniqueID:'+uniqueID);
                        List<OCLQS_Transaction_Monitor__c> tx_MON = [Select Id,Details__c,Request_Message__c,Response_Message__c FROM OCLQS_Transaction_Monitor__c where Correlation_Id__c=:uniqueID.trim() limit 1];
                        if(tx_MON.size() > 0) {
                            system.debug('tx_MON size:'+tx_MON.size());
                            if (String.isNotBlank(tx_MON[0].Details__c)){txnDetails = tx_MON[0].Details__c; }   
                            if (String.isNotBlank(tx_MON[0].Request_Message__c)){txnm_req = tx_MON[0].Request_Message__c; }   
                            if (String.isNotBlank(tx_MON[0].Response_Message__c)){txnm_res = tx_MON[0].Response_Message__c; }   
                        }//end if 
                        //txnDetails = [SELECT Details__c FROM OCLQS_Transaction_Monitor__c where Correlation_Id__c=:uniqueID.trim()].Details__c;
                    }//end if                                     
                    
                    if (String.isNotBlank(transactionDetails)){
                        txnMonitor.Details__c = maxChars( txnDetails +  newLine + transactionDetails.trim(),32750);
                    }else {
                        txnMonitor.Details__c = maxChars( txnDetails ,32750);
                    }
                    
                    if (String.isNotBlank(requestMessage)) {
                        txnMonitor.Request_Message__c = maxChars(txnm_req + newLine + requestMessage.trim(),131000);
                    }else{
                        txnMonitor.Request_Message__c = maxChars(txnm_req,131000);
                    }
                    
                    
                    if (String.isNotBlank(responseMessage)){
                        txnMonitor.Response_Message__c    = maxChars(txnm_res + newLine + responseMessage.trim(),131000);
                    }else{
                        txnMonitor.Response_Message__c    = maxChars(txnm_res ,131000);
                    }
                    
                    if (String.isNotBlank(uniqueID)){txnMonitor.Correlation_Id__c = maxChars(uniqueID.trim(),66);}
                    
                    if (String.isNotBlank(HTTPResponseCode)){
                        HTTPResponseCode = HTTPResponseCode.trim();
                        txnMonitor.Response_Code__c = maxChars(HTTPResponseCode,8);
                        
                        if(HTTPResponseCode.equals(statuscode)){
                            txnMonitor.Status__c = Pass;
                        }else{
                            txnMonitor.Status__c = Fail;
                        } 
                        //}else{
                        //    txnMonitor.Status__c = 'Fail';
                    }//End if HTTPResponseCode
                    
                    txnMonitor.Transaction_Log__c = parentId.trim(); //ref to parent record
                    upsert txnMonitor Correlation_Id__c;
                }//End if parentID is not empty
            } catch(Exception e){
                System.debug(e);
            }//End Catch
        }//End method LogMessage
    
    
    public static void LogErrorRealTime(String transactionID, String errorMessage, String errorCause, String errorLineNumber, String errorStack, String errorType){
        try{ 
            String parentId;
            String parentName;
            if(transactionID.trim() != null){
                parentId  = [SELECT Id  FROM OCLQS_Transaction_Log__c where Name=:transactionID.trim()].Id;
                parentName  = [SELECT Name__c  FROM OCLQS_Transaction_Log__c where Name=:transactionID.trim()].Name__c;
            }
            
            
            if (String.isNotBlank(parentId)){
                OCLQS_Transaction_Error__c   txnError = new OCLQS_Transaction_Error__c  ();
                
                if (String.isNotBlank(errorMessage)){ txnError.Error_Message__c = maxChars(errorMessage.trim(),131000);}
                txnError.Error_Subject__c =  maxChars(oclqs + new Integration_Connection().getEnvName() + errorText + parentName,245);
                
                if (String.isNotBlank(errorCause)){txnError.Error_Cause__c              = maxChars(errorCause.trim(),250);}
                if (String.isNotBlank(errorLineNumber)){txnError.Error_Line_Number__c   = maxChars(errorLineNumber.trim(),250);}
                if (String.isNotBlank(errorStack)){txnError.Error_Stack__c              = maxChars(errorStack.trim(),32600);}
                if (String.isNotBlank(errorType)){txnError.Error_Type__c                = maxChars(errorType.trim(),250);}
                
                txnError.Transaction_Parent_Id__c = parentId.trim(); //ref to parent record
                List<OCLQS_Transaction_Error__c> TransErrorList = new List<OCLQS_Transaction_Error__c>();
                TransErrorList.add(txnError);
                if(!TransErrorList.isEmpty()){
                    insert TransErrorList;
                } 
                sendSingleMail(txnError.Error_Subject__c, transactionID,parentName.trim(),errorCause.trim(),errorType.trim(),errorLineNumber.trim(),errorStack.trim(),errorMessage.trim());
            }//End if parentID is not empty
        } catch(Exception e){
            System.debug(e);
        }//End Catch
        
    }//end method
    
    /**
** Method           : LogError
** Description      : This method used for transaction Error logging
**/
    //@future(callout=true)
    public static String LogError(String transactionID, String errorMessage, String errorCause, String errorLineNumber, String errorStack, String errorType){
        String transactionErrorId = null;
        try{ 
            String parentId;
            String parentName;
            if(transactionID.trim() != null){
                parentId  = [SELECT Id  FROM OCLQS_Transaction_Log__c where Name=:transactionID.trim()].Id;
                parentName  = [SELECT Name__c  FROM OCLQS_Transaction_Log__c where Name=:transactionID.trim()].Name__c;
            }
            if (String.isNotBlank(parentId)){
                OCLQS_Transaction_Error__c   txnError = new OCLQS_Transaction_Error__c  ();
                
                if (String.isNotBlank(errorMessage)){ txnError.Error_Message__c = maxChars(errorMessage.trim(),131000);}
                
                txnError.Error_Subject__c =  maxChars(oclqs + new Integration_Connection().getEnvName() + errorText + parentName,250);
                
                if (String.isNotBlank(errorCause)){txnError.Error_Cause__c             = maxChars(errorCause.trim(),250);}
                if (String.isNotBlank(errorLineNumber)){txnError.Error_Line_Number__c  = maxChars(errorLineNumber.trim(),250);}
                if (String.isNotBlank(errorStack)){txnError.Error_Stack__c             = maxChars(errorStack.trim(),32600);}
                if (String.isNotBlank(errorType)){txnError.Error_Type__c               = maxChars(errorType.trim(),250);}
                
                txnError.Transaction_Parent_Id__c = parentId.trim(); //ref to parent record
                List<OCLQS_Transaction_Error__c> TransErrorList = new List<OCLQS_Transaction_Error__c>();
                TransErrorList.add(txnError);
                if(!TransErrorList.isEmpty()){
                    insert TransErrorList;
                } 
                transactionErrorId = txnError.Id;
                sendSingleMail(txnError.Error_Subject__c, transactionID,parentName.trim(),errorCause.trim(),errorType.trim(),errorLineNumber.trim(),errorStack.trim(),errorMessage.trim());
            }//End if parentID is not empty
        } catch(Exception e){
            System.debug(e);
        }//End Catch
        return transactionErrorId;
    }//End method LogError
    
    /**
** Method           : LogBatchMessage
** Description      : This method used for transaction Batch Monitor logging
**/
    //@future(callout=true)
    public static void LogBatchMessage(String transactionID,String errMessage,String BatchStatus,Integer TotCnt, Integer SucCnt, Integer FailCnt){
        try{ 
            String parentId;
            if(transactionID != null){
                parentId  = [SELECT Id  FROM OCLQS_Transaction_Log__c where Name=:transactionID].Id;
            }
            
            
            if (String.isNotBlank(parentId)){
                OCLQS_Integration_Batch_Monitor__c txnBatchMonitor = new OCLQS_Integration_Batch_Monitor__c();
                if (String.isNotBlank(errMessage)) {    txnBatchMonitor.Error_Message__c = errMessage.trim();}
                if (String.isNotBlank(BatchStatus)){   txnBatchMonitor.Status__c = BatchStatus.trim();}
                txnBatchMonitor.Total_Count__c = TotCnt;
                txnBatchMonitor.Success__c = SucCnt;
                txnBatchMonitor.Fail_Count__c = FailCnt;
                txnBatchMonitor.Transaction_Id__c = parentId.trim(); //ref to parent record
                List<OCLQS_Integration_Batch_Monitor__c> TransBatchList = new List<OCLQS_Integration_Batch_Monitor__c>();
                TransBatchList.add(txnBatchMonitor);
                if(!TransBatchList.isEmpty()){
                    insert TransBatchList;
                } 
            }//End if parentID is not empty
        } //End try
        catch(Exception e){
            System.debug(e);
        }//End Catch
    }//End method LogBatchMessage
    
    /**
** Method           : sendSingleMail
** Description      : This method used for send emails for errors
**/
    
    public static void sendSingleMail(String emailSubject, String txnID, String txnName, String errorCause, String errorType, String errorLineNo, String errorStack, String errorMessage){
        try{
            List<OCLQS_Transaction_Log__c> txnLog;
            if(txnID != null){
                txnLog =  [Select Id, Custom_Metadata_Integration_Type__c from OCLQS_Transaction_Log__c where Name =:txnID LIMIT 1];
            }
            
            if(txnLog.size() >0 && String.isNotBlank(txnLog[0].Custom_Metadata_Integration_Type__c)){
                
                String sendEmailFlag = new Integration_Connection().getConnectionDetails(txnLog[0].Custom_Metadata_Integration_Type__c.trim(),'Error_Email_Notification__c');
                String sendEmailgroup = new Integration_Connection().getConnectionDetails(txnLog[0].Custom_Metadata_Integration_Type__c.trim(),'Error_Email_Notification_Group__c');
                
                if ((sendEmailFlag.equals(TRUESTR) && String.isNotBlank(sendEmailgroup))||test.isRunningTest()){
                    String subject = emailSubject + '[' + txnID + ']';
                    String plainBody = '';
                    plainBody = plainBody + Empty + plainBody1a + emailSubject  + plainBody1b ;
                    plainBody = plainBody + plainBodyBr + plainBody2a + datetime.now().format(plainBody2b);
                    plainBody = plainBody + plainBody3 + URL.getSalesforceBaseUrl().getHost();
                    plainBody = plainBody + plainBodyBr + plainBody4a + Userinfo.getName() + plainBody4b + Userinfo.getUserId()  + plainBody4c + Userinfo.getUserEmail() + plainBody4d;
                    plainBody = plainBody + plainBodyBr + plainBody5 + txnID  ;
                    plainBody = plainBody + plainBodyBr + plainBody6 + txnName;
                    plainBody = plainBody + plainBodyBr + plainBody7 + errorCause;
                    plainBody = plainBody + plainBodyBr + plainBody8 + errorType;
                    plainBody = plainBody + plainBodyBr + plainBody9 + errorLineNo;
                    plainBody = plainBody + plainBodyBr + plainBody10 + errorStack;
                    
                    errorMessage = errorMessage.replace(rn, br);
                    errorMessage = errorMessage.replace(newLine, br);
                    errorMessage = errorMessage.replace(r, br);
                    
                    plainBody = plainBody + plainBodyBr + plainBodyErrorMsg + errorMessage;
                    plainBody = plainBody + newBr + plainBodyErrorMsg2;
                    
                    //build the email message
                    Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                    
                    sendEmailgroup=sendEmailgroup.replaceAll(';', ',');
                    List<String> mailingAddress= sendEmailgroup.split(',');
                    email.setToAddresses(mailingAddress);
                    
                    //See if org wide email address is set
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address ='mvg@deloitte.com'];
                    if ( owea.size() > 0 ) {
                        email.setOrgWideEmailAddressId(owea.get(0).Id);
                    }else{
                        email.setReplyTo('mvg@deloitte.com');
                        email.setSenderDisplayName(OCLQS_Notification);  
                    }//end if org wide email address
                    
                    email.setSaveAsActivity(false);
                    email.setSubject(subject);
                    email.setHtmlBody(plainBody);
                    Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
                }
                //if send email flag is true
            }//end if 
        } catch(Exception e){
            System.debug(e);
        }//End Catch
    }//end sendSingleMail
    
    /**
** Method           : GUID
** Description      : This method returns unique id for corelation
**/
    Public String GUID(){
        try{
            String kHexChars = kHexCharString;  
            String returnValue = Empty;
            Integer nextByte = 0;
            
            for (Integer i=0; i<16; i++) {
                if (i==4 || i==6 || i==8 || i==10){
                    returnValue += '-';
                } 
               
                nextByte = (Math.round(Math.random() * 255)-128) & 255;
                
                if (i==6) {
                    nextByte = nextByte & 15;
                    nextByte = nextByte | (4 << 4);
                }
                
                if (i==8) {
                    nextByte = nextByte & 63;
                    nextByte = nextByte | 128;
                }
                
                returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
                returnValue += getCharAtIndex(kHexChars, nextByte & 15);
            }//End for Loop
            
            string strNow =  string.valueOf(Date.Today().Year()) + string.valueOf(Date.Today().Month())   + string.valueOf(Date.Today().Day()) +   string.valueOf(system.now().hour()) + string.valueOf(system.now().minute()) + string.valueOf(system.now().second()) + string.valueOf(system.now().millisecond());
            return (strNow + '_' + returnValue);
            
        } catch(Exception e){
            //System.debug(e);
            return null;
        }//End Catch
    }//End methods GUID
    
    static String getCharAtIndex(String str, Integer index) {
        if (str == null){
            return null;
        } 
        if (str.length() <= 0){
            return str;
        }     
        if (index == str.length()){
            return null;
        }     
        return str.substring(index, index+1);
    }//end function getCharAtIndex
    
    public static String maxChars(String data, Integer MaxLength){
        String ret = data.trim();   
        if(ret.length() > MaxLength){ret = ret.substring(0, MaxLength);}
        return ret.trim();   
    }//end function
    
}//End Integration_Transaction_Logs