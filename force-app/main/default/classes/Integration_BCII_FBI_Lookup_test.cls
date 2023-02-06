/*************************************************************************************************************
** User Story: 
**************************************************************************************************************
** Name             : Integration_BCII_FBI_Lookup_test
** Description      : Test class for Integration_BCII_FBI_Lookup_Ctrl
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Vamsi Velampati                July-2016                    1.0                          Created
** Pavan Ayta						8/23/17					   1.1			Added setExecuteControlSetting() for Task - 11615
************************************************************************************/ 

@isTest(isParallel=true) 
public class Integration_BCII_FBI_Lookup_test {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 
    @IsTest
    public static void searchRecord(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            
            
            Test.startTest();
            Date testDate = Date.newInstance(1990,1,1); 
            
            CLQ_BCII_FBI__c testRecord = new CLQ_BCII_FBI__c(CLQ_Agency_Code__C = 'test', CLQ_Date_Completed_By_BCI__c = testDate,CLQ_Date_of_Birth__c = testDate,CLQ_Date_Of_Birth_Text__c= '01/01/1990',CLQ_Date_Received_At_BCI__C=testDate,CLQ_First_Name__c = 'test',CLQ_Last_Name__c='test',CLQ_Middle_Name__c='test',CLQ_Record_Check_Results__c='test',CLQ_Result_Type__c='test',CLQ_SSN_Integration__c='123456789',CLQ_Transaction_Authentication__c='test',CLQ_Transaction_Type__c='test');
            if(Schema.SObjectType.CLQ_BCII_FBI__c.isCreateable()){
                insert testRecord;
            }
            Test.setCurrentPage(Page.Integration_BCII_FBI_Lookup);
            ApexPages.currentPage().getParameters().put('firstName', 'test');
            ApexPages.currentPage().getParameters().put('lastName', 'test');
            ApexPages.currentPage().getParameters().put('middleName', 'test');
            ApexPages.currentPage().getParameters().put('dob', '01/01/1990');
            ApexPages.currentPage().getParameters().put('ssn', '123423333');
            
            Integration_BCII_FBI_Lookup_Ctrl testCtrl = new Integration_BCII_FBI_Lookup_Ctrl();
            
            PageReference returnVal =  testCtrl.runSearch();
            testCtrl.runQuery();
            
            /*Test.setCurrentPage(Page.Integration_BCII_FBI_Lookup);
ApexPages.currentPage().getParameters().put('firstName', '');
ApexPages.currentPage().getParameters().put('lastName', '');
ApexPages.currentPage().getParameters().put('middleName', '');
ApexPages.currentPage().getParameters().put('dob', '');
ApexPages.currentPage().getParameters().put('ssnLastFour', '');

Integration_BCII_FBI_Lookup_Ctrl testCtrl2 = new Integration_BCII_FBI_Lookup_Ctrl();*/
            
            System.assert(!String.isBlank(testCtrl.contactCountDetails),'Testing');
            System.assert(testCtrl.dob_Day.size() > 0,'Testing');
            System.assert(testCtrl.dob_Month.size() > 0,'Testing');
            System.assert(testCtrl.dob_Year.size() > 0,'Testing');
            
            Test.stopTest();
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    
    @IsTest
    public static void searchBlankRecord(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            Test.startTest();
            Date testDate = Date.newInstance(1990,1,1); 
            
            CLQ_BCII_FBI__c testRecord = new CLQ_BCII_FBI__c(CLQ_Agency_Code__C = 'test', CLQ_Date_Completed_By_BCI__c = testDate,CLQ_Date_of_Birth__c = testDate,CLQ_Date_Of_Birth_Text__c= '01/01/1990',CLQ_Date_Received_At_BCI__C=testDate,CLQ_First_Name__c = 'test',CLQ_Last_Name__c='test',CLQ_Middle_Name__c='test',CLQ_Record_Check_Results__c='test',CLQ_Result_Type__c='test',CLQ_SSN_Integration__c='123456789',CLQ_Transaction_Authentication__c='test',CLQ_Transaction_Type__c='test');
            if(Schema.SObjectType.CLQ_BCII_FBI__c.isCreateable()){
                insert testRecord;
            }
            Test.setCurrentPage(Page.Integration_BCII_FBI_Lookup);
            ApexPages.currentPage().getParameters().put('firstName', '');
            ApexPages.currentPage().getParameters().put('lastName', '');
            ApexPages.currentPage().getParameters().put('middleName', '');
            ApexPages.currentPage().getParameters().put('dob', '');
            ApexPages.currentPage().getParameters().put('ssn', '');
            
            Integration_BCII_FBI_Lookup_Ctrl testCtrl = new Integration_BCII_FBI_Lookup_Ctrl();
            
            PageReference returnVal =  testCtrl.runSearch();
            testCtrl.runQuery();
            
            System.assert(!String.isBlank(testCtrl.contactCountDetails),'Testing');
            System.assert(testCtrl.dob_Day.size() > 0,'Testing');
            System.assert(testCtrl.dob_Month.size() > 0,'Testing');
            System.assert(testCtrl.dob_Year.size() > 0,'Testing');
            
            Test.stopTest();
            system.assertEquals(True, 1==1,'Testing');
        }
    }
}