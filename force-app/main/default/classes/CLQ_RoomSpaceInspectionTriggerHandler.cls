/**************************************************************************************************************
** Name             : CLQ_RoomSpaceInspectionTriggerHandler
** Description      : 
** Assumptions      : 
** Version          : 1.4
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version		Description
**------------------------------------------------------------------------------------------------------------
**	Dev Team				July-2016		1.0			Created
**	Ramana Gurivelli		29-Aug-2017		1.1			Bug# 11565: To predefault Record Type for the records created from Mobile app.
**	Neetu Ojha				08-Nov-2017		1.2			TFS#11768 : To update RSI Mobile Record Type as per Record Type	
**  Pavan Ayta				11-Dec-2017		1.3			TFS#11920: Placed Null Checks
**	Neetu Ojha				06-Apr-2018		1.4			TFS#12138 : Redefined Capacity calculation
**************************************************************************************************************/ 
public with sharing class CLQ_RoomSpaceInspectionTriggerHandler extends CLQ_Trigger{
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static final string FCC_TYPEA_HOME = 'FCC - Type A Home';
    public static final string FCC_TYPEB_HOME = 'FCC - Type B Home';
    public static final string YES = 'Yes';
    public static boolean BypassTrigger{
        get
        {
            if (BypassTrigger == null){
                BypassTrigger = false;
            } 
            return BypassTrigger;
        }
        set;
    }
    
    public static boolean HasUpdated;
     
    public override boolean getUpdateFlag(){
        return HasUpdated;
    }
    
    public override void setUpdateFlag(boolean newVal){
        HasUpdated = newVal;
    }
    
    //Calls the Base class Constructor
    public CLQ_RoomSpaceInspectionTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <
                                        sObject > oldlistin, map < id, sObject > oldMapin,
                                        boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
                                        boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein){
        super(newlistin, newMapin, oldlistin, oldMapin,
              isExecutingin, isInsertin, isUpdatein, isDeletein,
              isBeforein, isAfterin, isUndeletein, sizein);
        BypassInheritedTrigger = BypassTrigger;
        if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
    }
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
   
    public override void BeforeInsert() {
        //SetType((list < Event > ) newList);
        UpdateRecTypeFromMobile((list < CLQ_Room_Space_Inspection__c > ) newList); //Bug# 11565
    }
    
    public override void BeforeUpdate() {
        
    }

    public override void AfterInsert() {
    	roomSpaceChildrenUpdate((list < CLQ_Room_Space_Inspection__c > ) newList , false);          
    }
    
    public override void AfterUpdate() {
    	roomSpaceChildrenUpdate((list < CLQ_Room_Space_Inspection__c > ) newList, false);          
    }
    
    public override void AfterDelete() {
    	roomSpaceChildrenUpdate((list < CLQ_Room_Space_Inspection__c > ) oldList, true);          
    }
    
    //12138 Starts
    public void roomSpaceChildrenUpdate (list < CLQ_Room_Space_Inspection__c > roomSpaceInsList , boolean isDelete){
    	Id indoorRSRecTypeId = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
    	Map<Id,List<CLQ_Room_Space_Inspection__c>> inspRoomSpaceMap = new Map<Id,List<CLQ_Room_Space_Inspection__c>>();
        Map<Id,Id> roomSpaceInspectionMap = new Map<Id,Id>();
        List<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList;
        List<CLQ_Inspection__c> insListToUpdate = new List<CLQ_Inspection__c>();
        
        
        for(CLQ_Room_Space_Inspection__c roomspace:roomSpaceInsList){
            roomSpaceInspectionMap.put(roomspace.Id, roomspace.CLQ_Inspection__c);
        }
        
		if(isDelete) {
            system.debug('');
            if(indoorRSRecTypeId!=null){
                roomSpaceInspectionList = [Select Id,Name, CLQ_Approved_for_under_2_1_2__c, CLQ_Calc_Nb_of_Child_Allowed_Indoor__c,
											CLQ_Inspection__c, CLQ_Inspection__r.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c
	                                      From CLQ_Room_Space_Inspection__c 
	                                      Where RecordTypeId =: indoorRSRecTypeId
	                                      AND CLQ_Inspection__c in: roomSpaceInspectionMap.values() 
	                                      AND (CLQ_Approved_Room_Space__c = true  
	                                      OR CLQ_Approved_for_under_2_1_2__c = 'Yes')
	                                      AND CLQ_Room_Space_Type__c = 'Primary Space'
	                                      AND CLQ_Currently_In_Use__c = 'Yes'
	                                      AND Id not in : roomSpaceInspectionMap.keySet()];
            }
		}else{
            //System.debug('');
            if(indoorRSRecTypeId!=null){
                roomSpaceInspectionList = [Select Id,Name, CLQ_Approved_for_under_2_1_2__c, CLQ_Calc_Nb_of_Child_Allowed_Indoor__c,
											CLQ_Inspection__c, CLQ_Inspection__r.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c
                                          From CLQ_Room_Space_Inspection__c 
                                          Where RecordTypeId =: indoorRSRecTypeId
                                          AND CLQ_Inspection__c in: roomSpaceInspectionMap.values()
                                          AND (CLQ_Approved_Room_Space__c = true  
                                          OR CLQ_Approved_for_under_2_1_2__c = 'Yes') 
                                          AND CLQ_Room_Space_Type__c = 'Primary Space'
                                          AND CLQ_Currently_In_Use__c = 'Yes'];
            }
			
        }
        
		for(CLQ_Room_Space_Inspection__c roomSpaceIns: roomSpaceInspectionList){
			if(inspRoomSpaceMap.containsKey(roomSpaceIns.CLQ_Inspection__c)){
                 inspRoomSpaceMap.get(roomSpaceIns.CLQ_Inspection__c).add(roomSpaceIns);
             }else{
				inspRoomSpaceMap.put(roomSpaceIns.CLQ_Inspection__c, new List<CLQ_Room_Space_Inspection__c>{roomSpaceIns});
			}
		}
        
        if(!inspRoomSpaceMap.isEmpty()){
			for(Id insID:inspRoomSpaceMap.keySet()){
                decimal maxCapUnder2AndHalf = 0;
                decimal calcMaxCapacity = 0;
				
				for(CLQ_Room_Space_Inspection__c roomObj:inspRoomSpaceMap.get(insID)){
					//PA - 11920 Starts
					if(roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c != null){
						calcMaxCapacity = roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c + calcMaxCapacity;
						
						if(roomObj.CLQ_Inspection__r.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_TYPEA_HOME && calcMaxCapacity > 12){
							calcMaxCapacity = 12;
						}
						if(roomObj.CLQ_Inspection__r.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_TYPEB_HOME && calcMaxCapacity > 6){
							calcMaxCapacity = 6;
						}
												
						if(roomObj.CLQ_Approved_for_under_2_1_2__c == Yes){
							maxCapUnder2AndHalf = maxCapUnder2AndHalf + roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c;
							if(roomObj.CLQ_Inspection__r.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_TYPEB_HOME && maxCapUnder2AndHalf > 3){
								maxCapUnder2AndHalf = 3;
							}
						}
					}
					//PA - 11920 Ends
				}
				
				//Max Capacity Under 2.5 year cannot be greater than calculated Max Capacity
				if(maxCapUnder2AndHalf > calcMaxCapacity){
					maxCapUnder2AndHalf = calcMaxCapacity;
				}
								
                CLQ_Inspection__c insObj = new CLQ_Inspection__c();
                insObj.Id = insID;
                insObj.Calculated_Max_Capacity__c = calcMaxCapacity;
                insObj.Max_Capacity_Under_2_1_2_Years__c = maxCapUnder2AndHalf;
                insListToUpdate.add(insObj);
            }
        }
        
        system.debug('insListToUpdate --- '+insListToUpdate);
        try{
        	if(!insListToUpdate.isEmpty()){
	            update insListToUpdate;
	        }
        }catch(Exception e){
			Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_RoomSpaceInspectionTriggerHandler');
        }
        
    }//end of method roomSpaceChildrenUpdate
    //12138 Ends
    public static final String EMPTY_STRING = '';   
    //Bug# 11565: Created new method to predefault Record Type for records created from Mobile app.
    public void UpdateRecTypeFromMobile(list<CLQ_Room_Space_Inspection__c> triggernew){
        for(CLQ_Room_Space_Inspection__c rsi: triggernew){
            String MobileRT = rsi.RSI_Mobile_Record_Type__c;
            if(MobileRT != EMPTY_STRING && MobileRT != null){
                rsi.RecordTypeId = Schema.sObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByName().get(MobileRT).getRecordTypeId();
            }
            //11768 Starts
            if((MobileRT == EMPTY_STRING || MobileRT == null) && rsi.RecordTypeId != null){
            	rsi.RSI_Mobile_Record_Type__c = Schema.sObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosById().get(rsi.RecordTypeId).getName();
            }
            //11768 Ends
        }
    }//end of method UpdateRecTypeFromMobile
}