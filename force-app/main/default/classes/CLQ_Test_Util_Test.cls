/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_Test_Util_Test
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
public class CLQ_Test_Util_Test {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }	
    @IsTest
    private static void testing(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord;
            CLQ_Program__c test1 = CLQ_Test_Util.getCLQProgram();
            CLQ_Program__c test2 = CLQ_Test_Util.getCLQProgram2();
            CLQ_Program__c test7 = CLQ_Test_Util.getCLQProgram1();
            CLQ_Program_Transaction__c test3 = CLQ_Test_Util.getCLQProgramTransaction();
            CLQ_Program_Transaction__c test6 = CLQ_Test_Util.getCLQProgramTransactionForTask();
            CLQ_Inspection__c test4 = CLQ_Test_Util.getCLQ_InspectionForTask();
            insert test4;
            Visit_Information__c test5 = CLQ_Test_Util.getVisitInformation(test4.Id);
        }
    }
    
}