/*************************************************************************************************************
** User Story: 
**************************************************************************************************************
** Name                : Integration_Connection_Test
** Description         : This class is a test class for Integration_Connection Class
** Version             : 1.2
** Built By            : 
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Sanjeev Chahar                    June-2016                1.0                          Created
** Vamsi Velampati                   July-2016                1.1                          Modified
** Pavan Ayta					 8/24/17 			     	   1.2			Added setExecuteControlSetting() for Task - 11615
************************************************************************************/ 

@isTest(isParallel=true)
private class Integration_Connection_Test {
    @testSetup //Added for task - 11615
	public static void setExecuteControlSetting()
	{
	CLQ_UnitTestUtilities.setExecuteControlSetting();
	} 	
    @isTest static void test_positive() {
        try{
            //List <OCLQS_Integration_Settings__mdt> listIntegration;
            //OCLQS_Integration_Settings__mdt Intset= new OCLQS_Integration_Settings__mdt();
            //Intset.Environment_Name__c='DEV';
            //listIntegration.add(Intset);
            //Integration_Connection.listIntegrationDetails=listIntegration;
                // Initialize the Integration Utility
                Integration_Connection utility = new Integration_Connection();
                
                test.StartTest();
                utility.getConnectionDetails('CBOSS','Target_Credentail_User_Id__c');  
                
                test.StopTest();
                
                System.Assert(utility.getConnectionDetails('CBOSS','Target_Credentail_User_Id__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Target_Connection_Port__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Target_Connection_URL__c') != '','Testing');            
                System.Assert(utility.getConnectionDetails('CBOSS','Target_Credentail_Token_OAuth_Key__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Target_Credentail_User_Password__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Attribute_1_Value__c') != '','Testing');  
                System.Assert(utility.getConnectionDetails('CBOSS','Attribute_2_Value__c') != '','Testing');  
                System.Assert(utility.getConnectionDetails('CBOSS','Attribute_3_Value__c') != '','Testing');  
                System.Assert(utility.getConnectionDetails('CBOSS','Enable_Debug__c') != '','Testing'); 
                System.Assert(utility.getConnectionDetails('CBOSS','Capture_Messages__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Error_Email_Notification__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Attribute_4_Value__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Attribute_5_Value__c') != '','Testing');
                System.Assert(utility.getConnectionDetails('CBOSS','Error_Email_Notification_Group__c') != '','Testing');
                Integration_Connection.sendErrorMailforMissingMetadata('test', 'text');
               
            }catch(Exception e){
                System.debug(e);
            }//End Catch
    }//End Test Positive
}//End Class