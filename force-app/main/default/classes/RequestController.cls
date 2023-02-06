/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Initial pipeline to process / delegate request
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of RequestController @version 1.0
 */
public with sharing class RequestController {
    /**
     * Used to delegate request by creating an instance of the class which implements IRequest
     * 
     * @param className - Name of the Apex class which implements IRequest
     * @param methodName - Name of the method to be invoked internally with in the Apex class
     * @param jsonParam - Request params in String format
     * 
     * @return string - JSON response
     */
    
    public static final String EMPTY_STRING = ' ';
    @AuraEnabled
    public static string delegateRequest(String className, String methodName, String jsonParam, String validationMethodName, Boolean bValidate){
        try{
            Type classType = Type.forName(className);
            IRequest req = (IRequest)classType.newInstance();
            //JsonResponse valResponse;
            JsonResponse response;
            bValidate = false;

            if(bValidate) {
                response = req.validate(validationMethodName, jsonParam);
            } 
            if(bValidate && response.status == RequestStatus.OK) {
                response = req.processRequest(methodName, jsonParam);
            } else if(!bValidate) {
                response = req.processRequest(methodName, jsonParam);
            }
            
			return JSON.serialize(response);
        }
        catch(Exception ex){
            JsonResponse response = new JsonResponse();
            response.status = RequestStatus.UNKNOWN_ERROR;
            response.data = null;
            response.errors = new List<String>();
            response.errors.add(ex.getStackTraceString() + EMPTY_STRING + ex.getLineNumber());
            return JSON.serialize(response);
        }
    }
}