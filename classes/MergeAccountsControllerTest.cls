@isTest
public class MergeAccountsControllerTest {

        public static  testMethod void MergeAccountsControllerTest () {
    
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
    
        List<Account> lstAccount  = new List<Account>();
        Account a1 = new Account(Name = 'TESTACCOUNTTOKEET', BillingStreet = '123', BillingState = 'MD', Description = 'TEST', recordtypeid = hhRecordTypeId  );
        lstAccount.add(a1);
        Account a2 = new Account(Name = 'TESTDUP', BillingStreet = '55555', BillingState = 'VA', Description = 'TEST2', Phone = '555555555', recordtypeid = hhRecordTypeId);
        lstAccount.add(a2);
        insert lstAccount;

        List<Contact> lstContact = new List<Contact>();
        Contact c1 = New Contact(FirstName = 'TEST123', LastName = 'TEST456', AccountId = a1.Id, prospect__c = true,  Relationship_To_Prospect__c = 'Self');
        Contact c2 = New Contact(FirstName = 'TESTXYZ', LastName = 'TESTPDQ', AccountId = a2.Id, prospect__c = true,  Relationship_To_Prospect__c = 'Self');
        lstContact.add(c1);
        lstContact.add(c2);
        insert lstContact;

        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = a1.Id, ContactId = c2.Id);
        AccountContactRelation acr2 = new AccountContactRelation(AccountId = a2.Id, ContactId = c1.Id);
        acrList.add(acr1);
        acrList.add(acr2);
        insert acrList;
        
        Search_Merge_Duplicate_Account__c smda = new Search_Merge_Duplicate_Account__c(Account_To_Keep__c = a1.Id, Account_To_Merge__c = a2.Id);
        Insert smda;
        Test.StartTest();
        MergeAccountsController.MergeAccounts(smda.Id);
        Test.stopTest();
    }
     public static    testMethod void MergeAccountsControllerTest2 () {
     String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
     
        List<Account> lstAccount  = new List<Account>();
        Account a1 = new Account(Name = 'TESTACCOUNTTOKEET', BillingStreet = '123', BillingState = 'MD', Description = 'TEST', recordtypeid = hhRecordTypeId);
        lstAccount.add(a1);
        Account a2 = new Account(Name = 'TESTDUP', BillingStreet = '55555', BillingState = 'VA', Description = 'TEST2', Phone = '555555555', recordtypeid = hhRecordTypeId);
        lstAccount.add(a2);
        insert lstAccount;

        List<Contact> lstContact = new List<Contact>();
        Contact c1 = New Contact(FirstName = 'TEST123', LastName = 'TEST456', AccountId = a1.Id, prospect__c = true, Relationship_To_Prospect__c = 'Self');
        Contact c2 = New Contact(FirstName = 'TESTXYZ', LastName = 'TESTPDQ', AccountId = a2.Id, prospect__c = true, Relationship_To_Prospect__c = 'Self');
        lstContact.add(c1);
        lstContact.add(c2);
        insert lstContact;

        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = a1.Id, ContactId = c2.Id);
        AccountContactRelation acr2 = new AccountContactRelation(AccountId = a2.Id, ContactId = c1.Id);
        acrList.add(acr1);
        acrList.add(acr2);
        insert acrList;
        
        Test.StartTest();
        MergeAccountsController sc = new MergeAccountsController();
        String mergeMsg =  sc.MergePersonAccountsfromLead(a1.Id, a2.Id, null , null ,false);  
        Test.stopTest();

      
    }
     public static    testMethod void MergeAccountsControllerTest3 () {
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
        Id conid1;
        Id conid2;
        for (Account a: [select Id, PersonContactId from Account where PersonContactId != null])
           if (a.Id == accPer1 .Id)
              conid1 = a.PersonContactId;
           else
              conid2= a.PersonContactId;
 
        Test.StartTest();
        Search_Merge_Duplicate_PA_Contact_Pair__c smda = new Search_Merge_Duplicate_PA_Contact_Pair__c(Contact_To_Keep__c = conid1 , Contact_To_Merge__c = conid2);
        Insert smda;
        
        MergeAccountsController.MergePersonAccounts(smda.Id);
    
      
        test.stoptest();
        
        
        }
        
         public static    testMethod void MergeAccountsControllerTest4 () {
    String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
  
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
        Id conid1;
        Id conid2;
        for (Account a: [select Id, PersonContactId from Account where PersonContactId != null])
           if (a.Id == accPer1 .Id)
              conid1 = a.PersonContactId;
           else
              conid2= a.PersonContactId;
 
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(AccountId = hhaobj1.Id, ContactId = conid1 );
        AccountContactRelation acr2 = new AccountContactRelation(AccountId = hhaobj2.Id, ContactId = conid2);
        acrList.add(acr1);
        acrList.add(acr2);
        insert acrList;
 
        List<Opportunity> oList = new List<Opportunity>();
        Opportunity o = new Opportunity(StageName = 'Depositor', CloseDate = Date.Today(), Name = 'Test', AccountId = accPer1.Id);
        oList.add(o);
        Opportunity o2 = new Opportunity(StageName = 'Depositor', CloseDate = Date.Today(), Name = 'Test', AccountId = accPer2.Id);
        oList.add(o2);
        insert oList ;
 
        Test.StartTest();
            Search_Merge_Duplicate_Opportunity_Pair__c smda = new   Search_Merge_Duplicate_Opportunity_Pair__c(Opportunity_to_Keep__c= o.Id , Opportunity_to_Merge__c= o2.Id);
        Insert smda;
        
        MergeAccountsController.MergeOpportunities(smda.Id);
    
      
        test.stoptest();
        
        
        }
}