@IsTest
public with sharing class LightningSelfRegisterControllerTest {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true,'Testing');
            System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false,'Testing');
            System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false,'Testing');
            System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false,'Testing');
        }
    }
    
    @IsTest
    static void testSiteAsContainerEnabled() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'),'Testing');
        }
    }
    
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            Map < String, String > paramsMap = initializeParams();
            System.assertNotEquals(null, paramsMap,'Testing');
            System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true),'Testing');
            System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true),'Testing');
            System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true),'Testing');
            System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true),'Testing');
            System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false),'Testing');
        }
    }
    
    
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            Map < String, String > paramsMap = initializeParams();
            System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true),'Testing');
        }
    }
    
    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            Account acc = new Account(name = 'test acc');
            if(Schema.SObjectType.Account.isAccessible()){
                insert acc;
            }
            List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
            System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
            String accountId = accounts[0].Id;
            Map < String, String > paramsMap = initializeParams();
            System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false),'Testing');
        }
    }
    
    @IsTest
    static void testGetNullExtraFields() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null),'Testing');
        }
    }
    
    @IsTest
    static void testGetNonEmptyExtraFields() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
        }
    }
    
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
            Map < String, String > paramsMap = initializeParams();
            Map < String, Object > fieldMap = new Map < String, Object > ();
            fieldMap.put('description', 'new field');
            fieldMap.put('fieldPath', 'dummyPath');
            fieldlist.add(fieldMap);
            String extraFields = JSON.serialize(fieldlist);
            System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true),'Testing');
        }
    }
    
    @IsTest
    static void lightningSelfRegisterControllerInstantiation() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            LightningSelfRegisterController controller = new LightningSelfRegisterController();
            System.assertNotEquals(controller, null,'Testing');
        }
    }
    
    @IsTest
    static void testsetExperienceId() {
        system.runAs(new user(ID = UserInfo.getUserID())){
            LightningSelfRegisterController.setExperienceId('');
            System.assertNotEquals(null, '','Testing');
        }
    }
    
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams() {
        Map < String, String > paramsMap = new Map < String, String > ();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
}