/* Name : CLQ_CaseTrigger_custom
* Description : This trigger contains all logic/methods for Case object's trigger event. Details methods can be found in handler class
*
*/
trigger CLQ_CaseTrigger_custom on CLQ_Case_Custom__c  (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_CaseTriggerHandler_custom Handler = new CLQ_CaseTriggerHandler_custom(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}