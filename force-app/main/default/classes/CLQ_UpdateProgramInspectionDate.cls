/* 
** Name: CLQ_UpdateProgramInspectionDate
** Description: Used in PB: Update_PT_status_from_inspection_status / Update Program based on Inspection and CLQ_InspectionTriggerHandler
** 
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version         Description
**  Soufin Rahimeen         9/21/2018       1.1             TFS : 13857 - Re-wrote logic to get the latest Last Visit Date from Inspection and display that on Program's Last Inspection Date
**  Pradeep Ravi            8/21/2019       1.2             TFS : 15786 - Updated the status of the inspection 
**************************************************************************************************************/
public with sharing class CLQ_UpdateProgramInspectionDate {
    
    //13857 this can be called by both methods
    public static void updateProgramsFromProgramList(List<CLQ_Program__c> programsToCheck) {
    	
    	try{
    		
    		List<CLQ_Program__c> progLstToUpdate = new List<CLQ_Program__c>();

            Boolean updated = false; //has the prog been updated

            for(CLQ_Program__c prog : programsToCheck) { //go through all the programs
                if(prog.Inspections__r.isEmpty()) { //if no inspections exist

                    prog.CLQ_Last_Inspection_Date__c = null;
                    progLstToUpdate.add(prog);
                    }
                else {
                    for(CLQ_Inspection__c ins : prog.Inspections__r) { //else get the first in list and set
                        if(updated ==false && ins.CLQ_Last_Visit_Date__c != null) {

                            prog.CLQ_Last_Inspection_Date__c = ins.CLQ_Last_Visit_Date__c;
                            progLstToUpdate.add(prog);
                            updated = true;
                        }   
                    }
                }
                
            }


            if(!progLstToUpdate.isEmpty())
            {
                CLQ_ProgramTriggerHandler.BypassTrigger = true; //added after review
                update progLstToUpdate;
                CLQ_ProgramTriggerHandler.BypassTrigger = false;
            }   
            
    	} catch(exception e)
        {
            system.debug('Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.2',e.getMessage()  , 'Update Program From Inspection for Last Inspection Date Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }	
    	
    }
    
    //this method is called from process builder and is designed to be independent from triggers
    @InvocableMethod
    public static void updatePro(List<Id> ids)
    {
        final String ANNUAL = 'Annual';
        final String COMPLIANCE = 'Compliance';
        final String PROVISIONAL = 'Provisional';
        
        try
        {
           
            //13857 start
            Set<String> inspectionTypes = new Set<String>{ANNUAL, COMPLIANCE, PROVISIONAL}; //all the inspection types to consider
            Set<Id> programIds = new Set<Id>();
            List<CLQ_Program__c> progLstToUpdate = new List<CLQ_Program__c>();
            
            //have to get all inspection, the condition will be in the programsToCheck query
            List<CLQ_Inspection__c> insList;
            if(ids != null){
                insList = [Select Id, CLQ_Program__c, CLQ_Inspection_Status__c, CLQ_Inspection_Type__c
                                    FROM CLQ_Inspection__c 
                                    WHERE Id in : ids];
            }                      

            
            
            if (!insList.isEmpty()) {
                
                for(CLQ_Inspection__c ins : insList) {
                    programIds.add(ins.CLQ_Program__c);
                }
                
                
                
                                    
                //get the programs along with all the related inspections sorted by latest first
                List<CLQ_Program__c> programsToCheck = [SELECT Id, CLQ_Last_Inspection_Date__c, (SELECT Id, CLQ_Last_Visit_Date__c,CLQ_Inspection_Type__c FROM Inspections__r WHERE CLQ_Inspection_Status__c='Under Approver Review' AND CLQ_Inspection_Type__c in: inspectionTypes ORDER BY CreatedDate DESC) FROM CLQ_Program__c WHERE Id in: programIds];
                                            
                updateProgramsFromProgramList(programsToCheck); //this will update the programs


            }

            //13857 end

        }
        catch(exception e)
        {
            system.debug('Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.2',e.getMessage()  , 'Update Program From Inspection for Last Inspection Date Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
    }
}