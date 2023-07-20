public class OppDupContactListController {
    
    //returns information to be shown in duplicate tab on opportunity page.
    //duplicate tab would show a list of the contacts currently assigned to the opportunity via opportunity contact roles 
    //and under each a list of potential duplicate contacts with a corresponding button, Merge Contact which would launch the 
    //a merge contacts action placing the current contact as contact to keep and the selected duo as the contact to merge. 
    // Then it would list any households of duplicate contacts that were different from the house hold of the current contact 
    // with a Merge Household button that would launch the Merge households action with the Primary a household of the current 
    // opportunity as household to keep (it already does this) and the selected duo household as the household to merge. 
    //  Then it would list opportunities associated with the duplicate contacts with a Merge Opporunity button that would 
    //  launch the merge opportunities action with current opp as opp to keep (it already does this) and selected dup opportunity as opp to merge. 
    @AuraEnabled
    public static DupInfo getDupInfo(Id recordId){
        DupInfo objDupInfo = null;
        if (string.isNotBlank(recordId)){
            for (Opportunity objOpp : [SELECT Id, Name, Primary_Household__c FROM Opportunity WHERE Id = :recordId]){
                list<OpportunityContactRole> lstOCR = new list<OpportunityContactRole>();
                set<Id> setContId = new set<Id>();
                set<Id> setdupContId = new set<Id>();
                set<Id> setContIdPAcc = new set<Id>();
                set<Id> setdupContIdPAcc = new set<Id>();
                set<Id> setHHId = new set<Id>();
                //getting all contacts linked to opportunity via OpportunityContactRole
                for (OpportunityContactRole tocr : [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :recordId AND ContactId != null]){
                    lstOCR.add(tocr);
                    setContId.add(tocr.ContactId);
                }
                if (!lstOCR.isEmpty()){
                    list<Id> lstContId = new list<Id>(setContId);
                    //map to store duplicate contact ids for each contact id linked to opportunity.
                    map<Id,set<Id>> mapContIdToDupId = new map<Id,set<Id>>();
                    map<Id,set<Id>> mapContIdToDupIdPAcc = new map<Id,set<Id>>();
                    // Get all duplicate Contacts
                    Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicatesByIds.findDuplicatesByIds(lstContId);
                    if (results!=null) if (!results.isEmpty())
                        for (integer i = 0;i<results.size();i++){
                            Datacloud.FindDuplicatesResult findDupeResult = results.get(i);
                            Id contId = lstContId.get(i);
                            if (findDupeResult.isSuccess())
                                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults())
                                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults())
                                for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()){
                                    system.debug(matchRecord.getRecord().getSObjectType());
                                    if (Schema.Contact.getSObjectType() == matchRecord.getRecord().getSObjectType()){
                                        setContId.add(matchRecord.getRecord().Id);
                                        setdupContId.add(matchRecord.getRecord().Id);
                                        //storing all duplicate contacts info in the map variable mapContIdToDupId
                                        if (matchRecord.getRecord().Id!=contId){
                                            if (mapContIdToDupId.containsKey(contId)) mapContIdToDupId.get(contId).add(matchRecord.getRecord().Id);
                                            else mapContIdToDupId.put(contId,new set<Id>{matchRecord.getRecord().Id});
                                        }
                                    }
                                    else if (Schema.Account.getSObjectType() == matchRecord.getRecord().getSObjectType()) if (((Account)matchRecord.getRecord()).isPersonAccount){
                                        setContIdPAcc.add(matchRecord.getRecord().Id);
                                        setdupContIdPAcc.add(matchRecord.getRecord().Id);
                                        //storing all duplicate contacts info in the map variable mapContIdToDupId
                                        if (mapContIdToDupIdPAcc.containsKey(contId)) mapContIdToDupIdPAcc.get(contId).add(matchRecord.getRecord().Id);
                                        else mapContIdToDupIdPAcc.put(contId,new set<Id>{matchRecord.getRecord().Id});
                                    }
                                }
                        }
                    if (!setContIdPAcc.isEmpty()){
                        map<Id,Id> mapPAcc = new map<Id,Id>();
                        for (Account tmpacc : [select id, PersonContactId from account where PersonContactId!=null and Id IN:setContIdPAcc]){
                            mapPAcc.put(tmpacc.id,tmpacc.PersonContactId);
                            setContId.add(tmpacc.PersonContactId);
                            setdupContId.add(tmpacc.PersonContactId);
                        }
                        if (!mapContIdToDupIdPAcc.isEmpty()) for (Id tContId1 : mapContIdToDupIdPAcc.keySet()){
                            for (Id tAccId2 : mapContIdToDupIdPAcc.get(tContId1)) if (mapPAcc.containsKey(tAccId2)){
                                if (mapPAcc.get(tAccId2)!=tContId1){
                                    if (mapContIdToDupId.containsKey(tContId1)) mapContIdToDupId.get(tContId1).add(mapPAcc.get(tAccId2));
                                    else mapContIdToDupId.put(tContId1,new set<Id>{mapPAcc.get(tAccId2)});
                                }
                            }
                        }
                    }
                    if (!setdupContId.isEmpty()){
                        objDupInfo = new DupInfo();
                        objDupInfo.OpportunityId = objOpp.Id;
                        objDupInfo.objOpportunity = objOpp;
                        objDupInfo.lstDupOpportunities = new list<Opportunity>();
                        objDupInfo.lstContactsInfo = new list<ContactWrapper>();
                        objDupInfo.lstHouseholdsInfo = new list<HouseholdWrapper>();
                        //get all opportunities linked to duplicate contacts.
                        for (Opportunity objdupOpp : [SELECT Id, Name, Primary_Household__c FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityContactRole WHERE ContactId IN :setdupContId AND OpportunityId != :objOpp.Id)]){
                            objDupInfo.lstDupOpportunities.add(objdupOpp);
                        }
                        map<Id,Contact> mapCont = new map<Id,Contact>();
                        for (Contact c: [select Id, Name, Phone, Email from Contact where Id in :setContId])
                            mapCont.put(c.Id,c);
                        if (mapContIdToDupId!=null) if (!mapContIdToDupId.isEmpty()){
                            for (Id conId : mapContIdToDupId.KeySet()) if (mapCont.containsKey(conId)){
                                ContactWrapper conwrap = new ContactWrapper();
                                conwrap.ContactId=conId;
                                conwrap.objContact=mapCont.get(conId);
                                conwrap.lstDupContacts=new list<Contact>();
                                for (Id conDupId : mapContIdToDupId.get(conId))  if (mapCont.containsKey(conDupId))
                                    conwrap.lstDupContacts.add(mapCont.get(conDupId));
                                objDupInfo.lstContactsInfo.add(conwrap);
                            }
                        }    
                        //map to store househod id for each contact id
                        map<Id,set<Id>> mapContIdToHHId = new map<Id,set<Id>>();
                        for (AccountContactRelation acr: [SELECT Id, AccountId, ContactId FROM AccountContactRelation where 
                            Account.RecordType.DeveloperName = 'IndustriesHousehold' and ContactId IN :setContId]){
                            setHHId.add(acr.AccountId);
                            if (mapContIdToHHId.containsKey(acr.ContactId)) mapContIdToHHId.get(acr.ContactId).add(acr.AccountId);
                            else mapContIdToHHId.put(acr.ContactId,new set<Id>{acr.AccountId});
                        }
                        //map to store duplicate houshold ids for each houlsehold id linked to opportunity.
                        map<Id,set<Id>> mapHHIdToDupId = new map<Id,set<Id>>();
                        for (Id contId1 : mapContIdToDupId.keySet()) if (mapContIdToHHId.containsKey(contId1))
                            for (Id contId2 : mapContIdToDupId.get(contId1)) if (mapContIdToHHId.containsKey(contId2)){
                                Id HHId1 = (new list<Id>(mapContIdToHHId.get(contId1))).get(0);
                                boolean HHMatch=false;
                                for (Id HHId2 : mapContIdToHHId.get(contId2)) if (mapContIdToHHId.get(contId1).contains(HHId2)) HHMatch=true;
                                if (!HHMatch) for (Id HHId2 : mapContIdToHHId.get(contId2)){
                                    if (mapHHIdToDupId.containsKey(HHId1)) mapHHIdToDupId.get(HHId1).add(HHId2);
                                    else mapHHIdToDupId.put(HHId1,new set<Id>{HHId2});
                                }
                            }
                        if (mapHHIdToDupId!=null) if (!mapHHIdToDupId.isEmpty()){
                            map<Id,Account> mapHH = new map<Id,Account>();
                            for (Account c: [select Id, Name from Account where Id in :setHHId])
                                mapHH.put(c.Id,c);
                            for (Id HHId : mapHHIdToDupId.KeySet()) if (mapHH.containsKey(HHId)){
                                HouseholdWrapper hhwrap = new HouseholdWrapper();
                                hhwrap.HouseholdId=HHId;
                                hhwrap.objHousehold=mapHH.get(HHId);
                                hhwrap.lstDupHouseholds=new list<Account>();
                                for (Id HHDupId : mapHHIdToDupId.get(HHId))  if (mapHH.containsKey(HHDupId))
                                    hhwrap.lstDupHouseholds.add(mapHH.get(HHDupId));
                                objDupInfo.lstHouseholdsInfo.add(hhwrap);
                            }
                        }
                        
                    }
                }
            }
        }
        return objDupInfo;
    }
    
    public class DupInfo{
        @AuraEnabled public Id OpportunityId;
        @AuraEnabled public Opportunity objOpportunity;
        @AuraEnabled public List<Opportunity> lstDupOpportunities;
        @AuraEnabled public list<ContactWrapper> lstContactsInfo;
        @AuraEnabled public list<HouseholdWrapper> lstHouseholdsInfo;
    }
    
    public class ContactWrapper{
        @AuraEnabled public Id ContactId;
        @AuraEnabled public Contact objContact;
        @AuraEnabled public List<Contact> lstDupContacts;
    }
    
    public class HouseholdWrapper{
        @AuraEnabled public Id HouseholdId;
        @AuraEnabled public Account objHousehold;
        @AuraEnabled public List<Account> lstDupHouseholds;
    }

}