public with sharing class Program_Rating_Controller implements IRequest{
    
    private String jsonParam;
    Public static final string Calculate_Desk_Review_Rating='Calculate Desk Review Rating';
    Public static final string Desk_Review_Findings='Desk Review Findings';
    Public static final string Onsite_Standard_Findings='Onsite Standard Findings';
    Public static final string Calculate_Onsite_Visit_Rating='Calculate Onsite Visit Rating';
    Public static final string Desk_Review_Findings_LWC='Desk Review Findings LWC';
    Public static final string Onsite_Standard_Findings_LWC='Onsite Standard Findings LWC';
    Public static final string Onsite_Visit_Pending='Onsite Visit Pending';
    Public static final string Pending_Approval='Pending Approval';
    Public static final string Rating_Assessment_Complete='Rating Assessment Complete';
    Public static final string ERROR='error';
    Public static final string Deferral='Deferral';
    Public static final string D='D';
    public static final string StringError = 'error';
    
    public JsonResponse validate(String methodName, String jsonParam) {
        JsonResponse response = new JsonResponse();
        response.status = RequestStatus.OK;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        return response;
    }
    public JsonResponse processRequest(String methodName, String jsonParam){
        JsonResponse response = null;
        this.jsonParam = jsonParam;
        
        try{
            if(methodName == Calculate_Desk_Review_Rating){
                response = Calculate_Desk_Review_Rating();
            }else if(methodName == Desk_Review_Findings){
                response = CLQ_Desk_Review_Findings();
            }else if(methodName == Onsite_Standard_Findings){
                response = Onsite_Standard_Findings();
            }
            else if(methodName == Calculate_Onsite_Visit_Rating){
                response = Calculate_Onsite_Visit_Rating();
            }else if(methodName == Desk_Review_Findings_LWC){
                response = CLQ_Desk_Review_Findings_LWC();
            }
            else if(methodName == Onsite_Standard_Findings_LWC){
                response = Onsite_Standard_Findings_LWC();
            }
            else{
                response = new JsonResponse();
                response.status = RequestStatus.ERROR;
                response.data = new Map<String, Object>();
                response.errors = new List<String>();
                response.errors.add('Invalid method name');
            }            
        }
        catch(Exception ex){
            //System.debug('ex'+ ex.getStackTraceString());
            response = new JsonResponse();
            response.status = RequestStatus.ERROR;
            response.data = new Map<String, Object>();
            response.errors = new List<String>();
            response.errors.add(ex.getMessage());
        }
        
        return response;
    }
    
    public JsonResponse Calculate_Desk_Review_Rating(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Program_Transaction__c progApp;
        if(recordId!=null){
            progApp=[select id, Name, CLQ_Transaction_Status__c from CLQ_Program_Transaction__c where id=:recordId]; 
        }
        
        string pickVal=progApp.CLQ_Transaction_Status__c;
        list<CLQ_Findings__c> DefList;
        list<CLQ_Findings__c> AllList;
        list<CLQ_Findings__c> findingList;
        list<CLQ_Transaction_Document__c> docList;
        list<Answer__c> answerList;
        list<CLQ_Rules_Inspected__c> rulesInspectedList;
        if(recordId!=null){
            DefList= [Select Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:recordId and Rating__c = 'D' and Rating__c != null];
        }
        if(recordId!=null){
            AllList= [Select Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:recordId];
        }
        if(recordId!=null){
            findingList = [Select Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:recordId and Rating__c != 'D' and Rating__c != null];
        }
        if(recordId!=null){
            docList = [Select Id,Document_Points__c,Rating__c from CLQ_Transaction_Document__c where CLQ_Program_Transaction__c =:recordId AND Rating__c != null];
        }
        if(recordId!=null){
            answerList = [Select Id,Points__c,Rating_Number__c from Answer__c where Program_Transaction__c =:recordId AND Domain_Name__c != 'Staff Quals and PD' And Rating_Number__c != null];
        }
        if(recordId!=null){
            rulesInspectedList = [SELECT Id, Name FROM CLQ_Rules_Inspected__c where ProgramTransaction__c = :recordId];
        }
        
        Integer sizeRL = rulesInspectedList.size();
        Integer sizeFL = findingList.size();
        
        if(DefList.size()>0)
        {
            response.errors.add('Rating Cannot be calculated as one or more findings are in Deferral Status');
            return response;
        }
        else if(sizeRL != AllList.size()){
            response.errors.add('All Desk Review Findings must have a rating or point value before the Onsite Visit can be created');
            return response;
        }
        else{
            system.debug('findingList'+findingList.size());
            system.debug('docList'+docList.size());
            system.debug('answerList'+answerList.size());
            if(findingList.IsEmpty() || docList.IsEmpty()|| answerList.IsEmpty()){
                response.errors.add('Please perform all Desk Review actions prior to calculating Desk Review Rating');
                return response;
            }
            else{
                if(pickVal==Onsite_Visit_Pending || pickVal==Pending_Approval || pickVal==Rating_Assessment_Complete)
                {
                    if(pickVal==Onsite_Visit_Pending){
                        response.errors.add('Transaction Status is Onsite Visit Pending, Desk Review Rating cannot be re-calculated');
                        return response;
                    }
                    if(pickVal==Pending_Approval)
                    {
                        response.errors.add('Transaction Status is Pending Approval, Desk Review Rating cannot be Re-Calculated');
                        return response;
                    }
                    if(pickVal==Rating_Assessment_Complete)
                    {
                        response.errors.add('Transaction Status is Rating Assessment Complete, Desk Review Rating Cannot be Re-Calculated');
                        return response;
                    }
                }
                else
                {
                    //response.data.put('redirect', true);
                    //response.data.put('redirectType', 'standard__webPage');
                    //response.data.put('url','/apex/CLQ_CalculateDeskReviewRating?id='+recordId);
                    CLQ_CalulateDeskReviewRatingCtrlLWC ctrl=new CLQ_CalulateDeskReviewRatingCtrlLWC();
                    string msg=ctrl.calulateDeskReviewRating(recordId);
                    if(msg.contains(ERROR)){
                        response.errors.add(msg);
                    }
                    else{
                        response.status = RequestStatus.OK;
                    }
                }
            }
        }
        return response;
    }
    
    public JsonResponse CLQ_Desk_Review_Findings(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Program_Transaction__c progApp;
        if(recordId!=null){
            progApp=[select id, Name, CLQ_Transaction_Status__c,CLQ_Rules_Effective_On__c from CLQ_Program_Transaction__c where id=:recordId]; 
        }
        
        
        if(progApp.CLQ_Rules_Effective_On__c==null){
            response.errors.add('You can not set Desk Review Findings without Rules Effective On');
            return response;
        }
        else{
            response.data.put('redirect', true);
            response.data.put('redirectType', 'standard__webPage');
            response.data.put('url','/apex/CLQ_DeskReviewFinding?id='+progApp.Id);
        }
        
        return response;
    }
    
    
    public JsonResponse CLQ_Desk_Review_Findings_LWC(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Program_Transaction__c progApp;
        if(recordId!=null){
            progApp=[select id, Name, CLQ_Transaction_Status__c,CLQ_Rules_Effective_On__c from CLQ_Program_Transaction__c where id=:recordId];
        }
        if(progApp.CLQ_Rules_Effective_On__c==null){
            response.errors.add('You can not set Desk Review Findings without Rules Effective On');
            return response;
        }
        else{
            response.data.put('redirect', true);
            response.data.put('redirectType', 'component');
            response.data.put('Data', progApp.Id);
            response.data.put('componentName','c__deskReviewFindingAura');
            response.data.put('rectype','CLQ_Program_Transaction__c');
        }
        
        return response;
    }
    
    public JsonResponse Onsite_Standard_Findings(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Inspection__c inspection;
        list<CLQ_Findings__c> findings;
        if(recordId!=null){
            inspection=[select id,CLQ_Program_Transaction__c,CLQ_Use_Rules_Effective_On__c from CLQ_Inspection__c where id=:recordId];
        }
        
        if(inspection.CLQ_Program_Transaction__c!=null){
            findings=[Select Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:inspection.CLQ_Program_Transaction__c];
        }
        
        if(inspection.CLQ_Use_Rules_Effective_On__c==null){
            response.errors.add('You can not set Onsite Standard Findings without Rules Effective On');
            return response;
        }
        else if(findings.IsEmpty()){
            response.errors.add('Desk Review Findings need to be created prior to creating Onsite Findings');
            return response;
        }
        else{
            response.data.put('redirect', true);
            response.data.put('redirectType', 'standard__webPage');
            response.data.put('url','/apex/CLQ_OnsiteReviewFinding?id='+recordId);
        }
        
        return response;
    }
    
    public JsonResponse Onsite_Standard_Findings_LWC(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Inspection__c inspection;
        list<CLQ_Findings__c> findings;
        if(recordId!=null){
            inspection=[select id,CLQ_Program_Transaction__c,CLQ_Use_Rules_Effective_On__c from CLQ_Inspection__c where id=:recordId];
        }
        
        if(inspection.CLQ_Program_Transaction__c!=null){
            findings=[Select Id,Points__c,Rating__c from CLQ_Findings__c where Program_Transaction__c =:inspection.CLQ_Program_Transaction__c];
        }
        
        
        if(inspection.CLQ_Use_Rules_Effective_On__c==null){
            response.errors.add('You can not set Onsite Standard Findings without Rules Effective On');
            return response;
        }
        else if(findings.IsEmpty()){
            response.errors.add('Desk Review Findings need to be created prior to creating Onsite Findings');
            return response;
        }
        else{
            response.data.put('redirect', true);
            response.data.put('redirectType', 'component');
            response.data.put('Data', inspection.Id);
            response.data.put('componentName','c__deskReviewFindingAura');
            response.data.put('rectype','CLQ_Inspection__c');
        }
        
        return response;
    }
    
    public JsonResponse Calculate_Onsite_Visit_Rating(){
        JsonResponse response = null;
        String recordId = this.jsonParam;
        
        response = new JsonResponse();
        response.status = RequestStatus.Error;
        response.data = new Map<String, Object>();
        response.errors = new List<String>();
        CLQ_Inspection__c inspection;
        if(recordId!=null){
            inspection=[select id,CLQ_Program_Transaction__c,CLQ_Inspection_Status__c from CLQ_Inspection__c where id=:recordId];
        }
        string pickVal=inspection.CLQ_Inspection_Status__c;
        
        Boolean CanSubmitForApproval = true;
        list<CLQ_Findings__c> findingList;
        list<CLQ_Rules_Inspected__c> rulesInspectedList;
        if(recordId!=null){
            findingList = [Select Id,Points__c,Rating__c from CLQ_Findings__c where CLQ_Inspection__c =:recordId];
        }
        if(recordId!=null){
            rulesInspectedList = [SELECT Id, Name FROM CLQ_Rules_Inspected__c where CLQ_Inspection_No__c = :recordId];
        }
        
        
        Integer sizeRL = rulesInspectedList.size();
        Integer sizeFL = findingList.size();
        
        if(sizeRL != sizeFL){
            CanSubmitForApproval = false;
        }
        //15653 - Ends
        Boolean isFindDef = false;
        Integer size = findingList.size();
        
        for(Integer i=0;i<size;i++)
        {
            if(findingList[i].Rating__c == D)
            {
                isFindDef = true;
            }
        }
        
        if(findingList.IsEmpty()){
            response.errors.add('Please perform all Onsite Visit actions prior to calculating Onsite Visit Rating');
            return response;
        }
        else{
            if(!isFindDef)
            {
                if(pickVal == Deferral){
                    response.errors.add('Inspection Status is Deferral, Onsite Rating cannot be Calculated');
                    return response;
                }
                else if(pickVal == Rating_Assessment_Complete){
                    response.errors.add('Inspection Status is Rating Assessment Complete, Onsite Rating cannot be Re-Calculated');
                    return response;
                }
                else{//15653
                    if(CanSubmitForApproval == false){
                        response.errors.add('All Onsite Standard Findings must have a rating or point value before the Onsite Rating can be calculated.');
                        return response;
                    }else{
                        //response.data.put('redirect', true);
                        //response.data.put('redirectType', 'standard__webPage');
                        //response.data.put('url','/apex/CLQ_CalculateOnsiteVisitRating?id='+recordId);
                        CLQ_CalulateOnsiteVisitRatingCtrlLWC ctrl=new CLQ_CalulateOnsiteVisitRatingCtrlLWC();
                        string msg=ctrl.calulateOnsiteVisitRating(recordId);
                        
                        if(msg.contains(StringError)){
                            response.errors.add(msg);
                        }
                        else{
                            response.status = RequestStatus.OK;
                        }
                    }
                }
            }
            else
            {
                response.errors.add('Calculate Onsite Rating cannot be performed, one or more Findings are in Deferral status');
                return response;
            }
        }
        
        return response;
    }
}