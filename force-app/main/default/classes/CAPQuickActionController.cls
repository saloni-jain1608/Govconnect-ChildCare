public with sharing class CAPQuickActionController implements IRequest{
    public static final string updateCAPonQuickActionClickString = 'updateCAPonQuickActionClick';
    public static final string Approve = 'Approve';
    public static final string Deny = 'Deny';
    public static final string Not_Required = 'Not_Required';
    public static final string ReturnRev = 'ReturnRev';
    public static final string Approved = 'Approved';
    public static final string Report_Revised_Not_Required = 'Report_Revised_Not_Required';
    public static final string Closed_Not_Addressed = 'Closed_Not_Addressed';
    public static final string Returned_for_Revision = 'Returned for Revision';
    public static final string Invalid_method_name = 'Invalid method name';
    public static final string boolStatus = 'boolStatus';
    public static final string boolReviewerCommAdded = 'boolReviewerCommAdded';
    public static final string StringTrue = 'true';
    public static final string StringFalse = 'false';
	public static final String EMPTY_STRING = '';    
    public static Map<String,Object> mapAssign = new Map<String,Object>();
    
    public static Map<String, String> capMetadataValueMap = new  Map<String, String>();
    
    public JsonResponse validate(String methodName, String jsonParam) {
        JsonResponse response = null;
        
        try {
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            
            if(capMetadataValueMap.size()!=0 && methodName == capMetadataValueMap.get(updateCAPonQuickActionClickString)) {
                response = updateCAPonQuickActionClick(jsonParam,jsonParam);
            }  else {
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(Invalid_method_name);
            }
            
        } catch(Exception ex) {
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    
    public JsonResponse processRequest(String methodName, String jsonParam) {
        JsonResponse response;
        
        try {
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            if(capMetadataValueMap.size()!=0 && methodName == capMetadataValueMap.get(updateCAPonQuickActionClickString)) {
                response = updateCAPonQuickActionClick(jsonParam,jsonParam);
            }  else {
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(Invalid_method_name);
            }
        } catch(Exception ex){
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    @AuraEnabled
    public static JsonResponse updateCAPonQuickActionClick(String strRecordId,String strQuickAction){
        JsonResponse response;
        system.debug('strRecordId=='+strRecordId);
        
        system.debug('str--'+strRecordId);
        system.debug('strQuickAction--'+strQuickAction);
        Boolean boolStatusChanged = false;
        //  CAPWrapper objCAPMain = new CAPWrapper();
        CLQ_Corrective_Action_Plan__c objCAP;
        try {
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            if(strRecordId != null) {
                objCAP = [SELECT Id,CLQ_CAP_Status__c,CLQ_Reviewer_Comments__c FROM CLQ_Corrective_Action_Plan__c where Id=:strRecordId];
                system.debug('objCAP=='+objCAP);
                if(capMetadataValueMap.size()!=0 && strQuickAction == capMetadataValueMap.get(Approve)) {
                    response = approveCAP(objCAP);
                } else if(capMetadataValueMap.size()!=0 && strQuickAction == capMetadataValueMap.get(Deny)) {
                    response = DenyCAP(objCAP);
                } else if(capMetadataValueMap.size()!=0 && strQuickAction == capMetadataValueMap.get(Not_Required)) {
                    response = NotRequiredCAP(objCAP);
                } else if(capMetadataValueMap.size()!=0 && strQuickAction == capMetadataValueMap.get(ReturnRev)) {
                    response = ReturnRevCAP(objCAP);
                }                               
            }
            system.debug('resp=='+response);
        } catch (Exception ex) {
            system.debug('e'+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
        return response;
    }
    
    public static JsonResponse approveCAP(CLQ_Corrective_Action_Plan__c objCAPlan){                     
        try {           
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            JsonResponse response = new JsonResponse();  
            if(capMetadataValueMap.size()!=0 && objCAPlan.CLQ_CAP_Status__c != capMetadataValueMap.get(Approved)) {
                objCAPlan.CLQ_CAP_Status__c = capMetadataValueMap.get(Approved);
                if(objCAPlan!=null){
                    update objCAPlan;
                }
                
                mapAssign.put(boolStatus, StringTrue);
                response.data = mapAssign; 
            }  else {
                mapAssign.put(boolStatus, StringFalse);
                response.data = mapAssign;
            }
            system.debug('responseApp=='+response);
            return response;
        } catch(Exception ex) {
            system.debug('ex==0'+ex.getMessage());
            JsonResponse response = new JsonResponse();
            response.status = RequestStatus.UNKNOWN_ERROR;
            response.data = null;
            response.errors = new List<String>();
            response.errors.add(ex.getStackTraceString() + ' ' + ex.getLineNumber());
            return response;
        }                
    }
    
    public static JsonResponse NotRequiredCAP(CLQ_Corrective_Action_Plan__c objCAPlan){
        try { 
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            JsonResponse response = new JsonResponse();  
            if(objCAPlan.CLQ_Reviewer_Comments__c == EMPTY_STRING || objCAPlan.CLQ_Reviewer_Comments__c == null) {
                mapAssign.put(boolReviewerCommAdded, StringFalse);
                response.data = mapAssign;             
            } else if(capMetadataValueMap.size()!=0 && objCAPlan.CLQ_CAP_Status__c != capMetadataValueMap.get(Report_Revised_Not_Required)) {
                objCAPlan.CLQ_CAP_Status__c = capMetadataValueMap.get(Report_Revised_Not_Required);
                if(objCAPlan!=null){
                    update objCAPlan;
                }
                mapAssign.put(boolStatus, StringTrue);
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            } else {
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            }
            return response;
        } catch(Exception ex) {
            JsonResponse response = new JsonResponse();
            response.status = RequestStatus.UNKNOWN_ERROR;
            response.data = null;
            response.errors = new List<String>();
            response.errors.add(ex.getStackTraceString() + ' ' + ex.getLineNumber());
            return response;
        } 
    }
    
    public static JsonResponse DenyCAP(CLQ_Corrective_Action_Plan__c objCAPlan){
        try {
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }
            JsonResponse response = new JsonResponse();  
            if(objCAPlan.CLQ_Reviewer_Comments__c == EMPTY_STRING || objCAPlan.CLQ_Reviewer_Comments__c == null) {
                mapAssign.put(boolReviewerCommAdded, StringFalse);
                response.data = mapAssign;
            } else if(capMetadataValueMap.size()!=0 && objCAPlan.CLQ_CAP_Status__c != capMetadataValueMap.get(Closed_Not_Addressed)) {
                objCAPlan.CLQ_CAP_Status__c = capMetadataValueMap.get(Closed_Not_Addressed);
                if(objCAPlan!=null){
                    update objCAPlan;
                }
                mapAssign.put(boolStatus, StringTrue);
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            }else {
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            }
            return response;
        } catch(Exception ex) {
            JsonResponse response = new JsonResponse();
            response.status = RequestStatus.UNKNOWN_ERROR;
            response.data = null;
            response.errors = new List<String>();
            response.errors.add(ex.getStackTraceString() + ' ' + ex.getLineNumber());
            return response;
        } 
    }
    
    public static JsonResponse ReturnRevCAP(CLQ_Corrective_Action_Plan__c objCAPlan){
        try { 
            for(CAPQuickActionController__mdt mdt : [Select label,QualifiedApiName from CAPQuickActionController__mdt]){
                capMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
            }           
            JsonResponse response = new JsonResponse();  
            if(objCAPlan.CLQ_Reviewer_Comments__c == EMPTY_STRING || objCAPlan.CLQ_Reviewer_Comments__c == null) {            
                mapAssign.put(boolReviewerCommAdded, StringFalse);
                response.data = mapAssign;
            } else if(capMetadataValueMap.size()!=0 && objCAPlan.CLQ_CAP_Status__c != capMetadataValueMap.get(Returned_for_Revision)) {
                objCAPlan.CLQ_CAP_Status__c = capMetadataValueMap.get(Returned_for_Revision);
                if(objCAPlan!=null){
                    update objCAPlan;
                }
                mapAssign.put(boolStatus, StringTrue);
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            } else {
                mapAssign.put(boolReviewerCommAdded, StringTrue);
                response.data = mapAssign;
            }
            return response;
        } catch(Exception ex) {
            JsonResponse response = new JsonResponse();
            response.status = RequestStatus.UNKNOWN_ERROR;
            response.data = null;
            response.errors = new List<String>();
            response.errors.add(ex.getStackTraceString() + ' ' + ex.getLineNumber());
            return response;
        } 
    }
    
}