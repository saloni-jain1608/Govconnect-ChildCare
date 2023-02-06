/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_90_60_30_Days_Rmndr_OnGng_BatchTest
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
private class CLQ_90_60_30_Days_Rmndr_OnGng_BatchTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void testProgramUpdateBatch()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();  
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            Contact cont = new Contact();
            cont.FirstName = 'Test';
            cont.LastName = 'Test';
            cont.Email = 'NOREPLY@TEST.COM';
            insert cont;
            
            
            //RecordType objOnGoingRegRec = [select id,name from RecordType where sobjectType = 'CLQ_Program_Transaction__c' and developername = 'Annual_Report'];  
            CLQ_Program__c cp = CLQ_Test_Util.getCLQProgram();
            cp.Rating_Effective_Date__c = Date.today();
            cp.Rating_Expiration_Date__c = date.today().adddays(90);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp.CLQ_Program_Email__c = 'NOREPLYJFS1@TEST.COM';
            cp.Program_Rating__c = '3';
            cp.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program__c cp1 = CLQ_Test_Util.getCLQProgram();
            cp1.Rating_Effective_Date__c = Date.today();
            cp1.Rating_Expiration_Date__c = date.today().adddays(120);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp1.CLQ_Program_Email__c = 'NOREPLYJFS2@TEST.COM';
            cp1.Program_Rating__c = '3';
            cp1.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp1;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program__c cp2 = CLQ_Test_Util.getCLQProgram();
            cp2.Rating_Effective_Date__c = Date.today();
            cp2.Rating_Expiration_Date__c = date.today().adddays(180);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp2.CLQ_Program_Email__c = 'NOREPLYJFS3@TEST.COM';
            cp2.Program_Rating__c = '3';
            cp2.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp2;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program__c cp3 = CLQ_Test_Util.getCLQProgram();
            cp3.Rating_Effective_Date__c = Date.today();
            cp3.Rating_Expiration_Date__c = date.today().adddays(150);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp3.CLQ_Program_Email__c = 'NOREPLYJFS4@TEST.COM';
            cp3.Program_Rating__c = '3';
            cp3.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp3;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program__c cp4 = CLQ_Test_Util.getCLQProgram();
            cp4.Rating_Effective_Date__c = Date.today();
            cp4.Rating_Expiration_Date__c = date.today().adddays(91); 
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp4.CLQ_Program_Email__c = 'NOREPLYJFS5@TEST.COM';
            cp4.Program_Rating__c = '3';
            cp4.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp4;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            Account accountrecord1 = new Account(Name='Test Account2',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership' ); 
            insert accountrecord1 ;
            
            
            CLQ_Program__c cp5 = CLQ_Test_Util.getCLQProgram();
            cp5.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp5.Rating_Expiration_Date__c = date.today().adddays(60);
            cp5.CLQ_Associated_Organization__c = accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp5.CLQ_Program_Email__c = 'NOREPLYJFS6@TEST.COM';
            cp5.Program_Rating__c = '3';
            cp5.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp5;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp6 = CLQ_Test_Util.getCLQProgram();
            cp6.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp6.Rating_Expiration_Date__c = date.today().adddays(60);
            //cp5.CLQ_Associated_Organization__c = accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp6.CLQ_Program_Email__c = 'NOREPLYJFS7@TEST.COM';
            cp6.Program_Rating__c = '3';
            cp6.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp6;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp6a = CLQ_Test_Util.getCLQProgram();
            cp6a.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp6a.Rating_Expiration_Date__c = date.today().adddays(60);
            //cp5.CLQ_Associated_Organization__c = accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp6a.CLQ_Program_Email__c = 'NOREPLYJFS7@TEST.COM';
            cp6a.Program_Rating__c = '3';
            cp6a.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp6a;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp7a = CLQ_Test_Util.getCLQProgram();
            cp7a.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp7a.Rating_Expiration_Date__c = date.today().adddays(30);
            cp7a.CLQ_Program_Email__c = 'NOREPLYJFS8@TEST.COM';
            cp7a.Program_Rating__c = '3';
            cp7a.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp7a;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;  
            
            CLQ_Program__c cp7b = CLQ_Test_Util.getCLQProgram();
            cp7b.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp7b.Rating_Expiration_Date__c = date.today().adddays(30);
            cp7b.CLQ_Program_Email__c = 'NOREPLYJFS8@TEST.COM';
            cp7b.Program_Rating__c = '3';
            cp7b.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp7b;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp7c = CLQ_Test_Util.getCLQProgram();
            cp7c.Rating_Effective_Date__c = Date.today().adddays(-1);
            cp7c.Rating_Expiration_Date__c = date.today().adddays(30);
            cp7c.CLQ_Program_Email__c = 'NOREPLYJFS8@TEST.COM';
            cp7c.Program_Rating__c = '3';
            cp7c.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp7c;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp8a = CLQ_Test_Util.getCLQProgram();
            cp8a.Rating_Effective_Date__c = Date.today().adddays(-10);
            cp8a.Rating_Expiration_Date__c = date.today().adddays(1);
            cp8a.CLQ_Program_Email__c = 'NOREPLYJFS9@TEST.COM';
            cp8a.Program_Rating__c = '2';
            cp8a.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp8a;
            CLQ_ProgramTriggerHandler.BypassTrigger = false; 
            
            CLQ_Program__c cp8b = CLQ_Test_Util.getCLQProgram();
            cp8b.Rating_Effective_Date__c = Date.today().adddays(-10);
            cp8b.Rating_Expiration_Date__c = date.today().adddays(1);
            cp8b.CLQ_Program_Email__c = 'NOREPLYJFS9@TEST.COM';
            cp8b.Program_Rating__c = '2';
            cp8b.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp8b;
            CLQ_ProgramTriggerHandler.BypassTrigger = false; 
            
            CLQ_Program__c cp8c = CLQ_Test_Util.getCLQProgram();
            cp8c.Rating_Effective_Date__c = Date.today().adddays(-10);
            cp8c.Rating_Expiration_Date__c = date.today().adddays(1);
            cp8c.CLQ_Program_Email__c = 'NOREPLYJFS9@TEST.COM';
            cp8c.Program_Rating__c = '2';
            cp8c.CLQ_Program_Status__c = 'Open';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp8c;
            CLQ_ProgramTriggerHandler.BypassTrigger = false; 
            
            //String programID = cp.id;
            System.debug('Program.id is ' + cp.id );  
            
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = cont.id;
            role1.Role_Type__c = 'JFS';
            role1.Portal_Roles__c = 'SUTQ Consultant';
            role1.CLQ_Program__c = cp.id;
            //role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role1);
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = cont.id;
            role2.Role_Type__c = 'JFS';
            role2.Portal_Roles__c = 'SUTQ Consultant';
            role2.CLQ_Program__c = cp5.id;
            //role1.Secondary_Role__c = 'OCLQSPS';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            
            CLQ_Role__c role3 = new CLQ_Role__c();
            role3.CLQ_Contact__c = cont.id;
            role3.Role_Type__c = 'JFS';
            role3.Portal_Roles__c = 'SUTQ Consultant';
            role3.CLQ_Program__c = cp6.id;
            //role1.Secondary_Role__c = 'OCLQSPS';
            role3.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role3);
            /*  
CLQ_Role__c role4 = new CLQ_Role__c();
role4.CLQ_Contact__c = cont.id;
role4.Role_Type__c = 'JFS';
role4.Portal_Roles__c = 'SUTQ Consultant';
role4.CLQ_Program__c = cp7.id;
//role1.Secondary_Role__c = 'OCLQSPS';
role4.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role4);

CLQ_Role__c role5 = new CLQ_Role__c();
role5.CLQ_Contact__c = cont.id;
role5.Role_Type__c = 'JFS';
role5.Portal_Roles__c = 'SUTQ Consultant';
role5.CLQ_Program__c = cp8.id;
//role1.Secondary_Role__c = 'OCLQSPS';
role5.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role5);
*/  
            insert roles;   
            //Create a CLQ_Program_Transaction__c record
            
            List<CLQ_Program_Transaction__c> programTransactionList = new List<CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c CLQ_program_transactionInstance = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            CLQ_program_transactionInstance.CLQ_Program__c = cp5.id;
            CLQ_program_transactionInstance.CLQ_Transaction_Status__c = 'Approved';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance.CLQ_Registration_Status__c = 'Approved';
            CLQ_program_transactionInstance.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance.CLQ_Associated_Organization__c = accountrecord1.id ; 
            CLQ_program_transactionInstance.Submission_Date1__c = Date.today().addDays(-10);
            CLQ_program_transactionInstance.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            programTransactionList.add(CLQ_program_transactionInstance);
            //Insert CLQ_program_transactionInstance; 
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance1 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            CLQ_program_transactionInstance1.CLQ_Program__c = cp6.id;
            CLQ_program_transactionInstance1.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance1.CLQ_Registration_Status__c = 'Approved';
            CLQ_program_transactionInstance1.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance1.Submission_Date1__c = Date.today().addDays(-10);
            CLQ_program_transactionInstance1.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance1.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            programTransactionList.add(CLQ_program_transactionInstance1);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance2 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
            CLQ_program_transactionInstance2.CLQ_Program__c = cp5.id;
            CLQ_program_transactionInstance2.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance2.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance2.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance2.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance2.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance2.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance2);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance3 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();
            CLQ_program_transactionInstance3.CLQ_Program__c = cp6a.id;
            CLQ_program_transactionInstance3.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance3.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance3.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance3.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance3.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance3.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance3.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance3);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance4 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance4.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            CLQ_program_transactionInstance4.CLQ_Program__c = cp7a.id;
            CLQ_program_transactionInstance4.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance4.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance4.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance4.CLQ_Registration_Status__c = 'Approved';
            CLQ_program_transactionInstance4.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance4.Submission_Date1__c = Date.today().addDays(-10);
            CLQ_program_transactionInstance4.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance4.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            programTransactionList.add(CLQ_program_transactionInstance4);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance5 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance5.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
            CLQ_program_transactionInstance5.CLQ_Program__c = cp7b.id;
            CLQ_program_transactionInstance5.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance5.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance5.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance5.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance5.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance5.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance5.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance5.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance5.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance5);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance6 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance6.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();
            CLQ_program_transactionInstance6.CLQ_Program__c = cp7c.id;
            CLQ_program_transactionInstance6.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance6.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance6.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance6.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance6.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance6.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance6.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance6.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance6.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance6);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance7 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance7.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            CLQ_program_transactionInstance7.CLQ_Program__c = cp8a.id;
            CLQ_program_transactionInstance7.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance7.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance7.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance7.CLQ_Registration_Status__c = 'Approved';
            CLQ_program_transactionInstance7.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance7.Submission_Date1__c = Date.today().addDays(-1);
            CLQ_program_transactionInstance7.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance7.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            programTransactionList.add(CLQ_program_transactionInstance7);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance8 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance8.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
            CLQ_program_transactionInstance8.CLQ_Program__c = cp8b.id;
            CLQ_program_transactionInstance8.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance8.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance8.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance8.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance8.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance8.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance8.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            programTransactionList.add(CLQ_program_transactionInstance8);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance9 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance9.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();
            CLQ_program_transactionInstance9.CLQ_Program__c = cp8c.id;
            CLQ_program_transactionInstance9.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance9.CLQ_ProgTrans_Phone__c = '6148523697';
            CLQ_program_transactionInstance9.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance9.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance9.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance9.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance9.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance9.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance9.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance9);
            
            insert programTransactionList;
            
            CLQ_90_60_30_Days_Reminder_OnGoing_Batch obj = new CLQ_90_60_30_Days_Reminder_OnGoing_Batch();
            DataBase.executeBatch(obj);  
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testProgramUpdateBatchODE()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();  
            List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            configRecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
            configRecords.add(configRecord1);
            
            CLQ_OCLQS_Configuration__c configRecord2 = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            configRecords.add(configRecord2);
            insert configRecords;
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Test';
            c.Email = 'NOREPLY@TEST.COM';
            insert c;
            
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234'); 
            insert accountrecord1 ;
            
            //RecordType objOnGoingRegRec = [select id,name from RecordType where sobjectType = 'CLQ_Program_Transaction__c' and developername = 'Annual_Report'];  
            CLQ_Program__c cp = CLQ_Test_Util.getCLQProgram();
            cp.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            
            cp.Rating_Effective_Date__c = Date.today();
            cp.Rating_Expiration_Date__c = date.today().adddays(90);
            cp.CLQ_Associated_Organization__c = accountrecord.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
            cp.Program_Rating__c = '3';
            cp.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp;
            
            CLQ_Program__c cp3 = CLQ_Test_Util.getCLQProgram();
            cp3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            
            cp3.Rating_Effective_Date__c = Date.today();
            cp3.CLQ_Associated_Organization__c = accountrecord1.id;
            cp3.Rating_Expiration_Date__c = date.today().adddays(150);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp3.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
            cp3.Program_Rating__c = '3';
            cp3.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp3;
            CLQ_Program__c cp4 = CLQ_Test_Util.getCLQProgram();
            cp4.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            
            cp4.Rating_Effective_Date__c = Date.today();
            cp4.Rating_Expiration_Date__c = date.today().adddays(91);
            cp4.CLQ_Associated_Organization__c = accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp4.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
            cp4.Program_Rating__c = '3';
            cp4.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp4;
            
            CLQ_Program__c cp5 = CLQ_Test_Util.getCLQProgram();
            cp4.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            cp5.Rating_Effective_Date__c = Date.today();
            cp5.Rating_Expiration_Date__c = date.today().adddays(-60);
            //cp5.CLQ_Associated_Organization__c = accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp5.CLQ_Program_Email__c = 'NOREPLY@TEST.COM';
            cp5.Program_Rating__c = '3';
            cp5.CLQ_Program_Status__c = 'Open'; 	 
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp5;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            //Create a CLQ_Program_Transaction__c record
            List<CLQ_Program_Transaction__c> progTransactions = new List<CLQ_Program_Transaction__c>();
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();  
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = cp5.id;
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord1.id ; 
            progTransactions.add(ProgramTransaction);
            
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = cp5.id;
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            progTransactions.add(ProgramTransaction1);
            
            //ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
            //ProgramTransaction2.CLQ_Program__c = programRecord.id;
            //progTransactions.add(ProgramTransaction2);    
            
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert progTransactions;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false; 
            
            
            
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            /*CLQ_Role__c role1 = new CLQ_Role__c();
role1.CLQ_Contact__c = c.id;
role1.Role_Type__c = 'ODE';
role1.Portal_Roles__c = 'OCLQSAdministrator';
role1.CLQ_Program__c = cp1.id;
role1.Secondary_Role__c = 'OCLQSPS';
role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role1);*/
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = c.id;
            role2.Role_Type__c = 'ODE';
            role2.Portal_Roles__c = 'OCLQSAdministrator';
            role2.CLQ_Organization__c = accountrecord.id;
            role2.Secondary_Role__c = 'OCLQSPS';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            
            CLQ_Role__c role5 = new CLQ_Role__c();
            role5.CLQ_Contact__c = c.id;
            role5.Role_Type__c = 'ODE';
            role5.Portal_Roles__c = 'OCLQSAdministrator';
            role5.CLQ_Program__c = cp.id;
            role5.Secondary_Role__c = 'OCLQSPS';
            role5.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role5);
            
            CLQ_Role__c role6 = new CLQ_Role__c();
            role6.CLQ_Contact__c = c.id;
            role6.Role_Type__c = 'ODE';
            role6.Portal_Roles__c = 'OCLQSAdministrator';
            role6.CLQ_Organization__c = accountrecord.id;
            role6.Secondary_Role__c = 'OCLQSPS';
            role6.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role6);
            
            /*CLQ_Role__c role3 = new CLQ_Role__c();
role3.CLQ_Contact__c = c.id;
role3.Role_Type__c = 'ODE';
role3.Portal_Roles__c = 'OCLQSAdministrator';
role3.CLQ_Program__c = cp2.id;
role3.Secondary_Role__c = 'OCLQSPS';
role3.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role3);*/
            
            CLQ_Role__c role7 = new CLQ_Role__c();
            role7.CLQ_Contact__c = c.id;
            role7.Role_Type__c = 'ODE';
            role7.Portal_Roles__c = 'OCLQSAdministrator';
            role7.CLQ_Organization__c = accountrecord.id;
            role7.Secondary_Role__c = 'OCLQSPS';
            role7.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role7);
            
            CLQ_Role__c role8 = new CLQ_Role__c();
            role8.CLQ_Contact__c = c.id;
            role8.Role_Type__c = 'ODE';
            role8.Portal_Roles__c = 'OCLQSAdministrator';
            role8.CLQ_Program__c = cp3.id;
            role8.Secondary_Role__c = 'OCLQSPS';
            role8.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role8);
            
            CLQ_Role__c role9 = new CLQ_Role__c();
            role9.CLQ_Contact__c = c.id;
            role9.Role_Type__c = 'ODE';
            role9.Portal_Roles__c = 'OCLQSAdministrator';
            role9.CLQ_Organization__c = accountrecord1.id;
            role9.Secondary_Role__c = 'OCLQSSACC';
            role9.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role9);
            
            CLQ_Role__c role10 = new CLQ_Role__c();
            role10.CLQ_Contact__c = c.id;
            role10.Role_Type__c = 'ODE';
            role10.Portal_Roles__c = 'OCLQSAdministrator';
            role10.CLQ_Program__c = cp4.id;
            role10.Secondary_Role__c = 'OCLQSPS';
            role10.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role10);
            
            CLQ_Role__c role4 = new CLQ_Role__c();
            role4.CLQ_Contact__c = c.id;
            role4.Role_Type__c = 'ODE';
            role4.Portal_Roles__c = 'OCLQSAdministrator';
            role4.CLQ_Organization__c = accountrecord1.id;
            role4.Secondary_Role__c = 'OCLQSSACC';
            role4.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role4);
            
            /*CLQ_Role__c role11 = new CLQ_Role__c();
role11.CLQ_Contact__c = c.id;
role11.Role_Type__c = 'JFS';
role11.Portal_Roles__c = 'OCLQSAdministrator';
role11.CLQ_Program__c = cp5.id;
role11.CLQ_Organization__c = accountrecord1.id;
//role11.Secondary_Role__c = 'OCLQSSACC';
role11.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role11);*/ 
            insert roles;
            
            
            CLQ_90_60_30_Days_Reminder_OnGoing_Batch obj = new CLQ_90_60_30_Days_Reminder_OnGoing_Batch();
            DataBase.executeBatch(obj);  
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testProgramUpdateBatchSUTQ()
    {
        Test.startTest(); 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            Contact cont = new Contact();
            cont.FirstName = 'Test';
            cont.LastName = 'Test';
            cont.Email = 'NOREPLY@TEST.COM';
            insert cont;
            
            Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership' ); 
            insert accountrecord1 ;
            
            //RecordType objOnGoingRegRec = [select id,name from RecordType where sobjectType = 'CLQ_Program_Transaction__c' and developername = 'Annual_Report'];  
            CLQ_Program__c cp = CLQ_Test_Util.getCLQProgram();
            cp.RecordTypeId=Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            cp.Rating_Effective_Date__c = Date.today().adddays(-120);
            cp.Rating_Expiration_Date__c = date.today().adddays(60);
            cp.CLQ_Associated_Organization__c =  accountrecord1.id;
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp.CLQ_Program_Email__c = 'NOREPLYSUTQ1@TEST.COM';
            cp.Program_Rating__c = '3';
            cp.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            //CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp;
            //CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program__c cp1 = CLQ_Test_Util.getCLQProgram();
            cp1.RecordTypeId=Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            cp1.Rating_Effective_Date__c = Date.today().adddays(-11);//120days
            cp1.Rating_Expiration_Date__c = date.today().adddays(120);
            //cp.Rating_Anniversary_Date__c = Date.today().addDays(-120);
            cp1.CLQ_Program_Email__c = 'NOREPLYSUTQ2@TEST.COM';
            cp1.Program_Rating__c = '3';
            cp1.CLQ_Program_Status__c = 'Open'; 	 
            //cp.Rating_Expiration_Date__c= Date.today().adddays(-3);
            //CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert cp1;
            //CLQ_ProgramTriggerHandler.BypassTrigger = false; 
            
            //Create a CLQ_Program_Transaction__c record
            
            
            List<CLQ_Program_Transaction__c> programTransactionList = new List<CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c CLQ_program_transactionInstance = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            CLQ_program_transactionInstance.CLQ_Program__c = cp.id;
            CLQ_program_transactionInstance.CLQ_Associated_Organization__c = accountrecord1.Id;
            CLQ_program_transactionInstance.CLQ_Transaction_Status__c = 'Approved';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance.CLQ_ProgTrans_Phone__c = '6148523697';
            //CLQ_program_transactionInstance.CLQ_ProgTrans_County__c = staticCountyInstance.Id;
            CLQ_program_transactionInstance.CLQ_ProgTrans_City__c = 'Wilminton';
            //CLQ_program_transactionInstance.CLQ_Registration_Status__c = 'Not Submitted';
            CLQ_program_transactionInstance.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance);
            //Insert CLQ_program_transactionInstance;            
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance1 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            CLQ_program_transactionInstance1.CLQ_Program__c = cp.id;
            CLQ_program_transactionInstance1.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance1.CLQ_ProgTrans_Phone__c = '6148523697';
            //CLQ_program_transactionInstance1.CLQ_ProgTrans_County__c = staticCountyInstance.Id;
            CLQ_program_transactionInstance1.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance1.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance1.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance1.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance1.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance1.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance1.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance1);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance2 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
            CLQ_program_transactionInstance2.CLQ_Program__c = cp1.id;
            CLQ_program_transactionInstance2.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance2.CLQ_ProgTrans_Phone__c = '6148523697';
            //CLQ_program_transactionInstance1.CLQ_ProgTrans_County__c = staticCountyInstance.Id;
            CLQ_program_transactionInstance2.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance2.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance2.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance2.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance2.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance2.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance2);
            
            CLQ_Program_Transaction__c CLQ_program_transactionInstance3 = new CLQ_Program_Transaction__c();
            CLQ_program_transactionInstance3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();
            CLQ_program_transactionInstance3.CLQ_Program__c = cp1.id;
            CLQ_program_transactionInstance3.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_State__c = 'DF';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Zip_Code__c = '65487';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Phone_Extension__c = 654;
            CLQ_program_transactionInstance3.CLQ_ProgTrans_Phone__c = '6148523697';
            //CLQ_program_transactionInstance1.CLQ_ProgTrans_County__c = staticCountyInstance.Id;
            CLQ_program_transactionInstance3.CLQ_ProgTrans_City__c = 'Wilminton';
            CLQ_program_transactionInstance3.ownerid = UserInfo.getUserId();
            CLQ_program_transactionInstance3.Submission_Date1__c = Date.today();
            CLQ_program_transactionInstance3.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            CLQ_program_transactionInstance3.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            CLQ_program_transactionInstance3.CLQ_Form_Complete_Not_Paid__c = true;
            CLQ_program_transactionInstance3.CLQ_Fee_Paid__c = false;
            programTransactionList.add(CLQ_program_transactionInstance3);
            
            insert programTransactionList;
            
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = cont.id;
            role1.Role_Type__c = 'JFS';
            role1.Portal_Roles__c = 'SUTQ Consultant';
            role1.CLQ_Program__c = cp.id;
            //role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role1);
            insert roles;  
            
            CLQ_90_60_30_Days_Reminder_OnGoing_Batch obj = new CLQ_90_60_30_Days_Reminder_OnGoing_Batch();
            DataBase.executeBatch(obj);  
            Test.stopTest();
        }
    }
}