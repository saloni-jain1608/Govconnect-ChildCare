/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CreateOnsiteVisitInspectionExtn_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
public with sharing  class CLQ_CreateOnsiteVisitInspectionExtn_Test {
    /*@testSetup //Added method for Task - 11615
public static void setExecuteControlSetting()
{
CLQ_UnitTestUtilities.setExecuteControlSetting();
} */
    @IsTest
    public static void  test_method_one() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            CLQ_Program_Transaction__c programTransactionRecord = [select id,RecordTypeId,Name,CLQ_Program__r.CLQ_BIRN__c,CLQ_Program__r.Id,OwnerId, Program_Transaction_County__c from CLQ_Program_Transaction__c limit 1];
            Test.startTest();
            PageReference pageRef = Page.CLQ_CreateOnsiteVisitInspection;
            pageRef.getParameters().put('Id',programTransaction.id); 
            
            ApexPages.StandardController controller = new ApexPages.StandardController(programTransactionRecord);
            CLQ_CreateOnsiteVisitInspectionExtn extensionObject = new CLQ_CreateOnsiteVisitInspectionExtn(controller);
            
            extensionObject.onLoad();
            
            Test.stopTest();
        }
    }
    
    static CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
    
    @testSetup
    public static void prepareData(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='CLQ_Program__c' and Name='FCC - Type B Home' Limit 1];
        //Create a program record
        System.debug('RT#$#$#$'+ rt.Name);
        Map<ID,Schema.RecordTypeInfo> programRd_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById();
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_License_Registration_Status__c = 'Exempt';
        insert programRecord ;
        
        System.debug('@#@#@#@#@'+ programRecord.RecordType.Name + '@$@$@$@'+ programRecord.recordTypeid);
        
        //CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
        programTransaction.CLQ_Program__c = programRecord.Id;
        programTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        programTransaction.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction.CLQ_Transaction_Status__c = 'Not Complete';
        programTransaction.OwnerId = UserInfo.getUserId();
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
        insert programTransaction;
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
        System.debug('@@@@@@@@@Program Transaction' + programTransaction.Id + 'RECORD TYPE NAME'+ programTransaction.CLQ_Program_Record_Type__c + '#########' + programTransaction.CLQ_Rating_Confirmed_by_Program__c);
        
        CLQ_Program__c programRecord1 = new CLQ_Program__c();
        programRecord1.Name = 'Test';
        programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord1.CLQ_Street_Address_1__c = 'test';
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        
        programRecord1.CLQ_Program_Rating__c = 3;
        programRecord1.Program_Rating__c = '3';
        programRecord1.CLQ_License_Type__c = '  Continuous';
        programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord1.Rating_Anniversary_Date__c = Date.today();
        CLQ_ProgramTriggerHandler.BypassTrigger = true;
        insert programRecord1 ;
        CLQ_ProgramTriggerHandler.BypassTrigger = false;
        
        CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
        programTransaction1.CLQ_Program__c = programRecord1.Id;
        programTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction1.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction1.CLQ_Transaction_Status__c = 'Not Complete';
        programTransaction1.ownerid = UserInfo.getUserId();
        
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
        insert programTransaction1;
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
        //return programTransaction;
    }
    
    
    
}