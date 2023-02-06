public class PageSubSection {
    public String Id {get; set;}
    public Decimal OrderNumber {get; set;}
    public String Type {get; set;}
    public String ComponentType {get; set;}
    public Boolean IsATextBlockType {get; set;}
    public String TextBlockBody {get; set;}
    public String Label {get; set;}
    public String ObjectName {get; set;}
    public String LookupObjectName {get; set;}
    public List<FormComponent> FormComponents {get; set;}
    public String RecordType {get; set;}
    public List<FormComponent> TableInfo {get; set;}
    public String WhereClause {get; set;}
    public String Section {get; set;}
    public list<sobject> lstObjs {get;set;}

    public List<PageField> Fields {get; set;}

    public PageSubSection(PGFSubSection__c subSection, string language){
        this.Id = String.valueOf(subSection.Id);
        this.OrderNumber = subSection.OrderNumber__c;
        this.Label = subSection.Label__c;
        this.Type = subSection.Type__c;
        this.IsATextBlockType = subSection.IsATextBlockType__c;
        this.TextBlockBody = subSection.TextBlockBody__c;
        this.Section = String.valueOf(subSection.Parent__c);
        this.ComponentType = subSection.ComponentAPIName__c;
        
        if(subSection.Type__c == 'Component'){
            this.ObjectName = subSection.ApplicableObject__c;
            this.LookupObjectName = subSection.Lookup_Object__c;
            this.RecordType = subSection.Applicable_Record_Type__c;
            this.WhereClause = subSection.QueryWhereClause__c;

            List<String> formLabels = subSection.Applicable_Form_Field_Labels__c != null ? subSection.Applicable_Form_Field_Labels__c.split(';') : new List<String>{};
            List<String> formFields = subSection.ApplicableFormFields__c != null ? subSection.ApplicableFormFields__c.split(';') : new List<String>{};
            this.FormComponents = new List<FormComponent>();

            for(Integer i = 0; i < formLabels.size(); i++){
                FormComponent formCmp = new FormComponent();
                formCmp.Label = formLabels[i];
                formCmp.FieldName = formFields[i];

                this.FormComponents.add(formCmp);
            }

            List<String> tableLabels = subSection.Applicable_Field_Labels__c != null ? subSection.Applicable_Field_Labels__c.split(';') : new List<String>{};
            List<String> tableFields = subSection.ApplicableFields__c != null ? subSection.ApplicableFields__c.split(';') : new List<String>{};

            this.TableInfo = new List<FormComponent>();

            for(Integer i = 0; i < tableLabels.size(); i++){
                FormComponent formCmp = new FormComponent();
                formCmp.Label = tableLabels[i];
                formCmp.FieldName = tableFields[i];

                this.TableInfo.add(formCmp);
            }
        }
        this.Fields = new List<PageField>();
    }

    public class FormComponent {
        public String Label {get; set;}
        public String FieldName {get; set;}
    }
}