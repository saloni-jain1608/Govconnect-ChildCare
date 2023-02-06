public class ReviewPdfPageController {
    public static ApplicationInfo jsonData;
    public static ApplicationInfo root;
    public PageSection pagesection;
    public List<PageSection> sections {get;set;}
    public static list<PageSection> pageSec1=new list<PageSection>();
    public list<PageSection> pageSec {get;set;}
    public List<sObject> sobjectlist {get;set;}
    public list <ContentDocumentLink> files {set;get;}
    

    public ReviewPdfPageController(){
        PageReference pageRef = ApexPages.currentPage();
        string currentUrl = pageRef.getUrl();        
        
        string ProgramTransactionId = pageRef.getParameters().get('programTransactionId');
        files = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.Title FROM ContentDocumentLink WHERE LinkedEntityId = :ProgramTransactionId order by SystemModstamp desc limit 1];
        string ProgramId = pageRef.getParameters().get('selectedProgramId');
        system.debug('param1:'+ProgramTransactionId);
        system.debug('param2:'+ProgramId);
        jsonData=vdssCommunityProgramsMain.getDynamicApplicationMetadata1( 'Licensing - New Application',ProgramId,userinfo.getUserId(),ProgramTransactionId,'English');
        root = (ApplicationInfo)(jsonData);
        sections = root.Sections;
        for (PageSection section : sections) {
            pageSec1.add(section);
            for(PageSubSection subsec: section.SubSections){
                for(PageField field:subsec.Fields){
                    /*if(field.Type=='Lookup'){
                        if(field.Value!=null){
                            string objectName=Id.valueof(field.Value).getSObjectType().getDescribe().getName();
                            String query = 'SELECT Id, Name';
                            query += ' FROM ' + objectName + ' where Id=' + Id.valueof(field.Value);
                            system.debug('query:'+query);
                            sobject sobjectData = Database.query(query);
                            
                        }
                    }*/
                }
                if(subsec.TableInfo!=null){
                    TableRequest tr=new TableRequest();
                    tr.programID=ProgramId;
                    tr.programTransactionID=ProgramTransactionId;
                    tr.objectName=subsec.ObjectName;
                    tr.recordTypeName=subsec.RecordType;
                    tr.whereClause=subsec.WhereClause;
                    tr.tableInfo=subsec.TableInfo;
                    DynamicTableFormCtrl FormCtrl=new DynamicTableFormCtrl();
                    JsonResponse jres=new JsonResponse();
                    jres=FormCtrl.processRequest('getTableData', JSON.serialize(tr));
                    Map<string,object> jresMap=new map<string,object>();
                    jresMap=(Map<string,object>)jres.data;
                    system.debug('jresmap:'+jresMap);
                    list<sobject> tabeldata=new list<sobject>();
                    tabeldata=(list<sobject>)jresMap.get('TableData');
                    system.debug('tabledata:'+tabeldata);
                    system.debug('objectName:'+subsec.ObjectName);
                    if(!jresMap.isEmpty()){
                        sobjectlist = Database.query((string)jresMap.get('Query'));
                        subsec.lstObjs=sobjectlist;
                        system.debug('sobjectlist:'+sobjectlist);  
                        
                    }
                }
            }
        }
        pageSec=pageSec1;
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