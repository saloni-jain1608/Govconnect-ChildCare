/**************************************************************************************************************
** Name             : CLQ_RoomOrGrptgrHandler
** Description      : Handles Room Space Information operation.
** Assumptions      : 
** Version          : 1.3
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version		Description
**------------------------------------------------------------------------------------------------------------
**	IncapsulateDevTeam		Oct-2016		1.0			Created
**	Neetu Ojha				18-Oct-2017		1.2			TFS#11820 : Update Room Space Info on Prog 
**	Neetu Ojha				21-Nov-2017		1.3			TFS#11909 : Changed Class modifier to Without sharing
**************************************************************************************************************/ 

public with sharing class CLQ_RoomOrGrptgrHandler extends CLQ_Trigger {
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger {
        get {
            if (BypassTrigger == null){
                BypassTrigger = false;
            } 
            return BypassTrigger;
        }
        set;
    }
    
    public static boolean HasUpdated;
    public override boolean getUpdateFlag()             {   return HasUpdated; }
    public override void setUpdateFlag(boolean newVal)  {   HasUpdated = newVal; }
    
        //Calls the Base class Constructor
    public CLQ_RoomOrGrptgrHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <sObject > oldlistin, 
    							map < id, sObject > oldMapin, boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            					boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) {
		super(newlistin, newMapin, oldlistin, oldMapin,isExecutingin, isInsertin, isUpdatein, isDeletein,isBeforein, isAfterin, isUndeletein, sizein);
			BypassInheritedTrigger = BypassTrigger;

		if(!(BypassInheritedTrigger || BypassAllTriggers)){            
			BypassInheritedTrigger = BypassSelectiveTriggers;
		}
	}

    public override void AfterInsert() {
    }
    
    public override void AfterUpdate() {
    }

    //11820 Starts
	@InvocableMethod(label='UpdateRoomSpaceDetailsOnProgram' description='Updates Room Space details on program')
  	public static void updateRoomSpaceOnProgram(List<ID> lstPrgIds) {
  		system.debug('Id --- '+lstPrgIds);
  		
  		Map<Id, CLQ_Program__c> mapPrgToUpdate = new Map<Id,CLQ_Program__c>();
  		
  		try{
  			//To udpate Total number of Rooms
            if(lstPrgIds!=null){
                for(CLQ_Program__c prgObj : [Select Id, CLQ_Total_of_Rooms__c, CLQ_Total_of_Rooms_under_21_2__c, (Select Id from Rooms_Spaces__r where CLQ_Currently_In_Use__c ='Yes' AND CLQ_Approved_Room_Space__c = true) 
	  									from CLQ_Program__c where Id IN : lstPrgIds]){
  				prgObj.CLQ_Total_of_Rooms__c = prgObj.Rooms_Spaces__r.size();
	  			mapPrgToUpdate.put(prgObj.Id, prgObj);							
			}
            }
	  		//To update Total number of Rooms (under 2 1/2)
            if(lstPrgIds!=null){
                for(CLQ_Program__c prgObj : [Select Id, CLQ_Total_of_Rooms__c, CLQ_Total_of_Rooms_under_21_2__c, (Select Id from Rooms_Spaces__r where CLQ_Currently_In_Use__c ='Yes' 
	  													AND CLQ_Approved_for_under_2_1_2__c = 'Yes' AND CLQ_Used_by_Under_or_Over_2_1_2__c != 'Over') 
	  									from CLQ_Program__c where Id IN : lstPrgIds]){
	  				
  				if(mapPrgToUpdate.containsKey(prgObj.Id)){
  					mapPrgToUpdate.get(prgObj.Id).CLQ_Total_of_Rooms_under_21_2__c = prgObj.Rooms_Spaces__r.size();	
  				}else{
  					prgObj.CLQ_Total_of_Rooms_under_21_2__c = prgObj.Rooms_Spaces__r.size();
  					
  					mapPrgToUpdate.put(prgObj.Id, prgObj);	
  				}
			}
            }
	  		
			
			if(!mapPrgToUpdate.isEmpty()){
				CLQ_ProgramTriggerHandler.BypassTrigger = true;
				update mapPrgToUpdate.values();
			}
  		}catch(Exception ex){
  			system.debug('Exception occured in : updateTotalRoomsOnProgram --'+ex.getMessage());
  			Integration_Transaction_Logs.LogError('SFDC-001.2', ex.getMessage() ,'' ,String.valueOf(ex.getLineNumber()),'','Salesforce Exception -- CLQ_RoomOrGrptgrHandler');
  		}
  	}
  	//11820 Ends    
}