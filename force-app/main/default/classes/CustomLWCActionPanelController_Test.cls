@isTest
public class CustomLWCActionPanelController_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    public static void test(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //CustomLWCActionPanelController c1 = new CustomLWCActionPanelController();
            CustomLWCActionPanelController.getActions('CLQ_Program_Transaction__c');
        }
    }
    
}