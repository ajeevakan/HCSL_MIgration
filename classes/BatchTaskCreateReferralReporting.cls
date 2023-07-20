global class BatchTaskCreateReferralReporting implements Database.Batchable<sObject>, Database.Stateful {
    
    public Date cutoffDate;
   
    public List<ReferralReportingDay__mdt> lstCutOff = new List<ReferralReportingDay__mdt>();

    
    global BatchTaskCreateReferralReporting()  {        
               
        Integer cutoffdateCalculator;

        lstCutOff = [SELECT RefReportingDays__c FROM ReferralReportingDay__mdt];
        cutoffdateCalculator = Integer.valueOf(lstCutOff[0].RefReportingDays__c);

        cutoffDate = Date.Today().addDays(-cutoffdateCalculator);
        system.debug('cutoffDate ' + cutoffDate);

        List<Referral_Reporting__c > lstOADel = [select Id, Metric_Type__c from Referral_Reporting__c where Metric_Type__c = 'Marketing Activity' and Date__c >=: cutoffDate];

        if (lstOADel != null)
            if (lstOADel.size() > 1)
                Delete lstOADel;
        
            
    }    
    global Iterable<sObject> start (Database.BatchableContext bc){
        system.debug('Batch Start');

        String query = 'select Id,WhoId, AccountId, ActivityDate , Activity_Complete_Date__c, Activity_Type__c, Account.Reporting_community__c  FROM Task WHERE IsDeleted = false and Is_Complete__c = TRUE AND Whoid in (SELECT Id From Contact where RecordType.Name = \'Business\') AND System__c = FALSE AND WhoId != NULL AND Account.Reporting_community__c != NULL AND Activity_Complete_Date__c >=: cutoffDate ALL ROWS';
        system.debug('query ' + query);
        return Database.query(query);
    }
    
    // The batch job executes and operates on one batch of records
    
    global void execute(Database.BatchableContext BC, List<Task> scope) {
        system.debug('Inside Execute');
       String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
       List<Referral_Reporting__c> lstRR = new List<Referral_Reporting__c>();
       system.debug('Task scope ' + scope);
       Id nullId;
       nullId = NULL;
       
       if (scope!=null)
           if (!scope.isEmpty()){
               
            List<Task> lstTask = new List<Task>();  
            for(Task objtsk: scope)  {
                if(((String)objtsk.WhoId).startsWith(contact_prefix))
                    lstTask.add(objtsk);
            }
            system.debug('lstTask ' +  lstTask);
            for (Task oTask : lstTask)
            {
                Referral_Reporting__c rrobj = new Referral_Reporting__c();
                rrobj.Community__c = oTask.Account.Reporting_community__c; 
                rrobj.Referral_Contact__c = oTask.WhoId;
                rrobj.Date__c = oTask.Activity_Complete_Date__c;
             //   rrobj.Referral_Type__c = '';
                rrobj.Metric_Type__c = 'Marketing Activity';
                rrobj.Outreach_Activity_Type__c = oTask.Activity_Type__c;
                
                rrobj.Patient_Contact__c = nullId;
                lstRR.add(rrobj);
            }   
            system.debug('lstRR ' +  lstRR);            
            if(lstRR.size()>0)
                insert lstRR;
           }
        
        
        
    }
    
    global void finish(Database.BatchableContext BC) {
    
     BatchEventCreateReferralReporting b=new BatchEventCreateReferralReporting();
     Database.executeBatch(b);
     
    }
}