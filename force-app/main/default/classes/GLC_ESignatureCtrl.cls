public with sharing class GLC_ESignatureCtrl {
    public static final String EMPTY_STRING = '';
    public static final String I_LETTER = 'I';
    public static final String SUCCESS_STRING = 'Success';
    public static final String Representative_Signature = 'Representative_Signature';
	public static final String png = 'png'; 
    public static final String Visit_Completed = 'Visit_Completed';
    public static final String Approved = 'Approved';
    public static final String Closed =  'Closed';
    public static final String Revised = 'Revised';
    @AuraEnabled
    public static String signDocuments(String signature, String recordId, String approvedTotCapacity, String approvedTotCapacityUnderTH, String siteRepName, String siteRepEmail) {
		Map<String, String> GLCeSignature = new  Map<String, String>();
    
        for(GLC_ESignature__mdt mdt : [Select label,QualifiedApiName from GLC_ESignature__mdt]){
                GLCeSignature.put(mdt.QualifiedApiName,mdt.label);
            }
        try {
            Blob blbSignature = EncodingUtil.base64Decode(signature);
            
            ContentVersion oCvNew = new ContentVersion();
            if(GLCeSignature.size()!=0){
            oCvNew.Title = GLCeSignature.get(Representative_Signature);
            oCvNew.PathOnClient = GLCeSignature.get(Representative_Signature) + GLCeSignature.get(png);
            }
            oCvNew.VersionData = blbSignature;
            oCvNew.IsMajorVersion = false;
            List<ContentVersion> CvList = new List<ContentVersion>();
            CvList.add(oCvNew);
            if(!CvList.isEmpty()){
                insert CvList;
            } 
            ContentVersion objConVer;
            if(oCvNew.Id!=null){
                objConVer = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :oCvNew.Id];
            }
            
            Id ContentDocumentId = objConVer.ContentDocumentId;

            ContentDocumentLink oCDL = New ContentDocumentLink();
            oCDL.LinkedEntityId = recordId;
            oCDL.ContentDocumentId = ContentDocumentId;
            oCDL.shareType = I_LETTER;
            List<ContentDocumentLink> CDLList = new List<ContentDocumentLink>();
            CDLList.add(oCDL);
            if(!CDLList.isEmpty()){
                insert CDLList;
            } 
            CLQ_Inspection__c oInspection;
            if(recordId!=null){
                oInspection = [SELECT Id, CLQ_Inspection_Type__c, CLQ_Inspection_Status__c, OwnerId, CLQ_Visit_Status__c, CLQ_CAP_Generated__c, CLQ_On_Site_Representative__c, CLQ_On_Site_Representative_Present__c, CLQ_Representative_Email__c, Approved_Total_Capacity__c, Approved_Total_Capacity_Under_2_1_2__c FROM CLQ_Inspection__c WHERE Id =: recordId];
            }
            

            oInspection.CLQ_On_Site_Representative__c = siteRepName;
            oInspection.CLQ_Representative_Email__c = siteRepEmail;
            if( approvedTotCapacity!=EMPTY_STRING){
            oInspection.Approved_Total_Capacity__c = Decimal.valueOf(approvedTotCapacity);
            }
            if(approvedTotCapacityUnderTH!=EMPTY_STRING){
            oInspection.Approved_Total_Capacity_Under_2_1_2__c = Decimal.valueOf(approvedTotCapacityUnderTH);
            }
            if(GLCeSignature.size()!=0){
            oInspection.CLQ_Visit_Status__c = GLCeSignature.get(Visit_Completed);
            }
            if(GLCeSignature.size()!=0 && oInspection.CLQ_Inspection_Status__c <> GLCeSignature.get(Approved) && oInspection.CLQ_Inspection_Status__c <> GLCeSignature.get(Closed) && oInspection.CLQ_Inspection_Status__c <> GLCeSignature.get(Revised)) {
                oInspection.CLQ_CAP_Generated__c = true;
            }
            List<CLQ_Inspection__c> InspectionList = new List<CLQ_Inspection__c>();
            InspectionList.add(oInspection);
            if(!InspectionList.isEmpty()){
                update InspectionList;
            } 
        } catch(Exception oEx) {
			system.debug('Exception:'+oEx);
        }
        return SUCCESS_STRING;


    }
}