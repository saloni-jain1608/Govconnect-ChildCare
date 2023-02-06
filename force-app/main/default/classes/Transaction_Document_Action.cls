public with sharing class Transaction_Document_Action implements IRequest{
    private String jsonParam;
    
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
        
        try{
            CLQ_Transaction_Document__c docObj = [Select CLQ_All_Comments__c,CLQ_Document_Status__c,CLQ_Document__c,Document_Points__c,Rating__c from CLQ_Transaction_Document__c where id=: this.jsonParam];
            if(methodName == 'documentApprove'){
                response = documentApprove(docObj);
            }else if(methodName == 'documentDenied'){
                response = documentDenied(docObj);
            }else if(methodName == 'documentNotVerified'){
                response = documentNotVerified(docObj);
            }else if(methodName == 'documentReturnRevision'){
                response = documentReturnRevision(docObj);
            }else{
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add('Invalid method name');
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
    
    public JsonResponse documentApprove(CLQ_Transaction_Document__c docObj){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        // CLQ_Transaction_Document__c docObj = [Select CLQ_Document__c,Document_Points__c,Rating__c from CLQ_Transaction_Document__c where id=: recordId];
        
        if(docObj.CLQ_Document__c == null){
            response.errors.add('Standard Document is needed to approve the Transaction Document');
            return response;
        }else if(docObj.CLQ_Document_Status__c != 'Approved'){
            CLQ_Transaction_Document__c docUpd = new CLQ_Transaction_Document__c();
            docUpd.id = recordId;
            docUpd.CLQ_Document_Status__c = 'Approved';
            Database.SaveResult srResult = Database.update(docUpd,false);
            
            if(srResult.isSuccess()){
                try{
                    CLQ_Standard_Document__c standDocUpd = new CLQ_Standard_Document__c();
                    standDocUpd.id = docObj.CLQ_Document__c;
                    if(docObj.Rating__c != null){
                        standDocUpd.CLQ_Document_Rating__c = docObj.Rating__c;
                    }else{
                        standDocUpd.CLQ_Document_Rating__c = null;
                    }
                    
                    if(docObj.Document_Points__c != null){
                        standDocUpd.CLQ_Document_Points__c = string.valueOf(docObj.Document_Points__c);
                    }else{
                        standDocUpd.CLQ_Document_Points__c = null;
                    }
                    update standDocUpd;
                    
                }catch(Exception e){
                    response.errors.add(e.getMessage());
                    return response;
                }
            }else{
                for(Database.Error err : srResult.getErrors()) {
                    response.errors.add(err.getMessage());
                    return response;                         
                }
            }
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse documentDenied(CLQ_Transaction_Document__c docObj){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        if(docObj.CLQ_Document_Status__c != 'Denied') {
            CLQ_Transaction_Document__c docUpd = new CLQ_Transaction_Document__c();
            docUpd.id = recordId;
            docUpd.CLQ_Document_Status__c = 'Denied';
            update docUpd;
        }
        
        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    
    public JsonResponse documentNotVerified(CLQ_Transaction_Document__c docObj){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        if(docObj.CLQ_Document_Status__c != 'Not Verified'){
            CLQ_Transaction_Document__c docUpd = new CLQ_Transaction_Document__c();
            docUpd.id = recordId;
            docUpd.CLQ_Document_Status__c = 'Not Verified';
            update docUpd;
        }
        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    
    public JsonResponse documentReturnRevision(CLQ_Transaction_Document__c docObj){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        // CLQ_Transaction_Document__c docObj = [Select CLQ_All_Comments__c,CLQ_Document_Status__c from CLQ_Transaction_Document__c where id=: recordId];
        
        if(docObj.CLQ_All_Comments__c == null){
            response.errors.add('Please enter Document Comments');
            return response;
        }else if(docObj.CLQ_Document_Status__c != 'Under Review'){
            CLQ_Transaction_Document__c docUpd = new CLQ_Transaction_Document__c();
            docUpd.id = recordId;
            docUpd.CLQ_Document_Status__c = 'Under Review';
            update docUpd;
        }
        
        
        response.status = RequestStatus.OK;
        return response;
    }
}