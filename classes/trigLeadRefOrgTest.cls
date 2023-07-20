@isTest
private class trigLeadRefOrgTest {

    @isTest
    static void Test1(){
    
        Account a1 = new Account(Referral_Organization_Code__c = 'APFM', Community__c = 'Lutheran Home', Name = 'APFM');
        insert a1;
        Lead ld1 = new Lead(FirstName = 'F1', LastName = 'L1', Company = 'CompanyA', LeadSource = 'OL - Online Directory', 
        Ref_Org_Code__c = 'APFM', Community__c = 'Lutheran Home');
        
        Test.startTest();
        insert ld1;
        Test.stopTest();
        
    }
    
    @isTest
    static void Test2(){
    
      //  Account a1 = new Account(Referral_Organization_Code__c = 'APFM', Community__c = 'Lutheran Home', Name = 'APFM');
      //  insert a1;
        Lead ld1 = new Lead(FirstName = 'F1', LastName = 'L1', Company = 'CompanyA', LeadSource = 'OL - Online Directory',  
        Ref_Org_Code__c = 'APFM', Community__c = 'Lutheran Home');
        
        Test.startTest();
        insert ld1;
        Test.stopTest();
        
    }
}