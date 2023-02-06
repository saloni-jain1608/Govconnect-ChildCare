/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_DeskReviewFindingController 
** Description      : Controller for DESK REVIEW FINDINGS BUTTON on Program Transaction
** Version          : 1.9
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                       Date                     Version                       Description
** Initial Build                    N/A                       1.0                         Initial Build
** Rahul Roy      				 10/15/2018					  1.4				CR#13564 : Added logic to populate Effective dated Standard Findings for Onsite Inspection
** Rahul Roy      				 10/16/2018					  1.5				CR#14722 : Added logic to populate Effective dated Domain Rules for Onsite Inspection
** Rohit Gowrishetty			10/18/2018 					  1.6				CR#14858 : Added logic to work for SUTQ Expedited Reg
** Rohit Gowrishetty			11/19/2018					  1.7				CR#14913 : Added logic to work for SUTQ Change os Owner
** Rohit Gowrishetty			11/19/2018					  1.8				CR#14917 : Added logic to work for SUTQ Rating reinstate
** Pradeep Ravi					12/24/2018					  1.9				CR#15234 : Added logic to display deferral for Expedited, COO and Resinstate 
************************************************************************************/
//Class for DESK REVIEW FINDINGS BUTTON on Program Transaction
public with sharing class CLQ_DeskReviewFindingController{
    //Variables
    public list<String> fieldlist;

    public CLQ_Program_Transaction__c programTransactionRecord {get;set;}
    public list<domainwithRuleList>domainRuleWrapperList{get;set;}
    public Boolean showPopup{get;set;}
    public list<popupWrapper> popupWrapperList{get;set;}
    public String selectedRule{get;set;}
    public String selectedInspectedRule{get;set;}
    public String resultselected{get;set;}
    public String selectedRuleName{get;set;}
    public list<CLQ_Rule__c> rulelist{get;set;}
    private list<CLQ_Rules_Inspected__c> rulesTobeUpdated = new list<CLQ_Rules_Inspected__c>();
    
    //popup realted variables
    list<CLQ_Standard_Findings__c> standardFindingList = new list<CLQ_Standard_Findings__c>();
    list<CLQ_Findings__c> findinglist = new list<CLQ_Findings__c>();
    map<id,CLQ_Findings__c> existingStandardFindingIdMap = new map<id,CLQ_Findings__c>();
    public Id onGoingRECId ; 
    public Id InitialId ; 
    public Id annualId ;
    public Id expeditedRecID ; //14858
    public Id sutqChangeofOwnerID ; //14913
    public Id sutqRaingReinstateID ; //14917
    public list<CLQ_Findings__c> existingFindings = new list<CLQ_Findings__c>(); 
    public Boolean isInitialAndOnGoing{get;set;}
    public Boolean isAnnual{get;set;}
    public Map<String,CLQ_Findings__c> existingFindingsMap = new Map<String,CLQ_Findings__c>();
    public Map<Id,CLQ_Findings__c> ruleSelectedCheck= new Map<Id,CLQ_Findings__c>();
    public list<CLQ_Findings__c> existingFindingForRule = new List<CLQ_Findings__c>();
    public Date rrValidityDate; //13564
    //Constructor
    public CLQ_DeskReviewFindingController(ApexPages.StandardController controller) {

        programTransactionRecord = new CLQ_Program_Transaction__c();
        fieldlist = new list<String>{'Name','CLQ_Program_Record_Type__c','CLQ_Rating_Confirmed_by_Program__c','CLQ_Rules_Effective_On__c'}; //Add fields as per need
        if(!Test.isRunningTest()){
            controller.addFields(fieldlist);
        }
       // this.inspectionRecord = (CLQ_Inspection__c)controller.getRecord();
        this.programTransactionRecord = (CLQ_Program_Transaction__c)controller.getRecord();
        rrValidityDate = programTransactionRecord.CLQ_Rules_Effective_On__c;  //13564
        domainRuleWrapperList = new list<domainwithRuleList>();

        showPopup = false;
       	isInitialAndOnGoing = false;
       	isAnnual = false;
	}
   
    //Method called on page load
    //@param: none
    //@return: none
    public PageReference onLoad(){
      
      onGoingRECId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
      annualId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
      InitialId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
      expeditedRecID =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Expedited Registration').getRecordTypeId(); //14858
      sutqChangeofOwnerID =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Change of Owner Registration').getRecordTypeId(); //14913
      sutqRaingReinstateID =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Reinstate Rating after Temporary Closure').getRecordTypeId(); //14917
        
      createRulesInspected();
      loadData();
      return null;
    }
        
     public void loadData(){ 
         
          existingFindingForRule = [Select Id,Rule__c,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =: programTransactionRecord.Id];
        
          if(programTransactionRecord.RecordTypeId == onGoingRECId || programTransactionRecord.RecordTypeId == InitialId || programTransactionRecord.RecordTypeId == expeditedRecID ||  programTransactionRecord.RecordTypeId == sutqChangeofOwnerID  || programTransactionRecord.RecordTypeId == sutqRaingReinstateID   ){ //14858 , 14913, 14917
              isInitialAndOnGoing = true;
          }
          else if(programTransactionRecord.RecordTypeId == annualId){
              isAnnual = true;
          }

        set<id> standardFindingRuleIDSet = new set<id>(); //variable to store all standard findings id
        set<String> domainNameSet = new set<String>(); //store unique domain names
        map<String,id> domainNameIdMap = new map<String,Id>();
        set<id> domainRuleIDSet = new set<id>();
        
        if(existingFindingForRule.size() > 0){
            for(CLQ_Findings__c  findingRule : existingFindingForRule)
            ruleSelectedCheck.put(findingRule.Rule__c,findingRule);
        }
        
        //Get all rule inspected for given insepection
        list<CLQ_Rules_Inspected__c> ruleinspectedlist = pullRuleInspectedforInspection(programTransactionRecord.id);
        System.debug('@@@@@@@@@'+ ruleinspectedlist );
        //Prepare the data map for rule code and rule description
        for(CLQ_Rules_Inspected__c ruleInspected : ruleinspectedlist){
            standardFindingRuleIDSet.add(ruleInspected.CLQ_Domain_Rule__r.CLQ_Rule__c);
            domainNameSet.add(ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name);
            if(!domainNameIdMap.containsKey(ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name)){
                domainNameIdMap.put(ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name, ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__c);
            }
            domainRuleIDSet.add(ruleInspected.CLQ_Domain_Rule__c);
            String selectedFindings = '';
            String selectedFindingsDescriptions = '';
         }
        //Get the Domain Rules 
        map<id,CLQ_Domain_Rule__c> mapIDDomainRule = new map<id,CLQ_Domain_Rule__c>([SELECT id
                                                                                    FROM CLQ_Domain_Rule__c
                                                                                    WHERE id in :domainRuleIDSet]);

        //Get all Rules and its related Standard Findings
        list<CLQ_Rule__c> rulelist = [Select ID
                                            ,CLQ_Domain__c
                                            ,(SELECT id
                                            ,Name
                                            FROM Standard_Findings__r)
                                    FROM CLQ_Rule__c
                                    WHERE id in :standardFindingRuleIDSet];
        
        domainRuleWrapperList.clear(); 
       //Now store the data in wrapper class structure so that we can display that in VF page
        for(String domainName : domainNameSet){
            //populate the domain option
            list<rulewithFinding> rulewithFindingList = new list<rulewithFinding>();
             System.debug('Map value' + ruleSelectedCheck);
            for(CLQ_Rules_Inspected__c ruleInspected : ruleinspectedlist){
                
                if(domainName == ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name){
                    System.debug('INSIDE IF');
                    if(ruleSelectedCheck.get(ruleInspected.CLQ_Domain_Rule__r.CLQ_Rule__c) != null){
                        System.debug('INSIDE SECOND IF');
                        rulewithFindingList.add(new rulewithFinding(ruleInspected,ruleSelectedCheck.get(ruleInspected.CLQ_Domain_Rule__r.CLQ_Rule__c).Rating__c,ruleSelectedCheck.get(ruleInspected.CLQ_Domain_Rule__r.CLQ_Rule__c).Points__c));
                        SYSTEM.DEBUG('$$$$$$Rule list'+rulewithFindingList);
                    }
                    else{
                        rulewithFindingList.add(new rulewithFinding(ruleInspected));
                    }
                }
			}
            domainwithRuleList wrapperRecord = new domainwithRuleList(domainNameIdMap.get(domainName),domainName,rulewithFindingList);
            domainRuleWrapperList.add(wrapperRecord);   
        }
        //return null;
    }
    
 //Method to query all rule inspected for the inspection
    //@param: inspection record id
    //@return: list of rule inspected
    public list<CLQ_Rules_Inspected__c> pullRuleInspectedforInspection(ID ProgramTransactionId){

            //add related object CLQ_Finind__c
            String relationQuery = '(SELECT id,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Finding_Code__c ,CLQ_Description__c,CLQ_TA_Description__c FROM  Findings__r)';
            //add extra fields as needed
            list<String> extraFieldsList = new list<String>{'CLQ_Domain_Rule__r.CLQ_Rule__c','CLQ_Domain_Rule__r.CLQ_Rule__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Description__c','CLQ_Domain_Rule__r.CLQ_Domain__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Short_Name__c','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Long_Name__c'};
            extraFieldsList.add(relationQuery);
            //get soql string
            String soqlQuery = CLQ_UtilityClass.createSOQLQuery('CLQ_Rules_Inspected__c', ' ProgramTransaction__c ='+'\''+String.escapeSingleQuotes(ProgramTransactionId)+'\'', extraFieldsList);   
            soqlQuery = soqlQuery + ' ORDER by CLQ_Domain_Rule__r.CLQ_Domain__r.Name';
            //query database
            return Database.query(soqlQuery);
         
    }

    //Method to redirect to Inspection page
    //@return: pageReference
    //@param : none
    public PageReference onCancel(){
        //return to inspection record
        return CLQ_UtilityClass.redirecttoPage('/'+programTransactionRecord.Id);
    }

    
    //prepare Popup data
    //@param: none  
    //@none: Pagereference
    public PageReference popupOnLoad(){

        showPopup = true; //variable to define if pop-up needs to be shown or not
        popupWrapperList = new list<popupWrapper>(); //list to show the table in pop-up
        selectedRule = ApexPages.currentPage().getParameters().get('selectedRule');
        selectedInspectedRule = ApexPages.currentPage().getParameters().get('selectedInspectedRule');
        //resultselected = ApexPages.currentPage().getParameters().get('resultselected');
        system.debug('====selectedRule===>'+selectedRule);
        system.debug('====selectedInspectedRule===>'+selectedInspectedRule);
        
        String rulesToShow = '';
        Id DomainRuleId ; 
        if(selectedRule != null){
          DomainRuleId = Id.valueOf(selectedRule);
        }
        
        
        existingFindingsMap = new Map<String,CLQ_Findings__c>();
        List<CLQ_Findings__c> existingFindingResults = new List<CLQ_Findings__c>();
        existingFindingResults = [Select Id,Name,CLQ_Domain_Rule__c,CLQ_Standard_Finding__c,CLQ_StandardFindingsName__c,CLQ_Description__c,Points__c,Rating__c,CLQ_Met_Not_Met__c from CLQ_Findings__c where Program_Transaction__c =: programTransactionRecord.Id ];
        
        System.debug('EXISTING FINDINGS' + existingFindingResults);
        if(existingFindingResults.size()> 0){
            for(CLQ_Findings__c existFinding : existingFindingResults){
                existingFindingsMap.put(existFinding.CLQ_StandardFindingsName__c,existFinding );
            }
        }
        
        
        //Anil's Code
        List<CLQ_Domain_Rule_Finding__c> associatedStandardFindings =  new List<CLQ_Domain_Rule_Finding__c>();
        if(programTransactionRecord.RecordTypeId == onGoingRECId || programTransactionRecord.RecordTypeId == InitialId){ //14858 , 14913, 14917
          associatedStandardFindings = [Select Id,Name,CLQ_Standard_Finding__r.CLQ_Description__c,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Points__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__r.CLQ_Rating__c,CLQ_Standard_Finding__r.Met_Not_Met__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c =: DomainRuleId AND CLQ_Standard_Finding__r.Name != 'Deferral' AND ((CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c != NULL AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= :rrValidityDate) AND (CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = NULL OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= :rrValidityDate)) order by CLQ_Order_Number__c ];//13564 
          System.debug('###########' + associatedStandardFindings);
          for(CLQ_Domain_Rule_Finding__c standardFinding : associatedStandardFindings){
              System.debug('Standard finding Name '+ standardFinding.CLQ_Standard_Finding__r.Name );
              if(existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name)!= null && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c == standardFinding.CLQ_Standard_Finding__r.Name && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Domain_Rule__c == standardFinding.CLQ_Domain_Rule__c){
                  System.debug('INSIDE FIRST IF');
                  popupWrapper wrapperRecord = new popupWrapper(true,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name),existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Rating__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Points__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Description__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c ,NULL);
                  system.debug('====> inside if '+wrapperRecord);
                  popupWrapperList.add(wrapperRecord);
              }
              else{
                  CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = standardFinding.CLQ_Standard_Finding__r.Id
                                                                                   ,CLQ_Description__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                                                   ,Points__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                                                   ,CLQ_StandardFindingsName__c = standardFinding.CLQ_Standard_Finding__r.Name
                                                                                   ,Rating__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                                                   ,CLQ_Met_Not_Met__c = null
                                                                                   ,CLQ_Domain_Rule_Finding__c = standardFinding.id
                                                                                  );
                  popupWrapper wrapperRecord = new popupWrapper(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,NULL);
                  system.debug('====>'+wrapperRecord);
                  popupWrapperList.add(wrapperRecord);
              }
          }
          
        }
        else if(programTransactionRecord.RecordTypeId == expeditedRecID ||  programTransactionRecord.RecordTypeId == sutqChangeofOwnerID  || programTransactionRecord.RecordTypeId == sutqRaingReinstateID)
        { // Updated to display deferral findings and findings for Expedited, COO and Resinstate - 15234
    		  associatedStandardFindings = [Select Id,Name,CLQ_Standard_Finding__r.CLQ_Description__c,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Points__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__r.CLQ_Rating__c,CLQ_Standard_Finding__r.Met_Not_Met__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c =: DomainRuleId AND ((CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c != NULL AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= :rrValidityDate) AND (CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = NULL OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= :rrValidityDate)) order by CLQ_Order_Number__c];//13564 
	          System.debug('###########' + associatedStandardFindings);
	          for(CLQ_Domain_Rule_Finding__c standardFinding : associatedStandardFindings){
	              System.debug('Standard finding Name '+ standardFinding.CLQ_Standard_Finding__r.Name );
	              if(existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name)!= null && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c == standardFinding.CLQ_Standard_Finding__r.Name && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Domain_Rule__c == standardFinding.CLQ_Domain_Rule__c){
	                  System.debug('INSIDE FIRST IF');
	                  popupWrapper wrapperRecord = new popupWrapper(true,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name),existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Rating__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Points__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Description__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c ,NULL);
	                  system.debug('====> inside if '+wrapperRecord);
	                  popupWrapperList.add(wrapperRecord);
	              }
	              else{
	                  CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = standardFinding.CLQ_Standard_Finding__r.Id
	                                                                                   ,CLQ_Description__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Description__c
	                                                                                   ,Points__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Points__c
	                                                                                   ,CLQ_StandardFindingsName__c = standardFinding.CLQ_Standard_Finding__r.Name
	                                                                                   ,Rating__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
	                                                                                   ,CLQ_Met_Not_Met__c = null
	                                                                                   ,CLQ_Domain_Rule_Finding__c = standardFinding.id
	                                                                                  );
	                  popupWrapper wrapperRecord = new popupWrapper(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,NULL);
	                  system.debug('====>'+wrapperRecord);
	                  popupWrapperList.add(wrapperRecord);
	              }
	          }
        }
        else if(programTransactionRecord.RecordTypeId == annualId){
          associatedStandardFindings = [Select Id,Name,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__r.CLQ_Description__c,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Points__c,CLQ_Standard_Finding__r.CLQ_Rating__c,CLQ_Standard_Finding__r.Met_Not_Met__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c =: DomainRuleId AND ((CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c != NULL AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= :rrValidityDate) AND (CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = NULL OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= :rrValidityDate)) order by CLQ_Order_Number__c]; //13564
            System.debug('###########' + associatedStandardFindings);
           for(CLQ_Domain_Rule_Finding__c standardFinding : associatedStandardFindings){
              if(existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name)!= null && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c == standardFinding.CLQ_Standard_Finding__r.Name && existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Domain_Rule__c == standardFinding.CLQ_Domain_Rule__c){
                  popupWrapper wrapperRecord = new popupWrapper(true,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name),existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Rating__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).Points__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Description__c,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_StandardFindingsName__c ,existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Met_Not_Met__c );
                  system.debug('====> inside if annual'+wrapperRecord);
                  popupWrapperList.add(wrapperRecord);
              }
              else{
                  CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = standardFinding.CLQ_Standard_Finding__r.Id
                                                                                   ,CLQ_Description__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                                                   ,Points__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                                                   ,CLQ_StandardFindingsName__c = standardFinding.CLQ_Standard_Finding__r.Name
                                                                                   ,Rating__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                                                   ,CLQ_Met_Not_Met__c = standardFinding.CLQ_Standard_Finding__r.Met_Not_Met__c
                                                                                   ,CLQ_Domain_Rule_Finding__c = standardFinding.id
                                                                                  );
                  popupWrapper wrapperRecord = new popupWrapper(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,finding.CLQ_Met_Not_Met__c );
                  system.debug('====>'+wrapperRecord);
                  popupWrapperList.add(wrapperRecord);
              }
               
          }
        }
       system.debug('====>'+popupWrapperList.size());
        return null;
    }
    
    
     //on close Popup button
    //@param:
    //@none:
    public PageReference closePopUp(){
        showPopup = false;
        return null;
    }
    
    //on save Popup button
    //@param: none
    //@return: pagereference
    public PageReference savePopUp(){
       try{
        showPopup = false;
        
        existingFindings = [Select Id,Name,Rule__c,CLQ_Standard_Finding__r.Name,
                            Program_Transaction__c,CLQ_Standard_Finding__c,
                            CLQ_Rules_Inspected__c,CLQ_Domain_Rule__r.CLQ_Rule__c,
                            CLQ_Domain_Rule_Finding__c
                            from CLQ_Findings__c 
                            where Program_Transaction__c =: programTransactionRecord.Id];
        
        Map<Id,Id> domainRuleToRule = new Map<Id,Id>();
        //Map<Id,Boolean> ruleSelectedCheck = new Map<Id,Boolean>();
        System.Debug('SELECTED RULE'+ selectedRule);
        
        CLQ_Domain_Rule__c domainRule = [Select Id,Name,CLQ_Rule__c 
                                         from CLQ_Domain_Rule__c 
                                         where Id =: selectedRule];
        //list<CLQ_Findings__c> findinglisttoInsert = new list<CLQ_Findings__c>();
        if(domainRule != null){
            domainRuleToRule.put(domainRule.Id,domainRule.CLQ_Rule__c);
        
        }
       
        list<CLQ_Findings__c> findinglisttoInsert = new list<CLQ_Findings__c>();
        String newsDescription = '';
        String MetNotMet = '';
        Integer selectedCount = 0;
      
        for(popupWrapper findingWrapper: popupWrapperList){
             if(findingWrapper.isSelected == true){
                 selectedCount = selectedCount + 1;
             }
        }
        System.debug('SELECT COUNT'+ selectedCount );
        if(selectedCount > 1 ){
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You may only select one standard finding for each rule');
              ApexPages.addMessage(myMsg);
              return null;
        }
        //Loop to check with record is selected or not
        for(popupWrapper findingWrapper: popupWrapperList){
            if(programTransactionRecord.RecordTypeId == onGoingRECId || programTransactionRecord.RecordTypeId == InitialId || programTransactionRecord.RecordTypeId == expeditedRecID  ||  programTransactionRecord.RecordTypeId == sutqChangeofOwnerID  || programTransactionRecord.RecordTypeId == sutqRaingReinstateID   ){ //14858 , 14913, 14917
              if(findingWrapper.isSelected == true){
                 
                  newsDescription = findingWrapper.standardFindings.CLQ_Description__c;
                 // MetNotMet = null;
                  CLQ_Findings__c findingToInsert = new CLQ_Findings__c();
                  findingToInsert.Rating__c = findingWrapper.rating ;
                  findingToInsert.CLQ_Rules_Inspected__c = selectedInspectedRule;
                  findingToInsert.CLQ_Domain_Rule__c = selectedRule;
                  if(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c)!= null){
                          findingToInsert.Rule__c = domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c);
                          //ruleSelectedCheck.put(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c),true);
                  }
                  findingToInsert.CLQ_Standard_Finding__c = findingWrapper.standardFindings.CLQ_Standard_Finding__c;
                  findingToInsert.Points__c = findingWrapper.point ;
                  findingToInsert.CLQ_Description__c = newsDescription;
                  findingToInsert.Program_Transaction__c = programTransactionRecord.Id;
                  findingToInsert.CLQ_Met_Not_Met__c = NULL;
                  findingToInsert.CLQ_StandardFindingsName__c = findingWrapper.standardFindings.CLQ_StandardFindingsName__c;
                  findingToInsert.CLQ_Domain_Rule_Finding__c = findingWrapper.standardFindings.CLQ_Domain_Rule_Finding__c ;
                  findinglisttoInsert.add(findingToInsert);    
              }
            }
            else if(programTransactionRecord.RecordTypeId == annualId){
              if(findingWrapper.isSelected == true){
  
                  newsDescription = findingWrapper.standardFindings.CLQ_Description__c;
                  MetNotMet = findingWrapper.standardFindings.CLQ_Met_Not_Met__c;
                  CLQ_Findings__c findingToInsert = new CLQ_Findings__c();
                  findingToInsert.Rating__c = findingWrapper.rating ;
                  findingToInsert.CLQ_Rules_Inspected__c = selectedInspectedRule;
                  findingToInsert.CLQ_Domain_Rule__c = selectedRule;
                  if(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c)!= null){
                          findingToInsert.Rule__c = domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c);
                          //ruleSelectedCheck.put(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c),true);
                  }
                  findingToInsert.CLQ_Standard_Finding__c = findingWrapper.standardFindings.CLQ_Standard_Finding__c;
                  findingToInsert.Points__c = findingWrapper.point ;
                  findingToInsert.CLQ_Description__c = newsDescription;
                  findingToInsert.Program_Transaction__c = programTransactionRecord.Id;
                  findingToInsert.CLQ_Met_Not_Met__c = MetNotMet;
                  findingToInsert.CLQ_StandardFindingsName__c = findingWrapper.standardFindings.CLQ_StandardFindingsName__c;
                  findingToInsert.CLQ_Domain_Rule_Finding__c = findingWrapper.standardFindings.CLQ_Domain_Rule_Finding__c ;
                  findinglisttoInsert.add(findingToInsert);    
              }
            }
            
            
        }
        
        
        System.debug('@#@#@#@CHECKBOX'+ ruleSelectedCheck);
        System.debug('########' + findinglisttoInsert);
        //insert new findings
        if(findinglisttoInsert.size()>0){
            insert findinglisttoInsert;
        }
        
        System.debug('########' + findinglisttoInsert);
        List<CLQ_Findings__c> findingsToDelete = new List<CLQ_Findings__c>();
        for(CLQ_Findings__c findings : findinglisttoInsert){
            for(CLQ_Findings__c existingFinding : existingFindings){
                System.debug('RULE RELATED TO EXISTING FINDINGS'+ existingFinding.Rule__c);
                System.debug('RULE RELATED TO NEW FINDINGS'+ findings.Rule__c);
                if(existingFinding.Rule__c == findings.Rule__c ){
                    findingsToDelete.add(existingFinding);
                }
            }
        
        }
        if(findingsToDelete != null && findingsToDelete.size() > 0){
            delete findingsToDelete;
        }
        loadData();
       }
       catch(Exception e){
           System.debug('Exception' + e.getMessage());
       }
        return null;
    }
    
    public void createRulesInspected(){
      //Id onGoingRECId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
      //Id annualId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
      //Id InitialId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
        try{
           list<CLQ_Inspection_Tools__c> inspectionToolList = new list<CLQ_Inspection_Tools__c>();
           list<CLQ_Inspection_Tools__c> inspectionToolFinalList = new list<CLQ_Inspection_Tools__c>();
           Set<Id> inspectionToolIds = new Set<Id>();
           //14858 - Added Applicable_to_SUTQ_Transactions__c
            inspectionToolList = [SELECT ID
                                    ,CLQ_Applicable_To__c
                                    ,CLQ_Description__c
                                    ,CLQ_Active__c
                                    ,PTEstimatedDeskRating_c__c
                                    ,CLQ_Is_Related_to_Program_Transaction__c
                                    ,Name , 
                                    Applicable_to_SUTQ_Transactions__c
                                FROM CLQ_Inspection_Tools__c
                                where CLQ_Is_Related_to_Program_Transaction__c = true
                                ];
                                
           //if(!Test.isRunningTest()){
                for(CLQ_Inspection_Tools__c inspectionTool : inspectionToolList){
                    String applicableTo ;
                    List<String> applicableToList = new List<String>();
                    
                    if(inspectionTool.Applicable_to_SUTQ_Transactions__c != null){
                        applicableTo = inspectionTool.Applicable_to_SUTQ_Transactions__c;
                        applicableToList = applicableTo.split(';');
                    }

                     System.debug('Sujith:Expedited'+applicableToList);
					                    
                    //14858 , 14913 , 14917 - Added logic for tehe new field - ( Applicable to (SUTQ Transactions) ) where now state user can select the tools accordingly with RT
                      if(programTransactionRecord.RecordTypeId == onGoingRECId || programTransactionRecord.RecordTypeId == InitialId  || programTransactionRecord.RecordTypeId == expeditedRecID ||  programTransactionRecord.RecordTypeId == sutqChangeofOwnerID  || programTransactionRecord.RecordTypeId == sutqRaingReinstateID   ){ //14858 
                        if(inspectionTool.CLQ_Is_Related_to_Program_Transaction__c == true && (inspectionTool.CLQ_Applicable_To__c != null && (inspectionTool.CLQ_Applicable_To__c).contains(programTransactionRecord.CLQ_Program_Record_Type__c)) && (inspectionTool.PTEstimatedDeskRating_c__c != null && programTransactionRecord.CLQ_Rating_Confirmed_by_Program__c!= null && (inspectionTool.PTEstimatedDeskRating_c__c).contains(programTransactionRecord.CLQ_Rating_Confirmed_by_Program__c))){
                            System.debug('Id would be' + inspectionTool.Id);
                            System.debug('INSIDE INSPECTION TOOLS IF');
                            
							if((programTransactionRecord.RecordTypeId == onGoingRECId || programTransactionRecord.RecordTypeId == InitialId) && 
                               ( inspectionTool.Applicable_to_SUTQ_Transactions__c == null || 
                               	 ((inspectionTool.Applicable_to_SUTQ_Transactions__c != null) && 
                                  (applicableToList.contains('Initial Registration') || applicableToList.contains('Ongoing Registration')) 
                                 ) 
                               )  
                              ){ 
                                System.debug('Initial or Ongoing');
                                inspectionToolFinalList.add(inspectionTool);
                                inspectionToolIds.add(inspectionTool.Id);                                
                            }else if(programTransactionRecord.RecordTypeId == expeditedRecID && inspectionTool.Applicable_to_SUTQ_Transactions__c != null && applicableToList.contains('Expedited Registration') ){
                                System.debug('Sujith:Expedited1');
                                inspectionToolFinalList.add(inspectionTool);
                                inspectionToolIds.add(inspectionTool.Id);                                 
                            }else if(programTransactionRecord.RecordTypeId == sutqChangeofOwnerID && inspectionTool.Applicable_to_SUTQ_Transactions__c != null && applicableToList.contains('Change of Owner Registration') ){
                                System.debug('Change of Owner');
                                inspectionToolFinalList.add(inspectionTool);
                                inspectionToolIds.add(inspectionTool.Id);                                
                            }else if(programTransactionRecord.RecordTypeId == sutqRaingReinstateID && inspectionTool.Applicable_to_SUTQ_Transactions__c != null && applicableToList.contains('Reinstate Rating after Temporary Closure') ){
                                System.debug('Rating Reinstate');
                                inspectionToolFinalList.add(inspectionTool);
                                inspectionToolIds.add(inspectionTool.Id);                                
                            }                            
                        }
                      }
                      else if(programTransactionRecord.RecordTypeId == annualId){
                        if(inspectionTool.CLQ_Is_Related_to_Program_Transaction__c == true && (inspectionTool.CLQ_Applicable_To__c != null && (inspectionTool.CLQ_Applicable_To__c).contains(programTransactionRecord.CLQ_Program_Record_Type__c)) && (inspectionTool.PTEstimatedDeskRating_c__c == null )){
                          System.debug('INSIDE INSPECTION TOOLS ELSE');
                          inspectionToolFinalList.add(inspectionTool);
                            inspectionToolIds.add(inspectionTool.Id);
                        }
                        
                        
                      }
                
                }
           //}
            /*CLQ_Inspection_Tools__c insTool = new CLQ_Inspection_Tools__c();
            insert insTool;
            */ 
            CLQ_Inspection__c Insp = new CLQ_Inspection__c();
            Insp.CLQ_Inspection_Status__c = 'Closed';
            Insp.CLQ_Insp_DeferralDueDate__c = date.today().addDays(-2);
            insert Insp;
            
            list<CLQ_Tools_Rules__c> toolRuleList = new list<CLQ_Tools_Rules__c>(); 
            for(Id insToolId : inspectionToolIds){
                
                toolRuleList = [Select Id,Name,CLQ_Domain_Rule__c, CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c, CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c,  CLQ_Rules__c from CLQ_Tools_Rules__c where CLQ_Inspection_Tools__c =: insToolId];//14722 Added Rule Eff and Exp date
            }
           list<CLQ_Rules_Inspected__c> ruleInspectedList = new list<CLQ_Rules_Inspected__c>();
           list<CLQ_Rules_Inspected__c> rulesInspectedToBeDeleted = new list<CLQ_Rules_Inspected__c>();
           for(CLQ_Tools_Rules__c toolRule : toolRuleList){
           		System.Debug('toolRule--> '+toolRule);
           		if((toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c != NULL && toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c <= rrValidityDate) && (toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c == NULL || toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c >= rrValidityDate)){//14722 Excluding rules not in eff
                    System.debug('INSIDE 14722');
                    ruleInspectedList.add(new CLQ_Rules_Inspected__c(ProgramTransaction__c=programTransactionRecord.Id,CLQ_Domain_Rule__c =toolRule.CLQ_Domain_Rule__c,CLQ_Inspection_No__c = Insp.Id ));   
           		}
            } 
            rulesInspectedToBeDeleted = [Select Id from CLQ_Rules_Inspected__c where ProgramTransaction__c =: programTransactionRecord.Id];
            /*
            if(rulesInspectedToBeDeleted.size() >0){
             delete rulesInspectedToBeDeleted;
            }
            
            if(ruleInspectedList.size()>0){   
                    insert ruleInspectedList; 
                }
                */
          
                if( rulesInspectedToBeDeleted.size() == 0 && ruleInspectedList.size()>0 ){
                    insert ruleInspectedList;
                }
           }
           Catch(Exception e){
               System.debug('Exception' + e.getMessage());
           }        
    
    }
    
    
    /**************************************Wrapper Class section begins *********************************************/
    //child Wrapper
    public class rulewithFinding{
        public CLQ_Rules_Inspected__c ruleRecord{get;set;}
        public Boolean showRule{get;set;}
        public String rating{get;set;}
        public String point{get;set;}
        public rulewithFinding(CLQ_Rules_Inspected__c ruleRecord){
            this.ruleRecord = ruleRecord;
            showRule = true;
        }
        public rulewithFinding(CLQ_Rules_Inspected__c ruleRecord, String sRating,String sPoint){
            this.ruleRecord = ruleRecord;
            this.rating = sRating;
            this.point = sPoint;
            showRule = true;
        }
        
    }

    //parent wrapper
    public class domainwithRuleList{
        public String domainID{get;set;}
        public String domainName{get;set;}
        public list<rulewithFinding> rulelist{get;set;}
        public Boolean showDomain{get;set;}
        public domainwithRuleList(ID domainID,String dname , list<rulewithFinding> rulewithFindingList){
            this.domainName = dname;
            this.rulelist = rulewithFindingList;
            showDomain = true;
            this.domainID = domainID;
        }
    }

    //wrapper for pop up
    public class popupWrapper{
        public Boolean isSelected{get;set;}
        public CLQ_Findings__c standardFindings{get;set;}
        public String sFindingCode{get;set;}
        public String rating{get;set;}
        public String point{get;set;}
        public String description{get;set;}
        public String sfindingName{get;set;}
        public String sMetOrNotMet{get;set;}
        public popupWrapper(Boolean isSelected,CLQ_Findings__c sfinding,String sRating,String sPoints,String sDescription, String sName, String sMetOrNotMet){
            this.isSelected = isSelected;
            this.standardFindings = sfinding;
            this.rating = sRating;
            this.point = sPoints;
            this.description = sDescription;
            this.sfindingName = sName;
            this.sMetOrNotMet = sMetOrNotMet;
        }
    }
    /**************************************Wrapper Class section ends *********************************************/
    
}