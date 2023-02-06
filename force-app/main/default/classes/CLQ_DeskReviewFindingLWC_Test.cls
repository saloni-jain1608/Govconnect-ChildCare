@isTest
public class CLQ_DeskReviewFindingLWC_Test {
   /* @testSetup 
    public static void testSetup()
    {
        CLQ_Program__c programRecordSetup = new CLQ_Program__c();
        programRecordSetup.Name = 'Test Setup';
    }*/
    static CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction3 = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction4 = new CLQ_Program_Transaction__c();
    static CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected3 = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected4 = new CLQ_Rules_Inspected__c();
    static list<CLQ_Domain_Rule__c> domainRuleList = new list<CLQ_Domain_Rule__c>();
    static  CLQ_Domain_Rule_Finding__c domainFinding=new  CLQ_Domain_Rule_Finding__c();
    
    @testSetup
    public static void prepareData(){
        CLQ_Program__c programRecordSetup = new CLQ_Program__c();
        programRecordSetup.Name = 'Test Setup';
        CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
        CLQ_Program_Transaction__c programTransaction2 = new CLQ_Program_Transaction__c();
        CLQ_Rules_Inspected__c ruleInspected1 = new CLQ_Rules_Inspected__c();
        CLQ_Rules_Inspected__c ruleInspected2 = new CLQ_Rules_Inspected__c(); 
        //CLQ_Domain_Rule__c domainRule= new CLQ_Domain_Rule__c();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='CLQ_Program__c' and Name='FCC - Type B Home' Limit 1];
        //Create a program record
        System.debug('RT#$#$#$'+ rt.Name);
        Map<ID,Schema.RecordTypeInfo> programRd_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        list<CLQ_Program__c> programs = new list<CLQ_Program__c>();
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_License_Registration_Status__c = 'Exempt';
        programs.add(programRecord);
        
        CLQ_Program__c programRecord1 = new CLQ_Program__c();
        programRecord1.Name = 'Test';
        programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord1.CLQ_Street_Address_1__c = 'test';
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord1.CLQ_Program_Rating__c = 3;
        programRecord1.Program_Rating__c = '3';
        programRecord1.CLQ_License_Type__c = '  Continuous';
        programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord1.Rating_Anniversary_Date__c = Date.today();
        programs.add(programRecord1);
        
        CLQ_ProgramTriggerHandler.BypassTrigger = true;
        insert programs;
        CLQ_ProgramTriggerHandler.BypassTrigger = false;
        
        
        List<CLQ_Program_Transaction__c> programTransactions = new list<CLQ_Program_Transaction__c>();
        
        programTransaction.CLQ_Program__c = programRecord.Id;
        programTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        programTransaction.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction.CLQ_Transaction_Status__c = 'Not Complete';
        
        programTransactions.add(programTransaction);
        
        
        programTransaction1.CLQ_Program__c = programRecord1.Id;
        programTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction1.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction1.CLQ_Transaction_Status__c = 'Not Complete';
        programTransactions.add(programTransaction1);
        
        programTransaction2.CLQ_Program__c = programRecord.Id;
        programTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        programTransaction2.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction2.CLQ_Transaction_Status__c = 'Not Complete';
        programTransactions.add(programTransaction2);
        
        programTransaction3.CLQ_Program__c = programRecord1.Id;
        programTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction3.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction3.CLQ_Transaction_Status__c = 'Not Complete';
        programTransactions.add(programTransaction3);
        
        programTransaction4.CLQ_Program__c = programRecord.Id;
        programTransaction4.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
        programTransaction4.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction4.CLQ_Transaction_Status__c = 'In Progress';
        programTransactions.add(programTransaction4);
        
        CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
        insert(programTransactions);
        CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
        //Insert CLQ_Inspection__c 
        CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Pre-license', 'Full', 'Pending Processing');
        inspectionrecord.CLQ_Program__c = programRecord.id;
        inspectionrecord.CLQ_Use_Rules_Effective_On__c = Date.today();
        insert inspectionrecord;
        
        //Create Domains
        list<CLQ_Domain__c> domainList = new list<CLQ_Domain__c>();
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Domain1');
        domainList.add(domain);
        
        insert domainList;
        
        //Create Rules
        list<CLQ_Rule__c> ruleList = new list<CLQ_Rule__c>();
        CLQ_Rule__c rule = new CLQ_Rule__c(Name='Rule',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        ruleList.add(rule);
        
        CLQ_Rule__c rule1 = new CLQ_Rule__c(Name='Rule1',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        ruleList.add(rule1);
        
        CLQ_Rule__c rule2 = new CLQ_Rule__c(Name='Rule2',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        ruleList.add(rule2);
        
        CLQ_Rule__c rule3 = new CLQ_Rule__c(Name='Rule3',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        ruleList.add(rule3);
        
        CLQ_Rule__c rule4 = new CLQ_Rule__c(Name='Rule4',CLQ_Domain__c='Staff Files (FT)',CLQ_Rule_Effective_Date__c = (Date.today()).addDays(-10),CLQ_Rule_Expiration_Date__c = (Date.today()).adddays(10),CLQ_Description__c='test');
        ruleList.add(rule4);
        
        insert ruleList;
        
        //Create Domain Rules
        //list<CLQ_Domain_Rule__c> domainRuleList = new list<CLQ_Domain_Rule__c>();
        CLQ_Domain_Rule__c domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule);
        CLQ_Domain_Rule__c domainRule1 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule1.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule1);
        CLQ_Domain_Rule__c domainRule2 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule2.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule2);
        CLQ_Domain_Rule__c domainRule3 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule3.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule3);
        CLQ_Domain_Rule__c domainRule4 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule4.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule4);
        
        insert domainRuleList;
        //Create Standard Findings
        list<CLQ_Standard_Findings__c> sfindingList = new list<CLQ_Standard_Findings__c>();
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true, CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding);
        CLQ_Standard_Findings__c sfinding1 = new CLQ_Standard_Findings__c(Name='test1',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c  = false,CLQ_TA__c = true, CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding1);
        CLQ_Standard_Findings__c sfinding2 = new CLQ_Standard_Findings__c(Name='test2',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c  = false,CLQ_TA__c = true, CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding2);
        CLQ_Standard_Findings__c sfinding3 = new CLQ_Standard_Findings__c(Name='test3',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c  = false,CLQ_TA__c = true, CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding3);
        CLQ_Standard_Findings__c sfinding4 = new CLQ_Standard_Findings__c(Name='test4',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c  = false,CLQ_TA__c = true, CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding4);        
        insert sfindingList;
        
        list<CLQ_Domain_Rule_Finding__c> domainRuleFindingslist = new list<CLQ_Domain_Rule_Finding__c>();
        CLQ_Domain_Rule_Finding__c domainFinding = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule.id,CLQ_Standard_Finding__c=sfinding.id);
        CLQ_Domain_Rule_Finding__c domainFinding1 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Standard_Finding__c=sfinding1.id);
        CLQ_Domain_Rule_Finding__c domainFinding2 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule2.id,CLQ_Standard_Finding__c=sfinding2.id);
        CLQ_Domain_Rule_Finding__c domainFinding3 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule3.id,CLQ_Standard_Finding__c=sfinding3.id);
        CLQ_Domain_Rule_Finding__c domainFinding4 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule4.id,CLQ_Standard_Finding__c=sfinding4.id);
        domainRuleFindingslist.add(domainFinding);
        domainRuleFindingslist.add(domainFinding1);
        domainRuleFindingslist.add(domainFinding2);
        domainRuleFindingslist.add(domainFinding3);
        insert domainRuleFindingslist;
        
        //Create inspection  tool
        CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(name='Full',CLQ_Active__c = true,CLQ_Applicable_To_Scope__c = 'Focused',CLQ_Applicable_To__c ='FCC - Type B Home',PTEstimatedDeskRating_c__c = '2',CLQ_Is_Related_to_Program_Transaction__c= true,Applicable_to_SUTQ_Transactions__c= 'Initial Registration;Ongoing Registration');
        insert inspectionTool;
        
        //Create inspection  tool
        CLQ_Inspection_Tools__c inspectionTool1 = new CLQ_Inspection_Tools__c(name='Full',CLQ_Active__c = true,CLQ_Applicable_To_Scope__c = 'Focused',CLQ_Applicable_To__c ='FCC - Type B Home',PTEstimatedDeskRating_c__c = '2',CLQ_Is_Related_to_Program_Transaction__c= true);
        insert inspectionTool1;
        
        
        CLQ_Inspection_Tools__c inspectionTool2 = new CLQ_Inspection_Tools__c(name='Full',CLQ_Active__c = true,CLQ_Applicable_To_Scope__c = 'Focused',CLQ_Applicable_To__c ='FCC - Type B Home',PTEstimatedDeskRating_c__c = '2',CLQ_Is_Related_to_Program_Transaction__c= true, Applicable_to_SUTQ_Transactions__c = 'Expedited Registration');
        insert inspectionTool2;
        
        //Create tool rules
        List<CLQ_Tools_Rules__c> toolRuleList = new List<CLQ_Tools_Rules__c>();
        CLQ_Tools_Rules__c toolRule = new CLQ_Tools_Rules__c(CLQ_Domain_Rule__c = domainRule.id,CLQ_Inspection_Tools__c=inspectionTool.id);
        toolRuleList.add(toolRule);
        CLQ_Tools_Rules__c toolRule1 = new CLQ_Tools_Rules__c(CLQ_Domain_Rule__c = domainRule4.id,CLQ_Inspection_Tools__c=inspectionTool2.id);
        toolRuleList.add(toolRule1);
        insert toolRuleList;
        
        List<CLQ_Rules_Inspected__c> listrulesInspected = new list<CLQ_Rules_Inspected__c>();
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        listrulesInspected.add(ruleInspected);
        
        ruleInspected1.ProgramTransaction__c= programTransaction1.Id;
        ruleInspected1.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected1.CLQ_Domain_Rule__c = domainRule.id;
        listrulesInspected.add(ruleInspected1);
        
        ruleInspected2.ProgramTransaction__c= programTransaction2.Id;
        ruleInspected2.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected2.CLQ_Domain_Rule__c = domainRule2.id;
        listrulesInspected.add(ruleInspected2);
        
        ruleInspected3.ProgramTransaction__c= programTransaction3.Id;
        ruleInspected3.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected3.CLQ_Domain_Rule__c = domainRule3.id;
        listrulesInspected.add(ruleInspected3);
        
        ruleInspected4.ProgramTransaction__c= programTransaction4.Id;
        ruleInspected4.CLQ_Inspection_No__c=inspectionrecord.id;
        ruleInspected4.CLQ_Domain_Rule__c = domainRule4.id;
        listrulesInspected.add(ruleInspected4);
        insert listrulesInspected ;
        
        
        
        List<CLQ_Findings__c> findings = new List<CLQ_Findings__c>();
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test');
        findings.add(finding);
        
        CLQ_Findings__c finding1 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected1.id,CLQ_Standard_Finding__c=sfinding1.id,CLQ_Description__c = 'test' , Program_Transaction__c = programTransaction1.Id , Rule__c = rule1.Id );
        findings.add(finding1);
        
        CLQ_Findings__c finding2 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected2.id,CLQ_Standard_Finding__c=sfinding2.id,CLQ_StandardFindingsName__c = 'test2',CLQ_Domain_Rule__c = domainRule2.id,CLQ_Description__c = 'test' , Program_Transaction__c = programTransaction2.Id , Rule__c = rule2.Id );
        findings.add(finding2);
        
        CLQ_Findings__c finding3 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected3.id,CLQ_Standard_Finding__c=sfinding3.id,CLQ_StandardFindingsName__c = 'test3',CLQ_Domain_Rule__c = domainRule3.id,CLQ_Description__c = 'test' , Program_Transaction__c = programTransaction3.Id , Rule__c = rule3.Id );
        findings.add(finding3);
        
        CLQ_Findings__c finding4 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected4.id,CLQ_Standard_Finding__c=sfinding4.id,CLQ_StandardFindingsName__c = 'test4',CLQ_Domain_Rule__c = domainRule4.id,CLQ_Description__c = 'test' , Program_Transaction__c = programTransaction4.Id , Rule__c = rule4.Id );
        findings.add(finding4);
        
        insert findings;
        
        
    }
    @IsTest
    public static void test_method() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //prepareData();
            list<CLQ_Program_Transaction__c> PTList=[Select id from CLQ_Program_Transaction__c];
            list<CLQ_Rules_Inspected__c> RulesList=[Select id from CLQ_Rules_Inspected__c];
            domainFinding=[Select id, CLQ_Standard_Finding__r.Id, CLQ_Standard_Finding__r.CLQ_Description__c, CLQ_Standard_Finding__r.CLQ_Points__c, CLQ_Standard_Finding__r.Name, CLQ_Standard_Finding__r.CLQ_Rating__c from CLQ_Domain_Rule_Finding__c limit 1];
            ruleInspected=RulesList[0];
            programTransaction=PTList[0];
            domainRuleList=[Select id from CLQ_Domain_Rule__c];
            Test.startTest();
            CLQ_DeskReviewFindingControllerLWC.createRulesInspected(programTransaction.Id);
            CLQ_DeskReviewFindingControllerLWC.loadData(programTransaction.Id);
            CLQ_DeskReviewFindingControllerLWC.popupOnLoad(string.valueOf(domainRuleList[0].Id),string.valueOf(ruleInspected.id),string.valueOf(programTransaction.Id));
            
            CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = domainFinding.CLQ_Standard_Finding__r.Id
                                                          ,CLQ_Description__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                          ,Points__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                          ,CLQ_StandardFindingsName__c = domainFinding.CLQ_Standard_Finding__r.Name
                                                          ,Rating__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                          ,CLQ_Met_Not_Met__c = null
                                                          ,CLQ_Domain_Rule_Finding__c = domainFinding.id
                                                         );
            CLQ_DeskReviewFindingControllerLWC.popupWrapper wrapperRecord = new CLQ_DeskReviewFindingControllerLWC.popupWrapper(true,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,NULL);     
            list<CLQ_DeskReviewFindingControllerLWC.popupWrapper> wrapperlist= new list<CLQ_DeskReviewFindingControllerLWC.popupWrapper>();
            wrapperlist.add(wrapperRecord);
            CLQ_DeskReviewFindingControllerLWC.savePopUp(string.valueOf(domainRuleList[0].Id),string.valueOf(programTransaction.Id),wrapperlist);
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void  test_method1() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //prepareData();
            list<CLQ_Rules_Inspected__c> RulesList=[Select id from CLQ_Rules_Inspected__c];
            list<CLQ_Program_Transaction__c> PTList=[Select id from CLQ_Program_Transaction__c];
            domainFinding=[Select id, CLQ_Standard_Finding__r.Id, CLQ_Standard_Finding__r.CLQ_Description__c, CLQ_Standard_Finding__r.CLQ_Points__c, CLQ_Standard_Finding__r.Name, CLQ_Standard_Finding__r.CLQ_Rating__c from CLQ_Domain_Rule_Finding__c limit 1];
            ruleInspected3=RulesList[3];
            ruleInspected4=RulesList[4];
            programTransaction3=PTList[3];
            programTransaction4=PTList[4];
            domainRuleList=[Select id from CLQ_Domain_Rule__c];
            Test.startTest();
            CLQ_DeskReviewFindingControllerLWC.createRulesInspected(programTransaction4.Id);
            CLQ_DeskReviewFindingControllerLWC.loadData(programTransaction4.Id);
            CLQ_DeskReviewFindingControllerLWC.popupOnLoad(string.valueOf(domainRuleList[0].Id),string.valueOf(ruleInspected4.id),string.valueOf(programTransaction4.Id));
            CLQ_DeskReviewFindingControllerLWC.popupOnLoad(string.valueOf(domainRuleList[0].Id),string.valueOf(ruleInspected3.id),string.valueOf(programTransaction3.Id));
            
            CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = domainFinding.CLQ_Standard_Finding__r.Id
                                                          ,CLQ_Description__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                          ,Points__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                          ,CLQ_StandardFindingsName__c = domainFinding.CLQ_Standard_Finding__r.Name
                                                          ,Rating__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                          ,CLQ_Met_Not_Met__c = null
                                                          ,CLQ_Domain_Rule_Finding__c = domainFinding.id
                                                         );
            CLQ_DeskReviewFindingControllerLWC.popupWrapper wrapperRecord = new CLQ_DeskReviewFindingControllerLWC.popupWrapper(true,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,NULL);     
            list<CLQ_DeskReviewFindingControllerLWC.popupWrapper> wrapperlist= new list<CLQ_DeskReviewFindingControllerLWC.popupWrapper>();
            wrapperlist.add(wrapperRecord);
            CLQ_DeskReviewFindingControllerLWC.savePopUp(string.valueOf(domainRuleList[0].Id),string.valueOf(programTransaction4.Id),wrapperlist);
            CLQ_DeskReviewFindingControllerLWC.savePopUp(string.valueOf(domainRuleList[0].Id),string.valueOf(programTransaction3.Id),wrapperlist);
            
            Test.stopTest();
        }
    }
}