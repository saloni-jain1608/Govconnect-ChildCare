public with sharing class RequiredCheckListItems {
   
    @AuraEnabled
    public static List<Required_Checklist__mdt> getChecklistRecords(){
        try {
            List<Required_Checklist__mdt> lstQuestion = [Select id,Question__c from Required_Checklist__mdt];
            return lstQuestion;           
		
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        //return null;
    }
}