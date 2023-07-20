public class newLeadController {
@AuraEnabled
public static String getCommunity() {
   string strCommunity = '';
   List<User> lstUser = [SELECT Id, Primary_Community__C  FROM User WHERE Id = :UserInfo.getUserId()];
   if (lstUser  != null)
      for (User u: lstUser)
        if (u.Primary_Community__C != null)
            strCommunity = u.Primary_Community__C;
   return strCommunity;
}


@AuraEnabled        
    //Get Record Type ID
    public static Id getLeadRecordTypeID() {
        Id LeadRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Living').getRecordTypeId();
        return LeadRTID;
    } 
    
@AuraEnabled        
    //Get Record Type ID
    public static Id getSNLeadRecordTypeID() {
        Id LeadRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Skilled Nursing').getRecordTypeId();
        return LeadRTID;
    } 

}