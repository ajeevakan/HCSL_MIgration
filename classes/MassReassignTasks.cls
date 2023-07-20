public with sharing class MassReassignTasks implements Database.Batchable<sObject> {
    public String assignedTo;
    public String reassignTo;
    public String community;
    public String leadScore;
    public String dateFrom;
    public String dateTo;
    public Boolean includeConsumer;
    public Boolean includeOutreach;

    public MassReassignTasks(String assignedTo, String reassignTo, String community, String leadScore, String dateFrom, String dateTo, Boolean includeConsumer, Boolean includeOutreach) {
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
        String query = 'SELECT Id, WhatId, OwnerId, Account.RecordTypeId FROM Task WHERE Is_Pending__c = True AND OwnerId = :assignedTo';
        Date dateFromObj;
        Date dateToObj;
        if (!string.isBlank(dateFrom) && !string.isBlank(dateTo)) {
            dateFromObj = Date.valueOf(dateFrom);
            dateToObj = Date.valueOf(dateTo);
            query += ' AND ActivityDate >= :dateFromObj AND ActivityDate <= :dateToObj';
        }
        
        return Database.getQueryLocator(query+' ALL ROWS');
     }
  
     public void execute(Database.BatchableContext BC, List<Task> TaskList){
        List<task> tasksToReassign = new List<task>();
        Map<Id, List<task>> oppIdToTasksMap = new Map<Id, List<task>>();

        Id BusinessAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        for(Task task: TaskList){
            if (includeConsumer){
                if (task.WhatId.getSObjectType().getDescribe().getName().equals('Opportunity')){
                    if (!oppIdToTasksMap.containsKey(task.WhatId)){
                        List<Task> tl = new List<Task>();
                        tl.add(task);
                        oppIdToTasksMap.put(task.WhatId, tl);
                    } else {
                        oppIdToTasksMap.get(task.WhatId).add(task);
                    }
                }
            }
            if (includeOutreach)
                if (task.Account.RecordTypeId == BusinessAccountTypeId){
                    task.ownerId = reassignTo;
                    tasksToReassign.add(task);
                }
        }

        for(Opportunity opp: [SELECT Id, Community__c, Lead_Score__c FROM Opportunity WHERE Id IN :oppIdToTasksMap.keySet()])
            if ((leadScore.equalsIgnoreCase('All')) || (opp.Lead_Score__c != null && opp.Lead_Score__c.equalsIgnoreCase(leadScore)))
                if ((community.equalsIgnoreCase('All Communities')) || (opp.Community__c != null && opp.Community__c == community))
                    for (Task t: oppIdToTasksMap.get(opp.Id)){
                        t.ownerId = reassignTo;
                        tasksToReassign.add(t);
                    }            
        

        if (tasksToReassign.size() > 0){
            update tasksToReassign;
        }
    }
  
     public void finish(Database.BatchableContext BC){
     }
}