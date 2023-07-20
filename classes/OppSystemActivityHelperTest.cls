@isTest
public class OppSystemActivityHelperTest {
  @isTest
    static void myUnitTest01() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Viv Richards';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-3);
        opp.Move_In_Date__c = Date.Today().addDays(-2);
        opp.Toggle_Create_System_Activities_Trigger__c = 'YES';
   
        opp.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Senior_Living').getRecordTypeId();
        opp.Service_Type__c = 'Assisted Living';
        insert opp;

        Test.startTest();
  
        
        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-1);
        opp.Move_In_Date__c= Date.Today().addDays(-1);
        opp.Toggle_Create_System_Activities_Trigger__c = 'NO';
        update opp;
        opp.Move_In_Date__c= null;
        update opp;
        Test.stopTest();
        
    }
}