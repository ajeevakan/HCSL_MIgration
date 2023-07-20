public class NOTUSEDrefreshLeadController{
@AuraEnabled
public static Id getOpportunity(Id recordId) {
   System.Debug('In RefreshContactController: ' + recordId);
   Id oppId;

   List<Lead> lstLead = [SELECT Id, ConvertedOpportunityId FROM Lead WHERE Id = :recordId ALL ROWS];

 
   Boolean notFoundOpp = true;    
   if (lstLead != null)
      for (Lead l: lstLead )
         if (l.ConvertedOpportunityId != null) {
               oppId = l.ConvertedOpportunityId ;
            }
    
   System.Debug('In RefreshLeadController: ' + recordId + ' returned Id: ' + oppId);         
   return oppId;
}
}