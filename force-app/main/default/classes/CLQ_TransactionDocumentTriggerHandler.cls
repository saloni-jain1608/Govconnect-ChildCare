/**************************************************************************************************************
** Name             : CLQ_TransactionDocumentTriggerHandler
** Description      : Handles transaction documents
** Assumptions      : 
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version		Description
**------------------------------------------------------------------------------------------------------------
**	IncapsulateDevTeam		Dec-2017		1.0			Created
**	Soufin Rahimeen			21-Dec-2017		1.0			TFS#11857 : Added deleteReplacedStandardDocuments to delete old standard document
**	Soufin Rahimeen			02/20/2018		1.1			TFS#11901 : Added integration log
**  Rohit Gowrishetty		07/09/2018		1.2			TFS#13359 : Updated the class the let the documents with "Not Verified" to be completed
**************************************************************************************************************/ 
public with sharing class CLQ_TransactionDocumentTriggerHandler extends CLQ_Trigger 
{
    public static final string APPROVED = 'Approved';
    public static final string APPROVE = 'Approve';
    public static final string DENIED = 'Denied';
    public static final string NOT_VERIFIED = 'Not Verified';
    public static final string DENY = 'Deny';
    public static final string WITHDRAW = 'Withdraw';
    public static final string GT = '&gt;';
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
    
    //Calls the Base class Constructor
    public CLQ_TransactionDocumentTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
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
                                    
    public override void AfterUpdate()
    {
        updateDocuentReivewOnPTwithCall((map<id, CLQ_Transaction_Document__c> ) NewMap);
        deleteReplacedStandardDocuments((list<CLQ_Transaction_Document__c> ) newList, (map<id, CLQ_Transaction_Document__c>) oldMap); //11857
    }  
    
    public override void AfterInsert()
    {
        updateDocuentReivewOnPTwithCall((map<id, CLQ_Transaction_Document__c> ) NewMap);
    }          
    
    //11857 start
    private void deleteReplacedStandardDocuments(list<CLQ_Transaction_Document__c> newList, map<id, CLQ_Transaction_Document__c> oldMap) {
    	system.debug('---- Entering deleteReplacedStandardDocuments ----');
    	
    	try {
	    	list<Id> lstOldDocumentsToDelete = new list<Id>();
	    	
			for (CLQ_Transaction_Document__c transDoc: newList) {
				if(oldMap.size()!=0 && transDoc.CLQ_Document__c != oldMap.get(transDoc.Id).CLQ_Document__c ){
					lstOldDocumentsToDelete.add(oldMap.get(transDoc.Id).CLQ_Document__c );
				}
			}
			
			if (lstOldDocumentsToDelete.size() > 0) {
				list<CLQ_Standard_Document__c> lstStdDocumentsToDelete = [SELECT Id FROM CLQ_Standard_Document__c WHERE Id IN :lstOldDocumentsToDelete];
                if(!lstStdDocumentsToDelete.isEmpty()){
                    delete lstStdDocumentsToDelete;
                }
				system.debug('Old document deleted!');
			}
			
    	} catch (Exception ex) {
			system.debug('Exception occured in : deleteReplacedStandardDocuments --'+ex.getMessage());
  			Integration_Transaction_Logs.LogError('SFDC-001.2', ex.getMessage() ,'' ,String.valueOf(ex.getLineNumber()),'','Salesforce Exception -- CLQ_TransactionDocumentTriggerHandler');
		}
    }
    //11857 end                       
    
    public void updateDocuentReivewOnPTwithCall(map<id, CLQ_Transaction_Document__c> NewMap){
        List<CLQ_Program_Transaction__c> PtListToUpdate= new list<CLQ_Program_Transaction__c>();
        PtListToUpdate = UpdateDocumentReviewOnPT(NewMap , null);
        
        try {
        	
        	try {
            if (PtListToUpdate != null && PtListToUpdate.size() > 0){
                boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
                CLQ_Trigger.BypassAllTriggers = true;
                update PTListToUpdate;
                CLQ_Trigger.BypassAllTriggers = PreviousValue;
            }
	        }catch(System.DmlException e) {
	            //system.debug('dmlMessage : '+e.getDmlMessage(0) + ' '+NewMap.values()[0]);
	            String msg = e.getDmlMessage(0);
                
	            if(e.getDmlMessage(0).contains(GT)) {
	                msg = e.getDmlMessage(0).replace('&gt;','>');
	            }
	            NewMap.values()[0].addError(msg);
	            
        	}
        } catch (Exception e) { //11901 added integration log
        	system.debug('Error in CLQ_TransactionDocumentTriggerHandler ----'+e);
        	//Error Framework- Log Error
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.2', 'Error in execute CLQ_TransactionDocumentTriggerHandler - ' + e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        
        }
        
    }  
      // Method created by LD:- Story 675 to update CLQ_Document_Review_Complete__c on PT
    public List<CLQ_Program_Transaction__c> UpdateDocumentReviewOnPT(map<id, CLQ_Transaction_Document__c> NewMap, List<CLQ_Program_Transaction__c> newPTList){

        set <Id> PTIdSet = new set <Id> ();
        List<CLQ_Program_Transaction__c> PTList = null;
        for (CLQ_Transaction_Document__c td: NewMap.Values())
        {
            if (td.CLQ_Program_Transaction__c != null){
                PTIdSet.add(td.CLQ_Program_Transaction__c);
            }
                
        }
        if (PTIdSet.IsEmpty()) {return null;}
        List<CLQ_Transaction_Document__c> TDList;
        if(PTIdSet != null){
        	TDList = new List<CLQ_Transaction_Document__c>([SELECT id, name, CLQ_Program_Transaction__c, CLQ_Document_Status__c FROM CLQ_Transaction_Document__c WHERE CLQ_Program_Transaction__c IN:PTIdSet]);
        }
        List< CLQ_Transaction_Document__c > TDAppList = new List< CLQ_Transaction_Document__c > ();
        List< CLQ_Transaction_Document__c > TDdeniedList = new List< CLQ_Transaction_Document__c > ();
		List< CLQ_Transaction_Document__c > TDNotVerifiedList = new List< CLQ_Transaction_Document__c > (); //13359

        Map<Id,CLQ_Program_Transaction__c> PTListToUpdate = new Map<ID,CLQ_Program_Transaction__c>(); 
		
        try {
	        	for (CLQ_Transaction_Document__c td: TDList)
		        {
                    if (td.CLQ_Document_Status__c == APPROVED){
                        TDAppList.add(td);
                    }
                    if (td.CLQ_Document_Status__c == DENIED){
                        TDdeniedList.add(td);
                    }
                    if (td.CLQ_Document_Status__c == NOT_VERIFIED){
                        TDNotVerifiedList.add(td);
                    }
		            	
		        }
		        
		        if (newPTList == null){
                    //System.debug('');
                    if(PTIdSet != null){
                        PTList = new List<CLQ_Program_Transaction__c>([SELECT id, CLQ_Recommendation__c, CLQ_Document_Review_Complete__c,RecordType.Name FROM CLQ_Program_Transaction__c WHERE Id IN :PTIdSet]);
                    }
		            system.debug('PTList..'+ PTList);
		        }
		        else{
		           PTList = newPTList;
		           system.debug('PTList..'+ PTList);
		        }
		            
		        for(CLQ_Program_Transaction__c pt : PTList){
		            //if (!pt.CLQ_Document_Review_Complete__c){
	                //Mod by LD on 1/7/17 -- fix for OJLS-1196
	                
	                //13805 - initially setting to false when new document is inserted
	                //pt.CLQ_Document_Review_Complete__c = false;
	                
	                //system.debug('***1'+ TDAppList.size() + '**** '+ TDdeniedList.size() + '**** total '+ TDList.size());
	                // recommendation = blank
	                if (pt.CLQ_Recommendation__c == null){
	                    system.debug(TDAppList.size());
	                    if (TDList.size() > 0 && (TDAppList.size() + TDdeniedList.size() + TDNotVerifiedList.size() == TDList.size())){ //13359
	                        pt.CLQ_Document_Review_Complete__c = true;
	                        PTListToUpdate.put(pt.id,pt);                      
	                    }
	                    else{
	                        pt.CLQ_Document_Review_Complete__c = false;
	                        PTListToUpdate.put(pt.id,pt);
	                    }
	                }
		                
	                if(pt.CLQ_Recommendation__c == APPROVE){
                        //System.debug('');
	                    if (TDList.size() > 0 && TDAppList.size() > 0 && TDdeniedList.size() == 0){
	                    	
	                        pt.CLQ_Document_Review_Complete__c = true;
	                        PTListToUpdate.put(pt.id,pt);                   
	                    }
	                    else{
	                    	/*//RR
	                    	if (TDList.size() == 0){
	                    		pt.CLQ_Document_Review_Complete__c = true;
	                    		PTListToUpdate.put(pt.id,pt);
	                    	}
	                    	else{
	                    https://govconnectchildcarelicesing--gcccldev.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#		//RR*/
	                    		//System.debug('approved and coming into not listlist');
	                        	pt.CLQ_Document_Review_Complete__c = false;
	                        	PTListToUpdate.put(pt.id,pt);
	                    	//}
	                    }
	                }
		            
	                if ((pt.CLQ_Recommendation__c == DENY || pt.CLQ_Recommendation__c == WITHDRAW)){ 
                       System.debug('');
	                   if ((TDList.size() > 0 && TDdeniedList.size() > 0)){
	                      pt.CLQ_Document_Review_Complete__c = true;
	                      PTListToUpdate.put(pt.id,pt);
	                   }
	                   else{
	                    pt.CLQ_Document_Review_Complete__c = false;
	                    PTListToUpdate.put(pt.id,pt);
	                   }
	               }
		            
		            if (pt.CLQ_Document_Review_Complete__c && (TDList.size() > 0 && (TDAppList.size() + TDdeniedList.size() + TDNotVerifiedList.size() != TDList.size()))){
		               
	                        pt.CLQ_Document_Review_Complete__c = false;
	                        PTListToUpdate.put(pt.id,pt);
	                    
		            }
		        }
        } catch (Exception e) { //11901 
        	//Error Framework- Log Error
            Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.2', 'Error in execute CLQ_TransactionDocumentTriggerHandler - ' + e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
        
        }
        
         system.debug('PtListToUpdate....'+ PTListToUpdate);
        
        return PTListToUpdate.values();
        //Update PT.CLQ_Administrator_Review_Complete__c status = True
        /*if (PtListToUpdate.size() > 0){
            boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
            CLQ_Trigger.BypassAllTriggers = true;
            update PTListToUpdate.values();
            CLQ_Trigger.BypassAllTriggers = PreviousValue;
        }*/
     }                              
                                    
}