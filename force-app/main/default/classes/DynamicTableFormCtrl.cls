/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Provides functionality to render dynamic table and Forms
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of DynamicTableFormCtrl @version 1.0
 * 
 */
public without sharing class DynamicTableFormCtrl implements IRequest {
    private String jsonParam;
	public static final string GET_TABLE_DATA = 'getTableData';
    private Map<String, String> programTransactionMap = new Map<String, String>();
    


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

        programTransactionMap.put('CLQ_Facility_Schedule__c', 'CLQ_Program_Transaction__c');
        programTransactionMap.put('CLQ_Role__c', 'CLQ_Program_Transaction_Source__c');
        programTransactionMap.put('CLQ_Room_Space_Transaction__c', 'CLQ_Program_Transaction__c');
        
        if(methodName == GET_TABLE_DATA){
            try{
                response = getTableData();
            }
            catch(Exception ex){
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(ex.getMessage());
            }
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

    public JsonResponse validate(String methodName, String jsonParam) {
        JsonResponse response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }

    private JsonResponse getTableData() {
        JsonResponse response = null;
        List<String> tableHeaders = new List<String>();
        TableRequest request = (TableRequest)JSON.deserialize(this.jsonParam, TableRequest.class);
        List<RecordType> programRecordTypes;
        string reqRecordName=request.recordTypeName;
        string reqObjectName=request.objectName;
        if(reqRecordName != null && reqObjectName != null){
            programRecordTypes = [SELECT Id, Name from RecordType where name =:reqRecordName AND SObjectType=:reqObjectName];
        }
        String query = 'SELECT ';
        for(Integer i = 0; i < request.tableInfo.size(); i++){
            tableHeaders.add(request.tableInfo[i].Label);
            if(i == request.tableInfo.size() - 1){
                query += request.tableInfo[i].FieldName;
            }
            else{
                query += request.tableInfo[i].FieldName + ', ';
            }
        }
        if(programTransactionMap.size()!=0){
        query += ' FROM ' + request.objectName + ' WHERE CLQ_Program__c = ' + escapeValue(request.programID) + ' AND CLQ_Program__c <> null ' + ' AND ' + programTransactionMap.get(request.objectName) + ' = ' + escapeValue(request.programTransactionID);
        }
        if(programRecordTypes != null && programRecordTypes.size() > 0){
            query += ' AND RecordTypeId = ' + escapeValue(programRecordTypes[0].Id);
        }

        query += ' ' + request.whereClause;

        List<sObject> sobjList = Database.query(query);



        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.data.put('Query', query);
        response.data.put('TableHeaders', tableHeaders);
        if(programRecordTypes != null && programRecordTypes.size() > 0){
            response.data.put('RecordTypeId', programRecordTypes[0].Id);
        }else{
            response.data.put('RecordTypeId', '');
        }
        response.data.put('TableData', sobjList);
        response.errors = new List<String>();

        return response;
    }

    /**
     * Encloses the value in single quotes
     * 
     * @param value - value to be enclosed
     */
    private String escapeValue(String value){
        return '\'' + String.escapeSingleQuotes(value) + '\'';
    }

    public class TableRequest {
        public String programID {get; set;}
        public String programTransactionID {get; set;}
        public String recordTypeName {get; set;}
        public String objectName {get; set;}
        public String whereClause {get; set;}
        public List<PageSubSection.FormComponent> tableInfo {get; set;} 
    }
}