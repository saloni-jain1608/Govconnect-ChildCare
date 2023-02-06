/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_UnitTestUtilities
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
public class CLQ_UnitTestUtilities {
    
    public static Id ProgramTransactionId		{get;set;}
    public static final string CLQ_ProgramMessage = 'CLQ_ProgramMessage__c';
    public static final string CLQ_Message = 'CLQ_Message__c';
    public static final string RecordTypeName = 'RecordType.Name';
    public static final string CLQ_Program_Transaction = 'CLQ_Program_Transaction__c';
    public static final string idNUll = ' Id != null ';
    //public static final String COMMUNITY_PLUS_PROFILE_ID = [Select Id from Profile Where Name = 'OCLQS Customer Community Plus Login User' limit 1 ].Id ;   
    public static final list<string> ProgramTypes = new list<string> {'FCC - Type B Home','FCC - Type A Home','Child Care Center', 'Day Camp','In-Home Aide',
        'Out of State Registration','Pre School','School Age Child Care','FCC - Type A Home','Day Camp', 
        'Child Care Center','FCC - Type A Home','FCC - Type A Home','FCC - Type A Home','FCC - Type B Home' ,'FCC - Type B Home','School Age Child Care'};
    public static final list<string> TransactionTypes = new list<string> {'Application - FCC','Update FCC Resident Information','Application - CC Center', 
                'Update Facility Information','In-Home Aide',
                'Registration - Out of State','Application - ODE Program','Update On-site Contact Information','Registration - Out of State','Day Camp',
                'Amendment - Center - Change of Location' , 'Amendment - ODE - Change of Location' ,
                'Amendment - FCC - Change of Location','Continuous License','Amendment - Change of Administrator','Amendment- FCC - Change of Capacity / Space',
                'Amendment - ODE and Center - Change of Capacity / Space'};                                                     
                    public static final map<string,string> ObjectField = new map<string,string>{
                        'Task' => 'WhatId',
                            'Event' => 'WhatId',
                            'CLQ_Transaction_Document__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Staff_Record__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Rules_Inspected__c' => 'ProgramTransaction__c',
                            'CLQ_Room_Space__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Room_Space_Inspection__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Role__c' => 'CLQ_Program_Transaction_Source__c',
                            'CLQ_Program_Transaction__c' => 'CLQ_Original_Program_Transaction__c',
                            //'CLQ_Payment_Received__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Message__c' => 'Program_Transaction__c',
                            'CLQ_ProgramMessage__c' => 'CLQ_Corresponding_Program_Transaction__c',
                            'CLQ_Inspection__c' => 'CLQ_Program_Transaction__c',
                            'CLQ_Findings__c' => 'Program_Transaction__c',
                            'CLQ_Facility_Schedule__c' => 'CLQ_Program_Transaction__c',
                            'Answer__c' => 'Program_Transaction__c'    };
                                public static map<Id,CLQ_Program_Transaction__c> ProgramTransactions		
                            {
                                get
                                {
                                    list<string> ExtraFields = new list<string> {RecordTypeName};
                                        string QueryString = CLQ_UtilityClass.createSOQLQuery(CLQ_Program_Transaction, idNUll, ExtraFields);
                                    List<sObject> sobjList = Database.query(QueryString);
                                    map<string,CLQ_Program_Transaction__c> AllTransactionsByRecordType = new map<string,CLQ_Program_Transaction__c>();
                                    map<Id,CLQ_Program_Transaction__c> AllTransactionsById = new map<Id,CLQ_Program_Transaction__c>();
                                    for(sObject obj : sobjList)
                                    {
                                        CLQ_Program_Transaction__c trans = (CLQ_Program_Transaction__c)obj;
                                        AllTransactionsByRecordType.put(trans.RecordType.Name, trans);
                                        AllTransactionsById.put(trans.Id, trans);
                                    }
                                    
                                    return AllTransactionsById;
                                }
                            }
    
    public  static User GetCustomer()
    {
        User usr = [SELECT Id, ProfileId, UserRoleId FROM User 
                    Where LastName = 'Customer' AND FirstName = 'Joe' LIMIT 1];
        return usr;		
    }
    public  static User GetInternalUser()
    {
        User usr = [SELECT Id, ProfileId, UserRoleId FROM User 
                    Where Email='bruce.wayne@wayneenterprises.com' LIMIT 1];
        return usr;		
    }
    static testMethod void TransactionCreationTest() {
        
        User user = CLQ_UnitTestUtilities.AddCustomerUser();
        
        Test.StartTest();
        CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
        Test.StopTest();
    }
    
    @testSetup 
    public static void FCC_Application()
    {
        HardCodedTransactionCreation();
    }
    
    public static void setExecuteControlSetting()
    {
        insert new ExecutionControlSetting__c(SetupOwnerId=UserInfo.getOrganizationId(), Run_Trigger__c=true,Run_Validation_Rule__c =true,Run_Workflow__c=true, Run_Process_Builder__c= true );
    }
    
    public static CLQ_Program_Transaction__c TransactionCreation(string ProgramType, string TransactionType)
    {
        //Building test data
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = ProgramType);
        insert configRecord; 
        
        CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
        insert county;
        //Create account record
        Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
        insert accountrecord ;
        
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get(ProgramType).getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
        programRecord.CLQ_County__c = county.id;
        insert programRecord ;
        
        //Create a CLQ_Program_Transaction__c record
        CLQ_Program_Transaction__c NewProgramTransaction = new CLQ_Program_Transaction__c();
        NewProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(TransactionType).getRecordTypeId();
        NewProgramTransaction.CLQ_Program__c = programRecord.id;
        NewProgramTransaction.CLQ_Name_of_Day_Camp_on_ACA_Certificate__c = '123';
        NewProgramTransaction.CLQ_Is_the_Day_Camp_ACA_Certified__c = 'Yes';
        NewProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
        NewProgramTransaction.OwnerId = UserInfo.GetUserId();
        NewProgramTransaction.CLQ_ProgTrans_County__c = county.Id;
        NewProgramTransaction.CLQ_Associated_Organization__c = programRecord.CLQ_Associated_Organization__c;
        insert NewProgramTransaction;	
        ProgramTransactionId = NewProgramTransaction.Id;
        return NewProgramTransaction;
    }
    
    public static void HardCodedTransactionCreation()
    { 
        
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        string rand = string.valueOf(math.rint(math.random()*1000));
        User usr = new User(LastName = 'LIVESTON',
                            FirstName = 'JASON' + rand,
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.liv@abcdefg09823420' + rand + '.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        //Building test data
        list<CLQ_OCLQS_Configuration__c> configs = new list<CLQ_OCLQS_Configuration__c>();
        list<Account> Accounts = new list<Account>();
        list<CLQ_Program__c> Programs = new list<CLQ_Program__c>();
        list<CLQ_County__c> counties = new list<CLQ_County__c>();
        
        counties.Add( new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' ) );
        counties.Add( new CLQ_County__c(Name = 'MONROE', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'LORAIN', CCC_Field_Officers__c = 'Cleveland', Area_Region__c='NE', FCC_Field_officers__c = 'Cleveland' ) );
        counties.Add( new CLQ_County__c(Name = 'HAMILTON', CCC_Field_Officers__c = 'Dayton', Area_Region__c='SW', FCC_Field_officers__c = 'Dayton' ) );
        counties.Add( new CLQ_County__c(Name = 'GUERNSEY', CCC_Field_Officers__c = 'Akron', Area_Region__c='SE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'DELAWARE', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' ) );
        counties.Add( new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' ) );
        counties.Add( new CLQ_County__c(Name = 'ASHTABULA', CCC_Field_Officers__c = 'Cleveland', Area_Region__c='NE', FCC_Field_officers__c = 'Cleveland' ) );
        counties.Add( new CLQ_County__c(Name = 'CLERMONT', CCC_Field_Officers__c = 'Dayton', Area_Region__c='SW', FCC_Field_officers__c = 'Dayton' ) );
        counties.Add( new CLQ_County__c(Name = 'LOGAN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='NW', FCC_Field_officers__c = 'Dayton' ) );
        counties.Add( new CLQ_County__c(Name = 'HARRISON', CCC_Field_Officers__c = 'Akron', Area_Region__c='SE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'ATHENS', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' ) );
        counties.Add( new CLQ_County__c(Name = 'PIKE', CCC_Field_Officers__c = 'Akron', Area_Region__c='SE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'PREBLE', CCC_Field_Officers__c = 'Akron', Area_Region__c='SE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'ASHTABULA', CCC_Field_Officers__c = 'Akron', Area_Region__c='NE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'ASHTABULA', CCC_Field_Officers__c = 'Akron', Area_Region__c='NE', FCC_Field_officers__c = 'Akron' ) );
        counties.Add( new CLQ_County__c(Name = 'ASHTABULA', CCC_Field_Officers__c = 'Akron', Area_Region__c='NE', FCC_Field_officers__c = 'Akron' ) );
        
        insert counties;
        
        for(string typ : ProgramTypes)
        {
            configs.add(new CLQ_OCLQS_Configuration__c(Name = typ));
            Accounts.add(new Account(Name='Test ' + typ, CLQ_DIRN__c = string.valueOf(RandomInt(1000, 8888))));
        }
        insert configs; 
        insert Accounts; 
        integer counter = 0;
        for(string typ : ProgramTypes)
        {
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = Accounts[counter].id;
            programRecord.CLQ_Street_Address_1__c = string.valueOf(RandomInt(1000, 8888)) + ' Random St';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get(typ).getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.GetUserId();
            programRecord.CLQ_County__c = counties[counter].id;
            programRecord.OwnerId = usr.id;
            programRecord.CLQ_Program_Status__c = 'Open'; 
            Programs.Add( programRecord );
            counter++;
        }
        insert Programs; 
        
        list<CLQ_Program_Transaction__c> Transactions = new list<CLQ_Program_Transaction__c>();
        counter = 0;
        for(string typ : TransactionTypes)
        {   		
            //Create a CLQ_Program_Transaction__c record
            CLQ_Program_Transaction__c NewProgramTransaction = new CLQ_Program_Transaction__c();
            NewProgramTransaction.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(typ).getRecordTypeId();
            NewProgramTransaction.CLQ_Program__c = Programs[counter].id;
            NewProgramTransaction.CLQ_Transaction_Status__c = 'Not Submitted';
            NewProgramTransaction.OwnerId = UserInfo.GetUserId();
            NewProgramTransaction.CLQ_Transaction_Assigned_To__c = UserInfo.GetUserId();
            NewProgramTransaction.CLQ_Portal_Application_Update__c = false;
            NewProgramTransaction.CLQ_Name_of_Day_Camp_on_ACA_Certificate__c = '123';
            NewProgramTransaction.CLQ_Is_the_Day_Camp_ACA_Certified__c = 'Yes';
            NewProgramTransaction.CLQ_ACA_Accredited__c = false;
            NewProgramTransaction.CLQ_License_Start_Date__c = Date.Today().AddDays(7);
            NewProgramTransaction.CLQ_ProgTrans_County__c = counties[counter].id;
            NewProgramTransaction.CLQ_Associated_Organization__c = Programs[counter].CLQ_Associated_Organization__c;
            Transactions.Add( NewProgramTransaction );
            counter++;
        }
        system.debug('PRAKS' + Transactions);
        CLQ_Trigger.BypassAllTriggers = true;
        insert Transactions;	
        CLQ_Trigger.BypassAllTriggers = false;
    }			
    
    public static integer RandomInt(integer MinValue, integer MaxValue)
    {
        if (MinValue == MaxValue){
            return MinValue;
        } 
        double rnd = Math.random();
        double rD = rnd * (MaxValue - MinValue) + MinValue;
        integer count = Math.round(rD);
        return count;
    }	
    public static string RandomChar()
    {
        string Items = 'abcdefghijklmnopqrstuvwxyz';
        integer charNum = RandomInt(0, Items.length() - 1);
        string Item = Items.substring(charNum,charNum + 1);
        return Item;
    }
    public static string RandomString(integer MinChars, integer MaxChars)
    {
        string builder = '';
        integer count = 0;
        if (MinChars == MaxChars){
            count = MinChars;
        } 
        else count = RandomInt(MinChars, MaxChars);
        string ch;
        for (integer i = 1; i <= count; i++)
        {
            ch = RandomChar();
            builder += ch;
        }
        return builder;
    }	    
    
    public static sObject AddRelatedItem(CLQ_Program_Transaction__c ProgramTransaction, string ObjectName)
    {
        Schema.SObjectType NewType;
        if (ObjectName == CLQ_ProgramMessage){
            NewType = Schema.getGlobalDescribe().get(CLQ_Message);
        }   
        else{
            NewType = Schema.getGlobalDescribe().get(ObjectName);
        }
            
        Sobject sobj = NewType.newSobject();
        string RefField = ObjectField.get(ObjectName);
        sobj.put(RefField, ProgramTransaction.Id);
        return sobj;
    }
    
    public static user AddCustomerUser()
    {
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        User AdminUser = [SELECT Id FROM User WHERE ProfileId = :profileAdmin.Id AND IsActive = true LIMIT 1];
        User usr;
        // Insert account as current user
        System.runAs (AdminUser) {
            //Profile portalprofileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            Profile portalprofileId = [SELECT Id FROM Profile WHERE Name = 'OCLQS Customer Community Plus Login User' LIMIT 1];
            //To fix the error: portal account owner must have a role
            UserRole RoleId = [SELECT Id FROM UserRole WHERE DeveloperName  = 'State_Admin'];
            
            //Create portal account owner
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            system.Debug('portalAccountOwner1 Profile: ' + profile1);
            User portalAccountOwner1 = new User(
                UserRoleId = RoleId.Id,
                ProfileId = profile1.Id,
                Username = 'bruce.wayne.'+System.now().millisecond() + generateRandomString(6) + 'test2@someOrg.com',
                Alias = 'batman',
                Email='bruce.wayne@wayneenterprises.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago'
            );
            portalAccountOwner1.ProfileId = profile1.Id;
            Database.insert(portalAccountOwner1);
            
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            string em = 'joe.customer@' + randomstring(4,9) + '.com';
            //Create contact
            Contact contact1 = new Contact(FirstName='Joe', LastName='Customer',Phone='415-555-1212', 
                                           AccountId = portalAccount1.Id,
                                           Email = em
                                          );
            Database.insert(contact1);
            
            //Create user
            usr = new User(LastName = 'Customer',
                           FirstName = 'Joe',
                           Alias = 'jcustom',
                           Email = em,
                           Username = em,
                           ProfileId = portalprofileId.id,
                           TimeZoneSidKey = 'America/New_York',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           ContactId = contact1.Id
                          );
            Database.insert(usr);
        }
        return usr;
        
    }
    
    /*public static user createCommunityPlusUserInstanceForSharing(String contactId , String username )
    {
        //System.debug('contactId** '+contactId + 'username ** '+username);
        // Now create new User Record 
        User usr = new User();
        usr.Username = System.now().millisecond() + generateRandomString(6) + username; 
        usr.Email = 'test@randomusername.com.cp';
        usr.FirstName = 'Dumm';
        usr.LastName = 'uPromo.lastName';
        usr.ContactId = contactId;
        usr.ProfileId = COMMUNITY_PLUS_PROFILE_ID; 
        transient string tempNickName = String.valueOf(Math.random()) + '-' + 'Dummy'  ;
        if(tempNickName.length() > 30 )
        {
            tempNickName = tempNickName.substring(2,30) ;
        }
        usr.CommunityNickname = tempNickName ; 
        
        
        usr.Alias = ('fdim' + 'dummy').substring(0,5);
        usr.languagelocalekey='en_US';
        usr.localesidkey='en_US';
        usr.timezonesidkey='America/Los_Angeles';
        usr.emailencodingkey='UTF-8';
        
        return usr ;
    }*/
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}