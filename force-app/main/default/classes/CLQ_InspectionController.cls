public with sharing class CLQ_InspectionController {
    
    public boolean CanEdit {get;set;}
    
    public CLQ_InspectionController(ApexPages.StandardController controller) {
        CanEdit = false;
         CLQ_Inspection__c inspectionRecord = [SELECT OwnerId FROM CLQ_Inspection__c WHERE ID = :controller.getId() LIMIT 1]; 
                
        Id CurrentUserId = UserInfo.GetUserId();
        if (inspectionRecord.OwnerId == CurrentUserId)
        {
            CanEdit = true;
            return;
        }
            
        User CurrUser = [Select Profile.Name FROM User Where Id = :CurrentUserId];
        string ProfileName = CurrUser.Profile.Name;
        System.debug('ProfileName==>'+ProfileName);
        Global_Settings__c GlobalSettings = Global_Settings__c.GetInstance();
       System.debug('GlobalSettings'+GlobalSettings);
       
        if ((GlobalSettings.Can_Edit_Closed_Programs__c!= null && GlobalSettings.Can_Edit_Closed_Programs__c.Contains(ProfileName)) || (GlobalSettings.Can_Edit_Closed_Programs2__c!=null && GlobalSettings.Can_Edit_Closed_Programs2__c.Contains(ProfileName)))
        {
            CanEdit = true;
            return;
        }       
        list<CLQ_Inspector__c> Inspectors = [Select Id, CLQ_Inspector_Name__c FROM CLQ_Inspector__c WHERE CLQ_Inspection__c = :controller.getId()];   
        for(CLQ_Inspector__c Inspector : Inspectors)
        {
            if (CurrentUserId == Inspector.CLQ_Inspector_Name__c)
            {
                CanEdit = true;
                return;
            }
     
        }
           
        
    }
}