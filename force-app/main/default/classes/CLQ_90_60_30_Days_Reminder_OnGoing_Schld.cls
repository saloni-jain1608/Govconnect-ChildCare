global without sharing class CLQ_90_60_30_Days_Reminder_OnGoing_Schld implements Schedulable {

    global void execute(SchedulableContext ctx) {
     CLQ_90_60_30_Days_Reminder_OnGoing_Batch   obj1 = new CLQ_90_60_30_Days_Reminder_OnGoing_Batch();
Database.executeBatch(obj1,50);   
        
    }
}