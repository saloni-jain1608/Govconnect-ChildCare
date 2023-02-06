/**************************************************************************************************************
** Name             : CLQ_VersionUtility
** Description      : Version utility for Ispection trigger
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version		Description
**------------------------------------------------------------------------------------------------------------
**	Rohit Gowrishetty		5/17/2018		1.1			TFS#12133 : Updated the code to work correctly to copy child relationships when inspection is updated 
**	Rohit Gowrishetty		5/17/2018		1.2			TFS#13407 : Updated the code to not to copy the inspection owner details to the revised inspection  
**	Vijay Gurusamy			8/22/2019		1.3			TFS#15939 : Exclude External Id fields while cloning.
**************************************************************************************************************/
public with sharing class CLQ_VersionUtility {
    
    public static List<RelatedObjects> objectChildren  { get; set; }
    public static String               objectTypeName  { get; set; }
    public static String               objectName      { get; set; }
    public Static String objectID { get; set; }
    public Id sObjectId { get; set; }
    public Id CloneParentId { get; set; } 
    private static SObject headSObject, headClone;
    public static final string CaseNumber=' CaseNumber';
    public static final string Subject=' Subject';
    public static final string Name=' Name';
    public static final string CaseStr='Case';
    public static final string EventStr='Event';
    public static final string TaskStr='Task';
    public static final string OwnerId='OwnerId';
    public static final string Comma=',';
    
    
    // Initialisation method called when the clone plus page is loaded.
    // Use the id page parameter to find out what kind of 
    // object we are trying to clone.
    // Then load the object from the database.
    // Finally call the populateObjectChildren method to      
    public static void initialiseObjectsForCloning(Id VersioningId,String relatedlist) {
        
        // Here we generate a keyprefixmap using the global describe 
        // Then compare that to our object to determine type.  
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        Map<String,String> keyPrefixMap =  new Map<String,String>{};
            if(gd.size()!=0){  
                for(String sObj : gd.keySet()){
                    Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                    keyPrefixMap.put(r.getKeyPrefix(), r.getName());
                }
            }
        
        objectID = VersioningId;
        String objectTypeKey = objectId.subString(0,3);
        if(keyPrefixMap.size()!=0){
            objectTypeName = keyPrefixMap.get(objectTypeKey);
        }
        
        String primaryObjectQueryString = 'SELECT Id, Name FROM '
            + objectTypeName
            + ' WHERE Id = \''
            + objectId
            + '\'';
        
        headSObject = Database.query(primaryObjectQueryString);
        objectName          = '' + headSObject.get('Name');
        populateObjectChildren(relatedlist);    
    }
    
    /*Get all of the children of the current object that have a 
object type contained in the child object types page parameter.
Not restricting the child objects to particular types 
results in unclonable system objects being added to the options, 
which we need to avoid (You will not want to clone these!)
Making these object type choices also allows us 
focus our efforts on the specific kinds of objects 
we want to allow users to clone.  */
    public static void populateObjectChildren(String ChildList) {
        
        objectChildren = new List<RelatedObjects>{};
            List<String> childObjectTypes = new List<String>{};
                
                //read the object types from the page parameter. //12133 - Trimmed the strings to get child from parents
                childObjectTypes.addAll(ChildList.split(','));
        
        //12133 Starts
        List<String> trimChildObjectTypes = new List<String>{}; 
            for(String s : childObjectTypes){
                trimChildObjectTypes.add(s.trim());
            }
        //12133 Ends
        
        // Use the sobjecttype describe method to retrieve all 
        // child relationships for the object to be cloned.    
        Schema.DescribeSObjectResult headDescribe = headsObject.getSObjectType().getDescribe();
        
        List<Schema.ChildRelationship> childRelationships = headDescribe.getChildRelationships(); 
        
        // Iterate through each relationship, and retrieve the related objects.
        string casestr;
        string eventTaskstr;
        for (Schema.ChildRelationship childRelationship : childRelationships) {
            Schema.SObjectType childObjectType = childRelationship.getChildSObject();
            
            // Only retrieve the objects if their type is included in the page argument.          
            if (trimChildObjectTypes.contains(childObjectType.getDescribe().getName())){ //12133
                List<RelatedObjectRow> RelatedObjects = new List<RelatedObjectRow>{};
                    
                    Schema.SObjectField childObjectField =  childRelationship.getField();
                
                string Namefield = Name;  
                if(childObjectType.getDescribe().getName() == CaseStr ){ 
                    Namefield = CaseNumber;
                    casestr= CaseNumber;
                }
                if(childObjectType.getDescribe().getName() == EventStr || childObjectType.getDescribe().getName() == TaskStr ){ 
                    Namefield = Subject; 
                    eventTaskstr=Subject;                
                }
                String relatedChildSObjectsquery = 'SELECT ID,'+ Namefield+' FROM ' 
                    + childObjectType.getDescribe().getName()
                    + ' WHERE '
                    + childObjectField.getDescribe().getName()
                    + ' = \'' 
                    + headsObject.Id
                    + '\''; 
                
                list<SObject> sobjectlist= Database.query(relatedChildSObjectsquery);
                for (SObject childObject :  sobjectlist){
                    RelatedObjects.add(new RelatedObjectRow(childObject));
                }
                
                if (!RelatedObjects.isEmpty()){
                    objectChildren.add(new RelatedObjects(RelatedObjects, childObjectType.getDescribe().getLabelPlural(), childObjectField.getDescribe().getName()));
                }  
            }
        }
        
        
    }
    
    /*Perform the cloning process.
First clone the parent, then all of the child objects. 
Then redirect the user to the new object page.*/
    public static Id doClone(Id sObjectId,String SelfLookupfield,String Statusfield, String IsSnapShotfield){
        
        List<String> sObjectFields = new List<String>{};
            String fields = '';  
        Schema.SObjectType objectType = sObjectId.getSObjectType();
        
        // Get all the fields from the selected object type using 
        // the get describe method on the object type.    
        if(objectType != null){
            for (Schema.SObjectField objField : objectType.getDescribe().fields.getMap().values()){ 
                Schema.DescribeFieldResult fieldDesc = objField.getDescribe();
                if(fieldDesc.isCreateable() && !fieldDesc.isExternalID() && !fieldDesc.isUnique() && fieldDesc.getName()!= OwnerId  ){
                    fields += fieldDesc.getName()+',';
                }
                    
                
            }
        }
        
        // If there are no objects sent into the method, then return an empty list
        
        if(fields.endsWith(Comma)){
            fields = fields.substring(0,fields.lastIndexOf(',')); 
        }
            
        
        string allSObjectFieldsQuery =  'SELECT ' + fields +' FROM ' + objectType.getDescribe().getName() + ' WHERE ID ='+' \''+sObjectId+'\'';
        
        // use the clone method on the generic sObject 
        
        SObject sObjectFromDatabase = Database.query(allSObjectFieldsQuery);        
        sObject clonedSnapshotObject  = sObjectFromDatabase.clone(false,true);
        
        if(SelfLookupfield !=null && Statusfield != null){
            clonedSnapshotObject.put(SelfLookupfield,sObjectId);
            clonedSnapshotObject.put(Statusfield,'Revised');
            clonedSnapshotObject.put(IsSnapShotfield,true);
            clonedSnapshotObject.put('OwnerId', UserInfo.getUserId() ); //13407
            //clonedSnapshotObject.put('CLQ_Inspection_Owner__c', UserInfo.getUserId() ); //13407
        }
        CLQ_Trigger.BypassAllTriggers = true;
        List<sObject> sobjectlist = new List<sObject>();
        if(!sobjectlist.isEmpty()){
            insert clonedSnapshotObject;
        }
        CLQ_Trigger.BypassAllTriggers = false;
        headClone = clonedSnapshotObject ;
        
        /*Method to update child objects with the parent id or to clone them along with new parent. Not applicable for OJLS-683/684/685 currently.
Uncomment this method to update new parent value to the related child objects of old parent*/
        cloneSelectedObjects();  // 12133 - Uncommented the method to work for copying child relationships
        // Method to clone the related child objects to the new inspection record. 
        //cloneSelectedChildObjects();
        return headClone.Id;
    }
    
    /*Clone the selected child objects.
/Associate the cloned objects with the new cloned parent object.*/
    public static void cloneSelectedObjects() {
        
        List<sObject> clonedObjects = new List<sObject>{};
            List<sObject> selectedRelatedObjects;
        list<List<sObject>> clonedObjectsList=new list<List<sObject>>();
        for (RelatedObjects relatedObject : objectChildren){
            selectedRelatedObjects = new List<sObject>{};  
                clonedObjects = new List<sObject>{}; 
                    
                    for (RelatedObjectRow row : relatedObject.objectRows) {
                        if (row.selected){
                            selectedRelatedObjects.add(row.obj);
                        }
                    }
            
            if (!selectedRelatedObjects.isEmpty()) {
                clonedObjects = cloneObjects(selectedRelatedObjects);	
                
                
                for (sObject cloneObj : clonedObjects){
                    //System.debug('Error is here' +'  Parent object '+ relatedObject+ '         ' + relatedObject.relatedFieldName);
                    cloneObj.put(relatedObject.relatedFieldName, headClone.Id);
                }
                
                //CLQ_Trigger.BypassAllTriggers = true;
                clonedObjectsList.add(clonedObjects);
                //insert clonedObjects;
                //CLQ_Trigger.BypassAllTriggers = false;
            }
        }
        if(clonedObjectsList.size()!=0){
            list<sObject> sobjectlist=new list<sObject>();
            for(List<sObject> slist:clonedObjectsList){
                for(sObject s: slist){
                    sobjectlist.add(s);
                }
            }
            
            //if(!sobjectlist.isEmpty()){
                CLQ_Trigger.BypassAllTriggers = true;
                insert sobjectlist;
                CLQ_Trigger.BypassAllTriggers = false;
            //}
            
        }
    }
    
    /*Clone a list of objects to a particular object type
Parameters : List<sObject> sObjects - the list of objects to be cloned 
The sObjects you pass in must include the ID field, 
and the object must exist already in the database, 
otherwise the method will not work.*/
    public static List<sObject> cloneObjects(List<sObject> sObjects){
        Schema.SObjectType objectType;
        if(sObjects.size()!=0){
            objectType = sObjects.get(0).getSObjectType();
        }
        //A list of IDs representing the objects to clone
        List<Id> sObjectIds = new List<Id>{};
            // A list of fields for the sObject being cloned
            List<String> sObjectFields = new List<String>{};
                // A list of new cloned sObjects
                List<sObject> clonedSObjects = new List<sObject>{};
                    
                    //Get all the fields from the selected object type using the get describe method on the object type.    
                    if(objectType != null){
                        for (Schema.SObjectField objField :  objectType.getDescribe().fields.getMap().values()){ 
                            Schema.DescribeFieldResult fieldDesc = objField.getDescribe();
                            /*If the field type is location, then do not include it, otherwise it will cause a soql exception.
Note that excluding the field does not stop the location from being copied to the new cloned object. */
                            // if(fieldDesc.getType() != DisplayType.LOCATION   )
                            //TFS#15939 Exclude ecternal ID field
                            if(fieldDesc.getType() != DisplayType.LOCATION  && (fieldDesc.isCreateable() || fieldDesc.isUpdateable()) && fieldDesc.getName() !=OwnerId &&  !fieldDesc.isExternalID() ){ //13407
                                sObjectFields.add(fieldDesc.Name);
                            }
                        }
                    }
        
        //If there are no objects sent into the method, then return an empty list
        if (sObjects != null || sObjects.isEmpty() || sObjectFields.isEmpty()){
            
            // Strip down the objects to just a list of Ids.
            for (sObject objectInstance: sObjects){
                sObjectIds.add(objectInstance.Id);
            }
            
            /* Using the list of sObject IDs and the object type, we can construct a string based SOQL query  to retrieve the field values of all the objects.*/
            String allSObjectFieldsQuery;
            if(sObjectFields.size()!=0){
                allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0); 
                
                for (Integer i=1 ; i < sObjectFields.size() ; i++){
                    allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
                }
            }
            if(sObjectIds.size()!=0){
                allSObjectFieldsQuery += ' FROM ' + 
                    objectType.getDescribe().getName() + 
                    ' WHERE ID IN (\'' + sObjectIds.get(0) + 
                    '\'';
                
                for (Integer i=1 ; i < sObjectIds.size() ; i++){
                    allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
                }
            }
            
            allSObjectFieldsQuery += ')';
            
            system.debug('allSObjectFieldsQuery: ' + allSObjectFieldsQuery);
            
            try{
                
                /*Execute the query. For every result returned, 
use the clone method on the generic sObject 
and add to the collection of cloned objects*/
                for (SObject sObjectFromDatabase: Database.query(allSObjectFieldsQuery)){
                    sObject cloneObj =  sObjectFromDatabase.clone(false,true);
                    
                    clonedSObjects.add(cloneObj);    // 12133
                }
            } catch (exception e){
                system.debug(e);
            }
            
        }
        
        return clonedSObjects;
    }
    
    /*Related objects data construct - 
used to store a collection of child objects connected to 
the head object through the same relationship field.*/
    public class RelatedObjects{
        public List<RelatedObjectRow> objectRows { get; set; }
        public String                 pluralLabel      { get; set; }
        public String                 relatedFieldName { get; set; }
        
        public RelatedObjects(List<RelatedObjectRow> objectRows,String pluralLabel,String relatedFieldName) {
            this.objectRows       = objectRows;
            this.pluralLabel      = pluralLabel;
            this.relatedFieldName = relatedFieldName;
        }   
    }     
    
    /*An indidual child object row. 
Each instance simply contains the object definition, 
and a checkbox to select the row for cloning on the clone plus page.*/
    public class RelatedObjectRow{
        public sObject obj      { get; set; }
        public Boolean selected { get; set; }
        
        public RelatedObjectRow(Sobject obj) {
            this.obj      = obj;
            // All object rows are selected by default.
            this.selected     = true;
        }
        
        public String getName(){
            try{
                return '' + obj.get('Name');
            } catch (Exception e){
                return '';
            }    
        }   
    }
}