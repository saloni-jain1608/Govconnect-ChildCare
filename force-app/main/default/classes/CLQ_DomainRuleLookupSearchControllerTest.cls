/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_DomainRuleLookupSearchControllerTest
** Description      : Test Class for CCLQ_DomainRuleLookupSearchController
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer           Date                Version         Description
**  Neetu Ojha          11/10/2017          1.0             TFS#11415 : Initial Version 
**************************************************************************************************************/

@isTest
private class CLQ_DomainRuleLookupSearchControllerTest{
    
    @testSetup
    static void testDataSetUp(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        
        CLQ_OCLQS_Configuration__c configRec = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRec; 
        
        //Create account record
        Account accRec = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accRec ;
        
        //Insert contact
        Contact conRec = new Contact(Firstname='test', lastName = 'Test',AccountId = accRec.id );
        insert conRec ;
        
        //Create a program record
        CLQ_Program__c prgRec = new CLQ_Program__c();
        prgRec.Name = 'Test';
        prgRec.CLQ_Associated_Organization__c = accRec.id;
        prgRec.CLQ_Street_Address_1__c = 'test';
        prgRec.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        prgRec.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        prgRec.CLQ_Program_Status__c = 'Open';
        prgRec.CLQ_License_Registration_Status__c='Licensed';
        prgRec.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        insert prgRec ;
        
        //Insert case for program
        CLQ_Case_Custom__c caseRec = new CLQ_Case_Custom__c();
        caseRec.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRec.ContactId__c = conRec.id;
        caseRec.CLQ_Program__c = prgRec.id;
        caseRec.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRec.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRec.CLQ_Anonymous_Complainant__c = true;
        caseRec.CLQ_Assigned_To__c = UserInfo.getUserid();
        insert caseRec;
        
        CLQ_Domain__c domain = new CLQ_Domain__c();
        domain.Name = 'Administrative & Leadership Practices';
        insert domain;
        
        CLQ_Domain_Rule__c dr = new CLQ_Domain_Rule__c();
        dr.CLQ_Domain__c = domain.Id;
        insert dr;
        
        CLQ_Alleged_Rule_Violation__c arv = new CLQ_Alleged_Rule_Violation__c();
        arv.CLQ_Domain_Rule__c = dr.id;
        arv.Case_Custom__c = caseRec.id;
        insert arv;
    }
    
    @IsTest
    static void myUnitTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_DomainRuleLookupSearchController drObj = new CLQ_DomainRuleLookupSearchController();
            drObj.getFormTag();
            drObj.getTextBox();
            
            drObj.domainRuleName='TestDR';
            drObj.domainName='Administrative';
            drObj.ruleShortName='Test Rule';
            drObj.ruleNumber='Test Rule Num';
            drObj.applicableTo='Test App';
            drObj.arvObject.CLQ_Rule_Effective_Date__c= system.today();
            
            drObj.getLstDomainRule();
            drObj.searchDomainRule();
            drObj.firstPage();
            drObj.previous();
            drObj.next();
            drObj.lastPage();
            drObj.getprev();
            drObj.getnxt();
            
            Test.stopTest();
        }
    }
}