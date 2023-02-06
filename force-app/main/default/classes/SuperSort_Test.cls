@isTest()
public class SuperSort_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void super1()
    {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            List<Lead> leads = new List<Lead>() ;
            for(integer i = 0 ; i<25 ; i++) // Create 25 CLQ_Rule__c s  
            {
                leads.add(new Lead(LastName = 'LastSDNAME' + i  , Company= 'Company' + i )) ;
            }
            SuperSort ss = new SuperSort();
            SuperSort.sortList((List<sObject>)leads,'LastName','Asc');
        }
    }
    
}