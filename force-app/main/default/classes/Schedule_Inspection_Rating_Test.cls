/*************************************************************************************************************
**************************************************************************************************************
** Name             : Schedule_Inspection_Rating_Test
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
** Ankush R Relekar	     12/22/2021		      1.0	    Initial Build 
** 		
**************************************************************************************************************/
@istest
public class Schedule_Inspection_Rating_Test {
    @testSetup 
    public static void testSetup()
    {
        Account accountrecord_setup = new Account(Name='Test Account Setup',CLQ_DIRN__c = '12345'); 
        insert accountrecord_setup ; 
    }
    @IsTest
    public static void testschedule() {
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
            programRecord.CLQ_License_Registration_Status__c='Licensed';
            programRecord.CLQ_License_Issue_Date__c=date.today();
            programRecord.CLQ_Program_Status__c='Open';
            programRecord.Rating_Expiration_Date__c=system.today().addDays(60);
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            
            
            Test.StartTest();
            Schedule_Inspection_Rating testsche = new Schedule_Inspection_Rating();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
            Schedule_Inspection_Rating_batch InsBatch=new Schedule_Inspection_Rating_batch();
            Database.executebatch(InsBatch);
            Test.stopTest();
        }
    }
    
}