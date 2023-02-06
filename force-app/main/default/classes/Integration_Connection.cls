/************************************************************************************************************
** User Story: 
**************************************************************************************************************
** Name             : Integration_Connection
** Description      : This class is a utility class that fetches the endpoint for the integration then makes
the references to fetch the endpoint and authorization details 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Sanjeev Chahar                 June-2016                    1.0                          Created
**
************************************************************************************/ 

public with sharing class Integration_Connection {
    public static String currenEnvName;
    Public static final String PROD_STRING = 'PROD';
    Public static final String Dev_STRING = 'DEV';
    Public static final String METADATA_NOT_FOUND = '--METADATA--NOT--FOUND--';
    public static final string Target_Connection_URL = 'Target_Connection_URL__c';
    public static final string Target_Connection_Port = 'Target_Connection_Port__c';
    public static final string Target_Credentail_Token_OAuth_Key = 'Target_Credentail_Token_OAuth_Key__c';
    public static final string Target_Credentail_User_Id = 'Target_Credentail_User_Id__c';
    public static final string Target_Credentail_User_Password = 'Target_Credentail_User_Password__c';
    public static final string Attribute_1_Value = 'Attribute_1_Value__c';
    public static final string Attribute_2_Value = 'Attribute_2_Value__c';
    public static final string Attribute_3_Value = 'Attribute_3_Value__c';
    public static final string Enable_Debug = 'Enable_Debug__c';
    public static final string Capture_Messages = 'Capture_Messages__c';
    public static final string Error_Email_Notification = 'Error_Email_Notification__c';
    public static final string Error_Email_Notification_Group = 'Error_Email_Notification_Group__c';
    public static final string Attribute_4_Value = 'Attribute_4_Value__c';
    public static final string Attribute_5_Value = 'Attribute_5_Value__c';
    public static final string Attribute_6_Value = 'Attribute_6_Value__c';
    public static final string Attribute_7_Value = 'Attribute_7_Value__c';
    
    public static List <OCLQS_Integration_Settings__mdt> listIntegrationDetails;
    
    /**
** Method           : Integration_Connection
** Description      : Constructor
** Parameter        : None
** Return Type      : None
**/
    public Integration_Connection() {
        
        if (runningInASandbox() == true)
        {
            // Fix to get correct Sandbox URL 
            //currenEnvName = System.Label.Integration_EnvironmentName.trim();
            
            Map<String,String> orgIdEnvironmentNameMap = new Map<String,String>();
            for(OCLQS_NameValuePair__mdt c : [ Select ID, DeveloperName, Value__c , Value2__c, Value1__c from OCLQS_NameValuePair__mdt Where DeveloperName='SandboxOrgIdMapping'])
            {
                if(c.value__c != null){orgIdEnvironmentNameMap.putAll(this.convertStringToMap(c.value__c));}
                if(c.value1__c != null){orgIdEnvironmentNameMap.putAll(this.convertStringToMap(c.value1__c)) ;}
                if(c.value2__c != null) {orgIdEnvironmentNameMap.putAll(this.convertStringToMap(c.value2__c)) ;}      
            }//end for
            
            Map<Id,String> orgIdEnvironmentNameMapId = new Map<Id,String>() ;
            for(String key : orgIdEnvironmentNameMap.keySet())
            {
                orgIdEnvironmentNameMapId.put((Id)key ,orgIdEnvironmentNameMap.get(key));
            }//end for
            
            currenEnvName  = orgIdEnvironmentNameMapId.get(UserInfo.getOrganizationId());
        } else {
            currenEnvName = PROD_STRING;
        }//end if sandbox type
        if(currenEnvName!=null){
            listIntegrationDetails = [Select Label, Error_Email_Notification__c, Error_Email_Notification_Group__c, Capture_Messages__c, Enable_Debug__c, Attribute_1_Value__c, Attribute_2_Value__c, Attribute_3_Value__c,Attribute_4_Value__c,Attribute_5_Value__c,Attribute_6_Value__c,Attribute_7_Value__c,DeveloperName, Target_Connection_Port__c,Target_Connection_URL__c,Target_Credentail_Token_OAuth_Key__c,Target_Credentail_User_Id__c,Target_Credentail_User_Password__c, Environment_Name__c from OCLQS_Integration_Settings__mdt where Environment_Name__c =:currenEnvName];
        }
        
    }//End Constructor
    
    public static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public String getEnvName(){
        return currenEnvName.trim();  
    }
    
    /**
** Method           : getConnectionDetails
** Description      : This method returns the integration parameter value
** Parameter        : DeveloperName and MetaData Type Object field name
** Return Type      : String
**/
    public String getConnectionDetails(String TransactionId, String paraType){
        try{ 
            String data = METADATA_NOT_FOUND; //Default value
            String dataBackup = data;
            
            if(test.isRunningTest()){
                OCLQS_Integration_Settings__mdt Intset= new OCLQS_Integration_Settings__mdt();
                Intset.Environment_Name__c= Dev_STRING;
                listIntegrationDetails.add(Intset);
            }
            if(!listIntegrationDetails.isEmpty() && listIntegrationDetails.size() > 0){
                for(OCLQS_Integration_Settings__mdt integration : listIntegrationDetails){
                    if (integration.Label.trim().touppercase().equals(TransactionId.trim().touppercase())){
                        
                        if (paraType.trim().touppercase().equals(Target_Connection_URL.trim().touppercase())){                
                            data = integration.Target_Connection_URL__c;
                        } else if (paraType.trim().touppercase().equals(Target_Connection_Port.trim().touppercase())){                
                            data = integration.Target_Connection_Port__c;
                        } else if (paraType.trim().touppercase().equals(Target_Credentail_Token_OAuth_Key.trim().touppercase())){                
                            data = integration.Target_Credentail_Token_OAuth_Key__c;
                        } else if (paraType.trim().touppercase().equals(Target_Credentail_User_Id.trim().touppercase())){                
                            data = integration.Target_Credentail_User_Id__c;
                        } else if (paraType.trim().touppercase().equals(Target_Credentail_User_Password.trim().touppercase())){                
                            data = integration.Target_Credentail_User_Password__c;
                        } else if (paraType.trim().touppercase().equals(Attribute_1_Value.trim().touppercase())){                
                            data = integration.Attribute_1_Value__c;
                        } else if (paraType.trim().touppercase().equals(Attribute_2_Value.trim().touppercase())){                
                            data = integration.Attribute_2_Value__c;
                        } else if (paraType.trim().touppercase().equals(Attribute_3_Value.trim().touppercase())){                
                            data = integration.Attribute_3_Value__c;         
                        } else if (paraType.trim().touppercase().equals(Enable_Debug.trim().touppercase())){                
                            data = string.valueOf(integration.Enable_Debug__c);         
                        } else if (paraType.trim().touppercase().equals(Capture_Messages.trim().touppercase())){                
                            data = string.valueOf(integration.Capture_Messages__c);         
                        } else if (paraType.trim().touppercase().equals(Error_Email_Notification.trim().touppercase())){                
                            data = string.valueOf(integration.Error_Email_Notification__c);         
                        } else if (paraType.trim().touppercase().equals(Error_Email_Notification_Group.trim().touppercase())){                
                            data = integration.Error_Email_Notification_Group__c.trim();    
                        } else if (paraType.trim().touppercase().equals(Attribute_4_Value.trim().touppercase())){                
                            data = integration.Attribute_4_Value__c.trim();                                                                           
                        } else if (paraType.trim().touppercase().equals(Attribute_5_Value.trim().touppercase())){                
                            data = integration.Attribute_5_Value__c.trim();                                                                           
                        } else if (paraType.trim().touppercase().equals(Attribute_6_Value.trim().touppercase())){                
                            data = integration.Attribute_6_Value__c.trim();                                                                           
                        }else if (paraType.trim().touppercase().equals(Attribute_7_Value.trim().touppercase())){                
                            data = integration.Attribute_7_Value__c.trim();                                                                           
                        }//End if//End if
                        
                        
                        break;  
                    }//End if Match Transaction Id
                }//End for Loop
            }//End if iterator
            
            //Parameter value not found in the system,send email notification
            if (data !=null && data==dataBackup){ sendErrorMailforMissingMetadata(TransactionId,paraType);}
            
            return data.trim();
        } catch(Exception e){
            
            return null;
        }//End Catch
    }//End getConnectionDetails
    
    //@future
    public static void sendErrorMailforMissingMetadata(String TransactionId, String paraType){
        try{
            String mailingAddressNoti = '';
            List <OCLQS_Integration_Settings__mdt> defMetadata = [Select Error_Email_Notification_Group__c from OCLQS_Integration_Settings__mdt where Environment_Name__c ='Default' Limit 1];
            if(!defMetadata.isEmpty() && defMetadata.size() > 0){
                mailingAddressNoti = defMetadata[0].Error_Email_Notification_Group__c.trim();                                                                           
            } else {
                mailingAddressNoti =  'mvg@deloitte.com'; //default just in case
            } //end if
            
            String subject = currenEnvName + '- Integration Metadata Not Found :[' + TransactionId + ']';
            String plainBody = '';
            plainBody = plainBody + '' + '<font color="red">' + subject  + '</font>';
            plainBody = plainBody + '<br><br>' + '<font color="blue">Date & Time&nbsp;:&nbsp;&nbsp;</font>' + datetime.now().format('MMMMM dd, yyyy hh:mm:ss a');
            plainBody = plainBody +  '<br><br><font color="blue">OCLQS URL&nbsp;:&nbsp;&nbsp;</font>' + URL.getSalesforceBaseUrl().getHost();
            plainBody = plainBody +  '<br><br>'+ '<font color="blue">User Impacted&nbsp;:&nbsp;&nbsp;</font>' + Userinfo.getName() + '(User Id: ' + Userinfo.getUserId()  + ' ; Email: ' + Userinfo.getUserEmail() + ')';
            plainBody = plainBody + '<br><br>' + '<font color="blue">Transaction Id&nbsp;:&nbsp;&nbsp;</font>' + TransactionId  ;
            plainBody = plainBody + '<br><br>' + '<font color="blue">Error Message&nbsp;:&nbsp;&nbsp;</font> ' + 'Transaction Metadata for Integration "' + TransactionId + '" parameter "' + paraType + '" not found' ;
            plainBody = plainBody + '<br><br><br>' + '<font color="red">*** Please do not reply to this auto-generated email ***</font>';
            
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
            String sendEmailgroup=mailingAddressNoti.replaceAll(';', ',');
            List<String> mailingAddress= sendEmailgroup.split(',');
            email.setToAddresses(mailingAddress);
            
            //See if org wide email address is set
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address ='mvg@deloitte.com'];
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }else{
                email.setReplyTo('mvg@deloitte.com');
                email.setSenderDisplayName('OCLQS Notification');  
            }//end if org wide email address
            
            email.setSaveAsActivity(false);
            email.setSubject(subject);
            email.setHtmlBody(plainBody);
            Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
            
        } catch(Exception e){
            System.debug(e);
        }//End Catch
    }//end method
    
    private map<String,String> convertStringToMap(String inContent)     
    {
        try{
            Map<String,String> retMap = new Map<String,String>() ;
            string[] eachConfig=null;
            for(String eachRec : inContent.split('\n'))
            {
                eachConfig = eachRec.split('==');
                retMap.put(eachConfig[0].trim(), eachConfig[1].trim() );
            }//end for
            return retMap ;
            
        } catch(Exception e){
            
            return null;
        }//End Catch
    }//end method
    
}//End Class