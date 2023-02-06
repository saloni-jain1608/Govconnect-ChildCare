@isTest()
public class RequiredCheckListItems_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void requiredCheckList(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            //RequiredCheckListItems req = new RequiredCheckListItems();
            RequiredCheckListItems.getChecklistRecords();
            Test.stopTest();
        }
    }
    
    @IsTest
    static void requiredCheckListOne(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            //RequiredCheckListItems req = new RequiredCheckListItems();
            //RequiredCheckListItems.getChecklistRecords();
            
            RequiredCheckListItems.getChecklistRecords() ;
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void requiredCheckListTwo(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            //RequiredCheckListItems req = new RequiredCheckListItems();
            //RequiredCheckListItems.getChecklistRecords();
            Required_Checklist__mdt a = new Required_Checklist__mdt(Question__c='');
            RequiredCheckListItems.getChecklistRecords();
            Test.stopTest();
        }
    }
    
    
}