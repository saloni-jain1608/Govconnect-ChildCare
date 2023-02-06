/**************************************************************************************************************
** Name             : CLQ_EventTriggerHandler
** Description      : Invoked for Event trigger
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                    Date                Version         Description
**------------------------------------------------------------------------------------------------------------
** IncapsulateDevTeam           July-2016           1.0             Created
** Rohit Gowrishetty            05/21/2018          1.1             TFS#12444 : Updated the total duration logic for inspection and Inspector to consider Archived records
** Soufin Rahimeen              08/10/2018          1.2             TFS#13807 - Updated logic for calcualting last visit date
**************************************************************************************************************/
public class CLQ_EventTriggerHandler extends CLQ_Trigger {

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

    //Calls the Base class Constructor
    public CLQ_EventTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,
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

    Public integer VisitEventCount;Public decimal InspectorTotalVisitDuration;

    public override void BeforeInsert() {
        SetType((list < Event > ) newList);
    }
    public override void BeforeUpdate() {
        SetType((list < Event > ) newList);
        AssignedTo_Rule_For_EventInspection((list < Event >) newList, (map <Id, Event >) oldMap);
    }
    public override void AfterInsert() {
        //This method executes instead of the base class empty method
        InspectionFirstVisitEvent((List<Event>) NewList);
        InspectionEventCountUpdateIncr((List<Event>) NewList);
    }
    
    public override void AfterUpdate() {
        InspectorsTotalVisitTime((List < Event > ) NewList);
        InspectionLastVisitDateUpdate((List < Event > ) NewList); //13807
    }
    
    /*****to handle evnt count on Inspection***/
    public override void BeforeDelete() {
        InspectionEventCountUpdate((map <Id, Event >) oldMap);
    }
    
    public override void AfterDelete() {
        InspectionLastVisitDateUpdate((List < Event > ) oldList); //13807
    }    
    
    /*13807 - Method to update latest visit end date as Last visit date on Inspection
    Parameter : Event list
    */
    public void InspectionLastVisitDateUpdate(list < Event> lstEvents) {
        
        Set < Id > InspectionIdSet = new set < Id > ();
        List<CLQ_Inspection__c> lstInspectionToUpdate = new List<CLQ_Inspection__c>();
        
        system.debug('lstEvents for visit-->' + lstEvents);

        for (Event et: lstEvents) {
            if (et.WhatId !=null && String.ValueOf(et.WhatId).substring(0, 3) == CLQ_Inspection__c.sobjecttype.getDescribe().getKeyPrefix())
                InspectionIdSet.add(et.WhatId); //get the current inspection id
        }
        
        system.debug('InspectionIdSet--->'+InspectionIdSet);
        
        if(!InspectionIdSet.isEmpty()){
            try {
                for(CLQ_Inspection__c inspObj : [Select Id,CLQ_Last_Visit_Date__c, 
                            (SELECT Id, EndDateTime, CLQ_Event_Status__c 
                                FROM Events
                                WHERE Type='Visit'
                                    AND CLQ_Event_Status__c = 'Completed' 
                                    AND EndDateTime != null
                                ORDER BY EndDateTime DESC LIMIT 1) 
                             from CLQ_Inspection__c where ID IN : InspectionIdSet]){
                    if(inspObj.Events.size()>0){
                        Event latestVisit = inspObj.Events[0];
                        Date latestVisitEndDate = Date.newinstance(latestVisit.EndDateTime.year(), latestVisit.EndDateTime.month(), latestVisit.EndDateTime.day()); //get the end date and set it to inspection
                        inspObj.CLQ_Last_Visit_Date__c = latestVisitEndDate;
                        lstInspectionToUpdate.add(inspObj);
                    }               
                }       

                system.debug('lstInspectionToUpdate--- '+lstInspectionToUpdate);
                if(!lstInspectionToUpdate.isEmpty()){
                    CLQ_InspectionTriggerHandler_Custom.BypassTrigger = true;
                    update lstInspectionToUpdate;
                    CLQ_InspectionTriggerHandler_Custom.BypassTrigger = false;
                }
            } catch (Exception e) {
                System.debug(e);
                Integration_Transaction_Logs.LogErrorRealTime('SFDC-001.2', 'Salesforce Exception -- CLQ_EventTriggerHandler - ' + e.getMessage()  , 'Cause:' + e.getCause(), 'Line:'+e.getLineNumber(), e.getStackTraceString(), e.getTypeName());
            }
        }
    }
    
    
    public void InspectionEventCountUpdateIncr(list < Event> triggerlist) {
        set < Id > InspectionIdSet = new set < Id > ();
        Map < Id, CLQ_Inspection__c > InspectionMap = New Map < Id, CLQ_Inspection__c > ();
        Map < Id, CLQ_Inspection__c > InspectionToUpdateMap = New Map < Id, CLQ_Inspection__c > ();

        for (Event et: triggerlist) {
            if (et.WhatId !=null && String.ValueOf(et.WhatId).substring(0, 3) == CLQ_Inspection__c.sobjecttype.getDescribe().getKeyPrefix())
                InspectionIdSet.add(et.WhatId);
        } 

        for(CLQ_Inspection__c ins: [SELECT Id, Name, CLQ_Event_Information_Count__c from CLQ_Inspection__c where Id IN: InspectionIdSet])
        {
            if(ins.CLQ_Event_Information_Count__c!=null)
                ins.CLQ_Event_Information_Count__c = ins.CLQ_Event_Information_Count__c+1;
            else
                ins.CLQ_Event_Information_Count__c = 1;
            InspectionToUpdateMap.put(ins.Id, ins);    
        }
        
        if (!InspectionToUpdateMap.IsEmpty())            
        Update InspectionToUpdateMap.VALUES();
    }
     
    public void InspectionEventCountUpdate(map <Id, Event > triggerMap) {

        set < Id > InspectionIdSet = new set < Id > ();
        Map < Id, CLQ_Inspection__c > InspectionMap = New Map < Id, CLQ_Inspection__c > ();
        Map < Id, CLQ_Inspection__c > InspectionToUpdateMap = New Map < Id, CLQ_Inspection__c > ();

        for (Event et: triggerMap.values()) {
            if (et.WhatId !=null && String.ValueOf(et.WhatId).substring(0, 3) == CLQ_Inspection__c.sobjecttype.getDescribe().getKeyPrefix())
                InspectionIdSet.add(et.WhatId);
        }
        
        for (CLQ_Inspection__c ins: [SELECT Id, Name, CLQ_Event_Information_Count__c FROM CLQ_Inspection__c WHERE Id IN: InspectionIdSet]) {
            if(ins.CLQ_Event_Information_Count__c!=null)
            ins.CLQ_Event_Information_Count__c = ins.CLQ_Event_Information_Count__c-1;
            InspectionToUpdateMap.put(ins.Id, ins);
        }
        
         if (!InspectionToUpdateMap.IsEmpty())
            Update InspectionToUpdateMap.VALUES();
     }
    
    /*****************************************/
    // OJLS-750 : Update Inspection Visit Status from 'To be Scheduled' to 'Scheduled' When a first Visit event is created.
    public void InspectionFirstVisitEvent(list < Event > triggerlist) {

        set < Id > InspectionIdSet = new set < Id > ();
        Map < Id, CLQ_Inspection__c > InspectionMap = New Map < Id, CLQ_Inspection__c > ();
        Map < Id, CLQ_Inspection__c > InspectionToUpdateMap = New Map < Id, CLQ_Inspection__c > ();

        for (Event et: triggerlist) {
            if (et.whatId!=null && String.ValueOf(et.WhatId).substring(0, 3) == CLQ_Inspection__c.sobjecttype.getDescribe().getKeyPrefix())
                InspectionIdSet.add(et.WhatId);
        }

        List < AggregateResult > groupedResults = [SELECT COUNT(Id), WhatId FROM Event WHERE WhatId IN: InspectionIdSet AND Type = 'Visit'
            AND CLQ_Event_Status__c != 'Completed'
            GROUP BY WhatId
        ];
        for (CLQ_Inspection__c ins: [SELECT Id, Name, CLQ_Visit_Status__c FROM CLQ_Inspection__c WHERE Id IN: InspectionIdSet]) {
            InspectionMap.put(ins.Id, ins);
        }

        for (AggregateResult ar: groupedResults) {
            CLQ_Inspection__c TempInspection = new CLQ_Inspection__c();
            TempInspection = InspectionMap.get((Id)(ar.get('WhatId')));
            VisitEventCount = (Integer) ar.get('expr0');
            if (VisitEventCount == 1 && TempInspection.CLQ_Visit_Status__c == 'To be Scheduled')
                TempInspection.CLQ_Visit_Status__c = 'Scheduled';
            InspectionToUpdateMap.put(TempInspection.Id, TempInspection);
        }

        if (!InspectionToUpdateMap.IsEmpty())
            Update InspectionToUpdateMap.VALUES();

    }
    
    // OJLS-854 : Update Total Visit duration time of each inspector on Inspector record for all compeleted Visits assigned to that Inspector
    // 12444 : Updated the method to consider Archived records and update the total duration on inspection and inspector records
    public void InspectorsTotalVisitTime(list < Event > triggerlist) {

        set < Id > InspectionIdSet = new set < Id > ();
        Map < Id, CLQ_Inspector__c > InspectorMap = New Map < Id, CLQ_Inspector__c > ();
        Map < Id, CLQ_Inspector__c > InspectorToUpdateMap = New Map < Id, CLQ_Inspector__c > ();
        Map < Id, CLQ_Inspection__c > InspectionToUpdateMap = New Map < Id, CLQ_Inspection__c > ();
        Map <Id, Decimal> MaptoUpdateownerDuration = New Map <Id, Decimal> ();
        Map <Id, Decimal> MaptoUpdateInspectionDuration = New Map <Id, Decimal> ();
        Map<Id,String> eveOwnerIdNameMap = new Map<Id,String>();
        
        for (Event et: triggerlist) {
            if (et.WhatId!=null && String.ValueOf(et.WhatId).substring(0, 3) == CLQ_Inspection__c.sobjecttype.getDescribe().getKeyPrefix())
                InspectionIdSet.add(et.WhatId);
        }
        system.debug('InspectionIdSet***'+InspectionIdSet);
        
        if(!InspectionIdSet.isEmpty()){
            List <Event> EventList  = [SELECT DurationInMinutes , OwnerId , WhatId from Event  WHERE WhatId IN: InspectionIdSet AND Type = 'Visit'
                                                      AND CLQ_Event_Status__c = 'Completed' AND IsDeleted=false ALL ROWS ];            
            for(Event e: EventList){
                if(MaptoUpdateownerDuration.containsKey(e.OwnerId)){
                    Decimal ownerDuration = MaptoUpdateownerDuration.get(e.OwnerId) + e.DurationInMinutes;
                    MaptoUpdateownerDuration.put(e.OwnerId, ownerDuration);
                }else{
                    MaptoUpdateownerDuration.put(e.OwnerId, e.DurationInMinutes);                        
                }
                
                if(MaptoUpdateInspectionDuration.containsKey(e.WhatId)){
                    Decimal inspectionDuration = MaptoUpdateInspectionDuration.get(e.WhatId) + e.DurationInMinutes ;
                    MaptoUpdateInspectionDuration.put(e.WhatId ,inspectionDuration);
                }else{
                    MaptoUpdateInspectionDuration.put(e.WhatId ,e.DurationInMinutes );
                }        
            }
        
            for(Id insp : MaptoUpdateInspectionDuration.keySet() ){
                CLQ_Inspection__c tempInspection = new CLQ_Inspection__c(id=(ID)insp);
                tempInspection.CLQ_Total_Duration_of_Visits__c =(Decimal) MaptoUpdateInspectionDuration.get(insp);
                InspectionToUpdateMap.put(tempInspection.Id,tempInspection);
                System.debug('Inspection to be updated : ' + tempInspection );
                System.debug('Duration will update to ' + tempInspection.CLQ_Total_Duration_of_Visits__c);
            }
                
            for (CLQ_Inspector__c ins: [SELECT Id, Name, CLQ_Inspection__c, CLQ_Inspection__r.CLQ_Visit_status__c, CLQ_Inspector_Name__c, CLQ_Inspector_Name__r.Name, CLQ_Total_Visit_Duration__c 
                                        FROM CLQ_Inspector__c WHERE CLQ_Inspection__c IN: InspectionIdSet]) {
                InspectorMap.put(ins.CLQ_Inspector_Name__c, ins); 
            }
            
            system.debug('InspectorMap***'+InspectorMap);
                
            for (Id owId : MaptoUpdateownerDuration.keySet() ){
                System.debug('Entered here ' + owId);
                CLQ_Inspector__c TempInspector ;
                
                if(InspectorMap.VALUES().size() >0 && InspectorMap.KeySet().CONTAINS(owId)){
                    TempInspector = InspectorMap.get(owId);
                    system.debug('TempInspector***'+TempInspector);
                    InspectorTotalVisitDuration =MaptoUpdateownerDuration.get(owId);
                    string Hours = String.ValueOf(math.floor(InspectorTotalVisitDuration.intValue()/60).intValue());
                    string Minutes = String.ValueOf(math.mod(InspectorTotalVisitDuration.intvalue(),60));
                    string hourdisplay;
                    
                    if(Hours == '1')
                        hourdisplay = ' Hour ';
                    else
                        hourdisplay = ' Hours ';  
                 
                    TempInspector.CLQ_Total_Visit_Duration__c = Hours+ hourdisplay + Minutes +' Minutes';
                    system.debug('TIME@@@'+TempInspector.CLQ_Total_Visit_Duration__c );
                    InspectorToUpdateMap.put(TempInspector.CLQ_Inspector_Name__c, TempInspector);
                }            
            }
            
            try{    
                if (!InspectorToUpdateMap.IsEmpty()){
                    Update InspectorToUpdateMap.values();
                }
                
                if(!InspectionToUpdateMap.IsEmpty()){
                    Update InspectionToUpdateMap.values();
                }
            }catch(Exception e){
                System.Debug('Execption Occured' +e);
                Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_EventTriggerHandler'); 
            }
        }
    }
    //12444 -END

    public void AssignedTo_Rule_For_EventInspection(list < Event > newList, map <Id, Event > oldMap)
    {
        for (Event evnt: newList) 
        {
            Event PRIORVALUE = oldMap.get(evnt.Id);
            if (evnt.CLQ_WhatType__c == 'CLQ_Inspection__c' && string.IsNotBlank(PRIORVALUE.OwnerId) && PRIORVALUE.OwnerId != evnt.OwnerId)
                evnt.AddError('Assigned to cannot be changed.Please cancel the current event and create a new event with new assigned to.');
        }
    }

    public static void SetType(list < Event > newList) {
        for (Event evnt: newList) evnt.CLQ_WhatType__c = GetObjectNameByPrefix(evnt.WhatId);
    }
    public static string GetObjectNameByPrefix(string prefix) {
        if (prefix == null || prefix.length() < 3) return null;
        if (prefix.length() > 3) prefix = prefix.substring(0, 3);

        map < String, Schema.SObjectType > CachedGlobalDescribe = Schema.getGlobalDescribe();
        list<string> sortedlist = new list<string>(CachedGlobalDescribe.keyset());
        sortedlist.sort();
        for (string itemname: sortedlist) {
            Schema.SObjectType tp = CachedGlobalDescribe.get(itemname);
            //system.debug('Searching for: ' + prefix + '   Currently on: ' + tp.getDescribe().getName() + '  with a prefix of ' + tp.getDescribe().getKeyPrefix());
            if (prefix.equals(tp.getDescribe().getKeyPrefix())) return tp.getDescribe().getName();
        }
        return null;
    }

}