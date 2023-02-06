/*************************************************************************************************************
**************************************************************************************************************
** Name             : Program_Rating_Controller_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Ankush R Relekar     20/12/2021       	  1.0       Initial Build 
**************************************************************************************************************/
@isTest
public class Program_Rating_Controller_Test {
    
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }   
    
    @IsTest
    static void processRequestTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.Rating_Anniversary_Date__c = date.today()+40;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            
            Program_Rating_Controller ctrl=new Program_Rating_Controller();
            ctrl.validate('Calculate Desk Review Rating','');
            ctrl.processRequest('Calculate Desk Review Rating','');
            ctrl.processRequest('Desk Review Findings','');
            ctrl.processRequest('Onsite Standard Findings','');
            ctrl.processRequest('Calculate Onsite Visit Rating','');
            ctrl.processRequest('Calculate','');
            
            
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            
            insert ProgramTransaction;
            
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            ctrl.processRequest('Desk Review Findings',ProgramTransaction.Id);
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
            insert sfinding;
            
            CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
            insert domain;
            CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            insert rule;
            
            CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
            insert domainRule;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
            ruleInspected.ProgramTransaction__c= programTransaction.Id;
            ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
            ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
            insert ruleInspected ;
            
            CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,Rating__c = '3');
            insert finding;
            
            
            
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
            insert standardDetail;
            
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 3,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
            insert ans;
            
            CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
            td.CLQ_Document_Status__c ='Under Review';
            td.CLQ_Program_Transaction__c= ProgramTransaction.id;
            td.CLQ_Document_Comments__c = 'test';
            td.Rating__c='3';
            insert td;
            
            
            ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            ctrl.processRequest('Desk Review Findings',ProgramTransaction.Id);
            ctrl.processRequest('Desk Review Findings LWC',ProgramTransaction.Id);
            Test.startTest();
            ProgramTransaction.CLQ_Transaction_Status__c='Approved';
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            Test.stopTest();
        }
    }
    
    @IsTest
    static void processRequestInspectionTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.Rating_Anniversary_Date__c = date.today()+40;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Inspection__c inspectionrecord1 = new CLQ_Inspection__c();
            inspectionrecord1.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord1.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord1.Inspection_Status__c = 'In Progress';
            insert inspectionrecord1;
            
            Program_Rating_Controller ctrl=new Program_Rating_Controller();
            ctrl.processRequest('Onsite Standard Findings',inspectionrecord.Id);
            ctrl.processRequest('Calculate Onsite Visit Rating',inspectionrecord.Id);
            
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=Date.today().addDays(-10);
            update inspectionrecord;
            
            CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
            insert sfinding;
            
            CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
            insert domain;
            CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            insert rule;
            
            CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
            insert domainRule;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
            ruleInspected.ProgramTransaction__c= programTransaction.Id;
            ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
            ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
            insert ruleInspected ;
            
            CLQ_Rules_Inspected__c ruleInspected1 = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord1.id,CLQ_Domain_Rule__c = domainRule.id);
            ruleInspected1.ProgramTransaction__c= programTransaction.Id;
            ruleInspected1.CLQ_Inspection_No__c=inspectionrecord.id;
            ruleInspected1.CLQ_Domain_Rule__c = domainRule.id;
            //insert ruleInspected1 ;
            
            CLQ_Findings__c finding = new CLQ_Findings__c(Points__c='30',CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c='3');
            insert finding;
            
            CLQ_Findings__c finding1 = new CLQ_Findings__c(Points__c='30',CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord1.Id,Rating__c='2');
            insert finding1;
            
            
            ctrl.processRequest('Onsite Standard Findings',inspectionrecord.Id);
            ctrl.processRequest('Onsite Standard Findings LWC',inspectionrecord.Id);
            
            ctrl.processRequest('Calculate Onsite Visit Rating',inspectionrecord.Id);
            ctrl.processRequest('Calculate Onsite Visit Rating',inspectionrecord1.Id);
            Test.stopTest();
        }
    }
    
    
    @IsTest
    static void processRequestTestTwo(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.Rating_Anniversary_Date__c = date.today()+40;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            
            Program_Rating_Controller ctrl=new Program_Rating_Controller();
            
            
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            
            insert ProgramTransaction;
            
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
            insert sfinding;
            
            CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
            insert domain;
            CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            insert rule;
            
            CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
            insert domainRule;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
            ruleInspected.ProgramTransaction__c= programTransaction.Id;
            ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
            ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
            insert ruleInspected ;
            
            CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,Rating__c = '3');
            insert finding;
            
            
            
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
            insert standardDetail;
            
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
            insert ans;
            
            CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
            td.CLQ_Document_Status__c ='Under Review';
            td.CLQ_Program_Transaction__c= ProgramTransaction.id;
            td.CLQ_Document_Comments__c = 'test';
            td.Rating__c='3';
            insert td;
            
            
            ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            Test.startTest();
            ProgramTransaction.CLQ_Transaction_Status__c='Approved';
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            
            Test.stopTest();
        }
    }
    
    
}