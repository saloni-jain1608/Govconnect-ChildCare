global without sharing class CLQ_90_Priordate_notification_Schdl implements Schedulable {

    global void execute(SchedulableContext ctx) {
     CLQ_90_Priordate_notification_Batch obj2 = new CLQ_90_Priordate_notification_Batch();
Database.executeBatch(obj2);   
        
    }
}