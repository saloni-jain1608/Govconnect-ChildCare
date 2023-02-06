@isTest
public class PageSubSectionTest {
    @testSetup 
    public static void testSetup()
    {
        PGFPage__c pgfPp = new PGFPage__c();
        pgfPp.Name = 'new Page';
        insert pgfPp;
    }
    @IsTest
    static void pageSubSectionMethod(){
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
            pgfSS.Type__c ='Component';
            pgfSS.Applicable_Form_Field_Labels__c = 'Open';
            pgfSS.ApplicableFormFields__c ='Open';
            pgfSS.Applicable_Field_Labels__c = 'Close';
            pgfSS.ApplicableFields__c ='Close';
            insert pgfSS;
            
            Test.startTest();
            PageSubSection PSS = new PageSubSection(pgfSS); 
            Test.stopTest();
        }
    }
}