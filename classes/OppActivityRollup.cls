public class OppActivityRollup {
    
    public static void handleActivityTrigger(){
        if (DisableTrigger.isDisabled('OppActivityRollUp')) return;
        boolean IgnoreSystemActivityCheck = false;
        if (Trigger.isAfter){
            if (Trigger.isDelete)
                (new OppActivityRollup()).ActivityTrigger(Trigger.old, !(DisableTrigger.isDisabled('OppActivityRollUpFuture')),IgnoreSystemActivityCheck);
            else if (Trigger.isInsert)
                (new OppActivityRollup()).ActivityTrigger(Trigger.new, !(DisableTrigger.isDisabled('OppActivityRollUpFuture')),IgnoreSystemActivityCheck); 
            else if (Trigger.isUpdate){
                set<string> setActvtFlds = new set<string>{'Fire_Task_Roll_Up_Trigger__c','Activity_Type__c','AccountId','Is_Complete__c','Is_Pending__c','WhoId'};
                for (Opp_Activity_Rollup__mdt objAR : Opp_Activity_Rollup__mdt.getall().values())
                    if (!(objAR.InActive__c)) {
                        if (string.isNotBlank(objAR.Activity_Summary_Field__c))
                            setActvtFlds.add(objAR.Activity_Summary_Field__c);
                        if (string.isNotBlank(objAR.Activity_Sort_Field__c))
                            setActvtFlds.add(objAR.Activity_Sort_Field__c); 
                        set<string> setExFlds = new set<string>();
                        if (string.isNotBlank(objAR.Extra_Conditions_Field_Names__c))
                            for (string strFld : objAR.Extra_Conditions_Field_Names__c.split(','))
                                if (string.isNotBlank(strFld.trim()))
                                    setExFlds.add(strFld.trim());
                        if (!setExFlds.isEmpty()) 
                            setActvtFlds.addAll(setExFlds);           
                    }
                list<SObject> lstActivity = new list<SObject>();
                for (SObject objEvent : Trigger.new){
                    SObject objOldEvent = trigger.oldMap.get(objEvent.Id);
                    boolean fieldEdited = false;
                    for (string strFld : setActvtFlds)
                        //if (objEvent.containsKey(strFld))
                            if (!(objEvent.get(strFld)==objOldEvent.get(strFld))){
                                fieldEdited = true;
                                if (!IgnoreSystemActivityCheck) 
                                    if ('Fire_Task_Roll_Up_Trigger__c'.equalsIgnoreCase(strFld)) 
                                    	IgnoreSystemActivityCheck=true;
                                break;
                            }
                    if (fieldEdited)
                        lstActivity.add(objEvent);
                } 
                if (!lstActivity.isEmpty())
                    (new OppActivityRollup()).ActivityTrigger(lstActivity, !(DisableTrigger.isDisabled('OppActivityRollUpFuture')),IgnoreSystemActivityCheck);
            }
      }
    }
    
    public void ActivityTrigger(list<SObject> lstActivity, boolean UseFuture, boolean IgnoreSystemActivityCheck){
        set<Id> setOppId = new set<Id>();
        if (lstActivity!=null)
            if (!lstActivity.isEmpty()){
                String opp_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
                for (SObject objActivity : lstActivity){
                    // Added check to skip activities of type System to avoid thrashing of account updates since we never perform 
                    // roll ups based on system generated activities
                    Boolean systemActivityRollupDisallowed =  IgnoreSystemActivityCheck?false:Boolean.valueOf(objActivity.get('System__c')); 
                    if (systemActivityRollupDisallowed) if (string.valueOf(objActivity.get('Activity_Type__c')) == 'Inquiry')
                       systemActivityRollupDisallowed = false;
                    if (systemActivityRollupDisallowed == false) {
                       if (string.isNotBlank(string.valueOf(objActivity.get('WhatId'))))
                           if (string.valueOf(objActivity.get('WhatId')).startsWith(opp_prefix))   
                               setOppId.add(Id.valueOf(string.valueOf(objActivity.get('WhatId'))));
                    }
                }
            }
        if (!setOppId.isEmpty()){
            list<Id> lstOppId = new list<Id>();
            lstOppId.addAll(setOppId);
            setOppId.clear();
           CalcActivityRollup(lstOppId, UseFuture);
        }
    }
    
    private static void CalcActivityRollup(list<Id> lstParentId, boolean UseFuture){
      if (!UseFuture) CalcActivityRollup( lstParentId);
    else if ((system.isFuture())||(system.isBatch())) CalcActivityRollup( lstParentId);
    else FutureCalcActivityRollup( lstParentId);
    }
    
    @future
    static void FutureCalcActivityRollup(list<Id> lstParentId){
      CalcActivityRollup(lstParentId);
    }
    
    private static void CalcActivityRollup(list<Id> lstParentId){
        list<Opp_Activity_Rollup__mdt> lstActivityRollup = new list<Opp_Activity_Rollup__mdt>(); 
        for (Opp_Activity_Rollup__mdt objAR : Opp_Activity_Rollup__mdt.getall().values())
            if (!(objAR.InActive__c))
                //if (strParentObject.equalsIgnoreCase(objAR.Parent_Object__c))
                    lstActivityRollup.add(objAR);
        string strParentQuery = 'SELECT Id';
        string strTaskQuery = 'SELECT Id';
        string strEventQuery = 'SELECT Id';
        set<string> setTaskFields = new set<string>{'Activity_Type__c','AccountId','Is_Complete__c','Is_Pending__c','WhoId','WhatId','System__c'};
        set<string> setEventFields = new set<string>{'Activity_Type__c','AccountId','Is_Complete__c','Is_Pending__c','WhoId','WhatId','System__c'};
        set<string> setParentFields = new set<string>();
        if (lstActivityRollup!=null)
            if (!lstActivityRollup.isEmpty())
                for (Opp_Activity_Rollup__mdt objActivityRollup : lstActivityRollup){
                    if (string.isNotBlank(objActivityRollup.Opportunity_Field__c))
                        setParentFields.add(objActivityRollup.Opportunity_Field__c);
                    if (string.isNotBlank(objActivityRollup.Activity_Summary_Field__c)) 
                        if (!(('Id').equalsIgnoreCase(objActivityRollup.Activity_Summary_Field__c))){
                            setEventFields.add(objActivityRollup.Activity_Summary_Field__c);
                            setTaskFields.add(objActivityRollup.Activity_Summary_Field__c);
                        }
                    if (string.isNotBlank(objActivityRollup.Activity_Sort_Field__c))
                        if (!(('Id').equalsIgnoreCase(objActivityRollup.Activity_Sort_Field__c))){
                            setTaskFields.add(objActivityRollup.Activity_Sort_Field__c);
                            setEventFields.add(objActivityRollup.Activity_Sort_Field__c);   
                        }
                    set<string> setExFlds = new set<string>();
                    if (string.isNotBlank(objActivityRollup.Extra_Conditions_Field_Names__c))
                        for (string strFld : objActivityRollup.Extra_Conditions_Field_Names__c.split(','))
                            if (string.isNotBlank(strFld.trim()))
                                setExFlds.add(strFld.trim());  
                    if (!setExFlds.isEmpty()){ 
                        setTaskFields.addAll(setExFlds);
                        setEventFields.addAll(setExFlds);
                    }
                }
        if (!setParentFields.isEmpty()){
            for (string strFld : setParentFields)   
                strParentQuery += (', ' + strFld);  
            setParentFields.clear();    
        }
        if (!setEventFields.isEmpty()){
            for (string strFld : setEventFields)    
                strEventQuery += (', ' + strFld);
            setEventFields.clear(); 
        }
        if (!setTaskFields.isEmpty()){
            for (string strFld : setTaskFields) 
                strTaskQuery += (', ' + strFld);
            setTaskFields.clear();  
        }
                        
        strParentQuery += ' FROM Opportunity WHERE Id IN :lstParentId ORDER BY Id ';
        strTaskQuery += ' FROM Task WHERE WhatId IN :lstParentId AND (System__c = false OR System__c = null) AND Isdeleted = false ORDER BY WhatId ALL ROWS';
        strEventQuery += ' FROM Event WHERE WhatId IN :lstParentId AND (System__c = false OR System__c = null) AND Isdeleted = false  ORDER BY WhatId  ALL ROWS';
        
        list<SObject> lstParent = database.query(strParentQuery);
        strParentQuery = null;
        map<Id,list<SObject>> mapParentEvents = new map<Id,list<SObject>>();
        map<Id,list<SObject>> mapParentTasks = new map<Id,list<SObject>>();
        for (SObject sobj : database.query(strEventQuery)){
            if (string.isNotBlank(string.valueOf(sobj.get('WhatId')))){
                list<SObject> lstTemp = null;
                if (mapParentEvents.containsKey(Id.valueOf(string.valueOf(sobj.get('WhatId')))))
                    lstTemp = (mapParentEvents.get(Id.valueOf(string.valueOf(sobj.get('WhatId')))));
                else
                    lstTemp = new list<SObject>();
                lstTemp.add(sobj);
                mapParentEvents.put(Id.valueOf(string.valueOf(sobj.get('WhatId'))),lstTemp);
            }
        }
        strEventQuery = null;
        for (SObject sobj : database.query(strTaskQuery)){
            if (string.isNotBlank(string.valueOf(sobj.get('WhatId')))){
                list<SObject> lstTemp = null;
                if (mapParentTasks.containsKey(Id.valueOf(string.valueOf(sobj.get('WhatId')))))
                    lstTemp = (mapParentTasks.get(Id.valueOf(string.valueOf(sobj.get('WhatId')))));
                else
                    lstTemp = new list<SObject>();
                lstTemp.add(sobj);
                mapParentTasks.put(Id.valueOf(string.valueOf(sobj.get('WhatId'))),lstTemp);
            }
        }
        strTaskQuery = null;
        for (SObject objParent : lstParent)
            for (Opp_Activity_Rollup__mdt objActivityRollup : lstActivityRollup)
                CalculateParentField(objParent, objActivityRollup, mapParentEvents.get(Id.valueOf(string.valueOf(objParent.get('Id')))),  
                                            mapParentTasks.get(Id.valueOf(string.valueOf(objParent.get('Id')))));
        update lstParent;
    }
    
    private static void CalculateParentField(SObject objParent, Opp_Activity_Rollup__mdt objActivityRollup, list<SObject> lstEvent, list<SObject> lstTask){
        SObject selActivity = null;
        Schema.SOAPType sortFieldType = Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap().get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)).getDescribe().getSoapType();
        integer intCount = 0;
        map<string,string> mapExtraCondition = new map<string,string>();
        list<string> lstExFlds = new list<string>();
        if (string.isNotBlank(objActivityRollup.Extra_Conditions_Field_Names__c))
            for (string strFld : objActivityRollup.Extra_Conditions_Field_Names__c.split(','))
                if (string.isNotBlank(strFld.trim()))
                    lstExFlds.add(strFld.trim());
        list<string> lstExFldVals = new list<string>();
        if (string.isNotBlank(objActivityRollup.Extra_Conditions_Field_Values__c))
            for (string strFld : objActivityRollup.Extra_Conditions_Field_Values__c.split(','))
                lstExFldVals.add(strFld.trim());            
        if (!lstExFlds.isEmpty())
            if (!lstExFldVals.isEmpty())
                if (lstExFlds.size()==lstExFldVals.size()) 
                    for (integer p=0;p<lstExFlds.size();p++)
                        mapExtraCondition.put(lstExFlds.get(p),lstExFldVals.get(p));

        set<string> setTypes = new set<string>();
        if (string.isNotBlank(objActivityRollup.Type__c))
            for (string strType : objActivityRollup.Type__c.split(','))
                setTypes.add(strType.trim());
        boolean isSort = false;
        boolean isSummary = false;
        if (string.isNotBlank(objActivityRollup.Summary_Type__c)){
            isSummary = true;
            if (string.isNotBlank(objActivityRollup.Activity_Sort_Field__c)) 
                isSort = true;   
        }
        boolean isMax = false;
        boolean isMin = false;
        if ((('Max').equalsIgnoreCase(objActivityRollup.Summary_Type__c))) 
            isMax = true;
        if((('Min').equalsIgnoreCase(objActivityRollup.Summary_Type__c)))   
            isMin = true;
        if (lstEvent!=null) 
            if (!lstEvent.isEmpty())
                for (SObject actvt: lstEvent ){
                    boolean flag = true;

                    if (flag)
                        if (objActivityRollup.Completed_Activity_Only__c)
                            if (!((boolean)actvt.get('Is_Complete__c')))
                                flag = false;
                    if (flag)
                        if (objActivityRollup.Pending_Activity_Only__c)
                            if (!((boolean)actvt.get('Is_Pending__c')))
                                flag = false;
                    if (flag)
                        if (objActivityRollup.Completed_Activity_False__c)
                            if (((boolean)actvt.get('Is_Complete__c')))
                                flag = false;
                    if (flag)
                        if (objActivityRollup.Pending_Activity_False__c)
                            if (((boolean)actvt.get('Is_Pending__c')))
                                flag = false;                                   
                    if (flag)
                        
                            if (!setTypes.isEmpty()){
                                if (string.isNotBlank(string.valueOf(actvt.get('Activity_Type__c')))){
                                    if (!setTypes.contains(string.valueOf(actvt.get('Activity_Type__c'))))
                                        flag = false;
                                }
                                else
                                    flag = false;
                            }
                     
                    if (flag){
                        if (!mapExtraCondition.isEmpty())
                            for (string strFld : mapExtraCondition.keySet()){
                                if (string.isBlank(mapExtraCondition.get(strFld))){
                                    if (!((actvt.get(strFld)==null)||(string.isBlank(string.valueOf(actvt.get(strFld)))))){
                                        flag = false;
                                        break;
                                    }
                                }
                                else{
                                    if (!(mapExtraCondition.get(strFld).equalsIgnoreCase(string.valueOf(actvt.get(strFld))))){
                                        flag = false;
                                        break;
                                    }
                                }
                            }
                    }    
                    if (flag)
                        if (isSummary){
                            if (isSort)
                                if ((actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))!=null){
                                    if (selActivity==null){
                                        if ((isMax)||(isMin))
                                            selActivity = actvt;
                                    }
                                    else{
                                        boolean greater = false;
                                        if (sortFieldType== Schema.SOAPType.Date){
                                            if ((date.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(date.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.DateTime){
                                            if ((DateTime.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(DateTime.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.Double){
                                            if ((Double.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(Double.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.Integer){
                                            if ((Integer.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(Integer.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else{
                                            if ((String.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(String.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        if (isMax){
                                            if (greater)
                                                selActivity = actvt;
                                        }
                                        else if (isMin){
                                            if (!(greater))
                                                selActivity = actvt;
                                        }
                                    }
                                }
                            intCount++; 
                        }
                }
        if (lstTask!=null) 
            if (!lstTask.isEmpty())
                for (SObject actvt: lstTask ){
                    boolean flag = true;

                    if (flag)
                        if (objActivityRollup.Completed_Activity_Only__c)
                            if (!((boolean)actvt.get('Is_Complete__c')))
                                flag = false;
                    if (flag)
                        if (objActivityRollup.Pending_Activity_Only__c)
                            if (!((boolean)actvt.get('Is_Pending__c')))
                                flag = false;   
                    if (flag)
                        if (objActivityRollup.Completed_Activity_False__c)
                            if (((boolean)actvt.get('Is_Complete__c')))
                                flag = false;
                    if (flag)
                        if (objActivityRollup.Pending_Activity_False__c)
                            if (((boolean)actvt.get('Is_Pending__c')))
                                flag = false;                               
                              
                    if (flag)
                        
                            if (!setTypes.isEmpty()){
                                if (string.isNotBlank(string.valueOf(actvt.get('Activity_Type__c')))){
                                    if (!setTypes.contains(string.valueOf(actvt.get('Activity_Type__c'))))
                                        flag = false;
                                }
                                else
                                    flag = false;
                            }
                     
                    if (flag){
                        if (!mapExtraCondition.isEmpty())
                            for (string strFld : mapExtraCondition.keySet()){
                                if (string.isBlank(mapExtraCondition.get(strFld))){
                                    if (!((actvt.get(strFld)==null)||(string.isBlank(string.valueOf(actvt.get(strFld)))))){
                                        flag = false;
                                        break;
                                    }
                                }
                                else{
                                    if (!(mapExtraCondition.get(strFld).equalsIgnoreCase(string.valueOf(actvt.get(strFld))))){
                                        flag = false;
                                        break;
                                    }
                                }
                            }
                    }    
                    if (flag)
                        if (isSummary){
                            if (isSort)
                                if ((actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))!=null){
                                    if (selActivity==null){
                                        if ((isMax)||(isMin))
                                            selActivity = actvt;
                                    }
                                    else{
                                        boolean greater = false;
                                        if (sortFieldType== Schema.SOAPType.Date){
                                            if ((date.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(date.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.DateTime){
                                            if ((DateTime.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(DateTime.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.Double){
                                            if ((Double.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(Double.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else if (sortFieldType== Schema.SOAPType.Integer){
                                            if ((Integer.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(Integer.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        else{
                                            if ((String.valueOf(actvt.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c))))>(String.valueOf(selActivity.get(string.valueOf(objActivityRollup.Activity_Sort_Field__c)))))
                                                greater = true;
                                        }
                                        if (isMax){
                                            if (greater)
                                                selActivity = actvt;
                                        }
                                        else if (isMin){
                                            if (!(greater))
                                                selActivity = actvt;
                                        }
                                    }
                                }
                            intCount++; 
                        }
                }       
        
        if (string.isNotBlank(objActivityRollup.Opportunity_Field__c)){
            if (isSummary) 
                if ((isMax)||(isMin)){
                    if (selActivity!=null)  
                        objParent.put(string.valueOf(objActivityRollup.Opportunity_Field__c), selActivity.get(string.valueOf(objActivityRollup.Activity_Summary_Field__c)));
                    else
                        objParent.put(string.valueOf(objActivityRollup.Opportunity_Field__c), null);
                }
            if ((('Count').equalsIgnoreCase(objActivityRollup.Summary_Type__c)))    
                objParent.put(string.valueOf(objActivityRollup.Opportunity_Field__c), intCount);
        }
    }

}