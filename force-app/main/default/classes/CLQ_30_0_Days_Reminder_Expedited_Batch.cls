/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_30_0_Days_Reminder_Expedited_Batch 
** Description      : Batch class to send email notifications to the program (ODJS and ODE) 30 days and day before prior to the
Expiration date
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				  Date				Version			Description
**  Rohit Gowrishetty		11/29/218			1.5				CR#14858 - SUTQ Expdited Rating
***************************************************************************************************************/

global with sharing class CLQ_30_0_Days_Reminder_Expedited_Batch implements Database.Batchable<sObject> {
    
    // Declaring a boolean to capture logs when there are no records to process
    public boolean recToProcess = false;
    public static final string EMPTY='';
    public static final string QuerySTR='Select id,Program_Rating__c,CLQ_Program_Email__c from CLQ_Program__c where Rating_Expiration_Date__c != null and Rating_Expiration_Date__c <=:todayPlus30Days and Rating_Expiration_Date__c >:todayDate AND (CLQ_Program_Status__c = \'Open\' OR CLQ_Program_Status__c = \'Enforcement\' OR CLQ_Program_Status__c = \'Pending\')';
    public static final string SUTQ_Email_30Day_Renew_Reminder='SUTQ_Email_30Day_Renew_Reminder';
    public static final string SUTQ_Email_Tomorrow_Renew_Reminder='SUTQ_Email_Tomorrow_Renew_Reminder';
    public static final string SJ001='SJ-001.4';
	public static final string SUTQ_EXPEDITED_REGISTRATION = 'SUTQ - Expedited Registration';
   	public static final string SUTQ_CHANGE_OWNER_REGISTRATION = 'SUTQ - Change of Owner Registration';
    public static final string SUTQ_REINSTATE_TEMPORARY_CLOSURE = 'SUTQ - Reinstate Rating after Temporary Closure';
    public static final string RATING_ASSESSMENT_COMPLETE = 'Rating Assessment Complete';   
    public static final string COMPLETED = 'Completed';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //set the scope by defining records
        
        Date todayPlus30Days = date.today().addDays(30);  
        Date todayDate = date.today();
        String query;
        if(test.isRunningTest()){
            query=QuerySTR;
        }
        else{
            query = Label.CLQ_30_Days_Reminder_Query;
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        final String d = EMPTY;
        try{
            recToProcess = true;
            Set<id> clqPrgmIdLst  = new Set<Id>();  
            CLQ_Program__c clqPrgrm;
            //Retrieve Program Ids from the Scope 
            for(SObject s: scope){
                clqPrgrm = (CLQ_Program__c)s;
                clqPrgmIdLst.add(clqPrgrm.id);
            }//end for loop 
            
            System.debug('List of programs' + clqPrgmIdLst.size());
            
            List<CLQ_Program__c> clqPrgLst = new List<CLQ_Program__c>();
            
            
            if(clqPrgmIdLst.size()>0 || clqPrgmIdLst!=null)
            {
                //11982 // 14858 , 14913 , 14917 - Added new RT's.Added record Type name 
                clqPrgLst =  [select id,Recordtype.name,CLQ_Associated_Organization__c,CLQ_Associated_Organization__r.Id,CLQ_Program_Email__c,
                              Rating_Discontinue__c,Rating_Expiration_Date__c,Program_Rating__c,Rating_Effective_Date__c, Rating_Anniversary_Date__c,
                              (SELECT id,Submission_Date1__c,clq_recordtypename__c,CLQ_Transaction_Status__c from Program_Transactions__r 
                               WHERE recordType.developername in ('Quality_Rating_Registration','Ongoing_Quality_Rating_Registration','SUTQ_Change_of_Owner_Registration' , 'SUTQ_Expedited_Registration', 'SUTQ_Reinstate_Rating_after_Temporary_Closure') 
                               AND CLQ_Transaction_Status__c IN ('Submitted','Under Reviewer Review','Returned for Revision','Closed','In Progress',
                                                                 'Closed by System','Resubmitted','Denied','Approved','Approver Review In Progress',
                                                                 'Licensed','Deferral','Pending Approval','Ineligible','Registration Assigned','Return for Revision',
                                                                 'Supervisor Desk Review','Unable to Rate','Onsite Visit Pending','Rating Recommended for Review',
                                                                 'Supervisor On-Site Review','Annual Report Disapproved','Rating Assessment Complete','Completed',
                                                                 'Returned to Reviewer','Cancelled','Application Revised','Closed at Applicant’s Request')
                               AND Submission_Date1__c != null
                               ORDER BY CreatedDate),
                              (Select Id, CLQ_Contact__r.Email from Roles__r 
                               where RecordType.developername = 'Portal_Roles' AND Role_Type__c = 'JFS' 
                               AND CLQ_Contact__r.Email != null AND Portal_Roles__c IN ('Owner', 'Director', 'SUTQ Consultant')) //CR-11200                                
                              from CLQ_Program__c where id=:clqPrgmIdLst]; 
                
                //System.debug('clqPrgLst is ' + clqPrgLst);
                
                list<string> templist=new list<string>{SUTQ_Email_30Day_Renew_Reminder,SUTQ_Email_Tomorrow_Renew_Reminder}; 
                list<EmailTemplate> EmailTempLists;
                if(templist != null){
                	EmailTempLists=[SELECT Id, Body, Subject from EmailTemplate where DeveloperName in :templist];
                }
                EmailTemplate lstEmailTemplates1 = EmailTempLists[0];
                EmailTemplate lstEmailTemplates2 = EmailTempLists[1];
                
                
                // List<String> emailList= new List<String>();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                
                //Dummy contact - technically used only for sending emails - NO functional dependency              
                Contact cnt = [SELECT Id From Contact 
                               Where Email!=null 
                               and Email = 'NOREPLY@TEST.COM' Limit 1];
                Id contactID = cnt.Id;
                
                
                
                
                //Retrieve Org Wide Email Address from OCLQS - used as the "from" email address              
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
                Id orgId;
                if(owea.size() > 0)
                {
                    orgId = owea.get(0).Id;
                }
                
                Map<Id,List<String>> finalMapPTtoEmail = new Map<Id,List<String>>();
                List<CLQ_Program__c> ODEPrograms = new List<CLQ_Program__c>();                
                
                //Get all the ODE programs
                for(CLQ_Program__c prog : clqPrgLst ){
                    if(prog.RecordType.Name == Label.PreSchoolRecType || prog.RecordType.Name == Label.SACCRecType){
                        ODEPrograms.add(prog);
                    }
                }
                
                //Get the send to email address for each program
                if(!ODEPrograms.isEmpty() && ODEPrograms != null){
                    finalMapPTtoEmail =  CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQBatchProg(ODEPrograms);
                }
                
                Integer total30Daycnt = 0 ;
                Integer total1Daycnt = 0 ;
                
                
                for(CLQ_Program__c cp : clqPrgLst)  
                {
                    
                    Date thirtyDaysBefore = cp.Rating_Expiration_Date__c.addDays(-30);
                    Date oneDayBefore = cp.Rating_Expiration_Date__c.addDays(-1);
                    
                    List<CLQ_Program_Transaction__c> prgTransList = new List<CLQ_Program_Transaction__c>();
                    
                    prgTransList = cp.Program_Transactions__r;
                    boolean threeSUTQsCheck = false;
    				
                    if(!prgTransList.isEmpty()){
                        
                        //System.debug('rec Id is ' + prgTransList.get(prgTransList.size()-1).clq_recordtypename__c );
                        String recName = prgTransList.get(prgTransList.size()-1).clq_recordtypename__c ; 
                        
                        if( ( recName == SUTQ_EXPEDITED_REGISTRATION || recName == SUTQ_CHANGE_OWNER_REGISTRATION ||recName == SUTQ_REINSTATE_TEMPORARY_CLOSURE ) && prgTransList.get(prgTransList.size()-1).CLQ_Transaction_Status__c == RATING_ASSESSMENT_COMPLETE ){
                            threeSUTQsCheck = true;
                        }
                    }
                    
                    
                    
                    if(threeSUTQsCheck = true){
                        
                        System.debug('ProgramIDMail'+cp.Id);        
                        String mailTempID = EMPTY;     
                        Boolean isMailReq = false;  
                        
                        if(date.today()==thirtyDaysBefore)
                        {
                            mailTempID = lstEmailTemplates1.Id;
                            isMailReq = true;
                            total30Daycnt ++ ;
                            
                        }
                        else if(date.today()==oneDayBefore)
                        {
                            mailTempID = lstEmailTemplates2.Id;
                            isMailReq = true;
                            total1Daycnt++ ;
                            
                        }
                        
                        //System.debug('is mail Req ' + isMailReq);
                        
                        if(isMailReq)
                        {
                            mails.add(generateEmailToSend(cp,mailTempID,contactID,finalMapPTtoEmail,orgId));
                        }
                    }
                    
                }
                
                if(!mails.isEmpty())
                {
                    boolean previousVal = CLQ_TaskTriggerHandler.BypassTrigger;
                    CLQ_TaskTriggerHandler.BypassTrigger = true;
                    Messaging.sendEmail(mails);
                    CLQ_TaskTriggerHandler.BypassTrigger = previousVal;
                    
                }
                
                
                
            }            
        }
        catch(Exception e) 
        {
            //System.debug('Error Message :: '+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SJ-001.4',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
        String IntLogID = SJ001;
        // Check batch status - IF not COMPLETED then send notification
        AsyncApexJob jobStatus = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                                  from AsyncApexJob where Id = :BC.getJobId()];        
        
        if(jobStatus.Status != COMPLETED || jobStatus.NumberOfErrors > 0)
        {
            Integration_Transaction_Logs.LogBatchMessage(IntLogID,jobStatus.ExtendedStatus,jobStatus.status,jobStatus.TotalJobItems,jobStatus.JobItemsProcessed,jobStatus.NumberOfErrors);   
        } 
        if(!recToProcess)
        {
            Integration_Transaction_Logs.LogBatchMessage(IntLogID,'No Records to Process', 'Success', 0, 0, 0); 
        }
        
    }
    
    //Method to generate mail based on number of days to rating anniversary 
    public Messaging.SingleEmailMessage generateEmailToSend(CLQ_Program__c cp, String mailTemplateID, Id contactID, Map<Id,List<String>> finalMapPTtoEmail, Id orgId)
    {
        //Temproary Email list for testing
        //List<String> tempEmailList = new List<String>();
        List<String> emailList = new List<String>();
        List<String> emailCCList = new List<String>();//CR-11200
        
        if(cp.CLQ_Program_Email__c != null)
        {
            emailList.add(cp.CLQ_Program_Email__c);
            system.debug('Emailid::::'+cp.CLQ_Program_Email__c);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Set reminder template based on number of days from rating anniversary date        
        mail.setTemplateId(mailTemplateID);
        //Any contact or User id of your record         
        mail.setTargetObjectId(contactID);
        
        //If record type is ODE get the send to email address from map        
        if(cp.Recordtype.name == Label.PreSchoolRecType  || cp.Recordtype.name == Label.SACCRecType){
            //System.debug('Final EMail'+ finalMapPTtoEmail.get(cp.Id));
            if(finalMapPTtoEmail.size()!=0 && finalMapPTtoEmail.containsKey(cp.Id)){
                List<String> emailaddress = new List<String>();
                for(String email : finalMapPTtoEmail.get(cp.Id)){
                    emailaddress.add(email);
                }
                //System.debug('EMAILS' + emailaddress); 
                mail.setToAddresses(emailaddress);
            }
        }
        else
        {
            mail.setToAddresses(emailList);
            //CR-11200 Starts
            for(CLQ_Role__c roleObj : cp.Roles__r){
                emailCCList.add(roleObj.CLQ_Contact__r.Email);
            }
            system.debug('emailCCList ----'+emailCCList);
            
            if(!emailCCList.isEmpty()){
                mail.setCcAddresses(emailCCList);
            }
            //CR-11200 Ends              
        }
        mail.setOrgWideEmailAddressId(orgId);
        mail.setWhatId(cp.Id);
        //system.debug('Generate Mail for :::' +cp.Id +'orgId :: '+orgId+ 'mailTemplateID ::'+mailTemplateID+'contactID ::' +contactID);
        return mail;
    }
}