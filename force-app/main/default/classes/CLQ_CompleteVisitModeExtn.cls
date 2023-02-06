/**
*
* @author      
* @version     1.2
* @since       1.0.0
* 
** Modification Log:
**------------------
**	Developer					Date				Version			Description
**------------------------------------------------------------------------------------------------------------
** Soufin Rahimeen				08/10/2018			1.1				TFS#13807 - Removed setting of CLQ_Last_Visit_Date__c from this class
**************************************************************************************************************/ 
public with sharing class CLQ_CompleteVisitModeExtn {
    public CLQ_Inspection__c inspectionRecord {get;set;}
    public static final String CLQ_Visit = 'CLQ_Visit_Status__c';
    public static final String CLQ_LAST_Visit = 'CLQ_Last_Visit_Date__c';
    public static final String CLQ_Inspection_Status = 'CLQ_Inspection_Status__c';
    public static final String VISIT_COMPLETED = 'Visit Completed';
    public static final String APPROVED = 'Approved';
   public static final String CLOSED =  'Closed';
     public static final String REVISED ='Revised';
    
    public CLQ_CompleteVisitModeExtn(ApexPages.StandardController controller) {
         list<String> fieldlist;
         inspectionRecord = new CLQ_Inspection__c();
          fieldlist = new list<String>{CLQ_Visit,CLQ_LAST_Visit,CLQ_Inspection_Status};
          if(!Test.isRunningTest()){
              controller.addFields(fieldlist);
          }
          this.inspectionRecord = (CLQ_Inspection__c)controller.getRecord();
    }
    
    //Method to do on load logic
    //@param: none
    //@return: none
     public PageReference onLoad(){
         try{
         	         	
             inspectionRecord.CLQ_Visit_Status__c = VISIT_COMPLETED;
             //inspectionRecord.CLQ_Last_Visit_Date__c = Date.today(); //13807 - removed as it is handled in Event Trigger Handler
             //CLQ_InspectionTriggerHandler.HasUpdated = false;
             if(inspectionRecord.CLQ_Inspection_Status__c != APPROVED && inspectionRecord.CLQ_Inspection_Status__c != CLOSED && inspectionRecord.CLQ_Inspection_Status__c != REVISED){
                inspectionRecord.CLQ_CAP_Generated__c = true;
             }else{
                 inspectionRecord.CLQ_CAP_Generated__c = false;
             }
             List<CLQ_Inspection__c> InspectionList = new List<CLQ_Inspection__c>();
             InspectionList.add(inspectionRecord);
             if(!InspectionList.isEmpty()){
                 update InspectionList;
             }          
             return CLQ_UtilityClass.redirecttoPage('/'+inspectionRecord.Id);
         }catch(exception e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
             return null; 
         }
     }
     
     //Method to do on ok logic
    //@param: none
    //@return: none
    public PageReference onOk(){
        return CLQ_UtilityClass.redirecttoPage('/CLQ_VisitModePageMobile?id='+inspectionRecord.Id);
    }
}