/**************************************************************************************************************
** Name             : CLQ_UtilityClass
** Description      : This class contains all untility logic/methods for OCLQS project.
** Assumptions      : 
** Version          : 2.8
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer					Date				Version		Description 
**------------------------------------------------------------------------------------------------------------
**	IncapsulateDevTeam			Oct-2016			1.0			Created
**	Ramana Gurivelli			10-May-2017			1.1			Updated for Error Framework & bug# 11125.
**	Ramana Gurivelli            13-July-2017		1.2			CR# 11192: Added code in createTaskrecord method.
**	Neetu Ojha					30-Aug-2017			1.3			TFS#11708,#11652: commented code to copy mailing address and wiping out SUTQ Ratings
**	Neetu Ojha					11-Oct-2017			1.4			TFS#11774: Copying IHA Program Transaction to Program
**  Pradeep Ravi				31-Oct-2017			1.5			TFS#11694 - Not cloning the owner for Room space
**  Neetu Ojha					07-Nov-2017			1.6			TFS#11851 - Room Space Clone Issue 
**  Soufin Rahimeen				29-Nov-2017			1.7			TFS#11885 - Copying Location Id and Location Type from Transaction to Program
**  Soufin Rahimeen				29-Nov-2017			1.8			TFS#11894 - Copying Location Id and Location Type for ODE Change of Location
**	Neetu Ojha					28-Feb-2018			1.9			TFS#12048 : Copy Owner only when it is active
**	Neetu Ojha					29-Mar-2018			2.0			TFS#12069 : Added new method to get combined counties for program county
**	Neetu Ojha					21-Apr-2018			2.1			TFS#12138 : Copying capacity for CoC	
**  Pradeep Ravi				24-Apr-2018			2.2			CR# 12166 - Copy Application Day Camp updates to Program	
**  Rohit Gowrishetty			14-May-2018			2.3			TFS#12212 : Undo the copying of licensing reviewer from PT to program for COS,COL,CL	
**	Neetu Ojha					18-May-2018			2.4			TFS#12185 : Added Owner Logic
**  Pradeep Ravi				05-May-2018			2.5			CR#12420  : Copy Registration Closure updates to Program
**  Rohit Gowrishetty			13-Aug-2018			2.6			CR#13554  : Updated to copy the related list from PT to Program for DC Renew app
**	Soufin Rahimeen				08/15/2018			2.7			TFS#13790 : Copy over ACA fields from PT (for Day Camp Application) to Program.
**	Rahul Roy    				11/20/2018			2.8			TFS#14804 : Created a method to populate program number and program name for the Tasks
**  Pradeep Ravi				01/22/2018			2.9			TFS#15275 : Commented out the Enrollment copy over to Program for FCC and CCC
**  Pradeep Ravi				10/14/2019			3.0			TFS#15751 : Updating cloning of building approval records
**************************************************************************************************************/ 

public with sharing class CLQ_UtilityClass {
    //Method to create inspection record
    //@param : String Inspectiontype String inspcetionscope, String inspectionStatus
    //@return : CLQ_Inspection__c 
    public static CLQ_Inspection__c createInspectionrecord(String incpsectionType,String inspcetionscope, String inspectionStatus){
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.CLQ_Inspection_Type__c = incpsectionType;
        inspectionrecord.CLQ_Scope__c = inspcetionscope;
        //inspectionrecord.CLQ_Program__c = programID;
        //inspectionrecord.CLQ_Inspection_Owner__c = ;
        inspectionrecord.CLQ_Inspection_Status__c = inspectionStatus;
        return inspectionrecord;
    }

    //Method to redirect the system to new page
    //@param: pagename , ret url (either one should be available)
    //@return: pagereference
    public static pageReference redirecttoPage(String urlvalue){
        pageReference pageRef = new pageReference(urlvalue);
        pageRef.setRedirect(true);  
        return pageRef;
    }

    //Method to create a task record
    //@param : taskownerid , whatid, Subject, Desctiption
    //@return : Task
    public static Task createTaskrecord(ID taskAssignTo, ID whatidfortask, Date taskDate, String subject, String description){
        Task taskrecord = new Task();
        taskrecord.Description = description;
        taskrecord.Subject = subject;
        taskrecord.ActivityDate = taskDate;
        taskrecord.WhatId = whatidfortask;
        taskrecord.Ownerid= taskAssignTo;
        //[Ramana, 7/15/17]: Code start for Task Matrix, CR# 11192 
        String sObjName = whatidfortask.getSObjectType().getDescribe().getName();
        taskrecord.CLQ_WhatType__c = sObjName;
        system.debug('Related Id: ' +whatidfortask);
        system.debug('Related Object Name: ' +sObjName);
        
        if(sObjName == 'CLQ_Program_Transaction__c')
            taskrecord.Program_Transaction__c = whatidfortask;
        else if(sObjName == 'CLQ_Inspection__c')
            taskrecord.Inspection__c = whatidfortask;
        //else if(sObjName == 'Case')
            //taskrecord.Case__c = whatidfortask;
        else if(sObjName == 'CLQ_Case_Custom__c')
            taskrecord.Cases__c = whatidfortask;
        else if(sObjName == 'CLQ_Program__c')
            taskrecord.CLQ_Program__c = whatidfortask;
        //End code CR# 11192
        return taskrecord;
    }
    
    //14804 
    //Method to create a task record
    //@param : program transaction, Subject, Desctiption
    //@return : Task
    public static Task createTaskrecord(CLQ_Program_Transaction__c ptRecord, Date taskDate, String subject, String description){
        Task taskrecord = new Task();
        taskrecord.Description = description;
        taskrecord.Subject = subject;
        taskrecord.ActivityDate = taskDate;
        taskrecord.WhatId = ptRecord.Id;
        taskrecord.Ownerid= ptRecord.CLQ_Transaction_Assigned_To__c;
        taskrecord.CLQ_Program__c = ptRecord.CLQ_Program__c;
        taskrecord.Program_Transaction__c = ptRecord.Id;
        //taskrecord.Program_Number__c = ptRecord.CLQ_Program_Number__c;
        String sObjName = ptRecord.Id.getSObjectType().getDescribe().getName();
        taskrecord.CLQ_WhatType__c = sObjName;

        return taskrecord;
    }

    //Method to get Room/Space information associated with any program
    //@param: programID
    //@return: list of Room Space information object
    public static list<CLQ_Room_Space__c> queryRoomSpacefromProgram(ID programID){
        list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
        roomSpaceList = Database.query(createSOQLQuery('CLQ_Room_Space__c','CLQ_Program__c='+'\''+programID+'\'',null));
        return roomSpaceList;     
    }

    //Create Room/Space Inspection object
    //@param : roomspace list , inspection record
    //@return : list of roomspace inspection
    public static list<CLQ_Room_Space_Inspection__c> createRoomSpaceInspection(list<CLQ_Room_Space__c> roomSpaceList ,CLQ_Inspection__c inspectionrecord ){
        list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = new list<CLQ_Room_Space_Inspection__c>();
        map<ID,Schema.RecordTypeInfo> rt_Map = CLQ_Room_Space__c.sObjectType.getDescribe().getRecordTypeInfosById();
        for(CLQ_Room_Space__c roompsacerecord : roomSpaceList){
                CLQ_Room_Space_Inspection__c newrecord = (CLQ_Room_Space_Inspection__c)cloneFromOneObjectToanother(roompsacerecord,'CLQ_Room_Space_Inspection__c');
                newrecord.CLQ_Inspection__c = inspectionrecord.id;
                newrecord.CLQ_Room_Group_Information__c = roompsacerecord.id;
                newrecord.CLQ_Program__c = null;
                newrecord.CLQ_Program_Transaction__c = null;
                Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByName().get(rt_map.get(roompsacerecord.recordTypeID).getName()).getRecordTypeId();
                newrecord.recordTypeID = devRecordTypeId;
                roomSpaceInspectionList.add(newrecord);
        }
        return roomSpaceInspectionList;
    }

    //Method to copy all fields of Room Space informaiton object to Room/Space inspection
    //@param: Sobject source record , String api name of object to which you want to copy
    //@return: Sobject
    public static sObject cloneFromOneObjectToanother(SObject fromRecord,String toObjectName){
        //Get fromSobject 
        Schema.SObjectType fromsobjectType = fromRecord.getSObjectType();
        String fromObjectName = fromsobjectType.getDescribe().getName();
        System.Debug('toObjectName__>'+toObjectName);

        SObjectType fromobjToken = Schema.getGlobalDescribe().get(fromObjectName);
        SObjectType toobjToken = Schema.getGlobalDescribe().get(toObjectName);

        //Create a cloned record
        sObject clonedRecord = Schema.getGlobalDescribe().get(toObjectName).newSObject() ;

        //Get list of fields from FromSobject
        Map<String,Schema.SObjectField> mapFromSObjFieldList = fromobjToken.getDescribe().fields.getMap();
        //Get list of fields from ToSobject
        Map<String,Schema.SObjectField> mapToSObjFieldList = toobjToken.getDescribe().fields.getMap();
        for(String field : mapFromSObjFieldList.keySet()){
            
			if(mapToSObjFieldList.get(field) != null && mapToSObjFieldList.get(field).getDescribe().isUpdateable() && !mapToSObjFieldList.get(field).getDescribe().isExternalID()) {
            	//11694, 11851 Starts - Not copying over the owner to allow deletion, 12048- Exclude copying inactive user
            	if(toObjectName == 'CLQ_Room_Space_Transaction__c' && field != 'ownerid'){
            		clonedRecord.put(field , fromRecord.get(field)) ;	
            	}
            	if(toObjectName != 'CLQ_Room_Space_Transaction__c'){
            		if((field == 'ownerid' && fromRecord.getSobject('Owner')!= null && ((String)fromRecord.get(field)).substring(0,3) == '005' && 
            			(Boolean) fromRecord.getSobject('Owner').get('IsActive')) || field != 'ownerid'){ //12185
            			clonedRecord.put(field , fromRecord.get(field)) ;	
            		}
            	}
			}
			//11694, 11851, 12048 Ends
        }
        return clonedRecord;
    }

    //Method to get query all the fields for any sObject
    //@param: objectapiname
    //@return: set of field api name
    public static set<String> getAllfieldsforSObject(String objectAPIName){
        SObjectType objToken = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String,Schema.SObjectField> mapSObjFieldList = objToken.getDescribe().fields.getMap();
        return mapSObjFieldList.keySet();     
    }

    //Method to create query string with all fields of the object
    //@param: ObjectAPIName, WhereClausestring, string list of extrafields
    //@return: soql string
    public static string createSOQLQuery(String sObjectAPIName,String whereClause,list<String> extraFieldsList){
        list<String> fieldNames =  new List<String>(getAllfieldsforSObject(sObjectAPIName));
        String soqlquery = 'SELECT '+ String.join( fieldNames, ',' );
        //Add extra fields if needed
        if(extraFieldsList != null && extraFieldsList.size()>0 ){
            soqlquery = soqlquery+',';
            soqlquery = soqlquery+ String.join( extraFieldsList, ',' );
        }
        //Complete the query
         //12048 Starts
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjectAPIName);
		Map<String,Schema.SObjectField> mapSObjFieldMap = objToken.getDescribe().fields.getMap();
		if(mapSObjFieldMap.containsKey('ownerid')){
			soqlquery = soqlquery+' ,Owner.isActive FROM '+sObjectAPIName+' WHERE '+whereClause;
		}else{
			soqlquery = soqlquery+' FROM '+sObjectAPIName+' WHERE '+whereClause;
		}
		//12048 Ends
        system.debug('====>'+soqlquery);
        return soqlquery;
    }
    
    //Method to get aligible Inspection Tool for given Inspection
    //@param: CLQ_Inspection__c
    //@return: CLQ_Inspection_Tools__c
    public static CLQ_Inspection_Tools__c retriveInspectionToolForInspection(CLQ_Inspection__c inspectionRecord,String programType,String scope,String inspectionType){
        return [SELECT ID
                      ,CLQ_Applicable_To__c
                      ,CLQ_Description__c
                      ,CLQ_Active__c
                      ,Name
                      ,CLQ_Applicable_To_Scope__c
                      ,CLQ_Application_To_Inspection_Type__c
                FROM CLQ_Inspection_Tools__c
                WHERE CLQ_Applicable_To_Scope__c =:scope
                AND CLQ_Application_To_Inspection_Type__c =:inspectionType
                AND CLQ_Applicable_To__c includes (:programType) 
                LIMIT 1];
    }
    
    //method to get all the domain Rules for given Inspection Tool
    //@param: ID inspectionToolRecordID, Date ruleeffectiveDate
    //@return:list<CLQ_Tools_Rules__c> list of Tool Rules
    public static list<CLQ_Tools_Rules__c> getToolRulesfromInspectionTool(ID inspectionToolRecordID, Date validityDate){
        return Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Tools_Rules__c', ' CLQ_Inspection_Tools__c ='+'\''+inspectionToolRecordID+'\' AND CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c<='+String.valueOf(validityDate)+' AND ((CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c>='+String.valueOf(validityDate)+'  AND CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c!= null) OR (CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c = null))', null));
    }
    
    //Method to get all the rule inspected for given Inspections
    //@param: set<id> Inspectionidset
    //@return: list<CLQ_Rules_Inspected__c> ruleinspectedlist
    public static list<CLQ_Rules_Inspected__c> queryallruleInspectedforInspections(set<id> Inspectionidset){
        return Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Rules_Inspected__c',' CLQ_Inspection_Tools__c in'+'\''+Inspectionidset,null));
    }
    
    //Method to copy all Building Approvals from Program to inspection
    //@param: programid, inspectionid
    //@return : updated building approval list
    //TFS15751 - Updated cloning to new inspection and removing from previous inspection
    public static list<CLQ_Building_Approval__c> copyBuildingApprovaltoinspection(Id programID, Id inspectionID){
        String buildingApprovalsoqlQuery = createSOQLQuery('CLQ_Building_Approval__c', ' CLQ_Program__c='+'\''+programID+'\'', null); 
        list<CLQ_Building_Approval__c> buildingApprovallist = new list<CLQ_Building_Approval__c>();
        for(CLQ_Building_Approval__c buildingApprovalrecord : Database.query(buildingApprovalsoqlQuery)){
            CLQ_Building_Approval__c bldgRec = buildingApprovalrecord.clone(false, true, false, false);
            bldgRec.CLQ_Inspection__c = inspectionID;
            buildingApprovalrecord.CLQ_Program__c = null;
            buildingApprovallist.add(buildingApprovalrecord);
            buildingApprovallist.add(bldgRec); 
        }
        return buildingApprovallist;
    }
    
    //Mathod to copy all Room/Space inspection record to Program Transaction
    //@param:inspectionrecord id set
    //@return:
    public void copyRoomSpactionInspectiontoTransaction(set<id> inspectionRecordIDSet){
        list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = new list<CLQ_Room_Space_Inspection__c>();  
        set<id> programTransactionIDset = new set<id>();
        list<CLQ_Room_Space_Transaction__c > roomSpaceTransactionlist = new list<CLQ_Room_Space_Transaction__c>();
        map<ID,Schema.RecordTypeInfo> rt_Map = CLQ_Room_Space_Inspection__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        //Query all Room/Space Inspection record from the data base to clone
        list<String> extraField = new list<String>{'CLQ_Inspection__r.CLQ_Program_Transaction__c'};
        roomSpaceInspectionList = Database.query(createSOQLQuery('CLQ_Room_Space_Inspection__c',' CLQ_Inspection__c  in :inspectionRecordIDSet',extraField));
        
        //Make copy for each record
         for(CLQ_Room_Space_Inspection__c roomSpaceinspectionrecord : roomSpaceInspectionList){
            CLQ_Room_Space_Transaction__c newrecord = (CLQ_Room_Space_Transaction__c)cloneFromOneObjectToanother(roomSpaceinspectionrecord,'CLQ_Room_Space_Transaction__c');
            newrecord.CLQ_Program_Transaction__c = roomSpaceinspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c;
            Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByName().get(rt_map.get(roomSpaceinspectionrecord.recordTypeID).getName()).getRecordTypeId();
            newrecord.recordTypeID = devRecordTypeId;
            roomSpaceTransactionlist.add(newrecord);
            programTransactionIDset.add(roomSpaceinspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c);
         }
        
         //Delete all current roomspace transaction records from PT
         deleteRoomSpaceTransactionRecord(programTransactionIDset);
         
         //Insert new Room Space Transaction records
         if(roomSpaceTransactionlist.size()>0){
            insert roomSpaceTransactionlist;
         }
    
    }
    
    //Method to remove current Room/Space Transaction record
    //@param: set of ProgramTransaction ids
    //@return: none
    public void deleteRoomSpaceTransactionRecord(set<id> programTransactionIDSet){
        delete [Select Id
                        ,Name
                        ,CLQ_Program_Transaction__c
                FROM CLQ_Room_Space_Transaction__c  
                WHERE CLQ_Program_Transaction__c in :programTransactionIDSet];
    } 
    
    //Method to query all facility schedules from Program/Program transaction to inspection
    //@param: list of facility schedule
    //@return : updated facility schedule list
    public static list<CLQ_Facility_Schedule__c> copyfacilityScheduletoinspection(list<CLQ_Facility_Schedule__c> facilityScheduleList, Id inspectionID){
        for(CLQ_Facility_Schedule__c facilityScheduleRecord : facilityScheduleList){
            facilityScheduleRecord.CLQ_Inspection__c = inspectionID;
        }
        return facilityScheduleList;
    }
    
    //Method to copy all related Room Space Transaction to Room Space information record
    //@param: program Transaction record id set
    //@return : inserted room space information record list
    public static void copyRoomSpaceTransactiontoProgram(set<id> programTransactionIdset){
        
        //Get list of all room/Space transaciton record associated with give PT
        list<CLQ_Room_Space_Transaction__c> roomSpaceTransactionlist = new list<CLQ_Room_Space_Transaction__c>();
        list<String> extraField = new list<String>{'CLQ_Program_Transaction__r.CLQ_Program__c','CLQ_Program_Transaction__r.RecordTypeID'};
        roomSpaceTransactionlist = Database.query(createSOQLQuery('CLQ_Room_Space_Transaction__c',' CLQ_Program_Transaction__c  in :programTransactionIdset',extraField));
        set<String> changeOfLocationStringSet = new set<String>{'Amendment - Center - Change of Location','Amendment - FCC - Change of Location','Amendment - ODE - Change of Location'};
        
        //Copy all the room space transaciton to Room space information
        map<ID,Schema.RecordTypeInfo> rt_Map = CLQ_Room_Space_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
        list<CLQ_Room_Space__c> roomSpaceInformationList = new list<CLQ_Room_Space__c>();
        //Variable to perrom delete functionality
        list<CLQ_Room_Space__c> roomSpaceInformationListToDelete = new list<CLQ_Room_Space__c>();
        set<id> programIDSet = new set<id>();
        for(CLQ_Room_Space_Transaction__c roomspaceTransactionRecord : roomSpaceTransactionlist){
             CLQ_Room_Space__c newrecord = (CLQ_Room_Space__c)cloneFromOneObjectToanother(roomspaceTransactionRecord,'CLQ_Room_Space__c');
             newrecord.CLQ_Program__c = roomspaceTransactionRecord.CLQ_Program_Transaction__r.CLQ_Program__c;
             Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space__c.getRecordTypeInfosByName().get(rt_map.get(roomspaceTransactionRecord.recordTypeID).getName()).getRecordTypeId();
             newrecord.recordTypeID = devRecordTypeId;
             if(changeOfLocationStringSet.contains(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(roomspaceTransactionRecord.CLQ_Program_Transaction__r.recordtypeid).getname()) && roomspaceTransactionRecord.CLQ_Program__c == null){
                 roomspaceTransactionRecord.CLQ_Address__c = 'Current Location';
                 roomspaceTransactionRecord.CLQ_Currently_In_Use__c = 'Yes';
             }
             if(changeOfLocationStringSet.contains(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(roomspaceTransactionRecord.CLQ_Program_Transaction__r.recordtypeid).getname()) && roomspaceTransactionRecord.CLQ_Program__c != null){
                 roomspaceTransactionRecord.CLQ_Address__c = 'Previous Location';
                 roomspaceTransactionRecord.CLQ_Currently_In_Use__c = 'No';
             }
             roomSpaceInformationList.add(newrecord);
             programIDSet.add(roomspaceTransactionRecord.CLQ_Program_Transaction__r.CLQ_Program__c);
        }
        
        //Delete existing RoomSpace information record
        roomSpaceInformationListToDelete = [Select id,CLQ_Address__c FROM CLQ_Room_Space__c Where CLQ_Program__c in :programIDSet];
        if(roomSpaceInformationListToDelete.size()>0){
            delete roomSpaceInformationListToDelete;
        }
        
        if(roomSpaceInformationList.size()>0){
            insert roomSpaceInformationList;
        }
        
    } 
    
    
    //Method to copy all related list from Program Transacton to Program
    //@param:
    //@return:
    public static void copyRelatedListfromPTtoProgram(set<id> programTransactionIdset){
        list<CLQ_Program_Transaction__c> programTransactionlist = new list<CLQ_Program_Transaction__c>();
        set<String> changeOfLocationStringSet = new set<String>{'Amendment - Center - Change of Location','Amendment - FCC - Change of Location','Amendment - ODE - Change of Location'};
        programTransactionlist = [SELECT id
                                        ,CLQ_Program__c
                                        ,recordtypeid                                       
                                        ,CLQ_Funding_Source__c
                                        ,CLQ_Program_Type_Formula__c
                                        ,CLQ_Same_as_Program_Address__c
                                        ,CLQ_Mailing_City__c
                                        ,CLQ_Mailing_State__c
                                        ,CLQ_Mailing_Street_Address__c 
                                        ,CLQ_Mailing_Street_Address_2__c 
                                        ,CLQ_Mailing_ZipCode__c
                                        ,CLQ_Food_Service__c
                                        ,CLQ_Lead_Based_Paint__c
                                        ,CLQ_Asbestos__c
                                        ,CLQ_Storage_of_Hazardous_Toxic_Material__c
                                        ,CLQ_Tanks_currently_in_use__c
                                        ,CLQ_Materials_stored_in_Tanks__c
                                        ,CLQ_Any_Problems_With_Tanks__c
                                        ,CLQ_Level_of_Radon_Gas__c
                                        ,CLQ_Radon_Gas__c
                                        ,CLQDescription_of_other_toxic_substances__c
                                        ,CLQ_Other_Toxic_Substances__c
                                        ,CLQ_Calculated_Maximum_Capacity__c
                                        ,CLQ_Calculated_Max_Capacity_Under_2_Yrs__c
                                        ,CLQ_Approved_Total_Capacity__c
                                        ,CLQ_Approved_Capacity_Under_2__c
                                        ,CLQ_Approved_First_Day_at_New_Address__c 
                                        ,CLQ_Age_Groups_Served_Global__c
                                        ,CLQ_Services_Offered_Global__c
                                        ,CLQ_Attendance_Options_Global__c 
                                        ,CLQ_Full_Part_Time_Options_Global__c
                                        ,CLQ_Liability_Insurance__c
                                        ,CLQ_Total_Enrollment__c
                                        ,CLQ_Total_Enrollment_Under_2_1_2__c
                                        ,CLQ_New_Street_Address_1__c
                                        ,CLQ_New_Street_Address_2__c
                                        ,CLQ_New_State__c
                                        ,CLQ_New_Zip_Code__c
                                        ,CLQ_New_City__c
                                        ,CLQ_New_County__c
                                        ,CLQ_New_Phone_Extension__c
                                        ,CLQ_New_Phone_Number__c
                                        ,CLQ_New_Program_Email_Address__c
                                        ,CLQ_Planned_First_Day_of_Operation__c
                                        ,CLQ_Transaction_Assigned_To__c
                                        ,CLQ_Calculated_Max_Capacity_Under_2_5Yr__c 
                                        ,CLQ_Approved_Capacity_Under_2_1_2__c 
                                        ,CLQ_Total_No_of_Rooms_In_Use__c
                                        ,CLQ_Total_No_of_Staff__c
                                        ,CLQ_Full_Day_Option_Offered__c
                                        ,CLQ_Part_Day_Option_Offered__c
                                        ,CLQ_Estimated_Enrollment__c
                                        ,CLQ_New_BIRN_Site_IRN__c
                                        ,CLQ_New_Site_Name__c
                                        ,CLQ_ProgTrans_City__c
                                        ,CLQ_ProgTrans_County__c
                                        ,CLQ_ProgTrans_Phone__c
                                        ,CLQ_ProgTrans_Phone_Extension__c
                                        ,CLQ_ProgTrans_Program_Email_Address__c
                                        ,CLQ_ProgTrans_State__c
                                        ,CLQ_ProgTrans_Street_Address__c
                                        ,CLQ_ProgTrans_Street_Address_2__c
                                        ,CLQ_ProgTrans_Zip_Code__c
                                        ,CLQ_Number_of_Residents__c
                                        ,CLQ_Are_you_a_foster_parent__c
                                        ,CLQ_Foster_Children__c
                                        ,CLQ_Specialized_Foster_Home__c
                                        ,CLQ_New_Approved_Capacity_Under_2_1_2__c
                                        ,CLQ_Provider_Agreement__c
                                        ,CLQ_Total_Enrollment_Infants__c
                                        ,CLQ_Total_Enrollment_Older_Toddler__c
                                        ,CLQ_Total_Enrollment_Preschool__c
                                        ,CLQ_Total_Enrollment_School_Age__c
                                        ,CLQ_Application_Approved__c
                                        ,CLQ_Total_Enrollment_Young_Toddler__c    
                                        ,CLQ_New_Approved_All_Groups_Capacity__c
                                        ,CLQ_New_Approved_Under_2_Capacity__c
                                        ,CLQ_Services_Offered_Day_Camp__c
                                        ,OEDS_Location_Id_c__c //11885
                                        ,OEDS_Location_Type_c__c //11885
										,CLQ_Last_Day_of_Operation__c
										,CLQ_Is_the_Day_Camp_ACA_Certified__c, //13790
										CLQ_Name_of_Day_Camp_on_ACA_Certificate__c, //13790
										CLQ_Program_Record_Type__c
                                        ,(SELECT id
                                                 ,Name
                                                 ,CLQ_Program__c
                                                 ,CLQ_Program_Transaction__c
                                                 ,CLQ_Address__c
                                                 ,CLQ_In_Use__c 
                                          FROM Building_Food_Fire_Approvals__r)
                                        ,(SELECT id
                                                ,CLQ_Program__c
                                                ,CLQ_Program_Transaction__c
                                                ,Name
                                         FROM Facility_Schedules__r)
                                         ,(SELECT id
                                                ,CLQ_Program_Transaction_Source__c
                                                ,CLQ_Program__c
                                            FROM Roles__r)  
                                    FROM CLQ_Program_Transaction__c
                                    WHERE id in :programTransactionIdset];
        list<CLQ_Building_Approval__c> buildingApprovalToUpdate = new list<CLQ_Building_Approval__c>();                         
        list<CLQ_Facility_Schedule__c> facilityScheduletoUpdate= new list<CLQ_Facility_Schedule__c>();
        list<CLQ_Program__c> programListtoUpdate = new list<CLQ_Program__c>();
        set<id> programtoUpdateIDSet = new set<id>();
        set<id> buildingApprovalIDset = new set<id>();
        set<id> facilityScheduleIDset = new set<id>();
        
        for(CLQ_Program_Transaction__c programTransactionRecord : programTransactionlist){
            //Copy Building Approvals to Program
            for(CLQ_Building_Approval__c buildingApprovalRecord : programTransactionRecord.Building_Food_Fire_Approvals__r){
                if(buildingApprovalRecord.CLQ_Program__c == null){
                    buildingApprovalRecord.CLQ_Program__c = programTransactionRecord.CLQ_Program__c;
                    if(changeOfLocationStringSet.contains(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname())){
                        buildingApprovalRecord.CLQ_Address__c= 'Current Location';
                        buildingApprovalRecord.CLQ_In_Use__c = 'Yes';
                    }
                   
                }
                else if(buildingApprovalRecord.CLQ_Program__c != null && changeOfLocationStringSet.contains(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname())){
                    buildingApprovalRecord.CLQ_Address__c= 'Previous Location';
                    buildingApprovalRecord.CLQ_In_Use__c = 'No';
                }
                if(!buildingApprovalIDset.contains(buildingApprovalRecord.id)){
                    buildingApprovalToUpdate.add(buildingApprovalRecord);
                    buildingApprovalIDset.add(buildingApprovalRecord.id);
                }
            } //end for Building Approvals
            //Copy all facility scheduled record
            for(CLQ_Facility_Schedule__c facilityScheduleRecord: programTransactionRecord.Facility_Schedules__r){
                if(facilityScheduleRecord.CLQ_Program__c == null){
                    facilityScheduleRecord.CLQ_Program__c = programTransactionRecord.CLQ_Program__c;
                    if(!facilityScheduleIDset.contains(facilityScheduleRecord.id)){
                        facilityScheduletoUpdate.add(facilityScheduleRecord);
                        facilityScheduleIDset.add(facilityScheduleRecord.id);
                    }
                    
                    
                }
            }//end for Facility Schedule
            
            if(!programtoUpdateIDSet.contains(programTransactionRecord.CLQ_Program__c)){
                        CLQ_Program__c newProgram = new CLQ_Program__c(id=programTransactionRecord.CLQ_Program__c);
                        //Pre-license
                         
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - ODE Program'
                         || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'
                         || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'){
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                            
                            //Mailing Information
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            }
                            //New Building/Site Info
                            /*newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                            newProgram.CLQ_Lead_Based_Paint__c=programTransactionRecord.CLQ_Lead_Based_Paint__c;
                            newProgram.CLQ_Asbestos__c=programTransactionRecord.CLQ_Asbestos__c;
                            newProgram.CLQ_Storage_of_Hazardous_Toxic_Material__c=programTransactionRecord.CLQ_Storage_of_Hazardous_Toxic_Material__c;
                            newProgram.CLQ_Tanks_currently_in_use__c=programTransactionRecord.CLQ_Tanks_currently_in_use__c;
                            newProgram.CLQ_Materials_stored_in_Tanks__c=programTransactionRecord.CLQ_Materials_stored_in_Tanks__c;
                            newProgram.CLQ_Level_of_Radon_Gas__c=programTransactionRecord.CLQ_Level_of_Radon_Gas__c;
                            newProgram.CLQ_Radon_Gas__c=programTransactionRecord.CLQ_Radon_Gas__c;
                            newProgram.CLQ_Describe_Other_Toxic_Substances__c =programTransactionRecord.CLQDescription_of_other_toxic_substances__c;
                            newProgram.CLQ_Other_Toxic_Substances__c=programTransactionRecord.CLQ_Other_Toxic_Substances__c;
                            
                            */
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - ODE Program'){
                                newProgram.CLQ_Total_Staff__c=programTransactionRecord.CLQ_Total_No_of_Staff__c;
                                newProgram.CLQ_Part_day_Option__c =programTransactionRecord.CLQ_Part_Day_Option_Offered__c;
                                //11885
                                newProgram.OEDS_Location_Id__c=programTransactionRecord.OEDS_Location_Id_c__c;
                                newProgram.OEDS_Location_Type__c=programTransactionRecord.OEDS_Location_Type_c__c;
                                }
                            newProgram.CLQ_Full_Day_Option_Offered__c=programTransactionRecord.CLQ_Full_Day_Option_Offered__c;
                            
                            
                            //Program Address and Contact Information
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                            
                                newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_ProgTrans_Phone__c;
                                newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_ProgTrans_Phone_Extension__c;
                                newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_ProgTrans_Program_Email_Address__c;
                            }
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_ProgTrans_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_ProgTrans_County__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_ProgTrans_State__c;
                            newProgram.CLQ_Street_Address_1__c =programTransactionRecord.CLQ_ProgTrans_Street_Address__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_ProgTrans_Street_Address_2__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_ProgTrans_Zip_Code__c;
                            
                            
                            //Services Information
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                            
                                newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                            
                            }
                            newProgram.CLQ_Services_Offered_Global__c=programTransactionRecord.CLQ_Services_Offered_Global__c;
                            newProgram.CLQ_Age_Groups_Served_Global__c=programTransactionRecord.CLQ_Age_Groups_Served_Global__c;
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                            
                                newProgram.CLQ_Full_Part_Time_Options_Global__c=programTransactionRecord.CLQ_Full_Part_Time_Options_Global__c;
                                newProgram.CLQ_Provider_Agreement__c=programTransactionRecord.CLQ_Provider_Agreement__c;
                            }
                            newProgram.CLQ_Attendance_Options_Global__c=programTransactionRecord.CLQ_Attendance_Options_Global__c;
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                            
                                newProgram.CLQ_Liability_Insurance__c=programTransactionRecord.CLQ_Liability_Insurance__c;
                            }
                            //Capacity Information
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - ODE Program'
                            || Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - CC Center'){
                                //newProgram.CLQ_Approved_Capacity_Under_2__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2__c;
                                newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2_1_2__c;
                                }
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'){
                                //newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2_1_2__c;
                                newProgram.CLQ_Approved_Capacity_Under_2__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2__c;
                            }
                            newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_Approved_Total_Capacity__c;
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_5_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c ;//12138
                            newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c; //bug# 11125
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - ODE Program'){
                                newProgram.CLQ_Full_Day_Option_Offered__c=programTransactionRecord.CLQ_Full_Day_Option_Offered__c;
                                newProgram.CLQ_Part_day_Option__c =programTransactionRecord.CLQ_Part_Day_Option_Offered__c;
                                newProgram.CLQ_Funding__c=programTransactionRecord.CLQ_Funding_Source__c;
                            }
                        } // end if Initial Applications
                        
                       
                        /***************************************************/
                        //Change of capacity
                        //a.Amendment- FCC - Change of Capacity / Space
                        if( Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Amendment- FCC - Change of Capacity / Space'){
                            //Mailing Information 
                            /* Commented for #11708,#11652
                            if(programTransactionRecord.CLQ_Program_Type_Formula__c== 'FCC - Type A Home'
                            || programTransactionRecord.CLQ_Program_Type_Formula__c== 'FCC - Type B Home'
                            || programTransactionRecord.CLQ_Program_Type_Formula__c== 'Child Care Center'){
                                newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                                newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                                newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                                newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                                newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                                newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            }*/
                            //Capacity Info
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_5_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c ;//12138
                            newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_New_Approved_All_Groups_Capacity__c;
                           	newProgram.CLQ_Approved_Capacity_Under_2__c=programTransactionRecord.CLQ_New_Approved_Under_2_Capacity__c;
                            
                            //Enrollment information
                            //Comment Begin - MP - OJLS-1235 - handled in process builder //15275
                           /* newProgram.CLQ_Total_Enrollment__c=programTransactionRecord.CLQ_Total_Enrollment__c;
                            newProgram.CLQ_Total_Enrollment_Under_2_5_years__c=programTransactionRecord.CLQ_Total_Enrollment_Under_2_1_2__c;
                            
                            newProgram.CLQ_Total_Enrollment_Infants__c = programTransactionRecord.CLQ_Total_Enrollment_Infants__c;
                            newProgram.CLQ_Total_Enrollment_Older_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                            newProgram.CLQ_Total_Enrollment_Preschool__c=programTransactionRecord.CLQ_Total_Enrollment_Preschool__c;
                            newProgram.CLQ_Total_Enrollment_School_Age__c=programTransactionRecord.CLQ_Total_Enrollment_School_Age__c;
                            newProgram.CLQ_Total_Enrollment_Young_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Young_Toddler__c;*/
                            //Comment end - MP - OJLS-1235 - handled in process builder
                            //New Location
                            /*newProgram.CLQ_Street_Address_1__c=programTransactionRecord.CLQ_New_Street_Address_1__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_New_Street_Address_2__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_New_State__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_New_Zip_Code__c;
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_New_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_New_County__c;
                            newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_New_Phone_Extension__c;
                            newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_New_Phone_Number__c;
                            newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_New_Program_Email_Address__c;
                            newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c;*/
                            
                            /*Commented for #11708,#11652
                            newProgram.Program_Rating__c=null;
                            newProgram.CLQ_Program_Rating__c=null;
                            newProgram.Rating_Effective_Date__c=null;
                            newProgram.Rating_Expiration_Date__c=null;
                            newProgram.Rating_Anniversary_Date__c=null;
                            */ 
                            
                        } //end if FCC COC
                        //b.Amendment - ODE and Center - Change of Capacity / Space
                         if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Amendment - ODE and Center - Change of Capacity / Space'){
                        //if (Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname().containsIgnoreCase('Change of Capacity / Space')){
                       
                            //Mailing Information
                            /*Commented for #11708,#11652
                            if(programTransactionRecord.CLQ_Program_Type_Formula__c== 'FCC - Type A Home'
                            || programTransactionRecord.CLQ_Program_Type_Formula__c== 'FCC - Type B Home'
                            || programTransactionRecord.CLQ_Program_Type_Formula__c== 'Child Care Center'){ 
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            }*/
                            
                            //Capacity Info
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_5_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c ;
                            /*newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_Approved_Total_Capacity__c;*/newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_New_Approved_All_Groups_Capacity__c;
                            /*newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2_1_2__c ;*/newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_New_Approved_Capacity_Under_2_1_2__c;
                            newProgram.CLQ_Approved_Capacity_Under_2__c =programTransactionRecord.CLQ_New_Approved_Under_2_Capacity__c;

                            //Enrollment information
                            newProgram.CLQ_Total_Enrollment__c=programTransactionRecord.CLQ_Total_Enrollment__c;
                            newProgram.CLQ_Total_Enrollment_Under_2_5_years__c=programTransactionRecord.CLQ_Total_Enrollment_Under_2_1_2__c;
                            
                            newProgram.CLQ_Total_Enrollment_Infants__c = programTransactionRecord.CLQ_Total_Enrollment_Infants__c;
                            newProgram.CLQ_Total_Enrollment_Older_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                            newProgram.CLQ_Total_Enrollment_Preschool__c=programTransactionRecord.CLQ_Total_Enrollment_Preschool__c;
                            newProgram.CLQ_Total_Enrollment_School_Age__c=programTransactionRecord.CLQ_Total_Enrollment_School_Age__c;
                            newProgram.CLQ_Total_Enrollment_Young_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Young_Toddler__c;
                            
                            //New Location
                            /*newProgram.CLQ_Street_Address_1__c=programTransactionRecord.CLQ_New_Street_Address_1__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_New_Street_Address_2__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_New_State__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_New_Zip_Code__c;
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_New_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_New_County__c;
                            newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_New_Phone_Extension__c;
                            newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_New_Phone_Number__c;
                            newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_New_Program_Email_Address__c;*/
                            
                           // newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c; // 12212 
                            
                            /*Commented for #11708,#11652
                            newProgram.Program_Rating__c=null;
                            newProgram.CLQ_Program_Rating__c=null;
                            newProgram.Rating_Effective_Date__c=null;
                            newProgram.Rating_Expiration_Date__c=null;
                            newProgram.Rating_Anniversary_Date__c=null; */
                        } //end if ODE & CCC COC
                        /***************************************************/
                        //Change of location
                        //a.Amendment - ODE - Change of Location
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Amendment - ODE - Change of Location'){
                            
                            //Mailing Information SR default commented
                            /*newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            */
                            //New Building/Site Info
                            newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                            newProgram.CLQ_Lead_Based_Paint__c=programTransactionRecord.CLQ_Lead_Based_Paint__c;
                            newProgram.CLQ_Total_Staff__c=programTransactionRecord.CLQ_Total_No_of_Staff__c;
                            newProgram.CLQ_Full_Day_Option_Offered__c=programTransactionRecord.CLQ_Full_Day_Option_Offered__c;
                            newProgram.CLQ_Part_day_Option__c =programTransactionRecord.CLQ_Part_Day_Option_Offered__c;
                            
                            //Capacity Info
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_5_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c ;
                            newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_Approved_Total_Capacity__c;
                            //newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2_1_2__c ;
                            
                            //Service Information
                            newProgram.CLQ_Age_Groups_Served_Global__c=programTransactionRecord.CLQ_Age_Groups_Served_Global__c;
                            newProgram.CLQ_Services_Offered_Global__c=programTransactionRecord.CLQ_Services_Offered_Global__c;
                            newProgram.CLQ_Attendance_Options_Global__c =programTransactionRecord.CLQ_Attendance_Options_Global__c ;
                            //newProgram.CLQ_Full_Part_Time_Options_Global__c=programTransactionRecord.CLQ_Full_Part_Time_Options_Global__c;
                            
                            //Enrollment information
                            newProgram.CLQ_Total_Enrollment__c=programTransactionRecord.CLQ_Total_Enrollment__c;
                            newProgram.CLQ_Total_Enrollment_Under_2_5_years__c=programTransactionRecord.CLQ_Total_Enrollment_Under_2_1_2__c;
                            
                            newProgram.CLQ_Total_Enrollment_Infants__c = programTransactionRecord.CLQ_Total_Enrollment_Infants__c;
                            newProgram.CLQ_Total_Enrollment_Older_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                            newProgram.CLQ_Total_Enrollment_Preschool__c=programTransactionRecord.CLQ_Total_Enrollment_Preschool__c;
                            newProgram.CLQ_Total_Enrollment_School_Age__c=programTransactionRecord.CLQ_Total_Enrollment_School_Age__c;
                            newProgram.CLQ_Total_Enrollment_Young_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Young_Toddler__c;
                            //New Location
                            newProgram.CLQ_Street_Address_1__c=programTransactionRecord.CLQ_New_Street_Address_1__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_New_Street_Address_2__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_New_State__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_New_Zip_Code__c;
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_New_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_New_County__c;
                            //newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_New_Phone_Extension__c;
                            //newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_New_Phone_Number__c;
                            //newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_New_Program_Email_Address__c;
                            //newProgram.=programTransactionRecord.CLQ_Planned_First_Day_of_Operation__c;
                            newProgram.CLQ_Estimated_Enrollment__c=programTransactionRecord.CLQ_Estimated_Enrollment__c;
                            newProgram.CLQ_BIRN__c=programTransactionRecord.CLQ_New_BIRN_Site_IRN__c;
                            newProgram.Name=programTransactionRecord.CLQ_New_Site_Name__c;
                           // newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c;    //12212
                            
                            //newProgram.OEDS_Site_Status_c= programTransactionRecord.OEDS_Site_Status__c;
                            newProgram.OEDS_Location_Id__c=programTransactionRecord.OEDS_Location_Id_c__c; //11894 
                            newProgram.OEDS_Location_Type__c=programTransactionRecord.OEDS_Location_Type_c__c; //11894 

                            /*Commented for #11708,#11652
                            newProgram.Program_Rating__c=null;
                            newProgram.CLQ_Program_Rating__c=null;
                            newProgram.Rating_Effective_Date__c=null;
                            newProgram.Rating_Expiration_Date__c=null;
                            newProgram.Rating_Anniversary_Date__c=null; */
                        } //end of ODE COL
                        
                        //b.Amendment - FCC - Change of Location
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Amendment - FCC - Change of Location'){
                            //Mailing Information 
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            
                            //New Building/Site Info
                            newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                            /*newProgram.CLQ_Lead_Based_Paint__c=programTransactionRecord.CLQ_Lead_Based_Paint__c;
                            newProgram.CLQ_Asbestos__c=programTransactionRecord.CLQ_Asbestos__c;
                            newProgram.CLQ_Storage_of_Hazardous_Toxic_Material__c=programTransactionRecord.CLQ_Storage_of_Hazardous_Toxic_Material__c;
                            newProgram.CLQ_Tanks_currently_in_use__c=programTransactionRecord.CLQ_Tanks_currently_in_use__c;
                            newProgram.CLQ_Materials_stored_in_Tanks__c=programTransactionRecord.CLQ_Materials_stored_in_Tanks__c;
                            newProgram.CLQ_Level_of_Radon_Gas__c=programTransactionRecord.CLQ_Level_of_Radon_Gas__c;
                            newProgram.CLQ_Radon_Gas__c=programTransactionRecord.CLQ_Radon_Gas__c;
                            newProgram.CLQ_Describe_Other_Toxic_Substances__c =programTransactionRecord.CLQDescription_of_other_toxic_substances__c;
                            newProgram.CLQ_Other_Toxic_Substances__c=programTransactionRecord.CLQ_Other_Toxic_Substances__c;
                            */
                            //Capacity Info
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_Yrs__c;
                            newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_Approved_Total_Capacity__c;
                            newProgram.CLQ_Approved_Capacity_Under_2__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2__c;
                            
                            //Service Information
                            newProgram.CLQ_Age_Groups_Served_Global__c=programTransactionRecord.CLQ_Age_Groups_Served_Global__c;
                            newProgram.CLQ_Services_Offered_Global__c=programTransactionRecord.CLQ_Services_Offered_Global__c;
                            newProgram.CLQ_Attendance_Options_Global__c =programTransactionRecord.CLQ_Attendance_Options_Global__c ;
                            newProgram.CLQ_Full_Part_Time_Options_Global__c=programTransactionRecord.CLQ_Full_Part_Time_Options_Global__c;
                            newProgram.CLQ_Liability_Insurance__c=programTransactionRecord.CLQ_Liability_Insurance__c;
                            
                            //Enrollment information // 15275 - Commenting copy over Enrollment info on to the program
                            /**newProgram.CLQ_Total_Enrollment__c=programTransactionRecord.CLQ_Total_Enrollment__c;
                            newProgram.CLQ_Total_Enrollment_Under_2_5_years__c=programTransactionRecord.CLQ_Total_Enrollment_Under_2_1_2__c;
                            newProgram.CLQ_Total_Enrollment_Infants__c = programTransactionRecord.CLQ_Total_Enrollment_Infants__c;
                            newProgram.CLQ_Total_Enrollment_Older_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                            newProgram.CLQ_Total_Enrollment_Preschool__c=programTransactionRecord.CLQ_Total_Enrollment_Preschool__c;
                            newProgram.CLQ_Total_Enrollment_School_Age__c=programTransactionRecord.CLQ_Total_Enrollment_School_Age__c;
                            newProgram.CLQ_Total_Enrollment_Young_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Young_Toddler__c;*/
                            
                            //New Location
                            newProgram.CLQ_Street_Address_1__c=programTransactionRecord.CLQ_New_Street_Address_1__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_New_Street_Address_2__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_New_State__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_New_Zip_Code__c;
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_New_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_New_County__c;
                            newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_New_Phone_Extension__c;
                            newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_New_Phone_Number__c;
                            //newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_New_Program_Email_Address__c;//11708,11652
                            
                           // newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c; //12212
                            
                            //Resident Information
                            if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - FCC'){
                                newProgram.CLQ_Number_of_Residents__c=programTransactionRecord.CLQ_Number_of_Residents__c;
                                newProgram.CLQ_Are_you_Foster_Parent__c=programTransactionRecord.CLQ_Are_you_a_foster_parent__c;
                                newProgram.CLQ_Foster_Children__c=programTransactionRecord.CLQ_Foster_Children__c;
                                newProgram.CLQ_Specialized_Foster_Home__c=programTransactionRecord.CLQ_Specialized_Foster_Home__c;
                            }
							/*Commented for #11708,#11652
                            newProgram.Program_Rating__c=null;
                            newProgram.CLQ_Program_Rating__c=null;
                            newProgram.Rating_Effective_Date__c=null;
                            newProgram.Rating_Expiration_Date__c=null;
                            newProgram.Rating_Anniversary_Date__c=null; */ 
                            
                        } //end FCC COL
                        
                        //c.Amendment - Center - Change of Location
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Amendment - Center - Change of Location'){
                            
                            //Mailing Information 
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            
                            //New Building/Site Info
                            /*newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                            newProgram.CLQ_Lead_Based_Paint__c=programTransactionRecord.CLQ_Lead_Based_Paint__c;
                            newProgram.CLQ_Asbestos__c=programTransactionRecord.CLQ_Asbestos__c;
                            newProgram.CLQ_Storage_of_Hazardous_Toxic_Material__c=programTransactionRecord.CLQ_Storage_of_Hazardous_Toxic_Material__c;
                            newProgram.CLQ_Tanks_currently_in_use__c=programTransactionRecord.CLQ_Tanks_currently_in_use__c;
                            newProgram.CLQ_Materials_stored_in_Tanks__c=programTransactionRecord.CLQ_Materials_stored_in_Tanks__c;
                            newProgram.CLQ_Level_of_Radon_Gas__c=programTransactionRecord.CLQ_Level_of_Radon_Gas__c;
                            newProgram.CLQ_Radon_Gas__c=programTransactionRecord.CLQ_Radon_Gas__c;
                            newProgram.CLQ_Describe_Other_Toxic_Substances__c =programTransactionRecord.CLQDescription_of_other_toxic_substances__c;
                            newProgram.CLQ_Other_Toxic_Substances__c=programTransactionRecord.CLQ_Other_Toxic_Substances__c;*/
                            
                            //Capacity Info
                            newProgram.CLQ_Calculated_Max_Capacity__c=programTransactionRecord.CLQ_Calculated_Maximum_Capacity__c;
                            newProgram.CLQ_Max_Capacity_Under_2_5_Years__c=programTransactionRecord.CLQ_Calculated_Max_Capacity_Under_2_5Yr__c ;
                            newProgram.CLQ_Approved_Total_Capacity__c=programTransactionRecord.CLQ_Approved_Total_Capacity__c;
                            newProgram.CLQ_Approved_Capacity_Under_2_5__c=programTransactionRecord.CLQ_Approved_Capacity_Under_2_1_2__c ;
                            
                            //Service Information
                            newProgram.CLQ_Age_Groups_Served_Global__c=programTransactionRecord.CLQ_Age_Groups_Served_Global__c;
                            newProgram.CLQ_Services_Offered_Global__c=programTransactionRecord.CLQ_Services_Offered_Global__c;
                            newProgram.CLQ_Attendance_Options_Global__c =programTransactionRecord.CLQ_Attendance_Options_Global__c ;
                            newProgram.CLQ_Full_Part_Time_Options_Global__c=programTransactionRecord.CLQ_Full_Part_Time_Options_Global__c;
                            newProgram.CLQ_Liability_Insurance__c=programTransactionRecord.CLQ_Liability_Insurance__c;
                            
                            //Enrollment information // 15275 - Commenting copy over of Enrollment info to Program
                            /**newProgram.CLQ_Total_Enrollment__c=programTransactionRecord.CLQ_Total_Enrollment__c;
                            newProgram.CLQ_Total_Enrollment_Under_2_5_years__c=programTransactionRecord.CLQ_Total_Enrollment_Under_2_1_2__c;
                            newProgram.CLQ_Total_Enrollment_Infants__c = programTransactionRecord.CLQ_Total_Enrollment_Infants__c;
                            newProgram.CLQ_Total_Enrollment_Older_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                            newProgram.CLQ_Total_Enrollment_Preschool__c=programTransactionRecord.CLQ_Total_Enrollment_Preschool__c;
                            newProgram.CLQ_Total_Enrollment_School_Age__c=programTransactionRecord.CLQ_Total_Enrollment_School_Age__c;
                            newProgram.CLQ_Total_Enrollment_Young_Toddler__c=programTransactionRecord.CLQ_Total_Enrollment_Young_Toddler__c;*/
                            //New Location
                            newProgram.CLQ_Street_Address_1__c=programTransactionRecord.CLQ_New_Street_Address_1__c;
                            newProgram.CLQ_Street_Address_2__c=programTransactionRecord.CLQ_New_Street_Address_2__c;
                            newProgram.CLQ_State__c=programTransactionRecord.CLQ_New_State__c;
                            newProgram.CLQ_Zip_Code__c=programTransactionRecord.CLQ_New_Zip_Code__c;
                            newProgram.CLQ_City__c=programTransactionRecord.CLQ_New_City__c;
                            newProgram.CLQ_County__c=programTransactionRecord.CLQ_New_County__c;
                            newProgram.CLQ_Phone_Extension__c=programTransactionRecord.CLQ_New_Phone_Extension__c;
                            newProgram.CLQ_Phone__c=programTransactionRecord.CLQ_New_Phone_Number__c;
                            //newProgram.CLQ_Program_Email__c=programTransactionRecord.CLQ_New_Program_Email_Address__c;//11708,11652
                            //newProgram.=programTransactionRecord.CLQ_Planned_First_Day_of_Operation__c;
                           // newProgram.CLQ_Licensing_Specialist__c=programTransactionRecord.CLQ_Transaction_Assigned_To__c; //12212
                            
                            /*Commented for #11708,#11652
                            newProgram.Program_Rating__c=null;
                            newProgram.CLQ_Program_Rating__c=null;
                            newProgram.Rating_Effective_Date__c=null;
                            newProgram.Rating_Expiration_Date__c=null;
                            newProgram.Rating_Anniversary_Date__c=null; */
                        } //end CCC COL
                        
                        //11774 Starts - Copying IHA Program Transaction to Program
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'In-Home Aide'){
                        	// Mailing Information 
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_Address__c = programTransactionRecord.CLQ_Mailing_Street_Address__c;
                            newProgram.CLQ_Mailing_Address_2__c = programTransactionRecord.CLQ_Mailing_Street_Address_2__c;
                            newProgram.CLQ_Mailing_City__c = programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c = programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_ZIP_Code__c = programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            
                            //Provider Address Information
                            newProgram.CLQ_Street_Address_1__c = programTransactionRecord.CLQ_ProgTrans_Street_Address__c;
                            newProgram.CLQ_Street_Address_2__c = programTransactionRecord.CLQ_ProgTrans_Street_Address_2__c;
                            newProgram.CLQ_City__c = programTransactionRecord.CLQ_ProgTrans_City__c;
                            newProgram.CLQ_State__c = programTransactionRecord.CLQ_ProgTrans_State__c;
                            newProgram.CLQ_Zip_Code__c = programTransactionRecord.CLQ_ProgTrans_Zip_Code__c;
                            newProgram.CLQ_County__c = programTransactionRecord.CLQ_ProgTrans_County__c;
                            
                            //Contact Info
							newProgram.CLQ_Program_Email__c = programTransactionRecord.CLQ_ProgTrans_Program_Email_Address__c;
							newProgram.CLQ_Phone_Extension__c = programTransactionRecord.CLQ_ProgTrans_Phone_Extension__c;
							newProgram.CLQ_Phone__c = programTransactionRecord.CLQ_ProgTrans_Phone__c;
                            
                            //Licensing Reviewer Info
                            newProgram.CLQ_Assigned_Reviewer__c = programTransactionRecord.CLQ_Transaction_Assigned_To__c;                            
                        }
                        //11774 Ends

						//CR - 12166 - Copy Application Day Camp updates to Program
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Application - Day Camp' ){ //13554 - Added to cpy the info from PT to program once approved
                        	Date DCAppRenStartDatePeriod = date.newinstance(System.today().year(), 1, 1);
                        	Date DCAppRenEndDatePeriod = date.newinstance(System.today().year(), 3, 14);
                        	System.debug('Ren start period is ' + DCAppRenStartDatePeriod);
                        	System.debug('Ren End period is ' + DCAppRenEndDatePeriod);
                        	newProgram.CLQ_Food_Service__c=programTransactionRecord.CLQ_Food_Service__c;
                        	newProgram.Services_Offered_Day_Camp__c=programTransactionRecord.CLQ_Services_Offered_Day_Camp__c;
                        	System.debug('Application approved date is : ' + programTransactionRecord.CLQ_Application_Approved__c );
                        	//13554 -  Updated the logic for DC Apps , if approved is between jan 1st and march 14th then the start date going to be 3/15/yyyy 
                        	if(programTransactionRecord.CLQ_Application_Approved__c >= DCAppRenStartDatePeriod && programTransactionRecord.CLQ_Application_Approved__c <= DCAppRenEndDatePeriod )
                        		newProgram.Approval_Start_Date__c = date.newInstance(programTransactionRecord.CLQ_Application_Approved__c.year(), 03, 15);	
                        	else
                        		newProgram.Approval_Start_Date__c = programTransactionRecord.CLQ_Application_Approved__c;
                        	newProgram.Approval_End_Date__c = date.newInstance(programTransactionRecord.CLQ_Application_Approved__c.year() +1, 03, 14);
                        	newProgram.Approved_to_do_a_Provider_Agreement__c = 'Yes';
                        	//Mailing Information
                            newProgram.CLQ_Same_as_Program_Address__c=programTransactionRecord.CLQ_Same_as_Program_Address__c;
                            newProgram.CLQ_Mailing_City__c=programTransactionRecord.CLQ_Mailing_City__c;
                            newProgram.CLQ_Mailing_State__c=programTransactionRecord.CLQ_Mailing_State__c;
                            newProgram.CLQ_Mailing_Address__c=programTransactionRecord.CLQ_Mailing_Street_Address__c ;
                            newProgram.CLQ_Mailing_Address_2__c=programTransactionRecord.CLQ_Mailing_Street_Address_2__c ;
                            newProgram.CLQ_Mailing_ZIP_Code__c=programTransactionRecord.CLQ_Mailing_ZipCode__c;
                            //13790 start - copy ACA fields
                        	newProgram.CLQ_Is_Day_Camp_ACA_Certified__c=programTransactionRecord.CLQ_Is_the_Day_Camp_ACA_Certified__c;                          
                        	newProgram.Name_of_Day_Camp_from_ACA__c=programTransactionRecord.CLQ_Name_of_Day_Camp_on_ACA_Certificate__c;
                            //13790 end
                            system.debug('programTransactionRecord.CLQ_Is_the_Day_Camp_ACA_Certified__c-->' + programTransactionRecord.CLQ_Is_the_Day_Camp_ACA_Certified__c);
                        }   
                        
                        //CR - 12420 - Copy Registration Closure updates to Program
                        if(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosById().get(programTransactionRecord.recordtypeid).getname() == 'Approval Closure' && programTransactionRecord.CLQ_Program_Record_Type__c == 'Day Camp'){
                        	newProgram.Approved_to_do_a_Provider_Agreement__c = 'No';
                        	newProgram.Approval_End_Date__c = programTransactionRecord.CLQ_Last_Day_of_Operation__c; 
                        }//CR - 12420 Ends - Copy Registration Closure updates to Program
                                             
                        programListtoUpdate.add(newProgram);
                        programtoUpdateIDSet.add(programTransactionRecord.CLQ_Program__c); 
                    }
            
        } //end for program transaction
        try{
            if(buildingApprovaltoUpdate.size()>0){update buildingApprovaltoUpdate;}
            if(facilityScheduletoUpdate.size()>0){update facilityScheduletoUpdate;}
            if(programListtoUpdate.size()>0){update programListtoUpdate;}
        }
        catch (exception e)
        {
                system.debug('Error in CLQ_UtilityClass ----'+e);
                //Error Framework
                Integration_Transaction_Logs.LogErrorRealTime('SJ-006.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
        
    } //end method copyRelatedListfromPTtoProgram
     
    //Method to check if the inspection is already exist or not
    //@param: program/Program transaction ID, isProgramTransactionFlag(make true if you are looking for PT)
    //@return: isValid
    public static boolean ifInspectionAlreadyExists(ID recordId, Boolean isProgramTransactionFlag,String inspectionType){
        boolean isExist = false;
        list<CLQ_Inspection__c> inspectionList = new list<CLQ_Inspection__c>();
        set<String> inProcessStatusSet = new set<String>{'Pending Processing','Returned to Reviewer','Pending Approval','Revision In Progress','In Progress'};
        if(isProgramTransactionFlag){
            inspectionList =  Database.query(createSOQLQuery('CLQ_Inspection__c', ' CLQ_Program_Transaction__c='+'\''+recordId+'\' AND CLQ_Inspection_Type__c='+'\''+inspectionType+'\' AND CLQ_Inspection_Status__c IN :inProcessStatusSet', null)); 
        }else{
            inspectionList =  Database.query(createSOQLQuery('CLQ_Inspection__c', ' CLQ_Program__c='+'\''+recordId+'\' AND CLQ_Inspection_Type__c='+'\''+inspectionType+'\' AND CLQ_Program_Transaction__c = NULL AND CLQ_Inspection_Status__c IN :inProcessStatusSet', null)); 
        }
        
        System.debug('Inspection List: ' + inspectionList);

        if(inspectionList.size()>0){
            isExist = true;
        }
        return isExist;
    }   
        
    @InvocableMethod(label='Quick Exit' description='Doesn\'t do anything, just a short cut to exit a Process Flow')
    public static void QuickExit() {  }
    
    //12069 Starts
    /*Method to get combined county set for User Role County*/
    public static set<String> getCombinedCounties(String userRole){
    	Set<String> setCombinedCounties = new Set<String>();
    	
    	system.debug('-- User Role --- '+userRole);
    	
    	if(userRole.length()>0 && userRole.indexOf('County') >= 0){
    		String usrRoleCounty = userRole.subString(0, userRole.indexOf('County')).trim().toUpperCase();
    		system.debug('-- User Role County --- '+usrRoleCounty);
    		
	    	for(CLQ_Combined_Counties__mdt ccm : [Select CLQ_Combined_Counties__c from CLQ_Combined_Counties__mdt 
	    												where DeveloperName =: usrRoleCounty
	    												AND CLQ_Process_Combined_County__c = true]){
	    		for(String county : ccm.CLQ_Combined_Counties__c.split(',')){
	    			setCombinedCounties.add(county.trim());
	    		}
	    	}
    	}
    	
    	system.debug('--- Combined County Set --- '+setCombinedCounties);
    	
    	return setCombinedCounties;
    }
    //12069 Ends
}