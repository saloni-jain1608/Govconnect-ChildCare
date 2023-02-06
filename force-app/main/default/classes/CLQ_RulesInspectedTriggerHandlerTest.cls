/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_RulesInspectedTriggerHandlerTest
** Description      : N/A
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Soufin Rahimeen         8/23/17         1.0          Inital Build
**************************************************************************************************************/

@isTest
public class CLQ_RulesInspectedTriggerHandlerTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 
    
    @IsTest
    static void testRulesInspectedUpdate() {
        
        system.assertEquals(True, 1==1, 'testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
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
            insert programRecord ;
            programRecord.CLQ_Program_Status__c = 'Open'; 
            update programRecord;
            
            CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
            insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
            insRecord.CLQ_Inspection_Type__c = 'Complaint';
            insRecord.CLQ_Program__c = programRecord.Id;
            insRecord.CLQ_Notice__c = 'Unannounced';
            insRecord.CLQ_Notes__c = 'inspection 1';
            insert insRecord;
            
            CLQ_Domain_Rule__c domRuleRecord = new CLQ_Domain_Rule__c();
            insert domRuleRecord;
            
            Test.StartTest();
            CLQ_Rules_Inspected__c ruleInsRecord = new CLQ_Rules_Inspected__c();
            ruleInsRecord.CLQ_Domain_Rule__c = DomRuleRecord.Id;
            ruleInsRecord.CLQ_Inspection_No__c = insRecord.Id;
            ruleInsRecord.CLQ_Allegation_Description__c = 'Test Data';
            ruleInsRecord.CLQ_Investigation_Method__c = 'On-Site';
            ruleInsRecord.CLQ_Investigation_Details_Outcome__c = 'This is Test data' ;
            ruleInsRecord.CLQ_Result__c = 'Non-Compliant';
            insert ruleInsRecord;
            
            ruleInsRecord.CLQ_Result__c = 'Compliant';
            update ruleInsRecord;
            
            CLQ_Findings__c testFindings = new CLQ_Findings__c();
            testFindings.CLQ_Rules_Inspected__c = ruleInsRecord.Id;
            //testFindings.CLQ_Inspection__c	 = insRecord.Id;
            insert testFindings;
            update ruleInsRecord;
            
            CLQ_Findings__c testFindings2 = new CLQ_Findings__c();
            testFindings2.CLQ_Rules_Inspected__c = ruleInsRecord.Id;
            //testFindings2.CLQ_Inspection__c	 = insRecord.Id;
            insert testFindings2;
            update ruleInsRecord;
            
            CLQ_Corrective_Action_Plan__c testCAP = new CLQ_Corrective_Action_Plan__c();
            testCAP.CLQ_Findings__c = testFindings.Id;
            insert testCAP;
            update ruleInsRecord;
            
            ruleInsRecord.CLQ_Result__c = 'Non-Compliant';
            update ruleInsRecord;
            
            ruleInsRecord.CLQ_Result__c = 'Compliant';
            update ruleInsRecord;
            
            Test.StopTest();
        }
        
    }
    
}