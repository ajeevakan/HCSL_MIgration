public with sharing class MassReassignActivitiesController {
    @auraEnabled
    public static List<userWrapper> userList {get; set;} 
    @auraEnabled
    public static List<communityWrapper> communityList {get; set;}

    @AuraEnabled
    public static List<userWrapper> getUsers(){
        try {
            if (userList == null || userList.isEmpty())
            {
                userList = new List<userWrapper>();
                for (User u: [SELECT Id, Name FROM User ORDER BY Name]){
                    userWrapper uw = new userWrapper();
                    uw.userId = u.Id;
                    uw.userName = u.Name;
                    userList.add(uw);
                }
            }
            return userList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<communityWrapper> getCommunities(){
        try {
            if (communityList == null || communityList.isEmpty())
            {
                communityList = new List<communityWrapper>();
                for (Community__c c: [SELECT Id, Name FROM Community__c WHERE Name != 'ALL' ORDER BY Name]){
                    communityWrapper cw = new communityWrapper();
                    cw.communityId = c.Id;
                    cw.communityName = c.Name;
                    communityList.add(cw);
                }
            }
            return communityList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getCommunityNames(){
        try{
            List<String> commPickList = new List<String>();
            Schema.DescribeFieldResult fieldResult = Opportunity.Community__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                commPicklist.add(pickListVal.getLabel());
            }   
            return commPickList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String reassignActivities(String assignedTo, String reassignTo, String community, String leadScore, String dateFrom, String dateTo, Boolean includeConsumer, Boolean includeOutreach){
        try {
            Database.executeBatch(new MassReassignTasks(assignedTo, reassignTo, community, leadScore, dateFrom, dateTo, includeConsumer, includeOutreach), 200);
            Database.executeBatch(new MassReassignEvents(assignedTo, reassignTo, community, leadScore, dateFrom, dateTo, includeConsumer, includeOutreach), 200);
            return 'Success';
        } catch (Exception e) {
            System.debug(e);
            return 'Error';
        }
    }
    
    private class userWrapper {
        @AuraEnabled
        public string userId {get; set;}
        @AuraEnabled
        public string userName {get; set;}
    }

    private class communityWrapper {
        @AuraEnabled
        public string communityId {get; set;}
        @AuraEnabled
        public string communityName {get; set;}
    }
}