@isTest
private class BatchOppCreateReferralReportingtest {
    static testMethod void testBatchOppCreateReferralReporting(){
        
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
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Svetlana';
        c.AccountId = acc.id;
        c.Email = 'ajeevakan@lansdalegroup.com';
        insert c;
        
        
        lstCutOff = [SELECT RefReportingDays__c FROM ReferralReportingDay__mdt];
        cutoffdateCalculator = Integer.valueOf(lstCutOff[0].RefReportingDays__c);
        cutoffDate = Date.Today().addDays(-cutoffdateCalculator);
        OppInquiryDate = cutoffDate.addDays(-10);
        
        Opportunity Opp = new Opportunity (Name = 'Batch Opportunity');
        Opp.CloseDate = Date.Today();
     //   Opp.RecordTypeId = (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SNF').getRecordTypeId());
        Opp.StageName = 'Not Yet Classified';
    
        Opp.AccountId = acc.id;
        Opp.HealthCloudGA__ReferringPractitioner__c  = c.id;
        Opp.Opportunity_Inquiry_Date__c  =  startDate;
  
        opp.Primary_Resident__c = c.id;
        opp.Reporting_Community__c = cm.id;
        opp.Move_In_Date__c = Date.Today();
   
        insert Opp;

        BatchOppCreateReferralReporting batchobj = new BatchOppCreateReferralReporting();
        Database.executeBatch(batchobj);
    }
}