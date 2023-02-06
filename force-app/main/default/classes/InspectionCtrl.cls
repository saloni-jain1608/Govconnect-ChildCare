/**
* @author Srikrishna Regula (sregula@deloitte.com)
* 
* @verison 1.0
* 
* Provides functionality to create Inspection
* 
* @Change History
* 
* 05/04/2020 - Initial version of InspectionCtrl @version 1.0
* 
*/
public with sharing class InspectionCtrl implements IRequest {
    public String jsonParam;
    public CLQ_Program_Transaction__c programTransactionRecord;
    public String  redirectUrl;
    public String inspectionId;
    public list<CLQ_Findings__c> listFindings;
    public list<CLQ_Findings__c> listFindingswithPoints;
    public list<CLQ_Transaction_Document__c> listTransDocument;
    public list<CLQ_Transaction_Document__c> listTransDocumentwithPoints;  
    Set<String> standardDetails = new Set<String>(); 
    
    /**
* validates the method and returns JsonResponse
* 
* @param methodName - Name of the method which contains the validation
* @param jsonParam - JSON parameter to be used.
* 
* @return JsonResponse - Returns JsonResponse object
*/
    public JsonResponse validate(String methodName, String jsonParam) {
        this.jsonParam = jsonParam;
        JsonResponse response = null;
        if(methodName == 'validateInspectionCreation'){
            try{
                response = validateInspectionCreation();
            }
            catch(Exception ex){
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(ex.getMessage());
            }
        }else if(methodName == 'validateOnSiteVisitRating'){
            response = validateOnSiteVisitRating();
        }else if(methodName == 'validateOnsiteStandardFindings'){
            response = validateOnsiteStandardFindings();
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
        
        if(methodName == 'createInspection'){
            try{
                response = createInspection();
            }
            catch(Exception ex){
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(ex.getMessage());
            }
        }else if(methodName == 'calculateOnSiteVisitRating'){
            response = calculateOnSiteVisitRating();
        }else if(methodName == 'completeTAVisit'){
            response = completeTAVisit();
        }else if(methodName == 'createFollowUpInspection'){
            response = createFollowUpInspection();
        }else if(methodName == 'reviewOnsiteStandardFindings'){
            response = reviewOnsiteStandardFindings();
        }else if(methodName == 'submitForApproval'){
            response = submitForApproval();
        }else{
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add('Invalid method name');
        }
        
        return response;
    }
    
    /**
* Validates OnSite visit Rating before computing it.
* 
*/
    public JsonResponse validateOnSiteVisitRating(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        CLQ_Inspection__c inspection = [SELECT Id, CLQ_Inspection_Status__c from CLQ_Inspection__c Where Id =: this.jsonParam];
        Boolean canSubmitForApproval = true;
        
        List<CLQ_Findings__c> findings = [SELECT Id, Points__c, Rating__c from CLQ_Findings__c where CLQ_Inspection__c =: this.jsonParam];
        List<CLQ_Rules_Inspected__c> rulesInspected = [SELECT Id, Name FROM CLQ_Rules_Inspected__c where CLQ_Inspection_No__c =: this.jsonParam];
        
        if(findings != null && rulesInspected != null && findings.size() != rulesInspected.size()){ canSubmitForApproval = false;
        }
        
        Boolean isFindingDef = false;
        if(findings != null && findings.size() > 0){
            for(CLQ_Findings__c f : findings){
                if(f.Rating__c == 'D'){ isFindingDef = true;
                }
            }
        }
        
        if(findings.size() == 0){
            response.errors.add('Please perform all Onsite Visit actions prior to calculating Onsite Visit Rating');    
            response.status = RequestStatus.ERROR;
            
            return response;
        }else{
            if(!isFindingDef){
                if(inspection.CLQ_Inspection_Status__c == 'Deferral'){
                    response.errors.add('Inspection Status is Deferral, Onsite Rating cannot be Calculated');    
                    response.status = RequestStatus.ERROR; return response;
                }else if(inspection.CLQ_Inspection_Status__c == 'Rating Assessment Complete'){
                    response.errors.add('Inspection Status is Rating Assessment Complete, Onsite Rating cannot be Re-Calculated');    
                    response.status = RequestStatus.ERROR; return response;
                }else{
                    if(!canSubmitForApproval){
                        response.errors.add('All Onsite Standard Findings must have a rating or point value before the Onsite Rating can be calculated.');    
                        response.status = RequestStatus.ERROR; return response;
                    }else{
                        response.status = RequestStatus.OK; return response;
                    }
                }
            }else{
                response.errors.add('Calculate Onsite Rating cannot be performed, one or more Findings are in Deferral status');    
                response.status = RequestStatus.ERROR; return response;
            }
        }
    }
    
    public JsonResponse completeTAVisit(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        Id profileId = UserInfo.getProfileId();
        Id userRoleId = UserInfo.getUserRoleId();
        String proname = [Select Id,Name from Profile where Id=:profileId].Name;
        String rolename = [Select Id,Name from UserRole where Id=:userRoleId].Name;
        
        
        List<CLQ_Inspection__c> inspectionRecs = [SELECT Id, Name, OwnerId, Owner.Type, CLQ_County__c,CLQ_Owner_Manager__c, Inspection_Record_Type__c,CLQ_Visit_Status__c, CLQ_Inspection_Status__c, 
                                                  CLQ_Program_Record_Type__c, CLQ_Inspection_Owner__c, CLQ_Inspection_Owner__r.Manager.IsActive, CLQ_Inspection_Type__c,CLQ_Program_Transaction__r.CLQ_Transaction_Assigned_To__c, 
                                                  CLQ_Program__r.CLQ_Licensing_Specialist__c, CLQ_Inspection__c.CLQ_Program_Transaction__c FROM CLQ_Inspection__c WHERE Id =: this.jsonParam];
        List<CLQ_Inspector__c> inspectors = [SELECT Id, Name, CLQ_Inspector_Name__c FROM CLQ_Inspector__c WHERE CLQ_Inspection__c =: this.jsonParam];
        CLQ_Inspection__c inspection = null;
        
        if(inspectionRecs != null && inspectionRecs.size() > 0){
            inspection = inspectionRecs[0];    
        }
        String InspOwnerId = inspection.OwnerId;
        Set<Id> inspectorIds = new Set<Id>();
        if(inspectors != null && inspectors.size() > 0){
            for(CLQ_Inspector__c i : inspectors){
                inspectorIds.add(i.CLQ_Inspector_Name__c);
            }
        }
        
        String progCounty = inspection.CLQ_County__c;
        String InspectionRT = inspection.Inspection_Record_Type__c;
        String sfdcAdminProfiles = Label.SFDC_Admin_Profiles;
        String NACOCcounties = Label.JFS_NACOC_Counties;
        String SCcounties = Label.JFS_SouthCentral_Counties;
        Boolean CanSubmitForApproval = false;
        String ErrMsg = 'Error - Cannot submit for approvals.';
        String strCombinedCounties = '';
        String ptCountyUC = ProgCounty.toUpperCase();
        
        if(rolename != null && rolename.toLowerCase().indexOf('county') >= 0) {
            String usrCounty = rolename.substring(0, rolename.toLowerCase().indexOf('county')).trim().toUpperCase();
            List<CLQ_Combined_Counties__mdt> records = [Select CLQ_Combined_Counties__c from CLQ_Combined_Counties__mdt where DeveloperName =:usrCounty and CLQ_Process_Combined_County__c = true];
            
            if(records != null && records.size() > 0) { strCombinedCounties = records[0].CLQ_Combined_Counties__c;
            }
        }
        
        if (string.valueOf(inspection.CLQ_Inspection_Owner__c) == '' || inspection.CLQ_Inspection_Owner__c == null)
            ErrMsg = 'Inspection Owner is not assigned - Cannot submit for approvals.';
        else if (String.isBlank(inspection.CLQ_Owner_Manager__c) || !inspection.CLQ_Inspection_Owner__r.Manager.IsActive)
            ErrMsg = 'User Manager is Missing or Inactive. Please update and submit for approvals.';
        else if (InspectionRT == 'Inspection' && (inspection.CLQ_Visit_Status__c != 'Visit Completed' || (inspection.CLQ_Inspection_Status__c != 'Pending Processing' && inspection.CLQ_Inspection_Status__c != 'Returned to Reviewer') || inspection.CLQ_Inspection_Type__c != 'Technical Assistance')) {
            ErrMsg = 'Check the following Entry Criteria before approving :\r\n 1.Visit Status should be Visit Completed \r\n 2.Inspection Status should be Pending Processing or Returned to Reviewer\r\n 3.Inspection Type should be Technical Assistance';
        } else if (sfdcAdminProfiles.indexOf(proname) != -1){
            CanSubmitForApproval = true;
        }
        else if (rolename == '' || rolename == null)
            ErrMsg = 'You do not have a Role - Cannot submit for approvals. Please contact OCLQS Help Desk.';
        else if ((strCombinedCounties.length() == 0 || strCombinedCounties.indexOf(ptCountyUC) < 0) && rolename != null && rolename.contains('county') && !rolename.contains(inspection.CLQ_County__c)) {
            ErrMsg = Label.Approval_Submit_Error_Message;
        } else if (InspectionRT == 'Inspection' && (inspection.CLQ_Program_Record_Type__c == 'Child Care Center')) {
            
            String rolenameUC = rolename.toUpperCase();
            String usrCounty = '';
            if (rolenameUC.indexOf('COUNTY') >= 0) {
                usrCounty = rolenameUC.substring(0, rolenameUC.indexOf('COUNTY')).trim();
            }
            
            if (rolename == 'JFS State Admin' || rolename == 'JFS Supervisor' || ((rolename == 'JFS Specialist' ||
                                                                                   (usrCounty != '' && Label.SUTQ_AKRON_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_CLEVELAND_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_COLUMBUS_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_DAYTON_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_TOLEDO_District_Counties.indexOf(usrCounty) >= 0))) && (InspOwnerId.indexOf(String.valueOf(UserInfo.getUserId())) != -1 || InspectorIds.contains(String.valueOf(UserInfo.getUserId()))))
                CanSubmitForApproval = true;
            else
                ErrMsg = 'You do not have a \'JFS State Admin/Supervisor Role\' or You are not an Inspector for this Inspection - Cannot submit for approvals.';
        }
        
        if (CanSubmitForApproval) {
            inspection.CLQ_Inspection_Status__c = 'Approved';
            update inspection;
        } else {
            response.errors.add(ErrMsg);    
            response.status = RequestStatus.ERROR;
            
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse calculateOnSiteVisitRating() {
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        List<CLQ_Inspection__c> inspectionToUpdate = new List<CLQ_Inspection__c>();
        String preSchool = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByName().get('Pre School').getRecordTypeId();
        String fccTypeA  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type A Home').getRecordTypeId();
        String fccTypeB  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByName().get('FCC - Type B Home').getRecordTypeId();
        String sacc      = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByName().get('School Age Child Care').getRecordTypeId();
        String center    = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByName().get('Child Care Center').getRecordTypeId();
        
        Set<String> odeCenterSet = new Set<String>();
        odeCenterSet.add(preSchool);
        odeCenterSet.add(sacc);
        odeCenterSet.add(center);
        
        Set<String> fccTypeABSet = new Set<String>();
        fccTypeABSet.add(fccTypeB);
        fccTypeABSet.add(fccTypeA);
        
        inspectionId = this.jsonParam;
        
        CLQ_Inspection__c inspection = [SELECT Id,Name 
                                        FROM CLQ_Inspection__c PT  
                                        WHERE Id = : inspectionId
                                       ];
        
        //Extract from custom settings the Standard Findings to exclude
        List<StandardFindingstoExclude__c> sdToExclude = StandardFindingstoExclude__c.getall().values();
        if(sdToExclude != NULL){
            for(StandardFindingstoExclude__c  sd : sdToExclude){
                standardDetails.add(sd.Name);
            }
        }
        
        //Get all inspections that have no Deferral ratings in associated findings
        Map<Id,CLQ_Inspection__c> mapInspection = new Map<Id,CLQ_Inspection__c>([SELECT Id,CLQ_Program_Transaction__c,CLQ_Program__r.RecordTypeId,
                                                                                 (SELECT Id,Points__c,Rating__c 
                                                                                  FROM Findings__r 
                                                                                  WHERE Rating__c != 'D' 
                                                                                  AND Rating__c != null 
                                                                                  ORDER BY Rating__c asc) 
                                                                                 FROM CLQ_Inspection__c 
                                                                                 WHERE Id = : inspectionId
                                                                                ]);
        //Get all the findings for this inspection
        if(mapInspection.get(inspectionId).Findings__r != null){
            listFindings = mapInspection.get(inspectionId).Findings__r;
        }//end if
        
        listFindingswithPoints =  new List<CLQ_Findings__c>([SELECT Id,Points__c,Rating__c 
                                                             FROM CLQ_Findings__c 
                                                             WHERE Points__c != null 
                                                             AND CLQ_Inspection__c =: inspectionId
                                                            ]);
        
        Integer OnsiteVisitRating = 0;
        
        
        if(Integer.valueOf(listFindings.get(0).Rating__c ) == 3){
            if(listFindingswithPoints.size() >0){
                for(CLQ_Findings__c finding : listFindingswithPoints){
                    if(finding.Points__c != null){
                        OnsiteVisitRating = OnsiteVisitRating + Integer.valueOf(finding.Points__c);
                    }//end if
                }//end for loop
            }//end if
            
            System.debug('Total desk review points = '+ OnsiteVisitRating);
            if(OnsiteVisitRating >=35 && OnsiteVisitRating <= 55 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                inspection.Onsite_Rating__c = '4';
                System.debug('(Center/ODE) DomainRating expected is 4, my value is = ' + OnsiteVisitRating);
                
            }//end if 
            else if(OnsiteVisitRating > 55 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                
                inspection.Onsite_Rating__c = '5';
                System.debug('(Center/ODE) DomainRating expected is 5, my value is = ' + OnsiteVisitRating);
            }//end else if
            else if(OnsiteVisitRating >=30 && OnsiteVisitRating <= 45 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                inspection.Onsite_Rating__c = '4';
                System.debug('(FCCTypeA/B) DomainRating expected is 4, my value is = ' + OnsiteVisitRating);
                
            }//end else if
            else if(OnsiteVisitRating > 45 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                
                inspection.Onsite_Rating__c = '5';
                System.debug('(FCCTypeA/B) DomainRating expected is 5, my value is = ' + OnsiteVisitRating);
            }//end else if
            else if (OnsiteVisitRating < 30 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                inspection.Onsite_Rating__c = '3';
                System.debug('(FCCTypeA/B) DomainRating expected is 3, my value is = ' + OnsiteVisitRating); 
            }//end else if
            
            else if (OnsiteVisitRating < 35 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId))){
                inspection.Onsite_Rating__c = '3';
                System.debug('(Center/ODE) DomainRating expected is 3, my value is = ' + OnsiteVisitRating);
                
            }//end else if
        }//end if
        
        else{
            //Only set the OnsiteVisitRating value to the Findings value if it doensn't have a value of 'D'
            if(listFindings.get(0).Rating__c != 'D'){
                OnsiteVisitRating = Integer.valueOf(listFindings.get(0).Rating__c );
                inspection.Onsite_Rating__c = String.valueOf(OnsiteVisitRating);
                System.debug('(Inside else block) Rating = ' + inspection.Onsite_Rating__c );
            }//end if
        }//end else
        
        inspectionToUpdate.add(inspection);
        if(inspectionToUpdate != null && inspectionToUpdate.size() > 0){
            update inspectionToUpdate;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse createFollowUpInspection(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        CLQ_Inspection__c inspection = [SELECT Id, Name, CLQ_ProgramId__c, CLQ_Street_Address_1_at_Site__c, CLQ_Street_Address_2_at_Site__c, CLQ_City_at_Site__c, 
                                        CLQ_County_at_Site__c, CLQ_State_at_Site__c, CLQ_Zip_Code_at_Site__c FROM CLQ_Inspection__c  
                                        WHERE Id =: this.jsonParam
                                       ];
        
        List<CLQ_Rules_Inspected__c> rulesInspected = [SELECT Id,CLQ_Inspection_No__c,CLQ_Rule__c, CLQ_Result__c from CLQ_Rules_Inspected__c where CLQ_Inspection_No__c =:inspection.Id AND CLQ_Result__c = 'Non-Compliant'];
        
        if(rulesInspected != null && rulesInspected.size() > 0){
            CLQ_Inspection__c insp = new CLQ_Inspection__c();
            insp.CLQ_Inspection_Type__c = 'Follow-up';
            insp.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            insp.CLQ_Visit_Status__c = 'To be Scheduled';
            insp.CLQ_Program__c = inspection.CLQ_ProgramId__c;
            insp.CLQ_Original_Inspection__c=inspection.Id;
            insp.CLQ_Scope__c ='Full';
            insp.CLQ_Inspection_Status__c = 'Pending Processing';
            
            insp.CLQ_Street_Address_1_at_Site__c = inspection.CLQ_Street_Address_1_at_Site__c;
            insp.CLQ_Street_Address_2_at_Site__c = inspection.CLQ_Street_Address_2_at_Site__c;
            insp.CLQ_City_at_Site__c = inspection.CLQ_City_at_Site__c;
            insp.CLQ_County_at_Site__c = inspection.CLQ_County_at_Site__c;
            insp.CLQ_State_at_Site__c = inspection.CLQ_State_at_Site__c;
            insp.CLQ_Zip_Code_at_Site__c = inspection.CLQ_Zip_Code_at_Site__c;
            
            insert insp;
        }else{
            response.status = RequestStatus.ERROR;
            response.errors.add('Cannot create a Follow-up as there are no \'Non-Compliant\' Rules for this Visit');
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse deleteInspection(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse validateOnsiteStandardFindings(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        CLQ_Inspection__c inspection = [SELECT Id, Name, CLQ_Program_Transaction__c, CLQ_Use_Rules_Effective_On__c FROM CLQ_Inspection__c  
                                        WHERE Id =: this.jsonParam
                                       ];
        
        List<CLQ_Findings__c> findings = [SELECT Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:inspection.CLQ_Program_Transaction__c];
        
        if(inspection.CLQ_Use_Rules_Effective_On__c == null){
            response.status = RequestStatus.ERROR;
            response.errors.add('You can not set Onsite Standard Findings without Rules Effective On');
            return response;
        }else if(findings.size() == 0){
            response.status = RequestStatus.ERROR;
            response.errors.add('Desk Review Findings need to be created prior to creating Onsite Findings');
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse reviewOnsiteStandardFindings(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    public JsonResponse submitForApproval(){
        JsonResponse response = new JsonResponse();
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        
        Date todaysDate = System.today();
        //16011
        Date nextMonthDate = todaysDate.addMonths(1);
        Id profileId = UserInfo.getProfileId();
        Id userRoleId = UserInfo.getUserRoleId();
        String proname = [Select Id,Name from Profile where Id=:profileId].Name;
        String rolename = [Select Id,Name from UserRole where Id=:userRoleId].Name;
        CLQ_Inspection__c inspection = [SELECT Id,CLQ_Program_Status__c,CLQ_Program_Record_Type__c, Name,CLQ_Total_Enrollment__c, OwnerId, Owner.Type,Inspection_Record_Type__c,CLQ_Owner_Manager__c, CLQ_Visit_Status__c,CLQ_County__c, CLQ_Inspection_Status__c, CLQ_Inspection_Owner__r.Manager.IsActive, CLQ_Inspection_Type__c,CLQ_Program_Transaction__r.CLQ_Transaction_Assigned_To__c, CLQ_Program__r.CLQ_Licensing_Specialist__c, CLQ_Inspection__c.CLQ_Program_Transaction__c,CLQ_Inspection_Owner__r.ManagerId,Onsite_Rating__c,X2star_re_reg_field__c FROM CLQ_Inspection__c WHERE Id =:this.jsonParam];
        String inspOwnerId = inspection.OwnerId;
        List<CLQ_Inspector__c> inspectors = [SELECT Id, Name, CLQ_Inspector_Name__c FROM CLQ_Inspector__c WHERE CLQ_Inspection__c =: this.jsonParam];
        List<CLQ_Enrollment_Group__c> enrollmentGroups = [SELECT Id, Name FROM CLQ_Enrollment_Group__c WHERE CLQ_Inspection__c =: this.jsonParam];
        
        Set<Id> inspectorIds = new Set<Id>();
        if (inspectors != null && inspectors.size() > 0) {
            for (CLQ_Inspector__c i : inspectors) {
                inspectorIds.add(i.CLQ_Inspector_Name__c);
            }
        }
        Boolean bypassval = false;
        Boolean CanSubmitForApproval = false;
        String errMsg = 'Error - Cannot submit for approvals.';
        String progCounty = inspection.CLQ_County__c;
        String inspectionRT = inspection.Inspection_Record_Type__c;
        String sfdcAdminProfiles = Label.SFDC_Admin_Profiles;
        String NACOCcounties = Label.JFS_NACOC_Counties;
        String SCcounties = Label.JFS_SouthCentral_Counties;
        
        String strCombinedCounties = '';
        String ptCountyUC = progCounty.toUpperCase();
        if (rolename != null && rolename.toLowerCase().indexOf('county') >= 0) {
            String usrCounty = rolename.substring(0, rolename.toLowerCase().indexOf('county')).trim().toUpperCase();
            List<CLQ_Combined_Counties__mdt> combinedCountyRec = [SELECT CLQ_Combined_Counties__c from CLQ_Combined_Counties__mdt where DeveloperName =:usrCounty and CLQ_Process_Combined_County__c = true];
            if (combinedCountyRec.size() > 0) { strCombinedCounties = combinedCountyRec[0].CLQ_Combined_Counties__c;}
        }
        
        //To check Approved Capacities on PT
        system.debug('inspection.CLQ_Program_Transaction__c'+inspection.CLQ_Program_Transaction__c);
        system.debug('inspectionRT'+inspectionRT);
        if (String.ValueOf(inspection.CLQ_Program_Transaction__c) != '' && inspectionRT == 'Inspection') {
            List<CLQ_Program_Transaction__c> programTransactions = [SELECT name,id,recordtypeid,CLQ_Approved_Total_Capacity__c,CLQ_Approved_Capacity_Under_2_1_2__c,CLQ_Approved_Capacity_Under_2__c,CLQ_New_Approved_All_Groups_Capacity__c,CLQ_New_Approved_Under_2_Capacity__c,CLQ_New_Approved_Capacity_Under_2_1_2__c from CLQ_Program_Transaction__c where id=:inspection.CLQ_Program_Transaction__c];
            String rtype = [SELECT Name,Id from recordtype where Id=:programTransactions[0].RecordTypeId].Name;
        
            if (inspection.CLQ_Inspection_Status__c == 'Pending Processing' && (rtype == 'Amendment - Center - Change of Location' || rtype == 'Amendment - ODE - Change of Location') && ((programTransactions[0].CLQ_Approved_Total_Capacity__c != null && programTransactions[0].CLQ_Approved_Total_Capacity__c != 0) || (programTransactions[0].CLQ_Approved_Capacity_Under_2_1_2__c != null && programTransactions[0].CLQ_Approved_Capacity_Under_2_1_2__c != 0))) {
                bypassval = true;
            }
            if (inspection.CLQ_Inspection_Status__c == 'Pending Processing' && (rtype == 'Amendment - FCC - Change of Location') && ((programTransactions[0].CLQ_Approved_Total_Capacity__c != null && programTransactions[0].CLQ_Approved_Total_Capacity__c != 0) || (programTransactions[0].CLQ_Approved_Capacity_Under_2__c != null && programTransactions[0].CLQ_Approved_Capacity_Under_2__c != 0))) {
                bypassval = true;
            }
        
            if (inspection.CLQ_Inspection_Status__c == 'Pending Processing' && (rtype == 'Amendment- FCC - Change of Capacity / Space') && ((programTransactions[0].CLQ_New_Approved_All_Groups_Capacity__c != null && programTransactions[0].CLQ_New_Approved_All_Groups_Capacity__c != 0) || (programTransactions[0].CLQ_New_Approved_Under_2_Capacity__c != null && programTransactions[0].CLQ_New_Approved_Under_2_Capacity__c != 0))) {
                bypassval = true;
            }
            if (inspection.CLQ_Inspection_Status__c == 'Pending Processing' && (rtype == 'Amendment - ODE and Center - Change of Capacity / Space') && ((programTransactions[0].CLQ_New_Approved_All_Groups_Capacity__c != null && programTransactions[0].CLQ_New_Approved_All_Groups_Capacity__c != 0) || (programTransactions[0].CLQ_New_Approved_Capacity_Under_2_1_2__c != null && programTransactions[0].CLQ_New_Approved_Capacity_Under_2_1_2__c != 0))) {
                bypassval = true;
            }
        }
        
        if (string.valueOf(inspection.CLQ_Inspection_Owner__c) == '' || inspection.CLQ_Inspection_Owner__c == null)
            ErrMsg = 'Inspection Owner is not assigned - Cannot submit for approvals.';
        else if (String.isBlank(inspection.CLQ_Owner_Manager__c) || !inspection.CLQ_Inspection_Owner__r.Manager.IsActive)
            ErrMsg = 'User Manager is Missing or Inactive. Please update and submit for approvals.';
        else if ((inspection.Onsite_Rating__c == '2') && (System.today() < inspection.X2star_re_reg_field__c)) {
        
            ErrMsg = 'Onsite rating is 2 and current date falls before the 2 star re-register date';
        }
        // 15275 - Adding valdiation to check if Total Enrollment is zero
        else if ((enrollmentGroups == null || enrollmentGroups.size() == 0)  && inspection.CLQ_Total_Enrollment__c == 0 && (inspection.CLQ_Inspection_Type__c == 'Annual' || inspection.CLQ_Inspection_Type__c == 'Provisional' || inspection.CLQ_Inspection_Type__c == 'Compliance' || inspection.CLQ_Inspection_Type__c == 'Follow-up'))
            ErrMsg = Label.Cannot_Submit_Inspection_with_Total_Enrollment_NULL;
        else if (inspectionRT == 'Onsite Visit Record Type' && (inspection.CLQ_Inspection_Status__c == 'Rating Assessment Complete')) {
            ErrMsg = 'Cannot submit inspection that is already in Rating Assessment Complete Status';
        }
        else if (bypassval)
            ErrMsg = 'The Approved Capacity values on the Program Transaction need to be Blank or Zero.';
        else if (sfdcAdminProfiles.indexOf(proname) != -1)
            CanSubmitForApproval = true;
        else if (rolename == '' || rolename == null)
            ErrMsg = 'You do not have a Role - Cannot submit for approvals. Please contact OCLQS Help Desk.';
        //Inspection - CCC Programs
        //Onsite - CCC/FCCC Programs
        else if ((inspectionRT == 'Inspection' && (inspection.CLQ_Program_Record_Type__c == 'Child Care Center' || inspection.CLQ_Program_Record_Type__c == 'Day Camp')) || (InspectionRT == 'Onsite Visit Record Type' && (inspection.CLQ_Program_Record_Type__c == 'Child Care Center' || inspection.CLQ_Program_Record_Type__c == 'FCC - Type A Home' || inspection.CLQ_Program_Record_Type__c == 'FCC - Type B Home'))) {
            String rolenameUC = rolename.toUpperCase();
            String usrCounty = '';
            if (rolenameUC.indexOf('COUNTY') >= 0) {
                usrCounty = rolenameUC.substring(0, rolenameUC.indexOf('COUNTY')).trim();
            }
        
            if (rolename == 'JFS State Admin' || rolename == 'JFS Supervisor' || rolenameUC.indexOf('NOCAC') == -1 || rolenameUC.indexOf('SOUTH CENTRAL') == -1 || ((rolename == 'JFS Specialist' || (usrCounty != '' && (Label.SUTQ_AKRON_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_CLEVELAND_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_COLUMBUS_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_DAYTON_District_Counties.indexOf(usrCounty) >= 0 || Label.SUTQ_TOLEDO_District_Counties.indexOf(usrCounty) >= 0))) && (inspOwnerId.indexOf(UserInfo.getUserId()) != -1 || inspectorIds.contains(UserInfo.getUserId()))))
                CanSubmitForApproval = true;
            else
                ErrMsg = 'You do not have a \'JFS State Admin/Supervisor Role\' or You are not an Inspector for this Inspection - Cannot submit for approvals.';
        }
        //Inspection and Onsite - ODE Programs
        else if (inspection.CLQ_Program_Record_Type__c == 'Pre School' || inspection.CLQ_Program_Record_Type__c == 'School Age Child Care') {
            if (rolename == 'ODE State Admin' || rolename == 'ODE Supervisor' || (rolename == 'ODE Specialist' && (inspOwnerId.indexOf(UserInfo.getUserId()) != -1 || inspectorIds.contains(UserInfo.getUserId()))))
                CanSubmitForApproval = true;
            else
                ErrMsg = 'You do not have a \'ODE State Admin/Supervisor Role\' or You are not an Inspector for this Inspection - Cannot submit for approvals.';
        }
        //Inspection - FCC Programs
        else if (inspectionRT == 'Inspection' && (inspection.CLQ_Program_Record_Type__c == 'FCC - Type A Home' || inspection.CLQ_Program_Record_Type__c == 'FCC - Type B Home')) {
            if (ProgCounty != '' && ProgCounty != null) {
                String rolenameLC = rolename.toLowerCase();
                String ProgCountyLC = ProgCounty.toLowerCase();
                //NACOC Roles
                if ((NACOCcounties.indexOf(ProgCounty) != -1) && (rolenameLC.indexOf(ProgCountyLC) != -1 || rolename.indexOf('NOCAC') != -1) && (rolename.indexOf('Approver') != -1 || (rolename.indexOf('Reviewer') != -1 && (inspOwnerId.indexOf(UserInfo.getUserId()) != -1 || inspectorIds.contains(UserInfo.getUserId())))))
                    CanSubmitForApproval = true;
                //South Central Roles
                else if ((SCcounties.indexOf(ProgCounty) != -1) && (rolenameLC.indexOf(ProgCountyLC) != -1 || rolename.indexOf('South Central') != -1) && (rolename.indexOf('Approver') != -1 || (rolename.indexOf('Reviewer') != -1 && (inspOwnerId.indexOf(UserInfo.getUserId()) != -1 || inspectorIds.contains(UserInfo.getUserId())))))
                    CanSubmitForApproval = true;
                else if (strCombinedCounties.indexOf(ptCountyUC) != -1)
                    CanSubmitForApproval = true;
                else if (rolenameLC.indexOf(ProgCountyLC) != -1 && (rolename.indexOf('Approver') != -1 || rolename.indexOf('Admin') != -1 || (rolename.indexOf('Reviewer') != -1 && (InspOwnerId.indexOf(UserInfo.getUserId()) != -1 || InspectorIds.contains(UserInfo.getUserId())))))
                    CanSubmitForApproval = true;
                else
                    ErrMsg = 'You do not have a ' + ProgCounty + ' County Approver Role or You are not an Inspector for this Inspection - Cannot submit for approvals.';
            } else
                ErrMsg = 'County is blank for this FCC program - Cannot submit for approvals.';
        }
        
        
        //Adding validation for 14973 for allowing only Open, Inactive and Enforcement Programs to submit the onsite Inspections for Approval
        if (InspectionRT == 'Onsite Visit Record Type' && (inspection.CLQ_Program_Status__c != 'Open' && inspection.CLQ_Program_Status__c != 'Enforcement' && inspection.CLQ_Program_Status__c != 'Inactive')) {
            ErrMsg = 'Onsite visit can be submitted for approval only if the Program is Open, Inactive or Enforcement';
            CanSubmitForApproval = false;
        }
        
        //To check for all findings being rated 14778
        if (String.ValueOf(inspection.CLQ_Program_Transaction__c) != '' && InspectionRT == 'Onsite Visit Record Type') {
            List<CLQ_Rules_Inspected__c> rulesInspected =[SELECT Id, Name FROM CLQ_Rules_Inspected__c where CLQ_Inspection_No__c =:inspection.Id];
            List<CLQ_Findings__c> findings = [SELECT Id,Points__c,Rating__c from CLQ_Findings__c where CLQ_Inspection__c =:inspection.Id];
            Integer sizeRL = rulesInspected.size();
            Integer sizeFL = findings.size();
        
            if (sizeRL != sizeFL) {
                ErrMsg = 'All Onsite Standard Findings must have a rating or point value before the visit can be submitted for approval.';
                CanSubmitForApproval = false;
            }
        }
        
        if(CanSubmitForApproval){
            //Invoke approval process
            // Create an approval request for the account
            try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting inspection for approval.');
            req1.setObjectId(inspection.Id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(UserInfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            //Create a task
            Integer noOfDays = 7;
            Date activityDate = todaysDate.addDays(noOfDays);
            Task tsk = new Task();
            tsk.Subject = 'Approve Inspection: ' + inspection.CLQ_Inspection_Type__c + ' - ' + inspection.Name;
            //alert('the value is'+InspectionRecs[0].CLQ_Inspection_Owner__r.ManagerId);
            tsk.OwnerId = inspection.CLQ_Inspection_Owner__r.ManagerId;
            tsk.WhatId = inspection.Id;
            tsk.ActivityDate = activityDate;
            tsk.Priority = 'Normal';
            tsk.Status = 'Open';
            
            insert tsk;
            }
            catch(Exception ex){
                
            }
        }else{
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ErrMsg);
            
            return response;
        }
        
        response.status = RequestStatus.OK;
        return response;
    }
    
    /**
* Creates a inspection based on the Program Transaction
* 
* 
*/
    public JsonResponse validateInspectionCreation() {
        String programTransactionId = this.jsonParam;
        JsonResponse response = new JsonResponse();
        
        Id currUserId = UserInfo.getUserId();
        User oUsr = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: currUserId];
        
        String proname = oUsr.Profile.Name;
        String rolename = oUsr.UserRole.Name;
        String countyFormula = '';
        Boolean createInspection = false;
        String errMsg = 'Error: System cannot create a new Inspection.';
        String JFSsfdcRoles = Label.JFS_SFDC_Roles;
        String ODEsfdcRoles = Label.ODE_SFDC_Roles;
        String sfdcAdminProfiles = Label.SFDC_Admin_Profiles;
        String NACOCcounties = Label.JFS_NACOC_Counties;
        String SCcounties = Label.JFS_SouthCentral_Counties;
        
        CLQ_Program_Transaction__c oProgTransaction = [SELECT Id, CLQ_Transaction_Status__c, CLQ_Program_Type_Formula__c, clq_recordtypename__c, CLQ_Transaction_Assigned_To__c, CLQ_Program_Record_Type__c, CLQ_ProgTrans_County__c, CLQ_New_County__c, CLQ_County__c FROM CLQ_Program_Transaction__c WHERE Id =: programTransactionId];
        
        if (oProgTransaction.CLQ_Transaction_Assigned_To__c == null) {
            errMsg = 'Licensing Reviewer is not assigned - System cannot create a new Inspection.';
        } else if (sfdcAdminProfiles.indexOf(proname) != -1) {
            createInspection = true;
        } else if (rolename == '' || rolename == null) {
            errMsg = 'You do not have a Role - System cannot create a new Inspection. Please contact OCLQS Help Desk.';
        } else if (oProgTransaction.CLQ_Program_Type_Formula__c == 'Child Care Center' || oProgTransaction.CLQ_Program_Type_Formula__c == 'Day Camp') {
            if (JFSsfdcRoles.indexOf(rolename) != -1) {
                createInspection = true;
            } else {
                errMsg = 'You do not have a JFS Role - System cannot create a new Inspection for this Child Care Center program.';
            }
        } else if (oProgTransaction.CLQ_Program_Type_Formula__c == 'Pre School' || oProgTransaction.CLQ_Program_Type_Formula__c == 'School Age Child Care') {
            if (ODEsfdcRoles.indexOf(rolename) != -1) {
                createInspection = true;
            } else {
                errMsg = 'You do not have a \'ODE Role\' - System cannot create a new Inspection for this ODE program.';
            }
        } else if (oProgTransaction.CLQ_Program_Type_Formula__c == 'FCC - Type A Home' || oProgTransaction.CLQ_Program_Type_Formula__c == 'FCC - Type B Home') {
            String rolenameLC = rolename.toLowerCase();
            String strCombinedCounties = '';
            
            if (rolenameLC.indexOf('county') >= 0) {
                List<CLQ_Combined_Counties__mdt> records = new List<CLQ_Combined_Counties__mdt>();
                String usrCounty = rolenameLC.substring(0, rolenameLC.indexOf('county')).trim().toUpperCase();
                records = [SELECT CLQ_Combined_Counties__c FROM CLQ_Combined_Counties__mdt WHERE DeveloperName =: usrCounty AND CLQ_Process_Combined_County__c = true];
                
                if (records.size() > 0) {
                    strCombinedCounties = records[0].CLQ_Combined_Counties__c;
                }
            }
            
            if (oProgTransaction.clq_recordtypename__c == 'Application - FCC') { CountyFormula = oProgTransaction.CLQ_ProgTrans_County__c;}
            else if (oProgTransaction.clq_recordtypename__c == 'Amendment- FCC - Change of Capacity / Space' || oProgTransaction.clq_recordtypename__c == 'Amendment - Change of Administrator') { CountyFormula = oProgTransaction.CLQ_County__c;}
            else if (oProgTransaction.clq_recordtypename__c == 'Amendment - FCC - Change of Location') { CountyFormula = oProgTransaction.CLQ_New_County__c;}
            
            if (CountyFormula != '' && CountyFormula != null) {
                String CountyFormulaLC = CountyFormula.toLowerCase();
                String CountyFormulaUC = CountyFormula.toUpperCase();
                
                //NACOC Roles
                if ((NACOCcounties.indexOf(CountyFormula) != -1) && ((rolenameLC.indexOf(CountyFormulaLC) != -1) || (rolename.indexOf('NOCAC') != -1))) { createInspection = true; } 
                else if ((SCcounties.indexOf(CountyFormula) != -1) && ((rolenameLC.indexOf(CountyFormulaLC) != -1) || (rolename.indexOf('South Central') != -1))) { createInspection = true;} 
                else if (rolenameLC.indexOf(CountyFormulaLC) != -1) { createInspection = true;
                } else if (strCombinedCounties.indexOf(CountyFormulaUC) != -1) { createInspection = true; }
                else {
                    errMsg = 'You do not have a ' + CountyFormula + ' County Role - System cannot create a new Inspection for this FCC program.';
                }
            } else {
                errMsg = 'County is blank for this FCC program - System cannot create a new Inspection.';
            }
        }
        
        if(createInspection) {
            response.status = RequestStatus.OK;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            
        } else {
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(errMsg);
        }
        
        return response;
    }
    
    /**
* Creates a inspection based on the Program Transaction
* 
* 
*/
    public JsonResponse createInspection(){
        JsonResponse response = null;
        
        String recordId = this.jsonParam;
        
        programTransactionRecord = [SELECT Id, CLQ_Program__r.CLQ_BIRN__c,CLQ_Program__r.CLQ_Attendance_Options_Global__c,
                                    CLQ_Program__r.CLQ_Services_Offered_Global__c,CLQ_Age_Groups_Served_Global__c,CLQ_Attendance_Options_Global__c,CLQ_Services_Offered_Global__c, CLQ_Full_Part_Time_Options_Global__c, 
                                    CLQ_Program__r.RecordtypeId,CLQ_Transaction_Assigned_To__c,CLQ_Program__r.Id,RecordType.Name,CLQ_Program__r.CLQ_Age_Groups_Served_Global__c, CLQ_Provider_Agreement__c,
                                    CLQ_Program__r.CLQ_License_Type__c,CLQ_Site_IRN__c,CLQ_New_BIRN_Site_IRN__c,OEDS_Site_Status_c__c,OEDS_Location_Type_c__c,OEDS_Location_Id_c__c,
                                    CLQ_ProgTrans_Phone__c,CLQ_ProgTrans_Phone_Extension__c,CLQ_Services_Offered_Day_Camp__c,CLQ_Food_Service__c,CLQ_ProgTrans_Street_Address__c,
                                    CLQ_ProgTrans_Street_Address_2__c,CLQ_ProgTrans_City__c,CLQ_ProgTrans_County__c,CLQ_ProgTrans_State__c,CLQ_ProgTrans_Zip_Code__c,
                                    CLQ_Old_Program_Street_Address__c,CLQ_Old_Program_Street_Address_2__c,CLQ_Old_City__c,CLQ_Old_County__c,CLQ_State__c,CLQ_Old_Zip_Code__c,
                                    CLQ_Program_Street_Address_1__c,CLQ_Program_Street_Address_2__c,CLQ_City__c,CLQ_County__c,CLQ_Zip_Code__c,Program_Transaction_County__c,
                                    CLQ_New_Street_Address_1__c,CLQ_New_Street_Address_2__c,CLQ_New_City__c, CLQ_New_State__c,CLQ_New_Zip_Code__c FROM CLQ_Program_Transaction__c WHERE Id =:recordId];
        
        String recordTypeName = CLQ_Program_Transaction__c.SObjectType.getDescribe().getRecordTypeInfosById().get(programTransactionRecord.RecordTypeId).getName();
        String inspectionType = ''; //13554
        
        CLQ_Inspection__c inspectionrecord; //13554
        //1. Create inspection record for given Program Transaction
        if(recordTypeName == 'Renew Application - Day Camp'){ // 13554
            inspectionType = 'Annual';
            inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType, 'Full', 'Pending Processing');
        }else
            inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Pre-license', 'Full', 'Pending Processing');
            
            //For SUTQ Application Program Record Types
         if(recordTypeName.Contains('SUTQ')){
                inspectionrecord.CLQ_Inspection_Type__c =null;
                inspectionrecord.CLQ_Scope__c =null;
                inspectionrecord.CLQ_Inspection_Status__c='In Progress';
                inspectionrecord.RecordTypeId=Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByName().get('Onsite Visit Record Type').getRecordTypeId();
            }
        
        inspectionrecord.CLQ_Program_Transaction__c = programTransactionRecord.Id;
        inspectionrecord.CLQ_Program__c = programTransactionRecord.CLQ_Program__r.Id;
        inspectionrecord.OwnerID = UserInfo.getUserId(); //bug# 11182
        inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId(); //bug# 11182
        inspectionrecord = updateInspectionDetail(inspectionrecord, programTransactionRecord);
        
        //Updating Insp IRN from Program - 11949
        inspectionrecord.CLQ_Site_IRN__c= programTransactionRecord.CLQ_Program__r.CLQ_BIRN__c;
        inspectionrecord.CLQ_Site_Status__c= programTransactionRecord.OEDS_Site_Status_c__c;
        inspectionrecord.CLQ_Location_Type__c= programTransactionRecord.OEDS_Location_Type_c__c;
        inspectionrecord.CLQ_Location_Id__c= programTransactionRecord.OEDS_Location_Id_c__c;
        
        if(recordTypeName== 'Amendment - ODE - Change of Location' || recordTypeName== 'Amendment - FCC - Change of Location' || recordTypeName== 'Amendment - Center - Change of Location'
           || recordTypeName== 'Application - CC Center' || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program' || recordTypeName == 'Renew Application - Day Camp' ){ //13554
               inspectionrecord.CLQ_Age_Groups_Served_Global__c = programTransactionRecord.CLQ_Age_Groups_Served_Global__c; 
               inspectionrecord.CLQ_Attendance_Options_Global__c = programTransactionRecord.CLQ_Attendance_Options_Global__c;
               inspectionrecord.CLQ_Services_Offered_Global__c = programTransactionRecord.CLQ_Services_Offered_Global__c;
               inspectionrecord.CLQ_Food_Service__c = programTransactionRecord.CLQ_Food_Service__c;
               inspectionrecord.CLQ_Full_Part_Time_Options_Global__c = programTransactionRecord.CLQ_Full_Part_Time_Options_Global__c;
               inspectionrecord.CLQ_Provider_Agreement__c = programTransactionRecord.CLQ_Provider_Agreement__c;
               if(recordTypeName== 'Application - Day Camp'  || recordTypeName == 'Renew Application - Day Camp' ) //13554
               {
                   inspectionrecord.CLQ_Services_Offered_Day_Camp__c = programTransactionRecord.CLQ_Services_Offered_Day_Camp__c;
               }
           }
        
        if(recordTypeName== 'Application - CC Center'  || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program'  || recordTypeName == 'Renew Application - Day Camp'){ //13554
            inspectionrecord.CLQ_Phone__c = programTransactionRecord.CLQ_ProgTrans_Phone__c;
            inspectionrecord.CLQ_Phone_Extension__c = programTransactionRecord.CLQ_ProgTrans_Phone_Extension__c;
        }
        
        if(recordTypeName== 'Amendment - ODE - Change of Location'){ //15112
            inspectionrecord.CLQ_Site_IRN__c = programTransactionRecord.CLQ_New_BIRN_Site_IRN__c;
        }
        
        if(recordTypeName=='Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName=='Amendment- FCC - Change of Capacity / Space'){
            inspectionrecord.CLQ_Age_Groups_Served_Global__c = programTransactionRecord.CLQ_Program__r.CLQ_Age_Groups_Served_Global__c; 
            inspectionrecord.CLQ_Attendance_Options_Global__c = programTransactionRecord.CLQ_Program__r.CLQ_Attendance_Options_Global__c;
            inspectionrecord.CLQ_Services_Offered_Global__c = programTransactionRecord.CLQ_Program__r.CLQ_Services_Offered_Global__c;
            //added by Srikanth for OJLS-1222
            inspectionrecord.CLQ_Scope__c = 'Partial';
        }
        
        System.debug('Checking if inspection already exists');
        
        if(!CLQ_UtilityClass.ifInspectionAlreadyExists(programTransactionRecord.Id , true, inspectionrecord.CLQ_Inspection_Type__c)){
            insert inspectionrecord;    
        }else{
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add('The inspection is already created with inspection type '+ inspectionrecord.CLQ_Inspection_Type__c +' for this program transaction.');
            
            return response;
        } 
        //insert inspectionrecord; 
        
        System.debug('Copying Room Space Records');
        //2b Copy Room Space records
        if(recordTypeName=='Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName=='Amendment- FCC - Change of Capacity / Space'
           || recordTypeName== 'Amendment - ODE - Change of Location' || recordTypeName== 'Amendment - FCC - Change of Location' || recordTypeName== 'Amendment - Center - Change of Location'
           || recordTypeName== 'Application - CC Center'  || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program' || recordTypeName == 'Renew Application - Day Camp' ){ //13554
               list<CLQ_Room_Space_Transaction__c> roomSpaceList = new list<CLQ_Room_Space_Transaction__c>();
               map<ID,Schema.RecordTypeInfo> rt_Map = CLQ_Room_Space_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
               roomSpaceList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Room_Space_Transaction__c',' CLQ_Program_Transaction__c =\''+programTransactionRecord.id+'\'',null));
               if(roomSpaceList.size()>0){
                   list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = new list<CLQ_Room_Space_Inspection__c>();
                   for(CLQ_Room_Space_Transaction__c roomSpaceTxrecord : roomSpaceList){
                       CLQ_Room_Space_Inspection__c newrecord = (CLQ_Room_Space_Inspection__c)CLQ_UtilityClass.cloneFromOneObjectToanother(roomSpaceTxrecord,'CLQ_Room_Space_Inspection__c');
                       newrecord.CLQ_Inspection__c = inspectionrecord.id;
                       //newrecord.CLQ_Program__c = null;
                       //newrecord.CLQ_Program_Transaction__c = null;
                       Id devRecordTypeId = Schema.SObjectType.CLQ_Room_Space_Inspection__c.getRecordTypeInfosByName().get(rt_map.get(roomSpaceTxrecord.recordTypeID).getName()).getRecordTypeId();
                       newrecord.recordTypeID = devRecordTypeId;
                       roomSpaceInspectionList.add(newrecord);
                   }
                   
                   insert roomSpaceInspectionList;
               }
           }
        
        System.debug('Copying Building Approval Records');
        //2b Update all Building approvals related records
        list<CLQ_Building_Approval__c> buildingApprovallist = new list<CLQ_Building_Approval__c>();
        if(recordTypeName== 'Amendment - ODE - Change of Location' || recordTypeName== 'Amendment - FCC - Change of Location' || recordTypeName== 'Amendment - Center - Change of Location'
           || recordTypeName== 'Application - CC Center'  || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program' || recordTypeName == 'Renew Application - Day Camp' ){ //13554
               
               buildingApprovallist  =  Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Building_Approval__c', ' CLQ_Program_Transaction__c='+'\''+programTransactionRecord.id+'\'', null)); 
               
           }
        if(recordTypeName=='Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName=='Amendment- FCC - Change of Capacity / Space'){
            buildingApprovallist  =  Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Building_Approval__c', ' CLQ_Program__c='+'\''+programTransactionRecord.CLQ_Program__r.Id+'\'', null)); 
        }
        if(buildingApprovallist.size()>0){
            for(CLQ_Building_Approval__c buildingApprovalrecord : buildingApprovallist){
                buildingApprovalrecord.CLQ_Inspection__c = inspectionrecord.id;
            }
            update buildingApprovallist ;
        }
        
        System.debug('Copying Facility Schedule Records');
        //2c update all facility schedule related record
        list<CLQ_Facility_Schedule__c> facilitySchedulelist = new list<CLQ_Facility_Schedule__c>();
        if(recordTypeName== 'Amendment - ODE - Change of Location' || recordTypeName== 'Amendment - FCC - Change of Location' || recordTypeName== 'Amendment - Center - Change of Location'
           || recordTypeName== 'Application - CC Center'  || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program' || recordTypeName == 'Renew Application - Day Camp' ){ //13554 
               facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program_Transaction__c='+'\''+programTransactionRecord.id+'\'', null));
           }
        if(recordTypeName=='Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName=='Amendment- FCC - Change of Capacity / Space'){
            facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program__c='+'\''+programTransactionRecord.CLQ_Program__r.Id+'\'', null));
        }
        if(facilitySchedulelist.size()>0){
            update CLQ_UtilityClass.copyfacilityScheduletoinspection(facilitySchedulelist,inspectionrecord.id);
        }
        
        System.debug('Copying Role Related Records');
        //2d update all role related record
        list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
        if(recordTypeName=='Amendment - ODE and Center - Change of Capacity / Space' || recordTypeName=='Amendment- FCC - Change of Capacity / Space' || recordTypeName== 'Amendment - ODE - Change of Location' || recordTypeName== 'Amendment - FCC - Change of Location' || recordTypeName== 'Amendment - Center - Change of Location'
          ){
              roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', 'CLQ_Status__c = \'Active\' AND CLQ_Program__c='+'\''+programTransactionRecord.CLQ_Program__r.Id+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByName().get('Administrator').getRecordTypeId()+'\'', null));
          }
        if(recordTypeName== 'Application - CC Center'  || recordTypeName== 'Application - Day Camp' || recordTypeName== 'Application - FCC' || recordTypeName== 'Application - ODE Program' || recordTypeName == 'Renew Application - Day Camp'  ){ //13554
            roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', ' CLQ_Program_Transaction_Source__c='+'\''+programTransactionRecord.Id+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByName().get('Administrator').getRecordTypeId()+'\'', null));
        }
        if(roleList.size()>0){
            for(CLQ_Role__c roleRecord: roleList  ){
                roleRecord.CLQ_Inspection__c = inspectionrecord.id;
            }
            update roleList;
        }
        
        
        Map<String, String> mapRedirectAttributes = new Map<String, String>();
        mapRedirectAttributes.put('recordId', inspectionrecord.Id);
        mapRedirectAttributes.put('actionName', 'view');
        
        System.debug('Completed creating inspection');
        response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.data.put('successMessage', 'Inspection Created Successfully');
        response.data.put('redirect', true);
        response.data.put('redirectType', 'standard__recordPage');
        response.data.put('redirectAttributes', mapRedirectAttributes);
        
        response.errors = new List<String>();
        
        return response;
    }
    
    public CLQ_Inspection__c updateInspectionDetail(CLQ_Inspection__c inspectionrecord , CLQ_Program_Transaction__c programTransactionRecord){
        //get all Program transaction record type info
        Map<ID,Schema.RecordTypeInfo> transactionRd_Map = CLQ_Program_Transaction__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<ID,Schema.RecordTypeInfo> programRd_Map = CLQ_Program__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        if(programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid) != null && 
           (programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getName() == 'FCC - Type A Home'
            || programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getName() == 'FCC - Type B Home'
            || programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getName() == 'Child Care Center'
            || programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getName() == 'Pre School'
            //Mod by LD on 12/18/16 - Added the missing Program RecordType 'School Age Child Care'
            || programRd_Map.get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getName() == 'School Age Child Care')){
                //For new applications
                if(transactionRd_Map.get(programTransactionRecord.Recordtypeid).getName().contains('Application')){
                    inspectionrecord.CLQ_Inspection_Type__c = 'Pre-license';
                }else if(transactionRd_Map.get(programTransactionRecord.Recordtypeid).getName().contains('Amendment') 
                         && transactionRd_Map.get(programTransactionRecord.Recordtypeid).getName().contains('Change of Location')){
                             inspectionrecord.CLQ_Inspection_Type__c = 'Amendment - change of location';
                         }else if(transactionRd_Map.get(programTransactionRecord.Recordtypeid).getName().contains('Amendment') 
                                  && transactionRd_Map.get(programTransactionRecord.Recordtypeid).getName().contains('Change of Capacity / Space')){
                                      inspectionrecord.CLQ_Inspection_Type__c = 'Amendment - change of capacity';
                                  }
            }
        
        String recordTypeName = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosById().get(programTransactionRecord.CLQ_Program__r.Recordtypeid).getname();
        
        if(inspectionrecord.CLQ_Inspection_Type__c == 'Pre-license'){
            inspectionrecord.CLQ_Street_Address_1_at_Site__c = programTransactionRecord.CLQ_ProgTrans_Street_Address__c;
            inspectionrecord.CLQ_Street_Address_2_at_Site__c = programTransactionRecord.CLQ_ProgTrans_Street_Address_2__c;
            inspectionrecord.CLQ_City_at_Site__c = programTransactionRecord.CLQ_ProgTrans_City__c;
            inspectionrecord.CLQ_County_at_Site__c = programTransactionRecord.Program_Transaction_County__c;
            inspectionrecord.CLQ_State_at_Site__c = programTransactionRecord.CLQ_ProgTrans_State__c;
            inspectionrecord.CLQ_Zip_Code_at_Site__c = programTransactionRecord.CLQ_ProgTrans_Zip_Code__c;            
        }else if(inspectionrecord.CLQ_Inspection_Type__c == 'Amendment - change of location'){
            //15588 - Updated to new address instead of old address
            inspectionrecord.CLQ_Street_Address_1_at_Site__c = programTransactionRecord.CLQ_New_Street_Address_1__c;
            inspectionrecord.CLQ_Street_Address_2_at_Site__c = programTransactionRecord.CLQ_New_Street_Address_2__c;
            inspectionrecord.CLQ_City_at_Site__c = programTransactionRecord.CLQ_New_City__c;
            inspectionrecord.CLQ_County_at_Site__c = programTransactionRecord.Program_Transaction_County__c;
            inspectionrecord.CLQ_State_at_Site__c = programTransactionRecord.CLQ_New_State__c;
            inspectionrecord.CLQ_Zip_Code_at_Site__c = programTransactionRecord.CLQ_New_Zip_Code__c;                        
        }else{
            inspectionrecord.CLQ_Street_Address_1_at_Site__c = programTransactionRecord.CLQ_Program_Street_Address_1__c;
            inspectionrecord.CLQ_Street_Address_2_at_Site__c = programTransactionRecord.CLQ_Program_Street_Address_2__c;
            inspectionrecord.CLQ_City_at_Site__c = programTransactionRecord.CLQ_City__c;
            inspectionrecord.CLQ_County_at_Site__c = programTransactionRecord.CLQ_County__c;
            inspectionrecord.CLQ_State_at_Site__c = programTransactionRecord.CLQ_State__c;
            inspectionrecord.CLQ_Zip_Code_at_Site__c = programTransactionRecord.CLQ_Zip_Code__c;
        }
        //14744 - Ends
        
        return inspectionrecord;    
    }
}