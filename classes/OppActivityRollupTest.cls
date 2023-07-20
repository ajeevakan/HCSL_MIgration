@isTest
public class OppActivityRollupTest {
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
        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-2);
        
       /* list<string> lstUnitType = new list<string>();
    Schema.DescribeFieldResult fieldResult = Waitlist__c.Unit_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
      lstUnitType.add(f.getValue());
    */
        insert opp;
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhatId = opp.Id, 
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');

        insert t1;
        Test.startTest();
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        insert e1;
        

        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-1);
        opp.Move_In_Date__c= Date.Today().addDays(-1);
        update opp;
        Test.stopTest();
        
    }
}