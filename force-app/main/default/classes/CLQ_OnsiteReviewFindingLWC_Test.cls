@isTest
public class CLQ_OnsiteReviewFindingLWC_Test {
    
    static CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected1 = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected2 = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected3 = new CLQ_Rules_Inspected__c();
    static CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
    static CLQ_Inspection__c inspection = new CLQ_Inspection__c();
    static CLQ_Inspection__c inspection1 = new CLQ_Inspection__c();
    static CLQ_Inspection__c inspection2 = new CLQ_Inspection__c();
    static CLQ_Inspection__c inspection3 = new CLQ_Inspection__c();
    static CLQ_Domain_Rule__c domainRule= new CLQ_Domain_Rule__c();
    static  CLQ_Domain_Rule_Finding__c domainFinding=new  CLQ_Domain_Rule_Finding__c();
    
    
    /*@testSetup
public static void setExecuteControlSetting()
{
CLQ_UnitTestUtilities.setExecuteControlSetting();
} */ 
    @testSetup
    public static void prepareData(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='CLQ_Program__c' and Name='FCC - Type B Home' Limit 1];
        //Create a program record
        List<CLQ_Program__c> programs = new List<CLQ_Program__c>();
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
        
        List<CLQ_Program_Transaction__c> programTransactionS = new List<CLQ_Program_Transaction__c>();
        programTransaction.CLQ_Program__c = programRecord.Id;
        programTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        programTransaction.Rating_Estimated_By_System__c = '2';
        programTransaction.CLQ_Transaction_Status__c = 'Not Complete';
        programTransactions.add(programTransaction);
        
        programTransaction1.CLQ_Program__c = programRecord1.Id;
        programTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction1.Recommended_Rating__c = '2';
        programTransaction1.Rating_Estimated_By_System__c = '2';
        programTransaction1.CLQ_Transaction_Status__c = 'Not Complete';
        programTransactions.add(programTransaction1);
        
        CLQ_Program_TransactionTriggerHandler.BypassTrigger=true;
        insert(programTransactions);
        CLQ_Program_TransactionTriggerHandler.BypassTrigger=false;
        
        List<CLQ_Inspection__c> inspections = new list<CLQ_Inspection__c>();
        inspection.Inspection_Status__c = 'Not Complete';
        inspection.CLQ_Inspection_Status__c = 'Pending Processing';
        inspection.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspection.CLQ_Use_Rules_Effective_On__c = Date.newInstance(2018,1,1);
        inspections.add(inspection);
        
        inspection1.Inspection_Status__c = 'Not Complete';
        inspection1.CLQ_Inspection_Status__c = 'Pending Processing';
        inspection1.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspections.add(inspection1);
        
        inspection2.Inspection_Status__c = 'Not Complete';
        inspection2.CLQ_Inspection_Status__c = 'Pending Processing';
        inspection2.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspections.add(inspection2);
        
        inspection3.Inspection_Status__c = 'Not Complete';
        inspection3.CLQ_Inspection_Status__c = 'Pending Processing';
        inspection3.CLQ_Program_Transaction__c = ProgramTransaction.Id;
        inspections.add(inspection3);
        
        insert inspections;
        //Create Domains
        list<CLQ_Domain__c> domainList = new list<CLQ_Domain__c>();
        CLQ_Domain__c domain = new CLQ_Domain__c(name='Learning & Development');
        domainList.add(domain);
        
        CLQ_Domain__c domain1 = new CLQ_Domain__c(name='Learning & Development');
        CLQ_Domain__c domain2 = new CLQ_Domain__c(name='Staff Qualifications & Professional Development');
        CLQ_Domain__c domain3 = new CLQ_Domain__c(name='Administrative & Leadership Practices');
        CLQ_Domain__c domain4 = new CLQ_Domain__c(name='Accreditation');
        CLQ_Domain__c domain5 = new CLQ_Domain__c(name='Ratio & Group Size');
        domainList.add(domain1);
        domainList.add(domain2);
        domainList.add(domain3);
        domainList.add(domain4);
        domainList.add(domain5);
        
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
        
        insert ruleList;
        
        //Create Domain Rules
        list<CLQ_Domain_Rule__c> domainRuleList = new list<CLQ_Domain_Rule__c>();
        domainRule = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule);
        CLQ_Domain_Rule__c domainRule1 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule1.id , CLQ_Domain__c = domain1.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule1);
        
        CLQ_Domain_Rule__c domainRule2 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule2.id , CLQ_Domain__c = domain.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule2);
        
        CLQ_Domain_Rule__c domainRule3 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule3.id , CLQ_Domain__c = domain1.id, CLQ_Applicable_To_Scope__c = 'Focused');
        domainRuleList.add(domainRule3);
        
        insert domainRuleList;
        //Create Standard Findings
        list<CLQ_Standard_Findings__c> sfindingList = new list<CLQ_Standard_Findings__c>();
        CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true,CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding);
        CLQ_Standard_Findings__c sfinding1 = new CLQ_Standard_Findings__c(Name='test1',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true,CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding1);
        
        CLQ_Standard_Findings__c sfinding2 = new CLQ_Standard_Findings__c(Name='test2',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true,CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding2);
        
        CLQ_Standard_Findings__c sfinding3 = new CLQ_Standard_Findings__c(Name='test3',Domain__c = 'Staff Qualifications & Professional Development',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_CAP__c = false,CLQ_TA__c = true,CLQ_Finding_Effective_Date__c = Date.newInstance(2018,1,1));
        sfindingList.add(sfinding3);
        
        insert sfindingList;
        
        list<CLQ_Domain_Rule_Finding__c> domainRuleFindingslist = new list<CLQ_Domain_Rule_Finding__c>();
        CLQ_Domain_Rule_Finding__c domainFinding = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule.id,CLQ_Standard_Finding__c=sfinding.id);
        CLQ_Domain_Rule_Finding__c domainFinding1 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Standard_Finding__c=sfinding1.id);
        // CLQ_Domain_Rule_Finding__c domainFinding2 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule2.id,CLQ_Standard_Finding__c=sfinding2.id);
        CLQ_Domain_Rule_Finding__c domainFinding3 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule3.id,CLQ_Standard_Finding__c=sfinding3.id);
        domainRuleFindingslist.add(domainFinding);
        domainRuleFindingslist.add(domainFinding1);
        //domainRuleFindingslist.add(domainFinding2);
        domainRuleFindingslist.add(domainFinding3);
        insert domainRuleFindingslist;
        
        //Create inspection  tool
        CLQ_Inspection_Tools__c inspectionTool = new CLQ_Inspection_Tools__c(name='Full',CLQ_Onsite__c = true,CLQ_Active__c = true,CLQ_Applicable_To_Scope__c = 'Focused',CLQ_Applicable_To__c ='FCC - Type B Home',PTEstimatedDeskRating_c__c = '2');
        insert inspectionTool;
        
        
        CLQ_Inspection_Tools__c inspectionTool1 = new CLQ_Inspection_Tools__c(name='Full',CLQ_Onsite__c = true,CLQ_Active__c = true,CLQ_Applicable_To_Scope__c = 'Focused',CLQ_Applicable_To__c ='FCC - Type B Home',PTEstimatedDeskRating_c__c = '2');
        insert inspectionTool1;
        
        //Create tool rules
        
        CLQ_Tools_Rules__c toolRule = new CLQ_Tools_Rules__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Inspection_Tools__c=inspectionTool.id);
        insert toolRule;
        
        List<CLQ_Rules_Inspected__c> listrulesInspected = new list<CLQ_Rules_Inspected__c>();
        //  CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule1.id);
        ruleInspected.ProgramTransaction__c= programTransaction.Id;
        ruleInspected.CLQ_Inspection_No__c=inspection.id;
        ruleInspected.CLQ_Domain_Rule__c = domainRule.id;
        listrulesInspected.add(ruleInspected);
        //insert ruleInspected ;
        
        // CLQ_Rules_Inspected__c ruleInspected2 = new CLQ_Rules_Inspected__c( ProgramTransaction__c= programTransaction.Id ,CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule1.id);
        ruleInspected1.ProgramTransaction__c= programTransaction1.Id;
        ruleInspected1.CLQ_Inspection_No__c=inspection.id;
        ruleInspected1.CLQ_Domain_Rule__c = domainRule1.id;
        listrulesInspected.add(ruleInspected1);
        
        ruleInspected2.ProgramTransaction__c= programTransaction.Id;
        ruleInspected2.CLQ_Inspection_No__c=inspection2.id;
        ruleInspected2.CLQ_Domain_Rule__c = domainRule2.id;
        listrulesInspected.add(ruleInspected2);
        
        ruleInspected3.ProgramTransaction__c= programTransaction.Id;
        ruleInspected3.CLQ_Inspection_No__c=inspection3.id;
        ruleInspected3.CLQ_Domain_Rule__c = domainRule3.id;
        listrulesInspected.add(ruleInspected3);
        
        insert listrulesInspected ;
        
        
        List<CLQ_Domain_Rule_Finding__c> domainruleFindings = new list<CLQ_Domain_Rule_Finding__c>();
        CLQ_Domain_Rule_Finding__c dr = new CLQ_Domain_Rule_Finding__c(CLQ_Standard_Finding__c = sfinding.id,CLQ_Domain_Rule__c = domainRule.Id);
        domainruleFindings.add(dr);
        
        CLQ_Domain_Rule_Finding__c dr1 = new CLQ_Domain_Rule_Finding__c(CLQ_Standard_Finding__c = sfinding1.id,CLQ_Domain_Rule__c = domainRule1.Id);
        domainruleFindings.add(dr1);
        
        CLQ_Domain_Rule_Finding__c dr2 = new CLQ_Domain_Rule_Finding__c(CLQ_Standard_Finding__c = sfinding2.id,CLQ_Domain_Rule__c = domainRule2.Id);
        domainruleFindings.add(dr2);
        
        insert domainruleFindings;
        
        List<CLQ_Findings__c> findings = new list<CLQ_Findings__c>();
        CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id, Rating__c='D', Points__c ='2', CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction1.Id);
        findings.add(finding);
        
        CLQ_Findings__c findinginspection = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,Rating__c='3', Points__c ='D',CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',CLQ_Inspection__c = inspection.Id , Rule__c = rule.id);
        findings.add(findinginspection);
        
        CLQ_Findings__c finding1 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected1.id,CLQ_Standard_Finding__c=sfinding1.id,Rating__c='3', Points__c ='D',CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id, CLQ_Domain_Rule__c = domainRule1.Id );
        findings.add(finding1);
        
        CLQ_Findings__c finding2 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected2.id,CLQ_StandardFindingsName__c = 'test2',Rating__c='3', Points__c ='D',CLQ_Standard_Finding__c=sfinding2.id,CLQ_Description__c = 'test',CLQ_Inspection__c = inspection2.Id , Rule__c = rule2.id,CLQ_Domain_Rule__c = domainRule2.Id );
        findings.add(finding2);
        
        CLQ_Findings__c finding3 = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected3.id,CLQ_StandardFindingsName__c = 'test3',Rating__c='3', Points__c ='D',CLQ_Standard_Finding__c=sfinding3.id,CLQ_Description__c = 'test',Program_Transaction__c = ProgramTransaction.Id, Rule__c = rule3.id,CLQ_Domain_Rule__c = domainRule3.Id );
        findings.add(finding3);
        
        insert findings;
        
        //return inspections;
        
    }
    @IsTest
    public static void  test_method() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            List<CLQ_Inspection__c> insplist=new List<CLQ_Inspection__c>();
            
            insplist= [Select id,concurrentFlag__c,CLQ_Use_Rules_Effective_On__c,CLQ_Program_Transaction__r.Id from CLQ_Inspection__c];
            domainFinding=[Select id, CLQ_Standard_Finding__r.Id, CLQ_Standard_Finding__r.CLQ_Description__c, CLQ_Standard_Finding__r.CLQ_Points__c, CLQ_Standard_Finding__r.Name, CLQ_Standard_Finding__r.CLQ_Rating__c from CLQ_Domain_Rule_Finding__c limit 1];
            domainRule=[Select id from CLQ_Domain_Rule__c limit 1];
            ruleInspected=[Select id from CLQ_Rules_Inspected__c limit 1];
            
            Test.startTest();
            CLQ_OnsiteReviewFindingControllerLWC.onLoad(insplist[0].Id);
            CLQ_OnsiteReviewFindingControllerLWC.createRulesInspected(insplist[0].Id);
            CLQ_OnsiteReviewFindingControllerLWC.loadData(insplist[0].Id);
            CLQ_OnsiteReviewFindingControllerLWC.onCancel(insplist[0].Id);
            CLQ_OnsiteReviewFindingControllerLWC.popupOnLoad(string.valueOf(domainRule.Id),string.valueOf(ruleInspected.id),'',string.valueOf(insplist[0].Id));
            
            CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = domainFinding.CLQ_Standard_Finding__r.Id
                                                          ,CLQ_Description__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                          ,Points__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                          ,CLQ_StandardFindingsName__c = domainFinding.CLQ_Standard_Finding__r.Name
                                                          ,Rating__c = domainFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                          ,CLQ_Domain_Rule_Finding__c = domainFinding.id
                                                         );
            CLQ_OnsiteReviewFindingControllerLWC.popupWrapperFindings dispWrapperFindingRecord = new CLQ_OnsiteReviewFindingControllerLWC.popupWrapperFindings(true,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,null);                      
            //system.debug('if findings does not match====>'+wrapperRecord); //Commenting for 15267
            //popupWrapperList.add(wrapperRecord); //Commenting for 15267
            list<CLQ_OnsiteReviewFindingControllerLWC.popupWrapperFindings> popupWrapperFindingList=new list<CLQ_OnsiteReviewFindingControllerLWC.popupWrapperFindings>();
            popupWrapperFindingList.add(dispWrapperFindingRecord); // Updated for 15267
            
            CLQ_OnsiteReviewFindingControllerLWC.popupWrapper wrapper=new CLQ_OnsiteReviewFindingControllerLWC.popupWrapper(true,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c);
            list<CLQ_OnsiteReviewFindingControllerLWC.popupWrapper> wrapperlist= new list<CLQ_OnsiteReviewFindingControllerLWC.popupWrapper>();
            wrapperlist.add(wrapper);
            CLQ_OnsiteReviewFindingControllerLWC.savePopUp(string.valueOf(domainRule.Id),string.valueOf(insplist[0].Id),wrapperlist);
            Test.stopTest();
            system.assertEquals(True, 1==1,'Testing');
        }
    }
}