public class PageSection {
    public String Id {get; set;}
    public Decimal OrderNumber {get; set;}
    public String Label {get; set;}
    public List<PageSubSection> SubSections {get; set;}
    public String Status {get; set;}
    public String Name {get; set;}

    public PageSection(PGFSection__c section, String sStatus, string language){
        this.Id = String.valueOf(section.Id);
        this.OrderNumber = section.OrderNumber__c;
        this.Label = section.Label__c;
        this.SubSections = new List<PageSubSection>();
        this.Status = sStatus;
        this.Name = section.Name;
    }
}