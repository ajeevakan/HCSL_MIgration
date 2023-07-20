public class OppCreateInquiryActivity {
    
    public static void OppTrigger(){
        ////if (DisableTrigger.isDisabled('OppCreateInquiryActivity')) return;
        if ((trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate)){
          Map<Id, Opportunity> mapAddInquiryTaskforOpp = new Map<Id, Opportunity>();
            List<Task> listTask = new List<Task>();
            List<Task> listTaskstoUpdate = new List<Task>();
            for (Opportunity o:(list<Opportunity>)Trigger.new)
            {
               if (Trigger.isInsert){
                    if (o.Opportunity_Inquiry_Date__c != null){
                         mapAddInquiryTaskforOpp.put(o.Id, o); 
                    }
                }
                else if (Trigger.isUpdate){
                    Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(o.Id);
                    if (o.Opportunity_Inquiry_Date__c != null) {
                        Boolean fireTriggerforReferralandInquiry = false;
                        if (o.Toggle_Create_System_Activities_Trigger__c != null)
                          if (o.Toggle_Create_System_Activities_Trigger__c != oldOpp.Toggle_Create_System_Activities_Trigger__c )
                             fireTriggerforReferralandInquiry = true;
                        if (o.Opportunity_Inquiry_Date__c != oldOpp.Opportunity_Inquiry_Date__c || o.LeadSource != oldOpp.LeadSource || 
                            o.HealthCloudGA__ReferringOrganization__c != oldOpp.HealthCloudGA__ReferringOrganization__c || o.HealthCloudGA__ReferringPractitioner__c != oldOpp.HealthCloudGA__ReferringPractitioner__c 
                           || o.Lead_Source_Campaign__c!= oldOpp.Lead_Source_Campaign__c || o.Internet_Lead_Source__c != oldOpp.Internet_Lead_Source__c)
                             fireTriggerforReferralandInquiry = true;
                        if (fireTriggerforReferralandInquiry){
                            mapAddInquiryTaskforOpp.put(o.Id, o);
                        }
                     }
                } 
            }
            if (!(mapAddInquiryTaskforOpp.isEmpty())){
                for (Task t : [SELECT WhoId, WhatId, AccountId, OwnerId, ActivityDate, Activity_Type__c, Re_Inquiry_Source__c, Lead_Source_Campaign__c, 
                 Referral_Organization__c, Referral_Contact__c, Internet_Lead_Source__c 
                 FROM Task where ((WhatId in:Trigger.new) AND (Activity_Type__c = 'Inquiry') AND System__c = true) ALL ROWS])
                {
                    if (mapAddInquiryTaskforOpp.containsKey(t.WhatId))
                    {
                        Opportunity o = mapAddInquiryTaskforOpp.get(t.WhatId);
                        // DR 01-05-2022 - we were using the standard Opp CampaignId, but because it can be changed by SF we are using our custom campaign Id
                        if (o.LeadSource != t.Re_Inquiry_Source__c  ||  o.Opportunity_Inquiry_Date__c != t.ActivityDate || o.OwnerId != t.OwnerId  || 
                            t.Lead_Source_Campaign__c != o.Lead_Source_Campaign__c || t.Referral_Contact__c != o.HealthCloudGA__ReferringPractitioner__c || 
                            t.Referral_Organization__c != o.HealthCloudGA__ReferringOrganization__c ||  t.Internet_Lead_Source__c != o.Internet_Lead_Source__c)
                        {
                            t.ActivityDate = o.Opportunity_Inquiry_Date__c;
                            t.OwnerId = o.OwnerId;
                            t.Lead_Source_Campaign__c = o.Lead_Source_Campaign__c;
                            t.Referral_Contact__c = o.HealthCloudGA__ReferringPractitioner__c ;
                            t.Referral_Organization__c = o.HealthCloudGA__ReferringOrganization__c;
                            if (o.LeadSource != null)
                                t.Re_Inquiry_Source__c = o.LeadSource;
                            t.System__c = true;
                            t.Internet_Lead_Source__c = o.Internet_Lead_Source__c;
                            listTaskstoUpdate.Add(t); 
                        }
                        mapAddInquiryTaskforOpp.remove(t.WhatId);
                    }
                    
                }
                
                if (!(mapAddInquiryTaskforOpp.isEmpty()))
                 for(Opportunity o : mapAddInquiryTaskforOpp.values())
                 {
                    Task t = new Task(Subject = 'Inquiry', System__c = true, Activity_Type__c = 'Inquiry', WhatId = o.Id, ActivityDate = o.Opportunity_Inquiry_Date__c, Activity_Complete_Date__c = o.Opportunity_Inquiry_Date__c, Status = 'Completed', Result_Code__c = 'Completed', OwnerId = o.OwnerId,
                                      Lead_Source_Campaign__c = o.Lead_Source_Campaign__c, Referral_Organization__c = o.HealthCloudGA__ReferringOrganization__c, 
                                      Re_Inquiry_Source__c = o.LeadSource, Referral_Contact__c = o.HealthCloudGA__ReferringPractitioner__c, Internet_Lead_Source__c = o.Internet_Lead_Source__c);  
                    listTask.Add(t);
                 }
            }
            if ( listTask != null)
              if (listTask.size() > 0)
                 insert listTask;
           if ( listTaskstoUpdate != null)
              if (listTaskstoUpdate.size() > 0)
                 update listTaskstoUpdate; 
        }
    }

}