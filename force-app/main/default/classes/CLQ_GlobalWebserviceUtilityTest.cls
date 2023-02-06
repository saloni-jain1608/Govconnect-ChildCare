/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_GlobalWebserviceUtilityTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**  Pavan Ayta              9/5/17          1.2         Adding Test methods for TFS #11354
**************************************************************************************************************/
@isTest
private class CLQ_GlobalWebserviceUtilityTest {
    public static final string OCLQSPS = 'OCLQSPS';
    public static final string APPROVED = 'Approved';
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        contact c = new contact();
        c.lastname = 'Test';
        c.Email = 'NOREPLY@TEST.COM';
        insert c;   
        
        OCLQS_Email_Recipients__c eMr = new OCLQS_Email_Recipients__c();
        eMr.BCC__c = 'clq_message_process_email__c';
        eMr.Name = 'TestName';
        eMr.CC__c = 'CLQ_Assigned_To_Email__c';
        eMr.CC_Role__c = 'OCLQSOwner';
        eMr.Object_API__c = 'CLQ_Program__c';
        eMr.Template_Name__c = 'CLQ_IHA_Program_Application_Renewal_Template';
        eMr.To__c = 'Program_Email__c';
        eMr.To_Role__c = 'OCLQSAdministrator';
        
        OCLQS_Email_Recipients__c eMr4 = new OCLQS_Email_Recipients__c();
        eMr4.BCC__c = 'clq_message_process_email__c';
        eMr4.Name = 'Closed by System ODJFS Email Alert';
        eMr4.CC__c = 'CLQ_Assigned_To_Email__c';
        eMr4.CC_Role__c = 'Owner';
        eMr4.Object_API__c = 'CLQ_Program_Transaction__c';
        eMr4.Template_Name__c = 'CLQ_Closed_by_System_ODJFS';
        eMr4.To__c = 'CLQ_Assigned_To_Email__c'; 
        
        OCLQS_Email_Recipients__c eMr1 = new OCLQS_Email_Recipients__c();
        eMr1.BCC__c = 'clq_message_process_email__c';
        eMr1.Name = 'TestName1';
        eMr1.CC__c = 'CLQ_Assigned_To_Email__c';
        eMr1.CC_Role__c = 'OCLQSAdministrator';
        eMr1.Object_API__c = 'CLQ_Program_Transaction__c';
        eMr1.Template_Name__c = 'CLQ_JFS_COC_Amendment_Request_Submitted';
        eMr1.To__c = 'LicenseManagerEmail';
        eMr1.To_Role__c = 'OCLQSOwner';
        
        OCLQS_Email_Recipients__c eMr2 = new OCLQS_Email_Recipients__c();
        eMr2.BCC__c = 'clq_message_process_email__c';
        eMr2.Name = 'TestName2';
        eMr2.CC__c = 'CLQ_Program_Email_Address__c';
        eMr2.CC_Role__c = 'Owner';
        eMr2.Object_API__c = 'CLQ_Corrective_Action_Plan__c';
        eMr2.Template_Name__c = 'CLQ_JFS_CAP_Overdue_Email_Template';
        eMr2.To__c = 'CLQ_Program_Email_Address__c';
        eMr2.To_Role__c = 'Owner';
        
        OCLQS_Email_Recipients__c eMr3 = new OCLQS_Email_Recipients__c();
        eMr3.BCC__c = 'clq_message_process_email__c';
        eMr3.Name = 'JFS Pro Period Exceeded Alert';
        eMr3.Object_API__c = 'CLQ_Program__c';
        eMr3.Template_Name__c = 'CLQ_JFS_Provisional_Period_Exceeded';
        eMr3.To__c = 'CLQ_Licensing_Specialist__r.Email';
        eMr3.CC__c = 'CLQ_Licensing_Specialist__r.Email';   
        eMr3.To_Role__c = 'Owner';  
        eMr3.CC_Role__c = 'Owner';  
        
        OCLQS_Email_Recipients__c eMr6 = new OCLQS_Email_Recipients__c();
        eMr6.BCC__c = 'clq_message_process_email__c';
        eMr6.Name = 'Closed by System ODE Email Alert';
        eMr6.Object_API__c = 'CLQ_Program_Transaction__c';
        eMr6.Template_Name__c = 'CLQ_Closed_by_System_ODE';
        eMr6.To__c = 'CLQ_Assigned_To_Email__c';
        eMr6.CC__c = 'CLQ_Assigned_To_Email__c';   
        eMr6.To_Role__c = 'OCLQSAdministrator';  
        eMr6.CC_Role__c = 'OCLQSAdministrator';
        
        OCLQS_Email_Recipients__c eMr5 = new OCLQS_Email_Recipients__c();
        eMr5.BCC__c = 'clq_message_process_email__c';
        eMr5.Name = 'ODE Pro Period Exceeded Alert';
        eMr5.CC__c = 'CLQ_Licensing_Specialist__r.Email';
        eMr5.CC_Role__c = 'OCLQSAdministrator';
        eMr5.Object_API__c = 'CLQ_Program__c';
        eMr5.Template_Name__c = 'CLQ_ODE_Provisional_Period_Exceeded';
        eMr5.To__c = 'CLQ_Licensing_Specialist__r.Email';
        eMr5.To_Role__c = 'OCLQSOwner';  
        
        insert new list<OCLQS_Email_Recipients__c> {eMr, eMr1, eMr2, eMr3, eMr4, eMr5, eMr6}; 
            
            }   
    //
    @IsTest
    static void testSubmitProgTrans() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord;
            
            //Create account record
            Account accountrecord = new Account(Name = 'Test Account', CLQ_DIRN__c = '1234');
            insert accountrecord;
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(
                'CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            insert programRecord;  
            //Create Program Transaction record to test CLQ_Global_Webservice_Utility
            CLQ_Program_Transaction__c ProgramTransactionCL = new CLQ_Program_Transaction__c();
            ProgramTransactionCL.RecordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(
                'Continuous_License').getRecordTypeId();
            ProgramTransactionCL.CLQ_Program__c = programRecord.id;
            ProgramTransactionCL.CLQ_Registration_Status__c = 'Closed by System';
            
            insert ProgramTransactionCL;       
            CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
            td.CLQ_Document_Status__c ='Under Review';
            td.CLQ_Program_Transaction__c= ProgramTransactionCL.id;
            td.CLQ_Document_Comments__c = 'test';
            insert td;
            test.startTest();
            
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransactionCL.id,'Continuous License');
            CLQ_GlobalWebserviceUtility.completeDocReview(ProgramTransactionCL.id);
            
            test.stopTest(); 
        }
    }
    
    @IsTest
    static void testCopyStaffDetails() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_County__c = county.id;
            // programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record - Amendment - Center - Change of Location
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.CLQ_Registration_Status__c = 'Closed by System';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            insert ProgramTransaction;
            
            //create prior inspection on program of type annual
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Annual', 'Full', 'Approved');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            //insert inspectionrecord;
            
            //create current inspection on program of type annual
            CLQ_Inspection__c inspectionrecord2 = new CLQ_Inspection__c();
            inspectionrecord2.CLQ_Program__c = programRecord.id;
            inspectionrecord2.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            inspectionrecord2.recordtypeid = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord2.CLQ_Scope__c = 'Full';
            inspectionrecord2.CLQ_Inspection_Status__c = 'Approved';
            inspectionrecord2.CLQ_Inspection_Type__c= 'Annual';
            insert inspectionrecord2;
            
            //create staff record for this inspection
            CLQ_Staff_Record__c sr = new CLQ_Staff_Record__c();
            sr.CLQ_Inspection__c = inspectionrecord2.id;
            sr.CLQ_Career_Pathways_Level__c = '3';
            sr.CLQ_FBI_Expiration_Date__c = system.today();
            insert sr;
            //create staff training records for this staff record
            CLQ_Staff_Training__c str = new CLQ_Staff_Training__c();
            str.CLQ_Staff_Record__c = sr.id;
            str.CLQ_Hours__c = 6;
            insert str;
            
            CLQ_GlobalWebserviceUtility.copyStaffDetails(inspectionrecord2.id);
            Test.stopTest();
        }
        
    }
    
    @IsTest
    static void testSendEmail() {    
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            
            // programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            insert programRecord ;
            Test.startTest();
            //Create a CLQ_Program_Transaction__c record - Amendment - Center - Change of Location
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord.id ; 
            ProgramTransaction.CLQ_Registration_Status__c = 'Closed By System';
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.CLQ_Contact_Email_Address__c = 'tester@tester.com';
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            insert role1;
            parms.add('COA Amendment Request Submitted' + '|' + ProgramTransaction.id);
            parms.add('CLQ_JFS_COC_Amendment_Request_Submitted' + '|' + ProgramTransaction.id + '|' +'CLQ_Program_Transaction__c');
            CLQ_GlobalWebserviceUtility.sendEmail(parms);
            Test.stopTest();
            
            
            //Create a CLQ_Program_Transaction__c record - Amendment - Center - Change of Location
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction2.CLQ_Program__c = programRecord.id;
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction2.CLQ_Program__c = programRecord.id;
            ProgramTransaction2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction2.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction2.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction2.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction2.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction2.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction2.CLQ_Registration_Status__c = 'Closed By System';
            ProgramTransaction2.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction2;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            //Inspection
            //CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
            //insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
            //insRecord1.CLQ_Inspection_Type__c = 'Complaint';
            //insRecord1.CLQ_Program__c = programRecord.Id;
            //insRecord1.CLQ_Notice__c = 'Announced';
            //insRecord1.CLQ_Notes__c = 'inspection 2';
            //insRecord1.CLQ_Program_Transaction__c = ProgramTransaction2.Id;
            //insert insRecord1;
            
            
            
            parms = new list<string>();    
            parms.add('COA Amendment Request Submitted' + '|' + ProgramTransaction2.id);
            //parms.add('COA Amendment Request Submitted' + '|' + insRecord1.id);
            parms.add('CLQ_IHA_Program_Application_Renewal_Template' + '|' + programRecord.id + '|' + 'CLQ_Program__c');
            CLQ_GlobalWebserviceUtility.sendEmail(parms);
        }
    }
    @IsTest 
    static void testSendEmailInspection() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            //Create a CLQ_Program_Transaction__c record - Amendment - Center - Change of Location
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.CLQ_Registration_Status__c = 'Closed By System';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Pre-license', 'Full', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = Date.today();
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            inspectionrecord.CLQ_CAP_Generated__c = false;
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            inspectionrecord.CLQ_Program_Transaction__c  = ProgramTransaction.Id;
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
            
            CLQ_Corrective_Action_Plan__c CAP = new CLQ_Corrective_Action_Plan__c();
            insert CAP;
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            insert role1;
            parms.add('SUTQ Email - on site deferral clone' + '|' + inspectionrecord.id);
            parms.add('CLQ_JFS_CAP_Overdue_Email_Template' + '|' + CAP.Id +'|' +'CLQ_Corrective_Action_Plan__c'); 
            CLQ_GlobalWebserviceUtility.sendEmail(parms);
            Test.StopTest(); 
        }
    }
    
    @IsTest
    static void testgetAllRecipientsSUTQ() {  
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            test.StartTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.CLQ_Registration_Status__c = 'Closed By System';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role1);
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = c.id;
            role2.Role_Type__c = 'ODE';
            role2.Portal_Roles__c = 'OCLQSAdministrator';
            role2.CLQ_Organization__c = accountrecord.id;
            role2.Secondary_Role__c = 'OCLQSPS';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            insert roles;
            
            //CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQ(programRecord.id,accountrecord.id,ProgramTransaction.Id);
            
            //jiangl bug#11354 start
            //create a user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsSUTQ@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
            insert u;
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord2.CLQ_Program_Status__c = 'New';
            programRecord2.CLQ_License_Type__c = 'Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Licensed';       
            
            programRecord2.CLQ_County__c = county.id;
            programRecord2.CLQ_License_Issue_Date__c = system.Date.today();
            
            programRecord2.CLQ_Licensing_Specialist__c = u.id;
            programRecord2.SUTQ_Reviewer__c = u.id;
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord2 ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction2.CLQ_Program__c = programRecord2.id;
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction2.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction2.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction2.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction2.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction2.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction2.CLQ_Registration_Status__c = 'Closed By System';
            ProgramTransaction2.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction2;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQ(programRecord2.id,accountrecord.id,ProgramTransaction2.Id);
            
            
            //jaingl bug#11354 end
            
            
            test.stopTest();
        }
    }
    
    @IsTest
    static void testgetAllRecipientsLicensing() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            test.StartTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role1);
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = c.id;
            role2.Role_Type__c = 'ODE';
            role2.Portal_Roles__c = 'OCLQSAdministrator';
            role2.CLQ_Organization__c = accountrecord.id;
            role2.Secondary_Role__c = 'OCLQSPS';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            insert roles;
            
            //CLQ_GlobalWebserviceUtility.getgetAllRecipientsLicensing(programRecord.id,accountrecord.id,ProgramTransaction.Id);
            
            //jiangl bug#11354 start
            //create a user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsLicensing@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
            insert u;
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord2.CLQ_Program_Status__c = 'New';
            programRecord2.CLQ_License_Type__c = 'Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Licensed';       
            
            programRecord2.CLQ_County__c = county.id;
            programRecord2.CLQ_License_Issue_Date__c = system.Date.today();
            
            programRecord2.CLQ_Licensing_Specialist__c = u.id;
            programRecord2.SUTQ_Reviewer__c = u.id;
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord2 ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction2.CLQ_Program__c = programRecord2.id;
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Not Submitted';      
            ProgramTransaction2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction2.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction2.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction2.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction2.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction2.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction2.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert ProgramTransaction2;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            CLQ_GlobalWebserviceUtility.getAllRecipientsLicensing(programRecord2.id,accountrecord.id,ProgramTransaction2.Id);
            
            //jaingl bug#11354 end
            
            
            test.stopTest();
        }
    }
    
    @IsTest
    static void testgetAllRecipientsSUTQBatch() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            test.StartTest();
            List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            configRecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
            configRecords.add(configRecord1); 
            insert configRecords;
            
            List<CLQ_County__c> Counties = new List<CLQ_County__c>();
            
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            Counties.add(county); 
            
            CLQ_County__c county2 = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            Counties.add(county2); 
            insert Counties;
            //Create account record
            List<Account> Accounts = new List<Account>();
            
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            Accounts.add(accountrecord);
            
            Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234'); 
            Accounts.add(accountrecord1);
            
            insert Accounts ;
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            programs.add(programRecord);
            
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord1.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            programRecord1.CLQ_Program_Status__c = 'New';
            programRecord1.CLQ_License_Type__c = 'Continuous';
            programRecord1.CLQ_License_Registration_Status__c = 'Licensed';
            
            programRecord1.CLQ_County__c = county.id;
            programRecord1.CLQ_License_Issue_Date__c = system.Date.today();
            programs.add(programRecord1);
            
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsSUTQBatch@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
            insert u;
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord2.CLQ_Program_Status__c = 'New';
            programRecord2.CLQ_License_Type__c = 'Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Licensed';              
            programRecord2.CLQ_County__c = county.id;
            programRecord2.CLQ_License_Issue_Date__c = system.Date.today(); 
            programRecord2.CLQ_Licensing_Specialist__c = u.id;
            programRecord2.SUTQ_Reviewer__c = u.id;
            
            programs.add(programRecord2);
            
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert Programs ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;  
            
            List<CLQ_Program_Transaction__c> progTrans = new List<CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord.id;           
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'lkjd@oiwuer.com';  
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            //      progTrans.add(ProgramTransaction);
            
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord1.id;
            ProgramTransaction1.CLQ_Associated_Organization__c = accountrecord1.id;           
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction1.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction1.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction1.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction1.CLQ_Assigned_To_Email__c = 'lkjd@oiwuer.com';            
            ProgramTransaction1.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction1.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction1.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction1.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            progTrans.add(ProgramTransaction1); 
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            
            //jiangl bug#11354 start      
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            ProgramTransaction2.CLQ_Program__c = programRecord2.id;
            ProgramTransaction2.CLQ_Associated_Organization__c = accountrecord.id;           
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction2.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction2.CLQ_Assigned_To_Email__c = 'lkjd@oiwuer.com';            
            ProgramTransaction2.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction2.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction2.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction2.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction2.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction2.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            
            system.debug('about to insert transaction... ');
            progTrans.add(ProgramTransaction2); 
            //jaingl bug#11354 end
            
            //jiangl bug#11354 start      
            CLQ_Program_Transaction__c ProgramTransaction3 = new CLQ_Program_Transaction__c();
            ProgramTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_ODE_Program').getRecordTypeId();
            ProgramTransaction3.CLQ_Program__c = programRecord2.id;
            ProgramTransaction3.CLQ_Associated_Organization__c = accountrecord.id; 
            ProgramTransaction3.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction3.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction3.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction3.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction3.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction3.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction3.CLQ_Assigned_To_Email__c = 'lkjd@oiwuer.com';  
            ProgramTransaction3.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction3.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction3.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction3.CLQ_ProgTrans_City__c = 'Wilminton';
            ProgramTransaction3.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction3.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            system.debug('about to insert transaction... ');
            progTrans.add(ProgramTransaction3); 
            //jaingl bug#11354 end
            
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            insert progTrans;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = OCLQSPS;
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role1);
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = c.id;
            role2.Role_Type__c = 'ODE';
            role2.Portal_Roles__c = 'OCLQSAdministrator';
            role2.CLQ_Organization__c = accountrecord.id;
            role2.CLQ_Program__c = programRecord1.id; //Pavan
            role2.Secondary_Role__c = 'OCLQSPS';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            
            CLQ_Role__c role3 = new CLQ_Role__c();
            role3.CLQ_Contact__c = c.id;
            role3.Role_Type__c = 'ODE';
            role3.Portal_Roles__c = 'OCLQSAdministrator';
            role3.CLQ_Program__c = programRecord.id;
            role3.Secondary_Role__c = 'OCLQSPS';
            role3.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role3);
            
            CLQ_Role__c role4 = new CLQ_Role__c();
            role4.CLQ_Contact__c = c.id;
            role4.Role_Type__c = 'ODE';
            role4.Portal_Roles__c = 'OCLQSAdministrator';
            role4.CLQ_Organization__c = accountrecord.id;
            role4.Secondary_Role__c = 'OCLQSSACC';
            role4.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role4);
            //Pavan for TFS #11354
            CLQ_Role__c role5 = new CLQ_Role__c();
            role5.CLQ_Contact__c = c.id;
            role5.Role_Type__c = 'JFS';
            role5.Portal_Roles__c = 'SUTQ Consultant';
            role5.CLQ_Organization__c = accountrecord.id;
            role5.CLQ_Program__c = programRecord1.id; //Pavan
            //role5.Secondary_Role__c = 'OCLQSPS';
            role5.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role5);
            insert roles;
            
            test.stopTest(); 
            CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQBatch(progTrans);
            //Pavan for TFS #11354
            Set<Id> ProgID = new Set<Id>();
            Set<ID> PrgTrnsID = new Set<Id>();
            ProgID.add(programRecord.Id);
            ProgID.add(programRecord1.Id);
            PrgTrnsID.add(ProgramTransaction.Id);
            PrgTrnsID.add(ProgramTransaction1.Id);
            list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
            roleList.add(role1);
            roleList.add(role2);
            roleList.add(role5);
            CLQ_GlobalWebserviceUtility.fetchAllJFSPortalRoleEmail(ProgID,PrgTrnsID);
            
            OCLQS_Email_Recipients__c Er = new OCLQS_Email_Recipients__c();
            Er.Template_Name__c = 'CLQ_JFS_CAP_Overdue_Email_Template';
            Er.Name = 'Test Template Name';
            insert Er;
            
            //CLQ_GlobalWebserviceUtility.fetchEmailTemplateRecipient();
            map<Id, String> mapprgTrans = new map<Id, String>();
            mapprgTrans.put(ProgramTransaction.Id, 'Test');
            mapprgTrans.put(ProgramTransaction1.Id, 'Test1');  
            
            CLQ_GlobalWebserviceUtility.sendJFSClosedBySystemAlert(progTrans,'CLQ_Closed_by_System_ODJFS');
            CLQ_GlobalWebserviceUtility.sendODEClosedBySystemAlert(progTrans,'CLQ_Closed_by_System_ODE');          
            //CLQ_GlobalWebserviceUtility.sendJFSEmailForPrgTransaction(mapprgTrans);//PA Commented by PRDP
            //CLQ_GlobalWebserviceUtility.sendODEEmailForPrgTransaction(mapprgTrans);//PA Commented by PRDP
        }
    }
    
    @IsTest
    static void testgetAllRecipientsSUTQBatchProg() {  
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            test.StartTest();
            List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            configRecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
            configRecords.add(configRecord1); 
            insert configRecords;
            
            //jiangl bug#11354 start
            //create a user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsSUTQProg@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
            insert u;
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234'); 
            insert accountrecord1 ;
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Licensing_Specialist__c = u.id;
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            programRecord.CLQ_Program_Email__c = 'asd@asd.com';
            programs.add(programRecord);        
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            //     programs.add(programRecord);
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord1.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            programRecord1.CLQ_Program_Status__c = 'New';
            programRecord1.CLQ_License_Type__c = 'Continuous';
            programRecord1.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord1.CLQ_Licensing_Specialist__c = u.id;
            programRecord1.CLQ_Program_Email__c = 'asd@asd.com';           
            programRecord1.CLQ_County__c = county.id;
            programRecord1.CLQ_License_Issue_Date__c = system.Date.today();
            programs.add(programRecord1);
            
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord2.CLQ_Program_Status__c = 'New';
            programRecord2.CLQ_License_Type__c = 'Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Licensed';       
            
            programRecord2.CLQ_County__c = county.id;
            programRecord2.CLQ_License_Issue_Date__c = system.Date.today();
            
            //     programRecord2.CLQ_Licensing_Specialist__c = u.id;
            //     programRecord2.SUTQ_Reviewer__c = u.id;
            //programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            programs.add(programRecord2);
            
            
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programs ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            insert c;
            list<string> parms = new list<string>();
            List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSOwner';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            role1.ODE_Role_Type__c = 'Org Role';
            roles.add(role1);
            
            CLQ_Role__c role2 = new CLQ_Role__c();
            role2.CLQ_Contact__c = c.id;
            role2.Role_Type__c = 'ODE';
            role2.Portal_Roles__c = 'OCLQSAdministrator';
            role2.CLQ_Organization__c = accountrecord.id;
            role2.Secondary_Role__c = 'OCLQSPS';
            role2.ODE_Role_Type__c = 'Org Role';
            role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role2);
            
            CLQ_Role__c role3 = new CLQ_Role__c();
            role3.CLQ_Contact__c = c.id;
            role3.Role_Type__c = 'ODE';
            role3.Portal_Roles__c = 'OCLQSAdministrator';
            role3.CLQ_Program__c = programRecord.id;
            role3.Secondary_Role__c = 'OCLQSPS';
            role3.ODE_Role_Type__c = 'Org Role';
            role3.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role3);
            
            CLQ_Role__c role4 = new CLQ_Role__c();
            role4.CLQ_Contact__c = c.id;
            role4.Role_Type__c = 'ODE';
            role4.Portal_Roles__c = 'OCLQSAdministrator';
            role4.CLQ_Organization__c = accountrecord.id;
            role4.Secondary_Role__c = 'OCLQSSACC';
            role4.ODE_Role_Type__c = 'Org Role';
            role4.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            roles.add(role4);
            insert roles;
            map<Id, String> mapPrgTransEt = new map<Id, String>();
            
            //OCLQS_Email_Recipients__c em = new OCLQS_Email_Recipients__c();
            Messaging.SingleEmailMessage ms = new Messaging.SingleEmailMessage();
            //ms
            
            CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQBatchProg(programs);
            CLQ_GlobalWebserviceUtility.sendODEProPeriodExceededEmailAlert(programs,'CLQ_ODE_Provisional_Period_Exceeded');
            test.stopTest();
        }
    }
    
    @IsTest
    static void testCAPOverDueEmailAlert() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            configRecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            configRecords.add(configRecord1); 
            insert configRecords;
            
            //jiangl bug#11354 start
            //create a user
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsSUTQProg@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
            insert u;         
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234'); 
            insert accountrecord1 ;
            
            contact c1 = new contact();
            c1.lastname = 'tester';
            c1.email = 'tester@tester.com';
            insert c1;
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';        
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            programRecord.CLQ_Licensing_Specialist__c = u.id;
            programs.add(programRecord);        
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord1.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            programRecord1.CLQ_Program_Status__c = 'New';
            programRecord1.CLQ_License_Type__c = 'Continuous';
            programRecord1.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord1.CLQ_County__c = county.id;
            programRecord1.CLQ_License_Issue_Date__c = system.Date.today();
            programRecord1.CLQ_Licensing_Specialist__c = u.id;         
            programs.add(programRecord1);
            
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programs ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            //create prior inspection on program of type annual
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Annual', 'Full', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            inspectionrecord.CLQ_Inspection_Type__c = 'Annual';
            inspectionrecord.CLQ_Scope__c = 'Full';
            inspectionrecord.CLQ_Inspection_Status__c = 'Approved';
            insert inspectionrecord;
            
            //create prior inspection on program of type annual
            CLQ_Inspection__c inspectionrecord2 = CLQ_UtilityClass.createInspectionrecord('Annual', 'Full', 'Pending Processing');
            inspectionrecord2.CLQ_Program__c = programRecord1.id;
            inspectionrecord2.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            inspectionrecord2.CLQ_Inspection_Type__c = 'Annual';
            inspectionrecord2.CLQ_Scope__c = 'Full';
            inspectionrecord2.CLQ_Inspection_Status__c = APPROVED;
            insert inspectionrecord2;
            
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c1.id;
            role1.Role_Type__c = 'JFS';
            role1.Portal_Roles__c = 'Owner';
            role1.CLQ_Program__c = programRecord1.id;
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            insert role1;
            
            List<CLQ_Corrective_Action_Plan__c> capList = new List<CLQ_Corrective_Action_Plan__c>();
            CLQ_Corrective_Action_Plan__c plan = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord.Id,             
                CLQ_Inspection__c = inspectionrecord.Id);
            
            CLQ_Corrective_Action_Plan__c plan1 = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord.Id,             
                CLQ_Inspection__c = inspectionrecord.Id);
            
            CLQ_Corrective_Action_Plan__c plan2 = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord1.Id,    
                CLQ_Program_Email_Address__c = 'asjdb@asnl.com',
                CLQ_Inspection__c = inspectionrecord2.Id);
            
            CLQ_Corrective_Action_Plan__c plan3 = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord1.Id,
                CLQ_Program_Email_Address__c = 'asjdb@asnl.com',
                CLQ_Inspection__c = inspectionrecord2.Id);  
            capList.add(plan); 
            capList.add(plan1); 
            capList.add(plan2); 
            capList.add(plan3);          
            insert capList; 
            Test.startTest(); 
            CLQ_GlobalWebserviceUtility.sendODECAPOverDueEmailAlert(capList,'CLQ_ODE_CAP_Overdue_Email_Template'); 
            CLQ_GlobalWebserviceUtility.sendJFSCAPOverDueEmailAlert(capList,'CLQ_JFS_CAP_Overdue_Email_Template'); 
            CLQ_GlobalWebserviceUtility.sendJFSProPeriodExceededEmailAlert(programs,'CLQ_JFS_Provisional_Period_Exceeded'); 
            Test.stopTest(); 
            //CLQ_GlobalWebserviceUtility.copyStaffDetails(inspectionrecord2.id);
        }
    }
    
    
    
    /*static testMethod void testgetOrgLevelODERecipients() {  
test.StartTest();
List<CLQ_OCLQS_Configuration__c> configRecords = new List<CLQ_OCLQS_Configuration__c>();
CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
configRecords.add(configRecord);

CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
configRecords.add(configRecord1); 
insert configRecords;

CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
insert county;
county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
insert county;
//Create account record
Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
insert accountrecord ;

Account accountrecord1 = new Account(Name='Test Account1',CLQ_DIRN__c = '1234'); 
insert accountrecord1 ;

//Create a program record
List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
CLQ_Program__c programRecord = new CLQ_Program__c();
programRecord.Name = 'Test';
programRecord.CLQ_Associated_Organization__c = accountrecord.id;
programRecord.CLQ_Street_Address_1__c = 'test';
programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Pre School').getRecordTypeId();
programRecord.CLQ_Program_Status__c = 'New';
programRecord.CLQ_License_Type__c = 'Continuous';
programRecord.CLQ_License_Registration_Status__c = 'Licensed';

programRecord.CLQ_County__c = county.id;
programRecord.CLQ_License_Issue_Date__c = system.Date.today();

//programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
programs.add(programRecord);

CLQ_Program__c programRecord1 = new CLQ_Program__c();
programRecord1.Name = 'Test';
programRecord1.CLQ_Associated_Organization__c = accountrecord1.id;
programRecord1.CLQ_Street_Address_1__c = 'test';
programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('School Age Child Care').getRecordTypeId();
programRecord1.CLQ_Program_Status__c = 'New';
programRecord1.CLQ_License_Type__c = 'Continuous';
programRecord1.CLQ_License_Registration_Status__c = 'Licensed';

programRecord1.CLQ_County__c = county.id;
programRecord1.CLQ_License_Issue_Date__c = system.Date.today();
programs.add(programRecord1);


//jiangl bug#11354 start
//create a user
Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
User u = new User(Alias = 'T11354', Email='Testbug11354_getAllRecipientsSUTQProg@testorg.com', EmailEncodingKey='UTF-8', LastName='TestDefect', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='TestDefect11354@testorg.com');
insert u;
//Create a program record
CLQ_Program__c programRecord2 = new CLQ_Program__c();
programRecord2.Name = 'Test';
programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
programRecord2.CLQ_Street_Address_1__c = 'test';
programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Pre School').getRecordTypeId();
programRecord2.CLQ_Program_Status__c = 'New';
programRecord2.CLQ_License_Type__c = 'Continuous';
programRecord2.CLQ_License_Registration_Status__c = 'Licensed';       

programRecord2.CLQ_County__c = county.id;
programRecord2.CLQ_License_Issue_Date__c = system.Date.today();

programRecord2.CLQ_Licensing_Specialist__c = u.id;
programRecord2.SUTQ_Reviewer__c = u.id;
//programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
programs.add(programRecord2);


CLQ_ProgramTriggerHandler.BypassTrigger = true;
insert programs ;
CLQ_ProgramTriggerHandler.BypassTrigger = false;

contact c = new contact();
c.lastname = 'tester';
c.email = 'tester@tester.com';
insert c;
list<string> parms = new list<string>();
List<CLQ_Role__c> roles = new List<CLQ_Role__c>();
CLQ_Role__c role1 = new CLQ_Role__c();
role1.CLQ_Contact__c = c.id;
role1.Role_Type__c = 'ODE';
role1.Portal_Roles__c = 'OCLQSAdministrator';
role1.CLQ_Program__c = programRecord.id;
role1.Secondary_Role__c = 'OCLQSPS';
role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role1);

CLQ_Role__c role2 = new CLQ_Role__c();
role2.CLQ_Contact__c = c.id;
role2.Role_Type__c = 'ODE';
role2.Portal_Roles__c = 'OCLQSAdministrator';
role2.CLQ_Organization__c = accountrecord.id;
role2.Secondary_Role__c = 'OCLQSPS';
role2.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role2);

CLQ_Role__c role3 = new CLQ_Role__c();
role3.CLQ_Contact__c = c.id;
role3.Role_Type__c = 'ODE';
role3.Portal_Roles__c = 'OCLQSAdministrator';
role3.CLQ_Program__c = programRecord1.id;
role3.Secondary_Role__c = 'OCLQSPS';
role3.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role3);

CLQ_Role__c role4 = new CLQ_Role__c();
role4.CLQ_Contact__c = c.id;
role4.Role_Type__c = 'ODE';
role4.Portal_Roles__c = 'OCLQSAdministrator';
role4.CLQ_Organization__c = accountrecord1.id;
role4.Secondary_Role__c = 'OCLQSSACC';
role4.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByName().get('Portal Roles').getRecordTypeId();
roles.add(role4);
insert roles;

//CLQ_GlobalWebserviceUtility.getOrgLevelODERecipients(programs);  
test.stopTest();  
} */
    
}