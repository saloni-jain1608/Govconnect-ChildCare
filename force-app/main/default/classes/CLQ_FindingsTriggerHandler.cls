/* Name : CLQ_FindingsTriggerHandler
* Description : 
*/
public with sharing class CLQ_FindingsTriggerHandler extends CLQ_Trigger 
{
    
    
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger {
        get {
            if (BypassTrigger == null) {BypassTrigger = false;}
            return BypassTrigger;
        }
        set;
    }
    
    //Calls the Base class Constructor
    public CLQ_FindingsTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
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
}