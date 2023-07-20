@isTest
public class ManageOccupancyControllerTest {

    @isTest
	static void myUnitTest01(){
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        
		string strPriComm = strCOMM1;
		//for (User oUser : [SELECT Id, Primary_Community__c FROM User WHERE Id = :UserInfo.getUserId() AND Primary_Community__c != null])
		//	strPriComm = oUser.Primary_Community__c;
		List<Opportunity> oList = new List<Opportunity>();

		Account acc = new Account();
		acc.Name = 'WICB';
		Account acc1 = new Account();
		acc1.Name = 'SLCB';
		insert new list<Account>{acc1,acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c3 = new Contact(FirstName = 'E', LastName = 'F', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
        
        Contact ci = new Contact(FirstName = 'A1', LastName = 'B1', AccountId = acc1.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2i = new Contact(FirstName = 'C1', LastName = 'D1',  AccountId = acc1.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c3i = new Contact(FirstName = 'E1', LastName = 'F1', AccountId = acc1.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
        
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		cList.add(c3);
        cList.add(ci);
		cList.add(c2i);
		cList.add(c3i);
		Insert cList;
		
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id); //,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		insert u1;

		Opportunity opp = new Opportunity(Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		opp.Move_In_Date__c = Date.Today().AddDays(-20);
		
		oList.add(opp);
		
		Opportunity opp1 = new Opportunity();
		opp1.Name = 'Steve Smith';
		opp1.AccountId = acc1.Id;
		opp1.CloseDate = Date.Today();
		opp1.StageName = 'Prospecting';
		opp1.Unit__c = u.id;
		opp1.Move_In_Date__c = Date.Today().AddDays(-1);
		oList.add(opp1);

		Opportunity opp2 = new Opportunity();
		opp2.Name = 'Steve Smith';
		opp2.AccountId = acc1.Id;
		opp2.CloseDate = Date.Today().AddDays(50);
		opp2.StageName = 'Prospecting';
		opp2.Unit__c = u1.id;
		opp2.Move_In_Date__c = Date.Today().AddDays(50);
		oList.add(opp2);
		test.startTest();
		insert oList;
		test.stopTest();
		delete oList;
	}
    
    @isTest
	static void myUnitTest04(){
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		//for (User oUser : [SELECT Id, Primary_Community__c FROM User WHERE Id = :UserInfo.getUserId() AND Primary_Community__c != null])
		//	strPriComm = oUser.Primary_Community__c;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm,Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm,Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		opp.Move_In_Date__c = Date.Today().AddDays(-20);
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.GetApartments(strPriComm,strResidentialLiving,u1.Id,opp.Id,true);
		test.stopTest();
		
	}
    
    @isTest
	static void myUnitTest05(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.MoveOut(opp.Id, 'Move-Out', string.valueOf(Date.Today().AddDays(-2)), 'Test', c.Id, c2.Id, '');
		test.stopTest();
		
	}
    
    @isTest
	static void myUnitTest06(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.GetTransferFormParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Transfer', string.valueOf(Date.Today().AddDays(-2)), strResidentialLiving, u1.Id, c.Id, null, '','');
		//ManageOccupancyController.GetRebatableRefundParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Move-Out', string.valueOf(Date.Today().AddDays(-2)), 'Test', null, c2.Id, '100');
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest07(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.GetTransferFormParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Schedule Transfer', string.valueOf(Date.Today().AddDays(-2)), strResidentialLiving, u1.Id, c.Id, null, '','100');
		//ManageOccupancyController.GetRebatableRefundParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Schedule Move-Out', string.valueOf(Date.Today().AddDays(-2)), 'Test', null, c2.Id, '100');
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest08(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.GetTransferFormParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Schedule Transfer', string.valueOf(Date.Today().AddDays(2)), strResidentialLiving, u1.Id, c.Id, null, '','');
		//ManageOccupancyController.GetRebatableRefundParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Schedule Move-Out', string.valueOf(Date.Today().AddDays(2)), 'Test', null, c2.Id, '100');
		test.stopTest();
		ManageOccupancyController.GetPendingChanges(opp.Id);
	}
    
    @isTest
	static void myUnitTest09(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(1)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.GetTransferFormParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Schedule Transfer', string.valueOf(Date.Today().AddDays(2)), strResidentialLiving, u1.Id, c.Id, null, '100','');
		//ManageOccupancyController.GetRebatableRefundParams(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Schedule Move-Out', string.valueOf(Date.Today().AddDays(2)), 'Test', null, c2.Id, '100');
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest10(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.GetTransferFormParams(opp.Id);
		OccTrigHelper.CalledOppTriggerOnce=false;
		opp.Primary_Resident__c=c2.Id;
		update opp;
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		//ManageOccupancyController.Transfer(opp.Id, 'Transfer', string.valueOf(Date.Today().AddDays(-2)), strResidentialLiving, u1.Id, c.Id, null, '');
		//ManageOccupancyController.GetRebatableRefundParams(opp.Id);
		//OccTrigHelper.CalledOppTriggerOnce=false;
		//ManageOccupancyController.MoveOut(opp.Id, 'Move-Out', string.valueOf(Date.Today().AddDays(-2)), 'Test', null, c2.Id, '100');
		test.stopTest();
		
		
	}
    
    @isTest
	static void myUnitTest11(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		//ManageOccupancyController.PayPromissoryNote(opp.Id, null, string.valueOf(Date.Today().AddDays(-1)));
		//ManageOccupancyController.PayPromissoryNote(opp.Id, 1000, null);
		//ManageOccupancyController.PayPromissoryNote(opp.Id, 1000, string.valueOf(Date.Today().AddDays(-1)));
		test.stopTest();
		
		
	}
    
    @isTest
	static void myUnitTest12(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(1)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Schedule Transfer', string.valueOf(Date.Today().AddDays(2)), strResidentialLiving, u1.Id, c.Id, null, '100','');
		ManageOccupancyController.GetCancelScheduledTransferFormParams(opp.Id);
		ManageOccupancyController.CancelScheduledTransfer(opp.Id, c.Id, null);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Schedule Move-Out', string.valueOf(Date.Today().AddDays(2)), 'Test', null, c2.Id, '100');
		ManageOccupancyController.GetCancelScheduledMoveOutFormParams(opp.Id);
		ManageOccupancyController.CancelScheduledMoveOut(opp.Id, null, c2.Id);
		//ManageOccupancyController.GetPromissoryNoteDueAmt(opp.Id);
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest12a(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id, Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id,Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(1)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.Transfer(opp.Id, 'Schedule Transfer', string.valueOf(Date.Today().AddDays(2)), strResidentialLiving, u1.Id, c.Id, null, '100','');
		ManageOccupancyController.GetCancelScheduledTransferFormParams(opp.Id);
		ManageOccupancyController.CancelScheduledTransfer(opp.Id, c.Id, null);
		OccTrigHelper.CalledOppTriggerOnce=false;
		ManageOccupancyController.MoveOut(opp.Id, 'Schedule Move-Out', string.valueOf(Date.Today().AddDays(2)), 'Test', c.Id, null, '100');
		ManageOccupancyController.GetCancelScheduledMoveOutFormParams(opp.Id);
		ManageOccupancyController.CancelScheduledMoveOut(opp.Id, c.Id, null);
		//ManageOccupancyController.GetPromissoryNoteDueAmt(opp.Id);
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest13(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
        opp.Expected_Move_In_Date__c=date.today().addDays(5);
        update opp;
        
        Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Reset_Deposit__c=true,Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Reset_Deposit_User_Names__c=UserInfo.getUserName(), Add_Missing_Resident_User_Names__c=UserInfo.getUserName(), Remove_Prospect_User_Names__c=UserInfo.getUserName(),Enable_Reverse_Move_Out__c=true, Enable_Add_Temporary_Respite_Stay__c=true, Enable_Add_Temporary_SNF_Stay__c=true);
		insert ots;
		
		test.startTest();
		ManageOccupancyController.GetAddSecondResidentFormParams(opp.Id);
        ManageOccupancyController.AddSecondResident(opp.Id,c2.Id,datetime.newInstance(date.today().year(),date.today().month(),date.today().day()).format('yyyy-MM-dd'),strResidentialLiving,u.Id,true);
        ManageOccupancyController.GetPendingChanges(opp.Id);
        ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetRemoveProspectFormParams(opp.Id);
        ManageOccupancyController.RemoveProspect(opp.Id, c.Id);
        ManageOccupancyController.OccupancyTabSetting  cs = new ManageOccupancyController.OccupancyTabSetting();
		//ManageOccupancyController.GetPromissoryNoteDueAmt(opp.Id);
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest14(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
        Contact c3 = new Contact(FirstName = 'E', LastName = 'F',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
        cList.add(c3);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
        Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Enable_Reset_Deposit__c=true, Add_Missing_Resident_User_Names__c=null, Remove_Prospect_User_Names__c=null);
		insert ots;
		
		oList.add(opp);

		insert oList;
		
		test.startTest();
        ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today()),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
        ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetAddSecondResidentFormParams(opp.Id);
        ManageOccupancyController.AddSecondResident(opp.Id,c2.Id,datetime.newInstance(date.today().year(),date.today().month(),date.today().day()).format('yyyy-MM-dd'),strResidentialLiving,u.Id,false);
		test.stopTest();
	}
    
    
    @isTest
	static void myUnitTest15(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
        Contact c3 = new Contact(FirstName = 'E', LastName = 'F',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
        cList.add(c3);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
        Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Add_Missing_Resident_User_Names__c=null, Remove_Prospect_User_Names__c=null);
		insert ots;
		
		oList.add(opp);

		insert oList;
		////CancelDeposit(Id OppId, string strCancelDate, string strCancelReason, string strRefundAmount, string strCompetitor, boolean SetAccountStatustoLost ){
		test.startTest();
        //ManageOccupancyController.GetCancelDepositFormParams(opp.Id);
        //////ManageOccupancyController.AddSecondResident(opp.Id,c2.Id,datetime.newInstance(date.today().year(),date.today().month(),date.today().day()).format('yyyy-MM-dd'),strResidentialLiving,u.Id,false);
        //ManageOccupancyController.CancelDeposit(opp.Id, datetime.newInstance(date.today().year(),date.today().month(),date.today().day()).format('yyyy-MM-dd'), 'Death', '100', null,'',true );
		test.stopTest();
	}
    
    @isTest
	static void myUnitTest16(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
        Contact c3 = new Contact(FirstName = 'E', LastName = 'F',  AccountId = acc.Id,Prospect__c=true,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
        cList.add(c3);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Contract_Type__c='Rebatable 50%',Amount=1000);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Depositor';
		opp.Unit__c = u.id;
        Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Enable_Reset_Deposit__c=true, Add_Missing_Resident_User_Names__c=null, Remove_Prospect_User_Names__c=null);
		insert ots;
		
		oList.add(opp);

		insert oList;
		////CancelDeposit(Id OppId, string strCancelDate, string strCancelReason, string strRefundAmount, string strCompetitor, boolean SetAccountStatustoLost ){
		test.startTest();
        ManageOccupancyController.GetButtonNames(opp.Id);
        //ManageOccupancyController.GetCancelDepositFormParams(opp.Id);
        ////ManageOccupancyController.AddSecondResident(opp.Id,c2.Id,datetime.newInstance(date.today().year(),date.today().month(),date.today().day()).format('yyyy-MM-dd'),strResidentialLiving,u.Id,false);
        //ManageOccupancyController.ResetDeposit(opp.Id);
		test.stopTest();
	}
	
	@isTest
	static void myUnitTest17(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;
		Id redTypeId = ([SELECT Id, name, DeveloperName FROM RecordType where SObjectType = 'Opportunity' and name = 'Senior Living' limit 1]).Id;
		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		opp.RecordTypeId=redTypeId;
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		ManageOccupancyController.GetMoveOutFormParams(opp.Id);
		ManageOccupancyController.MoveOut(opp.Id, 'Move-Out', string.valueOf(Date.Today().AddDays(-2)), 'Test', c.Id, c2.Id, '');
        Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Reverse_Move_Out__c=true, Enable_Reset_Deposit__c=true,Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Reset_Deposit_User_Names__c=UserInfo.getUserName(), Add_Missing_Resident_User_Names__c=UserInfo.getUserName(), Remove_Prospect_User_Names__c=UserInfo.getUserName(), Reverse_Move_Out_User_Names__c=UserInfo.getUserName(),Enable_Add_Temporary_Respite_Stay__c=true, Enable_Add_Temporary_SNF_Stay__c=true,Add_Temporary_Respite_Stay_User_Names__c=UserInfo.getUserName(),Add_Temporary_SNF_Stay_User_Names__c=UserInfo.getUserName());
		insert ots;
        ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetReverseMoveOutFormParams(opp.Id);
		ManageOccupancyController.ReverseMoveOut(opp.Id, c.Id, c2.Id);
		test.stopTest();
		
	}
    
    @isTest
	static void myUnitTest17aa(){
		string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm, Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		
		oList.add(opp);

		insert oList;
		
		
		test.startTest();
		ManageOccupancyController.MoveIn(opp.Id,'Regular',string.valueOf(Date.Today().AddDays(-20)),u.Id,'100.00',string.valueOf(Date.Today().AddDays(-21)),'100','Yes');
		test.stopTest();
        OccTrigHelper.CalledOppTriggerOnce = false;
        list<occupancy__c> lstOccUv = new list<occupancy__c>();
        for (occupancy__c oocc : [SELECT Id, Move_In_Date__c FROM occupancy__c where Move_In_Date__c !=null]){
        oocc.Move_In_Date__c = oocc.Move_In_Date__c-1;
        lstOccUv.add(oocc);
        }
        update lstOccUv;
		
	}
    
    @isTest
	static void myUnitTest18(){
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
		string strPriComm = strCOMM1;
		//for (User oUser : [SELECT Id, Primary_Community__c FROM User WHERE Id = :UserInfo.getUserId() AND Primary_Community__c != null])
		//	strPriComm = oUser.Primary_Community__c;
		List<Opportunity> oList = new List<Opportunity>();
		
		Account acc = new Account();
		acc.Name = 'WICB';
		insert new list<Account>{acc};
			
		Contact c = new Contact(FirstName = 'A', LastName = 'B', AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		Contact c2 = new Contact(FirstName = 'C', LastName = 'D',  AccountId = acc.Id,Relationship_to_Prospect__c='Self');
		
		List<Contact> cList = new List<Contact>();
		cList.add(c);
		cList.add(c2);
		Insert cList;
		final string strResidentialLiving = 'Residential Living';
		Unit__c u = new Unit__c(Community__c = strPriComm,Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u.Name = 'Unit001';
		u.Status__c = 'Vacant';
		u.Housing_Type__c=strResidentialLiving;
		insert u;
		
		Unit__c u1 = new Unit__c(Community__c = strPriComm,Community_Id__c=ocomm.Id);//,Floor_Plan_Id__c=fp.Id
		u1.Name = 'Unit002';
		u1.Status__c = 'Vacant';
		u1.Housing_Type__c=strResidentialLiving;
		insert u1;

		Opportunity opp = new Opportunity(Community__c = strPriComm,Primary_Resident__c=c.Id, Second_Resident__c=c2.Id);
		opp.Name = 'Viv Richards';
		opp.AccountId = acc.Id;
		opp.CloseDate = Date.Today();
		opp.StageName = 'Prospecting';
		opp.Unit__c = u.id;
		opp.Move_In_Date__c = Date.Today().AddDays(-20);
		
		oList.add(opp);

		insert oList;
		
		Occupancy_Tab_Setting__c ots = new Occupancy_Tab_Setting__c(Enable_Reverse_Move_Out__c=true, Enable_Reset_Deposit__c=true,Enable_Remove_Prospect__c=true, Enable_Add_Missing_Resident__c=true, Reset_Deposit_User_Names__c=UserInfo.getUserName(), Add_Missing_Resident_User_Names__c=UserInfo.getUserName(), Remove_Prospect_User_Names__c=UserInfo.getUserName(), Reverse_Move_Out_User_Names__c=UserInfo.getUserName(),Enable_Add_Temporary_Respite_Stay__c=true, Enable_Add_Temporary_SNF_Stay__c=true,Add_Temporary_Respite_Stay_User_Names__c=UserInfo.getUserName(),Add_Temporary_SNF_Stay_User_Names__c=UserInfo.getUserName());
		insert ots;
		test.startTest();
		ManageOccupancyController.GetOccupancies(opp.Id);
		ManageOccupancyController.GetPendingChanges(opp.Id);
		ManageOccupancyController.GetButtonNames(opp.Id);
		ManageOccupancyController.GetMoveInFormParams(opp.Id,'Regular');
		ManageOccupancyController.GetApartments(strPriComm,strResidentialLiving,u1.Id,opp.Id,true);
		test.stopTest();
		
	}

}