global class BatchEventCreateReferralReporting implements Database.Batchable<sObject>, Database.Stateful {
    
    public Date cutoffDate;
   
    public List<ReferralReportingDay__mdt> lstCutOff = new List<ReferralReportingDay__mdt>();

    
    global BatchEventCreateReferralReporting()  {        
               
        Integer cutoffdateCalculator;

        lstCutOff = [SELECT RefReportingDays__c FROM ReferralReportingDay__mdt];
        cutoffdateCalculator = Integer.valueOf(lstCutOff[0].RefReportingDays__c);

        cutoffDate = Date.Today().addDays(-cutoffdateCalculator);
        system.debug('cutoffDate ' + cutoffDate);

     // This job always runs after the Task processing job which deletes all marketing activity records.  Do not delete them again in this job.  
             
    }    
    global Iterable<sObject> start (Database.BatchableContext bc){
        system.debug('Batch Start');

        String query = 'select Id,WhoId, AccountId, ActivityDate , Activity_Complete_Date__c, Activity_Type__c, Account.Reporting_community__c FROM Event WHERE IsDeleted = false AND Is_Complete__c = TRUE AND Whoid in (SELECT Id From Contact where RecordType.Name = \'Business\')  AND System__c = FALSE AND WhoId != NULL AND Account.Reporting_community__c != NULL AND Activity_Complete_Date__c >=: cutoffDate';

        return Database.query(query);
    }
    
    // The batch job executes and operates on one batch of records
    
    global void execute(Database.BatchableContext BC, List<Event> scope) {
        
       String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
       List<Referral_Reporting__c> lstRR = new List<Referral_Reporting__c>();
       system.debug('Event scope ' + scope);
       Id nullId;
       nullId = NULL;
       if (scope!=null)
           if (!scope.isEmpty()){
               
            List<Event> lstEvent = new List<Event>();   
            for(Event objtsk: scope)  {
                if(((String)objtsk.WhoId).startsWith(contact_prefix))
                    lstEvent.add(objtsk);
            }
                
            for (Event oEvent : lstEvent)
            {
                Referral_Reporting__c rrobj = new Referral_Reporting__c();
                rrobj.Community__c = oEvent.Account.Reporting_community__c;
                rrobj.Referral_Contact__c = oEvent.WhoId;
                rrobj.Date__c = oEvent.Activity_Complete_Date__c;
            //    rrobj.Referral_Type__c = '';
                rrobj.Metric_Type__c = 'Marketing Activity';
                rrobj.Outreach_Activity_Type__c = oEvent.Activity_Type__c;
                rrobj.Patient_Contact__c = nullId;
                lstRR.add(rrobj);
            }               
            if(lstRR.size()>0)
                insert lstRR;
           }
        
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
}