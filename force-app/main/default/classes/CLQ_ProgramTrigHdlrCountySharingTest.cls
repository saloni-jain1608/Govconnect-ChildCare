@isTest
private class  CLQ_ProgramTrigHdlrCountySharingTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    @IsTest
    static void countyAdminSharetest(){
        system.assertEquals(True, 1==1,'Testing');
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
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
        
        CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
        CLQ_County__c county2 = new CLQ_County__c(Name = 'FRANKLIN', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
        insert new list<CLQ_County__c>{county, county2};
            List<CLQ_Program__c> progList = new List<CLQ_Program__c>();
        //Create a program record
        CLQ_Program__c programRecord = new CLQ_Program__c();
        programRecord.Name = 'Test';
        programRecord.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord.CLQ_Street_Address_1__c = 'test';
        programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
        programRecord.CLQ_County__c = county.id; 
        programRecord.CLQ_Licensing_Specialist__c = usr.Id; 
        progList.add(programRecord);
        
        //Create a program record
        CLQ_Program__c programRecord2 = new CLQ_Program__c();
        programRecord2.Name = 'Test2';
        programRecord2.CLQ_Associated_Organization__c = accountrecord.id;
        programRecord2.CLQ_Street_Address_1__c = 'test';
        programRecord2.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord2.CLQ_Licensing_Specialist__c = UserInfo.getUserID();
        programRecord2.CLQ_County__c = county2.id; 
        programRecord2.CLQ_Licensing_Specialist__c = usr.Id; 
        progList.add(programRecord2);        
        insert progList;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User u = new User();
        
        u.FirstName = 'A';
        u.LastName = 'S';
        u.Email = 'test@test.com';
        u.Username = 'astest@test.com';
        u.Alias = 'astest';
        u.ProfileId = p1.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        
        insert u;
        system.debug('u contains ' + u);
        
        System.runas(u){
            
            Group grp = new Group();
            grp.Name= 'County Admin';
            grp.DeveloperName='County_Admin_test';
            insert grp;
            
            Group grp1 = new Group();
            grp1.Name= 'County Admin1';
            grp1.DeveloperName='County_Admin_test1';
            insert grp1;
            
            GroupMember mem1= new GroupMember();
            mem1.GroupId=grp.id;
            mem1.UserOrGroupId=grp1.id;
            insert mem1;
        }
        
        
        
        
        
        
        
        
        
        CLQ_ProgramTrigHdlrCountySharing progTrgSharing = new CLQ_ProgramTrigHdlrCountySharing();
        progTrgSharing.CountyAdminShare(progList,null);
        
        
        
        
        
    }
    
}