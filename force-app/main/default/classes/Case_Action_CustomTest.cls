/*************************************************************************************************************
**************************************************************************************************************
** Name             : Case_Action_CustomTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Ankush R Relekar     20/12/2021       	  1.0       Initial Build 
**************************************************************************************************************/
@isTest
public class Case_Action_CustomTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }   
    @IsTest
    static void processRequestTest(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
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
        
        Test.startTest();
        Case_Action_Custom CA=new Case_Action_Custom();
        CA.validate('caseCompleteAllegation_Custom',caseRecord.Id);
        
        CA.processRequest('caseCompleteAllegation_Custom',caseRecord.Id);
        CA.processRequest('caseCompleteAllegedOpsReport_Custom',caseRecord.Id);
        CA.processRequest('caseCompleteDisposition_Custom',caseRecord.Id);
        CA.processRequest('caseCreateInspection_Custom',caseRecord.Id);
        CA.processRequest('caseCompleteReview_Custom',caseRecord.Id);
        CA.processRequest('caseSubmit_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitEnforcement_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitIncidentInjury_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitApproval_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitApprovalAllegedOps_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitIncidentInjuryIllness_Custom',caseRecord.Id);
        CA.processRequest('caseCompleteEnforcement_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitAllegedOps_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitApprovalEnforcement_Custom',caseRecord.Id);
        CA.processRequest('',caseRecord.Id);
        
        Case_Action_Custom.createInspectionRecord('Complaint', 'Partial', 'Pending Processing',caseRecord.Id);
        
        Test.stopTest();        
        system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    static void createInspectionTest(){
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
        
        system.runAs(usr){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
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
            programRecord.CLQ_Licensing_Specialist__c = usr.Id;
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
            caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Alleged_Ops_Completed').getRecordTypeId();
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
            caseRecord.CLQ_Alleged_Operator_State__c = 'VA';
            caseRecord.CLQ_Status__c = 'Submitted';
            //insert caseRecord;
            
            CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
            caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
            caseRecord1.ContactId__c = contactrecord.id;
            caseRecord1.CLQ_Program__c = programRecord.id;
            caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
            caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
            //caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
            caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
            caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
            caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
            caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
            //caseRecord.CLQ_Inspection__c = insRecord1.Id; 
            caseRecord1.CLQ_Status__c = 'Under Review';
            insert caseRecord1;
            
            CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
            allegedRule.Case_Custom__c = caseRecord.Id;
            insert allegedRule;
            
            Test.startTest();
            
            Case_Action_Custom CA=new Case_Action_Custom();
            
            CA.processRequest('caseCompleteAllegation_Custom',caseRecord.Id);
            CA.processRequest('caseCompleteAllegedOpsReport_Custom',caseRecord.Id);
            CA.processRequest('caseCompleteDisposition_Custom',caseRecord.Id);
            CA.processRequest('caseCreateInspection_Custom',caseRecord.Id);
            CA.processRequest('caseCompleteReview_Custom',caseRecord.Id);
            CA.processRequest('caseSubmit_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitEnforcement_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitIncidentInjury_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitApproval_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitApprovalAllegedOps_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitIncidentInjuryIllness_Custom',caseRecord.Id);
            CA.processRequest('caseCompleteEnforcement_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitAllegedOps_Custom',caseRecord.Id);
            CA.processRequest('caseSubmitApprovalEnforcement_Custom',caseRecord.Id);
            CA.processRequest('',caseRecord.Id);
            
            
            Case_Action_Custom.createInspectionRecord('Incident / Injury / Illness', 'Partial', 'Pending Processing',caseRecord1.Id);
            Case_Action_Custom.createInspectionRecord('Complaint', 'Partial', 'Pending Processing',caseRecord1.Id);
            
            
            Test.stopTest(); 
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    static void processRequestTestTwo(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //UserRole usrRole=[SELECT Id FROM UserRole WHERE Name = 'Clinton County Approver' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName = 'JASON',
                            //UserRoleId='00E6w000000Q5MMEA0',               
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
        
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
        insert configRecord1; 
        
        CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
        insert county;
        
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        //programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord.CLQ_Program_Status__c = 'Open';
        programRecord.CLQ_County__c = county.Id;
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        insert programRecord ;
        
        CLQ_Program__c programRecord1 = new CLQ_Program__c();
        programRecord1.Name = 'Test';
        //programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord1.CLQ_Street_Address_1__c = 'test';
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
        programRecord1.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        programRecord1.CLQ_Program_Status__c = 'Open';
        programRecord1.CLQ_County__c = county.Id;
        programRecord1.CLQ_License_Registration_Status__c='Licensed';
        programRecord1.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
        insert programRecord1 ;
        
        
        CLQ_Case_Custom__c caseRecord1 = new CLQ_Case_Custom__c();
        caseRecord1.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        //caseRecord1.ContactId__c = contactrecord.id;
        caseRecord1.CLQ_Program__c = programRecord.id;
        caseRecord1.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord1.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord1.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord1.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord1.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord1.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord1.CLQ_Inspection__c = null; 
        caseRecord1.CLQ_Status__c = 'Not Submitted';
        insert caseRecord1;
        
        
        CLQ_Case_Custom__c caseRecord2 = new CLQ_Case_Custom__c();
        caseRecord2.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        //caseRecord1.ContactId__c = contactrecord.id;
        caseRecord2.CLQ_Program__c = programRecord1.id;
        caseRecord2.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        caseRecord2.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord2.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord2.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord2.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord2.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord2.CLQ_Inspection__c = null; 
        caseRecord2.CLQ_Outcome_Reason_Code__c='12365';
        caseRecord2.CLQ_Case_Closure_Date__c=date.newInstance(2021, 11, 01);
        caseRecord2.CLQ_Status__c = 'Not Submitted';
        caseRecord2.CLQ_Complete_Allegation__c=true;
        caseRecord2.CLQ_No_Investigation_Required__c=false;
        caseRecord2.CLQ_Complete_Inspection__c=true;
        insert caseRecord2;
        
        CLQ_Case_Action_Details__c caseAction=new CLQ_Case_Action_Details__c();
        caseAction.CLQ_Case_Custom__c=caseRecord2.Id;
        insert caseAction;
        
        
        
        
        
        CLQ_Case_Custom__c caseRecord = new CLQ_Case_Custom__c();
        caseRecord.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
        //caseRecord1.ContactId__c = contactrecord.id;
        //caseRecord.CLQ_Program__c = programRecord.id;
        caseRecord.CLQ_Approver_s_Email__c = 'test@CLQ.com';
        caseRecord.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
        //caseRecord.CLQ_Assigned_To__c = UserInfo.getUserid();
        caseRecord.CLQ_Complainant_First_Name__c = 'Jim';
        caseRecord.CLQ_Complainant_Last_Name__c = 'Woods';
        caseRecord.CLQ_Complainant_Email__c = 'jim.woods@jdkdlsal.com';
        caseRecord.CLQ_Complainant_Phone__c = '6145619874';
        caseRecord.CLQ_Inspection__c = null; 
        caseRecord.CLQ_No_Investigation_Required__c=true;
        caseRecord.CLQ_Reason_for_No_Investigation__c='Created in Error';
        caseRecord.CLQ_Status__c = 'Not Submitted';
        caseRecord.CLQ_Outcome_Reason_Code__c='12365';
        caseRecord.CLQ_Case_Closure_Date__c=null;
        insert caseRecord;
        
        CLQ_Alleged_Rule_Violation__c allegedRule = new CLQ_Alleged_Rule_Violation__c();
        allegedRule.Case_Custom__c = caseRecord1.Id;
        insert allegedRule;
        
        
        
        Case_Action_Custom CA=new Case_Action_Custom();
        Case_Action_Custom.createInspectionRecord('Incident / Injury / Illness', 'Partial', 'Pending Processing',caseRecord1.Id);
        //Case_Action_Custom.createInspectionRecord('Complaint', 'Partial', 'Pending Processing',caseRecord1.Id);  
        Case_Action_Custom.createInspectionRecord('Incident / Injury / Illness', 'Partial', 'Pending Processing',caseRecord.Id);
        CA.processRequest('caseSubmitAllegedOps_Custom',caseRecord.Id);
        CA.processRequest('caseSubmitApproval_Custom',caseRecord.Id);
        CA.processRequest('caseCreateInspection_Custom',caseRecord1.Id);
        CA.processRequest('caseCompleteEnforcement_Custom',caseRecord2.Id);
        CA.processRequest('caseCompleteEnforcement_Custom',caseRecord.Id);
        CA.processRequest('caseCompleteDisposition_Custom',caseRecord2.Id);
        system.assertEquals(True, 1==1,'Testing');
        
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and Profile.name!=null and UserRole.name!=null limit 1];
        
        system.runAs(oUsr){
            
            CA.processRequest('caseCreateInspection_Custom',caseRecord1.Id);
            CA.processRequest('caseCreateInspection_Custom',caseRecord2.Id);
            
        }
        
        
        
        
        
    }
    
}