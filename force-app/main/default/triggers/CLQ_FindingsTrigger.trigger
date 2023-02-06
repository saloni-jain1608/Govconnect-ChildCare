/*Class Name : CLQ_ProgramTrigger
* Description : This trigger contains all logic/methods for CLQ_Program__c object's trigger event. Details methods can be found in handler class
*/
trigger CLQ_FindingsTrigger on CLQ_Findings__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_FindingsTriggerHandler Handler = new CLQ_FindingsTriggerHandler(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}