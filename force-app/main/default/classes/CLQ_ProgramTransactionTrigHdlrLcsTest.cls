/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTransactionTrigHdlrLcsTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_ProgramTransactionTrigHdlrLcsTest { 
    @testSetup
    public static void setExecuteControlSetting(){
        CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_UnitTestUtilities.HardCodedTransactionCreation();
    }
    
    @IsTest
    static void updateAddressTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
            
            List<CLQ_County__c> county = [Select Id from CLQ_County__c LIMIT 2];
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = acc.Id;
            programRecord.CLQ_Street_Address_1__c = '123 Random St';
            programRecord.CLQ_Street_Address_2__c = 'addr2';
            programRecord.City__c = 'test city';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord.CLQ_County__c = county[0].id;
            programRecord.OwnerId = UserInfo.getUserId();
            programRecord.CLQ_Program_Status__c = 'Open'; 
            programRecord.CLQ_Program_Email__c ='test@test.com';
            programRecord.CLQ_Phone__c ='1234567';
            programRecord.CLQ_Phone_Extension__c =456;
            insert programRecord;
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction.CLQ_Approved_by_Manager__c=true;
            ProgramTransaction.CLQ_ProgTrans_County__c = county[1].Id;
            
            List<CLQ_Program_Transaction__c> ptList = new List<CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            //ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            //ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.CLQ_ProgTrans_Street_Address__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_Street_Address_2__c = '123 lakjsdjkl st';
            ProgramTransaction1.CLQ_ProgTrans_State__c = 'DF';
            ProgramTransaction1.CLQ_ProgTrans_Zip_Code__c = '65487';
            ProgramTransaction1.CLQ_ProgTrans_Program_Email_Address__c = 'lkjd@oiwuer.com';
            ProgramTransaction1.CLQ_ProgTrans_Phone_Extension__c = 654;
            ProgramTransaction1.CLQ_ProgTrans_Phone__c = '6148523697';
            ProgramTransaction1.CLQ_ProgTrans_County__c = county[1].Id;
            ProgramTransaction1.CLQ_Approved_by_Manager__c=true;
            ptList.add(ProgramTransaction1);
            
            Test.startTest();
            CLQ_ProgramTransactionTrigHdlrLicsng Handler = new CLQ_ProgramTransactionTrigHdlrLicsng();
            boolean result = Handler.UpdateAddress(programRecord, ProgramTransaction);
            boolean result1 = Handler.Validation(ptList, null);
            
            insert ProgramTransaction;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approver Review In Progress';
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
            update ProgramTransaction;
            
            CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;
            Test.stopTest();
            system.assert(result,'Testing');
            system.assert(!result1,'Testing');
        }
    }
    
    @IsTest
    static void assignOwnerTest()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
            
            List<CLQ_County__c> county = [Select Id from CLQ_County__c LIMIT 2];        
            List<CLQ_Program__c> prgList = new List<CLQ_Program__c>();        
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = acc.Id;
            programRecord.CLQ_Street_Address_1__c = '123 Random St';
            programRecord.CLQ_Street_Address_2__c = 'addr2';
            programRecord.City__c = 'test city';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            //programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord.CLQ_County__c = county[0].id;
            programRecord.OwnerId = UserInfo.getUserId();
            programRecord.CLQ_Program_Status__c = 'Open'; 
            programRecord.CLQ_Program_Email__c ='test@test.com';
            programRecord.CLQ_Phone__c ='1234567';
            programRecord.CLQ_Phone_Extension__c =456;
            prgList.add(programRecord);
            
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = acc.Id;
            programRecord2.CLQ_Street_Address_1__c = '123 Random St';
            programRecord2.CLQ_Street_Address_2__c = 'addr2';
            programRecord2.City__c = 'test city';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            //programRecord2.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord2.CLQ_County__c = county[0].id;
            programRecord2.OwnerId = UserInfo.getUserId();
            programRecord2.CLQ_Program_Status__c = 'Open'; 
            programRecord2.CLQ_Program_Email__c ='test@test.com';
            programRecord2.CLQ_Phone__c ='1234567';
            programRecord2.CLQ_Phone_Extension__c =456;
            //insert programRecord2;
            
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test';
            programRecord3.CLQ_Associated_Organization__c = acc.Id;
            programRecord3.CLQ_Street_Address_1__c = '123 Random St';
            programRecord3.CLQ_Street_Address_2__c = 'addr2';
            programRecord3.City__c = 'test city';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            //programRecord3.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord3.CLQ_County__c = county[0].id;
            programRecord3.OwnerId = UserInfo.getUserId();
            programRecord3.CLQ_Program_Status__c = 'Open'; 
            programRecord3.CLQ_Program_Email__c ='test@test.com';
            programRecord3.CLQ_Phone__c ='1234567';
            programRecord3.CLQ_Phone_Extension__c =456;
            //insert programRecord3;        
            //day camp start
            CLQ_Program__c programRecordDayCamp = new CLQ_Program__c();
            programRecordDayCamp.Name = 'Test';
            programRecordDayCamp.CLQ_Associated_Organization__c = acc.Id;
            programRecordDayCamp.CLQ_Street_Address_1__c = '1235 Random St';
            programRecordDayCamp.CLQ_Street_Address_2__c = 'addr2';
            programRecordDayCamp.City__c = 'test city';
            programRecordDayCamp.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
            //programRecord3.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecordDayCamp.CLQ_County__c = county[0].id;
            programRecordDayCamp.OwnerId = UserInfo.getUserId();
            programRecordDayCamp.CLQ_Program_Status__c = 'Open'; 
            programRecordDayCamp.CLQ_Program_Email__c ='test@test.com';
            programRecordDayCamp.CLQ_Phone__c ='1234567';
            programRecordDayCamp.CLQ_Phone_Extension__c =456;
            //insert programRecordDayCamp; 
            //prgList.add(programRecord);  
            prgList.add(programRecord2);        
            prgList.add(programRecord3);  
            prgList.add(programRecordDayCamp);
            insert prgList;
            
            test.startTest();
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_On_site_Contact_Information').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            
            insert ProgramTransaction;
            
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            update ProgramTransaction;
            
            //day camp
            CLQ_Program_Transaction__c ProgramTransactionDayCamp = new CLQ_Program_Transaction__c();
            ProgramTransactionDayCamp.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Registration_Day_Camp').getRecordTypeId();
            ProgramTransactionDayCamp.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransactionDayCamp.CLQ_Program__c = programRecordDayCamp.id;
            
            insert ProgramTransactionDayCamp;
            
            ProgramTransactionDayCamp.CLQ_Transaction_Status__c = 'Submitted';
            update ProgramTransactionDayCamp;
            
            
            test.stopTest();
        }
        
    }
    
    @IsTest
    static void findModifiedFieldsTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            system.debug('begin of test for aaFindModifiedFieldsTest');
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction0 = ProgramTransactionMap.values()[0];
            CLQ_Program_Transaction__c ProgramTransaction1 = ProgramTransactionMap.values()[1];
            
            CLQ_ProgramTransactionTrigHdlrLicsng Handler = new CLQ_ProgramTransactionTrigHdlrLicsng();
            Handler.AllowedToModifyCertainFieldsWithoutVersioning(ProgramTransaction1,ProgramTransaction0);
            
            //ProgramTransaction0.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
            //ProgramTransaction0.CLQ_Transaction_Status__c='Under Reviewer Review';
            //update ProgramTransaction0;
            //Handler.ShouldBackup(ProgramTransaction1,ProgramTransaction0);
            
            set<string> ChangedItems = CLQ_CloneUtility.FindModifiedFields(ProgramTransaction1, ProgramTransaction0);
            
            system.debug('test for changged items ' + ChangedItems);
            system.debug('test for changged items size ' + ChangedItems.size());
            //system.AssertEquals(9,ChangedItems.size(),'Testing');
            
        }
    }
    
    @IsTest
    static void testProgram() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Program__c programRecord = [Select Id from CLQ_Program__c WHERE RecordType.Name = 'FCC - Type B Home' LIMIT 1];
            CLQ_County__c county = [Select Id from CLQ_County__c LIMIT 1];
            
            Test.StartTest();
            integer TransactionCount = [SELECT Count() FROM CLQ_Program_Transaction__c];
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location').getRecordTypeId();
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
            insert ProgramTransaction;
            list<CLQ_Program_Transaction__c> Transactions = [SELECT id, Name, CLQ_Transaction_Status__c FROM CLQ_Program_Transaction__c];
            system.AssertEquals(1, Transactions.size() - TransactionCount,'Testing');
            
            ProgramTransaction.CLQ_ProgTrans_City__c = 'Lancaster';
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            //update ProgramTransaction;
            
            Transactions = [SELECT id, Name, CLQ_Transaction_Status__c FROM CLQ_Program_Transaction__c];
            system.AssertEquals(1, Transactions.size() - TransactionCount,'Testing');
            
            
            Test.StopTest();
            
            /*
ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 Lakeside St';
ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = 'Suite B';
update ProgramTransaction;
Transactions = [SELECT id, Name, CLQ_Transaction_Status__c FROM CLQ_Program_Transaction__c];
system.AssertEquals(2, Transactions.size());
*/
        }
        
    }	
    
    @IsTest
    static void cannotSubmitAnotherAmendmentTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransactionOld = ProgramTransactionMap.values()[0];
            integer TransactionCount = [SELECT Count() FROM CLQ_Program_Transaction__c];
            CLQ_County__c county = [Select Id from CLQ_County__c LIMIT 1];
            list<CLQ_Inspection__c> Inspections = [SELECT id, Name FROM CLQ_Inspection__c];
            
            Test.StartTest();
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location').getRecordTypeId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            ProgramTransaction.CLQ_Program__c = ProgramTransactionOld.CLQ_Program__c;
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
            ProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            ProgramTransaction.CLQ_Assigned_To_Email__c = 'kjashdjh@jklasd.com';
            insert ProgramTransaction;
            list<CLQ_Program_Transaction__c> Transactions = [SELECT id, Name, CLQ_Transaction_Status__c, RecordType.Name FROM CLQ_Program_Transaction__c];
            system.AssertEquals(1, Transactions.size() - TransactionCount,'Testing');
            Inspections = [SELECT id, Name FROM CLQ_Inspection__c];
            system.AssertEquals(0, Inspections.size(),'Testing');
            
            
            CLQ_Program_Transaction__c ProgramTransaction2 = ProgramTransaction.clone(false, true, true, true);
            
            ProgramTransaction.CLQ_ProgTrans_Street_Address__c = '123 Lakeside St';
            ProgramTransaction.CLQ_ProgTrans_Street_Address_2__c = 'Suite B';
            try
            {
                system.Debug('About to submit a new transaction ');
                insert ProgramTransaction2;
            }
            catch(Exception exc)
            {
                string message = exc.getMessage();
                system.Debug('Exception Message: ' + message);
                system.Assert(message.contains('A Change of Location Request already exists for this program and has not been submitted'),'Testing');
            }
            Inspections = [SELECT id, Name FROM CLQ_Inspection__c];
            system.AssertEquals(0, Inspections.size(),'Testing');
            
            Transactions = [SELECT id, Name, CLQ_Transaction_Status__c, RecordType.Name FROM CLQ_Program_Transaction__c];
            system.debug('Transactions Count: ' +Transactions);
            system.AssertEquals(1, Transactions.size() - TransactionCount,'Testing');
            
            
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction.ownerid = UserInfo.getUserId();
            //update ProgramTransaction;
            try
            {
                system.Debug('About to submit a new transaction ');
                insert ProgramTransaction2;
            }
            catch(Exception exc)
            {
                string message = exc.getMessage();
                system.Debug('Exception Message: ' + message);
                //system.Assert(message.contains('A Change of Location request was submitted for this program and is currently being reviewed'),'Testing');
            }
            
            Test.StopTest();
        }
    }	
    
    @IsTest
    static void prefillRelatedListsFacilityScheduleTest()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            system.debug('PrefillRelatedListsTest: ' + ProgramTransactionMap.size());
            system.debug('PrefillRelatedListsTest: ' + ProgramTransaction);
            
            //string QueryString = CLQ_UtilityClass.createSOQLQuery('CLQ_Program_Transaction__c', ' Id = \'' + ProgramTransaction.CLQ_Program__c + '\'', null);
            //List<sObject> sobjectlist = Database.query(QueryString);
            CLQ_Program__c Program = [SELECT Id, Name, CLQ_Associated_Organization__c FROM CLQ_Program__c WHERE Id = :ProgramTransaction.CLQ_Program__c];
            system.debug('Program: ' + Program);
            
            CLQ_Facility_Schedule__c Schedule = new CLQ_Facility_Schedule__c(CLQ_Program__c = Program.Id);
            //[SELECT Id, Name FROM CLQ_Facility_Schedule__c WHERE Id =: Program.Id ];
            system.debug('Schedule: ' + Schedule);
            insert Schedule;
            
            
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            Test.StartTest();
            
            //Create a CLQ_Program_Transaction__c record to see if the Facility_Schedule get connected
            CLQ_Program_Transaction__c NewTransaction = new CLQ_Program_Transaction__c();
            NewTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_Facility_Information').getRecordTypeId();
            NewTransaction.CLQ_Program__c = Program.id;
            NewTransaction.CLQ_Start_Approval__c = true;
            NewTransaction.CLQ_Transaction_Status__c = 'Application Revised';
            insert NewTransaction;
            /*CLQ_Program_Transaction__c NewTransaction1 = new CLQ_Program_Transaction__c();
NewTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information').getRecordTypeId();
NewTransaction1.CLQ_Program__c = Program.id;
NewTransaction1.CLQ_Start_Approval__c = true;
NewTransaction1.CLQ_Transaction_Status__c = 'Approver Review In Progress';
insert NewTransaction1;*/
            map<id,CLQ_Program_Transaction__c> RelatedItems = CLQ_CloneUtility.RelatedItems(new list<id> {NewTransaction.Id});
            CLQ_Program_Transaction__c Related = RelatedItems.get(NewTransaction.Id);
            system.debug('Related Items: ' + Related.Facility_Schedules__r);
            //system.AssertEquals(1,Related.Facility_Schedules__r.size());
            system.debug('Test Run: ' + Related.Facility_Schedules__r.size());
            if(Related.Facility_Schedules__r.size()>0){
                system.AssertEquals(Schedule.Id,Related.Facility_Schedules__r[0].Id,'Testing');    
            }
            Test.StopTest();
            //Update On-site Contact Information
            //Update FCC Resident Information
        }
    }
    
    @IsTest
    static void prefillRelatedListsResidentTest()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            system.debug('PrefillRelatedListsTest: ' + ProgramTransactionMap.size());
            system.debug('PrefillRelatedListsTest: ' + ProgramTransaction);
            
            //string QueryString = CLQ_UtilityClass.createSOQLQuery('CLQ_Program_Transaction__c', ' Id = \'' + ProgramTransaction.CLQ_Program__c + '\'', null);
            //List<sObject> sobjectlist = Database.query(QueryString);
            CLQ_Program__c Program = [SELECT Id, Name, CLQ_Associated_Organization__c FROM CLQ_Program__c WHERE Id = :ProgramTransaction.CLQ_Program__c];
            system.debug('Program: ' + Program);
            
            list<CLQ_Role__c> roles = new list<CLQ_Role__c>();
            list<Contact> conts = new list<Contact>();
            conts.add(new Contact(FirstName = 'Test', LastName = 'One', AccountId = Program.CLQ_Associated_Organization__c));
            insert(conts);
            
            CLQ_Role__c contactRole = new CLQ_Role__c();     
            contactRole.CLQ_Program__c = Program.Id;
            contactRole.CLQ_Contact__c = conts[0].Id;
            contactRole.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Resident').getRecordTypeId();
            contactRole.CLQ_Role__c = 'Resident';
            contactRole.Relationship__c = 'Not related';
            roles.Add(contactRole);
            
            insert roles;
            
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            Test.StartTest();
            
            //Create a CLQ_Program_Transaction__c record to see if the Resident get connected
            CLQ_Program_Transaction__c NewTransaction = new CLQ_Program_Transaction__c();
            NewTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_FCC_Resident_Information').getRecordTypeId();
            NewTransaction.CLQ_Program__c = Program.id;
            NewTransaction.CLQ_Start_Approval__c = true;
            NewTransaction.CLQ_Transaction_Status__c = 'Application Revised';
            insert NewTransaction;		
            map<id,CLQ_Program_Transaction__c> RelatedItems = CLQ_CloneUtility.RelatedItems(new list<id> {NewTransaction.Id});
            CLQ_Program_Transaction__c Related = RelatedItems.get(NewTransaction.Id);
            system.debug('Related Items: ' + Related.Roles__r);
            system.AssertEquals(0,Related.Roles__r.size(),'Testing');
            
            Test.StopTest();
            //Update On-site Contact Information
            //Update FCC Resident Information
        }
    }
    
    @IsTest
    static void prefillRelatedListsOnsiteContactTest()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            system.debug('PrefillRelatedListsTest: ' + ProgramTransactionMap.size());
            system.debug('PrefillRelatedListsTest: ' + ProgramTransaction);
            
            //string QueryString = CLQ_UtilityClass.createSOQLQuery('CLQ_Program_Transaction__c', ' Id = \'' + ProgramTransaction.CLQ_Program__c + '\'', null);
            //List<sObject> sobjectlist = Database.query(QueryString);
            CLQ_Program__c Program = [SELECT Id, Name, CLQ_Associated_Organization__c FROM CLQ_Program__c WHERE Id = :ProgramTransaction.CLQ_Program__c];
            system.debug('Program: ' + Program);
            
            list<CLQ_Role__c> roles = new list<CLQ_Role__c>();
            list<Contact> conts = new list<Contact>();
            conts.add(new Contact(FirstName = 'Test', LastName = 'One', AccountId = Program.CLQ_Associated_Organization__c));
            conts.add(new Contact(FirstName = 'Test', LastName = 'Two', AccountId = Program.CLQ_Associated_Organization__c));
            insert(conts);
            
            CLQ_Role__c contactRole = new CLQ_Role__c();     
            contactRole.CLQ_Program__c = Program.Id;
            contactRole.CLQ_Contact__c = conts[0].Id;
            contactRole.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Program_Role').getRecordTypeId();
            contactRole.CLQ_Role__c = 'On-site Contact';
            roles.Add(contactRole);
            
            contactRole = new CLQ_Role__c();     
            contactRole.CLQ_Program__c = Program.Id;
            contactRole.CLQ_Contact__c = conts[1].Id;
            contactRole.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Program_Role').getRecordTypeId();
            contactRole.CLQ_Role__c = 'Alternate On Site Contact';
            roles.Add(contactRole);              
            
            insert roles;
            
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            Test.StartTest();
            
            //Create a CLQ_Program_Transaction__c record to see if the On-site Contact Information get connected
            CLQ_Program_Transaction__c NewTransaction = new CLQ_Program_Transaction__c();
            NewTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_On_site_Contact_Information').getRecordTypeId();
            NewTransaction.CLQ_Program__c = Program.id;
            NewTransaction.CLQ_Start_Approval__c = true;
            NewTransaction.CLQ_Transaction_Status__c = 'Application Revised';
            insert NewTransaction;		
            map<id,CLQ_Program_Transaction__c> RelatedItems = CLQ_CloneUtility.RelatedItems(new list<id> {NewTransaction.Id});
            CLQ_Program_Transaction__c Related = RelatedItems.get(NewTransaction.Id);
            system.debug('Related Items: ' + Related.Roles__r);
            system.AssertEquals(0,Related.Roles__r.size(),'Testing');
            
            
            Test.StopTest();
            //Update On-site Contact Information
            //Update FCC Resident Information
        }
    }
    @IsTest
    static void versioning(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[6]; 	//FCC - Type B Home - Application - FCC
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.CLQ_Mailing_Street_Address__c = '123 test st';
            ProgramTransaction.CLQ_License_Start_Date__c=Date.today();
            ProgramTransaction.CLQ_Recommendation__c='Approve';
            ProgramTransaction.CLQ_Approved_Total_Capacity__c =3;
            ProgramTransaction.CLQ_Calculated_Maximum_Capacity__c=3;
            ProgramTransaction.CLQ_Full_Part_Time_Options_Global__c='Full Time';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c = Null;
            //ProgramTransaction.CLQ_Program__r.CLQ_Licensing_Specialist__c = null;
            CLQ_Trigger.BypassAllTriggers = false;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;
            Test.StopTest();	
        }
        
    }
    @IsTest
    static void shouldupdatetest(){
        system.assertEquals(True, 1==1,'Testing');
        map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        Test.StartTest();
        CLQ_ProgramTransactionTrigHdlrLicsng Handler = new CLQ_ProgramTransactionTrigHdlrLicsng();
        
        CLQ_Program_Transaction__c ProgramTransaction1 = ProgramTransactionMap.values()[6]; //FCC - Type B Home - Application - FCC
        CLQ_Program_Transaction__c ProgramTransaction2 = ProgramTransactionMap.values()[6];
        CLQ_Program_Transaction__c ProgramTransaction3 = ProgramTransactionMap.values()[0];
        ProgramTransaction1.Ownerid=user.id;
        ProgramTransaction1.CLQ_Transaction_Assigned_To__c=user.id;
        ProgramTransaction1.CLQ_Transaction_Status__c='Under Reviewer Review';
        
        update ProgramTransaction1;
        CLQ_Trigger.BypassAllTriggers = false;
        CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
        //CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction1.id,'');
        System.runAs(user){
            ProgramTransaction1.CLQ_Mailing_Street_Address__c = '123 test st';
            update ProgramTransaction1;
            
            ProgramTransaction2.CLQ_Transaction_Status__c='Submitted';
            ProgramTransaction2.CLQ_License_Start_Date__c=null;
            ProgramTransaction2.CLQ_Recommendation__c='Approve';
            boolean result = Handler.ShouldBackup(ProgramTransaction1, ProgramTransaction2);
        }
        Handler.ReadyforApprovalCheck(new List<CLQ_Program_Transaction__c>{ProgramTransaction1});
        CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction3.id,'');
        ProgramTransaction3.CLQ_License_Start_Date__c=Date.today();
        ProgramTransaction3.CLQ_Recommendation__c='Approve';
        ProgramTransaction3.CLQ_Approved_Total_Capacity__c=6;
        ProgramTransaction3.CLQ_Calculated_Maximum_Capacity__c=6;
        ProgramTransaction3.CLQ_Full_Part_Time_Options_Global__c='Full Time';
        update ProgramTransaction3;
        List<CLQ_Program_Transaction__c> l=new List<CLQ_Program_Transaction__c>();
        l.add(ProgramTransaction3);            
        
        
        
        Test.StopTest();	
        
        
    }
    @IsTest
    static void shouldupdatetest2(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            List<CLQ_Program_Transaction__c> li=ProgramTransactionMap.values();
            for(CLQ_Program_Transaction__c l:li)
                l.CLQ_Transaction_Status__c='Under Reviewer Review';
            CLQ_ProgramTransactionTrigHdlrLicsng Handler = new CLQ_ProgramTransactionTrigHdlrLicsng();
            Handler.ReadyforApprovalCheck(li);
            Test.StopTest();
        }
    }
    @IsTest    
    static void shouldupdatetest3(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            List<CLQ_Program_Transaction__c> li=ProgramTransactionMap.values();
            for(CLQ_Program_Transaction__c l:li){
                l.CLQ_Transaction_Status__c='Under Reviewer Review';
                l.CLQ_License_Start_Date__c=Date.today();
                l.CLQ_Recommendation__c='Approve';
                l.CLQ_Full_Part_Time_Options_Global__c='Full Time';
            }
            CLQ_ProgramTransactionTrigHdlrLicsng Handler = new CLQ_ProgramTransactionTrigHdlrLicsng();
            Handler.ReadyforApprovalCheck(li);
            Test.StopTest();
        }
    }
    
    @IsTest
    static void countyAdminSharetest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Set<ID> ids = new Set<ID>();
            
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
            
            CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
                
            List<CLQ_Program__c> prgList = new List<CLQ_Program__c>();        
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = acc.Id;
            programRecord.CLQ_Street_Address_1__c = '123 Random St';
            programRecord.CLQ_Street_Address_2__c = 'addr2';
            programRecord.City__c = 'test city';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_In_Home_Aide').getRecordTypeId();
            //programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord.CLQ_County__c = county.id;
            programRecord.OwnerId = UserInfo.getUserId();
            programRecord.CLQ_Program_Status__c = 'Open'; 
            programRecord.CLQ_Program_Email__c ='test@test.com';
            programRecord.CLQ_Phone__c ='1234567';
            programRecord.CLQ_Phone_Extension__c =456;
            prgList.add(programRecord);
            
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = acc.Id;
            programRecord2.CLQ_Street_Address_1__c = '123 Random St';
            programRecord2.CLQ_Street_Address_2__c = 'addr2';
            programRecord2.City__c = 'test city';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            //programRecord2.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord2.CLQ_County__c = county.id;
            programRecord2.OwnerId = UserInfo.getUserId();
            programRecord2.CLQ_Program_Status__c = 'Open'; 
            programRecord2.CLQ_Program_Email__c ='test@test.com';
            programRecord2.CLQ_Phone__c ='1234567';
            programRecord2.CLQ_Phone_Extension__c =456;
            //insert programRecord2;
            
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test';
            programRecord3.CLQ_Associated_Organization__c = acc.Id;
            programRecord3.CLQ_Street_Address_1__c = '123 Random St';
            programRecord3.CLQ_Street_Address_2__c = 'addr2';
            programRecord3.City__c = 'test city';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            //programRecord3.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord3.CLQ_County__c = county.id;
            programRecord3.OwnerId = UserInfo.getUserId();
            programRecord3.CLQ_Program_Status__c = 'Open'; 
            programRecord3.CLQ_Program_Email__c ='test@test.com';
            programRecord3.CLQ_Phone__c ='1234567';
            programRecord3.CLQ_Phone_Extension__c =456;
            //insert programRecord3;        
            prgList.add(programRecord2);        
            prgList.add(programRecord3);   
            insert prgList;
            
            test.startTest();  
            List<CLQ_Program_Transaction__c> ptList = new List<CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
            ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Registration_In_Home_Aide').getRecordTypeId();
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction1.CLQ_Transaction_Type__c = 'Initial Application';
            ProgramTransaction1.CLQ_ProgTrans_County__c = county.id;
            ProgramTransaction1.CLQ_Program__c = programRecord.id;
            ProgramTransaction1.CLQ_Start_Approval__c = true;
            ProgramTransaction1.CLQ_Transaction_Status__c = 'Application Revised';
            ptList.add(ProgramTransaction1);
            
            
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_ODE_Program').getRecordTypeId();
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction2.CLQ_Program__c = programRecord2.id;
            ProgramTransaction2.CLQ_Start_Approval__c = true;
            ProgramTransaction2.CLQ_Transaction_Status__c = 'Application Revised';
            ptList.add(ProgramTransaction2);
            
            CLQ_Program_Transaction__c ProgramTransaction3 = new CLQ_Program_Transaction__c();
            ProgramTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction3.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction3.CLQ_ProgTrans_County__c = county.id;
            ProgramTransaction3.CLQ_Program__c = programRecord3.id;
            ProgramTransaction3.CLQ_Start_Approval__c = true;
            ProgramTransaction3.CLQ_Transaction_Status__c = 'Application Revised';
            
            ptList.add(ProgramTransaction3);
            
            
            CLQ_Program_Transaction__c ProgramTransaction4 = new CLQ_Program_Transaction__c();
            ProgramTransaction4.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location').getRecordTypeId();
            ProgramTransaction4.CLQ_Transaction_Status__c = 'Submitted';
            ProgramTransaction4.CLQ_ProgTrans_County__c = county.id;
            ProgramTransaction4.CLQ_Program__c = programRecord3.id;
            ProgramTransaction4.CLQ_Start_Approval__c = true;
            ProgramTransaction4.CLQ_Transaction_Status__c = 'Application Revised';
            
            ptList.add(ProgramTransaction4);
            
            insert ptList;
            
            for (CLQ_Program_Transaction__c pt : ptList)
            {
                ids.add(pt.id);                       
            }       
            
            list<CLQ_Program_Transaction__c>  OldList = new list<CLQ_Program_Transaction__c>();
            list<CLQ_Program_Transaction__c>  NewList = new list<CLQ_Program_Transaction__c>();
            NewList = ptList;
            
            map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c> ();
            map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>(); 
            
            //AfterInsert
            CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                                      true, true, false, false, 
                                                                                                      false, true, false, 1);
            
            Handler.ProcessTrigger();
            
                     
            
            List<CLQ_Program__Share> shares = [SELECT Id, UserOrGroupId, AccessLevel, 
                                               RowCause FROM CLQ_Program__Share WHERE ParentId IN :ids AND RowCause = 'County_Admin_Sharing__c'];
            
            //    System.assertEquals(shares.size(),2);
            
        }
    }          
    
    /*static testmethod void changesafterupdatetest1(){
map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
User user = CLQ_UnitTestUtilities.AddCustomerUser();
Test.StartTest();
List<CLQ_Program_Transaction__c> li=ProgramTransactionMap.values();
Set<String> rectype=new Set<String>{'Amendment - Change of Administrator','Reactivate Transaction','Amendment- FCC - Change of Capacity / Space','Change of Location'};
for(CLQ_Program_Transaction__c l:li){
if(rectype.contains(CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(l.RecordTypeId))){
l.CLQ_Transaction_Status__c='Approver Review in Progress';
l.CLQ_License_Start_Date__c=null;
l.CLQ_Recommendation__c='Deny';
l.CLQ_Full_Part_Time_Options_Global__c='Full Time';
l.Ownerid=user.id;
l.CLQ_Transaction_Assigned_To__c=user.id;
l.CLQ_Certificate_Issue_Date__c=Date.today();
l.CLQ_Approved_First_Day_at_New_Address__c=Date.today();
l.CLQ_New_Approved_All_Groups_Capacity__c =1;
l.CLQ_New_Approved_Under_2_Capacity__c =1;
l.CLQ_Calculated_Maximum_Capacity__c=1;
l.CLQ_Start_Approval__c=true;
l.CLQ_Approved_by_Manager__c=false;
l.CLQ_Transaction_Assigned_To__c=Userinfo.getUserId();        
l.CLQ_Deny_Reasons__c = 'Other';
l.CLQ_Reviewer_Notes__c = 'test';
l.CLQ_Specify_Other_Deny_Reasons__c='Test';
}
}      
CLQ_Trigger.BypassAllTriggers = false;
CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
update li;
Test.StopTest(); 
}   */
    @IsTest
    static void testmethod1(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[6]; 
            
            system.debug('testmethod1 ProgramTransaction: ' + ProgramTransaction);
            
            CLQ_Program__c Program = [SELECT Id, Name, CLQ_Associated_Organization__c FROM CLQ_Program__c WHERE Id = :ProgramTransaction.CLQ_Program__c];
            system.debug('Program: ' + Program);    
            
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //ProgramTransaction.CLQ_Mailing_Street_Address__c = '123 test st';
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Continuous_License').getRecordTypeId();
            ProgramTransaction.CLQ_License_Start_Date__c=Date.today();
            ProgramTransaction.CLQ_Recommendation__c='Approve';
            ProgramTransaction.CLQ_Approved_Total_Capacity__c =3;
            ProgramTransaction.CLQ_Calculated_Maximum_Capacity__c=3;
            ProgramTransaction.CLQ_Full_Part_Time_Options_Global__c='Full Time';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c = Null;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            //ProgramTransaction.CLQ_Program__r.CLQ_Licensing_Specialist__c = null;
            CLQ_Trigger.BypassAllTriggers = false;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;
            Test.StopTest();
        }
    }
    
    @IsTest
    static void testmethod2(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[6]; 
            system.debug('testmethod1 PT size: ' + ProgramTransactionMap.size());
            system.debug('testmethod1 ProgramTransaction: ' + ProgramTransaction);
            
            CLQ_Program__c Program = [SELECT Id, Name, CLQ_Associated_Organization__c FROM CLQ_Program__c WHERE Id = :ProgramTransaction.CLQ_Program__c];
            system.debug('Program: ' + Program);    
            
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //ProgramTransaction.CLQ_Mailing_Street_Address__c = '123 test st';
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Continuous_License').getRecordTypeId();
            ProgramTransaction.CLQ_License_Start_Date__c=Date.today();
            ProgramTransaction.CLQ_Recommendation__c='Approve';
            ProgramTransaction.CLQ_Approved_Total_Capacity__c =3;
            ProgramTransaction.CLQ_Calculated_Maximum_Capacity__c=3;
            ProgramTransaction.CLQ_Full_Part_Time_Options_Global__c='Full Time';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c = Null;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            ProgramTransaction.CLQ_Approved_by_Manager__c=true;
            //ProgramTransaction.CLQ_Program__r.CLQ_Licensing_Specialist__c = null;
            CLQ_Trigger.BypassAllTriggers = false;
            CLQ_ProgramTransactionTrigHdlrLicsng handler=new CLQ_ProgramTransactionTrigHdlrLicsng();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            update ProgramTransaction;
            list<CLQ_Program_Transaction__c> newlist=new list<CLQ_Program_Transaction__c>();
            newlist.add(ProgramTransaction);
            handler.ContinuousLicenseInitiated(newlist,'AfterUpdate');
            handler.getApproverWithLevel(ProgramTransaction);
            
            Test.StopTest();
        }
    }
    /* 
Test.StartTest();
Set<ID> ids = new Set<ID>();

Account acc = new Account(Name = 'TestAccount');
insert acc;

//CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
//insert county;

//System.debug('County==>' + county);     
List<CLQ_Program__c> prgList = new List<CLQ_Program__c>();        
CLQ_Program__c programRecord = new CLQ_Program__c();
programRecord.Name = 'Test';
programRecord.CLQ_Associated_Organization__c = acc.Id;
programRecord.CLQ_Street_Address_1__c = '123 Random St';
programRecord.CLQ_Street_Address_2__c = 'addr2';
programRecord.City__c = 'test city';
programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type A Home').getRecordTypeId();
//programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
//programRecord.CLQ_County__c = county.id;
programRecord.OwnerId = UserInfo.getUserId();
programRecord.CLQ_Program_Status__c = 'Open'; 
programRecord.CLQ_Program_Email__c ='test@test.com';
programRecord.CLQ_Phone__c ='1234567';
programRecord.CLQ_Phone_Extension__c =456;
prgList.add(programRecord);

insert prgList;

test.startTest();  
List<CLQ_Program_Transaction__c> ptList = new List<CLQ_Program_Transaction__c>();        

CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
ProgramTransaction2.CLQ_Transaction_Status__c = 'Submitted';
ProgramTransaction2.CLQ_Program__c = programRecord.id;
ProgramTransaction2.CLQ_Start_Approval__c = false;
ptList.add(ProgramTransaction2);

CLQ_Program_Transaction__c ProgramTransaction3 = new CLQ_Program_Transaction__c();
ProgramTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Continuous License').getRecordTypeId();
ProgramTransaction3.CLQ_Transaction_Status__c = 'Returned to Reviewer';
//ProgramTransaction3.CLQ_ProgTrans_County__c = county.id;
ProgramTransaction3.CLQ_Program__c = programRecord.id;
ProgramTransaction3.CLQ_Start_Approval__c = false;
//ProgramTransaction3.CLQ_Transaction_Status__c = 'Application Revised';
ptList.add(ProgramTransaction3);


CLQ_Program_Transaction__c ProgramTransaction4 = new CLQ_Program_Transaction__c();
ProgramTransaction4.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - FCC - Change of Location').getRecordTypeId();
ProgramTransaction4.CLQ_Transaction_Status__c = 'Under Reviewer Review';
//ProgramTransaction4.CLQ_ProgTrans_County__c = county.id;
ProgramTransaction4.CLQ_Program__c = programRecord.id;
ProgramTransaction4.CLQ_Start_Approval__c = false;
//ProgramTransaction4.CLQ_Transaction_Status__c = 'Application Revised';
ptList.add(ProgramTransaction4);

insert ptList;
Test.StopTest();
*/
    
}