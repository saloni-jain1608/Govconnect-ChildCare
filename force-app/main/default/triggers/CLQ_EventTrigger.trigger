trigger CLQ_EventTrigger on Event(before insert,after insert,before update,after update,before delete,after delete) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
  CLQ_EventTriggerHandler Handler = new CLQ_EventTriggerHandler(
                            trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                            trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                            trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
  Handler.ProcessTrigger();
  }
}