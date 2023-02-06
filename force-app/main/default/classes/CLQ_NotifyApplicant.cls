/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_NotifyApplicant 
** Description      : Controller Class 
** Version          : 1.3
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer           Date                Version         Description
**  Neetu Ojha          06/08/2017          1.1             TFS#11200 : Email Matrix Change
**  Neetu Ojha          05/02/2018          1.2             TFS#12201 : Stop sending email to inactive/ Denied Roles.
**  Neetu Ojha          06/19/2018          1.3             TFS#12501 : Added logic to send email for CoA, CoC, CoL
**  Rohit Gowrishetty   08/23/2018          1.4             CR#13554  : Added the Renew Application Day camp for returned documents
**  Pradeep Ravi        12/29/2018          1.5             CR#15242  : Added the SUTQ return for revision document for Exp, COO and Reinstate
**************************************************************************************************************/

public with sharing class CLQ_NotifyApplicant {
    
    public static list<CLQ_Program_Transaction__c>PTList;
    public static list< CLQ_Transaction_Document__c>TDList=new list<CLQ_Transaction_Document__c>();
    public static list< CLQ_Transaction_Document__c>TDupdateList=new list<CLQ_Transaction_Document__c>();
    public static list<CLQ_Program_Transaction__c>PTUpdateList=new list<CLQ_Program_Transaction__c>();
    public static list< CLQ_Role__c>rolelist=new list<CLQ_Role__c>();
    static ID PTid; 
    static string emailadd;
    public static String redirectUrl;
    static list<string> emailids=new list<string>();
    static list<string> emailIDNew = new List<string>();
    static String eBody;
    static string eSubject;
    static string tname;
    public static final String CHILD_CARE_CENTER = 'Child_Care_Center';
    public static final String FCC = 'FCC';
    public static final String Out_of_State_Registration = 'Out_of_State_Registration';
    public static final String In_Home_Aide = 'In_Home_Aide';
    public static final String Day_Camp = 'Day_Camp';
    public static final String Owner = 'Owner';
    public static final String JFS ='JFS';
    public static final String Director = 'Director';
    public static final String SUTQ_Consultant = 'SUTQ_Consultant';
    public static final String Returned_For_Revision = 'Returned_For_Revision';
    public static final String Licensing_Admin = 'Licensing_Admin';
    public static final String Application = 'Application';
    public static final String Application_Day_Camp = 'Application_Day_Camp';
    public static final String Change_of_Administrator = 'Change_of_Administrator';
    public static final String Change_of_Capacity = 'Change_of_Capacity';
    public static final String OUT_OF_STATE = 'Out of State Registration';
    public static final String INHOME_AID = 'In-Home Aide';
    public static final String DAYCAMP ='Day Camp';
    public static final String Change_of_Location = 'Change_of_Location';
    public static final String RENEW_APPLICATION_DAY_CAMP = 'Renew_Application_Day_Camp';
    public static final String EMPTY_STRING = '';   
    public static final string SCHOOL = 'School';
    public static final string SETREPLY_EMAIL = 'noreply@salesforce.com';
    public static final string OCLQS = 'OCLQS';
    
    //static EmailTemplate emailtemplate;
    static list<Messaging.SingleEmailMessage> maillist = new list<Messaging.SingleEmailMessage>();
    static map<string,EmailTemplate> EmailTempMap=new map<string,EmailTemplate>();
    static Boolean bFromFlow = false;
    public static Map<String, String> notifyMetadataValueMap = new  Map<String, String>();
    
    public CLQ_NotifyApplicant(){
        list<string> EmailTemplateDevList=new list<string>{'SUTQ_Email_Doc_Returned_For_Review','Day_Camp_Return_for_Revision_Email','JFS_COA_DocRevision_Email','JFS_COL_DocRevision_Email','JFS_COC_DocRevision_Email','CLQ_NotifyApplicant_ODJFS','CLQ_NotifyApplicant_ODE'};
            list<EmailTemplate> emailtemp=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue, e.developername from emailtemplate e where developername in :EmailTemplateDevList];
        for(EmailTemplate etemp:emailtemp){
            EmailTempMap.put(etemp.developername, etemp);
        }
    }
    
    public static pagereference notification(){
        
        Id objInitialRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Quality_Rating_Registration').getRecordTypeId();
        Id objAnnualReportReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        Id objOnGoingReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Ongoing_Quality_Rating_Registration').getRecordTypeId();
        // TFS #15242 - Adding Rec types for return docs notification
        Id objExpeditedRegId = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId();
        Id objCOOReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId();
        Id objReinstateReg = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId();     
        Id portalRoleRecId = Schema.SObjectType.CLQ_Role__c.getRecordTypeInfosByDeveloperName().get('Portal_Roles').getRecordTypeId(); //11200
        List<String> emailCCList = new List<String>(); //11200
        
        if(!bFromFlow) {
            PTid=ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        }
        
        for(CLQ_Notify_Application__mdt mdt : [Select label,QualifiedApiName from CLQ_Notify_Application__mdt]){
            notifyMetadataValueMap.put(mdt.QualifiedApiName,mdt.label);
        }
        
        CLQ_Program_Transaction__c PT;
        if(PTid!=null){
            PT = [select id,CLQ_ProgTrans_Program_Email_Address__c,
                  CLQ_Registration_Status__c,name,recordtypeid,recordtype.name,CLQ_Program__r.Id,
                  CLQ_Program_Record_Type__c,CLQ_Program__r.CLQ_Associated_Organization__r.Id,
                  CLQ_Program__r.CLQ_Associated_Organization__r.name,CLQ_Program__r.name,
                  CLQ_Program__r.CLQ_Associated_Organization__c,CLQ_Program__r.CLQ_Program_Number__c,
                  CLQ_Program__r.CLQ_Program_Email__c, clq_recordtypename__c, Annual_Report_Documents__c 
                  from CLQ_Program_Transaction__c where id=:PTid];
        }
        if(PTid!=null){
            TDList = [select id,name,CLQ_Document_Status__c,CLQ_Program_Transaction__c 
                      from CLQ_Transaction_Document__c where 
                      CLQ_Program_Transaction__c =:PTid and CLQ_Document_Status__c='Under Review'];
        }
        if(PT.CLQ_Program__r.id!=null){
            rolelist=[select id,name,CLQ_Contact__c,CLQ_Contact__r.email,CLQ_Program__c,
                      Role_Type__c,Portal_Roles__c, RecordTypeId from CLQ_Role__c 
                      where CLQ_Program__c =:PT.CLQ_Program__r.id AND (CLQ_End_Date__c = null OR CLQ_End_Date__c >= TODAY) AND CLQ_Status__c NOT IN ('Inactive', 'Denied')];//11200; 12201
        }
        
        list<string> toAddresses = 
            CLQ_GlobalWebserviceUtility.getAllRecipientsSUTQ(PT.CLQ_Program__r.Id,PT.CLQ_Program__r.CLQ_Associated_Organization__r.Id,PT.recordtypeid);
        
        if(TDList.size()>0){
            // TFS #15242 - Adding Rec types for return docs notification
            if(PT.recordTypeid == objOnGoingReg || PT.recordTypeid == objInitialRegId || PT.recordTypeid == objAnnualReportReg ||
               PT.recordTypeid == objExpeditedRegId || PT.recordTypeid == objCOOReg || PT.recordTypeid == objReinstateReg){
                   //11200 Starts
                       
                   for(CLQ_Role__c roleObj : rolelist){
                       if(notifyMetadataValueMap.size()!=0 && roleObj.CLQ_Contact__r.email != null && roleObj.RecordTypeId == portalRoleRecId && roleObj.Role_Type__c == notifyMetadataValueMap.get(JFS) && 
                          (roleObj.Portal_Roles__c == notifyMetadataValueMap.get(Owner) || roleObj.Portal_Roles__c == notifyMetadataValueMap.get(Director) || roleObj.Portal_Roles__c == notifyMetadataValueMap.get(SUTQ_Consultant))){
                              emailCCList.add(roleObj.CLQ_Contact__r.email);
                          }
                   }
                   //11200 Ends
                   
                   //email logic start
                   emailIDNew.add(PT.CLQ_Program__r.CLQ_Program_Email__c);
                   EmailTemplate emailtemplate;
                   if(EmailTempMap.size()!=0){
                   		emailtemplate=EmailTempMap.get('SUTQ_Email_Doc_Returned_For_Review');
                   }
                   //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='SUTQ_Email_Doc_Returned_For_Review'];
                   eBody = emailtemplate.Body;
                   ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                   ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                   eSubject = emailtemplate.subject;
                   esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                   esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                   
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                   
                   if(PT.CLQ_Program_Record_Type__c == Label.PreSchoolRecType || PT.CLQ_Program_Record_Type__c ==  Label.SACCRecType ){
                       System.debug('');
                       if(toAddresses.size() > 0){
                           Mail.setToAddresses(toAddresses);
                       }
                   }else{
                       Mail.setToAddresses(emailIDNew);
                       //11200 Starts
                       if(!emailCCList.isEmpty()){
                           mail.setCcAddresses(emailCCList);
                       }
                       //11200 Ends
                   }
                   
                   Mail.setPlaintextBody(ebody);        
                   Mail.SetSubject(esubject);
                   OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mvg@deloitte.com'];
                   
                   if ( owea.size() > 0 ) {
                       mail.setOrgWideEmailAddressId(owea.get(0).Id);
                   }
                   
                   mail.setWhatId(PT.Id);
                   // Mail.setSenderDisplayName('OCLQS');   
                   maillist.add(mail);
                   
                   if(maillist!=null && maillist.size()>0){
                       Messaging.sendEmailResult[] EmailResult=Messaging.sendEmail(maillist,false);
                   }
                   
                   for(CLQ_Transaction_Document__c TD : TDList){
                       if(notifyMetadataValueMap.size()!=0){
                       		TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                       		TD.CLQ_All_Comments__c= notifyMetadataValueMap.get(Returned_For_Revision);
                       }
                       TDupdateList.add(TD);
                   }
                   
                   if(!TDupdateList.isEmpty()){
                       update TDupdateList;
                   }
                   if(notifyMetadataValueMap.size()!=0){
                   		PT.CLQ_Transaction_Status__c= notifyMetadataValueMap.get(Returned_For_Revision);
                   }
                   PTUpdatelist.add(PT);
                   
                   if(!PTUpdatelist.isEmpty()){
                       update PTUpdatelist;
                   }
               }
            //Mod by LD 12/19/16 - Fix for 1138 --Srikanth added extra record types for OJLS-1284
           
            
            
            else{
                if(notifyMetadataValueMap.size()!=0 && (PT.CLQ_Program_Record_Type__c == notifyMetadataValueMap.get(CHILD_CARE_CENTER) || PT.CLQ_Program_Record_Type__c.contains(FCC) 
                   || PT.CLQ_Program_Record_Type__c == notifyMetadataValueMap.get(Out_of_State_Registration)
                   || PT.CLQ_Program_Record_Type__c == notifyMetadataValueMap.get(In_Home_Aide) || PT.CLQ_Program_Record_Type__c == notifyMetadataValueMap.get(Day_Camp))){
                       if(rolelist.size()>0){
                           for(CLQ_Role__c role : rolelist){
                               emailadd=role.CLQ_Contact__r.email;
                               if (role.CLQ_Contact__r.email != null){
                                   emailids.add(role.CLQ_Contact__r.email);
                                  //11200 Starts
                                   if(notifyMetadataValueMap.size()!=0 && role.RecordTypeId == portalRoleRecId && role.Role_Type__c == notifyMetadataValueMap.get(JFS) && (role.Portal_Roles__c == notifyMetadataValueMap.get(Owner) || role.Portal_Roles__c == notifyMetadataValueMap.get(Director) || role.Portal_Roles__c == notifyMetadataValueMap.get(Licensing_Admin))){
                                       emailCCList.add(role.CLQ_Contact__r.email);         
                                   }
                                   //11200 Ends
                               }
                           }
                       }
                       
                       if(notifyMetadataValueMap.size()!=0 && PT.Recordtype.name.contains(notifyMetadataValueMap.get(Application)) && PT.CLQ_ProgTrans_Program_Email_Address__c != null){
                           emailids.add(PT.CLQ_ProgTrans_Program_Email_Address__c);
                       }else{
                           if(PT.CLQ_Program__r.CLQ_Program_Email__c != null){
                               emailids.add(PT.CLQ_Program__r.CLQ_Program_Email__c);
                           }
                       }
                       
                       //sr added logic for day camp application document revise mail
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                       
                       if(notifyMetadataValueMap.size()!=0 && (PT.clq_recordtypename__c == notifyMetadataValueMap.get(Application_Day_Camp) || PT.clq_recordtypename__c == notifyMetadataValueMap.get(RENEW_APPLICATION_DAY_CAMP))){ //13554
                           //email logic starts
                           EmailTemplate emailtemplate;
                           if(EmailTempMap.size()!=0){
                           		emailtemplate=EmailTempMap.get('Day_Camp_Return_for_Revision_Email');
                           }	
                           //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='Day_Camp_Return_for_Revision_Email'];
                           eBody = emailtemplate.Body;
                           ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Id}',PT.Id);//12501
                           
                           if(PT.Annual_Report_Documents__c != null) {
                               ebody = ebody.replace('{!CLQ_Program_Transaction__c.Annual_Report_Documents__c}',PT.Annual_Report_Documents__c);
                           }
                           
                           eSubject = emailtemplate.subject;
                           esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           esubject = esubject.replace('{!CLQ_Program_Transaction__c.RecordType}',PT.recordtype.name);
                           //esubject = esubject.replace('{!CLQ_Program__c.CLQ_Associated_OrganizationId__c}',PT.CLQ_Program__r.CLQ_Associated_Organization__c);
                           tname='';
                           for(CLQ_Transaction_Document__c TD : TDList){             
                               if(tname!=null && tname!=EMPTY_STRING){
                                   tname= tname+','+TD.name;
                               }
                               else{
                                   tname=td.name;
                               }
                               TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               TD.CLQ_All_Comments__c= notifyMetadataValueMap.get(Returned_For_Revision);
                               TDupdateList.add(TD);
                           } // end for
                           
                           if(!TDupdateList.isEmpty()){
                               update TDupdateList;
                           }
                           
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Annual_Report_Documents__c}',tname);
                           mail.setwhatID(PT.Id);//12501
                           mail.setToAddresses(emailids);
                           mail.setPlaintextBody(ebody);        
                           mail.SetSubject(esubject);
                           mail.setReplyTo(SETREPLY_EMAIL);
                           //mail.setUseSignature(false);
                           mail.setSenderDisplayName(OCLQS);   
                           
                           //11200 Starts
                           if(!emailCCList.isEmpty()){
                               mail.setCcAddresses(emailCCList);
                           }
                           //11200 Ends   
                           maillist.add(mail);
                           //email logic ends        
                       }
                       //12501 Starts
                       //INHOME_AID
        
                       else if(notifyMetadataValueMap.size()!=0 && PT.clq_recordtypename__c.containsIgnoreCase(notifyMetadataValueMap.get(Change_of_Administrator))){
                           //email logic starts
                           EmailTemplate emailtemplate;
                           if(EmailTempMap.size()!=0){
                           		emailtemplate=EmailTempMap.get('JFS_COA_DocRevision_Email');
                           }
                           //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='JFS_COA_DocRevision_Email'];
                           eBody = emailtemplate.Body;
                           ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Id}',PT.Id);
                           eSubject = emailtemplate.subject;
                           esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           
                           for(CLQ_Transaction_Document__c TD : TDList){             
                               TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               TD.CLQ_All_Comments__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               TDupdateList.add(TD);
                           }
                           
                           if(!TDupdateList.isEmpty()){
                               update TDupdateList;
                           }
                           
                           mail.setwhatID(PT.Id); 
                           mail.setToAddresses(emailids);
                           mail.setPlaintextBody(ebody);        
                           mail.SetSubject(esubject);
                           mail.setReplyTo(SETREPLY_EMAIL);
                           mail.setSenderDisplayName(OCLQS);   
                           
                           if(!emailCCList.isEmpty()){
                               mail.setCcAddresses(emailCCList);
                           }
                           maillist.add(mail);
                       }else if(notifyMetadataValueMap.size()!=0 && PT.clq_recordtypename__c.containsIgnoreCase(notifyMetadataValueMap.get(Change_of_Location))){
                           //email logic starts
                            EmailTemplate emailtemplate;
                           if(EmailTempMap.size()!=0){
                           		emailtemplate=EmailTempMap.get('JFS_COL_DocRevision_Email');
                           }	
                           //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='JFS_COL_DocRevision_Email'];
                           eBody = emailtemplate.Body;
                           ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Id}',PT.Id);
                           eSubject = emailtemplate.subject;
                           esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           
                           for(CLQ_Transaction_Document__c TD : TDList){ 
                               TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               TD.CLQ_All_Comments__c= notifyMetadataValueMap.get(Returned_For_Revision);
                               TDupdateList.add(TD);
                           }
                           
                           if(!TDupdateList.isEmpty()){
                               update TDupdateList;
                           }
                           
                           mail.setwhatID(PT.Id);  
                           mail.setToAddresses(emailids);
                           mail.setPlaintextBody(ebody);        
                           mail.SetSubject(esubject);
                           mail.setReplyTo(SETREPLY_EMAIL);
                           mail.setSenderDisplayName(OCLQS);   
                           
                           if(!emailCCList.isEmpty()){
                               mail.setCcAddresses(emailCCList);
                           }
                           maillist.add(mail);
                           
                       }else if(notifyMetadataValueMap.size()!=0 && PT.clq_recordtypename__c.containsIgnoreCase(notifyMetadataValueMap.get(Change_of_Capacity))){
                           //email logic starts
                           EmailTemplate emailtemplate;
                           if(EmailTempMap.size()!=0){
                           		emailtemplate=EmailTempMap.get('JFS_COC_DocRevision_Email');
                           }
                         
                           //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='JFS_COC_DocRevision_Email'];
                           eBody = emailtemplate.Body;
                           ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Id}',PT.Id);
                           eSubject = emailtemplate.subject;
                           esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           
                           for(CLQ_Transaction_Document__c TD : TDList){  
                               TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               TD.CLQ_All_Comments__c= notifyMetadataValueMap.get(Returned_For_Revision);
                                
                               TDupdateList.add(TD);
                           }
                           
                           if(!TDupdateList.isEmpty()){
                               update TDupdateList;
                           }
                           
                           mail.setwhatID(PT.Id);  
                           mail.setToAddresses(emailids);
                           mail.setPlaintextBody(ebody);        
                           mail.SetSubject(esubject);
                           mail.setReplyTo(SETREPLY_EMAIL);
                           mail.setSenderDisplayName(OCLQS);   
                           
                           if(!emailCCList.isEmpty()){
                               mail.setCcAddresses(emailCCList);
                           }
                           maillist.add(mail);
                           //12501 Ends
                       }else{
                           //email logic starts
                           EmailTemplate emailtemplate;
                           if(EmailTempMap.size()!=0){
                           		emailtemplate=EmailTempMap.get('CLQ_NotifyApplicant_ODJFS');
                           }
                       
                           //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e where developername='CLQ_NotifyApplicant_ODJFS'];
                           eBody = emailtemplate.Body;
                           ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           ebody = ebody.replace('{!CLQ_Program_Transaction__c.Id}',PT.Id);//12501
                           eSubject = emailtemplate.subject;
                           esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                           esubject = esubject.replace('{!CLQ_Program_Transaction__c.RecordTypeId}',PT.recordtype.name);
                           esubject = esubject.replace('{!CLQ_Program__c.CLQ_Associated_OrganizationId__c}',PT.CLQ_Program__r.CLQ_Associated_Organization__c);
                           tname='';
                           
                           for(CLQ_Transaction_Document__c TD : TDList){             
                               if(tname!=null && tname!=EMPTY_STRING){
                                   tname= tname+','+TD.name;
                               }
                               else
                               {
                                   tname=td.name;
                               }
                               
                                if(notifyMetadataValueMap.size()!=0){
                               		TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                               		TD.CLQ_All_Comments__c = notifyMetadataValueMap.get(Returned_For_Revision);
                                }
                               TDupdateList.add(TD);
                           } // end for
                           
                           if(!TDupdateList.isEmpty()){
                               update TDupdateList;
                           }
                           
                           ebody = ebody.replace('{!CLQ_Transaction_Document__c.Name}',tname);
                           mail.setwhatID(PT.Id);//12501
                           mail.setToAddresses(emailids);
                           mail.setPlaintextBody(ebody);        
                           mail.SetSubject(esubject);
                           mail.setReplyTo(SETREPLY_EMAIL);
                           //mail.setUseSignature(false);
                           mail.setSenderDisplayName(OCLQS);   
                           
                           //11200 Starts
                           if(!emailCCList.isEmpty()){
                               mail.setCcAddresses(emailCCList);
                           }
                           //11200 Ends   
                           maillist.add(mail);
                           //email logic ends 
                       }
                       if(notifyMetadataValueMap.size()!=0){
                       		PT.CLQ_Transaction_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                       }
                       
                       if(notifyMetadataValueMap.size()!=0 && (PT.CLQ_Program_Record_Type__c == OUT_OF_STATE || PT.CLQ_Program_Record_Type__c == INHOME_Aid || PT.CLQ_Program_Record_Type__c == DAYCAMP)){
                           PT.CLQ_Registration_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                       }
                       
                       PTUpdatelist.add(PT);
                       
                       if(maillist!=null && maillist.size()>0){
                           Messaging.sendEmailResult[] EmailResult=Messaging.sendEmail(maillist,false);
                       }
                       
                       if (!PTUpdatelist.isEmpty()){
                           update PTUpdatelist;
                       }
                   } // FCC & CC
                
                //Mod by LD 12/19/16 - Fix for 1138 
                if(PT.CLQ_Program_Record_Type__c.contains(SCHOOL) && rolelist.size()>0){
                    for(CLQ_Role__c role : rolelist){
                        if (role.CLQ_Contact__r.email != null){
                            emailids.add(role.CLQ_Contact__r.email);
                        }
                    }
                    
                    
                    tname=EMPTY_STRING;
                    
                    for(CLQ_Transaction_Document__c TD : TDList){
                        if(tname!=null && tname !=EMPTY_STRING){
                            tname= tname+','+TD.name;
                        }
                        else{ 
                            tname=td.name;
                        }
                        
                        if(notifyMetadataValueMap.size()!=0){
                        	TD.CLQ_Document_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                        	TD.CLQ_All_Comments__c= notifyMetadataValueMap.get(Returned_For_Revision);
                        }
                        TDupdateList.add(TD);
                    } // for
                    
                    if(!TDupdateList.isEmpty()){
                        update TDupdateList;
                    }
                    
                    if (emailids.size() > 0){
                          EmailTemplate emailtemplate;
                        if(EmailTempMap.size()!=0){
                        	 emailtemplate=EmailTempMap.get('CLQ_NotifyApplicant_ODE');
                        }
                        //emailtemplate=[Select e.id, e.markup, e.subject, e.body,e.HtmlValue from emailtemplate e
                        //where developername='CLQ_NotifyApplicant_ODE'];
                        eBody = emailtemplate.Body;
                        ebody = ebody.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                        ebody = ebody.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                        eSubject = emailtemplate.subject;
                        esubject = esubject.replace('{!CLQ_Program__c.Name}',PT.CLQ_Program__r.name);
                        esubject = esubject.replace('{!CLQ_Program__c.CLQ_Program_Number__c}',PT.CLQ_Program__r.CLQ_Program_Number__c);
                        esubject = esubject.replace('{!CLQ_Program_Transaction__c.RecordTypeId}',PT.recordtype.name);
                        esubject = esubject.replace('{!CLQ_Program__c.CLQ_Associated_Organization__c}',PT.CLQ_Program__r.CLQ_Associated_Organization__c);
                        ebody = ebody.replace('{!CLQ_Transaction_Document__c.Name}',tname);
                        ebody = ebody.replace('{!CLQ_Program__c.CLQ_Associated_Organization__c}',PT.CLQ_Program__r.CLQ_Associated_Organization__r.name);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        
                        mail.setToAddresses(emailids);
                        mail.setPlaintextBody(ebody);        
                        mail.SetSubject(esubject);
                        
                        mail.setReplyTo(SETREPLY_EMAIL);
                        //mail.setUseSignature(false);
                        mail.setSenderDisplayName(OCLQS);   
                        maillist.add(mail);
                    }
                    
                    if(notifyMetadataValueMap.size()!=0){
                        PT.CLQ_Transaction_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                        PT.CLQ_Registration_Status__c = notifyMetadataValueMap.get(Returned_For_Revision);
                        PTUpdatelist.add(PT);
                    }
                    
                    if(maillist!=null && maillist.size()>0){
                        Messaging.sendEmailResult[] EmailResult=Messaging.sendEmail(maillist,false);
                    }
                    
                    if (!PTUpdatelist.isEmpty()){
                        update PTUpdatelist;
                    }
                }//school 
            }  
        }
        
        redirecturl ='/'+PT.id;
        pageReference newpage=new pagereference(redirecturl);
        newpage.setRedirect(true);
        return newpage;
    }
    
    //Added method to be called from Flow
    @InvocableMethod(label='Trigger Notification'
                     description='Triggers Notifications for Document Stakeholders' category='Program Transaction')
    public static void triggerNotification(List<String> lstProgramTransactionId) {
        PTid = Id.valueOf(lstProgramTransactionId[0]);
        bFromFlow = true;
        CLQ_NotifyApplicant notifyapplicant = new CLQ_NotifyApplicant();
        notification();
    }
}