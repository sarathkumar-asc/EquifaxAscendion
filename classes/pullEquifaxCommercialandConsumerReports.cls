/*
 * @Apex Class Name: pullEquifaxCommercialandConsumerReports
 * @Created By: Deepak kumar Reddy Regatte
 * @Created Date: 03-19-2021
 * @purpose: This Apex is called from customReportpullClass to pull 
             Equifax Reports when a Business connect button is clicked by user. 
*/
public class pullEquifaxCommercialandConsumerReports {
    
    Public static string pullEFXCommercialReport(ID acctid, String dataProvider){
        boolean hit;
        String sException;
        try {
                
           		forseva1.CommercialReportService crs = new forseva1.CommercialReportService(dataProvider);
              
           		hit = crs.performReviewCredit(acctid);//performPrequalification//performReviewCredit
                sException = hit?'Hit':'Nohit';
                system.debug('Line----18----'+hit);
        
           system.debug('-----Line22----'+hit); 
           
        }catch (Exception e) {
            string sForsevaException = e.getCause().getMessage(); 
            system.debug('Line----28----'+sForsevaException);
            if(sForsevaException!=null && sForsevaException.contains('Equifax did not find a company matching the request')){
            	sException ='NoHit';	    
            }
            else{
            	sException ='Exception';   
            }
            
            system.debug('EFX Commercial Report Exception :: '+e.getStackTraceString()+' :: '+e.getMessage());
        }
        return sException;
    }
    
    public static forseva1__EquifaxCommercialCredit__c efxCommercialReport(Id accountId){
        
        List<forseva1__EquifaxCommercialCredit__c> EFX_Commercial_ReportList = new List<forseva1__EquifaxCommercialCredit__c>([SELECT Id, forseva1__Account__c,Commercial_Insight_Delinquency_Score__c, forseva1__Account__r.Master_Score__c
                                                                                                                               FROM forseva1__EquifaxCommercialCredit__c
                                                                                                                               WHERE forseva1__Account__c =: accountId
                                                                                                                               ORDER BY CREATEDDATE DESC LIMIT 1]);
        
       
        if(!EFX_Commercial_ReportList.isEmpty()){
        	return EFX_Commercial_ReportList.get(0);    
        }else{
            return null;
        }    
    }
    
    Public static string pullPaynetReport(ID acctid, String dataProvider){
        boolean hit;
        String sException; 
        try {
            if(!Test.isRunningTest()){
                forseva1.CommercialReportService crs = new forseva1.CommercialReportService(dataProvider);            	
                hit = crs.performPrequalification(acctid);
                sException = hit?'Hit':'Nohit';
                system.debug('hit  ---> '+hit); 
            }else{
                
                sException ='Hit';
                
            }
            
        }catch (Exception e) {
            system.debug('Line----71----'+e.getCause().getmessage());
            string sForsevaException = e.getCause().getMessage(); 
            
            if(sForsevaException!=null && sForsevaException.contains('Equifax did not find a company matching the request')){
            	sException ='NoHit';	    
            }else{
             	sException ='Exception';   
            }
            
            system.debug('Paynet Exception :: '+e.getStackTraceString()+' :: '+e.getMessage());
        }
               
        return sException;
        
    }
    
    public static forseva1__PaynetCreditHistoryReport__c efxPaynetReport(Id accountId){
        
        List<forseva1__PaynetCreditHistoryReport__c> EFX_Paynet_ReportList = new List<forseva1__PaynetCreditHistoryReport__c>([SELECT Id, forseva1__Account__c,forseva1__Master_Score__c 
                                                                                                                               FROM forseva1__PaynetCreditHistoryReport__c
                                                                                                                               WHERE forseva1__Account__c =: accountId
                                                                                                                               ORDER BY CREATEDDATE DESC LIMIT 1]);
        
       
        if(EFX_Paynet_ReportList!=null && !EFX_Paynet_ReportList.isEmpty()){
        	return EFX_Paynet_ReportList.get(0);    
        }else{
            return null;
        }    
    }
    
    /*----Added by Ascednion : 7/1/25------*/
	Public static Map<String,forseva1__EquifaxBusinessPrincipalReport__c> pullBPRReport(ID acctid, String dataProvider){
        String sException; 
        forseva1__EquifaxBusinessPrincipalReport__c efxBPRReport = new forseva1__EquifaxBusinessPrincipalReport__c();
        Map<String,forseva1__EquifaxBusinessPrincipalReport__c> bprReport = new Map<String,forseva1__EquifaxBusinessPrincipalReport__c>();
        try {
            
                List<forseva1__CreditPolicy__c> BPRPolicyList = [SELECT Id FROM forseva1__CreditPolicy__c WHERE Name = 'US BPR' LIMIT 1];
                if(BPRPolicyList.size() == 0){
                    sException ='Exception';
                	bprReport.put(sException, efxBPRReport);
                    return bprReport;
                }
            if(!Test.isRunningTest()){
                forseva1.CommercialReportService crs = new forseva1.CommercialReportService(dataProvider);            	
                efxBPRReport = (forseva1__EquifaxBusinessPrincipalReport__c) crs.performCreditRequest(acctid,BPRPolicyList[0].Id,'Credit Review');
				system.debug('efxBPRReport=='+efxBPRReport);
                sException = (efxBPRReport.forseva1__Commercial_Hit_Indicator__c || efxBPRReport.forseva1__Consumer_Hit_Indicator__c) ?'Hit':'Nohit';
                bprReport.put(sException, efxBPRReport);
            }else{
                
                sException ='Hit';
                bprReport.put(sException, efxBPRReport);
                new System.NullPointerException();
                Integer i = 1/0;
            }
        }catch (Exception e) {
            system.debug('Line----71----'+e);
            string sForsevaException = e.getMessage(); 
            
            if((sForsevaException!=null) && 
               (sForsevaException.contains('Equifax did not find a company matching the request') || 
                                          sForsevaException.contains('Equifax did not find a company nor a person matching the request'))){
            	sException ='NoHit';	
                bprReport.put(sException, efxBPRReport);
            }else{
             	sException ='Exception'; 
                bprReport.put(sException, efxBPRReport);
            }
            
            system.debug('BPR Exception :: '+e.getStackTraceString()+' :: '+e.getMessage());
        }
               
        return bprReport;
    }
    /*----Added by Ascednion : 7/1/25------*/
    
    public static forseva1.Person getCreditPerson(Contact con){
        forseva1.Person p = new forseva1.Person();
        p.FirstName = con.FirstName;
        p.LastName = con.LastName;
        p.UnparsedAddress = con.MailingStreet; 
        p.City = con.MailingCity;
        p.State = con.MailingState;
        p.PostalCode = con.MailingPostalCode;
        p.personId = con.Id;
        
        if(con.SSN__c != null) {
            p.SSN = con.SSN__c.replaceAll('[^a-zA-Z0-9\\s+]', '');
        }
        
        if (con.Birth_Date__c != null)
            p.age = con.Birth_Date__c.monthsBetween(Date.today())/12;
        if (p.age < 14 || p.age > 120) {
            p.age = null;
        }  
        
        return p;
    }
    
    Public static String pullEFX_ConsumerReport(ID acctid, String dataProvider, Contact con){
        
        String consumerStatus = null;
        try {
            forseva1.Person person = getCreditPerson(Con);
            forseva1.ConsumerReportService crs = new forseva1.ConsumerReportService();
            if(!Test.isRunningTest()){
            	consumerStatus = crs.getCreditReport(person, acctid, new List<String>(), 'accountId:' + acctid);
            }else{
                consumerStatus = 'hit';    
            }
            system.debug('consumerStatus  ---> '+consumerStatus); 
            consumerStatus = (consumerStatus == 'Hit'?'hit':(consumerStatus == 'no-hit')?'Nohit':(consumerStatus == 'error')?'Exception':'');
            system.debug('consumerStatus  ---> '+consumerStatus);
            
        }catch (Exception e) {
            
            consumerStatus = 'Exception';
            system.debug('EFX Consumer Report Exception :: '+e.getStackTraceString()+' :: '+e.getMessage());
        }
        
        return consumerStatus;
        
    }
    
    
    public static forseva1__EquifaxConsumer__c getEquifaxConsumerReport(Id contactID){
        
        List<forseva1__EquifaxConsumer__c> EFX_Consumer_ReportList = new List<forseva1__EquifaxConsumer__c>([SELECT Id, forseva1__Account__c,forseva1__Contact__c , BNI__c,High_Credit_Amount__c,forseva1__eqScrBeacon__c 
                                                                                                             FROM forseva1__EquifaxConsumer__c
                                                                                                             WHERE forseva1__Contact__c  =: contactID 			
                                                                                                             ORDER BY CREATEDDATE DESC LIMIT 1]);
        if(!EFX_Consumer_ReportList.isEmpty()){
        	return EFX_Consumer_ReportList.get(0);    
        }else{
            return null;
        }   
    }
    
    public Static void executeScoreCard(Id Decisionrequest){
         //Decisonrequest query
         List<Decision_Request__c> listdecisionRequestrecord = [select Id, Account__c, BPR_1_2_TP__c, BPR_1_3_TP__c,
                                                                BPR_1_4_TP__c, BPR_1_5_TP__c, BPR_Average_Points__c, BPR_Total_Points__c,
                                                                Commercial_Delinquency_Score_Points__c, Commercial_Insight_Delinquency_Score__c,
                                                                Master_Score_Points__c, Master_Score__c, Number_of_PGs__c, PASS_Score__c,
                                                                PG1_Beacon__c, PG1_Name__c, PG1_Points__c, PG2_Beacon__c, PG2_Name__c,
                                                                PG2_Points__c, PG3_Beacon__c, PG3_Name__c, PG3_Points__c, PG4_Beacon__c, 
                                                                PG4_Name__c, PG4_Points__c, PG5_Beacon__c, PG5_Name__c, PG5_Points__c,
                                                                Review_Date__c, Review_Status__c, Minimum_Yield__c, Probability_of_Default__c,
                                                                Loan__c, Reduced_Payment__c, Payment_and_Fees__c, Total_Consumer_Scores__c,
                                                                Consumer_Scores_Average__c, PG1_BNI__c, PG2_BNI__c, PG1_High_Credit__c,
                                                                PG2_High_Credit__c, PG4_High_Credit__c, PG3_BNI__c, PG3_High_Credit3__c,
                                                                PG4_BNI__c, PG5_High_Credit__c, PG5_BNI__c, fml_BKI_Score__c, fml_EquifaxConsumerScore__c,
                                                                fml_PayNetMasterScore__c, fml_CIDSScore__c, fml_PASS__c, fml_BKI_Image__c,
                                                                PG1_Equifax_Consumer_Report__c, PG2_Equifax_Consumer_Report__c,
                                                                PG1_Equifax_Consumer_Report_Link__c, PG2_Equifax_Consumer_Report_Link__c,
                                                                Equifax_Commercial_Report__c, Equifax_Commercial_Report_Link__c, PayNet_Credit_History_Report__c,
                                                                NoContactPoints__c, PG3_Equifax_Consumer_Report__c, PG4_Equifax_Consumer_Report__c,
                                                                PG5_Equifax_Consumer_Report__c, Exception_Found__c, PG3_Equifax_Consumer_Report_Link__c,
                                                                PG4_Equifax_Consumer_Report_Link__c, PG5_Equifax_Consumer_Report_Link__c,
                                                                Hit_No_Hit_EFX_Commercial__c, Hit_No_Hit_PayNet__c, Hit_No_Hit_PG1__c, Hit_No_Hit_PG2__c,
                                                                Hit_No_Hit_PG3__c, Hit_No_Hit_PG4__c, Hit_No_Hit_PG5__c, OneScore__c, 
                                                                OneScore_Summary__c, OneScore_Type__c, PG_OneScore_Values__c from Decision_Request__c where Id=:Decisionrequest];
        
            // code to retrieve the scorecard Id for the context. HS vs CSP
         
         List<Id> emptySecondarySCList = new List<Id>();
		
             forseva1__Scorecard__c fscorecard = [select id,name from forseva1__Scorecard__c where name = 'Decision Request' Limit 1];
             forseva1.ScorecardService scService = new forseva1.ScorecardService();
             if(!listdecisionRequestrecord.isEmpty() && fscorecard!=null &&  !Test.isRunningTest()){
                 
                scService.executeScorecards(listdecisionRequestrecord,fscorecard.Id, emptySecondarySCList);
             }
		 
    }
    
}