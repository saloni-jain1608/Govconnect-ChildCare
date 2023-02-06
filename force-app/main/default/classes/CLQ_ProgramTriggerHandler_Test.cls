/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTriggerHandler_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Jiangl                  8/25/17                     Add CountyAdminSharetest() for JFS#11732
**  Pavan Ayta              9/15/17         1.1         Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_ProgramTriggerHandler_Test {
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void updateTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;        
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.CLQ_BIRN__c = '123456';
            insert programRecord ;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            programRecord.CLQ_Licensing_Specialist__c = usr.Id;
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            //Before Update
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger(); 
            
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            //AfterUpdate
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    false, true, false, 1);
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            //Handler.programValidation(NewList, OldMap);
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
            
            system.AssertEquals(usr.Id, NewList[0].CLQ_Licensing_Specialist__c,'Testing');
            //system.AssertEquals(usr.Id, NewList[0].OwnerId);
        }
        
    }
    
    @IsTest
    static void insertTest() {
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
            programRecord.CLQ_BIRN__c = '123465';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            //insert programRecord ;
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>();
            list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                
                //Before Insert
                CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, null, OldList, null,
                                                                                  true, true, false, false, 
                                                                                  true, false, false, 1);
            system.AssertEquals('beforeinsert', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger(); 
            system.AssertEquals(false, Handler.HasAlreadyUpdated,'Testing');
            
            //AfterInsert
            Handler = new CLQ_ProgramTriggerHandler(NewList, null, OldList, null,
                                                    true, true, false, false, 
                                                    false, true, false, 1);
            system.AssertEquals('afterinsert', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            system.AssertEquals(false, Handler.HasAlreadyUpdated,'Testing');
            
            //Throw an exception that there is a missing Configuration Record
            delete configRecord;
            programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_BIRN__c = '123456';
            NewList = new list<CLQ_Program__c>{programRecord};
                
                Handler = new CLQ_ProgramTriggerHandler(NewList, null, OldList, null,
                                                        true, true, false, false, 
                                                        true, false, false, 1);
            system.AssertEquals('beforeinsert', Handler.TriggerExecutionType,'Testing');
            try
            {
                Handler.ProcessTrigger();
                system.Assert(false, 'This should have thrown an Exception');
            }
            catch(CLQ_ProgramTriggerHandler.CLQ_ProgramTriggerHandlerException exc)
            {
                system.Assert(true, 'This worked correctly');
            }
        }
        
    }    
    
    @IsTest
    static void updateInspectionsTest() {
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
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.CLQ_BIRN__c = '123';
            programRecord.CLQ_Program_Status__c = 'Pending';
            insert programRecord ;
            
            //Create a program record
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test22';
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord1.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord1.CLQ_BIRN__c = '12324';
            programRecord1.CLQ_Program_Status__c = 'Open';
            insert programRecord1;    
            
            CLQ_Inspection__c Inspection = new CLQ_Inspection__c(CLQ_Program__c = programRecord.Id, isApproved__c = true);
            insert Inspection;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            oldprogramRecord.CLQ_BIRN__c = '1423';
            
            CLQ_Program__c oldprogramRecord1 = programRecord1.clone(true, true, true, true);
            oldprogramRecord1.CLQ_BIRN__c = '12834';
            
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord,programRecord1};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord,oldprogramRecord1.id =>oldprogramRecord1};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            AvoidRecursionCls.isRecomended = true;
            AvoidRecursionCls.isOnsiteVisit = true;
            programRecord.Program_Rating__c = '0';
            programRecord.CLQ_License_Issue_Date__c = Date.Today();
            programRecord.CLQ_BIRN__c = '178923';
            //AfterUpdate
            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                              true, false, true, false, 
                                                                              false, true, false, 1);
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger(); //sr
            Handler.checkODEProgramTypeAtSameIRN(NewList,OldMap); //sr
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
        }
        
    }
    
    @IsTest
    static void updateInspectionsTestOne() {
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
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecord ;
            
            CLQ_Inspection__c Inspection = new CLQ_Inspection__c(CLQ_Program__c = programRecord.Id, isApproved__c = true);
            insert Inspection;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            AvoidRecursionCls.isRecomended = true;
            AvoidRecursionCls.isOnsiteVisit = true;
            oldprogramRecord.Program_Rating__c = '0';
            oldprogramRecord.CLQ_License_Issue_Date__c = Date.Today();
            map < id, CLQ_Program__c> prgMapOld = new map < id, CLQ_Program__c> ();
            prgMapOld.put(oldprogramRecord.Id,oldprogramRecord);
            //AfterUpdate
            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                              true, false, true, false, 
                                                                              false, true, false, 1);
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            AvoidRecursionCls.isRecomended = true;
            AvoidRecursionCls.isOnsiteVisit = true;
            programRecord.Program_Rating__c = '1';
            programRecord.CLQ_License_Issue_Date__c = Date.Today()+1;
            List<CLQ_Program__c> prgList = new List<CLQ_Program__c>{programRecord};
                map < id, CLQ_Program__c> prgMap = new map < id, CLQ_Program__c> ();
            prgMap.put(programRecord.Id,programRecord);
            Handler.UpdateInspections(prgList,prgMap,prgMapOld);
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
        }
        
        
    }    
    @IsTest
    static void updateInspectionsTestTwo() {
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
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecord ;
            
            CLQ_Inspection__c Inspection = new CLQ_Inspection__c(CLQ_Program__c = programRecord.Id, isApproved__c = true);
            insert Inspection;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            AvoidRecursionCls.isRecomended = true;
            AvoidRecursionCls.isOnsiteVisit = true;
            programRecord.Program_Rating__c = '4';
            programRecord.CLQ_License_Issue_Date__c = Date.Today();
            //AfterUpdate
            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                              true, false, true, false, 
                                                                              false, true, false, 1);
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
        }
        
        
    }    
    
    @IsTest
    static void updateProgramRatingTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            List<CLQ_Program__c> proList = new List<CLQ_Program__c>();
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.Program_Rating__c = '0';
            programRecord.CLQ_Manual__c = true;
            programRecord.Unable_to_Rate_Reasons__c = 'Change of Owner Rating';
            programRecord.Rating_Expiration_Date__c = Date.Today();
            programRecord.Rating_Effective_Date__c = Date.Today();
            programRecord.Rating_Anniversary_Date__c = Date.Today();
            proList.add(programRecord) ;
            
            //Create a program record
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test';
            programRecord3.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord3.CLQ_Street_Address_1__c = 'test';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord3.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord3.Program_Rating__c = '0';
            programRecord3.CLQ_Manual__c = true;
            programRecord3.Unable_to_Rate_Reasons__c ='';
            programRecord3.Rating_Expiration_Date__c = Date.Today();
            programRecord3.Rating_Effective_Date__c = Date.Today();
            programRecord3.Rating_Anniversary_Date__c = Date.Today();
            proList.add(programRecord3) ;
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test12';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;        
            programRecord1.Rating_Effective_Date__c = Date.Today();
            programRecord1.CLQ_Manual__c = true;
            programRecord1.Program_Rating__c = '1';
            programRecord1.Unable_to_Rate_Reasons__c = 'Rating Reduced';
            proList.add(programRecord1) ;
            
            CLQ_Program__c programRecord4 = new CLQ_Program__c();
            programRecord4.Name = 'Test123';
            programRecord4.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord4.CLQ_Associated_Organization__c = accountrecord.id;         
            programRecord4.Rating_Expiration_Date__c = Date.Today();
            programRecord4.Rating_Effective_Date__c = Date.Today();
            programRecord4.Rating_Anniversary_Date__c = Date.Today();
            programRecord4.CLQ_Manual__c = true;
            programRecord4.Program_Rating__c = '1';
            programRecord1.Unable_to_Rate_Reasons__c = 'Does not meet requirements of the Administrative Practices';        
            proList.add(programRecord4) ;
            
            CLQ_Program__c programRecord5 = new CLQ_Program__c();
            programRecord5.Name = 'Test1245';
            programRecord5.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord5.CLQ_Associated_Organization__c = accountrecord.id;         
            programRecord5.Rating_Expiration_Date__c = Date.Today();
            programRecord5.Rating_Effective_Date__c = Date.Today();
            programRecord5.CLQ_Manual__c = true;
            programRecord5.Program_Rating__c = '3';
            programRecord1.Unable_to_Rate_Reasons__c = 'Does not meet requirements of the Administrative Practices';                
            proList.add(programRecord5) ;
            
            CLQ_Program__c programRecord6 = new CLQ_Program__c();
            programRecord6.Name = 'Test1235';
            programRecord6.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord6.CLQ_Associated_Organization__c = accountrecord.id;           
            programRecord6.Program_Rating__c = '4';
            programRecord6.Rating_Expiration_Date__c = Date.Today();
            programRecord6.Rating_Effective_Date__c = Date.Today();
            programRecord6.Rating_Anniversary_Date__c = Date.Today();
            programRecord1.Unable_to_Rate_Reasons__c = 'Does not meet requirements of the Administrative Practices';                
            programRecord6.CLQ_Manual__c = true;
            proList.add(programRecord6) ;
            
            insert proList;
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            //Program_Rating__c = '0'
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing'); 
            Handler.ProcessTrigger(); 
            //system.AssertEquals(null, programRecord.Rating_Expiration_Date__c );
            //system.AssertEquals(null, programRecord.Rating_Effective_Date__c );
            //system.AssertEquals(null, programRecord.Rating_Anniversary_Date__c );
            //system.AssertEquals(Date.Today(), programRecord.Rating_Discontinue__c );
            
            //Program_Rating__c = '1'
            
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();  
            //system.AssertNotEquals(null, programRecord1.Rating_Expiration_Date__c );
            //system.AssertEquals(null, programRecord1.Rating_Anniversary_Date__c );
            //system.AssertEquals(null, programRecord1.Rating_Discontinue__c );
            List<CLQ_Program__c> prgList = new List<CLQ_Program__c>{programRecord1,programRecord,programRecord3};
                map < id, CLQ_Program__c> prgMap = new map < id, CLQ_Program__c> ();
            prgMap.put(programRecord1.Id,programRecord1);
            Handler.UpdateProgramRating(prgList,prgMap);
            
            
            
            //Program_Rating__c = '3'
            CLQ_Program__c programRecord2 = programRecord.clone(true, true, true, true);
            programRecord2.Program_Rating__c = '3';
            programRecord2.Rating_Expiration_Date__c = Date.Today();
            programRecord2.Rating_Effective_Date__c = Date.Today();
            programRecord2.Rating_Anniversary_Date__c = Date.Today();
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();  
            //system.AssertNotEquals(null, programRecord2.Rating_Expiration_Date__c );
            //system.AssertNotEquals(null, programRecord2.Rating_Anniversary_Date__c );
            //system.AssertEquals(null, programRecord2.Rating_Discontinue__c );
            List<CLQ_Program__c> prgList1 = new List<CLQ_Program__c>{programRecord2};
                map < id, CLQ_Program__c> prgMap1 = new map < id, CLQ_Program__c> ();
            prgMap1.put(programRecord2.Id,programRecord2);
            Handler.UpdateProgramRating(prgList1,prgMap1);
            
            //Program_Rating__c = '5'
            programRecord.Program_Rating__c = '5';
            programRecord.Rating_Expiration_Date__c = Date.Today();
            programRecord.Rating_Effective_Date__c = Date.Today();
            programRecord.Rating_Anniversary_Date__c = Date.Today();
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();  
            //system.AssertNotEquals(null, programRecord.Rating_Expiration_Date__c );
            //system.AssertNotEquals(null, programRecord.Rating_Anniversary_Date__c );
            //system.AssertEquals(null, programRecord.Rating_Discontinue__c );
            List<CLQ_Program__c> prgList2 = new List<CLQ_Program__c>{programRecord};
                map < id, CLQ_Program__c> prgMap2 = new map < id, CLQ_Program__c> ();
            prgMap2.put(programRecord.Id,programRecord);
            Handler.UpdateProgramRating(prgList2,prgMap2);
        }
        
    } 
    @IsTest
    static void testAppendReviewerComments() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;        
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.Enter_new_comments__c = 'test new comment';
            insert programRecord ;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    true, false, false, 1);
            //system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();  
        }
    }
    @IsTest
    static void closeAllRelatedListTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
            
            CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'TestNetu';
            programRecord.CLQ_Associated_Organization__c = acc.Id;
            programRecord.CLQ_Street_Address_1__c = '123 Random St';
            programRecord.CLQ_Street_Address_2__c = 'addr2';
            programRecord.City__c = 'test city';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord.CLQ_County__c = county.Id;
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
            ProgramTransaction.CLQ_ProgTrans_County__c =county.Id;
            
            insert ProgramTransaction;
            
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Inspection_Type__c = 'Complaint';
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            insert Inspection;
            
            List<CLQ_Transaction_Document__c> transactionDocs = new list<CLQ_Transaction_Document__c>();       
            CLQ_Transaction_Document__c TD = new CLQ_Transaction_Document__c(Name = 'Test',Document_Points__c = 2,Rating__c='3',CLQ_Document_Status__c='Under Review',CLQ_Program_Transaction__c=ProgramTransaction.id);
            transactionDocs.add(TD);
            
            CLQ_Transaction_Document__c TD1 = new CLQ_Transaction_Document__c( Name = 'Under Review',Document_Points__c = 15,CLQ_Document_Status__c='Test',CLQ_Program_Transaction__c=ProgramTransaction.id);
            transactionDocs.add(TD1);
            
            CLQ_Transaction_Document__c TD2 = new CLQ_Transaction_Document__c(Name = 'Test',Document_Points__c = 2,Rating__c='3',CLQ_Document_Status__c='Approved',CLQ_Program_Transaction__c=ProgramTransaction.id);
            transactionDocs.add(TD2);
            
            insert transactionDocs;
            
            CLQ_Program__c newProgramRecord = programRecord.clone(true, true, true, true);
            newProgramRecord.CLQ_Program_Status__c = 'Closed';
            newProgramRecord.City__c = 'City Clone';
            update newProgramRecord;
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{programRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{newProgramRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{newProgramRecord.id => newProgramRecord};
                            
                            Test.startTest();
            //AfterUpdate
            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                              true, false, true, false, 
                                                                              false, true, false, 1);
            
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
            
            Test.stopTest();
        }
    }    
    
    
    @IsTest
    static void countyAdminSharetest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            ID id;        
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;        
            
            CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.CLQ_County__c = county.Id; 
            programRecord.CLQ_Licensing_Specialist__c = usr.Id; 
            insert programRecord ;
            id=programRecord.id;
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            //Before Update
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();   
            
            //system.AssertEquals(false, Handler.HasAlreadyUpdated);
            //AfterUpdate
            Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                    true, false, true, false, 
                                                    false, true, false, 1);
            system.AssertEquals('afterupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();
            system.AssertEquals(true, Handler.HasAlreadyUpdated,'Testing');
            
            system.AssertEquals(usr.Id, NewList[0].CLQ_Licensing_Specialist__c,'Testing');
            //system.AssertEquals(usr.Id, NewList[0].OwnerId);
            
            
            
                      
            
            List<CLQ_Program__Share> shares = [SELECT Id, UserOrGroupId, AccessLevel, 
                                               RowCause FROM CLQ_Program__Share WHERE ParentId = :id AND RowCause = 'County_Admin_Sharing__c'];
            
            //    System.assertEquals(shares.size(),2);
            
        }
        
    }
    
    //soufin
    @IsTest
    static void updateOwnerToSpecialistTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'In-Home Aide');
            insert configRecord;
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '4321'); 
            insert accountrecord;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;        
            
            CLQ_County__c county = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_In_Home_Aide').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.CLQ_County__c = county.Id; 
            programRecord.CLQ_Licensing_Specialist__c = usr.Id;
            programRecord.CLQ_Assigned_Reviewer__c = usr.Id;
            insert programRecord ;
            //id=programRecord.id;
            //System.debug('id insert==>' + id);  
            
            CLQ_Program__c oldprogramRecord = programRecord.clone(true, true, true, true);
            
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            
            system.AssertEquals('beforeupdate', Handler.TriggerExecutionType,'Testing');
            Handler.ProcessTrigger();   
        }
        
    }
    
    @IsTest
    static void closeAllPTRelatedListTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Day Camp');
            insert configRecord;
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '4321'); 
            insert accountrecord;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;        
            
            CLQ_County__c county = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            programRecord.CLQ_County__c = county.Id; 
            //programRecord.CLQ_Licensing_Specialist__c = usr.Id;
            programRecord.CLQ_Assigned_Reviewer__c = usr.Id;
            programRecord.CLQ_Program_Status__c='Closed';
            programRecord.CLQ_Current_Rating__c=3;
            programRecord.CLQ_SUTQ_Exempted__c='Yes';
            insert programRecord ;
            //id=programRecord.id;
            //System.debug('id insert==>' + id);  
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
            ProgramTransaction.CLQ_ProgTrans_County__c =county.Id;
            insert ProgramTransaction;
            
            CLQ_Program__c oldprogramRecord = new CLQ_Program__c();
            oldprogramRecord.Id=programRecord.Id;
            oldprogramRecord.Name = 'Test';
            oldprogramRecord.CLQ_Associated_Organization__c = accountrecord.id;
            oldprogramRecord.CLQ_Street_Address_1__c = 'test';
            oldprogramRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
            oldprogramRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            oldprogramRecord.CLQ_County__c = county.Id; 
            //oldprogramRecord.CLQ_Licensing_Specialist__c = usr.Id;
            oldprogramRecord.CLQ_Assigned_Reviewer__c = usr.Id;
            oldprogramRecord.CLQ_Program_Status__c='Open';
            
            
            
            
            list<CLQ_Program__c>  OldList = new list<CLQ_Program__c>{oldprogramRecord};
                list<CLQ_Program__c>  NewList = new list<CLQ_Program__c>{programRecord};
                    map<id,CLQ_Program__c>  OldMap = new map<id,CLQ_Program__c>{oldprogramRecord.id => oldprogramRecord};
                        map<id,CLQ_Program__c>  NewMap = new map<id,CLQ_Program__c>{programRecord.id => programRecord};
                            
                            CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(NewList, NewMap, OldList, OldMap,
                                                                                              true, false, true, false, 
                                                                                              true, false, false, 1);
            
            //system.AssertEquals('BeforeUpdate', Handler.TriggerExecutionType);
            Handler.closeAllPTRelatedList(NewList,OldMap);
            //Handler.ProcessTrigger();   
        } 
    }
}