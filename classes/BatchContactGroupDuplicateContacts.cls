/* @author Lansdale Group
* @since Jan 19 2022

*/

global class BatchContactGroupDuplicateContacts implements Database.Batchable<sObject>, Schedulable {
    
    // The batch job starts
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('BatchContactGroupDuplicateContacts Start');
        String query = 'select Id, Email from Contact where email != null order by email';
        
        return Database.getQueryLocator(query);
    }
    
    // The batch job executes and operates on one batch of records
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        //system.debug('Execute');
        //system.debug('BatchContactGroupDuplicateContacts Execute');
        //Map<String, List<Id>> mapEmailtoContactId = new Map<String, List<Id>>();
        //Map<Id, String> mapEmailtoConId = new Map<Id, String>();
        
        
        if (scope!=null)
            if (!scope.isEmpty()){
                //Records to delete, those are having 0 records for Unique Email Relationship
                List<Unique_Email__c> lstUniqueEmailToDelete = new List<Unique_Email__c>([SELECT Id, Name from Unique_Email__c WHERE Unique_Email_Relationship__c=0]);
                if(lstUniqueEmailToDelete.size()>0){
                    delete lstUniqueEmailToDelete;
                    system.debug('Deleted UE');
                }
                //List to store Email Address
                list<String> lstEmailAddresses = new list<String>();
                
                //Map to store Contact Ids, whose Email is null
                Map<String, string> blankEmailInContact = new Map<String, string>();
                
                //Map to store Email as a key and List of Contact as a value.
                Map<String, List<Contact>> mapEmailAndContactId = new Map<String, List<Contact>>();
                
                //Loop to store values in Map and List
                for(Contact sObj: scope){
                    //system.debug('sObj.Email '+sObj.Email);
                    if(sObj.Email!=null){
                        lstEmailAddresses.add(sObj.Email);
                        if(mapEmailAndContactId.containsKey(sObj.Email))
                            mapEmailAndContactId.get(sObj.Email).add(sObj);
                        else
                            mapEmailAndContactId.put(sObj.Email, new list<Contact>{sObj});
                    }else{
                        blankEmailInContact.put(sObj.Id, sObj.Id);
                    }
                }
                system.debug('blankEmailInContact '+blankEmailInContact);
                //Map to store Unique Email Records, Name as a Key and Record ID as a Value
                Map<String,Id> mapOfUniqueEmail = new Map<String,Id>();
                
                //Get Unique Email Records those Emails are in Contact
                List<Unique_Email__c> lstUniqueEmail = new List<Unique_Email__c>([SELECT Id, Name from Unique_Email__c WHERE Name in: lstEmailAddresses]);
                for(Unique_Email__c uniqueEmail: lstUniqueEmail){
                    mapOfUniqueEmail.put(uniqueEmail.Name,uniqueEmail.Id);
                }
                
                //List to Insert New Unique Email Records
                List<Unique_Email__c> newUniqueEmailList = new List<Unique_Email__c>();
                
                //Map to store the Contact Id as an Key and Email as an Value
                Map<Id, Id> mapOfContactIdAndUniqueEmailId = new Map<Id, Id>();
                
                //Loop to put values in a Map
                for(String email : mapEmailAndContactId.KeySet()){
                    if(mapOfUniqueEmail.containsKey(email)){
                        if(mapEmailAndContactId.containsKey(email)){
                            List<Contact> contactsFromMap = mapEmailAndContactId.get(email);
                            for(Contact con : contactsFromMap){
                                mapOfContactIdAndUniqueEmailId.put(con.Id, mapOfUniqueEmail.get(email));
                            }
                        }
                        
                    }else{
                        Unique_Email__c newUniqueEmail = new Unique_Email__c();
                        newUniqueEmail.Name = email;
                        newUniqueEmailList.add(newUniqueEmail);
                    }
                }
                
                //If List has Records, Insert New Record.
                if(newUniqueEmailList.size()>0){
                    insert newUniqueEmailList;
                    
                    //And Loop to get New Records Values in Map
                    for(Unique_Email__c uniqueEmail : newUniqueEmailList){
                        if(mapEmailAndContactId.containsKey(uniqueEmail.Name)){
                            List<Contact> contactsFromMap = mapEmailAndContactId.get(uniqueEmail.Name);
                            for(Contact con : contactsFromMap){
                                mapOfContactIdAndUniqueEmailId.put(con.Id, uniqueEmail.Id);
                            }
                        }
                    }
                }
                
                //List to Insert New Unique Email Relationship Records
                List<Unique_Email_Relationships__c> uniqueEmailRelationshipsList = new List<Unique_Email_Relationships__c>();
                
                //List to Delete Unique Email Relationship Records
                List<Unique_Email_Relationships__c> uniqueEmailRelationshipsListToDelete = new List<Unique_Email_Relationships__c>();
                
                //Loop to check which Records need to be insert 
                for(Unique_Email_Relationships__c uniqueEmailRelationship : [SELECT Id, Name,Contact__c,Email_Out_of_Sync__c,
                                                                             Unique_Email__c from Unique_Email_Relationships__c where Unique_Email__r.Name in : lstEmailAddresses]){
                                                                                 if(blankEmailInContact.containsKey(uniqueEmailRelationship.Contact__c) || uniqueEmailRelationship.Email_Out_of_Sync__c==true){
                                                                                     //Delete List
                                                                                     uniqueEmailRelationshipsListToDelete.add(uniqueEmailRelationship);
                                                                                 }else{
                                                                                     if(mapOfContactIdAndUniqueEmailId.containsKey(uniqueEmailRelationship.Contact__c) 
                                                                                    && uniqueEmailRelationship.Unique_Email__c == mapOfContactIdAndUniqueEmailId.get(uniqueEmailRelationship.Contact__c)){
                                                                                        mapOfContactIdAndUniqueEmailId.remove(uniqueEmailRelationship.Contact__c);
                                                                                    }                 
                                                                                 }
                                                                             }
                system.debug('uniqueEmailRelationshipsListToDelete '+uniqueEmailRelationshipsListToDelete);
                
                //Delete Unique Email Relationships
                if(uniqueEmailRelationshipsListToDelete.size()>0){
                    delete uniqueEmailRelationshipsListToDelete;
                    system.debug('deleted UER ');
                }
                
                //Create Unique Email Relationships
                for(Id uerId : mapOfContactIdAndUniqueEmailId.keyset()){
                    Unique_Email_Relationships__c newUniqueEmailRelationships = new Unique_Email_Relationships__c();
                    newUniqueEmailRelationships.Contact__c = uerId;
                    newUniqueEmailRelationships.Unique_Email__c = mapOfContactIdAndUniqueEmailId.get(uerId);
                    uniqueEmailRelationshipsList.add(newUniqueEmailRelationships);     
                }   
                
                if(uniqueEmailRelationshipsList.size()>0){
                    insert uniqueEmailRelationshipsList;
                }
            }
    }
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
        system.debug('finish Runs');
        List<Unique_Email__c> lstUniqueEmailToDelete = new List<Unique_Email__c>([SELECT Id, Name from Unique_Email__c WHERE Unique_Email_Relationship__c=0]);
                if(lstUniqueEmailToDelete.size()>0){
                    delete lstUniqueEmailToDelete;
                    system.debug('Deleted UE');
                }
    }
    
    global void execute(SchedulableContext sc) {
        BatchContactGroupDuplicateContacts b = new BatchContactGroupDuplicateContacts ();
        database.executebatch(b);
    }
    
}