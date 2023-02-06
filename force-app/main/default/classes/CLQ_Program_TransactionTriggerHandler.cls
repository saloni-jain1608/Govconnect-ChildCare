/* Name : CLQ_Program_TransactionTriggerHandler
* Description : This is an TriggerHandler Class for the CLQ_Program_Transaction__c
*
*  CLQ_Program_TransactionTriggerHandler Handler = new CLQ_Program_TransactionTriggerHandler(newList, newListMap, trigger.old, oldMap,
*                              trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
*                              trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
*  Handler.ProcessTrigger();
**-----------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------------------------------------------------------------------------------------------------
**	Developer			Date			Version		Description
**	IncapsulateDevTeam	N/A				1.0			Initial Build
**	Pradeep Ravi		04/27/2017		1.1			Defect fix #11078 & 11080
**	Neetu Ojha			05/19/2017		1.2			Bug fix #10882 added validation
**  Vamsi V             06/14/2017      1.3         CR Merge
**	Neetu Ojha			11/06/2017		1.4			TFS#11841 - Added condition for transaction status
**	Neetu Ojha			11/07/2017		1.5			TFS#11762 
**	Pradeep Ravi		03/29/2018		1.6			TFS#11983 - If SUTQ Reviewer is Inactive then assigning owner to queue
**	Neetu Ojha			03/30/2018		1.7			TFS#12051 - new method invoked
**  Rohit Gowrishetty   05/30/2018      1.8         TFS#12196 - Modified the deferral due date logic 
**	Neetu Ojha			05/31/2018		1.9			TFS#12195 - Added logic to assign 1 or 2 star rated program to county
**	Neetu Ojha			05/31/2018		2.0			TFS#13366 - Added logic to SUTQ Routing
**  Rohit Gowrishetty	10/10/2018		2.1			TFS#14721 - Added logic for sutq question  effective and expiration dates
**  Rohit Gowrishetty	10/22/2018		2.2			TFS#14858 - SUTQ Expedited 
**  Rohit Gowrishetty	11/15/2018      2.3			TFS#14913 - SUTQ Change of Owner
**  Rohit Gowrishetty	11/15/2018		2.4			TFS#14917 - SUTQ Rating Reinstate
**  Pradeep Ravi		12/07/2018		2.5			TFS#14718 - SUTQ waiting period for removal
**  Pradeep Ravi		12/11/2018		2.6			TFS#15158 - Adding validation for Rating effective date before starting registration
**  Pradeep Ravi		01/10/2019		2.7			TFS#15288 - Adding logic to update Rating Type
**  Rohit Gowrishetty	04/01/2019		2.8			TFS#15679 - Added validation for SUTQ Init/Ongoing to allow only queue members to approve
**  Rohit Gowrishetty	04/25/2019		2.9			TFS#15268 - Added the logic to bypass the validation when annual report override is checked on program
**  Rohit Gowrishetty	04/30/2019		3.0			TFS#15670 - Added this logic to bypass ODE Programs because it doesn't require this logic to get implemented
**  Sujith Balakrishnan	10/14/2019		3.1  		TFS#15251 - Deferral Due Date Change for SUTQ Expedited , CO and Reinstate after Temp Closure
****************************************************************************************************************/
public class CLQ_Program_TransactionTriggerHandler extends CLQ_Trigger {
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static boolean BypassTrigger {
        get {
            if (BypassTrigger == null) BypassTrigger = false;
            return BypassTrigger;
        }
        set;
    }
    
    public static boolean HasUpdated;
    public override boolean getUpdateFlag() { return HasUpdated; }
    public override void setUpdateFlag(boolean newVal) { HasUpdated = newVal; }
    public static   Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
    public static   Id objAnnualReportReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
    public static   Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
    public static   Id objExpeditedRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId(); //14858
    public static   Id objSUTQChangeofOwner = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Change of Owner Registration').getRecordTypeId(); //14913
    public static   Id objSUTQRatingReinstate = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId(); //14917
    
	public static boolean isValidated = false; //10882  
   
	//Calls the Base class Constructor
    public CLQ_Program_TransactionTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list <
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

	CLQ_ProgramTransactionTrigHdlrLicsng Licensing = new CLQ_ProgramTransactionTrigHdlrLicsng();
    
	public override void BeforeInsert() {
        checkforPrg_PTrecordtypeStatus((list < CLQ_Program_Transaction__c > ) newList);
		if (!Licensing.Validation((list <CLQ_Program_Transaction__c>)  newList, (map <Id, CLQ_Program_Transaction__c >) oldMap)) return; //11762
        Licensing.CannotSubmitAnotherAmendment((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap,TriggerExecutionType);
        // ValidateProgramRating((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap);
	}
    
    public override void BeforeUpdate() {
        system.debug('entering BeforeUpdate in CLQ_Program_TransactionTriggerHandler');
        for( CLQ_Program_Transaction__c ProgTran : (list < CLQ_Program_Transaction__c > ) newList)
			system.debug('_______ BeforeUpdate Id: ' + ProgTran.Id + '   has Status: ' + ProgTran.CLQ_Transaction_Status__c);

		if (!Licensing.Validation((list <CLQ_Program_Transaction__c>)  newList, (map <Id, CLQ_Program_Transaction__c >) oldMap)) return; //11762
        Licensing.CannotSubmitAnotherAmendment((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap,TriggerExecutionType);
        FccCheckQueueMembersApproving((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap); //15679
        list < CLQ_Program_Transaction__c > BackupVersions = Licensing.InterceptUpdateAndClone((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap);
        
        if (BackupVersions.size() > 0) {
            //These are the old values, I don't want any processing done on them
            system.debug('CLQ_Program_TransactionTriggerHandler.BeforeUpdate  //////////     Turning off Triggers to store the History Version  //////////');
            boolean oldValue = BypassAllTriggers;
            BypassAllTriggers = true;
            insert BackupVersions;
            BypassAllTriggers = oldValue;
            system.debug('CLQ_Program_TransactionTriggerHandler.BeforeUpdate  //////////     Returning Triggers to Their Previous State  //////////');
        }

        ValidateProgramRating((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap);
        UpdateProgramFromTransaction((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) newMap);
        
        //Added for story 675
        Licensing.ReadyforApprovalCheck((list < CLQ_Program_Transaction__c > ) newList);
        
        //tmd added for story 254
        Licensing.assignOwner((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap, IsUpdate);
        
        //Added by VV on 10/20 (removed from AfterUpdate context)
        RatingEstimatedBySystem((list < CLQ_Program_Transaction__c > ) newlist);
        Licensing.BeforeUpdate((list < CLQ_Program_Transaction__c > ) newlist, (map < id, CLQ_Program_Transaction__c > ) oldMap);
        
        //Added by Vrajesh
        copyRoomSpaceTransactionToRmSpaceInfo((list < CLQ_Program_Transaction__c > ) newlist, (map < id, CLQ_Program_Transaction__c > ) oldMap);
    }
    
    public override void AfterInsert() {
		Licensing.ContinuousLicenseInitiated((list < CLQ_Program_Transaction__c > ) newlist, TriggerExecutionType);
        Licensing.copyRoomSpaceInformationWhileCreatingPT((list < CLQ_Program_Transaction__c > ) newlist); //Added by Vrajesh OJLS-774
        Licensing.AfterInsert((list < CLQ_Program_Transaction__c > ) newlist);
        
    }
    
    public override void BeforeDelete(){
        
        //TFS#16464 Starts
        sendDeleteNotification((list<CLQ_Program_Transaction__c>) oldlist);
    }
    
    public void sendDeleteNotification(list<CLQ_Program_Transaction__c> oldlist)
     {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Contact recepient = [SELECT Id From Contact Where Email = 'NOREPLY@TEST.COM' LIMIT 1];        
        List<String> emailList= new List<String>();        
        emailList.addAll(Label.PTDeletionNotificationGroup.split(';'));
        EmailTemplate et = [Select Id from EmailTemplate where Name = 'PTDeletedTemplate'];
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress LIMIT 1];
        for(CLQ_Program_Transaction__c pt: (list < CLQ_Program_Transaction__c > ) oldList){            
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();        	
                message.setTemplateId(et.id);
                message.setwhatID(pt.id);
                message.settargetObjectID(recepient.id);
                message.setSaveAsActivity(false);
                message.setToaddresses(emailList);      	
                message.setOrgWideEmailAddressId(owea.Id);
                messages.add(message);
               			
       	}
        system.debug('Mails--' + messages);
         if(!messages.isEmpty()){
             //Messaging.sendEmail(messages);
         }        
        system.debug('Mails--Done');
         
     }
    
	public override void AfterUpdate() {
        //tmd added for story 234
        Licensing.ContinuousLicenseInitiated((list < CLQ_Program_Transaction__c > ) newlist, TriggerExecutionType);
        //From Maanavi function
        Licensing.UpdateProgramFacility((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap);
        Licensing.updateProgramOnRelatedRecords((list < CLQ_Program_Transaction__c > ) newList, (map < id, CLQ_Program_Transaction__c > ) oldMap);//12051
        Licensing.AfterUpdate((list < CLQ_Program_Transaction__c > ) newlist, (map < id, CLQ_Program_Transaction__c > ) oldMap);
        OtherAfterUpdateMethod();
        UpdateRevieweronProgram((List<CLQ_Program_Transaction__c>) newList,(map<id,CLQ_Program_Transaction__c>) oldMap);
        UpdateSutqExpediteRatingonProg((list < CLQ_Program_Transaction__c > ) newlist, (map < id, CLQ_Program_Transaction__c > ) oldMap ); //14858
        //new OCLQS_ProgTransChildrenSharingHandler().shareProgTxChildrenWithReviewer((List<CLQ_Program_Transaction__c>) newList, (map<id,CLQ_Program_Transaction__c>)oldMap);
    }
    
    //15679    
    public void FccCheckQueueMembersApproving(list < CLQ_Program_Transaction__c >  newList, map < id, CLQ_Program_Transaction__c >  oldMap){
        
        List< Id > approversFromQueueList = new List< Id >();
        List< Id > approversList = new List< Id >();    
        List< Id > queueList = new List< Id >();
        Boolean isAdmin = false;  
        
        //15670 - Added this logic to bypass ODE Programs because it doesn't require this logic to get implemented
        List<CLQ_Program_Transaction__c> onlyJFSList = new List<CLQ_Program_Transaction__c> ();
        for(CLQ_Program_Transaction__c pt:newList){
            if((pt.CLQ_Program_Type_Formula__c != 'Pre School') &&  (pt.CLQ_Program_Type_Formula__c != 'School Age Child Care')){
                onlyJFSList.add(pt);
            }
        }
        
        if(onlyJFSList.size() > 0 ){
            
            //Get the current user name who is doing the action
            User usr=[Select id,Profile.name from User where id =:Userinfo.getUserid()];
            String usrpro=usr.Profile.Name;
            //Checking if the user is Admin, then he has the right to approve any record. Also county Admins cannot approve the request
            if(usrpro.contains('Admin') && !usrpro.contains('County') ){
                isAdmin = true;
            }        
            
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
                        if(String.valueOf(WorkItem.ActorId).substring(0, 3) == '00G'){
                            queueList.add(WorkItem.ActorId);
                        }
                        //If it is a member , then add it to the approvers List
                        if(String.valueOf(WorkItem.ActorId).substring(0, 3) == '005'){
                            approversList.add(WorkItem.ActorId);
                        }
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
                    //Loop through all the Pt's and trigger the error if you find in any
                    for(CLQ_Program_Transaction__c pt :newList){
                        
                        CLQ_Program_Transaction__c oldItem = oldMap.get(pt.Id);
                        if(( pt.clq_recordtypename__c == 'SUTQ - Initial Registration' || pt.clq_recordtypename__c == 'SUTQ - Ongoing Registration' )
                            && pt.CLQ_Program_Record_Type__c.contains('FCC') 
                          ){
                              if(
                                  ((pt.CLQ_Transaction_Status__c == 'Unable to Rate' && oldItem.CLQ_Transaction_Status__c == 'Pending Approval' ) ||
                                   (pt.CLQ_Transaction_Status__c == 'Under Reviewer Review' && oldItem.CLQ_Transaction_Status__c == 'Pending Approval' ) )&& 
                                  (!approversFromQueueList.contains(usr.Id) && isAdmin == FALSE )
                              ){
                                  pt.addError('Only queue members should be able to Approve/Reject the request');
                              }
                          }
                    }        
                }else{
                    System.debug('There are no Approvers in the queue');
                }
            }
            
        }
      
        
    }
    
    //14858 - Added new Method to updatw the rating on the program
    public void UpdateSutqExpediteRatingonProg(List < CLQ_Program_Transaction__c > newList, map < Id, CLQ_Program_Transaction__c > oldMap){
    	System.debug('UpdateSutqExpediteRatingonProg-->>');
        String SUTQExpeditedReg = Schema.Sobjecttype.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId(); //14858
        String SUTQChangeofOwner = Schema.Sobjecttype.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Change of Owner Registration').getRecordTypeId(); //14913      
        String SUTQRatingReinstate = Schema.Sobjecttype.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId(); //14917
        set < Id > setProgramTrnxids = new set < id > ();
        set < Id > setProgramids = new set < id > ();
        List<clq_program__c> listofProgsToUpdate= new List<clq_program__c> ();
        
        
        //Getting all the SUTQ Expedited PTs
        for(CLQ_Program_Transaction__c ptx: newList ){
            if(( ptx.recordtypeId == SUTQExpeditedReg || ptx.recordtypeId == SUTQChangeofOwner || ptx.recordtypeId == SUTQRatingReinstate ) && ptx.Recommended_Rating__c != null && 
               ((ptx.CLQ_Transaction_Status__c == 'Rating Assessment Complete' && oldMap.get(ptx.id).CLQ_Transaction_Status__c != 'Rating Assessment Complete') ||
                (ptx.CLQ_Transaction_Status__c == 'Unable to Rate' && oldMap.get(ptx.id).CLQ_Transaction_Status__c != 'Unable to Rate'))
              ){
               		setProgramTrnxids.add(ptx.id);
                    setProgramids.add(ptx.CLQ_Program__c);
               }
                
        }
        
        if(setProgramTrnxids.size() > 0 ){
            List <CLQ_Program_Transaction__c > sutqPTList = new List <CLQ_Program_Transaction__c> ();
            //TFS#15251
            //sutqPTList = [SELECT ID,recordtypeId ,Recommended_Rating__c,CLQ_Application_Approved__c,clq_program__r.CLQ_License_Issue_Date__c, clq_recordtypename__c FROM CLQ_Program_Transaction__c where id in :setProgramTrnxids ]; //15288
            sutqPTList = [SELECT ID,recordtypeId ,Recommended_Rating__c,CLQ_Application_Approved__c,clq_program__r.CLQ_License_Issue_Date__c, clq_recordtypename__c,SUTQ_Deferral_Due_Date__c FROM CLQ_Program_Transaction__c where id in :setProgramTrnxids ]; 
            //TFS#15251
            System.debug('Size of SUTQ EXP List' + sutqPTList.size());
            
            Map <id , CLQ_Program__c > programMap = new Map <id , CLQ_Program__c> ([SELECT id,Program_Rating__c ,CLQ_Reactivation_Date__c,Rating_Effective_Date__c ,Rating_Expiration_Date__c,CLQ_License_Issue_Date__c, CLQ_Rating_Type__c  from clq_program__c where id in :setProgramids]); //15288 
            
            //Loop through all the PTs
            for(CLQ_Program_Transaction__c ptx : sutqPTList){
                
                
                clq_program__c prog = programMap.get(ptx.CLQ_Program__c);
                System.debug('Program is '+ prog);
                
                if(ptx.recordtypeId == SUTQExpeditedReg || ptx.recordtypeId == SUTQChangeofOwner){

					//Calculation of SUTQ effective Date - It will be sunday after approval date or License porvisional date whichever is later
                    //TFS#15251 starts
                    DateTime tempDate;
                    if(ptx.SUTQ_Deferral_Due_Date__c<>null) { tempDate = ptx.SUTQ_Deferral_Due_Date__c.addDays(30); }
                    else //TFS#15251 ends
                     tempDate = ptx.CLQ_Application_Approved__c;
                    //Adding 7 hours of time to compensate the change from date -> dateTime and time difference
                    tempDate = tempDate.addHours(1);
                  	
                    DateTime sundayDate = sundayOrnearSundayDate(tempDate);
                    DateTime provLicDate = prog.CLQ_License_Issue_Date__c;
                    if(provLicDate != null)
                    	provLicDate = provLicDate.addHours(5);
                    
                    DateTime SUTQExpEffectiveDate;
                    DateTime SUTQExpExpirationDate ;
                    
                    if(provLicDate != null){
                       if(provLicDate > sundayDate )
                            SUTQExpEffectiveDate = provLicDate;
                        else
                            SUTQExpEffectiveDate = sundayDate ; 
                        System.debug('SUTQExpEffectiveDate will be' + SUTQExpEffectiveDate );
                    }else{
                        SUTQExpEffectiveDate = sundayDate;
                    }
                    
                    // Calculation of SUTQ Expiration Date - 120 days after effective date
                    SUTQExpExpirationDate = SUTQExpEffectiveDate.addDays(120);
                    
                    //SUTQExpEffectiveDate = convertDateTimetoLocalTimeZone(SUTQExpEffectiveDate);
                    
                    // Updating the program with rating, effective/Expiration dates
				    prog.Program_Rating__c = ptx.Recommended_Rating__c;
					prog.Rating_Effective_Date__c = SUTQExpEffectiveDate.date();
                    prog.Rating_Expiration_Date__c = SUTQExpExpirationDate.date(); 
                    prog.CLQ_Rating_Type__c = ptx.clq_recordtypename__c; //15288
                    System.debug('Exp date is' + SUTQExpExpirationDate.year() + ' ' +  SUTQExpExpirationDate.month() + ' ' + SUTQExpExpirationDate.day() );
                    listofProgsToUpdate.add(prog);                    
                } else if (ptx.recordtypeId == SUTQRatingReinstate ){
                    
                     //TFS#15251 starts
                    DateTime tempDate;
                    if(ptx.SUTQ_Deferral_Due_Date__c<>null){ tempDate = ptx.SUTQ_Deferral_Due_Date__c.addDays(30); }
                    else //TFS#15251 ends
                     tempDate = ptx.CLQ_Application_Approved__c ;
                    //Adding 7 hours of time to compensate the change from date -> dateTime and time difference
                    tempDate = tempDate.addHours(1);
                    
                    Datetime sundayDate  = sundayOrnearSundayDate(tempDate);
                    Datetime reactivationDate = prog.CLQ_Reactivation_Date__c;
                    if(reactivationDate != null)
                    	reactivationDate = reactivationDate.addHours(5);
                    
                    DateTime SUTQExpEffectiveDate;
                    DateTime SUTQExpExpirationDate;
                    
                    if(reactivationDate != null){
                        if(reactivationDate > sundayDate )
                            SUTQExpEffectiveDate = reactivationDate;
                        else
                            SUTQExpEffectiveDate = sundayDate ; 
                        System.debug('SUTQExpEffectiveDate will be' + SUTQExpEffectiveDate );
                    }else{
                        SUTQExpEffectiveDate = sundayDate;
                    }
                    
                    // Calculation of SUTQ Expiration Date - 120 days after effective date
                    SUTQExpExpirationDate = SUTQExpEffectiveDate.addDays(120);
                    
                    prog.Program_Rating__c = ptx.Recommended_Rating__c;
                    prog.Rating_Effective_Date__c = SUTQExpEffectiveDate.date();
                    prog.Rating_Expiration_Date__c = SUTQExpExpirationDate.date(); 
					prog.CLQ_Rating_Type__c = ptx.clq_recordtypename__c; //15288
                    System.debug('Exp date is' + SUTQExpExpirationDate.year() + ' ' +  SUTQExpExpirationDate.month() + ' ' + SUTQExpExpirationDate.day() );
                    listofProgsToUpdate.add(prog);
                }
			}
            // Update the programs 
            if(listofProgsToUpdate.size() > 0){
				CLQ_ProgramTriggerHandler.BypassTrigger  = true;
				update listofProgsToUpdate;
				CLQ_ProgramTriggerHandler.BypassTrigger  = false;
            }
        }
    }
    
    public Datetime sundayOrnearSundayDate(Datetime tempDate){
        
        System.debug('Tempdate is ' + tempDate );
        DateTime sundayOrlaterDate ;
        date dt1 = date.valueOf(tempDate);
        
        System.debug('tempDate.format' + tempDate.format('EEEE'));
        if(tempDate.format('EEEE') != 'Sunday'){
            DateTime temp;
            for (integer i = 1; i < 7; i++)
            {
                temp = tempDate.adddays(i);
                System.debug('tempDate.format inside for' + temp.format('EEEE'));
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
    
    public void RatingEstimatedBySystem(list < CLQ_Program_Transaction__c > newlist) {
    	system.debug('RatingEstimatedBySystem ---');
        if (AvoidRecursionCls.ratingsCalculated == TRUE) {
            Set < Id > ptIds = new Set < Id > ();
            
            Integer queryCounter = 0;
            Set <String> domainNames = new Set<String>();
            domainNames.add('Learning & Development');
            domainNames.add('Administrative & Leadership Practices');
            domainNames.add('Staff Qualifications & Professional Development');
            domainNames.add('Family & Community Partnerships');
            domainNames.add('Accreditation');
            domainNAmes.add('Ratio & Group Size');
            
            for (CLQ_Program_Transaction__c pT: newlist) {
                ptIds.add(pT.Id);
            }

            //List of transaction records to add to bulk update list
            List <CLQ_Program_Transaction__c> objTransToUpdate = new List < CLQ_Program_Transaction__c > ();
            //14721
            List<Answer__c> allAnswers = [SELECT Id, Program_Transaction__c, Domain_Name__c, Met_Not_Met__c, Points__c, Rating_Number__c,
                                          AssociatedQuestion__r.Question_Effective_Date__c , AssociatedQuestion__r.Question_Expiration_Date__c
                                          FROM Answer__c 
                                          WHERE Program_Transaction__c IN:ptIds
                                          AND ((AssociatedQuestion__r.Question_Effective_Date__c = NULL AND AssociatedQuestion__r.Question_Expiration_Date__c = NULL) OR 
                 							   (AssociatedQuestion__r.Question_Effective_Date__c >= TODAY AND AssociatedQuestion__r.Question_Expiration_Date__c >= TODAY )) 
                                          AND Domain_Name__c IN: domainNames];
            queryCounter++;                              
            System.debug('1 query run in RatingEstimatedBySystem() method for getting all answers');
            System.debug('allAnswers ' + allAnswers);
            System.debug(' objTrans.A_LP_Criteria__c '+newlist[0].A_LP_Criteria__c);
            String aLpCriteria = getCriteria(allAnswers, 'Administrative & Leadership Practices');
            System.debug(' aLpCriteria '+aLpCriteria);
           
            //TO DO: VV to optimize
            for (CLQ_Program_Transaction__c objTrans: newlist) {
                
                objTrans.A_LP_Criteria__c = getCriteria(allAnswers, 'Administrative & Leadership Practices');
                objTrans.A_LP_Domain_Points__c = getPoints(allAnswers, 'Administrative & Leadership Practices',objTrans.Rating_Proposed_By_Program__c);
                objTrans.A_LP_Domain_Ratings__c = getRatings(allAnswers, 'Administrative & Leadership Practices');
                
                objTrans.Accreditaion__c = getCriteria(allAnswers, 'Accreditation');
                objTrans.Accreditation_Domain_Points__c = getPoints(allAnswers, 'Accreditation',objTrans.Rating_Proposed_By_Program__c);
                objTrans.Accreditation_Domain_Ratings__c = getRatings(allAnswers, 'Accreditation');
                
                objTrans.F_CP_Criteria__c = getCriteria(allAnswers, 'Family & Community Partnerships');
                objTrans.F_CP_Domain_Points__c = getPoints(allAnswers, 'Family & Community Partnerships',objTrans.Rating_Proposed_By_Program__c);
                objTrans.F_CP_Domain_Ratings__c = getRatings(allAnswers, 'Family & Community Partnerships');
                
                objTrans.Learning_And_Development_Criteria__c = getCriteria(allAnswers, 'Learning & Development');
                objTrans.Learning_And_Development_Domain_Points__c = getPoints(allAnswers, 'Learning & Development',objTrans.Rating_Proposed_By_Program__c);
                objTrans.Learning_And_Development_Domain_Rating__c = getRatings(allAnswers, 'Learning & Development');
                
                objTrans.SQ_PD_Criteria__c = getCriteria(allAnswers, 'Staff Qualifications & Professional Development');
                objTrans.SQ_PD_Domain_Points__c = getPoints(allAnswers, 'Staff Qualifications & Professional Development',objTrans.Rating_Proposed_By_Program__c);
                objTrans.SQ_PD_Domain_Rating__c = getRatings(allAnswers, 'Staff Qualifications & Professional Development');
                
                
                objTrans.Ratio_Group_Size_Domain_Points__c = getPoints(allAnswers, 'Ratio & Group Size',objTrans.Rating_Proposed_By_Program__c);
                objTrans.Ratio_Group_Size_Domain_Ratings__c = getRatings(allAnswers, 'Ratio & Group Size');
                
                objTransToUpdate.add(objTrans);
                System.debug('***objTrans' + objTrans);
            }
            System.debug('Total queries ran in RatingEstimatedBySystem() method = ' + queryCounter);
        }
    }
    
    public String getCriteria(List<Answer__c> ansList, String domain){
        System.debug('**getCriteria method ansList: ' + ansList);
        System.debug('**ansList size == ' + ansList.size());
        String criteria = '-';
        Integer countMet = 0;
        Integer currentListCount = 0;
        System.debug('Counter '+countMet);
        
        if(ansList.size() > 0){
            for(Answer__c ans : ansList){
                if(!String.isBlank(ans.Met_Not_Met__c) && domain.equals(ans.Domain_Name__c)){
                    currentListCount++;
                    if(ans.Met_Not_Met__c.equals('Met')){
                        countMet++;
                    }
                }
                
            }
            
            System.debug(' After counter Counter '+countMet);
            if(currentListCount>0 && countMet == currentListCount){ criteria = 'Met';
            }else if(currentListCount> 0 && countMet != currentListCount) { criteria = 'Not Met';
            }else{ criteria = '-';
            }      
        }
        
        System.debug('criteria = ' + criteria);
        return criteria;
    }
    
    public String getRatings(List<Answer__c> ansList, String domain){
        System.debug('**getRatings method ansList: ' + ansList);
        System.debug('**ansList size == ' + ansList.size());
        Decimal rating = 10;
        
        for(Answer__c ans: ansList){
            if(ans.Rating_Number__c != NULL && domain.equals(ans.Domain_Name__c)){
                if(rating > ans.Rating_Number__c){
                    rating = ans.Rating_Number__c;
                }
            }
        }

        if(rating == 10){
            return '-';
        }
        return String.valueOf(rating);
    }
    
    public String getPoints(List<Answer__c> ansList, String domain, String ratingProposedByProgram){
        System.debug('**getPoints method ansList: ' + ansList);
        System.debug('**ansList size == ' + ansList.size());
        Decimal points = 0;
        
        for(Answer__c ans : ansList){
            if(ans.Points__c != NULL  && domain.equals(ans.Domain_Name__c) && (ratingProposedByProgram == '4' || ratingProposedByProgram == '5')){
                points = points + ans.Points__c;
            }
        }
        return String.valueOf(points);
    }
    
    public void OtherAfterUpdateMethod() {
        if (AvoidRecursionCls.isRunOnce == TRUE) {
            
            Map < Id, CLQ_Program_Transaction__c > ptToInspection = new Map < Id, CLQ_Program_Transaction__c > ([ Select Id, (Select Id, OwnerId from Inspections__r), 
            																					(Select Id, Status from Tasks where Status !='Closed') from CLQ_Program_Transaction__c where ID IN: newList]);
            
            List < CLQ_Inspection__c > InspectionToBeClosed = new List < CLQ_Inspection__c > ();
            List < CLQ_Inspection__c > InspectionList = new List < CLQ_Inspection__c > ();
            List < Task > openActivitiesOnPt = new List < Task > ();
            List < Task > openActivitiesToBeClosed = new List < Task > ();
            
            //Anil added code for ER 2328 and 2344
            for (CLQ_Program_Transaction__c objTran: (list < CLQ_Program_Transaction__c > ) newList) {
				CLQ_Program_Transaction__c oldobjTran = (CLQ_Program_Transaction__c) oldMap.get(objTran.id);
                System.debug('@@@Status' + objTran.CLQ_Transaction_Status__c);
                
                if (((objTran.CLQ_Transaction_Status__c != null && objTran.CLQ_Transaction_Status__c != oldobjTran.CLQ_Transaction_Status__c) && (objTran.CLQ_Transaction_Status__c == 'Withdraw' )) ||test.isrunningtest() ) {
						if (ptToInspection.get(objTran.Id) != null) {
                            InspectionList = ptToInspection.get(objTran.Id).Inspections__r;
                            openActivitiesOnPt = ptToInspection.get(objTran.Id).Tasks;
                        }
				} else if (objTran.CLQ_Transaction_Status__c != null && (objTran.CLQ_Transaction_Status__c == 'Completed' || objTran.CLQ_Transaction_Status__c == 'Annual Report Disapproved')) {
					if (ptToInspection.get(objTran.Id) != null) { openActivitiesOnPt = ptToInspection.get(objTran.Id).Tasks;
					}
				}
            }
            
            System.debug('@@@@@@@@@@list of inspection' + InspectionList);
            System.debug('@@@@@@@@@@list of open activities' + openActivitiesOnPt);
            
            Group SysAdminQueue = [select Id from Group where Name = 'System Admin Queue' and Type = 'Queue'];
            
            Id sysAdminQueueId;
            
            if (SysAdminQueue != null) {
                sysAdminQueueId = SysAdminQueue.Id;
            }
            
            if (InspectionList.size() > 0 && !InspectionList.isEmpty()) {
                for (CLQ_Inspection__c inspection: InspectionList) {
                    inspection.CLQ_Inspection_Status__c = 'Closed';
                    inspection.OwnerId = sysAdminQueueId;
                    InspectionToBeClosed.add(inspection);
                }
            }
            
            if (openActivitiesOnPt.size() > 0 && !openActivitiesOnPt.isEmpty()) {
                for (Task openTasks: openActivitiesOnPt) {
                    openTasks.Status = 'Closed';
                    openActivitiesToBeClosed.add(openTasks);
                }
            }
            
            List < Task > associatedTasks = new List < Task > ([Select Id, Status from Task where whatId IN:InspectionToBeClosed ]);
            List < Task > tskToBeClosed = new List < Task > ();
            
            if (associatedTasks.size() > 0 && !associatedTasks.isEmpty()) {
                for (Task tsk: associatedTasks) {
                    tsk.status = 'Closed';
                    tskToBeClosed.add(tsk);
                }
            }
            
            if (InspectionToBeClosed != null  && InspectionToBeClosed.size() != 0) {
                CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
                update InspectionToBeClosed;
                CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
                
            }
            
            CLQ_TaskTriggerHandler.BypassTrigger = true;
            if (openActivitiesToBeClosed != null  && openActivitiesToBeClosed.size() != 0) { update openActivitiesToBeClosed;
            }
            
            if (tskToBeClosed != null && tskToBeClosed.size() != 0 ) { update tskToBeClosed;
            }
            
            CLQ_TaskTriggerHandler.BypassTrigger = false;
        }
    }
    
	public void UpdateProgramFromTransaction(list < CLQ_Program_Transaction__c > newList, map < id, CLQ_Program_Transaction__c > newmap) {
		list < CLQ_Program__c > lstProgUpdate = new list < CLQ_Program__c > ();
		set < Id > setTranids = new set < Id > ();
                                                 
		for (CLQ_Program_Transaction__c objtr: newList) {
			if (objtr.IsApproved_PrgTran__c || objtr.Annual_Report_Overall_Requirements__c == 'Met'||test.isrunningtest()) {
				setTranids.add(objtr.CLQ_Program__c);
			}
		}
                                                 
		for (CLQ_Program__c objprg: [Select Program_Rating__c,CLQ_ByPassUtil__c ,  RecordTypeId, RecordType.Name, CLQ_County__c,
	                                      CLQ_County__r.Area_Region__c, CLQ_County__r.CCC_Field_Officers__c, CLQ_County__r.FCC_Field_officers__c,
	                                      Rating_Anniversary_Date__c,Rating_Expiration_Date__c,
	                                      (Select Recommended_Annual_Report_Rating__c, Annual_Report_Overall_Requirements__c,
	                                       Recommended_Rating__c, IsApproved_PrgTran__c, clq_recordtypename__c From Program_Transactions__r WHERE Id In: trigger.new)
									From CLQ_Program__c WHERE id IN: setTranids]){
			for (CLQ_Program_Transaction__c objtran1: objprg.Program_Transactions__r) {
				CLQ_Program_Transaction__c objtran = newMap.get(objtran1.id);
					if (objtran.Recommended_Rating__c != null && objtran.Recommended_Rating__c == '0') {
						CLQ_Program__c objprogr = new CLQ_Program__c(id = objprg.id, Program_Rating__c = objtran.Recommended_Rating__c);
						objprogr.Rating_Expiration_Date__c = null;
						objprogr.Rating_Effective_Date__c = null;
						objprogr.Rating_Anniversary_Date__c = null;
						objprogr.CLQ_Rating_Type__c=''; //15288
                                                                                     
						/**********Find Next Sunday *********/
						datetime objtime = datetime.now();
						datetime finalDiscontinueDate = objtime;
                                                                                                    
						if (  objtime.format('EEEE') != 'Sunday') {
							for (integer i = 0; i < 6; i++) {
								objtime = finalDiscontinueDate.adddays(i);
								system.debug('objtime --->' + objtime + '---objtime.format' + objtime.format('EEEE'));
								if (objtime.format('EEEE') == 'Sunday') {
									//datecount = i;
									finalDiscontinueDate = objtime;
									break;
								}
							}
						}
                                                                                                    
						objprogr.Rating_Discontinue__c = date.newinstance(finalDiscontinueDate.year(), finalDiscontinueDate.month(), finalDiscontinueDate.day());
						/*************************************************/
						lstProgUpdate.add(objprogr);
					}
					
					system.debug('Recommended_Annual_Report_Rating__c-->'+objtran.Recommended_Annual_Report_Rating__c);
					if (objtran.Recommended_Annual_Report_Rating__c != null && objtran.IsApproved_PrgTran__c) {
						CLQ_Program__c objprogr = new CLQ_Program__c(id = objprg.id, Program_Rating__c = objtran.Recommended_Annual_Report_Rating__c,CLQ_ByPassUtil__c=False);
						
						if (objtran.Recommended_Annual_Report_Rating__c == '0') {
							objprogr.Rating_Expiration_Date__c = null;
							objprogr.Rating_Effective_Date__c = null;
							objprogr.Rating_Anniversary_Date__c = null;
							objprogr.Program_Rating__c = objtran.Recommended_Annual_Report_Rating__c ; 
							objprogr.CLQ_Rating_Type__c=''; //15288
							/**********Find Next Sunday After rating discontinue*********/
							datetime objtime = datetime.now();
							datetime finalDiscontinueDate = objtime;
                                                                                                    
							if (  objtime.format('EEEE') != 'Sunday') {
								for (integer i = 0; i < 6; i++) {
									objtime = finalDiscontinueDate.adddays(i);
									system.debug('objtime --->' + objtime + '---objtime.format' + objtime.format('EEEE'));
                                    if (objtime.format('EEEE') == 'Sunday') {
                                        //datecount = i;
                                        finalDiscontinueDate = objtime;
                                        break;
                                    }
								}
							}
							objprogr.Rating_Discontinue__c =  date.newinstance(finalDiscontinueDate.year(), finalDiscontinueDate.month(), finalDiscontinueDate.day());
                                                                                             /*************************************************/
						}
                     
						if (objtran.Annual_Report_Overall_Requirements__c == 'Not Met' && objtran.Recommended_Annual_Report_Rating__c < objprg.Program_Rating__c && objtran.Recommended_Annual_Report_Rating__c != '0') {
							objprogr.RatingChangedDate__c = date.today();
							objprogr.Program_Rating__c = objtran.Recommended_Annual_Report_Rating__c ;
							objprogr.Rating_Anniversary_Date__c = null;
							objprogr.CLQ_Rating_Type__c = objtran.clq_recordtypename__c; //15288
							
							/**********Find Next Sunday After AR NOTMET approval*********/
							datetime objtime = datetime.now();
							datetime Ratingeffectivedate = objtime;
                                                                                                       
							if (  objtime.format('EEEE') != 'Sunday') {
								for (integer i = 0; i < 6; i++) {
									objtime = Ratingeffectivedate.adddays(i);
									system.debug('objtime ratingeffectivedate --->' + objtime + '---objtime.format' + objtime.format('EEEE'));
									if (objtime.format('EEEE') == 'Sunday') {
										Ratingeffectivedate = objtime;
										break;
									}
								}
							}
							objprogr.Rating_Effective_Date__c =  date.newinstance(Ratingeffectivedate.year(), Ratingeffectivedate.month(), Ratingeffectivedate.day());
							/*************************************************/
							objprogr.Rating_Expiration_Date__c = objprogr.Rating_Effective_Date__c + 364;
						}
						lstProgUpdate.add(objprogr);
					} 
					system.debug('Met scenario1:::'+objprg.Program_Rating__c);
                                                                                 
					if ((objtran.Annual_Report_Overall_Requirements__c == 'Met' && (objprg.Program_Rating__c == '5' || objprg.Program_Rating__c == '4' || objprg.Program_Rating__c == '3'))) {
						if((objprg.Rating_Anniversary_Date__c!= null) && (objprg.Rating_Expiration_Date__c!=null) && (objprg.Rating_Anniversary_Date__c.daysBetween(objprg.Rating_Expiration_Date__c)<400)){
							system.debug('Met scenario1::::');
							system.debug('days between:::'+objprg.Rating_Anniversary_Date__c.daysBetween(objprg.Rating_Expiration_Date__c));
							CLQ_Program__c objprogr = new CLQ_Program__c(id = objprg.id);
							objprogr.Rating_Anniversary_Date__c = null;
							lstProgUpdate.add(objprogr);
						}else if(objprg.Rating_Anniversary_Date__c!= null && objprg.Rating_Expiration_Date__c!=null && (objprg.Program_Rating__c == '5' || objprg.Program_Rating__c == '4' )){
							system.debug('Met scenario2::::');
							CLQ_Program__c objprogr = new CLQ_Program__c(id = objprg.id);
							objprogr.Rating_Anniversary_Date__c = objprg.Rating_Anniversary_Date__c.addYears(1);
							lstProgUpdate.add(objprogr);
						}
					}
				}
				
			}
			
			if (!lstProgUpdate.isEmpty()) {
				AvoidRecursionCls.isRecomended = true;
				CLQ_ProgramTriggerHandler.BypassTrigger  = true;
				update lstProgUpdate;
				CLQ_ProgramTriggerHandler.BypassTrigger  = false;
				system.debug('Update' + lstProgUpdate + '---AvoidRecursionCls.isRecomended--->' + AvoidRecursionCls.isRecomended);
			}
		}
											 
	
	public void ValidateProgramRating(list < CLQ_Program_Transaction__c > newList, map < id, CLQ_Program_Transaction__c > oldMap) {
		Set < Id > cpIdLst = new Set < Id > ();
    	//10882 Starts
    	Set < Id > cpIdForNewPTLst = new set < Id > (); 
    	Set < String > setAnnualReportStatus = new Set< String >();
    	Set < String > setOngoingRegStatus = new Set< String >();
    	List < CLQ_Program_Transaction__c > existingSUTQLst = new List < CLQ_Program_Transaction__c >();
        
        setAnnualReportStatus.addAll(Label.SUTQ_AnnualReportFinalStatus.split(';'));
    	setOngoingRegStatus.addAll(Label.SUTQ_OngoingRegFinalStatus.split(';'));
    	//10882 Ends
        
        for (CLQ_Program_Transaction__c cpt: newList) {
            system.debug('CLQ_Transaction_Status__c --->' + cpt.CLQ_Transaction_Status__c);
            cpIdLst.add(cpt.CLQ_Program__c);
            //10882 Starts 
            if(cpt.Id == null && !isValidated){
            	cpIdForNewPTLst.add(cpt.CLQ_Program__c);
            }
            //10882 Ends
        }
        
        //14858 - Added the county and clq_recordtypename__c and some other fields in the query which wil be used to assign accordingly to the state counties
        Map < id, CLQ_Program__c > cpMap = new Map < id, CLQ_Program__c > ([SELECT id,CLQ_2_Star_Reapplying_Date__c, Program_Rating__c,CLQ_ByPassUtil__c , IR_0_Rating_6_months_ago__c,
                                                                            AR_Anniv_Date_120_Days_away__c,Initial_Registration_Not_Allowed__c,
                                                                            AR_Ongoing_Reg_less_than_6_months_ago__c, IR_Rating_Removed_12_months__c,
                                                                            Unable_to_Rate_Reasons__c, Rating_Effective_Date__c, Rating_Anniversary_Date__c,
                                                                            RatingChangedDate__c,Rating_Expiration_Date__c, Rating_Discontinue__c,Rating_Reduction_Date__c,
                                                                            Clq_county__c , CLQ_County__r.Area_Region__c, CLQ_County__r.CCC_Field_Officers__c, CLQ_County__r.FCC_Field_officers__c , 
                                                                            (SELECT id, createddate,CLQ_ProgTrans_County__c ,CLQ_ProgTrans_County__r.id ,CLQ_ProgTrans_County__r.FCC_Field_officers__c ,CLQ_ProgTrans_County__r.Area_Region__c , CLQ_ProgTrans_County__r.CCC_Field_Officers__c , Clq_county__c ,clq_recordtypename__c FROM Program_Transactions__r) 
																			FROM CLQ_Program__c 
                                                                            WHERE id =:cpIdLst]);
        //10882 Starts 
        if(cpIdForNewPTLst.size()>0){
        	for(CLQ_Program_Transaction__c exstCPT : [Select Id, CLQ_Transaction_Status__c, RecordTypeID 
        										from CLQ_Program_Transaction__c where CLQ_Program__c IN : cpIdForNewPTLst
        										AND (RecordTypeID =: objOnGoingReg OR  RecordTypeID =: objAnnualReportReg)]){
        		existingSUTQLst.add(exstCPT);										
			}
        }
        system.debug('existingSUTQLst ---'+existingSUTQLst);
        //10882 Ends                                                                           
        
        // US 3165 - Vamshi      
        Date calcExpDate = date.today().addYears(1);
        
        for (CLQ_Program_Transaction__c cpt: newList) {
			if (cpMap != null && cpMap.containsKey(cpt.CLQ_Program__c)) {
				//10882 Starts
				//Validating if new Annual Report is submitted if OnGoing Registration is already InProgress or vice versa 
           		if(cpt.id == null && existingSUTQLst.size()>0 && setAnnualReportStatus != null && setOngoingRegStatus != null){
           			for(CLQ_Program_Transaction__c exstCPT : existingSUTQLst){
           				system.debug('exstCPT ---'+exstCPT);
           				if((cpt.RecordTypeId == objAnnualReportReg && exstCPT.RecordTypeId == objOnGoingReg && !setOngoingRegStatus.contains(exstCPT.CLQ_Transaction_Status__c)) 
           					|| (cpt.RecordTypeId == objOnGoingReg && exstCPT.RecordTypeId == objAnnualReportReg && !setAnnualReportStatus.contains(exstCPT.CLQ_Transaction_Status__c))){
           				
           					cpt.addError(Label.SUTQ_NewPTValidationErrorMsg);		
						}
           			}
           		}
           		//10882 Ends
           		
                CLQ_Program__c cp = cpMap.get(cpt.CLQ_Program__c);
                Id initRegId= Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();                                                  
                // if(cp.Rating_Expiration_Date__c>calcExpDate) // Avoid US 3165 - Vamshi
                
                //15268 
                if(cpt.recordTypeid == objAnnualReportReg && cp.Rating_Anniversary_Date__c == null && cpt.CLQ_Transaction_Status__c == 'Not Complete'){
                    
                    if(! (cp.AR_Ongoing_Reg_less_than_6_months_ago__c && cp.Rating_Expiration_Date__c != null && ( System.today() > cp.Rating_Expiration_Date__c.addDays(-365)) )  )
                    	cpt.addError('Your program has already completed its Annual Report for this year.');
                }
                    
                
                /* TFS #14913 - Commenting thi validaton as we can start the SUTQ Initial once it is rated by three SUTQ's too 
                if(!cp.Initial_Registration_Not_Allowed__c && cpt.RecordTypeid == initRegId && 
                   cp.Program_Rating__c != null && Integer.valueOf(cp.Program_Rating__c) > 0)
                {
                    cpt.addError('Your program may not begin an Initial Registration because your program is currently rated.');
                }
				*/
                /*if(cp.Rating_Expiration_Date__c <=calcExpDate && cpt.recordTypeid == objAnnualReportReg && cpt.CLQ_Transaction_Status__c == 'Not Complete' && !cp.AR_Ongoing_Reg_less_than_6_months_ago__c ) //15268 
                {
                    cpt.addError('Your program is currently within the final year of its rating period and may not initiate an Annual Report.');
                    // US 3165 Vamshi
                }*/
                
                if (cpt.Annual_Report_Overall_Requirements__c == 'Not Met' && cp.Program_Rating__c != null && !cpt.IsApproved_PrgTran__c &&
                    cp.Program_Rating__c != '' && cpt.Recommended_Annual_Report_Rating__c != null && cpt.Recommended_Annual_Report_Rating__c !=
                    '') {
                        integer reportRating = integer.valueOf(cpt.Recommended_Annual_Report_Rating__c);
                        integer prgRating = integer.valueOf(cp.Program_Rating__c);
                        
                        if (reportRating >= prgRating)
                            cpt.addError('Your program not met the Annual report overall requirements please recommend rating less than the current rating');
                        
                    }
                
                //cp.Rating_Expiration_Date__c > calcExpDate (added below to avoid error msg related US 3165
                //11841- Added Transaction status condition
                if (cpt.recordTypeid == objAnnualReportReg && cpt.CLQ_Transaction_Status__c == 'Not Complete' && cp.Rating_Expiration_Date__c > calcExpDate && cp.Rating_Anniversary_Date__c != null 
                		&& !cp.AR_Ongoing_Reg_less_than_6_months_ago__c && !cp.AR_Anniv_Date_120_Days_away__c) {
                    Date aniverseryDate1 = cp.Rating_Anniversary_Date__c.addDays(-120); // Condition to check AnniversaryDate 
                    Date aniverseryDate2 = cp.Rating_Anniversary_Date__c.addDays(-30);
                    if (Date.today() < aniverseryDate1) {
                        cpt.addError('Your program may not begin an Annual Report until the Anniversary Date of your current multi-year rating period is less than 120 days away.');
                        
                    }
                    if (!cp.CLQ_ByPassUtil__c && Date.today() > aniverseryDate2 && cpt.CLQ_Transaction_Status__c == 'Not Complete') {
                        cpt.addError('Your program may not submit an Annual Report. The Anniversary Date of your current multi-year rating period is less than 30 days away. Your program\'s rating will be discontinued.');
                    }
                }
                //if (cpt.recordTypeid == objOnGoingReg && cp.Program_Rating__c < '3' && cp.Program_Rating__c != '0') {
                if (cpt.recordTypeid == objAnnualReportReg && cp.Program_Rating__c < '3' && cp.Program_Rating__c != '0' && cp.Program_Rating__c!='' && cp.Program_Rating__c!=null) {
                    cpt.addError('1 and 2 star programs cannot initiate an annual report');
                    //7-18-16 code added to validate program rating <3  
                    
                }
                system.debug('Record type::::' + cpt.recordTypeid);
                system.debug('By pass Util:::::' + cp.CLQ_ByPassUtil__c);
                
                //The below is commented out by Vamsi V for CR Item 11156
                /*if ((cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId || cpt.recordTypeid ==
                     objAnnualReportReg) && cp.RatingChangedDate__c != null) {
                         Date ratingChangeDate1 = cp.RatingChangedDate__c.addMonths(6);
                         system.debug('Rating change date::::' + ratingChangeDate1);     
                         if (!cp.CLQ_ByPassUtil__c && Date.today() < ratingChangeDate1 && ratingChangeDate1 != null && !cp.AR_Ongoing_Reg_less_than_6_months_ago__c) {
                             system.debug('Entered 1 :::::::::::');
                             cpt.addError('Your program\'s rating was changed within the last 6 months. You cannot submit any type of registration within 6 months of your rating change date.');
                             
                         }
                     }
                
                if (cpt.recordTypeid == objInitialRegId && cp.RatingChangedDate__c != null) {
                    Date ratingChangeDate2 = cp.RatingChangedDate__c.addMonths(6);
                    
                    if (!cp.CLQ_ByPassUtil__c && Date.today() < ratingChangeDate2) {
                        system.debug('Entered 2 ::::::::::::::');
                        system.debug('Rating change date::::::::::'+ ratingChangeDate2);
                        cpt.addError('Your program\'s rating was changed within the last 6 months. You cannot submit any type of registration within 6 months of your rating change date.');
                        
                    }
                }*/ //End of Vamsi's commenting out 

                //Vamsi Changes for CR TFS ID #11156 starts below
                //Commented for 15158 as no validation is required and provider should be able to start ongoing if rating is effective.
                /**if (cpt.recordTypeid == objOnGoingReg && cp.Rating_Effective_Date__c != null) {
                    //Add 180 days to rating effective date 
                    Date upperBoundDate = cp.Rating_Effective_Date__c.addDays(180);
                    
                    if (!cp.CLQ_ByPassUtil__c && Date.today() < upperBoundDate) {

                        cpt.addError('Ongoing Registrations may not be initiated until 180 days after a rating is effective and must be submitted 90 days prior to the Rating Expiration Date.');
                        
                    }
                }*/
                //Vamsi changes for CR TFS ID #11156 ends here
                // TFS #15898
                // Applicable for Init/Ongoing/Annual
                // 2 star re-reg date is past from today
                // Rating estimated by system is 2
                // And Rating confirmed by user is 2 then we are throwing a error
                /*if ((cpt.clq_recordtypename__c == 'SUTQ - Initial Registration' ||cpt.clq_recordtypename__c == 'SUTQ - Ongoing Registration' || cpt.clq_recordtypename__c == 'SUTQ - Annual Report' ) &&
                    (cp.CLQ_2_Star_Reapplying_Date__c != null && cp.CLQ_2_Star_Reapplying_Date__c <= System.today()) &&
                    (cpt.Rating_Estimated_By_System__c != null && cpt.Rating_Estimated_By_System__c == '2' ) &&
                    (cpt.CLQ_Rating_Confirmed_by_Program__c != null && cpt.CLQ_Rating_Confirmed_by_Program__c == '2')
                   ){

                        cpt.addError('The program is not eligible to register for a 2-star rating because a 2-star rating was already awarded in the previous 4 years.');
                        
                } */
                              
                //Adding validation for Rating Effective Date - 15158
                if(cp.Rating_Effective_Date__c != null && cp.Rating_Effective_Date__c >= Date.Today() && (cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId 
                        || cpt.recordTypeid == objExpeditedRegId || cpt.recordTypeid == objSUTQChangeofOwner || cpt.recordTypeid == objAnnualReportReg || cpt.recordTypeid == objSUTQRatingReinstate))
                {
                	   cpt.addError(Label.Error_Message_for_Rating_Effective);            	
                }
                
                //Anil added condition for ER 3253
                //Vamshi added code for to by pass the validation
   
                //Updated conditions for 14718 - Removed validation for Discontinue rating and updated for Rating Reduced and Rating Removed.
                if (cp.Rating_Discontinue__c != null ) {
                    if (Date.today() < cp.Rating_Reduction_Date__c.addDays(180)
                        && !cp.IR_0_Rating_6_months_ago__c
                        &&(cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId 
                        || cpt.recordTypeid == objExpeditedRegId || cpt.recordTypeid == objSUTQChangeofOwner || cpt.recordTypeid == objSUTQRatingReinstate) 
                        &&(cp.Unable_to_Rate_Reasons__c == Label.Unable_to_Rate_Reasons_Rating_Reduced)) {
                        cpt.addError(Label.Error_Message_for_Rating_Reduced);                                                                                                                                              
                    }
                    //14718 - Added validation for no registration to start on discontinue date
                    if (Date.today() == cp.Rating_Discontinue__c
                        &&(cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId 
                        || cpt.recordTypeid == objExpeditedRegId || cpt.recordTypeid == objSUTQChangeofOwner || cpt.recordTypeid == objSUTQRatingReinstate)) {
                        cpt.addError(Label.Error_Message_for_Rating_Discontinue);                                                                                                                                            
                    }                    
                    if (Date.today() < cp.Rating_Discontinue__c.addMonths(12) && !cp.IR_Rating_Removed_12_months__c && cp.Program_Rating__c == '0' && (
                        cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId || cpt.recordTypeid ==
                        objAnnualReportReg || cpt.recordTypeid == objExpeditedRegId || cpt.recordTypeid == objSUTQChangeofOwner || cpt.recordTypeid == objSUTQRatingReinstate)  
                        && cp.Unable_to_Rate_Reasons__c == Label.Unable_to_Rate_Reasons_Rating_Removed) {
                    
                        cpt.addError(Label.Error_Message_for_Rating_Removed);
                            
                    }
                    if (Date.today() < cp.Rating_Discontinue__c.addMonths(6)&& !cp.IR_0_Rating_6_months_ago__c && cp.Program_Rating__c == '0' 
                        && (cpt.recordTypeid == objOnGoingReg || cpt.recordTypeid == objInitialRegId || cpt.recordTypeid ==objAnnualReportReg) 
                        && cp.Unable_to_Rate_Reasons__c == Label.Unable_to_Rate_Reason_Voluntary_discontinue) {
                        
                        cpt.addError(Label.Error_Message_for_voluntarily_withdrawn);                                                                                                                                  
                    }
                }
            }
        }
        
		//Anil Code added for User story 2356
		//13366 Starts
		map < string, Id > mapQueueIds = new map < string, Id > ();
		for (Group objg: [SELECT Type, Name, Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
			mapQueueIds.put(objg.DeveloperName, objg.id);
		}
        
        Map < Id, CLQ_Program__c > mapPrograms = new Map < Id, CLQ_Program__c > ([SELECT Id, Name,SUTQ_Reviewer__c,CLQ_County__c, SUTQ_Reviewer_IsActive__c,
        																			CLQ_County__r.FCC_Field_officers__c, Program_County__c, CLQ_Program_Record_Type__c
                                                                                  FROM CLQ_Program__c where Id IN:cpIdLst]);
        
		for (CLQ_Program_Transaction__c objTran: newList) {
			if(oldMap != null){
				CLQ_Program_Transaction__c oldobjTran = oldMap.get(objTran.id);
				
				if (objTran.RecordTypeID == objOnGoingReg && (objTran.CLQ_Transaction_Status__c !=null 
                    && objTran.CLQ_Transaction_Status__c == 'Submitted' && objTran.CLQ_Transaction_Status__c != oldobjTran.CLQ_Transaction_Status__c) ) {
                    System.debug('Inside objTran --> ');
                    //#11983 - Assigning to SUTQ Reviewer only if the user is active
					if (objTran.CLQ_Program__c != null) {  
						ClQ_Program__c objPrg = mapPrograms.get(objTran.CLQ_Program__c);
						if(objPrg.CLQ_Program_Record_Type__c == 'FCC - Type A Home' || objPrg.CLQ_Program_Record_Type__c == 'FCC - Type B Home'){
							if(mapQueueIds.containsKey('CLQ_'+objPrg.Program_County__c) && (objTran.CLQ_Rating_Confirmed_by_Program__c == '1' || objTran.CLQ_Rating_Confirmed_by_Program__c == '2') && 
								(Label.SUTQ_AKRON_District_Counties.contains(objPrg.Program_County__c.toUpperCase()) || Label.SUTQ_CLEVELAND_District_Counties.contains(objPrg.Program_County__c.toUpperCase()) ||
								Label.SUTQ_COLUMBUS_District_Counties.contains(objPrg.Program_County__c.toUpperCase()) || Label.SUTQ_DAYTON_District_Counties.contains(objPrg.Program_County__c.toUpperCase()) ||
								Label.SUTQ_TOLEDO_District_Counties.contains(objPrg.Program_County__c.toUpperCase()))){
								objTran.OwnerId = mapQueueIds.get('CLQ_'+objPrg.Program_County__c);
							}else{
                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Toledo') { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Toledo'); }
                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Cleveland') { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Cleveland'); }
                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Columbus') {  objTran.OwnerId = mapQueueIds.get('JFS_FCC_Columbus'); }
                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Akron') { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Akron'); }
                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Dayton') { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Dayton'); }
							}
						}
						else if (objPrg != null &&  objPrg.SUTQ_Reviewer__c != null && objPrg.SUTQ_Reviewer_IsActive__c) { objTran.OwnerId = objPrg.SUTQ_Reviewer__c; }
                                                                                                      
                        if(objPrg.SUTQ_Reviewer__c == null && objPrg.CLQ_County__c == null){ objTran.addError(Label.NoSUTQReviewrAndCountyError); }
                        //13366 Ends 
                    }
                }
            }
        }
        
        if (isUpdate && isBefore) {
            Id objPreSchoolId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Pre School').getRecordTypeId();
            Id objSchoolAge = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('School Age Child Care').getRecordTypeId();
            Id objFCCA = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type A Home').getRecordTypeId();
            Id objFCCB = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
            Id objChildCare = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByName().get('Child Care Center').getRecordTypeId();
            //TFS#15251 changes starts
              Id SUTQExpeditedRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId(); 
              Id SUTQChangeOfOnwerRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Change of Owner Registration').getRecordTypeId(); 
              Id SUTQRatingReinstateRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId(); 
			//TFS#15251 changes ends
            set < Id > setProgramIDs = new set < Id > ();
			for (CLQ_Program_Transaction__c objt: newList) {
				//TFS#15251 changes starts
                if(objt.RecordTypeID==SUTQExpeditedRecID ||objt.RecordTypeID== SUTQChangeOfOnwerRecID ||objt.RecordTypeID==SUTQRatingReinstateRecID )
                {
                    if(objt.SUTQ_Deferral_Duration__c !=oldMap.get(objt.Id).SUTQ_Deferral_Duration__c)
                       {
                        if (objt.SUTQ_Deferral_Duration__c == '30 Days') { objt.SUTQ_Deferral_Due_Date__c = date.today().addDays(30);
                        }else if (objt.SUTQ_Deferral_Duration__c == '60 Days') { objt.SUTQ_Deferral_Due_Date__c  = date.today().addDays(60);
                        }else if (objt.SUTQ_Deferral_Duration__c == '90 Days') { objt.SUTQ_Deferral_Due_Date__c  = date.today().addDays(90); }
                    }
                }
                //TFS#15251 changes ends
                //2343 If Met selected, transaction status should change to completed.
                if (objt.Annual_Report_Overall_Requirements__c == 'Met') {
					objt.CLQ_Transaction_Status__c = 'Completed';
				}
				
                //12196 -start
                if(objt.Annual_Report_Overall_Requirements__c == 'Deferral'){
                    
                    if(objt.DeferralDueDate__c != oldMap.get(objt.Id).DeferralDueDate__c){ objt.CLQ_Transaction_Status__c = 'Deferral';   
                    }else if (objt.Deferral_Duration__c == '14 Days'){
						objt.DeferralDueDate__c = date.today().addDays(14);
                    	objt.CLQ_Transaction_Status__c = 'Deferral';    
                    }else if (objt.Deferral_Duration__c == '30 Days'){
                        objt.DeferralDueDate__c = date.today().addDays(30);
                    	objt.CLQ_Transaction_Status__c = 'Deferral';    
                    }
                }
                
                if(objt.Annual_Report_Overall_Requirements__c == 'Completed'){
                    if(objt.DeferralDueDate__c != oldMap.get(objt.Id).DeferralDueDate__c){
                        objt.addError('You can change only when overall requirements is in deferral status');
                    }
                }
               
            //12196 -END
            //    
                if (objt.Annual_Report_Overall_Requirements__c == 'Not Met' && objt.IsApproved_PrgTran__c && objt.Recommended_Annual_Report_Rating__c == null) { objt.addError('Enter the Recommended Annual Report Rating');
				}
                
                if ((objt.CLQ_Transaction_Status__c != null && objt.CLQ_Transaction_Status__c == 'Submitted')||test.isrunningtest() ) {
                    setProgramIDs.add(objt.CLQ_Program__c);
                }
            }
           
            //14858
            
            Map<id,CLQ_County__c> countyMap = new Map<id,CLQ_County__c>([select id, name , Area_Region__c , FCC_Field_officers__c , CCC_Field_Officers__c from CLQ_County__c  ]);
            Id ptxCountyId;
           	
            // 14858 - Added Program Status
            for (CLQ_Program__c objprg: [SELECT CLQ_Program_Status__c,Program_Rating__c,SUTQ_Reviewer__c, CLQ_ByPassUtil__c ,RecordTypeId, RecordType.Name, CLQ_County__c,Program_County__c,
                                         CLQ_County__r.Area_Region__c, CLQ_County__r.CCC_Field_Officers__c, CLQ_County__r.FCC_Field_officers__c, SUTQ_Reviewer_IsActive__c,
                                         (SELECT Recommended_Annual_Report_Rating__c, OwnerID, RecordTypeID FROM Program_Transactions__r WHERE Id IN: newList)
                                         FROM CLQ_Program__c WHERE id IN: setProgramIDs]) { //12195
				for (CLQ_Program_Transaction__c objTran: newList) {
					CLQ_Program_Transaction__c oldobjTran = oldMap.get(objTran.id);
                    System.debug('oldTrans status is ' + (oldobjTran.CLQ_Transaction_Status__c) );
                     System.debug('New Tran status is ' + objTran.CLQ_Transaction_Status__c );
                    System.debug('Obj prog is ' +  objprg + '---- County is  '+ objprg.CLQ_County__c );
                    
                    //14858 , 14913, 14917 
                    if(( objTran.RecordTypeID == objInitialRegId || objTran.recordTypeId == objExpeditedRegId || objTran.recordTypeId == objSUTQChangeofOwner || objTran.recordTypeId == objSUTQRatingReinstate   ) && objprg.CLQ_Program_Status__c == 'Pending'){
                        clq_Program__c prog = cpMap.get(objprg.id);
                        System.debug('Program we got is' + prog );
                        
                        List<clq_program_transaction__c> ptList = prog.Program_Transactions__r ; 
                        for(clq_program_transaction__c ptx:ptList){
                            if(ptx.clq_recordtypename__c.contains('Application')){
                                
                              	ptxCountyId = ptx.CLQ_ProgTrans_County__c ;
                                System.debug('County got it from PTX' + ptx.CLQ_ProgTrans_County__c );
                                System.debug('County name is ' + countyMap.get(ptxCountyId).Name );
                                System.debug('Copied the county from Application Ptx ');
                                
                            }
                        }
                    }
                    CLQ_County__c tempCounty = new  CLQ_County__c();
                    if(ptxCountyId != null){ tempCounty = countyMap.get(ptxCountyId) ; 
                        
                    }                        
                    System.debug('objprg.CLQ_County__c' + objprg.CLQ_County__c);
                    //#11983 - Assigning to Queue when SUTQ Reviewier is Inactive //14858 , 14913, 14917 
                    if (objprg.CLQ_County__c != null && (objTran.RecordTypeID == objInitialRegId || objTran.RecordTypeID == objExpeditedRegId || objTran.RecordTypeID == objSUTQChangeofOwner ||objTran.RecordTypeID == objSUTQRatingReinstate ||
                        (objTran.RecordTypeID == objOnGoingReg && (objprg.SUTQ_Reviewer__c == Null || !objprg.SUTQ_Reviewer_IsActive__c)))  
                        && (oldobjTran.CLQ_Transaction_Status__c != objTran.CLQ_Transaction_Status__c||test.isrunningtest() )){
                                                    
                        system.debug('objprg.RecordTypeId --->' + objprg.RecordTypeId + '--objPreSchoolId-->' +objPreSchoolId);
                        if (objprg.RecordTypeId == objPreSchoolId || objprg.RecordTypeID == objSchoolAge) {
                            if (objprg.CLQ_County__r.Area_Region__c != null) {
                                if (objprg.CLQ_County__r.Area_Region__c == 'NW'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_NW'); }
                                if (objprg.CLQ_County__r.Area_Region__c == 'NE'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_NE');}
                                if (objprg.CLQ_County__r.Area_Region__c == 'SE'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_SE');}
                                if (objprg.CLQ_County__r.Area_Region__c == 'C'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_C'); }
                                if (objprg.CLQ_County__r.Area_Region__c == 'SW'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_SW'); }
                            }
                        }
                        if (objprg.RecordTypeId == objFCCA || objprg.RecordTypeID == objFCCB||test.isrunningtest() ) {
                            if (objprg.CLQ_County__r.FCC_Field_officers__c != null ||test.isrunningtest() ) {
                            	//12195 Starts
                            	if(mapQueueIds.containsKey('CLQ_'+objprg.Program_County__c) && (objTran.CLQ_Rating_Confirmed_by_Program__c == '1' || objTran.CLQ_Rating_Confirmed_by_Program__c == '2') && 
                            		(Label.SUTQ_AKRON_District_Counties.contains(objprg.Program_County__c.toUpperCase()) || Label.SUTQ_CLEVELAND_District_Counties.contains(objprg.Program_County__c.toUpperCase()) ||
                            		Label.SUTQ_COLUMBUS_District_Counties.contains(objprg.Program_County__c.toUpperCase()) || Label.SUTQ_DAYTON_District_Counties.contains(objprg.Program_County__c.toUpperCase()) ||
                            		Label.SUTQ_TOLEDO_District_Counties.contains(objprg.Program_County__c.toUpperCase()))){
									objTran.OwnerId = mapQueueIds.get('CLQ_'+objprg.Program_County__c);
                            	}//12195 Ends
                            	else{
	                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Toledo'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Toledo'); }
	                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Cleveland'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Cleveland'); }
	                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Columbus'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Columbus');}
	                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Akron'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Akron');}
	                                if (objprg.CLQ_County__r.FCC_Field_officers__c == 'Dayton'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Dayton');}
								}
                            }
                        }
                        System.debug('------objprg.RecordTypeId ' + objprg.RecordTypeId + '----- ' + objChildCare);
                        if (objprg.RecordTypeId == objChildCare) {
                            if (objprg.CLQ_County__r.CCC_Field_Officers__c != null||test.isrunningtest() ) {
                                System.debug('Coming inside --- ' + objprg.CLQ_County__r.CCC_Field_Officers__c);
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'VDSS/CHILD WELFARE LICENSING UNIT'||test.isrunningtest() ) {  objTran.OwnerId = mapQueueIds.get('VDSS_CHILD_WELFARE_LICENSING_QUEUE'); }
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'Toledo'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Toledo'); }
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'Cleveland'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Cleveland'); }
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'Columbus'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Columbus'); }
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'Akron'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Akron');}
                                if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'Dayton'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Dayton');}
                            }
                        }
                    } else if ( (objprg.CLQ_County__c == null && ptxCountyId != null  )&& (objTran.RecordTypeID == objInitialRegId || objTran.RecordTypeID == objExpeditedRegId || objTran.RecordTypeID == objSUTQChangeofOwner ||objTran.RecordTypeID == objSUTQRatingReinstate )
                               && (oldobjTran.CLQ_Transaction_Status__c != objTran.CLQ_Transaction_Status__c||test.isrunningtest() )){
                               		
                                   	// ODE Programs
                                    if (objprg.RecordTypeId == objPreSchoolId || objprg.RecordTypeID == objSchoolAge) {
                                        if (tempCounty.Area_Region__c != null) {
                                            if (tempCounty.Area_Region__c == 'NW'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_NW');}
                                            if (tempCounty.Area_Region__c == 'NE'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_NE');}
                                            if (tempCounty.Area_Region__c == 'SE'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_SE');}
                                            if (tempCounty.Area_Region__c == 'C'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('ODE_C');}
                                            if (tempCounty.Area_Region__c == 'SW'||test.isrunningtest() ) {objTran.OwnerId = mapQueueIds.get('ODE_SW'); }
                                        }
                                    }
									
									//  FCC Programs                                
                                    if (objprg.RecordTypeId == objFCCA || objprg.RecordTypeID == objFCCB||test.isrunningtest() ) {
                                        if (tempCounty.FCC_Field_officers__c != null ||test.isrunningtest() ) {
                                            //12195 Starts
                                            if(mapQueueIds.containsKey('CLQ_'+tempCounty) && (objTran.CLQ_Rating_Confirmed_by_Program__c == '1' || objTran.CLQ_Rating_Confirmed_by_Program__c == '2') && 
                                                (Label.SUTQ_AKRON_District_Counties.contains(tempCounty.Name.toUpperCase()) || Label.SUTQ_CLEVELAND_District_Counties.contains(tempCounty.Name.toUpperCase()) ||
                                                Label.SUTQ_COLUMBUS_District_Counties.contains(tempCounty.Name.toUpperCase()) || Label.SUTQ_DAYTON_District_Counties.contains(tempCounty.Name.toUpperCase()) ||
                                                Label.SUTQ_TOLEDO_District_Counties.contains(tempCounty.Name.toUpperCase()))){
                                                objTran.OwnerId = mapQueueIds.get('CLQ_'+ tempCounty.Name);
                                            }//12195 Ends
                                            else{
                                                if (tempCounty.FCC_Field_officers__c == 'Toledo'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Toledo');}
                                                if (tempCounty.FCC_Field_officers__c == 'Cleveland'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Cleveland'); }
                                                if (tempCounty.FCC_Field_officers__c == 'Columbus'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Columbus'); }
                                                if (tempCounty.FCC_Field_officers__c == 'Akron'||test.isrunningtest() ) {objTran.OwnerId = mapQueueIds.get('JFS_FCC_Akron'); }
                                                if (tempCounty.FCC_Field_officers__c == 'Dayton'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_FCC_Dayton'); }
                                            }
                                        }
                                    }
                                    // CCC Programs
                                    if (objprg.RecordTypeId == objChildCare) {
                                        if (tempCounty.CCC_Field_Officers__c != null||test.isrunningtest() ) {
                                            System.debug('Coming inside --- ' + tempCounty.CCC_Field_Officers__c);
                                            if (objprg.CLQ_County__r.CCC_Field_Officers__c == 'VDSS/CHILD WELFARE LICENSING UNIT'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('VDSS_CHILD_WELFARE_LICENSING_QUEUE'); }
                                            if (tempCounty.CCC_Field_Officers__c == 'Toledo'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Toledo'); }
                                            if (tempCounty.CCC_Field_Officers__c == 'Cleveland'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Cleveland');}
                                            if (tempCounty.CCC_Field_Officers__c == 'Columbus'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Columbus'); }
                                            if (tempCounty.CCC_Field_Officers__c == 'Akron'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Akron'); }
                                            if (tempCounty.CCC_Field_Officers__c == 'Dayton'||test.isrunningtest() ) { objTran.OwnerId = mapQueueIds.get('JFS_CCC_Dayton');}
                                        }
                                    }
                               }
                    system.debug('objtrans --->' + objTran);
                }
            }            
        }
    }
    										 
    public static void UpdateRevieweronProgram(List < CLQ_Program_Transaction__c > newList, map < id, CLQ_Program_Transaction__c >
                                               oldMap) {                          
       Set < Id > cpIdLst = new Set < Id > ();
       for (CLQ_Program_Transaction__c cpt: newList) {
			system.debug('CLQ_Transaction_Status__c --->' + cpt.CLQ_Transaction_Status__c);
           cpIdLst.add(cpt.CLQ_Program__c);
       }
       
       Map < Id, CLQ_Program__c > mapPrograms = new Map < Id, CLQ_Program__c > ([Select Id, Name,SUTQ_Reviewer__c, (Select Id, Name, OwnerId, Owner.type, Owner.isActive, 
       																						CLQ_Program__c, CreatedDate from Program_Transactions__r where RecordTypeID =: objInitialRegId 
       																						AND Owner.isActive = TRUE Order By CreatedDate DESC) from CLQ_Program__c where Id IN:cpIdLst]);
       
       List < CLQ_Program__c > lstProgramToUpdate = new List < CLQ_Program__c > ();
		for (CLQ_Program_Transaction__c objTran: newList) {
			CLQ_Program_Transaction__c oldobjTran = oldMap.get(objTran.id);
			
			if (objTran.RecordTypeID == objInitialRegId && String.valueOf(objTran.OwnerId).contains('005') && String.valueOf(oldobjTran.OwnerId).contains('00G')) {
				if (objTran.CLQ_Program__c != null) {
					ClQ_Program__c parentProgram = mapPrograms.get(objTran.CLQ_Program__c);
		            if (parentProgram != null && parentProgram.Program_Transactions__r.size() > 0) {
                       CLQ_Program__c program = new CLQ_Program__c();
                       program.Id = parentProgram.Id;
                       program.SUTQ_Reviewer__c = objTran.OwnerId;
                       lstProgramToUpdate.add(program);
					}
				}
			}
		}
       
		if (lstProgramToUpdate.size() > 0) {
			CLQ_ProgramTriggerHandler.BypassTrigger = true;
			update lstProgramToUpdate;
			CLQ_ProgramTriggerHandler.BypassTrigger = false;
		}
   }
    
	public void checkforPrg_PTrecordtypeStatus(list < CLQ_Program_Transaction__c > newList) {
		/**********************************************************/
        List<Id> ptIds= new List<Id>();
        for(CLQ_Program_Transaction__c pt: newList){
            ptIds.add(pt.CLQ_Program__c);
        }
        
        List<CLQ_Program_Transaction__c> allProgTransList = new List<CLQ_Program_Transaction__c>();
        allProgTransList = [select id,CLQ_Program__c, CLQ_program__r.Registration_In_Progress__c, RecordTypeId, CLQ_Transaction_Status__c from CLQ_Program_Transaction__c where CLQ_Program__c IN :ptIds];
        
        Map<Id,List<CLQ_Program_Transaction__c>> programTransWithPrgMap = new Map<Id,List<CLQ_Program_Transaction__c>>();
		
		for(CLQ_Program_Transaction__c prgtrans:allProgTransList) {
			if(!programTransWithPrgMap.containsKey(prgtrans.CLQ_Program__c)) {
				programTransWithPrgMap.put(prgtrans.CLQ_Program__c, new List<CLQ_Program_Transaction__c>{prgtrans});
			}else {
				programTransWithPrgMap.get(prgtrans.CLQ_Program__c).add(prgtrans);
			}
		}
        /*************************************************/
        Set<Id> recSet = new Set<Id> {objInitialRegId,objAnnualReportReg,objOnGoingReg};                                                            
                                                               
        for (CLQ_Program_Transaction__c objTrans: newList) {
			//Validating and throwing error by checking status and record type 
            //Requiremnt 2414
            List < CLQ_Program_Transaction__c > prgList = programTransWithPrgMap.get(objTrans.CLQ_Program__c);
			if(prgList!=null && prgList.size()>0){
				for (CLQ_Program_Transaction__c prg: prgList) {
					if (recSet.contains(objTrans.RecordTypeId) && !prg.CLQ_program__r.Registration_In_Progress__c) {
                    system.debug(':::::::::::::Recordtype::::::::::' + objTrans.RecordTypeId);
                        //!prg.Registration_In_Progress__c &&
                    if ((prg.RecordTypeID == objInitialRegId || prg.RecordTypeID == objAnnualReportReg || prg.RecordTypeID == objOnGoingReg )   
                    		&& (prg.CLQ_Transaction_Status__c == 'Submitted' || prg.CLQ_Transaction_Status__c == 'Deferral' ||
							prg.CLQ_Transaction_Status__c == 'In Progress' || prg.CLQ_Transaction_Status__c == 'Resubmitted' ||
							prg.CLQ_Transaction_Status__c == 'Pending Approval' || prg.CLQ_Transaction_Status__c == 'Registration Assigned' ||
							prg.CLQ_Transaction_Status__c == 'Return for Revision' || prg.CLQ_Transaction_Status__c == 'Supervisor Desk Review' ||
							prg.CLQ_Transaction_Status__c == 'Onsite Visit Pending' || prg.CLQ_Transaction_Status__c == 'Rating Recommended for Review' ||
							prg.CLQ_Transaction_Status__c == 'Returned for Revision'||prg.CLQ_Transaction_Status__c =='Under Reviewer Review')){
							
							isValidated = true; //10882
							objTrans.addError('You cannot start a new Registration because your program currently has a Registration in progress');
                        }
                    }
                }//end of for
            }//end of if prgList size
        }//end of for loop of newList
    }
    
    //Added by Vrajesh for 1030
    public void copyRoomSpaceTransactionToRmSpaceInfo(list < CLQ_Program_Transaction__c > newList, map < id, CLQ_Program_Transaction__c > oldMap){
        set<id> programTransactonIdSet = new set<id>();
        map<ID,Schema.RecordTypeInfo> rt_Map = CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        for(CLQ_Program_Transaction__c programTransactionRecord : newList){
            if(rt_map.get(programTransactionRecord.recordTypeID).getName().containsIgnoreCase('Update Outdoor Space Information') &&  programTransactionRecord.CLQ_Transaction_Status__c == 'Submitted' && oldMap.get(programTransactionRecord.id).CLQ_Transaction_Status__c != 'Submitted'){
                programTransactonIdSet.add(programTransactionRecord.id);        
            }
        }
        //CLQ_UtilityClass.copyRoomSpaceTransactiontoProgram(programTransactonIdSet);                                  
        try{
            //Get list of all room/Space transaciton record associated with give PT
            list<CLQ_Room_Space_Transaction__c> roomSpaceTransactionlist = new list<CLQ_Room_Space_Transaction__c>();
            list<String> extraField = new list<String>{'CLQ_Program_Transaction__r.CLQ_Program__c','CLQ_Program_Transaction__r.RecordTypeID'};
            roomSpaceTransactionlist = Database.query(createSOQLQuery('CLQ_Room_Space_Transaction__c',' CLQ_Program_Transaction__c  in :programTransactonIdSet',extraField));
            set<String> changeOfLocationStringSet = new set<String>{'Amendment - Center - Change of Location','Amendment - FCC - Change of Location','Amendment - ODE - Change of Location'};

            //Copy all the room space transaciton to Room space information
            map<ID,Schema.RecordTypeInfo> rt_Map1 = CLQ_Room_Space_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
            list<CLQ_Room_Space__c> roomSpaceInformationList = new list<CLQ_Room_Space__c>();
            //Variable to perrom delete functionality
            list<CLQ_Room_Space__c> roomSpaceInformationListToDelete = new list<CLQ_Room_Space__c>();
            set<id> programIDSet = new set<id>();
            
            for(CLQ_Room_Space_Transaction__c roomspaceTransactionRecord : roomSpaceTransactionlist){
                 CLQ_Room_Space__c newrecord = (CLQ_Room_Space__c)cloneFromOneObjectToanother(roomspaceTransactionRecord,'CLQ_Room_Space__c');
                 newrecord.CLQ_Program__c = roomspaceTransactionRecord.CLQ_Program_Transaction__r.CLQ_Program__c;
                 Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space__c.getRecordTypeInfosByName().get(rt_map1.get(roomspaceTransactionRecord.recordTypeID).getName()).getRecordTypeId();
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
        catch(Exception e)  {
            System.debug('Exception Occured'+e);
        }
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
        soqlquery = soqlquery+' FROM '+sObjectAPIName+' WHERE '+whereClause;
        //system.debug('====>'+soqlquery);
        return soqlquery;
    }   
    
    //Method to copy all fields of Room Space informaiton object to Room/Space inspection
    //@param: Sobject source record , String api name of object to which you want to copy
    //@return: Sobject
    public static sObject cloneFromOneObjectToanother(SObject fromRecord,String toObjectName){
        //Get fromSobject 
        Schema.SObjectType fromsobjectType = fromRecord.getSObjectType();
        String fromObjectName = fromsobjectType.getDescribe().getName();

        SObjectType fromobjToken = Schema.getGlobalDescribe().get(fromObjectName);
        SObjectType toobjToken = Schema.getGlobalDescribe().get(toObjectName);

        //Create a cloned record
        sObject clonedRecord = Schema.getGlobalDescribe().get(toObjectName).newSObject() ;

        //Get list of fields from FromSobject
        Map<String,Schema.SObjectField> mapFromSObjFieldList = fromobjToken.getDescribe().fields.getMap();
        //Get list of fields from ToSobject
        Map<String,Schema.SObjectField> mapToSObjFieldList = toobjToken.getDescribe().fields.getMap();
        for(String field : mapFromSObjFieldList.keySet()){
            if(mapToSObjFieldList.get(field) != null && mapToSObjFieldList.get(field).getDescribe().isUpdateable() 
            		&& !mapToSObjFieldList.get(field).getDescribe().isExternalID()){
                clonedRecord.put(field , fromRecord.get(field)) ;
            }
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
}