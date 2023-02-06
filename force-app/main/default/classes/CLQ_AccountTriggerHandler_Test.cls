/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_AccountTriggerHandler_Test
** Description      : Test class for CLQ_AccountTriggerHandler | NIU
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Pavan Ayta              11/3/17         1.0         Initial Build 
**************************************************************************************************************/
@isTest
private class CLQ_AccountTriggerHandler_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void testMethod1()
    {  
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_UnitTestUtilities.setExecuteControlSetting();
            //CLQ_AccountTriggerHandler account1 = new CLQ_AccountTriggerHandler();
            Test.startTest();
            Account accountrecord =  new Account(Name='Test Account',CLQ_DIRN__c = '123456');
            Account accountrecord1 = new Account(Name='Test Account1', CLQ_DIRN__c='456789');
            List<Account> la = new List<Account>();
            la.add(accountrecord);
            la.add(accountrecord1);
            insert la;
            la[0].Name = 'Test';    
            la[1].Name = 'Test1';
            update la;
            
            
            
            Account acc2= new Account();
            acc2.Name = 'Account Test2';
            acc2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CLQ_Corporation_LLC').getRecordTypeId();
            acc2.CLQ_DIRN__c='111111';
            insert acc2;
            Account ac=[select id ,name from Account where id=:acc2.id ]; 
            ac.CLQ_DIRN__c='456789';        
            update ac;
            
            List<Account> toInsert = new List<Account>();
            
            Account acc3= new Account();
            acc3.Name = 'Account Test3';
            acc3.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CLQ_Corporation_LLC').getRecordTypeId();
            acc3.CLQ_DIRN__c='111112';
            toInsert.add(acc3);
            
            Account acc4= new Account();
            acc4.Name = 'Account Test3';
            acc4.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CLQ_Corporation_LLC').getRecordTypeId();
            acc4.CLQ_DIRN__c='111111';
            toInsert.add(acc4);
            
            insert toInsert;
            
            acc4.CLQ_DIRN__c = '331111';
            
            update acc4;
            
            
            Test.stopTest();  
        }
    }
    
}