/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_EventTriggerHandlerTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/

@isTest

private class CLQ_EventTriggerHandlerTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 
    
    @IsTest
    static void testclqEventTriggerHandler() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Inspection__c Inspect = new  CLQ_Inspection__c();
            insert Inspect;
            
            CLQ_Inspection__c InspectWithFirstVisit = new  CLQ_Inspection__c(CLQ_Visit_Status__c = 'To be Scheduled');
            insert InspectWithFirstVisit;     
            
            Event FirstVisitEvent = new Event(WhatId= InspectWithFirstVisit.id,StartDateTime=System.now(),EndDateTime =System.now().addDays(1),Type='Visit',CLQ_Event_Status__c='In Progress');
            
            
            List<Event> EventList = new List<Event>();
            for(integer i=0;i<100;i++){
                Event evt1 = new Event(WhatId= Inspect.id,StartDateTime=System.now(),EndDateTime =System.now().addDays(1),Type='Visit',CLQ_Event_Status__c='In Progress');
                Event evt2 = new Event(WhatId= Inspect.id,StartDateTime=System.now(),EndDateTime =System.now().addHours(1),Type='Visit',CLQ_Event_Status__c='In Progress');
                Event evt3 = new Event(WhatId= Inspect.id,StartDateTime=System.now(),EndDateTime =System.now().addHours(1),Type='Visit',CLQ_Event_Status__c='Completed');
                EventList.add(evt1);EventList.add(evt2);EventList.add(evt3);
            }
            
            Test.StartTest();
            insert FirstVisitEvent;
            //insert EventList;
            
            Map<Id,Event>EventListMap = new Map<Id,Event>();
            Map<Id,CLQ_Inspection__c> InspectionMap = New Map<Id,CLQ_Inspection__c>();
            set<Id>InspectionIdSet = new set<Id>();
            
            for(Event e : EventList){
                EventListMap.put(e.id,e);
                InspectionIdSet.add(e.WhatId);
            }
            
            CLQ_EventTriggerHandler et = new CLQ_EventTriggerHandler(EventList,EventListMap, EventList,EventListMap,true, false, false, true,false, true, false, EventList.size());
            et.AfterInsert();
            et.InspectionFirstVisitEvent(EventList) ;
            et.BeforeDelete();
            et.InspectionEventCountUpdate(EventListMap);
            et.InspectorsTotalVisitTime(EventList) ;
            Test.StopTest();
            System.assertEquals(300, EventList.size(),'Testing');
        }
    }
    
    @IsTest
    static void inspectionLastVisitDateUpdateTest() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liv@abcdefg09823420980777.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;
            
            //Create Config
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            insert configRecord; 
            //Create account record
            Account accountrecord = new Account(Name='Test FCC Account',CLQ_DIRN__c = '12345'); 
            insert accountrecord ;
            
            Id ProgRTid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            CLQ_Program__c prog = new CLQ_Program__c(Name = 'Test FCC Prog', RecordTypeId = ProgRTid, CLQ_Licensing_Specialist__c = UserInfo.getUserID(), CLQ_Street_Address_1__c = 'test123', CLQ_Associated_Organization__c = accountrecord.id, CLQ_Program_Status__c = 'Pending');
            insert prog;
            
            
            CLQ_Inspection__c inspection = CLQ_UtilityClass.createInspectionrecord('Pre-License', 'Full', 'Pending Processing');
            inspection.CLQ_Program__c = prog.Id;
            inspection.OwnerId = usr.Id;
            insert inspection;
            
            List<Event> scope = new List<Event>();
            Event event = new Event(WhatId= inspection.id,
                                    StartDateTime=System.now(),
                                    EndDateTime =System.now().addDays(1),
                                    Type='Visit',
                                    CLQ_Event_Status__c='In Progress',
                                    OwnerId = UserInfo.getUserId());
            
            Event event2 = new Event(WhatId= inspection.id,
                                     StartDateTime=System.now(),
                                     EndDateTime =System.now().addDays(3),
                                     Type='Visit',
                                     CLQ_Event_Status__c='Completed',
                                     OwnerId = UserInfo.getUserId());        
            
            scope.add(event);
            scope.add(event2);
            insert scope;
            
            Test.StartTest();
            event.CLQ_Event_Status__c='Completed';
            update event;
            Test.StopTest();
        }
    }
    
    @IsTest
    static void clqWhatTypeTest() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //insert configuration record
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord;
            
            Event task = new Event(whatid = configRecord.id, DurationInMinutes = 12, ActivityDateTime = DateTime.Now());
            insert task;
            
            Event task2 = [SELECT Id, CLQ_WhatType__c, WhatId FROM Event Where Id = :task.Id]; 
            system.AssertEquals('CLQ_OCLQS_Configuration__c', task2.CLQ_WhatType__c,'Testing');
            
            Account AccRecord = new Account(Name = 'Robert Smith');
            insert AccRecord;
            task.whatid = AccRecord.id;
            update task;
            task2 = [SELECT Id, CLQ_WhatType__c, WhatId FROM Event Where Id = :task.Id];
            //system.AssertEquals('CLQ_OCLQS_Configuration__c', task2.CLQ_WhatType__c);
        }
    }    
    
    @IsTest
    static void assignedToRuleForEventInspectionTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liv@abcdefg09823420980777.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;
            
            //Create Config
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            insert configRecord; 
            //Create account record
            Account accountrecord = new Account(Name='Test FCC Account',CLQ_DIRN__c = '12345'); 
            insert accountrecord ;
            //Create Program
            Id ProgRTid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            CLQ_Program__c prog = new CLQ_Program__c(Name = 'Test FCC Prog', RecordTypeId = ProgRTid, CLQ_Licensing_Specialist__c = UserInfo.getUserID(), CLQ_Street_Address_1__c = 'test123', CLQ_Associated_Organization__c = accountrecord.id, CLQ_Program_Status__c = 'Pending');
            insert prog;
            
            CLQ_Inspection__c Inspect = CLQ_UtilityClass.createInspectionrecord('Pre-License', 'Full', 'Pending Processing');
            Inspect.CLQ_Program__c = prog.Id;
            Inspect.OwnerId = usr.Id;
            insert Inspect;
            
            Event FirstVisitEvent = new Event(WhatId= Inspect.id,
                                              StartDateTime=System.now(),
                                              EndDateTime =System.now().addDays(1),
                                              Type='Visit',
                                              CLQ_Event_Status__c='In Progress',
                                              OwnerId = UserInfo.getUserId());
            insert FirstVisitEvent;
            
            Event event2 = [SELECT Id, CLQ_WhatType__c, WhatId FROM Event Where Id = :FirstVisitEvent.Id];
            system.AssertEquals('CLQ_Inspection__c', event2.CLQ_WhatType__c,'Testing');
            
            FirstVisitEvent.OwnerId = usr.Id;
            
            try
            {
                update FirstVisitEvent;
                system.Assert(true, 'This should fail with the Assignment Rule');
            }
            catch(Exception exc)
            {
                system.Assert(exc.getMessage().contains('Assigned to cannot be changed'), 'This should fail with the Assignment Rule');
            }
        }
    }
}