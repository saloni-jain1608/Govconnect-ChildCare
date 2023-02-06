public with sharing class CLQ_StandardDocumentTriggerHandler extends CLQ_Trigger {
    
    
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
    
    //Calls the Base class Constructor
    public CLQ_StandardDocumentTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
                                    boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
                                    boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) 
                                    {
                                        super(newlistin, newMapin, oldlistin, oldMapin,
                                              isExecutingin, isInsertin, isUpdatein, isDeletein,
                                              isBeforein, isAfterin, isUndeletein, sizein);
                                        BypassInheritedTrigger = BypassTrigger;
                                        if(!(BypassInheritedTrigger || BypassAllTriggers)){            
                                            BypassInheritedTrigger = BypassSelectiveTriggers;
                                        }
                                    }
    
    
    
	public override void afterinsert() {
		deleteReplaceDocument((list < CLQ_Standard_Document__c > ) newList);
	}
	
	private void deleteReplaceDocument(List<CLQ_Standard_Document__c> lstStdDoc){
		system.debug('list ----- '+lstStdDoc);
	}    
    
}