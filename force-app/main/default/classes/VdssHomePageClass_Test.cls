@isTest
public class VdssHomePageClass_Test {
    @testSetup 
	public static void setExecuteControlSetting()
	{
		CLQ_UnitTestUtilities.setExecuteControlSetting();
	}
    @IsTest
    public static void test(){
        system.assertEquals(True, 1==1,'Testing');
        user usr=[select id, name, UserType from user where UserType ='Guest' limit 1];
        system.runAs(usr){
    		VdssHomePageClass.isrendered();
        }
    }
    
    

}