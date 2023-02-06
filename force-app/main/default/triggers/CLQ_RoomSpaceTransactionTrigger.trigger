/* Name :
* Description :
*/
trigger CLQ_RoomSpaceTransactionTrigger on CLQ_Room_Space_Transaction__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_RoomSpaceTransactionTriggerHandler Handler = new CLQ_RoomSpaceTransactionTriggerHandler (
                                    trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                    trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                    trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}