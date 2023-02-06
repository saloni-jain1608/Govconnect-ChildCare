/*************************************************************************************************************
**************************************************************************************************************
** Name             : Schedule_Inspection_Rating
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
** Ankush R Relekar	     12/14/2021		      1.0	    Initial Build 
** 		
**************************************************************************************************************/

global with sharing class Schedule_Inspection_Rating implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        Schedule_Inspection_Rating_batch ratingbatch=new Schedule_Inspection_Rating_batch();
        ID batchprocessid = Database.executeBatch(ratingbatch);
        system.debug('batchprocessid'+ batchprocessid);
        
    }
}