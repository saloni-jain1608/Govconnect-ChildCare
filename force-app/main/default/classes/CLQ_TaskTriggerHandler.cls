/**************************************************************************************************************
** Name             : CLQ_TaskTriggerHandler
** Description      : Task trigger handler class.
** Version          : 1.4
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer           Date            Version     Description
**------------------------------------------------------------------------------------------------------------
**  Dev Team            Oct-2016        1.0         Created
**  Ramana Gurivelli    12July-2017     1.1         Removed with sharing, bug# 11494.
**  Ramana Gurivelli    08Aug-2017      1.2         To update task lookup fields, bug# 11505.
**  Neetu Ojha          10/24/2017      1.3         TFS#11799 - Error Occurred During Flow "CLQ_Corrective_Action_Plan_Updates", Too many SOQL queries: 101
**  Neetu Ojha          10/25/2017      1.4         TFS#11471 - Create App Review Task only if no open task.            
**************************************************************************************************************/

public with sharing class CLQ_TaskTriggerHandler extends CLQ_Trigger {
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
    private static boolean HasUpdated;
    public override boolean getUpdateFlag() { return HasUpdated; }
    public override void setUpdateFlag(boolean newVal) { HasUpdated = newVal; }
    public static final String open = 'Open';
    public static final String high = 'High';
    public static final String SFDC = 'SFDC-001.2';
    public static final String errorMsg = 'Salesforce Exception -- CLQ_TaskTriggerHandler';
    public static final String emptyString = '';

    //Calls the Base class Constructor
    public CLQ_Tasktriggerhandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,
            map < id, sObject > oldMapin,
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

    public override void BeforeInsert() {
        SetType((list < Task > ) newList);
        //This Method executes instead of the base class empty method
        ProgramTransactionTaskUpdate((List < Task > ) newList, (Map < Id, Task > ) OldMap);
    }
    public override void BeforeUpdate() {
        SetType((list < Task > ) newList);
    }
    public override void AfterInsert() {

    }

    public void ProgramTransactionTaskUpdate(List <Task > NewTasks, Map < Id, Task > OldTasks) {

        map < id, id > WhatOwnerMap = new map < id, id > ();
        
        //11799 Starts
        Map<ID, CLQ_Program_Transaction__c> progTransMap;
        Map<ID, CLQ_Case_Custom__c> caseMap;
        Map<ID, CLQ_Inspection__c> inspectionMap;
        //11799 Ends
        
        for (Task task: NewTasks) {
            if (task.WhatId != null){ 
                WhatOwnerMap.put(task.whatid, task.ownerid);
            }
        }
       
        //story 1020 - get the program id for each of the following: case, program transaction, inspection
        // Populate map from SOQL query
        //11799 Starts
        if(WhatOwnerMap.KeySet() != null){
            progTransMap = new Map<ID, CLQ_Program_Transaction__c>([SELECT Id, CLQ_Program__r.id FROM CLQ_Program_Transaction__c where id IN: WhatOwnerMap.KeySet()]);
        }
        if(WhatOwnerMap.KeySet() != null){
        	caseMap = new Map<ID, CLQ_Case_Custom__c>([SELECT Id, CLQ_Program__r.id FROM CLQ_Case_Custom__c where id IN: WhatOwnerMap.KeySet()]);
        }
		if(WhatOwnerMap.KeySet() != null){
        	inspectionMap = new Map<ID, CLQ_Inspection__c>([SELECT Id, CLQ_Program__r.id FROM CLQ_Inspection__c where id IN: WhatOwnerMap.KeySet()]);
        }        
        //11799 Ends
    
        //now iterate through the tasks and populate the associated programs
        for (Task task: NewTasks) {
            if (progTransMap.size()!=0 && progTransMap.get(task.whatid) != null){ //11799
                task.CLQ_Program__c = progTransMap.get(task.whatid).CLQ_Program__r.id;
                task.Program_Transaction__c = progTransMap.get(task.whatid).Id; //11505
            }
            else if (caseMap.size()!=0 && caseMap.get(task.whatid) != null){//11799
                task.CLQ_Program__c = caseMap.get(task.whatid).CLQ_Program__r.id;
                task.Cases__c = caseMap.get(task.whatid).Id; //11505
            }    
            else if (inspectionMap.size()!=0 && inspectionMap.get(task.whatid) != null){//11799
                task.CLQ_Program__c = inspectionMap.get(task.whatid).CLQ_Program__r.id;
                task.Inspection__c = inspectionMap.get(task.whatid).Id; //11505
            }                   
        }
    }

    public static void SetType(list < Task > newList) {
        for (Task Task: newList) Task.CLQ_WhatType__c = CLQ_EventTriggerHandler.GetObjectNameByPrefix(Task.WhatId);
    }
    
    //11471 Starts

    @InvocableMethod(label='CreateReviewerTask' description='Creates Task for Reviewer')
    public static void CreateReviewerTask(List<String> lstParameters) {
        Map<Id, Id> mapPTReviewerId = new Map<Id, Id>();
        List<Task> lstTasktToInsert = new list<Task>();
        String taskSubject =emptyString;

        try{
            for(String paramStr : lstParameters){
                String[] strArr = paramStr.split('\\|');
                mapPTReviewerId.put(strArr[0], strArr[1]); 
                taskSubject = strArr[2];
            }
            
            if(!mapPTReviewerId.isEmpty()){
                for(CLQ_Program_Transaction__c pt : [SELECT Id, CLQ_Program__c, CLQ_Transaction_Assigned_To__c,
                                                        (SELECT Id FROM Tasks WHERE WhatId IN : mapPTReviewerId.keySet() AND 
                                                        OwnerId IN : mapPTReviewerId.values() AND Subject =: taskSubject AND isClosed=false)
                                                    FROM CLQ_Program_Transaction__c where ID IN : mapPTReviewerId.keySet() 
                                                    AND CLQ_Transaction_Assigned_To__c IN : mapPTReviewerId.values()]){
                    if(pt.Tasks.IsEmpty()){
                        Task tsk = new Task();
                        tsk.CLQ_Program__c = pt.CLQ_Program__c;
                        tsk.Program_Transaction__c = pt.Id;
                        tsk.WhatId = pt.Id;
                        tsk.Subject = taskSubject;
                        tsk.activityDate = system.Today().addDays(90);
                        tsk.OwnerId = pt.CLQ_Transaction_Assigned_To__c;
                        tsk.Priority = high;
                        tsk.Status = open;
                        tsk.IsVisibleInSelfService = true;
                        
                        lstTasktToInsert.add(tsk);
                    }
                }
                
                
                if(!lstTasktToInsert.isEmpty()){
                    insert lstTasktToInsert;
                }
            }
            
        }catch(Exception ex){
            Integration_Transaction_Logs.LogError(SFDC, ex.getMessage() ,emptyString ,String.valueOf(ex.getLineNumber()),emptyString,errorMsg);
        }
    } 
    //11471 Ends
}