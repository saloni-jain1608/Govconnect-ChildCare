/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_Day_Annual_InspDueRemndr_Batch 
** Description      : Batch class to create task(Annual Licensing Inspection Due Reminder) 120 days prior to 30th June
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer					Date			Version			Description
**	Rahul Roy       			03/04/2019      1.0				TFS#14903 : Initial Build  
**************************************************************************************************************/
global with sharing class CLQ_120_Day_Annual_InspDueRemndr_Batch implements Database.Batchable<sObject> {
    // Declaring a boolean to capture logs when there are no records to process
    public static final String IntLogID = 'SJ-001.5';
    public static final String COMPLETED = 'Completed';
    public static final string SUBJECT = 'Annual Licensing Inspection Due Reminder';
    public static final string DESCRIPTION = 'Please consider this License for Annual Inspection';
    public static final string STATUS = 'Open';
    public static final string PRIORITY = 'Normal';
    global Database.QueryLocator start(Database.BatchableContext BC){
		
        //set the scope by defining records
        //Retrieves all programs, ratings and emails where the anniversary date is less than or equal to 180 days from today and anniversary date is greater than 90       
        Date todayPlus180Days = date.today().addDays(180);  
        Date todayDate = date.today();
        
        String query = Label.CLQ_90_60_30_Days_Reminder_Query;
        
        return Database.getQueryLocator(query);
    }
	
	global void execute(Database.BatchableContext bc, List<CLQ_Program__c> scope){
	
		List<Task> lstTasktoInsert = new List<Task>();

		for (CLQ_Program__C program: scope){
           system.debug('@@RR scope'+ scope);
           system.debug('@@RR program.Inspection'+program.Inspections__r.size());
                if( program.Inspections__r.IsEmpty() ){
            		//create task
					Task taskObj = createTask(program.Id, program.CLQ_Licensing_Specialist__c);
					lstTasktoInsert.add(taskObj);
            	}  
        }
		
		if(!lstTasktoInsert.isEmpty())
        {
        	try {
            	insert lstTasktoInsert;
            	}catch(Exception e){
                system.debug('Exception::'+e);
                Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_AnswerTriggerHandler');
            }
        }             
	}
	
	global void finish(Database.BatchableContext bc){
        boolean recToProcess = false;
        system.debug('>>>>JOB FINISHED');
        //String IntLogID = 'SJ-001.5';
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
    @TestVisible
    private Task createTask(String programId, String licensingReviewerId){
        
        Task t = new Task();
        t.Subject = SUBJECT;
        t.Description = DESCRIPTION;
        //t.Type = 'Outbound Call';
        t.Status = STATUS;
        t.Priority = PRIORITY;
        t.ActivityDate= Date.newInstance(System.TODAY().year(), 06, 30);
        t.WhatId = programId;
        t.OwnerId = licensingReviewerId;
        t.CLQ_Program__c = programId;
        return t;
    }
	
}