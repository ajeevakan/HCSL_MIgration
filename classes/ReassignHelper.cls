public without sharing class ReassignHelper implements Database.Batchable<sObject>, Database.Stateful{

    Id ReassignBatchId;
    boolean reverse;
    
    public ReassignHelper(Id pReassignBatchId,boolean preverse){
        ReassignBatchId = pReassignBatchId;
        reverse=preverse;
    }

    public Iterable<sObject> start (Database.BatchableContext bc){
        system.debug('Batch ReassignHelper: Batch Start');
        String query = GetBatchQuery(ReassignBatchId,reverse);
        system.debug(query);
        if (string.isBlank(query)) return null;
        else return Database.query(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug(scope);
        if (reverse) ReverseAssign(ReassignBatchId, (list<Reassignment_Log__c>)scope);
        else ReassignRecords(scope, ReassignBatchId);
    }

    public void finish(Database.BatchableContext BC) {
        if (string.isNotBlank(ReassignBatchId))
        for (Reassignment_Batch__c rb : [SELECT Id, Name, Status__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]){
            if (!(rb.Status__c.containsIgnoreCase('Error'))) rb.Status__c = reverse?'Reversed':'Completed';
            else if (!reverse) rb.Status__c = 'Completed with Errors';
            else rb.Status__c = 'ERROR (Reverse)';
            update rb;
        }
    }

    @InvocableMethod(label = 'ReverseAssign')
    public static List<String> ReverseAssign(list<Id> ReassignmentBatchIds){
        List<String> ret = new List<String>();
        if (ReassignmentBatchIds!=null) if (!ReassignmentBatchIds.isEmpty()) if (ReassignmentBatchIds.size()==1){
            Id ReassignBatchId = ReassignmentBatchIds.get(0);
            for (Reassignment_Batch__c rb : [SELECT Id, Name, Status__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]){
                if (!rb.Status__c.containsIgnoreCase('Completed')) ret.add('Batch Status is \'' + rb.Status__c + '\'. It cannot be reveresed.');
                else{
                    ret.add('Batch process started to reverse assignment.');
                    ReassignHelper oReassignHelper   = new ReassignHelper(ReassignBatchId,true); 
                    Database.executeBatch(oReassignHelper, 10);
                }
            }
        }
        return ret;
    }

    public static void ReverseAssign(Id ReassignBatchId, list<Reassignment_Log__c> lstLog){
        Reassignment_Batch__c objRB = null;
        for (Reassignment_Batch__c rb : [SELECT Id, Name, Message__c, Status__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]) 
            objRB = rb;
        if (objRB!=null) if (!('Reversed'.equalsIgnoreCase(objRB.Status__c))){
            try{
                map<string,set<Id>> mapRec = new map<string,set<Id>>();
                map<string,set<string>> mapObjFlds = new map<string,set<string>>();
                for (Reassignment_Log__c olog : lstLog) if (string.isNotBlank(olog.Record_Id__c)){
                    String sObjName = Id.valueOf(olog.Record_Id__c).getSObjectType().getDescribe().getName();
                    if (string.isNotBlank(sObjName)){
                        if (mapRec.containsKey(sObjName)) mapRec.get(sObjName).add(Id.valueOf(olog.Record_Id__c));
                        else mapRec.put(sObjName,new set<Id>{Id.valueOf(olog.Record_Id__c)});
                        if (!mapObjFlds.containsKey(sObjName)) 
                            mapObjFlds.put(sObjName,new set<string>{'Id','OwnerId'});
                        if (string.isNotBlank(olog.Old_Values__c))
                            for (OldValue ov : (list<OldValue>)JSON.deserialize(olog.Old_Values__c, list<OldValue>.class))
                                mapObjFlds.get(sObjName).add(ov.FieldName);
                        
                    }
                }
                if (!mapRec.isEmpty()){
                    Map<Id,SObject> mapDataRows = new Map<Id,SObject>();
                    for (string strObjName : mapRec.keySet()){
                        set<Id> setrecId = mapRec.get(strObjName);
                        string strFldsList = '';
                        list<string> lstOFlds = new list<string>(mapObjFlds.get(strObjName));
                        integer n = lstOFlds.size();
                        for (integer i=0;i<n;i++)
                            strFldsList += (lstOFlds.get(i)+(i==(n-1)?' ':', '));
                        string strQ = 'SELECT '+strFldsList+' FROM '+ strObjName + ' WHERE Id IN :setrecId';
                        for (SObject obj : Database.query(strQ))
                            mapDataRows.put(obj.Id,obj);
                    }
                    if (!mapDataRows.isEmpty()){
                        List<SObject> lstUpdate = new List<SObject>();
                        for (Reassignment_Log__c olog : lstLog) if (string.isNotBlank(olog.New_Owner__c)) if (string.isNotBlank(olog.Old_Owner_Id__c)) if (string.isNotBlank(olog.Record_Id__c)) if (mapDataRows.containsKey(Id.valueOf(olog.Record_Id__c))){
                            SObject obj = mapDataRows.get(Id.valueOf(olog.Record_Id__c));
                            if (Id.valueOf(string.valueOf(obj.get('OwnerId')))==Id.valueOf(string.valueOf(olog.New_Owner__c))){
                                obj.put('OwnerId',Id.valueOf(string.valueOf(olog.Old_Owner_Id__c)));
                                if (string.isNotBlank(olog.Old_Values__c))
                                for (OldValue ov : (list<OldValue>)JSON.deserialize(olog.Old_Values__c, list<OldValue>.class)){
                                    if (string.isBlank(ov.FieldValue)) obj.put(ov.FieldName,null);
                                    else if ('Date'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,Date.valueOf(ov.FieldValue));
                                    else if ('Datetime'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,Datetime.valueOf(ov.FieldValue));
                                    else if ('Boolean'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,Boolean.valueOf(ov.FieldValue));
                                    else if ('Double'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,Double.valueOf(ov.FieldValue));
                                    else if ('Integer'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,Integer.valueOf(ov.FieldValue));
                                    else if ('String'.equalsIgnoreCase(ov.FieldType)) obj.put(ov.FieldName,string.valueOf(ov.FieldValue));
                                }
                                lstUpdate.add(obj);
                            }
                        }
                        if (!lstUpdate.isEmpty()) update lstUpdate;
                    }
                }
                objRB.Status__c='In Progress (Reverse)';
                update objRB;
            }
            catch(Exception exc){
                string strMessage = '';
                if (string.isNotBlank(objRB.Message__c)) strMessage = objRB.Message__c + '\r\n';
                strMessage += 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
                objRB.Status__c = 'ERROR (Reverse)';
                update objRB;
                system.debug(strMessage);
            }
        }
    }

    public static string GetBatchQuery(Id ReassignBatchId, boolean reverse){
        string strQuery = '';
        Reassignment_Batch__c objRB = null;
        for (Reassignment_Batch__c rb : [SELECT Id, Name, Campaign__c, Community__c, Current_Owner__c, Message__c, Object_Name__c, Reassign_Activities_Only__c, Reassign_To__c, Status__c, Activity_Start_Date__c, Activity_End_Date__c, Where_Condition__c, Close_Past_Due_Activities__c, Assign_To_Default_Community_User__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]) 
            objRB = rb;
        if (reverse){
            if (objRB!=null) if (('Completed'.equalsIgnoreCase(objRB.Status__c))||('Completed with Errors'.startsWithIgnoreCase(objRB.Status__c))||('ERROR'.startsWithIgnoreCase(objRB.Status__c))){
                strQuery = 'SELECT Id, New_Owner__c, Old_Owner_Id__c, Reassignment_Batch__c, Record_Id__c, Old_Values__c FROM Reassignment_Log__c WHERE Reassignment_Batch__c = \'' + ReassignBatchId + '\' ';
            }
        }
        else if (objRB!=null) if (!('Reverse'.containsIgnoreCase(objRB.Status__c))) if (!('In Progress'.equalsIgnoreCase(objRB.Status__c))) if (!('Completed'.equalsIgnoreCase(objRB.Status__c))){
            if (('Account').equalsIgnoreCase(objRB.Object_Name__c)){
                Id ReferralRecordTypeId = Null;
                ReferralRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
                if (string.isNotBlank(ReferralRecordTypeId)){
                    strQuery = 'SELECT Id, OwnerId, Name, RecordTypeId FROM Account WHERE RecordTypeId = \'' + ReferralRecordTypeId + '\' ';
                    if (string.isNotBlank(objRB.Where_Condition__c)) strQuery += (' AND '+objRB.Where_Condition__c);
                }
            }
            else if (('OpportunityByCampaign').equalsIgnoreCase(objRB.Object_Name__c)){
                if (string.isNotBlank(objRB.Campaign__c)){
                    strQuery = 'SELECT Id, OwnerId FROM Contact WHERE Id IN (Select ContactId FROM CampaignMember WHERE ContactId != null AND CampaignId = \'' + Id.valueOf(string.valueOf(objRB.Campaign__c)) + '\')';
                }
            }
            else if (('Opportunity').equalsIgnoreCase(objRB.Object_Name__c)){
                strQuery = 'SELECT Id, OwnerId FROM Opportunity ';
                if ((string.isNotBlank(objRB.Community__c))||(string.isNotBlank(objRB.Where_Condition__c))) strQuery += 'WHERE ';
                if (string.isNotBlank(objRB.Community__c)) strQuery += ' Reporting_Community__c = \'' + Id.valueOf(string.valueOf(objRB.Community__c)) + '\' ';
                if (string.isNotBlank(objRB.Where_Condition__c)) strQuery += (((string.isNotBlank(objRB.Community__c))?' AND ':'')+objRB.Where_Condition__c);

            }
        }
        return strQuery;
    }

    public static void ReassignRecords(list<sobject> lstObj, Id ReassignBatchId){
        if (string.isNotBlank(ReassignBatchId)) if (lstObj!=null) if (!lstObj.isEmpty()){
            Reassignment_Batch__c objRB = null;
            list<Id> lstObjId = new list<Id>();
            for (SObject sobj : lstObj) 
                lstObjId.add(sobj.Id);
            if (!lstObjId.isEmpty())
                for (Reassignment_Batch__c rb : [SELECT Id, Name, Campaign__c, Community__c, Current_Owner__c, Message__c, Object_Name__c, Reassign_Activities_Only__c, Reassign_To__c, Status__c, Activity_Start_Date__c, Activity_End_Date__c, Assign_To_Default_Community_User__c, Close_Past_Due_Activities__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]) 
                    objRB = rb;
                if (objRB!=null) if (!('ERROR'.startsWithIgnoreCase(objRB.Status__c))) if (!('Reverse'.containsIgnoreCase(objRB.Status__c))){ 
                    try{
                        if (('Account').equalsIgnoreCase(objRB.Object_Name__c)){
                            list<Contact> lstContact = new list<Contact>();
                            list<Id> lstContactId = new list<Id>();
                            for (Contact objRefCont : [SELECT Id, Name,AccountId, OwnerId FROM Contact WHERE AccountId IN :lstObjId]){
                                lstContact.add(objRefCont);
                                lstContactId.add(objRefCont.Id);
                                system.debug(objRefCont);
                            }
                            string strTaskQuery = 'SELECT Id, WhatId, WhoId, OwnerId, ActivityDate, Activity_Complete_Date__c, Result_Code__c, Status FROM Task WHERE Is_Pending__c = true ';
                            if (!lstContactId.isEmpty()) strTaskQuery += ' AND (WhoId IN :lstContactId OR WhatId IN :lstObjId) ';
                            else strTaskQuery += ' AND (WhatId IN :lstObjId) ';
                            if (string.isNotBlank(objRB.Current_Owner__c)) strTaskQuery += ' AND OwnerId = \'' + Id.valueOf(string.valueOf(objRB.Current_Owner__c)) + '\' ';
                            if (objRB.Activity_Start_Date__c!=null) strTaskQuery += ' AND ActivityDate >= '+Datetime.newInstance(objRB.Activity_Start_Date__c.year(),objRB.Activity_Start_Date__c.month(),objRB.Activity_Start_Date__c.day()).format('yyyy-MM-dd')+' ';
                            if (objRB.Activity_End_Date__c!=null) strTaskQuery += ' AND ActivityDate <= '+Datetime.newInstance(objRB.Activity_End_Date__c.year(),objRB.Activity_End_Date__c.month(),objRB.Activity_End_Date__c.day()).format('yyyy-MM-dd')+' ';

                            string strEventQuery = 'SELECT Id, WhatId, WhoId, OwnerId, ActivityDate, Activity_Complete_Date__c, Result_Code__c FROM Event WHERE Is_Pending__c = true ';
                            if (!lstContactId.isEmpty()) strEventQuery += ' AND (WhoId IN :lstContactId OR WhatId IN :lstObjId) ';
                            else strEventQuery += ' AND (WhatId IN :lstObjId) ';
                            if (string.isNotBlank(objRB.Current_Owner__c)) strEventQuery += ' AND OwnerId = \'' + Id.valueOf(string.valueOf(objRB.Current_Owner__c)) + '\' ';
                            if (objRB.Activity_Start_Date__c!=null) strEventQuery += ' AND ActivityDate >= '+Datetime.newInstance(objRB.Activity_Start_Date__c.year(),objRB.Activity_Start_Date__c.month(),objRB.Activity_Start_Date__c.day()).format('yyyy-MM-dd')+' ';
                            if (objRB.Activity_End_Date__c!=null) strEventQuery += ' AND ActivityDate <= '+Datetime.newInstance(objRB.Activity_End_Date__c.year(),objRB.Activity_End_Date__c.month(),objRB.Activity_End_Date__c.day()).format('yyyy-MM-dd')+' ';

                            list<Reassignment_Log__c> lstLog = new list<Reassignment_Log__c>();
                            list<Task> lstUpdateTask = new list<Task>();
                            
                            for (Task objTask : (list<Task>)Database.query(strTaskQuery)) if (!(objTask.OwnerId==objRB.Reassign_To__c)){
                                Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = objRB.Reassign_To__c,
                                    Old_Owner_Id__c=objTask.OwnerId,
                                    Reassignment_Batch__c=objRB.Id,
                                    Record_Id__c=objTask.Id);
                                objTask.OwnerId=objRB.Reassign_To__c;
                                if (objRB.Close_Past_Due_Activities__c){
                                    if (objTask.ActivityDate<date.today()){
                                        list<OldValue> lstOldValue = new list<OldValue>();
                                        lstOldValue.add(new OldValue('Status','String',objTask.Status));
                                        lstOldValue.add(new OldValue('Result_Code__c','String',objTask.Result_Code__c));
                                        lstOldValue.add(new OldValue('Activity_Complete_Date__c','Date',objTask.Activity_Complete_Date__c));
                                        oLog.Old_Values__c = JSON.serialize(lstOldValue);
                                        objTask.Status = 'Completed';
                                        objTask.Result_Code__c = 'Cancelled';
                                        objTask.Activity_Complete_Date__c=date.today();
                                    }
                                }
                                lstLog.add(oLog);
                                lstUpdateTask.add(objTask);
                            }

                            list<Event> lstUpdateEvent = new list<Event>();
                            
                            for (Event objEvent : (list<Event>)Database.query(strEventQuery)) if (!(objEvent.OwnerId==objRB.Reassign_To__c)){
                                Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = objRB.Reassign_To__c,
                                    Old_Owner_Id__c=objEvent.OwnerId,
                                    Reassignment_Batch__c=objRB.Id,
                                    Record_Id__c=objEvent.Id);
                                lstLog.add(oLog);
                                objEvent.OwnerId=objRB.Reassign_To__c;
                                if (objRB.Close_Past_Due_Activities__c){
                                    if (objEvent.ActivityDate<date.today()){
                                        list<OldValue> lstOldValue = new list<OldValue>();
                                        lstOldValue.add(new OldValue('Result_Code__c','String',objEvent.Result_Code__c));
                                        lstOldValue.add(new OldValue('Activity_Complete_Date__c','Date',objEvent.Activity_Complete_Date__c));
                                        oLog.Old_Values__c = JSON.serialize(lstOldValue);
                                        objEvent.Result_Code__c = 'Cancelled';
                                        objEvent.Activity_Complete_Date__c=date.today();
                                    }
                                }
                                lstUpdateEvent.add(objEvent);
                            }

                            list<Contact> lstUpdateContact = new list<Contact>();
                            list<Account> lstUpdateAccount = new list<Account>();

                            if (objRB.Reassign_Activities_Only__c==null || objRB.Reassign_Activities_Only__c==false){
                                
                                if (!lstContact.isEmpty()) for (Contact objCont : lstContact) if (!(objCont.OwnerId==objRB.Reassign_To__c)){
                                    boolean skip = false;
                                    if (string.isNotBlank(objRB.Current_Owner__c)) if (objRB.Current_Owner__c!=objCont.OwnerId) skip = true;
                                    if (!skip){
                                        Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = objRB.Reassign_To__c,
                                            Old_Owner_Id__c=objCont.OwnerId,
                                            Reassignment_Batch__c=objRB.Id,
                                            Record_Id__c=objCont.Id);
                                        lstLog.add(oLog);
                                        objCont.OwnerId=objRB.Reassign_To__c;
                                        lstUpdateContact.add(objCont);
                                    }
                                }

                                for (Account objAcc : [SELECT Id, OwnerId FROM Account WHERE Id IN :lstObjId]) if (!(objAcc.OwnerId==objRB.Reassign_To__c)){
                                    boolean skip = false;
                                    if (string.isNotBlank(objRB.Current_Owner__c)) if (objRB.Current_Owner__c!=objAcc.OwnerId) skip = true;
                                    if (!skip){
                                        Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = objRB.Reassign_To__c,
                                            Old_Owner_Id__c=objAcc.OwnerId,
                                            Reassignment_Batch__c=objRB.Id,
                                            Record_Id__c=objAcc.Id, Account__c=objAcc.Id);
                                        lstLog.add(oLog);
                                        objAcc.OwnerId=objRB.Reassign_To__c;
                                        lstUpdateAccount.add(objAcc);
                                    }
                                }
                            }

                            if (!lstLog.isEmpty()) insert lstLog;
                            if (!lstUpdateTask.isEmpty()) update lstUpdateTask;
                            if (!lstUpdateEvent.isEmpty()) update lstUpdateEvent;
                            if (!lstUpdateContact.isEmpty()) update lstUpdateContact;
                            if (!lstUpdateAccount.isEmpty()) update lstUpdateAccount;
                            
                        }
                        else if (('Opportunity').equalsIgnoreCase(objRB.Object_Name__c)){
                            ReassignOpps(lstObjId, objRB);
                        }
                        else if (('OpportunityByCampaign').equalsIgnoreCase(objRB.Object_Name__c)){
                            set<Id> setOppId = new set<Id>();
                            for (OpportunityContactRole objOcr : [SELECT OpportunityId FROM OpportunityContactRole WHERE OpportunityId != null AND ContactId IN :lstObjId])
                                setOppId.add(objOcr.OpportunityId);
                            if (!setOppId.isEmpty()) ReassignOpps(new list<Id>(setOppId),objRB);
                        }
                        objRB.Status__c='In Progress';
                        update objRB;
                    }
                    catch(Exception exc){
                        string strMessage = '';
                        if (string.isNotBlank(objRB.Message__c)) strMessage = objRB.Message__c + '\r\n';
                        strMessage += 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
                        objRB.Status__c = 'ERROR';
                        update objRB;
                        system.debug(strMessage);
                    }
                }
        }
    }

    private static void ReassignOpps(list<Id> lstObjId, Reassignment_Batch__c objRB){
        List<Opportunity> lstUpdateOpp = new List<Opportunity>();
        List<Account> lstUpdateAccount = new List<Account>();
        List<Contact> lstUpdateContact = new List<Contact>();
        list<Reassignment_Log__c> lstLog = new list<Reassignment_Log__c>();
        list<Task> lstUpdateTask = new list<Task>();
        list<Event> lstUpdateEvent = new list<Event>();
        list<Id> lstOppId = new list<Id>();
        list<Id> lstAccId = new list<Id>();
        map<Id,Id> mapOppNewOwner = new map<Id,Id>();
        map<Id,Id> mapAccOpp = new map<Id,Id>();
        set<Id> setPContId = new set<Id>();
        for (Opportunity objOpp : [SELECT Id, Accountid, Primary_Household__c, Reporting_Community__c, Reporting_Community__r.Primary_User_for_Community__c, OwnerId FROM Opportunity WHERE Id IN :lstObjId]){
            Boolean skip = false;
            if (string.isNotBlank(objRB.Community__c)) if (!(objRB.Community__c==objOpp.Reporting_Community__c)) skip = true;
            if (!skip){
                Id NewOwnerId = null;
                if (objRb.Assign_To_Default_Community_User__c)
                    if (string.isNotBlank(objOpp.Reporting_Community__c))
                        if (string.isNotBlank(objOpp.Reporting_Community__r.Primary_User_for_Community__c))
                            NewOwnerId = objOpp.Reporting_Community__r.Primary_User_for_Community__c;
                if (string.isBlank(NewOwnerId)) NewOwnerId = objRB.Reassign_To__c;
                if (string.isBlank(NewOwnerId)) NewOwnerId = objOpp.OwnerId;
                //lstOpp.add(objOpp);
                lstOppId.add(objOpp.Id);
                mapOppNewOwner.put(objOpp.Id,NewOwnerId);
                if (string.isNotBlank(objOpp.AccountId)) {
                    lstAccId.add(objOpp.AccountId);
                    mapAccOpp.put(objOpp.AccountId,objOpp.Id);
                }
                if (string.isNotBlank(objOpp.Primary_Household__c)) {
                    lstAccId.add(objOpp.Primary_Household__c);
                    mapAccOpp.put(objOpp.Primary_Household__c,objOpp.Id);
                }
                if (objRb.Assign_To_Default_Community_User__c){
                    if (string.isNotBlank(objOpp.Reporting_Community__c)) 
                        if (!(objOpp.OwnerId==objOpp.Reporting_Community__r.Primary_User_for_Community__c))
                            if (string.isNotBlank(objRB.Current_Owner__c)) 
                                if (objRB.Current_Owner__c!=objOpp.OwnerId) skip = true;
                }
                else if (!(objOpp.OwnerId==objRB.Reassign_To__c))
                    if (string.isNotBlank(objRB.Current_Owner__c)) 
                        if (objRB.Current_Owner__c!=objOpp.OwnerId) skip = true;
                if (!skip)
                    if (objRB.Reassign_Activities_Only__c==null || objRB.Reassign_Activities_Only__c==false){
                        Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = NewOwnerId,
                            Old_Owner_Id__c=objOpp.OwnerId,
                            Reassignment_Batch__c=objRB.Id,
                            Record_Id__c=objOpp.Id, Opportunity__c=objOpp.Id);
                        lstLog.add(oLog);
                        objOpp.OwnerId=NewOwnerId;
                        lstUpdateOpp.add(objOpp);
                    }
            }
        }
        if (!lstAccId.isEmpty()) for (Account objAcc : [SELECT Id, OwnerId, PersonContactId FROM Account WHERE Id IN :lstAccId]){
            if (string.isNotBlank(objAcc.PersonContactId)) 
                setPContId.add(objAcc.PersonContactId);
            Boolean skip = false;
            if (mapAccOpp.containsKey(objAcc.Id)) if (mapOppNewOwner.containsKey(mapAccOpp.get(objAcc.Id)))
            if (!(objAcc.OwnerId==mapOppNewOwner.get(mapAccOpp.get(objAcc.Id))))
                if (string.isNotBlank(objRB.Current_Owner__c)) 
                    if (objRB.Current_Owner__c!=objAcc.OwnerId) skip = true;
            if (!skip)
                if (objRB.Reassign_Activities_Only__c==null || objRB.Reassign_Activities_Only__c==false){
                    Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = mapOppNewOwner.get(mapAccOpp.get(objAcc.Id)),
                        Old_Owner_Id__c=objAcc.OwnerId,
                        Reassignment_Batch__c=objRB.Id,
                        Record_Id__c=objAcc.Id, Account__c=objAcc.Id);
                    lstLog.add(oLog);
                    objAcc.OwnerId=mapOppNewOwner.get(mapAccOpp.get(objAcc.Id));
                    lstUpdateAccount.add(objAcc);
                }
        }
        if (!lstOppId.isEmpty()){
            map<Id,Id> mapContOpp = new map<Id,Id>();
            list<Id> lstContId = new list<Id>();
            for (OpportunityContactRole objOcr : [SELECT Id, ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :lstOppId AND ContactId!=null]){
                if (!setPContId.contains(objOcr.ContactId)) lstContId.add(objOcr.ContactId);
                mapContOpp.put(objOcr.ContactId,objOcr.OpportunityId);
            }
            if (!lstContId.isEmpty())
            for (Contact objCont : [SELECT Id, OwnerId FROM Contact WHERE Id IN :lstContId]){
                Boolean skip = false;
                if (mapContOpp.containsKey(objCont.Id)) if (mapOppNewOwner.containsKey(mapContOpp.get(objCont.Id)))
                if (!(objCont.OwnerId==mapOppNewOwner.get(mapContOpp.get(objCont.Id))))
                    if (string.isNotBlank(objRB.Current_Owner__c)) 
                        if (objRB.Current_Owner__c!=objCont.OwnerId) skip = true;
                if (!skip)
                    if (objRB.Reassign_Activities_Only__c==null || objRB.Reassign_Activities_Only__c==false){
                        Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = mapOppNewOwner.get(mapContOpp.get(objCont.Id)),
                            Old_Owner_Id__c=objCont.OwnerId,
                            Reassignment_Batch__c=objRB.Id,
                            Record_Id__c=objCont.Id);
                        lstLog.add(oLog);
                        objCont.OwnerId=mapOppNewOwner.get(mapContOpp.get(objCont.Id));
                        lstUpdateContact.add(objCont);
                    }
            }

            string strTaskQuery = 'SELECT Id, WhatId, WhoId, OwnerId, ActivityDate, Activity_Complete_Date__c, Result_Code__c, Status FROM Task WHERE Is_Pending__c = true ';
            strTaskQuery += ' AND (WhatId IN :lstOppId) ';
            if (string.isNotBlank(objRB.Current_Owner__c)) strTaskQuery += ' AND OwnerId = \'' + Id.valueOf(string.valueOf(objRB.Current_Owner__c)) + '\' ';
            if (objRB.Activity_Start_Date__c!=null) strTaskQuery += ' AND ActivityDate >= '+Datetime.newInstance(objRB.Activity_Start_Date__c.year(),objRB.Activity_Start_Date__c.month(),objRB.Activity_Start_Date__c.day()).format('yyyy-MM-dd')+' ';
            if (objRB.Activity_End_Date__c!=null) strTaskQuery += ' AND ActivityDate <= '+Datetime.newInstance(objRB.Activity_End_Date__c.year(),objRB.Activity_End_Date__c.month(),objRB.Activity_End_Date__c.day()).format('yyyy-MM-dd')+' ';

            string strEventQuery = 'SELECT Id, WhatId, WhoId, OwnerId, ActivityDate, Activity_Complete_Date__c, Result_Code__c FROM Event WHERE Is_Pending__c = true ';
            strEventQuery += ' AND (WhatId IN :lstOppId) ';
            if (string.isNotBlank(objRB.Current_Owner__c)) strEventQuery += ' AND OwnerId = \'' + Id.valueOf(string.valueOf(objRB.Current_Owner__c)) + '\' ';
            if (objRB.Activity_Start_Date__c!=null) strEventQuery += ' AND ActivityDate >= '+Datetime.newInstance(objRB.Activity_Start_Date__c.year(),objRB.Activity_Start_Date__c.month(),objRB.Activity_Start_Date__c.day()).format('yyyy-MM-dd')+' ';
            if (objRB.Activity_End_Date__c!=null) strEventQuery += ' AND ActivityDate <= '+Datetime.newInstance(objRB.Activity_End_Date__c.year(),objRB.Activity_End_Date__c.month(),objRB.Activity_End_Date__c.day()).format('yyyy-MM-dd')+' ';

            for (Task objTask : (list<Task>)Database.query(strTaskQuery)) 
            if (!(objTask.OwnerId==mapOppNewOwner.get(objTask.WhatId))){
                Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = mapOppNewOwner.get(objTask.WhatId),
                    Old_Owner_Id__c=objTask.OwnerId,
                    Reassignment_Batch__c=objRB.Id,
                    Record_Id__c=objTask.Id);
                lstLog.add(oLog);
                objTask.OwnerId=mapOppNewOwner.get(objTask.WhatId);
                if (objRB.Close_Past_Due_Activities__c){
                    if (objTask.ActivityDate<date.today()){
                        list<OldValue> lstOldValue = new list<OldValue>();
                        lstOldValue.add(new OldValue('Status','String',objTask.Status));
                        lstOldValue.add(new OldValue('Result_Code__c','String',objTask.Result_Code__c));
                        lstOldValue.add(new OldValue('Activity_Complete_Date__c','Date',objTask.Activity_Complete_Date__c));
                        oLog.Old_Values__c = JSON.serialize(lstOldValue);
                        objTask.Status = 'Completed';
                        objTask.Result_Code__c = 'Cancelled';
                        objTask.Activity_Complete_Date__c=date.today();
                    }
                }
                lstUpdateTask.add(objTask);
            }
            
            for (Event objEvent : (list<Event>)Database.query(strEventQuery)) 
            if (!(objEvent.OwnerId==mapOppNewOwner.get(objEvent.WhatId))){
                Reassignment_Log__c oLog = new Reassignment_Log__c(New_Owner__c = mapOppNewOwner.get(objEvent.WhatId),
                    Old_Owner_Id__c=objEvent.OwnerId,
                    Reassignment_Batch__c=objRB.Id,
                    Record_Id__c=objEvent.Id);
                lstLog.add(oLog);
                objEvent.OwnerId=mapOppNewOwner.get(objEvent.WhatId);
                if (objRB.Close_Past_Due_Activities__c){
                    if (objEvent.ActivityDate<date.today()){
                        list<OldValue> lstOldValue = new list<OldValue>();
                        lstOldValue.add(new OldValue('Result_Code__c','String',objEvent.Result_Code__c));
                        lstOldValue.add(new OldValue('Activity_Complete_Date__c','Date',objEvent.Activity_Complete_Date__c));
                        objEvent.Result_Code__c = 'Cancelled';
                        objEvent.Activity_Complete_Date__c=date.today();
                    }
                }
                lstUpdateEvent.add(objEvent);
            }
        }
        if (!lstLog.isEmpty()) insert lstLog;
        if (!lstUpdateTask.isEmpty()) update lstUpdateTask;
        if (!lstUpdateEvent.isEmpty()) update lstUpdateEvent;
        if (!lstUpdateContact.isEmpty()) update lstUpdateContact;
        if (!lstUpdateAccount.isEmpty()) update lstUpdateAccount;
        if (!lstUpdateOpp.isEmpty()) update lstUpdateOpp;

    }

    @AuraEnabled
    public static ReassignHelperFormParam GetFormParam(string wrapperText){
        ReassignHelperFormParam sourceParam = null;
        system.debug('wrapperText:'+wrapperText);
        sourceParam=(ReassignHelperFormParam)JSON.deserialize(wrapperText,ReassignHelperFormParam.class);
        system.debug('sourceParam:'+sourceParam);
        ReassignHelperFormParam retParam;
        integer intStep = 0;
        system.debug(sourceParam);
        if (sourceParam!=null) if (sourceParam.step!=null) if (sourceParam.step>0)
            intStep = sourceParam.step;
        system.debug(intStep);
        if (intStep==0) retParam = GetFirstFormParam();
        else if (intStep==1) retParam = GetSecondFormParam(sourceParam);
        else if (intStep==2) retParam = GetThirdFormParam(sourceParam);
        else if (intStep==3) retParam = GetFourthFormParam(sourceParam);
        else if (intStep==4) retParam = GetFifthFormParam(sourceParam);
        else retParam = sourceParam;
        return retParam;
    }

    private static ReassignHelperFormParam GetFifthFormParam(ReassignHelperFormParam FourthFormParam){
        ReassignHelperFormParam retParam = new ReassignHelperFormParam();
        try{
        retParam.step = 5;
        retParam.objectName = FourthFormParam.objectName;
        retParam.reassignActivitiesOnly = FourthFormParam.reassignActivitiesOnly;
        retParam.closePastDueActivities = FourthFormParam.closePastDueActivities;
        retParam.assignToDefaultCommunityUser = FourthFormParam.assignToDefaultCommunityUser;
        retParam.reassignToId = FourthFormParam.reassignToId;
        retParam.campaignId = FourthFormParam.campaignId;
        retParam.searchName = FourthFormParam.searchName;
        retParam.currentOwnerId = FourthFormParam.currentOwnerId;
        retParam.communityId = FourthFormParam.communityId;
        retParam.activityStartDate = FourthFormParam.activityStartDate;
        retParam.activityEndDate = FourthFormParam.activityEndDate;
        retParam.whereCondition = FourthFormParam.whereCondition;
        Reassignment_Batch__c rb = new Reassignment_Batch__c(Status__c = 'Started',
            Object_Name__c = FourthFormParam.objectName,
            Search_Name__c = FourthFormParam.searchName,
            Where_Condition__c = FourthFormParam.whereCondition);
        if (string.isNotBlank(FourthFormParam.reassignToId)) rb.Reassign_To__c = Id.valueOf(FourthFormParam.reassignToId);
        if (string.isNotBlank(FourthFormParam.campaignId)) rb.Campaign__c = Id.valueOf(FourthFormParam.campaignId);
        if (string.isNotBlank(FourthFormParam.currentOwnerId)) rb.Current_Owner__c = Id.valueOf(FourthFormParam.currentOwnerId);
        if (string.isNotBlank(FourthFormParam.communityId)) rb.Community__c = Id.valueOf(FourthFormParam.communityId);
        if (FourthFormParam.reassignActivitiesOnly==true){ 
            rb.Reassign_Activities_Only__c = true;
            if (retParam.activityStartDate!=null) 
                rb.Activity_Start_Date__c = retParam.activityStartDate;
            if (retParam.activityEndDate!=null) 
                rb.Activity_End_Date__c = retParam.activityEndDate;
        }
        if (FourthFormParam.closePastDueActivities==true) rb.Close_Past_Due_Activities__c = true;
        if (FourthFormParam.assignToDefaultCommunityUser==true) rb.Assign_To_Default_Community_User__c = true;
        insert rb;
        retParam.ReassignmentBatchId = rb.Id;
        ReassignHelper oReassignHelper   = new ReassignHelper(rb.Id,false); 
        Database.executeBatch(oReassignHelper, 10);
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }

    private static ReassignHelperFormParam GetFourthFormParam(ReassignHelperFormParam ThirdFormParam){
        ReassignHelperFormParam retParam = new ReassignHelperFormParam();
        //retParam.sourceParam = ThirdFormParam;
        retParam.step = 4;
        retParam.objectName = ThirdFormParam.objectName;
        retParam.reassignActivitiesOnly = ThirdFormParam.reassignActivitiesOnly;
        retParam.closePastDueActivities = ThirdFormParam.closePastDueActivities;
        retParam.assignToDefaultCommunityUser = ThirdFormParam.assignToDefaultCommunityUser;
        retParam.reassignToId = ThirdFormParam.reassignToId;
        retParam.campaignId = ThirdFormParam.campaignId;
        retParam.searchName = ThirdFormParam.searchName;
        retParam.paramFields = new list<ReassignHelperFormParamParamField>();
        try{
        list<string> lstError = new list<string>();
        if (!ThirdFormParam.paramFields.isEmpty()) for (ReassignHelperFormParamParamField pf : ThirdFormParam.paramFields) if (string.isNotBlank(pf.fieldValue)){
            if (pf.fieldName.equalsIgnoreCase('CurrentOwnerId')) 
                retParam.currentOwnerId = pf.fieldValue;
            else if (pf.fieldName.equalsIgnoreCase('CommunityId')) 
                retParam.communityId = pf.fieldValue;
            else if (pf.fieldName.equalsIgnoreCase('ActivityStartDate')) 
                retParam.activityStartDate = ParseDate(pf.fieldValue);
            else if (pf.fieldName.equalsIgnoreCase('ActivityEndDate')) 
                retParam.activityEndDate = ParseDate(pf.fieldValue);
        }
        string Reassign_Records = ThirdFormParam.objectName;
        if ((('Account').equalsIgnoreCase(Reassign_Records))||(('Opportunity').equalsIgnoreCase(Reassign_Records))){
            list<string> lstCondition = new list<string>();
            if (!ThirdFormParam.paramFields.isEmpty()) for (ReassignHelperFormParamParamField pf : ThirdFormParam.paramFields) if (string.isNotBlank(pf.fieldValue))
            if (!pf.fieldName.equalsIgnoreCase('CurrentOwnerId')) if (!pf.fieldName.equalsIgnoreCase('CommunityId')) if (!pf.fieldName.equalsIgnoreCase('ActivityStartDate')) if (!pf.fieldName.equalsIgnoreCase('ActivityEndDate')){
                string strFldValue = '';
                if (pf.fieldType.equalsIgnoreCase('DATE')){
                    date dt = ParseDate(pf.fieldValue);
                    if (dt==null) lstError.add(pf.fieldLabel + ' field value is Invalid.');
                    else strFldValue = Datetime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd');
                }
                else if (pf.fieldType.equalsIgnoreCase('DATETIME')){
                    datetime dtt = ParseDateTime(pf.fieldValue);
                    if (dtt==null){
                        date dt = ParseDate(pf.fieldValue);
                        if (dt!= null ) dtt = Datetime.newInstance(dt.year(),dt.month(),dt.day());
                    }
                    if (dtt==null) lstError.add(pf.fieldLabel + ' field value is Invalid.');
                    else strFldValue = dtt.format('yyyy-MM-dd HH:mm:ss','GMT').replace(' ','T') + 'z';
                }
                else if (pf.fieldType.equalsIgnoreCase('BOOLEAN')){
                    if (ParseBoolean(pf.fieldValue)) strFldValue = 'true';
                    else strFldValue = 'false';
                }
                else if (pf.fieldType.equalsIgnoreCase('NUMBER')){
                    string temp = ParseNumber(pf.fieldValue);
                    if (string.isNotBlank(temp)) strFldValue = temp;
                    else lstError.add(pf.fieldLabel + ' field value is Invalid.');
                }
                else strFldValue = '\''+string.escapeSingleQuotes(pf.fieldValue.trim())+'\'';
                if (string.isNotBlank(strFldValue)){
                    string strOp = '=';
                    if (string.isNotBlank(pf.operator)) strOp = pf.operator;
                    string strCond = '( '+pf.fieldName+ ' ' + strOp + ' ' + strFldValue + ' )';
                    lstCondition.add(strCond);
                }
            }
            if (lstError.isEmpty()){
                string strSearch_Object = 'Referral Account';
                string strObject = 'Account';
                Map<String, Schema.SObjectField> ffmap;
                if (('Opportunity').equalsIgnoreCase(Reassign_Records)){ 
                    strSearch_Object = 'Opportunity';
                    strObject = 'Opportunity';
                    ffmap = Schema.SObjectType.Opportunity.fields.getMap();
                }
                else ffmap = Schema.SObjectType.Account.fields.getMap();
                for (Reassign_Search_Criteria__mdt rsc : [SELECT Search_Name__c, Field_Label__c, Field_Name__c, Field_Value__c, 
                Operator__c, Search_Object__c FROM Reassign_Search_Criteria__mdt WHERE Search_Object__c = :strSearch_Object AND Search_Name__c = :retParam.searchName AND (Field_Value__c != '' AND Field_Value__c != null) ORDER BY Sort_Value__c]){
                    if (ffmap.containsKey(rsc.Field_Name__c.tolowercase())){
                        Schema.SObjectField oField = ffmap.get(rsc.Field_Name__c.tolowercase());
                        Schema.DescribeFieldResult oFieldDesc = oField.getDescribe();
                        Schema.DisplayType oFieldType = oFieldDesc.getType();
                        string strFldValue = '';
                        if (oFieldType==Schema.DisplayType.BOOLEAN){
                            if (ParseBoolean(rsc.Field_Value__c)) strFldValue = 'true';
                            else strFldValue = 'false';
                        }
                        else if (oFieldType==Schema.DisplayType.PICKLIST){
                            if ('<<null>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = 'null';
                            else strFldValue = '\''+string.escapeSingleQuotes(rsc.Field_Value__c.trim())+'\'';
                        }
                        else if (oFieldType==Schema.DisplayType.DATE){
                            if ('<<null>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = 'null';
                            else if ('<<today>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = Datetime.newInstance(Date.today().year(),Date.today().month(),Date.today().day()).format('yyyy-MM-dd');
                            else{
                                date dt = ParseDate(rsc.Field_Value__c);
                                if (dt==null) lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                                else strFldValue = Datetime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd');
                            }
                        }
                        else if (oFieldType==Schema.DisplayType.DATETIME){
                            if ('<<null>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = 'null';
                            else if ('<<today>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = Datetime.newInstance(Date.today().year(),Date.today().month(),Date.today().day()).format('yyyy-MM-dd');
                            else{
                                datetime dtt = ParseDateTime(rsc.Field_Value__c);
                                if (dtt==null){
                                    date dt = ParseDate(rsc.Field_Value__c);
                                    if (dt!= null ) dtt = Datetime.newInstance(dt.year(),dt.month(),dt.day());
                                }
                                if (dtt==null) lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                                else strFldValue = dtt.format('yyyy-MM-dd HH:mm:ss','GMT').replace(' ','T') + 'z';
                            }
                        }
                        else if ((oFieldType==Schema.DisplayType.CURRENCY)||(oFieldType==Schema.DisplayType.DOUBLE)||(oFieldType==Schema.DisplayType.INTEGER)||(oFieldType==Schema.DisplayType.LONG)||(oFieldType==Schema.DisplayType.PERCENT)){
                            if ('<<null>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = 'null';
                            else{
                                string temp = ParseNumber(rsc.Field_Value__c);
                                if (string.isNotBlank(temp)) strFldValue = temp;
                                else lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                            }
                        }
                        else if ('<<null>>'.equalsIgnoreCase(rsc.Field_Value__c)) strFldValue = 'null';
                        else strFldValue = '\''+string.escapeSingleQuotes(rsc.Field_Label__c.trim())+'\'';

                        if (string.isNotBlank(strFldValue)){
                            string strOp = '=';
                            if (string.isNotBlank(rsc.Operator__c)) strOp = rsc.Operator__c;
                            string strCond = '( '+rsc.Field_Value__c+ ' ' + strOp + ' ' + strFldValue + ' )';
                            lstCondition.add(strCond);
                        }
                        
                    }
                }
            }
            if (lstError.isEmpty()) if (!lstCondition.isEmpty()){
                integer n = lstCondition.size();
                string strCondition = '(';
                for (integer i =0;i<n;i++){
                    string s = (i==(n-1))?')':' AND ';
                    strCondition += (lstCondition.get(i)+s);
                }
                retParam.whereCondition = strCondition;
            }
        }
        if (!lstError.isEmpty()){
            retParam.step = 99;
            retParam.message = 'ERROR: ' + String.join(lstError,' <br/>\r\n');
            return retParam;
        }
        else{
            string strMsg = '<b>Please confirm following parameters for running of Resassign Batch Process:</b> <br/>\r\n';
            if (string.isNotBlank(retParam.objectName)) 
                strMsg += '\t &nbsp;&nbsp;&nbsp; Object : <b>' + retParam.objectName + '</b> <br/>\r\n';
            if (retParam.reassignActivitiesOnly!=null) 
                if (retParam.reassignActivitiesOnly) 
                    strMsg += '\t &nbsp;&nbsp;&nbsp; Reassign Activities Only : <b>' + 'Yes' + '</b> <br/>\r\n';
            if (retParam.closePastDueActivities!=null) 
                if (retParam.closePastDueActivities) 
                    strMsg += '\t &nbsp;&nbsp;&nbsp; Close Past Due Activities : <b>' + 'Yes' + '</b> <br/>\r\n';
            if (retParam.assignToDefaultCommunityUser!=null) 
                if (retParam.assignToDefaultCommunityUser) 
                    strMsg += '\t &nbsp;&nbsp;&nbsp; Assign To Default Community User : <b>' + 'Yes' + '</b> <br/>\r\n';
            if (string.isNotBlank(retParam.reassignToId)) {
                //strMsg += '\t &nbsp;&nbsp;&nbsp; Reassign To User Id : <b>' + retParam.reassignToId + '</b> <br/>\r\n';
                for (User ru : [SELECT Name FROM User WHERE Id = :retParam.reassignToId])
                    strMsg += '\t &nbsp;&nbsp;&nbsp; Reassign To User : <b>' + ru.Name + '</b> <br/>\r\n';
            }
            if (string.isNotBlank(retParam.campaignId)){
                //strMsg += '\t &nbsp;&nbsp;&nbsp; Campaign Id : <b>' + retParam.campaignId + '</b> <br/>\r\n';
                for (Campaign cmp : [SELECT Name FROM Campaign WHERE Id = :retParam.campaignId])
                    strMsg += '\t &nbsp;&nbsp;&nbsp; Campaign : <b>' + cmp.Name + '</b> <br/>\r\n';
            }
            if (string.isNotBlank(retParam.searchName)) 
                strMsg += '\t &nbsp;&nbsp;&nbsp; Search Name : <b>' + retParam.searchName + '</b> <br/>\r\n';
            if (ThirdFormParam!=null) 
                if (ThirdFormParam.paramFields!=null)
                    if (!ThirdFormParam.paramFields.isEmpty())
                        for (ReassignHelperFormParamParamField pf : ThirdFormParam.paramFields) if (string.isNotBlank(pf.fieldValue)){
                            if (pf.fieldName.equalsIgnoreCase('CurrentOwnerId')){
                                for (User ru : [SELECT Name FROM User WHERE Id = :pf.fieldValue])
                                    strMsg += '\t &nbsp;&nbsp;&nbsp; Current Owner : <b>' + ru.Name + '</b> <br/>\r\n';
                            }
                            else if (pf.fieldName.equalsIgnoreCase('CommunityId')){
                                for (Community__c ru : [SELECT Name FROM Community__c WHERE Id = :pf.fieldValue])
                                    strMsg += '\t &nbsp;&nbsp;&nbsp; Community : <b>' + ru.Name + '</b> <br/>\r\n';
                            }
                            else{
                                strMsg += '\t &nbsp;&nbsp;&nbsp; '+pf.fieldLabel+' : <b>' + pf.fieldValue + '</b> <br/>\r\n';
                            }
                        }
            //if (string.isNotBlank(retParam.whereCondition)) strMsg += '<br/>\r\n\t &nbsp;&nbsp;&nbsp; SOQL Where Condition : <b>' + retParam.whereCondition + '</b> <br/>\r\n';
            retParam.message = strMsg;
        }
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }

    private static date ParseDate(string strVal){
        date retDt = null;
        try{retDt=date.valueOf(strVal);}catch(Exception exc){}
        if (retDt==null) try{retDt=date.parse(strVal);}catch(Exception exc){}
        if (retDt==null) try{retDt = (Date)JSON.deserialize('"'+strVal+'"', Date.class);}catch(Exception exc){}
        return retDt;
    }
    private static dateTime ParseDateTime(string strVal){
        dateTime retDt = null;
        try{retDt=dateTime.valueOf(strVal);}catch(Exception exc){}
        if (retDt==null) try{retDt=dateTime.parse(strVal);}catch(Exception exc){}
        if (retDt==null) try{retDt = (DateTime)JSON.deserialize('"'+strVal+'"', DateTime.class);}catch(Exception exc){}
        return retDt;
    }
    private static boolean ParseBoolean(string strVal){
        boolean retDt = false;
        if (string.isNotBlank(strVal)) if (('Y'.equalsIgnoreCase(strVal))||('Yes'.equalsIgnoreCase(strVal))||('1'.equalsIgnoreCase(strVal))||('true'.equalsIgnoreCase(strVal))) retDt = true;
        return retDt;
    }
    private static string ParseNumber(string strVal){
        double d1 = null;
        integer i1 = null;
        try{d1=double.valueOf(strVal);}catch(Exception exc){}
        try{i1=integer.valueOf(strVal);}catch(Exception exc){}
        if ((d1==null)&&(i1==null)) return null;
        else return strVal;
    }

    private static ReassignHelperFormParam GetThirdFormParam(ReassignHelperFormParam SecondFormParam){
        ReassignHelperFormParam retParam = new ReassignHelperFormParam();
        retParam.sourceParam = SecondFormParam;
        retParam.step = 3;
        retParam.objectName = SecondFormParam.objectName;
        retParam.reassignActivitiesOnly = SecondFormParam.reassignActivitiesOnly;
        retParam.closePastDueActivities = SecondFormParam.closePastDueActivities;
        retParam.assignToDefaultCommunityUser = SecondFormParam.assignToDefaultCommunityUser;
        retParam.reassignToId = SecondFormParam.reassignToId;
        retParam.paramFields = new list<ReassignHelperFormParamParamField>();
        integer intP = 1;
        string Reassign_Records = SecondFormParam.objectName;
        try{
        ReassignHelperFormParamParamField p1 = new ReassignHelperFormParamParamField();
        p1.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p1.fieldLabel = 'Current Owner';
        p1.fieldName = 'CurrentOwnerId';
        p1.fieldType = 'PICKLIST';
        p1.SetType();
        p1.operator = '=';
        p1.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        for (User u: [SELECT Id, Name, Username FROM User ORDER BY Name]) {
            boolean flag = false;
            if ((string.isBlank(retParam.reassignToId))||('<Default>'.equalsIgnoreCase(retParam.reassignToId)))
                flag = true;
            else if (u.Id!=Id.valueOf(retParam.reassignToId))
                flag = true;
            if (flag)
                p1.picklistOptions.add(new ReassignHelperFormParamComboItem(u.Name + ' (' + u.Username + ')', Id.valueOf(string.valueOf(u.Id))));
        }
        p1.picklistOptions.add(0,new ReassignHelperFormParamComboItem('<All>',''));
        p1.fieldValue = '';
        retParam.paramFields.add(p1);
        if (!(('Account').equalsIgnoreCase(Reassign_Records))){
            ReassignHelperFormParamParamField p2 = new ReassignHelperFormParamParamField();
            p2.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
            p2.fieldLabel = 'Community';
            p2.fieldName = 'CommunityId';
            p2.fieldType = 'PICKLIST';
            p2.SetType();
            p2.operator = '=';
            p2.picklistOptions = new list<ReassignHelperFormParamComboItem>();
            for (Community__c u: [SELECT Id, Name FROM Community__c WHERE Name != 'ALL' ORDER BY Name])
                p2.picklistOptions.add(new ReassignHelperFormParamComboItem(u.Name, Id.valueOf(string.valueOf(u.Id))));
            p2.picklistOptions.add(0,new ReassignHelperFormParamComboItem('<All>',''));
            p2.fieldValue = '';
            retParam.paramFields.add(p2);
        }
        if (retParam.reassignActivitiesOnly==true){
            ReassignHelperFormParamParamField pa1 = new ReassignHelperFormParamParamField();
            pa1.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
            pa1.fieldLabel = 'Activity Start Date';
            pa1.fieldName = 'ActivityStartDate';
            pa1.fieldType = 'DATE';
            pa1.SetType();
            pa1.operator = '=';
            pa1.fieldValue = '';
            retParam.paramFields.add(pa1);
            ReassignHelperFormParamParamField pa2 = new ReassignHelperFormParamParamField();
            pa2.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
            pa2.fieldLabel = 'Activity End Date';
            pa2.fieldName = 'ActivityEndDate';
            pa2.fieldType = 'DATE';
            pa2.SetType();
            pa2.operator = '=';
            pa2.fieldValue = '';
            retParam.paramFields.add(pa2);
        }
        
        if ((('Account').equalsIgnoreCase(Reassign_Records))||(('Opportunity').equalsIgnoreCase(Reassign_Records))){
            string Search_Name = '';
            if (!SecondFormParam.paramFields.isEmpty()) for (ReassignHelperFormParamParamField pf : SecondFormParam.paramFields){
                if (pf.fieldName.equalsIgnoreCase('Search_Name'))
                    Search_Name = pf.fieldValue;
            }
            if (string.isNotBlank(Search_Name)){
                retParam.searchName = Search_Name;
                string strSearch_Object = 'Referral Account';
                string strObject = 'Account';
                Map<String, Schema.SObjectField> ffmap;
                if (('Opportunity').equalsIgnoreCase(Reassign_Records)){ 
                    strSearch_Object = 'Opportunity';
                    strObject = 'Opportunity';
                    ffmap = Schema.SObjectType.Opportunity.fields.getMap();
                }
                else ffmap = Schema.SObjectType.Account.fields.getMap();
                for (Reassign_Search_Criteria__mdt rsc : [SELECT Search_Name__c, Field_Label__c, Field_Name__c, Field_Value__c, Operator__c, Search_Object__c, Sort_Value__c FROM Reassign_Search_Criteria__mdt WHERE Search_Object__c = :strSearch_Object AND Search_Name__c = :Search_Name AND (Field_Value__c = '' OR Field_Value__c = null) ORDER BY Sort_Value__c]){
                    if (ffmap.containsKey(rsc.Field_Name__c.tolowercase())){
                        Schema.SObjectField oField = ffmap.get(rsc.Field_Name__c.tolowercase());
                        Schema.DescribeFieldResult oFieldDesc = oField.getDescribe();
                        Schema.DisplayType oFieldType = oFieldDesc.getType();
                        ReassignHelperFormParamParamField p3 = new ReassignHelperFormParamParamField();
                        p3.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
                        p3.fieldLabel = rsc.Field_Label__c;
                        p3.fieldName = oFieldDesc.getName();
                        p3.operator = rsc.Operator__c;
                        if (string.isNotBlank(p3.operator)) if (!p3.operator.trim().equalsIgnoreCase('=')) p3.fieldLabel += (' '+p3.operator);
                        if (oFieldType==Schema.DisplayType.BOOLEAN)
                            p3.fieldType = 'BOOLEAN';
                        else if (oFieldType==Schema.DisplayType.PICKLIST)
                            p3.fieldType = 'PICKLIST';
                        else if (oFieldType==Schema.DisplayType.DATETIME)
                            p3.fieldType = 'DATETIME';
                        else if ((oFieldType==Schema.DisplayType.CURRENCY)||(oFieldType==Schema.DisplayType.DOUBLE)||(oFieldType==Schema.DisplayType.INTEGER)||(oFieldType==Schema.DisplayType.LONG)||(oFieldType==Schema.DisplayType.PERCENT))
                            p3.fieldType = 'NUMBER';
                        else if (oFieldType==Schema.DisplayType.DATE)
                            p3.fieldType = 'DATE';
                        else p3.fieldType = 'TEXT';
                        p3.SetType();
                        if (p3.fieldType == 'PICKLIST'){
                            List<Schema.PicklistEntry> ple = oFieldDesc.getPicklistValues();
                            p3.picklistOptions = new list<ReassignHelperFormParamComboItem>();
                            p3.picklistOptions.add(new ReassignHelperFormParamComboItem('',''));
                            for( Schema.PicklistEntry pickListVal : ple)
                                p3.picklistOptions.add(new ReassignHelperFormParamComboItem(pickListVal.getLabel(),pickListVal.getValue()));
                        }
                        else if (p3.fieldType == 'BOOLEAN'){
                            List<Schema.PicklistEntry> ple = oFieldDesc.getPicklistValues();
                            p3.picklistOptions = new list<ReassignHelperFormParamComboItem>();
                            p3.picklistOptions.add(new ReassignHelperFormParamComboItem('No','false'));
                            p3.picklistOptions.add(new ReassignHelperFormParamComboItem('Yes','true'));
                        }
                        p3.fieldValue = '';
                        retParam.paramFields.add(p3);
                    }
                    else{
                        retParam.step = 99;
                        retParam.message = 'ERROR: ' + rsc.Field_Name__c + ' field is Not present in ' + strObject;
                        return retParam;
                    }
                }
            }
            else{
                retParam.step = 99;
                retParam.message = 'ERROR: Search Name is blank.';
                return retParam;
            }
        }
        else if ((('OpportunityByCampaign').equalsIgnoreCase(Reassign_Records))){
            if (!SecondFormParam.paramFields.isEmpty()) for (ReassignHelperFormParamParamField pf : SecondFormParam.paramFields){
                if (pf.fieldName.equalsIgnoreCase('Campaign')){
                    retParam.campaignId = pf.fieldValue;
                }
            }
        }
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }

    private static ReassignHelperFormParam GetSecondFormParam(ReassignHelperFormParam firstFormParam){
        ReassignHelperFormParam retParam = new ReassignHelperFormParam();
        retParam.sourceParam = firstFormParam;
        retParam.step = 2;
        retParam.paramFields = new list<ReassignHelperFormParamParamField>();
        integer intP = 1;
        try{
        string Reassign_Records = '';
        if (firstFormParam!=null) if (firstFormParam.paramFields!=null) if (!firstFormParam.paramFields.isEmpty())
        for (ReassignHelperFormParamParamField pf : firstFormParam.paramFields){
            if (pf.fieldName.equalsIgnoreCase('Reassign_Records')){
                retParam.message = '';
                Reassign_Records = pf.fieldValue;
                pf.picklistOptions.clear();
            }
            else if (pf.fieldName.equalsIgnoreCase('Reassign_To')){
                pf.picklistOptions.clear();
                if (string.isNotBlank(pf.fieldValue)){
                    if ('<Default>'.equalsIgnoreCase(pf.fieldValue)) retParam.assignToDefaultCommunityUser = true;
                    else retParam.reassignToId = pf.fieldValue;
                }
            }
            else if (pf.fieldName.equalsIgnoreCase('Activities_Only')){
                if (string.isNotBlank(pf.fieldValue)) if ((pf.fieldValue.equalsIgnoreCase('true'))||(pf.fieldValue.equalsIgnoreCase('yes'))||(pf.fieldValue.equalsIgnoreCase('1')))
                    retParam.reassignActivitiesOnly = true;
            }
            else if (pf.fieldName.equalsIgnoreCase('ClosePastDueActivities')){
                if (string.isNotBlank(pf.fieldValue)) if ((pf.fieldValue.equalsIgnoreCase('true'))||(pf.fieldValue.equalsIgnoreCase('yes'))||(pf.fieldValue.equalsIgnoreCase('1')))
                    retParam.closePastDueActivities = true;
            }
        }
        if ((('Account').equalsIgnoreCase(Reassign_Records))||(('Opportunity').equalsIgnoreCase(Reassign_Records))){
            retParam.objectName = Reassign_Records;
            set<string> setSeachName = new set<string>();
            list<string> lstSeachName = new list<string>();
            string strSearch_Object = 'Referral Account';
            if (('Opportunity').equalsIgnoreCase(Reassign_Records)) strSearch_Object = 'Opportunity';
            else if (retParam.assignToDefaultCommunityUser==true){
                retParam.message = 'Error: Cannot select \'Default Community User\' for reassigning Referral Orgs/Contacts.';
                retParam.step = 99;
                return retParam;
            }
            retParam.message = 'Please select search option for ' + strSearch_Object + '.';
            for (Reassign_Search_Criteria__mdt rsc : [SELECT Search_Name__c FROM Reassign_Search_Criteria__mdt WHERE Search_Object__c = :strSearch_Object ORDER BY Search_Name__c])
            if (string.isNotBlank(rsc.Search_Name__c)) if (!setSeachName.contains(rsc.Search_Name__c.trim().toUpperCase())){
                setSeachName.add(rsc.Search_Name__c.trim().toUpperCase());
                lstSeachName.add(rsc.Search_Name__c.trim());
            }
            if (!lstSeachName.isEmpty()){
                ReassignHelperFormParamParamField p3 = new ReassignHelperFormParamParamField();
                p3.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
                p3.fieldLabel = 'Search Name';
                p3.fieldName = 'Search_Name';
                p3.fieldType = 'PICKLIST';
                p3.SetType();
                p3.operator = '';
                p3.picklistOptions = new list<ReassignHelperFormParamComboItem>();
                for (string s: lstSeachName)
                    p3.picklistOptions.add(new ReassignHelperFormParamComboItem(s,s));
                p3.fieldValue = lstSeachName.get(0);
                retParam.paramFields.add(p3);
            }
        }
        else if ((('OpportunityByCampaign').equalsIgnoreCase(Reassign_Records))){
            retParam.objectName = Reassign_Records;
            retParam.message = 'Please select search parameters.';
            ReassignHelperFormParamParamField p3 = new ReassignHelperFormParamParamField();
            p3.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
            p3.fieldLabel = 'Campaign';
            p3.fieldName = 'Campaign';
            p3.fieldType = 'PICKLIST';
            p3.SetType();
            p3.operator = '';
            p3.picklistOptions = new list<ReassignHelperFormParamComboItem>();
            for (Campaign c: [SELECT Id, Name FROM Campaign ORDER By Name LIMIT 500])
                p3.picklistOptions.add(new ReassignHelperFormParamComboItem(c.Name,c.Id));
            p3.fieldValue = p3.picklistOptions.get(0).value;
            retParam.paramFields.add(p3);
        }
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }
    
    private static ReassignHelperFormParam GetFirstFormParam(){
        ReassignHelperFormParam retParam = new ReassignHelperFormParam();
        retParam.message = 'Please select reassignment parameters.';
        retParam.step = 1;
        retParam.paramFields = new list<ReassignHelperFormParamParamField>();
        integer intP = 1;
        try{
        ReassignHelperFormParamParamField p1 = new ReassignHelperFormParamParamField();
        p1.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p1.fieldLabel = 'Reassign Records';
        p1.fieldName = 'Reassign_Records';
        p1.fieldType = 'PICKLIST';
        p1.SetType();
        p1.operator = '';
        p1.fieldValue = 'Account';
        p1.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        p1.picklistOptions.add(new ReassignHelperFormParamComboItem('Referral Orgs/Contacts','Account'));
        p1.picklistOptions.add(new ReassignHelperFormParamComboItem('Opportunities','Opportunity'));
        p1.picklistOptions.add(new ReassignHelperFormParamComboItem('Opportunities by Campaign','OpportunityByCampaign'));
        retParam.ParamFields.add(p1);

        ReassignHelperFormParamParamField p2 = new ReassignHelperFormParamParamField();
        p2.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p2.fieldLabel = 'Reassign Related Activities Only';
        p2.fieldName = 'Activities_Only';
        p2.fieldType = 'BOOLEAN';
        p2.SetType();
        p2.operator = '';
        p2.fieldValue = 'false';
        p2.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        p2.picklistOptions.add(new ReassignHelperFormParamComboItem('No','false'));
        p2.picklistOptions.add(new ReassignHelperFormParamComboItem('Yes','true'));
        retParam.paramFields.add(p2);

        ReassignHelperFormParamParamField p21 = new ReassignHelperFormParamParamField();
        p21.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p21.fieldLabel = 'Close Past Due Activities';
        p21.fieldName = 'ClosePastDueActivities';
        p21.fieldType = 'BOOLEAN';
        p21.SetType();
        p21.operator = '';
        p21.fieldValue = 'false';
        p21.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        p21.picklistOptions.add(new ReassignHelperFormParamComboItem('No','false'));
        p21.picklistOptions.add(new ReassignHelperFormParamComboItem('Yes','true'));
        retParam.paramFields.add(p21);

        ReassignHelperFormParamParamField p3 = new ReassignHelperFormParamParamField();
        p3.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p3.fieldLabel = 'Reassign To';
        p3.fieldName = 'Reassign_To';
        p3.fieldType = 'PICKLIST';
        p3.SetType();
        p3.operator = '';
        p3.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        Id currUserId = UserInfo.getUserId();
        string currUserName = '';
        for (User u: [SELECT Id, Name, Username FROM User Where IsActive = true OR Id = :currUserId ORDER BY Name]){
            if (u.Id==currUserId) currUserName = u.Name + ' (' + u.Username + ')';
            else p3.picklistOptions.add(new ReassignHelperFormParamComboItem(u.Name + ' (' + u.Username + ')',Id.valueOf(string.valueOf(u.Id))));
        }
        p3.picklistOptions.add(0,new ReassignHelperFormParamComboItem(currUserName,Id.valueOf(string.valueOf(currUserId))));
        p3.fieldValue = Id.valueOf(string.valueOf(currUserId));
        p3.picklistOptions.add(new ReassignHelperFormParamComboItem('< Default Community User >','<Default>'));
        retParam.paramFields.add(p3);
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }

    private class OldValue{
        public string FieldName;
        public string FieldType;
        public string FieldValue;
        public OldValue(string pFieldName, string pFieldType, object pFieldValue){
            this.FieldName=pFieldName;
            this.FieldType=pFieldType;
            if (pFieldValue!=null) this.FieldValue=string.valueOf(pFieldValue);
            else this.FieldValue='';
        }
    }
}