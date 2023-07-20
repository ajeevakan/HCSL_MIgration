public with sharing class HomePageMultiSiteActivityList {

@AuraEnabled
  public static ActivityMultiListReturn getActivities(string strOption, string strCommunity) {
   if ((string.isBlank(strOption))) strOption = '0'; //('0').equalsIgnoreCase(strOption)
   if ((string.isBlank(strCommunity))) strCommunity = '';
   list<wrapActivityIncStart> wrapActivitylist;
   list<Task> tasklist;
   list<Event> eventlist;
   Id currentUserId = UserInfo.getUserId();
    //User_Preferences__c Activity_List_Filter__c User__c
    User_Preferences__c oUP = null;
    for (User_Preferences__c tUP : [SELECT Id, Multi_Site_Activity_List_Filter__c, Multi_Site_Activity_List_Community__c, User__c FROM User_Preferences__c WHERE User__c = :currentUserId LIMIT 1])
        oUP = tUP;
      if (oUP==null){
          if (('0').equalsIgnoreCase(strOption)) strOption = '1';
          oUP = new User_Preferences__c(User__c=currentUserId, Multi_Site_Activity_List_Filter__c=strOption, Multi_Site_Activity_List_Community__c=strCommunity);
      }
      else{
          if (('0').equalsIgnoreCase(strOption)){
              if (string.isNotBlank(oUP.Multi_Site_Activity_List_Filter__c)){
                strOption = oUP.Multi_Site_Activity_List_Filter__c;
                strCommunity = oUP.Multi_Site_Activity_List_Community__c;
                if ((string.isBlank(strCommunity))) strCommunity = '';  
              }
              else
                strOption = '1';
          }
          if (!strOption.equalsIgnoreCase(oUP.Multi_Site_Activity_List_Filter__c))
              oUP.Multi_Site_Activity_List_Filter__c=strOption;
          if (!strCommunity.equalsIgnoreCase(oUP.Multi_Site_Activity_List_Community__c))
              oUP.Multi_Site_Activity_List_Community__c=strCommunity;
      }
      upsert oUP;
   wrapActivitylist = new list<wrapActivityIncStart>();
   
   //Updated the below SOQL to include IsDeleted = FALSE
   tasklist=(list<Task>)database.query(getTaskSOQL(strOption,strCommunity));
//   tasklist= [select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,Owner.Name, Activity_Type__c, Result_Code__c FROM Task WHERE  IsDeleted = FALSE AND
//   (ActivityDate <= TODAY) and OwnerId =:currentUserId  and Is_Pending__c = true  ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS];
   eventlist=(list<Event>)database.query(getEventSOQL(strOption,strCommunity));
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
      ActivityMultiListReturn objret = new ActivityMultiListReturn();
      objret.lstActivities = wrapActivitylist;
      objret.strOption = strOption;
      objret.selectedComm = strCommunity;
      objret.lstCommOptions = new list<string>{''};
      Schema.DescribeFieldResult F = Account.Community__c.getDescribe();
      Schema.sObjectField T = F.getSObjectField();
      List<PicklistEntry> entries = T.getDescribe().getPicklistValues();
      for (PicklistEntry pe : entries){
            string strTemp = pe.getValue();
            objret.lstCommOptions.add(strTemp);
      }
      return objret;
    }
    
    public class ActivityMultiListReturn{
        @AuraEnabled
        public List<wrapActivityIncStart> lstActivities;
        @AuraEnabled
        public string strOption;
        @AuraEnabled
        public List<String> lstCommOptions;
        @AuraEnabled
        public string selectedComm;
    }
    
    
    public static string getEventSOQL(string strOption, string strCommunity) {
        string strSOQL = '';
        string strOwnerId = UserInfo.getUserId();
        string strCommClause = ' ';
        if (string.isNotBlank(strCommunity))
            strCommClause = ' AND Account.Community__c =\'' + strCommunity + '\' ';
        else if (strOption=='6' || strOption=='7' || strOption=='8' || strOption=='9' || strOption=='10')
            strCommClause = ' AND Account.Community__c  =\'' + 'NO COMMUNITY SELECTED - NOT ALLOWED' + '\' ';
        //switch on strOption
        //{
            if (strOption=='1'){ //My Activity Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+ strCommClause +
                    'AND (ActivityDate = '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='2'){ //My Overdue Activity
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730  and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='3'){ //My Activity Next 7 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='4'){ //My Activity Next 30 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='5'){ //My Activity Due by Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730  and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='6'){ //All Activity Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+ strCommClause +
                    'AND (ActivityDate = '+getDateStr(date.today())+')  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='7'){ //All Overdue Activity
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='8'){ //All Activity Next 7 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='9'){ //All Activity Next 30 Days
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'   '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='10'){ //All Activity Due by Today
                strSOQL = 'select Id,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, StartDateTime FROM Event WHERE IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'    '+ strCommClause +
                    'AND (ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730  and Is_Pending__c = true '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
        //}
        return strSOQL;
    }
    
    public static string getTaskSOQL(string strOption, string strCommunity) {
        string strSOQL = '';
        string strOwnerId = UserInfo.getUserId();
        string strCommClause = ' ';
        if (string.isNotBlank(strCommunity))
            strCommClause = ' Account.Community__c =\'' + strCommunity + '\' AND ';
        //switch on strOption{
            if (strOption=='1'){ //My Activity Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND  '+ strCommClause +
                    '(ActivityDate = '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='2'){ //My Overdue Activity
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND  '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730  and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='3'){ //My Activity Next 7 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND  '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='4'){ //My Activity Next 30 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND  '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='5'){ //My Activity Due by Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND  '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730  and OwnerId = \''+strOwnerId+'\'  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='6'){ //All Activity Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'  AND  '+ strCommClause +
                    '(ActivityDate = '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='7'){ //All Overdue Activity
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'  AND   '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(-1))+') and ActivityDate >= Last_N_Days:730  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='8'){ //All Activity Next 7 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'  AND   '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(7))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='9'){ //All Activity Next 30 Days
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'  AND   '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today().addDays(30))+' AND ActivityDate >= '+getDateStr(date.today())+') and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
            else if (strOption=='10'){ //All Activity Due by Today
                strSOQL = 'select Id,Status,ActivityDate,Subject,Who.Name,What.Name,Description,Activity_Complete_Date__c,'+
                    'Owner.Name, Activity_Type__c, Result_Code__c, Priority FROM Task WHERE  IsDeleted = FALSE AND Account.RecordType.Name = \'Person Account\'  AND  '+ strCommClause +
                    '(ActivityDate <= '+getDateStr(date.today())+') and ActivityDate >= Last_N_Days:730  and Is_Pending__c = true  '+
                    'ORDER BY ActivityDate DESC LIMIT 1000 ALL ROWS';
            }
        //}
        return strSOQL;
    }

    private static string getDateStr(date d){
        return DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYY-MM-dd');
    }
}