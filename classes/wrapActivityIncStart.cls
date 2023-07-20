public class wrapActivityIncStart implements Comparable 
    {
        @AuraEnabled
        public Date ActivityDate {get; set;}
        @AuraEnabled
        public string Subject {get; set;}
        @AuraEnabled
        public string Description {get; set;}
        @AuraEnabled
        public string OwnerName {get; set;}
        @AuraEnabled
        public string ResultCode {get; set;}
        public string WhatName {get; set;}
        @AuraEnabled
        public string WhoName {get; set;}
        @AuraEnabled
        public Id ActivityId {get; set;}
        @AuraEnabled
        public DateTime StartDateTime {get; set;}
        @AuraEnabled
        public string StartDateTimeStr {get; set;}
        @AuraEnabled
        public boolean HighPriority {get; set;}
        @AuraEnabled
        public string ActivityObjectType {get; set;} // Task or Event
  
        public Integer compareTo(Object compareTo) 
        {
            try
            {
                wrapActivityIncStart  compareToD = (wrapActivityIncStart)compareTo;
                if (ActivityDate == compareToD.ActivityDate){
                    if (ActivityObjectType > compareToD.ActivityObjectType) return 1;
                    else if (ActivityObjectType < compareToD.ActivityObjectType) return -1;
                    if (HighPriority == compareToD.HighPriority){
                        if (StartDateTime == null && compareToD.StartDateTime == null) return 0;
                        else if (StartDateTime != null && compareToD.StartDateTime == null) return 1;
                        else if (StartDateTime == null && compareToD.StartDateTime != null) return -1;
                        else if (StartDateTime > compareToD.StartDateTime) return 1;
                        else return -1;
                    }
                    else return (HighPriority?-1:1);
                }
                if (ActivityDate > compareToD.ActivityDate) return 1;
                return -1;
            }
            catch(Exception exc)
            {
                return 0;    
            }
        }
    }