@istest
public class CLQ_UpdateProgramInspectionDate_Test {
    
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }	
    static testMethod void TestMethod1(){
        
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
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
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
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        insert programRecord1 ;
        proglist.add(programRecord1);
        
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        inspectionrecord.CLQ_Program__c = programRecord.Id;
        inspectionrecord.CLQ_Inspection_Status__c = 'Pending Approval';
        inspectionrecord.CLQ_County_at_Site__c='BROWN1';
        inspectionrecord.CLQ_Inspection_Type__c='Technical Assistance';
        inspectionrecord.Onsite_Rating__c='3';
        inspectionrecord.CLQ_Visit_Status__c='Visit Completed';
        inspectionrecord.CLQ_Last_Visit_Date__c=system.today().addDays(10);
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
        insert inspectionrecord;
        CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
        InspIdList.add(inspectionrecord.Id);
        
        proglist=[select id,name,CLQ_Last_Inspection_Date__c,(select id,CLQ_Last_Visit_Date__c from Inspections__r) from CLQ_Program__c where Id in (:programRecord1.Id,:programRecord.Id)];
        
        test.startTest();
        CLQ_UpdateProgramInspectionDate.updateProgramsFromProgramList(proglist);
        CLQ_UpdateProgramInspectionDate.updateProgramsFromProgramList(proglist1);
        CLQ_UpdateProgramInspectionDate.updatePro(InspIdList);
        test.stopTest();
   
        
    }
}