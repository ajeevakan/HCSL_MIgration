@isTest
public class AssignPrimaryCommunityUserTest {
 
    @isTest
    static void myUnitTest01() {
        
        list<string> lstCommunityName = new list<string>();
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues())
            lstCommunityName.add(f.getValue());
        map<string,id> mapUserRole = new map<string,id>();
        for (UserRole oUR : [SELECT Id, Name FROM UserRole WHERE Name IN :lstCommunityName])
            mapUserRole.put(oUR.Name,oUR.Id);
        string strComm1 = '';
        string strComm2 = '';
        for(string strC : mapUserRole.keySet()){
            if (string.isBlank(strComm1))
                strComm1 = strC;
            else if (string.isBlank(strComm2))
                strComm2 = strC;
            else break;
        }
        if (!lstCommunityName.isEmpty()){
          if (string.isBlank(strComm1)) strComm1 = lstCommunityName.get(0);
            if (string.isBlank(strComm1)) if (lstCommunityName.size()>1) strComm2 = lstCommunityName.get(1);
        }
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       
       User u1 = new User(Alias = 'standtA', Email='testingUserA123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingA', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Primary_Community__c = strComm1,
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserA123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm1));
        User u2 = new User(Alias = 'standtB', Email='testingUserB123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingB', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserB123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm2));
       
       User u1b = new User(Alias = 'standtAb', Email='testingUserAb123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingAb', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserAb123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm1));
        User u2b = new User(Alias = 'standtBb', Email='testingUserBb123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingBb', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserBb123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm2));
        
        insert new list<User>{u1,u2,u1b,u2b};
        
        //insert new list<User>{u1,u2};
        Community__c ocomm1 = new Community__c(Name=strComm1,Primary_User_for_Community__c=u1b.Id);
        Community__c ocomm2 = new Community__c(Name=strComm2,Primary_User_for_Community__c=u2b.Id);
        
        System.runAs(u1){
            insert new list<Community__c>{ocomm1,ocomm2};    
            Account acc = new Account(Name='Test1_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            //acc.Name = 'TEST';
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
    
            Opportunity opp = new Opportunity(OwnerId=u1.Id,RecordTypeId = oppRecTId,Move_In_Date__c = Date.Today().AddDays(-20));
            opp.Name = 'Viv Richards';
            opp.AccountId = acc.Id;
            opp.CloseDate = Date.Today();
            opp.StageName = 'Prospecting';
            opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-2);
            
           
            insert opp;
            Test.startTest();
            opp.Opportunity_Inquiry_Date__c= Date.Today().addDays(-1);
            opp.Move_In_Date__c= Date.Today().addDays(-1);
            opp.Community__c=strComm1;
            opp.Assign_Original_Owner_as_Floater__c=true;
            update opp;
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void myUnitTest04() {
        Assign_Primary_Community_User__c cs = new Assign_Primary_Community_User__c(name='cs',Disable_Lead_Profiles__c='test234');
        insert cs;
        list<string> lstCommunityName = new list<string>();
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues())
            lstCommunityName.add(f.getValue());
        map<string,id> mapUserRole = new map<string,id>();
        for (UserRole oUR : [SELECT Id, Name FROM UserRole WHERE Name IN :lstCommunityName])
            mapUserRole.put(oUR.Name,oUR.Id);
        string strComm1 = '';
        string strComm2 = '';
        for(string strC : mapUserRole.keySet()){
            if (string.isBlank(strComm1))
                strComm1 = strC;
            else if (string.isBlank(strComm2))
                strComm2 = strC;
            else break;
        }
        if (!lstCommunityName.isEmpty()){
          if (string.isBlank(strComm1)) strComm1 = lstCommunityName.get(0);
            if (string.isBlank(strComm1)) if (lstCommunityName.size()>1) strComm2 = lstCommunityName.get(1);
        }
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standtA', Email='testingUserA123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingA', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserA123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm1));
        User u2 = new User(Alias = 'standtB', Email='testingUserB123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingB', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserB123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm2));
        User u1b = new User(Alias = 'standtAb', Email='testingUserAb123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingAb', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserAb123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm1));
        User u2b = new User(Alias = 'standtBb', Email='testingUserBb123@testingorg.com', 
            EmailEncodingKey='UTF-8', LastName='TestingBb', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testingUserBb123@testingorg.com',isActive = true,
            UserRoleId=mapUserRole.get(strComm2));
        
        insert new list<User>{u1,u2,u1b,u2b};
        Community__c ocomm1 = new Community__c(Name=strComm1,Primary_User_for_Community__c=u1b.Id);
        Community__c ocomm2 = new Community__c(Name=strComm2,Primary_User_for_Community__c=u2b.Id);
        
        System.runAs(u1){
            insert new list<Community__c>{ocomm1,ocomm2};   
            Test.startTest();
            lead ld = new lead(firstname='LdFName',lastname='LdLName',Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            
            insert ld;
            Campaign cmp = new Campaign(Name='TestCampign',Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            
            insert cmp;

            
            
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void myUnitTest05() {
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
        
        Test.startTest();
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
        insert new list<Task>{t1,t2};
        Event e1 = new Event(Activity_Complete_Date__c = date.today().adddays(-1), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-4), ActivityDateTime = (datetime.now().addDAys(-4)), DurationInMinutes=5);
        Event e2 = new Event(Activity_Complete_Date__c = date.today().adddays(-2), Result_Code__c='Completed',  Subject = 'Inquiry', Activity_Type__c = 'Tour', whatid = opp.Id, ActivityDate = date.today().addDAys(-2), ActivityDateTime = (datetime.now().addDAys(-2)), DurationInMinutes=5);
        insert new list <Event>{e1,e2};
        Test.stopTest();
        
    }
}