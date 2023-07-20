@isTest
private class BatchCreateOccupancyHistorytest {
    static testMethod void BatchCreateOccupancyHistorytest (){
        
        list<string> lstCommunityName = new list<string>();
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues())
            lstCommunityName.add(f.getValue());
        
        Community__c cm = new Community__c();
        cm.Name = lstCommunityName[0];
        insert cm;
        
        List<Unit__c> ulist = new List<Unit__c>();
        Unit__c u = new Unit__c(Name = '101A', Community_Id__c = cm.Id);
        ulist.add(u);
        Unit__c u2 = new Unit__c(Name = '101B', Community_Id__c = cm.Id);
        ulist.add(u2);
        insert ulist; 
        
        Occupancy_History__c oh = new Occupancy_History__c(Apartment__c = u.Id, Name = 'Test', Snapshot_Date__c = Date.today(), Status__c = 'Vacant');
        insert oh;
        
       
        BatchCreateOccupancyHistory batchobj = new BatchCreateOccupancyHistory();
        Database.executeBatch(batchobj);
    }
}