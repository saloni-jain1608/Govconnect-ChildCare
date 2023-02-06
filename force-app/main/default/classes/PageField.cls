public with sharing class PageField {
    public String Id {get; set;}
    public Decimal OrderNumber {get; set;}
    public String Type {get; set;}
    public String Label {get; set;}
    public Boolean Required {get; set;}
    public Boolean ReadOnly {get; set;}
    public String Validator {get; set;}
    public String CSSClasses {get; set;}
    public String ObjectApi {get; set;}
    public String Value {get; set;}
    public String FieldApi {get; set;}
    public String SubSection {get; set;}
    public String Label_Lang {get; set;}
    public String language {get; set;}
    public String Pattern {get; set;}
    public String Pattern_Mismatch_Message {get; set;}
    public String copy_options {get; set;}
    //public List<String> PicklistValues {get; set;}
    public List<Map<String, String>> PicklistValues {get; set;}
    
    public PageField(PGFField__c pageField, String sValue, string language) {
        this.Id = String.valueOf(pageField.Id);
        this.OrderNumber = pageField.OrderNumber__c;
        this.Label = pageField.Label__c;
        this.Type = pageField.Type__c;
        this.Required = pageField.Required__c;
        this.ReadOnly = pageField.ReadOnly__c;
        this.Validator = pageField.Validator__c;
        this.CSSClasses = pageField.CSSClasses__c;
        this.SubSection = pageField.Parent__c;
        this.ObjectApi = pageField.ObjectAPIName__c;
        this.FieldApi = pageField.Name;
        this.Value= sValue;
        this.language=language;
        this.Label_Lang =pageField.Label__c;
        this.Pattern=pageField.Pattern__c;
        this.Pattern_Mismatch_Message=pageField.Pattern_Mismatch_Message__c;
        this.copy_options=pageField.Copy_Options__c;
        
        /*if(this.language=='German'){
            if(!String.isBlank(pageField.German__c)){
                this.Label=pageField.German__c;
                this.Label_Lang=pageField.German__c;
            }
        }
        else if(this.language=='Spanish'){
            if(!String.isBlank(pageField.Spanish__c)){
                this.Label=pageField.Spanish__c;
                this.Label_Lang=pageField.Spanish__c;
            }
        }
        else{
            this.Label=pageField.Label__c;
            this.Label_Lang=pageField.Label__c;
        }*/
        
        if(pageField.Type__c == 'Picklist' || pageField.Type__c == 'Multi-Select'){
            this.PicklistValues = GetPickListValues(pageField.ObjectAPIName__c, pageField.Name);  
        }else{
            //this.PicklistValues = new List<String>();
        }
    }
    
    /**
* Used to obtain picklist values of a field
* 
* @param objName - Name of the SObject Ex: Account, Category__c
* @param fieldName - API name of the field
* 
* @return List<String> - List of picklist values
*/
    private List<Map<String, String>> GetPickListValues(String objName, String fieldName){
        
        List<Map<String, String>> values = new List<Map<String, String>>();
        
        try{
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSobjectResult objTypeDesc = objType.getDescribe();
            Map<String,Schema.SObjectField> fields = objTypeDesc.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                //values.add(pickListVal.getValue());
                Map<String, String> optionsMap = new Map<String, String>();
                
                optionsMap.put('label',pickListVal.getValue());
                optionsMap.put('value',pickListVal.getValue());
                values.add(optionsMap);
            }
        }
        catch(Exception ex){
            throw new DMLException('Could not find specified object / field');
        }
        
        return values;
    }
}