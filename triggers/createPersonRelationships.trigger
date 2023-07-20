/*

This trigger creates records in HealthCloudGA__ContactContactRelation__c when a new Person Account is added and related to 
  the main contact via a custom field, Related_Main_Prospect__c.  This trigger also creates a record in 

  Note that an additional HealthCloudGA__ContactContactRelation__c  record is created automatically by health cloud when a relationship is inserted
  with the 'recipricol relationship', e.g. if Jerry Jones is added as Role of Son to Bill Jones, a separate record is automatically created with the 
  reverse relationship with Parent as the Role.
  
  Design Issue: We might not always create the first prospect first.  So, this trigger needs to handle two scenarios:
  1. Add of new contact related to a contact who is not the first prospect 
  2. Add of first prospect (relationship Self) after one or more contacts already exist.  
  
  We will assume that the common denominator is always household.  So, for scenario 1, we add the contact to the related contact's household
  and then get the Self contact for that household and create relationships.
  For scenario 2, if contact being added is self, we check for other contacts related to household and add the contact to contact relationships
  
  Handles setting of Primary Resident and Second Resident fields on Opportunity and setting Opp Contact Role Roles when created from Opportunity 

*/

trigger createPersonRelationships on Account (Before Insert, After Insert) {


   if (Trigger.isBefore) {
      for(Account objAccount:trigger.new) {
      }
      return;
   }
   
   
   // Put the Recipricol Roles in a Map so that we can match to them based on Relationship to Prospect and set the 
   //  Role field when insert records into HealthCloudGA__ContactContactRelation__c
   Map<String, Id> mapRecipRole = new Map<String, Id>();


   // Get the PersonContactId and related Household for the main contact and put in a map
   // The related Opportunity list is the list of Opportunities from which these Contacts were created
   // Contact Roles will be added to all Opportunities, but only the current Opportunity will be updated for 
   // First Resident, Second Resident and Contact Roles set accordingly
   
   List<Id> relatedAccountIdList = new List<Id>();
   List<Id> relatedOpportunityIdList = new List<Id>();
   Map<String, String> mapContactOpptoRole = new Map<String, String>();
   
   for(Account objAccount:trigger.new) {
        if(objAccount.Related_Main_Prospect__c != NULL && objAccount.IsPersonAccount) { 
        system.debug('Related_Main_Prospect__c ' + objAccount.Related_Main_Prospect__c);
        //if(objAccount.Related_Main_Prospect__c != NULL)  
           relatedAccountIdList.add(objAccount.Related_Main_Prospect__c );
        }
        if(objAccount.Created_From_Opportunity__pc != NULL && objAccount.IsPersonAccount)  {
           system.debug('Created_From_Opportunity__pc ' + objAccount.Created_From_Opportunity__pc);
           relatedOpportunityIdList.add(objAccount.Created_From_Opportunity__pc);
        }
   }
   
   // The recipricol roles to be used are ONLY those where Create Inverse is True.  These are the 'user visible' Roles to match to our relationships.
   Boolean continueProcessing = false;
   if (relatedAccountIdList != null)
      if (relatedAccountIdList.size() > 0)
         continueProcessing = true;
   if (relatedOpportunityIdList != null)
     if (relatedOpportunityIdList.size() > 0)
         continueProcessing = true;
     
   if (continueProcessing )     
       //  for (HealthCloudGA__ReciprocalRole__c rr : [SELECT Id, Name FROM HealthCloudGA__ReciprocalRole__c])
           for (HealthCloudGA__ReciprocalRole__c rr : [SELECT Id, Name FROM 
               HealthCloudGA__ReciprocalRole__c where HEALTHCLOUDGA__CREATEINVERSEROLE__C = True and Name != null])
            mapRecipRole.put(rr.Name.toUpperCase(), rr.Id);
   
   system.debug('relatedAccountIdList ' + relatedAccountIdList);
   
   Map<Id, Contact> mapRelatedContacts = new Map<Id, Contact>();        
   for (Contact c: [select Id , AccountId, Account.PersonContactid, Relationship_To_Prospect__c, Prospect__c,
     (select id, ContactId, accountid from AccountContactRelations where Account.RecordType.DeveloperName = 'IndustriesHousehold'),
     (select Id, ContactId, OpportunityId from OpportunityContactRoles)
     from contact 
     where id in (select PersonContactId from Account where id in : relatedAccountIdList)])
     mapRelatedContacts.put(c.AccountId, c);

   system.debug('mapRelatedContacts ' + mapRelatedContacts);
   
   // Get Opportunities to update
   Map<Id, Opportunity> mapAccountsToOpps = new Map<Id, Opportunity>();
   Set<Opportunity> oppsToUpdate = new Set<Opportunity>();
   Map<Id, Opportunity> mapOppsToUpdate = new Map<Id, Opportunity>();
   for (Opportunity o: [select Id, Primary_Resident__c, Primary_Contact__c, Second_Resident__c , AccountId from Opportunity where Id in : relatedOpportunityIdList])
      if (o.AccountId != null)
         mapAccountsToOpps.put(o.AccountId, o);
   
   // Loop through the list of new contacts and create a contact relation and household relation for each
   List<HealthCloudGA__ContactContactRelation__c> lstContactCon = new List<HealthCloudGA__ContactContactRelation__c>();  
   List<AccountContactRelation> newHouseholdRelation = new List<AccountContactRelation>();
   List<OpportunityContactRole> newOpportunityContactRole = new List<OpportunityContactRole>();   
   
   for(Account objAccount:trigger.new) 
     if(objAccount.Related_Main_Prospect__c != NULL && objAccount.IsPersonAccount) 
      //if(objAccount.Related_Main_Prospect__c != NULL) 
       if (mapRelatedContacts.containsKey(objAccount.Related_Main_Prospect__c)) {
          // system.debug('objAccount.Related_Main_Prospect__c ' + objAccount.Related_Main_Prospect__c);
          Contact c = mapRelatedContacts.get(objAccount.Related_Main_Prospect__c );
          HealthCloudGA__ContactContactRelation__c  ccr = new HealthCloudGA__ContactContactRelation__c();

          //system.debug('objAccount.Relationship_to_Prospect__pc ' + objAccount.Relationship_to_Prospect__pc);
          
          // Assign a reciprocol relationship based on relationship
          // If the new contact is Self then use the existing contact's relationship and flip the assignment.         
          ccr.HealthCloudGA__RelatedContact__c = objAccount.PersonContactId;
          ccr.HealthCloudGA__Contact__c = c.Id;
          if (objAccount.Relationship_to_Prospect__pc != null)
             if (objAccount.Relationship_to_Prospect__pc != 'Self') {
                if (mapRecipRole.containsKey(objAccount.Relationship_to_Prospect__pc.toUpperCase()))
                  ccr.HealthCloudGA__Role__c = mapRecipRole.get(objAccount.Relationship_to_Prospect__pc.toUpperCase());
             } else {
                // Adding a Self Contact
                ccr.HealthCloudGA__RelatedContact__c = c.Id;
                ccr.HealthCloudGA__Contact__c = objAccount.PersonContactId;
                if (mapRecipRole.containsKey(c.Relationship_to_Prospect__c.toUpperCase()))
                   ccr.HealthCloudGA__Role__c = mapRecipRole.get(c.Relationship_to_Prospect__c.toUpperCase());
                // Set Opp Account and Opp Primary Resident to new Contact AccountId
                if (mapAccountsToOpps.containsKey(c.AccountId)) {
                   Opportunity o = mapAccountsToOpps.get(c.AccountId);
                   o.AccountId = objAccount.Id;
                   if (o.Primary_Resident__c == null) {
                      o.Primary_Resident__c = objAccount.PersonContactId;
                      
                      mapOppsToUpdate.put(o.Id, o);
                      mapContactOpptoRole.put(o.Id+'-'+ objAccount.PersonContactId, 'First Prospect Resident');
                   }
                }
             }
          lstContactCon.add(ccr);
          
          // If second resident update opp
          if (objAccount.Created_From_Opportunity_Action__pc == 'Add Second Resident')
             if (mapAccountsToOpps.containsKey(c.AccountId)) {
                Opportunity o = mapAccountsToOpps.get(c.AccountId);
                   if (o.Second_Resident__c == null) {
                      o.Second_Resident__c = objAccount.PersonContactId;
                      mapOppsToUpdate.put(o.Id, o);
                      mapContactOpptoRole.put(o.Id+'-'+ objAccount.PersonContactId, 'Second Prospect Resident');
                   }
                }
          
          // If first resident update opp
          if (objAccount.Created_From_Opportunity_Action__pc == 'Add Primary Resident')
             if (mapAccountsToOpps.containsKey(c.AccountId)) {
                Opportunity o = mapAccountsToOpps.get(c.AccountId);
                   if (o.Primary_Resident__c == null) {
                      o.Primary_Resident__c = objAccount.PersonContactId;
                      mapOppsToUpdate.put(o.Id, o);
                      mapContactOpptoRole.put(o.Id+'-'+ objAccount.PersonContactId, 'Primary Prospect Resident');
                   }
                }
          
          // Get first household for contact and add new contact to it
          system.debug('c.AccountContactRelations ' + c.AccountContactRelations);
          system.debug('c.AccountContactRelations.size() ' + c.AccountContactRelations.size());
          if (c.AccountContactRelations != null)
             if (c.AccountContactRelations.size() > 0) {
                AccountContactRelation acrForNewContact = new AccountContactRelation();
                for (AccountContactRelation acr : c.AccountContactRelations ) {
                   acrForNewContact.ContactId = objAccount.PersonContactId;
                   acrForNewContact.AccountId = acr.AccountId;
                }
                newHouseholdRelation.add(acrForNewContact );
          }
          
          // Get all Opportunities from Opportunity Contact Roles and add new Opportunity Contact Roles for new contacts
          system.debug('c.OpportunityContactRoles ' + c.OpportunityContactRoles);
          system.debug('c.OpportunityContactRoles.size() ' + c.OpportunityContactRoles.size());
          if (c.OpportunityContactRoles!= null)
             if (c.OpportunityContactRoles.size() > 0) {
                for (OpportunityContactRole ocr : c.OpportunityContactRoles) {
                   OpportunityContactRole ocrForNewContact = new OpportunityContactRole();
                   String matchkey = ocr.OpportunityId + '-' + objAccount.PersonContactId;
                   if (mapContactOpptoRole.containsKey(matchkey ))
                      ocrForNewContact.Role = mapContactOpptoRole.get(matchkey );
                   ocrForNewContact.ContactId = objAccount.PersonContactId;
                   ocrForNewContact.OpportunityId = ocr.OpportunityId ;
                   newOpportunityContactRole.add(ocrForNewContact);
                }
          }
          
       }
    if (lstContactCon != null) 
       if ( lstContactCon.size() > 0 )
          insert lstContactCon;
        
    if (newHouseholdRelation != null) 
       if ( newHouseholdRelation.size() > 0 )
          insert newHouseholdRelation;
    
    if (newOpportunityContactRole != null) 
       if ( newOpportunityContactRole.size() > 0 ) {
          insert newOpportunityContactRole;
          System.Debug('createPersonRelationships: Insert OCRs ' + newOpportunityContactRole.size() + ' ' + newOpportunityContactRole);    
       }

    if (mapOppsToUpdate != null) {
       List<Opportunity> oppsToUpdateList = new List<Opportunity>();
       for(Opportunity o: mapOppsToUpdate .values()) 
          oppsToUpdateList.add(o);
       if (oppsToUpdateList.size() > 0)
          update oppsToUpdateList; 
    }      
          
}