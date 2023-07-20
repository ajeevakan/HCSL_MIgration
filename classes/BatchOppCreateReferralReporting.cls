/*
Creates Referral Report records representing Referrals and Admits for each Referral Contact/Opportunity (referred by) Combination
When complete calls BatchTaskCreateReferralReporting, which creates Referral Reporting records for each outreach Task, and
which, in turn, calls BatchEventCreateReferralReporting, which creates Referral Reporting records for each outreach Event

As a first step, each batch (first 2) deletes referral reporting records going back X days, after which they are recomputed for that time period
Initial run should cover last full reporting period, e.g. last 12 months.  After initial run, the days should be pulled back to recent, e.g. 60 days

We dont use Referral Type because we only process one referral contact field, the HC Referring Practioner
*/
global class BatchOppCreateReferralReporting implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    public Date cutoffDate;
   
    public List<ReferralReportingDay__mdt> lstCutOff = new List<ReferralReportingDay__mdt>();

    global BatchOppCreateReferralReporting()  {        
               
        Integer cutoffdateCalculator;

        lstCutOff = [SELECT RefReportingDays__c FROM ReferralReportingDay__mdt];
        cutoffdateCalculator = Integer.valueOf(lstCutOff[0].RefReportingDays__c);
        system.debug('cutoffdateCalculator ' + cutoffdateCalculator );
        cutoffDate = Date.Today().addDays(-cutoffdateCalculator);
        system.debug('cutoffDate ' + cutoffDate);

        List<Referral_Reporting__c > lstOADel = [select Id, Metric_Type__c from Referral_Reporting__c where
           (Metric_Type__c = 'Referral' OR Metric_Type__c = 'Admit') and Date__c >=: cutoffDate];
        system.debug('lstOADel ' + lstOADel );
        if (lstOADel != null)
            if (lstOADel.size() > 1)
                Delete lstOADel;
        
            
    }    
    global Iterable<sObject> start (Database.BatchableContext bc){
        system.debug('Batch Start');

        String query = 'select Id, HealthCloudGA__ReferringPractitioner__c, Opportunity_Inquiry_Date__c, Primary_Resident__c, Reporting_Community__c, Move_In_Date__c FROM Opportunity where HealthCloudGA__ReferringPractitioner__c != NULL AND Opportunity_Inquiry_Date__c >=: cutoffDate AND Reporting_Community__c != NULL';

        
        return Database.query(query);
    }
    
    // The batch job executes and operates on one batch of records
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        system.debug('Inside Execute');
       //String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
       List<Referral_Reporting__c> lstRR = new List<Referral_Reporting__c>();
       system.debug('Opportunity scope ' + scope);
       
       if (scope!=null)
           if (!scope.isEmpty()){
               
            List<Opportunity> lstOpportunity = new List<Opportunity>();  
            for(Opportunity objOpp: scope)  {
                //if(((String)objtsk.WhoId).startsWith(contact_prefix))
                    lstOpportunity.add(objOpp);
            }
            system.debug('lstOpportunity ' +  lstOpportunity);
            for (Opportunity oOpportunity : lstOpportunity)
            {

                system.debug('oOpportunity.HealthCloudGA__ReferringPractitioner__c' + oOpportunity.HealthCloudGA__ReferringPractitioner__c);
         
                if(oOpportunity.HealthCloudGA__ReferringPractitioner__c != NULL) {
                    system.debug('referral contact');
                    Referral_Reporting__c rrobj = new Referral_Reporting__c();
                    rrobj.Community__c = oOpportunity.Reporting_Community__c;
                    rrobj.Referral_Contact__c = oOpportunity.HealthCloudGA__ReferringPractitioner__c;
                    // rrobj.Referral_Type__c = 'Referral Contact';
                    rrobj.Date__c = oOpportunity.Opportunity_Inquiry_Date__c;
                    rrobj.Related_Referral__c = oOpportunity.Id;
                    rrobj.Metric_Type__c = 'Referral';
                    rrobj.Outreach_Activity_Type__c = NULL;
                    rrobj.Patient_Contact__c = oOpportunity.Primary_Resident__c;
                    lstRR.add(rrobj);  
                    //create a second Referral_Reporting__c record when Opportunity Move In Date is not blank
                    if(oOpportunity.Move_In_Date__c != NULL)       {
                        
                        Referral_Reporting__c rrobj1 = new Referral_Reporting__c();
                        rrobj1.Community__c = oOpportunity.Reporting_Community__c;
                        rrobj1.Referral_Contact__c = oOpportunity.HealthCloudGA__ReferringPractitioner__c;
                      //  rrobj1.Referral_Type__c = 'Referral Contact';
                        rrobj1.Date__c = oOpportunity.Move_In_Date__c;
                        rrobj1.Related_Referral__c = oOpportunity.Id;
                        rrobj1.Metric_Type__c = 'Admit';
                        rrobj1.Outreach_Activity_Type__c = NULL;
                        rrobj1.Patient_Contact__c = oOpportunity.Primary_Resident__c;
                        lstRR.add(rrobj1);
                    }                   
                }
                
            }   
            system.debug('lstRR ' +  lstRR);            
            if(lstRR.size()>0)
                insert lstRR;
           }
        
    }
    
    global void finish(Database.BatchableContext BC) {
         BatchTaskCreateReferralReporting b=new BatchTaskCreateReferralReporting();
     Database.executeBatch(b);
     
    }
    
     public void execute(SchedulableContext SC){
        BatchOppCreateReferralReporting oBatchOppCreateReferralReporting  = new BatchOppCreateReferralReporting(); 
        Database.executeBatch(oBatchOppCreateReferralReporting , 100);
    }
}