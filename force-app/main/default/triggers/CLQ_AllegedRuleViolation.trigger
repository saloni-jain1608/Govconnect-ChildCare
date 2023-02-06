trigger CLQ_AllegedRuleViolation on CLQ_Alleged_Rule_Violation__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
if(ExecutionControlSetting__c.getInstance(userinfo.getuserId()).Run_Trigger__c){
    CLQ_AllegedRuleViolationTgrHdlr_custom Handler = new CLQ_AllegedRuleViolationTgrHdlr_custom(
                trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
                trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete,
                trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
    Handler.ProcessTrigger();
    }
}