@isTest
private class CLQ_NotifyApplicantTest2 {
    
    @testSetup 
    public static void testSetup()
    {
        
        Account accountrecord_setup = new Account(Name='Test Account Setup',CLQ_DIRN__c = '1234'); 
        insert accountrecord_setup ; 
    }
    @IsTest
    static void myUnitTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            // TO DO: implement unit test
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            //CLQ_NotifyApplicantTest notApplicant = new CLQ_NotifyApplicantTest();
            //Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            Id ccApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord.id;
            insert r;
            
            CLQ_Program_Transaction__c pt = new CLQ_Program_Transaction__c();
            pt.recordtypeid = objOnGoingReg;
            pt.CLQ_Program__c = programRecord.id;
            pt.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt;
            
            Test.startTest();
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt.id);
            CLQ_Transaction_Document__c td = new CLQ_Transaction_Document__c();
            td.CLQ_Program_Transaction__c = pt.id;
            td.CLQ_Document_Status__c='Under Review';
            td.CLQ_All_Comments__c = 'test';
            insert td; 
            CLQ_NotifyApplicant.notification(); 
            Test.stopTest(); 
        }
    }
    
    @IsTest
    static void cccTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            //CLQ_NotifyApplicantTest notApplicant = new CLQ_NotifyApplicantTest();
            //Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            Id ccApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create a program record
            CLQ_Program__c programRecord2 = new CLQ_Program__c();
            programRecord2.Name = 'Test2';
            programRecord2.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord2.CLQ_License_Type__c = 'Continuous';
            programRecord2.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord2.CLQ_Street_Address_1__c = 'test2';
            programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord2 ;
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord2.id;
            insert r;        
            CLQ_Program_Transaction__c pt2 = new CLQ_Program_Transaction__c();
            pt2.recordtypeid = ccApp;
            pt2.CLQ_Program__c = programRecord2.id;
            pt2.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt2;
            
            Test.startTest();   
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt2.id);
            CLQ_Transaction_Document__c td2 = new CLQ_Transaction_Document__c();
            td2.CLQ_Program_Transaction__c = pt2.id;
            td2.CLQ_Document_Status__c='Under Review';
            td2.CLQ_All_Comments__c = 'test';
            insert td2; 
            CLQ_NotifyApplicant.notification();
            Test.stopTest();
        }
    } 
    
    @IsTest
    static void odeTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            //CLQ_NotifyApplicantTest notApplicant = new CLQ_NotifyApplicantTest();
            //Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
            Id odeApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_ODE_Program').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord;
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            //Create a program record 
            CLQ_Program__c programRecord3 = new CLQ_Program__c();
            programRecord3.Name = 'Test2';
            programRecord3.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord3.CLQ_License_Type__c = 'Continuous';
            programRecord3.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord3.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord3.CLQ_Street_Address_1__c = 'test2';
            programRecord3.CLQ_Org_Wide_Email_Addresses_SUTQ__c = 'abc@gmail.com;def@gmail.com;ghi@gmail.com';
            programRecord3.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            insert programRecord3 ;   
            contact c = new contact();
            c.lastname = 'tester'; 
            c.email = 'tester@tester.com';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord3.id;
            insert r;      
            CLQ_Program_Transaction__c pt3 = new CLQ_Program_Transaction__c();
            pt3.recordtypeid = odeApp;
            pt3.CLQ_Program__c = programRecord3.id;
            pt3.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt3;  
            
            Test.startTest();
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef);  
            ApexPages.currentPage().getParameters().put('id' ,pt3.id);
            CLQ_Transaction_Document__c td3 = new CLQ_Transaction_Document__c();
            td3.CLQ_Program_Transaction__c = pt3.id;
            td3.CLQ_Document_Status__c='Under Review';
            td3.CLQ_All_Comments__c = 'test';
            insert td3; 
            CLQ_NotifyApplicant.notification();   
            Test.stopTest();  
        }
    }
    
    @IsTest
    static void dayCampTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            
            Id dcApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Application_Day_Camp').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test A';
            programRecord.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord.id;
            insert r;
            
            CLQ_Program_Transaction__c pt = new CLQ_Program_Transaction__c();
            pt.recordtypeid = dcApp;
            pt.CLQ_Program__c = programRecord.id;
            pt.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt;
            
            Test.startTest();   
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt.id);
            CLQ_Transaction_Document__c td2 = new CLQ_Transaction_Document__c();
            td2.CLQ_Program_Transaction__c = pt.id;
            td2.CLQ_Document_Status__c='Under Review';
            td2.CLQ_All_Comments__c = 'test';
            insert td2; 
            CLQ_NotifyApplicant.notification();
            Test.stopTest();
        }
    }
    @IsTest
    static void coaTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            
            Id coaApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Administrator').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Day Camp');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test A';
            programRecord.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId();
            insert programRecord ;
            
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord.id;
            insert r;
            
            CLQ_Program_Transaction__c pt = new CLQ_Program_Transaction__c();
            pt.recordtypeid = coaApp;
            pt.CLQ_Program__c = programRecord.id;
            pt.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt;
            
            Test.startTest();   
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt.id);
            CLQ_Transaction_Document__c td2 = new CLQ_Transaction_Document__c();
            td2.CLQ_Program_Transaction__c = pt.id;
            td2.CLQ_Document_Status__c='Under Review';
            td2.CLQ_All_Comments__c = 'test';
            insert td2; 
            CLQ_NotifyApplicant.notification();
            Test.stopTest();
        }
    }
    
    @IsTest
    static void coLTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            
            Id coaApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_FCC_Change_of_Location').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test A';
            programRecord.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord.id;
            insert r;
            
            CLQ_Program_Transaction__c pt = new CLQ_Program_Transaction__c();
            pt.recordtypeid = coaApp;
            pt.CLQ_Program__c = programRecord.id;
            pt.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt;
            
            Test.startTest();   
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt.id);
            CLQ_Transaction_Document__c td2 = new CLQ_Transaction_Document__c();
            td2.CLQ_Program_Transaction__c = pt.id;
            td2.CLQ_Document_Status__c='Under Review';
            td2.CLQ_All_Comments__c = 'test';
            insert td2; 
            CLQ_NotifyApplicant.notification();
            Test.stopTest();
        }
    }
    
    @IsTest
    static void coCTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            CLQ_NotifyApplicant notApplicant = new CLQ_NotifyApplicant();
            
            Id coaApp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Amendment_Change_of_Capacity_Space').getRecordTypeId();
            Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ; 
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test A';
            programRecord.CLQ_License_Issue_Date__c  = system.date.today();
            programRecord.CLQ_License_Type__c = 'Continuous';
            programRecord.CLQ_License_Registration_Status__c = 'Licensed';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert programRecord ;
            
            contact c = new contact();
            c.lastname = 'tester';
            insert c;
            CLQ_Role__c r = new CLQ_Role__c();
            r.CLQ_Contact__c = c.id;
            r.CLQ_Program__c = programRecord.id;
            insert r;
            
            CLQ_Program_Transaction__c pt = new CLQ_Program_Transaction__c();
            pt.recordtypeid = coaApp;
            pt.CLQ_Program__c = programRecord.id;
            pt.CLQ_Transaction_Status__c = 'Not Submitted';
            insert pt;
            
            Test.startTest();   
            PageReference pageRef = Page.CLQ_NotifyApplicantpage;
            Test.setCurrentPage(pageRef); 
            ApexPages.currentPage().getParameters().put('id' ,pt.id);
            CLQ_Transaction_Document__c td2 = new CLQ_Transaction_Document__c();
            td2.CLQ_Program_Transaction__c = pt.id;
            td2.CLQ_Document_Status__c='Under Review';
            td2.CLQ_All_Comments__c = 'test';
            insert td2; 
            CLQ_NotifyApplicant.notification();
            Test.stopTest();
        }
    }    
}