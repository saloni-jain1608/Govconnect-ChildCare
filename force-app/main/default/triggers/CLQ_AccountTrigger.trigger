/* Name : CLQ_AccountTrigger
* Description : This trigger contains all logic/methods for Case object's trigger event. Details methods can be found in handler class
*
*/
trigger CLQ_AccountTrigger on Account (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_AccountTriggerHandler Handler = new CLQ_AccountTriggerHandler(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}