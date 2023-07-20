@isTest
public class MassReassignActivitiesControllerTest {
    @isTest
    public static void test1 (){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        List<Task> lstTask = new List<Task>();
        
        Contact c = new Contact();
        c.LastName = 'Test';
        c.AccountId = acc.Id;
        insert c;
        
        Campaign camp = new Campaign();
        camp.IsActive = true;
        camp.Name = 'Test';
        insert camp;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = c.Id;
        cm.CampaignId = camp.Id;
        insert cm;
        
        Task tsk = new Task();
        tsk.Priority = 'Normal';
        tsk.ActivityDate = Date.Today();
        tsk.Subject = 'Test';
        tsk.Description = 'Test';
        tsk.WhatId = acc.Id;
        tsk.WhoId = c.Id;
        lstTask.add(tsk);
        
        Task tsk1 = new Task();
        tsk1.Priority = 'Normal';
        tsk1.ActivityDate = Date.Today()-10;
        tsk1.Subject = 'Test';
        tsk1.Description = 'Test';
        tsk1.WhatId = acc.Id;
        tsk1.WhoId = c.Id;
        lstTask.add(tsk1);
        
        Task tsk2 = new Task();
        tsk2.Priority = 'Normal';
        tsk2.ActivityDate = Date.Today();
        tsk2.Subject = 'Test';
        tsk2.Description = 'Test';
        tsk2.WhatId = acc.Id;
        tsk2.WhoId = c.Id;
        lstTask.add(tsk2);
        
        Event evt = new Event ();
        evt.StartDateTime= DateTime.Now();
        evt.EndDateTime= DateTime.Now() + 1;
        evt.Subject = 'Test';
        evt.Description = 'Test';
        evt.WhatId = acc.Id;
        evt.WhoId = c.Id;
        
        Event evt1 = new Event ();
        evt1.StartDateTime= DateTime.Now().addMinutes(5);
        evt1.EndDateTime= DateTime.Now().addMinutes(5) + 1;
        evt1.Subject = 'Test';
        evt1.Description = 'Test';
        evt1.WhatId = acc.Id;
        evt1.WhoId = c.Id;
        
        Community__c comm = new Community__c();
        comm.Name = 'COMM';
        insert comm;
        
        insert new list<Event>{evt,evt1};
        
        insert lstTask;
        
        Test.startTest();
        MassReassignActivitiesController.getUsers();
        MassReassignActivitiesController.getCommunities();
        MassReassignActivitiesController.getCommunityNames();
        MassReassignActivitiesController.reassignActivities(UserInfo.getUserId(), UserInfo.getUserId(), 'All Communities', 'All', '2020-01-01', '2050-01-01', True, True);
        Test.stopTest();
    }
}