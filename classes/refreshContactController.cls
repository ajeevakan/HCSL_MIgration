public class refreshContactController {
@AuraEnabled
public static Id getOpportunity(Id recordId) {
   System.Debug('In RefreshContactController accid: ' + recordId);
   
   Id oppId;
   Date dttoday = Date.Today();
   System.Debug('In RefreshLeadController: ' + dttoday);
   //List<Lead> lstLead = [SELECT Id, ConvertedOpportunityId FROM Lead WHERE ConvertedContactId = :recordId ALL ROWS];
   List<Lead> lstLead = [SELECT Id, ConvertedOpportunityId, ConvertedAccountId FROM Lead WHERE ConvertedAccountId = :recordId  
       and (ConvertedOpportunity.Not_Opened_After_Conversion_Yet__c = true) and (ConvertedOpportunityId  != null ) ALL ROWS ];
   
    //Start of changes AJ - 
    system.debug('lstLead ' + lstLead);
    for (Lead l1: lstLead )
        system.debug('l1.ConvertedOpportunityId ' + l1.ConvertedOpportunityId);
    // End of changes AJ
   
   Boolean notFoundOpp = true;    
   if (lstLead != null)
      for (Lead l: lstLead )
         if (l.ConvertedOpportunityId != null) {
               oppId = l.ConvertedOpportunityId ;
               List<Opportunity> oList = [select Not_Opened_After_Conversion_Yet__c , Id from Opportunity where Id = :oppId ];
               for (Opportunity o :oList)
                 o.Not_Opened_After_Conversion_Yet__c = false;
             
               if (oList != null)
                  if (oList.size() > 0) {
                     notFoundOpp = false;
                     
                     update oList;
                    
                     }
            }
   System.Debug('In RefreshLeadController: ' + recordId + ' returned Id: ' + oppId);         
   return oppId;
}
}