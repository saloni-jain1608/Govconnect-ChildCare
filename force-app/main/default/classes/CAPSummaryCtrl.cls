/**
 * @author Srikrishna Regula (sregula@deloitte.com)
 * 
 * @verison 1.0
 * 
 * Provides functionality to show / record Corrective Action Plan
 * 
 * @Change History
 * 
 * 05/04/2020 - Initial version of CAPSummaryCtrl @version 1.0
 * 
 */
public without sharing class CAPSummaryCtrl implements IRequest {
    private String jsonParam;
    
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

        if(methodName == 'getInspectionCaps'){
            response = getInspectionCaps();
        }else if(methodName == 'createCAPDocument'){
            response = createCAPDocument();
        }else if(methodName == 'getInspections'){
            response = getInspections();
        }else{
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add('Invalid method name');
        }

        return response;
    }
    
    public JsonResponse validate(String validationMethodName, Boolean jsonParam){
        return new JsonResponse();
    }

    private JsonResponse getInspections(){
        JsonResponse response = null;
        InspectionRequest request = (InspectionRequest)JSON.deserialize(this.jsonParam, InspectionRequest.class);
        User userDetails = [SELECT Id, ContactId, AccountId FROM User WHERE Id=: request.userID];
        
        List<CLQ_Inspection__c> programInspections = new List<CLQ_Inspection__c>();
        List<CLQ_Program__c> mapPrograms = [SELECT Id, Name from CLQ_Program__c WHERE CLQ_Associated_Organization__c =: userDetails.AccountId];
        Set<Id> programIds = new Set<Id>();
        for(CLQ_Program__c p : mapPrograms){
            programIds.add(p.Id);
        }
        System.debug(userDetails);
        System.debug(programIds);

        if(request.inspectionID == ''){
            programInspections = [SELECT Id, CLQ_Program__c, Name, CLQ_Program__r.Name, CLQ_Inspection_Status__c, CLQ_Visit_Status__c FROM CLQ_Inspection__c WHERE CLQ_Program__c =: programIds and CLQ_Inspection_Status__c!= 'Deleted'];
        }else{
            programInspections = [SELECT Id, CLQ_Program__c, Name, CLQ_Program__r.Name, CLQ_Inspection_Status__c, CLQ_Visit_Status__c FROM CLQ_Inspection__c WHERE Id =: request.inspectionID and CLQ_Inspection_Status__c!= 'Deleted'];
        }

        System.debug(programInspections);

        Map<Id, List<CLQ_Inspection__c>> mapInspections = new Map<Id, List<CLQ_Inspection__c>>();
        Map<Id, String> programNames = new Map<Id, String>();
        
        if(programInspections != null && programInspections.size() > 0){
            for(CLQ_Inspection__c insp : programInspections){
                if(!programNames.containsKey(insp.CLQ_Program__c)){
                    programNames.put(insp.CLQ_Program__c, insp.CLQ_Program__r.Name);
                }

                if(!mapInspections.containsKey(insp.CLQ_Program__c)){
                    mapInspections.put(insp.CLQ_Program__c, new List<CLQ_Inspection__c>());
                    mapInspections.get(insp.CLQ_Program__c).add(insp);
                }else{
                    mapInspections.get(insp.CLQ_Program__c).add(insp);
                }
            }
        }

        List<Program> programs = new List<Program>();
        for(Id pgmId : mapInspections.keySet()){
            String programName = programNames.get(pgmId);
            Program p = new Program();
            p.Name = programName;

            List<Inspection> inspections = new List<Inspection>();
            for(CLQ_Inspection__c ci : mapInspections.get(pgmId)){
                Inspection pi = new Inspection(ci);

                inspections.add(pi);
            }
            
            p.Inspections = inspections;
            programs.add(p);
        }

        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.data.put('ProgramInspections', programs);
        response.errors = new List<String>();
        return response;
    }
    
    public JsonResponse validate(String methodName, String jsonParam){
        return new JsonResponse();
    }

    private JsonResponse createCAPDocument(){
        JsonResponse response = null;
        FileRequest request = (FileRequest)JSON.deserialize(this.jsonParam, FileRequest.class);
        List<CLQ_Inspection__c> inspections = [SELECT CLQ_Program__c, CLQ_Program__r.CLQ_Associated_Organization__c FROM CLQ_Inspection__c WHERE Id=:request.inspectionId];

        if(inspections != null && inspections.size() > 0){
            CLQ_Inspection__c inspection = inspections[0];

            //ContentDocumentLink fileLink = new ContentDocumentLink();
            //fileLink.Id = request.documentId; 

            CLQ_Standard_Document__c standardDoc = new CLQ_Standard_Document__c();
            standardDoc.CLQ_Program__c = inspection.CLQ_Program__c;
            standardDoc.CLQ_Organization__c = inspection.CLQ_Program__r.CLQ_Associated_Organization__c;
            standardDoc.Name = request.fileName;
            standardDoc.CLQ_Standard_Document_Status__c = 'Submitted';

            insert standardDoc;

            CLQ_CAP_Documents__c capDocument = new CLQ_CAP_Documents__c();
            capDocument.Name = request.fileName;
            capDocument.CLQ_Corrective_Action_Plan__c = request.capId;
            capDocument.CLQ_Standard_Document__c = standardDoc.Id;

            insert capDocument;

            //fileLink.LinkedEntityId = standardDoc.Id;

            //update fileLink;
        }

        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }

    private JsonResponse getInspectionCaps(){
        JsonResponse response = null;
        List<InspectionCAP> inspectionCaps = new List<InspectionCAP>();
        List<CLQ_Corrective_Action_Plan__c> correctiveList = [Select Id, CLQ_CAP_Due_Date__c, CLQ_Status_Date__c, CLQ_CAP_Status__c,
        (SELECT Id, ContentDocument.Title FROM ContentDocumentLinks),
                              CLQ_Compliance_Summary_Rule__r.CLQ_Rule_Number__c,    
                              CLQ_Inspection__r.CLQ_Inspection_Start_Date__c, 
                              CLQ_Findings__r.CLQ_Risk_Level__c, CLQ_Findings__c,
                              CLQ_Findings__r.name , CLQ_Non_Compliance_Finding__c, 
                              CLQ_Compliance_Summary_Rule_Formula__c, 
                              CLQ_Documents_Required__c, 
                              CLQ_Findings__r.CLQ_Domain_Rule_Finding__r.CLQ_Standard_Finding__r.name 
                              from CLQ_Corrective_Action_Plan__c 
                              where CLQ_Inspection__c=: jsonParam];

        if(correctiveList != null && correctiveList.size() > 0){
            for(CLQ_Corrective_Action_Plan__c cap : correctiveList){
                InspectionCAP obj = new InspectionCAP(cap, cap.ContentDocumentLinks);
                inspectionCaps.add(obj);
            }
        }

        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.data.put('CAPS', inspectionCaps);
        response.data.put('InspectionID', jsonParam);
        response.errors = new List<String>();
        return response;
    }

    public class FileRequest {
        public String fileName {get; set;}
        public String documentId {get; set;}
        public String capId {get; set;}
        public String inspectionId {get; set;}
    }

    public class InspectionRequest {
        public String userID {get; set;}
        public String inspectionID {get; set;}
    }

    public class Program {
        public String Name {get; set;}
        public List<Inspection> Inspections {get; set;}
    }

    public class Inspection {
        public String Id {get; set;}
        public String Name {get; set;}
        public String InspectionStatus {get; set;}
        public String VisitStatus {get; set;}
        public String URL {get; set;}
        public String UrlLabel {get; set;}

        public Inspection(CLQ_Inspection__c record){
            this.Id = String.valueOf(record.Id);
            this.Name = record.Name;
            this.InspectionStatus = record.CLQ_Inspection_Status__c;
            this.VisitStatus = record.CLQ_Visit_Status__c;
            this.URL = '/vdss1/s/inspection-details?inspectionId=' + record.Id;
            this.UrlLabel = 'View Inspection';
        }
    }

    public class InspectionCAP {
        public String Id {get; set;}
        public String Title {get; set;}
        public Boolean isReadOnly {get; set;}
        public Boolean isUnderProcess {get; set;}
        public Boolean isApproved {get; set;}
        public String NonComplianceFinding {get; set;}
        public List<ContentDocumentLink> Documents {get; set;}
        
        public InspectionCAP(CLQ_Corrective_Action_Plan__c record, List<ContentDocumentLink> documents){
            this.Id = String.valueOf(record.Id);
            String riskLevel = record.CLQ_Findings__r.CLQ_Risk_Level__c != null ? record.CLQ_Findings__r.CLQ_Risk_Level__c : 'N/A';
            String capStatus = record.CLQ_CAP_Status__c != null ? record.CLQ_CAP_Status__c : 'Not Submitted';
            this.Title = String.format('Rule: {0}, Risk Level: {1}, CAP Status: {2}', New List<Object> {record.CLQ_Compliance_Summary_Rule_Formula__c, riskLevel, capStatus });
            this.NonComplianceFinding = record.CLQ_Non_Compliance_Finding__c;
            if(documents != null && documents.size() > 0){
                this.Documents = documents;
            }

            if (record.CLQ_CAP_Status__c == 'Submitted' || record.CLQ_CAP_Status__c == 'Resubmitted' ||
                record.CLQ_CAP_Status__c == 'Approved' || record.CLQ_CAP_Status__c == 'Closed - Not Addressed' ||
                record.CLQ_CAP_Status__c == 'Report Revised - Not Required' || record.CLQ_CAP_Status__c == 'Revised') {
                this.isUnderProcess = true;
                this.isReadOnly = true;
            }else{
                this.isUnderProcess = false;
                this.isReadOnly = false;
            }

            if(record.CLQ_CAP_Status__c == 'Approved'){
                this.isApproved = true;
            }else{
                this.isApproved = false;
            }
        }
    }
}