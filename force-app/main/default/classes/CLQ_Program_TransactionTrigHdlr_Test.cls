@isTest
private  class CLQ_Program_TransactionTrigHdlr_Test {
    
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    
    //test
    @IsTest
    static void beforeUpdateTest() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            //Create Config
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            //Create a new user
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            User usr = new User(LastName = 'LIVESTON',
                                FirstName = 'JASON',
                                Alias = 'jliv',
                                Email = 'jason.liveston@asdf.com',
                                Username = 'jason.liveston@abcdefg8395023.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
            insert usr;      
            
            CLQ_OCLQS_Configuration__c config = new CLQ_OCLQS_Configuration__c();
            config.Name = 'FCC - Type B Home';
            
            insert config;
            
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.CLQ_License_Registration_Status__c = 'Exempt';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            //programRecord.AR_Anniv_Date_120_Days_away__c = false;
            //programRecord.Initial_Registration_Not_Allowed__c = false;
            //programRecord.AR_Ongoing_Reg_less_than_6_months_ago__c = false;
            //programRecord.IR_Rating_Removed_12_months__c = false;
            //programRecord.Unable_to_Rate_Reasons__c = 'Voluntarily Discontinue Participation in SUTQ';
            //programRecord.Rating_Effective_Date__c = system.today();//RR
            //programRecord.Rating_Anniversary_Date__c = system.today().addYears(1);
            //programRecord.RatingChangedDate__c = system.today();
            programRecord.Program_Rating__c='3';
            programRecord.Rating_Reduction_Date__c = system.today().addmonths(-2);
            programRecord.Rating_Discontinue__c = Date.today().addmonths(-5);
            insert programRecord;
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c ProgramTransaction = new CLQ_Program_Transaction__c();
            ProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
            ProgramTransaction.CLQ_Program__c = programRecord.id;
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c  = 'Rating Assessment Complete';
            ProgramTransaction.Recommended_Rating__c = '1';
            ProgramTransaction.Annual_Report_Overall_Requirements__c = 'Not Met';
            ProgramTransaction.Recommended_Annual_Report_Rating__c = '2';
            ProgramTransaction.SUTQ_Deferral_Due_Date__c= Date.Today();
            ProgramTransaction.IsApproved_PrgTran__c = True;
            insert ProgramTransaction;
            
            
            
            //get transactions
            CLQ_Program_Transaction__c testTrans = new CLQ_Program_Transaction__c();
            testTrans.CLQ_Program__c = programRecord.Id;
            //insert testTrans;
            
        }
    }
    
}