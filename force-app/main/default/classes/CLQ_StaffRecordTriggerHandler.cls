//Class to contains all the method related to CLQ_StaffRecordTrigger
//Developer : Vrajesh Sheth (vsheth@incapsulate.com)
//Date : 09/07/2016
public with sharing class CLQ_StaffRecordTriggerHandler extends CLQ_Trigger  {
    
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
    //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
    public static final string ONSITE_VISIT_PENDING='Onsite Visit Pending';
    public static final string APPROVER_STATE_USER='Approver - State User';
    public static final string SUTQ_REVIEWER_STATE_USER='Lic and SUTQ Reviewer - State User';
    public static final string ODJFS_FCC_APPROVER='ODJFS FCC Approver - State User';
    public static boolean BypassTrigger {
        get {
            if (BypassTrigger == null){
                BypassTrigger = false;
            } 
            return BypassTrigger;
        }
        set;
    }
    
    static boolean HasUpdated;
    public override boolean getUpdateFlag()                 {   return HasUpdated;    }
    public override void setUpdateFlag(boolean newVal)      {   HasUpdated = newVal;    }
    
    //Calls the Base class Constructor
    public CLQ_StaffRecordTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
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
    
    //after insert logic method
    //@param : triggernew, triggernewmap
    //@return : null
    public override void afterinsert() {
    	//Mod by LD on 12/16/16 - Commented out the below line that creates a ContactRole when a Staff Record is created based on a changed requirement.
        //onafterinsert((list<CLQ_Staff_Record__c>) newlist, (map<id,CLQ_Staff_Record__c>) newMap);
    }
    
    //after update logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterupdate() {
    	//Mod by LD on 12/16/16 - Commented out the below line that creates a ContactRole when a Staff Record is updated based on a changed requirement.
        //onafterupdate((list<CLQ_Staff_Record__c>) oldlist, (map<id,CLQ_Staff_Record__c>) oldMap,(list<CLQ_Staff_Record__c>) newlist, (map<id,CLQ_Staff_Record__c>) newMap);
    }
    //before delete added by Vamshi Panuganti 
    // If the status of the program transaction is Onsite Visit Peding then certain profiles not allowed to delete the staff records manually.
     public override void beforedelete() {
        onbeforedelete((list<CLQ_Staff_Record__c>) oldlist);
        }
     public void onbeforedelete(list<CLQ_Staff_Record__c> oldlist)
     {
     Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
     system.debug('Profile name::::::::'+ProfileName);
     List<Id> staffIds = new List<Id>();
      for(CLQ_Staff_Record__c cr:oldlist){
          staffIds.add(cr.Id);
      }
         Map<Id,CLQ_Staff_Record__c> staffMap;
         if(staffIds != null){
             staffMap = new Map<Id,CLQ_Staff_Record__c> ([SELECT Id,CLQ_Program_Transaction__r.CLQ_Transaction_Status__c from CLQ_Staff_Record__c WHERE Id IN :staffIds]);
         }
         
    for(CLQ_Staff_Record__c cr:oldlist){
    //system.debug('Status ::::::::'+staffMap.get(cr.Id).CLQ_Program_Transaction__r.CLQ_Transaction_Status__c);
          if(staffMap.size()!=0 && staffMap.get(cr.Id)!=null && staffMap.get(cr.Id).CLQ_Program_Transaction__r.CLQ_Transaction_Status__c ==ONSITE_VISIT_PENDING 
          && (ProfileName.Name==APPROVER_STATE_USER || ProfileName.Name==SUTQ_REVIEWER_STATE_USER || ProfileName.Name==ODJFS_FCC_APPROVER))
          {             
             cr.addError('Deletion of staff record is not allowed');
            
          }     
         }
     }
    
    //Method to call on afterinsert 
   /* public void onafterinsert(list<CLQ_Staff_Record__c> triggernew, map<id,CLQ_Staff_Record__c> triggernewMap){
        list<id> insertedstaffrecordidlist = new list<id>();
        list<id> contactIDlist = new list<id>();
        for(CLQ_Staff_Record__c staffrecord : triggernew){
            insertedstaffrecordidlist.add(staffrecord.id);
            contactIDlist.add(staffrecord.CLQ_Name__c);
        }
        insertSaffContactRole(insertedstaffrecordidlist,contactIDlist);
    }
    
    //Method to call on afterupdate
    public void onafterupdate(list<CLQ_Staff_Record__c> triggerold, map<id,CLQ_Staff_Record__c> triggeroldMap,list<CLQ_Staff_Record__c> triggernew, map<id,CLQ_Staff_Record__c> triggernewMap){
        list<id> insertedstaffrecordidlist = new list<id>();
        list<id> contactIDlist = new list<id>();
        for(CLQ_Staff_Record__c staffrecord : triggernew){
            if(staffrecord.CLQ_Name__c != null 
            && staffrecord.CLQ_Name__c != (triggeroldMap.get(staffrecord.id).CLQ_Name__c)){
                insertedstaffrecordidlist.add(staffrecord.id);
                contactIDlist.add(staffrecord.CLQ_Name__c);
            }
            
        }
        insertSaffContactRole(insertedstaffrecordidlist,contactIDlist);
    }
    
    //logic to insert contact role of staff for given staff record
    public static void insertSaffContactRole(list<id> staffrecordIDlist,list<id> contactIDset){
        
        //Query staff record informaton
        map<id,CLQ_Staff_Record__c> staffrecordmap = new map<id,CLQ_Staff_Record__c>([SELECT id
                                                                                            ,CLQ_Name__c
                                                                                            ,CLQ_Hire_Date__c
                                                                                            ,CLQ_Inspection__c
                                                                                            ,CLQ_Inspection__r.CLQ_Program__c
                                                                                    FROM CLQ_Staff_Record__c
                                                                                    WHERE id in :staffrecordIDlist]);
        
        //Query exsting Staff Role record
        list<CLQ_Role__c> existingRoleList = new list<CLQ_Role__c>();
        existingRoleList = [SELECT  id
                                    ,CLQ_Contact__c
                                    ,CLQ_Program__c
                                    ,CLQ_Role__c
                            FROM CLQ_Role__c 
                            WHERE CLQ_Contact__c in :contactIDset
                            AND CLQ_Role__c = 'Staff'];
        //CreateMap of existing record 
        map<string,CLQ_Role__c> existingStaffRoleKeyRecordMap = new map<string,CLQ_Role__c>();
        for(CLQ_Role__c existingRecord : existingRoleList){
            existingStaffRoleKeyRecordMap.put(String.valueof(existingRecord.CLQ_Contact__c) + String.valueof(existingRecord.CLQ_Program__c) , existingRecord);
        }
        
        //list to store new contact role
        list<CLQ_Role__c> contactRoleToInsert = new list<CLQ_Role__c>();
        for(CLQ_Staff_Record__c staffRecord : staffrecordmap.values()){
            if(existingStaffRoleKeyRecordMap.get(String.valueof(staffRecord.CLQ_Name__c)+String.valueof(staffRecord.CLQ_Inspection__r.CLQ_Program__c)) == null){
                contactRoleToInsert.add(new CLQ_Role__c(CLQ_Contact__c = staffRecord.CLQ_Name__c
                                                    ,CLQ_Program__c = staffRecord.CLQ_Inspection__r.CLQ_Program__c
                                                    ,CLQ_Start_Date__c = staffRecord.CLQ_Hire_Date__c
                                                    ,CLQ_Role__c = 'Staff'
                                                    ,recordTypeid = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByName().get('Program Role').getRecordTypeId()
                                                    ,CLQ_Status__c = 'Approved'));
                                                    
            }
            
        }
        
        insert contactRoleToInsert; 
        
    }*/
}