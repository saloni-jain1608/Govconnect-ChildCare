/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_90_60_30_Dy_Rmndr_OnGing_Schld_Test
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_90_60_30_Dy_Rmndr_OnGing_Schld_Test {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    public static void testschedule1() { 
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.StartTest();
            CLQ_90_60_30_Days_Reminder_OnGoing_Schld sh1 = new CLQ_90_60_30_Days_Reminder_OnGoing_Schld();
            String sch = '0 0 23 * * ?'; 
            system.AssertEquals('0 0 23 * * ?', sch,'Testing');
            system.schedule('CLQ_90_60_30_Days_Reminder_OnGoing_Schld',sch,sh1);
            Test.stopTest();
        }
    } 
}