public with sharing class Case_Action_Custom implements IRequest{
    private String jsonParam;
    public static Map<String, String> capMetadataValueMap = new  Map<String, String>();
    
    public static final string CASE_COMPLETE_ALLEGATION_CUSTOM = 'caseCompleteAllegation_Custom';
    public static final string CASE_COMPLETE_ALLEGEDOPS_REPORT_CUSTOM = 'caseCompleteAllegedOpsReport_Custom';
    public static final string CASE_COMPLETE_DISPOSITION_CUSTOM = 'caseCompleteDisposition_Custom';
    public static final string CASE_COMPLETE_ENFORCEMENT_CUSTOM = 'caseCompleteEnforcement_Custom';
    public static final string CASE_CREATE_INSPECTION_CUSTOM = 'caseCreateInspection_Custom';
    public static final string CASE_COMPLETE_REVIEW_CUSTOM = 'caseCompleteReview_Custom';
    public static final string CASE_SUBMIT_CUSTOM = 'caseSubmit_Custom';
    public static final string CASE_SUBMIT_ALLEGEDOPS_CUSTOM = 'caseSubmitAllegedOps_Custom';
    public static final string CASE_SUBMIT_ENFORCEMENT_CUSTOM = 'caseSubmitEnforcement_Custom';
    public static final string CASE_SUBMIT_INCIDENT_INJURY_CUSTOM = 'caseSubmitIncidentInjury_Custom';
            public static final string CASE_SUBMIT_APPROVAL_CUSTOM = 'caseSubmitApproval_Custom';
            public static final string CASE_SUBMIT_APPROVAL_ALLEGEDOPS_CUSTOM = 'caseSubmitApprovalAllegedOps_Custom';
            public static final string CASE_SUBMIT_III_CUSTOM = 'caseSubmitIncidentInjuryIllness_Custom';
            public static final string CASE_SUBMIT_APPROVAL_ENFORCEMENT_CUSTOM = 'caseSubmitApprovalEnforcement_Custom';
     public static final string NOT_SUBMITTED = 'Not Submitted';
        public static final string COMPLETE = 'Complete';
    public static final string ENFORCEMENT = 'Enforcement';
    public static final string STRING_COUNTY = 'county';
    public static final string ZEROZEROFIVE = '005';
    public static final String DAYCAMP ='Day Camp';
	public static final string Child_Care_Center='Child Care Center';
    public static final string Pre_School='Pre School';
    public static final string School_Age_Child_Care='School Age Child Care';
    public static final string FCC_Type_A_Home='FCC - Type A Home';
    public static final string FCC_Type_B_Home='FCC - Type B Home';
	public static final String EMPTY_STRING = '';   
    /**
* validates the method and returns JsonResponse
* 
* @param methodName - Name of the method which contains the validation
* @param jsonParam - JSON parameter to be used.
* 
* @return JsonResponse - Returns JsonResponse object
*/
    public JsonResponse validate(String methodName, String jsonParam) {
        JsonResponse response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    
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
        for(Case_Action_Custom__mdt mdt : [Select label,QualifiedApiName from Case_Action_Custom__mdt]){
            capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
        }
        try{
            
            if(capMetadataValueMap.size()!=0){
                if(methodName == capMetadataValueMap.get(CASE_COMPLETE_ALLEGATION_CUSTOM)){
                    response = caseCompleteAllegation_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_COMPLETE_ALLEGEDOPS_REPORT_CUSTOM)){
                    response = caseCompleteAllegedOpsReport_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_COMPLETE_DISPOSITION_CUSTOM)){
                    response = caseCompleteDisposition_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_COMPLETE_ENFORCEMENT_CUSTOM)){
                    response = caseCompleteEnforcement_Custom();
                }else if(methodName== capMetadataValueMap.get(CASE_CREATE_INSPECTION_CUSTOM)){
                    response = caseCreateInspection_Custom();                
                }else if(methodName == capMetadataValueMap.get(CASE_COMPLETE_REVIEW_CUSTOM)){
                    response = caseCompleteReview_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_CUSTOM)){
                    response = caseSubmit_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_ALLEGEDOPS_CUSTOM)){
                    response = caseSubmitAllegedOps_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_ENFORCEMENT_CUSTOM)){
                    response = caseSubmitEnforcement_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_INCIDENT_INJURY_CUSTOM)){
                    response = caseSubmitIncidentInjury_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_APPROVAL_CUSTOM)){
                    response = caseSubmitApproval_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_APPROVAL_ALLEGEDOPS_CUSTOM)){
                    response = caseSubmitApprovalAllegedOps_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_III_CUSTOM)){
                    response = caseSubmitIncidentInjuryIllness_Custom();
                }else if(methodName == capMetadataValueMap.get(CASE_SUBMIT_APPROVAL_ENFORCEMENT_CUSTOM)){
                    response = caseSubmitApprovalEnforcement_Custom();
                }else{
                    response = new JsonResponse();
                    response.status = RequestStatus.ERROR;
                    response.data = new Map<String, Object>();
                    response.errors = new List<String>();
                    response.errors.add('Invalid method name');
                }
            }
        }
        catch(Exception ex){
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    
    public JsonResponse caseCompleteAllegation_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        List<CLQ_Alleged_Rule_Violation__c> lstAllegedRule;
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId != null){
            lstAllegedRule = [SELECT id, Case_Custom__c from CLQ_Alleged_Rule_Violation__c where Case_Custom__c =: recordId];
        }
        
        if(recordId != null){
            caseCustomObj =[Select id,CLQ_Inspection__c,CLQ_No_Investigation_Required__c,CLQ_Complete_Allegation__c from CLQ_Case_Custom__c where id=: recordId];
        } 
        if(caseCustomObj.CLQ_Inspection__c != null || caseCustomObj.CLQ_No_Investigation_Required__c == true){
            if(caseCustomObj.CLQ_No_Investigation_Required__c == true && lstAllegedRule.size() > 0){
                response.errors.add('Inspection is required when Alleged Rule Violations are listed');
                return response;
            }else if(caseCustomObj.CLQ_Inspection__c != null && (lstAllegedRule == null || lstAllegedRule.size() == 0)){
                response.errors.add('There is no alleged rule violation');
                return response;
            }else{
                CLQ_Case_Custom__c c = new CLQ_Case_Custom__c();
                c.id = recordId;
                c.CLQ_Complete_Allegation__c = True;
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(c);
                if(!caselist.isEmpty()){
                    update caselist;
                }
                
            }
        }else{
            response.errors.add('Inspection is required to complete this functionality');
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse caseCompleteAllegedOpsReport_Custom(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseCustomObj =[Select id,CLQ_Inspection__c,CLQ_No_Investigation_Required__c,CLQ_Complete_Allegation__c,CLQ_Status__c,CLQ_Assigned_To__c from CLQ_Case_Custom__c where id=: recordId];
        }
       
        if(caseCustomObj != null){
            if(caseCustomObj.CLQ_Status__c == COMPLETE){
                response.errors.add('The Alleged Operator Report has already completed.');
                return response;
            }
            else if(caseCustomObj.CLQ_Status__c == NOT_SUBMITTED){
                response.errors.add('The Alleged Operator Report has not submitted.');
                return response;
            }
            else if(caseCustomObj.CLQ_Assigned_To__c == null ) {
                response.errors.add('The Alleged Operation Report has not been reviewed by an assigned reviewer');
                return response;
            } else {
                CLQ_Case_Custom__c c = new CLQ_Case_Custom__c();
                c.Id = caseCustomObj.id;
                c.CLQ_Status__c = 'Complete';
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(c);
                if(!caselist.isEmpty()){
                    update caselist;
                }
            }
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse caseCompleteDisposition_Custom(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId != null){
            caseCustomObj = [SELECT id,CLQ_Complete_Allegation__c,CLQ_No_Investigation_Required__c,CLQ_Complete_Inspection__c,CLQ_Complete_Disposition__c FROM CLQ_Case_Custom__c where id=: recordId];
        }
        if(caseCustomObj.CLQ_Complete_Allegation__c == true){
            if((caseCustomObj.CLQ_No_Investigation_Required__c == false && caseCustomObj.CLQ_Complete_Inspection__c == true) || (caseCustomObj.CLQ_No_Investigation_Required__c == true && caseCustomObj.CLQ_Complete_Inspection__c == false)){
                CLQ_Case_Custom__c customCase = new CLQ_Case_Custom__c();
                customCase.id = recordId;
                customCase.CLQ_Complete_Disposition__c = True;
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(customCase);
                if(!caselist.isEmpty()){
                    update caselist;
                }
            }else{
                response.errors.add('Disposition cannot be Completed. Please make sure that either No Investigation Required box is checked OR Inspection is linked and completed.');
                return response;
            }
        }else{
            response.errors.add('Disposition cannot be Completed until the following: 1.) Attached Inspection must be Completed OR “No Inspection Required” is checked 2.) “Complete Allegation” is checked');
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse caseCompleteEnforcement_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        List<CLQ_Case_Action_Details__c> caseActionList;
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseActionList = [Select Id,Name,CLQ_Case_Custom__c from CLQ_Case_Action_Details__c where CLQ_Case_Custom__c =: recordId];
        }
        if(recordId!=null){
            caseCustomObj = [select id,CLQ_Outcome_Reason_Code__c,CLQ_Case_Closure_Date__c from CLQ_Case_Custom__c where id=: recordId];
        }
        
        if(caseCustomObj.CLQ_Outcome_Reason_Code__c == null){
            response.errors.add('Reason is a required field');
            return response;
        }else if(caseCustomObj.CLQ_Case_Closure_Date__c == null){
            response.errors.add('Closure Date is a required field');
            return response;            
        }else if(caseActionList.IsEmpty()){
            response.errors.add('A minimum of one Action must be added under the Enforcement Details section.');
            return response;
        }else{
            CLQ_Case_Custom__c caseCustom = new CLQ_Case_Custom__c();
            caseCustom.id = recordId;
            caseCustom.CLQ_Status__c= 'Complete';
            List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
            caselist.add(caseCustom);
            if(!caselist.isEmpty()){
                update caselist;
            }
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse caseCompleteReview_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        List<CLQ_Alleged_Rule_Violation__c> allegedRuleList;
        if(recordId != null){
            allegedRuleList = [Select Id,Case_Custom__c from CLQ_Alleged_Rule_Violation__c where Case_Custom__c =: recordId];
        } 
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId != null){
            caseCustomObj = [select id,CLQ_Inspection__c,CLQ_No_Investigation_Required__c,CLQ_Status__c from CLQ_Case_Custom__c where id=: recordId];
        }
        if(caseCustomObj.CLQ_Inspection__c != null || caseCustomObj.CLQ_No_Investigation_Required__c == true){
            if(caseCustomObj.CLQ_Inspection__c != null && (allegedRuleList == null || allegedRuleList.size() == 0)){
                response.errors.add('There is no alleged rule violation');
                return response;
                
            }else if(caseCustomObj.CLQ_Inspection__c != null){
                response.errors.add('Cannot Complete Review because an Inspection has been selected');
                return response;
                
            }else{
                CLQ_Case_Custom__c caseCustom = new CLQ_Case_Custom__c();
                caseCustom.CLQ_Complete_Review__c = True;
                caseCustom.id = recordId;
                caseCustom.CLQ_Status__c= 'Complete';
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(caseCustom);
                if(!caselist.isEmpty()){
                    update caselist;
                }
            }
        }else{
            response.errors.add('Inspection is required');
            return response;
        }
        response.status = RequestStatus.OK;
        return response;
        
    }
    
    public JsonResponse caseSubmit_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId != null){
            caseCustomObj = [SELECT Id, CLQ_Program__c,CLQ_Program__r.CLQ_Licensing_Specialist__c,CLQ_Program__r.CLQ_Program_Type__c FROM CLQ_Case_Custom__c where Id =: recordId];
        }
        
        Date SDate= date.today();
        if(caseCustomObj != null){
            CLQ_Case_Custom__c caseCustom= new CLQ_Case_Custom__c();
            caseCustom.id = caseCustomObj.id;
            caseCustom.CLQ_Status__c = 'Submitted';
            caseCustom.CLQ_Submitted_Date_Incident__c = SDate;
            caseCustom.CLQ_Complaint_Submitted__c = 'Complaint Submitted';
            List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
            caselist.add(caseCustom);
            if(!caselist.isEmpty()){
                update caselist;
            }
        }
        
        response.status = RequestStatus.OK;
        return response;
        
    }
    
    public JsonResponse caseSubmitAllegedOps_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId != null){
            caseCustomObj = [SELECT Id,CLQ_Status__c,Review_Due_Date__c FROM CLQ_Case_Custom__c where Id =: recordId];
        }
        Date SDate= date.today();
        
        if(caseCustomObj != null){
            if(caseCustomObj.CLQ_Status__c != NOT_SUBMITTED){
                response.errors.add('This Alleged Operator Report has already submitted');
                return response;
            }else{
                CLQ_Case_Custom__c caseCustom= new CLQ_Case_Custom__c();
                caseCustom.id = caseCustomObj.id;
                caseCustom.CLQ_Status__c = 'Submitted';
                caseCustom.CLQ_Alleged_Ops_Submitted__c = 'Alleged Ops Submitted';
                caseCustom.CLQ_Disable_Validation_Rule__c  = true;
                if(caseCustomObj.Review_Due_Date__c == null){
                    caseCustom.Review_Due_Date__c = date.today().addDays(30);
                }
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(caseCustom);
                if(!caselist.isEmpty()){
                    update caselist;
                }
                
            }
        }
        
        response.status = RequestStatus.OK;
        return response;
        
    }
    
    public JsonResponse caseSubmitEnforcement_Custom(){
        JsonResponse response = null;
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        
        String recordId = this.jsonParam;
        
        CLQ_Case_Custom__c caseCustomObj = new CLQ_Case_Custom__c();
        if(recordId != null){
            caseCustomObj.id = recordId;
            caseCustomObj.CLQ_Status__c = 'Submitted';
            caseCustomObj.CLQ_Enforcement_Suspension_Submitted__c = 'Enforcement Suspension Submitted';
            caseCustomObj.CLQ_Enforcement_Submitted__c  = 'Enforcement Submitted';
            List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
            caselist.add(caseCustomObj);
            if(!caselist.isEmpty()){
                update caselist;
            }
        }
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
        
    }
    
    public JsonResponse caseSubmitIncidentInjury_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        
        CLQ_Case_Custom__c caseCustomObj = new CLQ_Case_Custom__c();
        if(recordId != null){
            caseCustomObj.id = recordId;
            caseCustomObj.CLQ_Status__c = 'Submitted';
            caseCustomObj.CLQ_Incident_Injury_Submitted__c  = 'Incident Injury Submitted';
            List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
            caselist.add(caseCustomObj);
            if(!caselist.isEmpty()){
                update caselist;
            }
            
        }
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        return response;
        
    }
    
    public JsonResponse caseSubmitApproval_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        User userObj;
        
        response = new JsonResponse();
        response.status = RequestStatus.ERROR;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        string strCombinedCounties = '';
        string caseCountyUC = '';
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseCustomObj = [SELECT id,ownerId,CLQ_Program_County__c,
                             Program_Record_Type__c,CLQ_Start_Approval__c,
                             CLQ_No_Investigation_Required__c,CLQ_Inspection__c 
                             FROM CLQ_Case_Custom__c where id=: recordId];
        }
        
        if(caseCustomObj != null){
            userObj = [Select Id, Name, ManagerId,Manager.IsActive from User where Id =: caseCustomObj.OwnerId];
        }
        User currentUser;
        if(userInfo.getUserId() != null){
            currentUser = [Select id,UserRole.name from user where id=: userInfo.getUserId()];
        }
        if(caseCustomObj.CLQ_Program_County__c != null){
            caseCountyUC = caseCustomObj.CLQ_Program_County__c.toUpperCase();
        }
        
        
        if(currentUser.UserRole.name != null && currentUser.UserRole.name.toLowerCase().indexOf(STRING_COUNTY) >= 0){
            string usrCounty = currentUser.UserRole.Name.substring(0, currentUser.UserRole.name.toLowerCase().indexOf('county')).trim().toUpperCase();
            List<CLQ_Combined_Counties__mdt> combinedCountyRec;
            if(usrCounty!=null){
                combinedCountyRec = [Select CLQ_Combined_Counties__c from CLQ_Combined_Counties__mdt where DeveloperName =: usrCounty and CLQ_Process_Combined_County__c = true];
            }
            if (combinedCountyRec.size() > 0) {
                strCombinedCounties = combinedCountyRec[0].CLQ_Combined_Counties__c;
            }
        }
        if (caseCustomObj.OwnerId != userInfo.getUserId()) {
            response.errors.add('Only Owner of the record can Submit for Approval');
            return response;
        } else if ((strCombinedCounties.length() == 0 || strCombinedCounties.indexOf(caseCountyUC) < 0) &&  currentUser.UserRole.name != null && currentUser.UserRole.name.toLowerCase().contains('county') && !currentUser.UserRole.name.tolowercase().contains(caseCustomObj.CLQ_Program_County__c.toLowerCase()) && Label.JFS_County_Program_Record_Type.contains(caseCustomObj.Program_Record_Type__c)) {
            response.errors.add(Label.Approval_Submit_Error_Message);
            return response;
        }else if (userObj.ManagerId == null || userObj.Manager.IsActive == false) {
            response.errors.add('User Manager is missing or inactive. Please update and Submit for Approval');
            return response;
        } else if (caseCustomObj.CLQ_Start_Approval__c == true) {
            response.errors.add('Approval in Process');
            return response;
        } else if (caseCustomObj.CLQ_No_Investigation_Required__c == false && caseCustomObj.CLQ_Inspection__c == null) {
            response.errors.add('No Inspection Required box should be checked if no inspection is created or required from the Case');
            return response;
        }else if (caseCustomObj.CLQ_Inspection__c != null) {
            response.errors.add('Cannot Submit for Approval because an Inspection has been selected');
            return response;
        }else{
            CLQ_Case_Custom__c caseCustom = updateRecord(recordId,true);
            List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
            caselist.add(caseCustom);
            if(!caselist.isEmpty()){
                update caselist;
            }
            try{
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(recordId);
                Approval.ProcessResult result = Approval.Process(req);
            }catch(Exception e){
                CLQ_Case_Custom__c csCustom = updateRecord(recordId,false);
                List<CLQ_Case_Custom__c> caselist1 = new List<CLQ_Case_Custom__c>();
                caselist1.add(csCustom);
                if(!caselist1.isEmpty()){
                    update caselist1;
                }
                response.errors.add(e.getMessage());
                return response;
            }
            
        }
        
        response.status = RequestStatus.OK;
        return response;
        
    }
    
    public JsonResponse caseSubmitApprovalAllegedOps_Custom(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseCustomObj = [Select id,CLQ_Status__c,CLQ_Start_Approval__c,CLQ_Assigned_To__c,CLQ_No_Investigation_Required__c,CLQ_Inspection__c,Approve_Due_Date__c from CLQ_Case_Custom__c where id=: recordId];
        }
        
        response = new JsonResponse();
        response.status = RequestStatus.ERROR;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        if(caseCustomObj != null){
            if(caseCustomObj.CLQ_Start_Approval__c == true){
                response.errors.add('Approval in Process');
                return response;
            }else if(caseCustomObj.CLQ_Status__c == NOT_SUBMITTED){
                response.errors.add('You need to submit the Alleged Operator Report first, then submit for approval');
                return response;
            }else if(caseCustomObj.CLQ_Assigned_To__c == null){
                response.errors.add('The Alleged Operation Report needs to be reviewed by an assigned reviewer, then submit for approval');
                return response;
            }else if(caseCustomObj.CLQ_No_Investigation_Required__c == false && caseCustomObj.CLQ_Inspection__c == null){
                response.errors.add('No Inspection Required box is required to Submit for Approval');
                return response;
            }else{
                CLQ_Case_Custom__c cseCustom = new CLQ_Case_Custom__c();
                cseCustom.id = recordId;
                cseCustom.CLQ_Start_Approval__c = true;
                if(caseCustomObj.Approve_Due_Date__c == null){
                    cseCustom.Approve_Due_Date__c = date.today().addDays(30);
                }
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(cseCustom);
                if(!caselist.isEmpty()){
                    update caselist;
                }
                try{
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(recordId);
                    Approval.ProcessResult result = Approval.Process(req);
                }catch(Exception e){
                    CLQ_Case_Custom__c csCustom = updateRecord(recordId,false);
                    List<CLQ_Case_Custom__c> caselist1 = new List<CLQ_Case_Custom__c>();
                    caselist1.add(csCustom);
                    if(!caselist1.isEmpty()){
                        update caselist1;
                    }
                    
                    response.errors.add(e.getMessage());
                    return response;
                }
            }
        }
        
        
        response.status = RequestStatus.OK;
        return response;
    }   
    
    public JsonResponse caseSubmitIncidentInjuryIllness_Custom(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseCustomObj = [Select id,CLQ_Status__c,CLQ_Start_Approval__c,CLQ_Assigned_To__c,CLQ_No_Investigation_Required__c,CLQ_Inspection__c,Approve_Due_Date__c from CLQ_Case_Custom__c where id=: recordId];
        }
        
        response = new JsonResponse();
        response.status = RequestStatus.ERROR;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        if(caseCustomObj != null){
            if(caseCustomObj.CLQ_Start_Approval__c == true){
                response.errors.add('Approval in Process');
                return response;
            }else if(caseCustomObj.CLQ_No_Investigation_Required__c == false && caseCustomObj.CLQ_Inspection__c == null){
                response.errors.add('No Inspection Required box should be checked if no inspection is created or required from the Case');
                return response;
            }else{
                CLQ_Case_Custom__c c = updateRecord(recordId,true);
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(c);
                if(!caselist.isEmpty()){
                    update caselist;
                }
                
                try{
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(recordId);
                    Approval.ProcessResult result = Approval.Process(req);
                }catch(Exception e){
                    CLQ_Case_Custom__c cs = updateRecord(recordId,false);
                    List<CLQ_Case_Custom__c> caselist1 = new List<CLQ_Case_Custom__c>();
                    caselist1.add(cs);
                    if(!caselist1.isEmpty()){
                        update caselist1;
                    }
                    response.errors.add(e.getMessage());
                    return response;
                }
            }
        }
        
        
        response.status = RequestStatus.OK;
        return response;
    } 
    
    public JsonResponse caseSubmitApprovalEnforcement_Custom(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        decimal flag = 0;
        decimal count = 0;
        string strCombinedCounties = '';
        string caseCountyUC = '';
        
        response = new JsonResponse();
        response.status = RequestStatus.ERROR;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        user userObj;
        CLQ_Case_Custom__c caseCustomObj;
        
        if(recordId != null){
            caseCustomObj = [Select id,ownerId,CLQ_Program_County__c,
                             Program_Record_Type__c,CLQ_Start_Approval__c,
                             CLQ_No_Investigation_Required__c,CLQ_Inspection__c,
                             CLQ_Activity_Type__c,CLQ_Accepted_Case_Actions_Suspension__c,
                             CLQ_Closed_Case_Actions_Suspension__c,CLQ_Accepted_Case_Actions_Enforcement__c,
                             CLQ_Closed_Case_Actions_Enforcement__c,CLQ_Status__c,Approve_Due_Date__c 
                             from CLQ_Case_Custom__c where id=: recordId];
        }
        if (caseCustomObj.CLQ_Activity_Type__c == ENFORCEMENT) {
            count = caseCustomObj.CLQ_Accepted_Case_Actions_Enforcement__c 
                + caseCustomObj.CLQ_Closed_Case_Actions_Enforcement__c;
        }
        else {
            count = caseCustomObj.CLQ_Accepted_Case_Actions_Suspension__c 
                + caseCustomObj.CLQ_Closed_Case_Actions_Suspension__c;
        }
        
        if (count > 0) {
            flag = 0;
        }
        else {
            flag = 1;
        }
        
        if(caseCustomObj != null){
            System.debug('');
            if(caseCustomObj.OwnerId != null && String.valueOf(caseCustomObj.OwnerId).startsWithIgnoreCase(ZEROZEROFIVE)){
                userObj = [Select Id, Name, ManagerId,Manager.IsActive from User where Id =: caseCustomObj.OwnerId];
            }
                
        }
        User currentUser = [Select id,UserRole.name from user where id=: userInfo.getUserId()];
        if(caseCustomObj.CLQ_Program_County__c != null){
            caseCountyUC = caseCustomObj.CLQ_Program_County__c.toUpperCase();
        }
        
        
        if(currentUser.UserRole.name != null && currentUser.UserRole.name.toLowerCase().indexOf(STRING_COUNTY) >= 0){
            string usrCounty = currentUser.UserRole.Name.substring(0, currentUser.UserRole.name.toLowerCase().indexOf('county')).trim().toUpperCase();
            List<CLQ_Combined_Counties__mdt> combinedCountyRec;
            if(usrCounty!=null){
                combinedCountyRec = [Select CLQ_Combined_Counties__c from CLQ_Combined_Counties__mdt where DeveloperName =: usrCounty and CLQ_Process_Combined_County__c = true];
            }
            if (combinedCountyRec.size() > 0) {
                strCombinedCounties = combinedCountyRec[0].CLQ_Combined_Counties__c;
            }
        }
        
        if (caseCustomObj.OwnerId != userInfo.getUserId()) {
            response.errors.add('Only Owner of the record can Submit for Approval');
            return response;
        } else if ((strCombinedCounties.length() == 0 || strCombinedCounties.indexOf(caseCountyUC) < 0) 
                   && currentUser.UserRole.name != null && currentUser.UserRole.name.toLowerCase().contains(STRING_COUNTY) 
                   && !currentUser.UserRole.name.tolowercase().contains(caseCustomObj.CLQ_Program_County__c.toLowerCase())
                   && Label.JFS_County_Program_Record_Type.contains(caseCustomObj.Program_Record_Type__c)) {
                       response.errors.add(Label.Approval_Submit_Error_Message);
                       return response;
                   }else if (userObj.ManagerId == null || userObj.Manager.IsActive == false) {
                       response.errors.add('User Manager is missing or inactive. Please update and Submit for Approval');
                       return response;
                   } else if (caseCustomObj.CLQ_Start_Approval__c == true) {
                       response.errors.add('Approval in Process');
                       return response;
                   } else if (caseCustomObj.CLQ_No_Investigation_Required__c == false && caseCustomObj.CLQ_Inspection__c == null) {
                       response.errors.add('No Inspection Required box is required to Submit for Approval');
                       return response;
                   }else{
                       if(flag == 0){
                           CLQ_Case_Custom__c c = updateRecord(recordId,true);
                           List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                           caselist.add(c);
                           if(!caselist.isEmpty()){
                               update caselist;
                           }                           
                           try{
                               Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                               req.setObjectId(recordId);
                               Approval.ProcessResult result = Approval.Process(req);
                               
                           }catch(Exception e){
                               CLQ_Case_Custom__c cs = updateRecord(recordId,false);
                               List<CLQ_Case_Custom__c> caselist1 = new List<CLQ_Case_Custom__c>();
                               caselist1.add(cs);
                               if(!caselist1.isEmpty()){
                                   update caselist1;
                               }
                               response.errors.add(e.getMessage());
                               return response;
                           }
                       }else{
                           response.errors.add('Recommendation needed before Approval');
                           return response;
                       }
                   }
        
        response.status = RequestStatus.OK;
        return response;
    } 
    
    public JsonResponse caseCreateInspection_Custom(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        Boolean CreateInspection = false;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        User oUsr;
        if(UserInfo.getUserId() != null){
            oUsr= [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
        }
        
        
        String proName = oUsr.Profile.Name;
        String roleName = oUsr.UserRole.Name;
        CLQ_Case_Custom__c caseCustomObj;
        if(recordId!=null){
            caseCustomObj = [Select Id,CLQ_Program_County__c,CLQ_Case_Custom_RTName__c
                             ,CLQ_Assigned_To__c,Program_Record_Type__c from CLQ_Case_Custom__c where Id =: recordId];
        }
        
        String[] JFSsfdcRoles = Label.JFS_SFDC_Roles.split(', ');
        String[] ODEsfdcRoles = Label.ODE_SFDC_Roles.split(', ');
        String[] sfdcAdminProfiles = Label.SFDC_Admin_Profiles.split(', ');
        String[] NACOCcounties = Label.JFS_NACOC_Counties.split(', ');
        String[] SCcounties = Label.JFS_SouthCentral_Counties.split(', ');
        String ErrMsg = 'Error: System cannot create a new Inspection.';
        
        if(caseCustomObj.CLQ_Assigned_To__c == null){
            ErrMsg = 'Licensing Reviewer is not assigned - System cannot create a new Inspection.';
        }else if(sfdcAdminProfiles.contains(proname)){
            CreateInspection = true;
        }else if(rolename == EMPTY_STRING || rolename == null){
            ErrMsg = 'You do not have a Role - System cannot create a new Inspection for this Case. Please contact OCLQS Help Desk.';
        }else if(caseCustomObj.Program_Record_Type__c == Child_Care_Center || caseCustomObj.Program_Record_Type__c == DAYCAMP){
            if (JFSsfdcRoles.contains(rolename)){
                CreateInspection = true;
            }
            else{
                ErrMsg = 'You do not have a "JFS Role" - System cannot create a new Inspection for this JFS Case.';
            }
        }else if (caseCustomObj.Program_Record_Type__c == Pre_School || caseCustomObj.Program_Record_Type__c == School_Age_Child_Care) {
            if (ODEsfdcRoles.contains(rolename)){
                CreateInspection = true;
            }
            else{
                ErrMsg = 'You do not have a "ODE Role" - System cannot create a new Inspection for this ODE Case.';
            }
        }else if (caseCustomObj.Program_Record_Type__c == FCC_Type_A_Home || caseCustomObj.Program_Record_Type__c == FCC_Type_B_Home) {
            if (caseCustomObj.CLQ_Program_County__c != EMPTY_STRING && caseCustomObj.CLQ_Program_County__c != null) {
                String rolenameLC = rolename.toLowerCase();
                String ProgCountyLC = caseCustomObj.CLQ_Program_County__c.toLowerCase();
                String ProgCountyUC = caseCustomObj.CLQ_Program_County__c.toUpperCase();
                String strCombinedCounties = '';
                
                if (rolenameLC.indexOf(STRING_COUNTY) >= 0) {
                    String usrCounty = rolenameLC.substring(0, rolenameLC.indexOf('county')).trim().toUpperCase();
                    List<CLQ_Combined_Counties__mdt> records = new List<CLQ_Combined_Counties__mdt>();
                    if(usrCounty != null){
                        records = [SELECT CLQ_Combined_Counties__c FROM CLQ_Combined_Counties__mdt WHERE DeveloperName =: usrCounty AND CLQ_Process_Combined_County__c = true];
                    }
                    
                    if (records.size() > 0) {
                        strCombinedCounties = records[0].CLQ_Combined_Counties__c;
                    }
                } 
                
                if ((NACOCcounties.indexOf(caseCustomObj.CLQ_Program_County__c) != -1) && ((rolenameLC.indexOf(ProgCountyLC) != -1) || (rolename.indexOf('NOCAC') != -1))){
                    CreateInspection = true;
                }
                else if ((SCcounties.indexOf(caseCustomObj.CLQ_Program_County__c) != -1) && ((rolenameLC.indexOf(ProgCountyLC) != -1) || (rolename.indexOf('South Central') != -1))){
                    CreateInspection = true;
                }
                else if (rolenameLC.indexOf(ProgCountyLC) != -1){
                    CreateInspection = true;
                }
                else if (strCombinedCounties.indexOf(ProgCountyUC) != -1){
                    CreateInspection = true;
                }
                else{
                    ErrMsg = 'You do not have a ' + caseCustomObj.CLQ_Program_County__c + ' County Role - System cannot create a new Inspection for this JFS Case.';
                }
            }else {
                ErrMsg = 'County is blank for this FCC program - System cannot create a new Inspection.';
            }
        }
        
        if (CreateInspection) {
            system.debug('');
            List<CLQ_Alleged_Rule_Violation__c> allegedRules;
            if(recordId != null){
                allegedRules = [SELECT ID from CLQ_Alleged_Rule_Violation__c 
                                where Case_Custom__c =: recordId limit 1];
            }
            
            if (allegedRules.size() > 0) {
                if (caseCustomObj.CLQ_Case_Custom_RTName__c.indexOf('Complaint') != -1){
                    response = createInspectionRecord('Complaint', 'Partial', 'Pending Processing',caseCustomObj.id);
                }else if (caseCustomObj.CLQ_Case_Custom_RTName__c.indexOf('Incident') != -1){
                    response = createInspectionRecord('Incident / Injury / Illness', 'Partial', 'Pending Processing',caseCustomObj.id);  
                }else{
                    response.errors.add('System cannot create a new Inspection for this Case Type.');   
                }
            } else{
                response.errors.add('Alleged Rule Violations need to be linked to this Case.'); 
            }
        } else{
            response.errors.add(ErrMsg);
        }
        return response;
    }
    
    public static JsonResponse createInspectionRecord(String inspectionType, String inspectionscope, String inspectionStatus, Id caseCustomId){
        JsonResponse response = null;
        response = new JsonResponse();
        response.status = RequestStatus.ERROR;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Case_Custom__c caseCustomRecord;
        if(caseCustomId != null){
            caseCustomRecord =[SELECT Id,CLQ_No_Investigation_Required__c,
                               CLQ_Inspection__c,CLQ_Program__c, CLQ_Method_of_Investigation__c,
                               CLQ_Program_Street_Address1__c, CLQ_Program_Street_Address2__c,
                               CLQ_Program_City__c, CLQ_Program_County__c, CLQ_Program_State__c,
                               CLQ_Program_Zipcode__c, CLQ_Status__c FROM CLQ_Case_Custom__c
                               WHERE Id =: caseCustomId];
        }
        
        if(!Schema.sObjectType.CLQ_Inspection__c.isCreateable()){
            response.errors.add('You have not permission to create Inspection');
            return response;
        }
        else if(caseCustomRecord.CLQ_Inspection__c != null){
            response.errors.add('You can not create inspection for this complaint');
            return response;
        }
        else{
            try{
                //1. Create inspection record for given complaint
                CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType , inspectionscope , inspectionStatus);
                inspectionrecord.CLQ_Program__c = caseCustomRecord.CLQ_Program__c;
                inspectionrecord.CLQ_Method__c = caseCustomRecord.CLQ_Method_of_Investigation__c;
                if(inspectionrecord.CLQ_Inspection_Start_Date__c != null){
                    inspectionrecord.CLQ_Inspection_Due_Date__c = (inspectionrecord.CLQ_Inspection_Start_Date__c).adddays(20); 
                }
                inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId(); 
                //inspectionrecord.CLQ_Inspection_Tool__c = (CLQ_UtilityClass.retriveInspectionToolForInspection(inspectionrecord,caseRecord.CLQ_Program__r.RecordType.Name,inspectionrecord.CLQ_Scope__c,inspectionrecord.CLQ_Inspection_Type__c)).id;
                //inspectionrecord.CLQ_Recommended_Inspection_Tool__c = inspectionrecord.CLQ_Inspection_Tool__c;
                
                
                inspectionrecord.CLQ_Street_Address_1_at_Site__c = caseCustomRecord.CLQ_Program_Street_Address1__c;
                inspectionrecord.CLQ_Street_Address_2_at_Site__c = caseCustomRecord.CLQ_Program_Street_Address2__c;
                inspectionrecord.CLQ_City_at_Site__c = caseCustomRecord.CLQ_Program_City__c;
                inspectionrecord.CLQ_County_at_Site__c = caseCustomRecord.CLQ_Program_County__c; 
                inspectionrecord.CLQ_State_at_Site__c = caseCustomRecord.CLQ_Program_State__c;
                inspectionrecord.CLQ_Zip_Code_at_Site__c = caseCustomRecord.CLQ_Program_Zipcode__c;
                
                
                insert inspectionrecord;   
                
                //Get all Tool Rules related to recommanded inspection tool
                //list<CLQ_Tools_Rules__c> toolRuleList = CLQ_UtilityClass.getToolRulesfromInspectionTool(inspectionrecord.id,Date.today());
                
                //Copy all alleged Rule to Rule inspected
                list<CLQ_Alleged_Rule_Violation__c> allegedRuleList = new list<CLQ_Alleged_Rule_Violation__c>();
                allegedRuleList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Alleged_Rule_Violation__c',' Case_Custom__c =\''+caseCustomRecord.id+'\'', null));
                map<id,CLQ_Alleged_Rule_Violation__c> domainRuleallegedRuleMap = new map<id,CLQ_Alleged_Rule_Violation__c>();
                if(allegedRuleList.size()>0){
                    list<CLQ_Rules_Inspected__c> ruleInspectedList = new list<CLQ_Rules_Inspected__c>();
                    for(CLQ_Alleged_Rule_Violation__c ruleViolationRecord : allegedRuleList){
                        ruleInspectedList.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = ruleViolationRecord.CLQ_Domain_Rule__c
                                                                         ,CLQ_Inspection_No__c = inspectionrecord.id
                                                                         ,CLQ_Alleged_Rule_Violation__c = ruleViolationRecord.id
                                                                         ,CLQ_Result__c = 'TV'
                                                                         ,CLQ_Allegation_Description__c = ruleViolationRecord.CLQ_Allegation_Description__c
                                                                         ,CLQ_Decision__c = ruleViolationRecord.CLQ_Decision__c
                                                                         /*,CLQ_Investigation_Method__c = ruleViolationRecord.CLQ_Investigation_Method__c */));
                        domainRuleallegedRuleMap.put(ruleViolationRecord.CLQ_Domain_Rule__c,ruleViolationRecord);
                    }
                    /*for(CLQ_Tools_Rules__c toolRuleRecord : toolRuleList){
if(domainRuleallegedRuleMap.get(toolRuleRecord.CLQ_Domain_Rule__c) == null){
ruleInspectedList.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = toolRuleRecord.CLQ_Domain_Rule__c
,CLQ_Inspection_No__c = inspectionrecord.id
,CLQ_Result__c = 'Not Verified'));
}
}*/
                    insert ruleInspectedList;
                }
                
                //2a. Copy all Room/Space records to inspection
                list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
                if(caseCustomRecord.CLQ_Program__c != null){
                    roomSpaceList = CLQ_UtilityClass.queryRoomSpacefromProgram(caseCustomRecord.CLQ_Program__c);
                    if(roomSpaceList.size()>0){
                        list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = CLQ_UtilityClass.createRoomSpaceInspection(roomSpaceList , inspectionrecord);
                        insert roomSpaceInspectionList;
                    }                    
                }
                //2b Update all Building approvals related records
                list<CLQ_Building_Approval__c> buildingApprovallist = CLQ_UtilityClass.copyBuildingApprovaltoinspection(caseCustomRecord.CLQ_Program__c,inspectionrecord.id);
                if(!buildingApprovallist.isEmpty()){
                    upsert buildingApprovallist ;
                    //update buildingApprovallist ;
                }
                
                //2c update all facility schedule related record
                list<CLQ_Facility_Schedule__c> facilitySchedulelist = new list<CLQ_Facility_Schedule__c>();
                facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program__c='+'\''+caseCustomRecord.CLQ_Program__c+'\'', null));
                if(!facilitySchedulelist.isEmpty()){
                    update CLQ_UtilityClass.copyfacilityScheduletoinspection(facilitySchedulelist,inspectionrecord.id);
                }
                
                //2d UPdate all roles
                list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
                roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', 'CLQ_Status__c = \'Active\' AND CLQ_Program__c='+'\''+caseCustomRecord.CLQ_Program__c+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId()+'\'', null));
                if(roleList.size()>0){
                    for(CLQ_Role__c roleRecord: roleList  ){
                        roleRecord.CLQ_Inspection__c = inspectionrecord.id;
                    }
                    if(!roleList.isEmpty()){
                        update roleList;
                    } 
                }
                
                // Update Case Custom Details
                caseCustomRecord.CLQ_Inspection__c = inspectionrecord.id;
                caseCustomRecord.CLQ_Status__c = 'Under Review';
                List<CLQ_Case_Custom__c> caselist = new List<CLQ_Case_Custom__c>();
                caselist.add(caseCustomRecord);
                if(!caselist.isEmpty()){
                    update caselist;
                }
                Map<String, String> mapRedirectAttributes = new Map<String, String>();
                mapRedirectAttributes.put('recordId', inspectionrecord.Id);
                mapRedirectAttributes.put('actionName', 'view');
                
                response = new JsonResponse();
                response.status = RequestStatus.OK;
                response.data = new Map<String, Object>();
                response.data.put('successMessage', 'Inspection Created Successfully');
                response.data.put('redirect', true);
                response.data.put('redirectType', 'standard__recordPage');
                response.data.put('redirectAttributes', mapRedirectAttributes);
                response.errors = new List<String>();
            }catch(DmlException e){
                
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(e.getDmlMessage(0));
            }
            catch(Exception e){
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(e.getMessage());
            } 
        }
        return response;
    }
    
    public CLQ_Case_Custom__c updateRecord(String recId, Boolean startApproval){
        CLQ_Case_Custom__c caseCustom = new CLQ_Case_Custom__c();
        caseCustom.Id = recId;
        caseCustom.CLQ_Start_Approval__c = startApproval;
        return caseCustom;        
    }
}