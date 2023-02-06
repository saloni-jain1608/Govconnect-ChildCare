public with sharing class CLQ_CalulateDeskReviewRatingCtrlLWC{
    
    public static final string Three='3';
    public static final string Four='4';
    public static final string Five='5';
    public static final string Msg1='Desk Review Rating success';
    public static final string Msg2='error from ctrl in update:';
    public static final string Msg3='error from ctrl:';
    
    public string calulateDeskReviewRating(string PTid){
        String redirectUrl;
        list<CLQ_Transaction_Document__c> listTransDocument ;
    	list<Answer__c> listAnswers ;
    	list<CLQ_Findings__c> listFindings;
    	list<CLQ_Transaction_Document__c> listTransDocumentwithPoints ;
    	list<Answer__c> listAnswerswithPoints ;
    	list<CLQ_Findings__c> listFindingswithPoints;
    Set<String> standardfindings = new Set<String>();
        string msg;
        try{
            standardfindings.add('SD-00014');
            standardfindings.add('SD-00015');
            standardfindings.add('SD-00030');
            standardfindings.add('SD-00033');
            standardfindings.add('SD-00092');
            standardfindings.add('SD-00093');
            standardfindings.add('SD-00038');
            standardfindings.add('SD-00156');
            standardfindings.add('SD-00157');
            
            //Static data declared for comparison to determine Onsite Rating (check nested if/else statements below)
            
            String preSchool = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            String fccTypeA  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            String fccTypeB  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            String sacc      = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            String center    = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            String SUTQExpeditedReg = Schema.Sobjecttype.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Expedited_Registration').getRecordTypeId(); //14858
            String sutqChangeofOwnerID =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Change_of_Owner_Registration').getRecordTypeId(); //14913
            String sutqRaingReinstateID =  Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('SUTQ_Reinstate_Rating_after_Temporary_Closure').getRecordTypeId(); //14917
            
            
            Set<String> odeCenterSet = new Set<String>();
            odeCenterSet.add(preSchool);
            odeCenterSet.add(sacc);
            odeCenterSet.add(center);
            
            Set<String> fccTypeABSet = new Set<String>();
            fccTypeABSet.add(fccTypeB);
            fccTypeABSet.add(fccTypeA);
            //End static data declaration
            CLQ_Program_Transaction__c progTransaction;
            if(PTid != null){
                progTransaction = [SELECT Id,Name,Recommended_Rating__c 
                                                          FROM CLQ_Program_Transaction__c PT  
                                                          WHERE Id = : PTid
                                                         ];
            }                                      
            
            
            list<CLQ_Program_Transaction__c> prgTransactionToUpdate = new List<CLQ_Program_Transaction__c>();  
            
            Map<Id,CLQ_Program_Transaction__c> mapProgramTransaction = new Map<Id,CLQ_Program_Transaction__c>([SELECT Id,CLQ_Program__r.RecordTypeId,RecordTypeId,
                                                                                                               (SELECT Id,Document_Points__c,Rating__c 
                                                                                                                FROM Transaction_Documents__r 
                                                                                                                WHERE  Rating__c != null 
                                                                                                                ORDER BY Rating__c asc),
                                                                                                               (SELECT Id,Points__c,Rating_Number__c 
                                                                                                                FROM Answers__r 
                                                                                                                WHERE Domain_Name__c != 'Staff Quals and PD' 
                                                                                                                AND  Rating_Number__c != null 
                                                                                                                ORDER BY Rating_Number__c asc),
                                                                                                               (SELECT Id,Points__c,Rating__c 
                                                                                                                FROM Findings__r WHERE Rating__c != 'D' 
                                                                                                                AND  Rating__c != null 
                                                                                                                ORDER BY Rating__c asc)
                                                                                                               FROM CLQ_Program_Transaction__c 
                                                                                                               WHERE Id = : Ptid
                                                                                                              ]);
            
            if(mapProgramTransaction.size()!=0 && mapProgramTransaction.get(PTid).Transaction_Documents__r != null){
                listTransDocument = mapProgramTransaction.get(PTid).Transaction_Documents__r;
            }
            if(mapProgramTransaction.size()!=0 && mapProgramTransaction.get(PTid).Answers__r != null){
                listAnswers = mapProgramTransaction.get(PTid).Answers__r;
            }
            if(mapProgramTransaction.size()!=0 && mapProgramTransaction.get(PTid).Findings__r != null){
                listFindings = mapProgramTransaction.get(PTid).Findings__r;
            }
            
            //13359 - Updated the query to consider only the not verified records during the rating calculation
            listTransDocumentwithPoints = new List<CLQ_Transaction_Document__c>([SELECT Id,Document_Points__c,Rating__c 
                                                                                 FROM CLQ_Transaction_Document__c 
                                                                                 WHERE  Document_Points__c != null 
                                                                                 AND CLQ_Document_Status__c != 'Not Verified'
                                                                                 AND CLQ_Program_Transaction__c =: Ptid 
                                                                                ]);
            if(standardfindings != null){
                listAnswerswithPoints       = new List<Answer__c>([SELECT Id,Points__c,Rating_Number__c 
                                                               FROM Answer__c 
                                                               WHERE AssociatedQuestion__r.Name IN :standardfindings  
                                                               AND  Points__c != null 
                                                               AND  Program_Transaction__c =: Ptid
                                                              ]);
            }
            
            
            listFindingswithPoints      = new List<CLQ_Findings__c>([SELECT Id,Points__c,Rating__c 
                                                                     FROM CLQ_Findings__c 
                                                                     WHERE Points__c != null 
                                                                     AND Program_Transaction__c =: Ptid
                                                                    ]);
            
            
            Integer DeskReviewRating = 0;
            
            //14858
            //System.debug('@@RR.test');
            //System.debug('@@RR main class' + mapProgramTransaction.get(PTid).RecordTypeId);
            if(listFindings.size()!=0 && mapProgramTransaction.size()!=0 && (mapProgramTransaction.get(PTid).RecordTypeId == SUTQExpeditedReg || mapProgramTransaction.get(PTid).RecordTypeId == sutqChangeofOwnerID || mapProgramTransaction.get(PTid).RecordTypeId == sutqRaingReinstateID)){
                
                DeskReviewRating = Integer.valueOf(listFindings.get(0).Rating__c );
                progTransaction.Recommended_Rating__c = String.valueOf(DeskReviewRating);
                //System.debug('rating coming will be ' + DeskReviewRating);
                
            }else{
                
                if(listTransDocument.size()!=0 && listAnswers.size()!=0 && listFindings.size()!=0 && Integer.valueOf(listTransDocument.get(0).Rating__c) == 3 && Integer.valueOf(listAnswers.get(0).Rating_Number__c) == 3 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3){
                    
                    if(listTransDocumentwithPoints.size() >0){
                        for(CLQ_Transaction_Document__c transDoc : listTransDocumentwithPoints){
                            if(transDoc.Document_Points__c != null){
                                DeskReviewRating = DeskReviewRating + Integer.valueOf(transDoc.Document_Points__c);
                            }
                        }
                    }
                    
                    if(listAnswerswithPoints.size() >0){
                        for(Answer__c answer :listAnswerswithPoints ){
                            if(answer.Points__c != null){
                                DeskReviewRating = DeskReviewRating + Integer.valueOf(answer.Points__c);
                            }
                        }
                    }
                    
                    
                    if(listFindingswithPoints.size() >0){
                        for(CLQ_Findings__c finding : listFindingswithPoints){
                            if(finding.Points__c != null){
                                DeskReviewRating = DeskReviewRating + Integer.valueOf(finding.Points__c);
                            }
                        }
                    }
                    
                    if(mapProgramTransaction.size()!=0 && DeskReviewRating >=35 && DeskReviewRating <= 55 && odeCenterSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Four;
                        
                        
                    } else if(mapProgramTransaction.size()!=0 && DeskReviewRating > 55 && odeCenterSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Five;
                        
                        
                    }else if(mapProgramTransaction.size()!=0 && DeskReviewRating >=30 && DeskReviewRating <= 45 && fccTypeABSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Four;
                        
                        
                    }else if(mapProgramTransaction.size()!=0 && DeskReviewRating > 45 && fccTypeABSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Five;
                        
                        
                    }else if (mapProgramTransaction.size()!=0 && DeskReviewRating < 30 && fccTypeABSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Three;
                        
                    }else if (DeskReviewRating < 35 && odeCenterSet.contains(String.valueOf(mapProgramTransaction.get(PTid).CLQ_Program__r.RecordTypeId))){
                        progTransaction.Recommended_Rating__c = Three;
                    }
                    
                }else {
                    if(listFindings.size()!=0){
                    	DeskReviewRating = Integer.valueOf(listFindings.get(0).Rating__c );
                    }
                    if(listAnswers.size()!=0 && Integer.valueOf(listAnswers.get(0).Rating_Number__c ) < DeskReviewRating){
                        DeskReviewRating = Integer.valueOf(listAnswers.get(0).Rating_Number__c );
                    }
                    
                    if(listTransDocument.size()!=0 && Integer.valueOf(listTransDocument.get(0).Rating__c) < DeskReviewRating){
                        DeskReviewRating = Integer.valueOf(listTransDocument.get(0).Rating__c);
                    }
                    
                    progTransaction.Recommended_Rating__c = String.valueOf(DeskReviewRating);
                    
                }                
                
            }
            
            
            
            
            prgTransactionToUpdate.add(progTransaction);
            
            try{
                if(prgTransactionToUpdate != null && prgTransactionToUpdate.size() > 0){
                    update prgTransactionToUpdate;
                    msg=Msg1;
                    
                        }
            } 
            catch (Exception e){
                msg= Msg2+e;
                
            }
            
            
            
        }catch(exception e){
            //If there's a breakage in the method, catch exception and show on ApexPage
            
            
            
            
            msg= Msg3+e;
        }//end catch
        return msg;
    }
    
}