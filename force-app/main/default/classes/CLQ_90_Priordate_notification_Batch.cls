/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_90_Priordate_notification_Batch 
** Description      : Batch class to Send program email notification 90 days from expiration date
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer			Date			Version		Description
**	Pradeep Ravi		04/04/2017		1.1			Code Cleanup, Fix for 10916 - Updated the query to look for PT SUTQ IR and OR. Added logging for batch job. 
**	Neetu Ojha			06/08/2017		1.2			CR-11200; Email Matrix Change
**  Pradeep Ravi        07/07/2017      1.3         Included condition to process batch only for Program with status 
												    Open, New or Enforcement - Defect 11452  
**  Sujith Balakrishnan 04/03/2020      1.4         TFS#16356,16357 Stopping missed deadline when when expedited registration is submitted
**************************************************************************************************************/
global with sharing class CLQ_90_Priordate_notification_Batch implements Database.Batchable<sObject>{
    // Declaring a boolean to capture logs when there are no records to process
    public boolean recToProcess = false;
    public static final String completed = 'Completed';
    public static final String Newstring = 'New';
    public static final String Enforcement = 'Enforcement';
    public static final String Open = 'Open';
    public static Set<string> recordType_developername_set = new Set<String>{'Quality_Rating_Registration','Ongoing_Quality_Rating_Registration'};
    public static final String Portal_Roles = 'Portal_Roles';
    public static final String JFS = 'JFS';
    public static Set<string> Portal_Roles_Set = new Set<String>{'Owner', 'Director', 'SUTQ Consultant'};  
    public static final String SUTQ = 'SUTQ_Email_Missed_Ongoing_Reg_Filing_Deadline';   
    public static final String SJ = 'SJ-001.3';
    public static final String email1 = 'NOREPLY@TEST.COM';
    public static final String email2 = 'mvg@deloitte.com';
    public static final String LogBatchMessage1 = 'Reminder Mails Sent';
    public static final String LogBatchMessage2 = 'No Records found to send reminder eMails';
    public static final String LogBatchMessage3 = 'No Records to Process';
    public static final String success = 'Success';
    public static final String cause = 'Cause:';
    public static final String line = 'Line:'; 
    public static List<CLQ_90_Priordate_notification_Batch__mdt> CLQ_90_Priordate_notification_BatchList = [Select label from CLQ_90_Priordate_notification_Batch__mdt];
    
    global Database.QueryLocator start(Database.BatchableContext BC)
	{
        //set the scope by defining records
        //Retrieves all programs, ratings and emails where the Rating expiration date is equal to 90 days from today and expiration date        
		return Database.getQueryLocator([Select id,Program_Rating__c,CLQ_Program_Email__c from CLQ_Program__c
		        						 where Rating_Expiration_Date__c != null  
		        						 and Rating_Expiration_Date__c =: date.today().addDays(89)
										 AND (CLQ_Program_Status__c = :Open OR CLQ_Program_Status__c = :Newstring OR CLQ_Program_Status__c = :Enforcement)
										 ]
										 );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
    	try
    	{	
            Set<String> CLQ_Transaction_Status_Set = new Set<String>();
            for(CLQ_90_Priordate_notification_Batch__mdt mdt : CLQ_90_Priordate_notification_BatchList){
                CLQ_Transaction_Status_Set.add(mdt.label);
            }
            recToProcess = true;		
			List<CLQ_Program__c> clqPrgmLst = new List<CLQ_Program__c>();
			List<CLQ_Program__c> updateCLQPrgmLst = new List<CLQ_Program__c>();
			Set<id> clqPrgmIdLst  = new Set<Id>();  

	        //Retrieve Program Ids from the Scope 		
			for(SObject s: scope){
				CLQ_Program__c clqPrgrm = (CLQ_Program__c)s;
				clqPrgmIdLst.add(clqPrgrm.id);
			}//end for loop 

			List<CLQ_Program__c> clqPrgLst = new List<CLQ_Program__c>();

	        //Retrieve ODE program Id,CLQ_Associated_Organization__c,CLQ_Associated_Organization__r.Id,Recordtype.name,CLQ_Program_Email__c,
	        //Rating_Discontinue__c,Program_Rating__c,Rating_Expiration_Date__c, Rating_Anniversary_Date__c,Rating_Effective_Date__c,
	        //Program Transaction Id, Transaction submission date for all SUTQ Annual reports and SUTQ Ongoing Registrations
	        //From programs in scope 
			if(clqPrgmIdLst.size() >0 || clqPrgmIdLst != null)
			{
				clqPrgLst =  [select id,CLQ_Associated_Organization__c,CLQ_Associated_Organization__r.Id,Recordtype.name,
							  CLQ_Program_Email__c,Rating_Discontinue__c,Program_Rating__c,Rating_Expiration_Date__c,
							  Rating_Anniversary_Date__c,Rating_Effective_Date__c,
							  (select id,Submission_Date1__c,CLQ_Transaction_Status__c 
							   from Program_Transactions__r 
							   where recordType.developername 
							   in :recordType_developername_set
							   AND CLQ_Transaction_Status__c 
							   IN  : CLQ_Transaction_Status_Set 
	                          AND Submission_Date1__c != null
	                          ORDER BY CreatedDate),
	                          (Select Id, CLQ_Contact__r.Email from Roles__r 
												where RecordType.developername = :Portal_Roles AND Role_Type__c = :JFS 
												AND CLQ_Contact__r.Email != null AND Portal_Roles__c IN :Portal_Roles_Set ) //CR-11200  
							  from CLQ_Program__c 
							  where id=:clqPrgmIdLst];

	        	//Retrieve Org Wide Email Address from OCLQS - used as the "from" email address   
				OrgWideEmailAddress[] owea = [select Id 
											  from OrgWideEmailAddress 
											  where Address = :email2];

	        	//Dummy contact - technically used only for sending emails - NO functional dependency    										  
				Contact cnt = [SELECT Id 
							   From Contact 
							   Where Email!=null 
							   and Email = :email1 Limit 1];			

	        	//Retrieve Appropriate Email Template for this scenario, content of email is driven from this query     
				List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where 
													   DeveloperName = :SUTQ];	

				//Collection of mails we'll be sending 
	        	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();												   					   							  
				Map<Id,List<String>> finalMapPTtoEmail = new Map<Id,List<String>>();
				List<CLQ_Program__c> ODEPrograms = new List<CLQ_Program__c>();

	            //Get all the ODE programs			
				for(CLQ_Program__c prog : clqPrgLst )
				{
					if(prog.RecordType.Name == Label.PreSchoolRecType || prog.RecordType.Name == Label.SACCRecType)
					{
						ODEPrograms.add(prog);
					}
				}//End of loop

	            //Get the send to email address for each program			
				if(!ODEPrograms.isEmpty() && ODEPrograms != null)
				{
					finalMapPTtoEmail =  CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQBatchProg(ODEPrograms);
				}

                //Count for logging success 
                Integer totalNoMailRecCnt = 0;
                Integer totalSuccessCnt = 0;

				for(CLQ_Program__c cp : clqPrgLst)  
				{    
					totalNoMailRecCnt++;
					List<CLQ_Program_Transaction__c> cptLst = cp.Program_Transactions__r;
					//Date strDate  = cp.Rating_Effective_Date__c.addDays(180);
					// Date endDate = cp.Rating_Expiration_Date__c.addDays(-90);
					//boolean flag = false; 

					//Start date 180 day after Rating Effective date
					//Date strDate  = cp.Rating_Effective_Date__c.addDays(180);//16357
                    Date strDate  = cp.Rating_Effective_Date__c;//16357
					//Start date 90 days prior to Expiration date				
					Date endDate = cp.Rating_Expiration_Date__c.addDays(-89);

	            	boolean processFurther = false;
	                //Check if the AR/OR submission date is between 180 days after rating effective date and 90 days before Rating expiration date            	
					if(cptLst.size()> 0 && !cptLst.isEmpty()){
						for(CLQ_Program_Transaction__c cpt: cptLst)
						{
							Datetime local_Submission_Date1 = convertDateTimetoLocalTimeZone(cpt.Submission_Date1__c);
							//Check if PT submission is between 180 days after rating effective date and 90 days before Rating expiration date
							if(local_Submission_Date1.date() >= strDate && local_Submission_Date1.date() <= endDate)
							{
	                        	processFurther = true;
						    }
						}
					}
                    else
                        processFurther=true;//16356
					if(!processFurther)
					{
						List<String> emailList= new List<String>(); 
						List<String> emailCCList = new List<String>();//CR-11200
						//List<String> emailaddress = new List<String>();
		                List<String> tempEmailList = new List<String>();
		                tempEmailList.add('mvg@deloitte.com');  					
						if(cp.CLQ_Program_Email__c != null)
						{
							emailList.add(cp.CLQ_Program_Email__c);
						}
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						mail.setTemplateId(lstEmailTemplates[0].Id);               
						mail.setSaveAsActivity(true);
						mail.setTargetObjectId(cnt.ID);// Any contact or User id of your record
	        			//If record type is ODE get the send to email address from map   					
						if(cp.Recordtype.name == Label.PreSchoolRecType  || cp.Recordtype.name == Label.SACCRecType)
						{
					            if(finalMapPTtoEmail.containsKey(cp.Id)){
				                List<String> emailaddress = new List<String>();
				                for(String email : finalMapPTtoEmail.get(cp.Id)){
				                    emailaddress.add(email);
				                }
				                mail.setToAddresses(tempEmailList);
				            }
				            mail.setToAddresses(tempEmailList);
				        }
				        else
				        {
				            mail.setToAddresses(tempEmailList);
				            //CR-11200 Starts
				            for(CLQ_Role__c roleObj : cp.Roles__r){
				            	emailCCList.add(roleObj.CLQ_Contact__r.Email);
				            }
				            
				            if(!emailCCList.isEmpty()){
				            	mail.setCcAddresses(emailCCList);
				            }
				            //CR-11200 Ends 				            
				        }
						if ( owea.size() > 0 ) 
						{
							mail.setOrgWideEmailAddressId(owea.get(0).Id);
						}
						mail.setWhatId(cp.id); // Enter your record Id whose merge field you want to add in template
						mails.add(mail);
						totalSuccessCnt++;
					}//End if reminder mails are to be sent
				}//End loop for programs
				/*if(updateCLQPrgmLst != null && !updateCLQPrgmLst.isEmpty())
				update updateCLQPrgmLst; */
				//Debug Printing below
				//End debug printing
				//send all emails at once in bulk - avoids exhausting salesforce govenor limits
				if(!mails.isEmpty())
				{  
					Messaging.sendEmail(mails);					
					Integration_Transaction_Logs.LogBatchMessage(SJ,LogBatchMessage1, success, totalSuccessCnt, totalSuccessCnt, 0);             
				}
				else
				{
					totalNoMailRecCnt = totalNoMailRecCnt-totalSuccessCnt; 
					Integration_Transaction_Logs.LogBatchMessage(SJ,LogBatchMessage2, success, totalNoMailRecCnt, 0, 0); 
				}
			}//End if program list not null  
		}
        catch(Exception e)
        {
            Integration_Transaction_Logs.LogErrorRealTime(SJ,e.getMessage()  ,cause + e.getCause(), line +e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }      
    }    
	
    global void finish(Database.BatchableContext bc)
	{
        String IntLogID = SJ;
        // Check batch status - IF not COMPLETED then send notification
        AsyncApexJob jobStatus = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                                        from AsyncApexJob where Id = :BC.getJobId()];        
        
        if(jobStatus.Status != completed || jobStatus.NumberOfErrors > 0)
        {
            Integration_Transaction_Logs.LogBatchMessage(IntLogID,jobStatus.ExtendedStatus,jobStatus.status,jobStatus.TotalJobItems,jobStatus.JobItemsProcessed,jobStatus.NumberOfErrors);   
        }
        if(!recToProcess)
        {
            Integration_Transaction_Logs.LogBatchMessage(IntLogID,LogBatchMessage3, success, 0, 0, 0); 
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
}