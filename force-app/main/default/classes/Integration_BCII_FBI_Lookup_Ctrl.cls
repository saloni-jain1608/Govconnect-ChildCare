/*************************************************************************************************************
** User Story: 
************************************************************************************************************
** Name             : Integration_BCII_FBI_Lookup_Ctrl
** Description      : Integration Class for BCII FBI Lookup
** Version          : 1.0
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer                         Date                    Version                      Description
**------------------------------------------------------------------------------------------------------------
** Sanjeev Chahar                July-2016                    1.0                          Created
** Vamsi Velampati               November-2016                1.1                          Added 1 line for CPI tracking (see line 141)
************************************************************************************/ 

public with sharing class Integration_BCII_FBI_Lookup_Ctrl{

  private String soql {get;set;}
  public List<CLQ_BCII_FBI__c> contacts {get;set;}
      
  public String contactCountDetails{
    get { 
         integer cnt=0;
         if (contacts != null){
            cnt = contacts.size();
            } 
           return 'Record Count: ' + cnt;  
         }
    set;
  }//end method contactCountDetails
     
    
  public Integration_BCII_FBI_Lookup_Ctrl() {
      soql = '';
  }//end constructor

  // runs the actual query
  public void runQuery() {
    try {
          if (!String.isBlank(soql)){contacts = Database.query(soql + ' order by CLQ_Last_Name__c asc  LIMIT 100');}
    } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  e.getMessage()));
    }//end catch
  }//end runQuery

  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
    String firstName = Apexpages.currentPage().getParameters().get('firstname').trim();
    String lastName = Apexpages.currentPage().getParameters().get('lastname').trim();
    String middleName = Apexpages.currentPage().getParameters().get('middlename').trim();
    String dob= Apexpages.currentPage().getParameters().get('dob').trim();
    String ssn = Apexpages.currentPage().getParameters().get('ssn').trim();
    
    /**********Code commented as a part of Sheild Encrytion enabled    
    soql = 'Select Id, CLQ_Record_Check_Results__c,CLQ_Last_Name__c,CLQ_First_Name__c,CLQ_Middle_Name__c,CLQ_Date_of_Birth__c,CLQ_Date_Received_At_BCI__c,CLQ_Last_Four_Digits_of_SSN__c,CLQ_Transaction_Authentication__c,CLQ_Transaction_Type__c,CLQ_Result_Type__c from CLQ_BCII_FBI__c ';
    String whereClause='';
        
    if (!String.isBlank(firstName)){
          if (!String.isBlank(whereClause)){
              whereClause += ' and CLQ_First_Name__c LIKE \'' + String.escapeSingleQuotes(firstName) + '%\' ';
          }else{
              whereClause = ' where CLQ_First_Name__c LIKE \'' + String.escapeSingleQuotes(firstName) + '%\' ';
          }
    }//end if firstName          
    
    if (!String.isBlank(lastName)){    
        if (!String.isBlank(whereClause)){ 
              whereClause += ' and CLQ_Last_Name__c LIKE \'' + String.escapeSingleQuotes(lastName) + '%\' ';
        } else {       
              whereClause = ' where CLQ_Last_Name__c LIKE \'' + String.escapeSingleQuotes(lastName) + '%\' ';
        }
    }//end if lastname      
      
      
    if (!String.isBlank(middleName)){    
       if (!String.isBlank(whereClause)){ 
            whereClause  += ' and CLQ_Middle_Name__c LIKE \'' + String.escapeSingleQuotes(middleName) + '%\' ';
      }else{
            whereClause  += ' where CLQ_Middle_Name__c LIKE \'' + String.escapeSingleQuotes(middleName) + '%\' ';
      }
    }//end if middleName  
    
    if (!String.isBlank(dob)){    
        if (!String.isBlank(whereClause)){ 
             whereClause += ' and CLQ_Date_of_Birth__c=' + String.escapeSingleQuotes(dob) + ' ';
        }else{
             whereClause += ' where CLQ_Date_of_Birth__c=' + String.escapeSingleQuotes(dob) + ' ';
        }
    }//end if dob
    
    if (!String.isBlank(last4SSN)){    
        if (!String.isBlank(whereClause)){ 
            whereClause += ' and CLQ_Last_Four_Digits_of_SSN__c LIKE \'' + String.escapeSingleQuotes(last4SSN) + '%\' ';
        } else{
            whereClause += ' where CLQ_Last_Four_Digits_of_SSN__c LIKE \'' + String.escapeSingleQuotes(last4SSN) + '%\' ';
        }
    }//end if last 4 ssn
    
    soql = soql + ' ' + whereClause;
    System.debug('**soql = ' + soql);
    runQuery(); */
    
    String searchString = '';
    if(firstName != null && String.isNotBlank(firstName)){
        searchString =+ '("' + firstName + '") AND ';    
    }
    if(lastName != null && String.isNotBlank(lastName)){
        searchString =+ '("' + lastName + '") AND ';    
    }
    if(middleName != null && String.isNotBlank(middleName)){
        searchString =+ '("' + middleName + '") AND ';    
    }
    if(dob != null && String.isNotBlank(dob)){
        searchString =+ '("' + dob + '") AND ';    
    }
    if(ssn != null && String.isNotBlank(ssn)){
        searchString =+ '("' + ssn + '") AND ';    
    }
    
    String finalSearchString = '';
    if(String.isNotBlank(searchString)){
        finalSearchString = searchString.removeEnd(' AND ');
    }
    System.debug('********searchString********'+searchString); 
    System.debug('********finalSearchString********'+finalSearchString); 
    
    try {
        List<List<SObject>> searchResults = new List<List<SObject>>();
        if(String.isNotBlank(finalSearchString)){
            searchResults = [FIND :finalSearchString IN ALL FIELDS RETURNING CLQ_BCII_FBI__c(Id, CLQ_Record_Check_Results__c,CLQ_Last_Name__c,CLQ_First_Name__c,CLQ_Middle_Name__c,CLQ_Date_of_Birth__c,CLQ_Date_Received_At_BCI__c,CLQ_SSN_Integration__c,CLQ_Transaction_Authentication__c,CLQ_Transaction_Type__c,CLQ_Result_Type__c) LIMIT 100];
            System.debug('********searchResults********'+searchResults);
            if(searchResults != null && !searchResults.isEmpty()){
                contacts = ((List<CLQ_BCII_FBI__c>)searchResults[0]);
            }
        }  else {
            //situation when user did not had any search parameter
            soql = 'Select Id, CLQ_Record_Check_Results__c,CLQ_Last_Name__c,CLQ_First_Name__c,CLQ_Middle_Name__c,CLQ_Date_of_Birth__c,CLQ_Date_Received_At_BCI__c,CLQ_SSN_Integration__c,CLQ_Transaction_Authentication__c,CLQ_Transaction_Type__c,CLQ_Result_Type__c from CLQ_BCII_FBI__c ';
            contacts = Database.query(soql + ' order by CLQ_Last_Name__c asc  LIMIT 100');            
        } //end if 
        //call cpi class with contacts as a parameter
        CLQ_CPITracking_Util.logBCIFields(contacts);
    } catch (Exception e){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }//end catch
    
    return null;
  }//end method
  
  
  public List<Integer> dob_Year {
    get {
          List<Integer> dobYY = new List<Integer>();
          Integer currentYear = Date.Today().Year();
          for(Integer i = currentYear; i>=1910;i--) {dobYY.add(i);}
          return dobYY;          
        }
    set;
  }//end dob_Year
  
  
  public List<String> dob_Month {
    get {
          List<String> dobMM = new List<String>();
          for(Integer i = 1; i<=12;i++){if (i <10){dobMM.add('0' +i);}else{dobMM.add(i +'');}}
          return dobMM;          
        }
    set;
  }//end dob_Month
  
  public List<String> dob_Day {
    get {
          List<String> dobDD = new List<String>();
          for(Integer i = 1; i<=31;i++){if (i <10){dobDD.add('0' +i);}else{dobDD.add(i +'');}}
          return dobDD;          
    }
    set;
  }//end dob_Day
}//end class