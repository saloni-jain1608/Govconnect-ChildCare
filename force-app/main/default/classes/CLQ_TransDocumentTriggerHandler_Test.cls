/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_TransDocumentTriggerHandler_Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isParallel=true)
private class CLQ_TransDocumentTriggerHandler_Test {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 	
    @IsTest
    static void test_method_one() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Program_Transaction__c progTrans = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
            progTrans.CLQ_Recommendation__c = 'Approve';
            progTrans.CLQ_Full_Part_Time_Options_Global__c = 'Full Time';
            progTrans.CLQ_Approved_Total_Capacity__c=3;
            progTrans.CLQ_Calculated_Maximum_Capacity__c=3;
            update progTrans;
            CLQ_Transaction_Document__c transDoc = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Approved',CLQ_Program_Transaction__c =CLQ_UnitTestUtilities.ProgramTransactionId);
            insert transDoc;
            CLQ_Program_Transaction__c progTrans1 = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type A Home', 'Application - FCC');
            progTrans.CLQ_Recommendation__c = 'Deny';
            update progTrans1;
            CLQ_Transaction_Document__c transDoc1 = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Denied',Id=transDoc.Id,CLQ_Program_Transaction__c=CLQ_UnitTestUtilities.ProgramTransactionId);
            update transDoc1;
            CLQ_Transaction_Document__c transDoc2 = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Not Verified',Id=transDoc.Id,CLQ_Program_Transaction__c=CLQ_UnitTestUtilities.ProgramTransactionId);
            update transDoc2;
        }
    }
    
    @IsTest
    static void test_method_two() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Program_Transaction__c progTrans = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
            progTrans.CLQ_Recommendation__c = 'Deny';
            progTrans.CLQ_Reviewer_Notes__c = 'Test Comments';
            progTrans.CLQ_Deny_Reasons__c = 'Not Applicable';
            //progTrans.CLQ_Full_Part_Time_Options_Global__c = 'Full Time';
            //progTrans.CLQ_Approved_Total_Capacity__c=3;
            //progTrans.CLQ_Calculated_Maximum_Capacity__c=3;
            update progTrans;
            CLQ_Transaction_Document__c transDoc = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Approved',CLQ_Program_Transaction__c =CLQ_UnitTestUtilities.ProgramTransactionId);
            insert transDoc;
            CLQ_Program_Transaction__c progTrans1 = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type A Home', 'Application - FCC');
            progTrans.CLQ_Recommendation__c = 'Deny';
            update progTrans1;
            CLQ_Transaction_Document__c transDoc1 = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Denied',Id=transDoc.Id,CLQ_Program_Transaction__c=CLQ_UnitTestUtilities.ProgramTransactionId);
            update transDoc1;
            CLQ_Transaction_Document__c transDoc2 = new CLQ_Transaction_Document__c(CLQ_Document_Status__c ='Not Verified',Id=transDoc.Id,CLQ_Program_Transaction__c=CLQ_UnitTestUtilities.ProgramTransactionId);
            update transDoc2;
        }
    }
    
}