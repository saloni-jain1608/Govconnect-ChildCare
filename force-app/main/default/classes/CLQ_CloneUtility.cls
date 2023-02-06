// This class Clones a vertsion of the Program Transaction for Applications that have been modified.
//Keeps trace of the related list without needing to create a massive number of duplicate records

public with sharing class CLQ_CloneUtility {
    
    public static final String Application_Revised = 'Application Revised';
    public static final string CaseStr='Case';
    public static final string EventStr='Event';
    public static final string TaskStr='Task';
    public static final string Remove='Remove';
    public static final string Add='Add';
    
    public static CLQ_Program_Transaction__c CloneProgramTransaction(CLQ_Program_Transaction__c Exiting, Id RelatedRecord, Id OriginalRelatedRecord)
    {        
        map<id,CLQ_Program_Transaction__c> RetMap = RelatedItems(new list<Id>{Exiting.Id}); 
        
        CLQ_Program_Transaction__c RelatedItem;                    
        if (RetMap.IsEmpty()) {return null;}
        if(RetMap.size()!=0){
            RelatedItem = RetMap.get(Exiting.Id);
        }
        string Revision_Related_Records = JSON.serialize(RelatedItem);
        
        if (string.IsNotBlank(RelatedRecord) && string.IsNotBlank(OriginalRelatedRecord))
        {
            Revision_Related_Records = Revision_Related_Records.replace(OriginalRelatedRecord, RelatedRecord);
        }
        system.debug(Revision_Related_Records);
        
        CLQ_Program_Transaction__c clone = (CLQ_Program_Transaction__c)Exiting.Clone(false, true, true, true);
        clone.CLQ_Revision_Related_Records__c = Revision_Related_Records;
        clone.CLQ_Transaction_Status__c = Application_Revised;
        clone.CLQ_Original_Program_Transaction__c = Exiting.Id;
        clone.CLQ_Revision_Transaction_Status__c = Exiting.CLQ_Transaction_Status__c;
        clone.CLQ_External_Id__c = null;
        return clone;
    }
    
    public static CLQ_Program_Transaction__c DeserializeRelatedLists(CLQ_Program_Transaction__c ClonedItem)
    {
        if (ClonedItem == null){return null;}
        string JSONString = ClonedItem.CLQ_Revision_Related_Records__c;
        if (string.IsBlank(JSONString))
        {
            system.debug('DeserializeRelatedLists: WAS NULL');
            return null;
        }
        CLQ_Program_Transaction__c RelatedItems = (CLQ_Program_Transaction__c)JSON.deserialize(ClonedItem.CLQ_Revision_Related_Records__c, CLQ_Program_Transaction__c.class);
        system.debug('DeserializeRelatedLists: ' + RelatedItems);
        
        return RelatedItems;
    }    
    
    public static map<string, list<sObject>> QueryRelatedLists(CLQ_Program_Transaction__c ClonedItem)
    {
        map<string, list<sObject>> RelatedItems = new map<string, list<sObject>>();
        RelatedItems.put('Associated Individuals',new list<CLQ_Role__c>());
        RelatedItems.put('Inspections',new list<CLQ_Inspection__c>());
        RelatedItems.put('Facility Schedules',new list<CLQ_Facility_Schedule__c>());
        //RelatedItems.put('Payments Received',new list<CLQ_Payment_Received__c>());
        RelatedItems.put('Transaction Documents',new list<CLQ_Transaction_Document__c>());
        RelatedItems.put('Rules Inspected',new  list<CLQ_Rules_Inspected__c>());
        RelatedItems.put('Program Transactions',new list<CLQ_Program_Transaction__c>());
        
        if (ClonedItem == null) {
            return RelatedItems;
        }
        else{
            list<CLQ_Role__c> Roles;
            if(ClonedItem.Roles__r != null){
                Roles = [SELECT Name, CLQ_Contact__c,CLQ_Status__c,CLQ_Start_Date__c,CLQ_End_Date__c, CLQ_Program_Transaction_Source__c
                         FROM CLQ_Role__c WHERE Id In :ClonedItem.Roles__r];
            }
            RelatedItems.put('Associated Individuals',Roles);
            //------------------------
            list<CLQ_Inspection__c> Inspections;
            if(ClonedItem.Inspections__r != null){
                Inspections = [SELECT Name,RecordType.Name, CLQ_Inspection_Due_Date__c,CLQ_Program_Transaction__c,
                               CLQ_Inspection_Notice__c, CLQ_Inspection_Status__c
                               FROM CLQ_Inspection__c WHERE Id In :ClonedItem.Inspections__r];
            }
            
            RelatedItems.put('Inspections',Inspections);
            //------------------------Inspections__r
            list<CLQ_Facility_Schedule__c> Facility_Schedules;
            if(ClonedItem.Facility_Schedules__r != null){
                Facility_Schedules = [SELECT Name,CLQ_Program_Transaction__c
                                      FROM CLQ_Facility_Schedule__c WHERE Id In :ClonedItem.Facility_Schedules__r];
            }
            RelatedItems.put('Facility Schedules',Facility_Schedules);
            //------------------------
            /*list<CLQ_Payment_Received__c> Payments_Received;
if(ClonedItem.Payments_Received__r!=null){
Payments_Received = [SELECT Name,CLQ_Program_Transaction__c
FROM CLQ_Payment_Received__c WHERE Id In :ClonedItem.Payments_Received__r];
}

RelatedItems.put('Payments Received',Payments_Received);*/
            //------------------------
            list<CLQ_Transaction_Document__c> Transaction_Documents;
            if(ClonedItem.Transaction_Documents__r!=null){
                Transaction_Documents = [SELECT Name,CLQ_Document_Status__c,CLQ_Document_Comments__c,
                                         CLQ_Submission_Date__c,CLQ_Program_Transaction__c
                                         FROM CLQ_Transaction_Document__c WHERE Id In :ClonedItem.Transaction_Documents__r];
            }
            
            RelatedItems.put('Transaction Documents',Transaction_Documents);
            //------------------------
            list<CLQ_Rules_Inspected__c> Rules_Inspected;
            if(ClonedItem.Rules_Inspected__r!=null){
                Rules_Inspected = [SELECT Name,CLQ_Inspection_No__c,CLQ_Room_Space__c,CLQ_Risk_Points__c,
                                   CLQ_Result__c,CLQ_Description_Comments__c,ProgramTransaction__c
                                   FROM CLQ_Rules_Inspected__c WHERE Id In :ClonedItem.Rules_Inspected__r];
            }
            
            RelatedItems.put('Rules Inspected',Rules_Inspected);
            //------------------------
            list<CLQ_Program_Transaction__c> Program_Transactions;
            if(ClonedItem.Program_Transactions__r!=null){
                Program_Transactions = [SELECT RecordType.Name, RecordTypeId, Name, 
                                        CLQ_Transaction_Status__c, CLQ_Submitter__r.Name,  
                                        CLQ_Submission_Date__c, CLQ_Program__c,
                                        CLQ_Original_Program_Transaction__c
                                        From CLQ_Program_Transaction__c 
                                        WHERE Id In :ClonedItem.Program_Transactions__r];
            }
            
            RelatedItems.put('Program Transactions',Program_Transactions);
        }
        
        return RelatedItems;
    }
    
    public static CLQ_Program_Transaction__c CancelRevision(CLQ_Program_Transaction__c CurrentVersion)
    {
        string PreviousQuery = CLQ_UtilityClass.createSOQLQuery('CLQ_Program_Transaction__c',  
                                                                ' CLQ_Original_Program_Transaction__c = \'' + CurrentVersion.Id + 
                                                                '\' AND CLQ_Transaction_Status__c = \'Application Revised\'' +
                                                                ' ORDER By CreatedDate Desc LIMIT 1', null);
        List<sObject> sobjList = Database.query(PreviousQuery);
        if (sobjList.IsEmpty()) {return null;}
        CLQ_Program_Transaction__c PreviousRevision = (CLQ_Program_Transaction__c)sobjList[0];
        map<id,CLQ_Program_Transaction__c> RelatedLists = RelatedItems(new list<id>{CurrentVersion.Id, PreviousRevision.Id});
        
        //Sets the field values back to the previous version
        set<string> ModifiedFields = ResetModifiedFields(CurrentVersion, PreviousRevision);
        CurrentVersion.CLQ_Original_Program_Transaction__c = null;
        CurrentVersion.CLQ_Transaction_Status__c = PreviousRevision.CLQ_Revision_Transaction_Status__c;
        set<string> ModifiedLists = ResetRelatedLists(CurrentVersion.Id,PreviousRevision, RelatedLists);
        return CurrentVersion;
    }        
    
    
    public static CLQ_Program_Transaction__c RelatedItems(id ExistingId)
    {
        return RelatedItems(new list<Id>{ExistingId}).values()[0];
    }
    public static map<id,CLQ_Program_Transaction__c> RelatedItems(list<id> ExistingId)
    {
        map<id,CLQ_Program_Transaction__c> RelatedItemsMap = new map<id,CLQ_Program_Transaction__c>();
        if(ExistingId!=null){
            RelatedItemsMap = new map<id,CLQ_Program_Transaction__c>(
                [Select Id,
                 ( SELECT ID,Name,Program_Transaction__c FROM Answers__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Facility_Schedules__r LIMIT 1999),
                 ( SELECT ID,Name,Program_Transaction__c FROM Findings__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Inspections__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Corresponding_Program_Transaction__c FROM ProgramMessage__r LIMIT 1999),
                 ( SELECT ID,Name,Program_Transaction__c FROM Messages__r LIMIT 1999),
                 //( SELECT ID,Name,CLQ_Program_Transaction__c FROM Payments_Received__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Original_Program_Transaction__c FROM Program_Transactions__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction_Source__c FROM Roles__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Rooms_Spaces_Inspection__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Rooms_Spaces__r LIMIT 1999),
                 ( SELECT ID,Name,ProgramTransaction__c FROM Rules_Inspected__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Staff_Records__r LIMIT 1999),
                 ( SELECT ID,Name,CLQ_Program_Transaction__c FROM Transaction_Documents__r LIMIT 1999),
                 ( SELECT ID,Subject,WhatId FROM Events LIMIT 1999),
                 ( SELECT ID,Subject,WhatId FROM Tasks LIMIT 1999)
                 From CLQ_Program_Transaction__c 
                 WHERE Id IN: ExistingId]);  //20 Children relations at a time
        }
        
        return RelatedItemsMap;
        
    }
    
    
    //These values are either readonly, or are ok for the update. FYI - Please add the field name in lowercase only - MP
    //Ownerid field name added - MP - 1111
    private static set<string> SkipTheseItems = new set<string>{'id', 'isdeleted', 'name', 'createdby', 'lastmodifiedby',
        'recordtype','createddate', 'lastmodifieddate', 'createdbyid', 'lastmodifiedbyid',
        'systemmodstamp', 'lastactivitydate', 'lastvieweddate', 'lastreferenceddate', 'ownerid'} ;
            public static set<string> ResetModifiedFields(CLQ_Program_Transaction__c NewRecord, CLQ_Program_Transaction__c OldRecord)
        {
            set<string> Modified = new set<string>();
            // Get the field describe result for the Name field on the Account object
            map<string, Schema.SObjectField> FieldMap = Schema.sObjectType.CLQ_Program_Transaction__c.fields.getmap();
            if(FieldMap.size()!=0){
                for(string FieldName : FieldMap.KeySet())
                {
                    if (!SkipTheseItems.contains(FieldName))
                    {
                        Schema.DescribeFieldResult dfr = FieldMap.get(FieldName).getDescribe();
                        //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                        if (dfr.isUpdateable() && (NewRecord.get(FieldName) != OldRecord.get(FieldName)))
                        {
                            system.debug('FindModifiedFields: ' + FieldName + ' New: ' + NewRecord.get(FieldName) + ' Old: ' + OldRecord.get(FieldName));
                            Modified.Add(dfr.getName());
                            NewRecord.put(FieldName, OldRecord.get(FieldName));
                        }
                    }
                }
            }
            return Modified;
        }
    public static set<string> FindModifiedFields(CLQ_Program_Transaction__c NewRecord, CLQ_Program_Transaction__c OldRecord)
    {
        set<string> Modified = new set<string>();
        // Get the field describe result for the Name field on the Account object
        map<string, Schema.SObjectField> FieldMap = Schema.sObjectType.CLQ_Program_Transaction__c.fields.getmap();
        if(FieldMap.size()!=0){
            for(string FieldName : FieldMap.KeySet())
            {
                if (!SkipTheseItems.contains(FieldName))
                {
                    Schema.DescribeFieldResult dfr = FieldMap.get(FieldName).getDescribe();
                    //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                    if (dfr.isUpdateable() && (NewRecord.get(FieldName) != OldRecord.get(FieldName)))
                    {
                        system.debug('FindModifiedFields: ' + FieldName + ' New: ' + NewRecord.get(FieldName) + ' Old: ' + OldRecord.get(FieldName));
                        Modified.Add(dfr.getName());
                    }
                }
            }
        }
        return Modified;
    }            
    public static map<string, string> FindModifiedFieldsRoomSpaceTrans(CLQ_Room_Space_Transaction__c NewRecord, CLQ_Room_Space_Transaction__c OldRecord)
    {
        set<string> SkipTheseAdditionalItems = new set<string>{'clq_formatted_change_table__c'} ;
            
            map<string, string> modifiedHtmlMap = new map<string, string>();
        // Get the field describe result for the Name field on the Account object
        map<string, Schema.SObjectField> FieldMap = Schema.sObjectType.CLQ_Room_Space_Transaction__c.fields.getmap();
        if(FieldMap.size()!=0){
            for(string FieldName : FieldMap.KeySet())  
            {
                if (!SkipTheseItems.contains(FieldName) && !SkipTheseAdditionalItems.contains(FieldName))
                {
                    Schema.DescribeFieldResult dfr = FieldMap.get(FieldName).getDescribe();
                    //system.debug('FindModifiedFields: ' + FieldName + ' = ' + dfr.isUpdateable());
                    if (dfr.isUpdateable() && (NewRecord.get(FieldName) != OldRecord.get(FieldName)))
                    {
                        system.debug('FindModifiedFields: ' + FieldName + ' New: ' + NewRecord.get(FieldName) + ' Old: ' + OldRecord.get(FieldName));
                        modifiedHtmlMap.put(dfr.getLabel(),  '<tr> <td> ' + dfr.getLabel() + '</td> <td>' + OldRecord.get(FieldName)+ '</td> <td>' + NewRecord.get(FieldName) + '</td> </tr>') ;
                    }
                }
            }
        }
        return modifiedHtmlMap;
    }     
    
    public static set<string> ResetRelatedLists(Id NewRecordId, CLQ_Program_Transaction__c PreviousRecord, map<id,CLQ_Program_Transaction__c> RelatedLists)
    {
        set<string> Modified = new set<string>();
        CLQ_Program_Transaction__c CurrentList;
        CLQ_Program_Transaction__c OldList;
        if(RelatedLists.size()!=0){
            CurrentList = RelatedLists.get(NewRecordId);
            OldList = RelatedLists.get(PreviousRecord.Id);
        }
        
        system.debug('ResetRelatedLists:PreviousRecord ' + PreviousRecord);
        system.debug('ResetRelatedLists:OldList ' + OldList);
        
        //(Select Id From Tasks LIMIT 100), 
        map<string, list<sObject>> AddAndRemove = FixList(CurrentList.Tasks, PreviousRecord.Tasks, OldList.Tasks);
        if(AddAndRemove.size()!=0){
            if (AddAndRemove.get(Remove).size() > 0){
                delete AddAndRemove.get(Remove);
            } 
            if (AddAndRemove.get(Add).size() > 0){
                ReAdd('WhatId', AddAndRemove.get(Add), NewRecordId);
            } 
            //(Select Id From OpenActivities LIMIT 100), 
            //(Select Id From NotesAndAttachments LIMIT 100), 
            //(Select Id From Events LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Events, PreviousRecord.Events, OldList.Events);
            if (!AddAndRemove.get(Remove).isEmpty()) {
                delete AddAndRemove.get(Remove);
            }
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('WhatId', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Transaction_Documents__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Transaction_Documents__r, PreviousRecord.Transaction_Documents__r, OldList.Transaction_Documents__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Staff_Records__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Staff_Records__r, PreviousRecord.Staff_Records__r, OldList.Staff_Records__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Rules_Inspected__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Rules_Inspected__r, PreviousRecord.Rules_Inspected__r, OldList.Rules_Inspected__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('ProgramTransaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Rooms_Spaces__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Rooms_Spaces__r, PreviousRecord.Rooms_Spaces__r, OldList.Rooms_Spaces__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Rooms_Spaces_Inspection__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Rooms_Spaces_Inspection__r, PreviousRecord.Rooms_Spaces_Inspection__r, OldList.Rooms_Spaces_Inspection__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Roles__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Roles__r, PreviousRecord.Roles__r, OldList.Roles__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction_Source__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Program_Transactions__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Program_Transactions__r, PreviousRecord.Program_Transactions__r, OldList.Program_Transactions__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Original_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Payments_Received__r LIMIT 100), 
            //AddAndRemove = FixList(CurrentList.Payments_Received__r, PreviousRecord.Payments_Received__r, OldList.Payments_Received__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Messages__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Messages__r, PreviousRecord.Messages__r, OldList.Messages__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From ProgramMessage__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.ProgramMessage__r, PreviousRecord.ProgramMessage__r, OldList.ProgramMessage__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Corresponding_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Inspections__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Inspections__r, PreviousRecord.Inspections__r, OldList.Inspections__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Findings__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Findings__r, PreviousRecord.Findings__r, OldList.Findings__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Facility_Schedules__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Facility_Schedules__r, PreviousRecord.Facility_Schedules__r, OldList.Facility_Schedules__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('CLQ_Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From Answers__r LIMIT 100), 
            AddAndRemove = FixList(CurrentList.Answers__r, PreviousRecord.Answers__r, OldList.Answers__r);
            if (!AddAndRemove.get(Remove).isEmpty()) {delete AddAndRemove.get(Remove);}
            if (AddAndRemove.get(Add).size() > 0) {ReAdd('Program_Transaction__c', AddAndRemove.get(Add), NewRecordId);}
            //(Select Id From ActivityHistories LIMIT 100) 
            //
        }
        
        return Modified;
    }          
    
    public static void ReAdd(string FieldName, list<sObject> ToReference, Id TransactionId)
    {
        for(sobject sobj : ToReference){
            sobj.put(FieldName, TransactionId);
        }
        if(!ToReference.isEmpty()){
            update ToReference;
        }
        
    }
    
    public static map<string, list<sObject>> FixList(list<sObject> Current, list<sObject> Revision, list<sObject> Previous)
    {
        map<string, list<sObject>> Updates = new map<string, list<sObject>>{'Add' => new list<sObject>(), 'Remove' => new list<sObject>() };
            if (Current.IsEmpty())
        {
            if(Revision.IsEmpty())
            {
                
                if(Previous.IsEmpty()) {return updates;} //No changes
                else{
                    Updates.put('Add',  Previous);
                } 
            }
            else
            {
                
                map<Id, sObject> RevisionMap = new map<Id, sObject>(Revision);
                for(sObject sobj : Previous) RevisionMap.put(sobj.Id, sobj);
                Updates.put('Add', RevisionMap.values()); //Add all these to the current version
            }
        }
        else
        {
            map<Id, sObject> CurrentMap = new map<Id, sObject>(Current);
            if(Revision.IsEmpty())
            {
                if(Previous.IsEmpty()) {return updates;} //No changes
                else
                {
                    system.debug('FixList Section 3');
                    //If the Id is in both maps, remove it (doesn't need changed)
                    // The leftover in Current need to be delted
                    // the leftover in Previous need to be redirected to current version
                    map<Id, sObject> PreviousMap = new map<Id, sObject>(Previous);
                    for(Id ObjId : PreviousMap.keySet())
                    {
                        if (CurrentMap.ContainsKey(ObjId))
                        {
                            CurrentMap.remove(ObjId);
                            PreviousMap.remove(ObjId);
                        }
                    }
                    Updates.put('Add', PreviousMap.values()); //Add all these to the current version
                    Updates.put('Remove', CurrentMap.values()); //Remove all these from the current version
                }
            }
            else
            {
                system.debug('FixList Section 4');
                map<Id, sObject> CombinedMap = new map<Id, sObject>(Revision);
                for(sObject sobj : Previous) CombinedMap.put(sobj.Id, sobj);
                for(Id ObjId : CombinedMap.keySet())
                {
                    if (CurrentMap.ContainsKey(ObjId))
                    {
                        CurrentMap.remove(ObjId);
                        CombinedMap.remove(ObjId);
                    }
                }
                Updates.put('Add', CombinedMap.values()); //Add all these to the current version
                Updates.put('Remove', CurrentMap.values()); //Remove all these from the current version
            }
        }
        return Updates;
    }    
    
    
    public static string RelatedItemsQuery
    {
        get
        {
            if (RelatedItemsQuery == null)
            {
                RelatedItemsQuery = '[Select Id,Name, ' + BuildQuery() + ' From CLQ_Program_Transaction__c ';
            }
            return RelatedItemsQuery;
        }
        private set;
    }
    
    //Builds the query for  the related lists
    public static string BuildQuery() {
        
        //These Objects are the items we want for the Related ITems
        set<string> RelatedObjects = new set<string>{'Task', 'Event', 'CLQ_Transaction_Document__c', 'CLQ_Staff_Record__c', 
            'CLQ_Rules_Inspected__c','CLQ_Room_Space__c', 'CLQ_Room_Space_Inspection__c', 'CLQ_Role__c', 'CLQ_Program_Transaction__c',
            // 'CLQ_Payment_Received__c',
            'CLQ_Message__c', 'CLQ_Inspection__c', 'CLQ_Findings__c', 'CLQ_Facility_Schedule__c', 'Answer__c'} ;
                list < String > ChildObjectQueries = new list < String > {};
                    
                    Schema.DescribeSObjectResult PTDescribe = CLQ_Program_Transaction__c.getSObjectType().getDescribe();
        
        list < Schema.ChildRelationship > RelatedRelationships = PTDescribe.getChildRelationships();
        
        for (Schema.ChildRelationship RelatedRelationship: RelatedRelationships) {
            Schema.SObjectType childType = RelatedRelationship.getChildSObject();
            if (!RelatedObjects.contains(childType.getDescribe().getName())) {continue;}
            
            Schema.SObjectField childObjectField = RelatedRelationship.getField();
            string RelName = RelatedRelationship.getRelationshipName();
            if (RelName == null) {Continue;}
            string FieldName = childType.getDescribe().getName();
            system.Debug('Name ' + FieldName + '   RelationshipName ' + RelName);
            //system.Debug('RelatedRelationship ' + RelatedRelationship);
            //system.Debug('childObjectField ' + childObjectField);
            system.Debug('childType ' + childType);
            string Namefield = 'Name';
            if (childType.getDescribe().getName() == CaseStr){
                Namefield = 'CaseNumber';}
            else if (childType.getDescribe().getName() == EventStr || childType.getDescribe().getName() == TaskStr){
                Namefield = 'Subject';}
            
            String RelatedListSObjectSubQuery =
                '( SELECT ID,' + Namefield + ',' + childObjectField + ' FROM ' + RelName + ')';
            ChildObjectQueries.Add(RelatedListSObjectSubQuery);
            
        }
        
        return string.join(ChildObjectQueries,',\n');
    }    
}