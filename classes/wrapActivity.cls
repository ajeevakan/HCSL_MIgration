public class wrapActivity implements Comparable 
    {
        @AuraEnabled
        public Date ActivityDate {get; set;}
        @AuraEnabled
        public string Subject {get; set;}
        @AuraEnabled
        public string Description {get; set;}
        public string OwnerName {get; set;}
        @AuraEnabled
        public string ResultCode {get; set;}
        public string WhatName {get; set;}
        @AuraEnabled
        public string WhoName {get; set;}
  
        public Integer compareTo(Object compareTo) 
        {
            try
            {
                 wrapActivity compareToD = (wrapActivity)compareTo;
                if (ActivityDate == compareToD.ActivityDate) return 0;
                if (ActivityDate > compareToD.ActivityDate) return -1;
                return 1;
            }
            catch(Exception exc)
            {
                return 0;    
            }
        }
    }