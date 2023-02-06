/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_Day_Annual_InspDueRemndr_BatchT
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Rahul Roy     			03/07/2018      1.0          TFS#14903 : Initial Build 
**************************************************************************************************************/
@isTest(isparallel = true)
private class CLQ_120_Day_Annual_InspDueRemndr_BatchT {
    public boolean recToProcess = false;
    @testSetup
    public static void setExecuteControlSetting()
	{
	CLQ_UnitTestUtilities.setExecuteControlSetting();
	}
	
    static testMethod void testMethod1()
    {
		Test.startTest();
        List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
		CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
		configRecords.add(configRecord);

		CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
		configRecords.add(configRecord1); 
		insert configRecords;
        
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
	    insert accountrecord ;
        
        CLQ_Program__c cp = CLQ_Test_Util.getCLQProgram();
		cp.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Pre School').getRecordTypeId();
		cp.Rating_Effective_Date__c = Date.today();
		cp.CLQ_Associated_Organization__c = accountrecord.id;
		cp.Rating_Anniversary_Date__c = Date.today().addDays(90);
		cp.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
		cp.Program_Rating__c = '3';
		cp.CLQ_Program_Status__c = 'Open';
        cp.CLQ_License_Type__c = 'Continuous';
        cp.Rating_Expiration_Date__c = Date.today().addDays(90);
        cp.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
		CLQ_ProgramTriggerHandler.BypassTrigger = true;
		insert cp;
        CLQ_ProgramTriggerHandler.BypassTrigger = false;
        
        CLQ_120_Day_Annual_InspDueRemndr_Batch T1 = new CLQ_120_Day_Annual_InspDueRemndr_Batch();
        T1.createTask(String.valueOf(cp.id),String.valueOf(cp.CLQ_Licensing_Specialist__c));
        /*
        List<Task> taskRecords = new List<Task>();
        Task task1 = new Task();
        task1.Subject = 'Annual Licensing Inspection Due Reminder';
        task1.Description = 'Please consider this License for Annual Inspection';
        task1.ActivityDate = System.TODAY();
        task1.Status = 'Open';
        task1.Priority = 'Normal';
        taskRecords.add(task1);
    	insert taskRecords;
        */	
        /*
        //CLQ_Inspection__c inspectionOne = new  CLQ_Inspection__c();
        CLQ_Inspection__c inspectionOne = CLQ_UtilityClass.createInspectionrecord('Annual','Full','Approved');
        inspectionOne.CLQ_Visit_Status__c = 'To be Scheduled';
        inspectionOne.CLQ_Use_Rules_Effective_On__c = Date.today();
        //inspectionOne.CLQ_Inspection_Type__c = 'Annual';
        inspectionOne.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        //inspectionOne.Program_Jurisdiction__c = 'ODE';
        inspectionOne.CLQ_Program__c = cp.Id;
        insert inspectionOne;
        //inspectionOne.CLQ_Inspection_Status__c = 'Approved';
        update inspectionOne;
		//insert inspectionOne;  
        
        CLQ_Inspection__c inspectionTwo = new  CLQ_Inspection__c();
        inspectionTwo.CLQ_Visit_Status__c = 'Visit Completed';
        inspectionOne.CLQ_Use_Rules_Effective_On__c = Date.today();
        inspectionTwo.CLQ_Inspection_Type__c = 'Annual';
        inspectionOne.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        //inspectionOne.Program_Jurisdiction__c = 'ODE';
        inspectionTwo.CLQ_Program__c = cp.Id;
        inspectionTwo.CLQ_Scope__c = 'Full';
		insert inspectionTwo;
        */
        List<CLQ_Program__c> progList = new List<CLQ_Program__c>();
        progList = [select id, (select Id,CLQ_Inspection_Type__c from Inspections__r where ((CLQ_Inspection_Type__c IN ('Annual','Provisional') AND Program_Jurisdiction__c = 'JFS') OR (CLQ_Inspection_Type__c = 'Annual' AND Program_Jurisdiction__c = 'ODE'))) FROM CLQ_Program__c WHERE CLQ_Program_Record_Type__c IN ('Child Care Center','Pre School','School Age Child Care') AND CLQ_Program_Status__c IN ('Open','Enforcement') AND CLQ_License_Type__c = 'Continuous' AND CLQ_Licensing_Specialist__c != NULL];
        system.debug('@@RR>>>>'+ progList);
        
			CLQ_120_Day_Annual_InspDueRemndr_Batch b = new CLQ_120_Day_Annual_InspDueRemndr_Batch();
			database.executeBatch(b,10);
			
		Test.stopTest();    
    }
}