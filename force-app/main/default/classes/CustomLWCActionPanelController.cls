public with sharing class CustomLWCActionPanelController {
    
    @AuraEnabled
    public static ISD_CreateLightningServerResponse getActions(String sObjectApiName) {

        Boolean bIsSuccessful = true;
        Map<String, object> mapErrorInfo = new Map<String, object>();
        Map<String, object> mapObjectData = new Map<String, object>();

        //Query Metadata to fetch actions for this object
        List<Lightning_Actions_Configuration__mdt> lstActions = new List<Lightning_Actions_Configuration__mdt>();
        
        try {
            if(sObjectApiName != null){
                lstActions = [SELECT Id, MasterLabel, Button_Label__c,Show_Record_Types__c, Class_Method__c, Class_Name__c, Component_Type__c, Object_API_Name__c,   
                        Validation_Method__c, Validation_Required__c 
                        FROM Lightning_Actions_Configuration__mdt WHERE Object_API_Name__c =: sObjectApiName];
            }
            
            
            mapObjectData.put('lstConfigs', lstActions);
        } catch(Exception oEx) {
            bIsSuccessful = false;            
        }
        return new ISD_CreateLightningServerResponse(bIsSuccessful, mapErrorInfo, mapObjectData);
    }
}