/**************************************************************************************************************
** Name             : CLQ_CreateInspectionExtension
** Description      : This class/extension contains all detail logic/methods for CLQ_CreateInspection pages.
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version        Description
**------------------------------------------------------------------------------------------------------------
** IncapsulateDevTeam                July-2016               1.0            Created
** Ramana Gurivelli                14June-2017               1.1            Updated to make inspection owner as current logged in user,  bug# 11182.
** Ramana Gurivelli                12July-2017               1.2            Removed with sharing,  bug# 11494.
** Rohit Gowrishetty               02/08/2019                1.3            TFS #15575 : Added logic to copy over the address onto inspection
**************************************************************************************************************/ 
public with sharing class CLQ_CreateInspectionExtension {
    //variables
    
    private CLQ_Case_Custom__c  caseRecord ;
    private String inspectionType;
    private String inspcetionscope;
    private String inspectionStatus;
    public static final string UNDER_REVIEW = 'Under Review';
    public static final string TV = 'TV';
    //constructor
    public CLQ_CreateInspectionExtension(ApexPages.StandardController controller) {
        //15575
        list<String> fieldlist;
        fieldlist = new list<String>{'CLQ_Assigned_To__c','Ownerid','CLQ_Inspection__c','CLQ_No_Investigation_Required__c','CLQ_Program__c','CLQ_Program__r.RecordType.Name','CLQ_Method_of_Investigation__c'
            ,'CLQ_Program_Street_Address1__c' , 'CLQ_Program_Street_Address2__c' , 'CLQ_Program_City__c' , 'CLQ_Program_County__c' , 'CLQ_Program_State__c' , 'CLQ_Program_Zipcode__c' }; //add fields to this list to query from database
        if(!Test.isRunningTest()){
            controller.addFields(fieldlist);
        }

        this.caseRecord = (CLQ_Case_Custom__c )controller.getRecord();
        inspectionType = apexpages.currentpage().getparameters().get('inspectionType').escapeHtml4();
        inspcetionscope = apexpages.currentpage().getparameters().get('inspcetionscope').escapeHtml4();
        inspectionStatus = apexpages.currentpage().getparameters().get('inspectionStatus').escapeHtml4(); 
        system.debug('===>'+inspectionStatus);

    }

    //Method to complete all on-load logic
    //@param : none
    //@return : pagereference
    public pagereference onLoad(){
        system.debug('===>'+Schema.sObjectType.CLQ_Inspection__c.isCreateable());
        //Check if inspection record is already associated or No investigation require is checked or not
        if(!Schema.sObjectType.CLQ_Inspection__c.isCreateable()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You have not permission to create Inspection'));
            return null;
            }
        else if(caseRecord.CLQ_No_Investigation_Required__c || caseRecord.CLQ_Inspection__c != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not create inspection for this complaint'));
            return null;
        }
        
        else{
            try{
                //1. Create inspection record for given complaint
                CLQ_Inspection__c inspectionrecord = CLQ_UtilityClass.createInspectionrecord(inspectionType , inspcetionscope , inspectionStatus);
                inspectionrecord.CLQ_Program__c = caseRecord.CLQ_Program__c;
                inspectionrecord.CLQ_Method__c = caseRecord.CLQ_Method_of_Investigation__c;
                if(inspectionrecord.CLQ_Inspection_Start_Date__c != null){
                    inspectionrecord.CLQ_Inspection_Due_Date__c = (inspectionrecord.CLQ_Inspection_Start_Date__c).adddays(20); 
                }
                inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId(); //bug# 11182
                //inspectionrecord.CLQ_Inspection_Tool__c = (CLQ_UtilityClass.retriveInspectionToolForInspection(inspectionrecord,caseRecord.CLQ_Program__r.RecordType.Name,inspectionrecord.CLQ_Scope__c,inspectionrecord.CLQ_Inspection_Type__c)).id;
                //inspectionrecord.CLQ_Recommended_Inspection_Tool__c = inspectionrecord.CLQ_Inspection_Tool__c;
                
                
                //15575 - Starts
                inspectionrecord.CLQ_Street_Address_1_at_Site__c = caseRecord.CLQ_Program_Street_Address1__c;
                inspectionrecord.CLQ_Street_Address_2_at_Site__c = caseRecord.CLQ_Program_Street_Address2__c;
                inspectionrecord.CLQ_City_at_Site__c = caseRecord.CLQ_Program_City__c;
                inspectionrecord.CLQ_County_at_Site__c = caseRecord.CLQ_Program_County__c; //RG
                inspectionrecord.CLQ_State_at_Site__c = caseRecord.CLQ_Program_State__c;
                inspectionrecord.CLQ_Zip_Code_at_Site__c = caseRecord.CLQ_Program_Zipcode__c;
                //15575 - Ends
                
                
                insert inspectionrecord;   
                
                //Get all Tool Rules related to recommanded inspection tool
                //list<CLQ_Tools_Rules__c> toolRuleList = CLQ_UtilityClass.getToolRulesfromInspectionTool(inspectionrecord.id,Date.today());
                
                //Copy all alleged Rule to Rule inspected
                list<CLQ_Alleged_Rule_Violation__c> allegedRuleList = new list<CLQ_Alleged_Rule_Violation__c>();
                allegedRuleList = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Alleged_Rule_Violation__c',' Case_Custom__c =\''+caseRecord.id+'\'', null));
                map<id,CLQ_Alleged_Rule_Violation__c> domainRuleallegedRuleMap = new map<id,CLQ_Alleged_Rule_Violation__c>();
                if(allegedRuleList.size()>0){
                    list<CLQ_Rules_Inspected__c> ruleInsptectedList = new list<CLQ_Rules_Inspected__c>();
                    for(CLQ_Alleged_Rule_Violation__c ruleViolationRecord : allegedRuleList){
                        ruleInsptectedList.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = ruleViolationRecord.CLQ_Domain_Rule__c
                                                                            ,CLQ_Inspection_No__c = inspectionrecord.id
                                                                            ,CLQ_Alleged_Rule_Violation__c = ruleViolationRecord.id
                                                                            ,CLQ_Result__c = TV
                                                                            ,CLQ_Allegation_Description__c = ruleViolationRecord.CLQ_Allegation_Description__c
                                                                            ,CLQ_Decision__c = ruleViolationRecord.CLQ_Decision__c
                                                                            /*,CLQ_Investigation_Method__c = ruleViolationRecord.CLQ_Investigation_Method__c */));
                        domainRuleallegedRuleMap.put(ruleViolationRecord.CLQ_Domain_Rule__c,ruleViolationRecord);
                    }
                    /*for(CLQ_Tools_Rules__c toolRuleRecord : toolRuleList){
                        if(domainRuleallegedRuleMap.get(toolRuleRecord.CLQ_Domain_Rule__c) == null){
                            ruleInsptectedList.add(new CLQ_Rules_Inspected__c(CLQ_Domain_Rule__c = toolRuleRecord.CLQ_Domain_Rule__c
                                                                            ,CLQ_Inspection_No__c = inspectionrecord.id
                                                                            ,CLQ_Result__c = 'Not Verified'));
                        }
                    }*/
                    if(!ruleInsptectedList.isEmpty()){
                        insert ruleInsptectedList;
                    }
                    
                }
                
                //2a. Copy all Room/Space records to inspection
                list<CLQ_Room_Space__c> roomSpaceList = new list<CLQ_Room_Space__c>();
                if(caseRecord.CLQ_Program__c != null){
                    roomSpaceList = CLQ_UtilityClass.queryRoomSpacefromProgram(caseRecord.CLQ_Program__c);
                    if(roomSpaceList.size()>0){
                        list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = CLQ_UtilityClass.createRoomSpaceInspection(roomSpaceList , inspectionrecord);
                        if(!roomSpaceInspectionList.isEmpty()){
                        	insert roomSpaceInspectionList;
                    	}
                    }                    
                }
                //2b Update all Building approvals related records
                list<CLQ_Building_Approval__c> buildingApprovallist = CLQ_UtilityClass.copyBuildingApprovaltoinspection(caseRecord.CLQ_Program__c,inspectionrecord.id);
                if(!buildingApprovallist.isEmpty()){
                    upsert buildingApprovallist ;
                    //update buildingApprovallist ;
                }
        
                //2c update all facility schedule related record
                list<CLQ_Facility_Schedule__c> facilitySchedulelist = new list<CLQ_Facility_Schedule__c>();
                
                facilitySchedulelist = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Facility_Schedule__c', ' CLQ_Program__c='+'\''+caseRecord.CLQ_Program__c+'\'', null));
                if(!facilitySchedulelist.isEmpty()){
                    update CLQ_UtilityClass.copyfacilityScheduletoinspection(facilitySchedulelist,inspectionrecord.id);
                }
                
                //2d UPdate all roles
                list<CLQ_Role__c> roleList = new list<CLQ_Role__c>();
                roleList  = Database.query(CLQ_UtilityClass.createSOQLQuery('CLQ_Role__c', 'CLQ_Status__c = \'Active\' AND CLQ_Program__c='+'\''+caseRecord.CLQ_Program__c+'\' AND RecordTypeID = \''+Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('CLQ_Administrator').getRecordTypeId()+'\'', null));
                if(roleList.size()>0){
                    for(CLQ_Role__c roleRecord: roleList  ){
                        roleRecord.CLQ_Inspection__c = inspectionrecord.id;
                    }
                    if(!roleList.isEmpty()){
                        update roleList;
                    } 
                }
                
                //3. Insert task record //Below code commented by LD on 10/27/2016 - OJLS-333:- Task creation will be taken care in the Process Flows
        //        insert CLQ_UtilityClass.createTaskrecord(caseRecord.CLQ_Assigned_To__c, inspectionrecord.Id, (Date.today()).adddays(20), inspectionType + ' Inspection task', inspectionType + ' Inspection task');
    
                //4. Relate the Inspection record with case (and update other values of case if requires)
                update updateCaseDetail(caseRecord , inspectionrecord);
    
    
                return CLQ_UtilityClass.redirecttoPage('/'+inspectionrecord.Id);    
            }catch(DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(0)));
                return null;
            }
            catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            } 
        }
            
    }

    //Method to update case details
    //@param : case record,inspectionrecord
    //@return : caserecord
    public CLQ_Case_Custom__c updateCaseDetail(CLQ_Case_Custom__c caseRecord,CLQ_Inspection__c inspectionrecord){
        caseRecord.CLQ_Inspection__c = inspectionrecord.id;
        caseRecord.CLQ_Status__c = UNDER_REVIEW;
        return caseRecord;    
    }
    /*
    //Create Room/Space Inspection object
    //@param : roomspace list , inspection record
    //@return : list of roomspace inspection
    public list<CLQ_Room_Space_Inspection__c> createRoomSpaceInspection(list<CLQ_Room_Space__c> roomSpaceList ,CLQ_Inspection__c inspectionrecord ){
        list<CLQ_Room_Space_Inspection__c> roomSpaceInspectionList = new list<CLQ_Room_Space_Inspection__c>();
        for(CLQ_Room_Space__c roompsacerecord : roomSpaceList){
                roomSpaceInspectionList.add(new CLQ_Room_Space_Inspection__c(CLQ_Inspection__c = inspectionrecord.id,CLQ_Room_Group_Information__c = roompsacerecord.id));
        }
        return roomSpaceInspectionList;
    }
    */
    //Method to redirect to Case detail page
    //@param : none
    //@return : Pagereference
    public pagereference onOK(){
        return CLQ_UtilityClass.redirecttoPage('/'+caseRecord.Id);
    }

}