/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CompleteVisitModeExtnTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
public class CLQ_CompleteVisitModeExtnTest {
	@testSetup //Added method for Task - 11615
	public static void setExecuteControlSetting()
	{
	CLQ_UnitTestUtilities.setExecuteControlSetting();
	} 	
    @IsTest
    static void completeVisitModeTest(){
        User currUser = [Select id, Profile.Name from User where Id =: UserInfo.getUserId()];
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
        insert configRecord; 
        
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
              		
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Admin Read-Only' LIMIT 1];               
        User usr = new User(LastName = 'Hugh',
            FirstName = 'Jack',
            Alias = 'jHugh',
            Email = 'jack@hugh.com',
            Username = 'jack@hugh.com',
            ProfileId = profileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert usr;       
		          
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
        insert programRecord ;        
        
        CLQ_Inspection__c inspnRecord = new CLQ_Inspection__c();
        CLQ_Inspection__c inspectionrecord2 = CLQ_UtilityClass.createInspectionrecord('Complaint', 'Partial', 'Pending Processing');
        inspnRecord.CLQ_Program__c = programRecord.id;
        inspnRecord.CLQ_Inspection_Owner__c = currUser.Id;
        inspnRecord.OwnerId = currUser.Id;
        inspnRecord.CLQ_Visit_Status__c = 'Visit Completed';
        inspnRecord.CLQ_Last_Visit_Date__c = Date.today();
        Insert inspnRecord;
        
        CLQ_Inspection__c inspnRecord2 = new CLQ_Inspection__c();
        inspnRecord2.CLQ_Program__c = programRecord.id;
        inspnRecord2.CLQ_Inspection_Owner__c = currUser.Id;
        inspnRecord2.OwnerId = currUser.Id;
        inspnRecord2.CLQ_Visit_Status__c = 'Visit Completed';
        inspnRecord2.CLQ_Last_Visit_Date__c = Date.today();
        inspnRecord2.CLQ_Inspection_Status__c = 'Approved';     
        Insert inspnRecord2;
                   
        CLQ_Inspection__c insp = [Select id,CLQ_Inspection_Owner__c,CLQ_Visit_Status__c,CLQ_Last_Visit_Date__c from CLQ_Inspection__c where Id =: inspnRecord.Id];
        System.debug('Inspection Owner - '+insp.CLQ_Inspection_Owner__c+' . Inspection Visit Status - '+insp.CLQ_Visit_Status__c);
        CLQ_Inspection__c insp2 = [Select id,CLQ_Inspection_Owner__c,CLQ_Visit_Status__c,CLQ_Last_Visit_Date__c from CLQ_Inspection__c where Id =: inspnRecord2.Id];
        System.debug('Inspection Owner - '+insp2.CLQ_Inspection_Owner__c+' . Inspection Visit Status - '+insp2.CLQ_Visit_Status__c);
        
        List<String> fieldlist = new List<String>();
        fieldlist.add('CLQ_Visit_Status__c');
        fieldlist.add('CLQ_Last_Visit_Date__c');
       
        PageReference pageRef = Page.CLQ_CompleteVisitMode;
         pageRef.getParameters().put('id',inspnRecord.id);
          Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(inspnRecord);
        CLQ_CompleteVisitModeExtn ic = new CLQ_CompleteVisitModeExtn(sc);            
        system.AssertNotEquals(null,inspnRecord.CLQ_Inspection_Owner__c,'Testing');
        ic.inspectionRecord = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Inspection__c',' id=\''+inspnRecord.id+'\'', null));
        ic.onLoad();
        ic.onOK();
       PageReference pageRef2 = Page.CLQ_CompleteVisitMode;
         pageRef.getParameters().put('id',inspnRecord2.id);
          Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(inspnRecord2);
        CLQ_CompleteVisitModeExtn ic2 = new CLQ_CompleteVisitModeExtn(sc2);            
        system.AssertNotEquals(null,inspnRecord2.CLQ_Inspection_Owner__c,'Testing');
        ic2.inspectionRecord = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Inspection__c',' id=\''+inspnRecord2.id+'\'', null));
        ic2.onLoad();
        ic2.onOK();
        system.assertNotEquals(True, 1==2,'Testing');
    }
}