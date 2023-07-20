public without sharing class AssignPrimaryCommunityUser {
    private boolean Disable_Account;
    private boolean Disable_Campaign;
    private boolean Disable_Lead;
    private boolean Disable_Lead_Profile;
    private boolean Disable_Opportunity;
    
    // loads Assign_Primary_Community_User__c custom setting's values in class variables.
    private void LoadCustomSetting(){
        Disable_Account=false;
        Disable_Campaign=false;
        Disable_Lead=false;
        Disable_Opportunity=false;
        Disable_Lead_Profile = false;
        try{
            Assign_Primary_Community_User__c SS = Assign_Primary_Community_User__c.getInstance();
           if (SS != Null){
                Disable_Account=SS.Disable_Account__c;
                //Disable_Apartment=SS.Disable_Apartment__c;
                Disable_Campaign=SS.Disable_Campaign__c;
                Disable_Lead=SS.Disable_Lead__c;
                Disable_Opportunity=SS.Disable_Opportunity__c;
                if (string.isNotBlank(SS.Disable_Lead_Profiles__c)){
                    Id UProfileId = UserInfo.getProfileId();
                    if (string.isNotBlank(UProfileId)){
                        string UProfileName = '';
                        for (Profile pf : [Select Name from Profile where Id = :UProfileId AND Name != null])
                            UProfileName = pf.Name;
                        if (string.isNotBlank(UProfileName))
                            for (string strskipPf : SS.Disable_Lead_Profiles__c.split(','))
                                if (string.isNotBlank(strskipPf))
                                    if (strskipPf.trim().equalsIgnoreCase(UProfileName)){
                                        Disable_Lead_Profile = true;
                                        break;
                                    }
                    }
                }
            }
        }
        catch(Exception exc){}
    }
    
// This opportunity trigger functions gets called on 'beforeInsert' and 'beforeUpdate'.
// It has following business logic:
// 1.) If Community__c picklist field is set or changed, it updates Reporting_Community__c lookup field.
// 2.) Following business logic can be disabled using Disable_Opportunity__c field in Assign_Primary_Community_User__c custom setting.
// 3.) If Primary_User_for_Community__c field is set in Community__c object, and if current owner of opportunity is a user, 
//     and if owner user does Not belong to a Role with name matching the community name. 
//     Then it updates the Owner of opportunity equal to Primary_User_for_Community__c 
// 4.) When updating Owner of opportunity, if Assign_Original_Owner_as_Floater__c checkbox is true, then it sets old original owner value in Assigned_Floater__c field.
    public void OpportunityTrigger(){
        set<string> setCommunityName = new set<string>();
        map<string,Community__c> mapCommunity = new map<string,Community__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (Opportunity opp:(list<Opportunity>)Trigger.new){
            if (string.isNotBlank(opp.Community__c)){
                if (string.isBlank(opp.Reporting_Community__c)){
                    setCommunityName.add(opp.Community__c);
                    lstOpportunity.add(opp);
                }
                else if (Trigger.isUpdate)
                    if ((!(opp.Community__c==((Opportunity)trigger.oldMap.get(opp.Id)).Community__c))||(!(opp.OwnerId==((Opportunity)trigger.oldMap.get(opp.Id)).OwnerId))){
                        setCommunityName.add(opp.Community__c);
                        lstOpportunity.add(opp);
                    }
            }
        }
        if (!(setCommunityName.isEmpty())){
            for (Community__c objComm : [SELECT Id, Name,Primary_User_for_Community__c FROM Community__c WHERE Name IN :setCommunityName])
                mapCommunity.put(objComm.Name, objComm);
            set<Id> setOwnerId = new set<Id>();
            string strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
            for (Opportunity opp:lstOpportunity){
                if (mapCommunity.containsKey(opp.Community__c)){
                    opp.Reporting_Community__c = mapCommunity.get(opp.Community__c).Id;
                    if (string.isNotBlank(opp.OwnerId))
                        if (string.valueOf(opp.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                          setOwnerId.add(opp.OwnerId);
                }
            }
            LoadCustomSetting();
            if (!Disable_Opportunity){
                map<Id,string> mapUserRoleName = new map<Id,string>();
                if (!setOwnerId.isEmpty()){
                    for (User oUser : [SELECT Id, UserRoleId, UserRole.Name FROM User WHERE Id IN :setOwnerId AND UserRoleId!=Null])
                        mapUserRoleName.put(oUser.Id,oUser.UserRole.Name);
                    for (Opportunity opp:lstOpportunity){
                    if (mapCommunity.containsKey(opp.Community__c))
                            if (setOwnerId.contains(opp.OwnerId)){
                                boolean matchRoleCommunity = false;
                                if (mapUserRoleName.containsKey(opp.OwnerId))
                                    if (mapUserRoleName.get(opp.OwnerId).equalsIgnoreCase(mapCommunity.get(opp.Community__c).Name))
                                      matchRoleCommunity = true;
                                if (!matchRoleCommunity){
                                    if (string.isNotBlank(mapCommunity.get(opp.Community__c).Primary_User_for_Community__c))
                                      if (mapCommunity.get(opp.Community__c).Primary_User_for_Community__c!=opp.OwnerId){
                                        if (opp.Assign_Original_Owner_as_Floater__c)
                                            opp.Assigned_Floater__c=opp.OwnerId;
                                          opp.OwnerId=mapCommunity.get(opp.Community__c).Primary_User_for_Community__c;
                                    }
                                }
                            }
                    }
                }
            }
        }
        for (Opportunity opp:(list<Opportunity>)Trigger.new)
          if (opp.Assign_Original_Owner_as_Floater__c)
            opp.Assign_Original_Owner_as_Floater__c=false;
    }

// This Account trigger functions gets called on 'beforeInsert' and 'beforeUpdate'.
// It has following business logic:
// 1.) If Community__c picklist field is set or changed, it updates Reporting_Community__c lookup field.
// 2.) Following business logic can be disabled using Disable_Account__c field in Assign_Primary_Community_User__c custom setting.
// 3.) If Primary_User_for_Community__c field is set in Community__c object, and if current owner of Account is a user, 
//     and if owner user does Not belong to a Role with name matching the community name. 
//     Then it updates the Owner of Account equal to Primary_User_for_Community__c 
// 4.) When updating Owner of Account, if Assign_Original_Owner_as_Floater__c checkbox is true, then it sets old original owner value in Assigned_Floater__c field.    
    public void AccountTrigger(){
        set<string> setCommunityName = new set<string>();
        map<string,Community__c> mapCommunity = new map<string,Community__c>();
        list<Account> lstAcc = new list<Account>();
        for (Account act:(list<Account>)Trigger.new){
            if (string.isNotBlank(act.Community__c)){
                if (string.isBlank(act.Reporting_Community__c)){
                    setCommunityName.add(act.Community__c);
                    lstAcc.add(act);
                }
                else if (Trigger.isUpdate)
                    if ((!(act.Community__c==((Account)trigger.oldMap.get(act.Id)).Community__c))||(!(act.OwnerId==((Account)trigger.oldMap.get(act.Id)).OwnerId))){
                        setCommunityName.add(act.Community__c);
                        lstAcc.add(act);
                    }
            }
        }
        if (!(setCommunityName.isEmpty())){
            for (Community__c objComm : [SELECT Id, Name,Primary_User_for_Community__c FROM Community__c WHERE Name IN :setCommunityName])
                mapCommunity.put(objComm.Name, objComm);
            set<Id> setOwnerId = new set<Id>();
            string strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
            for (Account act:lstAcc){
                if (mapCommunity.containsKey(act.Community__c)){
                    act.Reporting_Community__c = mapCommunity.get(act.Community__c).Id;
                    if (string.isNotBlank(act.OwnerId))
                        if (string.valueOf(act.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                          setOwnerId.add(act.OwnerId);
                }
            }
            LoadCustomSetting();
            if (!Disable_Account){
                map<Id,string> mapUserRoleName = new map<Id,string>();
                if (!setOwnerId.isEmpty()){
                    for (User oUser : [SELECT Id, UserRoleId, UserRole.Name FROM User WHERE Id IN :setOwnerId AND UserRoleId!=Null])
                        mapUserRoleName.put(oUser.Id,oUser.UserRole.Name);
                    for (Account act:lstAcc){
                    if (mapCommunity.containsKey(act.Community__c))
                            if (setOwnerId.contains(act.OwnerId)){
                                boolean matchRoleCommunity = false;
                                if (mapUserRoleName.containsKey(act.OwnerId))
                                    if (mapUserRoleName.get(act.OwnerId).equalsIgnoreCase(mapCommunity.get(act.Community__c).Name))
                                      matchRoleCommunity = true;
                                if (!matchRoleCommunity){
                                    if (string.isNotBlank(mapCommunity.get(act.Community__c).Primary_User_for_Community__c))
                                      if (mapCommunity.get(act.Community__c).Primary_User_for_Community__c!=act.OwnerId){
                                          if (act.Assign_Original_Owner_as_Floater__c)
                                            act.Assigned_Floater__c=act.OwnerId;
                                          act.OwnerId=mapCommunity.get(act.Community__c).Primary_User_for_Community__c;
                                    }
                                }
                            }
                    }
                }
            }
        }
        for (Account act:(list<Account>)Trigger.new)
          if (act.Assign_Original_Owner_as_Floater__c)
            act.Assign_Original_Owner_as_Floater__c=false;
    }
    
// This Campaign trigger functions gets called on 'beforeInsert' and 'beforeUpdate'.
// It has following business logic:
// 1.) If Community__c picklist field is set or changed, it updates Reporting_Community__c lookup field.
// 2.) Following business logic can be disabled using Disable_Campaign__c field in Assign_Primary_Community_User__c custom setting.
// 3.) If Primary_User_for_Community__c field is set in Community__c object, and if current owner of Campaign is a user, 
//     and if owner user does Not belong to a Role with name matching the community name. 
//     Then it updates the Owner of Campaign equal to Primary_User_for_Community__c 
// 4.) When updating Owner of Campaign, if Assign_Original_Owner_as_Floater__c checkbox is true, then it sets old original owner value in Assigned_Floater__c field.    
    public void CampaignTrigger(){
        set<string> setCommunityName = new set<string>();
        map<string,Community__c> mapCommunity = new map<string,Community__c>();
        list<Campaign> lstCampaign = new list<Campaign>();
        for (Campaign objCampaign:(list<Campaign>)Trigger.new){
            if (string.isBlank(objCampaign.OwnerId)) 
                objCampaign.OwnerId = UserInfo.getUserId();
            if (string.isNotBlank(objCampaign.Community__c)){
                if (string.isBlank(objCampaign.Reporting_Community__c)||(Trigger.isInsert)){
                    setCommunityName.add(objCampaign.Community__c);
                    lstCampaign.add(objCampaign);
                }
                else if (Trigger.isUpdate)
                    if ((!(objCampaign.Community__c==((Campaign)trigger.oldMap.get(objCampaign.Id)).Community__c))||(!(objCampaign.OwnerId==((Campaign)trigger.oldMap.get(objCampaign.Id)).OwnerId))){
                        setCommunityName.add(objCampaign.Community__c);
                        lstCampaign.add(objCampaign);
                    }
            }
        }
        if (!(setCommunityName.isEmpty())){
            for (Community__c objComm : [SELECT Id, Name,Primary_User_for_Community__c FROM Community__c WHERE Name IN :setCommunityName])
                mapCommunity.put(objComm.Name, objComm);
            set<Id> setOwnerId = new set<Id>();
            string strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
            for (Campaign objCampaign:lstCampaign){
                if (mapCommunity.containsKey(objCampaign.Community__c)){
                    objCampaign.Reporting_Community__c = mapCommunity.get(objCampaign.Community__c).Id;
                    if (string.isNotBlank(objCampaign.OwnerId))
                        if (string.valueOf(objCampaign.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                          setOwnerId.add(objCampaign.OwnerId);
                }
            }
            LoadCustomSetting();
            if (!Disable_Campaign){
                map<Id,string> mapUserRoleName = new map<Id,string>();
                if (!setOwnerId.isEmpty()){
                    for (User oUser : [SELECT Id, UserRoleId, UserRole.Name FROM User WHERE Id IN :setOwnerId AND UserRoleId!=Null])
                        mapUserRoleName.put(oUser.Id,oUser.UserRole.Name);
                    for (Campaign objCampaign:lstCampaign){
                    if (mapCommunity.containsKey(objCampaign.Community__c))
                            if (setOwnerId.contains(objCampaign.OwnerId)){
                                boolean matchRoleCommunity = false;
                                if (mapUserRoleName.containsKey(objCampaign.OwnerId))
                                    if (mapUserRoleName.get(objCampaign.OwnerId).equalsIgnoreCase(mapCommunity.get(objCampaign.Community__c).Name))
                                      matchRoleCommunity = true;
                                if (!matchRoleCommunity){
                                    if (string.isNotBlank(mapCommunity.get(objCampaign.Community__c).Primary_User_for_Community__c))
                                      if (mapCommunity.get(objCampaign.Community__c).Primary_User_for_Community__c!=objCampaign.OwnerId){
                                        if (objCampaign.Assign_Original_Owner_as_Floater__c)
                                            objCampaign.Assigned_Floater__c=objCampaign.OwnerId;
                                          objCampaign.OwnerId=mapCommunity.get(objCampaign.Community__c).Primary_User_for_Community__c;
                                    }
                                }
                            }
                    }
                }
            }
        }
        for (Campaign objCampaign:(list<Campaign>)Trigger.new)
          if (objCampaign.Assign_Original_Owner_as_Floater__c)
            objCampaign.Assign_Original_Owner_as_Floater__c=false;
    }
    
// This Lead trigger functions gets called on 'beforeInsert' and 'beforeUpdate'.
// It has following business logic:
// 1.) If Community__c picklist field is set or changed, it updates Reporting_Community__c lookup field.
// 2.) Following business logic can be disabled using Disable_Lead__c field in Assign_Primary_Community_User__c custom setting.
// 3.) If Primary_User_for_Community__c field is set in Community__c object, and if current owner of Lead is a user, 
//     and if owner user does Not belong to a Role with name matching the community name. 
//     Then it updates the Owner of Lead equal to Primary_User_for_Community__c 
// 4.) When updating Owner of Lead, if Assign_Original_Owner_as_Floater__c checkbox is true, then it sets old original owner value in Assigned_Floater__c field.    
    public void LeadTrigger(){
        set<string> setCommunityName = new set<string>();
        map<string,Community__c> mapCommunity = new map<string,Community__c>();
        list<Lead> lstLead = new list<Lead>();
        for (Lead objLead:(list<Lead>)Trigger.new){
            if (string.isBlank(objLead.OwnerId)) 
                objLead.OwnerId = UserInfo.getUserId();
            if (string.isNotBlank(objLead.Community__c)){
                if (string.isBlank(objLead.Reporting_Community__c)||(Trigger.isInsert)){
                    setCommunityName.add(objLead.Community__c);
                    lstLead.add(objLead);
                }
                else if (Trigger.isUpdate)
                    if ((!(objLead.Community__c==((Lead)trigger.oldMap.get(objLead.Id)).Community__c))||(!(objLead.OwnerId==((Lead)trigger.oldMap.get(objLead.Id)).OwnerId))){
                        setCommunityName.add(objLead.Community__c);
                        lstLead.add(objLead);
                    }
            }
        }
        LoadCustomSetting();
        if (!(setCommunityName.isEmpty())){
            for (Community__c objComm : [SELECT Id, Name,Primary_User_for_Community__c FROM Community__c WHERE Name IN :setCommunityName])
                mapCommunity.put(objComm.Name, objComm);
            set<Id> setOwnerId = new set<Id>();
            string strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
            for (Lead objLead:lstLead){
                if (mapCommunity.containsKey(objLead.Community__c)){
                    objLead.Reporting_Community__c = mapCommunity.get(objLead.Community__c).Id;
                    if (string.isNotBlank(objLead.OwnerId))
                        if (string.valueOf(objLead.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                          setOwnerId.add(objLead.OwnerId);
                }
            }
            
            if (!Disable_Lead) if (!Disable_Lead_Profile){
                map<Id,string> mapUserRoleName = new map<Id,string>();
                if (!setOwnerId.isEmpty()){
                    for (User oUser : [SELECT Id, UserRoleId, UserRole.Name FROM User WHERE Id IN :setOwnerId AND UserRoleId!=Null])
                        mapUserRoleName.put(oUser.Id,oUser.UserRole.Name);
                    for (Lead objLead:lstLead){
                    if (mapCommunity.containsKey(objLead.Community__c))
                            if (setOwnerId.contains(objLead.OwnerId)){
                                boolean matchRoleCommunity = false;
                                if (mapUserRoleName.containsKey(objLead.OwnerId))
                                    if (mapUserRoleName.get(objLead.OwnerId).equalsIgnoreCase(mapCommunity.get(objLead.Community__c).Name))
                                      matchRoleCommunity = true;
                                if (!matchRoleCommunity){
                                    if (string.isNotBlank(mapCommunity.get(objLead.Community__c).Primary_User_for_Community__c))
                                      if (mapCommunity.get(objLead.Community__c).Primary_User_for_Community__c!=objLead.OwnerId){
                                        if (objLead.Assign_Original_Owner_as_Floater__c)
                                            objLead.Assigned_Floater__c=objLead.OwnerId;
                                          objLead.OwnerId=mapCommunity.get(objLead.Community__c).Primary_User_for_Community__c;
                                    }
                                }
                            }
                    }
                }
            }
        }
        
        for (Lead objLead:(list<Lead>)Trigger.new){
          if (objLead.Assign_Original_Owner_as_Floater__c)
            objLead.Assign_Original_Owner_as_Floater__c = false;
        //    if (Disable_Lead_Profile) objLead.Use_Queue_Assignment_Rule__c = true;
            
        }
    }
}