/*
 * @Apex Class Name: PullPaynetCommercialReportQueueable
 * @Created By: Deepak kumar Reddy Regatte
 * @Created Date: 03-19-2021
 * @purpose: This Apex is called from customReportpullClass to pull 
             paynet Commercial Reports when a Business connect button is clicked by user. 
*/
public class PullPaynetCommercialReportQueueable implements Queueable , Database.AllowsCallouts {
    public Id accountId;
    public List<ID> listContactsIds;
    public Id DecisonRequest;
    
    public PullPaynetCommercialReportQueueable(Id accountId, List<ID> listContactsIds, Id DecisonRequest){
    this.accountId = accountId;
    this.listContactsIds =   listContactsIds;
    this.DecisonRequest = DecisonRequest;   
        
    }
    
    public void execute(QueueableContext context) {
    	forseva1__PaynetCreditHistoryReport__c efxPaynetobj = new forseva1__PaynetCreditHistoryReport__c();
        Decision_Request__c dR = new Decision_Request__c();
        string hit;
        try{
        	hit = pullEquifaxCommercialandConsumerReports.pullPaynetReport(accountId, 'Paynet');
            system.debug('Line----73'+hit);
            if(hit == 'Hit'){
            	efxPaynetobj = pullEquifaxCommercialandConsumerReports.efxPaynetReport(accountId);
                dR.Master_Score__c  = efxPaynetobj.forseva1__Master_Score__c;
                dR.PayNet_Credit_History_Report__c = efxPaynetobj.Id;
                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                cs.Paynet_Report_Status__c = '<br/> Initiating Paynet Report pull <br/> Paynet Report retrieved successfully. <br/>';
                update cs;
            }
            //dR.Exception_Found__c = (hit == 'Exception' ? true:false);
            if(hit == 'Exception'){
            	dR.Exception_Found__c = true;    
            }
            dR.Hit_No_Hit_PayNet__c = (hit == 'hit' ? 'Hit' : (hit == 'Nohit' ? 'No Hit' : ''));
            dR.ID = DecisonRequest;
            update dR;
        }catch(Exception e){    
        	system.debug('----Exception----'+e); 
            dR.Exception_Found__c =true;
            dR.ID = DecisonRequest;
            update dR;
        }        
     	
        /*----Commented by Ascednion : 7/1/25------
		Integer i =1;
        if(!listContactsIds.isEmpty() && listContactsIds!=null && !Test.isRunningTest()){
        	customReportpullClass.pullEquifax_ConsumerForFC(listContactsIds, DecisonRequest, i);    
        }else{
            pullEquifaxCommercialandConsumerReports.executeScoreCard(DecisonRequest);   
            CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
            cs.Status_Percentage__c = 100;
            update cs;    
        }
        ----Commented by Ascednion : 7/1/25------*/
        
        //call BPR - Added by by Ascednion : 7/1/25
        customReportpullClass.pullBPRReport(accountId, listContactsIds, DecisonRequest);
    }

}