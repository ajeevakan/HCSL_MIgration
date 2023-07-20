@isTest
public class CreateCampaignMemberHelperTest {
    
    @isTest
    static void myUnitTest01() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
		integer i = 1;        
        Contact c1 = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = acc.Id);
        
        insert new list<contact>{c1,c2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhoId = c1.Id, 
                           					Lead_Source_Campaign__c = c.Id,
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');

        
        
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), 
                             Result_Code__c='Completed',  
                             Subject = 'Inquiry', 
                             Activity_Type__c = 'Tour', 
                             Lead_Source_Campaign__c = c.Id, 
                             WhoId = c2.Id,
                             ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        
        Test.startTest();
        //insert e1;
        insert t1;
        Test.stopTest();        
    }
    
    @isTest
    static void myUnitTest02() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
		integer i = 1;        
        Contact c1 = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = acc.Id);
        
        insert new list<contact>{c1,c2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhoId = c1.Id, 
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');

        
        
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), 
                             Result_Code__c='Completed',  
                             Subject = 'Inquiry', 
                             Activity_Type__c = 'Tour', 
                             WhoId = c2.Id,
                             ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        
        //insert e1;
        insert t1;
        Test.startTest();
        e1.Lead_Source_Campaign__c = c.Id;
        t1.Lead_Source_Campaign__c = c.Id;
        //update e1;
        update t1;
        Test.stopTest();        
    }
    
    @isTest
    static void myUnitTest03() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
		integer i = 1;        
        Contact c1 = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = acc.Id);
        
        insert new list<contact>{c1,c2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhoId = c1.Id, 
                           					Lead_Source_Campaign__c = c.Id,
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');

        
        
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), 
                             Result_Code__c='Completed',  
                             Subject = 'Inquiry', 
                             Activity_Type__c = 'Tour', 
                             Lead_Source_Campaign__c = c.Id, 
                             WhoId = c2.Id,
                             ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        Test.startTest();
        insert e1;
        //insert t1;
        Test.stopTest();        
    }
    
    @isTest
    static void myUnitTest04() {
        Account acc = new Account();
        acc.Name = 'TEST';
        insert acc;
        
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
		integer i = 1;        
        Contact c1 = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = acc.Id);
        Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = acc.Id);
        
        insert new list<contact>{c1,c2};
        
        Task t1 = new Task(Subject = 'Sub', 
                                            System__c = false, 
                                            WhoId = c1.Id, 
                                            ActivityDate = date.today(), 
                                            Activity_Complete_Date__c = date.today(), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed');

        
        
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), 
                             Result_Code__c='Completed',  
                             Subject = 'Inquiry', 
                             Activity_Type__c = 'Tour', 
                             WhoId = c2.Id,
                             ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        
        insert e1;
        //insert t1;
        Test.startTest();
        e1.Lead_Source_Campaign__c = c.Id;
        t1.Lead_Source_Campaign__c = c.Id;
        update e1;
        //update t1;
        Test.stopTest();        
    }

}