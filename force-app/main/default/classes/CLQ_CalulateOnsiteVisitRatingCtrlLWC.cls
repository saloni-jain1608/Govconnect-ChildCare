/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_CalulateOnsiteVisitRatingController 
** Description      : Controller for calculating onsite visit rating LWC
** Version          : 1.2
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
** Developer					Date				Version					Description
** Ankush R Relekar			  12/21/2021			  1.0					Initial Build (Controller for LWC component)

************************************************************************************/
public with sharing class CLQ_CalulateOnsiteVisitRatingCtrlLWC{
    
    public ID                                               inspectionId;
  	public static final String ONE = '1';
    public static final String TWO = '2';
    public static final String THREE = '3';
    public static final String FOUR = '4';
    public static final String FIVE = '5';
    public static final String D_LETTER = 'D';
    public static final String Message = 'Desk Review Rating success';
    
    public String calulateOnsiteVisitRating(string inspectionId){
    String redirectUrl;
    
    list<CLQ_Findings__c>                            listFindings;
    list<CLQ_Findings__c>                  listFindingswithPoints;
    list<CLQ_Transaction_Document__c>           listTransDocument;
    list<CLQ_Transaction_Document__c> listTransDocumentwithPoints;  
    Set<String> standardDetails                      = new Set<String>();
        string msg;
       try{
            //List we'll be updating
            List<CLQ_Inspection__c> inspectionToUpdate = new List<CLQ_Inspection__c>();
            
            //Static data declared for comparison to determine Onsite Rating (check nested if/else statements below)
            
            String preSchool = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Pre_School').getRecordTypeId();
            String fccTypeA  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Type_A_Home').getRecordTypeId();
            String fccTypeB  = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            String sacc      = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_School_Age_Child_Care').getRecordTypeId();
            String center    = Schema.Sobjecttype.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_Child_Care_Center').getRecordTypeId();
            
            Set<String> odeCenterSet = new Set<String>();
            odeCenterSet.add(preSchool);
            odeCenterSet.add(sacc);
            odeCenterSet.add(center);

            Set<String> fccTypeABSet = new Set<String>();
            fccTypeABSet.add(fccTypeB);
            fccTypeABSet.add(fccTypeA);
            //End static data declaration

            //Get Inspection id from page
            //inspectionId=ApexPages.currentPage().getParameters().get('id');
            //Query for inspection record
            CLQ_Inspection__c inspection;
           if(inspectionId!=null){
               inspection = [SELECT Id,Name 
                                            FROM CLQ_Inspection__c PT  
                                            WHERE Id = : inspectionId
                                           ];
           }
            
            //Extract from custom settings the Standard Findings to exclude

            List<StandardFindingstoExclude__c> sdToExclude = StandardFindingstoExclude__c.getall().values();
            if(sdToExclude != NULL){
                for(StandardFindingstoExclude__c  sd : sdToExclude){
                    standardDetails.add(sd.Name);
                }//end for loop
            }//end if
            
            //Get all inspections that have no Deferral ratings in associated findings
            Map<Id,CLQ_Inspection__c> mapInspection;
           	if(inspectionId!=null){
               	mapInspection = new Map<Id,CLQ_Inspection__c>([SELECT Id,CLQ_Program_Transaction__c,CLQ_Program__r.RecordTypeId,
                                                                                        (SELECT Id,Points__c,Rating__c 
                                                                                         FROM Findings__r 
                                                                                         WHERE Rating__c != 'D' 
                                                                                         AND Rating__c != null 
                                                                                         ORDER BY Rating__c asc) 
                                                                                    FROM CLQ_Inspection__c 
                                                                                    WHERE Id = : inspectionId
                                                                                    ]);
           	}
            
            //Get all the findings for this inspection
            if(mapInspection.size()!=0 && mapInspection.get(inspectionId).Findings__r != null){
                listFindings = mapInspection.get(inspectionId).Findings__r;
            }//end if
           	if(inspectionId!=null){
                listFindingswithPoints =  new List<CLQ_Findings__c>([SELECT Id,Points__c,Rating__c 
                                                                 FROM CLQ_Findings__c 
                                                                 WHERE Points__c != null 
                                                                 AND CLQ_Inspection__c =: inspectionId
                                                                ]);
           	}
            
            
            //13359 - Added where clause for CLQ_Document_Status__c for Not Verified 
            //13783 TODO: remove query since its from PT
            /*
            listTransDocument = new List<CLQ_Transaction_Document__c>([SELECT Id,Document_Points__c,Rating__c 
                                                                       FROM CLQ_Transaction_Document__c 
                                                                       WHERE  CLQ_Program_Transaction__c =: mapInspection.get(inspectionId).CLQ_Program_Transaction__c 
                                                                       AND Rating__c != null 
                                                                       AND CLQ_Document_Status__c != 'Not Verified'
                                                                       ORDER BY Rating__c asc
                                                                     ]);
			//13359 - Added where clause for CLQ_Document_Status__c for Not Verified 
			//13783 TODO: remove query since its from PT
            System.debug('@@@@@list of Document with Rating'+ listTransDocument);
            listTransDocumentwithPoints =  new List<CLQ_Transaction_Document__c>([SELECT Id,Document_Points__c,Rating__c 
                                                                                  FROM CLQ_Transaction_Document__c 
                                                                                  WHERE  CLQ_Standard_Detail_Document__r.Name IN :standardDetails 
                                                                                  AND Document_Points__c != null 
                                                                                  AND CLQ_Document_Status__c != 'Not Verified'
                                                                                  AND CLQ_Program_Transaction__c =: mapInspection.get(inspectionId).CLQ_Program_Transaction__c 
                                                                                ]);
            System.debug('@@@@list of Document with Points'+ listTransDocumentwithPoints);
            */
            
            Integer OnsiteVisitRating = 0;
            
            
        if(listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3 && listFindingswithPoints.size() !=0){
                    for(CLQ_Findings__c finding : listFindingswithPoints){
                        if(finding.Points__c != null){
                            OnsiteVisitRating = OnsiteVisitRating + Integer.valueOf(finding.Points__c);
                        }//end if
                    }//end for loop
                }//end if
                
                //13783 TODO: remove query since its from PT
                /*
                if(listTransDocumentwithPoints.size() >0){
                    for(CLQ_Transaction_Document__c transDoc : listTransDocumentwithPoints){
                        if(transDoc.Document_Points__c != null){
                            OnsiteVisitRating = OnsiteVisitRating + Integer.valueOf(transDoc.Document_Points__c);
                        }//end if
                    }//end for loop
                }//end if
                */
                if((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating >=35 && OnsiteVisitRating <= 55 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
                    inspection.Onsite_Rating__c = FOUR;
                    //System.debug('(Center/ODE) DomainRating expected is 4, my value is = ' + OnsiteVisitRating);
                                                                             
                }//end if 
                else if((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating > 55 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
	
                    inspection.Onsite_Rating__c = FIVE;
                }//end else if
                else if((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating >=30 && OnsiteVisitRating <= 45 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
                    inspection.Onsite_Rating__c = FOUR;
                   }//end else if
                else if((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating > 45 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
                    
                    inspection.Onsite_Rating__c = FIVE;
               }//end else if
                else if ((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating < 30 && fccTypeABSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
                    inspection.Onsite_Rating__c = THREE;
              }//end else if
                
                else if ((listFindings.size()!=0 && Integer.valueOf(listFindings.get(0).Rating__c ) == 3) && (mapInspection.size()!=0 && OnsiteVisitRating < 35 && odeCenterSet.contains(String.valueOf(mapInspection.get(inspectionId).CLQ_Program__r.RecordTypeId)))){
                    inspection.Onsite_Rating__c = THREE;
           }//end else if
     
            else{
                //Only set the OnsiteVisitRating value to the Findings value if it doensn't have a value of 'D'
                if(listFindings.size()!=0 && listFindings.get(0).Rating__c != D_LETTER){
                    OnsiteVisitRating = Integer.valueOf(listFindings.get(0).Rating__c );
                    inspection.Onsite_Rating__c = String.valueOf(OnsiteVisitRating);
                }//end if
            }//end else
            
            inspectionToUpdate.add(inspection);
            
            try{
                if(inspectionToUpdate != null && inspectionToUpdate.size() != 0){
                    update inspectionToUpdate;
                    msg = Message;
                }//end if
            }//end try
            catch(Exception e){
            //If DML operation fails, catch exception and show on ApexPage
                //System.debug('Exception: '   + e);
                //System.debug('Cause: '       + e.getCause());
                //System.debug('Line Number: ' + e.getLineNumber());
                //System.debug('Stack Trace: ' + e.getStackTraceString());
                msg='error from ctrl in update:'+e;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

            }//end catch
            
            //redirecturl ='/'+inspectionId;
            //pageReference newpage=new pagereference(redirecturl);
            //newpage.setRedirect(true);
            //return newpage;
        }//end try
        catch(Exception e){
        //If there's a breakage in the method, catch exception and show on ApexPage
            //System.debug('Exception: '   + e);
            //System.debug('Cause: '       + e.getCause());
            //System.debug('Line Number: ' + e.getLineNumber());
            //System.debug('Stack Trace: ' + e.getStackTraceString());
            msg= 'error from ctrl:'+e;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            //return null;
        }//end catch
        return msg;
    }//end method
    
}//end class