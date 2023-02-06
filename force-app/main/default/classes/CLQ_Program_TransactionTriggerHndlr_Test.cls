/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_Program_TransactionTriggerHndlr_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
private class CLQ_Program_TransactionTriggerHndlr_Test {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
    CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    static testMethod void InsertTest() {
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
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        
        list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>();
        list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        
        //Before Insert
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, null, OldList, null,
                        true, true, false, false, 
                        true, false, false, 1);
        //system.AssertEquals('BeforeInsert', Handler.TriggerExecutionType);
        Handler.ProcessTrigger(); 
        system.AssertEquals(false, Handler.HasAlreadyUpdated);
        
        //AfterInsert
        Handler = new CLQ_Program_TransactionTriggerHandler(NewList, null, OldList, null,
                        true, true, false, false, 
                        false, true, false, 1);
        //system.AssertEquals('AfterInsert', Handler.TriggerExecutionType);
        Handler.ProcessTrigger();
        system.AssertEquals(false, Handler.HasAlreadyUpdated);
        
    } 
      
    
    /*static testMethod void UpdateTest() {
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
    
        CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
        insert county;
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
         User u = new User(

            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'

        );
        Insert u;
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - FCC - Change of Location').getRecordTypeId();
        ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
       
        
        try
        {
            insert ProgramTransaction;
            system.Assert(false, 'This should have thrown an Exception');
        }
        catch(Exception exc)
        {
            system.Assert(exc.getMessage().contains('The Program is a required field for a Program Tranaction'), 'Incorrect Error message: ' + exc.getMessage());
        }        
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        insert ProgramTransaction;

        CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransaction.clone(true, true, true, true);
        
        ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
        ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
        ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
        ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
        ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
        ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
        ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
        ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
        ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
        ProgramTransaction.ownerid = u.id;
        ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
        
        list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{OldProgramTransaction};
        list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{OldProgramTransaction.id => OldProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
        
        //BeforeUpdate
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        system.AssertEquals('BeforeUpdate', Handler.TriggerExecutionType);
        Handler.ProcessTrigger(); 
        //system.AssertEquals(false, Handler.HasAlreadyUpdated); //For a new Version
        
        //AfterUpdate
        Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        false, true, false, 1);
        system.AssertEquals('AfterUpdate', Handler.TriggerExecutionType);
        Handler.ProcessTrigger();
        system.AssertEquals(true, Handler.HasAlreadyUpdated);
        
    }*/
    
   
    //Anil Adding SUTQ test methods
    static testMethod void InsertSUTQInitialPTTest() {
        test.startTest();
        	
        	
         
        	
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
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
                    //PA
            programRecord.AR_Anniv_Date_120_Days_away__c = false;
            programRecord.Initial_Registration_Not_Allowed__c = false;
            programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            programRecord.Rating_Effective_Date__c = system.today().adddays(-1);//RR earlier .adddays(3);
            programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            programRecord.RatingChangedDate__c = system.today();
            programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            programRecord.Rating_Effective_Dt__c = system.today();//RR
        	programRecord.Registration_In_Progress__c=False;
            insert programRecord ;

            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Submitted';
            insert ProgramTransaction;
        
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
            list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>();
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>();
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
          
        
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.checkforPrg_PTrecordtypeStatus(NewList);
        
    
       test.stopTest();
    }
    //PA
    static testMethod void test1(){
         test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            Account accountrecord1 = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
            insert accountrecord1;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
                    //PA
            programRecord.AR_Anniv_Date_120_Days_away__c = false;
            programRecord.Initial_Registration_Not_Allowed__c = false;
            programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();
            programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            programRecord.RatingChangedDate__c = system.today();
            programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord ;
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord1.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            insert programRecord1;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Submitted';
            insert ProgramTransaction;
            
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord1.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Submitted';
            insert ProgramTransaction1;
            
            /*Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk, tsk1};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;*/

            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
            
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist',Domain__c = 'Learning & Development');
            CLQ_Standard_Detail__c standardDetail1 = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist',Domain__c = 'Administrative & Leadership Practices');
            insert new list<CLQ_Standard_Detail__c>{standardDetail, standardDetail1}; 
        	
                
                
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Met_Not_Met__c = 'Met',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
            Answer__c ans1 = new Answer__c(Name = 'Test1',Answer_Text__c= 'Test',Met_Not_Met__c = 'Not Met',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail1.Id, Program_Transaction__c = ProgramTransaction1.Id);
            insert new list<Answer__c>{ans,ans1};
                
                
            ProgramTransaction1.CLQ_Asbestos__c = 'No';
            //ProgramTransaction1.CLQ_Transaction_Status__c  = 'Submitted';
            //ProgramTransaction1.Recommended_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            //update ProgramTransaction1;
            ProgramTransaction.CLQ_Asbestos__c = 'No';
            //ProgramTransaction.Recommended_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;
        test.stopTest();
    }//PA - end
    //PA - start
    static testMethod void test2(){
            test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'School Age Child Care');
            insert configRecord; 
        
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
        
            CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
            CLQ_County__c county1 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert new list<CLQ_County__c>{county, county1};
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('School Age Child Care').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            //programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            programRecord.Rating_Reduction_Date__c=Date.today().addmonths(-2);
            programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Submitted';
            ProgramTransaction.Recommended_Rating__c = '0';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Deferral';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction.IsApproved_PrgTran__c = false;
            insert ProgramTransaction;
        
        	CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
         	ProgramTransaction1.Id=ProgramTransaction.Id;
         	ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Not Submitted';
            ProgramTransaction1.Recommended_Rating__c = '0';
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction1.IsApproved_PrgTran__c = false;
                        
            /*programRecord.Rating_Discontinue__c = Date.today().addmonths(-7);
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;*/
            Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            //Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
            roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
            roomSpace.CLQ_Currently_In_Use__c = 'No';
            roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
            roomSpace.CLQ_Room_Space_Number__c = '123';
            roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
            roomSpace.CLQ_Square_Footage_Irregular__c = 10;
            insert roomSpace;
            
            CLQ_Room_Space__c roSpace = new CLQ_Room_Space__c();
            roSpace.CLQ_Program__c = programRecord.id;
            roSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roSpace;
        
        	list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{ProgramTransaction1};
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction1.id => ProgramTransaction1};
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
               
         	CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
             

         	
         	//Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
         	//Handler.UpdateProgramFromTransaction(NewList,OldMap);
            //Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
            Handler.ValidateProgramRating(NewList,OldMap);
        
        test.stopTest();
        
    }//PA - End
    
    static testMethod void InsertSUTQOnGoingPTTest() {
        test.StartTest();
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
            programRecord.SUTQ_Reviewer__c  = UserInfo.getUserId();
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Submitted';
            insert ProgramTransaction;
        
        
        
        test.stopTest();
    } 

    /*
    static testMethod void UpdateSUTQTest() {
        test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            insert ProgramTransaction;
                        
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            update ProgramTransaction;
        test.StopTest();
        
    }
    */
    static testMethod void UpdateSUTQWithdrawTest() {
         
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
          
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;


            
            
            //CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransaction.clone(true, true, true, true);
       test.StartTest();    
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Withdraw';
            upsert ProgramTransaction;
        Test.stopTest();
    }
    
    static testMethod void UpdateSUTQCompleteTest() {
        test.startTest();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
    
        CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
        insert county;
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
        ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        insert ProgramTransaction;
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord.Inspection_Status__c = 'In Progress';
        insert inspectionrecord;
        
        
       // Task reviewTask = new task();
        //reviewTask.OwnerId = ProgramTransaction.OwnerId;
        //reviewTask.Subject = 'Review the Program Transaction';
        //reviewTask.Priority = 'Normal';
        //reviewTask.Status = 'Not Started';
        //reviewTask.Type = 'Action';
        //reviewTask.whatId = ProgramTransaction.Id;
        
        ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
        ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
        ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
        ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
        ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
        ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
        ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
        ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
        ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
        ProgramTransaction.ownerid = UserInfo.getUserId();
        ProgramTransaction.CLQ_Transaction_Status__c = 'Completed';
        upsert ProgramTransaction;
        test.stopTest();
    
    }
    
    static testMethod void UpdateSUTQSubmitTest() {
        test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.SUTQ_Reviewer__c  = UserInfo.getUserId();
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';        
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            Task reviewTask = new task();
            reviewTask.OwnerId = ProgramTransaction.OwnerId;
            reviewTask.Subject = 'Review the Program Transaction';
            reviewTask.Priority = 'Normal';
            reviewTask.Status = 'Not Started';
            reviewTask.Type = 'Action';
            reviewTask.whatId = ProgramTransaction.Id;
            
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            update ProgramTransaction;
        Test.stopTest();
        
    }
    
    /*
    static testMethod void UpdateSUTQInitialSubmitTest() {
        test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.SUTQ_Reviewer__c = UserInfo.getUserId();
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';        
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            insert ProgramTransaction;
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
              
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransaction.clone(true, true, true, true);
            
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            //update ProgramTransaction;
            System.debug('UPDATED VALUE OF PT'+ ProgramTransaction);
            
             list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{OldProgramTransaction};
        list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{OldProgramTransaction.id => OldProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
        
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, null, OldList, null,
                        true, true, false, false, 
                        true, false, false, 1);
        system.AssertEquals('BeforeInsert', Handler.TriggerExecutionType);
        //AfterUpdate
        Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        false, true, false, 1);
        system.AssertEquals('AfterUpdate', Handler.TriggerExecutionType);
        Handler.ProcessTrigger();
        system.AssertEquals(true, Handler.HasAlreadyUpdated);
       Test.stopTest();
        
    }
    */
     static testMethod void newTest() {
        test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_License_Type__c = 'Continuous' ;
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            programRecord.Program_Rating__c = '3';
            programRecord.RatingChangedDate__c = date.today().addDays(-365);
            programRecord.Rating_Anniversary_Date__c = date.today().addyears(1);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_License_Type__c = 'Continuous' ;
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            programRecord1.Program_Rating__c = '3';
            programRecord1.RatingChangedDate__c = date.today().addDays(-365);
            programRecord1.Rating_Anniversary_Date__c = date.today().addyears(1);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord1 ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';        
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            insert ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
              
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransaction.clone(true, true, true, true);
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction.IsApproved_PrgTran__c = false;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '2';
            ProgramTransaction.CLQ_Transaction_Status__c = 'Withdraw'; 
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
   
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
            System.debug('UPDATED VALUE OF PT'+ ProgramTransaction);
            
            
            
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Not Submitted';        
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            
            
            /****/
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction1.IsApproved_PrgTran__c = false;
            ProgramTransaction1.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction1.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction1.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction1.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction1.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction1.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction1.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = '2';
            /****/
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            insert ProgramTransaction1;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
             CLQ_Program_Transaction__c OldProgramTransaction1 = ProgramTransaction1.clone(true, true, true, true);
            CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            update ProgramTransaction1;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;

            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Not Submitted';        
            ProgramTransaction2.CLQ_Program__c = programRecord1.id;
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            
            
            /****/
            
                        
            ProgramTransaction2.Annual_Report_Overall_Requirements__c = 'Met';
            
            ProgramTransaction2.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction2.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction2.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction2.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction2.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction2.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction2.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction2.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction2.ownerid = UserInfo.getUserId();
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Submitted';
           // ProgramTransaction2.Recommended_Annual_Report_Rating__c = '2';
            /****/
             CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;

            insert ProgramTransaction2; 
             CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;

            ProgramTransaction2.IsApproved_PrgTran__c = true;
             list<CLQ_Program_Transaction__c>  NewListT = new list<CLQ_Program_Transaction__c>{ProgramTransaction2};
        map<id,CLQ_Program_Transaction__c>  NewMapT = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction2.id => ProgramTransaction2};
        CLQ_Program_TransactionTriggerHandler Handler1 = new CLQ_Program_TransactionTriggerHandler(NewListT, null, null, null,
                        true, true, false, false, 
                        true, false, false, 1);
                        
                         list<CLQ_Program_Transaction__c>  OldListT = new list<CLQ_Program_Transaction__c>{OldProgramTransaction};
                          map<id,CLQ_Program_Transaction__c>  OldMapT = new map<id,CLQ_Program_Transaction__c>{OldProgramTransaction.id => OldProgramTransaction};
                        Handler1 = new CLQ_Program_TransactionTriggerHandler(NewListT, NewMapT, OldListT, OldMapT,
                        true, false, true, false, 
                        false, true, false, 1);
            //Handler1.UpdateProgramFromTransaction(newListT,newmapT);
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
            update ProgramTransaction2;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;

             CLQ_Program_Transaction__c OldProgramTransaction2 = ProgramTransaction2.clone(true, true, true, true);
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;

            update ProgramTransaction2;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;

            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_License_Type__c = 'Continuous' ;
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord2.Rating_Anniversary_Date__c = date.today().addyears(1);

            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            programRecord2.Program_Rating__c = '3';
            programRecord2.RatingChangedDate__c = date.today().addDays(-365);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord2 ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            CLQ_Program_Transaction__c ProgramTransaction3 = new CLQ_Program_Transaction__c();
            ProgramTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId(); 
            ProgramTransaction3.CLQ_Program__c = programRecord2.id;
            ProgramTransaction3.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction3.IsApproved_PrgTran__c = true;
            
             ProgramTransaction3.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction3.Recommended_Rating__c = '0';
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;

            insert ProgramTransaction3;  
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;

             CLQ_Program_Transaction__c OldProgramTransaction3 = ProgramTransaction3.clone(true, true, true, true);
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;

            update ProgramTransaction3;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
           
            
             list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{OldProgramTransaction};
        list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{OldProgramTransaction.id => OldProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
        
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, null, OldList, null,
                        true, true, false, false, 
                        true, false, false, 1);
        //system.AssertEquals('BeforeInsert', Handler.TriggerExecutionType);
        //AfterUpdate
        /*Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        false, true, false, 1);
        system.AssertEquals('AfterUpdate', Handler.TriggerExecutionType);
        Handler.ProcessTrigger();
        system.AssertEquals(true, Handler.HasAlreadyUpdated);*/
       Test.stopTest();
        
    }
    
    
     static testMethod void newTest1() {
        test.startTest();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
        
            CLQ_County__c county = new CLQ_County__c(Name = 'Clark', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_License_Type__c = 'Continuous' ;
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            programRecord.Program_Rating__c = '3';
            programRecord.Rating_Effective_Date__c = date.today().addDays(-190);
            programRecord.RatingChangedDate__c = date.today().addDays(-365);
            programRecord.Rating_Anniversary_Date__c = date.today().addyears(1);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false;
            /*CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_License_Type__c = 'Continuous' ;
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            programRecord1.Program_Rating__c = '3';
            programRecord1.RatingChangedDate__c = date.today().addDays(-365);
            CLQ_ProgramTriggerHandler.BypassTrigger = true;
            insert programRecord1 ;
            CLQ_ProgramTriggerHandler.BypassTrigger = false; */
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Annual Report Disapproved';        
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
            
            //CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
              
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransaction.clone(true, true, true, true);
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
            ProgramTransaction.CLQ_ProgTrans_City__c = 'kljlaskjdoi';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
           // ProgramTransaction.CLQ_Transaction_Status__c = 'Withdraw'; 
            ProgramTransaction.IsPending__c = true;
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true; 
            insert ProgramTransaction;
CLQ_Program_TransactionTriggerHandler.BypassTrigger = false; 
            ProgramTransaction.IsApproved_PrgTran__c = true;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = true; 
            update ProgramTransaction;
             CLQ_Program_TransactionTriggerHandler.BypassTrigger = false; 

            System.debug('UPDATED VALUE OF PT'+ ProgramTransaction);
            
           
            
             list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{OldProgramTransaction};
        list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{OldProgramTransaction.id => OldProgramTransaction};
        map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
        
        CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, null, OldList, null,
                        true, true, false, false, 
                        true, false, false, 1);
        //system.AssertEquals('BeforeInsert', Handler.TriggerExecutionType);
        //AfterUpdate
        /*Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        false, true, false, 1);
        system.AssertEquals('AfterUpdate', Handler.TriggerExecutionType);
        Handler.ProcessTrigger();
        system.AssertEquals(true, Handler.HasAlreadyUpdated);*/
       Test.stopTest();
        
    }
    
   
    static testMethod void test_getRatings(){
        List<Answer__c> testList = new List<Answer__c>();

        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
          Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
         
        
        	CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            //programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            programRecord.Program_Rating__c='3';
            programRecord.Rating_Reduction_Date__c = system.today().addmonths(-2);
            programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
         	programRecord.CLQ_License_Issue_Date__c=Date.today().addmonths(4);
         	programRecord.CLQ_License_Registration_Status__c ='Licensed';
         	programrecord.CLQ_Reactivation_Date__c=system.today().addmonths(4);
            insert programRecord;
        
        CLQ_Program_Transaction__c cpt = CLQ_Test_Util.getCLQProgramTransaction();
        cpt.CLQ_Program__c=programRecord.id;
        //insert cpt;
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                           Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist',Domain__c = 'Learning & Development');
        insert standardDetail;
        Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = cpt.Id);
        testList.add(ans);
        insert ans;
        
    }
    
     static testMethod void test3(){
         
         	     
            test.startTest();
            
         CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
         

            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
         
         Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Email = 'NOREPLY@TEST.COM',Accountid = accountrecord.id );
        	insert contactrecord ;
         
        
            CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
            CLQ_County__c county1 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert new list<CLQ_County__c>{county, county1};
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            programRecord.Program_Rating__c='3';
            programRecord.Rating_Reduction_Date__c = system.today().addmonths(-2);
            programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
         	programRecord.CLQ_License_Issue_Date__c=Date.today().addmonths(4);
         	programRecord.CLQ_License_Registration_Status__c ='Licensed';
         	programrecord.CLQ_Reactivation_Date__c=system.today().addmonths(4);
            insert programRecord;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Rating Assessment Complete';
            ProgramTransaction.Recommended_Rating__c = '1';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '2';
         	ProgramTransaction.SUTQ_Deferral_Due_Date__c= Date.Today();
            ProgramTransaction.IsApproved_PrgTran__c = True;
            insert ProgramTransaction;
         

         	
         	
         	CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
         	ProgramTransaction1.Id=ProgramTransaction.Id;
         	ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Not Submitted';
            ProgramTransaction1.Recommended_Rating__c = '0';
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction1.IsApproved_PrgTran__c = false;
         	ProgramTransaction1.CLQ_Transaction_Status__c='Approver Review In Progress';
            
             
         	
        
                        
            /*programRecord.Rating_Discontinue__c = Date.today().addmonths(-7);
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;*/
            Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            //Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
            roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
            roomSpace.CLQ_Currently_In_Use__c = 'No';
            roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
            roomSpace.CLQ_Room_Space_Number__c = '123';
            roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
            roomSpace.CLQ_Square_Footage_Irregular__c = 10;
            insert roomSpace;
            
            CLQ_Room_Space__c roSpace = new CLQ_Room_Space__c();
            roSpace.CLQ_Program__c = programRecord.id;
            roSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roSpace;
         
         	list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{ProgramTransaction1};
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction1.id => ProgramTransaction1};
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
         
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        	User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and Profile.name!=null and UserRole.name!=null and (NOT Profile.name like '%Admin%') limit 1];

      
         	CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
         	system.runAs(oUsr){
            Handler.FccCheckQueueMembersApproving(NewList,OldMap);
        	}
         	
            Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
            //Handler.UpdateProgramFromTransaction(NewList,NewMap);
          	Handler.ValidateProgramRating(NewList,OldMap);
         	Handler.copyRoomSpaceTransactionToRmSpaceInfo(NewList,OldMap);
         
         	
         	
         	delete(ProgramTransaction);
         
        test.stopTest();
        
    }//PA - End
    
    
         static testMethod void test4(){
         
         	     
            test.startTest();
            
         CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
         
         	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        	User usr = new User(LastName = 'LIVESTON',
            FirstName = 'JASON',
            Alias = 'jliv',
            Email = 'jason.liveston@asdf.com',
            Username = 'jason.liveston@abcdefg8395023.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        	);
        	//insert usr;
         
          	
        
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
         
         Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Email = 'NOREPLY@TEST.COM',Accountid = accountrecord.id );
        	insert contactrecord ;
         
        
            CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
            CLQ_County__c county1 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert new list<CLQ_County__c>{county, county1};
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            //programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Outdoor Space Information').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Submitted';
            ProgramTransaction.Recommended_Rating__c = '0';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction.IsApproved_PrgTran__c = false;
         	ProgramTransaction.SUTQ_Deferral_Due_Date__c= Date.Today();
            insert ProgramTransaction;
         	
         	CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
         	ProgramTransaction1.Id=ProgramTransaction.Id;
         	ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Not Submitted';
            ProgramTransaction1.Recommended_Rating__c = '0';
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction1.IsApproved_PrgTran__c = false;
             
   
            
             
         	
        
                        
            /*programRecord.Rating_Discontinue__c = Date.today().addmonths(-7);
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;*/
            Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            //Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
            roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
            roomSpace.CLQ_Currently_In_Use__c = 'No';
            roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
            roomSpace.CLQ_Room_Space_Number__c = '123';
            roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
            roomSpace.CLQ_Square_Footage_Irregular__c = 10;
            insert roomSpace;
            
            CLQ_Room_Space__c roSpace = new CLQ_Room_Space__c();
            roSpace.CLQ_Program__c = programRecord.id;
            roSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roSpace;
         
         	list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{ProgramTransaction1};
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction1.id => ProgramTransaction1};
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
               
         	CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
             
     
         	Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
            //Handler1.UpdateSutqExpediteRatingonProg(NewList1,OldMap1);
         	Handler.copyRoomSpaceTransactionToRmSpaceInfo(NewList,OldMap);
         	
         
        test.stopTest();
        
    }//PA - End
    
            static testMethod void test5(){
         
         	     
            test.startTest();
            
         CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
         
         	Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        	User usr = new User(LastName = 'LIVESTON',
            FirstName = 'JASON',
            Alias = 'jliv',
            Email = 'jason.liveston@asdf.com',
            Username = 'jason.liveston@abcdefg8395023.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        	);
        	//insert usr;
         
          	
        
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
         
         Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Email = 'NOREPLY@TEST.COM',Accountid = accountrecord.id );
        	insert contactrecord ;
         
        
            CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
            CLQ_County__c county1 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert new list<CLQ_County__c>{county, county1};
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.Rating_Discontinue__c=Date.today().addmonths(-5);
            programRecord.Rating_Reduction_Date__c=Date.today().addmonths(-2);
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            //programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            programRecord.Program_Rating__c='3';
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Rating Assessment Complete';
            ProgramTransaction.Recommended_Rating__c = '1';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            ProgramTransaction.IsApproved_PrgTran__c = True;
         	ProgramTransaction.SUTQ_Deferral_Due_Date__c= Date.Today();
            insert ProgramTransaction;
         	
         	CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
         	ProgramTransaction1.Id=ProgramTransaction.Id;
         	ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Not Submitted';
            ProgramTransaction1.Recommended_Rating__c = '0';
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction1.IsApproved_PrgTran__c = false;
            ProgramTransaction1.CLQ_Transaction_Status__c='Approver Review In Progress';
             
            
            
             
         	
        
                        
            /*programRecord.Rating_Discontinue__c = Date.today().addmonths(-7);
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;*/
            Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            //Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
            roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
            roomSpace.CLQ_Currently_In_Use__c = 'No';
            roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
            roomSpace.CLQ_Room_Space_Number__c = '123';
            roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
            roomSpace.CLQ_Square_Footage_Irregular__c = 10;
            insert roomSpace;
            
            CLQ_Room_Space__c roSpace = new CLQ_Room_Space__c();
            roSpace.CLQ_Program__c = programRecord.id;
            roSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roSpace;
         
         	list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{ProgramTransaction1};
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction1.id => ProgramTransaction1};
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
               
         	CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
             

         	
         	//Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
         	//Handler.UpdateProgramFromTransaction(NewList,OldMap);
            Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
            Handler.ValidateProgramRating(NewList,OldMap);
          
         	//Handler.copyRoomSpaceTransactionToRmSpaceInfo(NewList,OldMap);
         	
         
        test.stopTest();
        
    }//PA - End
    
    
        static testMethod void test6(){
         
         	     
            test.startTest();
            
         CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord; 
         
         	
          	
        
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            insert accountrecord;
         
         Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Email = 'NOREPLY@TEST.COM',Accountid = accountrecord.id );
        	insert contactrecord ;
         
        
            CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
            CLQ_County__c county1 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert new list<CLQ_County__c>{county, county1};
                
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.Rating_Discontinue__c=Date.today().addmonths(-5);
            programRecord.Rating_Reduction_Date__c=Date.today().addmonths(-2);
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Child Care Center').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            //programRecord.Rating_Expiration_Date__c = system.today().addYears(1);
            programRecord.Program_Rating__c='3';
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord;
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.CLQ_County__c = county.Id;
            programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord1.Rating_Discontinue__c=Date.today().addmonths(-5);
            programRecord1.Rating_Reduction_Date__c=Date.today().addmonths(-2);
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Child Care Center').getRecordTypeId();
            programRecord1.Program_Rating__c='3';
            //programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord1;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord1.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Rating Assessment Complete';
            ProgramTransaction.Recommended_Rating__c = '0';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction.IsApproved_PrgTran__c = True;
         	ProgramTransaction.SUTQ_Deferral_Due_Date__c= Date.Today();
            insert ProgramTransaction;
         	
         	CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
         	ProgramTransaction1.Id=ProgramTransaction.Id;
         	ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.ownerid = UserInfo.getUserId();
            ProgramTransaction1.CLQ_Transaction_Status__c  = 'Not Submitted';
            ProgramTransaction1.Recommended_Rating__c = '0';
            ProgramTransaction1.Annual_Report_Overall_Requirements__c = 'Met';
            ProgramTransaction1.Recommended_Annual_Report_Rating__c = null;
            ProgramTransaction1.IsApproved_PrgTran__c = false;
            ProgramTransaction1.CLQ_Transaction_Status__c='Approver Review In Progress';
             
            
            
             
         	
        
                        
            /*programRecord.Rating_Discontinue__c = Date.today().addmonths(-7);
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '0';
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;*/
            Task tsk = new Task(Subject = 'Test Subject', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', whatId = ProgramTransaction.Id);
            //Task tsk1 = new Task(Subject = 'Test1 Subject1', Priority = 'Normal', OwnerId =UserInfo.getUserId(), Status = 'Open', WhatId = ProgramTransaction1.Id);
            insert new list<Task>{tsk};
                     
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
            roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
            roomSpace.CLQ_Currently_In_Use__c = 'No';
            roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
            roomSpace.CLQ_Room_Space_Number__c = '123';
            roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
            roomSpace.CLQ_Square_Footage_Irregular__c = 10;
            insert roomSpace;
            
            CLQ_Room_Space__c roSpace = new CLQ_Room_Space__c();
            roSpace.CLQ_Program__c = programRecord.id;
            roSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roSpace;
         
         	list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>{ProgramTransaction1};
        	list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>{ProgramTransaction};
        	map<id,CLQ_Program_Transaction__c>  OldMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction1.id => ProgramTransaction1};
        	map<id,CLQ_Program_Transaction__c>  NewMap = new map<id,CLQ_Program_Transaction__c>{ProgramTransaction.id => ProgramTransaction};
               
         	CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                        true, false, true, false, 
                        true, false, false, 1);
             

         	
         	//Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
         	
            Handler.UpdateSutqExpediteRatingonProg(NewList,OldMap);
           
            Handler.ValidateProgramRating(NewList,OldMap);
            Handler.ValidateProgramRating(OldList,NewMap);
         	//Handler.copyRoomSpaceTransactionToRmSpaceInfo(NewList,OldMap);
         	
         
        test.stopTest();
        
    }//PA - End
}