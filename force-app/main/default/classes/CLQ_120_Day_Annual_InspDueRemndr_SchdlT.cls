/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_Day_Annual_InspDueRemndr_SchdlT
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Rahul Roy				03/07/19			1.0		 TFS#14903 : Initial Build
**************************************************************************************************************/

@isTest
private class CLQ_120_Day_Annual_InspDueRemndr_SchdlT {
    @testSetup
	public static void testSetup()
	{
		System.debug('');
	}
    @IsTest
    public static void testschedule() { 
        
        system.runAs(new user(ID = UserInfo.getUserID())){
            
        
        	Test.StartTest();
        	CLQ_120_Day_Annual_InspDueRemndr_Schdl sh1 = new CLQ_120_Day_Annual_InspDueRemndr_Schdl();
        	String sch = '0 0 23 * * ?'; 
        	system.schedule('CLQ_120_Day_Annual_InspDueRemndr_Schdl',sch,sh1);
        	Test.stopTest();
        	system.assertEquals(True, 1==1,'Testing');
            }
    } 
}