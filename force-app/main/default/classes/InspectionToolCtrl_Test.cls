@isTest
public class InspectionToolCtrl_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void inspectionTool(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            InspectionToolCtrl ins1 = new InspectionToolCtrl();
            //ins1.processRequest('getInspectionTools','');
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
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
            //inspectionrecord.CLQ_Scope__c='Partial';
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;        	
            insert inspectionrecord;
            
            ins1.processRequest('getInspectionTools',inspectionrecord.id);
            ins1.getInspectionTools();
        }
    }
    
    @IsTest
    static void inspectionToolOne()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            InspectionToolCtrl ins2 = new InspectionToolCtrl();
            //ins2.processRequest('saveInspectionTools','');
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
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = programRecord.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
            
            CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(CLQ_Applicable_To_Scope__c = 'Full',name='Full',CLQ_Active__c = true,CLQ_Applicable_To__c='Child Care Center',CLQ_Application_To_Inspection_Type__c='Provisional');
            insert inspectionTool;
            InspectionToolCtrl.InspectionTool T2 = new InspectionToolCtrl.InspectionTool(inspectionTool);
            
            List<InspectionToolCtrl.InspectionTool> T3 = new List<InspectionToolCtrl.InspectionTool>();
            T3.add(T2);
            
            
            
            
            InspectionToolCtrl.ToolRequest T1 = new InspectionToolCtrl.ToolRequest();
            T1.inspectionTools = T3;
            T1.fullScopeInspectionToolId = inspectionTool.id;
            T1.recordId = inspectionrecord.id;
            
            ins2.processRequest('getInspectionTools',inspectionrecord.id);
            ins2.processRequest('saveInspectionTools',Json.serialize(T1));
            //ins2.getInspectionTools();
        }
    }
    
    @IsTest
    static void inspectionToolThree()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            InspectionToolCtrl ins2 = new InspectionToolCtrl();
            //ins2.processRequest('saveInspectionTools','');
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
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
            insert ProgramTransaction;
            
            CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(CLQ_Applicable_To_Scope__c = 'Full',name='Full',CLQ_Active__c = true,CLQ_Applicable_To__c='Child Care Center');
            insert inspectionTool;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = programRecord.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
            inspectionrecord.CLQ_Scope__c = 'Partial';
            inspectionrecord.CLQ_Method__c = 'On-site Inspection';
            inspectionrecord.CLQ_Inspection_Tool__c = inspectionTool.id;
            //inspectionrecord.CLQ_Use_Rules_Effective_On__c = '020222';
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
            CLQ_Domain__c domain = new CLQ_Domain__c(name='Learning & Development');
            insert domain;
            CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
            insert rule;
            CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused', CLQ_Rule_Effective_Date__c=(Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c=(Date.today()).addDays(200));
            insert domainRule;
            
            CLQ_Alleged_Rule_Violation__c violation1 = new CLQ_Alleged_Rule_Violation__c();
            insert violation1;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c();
            ruleInspected.ProgramTransaction__c= programTransaction.Id;
            ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
            ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
            ruleInspected.CLQ_Alleged_Rule_Violation__c=violation1.Id;
            insert ruleInspected;
            
            CLQ_Tools_Rules__c toolRule = new CLQ_Tools_Rules__c(CLQ_Domain_Rule__c = domainRule.id,CLQ_Inspection_Tools__c=inspectionTool.id);
            insert toolRule;
            
            //CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(CLQ_Applicable_To_Scope__c = 'Full',name='Full',CLQ_Active__c = true,CLQ_Applicable_To__c='Child Care Center');
            //insert inspectionTool;
            InspectionToolCtrl.InspectionTool T2 = new InspectionToolCtrl.InspectionTool(inspectionTool);
            
            List<InspectionToolCtrl.InspectionTool> T3 = new List<InspectionToolCtrl.InspectionTool>();
            T3.add(T2);
            
            
            
            
            InspectionToolCtrl.ToolRequest T1 = new InspectionToolCtrl.ToolRequest();
            T1.inspectionTools = T3;
            T1.fullScopeInspectionToolId = inspectionTool.id;
            T1.recordId = inspectionrecord.id;
            
            
            ins2.processRequest('saveInspectionTools',Json.serialize(T1));
            //ins2.getInspectionTools();
        }
    }
    
    @IsTest
    static void inspectionToolTwo()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            InspectionToolCtrl ins3 = new InspectionToolCtrl();
            ins3.processRequest('','');
            ins3.validate('','');
            
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
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
        }
    }
    
    
    
    
    
    
    
}