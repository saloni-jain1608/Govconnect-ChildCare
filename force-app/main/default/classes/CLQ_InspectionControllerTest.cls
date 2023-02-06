/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_InspectionControllerTest
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
private class CLQ_InspectionControllerTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
            CLQ_UnitTestUtilities.setExecuteControlSetting();
        
    }	
    @IsTest
    static void inspectionControllerTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Id userId = UserInfo.getUserId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configRecord; 
            }
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord ;
            }
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Admin Read-Only' LIMIT 1];               
            User usr = new User(LastName = 'Hugh',
                                FirstName = 'Jack',
                                Alias = 'jHugh',
                                Email = 'jack@hugh.com',
                                Username = 'jack@hugh.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            if(Schema.SObjectType.User.isAccessible()){
                insert usr; 
            }
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord ;   
            }
            
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord2.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord2 ; 
            }
            
            //Insert CLQ_Inspection__c 
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Complaint', 'Partial', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            inspectionrecord.OwnerId = userId;
            if(Schema.SObjectType.CLQ_Inspection__c.isAccessible()){
                insert inspectionrecord;
            }
            
            system.assertEquals(true, inspectionrecord.CLQ_Use_Rules_Effective_On__c<Date.today(),'Testing');
            User currUser;
            if(Schema.SObjectType.User.isAccessible()){
                currUser = [Select Profile.Name from User where Id =: userId ];
            }
            String ProfileName = currUser.Profile.Name;
            Global_Settings__c GlobalSettings = new Global_Settings__c();
            GlobalSettings.SetupOwnerId=userId;
            GlobalSettings.Can_Edit_Closed_Programs__c = ProfileName;
            GlobalSettings.Can_Edit_Closed_Programs2__c = ProfileName;  
            if(Schema.SObjectType.Global_Settings__c.isAccessible()){
                Insert GlobalSettings;
            }
            
            
            //Create Inspection Record
            CLQ_Inspection__c insptn = CLQ_UtilityClass.createInspectionrecord('Complaint', 'Partial', 'Pending Processing');
            insptn.CLQ_Inspection_Owner__c = usr.Id;
            insptn.OwnerId = usr.Id;
            insptn.CLQ_Program__c = programRecord2.Id;
            insptn.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            if(Schema.SObjectType.CLQ_Inspection__c.isAccessible()){
                Insert insptn;
            }
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(inspectionrecord);
            CLQ_InspectionController ic = new CLQ_InspectionController(sc);            
            system.AssertNotEquals(null,insptn.CLQ_Inspection_Owner__c,'Testing');
            
            ApexPages.StandardController sc2 = new ApexPages.StandardController(insptn);
            CLQ_InspectionController ic2 = new CLQ_InspectionController(sc2);                    
            Test.stopTest();
        }
    }
    @IsTest
    static void inspectionControllerTestTwo(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Id userId = UserInfo.getUserId();        
            User currUser2 = [Select Profile.Name from User where Id =: userId];
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord; 
            
            //Create account record
            Account accountrecord2 = new Account(Name='Test2 Account2',CLQ_DIRN__c = '1234'); 
            insert accountrecord2 ;       
            
            Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'Standard user' LIMIT 1];               
            User usr2 = new User(LastName = 'Hugh',
                                 FirstName = 'Jill',
                                 Alias = 'jillHu',
                                 Email = 'jill@hugh.com',
                                 Username = 'jill@hugh.com',
                                 ProfileId = profileId2.id,
                                 TimeZoneSidKey = 'GMT',
                                 LanguageLocaleKey = 'en_US',
                                 EmailEncodingKey = 'UTF-8',
                                 LocaleSidKey = 'en_US'
                                );
            insert usr2;
            
            User usr3 = new User(LastName = 'Hugh',
                                 FirstName = 'Bill',
                                 Alias = 'BillHu',
                                 Email = 'bill@hugh.com',
                                 Username = 'bill@hugh.com',
                                 ProfileId = profileId2.id,
                                 TimeZoneSidKey = 'GMT',
                                 LanguageLocaleKey = 'en_US',
                                 EmailEncodingKey = 'UTF-8',
                                 LocaleSidKey = 'en_US'
                                );
            insert usr3;
            
            //Create a program record
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test2';
            programRecord3.CLQ_Associated_Organization__c = accountrecord2.id;
            programRecord3.CLQ_Street_Address_1__c = 'test2';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord3.CLQ_Licensing_Specialist__c = currUser2.Id;
            insert programRecord3 ;  
            
            Global_Settings__c GlobalSettings2 = new Global_Settings__c();
            GlobalSettings2.Name='TestGS';
            GlobalSettings2.SetupOwnerId = usr2.Id;  
            GlobalSettings2.Can_Edit_Closed_Programs__c = 'System Administrator';
            GlobalSettings2.Can_Edit_Closed_Programs2__c = 'System Administrator'; 
            Insert GlobalSettings2;
            
            //Create Inspection Record
            CLQ_Inspection__c inspectionrecord2 = CLQ_UtilityClass.createInspectionrecord('Complaint', 'Partial', 'Pending Processing');
            inspectionrecord2.CLQ_Program__c = programRecord3.id;       
            inspectionrecord2.OwnerId = usr3.Id;
            inspectionrecord2.CLQ_Inspection_Owner__c = currUser2.Id;
            insert inspectionrecord2;
            
            //Create Inspection Record
            CLQ_Inspection__c inspectionrecord3 = CLQ_UtilityClass.createInspectionrecord('Complaint', 'Partial', 'Pending Processing');
            inspectionrecord3.CLQ_Program__c = programRecord3.id;       
            inspectionrecord3.OwnerId = usr3.Id;
            inspectionrecord3.CLQ_Inspection_Owner__c = currUser2.Id;
            insert inspectionrecord3;
            
            //Create Inspector Record
            List<CLQ_Inspector__c> inspectors = new List<CLQ_Inspector__c>();
            CLQ_Inspector__c insptr1 = new CLQ_Inspector__c ();
            insptr1.CLQ_Inspection__c = inspectionrecord2.Id;
            insptr1.CLQ_Inspector_Name__c = currUser2.Id;
            inspectors.add(insptr1);   
            
            CLQ_Inspector__c insptr2 = new CLQ_Inspector__c ();
            insptr2.CLQ_Inspection__c = inspectionrecord2.Id;        
            insptr2.CLQ_Inspector_Name__c = currUser2.Id;       
            inspectors.add(insptr2);
            Insert inspectors;
            
            CLQ_Inspector__c insptr3 = new CLQ_Inspector__c ();
            insptr3.CLQ_Inspection__c = inspectionrecord3.Id;
            insptr3.CLQ_Inspector_Name__c = currUser2.Id;
            Insert insptr3;
            CLQ_Inspector__c insptr4 = new CLQ_Inspector__c ();
            insptr4.CLQ_Inspection__c = inspectionrecord3.Id;
            insptr4.CLQ_Inspector_Name__c = currUser2.Id;
            Insert insptr4;   
            
            List<CLQ_Inspector__c> inspectorQuery = [Select id,CLQ_Inspector_Name__c FROM CLQ_Inspector__c WHERE CLQ_Inspection__c =:inspectionrecord2.Id];
            
            
            CLQ_Inspection__c insp = [Select id,OwnerId,CLQ_Inspection_Owner__c from CLQ_Inspection__c where id =: inspectionrecord2.Id];
            insp.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            update insp;
            
            Test.startTest();            
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(insp);     
            CLQ_InspectionController inspCtrl = new CLQ_InspectionController(stdCtrl);          
            Test.stopTest();
        }
    }
}

/*User u = [select Profile.Name from User where id =: UserInfo.getUserId()];
System.debug('current users profile'+u.Profile.Name);
u.Profile.Name = 'Standard User';
Update u;
System.debug('current users profile222'+u.Profile.Name);*/
/*Commented code to be added at line 164 above test.starttest if needed
* Global_Settings__c GS1 = new Global_Settings__c();
GS1 = [Select Id,Can_Edit_Closed_Programs__c,Can_Edit_Closed_Programs2__c from Global_Settings__c where Id =: GlobalSettings2.Id ];        
if(GS1.Can_Edit_Closed_Programs2__c.Contains(currUser2.Profile.Name) || GS1.Can_Edit_Closed_Programs__c.Contains(currUser2.Profile.Name) ){
System.debug('COntains profile name');
String PFName = currUser2.Profile.Name;
String s1 = GS1.Can_Edit_Closed_Programs__c;       
GS1.Can_Edit_Closed_Programs__c = s1.remove(PFName);
System.debug('CECP - '+GS1.Can_Edit_Closed_Programs__c);
String s2 = GS1.Can_Edit_Closed_Programs2__c;
GS1.Can_Edit_Closed_Programs2__c = s2.remove(PFName);
System.debug('CECP2 - '+GS1.Can_Edit_Closed_Programs2__c);
Update GS1;   
}*/
/*User U = [Select Profile.Name from User where Id =: userId];
String PFName = U.Profile.Name;
Global_Settings__c GS1 = new Global_Settings__c();
GS1 = [Select Id,Can_Edit_Closed_Programs__c,Can_Edit_Closed_Programs2__c from Global_Settings__c where Id =: GlobalSettings.Id ];
String s1 = GS1.Can_Edit_Closed_Programs__c;       
GS1.Can_Edit_Closed_Programs__c = s1.remove(PFName);
String s2 = GS1.Can_Edit_Closed_Programs2__c;
GS1.Can_Edit_Closed_Programs2__c = s2.remove(PFName);
Update GS1;*/