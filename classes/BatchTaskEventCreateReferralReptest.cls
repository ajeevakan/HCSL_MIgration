@isTest
private class BatchTaskEventCreateReferralReptest {
    static testMethod void testBatchTaskEventCreateReferralRep(){
        
        date startDate = System.Today();
        startDate = startDate.addDays(-10);
        Date cutoffDate;
        Date OppInquiryDate;
        List<ReferralReportingDay__mdt> lstCutOff = new List<ReferralReportingDay__mdt>();
        Integer cutoffdateCalculator;
        
          
        list<string> lstCommunityName = new list<string>();
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues())
            lstCommunityName.add(f.getValue());
        
        Community__c cm = new Community__c();
        cm.Name = lstCommunityName[0];
        insert cm;
        
        Account acc = new Account();
        acc.Name = 'Lansdale Group';
        acc.Reporting_community__c = cm.id;
        acc.RecordTypeId = (Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Svetlana';
        c.AccountId = acc.id;
        c.Email = 'ajeevakan@lansdalegroup.com';
        c.RecordTypeId = (Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business').getRecordTypeId());
        insert c;
        
        lstCutOff = [SELECT RefReportingDays__c FROM ReferralReportingDay__mdt];
        cutoffdateCalculator = Integer.valueOf(lstCutOff[0].RefReportingDays__c);
        cutoffDate = Date.Today().addDays(-cutoffdateCalculator);
  
        
        Task t1 = new Task(Activity_Type__c = 'Initial Tour',  WhatId = acc.Id, ActivityDate = Date.TODAY(), WhoId = c.Id,Result_Code__c = 'Completed');
        insert t1;
        
        Event evt1=new Event();
        evt1.WhoId = c.Id;
        evt1.Subject = 'Call';
        evt1.StartDateTime = DateTime.Now();
        evt1.EndDateTime = DateTime.Now() + 1;
        evt1.Activity_Type__c = 'Initial Tour';
      //  evt1.Professional_Referral__c = TRUE;
        evt1.Result_Code__c = 'Completed';
        insert evt1;


        BatchTaskCreateReferralReporting Tbatchobj = new BatchTaskCreateReferralReporting();
        Database.executeBatch(Tbatchobj);
        BatchEventCreateReferralReporting Ebatchobj = new BatchEventCreateReferralReporting();
        Database.executeBatch(Ebatchobj);
        
    }
}