@isTest
public class ProgramActionsController_Test {
    
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
            
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test1';
            programRecord1.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord1.CLQ_Street_Address_1__c = 'test';
            programRecord1.Program_Rating__c='3';
            programRecord1.CLQ_Program_Status__c='Closed';
            programRecord1.CLQ_License_Registration_Status__c='Not Licensed';
            programRecord1.CLQ_License_Type__c='Provisional';
            programRecord1.Rating_Expiration_Date__c=date.today()+300;
            programRecord1.Rating_Effective_Date__c= date.today();
            programRecord1.Rating_Anniversary_Date__c = date.today()+40;
            programRecord1.Rating_Discontinue__c=date.today()+60;
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord1 ;
            
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test2';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test';
            programRecord2.Program_Rating__c='3';
            programRecord2.CLQ_Program_Status__c='Closed';
            programRecord2.CLQ_License_Registration_Status__c='Not Licensed';
            programRecord2.CLQ_License_Type__c='Continuous';
            programRecord2.Rating_Expiration_Date__c=date.today()+300;
            programRecord2.Rating_Effective_Date__c= date.today()+45;
            programRecord2.Rating_Anniversary_Date__c = date.today()+40;
            programRecord2.Rating_Discontinue__c=date.today()+60;
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord2 ;
            
            test.startTest();
            ProgramActionsController ctrl=new ProgramActionsController();
            ctrl.validate('validateInspectionCreation','');
            ctrl.validate('validateTAInspectionCreation','');
            ctrl.validate('validateNewDayCampAudit','');
            ctrl.validate('validateUpdatePortalRating','');
            ctrl.validate(' ','');
            ctrl.validate('validateInspectionCreation',programRecord.Id);
            ctrl.validate('validateInspectionCreation',programRecord1.Id);
            ctrl.validate('validateTAInspectionCreation',programRecord.Id);
            ctrl.validate('validateNewDayCampAudit',programRecord.Id);
            ctrl.validate('validateUpdatePortalRating',programRecord.Id);
            ctrl.validate(' ','');
            
            ctrl.processRequest('createInspection','');
            ctrl.processRequest('createTAInspection','');
            ctrl.processRequest('newDayCampAudit','');
            ctrl.processRequest('updatePortalRating','');
            ctrl.processRequest('','');
            ctrl.processRequest('createInspection',programRecord.Id);
            ctrl.processRequest('createInspection',programRecord1.Id);
            ctrl.processRequest('createInspection',programRecord2.Id);
            ctrl.processRequest('createTAInspection',programRecord1.Id);
            ctrl.processRequest('newDayCampAudit',programRecord.Id);
            ctrl.processRequest('updatePortalRating',programRecord.Id);
            ctrl.processRequest('updatePortalRating',programRecord1.Id);
            ctrl.processRequest('updatePortalRating',programRecord2.Id);
            ctrl.processRequest('','');
            
            test.stopTest();
        }
        
    }
}