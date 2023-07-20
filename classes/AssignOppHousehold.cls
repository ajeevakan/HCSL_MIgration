public without sharing class AssignOppHousehold {
  
  public void OpportunityTrigger(){
        list<Id> listAccIds = new List<Id>();
        map<Id, Id> mapPersonAccounttoHousehold = new map<Id, Id>();
        
        boolean householdNotBlankonAny = true;
        
        for (Opportunity opp:(list<Opportunity>)Trigger.new)
           if (opp.AccountId != null)
              if (opp.Primary_Household__c == null) {
                 listAccIds.add(opp.AccountId);
                 householdNotBlankonAny = false;
        }
        
        if (householdNotBlankonAny ) return;
              
        for (AccountContactRelation acr: [select Id, AccountId, ContactId, Contact.AccountId from AccountContactRelation where 
           ContactId in (select PersonContactId from Account where Id in : listAccIds )]) 
           mapPersonAccounttoHousehold.put(acr.Contact.AccountId, acr.AccountId);   
        
           
        for (Opportunity opp:(list<Opportunity>)Trigger.new)
           if (opp.AccountId != null) 
              if (mapPersonAccounttoHousehold.containsKey(opp.AccountId))
                 opp.Primary_Household__c = mapPersonAccounttoHousehold.get(opp.AccountId);
              

  }
}