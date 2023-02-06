/* Name : CLQ_UserTrigger
* Description : This trigger contains all logic/methods for User object's trigger event. Details methods can be found in handler class
*
*/

trigger CLQ_UserTrigger on User (after insert, after update,after delete, after undelete, before insert, before update,before delete) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_UserTriggerHandler Handler = new CLQ_UserTriggerHandler(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger();    
    }
}