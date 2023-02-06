/**
 * Class Name    : ISD_CreateLightningServerResponse
 * Owner         : Srivatsan
 * Created Date  : 02/13/2017
 * Description   : Wrapper class created to send response information requested by any lightning component to client
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer       Description                                                         
 *  ----------  -----------     -------------------------------------------------------------------
    02/13/2017  Srivatsan       First version created the wrapper to send client data
    03/23/2017  Wesly           Added 3rd constructor for error handling framework
 **/
 
public with sharing class ISD_CreateLightningServerResponse {
    @AuraEnabled public Boolean isSuccessful {get; private set;}
    @AuraEnabled public String successMessage { get; private set;}
    @AuraEnabled public String errorMessage { get; private set;}
    @AuraEnabled public List<String> errorFieldApiNames { get; private set;}
    @AuraEnabled public map<String, Object> mapErrorInfo { get; private set; }
    @AuraEnabled public map<String, Object> objectData { get; private set; }
    public ISD_CreateLightningServerResponse(Boolean isSuccessful, String message, List<String> errorFieldApiNames,map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        if(isSuccessful)this.successMessage = message;
        else this.errorMessage = message;
        this.errorFieldApiNames = errorFieldApiNames;
        this.objectData = objectData;
    }
    //Overloading constructor with different input parameters
    public ISD_CreateLightningServerResponse(Boolean isSuccessful,String message,map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        if(isSuccessful)this.successMessage = message;
        this.objectData = objectData;
    }
    
    /* Use this contructor ALWAYS - it has error handling implemented */
    public ISD_CreateLightningServerResponse(Boolean isSuccessful, map<String, Object> mapErrorInfo, map<String, Object> objectData) {
        this.isSuccessful = isSuccessful;
        this.mapErrorInfo = mapErrorInfo;
        this.objectData = objectData;
    }
    
    public ISD_CreateLightningServerResponse() {
        this.isSuccessful = isSuccessful;
    }
}