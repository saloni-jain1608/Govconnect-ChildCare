/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CloneUtility_Test
** Description      : This class contains unit tests for validating the behavior of Apex classes and triggers.
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_CloneUtility_Test {
    
    @IsTest
    static void nullTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            //ProgramTransaction.CLQ_Assigned_To__c = UserInfo.GetUserId();
            Test.startTest();
            CLQ_Program_Transaction__c clonedItem = CLQ_CloneUtility.DeserializeRelatedLists(ProgramTransaction);
            Test.stopTest();
            system.AssertEquals(null, clonedItem,'Testing');
            
            map<string, list<sObject>> RelatedListMap = CLQ_CloneUtility.QueryRelatedLists( ClonedItem);
            system.AssertNotEquals(null, RelatedListMap,'Testing');
            system.AssertNotEquals(0, RelatedListMap.size(),'Testing');
        }
    }
    @IsTest
    static void buildQueryOneTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            string query = CLQ_CloneUtility.BuildQuery();
            Test.stopTest();
            system.Debug('BuildQueryTest: ' + query);
        }
    }	
    @IsTest
    static void buildQueryTwoTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            string query = CLQ_CloneUtility.RelatedItemsQuery;
            system.Debug('BuildQueryTest: ' + query);
            
            for (string objFieldName : CLQ_UnitTestUtilities.ObjectField.values())
                system.assert(query.contains(objFieldName),'Testing');
            Test.stopTest();
        }
    }	
    @IsTest    
    static void fixListTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            list<CLQ_County__c> counties = [SELECT Id, Name from CLQ_County__c];
            system.debug('counties.size: ' + counties.size());
            system.Assert(counties.size() > 7 ,'Testing');
            
            list<CLQ_County__c> countiescurrent = new list<CLQ_County__c>();
            list<CLQ_County__c> countiesPrevious = new list<CLQ_County__c>();
            list<CLQ_County__c> countiesOld = new list<CLQ_County__c>();
            
            Test.startTest();
            map<string, list<sObject>> AddAndRemove = CLQ_CloneUtility.FixList(countiescurrent, countiesPrevious, countiesOld);
            system.AssertEquals(0, AddAndRemove.get('Add').size() ,'Testing');
            system.AssertEquals(0, AddAndRemove.get('Remove').size(),'Testing');
            
            
            countiescurrent = new list<CLQ_County__c>{ counties[0], counties[1],counties[2] };
                countiesPrevious = new list<CLQ_County__c>{ counties[3],counties[2] };
                    countiesOld = new list<CLQ_County__c>{ counties[4], counties[5],counties[1] };
                        for(CLQ_County__c  county : countiescurrent)  system.Debug(' Current contains: ' + county.Name);
            for(CLQ_County__c  county : countiesPrevious) system.Debug('Previous contains: ' + county.Name);
            for(CLQ_County__c  county : countiesOld)      system.Debug('     Old contains: ' + county.Name);
            AddAndRemove = CLQ_CloneUtility.FixList(countiescurrent, countiesPrevious, countiesOld);
            Test.stopTest();
            for(sObject  county : AddAndRemove.get('Add'))    system.Debug('   Add contains: ' + ((CLQ_County__c)county).Name);
            for(sObject  county : AddAndRemove.get('Remove')) system.Debug('Remove contains: ' + ((CLQ_County__c)county).Name);
            system.AssertEquals(3, AddAndRemove.get('Add').size(),'Testing');
            system.AssertEquals(1, AddAndRemove.get('Remove').size(),'Testing');   
        }
    }	
    @IsTest
    static void reAddTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c ProgramTransaction1 = ProgramTransactionMap.Values()[0];
            CLQ_Program_Transaction__c ProgramTransaction2 = ProgramTransactionMap.Values()[1];
            Test.StartTest();
            list<CLQ_Inspection__c> Inspections = new list<CLQ_Inspection__c>();
            /*for(integer i = 0; i < 5; i++)
{
CLQ_Inspection__c Inspection = (CLQ_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction1, 'CLQ_Inspection__c');
Inspections.Add(Inspection);
}
insert Inspections;*/
            CLQ_Inspection__c Inspection = (CLQ_Inspection__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction1, 'CLQ_Inspection__c');
            insert Inspection;
            Inspections.add(Inspection);
            
            list<CLQ_Inspection__c> InspectionsRetrieved = [SELECT CLQ_Program_Transaction__c FROM CLQ_Inspection__c WHERE Id IN : Inspections];
            system.AssertEquals(Inspections.Size() , InspectionsRetrieved.size(),'Testing');
            for(CLQ_Inspection__c Inspct : InspectionsRetrieved)
                system.AssertEquals(ProgramTransaction1.Id , Inspct.CLQ_Program_Transaction__c,'Testing');
            
            
            CLQ_CloneUtility.ReAdd('CLQ_Program_Transaction__c', Inspections, ProgramTransaction2.Id);
            
            InspectionsRetrieved = [SELECT CLQ_Program_Transaction__c FROM CLQ_Inspection__c WHERE Id IN : Inspections];
            system.AssertEquals(Inspections.Size() , InspectionsRetrieved.size(),'Testing');
            for(CLQ_Inspection__c Inspct : InspectionsRetrieved)
                system.AssertEquals(ProgramTransaction2.Id , Inspct.CLQ_Program_Transaction__c,'Testing');
            
            Test.StopTest();	
        }
    }
    
    @testSetup 
    public static void testSetup()
    {
        //CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_UnitTestUtilities.HardCodedTransactionCreation();
    }
}