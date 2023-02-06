/**************************************************************************************************************
** Name             : CLQ_CreateOnsiteVisitInspectionExtn
** Description      : This class/extension contains all detail logic/methods for CLQ_CreateOnsiteVisitInspection pages.
                    It will create a new OnSite inspection record from program transaction.
** Assumptions      : 
** Version          : 1.4
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer					Date				Version		Description
**------------------------------------------------------------------------------------------------------------
**	DevTeam						Nov-2016			1.0			Created
**	Ramana Gurivelli			07/05/2017			1.1			CR# 11199: Updated to set inspection owner as loggedin user.
**	Neetu Ojha					12/12/2017			1.2			TFS#11867 : Inspection status update
**	Pradeep Ravi				03/26/2018			1.3			TFS#11949 : Updating Inspection IRN from Prog
**	Neetu Ojha					04/25/2018			1.4			TFS#12102 : Inspection Type Update
** Rohit Gowrishetty			02/08/2019			1.5			TFS#15575 : Added logic to update county onto the Insp
**************************************************************************************************************/
public with sharing class CLQ_CreateOnsiteVisitInspectionExtn{
    //variables
    
    public CLQ_Program_Transaction__c programTransactionRecord;
     public static Map<String, String> CLQCreateOnsiteValueMap = new  Map<String, String>();
    

    public CLQ_CreateOnsiteVisitInspectionExtn(ApexPages.StandardController controller) {
        list<String> fieldlist;
        fieldlist = new list<String>{'CLQ_Program__r.CLQ_BIRN__c','CLQ_Program__r.Id','OwnerId', 'Program_Transaction_County__c'}; // 15575//add fields to this list to query from database
        if(!Test.isRunningTest()){
            controller.addFields(fieldlist);
        }
        this.programTransactionRecord = (CLQ_Program_Transaction__c)controller.getRecord();
    }


    //Method to complete all on-load logic
    //@param : none
    //@return : pagereference
    public pagereference onLoad(){
        Id onsiteVisitRecordTypeId;
        
         for(CLQ_Create_Onsite__mdt mdt : [Select label,QualifiedApiName from CLQ_Create_Onsite__mdt]){
                CLQCreateOnsiteValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
        if(Schema.sObjectType.CLQ_Inspection__c.isAccessible()){
        	 onsiteVisitRecordTypeId = Schema.CLQ_Inspection__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
        }
            //12102 starts
            Id ptInitialRegRecTypeId;
        	Id ptOngoingRegRecTypeId;
         if(Schema.sObjectType.CLQ_Program_Transaction__c.isAccessible()){
        	 ptInitialRegRecTypeId = Schema.CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
        	 ptOngoingRegRecTypeId = Schema.CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
         }
           
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        inspectionrecord.RecordTypeId = onsiteVisitRecordTypeId;
        inspectionrecord.CLQ_Program_Transaction__c = programTransactionRecord.Id;
        inspectionrecord.CLQ_Program__c = programTransactionRecord.CLQ_Program__r.Id;
        inspectionrecord.CLQ_Site_IRN__c= programTransactionRecord.CLQ_Program__r.CLQ_BIRN__c;
        inspectionrecord.CLQ_County_at_Site__c = programTransactionRecord.Program_Transaction_County__c ; //15575
        /*if(String.valueOf(programTransactionRecord.OwnerId).contains('005')){ 
            inspectionrecord.CLQ_Inspection_Owner__c = programTransactionRecord.OwnerId; 
        } */ 
        
        inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        if(CLQCreateOnsiteValueMap.size()!=0){
        inspectionrecord.Inspection_Status__c = CLQCreateOnsiteValueMap.get('In_Progress');
        inspectionrecord.CLQ_Inspection_Status__c = CLQCreateOnsiteValueMap.get('In_Progress');//11867
        }
        
        //12102 Starts
        if(programTransactionRecord.recordtypeId == ptInitialRegRecTypeId && CLQCreateOnsiteValueMap.size()!=0){
        	inspectionrecord.CLQ_Inspection_Type__c= CLQCreateOnsiteValueMap.get('Initial_Registration');
        }
        
        if(programTransactionRecord.recordtypeId == ptOngoingRegRecTypeId && CLQCreateOnsiteValueMap.size()!=0){
        	inspectionrecord.CLQ_Inspection_Type__c= CLQCreateOnsiteValueMap.get('Ongoing_Registration');
        }
        //12102 Ends
          
        try{
            List<CLQ_Inspection__c> inspectionlist = new List<CLQ_Inspection__c>();
            inspectionlist.add(inspectionrecord);
            if(!inspectionlist.isEmpty() && Schema.sObjectType.CLQ_Inspection__c.isCreateable()){
                insert inspectionlist;
            }
        }catch(Exception e){
           Integration_Transaction_Logs.LogError
                ('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','CLQ_CreateOnsiteVisitInspectionExtn');
        }
        return CLQ_UtilityClass.redirecttoPage('/'+inspectionrecord.Id);
    }  
}