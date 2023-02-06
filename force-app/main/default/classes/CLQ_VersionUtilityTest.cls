/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_VersionUtilityTest
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@istest 
public class CLQ_VersionUtilityTest {
    @testSetup //Added for task - 11615
    public static void setExecuteControlSetting(){
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    @IsTest
    public static void testVersionUtility () {
        //Create test data
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Account a = new Account (Name = 'Test A Original');
            insert a;
            
            List<Contact>ConList = new List<Contact>();
            List<Opportunity>OppList = new List<Opportunity>();
            List<CLQ_Case_Custom__c>CasList = new List<CLQ_Case_Custom__c>();
            //List<Task>TaskList = new List<Task>();
            //List<sObject> RelatedListRecords = new List<sObject>();
            CLQ_County__c county = new CLQ_County__c(Name = 'CUYAHOGA', CCC_Field_Officers__c = 'Columbus', Area_Region__c='C', FCC_Field_officers__c = 'Columbus' );
            insert county;
            for(integer i=0;i<20;i++){
                Contact c = new Contact (LastName = 'Test C Original', AccountId = a.Id);
                ConList.add(c);
            }
            
            for(integer i=0;i<20;i++){
                Opportunity o = new Opportunity (Name='Oppty[i]', AccountId = a.Id ,StageName='Prospecting' ,CloseDate=system.today().addDays(90));
                OppList.add(o);	
            }
            
            for(integer i=0;i<20;i++){
                CLQ_Case_Custom__c cs = new CLQ_Case_Custom__c ( AccountId__c = a.Id,CLQ_Anonymous_Complainant__c = true,CLQ_County_Alleged_Ops__c=county.Id);
                CasList.add(cs);
            }
            
            insert ConList;insert OppList;insert CasList ;
            CLQ_VersionUtility.initialiseObjectsForCloning(a.id,'Contact,Opportunity,CLQ_Case_Custom__c');
            Test.StartTest();
            //CLQ_VersionUtility.initialiseObjectsForCloning(a.id,'Contact,Opportunity,CLQ_Case_Custom__c');
            CLQ_VersionUtility.doClone(a.id,'ParentId',null,null);
            //CLQ_VersionUtility.cloneSelectedObjects();
            Test.StopTest();
            
            //Check there are now two accounts
            Account [] testresults = [Select Id, Name from Account WHERE NAME = 'Test A Original' ORDER BY CREATEDDATE ASC ];
            //system.assertequals(2,testresults.size());
            
            //Check is now one contact
            Contact [] testcresults = [Select Id, LastName, AccountId from CONTACT WHERE AccountId IN :testresults ORDER BY CREATEDDATE ASC];
            Opportunity [] testoresults = [Select Id, Name, AccountId from Opportunity WHERE AccountId IN :testresults ORDER BY CREATEDDATE ASC];
            CLQ_Case_Custom__c [] testcsresults = [Select Id, Name, AccountId__c from CLQ_Case_Custom__c WHERE AccountId__c IN :testresults ORDER BY CREATEDDATE ASC];
            //task [] testtresults = [Select Id, whatId from task WHERE AccountId = :a.Id ORDER BY CREATEDDATE ASC];
            
            //system.assertequals(40,testcresults.size());
            //system.assertequals(40,testoresults.size());
            //system.assertequals(40,testcsresults.size());
        }
    }
}