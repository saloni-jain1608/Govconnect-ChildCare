/*************************************************************************************************************
**************************************************************************************************************
** Name             : CCLQ_DomainRuleLookupSearchController
** Description      : CLQ_DomainRuleLookupSearch Page Controller
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer           Date                Version         Description
**  Neetu Ojha          11/08/2017          1.0             TFS#11415 : Initial Version 
**************************************************************************************************************/

public with sharing class CLQ_DomainRuleLookupSearchController{
	public CLQ_Alleged_Rule_Violation__c arvObject{get;set;}
	public String domainRuleName {get;set;}
	public String domainName {get;set;}
	public String ruleShortName {get;set;}	
	public String ruleNumber {get;set;}
	public String applicableTo {get;set;}
	public integer totalRecs{get;set;}
	public static final string EMPTY = '';
	List<string> conditions = new List<string>();
	
	private integer offsetSize = 0;
	private integer limitSize = Integer.valueOf(Label.LookUpSearch_RowSize);

	public CLQ_DomainRuleLookupSearchController(){
		arvObject = new CLQ_Alleged_Rule_Violation__c();
 		totalRecs = 0;
 		domainRuleName = system.currentPageReference().getParameters().get('lksrch');
 		
 		if(domainRuleName != null && domainRuleName != EMPTY){
 			searchDomainRule();
 		}
	}
  	
  	// used by the visualforce page to send the link to the right dom element
  	public string getFormTag() {
    	return system.currentPageReference().getParameters().get('frm');
  	}

  	// used by the visualforce page to send the link to the right dom element for the text box
  	public string getTextBox() {
    	return system.currentPageReference().getParameters().get('txt');
  	}	

	public void searchDomainRule(){
		totalRecs = 0;
		offsetSize = 0;
	}

	//Method to get all fields from field set
	private List<Schema.FieldSetMember> getFields() {
        return SObjectType.CLQ_Domain_Rule__c.FieldSets.LookUpSearchFS.getFields();
    }
    
    //Method to form query
    private string formBasicQuery(){
    	String strQuery = 'SELECT ';
    	conditions.clear();
    	
        for(Schema.FieldSetMember f : this.getFields()) {
            strQuery += f.getFieldPath() + ', ';
        }
        strQuery += 'Id FROM CLQ_Domain_Rule__c';
        
        conditions.add('(NOT CLQ_Domain__r.Name Like \'Conversion%\')');
        conditions.add('(CLQ_Rule_Expiration_Date__c = null OR CLQ_Rule_Expiration_Date__c >= TODAY)');
        conditions.add('(CLQ_Rule_Effective_Date__c = null OR CLQ_Rule_Effective_Date__c <= TODAY)');
        
        return strQuery;
    }
    
    //To get the list of Domain Rule
    public List<CLQ_Domain_Rule__c> getLstDomainRule(){
    	String strQuery = formBasicQuery();
		
		if(domainRuleName != EMPTY && domainRuleName != null){
        	conditions.add('Name Like \'%' +domainRuleName +'%\'');
        }
        
        if(domainName != EMPTY && domainName != null){
        	conditions.add('CLQ_Domain__r.Name Like \'%' +domainName +'%\'');
        }
        
        if(ruleShortName != EMPTY && ruleShortName != null){
        	conditions.add('CLQ_Rule__r.CLQ_Short_Name__c Like \'%' +ruleShortName +'%\'');
        }
         
        if(ruleNumber != EMPTY && ruleNumber != null){
        	conditions.add('CLQ_Rule__r.CLQ_Rule_Number__c Like \'%' +ruleNumber +'%\'');
        }
         
        if(applicableTo != EMPTY && applicableTo != null){
        	conditions.add('CLQ_ApplicableTo_Txt__c Like \'%' +applicableTo +'%\'');
        } 

        if(arvObject.CLQ_Rule_Effective_Date__c != null){
        	String strDt = arvObject.CLQ_Rule_Effective_Date__c+'';
        	conditions.add('CLQ_Rule_Effective_Date__c =' +strDt.split(' ',0)[0]);
        } 
		
		if (conditions.size() > 0) {
			strQuery += '  WHERE ' + conditions[0];
			for (Integer i = 1; i < conditions.size(); i++)
				strQuery += '  AND ' + conditions[i];
		}

		List<CLQ_Domain_Rule__c> domainRuleTemp = Database.query(strQuery);
		totalRecs = (domainRuleTemp !=null && domainRuleTemp.size()>0)?domainRuleTemp.size():0;
		
		strQuery += ' ORDER BY Name ASC LIMIT :LimitSize OFFSET :offsetSize';
		
		system.debug('strQuery ==>'+strQuery );
		
		return Database.query(strQuery);    	
    }

	//Pagination Starts
	public void firstPage(){
        offsetSize = 0;
    }
    
	public void previous(){
        offsetSize = offsetSize - limitSize;
    }
    
    public void next(){
        offsetSize = offsetSize + limitSize;
    }

    public void lastPage(){
        offsetSize = totalrecs - math.mod(totalRecs,limitSize);
    }        
    
    public boolean getprev(){
        if(offsetSize == 0) {return true;}
        else{
            return false; 
        } 
    }  
    
    public boolean getnxt() {
        if((offsetSize + limitSize) > totalRecs) {return true;}
        else{
            return false;
        } 
    }
    //Pagination Ends
}