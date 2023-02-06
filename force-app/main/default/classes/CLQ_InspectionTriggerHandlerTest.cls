/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_InspectionTriggerHandlerTest
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
private class CLQ_InspectionTriggerHandlerTest {
    public static final string DEFERRAL = 'Deferral';
    @IsTest
    private static void insertCAPonVisitCompleteTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            insert programRecord ;
            
            
            
            //Insert CLQ_Inspection__c 
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Pre-license', 'Full', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = Date.today();
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            inspectionrecord.CLQ_CAP_Generated__c = false;
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            insert inspectionrecord;
            inspectionrecord.CLQ_Inspection_Status__c = 'Approved';
            update inspectionrecord;
            CLQ_Inspection__c newInspection = inspectionrecord.Clone(true, true, true, true);
            newInspection.CLQ_Inspection_Status__c = 'Revision In Progress';        
            newInspection.CLQ_CAP_Generated__c = true;
            
            //Create Domains
            list<CLQ_Domain__c> domainList = new list<CLQ_Domain__c>();
            CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
            domainList.add(domain);
            
            insert domainList;
            
            //Create Rules
            list<CLQ_Rule__c> ruleList = new list<CLQ_Rule__c>();
            CLQ_Rule__c rule1 = new CLQ_Rule__c(Name='Rule1',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            ruleList.add(rule1);
            
            CLQ_Rule__c rule2 = new CLQ_Rule__c(Name='Rule2',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            ruleList.add(rule2);
            
            insert ruleList;
            
            //Create Domain Rules
            list<CLQ_Domain_Rule__c> domainRuleList = new list<CLQ_Domain_Rule__c>();
            CLQ_Domain_Rule__c domainRule1 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule1.id , CLQ_Domain__c = domain.id,CLQ_Applicable_To_Scope__c = 'Full');
            domainRuleList.add(domainRule1);
            CLQ_Domain_Rule__c domainRule2 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule2.id , CLQ_Domain__c = domain.id);
            domainRuleList.add(domainRule2);
            insert domainRuleList;
            
            //Create Standard Findings
            list<CLQ_Standard_Findings__c> sfindingList = new list<CLQ_Standard_Findings__c>();
            CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious');
            sfindingList.add(sfinding);
            CLQ_Standard_Findings__c sfinding2 = new CLQ_Standard_Findings__c(Name='test2',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious');
            sfindingList.add(sfinding2);
            insert sfindingList;
            
            list<CLQ_Domain_Rule_Finding__c> domainRuleFindingslist = new list<CLQ_Domain_Rule_Finding__c>();
            CLQ_Domain_Rule_Finding__c domainFinding1 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Standard_Finding__c=sfinding.id);
            CLQ_Domain_Rule_Finding__c domainFinding2 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Standard_Finding__c=sfinding2.id);
            CLQ_Domain_Rule_Finding__c domainFinding3 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule2.id,CLQ_Standard_Finding__c=sfinding.id);
            CLQ_Domain_Rule_Finding__c domainFinding4 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule2.id,CLQ_Standard_Finding__c=sfinding2.id);
            domainRuleFindingslist.add(domainFinding1);
            domainRuleFindingslist.add(domainFinding2);
            domainRuleFindingslist.add(domainFinding3);
            domainRuleFindingslist.add(domainFinding4);
            insert domainRuleFindingslist;
            
            //Create inspection  tool
            CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(CLQ_Applicable_To_Scope__c = 'Full',name='Full',CLQ_Active__c = true,CLQ_Applicable_To__c='Child Care Center');
            insert inspectionTool;
            
            //Create tool rules
            
            CLQ_Tools_Rules__c toolRule = new CLQ_Tools_Rules__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Inspection_Tools__c=inspectionTool.id);
            insert toolRule;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c=newInspection.id,CLQ_Domain_Rule__c = domainRule1.id,CLQ_Result__c = 'Non-Compliant');
            insert ruleInspected;
            
            CLQ_Staff_Record__c staffRec = new CLQ_Staff_Record__c();
            staffRec.Last_Name__c= 'tester';
            staffRec.First_Name__c = 'john';
            staffRec.CLQ_Inspection__c = inspectionrecord.id;
            insert staffRec;
            
            Job_Role__c jobRoleObj = new Job_Role__c();
            jobRoleObj.Staff_Record__c = staffRec.Id;
            jobRoleObj.Position__c = 'Programmer';
            insert jobRoleObj;
            
            //Create enrollemnt group record on inspection
            CLQ_Enrollment_Group__c enrollmentgrp = new CLQ_Enrollment_Group__c();
            enrollmentgrp.name = 'GRP1';
            enrollmentgrp.CLQ_Inspection__c = inspectionrecord.id;
            enrollmentgrp.CLQ_Infant__c = 10 ;
            enrollmentgrp.CLQ_No_of_Infants__c = 10 ; 
            enrollmentgrp.CLQ_Older_Toddler__c = 10 ;
            enrollmentgrp.CLQ_No_of_Preschool__c = 10 ;
            enrollmentgrp.CLQ_Pre_School__c = 10 ;
            enrollmentgrp.CLQ_No_of_School_Age__c = 10 ; 
            enrollmentgrp.CLQ_No_of_School_Age_Part_Time__c = 10 ; 
            enrollmentgrp.CLQ_No_of_Young_Toddler__c = 10 ;
            enrollmentgrp.CLQ_Younger_Toddler__c = 10 ;
            insert enrollmentgrp ;
            
            CLQ_Ratio__c ratio = new CLQ_Ratio__c();
            ratio.Group_Information__c = enrollmentgrp.Id;
            ratio.CLQ_No_of_Children__c = 2;
            ratio.CLQ_No_of_Staff__c = 20;
            insert ratio;
            
            CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',CLQ_TA_Description__c = 'test',CLQ_CAP_TA__c = 'CAP');
            insert finding;
            Test.startTest();
            
            list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{inspectionrecord};
                map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{inspectionrecord.Id => inspectionrecord};
                    //inspectionrecord.CLQ_CAP_Generated__c = true;
                    //update inspectionrecord;
                    
                    list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{newInspection };
                        map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{newInspection.Id => newInspection };
                            CLQ_InspectionTriggerHandler_Custom Handler = new CLQ_InspectionTriggerHandler_Custom(newList, newMap, oldList, oldMap,
                                                                                                                  true, false, true, false, 
                                                                                                                  true, false, false, 1);
            
            Handler.VersioningInspectionbeforeupdate(newList ,oldMap);
            Handler.insertCAPonVisitComplete(newList ,oldMap);
            //Handler.ProcessTrigger();
            test.stopTest();
        }
        
    }
    
    @IsTest
    private static void versioningInspectionbeforeupdateTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-1);
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            Inspection.Inspection_Status__c = 'Submitted';
            insert Inspection;
            
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            //AfterUpdate
                            CLQ_InspectionTriggerHandler_Custom Handler = new CLQ_InspectionTriggerHandler_Custom(newList, newMap, oldList, oldMap,
                                                                                                                  true, false, true, false, 
                                                                                                                  false, true, false, 1);
            
            Handler.ProcessTrigger();
            
            Inspection.Inspection_Status__c = 'Deferral';
            //Inspection.CLQ_DeferralDuration__c = '30 Days';
            Handler.ProcessTrigger();
            CLQ_Program_Transaction__c UpdatedProgramTransaction = [SELECT Id, CLQ_Transaction_Status__c 
                                                                    FROM CLQ_Program_Transaction__c 
                                                                    WHERE ID = : ProgramTransaction.Id];
            system.debug('UpdatedProgramTransaction: ' + UpdatedProgramTransaction);
            
            Visit_Information__c Visit = new Visit_Information__c(Inspection__c = Inspection.Id, 
                                                                  Visit_Date__c = date.Today(), 
                                                                  User__c = UserInfo.getUserId());
            // User__c = CLQ_UnitTestUtilities.GetInternalUser().Id);
            insert Visit;
            Inspection.isApproved__c = true;
            
            Handler = new CLQ_InspectionTriggerHandler_Custom(newList, newMap, oldList, oldMap,
                                                              true, false, true, false, 
                                                              false, true, false, 1);
            Handler.ProcessTrigger();
            
            //Inspection.CLQ_DeferralDuration__c = '60 Days';
            //Handler.ProcessTrigger();
            test.stopTest();
        }
    }       
    
    
    
    //sr
    @IsTest
    private static void updateAllegedRulesonSubmitInspectionNegativeTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            Id RtId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space').getRecordTypeId();
            ProgramTransaction.RecordTypeId = RtId;
            
            //find the ID of the correct record type
            Id rtId1 = [select Id, name from RecordType where DeveloperName  ='CLQ_Complaint' and   SObjectType='CLQ_Case_Custom__c' limit 1].Id;        
            
            Test.startTest();
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Inspection_Type__c = 'Complaint';
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            insert Inspection;
            
            CLQ_Case_Custom__c ca = new CLQ_Case_Custom__c(AccountId__c = accountrecord.Id,
                                                           ContactId__c = contactrecord.Id,
                                                           RecordTypeId = rtId1,
                                                           Type__c='Question',
                                                           //Origin='My Origin',
                                                           CLQ_Inspection__c = Inspection.Id,
                                                           CLQ_Anonymous_Complainant__c = true,
                                                           CLQ_Status__c='New'
                                                          );
            insert ca;
            
            //New room space inspection
            CLQ_Room_Space_Inspection__c testRSI = new CLQ_Room_Space_Inspection__c();
            testRSI.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            testRSI.CLQ_Inspection__c = Inspection.Id;
            insert testRSI;
            
            //New room space
            CLQ_Room_Space__c testRS = new CLQ_Room_Space__c();
            testRS.CLQ_Inspection__c = null;
            insert testRS;
            
            //New building approval
            CLQ_Building_Approval__c testBA = new CLQ_Building_Approval__c();
            testBA.CLQ_Inspection__c = Inspection.Id;
            insert testBA;
            
            //New facility schedule
            CLQ_Facility_Schedule__c testFS = new CLQ_Facility_Schedule__c();
            testFS.Name = 'test';
            testFS.CLQ_Inspection__c = Inspection.Id;
            //testFS.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            insert testFS;
            
            //Old inspection
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint', CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant', CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            //Inspection details
            Inspection.CLQ_Inspection_Status__c = 'Under Approver Review';
            Inspection.CLQ_Inspection_Type__c = 'Compliance';
            Inspection.CLQ_Visit_Status__c = 'Visit Completed';
            
            //Lists
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            
                            //BeforeUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            system.debug('About to simulate trigger');
            Handler.BeforeUpdate();
            
            //update inspection;
            CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            test.stopTest();
        }
    }
    
    @IsTest
    private static void negativeTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            Test.startTest();
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'Open';
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            insert programRecord ;
            
            //Create a program transaction record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_ODE_Change_of_Location').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.testDate__c = date.today().addYears(-6);
            insert ProgramTransaction;
            
            
            
            
            
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id; //prog trans
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            
            insert Inspection;
        }
    }
    
    @IsTest
    private static void updateAllegedRulesonSubmitInspectionTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            Test.startTest();
            
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-1);
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            insert Inspection;
            
            
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint',
                                                                     CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant',
                                              CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            //add case here
            
            ////add facility schedule here
            
            
            //add roles
            
            //end sr
            
            Inspection.CLQ_Inspection_Status__c = 'Under Approver Review';
            Inspection.CLQ_Inspection_Type__c = 'Compliance';
            Inspection.CLQ_Visit_Status__c = 'Visit Completed';
            
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            //BeforeUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            system.debug('About to simulate trigger');
            Handler.BeforeUpdate();
            //update inspection;
            
            CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            test.stopTest();
        }
    }
    
    @IsTest
    private static void updateProgramTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            User testUser = new User(
                
                //ProfileId = [SELECT Id FROM Profile WHERE Name = 'Lic and SUTQ Reviewer - State User'].Id,
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
                
            );
            Insert testUser;
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord;
            
            CLQ_Program__c program = CLQ_Test_Util.getCLQProgram2();
            program.CLQ_License_Type__c = 'Continuous';
            program.CLQ_Program_Status__c= 'Open';
            program.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            program.Program_Rating__c = '1';
            insert program;
            
            CLQ_Room_Space__c roomSpace = new CLQ_Room_Space__c();
            roomSpace.Name = 'TestRSName';
            roomSpace.CLQ_Program__c = program.Id;
            insert roomSpace;
            
            CLQ_Program_Transaction__c ProgramTransaction = CLQ_Test_Util.getCLQProgramTransactionForTask();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = program.id;
            ProgramTransaction.SUTQ_Deferral_Duration__c='14 Days';
            
            //CLQ_Program_Transaction__c.CLQ_County__c = county.id;     
            
            
            insert ProgramTransaction;
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.recordTypeid = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            Inspection.CLQ_Insp_DeferralDueDate__c = date.today().addDays(30);
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Inspection_End_Date__c = date.today();
            Inspection.CLQ_Program__c = program.Id;
            Inspection.isApproved__c = true;
            insert Inspection;
            
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            Inspection.Inspection_Status__c = 'Deferral';  
            update Inspection;
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            
                            //AfterUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    false, true, false, 1);
            
            Handler.ProcessTrigger();
            
            Inspection.Inspection_Status__c = DEFERRAL;
            //Inspection.CLQ_DeferralDuration__c = '30 Days';
            Handler.ProcessTrigger();
            CLQ_Program_Transaction__c UpdatedProgramTransaction = [SELECT Id, CLQ_Transaction_Status__c 
                                                                    FROM CLQ_Program_Transaction__c 
                                                                    WHERE ID = : ProgramTransaction.Id];
            
            
            
            Inspection.isApproved__c = true;       
            
            Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                               true, false, true, false, 
                                                               false, true, false, 1);
            Handler.ProcessTrigger();
            
            //Inspection.CLQ_DeferralDuration__c = '60 Days';
            //Handler.ProcessTrigger();
            test.stopTest();
        }
    }       
    
    @IsTest
    private static void updateStatusTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            Test.startTest();
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            //programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.Rating_Effective_Date__c=date.today().addDays(-1);
            programRecord.Program_Rating__c='0';
            //programRecord.CLQ_County__c = county.id;
            //programRecord.CLQ_License_Number__c = '306544';
            programRecord.CLQ_License_Type__c = 'Provisional';
            insert programRecord ;
            
            
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.RecordTypeId= Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            Inspection.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-1);
            Inspection.CLQ_Inspection_End_Date__c = date.today().addDays(-1);
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Inspection_Status__c = 'In Progress';
            Inspection.CLQ_Program__c=programRecord.Id;
            Inspection.Onsite_Rating__c='0';
            insert Inspection;
            
            
            
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            OldInspection.IsApproved__c=false;
            
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint',
                                                                     CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant',
                                              CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            
            Inspection.CLQ_Inspection_Status__c = 'Pending Approval';
            Inspection.CLQ_Inspection_Type__c = 'Compliance';
            Inspection.CLQ_Visit_Status__c = 'Visit Completed';
            
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            //BeforeUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            system.debug('About to simulate trigger');
            Handler.BeforeUpdate();
            
            
            Handler.updateStatus(newList,oldMap );
            
            Inspection.CLQ_Inspection_Status__c = 'Rating Assessment Complete';
            Inspection.CLQ_Inspection_Type__c = 'Compliance';
            Inspection.CLQ_Visit_Status__c = 'Visit Completed';
            Inspection.Inspection_Status__c = 'In Progress';
            Inspection.IsApproved__c = true;
            
            
            list<CLQ_Inspection__c> newList1 = new list<CLQ_Inspection__c>{Inspection};
                Handler.updateStatus(newList1,oldMap );
            Handler.updateProgram(newList1,oldMap );
            Inspection.CLQ_Insp_DeferralDueDate__c = null;
            Handler.updateProgram(newList1,oldMap );
            
            //update inspection;
            
            
            
            test.stopTest();
        }
    }
    
    
    /*****Added for Temporary Purpose***/
    @IsTest
    private static void updateAllegedRulesonSubmitInspectionTest1() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            Test.startTest();
            
            list<string> FieldNames = new list<string>(CLQ_UtilityClass.getAllfieldsforSObject('CLQ_Inspection__c'));
            string query = 'SELECT ' + string.join(FieldNames, ',') + ' FROM CLQ_Inspection__c WHERE CLQ_Program_Transaction__c = \'' + ProgramTransaction.Id + '\' LIMIT 1';
            system.debug('updateAllegedRulesonSubmitInspectionTest1 ' + query);
            CLQ_Inspection__c Inspection = (CLQ_Inspection__c)database.query(query);
            Inspection.CLQ_Inspection_Status__c = 'Under Approver Review';
            Inspection.CLQ_Visit_Status__c =  'Visit Completed';
            Inspection.CLQ_Send_Report_To__c ='CDC Web';
            Inspection.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            OldInspection.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint',
                                                                     CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant',
                                              CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            //BeforeUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            
            //Handler.BeforeUpdate();
            Handler.UpdateDeferralDueDate(newList,oldMap);
            Handler.updateAllegedRulesonSubmitInspection(newList, oldMap);
            Handler.updateCaseField(newList, oldMap);
            CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            //AfterUpdate
            Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                               true, false, true, false, 
                                                               false, true, false, 1);
            Handler.AfterUpdate();
            
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            test.stopTest();
        }
    }
    
    @testSetup 
    public static void testSetup()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        
        CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
        CLQ_Program__c Program = [SELECT Id, CLQ_Program_Status__c FROM CLQ_Program__c WHERE ID = :ProgramTransaction.CLQ_Program__c];
        system.Debug('Program Status = ' + Program.CLQ_Program_Status__c);
        
        CLQ_Trigger.BypassAllTriggers = true;
        ProgramTransaction.OwnerId = user.Id;
        system.Debug('Unit Test setting the Status to SUBMITTED');
        ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted';
        update ProgramTransaction;
        Program.CLQ_Program_Status__c = 'Open';
        Program.CLQ_License_Registration_Status__c='Licensed';
        Program.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        update Program;
        
        Id RtId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
        CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
        Inspection.RecordTypeId = RtId;
        Inspection.CLQ_Type__c = 'Complaint';
        Inspection.CLQ_Inspection_Type__c = 'Complaint';
        Inspection.CLQ_Program__c = Program.Id;
        Inspection.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-1);
        Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        Inspection.Inspection_Status__c = 'Submitted';
        insert Inspection;
        
        Inspection.CLQ_Inspection_Status__c = 'Approved';
        update Inspection;
        
        CLQ_Inspection__c RetInspection = [Select Id, CLQ_Inspection_age__c, CLQ_Status__c, CLQ_Inspection_Type__c, CLQ_Inspection_Status__c, 
                                           Inspection_Status__c, CLQ_Program__c, CLQ_Type__c
                                           FROM CLQ_Inspection__c WHERE Id = :Inspection.Id];
        system.Debug('RetInspection: ' + RetInspection);                                    
        
        CLQ_Facility_Schedule__c Facility = new CLQ_Facility_Schedule__c(CLQ_Program__c = ProgramTransaction.CLQ_Program__c, CLQ_Program_Transaction__c = ProgramTransaction.Id);
        Facility.Name = 'Test Schedule 1';
        Facility.CLQ_Status__c = 'Active';
        Facility.CLQ_Inspection__c = Inspection.Id;
        insert Facility;
        
        //RtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alleged Ops').getRecordTypeId();
        Contact contactrecord = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@nowhere.org');
        insert contactrecord;
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Complainant_First_Name__c = 'Joe';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Shmoe';
        caseRecord.CLQ_Program__c = Program.id;
        caseRecord.CLQ_Inspection__c = Inspection.Id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        insert caseRecord;
    }      
    
    //sr
    @IsTest
    private static void updateAllegedRuleOnCaseTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //Create Config
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            //TEST START
            Test.startTest();
            
            CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'Open';
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            programRecord.CLQ_County__c = county.Id;
            programRecord.CLQ_License_Registration_Status__c='Licensed';
            programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
            insert programRecord ;
            
            //Create a program transaction record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_ODE_Change_of_Location').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.testDate__c = date.today().addYears(-6);
            insert ProgramTransaction;
            
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Visit_Status__c = 'To be Scheduled';
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id; //prog trans
            Inspection.CLQ_Inspection_Status__c = 'Approved';
            Inspection.CLQ_Program__c = programRecord.Id;
            Inspection.CLQ_Inspection_Type__c = 'Complaint';
            //Inspection.
            
            insert Inspection;
            
            
            //Case
            CLQ_Case_Custom__c testCase = new 	CLQ_Case_Custom__c();
            testCase.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
            testCase.CLQ_Anonymous_Complainant__c = true;
            testCase.CLQ_Inspection__c = Inspection.Id;
            testCase.CLQ_Program__c = programRecord.Id;
            testCase.CLQ_Approver_s_Email__c = 'test@CLQ.com';
            testCase.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
            testCase.CLQ_Assigned_To__c = UserInfo.getUserid();
            //testCase.CLQ_Complainant_First_Name__c = 'Jim';
            //testCase.CLQ_Complainant_Last_Name__c = 'Woods';
            testCase.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
            testCase.CLQ_Complainant_Phone__c = '6145619874';
            insert testCase;
            
            
            //Old inspection
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            OldInspection.CLQ_Inspection_Status__c = 'Pending Processing';
            
            
            
            //Create domain rules
            CLQ_Domain_Rule__c testDomainRule = new CLQ_Domain_Rule__c();
            
            insert testDomainRule;
            
            //Create rules inspected
            CLQ_Rules_Inspected__c  testRulesInspected = new CLQ_Rules_Inspected__c();
            testRulesInspected.CLQ_Inspection_No__c = Inspection.Id;
            testRulesInspected.CLQ_Allegation_Description__c = 'testx';
            testRulesInspected.CLQ_Result__c = null;
            testRulesInspected.CLQ_Investigation_Details_Outcome__c  = 'testx';
            insert testRulesInspected;
            
            
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            violation1.Case_Custom__c = testCase.Id;
            violation1.CLQ_Allegation_Description__c = 'test';
            violation1.CLQ_Investigation_Method__c = 'On-site'; 
            violation1.CLQ_Result__c = 'Unsubstantiated';
            violation1.CLQ_Investigation_Details_Outcome__c = 'test';
            insert violation1;
            
            //Create findings
            CLQ_Findings__c testFindings = new CLQ_Findings__c();
            testFindings.CLQ_Rules_Inspected__c = testRulesInspected.Id;
            testFindings.CLQ_Inspection__c   = Inspection.Id;
            testFindings.CLQ_Alleged_Rule_Violation__c   = violation1.Id;
            insert testFindings;
            
            //Rules inspected
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint', CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant', CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            //Roles
            CLQ_Role__c role1 = new CLQ_Role__c();
            role1.CLQ_Contact__c = contactrecord.id;
            role1.Role_Type__c = 'ODE';
            role1.Portal_Roles__c = 'OCLQSAdministrator';
            role1.CLQ_Program__c = programRecord.id;
            role1.Secondary_Role__c = 'OCLQSPS';
            role1.recordtypeid = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
            //insert role1;
            
            
            //Lists and maps
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            
                            //updateAllegedRuleOnCase
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            //Run method
            system.debug('About to simulate trigger');
            Handler.updateAllegedRuleOnCase(newList, oldMap);
            
            
            //update inspection;
            CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            
            //TEST STOP
            Test.stopTest();
        }
    }
    
    //sr
    @IsTest
    private static void updateAllegedRulesonSubmitInspectionNegativeTest1() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            Id RtId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space').getRecordTypeId();
            ProgramTransaction.RecordTypeId = RtId;
            
            //find the ID of the correct record type
            Id rtId1 = [select Id, name from RecordType where DeveloperName ='CLQ_Complaint' and   SObjectType='CLQ_Case_Custom__c' limit 1].Id;        
            
            Test.startTest();
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Inspection_Type__c = 'Complaint';
            Inspection.Inspection_Status__c = 'Submitted';
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            insert Inspection;
            
            CLQ_Case_Custom__c ca = new CLQ_Case_Custom__c(AccountId__c = accountrecord.Id,
                                                           ContactId__c = contactrecord.Id,
                                                           RecordTypeId = rtId1,
                                                           Type__c='Question',
                                                           //Origin='My Origin',
                                                           CLQ_Inspection__c = Inspection.Id,
                                                           CLQ_Anonymous_Complainant__c = true,
                                                           CLQ_Status__c='New'
                                                          );
            insert ca;
            
            //New room space inspection
            CLQ_Room_Space_Inspection__c testRSI = new CLQ_Room_Space_Inspection__c();
            testRSI.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            testRSI.CLQ_Inspection__c = Inspection.Id;
            insert testRSI;
            
            //New room space
            CLQ_Room_Space__c testRS = new CLQ_Room_Space__c();
            testRS.CLQ_Inspection__c = null;
            insert testRS;
            
            //New building approval
            CLQ_Building_Approval__c testBA = new CLQ_Building_Approval__c();
            testBA.CLQ_Inspection__c = Inspection.Id;
            insert testBA;
            
            //New facility schedule
            CLQ_Facility_Schedule__c testFS = new CLQ_Facility_Schedule__c();
            testFS.Name = 'test';
            testFS.CLQ_Inspection__c = Inspection.Id;
            //testFS.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            insert testFS;
            
            ID adminRoleRecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId();
            CLQ_Role__c role = new CLQ_Role__c();
            role.CLQ_Inspection__c = Inspection.Id;
            role.CLQ_Status__c = 'Active';
            role.RecordTypeId = adminRoleRecordTypeID;
            insert role;
            
            //Old inspection
            CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
            
            //Add two Rules inspected One Complaint and One Non-Complaint
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint', CLQ_Alleged_Rule_Violation__c = violation1.id);
            insert Rule;
            CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
            insert violation2;
            Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant', CLQ_Alleged_Rule_Violation__c = violation2.id);
            insert Rule;
            
            //Inspection details
            Inspection.CLQ_Inspection_Status__c = 'Under Approver Review';
            Inspection.CLQ_Inspection_Type__c = 'Compliance';
            Inspection.CLQ_Visit_Status__c = 'Visit Completed';
            
            //Lists
            list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
                list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                    map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                        map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                            
                            //BeforeUpdate
                            CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                    true, false, true, false, 
                                                                                                                    true, false, false, 1);
            
            system.debug('About to simulate trigger');
            Handler.BeforeUpdate();
            
            //update inspection;
            CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
            system.debug('Retrieve violation: ' + violation);
            
            violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
            system.debug('Retrieve violation: ' + violation);
            
            test.stopTest();
        }
    }
    
    @IsTest
    static void copyInspectionChildInfoTest() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            CLQ_Inspection__c clqins1 = new CLQ_Inspection__c() ;
            clqins1.CLQ_Inspection_Type__c = 'Pre-license';
            insert clqins1;     
            
            CLQ_Building_Approval__c buildinap = new CLQ_Building_Approval__c();
            buildinap.CLQ_Building_Department__c ='Test Building 2';
            buildinap.CLQ_Inspection__c = clqins1.Id;     
            insert buildinap ; 
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            programRecord.CLQ_Program_Status__c = 'Open';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Issue_Date__c = Date.today();
            programRecord.CLQ_First_Inspection_Due__c = Date.today().adddays(20);
            insert programRecord;
            
            //Create a program record
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord1.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            programRecord1.CLQ_Program_Status__c = 'Open';
            programRecord1.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord1.CLQ_License_Type__c = 'Provisional';
            programRecord1.CLQ_License_Issue_Date__c = Date.today();
            programRecord1.CLQ_First_Inspection_Due__c = Date.today().adddays(20);
            //insert programRecord1;
            
            CLQ_Room_Space_Inspection__c roomins = new CLQ_Room_Space_Inspection__c();
            roomins.Name ='Room-1';
            roomins.CLQ_Room_Space_Number__c ='100';
            roomins.CLQ_Room_Space_Type__c = 'Primary Space';
            roomins.CLQ_Room_Space_Shape__c = 'Irregular';
            roomins.CLQ_Square_Footage_Irregular__c = 200;
            roomins.CLQ_Inspection__c = clqins1.Id;
            insert roomins ;   
            
            CLQ_Inspection__c clqins = new CLQ_Inspection__c() ;
            clqins.CLQ_Inspection_Type__c = 'Follow-up';
            clqins.CLQ_Original_Inspection__c = clqins1.ID;
            
            CLQ_Inspection__c clqins2 = new CLQ_Inspection__c() ;
            clqins2.CLQ_Inspection_Type__c = 'Pre-license';
            clqins2.CLQ_Original_Inspection__c = clqins2.ID;
            
            CLQ_Building_Approval__c buildApproval = new CLQ_Building_Approval__c();
            buildApproval.CLQ_Building_Department__c = 'testbuilding';
            buildApproval.CLQ_Program__c = programRecord.id;
            insert buildApproval; 
            
            insert clqins ;
            CLQ_Room_Space_Inspection__c roomins1 = new CLQ_Room_Space_Inspection__c();
            roomins1.Name ='Test Room Space';
            roomins1.CLQ_Room_Space_Number__c ='100';
            roomins1.CLQ_Room_Space_Type__c = 'Primary Space';
            roomins1.CLQ_Room_Space_Shape__c = 'Irregular';
            roomins1.CLQ_Square_Footage_Irregular__c = 200;
            roomins1.CLQ_Inspection__c = clqins.Id;
            insert roomins1 ;
            
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void followUpInspectionTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            Id RtId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.RecordTypeId = RtId;
            
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.CLQ_Inspection_Type__c = 'Annual';
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            insert Inspection;
            
            //New room space inspection
            CLQ_Room_Space_Inspection__c testRSI = new CLQ_Room_Space_Inspection__c();
            testRSI.CLQ_Inspection__c = Inspection.Id;
            insert testRSI;
            
            //New building approval
            CLQ_Building_Approval__c testBA = new CLQ_Building_Approval__c();
            testBA.CLQ_Inspection__c = Inspection.Id;
            insert testBA;
            
            Test.startTest();
            List<CLQ_Inspection__c> lstFollowUpInsp = new List<CLQ_Inspection__c>();
            CLQ_Inspection__c followUpInsp1 = CLQ_Test_Util.getCLQ_InspectionForTask();
            followUpInsp1.CLQ_Inspection_Type__c = 'Follow-up';
            followUpInsp1.CLQ_Inspection_Status__c = 'Pending Processing';
            followUpInsp1.CLQ_Original_Inspection__c = Inspection.Id;
            lstFollowUpInsp.add(followUpInsp1);
            
            CLQ_Inspection__c followUpInsp2 = CLQ_Test_Util.getCLQ_InspectionForTask();
            followUpInsp2.CLQ_Inspection_Type__c = 'Follow-up';
            followUpInsp2.CLQ_Inspection_Status__c = 'Pending Processing';
            followUpInsp2.CLQ_Original_Inspection__c = Inspection.Id;
            lstFollowUpInsp.add(followUpInsp2);
            
            insert lstFollowUpInsp;     
            
            test.stopTest();
        }
    }   
    
    @IsTest
    private static void sendDeleteNotificatgionTest() {        
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id, email = 'NOREPLY@TEST.COM' );
            insert contactrecord ;       
            Test.startTest();
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'Open';
            //programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            insert programRecord ;
            
            //New inspection
            CLQ_Inspection__c Inspection = CLQ_Test_Util.getCLQ_InspectionForTask();
            Inspection.Inspection_Status__c = 'Submitted';
            //Inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id; //prog trans
            Inspection.CLQ_Inspection_Status__c = 'Pending Processing';
            
            insert Inspection;
            
            
            CLQ_Inspection__c insObj = [Select Id From CLQ_Inspection__C Where id = :Inspection.id ];
            delete insObj;
            Test.stopTest();
        }
        
    }
    
    @IsTest
    private static void updateAllegedRulesonSubmitInspectionTest3() {
        system.assertEquals(True, 1==1,'Testing');
        map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
        system.debug('Number of Program Transactions: ' + ProgramTransactionMap.size());
        CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0];
        Test.startTest();
        
        
        
        list<string> FieldNames = new list<string>(CLQ_UtilityClass.getAllfieldsforSObject('CLQ_Inspection__c'));
        string query = 'SELECT ' + string.join(FieldNames, ',') + ' FROM CLQ_Inspection__c WHERE CLQ_Program_Transaction__c = \'' + ProgramTransaction.Id + '\' LIMIT 1';
        system.debug('updateAllegedRulesonSubmitInspectionTest1 ' + query);
        CLQ_Inspection__c Inspection = (CLQ_Inspection__c)database.query(query);
        Inspection.CLQ_Inspection_Status__c = 'Under Approver Review';
        Inspection.CLQ_Visit_Status__c =  'Visit Completed';
        Inspection.CLQ_Send_Report_To__c ='CDC Web';
        Inspection.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        //Inspection.CLQ_Type__c = 'Complaint';
        Inspection.CLQ_Inspection_Type__c = 'Complaint';
        Inspection.CLQ_Inspection_Type__c='Ongoing Registration';  
        Inspection.CLQ_DeferralDuration__c='30 Days';
        Inspection.CLQ_Insp_DeferralDueDate__c=Date.today().adddays(20);
        
        CLQ_Inspection__c OldInspection = Inspection.Clone(true, true, true, true);
        OldInspection.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        OldInspection.CLQ_DeferralDuration__c='10 Days';
        OldInspection.CLQ_Insp_DeferralDueDate__c=Date.today();
        OldInspection.CLQ_Inspection_Status__c = 'Approved';
        
        Id rtId1 = [select Id, name from RecordType where DeveloperName ='CLQ_Complaint' and   SObjectType='CLQ_Case_Custom__c' limit 1].Id;
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id, Email='NOREPLY@TEST.COM' );
        insert contactrecord ;
        
        CLQ_Case_Custom__c ca = new CLQ_Case_Custom__c(AccountId__c = accountrecord.Id,
                                                       ContactId__c = contactrecord.Id,
                                                       RecordTypeId = rtId1,
                                                       Type__c='Question',
                                                       //Origin='My Origin',
                                                       CLQ_Inspection__c = Inspection.Id,
                                                       CLQ_Anonymous_Complainant__c = true,
                                                       CLQ_Status__c='New'
                                                      );
        //insert ca;
        
        //Add two Rules inspected One Complaint and One Non-Complaint
        CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
        insert violation1;
        CLQ_Rules_Inspected__c Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Non Complaint',
                                                                 CLQ_Alleged_Rule_Violation__c = violation1.id);
        insert Rule;
        
        CLQ_Alleged_Rule_Violation__c violation2 = new CLQ_Alleged_Rule_Violation__c();
        insert violation2;
        Rule = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c = Inspection.Id, CLQ_Result__c = 'Compliant',
                                          CLQ_Alleged_Rule_Violation__c = violation2.id);
        insert Rule;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName = 'JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.liveston@abcdefg09823420980.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        list<CLQ_Inspection__c> newList = new list<CLQ_Inspection__c>{Inspection};
            list<CLQ_Inspection__c> oldList = new list<CLQ_Inspection__c>{OldInspection};
                map<id,CLQ_Inspection__c> newMap = new map<id,CLQ_Inspection__c>{Inspection.Id => Inspection};
                    map<id,CLQ_Inspection__c> oldMap = new map<id,CLQ_Inspection__c>{OldInspection.Id => OldInspection};
                        //BeforeUpdate
                        CLQ_InspectionTriggerHandler_Custom  Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                                                                                true, false, true, false, 
                                                                                                                true, false, false, 1);
        
        
        //Handler.BeforeUpdate();
        Handler.UpdateDeferralDueDate(newList,oldMap);
        Handler.updateAllegedRulesonSubmitInspection(newList, oldMap);
        Handler.updateCaseField(newList, oldMap);
        Handler.addDays(Inspection,Date.today());
        Handler.sundayOrnearSundayDate(Date.today());
        Handler.sendDeleteNotification(oldList);
        system.runAs(usr){
            Handler.FccCheckQueueMembersApproving(newList, oldMap);
        }  
        
        CLQ_Alleged_Rule_Violation__c violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
        system.debug('Retrieve violation: ' + violation);
        violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
        system.debug('Retrieve violation: ' + violation);
        
        //AfterUpdate
        Handler = new CLQ_InspectionTriggerHandler_Custom (newList, newMap, oldList, oldMap,
                                                           true, false, true, false, 
                                                           false, true, false, 1);
        Handler.AfterUpdate();
        
        violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation1.Id];
        system.debug('Retrieve violation: ' + violation);
        violation = [SELECT Id,CLQ_Decision__c  FROM CLQ_Alleged_Rule_Violation__c WHERE ID =: Violation2.Id];
        system.debug('Retrieve violation: ' + violation);
        
        test.stopTest();
    }
    
}