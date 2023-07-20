public class NOTUSEDnewLeadController {
@AuraEnabled
public static String getCommunity() {
   string strCommunity = '';
   List<User> lstUser = [SELECT Id, Primary_Community__C  FROM User WHERE Id = :UserInfo.getUserId()];
   if (lstUser  != null)
      for (User u: lstUser)
        if (u.Primary_Community__C != null)
            strCommunity = u.Primary_Community__C;
   system.debug('strCommunity ' + strCommunity);
   return strCommunity;
}


@AuraEnabled        
    //Get Record Type ID
    public static Id getLeadRecordTypeID() {
        //Id LeadRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Senior Living').getRecordTypeId();
        List<RecordType> lstRecID = new List<RecordType>();
        Id ldRcId;
        lstRecID = [SELECT Id FROM RecordType WHERE DeveloperName = 'Senior_Living' AND SObjectType = 'Lead' LIMIT 1];
        
        for(RecordType RcId: lstRecID)
        {
            ldRcId = RcId.Id;
            break;
        }
        system.debug('Senior_Living ' + ldRcId);
        return ldRcId;
    } 
    
@AuraEnabled        
    //Get Record Type ID 
    public static Id getSNLeadRecordTypeID() {
        //Id LeadRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Skilled Nursing').getRecordTypeId();
        List<RecordType> lstRecID = new List<RecordType>();
        Id ldRcId;
        lstRecID = [SELECT Id FROM RecordType WHERE DeveloperName = 'Skilled_Nursing' AND SObjectType = 'Lead' LIMIT 1];
        
        for(RecordType RcId: lstRecID)
        {
            ldRcId = RcId.Id;
            break;
        }
        system.debug('Skilled_Nursing ' + ldRcId);
        return ldRcId;
    } 

}