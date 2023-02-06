/* Name : CLQ_RoleTrigger
* Description : This trigger contains all logic/methods for CLQ_Role__c object's trigger event. Details methods can be found in handler class
*
*/
trigger CLQ_RoleTrigger on CLQ_Role__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_RoleTriggerHandler Handler = new CLQ_RoleTriggerHandler (
                                    trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                    trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                    trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}