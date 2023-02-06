/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_FacilityScheduleTriggerHandler 
** 
** Version          : 1.3
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version			Description
**	Soufin Rahimeen			07/26/2018		1.1				TFS#12150 : Added logic to update Transaction Updated flag on PT
**	Pradeep Ravi			08/15/2018		1.2				TFS#11670 : Added logic to update Program with the latest and earliest facility schedules for the days operating 
**	Pradeep Ravi			08/18/2018		1.3				TFS#11670 : Added two seperate methods for FS time comparator 
**	Pradeep Ravi			10/03/2018		1.4				TFS#14727 : Added invocable method
**	Pradeep Ravi			04/24/2019		1.5				TFS#14787 : Added logic to update funding sources
**************************************************************************************************************/
public with sharing class CLQ_FacilityScheduleTriggerHandler extends CLQ_Trigger {
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger {
        get {
        	System.Debug('BypassTrigger --> '+BypassTrigger);
            if (BypassTrigger == null) {BypassTrigger = false;}
            return BypassTrigger;
        }
        set;
    }
    public static boolean HasUpdated;
    public override boolean getUpdateFlag()                 {   return HasUpdated;    }
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;    }
    public static final String empty = '';
    public static final String value_n = 'N';
    public static final String value_y = 'Y';
    public static final String monday = 'Monday';
    public static final String tuesday = 'Tuesday';
    public static final String wednesday = 'Wednesday';
    public static final String thursday = 'Thursday';
    public static final String friday = 'Friday';
    public static final String saturday = 'Saturday';
    public static final String sunday = 'Sunday';
    public static final String early_Childhood_Education = 'Early Childhood Education Grant';
    public static final String head_Start = 'Head Start';
    public static final String tuition = 'Tuition';
    public static final String preschool_special = 'Preschool Special Education';
    public static final String century_grant = '21st Century Grant';
    public static final String ELIstring = 'ELI';
    public static final String school_Age_ChildCare= 'School Age Child Care';
    public static final String none = 'None';
    public static final String BDD = 'Board of Developmental Disabilities'; 
    public static final String Locally_Funded = 'Locally Funded';
    public static final String exceptionMsg = 'Salesforce Exception -- CLQ_FacilityScheduleTriggerHandler.updateProgTime - ';
    public static final String logErrorMsg = 'Salesforce Exception -- CLQ_FacilityScheduleTriggerHandler';
    public static final String SFDC = 'SFDC-001.2';
    public static final String cause = 'Cause:';
    public static final String line = 'Line:'; 
    public static final String active = 'Active';
    public static final String insertString = 'insert';
    public static final String updateString = 'update';
    public static final String deleteString = 'delete';
    public static final String beginString = 'Begin';
    public static final String endString = 'End';
    public static final String CLQ_Pre_School = 'CLQ_Pre_School';
    public static final String CLQ_School_Age_Child_Care = 'CLQ_School_Age_Child_Care';
    public static final String twelve = '12';
    public static final String AM = 'AM';
    public static final String PM = 'PM';
    public static final String twelveAM = '12:00 AM';
    public static final String Update_Facility_Information ='Update Facility Information';

    //Calls the Base class Constructor
    public CLQ_FacilityScheduleTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <
        sObject > oldlistin, map < id, sObject > oldMapin,
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
        ////////////////////////////////     Boilerplate implementation  ////////////////////////////

    //Method to hold the logic for before insert on CLQ_Program__c object
    //@return : none
    
    //after insert
	public override void afterinsert(){
		updateProgramTransaction((list < CLQ_Facility_Schedule__c > ) newlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, insertString); //12150
		updateProgram((list < CLQ_Facility_Schedule__c > ) newlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, insertString); //11670
    }

    //after update
    public override void afterupdate(){
		updateProgramTransaction((list < CLQ_Facility_Schedule__c > ) newlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, updateString); //12150
        updateProgram((list < CLQ_Facility_Schedule__c > ) newlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, updateString); //11670
    }
    
    
    public override void afterdelete(){
        updateProgramTransaction((list < CLQ_Facility_Schedule__c > ) oldlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, deleteString); //12150
        updateProgram((list < CLQ_Facility_Schedule__c > ) oldlist,(map < id, CLQ_Facility_Schedule__c > ) oldMap, deleteString); //11670
    }
    
    //11670 - Update Program with the latest and earliest facility schedules for the days operating 
    public static void updateProgram(List<CLQ_Facility_Schedule__c> newList,Map<Id, CLQ_Facility_Schedule__c> oldMap, String operationType)
    {
        Set<Id> programIdSet = new Set<Id>(); //collect all pt to update
        if(operationType == insertString || operationType == updateString)
        {
			for(CLQ_Facility_Schedule__c fs : newList) {
                if(fs.CLQ_Program__c!=null){
					programIdSet.add(fs.CLQ_Program__c);
                }
			}
        }
        else
        {
			for(CLQ_Facility_Schedule__c fs : oldMap.values()) {
                if(fs.CLQ_Program__c!=null){
					programIdSet.add(fs.CLQ_Program__c);
                }
			}
        }
        If(!programIdSet.isEmpty() && programIdSet.size() > 0){
            if(system.isBatch()){
            	updateProgTime(programIdSet);
            }
            else{
                updateProgramFSTimings(programIdSet);
            }
            	
        }
    }
    
    //11670 - Update Program with the latest and earliest facility schedules for the days operating - Batch Execution
    @future
    public static void updateProgramFSTimings(Set<Id> prgIdSet)
    {
		updateProgTime(prgIdSet);
    }
    
    @InvocableMethod //14727 - added to invoke from PT PB
	public static void updtProgTime(List<Id> prgIdSet) 
	{
		Set<Id> progIDset = new Set<Id>();
		progIDset.addall(prgIdSet);
		updateProgramFSTimings(progIDset);
	}
    
    //11670 - Update Program with the latest and earliest facility schedules for the days operating - Trigger Execution
    public static void updateProgTime(Set<Id> prgIdSet)
    {
    	try{
	        Map<Id,List<CLQ_Facility_Schedule__c>> progFSMAP = new Map<Id,List<CLQ_Facility_Schedule__c>>();
	        Map<Id,CLQ_Program__c> progMAP = new Map<Id,CLQ_Program__c>();
  			List<CLQ_Program__c> progListToUpdate = new List<CLQ_Program__c>();
            if(prgIdSet!=null){
	        for(CLQ_Program__c prog:[Select Id, RecordTypeId, (Select ID, Name, CLQ_Days_of_Operation__c, Months_of_Operation__c, 
												CLQ_Other_Funding_Source__c, CLQ_HOO_Time_1_Start__c, CLQ_HOO_Time_2_Start__c, 
												CLQ_HOO_Time_1_End__c, CLQ_HOO_Time_2_End__c, CLQ_Program__c, CLQ_Funding_Source_Picklist__c 
												From Facility_Schedules__r where CLQ_Status__c = :active) From CLQ_Program__c where Id in :prgIdSet]){
				List<CLQ_Facility_Schedule__c> fsLst = new 	List<CLQ_Facility_Schedule__c>();
                progMAP.put(prog.Id, prog);
				fsLst = prog.Facility_Schedules__r;										
				if(!fsLst.isEmpty())	 
				{
	                progFSMAP.put(prog.Id, fsLst);
				}
	            else {
	            	CLQ_Program__c progObj = new CLQ_Program__c();
	            	progObj.Id = prog.id;
					progObj.CLQ_FS_Sat_Begin_time__c = empty;
					progObj.CLQ_FS_Sat_End_time__c = empty;
					progObj.CLQ_FS_Sun_Begin_time__c = empty;
					progObj.CLQ_FS_Sun_End_time__c = empty;
					progObj.CLQ_FS_Mon_Begin_time__c = empty;
					progObj.CLQ_FS_Mon_End_time__c = empty;
					progObj.CLQ_FS_Tue_Begin_time__c = empty;
					progObj.CLQ_FS_Tue_End_time__c = empty;
					progObj.CLQ_FS_Wed_Begin_time__c = empty;
					progObj.CLQ_FS_Wed_End_time__c = empty;
					progObj.CLQ_FS_Thur_Begin_time__c = empty;
					progObj.CLQ_FS_Thur_End_time__c = empty;
					progObj.CLQ_FS_Fri_Begin_time__c = empty;
					progObj.CLQ_FS_Fri_End_time__c = empty;
					//14787
					progObj.CLQ_FS_ECEG_FS__c = value_n;
					progObj.CLQ_FS_ELI_FS__c = value_n;
					progObj.CLQ_FS_Head_Start_FS__c = value_n;
					progObj.CLQ_FS_None_FS__c = value_n;
					progObj.CLQ_FS_PSE_FS__c = value_n;
					progObj.CLQ_FS_SACC_FS__c = value_n;
					progObj.CLQ_FS_Tution_Locally_Funded_FS__c = value_n;
					progObj.CLQ_FS_Twenty_First_Century_Grant_FS__c = value_n;
					progObj.CLQ_FS_BODD_FS__c = value_n;
					progListToUpdate.add(progObj);
	            }
	        }
            }
	        
	        if(!progFSMAP.isEmpty() && progFSMAP.size() > 0)
	        {
                Id psRecID = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(CLQ_Pre_School).getRecordTypeId();
                Id saacRecID = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(CLQ_School_Age_Child_Care).getRecordTypeId();
	        	for(Id progID: progFSMAP.keyset())
	        	{
			        String mondayBeginTime = empty; 
			        String mondayEndTime = empty;
			        String tueBeginTime = empty;
			        String tueEndTime = empty;
			        String wedBeginTime = empty;
			        String wedEndTime = empty;
			        String thurBeginTime = empty;
			        String thurEndTime = empty;
			        String friBeginTime = empty;
			        String friEndTime = empty;
			        String satBeginTime = empty;
			        String satEndTime = empty;
			        String sunBeginTime = empty;
			        String sunEndTime = empty;
			        //14787
			        String ECEG = value_n; 
			        String headStart = value_n;
			        String tutionFunded = value_n;
			        String pse = value_n;
			        String twentyGrant = value_n;
			        String ELI = value_n;
			        String SACC = value_n;
			        String noneFS = value_n;
			        String boddFS = value_n;
			        for(CLQ_Facility_Schedule__c fsObj:progFSMAP.get(progID))
			        {
			            List<String> daysOfOp = new List<String>();
                        if(fsObj.CLQ_Days_of_Operation__c != null){
			            	daysOfOp = fsObj.CLQ_Days_of_Operation__c.split(';');
                        }
			            if(!daysOfOp.isEmpty() && daysOfOp.size() > 0)
			            {
			                for(String day:daysOfOp)
			                {
			                    if(day == monday){
			                    	mondayBeginTime = timeCompre(mondayBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	mondayEndTime = timeCompre(mondayEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);
			                    }
			                    if(day == tuesday){
			                    	tueBeginTime = timeCompre(tueBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	tueEndTime = timeCompre(tueEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);
			                    }
			                    if(day == wednesday){
			                    	wedBeginTime = timeCompre(wedBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	wedEndTime = timeCompre(wedEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);
			                    }
			                    if(day == thursday){
			                    	thurBeginTime = timeCompre(thurBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	thurEndTime = timeCompre(thurEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);			                    			                    	
			                    }
			                    if(day == friday){
			                    	friBeginTime = timeCompre(friBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	friEndTime = timeCompre(friEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);			                    			                    	
			                    }
			                    if(day == saturday){
			                    	satBeginTime = timeCompre(satBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	satEndTime = timeCompre(satEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);		                    			                    	
			                    }
			                    if(day == sunday){
			                    	sunBeginTime = timeCompre(sunBeginTime,fsObj.CLQ_HOO_Time_1_Start__c, fsObj.CLQ_HOO_Time_2_Start__c, beginString);
			                    	sunEndTime = timeCompre(sunEndTime,fsObj.CLQ_HOO_Time_1_End__c, fsObj.CLQ_HOO_Time_2_End__c, endString);
			                    }
			                }
			            }
			            //14787
			            if(progMAP.get(progID).RecordTypeId == psRecID || progMAP.get(progID).RecordTypeId == saacRecID)
			            {
                            if(fsObj.CLQ_Funding_Source_Picklist__c == early_Childhood_Education && ECEG == value_n) {ECEG = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == head_Start && headStart == value_n) {headStart = value_y;}
                            if((fsObj.CLQ_Funding_Source_Picklist__c == tuition || fsObj.CLQ_Funding_Source_Picklist__c == Locally_Funded) && tutionFunded == value_n) {tutionFunded = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == preschool_special && pse == value_n) {pse = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == century_grant && twentyGrant == value_n) {twentyGrant = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == ELIstring && ELI == value_n) {ELI = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == school_Age_ChildCare && SACC == value_n) {SACC = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == None && noneFS == value_n) {noneFS = value_y;}
                            if(fsObj.CLQ_Funding_Source_Picklist__c == BDD && boddFS == value_n) {boddFS = value_y;}
			            		
			            }
			        }
			        
			        CLQ_Program__c progObj = new CLQ_Program__c();
			        progObj.Id = progID;
					progObj.CLQ_FS_Sat_Begin_time__c = satBeginTime;
					progObj.CLQ_FS_Sat_End_time__c = sunEndTime;
					progObj.CLQ_FS_Sun_Begin_time__c = sunBeginTime;
					progObj.CLQ_FS_Sun_End_time__c = sunEndTime;
					progObj.CLQ_FS_Mon_Begin_time__c = mondayBeginTime;
					progObj.CLQ_FS_Mon_End_time__c =  mondayEndTime;
					progObj.CLQ_FS_Tue_Begin_time__c = tueBeginTime;
					progObj.CLQ_FS_Tue_End_time__c = tueEndTime;
					progObj.CLQ_FS_Wed_Begin_time__c = wedBeginTime;
					progObj.CLQ_FS_Wed_End_time__c = wedEndTime;
					progObj.CLQ_FS_Thur_Begin_time__c = thurBeginTime;
					progObj.CLQ_FS_Thur_End_time__c = thurEndTime;
					progObj.CLQ_FS_Fri_Begin_time__c = friBeginTime;
					progObj.CLQ_FS_Fri_End_time__c = friEndTime;
					//14787
					progObj.CLQ_FS_ECEG_FS__c = ECEG;
					progObj.CLQ_FS_ELI_FS__c = ELI;
					progObj.CLQ_FS_Head_Start_FS__c = headStart;
					progObj.CLQ_FS_None_FS__c = noneFS;
					progObj.CLQ_FS_PSE_FS__c = pse;
					progObj.CLQ_FS_SACC_FS__c = SACC;
					progObj.CLQ_FS_Tution_Locally_Funded_FS__c = tutionFunded;
					progObj.CLQ_FS_Twenty_First_Century_Grant_FS__c = twentyGrant;
					progObj.CLQ_FS_BODD_FS__c = boddFS;
					progListToUpdate.add(progObj);
	        	}
	        }
        	if(!progListToUpdate.isEmpty())
        	{
        		CLQ_Trigger.BypassAllTriggers = true;
        		update progListToUpdate;
        		CLQ_Trigger.BypassAllTriggers = false;
        	}
    	}
        catch(exception e)
        {
        	Integration_Transaction_Logs.LogErrorRealTime(SFDC, exceptionMsg + e.getMessage()  , cause + e.getCause(), line +e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    //11670 - Time Comparator for pulling out the earliest start or Latest end time based on the beginOrEnd parameter
    public static string timeCompre(String dayTime, String time1, String time2, String beginOrEnd)
    {
    	String timeAMPM1 = '';
    	String timeAMPM2 = '';
    	String dayTimeAMPM = '';
        if(time1 != null){
            timeAMPM1 = time1.right(2);}
        if(dayTime != null){
            dayTimeAMPM = dayTime.right(2);}    	
        if(time2 != null){
            timeAMPM2 = time2.right(2);}
    										
		if(dayTime == ''){																		// Start - If there is only one FS
            if(time2 != null){
				dayTime = timeAMPMCompare(time1, time2, beginOrEnd);
			}
	    	else{
	    		dayTime =  time1; 
	    	}
		}																						// End - If there is only one FS		
    	else{  																					// Start - If there is already existing FS	
    		String updatedDayTime = ''; 
			updatedDayTime = timeAMPMCompare(time1, time2, beginOrEnd); 						// Compare Time1 and Time2 within one FS
			dayTime = timeAMPMCompare(dayTime, updatedDayTime, beginOrEnd); 					// Compare the output from the previous step with the other FS
	}	 																						// End - If there is already existing FS
    	return dayTime;
    }
    
    //11670 - Time Comparator for pulling out the earliest start or Latest end time based on the beginOrEnd parameter and if it is AM or PM
    public static string timeAMPMCompare(String time1, String time2, String beginOrEnd)
    {
    	String returnTime = empty;    	
    	String timeAMPM1 = empty;
    	String timeAMPM2 = empty;
        if(time1 != null){
            timeAMPM1 = time1.right(2);}  	
        if(time2 != null){
    		timeAMPM2 = time2.right(2);
        }
		if(timeAMPM1 == timeAMPM2){	
			if(time1.left(2) == twelve && time2.left(2) == twelve){
                if(beginOrEnd == beginString){
                    returnTime =  time1 < time2? time1:time2;}
                else{
                    returnTime =  time1 > time2? time1:time2;
                }
					
			}
			else if(beginOrEnd == beginString && ((time1.left(2) == twelve && time2.left(2) != twelve)))
            {returnTime =  time1;}
			else if(beginOrEnd == beginString && ((time1.left(2) != twelve && time2.left(2) == twelve)))
            {returnTime =  time2;} 
			else if(beginOrEnd == endString && ((time1.left(2) == twelve && time2.left(2) != twelve)))
            {returnTime =  time2;}
			else if(beginOrEnd == endString && ((time1.left(2) != twelve && time2.left(2) == twelve)))
            {returnTime =  time1;}				
	        else if(beginOrEnd == beginString)
            {returnTime =  time1 < time2? time1:time2;}
	        else if(beginOrEnd == endString)
            {returnTime =  time1 > time2? time1:time2;}				
		}
		else if(timeAMPM1 == AM && (beginOrEnd == beginString || (beginOrEnd == endString && time1 == twelveAM)))
        {returnTime =  time1;}
		else if(timeAMPM2 == AM && (beginOrEnd == beginString || (beginOrEnd == endString && time2 == twelveAM)))
        {returnTime =  time2;}
		else if(timeAMPM2 == PM && (beginOrEnd == endString))
        {returnTime =  time2;}	
		else if(timeAMPM1 == PM && (beginOrEnd == endString))
        {returnTime =  time1;}						 
		return returnTime;			
    }
    
	//12150 Starts
	/*Method to update CLQ_Transaction_Updated__c on Program Transaction for different Facility Schedule Operations*/
	public void updateProgramTransaction(List<CLQ_Facility_Schedule__c> newList,Map<Id, CLQ_Facility_Schedule__c> oldMap, String operationType) {
		Id userId = userinfo.getProfileId();
		
		if(Label.CommunityProfileIds.contains(userId)){
			
			Set<Id> programTransIdSet = new Set<Id>(); //collect all the PT Ids
			Set<CLQ_Program_Transaction__c> ptToUpdate = new Set<CLQ_Program_Transaction__c>(); //collect all pt to update
			
			if(operationType== updateString || operationType== insertString) { //check if owner was changed, old map only exists for update
				for(CLQ_Facility_Schedule__c fs : newList) {
    				if(fs.CLQ_Program_Transaction__c != null && (oldMap.size()!=0 && fs.OwnerId == oldMap.get(fs.Id).OwnerId)) { //for new there is no old map so check
							programTransIdSet.add(fs.CLQ_Program_Transaction__c); //collect all the PT
						}
                }
			}
			
			if(operationType== deleteString) { //check if owner was changed, old map only exists for update
				for(CLQ_Facility_Schedule__c fs : oldMap.values()) { //we have old map for delete
					if (fs.CLQ_Program_Transaction__c != null) { //this wont exist on rst on program
						programTransIdSet.add(fs.CLQ_Program_Transaction__c); //collect all the PT
					}
				}
			}
			
			//master query to get all required details
			List<CLQ_Program_Transaction__c> relatedProgramTrans;
            if(programTransIdSet!=null){
			relatedProgramTrans = [SELECT Id, Name, CLQ_Program__c, CLQ_Transaction_Updated__c, clq_recordtypename__c, (SELECT Id FROM Facility_Schedules__r LIMIT 1999) 
																FROM CLQ_Program_Transaction__c 
																WHERE Id IN:programTransIdSet
																AND clq_recordtypename__c= :Update_Facility_Information];
            }
			
            //System.debug('');
			if (relatedProgramTrans != null) {
				//get the count of FS from program
				Map<Id, Id> programTransToProgramMap = new Map<Id, Id>(); //map to hold pt->p relationships so we delete correct items
				
				try {
					for(CLQ_Program_Transaction__c pt : relatedProgramTrans) { //if updated, change the flag
						if(operationType== updateString){
							pt.CLQ_Transaction_Updated__c = true;
							ptToUpdate.add(pt);
						}
						programTransToProgramMap.put(pt.Id, pt.CLQ_Program__c);
					}
				    //System.debug('');
					if(operationType== insertString || operationType== deleteString) {

						List<CLQ_Program__c> programsList = new List<CLQ_Program__c>(); //list of all programs
				
						if(programTransToProgramMap.size() > 0) {
							programsList = [SELECT Id, (SELECT Id FROM Facility_Schedules__r LIMIT 1999) FROM CLQ_Program__c WHERE Id IN: programTransToProgramMap.values()];
						}
						
						
						//go through the programs and pt and check if new FS has been added or if FS has been deleted in pt
						for(CLQ_Program__c prog : programsList) {
							for(CLQ_Program_Transaction__c pt : relatedProgramTrans) {
								if((programTransToProgramMap.size()!=0 && programTransToProgramMap.get(pt.Id) == prog.Id) && (pt.Facility_Schedules__r.size() != prog.Facility_Schedules__r.size())) { //if not equal then changes were made
										pt.CLQ_Transaction_Updated__c = true;
										ptToUpdate.add(pt);
									}
							}
						}

					}
				
				} catch (Exception e) {
					Integration_Transaction_Logs.LogError(SFDC, e.getMessage() ,empty ,String.valueOf(e.getLineNumber()),empty,logErrorMsg);  
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
	//12150 Ends    
}