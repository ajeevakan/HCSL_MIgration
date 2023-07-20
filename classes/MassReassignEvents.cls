public with sharing class MassReassignEvents implements Database.Batchable<sObject>{
    public String assignedTo;
    public String reassignTo;
    public String community;
    public String leadScore;
    public String dateFrom;
    public String dateTo;
    public Boolean includeConsumer;
    public Boolean includeOutreach;

    public MassReassignEvents(String assignedTo, String reassignTo, String community, String leadScore, String dateFrom, String dateTo, Boolean includeConsumer, Boolean includeOutreach) {
        this.assignedTo = assignedTo;
        this.reassignTo = reassignTo;
        this.community = community;
        this.leadScore = leadScore;
        this.dateFrom = dateFrom;
        this.dateTo = dateTo;
        this.includeConsumer = includeConsumer;
        this.includeOutreach = includeOutreach;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, WhatId, OwnerId, Account.RecordTypeId FROM Event WHERE Is_Pending__c = True AND OwnerId = :assignedTo';
        Date dateFromObj;
        Date dateToObj;
        if (!string.isBlank(dateFrom) && !string.isBlank(dateTo)) {
            dateFromObj = Date.valueOf(dateFrom);
            dateToObj = Date.valueOf(dateTo);
            query += ' AND ActivityDate >= :dateFromObj AND ActivityDate <= :dateToObj';
        }
        
        return Database.getQueryLocator(query+' ALL ROWS');
     }
  
     public void execute(Database.BatchableContext BC, List<Event> EventList){
        List<Event> EventsToReassign = new List<Event>();
        Map<Id, List<Event>> oppIdToEventsMap = new Map<Id, List<Event>>();

        Id BusinessAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        for(Event event: EventList){
            if (includeConsumer){
                if (event.WhatId.getSObjectType().getDescribe().getName().equals('Opportunity')){
                    if (!oppIdToEventsMap.containsKey(event.WhatId)){
                        List<Event> el = new List<Event>();
                        el.add(event);
                        oppIdToEventsMap.put(event.WhatId, el);
                    } else {
                        oppIdToEventsMap.get(event.WhatId).add(event);
                    }
                }
            }
            if (includeOutreach)
                if (event.Account.RecordTypeId == BusinessAccountTypeId){
                    event.ownerId = reassignTo;
                    eventsToReassign.add(event);
                }
        }

        for(Opportunity opp: [SELECT Id, Community__c, Lead_Score__c FROM Opportunity WHERE Id IN :oppIdToEventsMap.keySet()])
            if ((leadScore.equalsIgnoreCase('All')) || (opp.Lead_Score__c != null && opp.Lead_Score__c.equalsIgnoreCase(leadScore)))
                if ((community.equalsIgnoreCase('All Communities')) || (opp.Community__c != null && opp.Community__c == community))
                    for (Event e: oppIdToEventsMap.get(opp.Id)){
                        e.ownerId = reassignTo;
                        eventsToReassign.add(e);
                    }              
        

        if (eventsToReassign.size() > 0){
            update eventsToReassign;
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}