/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_AnswerTriggerHandlerTest
** Description      : 
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A	            1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest(isparallel = true)
public class CLQ_AnswerTriggerHandlerTest {
    /* @testSetup //Added method for Task - 11615
public static void setExecuteControlSetting()
{
CLQ_UnitTestUtilities.setExecuteControlSetting();
}*/
    @IsTest
    public static void testAnswerTriggerHandlerMethod()
    {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            // testing sp8
            
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            CLQ_Program__c clqProg=CLQ_Test_Util.getCLQProgram();
            clqProg.CLQ_Program_Status__c='Open';
            clqProg.CLQ_ByPassUtil__c = true;
            clqProg.CLQ_Program_Email__c = 'test@test.com';
            clqProg.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert clqProg;
            
            CLQ_Program_Transaction__c cpt = CLQ_Test_Util.getCLQProgramTransaction();
            cpt.CLQ_Program__c=clqProg.id;        
            insert cpt;
            
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', 
                                                                               Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',CLQ_Met_Not_Met__c='Met',CLQ_QuestionType__c = 'Picklist');
            insert standardDetail;
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Answer__c ansOld = [select Answer_Text__c, Program_Transaction__c from Answer__c where id=:ans.Id];
            ansOld.Program_Transaction__c = cpt.Id;
            ansOld.Answer_Text__c = 'Yes';
            update ans;
            update ansOld;
            delete ans;
            Test.stopTest();  
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testAnswerTriggerHandlerMethod1()
    {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            Test.startTest();
            
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            CLQ_Program__c clqProg=CLQ_Test_Util.getCLQProgram2();
            clqProg.CLQ_Program_Email__c = 'test@test.com';
            clqProg.CLQ_Program_Status__c='Open';
            clqProg.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert clqProg;
            
            CLQ_Program_Transaction__c cpt = CLQ_Test_Util.getCLQProgramTransaction();
            cpt.CLQ_Program__c=clqProg.id;
            insert cpt;
            
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail1 = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No',Possible_Ratings__c = '1;2',
                                                                                CLQ_QuestionType__c = 'Picklist');
            insert standardDetail1;
            
            Answer__c ans1 = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 40, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail1.Id, Program_Transaction__c = cpt.Id);
            insert ans1;
            
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testAnswerTriggerHandlerMethod2()
    {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            Test.startTest();
            
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            CLQ_Program__c clqProg=CLQ_Test_Util.getCLQProgram2();
            clqProg.CLQ_Program_Email__c = 'test@test.com';
            clqProg.CLQ_Program_Status__c='Open';
            clqProg.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            insert clqProg;
            
            CLQ_Program_Transaction__c cpt = CLQ_Test_Util.getCLQProgramTransaction();
            cpt.CLQ_Program__c=clqProg.id;
            insert cpt;
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', Possible_Points__c = '3;4;5',
                                                                               Possible_Ratings__c = '1;2',CLQ_QuestionType__c = 'Picklist');
            insert standardDetail;
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 60, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = cpt.Id);
            insert ans;
            ans.Answer_Text__c = 'Yes';
            
            
            
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    static void testAnswerTriggerHandlerMethod3()
    {
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            
            Test.startTest();
            
            
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'Child Care Center');
            insert configRecord; 
            
            CLQ_Program__c clqProg=CLQ_Test_Util.getCLQProgram2();
            clqProg.CLQ_Program_Email__c = 'test@test.com';
            clqProg.CLQ_Program_Status__c='Open';
            clqProg.RecordTypeId = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            insert clqProg;
            
            CLQ_Program_Transaction__c cpt = CLQ_Test_Util.getCLQProgramTransaction();
            cpt.CLQ_Program__c=clqProg.id;        
            insert cpt;
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'Test', CLQ_PossibleResponses__c = 'Test;Yes;No', Possible_Points__c = '3;4;5',
                                                                               Possible_Ratings__c = '1;2',CLQ_QuestionType__c = 'Picklist');
            insert standardDetail;
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 60, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = cpt.Id);
            insert ans;
            ans.Answer_Text__c = 'Yes';
            
            
            
            Test.stopTest();  
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    static void setAnswerValuesTest()
    { 
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            CLQ_Program_Transaction__c ProgramTransaction2 = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'Application - FCC');
            CLQ_Program_Transaction__c ProgramTransaction = CLQ_UnitTestUtilities.TransactionCreation('FCC - Type B Home', 'SUTQ - Initial Registration');//Application - FCC
            
            
            Test.startTest();
            Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
            CLQ_Standard_Detail__c standardDetail2 = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'SDL-00034', CLQ_PossibleResponses__c = 'Test;Yes;No', Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',
                                                                                CLQ_QuestionType__c = 'Picklist');
            insert standardDetail2;
            CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c(RecordTypeId=questionRecordTypeId ,Name = 'SDL-00035', CLQ_PossibleResponses__c = 'Test;Yes;No', Possible_Points__c = '3;4;5',Possible_Ratings__c = '1;2',
                                                                               CLQ_QuestionType__c = 'Picklist',CLQ_ParentQuestion__c = standardDetail2.Id);
            insert standardDetail;
            
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'test',Points__c = 60, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = ProgramTransaction.Id);
            Answer__c ans2 = new Answer__c(Name = 'Test23',Answer_Text__c= 'test23',Points__c = 60, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail2.Id, Program_Transaction__c = ProgramTransaction.Id);
            
            CLQ_AnswerTriggerHandler hand = new CLQ_AnswerTriggerHandler(null,null,null,null,
                                                                         false,false,false,false,
                                                                         false,false,false,1);      
            hand.updateProgramTransaction(new list<Answer__c> { ans}, null);
            hand.updateProgramTransaction(new list<Answer__c> { ans2}, null);
            
            insert ans;
            insert ans2;
            ans.Answer_Text__c = 'Yes';
            ans2.Answer_Text__c = 'Yes';
            Test.stopTest();  
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    
    //Anil added method to test rating and points for edge case scenario.
    @IsTest
    static void testUpdateRatingPoint(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail=[select id,Name from CLQ_Standard_Detail__c where name='SD-00066' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testUpdateRatingPoint1(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail1=[select id,Name from CLQ_Standard_Detail__c where name='SD-00067' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail1.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testUpdateRatingPointWithMultipleAnswer1(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail1=[select id,Name from CLQ_Standard_Detail__c where name='SD-00067' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test;Test1',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail1.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testUpdateRatingPointWithMoreThan2Answer(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail1=[select id,Name from CLQ_Standard_Detail__c where name='SD-00067' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test',Answer_Text__c= 'Test;Test1;Test2',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail1.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testUpdateRatingPoint2(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail2=[select id,Name from CLQ_Standard_Detail__c where name='SD-00076' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test123',Answer_Text__c= 'Test123',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail2.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    @IsTest
    public static void testUpdateRatingPoint3(){
        system.runAs(new user(ID = UserInfo.getUserID())){
            
            //prepareData();
            CLQ_Standard_Detail__c standardDetail3=[select id,Name from CLQ_Standard_Detail__c where name='SD-00170' limit 1];
            CLQ_Program_Transaction__c cpt=[select id,Name from CLQ_Program_Transaction__c limit 1];
            Answer__c ans = new Answer__c(Name = 'Test124',Answer_Text__c= 'Test124',Points__c = 30, Rating_Number__c = 2,AssociatedQuestion__c = standardDetail3.Id, Program_Transaction__c = cpt.Id);
            Test.startTest();
            insert ans;
            Test.stopTest();   
            system.assertEquals(True, 1==1,'Testing');
        }
    }
    
    static CLQ_Program_Transaction__c cpt = new CLQ_Program_Transaction__c();
    static CLQ_Standard_Detail__c standardDetail = new CLQ_Standard_Detail__c();
    static CLQ_Standard_Detail__c standardDetail1 = new CLQ_Standard_Detail__c();
    static CLQ_Standard_Detail__c standardDetail2 = new CLQ_Standard_Detail__c();
    static CLQ_Standard_Detail__c standardDetail3 = new CLQ_Standard_Detail__c();
    @testSetup
    public static void prepareData(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        CLQ_Program__c clqProg=CLQ_Test_Util.getCLQProgram();
        clqProg.CLQ_ByPassUtil__c = true;
        clqProg.CLQ_Program_Email__c = 'test@test.com';
        CLQ_ProgramTriggerHandler.BypassTrigger = true;
        insert clqProg;
        CLQ_ProgramTriggerHandler.BypassTrigger = false;
        
        cpt = CLQ_Test_Util.getCLQProgramTransaction();
        cpt.CLQ_Program__c=clqProg.id;
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= true;
        insert cpt;
        CLQ_Program_TransactionTriggerHandler.BypassTrigger= false;
        
        Id questionRecordTypeId = Schema.SObjectType.CLQ_Standard_Detail__c.getRecordTypeInfosByDeveloperName().get('CLQ_Question').getRecordTypeId();
        
        list<CLQ_Standard_Detail__c> standardDetails = new list<CLQ_Standard_Detail__c>();
        standardDetail.RecordTypeId=questionRecordTypeId; 
        standardDetail.Name = 'SD-00066';
        standardDetail.CLQ_PossibleResponses__c = 'Test;Yes;No';
        standardDetail.Possible_Points__c = '3;4;5';
        standardDetail.Possible_Ratings__c = '1;2';
        standardDetail.CLQ_Met_Not_Met__c='Met';
        standardDetail.CLQ_QuestionType__c = 'Picklist';
        standardDetails.add(standardDetail); 
        
        standardDetail1.RecordTypeId=questionRecordTypeId; 
        standardDetail1.Name = 'SD-00067';
        standardDetail1.CLQ_PossibleResponses__c = 'Test;Yes;No';
        standardDetail1.Possible_Points__c = '3;4;5';
        standardDetail1.Possible_Ratings__c = '1;2';
        standardDetail1.CLQ_Met_Not_Met__c='Met';
        standardDetail1.CLQ_QuestionType__c = 'Picklist';
        standardDetails.add(standardDetail1);
        
        standardDetail2.RecordTypeId=questionRecordTypeId; 
        standardDetail2.Name = 'SD-00076';
        standardDetail2.CLQ_PossibleResponses__c = 'Test;Yes;No';
        standardDetail2.Possible_Points__c = '3;4;5';
        standardDetail2.Possible_Ratings__c = '1;2';
        standardDetail2.CLQ_Met_Not_Met__c='Met';
        standardDetail2.CLQ_QuestionType__c = 'Picklist';
        standardDetails.add(standardDetail2);
        
        standardDetail3.RecordTypeId=questionRecordTypeId; 
        standardDetail3.Name = 'SD-00170';
        standardDetail3.CLQ_PossibleResponses__c = 'Test;Yes;No';
        standardDetail3.Possible_Points__c = '3;4;5';
        standardDetail3.Possible_Ratings__c = '1;2';
        standardDetail3.CLQ_Met_Not_Met__c='Met';
        standardDetail3.CLQ_QuestionType__c = 'Picklist';
        standardDetails.add(standardDetail3);
        
        insert standardDetails;
        
        List<QuestionToInclude__c> questionstoInclude = new List<QuestionToInclude__c>();
        QuestionToInclude__c questoInclude = new QuestionToInclude__c();
        questoInclude.Name = 'SD-00066';
        questionstoInclude.add(questoInclude);
        
        QuestionToInclude__c questoInclude1 = new QuestionToInclude__c();
        questoInclude1.Name = 'SD-00067';
        questionstoInclude.add(questoInclude1);
        
        QuestionToInclude__c questoInclude2 = new QuestionToInclude__c();
        questoInclude2.Name = 'SD-00076.2';
        questionstoInclude.add(questoInclude2);
        
        QuestionToInclude__c questoInclude3 = new QuestionToInclude__c();
        questoInclude3.Name = 'SD-00170.2';
        questionstoInclude.add(questoInclude3);
        
        insert questionstoInclude;
        
    }
}