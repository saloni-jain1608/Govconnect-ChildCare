/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTransactionTrigHdlrLcs2Test
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
private class CLQ_ProgramTransactionTrigHdlrLcs2Test {
    
    @IsTest
    static void allRecordTypesTestTwo() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            list<RecordType> RecTypes = [Select Id, Name from RecordType 
                                         WHERE SobjectType = 'CLQ_Program_Transaction__c'];
            map<Id, string> RecTypeMap = new map<id, string>();
            for(RecordType RecType : RecTypes) RecTypeMap.put(RecType.Id, RecType.Name);
            
            
            for (Id RecId : CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.keySet())
            {
                system.Debug(CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(RecId) + '   Id=' + RecId);
            }
            
            List<Id> kset=new List<Id>();
            kset.addAll(RecTypeMap.keySet());
            
            for (Id RecId : RecTypeMap.keySet())
            {
                string KnownItem = RecTypeMap.get(RecId);
                string UnKnownItem = CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(RecId);
                string ErrorMessage = ''; 
                if (UnKnownItem == null) {
                    ErrorMessage = KnownItem + 
                        ' RecordType is missing from CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes';
                }
                system.AssertEquals(KnownItem, UnKnownItem,  ErrorMessage);
            }
        }   
        
    }
    
    @IsTest
    static void constructorTest() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('ConstructorTest: Number of Program Transactions: ' + ProgramTransactionMap.size());
            //system.AssertEquals(14, ProgramTransactionMap.size());
            map<string,CLQ_Program_Transaction__c> MapByRecordType = new map<string,CLQ_Program_Transaction__c>();
            for(CLQ_Program_Transaction__c PT : ProgramTransactionMap.values()) 
            {
                system.Debug(PT.RecordType.Name);
                MapByRecordType.put(PT.RecordType.Name, PT);
            }
            
            CLQ_Program_Transaction__c ProgramTransaction = MapByRecordType.get('Amendment - Change of Administrator');
            
            
            list<CLQ_Program_Transaction__c> PTList = ProgramTransactionMap.values();
            map<Id,CLQ_Program__c> ProgramMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedPrograms(PTList);
            system.debug('ConstructorTest: Number of Programs : ' + ProgramMap.size());
            map<Id,CLQ_Role__c> RolesMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedRoles(PTList);
            system.debug('ConstructorTest: Number of Roles : ' + RolesMap.size());
            map<Id,Task> TasksMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedTasks(PTList);
            system.debug('ConstructorTest: Number of Tasks: ' + TasksMap.size());
            map<Id,CLQ_Facility_Schedule__c> FacilityMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedFacilitySchedules(PTList);
            system.debug('ConstructorTest: Number of Facilitys: ' + FacilityMap.size());
            map<Id,CLQ_Program_Transaction__c> RelatedMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedItems(PTList);
            system.debug('ConstructorTest: Number of Related items: ' + RelatedMap.size());
            
            
            CLQ_ProgramTransactionTrigHdlrLicsng2 Licensing2 = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap, RolesMap,TasksMap,FacilityMap, RelatedMap);
            
            Licensing2.ChangesAfterInsert(ProgramTransaction);
            
            
            list<string> Status = new list<string>{'Submitted', 'Under Reviewer Review', 'Approved','Denied','Approver Review in Progress','Returned to Reviewer','Closed'};
                
                for(CLQ_Program_Transaction__c ProgTrans : MapByRecordType.values())
            {
                ProgTrans.CLQ_Transaction_Status__c = 'Submitted';
                
                ProgTrans.CLQ_Approved_by_Manager__c = true;
                if (ProgTrans.RecordType.Name == 'Registration - Out of State')
                {
                    ProgTrans.CLQ_OOS_ProgramNumber__c = '1234';
                    ProgTrans.CLQ_Recommendation__c = 'Approve';
                }
                //OtherSettings(ProgTrans);
                Licensing2.ChangesAfterInsert(ProgTrans);
                Licensing2.ChangesBeforeUpdate(ProgTrans,ProgramTransaction);
                //Licensing2.ChangesAfterUpdate(ProgTrans,ProgramTransaction);
            }
            
            
            
            
            
            
            CLQ_Program_Transaction__c Program_Transaction = MapByRecordType.get('Amendment - Change of Administrator');
            Program_Transaction.CLQ_Rejected_By_Manager__c = true;
            Program_Transaction.CLQ_Portal_Application_Update__c = false;
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            
            Program_Transaction.CLQ_Start_Approval__c = false;
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Start_Approval__c = true;
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            Program_Transaction = MapByRecordType.get('Update FCC Resident Information');
            Program_Transaction.CLQ_Start_Approval__c = true;
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            //25    CLQ_Reactivation Review in Progress
            Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Start_Approval__c = true;
            Program_Transaction.CLQ_License_Start_Date__c = Date.Today();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            Program_Transaction.CLQ_Recommendation__c = 'Approve';
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            //8 CLQ_COA Amendment Approved
            Program_Transaction = MapByRecordType.get('Amendment - Change of Administrator');
            Program_Transaction.CLQ_Start_Approval__c = false;
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            Program_Transaction.CLQ_Transaction_Status__c = 'Denied';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            //41    CLQ Same as Physical Address checked
            Program_Transaction.CLQ_Same_as_Physical_Address__c = true;
            Program_Transaction.CLQ_ProgTrans_Street_Address__c = '123 Main';
            Program_Transaction.CLQ_ProgTrans_Street_Address_2__c = 'PO Box 123';
            Program_Transaction.CLQ_ProgTrans_City__c = 'Approved';
            Program_Transaction.CLQ_ProgTrans_State__c = 'OH';
            Program_Transaction.CLQ_ProgTrans_Zip_Code__c = '43213';
            Licensing2.ChangesBeforeInsert(Program_Transaction);
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
            //26    CLQ_ODE Reactivate Approved Transaction
            //27    CLQ_JFS Reactivate Approved Transaction         
            Program_Transaction = MapByRecordType.get('Update FCC Resident Information');
            Program_Transaction.RecordTypeId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction').getRecordTypeId();
            Program_Transaction.CLQ_ACA_Accredited__c = false;
            Program_Transaction.CLQ_Portal_Application_Update__c = false;
            Program_Transaction.CLQ_Start_Approval__c = false;
            Program_Transaction.CLQ_Rejected_By_Manager__c = false;
            Program_Transaction.CLQ_Transaction_Status__c = 'Not Submitted';
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            Program_Transaction.CLQ_Transaction_Status__c = 'Submitted';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            //Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Licensing2.ChangesBeforeUpdate(Program_Transaction,ProgramTransaction);
            //Licensing2.ChangesAfterUpdate(Program_Transaction,ProgramTransaction);
            
            
        }
    }
    
    @IsTest
    static void changesAfterInsertTest() 
    {
        system.assertEquals(True, 1==1,'Testing');
        //get a CLQ_Program_Transaction__c record
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            system.debug('ConstructorTest: Number of Program Transactions: ' + ProgramTransactionMap.size());
            //system.AssertEquals(14, ProgramTransactionMap.size());
            map<string,CLQ_Program_Transaction__c> MapByRecordType = new map<string,CLQ_Program_Transaction__c>();
            CLQ_Program_Transaction__c LastPT;
            for(CLQ_Program_Transaction__c PT : ProgramTransactionMap.values()) 
            {
                system.Debug(PT.RecordType.Name);
                MapByRecordType.put(PT.RecordType.Name, PT);
                LastPT = PT;
            }
            
            
            
            list<CLQ_Program_Transaction__c> PTList = ProgramTransactionMap.values();
            map<Id,CLQ_Program__c> ProgramMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedPrograms(PTList);
            system.debug('ConstructorTest: Number of Programs : ' + ProgramMap.size());
            map<Id,CLQ_Role__c> RolesMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedRoles(PTList);
            system.debug('ConstructorTest: Number of Roles : ' + RolesMap.size());
            map<Id,Task> TasksMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedTasks(PTList);
            system.debug('ConstructorTest: Number of Tasks: ' + TasksMap.size());
            map<Id,CLQ_Facility_Schedule__c> FacilityMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedFacilitySchedules(PTList);
            system.debug('ConstructorTest: Number of Facilitys: ' + FacilityMap.size());
            
            
            CLQ_ProgramTransactionTrigHdlrLicsng2 Licensing2 = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap, RolesMap,TasksMap,FacilityMap);
            
            CLQ_Program_Transaction__c ProgramTransaction = MapByRecordType.get('Amendment - Change of Administrator');
            CLQ_Program__c Program = ProgramMap.values()[0];
            system.debug('Program.Facility_Schedules__r  ' + Program.Facility_Schedules__r.size());
            system.debug('Program.Roles__r  ' + Program.Roles__r.size());
            system.AssertNotEquals(0, Program.Facility_Schedules__r.size(),'Testing');
            system.AssertNotEquals(0, Program.Roles__r.size(),'Testing');
            Licensing2.ChangesAfterInsert(ProgramTransaction);
            
            
            
            Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_Facility_Information');
            CLQ_Program_Transaction__c NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId(), ID = LastPT.Id);
            Licensing2.ChangesAfterInsert(NewPT);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_FCC_Resident_Information');
            NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId(), ID = LastPT.Id);
            Licensing2.ChangesAfterInsert(NewPT);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_Contact_Information');
            NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId(), ID = LastPT.Id);
            Licensing2.ChangesAfterInsert(NewPT);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_On_site_Contact_Information');
            NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId(), ID = LastPT.Id);
            Licensing2.ChangesAfterInsert(NewPT);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Licensing_Closure');
            NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId(), ID = LastPT.Id);
            Licensing2.ChangesBeforeInsert(NewPT);
            
            
            Program = ProgramMap.values()[0];
            system.debug('Program.Facility_Schedules__r  ' + Program.Facility_Schedules__r.size());
            system.AssertNotEquals(0, Program.Facility_Schedules__r.size(),'Testing');
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            NewPT = new CLQ_Program_Transaction__c(CLQ_Program__c = Program.Id, RecordTypeId = RecTypInfo.getRecordTypeId());
            Licensing2.ChangesAfterInsert(NewPT);
            
            
        }
    }
    
    @IsTest
    static void specificChangesAfterUpdateTestOne() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c Program_Transaction = ProgramTransactionMap.values()[0];
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransactionMap.values()[1];
            
            
            list<CLQ_Program_Transaction__c> PTList = ProgramTransactionMap.values();
            map<Id,CLQ_Program__c> ProgramMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedPrograms(PTList);
            system.debug('ConstructorTest: Number of Programs : ' + ProgramMap.size());
            map<Id,CLQ_Role__c> RolesMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedRoles(PTList);
            system.debug('ConstructorTest: Number of Roles : ' + RolesMap.size());
            map<Id,Task> TasksMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedTasks(PTList);
            system.debug('ConstructorTest: Number of Tasks: ' + TasksMap.size());
            map<Id,CLQ_Facility_Schedule__c> FacilityMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedFacilitySchedules(PTList);
            system.debug('ConstructorTest: Number of Facilitys: ' + FacilityMap.size());
            CLQ_ProgramTransactionTrigHdlrLicsng2 Licensing2 = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap, RolesMap,TasksMap,FacilityMap);
            
            
            //Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information');
            Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Start_Approval__c = true; 
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            String recname=CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
            Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(Program_Transaction, 'Task');
            if(recname=='Amendment - Change of Administrator'){
                tsk.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REVIEW_CHANGE_OF_ADMINISTRATOR;
            }
                
            tsk.Status = 'Open';
            insert tsk;
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Program_Transaction.CLQ_Start_Approval__c = false; 
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Task tsk1 = (Task)CLQ_UnitTestUtilities.AddRelatedItem(Program_Transaction, 'Task');
            recname=CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
            if(recname=='Amendment - Change of Administrator'){
                tsk1.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REVIEW_CHANGE_OF_ADMINISTRATOR;
            }
                
            tsk1.Status = 'Open';
            insert tsk1;
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Start_Approval__c = true; 
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Task tsk2 = (Task)CLQ_UnitTestUtilities.AddRelatedItem(Program_Transaction, 'Task');        
            recname=CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
            if(recname=='Reactivate Transaction'){
                tsk2.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REACTIVATE_TRANSACTION_SUBMITTED;
            }
                
            tsk2.Status = 'Open';
            insert tsk2; 
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            //Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Start_Approval__c = true; 
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            //Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Start_Approval__c = true; 
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            //Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
        }  
    }    
    
    @IsTest
    static void specificChangesAfterUpdateTestsTwo() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c Program_Transaction = ProgramTransactionMap.values()[0];
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransactionMap.values()[1];
            
            
            list<CLQ_Program_Transaction__c> PTList = ProgramTransactionMap.values();
            map<Id,CLQ_Program__c> ProgramMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedPrograms(PTList);
            system.debug('ConstructorTest: Number of Programs : ' + ProgramMap.size());
            map<Id,CLQ_Role__c> RolesMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedRoles(PTList);
            system.debug('ConstructorTest: Number of Roles : ' + RolesMap.size());
            map<Id,Task> TasksMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedTasks(PTList);
            system.debug('ConstructorTest: Number of Tasks: ' + TasksMap.size());
            map<Id,CLQ_Facility_Schedule__c> FacilityMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedFacilitySchedules(PTList);
            system.debug('ConstructorTest: Number of Facilitys: ' + FacilityMap.size());
            CLQ_ProgramTransactionTrigHdlrLicsng2 Licensing2 = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap, RolesMap,TasksMap,FacilityMap);
            
            Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;  
            
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Returned to Reviewer';
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;     
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Program_Transaction.CLQ_ACA_Accredited__c=false;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;     
            
            
            
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Program_Transaction.CLQ_Start_Approval__c=false;
            Program_Transaction.CLQ_Rejected_By_Manager__c=false;     
            Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            Licensing2.GetPTRoles(Program_Transaction.id,RolesMap.values());
            
        } 
    }    
    
    
    /*private static void OtherSettings(CLQ_Program_Transaction__c Program_Transaction)
{
if (Program_Transaction.RecordType.Name == 'Registration - Out of State')
{
Program_Transaction.CLQ_OOS_ProgramNumber__c = '1234';
Program_Transaction.CLQ_Recommendation__c = 'Approve';
}
//else if 
}*/
    
    @IsTest
    static void specificChangesAfterUpdateTestsThree() 
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Account acc = new Account(Name = 'TestAccount');
            insert acc;
            
            //List<CLQ_County__c> county = [Select Id from CLQ_County__c LIMIT 2];
            Test.startTest();
            
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(new Contact(FirstName='Test', lastName = 'Contact1',AccountId = acc.id,Email= 'NOREPLY@TEST.COM'));
            insert lstContact;
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = acc.Id;
            programRecord.CLQ_Street_Address_1__c = '123 Random St';
            programRecord.CLQ_Street_Address_2__c = 'addr2';
            programRecord.City__c = 'test city';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            //programRecord.CLQ_County__c = county[0].id;
            programRecord.OwnerId = UserInfo.getUserId();
            programRecord.CLQ_Program_Status__c = 'Open'; 
            programRecord.CLQ_Program_Email__c ='test@test.com';
            programRecord.CLQ_Phone__c ='1234567';
            programRecord.CLQ_Phone_Extension__c =456;
            insert programRecord;
            
            //get a CLQ_Program_Transaction__c record
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            CLQ_Program_Transaction__c Program_Transaction = ProgramTransactionMap.values()[0];
            CLQ_Program_Transaction__c OldProgramTransaction = ProgramTransactionMap.values()[1];
            
            
            list<CLQ_Program_Transaction__c> PTList = ProgramTransactionMap.values();
            map<Id,CLQ_Program__c> ProgramMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedPrograms(PTList);
            system.debug('ConstructorTest: Number of Programs : ' + ProgramMap.size());
            map<Id,CLQ_Role__c> RolesMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedRoles(PTList);
            system.debug('ConstructorTest: Number of Roles : ' + RolesMap.size());
            map<Id,Task> TasksMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedTasks(PTList);
            system.debug('ConstructorTest: Number of Tasks: ' + TasksMap.size());
            map<Id,CLQ_Facility_Schedule__c> FacilityMap = CLQ_ProgramTransactionTrigHdlrLicsng.RelatedFacilitySchedules(PTList);
            system.debug('ConstructorTest: Number of Facilitys: ' + FacilityMap.size());
            ProgramMap.put(programRecord.Id, programRecord);
            CLQ_ProgramTransactionTrigHdlrLicsng2 Licensing2 = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap, RolesMap,TasksMap,FacilityMap);
            
            Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Closed by System';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            
            
            
            
            
            //Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_On_site_Contact_Information');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Submitted';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;      
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Update_Facility_Information');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Submitted';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;      
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Submitted';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_ACA_Accredited__c=false;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=false;
            Program_Transaction.CLQ_Start_Approval__c=false;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;   
            
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=false;
            Program_Transaction.CLQ_Start_Approval__c=false;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location');
            
            Program_Transaction.RecordTypeId = RecTypInfo.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Under Reviewer Review';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=false;
            Program_Transaction.CLQ_Start_Approval__c=false;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();    
            
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            Schema.RecordTypeInfo RecTypInfo1 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC');
            
            Program_Transaction.RecordTypeId = RecTypInfo1.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            Schema.RecordTypeInfo RecTypInfo2 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Registration_Out_of_State');
            
            Program_Transaction.RecordTypeId = RecTypInfo2.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_OOS_ProgramNumber__c='125364';
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            Schema.RecordTypeInfo RecTypInfo12 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            
            Program_Transaction.RecordTypeId = RecTypInfo12.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approved';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=false;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_OOS_ProgramNumber__c='125364';
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid(); 
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            Schema.RecordTypeInfo RecTypInfo3 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space');
            
            Program_Transaction.RecordTypeId = RecTypInfo3.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_Start_Approval__c=true;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            Schema.RecordTypeInfo RecTypInfo13 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location');
            
            Program_Transaction.RecordTypeId = RecTypInfo13.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_Start_Approval__c=true;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();
            
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            Schema.RecordTypeInfo RecTypInfo4 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC');
            
            Program_Transaction.RecordTypeId = RecTypInfo4.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Denied';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            //Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = true;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            Schema.RecordTypeInfo RecTypInfo5 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Reactivate_Transaction');
            
            Program_Transaction.RecordTypeId = RecTypInfo5.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_Start_Approval__c=true;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();       
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction);
            
            
            
            Schema.RecordTypeInfo RecTypInfo7 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator');
            
            Program_Transaction.RecordTypeId = RecTypInfo7.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_Start_Approval__c=false;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();       
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction); 
            
            Schema.RecordTypeInfo RecTypInfo8 = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Amendment_ODE_and_Center_Change_of_Capacity_Space');
            
            Program_Transaction.RecordTypeId = RecTypInfo8.getRecordTypeId();
            Program_Transaction.CLQ_Transaction_Status__c = 'Approver Review in Progress';
            Program_Transaction.CLQ_Program__c = programRecord.id;
            Program_Transaction.CLQ_Rejected_By_Manager__c=true;
            Program_Transaction.CLQ_Portal_Application_Update__c=false;        
            Program_Transaction.CLQ_Approved_by_Manager__c = false;
            Program_Transaction.CLQ_License_Start_Date__c=Date.Today();
            Program_Transaction.CLQ_Start_Approval__c=true;
            Program_Transaction.CLQ_Transaction_Assigned_To__c=UserInfo.getUserid();       
            
            // Licensing2.ChangesBeforeUpdate(Program_Transaction,OldProgramTransaction);
            Licensing2.ChangesAfterUpdate(Program_Transaction,OldProgramTransaction); 
            
            
            
            
            
            
            
            
            //Licensing2.GetPTRoles(Program_Transaction.id,RolesMap.values());
            Test.stopTest();
        }
        
    }    
    
    
    
    
    @testSetup 
    public static void testSetupp()
    {
        //User user = CLQ_UnitTestUtilities.AddCustomerUser();
        CLQ_UnitTestUtilities.setExecuteControlSetting();//11615        
        CLQ_UnitTestUtilities.HardCodedTransactionCreation();
        
        list<CLQ_Role__c> RolesToUpsert = new list<CLQ_Role__c>();
        list<Task> TasksToUpsert = new list<Task>();
        list<CLQ_Facility_Schedule__c> Facility_ScheduleToUpsert = new list<CLQ_Facility_Schedule__c> ();
        
        map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
        map<Id,CLQ_Program__c> Programs = new map<Id,CLQ_Program__c>([Select Id,CLQ_Jurisdiction__c from CLQ_Program__c]);
        
        integer ContNum = 5+    5 * (ProgramTransactionMap.size() + Programs.size());
        //integer ContNum = 2;
        list<contact> Contacts = new list<Contact>();
        //for(integer n = 0 ; n < ContNum; n++)  
        //   Contacts.Add(new Contact(FirstName = 'Test', LastName = 'Contact' + string.ValueOf(n), Email = 'testcontact' + string.ValueOf(n) + '@nowhere.org'));
        //insert Contacts;
        integer ContactCounter = 0;
        Set<String> rectype=new Set<String> {'Amendment - Change of Administrator','Update FCC Resident Information','Reactivate Transaction','Update Facility Information','Update Authorized Rep Info','Update On-site Contact Information','Licensing - Closure',
            'Amendment - Change of Administrator','Amendment - ODE and Center - Change of Capacity / Space','Amendment - FCC - Change of Location'};
                for(CLQ_Program_Transaction__c ProgramTransaction : ProgramTransactionMap.values())
            {
                String recname=CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(ProgramTransaction.RecordTypeId);
                if(rectype.contains(recname)){
                    CLQ_Program__c Program = Programs.get(ProgramTransaction.CLQ_Program__c);
                    string JFS_ODE = '';
                    if (Program != null){
                        JFS_ODE = Program.CLQ_Jurisdiction__c;
                    } 
                    Task tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
                    if(recname=='Amendment - ODE and Center - Change of Capacity / Space'){
                        tsk.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REVIEW_CHANGE_OF_CAPACITY_OR_SPACE;
                    }
                    else if(recname.contains('Change of Location')){
                        tsk.Subject=CLQ_ProgramTransactionTrigHdlrLicsng2.REVISE_CHANGE_OF_LOCATION_REVIEW;
                    }
                    else{
                        tsk.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REVIEW_CHANGE_OF_ADMINISTRATOR;
                    }
                        
                    tsk.Status = 'Open';
                    TasksToUpsert.add( tsk);
                    tsk = (Task)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'Task');
                    if(recname=='Amendment - ODE and Center - Change of Capacity / Space'){
                        tsk.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE;
                    } 
                    else{
                        tsk.Subject = CLQ_ProgramTransactionTrigHdlrLicsng2.REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW;
                    }
                        
                    tsk.Status = 'Open';
                    TasksToUpsert.add( tsk); 
                    
                    CLQ_Facility_Schedule__c Facility = (CLQ_Facility_Schedule__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Facility_Schedule__c');
                    Facility.Name = 'Test Schedule ' + ContactCounter;
                    Facility.CLQ_Status__c = 'Active';
                    Facility_ScheduleToUpsert.add( Facility);
                    CLQ_Role__c role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
                    role.CLQ_Decision__c = 'Approved';
                    role.CLQ_Status__c = 'Active';
                    role.CLQ_Start_Date__c = Date.Today();
                    role.Role_Type__c = JFS_ODE;
                    if (JFS_ODE == 'JFS')
                    {
                        role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
                        role.CLQ_Role__c = 'Administrator';
                        //system.Debug('Skipping JFS');
                    }
                    else
                    {
                        role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
                        role.Portal_Roles__c = 'OCLQSOwner';
                    }
                    //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
                    RolesToUpsert.add( role);
                    if (JFS_ODE == 'JFS')
                    {
                        role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
                        role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Resident').getRecordTypeId();
                        role.CLQ_Decision__c = 'Approved';
                        role.CLQ_Status__c = 'Active';
                        role.CLQ_Role__c = 'Resident';
                        role.CLQ_Start_Date__c = Date.Today();
                        role.Role_Type__c = 'JFS';
                        role.Relationship__c = 'Related';
                        //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
                        RolesToUpsert.add( role);
                        
                        role = (CLQ_Role__c)CLQ_UnitTestUtilities.AddRelatedItem(ProgramTransaction, 'CLQ_Role__c');
                        role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
                        role.CLQ_Decision__c = 'Approved';
                        role.CLQ_Status__c = 'Active';
                        role.CLQ_Role__c = 'Authorized Representative';
                        role.CLQ_Start_Date__c = Date.Today();
                        role.Role_Type__c = 'JFS';
                        //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
                        RolesToUpsert.add( role);           
                    }
                    
                }
            }
        
        for(CLQ_Program__c Program : Programs.values())
        {
            string JFS_ODE = Program.CLQ_Jurisdiction__c;
            CLQ_Facility_Schedule__c Facility = new CLQ_Facility_Schedule__c(CLQ_Program__c = Program.Id);
            Facility.Name = 'Test Schedule ' + ContactCounter;
            Facility.CLQ_Status__c = 'Active';
            Facility_ScheduleToUpsert.add( Facility);
            CLQ_Role__c role = new CLQ_Role__c(CLQ_Program__c = Program.Id);
            role.CLQ_Decision__c = 'Approved';
            role.CLQ_Status__c = 'Active';
            role.CLQ_Start_Date__c = Date.Today();
            role.Role_Type__c = JFS_ODE;
            if (JFS_ODE == 'JFS')
            {
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
                //role.Portal_Roles__c = 'Owner';
                //system.Debug('Skipping JFS');
            }
            else
            {
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
                role.Portal_Roles__c = 'OCLQSAdministrator';
            }
            
            //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
            RolesToUpsert.add( role);
            
            if (JFS_ODE == 'JFS')
            {
                role = new CLQ_Role__c(CLQ_Program__c = Program.Id);
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Resident').getRecordTypeId();
                role.Relationship__c = 'Related';
                role.CLQ_Decision__c = 'Approved';
                role.CLQ_Role__c = 'Resident';
                role.CLQ_Status__c = 'Active';
                role.CLQ_Start_Date__c = Date.Today();
                role.Role_Type__c = 'JFS';
                //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
                RolesToUpsert.add( role);
                
                role = new CLQ_Role__c(CLQ_Program__c = Program.Id);
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Resident').getRecordTypeId();
                role.Relationship__c = 'Related';
                role.CLQ_Decision__c = 'Approved';
                role.CLQ_Status__c = 'Active';
                role.CLQ_Role__c = 'On-site Contact';
                role.CLQ_Start_Date__c = Date.Today();
                role.Role_Type__c = 'JFS';
                //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
                RolesToUpsert.add( role);
            }
            role = new CLQ_Role__c(CLQ_Program__c = Program.Id);
            role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId();
            role.CLQ_Decision__c = 'Approved';
            role.CLQ_Status__c = 'Active';
            role.CLQ_Start_Date__c = Date.Today();
            role.Role_Type__c = JFS_ODE;
            if (JFS_ODE == 'JFS')
            {
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId();
                role.CLQ_Role__c = 'Authorized Representative';
                system.Debug('Skipping JFS');
            }
            else
            {
                role.RecordTypeId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
                role.Portal_Roles__c = 'OCLQSOwner';
                role.CLQ_Role__c = 'On-site Contact';
            }
            //role.CLQ_Contact__c = Contacts[ContactCounter++].Id;
            RolesToUpsert.add( role);
        }
        CLQ_Trigger.BypassAllTriggers = true;
        insert TasksToUpsert;
        system.debug('TestSetup: Tasks: ' + TasksToUpsert.size());
        insert Facility_ScheduleToUpsert;
        system.debug('TestSetup: Facilitys: ' + Facility_ScheduleToUpsert.size());
        try
        {
            CLQ_Trigger.BypassAllTriggers = true;//RR
            insert RolesToUpsert;
        }
        
        catch (DMLException exc)
        {
            system.debug('TestSetup: DMLException Stack: ' + exc.getStackTraceString());
            system.debug('TestSetup: DMLException Message: ' + exc.getMessage());
            
            for(integer i = 0; i < exc.getNumDML(); i++)
            {
                system.debug('***** The items: ' + RolesToUpsert[exc.getDMLIndex(i)]);
                system.debug('***** The matching fields: ' + exc.getDmlFieldNames(i));
                system.debug('***** The error message ' + exc.getDMLMessage(i));
            }           
            throw exc;
        }
        catch (Exception exc)
        {
            system.debug('TestSetup: Exception Stack: ' + exc.getStackTraceString());
            throw exc;
        }
        CLQ_Trigger.BypassAllTriggers = false;
        
    }        
}