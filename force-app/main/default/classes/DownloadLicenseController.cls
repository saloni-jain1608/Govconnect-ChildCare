public class DownloadLicenseController {
    public String programid {get;set;}

    public DownloadLicenseController(){
        PageReference pageRef = ApexPages.currentPage();
        string currentUrl = pageRef.getUrl();  
        programid = pageRef.getParameters().get('selectedProgramId');
    }
    
}