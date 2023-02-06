public with sharing class CLQ_VisitModeController_Lightning {
    
    public static final string COMPLAINT = 'Compliant';
    public static final string EMPTY = '';
    public static final string Serious = 'Serious';
    public static final string Moderate = 'Moderate';
    public static final string Low = 'Low';
    public static final string CAP = 'CAP';
    public static final string TA = 'TA';
    public static final string Non_Compliant = 'Non-Compliant';
    //New Method for LWC - Unchanged from the original VF controller
    @AuraEnabled
    public static ISD_CreateLightningServerResponse getInitData(Id inspectionRecId) {
        
        Boolean bIsSuccessful = true;
        Map<String, object> mapErrorInfo = new Map<String, object>();
        Map<String, object> mapObjectData = new Map<String, object>();
        
        List<String> domainOptions = new List<String>();
        List<String> filterOptions = new List<String>();
        List<String> resultOptions = new List<String>();
        List<DomainwithRuleList>domainRuleWrapperList = new List<DomainwithRuleList>();
        CLQ_Inspection__c oInspection;
        if(inspectionRecId!=null){
            oInspection = [SELECT Id, Name FROM CLQ_Inspection__c WHERE Id =: inspectionRecId];
        }
        
        mapObjectData.put('inspectionNumber', oInspection.Name);
        
        //String domainName = '';
        set<id> standardFindingRuleIDSet = new set<id>(); //variable to store all standard findings id
        set<String> domainNameSet = new set<String>(); //store unique domain names
        map<String,id> domainNameIdMap = new map<String,Id>();
        map<id,String> ruleInspectedFindingCodeMap = new map<id,String>(); //Map all rule inspected with its code
        map<id,String> ruleInspectedDescriptionMap = new map<id,String>(); //Map all rule inspected with its description
        map<id,String> ruleInspectedTADescriptionMap = new map<id,String>(); //Map all rule inspected with its TA description
        set<id> domainRuleIDSet = new set<id>();
        
        //Get all rule inspected for given insepection
        list<CLQ_Rules_Inspected__c> ruleinspectedlist = pullRuleInspectedforInspection(inspectionRecId);
        domainOptions.add('All');
        
        //Populate rule filter drop-down with pre-defined values
        filterOptions = populateRuleFilter();
        
        //Populate apply result drop down
        resultOptions = populateresultFilter();
        
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
            String selectedFindingsTADescriptions = '';
            if(ruleInspected.Findings__r != null){
                for(CLQ_Findings__c findingRecord : ruleInspected.Findings__r){
                    if(findingRecord.CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.Name != null && findingRecord.CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.Name != EMPTY){
                        selectedFindings =findingRecord.CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.Name+'<br>'+selectedFindings;
                    }
                    if(findingRecord.CLQ_Description__c != null && findingRecord.CLQ_Description__c != EMPTY){
                        selectedFindingsDescriptions =findingRecord.CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Finding_Code__c+': '+findingRecord.CLQ_Description__c+'<br>'+selectedFindingsDescriptions;
                    }
                    if(findingRecord.CLQ_TA_Description__c != null && findingRecord.CLQ_TA_Description__c!= EMPTY){
                        selectedFindingsTADescriptions =findingRecord.CLQ_TA_Description__c+'<br>'+selectedFindingsTADescriptions ;
                    }
                }
                system.debug('===>description===>'+selectedFindingsDescriptions);
                selectedFindings.removeEnd('<br>');
                selectedFindingsDescriptions.removeEnd('<br>');
                selectedFindingsTADescriptions.removeEnd('<br>');
            }
            ruleInspectedFindingCodeMap.put(ruleInspected.id,selectedFindings);
            ruleInspectedDescriptionMap.put(ruleInspected.id,selectedFindingsDescriptions);
            ruleInspectedTADescriptionMap.put(ruleInspected.id,selectedFindingsTADescriptions);
        }
        
        //Get the Domain Rules 
        map<id,CLQ_Domain_Rule__c> mapIDDomainRule;
        if(domainRuleIDSet!=null){
            mapIDDomainRule = new map<id,CLQ_Domain_Rule__c>([SELECT id,(SELECT id ,Name,CLQ_Regulation__r.CLQ_Reg_key__c
                                                                         ,CLQ_Regulation__r.Name
                                                                         FROM Rule_Regulations__r LIMIT 1999)
                                                              FROM CLQ_Domain_Rule__c
                                                              WHERE id in :domainRuleIDSet]);
        }
        
        
        //Get all Rules and its related Standard Findings
        list<CLQ_Rule__c> rulelist;
        if(standardFindingRuleIDSet!=null){
            rulelist = [Select ID,CLQ_Domain__c,(SELECT id
                                                 ,Name
                                                 FROM Standard_Findings__r LIMIT 1999)
                        FROM CLQ_Rule__c
                        WHERE id in :standardFindingRuleIDSet];
        }
        
        map<id,String> inspectedRuleRegulationMap = new map<id,String>();
        
        //Prepare data to show Regulation
        for(CLQ_Domain_Rule__c domainRuleRecord : mapIDDomainRule.values()){
            String regulation = '';
            if(mapIDDomainRule.size()!=0 && mapIDDomainRule.get(domainRuleRecord.id) != null 
               && mapIDDomainRule.get(domainRuleRecord.id).Rule_Regulations__r != null){
                   for(CLQ_Junction_RuleRegs__c regulationrecord : mapIDDomainRule.get(domainRuleRecord.id).Rule_Regulations__r){
                       if(regulationrecord.CLQ_Regulation__r.Name !=EMPTY){regulation =regulation+', '+ regulationrecord.CLQ_Regulation__r.Name;}
                       
                   }
                   regulation = regulation.removeStart(',');
                   regulation.removeEnd(',');
                   inspectedRuleRegulationMap.put(domainRuleRecord.id,regulation); 
               }
        }
        
        //Now store the data in wrapper class structure so that we can display that in VF page
        for(String domainName : domainNameSet){
            //populate the domain option
            domainOptions.add(domainName);
            list<rulewithFinding> rulewithFindingList = new list<rulewithFinding>();
            for(CLQ_Rules_Inspected__c ruleInspected : ruleinspectedlist){
                String regulation = '';
                if(domainName == ruleInspected.CLQ_Domain_Rule__r.CLQ_Domain__r.Name){
                    
                    if(inspectedRuleRegulationMap.size()!=0 && inspectedRuleRegulationMap.get(ruleInspected.CLQ_Domain_Rule__c)!= null){
                        regulation = inspectedRuleRegulationMap.get(ruleInspected.CLQ_Domain_Rule__c);
                    }
                    //Make 'Not Verified' as defult result value
                    /*if(ruleInspected.CLQ_Result__c == '' || ruleInspected.CLQ_Result__c == null){
ruleInspected.CLQ_Result__c = 'Not Verified';
}*/
                    
                    //Result field picklist options based on Alleged rule or not - CR 11415
                    List<String> ruleResultSelectOption = new List<String>();
                    System.Debug('ruleInspected.CLQ_Alleged_Rule__c *** '+ruleInspected.CLQ_Alleged_Rule__c);
                    //Added to get the select list options based on the Rules inspected if Alleged rule or no
                    ruleResultSelectOption = populateRuleAllegedFilter(ruleInspected.CLQ_Alleged_Rule__c);
                    if(ruleInspectedFindingCodeMap.size()!=0 && ruleInspectedDescriptionMap.size()!=0 && ruleInspectedTADescriptionMap.size()!=0){
                        rulewithFindingList.add(
                            new rulewithFinding(
                                ruleInspected, 
                                ruleInspectedFindingCodeMap.get(ruleInspected.id), 
                                ruleInspectedDescriptionMap.get(ruleInspected.id), 
                                regulation, 
                                ruleInspectedTADescriptionMap.get(ruleInspected.id), 
                                ruleResultSelectOption
                            )
                        );//Added ruleResultSelectOption for CR - 11415 
                    }
                }
                
            }
            DomainwithRuleList wrapperRecord;
            if(domainNameIdMap.size()!=0){
                wrapperRecord = new DomainwithRuleList(domainNameIdMap.get(domainName),domainName,rulewithFindingList);
            }
            domainRuleWrapperList.add(wrapperRecord);
            
        }
        
        mapObjectData.put('domainOptions', domainOptions);
        mapObjectData.put('filterOptions', filterOptions);
        mapObjectData.put('resultOptions', resultOptions);
        mapObjectData.put('domainRuleWrapperList', domainRuleWrapperList);
        
        return new ISD_CreateLightningServerResponse(bIsSuccessful, mapErrorInfo, mapObjectData);
        
    }
    
    @AuraEnabled
    public static ISD_CreateLightningServerResponse loadFindings(String selectedRule, Id selectedInspectedRule, String resultSelected, Id inspectionRecordId) {
        Boolean bIsSuccessful = true;
        Map<String, object> mapErrorInfo = new Map<String, object>();
        Map<String, object> mapObjectData = new Map<String, object>();
        CLQ_Inspection__c inspectionRecord;
        if(inspectionRecordId!=null){
            inspectionRecord = [SELECT Id, CLQ_Use_Rules_Effective_On__c FROM CLQ_Inspection__c WHERE Id =: inspectionRecordId];
        }
        Date sfValidityDate = inspectionRecord.CLQ_Use_Rules_Effective_On__c;
        List<PopupWrapper> popupWrapperList = new List<PopupWrapper>(); //list to show the table in pop-up
        
        system.debug('====selectedRule===>'+selectedRule);
        system.debug('====selectedInspectedRule===>'+selectedInspectedRule);
        Map<Id, CLQ_Corrective_Action_Plan__c> existingCorrectiveActionPlanMap = new Map<Id, CLQ_Corrective_Action_Plan__c>();
        
        String rulesToShow = '';
        List<CLQ_Domain_Rule_Finding__c> standardFindingList = new List<CLQ_Domain_Rule_Finding__c>();
        List<CLQ_Findings__c> findinglist = new List<CLQ_Findings__c>();
        Map<Id, CLQ_Findings__c> existingStandardFindingIdMap = new Map<Id, CLQ_Findings__c>();
        
        if(resultselected != EMPTY && resultselected == COMPLAINT){ 
            rulesToShow = 'Documenting Statement';
        }
        
        //Get all the Findings stored for the rule
        List<String> extraFieldofFindings = new list<String>{'CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__c','CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Integration_Document_Type__c','(SELECT id FROM Corrective_Action_Plans__r)'};
            
            //TODO: maybe add some logic here
            string strselectedInspectedRule ='\''+String.escapeSIngleQuotes(selectedInspectedRule)+'\'';
        String sFindingQuery ='SELECT id,ownerid,isdeleted,name,createddate,createdbyid,lastmodifieddate,lastmodifiedbyid,systemmodstamp,clq_action_required__c,clq_alleged_finding__c,clq_alleged_rule_violation__c,clq_cap_required__c,clq_cap_ta__c,clq_comments__c,clq_compliance_due_by__c,clq_description_cont__c,clq_description__c,clq_documents_required__c,clq_domain_rule_finding__c,clq_domain_rule__c,clq_external_id__c,clq_finding_description__c,clq_finding_type__c,clq_inspection__c,clq_integration_document_type__c,clq_lrnc__c,clq_mrnc__c,clq_met_not_met__c,clq_non_compliance_points__c,clq_risk_level__c,clq_rules_inspected__c,clq_srnc__c,clq_standardfindingsname__c,clq_standard_finding__c,clq_stnd_finding__c,clq_ta_description__c,clq_ta_required__c,points__c,program_transaction__c,rating__c,rule__c,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__c,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Integration_Document_Type__c,(SELECT id FROM Corrective_Action_Plans__r) FROM CLQ_Findings__c WHERE  CLQ_Rules_Inspected__c =' +strselectedInspectedRule;
        //CLQ_UtilityClass.createSOQLQuery('CLQ_Findings__c', ' CLQ_Rules_Inspected__c ='+'\''+selectedInspectedRule+'\'', extraFieldofFindings);
        //sFindingQuery.remove(',Owner.isActive');
        
        findinglist = Database.query(sFindingQuery);
        //Get all the standard findings for given rule
        //Ramana bug# 11076 - applied efeective standard finding date filters
        extraFieldofFindings = new list<String>{'CLQ_Standard_Finding__r.CLQ_Integration_Document_Type__c','CLQ_Standard_Finding__r.CLQ_Documents_Required_single__c','CLQ_Standard_Finding__r.CLQ_Risk_Level__c','CLQ_Standard_Finding__r.CLQ_Non_Compliance_points__c','CLQ_Standard_Finding__r.CLQ_TA__c','CLQ_Standard_Finding__r.CLQ_CAP__c','CLQ_Standard_Finding__r.Name','CLQ_Standard_Finding__r.CLQ_Finding_Code__c','CLQ_Standard_Finding__r.CLQ_Description__c'};
            
            if(rulesToShow != EMPTY) {
                standardFindingList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Domain_Rule_Finding__c', ' CLQ_Domain_Rule__c ='+'\''+selectedRule+'\' AND CLQ_Standard_Finding__r.CLQ_Finding_Type__c = \''+rulesToShow+'\' AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= '+String.valueOf(sfValidityDate)+' AND ((CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c != null AND CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= '+String.valueOf(sfValidityDate)+') OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = null) ORDER BY CLQ_Order_Number__c ASC', extraFieldofFindings));//15267
                
            } else {
                standardFindingList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Domain_Rule_Finding__c', ' CLQ_Domain_Rule__c ='+'\''+selectedRule+'\' AND CLQ_Standard_Finding__r.CLQ_Finding_Effective_Date__c <= '+String.valueOf(sfValidityDate)+' AND ((CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c != null AND CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c >= '+String.valueOf(sfValidityDate)+') OR CLQ_Standard_Finding__r.CLQ_Finding_Expiration_Date__c = null) ORDER BY CLQ_Order_Number__c ASC', extraFieldofFindings )); //15267
                
            }
        
        //add findings
        for(CLQ_Findings__c finding : findinglist){
            //existingStandardFindingIdMap.put(finding.CLQ_Domain_Rule_Finding__c, finding);
            for(CLQ_Corrective_Action_Plan__c existingCAP : finding.Corrective_Action_Plans__r){
                //existingCorrectiveActionPlanMap.put(finding.id, existingCAP);
            }
        }
        
        //add standard finding in wrapper if it is not already in the list
        for(CLQ_Domain_Rule_Finding__c sFinding : standardFindingList) {
            
            
            
            if(existingStandardFindingIdMap.size()!=0 && existingStandardFindingIdMap.get(sFinding.id) != null) {
                PopupWrapper wrapperRecord = new PopupWrapper(true, existingStandardFindingIdMap.get(sFinding.id), sFinding.CLQ_Standard_Finding__r.CLQ_Finding_Code__c, sFinding.CLQ_Standard_Finding__r.CLQ_Risk_Level__c, sFinding.CLQ_Standard_Finding__r.Name);
                popupWrapperList.add(wrapperRecord);
            } else {
                CLQ_Findings__c newFinding = new CLQ_Findings__c(CLQ_Rules_Inspected__c=selectedInspectedRule
                                                                 ,CLQ_Domain_Rule_Finding__c = sFinding.id
                                                                 ,CLQ_Description__c = sFinding.CLQ_Standard_Finding__r.CLQ_Description__c
                                                                 //,CLQ_Description_Cont__c = sFinding.CLQ_Standard_Finding__r.CLQ_Description_Cont__c
                                                                 ,CLQ_TA_Required__c = sFinding.CLQ_Standard_Finding__r.CLQ_TA__c
                                                                 ,CLQ_CAP_Required__c = sFinding.CLQ_Standard_Finding__r.CLQ_CAP__c
                                                                 ,CLQ_Non_Compliance_points__c = sFinding.CLQ_Standard_Finding__r.CLQ_Non_Compliance_points__c
                                                                 ,CLQ_Documents_Required__c = sFinding.CLQ_Standard_Finding__r.CLQ_Documents_Required_single__c
                                                                 ,CLQ_Integration_Document_Type__c = sFinding.CLQ_Standard_Finding__r.CLQ_Integration_Document_Type__c);
                
                if(newFinding.CLQ_TA_Required__c) {
                    newFinding.CLQ_CAP_TA__c = TA;
                } 
                if(newFinding.CLQ_CAP_Required__c) {
                    newFinding.CLQ_CAP_TA__c = CAP;
                }                                               
                
                PopupWrapper wrapperRecord = new PopupWrapper(false, newFinding, sFinding.CLQ_Standard_Finding__r.CLQ_Finding_Code__c, sFinding.CLQ_Standard_Finding__r.CLQ_Risk_Level__c, sFinding.CLQ_Standard_Finding__r.Name);
                system.debug('====>'+wrapperRecord);
                popupWrapperList.add(wrapperRecord);
                
            }
        }
        
        mapObjectData.put('popupWrapperList', popupWrapperList);
        
        system.debug('====>'+popupWrapperList.size());
        return new ISD_CreateLightningServerResponse(bIsSuccessful, mapErrorInfo, mapObjectData);
    }
    
    @AuraEnabled
    public static ISD_CreateLightningServerResponse saveFindings(Id selectedInspectedRule, String resultSelected, String popupWrapperListJson, Id inspectionRecordId) {
        
        
        
        Boolean bIsSuccessful = true;
        Map<String, object> mapErrorInfo = new Map<String, object>();
        Map<String, object> mapObjectData = new Map<String, object>();
        CLQ_Inspection__c inspectionRecord;
        if(inspectionRecordId!=null){
            inspectionRecord = [SELECT Id, CLQ_Use_Rules_Effective_On__c FROM CLQ_Inspection__c WHERE Id =: inspectionRecordId];
        }
        String newsFindingCode = '';
        String newsDescription = '';
        String newTADescription= '';
        String newriskLevel = '';
        Decimal nonCompliancePoint = 0;
        Decimal srncPoint = 0;
        Decimal lrncPoint = 0;
        Decimal mrncPoint = 0;
        
        list<CLQ_Findings__c> findinglisttoInsert = new list<CLQ_Findings__c>();
        list<CLQ_Findings__c> findinglisttoDelete = new list<CLQ_Findings__c>();
        list<CLQ_Corrective_Action_Plan__c> cAPtoInsert = new list<CLQ_Corrective_Action_Plan__c>();
        list<CLQ_Corrective_Action_Plan__c> cAPtoDelete = new list<CLQ_Corrective_Action_Plan__c>();
        
        List<PopupWrapper> popupWrapperList = new List<PopupWrapper>();
        popupWrapperList = (List<PopupWrapper>) JSON.deserialize(popupWrapperListJson, List<PopupWrapper>.class);
        
        system.debug('========'+selectedInspectedRule);
        system.debug('========'+resultselected);
        
        List<CLQ_Findings__c> existingFindingList = new List<CLQ_Findings__c>();
        existingFindingList = getFindingList(selectedInspectedRule);
        Map<Id, CLQ_Findings__c> existingStandardFindingIdMap = new Map<Id, CLQ_Findings__c>();
        Map<Id, CLQ_Corrective_Action_Plan__c> existingCorrectiveActionPlanMap = new Map<Id, CLQ_Corrective_Action_Plan__c>();
        
        existingStandardFindingIdMap = getExistingStandardFindingIdMap(existingFindingList);
        existingCorrectiveActionPlanMap = getExistingCorrectiveActionPlanMap(existingFindingList);
        
        //Save the result on Rule Inspected
        if(selectedInspectedRule != null){
            CLQ_Rules_Inspected__c selectedRuleInspectedRecord = new CLQ_Rules_Inspected__c(id=selectedInspectedRule,CLQ_Result__c= resultselected); 
            List<CLQ_Rules_Inspected__c> RulesInspectedList = new List<CLQ_Rules_Inspected__c>();
            RulesInspectedList.add(selectedRuleInspectedRecord);
            if(!RulesInspectedList.isEmpty()){
                update RulesInspectedList;
            }
        }
        //Loop to check with record is selected or not
        for(PopupWrapper findingWrapper: popupWrapperList) {
            //if(findingWrapper.isSelected == true){
            system.debug('======='+findingWrapper.finding.CLQ_Non_Compliance_points__c);
            findinglisttoInsert.add(findingWrapper.finding);
            if(findingWrapper.sfindingName != null && findingWrapper.sfindingName!= EMPTY){
                //updated the finding code for inspected rule
                newsFindingCode =findingWrapper.sfindingName+'<br>'+newsFindingCode;
            }
            if(findingWrapper.finding.CLQ_Description__c != null && findingWrapper.finding.CLQ_Description__c  != EMPTY){
                //updated the description for inspected rule
                newsDescription = findingWrapper.sFindingCode+': '+findingWrapper.finding.CLQ_Description__c+'<br>'+newsDescription;
            }
            if(findingWrapper.finding.CLQ_TA_Description__c!= null && findingWrapper.finding.CLQ_TA_Description__c!= EMPTY){
                //updated the description for inspected rule
                newTADescription = findingWrapper.finding.CLQ_TA_Description__c+'<br>'+newTADescription;
            }
            
            if(findingWrapper.riskLevel != EMPTY &&  findingWrapper.riskLevel != null){newriskLevel = newriskLevel +','+findingWrapper.riskLevel;}
            if(findingWrapper.finding.CLQ_Non_Compliance_points__c !=null){nonCompliancePoint = nonCompliancePoint + findingWrapper.finding.CLQ_Non_Compliance_points__c;}
            if(findingWrapper.riskLevel != EMPTY &&  findingWrapper.riskLevel != null && findingWrapper.riskLevel==Serious){srncPoint  = srncPoint + findingWrapper.finding.CLQ_Non_Compliance_points__c;}
            if(findingWrapper.riskLevel != EMPTY &&  findingWrapper.riskLevel != null && findingWrapper.riskLevel==Moderate){mrncPoint = mrncPoint + findingWrapper.finding.CLQ_Non_Compliance_points__c;}
            if(findingWrapper.riskLevel != EMPTY &&  findingWrapper.riskLevel != null && findingWrapper.riskLevel==Low){lrncPoint = lrncPoint + findingWrapper.finding.CLQ_Non_Compliance_points__c;}
            if(findingWrapper.finding.CLQ_CAP_TA__c == CAP){findingWrapper.finding.CLQ_CAP_Required__c = true; findingWrapper.finding.CLQ_TA_Required__c= false;}
            if(findingWrapper.finding.CLQ_CAP_TA__c == TA){findingWrapper.finding.CLQ_TA_Required__c= true; findingWrapper.finding.CLQ_CAP_Required__c = false;}
            
            //}
            //if(findingWrapper.isSelected == false && existingStandardFindingIdMap.get(findingWrapper.finding.CLQ_Domain_Rule_Finding__c) != null){
            //prepare the list to delete
            //findinglisttoDelete.add(findingWrapper.finding);
            
            //}
            
            if((findingWrapper.finding.CLQ_CAP_TA__c == TA || resultselected  != Non_Compliant)  && existingCorrectiveActionPlanMap.size()!=0 && existingCorrectiveActionPlanMap.get(findingWrapper.finding.id) != null){
                cAPtoDelete.add(existingCorrectiveActionPlanMap.get(findingWrapper.finding.id));
            }
            
        }
        newsFindingCode.removeEnd('<br>');
        newsDescription.removeEnd('<br>');
        newTADescription.removeEnd('<br>');
        
        //update the wrapper class with new code and description before completing the method
        /*for(domainwithRuleList parentWrapper : domainRuleWrapperList){
for(rulewithFinding childWrapper : parentWrapper.rulelist){
if(childWrapper.ruleRecord.id == selectedInspectedRule){
childWrapper.sfindingCode = newsFindingCode;
childWrapper.sfindingDescription = newsDescription;
childWrapper.sfindingTADescription = newTADescription;

childWrapper.ruleRecord.CLQ_Risk_Points__c = nonCompliancePoint;
childWrapper.ruleRecord.CLQ_SRNC__c= srncPoint  ;
childWrapper.ruleRecord.CLQ_LRNC__c= lrncPoint ;
childWrapper.ruleRecord.CLQ_MRNC__c= mrncPoint ; 
if(newriskLevel != '' && newriskLevel.contains('Serious')){childWrapper.ruleRecord.CLQ_hasSeriousRiskFinding__c = true;}
}
}
}*/
        //remove unselected findings. Bug# 10864 moved this code before inserting finding
        if(!findinglisttoDelete.isEmpty()){
            delete findinglisttoDelete;
        }
        //13527 - delete caps of findings
        if(!cAPtoDelete.isEmpty()){
            delete cAPtoDelete;
        }
        //insert new findings
        if(!findinglisttoInsert.isEmpty()){
            upsert findinglisttoInsert;
            
            if(resultselected  == Non_Compliant){
                list<CLQ_Corrective_Action_Plan__c> cAPListtoinsert = new list<CLQ_Corrective_Action_Plan__c>();
                for(CLQ_Findings__c findingRecord : findinglisttoInsert){
                    if(findingRecord.CLQ_CAP_TA__c == CAP
                       && existingCorrectiveActionPlanMap.get(findingRecord.id) == null){
                           cAPListtoinsert.add(new CLQ_Corrective_Action_Plan__c(CLQ_Inspection__c = inspectionRecord.id
                                                                                 ,CLQ_Findings__c = findingRecord.id
                                                                                 ,CLQ_Non_Compliance_Finding__c = findingRecord.CLQ_Description__c));
                       }else if(findingRecord.CLQ_CAP_TA__c == CAP
                                && existingCorrectiveActionPlanMap.get(findingRecord.id) != null){
                                    CLQ_Corrective_Action_Plan__c caprecord = existingCorrectiveActionPlanMap.get(findingRecord.id);
                                    caprecord.CLQ_Non_Compliance_Finding__c = findingRecord.CLQ_Description__c;
                                    cAPListtoinsert.add(caprecord);
                                }
                }
                system.debug('====>'+cAPListtoinsert);
                if(!cAPListtoinsert.isEmpty()){
                    upsert cAPListtoinsert;
                }
            }
        }
        system.debug('====>' + cAPtoDelete);
        
        mapObjectData.put('Status', 'Success');
        mapObjectData.put('sfindingCode', newsFindingCode);
        mapObjectData.put('sfindingDescription', newsDescription);
        mapObjectData.put('sfindingTADescription', newTADescription);
        mapObjectData.put('nonCompliancePoint', nonCompliancePoint);
        mapObjectData.put('srncPoint', srncPoint);
        mapObjectData.put('lrncPoint', lrncPoint);
        mapObjectData.put('mrncPoint', mrncPoint);
        mapObjectData.put('newriskLevel', newriskLevel);
        
        return new ISD_CreateLightningServerResponse(bIsSuccessful, mapErrorInfo, mapObjectData);
    }
    
    @AuraEnabled
    public static ISD_CreateLightningServerResponse saveData(String domainRuleWrapperListJson) {
        
        Boolean bIsSuccessful = true;
        Map<String, object> mapErrorInfo = new Map<String, object>();
        Map<String, object> mapObjectData = new Map<String, object>();
        
        try {
            
            
            List<DomainwithRuleList> domainRuleWrapperList = new List<DomainwithRuleList>();
            domainRuleWrapperList = (List<DomainwithRuleList>) JSON.deserialize(domainRuleWrapperListJson, List<DomainwithRuleList>.class);
            
            //get all the rule inspected from the wrapper list
            list<CLQ_Rules_Inspected__c> ruleInspectedlist = new list<CLQ_Rules_Inspected__c>();
            
            for(domainwithRuleList wrapperrecord : domainRuleWrapperList) {
                for(rulewithFinding childWrapper : wrapperrecord.rulelist) {
                    
                    
                    ruleInspectedlist.add(childWrapper.ruleRecord);
                }
            }
            
            //14840    
            List<CLQ_Findings__c> findingsToDelete = new List<CLQ_Findings__c>();
            List<CLQ_Rules_Inspected__c> ruleInspectedlistToUpdate = new List<CLQ_Rules_Inspected__c>();
            Set<Id> rulesInsID = new Set<Id>();
            Set<Id> findingsToDeleteIds = new Set<Id>();
            
            
            for(CLQ_Rules_Inspected__c ri : ruleInspectedlist) {
                
                if(ri.CLQ_Result__c == COMPLAINT) {
                    rulesInsID.add(ri.Id);
                    ri.CLQ_Risk_Points__c = 0.0;
                    ri.CLQ_SRNC__c = 0.0;
                    ri.CLQ_MRNC__c = 0.0;
                    ri.CLQ_LRNC__c = 0.0;
                    ri.CLQ_hasSeriousRiskFinding__c = false;
                    //update ruleInspectedlist;
                }
                ruleInspectedlistToUpdate.add(ri);
            }
            
            
            
            for(CLQ_Rules_Inspected__c ri : ruleInspectedlist) {
                
                if(ri.CLQ_Result__c==COMPLAINT) {
                    for(CLQ_Findings__c finding : ri.Findings__r) {
                        findingsToDelete.add(finding);
                        findingsToDeleteIds.add(finding.Id);
                    }
                }
            }
            
            
            
            //get all the caps for the findings we want to delete
            List<CLQ_Corrective_Action_Plan__c> capsToDelete;
            if(findingsToDeleteIds!=null){
                capsToDelete = [SELECT Id FROM CLQ_Corrective_Action_Plan__c WHERE CLQ_Findings__c in: findingsToDeleteIds];
            }
            
            
            
            
            if(!capsToDelete.isEmpty()){
                delete capsToDelete;
            }

            if(!findingsToDelete.isEmpty()){
                delete findingsToDelete;
            }
                
            
            if(!ruleInspectedlistToUpdate.isEmpty()) {
                update ruleInspectedlistToUpdate;
            }
            
            mapObjectData.put('saveStatus', 'Success');
            
        } catch(Exception e) {
            bIsSuccessful = false;
        }
        return new ISD_CreateLightningServerResponse(bIsSuccessful, mapErrorInfo, mapObjectData);  
    }
    
    //Method to query all rule inspected for the inspection
    //@param: inspection record id
    //@return: list of rule inspected
    public static list<CLQ_Rules_Inspected__c> pullRuleInspectedforInspection(Id inspectionId){
        //add related object CLQ_Finind__c
        String relationQuery = '(SELECT id,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Finding_Code__c ,CLQ_Description__c,CLQ_TA_Description__c,CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.Name FROM  Findings__r)';
        //add extra fields as needed
        list<String> extraFieldsList = new list<String>{'CLQ_Domain_Rule__r.CLQ_Rule__c','CLQ_Domain_Rule__r.CLQ_Rule__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Description__c','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Description_Text__c','CLQ_Domain_Rule__r.CLQ_Domain__r.Name','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Short_Name__c','CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Long_Name__c'};
            extraFieldsList.add(relationQuery);
        //get soql string
        String soqlQuery = CLQ_UtilityClass.createSOQLQuery('CLQ_Rules_Inspected__c', ' CLQ_Inspection_No__c ='+'\''+inspectionId+'\'', extraFieldsList);   
        soqlQuery = soqlQuery + ' ORDER by CLQ_Domain_Rule__r.CLQ_Domain__r.Name,CLQ_Domain_Rule__r.CLQ_Rule__r.CLQ_Short_Name__c ASC';
        //query database
        return Database.query(soqlQuery);
    }
    
    //Method to add select option in filter drop-down on load
    public static list<String> populateRuleFilter(){
        List<String> filterOptions = new List<String>();
        
        filterOptions.add('All');
        /*filterOptions.add('Not Assessed');
filterOptions.add('Alleged Rule');
filterOptions.add('Focused/Partial');*/
        
        Schema.DescribeFieldResult fieldResult = CLQ_Rules_Inspected__c.CLQ_Result__c.getDescribe();
        
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            filterOptions.add(f.getValue());
        }
        return filterOptions;
    }
    
    //Method to add select option in Result filter drop-down on load
    public static list<String> populateresultFilter(){
        List<String> resultOptions = new list<String>();
        Schema.DescribeFieldResult fieldResult = CLQ_Rules_Inspected__c.CLQ_Result__c.getDescribe();
        
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            resultOptions.add(f.getValue());
        }
        return resultOptions;
    }
    
    public static Map<Id, CLQ_Findings__c> getExistingStandardFindingIdMap(List<CLQ_Findings__c> findingList) {
        Map<Id, CLQ_Findings__c> existingStandardFindingIdMap = new Map<Id, CLQ_Findings__c>();
        for(CLQ_Findings__c finding : findingList){
            existingStandardFindingIdMap.put(finding.CLQ_Domain_Rule_Finding__c, finding);
        }
        return existingStandardFindingIdMap;
    }
    
    public static Map<Id, CLQ_Corrective_Action_Plan__c> getExistingCorrectiveActionPlanMap(List<CLQ_Findings__c> findingList) {
        Map<Id, CLQ_Corrective_Action_Plan__c> existingCorrectiveActionPlanMap = new Map<Id, CLQ_Corrective_Action_Plan__c>();
        for(CLQ_Findings__c finding : findingList) {
            for(CLQ_Corrective_Action_Plan__c existingCAP : finding.Corrective_Action_Plans__r){
                existingCorrectiveActionPlanMap.put(finding.id, existingCAP);
            }
        }
        return existingCorrectiveActionPlanMap;
    }
    
    public static List<CLQ_Findings__c> getFindingList(Id selectedInspectedRule) {
        
        List<CLQ_Findings__c> findingList = new List<CLQ_Findings__c>();
        
        list<String> extraFieldofFindings = new list<String> {
            'CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__c',
                'CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.CLQ_Integration_Document_Type__c',
                '(SELECT id FROM Corrective_Action_Plans__r)'
                };
                    findinglist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Findings__c', ' CLQ_Rules_Inspected__c ='+'\''+selectedInspectedRule+'\'', extraFieldofFindings));
        return findingList;
    }
    
    public static list<String> populateRuleAllegedFilter(boolean isAlleged){
        List<String> resultAllegedOptions = new list<String>();
        String allegedRuleResults = Label.Alleged_Rule_Results; 
        Schema.DescribeFieldResult fieldResult = CLQ_Rules_Inspected__c.CLQ_Result__c.getDescribe();
        resultAllegedOptions.add('--None--');
        //Populate picklist based on Alleged rule flag
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues()){
            Set<String> allegedRuleOptions = new Set<String>();
            allegedRuleOptions.add(allegedRuleResults);
            System.Debug('allegedRuleOptions--> '+allegedRuleOptions.contains(f.getLabel()));
            if(!isAlleged && !allegedRuleResults.contains(f.getLabel())){
                
                
                
                resultAllegedOptions.add(f.getValue());   //need to check what should be written over here.
                
            }
            else if(isAlleged && allegedRuleResults.contains(f.getLabel())){
                
                
                
                resultAllegedOptions.add(f.getValue());
                
            }
        }
        return resultAllegedOptions;
    }
    
    
    //child Wrapper
    public class RulewithFinding {
        @AuraEnabled public CLQ_Rules_Inspected__c ruleRecord{get;set;}
        @AuraEnabled public String sfindingCode{get;set;}
        @AuraEnabled public String sfindingDescription{get;set;}
        @AuraEnabled public String sfindingTADescription{get;set;}
        @AuraEnabled public Boolean showRule{get;set;}
        @AuraEnabled public String regulation{get;set;}
        @AuraEnabled public List<String> ruleResultList{get;set;} //Added for CR - 11415 | Same change in next line.
        
        public RulewithFinding(CLQ_Rules_Inspected__c ruleRecord, String sfindingCode, String sfindingDescription, String regulation, String sfindingTADescription, List<String> ruleResultList){
            this.ruleRecord = ruleRecord;
            this.sfindingCode = sfindingCode;
            this.sfindingDescription = sfindingDescription;
            this.regulation = regulation;
            this.sfindingTADescription = sfindingTADescription;
            this.ruleResultList = ruleResultList; //Added for CR - 11415
            showRule = true;
        }
    }
    
    //parent wrapper
    public class DomainwithRuleList {
        @AuraEnabled public String domainID{get;set;}
        @AuraEnabled public String domainName{get;set;}
        @AuraEnabled public list<rulewithFinding> rulelist{get;set;}
        @AuraEnabled public Boolean showDomain{get;set;}
        public DomainwithRuleList(ID domainID,String dname , list<rulewithFinding> rulewithFindingList){
            this.domainName = dname;
            this.rulelist = rulewithFindingList;
            showDomain = true;
            this.domainID = domainID;
        }
    }
    
    //wrapper for pop up
    public class PopupWrapper {
        
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public CLQ_Findings__c finding{get;set;}
        @AuraEnabled public String sFindingCode{get;set;}
        @AuraEnabled public String riskLevel{get;set;}
        @AuraEnabled public String sfindingName{get;set;}
        
        public PopupWrapper(Boolean isSelected, CLQ_Findings__c sfinding, String sFindingCode, String riskLevel, String sfindingName) {
            this.isSelected = isSelected;
            this.finding = sfinding;
            this.sFindingCode = sFindingCode;
            this.riskLevel = riskLevel;
            this.sfindingName = sfindingName;
        }
        
    }
}