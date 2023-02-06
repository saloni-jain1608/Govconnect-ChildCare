/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_AnswerTriggerHandler 
** Description      : This class contains all detail logic/methods for Answer object's trigger. Methods are being 
**					  called from CLQ_AnswerTrigger 
** 
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**	Developer				Date			Version			Description
**	Rohit Gowrishetty		5/11/2018		1.1				TFS : 12079 - Added the functionality to not show 4 or 5 rating when any one of 4 domains has 0 rating 
**	Soufin Rahimeen			07/12/2018		1.2				TFS: 12496 - Added functionality to delete old documents when answer is changed
**  Rohit Gowrishetty		11/20/2018		1.3				TFS#14858, 14913, 14917 : Added logic to bypass to different logic for three SUTQs
**  Vijay Gurusamy			11/20/2018		1.4				9480 - Add number type to Question type list
**************************************************************************************************************/

public with sharing class CLQ_AnswerTriggerHandler extends CLQ_Trigger
{
    public static final string SUTQ_Initial_Registration='SUTQ - Initial Registration';
    public static final string SUTQ_Ongoing_Registration='SUTQ - Ongoing Registration';
    public static final string SUTQ_Annual_Report='SUTQ - Annual Report';
    public static final string JFS_OCLQS_Food_Service_License='JFS - OCLQS - Food Service License';
    public static final string JFS_OCLQS_Food_License_Exemption='JFS - OCLQS - Food License Exemption';
    public static final string JFS_OCLQS_Food_License='JFS - OCLQS - Food License';
    public static final string Food_Service_License_Exemption='Food Service License Exemption';
    public static final string Food_Service_License='Food Service License';
    public static final string CLQ_Child_Care_Center='CLQ_Child_Care_Center';
    public static final string CLQ_Pre_School='CLQ_Pre_School';
    public static final string CLQ_School_Age_Child_Care='CLQ_School_Age_Child_Care';
    public static final string CLQ_Type_A_Home='CLQ_Type_A_Home';
    public static final string CLQ_FCC_Type_B_Home='CLQ_FCC_Type_B_Home';
    public static final string SD67='SD-00067';
    public static final string SD76='SD-00076';
    public static final string SD170='SD-00170';
    public static final string SD66= 'SD-00066';
    public static final string Empty='';
    public static final string Three='3';
    public static final string Four='4';
    public static final string Five='5';
    
    public static final string N_A = 'N/A';
    public static final string SUTQ_Expedited_Registration = 'SUTQ_Expedited_Registration';
    public static final string SUTQ_Change_of_Owner_Registration = 'SUTQ_Change_of_Owner_Registration';
    public static final string SUTQ_Reinstate_Rating_after_Temporary_Closure = 'SUTQ_Reinstate_Rating_after_Temporary_Closure';
    public static final string Administrative_Leadership_Practices = 'Administrative & Leadership Practices';
    public static final string Family_Community_Partnerships = 'Family & Community Partnerships';
    public static final string Learning_Development = 'Learning & Development';
    public static final string Staff_Qualifications_Professional_Development = 'Staff Qualifications & Professional Development';
    
    
    
    //  'QuetionNumber' => 'TansactionField'
    public static final map<string,string> QuetionMap = new map<string,string>{
        
        'SDL-00043' => 'CLQ_Is_the_Day_Camp_ACA_Certified__c',
            'SDL-00065' => 'CLQ_Name_of_Day_Camp_on_ACA_Certificate__c',
            'SDL-00005' => 'CLQ_Age_Groups_Served_Global__c',
            'SDL-00035' => 'CLQ_Food_Service__c'
            //added by Srikanth for OJLS-1208
            //'SDL-00005' => 'CLQ_Age_Groups_Served_Global__c'
            };      
                
                //Allows only this trigger to be bypassed. Useful in Unit Test data setup and some bulk data loads.
                public static boolean BypassTrigger
            {
                get
                {
                    if (BypassTrigger == null){
                        BypassTrigger = false;
                    }
                    return BypassTrigger;
                }
                set;
            }
    
    //Calls the Base class Constructor
    public CLQ_AnswerTriggerHandler(list < sObject > newlistin, map < id, sObject > newMapin, list < sObject > oldlistin, map < id, sObject > oldMapin,
                                    boolean isExecutingin, boolean isInsertin, boolean isUpdatein, boolean isDeletein,
                                    boolean isBeforein, boolean isAfterin, boolean isUndeletein, integer sizein)
    { 
        
        
        super(newlistin, newMapin, oldlistin, oldMapin,
              isExecutingin, isInsertin, isUpdatein, isDeletein,
              isBeforein, isAfterin, isUndeletein, sizein);
        
        BypassInheritedTrigger = BypassTrigger;
        if(!(BypassInheritedTrigger || BypassAllTriggers)){            
            BypassInheritedTrigger = BypassSelectiveTriggers;
        }
        //BypassInheritedTrigger = ByPassTrigger
    }
    //After insert logic method
    //@param : triggerold, triggeroldmap,triggernew, triggernewmap
    //@return : null
    public override void afterinsert(){
        updateProgramTransaction((list < Answer__c > ) newlist, (map < id, Answer__c > ) newMap);
        deleteSUTQTransactionDocuments((list < Answer__c > ) newlist, (map < id, Answer__c > ) newMap); //12496
    }
    
    public override void afterupdate(){
        if (CheckRecursive.runOnce()){    
            updateProgramTransaction((list < Answer__c > ) newlist, (map < id, Answer__c > ) newMap);   
        }
    }
    public override void beforeinsert(){
        updateRatingsPoints((List < Answer__c > ) newList);
        updateRatingsPointsAnil((List < Answer__c > ) newList);
    }
    public override void beforeupdate(){
        updateRatingsPoints((List < Answer__c > ) newList);
        updateRatingsPointsAnil((List < Answer__c > ) newList);
    }
    
    public override void beforedelete(){
        
        checkTransactionDocFoodLicense((list < Answer__c > ) oldList, (map < id, Answer__c > ) oldMap);
    }
    
    //12496 - deletes old documents when answer is changed
    public void deleteSUTQTransactionDocuments(List<Answer__c> newList, map<id, Answer__c> newMap) {
        
        Map<Id,String> mapPTAnswer = new Map<Id,String>();
        Map<Id, String> mapCurrentQuestionAnswer = new Map<Id, String>();
        Map<Id, List<String>> mapQuestionAnswer = new Map<Id, List<String>>();
        List<CLQ_Transaction_Document__c> tdToBeDeleted = new List<CLQ_Transaction_Document__c>();
        List<String> SUTQRecordTypes = new List<String>{SUTQ_Initial_Registration, SUTQ_Ongoing_Registration, SUTQ_Annual_Report};
            
            for(Answer__c a : newList) {
                if(a.Answer_Text__c != null && a.Answer_Text__c != Empty && (a.Answer_Text__c != Food_Service_License && a.Answer_Text__c != Food_Service_License_Exemption)) {
                    mapPTAnswer.put(a.Program_Transaction__c,a.Answer_Text__c);
                }
            }
       
        if(!mapPTAnswer.isEmpty()){
            for(Answer__c a : [SELECT Id, AssociatedQuestion__c,Answer_Text__c
                               FROM Answer__c
                               WHERE Program_Transaction__c in : mapPTAnswer.keyset()
                               AND Program_Transaction__r.clq_recordtypename__c IN: SUTQRecordTypes]) { //pick only SUTQ answers  
                                   
                                   List<String> lstPTAnswers = a.Answer_Text__c.split(';');     														
                                   mapQuestionAnswer.put(a.AssociatedQuestion__c, lstPTAnswers);	
                               }
            
            
            
            //Fetch all related child questions
            if(mapQuestionAnswer.size() > 0){
                for(CLQ_Standard_Detail__c sd : [SELECT Id, CLQ_TriggeringAttachmentValue__c, CLQ_ParentQuestion__c
                                                 FROM CLQ_Standard_Detail__c
                                                 WHERE CLQ_ParentQuestion__c IN: mapQuestionAnswer.keySet()]) {
                                                     
                                                     if(mapQuestionAnswer.containsKey(sd.CLQ_ParentQuestion__c) && sd.CLQ_TriggeringAttachmentValue__c != null) {
                                                         List<String> listAllAnswers = sd.CLQ_TriggeringAttachmentValue__c.split(';');
                                                         List<String> lstPTAnswers = mapQuestionAnswer.get(sd.CLQ_ParentQuestion__c);
                                                         
                                                         for(String ans : lstPTAnswers){
                                                             if(listAllAnswers.contains(ans)){
                                                                 mapCurrentQuestionAnswer.put(sd.Id, sd.CLQ_TriggeringAttachmentValue__c);	
                                                             }
                                                         }
                                                     }
                                                 }
            }
         
            //make sure not to query documents which are not from Answers (such as from table comp)
            List<CLQ_Transaction_Document__c> transDocs = [SELECT Id,CLQ_Standard_Detail_Document__c,CLQ_Standard_Detail_Document__r.CLQ_TriggeringAttachmentValue__c
                                                           FROM CLQ_Transaction_Document__c 
                                                           WHERE CLQ_Program_Transaction__c in : mapPTAnswer.keyset()
                                                           AND CLQ_Program_Transaction__r.clq_recordtypename__c IN: SUTQRecordTypes]; //make sure only SUTQ documents are here
            
          
            for(CLQ_Transaction_Document__c td : transDocs) {
                
                //system.debug('td question--->' + td.CLQ_Standard_Detail_Document__c + ' td answer-->' + td.CLQ_Standard_Detail_Document__r.CLQ_TriggeringAttachmentValue__c);
                
                if(mapCurrentQuestionAnswer.containsKey(td.CLQ_Standard_Detail_Document__c) && (mapCurrentQuestionAnswer.get(td.CLQ_Standard_Detail_Document__c) != td.CLQ_Standard_Detail_Document__r.CLQ_TriggeringAttachmentValue__c)){
                    
                    tdToBeDeleted.add(td);
                    
                }else{
                    //tdToBeDeleted.add(td);
                }
            }
            
            //system.debug('Docs to delete size---- '+tdToBeDeleted.size() +'--Docs to delete ---> '+tdToBeDeleted);
            
            if(!tdToBeDeleted.isEmpty()) {
                try {
                    delete tdToBeDeleted;
                } catch (Exception e) {
                    Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_AnswerTriggerHandler');         
                }
            }
        }
    }
    
    
    public void checkTransactionDocFoodLicense(List < Answer__c> oldList,map < id, Answer__c > triggeroldmap ) {
        List<Id> pts = new List<Id>();
        List<String> answers = new List<String>();
        Map<Id,String> answerMap = new Map<Id,String>();
        for(Answer__c a : oldList) {
            pts.add(a.Program_Transaction__c);
            if(a.Answer_Text__c != null && a.Answer_Text__c != Empty && (a.Answer_Text__c == Food_Service_License || a.Answer_Text__c == Food_Service_License_Exemption)) {
                answers.add(a.Answer_Text__c);
                answerMap.put(a.Program_Transaction__c,a.Answer_Text__c);
            }
        }
        // Updated for 10476 - Adding a document type for cleaning up the food license 
        List<CLQ_Transaction_Document__c> transDocs;
        List<String> docTypes = new List<String> {JFS_OCLQS_Food_Service_License,JFS_OCLQS_Food_License_Exemption,JFS_OCLQS_Food_License};
            if(answerMap.keyset() != null && docTypes!=null){
                transDocs = [Select Id,CLQ_Program_Transaction__c,Document_Type__c 
                             from CLQ_Transaction_Document__c 
                             where CLQ_Program_Transaction__c in : answerMap.keyset() 
                             and Document_Type__c in : docTypes];
            }
        
        List<CLQ_Transaction_Document__c> tdToBeDeleted = new List<CLQ_Transaction_Document__c>();
        for(CLQ_Transaction_Document__c td : transDocs) {
            if(answerMap.size()!=0 && answerMap.keySet().contains(td.CLQ_Program_Transaction__c) && (td.Document_Type__c == JFS_OCLQS_Food_License_Exemption 
                                                                                                     && answerMap.get(td.CLQ_Program_Transaction__c) == Food_Service_License_Exemption) 
               || ((td.Document_Type__c == JFS_OCLQS_Food_Service_License || td.Document_Type__c == JFS_OCLQS_Food_License) 
                   && answerMap.get(td.CLQ_Program_Transaction__c) == Food_Service_License) ) {
                       
                       tdToBeDeleted.add(td);
                       
                   }
        }
        
        if(!tdToBeDeleted.isEmpty()) { //updated with try catch
            try {
                delete tdToBeDeleted;
                system.debug('tdToBeDeleted: '+tdToBeDeleted); 
            } catch (Exception e) {
                
                Integration_Transaction_Logs.LogError('SFDC-001.2', e.getMessage() ,'' ,String.valueOf(e.getLineNumber()),'','Salesforce Exception -- CLQ_AnswerTriggerHandler');         
            }
            
        }
        
    }
    //Method that calculates the ratings/points/met-not met criteria 
    //for an answer record upon insert + update action
    public void updateRatingsPoints(List < Answer__c > newList)
    {
        //Set of questions assosciated to the answers we have
        Set < Id > questionIds = new Set < Id > ();
        for (Answer__c ans: newList)
        {
            questionIds.add(ans.AssociatedQuestion__c);
        } //end for loop
        //set of question types we want to perform logic on
        Set < String > questionTypes = new Set < String >{'Text','Multiple Options','Picklist','Number'};
      
        //get list of questions related to the answer(s) with required fields
        List < CLQ_Standard_Detail__c > standardDetails;
        if(questionIds != null && questionTypes!=null){
            standardDetails = [SELECT CLQ_QuestionType__c, CLQ_Met_Not_Met__c, Domain__c, CLQ_PossibleResponses__c, Possible_Points__c, Possible_Ratings__c, Id
                               FROM CLQ_Standard_Detail__c
                               WHERE Id IN: questionIds AND CLQ_QuestionType__c IN: questionTypes
                              ];
        }
        
        
        //for all the relevant answers, we store the allowed answers, domain, ratings, points and met/not-met
        //into a map identified by the question id
        Map < Id, QuestionAnswerWrapper > questionDetails = new Map < Id, QuestionAnswerWrapper > ();
        for (CLQ_Standard_Detail__c question: standardDetails)
        {
            QuestionAnswerWrapper qaw = new QuestionAnswerWrapper();
            qaw.allowedAnswers = sanityCheck(question.CLQ_PossibleResponses__c).split(';');
            qaw.allowedRatings = sanityCheck(question.Possible_Ratings__c).split(';');
            qaw.domain = sanityCheck(question.Domain__c);
            qaw.allowedPoints = sanityCheck(question.Possible_Points__c).split(';');
            qaw.metNotMet = sanityCheck(question.CLQ_Met_Not_Met__c).split(';');
            questionDetails.put(question.Id, qaw);
            
            
            
        } //end for loop
        //loop through answers we want to update fields on
        for (Answer__c answer: newList)
        {
            //get the question id
            //get allowed answers and compare to current answer to get index
            //use that index to get ratings or points or met/not met
            QuestionAnswerWrapper sourceQuestionRecordDetails;
            if(questionDetails.size()!=0){
                sourceQuestionRecordDetails = questionDetails.get(answer.AssociatedQuestion__c);
            }
            
            List < String > allowedAnswers = sourceQuestionRecordDetails.allowedAnswers;
            Integer answerIndex = -1;
            if (allowedAnswers != null)
            {
                for (integer i = 0; i < allowedAnswers.size(); i++)
                {
                    if (allowedAnswers.size()!=0 && allowedAnswers.get(i).deleteWhiteSpace().equalsIgnorecase(answer.Answer_Text__c.deleteWhitespace()))
                    {
                        answerIndex = i;
                        break;
                    } //end if
                } //end for loop
            } //end if
            //System.debug('index of answer we want is = ' + answerIndex + ' for QuestionAnswerWrapper:' + sourceQuestionRecordDetails);
            List < String > msList = sourceQuestionRecordDetails.metNotMet;
            List < String > allowedPoints = sourceQuestionRecordDetails.allowedPoints;
            List < String > allowedRatings = sourceQuestionRecordDetails.allowedRatings;
            //System.debug('@@@@mSList = ' + msList + ' @@@@allowedPoints = ' + allowedPoints + ' @@@@allowedRatings ' + allowedRatings);
            String ms = null;
            String points = null;
            String ratings = null;
            //Logic:                                         
            //IF 1 of 3 fields is NOT NULL||N/A||''  Update that field                    
            //(3 fields being Met/Not Met, Ratings, Points) 
            //High level case - check if AnswerIndex >= 0 
            if (answerIndex >= 0)
            {
                //case 1 - update Met/Not Met from mSList into ms field
                if (msList.size() > answerindex && !String.isBlank(msList[answerIndex]) && !msList[answerIndex].equals(N_A))
                {
                    //we know that Met/Not Met needs to be Updated
                    if (msList.size()!=0 && msList.size() > answerIndex)
                    {
                        ms = msList.get(answerIndex);
                    } //end if
                    
                }//case 2 -update Points from allowedPoints list into points field
                else if (allowedPoints.size() > answerindex && !String.isBlank(allowedPoints[answerIndex]) && !allowedPoints[answerIndex].equals(N_A))
                {
                    //we know that Points needs to be Updated
                    if (allowedPoints.size() > answerIndex)
                    {
                        points = allowedPoints[answerIndex];
                    } //end if
                    
                }//case 3 - update Ratings from allowedRatings list into ratings field
                else if (allowedRatings.size() > answerindex && !String.isBlank(allowedRatings[answerIndex]) && !allowedRatings[answerIndex].equals(N_A))
                {
                    if (allowedRatings.size() > answerIndex)
                    {
                        ratings = allowedRatings[answerIndex];
                    } //end if
                } //end else if blocks
            }
            else
            {
                //System.debug('@@CLQ_AnswerTriggerHandler.updateRatingsPoints -- None of the criteria met, check data again');
            } //end else
            
            if (ms != null && ms != Empty)
            {
                answer.Met_Not_Met__c = ms;
                
            } //end if
            if (ratings != Empty && ratings != null)
            {
                answer.Rating_Number__c = Decimal.valueOf(ratings);
                
            } //end if
            if (points != Empty && points != null)
            {
                answer.Points__c = Decimal.valueOf(points);
                
            } //end if  
            
        } //for loop end
    } //method end
    
    
    //method to update the ratings or points on a newly created answer record
    //Method to insert   
    //@param : 
    //@return :
    //JPC 10/28/2016 - Updated to set values from answers onto the ProgramTransaction
    public void updateProgramTransaction(list < Answer__c > triggernew, map < id, Answer__c > triggernewmap)
    {
        //Get all the record type in a local map so that it can be accessed without describe object
        Schema.DescribeSObjectResult d = Schema.SObjectType.CLQ_Program__c;
        Map < String, Schema.RecordTypeInfo > rtMapByName = d.getRecordTypeInfosByDeveloperName();
        //Define a set of program transaction ids
        Set < Id > prgmTrnIdSet = new Set < Id > ();
        //Define a map of answer id to program Id
        Map < Id, Id > answerToPrgmIdMap = new Map < Id, Id > ();
        //Define a map of anwer Id to program
        Map < Id, CLQ_Program_Transaction__c > ansrIdToPrgMap = new Map < Id, CLQ_Program_Transaction__c > ();
        for (Answer__c ans: triggernew)
        {
            if (ans.Program_Transaction__c != null)
            {
                answerToPrgmIdMap.put(ans.Id, ans.Program_Transaction__c);
            }
        }
        ////Define a map of program Id to program
        Map < Id, CLQ_Program_Transaction__c > prgrmIdToPrgMap = new Map < Id, CLQ_Program_Transaction__c > ();
        //Define a all answer rating list 
        List < Answer__c > ansRatingList = new List < Answer__c > ();
        if (!answerToPrgmIdMap.isEmpty())
        {
            //JPC - Added more fields for update interview questions 10/28/2016
            //Had to make this a dynamic query because QuetionMap could be updated later
            /*
string query = 'SELECT Id, Rating_Estimated_By_System__c, CLQ_Program__c, CLQ_Program__r.RecordTypeId,' +
string.join(QuetionMap.values(),',') +
', (select Id, Rating_Number__c, points__c, Program_Transaction__c, Domain_Name__c,Name,AssociatedQuestion__r.Name, Answer_Text__c from Answers__r) ' +
' FROM CLQ_Program_Transaction__c  WHERE Id in: answerToPrgmIdMap.values() ';
system.Debug('updateProgramTransaction:query: ' + query);
list<CLQ_Program_Transaction__c> PreMapList = (list<CLQ_Program_Transaction__c>) database.query(query);
prgrmIdToPrgMap = new Map < ID, CLQ_Program_Transaction__c > (PreMapList);
*/			
            //14858 - Added recordtype id
            prgrmIdToPrgMap = new Map < ID, CLQ_Program_Transaction__c > (
                [SELECT Id,recordTypeId, Rating_Estimated_By_System__c, CLQ_Program__c, CLQ_Program__r.RecordTypeId,
                 CLQ_Food_Service__c,CLQ_Is_the_Day_Camp_ACA_Certified__c,CLQ_Name_of_Child_Day_Camp__c,CLQ_Name_of_Day_Camp_on_ACA_Certificate__c,CLQ_Age_Groups_Served_Global__c,
                 (select Id, Rating_Number__c, points__c, Program_Transaction__c, Domain_Name__c,
                  Name,AssociatedQuestion__r.Name, Answer_Text__c
                  from Answers__r LIMIT 1999)
                 FROM CLQ_Program_Transaction__c
                 WHERE Id in: answerToPrgmIdMap.values()
                ]);
            
        }
        Id programRecTypeId = null;
        Integer DomRating = 0;
        Decimal lowestRatingNumber;
        Id SUTQExpeditedRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(SUTQ_Expedited_Registration).getRecordTypeId(); //14858
        Id SUTQChangeOfOnwerRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(SUTQ_Change_of_Owner_Registration).getRecordTypeId(); //14913
        Id SUTQRatingReinstateRecID = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get(SUTQ_Reinstate_Rating_after_Temporary_Closure).getRecordTypeId(); //14917
        
        //Map to update program
        Map < Id, CLQ_Program_Transaction__c > ProgTransUpdateMap = new Map < Id, CLQ_Program_Transaction__c > ();        
        for (Answer__c answer: triggernew)
        {
            //if(Trigger.isInsert || Trigger.isUpdate) {
            if (answer.Program_Transaction__c != null && prgrmIdToPrgMap.size()!=0)
            {
                CLQ_Program_Transaction__c ProgramTransaction = prgrmIdToPrgMap.get(answer.Program_Transaction__c);
                if (ProgramTransaction != null)
                {
                    // fetching answer records where rating!= null
                    List < Answer__c > RatingList = ProgramTransaction.Answers__r;
                    //14858
                    if(ProgramTransaction.recordTypeId == SUTQExpeditedRecID || ProgramTransaction.recordTypeId == SUTQChangeOfOnwerRecID || ProgramTransaction.recordTypeId == SUTQRatingReinstateRecID ){
                        
                        lowestRatingNumber = -1;
                        for (Answer__c OneOfTheAnswers: RatingList)
                        {
                            if (OneOfTheAnswers.Rating_Number__c != null && (lowestRatingNumber == -1 || lowestRatingNumber > OneOfTheAnswers.Rating_Number__c)) //12079
                            {
                                lowestRatingNumber = OneOfTheAnswers.Rating_Number__c;
                                
                            }
                            
                            ProgramTransaction.Rating_Estimated_By_System__c = String.valueOf(lowestRatingNumber);
                            ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                            
                        }
                    }else{
                        
                        //12079 starts
                        
                        Decimal A_LP_Domain_Points = getPoints(RatingList, Administrative_Leadership_Practices);
                        Decimal F_CP_Domain_Points = getPoints(RatingList, Family_Community_Partnerships);
                        Decimal Learning_And_Development_Domain_Points = getPoints(RatingList, Learning_Development);
                        Decimal SQ_PD_Domain_Points = getPoints(RatingList, Staff_Qualifications_Professional_Development);
                        
                        
                        //12079 ends
                        
                        //Getting program from PT
                        programRecTypeId = ProgramTransaction.CLQ_Program__r.RecordTypeId;
                        
                        DomRating = 0;
                        lowestRatingNumber = -1;
                        for (Answer__c OneOfTheAnswers: RatingList)
                        {
                            if (OneOfTheAnswers.Points__c != null)
                            {
                                DomRating = DomRating + Integer.valueof(OneOfTheAnswers.Points__c);
                                
                            }
                            if (OneOfTheAnswers.Rating_Number__c != null && (lowestRatingNumber == -1 || lowestRatingNumber > OneOfTheAnswers.Rating_Number__c)) //12079
                            {
                                lowestRatingNumber = OneOfTheAnswers.Rating_Number__c;
                                
                            }
                            
                        }
                        
                        //This call gets answers and sets corresponding values in the ProgramTransaction
                        //JPC 10/28/2016                        
                        /*if (SetAnswerValues(ProgramTransaction, ProgramTransaction.Answers__r))
{                        
System.debug('pt>>>'+ProgramTransaction.CLQ_Age_Groups_Served_Global__c);
ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
}*/
                        Boolean WasChanged = false;
                        for(Answer__c ans:ProgramTransaction.Answers__r){
                            string QuetionName = ans.AssociatedQuestion__r.Name;
                            if (QuetionMap.containsKey(QuetionName))
                            {
                                string fieldName = QuetionMap.get(QuetionName);
                                string AnswerValue = ans.Answer_Text__c;
                                string CurrentPTValue = string.ValueOf(ProgramTransaction.get(fieldName));
                                // System.debug('question map>>'+QuetionName+'>>>'+fieldname+'>>>'+Answervalue+'>>>'+ProgramTransaction.get(fieldName)+'>>>'+currentPTValue);
                                if (AnswerValue != CurrentPTValue)
                                {
                                    //system.debug('Changing ProgramTransaction value for Question: ' + QuetionName + '  FROM ' + CurrentPTValue + ' TO ' + AnswerValue);
                                    WasChanged = true;
                                    ProgramTransaction.put(fieldName,AnswerValue);
                                }
                            }                        
                        }
                        if(WasChanged){
                            ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);      
                        }
                        
                        //System.debug('Answer point ' + answer.Points__c + ' lowest rating ' + String.valueOf(lowestRatingNumber));
                        // if (answer.Points__c != null && lowestRatingNumber == 3)
                        if (lowestRatingNumber == 3)
                        {
                            //List<Answer__c> DomainRatingList =  [select id, Rating_Number__c,points__c, Program_Transaction__c 
                            //from Answer__c where Program_Transaction__c =: answer.Program_Transaction__c AND points__c != null];   
                            if (rtMapByName.size()!=0 && DomRating >= 35 && DomRating <= 55 && (programRecTypeId == rtMapByName.get(CLQ_Child_Care_Center).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_Pre_School).getRecordTypeId()||programRecTypeId == rtMapByName.get(CLQ_School_Age_Child_Care).getRecordTypeId() ))
                            {
                                if(A_LP_Domain_Points == 0 || F_CP_Domain_Points == 0 || Learning_And_Development_Domain_Points == 0 || SQ_PD_Domain_Points == 0 ) {
                                    ProgramTransaction.Rating_Estimated_By_System__c = Three;
                                }
                                else{
                                    ProgramTransaction.Rating_Estimated_By_System__c = Four;
                                }
                                
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                                
                            }
                            else if (rtMapByName.size()!=0 && DomRating > 55 && (programRecTypeId == rtMapByName.get(CLQ_Child_Care_Center).getRecordTypeId() || programRecTypeId == rtMapByName.get(CLQ_Pre_School).getRecordTypeId()||programRecTypeId == rtMapByName.get(CLQ_School_Age_Child_Care).getRecordTypeId() ))
                            {
                                if(A_LP_Domain_Points == 0 || F_CP_Domain_Points == 0 || Learning_And_Development_Domain_Points == 0 || SQ_PD_Domain_Points == 0 ){
                                    ProgramTransaction.Rating_Estimated_By_System__c = Three; 
                                }
                                else{
                                    ProgramTransaction.Rating_Estimated_By_System__c = Five;
                                }  
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                                
                            }
                            else if (rtMapByName.size()!=0 && (DomRating >= 30 && DomRating <= 45) && (programRecTypeId == rtMapByName.get(CLQ_Type_A_Home).getRecordTypeId() ||
                                                                                                       programRecTypeId == rtMapByName.get(CLQ_FCC_Type_B_Home).getRecordTypeId()))
                            {
                                //if (programRecTypeId == rtMapByName.get('CLQ_Type_A_Home').getRecordTypeId() ||
                                //    programRecTypeId == rtMapByName.get('CLQ_FCC_Type_B_Home').getRecordTypeId())
                                //{
                                if(A_LP_Domain_Points == 0 || F_CP_Domain_Points == 0 || Learning_And_Development_Domain_Points == 0 || SQ_PD_Domain_Points == 0 ){
                                    ProgramTransaction.Rating_Estimated_By_System__c = Three; 
                                }   
                                else{
                                    ProgramTransaction.Rating_Estimated_By_System__c = Four;
                                }
                                
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                                
                                // }
                            }
                            else if (rtMapByName.size()!=0 && DomRating > 45 && (programRecTypeId == rtMapByName.get(CLQ_Type_A_Home).getRecordTypeId() ||
                                                                                 programRecTypeId == rtMapByName.get(CLQ_FCC_Type_B_Home).getRecordTypeId()))
                            {
                                if(A_LP_Domain_Points == 0 || F_CP_Domain_Points == 0 || Learning_And_Development_Domain_Points == 0 || SQ_PD_Domain_Points == 0 ){
                                    ProgramTransaction.Rating_Estimated_By_System__c = Three; 
                                }
                                else{
                                    ProgramTransaction.Rating_Estimated_By_System__c = Five;
                                }
                                
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                                
                            }
                            else if (lowestRatingNumber == 3)
                            {
                                ProgramTransaction.Rating_Estimated_By_System__c = string.valueof(lowestRatingNumber);
                                //update Pt;
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                            }
                        }
                        else
                        {
                            if (lowestRatingNumber >= 0)
                            {
                                ProgramTransaction.Rating_Estimated_By_System__c = String.valueOf(lowestRatingNumber);
                                //update Pt;
                                ProgTransUpdateMap.put(ProgramTransaction.Id, ProgramTransaction);
                            }
                        }
                        
                    }
                    
                    
                } //end of prgTn not null check
            } //end of prgTn id not null check
        } // for end
        if (!ProgTransUpdateMap.isEmpty())
        {
            try
            {
                boolean PreviousValue = CLQ_Trigger.BypassAllTriggers;
                CLQ_Trigger.BypassAllTriggers = true;
                update ProgTransUpdateMap.values();
                CLQ_Trigger.BypassAllTriggers = PreviousValue;
            }
            catch (DmlException de)
            {
                System.debug(de.getMessage());
                //if(de.getMessage().contains('You can not edit this record when approval status is in Pending/Approved'))
                //answer.addError('You can not edit this record when approval status is in Pending/Approved');
            }
            catch (Exception e)
            {
                e.getMessage();
                
            }
        }
    } //end of the method
    
    //12079 starts -  This method is used to get the domain wise total points of a transaction
    public Decimal getPoints(List<Answer__c> ansList, String domain){
        Decimal points = 0;
        
        for(Answer__c ans : ansList){
            if(ans.Points__c != NULL  && domain.equals(ans.Domain_Name__c)){
                points = points + ans.Points__c;
            }
        }
        //system.debug('domain ---'+domain+'---Points---'+points);
        return points;
    }
    //12079 ends 
    
    
    public boolean SetAnswerValues(CLQ_Program_Transaction__c ProgramTransaction, list<Answer__c> AllAnswers)
    {
        boolean WasChanged = false;
        
        for(Answer__c answer : AllAnswers)
        {
            string QuetionName = answer.AssociatedQuestion__r.Name;
            if (QuetionMap.containsKey(QuetionName))
            {
                string fieldName = QuetionMap.get(QuetionName);
                string AnswerValue = answer.Answer_Text__c;
                string CurrentPTValue = string.ValueOf(ProgramTransaction.get(fieldName));
                //System.debug('question map>>'+QuetionName+'>>>'+fieldname+'>>>'+Answervalue+'>>>'+ProgramTransaction.get(fieldName)+'>>>'+currentPTValue);
                if (AnswerValue != CurrentPTValue)
                {
                    //system.debug('Changing ProgramTransaction value for Question: ' + QuetionName + '  FROM ' + CurrentPTValue + ' TO ' + AnswerValue);
                    WasChanged = true;
                    ProgramTransaction.put(fieldName,AnswerValue);
                }
            }
        }
        
        return WasChanged;
    }
    
    //custom data type for handling rating/points/met-not met calculation 
    public class QuestionAnswerWrapper
    {
        List < String > allowedAnswers  {get;set;}
        List < String > allowedRatings  {get;set;}
        String domain                   {get;set;}
        List < String > allowedPoints   {get;set;}
        List < String > metNotMet       {get;set;}
    } //end custom data type class
    
    //returns empty string if the value passed == empty or null
    //else return value itself without whitespace
    public String sanityCheck(String toCheck)
    {
        String returnVal = Empty;
        if (!String.isBlank(toCheck))
        {
            returnVal = toCheck.trim();
        } //end if
        return returnVal;
    } //end method
    
    //Method to update Answer Rating for two edge case scenarios
    public void updateRatingsPointsAnil(List < Answer__c > newList)
    {
        //list of answers to update in bulk
        List < Answer__c > dmlAnswers = new List < Answer__c > ();
        //Query answers we want to perform calculation
        List < Answer__c > answersToUpdate = new List < Answer__c > ();
        //Set of questions assosciated to the answers we have
        Set < Id > questionIds = new Set < Id > ();
        for (Answer__c ans: newList)
        {
            questionIds.add(ans.AssociatedQuestion__c);
        }
        //set of question types we want to perform logic on
        Set < String > questionTypes = new Set < String > {'Text','Multiple Options','Picklist'};
       
        //get list of questions related to the answer(s) with required fields
        List < CLQ_Standard_Detail__c > standardDetails;
        Map < Id, String > quesName = new Map < Id, String > ();
        if(questionIds != null && questionTypes!=null){
            standardDetails = [SELECT Name, CLQ_QuestionType__c, CLQ_Met_Not_Met__c, Domain__c, CLQ_PossibleResponses__c, Possible_Points__c, Possible_Ratings__c, Id
                               FROM CLQ_Standard_Detail__c
                               WHERE Id IN: questionIds AND CLQ_QuestionType__c IN: questionTypes
                              ];
        }
        
        
        
        //for all the relevant answers, we store the allowed answers, domain, ratings, points and met/not-met
        //into a map identified by the question id
        Map < Id, QuestionAnswerWrapper > questionDetails = new Map < Id, QuestionAnswerWrapper > ();
        for (CLQ_Standard_Detail__c question: standardDetails)
        {
            quesName.put(question.Id, question.Name);
            QuestionAnswerWrapper qaw = new QuestionAnswerWrapper();
            qaw.allowedAnswers = sanityCheck(question.CLQ_PossibleResponses__c).trim().split(';');
            qaw.allowedRatings = sanityCheck(question.Possible_Ratings__c).trim().split(';');
            qaw.domain = sanityCheck(question.Domain__c).trim();
            qaw.allowedPoints = sanityCheck(question.Possible_Points__c).trim().split(';');
            qaw.metNotMet = sanityCheck(question.CLQ_Met_Not_Met__c).trim().split(';');
            questionDetails.put(question.Id, qaw);
            //System.debug('QuestionAnswerWrapper added: ' + qaw);
            
        }
        for (Answer__c answer: newList)
        {
            //get the question id
            //get allowed answers and compare to current answer to get index
            //use that index to get ratings or points or met/not met
            QuestionAnswerWrapper sourceQuestionRecordDetails;
            if(questionDetails.size()!=0){
                sourceQuestionRecordDetails = questionDetails.get(answer.AssociatedQuestion__c);
            }
            Integer answerIndex = -1;
            Integer answercount = 0;
            //getting the two edge scenarios answers
            //Integer answercount = 0;
            Map < string, QuestionToInclude__c > mapCodes = QuestionToInclude__c.getAll();
            //System.debug('MAP CODES' + mapCodes);
            //System.debug('INSIDE FOR LOOP');
            //System.debug('SD NAME' + quesName.get(answer.AssociatedQuestion__c));
            if (quesName.size()!=0 && mapCodes.size()!=0 && mapCodes.get(quesName.get(answer.AssociatedQuestion__c)) != null && mapCodes.get(quesName.get(answer.AssociatedQuestion__c)).Name == quesName.get(answer.AssociatedQuestion__c))
            {
                if (quesName.get(answer.AssociatedQuestion__c) == QuestionToInclude__c.getInstance(SD66).Name)
                {
                    for (integer i = 0; i < sourceQuestionRecordDetails.allowedAnswers.size(); i++)
                    {
                        
                        if (sourceQuestionRecordDetails.allowedAnswers.get(i).deleteWhiteSpace().equalsIgnorecase(answer.Answer_Text__c.deleteWhitespace()))
                        {
                            
                            answerIndex = i;
                            break;
                            
                        }
                    }
                    if (answerIndex == 0)
                    {
                        answer.Rating_Number__c = 1;
                    }
                }
                else if (quesName.size()!=0 && quesName.get(answer.AssociatedQuestion__c) == QuestionToInclude__c.getInstance(SD67).Name)
                {
                    
                    List < String > answersSelected = answer.Answer_Text__c.split(';');
                    //this loop is not required required
                    //suggest to use the List.size() function to remove this loop
                    //for (String ans: answersSelected)
                    //{
                    //    answercount = answercount + 1;
                    //}
                    
                    if (answersSelected.size() == 1)
                    {
                        answer.Rating_Number__c = 2;
                    }
                    else if (answersSelected.size() == 2)
                    {
                        answer.Rating_Number__c = 3;
                    }
                    else if (answersSelected.size() >= 3)
                    {
                        answer.Rating_Number__c = 3;
                        answer.Points__c = 3;
                    }
                }
                else if (quesName.size()!=0 && (quesName.get(answer.AssociatedQuestion__c) == QuestionToInclude__c.getInstance(SD76).Name || quesName.get(answer.AssociatedQuestion__c) == QuestionToInclude__c.getInstance(SD170).Name))
                {
                    List < String > answersSelectedList = answer.Answer_Text__c.trim().split(';');
                    
                    Set < String > answersSelected = new Set < String > (answersSelectedList);
                    
                    
                    //this loop is not required required
                    //suggest to use the List.size() function to remove this loop
                    
                    //for (String ans: answersSelected)
                    //{
                    //    answercount = answercount + 1;
                    //}
                    //System.debug('ANSWER COUNT' + answersSelected.size());
                    if (answersSelected.size() == 1)
                    {
                        answer.Rating_Number__c = 0;
                    }
                    if (answersSelected.Contains(System.Label.AnswerOptionI) || answersSelected.Contains(System.Label.AnswerOptionIcc))
                    {
                        
                        answer.Rating_Number__c = 0;
                    }
                    else
                    {
                        if (answersSelected.Contains(System.Label.AnswerOptionA))
                        {
                            
                            if (answersSelected.Contains(System.Label.AnswerOptionB))
                            {
                                
                                if (answersSelected.Contains(System.Label.AnswerOptionC) && answersSelected.Contains(System.Label.AnswerOptionD) && answersSelected.Contains(System.Label.AnswerOptionE) &&
                                    (answersSelected.Contains(System.Label.AnswerOptionF) || answersSelected.Contains(System.Label.AnswerOptionFcc)) &&
                                    (answersSelected.Contains(System.Label.AnswerOptionG) || answersSelected.Contains(System.Label.AnswerOptionGcc)) && (answersSelected.Contains(System.Label.AnswerOptionH) || answersSelected.Contains(System.Label.AnswerOptionHcc)))
                                {
                                    answer.Rating_Number__c = 3;
                                }
                                else if (answersSelected.Contains(System.Label.AnswerOptionC) && answersSelected.Contains(System.Label.AnswerOptionD) && answersSelected.Contains(System.Label.AnswerOptionE))
                                {
                                    answer.Rating_Number__c = 2;
                                }
                                else if (answersSelected.Contains(System.Label.AnswerOptionB))
                                {
                                    answer.Rating_Number__c = 1;
                                }
                            }
                            else
                            {
                                answer.Rating_Number__c = 0;
                            }
                        }
                        else
                        {
                            answer.Rating_Number__c = 0;
                        }
                    }
                }
            }
        }
    }
}