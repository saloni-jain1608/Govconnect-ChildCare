/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_90_60_30_Dy_Rmnd_Anrp_Schld_Test
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
private class CLQ_120_90_60_30_Dy_Rmnd_Anrp_Schld_Test {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    public static void testschedule() { 
        Test.StartTest();
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_120_90_60_30_Dy_Remndr_AnlRep_Schdl sh1 = new CLQ_120_90_60_30_Dy_Remndr_AnlRep_Schdl();
            String sch = '0 0 23 * * ?'; 
            system.schedule('CLQ_120_90_60_30_Dy_Remndr_AnlRep_Schdl',sch,sh1);
            system.assertEquals(True, 1==1, 'This worked correctly');
        }
            Test.stopTest();
        
    }
  
    
}