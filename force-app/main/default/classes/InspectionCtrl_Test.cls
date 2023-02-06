/*************************************************************************************************************
**************************************************************************************************************
** Name             : Program_Rating_Controller_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Ankush R Relekar     20/12/2021       	  1.0       Initial Build 
**************************************************************************************************************/
@isTest
public class InspectionCtrl_Test {
    
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }   
    
    static testMethod void ProcessRequestTest(){
        Test.startTest();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_County__c=countyRec.Id;
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.Rating_Anniversary_Date__c = date.today()+40;
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        
        InspectionCtrl ctrl=new InspectionCtrl();
        ctrl.processRequest('Calculate','');
        
        
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction;
        
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord.Inspection_Status__c = 'In Progress';
        inspectionrecord.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
        inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        CLQ_Inspection__c inspectionrecord1 = new CLQ_Inspection__c();
        inspectionrecord1.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        inspectionrecord1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord1.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord1.Inspection_Status__c = 'In Progress';
        inspectionrecord1.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord1.CLQ_Inspection_Type__c='Amendment - change of location';
        inspectionrecord1.CLQ_Inspection_Owner__c=userinfo.getUserId();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord1;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
        insert sfinding;
        
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
        insert domain;
        CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        insert rule;
        
        CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        insert domainRule;
        
        CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        ruleInspected.CLQ_Result__c = 'Non-Compliant';
        insert ruleInspected ;
        
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c = '3');
        insert finding;
        
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                           Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
        insert standardDetail;
        
        
        Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
        insert ans;
        
        CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
        td.CLQ_Document_Status__c ='Under Review';
        td.CLQ_Program_Transaction__c= ProgramTransaction.id;
        td.CLQ_Document_Comments__c = 'test';
        td.Rating__c='3';
        insert td;
        
        ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
        update ProgramTransaction;
        
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and Profile.name like '%Admin%' and UserRole.name!=null and ManagerId !=null limit 1];
        
        
        system.runAs(oUsr){
            ctrl.processRequest('completeTAVisit',inspectionrecord.Id);
            //ctrl.processRequest('submitForApproval',inspectionrecord1.Id);
            ctrl.validate('validateInspectionCreation',ProgramTransaction.Id);
        }
        
        ctrl.validate('validateOnSiteVisitRating',inspectionrecord.Id);
        ctrl.validate('validateOnsiteStandardFindings',inspectionrecord.Id);
        ctrl.validate('validateOnsite',inspectionrecord.Id);
        ctrl.processRequest('calculateOnSiteVisitRating',inspectionrecord.Id);
        ctrl.deleteInspection();
        ctrl.processRequest('createFollowUpInspection',inspectionrecord.Id);
        ctrl.processRequest('reviewOnsiteStandardFindings',inspectionrecord.Id);
        ctrl.processRequest('createInspection',ProgramTransaction.Id);
        
        
        
        
        
        Test.stopTest();
    }
    
    static testMethod void ProcessRequestTest2(){
        
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_County__c=countyRec.Id;
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.Rating_Anniversary_Date__c = date.today()+40;
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c=date.today();
        programRecord.CLQ_Program_Status__c='Open';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        
        
        
        
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE - Change of Location').getRecordTypeId();
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
        ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment- FCC - Change of Capacity / Space').getRecordTypeId();
        ProgramTransaction1.CLQ_Program__c = programRecord.id;
        ProgramTransaction1.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction1.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction1;
        
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord.Inspection_Status__c = 'In Progress';
        inspectionrecord.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord.CLQ_Inspection_Type__c='Ongoing Registration';
        inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Inspection__c inspectionrecord1 = new CLQ_Inspection__c();
        inspectionrecord1.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        inspectionrecord1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord1.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord1.Inspection_Status__c = 'In Progress';
        inspectionrecord1.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord1.CLQ_Inspection_Type__c='Amendment - change of location';
        inspectionrecord1.CLQ_Inspection_Owner__c=userinfo.getUserId();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord1;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
        insert sfinding;
        
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
        insert domain;
        CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        insert rule;
        
        CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        insert domainRule;
        
        CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        ruleInspected.CLQ_Result__c = 'Non-Compliant';
        insert ruleInspected ;
        
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c = '3');
        insert finding;
        
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                           Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
        insert standardDetail;
        
        
        Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
        insert ans;
        
        CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
        td.CLQ_Document_Status__c ='Under Review';
        td.CLQ_Program_Transaction__c= ProgramTransaction.id;
        td.CLQ_Document_Comments__c = 'test';
        td.Rating__c='3';
        insert td;
        
        ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
        update ProgramTransaction;
        
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and Profile.name like '%Admin%' and UserRole.name!=null and ManagerId !=null limit 1];
        
        InspectionCtrl ctrl=new InspectionCtrl();
        
        Test.startTest();        
        system.runAs(oUsr){
            ctrl.processRequest('completeTAVisit',inspectionrecord.Id);
            ctrl.processRequest('submitForApproval',inspectionrecord1.Id);
            ctrl.validate('validateInspectionCreation',ProgramTransaction.Id);
        }
        
        CLQ_Program_Transaction__c programTransactionRecord = [SELECT Id, CLQ_Program__r.CLQ_BIRN__c,CLQ_Program__r.CLQ_Attendance_Options_Global__c,
                                                               CLQ_Program__r.CLQ_Services_Offered_Global__c,CLQ_Age_Groups_Served_Global__c,CLQ_Attendance_Options_Global__c,CLQ_Services_Offered_Global__c, CLQ_Full_Part_Time_Options_Global__c, 
                                                               CLQ_Program__r.RecordtypeId,CLQ_Transaction_Assigned_To__c,CLQ_Program__r.Id,RecordType.Name,CLQ_Program__r.CLQ_Age_Groups_Served_Global__c, CLQ_Provider_Agreement__c,
                                                               CLQ_Program__r.CLQ_License_Type__c,CLQ_Site_IRN__c,CLQ_New_BIRN_Site_IRN__c,OEDS_Site_Status_c__c,OEDS_Location_Type_c__c,OEDS_Location_Id_c__c,
                                                               CLQ_ProgTrans_Phone__c,CLQ_ProgTrans_Phone_Extension__c,CLQ_Services_Offered_Day_Camp__c,CLQ_Food_Service__c,CLQ_ProgTrans_Street_Address__c,
                                                               CLQ_ProgTrans_Street_Address_2__c,CLQ_ProgTrans_City__c,CLQ_ProgTrans_County__c,CLQ_ProgTrans_State__c,CLQ_ProgTrans_Zip_Code__c,
                                                               CLQ_Old_Program_Street_Address__c,CLQ_Old_Program_Street_Address_2__c,CLQ_Old_City__c,CLQ_Old_County__c,CLQ_State__c,CLQ_Old_Zip_Code__c,
                                                               CLQ_Program_Street_Address_1__c,CLQ_Program_Street_Address_2__c,CLQ_City__c,CLQ_County__c,CLQ_Zip_Code__c,Program_Transaction_County__c,
                                                               CLQ_New_Street_Address_1__c,CLQ_New_Street_Address_2__c,CLQ_New_City__c, CLQ_New_State__c,CLQ_New_Zip_Code__c FROM CLQ_Program_Transaction__c WHERE Id =:ProgramTransaction.Id];
        
        CLQ_Program_Transaction__c programTransactionRecord1 = [SELECT Id, CLQ_Program__r.CLQ_BIRN__c,CLQ_Program__r.CLQ_Attendance_Options_Global__c,
                                                                CLQ_Program__r.CLQ_Services_Offered_Global__c,CLQ_Age_Groups_Served_Global__c,CLQ_Attendance_Options_Global__c,CLQ_Services_Offered_Global__c, CLQ_Full_Part_Time_Options_Global__c, 
                                                                CLQ_Program__r.RecordtypeId,CLQ_Transaction_Assigned_To__c,CLQ_Program__r.Id,RecordType.Name,CLQ_Program__r.CLQ_Age_Groups_Served_Global__c, CLQ_Provider_Agreement__c,
                                                                CLQ_Program__r.CLQ_License_Type__c,CLQ_Site_IRN__c,CLQ_New_BIRN_Site_IRN__c,OEDS_Site_Status_c__c,OEDS_Location_Type_c__c,OEDS_Location_Id_c__c,
                                                                CLQ_ProgTrans_Phone__c,CLQ_ProgTrans_Phone_Extension__c,CLQ_Services_Offered_Day_Camp__c,CLQ_Food_Service__c,CLQ_ProgTrans_Street_Address__c,
                                                                CLQ_ProgTrans_Street_Address_2__c,CLQ_ProgTrans_City__c,CLQ_ProgTrans_County__c,CLQ_ProgTrans_State__c,CLQ_ProgTrans_Zip_Code__c,
                                                                CLQ_Old_Program_Street_Address__c,CLQ_Old_Program_Street_Address_2__c,CLQ_Old_City__c,CLQ_Old_County__c,CLQ_State__c,CLQ_Old_Zip_Code__c,
                                                                CLQ_Program_Street_Address_1__c,CLQ_Program_Street_Address_2__c,CLQ_City__c,CLQ_County__c,CLQ_Zip_Code__c,Program_Transaction_County__c,
                                                                CLQ_New_Street_Address_1__c,CLQ_New_Street_Address_2__c,CLQ_New_City__c, CLQ_New_State__c,CLQ_New_Zip_Code__c FROM CLQ_Program_Transaction__c WHERE Id =:ProgramTransaction1.Id];
        
        
        ctrl.updateInspectionDetail(inspectionrecord, programTransactionRecord);
        ctrl.updateInspectionDetail(inspectionrecord1, programTransactionRecord1);
        ctrl.validate('validateOnSiteVisitRating',inspectionrecord.Id);
        ctrl.validate('validateOnsiteStandardFindings',inspectionrecord.Id);
        ctrl.validate('validateOnsite',inspectionrecord.Id);
        ctrl.processRequest('calculateOnSiteVisitRating',inspectionrecord.Id);
        ctrl.deleteInspection();
        ctrl.processRequest('createFollowUpInspection',inspectionrecord.Id);
        ctrl.processRequest('reviewOnsiteStandardFindings',inspectionrecord.Id);
        ctrl.processRequest('createInspection',ProgramTransaction.Id);
        
        
        
        
        
        Test.stopTest();
    }
    
    static testMethod void ProcessRequestTest3(){
        
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_County__c=countyRec.Id;
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.Rating_Anniversary_Date__c = date.today()+40;
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c=date.today();
        programRecord.CLQ_Program_Status__c='Open';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        
        
        
        
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE - Change of Location').getRecordTypeId();
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
        ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment- FCC - Change of Capacity / Space').getRecordTypeId();
        ProgramTransaction1.CLQ_Program__c = programRecord.id;
        ProgramTransaction1.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction1.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction1;
        
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and Profile.name like '%Admin%' and UserRole.name!=null and ManagerId !=null limit 1];
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord.CLQ_Inspection_Status__c = 'Pending Approval';
        inspectionrecord.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord.CLQ_Inspection_Type__c='Technical Assistance';
        inspectionrecord.CLQ_Inspection_Owner__c=oUsr.Id;
        inspectionrecord.Onsite_Rating__c='3';
        inspectionrecord.CLQ_Visit_Status__c='Visit Completed';
        
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Inspection__c inspectionrecord1 = new CLQ_Inspection__c();
        inspectionrecord1.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        inspectionrecord1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord1.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        inspectionrecord1.CLQ_County_at_Site__c='BROWN1';
        //inspectionrecord1.CLQ_Inspection_Type__c='Amendment - change of location';
        inspectionrecord1.CLQ_Visit_Status__c='Visit Completed';
        inspectionrecord1.CLQ_Inspection_Type__c='Technical Assistance';
        inspectionrecord1.CLQ_Inspection_Owner__c=userinfo.getUserId();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord1;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
        insert sfinding;
        
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
        insert domain;
        CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        insert rule;
        
        CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        insert domainRule;
        
        CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        ruleInspected.CLQ_Result__c = 'Non-Compliant';
        insert ruleInspected ;
        
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c = '3');
        insert finding;
        
        CLQ_Findings__c finding1 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test123',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c='2');
        insert finding1;
        
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                           Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
        insert standardDetail;
        
        
        Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
        insert ans;
        
        CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
        td.CLQ_Document_Status__c ='Under Review';
        td.CLQ_Program_Transaction__c= ProgramTransaction.id;
        td.CLQ_Document_Comments__c = 'test';
        td.Rating__c='3';
        insert td;
        
        ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
        update ProgramTransaction;
        
        CLQ_Room_Space_Transaction__c roomSpace = new CLQ_Room_Space_Transaction__c();
        roomSpace.CLQ_Program_Transaction__c = ProgramTransaction.id;
        roomSpace.CLQ_Currently_In_Use__c = 'No';
        roomSpace.CLQ_Room_Space_Shape__c = 'Irregular';
        roomSpace.CLQ_Room_Space_Number__c = '123';
        roomSpace.CLQ_Room_Space_Type__c = 'Primary Space';
        roomSpace.CLQ_Square_Footage_Irregular__c = 10;
        insert roomSpace;
        
        
        InspectionCtrl ctrl=new InspectionCtrl();
        
        Test.startTest();        
        system.runAs(oUsr){
            ctrl.processRequest('completeTAVisit',inspectionrecord1.Id);
            ctrl.processRequest('submitForApproval',inspectionrecord.Id);
            ctrl.processRequest('submitForApproval',inspectionrecord1.Id);
            ctrl.validate('validateInspectionCreation',ProgramTransaction.Id);
        }
        ctrl.processRequest('createInspection',ProgramTransaction.Id);
        
        
        Test.stopTest();
    }
    
    static testMethod void ProcessRequestTest4(){
        
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        CLQ_County__c countyRec = new CLQ_County__c();
        countyRec.CCC_Field_Officers__c = 'Cleveland';
        countyRec.Area_Region__c = 'NE';
        countyRec.name = 'BROWN1';     
        insert countyRec;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_County__c=countyRec.Id;
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.Rating_Anniversary_Date__c = date.today()+40;
        programRecord.CLQ_License_Registration_Status__c='Licensed';
        programRecord.CLQ_License_Issue_Date__c=date.today();
        programRecord.CLQ_Program_Status__c='Open';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord ;
        
        
        
        
        
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
        ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
        ProgramTransaction.CLQ_Program__c = programRecord.id;
        ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c ProgramTransaction1 = new CLQ_Program_Transaction__c();
        ProgramTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment- FCC - Change of Capacity / Space').getRecordTypeId();
        ProgramTransaction1.CLQ_Program__c = programRecord.id;
        ProgramTransaction1.CLQ_Transaction_Status__c='Onsite Visit Pending';
        ProgramTransaction1.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
        insert ProgramTransaction1;
        
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and (Not Profile.name like '%Admin%') and UserRole.name!=null and ManagerId !=null limit 1];
         //User oUsr = [SELECT Id, Profile.Name, UserRole.Name, IsActive FROM User where IsActive =True and (NOT Profile.name like '%Admin%') limit 1];
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord.CLQ_Inspection_Status__c = 'Pending Approval';
        inspectionrecord.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord.CLQ_Inspection_Type__c='Technical Assistance';
        inspectionrecord.CLQ_Inspection_Owner__c=oUsr.Id;
        inspectionrecord.Onsite_Rating__c='3';
        inspectionrecord.CLQ_Visit_Status__c='Visit Completed';
        
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Inspection__c inspectionrecord1 = new CLQ_Inspection__c();
        inspectionrecord1.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        inspectionrecord1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspectionrecord1.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
        inspectionrecord1.CLQ_Inspection_Status__c = 'Pending Processing';
        inspectionrecord1.CLQ_County_at_Site__c='BROWN1';
        //inspectionrecord1.CLQ_Inspection_Type__c='Amendment - change of location';
        inspectionrecord1.CLQ_Visit_Status__c='Visit Completed';
        inspectionrecord1.CLQ_Inspection_Type__c='Technical Assistance';
        inspectionrecord1.CLQ_Inspection_Owner__c=userinfo.getUserId();
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord1;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        
        
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true);
        insert sfinding;
        
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
        insert domain;
        CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        insert rule;
        
        CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        insert domainRule;
        
        CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule.id);
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        ruleInspected.CLQ_Result__c = 'Non-Compliant';
        insert ruleInspected ;
        
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c = '3');
        insert finding;
        
        CLQ_Findings__c finding1 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test123',Program_Transaction__c = ProgramTransaction.Id,CLQ_Inspection__c=inspectionrecord.Id,Rating__c='2');
        insert finding1;
        
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                           Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
        insert standardDetail;
        
        

        
        ProgramTransaction.CLQ_Rules_Effective_On__c=Date.today().addDays(-10);
        update ProgramTransaction;
        
 
        
        
        InspectionCtrl ctrl=new InspectionCtrl();
        
        Test.startTest();        
        system.runAs(oUsr){
            ctrl.processRequest('completeTAVisit',inspectionrecord1.Id);
            ctrl.processRequest('submitForApproval',inspectionrecord.Id);
            ctrl.processRequest('submitForApproval',inspectionrecord1.Id);
            ctrl.validate('validateInspectionCreation',ProgramTransaction.Id);
        }
        ctrl.processRequest('createInspection',ProgramTransaction.Id);
        ctrl.processRequest('createInspection',ProgramTransaction1.Id);
        
        
        Test.stopTest();
    }
}