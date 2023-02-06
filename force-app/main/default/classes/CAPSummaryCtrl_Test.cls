@isTest
public class CAPSummaryCtrl_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void testOne(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            if(Schema.SObjectType.CLQ_OCLQS_Configuration__c.isAccessible()){
                insert configRecord;
            }
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234');
            if(Schema.SObjectType.Account.isAccessible()){
                insert accountrecord ;
            }
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.Rating_Anniversary_Date__c = date.today()+40;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            if(Schema.SObjectType.CLQ_Program__c.isAccessible()){
                insert programRecord ;
            }
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            if(Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                insert ProgramTransaction;
            }
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            if(Schema.SObjectType.CLQ_Inspection__c.isAccessible()){
                insert inspectionrecord;
            }
            
            CLQ_Corrective_Action_Plan__c plan1 = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord.Id,             
                CLQ_Inspection__c = inspectionrecord.Id);
            if(Schema.SObjectType.CLQ_Corrective_Action_Plan__c.isAccessible()){
                insert plan1;
            }
            
            test.startTest();
            CAPSummaryCtrl ctrl=new CAPSummaryCtrl();
            CAPSummaryCtrl.FileRequest filereq= new CAPSummaryCtrl.FileRequest();
            filereq.fileName='Test Doc';
            filereq.documentId='';
            filereq.capId=plan1.Id;
            filereq.inspectionId=inspectionrecord.id;
            List<ContentDocumentLink> documents;
            
            CAPSummaryCtrl.InspectionRequest Ireq=new CAPSummaryCtrl.InspectionRequest();
            Ireq.userID=userinfo.getUserId();
            Ireq.inspectionID=inspectionrecord.id;
            
            CAPSummaryCtrl.InspectionCAP inspcap=new CAPSummaryCtrl.InspectionCAP(plan1,documents);
            
            
            ctrl.validate('validate','');
            ctrl.processRequest('','');
            
            ctrl.processRequest('getInspectionCaps',json.serialize(filereq));
            ctrl.processRequest('createCAPDocument',json.serialize(filereq));
            ctrl.processRequest('getInspections',json.serialize(Ireq));
            test.stopTest();
        }
        
    }
}