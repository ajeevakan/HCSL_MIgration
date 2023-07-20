@isTest
public class Opportunity360Test {
    
     @isTest
    static void myUnitTest06() {
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
        
        Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = dopp.getRecordTypeInfosByName();
        Id oppRecTId = rtOppMapByName.get('Senior Living').getRecordTypeId();

        Opportunity opp = new Opportunity(RecordTypeId = oppRecTId,Move_In_Date__c = Date.Today().AddDays(-20));
        opp.Name = 'Viv Richards';
        opp.AccountId = acc.Id;
        opp.Primary_Resident__c = c.Id;
        opp.Second_Resident__c = c2.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-2);
        
       
        insert opp;
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId=opp.id,ContactId=c.id,Role='Primary Prospect Resident',IsPrimary=true);
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId=opp.id,ContactId=c2.id,Role='Second Prospect Resident');
        insert new list<OpportunityContactRole>{ocr1,ocr2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhatId = opp.Id, 
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');
        Task t2 = new Task(Subject = 'Sub2', 
                                            System__c = false, 
                                            WhatId = opp.Id, 
                                            ActivityDate = date.today().adddays(-1), 
                                            Activity_Complete_Date__c = date.today().adddays(-1), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');
        //insert new list<Task>{t1,t2};
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        Event e2 = new Event(Activity_Complete_Date__c = date.today().adddays(-2), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-2), ActivityDateTime = (datetime.now().addDAys(-2)), DurationInMinutes=5);
        insert new list <SObject>{e1,e2,t1,t2};
        Test.startTest();
        Opportunity360.getOpp(opp.Id);
        Opportunity360.getContacts(opp.Id);
        Opportunity360.getActivities(opp.Id);
        Opportunity360.MakePrimaryResident(ocr2.id);
        Opportunity360.MakePrimaryContact(ocr2.id);
        Opportunity360.SetContactInactive(c.id,true,true,true);
        Test.stopTest();
        
    }
    
    @isTest
    static void myUnitTest07() {
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
        
        Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> rtOppMapByName = dopp.getRecordTypeInfosByName();
        Id oppRecTId = rtOppMapByName.get('Senior Living').getRecordTypeId();

        Opportunity opp = new Opportunity(RecordTypeId = oppRecTId,Move_In_Date__c = Date.Today().AddDays(-20));
        opp.Name = 'Viv Richards';
        opp.AccountId = acc.Id;
        opp.Primary_Resident__c = c.Id;
        opp.Second_Resident__c = c2.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-2);
        
       
        insert opp;
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId=opp.id,ContactId=c.id,Role='Primary Prospect Resident',IsPrimary=true);
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId=opp.id,ContactId=c2.id,Role='Second Prospect Resident');
        insert new list<OpportunityContactRole>{ocr1,ocr2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhatId = opp.Id, 
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');
        Task t2 = new Task(Subject = 'Sub2', 
                                            System__c = false, 
                                            WhatId = opp.Id, 
                                            ActivityDate = date.today().adddays(-1), 
                                            Activity_Complete_Date__c = date.today().adddays(-1), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');
        //insert new list<Task>{t1,t2};
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        Event e2 = new Event(Activity_Complete_Date__c = date.today().adddays(-2), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-2), ActivityDateTime = (datetime.now().addDAys(-2)), DurationInMinutes=5);
        insert new list <SObject>{e1,e2,t1,t2};
        Test.startTest();

        Opportunity360.DemoteSecondResident(ocr2.id);
        Opportunity360.MakeSecondResident(ocr2.id);

        Test.stopTest();
        
    }

}