trigger CLQ_RoomSpaceInspection on CLQ_Room_Space_Inspection__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_RoomSpaceInspectionTriggerHandler Handler = new CLQ_RoomSpaceInspectionTriggerHandler(
    trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete,
                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size); 
    
    Handler.ProcessTrigger();
    }
}