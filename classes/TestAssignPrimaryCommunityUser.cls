@isTest
public class TestAssignPrimaryCommunityUser {
    
    @isTest
    static void Test01Account(){
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
          Account acc1 = new Account(Name='Test1_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Account acc1b = new Account(Name='Test1b_'+strComm1,Community__c=strComm1,OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Account acc2 = new Account(Name='Test2_'+strComm2,Community__c=strComm2,OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Account acc2b = new Account(Name='Test2b_'+strComm2,Community__c=strComm2,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Account acc3 = new Account(Name='Test3_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Account acc3b = new Account(Name='Test3b_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            insert new list<Account>{acc1,acc1b,acc2,acc2b,acc3,acc3b};
            acc3.OwnerId=u2.Id;
            acc3.Assign_Original_Owner_as_Floater__c=true;
            acc3b.Community__c=strComm2;
            acc3.Assign_Original_Owner_as_Floater__c=true;
            update new list<Account>{acc3,acc3b};
          Test.stopTest();
        }
        integer iCount = 0;
        for(Account objAcc : [SELECT Id, Name, OwnerId, Assigned_Floater__c FROM Account]){
            if (objAcc.Name == 'Test1_'+strComm1){
                iCount++;
               // system.assertEquals(objAcc.OwnerId, u1.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.Name == 'Test1b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
               // system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.Name == 'Test2_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.Name == 'Test2b_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
            else if (objAcc.Name == 'Test3_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.Name == 'Test3b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
        }
       // system.assertEquals(iCount, 6);
    }
    
    @isTest
    static void Test01Campaign(){
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
          Campaign acc1 = new Campaign(Name='Test1_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Campaign acc1b = new Campaign(Name='Test1b_'+strComm1,Community__c=strComm1,OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Campaign acc2 = new Campaign(Name='Test2_'+strComm2,Community__c=strComm2,OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Campaign acc2b = new Campaign(Name='Test2b_'+strComm2,Community__c=strComm2,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Campaign acc3 = new Campaign(Name='Test3_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Campaign acc3b = new Campaign(Name='Test3b_'+strComm1,Community__c=strComm1,OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            insert new list<Campaign>{acc1,acc1b,acc2,acc2b,acc3,acc3b};
            acc3.OwnerId=u2.Id;
            acc3.Assign_Original_Owner_as_Floater__c=true;
            acc3b.Community__c=strComm2;
            acc3.Assign_Original_Owner_as_Floater__c=true;
            update new list<Campaign>{acc3,acc3b};
          Test.stopTest();
        }
        integer iCount = 0;
        for(Campaign objAcc : [SELECT Id, Name, OwnerId, Assigned_Floater__c FROM Campaign]){
            if (objAcc.Name == 'Test1_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.Name == 'Test1b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.Name == 'Test2_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.Name == 'Test2b_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
            else if (objAcc.Name == 'Test3_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.Name == 'Test3b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
        }
        //system.assertEquals(iCount, 6);
    }
    
    @isTest
    static void Test01Lead(){
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
          Lead acc1 = new Lead(LastName='Test1_'+strComm1,FirstName='Test1_'+strComm1,Community__c=strComm1,Company='TestCompany1',OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Lead acc1b = new Lead(LastName='Test1b_'+strComm1,FirstName='Test1b_'+strComm1,Community__c=strComm1,Company='TestCompany2',OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Lead acc2 = new Lead(LastName='Test2_'+strComm2,FirstName='Test2_'+strComm2,Community__c=strComm2,Company='TestCompany3',OwnerId=u2.Id,Assign_Original_Owner_as_Floater__c=true);
            Lead acc2b = new Lead(LastName='Test2b_'+strComm2,FirstName='Test2b_'+strComm2,Community__c=strComm2,Company='TestCompany4',OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Lead acc3 = new Lead(LastName='Test3_'+strComm1,FirstName='Test3_'+strComm1,Community__c=strComm1,Company='TestCompany5',OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            Lead acc3b = new Lead(LastName='Test3b_'+strComm1,FirstName='Test3b_'+strComm1,Community__c=strComm1,Company='TestCompany6',OwnerId=u1.Id,Assign_Original_Owner_as_Floater__c=true);
            insert new list<Lead>{acc1,acc1b,acc2,acc2b,acc3,acc3b};
            acc3.OwnerId=u2.Id;
            acc3.Assign_Original_Owner_as_Floater__c=true;
            acc3b.Community__c=strComm2;
            acc3b.Assign_Original_Owner_as_Floater__c=true;
            update new list<Lead>{acc3,acc3b};
          Test.stopTest();
        }
        integer iCount = 0;
        for(Lead objAcc : [SELECT Id, LastName, OwnerId, Assigned_Floater__c FROM Lead]){
            if (objAcc.LastName == 'Test1_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.LastName == 'Test1b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.LastName == 'Test2_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, null);
            }
            else if (objAcc.LastName == 'Test2b_'+strComm2){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
            else if (objAcc.LastName == 'Test3_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u1b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u2.Id);
            }
            else if (objAcc.LastName == 'Test3b_'+strComm1){
                iCount++;
                //system.assertEquals(objAcc.OwnerId, u2b.Id);
                //system.assertEquals(objAcc.Assigned_Floater__c, u1.Id);
            }
        }
        //system.assertEquals(iCount, 6);
    }

}