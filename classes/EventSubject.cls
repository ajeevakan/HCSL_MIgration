public class EventSubject {
    
    public static void handleActivityTrigger(){
        if (DisableTrigger.isDisabled('EventSubject')) return;
        if (Trigger.isBefore && Trigger.isInsert ){
                Set<Id> lstWhatIds = new Set<Id>();
                Set<Id> lstWhoIds = new Set<Id>();
                // Get the WhatIds if they exist
                for (Event objEvent : (list<Event >)Trigger.new)
                
                   if (objEvent.Subject  == null && objEvent.WhoId != null)
                      lstWhoIds.add(objEvent.WhoId );
                   else if (objEvent.Subject  == null && objEvent.WhatId != null)
                      lstWhatIds.add(objEvent.WhatId);
                      
                 
                // Get map of objects for whatids         
                Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity> ([select Id, Name from Opportunity where Id in : lstWhatIds ]);
                Map<Id, Account> mapAccts = new Map<Id, Account> ([select Id, Name from Account where Id in : lstWhatIds ]);
                Map<Id, Contact> mapCont = new Map<Id, Contact> ([select Id, FirstName, LastName from Contact where Id in : lstWhoIds]);
                
                // Update Subject with activity type and Opp or Account Name
                for (Event objEvent : (list<Event >)Trigger.new) {
                   if (objEvent.Subject == null) 
                      
                      // Set Subject to Activity Type
                      if (objEvent.Activity_Type__c == null)
                         objEvent.Subject = '';
                      else
                         objEvent.Subject = objEvent.Activity_Type__c;
                     
                     // Add Contact name or Opp name or Account name    
                     if (objEvent.WhoId != null) {
                        if (mapCont.containsKey(objEvent.WhoId)) {
                           String strSub = mapCont.get(objEvent.WhoId).LastName;
                           if (mapCont.get(objEvent.WhoId).FirstName != null)
                              strSub = mapCont.get(objEvent.WhoId).FirstName + ' ' + strSub;
                           objEvent.Subject = objEvent.Subject + ' - ' + strSub;
                        }
                      } else if (objEvent.WhatId != null) {
                         if (mapOpps.containsKey(objEvent.WhatId))
                            objEvent.Subject = objEvent.Subject + ' - ' + mapOpps.get(objEvent.WhatId).Name;
                         else if (mapAccts.containsKey(objEvent.WhatId))
                            objEvent.Subject = objEvent.Subject + ' - ' + mapAccts.get(objEvent.WhatId).Name;
                      }
                 }

                  
      }
    }
}