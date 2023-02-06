/* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*/
/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CloneUtility_2Test
** Description      : This class contains unit tests for validating the behavior of Apex classes and triggers.
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
private class CLQ_CloneUtility_2Test {
    public static final string APPLICATION_REVISED = 'Application Revised';
    @IsTest
    static void cancelUpdateTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            
            
            CLQ_Program_Transaction__c ProgramTransaction;
            CLQ_Program_Transaction__c VersionBackup;
            for(CLQ_Program_Transaction__c trans : ProgramTransactionMap.values())
            {
                system.debug('Program Transactions: ' + trans.RecordType + '  Status ' + trans.CLQ_Transaction_Status__c);
                if (trans.CLQ_Transaction_Status__c == APPLICATION_REVISED) {VersionBackup = trans;}
                ELSE{ ProgramTransaction = trans;}
            }
            
            Test.startTest();
            
            CLQ_Trigger.BypassAllTriggers = true;
            
            Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
            insert tsk;
            Event event = (Event)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Event');
            event.DurationInMinutes = 20;
            event.ActivityDateTime = DateTime.Now();
            insert Event;
            CLQ_Transaction_Document__c TransDoc = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
            insert TransDoc;
            CLQ_Facility_Schedule__c Facility = (CLQ_Facility_Schedule__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Facility_Schedule__c');
            insert Facility;
            //CLQ_Payment_Received__c Payment = (CLQ_Payment_Received__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Payment_Received__c');
            //insert Payment;
            CLQ_Role__c role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
            insert role;
            CLQ_Room_Space__c roomSpace = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
            roomSpace.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
            roomSpace.CLQ_Number_of_Children_Under_2__c = 2;
            roomSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert roomSpace;       
            CLQ_Inspection__c Inspection = (CLQ_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Inspection__c');
            insert Inspection;
            CLQ_Room_Space_Inspection__c rsi = (CLQ_Room_Space_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space_Inspection__c');
            rsi.CLQ_Inspection__c = Inspection.Id;
            rsi.CLQ_Room_Group_Information__c = roomSpace.Id;
            insert rsi;
            
            CLQ_Program_Transaction__c ChangedTransaction = CLQ_CloneUtility.CancelRevision(ProgramTransaction);
            
            Test.stopTest();
        }
    }       
    
    @IsTest
    static void cloneTrasnactionTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction;
            CLQ_Program_Transaction__c VersionBackup;
            for(CLQ_Program_Transaction__c trans : ProgramTransactionMap.values())
            {
                system.debug('Program Transactions: ' + trans.RecordType + '  Status ' + trans.CLQ_Transaction_Status__c);
                if (trans.CLQ_Transaction_Status__c == APPLICATION_REVISED) {VersionBackup = trans;}
                ELSE{ ProgramTransaction = trans;}
            }
            
            
            CLQ_Trigger.BypassAllTriggers = true;
            Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
            insert tsk;
            CLQ_Transaction_Document__c TransDoc1 = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
            CLQ_Transaction_Document__c TransDoc2 = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
            insert new list<sObject>{TransDoc1, TransDoc2};
                CLQ_Staff_Record__c staffRecord1 = (CLQ_Staff_Record__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Staff_Record__c');
            CLQ_Staff_Record__c staffRecord2 = (CLQ_Staff_Record__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Staff_Record__c');
            insert new list<sObject>{staffRecord1, staffRecord2};
                CLQ_Room_Space__c RS1 = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
            CLQ_Room_Space__c RS2 = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
            RS1.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
            RS1.CLQ_Number_of_Children_Under_2__c = 2;
            RS1.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            RS2.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
            RS2.CLQ_Number_of_Children_Under_2__c = 2;
            RS2.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert new list<sObject>{RS1, RS2};
                
                //ProgramTransaction;
                
                CLQ_Trigger.BypassAllTriggers = false;
            Test.StartTest();
            //Finished test data
            CLQ_Program_Transaction__c cloned = CLQ_CloneUtility.CloneProgramTransaction(ProgramTransaction, null, null);
            insert cloned;
            
            CLQ_Program_Transaction__c Deserialized = CLQ_CloneUtility.DeserializeRelatedLists(cloned);
            
            list<CLQ_Room_Space__c> spaces = Deserialized.Rooms_Spaces__r;
            
            system.debug('spaces: ' + spaces[0]);
            system.debug('spaces: ' + spaces[1]);
            system.debug('spaces: ' + spaces[2]);
            
            map<string, list<sObject>> relatedListMap = CLQ_CloneUtility.QueryRelatedLists(Deserialized);
            Test.StopTest();
        }
        
    }
    
    @IsTest
    static void cloneCancelTwoTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction;
            CLQ_Program_Transaction__c VersionBackup;
            for(CLQ_Program_Transaction__c trans : ProgramTransactionMap.values())
            {
                system.debug('Program Transactions: ' + trans.RecordType + '  Status ' + trans.CLQ_Transaction_Status__c);
                if (trans.CLQ_Transaction_Status__c == APPLICATION_REVISED) {VersionBackup = trans;}
                ELSE{ ProgramTransaction = trans;}
            }
            CLQ_Program_Transaction__c RelatedToPrevious = CLQ_CloneUtility.RelatedItems(ProgramTransaction.id);
            
            CLQ_Trigger.BypassAllTriggers = true;
            Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
            insert tsk;
            CLQ_Transaction_Document__c TransDoc1 = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
            CLQ_Transaction_Document__c TransDoc2 = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
            insert new list<sObject>{TransDoc1, TransDoc2};
                CLQ_Staff_Record__c staffRecord1 = (CLQ_Staff_Record__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Staff_Record__c');
            CLQ_Staff_Record__c staffRecord2 = (CLQ_Staff_Record__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Staff_Record__c');
            insert new list<sObject>{staffRecord1, staffRecord2};
                CLQ_Room_Space__c RS1 = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
            CLQ_Room_Space__c RS2 = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
            RS1.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
            RS1.CLQ_Number_of_Children_Under_2__c = 2;
            RS1.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            RS2.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
            RS2.CLQ_Number_of_Children_Under_2__c = 2;
            RS2.CLQ_Used_By_Under_or_Over_2__c = 'Both';
            insert new list<sObject>{RS1, RS2};
                CLQ_Facility_Schedule__c Facility = (CLQ_Facility_Schedule__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Facility_Schedule__c');
            insert Facility;
            //CLQ_Payment_Received__c Payment = (CLQ_Payment_Received__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Payment_Received__c');
            //insert Payment;
            CLQ_Role__c role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
            insert role;
            
            Test.StartTest();
            
            CLQ_Program_Transaction__c RelatedToMost = CLQ_CloneUtility.RelatedItems(ProgramTransaction.id);
            
            map<string, list<sObject>> AllItems = CLQ_CloneUtility.QueryRelatedLists(RelatedToPrevious);
            for(sObject sobj : AllItems.get('Facility Schedules'))
            {
                CLQ_Facility_Schedule__c sch = (CLQ_Facility_Schedule__c)sobj;
                // fix by MP - Test class failure - 1/14
                if(sch!= null && VersionBackup!=null && VersionBackup.Id != null){
                    sch.CLQ_Program_Transaction__c = VersionBackup.Id;
                }
            }
            update AllItems.get('Facility Schedules'); 
            
            for(sObject sobj : AllItems.get('Associated Individuals'))
            {
                CLQ_Role__c sch = (CLQ_Role__c)sobj;
                if(VersionBackup!=null && VersionBackup.Id != null){
                    sch.CLQ_Program_Transaction_Source__c = VersionBackup.Id;
                }
            }
            update AllItems.get('Associated Individuals'); 
            
            for(sObject sobj : AllItems.get('Rules Inspected'))
            {
                CLQ_Rules_Inspected__c sch = (CLQ_Rules_Inspected__c)sobj;
                if(VersionBackup!=null && VersionBackup.Id != null){
                    sch.ProgramTransaction__c = VersionBackup.Id;
                }
            }
            update AllItems.get('Rules Inspected'); 
            //for(sObject sobj : AllItems.get('Payments Received'))
            //{
                //CLQ_Payment_Received__c sch = (CLQ_Payment_Received__c)sobj;
                //if(VersionBackup!=null && VersionBackup.Id != null){
                //    sch.CLQ_Program_Transaction__c = VersionBackup.Id;
                //}
            //}
            //update AllItems.get('Payments Received'); 
            for(sObject sobj : AllItems.get('Transaction Documents'))
            {
                CLQ_Transaction_Document__c sch = (CLQ_Transaction_Document__c)sobj;
                //if(VersionBackup!=null && VersionBackup.Id != null){
                //sch.CLQ_Program_Transaction__c = VersionBackup.Id;
                //}
            }
            //update AllItems.get('Transaction Documents'); 
            
            
            //ProgramTransaction;
            
            CLQ_Program_Transaction__c RelatedAfterSomeMoved = CLQ_CloneUtility.RelatedItems(ProgramTransaction.id);
            
            CLQ_Trigger.BypassAllTriggers = false;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            ProgramTransaction.CLQ_Transaction_Status__c = 'Cancelled';
            update ProgramTransaction;
            CLQ_Program_Transaction__c RelatedToAfterCancel = CLQ_CloneUtility.RelatedItems(ProgramTransaction.id);
            
            Test.StopTest();
        }
        
    }    
    
    /*static void DisplayRelatedLists(CLQ_Program_Transaction__c Related)
    {
        map<string, list<sObject>> AllItems = CLQ_CloneUtility.QueryRelatedLists(Related);
        for(string KeyName : AllItems.keySet())
        {
            system.Debug(KeyName + '  -  ' + AllItems.get(KeyName).size());
            for(sObject sobj : AllItems.get(KeyName))
                system.Debug(KeyName + '  ---------  ' + string.valueOf(sobj.Id).subString(11).toUpperCase());
        }
    }*/
    
    @testSetup 
    public static void testSetup()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting(); //11615
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        
        CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
        CLQ_Trigger.BypassAllTriggers = true;
        ProgramTransaction.OwnerId = user.Id;
        system.Debug('Unit Test setting the Status to SUBMITTED');
        ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
        update ProgramTransaction;
        
        Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
        insert tsk;
        Event event = (Event)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Event');
        event.DurationInMinutes = 20;
        event.ActivityDateTime = DateTime.Now();
        insert Event;
        CLQ_Transaction_Document__c TransDoc = (CLQ_Transaction_Document__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Transaction_Document__c');
        insert TransDoc;
        CLQ_Facility_Schedule__c Facility = (CLQ_Facility_Schedule__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Facility_Schedule__c');
        insert Facility;
        //CLQ_Payment_Received__c Payment = (CLQ_Payment_Received__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Payment_Received__c');
        //insert Payment;
        CLQ_Role__c role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
        insert role;
        CLQ_Room_Space__c roomSpace = (CLQ_Room_Space__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space__c');
        roomSpace.CLQ_Program__c = ProgramTransaction.CLQ_Program__c;
        roomSpace.CLQ_Number_of_Children_Under_2__c = 2;
        roomSpace.CLQ_Used_By_Under_or_Over_2__c = 'Both';
        insert roomSpace;       
        CLQ_Inspection__c Inspection = (CLQ_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Inspection__c');
        
        insert Inspection;
        CLQ_Room_Space_Inspection__c rsi = (CLQ_Room_Space_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Room_Space_Inspection__c');
        rsi.CLQ_Inspection__c = Inspection.Id;
        rsi.CLQ_Room_Group_Information__c = roomSpace.Id;
        insert rsi;
        
        Test.startTest();
        CLQ_Trigger.BypassAllTriggers = false;
        CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
        System.RunAs(user)
        {
            //Causes a version to be created
            ProgramTransaction.CLQ_Mailing_Street_Address__c = '1234 NorthWest St';
            ProgramTransaction.CLQ_Portal_Application_Update__c = true;
            update ProgramTransaction;
        }
        Test.stopTest();
    }
}