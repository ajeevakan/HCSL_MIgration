global without sharing class OppSystemActivityHelper{
    global static Boolean ranOppSystemActivityTrigger = false;
    global static set<Id> setOppTrigger = new set<Id>();
    
    public void OppTrigger(boolean UseFuture){
        map<string, Opp_System_Activity_Type__mdt> mapOppCustSetting = new map<string, Opp_System_Activity_Type__mdt>(); 
        map<string, list<Opp_System_Activity_Type__mdt>> mapOppListCustSetting = new map<string, list<Opp_System_Activity_Type__mdt>>(); 
        set<string> setActvtTypes = new set<string>();
        set<string> setOppRecTypes = new set<string>();
        //map<string,Id> mapOppRecType = new map<string,Id>();
        map<Id,string> mapOppRecTypeId = new map<Id,string>();
        for (Opp_System_Activity_Type__mdt objOSM : Opp_System_Activity_Type__mdt.getall().values())
            if (string.isNotBlank(objOSM.Opp_Date_Field__c)){
                mapOppCustSetting.put(objOSM.Opp_Date_Field__c, objOSM);
                if (string.isNotBlank(objOSM.Activity_Type_Value__c))
                    setActvtTypes.add(objOSM.Activity_Type_Value__c);
                if (mapOppListCustSetting.containsKey(objOSM.Opp_Date_Field__c))
                    mapOppListCustSetting.get(objOSM.Opp_Date_Field__c).add(objOSM);
                else 
                    mapOppListCustSetting.put(objOSM.Opp_Date_Field__c, new list<Opp_System_Activity_Type__mdt>{objOSM});
                if (string.isNotBlank(objOSM.Opp_Record_Type_Name__c))
                    setOppRecTypes.add(objOSM.Opp_Record_Type_Name__c);
            }
        if (!setOppRecTypes.isEmpty()){
            Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity; 
            Map<String,Schema.RecordTypeInfo> rtOppMapByName = dopp.getRecordTypeInfosByName();
            for (string strrt : setOppRecTypes)
                if (rtOppMapByName!=null) if (rtOppMapByName.containsKey(strrt)){
                    //mapOppRecType.put(strrt,rtOppMapByName.get(strrt).getRecordTypeId());
                    mapOppRecTypeId.put(rtOppMapByName.get(strrt).getRecordTypeId(),strrt);
                }
        }
        //Id snfRecTypeId = (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SNF').getRecordTypeId());

        if (!(setActvtTypes.isEmpty())){
            map<string,list<Opportunity>> mapAddDateOpp = new map<string,list<Opportunity>>();
            map<string,list<Opportunity>> mapRemoveDateOpp = new map<string,list<Opportunity>>();
            list<Id> lstOppId = new list<Id>();
            for (Opportunity objOpp : (list<Opportunity>)trigger.New){
                boolean flag = false;
                if (trigger.isInsert){
                    for (string strDtFld : mapOppListCustSetting.keySet())
                        if (!(objOpp.get(strDtFld)==Null))
                        if (MatchOppRecType(objOpp,mapOppListCustSetting.get(strDtFld),mapOppRecTypeId))
                        {
                            flag = true;
                            if (!(mapAddDateOpp.containsKey(strDtFld)))
                                mapAddDateOpp.put(strDtFld,new list<Opportunity>{objOpp});
                            else
                                mapAddDateOpp.get(strDtFld).add(objOpp);
                            for (Opp_System_Activity_Type__mdt objOSCS : mapOppListCustSetting.get(strDtFld))
                                if (string.isNotBlank(objOSCS.Activity_Type_Field__c))
                                    if (objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))!=null)
                                        setActvtTypes.add(string.valueOf(objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))));
                        }
                }
                else if (trigger.isUpdate){
                    Opportunity objOldOpp = (Opportunity)trigger.oldMap.get(objOpp.Id);
                    if (objOldOpp!=Null){
                        for (string strDtFld : mapOppListCustSetting.keySet()) if (MatchOppRecType(objOpp,mapOppListCustSetting.get(strDtFld),mapOppRecTypeId)){
                        
                            // DR Add option to force firing of trigger without field edits if Toggle Create System Activities Trigger field is changed and not null
                            Boolean fireActTrigger = false;
                            if (!((objOpp.get('Toggle_Create_System_Activities_Trigger__c')==Null)&&(objOldOpp.get('Toggle_Create_System_Activities_Trigger__c'   )==Null)))
                               if  (!(objOpp.get('Toggle_Create_System_Activities_Trigger__c')==objOldOpp.get('Toggle_Create_System_Activities_Trigger__c')))
                                 fireActTrigger = true; 
               // system.debug(strDtFld);
                            // system.debug(objOpp.get(strDtFld));
                            // system.debug(objOldOpp.get(strDtFld));
                            if  (!((objOpp.get(strDtFld)==Null)&&(objOldOpp.get(strDtFld)==Null)))
                                if  (!(objOpp.get(strDtFld)==objOldOpp.get(strDtFld)))
                                   fireActTrigger = true; 
                                
                            if (fireActTrigger )    {
                                    flag = true;
                                    if ((objOpp.get(strDtFld)==Null)){
                                        if (!(mapRemoveDateOpp.containsKey(strDtFld)))
                                            mapRemoveDateOpp.put(strDtFld,new list<Opportunity>{objOpp});
                                        else
                                            mapRemoveDateOpp.get(strDtFld).add(objOpp);
                                    }
                                    else{
                                        if (!(mapAddDateOpp.containsKey(strDtFld)))
                                            mapAddDateOpp.put(strDtFld,new list<Opportunity>{objOpp});
                                        else
                                            mapAddDateOpp.get(strDtFld).add(objOpp);
                                    }
                                    for (Opp_System_Activity_Type__mdt objOSCS : mapOppListCustSetting.get(strDtFld))
                                        if (string.isNotBlank(objOSCS.Activity_Type_Field__c))
                                            if (objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))!=null)
                                                setActvtTypes.add(string.valueOf(objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))));
                                }
                        }
                    }
                    objOldOpp = Null;
                }
                if (flag) {
                    if (setOppTrigger!=null){
                        if (setOppTrigger.contains(objOpp.Id))
                            flag = false;
                        else{
                            if (!Test.isRunningTest()) setOppTrigger.add(objOpp.Id);}
                    }
                    else
                        setOppTrigger = new set<Id>{objOpp.Id};
                }
                if (flag){
                    lstOppId.add(objOpp.Id);
                }
            }
            if (!(lstOppId.isEmpty())){
                CallOppTrigger( lstOppId,  setActvtTypes, 
                     mapAddDateOpp, 
                     mapRemoveDateOpp, 
                     mapOppListCustSetting,
                     mapOppRecTypeId,
                     UseFuture);
            }
            
        }
        ranOppSystemActivityTrigger = false;
    }
    
    private static void CallOppTrigger(list<Id> lstOppId, set<string> setActvtTypes, 
                map<string,list<Opportunity>> mapAddDateOpp, 
                map<string,list<Opportunity>> mapRemoveDateOpp, 
                map<string, list<Opp_System_Activity_Type__mdt>> mapOppListCustSetting,
                map<Id,string> mapOppRecTypeId,
                boolean UseFuture){
        if (!UseFuture) OppTrigger( lstOppId,  setActvtTypes, 
                     mapAddDateOpp, 
                     mapRemoveDateOpp, 
                     mapOppListCustSetting,
                     mapOppRecTypeId);
        else if ((system.isFuture())||(system.isBatch())) OppTrigger( lstOppId,  setActvtTypes, 
                     mapAddDateOpp, 
                     mapRemoveDateOpp, 
                     mapOppListCustSetting,
                     mapOppRecTypeId);
        else{
            list<string> lstAddDateOpp = new list<string>();
            list<string> lstRemoveDateOpp = new list<string>();
            if (mapAddDateOpp!=null)
                if (!mapAddDateOpp.isEmpty())
                    for (string strFld : mapAddDateOpp.keySet())
                        if (string.isNotBlank(strFld))
                            if (mapAddDateOpp.get(strFld)!=null)
                                for (Opportunity objOpp : mapAddDateOpp.get(strFld))
                                    lstAddDateOpp.add(strFld+':'+string.valueOf(objOpp.Id));
            if (mapRemoveDateOpp!=null)
                if (!mapRemoveDateOpp.isEmpty())
                    for (string strFld : mapRemoveDateOpp.keySet())
                        if (string.isNotBlank(strFld))
                            if (mapRemoveDateOpp.get(strFld)!=null)
                                for (Opportunity objOpp : mapRemoveDateOpp.get(strFld))
                                    lstRemoveDateOpp.add(strFld+':'+string.valueOf(objOpp.Id));
            // system.debug('calling FutureOppTrigger -'+lstOppId);
            // system.debug(lstAddDateOpp);
            // system.debug(lstRemoveDateOpp);
            // system.debug(mapOppRecTypeId);
            FutureOppTrigger( lstOppId,  
                 lstAddDateOpp,   
                 lstRemoveDateOpp,
                 mapOppRecTypeId  
                );
        }
    }
    
    @future
    static void FutureOppTrigger(list<Id> lstOppId,  
                list<string> lstAddDateOpp,   
                list<string> lstRemoveDateOpp,
                map<Id,string> mapOppRecTypeId  
                ){
            //         system.debug('called FutureOppTrigger -'+lstOppId);
            // system.debug(lstAddDateOpp);
            // system.debug(lstRemoveDateOpp);
            // system.debug(mapOppRecTypeId);
        map<string, Opp_System_Activity_Type__mdt> mapOppCustSetting = new map<string, Opp_System_Activity_Type__mdt>(); 
        map<string, list<Opp_System_Activity_Type__mdt>> mapOppListCustSetting = new map<string, list<Opp_System_Activity_Type__mdt>>(); 
        set<string> setActvtTypes = new set<string>();
        for (Opp_System_Activity_Type__mdt objOSM : Opp_System_Activity_Type__mdt.getall().values())
            if (string.isNotBlank(objOSM.Opp_Date_Field__c)){
                mapOppCustSetting.put(objOSM.Opp_Date_Field__c, objOSM);
                if (string.isNotBlank(objOSM.Activity_Type_Value__c))
                    setActvtTypes.add(objOSM.Activity_Type_Value__c);
                if (mapOppListCustSetting.containsKey(objOSM.Opp_Date_Field__c))
                    mapOppListCustSetting.get(objOSM.Opp_Date_Field__c).add(objOSM);
                else 
                    mapOppListCustSetting.put(objOSM.Opp_Date_Field__c, new list<Opp_System_Activity_Type__mdt>{objOSM});
            }
        string query = 'Select ' + returnAllFields('Opportunity') + ' FROM Opportunity WHERE Id IN :lstOppId ';
        map<Id, Opportunity> mapOpportunity = new map<Id, Opportunity>((list<Opportunity>)database.query(query));
        map<string,list<Opportunity>> mapAddDateOpp = new map<string,list<Opportunity>>();
        map<string,list<Opportunity>> mapRemoveDateOpp = new map<string,list<Opportunity>>();
        if (lstAddDateOpp!=null) if (!lstAddDateOpp.isEmpty())
            for (string strAddDateOpp : lstAddDateOpp){
                list<string> arrTemp = strAddDateOpp.split(':');
                if (arrTemp!=null) 
                    if (arrTemp.size()==2)
                        if (mapOpportunity.containsKey(Id.valueOf(arrTemp.get(1)))){
                            string strDtFld = arrTemp.get(0);
                            Opportunity objOpp = (mapOpportunity.get(Id.valueOf(arrTemp.get(1))));
                            if (!(mapAddDateOpp.containsKey(strDtFld)))
                                mapAddDateOpp.put(strDtFld,new list<Opportunity>{objOpp});
                            else
                                mapAddDateOpp.get(strDtFld).add(objOpp);
                                for (Opp_System_Activity_Type__mdt objOSCS : mapOppListCustSetting.get(strDtFld))
                                    if (string.isNotBlank(objOSCS.Activity_Type_Field__c))
                                        if (objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))!=null)
                                            setActvtTypes.add(string.valueOf(objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))));
                        }
            }
        if (lstRemoveDateOpp!=null) if (!lstRemoveDateOpp.isEmpty())
            for (string strRemoveDateOpp : lstRemoveDateOpp){
                list<string> arrTemp = strRemoveDateOpp.split(':');
                if (arrTemp!=null) 
                    if (arrTemp.size()==2)
                        if (mapOpportunity.containsKey(Id.valueOf(arrTemp.get(1)))){
                            string strDtFld = arrTemp.get(0);
                            Opportunity objOpp = (mapOpportunity.get(Id.valueOf(arrTemp.get(1))));
                            if (!(mapRemoveDateOpp.containsKey(strDtFld)))
                                mapRemoveDateOpp.put(strDtFld,new list<Opportunity>{objOpp});
                            else
                                mapRemoveDateOpp.get(strDtFld).add(objOpp);
                                for (Opp_System_Activity_Type__mdt objOSCS : mapOppListCustSetting.get(strDtFld))
                                    if (string.isNotBlank(objOSCS.Activity_Type_Field__c))
                                        if (objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))!=null)
                                            setActvtTypes.add(string.valueOf(objOpp.get(string.valueOf(objOSCS.Activity_Type_Field__c))));
                        }
            }
        OppTrigger( lstOppId,  setActvtTypes, 
                     mapAddDateOpp, 
                     mapRemoveDateOpp, 
                     mapOppListCustSetting,
                     mapOppRecTypeId);
    }
    
    private static void OppTrigger(list<Id> lstOppId, set<string> setActvtTypes, 
                map<string,list<Opportunity>> mapAddDateOpp, 
                map<string,list<Opportunity>> mapRemoveDateOpp, 
                map<string, list<Opp_System_Activity_Type__mdt>> mapOppListCustSetting,
                map<Id,string> mapOppRecTypeId){
        if (ranOppSystemActivityTrigger) return;
        ranOppSystemActivityTrigger = true;
        map<Id,list<Task>> mapoppTasks = new map<Id,list<Task>>();
        for (sObject objTask : database.query(GetTaskQuery(mapAddDateOpp, mapRemoveDateOpp, mapOppListCustSetting))){
            if (mapoppTasks.containsKey(Id.valueOf(string.valueOf(objTask.get('WhatId')))))
                mapoppTasks.get(Id.valueOf(string.valueOf(objTask.get('WhatId')))).add((Task)objTask);
            else 
                mapoppTasks.put(Id.valueOf(string.valueOf(objTask.get('WhatId'))),new list<Task>{(Task)objTask});
        }
        Map<String,Schema.RecordTypeInfo> rtTaskMapByName = Schema.SObjectType.Task.getRecordTypeInfosByName();
        if (!(mapAddDateOpp.isEmpty())){
            List<Task> listTask = new List<Task>();
            for (string strdtFd : mapAddDateOpp.keySet()){
                for (Opportunity objOpp : mapAddDateOpp.get(strdtFd)){
                    Opp_System_Activity_Type__mdt objOSM = GetOSM(objOpp, mapOppListCustSetting.get(strdtFd), mapOppRecTypeId);
                    if (objOSM!=null){
                        string strActvtType = string.valueOf(objOSM.Activity_Type_Value__c).trim();
                        if (string.isNotBlank(objOSM.Activity_Type_Field__c))
                            if (objOpp.get(string.valueOf(objOSM.Activity_Type_Field__c))!=null)
                                strActvtType = string.valueOf(objOpp.get(string.valueOf(objOSM.Activity_Type_Field__c)));
                        string strActvtTypeFld = 'Activity_Type__c';
                        Id TskRecTypeId = null;
                        Task t = new Task(Subject = strActvtType, 
                                            System__c = true, 
                                            WhatId = objOpp.Id, 
                                            ActivityDate = (Date)objOpp.get(strdtFd), 
                                            Activity_Complete_Date__c = (Date)objOpp.get(strdtFd), 
                                            Status = 'Completed', 
                                            Result_Code__c = 'Completed', 
                                            OwnerId = objOpp.OwnerId);
                        t.put(strActvtTypeFld,strActvtType);
                        if (string.isNotBlank(objOSM.Task_Record_Type_Name__c))
                            if (rtTaskMapByName!= null) if (rtTaskMapByName.containsKey(objOSM.Task_Record_Type_Name__c)){
                                TskRecTypeId = rtTaskMapByName.get(objOSM.Task_Record_Type_Name__c).getRecordTypeId();
                                t.put('RecordTypeId',TskRecTypeId);
                            }
                        if (objOSM.Assign_Task_to_Current_User__c)
                            t.OwnerId = UserInfo.getUserId();
                        else if (string.isNotBlank(objOSM.Assign_Task_Opp_Field__c))
                            if (!('OwnerId'.equalsIgnoreCase(objOSM.Assign_Task_Opp_Field__c)))
                                t.OwnerId=(Id)objOpp.get(objOSM.Assign_Task_Opp_Field__c);
                        Task objTaskMatch = null;
                        objTaskMatch=GetMatchingTask(objOpp.Id,mapoppTasks,strActvtType,strActvtTypeFld,TskRecTypeId);
                        if (objTaskMatch!=null)
                            t.Id = objTaskMatch.Id;
                        listTask.add(t);
                    }
                }
            }
            if (!listTask.isEmpty())
                upsert listTask;
        }
        if (!(mapRemoveDateOpp.isEmpty())){
            List<Task> listTaskDel = new List<Task>();
            for (string strdtFd : mapRemoveDateOpp.keySet()){
                for (Opportunity objOpp : mapRemoveDateOpp.get(strdtFd)){
                    Opp_System_Activity_Type__mdt objOSM = GetOSM(objOpp, mapOppListCustSetting.get(strdtFd), mapOppRecTypeId);
                    if (objOSM!=null){
                        string strActvtType = string.valueOf(objOSM.Activity_Type_Value__c).trim();
                        if (string.isNotBlank(objOSM.Activity_Type_Field__c))
                            if (objOpp.get(string.valueOf(objOSM.Activity_Type_Field__c))!=null)
                                strActvtType = string.valueOf(objOpp.get(string.valueOf(objOSM.Activity_Type_Field__c)));
                        string strActvtTypeFld = 'Activity_Type__c';
                        Id TskRecTypeId = null;
                        if (string.isNotBlank(objOSM.Task_Record_Type_Name__c))
                            if (rtTaskMapByName!= null) if (rtTaskMapByName.containsKey(objOSM.Task_Record_Type_Name__c))
                                TskRecTypeId = rtTaskMapByName.get(objOSM.Task_Record_Type_Name__c).getRecordTypeId();
                            
                        Task objTaskMatch = null;
                        objTaskMatch=GetMatchingTask(objOpp.Id,mapoppTasks,strActvtType,strActvtTypeFld,TskRecTypeId);
                        if (objTaskMatch!=null)
                            listTaskDel.add(objTaskMatch);
                    }
                }
            }
            if (!listTaskDel.isEmpty())
                delete listTaskDel;
        }
        ranOppSystemActivityTrigger = false;    
    }
    
    private boolean MatchOppRecType(Opportunity objOpp, list<Opp_System_Activity_Type__mdt> lstOSM, map<Id,string> mapOppRecTypeId){
        boolean ismatch = false;
        for (Opp_System_Activity_Type__mdt objOSM : lstOSM) if (!ismatch){
            if (string.isBlank(objOSM.Opp_Record_Type_Name__c))
                ismatch = true;
            else if ((objOpp.get('RecordTypeId')!=null))
                if (mapOppRecTypeId.containsKey((Id)objOpp.get('RecordTypeId')))
                    if (mapOppRecTypeId.get((Id)objOpp.get('RecordTypeId')).equalsIgnoreCase(objOSM.Opp_Record_Type_Name__c))
                        ismatch = true;
        }
        return ismatch;
    }
    
    private static Opp_System_Activity_Type__mdt GetOSM(Opportunity objOpp, list<Opp_System_Activity_Type__mdt> lstOSM, map<Id,string> mapOppRecTypeId){
        boolean ismatch = false;
        Opp_System_Activity_Type__mdt objRet = null;
        for (Opp_System_Activity_Type__mdt objOSM : lstOSM) if (!ismatch){
            if (string.isBlank(objOSM.Opp_Record_Type_Name__c))
                ismatch = true;
            else if ((objOpp.get('RecordTypeId')!=null))
                if (mapOppRecTypeId.containsKey((Id)objOpp.get('RecordTypeId')))
                    if (mapOppRecTypeId.get((Id)objOpp.get('RecordTypeId')).equalsIgnoreCase(objOSM.Opp_Record_Type_Name__c))
                        ismatch = true;
            if (ismatch) objRet = objOSM;
        }
        return objRet;
    }
    
    private static String returnAllFields(String objectName){
        String fieldsCSV = '';
        for(Schema.SObjectField f: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().values()){
            DescribeFieldResult fr = f.getDescribe();
            if(fr.isAccessible())
                fieldsCSV += fr.getLocalName() + ',';
        }
        fieldsCSV = fieldscsv.removeEnd(',');
        return fieldsCSV;
    }
    
    private static string GetTaskQuery(map<string,list<Opportunity>> mapAddDateOpp,map<string,list<Opportunity>> mapRemoveDateOpp,map<string, list<Opp_System_Activity_Type__mdt>> mapOppListCustSetting){
        string strQuery = 'SELECT Id, WhatId';
        set<string> setActTypeFld = new set<string>{'Activity_Type__c'};
        boolean addRecTypeFld = false;
        for (string strDtFld : mapOppListCustSetting.keySet())
            if ((mapAddDateOpp.containsKey(strDtFld))||(mapRemoveDateOpp.containsKey(strDtFld)))
                for (Opp_System_Activity_Type__mdt objOSM : mapOppListCustSetting.get(strDtFld)){
                    //if (string.isNotBlank(objOSM.Activity_Type_Field__c))
                    //    setActTypeFld.add(objOSM.Activity_Type_Field__c);
                    if (string.isNotBlank(objOSM.Task_Record_Type_Name__c))
                        addRecTypeFld=true;
                }
        if (addRecTypeFld)
            setActTypeFld.add('RecordTypeId');
        for (string strFld : setActTypeFld)
            strQuery += (', '+strFld);
        strQuery += ' FROM Task WHERE WhatId in:lstOppId AND (';
        integer i = 0;
        for (string strFld : setActTypeFld){
            i++;
            strQuery += ((i==1?' ':' OR ') + strFld + ' IN :setActvtTypes ');
        }
        strQuery += ') AND IsDeleted = false ALL ROWS ';
        system.debug(strQuery);
        return strQuery;
    }
    
    private static Task GetMatchingTask(Id OppId, map<Id,list<Task>> mapoppTasks, 
            string strActvtType, string strActvtTypeFld, Id TskRecTypeId){
        Task objTask = null;
        if (mapoppTasks.containsKey(OppId))
            for (Task tsk : mapoppTasks.get(OppId)){
                boolean match = true;
                if (string.isNotBlank(TskRecTypeId))
                    if (!(TskRecTypeId==((Id)tsk.get('RecordTypeId'))))
                        match=false;
                if (!strActvtType.equalsIgnoreCase(string.valueOf(tsk.get(strActvtTypeFld))))
                    match=false;
                if (match){
                    objTask = tsk;
                    break;
                }
            }
        return objTask;
    }

}