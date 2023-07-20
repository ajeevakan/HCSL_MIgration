public without sharing class TLGJsonInterface{
    
    @AuraEnabled
    public static string ReSubmit(Id SubId){
        try{
            if (string.isNotBlank(SubId)){
                for (TLG_Integration_Submission__c sub : [SELECT Id, Interface_Name__c, json__c, Processed__c, Error__c, Error_Description__c, RecordId__c FROM TLG_Integration_Submission__c WHERE Id = :SubId AND (Processed__c = false OR Processed__c = null) LIMIT 1]){
                    Id RecordId = null;
                    boolean isError = false;
                    string strErrorDesc = null;
                    wrapProcessInfo objProcessInfo = new wrapProcessInfo();
                    try{
                      /*if (('CaringUpdate').equalsIgnoreCase(sub.Interface_Name__c))
                  objProcessInfo = CaringUpdateProcess( 'CARING',  sub.json__c);
                  else */
                    objProcessInfo = Process( sub.Interface_Name__c,  sub.json__c);
                  RecordId = objProcessInfo.RecordId;
                    }
                    catch(Exception ex){
                        isError = true;strErrorDesc = 'Exception: ' + ex.getTypeName()   + '\r\n' + 
                                     'Line at: ' + ex.getLineNumber() + '\r\n' +
                                     'Message: ' + ex.getMessage()  + '\r\n' +
                                     'Stack Trace: ' + ex.getStackTraceString();
                        
                        system.debug(strErrorDesc);
                    }
                    if (RecordId==null){
                        if (!isError){
                            isError = true;
                            strErrorDesc = string.isBlank(objProcessInfo.ErrorDesc)?'Could Not process json string.':objProcessInfo.ErrorDesc;
                        }
                    }
                    else
                        sub.Processed__c = true;
                    sub.Error__c=isError;
                    sub.Error_Description__c=strErrorDesc;
                    sub.RecordId__c=RecordId;
                    upsert sub;
                }
            }
        }
        catch(Exception ex){return 'Exception: ' + ex.getTypeName()   + '\r\n' + 
                         'Line at: ' + ex.getLineNumber() + '\r\n' +
                         'Message: ' + ex.getMessage()  + '\r\n' +
                         'Stack Trace: ' + ex.getStackTraceString();}
        return '';
    }
    
    public static TLG_Integration_Submission__c Submit(string strInterfaceName, string strJson){
        TLG_Integration_Submission__c sub = new TLG_Integration_Submission__c(Interface_Name__c = strInterfaceName, json__c = strJson);
        Id RecordId = null;
        boolean isError = false;
        string strErrorDesc = null;
        wrapProcessInfo objProcessInfo = new wrapProcessInfo();
        try{
         /* if (('CaringUpdate').equalsIgnoreCase(strInterfaceName))
            objProcessInfo = CaringUpdateProcess( 'CARING',  strJson);
            else */
              objProcessInfo = Process( strInterfaceName,  strJson);
            RecordId = objProcessInfo.RecordId;
        }
        catch(Exception ex){
            isError = true;strErrorDesc = 'Exception: ' + ex.getTypeName()   + '\r\n' + 
                         'Line at: ' + ex.getLineNumber() + '\r\n' +
                         'Message: ' + ex.getMessage()  + '\r\n' +
                         'Stack Trace: ' + ex.getStackTraceString();

            system.debug(strErrorDesc);
        }
        if (RecordId==null){
            if (!isError){
                isError = true;
                strErrorDesc = string.isBlank(objProcessInfo.ErrorDesc)?'Could Not process json string.':objProcessInfo.ErrorDesc;

            }
        }
        else
            sub.Processed__c = true;
        sub.Error__c=isError;
        sub.Error_Description__c=strErrorDesc;
        sub.RecordId__c=RecordId;
        insert sub;
        return sub;
    }
    
    /*private static Id GetOwnerId(Id leadId, Id AccId){
        try{
        string strUserKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
        //if (string.isNotBlank(OwnerId))
        //  if ((string.valueOf(OwnerId.getsobjecttype()).equalsIgnoreCase('User')))
        //      return OwnerId;
        if (string.isNotBlank(AccId)){
            for (Account objAcc : [SELECT Id, OwnerId, Owner.IsActive, Reporting_Community__c, Reporting_Community__r.Primary_User_for_Community__c, Reporting_Community__r.Primary_User_for_Community__r.IsActive, Reporting_Community__r.OwnerId, Reporting_Community__r.Owner.IsActive FROM Account WHERE Id = :AccId]){
                if (string.isNotBlank(objAcc.OwnerId))
                    if (string.valueOf(objAcc.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                      if (objAcc.Owner.IsActive)
                        return objAcc.OwnerId;
//                if (string.isNotBlank(objAcc.Reporting_Community__c))
//                    if (string.isNotBlank(objAcc.Reporting_Community__r.Primary_User_for_Community__c))
//                      if (string.valueOf(objAcc.Reporting_Community__r.Primary_User_for_Community__c).startswithIgnoreCase(strUserKeyPrefix))
//                        if (objAcc.Reporting_Community__r.Primary_User_for_Community__r.IsActive)
//                          return objAcc.Reporting_Community__r.Primary_User_for_Community__c;
//                if (string.isNotBlank(objAcc.Reporting_Community__c))
//                    if (string.isNotBlank(objAcc.Reporting_Community__r.OwnerId))
//                      if (string.valueOf(objAcc.Reporting_Community__r.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
//                        if (objAcc.Reporting_Community__r.Owner.IsActive)
//                          return objAcc.Reporting_Community__r.OwnerId;
            }
        }
        if (string.isNotBlank(leadId)){
            for (Lead objLead : [SELECT Id, OwnerId, Owner.IsActive, Reporting_Community__c, Reporting_Community__r.Primary_User_for_Community__c, Reporting_Community__r.Primary_User_for_Community__r.IsActive, Reporting_Community__r.OwnerId, Reporting_Community__r.Owner.IsActive FROM Lead WHERE Id = :leadId]){
                if (string.isNotBlank(objLead.OwnerId))
                    if (string.valueOf(objLead.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
                      if (objLead.Owner.IsActive)
                        return objLead.OwnerId;
//                if (string.isNotBlank(objLead.Reporting_Community__c))
//                    if (string.isNotBlank(objLead.Reporting_Community__r.Primary_User_for_Community__c))
//                      if (string.valueOf(objLead.Reporting_Community__r.Primary_User_for_Community__c).startswithIgnoreCase(strUserKeyPrefix))
//                        if (objLead.Reporting_Community__r.Primary_User_for_Community__r.IsActive)
//                          return objLead.Reporting_Community__r.Primary_User_for_Community__c;
//                if (string.isNotBlank(objLead.Reporting_Community__c))
//                    if (string.isNotBlank(objLead.Reporting_Community__r.OwnerId))
//                      if (string.valueOf(objLead.Reporting_Community__r.OwnerId).startswithIgnoreCase(strUserKeyPrefix))
//                        if (objLead.Reporting_Community__r.Owner.IsActive)
//                          return objLead.Reporting_Community__r.OwnerId;
            }
        }
        return userInfo.getUserId();
        }catch(Exception exc){
            system.debug(exc);
            return userInfo.getUserId();
        }
    }*/
    
    /*private static wrapProcessInfo CaringUpdateProcess(string strInterfaceName, string strJson){
      wrapProcessInfo objReturn = new wrapProcessInfo();
      objReturn.RecordId=null;
        string strInterface_Lead_Id_Field = 'lead_id';
        string strSFDC_External_Id_Field = 'Unique_Caring_Lead_Id__c';
        string strSFDC_Account_External_Id_Field = 'Unique_Caring_Lead_Id__c';
        TLG_Json_Interface__mdt interfaceMdt = [SELECT MasterLabel, DeveloperName, Interface_Lead_Id_Field__c, SFDC_External_Id_Field__c, SFDC_Account_External_Id_Field__c FROM TLG_Json_Interface__mdt WHERE DeveloperName = :strInterfaceName];
        if (interfaceMdt!=null){
            if (string.isNotBlank(interfaceMdt.Interface_Lead_Id_Field__c))
                strInterface_Lead_Id_Field = interfaceMdt.Interface_Lead_Id_Field__c.trim();
            if (string.isNotBlank(interfaceMdt.SFDC_External_Id_Field__c))
                strSFDC_External_Id_Field = interfaceMdt.SFDC_External_Id_Field__c.trim();
            if (string.isNotBlank(interfaceMdt.SFDC_Account_External_Id_Field__c))
                strSFDC_Account_External_Id_Field = interfaceMdt.SFDC_Account_External_Id_Field__c.trim();
            
        }
      try{
      Map<String, Object> mapSource = (Map<String, Object>)JSON.deserializeUntyped(strJson);
      if (mapSource!=null)
          if (!mapSource.isEmpty()){
            if (mapSource.containsKey(strInterface_Lead_Id_Field)){
              string leadId = (string.valueOf(mapSource.get(strInterface_Lead_Id_Field)));
                    Id sfdcLeadId = null;
              Id owner_Id = null;
              if (string.isNotBlank(leadId)){
                Id accId = null;
                        Id contId = null;
                boolean leadFound=false;
                        for (lead ld : (list<lead>)database.query('SELECT Id, OwnerId, IsConverted, ConvertedAccountid, ConvertedContactid, '+strSFDC_External_Id_Field+', ConvertedAccount.OwnerId FROM Lead WHERE '+strSFDC_External_Id_Field+' = :leadId LIMIT 1')){
                            if (ld.IsConverted){
                                if (string.isNotBlank(ld.ConvertedAccountid)){
                                    accId = ld.ConvertedAccountid;
                                    owner_Id = ld.ConvertedAccount.OwnerId;
                                    contId = ld.ConvertedContactid;
                                }
                                //for (Account acc : (list<Account>)database.query('SELECT Id, OwnerId, ' + strSFDC_Account_External_Id_Field + ' FROM Account WHERE ' + strSFDC_Account_External_Id_Field + ' = :leadId LIMIT 1')){
                                //    accId = acc.Id;
                                //    owner_Id = acc.OwnerId;
                                //}
                            }
                            else
                              owner_Id = ld.OwnerId;
//                  if (string.isNotblank(ld.ConvertedAccountId)){
//                    accId = ld.ConvertedAccountId;
//                    owner_Id = ld.ConvertedAccount.OwnerId;
//                  }
                            sfdcLeadId = ld.Id;
                  leadFound = true;
                }
                if (leadFound){
                  string strActivityDescription = '';
                  if (mapSource.containsKey('tour_date'))
                    if (string.isNotBlank(string.valueOf(mapSource.get('tour_date')))){
                      strActivityDescription += (strInterfaceName + ' scheduled a Tour for you on ' + string.valueOf(mapSource.get('tour_date')));
                      if (mapSource.containsKey('tour_time'))
                        if (string.isNotBlank(string.valueOf(mapSource.get('tour_time'))))
                          strActivityDescription += (' at ' + string.valueOf(mapSource.get('tour_time')));
                      strActivityDescription += '.\r\n';
                    }
                  if (mapSource.containsKey('notes'))
                    if (string.isNotBlank(string.valueOf(mapSource.get('notes'))))
                      strActivityDescription += (string.valueOf(mapSource.get('notes'))+'\r\n');
                  if (mapSource.containsKey('note'))
                    if (string.isNotBlank(string.valueOf(mapSource.get('note'))))
                      strActivityDescription += (string.valueOf(mapSource.get('note'))+'\r\n');
                  list<string> lstfld = new list<string>();
                  for (string strFld : mapSource.keySet())
                    if (!((('tour_date').equalsIgnoreCase(strFld))||(('tour_time').equalsIgnoreCase(strFld))||(('notes').equalsIgnoreCase(strFld))||(('note').equalsIgnoreCase(strFld))||(('lead_id').equalsIgnoreCase(strFld))))
                      lstfld.add(strFld);
                  if (!lstfld.isEmpty()){
                    strActivityDescription += 'Received following fields update from referral source.\r\n';
                    for (string strFld : lstfld)
                      strActivityDescription += (strFld + ': ' + string.valueOf(mapSource.get(strFld)) + '\r\n');
                  }
                  //system.debug(Owner_Id);
                  Owner_Id = GetOwnerId(sfdcLeadId,accId);
                            if (string.isNotBlank(Owner_Id))
                              if (!(string.valueOf(Owner_Id.getsobjecttype()).equalsIgnoreCase('User'))) 
                                  Owner_Id = userInfo.getUserId();
                  Task t = new Task(Activity_Type__C = 'Update from Referral Source', Subject = 'Update from Referral Source',  
                            Description = strActivityDescription, ActivityDate = date.today(), Status = 'Not Started',OwnerId=Owner_Id);
                            if (string.isNotBlank(accId)){
                  t.whatId = accId;
                                t.whoId = contId;
                            }
                else t.whoId = sfdcLeadId;
                insert t;
                objReturn.RecordId=t.Id;
                }
                else{
                  objReturn.ErrorDesc='Lead record Not found with Id: ' + leadId;
                }
              }
              else{
                objReturn.ErrorDesc=strInterface_Lead_Id_Field+' value is Not present in the update message.';
              }
            }
            else{
              objReturn.ErrorDesc=strInterface_Lead_Id_Field+' value is Not present in the update message.';
            }
          }
      }
      catch(exception ex){
        objReturn.ErrorDesc= 'Exception: ' + ex.getTypeName()   + '\r\n' + 
                         'Line at: ' + ex.getLineNumber() + '\r\n' +
                         'Message: ' + ex.getMessage()  + '\r\n' +
                         'Stack Trace: ' + ex.getStackTraceString();
            system.debug(objReturn.ErrorDesc);
      }
    return objReturn;
    }*/
    
    private static wrapProcessInfo Process(string strInterfaceName, string strJson){
      wrapProcessInfo objReturn = new wrapProcessInfo();
      objReturn.RecordId=null;
        TLG_Json_Interface__mdt interfaceMdt = [SELECT MasterLabel, DeveloperName, Target_Object__c, Lead_Source__c, Referral_Org_Code__c, Referral_Organization_Id__c, Duplicate_Check__c, Description_Field_in_Dup_Activity__c, Dup_Activity_Type__c FROM TLG_Json_Interface__mdt WHERE DeveloperName = :strInterfaceName];
        if (interfaceMdt!=null){
            list<TLG_Json_Interface_Mapping__mdt> lstInterfaceMapping = new list<TLG_Json_Interface_Mapping__mdt>();
            for (TLG_Json_Interface_Mapping__mdt mdt : [SELECT Json_Interface_Name__c, DeveloperName, Is_Unique__c, Source_Field__c, Target_Field__c, Translation_Object__c, Translation_Value_Field__c, Trnaslation_Match_Field__c, Hardcoded_Value__c, Duplicate_Check__c, Duplicate_Check_Condition__c FROM TLG_Json_Interface_Mapping__mdt WHERE Json_Interface_Name__c = :strInterfaceName]){
                lstInterfaceMapping.add(mdt);
            }
            if (!lstInterfaceMapping.isEmpty()){
                Map<String, Object> mapSource = (Map<String, Object>)JSON.deserializeUntyped(strJson);
                if (mapSource!=null)
                    if (!mapSource.isEmpty()){
                        Schema.SObjectType targetSObjectType = null;
                        String[] types = new String[]{interfaceMdt.Target_Object__c};
                        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
                        for(Schema.DescribeSobjectResult res : results) {
                            if (res.getName().equalsIgnoreCase(interfaceMdt.Target_Object__c))
                                targetSObjectType = res.getSobjectType();
                        }
                        if (targetSObjectType!=null){
                            Map<String, Schema.SObjectField> targetSObjectFields = targetSObjectType.getDescribe().fields.getMap();
                            Map<String, Object> mapTarget = new Map<String, Object>();
                            for (TLG_Json_Interface_Mapping__mdt mdt : lstInterfaceMapping){
                                Object TargetValue = null;
                                if (string.isBlank(mdt.Hardcoded_Value__c)){
                                  if (mapSource.containsKey(mdt.Source_Field__c)) 
                                      if (mapSource.get(mdt.Source_Field__c)!=null){
                                          if (string.isBlank(mdt.Translation_Object__c)){
                                            TargetValue = GetTargetValue( targetSObjectFields,  mdt,  mapSource.get(mdt.Source_Field__c));
//                                              if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DATETIME)
//                                                  TargetValue = makeDatetime(string.valueOf(mapSource.get(mdt.Source_Field__c)));
//                                              else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DATE)
//                                                  TargetValue = makeDate(string.valueOf(mapSource.get(mdt.Source_Field__c)));
//                                              else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.INTEGER)
//                                                  TargetValue = Integer.valueOf(mapSource.get(mdt.Source_Field__c));
//                                              else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DOUBLE)
//                                                  TargetValue = Double.valueOf(mapSource.get(mdt.Source_Field__c));
//                                              else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.BOOLEAN)
//                                                  TargetValue = Boolean.valueOf(mapSource.get(mdt.Source_Field__c));
//                                              else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.CURRENCY)
//                                                  TargetValue = Double.valueOf(mapSource.get(mdt.Source_Field__c));
//                                              else
//                                                  TargetValue = (mapSource.get(mdt.Source_Field__c));
                                          }
                                          else{
                                              string strQuery = 'SELECT ' + mdt.Translation_Value_Field__c + ', ' + mdt.Trnaslation_Match_Field__c + ' FROM ' + mdt.Translation_Object__c + ' WHERE ' + mdt.Trnaslation_Match_Field__c + ' = \'' + string.valueOf(mapSource.get(mdt.Source_Field__c)) + '\' LIMIT 1';
                                              //Debug by Anand
                                              system.debug('strQuery 1' + strQuery);
                                              for (sObject sobjT : database.query(strQuery))
                                                  TargetValue = sobjT.get(mdt.Translation_Value_Field__c);
                                          }
                                      }
//                                  if (TargetValue!=null){
//                                      mapTarget.put(mdt.Target_Field__c,TargetValue);
//                                  }
                                }
                                else{
                                  if (string.isBlank(mdt.Translation_Object__c))
                                    TargetValue = GetTargetValue( targetSObjectFields,  mdt,  mdt.Hardcoded_Value__c);
                                  else{
                                    string strQuery = 'SELECT ' + mdt.Translation_Value_Field__c + ', ' + mdt.Trnaslation_Match_Field__c + ' FROM ' + mdt.Translation_Object__c + ' WHERE ' + mdt.Trnaslation_Match_Field__c + ' = \'' + string.valueOf(mdt.Hardcoded_Value__c) + '\' LIMIT 1';
                                    //Debug by Anand
                                  system.debug('strQuery 1' + strQuery);
                                        for (sObject sobjT : database.query(strQuery))
                                            TargetValue = sobjT.get(mdt.Translation_Value_Field__c);
                                  }
                                }
                                if (TargetValue!=null){
                                    mapTarget.put(mdt.Target_Field__c,TargetValue);
                                }
                            }
                            Id TargetId = FindTargetId(interfaceMdt, lstInterfaceMapping, mapTarget);
                            string strDupMsg = '';
                            /*if (string.isBlank(TargetId))
                              strDupMsg = GetDupMsg(interfaceMdt, lstInterfaceMapping, mapTarget);*/
                            if (string.isBlank(strDupMsg)){
                              
                              sObject TargetObject;
                              if (TargetId!=null)
                                  TargetObject = targetSObjectType.newSObject(TargetId);
                              else
                                  TargetObject = targetSObjectType.newSObject();
                              for (string strFld : mapTarget.keySet()) {
                                  try {
                                  TargetObject.put(strFld, mapTarget.get(strFld));
                                  } catch (Exception exc) {}
                                  }
                              
                              //// Hard Code Lead Source and Referral Org  
                              //if (string.isNotBlank(interfaceMdt.Lead_Source__c))
                              //  TargetObject.put('LeadSource', interfaceMdt.Lead_Source__c);
                              //if (string.isNotBlank(interfaceMdt.Referral_Organization_Id__c))   
                              //  TargetObject.put('Referral_Organization__c', interfaceMdt.Referral_Organization_Id__c);   
                              
                              // Company - COMMENT OUT FOR HEALTH CLOUD OR PERSON ACCOUNT 
                           //   TargetObject.put('Company', 'Computed on Convert');   
                                  
                              // Run Assignment Rules    
                              Database.DMLOptions dmo = new Database.DMLOptions();
                              dmo.assignmentRuleHeader.useDefaultRule= true;    
                              
                              // Do not process duplicate rules
                              dmo.DuplicateRuleHeader.allowSave = true;
                                    
                              TargetObject.setOptions(dmo);system.debug(TargetObject);
                                if (string.isBlank(TargetId)){
                                insert TargetObject;
                                  objReturn.RecordId=TargetObject.Id;
                                }
                                else{
                                    if (!(strInterfaceName.toUpperCase().contains('CARING')))
                                      try{upsert TargetObject;}Catch(Exception exc){}
                                    else{
                                        system.debug(TargetId);
                                        TargetId=Id.valueOf(TargetId);
                                    }
                                    objReturn.RecordId=TargetId;
                                }
                            }
                            else objReturn.ErrorDesc=strDupMsg;
                            return objReturn;
                        }
                    }
            }
        }
        return objReturn;
    }
    
    private static object GetTargetValue(Map<String, Schema.SObjectField> targetSObjectFields, TLG_Json_Interface_Mapping__mdt mdt, object objSourceValue){//mapSource.get(mdt.Source_Field__c)
      object TargetValue = null;
        try{
      if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DATETIME)
            TargetValue = makeDatetime(string.valueOf(objSourceValue));
        else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DATE)
            TargetValue = makeDate(string.valueOf(objSourceValue));
        else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.INTEGER)
            TargetValue = Integer.valueOf(objSourceValue);
        else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.DOUBLE)
            TargetValue = Double.valueOf(objSourceValue);
        else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.BOOLEAN)
            TargetValue = Boolean.valueOf(objSourceValue);
        else if(targetSObjectFields.get(mdt.Target_Field__c.toLowerCase()).getDescribe().getType() == Schema.DisplayType.CURRENCY)
            TargetValue = Double.valueOf(objSourceValue);
        else
            TargetValue = String.valueOf(objSourceValue);
        }catch(Exception exc){}
      return TargetValue;
    }

    private static Id FindTargetId(TLG_Json_Interface__mdt interfaceMdt, list<TLG_Json_Interface_Mapping__mdt> lstInterfaceMapping, Map<String, Object> mapTarget){
        list<string> lstCondition = new list<string>();
        for (TLG_Json_Interface_Mapping__mdt mdt : lstInterfaceMapping)
            if (mdt.Is_Unique__c)
                if (mapTarget.containsKey(mdt.Target_Field__c))
                    if (mapTarget.get(mdt.Target_Field__c)!=null){
                        string strCondition = ' AND ' + mdt.Target_Field__c + '=\'' + string.valueOf(mapTarget.get(mdt.Target_Field__c)) + '\' ';
                        lstCondition.add(strCondition);
                    }
        if (!lstCondition.isEmpty()){
            string strQuery = 'SELECT Id FROM ' + interfaceMdt.Target_Object__c + ' WHERE Id != Null ';
            for (string strCondition : lstCondition)
                strQuery += strCondition;
            strQuery += ' LIMIT 1';
            for (sObject sobjT : database.query(strQuery))
                return sobjT.Id;
        }
        return null;
    }
    
    /*private static string GetDupMsg(TLG_Json_Interface__mdt interfaceMdt, list<TLG_Json_Interface_Mapping__mdt> lstInterfaceMapping, Map<String, Object> mapTarget){
      string strRetVal='';
      Id dupId = null;
        Id accId = null;
        Id contId = null;
      Id OwnerId = null;
      if (interfaceMdt.Duplicate_Check__c){
        //Work_Phone__c, Home_Phone__c, MobilePhone, Email
        string pWorkPhone;
        string pHomePhone;
        string pMobilePhone;
        string pEmail;
        string pCommunity;
        if (mapTarget.containsKey('Community__c'))
          pCommunity = string.valueOf(mapTarget.get('Community__c'));
        if (mapTarget.containsKey('Work_Phone__c'))
          pWorkPhone = string.valueOf(mapTarget.get('Work_Phone__c'));
        if (mapTarget.containsKey('Home_Phone__c'))
          pHomePhone = string.valueOf(mapTarget.get('Home_Phone__c'));
        if (mapTarget.containsKey('MobilePhone'))
          pMobilePhone = string.valueOf(mapTarget.get('MobilePhone'));
        if (mapTarget.containsKey('Email'))
          pEmail = string.valueOf(mapTarget.get('Email'));
        wrapDupInfo objDupInfo = FoundDuplicate( pWorkPhone,  pHomePhone,  pMobilePhone,  pEmail,  pCommunity);
        if (string.isNotBlank(objDupInfo.RecordId)){
          dupId=objDupInfo.RecordId;
          strRetVal=objDupInfo.ErrorDesc;
          OwnerId = objDupInfo.OwnerId;
                if (string.isNotBlank(objDupInfo.accId)){
                    accId=objDupInfo.accId;
                    contId=objDupInfo.contId;
                }
        }
      }
      
      if (string.isBlank(strRetVal)){
        list<string> lstConditionAND = new list<string>();
        list<string> lstConditionOR = new list<string>();
        set<string> lstFlds = new set<string>();
        for (TLG_Json_Interface_Mapping__mdt mdt : lstInterfaceMapping)
              if (mdt.Duplicate_Check__c)
                  if (mapTarget.containsKey(mdt.Target_Field__c))
                      if (mapTarget.get(mdt.Target_Field__c)!=null){
                          string strCondition = ' ' + mdt.Target_Field__c + '=\'' + string.valueOf(mapTarget.get(mdt.Target_Field__c)) + '\' ';
                          if (('AND').equalsIgnoreCase(mdt.Duplicate_Check_Condition__c))
                            lstConditionAND.add(strCondition);
                          else
                            lstConditionOR.add(strCondition);
                          lstFlds.add(mdt.Target_Field__c);
                      }
          string strOR = '';
          if (!lstConditionOR.isEmpty()){
            strOR += '( ';
            integer n = lstConditionOR.size();
            integer i=1;
            for (string str : lstConditionOR){
              strOR += str;
              if (i<n)
                strOR += ' OR ';
              i += 1;
            }
            strOR += ') ';
            lstConditionAND.add(strOR);
          }
        if (!lstConditionAND.isEmpty()){
          string strFlds = '';
                if (('lead').equalsIgnoreCase(interfaceMdt.Target_Object__c)){
                    lstFlds.add('IsConverted');
                    lstFlds.add('ConvertedAccountId');
                    lstFlds.add('ConvertedContactId');
                }
                //IsConverted, ConvertedAccountId, ConvertedContactId, convertedaccount.ownerid
          for (string strF : lstFlds)
            strFlds += (', '+strF);
              string strQuery = 'SELECT Id, OwnerId '+strFlds+' FROM ' + interfaceMdt.Target_Object__c + ' WHERE Id != Null ';
              for (string strCondition : lstConditionAND)
                  strQuery += (' AND '+ strCondition);
              strQuery += ' LIMIT 1';
              for (sObject sobjT : database.query(strQuery)){
                dupId = Id.valueOf(string.valueOf(sobjT.get('Id')));
                OwnerId = Id.valueOf(string.valueOf(sobjT.get('OwnerId')));
                    if (('lead').equalsIgnoreCase(interfaceMdt.Target_Object__c))
                        if (boolean.valueOf(sobjT.get('IsConverted'))){
                            accId = Id.valueOf(string.valueOf(sobjT.get('ConvertedAccountId')));
                            contId = Id.valueOf(string.valueOf(sobjT.get('ConvertedContactId')));
                        }
                    
                if (string.isBlank(strRetVal))
                  for (TLG_Json_Interface_Mapping__mdt mdt : lstInterfaceMapping)
                    if (mdt.Duplicate_Check__c)if (mapTarget.containsKey(mdt.Target_Field__c))if (mapTarget.get(mdt.Target_Field__c)!=null)if (('OR').equalsIgnoreCase(mdt.Duplicate_Check_Condition__c))
                                if (string.valueOf(mapTarget.get(mdt.Target_Field__c)).equalsIgnoreCase(string.valueOf(sobjT.get(mdt.Target_Field__c)))){
                                  strRetVal = 'Duplicate found. Record with ' + mdt.Target_Field__c + ' equal to ' + string.valueOf(mapTarget.get(mdt.Target_Field__c)) + ' already exists.';
                                  break;
                                }
            if (string.isBlank(strRetVal))
                  for (TLG_Json_Interface_Mapping__mdt mdt : lstInterfaceMapping)
                    if (mdt.Duplicate_Check__c)
                        if (mapTarget.containsKey(mdt.Target_Field__c))if (mapTarget.get(mdt.Target_Field__c)!=null)
                              if (('AND').equalsIgnoreCase(mdt.Duplicate_Check_Condition__c))
                                if (string.valueOf(mapTarget.get(mdt.Target_Field__c)).equalsIgnoreCase(string.valueOf(sobjT.get(mdt.Target_Field__c)))){
                                  strRetVal = 'Duplicate found. Record with ' + mdt.Target_Field__c + ' equal to ' + string.valueOf(mapTarget.get(mdt.Target_Field__c)) + ' already exists.';
                                  break;
                                }
              if (string.isBlank(strRetVal))
                strRetVal = 'Duplicate found. Record Id: ' + sobjT.get('Id');
              }
          }
      }
      if (string.isNotBlank(strRetVal))
        if (string.isNotBlank(dupId)){
          string strActivityDesc = 'A new lead was submitted on ' + string.valueOf(date.today()) + ' by interface: ' + interfaceMdt.MasterLabel + ' .\r\n';
          if (string.isNotBlank(interfaceMdt.Description_Field_in_Dup_Activity__c))
            if (mapTarget.containsKey(interfaceMdt.Description_Field_in_Dup_Activity__c))
              strActivityDesc += (interfaceMdt.Description_Field_in_Dup_Activity__c+': '+string.valueOf(mapTarget.get(interfaceMdt.Description_Field_in_Dup_Activity__c)));
          string strActType = interfaceMdt.Dup_Activity_Type__c;
          if (string.isBlank(strActType)) strActType = 'Dup Found';
                OwnerId = GetOwnerId(dupId,accId);
          Task t = new Task(Activity_Type__C = strActType, Subject = strActType, 
                      Description = strActivityDesc, ActivityDate = date.today(), Status = 'Not Started',OwnerId=OwnerId);
          if (string.isNotBlank(accId)){
                    t.whatId = accId;
                    t.whoId = contId;
                }
                else t.whoId = dupId;
                insert t;
        }
      return strRetVal;
    }
    
    private static wrapDupInfo FoundDuplicate(string pWorkPhone, string pHomePhone, string pMobilePhone, string pEmail, string pCommunity){
        wrapDupInfo objReturn = new wrapDupInfo();
        objReturn.RecordId=null;
        objReturn.ErrorDesc='';
        ////IsConverted, ConvertedAccountId, ConvertedContactId, convertedaccount.ownerid
        string strQueryLead = 'SELECT OwnerId, WorkPhoneFormula__c, MobilePhoneFormula__c, HomePhoneFormula__c, FirstName, LastName, Work_Phone__c, Home_Phone__c, MobilePhone, Email, Id, Community_Interest__c, Community__c, IsConverted, ConvertedAccountId, ConvertedContactId FROM Lead WHERE ';
        string strQueryContact = 'SELECT OwnerId, WorkPhoneFormula__c, MobilePhoneFormula__c, HomePhoneFormula__c, FirstName, LastName, Work_Phone__c, HomePhone, MobilePhone, Email, Id, Account_Community__c FROM Contact WHERE ';
        string strWhere = '';
        if (!((pHomePhone==null) || (pHomePhone == ''))){
            string strHomePhoneFormula = pHomePhone.replaceAll('[\\D]','');
            if (!((strHomePhoneFormula==null) || (strHomePhoneFormula == ''))){
                //if (!((strWhere == '')))
                //  strWhere = strWhere + ' OR ';
                strWhere = strWhere + '(HomePhoneFormula__c = \''+strHomePhoneFormula+'\' OR MobilePhoneFormula__c = \''+strHomePhoneFormula+'\' OR WorkPhoneFormula__c = \''+strHomePhoneFormula+'\')';
            }
        }
        
        if (!((pMobilePhone==null) || (pMobilePhone == ''))){
            string strMobilePhoneFormula = pMobilePhone.replaceAll('[\\D]','');
            if (!((strMobilePhoneFormula==null) || (strMobilePhoneFormula == ''))){
                if (!((strWhere == '')))
                    strWhere = strWhere + ' OR ';
                strWhere = strWhere + '(MobilePhoneFormula__c = \''+strMobilePhoneFormula+'\' OR HomePhoneFormula__c = \''+strMobilePhoneFormula+'\' OR WorkPhoneFormula__c = \''+strMobilePhoneFormula+'\')';
            }
        }
        
        if (!((pWorkPhone==null) || (pWorkPhone == ''))){
            string strWorkPhoneFormula = pWorkPhone.replaceAll('[\\D]','');
            if (!((strWorkPhoneFormula==null) || (strWorkPhoneFormula == ''))){
                if (!((strWhere == '')))
                    strWhere = strWhere + ' OR ';
                strWhere = strWhere + '(WorkPhoneFormula__c = \''+strWorkPhoneFormula+'\' OR HomePhoneFormula__c = \''+strWorkPhoneFormula+'\' OR MobilePhoneFormula__c = \''+strWorkPhoneFormula+'\')';
            }
        }
        
        if (!((pEmail==null) || (pEmail == ''))){
            string strEmailFormula = pEmail.trim().toLowerCase();
            if (!((strEmailFormula==null) || (strEmailFormula == ''))){
                if (!((strWhere == '')))
                    strWhere = strWhere + ' OR ';
                strWhere = strWhere + '(Email = \''+string.escapeSingleQuotes(strEmailFormula)+'\')';
            }
        }
        if (string.isBlank(strWhere))
            return objReturn;
        
        if (string.isNotBlank(pCommunity)){
          strQueryLead = strQueryLead + ' Community__c = \''+ pCommunity + '\' AND (' + strWhere + ')  LIMIT 1 '; 
          strQueryContact = strQueryContact +  ' Account_Community__c = \''+ pCommunity + '\' AND (' + strWhere + ')  LIMIT 1 ';
        }
        else{
          strQueryLead = strQueryLead + ' (' + strWhere + ')  LIMIT 1 '; 
          strQueryContact = strQueryContact +  ' (' + strWhere + ')  LIMIT 1 ';
        }
            
        for (Lead objLead : (List<Lead>)Database.query(strQueryLead)){
            //return true;
            objReturn.RecordId=objLead.Id;
            objReturn.OwnerId=objLead.OwnerId;
            if (boolean.valueOf(objLead.get('IsConverted'))){
                objReturn.accId = Id.valueOf(string.valueOf(objLead.get('ConvertedAccountId')));
                objReturn.contId = Id.valueOf(string.valueOf(objLead.get('ConvertedContactId')));
            }
            if (string.isNotBlank(pEmail))
              if (pEmail.trim().equalsIgnoreCase(objLead.Email))
                objReturn.ErrorDesc='Duplicate lead found with email: ' + objLead.Email + ' and id: ' + objLead.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pHomePhone))if (pHomePhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objLead.HomePhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate lead found with Home Phone: ' + objLead.Home_Phone__c + ' and id: ' + objLead.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pMobilePhone))if (pMobilePhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objLead.MobilePhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate lead found with Mobile Phone: ' + objLead.MobilePhone + ' and id: ' + objLead.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pWorkPhone))if (pWorkPhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objLead.WorkPhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate lead found with Work Phone: ' + objLead.Work_Phone__c + ' and id: ' + objLead.Id;
        }
        
        if (objReturn.RecordId==null)
        for (Contact objContact : (List<Contact>)Database.query(strQueryContact)){
            //return true;
            objReturn.RecordId=objContact.Id;
            objReturn.OwnerId=objContact.OwnerId;
            ///
            if (string.isNotBlank(pEmail))
              if (pEmail.trim().equalsIgnoreCase(objContact.Email))
                objReturn.ErrorDesc='Duplicate Contact found with email: ' + objContact.Email + ' and id: ' + objContact.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pHomePhone))
                if (pHomePhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objContact.HomePhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate Contact found with Home Phone: ' + objContact.HomePhone + ' and id: ' + objContact.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pMobilePhone))
                if (pMobilePhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objContact.MobilePhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate Contact found with Mobile Phone: ' + objContact.MobilePhone + ' and id: ' + objContact.Id;
            if (string.isBlank(objReturn.ErrorDesc))
              if (string.isNotBlank(pWorkPhone))
                if (pWorkPhone.replaceAll('[\\D]','').trim().equalsIgnoreCase(objContact.WorkPhoneFormula__c))
                  objReturn.ErrorDesc='Duplicate Contact found with Work Phone: ' + objContact.Work_Phone__c + ' and id: ' + objContact.Id;
            ///
        }
        
        return objReturn;
    }*/

    private static date makeDate(String dateS){
        dateTime rDateTime = makeDateTime(dateS);
        if (rDateTime==null) return null;
        else return rDateTime.date();
    }
    
    private static string CorrectDateStr(String dateTimeS){
        string strRetVal = dateTimeS;
        //"5/30/2019 12:00:00 AM"
        if (string.isNotBlank(dateTimeS))
            if ((dateTimeS.right(3).equalsIgnoreCase(' AM'))||(dateTimeS.right(3).equalsIgnoreCase(' PM'))){
                integer intLoc = dateTimeS.indexOfIgnoreCase(':', 0);
                if (intLoc>0){
                    intLoc = dateTimeS.indexOfIgnoreCase(':', intLoc+1);
                    if (intLoc>0){
                        //substring(startIndex, endIndex)
                        integer intLoc1 = dateTimeS.indexOfIgnoreCase(' ', intLoc+1);
                        if (intLoc1>0){
                            integer n = dateTimeS.length();
                            strRetVal = dateTimeS.substring(0,intLoc)+dateTimeS.substring(intLoc1,n);
                        }
                    }
                }
            }
        return strRetVal;
    }

    private static dateTime makeDateTime(String pdateTimeS){
      if (string.isBlank(pdateTimeS)) return null;
        if (string.isBlank(pdateTimeS.trim())) return null;
            String dateTimeS = CorrectDateStr(pdateTimeS);
            datetime dtTemp = null;
            try{dtTemp=datetime.parse(dateTimeS);}catch(Exception e){}
            if (dtTemp!=null) return dtTemp;
            
            date dtTemp1 = null;
            try{dtTemp1=date.parse(dateTimeS);}catch(Exception e){}
            if (dtTemp1!=null) return datetime.newInstance(dtTemp1.year(),dtTemp1.month(),dtTemp1.day());
            
            datetime dtTemp2 = null;
            try{dtTemp2=datetime.valueOf(dateTimeS);}catch(Exception e){}
            if (dtTemp2!=null) return datetime.newInstance(dtTemp2.year(),dtTemp2.month(),dtTemp2.day());
            
            dateTime rDateTime;
            String dString = '';
            String tString = '00:00:00';
            list<string> lstDtTime = dateTimeS.split('T');
            if (lstDtTime!=null) if (!lstDtTime.isEmpty()){
                dString = lstDtTime[0];
                if (lstDtTime.size()>1)
                    tString = lstDtTime[1];
            }
            Integer y = integer.valueof(dSTring.split('-')[0]);
            Integer m = integer.valueof(dSTring.split('-')[1]);
            Integer d = integer.valueof(dSTring.split('-')[2]);
            Integer h = integer.valueof(tSTring.split(':')[0]);
            Integer mn = integer.valueof(tSTring.split(':')[1]);
            String sec = tSTring.split(':')[2];
            Integer s;
            if(!sec.split('\\.').isEmpty())
                s = integer.valueof(tSTring.split(':')[2].split('\\.')[0]);
            else
                s = integer.valueof(tSTring.split(':')[2]);
            rDateTime = DateTime.newInstance(y,m,d,h,mn,s);
            return rDateTime;
    }
    
    class wrapProcessInfo {
      public Id RecordId;
      public string ErrorDesc;
    }
    
    class wrapDupInfo {
      public Id RecordId;
      public string ErrorDesc;
      public Id OwnerId;
        public Id accId;
        public Id contId;
    }
}