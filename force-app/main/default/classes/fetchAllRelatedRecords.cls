public with sharing class fetchAllRelatedRecords {
        @AuraEnabled(cacheable=true)
        public static string getBgList(Background_Check__c backgroundcheckRecord, string firstName, string lastName, string ssn, date dob, string facilityNum, string facilityName, string applicantName,string county,string applicationType,date consentReceivedDate,string juvenile,string bgCheckStatus) {
               
           // create contact list to store search result 
            list<Background_Check__c> bgFullListRecord = new list<Background_Check__c>();
            list<String> UniqueIdList = new list<String>();

            String filters = '';
            String jsonDT = '';
            
            if(firstName != '') {
             filters = 'First_Name__c Like :firstName';
            }
            if(lastName != '') {
                filters = filters + (!String.isBlank(filters) ?  (' AND Last_Name__c Like :lastName ') : (' Last_Name__c Like :lastName '));
            }
            if(ssn != '') {
                filters = filters + (!String.isBlank(filters) ? (' AND SSN__C Like :ssn ') : (' SSN__C Like :ssn '));
            }
            if(dob != null) {
                filters = filters + (!String.isBlank(filters) ? (' AND Date_of_Birth__c = :dob ') : (' Date_of_Birth__c = :dob '));
            }
            if(facilityName != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Program__r.Name like :facilityName ') : (' Program__r.Name like :facilityName '));
            }
            if(facilityNum != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Program__r.CLQ_Program_Number__c like :facilityNum ') : (' Program__r.CLQ_Program_Number__c like :facilityNum '));
             }
             if(applicantName != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Applicant_Name__c like :applicantName ') : (' Applicant_Name__c like :applicantName '));
             }
             if(county != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND County__r.Id = :county ') : (' County__r.Id = :county '));
             }
             if(applicationType != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Application_Type__c Like :applicationType ') : (' Application_Type__c Like :applicationType' ));
             }
             if(consentReceivedDate != null) {
                filters = filters + (!String.isBlank(filters) ? (' AND Consent_Received_Date__c = :consentReceivedDate ') : (' Consent_Received_Date__c = :consentReceivedDate '));
             }
             if(juvenile != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Juvenile__c Like :juvenile ') : (' Juvenile__c Like :juvenile' ));
             }
             if(bgCheckStatus != ''){
                filters = filters + (!String.isBlank(filters) ? (' AND Background_Check_Status__c Like :bgCheckStatus ') : (' Background_Check_Status__c Like :bgCheckStatus' ));
             }

           // query contact records
           String query = 'SELECT id,Email_Address__c,First_Name__c,Last_Name__c,Phone_Number__c,Consent_Received_Date__c,Consent_Due_Date__c,Application_Type__c,Unique_Id__c FROM Background_Check__c';
           if(!String.isBlank(filters)) {
            query += ' WHERE ' + filters + ' ORDER BY Application_Type__c, Consent_Received_Date__c';
          }
          System.debug('Query-->'+ query);
          Integer totalRecords = 0;
             for(Background_Check__c conObj : Database.query(query)){
                system.debug('Is contains' +UniqueIdList.contains(conObj.Unique_Id__c));
                boolean isUnique = UniqueIdList.contains(conObj.Unique_Id__c);
                if(isUnique == false){
                    if(String.isNotBlank(conObj.Unique_Id__c)){
                        UniqueIdList.add(conObj.Unique_Id__c);
                    }
                    bgFullListRecord.add(conObj);
                    totalRecords+=1;
                }
                
             }
             system.debug('Full List'+bgFullListRecord);
             if(bgFullListRecord.size() == 0){
                throw new AuraHandledException('No Record Found..'); 
             }
             
            //return bgListRecord;
            BackgroundCheckDTWrapper objDT =  new BackgroundCheckDTWrapper();  
            objDT.totalRecords = totalRecords;
            objDT.bgFullrecords = bgFullListRecord;

            jsonDT = JSON.serialize(objDT);
            return jsonDT;
        }

        public class BackgroundCheckDTWrapper {
            public Integer totalRecords {get;set;}
            public List<Background_Check__c> bgFullrecords {get;set;}
        }

        @AuraEnabled(cacheable=true)
        public static List<OptionWrapper> getCountyList(){
            List<OptionWrapper> countyNameList = new List<OptionWrapper>();
            List<CLQ_County__c> countyList = new List<CLQ_County__c>();
            for(CLQ_County__c county :[SELECT Id, Name FROM CLQ_County__c]){
                countyNameList.add(new OptionWrapper(county.Name, county.Name));
              }
           
           return countyNameList; 
        }
        public class OptionWrapper {
            @AuraEnabled
            public String label {get; set;}
            @AuraEnabled
            public String value {get; set;}
    
            public OptionWrapper(String label, String value) {
                this.label = label;
                this.value = value;
            }
        }

    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey ) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From CLQ_County__c  Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From CLQ_County__c Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    }