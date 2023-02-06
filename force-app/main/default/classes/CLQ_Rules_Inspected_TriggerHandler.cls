/*************************************************************************************************************
**************************************************************************************************************
** Name : CLQ_Rules_Inspected_TriggerHandler
** Description : This class contains all detail logic/methods for  Rules Inspected object's trigger. 
** Version          : 1.50
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer				Date            Version		Description
**  Soufin Rahimeen			09/25/2018      1.0			TFS#13527 - Added logic to delete findings and CAPs when a Rules Inspected is changed to Compliant
**************************************************************************************************************/
public with sharing class CLQ_Rules_Inspected_TriggerHandler extends CLQ_Trigger {
    public static final string COMPLAINT = 'Compliant';
    public static final string NON_COMPLAINT = 'Non-Compliant';
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger {
        get {
            if (BypassTrigger == null){
                BypassTrigger = false;
            } 
            return BypassTrigger;
        }
        set;
    }
    
    public static boolean HasUpdated;
    public override boolean getUpdateFlag()                 {   return HasUpdated;    }
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;   system.debug('before HasUpdated xx ' + newVal ); }
    
    //Calls the Base class Constructor
    public CLQ_Rules_Inspected_TriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
            boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) {
            super(newlistin, newMapin, oldlistin, oldMapin,
                isExecutingin, isInsertin, isUpdatein, isDeletein,
                isBeforein, isAfterin, isUndeletein, sizein);
                BypassInheritedTrigger = BypassTrigger;
                if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }       
    }    

    public override void afterinsert() {
        //TODO: maybe call deleteFindingsAndCAP here too?
    }
            
      
    public override void afterUpdate() {
        deleteFindingsAndCAP((List<CLQ_Rules_Inspected__c>) newList, (Map<id, CLQ_Rules_Inspected__c>) oldMap);
    }
    
    public void deleteFindingsAndCAP(List<CLQ_Rules_Inspected__c> newList, Map<id,CLQ_Rules_Inspected__c> oldMap) {
        
        Set<Id> rulesInspectedIds = new Set<Id>();
        
        for(CLQ_Rules_Inspected__c ri : newList) {
            rulesInspectedIds.add(ri.Id);
        }
        
        //get the Rules Inspected and Findings that were updated
        List<CLQ_Rules_Inspected__c> ruleInspectedlist;
        if(rulesInspectedIds!=null){
            ruleInspectedlist = [SELECT Id, CLQ_Result__c, (SELECT Id FROM Findings__r LIMIT 1999) FROM CLQ_Rules_Inspected__c WHERE Id in: rulesInspectedIds];
        }
        
        
        
        //System.debug('ri trigger handler-->' + ruleInspectedlist);
        
        //13527 start : added logic here to remove findings and caps from rules inspected if its compliant    
        Set<Id> findingsToDeleteIds = new Set<Id>();
        
        for(CLQ_Rules_Inspected__c ri : ruleInspectedlist) {
            //System.debug('ri.Findings__r-->' + ri.Findings__r);
            if(oldMap.size()!=0 && ri.CLQ_Result__c==COMPLAINT && oldMap.get(ri.id).CLQ_Result__c==NON_COMPLAINT) { //if changed to Compliant then we can delete findings
                for(CLQ_Findings__c finding : ri.Findings__r) {
                    findingsToDeleteIds.add(finding.Id);
                }
            }
        }
        
        //get all the caps for the findings we want to delete and delete them also
        if(findingsToDeleteIds!=null) {
             
            List<CLQ_Corrective_Action_Plan__c> capsToDelete = [SELECT Id FROM CLQ_Corrective_Action_Plan__c WHERE CLQ_Findings__c in: findingsToDeleteIds];
            
            //System.debug('capsToDelete-->' + capsToDelete);
        
            if(!capsToDelete.isEmpty()){
                delete capsToDelete;
            }
            	
        }
        
        
        /*
        if(findingsToDelete.size() > 0)
            delete findingsToDelete;
		*/
        //13527 end  
        
    }

}