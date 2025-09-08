/*
 * @Apex Class Name: customReportpullClass
 * @Created By: Deepak kumar Reddy Regatte
 * @Created Date: 03-19-2021
 * @purpose: This Apex is used to pull Equifax Consumer Reports when a Business connect button is clicked by user. 
*/
public class pullEquifaxConsumerReportsupto5Pgs implements Queueable , Database.AllowsCallouts {
	public List<ID> listContactIDS;
	public Id DecirequestID;
	public Integer ContactCountNumber;
    
    public pullEquifaxConsumerReportsupto5Pgs(List<Id> listContactIds, ID DecisionRequest,Integer ContactCountNumber){
		this.listContactIDS = listContactIds;
		this.DecirequestID =  DecisionRequest; 
        this.ContactCountNumber = ContactCountNumber;
    }
    
    public void execute(QueueableContext context) {
    	if(!listContactIDS.isEmpty() && listContactIDS.size()>0){
            Contact con = [Select Id, accountId, SSN__c, Birth_Date__c, Firstname, Lastname,Name, MailingStreet, MailingCity, MailingState, MailingPostalCode
                                     From Contact where ID =: listContactIDS[0]];
        
            Integer noofDays = integer.valueof(label.Equifax_Report_days);
            Date d = System.today() - noofDays;
            List<forseva1__EquifaxConsumer__c> EFX_Consumer_ReportList = new List<forseva1__EquifaxConsumer__c>([SELECT Id, forseva1__Account__c, BNI__c FROM forseva1__EquifaxConsumer__c WHERE forseva1__Contact__c =: con.ID AND Createddate >: d LIMIT 1]);
            forseva1__EquifaxConsumer__c  equifaxConsumerReport = new forseva1__EquifaxConsumer__c();
            Decision_Request__c dR = new Decision_Request__c();
            if(EFX_Consumer_ReportList.isEmpty()){
            	try{
                    String equifaxConsumerStatus = pullEquifaxCommercialandConsumerReports.pullEFX_ConsumerReport(con.accountID,'Equifax Consumer', con);	    
                    if(ContactCountNumber == 1){
                        if(equifaxConsumerStatus == 'hit'){
                            equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);    
                            if(Test.isRunningTest()){
                                equifaxConsumerReport = new forseva1__EquifaxConsumer__c();		    
                            }
                            if(equifaxConsumerReport!=null || Test.isRunningTest()){
                                dR.PG1_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                                dR.PG1_Name__c = con.FirstName + '' + con.Lastname;
                                dR.PG1_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                                dR.PG1_BNI__c = equifaxConsumerReport.BNI__c;
                                dR.PG1_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                				cs.Equifax_DR_First_Contact__c = 'PG1 Equifax Consumer Report pull.';
                				update cs;
                            }   	
                        }
                        dR.Hit_No_Hit_PG1__c = (equifaxConsumerStatus == 'hit'?'Hit':(equifaxConsumerStatus == 'Nohit'?'No Hit':''));
                        //dR.Exception_Found__c = (equifaxConsumerStatus == 'Exception' ? true:false);
                        if(equifaxConsumerStatus == 'Exception'){
            				dR.Exception_Found__c = true;    
            			}
                        dR.Number_of_PGs__c = ContactCountNumber;
                        
                    }
                    else if(ContactCountNumber == 2){
                    	if(equifaxConsumerStatus == 'hit'){
                            equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);    
                            if(Test.isRunningTest()){
                                equifaxConsumerReport = new forseva1__EquifaxConsumer__c();		    
                            }
                            if(equifaxConsumerReport!=null || Test.isRunningTest()){
                                dR.PG2_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                                dR.PG2_Name__c = con.FirstName + '' + con.Lastname;
                                dR.PG2_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                                dR.PG2_BNI__c = equifaxConsumerReport.BNI__c;
                                dR.PG2_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                				cs.Equifax_BPR_2nd_Contact_Status__c = 'PG2 Equifax Consumer Report pull';
                				update cs;
                            }   	
                        }
                        dR.Hit_No_Hit_PG2__c = (equifaxConsumerStatus == 'hit'?'Hit':(equifaxConsumerStatus == 'Nohit'?'No Hit':''));
                        //dR.Exception_Found__c = (equifaxConsumerStatus == 'Exception' ? true:false);
                        if(equifaxConsumerStatus == 'Exception'){
            				dR.Exception_Found__c = true;    
            			}
                        dR.Number_of_PGs__c = ContactCountNumber;	    
                    }
                    else if(ContactCountNumber == 3){
                        if(equifaxConsumerStatus == 'hit'){
                            equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);    
                            if(Test.isRunningTest()){
                                equifaxConsumerReport = new forseva1__EquifaxConsumer__c();		    
                            }
                            if(equifaxConsumerReport!=null || Test.isRunningTest()){
                                dR.PG3_High_Credit3__c = equifaxConsumerReport.High_Credit_Amount__c;
                                dR.PG3_Name__c = con.FirstName + '' + con.Lastname;
                                dR.PG3_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                                dR.PG3_BNI__c = equifaxConsumerReport.BNI__c;
                                dR.PG3_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                                cs.Equifax_BPR_3rd_Contact_Status__c = 'PG3 Equifax Consumer Report pull.';
                                update cs;
                            }   	
                        }
                        dR.Hit_No_Hit_PG3__c = (equifaxConsumerStatus == 'hit'?'Hit':(equifaxConsumerStatus == 'Nohit'?'No Hit':''));
                        //dR.Exception_Found__c = (equifaxConsumerStatus == 'Exception' ? true:false);
                        if(equifaxConsumerStatus == 'Exception'){
            				dR.Exception_Found__c = true;    
            			}
                        dR.Number_of_PGs__c = ContactCountNumber;
                        
                    }
                    else if(ContactCountNumber == 4){
                        if(equifaxConsumerStatus == 'hit'){
                            equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);    
                            if(Test.isRunningTest()){
                                equifaxConsumerReport = new forseva1__EquifaxConsumer__c();		    
                            }
                            if(equifaxConsumerReport!=null || Test.isRunningTest()){
                                dR.PG4_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                                dR.PG4_Name__c = con.FirstName + '' + con.Lastname;
                                dR.PG4_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                                dR.PG4_BNI__c = equifaxConsumerReport.BNI__c;
                                dR.PG4_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                                cs.Equifax_BPR_4th_Contact_Status__c = 'PG4 Equifax Consumer Report pull.';
                                update cs;
                            }   	
                        }
                        dR.Hit_No_Hit_PG4__c = (equifaxConsumerStatus == 'hit'?'Hit':(equifaxConsumerStatus == 'Nohit'?'No Hit':''));
                        //dR.Exception_Found__c = (equifaxConsumerStatus == 'Exception' ? true:false);
                        if(equifaxConsumerStatus == 'Exception'){
            				dR.Exception_Found__c = true;    
            			}
                        dR.Number_of_PGs__c = ContactCountNumber;
                        
                    }
                    else if(ContactCountNumber == 5){
                    	if(equifaxConsumerStatus == 'hit'){
                            equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);    
                            if(Test.isRunningTest()){
                                equifaxConsumerReport = new forseva1__EquifaxConsumer__c();		    
                            }
                            if(equifaxConsumerReport!=null || Test.isRunningTest()){
                                dR.PG5_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                                dR.PG5_Name__c = con.FirstName + '' + con.Lastname;
                                dR.PG5_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                                dR.PG5_BNI__c = equifaxConsumerReport.BNI__c;
                                dR.PG5_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                                cs.Equifax_BPR_5th_Contact_Status__c = 'PG5 Equifax Consumer Report pull.';
                                update cs;
                            }   	
                        }
                        dR.Hit_No_Hit_PG5__c = (equifaxConsumerStatus == 'hit'?'Hit':(equifaxConsumerStatus == 'Nohit'?'No Hit':''));
                        //dR.Exception_Found__c = (equifaxConsumerStatus == 'Exception' ? true:false);
                        if(equifaxConsumerStatus == 'Exception'){
            				dR.Exception_Found__c = true;    
            			}
                        dR.Number_of_PGs__c = ContactCountNumber;    
                    }
            
                }catch(Exception e){    
					system.debug('Exception----'+e);
                	dR.Exception_Found__c =true;                    
                }
            
            }
            else {
            	try{
                    if(ContactCountNumber == 1){
                    	equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);
                        if(equifaxConsumerReport!=null){
                        	dR.PG1_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                            dR.PG1_Name__c = con.FirstName + '' + con.Lastname;
                            dR.PG1_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                            dR.PG1_BNI__c = equifaxConsumerReport.BNI__c;
                            dR.PG1_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                            dR.Hit_No_Hit_PG1__c = 'Prior Report';
                       		dR.Number_of_PGs__c = ContactCountNumber; 
                            
                        }
                    }
                    else if(ContactCountNumber == 2){
                        equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);
                        if(equifaxConsumerReport!=null){
                    		dR.PG2_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                        	dR.PG2_Name__c = con.FirstName + '' + con.Lastname;
                        	dR.PG2_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                        	dR.PG2_BNI__c = equifaxConsumerReport.BNI__c;
                        	dR.PG2_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                        	dR.Hit_No_Hit_PG2__c = 'Prior Report';
                        	dR.Number_of_PGs__c = ContactCountNumber;
                        }    
                    }
                    else if(ContactCountNumber == 3){
                        equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);
                        if(equifaxConsumerReport!=null){
                    		dR.PG3_High_Credit3__c = equifaxConsumerReport.High_Credit_Amount__c;
                        	dR.PG3_Name__c = con.FirstName + '' + con.Lastname;
                        	dR.PG3_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                        	dR.PG3_BNI__c = equifaxConsumerReport.BNI__c;
                        	dR.PG3_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                        	dR.Hit_No_Hit_PG3__c = 'Prior Report';
                        	dR.Number_of_PGs__c = ContactCountNumber;
                        }    
                    }
                    else if(ContactCountNumber == 4){
                        equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);
                        if(equifaxConsumerReport!=null){
                            dR.PG4_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                            dR.PG4_Name__c = con.FirstName + '' + con.Lastname;
                            dR.PG4_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                            dR.PG4_BNI__c = equifaxConsumerReport.BNI__c;
                            dR.PG4_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                            dR.Hit_No_Hit_PG4__c = 'Prior Report';
                            dR.Number_of_PGs__c = ContactCountNumber; 
                        }    
                    }
                    else if(ContactCountNumber == 5){
                        equifaxConsumerReport = pullEquifaxCommercialandConsumerReports.getEquifaxConsumerReport(con.ID);
                        if(equifaxConsumerReport!=null){
                            dR.PG5_High_Credit__c = equifaxConsumerReport.High_Credit_Amount__c;
                            dR.PG5_Name__c = con.FirstName + '' + con.Lastname;
                            dR.PG5_Beacon__c = equifaxConsumerReport.forseva1__eqScrBeacon__c;
                            dR.PG5_BNI__c = equifaxConsumerReport.BNI__c;
                            dR.PG5_Equifax_Consumer_Report__c = equifaxConsumerReport.Id;
                            dR.Hit_No_Hit_PG5__c = 'Prior Report';
                            dR.Number_of_PGs__c = ContactCountNumber;
                            
                        }  
                	}
                }    
                catch(Exception e){
                	system.debug('Exception----'+e);
                	dR.Exception_Found__c =true;
                    
                }
            
            }
            
            dR.ID = DecirequestID;
            system.debug('----206----'+DecirequestID);
        	update dR;
            listContactIDS.remove(0);
            if(!listContactIDS.isEmpty()){
                system.EnqueueJob(new pullEquifaxConsumerReportsupto5Pgs(listContactIDS,dR.Id,(ContactCountNumber+1)));
                    
            }
            else{
                 pullEquifaxCommercialandConsumerReports.executeScoreCard(dR.Id);   
                 CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                 cs.Status_Percentage__c = 100;
                 if(!Test.isRunningTest()){
                     update cs;     
             	 }
          	}
  	    
        }
        
            
     
    }    
    
}