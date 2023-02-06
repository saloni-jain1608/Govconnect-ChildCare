@isTest
public class ReviewPdfPageControllerTest {
    @testsetup //Added method for Task - 11615
    public static void setExecuteControlSetting()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
    }
    
    @IsTest
    public static void TestMethod1(){
        system.assertEquals(True, 1==1,'Testing');
        CLQ_OCLQS_Configuration__c configRecord = new CLQ_OCLQS_Configuration__c(Name = 'FCC - Type B Home');
        insert configRecord; 
        
        User usr=CLQ_UnitTestUtilities.AddCustomerUser();
        Account Acc= new Account();
        Acc.Id=usr.AccountId;
        Acc.Name='test 123';
        Acc.Provider_Type__c='Child Care Center';
        Acc.Ownership='Individual Ownership';
        upsert Acc;
        
        
        
        CLQ_Program__c programRecord1 = new CLQ_Program__c();
        programRecord1.Name = 'Test';
        programRecord1.CLQ_Associated_Organization__c = usr.AccountId;
        programRecord1.CLQ_Street_Address_1__c = 'test';
        programRecord1.recordTypeid = Schema.SObjectType.CLQ_Program__c.getRecordTypeInfosByDeveloperName().get('CLQ_FCC_Type_B_Home').getRecordTypeId();
        programRecord1.CLQ_Program_Rating__c = 3;
        programRecord1.Program_Rating__c = '3';
        programRecord1.CLQ_License_Type__c = '  Continuous';
        programRecord1.CLQ_License_Registration_Status__c = 'Exempt';
        programRecord1.Rating_Anniversary_Date__c = Date.today();
        programRecord1.CLQ_Is_Withdrawn__c=false;
        Insert programRecord1;
        
        Test.startTest();
        
        
        PGFPage__c pgfP = new PGFPage__c();
        pgfP.Name = 'Licensing - New Application';
        pgfP.Success_Message_Body__c ='CLQ_Program_Name';
        insert pgfP;
        
        PGFSection__c pgfS = new PGFSection__c();
        pgfS.Parent__c = pgfP.Id;
        pgfS.Name = 'new Section';
        pgfS.OrderNumber__c = 45;
        insert pgfS;
        
        PGFSubSection__c pgfSS = new PGFSubSection__c();
        pgfSS.Parent__c = pgfS.Id;
        pgfSS.Name = 'ss Name';
        pgfSS.OrderNumber__c = 35;
        pgfSS.Type__c ='Component';
        pgfSS.Applicable_Form_Field_Labels__c = 'Open';
        pgfSS.ApplicableFormFields__c ='Open';
        pgfSS.Applicable_Field_Labels__c = 'Close';
        pgfSS.ApplicableFields__c ='Close';
        insert pgfSS;
        
        List<PGFField__c> fieldsReq = new List<PGFField__c>() ;
        fieldsReq.add(
            new PGFField__c(
                Name = 'CLQ_Proposed_Open_Date__c' ,
                CSSClasses__c ='col-md-4' ,
                Label__c ='Proposed Open Date' ,
                ObjectAPIName__c = 'CLQ_Program_Transaction__c' ,
                Type__c ='Date' ,
                OrderNumber__c = 2 ,
                Parent__c =  pgfSS.Id ,
                Required__c = true
            )   
        ); 
        
        
        INSERT fieldsReq ;
        
        
        CLQ_Program_Transaction__c programTransaction1 = new CLQ_Program_Transaction__c();
        programTransaction1.CLQ_Program__c = programRecord1.Id;
        programTransaction1.recordTypeid = Schema.SObjectType.CLQ_Program_Transaction__c.getRecordTypeInfosByDeveloperName().get('Annual_Report').getRecordTypeId();
        programTransaction1.CLQ_Rating_Confirmed_by_Program__c = '2';
        programTransaction1.CLQ_Transaction_Status__c = 'Not Complete';
        insert programTransaction1;
        
        Map<String, Object> fields=new Map<String, Object>();
        fields.put('label', '123');
        fields.put('Value','2' );
        fields.put('ObjectApi', 'CLQ_Program__c');
        fields.put('Type', 'Multi-Select');
        fields.put('FieldApi', 'Program_Rating__c');
        
        Map<String, Object> fields1=new Map<String, Object>();
        fields1.put('label', '123');
        fields1.put('Value', Date.today() );
        fields1.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields1.put('Type', 'Date');
        fields1.put('FieldApi', 'CLQ_Certificate_Issue_Date__c');
        
        Map<String, Object> fields2=new Map<String, Object>();
        fields2.put('label', '123');
        fields2.put('Value',5 );
        fields2.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields2.put('Type', 'Number');
        fields2.put('FieldApi', 'CLQ_Number_of_Residents__c');
        
        Map<String, Object> fields3=new Map<String, Object>();
        fields3.put('label', '123');
        fields3.put('Value',3 );
        fields3.put('ObjectApi', 'CLQ_Program__c');
        fields3.put('Type', 'Number');
        fields3.put('FieldApi', 'CLQ_Program_Rating__c');
        
        Map<String, Object> fields4=new Map<String, Object>();
        fields4.put('label', '123');
        fields4.put('Value', Date.today());
        fields4.put('ObjectApi', 'CLQ_Program__c');
        fields4.put('Type', 'Date');
        fields4.put('FieldApi', 'Rating_Anniversary_Date__c');
        
        Map<String, Object> fields5=new Map<String, Object>();
        fields5.put('label', '123');
        fields5.put('Value','2' );
        fields5.put('ObjectApi', 'CLQ_Program_Transaction__c');
        fields5.put('Type', 'Multi-Select');
        fields5.put('FieldApi', 'CLQ_Rating_Confirmed_by_Program__c');
        
        list<Map<String, Object>> fieldlist=new list<Map<String, Object>>();
        fieldlist.add(fields);
        fieldlist.add(fields1);
        fieldlist.add(fields2);
        fieldlist.add(fields3);
        fieldlist.add(fields4);
        fieldlist.add(fields5);
        
        Map<String, Object> subsection=new Map<String, Object>();
        subsection.put('label', 'Fieldset');
        subsection.put('Type', 'Fieldset');
        subsection.put('Name', pgfSS.Name);
        subsection.put('status',  pgfSS.Applicable_Form_Field_Labels__c);
        subsection.put('Fields',  fieldlist);
        
        
        list<Map<String, Object>> sectionlist=new list<Map<String, Object>>();
        list<Map<String, Object>> subsectionlist=new list<Map<String, Object>>();
        subsectionlist.add(subsection);
        
        Map<String, Object> sections=new Map<String, Object>();
        sections.put('label', 'Fieldset');
        sections.put('Name', pgfSS.Name);
        sections.put('status',  pgfSS.Applicable_Form_Field_Labels__c);
        sections.put('SubSections',  subsectionlist);
        
        sectionlist.add(sections);
        
        PageReference pageRef = Page.ReviewPdfPage;
        pageRef.getParameters().put('programTransactionId',programTransaction1.id);
        pageRef.getParameters().put('selectedProgramId',programRecord1.id);
        Test.setCurrentPage(pageRef);
        
        ReviewPdfPageController ReviewCtrl=new ReviewPdfPageController();
        Test.stopTest();
        
    }
}