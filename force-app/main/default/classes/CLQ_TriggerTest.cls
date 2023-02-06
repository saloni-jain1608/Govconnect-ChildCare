/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_TriggerTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isParallel=true)
private class CLQ_TriggerTest 
{
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 
    @IsTest
    static void constructorTest() 
    { 
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
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{programRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    
                    //Before Insert
                    CLQ_Trigger trig = new CLQ_Trigger(NewList, null, OldList, null,
                                                       true, true, false, false, 
                                                       true, false, false, 1);
            //system.AssertEquals('BeforeInsert', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger(); 
            
            //After Insert
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, true, false, false, 
                                   false, true, false, 1);
            //system.AssertEquals('AfterInsert', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //Before Update
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, true, false, 
                                   true, false, false, 1);
            //system.AssertEquals('BeforeUpdate', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //After Update
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, true, false, 
                                   false, true, false, 1);
            //system.AssertEquals('AfterUpdate', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //Before Delete
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, false, true, 
                                   true, false, false, 1);
            //system.AssertEquals('BeforeDelete', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //After Delete
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, false, true, 
                                   false, true, false, 1);
            //system.AssertEquals('AfterDelete', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //Before UnDelete
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, false, false, 
                                   true, false, true, 1);
            //system.AssertEquals('BeforeUndelete', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //After UnDelete
            trig = new CLQ_Trigger(NewList, null, OldList, null,
                                   true, false, false, false, 
                                   false, true, true, 1);
            //system.AssertEquals('AfterUndelete', trig.TriggerExecutionType,'Testing');
            trig.ProcessTrigger();
            
            //Bypass Trigger
            CLQ_Trigger.BypassAllTriggers = true;
            trig.ProcessTrigger();
            CLQ_Trigger.BypassAllTriggers = false;
            
            CLQ_ProgramTriggerHandler trig2 = new CLQ_ProgramTriggerHandler(NewList, null, OldList, null,
                                                                            true, true, false, false, 
                                                                            true, false, false, 1);
            CLQ_Program_TransactionTriggerHandler.BypassTrigger = true; 
            trig2.ProcessTrigger();
        }
    }
    
    @IsTest
    static void makeVersionBackupTest() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home', CLQ_Change_of_Location_Fee__c = 12.5, Program_Type__c = 'Child Care Center');
            insert configRecord;
            map<Id,CLQ_OCLQS_Configuration__c> OldMap = new  map<Id,CLQ_OCLQS_Configuration__c>();
            OldMap.put(configRecord.id, configRecord);
            
            CLQ_OCLQS_Configuration__c NewChangedConfigRecord = configRecord.Clone(true,true,true,true);
            NewChangedConfigRecord.CLQ_Change_of_Location_Fee__c = 44;
            NewChangedConfigRecord.Program_Type__c = 'FCC Type B';
            
            CLQ_OCLQS_Configuration__c configRecordClone = (CLQ_OCLQS_Configuration__c)CLQ_Trigger.MakeVersionBackup(NewChangedConfigRecord.Id, OldMap);
            
            system.AssertEquals(null, configRecordClone.Id,'Testing');
            system.AssertNotEquals(NewChangedConfigRecord.Id, configRecordClone.Id,'Testing');
            system.AssertNotEquals(NewChangedConfigRecord.CLQ_Change_of_Location_Fee__c, configRecordClone.CLQ_Change_of_Location_Fee__c,'Testing');
            system.AssertNotEquals(NewChangedConfigRecord.Program_Type__c, configRecordClone.Program_Type__c,'Testing');
            
            system.AssertNotEquals(configRecord.Id, configRecordClone.Id,'Testing');
            system.AssertEquals(configRecord.CLQ_Change_of_Location_Fee__c, configRecordClone.CLQ_Change_of_Location_Fee__c,'Testing');
            system.AssertEquals(configRecord.Program_Type__c, configRecordClone.Program_Type__c,'Testing');
        } 
    }
}