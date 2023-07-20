/* Test class for newLeadController
 *
 * @author Lansdale Group
 * @since Dec 06 2021

 */
@isTest
private class NOTUSEDnewLeadControllerTest {
    static testMethod void NOTUSEDnewLeadControllerTest(){

        
        Account acc = new Account();
        acc.Name = 'Lansdale Group';
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Svetlana';
        c.AccountId = acc.id;
        c.Email = 'ajeevakan@lansdalegroup.com';
        insert c;
   
        Lead l1 = new Lead(FirstName='LF01', LastName = 'LL01', Company = 'TestL1');    
        insert l1;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l1.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        
        Opportunity Opp = new Opportunity (Name = 'Batch Opportunity');
        Opp.CloseDate = Date.Today();
        Opp.StageName = 'Active';
        Opp.AccountId = acc.id;
        Opp.HealthCloudGA__ReferringPractitioner__c = c.id;

        insert Opp;

        NOTUSEDnewLeadController.getCommunity();
        NOTUSEDnewLeadController.getLeadRecordTypeID();
        NOTUSEDnewLeadController.getSNLeadRecordTypeID();
    }
}