/*************************************************************************************************************
** Name            : CLQ_UserTriggerHandlerTest  
** Description     : Test Class for CLQ_UserTriggerHandler
** Version         : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer						Date					Version		Description
**------------------------------------------------------------------------------------------------------------
**	Neetu Ojha						Sep 25, 2017			1.0			Initial Version                 
**************************************************************************************************************/ 
@isTest
private class CLQ_UserTriggerHandlerTest {
    
    @testSetup
    public static void setExecuteControlSetting(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        User usr =[select id, UserRoleId, ProfileId, IsActive from User where UserRoleId !=null and ProfileId !=null and IsActive =true limit 1];
        
        
        
        
        //Create account record
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name='Test Account1',CLQ_DIRN__c = '1234',OwnerId= usr.Id)); 
        lstAccount.add(new Account(Name='Test Account2',CLQ_DIRN__c = '1234',OwnerId= usr.Id)); 
        insert lstAccount ;
        
        //Insert contact
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(new Contact(FirstName='Test', lastName = 'Contact1',AccountId = lstAccount[0].id));
        lstContact.add(new Contact(FirstName='Test', lastName = 'Contact2',AccountId = lstAccount[1].id));
        insert lstContact;
    }
    
    @IsTest
    static void newUserUnitTest(){  
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            List<Contact> lstContact = [Select Id from Contact where FirstName='Test'];  
            List<User> lstUser = new List<User>();
            //Create a new user
            
            List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name IN ('OCLQS Customer Community Plus Login User','OCLQS Customer Community Login User') order by Name];
            lstUser.add(new User(LastName = 'Pierce', FirstName = 'Ben', Alias = 'bpie', Email = 'ben.pierce@test.com',
                                 Username = 'ben.pierce@ygmail.com',ProfileId = lstProfile[0].id, ContactId=lstContact[0].Id,
                                 TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',
                                 IsActive  = true, CommunityNickname = 'testbenpierce'));      
            
            
            
            
            Test.startTest();
            insert lstUser; 
            Test.stopTest(); 
        }
        
    }    
    
    @IsTest
    static void updateUserUnitTest() {
        system.assertEquals(True, 1==1,'Testing');
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        List<Contact> lstContact = [Select Id from Contact where FirstName='Test']; 
        Account accountrecord = new Account(Name='Test Account', CLQ_DIRN__C = '1234');
        insert accountrecord;
        List<User> lstUser=new List<User>();
        
         List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name IN ('OCLQS Customer Community Plus Login User','OCLQS Customer Community Login User') order by Name];
         lstUser.add(new User(LastName = 'Pierce', FirstName = 'Ben', Alias = 'bpie', Email = 'ben.pierce@test.com',
                                 Username = 'ben.pierce@ygmail.com',ProfileId = lstProfile[0].id,ContactId=lstContact[0].Id,
                                 TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',
                                 IsActive  = true, CommunityNickname = 'testbenpierce'));     
        insert lstUser; 
        //List<User> lstUser = [Select Id,isActive,ManagerId from User where Profile.Name = 'OCLQS Customer Community Plus Login User' limit 1];
        //List<User> lstUser = [Select Id,isActive,ManagerId from User where Profile.Name = 'Customer Community Login VDSS' limit 1];
        lstUser[0].isActive=false;
        List<User> lstUser1=[Select Id,isActive,Manager.IsActive,ManagerId from User where ManagerId !=null and ( Profile.name like '%Admin%') and manager.isactive =true and IsActive =true limit 1];
        lstUser[0].isActive=false;
        lstUser[0].ManagerId=lstUser1[0].Id;
        
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord.OwnerId= lstUser[0].Id;
        insert programRecord;
        
        CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
        programTransaction.CLQ_Program__c = programRecord.Id;
        programTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        programTransaction.Rating_Estimated_By_System__c = '2';
        programTransaction.CLQ_Transaction_Status__c = 'Not Complete';
        programTransaction.OwnerId=lstUser[0].Id;
        Insert programTransaction;
        
        CLQ_Inspection__c inspection = new CLQ_Inspection__c();
        inspection.Inspection_Status__c = 'Not Complete';
        inspection.CLQ_Inspection_Status__c = 'Pending Processing';
        inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspection.CLQ_Program__c = programRecord.id;
        inspection.OwnerId=lstUser[0].Id;
        Insert inspection;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        
        
        system.runAs(lstUser1[0]){
            Test.startTest();
            CLQ_UserTriggerHandler.BypassTrigger=null;
            update lstUser[0];
        }
        
        Test.stopTest(); 
    }       
}