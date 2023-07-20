trigger findHouseholds on Search_Merge_Duplicate_PA_Contact_Pair__c (Before Insert) {

   List<Id> contactIds = new List<Id>();
   Map<Id, Id> mapContactsToHouseholds = new Map<Id, Id>();

   if (Trigger.isBefore) {
      for(Search_Merge_Duplicate_PA_Contact_Pair__c objSMD :trigger.new) {
         contactIds.add(objSMD.Contact_To_Keep__c);  
         contactIds.add(objSMD.Contact_To_Merge__c);  
      }
     
    // Get first household for each contact  
    for (AccountContactRelation acr :   [select id, ContactId, accountid from AccountContactRelation where 
       ContactId in :contactIds and Account.RecordType.DeveloperName = 'IndustriesHousehold' and ContactId != null and AccountId != null] )   
       mapContactsToHouseholds.put(acr.ContactId, acr.AccountId);    
   
    for(Search_Merge_Duplicate_PA_Contact_Pair__c objSMD :trigger.new) {
       if (mapContactsToHouseholds.containsKey(objSMD.Contact_To_Keep__c))
          objSMD.Household_of_Contact_to_Keep__c = mapContactsToHouseholds.get(objSMD.Contact_To_Keep__c);
       if (mapContactsToHouseholds.containsKey(objSMD.Contact_To_Merge__c))
          objSMD.Household_of_Contact_to_Merge__c = mapContactsToHouseholds.get(objSMD.Contact_To_Merge__c);          
    }
   
   }
}