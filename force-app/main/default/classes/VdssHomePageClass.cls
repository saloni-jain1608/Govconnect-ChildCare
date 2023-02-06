public with sharing class VdssHomePageClass {
    public static final String GUEST='Guest';
    @AuraEnabled
    public static boolean isrendered(){
        boolean isrendered = true;
        try{
            if (UserInfo.getUserType() == GUEST) {
                isrendered = false;
            }
        }
        catch(exception e){
            system.debug('Exception:'+e);
        }
        return isrendered;    
    }
}