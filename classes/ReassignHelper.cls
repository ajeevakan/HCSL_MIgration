public without sharing class ReassignHelper {

    public static void ReassignRecords(list<sobject> lstObj, Id ReassignBatchId){
        if (string.isNotBlank(ReassignBatchId)) if (lstObj!=null) if (!lstObj.isEmpty()){
            Reassignment_Batch__c objRB = null;
            list<Id> lstObjId = new list<Id>();
            for (SObject sobj : lstObj) 
                lstObjId.add(sobj.Id);
            if (!lstObjId.isEmpty())
                for (Reassignment_Batch__c rb : [SELECT Id, Name, Campaign__c, Community__c, Current_Owner__c, Message__c, Object_Name__c, Reassign_Activities_Only__c, Reassign_To__c, Status__c FROM Reassignment_Batch__c WHERE Id = :ReassignBatchId]) objRB = rb;
                    if (objRB!=null){
                        if (('Account').equalsIgnoreCase(objRB.Object_Name__c)){
                            
                            
                        }
                    }
        }
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
        retParam.reassignToId = FourthFormParam.reassignToId;
        retParam.campaignId = FourthFormParam.campaignId;
        retParam.searchName = FourthFormParam.searchName;
        retParam.currentOwnerId = FourthFormParam.currentOwnerId;
        retParam.communityId = FourthFormParam.communityId;
        retParam.whereCondition = FourthFormParam.whereCondition;
        Reassignment_Batch__c rb = new Reassignment_Batch__c(Status__c = 'Not Started',
            Object_Name__c = FourthFormParam.objectName,
            Search_Name__c = FourthFormParam.searchName,
            Where_Condition__c = FourthFormParam.whereCondition);
        if (string.isNotBlank(FourthFormParam.reassignToId)) rb.Reassign_To__c = Id.valueOf(FourthFormParam.reassignToId);
        if (string.isNotBlank(FourthFormParam.campaignId)) rb.Campaign__c = Id.valueOf(FourthFormParam.campaignId);
        if (string.isNotBlank(FourthFormParam.currentOwnerId)) rb.Current_Owner__c = Id.valueOf(FourthFormParam.currentOwnerId);
        if (string.isNotBlank(FourthFormParam.communityId)) rb.Community__c = Id.valueOf(FourthFormParam.communityId);
        if (FourthFormParam.reassignActivitiesOnly==true) rb.Reassign_Activities_Only__c = true;
        insert rb;
        retParam.ReassignmentBatchId = rb.Id;
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
        }
        string Reassign_Records = ThirdFormParam.objectName;
        if ((('Account').equalsIgnoreCase(Reassign_Records))||(('Opportunity').equalsIgnoreCase(Reassign_Records))){
            list<string> lstCondition = new list<string>();
            if (!ThirdFormParam.paramFields.isEmpty()) for (ReassignHelperFormParamParamField pf : ThirdFormParam.paramFields) if (string.isNotBlank(pf.fieldValue))
            if (!pf.fieldName.equalsIgnoreCase('CurrentOwnerId')) if (!pf.fieldName.equalsIgnoreCase('CommunityId')){
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
                            strFldValue = '\''+string.escapeSingleQuotes(rsc.Field_Value__c.trim())+'\'';
                        }
                        else if (oFieldType==Schema.DisplayType.DATE){
                            date dt = ParseDate(rsc.Field_Value__c);
                            if (dt==null) lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                            else strFldValue = Datetime.newInstance(dt.year(),dt.month(),dt.day()).format('yyyy-MM-dd');
                        }
                        else if (oFieldType==Schema.DisplayType.DATETIME){
                            datetime dtt = ParseDateTime(rsc.Field_Value__c);
                            if (dtt==null){
                                date dt = ParseDate(rsc.Field_Value__c);
                                if (dt!= null ) dtt = Datetime.newInstance(dt.year(),dt.month(),dt.day());
                            }
                            if (dtt==null) lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                            else strFldValue = dtt.format('yyyy-MM-dd HH:mm:ss','GMT').replace(' ','T') + 'z';
                        }
                        else if ((oFieldType==Schema.DisplayType.CURRENCY)||(oFieldType==Schema.DisplayType.DOUBLE)||(oFieldType==Schema.DisplayType.INTEGER)||(oFieldType==Schema.DisplayType.LONG)||(oFieldType==Schema.DisplayType.PERCENT)){
                            string temp = ParseNumber(rsc.Field_Value__c);
                            if (string.isNotBlank(temp)) strFldValue = temp;
                            else lstError.add(rsc.Field_Label__c + ' field value is Invalid.');
                        }
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
            if (string.isNotBlank(retParam.objectName)) strMsg += '\t &nbsp;&nbsp;&nbsp; Object : <b>' + retParam.objectName + '</b> <br/>\r\n';
            if (retParam.reassignActivitiesOnly!=null) if (retParam.reassignActivitiesOnly) strMsg += '\t &nbsp;&nbsp;&nbsp; Reassign Activities Only : <b>' + 'Yes' + '</b> <br/>\r\n';
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
            if (string.isNotBlank(retParam.searchName)) strMsg += '\t &nbsp;&nbsp;&nbsp; Search Name : <b>' + retParam.searchName + '</b> <br/>\r\n';
            if (ThirdFormParam!=null) if (ThirdFormParam.paramFields!=null)
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
            if (string.isNotBlank(retParam.whereCondition)) strMsg += '<br/>\r\n\t &nbsp;&nbsp;&nbsp; SOQL Where Condition : <b>' + retParam.whereCondition + '</b> <br/>\r\n';
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
        retParam.reassignToId = SecondFormParam.reassignToId;
        retParam.paramFields = new list<ReassignHelperFormParamParamField>();
        integer intP = 1;
        try{
        ReassignHelperFormParamParamField p1 = new ReassignHelperFormParamParamField();
        p1.paramId = 'P'+ string.valueOf(retParam.step) + string.valueOf(intP++).leftPad(3,'0');
        p1.fieldLabel = 'Current Owner';
        p1.fieldName = 'CurrentOwnerId';
        p1.fieldType = 'PICKLIST';
        p1.SetType();
        p1.operator = '=';
        p1.picklistOptions = new list<ReassignHelperFormParamComboItem>();
        for (User u: [SELECT Id, Name, Username FROM User ORDER BY Name]) if (u.Id!=Id.valueOf(retParam.reassignToId))
            p1.picklistOptions.add(new ReassignHelperFormParamComboItem(u.Name + ' (' + u.Username + ')', Id.valueOf(string.valueOf(u.Id))));
        p1.picklistOptions.add(0,new ReassignHelperFormParamComboItem('<All>',''));
        p1.fieldValue = '';
        retParam.paramFields.add(p1);
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
        string Reassign_Records = SecondFormParam.objectName;
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
                        else if (oFieldType==Schema.DisplayType.DATE)
                            p3.fieldType = 'DATE';
                        else if (oFieldType==Schema.DisplayType.DATETIME)
                            p3.fieldType = 'DATETIME';
                        else if ((oFieldType==Schema.DisplayType.CURRENCY)||(oFieldType==Schema.DisplayType.DOUBLE)||(oFieldType==Schema.DisplayType.INTEGER)||(oFieldType==Schema.DisplayType.LONG)||(oFieldType==Schema.DisplayType.PERCENT))
                            p3.fieldType = 'NUMBER';
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
                Reassign_Records = pf.fieldValue;
                pf.picklistOptions.clear();
            }
            else if (pf.fieldName.equalsIgnoreCase('Reassign_To')){
                pf.picklistOptions.clear();
                if (string.isNotBlank(pf.fieldValue)){
                    retParam.reassignToId = pf.fieldValue;
                }
            }
            else if (pf.fieldName.equalsIgnoreCase('Activities_Only')){
                if (string.isNotBlank(pf.fieldValue)) if ((pf.fieldValue.equalsIgnoreCase('true'))||(pf.fieldValue.equalsIgnoreCase('yes'))||(pf.fieldValue.equalsIgnoreCase('1')))
                    retParam.reassignActivitiesOnly = true;
            }
        }
        if ((('Account').equalsIgnoreCase(Reassign_Records))||(('Opportunity').equalsIgnoreCase(Reassign_Records))){
            retParam.objectName = Reassign_Records;
            set<string> setSeachName = new set<string>();
            list<string> lstSeachName = new list<string>();
            string strSearch_Object = 'Referral Account';
            if (('Opportunity').equalsIgnoreCase(Reassign_Records)) strSearch_Object = 'Opportunity';
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
        retParam.paramFields.add(p3);
        }catch(Exception exc){
            retParam.message = 'Exception: ' + exc.getMessage() + ' (#' + string.valueOf(exc.getLineNumber()) + ')';
            retParam.step = 99;
        }
        return retParam;
    }

    // public class ParamField{
    //     @AuraEnabled
    //     public string fieldName;
    //     @AuraEnabled
    //     public string fieldLabel;
    //     @AuraEnabled
    //     public string fieldType;// (BOOLEAN,PICKLIST,DATE,DATETIME,NUMBER,TEXT)
    //     @AuraEnabled
    //     public string operator;
    //     @AuraEnabled
    //     public list<ComboItem> picklistOptions;
    //     @AuraEnabled
    //     public string fieldValue;
    //     @AuraEnabled
    //     public string paramId;
    //     @AuraEnabled
    //     public Boolean isBOOLEAN;
    //     @AuraEnabled
    //     public Boolean isPICKLIST;
    //     @AuraEnabled
    //     public Boolean isDATE;
    //     @AuraEnabled
    //     public Boolean isNUMBER;
    //     @AuraEnabled
    //     public Boolean isTEXT;
    //     public void SetType(){
    //         isBOOLEAN=false;
    //         isPICKLIST=false;
    //         isDATE=false;
    //         isNUMBER=false;
    //         isTEXT=false;
    //         if (string.isBlank(fieldType)) isTEXT = true;
    //         else if (fieldType.equalsIgnoreCase('BOOLEAN')) isBOOLEAN = true;
    //         else if (fieldType.equalsIgnoreCase('PICKLIST')) isPICKLIST = true;
    //         else if (fieldType.equalsIgnoreCase('DATE')) isDATE = true;
    //         else if (fieldType.equalsIgnoreCase('DATETIME')) isDATE = true;
    //         else if (fieldType.equalsIgnoreCase('NUMBER')) isNUMBER = true;
    //         else isTEXT = true;
    //     }

        
    // }

    // public class ComboItem{
    //     @AuraEnabled
    //     public string label;
    //     @AuraEnabled
    //     public string value;
    //     public ComboItem(string plabel, string pvalue){
    //         this.label = plabel;
    //         this.value = pvalue;
    //     }
    // }
    
    
    // public class FormParam{
    //     @AuraEnabled
    //     public list<ParamField> paramFields;
    //     @AuraEnabled
    //     public string message;
    //     @AuraEnabled
    //     public integer step;
    //     @AuraEnabled
    //     public FormParam sourceParam;
    //     @AuraEnabled
    //     public string objectName;
    //     @AuraEnabled
    //     public string searchName;
    //     @AuraEnabled
    //     public boolean reassignActivitiesOnly;
    //     @AuraEnabled
    //     public string reassignToId;
    //     @AuraEnabled
    //     public string communityId;
    //     @AuraEnabled
    //     public string currentOwnerId;
    //     @AuraEnabled
    //     public string campaignId;
    //     @AuraEnabled
    //     public string whereCondition;
    // }
}