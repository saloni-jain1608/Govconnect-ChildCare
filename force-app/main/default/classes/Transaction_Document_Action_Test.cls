@isTest
public class Transaction_Document_Action_Test {
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
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            
            insert ProgramTransaction;
            
            CLQ_Standard_Document__c docObj = new CLQ_Standard_Document__c(Name = 'Sahil.docx',  CLQ_Organization__c = accountrecord.Id, CLQ_Program__c = programRecord.Id);
            Insert docObj;
            
            List<CLQ_Transaction_Document__c> trDoc = new List<CLQ_Transaction_Document__c>();
            trDoc.add(new CLQ_Transaction_Document__c(Name = 'document 1', CLQ_Program_Transaction__c = ProgramTransaction.Id, CLQ_Document_Status__c = 'Denied', CLQ_Document__c = docObj.id, CLQ_All_Comments__c='approve doc' ) );
            INSERT trDoc;
            
            test.startTest();
            Transaction_Document_Action ctrl=new Transaction_Document_Action();
            
            ctrl.validate('documentApprove','');
            
            ctrl.processRequest('documentApprove','');
            ctrl.processRequest('documentDenied','');
            ctrl.processRequest('documentNotVerified','');
            ctrl.processRequest('documentReturnRevision','');
            ctrl.processRequest('','');
            ctrl.processRequest('documentApprove',trDoc[0].id);
            ctrl.processRequest('documentDenied',trDoc[0].id);
            ctrl.processRequest('documentNotVerified',trDoc[0].id);
            ctrl.processRequest('documentReturnRevision',trDoc[0].id);
            test.stopTest();
        }
    }
}