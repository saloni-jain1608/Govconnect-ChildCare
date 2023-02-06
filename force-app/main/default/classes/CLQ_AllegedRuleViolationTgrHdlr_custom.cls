public with sharing class CLQ_AllegedRuleViolationTgrHdlr_custom extends CLQ_Trigger {
    
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
    public override boolean getUpdateFlag() { return HasUpdated; }
    public override void setUpdateFlag(boolean newVal) { HasUpdated = newVal; }
    public static final String Case_Custom = 'Case_Custom__c';
    public static final String ruleCount = 'ruleCount';
    
    //Calls the Base class Constructor
    public CLQ_AllegedRuleViolationTgrHdlr_custom (list < sObject > newlistin, map < id, sObject > newMapin, list <
                                                   sObject > oldlistin, map < id, sObject > oldMapin,
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
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    public override void AfterInsert() {
        recalcCaseAllegedRuleCount((list < CLQ_Alleged_Rule_Violation__c > ) newList);
    }
    public override void AfterDelete() {
        recalcCaseAllegedRuleCount( (list < CLQ_Alleged_Rule_Violation__c > ) oldList);
    }
    
    public void recalcCaseAllegedRuleCount(list < CLQ_Alleged_Rule_Violation__c > theList){
        //gather a list of caseids for recalc
        set<id> CustomcaseList = new set<id>();
        
        for (CLQ_Alleged_Rule_Violation__c arv : theList) {
            if(arv.Case_Custom__c!=null){
                CustomcaseList.add(arv.Case_Custom__c);
            }
        }
        
        //retrieve the custom cases found above into a list
        list<CLQ_Case_Custom__c> CustomcasesToUpdate;
        if(CustomcaseList != null){
            CustomcasesToUpdate = [select id, CLQ_Alleged_Violation_Rule_Count__c from CLQ_Case_Custom__c where id in :CustomcaseList];
        }
        //retrieve an aggregate list of custom case + count of alleged rules
        AggregateResult[] CustomgroupedResults;
        if(CustomcaseList !=null){
            CustomgroupedResults = [SELECT Case_Custom__c, count(name) ruleCount FROM CLQ_Alleged_Rule_Violation__c where Case_Custom__c in :CustomcaseList group by Case_Custom__c];
        }
        //put the above aggregate results into a map
        map<String,integer> CustomcaseAVRCountMap = new map<String,integer>();
        
        for (AggregateResult ar : CustomgroupedResults){
            CustomcaseAVRCountMap.put(String.valueof(ar.get(Case_Custom)), Integer.valueof(ar.get(ruleCount)));
        }
        //now loop through custom cases and set the new values for the arv counts
        
        for (CLQ_Case_Custom__c upCase : CustomcasesToUpdate) {
            integer i;
            if(CustomcaseAVRCountMap.size()!=0){
                i = CustomcaseAVRCountMap.get(upCase.id);
            }
            if (i == null) {i = 0;}
            upCase.CLQ_Alleged_Violation_Rule_Count__c = i;
            
        }
        
        //update the custom cases
        if (CustomcasesToUpdate != null && CustomcasesToUpdate.size() > 0){
            try{
                update CustomcasesToUpdate;
            }catch(Exception e){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                System.debug ('Exception is: '+e.getMessage());
            }
            
        }
    }
    
}