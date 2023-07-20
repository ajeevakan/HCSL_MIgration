public class Opportunity360 {


@AuraEnabled
    public static Opportunity getOpp(Id recordId) {
       ////List<Task> lstTask = [select AccountId, Id, Subject, Description, ActivityDate, Result_Code__c, Activity_Type__c, WhoId, WhatId, What.Name, Who.Name from Task where Id =: recordId];
       Id OppId = recordId;
       
      /* List<Opportunity> lstOpp = [select AccountId, Id, Name, Temp_Display__c, Apartment_Care_Level__c, Care_Level__c, Location_Preference__c, Prospect_Qualified__c 
        ,Current_Situation__c,Desired_Situation__c,Benefits__c,Risks_and_Concerns__c,Priority_and_Urgency__c 
        from Opportunity where Id =: OppId ];*/
        
      List<Opportunity> lstOpp = [select AccountId, Id, Name from Opportunity where Id =: OppId ];
        
       System.Debug('getOpp in Task360 lstOpp: '+ lstOpp );  
       
       /*for (Waitlist__c w :[select Id, Unit_Type__c from Waitlist__c where Opportunity__c =: OppId ] )
          if (lstOpp[0].Temp_Display__c == null)
             lstOpp[0].Temp_Display__c = w.Unit_Type__c;
          else
             lstOpp[0].Temp_Display__c = lstOpp[0].Temp_Display__c + '; ' + w.Unit_Type__c;*/
       
       if (lstOpp != null)
          if (lstOpp .size() > 0)
             return lstOpp[0];
       return null;
       }
    
    @AuraEnabled
    public static string MakePrimaryResident(Id OCRId){
        string strErr = '';
        try{
            if (string.isBlank(OCRId)) strErr = 'Opportunity Contact Role Id is blank.';
            else{
                OpportunityContactRole objOCR1 = null;
                OpportunityContactRole objOCR2 = null;
                list<sObject> lstUpdate = new list<sObject>();
                for (OpportunityContactRole tmp : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE Id = :OCRId])
                    objOCR2 = tmp;
                if (objOCR2==null) strErr = 'Could Not read Opportunity Contact Role record.';
                else if (!('Second Prospect Resident'.equalsIgnoreCase(objOCR2.Role))) strErr = 'Selected contact\'s Role is Not \'Second Prospect Resident\'';
                else{
                    objOCR2.Role='Primary Prospect Resident';
                    lstUpdate.add(objOCR2);
                    for (OpportunityContactRole tmp : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE Id != :OCRId AND OpportunityId = :objOCR2.OpportunityId AND Role = 'Primary Prospect Resident' LIMIT 1]){
                        tmp.Role='Second Prospect Resident';
                        lstUpdate.add(tmp);
                        objOCR1 = tmp;
                    }
                    for (Opportunity tmp : [SELECT Primary_Resident__c, Second_Resident__c, Id FROM Opportunity WHERE Id = :objOCR2.OpportunityId]){
                        tmp.Primary_Resident__c=objOCR2.ContactId;
                        if (objOCR1==null) tmp.Second_Resident__c=null;
                        else tmp.Second_Resident__c=objOCR1.ContactId;
                        lstUpdate.add(tmp);
                    }
                    update lstUpdate;
                }
            }
        }
        catch (Exception exc){strErr=exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';}
        return strErr;
    }
    
    
    @AuraEnabled
    public static string DemoteSecondResident(Id OCRId){
        string strErr = '';
      
        try{
            if (string.isBlank(OCRId)) strErr = 'Opportunity Contact Role Id is blank.';
            else{
                OpportunityContactRole objOCR1 = null;
                OpportunityContactRole objOCR2 = null;
                list<sObject> lstUpdate = new list<sObject>();
                for (OpportunityContactRole tmp : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE Id = :OCRId])
                    objOCR2 = tmp;
                if (objOCR2==null) strErr = 'Could Not read Opportunity Contact Role record.';
                else if (!('Second Prospect Resident'.equalsIgnoreCase(objOCR2.Role))) strErr = 'Selected contact\'s Role is not \'Second Prospect Resident\'';
                else{
                    objOCR2.Role='Influencer';
                    lstUpdate.add(objOCR2);
                    for (Opportunity tmp : [SELECT Primary_Resident__c, Second_Resident__c, Id FROM Opportunity WHERE Id = :objOCR2.OpportunityId]){
                       tmp.Second_Resident__c=null;
                       lstUpdate.add(tmp);
                    }
                    update lstUpdate;
                }
            }
        }
        catch (Exception exc){strErr=exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';}
        return strErr;
    }
    
    @AuraEnabled
    public static string MakeSecondResident(Id OCRId){
        string strErr = '';
        Boolean continueProcessing = true;
        try{
            if (string.isBlank(OCRId)) strErr = 'Opportunity Contact Role Id is blank.';
            else{
                OpportunityContactRole objOCR1 = null;
                OpportunityContactRole objOCR2 = null;
                list<sObject> lstUpdate = new list<sObject>();
                for (OpportunityContactRole tmp : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE Id = :OCRId])
                    objOCR2 = tmp;
                if (objOCR2==null) strErr = 'Could Not read Opportunity Contact Role record.';
                else if (!('Influencer'.equalsIgnoreCase(objOCR2.Role))) strErr = 'Selected contact\'s Role is not \'Influencer\'';
                else{
                    objOCR2.Role='Second Prospect Resident';
                    lstUpdate.add(objOCR2);
                    for (OpportunityContactRole tmp : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE Id != :OCRId AND OpportunityId = :objOCR2.OpportunityId AND Role = 'Second Prospect Resident' LIMIT 1]){
                        strErr = 'A Second Resident is Already Assigned.  Demote it or make it Primary Resident first';
                        continueProcessing = false;
                    }
                    if (continueProcessing) {
                       for (Opportunity tmp : [SELECT Primary_Resident__c, Second_Resident__c, Id FROM Opportunity WHERE Id = :objOCR2.OpportunityId]){
                          tmp.Second_Resident__c=objOCR2.ContactId;
                          lstUpdate.add(tmp);
                       }
                       update lstUpdate;
                    }
                }
            }
        }
        catch (Exception exc){strErr=exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';}
        return strErr;
    }
    
    @AuraEnabled
    public static string SetContactInactive(Id idContact, boolean boolInactive, boolean boolDeceased, boolean updateDeceased){
        string strErr = '';
        try{
            if (string.isBlank(idContact)) strErr = 'Contact Id is blank.';
            else{
                Contact objContact = null;
                for (Contact tmp : [SELECT Id,Deceased__c,Inactive__c,IsPersonAccount FROM Contact WHERE Id = :idContact]){
                    tmp.Inactive__c=boolInactive;
                    if (updateDeceased) tmp.Deceased__c=boolDeceased;
                    objContact=tmp;
                }
                if (objContact==null) strErr = 'Cannot read Contact record.';
                else{ 
                    update objContact;
                    system.debug(objContact.Id);
                    if (objContact.IsPersonAccount) 
                        for (Account acc : [select id, isActive FROM Account WHERE PersonContactId = :objContact.Id]){
                            acc.isActive = !objContact.Inactive__c;
                            update acc;
                        }
                    
                }
            }
        }
        catch (Exception exc){strErr=exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';}
        return strErr; 
    }
    
    @AuraEnabled
    public static string MakePrimaryContact(Id OCRId){
        string strErr = '';
        try{
        if (string.isBlank(OCRId)) strErr = 'Opportunity Contact Role Id is blank.';
        else{
            OpportunityContactRole objOCR = null;
            list<OpportunityContactRole> lstOCR = new list<OpportunityContactRole>();
            for (OpportunityContactRole tmp : [SELECT Id, IsPrimary, OpportunityId, ContactId FROM OpportunityContactRole WHERE Id = :OCRId])
                objOCR = tmp;
            if (objOCR==null) strErr = 'Could Not read Opportunity Contact Role record.';
            else{
                for (OpportunityContactRole tmp : [SELECT Id, IsPrimary, OpportunityId, ContactId FROM OpportunityContactRole WHERE Id != :OCRId AND OpportunityId = :objOCR.OpportunityId AND IsPrimary = true]){
                    tmp.IsPrimary=false;
                    lstOCR.add(tmp);
                }
                objOCR.IsPrimary=true;
                lstOCR.add(objOCR);
                Opportunity opp = null;
                for (Opportunity tmp : [SELECT Primary_Contact__c, Id FROM Opportunity WHERE Id = :objOCR.OpportunityId]){
                    tmp.Primary_Contact__c = objOCR.ContactId;
           
                    opp = tmp;
                }
                update lstOCR;
                update opp;
            }
        }
        }
        catch (Exception exc){strErr=exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';}
        return strErr;         
    }

@AuraEnabled
    public static List<OpportunityContactRole> getContacts(Id recordId) {
    
    /*
       List<Opportunity> lstTask = [select AccountId from Opportunity where Id =: recordId];
       Id accountId = null;
       if (lstTask != null)
          if (lstTask.size() > 0)
             accountId  = lstTask[0].AccountId;
             */
             
       /*return   [select Id,Name, FirstName, LastName, Email, Phone, 
       MobilePhone, HomePhone, Work_Phone__c,
       Relationship_to_Prospect__c, Prospect__c, Primary_Contact__c,
     MailingStreet, MailingCity, MailingState, MailingPostalCode,
     Description, Talker__c,    Doer__c,    Controller__c, Supporter__c,
     Buying_Styles_Display__c
        FROM Contact WHERE  IsDeleted = FALSE AND AccountId = :accountId  order by prospect__c desc Limit 1000 ];*/ 
        
        /*
        return   [select Id,Name, FirstName, LastName, Email, Phone, 
       MobilePhone, HomePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode,
     Description, Relationship_to_Prospect__c from contact where id in (select contactid from  OpportunityContactRole WHERE  IsDeleted = FALSE AND OpportunityId =: recordId) Limit 1000 ];}
*/

        return   [select IsPrimary, Contact.Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone, 
       Contact.MobilePhone, Contact.HomePhone, Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode,
     Contact.Description, Contact.Relationship_to_Prospect__c, Contact.Inactive__c, Role, Contact.Prospect__c from  OpportunityContactRole WHERE  IsDeleted = FALSE AND OpportunityId =: recordId Limit 100 ];}



@AuraEnabled
  public static List<Task> getTaskList(Id recordId) {
    System.Debug('Account360 recordId:' + recordId);
     /*return [select id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c FROM Task WHERE  IsDeleted = FALSE AND
   (AccountId =: recordId)  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];*/
   
    return [select id,Status,ActivityDate,Subject,Who.Name,What.Name,Description  FROM Task WHERE  IsDeleted = FALSE AND
   (AccountId =: recordId)  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
   
  }
  
@AuraEnabled
  public static List<wrapActivity> getActivities(Id recordId) {
   list<wrapActivity> wrapActivitylist;
   list<Task> tasklist;
   list<Event> eventlist;
   list<CampaignMember> cmlist;

   if(recordId!=null ) {
       List<Opportunity> lstTask = [select AccountId from Opportunity where Id =: recordId];
       Id accountId = null;
       if (lstTask != null)
          if (lstTask.size() > 0)
             accountId  = lstTask[0].AccountId;
   wrapActivitylist = new list<wrapActivity>();
   
   //Updated the below SOQL to include IsDeleted = FALSE
   
   /*tasklist= [select id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c FROM Task WHERE  IsDeleted = FALSE AND
   (AccountId =: accountId  )  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];*/
   
   /*
   tasklist= [select id,Status,ActivityDate,Subject,Who.Name,What.Name,Description, Owner.Name FROM Task WHERE  IsDeleted = FALSE AND
   (AccountId =: accountId  )  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
*/
    tasklist= [select id,Status,ActivityDate,Subject,Who.Name,What.Name,Description, Owner.Name FROM Task WHERE  IsDeleted = FALSE AND
   (WhatId =: recordId  )  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];

   /*eventlist= [select id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c FROM Event WHERE IsDeleted = FALSE AND
   (AccountId =: accountId  ) ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];*/
   
   /*
   eventlist= [select id,ActivityDate,Subject,Who.Name,What.Name,Description, Owner.Name FROM Event WHERE IsDeleted = FALSE AND
   (AccountId =: accountId  ) ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
   */
      eventlist= [select id,ActivityDate,Subject,Who.Name,What.Name,Description, Owner.Name FROM Event WHERE IsDeleted = FALSE AND
  (WhatId =: recordId  )  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
   
  // cmlist = [select Id, Name, Status, Campaign.Name, Contact.Name, CreatedDate, Campaign.StartDate, 
  // Campaign.Type from CampaignMember where Contact.AccountId = : accountId  LIMIT 1000];
  // Updated to get based on OCRs of Opp
  cmlist = [select Id, Name, Status, Campaign.Name, Contact.Name, CreatedDate, Campaign.StartDate, 
   Campaign.Type from CampaignMember where ContactId in (select ContactId from OpportunityContactRole where OpportunityId = : recordId  )LIMIT 1000];

   Integer counter = 0;
   if (tasklist != null)
      for (task t: tasklist) {
        if (counter < 1000) {
    
         wrapActivity wa = new wrapActivity();
         wa.ActivityDate = t.ActivityDate;
         wa.Subject = t.Subject;
         wa.Description = t.Description;
         wa.OwnerName = t.Owner.Name;
        // wa.ResultCode = t.Result_Code__C;
         wa.WhatName = t.What.Name;
         wa.WhoName = t.Who.Name;
         wrapActivitylist.add(wa);
         counter++;
         }
      }
      
   if (eventlist != null)
      for (event t: eventlist) {
         if (counter < 1000) {
         wrapActivity wa = new wrapActivity();
         wa.ActivityDate = t.ActivityDate;
         wa.Subject = t.Subject;
         wa.Description = t.Description;
         wa.OwnerName = t.Owner.Name;
         //wa.ResultCode = t.Result_Code__C;
         wa.WhatName = t.What.Name;
         wa.WhoName = t.Who.Name;

         wrapActivitylist.add(wa);
         counter++;
         }
      }

      if (cmlist != null)
      for (CampaignMember cm: cmlist ) {
         if (counter < 1000) {
         wrapActivity wa = new wrapActivity();
         wa.ActivityDate = Date.newinstance(cm.CreatedDate.year(), cm.CreatedDate.month(), cm.CreatedDate.day());
         if (cm.Campaign.StartDate != null)
            wa.ActivityDate  =  cm.Campaign.StartDate;
         String subject = cm.Status;
         if (cm.Campaign.Type  !=null)
            subject = cm.Campaign.Type + ' - ' + cm.Status;
         wa.Subject = subject;
         wa.Description = cm.Campaign.Name;
      //   wa.OwnerName = t.Owner.Name;
      //   wa.ResultCode = t.Result_Code__C;
      //   wa.WhatName = t.What.Name;
         wa.WhoName = cm.Contact.Name;
         wrapActivitylist.add(wa);
         counter++;
         }
      }

    if (wrapActivitylist != null) 
      wrapActivitylist.sort();  
      
    }
    return   wrapActivitylist;
    

}
 

}