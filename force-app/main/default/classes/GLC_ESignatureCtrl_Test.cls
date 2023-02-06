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
public class GLC_ESignatureCtrl_Test {
    
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
            
            
            InspectionCtrl ctrl=new InspectionCtrl();
            ctrl.processRequest('Calculate','');
            
            
            
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.CLQ_Transaction_Status__c='Onsite Visit Pending';
            ProgramTransaction.CLQ_Transaction_Assigned_To__c=userinfo.getUserId();
            insert ProgramTransaction;
            ctrl.processRequest('Calculate Desk Review Rating',ProgramTransaction.Id);
            ctrl.processRequest('Desk Review Findings',ProgramTransaction.Id);
            
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();
            inspectionrecord.CLQ_Program_Transaction__c = ProgramTransaction.Id;
            inspectionrecord.CLQ_Program__c = ProgramTransaction.CLQ_Program__r.Id;
            inspectionrecord.Inspection_Status__c = 'In Progress';
            inspectionrecord.CLQ_County_at_Site__c='BROWN1';
            inspectionrecord.CLQ_Inspection_Owner__c=userinfo.getUserId();
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
            insert inspectionrecord;
            CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
            
            
            GLC_ESignatureCtrl.signDocuments('Test',inspectionrecord.Id,'30','30','TestName','Test@deloitte.com');
        }
    }
}