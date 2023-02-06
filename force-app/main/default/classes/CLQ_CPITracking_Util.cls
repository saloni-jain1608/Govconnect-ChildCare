/**
* Class to create a OCLQS_CPI_Tracking__c record
* to meet CPI tracking requirements
* Written by Vamsi V
* Version 1.1
* Date Modified: 11/16/16
*/
global class CLQ_CPITracking_Util {
    //global variables
    public static OCLQS_CPI_Tracking__c CPIRecord;
    public static List<OCLQS_CPI_Tracking__c> recordsToInsert = new List<OCLQS_CPI_Tracking__c>();
    public static User user = [SELECT Id, Alias, FederationIdentifier from User WHERE Id =: UserInfo.getUserId()];
    
    public static final string asterisk = '*';
    public static final string DateString = '1777-07-07';
    public static final string dotcom = '.com/';
    public static final string StringContact = 'Contact';
    public static final string CLQ_BCII_FBI = 'CLQ_BCII_FBI__c';
    public static final string CLQ_Date_of_Birth = 'CLQ_Date_of_Birth__c';
    public static final string CLQ_SSN_Integration = 'CLQ_SSN_Integration__c';
    public static final string Account = 'Account';
    public static final string CLQ_FEIN = 'CLQ_FEIN__c';
    public static final string Staff_Record = 'Staff Record';
    public static final string CLQ_Staff_Record = 'CLQ_Staff_Record__c';
    public static final string CLQ_SSN = 'CLQ_SSN__c';
    
    public static final string CLQ_Name = 'CLQ_Name__c';
    public static final string Middle_Name = 'Middle_Name__c';
    public static final string Middle_Initial = 'Middle_Initial__c';
    public static final string Last_Name = 'Last_Name__c';
    public static final string First_Name = 'First_Name__c';
    public static final string CLQ_Position = 'CLQ_Position__c';
    public static final string Position_End_Date = 'Position_End_Date__c';
    public static final string Position_Start_Date = 'Position_Start_Date__c';
    public static final string CLQ_Status = 'CLQ_Status__c';
    
    public static final string CLQ_Hire_Date = 'CLQ_Hire_Date__c';
    
    public static final string CLQ_Case_Custom = 'CLQ_Case_Custom__c';
    public static final string CaseObj = 'Case';
    public static final string CLQ_Complainant_City = 'CLQ_Complainant_City__c';
    public static final string CLQ_County_Complainant = 'CLQ_County_Complainant__c';
    public static final string CLQ_Complainant_Email = 'CLQ_Complainant_Email__c';
    public static final string CLQ_Complainant_First_Name = 'CLQ_Complainant_First_Name__c';
    public static final string CLQ_Complainant_Last_Name = 'CLQ_Complainant_Last_Name__c';
    
    public static final string CLQ_Complainant_Phone = 'CLQ_Complainant_Phone__c';
    public static final string CLQ_State_Complainant = 'CLQ_State_Complainant__c';
    public static final string CLQ_Complainant_Street = 'CLQ_Complainant_Street__c';
    public static final string CLQ_Complainant_Zip_Code = 'CLQ_Complainant_Zip_Code__c';
    public static final string CLQ_Complainant_Street_2 = 'CLQ_Complainant_Street_2__c';
    public static final string BCI_FBI = 'BCI FBI';
    
    
    
    /**
* Method to create static values required for a CPI record
* Parameters: recordId - the recordId we're tracking
*             screenURL - the URL of the screen we're tracking
*             u - the running user
*/
    public static OCLQS_CPI_Tracking__c createStaticValues(String recordId, String screenURL, User u){
        //initialize CPI record
        CPIRecord = new OCLQS_CPI_Tracking__c();
        
        //assign static values to record fields
        CPIRecord.Screen_URL__c = screenURL;
        CPIRecord.Record_Id__c = recordId;
        CPIRecord.OwnerId = UserInfo.getUserId();
        CPIRecord.User_Id__c = UserInfo.getUserId();
        CPIRecord.User_First_Name__c = UserInfo.getFirstName();
        CPIRecord.User_Last_Name__c = UserInfo.getLastName();
        CPIRecord.Username__c = UserInfo.getUserName();
        CPIRecord.User_Alias__c = u.Alias;
        CPIRecord.Employee_Id__c= u.FederationIdentifier;
        
        
        
        return CPIRecord;
    }//end method
    /**
* Method to log BCI/FBI records from the Integration_BCII_FBI_Lookup_Ctrl class
* Parameters: contacts - list of BCII/FBI contacts returned from the lookup
*/ 
    public static void logBCIFields(List<CLQ_BCII_FBI__c> contacts){
        
        for(CLQ_BCII_FBI__c contactRecord : contacts){
            
            if(contactRecord.CLQ_SSN_Integration__c != null){
                CPIRecord = createStaticValues(contactRecord.Id, '', user);
                CPIRecord.Object_Name__c = BCI_FBI;
                CPIRecord.Field_Name__c = CLQ_SSN_Integration;
                CPIRecord.Field_Value__c = contactRecord.CLQ_SSN_Integration__c;
                
                if(!contactRecord.CLQ_SSN_Integration__c.contains(asterisk)){
                    recordsToInsert.add(CPIRecord);
                }//end if
            }//end if
            
            if(contactRecord.CLQ_Date_of_Birth__c!=null){
                CPIRecord = createStaticValues(contactRecord.id, '', user);
                CPIRecord.Object_Name__c = BCI_FBI;
                CPIRecord.Field_Name__c = CLQ_Date_of_Birth;
                CPIRecord.Field_Value__c = contactRecord.CLQ_Date_of_Birth__c.format();
                   
                if(!contactRecord.CLQ_Date_of_Birth__c.format().contains(DateString)){
                    recordsToInsert.add(CPIRecord);
                }//end if
            }//end if
        }//end for
        
        finalizeCPIList(recordsToInsert);
        
    }//end method
    
    //@future
    webservice static void logCPIFields(String objectName, String recordId, String screenURL){
        
        //get the recordId from the URL and remove the ".com" if it exists
        
        if(recordId.contains(dotcom)){
            recordId = recordId.substring(5, recordId.length());
        }//end if
        
        
        //track fields required on Contact object
        if(objectName == StringContact){
            Contact contactRecord = [SELECT CLQ_Date_of_Birth__c, CLQ_SSN__c 
                                     FROM Contact 
                                     WHERE id =:recordId 
                                     LIMIT 1];
            if(contactRecord.CLQ_SSN__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = StringContact;
                CPIRecord.Field_Name__c = CLQ_SSN;
                CPIRecord.Field_Value__c = contactRecord.CLQ_SSN__c;
                
                if(!contactRecord.CLQ_SSN__c.contains(asterisk)){
                    recordsToInsert.add(CPIRecord);
                }
            }
            if(contactRecord.CLQ_Date_of_Birth__c!=null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = StringContact;
                CPIRecord.Field_Name__c = CLQ_Date_of_Birth;
                CPIRecord.Field_Value__c = contactRecord.CLQ_Date_of_Birth__c.format();
                   
                if(!contactRecord.CLQ_Date_of_Birth__c.format().contains(DateString)){
                    recordsToInsert.add(CPIRecord);
                }
            }
            
            //track fields required on BCII_FBI Object   
        }else if(objectName == CLQ_BCII_FBI){
            CLQ_BCII_FBI__c bci_fbi_record = [SELECT CLQ_Date_of_Birth_Text__c, CLQ_Date_of_Birth__c, CLQ_SSN_Integration__c 
                                              FROM CLQ_BCII_FBI__c 
                                              WHERE id =:recordId 
                                              LIMIT 1];
            
            
            if(bci_fbi_record.CLQ_Date_of_Birth__c!=null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CLQ_BCII_FBI;
                CPIRecord.Field_Name__c = CLQ_Date_of_Birth;
                CPIRecord.Field_Value__c = bci_fbi_record.CLQ_Date_of_Birth__c.format();
                recordsToInsert.add(CPIRecord);
            }
            if(bci_fbi_record.CLQ_SSN_Integration__c!=null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CLQ_BCII_FBI;
                CPIRecord.Field_Name__c = CLQ_SSN_Integration;
                CPIRecord.Field_Value__c = bci_fbi_record.CLQ_SSN_Integration__c;
                recordsToInsert.add(CPIRecord);
            }     
            //track fields required on Account Object 
        }else if(objectName == 'Account'){
            Account accRecord = [SELECT CLQ_FEIN__c 
                                 FROM Account 
                                 WHERE id =: recordId 
                                 LIMIT 1];
            if(accRecord.CLQ_FEIN__c!=null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Account;
                CPIRecord.Field_Name__c = CLQ_FEIN;
                CPIRecord.Field_Value__c = accRecord.CLQ_FEIN__c;
                if(!accRecord.CLQ_FEIN__c.contains(asterisk)){
                    recordsToInsert.add(CPIRecord);
                }
            }
            //track fields required on Staff Training Object
        }else if(objectName == CLQ_Staff_Record){
            CLQ_Staff_Record__c staffRec = [SELECT CLQ_Name__c, Middle_Name__c , Middle_Initial__c  ,Last_Name__c,
                                            First_Name__c,CLQ_Position__c,Position_End_Date__c,Position_Start_Date__c,
                                            CLQ_Status__c,CLQ_Hire_Date__c  
                                            FROM CLQ_Staff_Record__c
                                            WHERE Id =: recordId
                                            LIMIT 1];
            if(staffRec.CLQ_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = CLQ_Name;
                CPIRecord.Field_Value__c= staffRec.CLQ_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            
            if(staffRec.Middle_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = Middle_Name;
                CPIRecord.Field_Value__c= staffRec.Middle_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.Middle_Initial__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = Middle_Initial;
                CPIRecord.Field_Value__c= staffRec.Middle_Initial__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.Last_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = Last_Name;
                CPIRecord.Field_Value__c= staffRec.Last_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.First_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = First_Name;
                CPIRecord.Field_Value__c= staffRec.First_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.CLQ_Position__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = CLQ_Position;
                CPIRecord.Field_Value__c= staffRec.CLQ_Position__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.Position_End_Date__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = Position_End_Date;
                CPIRecord.Field_Value__c= staffRec.Position_End_Date__c.format();
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.Position_Start_Date__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = Position_Start_Date;
                CPIRecord.Field_Value__c= staffRec.Position_Start_Date__c.format();
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.CLQ_Status__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = CLQ_Status;
                CPIRecord.Field_Value__c= staffRec.CLQ_Status__c;
                recordsToInsert.add(CPIRecord);
            }
            if(staffRec.CLQ_Hire_Date__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = Staff_Record;
                CPIRecord.Field_Name__c = CLQ_Hire_Date;
                CPIRecord.Field_Value__c= staffRec.CLQ_Hire_Date__c.format();
                recordsToInsert.add(CPIRecord);
            }
            
        }else if(objectName == CLQ_Case_Custom){
            CLQ_Case_Custom__c caseRec = [SELECT CLQ_Complainant_City__c,CLQ_County_Complainant__c ,CLQ_Complainant_Email__c,CLQ_Complainant_First_Name__c,
                                          CLQ_Complainant_Last_Name__c,CLQ_Complainant_Phone__c,CLQ_State_Complainant__c ,CLQ_Complainant_Street__c,
                                          CLQ_Complainant_Street_2__c,CLQ_Complainant_Zip_Code__c   
                                          FROM CLQ_Case_Custom__c
                                          WHERE Id =: recordId
                                          LIMIT 1];
            
            if(caseRec.CLQ_Complainant_City__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_City;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_City__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_County_Complainant__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_County_Complainant;
                CPIRecord.Field_Value__c= caseRec.CLQ_County_Complainant__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Email__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Email;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Email__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_First_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_First_Name;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_First_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Last_Name__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Last_Name;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Last_Name__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Phone__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Phone;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Phone__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_State_Complainant__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_State_Complainant;
                CPIRecord.Field_Value__c= caseRec.CLQ_State_Complainant__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_State_Complainant__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_State_Complainant;
                CPIRecord.Field_Value__c= caseRec.CLQ_State_Complainant__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Street__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Street;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Street__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Zip_Code__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Zip_Code;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Zip_Code__c;
                recordsToInsert.add(CPIRecord);
            }
            if(caseRec.CLQ_Complainant_Street_2__c != null){
                CPIRecord = createStaticValues(recordId, screenURL, user);
                CPIRecord.Object_Name__c = CaseObj;
                CPIRecord.Field_Name__c = CLQ_Complainant_Street_2;
                CPIRecord.Field_Value__c= caseRec.CLQ_Complainant_Street_2__c;
                recordsToInsert.add(CPIRecord);
            }
        }
        
        finalizeCPIList(recordsToInsert);
        
        
    }
    public static void finalizeCPIList(List<OCLQS_CPI_Tracking__c> CPIRecs){
        for(OCLQS_CPI_Tracking__c record : CPIRecs){
            record.Name = 'Accessed ' + record.Object_Name__c + '.' + record.Field_Name__c + ' (id=' + record.Record_Id__c + ')';
        }
        
        try{
            insert CPIRecs;
        }catch(Exception e){
            
            sendEmail(CPIRecs);
        }
        
    }
    public static void sendEmail(List<OCLQS_CPI_Tracking__c> CPIRecList){
    /*    if(CPIRecList.size() > 0 && CPIRecList!=null){
            // First, reserve email capacity for the current Apex transaction to ensure
            // that we won't exceed our daily email limits when sending email after
            // the current transaction is committed.
            Messaging.reserveSingleEmailCapacity(CPIRecList.size());
            //replace Test_CPI_Email with data set name that's setup once finalized
            CPIEmails__c emailCustomSettings = CPIEmails__c.getValues('Test_CPI_Email');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(OCLQS_CPI_Tracking__c cpiRec : CPIRecList){
                // Now create a new single email message object
                // that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                
                // System.debug(emailCustomSettings.CPI_Email_To_Addresses__c);
                // System.debug(emailCustomSettings.CPI_CC_Email_Addresses__c);
                // Assign the addresses for the To and CC lists to the mail object.
                //mail.setToAddresses();
                
                mail.setToAddresses(new String[]{Label.CPIEmailAddress});
                //mail.setCcAddresses(emailCustomSettings.CPI_CC_Email_Addresses__c.split(','));
                
                // Specify the address used when the recipients reply to the email. 
                mail.setReplyTo(Label.CPIEmailAddress);
                
                // Specify the name used as the display name.
                mail.setSenderDisplayName('OCLQS Admin');
                
                // Specify the subject line for your email address.
                // Use custom setting to set Subject Line
                mail.setSubject('[ACTION REQUIRED] Failed to automatically log CPI Record in OCLQS');
                
                // Set to True if you want to BCC yourself on the email.
                mail.setBccSender(false);
                
                // Optionally append the salesforce.com email signature to the email.
                // The email address of the user executing the Apex Code will be used.
                mail.setUseSignature(false);
                
                // Specify the text content of the email.
                // Use custom setting with email body here
                String plainTextBody = 'The following CPI related information failed to log automatically in OCLQS: <br/><br/>';
                plainTextBody = plainTextBody + 'User: ' + cpiRec.User_First_Name__c + ' ' +   cpiRec.User_Last_Name__c + '<br/><br/>';
                plainTextBody = plainTextBody + 'Username: ' + cpiRec.Username__c  + '<br/><br/>' ;
                plainTextBody = plainTextBody + 'Employee Id: ' + cpiRec.Employee_Id__c + '<br/><br/>';
                plainTextBody = plainTextBody + 'URL Accesssed: ' + cpiRec.Screen_URL__c + '<br/><br/>';
                plainTextBody = plainTextBody + 'Time of Event: ' + System.now() + '<br/><br/>';
                plainTextBody = plainTextBody + 'Please notify the Security team for remedial actions in accordance with compliance policies <br/><br/>';
                
                //mail.setPlainTextBody(plainTextBody);
                //or use this
                mail.setHtmlBody(plainTextBody);
                
                // Add the email you have created to list of emails sent in this transaction.
                mails.add(mail);
                
            }//end for loop
            //send all emails we have to send
            Messaging.sendEmail(mails);
        }//end if*/
    }//end method
}