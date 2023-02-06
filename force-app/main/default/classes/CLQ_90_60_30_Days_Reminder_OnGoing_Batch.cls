/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_90_60_30_Days_Reminder_OnGoing_Batch 
** Description      : Batch class to send email notifications to the program (ODJS and ODE) 180, 150, 120 and 90 days prior to the
                      Anniversary date
** Version          : 1.4
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date				Version			Description
**	Vamshi Panuganti		N/A 				1.0				Initial Build 
**	Pradeep Ravi			03/31/2017			1.1				Code Cleanup, Fix for 10916 - Updated the query to look for PT IR and OR. Added logging for batch job. 
**	Neetu Ojha				06/08/2017			1.2				CR-11200; Email Matrix Change
**  Pradeep Ravi            07/07/2017          1.3         	Included condition to process batch only for Program with status 
															    Open, New or Enforcement - Defect 11452  
**	Soufin Rahimeen			03/19/2018			1.4				TFS#11982 added logic to check for rating effective date
**  Rohit Gowrishetty		11/27/218			1.5				CR#14858 - SUTQ Expdited Rating
**  Sujith Balakrishnan		1/23/2020			1.6 			TFS#16535 
**  Sujith Balakrishnan      04/03/2020         1.7              TFS#16378 Stopping missed deadline when when OR registration is submitted
***************************************************************************************************************/
global class CLQ_90_60_30_Days_Reminder_OnGoing_Batch implements Database.Batchable<sObject> {
    // Declaring a boolean to capture logs when there are no records to process
    public boolean recToProcess = false;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //set the scope by defining records
        //Retrieves all programs, ratings and emails where the anniversary date is less than or equal to 180 days from today and anniversary date is greater than 90       
        Date todayPlus180Days = date.today().addDays(180);  
        Date todayDate = date.today();
        
        String query = Label.CLQ_90_60_30_Days_Reminder_Query;
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        ///List<CLQ_Program__c> clqPrgmLst = new List<CLQ_Program__c>();
        // List<CLQ_Program__c> updateCLQPrgmLst = new List<CLQ_Program__c>();
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
            
            List<CLQ_Program__c> clqPrgLst = new List<CLQ_Program__c>();
            
            //Retrieve ODE program Id, Account (Id), RecordType, Program Email, Program Rating, Rating Discontinue, Anniversary Date
            //Program Transaction Id, Transaction submission date for all SUTQ Annual reports and SUTQ Ongoing Registrations
            //From programs in scope 
            if(clqPrgmIdLst.size()>0 || clqPrgmIdLst!=null)
            {
            	//11982 // 14858 , 14913 , 14917 - Added new RT's.Added record Type name //14858 - Addd CLQ_Transaction_Status__c
                clqPrgLst =  [select id,Recordtype.name,CLQ_Associated_Organization__c,CLQ_Associated_Organization__r.Id,CLQ_Program_Email__c,
                              Rating_Discontinue__c,Rating_Expiration_Date__c,Program_Rating__c,Rating_Effective_Date__c, Rating_Anniversary_Date__c,
                              (SELECT id,Submission_Date1__c,clq_recordtypename__c ,CLQ_Transaction_Status__c from Program_Transactions__r 
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
												AND CLQ_Contact__r.Email != null AND Portal_Roles__c IN ('Owner', 'Director', 'SUTQ Consultant') AND (CLQ_End_Date__c = null OR CLQ_End_Date__c >= TODAY) AND CLQ_Status__c NOT IN ('Inactive', 'Denied')) //CR-11200      //16535                          
                              from CLQ_Program__c where id=:clqPrgmIdLst];
                // List<String> emailList= new List<String>();
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                
                //Dummy contact - technically used only for sending emails - NO functional dependency              
                Contact cnt = [SELECT Id From Contact 
                               Where Email!=null 
                               and Email = 'NOREPLY@TEST.COM' Limit 1];
                Id contactID = cnt.Id;

                //Retrieve Appropriate Email Template for this scenario, content of email is driven from this query                 
                List<EmailTemplate> lstEmailTemplates1 = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'SUTQ_Email_90Day_Renew_Reminder'];
                List<EmailTemplate> lstEmailTemplates2 = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'SUTQ_Email_60Day_Renew_Reminder'];
                List<EmailTemplate> lstEmailTemplates3 = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'SUTQ_Email_30Day_Renew_Reminder'];
                List<EmailTemplate> lstEmailTemplates4 = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'SUTQ_Email_Tomorrow_Renew_Reminder'];
                
                
                // 14858 - Adding new queries to get the email templates and settle them up in a map 
                Map<String , Id > mapEmailTemplates = new Map <String , Id > ();
                List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject , DeveloperName from EmailTemplate where DeveloperName IN ( 'SUTQ_Email_60Day_Renew_Reminder_Expedited',
                                                                                                                             'SUTQ_Email_60Day_Renew_Reminder_COO' , 
                                                                                                                             'SUTQ_Email_60Day_Renew_Reminder_RR' , 
                                                                                                                             'SUTQ_Email_30Day_Renew_Reminder_Expedited' , 
                                                                                                                             'SUTQ_Email_30Day_Renew_Reminder_COO' , 
                                                                                                                             'SUTQ_Email_30Day_Renew_Reminder_RR' , 
                                                                                                                             'SUTQ_Email_1Day_Renew_Reminder_Expedited' , 
                                                                                                                             'SUTQ_Email_1Day_Renew_Reminder_COO' , 
                                                                                                                             'SUTQ_Email_1Day_Renew_Reminder_RR' )];
                
                for(EmailTemplate em: lstEmailTemplates){
                    mapEmailTemplates.put(em.DeveloperName , em.Id);
                }
                
                //Retrieve Org Wide Email Address from OCLQS - used as the "from" email address              
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
                Id orgId;
                if(owea.size() > 0)
                {
                    orgId = owea.get(0).Id;
                }           
                
                //14858 - Ends
                
                Date oneEightydays;
                Date oneFiftydays;
                Date oneTwentydays;
                Date nintyDays;
                Date ratingEffectiveOneEightyDays;//11982
                
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
                System.debug('LIST OF PROG'+ clqPrgLst);
                
                //Count for logging success 
                Integer totalNoMailRecCnt = 0;
                Integer totalSuccessCnt = 0;
                Integer total180SuccessCnt = 0;
                Integer total150SuccessCnt = 0;
                Integer total120SuccessCnt = 0;
                Integer total90SuccessCnt = 0;
                
                Integer total60SuccessCnt = 0; //14858
                Integer total30SuccessCnt = 0; //14858
                Integer total1SuccessCnt = 0; //14858

                for(CLQ_Program__c cp : clqPrgLst)  
                {    
                    totalNoMailRecCnt++;
                    System.debug('progId'+ cp.id);
                    //List<CLQ_Program_Transaction__c> cptLst = cp.Program_Transactions__r;
                    oneEightydays  = cp.Rating_Expiration_Date__c.addDays(-180);
                    //ratingEffectiveOneEightyDays = cp.Rating_Effective_Date__c.addDays(180); //11982 16357
                    ratingEffectiveOneEightyDays = cp.Rating_Effective_Date__c; // 16357
                    oneFiftydays  = cp.Rating_Expiration_Date__c.addDays(-150);
                    oneTwentydays  = cp.Rating_Expiration_Date__c.addDays(-120);
                    nintyDays  = cp.Rating_Expiration_Date__c.addDays(-91);
                    
                    Date sixtyDaysBefore = cp.Rating_Expiration_Date__c.addDays(-60);//14858
                    Date thirtyDaysBefore = cp.Rating_Expiration_Date__c.addDays(-30);//14858
                    Date oneDayBefore = cp.Rating_Expiration_Date__c.addDays(-1); //14858
                    
                    List<String> emailList= new List<String>();
                    List<CLQ_Program_Transaction__c> prgTransList = cp.Program_Transactions__r;                 
                    boolean processFurther = true;
                    
                    //14858 - Check if the last PT is from three SUTQ's and are approved - This implies that rating came from these three SUTQ's   
                    boolean threeSUTQsCheck = false;
                    String recName ; //14858
                    
                    
                    //Check if the AR submission date is between anniversary date and 120 days prior to anniversary date
                    if(prgTransList != null && !prgTransList.isEmpty()){
                        
                        //14858 - Starts
                        System.debug('rec Name is ' + prgTransList.get(prgTransList.size()-1).clq_recordtypename__c );
                    	recName = prgTransList.get(prgTransList.size()-1).clq_recordtypename__c ; 
                    	if( ( recName == 'SUTQ - Expedited Registration' || recName == 'SUTQ - Change of Owner Registration' ||recName == 'SUTQ - Reinstate Rating after Temporary Closure' ) && prgTransList.get(prgTransList.size()-1).CLQ_Transaction_Status__c == 'Rating Assessment Complete' ){
                        	threeSUTQsCheck = true;
                    	}
                        //14858 - Ends
                        //
                        for(CLQ_Program_Transaction__c prgTrans: prgTransList){
                            String recordType = prgTrans.clq_recordtypename__c ;
                            
                            
                            //14858Skipping this logic if the PTs are from exp/COO/RR
                            if(recordType != 'SUTQ - Expedited Registration' && recordType != 'SUTQ - Change of Owner Registration' && recordType != 'SUTQ - Reinstate Rating after Temporary Closure'  ){
                                
                                System.debug('prgTrans.Submission_Date1__c = ' +prgTrans.Submission_Date1__c);
                                Datetime local_Submission_Date1 = convertDateTimetoLocalTimeZone(prgTrans.Submission_Date1__c);
                                System.debug('local_Submission_Date1 = ' + local_Submission_Date1);
                                //11982 added condition to check rating effective date
                                if( (local_Submission_Date1.date() >= oneEightydays || local_Submission_Date1.date() >= ratingEffectiveOneEightyDays) && local_Submission_Date1.date() <= nintyDays){
                                    processFurther = false;
                                    System.debug('In processFurther piece');
                                }//end if                                
                            }

                        
                        }//end for loop
                    }//end if    
                    
                    System.debug('Three stuq check is' + threeSUTQsCheck );
                    
                    if(processFurther)
                    {
                        System.debug('ProgramIDMail'+cp.Id);        
                        String mailTempID = '';     
                        Boolean isMailReq = false;                    
                        if(date.today()==nintyDays)
                        {
                            mailTempID = lstEmailTemplates1[0].Id;
                            isMailReq = true;
                            total180SuccessCnt++;
                        }
                        else if(date.today()==sixtyDaysBefore)
                        {
                            mailTempID = lstEmailTemplates2[0].Id;
                            isMailReq = true;
                            total150SuccessCnt++;                        
                        }
                        else if(date.today()==thirtyDaysBefore && threeSUTQsCheck == false)
                        {
                            mailTempID = lstEmailTemplates3[0].Id;
                            isMailReq = true; 
                            total120SuccessCnt++;                       
                        }
                        else if(date.today()==oneDayBefore && threeSUTQsCheck == false )
                        {
                            mailTempID = lstEmailTemplates4[0].Id;
                            isMailReq = true;
                            total90SuccessCnt++;
                        }
                        else if(date.today()==sixtyDaysBefore &&  threeSUTQsCheck == true)  // 14858 - Sixty day Reminder
                        {
                           if(recName == 'SUTQ - Expedited Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_60Day_Renew_Reminder_Expedited');
                            }else if (recName == 'SUTQ - Change of Owner Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_60Day_Renew_Reminder_COO');
                            }else if (recName == 'SUTQ - Reinstate Rating after Temporary Closure'){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_60Day_Renew_Reminder_RR');
                            }
                            isMailReq = true;
                            total60SuccessCnt ++ ;
                            
                        }
                        else if(date.today()==thirtyDaysBefore &&  threeSUTQsCheck == true) // 14858 - 30 day Reminder
                        {
                            if(recName == 'SUTQ - Expedited Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_30Day_Renew_Reminder_Expedited');
                            }else if (recName == 'SUTQ - Change of Owner Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_30Day_Renew_Reminder_COO');
                            }else if (recName == 'SUTQ - Reinstate Rating after Temporary Closure'){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_30Day_Renew_Reminder_RR');
                            }
                            isMailReq = true;
                            total30SuccessCnt ++ ;
                        }
                        else if(date.today()==oneDayBefore && threeSUTQsCheck == true ) // 1 day Reminder
                        {
                            if(recName == 'SUTQ - Expedited Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_1Day_Renew_Reminder_Expedited');
                            }else if (recName == 'SUTQ - Change of Owner Registration' ){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_1Day_Renew_Reminder_COO');
                            }else if (recName == 'SUTQ - Reinstate Rating after Temporary Closure'){
                                mailTempID = mapEmailTemplates.get('SUTQ_Email_1Day_Renew_Reminder_RR');
                            }
                            isMailReq = true;
                            total1SuccessCnt ++ ;                      
                        } 
                       
                        if(isMailReq)
                        {
                            totalSuccessCnt++;
                            mails.add(generateEmailToSend(cp,mailTempID,contactID,finalMapPTtoEmail,orgId));
                        }                    
                    }
                }// end for loop
                if(!mails.isEmpty())
                {
                    boolean previousVal = CLQ_TaskTriggerHandler.BypassTrigger;
                    CLQ_TaskTriggerHandler.BypassTrigger = true;
                    Messaging.sendEmail(mails);
                    CLQ_TaskTriggerHandler.BypassTrigger = previousVal;
                    Integration_Transaction_Logs.LogBatchMessage('SJ-001.4','Reminder Mails Sent. 180 Day Reminder eMails ::'+total180SuccessCnt+'. 150 Day Reminder eMails :: '+total150SuccessCnt+'. 120 Day Reminder eMails :: '+total120SuccessCnt+'. 90 Day Reminder eMails :: '+total90SuccessCnt+'', 'Success', totalSuccessCnt, totalSuccessCnt, 0);
                }
                else
                {
                    totalNoMailRecCnt = totalNoMailRecCnt-totalSuccessCnt;                    
                    Integration_Transaction_Logs.LogBatchMessage('SJ-001.4','No Records found to send reminder eMails', 'Success', totalNoMailRecCnt, 0, 0);             
                }
            }
        }
        catch(Exception e) 
        {
            System.debug('Error Message :: '+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SJ-001.4',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    global void finish(Database.BatchableContext bc){
       system.debug('>>>>FINISHED');
        String IntLogID = 'SJ-001.4';
        // Check batch status - IF not COMPLETED then send notification
        AsyncApexJob jobStatus = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                                        from AsyncApexJob where Id = :BC.getJobId()];        
        
        if(jobStatus.Status != 'Completed' || jobStatus.NumberOfErrors > 0)
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
            System.debug('myDate value passed in:' + myDate);
            
            convertedDateTime = myDate.date();
            convertedDateTime = convertedDateTime.addHours(myDate.hour());
            convertedDateTime = convertedDateTime.addMinutes(myDate.minute());
            convertedDateTime = convertedDateTime.addSeconds(myDate.second());
            
            System.Debug('Converted Time: ' + convertedDateTime);
        }
        return convertedDateTime;
    }//end method
    
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
            System.debug('Final EMail'+ finalMapPTtoEmail.get(cp.Id));
            if(finalMapPTtoEmail.containsKey(cp.Id)){
                List<String> emailaddress = new List<String>();
                for(String email : finalMapPTtoEmail.get(cp.Id)){
                    emailaddress.add(email);
                }
                System.debug('EMAILS' + emailaddress); 
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
        system.debug('Generate Mail for :::' +cp.Id +'orgId :: '+orgId+ 'mailTemplateID ::'+mailTemplateID+'contactID ::' +contactID);
        return mail;
    }
}