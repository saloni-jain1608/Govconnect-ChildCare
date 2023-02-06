public with sharing class ProgramActionsController implements IRequest {
    
    public String jsonParam;
    public static List<ProgramActionsController__mdt> ProgramActionsControllerlabel = [Select label from ProgramActionsController__mdt];
    public Static List<String> fieldList = new list<String>();
    public static final string ValidateInspectionCreation='validateInspectionCreation';
    public static final string ValidateTAInspectionCreation='validateTAInspectionCreation';
    public static final string ValidateNewDayCampAudit='validateNewDayCampAudit';
    public static final string ValidateUpdatePortalRating ='validateUpdatePortalRating';
    public static final string CreateInspection ='createInspection';
    public static final string CreateTAInspection ='createTAInspection';
    public static final string NewDayCampAudit ='newDayCampAudit';
    public static final string UpdatePortalRating ='updatePortalRating';
    public static final string EMPTY ='';
    public static final string Inactive ='Inactive';
    public static final string Closed_By_System ='Closed by System';
    public static final string Pending ='Pending';
    public static final string Day_Camp='Day Camp';
    public static final string Licensed='Licensed';
    public static final string Closed='Closed';
    public static final string Child_Care_Center='Child Care Center';
    public static final string Pre_School='Pre School';
    public static final string School_Age_Child_Care='School Age Child Care';
    public static final string FCC_Type_A_Home='FCC - Type A Home';
    public static final string FCC_Type_B_Home='FCC - Type B Home';
    public static final string COUNTY='county';
    public static final string NOCAC='NOCAC';
    public static final string South_Central='South Central';
    public static final string Open='Open';
    public static final string YES='Yes';
    public static final string Not_Licensed='Not Licensed';
    public static final string Enforcement='Enforcement';
    public static final string Suspended='Suspended';
    public static final string Provisional='Provisional';
    public static final string Continuous='Continuous';
    public static final string Annual='Annual';
    public static final string Invalid_method_name ='Invalid method name';
    public static final string Portal_not_rated_yet = 'Portal not rated yet';
    public static final string successMessage = 'successMessage';
    public static final string Current_Rating = 'Current Rating, Exp Date and Rating Changed Date values updated';
    public static final string Rating_effective = 'Rating effective date or Rating Discontinue date is in the future, current portal rating is not updated';   
    public static final String errorMessage = 'Day Camp Audit cannot be created if Reviewer is Null Or Program Status is Closed or Inactive';
    public static final String errorMessage3 = 'Program status not in Open, Inactive, Enforcement.';
    public static final String errorMessage4 = 'You are not allowed to create this inspection.';
    public static final string FROM_CLQ_Program = ' FROM CLQ_Program__c WHERE Id =: programRecordId';
    public static final string SELECT_Id = 'SELECT Id, ';
    public static final string RECORD_ID = 'recordId';
    public JsonResponse validate(String methodName, String jsonParam) {
        JsonResponse response = null;
        try {
            if(methodName == ValidateInspectionCreation){
                response = validateInspectionCreation(jsonParam);
            } else if(methodName == ValidateTAInspectionCreation) {
                response = validateTAInspectionCreation(jsonParam);
            } else if(methodName == ValidateNewDayCampAudit) {
                response = validateNewDayCampAudit(jsonParam);
            } else if(methodName == ValidateUpdatePortalRating) {
                response = validateUpdatePortalRating(jsonParam);
            } else {
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(Invalid_method_name);
            }
            
        } catch(Exception ex) {
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    
    public JsonResponse processRequest(String methodName, String jsonParam) {
        JsonResponse response = null;
        //this.jsonParam = jsonParam;
        
        try {
            if(methodName == CreateInspection) {
                response = createInspection(jsonParam);
            } else if(methodName == CreateTAInspection) {
                response = createTAInspection(jsonParam);
            } else if(methodName == NewDayCampAudit) {
                response = newDayCampAudit(jsonParam);
            } else if(methodName == UpdatePortalRating) {
                response = updatePortalRating(jsonParam);
            } else {
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(Invalid_method_name);
            }
        } catch(Exception ex){
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    
    public static JsonResponse validateUpdatePortalRating(String programRecordId) {
        JsonResponse response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    
    public static JsonResponse updatePortalRating(String programRecordId) {
        JsonResponse response = null;
        CLQ_Program__c oProgram;
        if(programRecordId!=null){
            oProgram = [SELECT Id, Program_Rating__c, Rating_Expiration_Date__c, Rating_Effective_Date__c, Rating_Discontinue__c FROM CLQ_Program__c WHERE Id =: programRecordId];
        }
        Boolean bError = false;
        if(oProgram.Program_Rating__c != null) {
            Integer rating = Integer.valueOf(oProgram.Program_Rating__c);
            Date rating1 = oProgram.Rating_Expiration_Date__c;
            Date rating2 = oProgram.Rating_Effective_Date__c;
            Date rating3 = oProgram.Rating_Discontinue__c;
            
            Date dt = Date.Today();
            dt.addMonths(1);
            
            Date dateToCheck;
            if (rating2 != null) {
                dateToCheck = rating2; // effective date
            } else {
                dateToCheck = null; // blanking out date to check if curr eff is null 13787
            }
            
            Date dateToCheck1;
            if (rating3 != null) {
                dateToCheck1 = rating3; // discontinue date
            }
            
            Date dateToCheck2;
            if (rating1 != null) {
                dateToCheck2 = rating1; // expiration date
            } else {
                dateToCheck2 = null;
            }
            
            response = new JsonResponse();
            if ((dateToCheck != null && dt >= dateToCheck) || (dateToCheck1 != null && dt >= dateToCheck1)) {
                
                oProgram.CLQ_Current_Rating__c = rating;
                oProgram.CLQ_Current_Rating_Expiration_Date__c = dateToCheck2;
                oProgram.Rating_Effective_Dt__c = dateToCheck; // blanking out date to check if curr eff is null 13787 //14704
                oProgram.RatingChangedDate__c = dt; //14798
                
                List<CLQ_Program__c> ProgramList = new List<CLQ_Program__c>();
                ProgramList.add(oProgram);
                if(!ProgramList.isEmpty()){
                    update ProgramList;
                }
                response.status = RequestStatus.OK;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.data.put(successMessage, Current_Rating);
            } else {
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(Rating_effective);
            }
        } else {
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(Portal_not_rated_yet);
        }
        return response;
        
    }
    
    public static JsonResponse validateNewDayCampAudit(String programRecordId) {
        JsonResponse response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    
    public static JsonResponse newDayCampAudit(String programRecordId) {
        JsonResponse response = null;
        CLQ_Program__c oProgram;
        if(programRecordId!=null){
            oProgram = [SELECT Id, CreatedDate, CLQ_Assigned_Reviewer__c, CLQ_Program_Status_Text__c, RecordTypeId FROM CLQ_Program__c WHERE Id =: programRecordId];
        }
        
        Boolean bError = false;
        String errorMessage = 'Day Camp Audit cannot be created if Reviewer is Null Or Program Status is Closed or Inactive or Program Record type is not Day Camp';
        
        if(oProgram.CreatedDate != null && oProgram.CLQ_Assigned_Reviewer__c != EMPTY && oProgram.CLQ_Program_Status_Text__c != Inactive && oProgram.CLQ_Program_Status_Text__c != Closed_By_System && oProgram.RecordTypeId ==Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Day_Camp').getRecordTypeId()) {
            oProgram.CLQ_Create_Day_Camp_Audit__c = true;
            update oProgram;
        } else {
            bError = true;
        }
        
        response = new JsonResponse();
        if(bError) {
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(errorMessage);
        } else {
            response.status = RequestStatus.OK;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add('');
        }
        return response;
    }
    
    public static JsonResponse validateTAInspectionCreation(String programRecordId) {
        JsonResponse response = null;
        if(!Schema.sObjectType.CLQ_Inspection__c.isCreateable()) {
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
        } else {
            
            Id currUserId = UserInfo.getUserId();
            User oUsr;
            if(currUserId!=null){
                oUsr = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: currUserId];
            }
            CLQ_Program__c oProgram;
            if(programRecordId!=null){
                oProgram = [SELECT Id, CLQ_County__c, CLQ_Program_Record_Type__c, CLQ_Program_Status__c FROM CLQ_Program__c WHERE Id =: programRecordId];
            }
            
            String progStatus = oProgram.CLQ_Program_Status__c;
            List<String> allowedProgStatus = new List<String>{'Open','Enforcement','Inactive'};
                String profName = oUsr.Profile.Name;
            String allowedProfiles = Label.TAAllowedProfiles;
            Boolean iscreatable = true;
            String errorMessage2 = '';
            
            if(!allowedProgStatus.contains(progStatus)) {
                iscreatable = false;
                errorMessage2 = errorMessage2 + errorMessage3;
            }
            if(allowedProfiles.indexOf(profname) == -1 ){
                iscreatable = false;
                errorMessage2 = errorMessage2+ errorMessage4;
            }
            
            if(iscreatable) {
                response.status = RequestStatus.OK;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
            } else {
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add(errorMessage);
            }
        }
        return response;
    }
    
    public static JsonResponse createTAInspection(String programRecordId) {
        JsonResponse response = null;
        fieldList=new list<string>();
        for(ProgramActionsController__mdt mdt :ProgramActionsControllerlabel){
            fieldList.add(mdt.label);
        }
        String sProgramQuery = SELECT_Id + String.join(fieldList, ',') + FROM_CLQ_Program;
        CLQ_Program__c programRecord = Database.query(sProgramQuery);
        
        String inspectionType = 'Technical Assistance';
        CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
        
        // inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType, 'Full', 'Pending Processing'); TFS#16013
        inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType, 'Partial', 'Pending Processing'); //TFS#16013
        //System.debug('inspection record--->' + inspectionrecord);
        inspectionrecord.CLQ_Food_Service__c = programRecord.CLQ_Food_Service__c ; 
        inspectionrecord.CLQ_Full_Part_Time_Options_Global__c = programRecord.CLQ_Full_Part_Time_Options_Global__c ;
        inspectionrecord.CLQ_Provider_Agreement__c = programRecord.CLQ_Provider_Agreement__c ;
        inspectionrecord.CLQ_Age_Groups_Served_Global__c = programRecord.CLQ_Age_Groups_Served_Global__c; 
        inspectionrecord.CLQ_Attendance_Options_Global__c= programRecord.CLQ_Attendance_Options_Global__c;
        inspectionrecord.CLQ_Services_Offered_Global__c = programRecord.CLQ_Services_Offered_Global__c;
        inspectionrecord.CLQ_Program__c = programRecord.id;
        inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
        if(!CLQ_UtilityClass.ifInspectionAlreadyExists(programRecord.id,false,inspectionType)){
            inspectionrecord.CLQ_Street_Address_1_at_Site__c = programRecord.CLQ_Street_Address_1__c;
            inspectionrecord.CLQ_Street_Address_2_at_Site__c = programRecord.CLQ_Street_Address_2__c;
            inspectionrecord.CLQ_City_at_Site__c = programRecord.CLQ_City__c;
            inspectionrecord.CLQ_County_at_Site__c = programRecord.Program_County__c; //RG
            inspectionrecord.CLQ_State_at_Site__c = programRecord.CLQ_State__c;
            inspectionrecord.CLQ_Zip_Code_at_Site__c = programRecord.CLQ_Zip_Code__c;
            inspectionrecord.CLQ_Program_s_Email_Address__c = programRecord.CLQ_Program_Email__c ; 
            inspectionrecord.CLQ_Phone__c= programRecord.CLQ_Phone__c ; 
            inspectionrecord.CLQ_Phone_Extension__c = programRecord.CLQ_Phone_Extension__c ;
            List<CLQ_Inspection__c> InspectionList = new List<CLQ_Inspection__c>();
            InspectionList.add(inspectionrecord);
            if(!InspectionList.isEmpty()){
                insert InspectionList;
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The inspection is already created with Inspection type '+inspectionrecord.CLQ_Inspection_Type__c+' for this program.');
            ApexPages.addMessage(myMsg);
            return null;
        }    
        
        //2a. Copy all Room/Space records to inspection
        list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
        if(programRecord.id != null){
            roomSpaceList = CLQ_UtilityClass.queryRoomSpacefromProgram(programRecord.id);
            if(roomSpaceList.size()>0){
                list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = CLQ_UtilityClass.createRoomSpaceInspection(roomSpaceList , inspectionrecord);
                if(!roomSpaceInspectionList.isEmpty()){
                    insert roomSpaceInspectionList;
                }  
            }                    
        }
        
        //2b Update all Building approvals related records
        list<CLQ_Building_Approval__c> buildingApprovallist = CLQ_UtilityClass.copyBuildingApprovaltoinspection(programRecord.id,inspectionrecord.id);
        if(!buildingApprovallist.isEmpty()){
            upsert buildingApprovallist;
            //update buildingApprovallist ;
        }
        
        //2c update all facility schedule related record
        list<CLQ_Facility_Schedule__c> facilitySchedulelist = new list<CLQ_Facility_Schedule__c>();
        facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program__c='+'\''+programRecord.id+'\'', null));
        if(!facilitySchedulelist.isEmpty()){
            update CLQ_UtilityClass.copyfacilityScheduletoinspection(facilitySchedulelist,inspectionrecord.id);
        }
        
        //2d UPdate all roles
        list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
        roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', 'CLQ_Status__c = \'Active\' AND CLQ_Program__c='+'\''+programRecord.id+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId()+'\'', null));
        if(roleList.size()>0){
            for(CLQ_Role__c roleRecord: roleList){
                roleRecord.CLQ_Inspection__c = inspectionrecord.id;
            }
            if(!roleList.isEmpty()){
                update roleList;
            }
        }
        
        //3. Insert task record //Below code commented by LD on 10/31/2016 - OJLS-876:- Task creation will be taken care in the Process Flows
        Map<String, String> mapRedirectAttributes = new Map<String, String>();
        mapRedirectAttributes.put('recordId', inspectionrecord.Id);
        mapRedirectAttributes.put('actionName', 'view');
        
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
    
    public static JsonResponse validateInspectionCreation(String programRecordId) {
        JsonResponse response = null;
        if(!Schema.sObjectType.CLQ_Inspection__c.isCreateable()) {
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
        } else {
            
            Id currUserId = UserInfo.getUserId();
            User oUsr;
            CLQ_Program__c oProgram;
            If(currUserId!=null){
                oUsr = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id =: currUserId];
            }
            if(programRecordId!=null){
                oProgram = [SELECT Id, CLQ_County__c, CLQ_Program_Record_Type__c, CLQ_License_Registration_Status__c, CLQ_Program_Status__c FROM CLQ_Program__c WHERE Id =: programRecordId];
            }
            
            String proName = oUsr.Profile.Name;
            String roleName = oUsr.UserRole.Name;
            String progCounty = oProgram.CLQ_County__c;
            
            Boolean createInspection = false;
            String errMsg = 'Error: System cannot create a new Inspection.';
            String jfsSfdcRoles = Label.JFS_SFDC_Roles;
            String odeSfdcRoles = Label.ODE_SFDC_Roles;
            String sfdcAdminProfiles = Label.SFDC_Admin_Profiles;
            String NACOCcounties = Label.JFS_NACOC_Counties;
            String SCcounties = Label.JFS_SouthCentral_Counties;
            String progRecordType = oProgram.CLQ_Program_Record_Type__c;
            
            if(oProgram.CLQ_Program_Status__c == Pending) {
                errMsg = 'Program Status is \'Pending\' - System cannot create a new Inspection.';
            } else if(ProgRecordType != Day_Camp && oProgram.CLQ_License_Registration_Status__c != Licensed && oProgram.CLQ_Program_Status__c != Closed) {
                errMsg = 'License Status is not \'Licensed\' - System cannot create a new Inspection.';
            } else if (sfdcAdminProfiles.indexOf(proName) != -1) {
                createInspection = true;
            } else if (roleName == EMPTY || roleName == null) {
                errMsg = 'You do not have a Role - System cannot create a new Inspection.';
            } else if (oProgram.CLQ_Program_Record_Type__c == Child_Care_Center || oProgram.CLQ_Program_Record_Type__c == Day_Camp) {
                system.debug('CLQ_Program_Record_Type__c:'+oProgram.CLQ_Program_Record_Type__c);
                if (JFSsfdcRoles.indexOf(rolename) != -1) {
                    CreateInspection = true;
                } else {
                    errMsg = 'You do not have a \'JFS Role\' - System cannot create a new Inspection for this Child Care Center program.';
                }
            } else if (oProgram.CLQ_Program_Record_Type__c == Pre_School || oProgram.CLQ_Program_Record_Type__c == School_Age_Child_Care) {
                system.debug('CLQ_Program_Record_Type__c:'+oProgram.CLQ_Program_Record_Type__c);
                if (ODEsfdcRoles.indexOf(rolename) != -1) {
                    CreateInspection = true;
                } else {
                    errMsg = 'You do not have a \'ODE Role\' - System cannot create a new Inspection for this ODE program.';
                }
            } else if (oProgram.CLQ_Program_Record_Type__c == FCC_Type_A_Home || oProgram.CLQ_Program_Record_Type__c == FCC_Type_B_Home) {
                
                if (progCounty != EMPTY && progCounty != null) {
                    String rolenameLC = rolename.toLowerCase();
                    String ProgCountyLC = ProgCounty.toLowerCase();
                    String ProgCountyUC = ProgCounty.toUpperCase();
                    String strCombinedCounties = '';
                    
                    
                    if (rolenameLC.indexOf(County) >= 0) {
                        String usrCounty = rolenameLC.substring(0, rolenameLC.indexOf('county')).trim().toUpperCase();
                        
                        List<CLQ_Combined_Counties__mdt> records = new List<CLQ_Combined_Counties__mdt>();
                        if(usrCounty!=null){
                            records = [SELECT CLQ_Combined_Counties__c FROM CLQ_Combined_Counties__mdt WHERE DeveloperName =: usrCounty AND CLQ_Process_Combined_County__c = true];
                        }
                        
                        
                        if (records.size() > 0) {
                            strCombinedCounties = records[0].CLQ_Combined_Counties__c;
                        }
                    }
                    
                    if ((NACOCcounties.indexOf(ProgCounty) != -1) && ((rolenameLC.indexOf(ProgCountyLC) != -1) || (rolename.indexOf(NOCAC) != -1))) {
                        createInspection = true;
                    } else if ((SCcounties.indexOf(ProgCounty) != -1) && ((rolenameLC.indexOf(ProgCountyLC) != -1) || (rolename.indexOf(South_Central) != -1))) {
                        createInspection = true;
                    } else if (rolenameLC.indexOf(ProgCountyLC) != -1) {
                        createInspection = true;
                    } else if (strCombinedCounties.indexOf(ProgCountyUC) != -1) {
                        createInspection = true;
                    } else {
                        errMsg = 'You do not have a ' + ProgCounty + ' County Role - System cannot create a new Inspection for this FCC program.';
                    }
                    
                } else {
                    errMsg = 'County is blank for this FCC program - System cannot create a new Inspection.';
                }
            } else if (oProgram.CLQ_Program_Record_Type__c == Day_Camp && (oProgram.CLQ_Program_Status__c != Open || oProgram.Approved_to_do_a_Provider_Agreement__c != YES)) {
                errMsg = 'Cannot start an Annual inspection. Please ensure the ODJFS Requirement Met is Yes and the Program Status is Open.';
            }
            
            response = new JsonResponse();
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
        }
        return response;
    }
    
    public static JsonResponse createInspection(String programRecordId) {
        JsonResponse response = new JsonResponse();
        try {
            fieldList=new list<string>();
            for(ProgramActionsController__mdt mdt :ProgramActionsControllerlabel){
                fieldList.add(mdt.label);
            }
            String sProgramQuery = SELECT_Id + String.join(fieldList, ',') + ' FROM CLQ_Program__c WHERE Id =: programRecordId';
            CLQ_Program__c programRecord = Database.query(sProgramQuery);
            
            String recordTypeName = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosById().get(programRecord.recordtypeid).getname();
            String inspectionType = '';
            
            //1. Create inspection record for given complaint
            CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
            
            //Updated for bug# 11584 & 11634 - to set Inspection Type
            //12198 addeed logic for Not Licensed+Closed Programs to be able to make Inspections
            
            if((programRecord.CLQ_License_Registration_Status__c == Licensed && programRecord.CLQ_Program_Status__c == Open) 
               ||  (programRecord.CLQ_License_Registration_Status__c == Not_Licensed && programRecord.CLQ_Program_Status__c == Closed)
               || programRecord.CLQ_Program_Status__c == Inactive || programRecord.CLQ_Program_Status__c == Enforcement || programRecord.CLQ_Program_Status__c == Suspended){//TFS#15814 added condition for suspended 
                   /*if(programRecord.CLQ_License_Type__c == 'Continuous'){
inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Annual', 'Full', 'Pending Processing'); 
}
if(programRecord.CLQ_License_Type__c == 'Provisional'){
inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Provisional', 'Full', 'Pending Processing');
}*/
                   //Set the Inspection Type
                   system.debug('CLQ_License_Registration_Status__c:'+ programRecord.CLQ_License_Registration_Status__c);
                   if(programRecord.CLQ_License_Type__c == Provisional){
                       system.debug('license type:'+ programRecord.CLQ_License_Type__c);
                       if(recordTypeName == FCC_Type_A_Home ||  recordTypeName == FCC_Type_B_Home){
                           inspectionType = 'Provisional';
                           //inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Provisional', 'Full', 'Pending Processing');
                       }
                       if(recordTypeName == Child_Care_Center ||  recordTypeName == Pre_School || recordTypeName == School_Age_Child_Care){
                           inspectionType = 'Provisional';
                           //inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Provisional', 'Full', 'Pending Processing');
                       }
                   }
                   if(programRecord.CLQ_License_Type__c == Continuous){
                       system.debug('license type:'+ programRecord.CLQ_License_Type__c);
                       if(recordTypeName == FCC_Type_A_Home ||  recordTypeName == FCC_Type_B_Home){
                           inspectionType = 'Compliance';
                           //inspectionrecord = CLQ_UtilityClass.createInspectionrecord('Compliance', 'Full', 'Pending Processing');
                       }
                       if(recordTypeName == Child_Care_Center ||  recordTypeName == Pre_School || recordTypeName == School_Age_Child_Care){
                           inspectionType = 'Annual';
                       }
                   }
                   
                   inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType, 'Full', 'Pending Processing');
               }
            
            //12167 logic for Day Camp to create inspection
            if(recordTypeName == Day_Camp){
                inspectionType = 'Annual';
                inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType, 'Full', 'Pending Processing');
            }
            
            //System.debug('inspection record--->' + inspectionrecord);
            
            inspectionrecord.CLQ_Age_Groups_Served_Global__c = programRecord.CLQ_Age_Groups_Served_Global__c; 
            inspectionrecord.CLQ_Attendance_Options_Global__c= programRecord.CLQ_Attendance_Options_Global__c;
            inspectionrecord.CLQ_Services_Offered_Global__c = programRecord.CLQ_Services_Offered_Global__c;
            inspectionrecord.CLQ_Program__c = programRecord.id;
            inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
            if(!CLQ_UtilityClass.ifInspectionAlreadyExists(programRecord.id,false,inspectionType)){
                
                //14744 - Copyting the address from the program to the new fields on inspection
                
                
                
                inspectionrecord.CLQ_Street_Address_1_at_Site__c = programRecord.CLQ_Street_Address_1__c;
                inspectionrecord.CLQ_Street_Address_2_at_Site__c = programRecord.CLQ_Street_Address_2__c;
                inspectionrecord.CLQ_City_at_Site__c = programRecord.CLQ_City__c;
                inspectionrecord.CLQ_County_at_Site__c = programRecord.Program_County__c; //RG
                inspectionrecord.CLQ_State_at_Site__c = programRecord.CLQ_State__c;
                inspectionrecord.CLQ_Zip_Code_at_Site__c = programRecord.CLQ_Zip_Code__c;
                
                //14744 - Ends
                List<CLQ_Inspection__c> InspectionList = new List<CLQ_Inspection__c>();
                InspectionList.add(inspectionrecord);
                if(!InspectionList.isEmpty()){
                    insert InspectionList;
                }
                //insert inspectionrecord;
                
            } else {
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add('The inspection is already created with Inspection type ' + inspectionrecord.CLQ_Inspection_Type__c + ' for this program.');
                return response;
            }    
            
            //2a. Copy all Room/Space records to inspection
            list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
            if(programRecord.id != null){
                roomSpaceList = CLQ_UtilityClass.queryRoomSpacefromProgram(programRecord.id);
                if(roomSpaceList.size()>0){
                    list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = CLQ_UtilityClass.createRoomSpaceInspection(roomSpaceList , inspectionrecord);
                    if(!roomSpaceInspectionList.isEmpty()){
                        insert roomSpaceInspectionList;
                    }   
                }                    
            }
            
            //2b Update all Building approvals related records
            list<CLQ_Building_Approval__c> buildingApprovallist = CLQ_UtilityClass.copyBuildingApprovaltoinspection(programRecord.id,inspectionrecord.id);
            if(!buildingApprovallist.isEmpty()){
                upsert buildingApprovallist ;
                //update buildingApprovallist ;
            }
            
            //2c update all facility schedule related record
            list<CLQ_Facility_Schedule__c> facilitySchedulelist = new list<CLQ_Facility_Schedule__c>();
            facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program__c='+'\''+programRecord.id+'\'', null));
            if(!facilitySchedulelist.isEmpty()){
                update CLQ_UtilityClass.copyfacilityScheduletoinspection(facilitySchedulelist,inspectionrecord.id);
            }
            
            //2d UPdate all roles
            list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
            roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', 'CLQ_Status__c = \'Active\' AND CLQ_Program__c='+'\''+programRecord.id+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId()+'\'', null));
            if(roleList.size()>0){
                for(CLQ_Role__c roleRecord: roleList){
                    roleRecord.CLQ_Inspection__c = inspectionrecord.id;
                }
                if(!roleList.isEmpty()){
                    update roleList;
                }
                
            }
            
            //3. Insert task record //Below code commented by LD on 10/31/2016 - OJLS-876:- Task creation will be taken care in the Process Flows
            // insert CLQ_UtilityClass.createTaskrecord(programRecord.CLQ_Licensing_Specialist__c, inspectionrecord.Id, (Date.today()).adddays(20), 'Inspection Review task', 'Inspection Review task');
            
            Map<String, String> mapRedirectAttributes = new Map<String, String>();
            mapRedirectAttributes.put(RECORD_ID, inspectionrecord.Id);
            mapRedirectAttributes.put('actionName', 'view');
            
            response.status = RequestStatus.OK;
            response.data = new Map<String, Object>();
            response.data.put('successMessage', 'Inspection Created Successfully');
            response.data.put('redirect', true);
            response.data.put('redirectType', 'standard__recordPage');
            response.data.put('redirectAttributes', mapRedirectAttributes);
            response.errors = new List<String>();
            
        } catch(Exception e) {
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(e.getMessage());
        } 
        return response;
    }
}