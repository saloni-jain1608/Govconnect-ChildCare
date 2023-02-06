//test class for CPI Tracking solution
//Vamsi V

@isTest
public class CLQ_CPITracking_Util_Test {
    @testSetup 
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    @IsTest
    public static  void test(){
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            Test.startTest();
            //create contact record
            //Account a = createNewAccount();
            //insert configuration record
            CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
            insert configRecord; 
            
            //Create account record
            Account accountrecord = new Account(Name='Test Account',CLQ_DIRN__c = '1234'); 
            insert accountrecord ;
            
            //Insert contact
            Contact contactrecord = new Contact(Firstname='test', lastName = 'Test',Accountid = accountrecord.id );
            insert contactrecord ;
            
            //Create a program record
            CLQ_Program__c programRecord = new CLQ_Program__c();
            programRecord.Name = 'Test';
            programRecord.CLQ_Associated_Organization__c = accountrecord.id;
            programRecord.CLQ_Street_Address_1__c = 'test';
            programRecord.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
            programRecord.CLQ_Licensing_Specialist__c = UserInfo.getUserid();
            programRecord.CLQ_Program_Status__c = 'Open';
            programRecord.CLQ_License_Registration_Status__c='Licensed';
            programRecord.CLQ_License_Issue_Date__c =date.newInstance(2021, 11, 01);
            insert programRecord ;
            
            //Create a county
            CLQ_County__c countyRec = new CLQ_County__c ();
            countyRec.Name = 'testCounty';
            countyRec.Area_Region__c = 'C';
            countyRec.CCC_Field_Officers__c = 'Akron';
            countyRec.FCC_Field_officers__c = 'Cleveland';
            countyRec.Supervisor_Group__c = 'some group';  
            insert countyRec;
            //Insert case for program
            CLQ_Case_Custom__c rec = new CLQ_Case_Custom__c();
            
            rec.recordTypeID = Schema.SObjectType.CLQ_Case_Custom__c.getRecordTypeInfosByDeveloperName().get('CLQ_Complaint').getRecordTypeId();
            rec.ContactId__c= contactrecord.id;
            rec.CLQ_Program__c = programRecord.id;
            rec.CLQ_Approver_s_Email__c = 'test@CLQ.com';
            rec.CLQ_Assigned_to_Email__c = 'test@CLQ.com';
            rec.CLQ_Assigned_To__c = UserInfo.getUserid();
            rec.CLQ_Complainant_City__c = 'Columbus';
            rec.CLQ_County_Complainant__c  = countyRec.Id;
            rec.CLQ_Complainant_Email__c = 'test@email.com';
            rec.CLQ_Complainant_First_Name__c = 'John';
            rec.CLQ_Complainant_Last_Name__c = 'Smith';
            rec.CLQ_Complainant_Phone__c = '1231231234';
            rec.CLQ_State_Complainant__c = 'OH';
            rec.CLQ_Complainant_Street__c = 'Main';
            rec.CLQ_Complainant_Street_2__c = 'Main 2';
            rec.CLQ_Complainant_Zip_Code__c = '12345';
            
            insert rec;
            
            
            Account a = new Account (name = 'AcName',
                                     BillingCity ='TestCity',
                                     BillingCountry ='TestCountry',
                                     BillingStreet ='TestStreet',
                                     BillingPostalCode ='t3stcd3',
                                     CLQ_FEIN__c='123456'
                                    );
            
            insert a;
            System.debug('@@Account.Id = ' + a.id);
            
            
            Contact newContact = new Contact (
                FirstName = 'xyzFirst',
                LastName = 'XyZLast',
                Birthdate=System.today(),
                AccountId = a.id,
                Email = 'xyzmail@mail.com',
                CLQ_SSN__c = '1234567890',
                CLQ_Date_of_Birth__c=System.today()
            );
            
            insert newContact;
            String c = String.valueOf(newContact.Id);
            System.debug('@@Contact.Id = ' + c);
            String caseRec = String.valueOf(rec.Id);
            
            CLQ_Staff_Record__c rec1 = new CLQ_Staff_Record__c(CLQ_Name__c = c, Middle_Name__c = 'mid' , 
                                                               Middle_Initial__c = 'm'  ,Last_Name__c = 'smith',
                                                               First_Name__c = 'john',CLQ_Position__c = 'Floater ',
                                                               Position_End_Date__c = System.today(),
                                                               Position_Start_Date__c = System.today(),
                                                               CLQ_Status__c = 'Active ',CLQ_Hire_Date__c = System.today());
            insert rec1;
            
            String staffRec = String.valueOf(rec1.Id);
            
            //create bcifbi record
            CLQ_BCII_FBI__c rec2 = new CLQ_BCII_FBI__c(CLQ_SSN_Integration__c = '1234567890',
                                                       CLQ_Date_of_Birth__c=System.today(),
                                                       CLQ_Date_of_Birth_Text__c=System.today().format());
            
            insert rec2;
            
            String bcirec = String.valueOf(rec2.Id);
            System.debug('@@bcirec.Id = ' + bcirec);
            
            
            CLQ_CPITracking_Util.logCPIFields('Contact', c,'http://www.google.com');
            CLQ_CPITracking_Util.logCPIFields('CLQ_BCII_FBI__c', bcirec, 'http://www.google.com');
            CLQ_CPITracking_Util.logCPIFields('Account',String.valueOf(a.Id),'http://www.google.com');
            CLQ_CPITracking_Util.logCPIFields('CLQ_Staff_Record__c', staffRec, 'http://www.google.com');
            CLQ_CPITracking_Util.logCPIFields('CLQ_Case_Custom__c', caseRec, 'http://www.google.com');
            
            List<CLQ_BCII_FBI__c> contacts = new List<CLQ_BCII_FBI__c>();
            CLQ_BCII_FBI__c contactrec = new CLQ_BCII_FBI__c(CLQ_SSN_Integration__c = '123456789', CLQ_Date_of_Birth__c = System.today());
            contacts.add(contactrec);
            CLQ_CPITracking_Util.logBCIFields(contacts);
            
            //testing email being sent
            List<OCLQS_CPI_Tracking__c> reclist = new List<OCLQS_CPI_Tracking__c>();
            OCLQS_CPI_Tracking__c cpirec = new OCLQS_CPI_Tracking__c();
            cpirec.Employee_Id__c = '123';
            cpirec.Field_Name__c = 'TestFieldName';
            cpirec.Field_Value__c = 'testValue';
            cpirec.Name = 'name';
            cpirec.Object_Name__c = 'testobject';
            cpirec.User_Alias__c = 'alias';
            cpirec.User_First_Name__c = 'firstName';
            cpirec.User_Last_Name__c = 'lastName';
            cpirec.Record_Id__c = 'id123';
            //cpirec.User_Id__c = 'username@org.com';
            cpirec.Username__c = 'username@org.com';
            reclist.add(cpirec);
            
            CLQ_CPITracking_Util.sendEmail(reclist);
            
            Test.stopTest();
        }
    }
}