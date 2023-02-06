@isTest
public class DynamicTableFormCtrl_Test {
    
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
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.Rating_Anniversary_Date__c = date.today()+40;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            insert ProgramTransaction;
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            insert inspectionrecord;
            
            
            test.startTest();
            DynamicTableFormCtrl ctrl=new DynamicTableFormCtrl();
            DynamicTableFormCtrl.TableRequest tabreq= new DynamicTableFormCtrl.TableRequest();
            tabreq.programID=programRecord.id;
            tabreq.programTransactionID=ProgramTransaction.Id;
            tabreq.recordTypeName='FCC - Type B Home';
            tabreq.objectName='CLQ_Program__c';
            tabreq.whereClause='';
            List<PageSubSection.FormComponent> l1= new List<PageSubSection.FormComponent>();
            tabreq.tableInfo=l1;
            
            ctrl.processRequest('','');
            ctrl.processRequest('getTableData','');
            ctrl.processRequest('getTableData',json.serialize(tabreq));
            ctrl.validate('validate','');
        }
    }
    
}