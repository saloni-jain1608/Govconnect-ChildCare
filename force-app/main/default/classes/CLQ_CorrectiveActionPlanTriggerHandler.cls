/**************************************************************************************************************
** Name             : CLQ_CorrectiveActionPlanTriggerHandler
** Description      : Invoked from CAP trigger
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version       Description
**------------------------------------------------------------------------------------------------------------
** IncapsulateDevTeam                July-2016                    1.0        Created
** Ramana Gurivelli                  May 3, 2017                  1.1        Updated for bug# 10843                   
** Rahul Roy                         June 19, 2019                1.2        Updated for CR 15686 
**************************************************************************************************************/ 
public with sharing class CLQ_CorrectiveActionPlanTriggerHandler extends CLQ_Trigger
{
    
    public static final string BRS='<br><br>';
    public static final string BR='<br>';
    public static final string EMPTY='';
    public static final string APPROVED = 'Approved';
    public static final string REPORT_REVISED = 'Report Revised - Not Required';
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger
    {
        get
        {
            if (BypassTrigger == null) {BypassTrigger = false;}
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
    //Calls the Base class Constructor
    public CLQ_CorrectiveActionPlanTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,
                                                  map < id, sObject > oldMapin,
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
    public override void AfterInsert()
    {
        UpdateCAPInfoOnInspection((map <id, CLQ_Corrective_Action_Plan__c > ) NewMap);
    }
    public override void AfterUpdate()
    {
        UpdateCAPInfoOnInspection((map <id, CLQ_Corrective_Action_Plan__c > ) NewMap);
        //grantEditAccessToOwnerOnCAPDocs((List<CLQ_Corrective_Action_Plan__c>) newList,(map<id,CLQ_Corrective_Action_Plan__c>)oldMap);
    }
    
    //15686 start
    public override void BeforeUpdate() {
        AppendReviewerComments((list < CLQ_Corrective_Action_Plan__c > ) newList, (map < id, CLQ_Corrective_Action_Plan__c > ) oldMap);
    }
    //15686 end
    
    public void UpdateCAPInfoOnInspection(map <id, CLQ_Corrective_Action_Plan__c > NewMap)
    {
        set < Id > InspectionIdSet = new set < Id > ();
        for (CLQ_Corrective_Action_Plan__c cap: NewMap.Values())
        {
            if (cap.CLQ_Inspection__c != null){
                InspectionIdSet.add(cap.CLQ_Inspection__c);}
        }
        Map < Id, CLQ_Inspection__c > InspectionMap;
        if (InspectionIdSet.IsEmpty()) {return;}
        else{
            if(InspectionIdSet != null){
                InspectionMap = new map<id, CLQ_Inspection__c>([SELECT id, CLQ_Is_All_CAP_Approved__c,CLQ_Program_Transaction__c, 
             	(SELECT Id, CLQ_CAP_Status__c FROM Corrective_Action_Plans__r LIMIT 1999) FROM CLQ_Inspection__c WHERE Id IN :InspectionIdSet ]);
            }
        }
        
        list<CLQ_Inspection__c> InspectionListToUpdate = new list<CLQ_Inspection__c>();
        for(Id InspId : InspectionMap.keySet())
        {
            CLQ_Inspection__c Inspection;
            if(InspectionMap.size()!=0){
            	Inspection = InspectionMap.get(InspId);
            }
            //system.Debug('Inspection: ' + Inspection.Id + '  has ' + Inspection.Corrective_Action_Plans__r.size() + ' CAPs');
            //All the CAPs for this Inspection from the database
            map <id, CLQ_Corrective_Action_Plan__c > AllInspectionsCAPs = new map <id, CLQ_Corrective_Action_Plan__c >(Inspection.Corrective_Action_Plans__r);
            //Replace the items in this trigger. They've been updated, but the database versions could be out of date
            for (CLQ_Corrective_Action_Plan__c cap: NewMap.Values())
            {
                if (AllInspectionsCAPs.containsKey(cap.Id) || cap.CLQ_Inspection__c == InspId){
                    AllInspectionsCAPs.put(cap.Id, cap);
                }
            }
            
            //Check to see if all CAPs are approved
            boolean AllApproved = true;
            if(!AllInspectionsCAPs.isEmpty()){ //PB on 5/2/2017 added condition to check for null CAP value for bug# 10843
                for (CLQ_Corrective_Action_Plan__c cap: AllInspectionsCAPs.Values())
                {
                    system.Debug('CorrectiveActionPlan: Status: ' + cap.CLQ_CAP_Status__c);
                    if (cap.CLQ_CAP_Status__c != APPROVED && cap.CLQ_CAP_Status__c != REPORT_REVISED){
                        AllApproved = false; 
                    }
                }
                system.Debug('Inspection:Is_All_CAP_Approved  TO: ' + AllApproved);
            }
            //Finally, update the Inspection ONLY if changing the value
            //if (Inspection.CLQ_Is_All_CAP_Approved__c != AllApproved)
            //{
                system.Debug('Inspection:Changing CLQ_Is_All_CAP_Approved__c TO: ' + AllApproved);
                Inspection.CLQ_Is_All_CAP_Approved__c = AllApproved;
                InspectionListToUpdate.Add(Inspection);
            //}
        }
        
        if (!InspectionListToUpdate.isEmpty())
        {
            boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            CLQ_Trigger.BypassAllTriggers = true;
            //system.Debug('InspectionListToUpdate: ' + InspectionListToUpdate.size() + ' To update in the Inspection Trigger');
            update InspectionListToUpdate;
            CLQ_InspectionTriggerHandler_Custom Handler = new CLQ_InspectionTriggerHandler_Custom(
                newList, newMap, oldList, oldMap,
                isExecuting, isInsert, isUpdate, isDelete, 
                isBefore, isAfter, isUndelete, size);
            map<Id,CLQ_Inspection__c> InspMap = new map<Id,CLQ_Inspection__c>(InspectionListToUpdate);
            system.Debug('InspectionListToUpdate.UpdateCAPInfoOnTransaction Starting with ' + InspMap.size());
            Handler.UpdateCAPInfoOnTransaction(InspMap );
            system.Debug('InspectionListToUpdate.UpdateCAPInfoOnTransaction Finished');
            CLQ_Trigger.BypassAllTriggers = PreviousValue;
        }
    }
    
    //public void grantEditAccessToOwnerOnCAPDocs(List<CLQ_Corrective_Action_Plan__c> newList,Map<Id,CLQ_Corrective_Action_Plan__c> oldMap) {
        //system.debug('call capShare: '+newList);
        //new OCLQS_ProgTransChildrenSharingHandler().shareCAPChildrenWithCAPOwner(newList,oldMap);
    //}
    
//15686 start
    public void AppendReviewerComments(list<CLQ_Corrective_Action_Plan__c> newList,map<id, CLQ_Corrective_Action_Plan__c> oldMap){
        
        for(CLQ_Corrective_Action_Plan__c cap : newList){
            
            Integer oldRevCommentLength = 0;
        	Integer newRevCommentLength = 0;
			String newReviewerComment = EMPTY;
            
            if(!String.isBlank(cap.CLQ_Reviewer_Comments__c) && (oldMap.size()!=0 && cap.CLQ_Reviewer_Comments__c != oldMap.get(cap.Id).CLQ_Reviewer_Comments__c)){
               	
                if(String.isBlank(oldMap.get(cap.Id).CLQ_Reviewer_Comments__c) ){
                    newReviewerComment = cap.CLQ_Reviewer_Comments__c ; 
                }
                else{
                    
                    oldRevCommentLength = oldMap.get(cap.Id).CLQ_Reviewer_Comments__c.length();
                	newRevCommentLength = cap.CLQ_Reviewer_Comments__c.length();
                    //System.debug('old rev comm --> '+ oldMap.get(cap.Id).CLQ_Reviewer_Comments__c);
                    //System.debug('comm is -->' + cap.CLQ_Reviewer_Comments__c.substring(0,oldRevCommentLength));
                    if( ( oldRevCommentLength > newRevCommentLength ) || ( oldRevCommentLength == newRevCommentLength )  
                       || oldMap.get(cap.Id).CLQ_Reviewer_Comments__c != cap.CLQ_Reviewer_Comments__c.substring(0,oldRevCommentLength)){
                        newReviewerComment = cap.CLQ_Reviewer_Comments__c ;
                       }
                    else{
                    	newReviewerComment = cap.CLQ_Reviewer_Comments__c.substring(oldRevCommentLength).trim();
                    }
                }
                //System.debug('old comment length is '+ oldRevCommentLength);
                //System.debug('new comment length is ' + newRevCommentLength);
                //System.debug('new comment is ' + newReviewerComment);
                if(String.isBlank(cap.CLQ_Previous_Comments__c)){
                    //add to top of comments of line, i.e. no append
                    cap.CLQ_Previous_Comments__c = newReviewerComment  +BRS+UserInfo.getName() +BR + system.now().format() ; 
                }//end if
                else{
                    cap.CLQ_Previous_Comments__c = cap.CLQ_Previous_Comments__c + BRS + newReviewerComment  +BRS+UserInfo.getName() +BR + system.now().format(); 
                }//end else
            	
                cap.CLQ_Reviewer_Comments__c = newReviewerComment;
            }//end if
            
            /** Validations below **/
               if(oldMap.size()!=0 && !String.isBlank(cap.CLQ_Previous_Comments__c) && !String.isBlank(oldMap.get(cap.Id).CLQ_Previous_Comments__c) 
                   && cap.CLQ_Previous_Comments__c.length() < oldMap.get(cap.Id).CLQ_Previous_Comments__c.length()){
                    cap.AddError('Your account is not authorized to change the content in the Previous Comments field. Please undo your changes');
                }
            
           // if(oldMap.get(cap.Id).CLQ_Reviewer_Comments__c != cap.CLQ_Reviewer_Comments__c.left(oldMap.get(cap.Id).CLQ_Reviewer_Comments__c.length)){
             //   cap.addError('You are not authorized to remove the old comment from Reviewers comment section. Please continue to append the new comments');
            //}
            
        }//end for
    }//end method
    //15686 end
}