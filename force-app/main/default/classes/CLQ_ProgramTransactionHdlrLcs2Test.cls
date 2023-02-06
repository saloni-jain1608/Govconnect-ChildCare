/*************************************************************************************************************
**************************************************************************************************************
** Name             : CLQ_ProgramTransactionHdlrLcs2Test
** Description      : N/A
** Version          : 1.1
**------------------------------------------------------------------------------------------------------------
** Modification Log:
**------------------
**  Developer               Date            Version      Description
**  N/A     				N/A				1.0         Initial Build 
**  Pavan Ayta				8/23/17			1.1			Added setExecuteControlSetting() for Task - 11615
**************************************************************************************************************/
@isTest
private class CLQ_ProgramTransactionHdlrLcs2Test {
    
    /*This test method covers CLQ_ProgramTransactionTrigHdlrLicsng class*/
    @IsTest
    static  void assignOwnerTest1() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[0]; 	//FCC - Type B Home - Application - FCC
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            system.debug('assignOwnerTest1 update');
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            //ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            //update ProgramTransaction;	
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            update ProgramTransaction;
            test.stopTest();
        }
        
    }	
    @IsTest
    static void assignOwnerTest2() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[2]; //Child Care Center - Application - CC Center
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;  
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            system.debug('assignOwnerTest2 update');
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            update ProgramTransaction;
            test.stopTest(); 
        }
        
    }	
    @IsTest
    static void assignOwnerTest3() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[4]; //In-Home Aide
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            update ProgramTransaction;
            system.debug('assignOwnerTest3 update');
            test.stopTest(); 
        }
    }	
    @IsTest
    static void assignOwnerTest4() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[5]; //Registration - Out of State
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            update ProgramTransaction;
            system.debug('assignOwnerTest4 update');
            
            test.stopTest(); 
        }
    }	
    @IsTest
    static void assignOwnerTest5() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[6]; //Application - ODE Program
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            update ProgramTransaction;
            system.debug('assignOwnerTest5 update');
            
            test.stopTest(); 
        }
    }	
    @IsTest
    static void assignOwnerTest6() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[8]; //Application - ODE Program
            ProgramTransaction.CLQ_Transaction_Type__c = 'Update';
            ProgramTransaction.CLQ_Registration_Status__c = 'Not Submitted'; 
            
            update ProgramTransaction; 
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false; 
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.ownerid = UserInfo.getUserId(); 
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false; 
            update ProgramTransaction;
            test.stopTest(); //
        }
    }	
    @IsTest
    static void assignOwnerTest7() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[10]; //change loc
            
            ProgramTransaction.CLQ_Fee_Paid__c = true;
            CLQ_County__c cnty = new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', 
                                                   Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert cnty;
            ProgramTransaction.CLQ_New_County__c = cnty.id  ;
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            //update ProgramTransaction;			
            //system.debug('assignOwnerTest7 update');
            
            test.stopTest(); 
        }
    }		
    
    @IsTest
    static void assignOwnerTest7a() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[10]; //change loc
            
            CLQ_Program__C pgm = [select id, CLQ_Licensing_Specialist__c from CLQ_Program__C where id = :ProgramTransaction.CLQ_Program__C ];
            pgm.CLQ_Licensing_Specialist__c = null;
            update pgm;
            
            ProgramTransaction.CLQ_Fee_Paid__c = true;
            CLQ_County__c cnty = new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert cnty;
            ProgramTransaction.CLQ_New_County__c = cnty.id  ;
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved'; //remove
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;			
            //system.debug('assignOwnerTest7 update');
            
            test.stopTest(); 
        }
    }		
    @IsTest
    static void assignOwnerTest8() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();
            system.debug('assignOwnerTest8 update');
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[9]; //day camp
            ProgramTransaction.CLQ_Transaction_Type__c = 'Update';
            ProgramTransaction.CLQ_Registration_Status__c = 'Not Submitted'; 
            
            update ProgramTransaction; 
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false; 
            
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            ProgramTransaction.ownerid = UserInfo.getUserId();
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;   
            //update ProgramTransaction;
            
            test.stopTest(); 
        }
    }
    @IsTest
    static void assignOwnerTest9() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[11]; //change loc ode
            
            ProgramTransaction.CLQ_Fee_Paid__c = true;
            CLQ_County__c cnty = new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', 
                                                   Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert cnty;
            ProgramTransaction.CLQ_New_County__c = cnty.id  ;
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved'; //remove
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;			
            //system.debug('assignOwnerTest9 update');
            
            test.stopTest(); 
        }
    }		
    @IsTest
    static void assignOwnerTest10() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[11]; //change loc ode
            
            ProgramTransaction.CLQ_Fee_Paid__c = true;
            CLQ_County__c cnty = new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', 
                                                   Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert cnty;
            ProgramTransaction.CLQ_New_County__c = cnty.id  ;
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Submitted'; //remove
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;			
            //system.debug('assignOwnerTest9 update');
            
            test.stopTest(); 
        }
    }	
    @IsTest
    static void assignOwnerTest11() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[12]; //change loc ode
            
            ProgramTransaction.CLQ_Fee_Paid__c = true;
            CLQ_County__c cnty = new CLQ_County__c(Name = 'FULTON', CCC_Field_Officers__c = 'Toledo', 
                                                   Area_Region__c='NW', FCC_Field_officers__c = 'Toledo' );
            insert cnty;
            ProgramTransaction.CLQ_New_County__c = cnty.id  ;
            
            ProgramTransaction.ownerid = UserInfo.getUserId();
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved'; //remove
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;			
            //system.debug('assignOwnerTest9 update');
            
            test.stopTest(); 
        }
    }
    @IsTest
    static void assignOwnerTest12() {
        system.assertEquals(True, 1==1,'Testing');
        system.runAs(new user(ID = UserInfo.getUserID())){
            map<Id,CLQ_Program_Transaction__c> ProgramTransactionMap = CLQ_UnitTestUtilities.ProgramTransactions;
            Test.StartTest();       
            CLQ_Program_Transaction__c ProgramTransaction = ProgramTransactionMap.values()[13]; //continuous license
            ProgramTransaction.ownerid = UserInfo.getUserId();
            update ProgramTransaction;
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            CLQ_GlobalWebserviceUtility.submitProgTrans(ProgramTransaction.id,'');
            //
            CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            
            //CLQ_Program_TransactionTriggerHandler.HasUpdated = false;
            ProgramTransaction.CLQ_Transaction_Status__c = 'Approved';
            update ProgramTransaction;			
            //system.debug('assignOwnerTest9 update');
            
            test.stopTest(); 
        }
    }			
    @TestSetup
    static void testSetup()
    {
        CLQ_UnitTestUtilities.setExecuteControlSetting();
        CLQ_UnitTestUtilities.HardCodedTransactionCreation();
        list<Group> queueGrps = new list<group>();
        
        
    }	
}