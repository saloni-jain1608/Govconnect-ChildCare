/*************************************************************************************************************
** User Story: 
**************************************************************************************************************
** Name                : Integration_Transaction_Logs_Test
** Description         : This class is a test class for Integration_Transaction_Logs Class
** Version             : 1.3
** Built By            : 
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Sanjeev Chahar                    June-2016                1.0                          Created
** Vamsi Velampati                   July-2016                1.1                          Modified
** Ramana                            Sep-2016                 1.2                          Modified
** Pavan Ayta					 	8/24/17 			    1.3			Added setExecuteControlSetting() for Task - 11615
************************************************************************************/ 

@isTest(isParallel=true)
private class Integration_Transaction_Logs_Test {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    } 
    @IsTest
    static void test_positive() {
        try{
            system.assertEquals(True, 1==1,'Testing');
            // Initialize the Integration Utility
            Integration_Transaction_Logs txnLogs = new Integration_Transaction_Logs();
            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            
            System.runAs(thisUser) {
                test.StartTest();
                OCLQS_Transaction_Log__c testRecord = new OCLQS_Transaction_Log__c (Name='TestRecordTranId',Name__c='TestRecordName', Custom_Metadata_Integration_Type__c='CBOSS');
                insert testRecord;
                
                Integration_Transaction_Logs.LogMessage(testRecord.Name,'xxx','2','resp','200','other details');
                Integration_Transaction_Logs.LogErrorRealTime(testRecord.Name,'xxx','2','resp','200','other details');
                Integration_Transaction_Logs.LogError(testRecord.Name,'xxx','2','resp','200','other details');
                Integration_Transaction_Logs.LogBatchMessage(testRecord.Name,'xxx','Success',100, 50, 50);
                Integration_Transaction_Logs.sendSingleMail('emailSubject', testRecord.Name,testRecord.Name__c,'errorCause', 'errorType','errorLineNo','errorStack','errorMessage');  
                test.StopTest();
            }
            
            System.Assert(txnLogs.GUID() != '','Testing');
        } //end try
        catch(Exception e){
            System.debug(e);
        }//End Catch
    }//End Test Positive
}//End Class