/* Test class for CreateOppContactFromPersonAccHelper and associated Triggers
 *
 * @author Lansdale Group
 */
@isTest
private class CreateOppContactFromPersonAccHelpertest {
    static testMethod void CreateOppContactFromPersonAccHelpertest(){

        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        List<Opportunity> oList = new List<Opportunity>();
        Id pcId;
                
        Account hhaobj1 = new Account();
        hhaobj1.Name = 'Test122 Account';
        hhaobj1.RecordTypeID = hhRecordTypeId;
        insert hhaobj1;
        
        Account accPer1 = new Account();
        accPer1.FirstName='Test FName';
        accPer1.LastName='Test LName';
        accPer1.RecordTypeID = recordTypeId;
        accPer1.Related_Main_Prospect__c = hhaobj1.id;
        insert accPer1;
        
        List<Account> lstAccId = new List<Account>();
        
        for(Account accobj: [select Id, PersonContactId from Account where Id =: accPer1.Id])
        {
            lstAccId.add(accobj);
        }
        
        for(Account idobj: lstAccId)
        {
            pcId = idobj.PersonContactId;
        }
        
        
       Contact c2 = new Contact(FirstName = 'A', LastName = 'B',  Created_From_Opportunity_Action__c = 'Add Influencer',  Relationship_To_Prospect__C = 'Spouse', AccountId = hhaobj1.Id);
       // Contact c2 = new Contact(FirstName = 'A', LastName = 'B',  AccountId = hhaobj1.Id);
        insert c2;
        
        HealthCloudGA__ReciprocalRole__c robj = new HealthCloudGA__ReciprocalRole__c();
        robj.Name = 'Parent';
        robj.HealthCloudGA__InverseRole__c = 'Son';
        robj.RecordTypeID = rcrecordTypeId;
        insert robj;
        
        HealthCloudGA__ContactContactRelation__c  ccrobj = new HealthCloudGA__ContactContactRelation__c();
        ccrobj.HealthCloudGA__Contact__c = pcId;
        ccrobj.HealthCloudGA__Role__c = robj.id;
        insert ccrobj;



        AccountContactRelation acrForNewContact = new AccountContactRelation();
                   acrForNewContact.ContactId = pcId ;
                   acrForNewContact.AccountId = hhaobj1.Id;
        Insert acrForNewContact;


        Opportunity opp = new Opportunity();
        opp.Name = 'Viv Richards';
        opp.AccountId = accPer1.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';

        //opp.Community__c = strCOMM1;
        oList.add(opp);

        test.starttest();
        insert oList;
        test.stoptest();
        
    }
}