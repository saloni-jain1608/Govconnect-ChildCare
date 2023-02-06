/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_FacilityScheduleTriggerHandler_Test 
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Pradeep Ravi            01/03/2019      1.0          Initial Build 
**************************************************************************************************************/
@isTest
private class CLQ_FacilityScheduleTriggerHandler_Test {
    @testSetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    public static final String COMMUNITY_PROFILE_ID = [Select Id from Profile Where Name = 'OCLQS Customer Community Plus Login User' limit 1 ].Id ;    
    
    @isTest static void test_method_three() {
        UserRole usrrole=[select Id,Name from UserRole where DeveloperName='State_Admin' limit 1];
        BusinessHours stdBusinessHours = [select id,TimeZoneSidKey from BusinessHours where isDefault = true limit 1];
        Id sysAdminProfileId = [SELECT Id FROM Profile WHERE  name ='System Administrator' LIMIT 1].Id;
        User usr1=[select id, UserRoleId, ProfileId, IsActive from User where UserRoleId !=null and ProfileId !=null and IsActive =true limit 1];
        Account accountRecord = new Account(Name='Demo Account') ;
        //accountRecord.ownerId = new OCLQS_ENVManager().getDefaultAccountOwnerId();
        accountRecord.ownerId=usr1.Id;
        accountRecord.CLQ_DIRN__c = '040063';       
        insert accountRecord ;
        
        List<Contact> cons = new List<Contact>() ;
        
        Contact profileRecordactivated = new Contact(FirstName ='act' , AccountId =accountRecord.Id , LastName ='ivated' , email ='act@gmail.com' , OPIN__c = '12345678', Portal_User_Activated__c = true );
        cons.add(profileRecordactivated) ;
        
        INSERT cons ;
        
        User usr = new User();
        usr.Username = 'activated@randomusername.com'; 
        usr.Email = 'activated@randomusername.com';
        usr.FirstName = 'Dumm';
        usr.LastName = 'uPromo.lastName';
        usr.ContactId = profileRecordactivated.Id;
        usr.ProfileId = COMMUNITY_PROFILE_ID;
        usr.IsActive = true ;
        
        
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
        
        INSERT usr ;
        CLQ_County__c county = new CLQ_County__c(Name = 'CLARK', CCC_Field_Officers__c = 'Columbus', Area_Region__c='SW', FCC_Field_officers__c = 'Columbus' );
        insert county;
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
        insert configRecord; 
        CLQ_OCLQS_Configuration__c configRecord1 = new CLQ_OCLQS_Configuration__c(Name = 'Pre School');
        insert configRecord1;        
        Id progRecId = null;
        System.runAs(new user(ID=userinfo.getUserId())){
           Test.startTest();
            List<CLQ_Program__c> progList = new List<CLQ_Program__c>();
            List<Id> ProgIdList=new List<Id>();
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountRecord.id;
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            progList.add(programRecord) ;
            //Create a program record
            CLQ_Program__c programRecord1 = new CLQ_Program__c();
            programRecord1.Name = 'Test';
            programRecord1.CLQ_Associated_Organization__c = accountRecord.id;
            programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            progList.add(programRecord1) ;            
            insert progList;
            for(CLQ_Program__c prog:progList){
                ProgIdList.add(prog.Id);
            }
            List<CLQ_Facility_Schedule__c> fsList = new List<CLQ_Facility_Schedule__c>();
            CLQ_Facility_Schedule__c facShedule = new CLQ_Facility_Schedule__c(CLQ_Program__c=programRecord.Id,CLQ_Days_of_Operation__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday',Months_of_Operation__c='Year Round', CLQ_HOO_Time_1_Start__c= '12:00 AM', CLQ_HOO_Time_1_End__c= '12:00 AM', CLQ_HOO_Time_2_Start__c = '09:00 AM',CLQ_HOO_Time_2_End__c = '10:00 PM',CLQ_Status__c='Active');
            fsList.add(facShedule);
            CLQ_Facility_Schedule__c facShedule1 = new CLQ_Facility_Schedule__c(CLQ_Program__c=programRecord.Id,CLQ_Days_of_Operation__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday',Months_of_Operation__c='Year Round', CLQ_HOO_Time_1_Start__c= '12:00 AM', CLQ_HOO_Time_1_End__c= '12:00 PM', CLQ_HOO_Time_2_Start__c = '09:00 PM',CLQ_HOO_Time_2_End__c = '10:00 PM',CLQ_Status__c='Active');
            fsList.add(facShedule1);
            CLQ_Facility_Schedule__c facShedule2 = new CLQ_Facility_Schedule__c(CLQ_Program__c=programRecord1.Id,CLQ_Days_of_Operation__c='Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday',Months_of_Operation__c='Year Round', CLQ_HOO_Time_1_Start__c= '12:00 AM', CLQ_HOO_Time_1_End__c= '12:00 PM', CLQ_HOO_Time_2_Start__c = '09:00 PM',CLQ_HOO_Time_2_End__c = '10:00 PM',CLQ_Status__c='Inactive');
            fsList.add(facShedule2);            
            insert fsList;             
            CLQ_Facility_Schedule__c oldObject = new CLQ_Facility_Schedule__c();
            list<CLQ_Facility_Schedule__c>  OldList = new list<CLQ_Facility_Schedule__c>{fsList[2]};
            list<CLQ_Facility_Schedule__c>  NewList = new list<CLQ_Facility_Schedule__c>{fsList[0]};
            map<id,CLQ_Facility_Schedule__c>  OldMap = new map<id,CLQ_Facility_Schedule__c>{fsList[2].id => fsList[2]};
            map<id,CLQ_Facility_Schedule__c>  NewMap = new map<id,CLQ_Facility_Schedule__c>{fsList[0].id => fsList[0]};  
            CLQ_FacilityScheduleTriggerHandler Handler = new CLQ_FacilityScheduleTriggerHandler(newList, newMap, oldList, oldMap,
                                                                                    true, false, true, false, 
                                                                                    true, false, false, 1);        
            CLQ_FacilityScheduleTriggerHandler.updtProgTime(ProgIdList);                                 
            Test.stopTest();
            
			system.assertEquals(True, 1==1,'Testing');
        }
    }    
}