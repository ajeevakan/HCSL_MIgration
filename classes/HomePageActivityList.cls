public with sharing class HomePageActivityList {

@AuraEnabled
  public static ActivityListReturn getActivities(string strOption) {
   if ((string.isBlank(strOption))) strOption = '0'; //('0').equalsIgnoreCase(strOption)
   list<wrapActivityIncStart> wrapActivitylist;
   list<Task> tasklist;
   list<Event> eventlist;
   Id currentUserId = UserInfo.getUserId();
    //User_Preferences__c Activity_List_Filter__c User__c
    User_Preferences__c oUP = null;
    for (User_Preferences__c tUP : [SELECT Id, Activity_List_Filter__c, User__c FROM User_Preferences__c WHERE User__c = :currentUserId LIMIT 1])
        oUP = tUP;
      if (oUP==null){
          if (('0').equalsIgnoreCase(strOption)) strOption = '1';
          oUP = new User_Preferences__c(User__c=currentUserId, Activity_List_Filter__c=strOption);
      }
      else{
          if (('0').equalsIgnoreCase(strOption)){
              if (string.isNotBlank(oUP.Activity_List_Filter__c))
                strOption = oUP.Activity_List_Filter__c;
              else
                strOption = '1';
          }
          if (!strOption.equalsIgnoreCase(oUP.Activity_List_Filter__c))
              oUP.Activity_List_Filter__c=strOption;
      }
      upsert oUP;
   wrapActivitylist = new list<wrapActivityIncStart>();
   
   //Updated the below SOQL to include IsDeleted = FALSE
   tasklist=(list<Task>)database.query(getTaskSOQL(strOption));
//   tasklist= [select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c FROM Task WHERE  IsDeleted = FALSE AND
//   (ActivityDate <= TODAY) and OwnerId =:currentUserId  and Is_Pending__c = true  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
   eventlist=(list<Event>)database.query(getEventSOQL(strOption));
//   eventlist= [select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND
//   (ActivityDate <= TODAY) and OwnerId =:currentUserId and Is_Pending__c = true ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
  
   Integer counter = 0;
   if (tasklist != null)
      for (task t: tasklist) {
        if (counter < 1000) {
    
         wrapActivityIncStart wa = new wrapActivityIncStart();
         wa.ActivityObjectType='Task';
         wa.ActivityDate = t.ActivityDate;
         wa.Subject = t.Subject;
         wa.Description = t.Description;
         wa.OwnerName = t.Owner.Name;
         wa.ResultCode = t.Result_Code__C;
         wa.WhatName = t.What.Name;
         wa.WhoName = t.Who.Name;
         if (String.isBlank(wa.WhoName))
             wa.WhoName = t.What.Name;
         wa.ActivityId = t.Id;
         wa.HighPriority = ('High').equalsIgnoreCase(t.Priority);
         wrapActivitylist.add(wa);
       
         counter++;
         }
      }
      
   if (eventlist != null)
      for (event t: eventlist) {
         if (counter < 1000) {
         wrapActivityIncStart wa = new wrapActivityIncStart();
         wa.ActivityObjectType='Event';
         wa.ActivityDate = t.ActivityDate;
         wa.Subject = t.Subject;
         wa.Description = t.Description;
         wa.OwnerName = t.Owner.Name;
         wa.ResultCode = t.Result_Code__C;
         wa.WhatName = t.What.Name;
         wa.WhoName = t.Who.Name;
         if (String.isBlank(wa.WhoName))
             wa.WhoName = t.What.Name;
         wa.ActivityId = t.Id;
         wa.StartDateTime = t.StartDateTime;
         wa.StartDateTimeStr = t.StartDateTime.format('h:mm a');
         wa.HighPriority = false;
         wrapActivitylist.add(wa);
         counter++;
         }
      }

    if (wrapActivitylist != null) 
      wrapActivitylist.sort();  

    //return   wrapActivitylist;
      ActivityListReturn objret = new ActivityListReturn();
      objret.lstActivities = wrapActivitylist;
      objret.strOption = strOption;
      return objret;
    }
    
    public class ActivityListReturn{
        @AuraEnabled
        public List<wrapActivityIncStart> lstActivities;
        @AuraEnabled
        public string strOption;
    }
    
    public static string getEventSOQL(string strOption) {
        string strSOQL = '';
        string strOwnerId = UserInfo.getUserId();
        //switch on strOption
        //{
            if (strOption=='1'){ //My Activity Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+
                    'AND (ActivityDate = '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='2'){ //My Overdue Activity
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='3'){ //My Activity Next 7 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='4'){ //My Activity Next 30 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='5'){ //My Activity Due by Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+
                    'AND (ActivityDate <= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='6'){ //All Activity Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   '+
                    'AND (ActivityDate = '+getDateStr(date.today())+')  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='7'){ //All Overdue Activity
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730 and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='8'){ //All Activity Next 7 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='9'){ //All Activity Next 30 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   '+
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='10'){ //All Activity Due by Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   '+
                    'AND (ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730 and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
        //}
        return strSOQL;
    }
    
    public static string getTaskSOQL(string strOption) {
        string strSOQL = '';
        string strOwnerId = UserInfo.getUserId();
        //switch on strOption{
            if (strOption=='1'){ //My Activity Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND '+
                    '(ActivityDate = '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='2'){ //My Overdue Activity
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='3'){ //My Activity Next 7 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='4'){ //My Activity Next 30 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='5'){ //My Activity Due by Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND '+
                    '(ActivityDate <= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='6'){ //All Activity Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   AND '+
                    '(ActivityDate = '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='7'){ //All Overdue Activity
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730 and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='8'){ //All Activity Next 7 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='9'){ //All Activity Next 30 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   AND '+
                    '(ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='10'){ //All Activity Due by Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   AND '+
                    '(ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730 and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
        //}
        return strSOQL;
    }

    private static string getDateStr(date d){
    
        //return DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-dd');
        return String.valueOf(d.year()) +'-' + String.valueOf(d.month()).leftpad(2,'0') + '-' + String.valueOf(d.day()).leftpad(2,'0');
        
    }
}