/*
 * @Apex Class Name: customReportpullClass
 * @Created By: Deepak kumar Reddy Regatte
 * @Created Date: 03-19-2021
 * @purpose: This Apex is used to pull Equifax Reports when a Business connect button is clicked by user. 
*/

public class customReportpullClass {
    
    public Id accountId{get;set;}
    public Id opportunityId{get;set;}
    public String equifaxReport{get;set;}
    public String score{get;set;}
    
    public customReportpullClass(ApexPages.StandardController controller){
    	  
    	
        
        
    }

	public PageReference loadStatus() {
        equifaxReport ='';
        
        CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
        
        if(cs.Id != null){
            if(string.isnotEmpty(cs.Equifax_Report_Status__c) && !Test.isRunningTest()){
            	equifaxReport =   cs.Equifax_Report_Status__c +'<br/>';  
            }
            if(string.isnotEmpty(cs.Paynet_Report_Status__c)){
            	equifaxReport +=   cs.Paynet_Report_Status__c +'<br/>';  
            }
            if(string.isnotEmpty(cs.Equifax_DR_First_Contact__c)){
            	equifaxReport +=   cs.Equifax_DR_First_Contact__c +'<br/>';  
            }
            if(string.isnotEmpty(cs.Equifax_BPR_2nd_Contact_Status__c)){
            	equifaxReport +=   cs.Equifax_BPR_2nd_Contact_Status__c +'<br/>';  
            }
            if(string.isnotEmpty(cs.Equifax_BPR_3rd_Contact_Status__c)){
            	equifaxReport +=   cs.Equifax_BPR_3rd_Contact_Status__c +'<br/>';  
            }
            
            if(string.isnotEmpty(cs.Equifax_BPR_4th_Contact_Status__c)){
            	equifaxReport +=   cs.Equifax_BPR_4th_Contact_Status__c +'<br/>';  
            }
            
            if(string.isnotEmpty(cs.Equifax_BPR_5th_Contact_Status__c)){
            	equifaxReport +=   cs.Equifax_BPR_5th_Contact_Status__c +'<br/>';  
            }
            
            if(cs.Status_Percentage__c == 100){
                score = '100';
            	cs.Status_Percentage__c = 0;
                 cs.Equifax_Report_Status__c = '';
                 cs.Paynet_Report_Status__c = '';
                 cs.Equifax_DR_First_Contact__c = '';
                 cs.Equifax_BPR_2nd_Contact_Status__c ='';
                 cs.Equifax_BPR_3rd_Contact_Status__c ='';
                 cs.Equifax_BPR_4th_Contact_Status__c ='';
                 cs.Equifax_BPR_5th_Contact_Status__c ='';
                update cs;
         		/*PageReference page = new Pagereference('/'+opportunityId);
            	page.setRedirect(true);
            	return page;*/
        	}
            
        }
        
        
        
        return null;
    }
    
    public PageReference pullEquifaxCommercialReport(){
        opportunityId = ApexPages.CurrentPage().getParameters().get('id');      
        System.debug('Opportunity ID--->'+opportunityId);
        accountId = [Select Id, accountId From Opportunity Where Id =:opportunityId Limit 1].accountId;
        System.debug('Account ID--->'+accountId);
    	String hit;
        forseva1__EquifaxCommercialCredit__c efxCommercialReport = new forseva1__EquifaxCommercialCredit__c();
        Decision_Request__c dR = new Decision_Request__c();
        try{
        	hit = pullEquifaxCommercialandConsumerReports.pullEFXCommercialReport(accountId, 'Equifax');     
            if(hit =='Hit'){
            	efxCommercialReport =   pullEquifaxCommercialandConsumerReports.efxCommercialReport(accountId);
                if(efxCommercialReport!=null){
        			dR.Commercial_Insight_Delinquency_Score__c = efxCommercialReport.Commercial_Insight_Delinquency_Score__c;
                   	dr.Equifax_Commercial_Report__c	 = efxCommercialReport.Id;
                    CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                	cs.Equifax_Report_Status__c = '<br/> Initiating Equifax Commercial Report pull <br/> Equifax Commericial Report retrieved successfully.';
                	update cs;
             	}
            }
            system.debug('----84----'+hit);
            dR.Exception_Found__c = (hit == 'Exception' ? true:false);
            dR.Hit_No_Hit_EFX_Commercial__c = (hit == 'hit' ? 'Hit' : (hit == 'Nohit' ? 'No Hit' : ''));
            dR.Account__c = accountId;
        }catch(Exception e){    
        	system.debug('----Exception----'+e); 
            dR.Exception_Found__c =true;
            dR.Account__c = accountId;
        }
        insert dR;
        List<Contact> listContacts = new List<Contact>();
        List<ID> listContactID = new List<ID>();
        listContacts = [Select Id, SSN__c, Birth_Date__c, Firstname, Lastname,Name, MailingStreet, MailingCity, MailingState, MailingPostalCode
                                     From Contact where accountId=:accountId AND Is_Guarantor__c = true
                                     ORDER BY CreatedDate DESC Limit 5];
        for(Contact con: listContacts){
        	listContactID.add(con.ID);    
        }
        
        pullPaynetReport(accountId, listContactID, dR.ID);
        
        return null;
    }
    
    
    public static void pullPaynetReport(Id accountId, List<ID> listContactsIds, Id DecisonRequest){
    	
        PullPaynetCommercialReportQueueable pullPaynetQueueable = new PullPaynetCommercialReportQueueable(accountId, listContactsIds, DecisonRequest);
        system.enqueueJob(pullPaynetQueueable);
        
    }
    
    
    public static void pullEquifax_ConsumerForFC(List<Id> listContactIDs, ID DecisonRequest, Integer i){
    	pullEquifaxConsumerReportsupto5Pgs EquifaxconsumerQueueable = new pullEquifaxConsumerReportsupto5Pgs(listContactIDs, DecisonRequest, i);
        System.enqueueJob(EquifaxconsumerQueueable);
    }
    
    /*----Added by Ascednion : 7/1/25------*/
    public static void pullBPRReport(Id accountId, List<ID> listContactsIds, Id DecisonRequest){
    	
        PullBPRReportQueueable pullBPRQueueable = new PullBPRReportQueueable(accountId, listContactsIds, DecisonRequest);
        if(!Test.isRunningTest()){
        	system.enqueueJob(pullBPRQueueable);
        }
        
    }
	/*----Added by Ascednion : 7/1/25------*/
	    

}