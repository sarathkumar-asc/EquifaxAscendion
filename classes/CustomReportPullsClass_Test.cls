/*
 * @Apex Class Name: customReportpullClass
 * @Created By: Bhupati Muralimohan
 * @Created Date: 02-21-2025
 * @purpose: This Apex is a test class for CustomReportPullsClass . 
*/
@isTest
public class CustomReportPullsClass_Test {
    
    @TestSetup
    static void initData()
    {
        CreditReviewReport__c cr = new CreditReviewReport__c();
        cr.Paynet_Report_Status__c = 'Test';
        cr.Equifax_Report_Status__c = 'test';
        cr.SetupOwnerId  = UserInfo.getUserId();
        cr.Status_Percentage__c = 100;
        insert cr;
        //Creating US Credit Policy
        forseva1__CreditPolicy__c us_cp = new forseva1__CreditPolicy__c(name = 'PASS', forseva1__Default_Policy__c = true, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
        insert us_cp;
        Date myDate = date.newInstance(1997,05,22);
        //Creating Accounts        
        List<Account>  aclist = new List<Account>();
        List<Contact> listContact = new List<Contact>();
        aclist.add(new Account(name = 'ALEL Technologies LLC',Industry = 'Mining', forseva1__Credit_Policy__c = us_cp.Id));       
        aclist.add(new Account(name = 'Test LLC',Industry = 'Mining', forseva1__Credit_Policy__c = us_cp.Id));       
        insert aclist;
        Date d = system.today()-2000;
        listContact.add(new Contact(FirstName='Test1FN', LastName='Test1LS', accountId =aclist[0].ID, MailingStreet = '201 Addison path', MailingCity='JohnsCreek',MailingStatecode ='GA',MailingPostalCode='30005',Birth_Date__c = d, SSN__c = '132345345', MailingState ='Georgia'));
  
        insert listContact;
        forseva1__EquifaxCommercialCredit__c efxCommercial = new forseva1__EquifaxCommercialCredit__c();
        efxCommercial.forseva1__Account__c = aclist[0].ID;
        insert efxCommercial;
        
        forseva1__PaynetCreditHistoryReport__c efxPaynetCommercial = new forseva1__PaynetCreditHistoryReport__c();
        efxPaynetCommercial.forseva1__Account__c = aclist[0].ID;
        efxPaynetCommercial.forseva1__Master_Score__c = 380;
        insert efxPaynetCommercial;
        
        forseva1__EquifaxConsumer__c equifaxConsumer = new forseva1__EquifaxConsumer__c();
        equifaxConsumer.forseva1__Account__c = aclist[0].ID;
        
       // insert experianConsumer;
		Decision_Request__c  dR = new Decision_Request__c ();
		dR.Account__c = aclist[0].ID ;
        insert dR;
        
        
       // forseva1__CreditPolicy__c creditPolicy = new forseva1__CreditPolicy__c(Name = 'US BPR');
    	// insert creditPolicy;
    } 
    
    static testMethod void generateReportUnitTest() {
        CreditReviewReport__c crID = [select id from CreditReviewReport__c Limit 1];  
        map<Id, Account> mapAccountIds = new map<Id,Account>();
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        opp.CloseDate = system.today();
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        CreditReviewReport__c cr = new CreditReviewReport__c();
        cr.Id = crId.ID;
        cr.Equifax_Report_Status__c = 'report pulled';
        update cr;
        //customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, s1, 1); 
        
            
        
        
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        
    }
    
    static testMethod void generateReportUnitTest1() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 1);    
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 1);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest2() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 2); 
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 2);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        

        Test.StopTest();
        cs.loadStatus();
            }
    
    static testMethod void generateReportUnitTest3() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        

        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 3);  
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 3);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        Test.StopTest();
        cs.loadStatus();        
    }
    
    static testMethod void generateReportUnitTest4() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        

        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 4);    
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 4);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest5() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC' limit 1];
        system.debug('line----25'+listAccount);
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
         customReportpullClass cs = new customReportpullClass(sc);
        

        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 5);  
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 5);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest6() {
        
        
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        forseva1__EquifaxConsumer__c eConsumerReport = new forseva1__EquifaxConsumer__c();
        eConsumerReport.forseva1__Account__c = listContact[0].accountID;
        eConsumerReport.forseva1__Contact__c = listContact[0].ID;
        insert eConsumerReport;
        
    
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 1);   
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 1);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest7() {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        forseva1__EquifaxConsumer__c eConsumerReport = new forseva1__EquifaxConsumer__c();
        eConsumerReport.forseva1__Account__c = listContact[0].accountID;
        eConsumerReport.forseva1__Contact__c = listContact[0].ID;
        insert eConsumerReport;
        
    
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 2);  
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 2);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest8() 
    {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        forseva1__EquifaxConsumer__c eConsumerReport = new forseva1__EquifaxConsumer__c();
        eConsumerReport.forseva1__Account__c = listContact[0].accountID;
        eConsumerReport.forseva1__Contact__c = listContact[0].ID;
        insert eConsumerReport;
        
    
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 3); 
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 3);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest9() 
    {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        forseva1__EquifaxConsumer__c eConsumerReport = new forseva1__EquifaxConsumer__c();
        eConsumerReport.forseva1__Account__c = listContact[0].accountID;
        eConsumerReport.forseva1__Contact__c = listContact[0].ID;
        insert eConsumerReport;
        
      
    
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 4);  
        
        
        PullPaynetCommercialReportQueueable pullPaynetQueueable = new PullPaynetCommercialReportQueueable(listContact[0].accountID, listContactIDs, dR[0].ID);
        
        
        system.enqueueJob(pullPaynetQueueable);
        
        
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 4);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest10() 
    {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);    
            
        }
        Test.StartTest();
        forseva1__EquifaxConsumer__c eConsumerReport = new forseva1__EquifaxConsumer__c();
        eConsumerReport.forseva1__Account__c = listContact[0].accountID;
        eConsumerReport.forseva1__Contact__c = listContact[0].ID;
        insert eConsumerReport;
        
    
        
        customReportpullClass.pullEquifax_ConsumerForFC(listContactIDs, dR[0].ID, 5);  
        pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, dR[0].ID, 5);
        System.enqueueJob(EquifaxconsumerQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest11() 
    {
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
    	try{
            pullEquifaxCommercialandConsumerReports.efxCommercialReport(listAccount[0].ID);
            pullEquifaxCommercialandConsumerReports.efxPaynetReport(listAccount[0].ID);
        	pullEquifaxCommercialandConsumerReports.pullBPRReport(listAccount[0].ID,'Equifax');
            pullEquifaxCommercialandConsumerReports.pullPaynetReport(listAccount[0].ID,'Equifax');
        }
        catch(exception e){
            
        }
    }        
      
	static testMethod void generateReportUnitTest12() 
    {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);     
        }
        Test.StartTest();
        forseva1__EquifaxBusinessPrincipalReport__c eBPRReport = new forseva1__EquifaxBusinessPrincipalReport__c();
        eBPRReport.forseva1__Account__c = listContact[0].accountID;
        insert eBPRReport;
        forseva1__CreditPolicy__c usbpr_cp = new forseva1__CreditPolicy__c(name = 'US BPR', forseva1__Default_Policy__c = true, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
        insert usbpr_cp;
    
        
        customReportpullClass.pullBPRReport(listContact[0].accountID, listContactIDs, dR[0].ID); 
        PullBPRReportQueueable pullBPRQueueable = new PullBPRReportQueueable(listAccount[0].ID, new List<Id>(), dR[0].Id);
        pullBPRQueueable.accountId = listContact[0].accountID;
        pullBPRQueueable.DecisonRequest = dR[0].ID;
        pullBPRQueueable.listContactsIds = listContactIDs;
        system.enqueueJob(pullBPRQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }
    
    static testMethod void generateReportUnitTest13() 
    {
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        List<Account> acc = [select Id,Industry from Account where Name ='Test LLC'];
        forseva1__CreditPolicy__c usbpr_cp = new forseva1__CreditPolicy__c(name = 'US BPR', forseva1__Default_Policy__c = true, forseva1__First_Credit_Review_Product__c = 'test', forseva1__First_Prequalification_Product__c='test', forseva1__First_Verification_Product__c='test');
        insert usbpr_cp;
    	try{
            pullEquifaxCommercialandConsumerReports.efxCommercialReport(listAccount[0].ID);
            pullEquifaxCommercialandConsumerReports.efxPaynetReport(listAccount[0].ID);
        	pullEquifaxCommercialandConsumerReports.pullBPRReport(listAccount[0].ID,'Equifax');
            pullEquifaxCommercialandConsumerReports.pullPaynetReport(listAccount[0].ID,'Equifax');
            pullEquifaxCommercialandConsumerReports.efxCommercialReport(acc[0].ID);
            pullEquifaxCommercialandConsumerReports.efxPaynetReport(acc[0].ID);
        }
        catch(exception e){
            
        }
    }
    
    static testMethod void generateReportUnitTest14() 
    {
        List<Decision_Request__c> dR = [Select id from Decision_Request__c Limit 1 ];
        List<Account> listAccount = [select Id,Industry from Account where Name ='ALEL Technologies LLC'];
        system.debug('line----25'+listAccount);
        opportunity opp = new opportunity();
        opp.name= 'test';
        opp.StageName = 'Won';
        Date d = system.today();
        opp.CloseDate = d;
        opp.AccountId = listAccount[0].ID;
        insert opp;
		ApexPages.StandardController sc = new ApexPages.standardController(opp); 
       
        PageReference pageRef = Page.CreditReviewFromOpportunity; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(opp.Id));
        Test.setCurrentPage(pageRef);
        customReportpullClass cs = new customReportpullClass(sc);
        cs.pullEquifaxCommercialReport();
        cs.loadStatus();
        List<ID> listContactIDs = new List<ID>();
        List<Contact> listContact = [Select id,accountID,FirstName,LastName,MailingStreet, MailingCity, MailingStatecode, MailingPostalCode, Birth_Date__c,SSN__c,MailingState  from Contact where LastName='Test1LS'];
        for(Contact con: listContact){
        	listContactIDs.add(con.ID);     
        }
        Test.StartTest();
        forseva1__EquifaxBusinessPrincipalReport__c eBPRReport = new forseva1__EquifaxBusinessPrincipalReport__c();
        eBPRReport.forseva1__Account__c = listContact[0].accountID;
        insert eBPRReport;
    
        
        customReportpullClass.pullBPRReport(listContact[0].accountID, listContactIDs, dR[0].ID); 
        PullBPRReportQueueable pullBPRQueueable = new PullBPRReportQueueable(listAccount[0].ID, new List<Id>(), dR[0].Id);
        pullBPRQueueable.accountId = listContact[0].accountID;
        pullBPRQueueable.DecisonRequest = dR[0].ID;
        pullBPRQueueable.listContactsIds = listContactIDs;
        system.enqueueJob(pullBPRQueueable);
        forseva1__Scorecard__c fs  = new forseva1__Scorecard__c();
        fs.name = 'Decision Request';
        fs.forseva1__Source_Record_Type__c = 'Decision_Request__c';
        insert fs;
        
        Test.StopTest();
        cs.loadStatus();
    }

}