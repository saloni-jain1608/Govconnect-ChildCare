/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Wrapper to define response
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of JsonResponse @version 1.0
 */
public with sharing class JsonResponse {
    //Holds processed status of the request
    public RequestStatus status {get; set;}
    //Holds data Map
    @AuraEnabled
    public Map<String, Object> data {get; set;}
    //Holds errors if any as part of the request processed
    public List<String> errors {get; set;}
}