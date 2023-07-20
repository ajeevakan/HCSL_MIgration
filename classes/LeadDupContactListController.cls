/**

**/
public class LeadDupContactListController {
    /**
  
    **/
    @AuraEnabled
    public static List<ContactWrapper> getDupContacts(Id recordId) {
      List<Lead> listOfLeads = [Select Id, Name, FirstName, LastName,  Phone, Email from Lead where Id = :recordId];
        // List to store id of duplicate Leads
        List<Id> idList = new List<Id>();
        Set<Contact> setContacts = new Set<Contact>();
        Set<Account> setAccounts = new Set<Account>();
       // List<Contact> lstContactDups = new List<Contact>();
     
        
        // Iterate over all leads to get store Id
        for(Lead l: listOfLeads) {
            idList.add(l.id);
        }
        
        // Get all duplicate Contacts
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(idList);
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                       // Schema.SObjectType expected = Schema.Contact.getSObjectType();
                       // Dont do Contacts
                       // if (Schema.Contact.getSObjectType() == matchRecord.getRecord().getSObjectType())
                       //    setContacts.add((Contact)matchRecord.getRecord());
                        // check person accounts   
                        if (Schema.Account.getSObjectType() == matchRecord.getRecord().getSObjectType())
                           setAccounts.add((Account)matchRecord.getRecord());
                         
                    }
                }
            }
        }
        
        // add person account contact ids
        if (setAccounts.size() > 0)
           for (Contact c: [select Id, Name, Phone, Email from Contact where Id in (select PersonContactId from Account where Id in : setAccounts)])
              setContacts.add(c);
              
        
        List<Id> lstContactIds = new List<Id>();
        Map<Id, List<Opportunity>> mapConIdsToOpps = new Map<Id, List<Opportunity>>();
        for(Contact con : setContacts ) 
           lstContactIds.add(con.Id);
           
        // Get all Opportunities where the contact has a contact role   
        Map<Id, Opportunity> mapOpps = new Map<ID, Opportunity>([select Id, Name, StageName from Opportunity 
           where id in (select OpportunityId from OpportunityContactRole where ContactId in : lstContactIds)]);
        
        // populate map of contact ids to Opportunities 
        for (OpportunityContactRole ocr: [select OpportunityId, ContactId from OpportunityContactRole where ContactId in : lstContactIds]) {
           if (mapOpps.containsKey(ocr.OpportunityId)) {
              Opportunity o = mapOpps.get(ocr.OpportunityId);
              if (mapConIdsToOpps.containsKey(ocr.ContactId)) {
                List<Opportunity> lstOpp = mapConIdsToOpps.get(ocr.ContactId);
                lstOpp.add(o);
                mapConIdsToOpps.put(ocr.ContactId, lstOpp);
              } else {
                List<Opportunity> lstOpp = new List<Opportunity>();
                lstOpp.add(o);
                mapConIdsToOpps.put(ocr.ContactId, lstOpp);
              }
           }
        }
        
        // Wrapper to store Contact with duplicate check
        List<ContactWrapper> listofContactWrapper = new List<ContactWrapper>();
        for(Contact con : setContacts ) {
                List<Opportunity> lstOpp = new List<Opportunity>();
                if (mapConIdsToOpps.containsKey(con.Id))
                   lstOpp = mapConIdsToOpps.get(con.Id);
                listofContactWrapper.add(new ContactWrapper(con.Id, con, lstOpp ));
         }

      
        system.debug('Map of Contacts ==== ' + listofContactWrapper);
        system.debug('Map of Contacts to Opps ==== ' + mapConIdsToOpps);
        return listofContactWrapper;
    }
    
    /**
     * Name: ContactWrapper
     * Desc: To store Contact with duplicate check
    **/
    public class ContactWrapper {
        // To store duplicate flag
        @AuraEnabled public Id conId;
        // To store Contact record
        @AuraEnabled public Contact con;
        
        @AuraEnabled public List<Opportunity> oppList;
        
        /**
         * Name: Parameterised Constructor
         * Desc: To store values
        **/
        public ContactWrapper(Id conId, Contact con, List<Opportunity> oppList ) {
            this.conId= conId;
            this.con = con;
            this.oppList = oppList;
        }
    }
}