@isTest
private class EventSubjectTest {
    static testMethod void EventSubjectTest (){
                

        Account acc = new Account();
        acc.Name = 'Lansdale Group';
        //acc.Reporting_community__c = cm.id;
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Svetlana';
        c.AccountId = acc.id;
        c.Email = 'ajeevakan@lansdalegroup.com';
        insert c;
        

        
        Opportunity Opp = new Opportunity (Name = 'Opportunity');
        Opp.CloseDate = Date.Today();
        //Opp.RecordTypeId = (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SNF').getRecordTypeId());
        Opp.StageName = 'Active';
        Opp.AccountId = acc.id;
  
        insert Opp;
        
        List<Event> lstEv = new List<Event>();
        Event e1 = new Event(Activity_Type__c = 'Tour', whatid = Opp.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        lstEv.add(e1);
        Event e2 = new Event(Activity_Type__c = 'Tour', whoid = c.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        lstEv.add(e2);

        Test.startTest();
        Insert lstEv;
        Test.stopTest();
    }
}