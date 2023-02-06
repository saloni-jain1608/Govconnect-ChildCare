/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_120_Day_Annual_InspDueRemndr_Schdl 
** Description      : Scheduled Class
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  Rahul Roy               03/05/19        1.0          TFS#14903 : Initial Build 
**  
**************************************************************************************************************/
global without sharing class CLQ_120_Day_Annual_InspDueRemndr_Schdl implements Schedulable{
    global void execute(SchedulableContext sc){
        CLQ_120_Day_Annual_InspDueRemndr_Batch b = new CLQ_120_Day_Annual_InspDueRemndr_Batch();
        database.executeBatch(b,Integer.valueOf(Label.CLQ_Default_BatchSize));
    }
}