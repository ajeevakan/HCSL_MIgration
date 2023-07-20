@isTest
public class AutoConvertLeadsTest {

    public static testMethod void AutoConvertLeadsTest () {
    
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
    
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Company = 'Test Test';
        //ld.Relationship_to_Prospect__c = 'Self';
        ld.Lead_Source_Campaign__c = c.id;
        ld.Follow_Up_Activity_Type__c = 'Call Out';
        ld.Follow_Up_Activity_Date__c = Date.today();
        ld.Initial_Activity_Type__c = 'Call Out';
        ld.LeadSource = 'Other';
        ld.Prospect_Last_Name__c = 'Test3';
        ld.Addl_Prospect_Last_Name__c = 'Test2';
        //ld.Addl_Relationship_to_Prospect__c  = 'Spouse';
        ld.Inquiry_Date__c = Date.TODAY();
        
        insert ld;
        
        List<Id> lstIds = new List<Id>();
        lstIds.add(ld.Id);
        
        AutoConvertLeads.LeadAssign(lstIds );

      
    }
    
     public static testMethod void AutoConvertLeadsMergeTest () {

      String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        List<Opportunity> oList = new List<Opportunity>();
        Id pcId;
        
        
        List<Account> alist = new List<Account>();        
        Account hhaobj1 = new Account();
        hhaobj1.Name = 'Test122 Account';
        hhaobj1.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj1); 
        Account hhaobj2 = new Account();
        hhaobj2.Name = 'Test12233 Account';
        hhaobj2.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj2); 
               

        Account accPer1 = new Account();
        accPer1.FirstName='Test FName';
        accPer1.LastName='Test LName';
        accPer1.PersonEmail = 'testtesttest1231456789@test.com';
        accPer1.PersonMailingCity = 'Crystal City';
        accPer1.RecordTypeID = recordTypeId;
        alist.add(accPer1);
        Account accPer2 = new Account();
        accPer2.FirstName='Test FName333';
        accPer2.LastName='Test LName333';
        accPer2.RecordTypeID = recordTypeId;
        accPer2.PersonEmail = 'testtesttest123145678@test.com';
        accPer2.PersonHomePhone = '444-444-4949';
        accPer2.PersonMailingCity = 'Arlington';
        alist.add(accPer2);

        insert alist;
        
        Id conId;
        for (Account a : [Select PersonContactId from Account where PersonContactId != null])
            conId = a.PersonContactId;
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = hhaobj1.Id, ContactId = conId );
 
        acrList.add(acr1);
     
        insert acrList;
    
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
    
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Company = 'Test Test';
        // ld.Relationship_to_Prospect__c = 'Self';
        ld.Lead_Source_Campaign__c = c.id;
        ld.Follow_Up_Activity_Type__c = 'Call Out';
        ld.Follow_Up_Activity_Date__c = Date.today();
        ld.Initial_Activity_Type__c = 'Call Out';
        ld.LeadSource = 'Other';
        ld.Prospect_Last_Name__c = 'Test3';
        ld.Addl_Prospect_Last_Name__c = 'Test2';
        //ld.Addl_Relationship_to_Prospect__c  = 'Spouse';
        ld.Inquiry_Date__c = Date.TODAY();
        ld.Merge_to_Contact__c = conId ;
          
        insert ld;
        
        List<Id> lstIds = new List<Id>();
        lstIds.add(ld.Id);
     
        Test.StartTest();
        AutoConvertLeads.LeadAssign(lstIds );
        Test.StopTest();
      
    }
    
     public static testMethod void AutoConvertLeadsMergeTest2 () {
    
      String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        List<Opportunity> oList = new List<Opportunity>();
        Id pcId;
        
        
        List<Account> alist = new List<Account>();        
        Account hhaobj1 = new Account();
        hhaobj1.Name = 'Test122 Account';
        hhaobj1.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj1); 
        Account hhaobj2 = new Account();
        hhaobj2.Name = 'Test12233 Account';
        hhaobj2.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj2); 
               

        Account accPer1 = new Account();
        accPer1.FirstName='Test FName';
        accPer1.LastName='Test LName';
        accPer1.PersonEmail = 'testtesttest1231456789@test.com';
        accPer1.PersonMailingCity = 'Crystal City';
        accPer1.RecordTypeID = recordTypeId;
        alist.add(accPer1);
        Account accPer2 = new Account();
        accPer2.FirstName='Test FName333';
        accPer2.LastName='Test LName333';
        accPer2.RecordTypeID = recordTypeId;
        accPer2.PersonEmail = 'testtesttest123145678@test.com';
        accPer2.PersonHomePhone = '444-444-4949';
        accPer2.PersonMailingCity = 'Arlington';
        alist.add(accPer2);

        insert alist;
        
        Id conId;
        for (Account a : [Select PersonContactId from Account where PersonContactId != null])
            conId = a.PersonContactId;
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = hhaobj1.Id, ContactId = conId );
 
        acrList.add(acr1);
     
        insert acrList;
    
        Opportunity o = new Opportunity(StageName = 'Depositor', CloseDate = Date.Today(), Name = 'Test', AccountId = hhaobj1.Id);
        insert o;
    
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
    
        Lead ld = new Lead();
        ld.Add_ReInquiry_to_Opportunity__c = o.Id;
        
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
        ld.Company = 'Test Test';
        // ld.Relationship_to_Prospect__c = 'Self';
        ld.Lead_Source_Campaign__c = c.id;
        ld.Follow_Up_Activity_Type__c = 'Call Out';
        ld.Follow_Up_Activity_Date__c = Date.today();
        ld.Initial_Activity_Type__c = 'Call Out';
        ld.LeadSource = 'Other';
        ld.Prospect_Last_Name__c = 'Test3';
        ld.Addl_Prospect_Last_Name__c = 'Test2';
        //ld.Addl_Relationship_to_Prospect__c  = 'Spouse';
        ld.Inquiry_Date__c = Date.TODAY();
 
          
        insert ld;
        
        List<Id> lstIds = new List<Id>();
        lstIds.add(ld.Id);
     
        Test.StartTest();
        AutoConvertLeads.LeadAssign(lstIds );
        Test.StopTest();
      
    }
}