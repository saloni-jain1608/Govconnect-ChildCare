public without sharing class ApplicationFormCtrl {
    public String pageID;
    public Id programTransactionId;
    public string language;

    public ApplicationFormCtrl(String pageID, Id programTransactionId, string language) {
        this.pageID = pageID;
        this.programTransactionId = programTransactionId;
        this.language=language;
    }

    public ApplicationInfo getApplicationInfo(){
        ApplicationInfo appInfo;
        List<PGFPage__c> pages = [SELECT Id, Name, PageTitle__c, PageType__c,Instructions_to_Application__c,TransactionRecordType__c,ProgramRecordType__c FROM PGFPage__c WHERE Id =: pageID];
        System.debug(pages);

        if(pages != null && pages.size() > 0){
            appInfo = new ApplicationInfo(pages[0]);
            getPageSections(appInfo);
        }

        return appInfo;
    }

    public String getApplicationJSON(){
        return JSON.serialize(getApplicationInfo());
    }

    private void getPageSections(ApplicationInfo appInfo){
        List<PGFSection__c> sections = [SELECT Id, Name, Label__c, OrderNumber__c FROM PGFSection__c WHERE Parent__c =: appInfo.Id ORDER BY OrderNumber__c];
        List<PageSection> pageSections = new  List<PageSection>();

        System.debug(sections);
        Map<String, String> mapSectionNameProgress = new Map<String, String>();
        if(programTransactionId <> null) {
            //Query the Application Progress
            for(CLQ_Application_Progress__c oProgress : [SELECT Id, Name, CLQ_Program_Application__c, CLQ_Status__c 
                                                         FROM CLQ_Application_Progress__c 
                                                         WHERE CLQ_Program_Application__c =: programTransactionId]) {

                mapSectionNameProgress.put(oProgress.Name, oProgress.CLQ_Status__c);
            }
        }

        if(sections != null && sections.size() > 0) {
            for(PGFSection__c p : sections){
                String status = 'Draft';
                if(!mapSectionNameProgress.isEmpty() && mapSectionNameProgress.containsKey(p.Name)) {
                    status = mapSectionNameProgress.get(p.Name);
                } 
                PageSection ps = new PageSection(p, status, language);
                pageSections.add(ps);
            }
        }

        appInfo.Sections = pageSections;

        getPageSubSections(pageSections);
    }

    private List<PageSubSection> getAssociatedSubSections(String sectionId, List<PageSubSection> subSections){
        List<PageSubSection> pageSubSections = new  List<PageSubSection>();

        if(subSections != null && subSections.size() > 0){
            for(PageSubSection p : subSections){
                if(p.Section == sectionId){
                    pageSubSections.add(p);
                }
            }
        }

        return pageSubSections;
    }

    private void getPageSubSections(List<PageSection> sections){
        List<PageSubSection> pageSubSections = new  List<PageSubSection>();

        Set<Id> pageSectionIds = new Set<Id>();
        if(sections != null && sections.size() > 0){
            for(PageSection p : sections){
                pageSectionIds.add(Id.valueOf(p.Id));
            }
        }

        System.debug(pageSectionIds);

        List<PGFSubSection__c> subSections = [SELECT Id, Name, Parent__c,ComponentAPIName__c, Label__c, OrderNumber__c, Type__c, IsATextBlockType__c, 
        TextBlockBody__c, ApplicableObject__c, Applicable_Field_Labels__c, ApplicableFields__c, ApplicableFormFields__c, Applicable_Form_Field_Labels__c, Applicable_Record_Type__c, 
        Transaction_Record_Type__c, Lookup_Object__c,QueryWhereClause__c FROM PGFSubSection__c WHERE Parent__c =:pageSectionIds ORDER BY OrderNumber__c];

        System.debug(subSections);

        if(subSections != null && subSections.size() > 0){
            for(PGFSubSection__c p : subSections){
                PageSubSection ps = new PageSubSection(p, language);
                pageSubSections.add(ps);
            }
        }

        if(sections != null && sections.size() > 0){
            for(PageSection p : sections){
               p.SubSections = getAssociatedSubSections(String.valueOf(p.Id), pageSubSections);
            }
        }

        getPageSubSectionFields(pageSubSections);
    }

    private List<PageField> getAssociatedFields(String subSectionId, List<PageField> pageSubSectionFields){
        List<PageField> pageFields = new  List<PageField>();

        if(pageSubSectionFields != null && pageSubSectionFields.size() > 0){
            for(PageField p : pageSubSectionFields){
                if(p.SubSection == subSectionId){
                    pageFields.add(p);
                }
            }
        }

        return pageFields;
    }

    private void getPageSubSectionFields(List<PageSubSection> subSections){
        List<PageField> pageSubSectionFields = new  List<PageField>();

        Set<Id> pageSubSectionIds = new Set<Id>();
        if(subSections != null && subSections.size() > 0){
            for(PageSubSection p : subSections){
                pageSubSectionIds.add(Id.valueOf(p.Id));
            }
        }

        System.debug(pageSubSectionIds);

        List<PGFField__c> pageFields = [SELECT Id, Name, ObjectAPIName__c, Parent__c, Label__c, OrderNumber__c, Type__c, Required__c, ReadOnly__c, Validator__c, CSSClasses__c, Pattern__c,Pattern_Mismatch_Message__c,Copy_Options__c FROM PGFField__c WHERE Parent__c =:pageSubSectionIds ORDER BY OrderNumber__c];

        System.debug(pageFields);
        Map<String, Set<String>> mapObjApiNameSetFields = new Map<String, Set<String>>();
        Map<String, SObject> mapObjApiNameSObject = new Map<String, SObject>();

        if(pageFields != null && pageFields.size() > 0){

            if(programTransactionId <> null) {
                
                CLQ_Program_Transaction__c oProgTransaction = [SELECT Id, CLQ_Program__c, CLQ_Associated_Organization__c FROM CLQ_Program_Transaction__c WHERE Id =: programTransactionId];

                for(PGFField__c p : pageFields) {
                   
                    if(mapObjApiNameSetFields.containsKey(p.ObjectAPIName__c)) {
                        Set<String> setExistingFields = new Set<String>();
                        setExistingFields = mapObjApiNameSetFields.get(p.ObjectAPIName__c);
                        setExistingFields.add(p.Name);
                        mapObjApiNameSetFields.put(p.ObjectAPIName__c, setExistingFields);
                    } else {
                        mapObjApiNameSetFields.put(p.ObjectAPIName__c, new Set<String>{p.Name});
                    }
                }

                System.debug('Combined Map --> ' + mapObjApiNameSetFields);


                //Query the fields - It can be either part of Account, Program Transaction or Program
                for(String sObjectApiName : mapObjApiNameSetFields.keySet()) {
                    
                    List<SObject> lstRecords = new List<SObject>();
                    Set<String> setFields = new Set<String>();
                    setFields = mapObjApiNameSetFields.get(sObjectApiName);
                    String sFields = String.join(new List<String>(setFields), ',');
                    System.debug('Fields --> ' + sFields);
                    System.debug('Set Fields --> ' + setFields);

                    if(sObjectApiName == 'Account') {
                        String sQuery = 'SELECT Id, ' + sFields + ' FROM Account WHERE Id = \'' + oProgTransaction.CLQ_Associated_Organization__c + '\'';
                        lstRecords = Database.query(sQuery);
                        mapObjApiNameSObject.put(sObjectApiName, lstRecords[0]);
                    } else if(sObjectApiName == 'CLQ_Program_Transaction__c') {
                        String sQuery = 'SELECT Id, ' + sFields + ' FROM CLQ_Program_Transaction__c WHERE Id = \'' + programTransactionId + '\'';
                        lstRecords = Database.query(sQuery);
                        mapObjApiNameSObject.put(sObjectApiName, lstRecords[0]);
                    } else if(sObjectApiName == 'CLQ_Program__c') {
                        String sQuery = 'SELECT Id, ' + sFields + ' FROM CLQ_Program__c WHERE Id = \'' + oProgTransaction.CLQ_Program__c + '\'';
                        lstRecords = Database.query(sQuery);
                        mapObjApiNameSObject.put(sObjectApiName, lstRecords[0]);
                    }
                }
            }

            for(PGFField__c p : pageFields) {
                String sValue = '';
                if(mapObjApiNameSObject <> null && mapObjApiNameSetFields.containsKey(p.ObjectAPIName__c)) {
                    SObject oRecord = mapObjApiNameSObject.get(p.ObjectAPIName__c);
                    if(oRecord.get(p.Name) <> null) {
                        sValue = String.valueOf(oRecord.get(p.Name));
                    }
                }
                
                PageField pf = new PageField(p, sValue, language);
                pageSubSectionFields.add(pf);
            }
        }

        if(subSections != null && subSections.size() > 0){
            for(PageSubSection p : subSections){
               p.Fields = getAssociatedFields(String.valueOf(p.Id), pageSubSectionFields);
            }
        }
    }
}