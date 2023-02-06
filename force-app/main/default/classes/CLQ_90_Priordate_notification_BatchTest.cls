/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_90_Priordate_notification_BatchTest
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_90_Priordate_notification_BatchTest {
    public static final string EMPTY = '';
	@testSetup //Added method for Task - 11615
	public static void setExecuteControlSetting()
	{
	CLQ_UnitTestUtilities.setExecuteControlSetting();
	}
    	@IsTest
        static void testProgramUpdateBatch()
  {
      system.runAs(new user(ID = UserInfo.getUserID())){
        
    	Test.startTest();  
    	CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
      if(configRecord.name != null || configRecord.name !=EMPTY){
          insert configRecord; 
      }
    	
    	system.AssertEquals('FCC - Type B Home', configRecord.name,'Testing' );
    	Contact cont = new Contact();
    	cont.FirstName = 'Test';
    	cont.LastName = 'Test';
    	cont.Email = 'NOREPLY@TEST.COM';
      if(cont.LastName != null || cont.LastName != EMPTY){
          insert cont;
      }
    	
    	system.AssertEquals('Test', cont.LastName ,'Testing');

    	Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
    	insert accountrecord ;

    	CLQ_Role__c role2 = new CLQ_Role__c();
    	role2.CLQ_Contact__c = cont.id;
    	role2.Role_Type__c = 'ODE';
    	role2.Portal_Roles__c = 'OCLQSAdministrator';
    	role2.CLQ_Organization__c = accountrecord.id;
    	role2.Secondary_Role__c = 'OCLQSPS';
    	role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
    	insert role2; 

    	//RecordType objOnGoingRegRec = [select id,name from RecordType where sobjectType = 'CLQ_Program_Transaction__c' and developername = 'Annual_Report'];  
    	CLQ_Program__c cp = CLQ_Test_Util.getCLQProgram();
    	cp.Rating_Effective_Date__c = Date.today();
    	cp.Rating_Expiration_Date__c = date.today().adddays(89);
    	//cp.Rating_Anniversary_Date__c = Date.today().addDays(90);
    	cp.CLQ_License_Registration_Status__c = 'Licensed';
    	cp.CLQ_License_Issue_Date__c = date.today().adddays(-190);
    	cp.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
    	cp.Program_Rating__c = '3';
        cp.CLQ_Program_Status__c = 'Open';  		
    	//cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
    	CLQ_ProgramTriggerHandler.BypassTrigger = true;
      if(cp.CLQ_Program_Email__c !=null || cp.CLQ_Program_Email__c != EMPTY){
          insert cp;
      }
    	
    	system.AssertEquals('NOREPLY@TEST.COM', cp.CLQ_Program_Email__c ,'Testing');
    	CLQ_Program__c cp1 = CLQ_Test_Util.getCLQProgram();
    	cp1.Rating_Effective_Date__c = Date.today().adddays(-191);
    	cp1.Rating_Expiration_Date__c = date.today().adddays(89);
    	cp1.CLQ_License_Registration_Status__c = 'Licensed';
    	cp1.CLQ_License_Issue_Date__c = date.today().adddays(-180);
    	//cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
    	cp1.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
    	cp1.Program_Rating__c = '3';
        cp1.CLQ_Program_Status__c = 'Open';  		
    	//cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
    	CLQ_ProgramTriggerHandler.BypassTrigger = true;
      if(cp1.CLQ_Program_Email__c !=null || cp1.CLQ_Program_Email__c != EMPTY){
          insert cp1; 
      }
    	
    	system.AssertEquals('NOREPLY@TEST.COM', cp1.CLQ_Program_Email__c ,'Testing'); 
    	CLQ_Program_Transaction__c pt =  CLQ_Test_Util.getCLQProgramTransaction();
    		pt.CLQ_Program__c = cp1.id;
    		pt.CLQ_Transaction_Status__c = 'Under Reviewer Review';
    		pt.RecordTypeId =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
    		pt.Submission_Date1__c = cp1.Rating_Effective_Date__c.addDays(200);
    		clq_program_TransactionTriggerHandler.BypassTrigger = true;
      if(pt.CLQ_Transaction_Status__c != null || pt.CLQ_Transaction_Status__c != EMPTY){
          INSERT PT;
      }
		
		
		CLQ_Program__c cp2 = CLQ_Test_Util.getCLQProgram();
		cp2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
		cp2.CLQ_Associated_Organization__c = accountrecord.id;
		cp2.Rating_Effective_Date__c = Date.today().adddays(-190);
		cp2.Rating_Expiration_Date__c = date.today().adddays(89);
		//cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
		cp2.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
		cp2.Program_Rating__c = '3';
        cp2.CLQ_Program_Status__c = 'Open';  		
		//cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
		CLQ_ProgramTriggerHandler.BypassTrigger = true;
		insert cp2;
		
		system.AssertEquals('Under Reviewer Review', pt.CLQ_Transaction_Status__c,'Testing' ); 
		CLQ_90_Priordate_notification_Batch obj = new CLQ_90_Priordate_notification_Batch();
		DataBase.executeBatch(obj);  
		Test.stopTest();
      }
  }
}