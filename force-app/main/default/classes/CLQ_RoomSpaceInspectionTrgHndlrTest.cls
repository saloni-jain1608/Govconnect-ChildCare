/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_RoomSpaceInspectionTrgHndlrTest
** Description      : Test Class for CLQ_RoomSpaceInspectionTriggerHandler
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
public class CLQ_RoomSpaceInspectionTrgHndlrTest {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void updateRoomSpaceOnInspectionTest(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord; 
            
            
            //Create Account Record
            Account accountrecord = new Account(Name='Test123 Account',CLQ_DIRN__c = '3347'); 
            insert accountrecord ;
            //Create Program Record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test Program Name';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'Test Address';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
            insert programRecord ;
            
            //Create Program Transaction Record
            CLQ_Program_Transaction__c progTransA = new CLQ_Program_Transaction__c();
            progTransA.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            progTransA.CLQ_Program__c = programRecord.Id;
            progTransA.CLQ_ProgTrans_Street_Address__c ='Test Street Address';
            progTransA.CLQ_Transaction_Status__c = 'Not Submitted';
            progTransA.CLQ_Transaction_Assigned_To__c = UserInfo.getUserId();
            Insert progTransA;  
            
            
            
            //Insert CLQ_Inspection__c 
            CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Pre-license', 'Full', 'Pending Processing');
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            inspectionrecord.Calculated_Max_Capacity__c = 10;
            inspectionrecord.Approved_Total_Capacity_Under_2_1_2__c = 10;
            inspectionrecord.Approved_Total_Capacity__c = 5;
            inspectionrecord.Max_Capacity_Under_2_1_2_Years__c = 30;
            inspectionrecord.CLQ_Notice__c ='Unannounced';
            inspectionrecord.CLQ_Inspection_Type__c ='Annual';
            inspectionrecord.CLQ_Scope__c='Full';
            inspectionrecord.CLQ_Use_Rules_Effective_On__c = System.today();
            inspectionrecord.CLQ_Method__c ='On-site Inspection';
            
            insert inspectionrecord;
            
            inspectionrecord.Calculated_Max_Capacity__c = 11;
            inspectionrecord.Approved_Total_Capacity_Under_2_1_2__c = 3;
            inspectionrecord.Approved_Total_Capacity__c = 5;
            inspectionrecord.Max_Capacity_Under_2_1_2_Years__c = 12;
            update inspectionrecord;
            
            //Insert List for CLQ_Room_Space_Inspection__c
            list<CLQ_Room_Space_Inspection__c> rsiInsert = new list<CLQ_Room_Space_Inspection__c>();
            
            CLQ_Room_Space_Inspection__c rsiRecord1 = new CLQ_Room_Space_Inspection__c();
            rsiRecord1.Name = 'Room2';
            rsiRecord1.CLQ_Room_Space_Number__c = '1234';
            rsiRecord1.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rsiRecord1.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rsiRecord1.CLQ_Length_Feet__c = 100;
            rsiRecord1.CLQ_Width_Feet__c = 90;
            rsiRecord1.CLQ_Room_Space_Type__c = 'Primary Space';
            rsiRecord1.CLQ_Approved_Room_Space__c = true;
            rsiRecord1.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            rsiRecord1.CLQ_Approved_for_under_2_1_2__c = 'No';
            rsiRecord1.CLQ_Currently_In_Use__c = 'Yes'; 
            rsiRecord1.CLQ_Inspection__c= inspectionrecord.Id;
            rsiRecord1.CLQ_Observation_Complete__c ='Yes';
            rsiRecord1.CLQ_Number_of_Children_Allowed__c = 4;
            rsiInsert.add(rsiRecord1);
            
            CLQ_Room_Space_Inspection__c rsiRecord2 = new CLQ_Room_Space_Inspection__c();
            rsiRecord2.Name = 'Room2';
            rsiRecord2.CLQ_Room_Space_Number__c = '4321';
            rsiRecord2.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rsiRecord2.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rsiRecord2.CLQ_Length_Feet__c = 90;
            rsiRecord2.CLQ_Width_Feet__c = 100;
            rsiRecord2.CLQ_Room_Space_Type__c = 'Primary Space';
            rsiRecord2.CLQ_Approved_Room_Space__c = true;
            rsiRecord2.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Under';
            rsiRecord2.CLQ_Approved_for_under_2_1_2__c = 'Yes';
            rsiRecord2.CLQ_Currently_In_Use__c = 'Yes';
            rsiRecord2.CLQ_Inspection__c= inspectionrecord.Id;
            rsiRecord2.CLQ_Observation_Complete__c ='Yes';
            rsiRecord2.CLQ_Number_of_Children_Allowed__c = 3;
            rsiInsert.add(rsiRecord2);
            
            CLQ_Room_Space_Inspection__c rsiRecord3 = new CLQ_Room_Space_Inspection__c();
            rsiRecord3.Name = 'Room3';
            rsiRecord3.CLQ_Room_Space_Number__c = '2472';
            rsiRecord3.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rsiRecord3.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rsiRecord3.CLQ_Length_Feet__c = 120;
            rsiRecord3.CLQ_Width_Feet__c = 100;
            rsiRecord3.CLQ_Room_Space_Type__c = 'Primary Space';
            rsiRecord3.CLQ_Approved_Room_Space__c = true;
            rsiRecord3.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Both';
            rsiRecord3.CLQ_Approved_for_under_2_1_2__c = 'Yes';
            rsiRecord3.CLQ_Currently_In_Use__c = 'Yes';
            rsiRecord3.CLQ_Inspection__c= inspectionrecord.Id;
            rsiRecord3.CLQ_Observation_Complete__c ='Yes';
            rsiRecord3.CLQ_Number_of_Children_Allowed__c = 5;
            rsiInsert.add(rsiRecord3);
            
            CLQ_Room_Space_Inspection__c rsiRecord4 = new CLQ_Room_Space_Inspection__c();
            rsiRecord4.Name = 'Room4';
            rsiRecord4.CLQ_Room_Space_Number__c = '3284';
            rsiRecord4.recordTypeid = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
            rsiRecord4.CLQ_Room_Space_Shape__c = 'Square/Rectangle/L-Shaped';
            rsiRecord4.CLQ_Length_Feet__c = 120;
            rsiRecord4.CLQ_Width_Feet__c = 110;
            rsiRecord4.CLQ_Room_Space_Type__c = 'Primary Space';
            rsiRecord4.CLQ_Approved_Room_Space__c = true;
            rsiRecord4.CLQ_Used_by_Under_or_Over_2_1_2__c = 'Both';
            rsiRecord4.CLQ_Approved_for_under_2_1_2__c = 'No';
            rsiRecord4.CLQ_Currently_In_Use__c = 'Yes';
            rsiRecord4.CLQ_Inspection__c= inspectionrecord.Id;
            rsiRecord4.CLQ_Observation_Complete__c ='Yes';
            rsiRecord4.CLQ_Number_of_Children_Allowed__c = 5;
            rsiInsert.add(rsiRecord4);
            
            
            insert rsiInsert;
            
            update rsiRecord1;
            
            
            CLQ_Room_Space_Inspection__c oldRecord = rsiRecord1.clone(true,true,true,true);
            
            
            list<CLQ_Room_Space_Inspection__c> newList = new list<CLQ_Room_Space_Inspection__c>{rsiRecord1};
                list<CLQ_Room_Space_Inspection__c> oldList = new list<CLQ_Room_Space_Inspection__c>{oldRecord};
                    map<id,CLQ_Room_Space_Inspection__c> newMap = new map<id,CLQ_Room_Space_Inspection__c>{rsiRecord1.Id => rsiRecord1};
                        map<id,CLQ_Room_Space_Inspection__c> oldMap = new map<id,CLQ_Room_Space_Inspection__c>{oldRecord.Id => oldRecord};
                            CLQ_RoomSpaceInspectionTriggerHandler rsi = new CLQ_RoomSpaceInspectionTriggerHandler(newList,newMap,oldList,oldMap,
                                                                                                                  true,false,true,false,
                                                                                                                  true,false,false,1);
            
            rsi.roomSpaceChildrenUpdate(newList , false);
            
            
        }
    }
}