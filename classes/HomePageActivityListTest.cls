@isTest
public class HomePageActivityListTest {

    public static testMethod void HomePageActivityListTest () {
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
        lstTask.add(tsk);
        
        Task tsk1 = new Task();
        tsk1.Priority = 'Normal';
        tsk1.ActivityDate = Date.Today()-10;
        tsk1.Subject = 'Test';
        tsk1.Description = 'Test';
        tsk1.WhatId = acc.Id;
        lstTask.add(tsk1);
        
        Task tsk2 = new Task();
        tsk2.Priority = 'Normal';
        tsk2.ActivityDate = Date.Today();
        tsk2.Subject = 'Test';
        tsk2.Description = 'Test';
        tsk2.WhatId = acc.Id;
        lstTask.add(tsk2);
        
        Event evt = new Event ();
        evt.StartDateTime= DateTime.Now();
        evt.EndDateTime= DateTime.Now() + 1;
        evt.Subject = 'Test';
        evt.Description = 'Test';
        evt.WhatId = acc.Id;
        
        Event evt1 = new Event ();
        evt1.StartDateTime= DateTime.Now().addMinutes(5);
        evt1.EndDateTime= DateTime.Now().addMinutes(5) + 1;
        evt1.Subject = 'Test';
        evt1.Description = 'Test';
        evt1.WhatId = acc.Id;
        
        insert new list<Event>{evt,evt1};
        
        insert lstTask;
       
        Test.startTest();
        HomePageActivityList.getActivities('1');
        HomePageActivityList.getActivities('2');
        HomePageActivityList.getActivities('0');
        HomePageActivityList.getActivities('3');
        HomePageActivityList.getActivities('4');
        HomePageActivityList.getActivities('5');
        HomePageActivityList.getActivities('6');
        HomePageActivityList.getActivities('7');
        HomePageActivityList.getActivities('8');
        HomePageActivityList.getActivities('9');
        HomePageActivityList.getActivities('10');
        Test.stopTest();
    }
    
    public static testMethod void HomePageActivityListTest2 () {
        Schema.DescribeFieldResult F = Account.Community__c.getDescribe();
      Schema.sObjectField T = F.getSObjectField();
      List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
        string strComm = entries.get(0).getValue();
        Account acc = new Account(Community__c=strComm);
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
        lstTask.add(tsk);
        
        Task tsk1 = new Task();
        tsk1.Priority = 'Normal';
        tsk1.ActivityDate = Date.Today()-10;
        tsk1.Subject = 'Test';
        tsk1.Description = 'Test';
        tsk1.WhatId = acc.Id;
        lstTask.add(tsk1);
        
        Task tsk2 = new Task();
        tsk2.Priority = 'Normal';
        tsk2.ActivityDate = Date.Today();
        tsk2.Subject = 'Test';
        tsk2.Description = 'Test';
        tsk2.WhatId = acc.Id;
        lstTask.add(tsk2);
        
        Event evt = new Event ();
        evt.StartDateTime= DateTime.Now();
        evt.EndDateTime= DateTime.Now() + 1;
        evt.Subject = 'Test';
        evt.Description = 'Test';
        evt.WhatId = acc.Id;
        
        Event evt1 = new Event ();
        evt1.StartDateTime= DateTime.Now().addMinutes(5);
        evt1.EndDateTime= DateTime.Now().addMinutes(5) + 1;
        evt1.Subject = 'Test';
        evt1.Description = 'Test';
        evt1.WhatId = acc.Id;
        
        insert new list<Event>{evt,evt1};
        
        insert lstTask;
       
        Test.startTest();
        HomePageMultiSiteActivityList.getActivities('1',strComm);
        HomePageMultiSiteActivityList.getActivities('2',strComm);
        HomePageMultiSiteActivityList.getActivities('0','');
        HomePageMultiSiteActivityList.getActivities('3',strComm);
        HomePageMultiSiteActivityList.getActivities('4',strComm);
        HomePageMultiSiteActivityList.getActivities('5',strComm);
        HomePageMultiSiteActivityList.getActivities('6',strComm);
        HomePageMultiSiteActivityList.getActivities('7',strComm);
        HomePageMultiSiteActivityList.getActivities('8',strComm);
        HomePageMultiSiteActivityList.getActivities('9',strComm);
        HomePageMultiSiteActivityList.getActivities('10',strComm);
        HomePageMultiSiteActivityList.getActivities('10','');
        Test.stopTest();
    }
}