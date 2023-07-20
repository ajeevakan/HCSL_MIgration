//This is the controller class for Create Senior Living Global action

public class newSeniorLivingLeadController {
@AuraEnabled
public static List<String> getRecType() {
     
   string strCommunity = '';
   string recTypeName = '';
   List<String> strValues = new List<String>();
   List<User> lstUser = [SELECT Id, Primary_Community__c FROM User WHERE Id = :UserInfo.getUserId()];
   system.debug('UserInfo.getUserId() ' + UserInfo.getUserId());
   if (lstUser  != null)
      for (User u: lstUser)
         if (u.Primary_Community__c != null)
         {
            strCommunity = u.Primary_Community__c;
            system.debug('strCommunity ' + u.Primary_Community__c);
         }
    strValues.add(strCommunity);
    
    //String strRecTypeName;
    List<RecordType> lstId = [SELECT Id FROM RecordType where DeveloperName = 'Senior_Living' AND SObjectType = 'Lead'];
    
    if (lstId  != null)
      for (RecordType i: lstId)
         if (i.Id != null)
            recTypeName = String.valueOf(i.Id);
    strValues.add(recTypeName);
    
    system.debug('strRecTypeName ' + recTypeName);
    system.debug('strCommunity ' + strCommunity);
    system.debug('strValues ' + strValues);
   return strValues;
}
}