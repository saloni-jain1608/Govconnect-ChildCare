/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTransactionTrigHdlrLicsng2 
** Description      : This is an TriggerHandler Class for the CLQ_Program_Transaction__c for the Licensing Team
This is a conversion of the Process Flow Changes On Update and Creation
** Version          : 1.7
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer                   Date                Version         Description
**  N/A                         N/A                 1.0             Initial Build
**  Soufin                      N/A                 1.1             TFS#11927: Updated for enabling the Portal user to be able to delete schedule
**  Pavan Ayta                  03/28/2018          1.2             TFS#12050: Commenting the following line to retain the Facility Schedule with the Original PT
**  Neetu Ojha                  03/30/2018          1.3             TFS#12051 : Update Onsite Contact transaction updates 
**  Pradeep Ravi                05/17/2018          1.4             Updated for #12214 - Copy over onsite contact role to the update program transaction
**  Rahul Roy                   10/3/2018           1.5             TFS #14780 - Added check to see if the lic reviewer is inactive
**  Rahul Roy                   11/14/2018          1.6             TFS #14805 - Added condition to check for Reactivated Transactions and closing related task.
**  Rahul Roy                   11/20/2018          1.7             TFS #14804 - Updated code to populate program number and program name for the Tasks on PT
**  Sujith Balakrishnan         1/15/2020           1.8             TFS #16454 - The system should close an application if it is open more than 13 months
**  Sujith Balakrishnan         4/4/2020            1.9             TFS #16658,16404,16660 
*************************************************************************************************************/

/* Name : 
* Description : 
*
*/
public with sharing class CLQ_ProgramTransactionTrigHdlrLicsng2 
{
    CLQ_ProgramTransactionTrigHdlrLicsng Parent;
    map<Id,CLQ_Program__c> ProgramMap;
    map<Id,CLQ_Role__c> RolesMap;
    map<Id,Task> TasksMap;
    map<Id,CLQ_Facility_Schedule__c> FacilityMap;
    map<Id,CLQ_Program_Transaction__c> RelatedMap;
    
    public static final string REVIEW_CHANGE_OF_ADMINISTRATOR = 'Review Change of Administrator Amendment';
    public static final string REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW = 'Revise Change of Administrator Amendment Review';
    public static final string APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR = 'Approval Review of Administrator Amendment';
    public static final string COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE = 'Complete Reactivation of Temporary License';
    public static final string REACTIVATE_TRANSACTION_SUBMITTED = 'Reactivate Transaction Submitted';
    public static final string REVISE_REACTIVATE_TRANSACTION = 'Revise Reactivate Transaction';
    
    public static final string REVIEW_CHANGE_OF_CAPACITY_OR_SPACE = 'Review Change of Capacity or Space Amendment';
    public static final string REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW = 'Revise Change of Capacity or Space Amendment Review';
    public static final string APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE = 'Approval Review of Change Capacity or Space Amendment';
    public static final string REVIEW_CHANGE_OF_LOCATION = 'Review Change of Location Amendment';
    public static final string REVISE_CHANGE_OF_LOCATION_REVIEW = 'Revise Change of Location Amendment Review';
    public static final string APPROVAL_REVIEW_LOCATION_OR_SPACE = 'Approval Review of Change of Location Amendment';
    
    public static final string APPLICATION_REVISED = 'Application Revised';
    public static final string LICENSING_CLOSURE = 'Licensing - Closure';
    public static final string REGISTRATION_CLOSURE = 'Registration Closure';
    public static final string PENDING_PROCESSING = 'Pending Processing';
    public static final string UPDATE_FACILITY_INFORMATION = 'Update Facility Information';
    public static final string UPDATE_ON_SITE_CONTACT_INFORMATION = 'Update On-site Contact Information';
    public static final string CHANGE_OF_ADMIN = 'Review the "Amendment - Change of Administrator" request for ';
    public static final string REVISE_THE_AMENDMENT = 'Revise the "Amendment - Change of Administrator" request for ';
    
    public static final string DAY_CAMP = 'Day Camp';
    public static final string UPDATE_sTRING = 'Update';
    public static final string ON_SITE_CONTACT = 'On-site Contact';
    public static final string ALTERNATE_ON_SITE_CONTACT = 'Alternate On Site Contact';
    public static final string UPDATE_AUTHORIZED_REP_INFO = 'Update Authorized Rep Info';
    public static final string AUTHORIZED_REPRESENTATIVE = 'Authorized Representative';
    
    public static final string ORGANIZTION_ROLE = 'Organization Role';
    public static final string UPDATE_FCC_RESIDENT_INFO = 'Update FCC Resident Information';
    public static final string RESIDENT = 'Resident';
    public static final string AMENDMENT_CHANGE_OF_ADMINISTRATOR = 'Amendment - Change of Administrator';
    public static final string ADMINISTRATOR = 'Administrator';
    public static final string ACTIVE = 'Active';
    public static final string request_for = ' request for ';
    
    public static final string PENDING = 'Pending';
    public static final string COMPLETED = 'Completed';
    public static final string SUTQ = 'SUTQ';
    public static final string UNDER_REVIEWER_REVIEW = 'Under Reviewer Review';
    public static final string APPROVED = 'Approved';
    public static final string NOT_SUBMITTED = 'Not Submitted';
    
    public static final string REACTIVATE_TRANSCATION = 'Reactivate Transaction';
    public static final string PRE_SCHOOL = 'Pre School';
    public static final string APPROVER_REVIEW_IN_PROGRESS = 'Approver Review in Progress';
    public static final string REACTIVATE_TRANSACTION = 'Reactivate Transaction';
    public static final string AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE = 'Amendment - ODE and Center - Change of Capacity / Space';
    public static final string AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE = 'Amendment- FCC - Change of Capacity / Space';
    
    public static final string SUPER_STATE_ADMIN_STATE_USER = 'Super State Admin - State user';
    public static final string STATE_PROGRAM_ADMIN_STATE_USER = 'State Program Admin State User';
    public static final string STATE_ADMIN_STATE_USER = 'State Admin - State user';
    public static final string ODJFS_COUNTY_ADMIN_COUNTY_ROLE = 'ODJFS County Admin - County Role';
    public static final string SYSTEM_ADMIN = 'System Administrator';
    public static final string JFS_STATE_ADMIN = 'JFS State Admin';
    
    public static final string JFS_SPECIALIST = 'JFS Specialist';
    public static final string JFS_SUPERVISOR = 'JFS Supervisor';
    public static final string CLOSED_BY_SYSTEM = 'Closed by System';
    public static final string APPLICATION = 'Application';
    public static final string REGISTRATION_OUT_OF_STATE = 'Registration - Out of State';
    public static final string IN_HOME_AID = 'In-Home Aid';
    
    public static final string OPEN = 'Open';
    public static final string INACTIVE = 'Inactive';
    public static final string FCC_TYPE_B_HOME = 'FCC - Type B Home';
    
    public static final string CHILD_CARE_CENTER = 'Child Care Center';
    public static final string FCC_TYPE_A_HOME = 'FCC - Type A Home';
    
    public static final string OUT_OF_STATE_REGISTRATION = 'Out of State Registration';
    public static final string JFS_APPLICATION_CLOSED = 'JFS Application Closed';
    public static final string ODE_APPLICATION_CLOSED = 'ODE Application Closed';
    public static final string CLOSED = 'Closed';
    public static final string DENIED = 'Denied';
    public static final string CANCELLED = 'Cancelled';
    
    public static final string CLOSED_AT_APPLICANT_REQUEST = 'Closed at Applicant�s Request';
    
    public static final string CHANGE_OF_LOCATION = 'Change of Location';
    public static final string SCHOOL_AGE_CHILD_CARE = 'School Age Child Care';
    
    public static final string PENDING_INACTIVE = 'Pending Inactive';
    
    public static final string SUBMITTED = 'Submitted';
    public static final string CLQ_ODE_Email_alert_to_be_sent_if_Reactivation_is_Approved = 'CLQ_ODE_Email_alert_to_be_sent_if_Reactivation_is_Approved';
    public static final string PORTAL_ROLES = 'Portal Roles';
    public static final string OCLQSSUTQ = 'OCLQSSUTQ';
    public static final string ODE = 'ODE';
    public static final string CLQ_JFS_Email_alert_to_be_sent_if_Reactivation_is_Approved = 'CLQ_JFS_Email_alert_to_be_sent_if_Reactivation_is_Approved';
    
    public static final string REVIEW = 'Review';
    public static final string NOT_LICENSED = 'Not Licensed';
    public static final string RETURNED_TO_REVIEWER = 'Returned to Reviewer';
    public static final string REGISTRATION_DAY_CAMP = 'Registration - Day Camp';
    public static final string LICENSCE_CLOSURE = 'Licensing Closure';
    public static final string FCC = 'FCC';
    public static final string YES = 'Yes';
    public static final string ErrorMsg = 'You cannot assign the program transaction to users from outside the county.';
    public static final String EMPTY_STRING = '';   
    
    public CLQ_ProgramTransactionTrigHdlrLicsng2(map<Id,CLQ_Program__c> Programs,map<Id,CLQ_Role__c> Roles, map<Id,Task> Tasks,map<Id,CLQ_Facility_Schedule__c> Facilities)
    {
        ProgramMap = Programs;
        RolesMap = Roles;
        TasksMap = Tasks;
        FacilityMap = Facilities;
    }     
    public CLQ_ProgramTransactionTrigHdlrLicsng2(map<Id,CLQ_Program__c> Programs,map<Id,CLQ_Role__c> Roles, map<Id,Task> Tasks,map<Id,CLQ_Facility_Schedule__c> Facilities,
                                                 map<Id,CLQ_Program_Transaction__c> Related)
    {
        ProgramMap = Programs;
        RolesMap = Roles;
        TasksMap = Tasks;
        FacilityMap = Facilities;
        RelatedMap = Related;
    } 
    
    
    public set<CLQ_Role__c> RolesToUpsert = new set<CLQ_Role__c>();
    public set<CLQ_Program__c> ProgramsToUpsert = new set<CLQ_Program__c>();
    public set<Task> TasksToUpsert = new set<Task>();
    public set<CLQ_Facility_Schedule__c> Facility_ScheduleToUpsert = new set<CLQ_Facility_Schedule__c> ();
    
    public void ChangesBeforeInsert(CLQ_Program_Transaction__c Program_Transaction)
    {
        string RecordTypeName = CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId); 
        if (RecordTypeName == null || RecordTypeName.startsWith(SUTQ)){ return;}
        if (Program_Transaction.CLQ_Transaction_Status__c == APPLICATION_REVISED){ return;}
        
        CLQ_Program__c Program;
        if(ProgramMap.size()>0){Program= ProgramMap.get(Program_Transaction.CLQ_Program__c);}
        //system.Debug('ChangesAfterInsert:Facility_Schedules__r: ' + Program.Facility_Schedules__r.size());
        //system.Debug('ChangesAfterInsert:Roles__r:              ' + Program.Roles__r.size());
        if (RecordTypeName == LICENSING_CLOSURE || RecordTypeName == REGISTRATION_CLOSURE)
        {
            //23    CLQ_Closure Registration Create
            Program_Transaction.CLQ_Closure_Status__c = PENDING_PROCESSING;
        }
        //          Same As Physical Address                ProgramTransaction.CLQ_Same_as_Physical_Address__c
        //          Mailing Street Address                  ProgramTransaction.CLQ_Mailing_Street_Address__c
        //          Mailing Street Address 2                ProgramTransaction.CLQ_Mailing_Street_Address_2__c
        //          Mailing City                            ProgramTransaction.CLQ_Mailing_City__c
        //          Mailing State                           ProgramTransaction.CLQ_Mailing_State__c
        //          Mailing ZipCode                         ProgramTransaction.CLQ_Mailing_ZipCode__c
        if (Program_Transaction.CLQ_Same_as_Physical_Address__c)
        {
            //41    CLQ Same as Physical Address checked
            Program_Transaction.CLQ_Mailing_Street_Address__c =     Program_Transaction.CLQ_ProgTrans_Street_Address__c;
            Program_Transaction.CLQ_Mailing_Street_Address_2__c =   Program_Transaction.CLQ_ProgTrans_Street_Address_2__c;
            Program_Transaction.CLQ_Mailing_City__c =               Program_Transaction.CLQ_ProgTrans_City__c;
            Program_Transaction.CLQ_Mailing_State__c =              Program_Transaction.CLQ_ProgTrans_State__c;
            Program_Transaction.CLQ_Mailing_ZipCode__c =            Program_Transaction.CLQ_ProgTrans_Zip_Code__c;
        }        
    }
    
    public void ChangesAfterInsert(CLQ_Program_Transaction__c Program_Transaction)
    {
        
        string RecordTypeName = CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
        
        if (RecordTypeName == null || RecordTypeName.startsWith(SUTQ)){
            return;
        } 
        if (Program_Transaction.CLQ_Transaction_Status__c == APPLICATION_REVISED){
            return;
        } 
        
        CLQ_Program__c Program;
        if(ProgramMap.size()>0){Program= ProgramMap.get(Program_Transaction.CLQ_Program__c);}
        
        //system.Debug('ChangesAfterInsert:Facility_Schedules__r: ' + Program.Facility_Schedules__r.size());
        //system.Debug('ChangesAfterInsert:Roles__r:              ' + Program.Roles__r.size());
        
        if (RecordTypeName == UPDATE_FACILITY_INFORMATION)
        {
            for (CLQ_Facility_Schedule__c schedule: Program.Facility_Schedules__r)
            {
                if (Schedule.CLQ_Program_Transaction__c != Program_Transaction.Id && schedule.CLQ_Status__c == ACTIVE)//PA-03/29/2018
                {
                    //PA-12050: Begins
                    //schedule.CLQ_Program_Transaction__c = Program_Transaction.Id;
                    //schedule.OwnerId = Program_Transaction.createdById; // 11927
                    CLQ_Facility_Schedule__c NewSchedule = new CLQ_Facility_Schedule__c ();
                    NewSchedule = schedule.Clone(false, true, false, false); 
                    NewSchedule.CLQ_Program_Transaction__c = Program_Transaction.Id;
                    NewSchedule.CLQ_Program__c = NULL;
                    Facility_ScheduleToUpsert.Add(NewSchedule);
                    
                }//PA-12050 Ends
            }
        }
        //2.1   CLQ_Onsite_update PT
        // Updated for #12214 - Copy over onsite contact role to the update program transaction
        else if (RecordTypeName == UPDATE_ON_SITE_CONTACT_INFORMATION || (RecordTypeName == DAY_CAMP && Program_Transaction.CLQ_Transaction_Type__c == UPDATE_STRING))
        {
            for (CLQ_Role__c role: Program.Roles__r)
            {
                if (role.CLQ_Role__c == ON_SITE_CONTACT || role.CLQ_Role__c == ALTERNATE_ON_SITE_CONTACT)
                {
                    if (role.CLQ_Program_Transaction_Source__c != Program_Transaction.Id)
                    {
                        //12051 Starts
                        CLQ_Role__c newRole = new CLQ_Role__c();
                        newRole = role.Clone(false, true, false, false);
                        // Updated for #12214 - Adding the organization for the role to display for the portal user
                        if(RecordTypeName == DAY_CAMP)
                        {
                            newRole.CLQ_Organization__c = Program_Transaction.CLQ_Associated_Organization__c;
                        } 
                        newRole.CLQ_Program_Transaction_Source__c = Program_Transaction.Id;
                        newRole.CLQ_Program__c = NULL;                    	
                        //role.CLQ_Program_Transaction_Source__c = Program_Transaction.Id;
                        RolesToUpsert.Add(newRole);
                        //12051 Ends
                    }
                }
            }
        }
        //2.2   CLQ_Onsite_update PT
        else if (RecordTypeName == UPDATE_AUTHORIZED_REP_INFO)
        {
            for (CLQ_Role__c role: Program.Roles__r)
            {
                if (role.CLQ_Role__c == AUTHORIZED_REPRESENTATIVE && role.RecordType.Name == ORGANIZTION_ROLE)
                {
                    if (role.CLQ_Program_Transaction_Source__c != Program_Transaction.Id)
                    {
                        role.CLQ_Program_Transaction_Source__c = Program_Transaction.Id;
                        RolesToUpsert.Add(role);
                    }
                }
            }
        }
        //1 CLQ_Resident_Update PT
        else if (RecordTypeName == UPDATE_FCC_RESIDENT_INFO)
        {
            for (CLQ_Role__c role: Program.Roles__r)
            {
                if (role.CLQ_Role__c == RESIDENT)
                {
                    if (role.CLQ_Program_Transaction_Source__c != Program_Transaction.Id)
                    {
                        role.CLQ_Program_Transaction_Source__c = Program_Transaction.Id;
                        RolesToUpsert.Add(role);
                    }
                }
            }
        }       
        else if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR)
        {
            //4 CLQ_Administrator PT Update
            for (CLQ_Role__c role: Program.Roles__r)
            {
                //Status check for Role added by Meena
                if (role.RecordType.Name == ADMINISTRATOR && (role.CLQ_Status__c == ACTIVE || role.CLQ_Status__c == PENDING))
                {
                    if (role.CLQ_Program_Transaction_Source__c != Program_Transaction.Id)
                    {
                        role.CLQ_Program_Transaction_Source__c = Program_Transaction.Id;
                        RolesToUpsert.Add(role);
                    }
                }
            }
            map<string,Task> NamedTasks =  GetPTTaskBySubject(Program_Transaction.Id, TasksMap.Values());
            if (NamedTasks.containsKey(REVIEW_CHANGE_OF_ADMINISTRATOR))
            {
                Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_ADMINISTRATOR);
                TaskToClose.Status= COMPLETED ;
                TasksToUpsert.Add(TaskToClose);
            }
        }               
    }
    public void ChangesBeforeUpdate(CLQ_Program_Transaction__c Program_Transaction, CLQ_Program_Transaction__c OldRecord)
    {
        ValidateUserCounty(Program_Transaction,OldRecord); //TFS #16658
        string RecordTypeName = CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
        if (RecordTypeName == null || RecordTypeName.startsWith(SUTQ)){
            return;
        } 
        if (Program_Transaction.CLQ_Transaction_Status__c == APPLICATION_REVISED){
            return;
        } 
        
        CLQ_Program__c Program;
        if(ProgramMap.size()>0){Program = ProgramMap.get(Program_Transaction.CLQ_Program__c);}
        
        if (Program_Transaction.CLQ_Transaction_Status__c == SUBMITTED)
        {
            //3.1   CLQ_Update Resident/onsite Functinality
            //3.2   CLQ_Update Resident/onsite Functinality
            //3.3   CLQ_Update Resident/onsite Functinality
            //14780 - removed
            /*if (RecordTypeName == 'Update On-site Contact Information'
||RecordTypeName == UPDATE_AUTHORIZED_REP_INFO
||RecordTypeName == UPDATE_FCC_RESIDENT_INFO)
{
if (Program.CLQ_Licensing_Specialist__c != null && Program.Lic_Reviewer_IsActive__c == true) //14780
{
Program_Transaction.CLQ_Transaction_Assigned_To__c = Program.CLQ_Licensing_Specialist__c;
Program_Transaction.OwnerId = Program.CLQ_Licensing_Specialist__c;
}
} */  
            set<string> RecordTypeSet = new set<string> {LICENSCE_CLOSURE,REGISTRATION_OUT_OF_STATE,REGISTRATION_DAY_CAMP,REACTIVATE_TRANSCATION,AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE,AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE, AMENDMENT_CHANGE_OF_ADMINISTRATOR};
                if (!RecordTypeSet.contains(RecordTypeName) && !RecordTypeName.contains(UPDATE_STRING))
            {
                //12    CLQ_Status = Review in Progress
                if (Program_Transaction.CLQ_Transaction_Assigned_To__c != null
                    && !Program_Transaction.CLQ_ACA_Accredited__c
                    && !Program_Transaction.CLQ_Portal_Application_Update__c)
                {
                    Program_Transaction.CLQ_Transaction_Status__c = UNDER_REVIEWER_REVIEW;
                }
            }                       
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == APPROVED)
        {
            //8 CLQ_COA Amendment Approved
            if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR && Program_Transaction.CLQ_Start_Approval__c == false)
            {
                if (Program.CLQ_Licensing_Specialist__c != null)
                {
                    Program_Transaction.CLQ_Approval_Date__c = Date.Today();
                    Program_Transaction.CLQ_Send_Notification_to_Program__c = YES;
                }
            }               
            //26    CLQ_ODE Reactivate Approved Transaction
            //27    CLQ_JFS Reactivate Approved Transaction         
            if (RecordTypeName == REACTIVATE_TRANSCATION)
            {
                set<string> ProgramRecordTypes = new set<string> {SCHOOL_AGE_CHILD_CARE,PRE_SCHOOL,CHILD_CARE_CENTER,FCC_TYPE_A_HOME,FCC_TYPE_B_HOME};
                    if (RelatedMap.size()>0 && ProgramRecordTypes.contains(Program.RecordType.Name) && Program_Transaction.CLQ_Transaction_Assigned_To__c != null)
                {
                    CLQ_Program_Transaction__c AdditionalFields = RelatedMap.get(Program_Transaction.Id);
                    if (AdditionalFields != null && AdditionalFields.CLQ_Transaction_Assigned_To__c != null){
                        Program_Transaction.CLQ_Assigned_To_Email__c = AdditionalFields.CLQ_Transaction_Assigned_To__r.Email;
                    }
                        
                }
            }               
            Program_Transaction.CLQ_CopiedToProgram__c = false;
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == NOT_SUBMITTED)
        {
            //23    CLQ_Portal User Updates_ODE
            if (RecordTypeName == REACTIVATE_TRANSCATION && (Program.RecordType.Name == PRE_SCHOOL || Program.RecordType.Name == SCHOOL_AGE_CHILD_CARE))
            {
                if (Program_Transaction.CLQ_Submitter__c == null && Program_Transaction.CLQ_Portal_Application_Update__c == true)
                {
                    Program_Transaction.CLQ_Portal_Application_Update__c = false;
                }
            }               
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == APPROVER_REVIEW_IN_PROGRESS)
        {
            if (RecordTypeName == REACTIVATE_TRANSCATION
                && Program_Transaction.CLQ_Start_Approval__c
                && Program_Transaction.CLQ_Transaction_Assigned_To__c != null
                && Program_Transaction.CLQ_Transaction_Assigned_to_Manager__c != null )
            {
                //25 CLQ_Reactivation Review in Progress
                //Program_Transaction.CLQ_Assigned_To_Email__c = Program_Transaction.CLQ_Transaction_Assigned_To__c; --Commented by Vrajesh as it is assigning User id to email field - Fix for 101 SOQL error
                Program_Transaction.CLQ_Assigned_To_Email__c = Program_Transaction.CLQ_Transaction_Assigned_To__r.Email;
            }
        }
        if (Program_Transaction.CLQ_Approved_by_Manager__c && !OldRecord.CLQ_Approved_by_Manager__c)
        {
            //35    CLQ_COC Amendment Approved
            if (RecordTypeName == AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE || RecordTypeName == AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE)
            {
                Program_Transaction.CLQ_Approval_Date__c = Date.Today();
                Program_Transaction.CLQ_Send_Notification_to_Program__c = YES;
            }
        }
        
        //          Same As Physical Address                ProgramTransaction.CLQ_Same_as_Physical_Address__c
        //          Mailing Street Address                  ProgramTransaction.CLQ_Mailing_Street_Address__c
        //          Mailing Street Address 2                ProgramTransaction.CLQ_Mailing_Street_Address_2__c
        //          Mailing City                            ProgramTransaction.CLQ_Mailing_City__c
        //          Mailing State                           ProgramTransaction.CLQ_Mailing_State__c
        //          Mailing ZipCode                         ProgramTransaction.CLQ_Mailing_ZipCode__c
        if (Program_Transaction.CLQ_Same_as_Physical_Address__c)
        {
            //41    CLQ Same as Physical Address checked
            Program_Transaction.CLQ_Mailing_Street_Address__c =     Program_Transaction.CLQ_ProgTrans_Street_Address__c;
            Program_Transaction.CLQ_Mailing_Street_Address_2__c =   Program_Transaction.CLQ_ProgTrans_Street_Address_2__c;
            Program_Transaction.CLQ_Mailing_City__c =               Program_Transaction.CLQ_ProgTrans_City__c;
            Program_Transaction.CLQ_Mailing_State__c =              Program_Transaction.CLQ_ProgTrans_State__c;
            Program_Transaction.CLQ_Mailing_ZipCode__c =            Program_Transaction.CLQ_ProgTrans_Zip_Code__c;
        }        
        
    }       
    
    //TFS #16658 changes starts
    public void ValidateUserCounty( CLQ_Program_Transaction__c  prog,  CLQ_Program_Transaction__c   oldMap)
    {
        
        User AssignedUser=null;
        User SUTQUser=null;
        String LicenseUserID;
        String SUTQUserID=EMPTY_STRING;
        if(!prog.CLQ_Program_Record_Type__c.contains(FCC)||!String.isNotEmpty(prog.CLQ_Transaction_Assigned_To__c) || (prog.CLQ_Transaction_Assigned_To__c == oldMap.CLQ_Transaction_Assigned_To__c))
        {
            return;
        }
        LicenseUserID=prog.CLQ_Transaction_Assigned_To__c;
        
        Boolean LicensingProfile=false;
        if(LicenseUserID!=null)
        {
            AssignedUser= [Select Id, Profile.Name, UserRole.Name FROM User WHERE Id = :LicenseUserID]; 
        }
        if((String.isNotEmpty(LicenseUserID)) && (AssignedUser ==null || !String.isNotEmpty(AssignedUser.UserRole.Name)) )
        {
            // prog.AddError('There is no role assigned to the licensing reviewer.');
            return;
        }
        
        If(LicenseUserID<>NULL && (AssignedUser.Profile.Name==SUPER_STATE_ADMIN_STATE_USER || AssignedUser.Profile.Name==STATE_PROGRAM_ADMIN_STATE_USER || AssignedUser.Profile.Name== STATE_ADMIN_STATE_USER || AssignedUser.Profile.Name==ODJFS_COUNTY_ADMIN_COUNTY_ROLE || AssignedUser.Profile.Name==SYSTEM_ADMIN || AssignedUser.UserRole.Name== JFS_STATE_ADMIN || AssignedUser.UserRole.Name==JFS_SPECIALIST || AssignedUser.UserRole.Name==JFS_SUPERVISOR) )
        {
            LicensingProfile=true; 
        }
        
        if(LicensingProfile==false && String.isNotEmpty(LicenseUserID) && String.isNotEmpty(AssignedUser.UserRole.Name) &&  !AssignedUser.UserRole.Name.ContainsIgnoreCase(prog.CLQ_County__c)) 
        {
            prog.AddError(ErrorMsg);
            return;
        }
        
        
    }
    //TFS #16658 changes ends
    public void ChangesAfterUpdate(CLQ_Program_Transaction__c Program_Transaction, CLQ_Program_Transaction__c OldRecord)
    {
        string RecordTypeName = CLQ_ProgramTransactionTrigHdlrLicsng.AllRecordTypes.get(Program_Transaction.RecordTypeId);
        //TFS#16454 starts
        CLQ_Program__c Program;
        if(ProgramMap.size()>0){Program = ProgramMap.get(Program_Transaction.CLQ_Program__c);}
        
        
        if ((Program_Transaction.CLQ_Transaction_Status__c == CLOSED_BY_SYSTEM ) && RecordTypeName.contains(APPLICATION) && Program.RecordType.Name!=DAY_CAMP )
        {
            system.debug('');
            List <CLQ_Program_Transaction__c> lstApprovedPT;
            if(Program.id!=null && Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                lstApprovedPT =[SELECT id,CLQ_Transaction_Status__c from CLQ_Program_Transaction__c where CLQ_Program__c=:Program.id and CLQ_Transaction_Status__c   in ('Approved') and  RecordType.Name like 'Application%'];
            }
            List <CLQ_Program_Transaction__c> lstPT;
            if(lstApprovedPT.IsEmpty())
            {
                system.debug('');
                if(Program.id!=null && Schema.SObjectType.CLQ_Program_Transaction__c.isAccessible()){
                    lstPT  = [SELECT id,CLQ_Transaction_Status__c from CLQ_Program_Transaction__c where CLQ_Program__c=:Program.id and CLQ_Transaction_Status__c  not in ('Approved','Denied','Closed','Closed by System','Withdraw','Withdrawn at Applicant\'s Request')];   
                }
                
                for(CLQ_Program_Transaction__c lst:lstPT)
                {
                    lst.CLQ_Transaction_Status__c=CLOSED_BY_SYSTEM;
                    lst.CLQ_Registration_Status__c=CLOSED_BY_SYSTEM;
                }
                CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
                if(!lstPT.isEmpty()){
                    if(Schema.SObjectType.CLQ_Program_Transaction__c.isUpdateable()){
                        update lstPT;
                    }
                }
                CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
            }
        }  
        //TFS#16454 ends
        //16404 starts
        Boolean MailFlag=false;
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea;
        if(Schema.SObjectType.OrgWideEmailAddress.isAccessible()){
            owea = [select Id from OrgWideEmailAddress where Address = 'jshivakumar@deloitte.com'];
        }
        if ((Program_Transaction.CLQ_Transaction_Status__c == CLOSED_BY_SYSTEM ) && (RecordTypeName.contains(APPLICATION) ||RecordTypeName.contains(REGISTRATION_OUT_OF_STATE) ||RecordTypeName.contains(IN_HOME_AID) ))
        {
            if((Program_Transaction.CLQ_Program_Status__c== OPEN ||Program_Transaction.CLQ_Program_Status__c==INACTIVE || Program_Transaction.CLQ_Program_Status__c==PENDING) && OldRecord.CLQ_Transaction_Status__c==APPLICATION_REVISED ){
                MailFlag=true;
            }
                
            if(MailFlag==false)
            {    
                EmailTemplate templateForEmail ;
                map<string,EmailTemplate> EmailTempMap=new map<string,EmailTemplate>();    
                list<string> EmailTemplateDevList=new list<string>{JFS_APPLICATION_CLOSED,ODE_APPLICATION_CLOSED};  
                    list<EmailTemplate> emailtemp;
                if(EmailTemplateDevList!=null && Schema.SObjectType.EmailTemplate.isAccessible()){
                    emailtemp=[SELECT Id,name, Body, Subject FROM EmailTemplate WHERE name in :EmailTemplateDevList];
                }
                
                for(EmailTemplate etemp:emailtemp){
                    EmailTempMap.put(etemp.name, etemp);
                } 
                list<string> toAddresses=new List<string>();
                if(EmailTempMap.size()>0 && (Program_Transaction.CLQ_Program_Record_Type__c==CHILD_CARE_CENTER || Program_Transaction.CLQ_Program_Record_Type__c==FCC_TYPE_A_HOME || Program_Transaction.CLQ_Program_Record_Type__c==FCC_TYPE_B_HOME || Program_Transaction.CLQ_Program_Record_Type__c==IN_HOME_AID || Program_Transaction.CLQ_Program_Record_Type__c==OUT_OF_STATE_REGISTRATION))
                {
                    templateForEmail = EmailTempMap.get(JFS_APPLICATION_CLOSED);
                    
                }
                else
                {
                    if(EmailTempMap.size()>0){
                        templateForEmail = EmailTempMap.get(ODE_APPLICATION_CLOSED);
                    }
                }
                if(Program_Transaction.CLQ_Transaction_Assigned_To__c!=null){
                    toAddresses.add(Program_Transaction.CLQ_Transaction_Assigned_To__c);
                }
                    
                if(Program_Transaction.clq_message_process_email__c!=null){
                    toAddresses.add(Program_Transaction.clq_message_process_email__c);
                }
                    
                msg.setTemplateId(templateForEmail.id);
                if(toAddresses != null && toAddresses.size() >0){
                    msg.setToaddresses(toAddresses);
                }
                if ( owea.size() > 0 ) {
                    msg.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                Contact cnt = [SELECT Id 
                               FROM Contact 
                               WHERE Email != null 
                               AND Email    = 'NOREPLY@TEST.COM' 
                               LIMIT 1];
                msg.settargetObjectID(cnt.id);
                msg.setwhatID(Program_Transaction.id);
                msg.setTreatTargetObjectAsRecipient(false);
                if(toAddresses.size()>0){
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                }
                    
            }
        }
        //16404 ends
        //16660 starts
        if (((RecordTypeName.contains(APPLICATION) &&(Program_Transaction.CLQ_Transaction_Status__c == CLOSED_BY_SYSTEM || Program_Transaction.CLQ_Transaction_Status__c == CLOSED || Program_Transaction.CLQ_Transaction_Status__c == DENIED || Program_Transaction.CLQ_Transaction_Status__c == CANCELLED || Program_Transaction.CLQ_Transaction_Status__c == CLOSED_AT_APPLICANT_REQUEST )) ||((RecordTypeName.contains(REGISTRATION_OUT_OF_STATE) ||RecordTypeName.contains(IN_HOME_AID) ||RecordTypeName.contains(DAY_CAMP))) && (Program_Transaction.CLQ_Registration_Status__c == CLOSED || Program_Transaction.CLQ_Registration_Status__c == DENIED)) && OldRecord.CLQ_Transaction_Status__c!=APPLICATION_REVISED)
        {
            system.debug('');
            list<CLQ_Program__c> lstprg;
            if(Program.id!=null){
                lstprg=[SELECT id,CLQ_Program_Status__c,CLQ_Program_Closure_Date__c from CLQ_Program__c where id=:Program.id];
            }
            
            for(CLQ_Program__c prg:lstprg)
            { 
                if(prg.CLQ_Program_Status__c==PENDING)
                {
                    prg.CLQ_Program_Status__c=CLOSED_BY_SYSTEM;
                    prg.CLQ_Program_Closure_Date__c=Date.today();
                    prg.CLQ_Closure_Date__c=Date.today();
                }
            }
            if(!lstprg.isEmpty()){
                if(Schema.SObjectType.CLQ_Program__c.isUpdateable()){
                    update lstprg;
                }
            } 
        }
        //16660 end
        if (RecordTypeName == null || RecordTypeName.startsWith(SUTQ)){
            return;
        } 
        if (Program_Transaction.CLQ_Transaction_Status__c == APPLICATION_REVISED){
            return;
        } 
        
        //CLQ_Program__c Program = ProgramMap.get(Program_Transaction.CLQ_Program__c);
        //system.Debug('ChangesAfterUpdate:Transaction Status: ' + Program_Transaction.CLQ_Transaction_Status__c + ' -- RecordType Name: ' + RecordTypeName);
        //system.Debug('ChangesAfterUpdate:Facility_Schedules__r: ' + Program.Facility_Schedules__r.size());
        //system.Debug('ChangesAfterUpdate:Roles__r:              ' + Program.Roles__r.size());
        
        if (Program_Transaction.CLQ_Transaction_Status__c == SUBMITTED)
        {
            //3.1   CLQ_Update Resident/onsite Functinality
            //3.2   CLQ_Update Resident/onsite Functinality
            //3.3   CLQ_Update Resident/onsite Functinality
            if (RecordTypeName == UPDATE_ON_SITE_CONTACT_INFORMATION
                ||RecordTypeName == UPDATE_AUTHORIZED_REP_INFO
                ||RecordTypeName == UPDATE_FCC_RESIDENT_INFO)
            {
                for(CLQ_Role__c role : RolesMap.values())
                {
                    if (role.CLQ_Program_Transaction_Source__c == Program_Transaction.Id && role.CLQ_Transaction_Status_Check__c == false)
                    {
                        role.CLQ_Transaction_Status_Check__c = true;
                        RolesToUpsert.Add(role);
                    }
                }
            }               
            if (RecordTypeName == UPDATE_FACILITY_INFORMATION)
            {
                //11    CLQ_Update Facility
                for(CLQ_Role__c role : RolesMap.values())
                {
                    if (role.CLQ_Program_Transaction_Source__c == Program_Transaction.Id)
                        if (role.CLQ_Transaction_Status_Check__c == false && role.CLQ_Status__c == ACTIVE)
                    {
                        role.CLQ_Transaction_Status_Check__c = true;
                        RolesToUpsert.Add(role);
                    }
                    else if (role.CLQ_Program__c != null && role.CLQ_Status__c == PENDING_INACTIVE)
                    {
                        role.CLQ_Status__c = Inactive;
                        RolesToUpsert.Add(role);
                    }
                }
            }
            set<string> RecordTypeSet = new set<string> {LICENSCE_CLOSURE,REGISTRATION_OUT_OF_STATE,REGISTRATION_DAY_CAMP,REACTIVATE_TRANSCATION,AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE,AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE,AMENDMENT_CHANGE_OF_ADMINISTRATOR};
                if (!RecordTypeSet.contains(RecordTypeName) && !RecordTypeName.contains(UPDATE_STRING))
            {
                //12    CLQ_Status = Review in Progress
                if (Program_Transaction.CLQ_Transaction_Assigned_To__c != null
                    && !Program_Transaction.CLQ_ACA_Accredited__c
                    && !Program_Transaction.CLQ_Portal_Application_Update__c)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    string NewTaskName = Review  + RecordTypeName;
                    if (!NamedTasks.containsKey(NewTaskName) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(2),NewTaskName,
                                                                         NewTaskName +  request_for  + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
            }
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == UNDER_REVIEWER_REVIEW  )
        {
            //5 CLQ_Administrator_Review
            if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR)
            {
                if (Program_Transaction.CLQ_Transaction_Assigned_To__c != null && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                {
                    //14804 start
                    Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction,
                                                                     Date.Today().AddDays(20),REVIEW_CHANGE_OF_ADMINISTRATOR,
                                                                     change_of_Admin + Program.Name);
                    //14804 end
                    /*
Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
Date.Today().AddDays(20),REVIEW_CHANGE_OF_ADMINISTRATOR,
'Review the "Amendment - Change of Administrator" request for ' + Program.Name);
*/
                    
                    newTask.Status = OPEN;
                    TasksToUpsert.Add(newTask);
                }
            }
            set<string> RecordTypeSet = new set<string>
            {LICENSCE_CLOSURE,REGISTRATION_OUT_OF_STATE,REACTIVATE_TRANSCATION,AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE,AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE};
                /*
if (!RecordTypeSet.contains(RecordTypeName))
{
//13    CLQ_License Start date
if (Program_Transaction.CLQ_License_Start_Date__c != null
&& Program_Transaction.CLQ_Recommendation__c == 'Approve'
&& !Program_Transaction.CLQ_Portal_Application_Update__c)
{
if (Program.CLQ_License_Type__c == 'Provisional')
Program.CLQ_License_Issue_Date__c = Program_Transaction.CLQ_License_Start_Date__c;
else if (Program.CLQ_License_Type__c == 'Continuous')
Program.CLQ_Continuous_License_Begin_Date__c = Program_Transaction.CLQ_License_Start_Date__c;

Program.CLQ_Licensing_Specialist__c = Program_Transaction.CLQ_Transaction_Assigned_To__c;
ProgramsToUpsert.Add(Program);
}
}*/
                if (RecordTypeName == REACTIVATE_TRANSCATION)
            {
                //28    CLQ_Reactivate Initial Task
                if (Program_Transaction.CLQ_Start_Approval__c == false && Program_Transaction.CLQ_Rejected_By_Manager__c == false
                    && Program_Transaction.CLQ_Transaction_Assigned_To__c != null)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE))
                    {
                        Task TaskToClose = NamedTasks.get(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REACTIVATE_TRANSACTION_SUBMITTED) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        //14804 start
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction,
                                                                         Date.Today().AddDays(10),REACTIVATE_TRANSACTION_SUBMITTED,
                                                                         REACTIVATE_TRANSACTION_SUBMITTED + ' request for ' + Program.Name);
                        //14804 end
                        /*
Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
Date.Today().AddDays(10),REACTIVATE_TRANSACTION_SUBMITTED,
REACTIVATE_TRANSACTION_SUBMITTED + ' request for ' + Program.Name);
*/                        
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
            }                            
            if (RecordTypeName == AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE || RecordTypeName == AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE)
            {
                //28    CLQ_Reactivate Initial Task
                if (Program_Transaction.CLQ_Transaction_Assigned_To__c != null)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        //14804 start
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction,
                                                                         Date.Today().AddDays(20),REVIEW_CHANGE_OF_CAPACITY_OR_SPACE,
                                                                         REVIEW_CHANGE_OF_CAPACITY_OR_SPACE +  request_for  + Program.Name);
                        //14804 end  
                        /*
Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
Date.Today().AddDays(20),REVIEW_CHANGE_OF_CAPACITY_OR_SPACE,
REVIEW_CHANGE_OF_CAPACITY_OR_SPACE + ' request for ' + Program.Name);
*/
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
            }                            
            if (RecordTypeName.contains(CHANGE_OF_LOCATION))
            {
                //37    CLQ_COL Under Reviewer Review
                if (Program_Transaction.CLQ_Transaction_Assigned_To__c != null 
                    && Program_Transaction.CLQ_Rejected_By_Manager__c == false 
                    && Program_Transaction.CLQ_Portal_Application_Update__c == false)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVISE_CHANGE_OF_LOCATION_REVIEW))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_LOCATION_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(APPROVAL_REVIEW_LOCATION_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_LOCATION_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVIEW_CHANGE_OF_LOCATION) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        //14804 start
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction,
                                                                         Date.Today().AddDays(20),REVIEW_CHANGE_OF_LOCATION,
                                                                         REVIEW_CHANGE_OF_LOCATION +  request_for + Program.Name);
                        //14804 end                                                    
                        /*Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
Date.Today().AddDays(20),REVIEW_CHANGE_OF_LOCATION,
REVIEW_CHANGE_OF_LOCATION + ' request for ' + Program.Name);

*/
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
            }                            
        }                       
        // Mod by LD on 1/8/17 - Logic moved to Process Flow
        /*else if (Program_Transaction.CLQ_Transaction_Status__c == 'Denied')
{
//system.debug('****LD check 4 in Denied');
//6 CLQ_COA_Role Update
if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR)
{
for(CLQ_Role__c role : GetPTRoles(Program_Transaction.Id, RolesMap.values()))
{
if (role.CLQ_Update_Role__c == false)
{
role.CLQ_Update_Role__c = true;
RolesToUpsert.Add(role);
system.debug('Update Role: Denied: ' + role);
}
}
} 

}  */                     
        else if (Program_Transaction.CLQ_Transaction_Status__c == APPROVED  )
        {
            //system.debug('****LD check 3 in Approved');
            //6 CLQ_COA_Role Update
            /*if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR)
{
for(CLQ_Role__c role : GetPTRoles(Program_Transaction.Id, RolesMap.values()))
{
//system.debug('Update Role: CLQ_Update_Role__c: ' + role.CLQ_Update_Role__c);
if (role.CLQ_Update_Role__c == false)
{
role.CLQ_Update_Role__c = true;
RolesToUpsert.Add(role);
system.debug('Update Role: Approved: ' + role);
}
}
}*/
            if (RecordTypeName.contains(APPLICATION))
            {
                //14    CLQ Transaction Approved
                if (Program_Transaction.CLQ_License_Start_Date__c != null
                    && Program_Transaction.CLQ_Approved_by_Manager__c
                    && !Program_Transaction.CLQ_Portal_Application_Update__c)
                {
                    Program.CLQ_License_Issue_Date__c = Program_Transaction.CLQ_License_Start_Date__c;
                    Program.CLQ_License_Expiration_Date__c = Program_Transaction.CLQ_License_Start_Date__c.AddYears(1).AddDays(-1);                     
                    Program.CLQ_Licensing_Specialist__c = Program_Transaction.CLQ_Transaction_Assigned_To__c;
                    
                    ProgramsToUpsert.Add(Program);
                }
            }
            if (RecordTypeName == REGISTRATION_OUT_OF_STATE)
            {
                //18    CLQ_OOS Registration
                if (Program_Transaction.CLQ_OOS_ProgramNumber__c != null
                    && !Program_Transaction.CLQ_Portal_Application_Update__c)
                {
                    Program.CLQ_OOS_Program_Number__c = Program_Transaction.CLQ_OOS_ProgramNumber__c;
                    Program.CLQ_Licensing_Specialist__c = Program_Transaction.CLQ_Transaction_Assigned_To__c;
                    
                    ProgramsToUpsert.Add(Program);
                }
            }
            //8 CLQ_COA Amendment Approved
            if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR && Program_Transaction.CLQ_Start_Approval__c == false)
            {
                map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                if (NamedTasks.containsKey(REVIEW_CHANGE_OF_ADMINISTRATOR))
                {
                    Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_ADMINISTRATOR); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
                if (NamedTasks.containsKey(REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW))
                {
                    Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
                if (NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR))
                {
                    Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
            }
            //26    CLQ_ODE Reactivate Approved Transaction
            //27    CLQ_JFS Reactivate Approved Transaction         
            if (RecordTypeName == REACTIVATE_TRANSCATION)
            {
                set<string> ProgramRecordTypes = new set<string> {SCHOOL_AGE_CHILD_CARE,PRE_SCHOOL,CHILD_CARE_CENTER,FCC_TYPE_A_HOME,FCC_TYPE_B_HOME};
                    if (ProgramRecordTypes.contains(Program.RecordType.Name) && Program_Transaction.CLQ_Transaction_Assigned_To__c != null && Program_Transaction.CLQ_Transaction_Assigned_To_Manager__c != null)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    //14805 starts
                    if (NamedTasks.containsKey(REACTIVATE_TRANSACTION_SUBMITTED))
                    {
                        Task TaskToClose = NamedTasks.get(REACTIVATE_TRANSACTION_SUBMITTED); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    //14805 ends
                    if (NamedTasks.containsKey(REVISE_REACTIVATE_TRANSACTION))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_REACTIVATE_TRANSACTION); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE))
                    {
                        Task TaskToClose = NamedTasks.get(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    string EmailTemplate = '';
                    if (Program.RecordType.Name == SCHOOL_AGE_CHILD_CARE || Program.RecordType.Name == PRE_SCHOOL)
                    {
                        EmailTemplate = CLQ_ODE_Email_alert_to_be_sent_if_Reactivation_is_Approved;
                        for(CLQ_Role__c role : GetPTRoles(Program_Transaction.Id, RolesMap.values()))
                        {
                            if (role.Recordtype.Name == PORTAL_ROLES && role.Portal_Roles__c != OCLQSSUTQ && role.Role_Type__c == ODE)
                            {
                                role.CLQ_Transaction_Email_Check__c = true;
                                RolesToUpsert.Add(role);
                            }
                        }
                    }
                    else{
                        EmailTemplate = CLQ_JFS_Email_alert_to_be_sent_if_Reactivation_is_Approved;
                    }
                        
                    CLQ_GlobalWebserviceUtility.sendEmail(EmailTemplate, Program_Transaction.Id);
                }
            }               
            
        }                       
        else if (Program_Transaction.CLQ_Transaction_Status__c == APPROVER_REVIEW_IN_PROGRESS)
        {
            
            if (Program_Transaction.CLQ_Start_Approval__c && Program_Transaction.CLQ_Approved_by_Manager__c == false
                && Program_Transaction.CLQ_Transaction_Assigned_To__c != null
                && Program_Transaction.CLQ_Transaction_Assigned_to_Manager__c != null )
            {
                //7 CLQ_Amendment COA Submit for Approval
                if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_ADMINISTRATOR))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_ADMINISTRATOR); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To_Manager__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(10),APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR,
                                                                         APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR +  request_for  + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
                //25    CLQ_Reactivation Review in Progress
                else if (RecordTypeName == REACTIVATE_TRANSCATION)
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REACTIVATE_TRANSACTION_SUBMITTED))
                    {
                        Task TaskToClose = NamedTasks.get(REACTIVATE_TRANSACTION_SUBMITTED); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVISE_REACTIVATE_TRANSACTION))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_REACTIVATE_TRANSACTION); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_to_Manager__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(7),COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE,
                                                                         COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE +  request_for  + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }                    
                }
                else if (RecordTypeName == AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE || RecordTypeName == AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE)
                {
                    //33    CLQ_COC Submit for Approval
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To_Manager__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(10),APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE,
                                                                         APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE +  request_for  + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }    
                else if (RecordTypeName.contains(CHANGE_OF_LOCATION))
                {
                    //38    CLQ_COL Submit for Approval
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVISE_CHANGE_OF_LOCATION_REVIEW))
                    {
                        Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_LOCATION_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_LOCATION))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_LOCATION); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(APPROVAL_REVIEW_LOCATION_OR_SPACE) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To_Manager__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(20),APPROVAL_REVIEW_LOCATION_OR_SPACE,
                                                                         APPROVAL_REVIEW_LOCATION_OR_SPACE +  request_for + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }                                               
            }     
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == RETURNED_TO_REVIEWER)
        {
            if (Program_Transaction.CLQ_Rejected_By_Manager__c  && !Program_Transaction.CLQ_Portal_Application_Update__c && Program_Transaction.CLQ_Transaction_Assigned_To__c != null)
            {
                //8 CLQ_COA Amendment Approved
                if (RecordTypeName == AMENDMENT_CHANGE_OF_ADMINISTRATOR) 
                {
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_ADMINISTRATOR))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_ADMINISTRATOR); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR))
                    {
                        Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_CHANGE_OF_ADMINISTRATOR); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(7),REVISE_CHANGE_OF_ADMINISTRATOR_REVIEW,
                                                                         REVISE_THE_AMENDMENT + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }            
                else if (RecordTypeName == REACTIVATE_TRANSCATION)
                {
                    //30    CLQ_Reactivate Transaction Rejected
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE))
                    {
                        Task TaskToClose = NamedTasks.get(COMPLETE_REACTIVATION_OF_TEMPORARY_LICENSE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REACTIVATE_TRANSACTION_SUBMITTED))
                    {
                        Task TaskToClose = NamedTasks.get(REACTIVATE_TRANSACTION_SUBMITTED); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVISE_REACTIVATE_TRANSACTION) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(7),REVISE_REACTIVATE_TRANSACTION,
                                                                         REVISE_REACTIVATE_TRANSACTION +  request_for + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }
                else if (RecordTypeName == AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE || RecordTypeName == AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE)
                {
                    //36    CLQ_COC Amendment Rejected
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(10),REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW,
                                                                         REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW + request_for  + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }                            
                else if (RecordTypeName.contains(CHANGE_OF_LOCATION))
                {
                    //38    CLQ_COL Submit for Approval
                    map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                    if (NamedTasks.containsKey(APPROVAL_REVIEW_LOCATION_OR_SPACE))
                    {
                        Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_LOCATION_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (NamedTasks.containsKey(REVIEW_CHANGE_OF_LOCATION))
                    {
                        Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_LOCATION); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                    if (!NamedTasks.containsKey(REVISE_CHANGE_OF_LOCATION_REVIEW) && Program_Transaction.CLQ_Transaction_Status__c != OldRecord.CLQ_Transaction_Status__c)
                    {
                        Task newTask = CLQ_UtilityClass.createTaskrecord(Program_Transaction.CLQ_Transaction_Assigned_To_Manager__c,Program_Transaction.Id,
                                                                         Date.Today().AddDays(7),REVISE_CHANGE_OF_LOCATION_REVIEW,
                                                                         REVISE_CHANGE_OF_LOCATION_REVIEW +  request_for + Program.Name);
                        newTask.Status = OPEN;
                        TasksToUpsert.Add(newTask);
                    }
                }         
            }   
        }
        else if (Program_Transaction.CLQ_Transaction_Status__c == NOT_SUBMITTED)
        {
            //23    CLQ_Portal User Updates_ODE
            if (RecordTypeName == REACTIVATE_TRANSCATION && (Program.RecordType.Name == PRE_SCHOOL || Program.RecordType.Name == SCHOOL_AGE_CHILD_CARE))
            {
                if( Program_Transaction.CLQ_Portal_Application_Update__c == true)
                {
                    for(CLQ_Role__c Role : RolesMap.values())
                    {
                        if (Role.RecordType.Name == PORTAL_ROLES && Role.Portal_Roles__c != OCLQSSUTQ && Role.Role_Type__c == ODE)
                        {
                            Role.CLQ_Transaction_Email_Check__c = true;
                            RolesToUpsert.Add(Role);
                        }
                    }
                }
            }               
        }        
        
        if (Program_Transaction.CLQ_Transaction_Status__c == DENIED || Program_Transaction.CLQ_Transaction_Status__c.contains(Closed))
        {
            if (RecordTypeName.contains(APPLICATION))
            {
                //15    CLQ Transaction Denied
                if (Program_Transaction.CLQ_Approved_by_Manager__c
                    && !Program_Transaction.CLQ_Portal_Application_Update__c)
                {
                    Program.CLQ_License_Issue_Date__c = null;
                    Program.CLQ_License_Registration_Status__c = NOT_LICENSED;                    
                    Program.CLQ_Program_Status__c = DENIED;
                    Program.CLQ_Licensing_Specialist__c = Program_Transaction.CLQ_Transaction_Assigned_To__c;
                    
                    ProgramsToUpsert.Add(Program);
                }
            }
            
        }
        if(Program_Transaction.CLQ_Approved_by_Manager__c == true)
        {
            if (RecordTypeName == AMENDMENT_OCE_AND_CENTER_CHANGE_OF_CAPACITY_SPADCE || RecordTypeName == AMENDEMENT_FCC_CHANGE_OF_CAPACITY_SPACE)
            {
                //35    CLQ_COC Amendment Approved
                map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                if (NamedTasks.containsKey(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW))
                {
                    Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_CAPACITY_OR_SPACE_REVIEW); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
                //if (NamedTasks.containsKey(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                //{
                //    Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_CAPACITY_OR_SPACE);
                //    TaskToClose.Status='Completed';
                //    TasksToUpsert.Add(TaskToClose);
                //}
                if (NamedTasks.containsKey(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE))
                {
                    Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_CHANGE_OF_CAPACITY_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
            }
            else if (RecordTypeName.contains(CHANGE_OF_LOCATION))
            {
                //38    CLQ_COL Submit for Approval
                map<string,Task> NamedTasks = GetPTTaskBySubject(Program_Transaction.ID, TasksMap.values());
                if (NamedTasks.containsKey(APPROVAL_REVIEW_LOCATION_OR_SPACE))
                {
                    Task TaskToClose = NamedTasks.get(APPROVAL_REVIEW_LOCATION_OR_SPACE); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
                if (NamedTasks.containsKey(REVIEW_CHANGE_OF_LOCATION))
                {
                    Task TaskToClose = NamedTasks.get(REVIEW_CHANGE_OF_LOCATION); TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                }
                if (NamedTasks.containsKey(REVISE_CHANGE_OF_LOCATION_REVIEW))
                {
                    Task TaskToClose = NamedTasks.get(REVISE_CHANGE_OF_LOCATION_REVIEW);
                    if (TaskToClose != null)
                    {
                        TaskToClose.Status=COMPLETED; TasksToUpsert.Add(TaskToClose);
                    }
                }
            }                         
        }        
    }
    
    public list<Task> GetPTTasks(Id PTID, list<Task> FullList)
    {
        list<Task> RetList = new list<Task>();
        for(Task item : FullList)
        {
            if (item.WhatId == PTID){
                RetList.Add(item);
            } 
        }
        return RetList;
    }
    public map<string,Task> GetPTTaskBySubject(Id PTID, list<Task> FullList)
    {
        map<string,Task> RetMap = new map<string,Task>();
        list<Task> PTTasks = GetPTTasks( PTID, FullList);
        for(Task tsk : PTTasks) 
        {
            
            if (tsk.Subject != null){
                RetMap.put(tsk.Subject, tsk);
            }
                
        }
        /*for(Task tsk : TasksToUpsert) 
{
system.debug('GetPTTaskBySubject: ' + tsk.Subject + '   ' + tsk);
if (tsk.Subject != null)
RetMap.put(tsk.Subject, tsk);
}*/
        
        return RetMap;
    }    
    public list<CLQ_Role__c> GetPTRoles(Id PTID, list<CLQ_Role__c> FullList)
    {
        list<CLQ_Role__c> RetList = new list<CLQ_Role__c>();
        for(CLQ_Role__c item : FullList)
        {
            if (item.CLQ_Program_Transaction_Source__c == PTID){
                RetList.Add(item);
            } 
        }
        return RetList;
    }
}