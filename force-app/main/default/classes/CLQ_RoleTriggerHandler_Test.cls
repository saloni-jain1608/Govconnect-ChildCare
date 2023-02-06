/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_RoleTriggerHandler_Test
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
private class CLQ_RoleTriggerHandler_Test {
    @IsTest
    static void interceptUpdateAndCloneTest() {
        test.startTest(); 		
        map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
        integer OriginalCount = ProgramTransactionMap.size();
        CLQ_Program_Transaction__c ProgramTransaction;
        CLQ_Program_Transaction__c VersionBackup;
        for(CLQ_Program_Transaction__c trans : ProgramTransactionMap.values())
        {
            system.debug('Program Transactions: ' + trans.RecordType + '  Status ' + trans.CLQ_Transaction_Status__c);
            if(trans.CLQ_Transaction_Status__c == 'Application Revised'){
                VersionBackup = trans;
            } 
            ELSE{
                ProgramTransaction = trans;
            } 
        }
        system.assertEquals(null,VersionBackup,'Testing');
        
        
        list<CLQ_Role__c> Roles = [SELECT Id, Name, CLQ_Are_you_currently_Licensed__c,CLQ_Program_Number__c,
                                   CLQ_License_Revoked_Previously__c,CLQ_Certified_Licensed_by_other_state__c,CLQ_States__c,
                                   CLQ_Certified_as_Provider_within_past_5__c,CLQ_X2_Program_Number__c,CLQ_Licensed_as_Provider_within_past5yrs__c
                                   //,CLQ_X3_License_No__c
                                   FROM CLQ_Role__c Limit 20];    
        system.assertNotEquals(0,Roles.size(),'Testing');
        
        User customer = CLQ_UnitTestUtilities.GetCustomer();
        System.RunAs(customer)
        {
            Roles[0].CLQ_Certified_Licensed_by_other_state__c = 'Yes';
            CLQ_RoleTriggerHandler.HasUpdated = false;
            update Roles[0]; 
        }
        ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
        integer NewCount = ProgramTransactionMap.size();
        //system.assertEquals(OriginalCount + 2, NewCount);
        
        for(CLQ_Program_Transaction__c trans : ProgramTransactionMap.values())
        {
            system.debug('Program Transactions: ' + trans.RecordType + '  Status ' + trans.CLQ_Transaction_Status__c);
            if(trans.CLQ_Transaction_Status__c == 'Application Revised'){
                VersionBackup = trans;
            } 
            ELSE{
                ProgramTransaction = trans;
            } 
        }
        //system.assertNotEquals(null,VersionBackup);
        test.stopTest();        
    }
    @IsTest
    static void setEmptyRoleTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Role__c role = new CLQ_Role__c();
            role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Resident').getRecordTypeId();
            role.Relationship__c = 'Related';
            insert role;
            
            CLQ_Role__c modifiedrole = [SELECT Id, CLQ_Role__c FROM CLQ_Role__c WHERE Id = :role.id LIMIT 1];
            system.assertEquals('Resident', modifiedrole.CLQ_Role__c,'Testing');
        }
    }
    
    
    @testSetup 
    public static void testSetup()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
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
        Account a = new Account (Name = 'Test A Original');
        insert a;
        Contact c = new Contact (LastName = 'Test C Original', AccountId = a.Id);
        insert c;
        CLQ_Role__c role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
        role.CLQ_Role__c = 'Authorized Representative';
        role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        role.OwnerId = user.id;
        role.CLQ_Contact__c=c.id;
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
        
        /*
Test.startTest();
CLQ_Trigger.BypassAllTriggers = false;
CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
System.RunAs(user)
{
//Causes a version to be created
ProgramTransaction.CLQ_Mailing_Street_Address__c = '1234 NorthWest St';
update ProgramTransaction;
}
Test.stopTest();
*/
    } 
    
    
}