/*Class Name : CLQ_ProgramTrigger
* Description : This trigger contains all logic/methods for CLQ_Program__c object's trigger event. Details methods can be found in handler class
*/
trigger CLQ_ProgramTrigger on CLQ_Program__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_ProgramTriggerHandler Handler = new CLQ_ProgramTriggerHandler(
                                                        trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                                                        trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
                                                        trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger(); 
    }
}