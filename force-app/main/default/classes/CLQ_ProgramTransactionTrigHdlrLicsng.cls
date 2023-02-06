/**************************************************************************************************************
** Name             : CLQ_ProgramTransactionTrigHdlrLicsng
** Description      : This is an TriggerHandler Class for the CLQ_Program_Transaction__c for the Licensing Team Since there has been some issues over writting other teams code,
we decided to separate this specific trigger handler and write unit testing for our specific code coverage.
Program Transaction Routing logic developed in this class.
This class is covered by 3 test classes. All the three classes have to run to get complete coverage
    1. CLQ_ProgramTransactionHdlrLcs2Test
    2. CLQ_ProgramTransactionTrigHdlrLcsTest
    3. CLQ_ProgramTransactionTrigHdlrLcs2Test
    
** Assumptions:
    1. County will be always populated for IA/Amendments Program Transactions
** Version          : 2.8
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer						Date					Version		Description
**------------------------------------------------------------------------------------------------------------
**	IncapsulateDevTeam				July-2016				1.0			Created
**	Ramana Gurivelli				May 8, 2017				1.1			CR#11159, In-Home Aide Routing 
**	Neetu Ojha						Sep 25, 2017			1.2			TFS#11491, Revise Application                 
**  Jiangl                          Oct 3, 2017             1.3			TFS#11732, handle NOCAC Admint
**  Pradeep Ravi					Oct 31, 2017			1.4			TFS#10476 - Updating the room space name from Program to PT
**	Neetu Ojha						Nov 07, 2017			1.5			TFS#11762 - Added new validation 
**	Neetu Ojha						Nov 21, 2017			1.6			TFS#11903 - Added Null check for county
**	Soufin Rahimeen					Nov 29, 2017			1.7			TFS#11827 - Added AND condition in if block check for JFS
**	Neetu Ojha						Dec 14, 2017			1.8			TFS#11925 : changed for OLD Map Parameter 
**	Soufin Rahimeen					03/27/2018				1.9			TFS#12073 DC added logic for Day Camp Application to be assigned DC Admin queue on Submitted (sr)
**  Pavan Ayta						03/27/2018				2.0			TFS#12050: Added fields in the SOQL Query
**	Neetu Ojha						03/30/2018				2.1			TFS#12051 : Added new method to remove Program	
**	Neetu Ojha						04/02/2018				2.2			TFS#12069 : Added Logic for combined counties
**	Pradeep Ravi					04/04/2018				2.2			TFS#12022 : Updating Day Camps to be approved regardless of ACA
**	Soufin Rahimeen					04/19/2018				2.3			TFS#12166 : Added logic to remove irrelevant required elements list items for Day Camp
**	Neetu Ojha						04/21/2018				2.4			TFS#12095 : Added logic for inactive reviewer
**	Neetu Ojha						05/01/2018				2.5			TFS#12181 : Don't change transaction status for locked status
**  Pradeep Ravi					05/17/2018				2.6			TFS#12214 : Copy over onsite contact role to the update program transaction
**  Pradeep Ravi					06/06/2018				2.7			TFS#12420 : Assign Day Camp closure to admin queue
**  Rahul Roy						10/09/2018				2.8			TFS#13805 : Added logic for Document Review Complete checkbox to be checked if no Transaction documents for a PT
**  Neetu Ojha						03/04/2019				2.9			TFS#15621 : Added logic to allow Delegated Approver to approve PT
**************************************************************************************************************/ 
public class CLQ_ProgramTransactionTrigHdlrLicsng
{
	
    public boolean Validation(list <CLQ_Program_Transaction__c> newList, map <Id, CLQ_Program_Transaction__c> oldMap)
    {
        boolean Validated = true;
        set < Id > AllowedNull = new set < Id > ();
        
        //11762 Starts
        map <String, Set<Id>> mapApproverWithLevel = new map<string, Set<Id>>();
        Set<String> setPrgRecType = new Set<String>();
        setPrgRecType.addAll(Label.JFS_County_Program_Record_Type.split(','));
        //11762 Ends
        Set<String> setCombinedCounties = new Set<String>();//12069
        
        AllowedNull.Add(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(
            'Registration - Out of State').getRecordTypeId());
        AllowedNull.Add(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(
            'In-Home Aide').getRecordTypeId());
        AllowedNull.Add(Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(
            'Day Camp').getRecordTypeId());

		//11762 Starts - Calling method to get all approvers only when approval in progress
		if(newList != null &&  newList.size() == 1 && oldMap != null && setPrgRecType.contains(newList[0].CLQ_Program_Record_Type__c)){			
			if(oldMap.get(newList[0].Id).CLQ_Transaction_Status__c == 'Approver Review In Progress'){
				mapApproverWithLevel = getApproverWithLevel(oldMap.get(newList[0].Id));
			}
		}
		//11762 Ends 

		User userRec = [SELECT Id, name, userRoleId, userRole.name FROM User WHERE Id = : UserInfo.getUserId()];
		
		//12069 starts
		if(userRec != null && userRec.userRoleId != null && userRec.userRole.name != null){
			setCombinedCounties = CLQ_UtilityClass.getCombinedCounties(userRec.userRole.name);
		}
		//12069 Ends
        for (CLQ_Program_Transaction__c trans: newList){
        	
        	//11762 Starts
        	if(!setPrgRecType.contains(newList[0].CLQ_Program_Record_Type__c) && userRec != null && userRec.userRoleId <> null
	        		&& (userRec.userRole.name.containsIgnorecase('County Admin') || userRec.userRole.name.containsIgnorecase('County Approver') || userRec.userRole.name.containsIgnorecase('County Reviewer'))){
        		trans.AddError(Label.JFS_OtherPRG_Update_Error_Message+' Program Transactions.');
        		Validated = false;				
			}

        	if(Validated && newList != null &&  newList.size() == 1 && oldMap != null && setPrgRecType.contains(trans.CLQ_Program_Record_Type__c)){
        		//12069- added setCombinedCounties in If clause
	        	if((trans.Program_Transaction_County__c != null && trans.Program_Transaction_County__c != '' && !setCombinedCounties.contains(trans.Program_Transaction_County__c.toUpperCase()) && 
	        		(mapApproverWithLevel.isEmpty() || mapApproverWithLevel.containsKey('Approval Step 1')) && userRec != null && userRec.userRoleId <> null
	        		&& (userRec.userRole.name.containsIgnorecase('County Admin') || userRec.userRole.name.containsIgnorecase('County Approver') || userRec.userRole.name.containsIgnorecase('County Reviewer')) 
	        		&& !userRec.userRole.name.containsIgnorecase(trans.Program_Transaction_County__c)) || 
	        		( mapApproverWithLevel.containsKey('Approval Step 2') && !mapApproverWithLevel.get('Approval Step 2').contains(UserInfo.getUserId()))){//11903
	        		
	        		trans.AddError(Label.Update_Error_Message); Validated = false;	
	        	}
        	}
        	//11762 Ends
        	
            if (Validated && trans.CLQ_Program__c == null)
            {
                trans.CLQ_Program__c.AddError('The Program is a required field for a Program Transaction');
                Validated = false;
            }
            if (Validated && trans.CLQ_Transaction_Status__c == null)
            {

                if (!AllowedNull.Contains(trans.RecordTypeId))
                {
                    trans.CLQ_Transaction_Status__c.AddError('The Transaction Status is a required field for a Program Transaction');
                    Validated = false;
                }
                else
                {
                    trans.CLQ_Transaction_Status__c = 'Not Submitted';
                }
            }
        }
        return Validated;
    }


    public void ContinuousLicenseInitiated(list<CLQ_Program_Transaction__c> newlist, string TriggerExecutionType)
    {
        //tmd added for story 234
        //get a map of all the potential programs for the prog trans to be updated in one transaction
        map < id, CLQ_Program__c > programsMap = RelatedPrograms(newList);
        Boolean isProgramUpdated = false;
        //loop through the incoming program transactions and set the cont lic status to initiated
        Id ContinuousLicenseRecordType = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get(
            'Continuous License').getRecordTypeId();

        for (CLQ_Program_Transaction__c trans: newList)
        {
            if (trans.recordTypeid == ContinuousLicenseRecordType)
            {
                system.debug('CLQ_Approved_by_Manager__c value is ' + trans.CLQ_Approved_by_Manager__c);
                system.debug('CLQ_Transaction_Status__c value is ' + trans.CLQ_Transaction_Status__c);
                CLQ_Program__c programRecord = programsMap.get(trans.CLQ_Program__c);
                if (TriggerExecutionType == 'AfterInsert')
                {
                    programRecord.CLQ_Continuous_License_Status__c = 'Initiated';
                    programsMap.put(trans.CLQ_Program__c, programRecord);
                    isProgramUpdated = true;
                }
                else if (TriggerExecutionType == 'AfterUpdate' && trans.CLQ_Approved_by_Manager__c)
                {
                    if (trans.CLQ_Recommendation__c == 'Approve'){
                        programRecord.CLQ_Continuous_License_Status__c = 'Approved';
                        programRecord.CLQ_PT_Lic_Start_Dt__c = trans.CLQ_License_Start_Date__c;}
                    else if (trans.CLQ_Recommendation__c == 'Deny'){
                        programRecord.CLQ_Continuous_License_Status__c = 'Denied';
                    }
                    else{
                        programRecord.CLQ_Continuous_License_Status__c = 'Withdrawn';
                    }
                    programsMap.put(trans.CLQ_Program__c, programRecord);isProgramUpdated = true;
                }
            }
        }
                if (programsMap != null && programsMap.size() > 0 && isProgramUpdated)
                {
                    CLQ_Trigger.BypassAllTriggers = true;
                    update programsMap.values();
                    CLQ_Trigger.BypassAllTriggers = false;
                }
                //tmd added for story 234 - end 
    }

    public void assignOwner(list < CLQ_Program_Transaction__c > newList, map < id, CLQ_Program_Transaction__c >
        oldMap, boolean isUpdate)
    {
        //tmd added for story 254 
        Id odeApp =         Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - ODE Program').getRecordTypeId();
        Id fccApp =         Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC').getRecordTypeId();
        Id cccApp =         Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - CC Center').getRecordTypeId();
        Id fccChangeLoc =   Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - FCC - Change of Location').getRecordTypeId();
        Id odeChangeLoc =   Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE - Change of Location').getRecordTypeId();
        Id cccChangeLoc =   Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - Center - Change of Location').getRecordTypeId();
        Id changeAdmin =    Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - Change of Administrator').getRecordTypeId();
        Id fccChangeCap =   Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment- FCC - Change of Capacity / Space').getRecordTypeId();
        Id odeCCCChangeCap = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE and Center - Change of Capacity / Space').getRecordTypeId();
        Id contLic =        Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Continuous License').getRecordTypeId();
        Id reactTran =      Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Reactivate Transaction').getRecordTypeId();
        Id licClose =       Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Licensing - Closure').getRecordTypeId();
        Id regOOS =         Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Registration - Out of State').getRecordTypeId();
        Id dayCamp =        Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Day Camp').getRecordTypeId();
        Id regIHA =         Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('In-Home Aide').getRecordTypeId();
        Id updAuthRep =     Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Authorized Rep Info').getRecordTypeId();
        Id updOnsiteC =     Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update On-site Contact Information').getRecordTypeId();
        Id updFCCResident = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update FCC Resident Information').getRecordTypeId();
        Id updFacilty =     Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information').getRecordTypeId();
        Id updOSInfo =      Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Outdoor Space Information').getRecordTypeId();
        Id regClose =       Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Registration Closure').getRecordTypeId();
        Id approvalClose =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Approval Closure').getRecordTypeId(); //CR 12420 Day Camp Approval Application closure
        Id dayCampApp =     Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - Day Camp').getRecordTypeId(); //12073 get day camp app
        Id dayCampRenewApp =Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Renew Application - Day Camp').getRecordTypeId(); //13554
        
        
        set < id > updatedPrograms = new set < id > ();

        //build map of program information to be able to provide the licensing specialist later
        map < Id, CLQ_Program__c > programLicSpecialistMap = RelatedPrograms(newList);

        //build map of county/office
        map < string, string > countyOfficeMap = new map < string, string > ();
        map < string, string > countyOfficeMapODE = new map < string, string > ();
        map < string, string > countyOfficeIDMap = new map < string, string > ();

        list < CLQ_County__c > fieldOfficesCCC = [SELECT id, name, Area_Region__c, CCC_Field_Officers__c FROM CLQ_County__c];
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
        Group adminQueue = null;

        for (Group qm: queueMembers)
        {
            allOwners.put(qm.developername, qm.id);
            allQueues.put(qm.id, qm.name);
            //system.debug('Queue value is ' + qm.id + ' ' + qm.name);
            //12073
            if(qm.name == 'DC - Admin') {
            	adminQueue = qm;
            }
        }
        system.debug('allQueues value is ' + allQueues);
        //check for updates to owner 
        boolean exitTrigger = false;
        if (isUpdate)
        {
            for (CLQ_Program_Transaction__c trans: newlist)
            {
                if (trans.ownerid != oldMap.get(trans.id).ownerid)
                {
                    //owner has changed, check to see if it has changed to a queue
                    exitTrigger = true;
                    string validQueue = allQueues.get(trans.ownerid);
                    system.debug('trans.ownerid value is ' + trans.ownerid);
                    if (validQueue != null && validQueue.length() > 0){trans.CLQ_Transaction_Assigned_To__c = null;//this is a queue
                        system.debug('trans.CLQ_Transaction_Assigned_To__c = ' + trans.CLQ_Transaction_Assigned_To__c);
                    }
                    else
                    {
                        //this is a user
                        system.debug('---updating reviewer---');
                        //12181 Starts
                        Set<String> setLockedTransStatus = new set<String>();
                        setLockedTransStatus.addAll(Label.Locked_Transaction_Status.split(';'));
                        
                        trans.CLQ_Transaction_Assigned_To__c = trans.ownerid;
                        if(!setLockedTransStatus.contains(trans.CLQ_Transaction_Status__c)){
                        	trans.CLQ_Transaction_Status__c = 'Under Reviewer Review';
                        }
                        //12181 Ends
                        if (trans.CLQ_Transaction_Type__c == 'Renewal' ||
                            trans.CLQ_Transaction_Type__c == 'Registration' ||
                            trans.CLQ_Transaction_Type__c == 'Update' ||
                            trans.CLQ_Transaction_Type__c == 'Initial Application' ||
                            trans.CLQ_Transaction_Type__c == 'Recertification'){  trans.CLQ_Registration_Status__c = 'Under Reviewer Review';
                        }
                    }
                }
            }
        }

        //loop through the incoming program transactions, and set the owener
        list < CLQ_Program_Transaction__c > updatedProgTrans = new list < CLQ_Program_Transaction__c > ();
        for (CLQ_Program_Transaction__c trans: newlist)
        {
            string licReviewerFromProg = null;
            String ReviewerFromProg = null;
            string assignedReviewer = null;//1180 tmd
            boolean accreditationVer;
            string programRecType = null;
            string progJurisdiction = null;
            id progCounty = null;
            id progIHAchildCounty = null; //for CR# 11159
            boolean isLicReviewerActive = false;//12095
            
            if(programLicSpecialistMap != null && programLicSpecialistMap.get(trans.CLQ_Program__c) != null){
	            accreditationVer = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_Accreditation_Verified__c;
	            licReviewerFromProg = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_Licensing_Specialist__c;     
	            isLicReviewerActive = programLicSpecialistMap.get(trans.CLQ_Program__c).Lic_Reviewer_IsActive__c;//12095     
	            assignedReviewer = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_Assigned_Reviewer__c;//1180 tmd
	            programRecType = programLicSpecialistMap.get(trans.CLQ_Program__c).recordtype.name;
	            progCounty = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_County__c;
	            progIHAchildCounty = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_County_Parent_Guardian__c; //for CR# 11159
	            progJurisdiction = programLicSpecialistMap.get(trans.CLQ_Program__c).CLQ_Jurisdiction__c;
            }
            system.debug('licReviewerFromProg ' + licReviewerFromProg);
            system.debug('licReviewerFromProgIHA ' + ReviewerFromProg);
            system.debug('isLicReviewerActive --'+isLicReviewerActive);
            system.debug('progCounty ' + progCounty);
            system.debug('programRecType ' + programRecType);
            system.debug('transaction type id: ' + Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByID().get(trans.recordtypeid).getname()); //       
            //When Transaction Status = Approved and this is a change of location transaction
            //Update Program Address fields with the New Location Address fields on the Program Transaction
            system.debug('trans status = ' + trans.CLQ_Transaction_Status__c);
            system.debug('old trans status = ' + oldMap.get(trans.id).CLQ_Transaction_Status__c);
            system.debug('reg status = ' + trans.CLQ_Registration_Status__c);
            system.debug('old reg status = ' + oldMap.get(trans.id).CLQ_Registration_Status__c);

            if (trans.CLQ_Transaction_Status__c == 'Approved' &&
                trans.CLQ_Transaction_Status__c != oldMap.get(trans.id).CLQ_Transaction_Status__c &&
                (trans.recordtypeid == cccChangeLoc || trans.recordtypeid == fccChangeLoc || trans.recordtypeid == odeChangeLoc))
            {
                //mark this program as updated so we can update the address on the program
                updatedPrograms.add(trans.CLQ_Program__c);
                updatedProgTrans.add(trans);
            }

            //When Transaction Status = Submitted, do the routing
            else
            if (trans.clq_revision_transaction_status__c == null && trans.CLQ_Transaction_Status__c == 'Submitted' && trans.CLQ_Transaction_Status__c != oldMap.get(trans.id).CLQ_Transaction_Status__c)
            {
                //*******CCC*********county office queue                
                //cccChangeLoc or changeAdmin (center ) odeCCCChangeCap
                if (trans.recordtypeid == cccChangeLoc ||
                    (trans.recordtypeid == odeCCCChangeCap && programRecType == 'Child Care Center') ||
                    (trans.recordtypeid == changeAdmin && programRecType == 'Child Care Center') ||
                    (trans.recordtypeid == contLic && programRecType == 'Child Care Center') ||
                    (trans.recordtypeid == licClose && programRecType == 'Child Care Center') ||
                    (trans.recordtypeid == updFacilty && programRecType == 'Child Care Center') ||  
                    (trans.recordtypeid == updAuthRep && programRecType == 'Child Care Center') ||
                    (trans.recordtypeid == updOnsiteC && programRecType == 'Child Care Center') ||   
                    (trans.recordtypeid == updFCCResident && programRecType == 'Child Care Center') ||                    
                    (trans.recordtypeid == updOSInfo && programRecType == 'Child Care Center') ||                                                                          
                    (trans.recordtypeid == reactTran && programRecType == 'Child Care Center'))
                {
                    //If Licensing Reviewer = NULL, route to the County Office Queue
                    if (licReviewerFromProg == null || !isLicReviewerActive)//12095
                    {
                        trans.CLQ_Transaction_Assigned_To__c = null;
                        if (trans.recordtypeid == cccChangeLoc)
                        {
                            trans.ownerid = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(trans.CLQ_New_County__c)));
                        }
                        else
                        {
                            if(progCounty == null){ trans.adderror('No county is available on the program, please update the program record with a county before pressing SUBMIT.');
                            }
                            else{
                                trans.ownerid = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(progCounty)));
                            }
                        }
                    }
                    else
                    {
                        trans.CLQ_Transaction_Assigned_To__c = licReviewerFromProg;
                        trans.ownerid = licReviewerFromProg;
                        //check to see if changeloc & the county office has changed
                        if (trans.recordtypeid == cccChangeLoc && allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(trans.CLQ_New_County__c))) !=
                            allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(progCounty))))
                        {
                            trans.CLQ_Transaction_Assigned_To__c = null;
                            trans.ownerid = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(trans.CLQ_New_County__c)));
                        }

                    }
                } //end of ccc                

                //*******ODE*********county office queue
                //odeChangeLoc, odeCCCChangeCap, reactTran(ode), contLic(ode)
                if (trans.recordtypeid == odeChangeLoc ||
                    (trans.recordtypeid == reactTran && progJurisdiction == 'ODE') ||
                    (trans.recordtypeid == contLic && progJurisdiction == 'ODE') ||
                    (trans.recordtypeid == licClose && progJurisdiction == 'ODE') ||
                    (trans.recordtypeid == updAuthRep && progJurisdiction == 'ODE') ||   
                    (trans.recordtypeid == updOnsiteC && progJurisdiction == 'ODE') ||  
                    (trans.recordtypeid == updFCCResident && progJurisdiction == 'ODE') ||  
                    (trans.recordtypeid == updFacilty && progJurisdiction == 'ODE') ||  
                    (trans.recordtypeid == updOSInfo && progJurisdiction == 'ODE') ||                                                                                                   
                    (trans.recordtypeid == odeCCCChangeCap && (programRecType == 'Pre School' || programRecType == 'School Age Child Care')))
                {
                    //If Licensing Reviewer = NULL, route to the County Office Queue

                    if (licReviewerFromProg == null || !isLicReviewerActive) //12095
                    {
                        trans.CLQ_Transaction_Assigned_To__c = null;
                        if (trans.recordtypeid == odeChangeLoc)
                        {
                            trans.ownerid = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(trans.CLQ_New_County__c)));
                        }
                        else
                        {
                            if(progCounty == null){ trans.adderror('No county is available on the program, please update the program record with a county before pressing SUBMIT.');
                            }
                            else{
                                trans.ownerid = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(progCounty)));
                            }
                        }
                    }
                    else
                    {
                        trans.CLQ_Transaction_Assigned_To__c = licReviewerFromProg;
                        trans.ownerid = licReviewerFromProg;

                        //check to see if odeChangeLoc & the county office has changed
                        if (trans.recordtypeid == odeChangeLoc && allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(trans.CLQ_New_County__c))) !=
                            allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(progCounty))))
                        {
                            trans.CLQ_Transaction_Assigned_To__c = null;
                            trans.ownerid = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(trans.CLQ_New_County__c)));
                        }

                    }
                } //end of ode

                //*******FCC*********county queue
                //fccChangeLoc, changeAdmin(FCC), fccChangeCap, reactTran(FCC), contLic(FCC)
                //11827- Updted if clause 
                if ( programRecType != 'Child Care Center' && (trans.recordtypeid == fccChangeCap || trans.recordtypeid == fccChangeLoc ||
                    (trans.recordtypeid == changeAdmin && programRecType == 'FCC - Type A Home') ||
                    (trans.recordtypeid == reactTran && progJurisdiction == 'JFS') ||
                    (trans.recordtypeid == licClose && progJurisdiction == 'JFS') ||
                    (trans.recordtypeid == updFacilty && progJurisdiction == 'JFS') || 
                    (trans.recordtypeid == updAuthRep && progJurisdiction == 'JFS') || 
                    (trans.recordtypeid == updOnsiteC && progJurisdiction == 'JFS') || 
                    (trans.recordtypeid == updFCCResident && progJurisdiction == 'JFS') || 
                    (trans.recordtypeid == updOSInfo && progJurisdiction == 'JFS') ||                                                                                 
                    (trans.recordtypeid == contLic && progJurisdiction == 'JFS')))
                {

                    //If Licensing Reviewer = NULL, route to the County Queue
                    if (licReviewerFromProg == null || !isLicReviewerActive) //12095
                    {
                        trans.CLQ_Transaction_Assigned_To__c = null;
                        if (trans.recordtypeid == fccChangeLoc)
                        {
                            trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_New_County__c));
                        }
                        else
                        {
                            if(progCounty == null){ trans.adderror('No county is available on the program, please update the program record with a county before pressing SUBMIT.');
                            }
                            else{
                                trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(progCounty));
                            }
                        }
                    }
                    else
                    {
                        trans.CLQ_Transaction_Assigned_To__c = licReviewerFromProg;
                        trans.ownerid = licReviewerFromProg;
                        //check to see if the county has changed
                        if (trans.recordtypeid == fccChangeLoc && trans.CLQ_New_County__c != progCounty)
                        {
                            trans.CLQ_Transaction_Assigned_To__c = null;
                            trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_New_County__c));
                        }
                    }
                } //end of fcc
                if (trans.CLQ_Transaction_Assigned_To__c != null 
                    && trans.recordtypeid != updFacilty 
                    && trans.recordtypeid != updAuthRep 
                    && trans.recordtypeid != updOnsiteC 
                    && trans.recordtypeid != updFCCResident 
                    && trans.recordtypeid != updOSInfo )
                {
                    trans.CLQ_Transaction_Status__c = 'Under Reviewer Review';
                }

                Id NewOwnerId = null;
                //12073 if day camp app, assign to DC - Admin queue , 13554 - Updated for day camp app renewal
                if (trans.recordtypeid == dayCampApp || trans.recordtypeid == dayCampRenewApp)
                {
                    //use county name to get approvers on map
                    //List<Group> queue = [select Id from Group where Name = 'DC - Admin' and Type = 'Queue'];
                    //NewOwnerId = queue[0].Id;
                    if(adminQueue != null) { NewOwnerId = adminQueue.Id; }
                    
                }
                //if fcc app get the approvers using the county name
                if (trans.recordtypeid == fccApp)
                {
                    //use county name to get approvers on map
                    NewOwnerId = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c));
                    system.Debug('AssignOwner: ' + NewOwnerId + '   ' + 'CLQ_' + countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c));
                }
                //if ccc app get the approvers using the county office name
                if (trans.recordtypeid == cccApp)
                {
                    //use office name to get approvers on map
                    NewOwnerId = allOwners.get('JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c)));
                    system.Debug('AssignOwner: ' + NewOwnerId + '   ' + 'JFS_CCC_' + countyOfficeMap.get(countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c)));
                }
                //if ode app get the approvers using the county office name
                if (trans.recordtypeid == odeApp)
                {
                    //use office name to get approvers on map
                    NewOwnerId = allOwners.get('ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c)));
                    system.Debug('AssignOwner: ' + NewOwnerId + '   ' + 'ODE_' + countyOfficeMapODE.get(countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c)));
                }
                
                //if registration closure get the approver or queue based on the program CLQ_Assigned_Reviewer__c field
                if (trans.recordtypeid == regClose)
                {
                //If assignedReviewer on program  = NULL, route to a Queue - 1180 tmd
                    if (assignedReviewer == null)
                    {
                        trans.CLQ_Transaction_Assigned_To__c = null;
                        if (programRecType == 'In-Home Aide' )
                        {
                            //trans.ownerid = allOwners.get('CLQ_FCC_App_Unit');
                            trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(progIHAchildCounty)); //CR# 11159
                        }
                        else if(programRecType == 'Day Camp')
                        {
                        	trans.ownerid = allOwners.get('DC_Admin');
                        }
                        else
                        {
                            trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                        }
                    }
                    else
                    {
                        trans.CLQ_Transaction_Assigned_To__c = assignedReviewer;
                        trans.ownerid = assignedReviewer;    
                        trans.CLQ_Transaction_Status__c = 'Under Reviewer Review';                    
                    }
                }//if registration closure
                
                //CR - 12420 - Assigning to DC Admin queue for Day Camp Application closure
                if (trans.recordtypeid == approvalClose)
                {
                	if(programRecType == 'Day Camp') { trans.ownerid = allOwners.get('DC_Admin');
                    }                	
                }
                
                if (NewOwnerId != null)
                    trans.ownerid = NewOwnerId;
            } //end of transaction status = submitted
            //When registration status = Submitted, do the routing..story 511
            //
            if (trans.CLQ_Registration_Status__c != '' && trans.CLQ_Registration_Status__c != null && trans.CLQ_Registration_Status__c == 'Submitted' && trans.CLQ_Registration_Status__c != oldMap.get(trans.id).CLQ_Registration_Status__c)
            {
                if (trans.recordtypeid == regOOS)
                {
                    if (trans.CLQ_Transaction_Type__c == 'Registration')
                    {
                        trans.CLQ_Transaction_Assigned_To__c = null; trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                    }
                    else
                    if (trans.CLQ_Transaction_Type__c == 'Update')
                    {
                        //mark this program so we can update the reviewer on the program later
                        if (licReviewerFromProg == null || !isLicReviewerActive)//12095
                        {
                            trans.CLQ_Transaction_Assigned_To__c = null;
                            trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                        }
                        else
                        {
                            trans.CLQ_Transaction_Assigned_To__c = licReviewerFromProg;
                            trans.ownerid = licReviewerFromProg;
                        }
                    }
                } //end OOS
                else if (trans.recordtypeid == dayCamp)
                {
                	// Updated for CR 12022 - to be approved regardless of ACA certified
                    if (trans.CLQ_Is_the_Day_Camp_ACA_Certified__c == 'No' || trans.CLQ_Is_the_Day_Camp_ACA_Certified__c == 'Yes')
                    {
                        trans.CLQ_Registration_Status__c = 'Approved';
                    }
                    if (trans.CLQ_Transaction_Type__c == 'Registration')
                    {
                        if (trans.CLQ_Is_the_Day_Camp_ACA_Certified__c == 'Yes')
                        {
                            trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                            trans.CLQ_Transaction_Assigned_To__c = null;
                        }
                    }
                    else if (trans.CLQ_Transaction_Type__c == 'Update')
                    {
                        if (trans.CLQ_Is_the_Day_Camp_ACA_Certified__c == 'Yes')
                        {
                            if (accreditationVer == false)
                            {
                                trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                                trans.CLQ_Transaction_Assigned_To__c = null;
                            }
                        }
                    }
                    else if (trans.CLQ_Transaction_Type__c == 'Renewal')
                    {
                        if (trans.CLQ_Is_the_Day_Camp_ACA_Certified__c == 'Yes')
                        {
                            if (licReviewerFromProg == null || !isLicReviewerActive)//12095
                            {
                                trans.ownerid = allOwners.get('CLQ_Application_Unit_2');
                                trans.CLQ_Transaction_Assigned_To__c = null;
                            }
                            else
                            {
                                trans.ownerid = licReviewerFromProg;
                                trans.CLQ_Transaction_Assigned_To__c = licReviewerFromProg;
                                trans.CLQ_Registration_Status__c = 'Under Reviewer Review'; //Added by MP 
                                //trans.CLQ_Transaction_Status__c = 'Under Reviewer Review'; //Commented by MP 
                            }
                        }
                    }
                } //end of day camp
                //[Ramana, 5/8/2017]: Updated IHA routing logic as per CR# 11159. Owner will be set to be the corresponding county queue.
                else if (trans.recordtypeid == regIHA)
                {
                    if (trans.CLQ_Transaction_Type__c == 'Initial Application')
                    {
                        //trans.ownerid = allOwners.get('CLQ_FCC_App_Unit');
                        trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c));
                        trans.CLQ_Transaction_Assigned_To__c = null;
                    }
                    else if (trans.CLQ_Transaction_Type__c == 'Recertification' || trans.CLQ_Transaction_Type__c == 'Update')
                    {
                        if (assignedReviewer == null)
                        {
                            trans.CLQ_Transaction_Assigned_To__c = null;
                            trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c));
                            //trans.ownerid = allOwners.get('CLQ_FCC_App_Unit');
                        }
                        else
                        {
                            if (trans.CLQ_ProgTrans_County__c == progIHAchildCounty){
                                trans.CLQ_Transaction_Assigned_To__c = assignedReviewer;
                                trans.ownerid = assignedReviewer;
                                trans.CLQ_Registration_Status__c = 'Under Reviewer Review'; //Added by MP - OJLS-1283
                                // trans.CLQ_Transaction_Status__c = 'Under Reviewer Review'; //commented by MP - OJLS-1283
                            }
                            else{
                                trans.CLQ_Transaction_Assigned_To__c = null;
                                trans.ownerid = allOwners.get('CLQ_' + countyOfficeIDMap.get(trans.CLQ_ProgTrans_County__c));
                            } 
                        }
                    }
                } //end IHA
            } //end if Registration Status
            system.Debug('assignOwner:FINAL OwnerID: ' + Trans.ownerId);
        }

        //now update the parent program address information
        if (updatedPrograms != null && updatedPrograms.size() > 0)
        {
            system.debug('updatedPrograms entries' + updatedPrograms);

            list < CLQ_Program__c > updateProgsList = new list < CLQ_Program__c > ();
            list < CLQ_Program__c > updateProgsShareList = new list < CLQ_Program__c > ();//11732
            //update address if changed
            for (CLQ_Program_Transaction__c trans: updatedProgTrans)
            {
                CLQ_Program__c prog = programLicSpecialistMap.get(trans.CLQ_Program__c);
                if (UpdateProgShare(prog, trans)) updateProgsShareList.add(prog);//11732
                if (UpdateAddress(prog, trans)) updateProgsList.add(prog);
                
            }

            if (updateProgsList.size() > 0)
            {
                system.debug('updateProgsList entries' + updateProgsList);
                CLQ_Trigger.BypassAllTriggers = true;
                update updateProgsList;
                CLQ_Trigger.BypassAllTriggers = false;
            }
            
            //11732 Starts
            system.debug('updateProgsShareList entries' + updateProgsShareList);
            if (updateProgsShareList.size() > 0){            	
            	new CLQ_ProgramTrigHdlrCountySharing().CountyAdminShare(updateProgsShareList, null); //11925
            }
            //11732 Ends    
        }

        //tmd added for story 254 - end 
    }


        //Internal Person can change everything - No Versioning required. Field History Tracking will be enabled. 
        //Editable and Versioning Required (External User)
        //  Authorized Representative Information           Role.CLQ_Role__c = 'Authorized Representative'
        //  Applicant's History on Org Role - Editable for all roles (Owners, Partners and Authorized Rep)
        //      Are you currently Licensed?                 Role.CLQ_Are_you_currently_Licensed__c
        //      Program Number                              Role.CLQ_Program_Number__c
        //      License Revoked Previously                  Role.CLQ_License_Revoked_Previously__c
        //      Certified/Licensed by another State         Role.CLQ_Certified_Licensed_by_other_state__c
        //      States                                      Role.CLQ_States__c
        //      Certified as Provider within past 5 yrs     Role.CLQ_Certified_as_Provider_within_past_5__c
        //      2. Program Number                           Role.CLQ_X2_Program_Number__c
        //      Licensed as Provider within past 5 yrs      Role.CLQ_Licensed_as_Provider_within_past5yrs__c
        //      3. Program Number                           Role.CLQ_X3_License_No__c
        //  Building Information
        //      Lead Based Paint                            ProgramTransaction.CLQ_Lead_Based_Paint__c
        //      Asbestos                                    ProgramTransaction.CLQ_Asbestos__c
        //      Radon Gas                                   ProgramTransaction.CLQ_Radon_Gas__c
        //      Level of Radon Gas                          ProgramTransaction.CLQ_Level_of_Radon_Gas__c
        //      Storage of Hazardous/Toxic Material         ProgramTransaction.CLQ_Storage_of_Hazardous_Toxic_Material__c
        //      Materials Stored in Tanks                   ProgramTransaction.CLQ_Materials_stored_in_Tanks__c
        //      Tanks currently in use                      ProgramTransaction.CLQ_Tanks_currently_in_use__c
        //      Any Problems with Tanks                     ProgramTransaction.CLQ_Any_Problems_With_Tanks__c
        //      Other Toxic Substances                      ProgramTransaction.CLQ_Other_Toxic_Substances__c
        //      Description of Other Toxic Substance        ProgramTransaction.CLQDescription_of_other_toxic_substances__c
        //  Program Information
        //      Program Mailing Address
        //          Same As Physical Address                ProgramTransaction.CLQ_Same_as_Physical_Address__c
        //          Mailing Street Address                  ProgramTransaction.CLQ_Mailing_Street_Address__c
        //          Mailing Street Address 2                ProgramTransaction.CLQ_Mailing_Street_Address_2__c
        //          Mailing City                            ProgramTransaction.CLQ_Mailing_City__c
        //          Mailing State                           ProgramTransaction.CLQ_Mailing_State__c
        //          Mailing ZipCode                         ProgramTransaction.CLQ_Mailing_ZipCode__c
        //      Program Name                                ProgramTransaction.CLQ_Previous_Program_Name__c
        //      Proposed Open Date                          ProgramTransaction.CLQ_Proposed_Open_Date__c
        //Editable but NO Versioning.
        //  Resident Information - Both related list  (Add and Delete Residents) & Section on the Program Transaction
        //      Number of Residents                         ProgramTransaction.CLQ_Number_of_Residents__c
        //      Are you a Foster Parent                     ProgramTransaction.CLQ_Are_you_a_foster_parent__c
        //      Foster Children                             ProgramTransaction.CLQ_Foster_Children__c
        //      Specialized Foster Home                     ProgramTransaction.CLQ_Specialized_Foster_Home__c
        //  Services Information  Section on the PT
        //      Services Offered                            ProgramTransaction.CLQ_Services_Offered_Global__c
        //      Age Groups Served                           ProgramTransaction.CLQ_Age_Groups_Served_Global__c
        //      Full/Part-Time Options                      ProgramTransaction.CLQ_Full_Part_Time_Options_Global__c
        //      Attendance Options                          ProgramTransaction.CLQ_Attendance_Options_Global__c
        //      Provider Agreement                          ProgramTransaction.CLQ_Provider_Agreement__c
        //      Liability Insurance                         ProgramTransaction.CLQ_Liability_Insurance__c
        //  Facility Schedule Related List - Add, Edit and Delete
        //              All are allowed without versioning, so these can be ignored
        //Not Editable after Submission
        //  Owner Information - Can edit Phone and Email, but NO Versioning
        //  Partner Information - Can edit Phone and Email, but NO Versioning)
        //  Program Physical Address 
        //  Program Information - Can edit Phone and Email, but NO Versioning
        //Editable Till Inspection Launch
        //  Room/Space Information - Can edit till Inspection is launched. After inspection is launched cannot edit.  NO Versioning. 
        //              Need to add trigger to stop editing if an inspection exists.

    // InterceptUpdateAndClone - The purpose of this method is to create a backup snapshot of an Application if the
    //                          Application has been submitted, and the application is updated by the external user,
    //                          or certain fields are modified by an internal user.
    //
    public list < CLQ_Program_Transaction__c > InterceptUpdateAndClone(List < CLQ_Program_Transaction__c > newList, map < Id, CLQ_Program_Transaction__c > oldMap){
        list < CLQ_Program_Transaction__c > Insertlist = new list < CLQ_Program_Transaction__c > ();
        
        //Internal Person can change everything - No Versioning required. Field History Tracking will be enabled.
        system.Debug('InterceptUpdateAndClone:UserInfo: ' + UserInfo.getUserType() + '  ' + UserInfo.getUserName());
        if (UserInfo.getUserType() == 'Standard' && !Global_Settings__c.getInstance().RunTriggerAsPortal__c) //Internal User
            return Insertlist;
		Id dcAppRecordTypeId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - Day Camp').getRecordTypeId();
        for (CLQ_Program_Transaction__c Program_Transaction: newlist)
        {
            CLQ_Program_Transaction__c OldProgramTransaction = OldMap.get(Program_Transaction.Id);
            system.debug('OldStartApproval: ' + OldProgramTransaction.CLQ_Start_Approval__c);
            system.debug('NewStartApproval: ' + Program_Transaction.CLQ_Start_Approval__c);
            boolean StartApproval = Program_Transaction.CLQ_Start_Approval__c;
            system.debug('StartApproval: ' + StartApproval);
            boolean BrandNew = Program_Transaction.CreatedDate >= DateTime.Now().AddSeconds(-2);
            if (BrandNew || StartApproval || Program_Transaction.CLQ_Transaction_Status__c == 'Not Submitted' || 
            		(Program_Transaction.CLQ_Transaction_Status__c == 'Revision In Progress' && !Program_Transaction.Is_Revision_InProgress__c)) continue; //11491

            if (ApplicationRecordTypes.containsKey(Program_Transaction.RecordTypeId))
            {
                if (Program_Transaction.CLQ_Transaction_Status__c == 'Cancelled') 
                    CLQ_CloneUtility.CancelRevision(Program_Transaction);
                else
                {
                   // system.debug('******ShouldBackup 1'+ ShouldBackup); 
					
                    boolean ShouldBackup = ShouldBackup(Program_Transaction, OldProgramTransaction);
                    system.debug('******ShouldBackup 2'+ ShouldBackup); 
                    if (ShouldBackup)
                    {
                        system.debug('******ShouldBackup 3'+ ShouldBackup); 
                        CLQ_Program_Transaction__c BackupProgramTransaction = CLQ_CloneUtility.CloneProgramTransaction(OldProgramTransaction, null, null);
                        if (BackupProgramTransaction != null)
                        {
                            system.debug('******ShouldBackup 4'+ ShouldBackup); 
                            //if (((UserInfo.getUserType() != 'Standard' || Global_Settings__c.getInstance().RunTriggerAsPortal__c) && OldProgramTransaction.CLQ_External_User_Can_Edit__c)){
							if (UserInfo.getUserType() != 'Standard' || Global_Settings__c.getInstance().RunTriggerAsPortal__c){ //11491                            	
                                system.debug('******ShouldBackup 5'+ ShouldBackup); 
                                BackupProgramTransaction.CLQ_Revision_Field_Changes__c = string.join(new list < string > (ModifiedFields), ',');
                                //An update by the external user will Set this version to 'Not Submitted'
                                Program_Transaction.CLQ_Revision_Transaction_Status__c = Program_Transaction.CLQ_Transaction_Status__c;
                                //11491 Starts
                                Program_Transaction.CLQ_Transaction_Status__c = 'Revision In Progress';
                                //Program_Transaction.CLQ_Transaction_Status__c = 'Not Submitted'; 
                                //11491 Ends
                                system.debug('New cloned Program_Transaction: ' + BackupProgramTransaction.CLQ_Revision_Related_Records__c);
                                insertlist.add(BackupProgramTransaction);
                            }
                        }
                    }
                    
                    //11491 Starts - To update Transaction status to Revision in progress without versioning
                    if(!ShouldBackup && !(system.isFuture() || system.isBatch() || system.isScheduled()) 
                		&& OldProgramTransaction.CLQ_External_User_Can_Edit__c
                    	&& (UserInfo.getUserType() != 'Standard' || Global_Settings__c.getInstance().RunTriggerAsPortal__c)){
	                    Boolean isUpdatedWithoutVersioning = false;
						set<string> setSkipFields = new set<string>{'id', 'isdeleted', 'name', 'createdby', 'lastmodifiedby','recordtypeid','createddate', 'lastmodifieddate', 'createdbyid', 'lastmodifiedbyid',
	        															'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate', 'ownerid', 'submission_date1__c','is_revision_inprogress__c'} ;
	    				if(!isUpdatedWithoutVersioning){
	    					map<string, Schema.SObjectField> ptFieldMap = Schema.sObjectType.CLQ_Program_Transaction__c.fields.getmap();
		        			for(string strFldName : ptFieldMap.KeySet()){
		            			if (!setSkipFields.contains(strFldName.toLowerCase())){
		                			Schema.DescribeFieldResult dfr = ptFieldMap.get(strFldName).getDescribe();
									if (dfr.isUpdateable() && (Program_Transaction.get(strFldName) != OldProgramTransaction.get(strFldName))){
										system.debug('strFldName ---- '+strFldName);
										isUpdatedWithoutVersioning = true;
										break;
									}
		            			}
		        			}
	    				}
	        			system.debug('isUpdatedWithoutVersioning ---- '+isUpdatedWithoutVersioning);
	        			        															                    
	                    if(isUpdatedWithoutVersioning){
							Program_Transaction.CLQ_Revision_Transaction_Status__c = Program_Transaction.CLQ_Transaction_Status__c;
							Program_Transaction.CLQ_Transaction_Status__c = 'Revision In Progress';   
							Program_Transaction.Is_Revision_InProgress__c = true;                 	
	                    }
                    }
                    //11491 Ends
                }
            }
        }
        return insertlist;
    }

    private set < string > ModifiedFields;

    private static set < string > AllowedToModify = new set < string >
    {
        'Submitted',
        'Under Reviewer Review',
        'Resubmitted',
        'Returned for Revision'
    };
    public boolean ShouldBackup(CLQ_Program_Transaction__c NewRecord, CLQ_Program_Transaction__c OldRecord)
    {
        system.debug('OldRecord.CLQ_Transaction_Status__c: ' + OldRecord.CLQ_Transaction_Status__c);
        system.debug('NewRecord.CLQ_Transaction_Status__c: ' + NewRecord.CLQ_Transaction_Status__c);
        
        if (OldRecord.CLQ_Transaction_Status__c == 'Not Submitted' || (OldRecord.CLQ_Transaction_Status__c == 'Revision In Progress' && !OldRecord.Is_Revision_InProgress__c) ) return false; //11491
        ModifiedFields = AllowedToModifyCertainFieldsWithoutVersioning(NewRecord, OldRecord);

        if (OldRecord.CLQ_External_User_Can_Edit__c || OldRecord.Is_Revision_InProgress__c || Test.isRunningTest()){
			if (ModifiedFields.size() == 0){
            	return false; //No reason to make a backup version
            }

            System.debug('1Modified Fields:'+ModifiedFields);    
            Global_Settings__c GlobalSettings = Global_Settings__c.getInstance();
            if (string.IsNotBlank(GlobalSettings.AllowedEditWithVersioning__c)) AllowedEditWithVersioning.AddAll(GlobalSettings.AllowedEditWithVersioning__c.replace(' ','').split(','));
            ModifiedFields.removeAll(AllowedEditWithVersioning);
            System.debug('1Modified Fields:'+ModifiedFields);
            if (ModifiedFields.size() == 0) 
                return true; //Some fields were modified that require versioning
            else
            {
                System.debug('WARNING this should throw an EXCEPTION: ' + ModifiedFields + '  have been changed and are not allowed.');
                if(!test.isRunningTest())
                throw new OCLQS_Exception('Some values were modified that are not allowed: ' + ModifiedFields);
            }
        }
        else
            throw new OCLQS_Exception('An external user cannot modify an Application in a status of: ' + OldRecord.CLQ_Transaction_Status__c);
        //Should never get here
        return false;
    }

    private static set < string > AllowedEditWithoutVer = new set < string >
    {
        //      Number of Residents                         
        'CLQ_Number_of_Residents__c',
        //      Are you a Foster Parent                     
        'CLQ_Are_you_a_foster_parent__c',
        //      Foster Children                             
        'CLQ_Foster_Children__c',
        //      Specialized Foster Home                     
        'CLQ_Specialized_Foster_Home__c',
        //  Services Information  Section on the PT
        //      Services Offered                            
        'CLQ_Services_Offered_Global__c',
        //      Age Groups Served                           
        'CLQ_Age_Groups_Served_Global__c',
        //      Full/Part-Time Options                      
        'CLQ_Full_Part_Time_Options_Global__c',
        //      Attendance Options                          
        'CLQ_Attendance_Options_Global__c',
        //      Provider Agreement                          
        'CLQ_Provider_Agreement__c',
        //      Liability Insurance                         
        'CLQ_Liability_Insurance__c',
        //This one is modified by triggers
        'CLQ_Reviewer_Missing_Elements__c',
        'CLQ_Old_Transaction_Status__c',
        'CLQ_Portal_Application_Update__c',
        'PGFConfigId__c',
        'SectionNumber__c',
        'CLQ_Fee_Paid__c',
        'CLQ_Form_Complete_Not_Paid__c',
        'Submission_Date1__c',
        'SectionNumber__c',
        'PGFConfigId__c'
    };
    private static set < string > AllowedEditWithVersioning = new set < string >
    {
        //  Building Information
        //      Lead Based Paint                            
        'CLQ_Lead_Based_Paint__c',
        //      Asbestos                                    
        'CLQ_Asbestos__c',
        //      Radon Gas                                   
        'CLQ_Radon_Gas__c',
        //      Level of Radon Gas                          
        'CLQ_Level_of_Radon_Gas__c',
        //      Storage of Hazardous/Toxic Material         
        'CLQ_Storage_of_Hazardous_Toxic_Material__c',
        //      Materials Stored in Tanks                   
        'CLQ_Materials_stored_in_Tanks__c',
        //      Tanks currently in use                      
        'CLQ_Tanks_currently_in_use__c',
        //      Any Problems with Tanks                     
        'CLQ_Any_Problems_With_Tanks__c',
        //      Other Toxic Substances                      
        'CLQ_Other_Toxic_Substances__c',
        //      Description of Other Toxic Substance        
        'CLQDescription_of_other_toxic_substances__c',
        //  Program Information
        //      Program Mailing Address
        //          Same As Physical Address                
        'CLQ_Same_as_Physical_Address__c',
        //          Mailing Street Address                  
        'CLQ_Mailing_Street_Address__c',
        //          Mailing Street Address 2                
        'CLQ_Mailing_Street_Address_2__c',
        //          Mailing City                            
        'CLQ_Mailing_City__c',
        //          Mailing State                           
        'CLQ_Mailing_State__c',
        //          Mailing ZipCode                         
        'CLQ_Mailing_ZipCode__c',
        //      Program Name                                
        'CLQ_Previous_Program_Name__c',
        //      Proposed Open Date                          
        'CLQ_Proposed_Open_Date__c',
        // Mod by LD on 1/3/17 -- fix for OJLS-1181
        'CLQ_Calculated_Max_Capacity_Under_2_5Yr__c', 
        'CLQ_Calculated_Maximum_Capacity__c', 
        'CLQ_Requested_Calculated_Max_Capacity__c', 
        'CLQ_Requested_Calculated_Max_Under_2_1_2__c',
         //Mod by VS--Fix OJLS-1085
         'CLQ_Estimated_Enrollment__c',
         'CLQ_Total_No_of_Rooms_In_Use__c',
         'CLQ_Total_No_of_Staff__c',
         'CLQ_Part_Day_Option_Offered__c',
         'CLQ_Full_Day_Option_Offered__c',
         'CLQ_Submitter__c',
         'CLQ_ProgTrans_Program_Email_Address__c',
         'CLQ_ProgTrans_Phone__c',
         'CLQ_ProgTrans_Phone_Extension__c'         
    };    
        
    public set < string > AllowedToModifyCertainFieldsWithoutVersioning(CLQ_Program_Transaction__c NewRecord, CLQ_Program_Transaction__c OldRecord)
    {
        string Status = OldRecord.CLQ_Transaction_Status__c;
        set < string > ModifiedFields = CLQ_CloneUtility.FindModifiedFields(NewRecord, OldRecord);
        system.Debug('Complete List of modified fields: ' + string.join(new list < string > (ModifiedFields), ','));
        Global_Settings__c GlobalSettings = Global_Settings__c.getInstance();
        if (string.IsNotBlank(GlobalSettings.AllowedEditWithoutVer__c)) AllowedEditWithoutVer.AddAll(GlobalSettings.AllowedEditWithoutVer__c.replace(' ','').split(','));{
        	ModifiedFields.RemoveAll(AllowedEditWithoutVer);
        }
        return ModifiedFields;
    }

    //Updates the Program 
    public list < CLQ_Program__c > UpdateProgramFacility(List < CLQ_Program_Transaction__c > newList, map < Id, CLQ_Program_Transaction__c > oldMap)
    {
        Id RecordTypesFacilityId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information').getRecordTypeId();
        Id RecordTypesResidentId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update FCC Resident Information').getRecordTypeId();

        map < id, CLQ_Program__c > PgrMap = RelatedPrograms(newList);

        list < CLQ_Program__c > UpdatedPrograms = new list < CLQ_Program__c > ();

        for (CLQ_Program_Transaction__c Program_Transaction: newlist)
        {

            CLQ_Program_Transaction__c OldTransaction = oldMap.get(Program_Transaction.Id);

            if (Program_Transaction.CLQ_Transaction_Status__c == 'Submitted' && OldTransaction.CLQ_Transaction_Status__c != 'Submitted')
            {
                CLQ_Program__c Program = PgrMap.get(Program_Transaction.CLQ_Program__c);

                if (RecordTypesFacilityId == Program_Transaction.RecordTypeId)
                {
                    Program.CLQ_Age_Groups_Served_Global__c= Program_Transaction.CLQ_Age_Groups_Served_Global__c;
                    Program.CLQ_Attendance_Options_Global__c= Program_Transaction.CLQ_Attendance_Options_Global__c;
                    Program.CLQ_Services_Offered_Global__c = Program_Transaction.CLQ_Services_Offered_Global__c;
                    UpdatedPrograms.Add(Program);
                }
                else if (RecordTypesResidentId == Program_Transaction.RecordTypeId)
                {
                    Program.CLQ_Number_of_Residents__c = Program_Transaction.CLQ_Number_of_Residents__c;
                    Program.CLQ_Are_you_Foster_Parent__c = Program_Transaction.CLQ_Are_you_a_foster_parent__c;
                    Program.CLQ_Foster_Children__c = Program_Transaction.CLQ_Foster_Children__c;
                    Program.CLQ_Specialized_Foster_Home__c = Program_Transaction.CLQ_Specialized_Foster_Home__c;
                    UpdatedPrograms.Add(Program);
                }

            }
            //if(OldTransaction.CLQ_Transaction_Status__c){

            //}
        }
        if (UpdatedPrograms.size() > 0)
        {
            system.debug('UpdatedPrograms entries' + UpdatedPrograms);
            CLQ_Trigger.BypassAllTriggers = true;
            update UpdatedPrograms;
            CLQ_Trigger.BypassAllTriggers = false;
        }
        return UpdatedPrograms;
    }
	
	//11732 Starts
    public boolean UpdateProgShare(CLQ_Program__c Program, CLQ_Program_Transaction__c ProgramTransaction)
    {
        boolean ProgramShareUpdated = false;
        System.debug('Program.CLQ_County__c==>' + Program.CLQ_County__c);
        System.debug('ProgramTransaction.CLQ_New_County__c==>' + ProgramTransaction.CLQ_New_County__c);
        if (Program.CLQ_County__c != ProgramTransaction.CLQ_New_County__c)
        {            
            ProgramShareUpdated = true;
        }	
        System.debug('ProgramShareUpdated==>' + ProgramShareUpdated);
        return ProgramShareUpdated;
    }
    //11732 Ends
    
    public boolean UpdateAddress(CLQ_Program__c Program, CLQ_Program_Transaction__c ProgramTransaction)
    {
        boolean ProgramUpdated = false;
        if (Program.CLQ_Street_Address_1__c != ProgramTransaction.CLQ_New_Street_Address_1__c)
        {
            system.debug('Updating Address 1');
            Program.CLQ_Street_Address_1__c = ProgramTransaction.CLQ_New_Street_Address_1__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_Street_Address_2__c != ProgramTransaction.CLQ_New_Street_Address_2__c)
        {
            Program.CLQ_Street_Address_2__c = ProgramTransaction.CLQ_New_Street_Address_2__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_State__c != ProgramTransaction.CLQ_New_State__c)
        {
            Program.CLQ_State__c = ProgramTransaction.CLQ_New_State__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_Zip_Code__c != ProgramTransaction.CLQ_New_Zip_Code__c)
        {
            Program.CLQ_Zip_Code__c = ProgramTransaction.CLQ_New_Zip_Code__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_Program_Email__c != ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c)
        {
            Program.CLQ_Program_Email__c = ProgramTransaction.CLQ_ProgTrans_Program_Email_Address__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_Phone_Extension__c != ProgramTransaction.CLQ_New_Phone_Extension__c)
        {
            Program.CLQ_Phone_Extension__c = ProgramTransaction.CLQ_New_Phone_Extension__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_Phone__c != ProgramTransaction.CLQ_New_Phone_Number__c)
        {
            Program.CLQ_Phone__c = ProgramTransaction.CLQ_New_Phone_Number__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_County__c != ProgramTransaction.CLQ_New_County__c)
        {
            Program.CLQ_County__c = ProgramTransaction.CLQ_New_County__c;
            ProgramUpdated = true;
        }
        if (Program.CLQ_City__c != ProgramTransaction.CLQ_New_City__c)
        {
            Program.CLQ_City__c = ProgramTransaction.CLQ_New_City__c;
            ProgramUpdated = true;
        }
        return ProgramUpdated;
    }
    
    public static final list < string > pendingAmendmentStatus = new list < string >
    {
        'Not Submitted',
        'In Progress',
        'Submitted',
        'Returned for Revision',
        'Resubmitted'
    };
    

    //Purpose: To make sure that multiple amendments of the same type can't be submitted at the same time.
    //          And to make sure only the correct person can edit this at any specific time.
    //A program cannot submit two amendments of the same type at the same time.
    public void CannotSubmitAnotherAmendment(list < CLQ_Program_Transaction__c > newList, map < Id, CLQ_Program_Transaction__c > oldMap, string TriggerExecutionType)
    {
        //An amendment cannot be created if one of the same type is already pending.
        //This is saying that only the transaction owner = transaction assigned to person can edit the amendment
        //      this transaction assigned to user is a reviewer.
        //External user CAN edit amendment when transaction status = Not Submitted
        //Once Transaction Status = Approved OR Withdraw OR Denied - no one except sys admin will be able to edit
        //When Transaction Status = Approver Review in Progress, only a person with Approver Profile can edit the amendment

        system.Debug('CannotSubmitAnotherAmendment');

        list < Id > ProgramIDs = new list < Id > ();
        for (CLQ_Program_Transaction__c ProgTransaction: newList)
        {
            if (AmendmentRecordTypes.containsKey(ProgTransaction.RecordTypeId))
            {
                if (ProgTransaction.CLQ_Program__c != null) ProgramIDs.Add(ProgTransaction.CLQ_Program__c);
            }
        }
        //Quick out if no Amendments
        //system.Debug('CannotSubmitAnotherAmendment:Number of Programs: ' + ProgramIDs.size());
        if (ProgramIDs.size() == 0) return;
        map < Id, CLQ_Program__c > ProgramMap = RelatedPrograms(newList);

        list < CLQ_Program_Transaction__c > ExistingItems = [Select Id, CLQ_Program__c, CLQ_Transaction_Status__c, RecordType.Name, RecordTypeId
            FROM CLQ_Program_Transaction__c
            WHERE CLQ_Transaction_Status__c IN: pendingAmendmentStatus
            AND CLQ_Program__c in: ProgramIDs
            AND RecordTypeId IN: AmendmentRecordTypes.keySet()
        ];

        //Create a list of approvers
        set < Id > ApproverList = new Set < Id > ();
        // initializing list instance to include all the ids of the respective queue [Prakriti Biswas Bug# 11019]
        set < Id > queueList = new Set < Id > (); 
        set < Id > SystemAdminList = new Set < Id > ();
        set < Id > SystemAdminApproverList = new Set < Id > ();
		Boolean isDelegatedApprover = false; //15621
        if (TriggerExecutionType == 'BeforeUpdate')
        {
            SystemAdminList = new map < Id, Profile > ([SELECT Id FROM Profile WHERE Name LIKE '%Admin%']).keySet();
            SystemAdminApproverList = new map < Id, Profile > ([SELECT Id FROM Profile WHERE Name LIKE '%Admin%'
                OR Name LIKE '%Approver%'
            ]).keySet();
			
			//15621 Starts
			if(!isDelegatedApprover){
				for(User user : [Select Id from User where DelegatedApproverId =: UserInfo.getUserId()]){
					isDelegatedApprover = true;
					break;
				}
			}
			//15621 Ends
			
            List < ProcessInstance > processList = [SELECT Id, TargetObject.Name, TargetObjectID, Status, LastModifiedDate,
                (SELECT Id, Actor.id, Actor.Name FROM WorkItems)
                FROM ProcessInstance
                WHERE TargetObjectID IN: oldMap.keySet()
                AND(Status = 'Pending'
                    OR Status = 'Approved')
                ORDER BY LastModifiedDate desc
            ];
            //checking approval process is there or not for this pt
            System.debug('proList' + processList);
            for (ProcessInstance ProcessInst: processList)
            {
                //fetching latest processInstance
                //System.debug('ProcessInstance record' + ProcessInst);
                //fetching current approver FROM workitems
                for (ProcessInstanceWorkitem Workitem: ProcessInst.WorkItems)
                {
                	//checking for all users[Prakriti Biswas-Bug#11019]
                	if(String.valueOf(Workitem.ActorId).substring(0, 3) == '005'){
                	
                    //assign next approver to field in PT
                    ApproverList.Add(Workitem.ActorId);
                    }
                	
                   //checking for members in queue [Prakriti Biswas Bug#11019]
                    else if(String.valueOf(Workitem.ActorId).substring(0, 3) == '00G'){
                    	queueList.Add(Workitem.ActorId);
                    	}
                    } 
            }
            System.debug('queueList' + queueList);
            if(!queueList.isEmpty()){
	            //Query to fetch all users who are members of the specified queue [Prakriti Biswas Bug#11019]
	            for(GroupMember gmObj : [Select UserOrGroupId From GroupMember where GroupId in: queueList]){
	            	if(String.valueOf(gmObj.UserOrGroupId).subString(0,3) == '005'){
	            		ApproverList.Add(gmObj.UserOrGroupId);
	            	}
	            }
            }
           System.debug('ApproverList' + ApproverList); 
        }
        system.Debug('CannotSubmitAnotherAmendment:Number of ExistingItems: ' + ExistingItems.size());
        map < string, CLQ_Program_Transaction__c > ExistingMap = new map < string, CLQ_Program_Transaction__c > ();
        for (CLQ_Program_Transaction__c ExistingProgTransaction: ExistingItems)
        {
            string Key = string.valueOf(ExistingProgTransaction.CLQ_Program__c) + string.valueOf(ExistingProgTransaction.RecordTypeId);
            ExistingMap.put(Key, ExistingProgTransaction);
        }


        set < string > NotAllowedProgramStatus = new set < string > //12197 removed closed --> added closed back
        {
            'Pending',
            'Denied',
            'Closed'
        };
        set < string > OwnerCanEdit = new set < string >
        {
            'Not Submitted',
            'Returned to Reviewer',
            'Under Reviewer Review',
            'Submitted',
            'Resubmitted',
            'Return for Revision'
        };
    User usr=[Select id,Profile.name from User where id =:Userinfo.getUserid()];
        String usrpro=usr.Profile.Name;

        for (CLQ_Program_Transaction__c ProgTransaction: newList)
        {
            if (AmendmentRecordTypes.containsKey(ProgTransaction.RecordTypeId))
            {
                string AmendmentType = AmendmentRecordTypes.get(ProgTransaction.RecordTypeId);
                AmendmentType = AmendmentType.subString(AmendmentType.lastIndexOf('-') + 1).trim();

                if (TriggerExecutionType == 'BeforeInsert' && ProgTransaction.CLQ_Program__c != null)
                {
                    //system.Debug('CannotSubmitAnotherAmendment:BeforeInsert:AmendmentType ' + AmendmentType);
                    CLQ_Program__c Program = ProgramMap.get(ProgTransaction.CLQ_Program__c);
                    //system.Debug('CannotSubmitAnotherAmendment:BeforeInsert:Program Status ' + Program.CLQ_Program_Status__c);
                    if (Program.CLQ_Program_Status__c != null && NotAllowedProgramStatus.contains(Program.CLQ_Program_Status__c))
                        ProgTransaction.AddError('The program has a license status of ‘Closed’, ’Denied’ or ‘Pending’, and is not ' +
                            'eligible to request a ' + AmendmentType);
                    //system.Debug('CannotSubmitAnotherAmendment:BeforeInsert:ExistingMap Keys ' + ExistingMap.keySet());
                    string Key = string.valueOf(ProgTransaction.CLQ_Program__c) + string.valueOf(ProgTransaction.RecordTypeId);
                    //system.Debug('CannotSubmitAnotherAmendment:BeforeInsert:Looking for Key  ' + Key);
                    if (ExistingMap.containsKey(Key))
                    {
                        CLQ_Program_Transaction__c ExistingProgTransaction = ExistingMap.get(Key);
                        //system.Debug('CannotSubmitAnotherAmendment:BeforeInsert:ExistingProgTransaction ' + ExistingProgTransaction.CLQ_Transaction_Status__c);
                        if (ExistingProgTransaction.CLQ_Transaction_Status__c == 'Not Submitted')
                            ProgTransaction.AddError('A ' + AmendmentType + ' Request already exists for this program and has not been ' +
                                'submitted. Please SELECT the existing request FROM the Amendment Activities Screen, ' +
                                'then edit and submit the existing request');
                        else
                            ProgTransaction.AddError('A ' + AmendmentType + ' request was submitted for this program and is currently ' +
                                'being reviewed. If you need to change or withdraw the request, please contact your ' +
                                'specialist.');
                    }
                }
                else if (TriggerExecutionType == 'BeforeUpdate')
                {
                    boolean IsAdminOrApprover = SystemAdminApproverList.contains(UserInfo.getProfileId());
                    CLQ_Program_Transaction__c OldItem = oldMap.get(ProgTransaction.Id);
                    system.Debug('CannotSubmitAnotherAmendment:BeforeUpdate:Old Transaction_Status ' + OldItem.CLQ_Transaction_Status__c+'>>'+ProgTransaction.CLQ_Transaction_Status__c );
                    system.Debug('CannotSubmitAnotherAmendment:BeforeUpdate:Old Transaction RecordType ' + OldItem.RecordTypeId);
                    //system.Debug('CannotSubmitAnotherAmendment:BeforeUpdate:Old Transaction RecordType ' + OldItem.RecordTyp);
                  
                    if (!(OldItem.CLQ_Transaction_Status__c == 'Not Submitted' || OldItem.CLQ_Transaction_Status__c == 'Returned for Revision') && !(usrpro.containsignorecase('Customer Community'))){ // modified the logic VS
                    Id CurrUserId = UserInfo.getUserId();
                    /*if (UserInfo.getUserType() != 'Standard' || Global_Settings__c.getInstance().RunTriggerAsPortal__c) //External User
                    {

                        ProgTransaction.AddError('This ' + AmendmentType + ' request was submitted for this program and is currently ' +
                            'being reviewed. If you need to change or withdraw the request, please contact your ' +
                            'specialist.');
                    }
                    else*/ 
	                    //Checking whether current user belongs to Approver List[Prakriti Biswas #Bug#11019 ]
	                    if ((OldItem.OwnerId == CurrUserId && OwnerCanEdit.Contains(OldItem.CLQ_Transaction_Status__c)) || IsAdminOrApprover || ApproverList.Contains(CurrUserId) || isDelegatedApprover) //15621
                    {
                        //No error message
                    }
                    else if (OldItem.OwnerId == CurrUserId && !OwnerCanEdit.Contains(OldItem.CLQ_Transaction_Status__c) && !IsAdminOrApprover && !isDelegatedApprover) //15621
                    {
                        ProgTransaction.AddError('This ' + AmendmentType + ' request is in ' + OldItem.CLQ_Transaction_Status__c +
                            ' status. If you need to change or withdraw the request, please contact the approver ' +
                            ' or the System Administrator.');
                    }
                    else if (OldItem.CLQ_Transaction_Status__c == 'Approver Review in Progress' && !ApproverList.Contains(CurrUserId) && !IsAdminOrApprover && !isDelegatedApprover) //15621
                    {
                        ProgTransaction.AddError('This ' + AmendmentType + ' request is in Approver Review in Progress' +
                            ' status and can only be modified by an approver. If you need to change or withdraw the request, please contact the approver ' +
                            ' or the System Administrator.');
                    }
                    else if (!SystemAdminList.contains(UserInfo.getProfileId()))
                    {
                        ProgTransaction.AddError('This ' + AmendmentType + ' request is in ' + OldItem.CLQ_Transaction_Status__c +
                            ' status. This can only be modified by the System Administrator.');
                    }
                    }
                }
            }
        }

    }

    //Purpose: to prefill the related list 
    public void AfterInsert(list < CLQ_Program_Transaction__c > newList)
    {
        map < Id, CLQ_Program__c > ProgramMap = RelatedPrograms(newList);
        map < Id, CLQ_Role__c > RoleMap = RelatedRoles(newList);
        map < Id, Task > TaskMap = RelatedTasks(newList);
        map < Id, CLQ_Facility_Schedule__c > FacilityScheduleMap = RelatedFacilitySchedules(newList);
        
        CLQ_ProgramTransactionTrigHdlrLicsng2 ChangesOnUpdateAndCreate = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap,RoleMap,TaskMap, FacilityScheduleMap);
        //Get the list of records to repoint to this Transaction
        for (CLQ_Program_Transaction__c Program_Transaction: newList)
        {
            ChangesOnUpdateAndCreate.ChangesAfterInsert(Program_Transaction ); 
        }

        
        CLQ_Trigger.BypassAllTriggers = true;
        if (ChangesOnUpdateAndCreate.ProgramsToUpsert.Size() > 0)  upsert new list<CLQ_Program__c>(ChangesOnUpdateAndCreate.ProgramsToUpsert);
        if (ChangesOnUpdateAndCreate.RolesToUpsert.Size() > 0)  upsert new list<CLQ_Role__c>(ChangesOnUpdateAndCreate.RolesToUpsert);
            system.debug('****** ChangesOnUpdateAndCreate.RolesToUpsert ****'+ChangesOnUpdateAndCreate.RolesToUpsert);
        if (ChangesOnUpdateAndCreate.TasksToUpsert.Size() > 0)  upsert new list<Task>(ChangesOnUpdateAndCreate.TasksToUpsert);
        if (ChangesOnUpdateAndCreate.Facility_ScheduleToUpsert.Size() > 0)  upsert new list<CLQ_Facility_Schedule__c>(ChangesOnUpdateAndCreate.Facility_ScheduleToUpsert);
                              
        CLQ_Trigger.BypassAllTriggers = false;
    }

    //Purpose: Set values on the PT when necessary
    public void BeforeUpdate(list < CLQ_Program_Transaction__c > newList, map<Id, CLQ_Program_Transaction__c> oldMap)
    {

        map < Id, CLQ_Program__c > ProgramMap = RelatedPrograms(newList);
        map < Id, CLQ_Program_Transaction__c > RelatedMap = RelatedItems(newList);
        set<id> programTransactionIDset = new set<id>();
        map<id,CLQ_Role__c> roleMap = new map<id,CLQ_Role__c>();
        map<id,CLQ_Transaction_Document__c> tansactionDocumentMap = new map<id,CLQ_Transaction_Document__c>();
        CLQ_ProgramTransactionTrigHdlrLicsng2 ChangesOnUpdateAndCreate = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap,null,null, null, RelatedMap);
        //Get the list of records to repoint to this Transaction
        for (CLQ_Program_Transaction__c Program_Transaction: newList)
        {
            CLQ_Program_Transaction__c OldRecord = oldMap.get(Program_Transaction.Id);
            ChangesOnUpdateAndCreate.ChangesBeforeUpdate(Program_Transaction, OldRecord );
            if(Program_Transaction.CLQ_Recommendation__c != (oldMap.get(Program_Transaction.Id)).CLQ_Recommendation__c){
            programTransactionIDset.add(Program_Transaction.Id); 
            } 
        }
        //Added logic to update the flag on PT
        if(programTransactionIDset.size()>0){
            tansactionDocumentMap = new Map<ID, CLQ_Transaction_Document__c>([SELECT Id,CLQ_Program_Transaction__c FROM CLQ_Transaction_Document__c WHERE CLQ_Program_Transaction__c in :programTransactionIDset]);
            roleMap = new Map<ID, CLQ_Role__c>([SELECT Id,Name, CLQ_Status__c, CLQ_Decision__c,CLQ_Program_Transaction_Source__c FROM CLQ_Role__c WHERE CLQ_Program_Transaction_Source__c in :programTransactionIDset]);
            CLQ_RoleTriggerHandler roleHandler = new CLQ_RoleTriggerHandler(null, null, null,null,
                                    false, false, false, false,false, false,false, 200);
            CLQ_TransactionDocumentTriggerHandler transdocHandler = new CLQ_TransactionDocumentTriggerHandler(null, null, null,null,
                                    false, false, false, false,false, false,false, 200);
            list<CLQ_Program_Transaction__c> updateprogramTransactionList = new list<CLQ_Program_Transaction__c>();
            list<CLQ_Program_Transaction__c> updateprogramTransactionListFromRole = new list<CLQ_Program_Transaction__c>();
            if(roleHandler.UpdateAdminReviewOnPT(roleMap,newList) != null){
                updateprogramTransactionListFromRole = roleHandler.UpdateAdminReviewOnPT(roleMap,newList);
                for(CLQ_Program_Transaction__c ptRecord : updateprogramTransactionListFromRole ){
                    for(CLQ_Program_Transaction__c newrecord: newList){
                        if(ptRecord.id == newrecord.id){
                            newrecord.CLQ_Administrator_Review_Complete__c = ptRecord.CLQ_Administrator_Review_Complete__c ;
                        }
                    }
                }
            }
            if(transdocHandler.UpdateDocumentReviewOnPT(tansactionDocumentMap,newList) != null){
                updateprogramTransactionList = transdocHandler.UpdateDocumentReviewOnPT(tansactionDocumentMap,newList);
                for(CLQ_Program_Transaction__c ptRecord : updateprogramTransactionList){
                    for(CLQ_Program_Transaction__c newrecord: newList){
                    if(ptRecord.id == newrecord.id){
                        newrecord.CLQ_Document_Review_Complete__c  = ptRecord.CLQ_Document_Review_Complete__c ;
                    }
                    }
                }
            }
        }
    }

    //Purpose: to prefill the related list 
    public void AfterUpdate(list < CLQ_Program_Transaction__c > newList, map<Id, CLQ_Program_Transaction__c> oldMap)
    {	
        system.debug('==afterupdate enter=====>');
        map < Id, CLQ_Program__c > ProgramMap = RelatedPrograms(newList);
        map < Id, CLQ_Role__c > RoleMap = RelatedRoles(newList);
        map < Id, Task > TaskMap = RelatedTasks(newList);
        map < Id, CLQ_Facility_Schedule__c > FacilityScheduleMap = RelatedFacilitySchedules(newList);
        //set<id> programTransactionIDset = new set<id>();
        //map<id,CLQ_Transaction_Document__c> tansactionDocumentMap = new map<id,CLQ_Transaction_Document__c>();
        CLQ_ProgramTransactionTrigHdlrLicsng2 ChangesOnUpdateAndCreate = new CLQ_ProgramTransactionTrigHdlrLicsng2(ProgramMap,RoleMap,TaskMap, FacilityScheduleMap);
        //Get the list of records to repoint to this Transaction
        for (CLQ_Program_Transaction__c Program_Transaction: newList)
        {
            CLQ_Program_Transaction__c OldRecord = oldMap.get(Program_Transaction.Id);
            ChangesOnUpdateAndCreate.ChangesAfterUpdate(Program_Transaction,OldRecord );
            //if(Program_Transaction.CLQ_Recommendation__c != (oldMap.get(Program_Transaction.Id)).CLQ_Recommendation__c){
            //programTransactionIDset.add(Program_Transaction.Id); 
            //}
        }
        //Added logic to update the flag on PT
        /*if(programTransactionIDset.size()>0){
            tansactionDocumentMap = new Map<ID, CLQ_Transaction_Document__c>([SELECT Id,CLQ_Program_Transaction__c FROM CLQ_Transaction_Document__c WHERE CLQ_Program_Transaction__c in :programTransactionIDset]);
            CLQ_TransactionDocumentTriggerHandler transdocHandler = new CLQ_TransactionDocumentTriggerHandler(null, null, null,null,
                                    false, false, false, false,false, false,false, 200);
            if(checkRecursive.runOnce()){transdocHandler.UpdateDocumentReviewOnPT(tansactionDocumentMap,newList);}                        
            
        }*/
        
        
        CLQ_Trigger.BypassAllTriggers = true;
        if (ChangesOnUpdateAndCreate.ProgramsToUpsert.Size() > 0) 
            upsert new list<CLQ_Program__c>(ChangesOnUpdateAndCreate.ProgramsToUpsert);
        if (ChangesOnUpdateAndCreate.RolesToUpsert.Size() > 0) 
        {
            //Trigger may creat new tasks.
            for(CLQ_Role__c role : ChangesOnUpdateAndCreate.RolesToUpsert)
            {
                system.Debug('Updating a role for ' + role.Name + '  With a status of ' + role.CLQ_Status__c + '  Update Role ' + role.CLQ_Update_Role__c);
            }
            upsert new list<CLQ_Role__c>(ChangesOnUpdateAndCreate.RolesToUpsert);
        }
        if (ChangesOnUpdateAndCreate.TasksToUpsert.Size() > 0) 
        {
            //Trigger may creat new tasks.
            for(Task tsk : ChangesOnUpdateAndCreate.TasksToUpsert)
            {
                if (tsk.Id == null)
                    system.Debug('Adding a new task for ' + tsk.subject);
                else
                    system.Debug('Updating a task for ' + tsk.subject + '  With a status of ' + tsk.Status);
                mappedTasks.put(tsk.Id, tsk);
            }
            upsert new list<Task>(ChangesOnUpdateAndCreate.TasksToUpsert);
        }
        if (ChangesOnUpdateAndCreate.Facility_ScheduleToUpsert.Size() > 0) 
            upsert new list<CLQ_Facility_Schedule__c>(ChangesOnUpdateAndCreate.Facility_ScheduleToUpsert);
                       
        CLQ_Trigger.BypassAllTriggers = false;
    }

    //Method to copy Room/Space information records to Room/Space Transaction records while creating PT records
    //@param: trigger.new list
    //@return: none
    //Author: Vrajesh Sheth (vsheth@incapsulate.com)
    public void copyRoomSpaceInformationWhileCreatingPT(list < CLQ_Program_Transaction__c > newList)
    {
        set < String > recordTypeSet = new set < String >
        {
            'Update Outdoor Space Information',
            'Amendment - ODE and Center - Change of Capacity / Space',
            'Amendment- FCC - Change of Capacity / Space'
        };
        set < id > programIDSet = new set < id > ();
        map < id, id > programTransactionProgramIdMap = new map < id, id > ();
        for (CLQ_Program_Transaction__c programTransactionRecord: newList)
        {
            String recordTypeName='';
                if(programTransactionRecord.RecordtypeID!=null){
            	 recordTypeName = CLQ_Program_Transaction__c.SObjectType.getDescribe().getRecordTypeInfosById().get(programTransactionRecord.RecordtypeID)
                .getName();
                }
            if (recordTypeSet.contains(recordTypeName) && recordTypeName!='')
            {
                programIDSet.add(programTransactionRecord.CLQ_Program__c);
                programTransactionProgramIdMap.put(programTransactionRecord.id, programTransactionRecord.CLQ_Program__c);
            }
        }

        //Get all Room/Space information record into one list
        list < CLQ_Room_Space__c > roomSpaceInformation = new list < CLQ_Room_Space__c > ();
        list < CLQ_Room_Space_Transaction__c > roomSpaceTransactiontoInsert = new list < CLQ_Room_Space_Transaction__c > ();
        map < ID, Schema.RecordTypeInfo > rt_Map = CLQ_Room_Space__c.sObjectType.getDescribe().getRecordTypeInfosById();
        roomSpaceInformation = Database.Query(CLQ_UtilityClass.createSOQLQuery('CLQ_Room_Space__c', 'CLQ_Program__c in :programIDSet', null));
        //Clone the record in Room/Space Transaction object
        for (CLQ_Program_Transaction__c programTransactionRecord: newList)
        {
            for (CLQ_Room_Space__c roompsacerecord: roomSpaceInformation)
            {
                if (programTransactionRecord.CLQ_Program__c == roompsacerecord.CLQ_Program__c)
                {
                    CLQ_Room_Space_Transaction__c newrecord = (CLQ_Room_Space_Transaction__c) CLQ_UtilityClass.cloneFromOneObjectToanother(roompsacerecord,
                        'CLQ_Room_Space_Transaction__c');
                    newrecord.CLQ_Program_Transaction__c = programTransactionRecord.id;
                    Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByName().get(rt_map.get(roompsacerecord.recordTypeID)
                        .getName()).getRecordTypeId();
                    newrecord.recordTypeID = devRecordTypeId;
                    newrecord.CLQ_XExisting_Room__c=true;
                    //Updated Record name for 10476 in addition to updating the owner
                    newrecord.Name = roompsacerecord.Name;
                    roomSpaceTransactiontoInsert.add(newrecord);
                }
            }
        }

        if (roomSpaceTransactiontoInsert.size() > 0) { insert roomSpaceTransactiontoInsert; }

    }

    //OJLS-675/User story 2637 : Added by Santosh M Reddy // Mod by Latha Davuluri 
    public void ReadyforApprovalCheck(list < CLQ_Program_Transaction__c > newList)
    {

        Set < Id > ParentIdSet = new Set < Id > ();
        integer LinkedInspectionListCheck;
        String DisplayReviewerMessage = '';
       
        Map < ID, Schema.RecordTypeInfo > RTMap = CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();

        for (CLQ_Program_Transaction__c pt: newList)
        {
            ParentIdSet.add(pt.Id);
        }
        
        List<CLQ_Transaction_Document__c> transDocList = new List<CLQ_Transaction_Document__c>([SELECT id, name, CLQ_Program_Transaction__c, CLQ_Document_Status__c FROM CLQ_Transaction_Document__c WHERE CLQ_Program_Transaction__c IN:ParentIdSet AND ((CLQ_Document_Status__c = 'Approved' OR CLQ_Document_Status__c = 'Denied') OR CLQ_Document_Status__c = 'Attached' )]);//13805
        
        List <CLQ_Role__c > roleList = RelatedRoles(newList).values();
        
        for (CLQ_Program_Transaction__c pt: newList)
        {
        	//12166 check for day camp app or App renewal , 13554
        	Boolean isDayCampApp = false;
        	if(pt.clq_recordtypename__c == 'Application - Day Camp' || pt.clq_recordtypename__c == 'Renew Application - Day Camp' ) {
        		isDayCampApp = true;
        	}
        	System.debug('isDayCampApp-->>>'+isDayCampApp);
            System.debug('Sri>>>'+pt.CLQ_Recommendation__c);
            if (pt.CLQ_Transaction_Status__c == 'Under Reviewer Review' || pt.CLQ_Transaction_Status__c == 'Submitted' || pt.CLQ_Transaction_Status__c == 'Returned to Reviewer')
            {
                // Keep the DisplayReviewerMessage EMPTY if the Recommendation is Deny
                if (pt.CLQ_Recommendation__c == 'Deny'){
                     DisplayReviewerMessage = '';
                    pt.CLQ_Reviewer_Missing_Elements__c = DisplayReviewerMessage;
                }
                //12166 if it is DayCampApp then we only need the recommendation 
                else if(isDayCampApp) {
                	if (pt.CLQ_Recommendation__c == null){
                		DisplayReviewerMessage += '.Recommendation Missing\n';
                		pt.CLQ_Reviewer_Missing_Elements__c = DisplayReviewerMessage;
                	} //this logic might exist elsewhere
                	else if (pt.CLQ_Recommendation__c == 'Approve'){
                		DisplayReviewerMessage = '';
                    	pt.CLQ_Reviewer_Missing_Elements__c = DisplayReviewerMessage;
                	}
                		
                }
                else {
                    if (pt.CLQ_Recommendation__c == null && RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location') || RTMap.get(pt.recordTypeId)
                        .getName().containsIgnoreCase('Application') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Capacity / Space'))
                    {
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application'))
                        {
                            if (pt.CLQ_License_Start_Date__c == null)
                                DisplayReviewerMessage += '.License Start Date Missing\n';
                        }
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location'))
                        {
                            if (pt.CLQ_Approved_Last_Day_at_Current_Address__c == null)
                                DisplayReviewerMessage += '.Missing Approved Last Date Of Operation\n';
                            if (pt.CLQ_Approved_First_Day_at_New_Address__c == null)
                                DisplayReviewerMessage += '.Missing Approved First Date of Operation\n';
                        }
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Capacity / Space'))
                        {
                            if (pt.CLQ_New_Approved_All_Groups_Capacity__c == null)
                                DisplayReviewerMessage += '.Missing New Approved Total Capacity\n';
                        }
                        else
                        {
                            //if (pt.CLQ_Approved_Total_Capacity__c == null)
                                //DisplayReviewerMessage += '.Missing Approved Total Capacity\n';
                        }
                        if (pt.CLQ_New_Approved_Under_2_Capacity__c == null && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'FCC - Change of Capacity / Space')))
                            DisplayReviewerMessage += '.Missing New Approved Total Capacity Under 2\n';
    
                        if (pt.CLQ_New_Approved_Capacity_Under_2_1_2__c == null && !(RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'FCC - Change of Capacity / Space')) && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application') && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location'))
                            DisplayReviewerMessage += '.Missing New Approved Total Capacity Under 2 1/2\n';
    
                        if (pt.CLQ_Approved_Capacity_Under_2__c == null && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'Amendment - FCC - Change of Location') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application - FCC')))
                            DisplayReviewerMessage += '.Missing Approved Total Capacity Under 2\n';
                        /*if (pt.CLQ_Approved_Capacity_Under_2_1_2__c == null && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'Amendment - FCC - Change of Location') && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application - FCC') && !
                            RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Capacity / Space'))
                            //DisplayReviewerMessage += '.Missing Approved Total Capacity Under 2 1/2\n';*/
                         if (pt.CLQ_Recommendation__c == null)
                            DisplayReviewerMessage += '.Recommendation Missing\n';
                    }
                    else if (pt.CLQ_Recommendation__c != null && (pt.CLQ_Recommendation__c == 'Approve' && RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Location') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application')))
                    {
    
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application'))
                        {
                            if (pt.CLQ_License_Start_Date__c == null) DisplayReviewerMessage += '.License Start Date Missing\n';
                        }
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location'))
                        {
                            if (pt.CLQ_Approved_Last_Day_at_Current_Address__c == null)
                                DisplayReviewerMessage += '.Missing Approved Last Date Of Operation\n';
                            if (pt.CLQ_Approved_First_Day_at_New_Address__c == null)
                                DisplayReviewerMessage += '.Missing Approved First Date of Operation\n';
                        }
                        //if (pt.CLQ_Approved_Total_Capacity__c == null)
                            //DisplayReviewerMessage += '.Missing Approved Total Capacity\n';
                        if (pt.CLQ_Approved_Capacity_Under_2__c == null && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'Amendment - FCC - Change of Location') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application - FCC')))
                            DisplayReviewerMessage += '.Missing Approved Total Capacity Under 2\n';
                        /*if (pt.CLQ_Approved_Capacity_Under_2_1_2__c == null && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'Amendment - FCC - Change of Location') && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application - FCC'))
                            //DisplayReviewerMessage += '.Missing Approved Total Capacity Under 2 1/2\n';*/
       
                    }
                    else if (pt.CLQ_Recommendation__c != null && pt.CLQ_Recommendation__c != 'Approve' && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Location') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application')))
                    {
    
                        if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application'))
                        {
                            if (pt.CLQ_License_Start_Date__c == null)
                                DisplayReviewerMessage += '.License Start Date Missing\n';
                        }               
                    }
                    else if (pt.CLQ_Recommendation__c != null && pt.CLQ_Recommendation__c == 'Approve' && RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Capacity / Space'))
                    {
    
                        if (pt.CLQ_New_Approved_All_Groups_Capacity__c == null)
                            DisplayReviewerMessage += '.Missing New Approved Total Capacity\n';
                        if (pt.CLQ_New_Approved_Under_2_Capacity__c == null && RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'Amendment- FCC - Change of Capacity / Space'))
                            DisplayReviewerMessage += '.Missing New Approved Total Capacity Under 2\n';
                        if (pt.CLQ_New_Approved_Capacity_Under_2_1_2__c == null && !(RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                                'FCC - Change of Capacity / Space')) && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application') && !RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location'))
                            DisplayReviewerMessage += '.Missing New Approved Total Capacity Under 2 1/2\n';
    
                    }
                    else if (pt.CLQ_Recommendation__c != null && pt.CLQ_Recommendation__c != 'Approve' && RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Capacity / Space'))
                    {
    
                        // do something
                    }
                    //Change of Administrator
                    if (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Administrator'))
                    {
                        if (pt.CLQ_Recommendation__c == null)
                        {
                            DisplayReviewerMessage += '.Recommendation Missing\n';
                        }
                    }               
    
                    pt.CLQ_Reviewer_Missing_Elements__c = DisplayReviewerMessage;
                    
                }

                if (String.isBlank(pt.CLQ_Reviewer_Missing_Elements__c) && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Location') ||
                        RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Administrator')|| RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Capacity / Space')))
                    pt.CLQ_Ready_for_Approval__c = true;
                else if (String.isNotBlank(pt.CLQ_Reviewer_Missing_Elements__c) && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase(
                            'Change of Location') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Application') || RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Administrator') || RTMap.get(pt.recordTypeId).getName()
                        .containsIgnoreCase('Change of Capacity / Space')))
                    pt.CLQ_Ready_for_Approval__c = false;
            }
          
             //Check Document Review Complete checkbox - based on OJLS-1171
            if(transDocList.size() == 0 && (RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Change of Capacity / Space')|| RTMap.get(pt.recordTypeId).getName().containsIgnoreCase('Amendment - Change of Administrator')))//13805
               pt.CLQ_Document_Review_Complete__c = true;
        
             /* commented out based on OJLS-1011    
                //Check Administrator Review Complete checkbox  
                if(roleList.size() == 0)  
                  pt.CLQ_Administrator_Review_Complete__c = true;
             */
             if(roleList.size() > 0) {
                if (pt.CLQ_Recommendation__c == 'Deny'){
                    for(CLQ_Role__c r: roleList){
                        if (r.CLQ_Decision__c == 'Approved') pt.CLQ_Recommendation__c.AddError('Recommendation cannot be Denied, if alteast one Administrator has been approved.');
                    }
                }
             }
             
         } // end for
    }
    
    public static map < Id, string > ApplicationRecordTypes
    {
        get
        {
            if (ApplicationRecordTypes == null)
            {
                ApplicationRecordTypes = new map < Id, string > ();
                Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - ODE Program');
                ApplicationRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - CC Center');
                ApplicationRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Application - FCC');
                ApplicationRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
            }
            return ApplicationRecordTypes;

        }
        private set;
    }
    public static map < Id, string > AmendmentRecordTypes
    {
        get
        {
            if (AmendmentRecordTypes == null)
            {
                AmendmentRecordTypes = new map < Id, string > ();
                Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - Center - Change of Location');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - Change of Administrator');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - FCC - Change of Location');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE - Change of Location');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment - ODE and Center - Change of Capacity / Space');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Amendment- FCC - Change of Capacity / Space');
                AmendmentRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());

            }
            return AmendmentRecordTypes;

        }
        private set;
    }
    public static map < Id, string > UpdateRecordTypes
    {
        get
        {
            if (UpdateRecordTypes == null)
            {
                UpdateRecordTypes = new map < Id, string > ();
                Schema.RecordTypeInfo RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information');
                UpdateRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update On-site Contact Information');
                UpdateRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
                RecTypInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update FCC Resident Information');
                UpdateRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
            }
            return UpdateRecordTypes;

        }
        private set;
    }
    public static map < Id, string > AllRecordTypes
    {
        get
        {
            if (AllRecordTypes == null)
            {
                AllRecordTypes = new map < Id, string > ();
                Map < ID, Schema.RecordTypeInfo > RTMap = CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
                for (Schema.RecordTypeInfo RecTypInfo : RTMap.values())
                    AllRecordTypes.put(RecTypInfo.getRecordTypeId(), RecTypInfo.getName());
            }
            return AllRecordTypes;

        }
        private set;
    }

    public static map < id, CLQ_Program__c > mappedPrograms;
    public static map < id, CLQ_Program__c > RelatedPrograms(list < CLQ_Program_Transaction__c > newList)
    {
        if (mappedPrograms == null)
        {
            list < Id > allPrograms = new list < Id > ();
            for (CLQ_Program_Transaction__c trans: newlist)
            {
                if (trans.CLQ_Program__c != null)
                    allPrograms.add(trans.CLQ_Program__c);
            }
            //1180 tmd
            
            mappedPrograms = new map < id, CLQ_Program__c > (
                [SELECT id, Name, CLQ_Assigned_Reviewer__c, CLQ_Continuous_License_Status__c,CLQ_License_Type__c,CLQ_Continuous_License_Begin_Date__c,CLQ_License_Issue_Date__c,
                    CLQ_Accreditation_Verified__c, CLQ_Jurisdiction__c, CLQ_Licensing_Specialist__c, CLQ_County__c, CLQ_County_Parent_Guardian__c, recordtype.name,
                    CLQ_Street_Address_1__c, CLQ_Street_Address_2__c, CLQ_City__c, CLQ_State__c,
                    CLQ_Zip_Code__c, CLQ_Program_Email__c, CLQ_Phone__c, CLQ_Phone_Extension__c,
                    CLQ_Age_Groups_Served_Global__c, CLQ_Attendance_Options_Global__c, CLQ_Services_Offered_Global__c, CLQ_Are_you_Foster_Parent__c,
                    CLQ_Number_of_Residents__c, CLQ_Foster_Children__c, CLQ_Specialized_Foster_Home__c,
                    CLQ_License_Registration_Status__c, CLQ_Program_Status__c,Lic_Reviewer_IsActive__c,
                    (Select Id, CLQ_Program_Transaction__c, CLQ_Status__c,CLQ_Transaction_Status_Check__c,OwnerId, CLQ_Days_of_Operation__c,Months_of_Operation__c,
                     CLQ_HOO_Time_1_Start__c, CLQ_HOO_Time_1_End__c, CLQ_HOO_Time_2_Start__c, CLQ_HOO_Time_2_End__c, name From Facility_Schedules__r LIMIT 100 ), //PA 12050
                    (Select Id, CLQ_Program_Transaction_Source__c, CLQ_Role__c,CLQ_Status__c, RecordTypeId, RecordType.Name,CLQ_Transaction_Status_Check__c,
                     CLQ_Update_Role__c, CLQ_Contact__c,CLQ_Start_Date__c,CLQ_End_Date__c //12051
                     From Roles__r LIMIT 100)
                    FROM CLQ_Program__c
                    WHERE id in: allPrograms
                ]);//12095
        }
        return mappedPrograms;
    }
    
    public static map < id, Task > mappedTasks;
    public static map < id, Task > RelatedTasks(list < CLQ_Program_Transaction__c > newList)
    {
        //Because this creates and removes tasks, this is required to query each time
        if (mappedTasks == null)
        {
            list < Id > allTransactions = new list < Id > ();
            for (CLQ_Program_Transaction__c trans: newlist) allTransactions.Add(trans.Id);

            mappedTasks = new map < id, Task > (
                [Select WhoId, WhatId, TaskSubtype, Subject, Status, ReminderDateTime, Priority, 
                Owner.ProfileId, Owner.UserRoleId, Owner.Email, Owner.Username, Owner.Id, OwnerId, 
                IsClosed, IsArchived, Id, Description, CLQ_WhatType__c, CLQ_Program__c, CLQ_External_ID__c, 
                CLQ_Event_Status__c, CLQ_Event_Start_Date__c, CLQ_Event_End_Date__c, CLQ_Event_Duration__c, 
                CLQ_Event_Duration_Calc__c, ActivityDate, AccountId 
                From Task
                WHERE WhatId in: allTransactions
                AND IsClosed = false
                AND Status != 'Completed']
                );
        }
        return mappedTasks;
    }    
    
    public static map < id, CLQ_Role__c > mappedRoles;
    public static map < id, CLQ_Role__c > RelatedRoles(list < CLQ_Program_Transaction__c > newList)
    {
        if (mappedRoles == null)
        {
            list < Id > allTransactions = new list < Id > ();
            for (CLQ_Program_Transaction__c trans: newlist) allTransactions.Add(trans.Id);
            mappedRoles = new map <Id, CLQ_Role__c> (
                    [SELECT Id, Name, CLQ_Status__c, CLQ_Decision__c, CLQ_Contact__c, CLQ_Role__c, RecordType.Name,
                    CLQ_Transaction_Status_Check__c,CLQ_Update_Role__c,CLQ_Program_Transaction_Source__c, CLQ_Program__c,
                    Role_Type__c, Portal_Roles__c
                    FROM CLQ_Role__c 
                    WHERE CLQ_Program_Transaction_Source__c IN :allTransactions 
                    AND CLQ_Decision__c != null]
                    );        
        }
        return mappedRoles;
    }
    
    public static map < id, CLQ_Facility_Schedule__c > mappedFacilitySchedules;
    public static map < id, CLQ_Facility_Schedule__c > RelatedFacilitySchedules(list < CLQ_Program_Transaction__c > newList)
    {
        if (mappedFacilitySchedules == null)
        {
            list < Id > allTransactions = new list < Id > ();
            //Id prgId;
            for (CLQ_Program_Transaction__c trans: newlist){
                allTransactions.Add(trans.Id);
                //prgId = trans.CLQ_Program__c;
            } 
            
            //List<CLQ_Program_Transaction__c> oldPT = [SELECT Id FROM CLQ_Program_Transaction__c WHERE CLQ_Program__c =: prgId Order by CreatedDate Desc];
            //Id oldPTId = oldPT[1].Id;
            mappedFacilitySchedules = new map <Id, CLQ_Facility_Schedule__c> (
                    [SELECT Id, CLQ_Program_Transaction__c,CLQ_Program__c, CLQ_Status__c,CLQ_Transaction_Status_Check__c, OwnerId, CLQ_Days_of_Operation__c,Months_of_Operation__c,
                     CLQ_HOO_Time_1_Start__c, CLQ_HOO_Time_1_End__c, CLQ_HOO_Time_2_Start__c, CLQ_HOO_Time_2_End__c, name
                    FROM CLQ_Facility_Schedule__c //PA 12050
                    WHERE CLQ_Program_Transaction__c IN :allTransactions]
                    );        
        }
        return mappedFacilitySchedules;
    }    
    
    public static map < id, CLQ_Program_Transaction__c > mappedRelatedItems;
    public static map < id, CLQ_Program_Transaction__c > RelatedItems(list < CLQ_Program_Transaction__c > newList)
    {
        if (mappedRelatedItems == null)
        {
            mappedRelatedItems = new map < id, CLQ_Program_Transaction__c > (
                [SELECT id, Name, CLQ_Transaction_Assigned_To__c, CLQ_Transaction_Assigned_To__r.Email
                    FROM CLQ_Program_Transaction__c
                    WHERE id in: newList
                ]);
        }
        return mappedRelatedItems;
    }    
    
   	//11762 Starts - Method to get all approvers and admins
   @TestVisible
    private Map<String, set<Id>> getApproverWithLevel(CLQ_Program_Transaction__c pTrans){
    	map <String, Set<Id>> mapApproverWithLevel = new map<string, Set<Id>>();
    	Set<Id> setApproverId = new Set<Id>();
		Set<Id> setQueueId = new Set<Id>();
		Set<String> setApproverRole = new Set<String>();
		String approvalLvl = '';
		setApproverRole.addAll(Label.Transaction_Approval_Role.split(',')); 
		system.debug('pTrans --- '+pTrans.Id);
		
		for(ProcessInstance piObj: [SELECT Id, TargetObjectID,(SELECT Id, Actor.id, Actor.Name FROM WorkItems), (SELECT ProcessNodeName  from Nodes order by createddate desc limit 1) 
										FROM ProcessInstance WHERE TargetObjectID =: pTrans.Id ORDER BY LastModifiedDate desc limit 1]){
			system.debug(' Process Instance ---'+piObj.TargetObjectID);									
			for(ProcessInstanceWorkitem wiObj: piObj.WorkItems){
				if(string.valueOf(wiObj.ActorId).substring(0,3) == '005'){
					setApproverId.add(wiObj.ActorId);
				}else if(string.valueOf(wiObj.ActorId).substring(0,3) == '00G'){
					setQueueId.add(wiObj.ActorId);					
				}
			}
			for(ProcessInstanceNode pinObj : piObj.Nodes){
				approvalLvl = pinObj.ProcessNodeName;
			}
		}
		system.debug('QueList --- ' +setQueueId);
		
		//Adding queue members in approver list
		if(!setQueueId.isEmpty()){
			for(GroupMember gmObj : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN: setQueueId]){
				if(string.valueOf(gmObj.UserOrGroupId).substring(0,3) == '005'){
					setApproverId.add(gmObj.UserOrGroupId);
				}
			}
		}
		
		//Adding Admins in the approvers list if approval is pending
		if(!setApproverId.isEmpty()){
					
			for(User usr :[Select Id from User where (Profile.Name IN ('System Administrator') OR UserRole.Name IN : setApproverRole) AND IsActive = true]){
				setApproverId.add(usr.Id);
			}
		}
		
		system.debug('setApproverId --- '+setApproverId);
		if(!setApproverId.isEmpty()){ mapApproverWithLevel.put(approvalLvl, setApproverId); }
		return mapApproverWithLevel;
    }	
	//11762 Ends 	
	
	//12051 Starts
	/*Method to remove Program for historical transactions*/ 
	public void updateProgramOnRelatedRecords(List < CLQ_Program_Transaction__c > newList, map < Id, CLQ_Program_Transaction__c > oldMap){
		system.debug('---Enter updateProgramOnRelatedRecords -----');
        Id recTypeIdOnsiteConInfo = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update On-site Contact Information').getRecordTypeId();
        Id recTypeIdFS = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Update Facility Information').getRecordTypeId();
        Id recTypeIdProgRole = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByName().get('Program Role').getRecordTypeId();
        Id recTypeIdDC = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('Day Camp').getRecordTypeId();
		
		Map<Id, Set<Id>> mapRecTypePrgId = new Map<Id, set<Id>>();
		List<Id> lstProgTransId = new List<Id>();
		
		try{
	        for (CLQ_Program_Transaction__c ptObj: newlist){
	
				CLQ_Program_Transaction__c oldPTObj = oldMap.get(ptObj.Id);
				
				if (ptObj.CLQ_Transaction_Status__c == 'Submitted' && oldPTObj.CLQ_Transaction_Status__c != 'Submitted'){
					
					lstProgTransId.add(ptObj.Id);
					
					if(mapRecTypePrgId.containsKey(ptObj.RecordTypeId)){ mapRecTypePrgId.get(ptObj.RecordTypeId).add(ptObj.CLQ_Program__c); }
                    else{
						mapRecTypePrgId.put(ptObj.RecordTypeId, new Set<Id>{ptObj.CLQ_Program__c});
					}
				}
				
				system.debug('---Map Prg Rec Type ID --- '+mapRecTypePrgId);
				
				if(!mapRecTypePrgId.isEmpty()){
					List<CLQ_Role__c> lstRoleToUpdate = new List<CLQ_Role__c>();
					List<CLQ_Facility_Schedule__c> lstFSToUpdate = new List<CLQ_Facility_Schedule__c>();
					
					for(Id recTypeId : mapRecTypePrgId.keySet()){
						Set<Id> setProgId = mapRecTypePrgId.get(recTypeId);
						
						//To remove Program from existing roles of old Transaction
						//CR - 12214 - Update for Day Camp Program Information Update
						if(recTypeId == recTypeIdOnsiteConInfo || recTypeId == recTypeIdDC){
							system.debug('---Onsite Contact Info Update ---');
							for(CLQ_Role__c roleObj : [Select Id, CLQ_Program__c from CLQ_Role__c 
														where CLQ_Program__c IN : setProgId 
														AND RecordTypeId =: recTypeIdProgRole 
														AND CLQ_Role__c IN ('On-site Contact','Alternate On Site Contact')
														AND CLQ_Program_Transaction_Source__c NOT IN : lstProgTransId]){
								
								roleObj.CLQ_Program__c = null;							
								lstRoleToUpdate.add(roleObj);
							}
						}
						
						//To remove Program from existing Facility Schedule of old Transaction
						if(recTypeId == recTypeIdFS){
							system.debug('---Facility Schedule Update ---');
							for(CLQ_Facility_Schedule__c fsObj : [Select Id, CLQ_Program__c from CLQ_Facility_Schedule__c 
														where CLQ_Program__c IN : setProgId 
														AND CLQ_Program_Transaction__c NOT IN : lstProgTransId]){
								
								fsObj.CLQ_Program__c = null;							
								lstFSToUpdate.add(fsObj);
							}
						}
																
					}
					
					system.debug('--lstRoleToUpdate--'+lstRoleToUpdate);
					if(!lstRoleToUpdate.isEmpty()){ update lstRoleToUpdate; }
					
					system.debug('--lstFSToUpdate--'+lstFSToUpdate);
					if(!lstFSToUpdate.isEmpty()){ update lstFSToUpdate; }					
				}
	
	    	}
		}catch(Exception e){
			Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_ProgramTransactionTrigHdlrLicsng');
		}
		
		system.debug('---Exit updateProgramOnRelatedRecords -----');
	}	
	//12051 Ends
}