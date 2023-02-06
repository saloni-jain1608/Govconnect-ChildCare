/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTrigHdlrCountySharing 
** Description      : class to grant the 'Edit' Access to County Admin based on the Program County for all existion program record
** 
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date				Version			Description
**	Jiangl					09/10/2017			1.0				TFS#11732 - To grant the 'Edit' Access to County Admin based on the Program County
**	Neetu Ojha				12/14/2017			1.1				TFS#11925 - Added County Check
**************************************************************************************************************/
public with sharing class CLQ_ProgramTrigHdlrCountySharing {
   
    public static final String SOUTH_Central_JFS_Admin = 'SOUTH_Central_JFS_Admin';
    public static final String NOCAC_Admin = 'NOCAC_Admin';
    public static final String County_Admin = '_County_Admin';
    public static final String edit = 'Edit';
    public static final string Informatica_User='Informatica User';
    
    public void CountyAdminShare (list < CLQ_Program__c > newList, map<Id, CLQ_Program__c> oldMap){//11925
        Id fccTypeAId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
        Id fccTypeBId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        Id inHomeAideId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_In_Home_Aide').getRecordTypeId();
        Id preSchoolId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
        Id SACCId = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
        
        String CountyName,subGroupName;
        List<ID> lstShareIdsToDelete = new List<ID>(); 
        List<CLQ_Program__Share> lstPrgShares  = new List<CLQ_Program__Share>();
        List<CLQ_Program__c> lstPrgToShare = new List<CLQ_Program__c>();
        
        for(CLQ_Program__c prg : newList){
            if(prg.RecordTypeId != preSchoolId && prg.RecordTypeId != SACCId){
                System.debug('prg-->' +oldMap);
                if( oldMap == null ||( prg.CLQ_County__c != oldMap.get(prg.Id).CLQ_County__c)){ //11925
                    lstPrgToShare.add(prg);
                }
            }
        }
        
        if(!lstPrgToShare.isEmpty()){
            List<Id> lstUserorGrpId = new List<Id>();
            map<String,id> mapUserGroupId = new map<String,Id>();
            
            List<CLQ_Program__c> lstProgs = [SELECT Id, Recordtypeid , CLQ_County__r.Name, Owner.Name 
                                             FROM CLQ_Program__c WHERE Id IN: lstPrgToShare];  	        				              	 
            
            if(!lstProgs.isEmpty()) {
                for(GroupMember grpMem :[SELECT Id, GroupId, UserOrGroupId FROM GroupMember 
                                         WHERE GroupId IN (SELECT Id FROM Group where Name=: Label.County_Admin_Group) ]){
                                             lstUserorGrpId.add(grpMem.UserOrGroupId);								
                                         }
                
                if(!lstUserorGrpId.isEmpty()){
                    for(Group grp : [SELECT DeveloperName,Type,Id From Group WHERE Id IN:lstUserorGrpId]){
                        mapUserGroupId.put(grp.DeveloperName, grp.Id);
                    }
                }
                
                system.debug('mapUserGroupId==>' + mapUserGroupId);        				             	   	  
                
                if(!mapUserGroupId.isEmpty()){
                    Global_Settings__c GlobalSettings = Global_Settings__c.GetInstance();
                    system.debug('GlobalSettings'+GlobalSettings);                     				             
                    
                    for(CLQ_Program__c p : lstProgs){
                        CLQ_Program__Share countyAdminShare = new CLQ_Program__Share();
                        CountyName = p.CLQ_County__r.Name;	
                        system.debug('CountyName==>' + CountyName);
                        system.debug('GlobalSettings.NOCAC__c==>' + GlobalSettings.NOCAC__c);	                	          	       	        	        									            
                        
                        if((p.Recordtypeid == fccTypeAId ||p.Recordtypeid == fccTypeBId || p.Recordtypeid == inHomeAideId || 
                            (p.Owner.Name != null && p.Owner.Name == Informatica_User && p.Recordtypeid != preSchoolId 
                             && p.Recordtypeid != SACCId)) && CountyName != null){	
                                 
                                 system.debug('program.Owner.Name==>' + p.Owner.Name); 
                                 countyAdminShare.ParentId = p.Id;                   
                                 
                                 if (GlobalSettings.JFS_South_Central__c!= null && GlobalSettings.JFS_South_Central__c.Contains(CountyName)){
                                     subGroupName = SOUTH_Central_JFS_Admin;
                                 }else if (GlobalSettings.NOCAC__c!= null && GlobalSettings.NOCAC__c.Contains(CountyName)){
                                     subGroupName = NOCAC_Admin;
                                 }else{
                                     subGroupName = CountyName + County_Admin; 
                                 }                                                                            
                                 
                                 system.debug('subGroupName==>' + subGroupName);
                                 countyAdminShare.UserOrGroupId = mapUserGroupId.get(subGroupName);                                                       
                                 system.debug('countyAdminShare.UserOrGroupId==>' + countyAdminShare.UserOrGroupId);   
                                 countyAdminShare.AccessLevel = edit;
                                 countyAdminShare.RowCause = Schema.CLQ_Program__Share.RowCause.County_Admin_Sharing__c;
                                 
                                 lstPrgShares.add(countyAdminShare);  
                                 lstShareIdsToDelete.add(p.id);        
                             }    
                    } 
                }
            } 
            
            //Delete the old share           
            system.debug('lstShareIdsToDelete==>' + lstShareIdsToDelete);
            try{
                if(!lstShareIdsToDelete.isEmpty() && oldMap != null){ //11925
                    List<CLQ_Program__Share> lstProgShareToDel = new List<CLQ_Program__Share>();
                    for(CLQ_Program__Share oldProgShrs : [SELECT Id FROM CLQ_Program__Share WHERE ParentId IN :lstShareIdsToDelete 
                                                          AND RowCause = 'County_Admin_Sharing__c']){
                                                              lstProgShareToDel.add(oldProgShrs);											
                                                          }       
                    
                    system.debug('lstProgShareToDel==>' + lstProgShareToDel); 
                    if (!lstProgShareToDel.isEmpty()){ 
                        delete lstProgShareToDel;
                    }
                }
                
                //Insert the new share   
                if (!lstPrgShares.isEmpty()) { 
                    Database.SaveResult[] jobShareInsertResult = Database.insert(lstPrgShares,false);  
                } 
            }catch(Exception ex){
                system.debug('Exception occured in : CountyAdminShare --'+ex.getMessage());
                Integration_Transaction_Logs.LogError('SFDC-001.2', ex.getMessage() ,'' ,String.valueOf(ex.getLineNumber()),'','Salesforce Exception -- CountyAdminShare');
            } 
        }
    } 
}