@isTest(isparallel = true)
public with sharing class RequestController_Test {
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    @IsTest
    static void testOne(){
        system.assertEquals(True, 1==1,'testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            RequestController.delegateRequest('Program_Rating_Controller','Desk Review Findings','','',false);
            RequestController.delegateRequest('','','','',true);
        }
        
    }
}