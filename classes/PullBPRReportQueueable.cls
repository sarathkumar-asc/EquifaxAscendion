public class PullBPRReportQueueable implements Queueable, Database.AllowsCallouts {
    public Id accountId;
    public List<ID> listContactsIds;
    public Id DecisonRequest;

    public PullBPRReportQueueable(Id accountId, List<ID> listContactsIds, Id DecisonRequest){
        this.accountId = accountId;
        this.listContactsIds = listContactsIds;
        this.DecisonRequest = DecisonRequest;   
    }

    public void execute(QueueableContext context) {
        forseva1__EquifaxBusinessPrincipalReport__c efxBPRobj = new forseva1__EquifaxBusinessPrincipalReport__c();
        Decision_Request__c dR = new Decision_Request__c();
        String hit;
        Map<String, forseva1__EquifaxBusinessPrincipalReport__c> bprReportResult = new Map<String, forseva1__EquifaxBusinessPrincipalReport__c>();

        try {
            bprReportResult = pullEquifaxCommercialandConsumerReports.pullBPRReport(accountId, 'Equifax');
            Set<String> hitNohit = bprReportResult.keySet();
            hit = hitNohit.iterator().next();

            if (bprReportResult.containsKey('Hit')) {
                efxBPRobj = bprReportResult.get('Hit');
                List<String> scoreValues = new List<String>();
                List<String> scoreTypeValuesList = new List<String>();
                String cidsScoreValue = '';
                Id reportResponseId = efxBPRobj.forseva1__Report_Response__c;

                if (!Test.isRunningTest()) {
                    forseva1.CommercialReportService crs = new forseva1.CommercialReportService('Equifax');
                    String xmlData = crs.getReportResponseData(reportResponseId);
                    forseva1.ConsumerReportService cnrs = new forseva1.ConsumerReportService(xmlData, 'Equifax');

                    scoreValues = cnrs.getAllAttributeValues(
                        'EfxTransmit/CommercialCreditReport/Folder/DecisionTools/ScoreData|scoreName:Equifax OneScore for Commercial Total Financial Solution',
                        'score'
                    );

                    cidsScoreValue = cnrs.getAttributeValue(
                        'EfxTransmit/CommercialCreditReport/Folder/DecisionTools/ScoreData|scoreName:CFN Commercial Insight Origination Score',
                        'score'
                    );

                    scoreTypeValuesList = cnrs.getAllAttributeValues(
                        'EfxTransmit/CommercialCreditReport/Folder/DecisionTools/ScoreData|scoreName:Equifax OneScore for Commercial Total Financial Solution',
                        'scoreType'
                    );
                }

                Integer sumOfScoreValues = 0;
                
                for(String str : scoreValues){
                    sumOfScoreValues = sumOfScoreValues + Integer.valueOf(str.trim());
                }

                if (!listContactsIds.isEmpty()) {
                    efxBPRobj.OneScore__c = null;
					efxBPRobj.OneScore_Type__c = String.join(scoreTypeValuesList, ', ');
                	efxBPRobj.PG_OneScore_Values__c = String.join(scoreValues, ', ');
                } else {
                    efxBPRobj.OneScore__c = !scoreValues.isEmpty() && String.isNotBlank(scoreValues[0]) ? Decimal.valueOf(scoreValues[0]) : null;
                    efxBPRobj.OneScore_Summary__c = null;
                	efxBPRobj.PG_OneScore_Values__c = null;
                }                
				
                dR.Commercial_Insight_Delinquency_Score__c = (efxBPRobj.forseva1__Commercial_Hit_Indicator__c && String.isNotBlank(cidsScoreValue)) ? Decimal.valueOf(cidsScoreValue) : null;
                dR.OneScore__c = efxBPRobj.OneScore__c;
                dR.OneScore_Summary__c = efxBPRobj.OneScore_Summary__c;
                dR.OneScore_Type__c = efxBPRobj.OneScore_Type__c;
                dR.PG_OneScore_Values__c = efxBPRobj.PG_OneScore_Values__c;
                
                dr.Equifax_Blended_Report__c = efxBPRobj.Id;
                
                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                String bprStatus = '<br/> Initiating Blended Report pull <br/> Blended Report retrieved successfully. <br/>';
                cs.Paynet_Report_Status__c = cs.Paynet_Report_Status__c != null ? (cs.Paynet_Report_Status__c + bprStatus) : bprStatus;
                update cs;

                update efxBPRobj;
            }

            //  NO HIT LOGIC
            /*if (bprReportResult.containsKey('Nohit')) {
                forseva1__EquifaxBusinessPrincipalReport__c noHitBPRObj = bprReportResult.get('Nohit');

                List<String> scoreValues = new List<String>();
                List<String> scoreTypeValuesList = new List<String>();
                String cidsScoreValue = '';
                Id reportResponseId = noHitBPRObj.forseva1__Report_Response__c;

                if (!Test.isRunningTest()) {
                    forseva1.CommercialReportService crs = new forseva1.CommercialReportService('Equifax');
                    String xmlData = crs.getReportResponseData(reportResponseId);
                    forseva1.ConsumerReportService cnrs = new forseva1.ConsumerReportService(xmlData, 'Equifax');

                    scoreValues = cnrs.getAllAttributeValues(
                        'EfxTransmit/CommercialCreditReport/Folder/DecisionTools/ScoreData|scoreName:Equifax OneScore for Commercial Total Financial Solution',
                        'score'
                    );

                    scoreTypeValuesList = cnrs.getAllAttributeValues(
                        'EfxTransmit/CommercialCreditReport/Folder/DecisionTools/ScoreData|scoreName:Equifax OneScore for Commercial Total Financial Solution',
                        'scoreType'
                    );
                }
                
                Set<String> scoreTypeValuesSet = new Set<String>();
                scoreTypeValuesSet.addAll(scoreTypeValuesList);

                if (!listContactsIds.isEmpty()) {
                    noHitBPRObj.OneScore__c = null;
                } else {
                    noHitBPRObj.OneScore__c = !scoreValues.isEmpty() && String.isNotBlank(scoreValues[0]) ? Decimal.valueOf(scoreValues[0]) : null;
                }

                noHitBPRObj.OneScore_Type__c = String.join(scoreTypeValuesList, ', ');
                noHitBPRObj.PG_OneScore_Values__c = String.join(scoreValues, ', ');

                dR.OneScore__c = noHitBPRObj.OneScore__c;
                dR.PG_OneScore_Values__c = noHitBPRObj.PG_OneScore_Values__c;
                dR.PG_OneScore_Values__c = String.join(scoreValues, ', ');
               // dR.Commercial_Insight_Delinquency_Score__c = String.isNotBlank(cidsScoreValue) ? Decimal.valueOf(cidsScoreValue) : null; 
                dR.OneScore_Summary__c = noHitBPRObj.OneScore_Summary__c;
                dR.OneScore_Type__c = noHitBPRObj.OneScore_Type__c;

                CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
                String bprStatus = '<br/> Initiating Blended Report pull <br/> Blended Report retrieved successfully.';
                cs.Paynet_Report_Status__c = cs.Paynet_Report_Status__c != null ? (cs.Paynet_Report_Status__c + bprStatus) : bprStatus;
                update cs;
                
                update noHitBPRObj;
            }*/

            if (bprReportResult.containsKey('Exception')) {
                dR.Exception_Found__c = true;
            }

            dR.Hit_No_Hit_BPR__c = (hit == 'hit' ? 'Hit' : (hit == 'Nohit' ? 'No Hit' : ''));
            dR.Id = DecisonRequest;
            update dR;

        } catch (Exception e) {
            System.debug('----Exception----' + e + e.getLineNumber());
            dR.Exception_Found__c = true;
            dR.Id = DecisonRequest;
            update dR;
        }

        Integer i = 1;
        if (!listContactsIds.isEmpty() && !Test.isRunningTest()) {
            customReportpullClass.pullEquifax_ConsumerForFC(listContactsIds, DecisonRequest, i);
        } else {
            pullEquifaxCommercialandConsumerReports.executeScoreCard(DecisonRequest);
            CreditReviewReport__c cs = CreditReviewReport__c.getInstance();
            cs.Status_Percentage__c = 100;
            update cs;
        }
    }
}