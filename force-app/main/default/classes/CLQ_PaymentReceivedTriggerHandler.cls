/*Class Name : CLQ_PaymentReceivedTriggerHandler
 * Description : This class contains all logic/methods used in CLQ_ProgramTrigger on CLQ_Program__c object
 */
public with sharing class CLQ_PaymentReceivedTriggerHandler extends CLQ_Trigger {
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
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
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;    }

    //Calls the Base class Constructor
    public CLQ_PaymentReceivedTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <
            sObject > oldlistin, map < id, sObject > oldMapin,
            boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) {
            super(newlistin, newMapin, oldlistin, oldMapin,
                isExecutingin, isInsertin, isUpdatein, isDeletein,
                isBeforein, isAfterin, isUndeletein, sizein);
            BypassInheritedTrigger = BypassTrigger;
        }
        ////////////////////////////////     Boilerplate implementation  ////////////////////////////

    //Method to hold the logic for before insert on CLQ_Program__c object
    //@return : none

}