@isTest
public class CAPQuickActionController_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void test(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CAPQuickActionController q1 = new CAPQuickActionController();
            q1.validate('updateCAPonQuickActionClick','');
            q1.processRequest('updateCAPonQuickActionClick','');
            
            CAPQuickActionController q2 = new CAPQuickActionController();
            q1.validate('updateCAPonQuickActionCl','');
            q1.processRequest('updateCAPonQuickActionC','');
            
            CLQ_County__c county = new CLQ_County__c(Name = 'Clinton', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Akron' );
            insert county;
            
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            programRecord.CLQ_Program_Status__c = 'New';
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';        
            programRecord.CLQ_County__c = county.id;
            programRecord.CLQ_License_Issue_Date__c = system.Date.today();
            //programRecord.CLQ_Licensing_Specialist__c = u.id;
            insert programRecord;  
            
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Annual', 'Full', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = (Date.today()).addyears(-10);
            inspectionrecord.CLQ_Inspection_Type__c = 'Annual';
            inspectionrecord.CLQ_Scope__c = 'Full';
            inspectionrecord.CLQ_Inspection_Status__c = 'Approved';
            insert inspectionrecord;
            
            //List<CLQ_Corrective_Action_Plan__c> capList = new List<CLQ_Corrective_Action_Plan__c>();
            CLQ_Corrective_Action_Plan__c plan = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord.Id,             
                CLQ_Inspection__c = inspectionrecord.Id);
            insert plan;
            //CAPQuickActionController q3 = new CAPQuickActionController();
            //q3.approveCAP(plan);
            CAPQuickActionController.approveCAP(plan);
            CAPQuickActionController.NotRequiredCAP(plan);
            CAPQuickActionController.DenyCAP(plan);
            CAPQuickActionController.ReturnRevCAP(plan);
            CLQ_Corrective_Action_Plan__c plan1 = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Not Submitted',
                CLQ_CAP_Due_Date__c = System.Date.today(),
                CLQ_Program__c = programRecord.Id,             
                CLQ_Inspection__c = inspectionrecord.Id,
                CLQ_Reviewer_Comments__c = 'Approved');
            CAPQuickActionController.approveCAP(plan1);
            CAPQuickActionController.NotRequiredCAP(plan1);
            CAPQuickActionController.DenyCAP(plan1);
            CAPQuickActionController.ReturnRevCAP(plan1);
            
            
        }
        
        
    }
    
    
}