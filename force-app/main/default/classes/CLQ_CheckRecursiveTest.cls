/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CheckRecursiveTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
public class CLQ_CheckRecursiveTest {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    private static void testing(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CheckRecursive.runOnce();
            
            CheckRecursive.PT_actorid_once();
            CheckRecursive.runOnce();
            CheckRecursive.PT_actorid_once();
        }
    }
}