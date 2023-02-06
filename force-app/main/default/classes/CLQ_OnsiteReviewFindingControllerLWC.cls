/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_OnsiteReviewFindingControllerLWC 
** Description      : Controller for performing onsite review finding actions for LWC Component
** Version          : 1.5

************************************************************************************/
public with sharing class CLQ_OnsiteReviewFindingControllerLWC {

    //Variables
    public list<String> fieldlist;

   // public CLQ_Program_Transaction__c programTransactionRecord {get;set;}
    public static CLQ_Inspection__c inspectionRecord {get;set;}
    //public list<visitRulewrapper> wrapperClasslist{get;set;}
    //public static list<domainwithRuleList>domainRuleWrapperList{get;set;}
    public static Boolean showPopup{get;set;}
    public static Boolean showFindings{get; set;}
    public static Boolean showStandardFindings{get; set;}
    public static list<popupWrapper> popupWrapperList{get;set;}
    public static list<popupWrapperFindings> popupWrapperFindingList{get;set;}
    public static String selectedRule{get;set;}
    public static String selectedInspectedRule{get;set;}
    public static String resultselected{get;set;}

    public static String selectedRuleName{get;set;}
   // public List<SelectOption> domainOptions{get;set;}
    public static list<CLQ_Rule__c> rulelist{get;set;}
    static Boolean showError = false;
    static Boolean fireOnce = false;
    private static list<CLQ_Rules_Inspected__c> rulesTobeUpdated = new list<CLQ_Rules_Inspected__c>();
    public static  list<CLQ_Domain_Rule_Finding__c> domainRuleFindingList = new list<CLQ_Domain_Rule_Finding__c>();
    
    //popup realted variables
    static list <CLQ_Standard_Findings__c> standardFindingList = new list<CLQ_Standard_Findings__c>();
    static list <CLQ_Findings__c> findinglist = new list<CLQ_Findings__c>();
    static map<id,CLQ_Findings__c> existingStandardFindingIdMap = new map<id,CLQ_Findings__c>();
    public static Id onGoingRECId ; 
    public static Id InitialId ; 
    public static Id annualId ;    
    public static CLQ_Inspection__c  inspection = new CLQ_Inspection__c();
    public static Date rrValidityDate; //13564
    public static list<CLQ_Findings__c> deskReviewFindings = new list<CLQ_Findings__c>();
    public static list<CLQ_Findings__c> existingFindings = new list<CLQ_Findings__c>();
    public static Map<String,CLQ_Findings__c> existingFindingsMap = new Map<String,CLQ_Findings__c>();
    public static Map<Id,CLQ_Findings__c> existingFindingSQandPDMap = new Map<Id,CLQ_Findings__c>();
    public static set<Id> domainRuleIds = new set<Id>();
    public static list<CLQ_Findings__c> existingFindingForRule = new List<CLQ_Findings__c>(); 
    public static Map<Id,CLQ_Findings__c> ruleSelectedCheck= new Map<Id,CLQ_Findings__c>();
   // public list<CLQ_Findings__c> findinglisttoInsert = new list<CLQ_Findings__c>();
    //Constructor
   
    
    //Method to do on load logic
    //@param: none
    //@return: none
    @AuraEnabled
    public static boolean onLoad(string InspId){
        
        onGoingRECId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
        annualId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
        InitialId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
         
        //TFS#15842 starts
        //createRulesInspected();
        //loadData();
         Boolean concurrentFlag=[select concurrentFlag__c from CLQ_Inspection__c where id=:InspId].concurrentFlag__c;
            if(concurrentFlag==false)
             {
                 //inspectionRecord.concurrentFlag__c=true;
                 //update inspectionRecord;
                 //createRulesInspected();
                 //loadData();
             }
            //TFS#15842 ends
        return concurrentFlag;
    }   
        
        @AuraEnabled
       public static list<domainwithRuleList> loadData(string InspId){
           
        list<domainwithRuleList> domainRuleWrapperList=new list<domainwithRuleList>();
        inspectionRecord      = new CLQ_Inspection__c();
        onGoingRECId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
        annualId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
        InitialId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
        inspectionRecord=[Select id,concurrentFlag__c,CLQ_Use_Rules_Effective_On__c,CLQ_Program_Transaction__r.Id from CLQ_Inspection__c where id=:InspId];
        if(inspectionRecord.concurrentFlag__c==false)
             {
                 inspectionRecord.concurrentFlag__c=true;
                 update inspectionRecord;
             }
           
        existingFindingForRule = [Select Id,Rule__c,Points__c,Rating__c from CLQ_Findings__c where CLQ_Inspection__c =: inspectionRecord.Id];
        deskReviewFindings = [Select Id,CLQ_Domain_Rule_Finding__c,CLQ_StandardFindingsName__c,CLQ_Standard_Finding__r.Name,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Domain_Rule__c,Name,CLQ_Standard_Finding__c,Points__c,Rating__c,CLQ_Description__c from CLQ_Findings__c where Program_Transaction__c =:inspectionRecord.CLQ_Program_Transaction__r.Id ];
        
        
        
        //String domainName = '';
        set<id> standardFindingRuleIDSet = new set<id>(); //variable to store all standard findings id
        set<String> domainNameSet = new set<String>(); //store unique domain names
        map<String,id> domainNameIdMap = new map<String,Id>();
        set<id> domainRuleIDSet = new set<id>();
        
        
        if(existingFindingForRule.size() > 0){
            for(CLQ_Findings__c  findingRule:existingFindingForRule)
            ruleSelectedCheck.put(findingRule.Rule__c,findingRule);
        }
        //Get all rule inspected for given insepection
        list<CLQ_Rules_Inspected__c> ruleinspectedlist = pullRuleInspectedforInspection(inspectionRecord.id);
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
        
       
        //domainRuleWrapperList.clear(); 
       //Now store the data in wrapper class structure so that we can display that in VF page
        for(String domainName : domainNameSet){
            //populate the domain option

            list<rulewithFinding> rulewithFindingList = new list<rulewithFinding>();
            for(CLQ_Rules_Inspected__c ruleInspected : ruleinspectedlist){
               
                if(domainName == ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name){
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
           return domainRuleWrapperList;
        
        
    }
    
 //Method to query all rule inspected for the inspection
    //@param: inspection record id
    //@return: list of rule inspected
    @AuraEnabled
    public static list<CLQ_Rules_Inspected__c> pullRuleInspectedforInspection(ID inspectionId){
        //add related object CLQ_Finind__c
        String relationQuery = '(SELECT id,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Finding_Code__c ,CLQ_Description__c,CLQ_TA_Description__c FROM  Findings__r)';
        //add extra fields as needed
        list<String> extraFieldsList = new list<String>{'CLQ_Domain_Rule__r.CLQ_Rule__c','CLQ_Domain_Rule__r.CLQ_Rule__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Description__c','CLQ_Domain_Rule__r.CLQ_Domain__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Short_Name__c','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Long_Name__c'};
        extraFieldsList.add(relationQuery);
        //get soql string
        String soqlQuery = CLQ_UtilityClass.createSOQLQuery('CLQ_Rules_Inspected__c', ' CLQ_Inspection_No__c ='+'\''+String.escapeSingleQuotes(inspectionId)+'\'', extraFieldsList);   
        soqlQuery = soqlQuery + ' ORDER by CLQ_Domain_Rule__r.CLQ_Domain__r.Name';
        //query database
        return Database.query(soqlQuery);
    }
    

    //Method to redirect to Inspection page
    //@return: pageReference
    //@param : none
   
    @AuraEnabled
    public static string onCancel(string InspId){
        //TFS#15842 starts
        inspectionRecord=[Select id,Rating_Proposed_By_Program__c,A_LP_Domain_Points__c,Accreditation_Domain_Points__c,F_CP_Domain_Points__c,Learning_And_Development_Domain_Points__c,SQ_PD_Domain_Points__c,Ratio_Group_Size_Domain_Points__c,concurrentFlag__c,CLQ_Use_Rules_Effective_On__c,CLQ_Program_Transaction__r.Id from CLQ_Inspection__c where id=:InspId];
         inspectionRecord.concurrentFlag__c=false;
         update inspectionRecord;
        //TFS#15842 ends
        //12032
        try{
        RatingEstimatedBySystem(inspectionRecord);
            return 'success';
        }
        catch(exception e){
            return e.getMessage();
        }
        //return to inspection record
    }//end method onCancel
    
    //12032 start: Method to calculate ratings and points from Findings
    @AuraEnabled
    public static void RatingEstimatedBySystem(CLQ_Inspection__c inspectionToUpdate) {
        
        System.debug('RatingEstimatedBySystem triggered--->');
        
        Set <String> domainNames = new Set<String>();
        domainNames.add('Learning & Development');
        domainNames.add('Administrative & Leadership Practices');
        domainNames.add('Staff Quals and PD');
        domainNames.add('Family & Community Partnerships');
        domainNames.add('Accreditation');
        domainNAmes.add('Ratio');
        
        List<CLQ_Findings__c> allFindings = [SELECT Id, CLQ_Inspection__c, CLQ_Domain_Rule__c, CLQ_Domain_Rule__r.CLQ_Domain_Name__c, CLQ_Met_Not_Met__c, Points__c, Rating__c 
                                      FROM CLQ_Findings__c 
                                      WHERE CLQ_Inspection__c=:inspectionToUpdate.id
                                      AND CLQ_Domain_Rule__r.CLQ_Domain_Name__c IN: domainNames];
        
            
         System.debug('domainNames-->' + domainNames);                           
         System.debug('allFindings size-->' + allFindings.size());
         System.debug('allFindings-->' + allFindings);
         
        //update all fields
        inspectionToUpdate.A_LP_Domain_Points__c = getPoints(allFindings, 'Administrative & Leadership Practices',inspectionToUpdate.Rating_Proposed_By_Program__c);
        inspectionToUpdate.A_LP_Domain_Ratings__c = getRatings(allFindings, 'Administrative & Leadership Practices');

        System.debug('objIns.A_LP_Domain_Points__c-->' + inspectionToUpdate.A_LP_Domain_Points__c);
        System.debug('objIns.A_LP_Domain_Ratings__c-->' + inspectionToUpdate.A_LP_Domain_Ratings__c);
        
        inspectionToUpdate.Accreditation_Domain_Points__c = getPoints(allFindings, 'Accreditation',inspectionToUpdate.Rating_Proposed_By_Program__c);
        //objIns.Accreditation_Domain_Ratings__c = getRatings(allFindings, 'Accreditation');
        
        inspectionToUpdate.F_CP_Domain_Points__c = getPoints(allFindings, 'Family & Community Partnerships',inspectionToUpdate.Rating_Proposed_By_Program__c);
        inspectionToUpdate.F_CP_Domain_Ratings__c = getRatings(allFindings, 'Family & Community Partnerships');
        
        inspectionToUpdate.Learning_And_Development_Domain_Points__c = getPoints(allFindings, 'Learning & Development',inspectionToUpdate.Rating_Proposed_By_Program__c);
        inspectionToUpdate.Learning_And_Development_Domain_Rating__c = getRatings(allFindings, 'Learning & Development');
        
        inspectionToUpdate.SQ_PD_Domain_Points__c = getPoints(allFindings, 'Staff Quals and PD',inspectionToUpdate.Rating_Proposed_By_Program__c);
        inspectionToUpdate.SQ_PD_Domain_Rating__c = getRatings(allFindings, 'Staff Quals and PD');
        
        
        inspectionToUpdate.Ratio_Group_Size_Domain_Points__c = getPoints(allFindings, 'Ratio',inspectionToUpdate.Rating_Proposed_By_Program__c);
        //objIns.Ratio_Group_Size_Domain_Ratings__c = getRatings(allFindings, 'Ratio & Group Size');
         inspectionToUpdate.concurrentFlag__c=false;//TFS#15842 
         if(inspectionToUpdate.Id!=null){
         update inspectionToUpdate;
         }
    }
    
    @AuraEnabled
    public static String getRatings(List<CLQ_Findings__c> findingsList, String domain){
        System.debug('Inspection->getRatings->findingsList--->' + findingsList);
        System.debug('Inspection->getRatings->findingsList size-->' + findingsList.size());
        String rating = '10';
        
        Integer timesRun = 0; //TODO: remove
        
        for(CLQ_Findings__c fin: findingsList){
            system.debug('fin.Rating__c--->' + fin.Rating__c);
            system.debug('fin-->' + fin);
            if(fin.Rating__c != NULL && domain.equals(fin.CLQ_Domain_Rule__r.CLQ_Domain_Name__c)){
                if(fin.Rating__c == 'D') { //check if D
                    rating = 'D';
                }
                else if(rating != 'D' && Decimal.ValueOf(rating) > Decimal.ValueOf(fin.Rating__c)){ //otherwise, take the new rating
                    rating = String.valueOf(fin.Rating__c);
                    timesRun++;
                }
            }
        }
        
        System.debug('timesRun rating-->' + timesRun);

        if(rating != 'D' && Decimal.ValueOf(rating) == 10){
            return '-';
        }
        return rating;
    }
    
    @AuraEnabled
    public static String getPoints(List<CLQ_Findings__c> findingsList, String domain, String ratingProposedByProgram){
        System.debug('Inspection->getPoints->findingsList--->' + findingsList);
        System.debug('Inspection->getPoints->findingsList size-->' + findingsList.size());
        Decimal points = 0;
        
        Integer timesRun = 0; //TODO: remove
        
        for(CLQ_Findings__c fin : findingsList){
            system.debug('fin.Points__c--->' + fin.Points__c);
            if(fin.Points__c != NULL  && domain.equals(fin.CLQ_Domain_Rule__r.CLQ_Domain_Name__c) && (ratingProposedByProgram == '4' || ratingProposedByProgram == '5')){
                if(fin.Points__c == 'D') {
                    points = 0;
                } else {
                    points = points + Decimal.valueOf(fin.Points__c);
                }
            }
        }
        
        System.debug('timesRun points-->' + timesRun);
        
        return String.valueOf(points);
        
    }
    //12032 end     
   @AuraEnabled
    public static popupWrapperslist popupOnLoad(String selectedRule,String selectedInspectedRule,string resultselected,string InspId){

        showPopup = true; //variable to define if pop-up needs to be shown or not
      
        popupWrapperList = new list<popupWrapper>(); //list to show the table in pop-up
        popupWrapperFindingList = new list<popupWrapperFindings>();
              //resultselected = ApexPages.currentPage().getParameters().get('resultselected');
        system.debug('====selectedRule===>'+selectedRule);
        system.debug('====selectedInspectedRule===>'+selectedInspectedRule);
        inspectionRecord=[Select id,concurrentFlag__c,CLQ_Use_Rules_Effective_On__c,CLQ_Program_Transaction__r.Id from CLQ_Inspection__c where id=:InspId];
        deskReviewFindings = [Select Id,CLQ_Domain_Rule_Finding__c,CLQ_StandardFindingsName__c,CLQ_Standard_Finding__r.Name,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Domain_Rule__c,Name,CLQ_Standard_Finding__c,Points__c,Rating__c,CLQ_Description__c from CLQ_Findings__c where Program_Transaction__c =:inspectionRecord.CLQ_Program_Transaction__r.Id ];
        rrValidityDate = inspectionRecord.CLQ_Use_Rules_Effective_On__c; 
        
        /*for(domainwithRuleList wrapperRecord : domainRuleWrapperList){
            for(rulewithFinding c : wrapperRecord.rulelist){
                if(selectedInspectedRule == c.ruleRecord.id){
                    resultselected = c.ruleRecord.CLQ_Result__c;
                }
            } 
        }*/
        
        domainRuleFindingList = new list<CLQ_Domain_Rule_Finding__c>();
        
        domainRuleFindingList = [Select Id,CLQ_Domain_Rule__c,CLQ_Domain_Rule__r.CLQ_Rule__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c =: selectedRule];
        String rulesToShow = '';
        Id DomainRuleId ; 
        if(selectedRule != null){
          DomainRuleId = Id.valueOf(selectedRule);
        }
        //Anil's Code
        List<CLQ_Domain_Rule_Finding__c> associatedStandardFindings =  new List<CLQ_Domain_Rule_Finding__c>();
        List<CLQ_Domain_Rule_Finding__c> associatedStandardFindingsSQandPD =  new List<CLQ_Domain_Rule_Finding__c>();
        

        CLQ_Domain_Rule__c domainRule = [Select Id,Name,CLQ_Domain__c,CLQ_Domain__r.Name from CLQ_Domain_Rule__c where Id =:DomainRuleId];
        String DomainName = '';
        
        if(domainRule!= null){
            DomainName = domainRule.CLQ_Domain__r.Name;
        }
        
        List<CLQ_Findings__c> drFindingforDomain = new List<CLQ_Findings__c>();
        Map<Id,CLQ_Findings__c> drFindingForDomainMap = new Map<Id,CLQ_Findings__c>();
        for(CLQ_Findings__c drFindings : deskReviewFindings){
          if(drFindings.CLQ_Domain_Rule__c == DomainRuleId){
            drFindingforDomain.add(drFindings);
            drFindingForDomainMap.put(drFindings.CLQ_Domain_Rule__c,drFindings);
          }
        }
        
        existingFindingsMap = new Map<String,CLQ_Findings__c>();
        List<CLQ_Findings__c> existingFindingResults = new List<CLQ_Findings__c>();
        existingFindingResults = [Select Id,Name,Rule__c,CLQ_StandardFindingsName__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__c,CLQ_Rules_Inspected__c,CLQ_Domain_Rule__r.CLQ_Rule__c,Rating__c,Points__c,CLQ_Description__c,CLQ_Domain_Rule__c from CLQ_Findings__c where CLQ_Inspection__c =: InspId];
        
        System.debug('EXISTING FINDINGS' + existingFindingResults);
        if(existingFindingResults.size()> 0){
            for(CLQ_Findings__c existFinding : existingFindingResults){
                existingFindingsMap.put(existFinding.CLQ_StandardFindingsName__c+existFinding.CLQ_Domain_Rule__c,existFinding );// for 11396: Included CLQ_Domain_Rule__c
                existingFindingSQandPDMap.put(existFinding.CLQ_Domain_Rule__c,existFinding);
            }
        }
        
        System.debug('EXISTING MAP' + existingFindingsMap);
        System.debug('EXISTING SQ and PD  MAP' + existingFindingSQandPDMap);
        if(inspection.CLQ_Program_Transaction__r.RecordTypeId == onGoingRECId || inspection.CLQ_Program_Transaction__r.RecordTypeId == InitialId){
            associatedStandardFindings = [Select Id,Name,CLQ_Standard_Finding__r.CLQ_Description__c,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Points__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__r.CLQ_Rating__c,CLQ_Standard_Finding__r.Met_Not_Met__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c  =: DomainRuleId and CLQ_Standard_Finding__r.Domain__c != 'Staff Qualifications & Professional Development' and ((CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c != NULL AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= :rrValidityDate) AND (CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = NULL OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= :rrValidityDate)) order by CLQ_Order_Number__c]; //15267 //13564 Added condition to pull findings in effect
            associatedStandardFindingsSQandPD = [Select Id,Name,CLQ_Standard_Finding__r.CLQ_Description__c,CLQ_Domain_Rule__c,CLQ_Standard_Finding__r.CLQ_Points__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__r.CLQ_Rating__c,CLQ_Standard_Finding__r.Met_Not_Met__c from CLQ_Domain_Rule_Finding__c where CLQ_Domain_Rule__c  =: DomainRuleId and CLQ_Standard_Finding__r.Domain__c = 'Staff Qualifications & Professional Development' and ((CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c != NULL AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= :rrValidityDate) AND (CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = NULL OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= :rrValidityDate)) order by CLQ_Order_Number__c]; //15267 //13564 Added condition to pull findings in effect
            
            System.debug('###########' + associatedStandardFindingsSQandPD);
            System.debug('&&&&&&&&&&&&' + associatedStandardFindings);
           // for(CLQ_Standard_Findings__c standardFinding : associatedStandardFindingsSQandPD)
        
        
          for(CLQ_Domain_Rule_Finding__c standardFinding : associatedStandardFindingsSQandPD){
           System.debug('SF NAME' + standardFinding.CLQ_Standard_Finding__r.Name);
                String domainKey = standardFinding.CLQ_Standard_Finding__r.Name+standardFinding.CLQ_Domain_Rule__c; // for 11396
                if(existingFindingsMap.get(domainKey) != null && existingFindingsMap.get(domainKey).CLQ_Domain_Rule__c == standardFinding.CLQ_Domain_Rule__c){
                      //showStandardFindings = true;
                    showFindings = true;
                    // for 11396
                    //popupWrapper wrapperRecord = new popupWrapper(true,existingFindingsMap.get(domainKey),existingFindingsMap.get(domainKey).Rating__c,existingFindingsMap.get(domainKey).Points__c,existingFindingsMap.get(domainKey).CLQ_Description__c,existingFindingsMap.get(domainKey).CLQ_StandardFindingsName__c); //Commenting for 15267
                    popupWrapperFindings dispWrapperFindingRecord = new popupWrapperFindings(true,existingFindingsMap.get(domainKey),existingFindingsMap.get(domainKey).Rating__c,existingFindingsMap.get(domainKey).Points__c,existingFindingsMap.get(domainKey).CLQ_Description__c,existingFindingsMap.get(domainKey).CLQ_StandardFindingsName__c,null);                    
                      //system.debug('====> inside if existing'+ wrapperRecord);
                      //popupWrapperList.add(wrapperRecord); //Commenting for 15267
                      popupWrapperFindingList.add(dispWrapperFindingRecord); // Updated for 15267
                     // domainRuleIds.add(existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Domain_Rule__c);
               }
           
            
           else{ System.debug('STANDARD FINDINGS NAME'+ standardFinding.CLQ_Standard_Finding__r.Name); 
               //System.debug('domain rule of existing finding'+ existingFindingsMap.get(standardFinding.CLQ_Standard_Finding__r.Name).CLQ_Domain_Rule__c );
              // System.debug('DOMAIN RULE IDS' domainRuleIds);
               //System.debug('domain rule of desk review finging' + drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).CLQ_Domain_Rule__c);
               if(drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c) != null && standardFinding.CLQ_Standard_Finding__r.Name == drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).CLQ_Standard_Finding__r.Name && existingFindingSQandPDMap.get(standardFinding.CLQ_Domain_Rule__c) == null){
                    System.debug('domain rule of desk review finging' + drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).CLQ_Domain_Rule__c);
                    showFindings = true;  
                    System.debug('DeskReviewFinding Record'+ drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c));
                    popupWrapperFindings wrapperFindingRecord = new popupWrapperFindings(true,drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c),drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).Rating__c,drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).Points__c,drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).CLQ_Description__c,standardFinding.CLQ_Standard_Finding__r.Name,drFindingForDomainMap.get(standardFinding.CLQ_Domain_Rule__c).CLQ_Standard_Finding__c ); //Commenting for 15267
                                  //system.debug('if findings match====>'+wrapperFindingRecord); //Commenting for 15267
                                  popupWrapperFindingList.add(wrapperFindingRecord);  // Updated for 15267
                  }
               
                  else{
                    System.debug('INSIDE second if');
                    CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = standardFinding.CLQ_Standard_Finding__r.Id
                                                                                       ,CLQ_Description__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                                                       ,Points__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                                                       ,CLQ_StandardFindingsName__c = standardFinding.CLQ_Standard_Finding__r.Name
                                                                                       ,Rating__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                                                       ,CLQ_Domain_Rule_Finding__c = standardFinding.id
                                                                                      );
                    //showStandardFindings = true;
                    showFindings = true;  
                                 //popupWrapper wrapperRecord = new popupWrapper(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c); //Commenting for 15267
                                 popupWrapperFindings dispWrapperFindingRecord = new popupWrapperFindings(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c,null);                      
                                 //system.debug('if findings does not match====>'+wrapperRecord); //Commenting for 15267
                                 //popupWrapperList.add(wrapperRecord); //Commenting for 15267
                                 popupWrapperFindingList.add(dispWrapperFindingRecord); // Updated for 15267
                    }
            }
                     
         }
          
          domainRuleIds.clear();
          
      
            
            for(CLQ_Domain_Rule_Finding__c standardFinding : associatedStandardFindings){
                String domainKey = standardFinding.CLQ_Standard_Finding__r.Name+standardFinding.CLQ_Domain_Rule__c; //for 11396
                    System.debug('Standard finding Name '+ standardFinding.CLQ_Standard_Finding__r.Name );
                system.debug('Map Name --'+existingFindingsMap.get(domainKey));
                if(existingFindingsMap.get(domainKey)!= null && existingFindingsMap.get(domainKey).CLQ_StandardFindingsName__c == standardFinding.CLQ_Standard_Finding__r.Name && existingFindingsMap.get(domainKey).CLQ_Domain_Rule__c == standardFinding.CLQ_Domain_Rule__c){
                  System.debug('INSIDE FIRST IF');
                  showStandardFindings = true;
                    popupWrapper wrapperRecord = new popupWrapper(true,existingFindingsMap.get(domainKey),existingFindingsMap.get(domainKey).Rating__c,existingFindingsMap.get(domainKey).Points__c,existingFindingsMap.get(domainKey).CLQ_Description__c,existingFindingsMap.get(domainKey).CLQ_StandardFindingsName__c);
                  system.debug('====> inside if '+wrapperRecord);
                  popupWrapperList.add(wrapperRecord);
              }
              else{
                     CLQ_Findings__c finding = new CLQ_Findings__c( CLQ_Standard_Finding__c = standardFinding.CLQ_Standard_Finding__r.Id
                                                                                   ,CLQ_Description__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                                                   ,Points__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Points__c
                                                                                   ,CLQ_StandardFindingsName__c = standardFinding.CLQ_Standard_Finding__r.Name
                                                                                   ,Rating__c = standardFinding.CLQ_Standard_Finding__r.CLQ_Rating__c
                                                                                   ,CLQ_Domain_Rule_Finding__c = standardFinding.id
                                                                                  );
                    
                    showStandardFindings = true;
                    popupWrapper wrapperRecord = new popupWrapper(false,finding,finding.Rating__c,finding.Points__c,finding.CLQ_Description__c,finding.CLQ_StandardFindingsName__c);
                    system.debug('====>'+wrapperRecord);
                    popupWrapperList.add(wrapperRecord);
              }
                
            }
            
        }
       system.debug('====>'+popupWrapperList.size());
       System.debug('popupWrapperList is ' + popupWrapperList);
        System.debug('popupWrapperFindingList is ' + popupWrapperFindingList);
        popupWrapperslist pwl=new popupWrapperslist(popupWrapperFindingList,popupWrapperList);
        return pwl;
    }
    
    

    
    //on save Popup button
    //@param: none
    //@return: pagereference
    
    @AuraEnabled
    public static string savePopUp(string selectedRule,string InspId, list<popupWrapper> popupWrapperList){
        try{
            showPopup = false;
            existingFindings = [Select Id,Name,Rule__c,CLQ_Standard_Finding__r.Name,CLQ_Standard_Finding__c,CLQ_Rules_Inspected__c,CLQ_Domain_Rule__r.CLQ_Rule__c from CLQ_Findings__c where CLQ_Inspection__c =: InspId];
            
           
            Map<Id,Id> domainRuleToRule = new Map<Id,Id>();
            System.Debug('SELECTED RULE'+ selectedRule);
            CLQ_Domain_Rule__c domainRule = [Select Id,Name,CLQ_Rule__c from CLQ_Domain_Rule__c where Id =: selectedRule];
            list<CLQ_Findings__c> findinglisttoInsert = new list<CLQ_Findings__c>();
            if(domainRule != null){
              domainRuleToRule.put(domainRule.Id,domainRule.CLQ_Rule__c);
            
            }
            String newsDescription = '';
             Integer selectedCount = 0;
             Integer selectedCountDR = 0;
             Integer selectedCountSQandPD = 0;
             Set<Id> standardFindings = new Set<Id>();
          
            for(popupWrapper findingWrapper: popupWrapperList){
                 if(findingWrapper.isSelected == true){
                     selectedCount = selectedCount + 1;
                     standardFindings.add(findingWrapper.standardFindings.CLQ_Standard_Finding__c);
                 }
            }
            System.debug('SF SET'+ standardFindings);
            //if(standardFindings.size() > 0 ){
                //Map<Id,CLQ_Standard_Findings__c> standardFindingMap = new Map<Id,CLQ_Standard_Findings__c>([Select Id,Name,Domain__c from CLQ_Standard_Findings__c where Id IN:standardFindings and Domain__c = 'Staff Qualifications and Professional Development']);
             List<CLQ_Standard_Findings__c> standardFindingList = new List<CLQ_Standard_Findings__c>([Select Id,Name,Domain__c from CLQ_Standard_Findings__c where Id IN:standardFindings]);
             System.debug('SF MAP'+ standardFindingList);
            
            if(standardFindingList.size() > 0 ){
                for(CLQ_Standard_Findings__c standardFinding : standardFindingList){
                  if(standardFinding.Domain__c == 'Staff Qualifications & Professional Development'){
                  selectedCountSQandPD  = selectedCountSQandPD + 1;
                  }  
                }
            }
            System.debug('SELECTESQAND PD '+ selectedCountSQandPD );
            //Updated from popupwrapper
            /*for(popupWrapperFindings findingWrapper: popupWrapperFindingList){
                 if(findingWrapper.isSelected == true){
                     selectedCountDR = selectedCountDR + selectedCountSQandPD + 1;
                 }
            }
            System.debug('SELECT COUNT'+ selectedCount + 'selectedCountDR --> ' +selectedCountDR);
            if(selectedCount > 1 || selectedCountDR > 1){
                  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You may only select one standard finding for each rule');
                  ApexPages.addMessage(myMsg);
                  return null;
            }*/
            //Loop to check with record is selected or not
            System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ popuplist'+popupWrapperList);
            if(popupWrapperList != null){
                for(popupWrapper findingWrapper: popupWrapperList){
                    if(findingWrapper.isSelected == true){
                        newsDescription = findingWrapper.standardFindings.CLQ_Description__c;
                        CLQ_Findings__c findingToInsert = new CLQ_Findings__c();
                        findingToInsert.CLQ_Rules_Inspected__c = selectedInspectedRule;
                        findingToInsert.CLQ_Domain_Rule__c = selectedRule;
                        if(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c)!= null){
                          findingToInsert.Rule__c = domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c);
                        }
                        findingToInsert.Rating__c = findingWrapper.rating ;
                        findingToInsert.CLQ_Standard_Finding__c = findingWrapper.standardFindings.CLQ_Standard_Finding__c;
                        findingToInsert.Points__c = findingWrapper.point ;
                        findingToInsert.CLQ_Description__c = newsDescription;
                        findingToInsert.CLQ_Inspection__c = InspId;
                        findingToInsert.CLQ_StandardFindingsName__c = findingWrapper.standardFindings.CLQ_StandardFindingsName__c;
                        findingToInsert.CLQ_Domain_Rule_Finding__c = findingWrapper.standardFindings.CLQ_Domain_Rule_Finding__c ;
                        findinglisttoInsert.add(findingToInsert);    
                    }
                }
            }
            if(popupWrapperFindingList != null){
                for(popupWrapperFindings findingWrapper: popupWrapperFindingList){
                    if(findingWrapper.isSelected == true){
                        newsDescription = findingWrapper.standardFindings.CLQ_Description__c;
                        CLQ_Findings__c findingToInsert = new CLQ_Findings__c();
                        findingToInsert.CLQ_Rules_Inspected__c = selectedInspectedRule;
                        findingToInsert.CLQ_Domain_Rule__c = selectedRule;
                        if(domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c)!= null){
                          findingToInsert.Rule__c = domainRuleToRule.get(findingToInsert.CLQ_Domain_Rule__c);
                        }
                        findingToInsert.Rating__c = findingWrapper.rating ;
                        // Updated for 15267
                        if(findingWrapper.standardFindingId != null)
                            findingToInsert.CLQ_Standard_Finding__c = findingWrapper.standardFindingId;
                        else
                            findingToInsert.CLQ_Standard_Finding__c = findingWrapper.standardFindings.CLQ_Standard_Finding__c; 
                        findingToInsert.Points__c = findingWrapper.point ;
                        findingToInsert.CLQ_Description__c = newsDescription;
                        findingToInsert.CLQ_Inspection__c = InspId;
                        findingToInsert.CLQ_StandardFindingsName__c = findingWrapper.standardFindings.CLQ_StandardFindingsName__c;
                        findingToInsert.CLQ_Domain_Rule_Finding__c = findingWrapper.standardFindings.CLQ_Domain_Rule_Finding__c ;
                        findinglisttoInsert.add(findingToInsert);    
                    }
                }
            }            
           
            if(findinglisttoInsert.size()>0){
                insert findinglisttoInsert;
                for(CLQ_Findings__c finding : findinglisttoInsert){
                  System.debug('FINDING RULES'+ finding.Rule__c);
                }
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
    
            //insert new findings
            //loadData();
        }
        catch(Exception e){
            System.debug('Exception ' + e.getMessage());
            return e.getMessage();
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static void createRulesInspected(string InspId){
        onGoingRECId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Ongoing Registration').getRecordTypeId();
        annualId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Annual Report').getRecordTypeId();
        InitialId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByName().get('SUTQ - Initial Registration').getRecordTypeId();
        try{   
        inspection = [Select Id,Name,CLQ_Program_Transaction__c,CLQ_Program_Transaction__r.Id,CLQ_Use_Rules_Effective_On__c,CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c,CLQ_Program_Transaction__r.Recommended_Rating__c,CLQ_Program_Transaction__r.RecordTypeId, Rating_Proposed_By_Program__c from CLQ_Inspection__c where Id =: InspId ]; //12032 added Rating_Proposed_By_Program__c
        System.debug('@@@@@@@@@@ inspection PT ID'+ inspection.CLQ_Program_Transaction__r.Id);
           rrValidityDate = inspection.CLQ_Use_Rules_Effective_On__c; 
           list<CLQ_Inspection_Tools__c> inspectionToolList = new list<CLQ_Inspection_Tools__c>();
           list<CLQ_Inspection_Tools__c> inspectionToolFinalList = new list<CLQ_Inspection_Tools__c>();
           Set<Id> inspectionToolIds = new Set<Id>();
           inspectionToolList = [SELECT ID
                                    ,CLQ_Applicable_To__c
                                    ,CLQ_Description__c
                                    ,CLQ_Active__c
                                    ,PTEstimatedDeskRating_c__c
                                    ,CLQ_Is_Related_to_Program_Transaction__c
                                    ,CLQ_Onsite__c
                                    ,Name
                                FROM CLQ_Inspection_Tools__c
                                where CLQ_Onsite__c = true
                                ];
            System.debug('&&&&&&&&&& inspection tool list' + inspectionToolList);
            if(!Test.isRunningTest()){
                for(CLQ_Inspection_Tools__c inspectionTool : inspectionToolList){
                    
                        if(inspection.CLQ_Program_Transaction__c != null){
                            if(inspection.CLQ_Program_Transaction__r.RecordTypeId == onGoingRECId || inspection.CLQ_Program_Transaction__r.RecordTypeId == InitialId){
                                if(inspectionTool.CLQ_Onsite__c == true && (inspectionTool.CLQ_Applicable_To__c != null && (inspectionTool.CLQ_Applicable_To__c).contains(inspection.CLQ_Program_Transaction__r.CLQ_Program_Record_Type__c)) && (inspectionTool.PTEstimatedDeskRating_c__c != null && inspection.CLQ_Program_Transaction__r.Recommended_Rating__c != null && (inspectionTool.PTEstimatedDeskRating_c__c).contains(inspection.CLQ_Program_Transaction__r.Recommended_Rating__c))){
                                    System.debug('INSIDE INSPECTION TOOLS IF');
                                    inspectionToolFinalList.add(inspectionTool);
                                    inspectionToolIds.add(inspectionTool.Id);
                                }
                            }
                        }
               }
            }
            
            System.debug('INSPECTION TOOLS'+ inspectionToolIds);
            
            list<CLQ_Tools_Rules__c> toolRuleList = new list<CLQ_Tools_Rules__c>(); 
            //for(Id insToolId : inspectionToolIds){
                
        toolRuleList = [Select Id,Name,CLQ_Domain_Rule__c,CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c, CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c, CLQ_Rules__c,CLQ_Domain_Rule__r.CLQ_Rule__c from CLQ_Tools_Rules__c where CLQ_Inspection_Tools__c IN: inspectionToolIds];//14722 Added the fields for Rule Eff and Exp
           // }
           Set<String> domainrule = new Set<String>();
           for(CLQ_Tools_Rules__c toolRule : toolRuleList){
                domainrule.add(toolRule.CLQ_Domain_Rule__c);
           }//end for loop
           System.debug('@#@#@#@#@ domain rules' + domainrule );
           list<CLQ_Rules_Inspected__c> ruleInspectedList = new list<CLQ_Rules_Inspected__c>();
           list<CLQ_Rules_Inspected__c> rulesInspectedToBeDeleted = new list<CLQ_Rules_Inspected__c>();
           for(CLQ_Tools_Rules__c toolRule : toolRuleList){
            if((toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c != NULL && toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c <= rrValidityDate) && (toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c == NULL || toolRule.CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c >= rrValidityDate)){//14722 Added the condition to filter the Rules not in effect
                    ruleInspectedList.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c =toolRule.CLQ_Domain_Rule__c,CLQ_Rule__c = toolRule.CLQ_Domain_Rule__r.CLQ_Rule__c ,CLQ_Inspection_No__c = InspId ));   
                } 
            }//end for loop
            rulesInspectedToBeDeleted = [Select Id from CLQ_Rules_Inspected__c where CLQ_Inspection_No__c =: InspId];
            System.debug('RECORDS TO BE DELETED'+ rulesInspectedToBeDeleted);
            /*
            if(rulesInspectedToBeDeleted.size() >0){
             delete rulesInspectedToBeDeleted;
            }
            
            
            if(ruleInspectedList.size()>0){   
                    insert ruleInspectedList; 
                }*/
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
        @AuraEnabled
        public CLQ_Rules_Inspected__c ruleRecord{get;set;}
        @AuraEnabled
        public Boolean showRule{get;set;}
        @AuraEnabled
        public String rating{get;set;}
        @AuraEnabled
        public String point{get;set;}
  
        public rulewithFinding(CLQ_Rules_Inspected__c ruleRecord){
            this.ruleRecord = ruleRecord;
            showRule = true;
        }
        
        public rulewithFinding(CLQ_Rules_Inspected__c ruleRecord,String sRating,String sPoint){
            this.ruleRecord = ruleRecord;
            this.rating = sRating;
            this.point = sPoint;
            showRule = true;
        }
        
    }

    //parent wrapper
    public class domainwithRuleList{
        @AuraEnabled
        public String domainID{get;set;}
        @AuraEnabled
        public String domainName{get;set;}
        @AuraEnabled
        public list<rulewithFinding> rulelist{get;set;}
        @AuraEnabled
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
        @AuraEnabled
        public Boolean isSelected{get;set;}
        @AuraEnabled
        public CLQ_Findings__c standardFindings{get;set;}
        @AuraEnabled
        public String sFindingCode{get;set;}
        @AuraEnabled
        public String rating{get;set;}
        @AuraEnabled
        public String point{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public String sfindingName{get;set;}
        public popupWrapper(){}
        public popupWrapper(Boolean isSelected,CLQ_Findings__c sfinding,String sRating,String sPoints,String sDescription, String sName){
            this.isSelected = isSelected;
            this.standardFindings = sfinding;
            this.rating = sRating;
            this.point = sPoints;
            this.description = sDescription;
            this.sfindingName = sName;
        }
    }
    public class popupWrapperFindings{
        @AuraEnabled
        public Boolean isSelected{get;set;}
        @AuraEnabled
        public CLQ_Findings__c standardFindings{get;set;}
        @AuraEnabled
        public Id standardFindingId{get;set;}
        @AuraEnabled
        public String sFindingCode{get;set;}
        @AuraEnabled
        public String rating{get;set;}
        @AuraEnabled
        public String point{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public String sfindingName{get;set;}
        
        public popupWrapperFindings(Boolean isSelected,CLQ_Findings__c sfinding,String sRating,String sPoints,String sDescription, String sName, Id sId){
            this.isSelected = isSelected;
            this.standardFindings = sfinding;
            this.rating = sRating;
            this.point = sPoints;
            this.description = sDescription;
            this.sfindingName = sName;
            this.standardFindingId = sId;
        }
    }
    
    public class popupWrapperslist{
        @AuraEnabled
        public list<popupWrapperFindings> popupWrapperFindings1{get;set;}
        @AuraEnabled
        public list<popupWrapper> popupWrapper1{get;set;}
        
         public popupWrapperslist(list<popupWrapperFindings> popupWrapperFindings1,list<popupWrapper> popupWrapper1){
            this.popupWrapperFindings1 = popupWrapperFindings1;
            this.popupWrapper1 = popupWrapper1;
             }
       
    }
    
    /**************************************Wrapper Class section ends *********************************************/




}