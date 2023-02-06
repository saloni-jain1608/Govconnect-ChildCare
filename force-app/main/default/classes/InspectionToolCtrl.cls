/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Provides functionality to associate rules to an Inspection
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of InspectionToolCtrl @version 1.0
 * 
 */
public with sharing class InspectionToolCtrl implements IRequest {
    private String jsonParam;
    
    /**
     * Processes the method and returns JsonResponse
     * 
     * @param methodName - Name of the method to be processed defined in the class
     * @param jsonParam - JSON parameter to be used.
     * 
     * @return JsonResponse - Returns JsonResponse object
     */
    public JsonResponse processRequest(String methodName, String jsonParam){
        JsonResponse response = null;
        this.jsonParam = jsonParam;

        if(methodName == 'getInspectionTools'){
            response = getInspectionTools();
        }else if(methodName == 'saveInspectionTools'){
            response = saveInspectionTools();
        }
        else{
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add('Invalid method name');
        }

        return response;
    }
    
    public JsonResponse validate(String x, String y){
        return new JsonResponse();
    }

    public JsonResponse getInspectionTools(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        String scope = '';

        CLQ_Inspection__c inspectionrecord = [SELECT Id,CLQ_Inspection_Type__c,CLQ_Use_Rules_Effective_On__c,CLQ_Reason_for_Inspection_Tool_Selection__c,
        CLQ_Scope__c,CLQ_Program__c,CLQ_Program__r.RecordTypeID,CLQ_Program__r.RecordType.Name,CLQ_Program_Transaction__c,
        CLQ_Program_Transaction__r.CLQ_Program__r.RecordType.Name,CLQ_Inspection_Tool__c,CLQ_Recommended_Inspection_Tool__c FROM CLQ_Inspection__c WHERE Id =:recordId];

        if(inspectionRecord.CLQ_Scope__c == 'Partial'){
            scope = 'Full';
        }else{
            scope = inspectionRecord.CLQ_Scope__c;
        }

        List<InspectionTool>  inspectionTools = new List<InspectionTool>();
        CLQ_Inspection_Tools__c fullScopeInspectionTool = new CLQ_Inspection_Tools__c();

        string programRecordType = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosById().get(inspectionRecord.CLQ_Program__r.RecordTypeID).getname();

        System.debug('Inspection Tools: ' + retriveInspectionTools());
        for(CLQ_Inspection_Tools__c inspectionToolrecord : retriveInspectionTools()){
            InspectionTool innerRecord = new InspectionTool(inspectionToolrecord);
            //Updated If Block for defect ID: 10872
            if(inspectionToolrecord.CLQ_Applicable_To__c !=null && (inspectionrecord.CLQ_Program__r.RecordType.Name !=null) && (inspectionrecord.CLQ_Inspection_Type__c !=null) && (inspectionrecord.CLQ_Scope__c != null)
                && (inspectionToolrecord.CLQ_Applicable_To__c).contains(inspectionrecord.CLQ_Program__r.RecordType.Name)
                && (inspectionToolrecord.CLQ_Applicable_To_Scope__c != null &&(inspectionToolrecord.CLQ_Applicable_To_Scope__c).contains(scope))
                && (inspectionToolrecord.CLQ_Application_To_Inspection_Type__c != null && inspectionToolrecord.CLQ_Application_To_Inspection_Type__c == inspectionrecord.CLQ_Inspection_Type__c)){
                innerRecord.isRecommended = true;
                innerRecord.isSelected = true;
                inspectionTools.add(innerRecord);
            }

            if(inspectionToolrecord.CLQ_Applicable_To__c !=null && (inspectionrecord.CLQ_Program__r.RecordType.Name != null) 
                && (inspectionToolrecord.CLQ_Applicable_To__c).contains(inspectionrecord.CLQ_Program__r.RecordType.Name)
                && (inspectionToolrecord.CLQ_Applicable_To_Scope__c == 'Full')
                && (inspectionToolrecord.CLQ_Application_To_Inspection_Type__c != null && inspectionToolrecord.CLQ_Application_To_Inspection_Type__c == inspectionrecord.CLQ_Inspection_Type__c)){
                fullScopeInspectionTool = inspectionToolrecord; 
           		
            }
        }

        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.data.put('inspectionTools', inspectionTools);
        response.data.put('fullScopeInspectionTool', fullScopeInspectionTool);
        response.errors = new List<String>();

        return response;
    }

    public JsonResponse saveInspectionTools(){
        JsonResponse response = null;

        System.debug(this.jsonParam);

        InspectionToolCtrl.ToolRequest request = (ToolRequest)JSON.deserialize(this.jsonParam, InspectionToolCtrl.ToolRequest.class);
        String recordId = request.recordId;
        List<InspectionTool> inspectionTools = request.inspectionTools;
        String fullScopeInspectionToolId = request.fullScopeInspectionToolId;
		
        System.debug('Full Scope Inspection Tool Id: ' + fullScopeInspectionToolId);
        CLQ_Inspection__c inspectionrecord = [SELECT Id,CLQ_Inspection_Type__c,CLQ_Method__c,CLQ_Use_Rules_Effective_On__c,CLQ_Reason_for_Inspection_Tool_Selection__c,
        CLQ_Scope__c,CLQ_Program__c,CLQ_Program__r.RecordTypeID,CLQ_Program__r.RecordType.Name,CLQ_Program_Transaction__c,
        CLQ_Program_Transaction__r.CLQ_Program__r.RecordType.Name,CLQ_Inspection_Tool__c,CLQ_Recommended_Inspection_Tool__c FROM CLQ_Inspection__c WHERE Id =:recordId];

        if(inspectionrecord.CLQ_Scope__c == null || inspectionrecord.CLQ_Method__c == null || inspectionrecord.CLQ_Use_Rules_Effective_On__c == null){
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();

            response.errors.add('Please populate Method, Scope and Rules Effective Date to proceed.');

            return response;
        }
        
        List<CLQ_Rules_Inspected__c> ruleInspectedList = new List<CLQ_Rules_Inspected__c>();
        
        for(InspectionTool innerRecord : inspectionTools){
            if(innerRecord.isSelected == true){
                inspectionRecord.CLQ_Inspection_Tool__c = innerRecord.Id;
            }
            if(innerRecord.isRecommended == true){
                inspectionRecord.CLQ_Recommended_Inspection_Tool__c = innerRecord.Id;
            }
        }

        update inspectionRecord;
        
        Map<Id, CLQ_Tools_Rules__c> focusedToolRuleMap = new Map<Id, CLQ_Tools_Rules__c>();
        Set<Id> domainRuleIDset = new Set<Id>();
        for(CLQ_Rules_Inspected__c ruleInspectedRecord : [SELECT Id,CLQ_Domain_Rule__c 
                                                            FROM CLQ_Rules_Inspected__c
                                                            WHERE CLQ_Inspection_No__c =:inspectionRecord.id AND CLQ_Alleged_Rule_Violation__c =: '']){
            domainRuleIDset.add(ruleInspectedRecord.CLQ_Domain_Rule__c);                                                    
        }

        if((inspectionRecord.CLQ_Scope__c == 'Focused' || inspectionRecord.CLQ_Scope__c == 'Partial') && inspectionRecord.CLQ_Inspection_Tool__c != null){ //10912
            for(CLQ_Tools_Rules__c rulerecord : retriveToolRules(inspectionRecord.CLQ_Inspection_Tool__c, inspectionRecord.CLQ_Use_Rules_Effective_On__c)){
                if(!domainRuleIDset.contains(rulerecord.CLQ_Domain_Rule__c)){
                    CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c=inspectionRecord.id,CLQ_Domain_Rule__c =rulerecord.CLQ_Domain_Rule__c);
                    //ruleInspected.CLQ_Result__c = '';
                    if(inspectionRecord.CLQ_Inspection_Type__c == 'Technical Assistance'){ //15942
                        ruleInspected.CLQ_Result__c = 'Not Discussed' ; 
                    }else{
                        if(inspectionRecord.CLQ_Scope__c == 'Partial'){ruleInspected.CLQ_Result__c = 'Not Verified';}else{ruleInspected.CLQ_Result__c = '';}    
                    } 
                    ruleInspected.CLQ_isFocused__c = true;
                    ruleInspectedList.add(ruleInspected); 
                    domainRuleIDset.add(rulerecord.CLQ_Domain_Rule__c);
                    focusedToolRuleMap.put(rulerecord.CLQ_Domain_Rule__c,rulerecord);
                }
            }
        }
        if(fullScopeInspectionToolId != null){ //10912
        //Copy all rule associated with the selected inspection to inspection record
            for(CLQ_Tools_Rules__c toolRule : retriveToolRules(fullScopeInspectionToolId, inspectionRecord.CLQ_Use_Rules_Effective_On__c)){
                if(!domainRuleIDset.contains(toolRule.CLQ_Domain_Rule__c)){
                    CLQ_Rules_Inspected__c ruleInspected = new CLQ_Rules_Inspected__c(CLQ_Inspection_No__c=inspectionRecord.id,CLQ_Domain_Rule__c =toolRule.CLQ_Domain_Rule__c);
                    if((inspectionRecord.CLQ_Scope__c == 'Focused' || inspectionRecord.CLQ_Scope__c == 'Partial') && focusedToolRuleMap.get(toolRule.CLQ_Domain_Rule__c) == null){
                        ruleInspected.CLQ_Result__c = 'Not Verified';
                    }else if(inspectionRecord.CLQ_Scope__c == 'Full'){
                        if(inspectionRecord.CLQ_Inspection_Type__c == 'Technical Assistance') //15942
                            ruleInspected.CLQ_Result__c = 'Not Discussed' ;
                        else
                            ruleInspected.CLQ_Result__c = '';
                    }
                    ruleInspectedList.add(ruleInspected);
                }	    
            }
        }
        else{ //10912
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();

            response.errors.add('There are no inspection tools to select for this inspection record');

            return response;
        }
        if(ruleInspectedList.size()>0){   
            insert ruleInspectedList; 
        }    

        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();

        return response;
    }

    public list<CLQ_Inspection_Tools__c> retriveInspectionTools(){
        list<CLQ_Inspection_Tools__c> inspectionToolList = new list<CLQ_Inspection_Tools__c>();
        
        inspectionToolList = [SELECT Id,CLQ_Applicable_To__c,CLQ_Description__c,CLQ_Active__c,Name
                                ,CLQ_Applicable_To_Scope__c,CLQ_Application_To_Inspection_Type__c
                                FROM CLQ_Inspection_Tools__c
                                WHERE CLQ_Applicable_To_Scope__c != NULL
                                AND CLQ_Application_To_Inspection_Type__c != NULL
                                AND CLQ_Applicable_To__c != NULL
                             	AND CLQ_Active__c = true];
                            
        return inspectionToolList;
    }

    public list<CLQ_Tools_Rules__c> retriveToolRules(ID ruleId, Date validityDate){
        list<CLQ_Tools_Rules__c> toolRuleList = new list<CLQ_Tools_Rules__c>(); 
        toolRuleList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Tools_Rules__c', ' CLQ_Inspection_Tools__c ='+'\''+ruleId+'\' AND CLQ_Domain_Rule__r.CLQ_Rule_Effective_Date__c<='+String.valueOf(validityDate)+' AND ((CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c>='+String.valueOf(validityDate)+'  AND CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c!= null) OR (CLQ_Domain_Rule__r.CLQ_Rule_Expiration_Date__c = null))', null));
        return  toolRuleList;
    }

    public class InspectionTool{
        public String Id {get; set;}
        public String Name {get; set;}
        public String Description {get; set;}
        public boolean isSelected {get; set;}
        public boolean isRecommended {get; set;}
        //public CLQ_Inspection_Tools__c record {get; set;} 
        public String recommended {get; set;}

        public InspectionTool(CLQ_Inspection_Tools__c record){
            this.Id = record.Id;
            this.Name = record.Name;
            this.Description = record.CLQ_Description__c;
            isSelected = false;
            isRecommended = false;
            recommended = 'Recommended';
            //this.record = record;
        }
    }

    public class ToolRequest {
        public String recordId {get; set;}
        public List<InspectionTool> inspectionTools {get; set;}
        public String fullScopeInspectionToolId {get; set;}
    }
}