/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CorrectiveActionPlanHandler_Test
** Description      : This class contains unit tests for validating the behavior of Apex classes and triggers.
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/ 
@isTest(isparallel = true)
private class CLQ_CorrectiveActionPlanHandler_Test {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void updateCAPInfoOnInspectionTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Inspection__c Inspection = new CLQ_Inspection__c();
            insert Inspection;
            CLQ_Inspection__c InspectionRet = [SELECT id, CLQ_Is_All_CAP_Approved__c, (SELECT Id, CLQ_CAP_Status__c FROM Corrective_Action_Plans__r)
                                               FROM CLQ_Inspection__c
                                               WHERE Id = :Inspection.Id ];
            system.AssertEquals(true,InspectionRet.CLQ_Is_All_CAP_Approved__c,'Testing');
            system.AssertEquals(0,InspectionRet.Corrective_Action_Plans__r.size(),'Testing');
            
            CLQ_Corrective_Action_Plan__c plan = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Submitted',
                CLQ_Inspection__c = Inspection.Id);
            insert plan;
            
            InspectionRet = [SELECT id, CLQ_Is_All_CAP_Approved__c, (SELECT Id, CLQ_CAP_Status__c FROM Corrective_Action_Plans__r)
                             FROM CLQ_Inspection__c
                             WHERE Id = :Inspection.Id ];
            system.AssertEquals(false,InspectionRet.CLQ_Is_All_CAP_Approved__c,'Testing');
            system.AssertEquals(1,InspectionRet.Corrective_Action_Plans__r.size(),'Testing');
            
            plan.CLQ_CAP_Status__c = 'Approved';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            InspectionRet = [SELECT id, CLQ_Is_All_CAP_Approved__c
                             FROM CLQ_Inspection__c
                             WHERE Id = :Inspection.Id ];
            system.AssertEquals(true,InspectionRet.CLQ_Is_All_CAP_Approved__c,'Testing');
            
            plan.CLQ_CAP_Status__c = 'Revised';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            InspectionRet = [SELECT id, CLQ_Is_All_CAP_Approved__c
                             FROM CLQ_Inspection__c
                             WHERE Id = :Inspection.Id ];
            system.AssertEquals(false,InspectionRet.CLQ_Is_All_CAP_Approved__c,'Testing');
            
            plan.CLQ_CAP_Status__c = 'Report Revised - Not Required';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            InspectionRet = [SELECT id, CLQ_Is_All_CAP_Approved__c
                             FROM CLQ_Inspection__c
                             WHERE Id = :Inspection.Id ];
            system.AssertEquals(true,InspectionRet.CLQ_Is_All_CAP_Approved__c,'Testing');
        }
    }
    
    @IsTest
    static void updateCAPInfoOnTransactionTest() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
            
            CLQ_Inspection__c Inspection = new CLQ_Inspection__c(CLQ_Program_Transaction__c = ProgramTransaction.Id);
            insert Inspection;
            CLQ_Program_Transaction__c ProgramTransactionRet = [SELECT id, CLQ_CAP_Complete__c, 
                                                                (SELECT Id, CLQ_Is_All_CAP_Approved__c FROM Inspections__r)
                                                                FROM CLQ_Program_Transaction__c
                                                                WHERE Id = :ProgramTransaction.Id ];
            system.AssertEquals(false,ProgramTransactionRet.CLQ_CAP_Complete__c,'Testing');
            system.AssertEquals(1,ProgramTransactionRet.Inspections__r.size(),'Testing');
            
            CLQ_Corrective_Action_Plan__c plan = new CLQ_Corrective_Action_Plan__c(
                CLQ_CAP_Status__c = 'Submitted',
                CLQ_Inspection__c = Inspection.Id);
            insert plan;
            
            ProgramTransactionRet = [SELECT id, CLQ_CAP_Complete__c
                                     FROM CLQ_Program_Transaction__c
                                     WHERE Id = :ProgramTransaction.Id ];
            system.AssertEquals(false,ProgramTransactionRet.CLQ_CAP_Complete__c,'Testing');
            
            plan.CLQ_CAP_Status__c = 'Approved';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            ProgramTransactionRet = [SELECT id, CLQ_CAP_Complete__c
                                     FROM CLQ_Program_Transaction__c
                                     WHERE Id = :ProgramTransaction.Id ];
            system.AssertEquals(false,ProgramTransactionRet.CLQ_CAP_Complete__c,'Testing');
            
            plan.CLQ_CAP_Status__c = 'Revised';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            ProgramTransactionRet = [SELECT id, CLQ_CAP_Complete__c
                                     FROM CLQ_Program_Transaction__c
                                     WHERE Id = :ProgramTransaction.Id ];
            system.AssertEquals(false,ProgramTransactionRet.CLQ_CAP_Complete__c,'Testing');
            
            plan.CLQ_CAP_Status__c = 'Report Revised - Not Required';
            CLQ_CorrectiveActionPlanTriggerHandler.HasUpdated = false;
            update plan;
            
            ProgramTransactionRet = [SELECT id, CLQ_CAP_Complete__c
                                     FROM CLQ_Program_Transaction__c
                                     WHERE Id = :ProgramTransaction.Id ];
            system.AssertEquals(false,ProgramTransactionRet.CLQ_CAP_Complete__c,'Testing');
        }
        
    }    
}