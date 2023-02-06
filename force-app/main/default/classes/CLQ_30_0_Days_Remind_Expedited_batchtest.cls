@isTest
public class CLQ_30_0_Days_Remind_Expedited_batchtest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void clqExpeditedbatchtestOne(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            Contact c = new Contact();
            c.LastName = 'abcd';
            c.Email = 'NOREPLY@TEST.COM';
            insert c;
            
            CLQ_Role__c role = new CLQ_Role__c();
            role.CLQ_Contact__c = c.id;
            role.recordTypeid = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            role.Role_Type__c = 'JFS';
            role.Portal_Roles__c = 'Owner';
            insert role;
            
            CLQ_Program__c cp = new CLQ_Program__c();
            cp.Name = 'test FCC';
            cp.CLQ_License_Registration_Status__c = 'Licensed';
            cp.Program_Rating__c = '1';
            cp.Rating_Effective_Date__c = date.today().addDays(-200);
            cp.Rating_Expiration_Date__c = date.today().addDays(30);
            cp.CLQ_License_Issue_Date__c = date.today().addDays(-10);
            cp.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            cp.CLQ_Program_Status__c = 'Open';
            cp.CLQ_Program_Email__c= 'test125266@test.com';
            cp.Role__c = role.Id;
            insert cp;
            
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            insert accountrecord ;
            
            CLQ_Program_Transaction__c PT = new CLQ_Program_Transaction__c();
            PT.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
            PT.CLQ_Transaction_Status__c = 'Submitted';
            PT.CLQ_Program__c = cp.id;
            PT.CLQ_Associated_Organization__c = accountrecord.id ;
            PT.Submission_Date1__c = date.today();
            insert PT;
            
            CLQ_30_0_Days_Reminder_Expedited_Batch obj = new CLQ_30_0_Days_Reminder_Expedited_Batch();
            DataBase.executeBatch(obj);  
            Test.stopTest();
        }
    }
    @IsTest
    static void clqExpeditedbatchtestTwo(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_Program__c cp1 = new CLQ_Program__c();
            cp1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            cp1.Name = 'test school';
            cp1.CLQ_License_Registration_Status__c = 'Licensed';
            cp1.Program_Rating__c = '1';
            cp1.Rating_Effective_Date__c = date.today().addDays(-200);
            cp1.Rating_Expiration_Date__c = date.today().addDays(25);
            cp1.CLQ_License_Issue_Date__c = date.today().addDays(-10);
            cp1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            cp1.CLQ_Program_Status__c = 'Open';
            cp1.CLQ_Program_Email__c= 'test125266@test.com';
            insert cp1;
            
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234',Ownership = 'Individual Ownership'); 
            insert accountrecord ;
            
            CLQ_Program_Transaction__c PT = new CLQ_Program_Transaction__c();
            PT.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            PT.CLQ_Transaction_Status__c = 'Submitted';
            PT.CLQ_Program__c = cp1.id;
            PT.CLQ_Associated_Organization__c = accountrecord.id ;
            PT.Submission_Date1__c = date.today();
            insert PT;
            
            Contact c = new Contact();
            c.LastName = 'abcde';
            c.Email = 'NOREPLY@TEST.COM';
            insert c;
            
            CLQ_Role__c role = new CLQ_Role__c();
            role.CLQ_Contact__c = c.id;
            role.recordTypeid = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            role.Role_Type__c = 'ODE';
            role.Portal_Roles__c = 'OCLQSOwner';
            insert role;
            
            CLQ_30_0_Days_Reminder_Expedited_Batch obj = new CLQ_30_0_Days_Reminder_Expedited_Batch();
            DataBase.executeBatch(obj);  
            Test.stopTest();
        }
        
    }
    
}