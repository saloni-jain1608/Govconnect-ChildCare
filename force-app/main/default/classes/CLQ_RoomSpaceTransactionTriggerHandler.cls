/**************************************************************************************************************
** Name             : CLQ_RoomSpaceTransactionTriggerHandler
** Description      : Handles RoomSpaceTransaction methods
** Assumptions      : 
** Version          : 1.5
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version		Description
**------------------------------------------------------------------------------------------------------------
**  Prakriti Biswas         9/19/17         1.1         TFS#11648 : Using CLQ_Calc_Nb_of_Child_Allowed_Indoor__c for footApp Math Calculation for ODE and CC 
** 	Soufin Rahimeen			02/14/2018		1.2			TFS#11958 : Added upper limits to max value
**	Neetu Ojha				04/16/2018		1.3			TFS#12138 : Redefined Capacity calculation
**	Neetu Ojha				05/10/2018		1.4			TFS#12218 : Added null check
**	Soufin Rahimeen			07/26/2018		1.5			TFS#12150 : Added logic to update Transaction Updated flag on PT
**  Rohit Gowrishetty		02/22/2019		1.6			TFS#15095 : Added logic to check for reviewer before deleting the RmSpace Records 
**************************************************************************************************************/ 

public with sharing class CLQ_RoomSpaceTransactionTriggerHandler extends CLQ_Trigger 
{
    
    Public static final string Reviewer='Reviewer';
    Public static final string TD='<td>';
    Public static final string FCC_Type_A_Home='FCC - Type A Home';
    Public static final string FCC_Type_B_Home='FCC - Type B Home';
    Public static final string YES='Yes';
    Public static final string UPDATESTR='update';
    Public static final string INSERTSTR='insert';
    Public static final string DELETESTR='delete';
    
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
    
    public static final String headerValue = '<table border="1" rules="all" style="padding-top:3rem;padding-bottom:3rem;"> <thead> <tr> <th>Field Name</th> <th>Original Value</th> <th>New Value</th> </tr> </thead> <tbody>'; 
    public static final String footerValue = '</tbody></table> <br><br>';
    public static final String empty_string = '';
    //Calls the Base class Constructor
    public CLQ_RoomSpaceTransactionTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
                                    boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
                                    boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) {
                                        super(newlistin, newMapin, oldlistin, oldMapin,
                                              isExecutingin, isInsertin, isUpdatein, isDeletein,
                                              isBeforein, isAfterin, isUndeletein, sizein);
                                        BypassInheritedTrigger = BypassTrigger;
                                                if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
                                    }
   public override void AfterInsert() {
        updateCapacityOnProgTransacation((list < CLQ_Room_Space_Transaction__c > ) newList , false); //12138
        updateProgramTransaction((list < CLQ_Room_Space_Transaction__c > ) newList, (map < id, CLQ_Room_Space_Transaction__c > ) oldMap, 'insert'); //12150
    }
    
    public override void AfterUpdate() {
        updateCapacityOnProgTransacation((list < CLQ_Room_Space_Transaction__c > ) newList , false); //12138
        updateProgramTransaction((list < CLQ_Room_Space_Transaction__c > ) newList, (map < id, CLQ_Room_Space_Transaction__c > ) oldMap,  'update'); //12150
    }
    
    public override void BeforeUpdate() {
        buildFieldChangeHtmlTable((List <CLQ_Room_Space_Transaction__c> ) newList, (Map < Id, CLQ_Room_Space_Transaction__c > ) OldMap);
    }
    
    //12138 starts
    public override void AfterDelete() {
    	updateCapacityOnProgTransacation((list < CLQ_Room_Space_Transaction__c > ) oldList, true);
    	updateProgramTransaction((list < CLQ_Room_Space_Transaction__c > ) newList, (Map < Id, CLQ_Room_Space_Transaction__c > ) OldMap, 'delete'); //12150       
    }    
    //12138 Ends
    
    //15095 - Starts
    public override void BeforeDelete(){
        checkIfReviewerIsDeleting((list < CLQ_Room_Space_Transaction__c > ) oldList, true);
    }
    
    public void checkIfReviewerIsDeleting( list<CLQ_Room_Space_Transaction__c>  oldList, Boolean isDelete){
        
       // List<CLQ_Room_Space_Transaction__c> rmSpaceTrans = new List<CLQ_Room_Space_Transaction__c> ();
        Map<Id, Id> mapOfRmSpAndPT = new Map<Id,Id>();
        
        for (CLQ_Room_Space_Transaction__c rst : oldList){
        	if(rst.CLQ_Program_Transaction__c!=null){
                mapOfRmSpAndPT.put(rst.Id,rst.CLQ_Program_Transaction__c);
            }
		}
        
        if(!mapOfRmSpAndPT.isEmpty()){
        	Map<Id,CLQ_Program_Transaction__c> MapPT = new Map<Id,CLQ_Program_Transaction__c>([SELECT id ,CLQ_Assigned_To__c,CLQ_Transaction_Assigned_To__c from CLQ_Program_Transaction__c where id in :mapOfRmSpAndPT.values()]);
		  	String profileId = UserInfo.getProfileId();
            String profileName = UserInfo.getName();
            //System.debug('profileName ' + profileName);
            
            for(CLQ_Room_Space_Transaction__c rst : oldList){
            Clq_Program_Transaction__c  pt =    MapPT.get(mapOfRmSpAndPT.get(rst.Id));
                //System.debug('Trans assignd to '+ pt.CLQ_Assigned_To__c );
                if(!profileName.containsIgnoreCase(Reviewer)){
                   // System.debug('is it coming inside--1');
                    Continue;
                }
                else if(profileName.containsIgnoreCase(Reviewer) && profileName !=pt.CLQ_Assigned_To__c ){
                    System.debug('is it coming inside--2');
                    //rst.addError('Only Reviewer assigned to Program Transaction can be able to delete the Room space records.');
            	}
        	}
    	}
    }
    //15095 - Ends
    public void buildFieldChangeHtmlTable(list < CLQ_Room_Space_Transaction__c > newList, map < id, CLQ_Room_Space_Transaction__c > oldMap){
      
        for (CLQ_Room_Space_Transaction__c rst : newList){
            string htmlTableValue = empty_string;
            string oldChangeTableHtml = empty_string;
            map<string, string> modifiedHtmlMap = new map<string, string>();
            map<string, string> originalHtmlMap = new map<string, string>();
            //first pull in the original field value and parse into map
            system.debug('******LD -----'+rst.clq_formatted_change_table__c);
            if (rst.clq_formatted_change_table__c != null ){
                oldChangeTableHtml = rst.clq_formatted_change_table__c.substringbetween('<tbody>','</tbody>');
            }
            list<string> listVals = oldChangeTableHtml.split('<tr>');
            for (string fieldVal : listVals){
                system.debug('value of splitarray ' + fieldVal);
                system.debug('value of td tags ' + fieldVal.substringbetween('<td>','</td>'));
                if (fieldVal.substringbetween(TD,TD) != null){
                    originalHtmlMap.put(fieldVal.substringbetween('<td>','</td>').trim(),'<tr>' + fieldVal);
                }
            }

            //now get the diff fields into the html table
            if(oldMap.size()!=0){
            modifiedHtmlMap = CLQ_CloneUtility.FindModifiedFieldsRoomSpaceTrans(rst,oldMap.get(rst.id));
            }
            //now check the originalHtmlMap and replace anything that was changed from modified map
            for (string modFieldNm : modifiedHtmlMap.keyset()){
                system.debug('value of lookup field' + modFieldNm + 'fff');
                if(originalHtmlMap.size()!=0 && modifiedHtmlMap.size()!=0){
                string test = originalHtmlMap.get(modFieldNm);
                system.debug('value of existing field' + test);
                originalHtmlMap.put(modFieldNm,modifiedHtmlMap.get(modFieldNm));            
            }
            }
            system.debug('*****value of originalHtmlMap after mod ' + originalHtmlMap);
           
            if(!originalHtmlMap.isEmpty()){  //LD
                //rebuild the html table value
                htmlTableValue += headerValue;
                for(string htmlVal : originalHtmlMap.values()){
                    htmlTableValue += htmlVal; 
                }
                
                //wrap the end of the table
                htmlTableValue += footerValue;
                rst.clq_formatted_change_table__c = htmlTableValue;
            }
        }

    }
    
    //12138 Starts
    private static void updateCapacityOnProgTransacation(list < CLQ_Room_Space_Transaction__c > lstRoomSpaceTrans , boolean isDelete){
    	
    	Id indoorRSRecTypeId = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Indoor_Room_Space').getRecordTypeId();
    	Map<Id,List<CLQ_Room_Space_Transaction__c>> mapPTRoomSpace = new Map<Id,List<CLQ_Room_Space_Transaction__c>>();
        Map<Id,Id> mapRoomSpacePTId = new Map<Id,Id>();
        List<CLQ_Room_Space_Transaction__c> lstRoomSpaceT;
        List<CLQ_Program_Transaction__c> lstProgTransToUpdate = new List<CLQ_Program_Transaction__c>();
        
        system.debug('lstRoomSpaceTrans---'+lstRoomSpaceTrans);
        
        for(CLQ_Room_Space_Transaction__c rstObj:lstRoomSpaceTrans){
        	if(rstObj.CLQ_Program_Transaction__c != null){ //12218
            	mapRoomSpacePTId.put(rstObj.Id, rstObj.CLQ_Program_Transaction__c);
        	}
        }
        
		if(isDelete) {
            if(indoorRSRecTypeId != null && mapRoomSpacePTId.values() != null){
                lstRoomSpaceT = [Select Id,Name, CLQ_Approved_for_under_2_1_2__c, CLQ_Calc_Nb_of_Child_Allowed_Indoor__c,
											CLQ_Program_Transaction__c, CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c
	                                      From CLQ_Room_Space_Transaction__c 
	                                      Where RecordTypeId =: indoorRSRecTypeId
	                                      AND CLQ_Program_Transaction__c in: mapRoomSpacePTId.values() 
	                                      AND (CLQ_Approved_Room_Space__c = true  
	                                      OR CLQ_Approved_for_under_2_1_2__c = 'Yes')
	                                      AND CLQ_Room_Space_Type__c = 'Primary Space'
	                                      AND CLQ_Currently_In_Use__c = 'Yes'
	                                      AND Id not in : mapRoomSpacePTId.keySet()
	                                      AND CLQ_Program_Transaction__r.CLQ_Transaction_Status__c != 'Approved'];
            }
		}else{
            if(indoorRSRecTypeId != null && mapRoomSpacePTId.values() != null){
                lstRoomSpaceT = [Select Id,Name, CLQ_Approved_for_under_2_1_2__c, CLQ_Calc_Nb_of_Child_Allowed_Indoor__c,
                                          CLQ_Program_Transaction__c, CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c
                                          From CLQ_Room_Space_Transaction__c 
                                          Where RecordTypeId =: indoorRSRecTypeId
                                          AND CLQ_Program_Transaction__c in: mapRoomSpacePTId.values()
                                          AND (CLQ_Approved_Room_Space__c = true  
                                          OR CLQ_Approved_for_under_2_1_2__c = 'Yes') 
                                          AND CLQ_Room_Space_Type__c = 'Primary Space'
                                          AND CLQ_Currently_In_Use__c = 'Yes'
                                          AND CLQ_Program_Transaction__r.CLQ_Transaction_Status__c != 'Approved'];
            }
        }
        
		for(CLQ_Room_Space_Transaction__c roomSpaceIns: lstRoomSpaceT){
			if(mapPTRoomSpace.containsKey(roomSpaceIns.CLQ_Program_Transaction__c)){
                 mapPTRoomSpace.get(roomSpaceIns.CLQ_Program_Transaction__c).add(roomSpaceIns);
             }else{
				mapPTRoomSpace.put(roomSpaceIns.CLQ_Program_Transaction__c, new List<CLQ_Room_Space_Transaction__c>{roomSpaceIns});
			}
		}
        
        if(!mapPTRoomSpace.isEmpty()){
			for(Id ptId:mapPTRoomSpace.keySet()){
                decimal maxCapUnder2AndHalf = 0;
                decimal calcMaxCapacity = 0;
				
				for(CLQ_Room_Space_Transaction__c roomObj:mapPTRoomSpace.get(ptId)){
					if(roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c != null){
						calcMaxCapacity = roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c + calcMaxCapacity;
						
						if(roomObj.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_Type_A_Home && calcMaxCapacity > 12){
							calcMaxCapacity = 12;
						}
						if(roomObj.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_Type_B_Home && calcMaxCapacity > 6){
							calcMaxCapacity = 6;
						}
						
						if(roomObj.CLQ_Approved_for_under_2_1_2__c == YES){
							maxCapUnder2AndHalf = maxCapUnder2AndHalf + roomObj.CLQ_Calc_Nb_of_Child_Allowed_Indoor__c;
							if(roomObj.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c == FCC_Type_B_Home && maxCapUnder2AndHalf > 3){
								maxCapUnder2AndHalf = 3;
							}						
						}			
					}
					system.debug('maxCapUnder2AndHalf is:' +maxCapUnder2AndHalf);
					system.debug('calcMaxCapacity is:' +calcMaxCapacity);
				}
				//Max Capacity Under 2.5 year cannot be greater than calculated Max Capacity
				if(maxCapUnder2AndHalf > calcMaxCapacity){
					maxCapUnder2AndHalf = calcMaxCapacity;
				}
                CLQ_Program_Transaction__c ptObj = new CLQ_Program_Transaction__c();
                ptObj.Id = ptId;
                ptObj.CLQ_Calculated_Maximum_Capacity__c = calcMaxCapacity;
                ptObj.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c = maxCapUnder2AndHalf;
                lstProgTransToUpdate.add(ptObj);
            }
        }
        
        system.debug('lstProgTransToUpdate --- '+lstProgTransToUpdate);
        try{
        	if(!lstProgTransToUpdate.isEmpty()){
	            update lstProgTransToUpdate;
	        }
        }catch(Exception e){
			Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_RoomSpaceTransactionTriggerHandler');
        }
    }
    //12138 Ends
    
    //12150 starts
	//update PT transaction updated field
	public void updateProgramTransaction(List<CLQ_Room_Space_Transaction__c> newList, Map<Id, CLQ_Room_Space_Transaction__c> oldMap, String operationType) {
		Id userId = userinfo.getProfileId();
		system.debug('User Id ---- '+userId);
		
		if(Label.CommunityProfileIds.contains(userId)){
			//System.debug('community user found-->');
			
			Set<Id> programTransIdSet = new Set<Id>(); //collect all the PT Ids
			Set<CLQ_Program_Transaction__c> ptToUpdate = new Set<CLQ_Program_Transaction__c>(); //collect all pt to update
			
			if(operationType==UPDATESTR || operationType==INSERTSTR) { //check if owner was changed, old map only exists for update
                System.debug('');
				for(CLQ_Room_Space_Transaction__c rst : newList) { //we dont have old map for these types
					if (rst.CLQ_Program_Transaction__c != null) { //this wont exist on rst on program
                        	//System.debug('');
							if(oldMap.size()!=0 && rst.OwnerId == oldMap.get(rst.Id).OwnerId) { //for new there is no old map so check
								programTransIdSet.add(rst.CLQ_Program_Transaction__c); //collect all the PT
							}
					}
				}
			}
			
			if(operationType==DELETESTR) { //check if owner was changed, old map only exists for update
				for(CLQ_Room_Space_Transaction__c rst : oldMap.values()) { //we have old map for delete
					if (rst.CLQ_Program_Transaction__c != null) { //this wont exist on rst on program
						programTransIdSet.add(rst.CLQ_Program_Transaction__c); //collect all the PT
					}
				}
			}
			
			if(programTransIdSet.size() > 0) {
				//master query to get all required details
				List<CLQ_Program_Transaction__c> relatedProgramTrans = [SELECT Id, Name, CLQ_Program__c, CLQ_Transaction_Updated__c, clq_recordtypename__c, (SELECT Id FROM Room_Space_Transactions__r LIMIT 1999) 
																	FROM CLQ_Program_Transaction__c 
																	WHERE Id IN:programTransIdSet
																	AND clq_recordtypename__c='Update Outdoor Space Information'];
																	
				if (relatedProgramTrans != null) {
					//get the count of rst from program
					
					//System.debug('relatedProgramTrans-->' + relatedProgramTrans);
					
					Map<Id, Id> programTransToProgramMap = new Map<Id, Id>(); //map to hold pt->p relationships so we delete correct items
					
					try {
						for(CLQ_Program_Transaction__c pt : relatedProgramTrans) { //if updated, change the flag
							if(operationType==UPDATESTR){
								//System.debug('operationType is update-->');
								pt.CLQ_Transaction_Updated__c = true;
								ptToUpdate.add(pt);
							}
							
							programTransToProgramMap.put(pt.Id, pt.CLQ_Program__c);
						}
						
						 			
					
						if(operationType==INSERTSTR || operationType==DELETESTR) {
							//System.debug('rst operationType is-->' + operationType);
		
							List<CLQ_Program__c> programsList = new List<CLQ_Program__c>(); //list of all programs
					
							if(programTransToProgramMap.size() > 0) {
								programsList = [SELECT Id, (SELECT Id FROM Rooms_Spaces__r LIMIT 1999) FROM CLQ_Program__c WHERE Id IN: programTransToProgramMap.values()];
							}
							
							
							//go through the programs and pt and check if new rst has been added or if rst has been deleted in pt
							for(CLQ_Program__c prog : programsList) {
								for(CLQ_Program_Transaction__c pt : relatedProgramTrans) {
									if(programTransToProgramMap.size() !=0 && programTransToProgramMap.get(pt.Id) == prog.Id) {
										System.debug('rst pt.Room_Space_Transactions__r.size()-->' + pt.Room_Space_Transactions__r.size());
										//System.debug('rst prog.Rooms_Spaces__r.size()-->' + prog.Rooms_Spaces__r.size());
										if(pt.Room_Space_Transactions__r.size() != prog.Rooms_Spaces__r.size()) { //if not equal then changes were made
											system.debug('rst Adding pt to list to update--->');
											pt.CLQ_Transaction_Updated__c = true;
											ptToUpdate.add(pt);
										}
									}
								}
							}
		
						}
					
					} catch (Exception e) {
						//System.debug('Error-->' + e);
						Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_RoomSpaceTransactionTriggerHandler');  
					}
					
					//update all the collected pt	
					if(ptToUpdate != null) {
						List<CLQ_Program_Transaction__c> ptToUpdateList = new List<CLQ_Program_Transaction__c>(ptToUpdate);
                        if(!ptToUpdateList.isEmpty()){
        					update ptToUpdateList;
         				}
					}
				}
				
			}
		}
	}    
    
}