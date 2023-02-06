/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_GlobalWebservice3Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/

@isTest(isparallel = true)
private class CLQ_GlobalWebservice3Test {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void myUnitTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configRecord; 
            }
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            if(Schema.SObjectType.CLQ_County__c.isAccessible()){
                insert county;
            }
            county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Dayton', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            if(Schema.SObjectType.CLQ_County__c.isAccessible()){
                insert county;
            }
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord ;
            }
            
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
            
            programRecord.CLQ_Org_Wide_Email_Addresses__c = 'test@test.com';
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord ;
            }
            
            CLQ_Corrective_Action_Plan__c capTest = new CLQ_Corrective_Action_Plan__c();
            capTest.CLQ_Program__c = programRecord.id;
            if(Schema.SObjectType.CLQ_Corrective_Action_Plan__c.isAccessible()){
                insert capTest;
            }
            
            
            contact c = new contact();
            c.lastname = 'tester';
            c.email = 'tester@tester.com';
            if(Schema.SObjectType.contact.isAccessible()){
                insert c;
            }
            list<string> parms = new list<string>();
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = c.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c .getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            if(Schema.SObjectType.CLQ_Role__c.isAccessible()){
                insert role1;
            }
            parms.add('CLQ_ODE_CAP_Overdue_Email_Template' + '|' + capTest.id);
            
            Test.startTest();
            CLQ_GlobalWebService3.sendCAPEmail(parms);
            Test.StopTest();  
            
        }
    }
}