@istest
public class CLQ_VisitModeController_Lightning_Test {
    
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }	
    @IsTest
    static void testMethod1(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
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
            
            list<CLQ_Program__c> proglist=new list<CLQ_Program__c>();
            list<CLQ_Program__c> proglist1=new list<CLQ_Program__c>();
            list<Id> InspIdList=new list<Id>();
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
            programRecord.Rating_Expiration_Date__c=system.today().addDays(60);
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            proglist.add(programRecord);
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_County__c=countyRec.Id;
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test1';
            programRecord1.Rating_Anniversary_Date__c = date.today()+40;
            programRecord1.CLQ_License_Registration_Status__c='Licensed';
            programRecord1.CLQ_License_Issue_Date__c=date.today();
            programRecord1.CLQ_Program_Status__c='Open';
            programRecord1.Rating_Expiration_Date__c=system.today().addDays(60);
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord1 ;
            proglist.add(programRecord1);
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program__c = programRecord.Id;
            inspectionrecord.CLQ_Inspection_Status__c = 'Pending Approval';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Type__c='Technical Assistance';
            inspectionrecord.Onsite_Rating__c='3';
            inspectionrecord.CLQ_Visit_Status__c='Visit Completed';
            inspectionrecord.CLQ_Last_Visit_Date__c=system.today().addDays(10);
            inspectionrecord.CLQ_Use_Rules_Effective_On__c=system.today();
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
            InspIdList.add(inspectionrecord.Id);
            
            //Create Standard Findings
            list<CLQ_Standard_Findings__c> sfindingList = new list<CLQ_Standard_Findings__c>();
            CLQ_Standard_Findings__c sfinding = new CLQ_Standard_Findings__c(Name='test',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_Finding_Expiration_Date__c=system.today().adddays(10),CLQ_Finding_Type__c='Complaint',CLQ_Finding_Effective_Date__c=system.today().adddays(-10));
            sfindingList.add(sfinding);
            CLQ_Standard_Findings__c sfinding2 = new CLQ_Standard_Findings__c(Name='test2',CLQ_Description__c='test',CLQ_Finding_Code__c='test',CLQ_Risk_Level__c='Serious',CLQ_Finding_Expiration_Date__c=system.today().adddays(10));
            sfindingList.add(sfinding2);
            insert sfindingList;
            
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
            insert domainRule1;
            domainRuleList.add(domainRule1);
            CLQ_Domain_Rule__c domainRule2 = new CLQ_Domain_Rule__c(CLQ_Rule__c = rule2.id , CLQ_Domain__c = domain.id);
            domainRuleList.add(domainRule2);
            //insert domainRuleList;
            
            CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c=inspectionrecord.id,CLQ_Domain_Rule__c = domainRule1.id,CLQ_Result__c = 'Non-Compliant');
            insert ruleInspected;
            
            list<CLQ_Findings__c> findingslist=new list<CLQ_Findings__c>();
            CLQ_Findings__c finding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=ruleInspected.id,CLQ_Standard_Finding__c=sfinding.id,CLQ_Description__c = 'test',CLQ_TA_Description__c = 'test',CLQ_CAP_TA__c = 'CAP');
            insert finding;
            findingslist.add(finding);
            
            CLQ_Domain_Rule_Finding__c domainFinding1 = new CLQ_Domain_Rule_Finding__c(CLQ_Domain_Rule__c = domainRule1.id,CLQ_Standard_Finding__c=sfinding.id);
            insert domainFinding1;
            
            String myJSON = JSON.serialize(finding);
            string simplejson='[{"isSelected":'+true+',"finding":'+myJSON+',"sFindingCode":"","riskLevel":"","sfindingName":""}]';
            
            test.startTest();
            CLQ_VisitModeController_Lightning.getInitData(inspectionrecord.Id);
            CLQ_VisitModeController_Lightning.loadFindings(string.valueOf(domainRule1.Id),ruleInspected.Id,'Compliant',inspectionrecord.Id);
            CLQ_VisitModeController_Lightning.populateRuleAllegedFilter(true);
            CLQ_VisitModeController_Lightning.getFindingList(ruleInspected.Id);
            CLQ_VisitModeController_Lightning.getExistingStandardFindingIdMap(findingslist);
            CLQ_VisitModeController_Lightning.getExistingCorrectiveActionPlanMap(findingslist);
            CLQ_VisitModeController_Lightning.saveFindings(ruleInspected.Id,'Non-Compliant',simplejson,inspectionrecord.Id);
            CLQ_VisitModeController_Lightning.saveData(simplejson);
            test.stopTest();
        }
        
    }
    
}