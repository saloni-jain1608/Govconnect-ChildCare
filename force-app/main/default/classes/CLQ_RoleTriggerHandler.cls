/**************************************************************************************************************************************************
** User Story: 
***************************************************************************************************************************************************
** Name             : CLQ_RoleTriggerHandler
** Description      : Trigger Handler class for CLQ_RoleTrigger
** Version          : 1.6
**-------------------------------------------------------------------------------------------------------------------------------------------------
**  Modification Log:
**------------------
**  Developer               Date                Version         Description
**--------------------------------------------------------------------------------------------------------------------------------------------------
**  DEV TEAM                10/01/2016          1.0             Created
**  Patrick Culp            06/15/2017          1.1             TFS #11348 - removed condition of no approved pending roles to  etermine if administrator review process is complete as per analysis by Alan Garcia.
**  Neetu Ojha              03/15/2018          1.2             TFS#12077 - Added condition not to update Approved Transaction
**  Pradeep Ravi            04/12/2018          1.3             TFS#12024 - Updating the After Insert and Update not to clone the Role and PT
**  Soufin Rahimeen         07/26/2018          1.5             TFS#12150 : Added logic to update Transaction Updated flag on PT
**  Rahul Roy               09/20/2018          1.6             TFS#14780 : Added logic to update default status as Active for ODE programs
****************************************************************************************************************************************************/ 
public with sharing class CLQ_RoleTriggerHandler extends CLQ_Trigger
{

    public static final String Administrator='Administrator';
    public static final String Resident='Resident';
    public static final String Active='Active';
    public static final String RecordTypeName='RecordType.Name';
    public static final String Not_Submitted='Not Submitted';
    public static final String Contact_Email='CLQ_Contact_Email_Address__c';
    public static final String STANDARD_STRING ='Standard';
    public static final string APPROVED = 'Approved';
    public static final string DENIED = 'Denied';
    public static final string PENDING = 'Pending';
    public static final string PENDING_REMOVAL = 'Pending Removal';
    public static final string CLQ_Pre_School = 'CLQ_Pre_School';
    public static final string CLQ_School_Age_Child_Care = 'CLQ_School_Age_Child_Care';
    public static final string CLQ_Organization_Role = 'CLQ_Organization_Role';
    public static final string Authorized_Representative = 'Authorized Representative';
    public static final string OCLQS_ExceptionMsg = 'An external user cannot modify a Role of an Application in a status of: ';
    public static final string CLQ_Program_Transaction = 'CLQ_Program_Transaction__c';
    public static final string queryStr = ' Id IN :ProgramTransactionIds AND RecordType.Name LIKE \'%Application%\' AND RecordType.name != \'Application - Day Camp\' AND RecordType.name != \'Renew Application - Day Camp\' ';
    public static final string exception2 = 'Some values were modified that are not allowed: ';
    public static final string Pre_School = 'Pre School' ; 
    public static final string School_Age_Child_Care = 'School Age Child Care';
    public static final string Approve = 'Approve';
    public static final string Deny = 'Deny';
    public static final string Withdraw = 'Withdraw';
    public static final string insertString = 'insert';
    public static final string deleteString = 'delete';
    public static final string updateString = 'update';
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger
    {
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
    public override boolean getUpdateFlag()
    {
        return HasUpdated;
    }
    public override void setUpdateFlag(boolean newVal)
    {
        HasUpdated = newVal;
    }
    
    public static Id PreSchoolId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(CLQ_Pre_School).getRecordTypeId();
    public static Id SACCId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(CLQ_School_Age_Child_Care).getRecordTypeId();

    //Calls the Base class Constructor
    public CLQ_RoleTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin, map < id, sObject > oldMapin,
            boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein)
        {
            super(newlistin, newMapin, oldlistin, oldMapin,
                isExecutingin, isInsertin, isUpdatein, isDeletein,
                isBeforein, isAfterin, isUndeletein, sizein);
            BypassInheritedTrigger = BypassTrigger;
                    if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
        }
        ////////////////////////////////     Boilerplate implementation  ////////////////////////////

    //Before insert logic method
    //@param : triggernew, triggernewmap
    //@return : null
    public override void beforeinsert()
    {
        SetRoleParameters((List < CLQ_Role__c > ) newList);//14780
        SetEmptyRole((List < CLQ_Role__c > ) newList);
        //InterceptUpdateAndClone((list<CLQ_Role__c>) newList, (map<Id, CLQ_Role__c>) oldMap);
    }

    //After insert logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterinsert()
    {
        InterceptUpdateAndClone((List < CLQ_Role__c > ) newList, null);
        //OrgWideEmailAddresses((List < CLQ_Role__c > ) newList);
        UpdateAdminReviewOnPTwithDML((Map < id, CLQ_Role__c > ) NewMap);
        updateProgramTransaction((list < CLQ_Role__c > ) newList, (map < id, CLQ_Role__c > ) oldMap, 'insert'); //12150
    }

    //Before update logic method
    //@param : triggernew, triggernewmap
    //@return : null
    public override void beforeupdate()
    {
        SetEmptyRole((List < CLQ_Role__c > ) newList);
        
    }
        
    //After insert logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterupdate()
    {
        InterceptUpdateAndClone((List < CLQ_Role__c > ) newList, (map < Id, CLQ_Role__c > ) oldMap);
        //OrgWideEmailAddresses((List < CLQ_Role__c > ) newList);
        UpdateAdminReviewOnPTwithDML((Map < id, CLQ_Role__c > ) NewMap);
        updateProgramTransaction((list < CLQ_Role__c > ) newList, (map < id, CLQ_Role__c > ) oldMap, 'update'); //12150
    }
    
    //After delete
    public override void AfterDelete() {
        updateProgramTransaction((list < CLQ_Role__c > ) newList, (map < id, CLQ_Role__c > ) oldMap, 'delete'); //12150    
    }  

/*
    //After Delete logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterdelete()
    {
        RemoveOrgWideEmailAddresses((List < CLQ_Role__c > ) OldList);
    }
        
    //After UnDelete logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterundelete()
    {
        OrgWideEmailAddresses((List < CLQ_Role__c > ) newList);
    }
*/
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

    // InterceptUpdateAndClone - The purpose of this method is to create a backup snapshot of an Application if the
    //                          Application has been submitted, and the application is updated by the external user,
    //                          or certain fields are modified by an internal user.
    //
    public void InterceptUpdateAndClone(List < CLQ_Role__c > newList, map < Id, CLQ_Role__c > oldMap)
    {
        Id RecTypId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get(CLQ_Organization_Role).getRecordTypeId();

        set < Id > ProgramTransactionIds = new set < Id > ();
        for (CLQ_Role__c role: newList)
        {
            if (role.CLQ_Role__c != Authorized_Representative || role.RecordTypeId != RecTypId){ 
                continue;
            }
            ProgramTransactionIds.Add(role.CLQ_Program_Transaction_Source__c);
        }
        if (ProgramTransactionIds.IsEmpty()){
            return;
        } 
        list < string > ExtraFields = new list < string >
        {
            RecordTypeName
        };
        //TFS#12024 - Updating the After Insert and Update not to clone the Role and PT
        string QueryString = CLQ_UtilityClass.createSOQLQuery(CLQ_Program_Transaction,
           queryStr , ExtraFields); //13554
        list < CLQ_Program_Transaction__c > sobjList = (list < CLQ_Program_Transaction__c > ) Database.query(QueryString);
        map < id, CLQ_Program_Transaction__c > ProgramTransactionsMap = new map < id, CLQ_Program_Transaction__c > (sobjList);

        /*      map<id, CLQ_Program_Transaction__c> ProgramTransactionsMap = new map<id, CLQ_Program_Transaction__c> (
                                                                        [SELECT Id, CLQ_Transaction_Status__c, RecordType.Name,CLQ_External_User_Can_Edit__c
                                                                        FROM CLQ_Program_Transaction__c
                                                                        WHERE Id IN :ProgramTransactionIds
                                                                        AND RecordType.Name LIKE '%Application%']); */
        if (ProgramTransactionsMap.IsEmpty()){
            return;
        } 
        list<CLQ_Role__c> backuplist=new list<CLQ_Role__c>();
        list<CLQ_Program_Transaction__c> BackupProgramTransactionlist=new list<CLQ_Program_Transaction__c>();
        for (CLQ_Role__c role: newList)
        {
            CLQ_Program_Transaction__c ProgramTransaction;
            if (role.CLQ_Role__c != Authorized_Representative){ continue;}
            if(ProgramTransactionsMap.size()>0){ ProgramTransaction = ProgramTransactionsMap.get(role.CLQ_Program_Transaction_Source__c);}
            if (ProgramTransaction == null){continue;}
            if (ProgramTransaction.CLQ_Transaction_Status__c == Not_Submitted){continue;}
            if (UserInfo.getUserType() == STANDARD_STRING && !Global_Settings__c.getInstance().RunTriggerAsPortal__c){ continue;}
            CLQ_Role__c oldRecord;
            if (oldMap != null || oldMap.size()>0){ oldRecord = oldMap.get(role.Id);}

            boolean ShouldBackup = ShouldBackup(role, OldRecord);
            if (!ShouldBackup){
                continue;
            } 

            if (!ProgramTransaction.CLQ_External_User_Can_Edit__c){
                throw new OCLQS_Exception(OCLQS_ExceptionMsg + ProgramTransaction.CLQ_Transaction_Status__c);
            }
     
            CLQ_Program_Transaction__c BackupProgramTransaction;
            if (OldRecord != null)
            {
                CLQ_Role__c Backup = (CLQ_Role__c) MakeVersionBackup(role.Id);
                backuplist.add(Backup);
                //insert Backup;
                BackupProgramTransaction = CLQ_CloneUtility.CloneProgramTransaction(ProgramTransaction, role.Id, Backup.Id);
            }
            else{
                BackupProgramTransaction = CLQ_CloneUtility.CloneProgramTransaction(ProgramTransaction, role.Id, null);
            }
                

            if (BackupProgramTransaction != null)
            {
                if ((UserInfo.getUserType() != STANDARD_STRING || Global_Settings__c.getInstance().RunTriggerAsPortal__c) && ProgramTransaction.CLQ_External_User_Can_Edit__c)
                {
                    //An update by the external user will Set this version to 'Not Submitted'
                    ProgramTransaction.CLQ_Transaction_Status__c = Not_Submitted;
                }
                BackupProgramTransactionlist.add(BackupProgramTransaction);
                //insert BackupProgramTransaction;
            }
        }
        if(!backuplist.isEmpty()){
            insert backuplist;
        }
        if(!BackupProgramTransactionlist.isEmpty()){
            insert BackupProgramTransactionlist;
        }
    }

    private static set < string > AllowedEditWithVersioning = new set < string >
    {
        //  Authorized Representative Information           CLQ_Role__c = 'Authorized Representative'
        //  Applicant's History on Org Role - Editable for all roles (Owners, Partners and Authorized Rep)
        //      Are you currently Licensed?                 
        'CLQ_Are_you_currently_Licensed__c',
        //      Program Number                              
        'CLQ_Program_Number__c',
        //      License Revoked Previously                  
        'CLQ_License_Revoked_Previously__c',
        //      Certified/Licensed by another State         
        'CLQ_Certified_Licensed_by_other_state__c',
        //      States                                      
        'CLQ_States__c',
        //      Certified as Provider within past 5 yrs     
        'CLQ_Certified_as_Provider_within_past_5__c',
        //      2. Program Number                           
        'CLQ_X2_Program_Number__c',
        //      Licensed as Provider within past 5 yrs      
        'CLQ_Licensed_as_Provider_within_past5yrs__c',
        //      3. Program Number                           
        'CLQ_X3_License_No__c',
            'CLQ_Portal_New_Role__c'

    };
    private static set < string > AllowedEditWithOutVersioning = new set < string >
    {
        Contact_Email
    };

    public boolean ShouldBackup(CLQ_Role__c NewRecord, CLQ_Role__c OldRecord)
    {
        set < string > ModifiedFields = AllowedToModifyCertainFieldsWithoutVersioning(NewRecord, OldRecord);
        ModifiedFields.removeAll(AllowedEditWithOutVersioning);
        boolean ExcThrow=true;
        if (ModifiedFields.IsEmpty()){
            return false; //No reason to make a backup version
            }
        ModifiedFields.removeAll(AllowedEditWithVersioning);
        if (ModifiedFields.IsEmpty() || OldRecord == null){
            return true; //Some fields were modified that require versioning
            }
        else{
            if(ExcThrow){
                throw new OCLQS_Exception(exception2  + ModifiedFields);
                }
            }
        //Should never get here
        return false;
       
    }
    
    public set < string > AllowedToModifyCertainFieldsWithoutVersioning(CLQ_Role__c NewRecord, CLQ_Role__c OldRecord)
    {
        set < string > ModifiedFields = FindModifiedFields(NewRecord, OldRecord);
        return ModifiedFields;
    }
    private static set < string > SkipTheseItems = new set < string >
    {
        'id',
        'isdeleted',
        'name',
        'createdby',
        'lastmodifiedby',
        'recordtype',
        'createddate',
        'lastmodifieddate',
        'createdbyid',
        'lastmodifiedbyid',
        'systemmodstamp',
        'lastactivitydate',
        'lastvieweddate',
        'lastreferenceddate'
    };
    public static set < string > FindModifiedFields(CLQ_Role__c NewRecord, CLQ_Role__c OldRecord)
    {
        set < string > Modified = new set < string > ();
        // Get the field describe result for the Name field on the Account object
        map < string, Schema.SObjectField > FieldMap = Schema.sObjectType.CLQ_Role__c.fields.getmap();
        for (string FieldName: FieldMap.KeySet())
        {
            if (!SkipTheseItems.contains(FieldName))
            {
                Schema.DescribeFieldResult dfr;
                if(FieldMap.size()>0){dfr= FieldMap.get(FieldName).getDescribe();}
                //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                if (dfr.isUpdateable())
                {
                    if (OldRecord == null)
                    {
                        Modified.Add(dfr.getName());
                    }
                    else if (NewRecord.get(FieldName) != OldRecord.get(FieldName))
                    {
                        //system.debug('FindModifiedFields: ' + FieldName + ' New: ' + NewRecord.get(FieldName) + ' Old: ' + OldRecord.get(FieldName));
                        Modified.Add(dfr.getName());
                    }
                }
            }
        }
        return Modified;
    }

    // SetEmptyRole - The purpose of this method is to Set the default value of Role for the RecordType if it is empty
    //
    public void SetEmptyRole(List < CLQ_Role__c > newList)
    {

        // Administrator,Staff,Owner,Complainant,Child,Resident,On-site Contact,Authorized Representative,Partner,Alternate On Site Contact,Parent
        map < string, string > RecordTypeToRole = new map < string, string > { Administrator => Administrator, Resident => Resident  };
        map < Id, RecordType > RecordTypes = new map < Id, RecordType > ([SELECT Id, Name, DeveloperName FROM RecordType  WHERE sobjectType = 'CLQ_Role__c' ]);
        set < Id > ContactIds = new set < Id > ();
        for (CLQ_Role__c role: newList)
        {
            if (role.CLQ_Contact__c != null){
                ContactIds.Add(role.CLQ_Contact__c);
            } 
            if (string.IsBlank(role.CLQ_Role__c) && RecordTypes.containsKey(role.RecordTypeId))
            {
                string RecordTypeName = RecordTypes.get(role.RecordTypeId).Name;
                if (RecordTypeToRole.ContainsKey(RecordTypeName)){
                    role.CLQ_Role__c = RecordTypeToRole.get(RecordTypeName);
                }
            }
        }
        if (ContactIds.IsEmpty()){
            return;
        } 
        map < Id, Contact > ContactMap;
        if(ContactIds!=null){
            ContactMap = new map < Id, Contact > ([SELECT Id, Email, AccountId FROM Contact WHERE Id IN: ContactIds]);
        }

        for (CLQ_Role__c role: newList)
        {
            Contact Contact;
            if(ContactMap.size()>0){Contact= ContactMap.get(role.CLQ_Contact__c);}
            if (Contact != null){
                role.CLQ_Contact_Email_Address__c = Contact.Email;
            }
                
        }
    }
    
    //14780 - Method to set Role fields
    public void SetRoleParameters(List < CLQ_Role__c > lstRole){
        if (lstRole != null && !lstRole.isEmpty() ) {
            for(CLQ_Role__c roleObj : lstRole){
                if(roleObj.CLQ_Program_Type_Formula__c == Pre_School || roleObj.CLQ_Program_Type_Formula__c == School_Age_Child_Care){
                    roleObj.CLQ_Status__c = Active;
                }
            }
        }
    }
    
    public void UpdateAdminReviewOnPTwithDML(map < id, CLQ_Role__c > NewMap){
        List < CLQ_Program_Transaction__c > PtListToUpdate= new List < CLQ_Program_Transaction__c >();
        PtListToUpdate = UpdateAdminReviewOnPT(NewMap , null);
        if (PtListToUpdate != null && !PtListToUpdate.isEmpty() )
        {
            boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            CLQ_Trigger.BypassAllTriggers = true;
            update PtListToUpdate;
            CLQ_Trigger.BypassAllTriggers = PreviousValue;
        }
    }
    
    // Method created by LD:- Story 675 to update CLQ_Administrator_Review_Complete__c on PT
    public List < CLQ_Program_Transaction__c > UpdateAdminReviewOnPT(map < id, CLQ_Role__c > NewMap, List<CLQ_Program_Transaction__c> newPTList)
    {

        set < Id > PTIdSet = new set < Id > ();
        List < CLQ_Program_Transaction__c > PTList = null;
        for (CLQ_Role__c r: NewMap.Values())
        {
            if (r.CLQ_Program_Transaction_Source__c != null){
                PTIdSet.add(r.CLQ_Program_Transaction_Source__c);
            }
                
        }
        if (PTIdSet.IsEmpty()){return null;}
        List < CLQ_Role__c > roleList;
        if(PTIdSet!=null){
            roleList = new List < CLQ_Role__c > ([Select Id, Name, CLQ_Status__c, CLQ_Decision__c from CLQ_Role__c where CLQ_Program_Transaction_Source__c in
            : PTIdSet AND(CLQ_Status__c = 'Pending'
                OR CLQ_Status__c = 'Pending Removal' OR CLQ_Status__c ='Active')
        ]);
        }
        
        List < CLQ_Role__c > AppRoleList = new list < CLQ_Role__c > ();
        List < CLQ_Role__c > ActiveRoleList = new list < CLQ_Role__c > ();
        List < CLQ_Role__c > NonAppRoleList = new list < CLQ_Role__c > ();
        List < CLQ_Role__c > DeniedRoleList = new list < CLQ_Role__c > ();
        Map < Id,CLQ_Program_Transaction__c > PTListToUpdate = new Map < Id,CLQ_Program_Transaction__c > ();

        for (CLQ_Role__c r: RoleList)
        {
          
            //system.debug('VJ CLQ_Contact_Name__c' + r.CLQ_Contact_Name__c);
            
            //Active Roles
            if (r.CLQ_Status__c == Active){
                ActiveRoleList.add(r);
            }
                
            
            //Approved Roles
            if (r.CLQ_Decision__c == APPROVED && (r.CLQ_Status__c == PENDING || r.CLQ_Status__c == PENDING_REMOVAL)){
                AppRoleList.add(r);
            }
                

            //Denied Roles
            if (r.CLQ_Decision__c == DENIED && (r.CLQ_Status__c == PENDING || r.CLQ_Status__c == PENDING_REMOVAL)){
                DeniedRoleList.add(r);
            }
                

            //No Decision
            if ((r.CLQ_Status__c == PENDING || r.CLQ_Status__c == PENDING_REMOVAL) && r.CLQ_Decision__c == null){
                NonAppRoleList.add(r);
            }
                
        }
        
        if (newPTList == null){
            system.debug('');
            if(PTIdSet!=null){
                PTList = new List < CLQ_Program_Transaction__c > ([SELECT id, CLQ_Recommendation__c,CLQ_Transaction_Status__c,
                CLQ_Administrator_Review_Complete__c, RecordType.Name FROM CLQ_Program_Transaction__c WHERE Id IN: PTIdSet]);
            }
             
        }
        else{
            PTList = newPTList;
        }

        for (CLQ_Program_Transaction__c pt: PTList)
        {
            system.debug('**** 1 ****');
            //if (!pt.RecordType.Name.containsIgnoreCase('Amendment - Change of Administrator')){
            if (pt.CLQ_Transaction_Status__c != APPROVED && (pt.CLQ_Recommendation__c == Approve || pt.CLQ_Recommendation__c == null)){ //12077
                system.debug('**** 2 ****');
                //pc 06/15/17 - removing condition of no approved pending roles to determine if review process is complete
                //if (RoleList.size() > 0 && (NonAppRoleList.size() == 0 && (ActiveRoleList.size() + AppRoleList.size() <= 3 && AppRoleList.size() > 0)))
                if (RoleList.size() > 0 && (NonAppRoleList.size() == 0 && (ActiveRoleList.size() + AppRoleList.size() <= 3 )))
                {
                    system.debug('**** 3 ****');
                    pt.CLQ_Administrator_Review_Complete__c = true;
                    PtListToUpdate.put(pt.Id,pt);
                }
                else{
                    system.debug('**** 4 ****');
                    pt.CLQ_Administrator_Review_Complete__c = false;
                    PtListToUpdate.put(pt.Id,pt);
                }
            }
            
            if (pt.CLQ_Recommendation__c == Deny || pt.CLQ_Recommendation__c == Withdraw){ 
            system.debug('**** 5 ****');    
               if (RoleList.size() > 0 && AppRoleList.size() == 0){
                  system.debug('**** 6 ****');
                    pt.CLQ_Administrator_Review_Complete__c = true;
                    PtListToUpdate.put(pt.Id,pt);
               }
               else{
                   system.debug('**** 7 ****');
                   pt.CLQ_Administrator_Review_Complete__c = false;
                   PtListToUpdate.put(pt.Id,pt);
               }
            }

            if(pt.CLQ_Administrator_Review_Complete__c && pt.CLQ_Transaction_Status__c != APPROVED){//12077
                system.debug('**** 8 ****');
                if (RoleList.size() > 0 && (NonAppRoleList.size() > 0)){
                    system.debug('**** 9 ****');
                    pt.CLQ_Administrator_Review_Complete__c = false;
                    PtListToUpdate.put(pt.Id,pt);
                }
            }
        }
        return PtListToUpdate.values();
        //Update PT.CLQ_Administrator_Review_Complete__c status = True
        //if (!PtListToUpdate.isEmpty())
        //{
            //boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            //CLQ_Trigger.BypassAllTriggers = true;
            //update PtListToUpdate.values();
            //CLQ_Trigger.BypassAllTriggers = PreviousValue;
        //}
    }
/*
    public void OrgWideEmailAddresses(list < CLQ_Role__c > NewList)
    {
        System.debug('NEW LIST ' + NewList);
        //CLQ_Org_Wide_Email_Addresses__c
        //CLQ_Program_Wide_Email_Addresses__c
        set < string > PortalRoles = new set < string > { 'OCLQSOwner',  'OCLQSLicensing',   'OCLQSAdministrator'  };
        set<string> SUTQPortalRoles = new set<String> {'OCLQSOwner',  'OCLQSSUTQ',   'OCLQSAdministrator'};
        //set<string> SUTQSecondaryRoles = new set<string> {'OCLQSPS','OCLQSSACC'};
        set < Id > AccountIdsSUTQ = new set < Id > ();
        set < Id > ProgramIdsSUTQ = new set < Id > ();
        set < Id > AccountIds = new set < Id > ();
        set < Id > ProgramIds = new set < Id > ();
        for (CLQ_Role__c role: newList)
        {
            if (role.Role_Type__c == 'ODE' && PortalRoles.contains(role.Portal_Roles__c))
            {
                if (role.CLQ_Program__c != null) ProgramIds.Add(role.CLQ_Program__c);
                if (role.CLQ_Organization__c != null) AccountIds.Add(role.CLQ_Organization__c);
            }
            //Condition for ODE SUTQ emails
            if(role.Role_Type__c == 'ODE' && SUTQPortalRoles.contains(role.Portal_Roles__c)){
                if (role.CLQ_Program__c != null) ProgramIdsSUTQ.Add(role.CLQ_Program__c);
                if(role.Secondary_Role__c != null  && (role.Secondary_Role__c.contains(Label.SecondaryRolePreSchool) || role.Secondary_Role__c.contains(Label.SecondaryRoleSACC))){
                    if (role.CLQ_Organization__c != null) AccountIdsSUTQ.Add(role.CLQ_Organization__c);
                }
            }
        }
       // if (ProgramIds.IsEmpty() && AccountIds.IsEmpty()) return;
        //get associated ODE SUTQ Items START 
        if (ProgramIdsSUTQ.IsEmpty() && AccountIdsSUTQ.IsEmpty()) return;
       // if(!ProgramIdsSUTQ.IsEmpty() || !AccountIdsSUTQ.IsEmpty()){
            map < Id, CLQ_Program__c > SUTQProgramMap = new map < Id, CLQ_Program__c > (
            [SELECT Id, CLQ_Program_Wide_Email_Addresses_SUTQ__c, CLQ_Org_Wide_Email_Addresses_SUTQ__c,
                CLQ_Associated_Organization__c, RecordTypeId
                FROM CLQ_Program__c
                WHERE Id IN: ProgramIdsSUTQ
                OR CLQ_Associated_Organization__c IN: AccountIdsSUTQ ]);
                
            map < Id, list < CLQ_Program__c >> SUTQAccountProgramMap = new map < Id, list < CLQ_Program__c >> ();
            for (CLQ_Program__c prog: SUTQProgramMap.values()){
                AccountIdsSUTQ.Add(prog.CLQ_Associated_Organization__c);
                if (!SUTQAccountProgramMap.ContainsKey(prog.CLQ_Associated_Organization__c))
                    SUTQAccountProgramMap.put(prog.CLQ_Associated_Organization__c, new list < CLQ_Program__c > ());
                SUTQAccountProgramMap.get(prog.CLQ_Associated_Organization__c).Add(prog);
            }
            map < Id, Account > SUTQAccountMap = new map < Id, Account > (
                [SELECT Id, Org_Wide_Email_Addresses_SUTQPS__c,Org_Wide_Email_Addresses_SUTQSACC__c
                    FROM Account WHERE Id IN: AccountIdsSUTQ ]);
            //}
        //get associated ODE SUTQ Items END
        //Get associated Items
        map < Id, CLQ_Program__c > ProgramMap = new map < Id, CLQ_Program__c > (
            [SELECT Id, CLQ_Org_Wide_Email_Addresses__c, CLQ_Program_Wide_Email_Addresses__c,
                CLQ_Associated_Organization__c
                FROM CLQ_Program__c
                WHERE Id IN: ProgramIds
                OR CLQ_Associated_Organization__c IN: AccountIds ]);
        map < Id, list < CLQ_Program__c >> AccountProgramMap = new map < Id, list < CLQ_Program__c >> ();
        for (CLQ_Program__c prog: ProgramMap.values())
        {
            AccountIds.Add(prog.CLQ_Associated_Organization__c);
            if (!AccountProgramMap.ContainsKey(prog.CLQ_Associated_Organization__c))
                AccountProgramMap.put(prog.CLQ_Associated_Organization__c, new list < CLQ_Program__c > ());
            AccountProgramMap.get(prog.CLQ_Associated_Organization__c).Add(prog);
        }
        map < Id, Account > AccountMap = new map < Id, Account > (
            [SELECT Id, CLQ_Org_Wide_Email_Addresses__c
                FROM Account WHERE Id IN: AccountIds ]);

        //Now, update the items as necessary
        map < Id, CLQ_Program__c > UpdateProgramMap = new map < Id, CLQ_Program__c > ();
        map < Id, Account > UpdateAccountMap = new map < Id, Account > ();
        // update maps for the sutq items 
        map < Id, CLQ_Program__c > SUTQUpdateProgramMap = new map < Id, CLQ_Program__c > ();
        map < Id, Account > SUTQUpdateAccountMap = new map < Id, Account > ();
        for (CLQ_Role__c role: newList)
        {
            String oldEmailAddress ; 
            CLQ_Role__c oldoRole = new CLQ_Role__c();
            if(isUpdate){
                if(oldMap.get(role.id) != null){
                    oldoRole = (CLQ_Role__c)oldMap.get(role.id);
                    oldEmailAddress = oldoRole.CLQ_Contact_Email_Address__c;
                }
            }
            string EmailAddress = role.CLQ_Contact_Email_Address__c;
            
            system.Debug('Found Contact Email address: ' + EmailAddress);
            system.Debug('Found OLD Contact Email address: ' + oldEmailAddress);
            if (string.IsNotBlank(EmailAddress))
            {
                //If this a program level Role
                if (role.CLQ_Program__c != null)
                {
                    CLQ_Program__c Program = ProgramMap.get(role.CLQ_Program__c);
                    if (Program != null)
                    {
                        system.Debug('Found Program: ' + Program);
                        if (string.IsBlank(Program.CLQ_Program_Wide_Email_Addresses__c))
                        {
                            Program.CLQ_Program_Wide_Email_Addresses__c = EmailAddress;
                            UpdateProgramMap.put(Program.Id, Program);
                        }
                        else if (!Program.CLQ_Program_Wide_Email_Addresses__c.Contains(EmailAddress))
                        {
                            list < string > Emails = Program.CLQ_Program_Wide_Email_Addresses__c.split(';');
                            Emails.Add(EmailAddress);
                            Program.CLQ_Program_Wide_Email_Addresses__c = string.Join(Emails, ';');
                            UpdateProgramMap.put(Program.Id, Program);
                        }
                    }
                    //SUTQ programs
                    CLQ_Program__c SUTQProgram = SUTQProgramMap.get(role.CLQ_Program__c);
                    if (SUTQProgram != null)
                    {
                        system.Debug('Found Program: ' + SUTQProgram);
                        if (string.IsBlank(SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c))
                        {
                            SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c = EmailAddress;
                            SUTQUpdateProgramMap.put(SUTQProgram.Id, SUTQProgram);
                        }
                        else if (!SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c.Contains(EmailAddress))
                        {
                            list < string > Emails = SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c.split(';');
                            if(isInsert){
                                Emails.Add(EmailAddress);
                            }
                            if(isUpdate){
                                if(EmailAddress != oldEmailAddress){
                                    for(Integer i = 0; i < Emails.size(); i++){
                                        if (Emails.get(i) == oldEmailAddress){
                                            Emails.remove(i);
                                            i--;
                                        }
                                    }
                                    Emails.Add(EmailAddress);
                                }
                            }
                            SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c = string.Join(Emails, ';');
                            System.debug('Updated CLQ_Program_Wide_Email_Addresses_SUTQ__c' + SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c);
                            SUTQUpdateProgramMap.put(SUTQProgram.Id, SUTQProgram);
                        }
                    }
                }
                //If this is a Organization level Role
                if (role.CLQ_Organization__c != null)
                {
                    Account Account = AccountMap.get(role.CLQ_Organization__c);
                    if (Account != null)
                    {
                        system.Debug('Found Account: ' + Account);
                        if (string.IsBlank(Account.CLQ_Org_Wide_Email_Addresses__c))
                        {
                            Account.CLQ_Org_Wide_Email_Addresses__c = EmailAddress;
                            UpdateAccountMap.put(Account.Id, Account);
                            //Going to need to update these below
                            list<CLQ_Program__c> AccountPrograms = AccountProgramMap.get(Account.Id);
                            if (AccountPrograms != null)
                            {
                                for (CLQ_Program__c AccountProgram: AccountProgramMap.get(Account.Id))
                                    UpdateProgramMap.put(AccountProgram.Id, AccountProgram);
                            }
                        }
                        else if (!Account.CLQ_Org_Wide_Email_Addresses__c.Contains(EmailAddress))
                        {
                            list < string > Emails = Account.CLQ_Org_Wide_Email_Addresses__c.split(';');
                            Emails.Add(EmailAddress);
                            Account.CLQ_Org_Wide_Email_Addresses__c = string.Join(Emails, ';');
                            UpdateAccountMap.put(Account.Id, Account);
                            //Going to need to update these below
                            list<CLQ_Program__c> AccountPrograms = AccountProgramMap.get(Account.Id);
                            if (AccountPrograms != null)
                            {
                                for (CLQ_Program__c AccountProgram: AccountProgramMap.get(Account.Id))
                                    UpdateProgramMap.put(AccountProgram.Id, AccountProgram);
                            }
                        }
                    }
                    
                    //SUTQ Accounts
                    Account SUTQAccount = SUTQAccountMap.get(role.CLQ_Organization__c);
                    if (SUTQAccount != null)
                    {
                        system.Debug('Found SUTQ Account: ' + SUTQAccount);
                        //For PS
                        if (string.IsBlank(SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c))
                        {
                            if(role.Secondary_Role__c.Contains(Label.SecondaryRolePreSchool)){
                                SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c = EmailAddress;
                                SYSTEM.DEBUG('sutq pre school email address blank'+ SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c);
                            }
                            SUTQUpdateAccountMap.put(SUTQAccount.Id, SUTQAccount);
                            //Going to need to update these below
                            list<CLQ_Program__c> SUTQAccountPrograms = SUTQAccountProgramMap.get(SUTQAccount.Id);
                            if (SUTQAccountPrograms != null)
                            {
                                for (CLQ_Program__c SUTQAccountProgram: SUTQAccountProgramMap.get(SUTQAccount.Id))
                                    SUTQUpdateProgramMap.put(SUTQAccountProgram.Id, SUTQAccountProgram);
                            }
                        }
                        else if (!SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c.Contains(EmailAddress))
                        {
                            list < string > Emails = SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c.split(';');
                            if(role.Secondary_Role__c.Contains(Label.SecondaryRolePreSchool)){
                                if(isInsert){
                                Emails.Add(EmailAddress);
                                }
                                if(isUpdate){
                                    if(EmailAddress != oldEmailAddress){
                                        for(Integer i = 0; i < Emails.size(); i++){
                                            if (Emails.get(i) == oldEmailAddress){
                                                Emails.remove(i);
                                                i--;
                                            }
                                        }
                                        Emails.Add(EmailAddress);
                                    }
                                }
                            }
                            SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c = string.Join(Emails, ';');
                            SYSTEM.DEBUG('sutq pre school email address final'+ SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c);
                            SUTQUpdateAccountMap.put(SUTQAccount.Id, SUTQAccount);
                            //Going to need to update these below
                            list<CLQ_Program__c> SUTQAccountPrograms = SUTQAccountProgramMap.get(SUTQAccount.Id);
                            if (SUTQAccountPrograms != null)
                            {
                                for (CLQ_Program__c SUTQAccountProgram: SUTQAccountProgramMap.get(SUTQAccount.Id))
                                    SUTQUpdateProgramMap.put(SUTQAccountProgram.Id, SUTQAccountProgram);
                            }
                        }
                        //for SACC
                        if (string.IsBlank(SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c))
                        {
                            if(role.Secondary_Role__c.Contains(Label.SecondaryRoleSACC)){
                                SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c = EmailAddress;
                            }
                            SUTQUpdateAccountMap.put(SUTQAccount.Id, SUTQAccount);
                            //Going to need to update these below
                            list<CLQ_Program__c> SUTQAccountPrograms = SUTQAccountProgramMap.get(SUTQAccount.Id);
                            if (SUTQAccountPrograms != null)
                            {
                                for (CLQ_Program__c SUTQAccountProgram: SUTQAccountProgramMap.get(SUTQAccount.Id))
                                    SUTQUpdateProgramMap.put(SUTQAccountProgram.Id, SUTQAccountProgram);
                            }
                        }
                        else if (!SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c.Contains(EmailAddress))
                        {
                            list < string > Emails = SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c.split(';');
                            if(role.Secondary_Role__c.Contains(Label.SecondaryRoleSACC)){
                                if(isInsert){
                                Emails.Add(EmailAddress);
                                }
                                if(isUpdate){
                                    if(EmailAddress != oldEmailAddress){
                                        for(Integer i = 0; i < Emails.size(); i++){
                                            if (Emails.get(i) == oldEmailAddress){
                                                Emails.remove(i);
                                                i--;
                                            }
                                        }
                                        Emails.Add(EmailAddress);
                                    }
                                }
                            }
                            SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c = string.Join(Emails, ';');
                            SUTQUpdateAccountMap.put(SUTQAccount.Id, SUTQAccount);
                            //Going to need to update these below
                            list<CLQ_Program__c> SUTQAccountPrograms = SUTQAccountProgramMap.get(SUTQAccount.Id);
                            if (SUTQAccountPrograms != null)
                            {
                                for (CLQ_Program__c SUTQAccountProgram: SUTQAccountProgramMap.get(SUTQAccount.Id))
                                    SUTQUpdateProgramMap.put(SUTQAccountProgram.Id, SUTQAccountProgram);
                            }
                        }
                    }
                }
            }

        }
        //Final Updates for the Programs        
        for (CLQ_Program__c Program: UpdateProgramMap.Values())
        {
            Account Account = AccountMap.get(Program.CLQ_Associated_Organization__c);
            
            list < string > Emails = new list < string > ();
            if (Account != null && string.IsNotBlank(Account.CLQ_Org_Wide_Email_Addresses__c))
                Emails.AddAll(Account.CLQ_Org_Wide_Email_Addresses__c.split(';'));
            if (string.IsNotBlank(Program.CLQ_Program_Wide_Email_Addresses__c))
                Emails.AddAll(Program.CLQ_Program_Wide_Email_Addresses__c.split(';'));
            if (Emails.size() > 0)
                Program.CLQ_Org_Wide_Email_Addresses__c = string.Join(Emails, ';');
            else
                Program.CLQ_Org_Wide_Email_Addresses__c = null;
            system.Debug('Set Program.CLQ_Org_Wide_Email_Addresses__c: ' + Program.CLQ_Org_Wide_Email_Addresses__c);
        }
        
        //final updates for the SUTQ Programs 
        for (CLQ_Program__c SUTQProgram: SUTQUpdateProgramMap.Values())
        {
            Account SUTQAccount = SUTQAccountMap.get(SUTQProgram.CLQ_Associated_Organization__c);
            
            list < string > Emails = new list < string > ();
            if (SUTQAccount != null && SUTQProgram.RecordTypeId == PreSchoolId  && string.IsNotBlank(SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c))
                SYSTEM.DEBUG('sutq pre school email address'+ SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c);
            if(SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c != null )
            {    
                Emails.AddAll(SUTQAccount.Org_Wide_Email_Addresses_SUTQPS__c.split(';'));
            }
            if (SUTQAccount != null && SUTQProgram.RecordTypeId == SACCId && string.IsNotBlank(SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c))
                Emails.AddAll(SUTQAccount.Org_Wide_Email_Addresses_SUTQSACC__c.split(';'));
           
            if (string.IsNotBlank(SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c))
                Emails.AddAll(SUTQProgram.CLQ_Program_Wide_Email_Addresses_SUTQ__c.split(';'));
            if (Emails.size() > 0)
                SUTQProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c = string.Join(Emails, ';');
                
            else
                SUTQProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c = null;
            system.Debug('Set SUTQProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c: ' + SUTQProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c);
        }
        
        boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
        CLQ_Trigger.BypassAllTriggers = true;

        if (UpdateProgramMap.size() > 0)
            update UpdateProgramMap.values();
        if (UpdateAccountMap.size() > 0)
            update UpdateAccountMap.values();
        
        if (SUTQUpdateProgramMap.size() > 0)
            update SUTQUpdateProgramMap.values();
        if (SUTQUpdateAccountMap.size() > 0)
            update SUTQUpdateAccountMap.values();

        CLQ_Trigger.BypassAllTriggers = PreviousValue;

    }

    public void RemoveOrgWideEmailAddresses(list < CLQ_Role__c > OldList)
    {
        set < Id > AccountIds = new set < Id > ();
        set < Id > ProgramIds = new set < Id > ();
        for (CLQ_Role__c role: OldList)
        {
            if (string.IsNotBlank(role.CLQ_Contact_Email_Address__c) && role.Role_Type__c == 'ODE')
            {
                if (role.CLQ_Program__c != null) ProgramIds.Add(role.CLQ_Program__c);
                if (role.CLQ_Organization__c != null) AccountIds.Add(role.CLQ_Organization__c);
                system.debug('Removing an email address from Programs: ' + role.CLQ_Contact_Email_Address__c);
            }
        }
        if (ProgramIds.IsEmpty() && AccountIds.IsEmpty()) return;

        //Get associated Items
        map < Id, CLQ_Program__c > ProgramMap = new map < Id, CLQ_Program__c > (
            [SELECT Id, CLQ_Org_Wide_Email_Addresses__c, CLQ_Program_Wide_Email_Addresses__c,
                CLQ_Associated_Organization__c , CLQ_Program_Wide_Email_Addresses_SUTQ__c, CLQ_Org_Wide_Email_Addresses_SUTQ__c
                FROM CLQ_Program__c
                WHERE Id IN: ProgramIds
                OR CLQ_Associated_Organization__c IN: AccountIds ]);
        map < Id, list < CLQ_Program__c >> AccountProgramMap = new map < Id, list < CLQ_Program__c >> ();
        for (CLQ_Program__c prog: ProgramMap.values())
        {
            AccountIds.Add(prog.CLQ_Associated_Organization__c);
            if (!AccountProgramMap.ContainsKey(prog.CLQ_Associated_Organization__c))
                AccountProgramMap.put(prog.CLQ_Associated_Organization__c, new list < CLQ_Program__c > ());
            AccountProgramMap.get(prog.CLQ_Associated_Organization__c).Add(prog);
        }
        map < Id, Account > AccountMap = new map < Id, Account > (
            [SELECT Id, CLQ_Org_Wide_Email_Addresses__c , Org_Wide_Email_Addresses_SUTQPS__c,Org_Wide_Email_Addresses_SUTQSACC__c
                FROM Account WHERE Id IN: AccountIds ]);

        //Now, update the items as necessary
        map < Id, CLQ_Program__c > UpdateProgramMap = new map < Id, CLQ_Program__c > ();
        map < Id, Account > UpdateAccountMap = new map < Id, Account > ();

        for (CLQ_Role__c role: OldList)
        {
            string EmailAddress = role.CLQ_Contact_Email_Address__c.ToLowerCase();
            system.Debug('Program.Looking for: ' + EmailAddress);
            if (string.IsNotBlank(EmailAddress))
            {
                //If this a program level Role
                if (role.CLQ_Program__c != null)
                {
                    CLQ_Program__c Program = ProgramMap.get(role.CLQ_Program__c);
                    if (Program != null)
                    {
                        system.Debug('Program.CLQ_Program_Wide_Email_Addresses__c: ' + Program.CLQ_Program_Wide_Email_Addresses__c);
                        if (string.IsNotBlank(Program.CLQ_Program_Wide_Email_Addresses__c))
                        {
                            if (string.isNotBlank(Program.CLQ_Program_Wide_Email_Addresses__c))
                            {
                                Program.CLQ_Program_Wide_Email_Addresses__c = Program.CLQ_Program_Wide_Email_Addresses__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                if (Program.CLQ_Program_Wide_Email_Addresses__c == ';') Program.CLQ_Program_Wide_Email_Addresses__c = null;
                                UpdateProgramMap.put(Program.Id, Program);
                                system.Debug('Removed Email from Program.CLQ_Program_Wide_Email_Addresses__c: ' + EmailAddress);
                            }
                        }
                        //removing field from SUTQ Field - START
                        if (string.isNotBlank(Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c))
                            {
                                Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c = Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                if (Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c == ';') Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c = null;
                                UpdateProgramMap.put(Program.Id, Program);
                                system.Debug('Removed Email from Program.CLQ_Program_Wide_Email_Addresses_SUTQ__c: ' + EmailAddress);
                            }
                        system.Debug('Program.CLQ_Org_Wide_Email_Addresses__c: ' + Program.CLQ_Org_Wide_Email_Addresses__c);
                        //removing field from SUTQ Field - ENDS
                        if (string.IsNotBlank(Program.CLQ_Org_Wide_Email_Addresses__c))
                        {
                            if (string.isNotBlank(Program.CLQ_Org_Wide_Email_Addresses__c))
                            {
                                Program.CLQ_Org_Wide_Email_Addresses__c = Program.CLQ_Org_Wide_Email_Addresses__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                if (Program.CLQ_Org_Wide_Email_Addresses__c == ';') Program.CLQ_Org_Wide_Email_Addresses__c = null;
                                UpdateProgramMap.put(Program.Id, Program);
                                system.Debug('Removed Email from Program.CLQ_Org_Wide_Email_Addresses__c: ' + EmailAddress);
                            }
                        }
                        //removing field from SUTQ ORG Wide EMail Field - START
                        if (string.isNotBlank(Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c))
                            {
                                Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c = Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                if (Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c == ';') Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c = null;
                                UpdateProgramMap.put(Program.Id, Program);
                                system.Debug('Removed Email from Program.CLQ_Org_Wide_Email_Addresses_SUTQ__c: ' + EmailAddress);
                            }
                        //removing field from SUTQ ORG Wide EMail Field - ENDS
                    }
                }
                //If this is a Organization level Role
                if (role.CLQ_Organization__c != null)
                {
                    Account Account = AccountMap.get(role.CLQ_Organization__c);
                    system.Debug('Account.CLQ_Org_Wide_Email_Addresses__c: ' + Account.CLQ_Org_Wide_Email_Addresses__c);
                    if (Account != null && string.IsNotBlank(Account.CLQ_Org_Wide_Email_Addresses__c))
                    {
                        if (string.IsNotBlank(Account.CLQ_Org_Wide_Email_Addresses__c))
                        {
                            Account.CLQ_Org_Wide_Email_Addresses__c = Account.CLQ_Org_Wide_Email_Addresses__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                            if (Account.CLQ_Org_Wide_Email_Addresses__c == ';') Account.CLQ_Org_Wide_Email_Addresses__c = null;
                            UpdateAccountMap.put(Account.Id, Account);
                        }
                        system.Debug('Removed Email from Account.CLQ_Org_Wide_Email_Addresses__c: ' + EmailAddress);
                        list<CLQ_Program__c> SubPrograms = AccountProgramMap.get(Account.Id);
                        if (SubPrograms != null && SubPrograms.size() > 0)
                        {
                            for(CLQ_Program__c SubProgram : SubPrograms)
                            {
                                if (string.IsNotBlank(SubProgram.CLQ_Org_Wide_Email_Addresses__c))
                                {
                                    SubProgram.CLQ_Org_Wide_Email_Addresses__c = SubProgram.CLQ_Org_Wide_Email_Addresses__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                    if (SubProgram.CLQ_Org_Wide_Email_Addresses__c == ';') SubProgram.CLQ_Org_Wide_Email_Addresses__c = null;
                                    UpdateProgramMap.put(SubProgram.Id, SubProgram);
                                }
                            }
                        }
                    }
                    //removing field from Account SUTQ FIELD -START
                    if (Account != null && (string.IsNotBlank(Account.Org_Wide_Email_Addresses_SUTQPS__c)|| string.IsNotBlank(Account.Org_Wide_Email_Addresses_SUTQSACC__c)))
                    {
                        if (string.IsNotBlank(Account.Org_Wide_Email_Addresses_SUTQPS__c))
                        {
                            Account.Org_Wide_Email_Addresses_SUTQPS__c = Account.Org_Wide_Email_Addresses_SUTQPS__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                            if (Account.Org_Wide_Email_Addresses_SUTQPS__c == ';') Account.Org_Wide_Email_Addresses_SUTQPS__c = null;
                            UpdateAccountMap.put(Account.Id, Account);
                        }
                        
                        if (string.IsNotBlank(Account.Org_Wide_Email_Addresses_SUTQSACC__c))
                        {
                            Account.Org_Wide_Email_Addresses_SUTQSACC__c = Account.Org_Wide_Email_Addresses_SUTQSACC__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                            if (Account.Org_Wide_Email_Addresses_SUTQSACC__c == ';') Account.Org_Wide_Email_Addresses_SUTQSACC__c = null;
                            UpdateAccountMap.put(Account.Id, Account);
                        }
                        system.Debug('Removed Email from Account.Org_Wide_Email_Addresses_SUTQSACC__c: ' + EmailAddress);
                        system.Debug('Removed Email from Account.Org_Wide_Email_Addresses_SUTQSPS__c: ' + EmailAddress);
                        list<CLQ_Program__c> SubPrograms = AccountProgramMap.get(Account.Id);
                        if (SubPrograms != null && SubPrograms.size() > 0)
                        {
                            for(CLQ_Program__c SubProgram : SubPrograms)
                            {
                                if (string.IsNotBlank(SubProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c))
                                {
                                    SubProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c = SubProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c.ToLowerCase().replace(EmailAddress, '').replace(';;', ';');
                                    if (SubProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c == ';') SubProgram.CLQ_Org_Wide_Email_Addresses_SUTQ__c = null;
                                    UpdateProgramMap.put(SubProgram.Id, SubProgram);
                                }
                            }
                        }
                    }
                    //removing field from Account SUTQ Field - END
                }

            }
        }

        boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
        CLQ_Trigger.BypassAllTriggers = true;

        if (UpdateProgramMap.size() > 0)
            update UpdateProgramMap.values();
        if (UpdateAccountMap.size() > 0)
            update UpdateAccountMap.values();

        CLQ_Trigger.BypassAllTriggers = PreviousValue;
    }*/
    
    //12150 starts
    //update PT transaction updated field
    public void updateProgramTransaction(List<CLQ_Role__c> newList, Map<Id, CLQ_Role__c> oldMap, String operationType) {
        Id userId = userinfo.getProfileId();
        system.debug('User Id ---- '+userId);
        
        if(Label.CommunityProfileIds.contains(userId)){
            //System.debug('community user found-->');
            
            Set<Id> programTransIdSet = new Set<Id>(); //collect all the PT Ids
            Set<CLQ_Program_Transaction__c> ptToUpdate = new Set<CLQ_Program_Transaction__c>(); //collect all pt to update
            
            if(operationType == updateString || operationType == insertString) { //check if owner was changed, old map only exists for update
                //System.debug('');
                for(CLQ_Role__c role : newList) { //we dont have old map for these types
                    if (role.CLQ_Program_Transaction_Source__c != null) { //this wont exist on role on program
                        System.debug('');
                        if(oldMap.size()>0 && role.OwnerId == oldMap.get(role.Id).OwnerId) { //for new there is no old map so check
                            programTransIdSet.add(role.CLQ_Program_Transaction_Source__c); //collect all the PT
                        }
                    }
                }
            }
            
            if(operationType == deleteString) { //check if owner was changed, old map only exists for update
                for(CLQ_Role__c role : oldMap.values()) { //we have old map for delete
                    if (role.CLQ_Program_Transaction_Source__c != null) { //this wont exist on role on program                      
                        programTransIdSet.add(role.CLQ_Program_Transaction_Source__c); //collect all the PT
                    }
                }
            }           
            
            if(programTransIdSet.size() > 0) {
                //master query to get all required details
                List<CLQ_Program_Transaction__c> relatedProgramTrans = [SELECT Id, Name, CLQ_Program__c, CLQ_Transaction_Updated__c, clq_recordtypename__c, (SELECT Id FROM Room_Space_Transactions__r LIMIT 1999) 
                                                                    FROM CLQ_Program_Transaction__c 
                                                                    WHERE Id IN:programTransIdSet
                                                                    AND (clq_recordtypename__c='Update FCC Resident Information'
                                                                    OR clq_recordtypename__c='Update On-site Contact Information'
                                                                    OR clq_recordtypename__c='Update Authorized Rep Info')];
                                                                    
                if (relatedProgramTrans != null) {
                    //get the count of role from program
                    
                    //System.debug('relatedProgramTrans-->' + relatedProgramTrans);
                    
                    Map<Id, Id> programTransToProgramMap = new Map<Id, Id>(); //map to hold pt->p relationships so we delete correct items
                    
                    try {
                        for(CLQ_Program_Transaction__c pt : relatedProgramTrans) { //if updated, change the flag
                            if(operationType == updateString){
                                //System.debug('operationType is update-->');
                                pt.CLQ_Transaction_Updated__c = true;
                                ptToUpdate.add(pt);
                            }
                            
                            programTransToProgramMap.put(pt.Id, pt.CLQ_Program__c);
                        }
                        
                                    
                    
                        if(operationType == insertString || operationType == deleteString) {
                            //System.debug('role operationType is-->' + operationType);
        
                            List<CLQ_Program__c> programsList = new List<CLQ_Program__c>(); //list of all programs
                    
                            if(programTransToProgramMap.size() > 0) {
                                programsList = [SELECT Id, (SELECT Id FROM Rooms_Spaces__r LIMIT 1999) FROM CLQ_Program__c WHERE Id IN: programTransToProgramMap.values()];
                            }
                            
                            
                            //go through the programs and pt and check if new role has been added or if role has been deleted in pt
                            for(CLQ_Program__c prog : programsList) {
                                for(CLQ_Program_Transaction__c pt : relatedProgramTrans) {
                                    if(programTransToProgramMap.size() > 0 && programTransToProgramMap.get(pt.Id) == prog.Id) {
                                        //System.debug('role pt.Room_Space_Transactions__r.size()-->' + pt.Room_Space_Transactions__r.size());
                                        //System.debug('role prog.Rooms_Spaces__r.size()-->' + prog.Rooms_Spaces__r.size());
                                        if(pt.Room_Space_Transactions__r.size() != prog.Rooms_Spaces__r.size()) { //if not equal then changes were made
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