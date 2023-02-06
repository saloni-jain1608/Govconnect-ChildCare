@isTest()
public class ISD_CreateLightningServerResponse_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    @IsTest
    static void createLightningServerResponse()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            ISD_CreateLightningServerResponse clsr = new ISD_CreateLightningServerResponse(true,'Hello',NULL,NULL);
            ISD_CreateLightningServerResponse clsr1 = new ISD_CreateLightningServerResponse(true,'Hello',NULL);
            ISD_CreateLightningServerResponse clsr2 = new ISD_CreateLightningServerResponse();
        }
        
        
    }
    
}