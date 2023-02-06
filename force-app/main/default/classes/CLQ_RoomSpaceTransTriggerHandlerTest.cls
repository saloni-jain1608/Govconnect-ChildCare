/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_RoomSpaceTransTriggerHandlerTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**  Prakriti Biswas         9/19/17         1.1         Added record for Irregular Room Space Shape for Indoor Room                  
**************************************************************************************************************/
@isTest
private class CLQ_RoomSpaceTransTriggerHandlerTest {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void roomSpaceTransactionTriggerHandlerTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            //Create Account Record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create Program Record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Program Name Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecord ;
            
            CLQ_OCLQS_Configuration__c configRecordA = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            insert configRecordA; 
            //Create Account Record
            Account accountrecordA = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecordA ;
            //Create Program Record
            CLQ_Program__c programRecordA = new CLQ_Program__c();
            programRecordA.Name = 'Program Name Test';
            programRecordA.CLQ_Associated_Organization__c = accountrecordA.id;
            programRecordA.CLQ_Street_Address_1__c = 'test';
            programRecordA.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            programRecordA.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecordA ;
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTransA = new CLQ_Program_Transaction__c();
            progTransA.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            progTransA.CLQ_Program__c = programRecordA.Id;
            progTransA.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTransA.CLQ_Transaction_Status__c = 'Not Submitted';
            progTransA.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            Insert progTransA;       
            
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTrans = new CLQ_Program_Transaction__c();
            progTrans.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            progTrans.CLQ_Program__c = programRecord.Id;
            progTrans.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTrans.CLQ_Transaction_Status__c = 'Not Submitted';
            progTrans.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            Insert progTrans;
            
            CLQ_OCLQS_Configuration__c configRecord2 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord2; 
            //Create Account Record
            Account accountrecord2 = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord2 ;
            //Create Program Record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Program Name Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord2.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord2.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecord2 ;
            
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTrans2 = new CLQ_Program_Transaction__c();
            progTrans2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            progTrans2.CLQ_Program__c = programRecord2.Id;
            progTrans2.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTrans2.CLQ_Transaction_Status__c = 'Not Submitted';
            progTrans2.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            Insert progTrans2;
            
            progTrans.CLQ_ProgTrans_Street_Address__c = 'updated Street';
            update progTrans;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
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
            insert usr; 
            list<CLQ_Room_Space_Transaction__c> rstInsert = new list<CLQ_Room_Space_Transaction__c>();
            
            CLQ_Room_Space_Transaction__c rstRecord = new CLQ_Room_Space_Transaction__c();
            rstRecord.Name = 'Office Room';
            rstRecord.CLQ_Room_Space_Number__c = '4321';
            rstRecord.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Outdoor_Space').getRecordTypeId();
            rstRecord.CLQ_Program_Transaction__c = progTrans.Id;
            rstRecord.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord.CLQ_Length_Feet__c = 3;
            rstRecord.CLQ_Width_Feet__c = 3;
            //rstRecord.CLQ_Length_Feet__c = 44;
            //rstRecord.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord); 
            
            CLQ_Room_Space_Transaction__c rstRecord2 = new CLQ_Room_Space_Transaction__c();
            rstRecord2.Name = 'Office Room2';
            rstRecord2.CLQ_Room_Space_Number__c = '4321';
            rstRecord2.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord2.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord2.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord2.CLQ_Length_Feet__c = 3;
            rstRecord2.CLQ_Width_Feet__c = 3;
            rstRecord2.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord2.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            //rstRecord2.CLQ_Length_Feet__c = 44;
            //rstRecord2.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord2);    
            
            CLQ_Room_Space_Transaction__c rstRecord3 = new CLQ_Room_Space_Transaction__c();
            rstRecord3.Name = 'Office Room3';
            rstRecord3.CLQ_Room_Space_Number__c = '4321';
            rstRecord3.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord3.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord3.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord3.CLQ_Length_Feet__c = 3;
            rstRecord3.CLQ_Width_Feet__c = 3;
            rstRecord3.CLQ_Approved_Room_Space__c = true;
            rstRecord3.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord3.CLQ_Currently_In_Use__c = 'Yes';
            rstRecord3.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Over';
            //rstRecord3.CLQ_Length_Feet__c = 44;
            //rstRecord3.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord3); 
            
            CLQ_Room_Space_Transaction__c rstRecord4 = new CLQ_Room_Space_Transaction__c();
            rstRecord4.Name = 'Office Room4';
            rstRecord4.CLQ_Room_Space_Number__c = '4321';
            rstRecord4.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord4.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord4.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord4.CLQ_Length_Feet__c = 3;
            rstRecord4.CLQ_Width_Feet__c = 3;
            rstRecord4.CLQ_Approved_Room_Space__c = true;
            rstRecord4.CLQ_Currently_In_Use__c = 'Yes';
            rstRecord4.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord4.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            //rstRecord4.CLQ_Length_Feet__c = 44;
            //rstRecord4.CLQ_Width_Feet__c =20;
            rstInsert.add( rstRecord4);  
            
            CLQ_Room_Space_Transaction__c rstRecord11 = new CLQ_Room_Space_Transaction__c();
            rstRecord11.Name = 'Office Room';
            rstRecord11.CLQ_Room_Space_Number__c = '4321';
            rstRecord11.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord11.CLQ_Program_Transaction__c = progTrans.Id;
            rstRecord11.CLQ_Room_Space_Shape__c = 'Irregular';
            rstRecord11.CLQ_Length_Feet__c = 3;
            rstRecord11.CLQ_Width_Feet__c = 3;
            //rstRecord.CLQ_Length_Feet__c = 44;
            //rstRecord.CLQ_Width_Feet__c =20;
            rstRecord11.CLQ_Square_Footage_Irregular__c = 300;
            rstInsert.add(rstRecord11); 
            
            CLQ_Room_Space_Transaction__c rstRecord5 = new CLQ_Room_Space_Transaction__c();
            rstRecord5.Name = 'Office Room5';
            rstRecord5.CLQ_Room_Space_Number__c = '4321';
            rstRecord5.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Outdoor_Space').getRecordTypeId();
            rstRecord5.CLQ_Program_Transaction__c = progTransA.Id;
            rstRecord5.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord5.CLQ_Length_Feet__c = 3;
            rstRecord5.CLQ_Width_Feet__c = 3;
            //rstRecord5.CLQ_Length_Feet__c = 44;
            //rstRecord5.CLQ_Width_Feet__c =20;
            rstInsert.add( rstRecord5);         
            insert  rstInsert;
            test.startTest(); 
            
            CLQ_Room_Space_Transaction__c oldRstRecord = rstRecord.clone(true,true,true,true);
            
            rstRecord.CLQ_Length_Feet__c = 4;
            rstRecord.CLQ_Width_Feet__c = 5;
            update rstRecord;
            
            list<CLQ_Room_Space_Transaction__c> oldList = new List<CLQ_Room_Space_Transaction__c>([Select Id, Name FROM CLQ_Room_Space_Transaction__c where Id =: oldRstRecord.Id]);
            list<CLQ_Room_Space_Transaction__c> newList = new List<CLQ_Room_Space_Transaction__c>([Select Id, Name FROM CLQ_Room_Space_Transaction__c where Id =: rstRecord.Id]);
            Map<id,CLQ_Room_Space_Transaction__c> oldMap = new Map<id,CLQ_Room_Space_Transaction__c>{oldRstRecord.id => oldRstRecord};         
                Map<id,CLQ_Room_Space_Transaction__c> newMap = new Map<id,CLQ_Room_Space_Transaction__c>{rstRecord.id => rstRecord};
                    
                    CLQ_RoomSpaceTransactionTriggerHandler rst = new CLQ_RoomSpaceTransactionTriggerHandler(newList,newMap,oldList,oldMap,
                                                                                                            true,false,true,false,
                                                                                                            true,false,false,1);
            CLQ_Room_Space_Transaction__c rstUpdate = [Select Id,clq_formatted_change_table__c, Name,CLQ_Room_Space_Number__c from CLQ_Room_Space_Transaction__c where Id =: rstRecord.Id];
            rstUpdate.CLQ_Room_Space_Number__c = '4433';
            update rstUpdate; 
            delete rstUpdate;
            //rst.buildFieldChangeHtmlTable(newList, oldMap);
            //rst.UpdateFormulaValuesPT(newMap, oldMap);
            test.stopTest();
        }
    }
    
    @IsTest
    static void communityProfile(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            //Create Account Record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Profile profileId = [SELECT Id FROM Profile WHERE Name = 'OCLQS Customer Community Login User' LIMIT 1];
            Id profileId = [select id from profile where name='OCLQS Customer Community Plus Login User'].id;
            
            Contact objContact = new Contact(LastName ='testCon',AccountId = accountrecord.Id);
            insert objContact;  
            
            CLQ_OCLQS_Configuration__c configRecordA = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            insert configRecordA; 
            //Create Account Record
            Account accountrecordA = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecordA ;
            
            CLQ_OCLQS_Configuration__c configRecord2 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord2; 
            //Create Account Record
            Account accountrecord2 = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord2 ;
            
           
            
            user usr= [select id from user where isactive = true AND Profile.Name like '%System Admin%' limit 1];
            User usr1 = new User(alias = 'TestUser', email='test123@test.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                                ContactId = objContact.Id,
                                timezonesidkey='America/Los_Angeles', username='tester@123.com');
            
            //insert usr1;
            
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Program Name Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.OwnerId = usr.Id;
            insert programRecord ;
            
            //Create Program Record
            CLQ_Program__c programRecordA = new CLQ_Program__c();
            programRecordA.Name = 'Program Name Test';
            programRecordA.CLQ_Associated_Organization__c = accountrecordA.id;
            programRecordA.CLQ_Street_Address_1__c = 'test';
            programRecordA.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            programRecordA.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecordA.OwnerId = usr.Id;
            insert programRecordA ;
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTransA = new CLQ_Program_Transaction__c();
            progTransA.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            progTransA.CLQ_Program__c = programRecordA.Id;
            progTransA.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTransA.CLQ_Transaction_Status__c = 'Not Submitted';
            progTransA.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            progTransA.OwnerId = usr.Id;
            Insert progTransA;       
            
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTrans = new CLQ_Program_Transaction__c();
            progTrans.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            progTrans.CLQ_Program__c = programRecord.Id;
            progTrans.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTrans.CLQ_Transaction_Status__c = 'Not Submitted';
            progTrans.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            progTrans.OwnerId = usr.Id;
            Insert progTrans;
            
            //Create Program Record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Program Name Test';
            programRecord2.CLQ_Associated_Organization__c = accountrecord2.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord2.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord2.OwnerId = usr.Id;
            insert programRecord2 ;
            
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTrans2 = new CLQ_Program_Transaction__c();
            progTrans2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            progTrans2.CLQ_Program__c = programRecord2.Id;
            progTrans2.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTrans2.CLQ_Transaction_Status__c = 'Not Submitted';
            progTrans2.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            progTrans2.OwnerId = usr.Id;
            Insert progTrans2;
            
            CLQ_Program_Transaction__c progTrans3 = new CLQ_Program_Transaction__c();
            progTrans3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_Outdoor_Space_Information').getRecordTypeId();
            progTrans3.CLQ_Program__c = programRecord2.Id;
            progTrans3.CLQ_ProgTrans_Street_Address__c ='old Street';
            progTrans3.CLQ_Transaction_Status__c = 'Not Submitted';
            progTrans3.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            progTrans3.OwnerId = usr.Id;
            Insert progTrans3;
            
            progTrans.CLQ_ProgTrans_Street_Address__c = 'updated Street';
            update progTrans;
            
            list<CLQ_Room_Space_Transaction__c> rstInsert = new list<CLQ_Room_Space_Transaction__c>();
            
            CLQ_Room_Space_Transaction__c rstRecord = new CLQ_Room_Space_Transaction__c();
            rstRecord.Name = 'Office Room';
            rstRecord.CLQ_Room_Space_Number__c = '4321';
            rstRecord.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Outdoor_Space').getRecordTypeId();
            rstRecord.CLQ_Program_Transaction__c = progTrans.Id;
            rstRecord.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord.CLQ_Length_Feet__c = 3;
            rstRecord.CLQ_Width_Feet__c = 3;
            rstRecord.OwnerId = usr.Id;
            //rstRecord.CLQ_Length_Feet__c = 44;
            //rstRecord.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord); 
            
            CLQ_Room_Space_Transaction__c rstRecord2 = new CLQ_Room_Space_Transaction__c();
            rstRecord2.Name = 'Office Room2';
            rstRecord2.CLQ_Room_Space_Number__c = '4321';
            rstRecord2.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord2.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord2.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord2.CLQ_Length_Feet__c = 3;
            rstRecord2.CLQ_Width_Feet__c = 3;
            rstRecord2.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord2.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            rstRecord2.OwnerId = usr.Id;
            //rstRecord2.CLQ_Length_Feet__c = 44;
            //rstRecord2.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord2);    
            
            CLQ_Room_Space_Transaction__c rstRecord3 = new CLQ_Room_Space_Transaction__c();
            rstRecord3.Name = 'Office Room3';
            rstRecord3.CLQ_Room_Space_Number__c = '4321';
            rstRecord3.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord3.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord3.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord3.CLQ_Length_Feet__c = 3;
            rstRecord3.CLQ_Width_Feet__c = 3;
            rstRecord3.CLQ_Approved_Room_Space__c = true;
            rstRecord3.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord3.CLQ_Currently_In_Use__c = 'Yes';
            rstRecord3.OwnerId = usr.Id;
            rstRecord3.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Over';
            //rstRecord3.CLQ_Length_Feet__c = 44;
            //rstRecord3.CLQ_Width_Feet__c =20;
            rstInsert.add(rstRecord3); 
            
            CLQ_Room_Space_Transaction__c rstRecord4 = new CLQ_Room_Space_Transaction__c();
            rstRecord4.Name = 'Office Room4';
            rstRecord4.CLQ_Room_Space_Number__c = '4321';
            rstRecord4.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord4.CLQ_Program_Transaction__c = progTrans2.Id;
            rstRecord4.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord4.CLQ_Length_Feet__c = 3;
            rstRecord4.CLQ_Width_Feet__c = 3;
            rstRecord4.CLQ_Approved_Room_Space__c = true;
            rstRecord4.CLQ_Currently_In_Use__c = 'Yes';
            rstRecord4.CLQ_Room_Space_Type__c = 'Primary Space';
            rstRecord4.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            rstRecord4.OwnerId = usr.Id;
            //rstRecord4.CLQ_Length_Feet__c = 44;
            //rstRecord4.CLQ_Width_Feet__c =20;
            rstInsert.add( rstRecord4);  
            
            CLQ_Room_Space_Transaction__c rstRecord11 = new CLQ_Room_Space_Transaction__c();
            rstRecord11.Name = 'Office Room';
            rstRecord11.CLQ_Room_Space_Number__c = '4321';
            rstRecord11.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rstRecord11.CLQ_Program_Transaction__c = progTrans.Id;
            rstRecord11.CLQ_Room_Space_Shape__c = 'Irregular';
            rstRecord11.CLQ_Length_Feet__c = 3;
            rstRecord11.CLQ_Width_Feet__c = 3;
            rstRecord11.OwnerId = usr.Id;
            //rstRecord.CLQ_Length_Feet__c = 44;
            //rstRecord.CLQ_Width_Feet__c =20;
            rstRecord11.CLQ_Square_Footage_Irregular__c = 300;
            rstInsert.add(rstRecord11); 
            
            CLQ_Room_Space_Transaction__c rstRecord5 = new CLQ_Room_Space_Transaction__c();
            rstRecord5.Name = 'Office Room5';
            rstRecord5.CLQ_Room_Space_Number__c = '4321';
            rstRecord5.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Outdoor_Space').getRecordTypeId();
            rstRecord5.CLQ_Program_Transaction__c = progTransA.Id;
            rstRecord5.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord5.CLQ_Length_Feet__c = 3;
            rstRecord5.CLQ_Width_Feet__c = 3;
            rstRecord5.OwnerId = usr.Id;
            //rstRecord5.CLQ_Length_Feet__c = 44;
            //rstRecord5.CLQ_Width_Feet__c =20;
            rstInsert.add( rstRecord5);  
            
            CLQ_Room_Space_Transaction__c rstRecord6 = new CLQ_Room_Space_Transaction__c();
            rstRecord6.Name = 'Office Room6';
            rstRecord6.CLQ_Room_Space_Number__c = '4321';
            rstRecord6.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Outdoor_Space').getRecordTypeId();
            rstRecord6.CLQ_Program_Transaction__c = progTransA.Id;
            rstRecord6.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rstRecord6.CLQ_Length_Feet__c = 3;
            rstRecord6.CLQ_Width_Feet__c = 3;
            rstRecord6.OwnerId = usr.Id;
            //rstRecord5.CLQ_Length_Feet__c = 44;
            //rstRecord5.CLQ_Width_Feet__c =20;
            rstInsert.add( rstRecord6);     
            insert  rstInsert;
            
            test.startTest(); 
            
            CLQ_Room_Space_Transaction__c oldRstRecord = rstRecord.clone(true,true,true,true);
            CLQ_Room_Space_Transaction__c oldRstRecord1 = rstRecord6.clone(true,true,true,true);
            
            rstRecord.CLQ_Length_Feet__c = 4;
            rstRecord.CLQ_Width_Feet__c = 5;
            
            rstRecord6.CLQ_Length_Feet__c = 4;
            rstRecord6.CLQ_Width_Feet__c = 5;
            update rstRecord;
            update rstRecord6;
            System.runAs(usr) {
                list<CLQ_Room_Space_Transaction__c> oldList = new List<CLQ_Room_Space_Transaction__c>([Select Id, Name FROM CLQ_Room_Space_Transaction__c where Id =: oldRstRecord.Id]);
                list<CLQ_Room_Space_Transaction__c> newList = new List<CLQ_Room_Space_Transaction__c>([Select Id, Name FROM CLQ_Room_Space_Transaction__c where Id =: rstRecord.Id]);
                Map<id,CLQ_Room_Space_Transaction__c> oldMap = new Map<id,CLQ_Room_Space_Transaction__c>{oldRstRecord.id => oldRstRecord};         
                    Map<id,CLQ_Room_Space_Transaction__c> newMap = new Map<id,CLQ_Room_Space_Transaction__c>{rstRecord.id => rstRecord};
                        
                        CLQ_RoomSpaceTransactionTriggerHandler rst = new CLQ_RoomSpaceTransactionTriggerHandler(newList,newMap,oldList,oldMap,
                                                                                                                true,false,true,false,
                                                                                                                true,false,false,1);
                CLQ_Room_Space_Transaction__c rstUpdate = [Select Id,clq_formatted_change_table__c, Name,CLQ_Room_Space_Number__c from CLQ_Room_Space_Transaction__c where Id =: rstRecord.Id];
                rstUpdate.CLQ_Room_Space_Number__c = '4433';
                update rstUpdate;
                delete rstUpdate;
                //rst.buildFieldChangeHtmlTable(newList, oldMap);
                //rst.UpdateFormulaValuesPT(newMap, oldMap);
                test.stopTest();
            }
        }  
    }
    
}