global without sharing class CLQ_120_90_60_30_Dy_Remndr_AnlRep_Schdl implements Schedulable {

    global void execute(SchedulableContext ctx) {
     CLQ_120_90_60_30_Dy_Remndr_AnlRep_Batch obj4 = new CLQ_120_90_60_30_Dy_Remndr_AnlRep_Batch();
Database.executeBatch(obj4);   
        
    }
}