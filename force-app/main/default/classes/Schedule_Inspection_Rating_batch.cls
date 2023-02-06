/*************************************************************************************************************
**************************************************************************************************************
** Name             : Schedule_Inspection_Rating_batch
** Description      : 
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
** Ankush R Relekar	     12/14/2021		      1.0	    Initial Build 
** 		
**************************************************************************************************************/
global with sharing class Schedule_Inspection_Rating_batch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer recordsDeleted = 0;
    global static final String IN_PROGRESS = 'In Progress';
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //list <CLQ_Program__c> ProgList=[select id,CLQ_Manual__c, CLQ_Program_Rating__c,CLQ_Current_Rating__c, CLQ_Current_Rating_Expiration_Date__c,  Rating_Effective_Date__c, Rating_Expiration_Date__c, Rating_Anniversary_Date__c, Program_Rating__c, SUTQ_Current_Rating__c,CLQ_Continuous_License_Status__c, CLQ_License_Registration_Status__c, CLQ_License_Issue_Date__c from CLQ_Program__c where Rating_Expiration_Date__c=:d];
        date d = system.today().addDays(60);
        return Database.getQueryLocator([select id,CLQ_Manual__c, CLQ_Program_Rating__c,CLQ_Current_Rating__c, CLQ_Current_Rating_Expiration_Date__c,  Rating_Effective_Date__c, Rating_Expiration_Date__c, Rating_Anniversary_Date__c, Program_Rating__c, SUTQ_Current_Rating__c,CLQ_Continuous_License_Status__c, CLQ_License_Registration_Status__c, CLQ_License_Issue_Date__c,(select id, RecordType.Name from Inspections__r where RecordType.Name='Onsite Visit Record Type') from CLQ_Program__c where Rating_Expiration_Date__c=:d]);
    }
    
    global void execute(Database.BatchableContext BC,List<CLQ_Program__c> scope){
        list<CLQ_Inspection__c> insplist=new list<CLQ_Inspection__c>();
        Map<String,List<CLQ_Inspection__c>> mapInspectLst = new Map<String,List<CLQ_Inspection__c>>();
        
        for(CLQ_Program__c prog:scope){
            system.debug('prog in scope:'+prog);
            if(prog.Inspections__r.IsEmpty()){
                CLQ_Inspection__c inspectionrecord = new CLQ_Inspection__c();
                inspectionrecord.RecordTypeId=Schema.SObjectType.CLQ_Inspection__c.getRecordTypeInfosByDeveloperName().get('Onsite_Visit_Record_Type').getRecordTypeId();
                inspectionrecord.CLQ_Program__c = prog.Id; 
                inspectionrecord.CLQ_Inspection_Owner__c = UserInfo.getUserId();
                inspectionrecord.CLQ_Inspection_Status__c = IN_PROGRESS; 
                insplist.add(inspectionrecord);
            } 
        }
        
        if(!insplist.isEmpty()){
            insert insplist;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('Rating_exp_date_batch - Finished!');
        
    }        
}