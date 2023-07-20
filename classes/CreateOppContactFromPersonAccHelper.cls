/*
Date: August 10, 2021
Author: Lansdale Group
Description:
1.  We DO create an Opportunity contact role for the Contact associated with the Opportunity person account (the account assigned to the opp).
2.  We ALSO create an Opportunity contact role for all contacts related to the Account assigned to the Opportunity via the 
Contact - Contact Health Cloud relationships between additional contacts and the Contact Id identified in step 1 
(i.e. the Contact Id of the Person Account assigned to the Opportunity). 
*/
public class CreateOppContactFromPersonAccHelper{
  
  public void CreateOppContactsForOpportunity(list<Opportunity> lstOpportunity){
    Map<Id, Id> oppIdtoPersonAccountId = new Map<Id, Id>();
    Map<String, Id> CreateOCRAccountsforOpps = new Map<String, Id>();
    Map<Id, Id> CreateOCRAccountsforAccts = new Map<Id, Id>();
    if (lstOpportunity!=Null)
      if (!(lstOpportunity.isEmpty())){
        list<Id> lstOppId = new list<Id>();
        set<Id> setAccId = new set<Id>();
        for (Opportunity objOpp : lstOpportunity)
          if (string.isNotBlank(objOpp.AccountId)){
            setAccId.add(objOpp.AccountId);
            lstOppId.add(objOpp.Id);
            oppIdtoPersonAccountId.put(objOpp.Id, objOpp.AccountId);
            if (objOpp.Create_OCR_for_Account__c) {
               CreateOCRAccountsforAccts.put(objOpp.AccountId, objOpp.Id);
               // assumes 1:1 relationship between accounts and opps in batch.  No accounts duplicated across opps where the value of 
               // create OCR for Account is different
               CreateOCRAccountsforOpps.put(objOpp.Id + '-' + objOpp.AccountId, objOpp.Id);
            }
               
          }
      
        //  List of person accounts and associated contacts
        Map<Id, Set<Id>> mapPersonAccountsToContacts = new Map<Id, Set<Id>>();
        Map<Id, Id> mapPrimaryOppPersonAcctIdToContactId = new Map<Id, Id>();
        
        List<Id> contactIds = new List<Id>();
        
        // Get the list of households and map the Household account to Opp Person Account
        Map<Id, Id> mapHouseholdtoOppPersonAcct = new Map<Id, Id>();
        Set<Id> householdAccountIds = new Set<Id>();
    
        if (!(setAccId.isEmpty())){
                   
              // Get the list of contacts associated with Opportunity Accounts along with the relationships to Households     
              for (Contact c: [select Id , AccountId, Account.PersonContactid, 
                (select id, ContactId, accountid from AccountContactRelations where Account.RecordType.DeveloperName = 'IndustriesHousehold')
                from contact 
                where id in (select PersonContactId from Account where id in : setAccId)]) {
                 Set<Id> contactList = new Set<Id>();

                // Initialize contact lists for each household with contact for main Opp Account
                 contactList.add(c.Id); 
                 contactIds.add(c.Id);
                 
                 // Initialize map of lists of contacts for each main Opp Acct
                 //  Initialize map of main Opp Acct to it's corresponding Contact Id to use later to determine who is main Opp Role
                 if (CreateOCRAccountsforAccts.containsKey(c.AccountId)) {
                    mapPersonAccountsToContacts.put(c.AccountId, contactList );
                    mapPrimaryOppPersonAcctIdToContactId.put(c.AccountId, c.Id ); 
                 }
             
                 if (c.AccountContactRelations != null)
                    if (c.AccountContactRelations.size() > 0) {
                       for (AccountContactRelation acr : c.AccountContactRelations ) {
                          householdAccountIds.add(acr.AccountId);
                          mapHouseholdtoOppPersonAcct.put(acr.AccountId, c.AccountId );
                        }
                     }
              }
           }
        
          //  Get all of the contacts in all of the households and create a map by person account to lists of associated contacts in the household
          // Exclude the contacts that are main accounts for the Opportunities
          //  Note this wont work for batch operations in which a given account is the main account for one opp but just a related account for another
          
          for (AccountContactRelation acr :  [select id, ContactId, accountid from AccountContactRelation 
             where AccountId in :householdAccountIds and Account.RecordType.DeveloperName = 'IndustriesHousehold' and ContactId Not in : contactIds]) {
             if (mapHouseholdtoOppPersonAcct.containsKey(acr.accountId)) {
                 Id personAccountId = mapHouseholdtoOppPersonAcct.get(acr.accountId);
                 if (mapPersonAccountsToContacts.containsKey(personAccountId )) {
                    Set<Id> lstContactIds = mapPersonAccountsToContacts.get(personAccountId);
                    lstContactIds.add(acr.ContactId);
                    mapPersonAccountsToContacts.put(personAccountId, lstContactIds);
                 }
                 else {
                    Set<Id> lstContactIds = new Set<Id>(); 
                    lstContactIds.add(acr.ContactId);
                    mapPersonAccountsToContacts.put(personAccountId, lstContactIds); 
                 }    
             }
          }
          
          list<OpportunityContactRole> lstOCR = new list<OpportunityContactRole>();
          for (Opportunity objOpp : lstOpportunity)  {
       
                
                // Add the household contacts
                Set<Id> lstContacts = mapPersonAccountsToContacts.get(objOpp.AccountId);
                if (lstContacts != null)
                   for (Id conId : lstContacts) {
                      OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = objOpp.Id, ContactId = conId) ;
                      
                      if (mapPersonAccountsToContacts.containskey(objOpp.AccountId)) {
                         // Add the primary contact/resident
                         String matchkey = objOpp.Id + '-' + objOpp.AccountId;
                         Id primaryOppContactId;
                         if (mapPrimaryOppPersonAcctIdToContactId.containsKey(objOpp.AccountId))
                            primaryOppContactId = mapPrimaryOppPersonAcctIdToContactId.get(objOpp.AccountId);
                         if (CreateOCRAccountsforOpps.containsKey(matchkey)) 
                            if (primaryOppContactId == conId)
                               if (CreateOCRAccountsforAccts.containsKey(objOpp.AccountId)) {
                                  ocr.Role = 'Primary Prospect Resident';
                                  ocr.IsPrimary = true;
                               }
                         
                      }
                      lstOCR.add(ocr);
                   }
          }
          
      
            if (!(lstOCR.isEmpty()))  {
              System.Debug('CreateOppContactFromPersonAccHelper: Inserting OCR Records ' + lstOCR.size() + ' ' + lstOCR);
              insert lstOCR;
            }
          }
        }
      }