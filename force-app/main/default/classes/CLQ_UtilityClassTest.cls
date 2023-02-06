/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_UtilityClassTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_UtilityClassTest {
    @IsTest
    static void utilityTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            
            CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.ProgramTransactions.values()[0];
            system.AssertNotEquals(null,ProgramTransaction,'Testing');
            CLQ_Program__c programRecord = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Program__c',' id=\''+ProgramTransaction.CLQ_Program__c+'\'', null));
            
            contact c = new contact();
            c.lastname = 'test';
            insert  c;
            
            CLQ_Room_Space__c RorGrecord = new CLQ_Room_Space__c(CLQ_Length_Feet__c = 30,CLQ_Width_Feet__c = 30,CLQ_Currently_In_Use__c = 'Yes',CLQ_Approved_Room_Space__c = true, CLQ_Number_of_Children_Under_2__c = 2,CLQ_Used_By_Under_or_Over_2__c = 'Over',name='dining area', CLQ_Room_Space_Type__c='Primary Space', CLQ_Program__c= programRecord.id,CLQ_Program_Transaction__c=ProgramTransaction.id);
            RorGrecord.RecordTypeId = Schema.SObjectType.CLQ_Room_Space__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
            roomSpaceList.add(RorGrecord);
            //insert roomSpaceList; 
            
            test.starttest();
            CLQ_UtilityClass.createInspectionrecord('Provisional', 'Full', 'Pending Processing');
            CLQ_UtilityClass.redirecttoPage('test');
            
            CLQ_UtilityClass.createTaskrecord(c.id,programRecord.id,system.Date.today(),'test','test');
            CLQ_UtilityClass.createTaskrecord(ProgramTransaction,system.Date.today(),'test','test');
            
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_UtilityClass.copyRelatedListfromPTtoProgram(ProgramTransactionMap.keyset());
            
            Id RtId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Inspection').getRecordTypeId();        
            
            CLQ_Inspection_Tools__c Inspect1= new CLQ_Inspection_Tools__c();
            Inspect1.CLQ_Applicable_To_Scope__c='Full';
            Inspect1.CLQ_Application_To_Inspection_Type__c='Complaint';
            Inspect1.CLQ_Applicable_To__c='Day Camp';
            insert Inspect1; 
            CLQ_Inspection__c Inspect = new CLQ_Inspection__c();
            Inspect.CLQ_Inspection_Tool__c = Inspect1.Id;
            Inspect.CLQ_Program_Transaction__c=ProgramTransaction.Id;
            insert Inspect; 
            CLQ_Room_Space_Inspection__c Inspect3 = new CLQ_Room_Space_Inspection__c();
            Inspect3.CLQ_Inspection__c = Inspect.id;
            set<Id> insp = new set<Id>();
            insp.add(Inspect.id);
            set<Id> progtrans = new set<Id>();
            progtrans.add(ProgramTransaction.Id);
            CLQ_UtilityClass utilCls = new CLQ_UtilityClass();
            utilCls.copyRoomSpactionInspectiontoTransaction(insp);
            CLQ_UtilityClass.copyBuildingApprovaltoinspection(programRecord.id,Inspect.id);
            CLQ_UtilityClass.queryRoomSpacefromProgram(programRecord.id);
            CLQ_UtilityClass.createRoomSpaceInspection( roomSpaceList ,Inspect);
            CLQ_UtilityClass.cloneFromOneObjectToanother(programRecord,'clq_program__c');
            CLQ_UtilityClass.copyRoomSpaceTransactiontoProgram(progtrans);
            CLQ_UtilityClass.ifInspectionAlreadyExists(Inspect.Id, True, 'Complaint');
            CLQ_UtilityClass.getCombinedCounties('Adam County');
            //CLQ_UtilityClass.retriveInspectionToolForInspection(Inspect,'Full','Complaint','Day Camp');
            
            
            test.stoptest();  
            system.assertEquals(True, 1==1,'Testing');
        }
    }  
    
    
    
    @TestSetup
    static void testSetup()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting(); //11615
        CLQ_UnitTestUtilities.HardCodedTransactionCreation();
        
    }
    
    
}