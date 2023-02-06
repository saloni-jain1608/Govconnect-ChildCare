/* Name : CLQ_Rules_Inspected_Trigger
* Description : This trigger contains all logic/methods for Rules Inspected object's trigger event. Details methods can be found in handler class
* Created for TFS#13527
*/
trigger CLQ_Rules_Inspected_Trigger on CLQ_Rules_Inspected__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_Rules_Inspected_TriggerHandler Handler = new CLQ_Rules_Inspected_TriggerHandler(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}