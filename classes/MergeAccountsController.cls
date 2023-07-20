global without sharing class MergeAccountsController{
   
  public string MergeHouseholdsfromLead(Id AccountToKeepId, Id AccountToMergeId) {
     MergeHouseholds(AccountToKeepId ,AccountToMergeId);
     return '';
  }
   
  public string MergeOppsfromLead(Id OppId,Id dupOppId, Id HouseholdOpptoKeepId , Id HouseholdOpptoMergeId) {
      if (HouseholdOpptoKeepId != null && HouseholdOpptoMergeId!= null)
         if (HouseholdOpptoKeepId  != HouseholdOpptoMergeId)
            MergeHouseholds(HouseholdOpptoKeepId , HouseholdOpptoMergeId); 
      MergeOpps(OppId, dupOppId);
      return '';
  }
   
  public  string MergePersonAccountsfromLead(Id AccountToKeepId, Id AccountToMergeId, Id OppToKeepId, Id OppToMergeId, Boolean MergeToOpportunity ){
    string strReturn = '';
      try{
         Id HouseholdAccounttoKeepId;
         Id HouseholdAccounttoMergeId;
      List<Account> smList = [select Id, OwnerId
        from Account where Id = : AccountToKeepId];
      if (smList.size()==1) {
         Id ownerId;
         Boolean changeOwner = false;
         for (Account sm: smList ) {
               ownerId = sm.OwnerId;
               changeOwner = true;
            }
        
        for (AccountContactRelation acr : [select AccountId, ContactId, Contact.AccountId from AccountContactRelation 
           where (Contact.AccountId = : AccountToKeepId OR Contact.AccountId = : AccountToMergeId) and 
           Account.RecordType.DeveloperName = 'IndustriesHousehold']) {
              if (AccountToKeepId == acr.Contact.AccountId)
                 HouseholdAccounttoKeepId = acr.AccountId;
              if (AccountToMergeId == acr.Contact.AccountId)
                 HouseholdAccounttoMergeId = acr.AccountId;
           }
        System.Debug('MergePersonAccountsfromLead Households: ' + HouseholdAccounttoKeepId + ', ' + HouseholdAccounttoMergeId );    
        if (HouseholdAccounttoKeepId != null && HouseholdAccounttoMergeId != null)
            if (HouseholdAccounttoKeepId != HouseholdAccounttoMergeId )
               MergeHouseholds(HouseholdAccounttoKeepId , HouseholdAccounttoMergeId );      
            
         System.Debug('MergePersonAccountsfromLead Accounts: ' + AccountToKeepId + ', ' + AccountToMergeId);   
         if (string.isNotBlank(AccountToKeepId) && string.isNotBlank(AccountToMergeId)) {
            if (changeOwner)
               UpdateAccountOwner(AccountToMergeId, ownerId);
            RemoveRelatedAccountLinks(AccountToKeepId, AccountToMergeId, true);
                FixContacts(AccountToKeepId, AccountToMergeId);
            MergeAccount(AccountToKeepId, AccountToMergeId, true);
         if (  OppToKeepId != null &&  OppToMergeId != null && MergeToOpportunity )
            MergeOpps(OppToKeepId, OppToMergeId);    
            
         }
      }
    }
    catch (Exception exc){strReturn=exc.getMessage();}
    Return strReturn;
}

@AuraEnabled
  public static string MergePersonAccounts(Id SearchMergeId){
    string strReturn = '';
      try{
    if (string.isNotBlank(SearchMergeId)){
      List<Search_Merge_Duplicate_PA_Contact_Pair__c> smList = [select Id, Contact_To_Keep__r.AccountId, Contact_To_Merge__r.AccountId, Contact_To_Keep__r.Account.OwnerId, 
      Contact_to_Merge__r.Account.OwnerId, Household_of_Contact_to_Keep__c, Household_of_Contact_to_Merge__c 
        from Search_Merge_Duplicate_PA_Contact_Pair__c where Id = :SearchMergeId and Contact_To_Keep__c != null AND Contact_To_Merge__c != null];
      if (smList.size()==1) {
         Id AccountToKeepId;
         Id AccountToMergeId;
         Id HouseholdAccounttoKeepId;
         Id HouseholdAccounttoMergeId;
         Id ownerId;
    
         Boolean changeOwner = false;
   
         for (Search_Merge_Duplicate_PA_Contact_Pair__c sm: smList ) {
            AccountToKeepId = sm.Contact_To_Keep__r.AccountId;
            AccountToMergeId = sm.Contact_To_Merge__r.AccountId;
            HouseholdAccounttoKeepId = sm.Household_of_Contact_to_Keep__c;
            HouseholdAccounttoMergeId = sm.Household_of_Contact_to_Merge__c;     
    
            if (sm.Contact_To_Keep__r.Account.OwnerId != sm.Contact_to_Merge__r.Account.OwnerId) {
               ownerId = sm.Contact_To_Keep__r.Account.OwnerId;
               changeOwner = true;
            }
         }
         
         if (HouseholdAccounttoKeepId != null && HouseholdAccounttoMergeId != null)
            if (HouseholdAccounttoKeepId != HouseholdAccounttoMergeId )
               MergeHouseholds(HouseholdAccounttoKeepId , HouseholdAccounttoMergeId );         
         
         if (string.isNotBlank(AccountToKeepId) && string.isNotBlank(AccountToMergeId)) {
            if (changeOwner)
               UpdateAccountOwner(AccountToMergeId, ownerId);
            RemoveRelatedAccountLinks(AccountToKeepId, AccountToMergeId, true);
            FixContacts(AccountToKeepId, AccountToMergeId);
            MergeAccount(AccountToKeepId, AccountToMergeId, true);
            
            
         }
      }
    }
    }
    catch (Exception exc){strReturn=exc.getMessage();}
    Return strReturn;
}

@AuraEnabled
  public static string MergeOpportunities(Id SearchMergeId){
    string strReturn = '';
      try{
    if (string.isNotBlank(SearchMergeId)){
      List<Search_Merge_Duplicate_Opportunity_Pair__c > smList = [select Id, Opportunity_to_Keep__c, Opportunity_to_Merge__c, 
        Opportunity_to_Keep__r.Primary_Household__c, Opportunity_to_Merge__r.Primary_Household__c,  Households_Different__c,
        Opportunity_to_Keep__r.OwnerId, Opportunity_to_Merge__r.OwnerId
        from Search_Merge_Duplicate_Opportunity_Pair__c where Id = :SearchMergeId and Opportunity_to_Keep__c != null AND Opportunity_to_Merge__c != null];
      if (smList.size()==1) {
         Id OppToKeepId;
         Id OppToMergeId;
         Id HouseholdOpptoKeepId;
         Id HouseholdOpptoMergeId;
         Id ownerId;
    
         Boolean changeOwner = false;
   
         for (Search_Merge_Duplicate_Opportunity_Pair__c sm: smList ) {
            OppToKeepId = sm.Opportunity_to_Keep__c;
            OppToMergeId= sm.Opportunity_to_Merge__c;
            HouseholdOpptoKeepId = sm.Opportunity_to_Keep__r.Primary_Household__c;
            HouseholdOpptoMergeId = sm.Opportunity_to_Merge__r.Primary_Household__c;     
    
            if (sm.Opportunity_to_Keep__r.OwnerId != sm.Opportunity_to_Merge__r.OwnerId) {
               ownerId = sm.Opportunity_to_Keep__r.OwnerId;
               changeOwner = true;
            }
         }
         
         if (HouseholdOpptoKeepId != null && HouseholdOpptoMergeId!= null)
            if (HouseholdOpptoKeepId  != HouseholdOpptoMergeId)
               MergeHouseholds(HouseholdOpptoKeepId , HouseholdOpptoMergeId);   
               
         MergeOpps(OppToKeepId, OppToMergeId);            
         /*
         if (string.isNotBlank(AccountToKeepId) && string.isNotBlank(AccountToMergeId)) {
            if (changeOwner)
               UpdateAccountOwner(AccountToMergeId, ownerId);
            RemoveRelatedAccountLinks(AccountToKeepId, AccountToMergeId, true);
            FixContacts(AccountToKeepId, AccountToMergeId);
            MergeAccount(AccountToKeepId, AccountToMergeId, true);
         } */
      }
    }
    }
    catch (Exception exc){strReturn=exc.getMessage();}
    Return strReturn;
}

  @AuraEnabled
  public static string MergeAccounts(Id SearchMergeId){
    string strReturn = '';
      try{
    if (string.isNotBlank(SearchMergeId)){
      List<Search_Merge_Duplicate_Account__c> smList = [select Id, Account_To_Keep__c, Account_To_Merge__c, Account_To_Keep__r.OwnerId, 
      Account_to_Merge__r.OwnerId
        from Search_Merge_Duplicate_Account__c where Id = :SearchMergeId and Account_To_Keep__c != null AND Account_To_Merge__c != null];
      if (smList.size()==1) {
         Id AccountToKeepId;
         Id AccountToMergeId;

         Id ownerId;
    
         Boolean changeOwner = false;
   
         for (Search_Merge_Duplicate_Account__c sm: smList ) {
            AccountToKeepId = sm.Account_To_Keep__c;
            AccountToMergeId = sm.Account_To_Merge__c;

     
    
            if (sm.Account_To_Keep__r.OwnerId != sm.Account_to_Merge__r.OwnerId) {
               ownerId = sm.Account_To_Keep__r.OwnerId;
               changeOwner = true;
            }
         }
         

         
         if (string.isNotBlank(AccountToKeepId) && string.isNotBlank(AccountToMergeId)) {
            if (changeOwner)
               UpdateAccountOwner(AccountToMergeId, ownerId);
            RemoveRelatedAccountLinks(AccountToKeepId, AccountToMergeId, false);
            FixContacts(AccountToKeepId, AccountToMergeId);
            MergeAccount(AccountToKeepId, AccountToMergeId, false);
            AddOCRs(AccountToKeepId);
            
            
         }
      }
    }
    }
    catch (Exception exc){strReturn=exc.getMessage();}
    Return strReturn;
}


  public static string MergeHouseholds(Id AccountToKeepId, Id AccountToMergeId){
    string strReturn = '';
      try{
   
         Id ownerId;
      
         Boolean changeOwner = false;     
    
         for (Account a : [select Id, OwnerId from Account where Id = : AccountToKeepId]) {
            ownerId = a.OwnerId;
            changeOwner = true;
         }
         
         if (string.isNotBlank(AccountToKeepId) && string.isNotBlank(AccountToMergeId)) {
            if (changeOwner)
               UpdateAccountOwner(AccountToMergeId, ownerId);
            RemoveRelatedAccountLinks(AccountToKeepId, AccountToMergeId, false);
            FixContacts(AccountToKeepId, AccountToMergeId);
            MergeAccount(AccountToKeepId, AccountToMergeId, false);
            AddOCRs(AccountToKeepId);
            
            
         }
      
   }
   
    catch (Exception exc){strReturn=exc.getMessage();}
    Return strReturn;
}

private static void UpdateAccountOwner(Id dupAccId,Id ownerId) {
  if (dupAccId != null && ownerId != null) {
     List<Account> lstdupAcct = [Select Id, OwnerId from Account where Id = : dupAccId and OwnerId != : ownerId];
     for (Account a: lstdupAcct )
        a.OwnerId = ownerId;
      if (lstdupAcct != null)
         if (lstdupAcct.size() > 0)
            update lstdupAcct;
   }
}

private static void AddOCRs(Id AccId) {
   List<OpportunityContactRole> lstOCR = new List<OpportunityContactRole>();

   Map<String, Id> mapFoundOCRs = new Map<String, Id>();
   List<Id> listOppIds = new List<Id>();
   for (Opportunity o : [select Id from Opportunity where Primary_Household__c = : AccId] )
      listOppIds.add(o.Id);
   List<Id> listConIds = new List<Id>();
   for (AccountContactRelation  acr: [select ContactId from AccountContactRelation where AccountId =: AccId and Account.RecordType.DeveloperName = 'IndustriesHousehold' ]) 
      listConIds.add(acr.ContactId);
      
   for ( OpportunityContactRole ocr: [select Id, ContactId, OpportunityId from OpportunityContactRole where Opportunity.Primary_Household__c = : AccId])
      mapFoundOCRs.put(ocr.ContactId +'-'+ocr.OpportunityId, ocr.Id );
      
   
   for (Id cid: listConIds )
     for (ID oid :    listOppIds )
        if (!mapFoundOCRs.containsKey(cid+'-'+oid)) {
            OpportunityContactRole ocr = new OpportunityContactRole(ContactId = cid, OpportunityId = oid);
            lstOCR.add(ocr);
         }
      
      
   if (lstOCR.size() > 0)
      insert lstOCR;   
}


private static void RemoveRelatedAccountLinks(Id AccId,Id dupAccId, Boolean isPerson) {

  List<AccountContactRelation> lstACRToDelete = new List<AccountContactRelation>();
  List<OpportunityContactRole> lstOCRToDelete = new List<OpportunityContactRole>();
  List<HealthCloudGA__ContactContactRelation__c > lstCCRToDelete = new List<HealthCloudGA__ContactContactRelation__c >();
  // for households
  
  if (!isPerson)
     for (AccountContactRelation acr: [SELECT Id, AccountId, ContactId, Contact.AccountId FROM AccountContactRelation where 
      Account.RecordType.DeveloperName = 'IndustriesHousehold' and (
      (AccountId = :AccId and Contact.AccountId = :dupAccId) OR (AccountId = :dupAccId and Contact.AccountId = :AccId)
      )])
        lstACRToDelete.add(acr);
     
  // for person accounts - remove any links to households for the duplicate and for OpportunityContactRoles for same Opportunity
  if (isPerson) {
     for (AccountContactRelation acr: [SELECT Id, AccountId, ContactId, Contact.AccountId 
        FROM AccountContactRelation where ContactId in (select PersonContactId from Account where Id = : dupAccId) and Account.RecordType.DeveloperName = 'IndustriesHousehold'])
        lstACRToDelete.add(acr);
     List<Id> listOppIds = new List<Id>();
     for (OpportunityContactRole ocr: [select OpportunityId from OpportunityContactRole where ContactId in 
         (select PersonContactId from Account where Id = : AccId)])
        listOppIds.add(ocr.OpportunityId);
     for (OpportunityContactRole ocr: [SELECT Id FROM OpportunityContactRole where ContactId in 
         (select PersonContactId from Account where Id = : dupAccId) and OpportunityId in : listOppIds])
         lstOCRToDelete .add(ocr);
     for (HealthCloudGA__ContactContactRelation__c ccr : [select Id from HealthCloudGA__ContactContactRelation__c 
        where (HealthCloudGA__RelatedContact__r.AccountId = : AccId and HealthCloudGA__Contact__r.AccountId   = :dupAccId) ])
        lstCCRToDelete.add(ccr);
  }     
     
   if (lstACRToDelete.size() > 0)
      delete lstACRToDelete;
   if (lstOCRToDelete.size() > 0)
      delete lstOCRToDelete ;
   if (lstCCRToDelete .size() > 0)
      delete lstCCRToDelete ;      
   
}

private static void FixContacts(Id AccId, Id dupAccId) {
  // only applicable if account is a household.  It makes sure only one contact is Self.
  // Our definition of 'Self' on contact is the main contact for the household they are attached to
  // We can only have 
  // What about relationships? we need to create/manage all of the relationships to the self contact when merging a household
  // We need to not only set Self Contacts from old household to Not Self, but we need to attach all contacts from old household
  // to the self contact on the new household.
  // We need to identify the 'Self to keep' and the 'Self to make Spouse'.  All contacts related to self to make spouse need to be related to Self to keep

  // If Households being merged, get the Self Contact from the old Household
  system.debug('AccId ' + AccId);
        system.debug('dupAccId ' + dupAccId);
  
  // Self Contact for household to keep
  Contact selfContactofHouseholdToKeep;
  for (Contact c: [select Id, Relationship_To_Prospect__c from Contact where id in (select ContactId from AccountContactRelation where 
                AccountId = : AccId and Contact.Relationship_To_Prospect__c = 'Self' and Account.RecordType.DeveloperName = 'IndustriesHousehold')  ])
                selfContactofHouseholdToKeep = c;
  
  if (selfContactofHouseholdToKeep == null) return;
  
  // Set the Self contact from old household to Spouse
  Contact selfContactofOldHousehold;
  for (Contact c: [select Id, Relationship_To_Prospect__c from Contact where id in (select ContactId from AccountContactRelation where 
                AccountId = : dupAccId and Contact.Relationship_To_Prospect__c = 'Self' and Account.RecordType.DeveloperName = 'IndustriesHousehold')  ])
                selfContactofOldHousehold = c;
   if (selfContactofOldHousehold == null) return;
   selfContactofOldHousehold .Relationship_To_Prospect__c = 'Spouse';
           //system.debug('selfContactofOldHousehold.accountId ' + selfContactofOldHousehold.accountId); 
   Update selfContactofOldHousehold ;
   
   // Relate all of the Contacts in hold household to Self Contact in new Household
   List<HealthCloudGA__ContactContactRelation__c> contactcontactRelationsToUpdate = new List<HealthCloudGA__ContactContactRelation__c>();

   for (HealthCloudGA__ContactContactRelation__c cc: [select HealthCloudGA__Contact__c, HealthCloudGA__RelatedContact__c 
      from HealthCloudGA__ContactContactRelation__c where HealthCloudGA__Contact__c  = : selfContactofOldHousehold.Id ]) {
      cc.HealthCloudGA__Contact__c   = selfContactofHouseholdToKeep.Id;
      contactcontactRelationsToUpdate.add(cc);
      }

   //  Add a relationship for the old Self Contact to the new Self Contact
   Id rrId;
   if (selfContactofOldHousehold != null) {
     for (HealthCloudGA__ReciprocalRole__c rr : [SELECT Id, Name FROM 
               HealthCloudGA__ReciprocalRole__c where HEALTHCLOUDGA__CREATEINVERSEROLE__C = True and Name = 'Spouse'])
         rrId = rr.Id;
      if (rrId != null) {
         HealthCloudGA__ContactContactRelation__c  ccr = new HealthCloudGA__ContactContactRelation__c();
         ccr.HealthCloudGA__RelatedContact__c = selfContactofOldHousehold.Id;
         ccr.HealthCloudGA__Contact__c = selfContactofHouseholdToKeep.Id;
         ccr.HealthCloudGA__Role__c = rrId;
         contactcontactRelationsToUpdate.add(ccr);
      }
   }
   
   if (contactcontactRelationsToUpdate .size()>0)
      upsert contactcontactRelationsToUpdate ;
}



    
private static void MergeAccount(Id AccId,Id dupAccId, Boolean isPerson){
        if ((AccId==null)||(dupAccId==null)) return;
        if (AccId==dupAccId) return;
        String querystring = 'select  ';
        String selectedObject = 'Account';
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();

        for(String fieldName : fieldMap.keySet()) {
           if(     (!fieldName.toLowerCase().contains('ispartner' ) ) && 
           (!fieldName.toLowerCase().contains('iscustomerportal' ) ) && 
      
           
           (
           
           fieldMap.get(fieldName).getDescribe().isUpdateable()  
          
              && ( (!isPerson && !(fieldName.toLowercase().contains('__pc'))  && !(fieldName.toLowercase().contains('person')) ) || (isPerson & fieldName != 'Name')  ) )
              )
               querystring += ' ' + fieldName +',';
        }
        
        querystring = querystring.left(querystring.length()-1);
        querystring += ' from Account where Id = :AccId OR Id = :dupAccId';
        List<Account> records = new List<Account>();
        List<Account> duplicates = new List<Account>();
        for (Account acc : (List<Account>)database.query(querystring)){
            if (AccId==acc.Id)
                records.add(acc);
            else if (dupAccId==acc.Id)
                duplicates.add(acc);
        }
        if ((records.isEmpty())||(duplicates.isEmpty())) return;
        
        set<string> billingAddressFields = new set<string>(); 
        billingAddressFields.add('billingstreet'); 
        billingAddressFields.add('billingcity');
        billingAddressFields.add('billingstate');
        billingAddressFields.add('billingpostalcode');
        billingAddressFields.add('billingcountry'); 
                
        set<string> shippingAddressFields = new set<string>(); 
        shippingAddressFields.add('shippingstreet'); 
        shippingAddressFields.add('shippingcity');
        shippingAddressFields.add('shippingstate');
        shippingAddressFields.add('shippingpostalcode');
        shippingAddressFields.add('shippingcountry'); 
        
        set<string> personAddressFields = new set<string>(); 
        if (isPerson ) {
           personAddressFields .add('personmailingstreet'); 
           personAddressFields .add('personmailingcity');
           personAddressFields .add('personmailingstate');
           personAddressFields .add('personmailingpostalcode');
           personAddressFields .add('personmailingcountry'); 
        }
        
        if (string.isBlank(records.get(0).Description))
            records.get(0).Description = duplicates.get(0).Description;
        else if (string.isNotBlank(duplicates.get(0).Description))
            records.get(0).Description = records.get(0).Description+'\r\n'+duplicates.get(0).Description;
        for (Account record: records) {
            ////
            String recordid = record.Id;
            
            for (Account d :duplicates) {
               String strMergeConflicts = '';
               string strMergeConflictsMsg = 'Merged Contact ' + d.Id + ' into ' + record.Id + ' on ' + datetime.now().format('yyyy.MM.dd HH:mm:ss');
               
               boolean nonBlankBillingAddress = false;
               boolean nonBlankShippingAddress = false;
               boolean nonBlankPersonAddress = false;
               for(String fieldName : fieldMap.keySet()) {
                   if(  (!fieldName.toLowerCase().contains('ispartner' ) ) &&
                       (!fieldName.toLowerCase().contains('iscustomerportal' ) ) && 
                    (
                       ( (!isPerson && !(fieldName.toLowercase().contains('__pc'))  
                      
                &&    !(fieldName.toLowercase().contains('person')) )  
                      || (isPerson &&  fieldName.toLowercase() != 'name')  ) && fieldMap.get(fieldName).getDescribe().isUpdateable())) {
                     System.Debug('MergeAccountsController - fieldName: ' + fieldName);
                    // Need to skip address here, but keep track of address fields and merge if ALL address fields blank
                     if (!personAddressFields.contains(fieldName.toLowercase()) && !billingAddressFields.contains(fieldName.toLowercase()) && !shippingAddressFields.contains(fieldName.toLowercase())) {
                        boolean continueProcessing = true;
                        // Don't update parentId field with record id of master
                        if (fieldName.equalsIgnoreCase('ParentId'))
                           if (d.get(fieldName) != null)
                              if (d.get(fieldName) == recordid) 
                                 continueProcessing = false;
                        if (d.get(fieldName) != null && record.get(fieldName) == null && continueProcessing)
                           record.put(fieldName, d.get(fieldName));
                        else if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean)
                           if (continueProcessing && d.get(fieldName) == true)
                              record.put(fieldName, d.get(fieldName));
                        if (d.get(fieldName) != null && record.get(fieldName) != null)
                           strMergeConflicts += (fieldName + ': ' + string.valueOf(d.get(fieldName))+'\r\n');      
                            
                     }
                     else
                        if (record.get(fieldName) != null && billingAddressFields.contains(fieldName.toLowercase()))
                           nonBlankBillingAddress = true;
                        else if (record.get(fieldName) != null && shippingAddressFields.contains(fieldName.toLowercase()))
                           nonBlankShippingAddress = true;
                        else if (record.get(fieldName) != null && personAddressFields.contains(fieldName.toLowercase()))
                           nonBlankPersonAddress = true;
                   }
               }
               // Set Address fields if blank
               if (!nonBlankBillingAddress) {
                    record.put('BillingStreet', d.get('BillingStreet'));
                    record.put('BillingCity', d.get('BillingCity'));
                    record.put('BillingState', d.get('BillingState'));
                    record.put('BillingPostalCode', d.get('BillingPostalCode'));
                    record.put('BillingCountry', d.get('BillingCountry'));
               }
               if (!nonBlankShippingAddress) {
                    record.put('ShippingStreet', d.get('ShippingStreet'));
                    record.put('ShippingCity', d.get('ShippingCity'));
                    record.put('ShippingState', d.get('ShippingState'));
                    record.put('ShippingPostalCode', d.get('ShippingPostalCode'));
                    record.put('ShippingCountry', d.get('ShippingCountry'));                    
               }
               if (isPerson  && !nonBlankPersonAddress) {
                    record.put('PersonMailingStreet', d.get('PersonMailingStreet'));
                    record.put('PersonMailingCity', d.get('PersonMailingCity'));
                    record.put('PersonMailingState', d.get('PersonMailingState'));
                    record.put('PersonMailingPostalCode', d.get('PersonMailingPostalCode'));
                    record.put('PersonMailingCountry', d.get('PersonMailingCountry'));                       
               }
               
               // Compute Merge Conflcits for PersonMailingAddress
               if (isPerson) {
                  boolean contMailingAddrBlank = true;
                  boolean dupMailingAddrBlank = true;
                  for (string strFld : personAddressFields){
                     if (contMailingAddrBlank)
                        if ((string.isNotBlank(string.valueOf(record.get(strFld))))&&(record.get(strFld)!=null)){
                           contMailingAddrBlank = false;system.debug(record.Id+':'+'+@1+: '+strFld+':'+string.valueOf(record.get(strFld)));}
                     if (dupMailingAddrBlank)
                        if ((string.isNotBlank(string.valueOf(d.get(strFld))))&&(d.get(strFld)!=null)){
                           dupMailingAddrBlank = false;system.debug(d.Id+':'+'+@2+: '+strFld+':'+string.valueOf(d.get(strFld)));}
                  }
              
                  if ( (!dupMailingAddrBlank) && (!contMailingAddrBlank)){
                     for (string strFld : personAddressFields){
                         if ((string.valueOf(record.get(strFld))!=string.valueOf(d.get(strFld))))
                           strMergeConflicts += (strFld + ': ' + string.valueOf(d.get(strFld))+'\r\n');
             
                     }
                 }
              
                 if (string.isNotBlank(record.Merge_Conflicts__pc))
                     strMergeConflictsMsg = record.Merge_Conflicts__pc + '\r\n' + strMergeConflictsMsg;
                 if (string.isNotBlank(strMergeConflicts))
                     strMergeConflictsMsg = strMergeConflictsMsg + ' with following conflicts: \r\n' + strMergeConflicts;
                 strMergeConflictsMsg+='--------------------\r\n';
                 if (string.isNotBlank(d.Merge_Conflicts__pc))
                     strMergeConflictsMsg+=d.Merge_Conflicts__pc;
                 record.Merge_Conflicts__pc= strMergeConflictsMsg;
              
                 record.Related_Main_Prospect__c = null;
              }
               
           }
            ////
            Boolean  completeMerge = false;          
            if (duplicates.size() < 3 && duplicates.size() > 0)    {
                Database.MergeResult[] results = Database.merge(record, duplicates, false);
                
                for(Database.MergeResult res : results) {
                    if (res.isSuccess()) {
                        // Get the master ID from the result and validate it
                        completeMerge  = true;
                        System.debug('Master record ID: ' + res.getId());
                    }
                    else {
                        for(Database.Error err : res.getErrors()) {
                            // Write each error to the debug output
                            System.debug(err.getMessage());
                        }
                    }
                }
            } else if (duplicates.size() < 3) 
                System.debug('Batch Merge: skip records too many for master record: ' + record.Id);
            else
                System.debug('Batch Merge: skip no duplicates for master record: ' + record.Id);
        }
        update records;
    }
    
private static void MergeOpps(Id OppId,Id dupOppId){
//private static void MergeOpportunity(Id OppId,Id dupOppId, Boolean mergeOppFields){
        if (( OppId==null)||(dupOppId==null)) return;
        if ( OppId==dupOppId) return;

        // Merge Tasks
        List<Task> lstTask = [Select Id, WhatId, Activity_Type__c, Subject   from Task where WhatId = : dupOppId ALL ROWS];
        for (Task t : lstTask) {
           t.WhatId = OppId;
           if (t.Activity_Type__c == 'Inquiry') {
              t.Activity_Type__c = 'ReInquiry';
              t.Subject = 'ReInquiry';
           }
        }

        if (lstTask.size() > 0)
           update  lstTask;   
           
        // Merge Events
        List<Event> lstEvent = [Select Id, WhatId from Event where WhatId = : dupOppId ALL ROWS];
        for (Event t : lstEvent)
           t.WhatId = OppId;

        if (lstEvent.size() > 0)
           update  lstEvent; 
           
        // Merge Transactions
        List<Transaction__c> lstTransaction = [Select Id, Opportunity__c from Transaction__c where Opportunity__c = : dupOppId ];
        for (Transaction__c t : lstTransaction)
           t.Opportunity__c  = OppId;

        if (lstTransaction.size() > 0)
           update  lstTransaction;     
                 
        // Merge Occupancies
        List<Occupancy__c> lstOcupancy = [Select Id, Source_Opportunity__c from Occupancy__c where Source_Opportunity__c = : dupOppId ];
        for (Occupancy__c t : lstOcupancy)
           t.Source_Opportunity__c = OppId;

        if (lstOcupancy.size() > 0)
           update  lstOcupancy; 
           
        // Create new OCRs and Delete old   
        List<OpportunityContactRole> lstnewOCR = new   List<OpportunityContactRole>();
        
        Map<Id, Id> mapOCRContacts = new Map<Id, Id>();
        // Create map to check for dup roles
        for (OpportunityContactRole ocr : [Select Id, ContactId, OpportunityId, IsPrimary  from OpportunityContactRole where OpportunityId = : OppId])
           mapOCRContacts.put(ocr.ContactId, ocr.OpportunityId);
        
        List<OpportunityContactRole> lstOCR = [Select Id, ContactId, OpportunityId, IsPrimary  from OpportunityContactRole where OpportunityId = : dupOppId ];
        
        // Create new OCRs only if they don't exist for Opp to keep for same contacts.
        for (OpportunityContactRole t : lstOCR) 
           if (!mapOCRContacts.containsKey(t.ContactId)     ) {
              OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = OppId, ContactId = t.ContactId);
              lstnewOCR.add(ocr);
           }
        if (lstnewOCR.size() > 0)
           insert lstnewOCR ; 
        if (lstOCR.size() > 0)
           delete lstOCR;           
           
// Merge Opp Fields
// -------------------------------------------------------------------------------
/*


        if (mergeOppFields) {
           String querystring = 'select  ';
           String selectedObject = 'Opportunity';
           Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
           Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
           Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
           for(String fieldName : fieldMap.keySet()) {
              if(   fieldMap.get(fieldName).getDescribe().isUpdateable() )
                  querystring += ' ' + fieldName +',';
           }
        
           querystring = querystring.left(querystring.length()-1);
           querystring += ' from Opportunity where Id = : OppId OR Id = :dupOppId';
           List<Opportunity> records = new List<Opportunity>();
           List<Opportunity> duplicates = new List<Opportunity>();
           for (Opportunity acc : (List<Opportunity>)database.query(querystring)){
               if ( OppId==acc.Id)
                   records.add(acc);
               else if (dupOppId==acc.Id)
                   duplicates.add(acc);
           }
           if ((records.isEmpty())||(duplicates.isEmpty())) return;
        
           if (string.isBlank(records.get(0).Description))
               records.get(0).Description = duplicates.get(0).Description;
           else if (string.isNotBlank(duplicates.get(0).Description))
               records.get(0).Description = records.get(0).Description+'\r\n'+duplicates.get(0).Description;
           for (Opportunity record: records) {
            ////
            String recordid = record.Id;
            
            for (Opportunity d :duplicates) {
             
               for(String fieldName : fieldMap.keySet()) {
                   if( fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                     System.Debug('MergeOpportunitysController - fieldName: ' + fieldName);
                 
                        if (d.get(fieldName) != null && record.get(fieldName) == null)
                           record.put(fieldName, d.get(fieldName));
                        else if(fieldMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Boolean)
                           if (continueProcessing && d.get(fieldName) == true)
                              record.put(fieldName, d.get(fieldName));         
                  }
              
              
                 }
               
              }
           
           }
           update records;
        }
    */
// -------------------------------------------------------------------------------------------------------------
       List<Opportunity> listDupOpps = [select Id from Opportunity where Id = : dupOppId];
       if (listDupOpps.size() > 0)
          delete listDupOpps;
    }
    
    
}