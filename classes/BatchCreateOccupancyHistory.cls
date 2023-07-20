/*
Creates Occupancy History
Runs every day of month , updating trend record for ‘current month’.  
Inserts new record on first day of month (or later if record does not exist for current month yet )
*/
global class BatchCreateOccupancyHistory implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    global BatchCreateOccupancyHistory ()  {        
            
    }    
    global Iterable<sObject> start (Database.BatchableContext bc){
        system.debug('BatchCreateOccupancyHistory: Batch Start');

        String query = 'select Id, Name, Current_Resident_Occupancy_1__c, Current_Resident_Occupancy_2__c, Status__c, Current_Resident_Occupancy_1__r.Resident__c, Current_Resident_Occupancy_2__r.Resident__c, Current_Resident_Occupancy_1__r.Resident__r.Name, Current_Resident_Occupancy_1__r.Move_In_Date__c from Unit__c'; 
        return Database.query(query);
    }
    
    // The batch job executes and operates on one batch of records
    
    global void execute(Database.BatchableContext BC, List<Unit__c> scope) {
       system.debug('BatchCreateOccupancyHistory: Inside Execute');
       system.debug('Apartment scope ' + scope);
       List<Unit__c> lstUnits = new List<Unit__c>();
       Map<Id, Occupancy_History__c> mapUnittoOccHistory = new Map<Id, Occupancy_History__c>();
       
       if (scope!=null)
           if (!scope.isEmpty())
              for(Unit__c objUnit: scope)  
                    lstUnits.add(objUnit);
      
           
       for (Occupancy_History__c oh : [select Id, Name, Apartment__c, Primary_Resident__c, Second_Resident__c, Status__c, Snapshot_Date__c,
          Apartment__r.Name, Primary_Resident__r.Name, Second_Resident__r.Name 
          from Occupancy_History__c where Snapshot_Date__c = THIS_MONTH])
          if (oh.Apartment__c != null)
             mapUnittoOccHistory.put(oh.Apartment__c, oh);
       
       if (scope!=null)
           if (!scope.isEmpty())
              for(Unit__c objUnit: scope)  {
                    Occupancy_History__c oh;
                    if (mapUnittoOccHistory.containsKey(objUnit.Id))
                       oh = mapUnittoOccHistory.get(objUnit.Id);
                    else
                       oh = new Occupancy_History__c (Apartment__c = objUnit.Id);
                    oh.Name = objUnit.Name + ' - ' + Date.Today();
                    oh.Snapshot_Date__c = Date.Today();
                    
                    oh.Status__c = objUnit.Status__c;
                    if (objUnit.Current_Resident_Occupancy_1__c != null) {
                       oh.Move_In_Date__c = objUnit.Current_Resident_Occupancy_1__r.Move_In_Date__c;
                       if (objUnit.Current_Resident_Occupancy_1__r.Resident__c != null)
                          oh.Primary_Resident__c = objUnit.Current_Resident_Occupancy_1__r.Resident__c;
                    }
                    if (objUnit.Current_Resident_Occupancy_2__c != null)
                       if (objUnit.Current_Resident_Occupancy_2__r.Resident__c != null)
                          oh.Second_Resident__c = objUnit.Current_Resident_Occupancy_2__r.Resident__c;  
                    mapUnittoOccHistory.put(objUnit.Id, oh);                        
              }
              
              List< Occupancy_History__c > ohToUpsert = new List<Occupancy_History__c >();
              for (Id key: mapUnittoOccHistory.keySet()){
                 Occupancy_History__c oh = mapUnittoOccHistory.get(key);
                 ohToUpsert.add(oh);
              }
              
              if (ohToUpsert != null)
                 if (ohToUpsert.size() > 0)
                    upsert ohToUpsert;
        
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
     public void execute(SchedulableContext SC){
        BatchCreateOccupancyHistory oBatchCreateOccupancyHistory   = new BatchCreateOccupancyHistory (); 
        Database.executeBatch(oBatchCreateOccupancyHistory   , 100);
    }
}