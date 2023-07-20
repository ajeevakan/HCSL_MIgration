Public class TaskTriggerAssignOppsToTasks {
    public static void handleActivityTrigger(){
    System.Debug('IN TaskTriggerAssignOppsToTasks: START ' + 'BEFORE ' + trigger.isBefore + 'UPDATE ' + trigger.isUpdate);
        if (trigger.isBefore){
            String contact_prefix = Schema.SObjectType.Contact.getKeyPrefix();
            list<Id> lstContId = new list<Id>();
            list<Task> lstTask = new list<Task>();
            for (Task objTask : (list<Task>)trigger.new){
            
                // Logged Email Type and Result Processing
                if (objTask.Subject != null)
                   if (objTask.Subject.startsWithIgnoreCase('EMAIL:')) {
                      if (objTask.Activity_Type__c == null)
                         objTask.Activity_Type__c = 'Email';
                      if (objTask.Result_Code__c == null)
                         objTask.Result_Code__c  = 'Completed';
                   }
            
                if (string.isBlank(objTask.WhatId)) 
                    if (string.isNotBlank(objTask.WhoId)) 
                    if (string.valueOf(objTask.WhoId).startsWith(contact_prefix)){
                        if (trigger.isInsert){
                            lstContId.add(objTask.WhoId);
                            lstTask.add(objTask);
                        }
                        else if (trigger.isUpdate) if (string.isBlank(objTask.WhoId) || (!(objTask.WhoId==((Task)trigger.oldMap.get(objTask.Id)).WhoId))){
                            lstContId.add(objTask.WhoId);
                            lstTask.add(objTask);
                      }
                  }
            }
            if (!lstTask.isEmpty()){
                map<Id,Id> mapContOpp = new map<Id,Id>();
                for (OpportunityContactRole ocr: [Select Id, OpportunityId, ContactId, Opportunity.Community__c, Contact.AccountId from OpportunityContactRole where OpportunityId != null AND ContactId in : lstContId order by Opportunity.Opportunity_Inquiry_Date__c DESC]) 
                    if (!mapContOpp.containsKey(ocr.ContactId)) 
                      mapContOpp.put(ocr.ContactId,ocr.OpportunityId);
                System.Debug('IN TaskTriggerAssignOppsToTasks: PROCESSING: ' + mapContOpp + ' : ' + lstTask);
                if (!mapContOpp.isEmpty())
                    for (Task objTask : lstTask) 
                      if (mapContOpp.containsKey(objTask.WhoId)) 
                        objTask.WhatId = mapContOpp.get(objTask.WhoId);
            }
        }
    }
}