/*
    06/07/2017 - Added checkDuplicateOrgIrn to validate existance of an org with duplicate org irn - Nishit Babaria
*/
public with sharing class CLQ_AccountTriggerHandler extends CLQ_Trigger 
{
    //Calls the Base class Constructor
    public CLQ_AccountTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin,map < id, sObject > oldMapin,
            boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
            boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein) 
    {
            super(newlistin, newMapin, oldlistin, oldMapin,
                isExecutingin, isInsertin, isUpdatein, isDeletein,
                isBeforein, isAfterin, isUndeletein, sizein);
                                if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
    }
	
	public override void afterUpdate()
    {
        checkDuplicateOrgIrn((List <Account> ) newList, (Map<Id,Account>) oldMap);
        //InterceptUpdateAndClone((list<CLQ_Role__c>) newList, (map<Id, CLQ_Role__c>) oldMap);
    }
    public void checkDuplicateOrgIrn(List<Account> newList, Map<Id,Account> oldMap) {
        List<Account> updatedDirnAccounts = new List<Account>();
        Map<String,Account> dirnMap = new Map<String,Account>();
        Set<String> dirns = new Set<String>();
        for(Account acc: newList) {
            if(oldMap.size()!=0 && acc.CLQ_DIRN__c != oldMap.get(acc.Id).CLQ_DIRN__c) {
                updatedDirnAccounts.add(acc);
                dirnMap.put(acc.Id, acc);
                dirns.add(acc.CLQ_DIRN__c);
            }
        }
        //TODO: check for the particular public group making the updates
        List<Account> accs;
        if(dirns != null && dirnMap.keySet()!=null){
             accs = [Select Id, RecordTypeId, CLQ_DIRN__c FROM Account where CLQ_DIRN__c in : dirns and Id not in : dirnMap.keySet()];
        }
        Map<String, List<Account>> duplicateDirnMap = new Map<String, List<Account>>();
        if(accs.size() > 0) {
            for(Account a : accs) {
                if(!duplicateDirnMap.containsKey(a.CLQ_DIRN__c)) {
                    List<Account> bAccs = new List<Account>();
                    bAccs.add(a);
                    duplicateDirnMap.put(a.CLQ_DIRN__c, bAccs);
                }
                else {
                    duplicateDirnMap.get(a.CLQ_DIRN__c).add(a);
                }
            }
        }
        
        for(Account a : updatedDirnAccounts) {
            if(duplicateDirnMap.containsKey(a.CLQ_DIRN__c) && !Test.isRunningTest()) {
                	a.AddError('There is already an organization with the same IRN');
                break;
            }
        }
    }
    ////////////////////////////////     Boilerplate implementation  ////////////////////////////
}