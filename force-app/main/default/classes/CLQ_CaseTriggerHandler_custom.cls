/*************************************************************************************************************
**************************************************************************************************************
** Name : CLQ_CaseTriggerHandler_custom
** Description : This class contains all detail logic/methods for CLQ_Case_Custom__c object's trigger. Methods are being called from CLQ_CaseTrigger_custom 
** Version          : 1.5
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version     Description
**  Developer               N/A             1.0         Initial Build 
**  Ankush R Relekar        11/29/2021      1.1         Trigger handler for Case Custom Object
**************************************************************************************************************/
public with sharing class CLQ_CaseTriggerHandler_custom extends CLQ_Trigger {
	public static final String COUNTY_ADMIN ='County Admin';
    public static final String COUNTY_APPROVER ='County Approver';
    public static final String COUNTY_REVIWER ='County Reviewer';
    public static final String DAYCAMP ='Day Camp';
    public static final string SUBMITTED = 'Submitted';
    public static final String EMPTY_STRING = '';   
    
    
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
    public override boolean getUpdateFlag()                 {   return HasUpdated;    }
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;  }
	public static Map<String, String> CLQCaseTriggerValueMap = new  Map<String, String>();
    //Calls the Base class Constructor
    public CLQ_CaseTriggerHandler_custom(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
            boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) {
            super(newlistin, newMapin, oldlistin, oldMapin,
                isExecutingin, isInsertin, isUpdatein, isDeletein,
                isBeforein, isAfterin, isUndeletein, sizein);
                BypassInheritedTrigger = BypassTrigger;
                if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
    
        for(CLQ_CaseTriggerHandler__mdt mdt : [Select label,QualifiedApiName from CLQ_CaseTriggerHandler__mdt]){
                CLQCaseTriggerValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
                
        }
        ////////////////////////////////     Boilerplate implementation  ////////////////////////////

    //Before insert logic method
    //@param : triggernew, triggernewmap
    //@return : null
    public override void beforeinsert() {
       populateAssigntoonComplaint((list < CLQ_Case_Custom__c > ) newlist, (map < id, CLQ_Case_Custom__c > ) newMap);
    }
    public override void beforeupdate() {
       if (!Validation((list <CLQ_Case_Custom__c>)  newList, (map <Id, CLQ_Case_Custom__c >) oldMap)) return;//11762
        assignOwner((list < CLQ_Case_Custom__c > ) newlist, (map < id, CLQ_Case_Custom__c > ) oldMap);
    }
    //After insert logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterinsert() {
        insertRoleonContact((list < CLQ_Case_Custom__c > ) newlist, (map < id, CLQ_Case_Custom__c > ) newMap);
            }
            
    //Added after update to copy the alleged violations from CLQ_Case_Custom__c to related inspection - 11415        
    public override void afterUpdate()
    {
        copyAllegedRuleToInsp((list < CLQ_Case_Custom__c > ) newlist, (map < id, CLQ_Case_Custom__c > ) oldMap);
    }            

    //Method to insert role  for selected contact on CLQ_Case_Custom__c
    //@param : 
    //@return :
    public void insertRoleonContact(list < CLQ_Case_Custom__c > triggernew, map < id, CLQ_Case_Custom__c > triggernewmap) {
        list < CLQ_Role__c > roleList = new list < CLQ_Role__c > (); //role list 
        map < string, CLQ_Role__c > uniqueKeyRoleMap = new map < string, CLQ_Role__c > ();
        set < id > contactIDset = new set < id > ();

        //list < Task > taskListtoinsert = new list < Task > ();
      
        //Check the below conditions to create complainant role record for contact
        //1. record type = 'Complaint'
        //2. CLQ_Anonymous_Complainant__c = false
        //3. Contact is populated
        for (CLQ_Case_Custom__c caseRecord: triggernew) {

            if (caseRecord.recordTypeID == Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId() &&
                !caseRecord.CLQ_Anonymous_Complainant__c &&
                caseRecord.ContactId__c != null) {
                CLQ_Role__c contactRole = new CLQ_Role__c();
                contactRole.CLQ_Program__c = caseRecord.CLQ_Program__c;
                contactRole.CLQ_Contact__c = caseRecord.ContactId__c;
                contactRole.RecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Program_Role').getRecordTypeId();
                if(CLQCaseTriggerValueMap.size()!=0){contactRole.CLQ_Role__c = CLQCaseTriggerValueMap.get('Complainant');}
                contactIDset.add(caseRecord.ContactId__c);
                string uniqueID = String.valueof(contactRole.CLQ_Program__c) + String.valueof(contactRole.RecordTypeID) +
                    String.valueof(contactRole.CLQ_Role__c) + String.valueof(contactRole.CLQ_Contact__c);
                uniqueKeyRoleMap.put(uniqueID,contactRole);

                //roleList.add(contactRole);
            }
            /*if (caseRecord.recordTypeID == Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByName().get('Complaint').getRecordTypeId()) {
                taskListtoinsert.add(new Task(Subject = 'Review Complaint report',
                OwnerID = caseRecord.CLQ_Assigned_To__c, Whatid = caseRecord.id)); 

            }*/
        }

        //block to ckeck if the role record already created or not
        if(contactIDset != null ){
            for (CLQ_Role__c roleRecord: [SELECT id, CLQ_Program__c, CLQ_Contact__c, CLQ_Role__c, RecordTypeID
                                        FROM CLQ_Role__c
                                        WHERE CLQ_Contact__c in: contactIDset]) {
            string uniqueID = String.valueof(roleRecord.CLQ_Program__c) + String.valueof(roleRecord.RecordTypeID) +
                String.valueof(roleRecord.CLQ_Role__c) + String.valueof(roleRecord.CLQ_Contact__c);

            if (uniqueKeyRoleMap.size()!=0 && uniqueKeyRoleMap.get(String.valueof(roleRecord.CLQ_Program__c) + String.valueof(roleRecord.RecordTypeID) +
                    String.valueof(roleRecord.CLQ_Role__c) + String.valueof(roleRecord.CLQ_Contact__c)) != null) {
                uniqueKeyRoleMap.remove(String.valueof(roleRecord.CLQ_Program__c) + String.valueof(roleRecord.RecordTypeID) +
                    String.valueof(roleRecord.CLQ_Role__c) + String.valueof(roleRecord.CLQ_Contact__c));
            }
        }

        }
        
        //insert the role record
        if(!uniqueKeyRoleMap.values().isEmpty()){
            insert uniqueKeyRoleMap.values();
        }
        //insert task for assign to user
        //insert taskListtoinsert;

    }

    //Method to populate Assign to as reviewer specialist
    //@param: trigger new and newmap
    //Return : updated triggernew
    public list < CLQ_Case_Custom__c > populateAssigntoonComplaint(list < CLQ_Case_Custom__c > triggernew, map < id, CLQ_Case_Custom__c > triggernewmap) {
        set < id > programIDSet = new set < id > ();
        list < Task > taskListtoinsert = new list < Task > ();
        
        //Fetching the assignment rules on CLQ_Case_Custom__c
        //AssignmentRule AR = new AssignmentRule();
        //AR = [select id from AssignmentRule where SobjectType = 'CLQ_Case_Custom__c' and Active = true limit 1];

        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        //Database.DMLOptions dmlOpts = new Database.DMLOptions();
        //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;

        list < CLQ_Program__c > programList = new list < CLQ_Program__c > ();
        for (CLQ_Case_Custom__c caseRecord: triggernew) {
            if (caseRecord.recordTypeID == Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId() &&
                caseRecord.CLQ_Program__c != null) {
                programIDSet.add(caseRecord.CLQ_Program__c);
            }
        }

        /*map < id, CLQ_Program__c > programmap = new map < id, CLQ_Program__c > ([SELECT id,
            CLQ_Licensing_Specialist__c FROM CLQ_Program__c WHERE id in: programIDSet]);
        for (CLQ_Case_Custom__c caseRecord: triggernew) {
            if (caseRecord.CLQ_Assigned_To__c == null && programmap.get(caseRecord.CLQ_Program__c) != null) {
                caseRecord.CLQ_Assigned_To__c = programmap.get(caseRecord.CLQ_Program__c).CLQ_Licensing_Specialist__c;
            }
		 if (caseRecord.CLQ_Assigned_To__c == null) {
                caseRecord.setOptions(dmlOpts);
            }

        }*/

        return triggernew;
    }
    
    public void assignOwner(list < CLQ_Case_Custom__c > newList, map < id, CLQ_Case_Custom__c > oldMap)
    {
        //build map of program information to be able to provide the licensing specialist later
        map < Id, CLQ_Program__c > programLicSpecialistMap = RelatedPrograms(newList);
        Id allegedOps =     Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Alleged_Ops').getRecordTypeId();
        
        //build map of county/office
        map < string, string > countyOfficeMap = new map < string, string > ();
        map < string, string > countyOfficeMapODE = new map < string, string > ();
        map < string, string > countyOfficeIDMap = new map < string, string > ();

        list < CLQ_County__c > fieldOfficesCCC = [SELECT id, name, Area_Region__c, CCC_Field_Officers__c FROM CLQ_County__c LIMIT 1999];
        for (CLQ_County__c fo: fieldOfficesCCC)
        {
            countyOfficeMap.put(fo.name, fo.CCC_Field_Officers__c);
            countyOfficeMapODE.put(fo.name, fo.Area_Region__c);
            countyOfficeIDMap.put(fo.id, fo.name);
        }

        //Build map of owner by queue developer name
        list < Group > queueMembers = [SELECT id, name, developername FROM Group WHERE type = 'queue'];
        map < string, id > allOwners = new map < string, id > ();
        map < id, string > allQueues = new map < id, string > ();

        for (Group qm: queueMembers)
        {
            allOwners.put(qm.developername, qm.id);
            allQueues.put(qm.id, qm.name);
            //system.debug('Queue value is ' + qm.id + ' ' + qm.name);
        }
        
       for (CLQ_Case_Custom__c cs: newlist)
        {
            
        //check to see if owner has changed and its a user (not a queue)
            if (oldMap.size()!=0 && allQueues.size()!=0 && cs.ownerid != oldMap.get(cs.id).ownerid)
            {
                //owner has changed, check to see if it has changed to a queue
                
                string validQueue = allQueues.get(cs.ownerid);
                if (CLQCaseTriggerValueMap.size()!=0 && validQueue == null )
                {
                    //this is a user
                    cs.CLQ_Assigned_To__c = cs.ownerid;
                    cs.CLQ_Status__c = CLQCaseTriggerValueMap.get('Under Review');
                }
                continue;
            }
           // if ( programLicSpecialistMap.size() == 0){
                //Commented by Meena - OJLS-1250
                /*if (cs.CLQ_Status__c != 'Complete'){
                    cs.CLQ_Assigned_To__c = null;                  
                }*/
                
                if ((programLicSpecialistMap.size() == 0) && (CLQCaseTriggerValueMap.size()!=0 && cs.CLQ_Status__c == CLQCaseTriggerValueMap.get(SUBMITTED) && cs.CLQ_Status__c != oldMap.get(cs.id).CLQ_Status__c))
                    {
                    if (cs.recordtypeid == allegedOps)  {
                        //Next Line Added by Meena - OJLS-1250
                        cs.CLQ_Assigned_To__c = null;
                        cs.ownerid = allOwners.get('CLQ_FCC_App_Unit' );
                        }
                    
                    }
                    
           // }
            else{
                string licReviewerFromProg ='';
                string programRecType = '';
                string progJurisdiction = ''; 
                id progCounty;
                string assignedReviewerFromProg = ''; //12073
                
                if(programLicSpecialistMap.containsKey(cs.CLQ_Program__c)){
                    licReviewerFromProg  = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Licensing_Specialist__c;
                    programRecType = programLicSpecialistMap.get(cs.CLQ_Program__c).recordtype.name;
                    progCounty = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_County__c;
                    progJurisdiction = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Jurisdiction__c;
                    assignedReviewerFromProg  = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Assigned_Reviewer__c; //12073
                }
                
 
                //12073 set to queue for day camp unless reviewer present, 13409 - Added CLQ_Case_Custom__c owner update logic for Day camps
                if(CLQCaseTriggerValueMap.size()!=0 && cs.CLQ_Status__c == CLQCaseTriggerValueMap.get(SUBMITTED) && cs.CLQ_Status__c != oldMap.get(cs.id).CLQ_Status__c && programRecType == CLQCaseTriggerValueMap.get('Day_Camp')) {
					system.debug('queue for day camp unless reviewer present ' + cs.CLQ_Status__c);
                   if (assignedReviewerFromProg == null) {
                        cs.ownerid = allOwners.get('DC_Admin');
                    }
                    else {
                        //13409 -Starts                    
                        Boolean isAssignedReviewerActive =  programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Assigned_Reviewer__r.isActive;
                        Boolean isAssignedReviewersManagerActive = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Assigned_Reviewer__r.Manager.isActive;
                        String reviewersManager = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Assigned_Reviewer__r.ManagerId ;

                        if(CLQCaseTriggerValueMap.size()!=0 && isAssignedReviewerActive){
                            cs.CLQ_Assigned_To__c = assignedReviewerFromProg;
                            cs.ownerid = assignedReviewerFromProg;
                            cs.CLQ_Status__c = CLQCaseTriggerValueMap.get('Under_Review'); 
                        }else if(CLQCaseTriggerValueMap.size()!=0 && isAssignedReviewersManagerActive){
                            cs.CLQ_Assigned_To__c = reviewersManager ;
                            cs.ownerid = reviewersManager;
                            cs.CLQ_Status__c = CLQCaseTriggerValueMap.get('Under_Review'); 
                        }else{
                            cs.CLQ_Assigned_To__c = null;                            
                            cs.ownerid = allOwners.get('DC_Admin');
                        }    
                        
                        //cs.CLQ_Assigned_To__c = assignedReviewerFromProg;
                        //cs.ownerid = assignedReviewerFromProg; 
                        //cs.CLQ_Status__c = 'Under Review';
                        //13409- ENDS
                    }
                }
 
                if (CLQCaseTriggerValueMap.size()!=0 && oldMap.size()!=0 && programRecType != DAYCAMP && cs.CLQ_Status__c == CLQCaseTriggerValueMap.get(SUBMITTED) && cs.CLQ_Status__c != oldMap.get(cs.id).CLQ_Status__c){ //12073 added not Day Camp condition
                    system.debug('submitted CLQ_Case_Custom__c here is activity type ' + cs.CLQ_Activity_Type__c);
                        
                    if (allOwners.size()!=0 && cs.CLQ_Activity_Type__c == CLQCaseTriggerValueMap.get('Enforcement')){
                        cs.ownerid = allOwners.get('CLQ_Enforcement' );
                    }else if (allOwners.size()!=0 && cs.CLQ_Activity_Type__c == CLQCaseTriggerValueMap.get('Suspension')){
                        cs.ownerid = allOwners.get('CLQ_Suspension' );
                    }else if (allOwners.size()!=0 && licReviewerFromProg == null){
                        cs.CLQ_Assigned_To__c = null;                            
                        if (countyOfficeIDMap.size()!=0 && countyOfficeMap.size()!=0 && programRecType == CLQCaseTriggerValueMap.get('Child_Care_Center')){
                            cs.ownerid = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(progCounty)));
                        }else if (countyOfficeIDMap.size()!=0 && countyOfficeMapODE.size()!=0 && progJurisdiction == CLQCaseTriggerValueMap.get('ODE')){
                            cs.ownerid = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(progCounty)));
                        }else if (countyOfficeIDMap.size()!=0 && progJurisdiction == CLQCaseTriggerValueMap.get('JFS')){
                            cs.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(progCounty));
                        }   
                   }
                   else{
                        //13409 -Starts  
                        Boolean isReviewerActive;
                       	Boolean isReviewersManagerActive;
                       String reviewersManager;
                       if(programLicSpecialistMap.size()!=0){                  
                        isReviewerActive =  programLicSpecialistMap.get(cs.CLQ_Program__c).Lic_Reviewer_IsActive__c;
                        isReviewersManagerActive = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Licensing_Specialist__r.Manager.isActive;
                        reviewersManager = programLicSpecialistMap.get(cs.CLQ_Program__c).CLQ_Licensing_Specialist__r.ManagerId ;
                       }
                       if(isReviewerActive){
                            cs.CLQ_Assigned_To__c = licReviewerFromProg;
                            cs.ownerid = licReviewerFromProg;
                            cs.CLQ_Status__c = CLQCaseTriggerValueMap.get('Under_Review'); 
                        }else if(isReviewersManagerActive){
                            cs.CLQ_Assigned_To__c = reviewersManager ;
                            cs.ownerid = reviewersManager;
                            cs.CLQ_Status__c = CLQCaseTriggerValueMap.get('Under_Review'); 
                        }else{
                            cs.CLQ_Assigned_To__c = null;                            
                            if (countyOfficeIDMap.size()!=0 && countyOfficeMap.size()!=0 && allOwners.size()!=0 && programRecType == CLQCaseTriggerValueMap.get('Child_Care_Center')){
                                cs.ownerid = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(progCounty)));
                            
                            }
                            else if (countyOfficeIDMap.size()!=0 && countyOfficeMapODE.size()!=0 && allOwners.size()!=0 && progJurisdiction == CLQCaseTriggerValueMap.get('ODE')){
                                cs.ownerid = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(progCounty)));
                           }
                            else if (countyOfficeIDMap.size()!=0 && allOwners.size()!=0 && progJurisdiction == CLQCaseTriggerValueMap.get('JFS')){
                                cs.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(progCounty));
                            }
                        }    
                            
                        //  cs.CLQ_Assigned_To__c = licReviewerFromProg;
                        //  cs.ownerid = licReviewerFromProg; 
                        
                        //cs.CLQ_Status__c = 'Under Review'; //Added for defect #10974 
                        //13409 - ENDS
                    }
                }
            }
        }
    }

    public static map < id, CLQ_Program__c > RelatedPrograms(list < CLQ_Case_Custom__c > newList){
        map < id, CLQ_Program__c > mappedPrograms;
        
        list < Id > allPrograms = new list < Id > ();
        for (CLQ_Case_Custom__c cas: newlist)
        {
            if (cas.CLQ_Program__c != null){
                allPrograms.add(cas.CLQ_Program__c);
            }
                
        }
        //12073 added CLQ_Assigned_Reviewer__c
        //13409: Added Lic_Reviewer_IsActive__c, CLQ_Licensing_Specialist__r.manager.isActive
        if(allPrograms != null){
            mappedPrograms = new map < id, CLQ_Program__c > (
            [SELECT id, Name, CLQ_Continuous_License_Status__c,
                CLQ_Accreditation_Verified__c, CLQ_Jurisdiction__c, CLQ_Licensing_Specialist__c, CLQ_Assigned_Reviewer__c, CLQ_County__c, recordtype.name,Lic_Reviewer_IsActive__c ,
                CLQ_Assigned_Reviewer__r.isActive, CLQ_Assigned_Reviewer__r.manager.isActive,
                CLQ_Licensing_Specialist__r.manager.isActive , CLQ_Street_Address_1__c, CLQ_Street_Address_2__c, CLQ_City__c, CLQ_State__c, 
                CLQ_Zip_Code__c, CLQ_Program_Email__c, CLQ_Phone__c, CLQ_Phone_Extension__c,
                CLQ_Age_Groups_Served_Global__c, CLQ_Attendance_Options_Global__c, CLQ_Services_Offered_Global__c, CLQ_Are_you_Foster_Parent__c,
                CLQ_Number_of_Residents__c, CLQ_Foster_Children__c, CLQ_Specialized_Foster_Home__c,
                CLQ_License_Registration_Status__c, CLQ_Program_Status__c
                FROM CLQ_Program__c
                WHERE id in: allPrograms
            ]);
        }
        
       return mappedPrograms;
    }
    
    //Method to copy the alleged violations from CLQ_Case_Custom__c to related inspection - 11415
    public void copyAllegedRuleToInsp(list < CLQ_Case_Custom__c > newList, map < id, CLQ_Case_Custom__c > oldMap)
    {
        try
        {
            Set<id> caseIDList = new Set<id>();
            for(CLQ_Case_Custom__c c:newList)
                caseIDList.add(c.id);
            
            //Get CLQ_Case_Custom__c with related alleged rule to copy to inspection
            Map<Id, CLQ_Case_Custom__c> caseWithAllegedRuleMap;
            if(caseIDList != null){
                caseWithAllegedRuleMap = new Map<Id, CLQ_Case_Custom__c>([Select Id, CLQ_Inspection__c, 
                                                                     (Select Id, CLQ_Domain_Rule__c, CLQ_Investigation_Details_Outcome__c, CLQ_Decision__c, CLQ_Allegation_Description__c, 
                                                                     Case_Custom__r.CLQ_Inspection__c, CLQ_Investigation_Method__c, CLQ_Result__c from Alleged_Rule_Violations__r LIMIT 1999)
                                                                     from CLQ_Case_Custom__c
                                                                     where Id in : caseIDList]);
            }
            
            //Adding inspection ID and CLQ_Case_Custom__c map to bulkify
            List<CLQ_Case_Custom__c> caseList = new List<CLQ_Case_Custom__c>();
            CLQ_Case_Custom__c oldcase = new CLQ_Case_Custom__c();
            for(CLQ_Case_Custom__c c:newList)
            {
                 if(oldMap.size()!=0 && oldMap.get(c.id) != null)
                {
                    oldcase = oldMap.get(c.id);
                    if(caseWithAllegedRuleMap.size()!=0 && c.CLQ_Inspection__c != null && (c.CLQ_Inspection__c != oldcase.CLQ_Inspection__c))
                    {
                        caseList.add(caseWithAllegedRuleMap.get(c.id));
                    }
                }       
            }
            If(!caseList.isEmpty())
            {
                createRuleInspRecFromAllegedRule(caseList);
            }
        }
        catch(Exception e)
        {
           Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_CaseTriggerHandler');             
        }    
    } 
 
    //Method to create rules inspected record in Inspection - CR 11415
    public void createRuleInspRecFromAllegedRule(List<CLQ_Case_Custom__c> caseList)
    {
        try
        {
            Set<id> insIDList = new Set<id>();
            //List<CLQ_Alleged_Rule_Violation__c> allegedRuleCaseList = new List<CLQ_Alleged_Rule_Violation__c>();  
            Map<Id, List<CLQ_Alleged_Rule_Violation__c>> caseIDAllegedMap = new Map<Id, List<CLQ_Alleged_Rule_Violation__c>>();
            for(CLQ_Case_Custom__c c:caseList)
            {
                insIDList.add(c.CLQ_Inspection__c);
                //allegedRuleCaseList = c.Alleged_Rule_Violations__r;
                if(!c.Alleged_Rule_Violations__r.isEmpty())
                {
                    caseIDAllegedMap.put(c.CLQ_Inspection__c,c.Alleged_Rule_Violations__r); 
                }
            }
            List<CLQ_Rules_Inspected__c> rulesInsListToInsert = new List<CLQ_Rules_Inspected__c>();
            List<CLQ_Rules_Inspected__c> rulesInspList = new List<CLQ_Rules_Inspected__c>();
            if(!caseIDAllegedMap.isEmpty())
            {
                rulesInspList = [Select ID, CLQ_Domain_Rule__c, CLQ_Inspection_No__c, CLQ_Alleged_Rule_Violation__c from CLQ_Rules_Inspected__c where CLQ_Inspection_No__c in:caseIDAllegedMap.keySet()];
                for(Id insID:caseIDAllegedMap.keySet())
                {
                    if(!rulesInspList.isEmpty())
                    {
                        for(CLQ_Alleged_Rule_Violation__c allegedRule:caseIDAllegedMap.get(insID))
                        {
                            Boolean domainRulePresent = false;
                            for(CLQ_Rules_Inspected__c rulesIns:rulesInspList)
                            {
                                if((allegedRule.CLQ_Domain_Rule__c == rulesIns.CLQ_Domain_Rule__c) && (allegedRule.Id == rulesIns.CLQ_Alleged_Rule_Violation__c))
                                {
                                    domainRulePresent = true;
                                }
                            }
                            If(!domainRulePresent)
                            {
                               rulesInsListToInsert.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = allegedRule.CLQ_Domain_Rule__c
                                                                            ,CLQ_Inspection_No__c = allegedRule.Case_Custom__r.CLQ_Inspection__c
                                                                            ,CLQ_Alleged_Rule_Violation__c = allegedRule.id
                                                                            ,CLQ_Allegation_Description__c = allegedRule.CLQ_Allegation_Description__c
                                                                            ,CLQ_Investigation_Method__c = allegedRule.CLQ_Investigation_Method__c
                                                                            ,CLQ_Investigation_Details_Outcome__c = allegedRule.CLQ_Investigation_Details_Outcome__c 
                                                                            ,CLQ_Result__c = allegedRule.CLQ_Result__c
                                                                            /*,CLQ_Investigation_Method__c = ruleViolationRecord.CLQ_Investigation_Method__c */));
                            }
                        }   
                    }
                    else
                    {
                        for(CLQ_Alleged_Rule_Violation__c allegedRule:caseIDAllegedMap.get(insID))
                        {
                                rulesInsListToInsert.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = allegedRule.CLQ_Domain_Rule__c
                                                                            ,CLQ_Inspection_No__c = allegedRule.Case_Custom__r.CLQ_Inspection__c
                                                                            ,CLQ_Alleged_Rule_Violation__c = allegedRule.id
                                                                            ,CLQ_Allegation_Description__c = allegedRule.CLQ_Allegation_Description__c
                                                                            ,CLQ_Investigation_Method__c = allegedRule.CLQ_Investigation_Method__c
                                                                            ,CLQ_Investigation_Details_Outcome__c = allegedRule.CLQ_Investigation_Details_Outcome__c 
                                                                            ,CLQ_Result__c = allegedRule.CLQ_Result__c
                                                                            /*,CLQ_Investigation_Method__c = ruleViolationRecord.CLQ_Investigation_Method__c */));
                        }
                    }
                }
            }
            if(!rulesInsListToInsert.isEmpty())
            {
                insert rulesInsListToInsert;
            }
        }
        catch(Exception e)
        {
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_CaseTriggerHandler'); 
        }
    }
    
    //11762 Starts
    private boolean Validation(list <CLQ_Case_Custom__c> newList, map <Id, CLQ_Case_Custom__c> oldMap){
        boolean isValidated = true;
        map <String, Set<Id>> mapApproverWithLevel = new map<string, Set<Id>>();
        Set<String> setPrgRecType = new Set<String>();
        setPrgRecType.addAll(Label.JFS_County_Program_Record_Type.split(','));
        Set<String> setCombinedCounties = new Set<String>();//12069
        
        User userRec = [SELECT Id, name, userRoleId, userRole.name FROM User WHERE Id = : UserInfo.getUserId()];
        
        //12069 starts
        if(userRec != null && userRec.userRoleId != null && userRec.userRole.name != null){
            setCombinedCounties = CLQ_UtilityClass.getCombinedCounties(userRec.userRole.name);
        }
        for (CLQ_Case_Custom__c caseObj: newList){
            
            if(!setPrgRecType.contains(caseObj.Program_Record_Type__c) && userRec != null && userRec.userRoleId <> null
                    && (userRec.userRole.name.containsIgnorecase(COUNTY_ADMIN) || userRec.userRole.name.containsIgnorecase(COUNTY_APPROVER) || userRec.userRole.name.containsIgnorecase(COUNTY_REVIWER))){
                caseObj.AddError(Label.JFS_OtherPRG_Update_Error_Message+' Cases.');
                isValidated = false;                
            }           
            //12069- added setCombinedCounties in If clause
            if(isValidated && setPrgRecType.contains(caseObj.Program_Record_Type__c) && caseObj.CLQ_Program_County__c != null && !setCombinedCounties.contains(caseObj.CLQ_Program_County__c.toUpperCase()) && 
                (userRec != null && userRec.userRoleId <> null
                && (userRec.userRole.name.containsIgnorecase(COUNTY_ADMIN) || userRec.userRole.name.containsIgnorecase(COUNTY_APPROVER) || userRec.userRole.name.containsIgnorecase(COUNTY_REVIWER)) 
                && (caseObj.CLQ_Program_County__c != null && caseObj.CLQ_Program_County__c != EMPTY_STRING && !userRec.userRole.name.containsIgnorecase(caseObj.CLQ_Program_County__c)))){//11903
                
                caseObj.AddError(Label.Update_Error_Message);
                isValidated = false;    
            }
        }
        return isValidated;
    }
    //11762 Ends      
    
    }