/* Class Name : CLQ_ProgramTriggerHandler
* Description : This class contains all logic/methods used in CLQ_ProgramTrigger on CLQ_Program__c object
** Version          : 1.8
** Modification Log:
**------------------
**  Developer                   Date                    Version     Description
**------------------------------------------------------------------------------------------------------------
**  IncapsulateDevTeam          ----------              1.0         Created
**  Nishit Babaria              Jun 7, 2017             1.1         TFS#11250:update program irn and its relevant child site irn based on status values
**  Jiangl                      Aug 25, 2017            1.2         TFS#11732: Added Logic for County Admin Sharing.                 
**  Ramana Gurivelli            Aug 29, 2017            1.3         TFS#11680 : updated to allow users to edit "Inactive" programs
**  Neetu Ojha                  Dec 14, 2017            1.4         TFS#11925 : changed for OLD Map Parameter 
**  Soufin Rahimeen             05/31/2018              1.5         TFS#12198 : Removed validation functions that are not required, moved to CLQ_ProgramEditOvverride
**  Rohit Gowrishetty           06/18/2018              1.6         TFS#12096 : Updated the IRN functionality to not to update whent the PT is in final status
**  Rohit Gowrishetty           09/19/2018              1.7         CR#13881 : Added a method to update all the child related list to close when program is closed
**  Rahul Roy                   12/10/2018              1.8         CR#14811 : Updated code to update all not approved CAP's to Closed status for Program Closure
**  Rohit Gowrishetty           1/22/2019               1.9         TFS #14776 : Added condition to copy the owner Id only when specialists is changed. 
**  Pradeep Ravi                10/24/2019              2.0         TFS#16041 : Updated for Approver and Reviewer Editable fields
**  Sujith Balakrishnan         12/09/2019              2.1         TFS#16380: Updated for Approver and Reviewer Editable fields
**************************************************************************************************************/  

public with sharing class CLQ_ProgramTriggerHandler extends CLQ_Trigger {
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
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;    }
    
    public static String SC = '';
    public static final String Yes = 'Yes';
    public static final String ZERO='0';
    public static final String ONE='1';
    public static final String TWO='2';
    public static final String THREE='3';
    public static final String FOUR='4';
    public static final String FIVE='5';
    public static final String OPEN='Open';
    public static final Date empty;
    public static final String closed = 'Closed';
    public static final String Closed_NotAddressed = 'Closed - Not Addressed';
    public static final String Not_Verified = 'Not Verified';
    public static final String Pending = 'Pending';
    public static final String Newstring = 'New';
    public static final String Enforcement = 'Enforcement';
    public static final String Provisional = 'Provisional';
    public static final String Rating_Reduced = 'Rating Reduced';
    public static final String Required_Compliance = 'Required Compliance';
    public static final String Rating_Removed = 'Rating Removed';
    public static final String No = 'No';
    public static final String error1 = 'It is not possible to change the IRN of a program with a program status of ';
    public static final String error2 = 'There is already a Pre School program at this location with a status of ';
    public static final String error3 = 'There is already a School Age Child Care program at this location with a status of ';
    public static final String error4 = 'There is a program transaction with a status of ';
    public static final String errorMsg = '. Please select another location';
    public static final String Amendment_Capacity = 'Amendment - ODE and Center - Change of Capacity / Space';
    public static final String Amendment_ODE = 'Amendment - ODE and Center';
    public static final String Voluntarily_Discontinue = 'Voluntarily Discontinue Participation in SUTQ';
    public static final String ChangeOfOwner_Rating = 'Change of Owner Rating';
    public static final String Expedited_Rating = 'Expedited Rating';
    public static final String In_Home_Aide = 'In-Home Aide';
    public static final String Day_Camp = 'Day Camp';
    public static final String OutOfState_Registration = 'Out of State Registration';
    public static final String programError1 = 'Approvers can only update the Licensing Reviewer, SUTQ Reviewer and Comments Section';
    public static final String programError2 = 'Reviewers can only update the comments section';
    public static final String programError3 = 'Your account is not authorized to change the content in the Previous Comments field. Please undo your changes';
    public static final String ExceptionPart1  = 'There is not a CLQ_OCLQS_Configuration__c record with the name: ';
    public static final String ExceptionPart2 = '   Please notify your system administrator to update this table';
    public static Set<String> currProgStatus = new Set<String>{'Open','Pending'};
        public static String recordTypeName1 = 'CLQ_Pre_School'; 
    public static final String recordTypeName2 = 'CLQ_School_Age_Child_Care';
    public static final String recordTypeName3 = 'Onsite_Visit_Record_Type'; 
    
    public static List<CLQ_ProgramTriggerHandler__mdt> openProgAndTransStatuslist = [Select openProgAndTransStatus__c from CLQ_ProgramTriggerHandler__mdt where openProgAndTransStatus__c != null];
    public static List<CLQ_ProgramTriggerHandler__mdt> pendingProgAndTransStatuslist = [Select pendingProgAndTransStatus__c from CLQ_ProgramTriggerHandler__mdt where pendingProgAndTransStatus__c != null];
    public static List<CLQ_ProgramTriggerHandler__mdt> licInspectionsStatusOpenlist = [Select licInspectionsStatusOpen__c from CLQ_ProgramTriggerHandler__mdt where licInspectionsStatusOpen__c != null];
    public static List<CLQ_ProgramTriggerHandler__mdt> licInspectionsStatusPendinglist = [Select licInspectionsStatusPending__c from CLQ_ProgramTriggerHandler__mdt where licInspectionsStatusPending__c != null];
    public static List<CLQ_ProgramTriggerHandler__mdt> progStatusMdtList = [Select progStatusList__c from CLQ_ProgramTriggerHandler__mdt where progStatusList__c != null];
    public static List<CLQ_ProgramTriggerHandler__mdt> failProgTransStatuslist = [Select failProgTransStatus__c from CLQ_ProgramTriggerHandler__mdt where failProgTransStatus__c != null];
    
    
    //Calls the Base class Constructor
    public CLQ_ProgramTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <
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
    //@param : list<CLQ_Program__c> , map<id,CLQ_Program__c>
    //@return : none
    
    CLQ_ProgramTrigHdlrCountySharing ProgCountyAdminShare = new CLQ_ProgramTrigHdlrCountySharing();//JFS#11732 - County Admin Sharing 
    
    public override void beforeinsert() {
        populateConfigurationOnProgram((list < CLQ_Program__c > ) newList);
        UpdateOwnerToSpecialist((list < CLQ_Program__c > ) newList);
        
        //Duplicate
        map<boolean, list<CLQ_Program__C>> finalPrg = new map<boolean, list<CLQ_Program__C>>();
        set<String> setEmail = new set<String>();
        set<String> setName = new set<String>();
        //string SC = '';       
        
        map<string, CLQ_Program__C> mapPrgUni = new map<string, CLQ_Program__C>();
        map<string, CLQ_Program__C> mapPrgDup = new map<string, CLQ_Program__C>();
        
        for(CLQ_Program__c prog: (list < CLQ_Program__c > )newList){ 
            SC = prog.CLQ_Program_Email__c + prog.Name;
            setEmail.add(prog.CLQ_Program_Email__c); 
            setName.add(prog.Name);
            mapPrgUni.put(SC, prog);
        }
        if(setEmail != null && setName!= null){
            for( CLQ_Program__c dbProg : [SELECT id,CLQ_Program_Email__c,Name from CLQ_Program__C WHERE CLQ_Program_Email__c IN: setEmail AND Name IN: setName]){
                SC = dbProg.CLQ_Program_Email__c + dbProg.Name; mapPrgDup.put(SC, dbProg); mapPrgUni.remove(SC);
            }
        }
        finalPrg.put(true, mapPrgDup.values());
        finalPrg.put(false, mapPrgUni.values());        
        system.debug('Final program list -- ' + finalPrg);
    }
    
    public override void afterUpdate() {
        //Commented out UpdateInspection call as it seems to do nothing -- FOM October 10/23/2016
        // Uncommented UpdateInspection as it is triggering inspection trigger handler method to update rating effective date 
        /* UpdateInspections((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) newMap, (map < id,
CLQ_Program__c > ) oldMap);*/
        // new OCLQS_ProgTransChildrenSharingHandler().shareProgChildrenWithReviewer((List<CLQ_Program__c>) newList,
        //                                                                           (map<id,CLQ_Program__c>)oldMap);
        checkODEProgramTypeAtSameIRN((list<CLQ_Program__c>) newList, (map < id, CLQ_Program__c > ) oldMap);                                                                             
        /*updatEmailFieldToProgramTransaction((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) newMap, (map < id,
CLQ_Program__c > ) oldMap);*/
        ProgCountyAdminShare.CountyAdminShare((List<CLQ_Program__c>) newList, (map<Id,CLQ_Program__c>)oldMap); //JFS#11732,11925
        closeAllPTRelatedList((List<CLQ_Program__c>) newList, (map<Id,CLQ_Program__c>)oldMap); //13881
        UpdateSUTQExemption((List<CLQ_Program__c>) newList, (map<Id,CLQ_Program__c>)oldMap);
        
    }
    
    public override void BeforeUpdate() {
        //if(!programValidation((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap)) {
        //  System.debug('sr reached here');
        //  return; //sr
        //}
        //DoNotAllowUpdateOfClosedProgram((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap); //12198 removed
        //16380 changes starts
        //ValidateUserCounty((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap);
        //16380 changes ends
        UpdateProgramRating((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap);
        UpdateOwnerToSpecialist((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap); //14776
        AppendReviewerComments((list < CLQ_Program__c > ) newList, (map < id, CLQ_Program__c > ) oldMap);
        
    }
    
    public void UpdateSUTQExemption(list < CLQ_Program__c >  newList, map < id, CLQ_Program__c >  oldMap)
    {
        Date todayDate = date.today();
        List<CLQ_SUTQ_Exemption__c> newSUTQExcemptionList = new List<CLQ_SUTQ_Exemption__c>();
        List<CLQ_SUTQ_Exemption__c> updateSUTQExcemptionList = new List<CLQ_SUTQ_Exemption__c>();
        List<CLQ_Program__c> updateProgramList = new List<CLQ_Program__c>();
        for(CLQ_Program__c prog: newList) 
        {
            system.debug('Prg Id V---- '+prog.Id);
            
            if(prog.CLQ_Current_Rating__c != null && prog.CLQ_Current_Rating__c != 0 && prog.CLQ_SUTQ_Exempted__c != null && prog.CLQ_SUTQ_Exempted__c == Yes) {
                
                for (CLQ_SUTQ_Exemption__c objSUTQException: prog.SUTQ_Exemptions__r) {
                    if(objSUTQException.CLQ_Exempted__c != null && objSUTQException.CLQ_Exempted__c == Yes) {
                        system.debug('SUTQ_Exemptions' + objSUTQException.Effective_Date__c);
                        //objSUTQException.SUTQ_Exemption__c = 'No';
                        objSUTQException.End_Date__c = todayDate;
                        //prog.CLQ_SUTQ_Exempted__c = 'No';
                        //prog.CLQ_SUTQ_Exempted_End_Date__c = todayDate;
                        prog.Unable_to_Rate_Reasons__c = '';
                        prog.Rating_Reduction_Date__c = empty;
                        prog.Rating_Discontinue__c = empty;
                        updateProgramList.add(prog);
                        updateSUTQExcemptionList.add(objSUTQException);
                    }
                }
            }
            
            if(((prog.CLQ_SUTQ_Exempted__c == null || prog.CLQ_SUTQ_Exempted__c ==No) && prog.CLQ_Current_Rating__c == null ||  prog.CLQ_Current_Rating__c == 0) 
               && (prog.CLQ_Program_Status__c == Pending || prog.CLQ_Program_Status__c == Newstring || prog.CLQ_Program_Status__c == Enforcement || prog.CLQ_License_Type__c == Provisional 
                   || (prog.Rating_Reduction_Date__c != null && prog.Rating_Reduction_Date__c.addDays(365) < todayDate && (prog.Unable_to_Rate_Reasons__c == Rating_Reduced || prog.Unable_to_Rate_Reasons__c == Required_Compliance))
                   || (prog.Rating_Discontinue__c != null && prog.Rating_Discontinue__c.addDays(365) < todayDate && prog.Unable_to_Rate_Reasons__c == Rating_Removed))
              ) {
                  
                  CLQ_SUTQ_Exemption__c newSUTQEx = new CLQ_SUTQ_Exemption__c();
                  newSUTQEx.Effective_Date__c = todayDate;
                  newSUTQEx.CLQ_Exempted__c = Yes;
                  newSUTQEx.clq_program__c = prog.Id;
                  newSUTQExcemptionList.add(newSUTQEx);
              }
        }
        CLQ_Trigger.BypassAllTriggers = true;
        if(!newSUTQExcemptionList.isEmpty()){
            insert newSUTQExcemptionList;
        } 
        
        if(!updateSUTQExcemptionList.isEmpty()){
            update updateSUTQExcemptionList;
        } 
        
        if(!updateProgramList.isEmpty()){
            update updateProgramList;
        }
        CLQ_Trigger.BypassAllTriggers = false;
    }
    //16380 changes starts
    /*commenting as this method is not used
public void ValidateUserCounty(list < CLQ_Program__c >  newList, map < id, CLQ_Program__c >  oldMap)
{
for(CLQ_Program__c prog: newList) 
{
User AssignedUser=null;
User SUTQUser=null;
String LicenseUserID;
String SUTQUserID='';

if(prog.CLQ_Program_Record_Type__c=='Day Camp')
{
if(!String.isNotEmpty(prog.CLQ_Assigned_Reviewer__c) )
{
return;
}
LicenseUserID=prog.CLQ_Assigned_Reviewer__c;

}
else
{
LicenseUserID=prog.CLQ_Licensing_Specialist__c;          
SUTQUserID=prog.SUTQ_Reviewer__c;
if(String.isNotEmpty(SUTQUserID))
{
SUTQUser= [Select Id, Profile.Name, UserRole.Name FROM User WHERE Id = :SUTQUserID]; 
}
}
Boolean LicensingProfile=false;
Boolean SUTQProfile=false;
if(LicenseUserID <>NULL)
{
AssignedUser= [Select Id, Profile.Name, UserRole.Name FROM User WHERE Id = :LicenseUserID]; 
}
if((String.isNotEmpty(LicenseUserID)) && (AssignedUser ==null || !String.isNotEmpty(AssignedUser.UserRole.Name)) )
{
prog.AddError('There is no role assigned to the licensing reviewer.');
return;
}
if((String.isNotEmpty(SUTQUserID)) && (SUTQUser ==null || !String.isNotEmpty(SUTQUser.UserRole.Name)) )
{
prog.AddError('There is no role assigned to the SUTQ reviewer.');
return;
}
If(LicenseUserID<>NULL && (AssignedUser.Profile.Name=='Super State Admin - State user' || AssignedUser.Profile.Name=='State Program Admin State User' || AssignedUser.Profile.Name=='State Admin - State user' || AssignedUser.Profile.Name=='ODJFS County Admin - County Role' || AssignedUser.UserRole.Name=='JFS State Admin') )
{
LicensingProfile=true; 
}
If(SUTQUserID <>NULL && (SUTQUser.Profile.Name=='Super State Admin - State user' || SUTQUser.Profile.Name=='State Program Admin State User' || SUTQUser.Profile.Name=='State Admin - State user' || SUTQUser.Profile.Name=='ODJFS County Admin - County Role' || SUTQUser.UserRole.Name=='JFS State Admin') )
{
SUTQProfile=true; 
}
if((prog.CLQ_Program_Record_Type__c=='Day Camp' &&  LicensingProfile==true) || (LicensingProfile==true && SUTQProfile==true ) )
{
return;
}

if(LicensingProfile==false && String.isNotEmpty(LicenseUserID) && String.isNotEmpty(AssignedUser.UserRole.Name) && prog.CLQ_Jurisdiction__c=='JFS' && !AssignedUser.UserRole.Name.ContainsIgnoreCase(prog.Program_County__c)) 
{
prog.AddError('You cannot assign the program to users from outside the county.');
return;
}
if(SUTQProfile==false && String.isNotEmpty(SUTQUserID) && String.isNotEmpty(SUTQUser.UserRole.Name) && prog.CLQ_Jurisdiction__c=='JFS' && !SUTQUser.UserRole.Name.ContainsIgnoreCase(prog.Program_County__c)) 
{
prog.AddError('You cannot assign the SUTQ reviewer from outside the county.');
return;
}
}  
}*/
    //16380 changes ends
    //13881
    public void closeAllPTRelatedList(list <CLQ_Program__c > newList, map <Id, CLQ_Program__c> oldMap) {
        Id licClosure = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Licensing_Closure').getRecordTypeId();
        Id regClosure = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('CLQ_Registration_Closure').getRecordTypeId(); 
        //13881- Starts - Sets and lists to capture the final status and also to update the list
        set <String> PTStatusExempts = new set <String> ();
        set <String> InspStatusExempts = new set <String> ();
        set <String> DocStatusExempts = new set <String> ();
        set <String> CAPStatusExempts = new set <String> ();
        list<Sobject> pTToUpdate = new list<CLQ_Program_Transaction__c>();
        list<Sobject> inspToUpdate = new list<CLQ_Inspection__c>();
        list<Sobject> docsToUpdate = new list<CLQ_Transaction_Document__c>();
        list<Sobject> CAPSToUpdate = new list<CLQ_Corrective_Action_Plan__c >();
        list<Sobject> recsToUpdate = new list<Sobject> () ;
        set <id> permanentClosureIds = new set<id>(); 
        
        PTStatusExempts.addAll(label.List_of_PT_Status_to_exempt_from_updating.split(';'));
        InspStatusExempts.addAll(label.List_of_Inspections_to_exempt.split(';'));
        DocStatusExempts.addAll(label.List_of_Document_Status_to_exempt.split(';'));
        CAPStatusExempts.addAll(label.List_of_CAP_Exempts.split(';'));
        
        for(CLQ_Program__c prg: newList){
            system.debug('Prg Id V---- '+prg.Id);
            system.debug('Prg Name ---- '+prg.Name);
            system.debug('Prg status ---- '+prg.CLQ_Program_Status__c);
            system.debug('Prg City ---- '+prg.City__c);
            //system.debug('Old Prg Id ---- '+oldMap.get(prg.Id));
            //system.debug('Old Prg status ---- '+oldMap.get(prg.Id).CLQ_Program_Status__c);
            //system.debug('Old Prg City ---- '+oldMap.get(prg.Id).City__c);
            
            if(oldMap.size()!=0 && prg.CLQ_Program_Status__c == closed && oldMap.get(prg.Id).CLQ_Program_Status__c != closed){permanentClosureIds.add(prg.id);  
                                                                                                                             }
        }
        
        if(permanentClosureIds.size() > 0 ){
            
            try{
                
                //13881 - Added the CAPS related lists which are associated to the permanent & Temperory program closure Caps
                map<id,CLQ_Program__c> relatedPrograms = new Map<Id,CLQ_Program__c>([select id,CLQ_Closure_Date__c, CLQ_Program_Status__c,
                                                                                     CLQ_License_Registration_Status__c,CLQ_License_Type__c ,
                                                                                     CLQ_Temporary_Closure_Date__c,
                                                                                     (select id, CLQ_CAP_Status__c,CLQ_Inspection__c from Corrective_Action_Plans__r where CLQ_CAP_Status__c not in :CAPStatusExempts )
                                                                                     from clq_program__c where id in :permanentClosureIds]);
                
                
                //13881 - Getting all the PTs from permanent closure programs and there related lists. So all the related lists which are not in final status wil be closed below. 
                Map <Id,CLQ_Program_Transaction__c> PTSfromClosurePrograms = new Map< Id, CLQ_Program_Transaction__c> ([select id,CLQ_Transaction_Status__c,
                                                                                                                        ( select id,CLQ_Document_Status__c  from Transaction_Documents__r  where CLQ_Document_Status__c not in :DocStatusExempts ),
                                                                                                                        ( select id,CLQ_Inspection_Status__c from Inspections__r where CLQ_Inspection_Status__c not in :InspStatusExempts )
                                                                                                                        from CLQ_Program_Transaction__c
                                                                                                                        where CLQ_Program_Transaction__c.CLQ_Program__r.id in :permanentClosureIds
                                                                                                                        and CLQ_Transaction_Status__c not in :PTStatusExempts]);
                
                // 13881 - Loop through all the PTs, and update the status of all the related lists - PTs, Docs and Inspections are covered here
                if(PTSfromClosurePrograms.size()!=0){
                    for(Id key : PTSfromClosurePrograms.keySet() ){
                        
                        CLQ_Program_Transaction__c pt = PTSfromClosurePrograms.get(key);
                        
                        pt.CLQ_Transaction_Status__c = closed ;
                        pt.Skip_Validation__c= true ;
                        if(!pTToUpdate.contains(pt)){
                            pTToUpdate.add(pt); 
                        }     
                        
                        List<CLQ_Transaction_Document__c>  ptDocs =   PTSfromClosurePrograms.get(key).Transaction_Documents__r ; 
                        List<CLQ_Inspection__c>  inspList =   PTSfromClosurePrograms.get(key).Inspections__r ;                       
                        
                        for(CLQ_Transaction_Document__c eachDoc: ptDocs){
                            
                            eachDoc.CLQ_Document_Status__c = Not_Verified;
                            docsToUpdate.add(eachDoc);
                            
                        }
                        for(CLQ_Inspection__c insp: inspList){
                            insp.CLQ_Inspection_Status__c = closed;   
                            inspToUpdate.add(insp); 
                        }
                    }
                }
                
                //System.debug('eachDoc' + docsToUpdate.size());
                //System.debug('insp' + inspToUpdate.size());
                
                Map<Id,Sobject> finalInspMap = new Map<Id,Sobject>();
                for(Sobject insp: inspToUpdate){  finalInspMap.put(insp.id, insp);}
                
                // Loop all through the Programs which are changed to closed.
                
                for(Id key : relatedPrograms.keySet()){
                    CLQ_Program__c prog;
                    if(relatedPrograms.size()!=0){
                        prog = relatedPrograms.get(key);
                    }
                    
                    // 13881 - All the perm closure programs which are associated to the prog are changed to closed if they are not in approved.
                    List<CLQ_Corrective_Action_Plan__c> Caps = prog.Corrective_Action_Plans__r;
                    //System.debug('Caps are' + Caps);
                    for(CLQ_Corrective_Action_Plan__c eachCAP :Caps ){
                        //System.debug('Coming into caps loop ');
                        //if(finalInspMap.containsKey(eachCAP.CLQ_Inspection__c)){ //14811
                        //System.debug('Changing caps');
                        eachCAP.CLQ_CAP_Status__c = Closed_NotAddressed;
                        CAPSToUpdate.add(eachCAP);                           
                        //}
                    }                
                }
                //update the program and pt records
                
                //13881 - starts
                CLQ_Trigger.BypassAllTriggers = true;
                recsToUpdate.addAll(inspToUpdate);
                recsToUpdate.addAll(docsToUpdate);
                recsToUpdate.addAll(CAPSToUpdate);
                recsToUpdate.addAll(pTToUpdate);            
                if(!recsToUpdate.isEmpty()){ update recsToUpdate;}
                CLQ_Trigger.BypassAllTriggers = false;
                //13881- ends
            }catch(Exception e){ Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_License_Closure_Schedule_Tasks'); }
        }
    }
    
    //sr validation for odjfs flag
    /*Comenting as this method is not used
public boolean programValidation(list <CLQ_Program__c > newList, map <Id, CLQ_Program__c> oldMap) {

boolean Validated = true;

User userRec = [SELECT Id, name, userRoleId, userRole.name FROM User WHERE Id = : UserInfo.getUserId()];

Group adminQueue = [SELECT id, name, developername FROM Group WHERE type = 'queue' AND Group.Name = 'DC - Admin'];

for(CLQ_Program__c prog: newList) {
if(prog.Approved_to_do_a_Provider_Agreement__c != oldMap.get(prog.Id).Approved_to_do_a_Provider_Agreement__c) {
//get profile name
Id profileId = UserInfo.getProfileId();
String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
system.debug('ProfileName--->'+profileName);

//GroupMember queueUser = [SELECT Id FROM GroupMember WHERE UserOrGroupId=userId AND Group.Type = 'Queue' AND Group.Name = 'DC - Admin'];

if(profileName != 'State Admin - State user') {
Validated = false;
}
}
}

system.debug('Validated--->'+Validated);


return Validated;
}*/
    
    //TFS CR 11250 - Nishit Babaria - update program irn and its relevant child site irn based on status values
    public void checkODEProgramTypeAtSameIRN(list<CLQ_Program__c> newList, map<id, CLQ_Program__c> oldMap) {
        Set<String> openProgAndTransStatus = new Set<String>();   
        for(CLQ_ProgramTriggerHandler__mdt mdt : openProgAndTransStatuslist){
            openProgAndTransStatus.add(mdt.openProgAndTransStatus__c);
        }
        
        Set<String> pendingProgAndTransStatus = new Set<String>();
        for(CLQ_ProgramTriggerHandler__mdt mdt : pendingProgAndTransStatuslist){
            pendingProgAndTransStatus.add(mdt.pendingProgAndTransStatus__c);
        }
        Set<String> allProgTransStatus = new Set<String>();
        allProgTransStatus.addAll(openProgAndTransStatus);
        allProgTransStatus.addAll(pendingProgAndTransStatus);
        Set<String> licInspectionsStatusOpen = new Set<String>();
        for(CLQ_ProgramTriggerHandler__mdt mdt : licInspectionsStatusOpenlist){
            licInspectionsStatusOpen.add(mdt.licInspectionsStatusOpen__c);
        }        
        Set<String> licInspectionsStatusPending = new Set<String>();
        for(CLQ_ProgramTriggerHandler__mdt mdt : licInspectionsStatusPendinglist){
            licInspectionsStatusPending.add(mdt.licInspectionsStatusPending__c);
        } 
        Set<String> allInspectionStatus = new Set<String>();
        allInspectionStatus.addAll(licInspectionsStatusOpen);
        allInspectionStatus.addAll(licInspectionsStatusPending);
        List<CLQ_Program__c> updatedBirnProgs = new List<CLQ_Program__c>();
        Map<String,CLQ_Program__c> birnMap = new Map<String,CLQ_Program__c>();
        Set<String> birns = new Set<String>();
        for(CLQ_Program__c prog: newList) {
            if(oldMap.size()!=0 && prog.CLQ_BIRN__c != oldMap.get(prog.Id).CLQ_BIRN__c) {
                //System.debug('');
                if(prog.CLQ_Program_Status__c != null && prog.CLQ_Program_Status__c != SC && !currProgStatus.contains(prog.CLQ_Program_Status__c)) {
                    prog.AddError(error1 +prog.CLQ_Program_Status__c);
                    return;
                }
                updatedBirnProgs.add(prog);
                birnMap.put(prog.Id, prog);
                birns.add(prog.CLQ_BIRN__c);
            }
        }
        Map<Id,CLQ_Program__c> finalPrograms = new Map<Id,CLQ_Program__c>([Select Id, (Select Id,CLQ_Transaction_Status__c,
                                                                                       CLQ_Site_IRN__c,CLQ_New_BIRN_Site_IRN__c,clq_recordtypename__c   //12096  
                                                                                       FROM Program_Transactions__r 
                                                                                       where CLQ_Transaction_Status__c in : allProgTransStatus)
                                                                           , (Select Id,CLQ_Site_IRN__c,RecordTypeId, CLQ_Inspection_Status__c FROM Inspections__r 
                                                                              where CLQ_Inspection_Status__c in : allInspectionStatus) 
                                                                           FROM CLQ_Program__c where Id in : birnMap.keySet() 
                                                                           and CLQ_Program_Status__c in ('Open','Pending')]);
        //TODO: check for the particular public group making the updates//
        Id preSchoolId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(recordTypeName1).getRecordTypeId();
        Id saccId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get(recordTypeName2).getRecordTypeId();
        Id onsiteVisitId = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get(recordTypeName3).getRecordTypeId();
        
        List<CLQ_Program__c> progs = [Select Id, CLQ_Program_Status__c, RecordTypeId, CLQ_BIRN__c 
                                      FROM CLQ_Program__c 
                                      where CLQ_BIRN__c in : birns 
                                      and Id not in : birnMap.keySet()];
        Map<String, List<CLQ_Program__c>> duplicateBirnMap = new Map<String, List<CLQ_Program__c>>();
        List<CLQ_Program_Transaction__c> finalTransToBeUpdated = new List<CLQ_Program_Transaction__c>();
        List<CLQ_Inspection__c> finalInspToBeUpdated = new List<CLQ_Inspection__c>();
        for(CLQ_Program__c p : progs) {
            if(!duplicateBirnMap.containsKey(p.CLQ_BIRN__c)) {
                List<CLQ_Program__c> bProgs = new List<CLQ_Program__c>();
                bProgs.add(p);
                duplicateBirnMap.put(p.CLQ_BIRN__c, bProgs);
            }
            else {
                duplicateBirnMap.get(p.CLQ_BIRN__c).add(p);
            }
            
        }
        Boolean errorCheck = false;
        Set<String> progStatusList = new Set<String>();
        for(CLQ_ProgramTriggerHandler__mdt mdt : progStatusMdtList){
            progStatusList.add(mdt.progStatusList__c);
        }
        Set<Id> pendingPrograms = new Set<Id>();
        for(CLQ_Program__c p : updatedBirnProgs) {
            if(duplicateBirnMap.containsKey(p.CLQ_BIRN__c)) {
                System.debug('');
                for(CLQ_Program__c dupProg : duplicateBirnMap.get(p.CLQ_BIRN__c)) {
                    if(dupProg != null) {
                        //System.debug('');
                        if(p.RecordTypeId == dupProg.RecordTypeId && p.RecordTypeId == preSchoolId && progStatusList.contains(dupProg.CLQ_Program_Status__c)) {
                            p.AddError(error2 +dupProg.CLQ_Program_Status__c+ errorMsg);
                            errorCheck = true;
                            break;
                        }
                        if(p.RecordTypeId == dupProg.RecordTypeId && p.RecordTypeId == saccId && progStatusList.contains(dupProg.CLQ_Program_Status__c)) {
                            p.AddError(error3 +dupProg.CLQ_Program_Status__c+ errorMsg);
                            errorCheck = true;
                            break;
                        }
                        if(p.RecordTypeId == dupProg.RecordTypeId && dupProg.CLQ_Program_Status__c == Pending) {
                            pendingPrograms.add(dupProg.Id);
                        }
                    }
                }
            }
        }
        if(pendingPrograms.size() > 0) {
            //System.debug('');
            Set<String> failProgTransStatus = new Set<String>();
            for(CLQ_ProgramTriggerHandler__mdt mdt : failProgTransStatuslist){
                failProgTransStatus.add(mdt.failProgTransStatus__c);
            } 
            Map<Id, CLQ_Program__c> programs = new Map<Id, CLQ_Program__c>([Select Id, (Select Id,CLQ_Transaction_Status__c FROM Program_Transactions__r LIMIT 1999)
                                                                            FROM CLQ_Program__c 
                                                                            where Id in : pendingPrograms]);
            if(programs.size()!=0){
                for(Id pId : programs.keySet()) {
                    for(CLQ_Program_Transaction__c pt : programs.get(pId).Program_Transactions__r) {
                        if(pt != null) {
                            System.debug('');
                            if(failProgTransStatus.contains(pt.CLQ_Transaction_Status__c)) {
                                programs.get(pId).AddError(error4 +pt.CLQ_Transaction_Status__c);
                                errorCheck = true;
                            }
                        }
                    }
                }
            }
        }
        if(errorCheck == false) {
            for(CLQ_Program__c p : updatedBirnProgs) {
                if(p.CLQ_Program_Status__c == Open && finalPrograms.size()!=0) {
                    for(CLQ_Program_Transaction__c pt : finalPrograms.get(p.Id).Program_Transactions__r) {
                        //12096 -starts
                        String PT_RecordType='';                                                                    
                        if(pt.clq_recordtypename__c == Amendment_Capacity ){
                            PT_RecordType = Amendment_ODE ;
                        } 
                        else{
                            PT_RecordType = pt.clq_recordtypename__c    ; 
                        }
                            
                        Program_Transaction_Mapping__c PTMapping = Program_Transaction_Mapping__c.getValues(PT_RecordType);
                        List<String> finalStatusSet = PTMapping.Final_Status__c.split(','); 
                        //12096 -Ends
                        
                        if(openProgAndTransStatus.contains(pt.CLQ_Transaction_Status__c) && !finalStatusSet.contains(pt.CLQ_Transaction_Status__c)) {//12096
                            //CLQ_New_BIRN_Site_IRN__c, CLQ_Organization_IRN__c, CLQ_Site_IRN__c 
                            pt.CLQ_Site_IRN__c = p.CLQ_BIRN__c;
                            pt.CLQ_New_BIRN_Site_IRN__c = p.CLQ_BIRN__c;
                            finalTransToBeUpdated.add(pt);
                        }
                    }
                    //***TFS 11562: Prakriti Biswas - commented out as we dont need to update Site IRN on Inspection every time Site IRN on Program is updated ***                  
                    /*for(CLQ_Inspection__c ins : finalPrograms.get(p.Id).Inspections__r) {
if(licInspectionsStatusOpen.contains(ins.CLQ_Inspection_Status__c)) {//CLQ_New_BIRN_Site_IRN__c, CLQ_Organization_IRN__c, CLQ_Site_IRN__c
if(ins.RecordTypeId != onsiteVisitId && ins.CLQ_Inspection_Status__c == 'Pending Approval') {}
else {
ins.CLQ_Site_IRN__c = p.CLQ_BIRN__c;
finalInspToBeUpdated.add(ins);
}
}
}*/
                }
                else if(p.CLQ_Program_Status__c == Pending && finalPrograms.size()!=0) {
                    for(CLQ_Program_Transaction__c pt : finalPrograms.get(p.Id).Program_Transactions__r) {
                        //12096 -starts
                        String PT_RecordType=SC;                                                                 
                        if(pt.clq_recordtypename__c == Amendment_Capacity ){
                            PT_RecordType = Amendment_ODE;
                        }  
                        else{
                            PT_RecordType = pt.clq_recordtypename__c    ;
                        }
                             
                        Program_Transaction_Mapping__c PTMapping = Program_Transaction_Mapping__c.getValues(PT_RecordType); 
                        List<String> finalStatusSet = PTMapping.Final_Status__c.split(',');
                        //12096 -Ends
                        
                        if(pendingProgAndTransStatus.contains(pt.CLQ_Transaction_Status__c) && !finalStatusSet.contains(pt.CLQ_Transaction_Status__c)) { //12096
                            pt.CLQ_Site_IRN__c = p.CLQ_BIRN__c;
                            pt.CLQ_New_BIRN_Site_IRN__c = p.CLQ_BIRN__c;
                            finalTransToBeUpdated.add(pt);
                        }
                    }
                    
                    //***TFS 11562: Prakriti Biswas - commented out as we dont need to update Site IRN on Inspection every time Site IRN on Program is updated ***
                    /*for(CLQ_Inspection__c ins : finalPrograms.get(p.Id).Inspections__r) {
if(licInspectionsStatusPending.contains(ins.CLQ_Inspection_Status__c)) {//CLQ_New_BIRN_Site_IRN__c, CLQ_Organization_IRN__c, CLQ_Site_IRN__c
ins.CLQ_Site_IRN__c = p.CLQ_BIRN__c;
finalInspToBeUpdated.add(ins);
}
}*/
                }
            }
        }
        if(!finalTransToBeUpdated.isEmpty()) { CLQ_Program_TransactionTriggerHandler.BypassTrigger = true; update finalTransToBeUpdated; CLQ_Program_TransactionTriggerHandler.BypassTrigger = false;
                                             }
        if(!finalInspToBeUpdated.isEmpty()) {  CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true; update finalInspToBeUpdated; CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
                                            }
    }
    
    //Method to populate configuration record on Program while inserting
    //@param: list<CLQ_Program__c> new program record list
    //@return: list<CLQ_Program__c> updated program record list
    public void populateConfigurationOnProgram(list < CLQ_Program__c > triggernew) {
        list < string > recordTypeNameList = new list < string > (); //list of record type name for all program record
        map < string, CLQ_OCLQS_Configuration__c > configurationnameRecordMap = new map < string,
            CLQ_OCLQS_Configuration__c > (); //map of all applicable configuration records with name as key  
        Map < ID, Schema.RecordTypeInfo > rt_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById(); //map to hold all the record type info for Program object
        
        //Store record type name value in recordTypeNameList
        for (CLQ_Program__c programRecord: triggernew) {
            if (rt_map.containsKey(programRecord.recordTypeID)){
                recordTypeNameList.add(rt_map.get(programRecord.recordTypeID).getName());
            }
                
            else{
                throw new CLQ_ProgramTriggerHandlerException(ExceptionPart1 + programRecord.recordTypeID +
                                                             ExceptionPart2);
            }
                
        }
        System.Debug('recordTypeNameList-->' +recordTypeNameList);
        if (recordTypeNameList.size() > 0) {
            //query the configuration records
            //System.debug('Coming into loop');
            for (CLQ_OCLQS_Configuration__c configrecord: [SELECT id, Name
                                                           FROM CLQ_OCLQS_Configuration__c
                                                           WHERE name IN: recordTypeNameList
                                                          ]) {
                                                              //System.debug('Record is ' + configrecord);
                                                              configurationnameRecordMap.put(configrecord.Name, configrecord); //populate the map                                                  
                                                          }
            
            for (CLQ_Program__c programRecord: triggernew) {
                if(configurationnameRecordMap.size()!=0 && rt_map.size()!=0){
                    programRecord.CLQ_OCLQS_Configuration__c = (configurationnameRecordMap.get(rt_map.get(programRecord
                                                                                                          .recordTypeID).getName())).id; //populate the configuration record reference on program record
                }
            }
            
        }
    }
    //Not in use
    public void UpdateInspections(list < CLQ_Program__c > triggernew, map < id, CLQ_Program__c > newMap, map < id,
                                  CLQ_Program__c > oldMap) {
                                      set < Id > setProgramIds = new set < Id > ();
                                      list < CLQ_Inspection__c > lstInspection = new list < CLQ_Inspection__c > ();
                                      for (CLQ_Program__c obj: triggernew) {
                                          
                                          if ((AvoidRecursionCls.isRecomended == true || AvoidRecursionCls.isOnsiteVisit == true) &&
                                              ((newmap.size()!=0 && oldmap.size()!=0) && (newmap.get(obj.id).Program_Rating__c != null && newmap.get(obj.id).Program_Rating__c !=ZERO  &&
                                                                                          newmap.get(obj.id).Program_Rating__c != oldmap.get(obj.id).Program_Rating__c) ||
                                               newmap.get(obj.id).CLQ_License_Issue_Date__c != oldmap.get(obj.id).CLQ_License_Issue_Date__c)) {
                                                   setProgramIds.add(obj.id);
                                               }
                                      }
                                      
                                      for (CLQ_Program__c obj: [select id, Rating_Effective_Date__c, Program_Rating__c, Rating_Expiration_Date__c,
                                                                (select id, Name, isApproved__c from Inspections__r WHERE isApproved__c = true limit 1) from CLQ_Program__c WHERE ID IN:
                                                                setProgramIds
                                                               ]) {
                                                                   
                                                                   for (CLQ_Inspection__c objins: obj.Inspections__r) {
                                                                       CLQ_Inspection__c objinspection = new CLQ_Inspection__c(id = objins.id, isApproved__c = true);
                                                                       lstInspection.add(objinspection);
                                                                   }
                                                               }
                                      if (!lstInspection.isEmpty()) {
                                          AvoidRecursionCls.isRecomended = true;
                                          update lstInspection;
                                      } 
                                  }
    //Vamshi
    public void UpdateProgramRating(list < CLQ_Program__c > newList, map < id, CLQ_Program__c > oldMap) {
        //[select id,Program_Rating__c,Rating_Effective_Date__c,Rating_Expiration_Date__c from CLQ_Program__c WHERE ID IN:trigger.new]
        for (CLQ_Program__c obj: newList) {
            CLQ_Program__c oldObj;
            if(oldMap.size()!=0){
                oldObj = oldMap.get(obj.id);
            }
            if (obj.CLQ_Manual__c && obj.Program_Rating__c ==ZERO
                && (obj.Unable_to_Rate_Reasons__c == Rating_Removed||obj.Unable_to_Rate_Reasons__c == Voluntarily_Discontinue || obj.Unable_to_Rate_Reasons__c == SC)) {
                    obj.Rating_Expiration_Date__c = null;
                    obj.Rating_Effective_Date__c = null;
                    obj.Rating_Anniversary_Date__c = null;
                    obj.CLQ_Manual__c = false;
                    
                } 
            
            if (obj.CLQ_Manual__c && obj.Program_Rating__c != null && obj.Rating_Effective_Date__c != null && (obj.Unable_to_Rate_Reasons__c == ChangeOfOwner_Rating|| obj.Unable_to_Rate_Reasons__c == Expedited_Rating)) {
                obj.Rating_Expiration_Date__c =obj.Rating_Effective_Date__c.adddays(120) ;
                obj.Rating_Anniversary_Date__c = null;
                obj.CLQ_Manual__c = false;
                
            } 
            
            
            else if (obj.CLQ_Manual__c && obj.Program_Rating__c != null &&obj.Rating_Effective_Date__c != null && obj.Program_Rating__c != ZERO  && obj.Unable_to_Rate_Reasons__c ==Rating_Reduced)
            {
                obj.Rating_Expiration_Date__c = obj.Rating_Effective_Date__c.addYears(1).adddays(-1);
                obj.Rating_Anniversary_Date__c = null;
                obj.CLQ_Manual__c = false;
            }
            
            
            else if (obj.CLQ_Manual__c && obj.Rating_Effective_Date__c != null && obj.Program_Rating__c != null && (obj.Program_Rating__c ==
                                                                                                                    ONE || obj.Program_Rating__c == TWO)) {
                                                                                                                        obj.Rating_Expiration_Date__c = obj.Rating_Effective_Date__c.addYears(1).adddays(-1);
                                                                                                                        obj.Rating_Anniversary_Date__c = null;
                                                                                                                        obj.CLQ_Manual__c = false;
                                                                                                                        
                                                                                                                        
                                                                                                                    } else if (obj.CLQ_Manual__c && obj.Rating_Effective_Date__c != null && obj.Program_Rating__c != null && obj.Program_Rating__c ==
                                                                                                                               THREE && oldObj.Rating_Anniversary_Date__c == null) {
                                                                                                                                   obj.Rating_Expiration_Date__c = obj.Rating_Effective_Date__c.addYears(2).adddays(-1);
                                                                                                                                   obj.Rating_Anniversary_Date__c = obj.Rating_Effective_Date__c.addYears(1);
                                                                                                                                   obj.CLQ_Manual__c = false;
                                                                                                                                   
                                                                                                                                   
                                                                                                                               } else if (obj.CLQ_Manual__c && obj.Rating_Effective_Date__c != null && obj.Program_Rating__c != null  && (obj.Program_Rating__c ==
                                                                                                                                                                                                                                          FOUR || obj.Program_Rating__c == FIVE)) {
                                                                                                                                                                                                                                              system.debug('Entered in rating anniversary code');
                                                                                                                                                                                                                                              obj.Rating_Expiration_Date__c = obj.Rating_Effective_Date__c.addYears(3).adddays(-1);
                                                                                                                                                                                                                                              obj.Rating_Anniversary_Date__c = obj.Rating_Effective_Date__c.addYears(1);
                                                                                                                                                                                                                                              obj.CLQ_Manual__c = false;
                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                          }
            else if (obj.CLQ_Manual__c && obj.Program_Rating__c != null && obj.Program_Rating__c != ZERO){
                obj.Rating_Discontinue__c = null;
                obj.CLQ_Manual__c = false;}
            
            
            
            
            //&& oldObj.Rating_Anniversary_Date__c == null
            
            /* if ((obj.Program_Rating__c == '4' || obj.Program_Rating__c == '5') && oldObj.Rating_Anniversary_Date__c == null && oldObj.Rating_Anniversary_Date__c !=
obj.Rating_Anniversary_Date__c) {
system.debug('Entered in rating anniversary date old value code');
obj.Rating_Anniversary_Date__c = obj.Rating_Effective_Date__c.addYears(1);
system.debug('Prgm update::');
}

if (obj.Program_Rating__c == '4'  && oldObj.Rating_Anniversary_Date__c == null && oldObj.Rating_Anniversary_Date__c !=
obj.Rating_Anniversary_Date__c) {
system.debug('Entered in rating anniversary date old value code');
obj.Rating_Anniversary_Date__c = null;
system.debug('Prgm update::');
}*/
            
            
            
            
            
            
        }
    }
    /* public void updatEmailFieldToProgramTransaction(list < CLQ_Program__c > triggernew, map < id, CLQ_Program__c > newMap, map < id,
CLQ_Program__c > oldMap) {

for (CLQ_Program__c obj: triggernew) {
CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;

if (newmap.get(obj.id).CLQ_Program_Email__c != null &&
newmap.get(obj.id).CLQ_Program_Email__c != oldmap.get(obj.id).CLQ_Program_Email__c) {
List <CLQ_Program_Transaction__c> proTrList = [SELECT Id,CLQ_ProgTrans_Program_Email_Address__c from  CLQ_Program_Transaction__c WHERE CLQ_Program__c =:obj.id];
List <CLQ_Program_Transaction__c> newUpdateList = new List <CLQ_Program_Transaction__c>();                        
for(CLQ_Program_Transaction__c prt: proTrList)
{
prt.CLQ_ProgTrans_Program_Email_Address__c = obj.CLQ_Program_Email__c;
newUpdateList.add(prt);
}
update(newUpdateList);
}
}

}*/
    
    /* 12198 removed
public void DoNotAllowUpdateOfClosedProgram(list<CLQ_Program__c> newList, map<id, CLQ_Program__c> oldMap)
{
set<string> NotAllowed = new set<string>{'Closed by System', 'Closed'}; //Bug# 11680 - removed "Inactive" string value. 12198 removed closed
Profile Prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
string AllowedEdit = Global_Settings__c.getInstance().Can_Edit_Closed_Programs__c + 
Global_Settings__c.getInstance().Can_Edit_Closed_Programs2__c;
if (AllowedEdit.indexOf(Prof.Name) > -1) return;

for (CLQ_Program__c Program : newList) {
CLQ_Program__c oldProgram = oldMap.get(Program.Id);
if (oldProgram.CLQ_Program_Status__c != null && NotAllowed.contains(oldProgram.CLQ_Program_Status__c))
{
Program.AddError('You cannot edit a closed Program. Current Status is: ' + oldProgram.CLQ_Program_Status__c + 
'\n - Click Cancel to return to the previous page.');
}
}
}  
*/
    //14776 - Updated the input parameters and checking to update if the 
    public void UpdateOwnerToSpecialist(list<CLQ_Program__c> newList , map<id, CLQ_Program__c> oldMap )
    {
        //system.debug('before: '+(Trigger.isBefore && Trigger.isUpdate)+'newList: '+newList[0]+ 'bef: '+(Trigger.isBefore && Trigger.isInsert));
        Map < ID, Schema.RecordTypeInfo > rt_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById();
        for (CLQ_Program__c Program : newList) {
            String rtName;
            if(rt_Map.size()!=0) {rtName=rt_Map.get(Program.RecordTypeId).Name;}
            clq_program__c oldObj;
            if(oldMap.size()!=0) { oldObj = oldMap.get(Program.Id);}
            if((rtName== In_Home_Aide || rtName==Day_Camp || rtName== OutOfState_Registration) && Program.CLQ_Assigned_Reviewer__c!=null){
                //System.debug('');
                if (Program.CLQ_Assigned_Reviewer__c != Program.OwnerId){
                    Program.OwnerId = Program.CLQ_Assigned_Reviewer__c;
                }
                    
            }
            else if(Program.CLQ_Licensing_Specialist__c != null && Program.OwnerId == oldObj.OwnerId ) // 14776
            {   
               // System.debug('');
                if (Program.CLQ_Licensing_Specialist__c != Program.OwnerId){
                    Program.OwnerId = Program.CLQ_Licensing_Specialist__c;
                }
                    
                
            }else if(Program.OwnerId != oldObj.OwnerId){ // 14776 - There is no need to check null for owner ID as there cannot be empty owner for a record at anytime
                //System.debug('');
                if (Program.CLQ_Licensing_Specialist__c != Program.OwnerId){
                    Program.CLQ_Licensing_Specialist__c = Program.OwnerId ;
                } 
                    
            }
        }
    }
    
    //14776 - Added a new overloading method because the above method is called from before insert and we don't have the Program Id 
    
    public void UpdateOwnerToSpecialist(list<CLQ_Program__c> newList)
    {
        //system.debug('before: '+(Trigger.isBefore && Trigger.isUpdate)+'newList: '+newList[0]+ 'bef: '+(Trigger.isBefore && Trigger.isInsert));
        Map < ID, Schema.RecordTypeInfo > rt_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById();
        for (CLQ_Program__c Program : newList) {
            String rtName=rt_Map.get(Program.RecordTypeId).Name;
            
            if((rtName== In_Home_Aide || rtName== Day_Camp || rtName== OutOfState_Registration) && Program.CLQ_Assigned_Reviewer__c!=null){
                //System.debug('');
                if (Program.CLQ_Assigned_Reviewer__c != Program.OwnerId){
                    Program.OwnerId = Program.CLQ_Assigned_Reviewer__c;
                }
                    
            }
            else if(Program.CLQ_Licensing_Specialist__c != null )
            {
                if (Program.CLQ_Licensing_Specialist__c != Program.OwnerId){
                    Program.OwnerId = Program.CLQ_Licensing_Specialist__c;
                }
                    
                
            }
        }
    }    
    
    
    public void AppendReviewerComments(list<CLQ_Program__c> newList,map<id, CLQ_Program__c> oldMap){
        set <String> approverProfiles = new set <String> ();
        approverProfiles.addAll(label.ApproverAllowedProfilestoEditProgram.split(';'));
        set <String> reviewerProfiles = new set <String> ();
        reviewerProfiles.addAll(label.ReviewerAllowedProfilestoEditProgram.split(';'));
        //Get the current user name who is doing the action
        User usr=[Select id,Profile.name from User where id =:Userinfo.getUserid()];
        String usrpro=usr.Profile.Name;
        
        for(CLQ_Program__c program : newList){
            //16041 - Updated for Approver and Reviewer Editable fields - Start
            CLQ_Program__c oldItem;
            if(oldMap.size()!=0){
                oldItem = oldMap.get(program.Id);
            }
            //Checking if the user is Admin, then he has the right to approve any record. Also county Admins cannot approve the request
            System.Debug('approverProfiles.contains(usrpro)' +approverProfiles.contains(usrpro) +usrpro);
            Boolean approverEditable = false;
            if((program.CLQ_Licensing_Specialist__c != oldItem.CLQ_Licensing_Specialist__c || 
                program.SUTQ_Reviewer__c != oldItem.SUTQ_Reviewer__c ||
                program.Enter_new_comments__c != oldItem.Enter_new_comments__c)) {
                    approverEditable = true;
                }
            if(!approverEditable && approverProfiles.contains(usrpro)){
                //isAdmin = true;
                program.AddError(programError1);
            } 
            Boolean reviewerEditable = false;
            if((program.Enter_new_comments__c != oldItem.Enter_new_comments__c)) {
                reviewerEditable = true;
            }
            if(!reviewerEditable && reviewerProfiles.contains(usrpro)){
                //isAdmin = true;
                program.AddError(programError2);
            }
            //16041 - Updated for Approver and Reviewer Editable fields - End
            if(!String.isBlank(program.Enter_new_comments__c)){
                //System.debug('');                
                if(String.isBlank(program.Previous_Comments__c)){
                    //add to top of comments of line, i.e. no append
                    program.Previous_Comments__c = program.Enter_new_comments__c  +'<br><br>'+UserInfo.getName() +'<br>' + system.now().format() ; 
                }//end if
                else{
                    //previousCommentsSize = program.Previous_Comments__c.length();
                    program.Previous_Comments__c = program.Previous_Comments__c + '<br><br>' + program.Enter_new_comments__c  +'<br><br>'+UserInfo.getName() +'<br>' + system.now().format(); 
                }//end else
            }//end if
            if(!String.isBlank(program.Previous_Comments__c) && oldMap.size()!=0 && !String.isBlank(oldMap.get(program.Id).Previous_Comments__c)){
                //System.debug('');
                if(program.Previous_Comments__c.length() < oldMap.get(program.Id).Previous_Comments__c.length()){
                    program.AddError(programError3);
                }
                //program.Previous_Comments__c = oldMap.get(program.Id).Previous_Comments__c;
            }
            program.Enter_new_comments__c = '';
        }//end for
    }//end method
    
    public class CLQ_ProgramTriggerHandlerException extends Exception{}
}