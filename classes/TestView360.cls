//Test class for task 360, event 360 and opportunity 360
@isTest
private class TestView360 {

    
    @isTest
    static void myUnitTest01() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'A', LastName = 'B',  AccountId = acc.Id);
        Contact c3 = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id);
        List<Contact> cList = new List<Contact>();
        cList.add(c);
        cList.add(c2);
        Insert cList;

        Opportunity opp = new Opportunity();
        opp.Name = 'Viv Richards';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        
       /* list<string> lstUnitType = new list<string>();
    Schema.DescribeFieldResult fieldResult = Waitlist__c.Unit_Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
      lstUnitType.add(f.getValue());
    */
        insert opp;
        
        //HC Configs - removing Community and System fields from Task and Event query
        /*Task t = new Task(WhoId = c.Id, WhatId = opp.Id, Priority = 'Normal', Subject = 'Test', Community__c = 'Test', System__C = true, Activity_Type__c = 'Deposit', ActivityDate = Date.today());
        Task t1 = new Task(WhoId = c.Id, WhatId = opp.Id, Priority = 'Normal', Subject = 'Test1', Community__c = 'Test', System__C = true, Activity_Type__c = 'Deposit', ActivityDate = Date.today().addDays(-1));
        insert new list<Task>{t,t1};
        
        event et = new event(WhoId = c.Id, WhatId = opp.Id, Subject = 'Test', Community__c = 'Test', System__C = true, Activity_Type__c = 'Deposit', ActivityDateTime = Datetime.now(),DurationInMinutes=5);
        insert et;*/
        
        Task t = new Task(WhoId = c.Id, WhatId = opp.Id, Priority = 'Normal', Subject = 'Test',  Activity_Type__c = 'Deposit', ActivityDate = Date.today());
        Task t1 = new Task(WhoId = c.Id, WhatId = opp.Id, Priority = 'Normal', Subject = 'Test1',  Activity_Type__c = 'Deposit', ActivityDate = Date.today().addDays(-1));
        insert new list<Task>{t,t1};
        
        event et = new event(WhoId = c.Id, WhatId = opp.Id, Subject = 'Test',  Activity_Type__c = 'Deposit', ActivityDateTime = Datetime.now(),DurationInMinutes=5);
        insert et;
        
        Test.startTest();
        Opportunity360.getOpp(opp.Id);
        Opportunity360.getContacts(opp.Id);
        Opportunity360.getTaskList(opp.Id);
        Opportunity360.getActivities(opp.Id);
        
        /*Task360.getTask(t.Id);
        Task360.getOpp(t.Id);
        Task360.getContacts(t.Id);
        Task360.getTaskList(acc.Id);
        Task360.getActivities(t.Id);
        
        Event360.getEvent(et.Id);
        Event360.getOpp(et.Id);
        Event360.getContacts(et.Id);
        Event360.getEventList(acc.Id);
        Event360.getActivities(et.Id);*/
        
        Test.stopTest();
        
    }
        

}