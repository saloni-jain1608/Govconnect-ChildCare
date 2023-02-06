/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Interface to define service contract for processing requests
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of IRequest @version 1.0
 */
public interface IRequest {

    /**
     * Validates the request and resturns JSON response
     * 
     * @param methodName - Name of the Validation method
     * @param jsonParam - JSON parameter to be de-serialized
     * 
     * @return JsonResponse - Response holding status, data & errors as part of request processed
     */
    JsonResponse validate(String methodName, String jsonParam);

    /**
     * Processes the request and resturns JSON response
     * 
     * @param methodName - Name of the method
     * @param jsonParam - JSON parameter to be de-serialized
     * 
     * @return JsonResponse - Response holding status, data & errors as part of request processed
     */
    JsonResponse processRequest(String methodName, String jsonParam);

}