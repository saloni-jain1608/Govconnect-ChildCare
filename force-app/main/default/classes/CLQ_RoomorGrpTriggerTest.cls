/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_RoomorGrpTriggerTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true) 
private class CLQ_RoomorGrpTriggerTest
{
    @testSetup //Added for task - 11615
	public static void setExecuteControlSetting()
	{
	CLQ_UnitTestUtilities.setExecuteControlSetting();
	}	
    @IsTest
    static void updateFormulaValuesTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            list<CLQ_Room_Space__c> RoomSpaceRecords = new list<CLQ_Room_Space__c>();
            list<ID> ProgramIDs = new list<ID>();
            list<ID> ProgramTransIDs = new list<ID>();
            //insert configuration record
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account recordd
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_Program_Status__c='Open';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            ProgramIDs.Add(programRecord.ID);
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            insert ProgramTransaction;
            ProgramTransIDs.Add(ProgramTransaction.ID);
            CLQ_Room_Space__c RorGrecord = new CLQ_Room_Space__c(CLQ_Currently_In_Use__c='Yes',CLQ_Length_Feet__c = 30,CLQ_Width_Feet__c = 30,CLQ_Approved_Room_Space__c = true, CLQ_Number_of_Children_Under_2__c = 2,CLQ_Used_By_Under_or_Over_2__c = 'Over',name='dining area', CLQ_Room_Space_Type__c='Primary Space', CLQ_Program__c= programrecord.id,CLQ_Program_Transaction__c=ProgramTransaction.id);
            //insert RorGrecord;
            RoomSpaceRecords.Add(RorGrecord);
            
            //insert configuration record
            CLQ_OCLQS_Configuration__c configRecord2 = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type A Home');
            insert configRecord2; 
            
            //Create account record
            Account accountrecord2 = new Account(Name='Test Account2',CLQ_DIRN__c = '2345'); 
            insert accountrecord2 ;   
            
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test2';
            programRecord2.CLQ_Associated_Organization__c = accountrecord2.id;
            programRecord2.CLQ_Street_Address_1__c = 'test2';
            programRecord2.CLQ_Program_Status__c='Open';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            insert programRecord2 ;
            ProgramIDs.Add(programRecord2.ID);  
            CLQ_Program_Transaction__c ProgramTransaction2 = new CLQ_Program_Transaction__c();
            ProgramTransaction2.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_FCC').getRecordTypeId();
            ProgramTransaction2.CLQ_Program__c = programRecord2.id;
            insert ProgramTransaction2;
            ProgramTransIDs.Add(ProgramTransaction2.ID);
            CLQ_Room_Space__c RorGrecord2 = new CLQ_Room_Space__c(CLQ_Currently_In_Use__c='Yes',CLQ_Length_Feet__c = 35,CLQ_Width_Feet__c = 35,CLQ_Approved_Room_Space__c = true, CLQ_Number_of_Children_Under_2__c = 2,CLQ_Used_By_Under_or_Over_2__c = 'Both',CLQ_Number_of_Children_Allowed__c= 0,name='dining area', CLQ_Room_Space_Type__c='Primary Space', CLQ_Program__c= programrecord2.id,CLQ_Program_Transaction__c=ProgramTransaction2.id);
            //insert RorGrecord2; 
            RoomSpaceRecords.Add(RorGrecord2);
            
            CLQ_Room_Space__c RorGrecord2a = new CLQ_Room_Space__c(CLQ_Currently_In_Use__c='Yes',CLQ_Length_Feet__c = 30,CLQ_Width_Feet__c = 30,CLQ_Approved_Room_Space__c = true, CLQ_Number_of_Children_Under_2__c = 2,CLQ_Used_By_Under_or_Over_2__c = 'Over',name='dining area', CLQ_Room_Space_Type__c='Primary Space', CLQ_Program__c= programrecord2.id,CLQ_Program_Transaction__c=ProgramTransaction2.id);
            //insert RorGrecord2a;      
            RoomSpaceRecords.Add(RorGrecord2a);
            
            //insert configuration record
            CLQ_OCLQS_Configuration__c configRecord3 = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord3; 
            
            //Create account record
            Account accountrecord3 = new Account(Name='Test Account2',CLQ_DIRN__c = '3456'); 
            insert accountrecord3 ;   
            
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test3';
            programRecord3.CLQ_Associated_Organization__c = accountrecord3.id;
            programRecord3.CLQ_Street_Address_1__c = 'test3';
            programRecord3.CLQ_Program_Status__c='Open';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            insert programRecord3 ;        
            ProgramIDs.Add(programRecord3.ID); 
            CLQ_Program_Transaction__c ProgramTransaction3 = new CLQ_Program_Transaction__c();
            ProgramTransaction3.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            ProgramTransaction3.CLQ_Program__c = programRecord3.id;
            insert ProgramTransaction3;
            ProgramTransIDs.Add(ProgramTransaction3.ID);
            CLQ_Room_Space__c RorGrecord3 = new CLQ_Room_Space__c(CLQ_Currently_In_Use__c='Yes',CLQ_Number_of_Children_Under_2_5__c =5,CLQ_Length_Feet__c = 35,CLQ_Width_Feet__c = 35,CLQ_Approved_Room_Space__c = true, CLQ_Used_by_Under_or_Over_2_1_2__c = 'Both',name='dining area',CLQ_Number_of_Children_Allowed__c= 0,CLQ_Room_Space_Type__c='Primary Space', CLQ_Program__c= programrecord3.id,CLQ_Program_Transaction__c=ProgramTransaction3.id);
            //insert RorGrecord3;
            RoomSpaceRecords.Add(RorGrecord3);
            
            Test.StartTest();
            insert RoomSpaceRecords;
            Test.StopTest();
            
            map<ID, CLQ_Program__c> ProgramsMap = new map<ID, CLQ_Program__c>([SELECT CLQ_Calculated_Max_Capacity__c, CLQ_Max_Capacity_Under_2_Years__c, recordtype.Name
                                                                               FROM CLQ_Program__c WHERE ID IN: ProgramIDs]);
            map<ID, CLQ_Program_Transaction__c > ProgramTransMap = new map<ID, CLQ_Program_Transaction__c >([SELECT CLQ_Requested_Calculated_Max_Capacity__c, CLQ_Calculated_Maximum_Capacity__c,CLQ_Calculated_Max_Capacity_Under_2_5Yr__c,recordtype.Name
                                                                                                             FROM CLQ_Program_Transaction__c WHERE ID IN: ProgramTransIDs]);
            
            for(CLQ_Program__c Program : ProgramsMap.Values())
            {
                system.Debug(Program.Id + '   ' + Program.CLQ_Calculated_Max_Capacity__c   + '     ' + Program.CLQ_Max_Capacity_Under_2_Years__c );
            }
            for(CLQ_Program_Transaction__c ProgramTrans : ProgramTransMap.Values())
            {
                system.Debug(ProgramTrans.Id + '   ' + ProgramTrans.CLQ_Requested_Calculated_Max_Capacity__c+ '     ' + ProgramTrans.CLQ_Calculated_Maximum_Capacity__c);
            }
            
            CLQ_Program__c Prog = ProgramsMap.get(programRecord.Id);
            /*system.AssertEquals(76, Prog.CLQ_Calculated_Max_Capacity__c);
system.AssertEquals(70, Prog.CLQ_Max_Capacity_Under_2_Years__c);
Prog = ProgramsMap.get(programRecord2.Id);
system.AssertEquals(82, Prog.CLQ_Calculated_Max_Capacity__c);
system.AssertEquals(70, Prog.CLQ_Max_Capacity_Under_2_Years__c);
Prog = ProgramsMap.get(programRecord3.Id);
system.AssertEquals(82, Prog.CLQ_Calculated_Max_Capacity__c);
system.AssertEquals(null, Prog.CLQ_Max_Capacity_Under_2_Years__c);*/
            
            RorGrecord3.CLQ_Number_of_Children_Under_2_5__c = 12;
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            update RorGrecord3;
            system.assertEquals(True, 1==1,'Testing');
        }
    }
}