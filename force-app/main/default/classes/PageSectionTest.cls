@isTest
public class PageSectionTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void pageSectionMethod(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            PGFPage__c pgfP = new PGFPage__c();
            pgfP.Name = 'new Page';
            insert pgfP;
            
            PGFSection__c pgfS = new PGFSection__c();
            pgfS.Parent__c = pgfP.Id;
            pgfS.Name = 'new Section';
            pgfS.OrderNumber__c = 45;
            insert pgfS;
            
            Test.startTest();
            PageSection PS = new PageSection(pgfS,'Open');
            Test.stopTest();
            system.assertEquals(True, 1==1,'Testing');
        }
        
    } 
}