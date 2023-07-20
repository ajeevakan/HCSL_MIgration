trigger trigLeadRefOrg on Lead (before insert, before update){

// APFM payload LeadSource maps to Ref_Org_Code__c in custom metadata

     if (DisableTrigger.isDisabled('trigLeadRefOrg')) return;

    list<Lead> lstLead = new list<Lead>();
    list<string> lstRefOrgCode = new list<string>();
    list<string> lstCommunity = new list<string>();
    for (Lead objLead : trigger.new){
      if (trigger.isInsert){
        if (string.isNotBlank(objLead.Community__c))
          if (string.isNotBlank(objLead.Ref_Org_Code__c))
            if (string.isBlank(objLead.HealthCloudGA__ReferringOrganization__c)){
              lstLead.add(objLead);
              lstRefOrgCode.add(objLead.Ref_Org_Code__c);
              lstCommunity.add(objLead.Community__c);
            }
      }
      else if (trigger.isUpdate){
        Lead objOldLead = trigger.oldMap.get(objLead.Id);
        if (string.isNotBlank(objLead.Community__c))
          if (string.isNotBlank(objLead.Ref_Org_Code__c))
            if ((string.isBlank(objLead.HealthCloudGA__ReferringOrganization__c))||(!(objLead.Community__c==objOldLead.Community__c))||(!(objLead.Ref_Org_Code__c==objOldLead.Ref_Org_Code__c))){
              lstLead.add(objLead);
              lstRefOrgCode.add(objLead.Ref_Org_Code__c);
              lstCommunity.add(objLead.Community__c);
            }
      }
    }
    if (!lstCommunity.isEmpty()){
      Id ReferralRecordTypeId = Null;
        ReferralRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
        map<string,Id> mapRefOrg = new map<string,Id>();
        for (Account objAccount : [SELECT Id, Name, Community__c, Referral_Organization_Code__c FROM Account WHERE RecordTypeId = :ReferralRecordTypeId AND Community__c IN :lstCommunity AND Referral_Organization_Code__c IN :lstRefOrgCode])
          mapRefOrg.put(string.valueOf(objAccount.Community__c).toUpperCase()+':'+string.valueOf(objAccount.Referral_Organization_Code__c).toUpperCase(),objAccount.Id);
        list<Account> lstAccount = new list<Account>();
        list<Lead> lstLead1 = new list<Lead>();
        map<string,Account> mapRefOrgAct = new map<string,Account>();
        for (Lead objLead : lstLead){
          string strKey = string.valueOf(objLead.Community__c).toUpperCase()+':'+string.valueOf(objLead.Ref_Org_Code__c).toUpperCase();
          if (mapRefOrg.containsKey(strKey))
            objLead.HealthCloudGA__ReferringOrganization__c =mapRefOrg.get(strKey);
          else{
            lstLead1.add(objLead);
            Account objAccount = new Account(RecordTypeId=ReferralRecordTypeId, Community__c=objLead.Community__c, Name=objLead.Ref_Org_Code__c, Referral_Organization_Code__c=objLead.Ref_Org_Code__c);
            lstAccount.add(objAccount); 
            mapRefOrgAct.put(strKey,objAccount);
          }
        }
        if (!lstLead1.isEmpty()){
          insert lstAccount;
          for (Lead objLead : lstLead1){
            string strKey = string.valueOf(objLead.Community__c).toUpperCase()+':'+string.valueOf(objLead.Ref_Org_Code__c).toUpperCase();
            if (mapRefOrgAct.containsKey(strKey))
              objLead.HealthCloudGA__ReferringOrganization__c=mapRefOrgAct.get(strKey).Id;
          }
        }
    }
}