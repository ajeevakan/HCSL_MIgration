global class DisableTrigger {
    global static boolean isDisabled(string strName){
        try{
            Disable_Trigger__c objDisableTrigger = Disable_Trigger__c.getInstance(strName);
            if (objDisableTrigger!=null) if (objDisableTrigger.Trigger_Disabled__c){
                if (objDisableTrigger.Disable_For_Users__c!=null) 
                    if (string.valueOf(objDisableTrigger.Disable_For_Users__c).trim()!='')
                        return (string.valueOf(objDisableTrigger.Disable_For_Users__c).containsIgnoreCase(UserInfo.getUserName()));
                return true;
            }
            return false;
        }
        catch(Exception exc){return false;}
    }
}