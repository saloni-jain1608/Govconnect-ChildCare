/**************************************************************************************************************
** Name             : CLQ_InspectionTriggerHandler
** Description      : Invoked from Inspection trigger
** Version          : 3.6
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer                   Date                Version     Description
**------------------------------------------------------------------------------------------------------------
**  IncapsulateDevTeam          July-2016           1.0         Created
**  Ramana Gurivelli            5th May-2017        1.1         Added logic at line 942 to check if Inspection is complete for Bug 10843 and Bug 10960 
**  Vamsi Velampati             15 Jun 2017         1.2         Method updateCaseField added for CR #11235 and #11236
**  Ramana Gurivelli            26 July 2017        1.3         Updated Method updateCaseField for bug# 11598
**  Pradeep Ravi                8/1/2017            1.4         Updated code to check and execute the Program Eff Date Update only if the ins is Onsite record type - 10811
**  Pradeep Ravi                10/10/2017          1.5         Updated for CR 11415 - Complaints CR 
**  Neetu Ojha                  11/17/2017          1.6         TFS#11762 - Added validation
**  Neetu Ojha                  11/21/2017          1.7         TFS#11903 - Added Null check for county
**  Neetu Ojha                  11/24/2017          1.8         TFS#11867 - Updated to bypass 2 star rating validation
**  Neetu Ojha                  04/02/2018          1.9         TFS#12069 : Added Logic for combined counties
**  Neetu Ojha                  04/02/2018          2.0         TFS#12091 : Added new method to Copy Inspection Child Info
**  Pradeep Ravi                05/03/2018          2.1         TFS#12164 : Updated updateAllegedRulesonSubmitInspection to copy Details from Inspection to PT for Day camp
**  Neetu Ojha                  05/03/2018          2.2         TFS#12182 : Added new method to Copy Program Child Info
**  Neetu Ojha                  05/08/2018          2.3         TFS#12213 : Added logic to avoid duplicate Ids in list
**  Rohit Gowrishetty           05/16/2018          2.4         TFS#12133 : Updated the set of child objects which needs to be copied from revised inspection 
**  Rohit Gowrishetty           05/15/2018          2.5         TFS#12196 : Modified the deferral due date logic
**  Neetu Ojha                  06/06/2018          2.6         TFS#12195 : Added filter for Program Record Type
**  Rohit Gowrishetty           06/05/2018          2.7         TFS#13340 : Updated the case update fucntion to send report email only when it is in approved status
**  Rohit Gowrishetty           06/12/2018          2.8         TFS#13407 : Updated the functionality to update the current user as the owner of Inspection record if the assigned owner is inactive
**  Neetu Ojha                  08/24/2018          2.9         TFS#13898 : Added null check
**  Soufin Rahimeen             9/07/2018           3.0         TFS#13857 : Added logic to pass the other inspections when an inspection is delted to CLQ_UpdateProgramInspectionDate 
**  Rohit Gowrishetty           10/9/2018           3.1         TFS#14775 : Added the logic to execute only when the status changes to approval
**  Pradeep Ravi                12/17/2018          3.2         TFS#14973 : Updated the logic to populate Rating effective date on the program
**  Pradeep Ravi                01/19/2019          3.3         TFS#15288 : Updated the logic to populate Rating Type Field
**  Rahul Roy                   03/06/2019          3.4         TFS#14903 : Added logic to close Annual Inspection Reminder task on inspection creation
**  Rohit Gowrishetty           03/25/2019          3.5         TFS#15679 : Added logic to validate only queue members can approve the request.
**  Rohit Gowrishetty           04/12/2019          3.6         TFS#15269 : Added logic to check for Follou - up Inspection  
**  Vijay Gurusamy              11/19/2019          3.7         TFS#16148 : Changing owner of an approved inspection is not working correctly  
**  Sujith Balakrishnan         11/19/2019          3.8         TFS#15819 : JFS-PROD-System users should not have the ability to delete an Approved Inspection
**  Santosh Tripathi            02/04/2020          3.9         TFS#16228 : JFS-PROD- complaint cases are not changing to approved once their attached inspection is approved
**  Santosh Tripathi            02/04/2020          4.0         TFS#16195 : JFS-PROD- Complaint cases are still showing as under review when the inspection has been approved.
**  Vijay Gurusamy              03/03/2020          4.1         TFS#16564 and 16566
**  Sujith Balakrishnan         04/15/2020          4.2         TFS#16392
**  Vijay Gurusamy              04/23/2020          4.3         TFS#16767
**************************************************************************************************************/
public class CLQ_InspectionTriggerHandler_Custom extends CLQ_Trigger{
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger{
        get
        {
            if (BypassTrigger == null) BypassTrigger = false;
            return BypassTrigger;
        }
        set;
    }
    
    public static boolean HasUpdated;
    
    public override boolean getUpdateFlag(){
        return HasUpdated;
    }
    
    public override void setUpdateFlag(boolean newVal){
        HasUpdated = newVal;
    }
    
    //Calls the Base class Constructor
    public CLQ_InspectionTriggerHandler_Custom(list < sObject > newlistin, map < id, sObject > newMapin, list <sObject > oldlistin, map < id, sObject > oldMapin,
                                    boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein, boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein){
        super(newlistin, newMapin, oldlistin, oldMapin, isExecutingin, isInsertin, isUpdatein, isDeletein, isBeforein, isAfterin, isUndeletein, sizein);
        BypassInheritedTrigger = BypassTrigger;
        if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
    }
        ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    public override void BeforeInsert(){
        //UpdateCAPInfo((list < CLQ_Inspection__c > ) newList); //commented for bug# 10843
    }
    
    //13857 calling on after delete to update Program with next latest inspection date
    public override void AfterDelete() {
        //13807 call method
        callUpdateProgramInspectionDate((List < CLQ_Inspection__c > ) oldList);
        
    }  
    //TFS#15819 starts
      public override void beforedelete() {
        onbeforedelete((list<CLQ_Inspection__c>) oldlist);
        sendDeleteNotification((list<CLQ_Inspection__c>) oldlist); //TFS#16461
        }
     public void onbeforedelete(list<CLQ_Inspection__c> oldlist)
     {
     Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
         for(CLQ_Inspection__c ins : oldlist)
         {
         if(ins.CLQ_Inspection_Status__c=='Rating Assessment Complete' && (ProfileName.Name =='Approver - State User' ||ProfileName.Name =='ODE Approver - State User' ||ProfileName.Name =='ODJFS FCC Approver - County Role' || ProfileName.Name =='ODE State Admin - State User'))
         {
           ins.addError('You are not authorized to delete this inspection');  
         }
        //TFS#16767 - Starts
        if(ins.CLQ_Inspection_Status__c=='Approved' && (ProfileName.Name =='ODJFS County Admin - County Role' || ProfileName.Name =='ODJFS FCC Approver - County Role' 
                                                        || ProfileName.Name =='ODJFS FCC Reviewer - County Role' || ProfileName.Name =='Lic and SUTQ Reviewer - State User'
                                                        || ProfileName.Name =='ODE Lic and SUTQ Reviewer - State User' || ProfileName.Name =='ODE Lic Reviewer-State User'))
        {
            ins.addError('You are not authorized to delete Approved inspection'); 
        }
        //TFS#16767 - Ends


         }
     }
    //TFS#15819 ends
    public void sendDeleteNotification(list<CLQ_Inspection__c> oldlist)
     {
     List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Contact recepient = [SELECT Id From Contact Where Email = 'NOREPLY@TEST.COM' LIMIT 1];        
        List<String> emailList= new List<String>();        
        emailList.addAll(Label.PTDeletionNotificationGroup.split(';'));
        EmailTemplate et = [Select Id from EmailTemplate where Name = 'InsDeletedTemplate'];
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'jshivakumar@deloitte.com' LIMIT 1];
        for(CLQ_Inspection__c pt: (list < CLQ_Inspection__c > ) oldList){
            If( pt.CLQ_Inspection_Status__c == 'Approved' )
            {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();          
                message.setTemplateId(et.id);
                message.setwhatID(pt.id);
                message.settargetObjectID(recepient.id);
                message.setSaveAsActivity(false);
                message.setToaddresses(emailList);          
                message.setOrgWideEmailAddressId(owea.Id);
                messages.add(message);
            }
            
        }
        system.debug('Mails--' + messages);
         if(!messages.isEmpty()){ //Messaging.sendEmail(messages);
         }        
        system.debug('Mails--Done');
         
     }
    
    public override void AfterInsert(){
        UpdateCAPInfoOnTransaction((map < id, CLQ_Inspection__c > ) newMap);
        CopyInspectionChildInfo((list <CLQ_Inspection__c>)  newList); //12091
        CopyProgramChildInfoToInspection((list <CLQ_Inspection__c>)  newList); //12182
        CloseAnnualInspReminderTask((list <CLQ_Inspection__c>)  newList);//14903
    }
    
    public override void BeforeUpdate(){    
        if (!Validation((list <CLQ_Inspection__c>)  newList, (map <Id, CLQ_Inspection__c >) oldMap)) return;//11762
        checkForFollowUpInsp((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap); //15269
        UpdateDeferralDueDate((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap); //12196
        updateAllegedRulesonSubmitInspection((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);
        //insertCAPonVisitComplete((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);
        VersioningInspectionbeforeupdate((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);
        FccCheckQueueMembersApproving((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap); //15679
    }
    
    public override void AfterUpdate(){
        uPdateStatus((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);
        //uPdateStatus1((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);//11867
        //updateProgram((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);16392
        UpdateCAPInfoOnTransaction((map < id, CLQ_Inspection__c > ) newMap);
        updateProgram((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);//16392
        insertCAPonVisitComplete((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap);
        updateCaseField((list < CLQ_Inspection__c > ) newList , (map < id, CLQ_Inspection__c > ) oldMap ); //13340
        updateAllegedRuleOnCase((list < CLQ_Inspection__c > ) newList, (map < id, CLQ_Inspection__c > ) oldMap); //Added for - 11415       
    }
    
    //15269
    public void checkForFollowUpInsp(list < CLQ_Inspection__c >  newList, map < id, CLQ_Inspection__c >  oldMap){
        
        ID inspectionRT = Schema.SObjectType.Clq_inspection__c.getRecordTypeInfosByName().get('Inspection').getRecordTypeId();
        Set<Id> prgIds = new Set<Id>();
        Map<Id , List<Clq_Inspection__c>> prgWithInspections = new Map<Id , List<Clq_Inspection__c>> ();
        List<Clq_inspection__c> listOfInspectionFromProg = new List <Clq_Inspection__c> ();
        
        for(Clq_inspection__c insp:newList){
            if(insp.CLQ_Program__c != null) prgIds.add(insp.CLQ_Program__c);}
        System.debug('Prog Ids are' + prgIds);
        //Get all the inspections related to the program
        if(prgIds.size() > 0){
            listOfInspectionFromProg = [SELECT ID,CLQ_Inspection_Type__c ,CLQ_Inspection_Status__c,RecordTypeId,Clq_Program__c , clq_program__r.Id from CLQ_inspection__c where CLQ_Program__c IN :prgIds ];
            System.debug('list of insps are ' + listOfInspectionFromProg );
        }
        
        //Loop through the insp list to create a prog with insp map 
        for(Clq_inspection__c insp :listOfInspectionFromProg ){
            if(prgWithInspections.containsKey(insp.clq_program__r.Id)){
                System.debug('-- getting' + prgWithInspections.get(insp.clq_program__r.Id) );
                prgWithInspections.get(insp.clq_program__c).add(insp);
                System.debug('- After ' + prgWithInspections.get(insp.clq_program__r.Id));
            }else{
                List<Clq_Inspection__c> newinspList = new List<Clq_Inspection__c> ();
                newinspList.add(insp);
                System.debug('newinspList -- ' + newinspList);
                prgWithInspections.put(insp.clq_program__c , newinspList);
                System.debug('prgWithInspections -- ' + prgWithInspections );
            }
        }
        System.debug('prgWithInspections' + prgWithInspections); 
        
        if(prgWithInspections.size() > 0){
            for(Clq_inspection__c insp:newList){
                System.debug('Change in this inspe' + insp.Id);
                if(insp.CLQ_Inspection_Type__c == 'Follow-up' && oldMap.get(insp.Id).clq_Inspection_Type__c != 'Follow-up'){
                    List<Clq_Inspection__c> inspList = new List<Clq_Inspection__c>(); 
                    inspList = prgWithInspections.get(insp.CLQ_Program__c);
                    System.debug('Insp list from program is' + inspList);
                    if(inspList != null &&  inspList.size() > 0){
                    
                        for(Clq_inspection__c prgInsp :inspList  ){
                            System.debug('Insp --- ' + '--CLQ_Inspection_Type__c ' + prgInsp.CLQ_Inspection_Type__c + '-- CLQ_Inspection_Status__c' + prgInsp.CLQ_Inspection_Status__c);
                            
                            if(prgInsp.Id != insp.Id &&
                                prgInsp.RecordTypeId == inspectionRT && 
                               (prgInsp.CLQ_Inspection_Type__c == 'Annual' || prgInsp.CLQ_Inspection_Type__c == 'Provisional' || prgInsp.CLQ_Inspection_Type__c == 'Follow-up'  ) &&
                               (prgInsp.CLQ_Inspection_Status__c !=  'Approved' && prgInsp.CLQ_Inspection_Status__c !=  'Revised'  )                               
                              ){
                                  System.debug('Coming into this');
                                  String erroMessage = LABEL.Inspection_Error_Message ;  
                                  insp.addError(erroMessage);
                                  break;
                              }
                        }    
                    }
                }
            }    
        }
    }
    
    //15679    
    public void FccCheckQueueMembersApproving(list < CLQ_Inspection__c >  newList, map < id, CLQ_Inspection__c >  oldMap){
        
        List< Id > approversFromQueueList = new List< Id >();
        List< Id > approversList = new List< Id >();    
        List< Id > queueList = new List< Id >();
        Boolean isAdmin = false;    
        
        //Get the current user name who is doing the action
        User usr=[Select id,Profile.name from User where id =:Userinfo.getUserid()];
        String usrpro=usr.Profile.Name;
        //Checking if the user is Admin, then he has the right to approve any record. Also county Admins cannot approve the request
        if(usrpro.contains('Admin') && !usrpro.contains('County') ){ isAdmin = true;}        
        
        if(isAdmin == FALSE){
            
            System.debug('oldMap.keySet()' + oldMap.keySet());    
            List < ProcessInstance > processList = [SELECT Id, TargetObject.Name, TargetObjectID, Status, LastModifiedDate,
                                                    (SELECT Id, Actor.id, Actor.Name FROM WorkItems)
                                                    FROM ProcessInstance
                                                    WHERE TargetObjectID IN :oldMap.keySet()
                                                    AND Status IN ('Pending','Approved','Rejected') 
                                                    ORDER BY LastModifiedDate desc
                                                   ];
            System.debug('processList' + processList); 
            
            //Loop through each Process Instance
            for(ProcessInstance ProcessInst :processList){
                //Loop through each Workitem you have in pending
                for(ProcessInstanceWorkitem WorkItem :ProcessInst.WorkItems){
                    // If it is queue then we are adding into it
                    if(String.valueOf(WorkItem.ActorId).substring(0, 3) == '00G'){ queueList.add(WorkItem.ActorId);}
                    //If it is a member , then add it to the approvers List
                    if(String.valueOf(WorkItem.ActorId).substring(0, 3) == '005'){ approversList.add(WorkItem.ActorId);}
                }
            }
            System.debug('Queue lsit Id is ' + queueList);
            // Get all the members of the queue to ApproversFromQueueList
            if(!queueList.isEmpty()){
                //Query to fetch all users who are members of the specified queue
                for(GroupMember gmObj : [Select UserOrGroupId From GroupMember where GroupId in: queueList]){
                    if(String.valueOf(gmObj.UserOrGroupId).subString(0,3) == '005' && !approversFromQueueList.contains(gmObj.UserOrGroupId) ){
                        approversFromQueueList.Add(gmObj.UserOrGroupId);
                    }
                }
            }
            System.debug('User profile is' + usr.id );
            System.debug('approversFromQueueList + ' +approversFromQueueList);
            
            If(approversFromQueueList.size() > 0){
                //Loop through all the inspections and trigger the error if you find in any
                for(Clq_Inspection__c insp :newList){
                    
                    Clq_Inspection__c oldItem = oldMap.get(insp.Id);
                    if(insp.Inspection_Record_Type__c == 'Onsite Visit Record Type' && insp.CLQ_Program_Record_Type__c.contains('FCC') 
                      ){
                          if(
                              ((insp.CLQ_Inspection_Status__c == 'Rating Assessment Complete' && oldItem.CLQ_Inspection_Status__c == 'Pending Approval' ) ||
                               (insp.CLQ_Inspection_Status__c == 'In Progress' && oldItem.CLQ_Inspection_Status__c == 'Pending Approval' ) )&& 
                              (!approversFromQueueList.contains(usr.Id) && isAdmin == FALSE )
                          ){
                              insp.addError('Only queue members should be able to Approve/Reject the request');
                          }
                      }
                }        
            }else{
                System.debug('There are no Approvers in the queue');
            }
        }
        
    }
    
    //13857 start: method to call CLQ_UpdateProgramInspectionDate, when inspection is deleted consider the next latest inspection
    //this method should get the ids of the remaining inspections and pass it to the CLQ_UpdateProgramInspectionDate method
    public void callUpdateProgramInspectionDate(list < CLQ_Inspection__c > oldList) {
        List<Id> oldIds = new List<Id>(); //container to hold ids from oldlist
        Set<Id> programIds = new Set<Id>(); //store program associated with deleted inspection
        List<Id> ids = new List<Id>(); //store ids to pass to method
        
        System.debug('sr trig oldList-->' + oldList);
        
        //get the associated program ids
        if(!oldList.isEmpty()) {
            for(CLQ_Inspection__c ins : oldList) {
                oldIds.add(ins.Id);
                programIds.add(ins.CLQ_Program__c);
            }
        }
        
        
        System.debug('sr trig programIds-->' + programIds);
        
        Set<String> inspectionTypes = new Set<String>{'Annual', 'Compliance', 'Provisional'}; //all the inspection types to consider
        
        //get the associated program objects, dont filter here else we wont be able to update to null.
        //we want to get the list here
        List<CLQ_Program__c> programsToCheck = [SELECT Id, CLQ_Last_Inspection_Date__c, 
                                                (SELECT Id, CLQ_Last_Visit_Date__c,CLQ_Inspection_Type__c FROM Inspections__r WHERE CLQ_Inspection_Status__c='Approved' 
                                                AND CLQ_Inspection_Type__c in: inspectionTypes ORDER BY CLQ_Last_Visit_Date__c DESC)
                                                 FROM CLQ_Program__c WHERE Id in: programIds];
                                                
                                            
                                                
        System.debug('sr trig programsToCheck--->' + programsToCheck);                                      

        
        if(!programsToCheck.isEmpty()) { CLQ_UpdateProgramInspectionDate.updateProgramsFromProgramList(programsToCheck);
            System.debug('injecting ids into CLQ_UpdateProgramInspectionDate');
        } 
    }
    //13857 end
    
    
    //Method to update Alleged Rules when Inspection status is updated 
    //Developer : Vrajesh Sheth (vsheth@incapsulate.com, 09/02/2016)
    //@param: newlist,oldmap
    //@param: none
    public void updateAllegedRulesonSubmitInspection(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        //set of id to store inspection record id
        set < id > inspectionrecordIdSet = new set < id > ();
        //Map of Inspection id with its related case ID
        map < id, id > inspectionCaseIDMap = new map < id, id > ();
        //list of Rule Inspected record
        list < CLQ_Rules_Inspected__c > ruleInspectedList = new list < CLQ_Rules_Inspected__c > ();
        //list of Alleged Rules record
        list < CLQ_Alleged_Rule_Violation__c > allegedRulesList = new list < CLQ_Alleged_Rule_Violation__c > ();

        //Check if the inspection status is changed or not to "Under Approver Review"
        for (CLQ_Inspection__c inspectionRecord: newList){
            system.debug('CLQ_Inspection_Status__c'+inspectionRecord.CLQ_Inspection_Status__c);
            system.debug('old map CLQ_Inspection_Status__c'+oldMap.get(inspectionRecord.id).CLQ_Inspection_Status__c);
            system.debug('CLQ_Inspection_Type__c'+inspectionRecord.CLQ_Inspection_Type__c);
            system.debug('CLQ_Visit_Status__c'+inspectionRecord.CLQ_Visit_Status__c);
            system.debug('old map CLQ_Visit_Status__c'+oldMap.get(inspectionRecord.id).CLQ_Visit_Status__c);
            if ((inspectionRecord.CLQ_Inspection_Status__c == 'Under Approver Review' &&
                    (oldMap.get(inspectionRecord.id)).CLQ_Inspection_Status__c != 'Under Approver Review' && inspectionRecord.CLQ_Inspection_Type__c != 'Pre-license') ||
                    (inspectionRecord.CLQ_Visit_Status__c == 'Visit Completed' &&
                    (oldMap.get(inspectionRecord.id)).CLQ_Visit_Status__c != 'Visit Completed' && inspectionRecord.CLQ_Inspection_Type__c == 'Pre-license' && UserInfo.getUserId() == inspectionRecord.CLQ_Inspection_Owner__c)){
                    
                    inspectionrecordIdSet.add(inspectionRecord.id);
            }
        }
            
        map < ID, Schema.RecordTypeInfo > rt_Map = CLQ_Room_Space_Inspection__c.sObjectType.getDescribe().getRecordTypeInfosById();
        //Query inspection record with Rule inspected related list
        if (inspectionrecordIdSet.size() > 0){
            //Query all the case to which the inspections are associated with ans store them in map
            //Commented for CR 11415 - As the alleged rules should not be updated on the inspection status changing to Under Approver Review 
            /**for (Case caseRecord: [SELECT id
                                    , CLQ_Inspection__c
                                    FROM Case
                                    WHERE CLQ_Inspection__c in: inspectionrecordIdSet])
            {
                inspectionCaseIDMap.put(caseRecord.CLQ_Inspection__c, caseRecord.id);
            }
            ruleInspectedList = [Select Id
                              , CLQ_Result__c
                              , CLQ_Alleged_Rule_Violation__c
                              , CLQ_Alleged_Rule_Violation__r.CLQ_Decision__c
                              , CLQ_Inspection_No__c
                              , CLQ_hasSeriousRiskFinding__c
                              , CLQ_Domain_Rule__c
                              , CLQ_Decision__c
                              , CLQ_Investigation_Method__c
                              , CLQ_Allegation_Description__c
                              , CLQ_Inspection_No__r.CLQ_Inspection_Status__c
                              From CLQ_Rules_Inspected__c
                              WHERE CLQ_Inspection_No__c in: inspectionrecordIdSet
                             ];*/
            list < CLQ_Room_Space_Inspection__c > roomSpaceInspectionList = new list < CLQ_Room_Space_Inspection__c > ();
            list < String > extraField = new list < String >{'CLQ_Inspection__r.CLQ_Program__c', 'CLQ_Inspection__r.CLQ_Program_Transaction__c'};
            
            roomSpaceInspectionList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Room_Space_Inspection__c', ' CLQ_Inspection__c in: inspectionrecordIdSet', extraField));
            list < CLQ_Room_Space__c > roomSpacetoUpdate = new list < CLQ_Room_Space__c > ();
            set < id > programIDset = new set < id > ();
            set < id > programTransactionIDset = new set < id > ();
            list < CLQ_Room_Space_Transaction__c > roomSpaceTransactionlist = new list < CLQ_Room_Space_Transaction__c > ();
            
            //Copy Room Space Information
            for (CLQ_Room_Space_Inspection__c roomSpaceInspectionrecord: roomSpaceInspectionList){
                if (roomSpaceInspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c == null){
                    CLQ_Room_Space__c newrecord = (CLQ_Room_Space__c) CLQ_UtilityClass.cloneFromOneObjectToanother(roomSpaceInspectionrecord, 'CLQ_Room_Space__c');
                    newrecord.CLQ_Program__c = roomSpaceInspectionrecord.CLQ_Inspection__r.CLQ_Program__c;
                    Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space__c.getRecordTypeInfosByName().get(rt_map.get(roomSpaceInspectionrecord.recordTypeID).getName()).getRecordTypeId();
                    newrecord.recordTypeID = devRecordTypeId;
                    newrecord.CLQ_Inspection__c = null;
                    roomSpacetoUpdate.add(newrecord);
                    programIDset.add(roomSpaceInspectionrecord.CLQ_Inspection__r.CLQ_Program__c);
                }else if (roomSpaceInspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c != null){
                    CLQ_Room_Space_Transaction__c newrecord = (CLQ_Room_Space_Transaction__c) CLQ_UtilityClass.cloneFromOneObjectToanother(roomSpaceinspectionrecord, 'CLQ_Room_Space_Transaction__c');
                    newrecord.CLQ_Program_Transaction__c = roomSpaceinspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c;
                    Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space_Transaction__c.getRecordTypeInfosByName().get(rt_map.get(roomSpaceinspectionrecord.recordTypeID).getName()).getRecordTypeId();
                    newrecord.recordTypeID = devRecordTypeId;
                    roomSpaceTransactionlist.add(newrecord);
                    programTransactionIDset.add(roomSpaceInspectionrecord.CLQ_Inspection__r.CLQ_Program_Transaction__c);
                }
            }
            
            ID adminRoleRecordTypeID = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByName().get('Administrator').getRecordTypeId();
            //Loop through all Rule Inspected to check if it is derived from Allege Rule or not
            list < CLQ_Inspection__c > inspectionList = [SELECT id
                                                       , CLQ_Program__c
                                                       , CLQ_Program_Transaction__c
                                                       , CLQ_Program_Transaction__r.RecordTypeID
                                                       , CLQ_Inspection_Type__c
                                                       , CLQ_Age_Groups_Served_Global__c
                                                       , CLQ_Attendance_Options_Global__c
                                                       , CLQ_Services_Offered_Global__c
                                                       ,CLQ_Total_Enrollment__c
                                                       ,CLQ_TotalEnrollment_Under_21_2_yrs_Infan__c
                                                       ,CLQ_Total_Enrollment_Infants__c
                                                       ,CLQ_Total_Enrollment_Older_Toddler__c
                                                       ,CLQ_Total_Enrollment_Preschool__c
                                                       ,CLQ_Total_Enrollment_School_Age__c
                                                       ,CLQ_Total_Enrollment_Young_Toddler__c
                                                       , CLQ_Program__r.CLQ_Services_Offered_Global__c
                                                       , CLQ_Program__r.CLQ_Age_Groups_Served_Global__c
                                                       , CLQ_Program__r.CLQ_Attendance_Options_Global__c
                                                       , CLQ_Program_Transaction__r.CLQ_Services_Offered_Global__c
                                                       , CLQ_Program_Transaction__r.CLQ_Age_Groups_Served_Global__c
                                                       , CLQ_Program_Transaction__r.CLQ_Attendance_Options_Global__c
                                                       , CLQ_Program_Transaction__r.CLQ_Complete_Inspection__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_Under_2_1_2__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_Infants__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_Older_Toddler__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_Preschool__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_School_Age__c
                                                       , CLQ_Program_Transaction__r.CLQ_Total_Enrollment_Young_Toddler__c
                                                       , (Select Id, CLQ_Result__c, CLQ_Alleged_Rule_Violation__c, CLQ_Alleged_Rule_Violation__r.CLQ_Decision__c, CLQ_Inspection_No__c, CLQ_hasSeriousRiskFinding__c, CLQ_Domain_Rule__c, CLQ_Decision__c, CLQ_Investigation_Method__c, CLQ_Allegation_Description__c From Rules_Inspected__r)
                                                       , (SELECT id, CLQ_Program__c, CLQ_Program_Transaction__c, Name FROM Facility_Schedules__r)
                                                       , (SELECT id, Name, CLQ_Program__c, CLQ_Program_Transaction__c FROM Building_Approvals__r), (SELECT id, CLQ_Inspection__c, CLQ_Room_Group_Information__c
                                                        FROM Rooms_Space_Inspection__r)
                                                       , (SELECT id, CLQ_Program_Transaction_Source__c, CLQ_Program__c, CLQ_Status__c, CLQ_Inspection__c FROM Roles__r WHERE RecordTypeid =: adminRoleRecordTypeID AND CLQ_Status__c = 'Active')
                                                       , (SELECT id, CLQ_Complete_Inspection__c FROM CLQ_Cases__r)
                                                       FROM CLQ_Inspection__c
                                                       WHERE id in: inspectionrecordIdSet];
            list < CLQ_Building_Approval__c > buildingApprovaltoUpdate = new list < CLQ_Building_Approval__c > ();
            list < CLQ_Facility_Schedule__c > facilityScheduletoUpdate = new list < CLQ_Facility_Schedule__c > ();
            list < CLQ_Role__c > rolestoUpdate = new list < CLQ_Role__c > ();
            list < CLQ_Program_Transaction__c > programTransactionToUpdate = new list < CLQ_Program_Transaction__c > ();
            list < CLQ_Program__c > programListtoUpdate = new list < CLQ_Program__c > ();
            list < CLQ_Case_Custom__c > caseListtoUpdate = new list < CLQ_Case_Custom__c > ();
            set < id > programtoUpdateIDSet = new set < id > ();
            set < id > casetoUpdateIDSet = new set < id > ();
            set < id > programTxtoUpdateIDSet = new set < id > ();
            set < id > buildingApprovalidSet = new set < id > ();
            set < id > facilityScheduleIdset = new set < id > ();
            set < id > roleIdset = new set < id > ();

            //Copy all records to program 
            for (CLQ_Inspection__c inspectionRecord: inspectionList){
                String recordTypeName = '';
                if (inspectionRecord.CLQ_Program_Transaction__c != null)
                {
                    recordTypeName = CLQ_Program_Transaction__c.SObjectType.getDescribe().getRecordTypeInfosById().get(inspectionRecord.CLQ_Program_Transaction__r.RecordTypeId).getName();
                }
                //Update Case record
                for (CLQ_Case_Custom__c caseRecord: inspectionRecord.CLQ_Cases__r)
                {
                    caseRecord.CLQ_Complete_Inspection__c = true;
                    if (!casetoUpdateIDSet.contains(caseRecord.id)){caseListtoUpdate.add(caseRecord);}
                }
                //Copy building Approval
                for (CLQ_Building_Approval__c buildingApprovalRecord: inspectionRecord.Building_Approvals__r)
                {
                    if ((inspectionRecord.CLQ_Program_Transaction__c == null) ||
                        (
                            inspectionRecord.CLQ_Program_Transaction__c != null &&
                            (recordTypeName == 'Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName == 'Amendment- FCC - Change of Capacity / Space')))
                    {
                        if(buildingApprovalRecord.CLQ_Program__c == null){buildingApprovalRecord.CLQ_Program__c = inspectionRecord.CLQ_Program__c;
                        if (!buildingApprovalidSet.contains(buildingApprovalRecord.id)){ buildingApprovaltoUpdate.add(buildingApprovalRecord); buildingApprovalidSet.add(buildingApprovalRecord.id);}
                        }
                    }
                    else if (inspectionRecord.CLQ_Program_Transaction__c != null  &&
                        (recordTypeName == 'Amendment - ODE - Change of Location' || recordTypeName == 'Amendment - FCC - Change of Location' || recordTypeName == 'Amendment - Center - Change of Location' || recordTypeName == 'Application - CC Center' || recordTypeName ==  'Application - Day Camp' || recordTypeName == 'Application - FCC' || recordTypeName == 'Application - ODE Program'))
                    {
                        if(buildingApprovalRecord.CLQ_Program_Transaction__c == null){buildingApprovalRecord.CLQ_Program_Transaction__c = inspectionRecord.CLQ_Program_Transaction__c;
                        if (!buildingApprovalidSet.contains(buildingApprovalRecord.id)){ buildingApprovaltoUpdate.add(buildingApprovalRecord); buildingApprovalidSet.add(buildingApprovalRecord.id);}
                        }
                    }
                }
                //Copy Facility Schedules
                system.debug('====COL====>'+inspectionRecord.Facility_Schedules__r.size());
                for (CLQ_Facility_Schedule__c facilityScheduleRecord: inspectionRecord.Facility_Schedules__r)
                {
                    if (((inspectionRecord.CLQ_Program_Transaction__c == null) ||
                            ((inspectionRecord.CLQ_Program_Transaction__c != null) && (recordTypeName == 'Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName == 'Amendment- FCC - Change of Capacity / Space'))))
                    {
                        if(facilityScheduleRecord.CLQ_Program__c == null){facilityScheduleRecord.CLQ_Program__c = inspectionRecord.CLQ_Program__c;
                        if (!facilityScheduleIdset.contains(facilityScheduleRecord.id))
                        {
                            facilityScheduletoUpdate.add(facilityScheduleRecord);
                            facilityScheduleIdset.add(facilityScheduleRecord.id);
                        }
                        }
                        if (inspectionRecord.CLQ_Program__c != null && !programtoUpdateIDSet.contains(inspectionRecord.CLQ_Program__c))
                        {
                            programListtoUpdate.add(new CLQ_Program__c(id = inspectionRecord.CLQ_Program__c, CLQ_Services_Offered_Global__c = inspectionRecord.CLQ_Services_Offered_Global__c, CLQ_Age_Groups_Served_Global__c = inspectionRecord.CLQ_Age_Groups_Served_Global__c, CLQ_Attendance_Options_Global__c = inspectionRecord.CLQ_Attendance_Options_Global__c));
                            programtoUpdateIDSet.add(inspectionRecord.CLQ_Program__c);//12213
                        }
                    }
                    
                    else if (inspectionRecord.CLQ_Program_Transaction__c != null &&
                        (recordTypeName == 'Amendment - ODE - Change of Location' || recordTypeName == 'Amendment - FCC - Change of Location' || recordTypeName == 'Amendment - Center - Change of Location' || recordTypeName == 'Application - CC Center'  || recordTypeName ==  'Application - Day Camp'  || recordTypeName == 'Application - FCC' || recordTypeName == 'Application - ODE Program'))
                    {
                        
                        if(facilityScheduleRecord.CLQ_Program_Transaction__c == null){facilityScheduleRecord.CLQ_Program_Transaction__c = inspectionRecord.CLQ_Program_Transaction__c;}
                        if (!facilityScheduleIdset.contains(facilityScheduleRecord.id))
                        {
                            facilityScheduletoUpdate.add(facilityScheduleRecord);
                            facilityScheduleIdset.add(facilityScheduleRecord.id);
                        }
                        if (!programTxtoUpdateIDSet.contains(inspectionRecord.CLQ_Program_Transaction__c))
                        {
                            programTransactionToUpdate.add(new CLQ_Program_Transaction__c(id = inspectionRecord.CLQ_Program_Transaction__c, CLQ_Services_Offered_Global__c = inspectionRecord.CLQ_Services_Offered_Global__c, CLQ_Age_Groups_Served_Global__c = inspectionRecord.CLQ_Age_Groups_Served_Global__c, CLQ_Attendance_Options_Global__c = inspectionRecord.CLQ_Attendance_Options_Global__c));
                            programTxtoUpdateIDSet.add(inspectionRecord.CLQ_Program_Transaction__c);//12213
                        }
                    }
                }
                //Copy Role record
                for (CLQ_Role__c roleRecord: inspectionRecord.Roles__r)
                {
                    if (
                        (recordTypeName == 'Application - CC Center'  || recordTypeName ==  'Application - Day Camp'  || recordTypeName == 'Application - FCC' || recordTypeName == 'Application - ODE Program'))
                    {    
                    if(roleRecord.CLQ_Program_Transaction_Source__c == null){
                        roleRecord.CLQ_Program_Transaction_Source__c = inspectionRecord.CLQ_Program_Transaction__c;
                        if (!roleIdset.contains(roleRecord.id)){ rolestoUpdate.add(roleRecord); roleIdset.add(roleRecord.id);
                        }
                        }
                    }
                    else if ((roleRecord.CLQ_Program__c == null && inspectionRecord.CLQ_Program_Transaction__c == null))
                    {
                        roleRecord.CLQ_Program__c = inspectionRecord.CLQ_Program__c;
                        if (!roleIdset.contains(roleRecord.id)){rolestoUpdate.add(roleRecord); roleIdset.add(roleRecord.id);}
                    }
                }
                
                
                if(inspectionRecord.CLQ_Program_Transaction__c != null && !programTxtoUpdateIDSet.contains(inspectionRecord.CLQ_Program_Transaction__c)){
                     programTransactionToUpdate.add(new CLQ_Program_Transaction__c(id = inspectionRecord.CLQ_Program_Transaction__c,CLQ_Complete_Inspection__c = true));
                     programTxtoUpdateIDSet.add(inspectionRecord.CLQ_Program_Transaction__c);
                }
                for (CLQ_Program_Transaction__c programTransaction: programTransactionToUpdate)
                {
                    //if (programTransaction.id == inspectionRecord.CLQ_Program_Transaction__c)
                    {
                        programTransaction.CLQ_Complete_Inspection__c = true;
                        if((recordTypeName == 'Amendment- FCC - Change of Capacity / Space' 
                        || recordTypeName == 'Amendment - ODE and Center - Change of Capacity / Space' 
                        || recordTypeName == 'Amendment - ODE - Change of Location'
                        || recordTypeName == 'Amendment - FCC - Change of Location'
                        || recordTypeName == 'Amendment - Center - Change of Location'
                        )){
                        programTransaction.CLQ_Total_Enrollment__c= inspectionRecord.CLQ_Total_Enrollment__c;
                        programTransaction.CLQ_Total_Enrollment_Under_2_1_2__c= inspectionRecord.CLQ_TotalEnrollment_Under_21_2_yrs_Infan__c;
                        programTransaction.CLQ_Total_Enrollment_Infants__c = inspectionRecord.CLQ_Total_Enrollment_Infants__c;
                        programTransaction.CLQ_Total_Enrollment_Older_Toddler__c=inspectionRecord.CLQ_Total_Enrollment_Older_Toddler__c;
                        programTransaction.CLQ_Total_Enrollment_Preschool__c=inspectionRecord.CLQ_Total_Enrollment_Preschool__c;
                        programTransaction.CLQ_Total_Enrollment_School_Age__c=inspectionRecord.CLQ_Total_Enrollment_School_Age__c;
                        programTransaction.CLQ_Total_Enrollment_Young_Toddler__c=inspectionRecord.CLQ_Total_Enrollment_Young_Toddler__c;
                        }
                    }
                }
                system.debug('==programTxtoUpdateIDSet===>'+programTxtoUpdateIDSet);
                system.debug('==programTransactionToUpdate===>'+programTransactionToUpdate);
            }
                if (buildingApprovaltoUpdate.size() > 0){ update buildingApprovaltoUpdate;}
                if (facilityScheduletoUpdate.size() > 0){update facilityScheduletoUpdate;}
                if (programListtoUpdate.size() > 0){update programListtoUpdate;}
                if (programTransactionToUpdate.size() > 0){update programTransactionToUpdate;}
                if (caseListtoUpdate.size() > 0){update caseListtoUpdate; }
                if (rolestoUpdate.size() > 0){update rolestoUpdate;}
                if (roomSpacetoUpdate.size() > 0)
                {
                    //
                    if (programIDset.size() > 0)
                    {
                        list < CLQ_Room_Space__c > roomSpacetodelete = new list < CLQ_Room_Space__c > ();
                        roomSpacetodelete = [SELECT id FROM CLQ_Room_Space__c WHERE CLQ_Program__c in: programIDset];
                        delete roomSpacetodelete;
                    }
                    insert roomSpacetoUpdate;
                }
                if (roomSpaceTransactionlist.size() > 0)
                {
                    if (programTransactionIDset.size() > 0)
                    {
                        list < CLQ_Room_Space_Transaction__c > roomSpacetxtodelete = new list < CLQ_Room_Space_Transaction__c > ();
                        roomSpacetxtodelete = [Select Id, Name, CLQ_Program_Transaction__c FROM CLQ_Room_Space_Transaction__c WHERE CLQ_Program_Transaction__c in: programTransactionIDSet];
                        delete roomSpacetxtodelete;
                    }
                    insert roomSpaceTransactionlist;
                }
            } //end of if
        } //end of Method
   
    //12196 Updated the logic to change due date depending upon the profile and intitial due date
    public void UpdateDeferralDueDate(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        // 2-27 Deferral due date calculation and automatic status update to deferral
        
        List<String> listofAdminProfiles = label.DeferralAdminProfiles.split(',');
        List<CLQ_Inspection__c> InspectionList = new List<CLQ_Inspection__c>();
        List<Event> eventListforAllInsps = new List<Event>();
        Map<Id, List<Event>> mapEventInspId = new Map<Id, List<Event>>();
        
         //Getting all the inspections to a list                                                   
        for (CLQ_Inspection__c objI: newList){
            CLQ_Inspection__c oldInsp = oldMap.get(objI.id);
            if(oldInsp != null && (objI.CLQ_Inspection_Type__c == 'Ongoing Registration' || objI.CLQ_Inspection_Type__c =='Initial Registration') && 
            (objI.CLQ_DeferralDuration__c != oldInsp.CLQ_DeferralDuration__c  || objI.CLQ_Insp_DeferralDueDate__c != oldInsp.CLQ_Insp_DeferralDueDate__c)){
                InspectionList.add(objI);
            }
        }
        
        if(!InspectionList.isEmpty()){
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            
            //Get all the events associated with the triggered inspections
            eventListforAllInsps = [SELECT EndDateTime , WhatId , CLQ_Event_Status__c,OwnerId from Event  WHERE WhatId IN: InspectionList AND Type = 'Visit'
                                    AND IsDeleted=false 
                                    ORDER BY EndDateTime desc ALL ROWS ];
            
            // Divide the list of events to respective inspections
            for(Event eve:eventListforAllInsps){
                if(mapEventInspId.containsKey(eve.WhatId)){
                    mapEventInspId.get(eve.WhatId).add(eve);
                }else{
                    mapEventInspId.put(eve.WhatId,new List<Event>{eve});
                }
            }
            
            for (CLQ_Inspection__c objI: newList) {
    
                if(objI.CLQ_Inspection_Type__c == 'Ongoing Registration' || objI.CLQ_Inspection_Type__c =='Initial Registration'){
                
                    List <Event> EventList = mapEventInspId.get(objI.Id);
                    List <Event> completedEvents = new List <Event> ();
                    List <Event> notCompletedEvents = new List <Event> ();
                    Date retreievedDate;
                                
                    //Divide the event list for respective inspection for completed and in progress events  
                    if(EventList != null && !EventList.isEmpty()){//13898              
                        for (Event eve : EventList){
                            if(eve.CLQ_Event_Status__c == 'Completed' ){
                                completedEvents.add(eve);
                            }else if (eve.CLQ_Event_Status__c == 'In Progress'){
                                notCompletedEvents.add(eve);
                            }
                        }
                    }
                    
                    // If reviewer, then latest visit is taken and add the deferral duration. They cannot change in pending approval status.
                    // Remaining status both the fields are disabled
                     if(objI.CLQ_DeferralDuration__c != oldMap.get(objI.id).CLQ_DeferralDuration__c ){
                        if( notCompletedEvents.size() > 0 || (EventList != null && EventList.size() ==0) ){//13898
                            objI.addError('There are no completed events or some events are pending.');
                            return;
                        }else if(completedEvents.size()>0){
                            DateTime dt = completedEvents[0].EndDateTime;
                            retreievedDate = dt.date();
                        }
                    }
                    
                    System.debug('Latest completed event date is   ' + retreievedDate);
                                                            
                    if(profileName.contains('Reviewer') && retreievedDate != null){
                        addDays(objI, retreievedDate );                    
                    }else if(listofAdminProfiles.contains(profileName)){
                        // ADMIN profiles cannot change the deferral due date once the inspection is in approved state
                        if(objI.CLQ_Inspection_Status__c == 'Rating Assessment Complete' ){
                            if( objI.CLQ_Insp_DeferralDueDate__c != oldMap.get(objI.id).CLQ_Insp_DeferralDueDate__c ){
                                objI.addError('You cannot change deferral due date once the inspection got approved.');
                                return;
                            }
                        }
                        
                        if(retreievedDate != null && (objI.CLQ_Insp_DeferralDueDate__c == null && objI.CLQ_DeferralDuration__c != null)  || 
                                (objI.CLQ_Insp_DeferralDueDate__c == oldMap.get(objI.id).CLQ_Insp_DeferralDueDate__c && objI.CLQ_DeferralDuration__c != oldMap.get(objI.id).CLQ_DeferralDuration__c) ){
                            addDays(objI,retreievedDate);
                        }
                    }
                }
            }
        }
    }
    
    //12196
    public void addDays(CLQ_Inspection__c objI , Date dateToAdd){

        if (objI.CLQ_DeferralDuration__c == '30 Days'){
            objI.CLQ_Insp_DeferralDueDate__c = dateToAdd.addDays(30);
        }
        else if (objI.CLQ_DeferralDuration__c == '45 Days'){
            objI.CLQ_Insp_DeferralDueDate__c = dateToAdd.addDays(45);
        }
        else if (objI.CLQ_DeferralDuration__c == '60 Days'){
            objI.CLQ_Insp_DeferralDueDate__c = dateToAdd.addDays(60);
        }
    }
    
    //11867 Starts
    public void updateStatus(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        List < CLQ_Program_Transaction__c > listProgTransToUpdate = new List < CLQ_Program_Transaction__c > ();
        Map<Id, List<Id>> mapTransInspId = new Map<Id, List<Id>>();
        Map<Id, String> mapInspStatus = new Map<Id, String>();
        
        try{
            for (CLQ_Inspection__c insp: newList){
                if (insp.CLQ_Inspection_Status__c != null && insp.CLQ_Inspection_Status__c != oldMap.get(insp.Id).CLQ_Inspection_Status__c 
                    && (insp.CLQ_Inspection_Status__c == 'Pending Approval' || insp.CLQ_Inspection_Status__c == 'Rating Assessment Complete'
                        || insp.CLQ_Inspection_Status__c == 'In Progress')){
                    mapInspStatus.put(insp.Id, insp.CLQ_Inspection_Status__c);
                    if(mapTransInspId.containsKey(insp.CLQ_Program_Transaction__c)){
                        mapTransInspId.get(insp.CLQ_Program_Transaction__c).add(insp.Id);
                    }else{
                        mapTransInspId.put(insp.CLQ_Program_Transaction__c, new List<Id>{insp.Id});
                    }
                }
            }
            system.debug('mapInspStatus --- '+mapInspStatus);
            system.debug('mapTransInspId ---- '+mapTransInspId);
                        
            if(!mapTransInspId.isEmpty()){
                for (CLQ_Program_Transaction__c pt: [SELECT Id, Name, CLQ_Transaction_Status__c, CLQ_Transaction_Assigned_To__c, Skip_Validation__c 
                                                        FROM CLQ_Program_Transaction__c WHERE ID IN: mapTransInspId.keySet()]){
                    for(Id inspId : mapTransInspId.get(pt.Id)){
                        if(mapInspStatus.containsKey(inspId)){
                            if(mapInspStatus.get(inspId) == 'Pending Approval'){
                                pt.CLQ_Transaction_Status__c = 'Pending Approval';
                                pt.Skip_Validation__c = true;
                            }
                            if(mapInspStatus.get(inspId) == 'Rating Assessment Complete'){
                                pt.CLQ_Transaction_Status__c = 'Rating Assessment Complete';
                                pt.Skip_Validation__c = true;
                            }
                        
                            if(mapInspStatus.get(inspId) == 'In Progress' && pt.CLQ_Transaction_Assigned_To__c == null){
                                pt.CLQ_Transaction_Status__c = 'Submitted';
                                pt.Skip_Validation__c = true;
                            }
                        
                            if(mapInspStatus.get(inspId) == 'In Progress' && pt.CLQ_Transaction_Assigned_To__c != null){
                                pt.CLQ_Transaction_Status__c = 'Under Reviewer Review';
                                pt.Skip_Validation__c = true;
                            }
                        }
                        listProgTransToUpdate.add(pt);          
                    }
                }
            }
            
            system.debug('listProgTransToUpdate ---- '+listProgTransToUpdate);
            if(!listProgTransToUpdate.isEmpty()){
                CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
                update listProgTransToUpdate;
            }
        }catch(Exception e) {
            system.debug('Exception Occured'+e);
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','CLQ_InspectionTriggerHandler');
        }
    }
    
    public void updateProgram(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        try {
            set < Id > setInspectionIds = new set < Id > ();
            set < Id > setProgramids = new set < id > ();
            list < CLQ_Program__c > lstUpdateProgram = new list < CLQ_Program__c > ();
            list < CLQ_Program_Transaction__c > lstUpdateProgramTrans = new list < CLQ_Program_Transaction__c > ();
            map < id, CLQ_Inspection__c > mapProgramInspection = new map < Id, CLQ_Inspection__c > ();
            date objvisitdate;
            date objvisitdate1;
            datetime obj;
            integer datecount = 0;
            String ptRecType =''; //15288
            Id insRecordTypeID = Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();         
            
            for (CLQ_Inspection__c objI: newList){
                //Defect 10811 fix - Execute only if the record type is Onsite Visit Record Type
                if(insRecordTypeID == objI.RecordTypeId)
                {       
                    CLQ_Inspection__c oldObj = oldMap.get(objI.id);
                    system.debug('Old object' + oldObj.Inspection_Status__c);
                    system.debug('New object' + objI.Inspection_Status__c);
                    if (objI.CLQ_Program_Transaction__c != null && oldObj.Inspection_Status__c != objI.Inspection_Status__c &&
                        (objI.Inspection_Status__c == 'Deferral' || objI.Inspection_Status__c == 'In Progress'))
                    {
                        CLQ_Program_Transaction__c cpt = new CLQ_Program_Transaction__c(id = objI.CLQ_Program_Transaction__c);
                        cpt.CLQ_Transaction_Status__c = objI.Inspection_Status__c;
                        lstUpdateProgramTrans.add(cpt);
                    }
                    if (objI.isApproved__c && oldObj.isApproved__c == false) //14775
                    {
                        System.debug('objI approved---->' + objI.isApproved__c);
                        setInspectionIds.add(objI.id);
                        // for(integer i = 0; i<= setInspectionIds.size();i++){
                        // system.debug('InspectionId'+setInspectionIds[i]);
                        //}
                    }
                }
            }
            System.debug('setInspectionIds---->' + setInspectionIds);
            boolean flag = false; // Part of 4689 US - Vamshi
            for (CLQ_Inspection__c objI: [Select IsApproved__c, Id, Onsite_Rating__c,
                                          CLQ_Program__c, CLQ_Program__r.CLQ_License_Type__c, CLQ_Program__r.Last_6_Months_Provisional__c,
                                          CLQ_Program__r.CLQ_License_Issue_Date__c, CLQ_Inspection_End_Date__c, CLQ_Insp_DeferralDueDate__c, 
                                          CLQ_Program_Transaction__r.clq_recordtypename__c 
                                          From CLQ_Inspection__c
                                          WHERE Id IN: setInspectionIds]){ //and  = 'Continous'
                flag = objI.CLQ_Program__r.Last_6_Months_Provisional__c; // Part of 4689 US - Vamshi
                setProgramids.add(objI.CLQ_Program__c);
                mapProgramInspection.put(objI.CLQ_Program__c, objI);
                System.debug('visitinfo---->' + objI.Visit_Information__r);
                //for (Visit_Information__c objv: objI.Visit_Information__r) {
                System.debug('checking----s');
                system.debug('licence::' + objI.CLQ_Program__r.CLQ_License_Type__c + 'Visit date::' + objI.CLQ_Inspection_End_Date__c);
                
                ptRecType = objI.CLQ_Program_Transaction__r.clq_recordtypename__c; //15288
                
                if (objI.CLQ_Program__r.CLQ_License_Type__c == 'Continuous' && objI.CLQ_Inspection_End_Date__c != null && obji.CLQ_Insp_DeferralDueDate__c != null)
                {
                    System.debug('inside if---->');
                    objvisitdate = objI.CLQ_Insp_DeferralDueDate__c.adddays(30);
                    objvisitdate1 = date.today();
                }
                else if (objI.CLQ_Program__r.CLQ_License_Type__c == 'Continuous' && objI.CLQ_Inspection_End_Date__c != null)
                {
                    System.debug('inside if---->');
                    objvisitdate = objI.CLQ_Inspection_End_Date__c.adddays(30);
                    objvisitdate1 = date.today();
    
                }
                else if (objI.CLQ_Program__r.CLQ_License_Type__c == 'Provisional' && objI.CLQ_Program__r.Last_6_Months_Provisional__c)
                {
                    objvisitdate = date.today();
                    objvisitdate1 = date.today();
    
                    //US 4689 Vamshi                
                }
                else if (objI.CLQ_Program__r.CLQ_License_Type__c == 'Provisional') //TFS#14973 : Updated the logic to populate Rating effective date on the program
                {
                    if(objI.CLQ_Inspection_End_Date__c != null && obji.CLQ_Insp_DeferralDueDate__c != null && 
                       (objI.CLQ_Program_Transaction__r.clq_recordtypename__c != 'SUTQ - Expedited Registration' ||
                        objI.CLQ_Program_Transaction__r.clq_recordtypename__c != 'SUTQ - Change of Owner Registration')) {
                        objvisitdate = objI.CLQ_Insp_DeferralDueDate__c.adddays(30);
                        objvisitdate1 = date.today();
                    }
                    else if(objI.CLQ_Inspection_End_Date__c != null && (objI.CLQ_Program_Transaction__r.clq_recordtypename__c != 'SUTQ - Expedited Registration' ||
                            objI.CLQ_Program_Transaction__r.clq_recordtypename__c != 'SUTQ - Change of Owner Registration')) {
                        objvisitdate = objI.CLQ_Inspection_End_Date__c.adddays(30);
                        objvisitdate1 = date.today();                        
                    }
                    else if((objI.CLQ_Program_Transaction__r.clq_recordtypename__c == 'SUTQ - Expedited Registration' ||
                            objI.CLQ_Program_Transaction__r.clq_recordtypename__c == 'SUTQ - Change of Owner Registration')) {
                        objvisitdate = date.today();
                        objvisitdate1 = date.today();   
                    }
                    else
                    {
                        objvisitdate = objI.CLQ_Inspection_End_Date__c.adddays(30);
                        objvisitdate1 = date.today();
                    }
                        
                    /**if (objI.CLQ_Insp_DeferralDueDate__c <= objI.CLQ_Program__r.CLQ_License_Issue_Date__c.addMonths(11))
                    {
                        objvisitdate = objI.CLQ_Program__r.CLQ_License_Issue_Date__c.addyears(1);
                        objvisitdate1 = date.today();
    
                        System.debug('inside if----2>');
                    }
                    else if (objI.CLQ_Insp_DeferralDueDate__c >= objI.CLQ_Program__r.CLQ_License_Issue_Date__c.addMonths(11))
                    {
                        objvisitdate = objI.CLQ_Insp_DeferralDueDate__c.adddays(30);
                        objvisitdate1 = date.today();
    
                        System.debug('inside if----2>');
                    }
                    else if (objI.CLQ_Inspection_End_Date__c <= objI.CLQ_Program__r.CLQ_License_Issue_Date__c.addMonths(11))
                    {
                        objvisitdate = objI.CLQ_Program__r.CLQ_License_Issue_Date__c.addyears(1);
                        objvisitdate1 = date.today();
    
    
                        System.debug('inside if----2>');
                    }
                    else
                    {
                        System.debug('inside else----2>');
                        //integer remainingdays = objI.CLQ_Program__r.CLQ_License_Issue_Date__c.daysbetween(system.today());
                        // system.debug('remainingdays --->' + remainingdays);
                        // objvisitdate = objI.CLQ_Program__r.CLQ_License_Issue_Date__c.adddays(remainingdays + 30);
                        objvisitdate = objI.CLQ_Inspection_End_Date__c.adddays(30);
                        objvisitdate1 = date.today();
    
    
                    }*/
                }
                // }
            }
            system.debug('visit date::' + objvisitdate);
            datetime objtime = objvisitdate;
            datetime objtime1 = objvisitdate1;
            datetime finalVisitDate = objvisitdate;
            datetime finalVisitDate1 = objvisitdate1;
    
            system.debug('Bypass approval date.......' + finalVisitDate);
            // system.debug('objtime.format() '+objtime.format('EEEE') );
            /*system.debug('ByPass rating effective date.....' + date.newinstance(finalVisitDate.year(), finalVisitDate.month(),
                finalVisitDate.day()));*/
            if (objvisitdate != null)
            {
                System.debug('Came here');
                System.debug('flag' + flag);
                //obj = datetime.newinstance(objvisitdate.year(),objvisitdate.month(),objvisitdate.day());
                // US 46689 - Vamshi -bypass
                //objtime  = DateTime.newInstance(objtime.year(), objtime.month(), objtime.day());
                if (!flag && objtime.format('EEEE') != 'Saturday')
                {
                    for (integer i = 1; i < 7; i++)
                    {
                        objtime = objvisitdate.adddays(i);
                        system.debug('objtime --->' + objtime + '---objtime.format' + objtime.format('EEEE'));
                        if (objtime.format('EEEE') == 'Saturday')
                        {
                            //datecount = i;
                            finalVisitDate = objtime;
                            break;
                        }
                    }
                }
            }
            //TFS#16564 and 16566 Added Rating_Reduction_Date__c, Unable_to_Rate_Reasons__c, Rating_Discontinue__c
            for (CLQ_Program__c objprg: [select id, Last_6_Months_Provisional__c,Rating_Reduction_Date__c,Unable_to_Rate_Reasons__c,Rating_Discontinue__c, RatingChangedDate__c, CLQ_2_Star_Reapplying_Date__c, Rating_Effective_Date__c,
                                        Rating_Anniversary_Date__c, Program_Rating__c,Rating_Expiration_Date__c, CLQ_Rating_Type__c
                                        from CLQ_Program__c WHERE ID IN: setProgramids
                                        ])
            {
                system.debug('finalVisitDate --->' + finalVisitDate + '--datecount -->' + datecount);
                if (finalVisitDate != null)
                {
                    system.debug('AvoidRecursionCls.isRecomended ---->' + AvoidRecursionCls.isRecomended);
                    if (AvoidRecursionCls.isRecomended == false)
                    {
                        system.debug('Entered program rating -->');
                        objprg.Program_Rating__c = mapProgramInspection.get(objprg.id).Onsite_Rating__c;
                        /* objprg.Rating_Effective_Date__c = date.newinstance(finalVisitDate.year(), finalVisitDate.month(),
                            finalVisitDate.day()); //objvisitdate.adddays(datecount); */
                        objprg.Rating_Effective_Date__c = date.valueof(finalVisitDate); // Part of 4689 US - Vamshi
                        //TFS#16564 and 16566- Starts
                        system.debug('16564-20 - Start');
                        system.debug('objprg.Unable_to_Rate_Reasons__c - ' + objprg.Unable_to_Rate_Reasons__c);
                        if ( objprg.Unable_to_Rate_Reasons__c == Label.Unable_to_Rate_Reasons_Rating_Reduced ){
                            system.debug('16564-20 -RR ');
                            system.debug('objprg.Rating_Reduction_Date__c1 - ' + objprg.Rating_Reduction_Date__c);
                            system.debug('objprg.Rating_Reduction_Date__c2 - ' + objprg.Rating_Reduction_Date__c.addDays(180));
                             //Adding 7 hours of time to compensate the change from date -> dateTime and time difference
                             DateTime tempDate = objprg.Rating_Reduction_Date__c.addDays(180);
                             
                             system.debug('tempDate1 - ' + tempDate);
                            DateTime ReductionDatePlus180 = sundayOrnearSundayDate( tempDate);
                            system.debug('finalVisitDate - ' + finalVisitDate);
                            system.debug('ReductionDatePlus180 - ' + ReductionDatePlus180);
                            if( ReductionDatePlus180 > finalVisitDate )
                            {
                                objprg.Rating_Effective_Date__c = date.valueof(ReductionDatePlus180);
                            }
                        }
                        else if( objprg.Unable_to_Rate_Reasons__c == Label.Unable_to_Rate_Reasons_Rating_Removed ){
                            system.debug('16564-20 -RD ');
                            system.debug('objprg.Rating_Reduction_Date__c3 - ' + objprg.Rating_Discontinue__c);
                            system.debug('objprg.Rating_Reduction_Date__c4 - ' + objprg.Rating_Discontinue__c.addDays(12));
                            DateTime ReductionDatePlus12M = objprg.Rating_Discontinue__c.addmonths(12);
                            system.debug('finalVisitDate - ' + finalVisitDate);
                            if( ReductionDatePlus12M > finalVisitDate )
                            {
                                objprg.Rating_Effective_Date__c = date.valueof(ReductionDatePlus12M);
                            }
                        }
                        system.debug('Final Rating Effective date.......' + objprg.Rating_Effective_Date__c);
                        system.debug('program Rating Effective date.......' + objprg.Program_Rating__c);
                        if (objprg.Rating_Effective_Date__c != null && objprg.Program_Rating__c != null && objprg.Program_Rating__c ==
                            '0')
                        {
                        
                                                if (!flag && objtime1.format('EEEE') != 'Saturday')
                                        {
                                            for (integer i = 1; i < 7; i++)
                                            {
                                                objtime1 = objvisitdate1.adddays(i);
                                                system.debug('objtime1:::::::: --->' + objtime1 + '---objtime1.format::::::' + objtime1.format('EEEE'));
                                                if (objtime1.format('EEEE') == 'Saturday')
                                                {
                                                    //datecount = i;
                                                    finalVisitDate1 = objtime1;
                                                    system.debug('finalVisitDate1 :::::::: --->' + finalVisitDate1);
    
                                                    break;
                                                }
                                            }
                                        }
                             system.debug('second finalVisitDate1 :::::::: --->' + finalVisitDate1);
                            objprg.Rating_Expiration_Date__c = null;
                            objprg.Rating_Effective_Date__c = null;
                            objprg.Rating_Anniversary_Date__c = null;
                            objprg.Rating_Discontinue__c = date.valueof(finalVisitDate1); 
                            objprg.Unable_to_Rate_Reasons__c = null;
                            objprg.CLQ_Rating_Type__c = ''; //15288
                            
                        }
                        else if (objprg.Rating_Effective_Date__c != null && objprg.Program_Rating__c != null && (
                                objprg.Program_Rating__c == '1' || objprg.Program_Rating__c == '2'))
                        {
                            objprg.Rating_Expiration_Date__c = objprg.Rating_Effective_Date__c.addYears(1).adddays(-1);
                            objprg.Rating_Anniversary_Date__c = null;
                            objprg.RatingChangedDate__c = date.today();
                            objprg.Unable_to_Rate_Reasons__c = null;
                            objprg.CLQ_Rating_Type__c = ptRecType; //15288
                            system.debug('Date' + objprg.Rating_Expiration_Date__c);
                        }
                        else if (objprg.Rating_Effective_Date__c != null && objprg.Program_Rating__c != null &&
                            objprg.Program_Rating__c == '3')
                        {
                            objprg.Rating_Expiration_Date__c = objprg.Rating_Effective_Date__c.addYears(2).adddays(-1);
                            objprg.Rating_Anniversary_Date__c = objprg.Rating_Effective_Date__c.addYears(1);
                            objprg.RatingChangedDate__c = date.today();
                            objprg.Unable_to_Rate_Reasons__c = null;
                            objprg.CLQ_Rating_Type__c = ptRecType; //15288
                        }
                        else if (objprg.Rating_Effective_Date__c != null && objprg.Program_Rating__c != null && (
                                objprg.Program_Rating__c == '4' || objprg.Program_Rating__c == '5'))
                        {
                            objprg.Rating_Expiration_Date__c = objprg.Rating_Effective_Date__c.addYears(3).adddays(-1);
                            objprg.Rating_Anniversary_Date__c = objprg.Rating_Effective_Date__c.addYears(1);
                            objprg.RatingChangedDate__c = date.today();
                            objprg.Unable_to_Rate_Reasons__c = null;
                            objprg.CLQ_Rating_Type__c = ptRecType; //15288
                        }
                        system.debug('objprg' + objprg);
                        lstUpdateProgram.add(objprg);
                    }
                }
            }
            system.debug('lstUpdateProgram ---' + lstUpdateProgram);
            if (!lstUpdateProgram.isEmpty())
            {
                //AvoidRecursionCls.isOnsiteVisit = true;
                CLQ_ProgramTriggerHandler.BypassTrigger = true;
                update lstUpdateProgram;
            }
            if (!lstUpdateProgramTrans.isEmpty())
            {
                //AvoidRecursionCls.isOnsiteVisit = true;
                CLQ_Program_TransactionTriggerHandler.BypassTrigger = true;
                update lstUpdateProgramTrans;
            }
            
        }catch(Exception e) {
            System.debug('Exception Occured'+e);
        }
    }
    //method to do versioning on amendment of an Approved Inspection record.
  
    public void VersioningInspectionbeforeupdate(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        //declare all the related list objects that are present on Inspection page layout in the csv format. //15624 Removed CAP cloning
        String ChildList = 'CLQ_Rules_Inspected__c,CLQ_Staff_Record__c,CLQ_Child_Record__c,CLQ_Enrollment_Group__c,CLQ_Facility_Schedule__c,CLQ_Building_Approval__c,CLQ_Room_Space_Inspection__c,CLQ_Inspector__c'; // 12133
        String SelflookUpfield = 'CLQ_Original_Inspection__c';
        String InsSnapshotId;
        String Statusfield = 'CLQ_Inspection_Status__c';
        String IsSnapShotfield = 'CLQ_Snapshot_Copy__c';
        //Add if conditions to fire the versionin logic if needed.
        for (CLQ_Inspection__c ins: newList)
        {
            // getting the old value of status field before update and making sure the status field gets updated only on versioning and not on Approval process.
            CLQ_Inspection__c oldObj;
            //Check for De-reference ofr null object on Old Map , if another trigger of application updating Inspections.
            if (oldMap.get(ins.id) != null)
                oldObj = oldMap.get(ins.id);
            //TFS#15819 
            //if (oldObj.CLQ_Inspection_Status__c == 'Approved)
            if (oldObj.CLQ_Inspection_Status__c == 'Approved' && ins.CLQ_Inspection_Status__c !='Deleted' ) //TFS#15819 
            {
                CLQ_VersionUtility.initialiseObjectsForCloning(ins.id, ChildList);
                //CLQ_VersionUtility.doClone(ins.id, SelflookUpfield, Statusfield, IsSnapShotfield);
                ins.CLQ_Inspection_Status__c = 'Revision in Progress'; // update status only when Previous value is Approved.
                ins.CLQ_Inspection_Revision_Complete__c = false; // OJLS-872 : make the checkbox false whenver a record is up for versioning
                //13407 - Starts
                system.debug('Insp Owner Active ---- '+ins.Is_inspection_Owner_Active__c);
                if(ins.Is_inspection_Owner_Active__c == false && ins.Owner.name==oldMap.get(ins.id).Owner.name ){  //TFS#16148
               // if(userRec.IsActive == false){  //TFS#16148
                    ins.OwnerId = UserInfo.getUserId();    
                    ins.CLQ_Inspection_Owner__c = UserInfo.getUserId();
                }                                                   
            }
            //13407 - Ends
            //Update the Parent Version or Current version status to Approved upon user checking Inspection Complete and once the
            if (ins.CLQ_Inspection_Status__c == 'Revision in Progress' && ins.CLQ_Inspection_Revision_Complete__c == true)
            {
                ins.CLQ_Inspection_Status__c = 'Approved';
            }
        }
    }
    
    //Method to Create CAP records when Visit mode is completed 
    //Developer : Vrajesh Sheth (vsheth@incapsulate.com, 09/30/2016)
    //@param: newlist,oldmap
    //@param: none
    public void insertCAPonVisitComplete(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        //set of id to store inspection record id
        set < id > inspectionrecordIdSet = new set < id > ();
        //list of Rule Inspected record
        list < CLQ_Rules_Inspected__c > ruleInspectedList = new list < CLQ_Rules_Inspected__c > ();
        //Check if the CLQ_Visit_Status__c is changed or not to "Visit Completed"
        for (CLQ_Inspection__c inspectionRecord: newList)
        {
            system.debug('======>' + inspectionRecord.CLQ_Visit_Status__c);
            system.debug('======>' + (oldMap.get(inspectionRecord.id)).CLQ_Visit_Status__c);

            if (inspectionRecord.CLQ_CAP_Generated__c &&
                !(oldMap.get(inspectionRecord.id)).CLQ_CAP_Generated__c )
            {
                if(inspectionRecord.CLQ_Inspection_Status__c != 'Approved' && inspectionRecord.CLQ_Inspection_Status__c != 'Closed' && inspectionRecord.CLQ_Inspection_Status__c != 'Revised'){
                    //inspectionRecord.CLQ_CAP_Generated__c = false;
                }
                inspectionrecordIdSet.add(inspectionRecord.id);
            }
        }
        //Query Rule inspected with Findindgs
        ruleInspectedList = [Select Id
                             , CLQ_Result__c
                             , CLQ_Alleged_Rule_Violation__c
                             , CLQ_Alleged_Rule_Violation__r.CLQ_Decision__c
                             , CLQ_Inspection_No__c
                             , CLQ_Inspection_No__r.CLQ_Program__c
                             , CLQ_Inspection_No__r.CLQ_Inspection_Owner__r.Email
                             , CLQ_hasSeriousRiskFinding__c
                             , CLQ_Domain_Rule__c
                             
                             , (Select Id, OwnerId, IsDeleted, Name, CLQ_CAP_Required__c, CLQ_Comments__c, CLQ_Description__c, CLQ_Documents_Required__c, CLQ_Finding_Description__c, CLQ_Finding_Type__c, CLQ_Risk_Level__c, CLQ_Rules_Inspected__c, CLQ_Standard_Finding__c, CLQ_TA_Required__c, CLQ_Domain_Rule_Finding__c, CLQ_TA_Description__c, Rating__c, Points__c, CLQ_CAP_TA__c, CLQ_Inspection__c, CLQ_Domain_Rule__c,CLQ_Integration_Document_Type__c From Findings__r)
                             From CLQ_Rules_Inspected__c
                             WHERE CLQ_Inspection_No__c in: inspectionrecordIdSet

                            ];
        list<CLQ_Corrective_Action_Plan__c> existingCAPRecord = new list<CLQ_Corrective_Action_Plan__c>();
        map<id,CLQ_Corrective_Action_Plan__c> findingIDCAPMap = new map<id,CLQ_Corrective_Action_Plan__c>();
        existingCAPRecord = [SELECT id,CLQ_Findings__c FROM CLQ_Corrective_Action_Plan__c WHERE CLQ_Inspection__c in: inspectionrecordIdSet]; 
        for(CLQ_Corrective_Action_Plan__c capRecord : existingCAPRecord ){
            findingIDCAPMap.put(capRecord.CLQ_Findings__c,capRecord);
        }                   
        list < CLQ_Corrective_Action_Plan__c > cAPListtoinsert = new list < CLQ_Corrective_Action_Plan__c > ();
        for (CLQ_Rules_Inspected__c ruleinspectedRecord: ruleInspectedList)
        {
            system.debug('11111111111>>>' + ruleinspectedRecord.CLQ_Result__c);
            if (ruleinspectedRecord.CLQ_Result__c == 'Non-Compliant' || ruleinspectedRecord.CLQ_Result__c == 'Substantiated')
            {
                system.debug('11111111111>>>');
                for (CLQ_Findings__c findingRecord: ruleinspectedRecord.Findings__r)
                {
                    system.debug('11111111111>>>' + findingRecord.CLQ_CAP_TA__c);
                    if (findingRecord.CLQ_CAP_TA__c == 'CAP' && findingIDCAPMap != null && findingIDCAPMap.get(findingRecord.id) == null)
                    {
                        CLQ_Corrective_Action_Plan__c newCAP = new CLQ_Corrective_Action_Plan__c(CLQ_Inspection__c = ruleinspectedRecord.CLQ_Inspection_No__c, CLQ_Findings__c = findingRecord.id, CLQ_Status_Date__c = Date.today(), CLQ_Non_Compliance_Finding__c = findingRecord.CLQ_Description__c, CLQ_CAP_Status__c = 'Not Submitted', CLQ_Program__c = ruleinspectedRecord.CLQ_Inspection_No__r.CLQ_Program__c,Integration_Document_Type__c=findingRecord.CLQ_Integration_Document_Type__c);
                        if (ruleinspectedRecord.CLQ_Inspection_No__r.CLQ_Inspection_Owner__c != null)
                        {
                            newCAP.CLQ_Inspection_Owner_Email__c = ruleinspectedRecord.CLQ_Inspection_No__r.CLQ_Inspection_Owner__r.Email;
                        }
                        if (findingRecord.CLQ_Risk_Level__c == 'Serious')
                        {
                            newCAP.CLQ_CAP_Due_Date__c = (Date.Today()).adddays(5);
                        }
                        else
                        {
                            newCAP.CLQ_CAP_Due_Date__c = (Date.Today()).adddays(30);
                        }
                        if (findingRecord.CLQ_Documents_Required__c != '' && findingRecord.CLQ_Documents_Required__c != NULL)
                        {
                            newCAP.CLQ_Documents_Required_Long_Text__c = findingRecord.CLQ_Documents_Required__c;
                            //newCAP.CLQ_Documents_Required__c = 'Yes';
                        }

                        //Added as per 10437 (OJLS-1258)
                        if(newCAP.Integration_Document_Type__c!=null){
                            newCAP.CLQ_Documents_Required__c = 'Yes';
                        }else{
                            newCAP.CLQ_Documents_Required__c = 'No';
                        }
                        cAPListtoinsert.add(newCAP);
                    }
                }
            }
        }
        system.debug('=====>' + CLQ_Trigger.BypassAllTriggers);
        if (cAPListtoinsert.size() > 0)
        {
            insert cAPListtoinsert;
        }
        
    }
    
    public void UpdateCAPInfoOnTransaction(map < id, CLQ_Inspection__c > NewMap){
        set < Id > ParentIdSet = new set < Id > ();
        for (CLQ_Inspection__c item: NewMap.Values())
        {
            if (item.CLQ_Program_Transaction__c != null)
                ParentIdSet.add(item.CLQ_Program_Transaction__c);
        }
        system.Debug('UpdateCAPInfoOnTransaction Starting with ' + NewMap.size() + ' Inspections with Transactions ' + ParentIdSet.size());
        if (ParentIdSet.size() == 0) return;
        Map < Id, CLQ_Program_Transaction__c > ParentMap = new map < id, CLQ_Program_Transaction__c > (
            [SELECT id, CLQ_CAP_Complete__c, CLQ_Complete_inspection__c, (SELECT Id, CLQ_Is_All_CAP_Approved__c FROM Inspections__r)
             FROM CLQ_Program_Transaction__c
             WHERE Id IN: ParentIdSet]);
        list < CLQ_Program_Transaction__c > ParentListToUpdate = new list < CLQ_Program_Transaction__c > ();
        for (Id ParentId: ParentMap.keySet())
        {
            CLQ_Program_Transaction__c Parent = ParentMap.get(ParentId);
            system.Debug('Parent: ' + Parent.Id + '  has ' + Parent.Inspections__r.size() + ' Inspections');
            //All the CAPs for this Inspection from the database
            map < id, CLQ_Inspection__c > AllInspectionsCAPs = new map < id, CLQ_Inspection__c > (Parent.Inspections__r);
            //Replace the items in this trigger. They've been updated, but the database versions could be out of date
            for (CLQ_Inspection__c item: NewMap.Values())
            {
                if (AllInspectionsCAPs.containsKey(item.Id) || item.CLQ_Program_Transaction__c == ParentId)
                    AllInspectionsCAPs.put(item.Id, item);
            }
            //Check to see if all CAPs are approved
            boolean AllApproved = true;
      if(!AllInspectionsCAPs.isEmpty()){ //Updated by Ramana for Bug 10843 and Bug 10960      
        for (CLQ_Inspection__c item: AllInspectionsCAPs.Values())
        {
          system.Debug('******* LD **** Inspection: CLQ_Is_All_CAP_Approved: ' + item.CLQ_Is_All_CAP_Approved__c);
          AllApproved = AllApproved && item.CLQ_Is_All_CAP_Approved__c;
        }
      }
            //Finally, update the Inspection ONLY if changing the value
            if (Parent.CLQ_Complete_Inspection__c != false) //Mod by Ramana Gurivelli for Bug 10843 and Bug 10960
            {
                system.Debug('Transaction:Changing CLQ_CAP_Complete__c TO: ' + AllApproved);
                Parent.CLQ_CAP_Complete__c = AllApproved;
                ParentListToUpdate.Add(Parent);
            }
        }
        if (ParentListToUpdate.size() > 0)
        {
            boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            CLQ_Trigger.BypassAllTriggers = true;
            update ParentListToUpdate;
            CLQ_Trigger.BypassAllTriggers = PreviousValue;
        }
    }
    
    /*commenting this method as this is not used
    public void UpdateCAPInfo(list < CLQ_Inspection__c > NewList){
        for (CLQ_Inspection__c item: NewList)
             item.CLQ_Is_All_CAP_Approved__c = false;  //Mod by LD on 12/29/16 changed the value to false.
    }
*/
    
    /*Method to increment a counter field on the case record so that
    a WF rule to send complaint inspection report can be fired for CR #11235 and #11236
    Written by Vamsi V on 3/22/17 for CDC Web solution*/
    //Method rewritten for 11415 - Complaints CR to update case status upon inspection status update
    public void updateCaseField(list<CLQ_Inspection__c> newList,map < id, CLQ_Inspection__c >  oldMap){ //13340
        try{
            System.debug('Method:: updateCaseField start');
            System.debug('Number of inspection records: ' + newList.size());
            //Set defined to capture Ids for which we want to update the case records for
            Set<Id> JFSinspectionIds = new Set<Id>();
            SET<Id> ODEinspectionIds = new Set<Id>();
            Set<Id> inspectionIds = new Set<Id>();        
            Map<Id, CLQ_Inspection__c> inspStatusMap = new Map<Id, CLQ_Inspection__c>();
            //loop through new list to get inspection Ids only if
            //Inpsection type is complaint and inspection status is approved
            for(CLQ_Inspection__c inspection : newList){
                String ProgType = inspection.CLQ_Program_Record_Type__c; //Bug# 11598
                inspStatusMap.put(inspection.id, inspection);
                //Get only Complaint and Injury type inspection if updated to Approved or Under Approver Review status
                if(inspection.CLQ_Inspection_Type__c == 'Complaint' || inspection.CLQ_Inspection_Type__c == 'Complaint Submitted' || 
                    inspection.CLQ_Inspection_Type__c == 'Incident / Injury / Illness' || inspection.CLQ_Inspection_Type__c == 'Incident Injury Submitted'){
                    if((inspection.CLQ_Inspection_Status__c != oldMap.get(inspection.id).CLQ_Inspection_Status__c && (inspection.CLQ_Inspection_Status__c == 'Approved' || inspection.CLQ_Inspection_Status__c == 'Returned to Reviewer' )) || //13340
                        ((inspection.CLQ_Send_Report_To__c =='CDC Web' || inspection.CLQ_Send_Report_To__c =='CDCWeb & Portal' || inspection.CLQ_Send_Report_To__c =='Portal')
                             && inspection.CLQ_Visit_Status__c == 'Visit Completed' 
                             && inspection.CLQ_Inspection_Status__c == 'Under Approver Review'))
                    {
                        inspectionIds.add(inspection.Id);   
                    }
                }
            }
            //Get cases related to the inspections updated and update the status 
            if(!inspectionIds.isEmpty())
            {
                List<CLQ_Case_Custom__c> casesToUpdate = [SELECT CLQ_DE_Complaint_Inspection__c, CLQ_Inspection__c, CLQ_Complaint_Inspection_Approved__c,recordtypeId, ID FROM CLQ_Case_Custom__c WHERE CLQ_Inspection__c IN: inspectionIds];
                if(casesToUpdate.size()>0){
                    for(CLQ_Case_Custom__c c : casesToUpdate){
                        id recordtypeComplaintSub = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Submitted').getRecordTypeId();
                        id recordtypeComplaint = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();  
                        id recordtypeInjuryIllness = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident / Injury / Illness').getRecordTypeId(); 
                        id recordtypeInjuryIllnessSub = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Incident Injury Submitted').getRecordTypeId();                  
                        CLQ_Inspection__c insObject = new CLQ_Inspection__c();
                        insObject = inspStatusMap.get(c.CLQ_Inspection__c);
                        String ProgType = insObject.CLQ_Program_Record_Type__c;
                        //Update the counter only for Inspection type Complaint
                        if(insObject.CLQ_Inspection_Type__c == 'Complaint' && insObject.CLQ_Inspection_Status__c == 'Approved' ) //13340
                        {
                            if(ProgType == 'Child Care Center' || ProgType == 'FCC - Type A Home' || ProgType == 'FCC - Type B Home' || ProgType == 'Day Camp')
                            {
                                if(c.CLQ_Complaint_Inspection_Approved__c == null){
                                //for existing records, the value in the custom field might be null,
                                //in that case set the value to 1
                                //so that WF rule to send out Complaint Inspection Report fires
                                c.CLQ_Complaint_Inspection_Approved__c = 1;
                                }//end if
                                else if(c.CLQ_Complaint_Inspection_Approved__c != null) {
                                    //increment existing value by 1 so that the WF rule to send
                                    //complaint inspection report for CDC web fires
                                    c.CLQ_Complaint_Inspection_Approved__c = c.CLQ_Complaint_Inspection_Approved__c + 1;
                                }//end else
                            }
                            else if(ProgType == 'Pre School' || ProgType == 'School Age Child Care')
                            {
                                if(c.CLQ_DE_Complaint_Inspection__c == null){
                                    //for existing records, the value in the custom field might be null,
                                    //in that case set the value to 1
                                    //so that WF rule to send out Complaint Inspection Report fires
                                    c.CLQ_DE_Complaint_Inspection__c = 1;
                                }//end if
                                else{
                                    //increment existing value by 1 so that the WF rule to send
                                    //complaint inspection report for CDC web fires
                                    c.CLQ_DE_Complaint_Inspection__c = c.CLQ_DE_Complaint_Inspection__c + 1;
                                }//end else
                            }
                        }
                        System.Debug('c.recordtypeId** '+c.recordtypeId + ' recordtypeComplaintSub ' +recordtypeComplaintSub);
                        System.Debug('recordtypeComplaintSub** '+recordtypeComplaintSub + ' recordtypeInjuryIllnessSub ' +recordtypeInjuryIllnessSub);                    
                        if(insObject.CLQ_Inspection_Status__c == 'Under Approver Review' && c.recordtypeId == recordtypeComplaintSub)
                        {
                            // Update the case status on Inspection submit for approval
                                c.CLQ_Status__c = 'Pending Approval';
                        }
                        //TFS#16228 (Santosh Tripathi): added check to approve case when inspection of type 'Complaint Submitted' and 'Complaint' is approved
                        else if(insObject.CLQ_Inspection_Status__c == 'Approved' && (c.recordtypeId == recordtypeComplaintSub || c.recordtypeId == recordtypeComplaint || c.recordtypeId == recordtypeInjuryIllnessSub))
                        {
                            // Update the case status on Inspection submit for approval
                            //TFS#16228 (Santosh Tripathi): added check to approve case when inspection of type 'Complaint Submitted' and 'Complaint' is approved
                            if(c.recordtypeId == recordtypeComplaintSub || c.recordtypeId == recordtypeComplaint)
                                c.CLQ_Status__c = 'Approved'; 
                            else if(c.recordtypeId == recordtypeInjuryIllnessSub)
                                c.CLQ_Status__c = 'Complete';
                        }
                    }
                if(casesToUpdate.size() > 0 || casesToUpdate != null){
                    CLQ_Trigger.BypassAllTriggers = true;
                    update casesToUpdate;
                    CLQ_Trigger.BypassAllTriggers = false;
                }//end if
                }           
            }
        }catch(Exception e) {
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_InspectionTriggerHandler'); 
        }
        //Retrieve all cases with associated inspection from collection above  */ 
    }//end method updateCaseField CR #11235 and #11236
        
    //Method to copy the alleged rules from Rules inspected to the case alleged rules - CR 11415
    public void updateAllegedRuleOnCase(list < CLQ_Inspection__c > newList, map < id, CLQ_Inspection__c > oldMap){
        try
        {
            Set<Id> insIDList = new Set<Id>();
            for (CLQ_Inspection__c ins: newList)
            {
                // getting the old value of status field before update and making sure the status field gets updated only on versioning and not on Approval process.
                if ((ins.CLQ_Inspection_Status__c == 'Approved' && oldMap.get(ins.id).CLQ_Inspection_Status__c != 'Approved'))
                {
                    insIDList.add(ins.Id);
                }   
            }
            List<CLQ_Inspection__c> inspList = new List<CLQ_Inspection__c>();
            if(!insIDList.isEmpty())
            {
                //Get rules inspected and case under the inspection that has been approved
                inspList = [SELECT ID, (Select ID, CLQ_Domain_Rule__c, CLQ_Decision__c, CLQ_Investigation_Details_Outcome__c, CLQ_Investigation_Method__c, CLQ_Allegation_Description__c,
                                        CLQ_Alleged_Rule__c, CLQ_Alleged_Rule_Violation__c, CLQ_Result__c, CLQ_hasSeriousRiskFinding__c from Rules_Inspected__r where CLQ_Alleged_Rule__c = true), (Select ID from CLQ_Cases__r)
                                                from CLQ_Inspection__c where id in:insIDList]; 
                Set<Id> ruleIDs = new Set<Id>();
                Set<Id> domainRuleIDSet = new Set<Id>();                          
                if(!inspList.isEmpty())
                {
                    for(CLQ_Inspection__c insObject:inspList)
                    {
                        if(!insObject.Rules_Inspected__r.isEmpty())
                        {
                            for(CLQ_Rules_Inspected__c r:insObject.Rules_Inspected__r)
                            {
                                ruleIDs.add(r.Id);
                                domainRuleIDSet.add(r.CLQ_Domain_Rule__c);
                            }
                        }
                    }
                }
                List<CLQ_Findings__c> findingsList = [Select Id, CLQ_Alleged_Rule_Violation__c, CLQ_Rules_Inspected__c from CLQ_Findings__c where CLQ_Rules_Inspected__c in:ruleIDs];
                //Copy findings to alleged rule on case
                Map<Id,List<CLQ_Findings__c>> ruleFindingMap = new Map<Id,List<CLQ_Findings__c>>();
                if(!findingsList.isEmpty())
                {
                    for(CLQ_Findings__c f:findingsList)
                    {
                       if(ruleFindingMap.containsKey(f.CLQ_Rules_Inspected__c)){
                            ruleFindingMap.get(f.CLQ_Rules_Inspected__c).add(f);
                        }else{
                            ruleFindingMap.put(f.CLQ_Rules_Inspected__c, new List<CLQ_Findings__c>{f});
                        }
                    }
                }
                
                //12213 Starts
                map <Id, List<CLQ_Alleged_Rule_Violation__c>> mapInspARV = new map <Id, List<CLQ_Alleged_Rule_Violation__c>> ();
                //Get the alleged rules list under the case mapped to inspection
                for(CLQ_Alleged_Rule_Violation__c arvObj : [Select  Id, CLQ_Domain_Rule__c, CLQ_Investigation_Method__c, CLQ_Allegation_Description__c, CLQ_Decision__c, CLQ_Investigation_Details_Outcome__c,  
                                                            CLQ_Rule_Name__c, Case_Custom__r.CLQ_Inspection__c, CLQ_Serious_Risk_Non_Compliance__c, CLQ_Result__c 
                                                            From CLQ_Alleged_Rule_Violation__c where Case_Custom__r.CLQ_Inspection__c in :insIDList]){
                    if(mapInspARV.containsKey(arvObj.Case_Custom__r.CLQ_Inspection__c)){
                        mapInspARV.get(arvObj.Case_Custom__r.CLQ_Inspection__c).add(arvObj);
                    }else{
                        mapInspARV.put(arvObj.Case_Custom__r.CLQ_Inspection__c, new List<CLQ_Alleged_Rule_Violation__c> {arvObj});
                    }                                               
                }
                //12213 Ends
                if(!mapInspARV.isEmpty())
                {
                    List<CLQ_Alleged_Rule_Violation__c> allegedRuleUpdatedList = new List<CLQ_Alleged_Rule_Violation__c>();
                    List<CLQ_Findings__c> fListToUpdate = new List<CLQ_Findings__c>();
                    List<CLQ_Alleged_Rule_Violation__c> allegedRulesToDelete = new List<CLQ_Alleged_Rule_Violation__c>();
                    for(CLQ_Inspection__c insObject: inspList)
                    {               
                        if(mapInspARV.containsKey(insObject.Id)){
                        for(CLQ_Alleged_Rule_Violation__c allegedRule: mapInspARV.get(insObject.Id))//12213
                        {
                                Boolean isAllegedRuleExist = false;
                                //List<CLQ_Rules_Inspected__c> ruleList = insObject.Rules_Inspected__r;
                                if(!insObject.Rules_Inspected__r.isEmpty())
                                {
                                    for(CLQ_Rules_Inspected__c r:insObject.Rules_Inspected__r)
                                    {
                                        if((r.CLQ_Alleged_Rule__c) && (r.CLQ_Domain_Rule__c == allegedRule.CLQ_Domain_Rule__c) && (r.CLQ_Alleged_Rule_Violation__c == allegedRule.Id)) 
                                        {
                                            isAllegedRuleExist = true;
                                            if(!ruleFindingMap.isEmpty())
                                            {
                                                if(ruleFindingMap.get(r.id) != null)
                                                {
                                                    for(CLQ_Findings__c finding: ruleFindingMap.get(r.id))
                                                    {
                                                        finding.CLQ_Alleged_Rule_Violation__c = allegedRule.Id;
                                                        fListToUpdate.add(finding);
                                                    }
                                                }
                                            }
                                            boolean isChanged = false;
                                            if(r.CLQ_Investigation_Method__c != null)
                                            {
                                                if(!r.CLQ_Investigation_Method__c.equals(allegedRule.CLQ_Investigation_Method__c))
                                                {
                                                    isChanged = true;
                                                    allegedRule.CLQ_Investigation_Method__c = r.CLQ_Investigation_Method__c;
                                                }
                                            }
                                            else if(r.CLQ_Investigation_Method__c == null && allegedRule.CLQ_Investigation_Method__c != null)
                                            {
                                                isChanged = true;
                                                allegedRule.CLQ_Investigation_Method__c = r.CLQ_Investigation_Method__c;
                                            }
                                            if(r.CLQ_Allegation_Description__c != null)
                                            {                                       
                                                if(!r.CLQ_Allegation_Description__c.equals(allegedRule.CLQ_Allegation_Description__c))
                                                {
                                                    isChanged = true;                                   
                                                    allegedRule.CLQ_Allegation_Description__c = r.CLQ_Allegation_Description__c;
                                                }
                                            }
                                            else if(r.CLQ_Allegation_Description__c == null && allegedRule.CLQ_Allegation_Description__c != null)
                                            {
                                                isChanged = true;
                                                allegedRule.CLQ_Allegation_Description__c = r.CLQ_Allegation_Description__c;
                                            }
                                            if(r.CLQ_Result__c != null)
                                            {                                       
                                                if(!r.CLQ_Result__c.equals(allegedRule.CLQ_Result__c))
                                                {
                                                    isChanged = true;                                   
                                                    allegedRule.CLQ_Result__c = r.CLQ_Result__c;
                                                }
                                            }
                                            else if(r.CLQ_Result__c == null && allegedRule.CLQ_Result__c != null)
                                            {
                                                isChanged = true;
                                                allegedRule.CLQ_Result__c = r.CLQ_Result__c;
                                            }                                           
                                            if(r.CLQ_Investigation_Details_Outcome__c != null)
                                            {                                       
                                                if(!r.CLQ_Investigation_Details_Outcome__c.equals(allegedRule.CLQ_Investigation_Details_Outcome__c))
                                                {
                                                    isChanged = true;                                   
                                                    allegedRule.CLQ_Investigation_Details_Outcome__c = r.CLQ_Investigation_Details_Outcome__c;
                                                }
                                            }
                                            else if(r.CLQ_Investigation_Details_Outcome__c == null && allegedRule.CLQ_Investigation_Details_Outcome__c != null)
                                            {
                                                isChanged = true;
                                                allegedRule.CLQ_Investigation_Details_Outcome__c = r.CLQ_Investigation_Details_Outcome__c;
                                            }  
                                            if (r.CLQ_hasSeriousRiskFinding__c == true)
                                            {
                                                allegedRule.CLQ_Serious_Risk_Non_Compliance__c = 'Yes';
                                            }
                                            else
                                            {
                                                allegedRule.CLQ_Serious_Risk_Non_Compliance__c = 'No';
                                            }                                         
                                            if(isChanged)
                                            {
                                                allegedRuleUpdatedList.add(allegedRule);
                                            }
                                        }
                                    }
                            }
                            if(!isAllegedRuleExist)
                            {
                                allegedRulesToDelete.add(allegedRule);
                            }
                        }
                    }
                    }
                    if(!allegedRuleUpdatedList.isEmpty())
                    {
                        Set<CLQ_Alleged_Rule_Violation__c> myset = new Set<CLQ_Alleged_Rule_Violation__c>();
                        List<CLQ_Alleged_Rule_Violation__c> result = new List<CLQ_Alleged_Rule_Violation__c>();
                        myset.addAll(allegedRuleUpdatedList);
                        result.addAll(myset);
                        update result;
                    }
                    if(!fListToUpdate.isEmpty())
                        update fListToUpdate;      
                    if(!allegedRulesToDelete.isEmpty())
                        delete allegedRulesToDelete;         
                }
            }
        }catch(Exception e)
        {
            System.Debug('Execption Occured' +e);
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_InspectionTriggerHandler'); 
        }
    }
    
    //11762 Starts
    private boolean Validation(list <CLQ_Inspection__c> newList, map <Id, CLQ_Inspection__c> oldMap){
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
        //12069 Ends
        
        for (CLQ_Inspection__c insp: newList){
            
            if(insp.CLQ_Program_Record_Type__c != null && !setPrgRecType.contains(insp.CLQ_Program_Record_Type__c) && userRec != null && userRec.userRoleId <> null
                    && (userRec.userRole.name.containsIgnorecase('County Admin') || userRec.userRole.name.containsIgnorecase('County Approver') || userRec.userRole.name.containsIgnorecase('County Reviewer'))){//12195
                insp.AddError(Label.JFS_OtherPRG_Update_Error_Message+' Inspections.');
                isValidated = false;                
            }           
            //12069- added setCombinedCounties in If clause
            if(isValidated && setPrgRecType.contains(insp.CLQ_Program_Record_Type__c) && insp.CLQ_County__c <> null && insp.CLQ_County__c != '' && 
                !setCombinedCounties.contains(insp.CLQ_County__c.toUpperCase()) && (userRec <> null && userRec.userRoleId <> null
                && (userRec.userRole.name.containsIgnorecase('County Admin') || userRec.userRole.name.containsIgnorecase('County Approver') || userRec.userRole.name.containsIgnorecase('County Reviewer')) 
                && !userRec.userRole.name.containsIgnorecase(insp.CLQ_County__c))){ //11903
                
                insp.AddError(Label.Update_Error_Message);
                isValidated = false;    
            }
        }
        return isValidated;
    }
    //11762 Ends  
    
    //12091 Starts
    /*Method to copy inspection related records*/
    private static void CopyInspectionChildInfo(List<CLQ_Inspection__c> lstInspection){
        Map<Id,List<Id>> mapInspFollowUpInspID = new Map<Id,List<Id>>();
        List<CLQ_Building_Approval__c> lstBAToInsert = new List<CLQ_Building_Approval__c>();
        List<CLQ_Room_Space_Inspection__c> lstRSIToInsert = new List<CLQ_Room_Space_Inspection__c>();
        
        try{
            for(CLQ_Inspection__c inspObj : lstInspection){
                if(inspObj.CLQ_Inspection_Type__c == 'Follow-up'){
                    if(mapInspFollowUpInspID.containsKey(inspObj.CLQ_Original_Inspection__c)){
                        mapInspFollowUpInspID.get(inspObj.CLQ_Original_Inspection__c).add(inspObj.Id);
                    }else{
                        mapInspFollowUpInspID.put(inspObj.CLQ_Original_Inspection__c, new List<Id>{inspObj.Id});
                    }
                }
            }
            system.debug('mapInspFollowUpInspID ---- '+mapInspFollowUpInspID);
            if(!mapInspFollowUpInspID.isEmpty()){
                Set<Id> setInspId = mapInspFollowUpInspID.keySet();
                String strBAFields = getAllFields('CLQ_Building_Approval__c')+' ,Owner.Name, Owner.IsActive';
                String strRSIFields = getAllFields('CLQ_Room_Space_Inspection__c');
                String strQuery = 'Select Id, (Select '+strBAFields+' FROM Building_Approvals__r), '+
                                    '(Select '+strRSIFields+' FROM Rooms_Space_Inspection__r)' +
                                    ' from CLQ_Inspection__c where Id IN : setInspId';
                
                system.debug('strQuery --- '+strQuery);
                
                for(CLQ_Inspection__c inspObj : (List<CLQ_Inspection__c>)Database.Query(strQuery)){ 
                    system.debug('Bldng App ----- '+inspObj.Building_Approvals__r);
                    system.debug('rsiObj ----- '+inspObj.Rooms_Space_Inspection__r);
                                            
                        for(CLQ_Building_Approval__c baObj : inspObj.Building_Approvals__r)
                        {
                            for(Id followUpInspId : mapInspFollowUpInspID.get(inspObj.Id))
                            {
                                CLQ_Building_Approval__c newBA = (CLQ_Building_Approval__c)CLQ_UtilityClass.cloneFromOneObjectToanother(baObj,'CLQ_Building_Approval__c');
                                newBA.CLQ_Inspection__c = followUpInspId;
                                lstBAToInsert.add(newBA);
                            }
                        }
                        
                        for(CLQ_Room_Space_Inspection__c rsiObj : inspObj.Rooms_Space_Inspection__r)
                        {
                            for(Id followUpInspId : mapInspFollowUpInspID.get(inspObj.Id))
                            {
                            CLQ_Room_Space_Inspection__c newRSI = (CLQ_Room_Space_Inspection__c)CLQ_UtilityClass.cloneFromOneObjectToanother(rsiObj,'CLQ_Room_Space_Inspection__c');
                            newRSI.CLQ_Inspection__c = followUpInspId;
                            lstRSIToInsert.add(newRSI); 
                        }
                    }
                }                               
                system.debug('lstBAToInsert ---- '+lstBAToInsert);
                system.debug('lstRSIToInsert ---- '+lstRSIToInsert);
                if(!lstBAToInsert.isEmpty()){
                    insert lstBAToInsert;
                }
                
                if(!lstRSIToInsert.isEmpty()){
                    insert lstRSIToInsert;
                }               
            }
        }catch(Exception e){
            System.Debug('Execption Occured' +e);
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_InspectionTriggerHandler'); 
        }
    }
    
    /*Method to get all Fields for Object*/
    private static string getAllFields(String objName){
        String strFields = '';
        SObjectType objDescribe = Schema.getGlobalDescribe().get(objName);
        
        for(String field : objDescribe.getDescribe().fields.getMap().keySet()){
            strFields += field+',';
        }
        strFields = strFields.subString(0, strFields.length()-(strFields.length()-strFields.lastIndexOf(',')));
        system.debug('strFields --- '+strFields);
        return strFields;
    }
    //12091 Ends  
    
    //12182 Starts
    /*Method to copy Program related records*/
    private static void CopyProgramChildInfoToInspection(List<CLQ_Inspection__c> lstInspection){
        Map<Id,List<Id>> mapProgramInspID = new Map<Id,List<Id>>();
        List<CLQ_Room_Space_Inspection__c> lstRSIToInsert = new List<CLQ_Room_Space_Inspection__c>();
        Id onsiteVisitRecTypeId = Schema.CLQ_Inspection__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        
        try{
            for(CLQ_Inspection__c inspObj : lstInspection){
                if(inspObj.RecordTypeId == onsiteVisitRecTypeId){
                    if(mapProgramInspID.containsKey(inspObj.CLQ_Program__c)){
                        mapProgramInspID.get(inspObj.CLQ_Program__c).add(inspObj.Id);
                    }else{
                        mapProgramInspID.put(inspObj.CLQ_Program__c, new List<Id>{inspObj.Id});
                    }
                }
            }
            system.debug('mapProgramInspID ---- '+mapProgramInspID);
            
            if(!mapProgramInspID.isEmpty()){
                Set<Id> setProgramId = mapProgramInspID.keySet();
                
                String strRSFields = getAllFields('CLQ_Room_Space__c')+' ,Owner.Name, Owner.IsActive';
                
                String strQuery = 'Select Id, (Select '+strRSFields+' FROM Rooms_Spaces__r)' +
                                    ' from CLQ_Program__c where Id IN : setProgramId';
                
                system.debug('strQuery --- '+strQuery);
                
                map<ID,Schema.RecordTypeInfo> roomSpaceRT_Map = CLQ_Room_Space__c.sObjectType.getDescribe().getRecordTypeInfosById();
                
                for(CLQ_Program__c prgObj : (List<CLQ_Program__c>)Database.Query(strQuery)){ 
                    system.debug('roomSpaceObj ----- '+prgObj.Rooms_Spaces__r);
                    
                    for(CLQ_Room_Space__c roomSpaceObj : prgObj.Rooms_Spaces__r){
                        for(Id inspId : mapProgramInspID.get(prgObj.Id)){
                            CLQ_Room_Space_Inspection__c newRSI = (CLQ_Room_Space_Inspection__c)CLQ_UtilityClass.cloneFromOneObjectToanother(roomSpaceObj,'CLQ_Room_Space_Inspection__c');
                            newRSI.CLQ_Inspection__c = inspId;
                            newRSI.CLQ_Room_Group_Information__c = roomSpaceObj.id;
                            newRSI.CLQ_Program__c = null;
                            newRSI.CLQ_Program_Transaction__c = null;   
                            newRSI.recordTypeID = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByName().get(roomSpaceRT_Map.get(roomSpaceObj.recordTypeID).getName()).getRecordTypeId();                   
                            lstRSIToInsert.add(newRSI); 
                        }
                    }
                }                               
                system.debug('lstRSIToInsert ---- '+lstRSIToInsert);
                if(!lstRSIToInsert.isEmpty()){
                    insert lstRSIToInsert;
                }               
            }
        }catch(Exception e){
            System.Debug('Execption Occured' +e);
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_InspectionTriggerHandler'); 
        }
    }    
    //12182 Ends   
    //14903 Start   
    private static void CloseAnnualInspReminderTask(List<CLQ_Inspection__c> lstInspection){
 
        Set<Id> listofProgIds = new Set<Id>();
        for (CLQ_Inspection__c ins: lstInspection){
            
            if(ins.Program_Jurisdiction__c == 'ODE' && ins.CLQ_Inspection_Type__c == 'Annual'){
                if(ins.CLQ_License_Type__c == 'Continuous' && (ins.CLQ_Program_Status__c == 'Open' || ins.CLQ_Program_Status__c == 'Enforcement')){
                    listofProgIds.add(ins.CLQ_Program__c);
                }
            }
            else if(ins.Program_Jurisdiction__c == 'JFS' && (ins.CLQ_Inspection_Type__c == 'Annual' || ins.CLQ_Inspection_Type__c == 'Provisional')){
                if(ins.CLQ_Program_Record_Type__c == 'Child Care Center'){
                    if(ins.CLQ_License_Type__c == 'Continuous' && (ins.CLQ_Program_Status__c == 'Open' || ins.CLQ_Program_Status__c == 'Enforcement')){
                        listofProgIds.add(ins.CLQ_Program__c);
                    }
                }
            }
            
        } 
        list<Task> taskslist = new list<Task>();
        taskslist = [SELECT Id from Task WHERE Subject = 'Annual Licensing Inspection Due Reminder' AND Status = 'Open' AND WhatId in:listofProgIds];
        if(taskslist.size()>0){
            for(Task taskRecord: taskslist){
                taskRecord.Status = 'Completed';
                system.debug('closing CloseAnnualInspReminderTask for ---- '+ listofProgIds);
            }
        }
        try {
            boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            CLQ_Trigger.BypassAllTriggers = true;
            update taskslist;
            CLQ_Trigger.BypassAllTriggers = PreviousValue;
        }catch(Exception e){
            system.debug('Exception::'+e);
            Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_AnswerTriggerHandler');
        }

    }
    //TFS#16564 and 16566
    public Datetime sundayOrnearSundayDate(Datetime tempDate){
        
        System.debug('Tempdate is ' + tempDate );
        DateTime sundayOrlaterDate ;
        date dt1 = date.valueOf(tempDate);
        tempDate = tempDate.addHours(7);
        System.debug('tempDate.format' + tempDate.format('EEEE'));
        if(tempDate.format('EEEE') != 'Sunday'){
            DateTime temp;
            for (integer i = 1; i < 7; i++)
            {
                temp = tempDate.adddays(i);
                if(temp.format('EEEE') == 'Sunday')
                {
                    sundayOrlaterDate = temp;
                    break;
                }
            }
        }else{
            sundayOrlaterDate = tempDate ;
        }
        
        System.debug('Sunday after approval date is '+ sundayOrlaterDate);        
        
        return sundayOrlaterDate;
    }

}