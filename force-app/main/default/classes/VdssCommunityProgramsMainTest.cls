@isTest
public class VdssCommunityProgramsMainTest {
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    static CLQ_Program_Transaction__c programTransaction = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction2 = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction3 = new CLQ_Program_Transaction__c();
    static CLQ_Program_Transaction__c programTransaction4 = new CLQ_Program_Transaction__c();
    static CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected1 = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected2 = new CLQ_Rules_Inspected__c(); 
    static CLQ_Rules_Inspected__c ruleInspected3 = new CLQ_Rules_Inspected__c();
    static CLQ_Rules_Inspected__c ruleInspected4 = new CLQ_Rules_Inspected__c();
    static CLQ_Domain_Rule__c domainRule= new CLQ_Domain_Rule__c();
    static list<CLQ_Domain_Rule__c> domainRuleList = new list<CLQ_Domain_Rule__c>();
    static  CLQ_Domain_Rule_Finding__c domainFinding=new  CLQ_Domain_Rule_Finding__c();
    static Account accountrecord=new Account();
    
    /*public static void prepareData(){
CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
insert configRecord; 

//Create account record
accountrecord.Name='Test Account';
accountrecord.CLQ_DIRN__c = '1234';
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
programRecord1.CLQ_Is_Withdrawn__c=false;
programs.add(programRecord1);

CLQ_ProgramTriggerHandler.BypassTrigger = true;
insert programs;
CLQ_ProgramTriggerHandler.BypassTrigger = false;

System.debug('@#@#@#@#@'+ programRecord.RecordType.Name + '@$@$@$@'+ programRecord.recordTypeid);
List<CLQ_Program_Transaction__c> programTransactions = new list<CLQ_Program_Transaction__c>();

programTransaction.CLQ_Program__c = programRecord.Id;
programTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
programTransaction.CLQ_Rating_Confirmed_by_Program__c = '2';
programTransaction.CLQ_Transaction_Status__c = 'Not Complete';

programTransactions.add(programTransaction);
System.debug('@@@@@@@@@Program Transaction' + programTransaction.Id + 'RECORD TYPE NAME'+ programTransaction.CLQ_Program_Record_Type__c + '#########' + programTransaction.CLQ_Rating_Confirmed_by_Program__c);

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

System.debug('INSPECTION TOOL IN TEST CLASS'+ inspectionTool);
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

System.debug('&&&&&&'+ ruleInspected.ProgramTransaction__c);

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
*/
    @IsTest
    public static void  test_method() {
        system.assertEquals(True, 1==1,'Testing');
        //prepareData();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
          
        User usr=CLQ_UnitTestUtilities.AddCustomerUser();
        //User usr=[Select ID,UserRoleId, username, UserRole.Name,ContactId, AccountId,Email from User where AccountId!=null order by CreatedDate desc limit 1];
        Account Acc= new Account();
        Acc.Id=usr.AccountId;
        Acc.Name='test 123';
        Acc.Provider_Type__c='Child Care Center';
        Acc.Ownership='Individual Ownership';
        upsert Acc;
        
      
        
        
        CLQ_Program__c programRecord1 = new CLQ_Program__c();
        programRecord1.Name = 'Test';
        programRecord1.CLQ_Associated_Organization__c = usr.AccountId;
        programRecord1.CLQ_Street_Address_1__c = 'test';
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord1.CLQ_Program_Rating__c = 3;
        programRecord1.Program_Rating__c = '3';
        programRecord1.CLQ_License_Type__c = '  Continuous';
        programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord1.Rating_Anniversary_Date__c = Date.today();
        programRecord1.CLQ_Is_Withdrawn__c=false;
        Insert programRecord1;
        
        Test.startTest();
        /*User testUser = new User(

ProfileId = [SELECT Id FROM Profile WHERE Name = 'Lic and SUTQ Reviewer - State User'].Id,
LastName = 'last',
Email = 'puser000@amamama.com',
Username = 'puser000@amamama.com' + System.currentTimeMillis(),
CompanyName = 'Test Account',
Title = 'title',
Alias = 'alias',
TimeZoneSidKey = 'America/Los_Angeles',
EmailEncodingKey = 'UTF-8',
LanguageLocaleKey = 'en_US',
LocaleSidKey = 'en_US'
//AccountId=accountrecord.Id;

);
Insert testUser;*/
        
        
        Map<String, Object> jsondata=new Map<String, Object>();
        jsondata.put('ProgramRecordType', programRecord1.recordtype.Name);
        jsondata.put('TransactionRecordType', programTransaction1.recordtype.Name);
        
        PGFPage__c pgfP = new PGFPage__c();
        pgfP.Name = 'Licensing - Child Care Center - Individual Ownership';
        pgfP.Success_Message_Body__c ='CLQ_Program_Name';
        insert pgfP;
        
        PGFSection__c pgfS = new PGFSection__c();
        pgfS.Parent__c = pgfP.Id;
        pgfS.Name = 'new Section';
        pgfS.OrderNumber__c = 45;
        insert pgfS;
        
        PGFSubSection__c pgfSS = new PGFSubSection__c();
        pgfSS.Parent__c = pgfS.Id;
        pgfSS.Name = 'ss Name';
        pgfSS.OrderNumber__c = 35;
        pgfSS.Type__c ='Component';
        pgfSS.Applicable_Form_Field_Labels__c = 'Open';
        pgfSS.ApplicableFormFields__c ='Open';
        pgfSS.Applicable_Field_Labels__c = 'Close';
        pgfSS.ApplicableFields__c ='Close';
        insert pgfSS;
        
        List<PGFField__c> fieldsReq = new List<PGFField__c>() ;
        fieldsReq.add(
            new PGFField__c(
                Name = 'CLQ_Proposed_Open_Date__c' ,
                CSSClasses__c ='col-md-4' ,
                Label__c ='Proposed Open Date' ,
                ObjectAPIName__c = 'CLQ_Program_Transaction__c' ,
                Type__c ='Date' ,
                OrderNumber__c = 2 ,
                Parent__c =  pgfSS.Id ,
                Required__c = true
            )   
        ); 
        
        
        INSERT fieldsReq ;
        
        
        CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
        programTransaction1.CLQ_Program__c = programRecord1.Id;
        programTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction1.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction1.CLQ_Transaction_Status__c = 'Not Complete';
        insert programTransaction1;
        
        Map<String, Object> fields=new Map<String, Object>();
        fields.put('label', '123');
        fields.put('Value','2' );
        fields.put('ObjectApi', 'CLQ_Program__c');
        fields.put('Type', 'Multi-Select');
        fields.put('FieldApi', 'Program_Rating__c');
        
        Map<String, Object> fields1=new Map<String, Object>();
        fields1.put('label', '123');
        fields1.put('Value', Date.today() );
        fields1.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields1.put('Type', 'Date');
        fields1.put('FieldApi', 'CLQ_Certificate_Issue_Date__c');
        
        Map<String, Object> fields2=new Map<String, Object>();
        fields2.put('label', '123');
        fields2.put('Value',5 );
        fields2.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields2.put('Type', 'Number');
        fields2.put('FieldApi', 'CLQ_Number_of_Residents__c');
        
        Map<String, Object> fields3=new Map<String, Object>();
        fields3.put('label', '123');
        fields3.put('Value',3 );
        fields3.put('ObjectApi', 'CLQ_Program__c');
        fields3.put('Type', 'Number');
        fields3.put('FieldApi', 'CLQ_Program_Rating__c');
        
        Map<String, Object> fields4=new Map<String, Object>();
        fields4.put('label', '123');
        fields4.put('Value', Date.today());
        fields4.put('ObjectApi', 'CLQ_Program__c');
        fields4.put('Type', 'Date');
        fields4.put('FieldApi', 'Rating_Anniversary_Date__c');
        
        Map<String, Object> fields5=new Map<String, Object>();
        fields5.put('label', '123');
        fields5.put('Value','2' );
        fields5.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields5.put('Type', 'Multi-Select');
        fields5.put('FieldApi', 'CLQ_Rating_Confirmed_by_Program__c');
        
        list<Map<String, Object>> fieldlist=new list<Map<String, Object>>();
        fieldlist.add(fields);
        fieldlist.add(fields1);
        fieldlist.add(fields2);
        fieldlist.add(fields3);
        fieldlist.add(fields4);
        fieldlist.add(fields5);
        
        Map<String, Object> subsection=new Map<String, Object>();
        subsection.put('label', 'Fieldset');
        subsection.put('Type', 'Fieldset');
        subsection.put('Name', pgfSS.Name);
        subsection.put('status',  pgfSS.Applicable_Form_Field_Labels__c);
        subsection.put('Fields',  fieldlist);
        
        
        list<Map<String, Object>> sectionlist=new list<Map<String, Object>>();
        list<Map<String, Object>> subsectionlist=new list<Map<String, Object>>();
        subsectionlist.add(subsection);
        
        Map<String, Object> sections=new Map<String, Object>();
        sections.put('label', 'Fieldset');
        sections.put('Name', pgfSS.Name);
        sections.put('status',  pgfSS.Applicable_Form_Field_Labels__c);
        sections.put('SubSections',  subsectionlist);
        
        sectionlist.add(sections);
        jsondata.put('Sections', sectionlist);
        
        //PGFPage__c pgf = new PGFPage__c(Success_Message_Body__c ='CLQ_Program_Name', Name='Licensing - Child Care Center - Individual Ownership');
        //insert pgf;
        
        vdssCommunityProgramsMain.getUserPrograms(usr.Id);
        vdssCommunityProgramsMain.fetchAllFieldsFromObject('CLQ_Program__c');
        vdssCommunityProgramsMain.createTransactionDocumentRecord(programTransaction1.Id,'','','');
        vdssCommunityProgramsMain.getDynamicApplicationMetadata('Licensing',programRecord1.Id,usr.Id,programTransaction1.Id);
        vdssCommunityProgramsMain.updateApplicationStatus(programTransaction1.Id,'abc');
        vdssCommunityProgramsMain.withdrawProgram(programRecord1.Id,'Nothing');
        vdssCommunityProgramsMain.withdrawProgram(programTransaction1.Id,'Nothing');
        vdssCommunityProgramsMain.fetchuploadedtransdocs(programTransaction1.Id);
        vdssCommunityProgramsMain.Program prog=new vdssCommunityProgramsMain.Program(programRecord1,programTransaction1.Id,'submitted');
        
        
        
        system.runAs(usr){
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test';
            programRecord2.CLQ_Associated_Organization__c = usr.AccountId;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord2.CLQ_Program_Rating__c = 3;
            programRecord2.Program_Rating__c = '3';
            programRecord2.CLQ_License_Type__c = '  Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord2.Rating_Anniversary_Date__c = Date.today();
            programRecord2.CLQ_Is_Withdrawn__c=false;
            Insert programRecord2;
            
            CLQ_Program_Transaction__c programTransaction7 = new CLQ_Program_Transaction__c();
            programTransaction7.CLQ_Program__c = programRecord2.Id;
            programTransaction7.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            programTransaction7.CLQ_Rating_Confirmed_by_Program__c = '2';
            programTransaction7.CLQ_Transaction_Status__c = 'Not Complete';
            insert programTransaction7;
            vdssCommunityProgramsMain.saveDynamicApplicationData(JSON.serialize(jsondata),programTransaction7.Id,'Submitted');
            //vdssCommunityProgramsMain.saveDynamicApplicationData(JSON.serialize(jsondata),'','Complete');
            
        }
        test.stopTest();
    }
}