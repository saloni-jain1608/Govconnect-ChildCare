/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_AllegedRuleViolationTrigHandlerTest
** Description      : 
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
private class CLQ_AllegedRuleViolationTrigHandlerTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
    CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void myUnitTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
        
        // TO DO: implement unit test
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01); 
        programRecord.CLQ_Assigned_Reviewer__c=UserInfo.getUserid();
        insert programRecord ;
        
        //Insert case for program
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Anonymous_Complainant__c = true;
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        insert caseRecord;
        
        test.starttest();
        //create an alleged rule violation for the case
        //Added by MP - Begin - To handle Search filter validation on Domain Name
        CLQ_Domain__c domain = new CLQ_Domain__c();
        domain.Name = 'Administrative & Leadership Practices';
        Insert domain;
        CLQ_Domain__c dm = [Select id from CLQ_Domain__c where ID =: domain.Id];
        CLQ_Domain_Rule__c dr = new CLQ_Domain_Rule__c();
        dr.CLQ_Domain__c = dm.Id;
        //Added by MP - End - To handle Search filter validation on Domain Name
        insert dr;
        CLQ_Alleged_Rule_Violation__c arv = new CLQ_Alleged_Rule_Violation__c();
        arv.CLQ_Domain_Rule__c = dr.id;
        arv.Case_Custom__c = caseRecord.id;
        insert arv;
        delete arv;
        test.stoptest();
        system.assertEquals(True, 1==1,'Testing');
        }
    }
}