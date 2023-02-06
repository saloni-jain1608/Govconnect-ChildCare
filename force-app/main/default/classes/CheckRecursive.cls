public with sharing class CheckRecursive {

    private static boolean run = true;
	private static boolean run_PT_actorid = true;
    
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
      }else{
          return run;
      }
    }
    
     public static boolean PT_actorid_once(){
        if(run_PT_actorid){
         run_PT_actorid=false;
         return true;
      }else{
          return run_PT_actorid;
      }
    }
}