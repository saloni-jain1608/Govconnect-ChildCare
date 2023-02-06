public with sharing class CLQ_Test_Util {
 
  
  public static CLQ_Program__c getCLQProgram()
  {
      
       CLQ_Program__c cp = new CLQ_Program__c();
        cp.name = 'Test Pgrm';
        cp.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        cp.CLQ_License_Type__c = 'Continuous';
        cp.Program_Rating__c = '0';
        cp.Rating_Effective_Date__c = Date.today().addYears(-2);
      return cp;
  }
    public static CLQ_Program__c getCLQProgram1()
  {
      
        CLQ_Program__c cp1 = new CLQ_Program__c();
        cp1.name = 'Test Pgrm';
        cp1.CLQ_License_Type__c = 'Continuous';
        //cp1.CLQ_OCLQS_Configuration__c = 'FCC - Type B Home';
       
        return cp1;
  }
  public static CLQ_Program__c getCLQProgram2()
  {
      
        CLQ_Program__c cp2 = new CLQ_Program__c();
        cp2.name = 'Test Pgrm';
        cp2.CLQ_License_Type__c = 'Continuous';
        cp2.Program_Rating__c = '3';
        cp2.Rating_Effective_Date__c = Date.today();
        //cp2.CLQ_OCLQS_Configuration__c = 'Child Care Center';
       
        return cp2;
  }
  public static CLQ_Program_Transaction__c getCLQProgramTransaction()
  {
      
       CLQ_Program_Transaction__c cpt = new CLQ_Program_Transaction__c();
        cpt.CLQ_Transaction_Status__c = 'Submitted';      	
        cpt.CLQ_Submission_Date__c = date.today().addDays(-122);
      	cpt.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Application_CC_Center').getRecordTypeId();
        
      return cpt;
  }  
    public static CLQ_Program_Transaction__c getCLQProgramTransactionForTask()
  {
      
       CLQ_Program_Transaction__c cpt = new CLQ_Program_Transaction__c();
        cpt.CLQ_Transaction_Status__c = 'Deferral';
      cpt.DeferralDueDate__c = date.today().addDays(-2);
      cpt.CLQ_Submission_Date__c = date.today().addDays(-122);
      return cpt;
  }  
    public static CLQ_Inspection__c getCLQ_InspectionForTask()
  {
      
       CLQ_Inspection__c Insp = new CLQ_Inspection__c();
        Insp.Inspection_Status__c = 'Deferral';
      Insp.CLQ_Inspection_Status__c = 'Deferral';
            Insp.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-2);
      //cpt.CLQ_Submission_Date__c = date.today().addDays(-122);
      return Insp;
  }  
    public static Visit_Information__c getVisitInformation(Id inspId)
  {
      
       Visit_Information__c visit = new Visit_Information__c();
        Visit.Visit_Date__c = date.today();
      visit.Name = 'Visit 1';
      visit.Inspection__c = inspId;
      //Insp.CLQ_Inspection_Status__c = 'Deferral';
        //    Insp.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-2);
      //cpt.CLQ_Submission_Date__c = date.today().addDays(-122);
      return visit;
  }  
}