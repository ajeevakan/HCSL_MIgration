Public class AutoConvertLeads
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
        
         //Start of merge of duplicate Leads into accounts
        
        Id AccountToKeep;
        Id AccountToMerge;
        Id ContactToKeep;
        Id ContactToMerge;  
        Id OpportunityToKeep;
        Id OpportunitytoMerge;
        Boolean MergeToOpportunity = true;
        
        //End of merge of duplicate Leads into accounts
        
        
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        List<Task> tList = new List<Task>();
        List<CampaignMember> cmList = new List<CampaignMember>();
        
        //Adding Account_to_Merge__c, Optional_Contact_to_Merge__c, Optional_Opportunity_to_Merge__c
        /*Map<Id, Lead> mapLeads = new Map<Id, Lead>([select Id, Lead_Source_Campaign__c, Initial_Activity_Type__c, Initial_Activity_Result_Code__c, 
              Initial_Activity_Notes__c, ,
              Follow_Up_Activity_Type__c, Follow_Up_Activity_Date__c, Follow_Up_Activity_Notes__c,
              LeadSource, Prospect_Last_Name__c, Prospect_First_Name__c, Relationship_to_Prospect__c, 
              Addl_Prospect_Last_Name__c, Addl_Prospect_First_Name__c, Addl_Relationship_to_Prospect__c, Description,
              Create_Opportunity__c
             from Lead where Id in :LeadIds]);*/
             
             
        //Health cloud config commenting out the below code 
        /*Map<Id, Lead> mapLeads = new Map<Id, Lead>([select Id, Lead_Source_Campaign__c, Initial_Activity_Type__c, Initial_Activity_Result_Code__c, 
              Initial_Activity_Notes__c, Inquiry_Date__C,
              Follow_Up_Activity_Type__c, Follow_Up_Activity_Date__c, Follow_Up_Activity_Notes__c,
              LeadSource, Prospect_Last_Name__c, Prospect_First_Name__c, Relationship_to_Prospect__c, 
              Addl_Prospect_Last_Name__c, Addl_Prospect_First_Name__c, Addl_Relationship_to_Prospect__c, Description, Account_to_Merge__c, Optional_Contact_to_Merge__c, Optional_Opportunity_to_Merge__c, Create_Opportunity__c
             from Lead where Id in :LeadIds]);*/
        
        //system.debug('LeadIds ' + LeadIds);   
        /*
        Map<Id, Lead> mapLeads = new Map<Id, Lead>([select Id, Initial_Activity_Type__c, Initial_Activity_Result_Code__c, 
              Initial_Activity_Notes__c, Follow_Up_Activity_Type__c, Follow_Up_Activity_Date__c, Follow_Up_Activity_Notes__c,
              LeadSource , Description, Prospect_Last_Name__c, Prospect_First_Name__c, Addl_Prospect_Last_Name__c, Addl_Prospect_First_Name__c, 
              Create_Opportunity__c, Lead_Source_Campaign__c, Inquiry_Date__C, LastName, Community__c, Prospect__c, Relationship_To_Prospect__c,
              Merge_to_Contact__c, Merge_to_Contact__r.AccountId, Add_ReInquiry_to_Opportunity__c, Add_to_Household_of_Opportunity__c,     Create_New_Opportunity__c
             from Lead where Id in :LeadIds]);
        */
        Map<Id, Lead> mapLeads = new Map<Id, Lead>();
        for  (Lead l: [select Id, Initial_Activity_Type__c, Initial_Activity_Result_Code__c, 
              Initial_Activity_Notes__c, Follow_Up_Activity_Type__c, Follow_Up_Activity_Date__c, Follow_Up_Activity_Notes__c,
              LeadSource , Description, Prospect_Last_Name__c, Prospect_First_Name__c, Addl_Prospect_Last_Name__c, Addl_Prospect_First_Name__c, 
              Create_Opportunity__c, Lead_Source_Campaign__c, Inquiry_Date__C, LastName, Community__c, Prospect__c, Relationship_To_Prospect__c,
              Merge_to_Contact__c, Merge_to_Contact__r.AccountId, Add_ReInquiry_to_Opportunity__c, Add_to_Household_of_Opportunity__c,     Create_New_Opportunity__c
             from Lead where Id in :LeadIds]) {
             mapLeads.put(l.Id, l);
             System.Debug('AUTOCONVERT LEADS READ LEAD: ' + l.Merge_to_Contact__c + ', ' + l.Merge_to_Contact__r.AccountId + ', ' + l);
             if (l.Merge_to_Contact__c != null) {
                AccountToKeep = l.Merge_to_Contact__r.AccountId;
              //  for (Contact c: [select AccountId from Contact where id = :l.Merge_to_Contact__c  ])
              //     AccountToKeep = c.AccountId;
                }
             System.Debug('AUTOCONVERT LEADS READ LEAD AccountToKeep : ' + AccountToKeep );
       }
          
        Map<String, CampaignMember> mapCM = new   Map<String, CampaignMember>();
        for (CampaignMember cm :[select LeadId, CampaignId from CampaignMember where LeadId in :LeadIds])  
          mapCM.put(cm.LeadId+'-'+cm.CampaignId, cm);
        LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(id currentlead: LeadIds){
                // customize for campaign member
                Lead ld = mapLeads.get(currentlead);
                //system.debug('currentlead ' + currentlead);
                
                //Health cloud config commenting out the below code 
                //AccountToKeep = ld.Account_to_Merge__c;
                //ContactToKeep = ld.Optional_Contact_to_Merge__c; 
                //OpportunityToKeep = ld.Optional_Opportunity_to_Merge__c;
                
              if (ld.Lead_Source_Campaign__c != null) 
                   if (!(mapCM.containsKey(ld.Id+'-'+ld.Lead_Source_Campaign__c))) {
                   CampaignMember cmNew = new CampaignMember(CampaignId = ld.Lead_Source_Campaign__c, LeadId = currentLead, Status = 'Responded');
                   cmList.add(cmNew);
                }
                // customize for initial activity
                if (ld.Initial_Activity_Type__c != null) {
                   Task t = new Task(Activity_Type__C = ld.Initial_Activity_Type__c, Subject = ld.Initial_Activity_Type__c, WhoId = currentLead, 
                      Result_Code__c = ld.Initial_Activity_Result_Code__c,
                      Description = ld.Initial_Activity_Notes__c, ActivityDate = ld.Inquiry_Date__c, Status = 'Completed');
                   tList.add(t);
                }
                
                // customize for initial activity
                if (ld.Follow_Up_Activity_Type__c != null) {
                   Date activityDate = Date.Today();
                   if (ld.Follow_Up_Activity_Date__c != null)
                      activityDate = ld.Follow_Up_Activity_Date__c;
                   Task t = new Task(Activity_Type__C = ld.Follow_Up_Activity_Type__c , Subject = ld.Follow_Up_Activity_Type__c, WhoId = currentLead, 
                      ActivityDate = activityDate, Description = ld.Follow_Up_Activity_Notes__c, 
                      Status = 'Not Started');
                   tList.add(t);
                }
                
               
                
                Database.LeadConvert Leadconvert = new Database.LeadConvert();
                
                
                //Health cloud config commenting out the below code
                /*
                if (OpportunityToKeep != null)
                    Leadconvert.setDoNotCreateOpportunity(TRUE);*/
                
                Leadconvert.setLeadId(currentlead);                
                Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
                
                //Added on 25 Aug 21 as LeadConvertResult is commented out while doing tring to implement the senior living in HC
                //Database.LeadConvertResult lcr = Database.convertLead(Leadconvert);
                
                //HC Config 
                /*
                //System.assert(lcr.isSuccess());
                
                //system.debug('Status ' + Leadconvert.getConvertedStatus());
                //system.debug('Converted Status ' + lcr.isSuccess());
                
                //system.debug('Acc ID ' + Leadconvert.getAccountId());
                //system.debug('Contact ID ' + Leadconvert.getContactId());
                */
                
                // Change formula on Create Opportunity field to create or not create opportunities.  If true, opp will be created
             //   if (!(ld.Create_Opportunity__c))      
                   //Leadconvert.setDoNotCreateOpportunity(TRUE); //Remove this line if you want to create an opportunity from Lead Conversion 
                MassLeadconvert.add(Leadconvert);
        }

        if (cmList.size() > 0)
          insert cmList;
        if (tList.size() > 0 )
          insert tList;
        
        if (!MassLeadconvert.isEmpty()) {
          List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
          
          // To store list of contacts which are to be insert
          List<Contact> contactToBeInsert = new List<Contact>();
          List<Id> AccountIds = new List<Id>();
          List<Id> OppIds = new List<Id>();
          
          // HC Configs
          /*
          Map<Id, String> mapAccountsLeadSource = new Map<Id, String>();
          Map<Id, String> mapAccountsDescription = new Map<Id, String>();
          */
          
          List<Account> householdsList = new List<Account>();
          List<AccountContactRelation> accountContactRelationsList = new List<AccountContactRelation>();
          Map<Id, Id> mapConvertedAccounttoConvertedContactId = new Map<Id, Id>();
          Map<Id, Id> mapConvertedOpptoConvertedContactId = new Map<Id, Id>();
          Map<Id, Id> mapConvertedOpptoConvertedProspectContactId = new Map<Id, Id>();
          
          for ( Database.LeadConvertResult olcResults : lcr ) 
          {
             if (olcResults.isSuccess()) {
                Id lid = olcResults.getLeadID();
                Lead l = mapLeads.get(lid);
                System.Debug('AUTOCONVERT LEADS CONVERTED LEAD: ' + l);
                Id acctId = olcResults.getAccountId();
                Id conId = olcResults.getContactId(); 
                Id OppId = olcResults.getOpportunityId(); 
                OppIds.add(OppId);
                mapConvertedAccounttoConvertedContactId.put(acctId , conId  ); 
                mapConvertedOpptoConvertedContactId.put(OppId , conId  );  
                if (l.Prospect__c)
                   mapConvertedOpptoConvertedProspectContactId.put(OppId , conId  ); 
                
                //HC Configs
                /*
                if (l.LeadSource != null || l.Description != null) {
                   AccountIds.add(acctId);
                   if (l.LeadSource != null) 
                      mapAccountsLeadSource.put(acctId, l.LeadSource);
                   if (l.Description != null) 
                      mapAccountsDescription.put(acctId, l.Description );
                }
                */
                
                // Id conId =olcResults.getContactId();
                // If prospective resident specified then create a prospective resident
                
                String householdName = l.lastname;
                
                // HC Configs -- we will need to modify this to create a Person Account instead of a Contact if we want to add Prospects from initial lead
                /*
                if (l.Prospect_Last_Name__c != Null) {
                    //HC Config - removing Prospect__c
                   //Contact c = New Contact(LastName = l.Prospect_Last_Name__c, FirstName = l.Prospect_First_Name__c, Prospect__c = True  , AccountId = acctId, Relationship_to_Prospect__c = 'Self' );
                   Contact c = New Contact(LastName = l.Prospect_Last_Name__c, FirstName = l.Prospect_First_Name__c, 
                   AccountId = acctId, Relationship_to_Prospect__c = 'Self', Related_Main_Prospect__c =  acctId );
                   contactToBeInsert.add(c);
                   householdName = l.Prospect_Last_Name__c;
                } 
                */
                
                // Create a Household Account
                // Related Main Prospect is usually used to relate person accounts, but we are using it here with Households to relate the main converted person Account
                Account householdAccount = new Account(Name = householdName + ' Household', Related_Main_Prospect__c = acctId, RecordTypeId =  hhRecordTypeId, Community__c = l.Community__c );
                householdsList.add(householdAccount);
                
                //HC Configs
                /*
                // If Additional prospect then create it too.
                if (l.Addl_Prospect_Last_Name__c != Null && l.Addl_Relationship_to_Prospect__c != Null) {
                    Contact c1 = new contact( lastName = l.Addl_Prospect_Last_Name__c, firstName = l.Addl_Prospect_First_Name__c, Relationship_to_Prospect__c = l.Addl_Relationship_to_Prospect__c, Prospect__c = true, AccountId = acctId );
                    contactToBeInsert.add(c1);
                }*/
                //Start of merge of duplicate Leads into accounts
                
                System.Debug('AUTOCONVERT LEADS: MERGE PREP ' + acctId + ', ' + conId  + ', ' +  l.Merge_to_Contact__c  + ', ' + l.Merge_to_Contact__r.AccountId );
                
                AccountToMerge = acctId;
                ContactToMerge = conId ; 
                OpportunitytoMerge = OppId ;
                if (l.Merge_to_Contact__c != null) {
                  // cant get this from a map of leads.  Done above
                  // AccountToKeep = l.Merge_to_Contact__r.AccountId;
                   ContactToKeep = l.Merge_to_Contact__c ;
                }
                if (l.Create_New_Opportunity__c ) 
                   MergeToOpportunity = false;
              
                OpportunityToKeep = l.Add_ReInquiry_to_Opportunity__c;
                if (l.Add_to_Household_of_Opportunity__c != null)
                   OpportunityToKeep = l.Add_to_Household_of_Opportunity__c;
                //End of merge of duplicate Leads into accounts
             } 
          }
          //HC Config 
          /*          
           // dont use this merge method if merging with an Opportunity
          if (OpportunityToKeep == null && AccountToKeep != null && AccountToMerge != null) { 
             MergeAccountsController sc = new MergeAccountsController();
              String mergeMsg =  sc.MergeAccountsfromLead(AccountToKeep , AccountToMerge );   
          }
          
          if (AccountToKeep != null && AccountToMerge != null) { 
             MergeAccountsController sc = new MergeAccountsController();
              String mergeMsg =  sc.MergeAccountsfromLead(AccountToKeep , AccountToMerge );   
          }
          
          if ( ContactToKeep != null &&  ContactToMerge != null) { 
             MergeContactsController sc = new MergeContactsController();
              String mergeMsg =  sc.MergeContactsfromLead( ContactToKeep ,  ContactToMerge );   
          } 
          */
          
          
          // The below is not necessary and does not work for Person Accounts
          /*
          if (AccountIds.size() > 0) {
             List<Account> AccountsToUpdate = new List<Account>();
             for (Account a: [ SELECT Id, Name, Description FROM Account WHERE Id in :AccountIds]) {
                if (mapAccountsLeadSource.containsKey(a.Id))
                   a.Lead_Source__c = mapAccountsLeadSource.get(a.Id);
                if (mapAccountsDescription.containsKey(a.Id))
                   a.Description = mapAccountsDescription.get(a.Id);
                AccountsToUpdate.add(a);
             }
             
            if (AccountsToUpdate.size() > 0)
                update AccountsToUpdate;
          }    
          
          */  
          
    
          
          
          if (householdsList.size() > 0)
             insert householdsList;
           Map<Id, Id> mapHouseholdtoConvertedProspectContactId = new Map<Id, Id>();   
          for (Account household : householdsList)
              if (household.Related_Main_Prospect__c  != null)
                 if (mapConvertedAccounttoConvertedContactId.containsKey(household.Related_Main_Prospect__c )) {
                    AccountContactRelation acrForNewContact = new AccountContactRelation();
                    acrForNewContact.ContactId = mapConvertedAccounttoConvertedContactId.get(household.Related_Main_Prospect__c );
                    acrForNewContact.AccountId = household.Id;
                    accountContactRelationsList.add(acrForNewContact);
                    mapHouseholdtoConvertedProspectContactId.put(household.Related_Main_Prospect__c, household.Id);

                 }
                    
          if (accountContactRelationsList.size() > 0)
             insert accountContactRelationsList;
          
          if(contactToBeInsert.size() > 0) {
             //update to ignore duplicate rules due to APFM extra prospect data causing dup errors
             Database.DMLOptions dml = new Database.DMLOptions();
             dml.DuplicateRuleHeader.allowSave = true;
             dml.DuplicateRuleHeader.runAsCurrentUser = true; 

             Database.insert(contactToBeInsert, dml); 
          }
          //HC Config 
          /*
          List<CampaignMember> cmlst = [select Id from CampaignMember where ContactId in (select Id from Contact where AccountId in :AccountIds)];
          if (cmlst != null)
             if (cmlst.size() > 0)
                update cmlst;      
            
*/
           
           // Set Primary Contact, Primary Resident, and Household on Opportunity as appropriate
          
            List<Id> convertedProspects = new List<Id>(); 
          
            if(OppIds.size() > 0) {
                List<Opportunity> OppstoUpdate = new List<Opportunity>();
                for (Opportunity o : [SELECT Id, AccountId, Primary_Resident__c, Primary_Contact__c, Primary_Household__c FROM Opportunity WHERE Id in : OppIds]) {
                    if (mapConvertedOpptoConvertedContactId.containsKey(o.Id))
                       o.Primary_Contact__c = mapConvertedOpptoConvertedContactId.get(o.Id);
                    if (mapConvertedOpptoConvertedProspectContactId.containsKey(o.Id)) {
                       o.Primary_Resident__c = mapConvertedOpptoConvertedProspectContactId.get(o.Id);
                       convertedProspects.add(o.Primary_Resident__c);
                    }
                    if (mapHouseholdtoConvertedProspectContactId.containsKey(o.AccountId) )
                       o.Primary_Household__c  = mapHouseholdtoConvertedProspectContactId.get(o.AccountId);
                    OppstoUpdate.add(o);
                }
                if (OppstoUpdate.size() > 0)
                    update OppstoUpdate;
            }
              
         //   Update OCR records  
            List<OpportunityContactRole> lstOCR = new List<OpportunityContactRole>();        
            if(OppIds.size() > 0 && convertedProspects.size() > 0) {
           
                for (OpportunityContactRole ocr : [SELECT Id, Role FROM OpportunityContactRole WHERE ContactId in : convertedProspects]) {
                    ocr.Role = 'Primary Prospect Resident';
                    lstOCR.add(ocr);
                }
         
                if (lstOCR.size() > 0)
                    update lstOCR ;
            }
            
        }
        
       
        
        // Merge Operations
        System.Debug('AUTOCONVERTLEADS MERGE: CHECK ' + AccountToKeep + ', ' + ContactToKeep );
        
        // scenario 1 - Merging Contacts.  If Merge To Opportunity is true then merge Opportunities also.  Will merge households if different.
        if (AccountToKeep != null && ContactToKeep != null) {
          System.Debug('AUTOCONVERTLEADS MERGE: START ' + AccountToKeep +', ' + AccountToMerge +', ' + OpportunityToKeep +', ' + OpportunitytoMerge); 
          MergeAccountsController sc = new MergeAccountsController();
          String errormsg = sc.MergePersonAccountsfromLead (AccountToKeep , AccountToMerge, OpportunityToKeep, OpportunitytoMerge, MergeToOpportunity  );    
          System.Debug('AUTOCONVERTLEADS MERGE: END ' + errormsg ); 
        // scenario 2 - Not Merging contacts.   Creating new Opportunity, but merging Households. 
        } else if (  (!MergeToOpportunity)  && OpportunityToKeep != null) {
            Id AcctToKeep;
            Id AcctToMerge;
            for ( Opportunity o : [select Id, Primary_Household__c from Opportunity where Id = : OpportunityToKeep OR Id = : OpportunitytoMerge]) {
               if (o.Id == OpportunityToKeep )
                  AcctToKeep = o.Primary_Household__c ;
               if (o.Id == OpportunitytoMerge)
                  AcctToMerge = o.Primary_Household__c ;
            }
            MergeAccountsController sc = new MergeAccountsController();
            if (AcctToKeep  != null && AcctToMerge != null)
              sc.MergeHouseholdsfromLead(AcctToKeep ,AcctToMerge );
        // Scenario 3 - Not merging Contacts. Merging Opportunities and Households.
        } else if (OpportunityToKeep != null) {
                       Id AcctToKeep;
            Id AcctToMerge;
            for ( Opportunity o : [select Id, Primary_Household__c from Opportunity where Id = : OpportunityToKeep OR Id = : OpportunitytoMerge]) {
               if (o.Id == OpportunityToKeep )
                  AcctToKeep = o.Primary_Household__c ;
               if (o.Id == OpportunitytoMerge)
                  AcctToMerge = o.Primary_Household__c ;
            }
            MergeAccountsController sc = new MergeAccountsController();
            if (OpportunityToKeep != null && OpportunitytoMerge != null)
               sc.MergeOppsfromLead(OpportunityToKeep , OpportunitytoMerge , AcctToKeep , AcctToMerge );
        }
     }
    }