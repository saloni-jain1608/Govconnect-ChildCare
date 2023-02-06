/**************************************************************************************************************
** Name             : CLQ_UserTriggerHandler
** Description      : This is an TriggerHandler Class for the User Object
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer                       Date                    Version     Description
**------------------------------------------------------------------------------------------------------------
**  Neetu Ojha                      Sep 25, 2017            1.2         TFS#11992,12051 : Add Community user to Community Queue                 
**************************************************************************************************************/ 

public with sharing class CLQ_UserTriggerHandler extends CLQ_Trigger
{
    public static final string CUSTOMER_COMMUNITY_PLUS = 'Customer Community Plus Login User';
    public static final string CUSTOMER_COMMUNITY_USER = 'Customer Community Login User';
    public static final string CENTER_INACTIVE_USER = 'Center_Inactive_User';
    public static final string FCC_INACTIVE_USER = 'FCC_Inactive_User';
    public static final string CLQ_Pre_School = 'CLQ_Pre_School';
    public static final string CLQ_School_Age_Child_Care = 'CLQ_School_Age_Child_Care';
    public static final string CLQ_Type_A_Home = 'CLQ_Type_A_Home';
    public static final string CLQ_FCC_Type_B_Home = 'CLQ_FCC_Type_B_Home';
    public static final string CLQ_In_Home_Aide = 'CLQ_In_Home_Aide';
    public static final string CLQ_Child_Care_Center = 'CLQ_Child_Care_Center';
    public static final string CLQ_Day_Camp = 'CLQ_Day_Camp';
    public static final string CLQ_Out_of_State_Registration = 'CLQ_Out_of_State_Registration';
    
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
    
    public CLQ_UserTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
                                  boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
                                  boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) 
    {
        super(newlistin, newMapin, oldlistin, oldMapin,
              isExecutingin, isInsertin, isUpdatein, isDeletein,
              isBeforein, isAfterin, isUndeletein, sizein);
        if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
    }
    
    //11992, 12051 Starts
    public override void AfterInsert(){
        addUserToQueue((list < User > ) newlist, null); 
        assignPermissionSet((list < User > ) newlist, null);
    }
    
    public override void AfterUpdate(){
        addUserToQueue((list < User > ) newlist, (map < id, User > ) oldMap); 
        assignPermissionSet((list < User > ) newlist, (map < id, User > ) oldMap);
        //TFS13779 - Starts
        recordReassignmentforInactiveUsers((list < User > ) newlist, (map < id, User > ) oldMap);
        //TFS13779 - Ends
    }       

    /*Method to add Community Plus User to Queue and calls future method to avoid Mixed-DML-Operation*/
    private static void addUserToQueue(List<User> lstUser, map<Id, User> oldMapUser){
        List<Id> lstUserId = new List<Id>();
        
        for(User usr : lstUser){
            if(usr.IsActive && usr.Profile_Name__c.contains(CUSTOMER_COMMUNITY_PLUS) 
               && (oldMapUser==null || ( !oldMapUser.get(usr.Id).isActive))){
                   lstUserId.add(usr.Id);
               }
        }
        system.debug('----'+lstUserId);
        if(!lstUserId.isEmpty()){
            addUserToQueueFuture(lstUserId);
        }
    }
    
    /*Future method to add Community Plus User to Community Queue*/
    @future
    static void addUserToQueueFuture(List<Id> lstUserID){
        
        List<GroupMember> lstGrpMem = new List<GroupMember>();
        
        for(Id usrId : lstUserID){
            lstGrpMem.add(new GroupMember(UserOrGroupId=usrId, GroupId = Label.CommunityQueueId));  
        }
        system.debug('lstGrpMem --- '+lstGrpMem);
        try{
            if (!lstGrpMem.isEmpty() && Schema.sObjectType.GroupMember.isCreateable()){
                insert lstGrpMem;
            }
        }catch(Exception e){
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_UserTriggerHandler');
        }
    }
    
    /*Method to assign community modify all Permission set to Community User and calls future method to avoid Mixed-DML-Operation*/
    private static void assignPermissionSet(List<User> lstUser, map<Id, User> oldMapUser){
        List<Id> lstUserId = new List<Id>();
        
        for(User usr : lstUser){
            if(usr.IsActive && usr.Profile_Name__c.contains(CUSTOMER_COMMUNITY_USER) 
               && (oldMapUser==null || ( !oldMapUser.get(usr.Id).isActive))){
                   lstUserId.add(usr.Id);
               }
        }
        system.debug('----'+lstUserId);
        if(!lstUserId.isEmpty()){
            assignPermissionSetFuture(lstUserId);
        }
    }
    
    //TFS13779 - Starts
    @TestVisible private static void recordReassignmentforInactiveUsers(List<User> lstUser, map<Id, User> oldMapUser){
        
        //Fetch inactive queues
        list<Group> groups = [select Id, Name,developername                               
                                  from Group 
                                  where Type = 'Queue' and ( developername = 'Center_Inactive_User' or developername = 'FCC_Inactive_User' or developername = 'ODE_Inactive_User')
                             ];
                                                              
        system.debug('Groups----->' + groups);   
                              
        map<string, ID> centerQueueMap = new map<string, ID>();
                Set<id> inActiveUserWithInActiveManagerIDS  = new Set<Id>();
                Set<id> inActiveUserIDS  = new Set<Id>();  
                map<id,id> inActiveUserAndManagerIDS = new map<id,id>();
                
                for( group g: groups){
                    if( g.developername == CENTER_INACTIVE_USER)
                    {
                        centerQueueMap.put('CENTER', g.id);
                    }
                    else if(g.developername == FCC_INACTIVE_USER)
                    {
                        centerQueueMap.put('FCC', g.id);
                    }
                    else
                    {
                        centerQueueMap.put('ODE', g.id);
                    }
                }                         
                                         
        
        for(User usr : lstUser){
            if(oldMapUser.size()!=0 && usr.Isactive == false && usr.Isactive != oldMapUser.get(usr.Id).isActive )
            {    
                system.debug('usr.ManagerId==>'+usr.ManagerId);
                system.debug('usr.manager.isactive==>'+usr.manager.isactive);
                if( (usr.ManagerId == null) || (usr.ManagerId <> null && usr.manager.isactive == false))
                {
                    inActiveUserWithInActiveManagerIDS.add(usr.id);
                    system.debug('User manager not active----->');          
                }
                else
                {                
                    inActiveUserIDS.add(usr.id);
                    inActiveUserAndManagerIDS.put(usr.id, usr.ManagerId);
                    system.debug('User manager active----->');
                } 
            }
        }
        
        if( inActiveUserIDS.size() > 0 || inActiveUserWithInActiveManagerIDS.size() > 0 ){
            
      
        
        
                //Program
                Set<id> clqPrgmIdLst  = new Set<Id>();  
                User clqUser;
                CLQ_Program__c clqPrgrm;
                list<CLQ_Program__c> prgToBeInserted = new list<CLQ_Program__c>();
                Schema.DescribeSObjectResult d = Schema.SObjectType.CLQ_Program__c;
                map< String, Schema.RecordTypeInfo > rtMapByName = d.getRecordTypeInfosByDeveloperName();
                
                list<CLQ_Program__c> listProgram = new list<CLQ_Program__c>([SELECT ID,OwnerId,CLQ_Licensing_Specialist__c,RecordTypeId
                                                                            FROM CLQ_Program__c
                                                                            WHERE OwnerId in :inActiveUserIDS or OwnerId in :inActiveUserWithInActiveManagerIDS
                                                                            ] );
                
                system.debug('listProgram.size----->' + listProgram.size());
                for( CLQ_Program__c clqProg: listProgram ){
                     if(inActiveUserAndManagerIDS.size()!=0 && inActiveUserAndManagerIDS.get(clqProg.OwnerId)!= null){
                        clqProg.OwnerId = inActiveUserAndManagerIDS.get(clqProg.OwnerId);
                        prgToBeInserted.add(clqProg);
                     }
                     else
                     {
                        //clqProg.OwnerId = queue
                        ID programRecTypeId = clqProg.RecordTypeId;
                        ID queueID;
                        //ODE
                        queueID = returnInactiveQueue(programRecTypeId,rtMapByName,centerQueueMap);
                        
                        system.debug('queueID-----> queueID');
                        if(queueID != NULL)
                        {
                            clqProg.ownerid = queueID;
                            clqProg.CLQ_Licensing_Specialist__c = NULL;
                            prgToBeInserted.add(clqProg);
                        }
                     }
                }
                
                 
                recordUpdateForInactiveUserFuture(inActiveUserIDS, inActiveUserWithInActiveManagerIDS,inActiveUserAndManagerIDS,centerQueueMap);
        
                //Program Transaction
                Set<id> clqPrgmTranIdLst  = new Set<Id>();                  
                CLQ_Program_Transaction__c clqPrgrmTran;
                list<CLQ_Program_Transaction__c> prgTranToBeInserted = new list<CLQ_Program_Transaction__c>();
                                
                list<CLQ_Program_Transaction__c> listProgramTran = new list<CLQ_Program_Transaction__c>([SELECT ID,OwnerId,CLQ_Program__r.RecordTypeId
                                                                                                        FROM CLQ_Program_Transaction__c
                                                                                                        WHERE OwnerId in :inActiveUserIDS or OwnerId in :inActiveUserWithInActiveManagerIDS
                                                                                                       ]);
                
                system.debug('listProgram.size----->' + listProgram.size());
                for( CLQ_Program_Transaction__c clqProgTran: listProgramTran ){
                     if(inActiveUserAndManagerIDS.size()!=0 && inActiveUserAndManagerIDS.get(clqProgTran.OwnerId)!= null){
                        clqProgTran.OwnerId = inActiveUserAndManagerIDS.get(clqProgTran.OwnerId);
                        prgTranToBeInserted.add(clqProgTran);
                     }
                     else
                     {
                        //clqProg.OwnerId = queue
                        ID programRecTypeId = clqProgTran.CLQ_Program__r.RecordTypeId;
                        ID queueID;
                        //ODE
                        queueID = returnInactiveQueue(programRecTypeId,rtMapByName,centerQueueMap);
                        system.debug('queueID-----> queueID');
                        if(queueID != NULL)
                        {
                            clqProgTran.ownerid = queueID;
                            clqProgTran.CLQ_Transaction_Assigned_To__c = NULL;
                            prgTranToBeInserted.add(clqProgTran);
                        }
                     }
                }
                
                system.debug('prgTranToBeInserted.size----->' + prgTranToBeInserted.size());
                
                //Inspection
                Set<id> clqInsIdLst  = new Set<Id>();               
                CLQ_Inspection__c clqIns;
                list<CLQ_Inspection__c> insToBeInserted = new list<CLQ_Inspection__c>();
                                
                list<CLQ_Inspection__c> listIns = new list<CLQ_Inspection__c>([SELECT ID,OwnerId, CLQ_Program__r.RecordTypeId
                                                                                                        FROM CLQ_Inspection__c
                                                                                                        WHERE OwnerId in :inActiveUserIDS or OwnerId in :inActiveUserWithInActiveManagerIDS
                                                                                                       ]);
                
                system.debug('listProgram.size----->' + listProgram.size());
                for( CLQ_Inspection__c clqInsTran: listIns ){
                     if(inActiveUserAndManagerIDS.size()!=0 && inActiveUserAndManagerIDS.get(clqInsTran.OwnerId)!= null){
                        clqInsTran.OwnerId = inActiveUserAndManagerIDS.get(clqInsTran.OwnerId);
                        insToBeInserted.add(clqInsTran);
                     }
                     else
                     {
                        //clqProg.OwnerId = queue
                        ID programRecTypeId = clqInsTran.CLQ_Program__r.RecordTypeId;
                        ID queueID;
                        //ODE
                        queueID = returnInactiveQueue(programRecTypeId,rtMapByName,centerQueueMap);
                        system.debug('queueID-----> queueID');
                        if(queueID != NULL)
                        {
                            clqInsTran.ownerid = queueID;
                            clqInsTran.CLQ_Inspection_Owner__c = NULL;
                            insToBeInserted.add(clqInsTran);
                        }
                     }
                }
                
                system.debug('insToBeInserted.size----->' + insToBeInserted.size());
                
                //CAP
                Set<id> clqCAPIdLst  = new Set<Id>();               
                CLQ_Corrective_Action_Plan__c clqCAP;
                list<CLQ_Corrective_Action_Plan__c> CAPToBeInserted = new list<CLQ_Corrective_Action_Plan__c>();
                                
                list<CLQ_Corrective_Action_Plan__c> listCAP = new list<CLQ_Corrective_Action_Plan__c>([SELECT ID,OwnerId, CLQ_Program__r.RecordTypeId
                                                                                                        FROM CLQ_Corrective_Action_Plan__c
                                                                                                        WHERE OwnerId in :inActiveUserIDS or OwnerId in :inActiveUserWithInActiveManagerIDS
                                                                                                       ]);
                
                system.debug('listProgram.size----->' + listProgram.size());
                for( CLQ_Corrective_Action_Plan__c clqCAPTran: listCAP ){
                     if(inActiveUserAndManagerIDS.size()!=0 && inActiveUserAndManagerIDS.get(clqCAPTran.OwnerId)!= null){
                        clqCAPTran.OwnerId = inActiveUserAndManagerIDS.get(clqCAPTran.OwnerId);
                        CAPToBeInserted.add(clqCAPTran);
                     }
                     else
                     {
                        //clqProg.OwnerId = queue
                        ID programRecTypeId = clqCAPTran.CLQ_Program__r.RecordTypeId;
                        ID queueID;
                        //ODE
                        queueID = returnInactiveQueue(programRecTypeId,rtMapByName,centerQueueMap);
                        system.debug('queueID-----> queueID');
                        if(queueID != NULL)
                        {
                            clqCAPTran.ownerid = queueID;                           
                            CAPToBeInserted.add(clqCAPTran);
                        }
                     }
                }
            system.debug('CAPToBeInserted.size----->' + CAPToBeInserted.size());
            
      }
    
    }
    
    
    
    static id returnInactiveQueue(id programRecTypeId,map< String, Schema.RecordTypeInfo > rtMapByName,map<string, ID> centerQueueMap){
        ID queueID;
        if(rtMapByName.size()!=0 && centerQueueMap.size()!=0){
                        if( programRecTypeId == rtMapByName.get(CLQ_Pre_School).getRecordTypeId()||programRecTypeId == rtMapByName.get(CLQ_School_Age_Child_Care).getRecordTypeId())
                        {
                            //ODE queue
                            queueID = centerQueueMap.get('ODE');
                            system.debug('Queue Type-----> ODE');
                        }
                        else if(programRecTypeId == rtMapByName.get(CLQ_Type_A_Home).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_FCC_Type_B_Home).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_In_Home_Aide).getRecordTypeId())
                        {
                            //FCC Queue
                            queueID = centerQueueMap.get('FCC');
                            system.debug('Queue Type-----> FCC');
                        }
                        else if(programRecTypeId == rtMapByName.get(CLQ_Child_Care_Center).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_Day_Camp).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_Out_of_State_Registration).getRecordTypeId())
                        {
                            //Center queue
                            queueID = centerQueueMap.get('CENTER');
                            system.debug('Queue Type-----> CENTER');                            
                        }
                        else
                        {
                            //No match
                            queueID = null;
                            system.debug('Queue Type-----> NO MATCH');
                        }
        }
        return queueID;

    }   
    
    
    
    @future
    static void recordUpdateForInactiveUserFuture(set<Id> inActiveUserIDS, set<Id> inActiveUserWithInActiveManagerIDS,map<id,id> inActiveUserAndManagerIDS,map<string, ID> centerQueueMap){
            list<CLQ_Program__c> prgToBeInserted = new list<CLQ_Program__c>();
            Schema.DescribeSObjectResult d = Schema.SObjectType.CLQ_Program__c;
            map< String, Schema.RecordTypeInfo > rtMapByName = d.getRecordTypeInfosByDeveloperName();
        	list<CLQ_Program__c> listProgram;
        	if(inActiveUserIDS != null || inActiveUserWithInActiveManagerIDS != null){
            	listProgram = new list<CLQ_Program__c>([SELECT ID,OwnerId,CLQ_Licensing_Specialist__c,RecordTypeId
                                                                            FROM CLQ_Program__c
                                                                            WHERE OwnerId in :inActiveUserIDS or OwnerId in :inActiveUserWithInActiveManagerIDS
                                                                            ] );
        	}
            
                
                system.debug('listProgram.size----->' + listProgram.size());
                for( CLQ_Program__c clqProg: listProgram ){
                     if(inActiveUserAndManagerIDS.size()!=0 && inActiveUserAndManagerIDS.get(clqProg.OwnerId)!= null){
                        clqProg.OwnerId = inActiveUserAndManagerIDS.get(clqProg.OwnerId);
                        prgToBeInserted.add(clqProg);
                     }
                     else
                     {
                        //clqProg.OwnerId = queue
                        ID programRecTypeId = clqProg.RecordTypeId;
                        ID queueID;
                        //ODE
                        queueID = returnInactiveQueue(programRecTypeId,rtMapByName,centerQueueMap);
                        
                        system.debug('queueID-----> queueID');
                        if(queueID != NULL)
                        {
                            clqProg.ownerid = queueID;
                            clqProg.CLQ_Licensing_Specialist__c = NULL;
                            prgToBeInserted.add(clqProg);
                        }
                     }
                }
                
                system.debug('F prgToBeInserted.size----->' + prgToBeInserted.size());
                boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
                CLQ_Trigger.BypassAllTriggers = true;
                if(!prgToBeInserted.isEmpty() && Schema.sObjectType.CLQ_Program__c.isUpdateable()){
                    update prgToBeInserted;
                }
                
                CLQ_Trigger.BypassAllTriggers = PreviousValue;
            

        try{
         
        }catch(Exception e){
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_UserTriggerHandler');
        }
    }   
    
    
    //TFS13779 - Ends
    /*Future method to assign community modify all Permission set to Community User*/
    @future
    static void assignPermissionSetFuture(List<Id> lstUserID){
        Id psID = [Select Id from PermissionSet Where Name  = 'Community_Modify_All_Data'].Id; 
        
        List<PermissionSetAssignment>  lstPSA = new List<PermissionSetAssignment>();
        
        for(Id usrId : lstUserID){
            lstPSA.add(new PermissionSetAssignment(AssigneeId=usrId, PermissionSetId = psID));  
        }
        system.debug('lstPSA --- '+lstPSA);
        try{
            if (!lstPSA.isEmpty() &&  Schema.sObjectType.PermissionSetAssignment.isCreateable()){
                insert lstPSA;
            }
        }catch(Exception e){
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_UserTriggerHandler');
        }
    }   
    //11992, 12051 Ends
}