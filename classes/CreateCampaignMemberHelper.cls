public without sharing class CreateCampaignMemberHelper {
    
    public static Boolean ranCreateCampaignMemberTrigger = false;
    
    public void ActivityTrigger(){
        if (CreateCampaignMemberHelper.ranCreateCampaignMemberTrigger) return;
        CreateCampaignMemberHelper.ranCreateCampaignMemberTrigger = true;
        string strContactPrefix = Schema.SObjectType.Contact.getKeyPrefix();
        list<SObject> lstActivity = new list<SObject>();
        set<Id> setCampaignId = new set<Id>();
        set<Id> setContactId = new set<Id>();
        for (SObject objActivity : trigger.New)
            if (!(objActivity.get('Lead_Source_Campaign__c')==Null))
                if (!(objActivity.get('WhoId')==Null))
                    if (string.valueOf(objActivity.get('WhoId')).startsWith(strContactPrefix)){
                        if (trigger.isInsert){
                            lstActivity.add(objActivity);
                            setContactId.add(Id.valueOf(string.valueOf(objActivity.get('WhoId'))));
                            setCampaignId.add(Id.valueOf(string.valueOf(objActivity.get('Lead_Source_Campaign__c'))));
                        }
                        else if (trigger.isUpdate){
                            SObject objOldActivity = trigger.oldMap.get(Id.valueOf(string.valueOf(objActivity.get('Id'))));
                            if ((objOldActivity.get('Lead_Source_Campaign__c')==Null)){
                                lstActivity.add(objActivity);
                                setContactId.add(Id.valueOf(string.valueOf(objActivity.get('WhoId'))));
                                setCampaignId.add(Id.valueOf(string.valueOf(objActivity.get('Lead_Source_Campaign__c'))));
                            }
                        }
                    }
        if (!lstActivity.isEmpty()){
            map<string,CampaignMember> mapKeyCmpgnMbr = new map<string,CampaignMember>();
            for (CampaignMember cm : [SELECT Id, CampaignId, ContactId, Status, HealthCloudGA__Account__c, Responded_Date__c FROM CampaignMember WHERE CampaignId IN :setCampaignId AND ContactId IN :setContactId AND ContactId != Null AND CampaignId != Null]){
                string strKey = Id.valueOf(string.valueOf(cm.CampaignId))+':'+Id.valueOf(string.valueOf(cm.ContactId));
                mapKeyCmpgnMbr.put(strKey, cm);
            }            
            set<string> setDups = new set<string>();
            list<CampaignMember> lstCampaignMember = new list<CampaignMember>();
            for (SObject objActivity : lstActivity){
                string strKey = Id.valueOf(string.valueOf(objActivity.get('Lead_Source_Campaign__c')))+':'+Id.valueOf(string.valueOf(objActivity.get('WhoId')));
                if (mapKeyCmpgnMbr.containsKey(strKey)){
                    CampaignMember cm = mapKeyCmpgnMbr.get(strKey);
                    if (!(('Responded').equalsIgnoreCase(cm.Status))){
                        cm.Status = 'Responded';
                        if (string.isBlank(cm.HealthCloudGA__Account__c))
                            cm.HealthCloudGA__Account__c = string.valueOf(objActivity.get('AccountId'));
                        if ((cm.Responded_Date__c==Null))   
                            cm.Responded_Date__c =(Date)objActivity.get('ActivityDate');
                        lstCampaignMember.add(cm);  
                    }
                }
                else{
                    if (!setDups.contains(strKey)) {
                       setDups.add(strKey);
                       
                       CampaignMember cm = new CampaignMember();
                       cm.Status = 'Responded';
                       cm.HealthCloudGA__Account__c = string.valueOf(objActivity.get('AccountId'));
                       cm.Responded_Date__c = (Date)objActivity.get('ActivityDate');
                       cm.CampaignId = string.valueOf(objActivity.get('Lead_Source_Campaign__c'));
                       cm.ContactId = string.valueOf(objActivity.get('WhoId'));
                       lstCampaignMember.add(cm);
                    }
                }
            }
            if (!lstCampaignMember.isEmpty())
                upsert lstCampaignMember;
        }
        CreateCampaignMemberHelper.ranCreateCampaignMemberTrigger = false;
    }

}