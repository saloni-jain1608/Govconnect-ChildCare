/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_StaffRecordTriggerHandlerTest
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
private class CLQ_StaffRecordTriggerHandlerTest {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void myUnitTest() {
        // TO DO: implement unit test
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_Staff_Record__c staffRec = new CLQ_Staff_Record__c();
            staffRec.Last_Name__c= 'tester';
            staffRec.First_Name__c = 'john';
            insert staffRec;
            
            staffRec.First_Name__c = 'johnny';
            update staffRec;
            
            delete staffRec;
        }
        
    }
}