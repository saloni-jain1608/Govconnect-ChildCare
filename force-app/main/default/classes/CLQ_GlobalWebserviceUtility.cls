/*****************************************************************************************************************************
 **    DATE    * DEV NAME *                                    TFS NUMBER / DESC
 *****************************************************************************************************************************
** Modification Log:
**------------------
**  Developer			Date			Version		Description
**  Neetu Ojha			06/08/2017      1.1       	CR#11200; Email Matrix Change
**  JIANGL          	06/20/2017      1.2         TFS#11354 : If ODE Program doesn't have an associated role, send email to the reviewer on porgram.
**  JIANGL          	08/02/2017      1.3         TFS#11354 : Clean up
**	Neetu Ojha			10/09/2017		1.4			TFS#11785 : Fix to remove Inactive/ Denied Role while sending email.
**	Neetu Ojha			10/31/2017		1.5			TFS#11815 : Added methods to send closed by system emails for ODE & JFS
**	Neetu Ojha			11/02/2017		1.6			TFS#11799 : Added methods to send CAP overdue email for ODE & JFS
**  Pavan Ayta			01/08/2018		1.7			TFS#11926 : Added methods to create a Task and send Email for ODE & JFS
**	Neetu Ojha			01/19/2018		1.8			TFS#12174 : Updating Owner Id as current User
**	Soufin Rahimeen		05/04/2018		1.9			TFS#12166 : Created methods and updated logic to send Email for Day Camp Application Approval
**  Rohit Gowrishetty   05/10/2018		2.0			TFS#12211 : Added a button functionality to submit the inspection record from backoffice for Ongoing RT
**  Rohit Gowrishetty   05/10/2018		2.1			TFS#13333 : Added a button functionality to submit the inspection record from backoffice for Annual and initial RT
**  Rohit Gowrishetty   10/02/2018		2.2			TFS#14791 : Updated the class to check the conditions in Query itself instead of checking it in if condition
**  Pradeep Ravi		12/03/2018		2.3			TFS#14919 : AR Reminder Mails for ODE not going to Site Level Individuals
**  Rohit Gowrishetty	01/29/2019		2.4			TFS#15320 : Added the transaction assigned to owner in the recipient list
**  Vijay Gurusamy		06/06/2019		2.5			TFS#15875 : Do not clone CLQ_External_Id__c in copyStaffDetails method.
**  Sujith Balakrishnan 08/14/2019		2.7			TFS#15835 : Added validation for Resubmitted status.
**  Sujith Balakrishnan 09/07/2019		2.8			TFS#15920 : ODE duplication of staff records when pulled from Previous Inspection tab.
**  Sujith Balakrishnan 09/09/2019      2.9         TFS#16013 : When processing an inspection, staff records that are pulled in from a previous full inspection should only come from a Pre-licensing, Provisional, Annual, Compliance, or Follow-up inspection 
**  Sujith Balakrishnan 10/07/2019      2.10         TFS#15251 : Rating shouldn't be calculated if Reinstate,Expedited Rating/Change of Owner Transaction has any finding in deferral status
*****************************************************************************************************************************/

global with sharing class CLQ_GlobalWebserviceUtility {
    //Method to do the Program Transaction submit logic to be called from the std ui button in sfdc
    //@param: objectID, objType
    //@return: return code
    public static final string INACTIVE = 'Inactive';
    public static final string DENIED = 'Denied';
    public static Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
    public static Id objAnnualReportReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
    public static Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
    //15251 starts
    public static Id objExpeditedReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
    public static Id objChangeOwnerReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
    public static Id objReinstate = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();
 	//15251 ends
    public static Id portalRoleRecId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId();
    public static Id orgRoleRecId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Organization_Role').getRecordTypeId(); //12166 DC Org Roles
    public static Id PreSchoolId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
    public static Id SACCId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
 	private static set<String> setExcludeRoleStatus = new set<String>{INACTIVE, DENIED}; //11785
 	public static final string EMPTY='';
    public static final string RETURNED_FOR_REVISION='Returned for Revision';
    public static final string SUBMITTED = 'Submitted';
    public static final string OCLQSOWNER = 'OCLQSOwner';
    public static final string OCLQSUTQ = 'OCLQSSUTQ';
    public static final string OCLQADMIN = 'OCLQSAdministrator';
    public static final string CLOSED_BY_SYSTEM = 'Closed by System';
    public static final string SELECT_ID = 'Select Id';
    public static final string FROM_CLQ_PROGRAM = ' from CLQ_Program__c where ID IN : setProgId';
    public static final string returnError = 'Error - This transaction has already been submitted';
    public static final string returnError2 = 'Error - Fee or Payment Override Required';
    public static final string Not_Submitted = 'Not Submitted';
    public static final string Not_Complete = 'Not Complete';
    public static final string Resubmitted = 'Resubmitted';
    public static final string CLQ_Registration_Day_Camp = 'CLQ_Registration_Day_Camp';
    public static final string Ongoing_Quality_Rating_Registration = 'Ongoing_Quality_Rating_Registration';
    public static final string Annual_Report = 'Annual_Report';
    public static final string UpdateString = 'update';
    public static final string Quality_Rating_Registration = 'Quality_Rating_Registration';
    public static final string ODE = 'ODE';
    public static final string LICENSING_MANAGER_EMAIL =  'LicenseManagerEmail';
    public static final string DOT = '.';
    public static final String DAYCAMP ='Day Camp';
    public static final string RENEWAL = 'Renewal';
    public static final string REGISTRATION = 'Registration';
    public static final string STRING_UPDATE = 'Update';
    public static final string INITIAL_APPLICATION = 'Initial Application';
    public static final string RECERTIFICATION = 'Recertification';
    public static string completeDocReview(String ptID){
        String returnCd = EMPTY;
        CLQ_Program_Transaction__c ptCurrent;
        if(ptID != null){
            ptCurrent = [select id, CLQ_Registration_Status__c from CLQ_Program_Transaction__c where id = :ptID];
        }
        ptCurrent.CLQ_Registration_Status__c = RETURNED_FOR_REVISION;
        list<CLQ_Transaction_Document__c > TDList;
        if(ptID != null){
            TDList = [select id, CLQ_Document_Status__c  from CLQ_Transaction_Document__c where CLQ_Document_Status__c = 'Under Review' and CLQ_Program_Transaction__r.id = :ptID];
        } 
        for (CLQ_Transaction_Document__c td : TDList){
            td.CLQ_Document_Status__c = RETURNED_FOR_REVISION;
        }
        
        
        try{
            if (!TDList.isEmpty()){
                update TDList;
            }
            List<CLQ_Program_Transaction__c> ProgramTransList = new List<CLQ_Program_Transaction__c>();
            ProgramTransList.add(ptCurrent);
            if(!ProgramTransList.isEmpty()){
                update ProgramTransList;
            }
        }
        catch(exception e){
                return 'Error - ' + e.getMessage();
        }
        
        return returnCd;
    }
    
    webservice static string submitProgTrans(String objectID,String objType){
        //validate Fee Paid checkbox =True or Payment Override Checkbox = True.
        //Error Message - Fee or Payment Override Required
        try{
        RecordType PTRecType = null;    
        Id dayCamp = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(CLQ_Registration_Day_Camp).getRecordTypeId();
        Id RT_ongoing = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(Ongoing_Quality_Rating_Registration).getRecordTypeId(); //12211
        Id RT_annual = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(Annual_Report).getRecordTypeId(); //13333
        Id RT_initial = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(Quality_Rating_Registration).getRecordTypeId(); //13333
            
        Map<Id,RecordType> PTRecordType = new Map<Id,RecordType>([Select Id,Name from RecordType where sObjectType = 'CLQ_Program_Transaction__c' and Name in ('Application - CC Center', 'Application - FCC','Amendment - FCC - Change of Location','Amendment - Center - Change of Location','Day Camp','SUTQ - Ongoing Registration' , 'SUTQ - Initial Registration' , 'SUTQ - Annual Report')]); //12211,13333
        CLQ_Program_Transaction__c progTrans;
        if(objectID != null){
        	progTrans = [select id,Submission_Date1__c,CLQ_Old_Submission_Date1__c,recordtypeid,CLQ_Transaction_Type__c,
                CLQ_Registration_Status__c, CLQ_Fee_Paid__c, CLQ_Override__c, CLQ_Program__r.id,
                CLQ_Submitter__c,CLQ_Submission_Date__c, CLQ_Transaction_Status__c, 
                CLQ_Transaction_Assigned_To__c, OwnerId 
                FROM CLQ_Program_Transaction__c where Id = : objectID];
        }
            if(PTRecordType.size()!=0){
        		PTRecType = PTRecordType.get(progTrans.recordtypeid);
            }
        //bug 1032 fix
       //TFS 15835- removed resubmit** if (progTrans.CLQ_Transaction_Status__c != null && ( progTrans.CLQ_Transaction_Status__c != 'Not Submitted' &&  progTrans.CLQ_Transaction_Status__c != 'Resubmitted' && progTrans.CLQ_Transaction_Status__c !='Not Complete' ))
        if (progTrans.CLQ_Transaction_Status__c != null && ( progTrans.CLQ_Transaction_Status__c != Not_Submitted  && progTrans.CLQ_Transaction_Status__c != Not_Complete ))
        {//12211
            return returnError;
        }//bug 1032 fix end
        //TFS-15780 Starts Submission date should be updated only if status = Not Submitted / Not Complete
        else if (progTrans.CLQ_Transaction_Status__c != null && progTrans.CLQ_Transaction_Status__c != Resubmitted)
        {
	      	progTrans.Submission_Date1__c = System.now();
            if(progTrans.CLQ_Old_Submission_Date1__c==null){
                progTrans.CLQ_Old_Submission_Date1__c = System.now();//Added by Srikanth OJLS-1199  
            }
	             
	        progTrans.CLQ_Submitter__c = UserInfo.getUserID(); 	
        }
        //TFS-15780 Ends
        
        if (PTRecType != null && !progTrans.CLQ_Fee_Paid__c && !progTrans.CLQ_Override__c){
            //check fee only for renewal and registration for day camp
            if ((PTRecType.id == dayCamp && progTrans.CLQ_Transaction_Type__c == UpdateString) || PTRecType.id == RT_ongoing || PTRecType.id == RT_annual || PTRecType.id == RT_initial  ){} //12211,13333
                    //continue if update
            else {
                return returnError2;}
        }
            
        if (progTrans.CLQ_Transaction_Type__c == RENEWAL ||
            progTrans.CLQ_Transaction_Type__c == REGISTRATION ||
            progTrans.CLQ_Transaction_Type__c == STRING_UPDATE||
            progTrans.CLQ_Transaction_Type__c == INITIAL_APPLICATION||
            progTrans.CLQ_Transaction_Type__c == RECERTIFICATION){
            progTrans.CLQ_Registration_Status__c = SUBMITTED;
            system.debug('setting the reg status');
        }
        else{
            progTrans.CLQ_Transaction_Status__c = SUBMITTED;
        }
        
        //TFS-15780 Starts Submission date should be updated only if status = Not Submitted / Not Complete     
        //progTrans.Submission_Date1__c = System.now();
        //if(progTrans.CLQ_Old_Submission_Date1__c==null)
            //progTrans.CLQ_Old_Submission_Date1__c = System.now();//Added by Srikanth OJLS-1199
        //progTrans.CLQ_Submitter__c = UserInfo.getUserID();
		//TFS-15780 Ends
    	List<CLQ_Program_Transaction__c> ProgramTransList = new List<CLQ_Program_Transaction__c>();
        ProgramTransList.add(progTrans);
        if(!ProgramTransList.isEmpty()){
        	update ProgramTransList;
         }
        return '';
        }catch(DMLException e){
            return  'Error:'+e.getdmlMessage(0);
        
        }catch(exception e){
            return  'Error:'+e.getMessage();
        }
    }
    
    //button call to copy Staff Details from Previous Inspection
    //this method will take as an argument the inspection id.  It will then find
    //the most recent inspection of type "annual" for the program and copy the staffing 
    //and staff training information and copy that to the inspection that the button
    //was clicked on
    //@param: objectID
    //@return: return code
    webservice static string copyStaffDetails(String objectID){
        CLQ_Inspection__c clickedIns;
        if(objectID != null){
            clickedIns = [select CLQ_Program__r.id from CLQ_Inspection__c where id = :objectID];
        } 
        CLQ_Inspection__c cloneIns;
        try
        {
            
          //TFS-16013  cloneIns = [select id from CLQ_Inspection__c where CLQ_program__r.id = :clickedIns.CLQ_Program__r.id and CLQ_Scope__c = 'Full' and (CLQ_Inspection_Status__c = 'Under Approver Review' or CLQ_Inspection_Status__c = 'Approved' ) order by name desc limit 1 ];
            if(clickedIns.CLQ_Program__r.id!=null){
                cloneIns = [select id from CLQ_Inspection__c where CLQ_program__r.id = :clickedIns.CLQ_Program__r.id and CLQ_Scope__c = 'Full' and (CLQ_Inspection_Status__c = 'Under Approver Review' or CLQ_Inspection_Status__c = 'Approved' or CLQ_Inspection_Status__c = 'Revision In Progress' ) and CLQ_Inspection_Type__c in('Pre-license','Provisional','Annual','Compliance','Follow-up') order by name desc limit 1 ];
            }
            
          //TFS-16013
        }
        catch(queryException e){
            return 'Error - There are no Previous Full Inspections to copy the records from';
        }
        list<CLQ_Staff_Record__c> stfRecsToClone = new list<CLQ_Staff_Record__c>();
        System.Debug('cloneIns-->'+cloneIns);
        List<String> fields = new List<String>(CLQ_Staff_Record__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ' select ' + String.join(fields, ',')
            + ' from CLQ_Staff_Record__c where CLQ_Inspection__r.id =\'' + cloneIns.id + '\'' ;
        system.debug('soql statement about to exec ' + soql);
        stfRecsToClone  =  Database.query(soql);
        if (stfRecsToClone.IsEmpty()){
            return 'Error - There are no staff records in the Previous Full Inspection';
        }
        set<id> stfRecIds = new set<id>();
        map<id,CLQ_Staff_Record__c> stfRecsToIns = new map<id,CLQ_Staff_Record__c>();
        for (CLQ_Staff_Record__c sr : stfRecsToClone){
            //get a set of the staff record ids to pick up the staff training recs
            stfRecIds.add(sr.id);
            //clone the original and set the new inspection
            CLQ_Staff_Record__c cloneSr = sr.clone(false,false);
            cloneSr.CLQ_Inspection__c = objectID;
            cloneSr.OwnerId = UserInfo.getUserId(); //12174
            cloneSr.CLQ_External_Id__c = NULL; //TFS#15875
            stfRecsToIns.put(sr.id,cloneSr);
        }
        //TFS#15920 Delete Previous staff records before adding new  -- Starts
        if (stfRecsToIns.size() > 0)
        {
            CLQ_StaffRecordTriggerHandler.BypassTrigger = true;
            List<CLQ_Staff_Record__c> exisitingStaffRecords;
            if(objectID != null){
                exisitingStaffRecords = [SELECT Id,CLQ_Inspection__c FROM CLQ_Staff_Record__c WHERE CLQ_Inspection__c = :objectID];
            }
            if(exisitingStaffRecords.size()>0)
            {
                List<Id> staffRecordIdList = new List<Id>();
                for(CLQ_Staff_Record__c st: exisitingStaffRecords)
                {
                    staffRecordIdList.add(st.Id);
                }
                List<CLQ_Staff_Training__c> existingStaffTrainingRecords;
                if(staffRecordIdList != null){
                    existingStaffTrainingRecords = [SELECT Id, CLQ_Staff_Record__c FROM CLQ_Staff_Training__c WHERE CLQ_Staff_Record__c IN :staffRecordIdList];
                }
                
                if(!existingStaffTrainingRecords.isEmpty())
                {
                    delete existingStaffTrainingRecords;                  
                }
                if(!exisitingStaffRecords.isEmpty())
                {
                    delete exisitingStaffRecords;                  
                }
            }
        }
        //TFS#15920  -- Ends
        if (!stfRecsToIns.values().isEmpty()){
               insert stfRecsToIns.values();
        }
        else {return '' ;}      //nothing to insert
        
        //now get the training recs and clone them
        
        list<CLQ_Staff_Training__c> stfTrainRecsToClone = new list<CLQ_Staff_Training__c>();
        list<CLQ_Staff_Training__c> stfTrainRecsToIns = new list<CLQ_Staff_Training__c>();
        fields = new List<String>(CLQ_Staff_Training__c.SObjectType.getDescribe().fields.getMap().keySet());
        
         soql = ' select ' + String.join(fields, ',')
            + ' from CLQ_Staff_Training__c'
            + ' where CLQ_Staff_Record__r.id in :stfRecIds';
        stfTrainRecsToClone  =  Database.query(soql);
        for (CLQ_Staff_Training__c str : stfTrainRecsToClone){
            //clone the original and set the new inspection
            CLQ_Staff_Training__c cloneStr = str.clone(false,false);
            if(stfRecsToIns.size()!=0){
            	cloneStr.CLQ_Staff_Record__c = stfRecsToIns.get(str.CLQ_Staff_Record__c).id;
            }
            stfTrainRecsToIns.add(cloneStr);
        }       
        if (stfTrainRecsToIns.size() > 0){
             list<CLQ_Staff_Training__c> stfTrainRecsTobeDeleted = new list<CLQ_Staff_Training__c>();
             
            insert stfTrainRecsToIns;
        }
        
        return '';
    }
    
    
    webservice static void sendEmail(string templateName, id ptRecordID) {  
       
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'jshivakumar@deloitte.com'];
        
        EmailTemplate templateForEmail;
        if(templateName!=null){
            templateForEmail = [select id from EmailTemplate where name = :templateName];
        }
        
        Schema.SObjectType sobjectType = ptRecordID.getSObjectType();
        
        if(sobjectType == Schema.getGlobalDescribe().get('CLQ_Program_Transaction__c')){
            //15320 - Added CLQ_Assigned_To_Email__c , clq_recordtypename__c in the query 
            System.debug('');
            CLQ_Program_Transaction__c progTrans;
            if(ptRecordID != null){
                progTrans = [select id,RecordTypeId,CLQ_Program__r.id,CLQ_Program__r.CLQ_Associated_Organization__r.id , CLQ_Assigned_To_Email__c , clq_recordtypename__c from CLQ_Program_Transaction__c where id = :ptRecordID limit 1];
            }
            list<string> toAddressesSUTQ = getAllRecipientsSUTQ(progTrans.CLQ_Program__r.Id,progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id,progTrans.RecordTypeId);
            list<string> toAddressesLICENSING = getAllRecipientsLicensing(progTrans.CLQ_Program__r.Id,progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id,progTrans.RecordTypeId);
       
            if(progTrans.RecordTypeId == objInitialRegId || progTrans.RecordTypeId == objAnnualReportReg || progTrans.RecordTypeId == objOnGoingReg || progTrans.RecordTypeId == objExpeditedReg || progTrans.RecordTypeId == objReinstate || progTrans.RecordTypeId == objChangeOwnerReg ){ //15251 added additional SUTQ transaction
            	System.debug('first if statement --->');
                    try{
                       //EmailTemplate templateForEmail = [select id from EmailTemplate where name = :templateName];
                        list<CLQ_Role__c> roleForEmail;
                        if((setExcludeRoleStatus != null) && (progTrans.CLQ_Program__r.id!=null || progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id!=null)){
                            roleForEmail = [select id,CLQ_Contact__c from CLQ_Role__c where (Portal_Roles__c = 'OCLQSOwner' or Portal_Roles__c = 'OCLQSSUTQ' or Portal_Roles__c = 'OCLQSAdministrator') 
                       										and (CLQ_Program__r.id = :progTrans.CLQ_Program__r.id or CLQ_Organization__r.id = :progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id)
                       										AND CLQ_Status__c NOT IN : setExcludeRoleStatus]; //11785
                        }
                       //Added logic by VS to take only those role on which user is having access to contact
                        set<id> contactIDset = new set<id>();
                        for(CLQ_Role__c roleRecord : roleForEmail){
                            contactIDset.add(roleRecord.CLQ_Contact__c );
                        }
                        list<Contact> contactList = new list<Contact>();
                        if(contactIDset!=null){
                            contactList = [Select id FROM Contact where id in :contactIDset limit 1];
                        }
                         
                        if(contactList.size()>0){
                       msg.settargetObjectID(contactList[0].id);
                       msg.setwhatID(progTrans.id);
                       msg.setTemplateId(templateForEmail.id);
                       if(toAddressesSUTQ != null && toAddressesSUTQ.size() >0){
                           msg.setToaddresses(toAddressesSUTQ);
                       }
                       if ( owea.size() > 0 ) {
                       		
                           msg.setOrgWideEmailAddressId(owea.get(0).Id);
                       }
                       msg.setTreatTargetObjectAsRecipient(false);
                       //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                       }
                    }
                    catch(QueryException e){
                        system.debug('exception:'+e);
                    }
            }
            else{
            	System.debug('second if statement --->');
                     try{
                         //15320
                         if(progTrans.clq_recordtypename__c == 'Licensing - Closure' && progTrans.CLQ_Assigned_To_Email__c != null){
                             toAddressesLICENSING.add(progTrans.CLQ_Assigned_To_Email__c);
                         }
                         
                        // System.debug('toAddressesLICENSING list is ' + toAddressesLICENSING);
                     	//System.debug('second if statement try block--->');
                        //EmailTemplate templateForEmail = [select id from EmailTemplate where name = :templateName];
                        list<CLQ_Role__c> roleForEmail;
                         if((setExcludeRoleStatus != null) && (progTrans.CLQ_Program__r.id!=null || progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id!=null)){
                             roleForEmail = [select id,CLQ_Contact__r.id,CLQ_Contact__c from CLQ_Role__c 
                        									where (Portal_Roles__c = 'OCLQSOwner' or Portal_Roles__c = 'OCLQSLicensing' or Portal_Roles__c = 'OCLQSAdministrator') 
                        									and (CLQ_Program__r.id = :progTrans.CLQ_Program__r.id or CLQ_Organization__r.id = :progTrans.CLQ_Program__r.CLQ_Associated_Organization__r.id)
                        									AND CLQ_Status__c NOT IN : setExcludeRoleStatus]; //11785

                         }
                                                //Added logic by VS to take only those role on which user is having access to contact
                        set<id> contactIDset = new set<id>();
                        for(CLQ_Role__c roleRecord : roleForEmail){
                            contactIDset.add(roleRecord.CLQ_Contact__c );
                        }
                        
                        list<Contact> contactList = new list<Contact>();
                         if(contactIDset != null){
                             contactList = [Select id FROM Contact where id in :contactIDset limit 1];
                         }
                        //System.debug('contact list in second if block--->' + contactList.size());
                        if(contactList.size()>0){ //End of VS logic
	                        CLQ_Message_Emails__c mEmail =CLQ_Message_Emails__c.getinstance();
	                        system.debug('value of CLQ_Message_Emails__c ' + mEmail);
	                        
	                        if (mEmail.CLQ_Message_Process_Email__c != null){
	                            //system.debug('found a value for CLQ_Message_Emails__c ' + mEmail);
	                            toAddressesLICENSING.add(mEmail.CLQ_Message_Process_Email__c);
	                        }
	                        //system.debug('***LD....roleForEmail.CLQ_Contact__r.id####'+roleForEmail.CLQ_Contact__r.id);
	                        msg.settargetObjectID(contactList[0].id);
	                        msg.setwhatID(ptRecordID);
	                        msg.setTemplateId(templateForEmail.id);
	                       
	                        if(toAddressesLICENSING != null && toAddressesLICENSING.size() >0){
	                           msg.setToaddresses(toAddressesLICENSING );
	                       }
	                            //Added by MP - Begin - OJLS-1111
	               			if ( owea.size() > 0 ) {
	               				
	                           msg.setOrgWideEmailAddressId(owea.get(0).Id);
	                       }
	                            //Added by MP - End - OJLS-1111
	                        msg.setTreatTargetObjectAsRecipient(false);
	                        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                        }
                    }
                    catch(QueryException e){
                        system.debug('exception:'+e);
                    }
            }
        }
        if(sobjectType == Schema.getGlobalDescribe().get('CLQ_Inspection__c')){
            system.debug('');
            CLQ_Inspection__c inspection;
            if(ptRecordID != null){
            	inspection = [select id,CLQ_Program_Transaction__r.Id,CLQ_Program_Transaction__r.CLQ_Program__r.CLQ_Associated_Organization__r.id,CLQ_Program_Transaction__r.RecordTypeId,CLQ_Program_Transaction__r.CLQ_Program__r.Id from CLQ_Inspection__c where id = :ptRecordID limit 1];
            }
            list<string> toAddressesInspectionSUTQ = getAllRecipientsSUTQ(inspection.CLQ_Program_Transaction__r.CLQ_Program__r.Id,inspection.CLQ_Program_Transaction__r.CLQ_Program__r.CLQ_Associated_Organization__r.id,inspection.CLQ_Program_Transaction__r.RecordTypeId);
        
        if(inspection.CLQ_Program_Transaction__r.RecordTypeId == objInitialRegId || inspection.CLQ_Program_Transaction__r.RecordTypeId == objAnnualReportReg || inspection.CLQ_Program_Transaction__r.RecordTypeId == objOnGoingReg ){
                try{
                   //EmailTemplate templateForEmail = [select id from EmailTemplate where name = :templateName];
                    CLQ_Role__c roleForEmail;
                    if((setExcludeRoleStatus != null) && (inspection.CLQ_Program_Transaction__r.CLQ_Program__r.id!=null || inspection.CLQ_Program_Transaction__r.CLQ_Program__r.CLQ_Associated_Organization__r.id!=null )){
                        roleForEmail = [select id,CLQ_Contact__r.id from CLQ_Role__c where (Portal_Roles__c = 'OCLQSOwner' or Portal_Roles__c = 'OCLQSSUTQ' or Portal_Roles__c = 'OCLQSAdministrator') 
                   								and ( CLQ_Program__r.id = :inspection.CLQ_Program_Transaction__r.CLQ_Program__r.id 
                   										or CLQ_Organization__r.id = :inspection.CLQ_Program_Transaction__r.CLQ_Program__r.CLQ_Associated_Organization__r.id) 
                   								AND CLQ_Status__c NOT IN : setExcludeRoleStatus limit 1]; //11785
                    }
                   //list<string> toAddresses = inspection.CLQ_Program_Transaction__r.CLQ_Program__r.CLQ_Org_Wide_Email_Addresses_SUTQ__c.split(';');
                   msg.settargetObjectID(roleForEmail.CLQ_Contact__r.id);
                   msg.setwhatID(inspection.id);
                   msg.setTemplateId(templateForEmail.id);
                   if(toAddressesInspectionSUTQ != null && toAddressesInspectionSUTQ.size() >0){
						msg.setToaddresses(toAddressesInspectionSUTQ);
                   }
                   if ( owea.size() > 0 ) {
                       msg.setOrgWideEmailAddressId(owea.get(0).Id);
                   }
                   msg.setTreatTargetObjectAsRecipient(false);
                   //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                }
                catch(QueryException e){
                    system.debug('exception:'+e);
                }
        }
        
        }
    }
    
    @InvocableMethod(label='Send Email' description='Allows an email to be sent using apex, combine template and ptRecordID id separated by comma')
    public static void sendEmail(list<string> templateAndRecordID) {  
      //CR-11200 Starts
      Map<Id, String> mapPrgTransEmailTemplate = new Map<Id, String>();
      Map<Id, String> mapCAPEmailTemplate = new Map<Id, String>();
      Map<Id, String> mapProgramEmailTemplate = new Map<Id, String>();
      //CR-11200 Ends 
      String recordType = EMPTY; //12166 variable to store record type of Program
      
        for (string tempRec : templateAndRecordID){
            list<string> callParms = tempRec.split('\\|');
            //system.debug('incoming parms to the sendEmail funtion ' + tempRec);
            //system.debug('incoming parms to the sendEmail funtion ' + callParms[0]);
            //system.debug('incoming parms to the sendEmail funtion ' + callParms[1]);
            //12166 Day Camp will have 4 parameters from Process Builder: CLQ - Email Alert - New license Approval - ODE and JFS
            if(callParms.size()==4) {
            	//system.debug('parameter 3--->' + callParms[2]); //PT object name
            	//system.debug('parameter 4--->' + callParms[3]); //Program record type
            	recordType = callParms[3];
            }
            //CR-11200 Starts
            if(callParms.size()==2){
              sendEmail(callParms[0], callParms[1]);
            }else{
              if(callParms[2] == 'CLQ_Program__c'){
                mapProgramEmailTemplate.put(callParms[1], callParms[0]);
                
              }else if(callParms[2] == 'CLQ_Corrective_Action_Plan__c'){
                mapCAPEmailTemplate.put(callParms[1], callParms[0]);
                
              }else if(callParms[2] == 'CLQ_Program_Transaction__c'){
              	
                mapPrgTransEmailTemplate.put(callParms[1], callParms[0]);
              }
            }
        }

        if(!mapPrgTransEmailTemplate.isEmpty()){
          sendJFSEmailForPrgTransaction(mapPrgTransEmailTemplate, recordType); //12166 Updated call since method parameters changed
        }
        
        if(!mapProgramEmailTemplate.isEmpty()){
          sendJFSEmailForProgram(mapProgramEmailTemplate);
        }
        
        if(!mapCAPEmailTemplate.isEmpty()){
          sendJFSEmailForCAP(mapCAPEmailTemplate);
        }        
        //CR-11200 Ends
    }
    
    //Method to get email address of the roles associated to program and Account for SUTQ
    global static List<String> getAllRecipientsSUTQ(Id  programId, Id accountId, Id progTransactionRecId){
        set<string> SUTQPortalRoles = new set<String> {OCLQSOWNER,  OCLQSUTQ,   OCLQADMIN}; // 14791
        List<CLQ_Role__c>  roleassociatedToProgram = new List<CLQ_Role__c>(); //14791
        CLQ_Program__c program;
        if(programId!=null){
            program = [Select Id,Name,recordTypeid,SUTQ_Reviewer__r.email from CLQ_Program__c where Id =: programId ];//bug 11354 fix
        }
        if(programId!=null && portalRoleRecId!=null && SUTQPortalRoles!=null && setExcludeRoleStatus!=null){
            roleassociatedToProgram = [Select Id,Name,Secondary_Role__c,recordTypeid,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c  from CLQ_Role__c where CLQ_Program__r.Id =: programId AND recordTypeid = :portalRoleRecId AND Role_Type__c ='ODE' AND Portal_Roles__c IN  :SUTQPortalRoles AND CLQ_Status__c NOT IN : setExcludeRoleStatus]; //11785 //14791
        }
        List<CLQ_Role__c>  roleassociatedToAccount;
        if(accountId!=null && setExcludeRoleStatus!=null){
            roleassociatedToAccount = [Select Id,Name,Secondary_Role__c,recordTypeid,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c from CLQ_Role__c where CLQ_Organization__r.Id =: accountId AND CLQ_Status__c NOT IN : setExcludeRoleStatus];
        }
         //11785  

        List<String> SUTQRolesEmailAddresses = new List<String>();

        //bug 11354 fix 
         if(roleassociatedToProgram != null && !roleassociatedToProgram.isEmpty()){
             System.debug('');
            for(CLQ_Role__c programRole : roleassociatedToProgram){
               if( programRole.recordTypeid == portalRoleRecId && programRole.Role_Type__c == ODE && SUTQPortalRoles.contains(programRole.Portal_Roles__c) ){                   
                      SUTQRolesEmailAddresses.add(programRole.CLQ_Contact_Email_Address__c);
                 }
             } 
         } else if((program.recordTypeid == PreSchoolId || program.recordTypeid == SACCId) && program.SUTQ_Reviewer__r.email != null) {                                         
             SUTQRolesEmailAddresses.add(program.SUTQ_Reviewer__r.email);  
             //System.debug('EMAIL(SUTQ_Reviewer__r From getAllRecipientsSUTQ)==>' + program.SUTQ_Reviewer__r.email);     
                                                           
             }
        // bug 11354 fix end

        if(roleassociatedToAccount != null && !roleassociatedToAccount.isEmpty() ) {
            System.debug('');
          for(CLQ_Role__c accountRole : roleassociatedToAccount){
            if(accountRole.recordTypeid == portalRoleRecId && accountRole.Role_Type__c == ODE && SUTQPortalRoles.contains(accountRole.Portal_Roles__c)){
                System.debug('');
              if(program.recordTypeid == PreSchoolId && accountRole.Secondary_Role__c != null &&  accountRole.Secondary_Role__c.contains(Label.SecondaryRolePreSchool) ){
                    SUTQRolesEmailAddresses.add(accountRole.CLQ_Contact_Email_Address__c);
              }
                System.debug('');
              if(program.recordTypeid == SACCId && accountRole.Secondary_Role__c != null && accountRole.Secondary_Role__c.contains(Label.SecondaryRoleSACC)){
                  SUTQRolesEmailAddresses.add(accountRole.CLQ_Contact_Email_Address__c);
              }
            }       
          }
        }
        //System.debug('EMAIL(getAllRecipientsSUTQ)==>' + SUTQRolesEmailAddresses); 
        return SUTQRolesEmailAddresses; 
    } 
    public static final string OCLQSLICENSING='OCLQSLicensing';
    //Method to get email address of the roles associated to program and Account for SUTQ
    public static List<String> getAllRecipientsLicensing(Id  programId, Id accountId, Id progTransactionRecId){
        //bug 11354 fix 
       set < string > PortalRoles = new set < string > { OCLQSOWNER,  OCLQSLICENSING,   OCLQADMIN  }; //14791
        List<CLQ_Role__c>  roleassociatedToProgram = new List<CLQ_Role__c>(); //14791
        CLQ_Program__c program;
        if(programId!=null){
            program = [Select Id,Name,recordTypeid,CLQ_Licensing_Specialist__r.email from CLQ_Program__c where Id =: programId ];
        }
        if(programId!=null && portalRoleRecId!=null && PortalRoles!=null && setExcludeRoleStatus!=null){
            roleassociatedToProgram = [Select Id,Name,Secondary_Role__c,recordTypeid,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c  
                                                      from CLQ_Role__c 
                                                      where CLQ_Program__r.Id =: programId AND recordTypeid = :portalRoleRecId AND Role_Type__c ='ODE' AND Portal_Roles__c IN  :PortalRoles
                                                      AND CLQ_Status__c NOT IN : setExcludeRoleStatus
                                                      ]; //11785 //14791
        }
       	
		List<CLQ_Role__c>  roleassociatedToAccount;
        if(accountId!=null && setExcludeRoleStatus!=null){
            roleassociatedToAccount = [Select Id,Name,Secondary_Role__c,recordTypeid,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c 
                                                      from CLQ_Role__c 
                                                      where CLQ_Organization__r.Id =: accountId AND CLQ_Status__c NOT IN : setExcludeRoleStatus
                                                      ]; //11785
        }
        List<String> LICENSINGRolesEmailAddresses = new List<String>();
             
        if(roleassociatedToProgram != null && !roleassociatedToProgram.isEmpty()){
            System.debug('');
           for(CLQ_Role__c programRole : roleassociatedToProgram){
               if( programRole.recordTypeid == portalRoleRecId && programRole.Role_Type__c == ODE && PortalRoles.contains(programRole.Portal_Roles__c) ){
                  LICENSINGRolesEmailAddresses.add(programRole.CLQ_Contact_Email_Address__c);
               }
            } 
         } else if((program.recordTypeid == PreSchoolId || program.recordTypeid == SACCId) && (program.CLQ_Licensing_Specialist__r.email != null))  { 
             LICENSINGRolesEmailAddresses.add(program.CLQ_Licensing_Specialist__r.email); 
             //System.debug('EMAIL(CLQ_Licensing_Specialist__r From getAllRecipientsLicensing)==>' + program.CLQ_Licensing_Specialist__r.Email); 
         	     
            }
         //bug 11354 fix  end 
        
        if(roleassociatedToAccount != null && !roleassociatedToAccount.isEmpty() ) {
          for(CLQ_Role__c accountRole : roleassociatedToAccount){
            if(accountRole.recordTypeid == portalRoleRecId && accountRole.Role_Type__c == ODE && PortalRoles.contains(accountRole.Portal_Roles__c)){
                LICENSINGRolesEmailAddresses.add(accountRole.CLQ_Contact_Email_Address__c);
            }   
            
          }
        }
        
        //System.debug('EMAIL(getAllRecipientsLicensing)==>' + LICENSINGRolesEmailAddresses);
        return LICENSINGRolesEmailAddresses ; 
    }    
    
    //Method to get email address to respective Program Transaction for a given list.
    global static Map<id,List<String>> getAllRecipientsSUTQBatch(List<CLQ_Program_Transaction__c> lstTrans){            
        Set<Id> progTranId = new Set<Id>();      //bug 11354 fix  
        Map<Id,Id> mapProgramtoPT = new Map<Id,Id>();
        Map<Id,Id> mapAccounttoPT = new Map<Id,Id>();
        Map<Id,List<String>> finalMapPTtoEmail = new Map<Id,List<String>>();
        set<string> SUTQPortalRoles = new set<String> {OCLQSOWNER, OCLQSUTQ, OCLQADMIN};
            //List<String> emailAddress = new List<String>();
        Map<Id,List<CLQ_Role__c>>  mapProgramToRole = new Map<Id,List<CLQ_Role__c>>();
        Map<Id,List<CLQ_Role__c>>  mapAccountToRole = new Map<Id,List<CLQ_Role__c>>();
        
        try{  
            // bug 11354 fix 
            for(CLQ_Program_Transaction__c cmail: lstTrans){
                progTranId.add(cmail.Id);               
            }          
            //System.debug(' progTranId = ' +  progTranId); 
            list<CLQ_Program_Transaction__c> lstprogTrans;
            if(progTranId!=null){
                lstprogTrans = [SELECT Id,  CLQ_Program__r.RecordTypeId, CLQ_Program__r.id, CLQ_Program__r.SUTQ_Reviewer__r.Email, CLQ_Program__r.CLQ_Associated_Organization__r.Id FROM CLQ_Program_Transaction__c where id IN: progTranId];
            }
               
            // bug 11354 fix end

            for(CLQ_Program_Transaction__c cmail: lstprogTrans){             
                mapProgramtoPT.put(cmail.Id,cmail.CLQ_Program__r.id);
                mapAccounttoPT.put(cmail.Id,cmail.CLQ_Program__r.CLQ_Associated_Organization__c);                                      
            }   
            
            //System.debug('mapAccounttoPT = ' + mapAccounttoPT); 
            //System.debug('mapProgramtoPT = ' + mapProgramtoPT); 
            
            list<CLQ_Role__c> rolesassociatedToProgram;
            if(mapProgramtoPT.values()!=null && setExcludeRoleStatus!=null){
                rolesassociatedToProgram = [SELECT Id,Name,CLQ_Program__r.Id,Secondary_Role__c,recordTypeid,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c,CLQ_Contact__r.email, ODE_Role_Type__c    
                                                          FROM CLQ_Role__c 
                                                          WHERE CLQ_Program__r.Id IN: mapProgramtoPT.values() AND CLQ_Status__c NOT IN : setExcludeRoleStatus]; //11785
            }
            
            
            if(rolesassociatedToProgram != null && !rolesassociatedToProgram.isEmpty() ) {
              for(CLQ_Role__c role : rolesassociatedToProgram){
                //populate the map mapProgramToRole
                if (!mapProgramToRole.ContainsKey(role.CLQ_Program__r.Id)){
                     mapProgramToRole.put(role.CLQ_Program__r.Id, new list < CLQ_Role__c > ());
                     //System.debug('programId in role = ' + role.CLQ_Program__r.Id);  
                }   
                mapProgramToRole.get(role.CLQ_Program__r.Id).Add(role);
                
             }
           }
            
            
            list<CLQ_Role__c> rolesassociatedToAccount;
            if(mapAccounttoPT.values()!=null && setExcludeRoleStatus!=null){
                rolesassociatedToAccount = [SELECT Id,Name,CLQ_Program__r.recordTypeId,Secondary_Role__c,recordTypeid,CLQ_Organization__r.Id,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c,CLQ_Contact__r.email, ODE_Role_Type__c 
                                                          FROM CLQ_Role__c 
                                                          WHERE CLQ_Organization__r.Id IN: mapAccounttoPT.values() AND Secondary_Role__c != NULL AND CLQ_Status__c NOT IN : setExcludeRoleStatus];
            }
             //11785
            //System.debug('rolesassociatedToProgram = ' + rolesassociatedToProgram);
            //System.debug('rolesassociatedToAccount = ' + rolesassociatedToAccount);
            //System.debug('mapProgramToRole = ' + mapProgramToRole.values());
            //System.debug('mapAccountToRole = ' + mapAccountToRole.values());
            
           
           if(rolesassociatedToAccount != null && !rolesassociatedToAccount.isEmpty() ) {  
            for(CLQ_Role__c role : rolesassociatedToAccount){
                //populate the map mapAccountToRole
                if (!mapAccountToRole.ContainsKey(role.CLQ_Organization__r.Id)){
                     mapAccountToRole.put(role.CLQ_Organization__r.Id, new list < CLQ_Role__c > {role});
                }   
                mapAccountToRole.get(role.CLQ_Organization__r.Id).Add(role);
                
            }
           }
            // bug 11354 fix 
            for(CLQ_Program_Transaction__c cmail: lstprogTrans){
                List<String> emailAddress = new List<String>();
                System.debug('');
                if(!mapProgramToRole.isEmpty() && mapProgramToRole.ContainsKey(cmail.CLQ_Program__r.Id)){
                    System.debug('IF PROGRAM MATCHES ==> Id' + cmail.CLQ_Program__r.Id);
                    for(CLQ_Role__c role : mapProgramToRole.get(cmail.CLQ_Program__r.Id)){
                        if(role.recordTypeid == portalRoleRecId && role.Role_Type__c == ODE && SUTQPortalRoles.contains(role.Portal_Roles__c)  && role.ODE_Role_Type__c == 'Org Role'){
                            emailAddress.add(role.CLQ_Contact__r.EMAIL); 
                            //System.debug('EMAIL FROM PROGRAM'+ emailAddress);
                        }
                    }       
                 } else if((cmail.CLQ_Program__r.recordTypeid == PreSchoolId || cmail.CLQ_Program__r.recordTypeid == SACCId) && (cmail.CLQ_Program__r.SUTQ_Reviewer__r.Email != null)) { 
                     emailAddress.add(cmail.CLQ_Program__r.SUTQ_Reviewer__r.Email); 
                    // System.debug('EMAIL(SUTQ_Reviewer__r from getAllRecipientsSUTQBatch)==>' + cmail.CLQ_Program__r.SUTQ_Reviewer__r.Email);   
                 	                                                                                           
                   }
               // bug 11354 fix end 
                       
                if(mapAccountToRole.ContainsKey(cmail.CLQ_Program__r.CLQ_Associated_Organization__r.Id)){
                    System.debug('IF ACCOUNTS MATCHES');
                    for(CLQ_Role__c role : mapAccountToRole.get(cmail.CLQ_Program__r.CLQ_Associated_Organization__r.Id)){
                        if(cmail.CLQ_Program__r.recordTypeId == PreSchoolId && role.Secondary_Role__c.contains(Label.SecondaryRolePreSchool)){
                            emailAddress.add(role.CLQ_Contact__r.EMAIL);
                            //System.debug('EMAIL FROM Account'+ emailAddress);
                        }
                        else if(cmail.CLQ_Program__r.recordTypeId == SACCId && role.Secondary_Role__c.contains(Label.SecondaryRoleSACC)){
                            emailAddress.add(role.CLQ_Contact__r.EMAIL);
                            //System.debug('EMAIL FROM Account SACC'+ emailAddress);
                        }
                    }
                }
                if(!finalMapPTtoEmail.ContainsKey(cmail.Id)){
                    finalMapPTtoEmail.put(cmail.Id,emailAddress);
                }
                else{
                    List<String> emails = finalMapPTtoEmail.get(cmail.Id);
                    emails.addAll(emailAddress);
                    finalMapPTtoEmail.put(cmail.Id,emails);
                }
            }
        }
        catch(Exception e){
            System.debug('Error'+ E.Getmessage());
        }
                        
        //System.debug('EMAIL finalMapPTtoEmail'+ finalMapPTtoEmail);
        return finalMapPTtoEmail ;
    }
    
    
    //Method to get email address to respective  for a given list.
     global static Map<id,List<String>> getAllRecipientsSUTQBatchProg(List<CLQ_Program__c> lstPrograms){
        
        //Map<Id,Id> mapProgramtoPT = new Map<Id,Id>();
        Set<Id> progId = new Set<Id>();
        Map<Id,Id> mapAccounttoProg = new Map<Id,Id>();
        Map<Id,List<String>> finalMapPTtoEmail = new Map<Id,List<String>>();
        set<string> SUTQPortalRoles = new set<String> {OCLQSOWNER, OCLQSUTQ, OCLQADMIN};
        Map<Id,List<CLQ_Role__c>>  mapProgramToRole = new Map<Id,List<CLQ_Role__c>>();
        Map<Id,List<CLQ_Role__c>>  mapAccountToRole = new Map<Id,List<CLQ_Role__c>>();
              
        try{    
            for(CLQ_Program__c cmail: lstPrograms){
                progId.add(cmail.Id);
                mapAccounttoProg.put(cmail.Id,cmail.CLQ_Associated_Organization__c);
            }
            
            //System.debug('Programs Id'+ progId );
             
            // bug 11354 fix        
            list<CLQ_Program__c> lstAllprograms;   
            if(progId!=null){
                lstAllprograms = [Select Id,Name,recordTypeid,SUTQ_Reviewer__r.email,CLQ_Associated_Organization__r.Id from CLQ_Program__c where Id =: progId ];
            }
            //System.debug('program(getAllRecipientsSUTQ)==>' + lstAllprograms); 
           // bug 11354 fix end
            
            
            for(CLQ_Program__c cmail: lstAllprograms){                
                mapAccounttoProg.put(cmail.Id,cmail.CLQ_Associated_Organization__c);
            } 
            //System.debug('mapAccounttoProg'+ mapAccounttoProg);  
			list<CLQ_Role__c> rolesassociatedToProgram;            
            if(progId!=null && setExcludeRoleStatus!=null){
                rolesassociatedToProgram = [SELECT Id,Name,CLQ_Program__r.Id,Secondary_Role__c,recordTypeid,
                                                                 CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c, ODE_Role_Type__c, CLQ_Contact__r.EMAIL 
                                                          FROM CLQ_Role__c 
                                                          WHERE CLQ_Program__r.Id IN: progId AND CLQ_Status__c NOT IN : setExcludeRoleStatus];//11785
            }
        
           if(rolesassociatedToProgram != null && !rolesassociatedToProgram.isEmpty() ) {  
             for(CLQ_Role__c role : rolesassociatedToProgram){
                //populate the map mapProgramToRole
                if (!mapProgramToRole.ContainsKey(role.CLQ_Program__r.Id)){
                    mapProgramToRole.put(role.CLQ_Program__r.Id, new list < CLQ_Role__c > {role});
                }   
                mapProgramToRole.get(role.CLQ_Program__r.Id).Add(role);
                
             }                       
           }  
            list<CLQ_Role__c> rolesassociatedToAccount;
            if(mapAccounttoProg.values()!=null && setExcludeRoleStatus!=null){
                rolesassociatedToAccount = [SELECT Id,Name,CLQ_Program__r.recordTypeId,Secondary_Role__c,recordTypeid,
                                                                 CLQ_Organization__r.Id,CLQ_Contact_Email_Address__c,Role_Type__c,Portal_Roles__c, ODE_Role_Type__c,CLQ_Contact__r.EMAIL  
                                                          FROM CLQ_Role__c 
                                                          WHERE CLQ_Organization__r.Id IN: mapAccounttoProg.values() 
                                                          AND Secondary_Role__c != NULL AND CLQ_Status__c NOT IN : setExcludeRoleStatus]; //11785
            }
            //System.debug('rolesassociatedToProgram = ' + rolesassociatedToProgram);
            //System.debug('rolesassociatedToAccount = ' + rolesassociatedToAccount);
            //System.debug('mapProgramToRole = '         + mapProgramToRole.values());
                        
            
           if(rolesassociatedToAccount != null && !rolesassociatedToAccount.isEmpty() ) {    
             for(CLQ_Role__c role : rolesassociatedToAccount){
                //populate the map mapAccountToRole
                if (!mapAccountToRole.ContainsKey(role.CLQ_Organization__r.Id)){
                    mapAccountToRole.put(role.CLQ_Organization__r.Id, new list < CLQ_Role__c > {role});
                }   
                mapAccountToRole.get(role.CLQ_Organization__r.Id).Add(role);
             }           
           }
           // bug 11354 fix
            for(CLQ_Program__c cmail: lstAllprograms){     
               
                List<String> emailAddress = new List<String>();
                if(!mapProgramToRole.isEmpty() && mapProgramToRole.ContainsKey(cmail.Id)){
                    //System.debug('IF PROGRAM MATCHES');                  
                    for(CLQ_Role__c role : mapProgramToRole.get(cmail.Id)){
                      //System.debug('role.recordTypeid='+ role.recordTypeid);                      
                      //System.debug('role.Role_Type__c='+ role.Role_Type__c);
                        if(role.recordTypeid == portalRoleRecId && role.Role_Type__c == ODE && SUTQPortalRoles.contains(role.Portal_Roles__c)  && role.ODE_Role_Type__c == 'Site Role'){ // Updating for 14919 - Corrected Role type to check Site role
                            emailAddress.add(role.CLQ_Contact__r.EMAIL);                             
                        }
                    }       
                } else if((cmail.recordTypeid == PreSchoolId || cmail.recordTypeid == SACCId)&& (cmail.SUTQ_Reviewer__r.email != null)) {             //11354
                    emailAddress.add(cmail.SUTQ_Reviewer__r.email);  
                	                                                                                               
                }                                          
               
              // bug 11354 fix end
 
                if(mapAccountToRole.ContainsKey(cmail.CLQ_Associated_Organization__r.Id)){
                    System.debug('IF ACCOUNTS MATCHES');
                    for(CLQ_Role__c role : mapAccountToRole.get(cmail.CLQ_Associated_Organization__r.Id)){
                        if(cmail.recordTypeId == PreSchoolId && role.Secondary_Role__c.contains(Label.SecondaryRolePreSchool)){
                            emailAddress.add(role.CLQ_Contact__r.EMAIL);
                            //System.debug('EMAIL FROM Account'+ emailAddress);
                        }
                        else if(cmail.recordTypeId == SACCId && role.Secondary_Role__c.contains(Label.SecondaryRoleSACC)){
                            emailAddress.add(role.CLQ_Contact__r.EMAIL);
                            //System.debug('EMAIL FROM Account SACC'+ emailAddress);
                        }
                    }
                }
                
                if(!finalMapPTtoEmail.ContainsKey(cmail.Id)){
                    finalMapPTtoEmail.put(cmail.Id,emailAddress);
                }
                else{
                    List<String> emails = finalMapPTtoEmail.get(cmail.Id);
                    emails.addAll(emailAddress);
                    finalMapPTtoEmail.put(cmail.Id,emails);
                }
                //System.debug('Final map '+ finalMapPTtoEmail);                
            }
        }
        Catch(Exception e){
            System.debug('Error'+ e.getMessage());
        }  
               
        //System.debug('EMAIL finalMapPTtoEmail ==>' + finalMapPTtoEmail);
        return finalMapPTtoEmail ;
    }

   
	//CR-11200 Starts
	//Method to fetch all JFS Portal Roles
  	public static Map<Id, List<CLQ_Role__c>>  fetchAllJFSPortalRoleEmail (set<Id> setProgramID, set<Id> setPrgTransId){
    	Map<Id, List<CLQ_Role__c>> mapPrgPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<String> lstPortalRoles = Label.JFS_Portal_Roles.split(',');
    	String strQuery = Label.JFSPortalRole_Query;
    	
    	//TODO: update query in label, then do check for program type in following for loop, add 4 parameters in PB
    	//System.debug('strQuery ---'+strQuery);
    
    	for(CLQ_Role__c roleObj : (List <CLQ_Role__c>)Database.Query(strQuery)){
            //System.debug('Role:'+roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c);
      		if(mapPrgPortalRoleEmail.containsKey(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c)){
    			mapPrgPortalRoleEmail.get(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c).add(roleObj);
  			}else{
    			mapPrgPortalRoleEmail.put(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c, new List<CLQ_Role__c>{roleObj});
  			}              
    	} 
    
    	//system.debug('Map JSF Portal Role -- '+mapPrgPortalRoleEmail);
    
    	return mapPrgPortalRoleEmail;
  	}
  	
  	//12166 Day Camp get role emails start
  	public static Map<Id, List<CLQ_Role__c>> fetchAllDayCampRoleEmail (set<Id> setProgramID, set<Id> setPrgTransId){
    	Map<Id, List<CLQ_Role__c>> mapPrgPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	//create new labels for DC
    	List<String> lstPortalRoles = Label.DC_Portal_Roles.split(',');
    	String strQuery = Label.DCPortalRole_Query;
    	
    	//System.debug('strQuery ---'+strQuery);
    	
    	for(CLQ_Role__c roleObj : (List <CLQ_Role__c>)Database.Query(strQuery)){
    		

			if(mapPrgPortalRoleEmail.containsKey(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c)){
    			mapPrgPortalRoleEmail.get(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c).add(roleObj);
  			}else{
    			mapPrgPortalRoleEmail.put(roleObj.CLQ_Program_Transaction_Source__r.CLQ_Program__c, new List<CLQ_Role__c>{roleObj});
  			}  
                
    	} 
    
    	//system.debug('Map DC Portal Role -- '+mapPrgPortalRoleEmail);
    
    	return mapPrgPortalRoleEmail;
  	}
  	//12166 end
  	
  	
  
  	//Method to fetch all Email Recipients from custom setting
  	public static Map<String, OCLQS_Email_Recipients__c> fetchEmailTemplateRecipient(){
	    Map<String, OCLQS_Email_Recipients__c> mapEmailTempRecpnt = new Map<String, OCLQS_Email_Recipients__c>();
    
    	for(OCLQS_Email_Recipients__c oer : OCLQS_Email_Recipients__c.getall().values()){
      		mapEmailTempRecpnt.put(oer.Template_Name__c, oer);
    	}
    
    	return mapEmailTempRecpnt;
  	}
  
	//Method to send email alert for JFS Program Transaction
	
	//12166 Updated parameters to include record type
	private static void sendJFSEmailForPrgTransaction(Map<Id, String> mapPrgTransEmailTemplate, String RecordType){
		Set<Id> setPrgTransId = new Set<Id>();
    	Map<Id, List<CLQ_Program_Transaction__c>> mapPrgWithPrgTrans = new Map<Id, List<CLQ_Program_Transaction__c>>();
    	Map<String, Id> mapTemplate = new Map<String, Id>();
    	Map<Id, List<CLQ_Role__c>> mapPrgPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    
    	try{
      		setPrgTransId.addAll(mapPrgTransEmailTemplate.keySet());
      		
      		//System.debug('setPrgTransId has values--->' + setPrgTransId);
      		//System.debug('mapPrgTransEmailTemplate is not empty--->' + mapPrgTransEmailTemplate);
      		//System.debug('mapPrgTransEmailTemplate values--->' + mapPrgTransEmailTemplate.values());
      
			if(!mapPrgTransEmailTemplate.isEmpty()){
        		for(EmailTemplate et: [select Id,Name,DeveloperName from EmailTemplate where DeveloperName IN : mapPrgTransEmailTemplate.values()]){
          			//System.debug('et--->' + et);
          			mapTemplate.put(et.DeveloperName, et.Id);
        		}
        		
        		//System.debug('mapTemplate--->' + mapTemplate);
        
				String ptQuery = 'Select Id, CLQ_Program__c, '+Label.PT_EmailAlert_Fields+' from CLQ_Program_Transaction__c where ID IN : setPrgTransId';
	        
				for(CLQ_Program_Transaction__c ptObj : (List<CLQ_Program_Transaction__c>)Database.Query(ptQuery)){
                
	                if(mapPrgWithPrgTrans.containskey(ptObj.CLQ_Program__c)){
						mapPrgWithPrgTrans.get(ptObj.CLQ_Program__c).add(ptObj);
					}else{
						mapPrgWithPrgTrans.put(ptObj.CLQ_Program__c, new List<CLQ_Program_Transaction__c> {ptObj});
					}
				}
        		
        		//TODO: add condityion here if not Day Camp use this method, else use new created method
        		
        		//System.debug('mapPrgWithPrgTrans--->' + mapPrgWithPrgTrans);
        		
        		if(RecordType == DAYCAMP) {
        			mapPrgPortalRoleEmail = fetchAllDayCampRoleEmail(mapPrgWithPrgTrans.keySet(), setPrgTransId);
        		} else {
        			mapPrgPortalRoleEmail = fetchAllJFSPortalRoleEmail(mapPrgWithPrgTrans.keySet(), setPrgTransId);
        		}

        
        		//Setting email content
				if(!mapTemplate.isEmpty()){
					//System.debug('mapTemplate is not empty --->' + mapTemplate);
          			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
          			Contact cnt = [SELECT Id FROM Contact WHERE Email!=null AND Email = 'NOREPLY@TEST.COM' Limit 1];
          			Map<String, OCLQS_Email_Recipients__c> mapEmailRecipient = fetchEmailTemplateRecipient();
          
					for(Id prgId : mapPrgWithPrgTrans.keySet()){
						for(CLQ_Program_Transaction__c prgTrans : mapPrgWithPrgTrans.get(prgId)){
							
							Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
							Id TemplateId = mapTemplate.get(mapPrgTransEmailTemplate.get(prgTrans.Id));	
							List<String> emailToList = new List<String>();
							List<String> emailCCList = new List<String>();
							List<String> emailBCCList = new List<String>();
							Set<String> emailToSet = new Set<String>();
  							Set<String> emailCCSet = new Set<String>();
  							Set<String> emailBCCSet = new Set<String>(); 
  							Set<String> setToPortalRoles = new Set<String>();
  							Set<String> setCCPortalRoles = new Set<String>();
  							OCLQS_Email_Recipients__c emailRcpnt = mapEmailRecipient.get(mapPrgTransEmailTemplate.get(prgTrans.Id));
  							//System.debug('emailRcpnt--->' + emailRcpnt);
              
							if(owea.size() > 0 ) {
								msg.setOrgWideEmailAddressId(owea.get(0).Id);
              				}
              
							msg.settargetObjectID(cnt.id);            
							msg.setwhatID(prgTrans.Id);
              				msg.setTemplateId(TemplateId);
              
							if(emailRcpnt != null){
								//Setting Prog Transaction fields as email recipients
                				if(emailRcpnt.To__c != null){
                                    //System.debug('emailRcpnt-->' +emailRcpnt.To__c);
                  					for(String toEmail : emailRcpnt.To__c.split(',')){
                                        //System.debug('toEmail-->' +toEmail);
                    					if(toEmail.indexOf(DOT)>0){
                      						String []emailField = toEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailToSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1]));
                                            }
                    						}else{
                                                if(toEmail != LICENSING_MANAGER_EMAIL && prgTrans.get(toEmail) != null){
                                                    emailToSet.add((String)prgTrans.get(toEmail));
                                                }
                    						}
                    
										if(toEmail == LICENSING_MANAGER_EMAIL && prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email != null){
                      						emailToSet.add((String)prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email);
                    					}
                  					}
                				}
                		
	                			if(emailRcpnt.CC__c != null){
	                  				for(String ccEmail : emailRcpnt.CC__c.split(',')){
	                    				if(ccEmail.indexOf(DOT)>0){
	                      					String []emailField = ccEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                               emailCCSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1])); 
                                            }
	                    					}else{
                                                if(ccEmail != LICENSING_MANAGER_EMAIL && prgTrans.get(ccEmail) != null){
                                                    emailCCSet.add((String)prgTrans.get(ccEmail));
                                                }
	                    					}
	                    				
	                    				if(ccEmail == LICENSING_MANAGER_EMAIL && prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email !=null){
	                      					emailCCSet.add((String)prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email);
	                    				}  
	                  				}
	                			}
                		
	                			if(emailRcpnt.BCC__c != null){
	                  				for(String bccEmail : emailRcpnt.BCC__c.split(',')){
	                    				if(bccEmail.indexOf(DOT)>0){
	                      					String []emailField = bccEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailBCCSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1]));
                                            }
	                    					}else{
                                                if(prgTrans.get(bccEmail) != null){
                                                    emailBCCSet.add((String)prgTrans.get(bccEmail));
                                                }
	                    					}
	                  				}
	                			}         
                  				
                  				//Setting portal roles as email recipients
                  				if(mapPrgPortalRoleEmail.containsKey(prgId)){
                  					//System.debug('came here--->');
									for(CLQ_Role__c roleObj : mapPrgPortalRoleEmail.get(prgId)){
										//System.debug('roleObj inside setting roles as email recp-->');
			                			if(emailRcpnt.To_Role__c != null){
			                    			setToPortalRoles.addAll(emailRcpnt.To_Role__c.split(','));
			                    			//System.debug('setToPortalRoles--->' + setToPortalRoles);
				                  			if(setToPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
				                    			emailToSet.add(roleObj.CLQ_Contact__r.Email);
				                    			//System.debug('emailToSet--->' + emailToSet);
				                  			}
				                  			//12166 condition to add DC portal roles
				                  			if(RecordType == DAYCAMP && setToPortalRoles.contains(roleObj.CLQ_Role__c) && roleObj.CLQ_Contact__r.Email != null){ 
				                    			emailToSet.add(roleObj.CLQ_Contact__r.Email);
				                    			//System.debug('main emailToSet--->' + emailToSet);
				                  			}
			                			}  
			                
			                			if(emailRcpnt.CC_Role__c != null){  
			                				//System.debug('emailRcpnt.CC_Role__c != null-->');      
			                  				setCCPortalRoles.addAll(emailRcpnt.CC_Role__c.split(','));
			                  				if(setCCPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
			                    				emailCCSet.add(roleObj.CLQ_Contact__r.Email);
			                  				}
			                  				//System.debug('roleObj--->' + roleObj);
			                  				//12166 condition to add DC portal roles
				                  			if(RecordType == DAYCAMP && setCCPortalRoles.contains(roleObj.CLQ_Role__c) && roleObj.CLQ_Contact__r.Email != null){ 
				                    			emailCCSet.add(roleObj.CLQ_Contact__r.Email);
				                    			//System.debug('CC emailToSet--->' + emailToSet);
				                  			}
			                			}
			              			}
                  				}
	              			
								emailToList.addAll(emailToSet);
		              			emailCCList.addAll(emailCCSet);
		              			emailBCCList.addAll(emailBCCSet);
		              
				              	
		              
								if(!emailToList.isEmpty()){
		                			msg.setToAddresses(emailToList);
		              			}
		              
								if(!emailCCList.isEmpty()){                 
									msg.setCcAddresses(emailCCList);
		            			}
		            
		            			if(!emailBCCList.isEmpty()){                 
		                  			msg.setBccAddresses(emailBCCList);
		            			}                        
		              		}
	              
							lstMails.add(msg);
						}
					}
          
					//Sending Email
					//system.debug('lstMails ---'+lstMails);
					if(!lstMails.isEmpty()){
						Messaging.sendEmail(lstMails);
		          	}
				}
			}
    	}catch(Exception e){
			//system.debug('Exception::'+e.getMessage()+'Line ---'+e.getLineNumber());
			Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}
  
	//Method to send email alert for JFS Corrective Action Plan
	
  	private static void sendJFSEmailForCAP(Map<Id, String> mapCAPEmailTemplate){
    
    	Set<Id> setCAPID = new Set<Id>();
    	Map<String, Id> mapTemplate = new Map<String, Id>();
    	Map<Id, List<CLQ_Corrective_Action_Plan__c>> mapPrgWithCAP = new Map<Id, List<CLQ_Corrective_Action_Plan__c>>();
    	Map<Id, List<CLQ_Role__c>> mapPrgPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    
    	try{
      		setCAPID.addAll(mapCAPEmailTemplate.keySet());
      
      		if(!mapCAPEmailTemplate.isEmpty()){
        		for(EmailTemplate et: [select Id,Name,DeveloperName from EmailTemplate where DeveloperName IN : mapCAPEmailTemplate.values()]){
          			mapTemplate.put(et.DeveloperName, et.Id);
        		}
        
        		String capQuery = 'Select Id, CLQ_Program__c, '+Label.CAP_EmailAlert_Fields+' from CLQ_Corrective_Action_Plan__c where ID IN : setCAPID';
        		
        		for(CLQ_Corrective_Action_Plan__c cap : (List<CLQ_Corrective_Action_Plan__c>)Database.Query(capQuery)){
                	if(mapPrgWithCAP.containskey(cap.CLQ_Program__c)){
                  		mapPrgWithCAP.get(cap.CLQ_Program__c).add(cap);
                	}else{
                  		mapPrgWithCAP.put(cap.CLQ_Program__c, new List<CLQ_Corrective_Action_Plan__c> {cap});
                	}
        		}        
        
        		mapPrgPortalRoleEmail = fetchAllJFSPortalRoleEmail(mapPrgWithCAP.keySet(), new Set<Id>());
        
        		//Setting email content
        
        		if(!mapTemplate.isEmpty()){
          			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
          			Contact cnt = [SELECT Id FROM Contact WHERE Email!=null AND Email = 'NOREPLY@TEST.COM' Limit 1];
          			Map<String, OCLQS_Email_Recipients__c> mapEmailRecipient = fetchEmailTemplateRecipient();
          
          			for(Id prgId : mapPrgWithCAP.keySet()){
            			for(CLQ_Corrective_Action_Plan__c cap : mapPrgWithCAP.get(prgId)){
              				Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
              				Id TemplateId = mapTemplate.get(mapCAPEmailTemplate.get(cap.Id));
  							List<String> emailToList = new List<String>();
							List<String> emailCCList = new List<String>();
							List<String> emailBCCList = new List<String>();
							Set<String> emailToSet = new Set<String>();
							Set<String> emailCCSet = new Set<String>(); 
							Set<String> emailBCCSet = new Set<String>(); 
							Set<String> setToPortalRoles = new Set<String>();
							Set<String> setCCPortalRoles = new Set<String>();
							OCLQS_Email_Recipients__c emailRcpnt = mapEmailRecipient.get(mapCAPEmailTemplate.get(cap.Id));
              
							if(owea.size() > 0 ) {
								msg.setOrgWideEmailAddressId(owea.get(0).Id);
              				}
              
							msg.settargetObjectID(cnt.id);            
							msg.setwhatID(cap.Id);
							msg.setTemplateId(TemplateId);
							//system.debug('emailRcpnt --- '+emailRcpnt);
              
							if(emailRcpnt != null){
								//Setting CAP fields as email recipients
								if(emailRcpnt.To__c != null){
									for(String toEmail : emailRcpnt.To__c.split(',')){
										if(toEmail.indexOf(DOT)>0){
											String []emailField = toEmail.split('\\.');
                                            if(cap.getSobject(emailField[0]) != null && cap.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailToSet.add((String)cap.getSobject(emailField[0]).get(emailField[1]));
                                            }
                    					}else{
                                            if(cap.get(toEmail) != null){
                                                emailToSet.add((String)cap.get(toEmail));
                                            }
                    					}
                  					}
                				}
                				
                				if(emailRcpnt.CC__c != null){
                  					for(String ccEmail : emailRcpnt.CC__c.split(',')){
                    					if(ccEmail.indexOf(DOT)>0){
                      						String []emailField = ccEmail.split('\\.');
                                            if(cap.getSobject(emailField[0]) != null && cap.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailCCSet.add((String)cap.getSobject(emailField[0]).get(emailField[1]));
                                            }
                    						}else{
                                                if(cap.get(ccEmail) != null){
                                                    emailCCSet.add((String)cap.get(ccEmail));
                                                }
                        							
                    						}
                  					}
                				} 
                
                				if(emailRcpnt.BCC__c != null){
                  					for(String bccEmail : emailRcpnt.BCC__c.split(',')){
                    					if(bccEmail.indexOf(DOT)>0){
                      						String []emailField = bccEmail.split('\\.');
                                            if(cap.getSobject(emailField[0]) != null && cap.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailBCCSet.add((String)cap.getSobject(emailField[0]).get(emailField[1]));
                                            }
                    					}else{
                                            if(cap.get(bccEmail) != null){
                                                emailBCCSet.add((String)cap.get(bccEmail));
                                            }
                						}
                  					}
                				}                
                
                				//Setting portal roles as email recipients
                				if(mapPrgPortalRoleEmail.containsKey(prgId)){
	                          		for(CLQ_Role__c roleObj : mapPrgPortalRoleEmail.get(prgId)){
	                            		if(emailRcpnt.To_Role__c != null){
	                                		setToPortalRoles.addAll(emailRcpnt.To_Role__c.split(','));
	                              			if(setToPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
	                                			emailToSet.add(roleObj.CLQ_Contact__r.Email);
	                              			}
	                            		}
	                            
	                            		if(emailRcpnt.CC_Role__c != null){        
	                              			setCCPortalRoles.addAll(emailRcpnt.CC_Role__c.split(','));
	                              			if(setCCPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
	                                			emailCCSet.add(roleObj.CLQ_Contact__r.Email);
	                              			}
	                            		}
	                          		}
                				}
                          		
                          		emailToList.addAll(emailToSet);
                          		emailCCList.addAll(emailCCSet);
                          		emailBCCList.addAll(emailBCCSet);
	                          
								
								if(!emailToList.isEmpty()){
									msg.setToAddresses(emailToList);
								}
                          
								if(!emailCCList.isEmpty()){                 
                              		msg.setCcAddresses(emailCCList);
                        		}
                         		
                         		if(!emailBCCList.isEmpty()){                 
                              		msg.setBccAddresses(emailBCCList);
                    			}                        
              				}
              
							lstMails.add(msg);
            			}
          			}
          
          			//Sending Email
          			//system.debug('lstMails ---'+lstMails);
          			if(!lstMails.isEmpty()){
            			Messaging.sendEmail(lstMails);
          			}
        		}
      		}
		}catch(Exception e){
            //system.debug('Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
    	}
 	}
  
	//Method to send email alert for JFS Corrective Action Plan
	
	private static void sendJFSEmailForProgram(Map<Id, String> mapProgramEmailTemplate){
    
    	Map<String, Id> mapTemplate = new Map<String, Id>();
    	Map<Id, List<CLQ_Role__c>> mapPrgPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
		Set<Id> setProgId = new Set<Id>();
    
    	try{
      		if(!mapProgramEmailTemplate.isEmpty()){
        		setProgId.addAll(mapProgramEmailTemplate.keySet());
        
        		for(EmailTemplate et: [select Id,Name,DeveloperName from EmailTemplate where DeveloperName IN : mapProgramEmailTemplate.values()]){
          			mapTemplate.put(et.DeveloperName, et.Id);
        		}
        
        		mapPrgPortalRoleEmail = fetchAllJFSPortalRoleEmail(mapProgramEmailTemplate.keySet(), new Set<Id>());
        
        		//Setting email content
        
	        	if(!mapProgramEmailTemplate.isEmpty()){
	          		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
	          		Contact cnt = [SELECT Id FROM Contact WHERE Email!=null AND Email = 'NOREPLY@TEST.COM' Limit 1];
	          		Map<String, OCLQS_Email_Recipients__c> mapEmailRecipient = fetchEmailTemplateRecipient();
	          
	          		String prgQuery = SELECT_ID +Label.Prg_EmailAlert_Fields + FROM_CLQ_PROGRAM;
	          
	          		for(CLQ_Program__c prg : (List<CLQ_Program__c>)Database.Query(prgQuery)){
	            
	            		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
	            		Id TemplateId = mapTemplate.get(mapProgramEmailTemplate.get(prg.Id));
			            List<String> emailToList = new List<String>();
			            List<String> emailCCList = new List<String>();
			            List<String> emailBCCList = new List<String>();
			            Set<String> emailToSet = new Set<String>();
			            Set<String> emailCCSet = new Set<String>();
			            Set<String> emailBCCSet = new Set<String>(); 
			            Set<String> setToPortalRoles = new Set<String>();
			            Set<String> setCCPortalRoles = new Set<String>();
			            OCLQS_Email_Recipients__c emailRcpnt = mapEmailRecipient.get(mapProgramEmailTemplate.get(prg.Id));
	            
	            		if(owea.size() > 0 ) {
							msg.setOrgWideEmailAddressId(owea.get(0).Id);
	            		}
	            
	            		msg.settargetObjectID(cnt.id);  
	            		msg.setwhatID(prg.Id);
	            		msg.setTemplateId(TemplateId);
	            		
	            		//system.debug('emailRcpnt --- '+emailRcpnt);
	            
	            		if(emailRcpnt != null){
	            			//Setting Prog fields as email recipients
	              			if(emailRcpnt.To__c != null){
	                			for(String toEmail : emailRcpnt.To__c.split(',')){
	                  				if(toEmail.indexOf(DOT)>0){
	                    				String []emailField = toEmail.split('\\.');
                                        if(prg.getSobject(emailField[0]) != null && prg.getSobject(emailField[0]).get(emailField[1]) != null){
                                            emailToSet.add((String)prg.getSobject(emailField[0]).get(emailField[1]));
                                        }
	                  				}else{
                                        if(prg.get(toEmail) != null){
                                            emailToSet.add((String)prg.get(toEmail));
                                        }
	                      					
	                  				}
	                			}
	              			}
	              			
	              			if(emailRcpnt.CC__c != null){
	                			for(String toEmail : emailRcpnt.CC__c.split(',')){
	                  				if(toEmail.indexOf(DOT)>0){
	                    				String []emailField = toEmail.split('\\.');
                                        if(prg.getSobject(emailField[0]) != null && prg.getSobject(emailField[0]).get(emailField[1]) != null){
                                            emailCCSet.add((String)prg.getSobject(emailField[0]).get(emailField[1]));
                                        }
	              					}else{
                                        if(prg.get(toEmail) != null){
                                            emailCCSet.add((String)prg.get(toEmail));
                                        }
	                  						
	              					}
	                			}	
	              			}
	              		
	              			if(emailRcpnt.BCC__c != null){
	                			for(String toEmail : emailRcpnt.BCC__c.split(',')){
	                  				if(toEmail.indexOf(DOT)>0){
	                    				String []emailField = toEmail.split('\\.');
                                        if(prg.getSobject(emailField[0]) != null && prg.getSobject(emailField[0]).get(emailField[1]) != null){
                                            emailBCCSet.add((String)prg.getSobject(emailField[0]).get(emailField[1]));
                                        }
	                  					}else{
                                            if(prg.get(toEmail) != null){
                                                emailBCCSet.add((String)prg.get(toEmail));
                                            }
	                      						
	                  					}
	                			}
	              			}
	                        
	                        //Setting portal roles as email recipients
	                        if(mapPrgPortalRoleEmail.containsKey(prg.Id)){
		                        for(CLQ_Role__c roleObj : mapPrgPortalRoleEmail.get(prg.Id)){  
		                			if(emailRcpnt.To_Role__c != null){
										setToPortalRoles.addAll(emailRcpnt.To_Role__c.split(','));
										if(setToPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
											emailToSet.add(roleObj.CLQ_Contact__r.Email);
										}
									}  
		                            
		                          	if(emailRcpnt.CC_Role__c != null){        
		                            	setCCPortalRoles.addAll(emailRcpnt.CC_Role__c.split(','));
		                        		if(setCCPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
		                          			emailCCSet.add(roleObj.CLQ_Contact__r.Email);
		                        		}
		                          	}
		                        }
	            			}
	                          
	                        emailToList.addAll(emailToSet);
	                        emailCCList.addAll(emailCCSet);
	                        emailBCCList.addAll(emailBCCSet);
	                        
	                       
	                        
	                        if(!emailToList.isEmpty()){
								msg.setToAddresses(emailToList);
							}
	                        
	                      	if(!emailCCList.isEmpty()){                 
								msg.setCcAddresses(emailCCList);
							}
							
							if(!emailBCCList.isEmpty()){                 
								msg.setBccAddresses(emailBCCList);
							}                        
						}
	            
	            		lstMails.add(msg);
	          		}
	          
					//Sending Email
	          		//system.debug('lstMails ---'+lstMails);
	          		if(!lstMails.isEmpty()){
	            		Messaging.sendEmail(lstMails);
	          		}
				}
			}
		}catch(Exception e){
            //system.debug('Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}    
	//CR-11200 Ends
  
	//11815 Starts
	//Method update Transaction/ Registration status to 'Closed by Sytem' and send notification email for JFS prog
	
	public static void sendJFSClosedBySystemAlert(List<CLQ_Program_Transaction__c> lstProgTrans, String strTemplate){
		List<CLQ_Program_Transaction__c> lstProgTransToUdpate = new List<CLQ_Program_Transaction__c>();
		Map<Id, String> mapPrgTransEmailTemplate = new Map<Id, String>();
		
		try{
			for(CLQ_Program_Transaction__c pt : lstProgTrans){
				pt.CLQ_Registration_Status__c= CLOSED_BY_SYSTEM;
				pt.CLQ_Transaction_Status__c = CLOSED_BY_SYSTEM;
				
				lstProgTransToUdpate.add(pt);
				
				mapPrgTransEmailTemplate.put(pt.Id, strTemplate);
			}
			
			if(!lstProgTransToUdpate.isEmpty() && !mapPrgTransEmailTemplate.isEmpty()){
				update lstProgTransToUdpate;
				
				sendJFSEmailForPrgTransaction(mapPrgTransEmailTemplate, ''); //12166 Updated call since method parameters changed, passing blank string since not Day Camp
			}
			
		}catch(Exception e){
            //system.debug('sendJFSClosedBySystemAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}
	
	//Method update Transaction/ Registration status to 'Closed by Sytem' and send notification email for ODE prog	
	
	public static void sendODEClosedBySystemAlert(List<CLQ_Program_Transaction__c> lstProgTrans, String strTemplate){
		//system.debug('sendODEClosedBySystemAlert --');
		List<CLQ_Program_Transaction__c> lstProgTransToUdpate = new List<CLQ_Program_Transaction__c>();
		Map<Id, String> mapPrgTransEmailTemplate = new Map<Id, String>();
		
		try{
			for(CLQ_Program_Transaction__c pt : lstProgTrans){
				pt.CLQ_Registration_Status__c= CLOSED_BY_SYSTEM;
				pt.CLQ_Transaction_Status__c = CLOSED_BY_SYSTEM;
				pt.CLQ_Check_for_120_Days__c = true;
				
				lstProgTransToUdpate.add(pt);
				
				mapPrgTransEmailTemplate.put(pt.Id, strTemplate);
			}
			//system.debug('lstProgTransToUdpate --- '+lstProgTransToUdpate);
			//system.debug('mapPrgTransEmailTemplate --- '+mapPrgTransEmailTemplate);
			
			if(!lstProgTransToUdpate.isEmpty() && !mapPrgTransEmailTemplate.isEmpty()){
				update lstProgTransToUdpate;
				
				sendODEEmailForPrgTransaction(mapPrgTransEmailTemplate);
			}
			
		}catch(Exception e){
            //system.debug('sendODEClosedBySystemAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}
	
	//Method to fetch all ODE Portal Roles
	private static Map<Id, List<CLQ_Role__c>>  fetchAllODEPortalRoleEmail (set<Id> setProgramID, set<Id> setOrgId){
		Map<Id, List<CLQ_Role__c>> mapODEPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<String> lstPortalRoles = Label.ODE_Portal_Roles.split(',');
    	String strQuery = Label.ODEPortalRole_Query;
    	Id orgId;
    
    	//System.debug('ODE Portal Role Query ---'+strQuery);
    
		for(CLQ_Role__c roleObj : (List <CLQ_Role__c>)Database.Query(strQuery)){
			if(roleObj.CLQ_Organization__c != null){
				orgId = roleObj.CLQ_Organization__c;
			}else if(roleObj.CLQ_Program__r.CLQ_Associated_Organization__c != null){
				orgId = roleObj.CLQ_Program__r.CLQ_Associated_Organization__c;
			}
			
      		if(mapODEPortalRoleEmail.containsKey(orgId)){
        		mapODEPortalRoleEmail.get(orgId).add(roleObj);
      		}else{
        		mapODEPortalRoleEmail.put(orgId, new List<CLQ_Role__c>{roleObj});
      		}                
    	} 
    
    	//system.debug('Map ODE Portal Role -- '+mapODEPortalRoleEmail);
    
    	return mapODEPortalRoleEmail;
	}	
	
	//Method to send email alert for ODE Program Transaction
	private static void sendODEEmailForPrgTransaction(Map<Id, String> mapPrgTransEmailTemplate){
		
		//system.debug('sendODEEmailForPrgTransaction --');
		Set<Id> setPrgTransId = new Set<Id>();
		Set<Id> setPrgId = new Set<Id>();
    	Map<Id, List<CLQ_Program_Transaction__c>> mapOrgWithPrgTrans = new Map<Id, List<CLQ_Program_Transaction__c>>();
    	Map<String, Id> mapTemplate = new Map<String, Id>();
    	Map<Id, List<CLQ_Role__c>> mapPortalRoleEmail = new Map<Id, List<CLQ_Role__c>>();
    	List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
    
    	try{
      		setPrgTransId.addAll(mapPrgTransEmailTemplate.keySet());
      
			if(!mapPrgTransEmailTemplate.isEmpty()){
        		for(EmailTemplate et: [select Id,Name,DeveloperName from EmailTemplate where DeveloperName IN : mapPrgTransEmailTemplate.values()]){
          			mapTemplate.put(et.DeveloperName, et.Id);
        		}
        
				String ptQuery = 'Select Id, CLQ_Program__c, CLQ_Associated_Organization__c, '+Label.PT_EmailAlert_Fields+' from CLQ_Program_Transaction__c where ID IN : setPrgTransId';
	        
				for(CLQ_Program_Transaction__c ptObj : (List<CLQ_Program_Transaction__c>)Database.Query(ptQuery)){
                	
                	setPrgId.add(ptObj.CLQ_Program__c);
                	
	                if(mapOrgWithPrgTrans.containskey(ptObj.CLQ_Associated_Organization__c)){
						mapOrgWithPrgTrans.get(ptObj.CLQ_Associated_Organization__c).add(ptObj);
					}else{
						mapOrgWithPrgTrans.put(ptObj.CLQ_Associated_Organization__c, new List<CLQ_Program_Transaction__c> {ptObj});
					}
				}
        		//system.debug('mapOrgWithPrgTrans --- '+mapOrgWithPrgTrans);
				mapPortalRoleEmail = fetchAllODEPortalRoleEmail(setPrgId, mapOrgWithPrgTrans.keySet());
        
        		//Setting email content
				if(!mapTemplate.isEmpty()){
          			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
          			Contact cnt = [SELECT Id FROM Contact WHERE Email!=null AND Email = 'NOREPLY@TEST.COM' Limit 1];
          			Map<String, OCLQS_Email_Recipients__c> mapEmailRecipient = fetchEmailTemplateRecipient();
          
					for(Id orgId : mapOrgWithPrgTrans.keySet()){
						for(CLQ_Program_Transaction__c prgTrans : mapOrgWithPrgTrans.get(orgId)){
							Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
							Id TemplateId = mapTemplate.get(mapPrgTransEmailTemplate.get(prgTrans.Id));	
							List<String> emailToList = new List<String>();
							List<String> emailCCList = new List<String>();
							List<String> emailBCCList = new List<String>();
							Set<String> emailToSet = new Set<String>();
  							Set<String> emailCCSet = new Set<String>();
  							Set<String> emailBCCSet = new Set<String>(); 
  							Set<String> setToPortalRoles = new Set<String>();
  							Set<String> setCCPortalRoles = new Set<String>();
  							OCLQS_Email_Recipients__c emailRcpnt = mapEmailRecipient.get(mapPrgTransEmailTemplate.get(prgTrans.Id));
              
							if(owea.size() > 0 ) {
								msg.setOrgWideEmailAddressId(owea.get(0).Id);
              				}
              
							msg.settargetObjectID(cnt.id);            
							msg.setwhatID(prgTrans.Id);
              				msg.setTemplateId(TemplateId);
              
							if(emailRcpnt != null){
								//Setting Prog Transaction fields as email recipients
                				if(emailRcpnt.To__c != null){
                  					for(String toEmail : emailRcpnt.To__c.split(',')){
                    					if(toEmail.indexOf(DOT)>0){
                      						String []emailField = toEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailToSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1]));
                                            }
                    						}else{
                                                if(toEmail != LICENSING_MANAGER_EMAIL && prgTrans.get(toEmail) != null){
                                                    emailToSet.add((String)prgTrans.get(toEmail));
                                                }
                    						}
                    
										if(toEmail == LICENSING_MANAGER_EMAIL && prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email != null){
                      						emailToSet.add((String)prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email);
                    					}
                  					}
                				}
                		
	                			if(emailRcpnt.CC__c != null){
	                  				for(String ccEmail : emailRcpnt.CC__c.split(',')){
	                    				if(ccEmail.indexOf(DOT)>0){
	                      					String []emailField = ccEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailCCSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1]));
                                            }
	                    					}else{
                                                if(ccEmail != LICENSING_MANAGER_EMAIL && prgTrans.get(ccEmail) != null){
                                                    emailCCSet.add((String)prgTrans.get(ccEmail));
                                                }	
	                    					}
	                    				
	                    				if(ccEmail == LICENSING_MANAGER_EMAIL && prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email !=null){
	                      					emailCCSet.add((String)prgTrans.CLQ_Program__r.CLQ_Licensing_Specialist__r.Manager.Email);
	                    				}  
	                  				}
	                			}
                		
	                			if(emailRcpnt.BCC__c != null){
	                  				for(String bccEmail : emailRcpnt.BCC__c.split(',')){
	                    				if(bccEmail.indexOf(DOT)>0){
	                      					String []emailField = bccEmail.split('\\.');
                                            if(prgTrans.getSobject(emailField[0]) != null && prgTrans.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailBCCSet.add((String)prgTrans.getSobject(emailField[0]).get(emailField[1]));
                                            }
	                    					}else{
                                                if(prgTrans.get(bccEmail) != null){
                                                    emailBCCSet.add((String)prgTrans.get(bccEmail));
                                                }
	                        						
	                    					}
	                  				}
	                			}         
                  				
                  				//Setting portal roles as email recipients
                  				if(mapPortalRoleEmail.containsKey(orgId)){
									for(CLQ_Role__c roleObj : mapPortalRoleEmail.get(orgId)){
			                			if(emailRcpnt.To_Role__c != null){
			                    			setToPortalRoles.addAll(emailRcpnt.To_Role__c.split(','));
				                  			if(setToPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
				                    			emailToSet.add(roleObj.CLQ_Contact__r.Email);
				                  			}
			                			}  
			                
			                			if(emailRcpnt.CC_Role__c != null){        
			                  				setCCPortalRoles.addAll(emailRcpnt.CC_Role__c.split(','));
			                  				if(setCCPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
			                    				emailCCSet.add(roleObj.CLQ_Contact__r.Email);
			                  				}
			                			}
			              			}
								}
	              			
								emailToList.addAll(emailToSet);
		              			emailCCList.addAll(emailCCSet);
		              			emailBCCList.addAll(emailBCCSet);
		              
				              	
		              
								if(!emailToList.isEmpty()){
		                			msg.setToAddresses(emailToList);
		              			}
		              
								if(!emailCCList.isEmpty()){                 
									msg.setCcAddresses(emailCCList);
		            			}
		            
		            			if(!emailBCCList.isEmpty()){                 
		                  			msg.setBccAddresses(emailBCCList);
		            			}                        
		              		}
	              
							lstMails.add(msg);
						}
					}
          
					//Sending Email
					//system.debug('lstMails ---'+lstMails);
					if(!lstMails.isEmpty()){
						Messaging.sendEmail(lstMails);
		          	}
				}
			}
    	}catch(Exception e){
			//system.debug('Exception::'+e.getMessage()+'Line ---'+e.getLineNumber());
			Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}	
	//11815 Ends   
	
	//11799 Starts
	//Method to send CAP Over due notification to ODE/ JFS Prg 	
	public static void sendODECAPOverDueEmailAlert(List<CLQ_Corrective_Action_Plan__c> lstCAPs, String strTemplate){
		//system.debug('--sendODECAPOverDueEmailAlert --');
		List<String> lstCAPEmailTemplate = new List<String>();
		
		try{
			for(CLQ_Corrective_Action_Plan__c cap : lstCAPs){
				lstCAPEmailTemplate.add(strTemplate+'|'+cap.Id);
			}
			//system.debug('lstCAPEmailTemplate --- '+lstCAPEmailTemplate);
			
			if(!lstCAPEmailTemplate.isEmpty()){
				CLQ_GlobalWebService3.sendCAPEmail(lstCAPEmailTemplate);
			}
			
		}catch(Exception e){
            //system.debug('sendODECAPOverDueEmailAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}
	
	//Method to send CAP Over due notification to JFS Prg 	
	public static void sendJFSCAPOverDueEmailAlert(List<CLQ_Corrective_Action_Plan__c> lstCAPs, String strTemplate){
		//system.debug('--sendJFSCAPOverDueEmailAlert --');
		Map<Id, String> mapCAPEmailTemplate = new Map<Id, String>();
		
		try{
			for(CLQ_Corrective_Action_Plan__c cap : lstCAPs){
				mapCAPEmailTemplate.put(cap.Id, strTemplate);
			}
			//system.debug('mapCAPEmailTemplate --- '+mapCAPEmailTemplate);
			
			if(!mapCAPEmailTemplate.isEmpty()){
				sendJFSEmailForCAP(mapCAPEmailTemplate);
			}
			
		}catch(Exception e){
            //system.debug('sendJFSCAPOverDueEmailAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
		}
	}	
	//11799 Ends 
	//PA - 11926 Begins 
	//Method to send Emails for ODE Programs
    @testVisible private static void sendODEEmailForProgram(map<Id, String> mapProgramEmailTemplate){
        //Declare Few Variables that needs to be used in the logic of this method.
        map<String, Id> mapTemplate = new map<String, Id>();
        map<Id, list<CLQ_Role__c>> mapPrgRoleEmail = new map<Id, list<CLQ_Role__c>>();
        list<Messaging.SingleEmailMessage> lstMails = new list<Messaging.SingleEmailMessage>();
        set<Id> setPrgId = new set<Id>();
        map<Id, list<CLQ_Program__c>> mapOrgwithPrgs = new map<Id, list<CLQ_Program__c>>();
        try{
            //logic that selects the email recipients for ODE Programs
            if(!mapProgramEmailTemplate.isEmpty()){
                setPrgId.addAll(mapProgramEmailTemplate.keySet());
                for(EmailTemplate et: [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName IN : mapProgramEmailTemplate.values()]){
                    mapTemplate.put(et.DeveloperName, et.Id);
                }
                //system.debug('mapOrgwithPrgs --- '+mapOrgwithPrgs);
                mapPrgRoleEmail = fetchAllODEPortalRoleEmail(setPrgId, mapOrgwithPrgs.keySet());
                if(!mapProgramEmailTemplate.isEmpty()){
                    OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'mvg@deloitte.com'];
                    Contact cnt = [SELECT Id FROM Contact WHERE Email != null AND Email = 'NOREPLY@TEST.COM' LIMIT 1];
                    map<string, OCLQS_Email_Recipients__c> mapEmailRecipient = fetchEmailTemplateRecipient();
                    
                    String prgQuery = 'Select Id, '+Label.Prg_EmailAlert_Fields+' from CLQ_Program__c where ID IN : setPrgId';
                    
                    for(CLQ_Program__c Prgr : (list<CLQ_Program__c>)Database.Query(prgQuery)){
                        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                        Id TemplateId = mapTemplate.get(mapProgramEmailTemplate.get(Prgr.Id));
                        list<String> emailToList = new list<String>();
                        list<String> emailCCList = new list<String>();
                        list<String> emailBCCList = new list<String>();
                        set<String> emailToSet = new set<String>();
                        set<String> emailCCSet = new set<String>();
                        set<String> emailBCCSet = new set<String>();
                        set<String> setToPortalRoles = new set<String>();
                        set<String> setCCPortalRoles = new set<String>();
                        OCLQS_Email_Recipients__c emailRcpnt = mapEmailRecipient.get(mapProgramEmailTemplate.get(Prgr.Id));
                        if(owea.size() > 0){
                            msg.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        msg.settargetObjectID(cnt.Id);
                        msg.setwhatID(Prgr.Id);
                        msg.setTemplateId(TemplateId);
                        //system.debug('emailRcpnt --- '+emailRcpnt);
                        if(emailRcpnt != null){
                            //Setting Program fields as Email Recipients
                            if(emailRcpnt.To__c != null){
                                for(String toEmail : emailRcpnt.To__c.split(',')){
                                    if(toEmail.indexof(DOT)>0){
                                        String []emailField = toEmail.split('\\.');
                                        if(Prgr.getSobject(emailField[0]) != null && Prgr.getSobject(emailField[0]).get(emailField[1]) != null){
                                            emailToSet.add((String)Prgr.getSobject(emailField[0]).get(emailField[1]));
                                        }
                                    }else{
                                        if(toEmail != LICENSING_MANAGER_EMAIL && Prgr.get(toEmail) != null){
                                            emailToSet.add((String)Prgr.get(toEmail));
                                        }
                                            
                                    }
                                     if(toEmail == LICENSING_MANAGER_EMAIL && Prgr.CLQ_Licensing_Specialist__r.Manager.Email != null){
                                    		emailToSet.add((String)Prgr.CLQ_Licensing_Specialist__r.Manager.Email);
                                	}
                                }
                            }
                            if(emailRcpnt.CC__c != null){
                                for(String ccEmail : emailRcpnt.CC__c.split(',')){
	                    				if(ccEmail.indexOf(DOT)>0){
	                      					String []emailField = ccEmail.split('\\.');
                                            if(Prgr.getSobject(emailField[0]) != null && Prgr.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailCCSet.add((String)Prgr.getSobject(emailField[0]).get(emailField[1]));
                                            }
	                    					}else{
                                                if(ccEmail != LICENSING_MANAGER_EMAIL && Prgr.get(ccEmail) != null){
                                                    emailCCSet.add((String)Prgr.get(ccEmail));
                                                }
	                    					}
	                    				
	                    				if(ccEmail == LICENSING_MANAGER_EMAIL && Prgr.CLQ_Licensing_Specialist__r.Manager.Email !=null){
	                      					emailCCSet.add((String)Prgr.CLQ_Licensing_Specialist__r.Manager.Email);
	                    				}  
	                  				}
                            }
                            if(emailRcpnt.BCC__c != null){
                                for(String bccEmail : emailRcpnt.BCC__c.split(',')){
	                    				if(bccEmail.indexOf(DOT)>0){
	                      					String []emailField = bccEmail.split('\\.');
                                            if(Prgr.getSobject(emailField[0]) != null && Prgr.getSobject(emailField[0]).get(emailField[1]) != null){
                                                emailBCCSet.add((String)Prgr.getSobject(emailField[0]).get(emailField[1]));
                                            }
	                    					}else{
                                                if(Prgr.get(bccEmail) != null){
                                                    emailBCCSet.add((String)Prgr.get(bccEmail));
                                                }
	                        						
	                    					}
	                  				}
                            }
                            //Setting Portal Roles as Email Recipients
                            if(mapPrgRoleEmail.containsKey(Prgr.Id)){
                                for(CLQ_Role__c roleObj : mapPrgRoleEmail.get(Prgr.Id)){
                                    if(emailRcpnt.To_Role__c != null){
			                    			setToPortalRoles.addAll(emailRcpnt.To_Role__c.split(','));
				                  			if(setToPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
				                    			emailToSet.add(roleObj.CLQ_Contact__r.Email);
				                  			}
			                			}  
			                
			                			if(emailRcpnt.CC_Role__c != null){        
			                  				setCCPortalRoles.addAll(emailRcpnt.CC_Role__c.split(','));
			                  				if(setCCPortalRoles.contains(roleObj.Portal_Roles__c) && roleObj.CLQ_Contact__r.Email != null){
			                    				emailCCSet.add(roleObj.CLQ_Contact__r.Email);
			                  				}
			                			}
                                }
                            }
                            emailToList.addAll(emailToSet);
                            emailCCList.addAll(emailCCSet);
                            emailBCCList.addAll(emailBCCSet);
                            system.debug('emailToList--' +emailToList);
                            if(!emailToList.isEmpty()){
                                msg.setToAddresses(emailToList);
                            }
                            if(!emailCCList.isEmpty()){
                                msg.setCCAddresses(emailCCList);
                            }
                            if(!emailBCCList.isEmpty()){
                                msg.setBCCAddresses(emailBCCList);
                            }
                        }
                        lstMails.add(msg);
                    }
                    //Logic for Sending Email
                    //system.debug('lstMails::'+lstMails);
                    if(!lstMails.isEmpty()){
                        Messaging.sendEmail(lstMails);
                    }
                }
            }
        }catch(Exception e){
            //system.debug('Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1', e.getMessage(), 'Cause:' + e.getCause() , 'Line:' + e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
    }
	//Method to send an email alert for ODE Programs
    public static void sendODEProPeriodExceededEmailAlert(list<CLQ_Program__c> lstPrgs, string strTemplate){
        //system.debug('--sendODEProPeriodExceededEmailAlert--');
        map<Id, String> mapPrgEmailTemplate = new map<Id, String>();
        try{
            for(CLQ_Program__c prg : lstPrgs){
                mapPrgEmailTemplate.put(prg.Id, strTemplate);
            }
            //system.debug('mapPrgEmailTemplate:'+mapPrgEmailTemplate);
            if(!mapPrgEmailTemplate.isEmpty()){
                sendODEEmailForProgram(mapPrgEmailTemplate);
            }
        }catch(Exception e){
            //system.debug('sendODEProPeriodExceededEmailAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
        
    }
    //Method to send an email alert for JFS Programs
    public static void sendJFSProPeriodExceededEmailAlert(list<CLQ_Program__c> lstPrgs, string strTemplate){
        //system.debug('--sendJFSProPeriodExceededEmailAlert--');
        map<Id, String> mapPrgEmailTemplate = new map<Id, String>();
        
        try{
            for(CLQ_Program__c prg : lstPrgs){
                mapPrgEmailTemplate.put(prg.Id, strTemplate);
            }
            //system.debug('mapPrgEmailTemplate:'+mapPrgEmailTemplate);
            if(!mapPrgEmailTemplate.isEmpty()){
                sendJFSEmailForProgram(mapPrgEmailTemplate);
            }
            
        }catch(Exception e){
            //system.debug('sendJFSProPeriodExceededEmailAlert - Exception::'+e.getMessage());
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.1',e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        }
    }//PA - 11926 Ends
}