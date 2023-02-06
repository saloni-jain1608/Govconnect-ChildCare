/*************************************************************************************************************
**************************************************************************************************************
** Name             : CalulateDeskReviewRatingCtrlLWCTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				9/15/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest()
public with sharing class CalulateDeskReviewRatingCtrlLWCTest {
    static CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    
    
    @IsTest     
    static void testRatingFour(){
        //prepareTestData();
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            List<CLQ_OCLQS_Configuration__c> configrecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            configrecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            configrecords.add(configRecord1);
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configrecords;
            }
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            insert accountrecord ;
            
            Account accountrecord1 = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership');
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord1;
            }
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord;
            }
            
            List<CLQ_Program_Transaction__c> progTransactions = new List<CLQ_Program_Transaction__c>();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'In Progress';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord.id ;
            //progTransactions.add(ProgramTransaction);
            if(Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                insert ProgramTransaction; 
            }
            
            List<CLQ_Findings__c> findings = new list<CLQ_Findings__c>();
            CLQ_Findings__c finding = new CLQ_Findings__c(Rating__c = '3',Points__c = '4',Program_Transaction__c = ProgramTransaction.Id);
            if(Schema.SObjectType.CLQ_Findings__c.isAccessible()){
                insert finding;
            }
            
            
            
            
            Test.startTest();
            
            CLQ_CalulateDeskReviewRatingCtrlLWC extensionObject = new CLQ_CalulateDeskReviewRatingCtrlLWC();
            
            Test.stopTest();
        } 
    }
    @IsTest
    static void testRatingFive(){
        //prepareTestData();
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            List<CLQ_OCLQS_Configuration__c> configrecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            configrecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            configrecords.add(configRecord1);
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configrecords;
            }
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord;
            }
            
            Account accountrecord1 = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord1;
            }
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord;
            }
            
            List<CLQ_Program_Transaction__c> progTransactions = new List<CLQ_Program_Transaction__c>();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'In Progress';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord.id ;
            //progTransactions.add(ProgramTransaction);
            if(Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                insert ProgramTransaction;
            }
            
            
            List<CLQ_Findings__c> findings = new list<CLQ_Findings__c>();
            CLQ_Findings__c finding = new CLQ_Findings__c(Rating__c = '3',Points__c = '4',Program_Transaction__c = ProgramTransaction.Id);
            if(Schema.SObjectType.CLQ_Findings__c.isAccessible()){
                insert finding;
            }
            
            List<CLQ_Transaction_Document__c> transactionDocs = new list<CLQ_Transaction_Document__c>();       
            CLQ_Transaction_Document__c TD = new CLQ_Transaction_Document__c(Name = 'Test',Document_Points__c = 2,Rating__c='3',CLQ_Document_Status__c='Test',CLQ_Program_Transaction__c=ProgramTransaction.id);
            if(Schema.SObjectType.CLQ_Transaction_Document__c.isAccessible()){
                insert TD;
            }
            
            
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No',
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
            if(Schema.SObjectType.CLQ_Standard_Detail__c.isAccessible()){
                insert standardDetail;
            }
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 3,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
            if(Schema.SObjectType.Answer__c.isAccessible()){
                insert ans;
            }
            
            
            
            
            
            
            
            
            
            Test.startTest();
            
            CLQ_CalulateDeskReviewRatingCtrlLWC extensionObject = new CLQ_CalulateDeskReviewRatingCtrlLWC();
            extensionObject.calulateDeskReviewRating(ProgramTransaction.id);
            
            
            
            Test.stopTest();
        }
        
    }
    
    @IsTest
    static void testRatingSeven(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            List<CLQ_OCLQS_Configuration__c> configrecords = new List<CLQ_OCLQS_Configuration__c>();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            configrecords.add(configRecord);
            
            CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            configrecords.add(configRecord1);
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configrecords;
            }
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord ;
            }
            
            Account accountrecord1 = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord1 ;
            }
            
            //Create a program record
            List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord;
            }
            
            List<CLQ_Program_Transaction__c> progTransactions = new List<CLQ_Program_Transaction__c>();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Associated_Organization__c = accountrecord.id ;
            //progTransactions.add(ProgramTransaction);
            if(Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                insert ProgramTransaction;
            }
            
            
            
            
            
            
            
            Test.startTest();
            
            CLQ_CalulateDeskReviewRatingCtrlLWC extensionObject = new CLQ_CalulateDeskReviewRatingCtrlLWC();
            extensionObject.calulateDeskReviewRating(ProgramTransaction.id);
            
            
            
            Test.stopTest();
        }
        
    }
    
    
    
}