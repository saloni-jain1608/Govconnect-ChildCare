public class ApplicationInfo {
    public String Id {get; set;}
    public String PageTitle {get; set;}
    public String PageType {get; set;}
    public String TransactionRecordType {get; set;}
    public String ProgramRecordType {get; set;}
    public String Instructions_to_Application {get; set;}
    public List<PageSection> Sections {get; set;}

    public ApplicationInfo(PGFPage__c page){
        this.Id = String.valueOf(page.Id);
        this.PageTitle = page.PageTitle__c;
        this.PageType=page.PageType__c;
        this.TransactionRecordType=page.TransactionRecordType__c;
        this.ProgramRecordType=page.ProgramRecordType__c;
        this.Instructions_to_Application = page.Instructions_to_Application__c;

        this.Sections = new List<PageSection>();
    }
}