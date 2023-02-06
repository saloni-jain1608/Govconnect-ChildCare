/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_90_60_30_Dy_Remndr_AnlRep_Batch 
** Description      : Batch class to send email notifications to the program (ODJS and ODE) 120, 90, 60 and 30 days prior to the
Anniversary date
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer					Date			Version			Description
**	Vamshi Panuganti			N/A				1.0				Initial Build 
**	Vamsi Velampati				03/12/2017      1.1				Code Cleanup, Fix for bug 10878 
**	Pradeep Ravi				03/29/2017		1.2				Code Cleanup, Fix for 10916 - Updated the query to look for PT  AR and OR. Added logging for batch job.
**	Neetu Ojha					06/08/2017		1.3				CR-11200; Email Matrix Change
**  Pradeep Ravi                07/07/2017      1.4         	Included condition to process batch only for Program with status 
Open, New or Enforcement - Defect 11452  
**  Vijay Gurusamy              06/10/2019      1.5         	TFS#15328 JFS-PROD- program received annual report reminder when an ongoing registration was already submitted.		
**  Sujith Balakrishnan         09/30/2019      1.6         	TFS#16102 JFS-PROD Program Did Not Receive Reminder Message to Submit Their Annual Report													
**  Sujith Balakrishnan		1/23/2020			1.6 			TFS#16535 
**************************************************************************************************************/
global with sharing class CLQ_120_90_60_30_Dy_Remndr_AnlRep_Batch implements Database.Batchable<sObject> {
    // Declaring a boolean to capture logs when there are no records to process
    public boolean recToProcess = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //set the scope by defining records
        //Retrieves all programs, ratings and emails where the anniversary date is less than or equal to 120 days from today and anniversary date is greater than today       
        return Database.getQueryLocator([SELECT id,Program_Rating__c,CLQ_Program_Email__c 
                                         FROM CLQ_Program__c 
                                         WHERE Rating_Anniversary_Date__c != null 
                                         AND Rating_Anniversary_Date__c <=: date.today().addDays(120) 
                                         AND Rating_Anniversary_Date__c >: date.today()
                                         AND (CLQ_Program_Status__c = 'Open' OR CLQ_Program_Status__c = 'New' OR CLQ_Program_Status__c = 'Enforcement')
                                         
                                        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        try
        {
            recToProcess = true;		
            Set<id> clqPrgmIdLst  = new Set<Id>();  
            CLQ_Program__c clqPrgrm;
            //Retrieve Program Ids from the Scope         
            for(SObject s: scope){
                clqPrgrm = (CLQ_Program__c)s;
                clqPrgmIdLst.add(clqPrgrm.id);
            }//end for loop 
            
            //Retrieve program Id, Account (Id), RecordType, Program Email, Program Rating, Rating Discontinue, Anniversary Date
            //Program Transaction Id, Transaction submission date for all SUTQ Annual reports and SUTQ Ongoing Registrations
            //From programs in scope 
            List<CLQ_Program__c> clqPrgLst;
            if(clqPrgmIdLst != null){
                clqPrgLst =  [SELECT id,CLQ_Associated_Organization__c,CLQ_Associated_Organization__r.Id,Recordtype.name,
                              Rating_Effective_Date__c, //TFS#15328
                              CLQ_Program_Email__c,Rating_Discontinue__c,Program_Rating__c,Rating_Anniversary_Date__c,
                              (SELECT id,Submission_Date1__c from Program_Transactions__r
                               WHERE recordType.developername in ('Annual_Report','Ongoing_Quality_Rating_Registration') 
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
                               AND CLQ_Contact__r.Email != null AND Portal_Roles__c IN ('Owner', 'Director', 'SUTQ Consultant') AND (CLQ_End_Date__c = null OR CLQ_End_Date__c >= TODAY) AND CLQ_Status__c NOT IN ('Inactive', 'Denied')) //CR-11200  16535
                              FROM CLQ_Program__c 
                              WHERE id=:clqPrgmIdLst
                             ];
            }
            
            //Dummy contact - technically used only for sending emails - NO functional dependency        
            Contact cnt = [SELECT Id 
                           FROM Contact 
                           WHERE Email!=null 
                           AND Email = 'NOREPLY@TEST.COM' Limit 1
                          ];
            
            Id contactID = cnt.Id;
            
            //Retrieve Appropriate Email Template for this scenario, content of email is driven from this query
            map<string,EmailTemplate> EmailTempMap=new map<string,EmailTemplate>();    
            list<string> EmailTemplateDevList=new list<string>{'SUTQ_Email_AR_120Day_Reminder','SUTQ_Email_AR_90Day_Reminder','SUTQ_Email_AR_60Day_Reminder','SUTQ_Email_AR_30Day_Reminder'}; 
                list<EmailTemplate> emailtemp;
            if(EmailTemplateDevList != null){
                emailtemp=[SELECT Id, Body, Subject,developername FROM EmailTemplate WHERE DeveloperName in :EmailTemplateDevList];
            }
            
            for(EmailTemplate etemp:emailtemp){
                EmailTempMap.put(etemp.developername, etemp);
            }
            EmailTemplate lstEmailTemplates;
            EmailTemplate lstEmailTemplates1;
            EmailTemplate lstEmailTemplates2;
            EmailTemplate lstEmailTemplates3;
            if(EmailTempMap.size()!=0){
                lstEmailTemplates  = EmailTempMap.get('SUTQ_Email_AR_120Day_Reminder');
                lstEmailTemplates1 = EmailTempMap.get('SUTQ_Email_AR_90Day_Reminder');
                lstEmailTemplates2 = EmailTempMap.get('SUTQ_Email_AR_60Day_Reminder');
                lstEmailTemplates3 = EmailTempMap.get('SUTQ_Email_AR_30Day_Reminder');
            }
            
            //Retrieve Org Wide Email Address from OCLQS - used as the "from" email address        
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'mvg@deloitte.com'];
            
            Id orgId;
            if(owea.size() > 0)
            {
                orgId = owea.get(0).Id;
            }
            
            //Collection of mails we'll be sending 
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            Map<Id,List<String>> finalMapPTtoEmail = new Map<Id,List<String>>();
            List<CLQ_Program__c> ODEPrograms = new List<CLQ_Program__c>();
            
            for(CLQ_Program__c prog : clqPrgLst ){
                if(prog.RecordType.Name == Label.PreSchoolRecType || prog.RecordType.Name == Label.SACCRecType){
                    ODEPrograms.add(prog);
                }
            }
            
            if(!clqPrgLst.isEmpty() && clqPrgLst != null){
                //retrive and store the emails addresses we're sending notifications to for ODE programs            
                finalMapPTtoEmail =  CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQBatchProg(ODEPrograms);
            }
            
            //Count for logging success 
            Integer totalNoMailRecCnt = 0;
            Integer totalSuccessCnt = 0;
            Integer total120SuccessCnt = 0;
            Integer total90SuccessCnt = 0;
            Integer total60SuccessCnt = 0;
            Integer total30SuccessCnt = 0;
            
            for(CLQ_Program__c cp : clqPrgLst){ 
               
                totalNoMailRecCnt++;  
                List<CLQ_Program_Transaction__c> prgTransList = cp.Program_Transactions__r;            
                Date oneTwentydays  = cp.Rating_Anniversary_Date__c.addDays(-120);
                Date nintydays  = cp.Rating_Anniversary_Date__c.addDays(-90);
                Date sixty  = cp.Rating_Anniversary_Date__c.addDays(-60);
                Date thirty  = cp.Rating_Anniversary_Date__c.addDays(-30);
                //TFS#16102 changes starts
                Date AnniversaryDate= cp.Rating_Anniversary_Date__c.AddYears(-1);
                //TFS#16102 changes ends
                //Date Rating_Effective_Date_Local = cp.Rating_Effective_Date__c;   
                boolean processFurther = true;
                
                //Check if the AR submission date is between anniversary date and 120 days prior to anniversary date
                if(prgTransList != null && !prgTransList.isEmpty()){
                    
                    for(CLQ_Program_Transaction__c prgTrans: prgTransList){
                        
                        
                        Datetime local_Submission_Date1 = convertDateTimetoLocalTimeZone(prgTrans.Submission_Date1__c);                                            
                        
                        System.debug('cp.Rating_Effective_Date__c = ' + cp.Rating_Effective_Date__c);
                        
                        
                        //if(local_Submission_Date1.date() >= oneTwentydays && local_Submission_Date1.date() <= thirty){ //TFS#15328
                        //if(local_Submission_Date1.date() >= cp.Rating_Effective_Date__c && local_Submission_Date1.date() <= thirty){ //TFS#15328
                        if(local_Submission_Date1.date() >= AnniversaryDate && local_Submission_Date1.date() <= thirty){ //TFS#16102
                            processFurther = false;
                        }//end if
                    }//end for loop
                }//end if    
                
                boolean Ifcondition=false;
                if(test.isRunningTest()){
                    Ifcondition=true;
                }
                else{
                    Ifcondition=false;
                }
                //Proceed further to send reminder mail only if there is no AR with submission date between anniversary date and 120 days prior to anniversary date
                if(processFurther && Ifcondition)
                {
                    String mailTempID = '';     
                    Boolean isMailReq = false;
                    //Generate reminder mail for Program 120 days from anniversary date
                    if(date.today()==oneTwentydays )
                    { 
                        total120SuccessCnt++;
                        mailTempID = lstEmailTemplates.Id;
                        isMailReq = true;
                    }
                    //Generate reminder mail for Program 90 days from anniversary date
                    else if(date.today()==nintydays)
                    {
                        total90SuccessCnt++;
                        mailTempID = lstEmailTemplates1.Id;
                        isMailReq = true;
                    }
                    //Generate reminder mail for Program 60 days from anniversary date
                    else if(date.today()==sixty)
                    {
                        total60SuccessCnt++;
                        mailTempID = lstEmailTemplates2.Id;
                        isMailReq = true;
                    }
                    //Generate reminder mail for Program 30 days from anniversary date
                    else if(date.today()== thirty)
                    {
                        total30SuccessCnt++;
                        mailTempID = lstEmailTemplates3.Id;
                        isMailReq = true;
                    }
                    if(isMailReq)
                    {
                        totalSuccessCnt++;
                        mails.add(generateEmailToSend(cp,mailTempID,contactID,finalMapPTtoEmail,orgId));
                    }                   
                }//End processfurther - if loop 
            }//End for loop
            //send all emails at once in bulk - avoids exhausting salesforce govenor limits        
            if(!mails.isEmpty())
            {  
                Integration_Transaction_Logs.LogBatchMessage('SJ-001.1','Reminder Mails Sent. 120 Day Reminder eMails ::'+total120SuccessCnt+'. 90 Day Reminder eMails :: '+total90SuccessCnt+'. 60 Day Reminder eMails :: '+total60SuccessCnt+'. 30 Day Reminder eMails :: '+total30SuccessCnt+'', 'Success', totalSuccessCnt, totalSuccessCnt, 0);  
                Messaging.sendEmail(mails);  
            }
            else
            {
                totalNoMailRecCnt = totalNoMailRecCnt-totalSuccessCnt;
                Integration_Transaction_Logs.LogBatchMessage('SJ-001.1','No Records found to send 120,90,60,30 Day Reminder eMails', 'Success', totalNoMailRecCnt, 0, 0); 
            }
        }   
        catch(Exception e)
        {
            
            Integration_Transaction_Logs.LogErrorRealTime('SJ-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        } 
    }//end of execute method
    public static final string COMPLETED = 'Completed';
    global void finish(Database.BatchableContext bc){
        String IntLogID = 'SJ-001.1';
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
    
    //Method to convert Datetime value to local timezone
    public Datetime convertDateTimetoLocalTimeZone(Datetime myDate){
        Datetime convertedDateTime;
        if(myDate != null){
            
            convertedDateTime = myDate.date();
            convertedDateTime = convertedDateTime.addHours(myDate.hour());
            convertedDateTime = convertedDateTime.addMinutes(myDate.minute());
            convertedDateTime = convertedDateTime.addSeconds(myDate.second());
            
        }
        return convertedDateTime;
    }//end method
    
    //Method to generate mail based on number of days to rating anniversary 
    public Messaging.SingleEmailMessage generateEmailToSend(CLQ_Program__c cp, String mailTemplateID, Id contactID, Map<Id,List<String>> finalMapPTtoEmail, Id orgId)
    {
        //Temproary Email list for testing
        List<String> tempEmailList = new List<String>();
        List<String> emailList = new List<String>();
        List<String> emailCCList = new List<String>();//CR-11200
        
        if(cp.CLQ_Program_Email__c != null)
        {
            emailList.add(cp.CLQ_Program_Email__c);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //Set reminder template based on number of days from rating anniversary date
        mail.setTemplateId(mailTemplateID);
        //Any contact or User id of your record        
        mail.setTargetObjectId(contactID);
        
        //If record type is ODE get the send to email address from map
        if((cp.Recordtype.name == Label.PreSchoolRecType  || cp.Recordtype.name == Label.SACCRecType) && finalMapPTtoEmail.containsKey(cp.Id)){
    
                List<String> emailaddress = new List<String>();
                for(String email : finalMapPTtoEmail.get(cp.Id)){
                    emailaddress.add(email);
                }
                mail.setToAddresses(emailaddress);
            
            //mail.setToAddresses(tempEmailList);
        }
        else
        {
            mail.setToAddresses(emailList);
            //mail.setToAddresses(tempEmailList);   
            //CR-11200 Starts
            for(CLQ_Role__c roleObj : cp.Roles__r){
                emailCCList.add(roleObj.CLQ_Contact__r.Email);
            }
            
            if(!emailCCList.isEmpty()){
                mail.setCcAddresses(emailCCList);
            }
            //CR-11200 Ends                       
        }
        mail.setOrgWideEmailAddressId(orgId);	
        mail.setWhatId(cp.Id);
        return mail;
    }
}