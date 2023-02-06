/* Name : CLQ_Trigger
* Description : This is the base class for trigger handler classes to capture the Trigger context and 
*               contain it for the Trigger Handling methods.
*               The typical trigger will follow this pattern, where OpportunityTriggerHandler extends this class
*
*   OpportunityTriggerHandler Handler = new OpportunityTriggerHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap,
*                               trigger.isExecuting, trigger.isInsert, trigger.isUpdate, trigger.isDelete, 
*                               trigger.isBefore, trigger.isAfter, trigger.isUndelete, trigger.size);
*   Handler.ProcessTrigger();
*/
public without sharing virtual class CLQ_Trigger
{
    //Variable  Usage
    //Returns true if the current context for the Apex code is a trigger, not a Visualforce page, 
    //a Web service, or an executeanonymous() API call.
    public boolean isExecuting; 
    //Returns true if this trigger was fired due to an insert operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isInsert;    
    //Returns true if this trigger was fired due to an update operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isUpdate;    
    //Returns true if this trigger was fired due to a delete operation, from the Salesforce user 
    //interface, Apex, or the API.
    public boolean isDelete;    
    //Returns true if this trigger was fired before any record was saved.
    public boolean isBefore;    
    //Returns true if this trigger was fired after all records were saved.
    public boolean isAfter;     
    //Returns true if this trigger was fired after a record is recovered from the Recycle Bin 
    //(that is, after an undelete operation from the Salesforce user interface, Apex, or the API.)
    public boolean isUndelete;  
    //Returns a list of the new versions of the sObject records.
    //Note that this sObject list is only available in insert and update triggers, and the records 
    //can only be modified in before triggers.
    public list<sObject> newlist;           
    //A map of IDs to the new versions of the sObject records.
    //Note that this map is only available in before update, after insert, and after update triggers.
    public map<id,sObject> newMap;      
    //Returns a list of the old versions of the sObject records.
    //Note that this sObject list is only available in update and delete triggers.
    public list<sObject> oldlist;           
    //A map of IDs to the old versions of the sObject records.
    //Note that this map is only available in update and delete triggers.
    public map<id,sObject> oldMap;      
    //The total number of records in a trigger invocation, both old and new.    
    public integer size;
    
    public static final String EMPTY_STRING = '';
    public static final String BEFORE = 'before';
    public static final String AFTER = 'after';
    public static final String INSERT_STRING = 'insert';
    public static final String UPDATE_STRING = 'update';
    public static final String DELETE_STRING = 'delete';
    public static final String UNDELETE_STRING = 'undelete';
    public static final String CLQ_PROGRAM = 'clq_program_transaction__c';
    public static final string FALSE_STRING = 'false';
    
    public virtual boolean getUpdateFlag()  {   return false;   }
    public virtual void setUpdateFlag(boolean newVal)   {}
    
    public boolean HasAlreadyUpdated
    {
        get {   
            boolean RetVal = getUpdateFlag();
            return (RetVal == null) ? false :   RetVal;
        }
        set {   setUpdateFlag(value);   }
    }

    public static boolean BypassAllTriggers
    {
        get
        {
            if (BypassAllTriggers == null){
                return false;
            } 
            return BypassAllTriggers;
        }
        set;
    }
    
    //Allows an individual trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.     
    protected boolean BypassInheritedTrigger
    {
        get
        {
            if (BypassInheritedTrigger == null){
                return false;
            } 
            return BypassInheritedTrigger;
        }
        set;
    }

    //Constructor to pass in all values of the trigger
    //@param : All Trigger values
    //@return : null
    public CLQ_Trigger(list<sObject> newlistin, map<id,sObject> newMapin, list<sObject> oldlistin, map<id,sObject> oldMapin,
                        boolean isExecutingin, boolean isInsertin, boolean isUpdatein,   boolean isDeletein, 
                        boolean isBeforein,    boolean isAfterin,  boolean isUndeletein, integer sizein)
    {
        this.newlist    = newlistin;
        this.newMap     = newMapin;
        this.oldlist    = oldlistin;
        this.oldMap     = oldMapin;
        this.isExecuting = isExecutingin;
        this.isInsert   = isInsertin;
        this.isUpdate   = isUpdatein;
        this.isDelete   = isDeletein;
        this.isBefore   = isBeforein;
        this.isAfter    = isAfterin;
        this.isUndelete = isUndeletein;
        this.size       = sizein;
    }

    //Public method to execute any functionality contained in the extension classes
    //@param : none 
    //@return : null
    public virtual void ProcessTrigger()
    {
        /*system.debug('CLQ_Trigger.ProcessTrigger: ' + TriggerExecutionType + '  IsBefore: ' + IsBefore + ' isAfter: ' + isAfter + ' isInsert: ' + isInsert + 
                      ' isUpdate: ' + isUpdate + ' isDelete: ' + isDelete + ' isUndelete: ' + isUndelete + ' size: ' + size);*/
        // BypassAllTriggers is public static, BypassInheritedTrigger is protected instance variable
        if (BypassAllTriggers || BypassInheritedTrigger){
            return;
        } 
        if (isUpdate && ObjectName.ToLowerCase() == CLQ_PROGRAM){
            ShowPTFieldChanges();
        } 
        if (IsBefore)
        {
            if (isInsert){
                BeforeInsert();
            }        
            else if (isUpdate && !HasAlreadyUpdated)
            {
            	BeforeUpdate();
            }
            
            else if (isDelete){
                BeforeDelete();
            }   
            else if (isUndelete){
                BeforeUndelete();
            } 
        }
        else if (isAfter)
        {
            if (isInsert){
                AfterInsert();
            }        
            else if (isUpdate && !HasAlreadyUpdated) 
            {
                AfterUpdate();
                //This flag will stop the trigger from running in a loop
                //In unit tests, we want the trigger to run many time in a test.
                //Allow testing to run many times, unless someone's code is really messed up
                //if (!Test.isRunningTest() || TestingNeedsToStopRecycle) - Breaks too many tests
                HasAlreadyUpdated = true;//RR important
            }
            else if (isUpdate && HasAlreadyUpdated)
            {
            	system.Debug('Has Updated - Bypass Trigger 2');
            }
            else if (isDelete){
                AfterDelete();
            }   
            else if (isUndelete){
                AfterUndelete();
            } 
        }
        
        
        //This method is called to perform sharing calculations
        //It handles all necessary conditions and events in handler class
        //OCLQS Portal Team
        //OCLQS_SObjectTriggerSharingHandler sharingHandler = new OCLQS_SObjectTriggerSharingHandler(Trigger.isBefore ,Trigger.isAfter , Trigger.isInsert, Trigger.isUpdate ,Trigger.isDelete  ,Trigger.new , Trigger.old  ,Trigger.newMap , Trigger.oldMap ) ;    
        //sharingHandler.recalculateSharing() ;
        //Sharing calculation ends 
        
    }

    //The developer can override any of these methods when necessary
    public virtual void BeforeInsert() {}
    public virtual void BeforeUpdate() {}
    public virtual void BeforeDelete() {}
    public virtual void BeforeUndelete() {}
    public virtual void AfterInsert() {}
    public virtual void AfterUpdate() {}
    public virtual void AfterDelete() {}
    public virtual void AfterUndelete() {}

    public string ObjectName
    {
        get
        {
            sObject so;
            if(isInsert || isUpdate || isUndelete   )
            {
                so = newList[0] ;
            }else if(isDelete )
            {
                so = OldList[0] ;
            }
            if (so != null){
                return so.getSobjectType().getDescribe().getName() ;
            }	
            else{
                return 'Null object';
            }
            	        
        }
    }
    //Returns the Type of execution being performed
    public string TriggerExecutionType
    {
        get
        {
            string ExcType = EMPTY_STRING;
            if (IsBefore){
                ExcType = BEFORE;
            } 
            if (IsAfter){
                ExcType = AFTER;
            } 
            if (isInsert){
                ExcType += INSERT_STRING;
            } 
            if (isUpdate){
                ExcType += UPDATE_STRING;
            } 
            if (isDelete){
                ExcType += DELETE_STRING;
            } 
            if (isUndelete){
                ExcType += UNDELETE_STRING;
            } 
            return ExcType;
        }
    }
    
    public static boolean TestingNeedsToStopRecycle
    {
        get
        {
            if (TestingNeedsToStopRecycle == null){
                TestingNeedsToStopRecycle = false;
            } 
            return TestingNeedsToStopRecycle;
        }
        set;
    }
    
    public sObject MakeVersionBackup(id ItemId)
    {
        return CLQ_Trigger.MakeVersionBackup(ItemId, oldMap);
    }
    public static sObject MakeVersionBackup(id ItemId, map<Id, sObject> oldMap)
    {
        if (!oldMap.containsKey(ItemId)){return null;}
        sObject OldVersion;
        if(oldMap.size()!=0){
        	OldVersion = oldMap.get(ItemId);
        }
        //clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber)
        sObject OldVersionBackup = OldVersion.Clone(false, true, true, true);
        return OldVersionBackup;
    }
	public void ShowPTFieldChanges()
	{
		if (ObjectName.ToLowerCase() == CLQ_PROGRAM)
		{
			for(CLQ_Program_Transaction__c NewRecord : (list<CLQ_Program_Transaction__c> )newList)
			{
                CLQ_Program_Transaction__c OldRecord;
                if(OldMap.size()!=0){
					OldRecord = (CLQ_Program_Transaction__c) OldMap.get(newRecord.Id);
                }
				set<string> ChangedFields =  CLQ_CloneUtility.FindModifiedFields( NewRecord,  OldRecord);

			}
		}
	}
    
    public static boolean BypassSelectiveTriggers
    {
        get
        {	
            if (Label.ByPassSelectiveTrigger == null || Label.ByPassSelectiveTrigger == EMPTY_STRING || Label.ByPassSelectiveTrigger.equalsIgnoreCase(FALSE_STRING)){
                return false;
            } 
            return Boolean.valueOf(Label.ByPassSelectiveTrigger);
        }
        set;
    }
}