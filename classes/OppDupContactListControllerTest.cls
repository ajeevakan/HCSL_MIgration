@isTest
public class OppDupContactListControllerTest {
    @isTest
    public static void OppDupContactListControllertest () {

        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        List<Account> alist = new List<Account>();   
        // Duplicate household accounts  
        Account hhaobj1 = new Account();
        hhaobj1.Name = 'Test122 Account';
        hhaobj1.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj1); 
        Account hhaobj2 = new Account();
        hhaobj2.Name = 'Test122 Account';
        hhaobj2.RecordTypeID = hhRecordTypeId;
        alist.add(hhaobj2);
        // Duplicate person accounts  
        Account accPer1 = new Account();
        accPer1.FirstName='Test FName';
        accPer1.LastName='Test LName';
        accPer1.PersonEmail = 'testtesttest123145678A@test.com';
        accPer1.PersonMailingCity = 'Crystal City';
        accPer1.RecordTypeID = recordTypeId;
        alist.add(accPer1);
        Account accPer2 = new Account();
        accPer2.FirstName='Test FName';
        accPer2.LastName='Test LName';
        accPer2.RecordTypeID = recordTypeId;
        accPer2.PersonEmail = 'testtesttest123145678A@test.com';
        accPer2.PersonMailingCity = 'Crystal City';
        alist.add(accPer2);
        insert alist;

        List<Opportunity> oList = new List<Opportunity>();
        // Duplicate opportunities
        Opportunity o1 = new Opportunity(StageName = 'Depositor', CloseDate = Date.Today(), Name = 'Test', AccountId = accPer1.Id);
        oList.add(o1);
        Opportunity o1Dup = new Opportunity(StageName = 'Depositor', CloseDate = Date.Today(), Name = 'Test', AccountId = accPer2.Id);
        oList.add(o1Dup);
        insert oList;

        List<Contact> cList = new List<Contact>();
        // Duplicate contacts
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@emailtest.com', Phone = '123-123-1234', AccountId=hhaobj1.Id);
        cList.add(c1);
        Contact c1Dup = new Contact(FirstName = 'Test1', LastName = 'Test', Email = 'test@emailtest.com', Phone = '123-123-1234', AccountId=hhaobj2.Id);
        cList.add(c1Dup);

        // Ignore duplicate rules
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true; 
        Database.insert(cList, dml); 

        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId = o1.Id, ContactId = c1.Id);
        ocrList.add(ocr1);
        OpportunityContactRole ocr1Dup = new OpportunityContactRole(OpportunityId = o1Dup.Id, ContactId = c1Dup.Id);
        ocrList.add(ocr1Dup);
        Database.insert(ocrList, dml);

        Test.StartTest();
        OppDupContactListController.getDupInfo(o1.Id);
        Test.StopTest(); 
    }
}