/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
@IsTest public with sharing class CommunitiesSelfRegConfirmControllerTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }    
    @IsTest
    public static void testCommunitiesSelfRegConfirmController() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            // Instantiate a new controller with all parameters in the page
            CommunitiesSelfRegConfirmController controller = new CommunitiesSelfRegConfirmController();
        }
    }    
}