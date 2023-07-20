/* Test class for refreshContactController
 *
 * @author Lansdale Group
 * @since Sep 01 2021
 Commented out lines that are not yet implmented in HC
 */
@isTest
private class TestrefreshContactController {
    static testMethod void TestrefreshContactController(){
                
        /*Community__c cm = new Community__c();
        cm.Name = 'Test';
        insert cm;*/
        
        Account acc = new Account();
        acc.Name = 'Lansdale Group';
        //acc.Reporting_community__c = cm.id;
        insert acc;
        
        Contact c = new Contact();
        c.LastName = 'Svetlana';
        c.AccountId = acc.id;
        c.Email = 'ajeevakan@lansdalegroup.com';
        insert c;
        
        //Lead l1 = new Lead(FirstName='LF01', LastName = 'LL01', Company = 'TestL1', External_Source_Code__c = 'Test');    
        Lead l1 = new Lead(FirstName='LF01', LastName = 'LL01', Company = 'TestL1');    
        insert l1;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l1.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Converted');
        
        Opportunity Opp = new Opportunity (Name = 'Batch Opportunity');
        Opp.CloseDate = Date.Today();
        //Opp.RecordTypeId = (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SNF').getRecordTypeId());
        Opp.StageName = 'Active';
        //Opp.PCP__c = c.id;
        Opp.AccountId = acc.id;
        Opp.HealthCloudGA__ReferringPractitioner__c = c.id;
        //Opp.Referral_Contact__c = c.id;
        //Opp.Opportunity_Inquiry_Date__c  =  startDate;
        //Opp.Referring_Physician__c =  c.id;
        //Opp.Specialist_Physician__c =  c.id;
        //opp.Primary_Resident__c = c.id;
        //opp.Reporting_Community__c = cm.id;
        //opp.Move_In_Date__c = Date.Today();
        //opp.Opportunity_Inquiry_Date__c  = OppInquiryDate;//Date.Today().AddDays(-130);
        insert Opp;

        refreshContactController.getOpportunity(c.id);
    }
}