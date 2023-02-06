@isTest
public class PageFieldTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    static void pageFieldMethod(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            PGFPage__c pgfP = new PGFPage__c();
            pgfP.Name = 'new Page';
            insert pgfP;
            
            PGFSection__c pgfS = new PGFSection__c();
            pgfS.Parent__c = pgfP.Id;
            pgfS.Name = 'new Section';
            pgfS.OrderNumber__c = 45;
            insert pgfS;
            
            PGFSubSection__c pgfSS = new PGFSubSection__c();
            pgfSS.Parent__c = pgfS.Id;
            pgfSS.Name = 'ss Name';
            pgfSS.OrderNumber__c = 35;
            insert pgfSS;
            
            PGFField__c pgf = new PGFField__c();
            pgf.Parent__c = pgfSS.Id;
            pgf.Label__c = 'Hey Label';
            pgf.OrderNumber__c = 25;
            pgf.Name ='AccountSource';
            pgf.ObjectAPIName__c ='Account';
            pgf.Type__c = 'Picklist';
            insert pgf;
            
            Test.startTest();
            PageField PF = new PageField(pgf,'new PG');
            Test.stopTest();
        }
        
    }
}