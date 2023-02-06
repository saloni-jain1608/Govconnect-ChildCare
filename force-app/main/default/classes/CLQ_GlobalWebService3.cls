/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_GlobalWebService3
** Description      : Class to send email
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer           Date                Version         Description
**	Neetu Ojha			10/09/2017			1.1				TFS#11785 - Fix to remove Inactive/ Denied Role while sending email.
**  Neetu Ojha          11/02/2017          1.2             TFS#11799
**************************************************************************************************************/

global with sharing class CLQ_GlobalWebService3 {

     @InvocableMethod(label='Send CAP Email' description='Allows an email to be sent using apex, combine template and CAPRecordID id separated by pipe')
    public static void sendCAPEmail(list<string> templateAndRecordID) {  

        for (string tempRec : templateAndRecordID){
            list<string> callParms = tempRec.split('\\|');
            sendCAPEmail(callParms[0], callParms[1]);
        }
    }  
    
    webservice static void sendCAPEmail(string templateName, id CAPRecordID) {

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        CLQ_Corrective_Action_Plan__c capRecord;
        if(CAPRecordID!=null && Schema.SObjectType.CLQ_Corrective_Action_Plan__c.isAccessible()){
        capRecord = [select id,CLQ_Program__r.id,CLQ_Program__r.CLQ_Associated_Organization__r.id from CLQ_Corrective_Action_Plan__c where id = :CAPRecordID limit 1];
        }
        list<string> toAddressesLICENSING = CLQ_GlobalWebserviceUtility.getAllRecipientsLicensing(capRecord.CLQ_Program__r.Id,capRecord.CLQ_Program__r.CLQ_Associated_Organization__r.id,null);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'jshivakumar@deloitte.com'];
        if(toAddressesLICENSING.size() > 0 ){
           try{
               EmailTemplate templateForEmail;
               if(templateName!=null &&  Schema.SObjectType.EmailTemplate.isAccessible()){
               templateForEmail = [select id from EmailTemplate where DeveloperName = :templateName]; //11799
               }
               CLQ_Role__c roleForEmail;
               if(capRecord!=null &&  Schema.SObjectType.CLQ_Role__c.isAccessible()){
                   
               roleForEmail = [select id,CLQ_Contact__r.id from CLQ_Role__c 
               									where Portal_Roles__c IN ('OCLQSOwner','OCLQSSUTQ','OCLQSAdministrator') 
               									and ( CLQ_Program__r.id = :capRecord.CLQ_Program__r.id 
               										or CLQ_Organization__r.id = :capRecord.CLQ_Program__r.CLQ_Associated_Organization__r.id)
               									AND CLQ_Status__c NOT IN ('Inactive', 'Denied') limit 1]; //11785
               }
               msg.settargetObjectID(roleForEmail.CLQ_Contact__r.id);
               msg.setwhatID(capRecord.id);
               msg.setTemplateId(templateForEmail.id);
               msg.setToaddresses(toAddressesLICENSING);
               if ( owea.size() > 0 ) {
                   msg.setOrgWideEmailAddressId(owea.get(0).Id);
               }
               msg.setTreatTargetObjectAsRecipient(false);
               //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
            }
            catch(QueryException e){
                system.debug('exception:'+e);
            }
        }
    }
}