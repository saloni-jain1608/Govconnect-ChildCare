public without sharing class vdssCommunityProgramsMain {
    
    // This method will fetch all programs associated with the community user account.
    @AuraEnabled 
    public static String getUserPrograms(String userId) {
        List<Program> programs = new List<Program>();
        List <CLQ_Program__c> programList;
        //List <CLQ_Program_Transaction__c> programApplList;
        List<CLQ_Program_Transaction__c> programTransactions;
        List<CLQ_Inspection__c> inspections;
        Boolean actionRequired = false;
        
        User userDetails = [SELECT Id, ContactId, AccountId FROM User WHERE Id=: userId];
        
        String accountId = userDetails.AccountId;
        String queryString = 'SELECT Id, Name, (SELECT Id from Inspections__r), (SELECT Id,CLQ_Transaction_Status__c  FROM Program_Transactions__r ORDER BY CreatedDate DESC), CLQ_Program_Number__c, CLQ_Program_Status__c, CLQ_Is_Withdrawn__c, CLQ_License_Registration_Status__c, CLQ_License_Type__c, License_Begin_Date__c, License_End_Date__c,Program_Icon_For_Portal__c FROM CLQ_Program__c WHERE CLQ_Is_Withdrawn__c = false and CLQ_Associated_Organization__c =\'' + accountId + '\' ORDER BY CreatedDate Desc';
        programList = Database.query(queryString);
        
        
        for(CLQ_Program__c program : programList){
            Id programTransactionId = null;
            string programTransactionStatus;
            system.debug('program.Program_Transactions__r=='+program.Program_Transactions__r);
            for(CLQ_Program_Transaction__c oProgTransaction : program.Program_Transactions__r) {
                programTransactionId = oProgTransaction.Id;
                programTransactionStatus=oProgTransaction.CLQ_Transaction_Status__c;
                break;
            }
            
            if(programTransactionId != null) {
                Program p = new Program(program, programTransactionId,programTransactionStatus);
                programs.add(p);
            }
            
        }
        return JSON.serialize(programs);
    }
    
    // This method will fetch all fields from the object 
    public static String fetchAllFieldsFromObject(String objectApi) {
        
        String allObjFields=''; 
        //String fullQueryString='';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApi).getDescribe().fields.getMap(); //describeResult.fields.getMap();
        
        for(Schema.SObjectField field : fieldMap.Values()){
            Schema.DescribeFieldResult fieldRes = field.getDescribe();
            allObjFields += fieldRes.getName() + ',';
        }
        allObjFields = allObjFields.substring(0, allObjFields.length()-1);
        //fullQueryString=' SELECT ' + strfieldName + ' FROM ' + objectApi + ' ' +whereClause;
        
        return allObjFields;
    }
    
    @AuraEnabled 
    public static String createTransactionDocumentRecord(String programTransactionId, String documentName, string documentId, string FileName) {
        String transactionDocId='';
        
        
        CLQ_Transaction_Document__c transDoc = new CLQ_Transaction_Document__c(CLQ_Program_Transaction__c=programTransactionId,Name=documentName);
        //Hard coding lookup fields
        //transDoc.CLQ_Document__c = 'a1i6w00000023Uj';
        //transDoc.CLQ_Standard_Detail_Document__c = 'a1h6w0000004dcC';
        transDoc.CLQ_Document_Type__c = 'Application Documents';
        insert transDoc;
        transactionDocId = transDoc.Id;
        
        if(!string.isEmpty(documentId)){
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = documentId;
            cDe.LinkedEntityId = transDoc.Id;   // Object A Id
            cDe.ShareType = 'I'; 
            insert cDe;
        }
        
        return transactionDocId;
    }
    
    
    // This method will fetch all the program application metadata and create a JSON structure
    @AuraEnabled 
    public static String getDynamicApplicationMetadata(String applicationType, String selectedProgramId, String userId, Id programTransactionId, string language) {
        
        List<User> userDetails = [SELECT Id, ContactId, AccountId FROM User WHERE Id=: userId];
        String applicationName = applicationType;//'Licensing - New Application - CC Center - Corporation';
        //String applicationName = 'Licensing - New Application - Day Camp - Individual Ownership';
        //String applicationPageId='a2B6w000000GvLgEAK';
        String jsonData = '';
        
        if(userDetails != null && userDetails.size()>0) {
            
            List<Account> userAccountDetails = [SELECT Id, Ownership, Provider_Type__c FROM Account WHERE Id=: userDetails[0].AccountId];
            
            if(userAccountDetails!=null && userAccountDetails.size()>0){
                
                if(userAccountDetails[0].Provider_Type__c !=null){
                    applicationName = applicationName +' - ' + userAccountDetails[0].Provider_Type__c; 
                }
                
                if(userAccountDetails[0].Ownership !=null){
                    applicationName = applicationName +' - '+ userAccountDetails[0].Ownership;
                }
            }
        }
        
        List<PGFPage__c> pageApplication = [SELECT Id FROM PGFPage__c WHERE Name=: applicationName];
        
        System.debug('========== applicationName ============> '+applicationName);
        
        if(pageApplication!=null && pageApplication.size()>0){
            ApplicationFormCtrl obj = new ApplicationFormCtrl(pageApplication[0].Id, programTransactionId, language);
            jsonData = obj.getApplicationJSON();
        }
        
        System.debug('========== Debug Old Org ============> '+jsonData);
        
        return jsonData;
    }
    
    // This method will fetch all the program application metadata and create a JSON structure
    @AuraEnabled 
    public static ApplicationInfo getDynamicApplicationMetadata1(String applicationType, String selectedProgramId, String userId, Id programTransactionId, string language) {
        
        List<User> userDetails = [SELECT Id, ContactId, AccountId FROM User WHERE Id=: userId];
        String applicationName = applicationType;//'Licensing - New Application - CC Center - Corporation';
        //String applicationName = 'Licensing - New Application - Day Camp - Individual Ownership';
        //String applicationPageId='a2B6w000000GvLgEAK';
        ApplicationInfo jsonData;
        
        if(userDetails != null && userDetails.size()>0) {
            
            List<Account> userAccountDetails = [SELECT Id, Ownership, Provider_Type__c FROM Account WHERE Id=: userDetails[0].AccountId];
            
            if(userAccountDetails!=null && userAccountDetails.size()>0){
                
                if(userAccountDetails[0].Provider_Type__c !=null){
                    applicationName = applicationName +' - ' + userAccountDetails[0].Provider_Type__c; 
                }
                
                if(userAccountDetails[0].Ownership !=null){
                    applicationName = applicationName +' - '+ userAccountDetails[0].Ownership;
                }
            }
        }
        
        List<PGFPage__c> pageApplication = [SELECT Id FROM PGFPage__c WHERE Name=: applicationName];
        
        System.debug('========== applicationName ============> '+applicationName);
        
        if(pageApplication!=null && pageApplication.size()>0){
            ApplicationFormCtrl obj = new ApplicationFormCtrl(pageApplication[0].Id, programTransactionId, language);
            jsonData = obj.getApplicationInfo();
        }
        
        System.debug('========== Debug Old Org ============> '+jsonData);
        
        return jsonData;
    }
    
    
    //Save the JSON data
    @AuraEnabled
    public static List<String> saveDynamicApplicationData(String jsonData, String programApplicationId, String applicationStatus) {
         List<String> returnData = new List<String>();
        try{
        System.debug(jsonData);
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        String transactionRecordTypeName = (String)root.get('TransactionRecordType');
        String programRecordTypeName = (String)root.get('ProgramRecordType');
        
        List<Object> sections = (List<Object>)root.get('Sections');
        CLQ_Program__c programData = new CLQ_Program__c(); 
        CLQ_Program_Transaction__c programApplicationData = new CLQ_Program_Transaction__c(); 
        Map<String, Object> accountMap = new Map<String, Object>();
        Map<String, Object> programMap = new Map<String, Object>();
        Map<String, Object> programApplicationMap = new Map<String, Object>();
        Map<String, CLQ_Application_Progress__c> mapNameAppProgress = new Map<String, CLQ_Application_Progress__c>();
        List<CLQ_Application_Progress__c> lstAppProgress = new List<CLQ_Application_Progress__c>();
        
        if(programApplicationId <> null && programApplicationId <> '') {
            //Query the Application Progress
            for(CLQ_Application_Progress__c oProgress : [SELECT Id, Name, CLQ_Status__c FROM CLQ_Application_Progress__c WHERE CLQ_Program_Application__c =: programApplicationId]) {
                mapNameAppProgress.put(oProgress.Name, oProgress);
            }   
        }
        
        //Get Sections data
        for (Object section : sections) {
            Map<String, Object> sectionMap = (Map<String, Object>)section;
            System.debug('---- Section name----> '+sectionMap.get('Label'));
            //Storing Section Values
            String status = (String)sectionMap.get('Status');
            String sSectionName = (String)sectionMap.get('Name');
            if(!mapNameAppProgress.isEmpty() && mapNameAppProgress.containsKey(sSectionName)) {
                CLQ_Application_Progress__c oExtProgress = mapNameAppProgress.get(sSectionName);
                oExtProgress.CLQ_Status__c = status;
                lstAppProgress.add(oExtProgress);
            } else {
                CLQ_Application_Progress__c oNewProgress = new CLQ_Application_Progress__c();
                oNewProgress.Name = (String)sectionMap.get('Name');
                oNewProgress.CLQ_Status__c = status;
                lstAppProgress.add(oNewProgress);
            }
            
            List<Object> subsections = (List<Object>)sectionMap.get('SubSections');
            
            for (Object subsection : subsections) {
                Map<String, Object> subsectionMap = (Map<String, Object>)subsection;
                System.debug('---- Sub-Section name----> '+subsectionMap.get('Label'));
                String subsectionType = (String)subsectionMap.get('Type');
                
                if(subsectionType == 'Fieldset'){
                    List<Object> subsectionsfields = (List<Object>)subsectionMap.get('Fields');
                    for (Object subsectionsfield : subsectionsfields) {
                        Map<String, Object> subsectionfieldMap = (Map<String, Object>)subsectionsfield;
                        System.debug('---- Sub-Section Field name----> '+subsectionfieldMap.get('Label'));
                        System.debug('---- Sub-Section Field fieldValue----> '+subsectionfieldMap.get('Value'));
                        
                        
                        String objApi = (String)subsectionfieldMap.get('ObjectApi');
                        String fieldApi = (String)subsectionfieldMap.get('FieldApi');
                        //String fieldValue = (String)subsectionfieldMap.get('Value');
                        String fieldType = (String)subsectionfieldMap.get('Type');
                        
                        
                        if(subsectionfieldMap.get('Value')!=null && subsectionfieldMap.get('Value')!='' && objApi!=''){
                            
                            if(fieldType=='Date'){
                                if(objApi=='CLQ_Program__c'){
                                    programData.put(fieldApi,date.valueOf((String)subsectionfieldMap.get('Value')));
                                    programMap.put(fieldApi,date.valueOf((String)subsectionfieldMap.get('Value')));
                                }
                                else if(objApi=='CLQ_Program_Transaction__c'){
                                    programApplicationData.put(fieldApi,date.valueOf((String)subsectionfieldMap.get('Value')));
                                    programApplicationMap.put(fieldApi,date.valueOf((String)subsectionfieldMap.get('Value')));
                                }
                            }
                            else if(fieldType=='Number'){
                                if(objApi=='CLQ_Program__c'){
                                    programData.put(fieldApi,Integer.valueOf(subsectionfieldMap.get('Value')));
                                    programMap.put(fieldApi,Integer.valueOf(subsectionfieldMap.get('Value')));
                                }
                                else if(objApi=='CLQ_Program_Transaction__c'){
                                    programApplicationData.put(fieldApi,Integer.valueOf(subsectionfieldMap.get('Value')));
                                    programApplicationMap.put(fieldApi,Integer.valueOf(subsectionfieldMap.get('Value')));
                                }
                            }
                            else if(fieldType=='Multi-Select'){
                                List<String> lstOptions = new List<String>();
                                system.debug('subsectionfieldMap>>>' + subsectionfieldMap.get('Value'));
                                String options;
                                if(subsectionfieldMap.get('Value') instanceOf List<Object>){
                                    for(Object oVal : (List<Object>)subsectionfieldMap.get('Value')) {
                                        lstOptions.add((String)(oVal));
                                    }
                                    options = String.join(lstOptions, ';');
                                }else{
                                    options = String.valueOf((Object)subsectionfieldMap.get('Value'));
                                }
                                /* List<String> lstOptions = new List<String>();
for(Object oVal : (List<Object>)subsectionfieldMap.get('Value')) {
lstOptions.add((String)(oVal));
}
//String options = String.valueOf((Object)subsectionfieldMap.get('Value'));
String options = String.join(lstOptions, ';');
//options = options.Substring(1,options.length()-1);
//options = options.replaceAll(',', ';');*/
                                
                                if(objApi=='CLQ_Program__c'){
                                    programData.put(fieldApi,options);
                                    programMap.put(fieldApi,options);
                                }
                                else if(objApi=='CLQ_Program_Transaction__c'){
                                    programApplicationData.put(fieldApi,options);
                                    programApplicationMap.put(fieldApi,options);
                                }  
                            } else if(fieldType == 'Checkbox') {
                                System.debug('Actual Value --> ' + subsectionfieldMap.get('Value'));
                                if(objApi=='CLQ_Program__c'){
                                    programData.put(fieldApi,Boolean.valueOf(subsectionfieldMap.get('Value')));
                                    programMap.put(fieldApi,Boolean.valueOf(subsectionfieldMap.get('Value')));
                                }
                                else if(objApi=='CLQ_Program_Transaction__c'){
                                    programApplicationData.put(fieldApi,Boolean.valueOf(subsectionfieldMap.get('Value')));
                                    programApplicationMap.put(fieldApi,Boolean.valueOf(subsectionfieldMap.get('Value')));
                                }
                                else if(objApi=='Account'){
                                    accountMap.put(fieldApi,Boolean.valueOf(subsectionfieldMap.get('Value')));
                                }
                            }
                            else{
                                if(objApi=='CLQ_Program__c'){
                                    programData.put(fieldApi,(String)subsectionfieldMap.get('Value'));
                                    programMap.put(fieldApi,(String)subsectionfieldMap.get('Value'));
                                }
                                else if(objApi=='CLQ_Program_Transaction__c'){
                                    programApplicationData.put(fieldApi,(String)subsectionfieldMap.get('Value'));
                                    programApplicationMap.put(fieldApi,(String)subsectionfieldMap.get('Value'));
                                }
                                else if(objApi=='Account'){
                                    accountMap.put(fieldApi,(String)subsectionfieldMap.get('Value'));
                                }
                            }
                        }
                    }
                }
            }
        }
        
        User userDetails = [SELECT Id, ContactId, AccountId FROM User WHERE Id=: UserInfo.getUserId()];
        
        if(userDetails!=null){
            
            //Update Account record
            Account accoundRec = [Select Id from Account where Id=:userDetails.AccountId];
            for(String fieldName : accountMap.keySet()){
                accoundRec.put(fieldName, accountMap.get(fieldName));
            }
            update accoundRec;
            
            if(programApplicationId==''){
                //Inserting program record
                RecordType programRecordType = [SELECT Id, Name from RecordType where name =:programRecordTypeName AND SObjectType=:'CLQ_Program__c'];
                programData.put('RecordTypeId',programRecordType.Id);
                programData.put('CLQ_Associated_Organization__c',userDetails.AccountId);
                Insert programData;
                String programId = (String)programData.Id;
                
                //Inserting program application record
                RecordType transactionRecordType = [SELECT Id, Name from RecordType where name =:transactionRecordTypeName AND SObjectType=:'CLQ_Program_Transaction__c'];
                programApplicationData.put('RecordTypeId',transactionRecordType.Id);
                programApplicationData.put('CLQ_Program__c',programData.Id);
                programApplicationData.put('CLQ_Associated_Organization__c',userDetails.AccountId);
                
                Insert programApplicationData;
                programApplicationId = (String)programApplicationData.Id;
                
                returnData.add(programApplicationId);
                returnData.add(programId);
                
            }
            else {
                System.debug('--- Program Application Id --->' +programApplicationId);
                
                CLQ_Program_Transaction__c programApplicationRec = [Select Id,CLQ_Program__c from CLQ_Program_Transaction__c where Id=:programApplicationId];
                CLQ_Program__c programRec = [Select Id from CLQ_Program__c where Id=:programApplicationRec.CLQ_Program__c];
                
                for(String i : programMap.keySet()){
                    programRec.put(i, programMap.get(i));
                }
                update programRec;
                
                for(String i : programApplicationMap.keySet()){
                    programApplicationRec.put(i, programApplicationMap.get(i));
                }
                if(applicationStatus=='Submitted'){
                    programApplicationRec.put('CLQ_Transaction_Status__c','Submitted');
                    programApplicationRec.put('CLQ_Submitter__c',UserInfo.getUserId());
                    programApplicationRec.put('Submission_Date1__c',system.today());
                    programApplicationRec.put('Original_Submission_Date__c',system.today());
                    programApplicationRec.put('CLQ_Transaction_Type__c','Initial Application');
                    //programApplicationRec.put('CLQ_Transaction_Assigned_To__c','Initial Application');
                }
                update programApplicationRec;
                
                returnData.add(programApplicationId);
                returnData.add(programApplicationRec.CLQ_Program__c);
            }
            
            //Upserting Application Progress
            for(CLQ_Application_Progress__c oAppProgress: lstAppProgress) {
                oAppProgress.CLQ_Program_Application__c = programApplicationId;
            }
            upsert lstAppProgress;
        }
        }catch(DmlException e){
            //we can get from DmlException
            string msg;
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
            
        }
        return returnData;
    }
    
    @AuraEnabled
    public static void updateApplicationStatus(String recordId, String signature) {
        List<CLQ_Program_Transaction__c> lstProgramTransaction = [select id,CLQ_Transaction_Status__c from CLQ_Program_Transaction__c where id =: recordId limit 1]; 
        if(!lstProgramTransaction.isEmpty()){
            
            Blob blbSignature = EncodingUtil.base64Decode(signature);
            
            ContentVersion oCvNew = new ContentVersion();
            oCvNew.Title = 'Submitter_Signature';
            oCvNew.PathOnClient = 'Submitter_Signature' + '.png';
            oCvNew.VersionData = blbSignature;
            oCvNew.IsMajorVersion = false;
            insert oCvNew;
            ContentVersion objConVer = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :oCvNew.Id];
            Id ContentDocumentId = objConVer.ContentDocumentId;
            
            ContentDocumentLink oCDL = New ContentDocumentLink();
            oCDL.LinkedEntityId = recordId;
            oCDL.ContentDocumentId = ContentDocumentId;
            oCDL.shareType = 'I';
            insert oCDL;
            
            lstProgramTransaction[0].CLQ_Transaction_Status__c = 'Submitted';
            update lstProgramTransaction;
            
        }
    }
    
    @AuraEnabled
    public static String withdrawProgram(String recId, String withdrawReason) {
        try{
            CLQ_Program__c prgRec = new CLQ_Program__c();
            prgRec.Id = recId;
            prgRec.CLQ_Program_Status__c = 'Withdrawn';
            prgRec.CLQ_Is_Withdrawn__c = true;
            prgRec.CLQ_Withdrawal_Reason__c = withdrawReason;
            update prgRec;
        } catch(exception e) {
            return e.getMessage();
            
        }
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static list<CLQ_Transaction_Document__c> fetchuploadedtransdocs(String TransDocId) {
        
        list<CLQ_Transaction_Document__c> transDoc=[select id, Name, CLQ_Document__c, CLQ_Document_Type__c, CreatedDate, (SELECT Id, ContentDocument.Title FROM ContentDocumentLinks) from CLQ_Transaction_Document__c where CLQ_Program_Transaction__c =:TransDocID]; 
        
        return transDoc;
    }
    
    public class Program {
        public String Id {get; set;}
        public Id programTransactionId {get; set;}
        public String Name {get; set;}
        public String ProgramNumber {get; set;}
        public String ProgramStatus {get; set;}
        public String ProgramTransactionStatus {get; set;}
        public String LicenseRegistrationStatus {get; set;}
        public String LicenseType {get; set;}
        public String LicenseBeginDate {get; set;}
        public String LicenseEndDate {get; set;}
        public Boolean ActionRequired {get; set;}
        public String InspectionsURL {get; set;}
        public String ProgramIconForPortal {get; set;}
        public Boolean isWithdrawn {get; set;}
        
        public Program(CLQ_Program__c record, Id programTransactionId, string ProgramTransactionStatus ){
            this.Id = String.valueOf(record.Id);
            this.Name = record.Name;
            this.ProgramNumber = record.CLQ_Program_Number__c;
            this.ProgramStatus = record.CLQ_Program_Status__c;
            this.LicenseRegistrationStatus = record.CLQ_License_Registration_Status__c;
            this.LicenseType = record.CLQ_License_Type__c;
            this.LicenseBeginDate = record.License_Begin_Date__c;
            this.LicenseEndDate = record.License_End_Date__c;
            this.ActionRequired = false;
            this.ProgramIconForPortal = record.Program_Icon_For_Portal__c;
            this.programTransactionId = programTransactionId;
            this.isWithdrawn = record.CLQ_Is_Withdrawn__c;
            this.ProgramTransactionStatus =ProgramTransactionStatus ;
            
            System.debug(record.Name);
            if(record.Inspections__r != null && record.Inspections__r.size() > 0){
                System.debug(record.Inspections__r);
                for(CLQ_Inspection__c insp : record.Inspections__r){
                    List<CLQ_Corrective_Action_Plan__c> caps = [SELECT Id FROM CLQ_Corrective_Action_Plan__c WHERE (CLQ_CAP_Status__c = null OR CLQ_CAP_Status__c = 'Not Submitted' OR  CLQ_CAP_Status__c = 'Returned for Revision') AND CLQ_Inspection__c =:insp.Id];
                    if(caps != null && caps.size() > 0){
                        this.ActionRequired = true;
                    }
                    this.InspectionsURL = '/vdss1/s/inspection-details?inspectionId=' + insp.Id;
                    
                }
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Translate_English__mdt> Fetch_lang_metadata(string language){
        list<Translate_English__mdt> Lang_Data=[select id,Field_Api_Name__c,English__c, Label,ObjectAPIName__c,German_Translate__c,Spanish_Translate__c,Language_Selected__c, DeveloperName from Translate_English__mdt];
        if(language=='German'){
            for(Translate_English__mdt lang:Lang_Data ){
                lang.Language_Selected__c=lang.German_Translate__c;
            }
        }
        else if(language=='Spanish'){
            for(Translate_English__mdt lang:Lang_Data ){
                lang.Language_Selected__c=lang.Spanish_Translate__c;
            }
        }
        else{
            for(Translate_English__mdt lang:Lang_Data ){
                lang.Language_Selected__c=lang.English__c;
            }
        }
        
        return Lang_Data;
    }
    
    @AuraEnabled(cacheable=false)
    public static void updateLanguage(string language){
        LanguageSelected__c LangSel=[select id,Language__c from LanguageSelected__c limit 1];
        LangSel.Language__c=language;
        update LangSel;
    }
    @AuraEnabled
    public static string getSelectedLanguage(){
        LanguageSelected__c LangSel=[select id,Language__c from LanguageSelected__c limit 1];
        if(LangSel!=null){
            return LangSel.Language__c;
        }
        else{
            LanguageSelected__c LangSel1=new LanguageSelected__c();
            LangSel1.Language__c='English';
            insert LangSel1;
            return'English';
        }
    }
    
    @AuraEnabled
    public static void attachPDFtoApplication(String recordId, String pdfUrl){
        PageReference pdfPageRef;
        pdfPageRef =  new PageReference(pdfUrl);
        
        system.debug('pdfPageRef:'+pdfPageRef);
        Id appId = Id.valueOf(recordId);
        ContentVersion cont = new ContentVersion();
        
        String titlePrefix;
        String pathPrefix;
        titlePrefix = 'PortalGenerated_';
        pathPrefix = 'Portal_';
        cont.Title = titlePrefix +'pdf_form'+ '_' + String.valueOf(DateTime.now());
        cont.PathOnClient = pathPrefix+'pdf_form'+'.pdf';
        cont.VersionData = pdfPageRef.getContentAsPdf();
        cont.Origin = 'H';
        
        insert cont; 
    
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = appId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
    }
    
    
}