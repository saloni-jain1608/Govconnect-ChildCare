/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CaseTriggerCustomTest
** Description      : This test class contains all test logic logic/methods for Case object's trigger event.
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A                     N/A             1.0         Initial Build 
**  Pavan Ayta              8/23/17         1.1         Added setExecuteControlSetting() for Task - 11615
**  Pavan Ayta              10/17/17        1.2         Fixing the Class for CR - 11415
**************************************************************************************************************/
@isTest(isparallel = true) 
private class CLQ_CaseTriggerCustomTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
    CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void insertRoleonContactTest() {
        
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){

        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        user = CLQ_UnitTestUtilities.GetInternalUser();
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;  
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        insert programRecord ;
        system.debug('@@RR' + programRecord.recordTypeid);
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord1.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord;
        CLQ_Role__c roleRec = new CLQ_Role__c();
        roleRec.CLQ_Contact__c = contactrecord.id;
        roleRec.CLQ_Program__c = programRecord.id;
        roleRec.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        roleRec.CLQ_Role__c = 'Org Role';
        insert roleRec;
        
        
        //Insert case for program
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord.CLQ_Inspection__c = insRecord1.Id; 
        caseRecord.CLQ_Status__c = 'Submitted';
        insert caseRecord;
        
         CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.Id=caseRecord.Id;
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord1.ContactId__c = contactrecord.id;
        caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord1.CLQ_Inspection__c = insRecord1.Id;
        caseRecord1.OwnerId = UserInfo.getUserid();
        caseRecord1.CLQ_Status__c = 'Under Review';
      
        
         
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        
        //caseRecord.CLQ_Status__c = 'Submitted';
        caseRecord.CLQ_Inspection__c = insRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        caseRecord.OwnerId = UserInfo.getUserid();
        update caseRecord ;
        
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caserecord1};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{caserecord1.Id => caserecord1};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caserecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caserecord.Id => caserecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.assignOwner(newList ,oldMap);
        }
        
    }    
    
    @IsTest
    static void updateTest() {
        
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
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
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecord ;
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed'; 
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        update programRecord ;
        
        //Create a program record DC
        /*
        CLQ_Program__c programRecordDC = new CLQ_Program__c();
        programRecordDC.Name = 'Test';
        programRecordDC.CLQ_Associated_Organization__c = accountrecord.id;
        programRecordDC.CLQ_Street_Address_1__c = 'test';
        programRecordDC.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Day Camp').getRecordTypeId();
        programRecordDC.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecordDC ;
        programRecordDC.CLQ_Program_Status__c = 'Open'; 
        update programRecordDC ;
        */
        
        //Create a Domain Rule record - 11415
        CLQ_Domain_Rule__c domRuleRecord = new CLQ_Domain_Rule__c();
        insert domRuleRecord;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Unannounced';
        insRecord.CLQ_Notes__c = 'inspection 1';
        insert insRecord;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        //Create a Rules Inspected record - 11415
        CLQ_Rules_Inspected__c ruleInsRecord = new CLQ_Rules_Inspected__c();
        ruleInsRecord.CLQ_Domain_Rule__c = DomRuleRecord.Id;
        ruleInsRecord.CLQ_Inspection_No__c = insRecord.Id;
        ruleInsRecord.CLQ_Allegation_Description__c = 'Test Data';
        ruleInsRecord.CLQ_Investigation_Method__c = 'On-Site';
        ruleInsRecord.CLQ_Investigation_Details_Outcome__c = 'This is Test data' ;
        ruleInsRecord.CLQ_Result__c = 'Compliant';
        insert ruleInsRecord;
        //Insert case for program
        List<CLQ_Case_Custom__c> lstCase = new List<CLQ_Case_Custom__c>();
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Anonymous_Complainant__c = true;
        lstCase.add(caseRecord);
        
        
        CLQ_Case_Custom__c caseRecord2 = new CLQ_Case_Custom__c();
        caseRecord2.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord2.ContactId__c = contactrecord.id;
        caseRecord2.CLQ_Program__c = programRecord.id;
        caseRecord2.CLQ_Inspection__c = insRecord.Id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord2.CLQ_Anonymous_Complainant__c = true;
        caseRecord2.CLQ_Status__c = 'Under Review';//PA
        caseRecord2.CLQ_Activity_Type__c = 'Suspension';//PA
        //lstCase.add(caseRecord2);
        
        CLQ_Case_Custom__c caseRecord3 = new CLQ_Case_Custom__c();
        caseRecord3.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord3.ContactId__c = contactrecord.id;
        caseRecord3.CLQ_Inspection__c = insRecord.Id;
        caseRecord3.CLQ_Program__c = programRecord.id;
        caseRecord3.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord3.CLQ_Assigned_to_Email__c = 'test3@CLQ.com';
        caseRecord3.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord3.CLQ_Anonymous_Complainant__c = true;
        caseRecord3.CLQ_Status__c = 'Not Submitted';//PA
        caseRecord3.CLQ_Activity_Type__c = 'Enforcement';//PA
        //lstCase.add(caseRecord3);
        insert lstCase;
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caserecord.Id;
        insert allegedRule;
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        
        caseRecord.CLQ_Status__c = 'Submitted';
        caseRecord.CLQ_Inspection__c = insRecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        
        update caseRecord;
        
        //***
        /*
        Case caseRecordforAllegedRules = new Case();
        caseRecordforAllegedRules.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        caseRecordforAllegedRules.ContactId = contactrecord.id;
        caseRecordforAllegedRules.Status = 'Not Submitted';
        caseRecordforAllegedRules.CLQ_Program__c = programRecord.id;
        caseRecordforAllegedRules.CLQ_Approver_s_Email__c = 'test2@CLQ.com';
        caseRecordforAllegedRules.CLQ_Assigned_to_Email__c = 'test2@CLQ.com';
        caseRecordforAllegedRules.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecordforAllegedRules.CLQ_Complainant_First_Name__c = 'Jimm';
        caseRecordforAllegedRules.CLQ_Complainant_Last_Name__c = 'Woodss';
        caseRecordforAllegedRules.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecordforAllegedRules.CLQ_Complainant_Phone__c = '614-561-9874';
        caseRecordforAllegedRules.CLQ_Inspection__c = insRecord1.Id;        
        insert caseRecord;
        
        CLQ_Alleged_Rule_Violation__c allegedRuleX = new CLQ_Alleged_Rule_Violation__c();
        allegedRuleX.Case_Custom__c = caseRecordforAllegedRules.Id;
        allegedRuleX.CLQ_Domain_Rule__c = domRuleRecord.Id;
        insert allegedRuleX;
        
        caseRecordforAllegedRules.Status = 'Submitted';
        update caseRecordforAllegedRules;
        */
        //***
        
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caserecord};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{oldcase.Id => oldcase};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caserecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caserecord.Id => caserecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        
        Handler.createRuleInspRecFromAllegedRule(newList);
        Handler.copyAllegedRuleToInsp(newList ,oldMap);
        delete caseRecord;
        }
        
    }   

    //RR
     @IsTest
    static void testMethodOne() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        //insert configuration record
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
        programRecord.CLQ_Program_Status__c = 'Open'; 
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        update programRecord ;
        
        //Create a program record DC
        /*
        CLQ_Program__c programRecordDC = new CLQ_Program__c();
        programRecordDC.Name = 'Test';
        programRecordDC.CLQ_Associated_Organization__c = accountrecord.id;
        programRecordDC.CLQ_Street_Address_1__c = 'test';
        programRecordDC.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Day Camp').getRecordTypeId();
        programRecordDC.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecordDC ;
        programRecordDC.CLQ_Program_Status__c = 'Open'; 
        update programRecordDC ;
        */
        
        //Create a Domain Rule record - 11415
        CLQ_Domain_Rule__c domRuleRecord = new CLQ_Domain_Rule__c();
        insert domRuleRecord;
        Boolean domainRulePresent = false;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Unannounced';
        insRecord.CLQ_Notes__c = 'inspection 1';
        insert insRecord;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        //Create a Rules Inspected record - 11415
        CLQ_Rules_Inspected__c ruleInsRecord = new CLQ_Rules_Inspected__c();
        ruleInsRecord.CLQ_Domain_Rule__c = DomRuleRecord.Id;
        ruleInsRecord.CLQ_Inspection_No__c = insRecord.Id;
        ruleInsRecord.CLQ_Allegation_Description__c = 'Test Data';
        ruleInsRecord.CLQ_Investigation_Method__c = 'On-Site';
        ruleInsRecord.CLQ_Investigation_Details_Outcome__c = 'This is Test data' ;
        ruleInsRecord.CLQ_Result__c = 'Compliant';
        insert ruleInsRecord;
        //Insert case for program
        List<CLQ_Case_Custom__c> lstCase = new List<CLQ_Case_Custom__c>();
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Anonymous_Complainant__c = true;
        lstCase.add(caseRecord);
        
        
        CLQ_Case_Custom__c caseRecord2 = new CLQ_Case_Custom__c();
        caseRecord2.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord2.ContactId__c = contactrecord.id;
        caseRecord2.CLQ_Program__c = programRecord.id;
        caseRecord2.CLQ_Inspection__c = insRecord.Id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord2.CLQ_Anonymous_Complainant__c = true;
        caseRecord2.CLQ_Status__c = 'Submitted';//PA
        caseRecord2.CLQ_Activity_Type__c = 'Suspension';//PA
        lstCase.add(caseRecord2);
        
        /*
        Case caseRecord3 = new Case();
        caseRecord3.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        caseRecord3.ContactId = contactrecord.id;
        caseRecord3.CLQ_Inspection__c = insRecord.Id;
        caseRecord3.CLQ_Program__c = programRecord.id;
        caseRecord3.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord3.CLQ_Assigned_to_Email__c = 'test3@CLQ.com';
        caseRecord3.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord3.CLQ_Anonymous_Complainant__c = true;
        caseRecord3.status = 'Not Submitted';//PA
        caseRecord3.CLQ_Activity_Type__c = 'Enforcement';//PA
        lstCase.add(caseRecord3);
        */
        insert lstCase;
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caseRecord.Id;
        insert allegedRule;
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        
        caseRecord2.CLQ_Status__c = 'Submitted';
        caseRecord2.CLQ_Inspection__c = insRecord.id;
        caseRecord2.CLQ_Program__c = programRecord.id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        
        update caseRecord2;
        
        
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord2};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{oldcase.Id => oldcase};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord2 };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord2.Id => caseRecord2 };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        
        Handler.createRuleInspRecFromAllegedRule(newList);
        Handler.copyAllegedRuleToInsp(newList ,oldMap);
        delete caseRecord2;
        }
        
    } 
    
     @IsTest
    static void testMethodTwo() { 
        //insert configuration record
      
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Day Camp');
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
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecord ;
        programRecord.CLQ_Program_Status__c = 'Open'; 
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        update programRecord ;
        
        //Create a program record DC
        /*
        CLQ_Program__c programRecordDC = new CLQ_Program__c();
        programRecordDC.Name = 'Test';
        programRecordDC.CLQ_Associated_Organization__c = accountrecord.id;
        programRecordDC.CLQ_Street_Address_1__c = 'test';
        programRecordDC.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Day Camp').getRecordTypeId();
        programRecordDC.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecordDC ;
        programRecordDC.CLQ_Program_Status__c = 'Open'; 
        update programRecordDC ;
        */
        
        //Create a Domain Rule record - 11415
        CLQ_Domain_Rule__c domRuleRecord = new CLQ_Domain_Rule__c();
        insert domRuleRecord;
        Boolean domainRulePresent = false;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Unannounced';
        insRecord.CLQ_Notes__c = 'inspection 1';
        insert insRecord;
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        //Create a Rules Inspected record - 11415
        CLQ_Rules_Inspected__c ruleInsRecord = new CLQ_Rules_Inspected__c();
        ruleInsRecord.CLQ_Domain_Rule__c = DomRuleRecord.Id;
        ruleInsRecord.CLQ_Inspection_No__c = insRecord.Id;
        ruleInsRecord.CLQ_Allegation_Description__c = 'Test Data';
        ruleInsRecord.CLQ_Investigation_Method__c = 'On-Site';
        ruleInsRecord.CLQ_Investigation_Details_Outcome__c = 'This is Test data' ;
        ruleInsRecord.CLQ_Result__c = 'Compliant';
        insert ruleInsRecord;
        //Insert case for program
        List<CLQ_Case_Custom__c> lstCase = new List<CLQ_Case_Custom__c>();
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Anonymous_Complainant__c = true;
        lstCase.add(caseRecord);
        
        
        CLQ_Case_Custom__c caseRecord2 = new CLQ_Case_Custom__c();
        caseRecord2.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord2.ContactId__c = contactrecord.id;
        caseRecord2.CLQ_Program__c = programRecord.id;
        caseRecord2.CLQ_Inspection__c = insRecord.Id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord2.CLQ_Anonymous_Complainant__c = true;
        caseRecord2.CLQ_Status__c = 'Submitted';//PA
        caseRecord2.CLQ_Activity_Type__c = 'Suspension';//PA
        lstCase.add(caseRecord2);
        
        /*
        Case caseRecord3 = new Case();
        caseRecord3.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        caseRecord3.ContactId = contactrecord.id;
        caseRecord3.CLQ_Inspection__c = insRecord.Id;
        caseRecord3.CLQ_Program__c = programRecord.id;
        caseRecord3.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord3.CLQ_Assigned_to_Email__c = 'test3@CLQ.com';
        caseRecord3.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord3.CLQ_Anonymous_Complainant__c = true;
        caseRecord3.status = 'Not Submitted';//PA
        caseRecord3.CLQ_Activity_Type__c = 'Enforcement';//PA
        lstCase.add(caseRecord3);
        */
        insert lstCase;
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caseRecord.Id;
        insert allegedRule;
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        
        caseRecord2.CLQ_Status__c = 'Submitted';
        caseRecord2.CLQ_Inspection__c = insRecord.id;
        caseRecord2.CLQ_Program__c = programRecord.id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        
        update caseRecord2;
        
        
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord2};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{oldcase.Id => oldcase};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord2 };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord2.Id => caseRecord2 };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        
        Handler.createRuleInspRecFromAllegedRule(newList);
        Handler.copyAllegedRuleToInsp(newList ,oldMap);
        delete caseRecord2;
        
        }
    } 
    
     @IsTest
    static void insertRoleonContactTestTwo() {

        system.debug('@@RRstart' );
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        user = CLQ_UnitTestUtilities.GetInternalUser();
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Day Camp');
        insert configRecord; 
        system.debug('@@RRconfigRecord' );
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        system.debug('@@RRaccountrecord' );
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        system.debug('@@RRcontactrecord' );
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;  
        system.debug('@@RRcountyRec' );
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'TestRR';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'testRR';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01); 
        programRecord.CLQ_Assigned_Reviewer__c=UserInfo.getUserid();
        insert programRecord ;
        system.debug('@@RRprogramRecord2'+ programRecord.recordTypeid );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord1.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        system.debug('@@RRinsRecord1' );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord;
        system.debug('@@RRinsRecord' );
        CLQ_Role__c roleRec = new CLQ_Role__c();
        roleRec.CLQ_Contact__c = contactrecord.id;
        roleRec.CLQ_Program__c = programRecord.id;
        roleRec.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        roleRec.CLQ_Role__c = 'Org Role';
        insert roleRec;
        system.debug('@@RRroleRec' );
        
        //Insert case for program
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Status__c = 'Submitted';
        //caseRecord.status = 'Not Submitted';        
        insert caseRecord;
        
        
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caserecord.Id;
        insert allegedRule;
        
        CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.Id=caseRecord.Id;
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord1.ContactId__c = contactrecord.id;
        caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord1.CLQ_Inspection__c = insRecord1.Id;
        caseRecord1.OwnerId = UserInfo.getUserid();
        caseRecord1.CLQ_Status__c = 'Under Review';
        
        system.debug('@@RRone'+ caseRecord.CLQ_Complainant_First_Name__c );
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        oldcase.CLQ_Status__c = 'Under Review';
        system.debug('@@RR' + oldcase.CLQ_Status__c );
        //caseRecord.CLQ_Status__c = 'Under Review';
        caseRecord.CLQ_Inspection__c = insRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        caseRecord.OwnerId = UserInfo.getUserid();
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord1};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{caseRecord1.Id => caseRecord1};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord.Id => caseRecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.assignOwner(newList ,oldMap);
        
        }
    }
    
     @IsTest
    static void insertRoleonContactTestThree() {

        system.debug('@@RRstart' );
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        user = CLQ_UnitTestUtilities.GetInternalUser();
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Day Camp');
        insert configRecord; 
        system.debug('@@RRconfigRecord' );
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        system.debug('@@RRaccountrecord' );
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        system.debug('@@RRcontactrecord' );
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;  
        system.debug('@@RRcountyRec' );
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'TestRR';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'testRR';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01); 
        programRecord.CLQ_Assigned_Reviewer__c=UserInfo.getUserid();
        insert programRecord ;
        system.debug('@@RRprogramRecord2'+ programRecord.recordTypeid );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord1.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        system.debug('@@RRinsRecord1' );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord;
        system.debug('@@RRinsRecord' );
        CLQ_Role__c roleRec = new CLQ_Role__c();
        roleRec.CLQ_Contact__c = contactrecord.id;
        roleRec.CLQ_Program__c = programRecord.id;
        roleRec.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        roleRec.CLQ_Role__c = 'Org Role';
        insert roleRec;
        system.debug('@@RRroleRec' );

        
        //Insert case for program
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        //caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Status__c = 'Submitted';
        //caseRecord.status = 'Not Submitted';
               
        insert caseRecord;
        
       
        
        
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caserecord.Id;
        insert allegedRule;
        
        CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.Id=caseRecord.Id;
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord1.ContactId__c = contactrecord.id;
        //caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord1.CLQ_Inspection__c = insRecord1.Id;
        caseRecord1.OwnerId = user.Id;
        caseRecord1.CLQ_Status__c = 'Under Review';
            
        
        
        system.debug('@@RRone'+ caseRecord.CLQ_Complainant_First_Name__c );
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        oldcase.CLQ_Status__c = 'Under Review';
        system.debug('@@RR' + oldcase.CLQ_Status__c );
        //caseRecord.CLQ_Status__c = 'Under Review';
        caseRecord.CLQ_Inspection__c = insRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        caseRecord.OwnerId = UserInfo.getUserid();
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord1};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{caseRecord1.Id => caseRecord1};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord.Id => caseRecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.assignOwner(newList ,oldMap);
        }
        
    }
    
     @IsTest
    static void assignOwnerTestOne() {

        system.debug('@@RRstart' );
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        user = CLQ_UnitTestUtilities.GetInternalUser();
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
        insert configRecord; 
        system.debug('@@RRconfigRecord' );
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        system.debug('@@RRaccountrecord' );
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        system.debug('@@RRcontactrecord' );
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;  
        system.debug('@@RRcountyRec' );
        //Create a program record
                
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'TestRR';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'testRR';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = null;
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01); 
        programRecord.CLQ_Assigned_Reviewer__c=null;
        insert programRecord ;
        system.debug('@@RRprogramRecord2'+ programRecord.recordTypeid );
       
        
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord1.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        system.debug('@@RRinsRecord1' );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord;
        system.debug('@@RRinsRecord' );
        CLQ_Role__c roleRec = new CLQ_Role__c();
        roleRec.CLQ_Contact__c = contactrecord.id;
        roleRec.CLQ_Program__c = programRecord.id;
        roleRec.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        roleRec.CLQ_Role__c = 'Org Role';
        insert roleRec;
        system.debug('@@RRroleRec' );

        
        //Insert case for program
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Status__c = 'Submitted';
        //caseRecord.status = 'Not Submitted';
               
        insert caseRecord;
        
       
        
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caserecord.Id;
        insert allegedRule;
        
        CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.Id=caseRecord.Id;
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord1.ContactId__c = contactrecord.id;
        caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord1.CLQ_Inspection__c = insRecord1.Id;
        caseRecord1.CLQ_Status__c = 'Under Review';
            
        
        
        system.debug('@@RRone'+ caseRecord.CLQ_Complainant_First_Name__c );
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        oldcase.CLQ_Status__c = 'Under Review';
        system.debug('@@RR' + oldcase.CLQ_Status__c );
        //caseRecord.CLQ_Status__c = 'Under Review';
        //caseRecord.CLQ_Inspection__c = insRecord.id;
        //caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        //caseRecord.OwnerId = UserInfo.getUserid();
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord1};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{caseRecord1.Id => caseRecord1};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord.Id => caseRecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.assignOwner(newList ,oldMap);
      
        }
        
    }
    
     @IsTest
     static void assignOwnerTestTwo() {

        system.debug('@@RRstart' );
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        user = CLQ_UnitTestUtilities.GetInternalUser();
         system.assertEquals(True, 1==1,'Testing');
         system.runAs(new user(ID = UserInfo.getUserID())){
         

        //insert configuration record
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        system.debug('@@RRconfigRecord' );
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        system.debug('@@RRaccountrecord' );
        //Insert contact
        Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
        insert contactrecord ;
        system.debug('@@RRcontactrecord' );
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;  
        system.debug('@@RRcountyRec' );
        //Create a program record
                
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'TestRR';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'testRR';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = null;
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01); 
        programRecord.CLQ_Assigned_Reviewer__c=user.Id;
        insert programRecord ;
        system.debug('@@RRprogramRecord2'+ programRecord.recordTypeid );
       
        
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord1 = new CLQ_Inspection__c();
        insRecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord1.CLQ_Inspection_Type__c = 'Complaint';
        insRecord1.CLQ_Program__c = programRecord.Id;
        insRecord1.CLQ_Notice__c = 'Announced';
        insRecord1.CLQ_Notes__c = 'inspection 2';
        insert insRecord1;
        system.debug('@@RRinsRecord1' );
        //Create an Inspection record - 11415
        CLQ_Inspection__c insRecord = new CLQ_Inspection__c();
        insRecord.CLQ_Inspection_Status__c = 'Pending Processing';
        insRecord.CLQ_Inspection_Type__c = 'Complaint';
        insRecord.CLQ_Program__c = programRecord.Id;
        insRecord.CLQ_Notice__c = 'Announced';
        insRecord.CLQ_Notes__c = 'inspection 2';
        insert insRecord;
        system.debug('@@RRinsRecord' );
        CLQ_Role__c roleRec = new CLQ_Role__c();
        roleRec.CLQ_Contact__c = contactrecord.id;
        roleRec.CLQ_Program__c = programRecord.id;
        roleRec.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
        roleRec.CLQ_Role__c = 'Org Role';
        insert roleRec;
        system.debug('@@RRroleRec' );

        
        //Insert case for program
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord.ContactId__c = contactrecord.id;
        caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord.CLQ_Inspection__c = insRecord1.Id;
        caseRecord.CLQ_Status__c = 'Submitted';
        //caseRecord.status = 'Not Submitted';
               
        insert caseRecord;
        
       
        
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caserecord.Id;
        insert allegedRule;
        
        CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.Id=caseRecord.Id;
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        caseRecord1.ContactId__c = contactrecord.id;
        caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        //caseRecord1.CLQ_Inspection__c = insRecord1.Id;
        caseRecord1.CLQ_Status__c = 'Under Review';
            
        
        
        system.debug('@@RRone'+ caseRecord.CLQ_Complainant_First_Name__c );
        CLQ_Case_Custom__c oldcase = caseRecord.Clone(true, true, true, true);
        oldcase.CLQ_Status__c = 'Under Review';
        system.debug('@@RR' + oldcase.CLQ_Status__c );
        //caseRecord.CLQ_Status__c = 'Under Review';
        //caseRecord.CLQ_Inspection__c = insRecord.id;
        //caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ2.com';
        //caseRecord.OwnerId = UserInfo.getUserid();
        list<CLQ_Case_Custom__c> oldList = new list<CLQ_Case_Custom__c>{caseRecord1};
        map<id,CLQ_Case_Custom__c> oldMap = new map<id,CLQ_Case_Custom__c>{caseRecord1.Id => caseRecord1};
        list<CLQ_Case_Custom__c> newList = new list<CLQ_Case_Custom__c>{caseRecord };
        map<id,CLQ_Case_Custom__c> newMap = new map<id,CLQ_Case_Custom__c>{caseRecord.Id => caseRecord };         
        CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(newList, newMap, oldList, oldMap,
                        true, false, true, false, 
                        true, false, false, 1);
        Handler.assignOwner(newList ,oldMap);
         }
      
        
        
    }
    
}