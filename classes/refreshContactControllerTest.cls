/* Test class for refreshContactController
 *
 * @author Lansdale Group
 * @since Dec 06 2021

 */

@isTest
public class refreshContactControllerTest {

    public static testMethod void  refreshContactControllerTest   () {
   
        Campaign  c = new Campaign(IsActive = true, Name = 'Test');
        insert c;
   
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Test';
 //       ld.Company = 'Test Test';
        ld.Relationship_to_Prospect__c = 'Self';
        ld.Lead_Source_Campaign__c = c.id;
        ld.Follow_Up_Activity_Type__c = 'Call Out';
        ld.Follow_Up_Activity_Date__c = Date.today();
        ld.Initial_Activity_Type__c = 'Call Out';
        ld.LeadSource = 'Other';
        ld.Prospect_Last_Name__c = 'Test3';
        ld.Addl_Prospect_Last_Name__c = 'Test2';
        //ld.Addl_Relationship_to_Prospect__c  = 'Spouse';
        ld.Inquiry_Date__c = Date.TODAY();
        List<RecordType> lstId = [SELECT Id FROM RecordType where DeveloperName = 'Senior_Living' AND SObjectType = 'Lead'];
        Id rectypeid;
    if (lstId  != null)
      for (RecordType i: lstId)
         if (i.Id != null)
            rectypeid= i.Id;
            
        insert ld;
       
        List<Id> lstIds = new List<Id>();
        lstIds.add(ld.Id);
       
        AutoConvertLeads.LeadAssign(lstIds );
// everything up to here is just the original autoconvertleadstest

        Lead l1;
        for (Lead l: [ select ConvertedAccountId   from Lead where Id in :lstIds ])
           l1 = l;
           List<Opportunity> lstOpp = [select Not_Opened_After_Conversion_Yet__c  from Opportunity];
         for (Opportunity o: lstOpp )
            o.Not_Opened_After_Conversion_Yet__c   = true;
          update lstOpp; 
         refreshContactController.getOpportunity(l1.ConvertedAccountId  );
    }
}