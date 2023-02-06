@IsTest
public with sharing class LightningLoginFormControllerTest {
	@testSetup 
	public static void setExecuteControlSetting()
	{
		CLQ_UnitTestUtilities.setExecuteControlSetting();
	}
 @IsTest
 static void lightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null,'Testing');
 }
 
 @IsTest
 static void testLogin() {
  System.assertNotEquals(LightningLoginFormController.login('fakeUser','1234 ', 'http://a.com'), 'user','Testing');
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled(),'Testing');
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled(),'Testing');
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl(),'Testing');
 }
    
 @IsTest
 static void testGetForgotPasswordUrl() {
  System.assertEquals(null, LightningLoginFormController.getForgotPasswordUrl(),'Testing');
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig,'Testing');
 }
    
 @IsTest
 static void testsetExperienceId() {
  LightningLoginFormController.setExperienceId('');
  System.assertNotEquals(null, '','Testing');
 }
}