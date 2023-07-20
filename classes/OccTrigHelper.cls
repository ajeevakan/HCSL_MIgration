public without sharing class OccTrigHelper{
	public static list<Occupancy__c> lstDelOcc;

  public static void OccTrigger(boolean UseFuture){
    if (trigger.isAfter){
      set<Id> setApartmentId = new set<Id>();
      set<Id> setApartmentIdSch = new set<Id>();
      if (trigger.isDelete){
		for (Occupancy__c objOcc : (list<Occupancy__c>)trigger.Old){
			if (string.isNotBlank(objOcc.Apartment__c))
            	setApartmentId.add(objOcc.Apartment__c);
            if (string.isNotBlank(objOcc.Transfer_Apartment__c))
            	setApartmentId.add(objOcc.Transfer_Apartment__c);
		}
        if (!setApartmentId.isEmpty()){
          if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
            CallUpdateUnitStatus(new list<Id>(setApartmentId), false);
        }
      }
      else if (trigger.isInsert){
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        for (Occupancy__c objOcc : (list<Occupancy__c>)trigger.New){
          if (string.isNotBlank(objOcc.Apartment__c))
            setApartmentId.add(objOcc.Apartment__c);
          if (objOcc.Move_In_Date__c!=null)
            lstOcc.add(objOcc);
        }
        if (!lstOcc.isEmpty()){
          if (!(DisableTrigger.isDisabled('trigOccupancyCreateOccLog')))
            CallCreateOccLogInsert(lstOcc, setApartmentId, UseFuture);
        }
        else if (!setApartmentId.isEmpty()){
          if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
            CallUpdateUnitStatus(new list<Id>(setApartmentId), false);
        }
      }
      else if (trigger.isUpdate){
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        for (Occupancy__c objOcc : (list<Occupancy__c>)trigger.New){
          Occupancy__c objOldOcc = (Occupancy__c)trigger.oldMap.get(objOcc.Id);
          boolean changed = true;
          if (isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c))
            if (isFldEqual(objOcc.Resident__c,objOldOcc.Resident__c))
              if (isFldEqual(objOcc.Level_of_Care__c,objOldOcc.Level_of_Care__c))
                if (isFldEqual(objOcc.Move_In_Date__c,objOldOcc.Move_In_Date__c))
                  if (isFldEqual(objOcc.Move_Out_Date__c,objOldOcc.Move_Out_Date__c))
                    if (isFldEqual(objOcc.Bed__c,objOldOcc.Bed__c))
                      if (isFldEqual(objOcc.Move_Out_Reason__c,objOldOcc.Move_Out_Reason__c))
              			if (isFldEqual(objOcc.Change_to_Fire_Occupancy_Trigger__c,objOldOcc.Change_to_Fire_Occupancy_Trigger__c))
                        changed = false;
          if (changed){
            changed = false;
            lstOcc.add(objOcc);
            if (string.isNotBlank(objOcc.Apartment__c))
              setApartmentId.add(objOcc.Apartment__c);
            if (!isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c))
              if (string.isNotBlank(objOldOcc.Apartment__c))
                setApartmentId.add(objOldOcc.Apartment__c);
          }
          else{
            changed = true; 
            if (isFldEqual(objOcc.Scheduled_Move_In_Date__c,objOldOcc.Scheduled_Move_In_Date__c))
              if (isFldEqual(objOcc.Scheduled_Move_Out_Date__c,objOldOcc.Scheduled_Move_Out_Date__c))
                if (isFldEqual(objOcc.Transfer_Apartment__c,objOldOcc.Transfer_Apartment__c))
                  changed = false;
          }
          if (changed){
            changed = false;
            if (string.isNotBlank(objOcc.Apartment__c))
              setApartmentIdSch.add(objOcc.Apartment__c);
            if (string.isNotBlank(objOcc.Transfer_Apartment__c))
              setApartmentIdSch.add(objOcc.Transfer_Apartment__c);
            if (!isFldEqual(objOcc.Transfer_Apartment__c,objOldOcc.Transfer_Apartment__c))
              if (string.isNotBlank(objOldOcc.Transfer_Apartment__c))
                setApartmentIdSch.add(objOldOcc.Transfer_Apartment__c);
          }
        }
        if (!lstOcc.isEmpty()){
          if (!(DisableTrigger.isDisabled('trigOccupancyCreateOccLog')))
            CallCreateOccLogUpdate(lstOcc, setApartmentId, UseFuture);
        }
        if (!setApartmentIdSch.isEmpty()){
          if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
            CallUpdateUnitStatus(new list<Id>(setApartmentIdSch), false);
        }
      }
    }
    else if (trigger.isBefore){
      list<Occupancy__c> lstOcc = new list<Occupancy__c>();
      set<Id> setApartmentId = new set<Id>();
      set<Id> setOccId = new set<Id>();
      for (Occupancy__c objOcc : (list<Occupancy__c>)trigger.New){
        if (trigger.isInsert){
          lstOcc.add(objOcc);
          if (string.isNotBlank(objOcc.Apartment__c))
            setApartmentId.add(objOcc.Apartment__c);
        }
        else if (trigger.isUpdate){
          Occupancy__c objOldOcc = (Occupancy__c)trigger.oldMap.get(objOcc.Id);
          if ((!(isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c)))
            || (!(isFldEqual(objOcc.Bed__c,objOldOcc.Bed__c)))
              || (!(isFldEqual(objOcc.Level_of_Care__c,objOldOcc.Level_of_Care__c)))){
                if (string.isNotBlank(objOcc.Transfer_Apartment__c)) objOcc.Transfer_Apartment__c = null;
                if (string.isNotBlank(objOcc.Transfer_Bed__c)) objOcc.Transfer_Bed__c = null;
                if (string.isNotBlank(objOcc.Transfer_Level_of_Care__c)) objOcc.Transfer_Level_of_Care__c = null;
              }
          boolean changed = true;
          if (isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c))
            if (isFldEqual(objOcc.Move_In_Date__c,objOldOcc.Move_In_Date__c))
              if (isFldEqual(objOcc.Move_Out_Date__c,objOldOcc.Move_Out_Date__c))
                changed = false;
          if (changed){
            lstOcc.add(objOcc);
            setOccId.add(objOcc.Id);
            if (string.isNotBlank(objOcc.Apartment__c))
              setApartmentId.add(objOcc.Apartment__c);
            if (!isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c))
              if (string.isNotBlank(objOldOcc.Apartment__c))
                setApartmentId.add(objOldOcc.Apartment__c);
          }
        }
      }
      if (!lstOcc.isEmpty()){
        map<Id, Date> mapOccupiedUnits = new map<Id, Date>();
        for (Occupancy__c tmpOcc : [SELECT Id, Apartment__c, Move_In_Date__c FROM Occupancy__c WHERE Apartment__c IN :setApartmentId AND Move_In_Date__c != Null AND (Move_Out_Date__c = null OR Move_Out_Date__c > TODAY) AND Id NOT IN :setOccId])
          mapOccupiedUnits.put(tmpOcc.Apartment__c,tmpOcc.Move_In_Date__c);
        for (Occupancy__c objOcc : lstOcc) if (string.isNotBlank(objOcc.Apartment__c)){
          if (objOcc.Move_Out_Date__c!=null){
            if (mapOccupiedUnits.containsKey(objOcc.Apartment__c))
              objOcc.is_Primary__c = false;
          }
          else if (objOcc.Move_In_Date__c!=null){
            if (mapOccupiedUnits.containsKey(objOcc.Apartment__c)){
              if (objOcc.Move_In_Date__c<mapOccupiedUnits.get(objOcc.Apartment__c)){
                objOcc.is_Primary__c = true;
                mapOccupiedUnits.put(objOcc.Apartment__c,objOcc.Move_In_Date__c);
              }
            }
            else{
              objOcc.is_Primary__c = true;
              mapOccupiedUnits.put(objOcc.Apartment__c,objOcc.Move_In_Date__c);
            }
          }
        }
        for (Occupancy__c objOcc : lstOcc) 
          if (objOcc.Move_Out_Date__c==null) 
            if (objOcc.Move_In_Date__c!=null)
              if (string.isNotBlank(objOcc.Apartment__c)) 
                if (objOcc.is_Primary__c)
                  if (mapOccupiedUnits.containsKey(objOcc.Apartment__c))
                    if (objOcc.Move_In_Date__c>mapOccupiedUnits.get(objOcc.Apartment__c))
                      objOcc.is_Primary__c = false;
      }
      OccTriggerApplyChangetoCouple();
    }
  }

  private static void UpdateCurrentActiveOccupancy(list<Occupancy__c> lstOcc){
    if (lstOcc!=null)
      if (!lstOcc.isEmpty()){
        list<Id> setOccId = new list<Id>();
        set<Id> setResidentId = new set<Id>();
        list<Id> lstResidentId = new list<Id>();
        map<Id,Id> mapResidentActiveOcc = new map<Id,Id>();
        map<Id,Id> mapResidentNextActiveOcc = new map<Id,Id>();
        list<Occupancy__c> lstOccMoveOut = new list<Occupancy__c>();
        for (Occupancy__c objOcc : lstOcc)
          if (string.isNotBlank(objOcc.Resident__c)){
            setOccId.add(objOcc.Id);
            lstResidentId.add(objOcc.Resident__c);
            if (isOccActive(objOcc))
              mapResidentActiveOcc.put(objOcc.Resident__c, objOcc.Id);
            else{
              lstOccMoveOut.add(objOcc);
              setResidentId.add(objOcc.Resident__c);
              if (isOccNextActive(objOcc)){
                if (!mapResidentNextActiveOcc.containsKey(objOcc.Resident__c))
                  mapResidentNextActiveOcc.put(objOcc.Resident__c, objOcc.Id);
                else if (mapResidentNextActiveOcc.get(objOcc.Resident__c)<objOcc.Id)
                  mapResidentNextActiveOcc.put(objOcc.Resident__c, objOcc.Id);
              }
            }
          }
        if (!setResidentId.isEmpty())
          for (Occupancy__c objOcc : [SELECT Id, Resident__c, Move_In_Date__c, Move_Out_Date__c FROM Occupancy__c 
                          WHERE Id NOT IN :setOccId AND Resident__c IN :setResidentId AND Move_In_Date__c != null AND Move_In_Date__c <= TODAY ORDER BY Move_In_Date__c]){
            if (isOccActive(objOcc))
              mapResidentActiveOcc.put(objOcc.Resident__c, objOcc.Id);
            else{
              if (isOccNextActive(objOcc)){
                if (!mapResidentNextActiveOcc.containsKey(objOcc.Resident__c))
                  mapResidentNextActiveOcc.put(objOcc.Resident__c, objOcc.Id);
                else if (mapResidentNextActiveOcc.get(objOcc.Resident__c)<objOcc.Id)
                  mapResidentNextActiveOcc.put(objOcc.Resident__c, objOcc.Id);
              }
            }
          }
        list<Contact> lstResident = new list<Contact>();
        if (!lstResidentId.isEmpty())
          for (Contact objCont : [SELECT Id, Current_Active_Occupancy__c FROM Contact WHERE Id IN :lstResidentId]){
            if (mapResidentActiveOcc.containsKey(objCont.Id))
              objCont.Current_Active_Occupancy__c=mapResidentActiveOcc.get(objCont.Id);
            else if (mapResidentNextActiveOcc.containsKey(objCont.Id))
              objCont.Current_Active_Occupancy__c=mapResidentNextActiveOcc.get(objCont.Id);
            else
              objCont.Current_Active_Occupancy__c=null;
            lstResident.add(objCont);
          }
        if (!lstResident.isEmpty())
          update lstResident;
        if (!lstOccMoveOut.isEmpty())
          UpdateOppMoveOut(lstOccMoveOut);
      }
  }

  private static void UpdateOppMoveOut(list<Occupancy__c> lstOccMoveOut){
    if (lstOccMoveOut!=null)
      if (!lstOccMoveOut.isEmpty()){
        set<Id> setOccId = new set<Id>();
        set<Id> setOppId = new set<Id>();
        map<Id,Occupancy__c> mapOppIdMoveOutOcc = new map<Id,Occupancy__c>();
        for (Occupancy__c objOcc : lstOccMoveOut)
          if (string.isNotBlank(objOcc.Source_Opportunity__c)) if (objOcc.Move_Out_Date__c!=null){
            setOppId.add(objOcc.Source_Opportunity__c);
            setOccId.add(objOcc.Id);
            if (!mapOppIdMoveOutOcc.containsKey(objOcc.Source_Opportunity__c))
              mapOppIdMoveOutOcc.put(objOcc.Source_Opportunity__c,objOcc);
            else if (objOcc.Move_Out_Date__c > mapOppIdMoveOutOcc.get(objOcc.Source_Opportunity__c).Move_Out_Date__c)
              mapOppIdMoveOutOcc.put(objOcc.Source_Opportunity__c,objOcc);
          }
        if (!setOppId.isEmpty()){
          for (Occupancy__c objOcc : [SELECT Id, Move_Out_Reason__c, Scheduled_Move_In_Date__c, Move_In_Date__c, Move_Out_Date__c, Source_Opportunity__c FROM Occupancy__c WHERE Id NOT IN :setOccId AND Source_Opportunity__c IN :setOppId]){
            boolean isActive = false;
            if (objOcc.Move_Out_Date__c==null)
              isActive=true;
            else if (objOcc.Move_Out_Date__c>date.today())
              isActive=true;
            if (isActive){
              if (mapOppIdMoveOutOcc.containsKey(objOcc.Source_Opportunity__c))
                mapOppIdMoveOutOcc.remove(objOcc.Source_Opportunity__c);
            }
            else{
              if (mapOppIdMoveOutOcc.containsKey(objOcc.Source_Opportunity__c))
                if (objOcc.Move_Out_Date__c > mapOppIdMoveOutOcc.get(objOcc.Source_Opportunity__c).Move_Out_Date__c)
                  mapOppIdMoveOutOcc.put(objOcc.Source_Opportunity__c,objOcc);
            }
          }
        }
        if (!mapOppIdMoveOutOcc.isEmpty()){
          string strMoveOutStage = 'Move Out';
          list<Opportunity> lstUpdate = new list<Opportunity>();
            for (Opportunity objOpp : [SELECT Id, Move_Out_Discharge_Date__c, Move_Out_Reason__c, StageName, Housing_Type__c, RecordTypeId FROM Opportunity WHERE Id IN :mapOppIdMoveOutOcc.keySet()]){
                strMoveOutStage = OccTrigHelper.GetOppStage('Move Out', objOpp.RecordTypeId, objOpp.Housing_Type__c);
                if (!(strMoveOutStage.equalsIgnoreCase(objOpp.StageName))){
                  objOpp.StageName = strMoveOutStage;
                  objOpp.Move_Out_Discharge_Date__c = mapOppIdMoveOutOcc.get(objOpp.Id).Move_Out_Date__c;
                  objOpp.Move_Out_Reason__c = mapOppIdMoveOutOcc.get(objOpp.Id).Move_Out_Reason__c;
                  lstUpdate.add(objOpp);
                }
            }
          if (!lstUpdate.isEmpty())
            update lstUpdate;
        }
      }
  }

  private static boolean isOccActive(Occupancy__c objOcc){
    boolean isActive = false;
    if (objOcc!=null)
      if (objOcc.Move_In_Date__c!=null)
        if (objOcc.Move_In_Date__c<=date.today()){
          if (objOcc.Move_Out_Date__c==null)
            isActive=true;
          else if (objOcc.Move_Out_Date__c>date.today())
            isActive=true;
        }
    return isActive;
  }

  private static boolean isOccNextActive(Occupancy__c objOcc){
    boolean isActive = false;
    if (objOcc!=null)
      if (objOcc.Move_In_Date__c!=null)
        if (objOcc.Move_In_Date__c<=date.today()){
            isActive=true;
        }
    return isActive;
  }

  private static void OccTriggerApplyChangetoCouple(){
    if (trigger.isBefore)
      if (trigger.isUpdate){
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        set<Id> setOccId = new set<Id>();
        set<Id> setOppId = new set<Id>();
        set<Id> setUnitId = new set<Id>();
        set<Id> setResident = new set<Id>();
        set<string> setLevelOfCare = new set<string>();
        map<Id,string> mapIdKey = new map<Id,string>(); 
        map<string,Occupancy__c> mapKeyOccupancy = new map<string,Occupancy__c>();
        for (Occupancy__c objOcc : (list<Occupancy__c>)trigger.New){
          setOccId.add(objOcc.Id);
          if (objOcc.Apply_Change_to_Couple__c){
            objOcc.Apply_Change_to_Couple__c = false;
            lstOcc.add(objOcc);
            Occupancy__c objOldOcc = (Occupancy__c)trigger.oldMap.get(objOcc.Id);
            string strKey = '';
            if (string.isNotBlank(objOcc.Source_Opportunity__c)){
              setOppId.add(objOcc.Source_Opportunity__c);
              strKey += string.valueOf(Id.valueOf(string.valueOf(objOcc.Source_Opportunity__c)));
            }
            if (string.isNotBlank(objOldOcc.Level_of_Care__c)){
              setLevelOfCare.add(objOldOcc.Level_of_Care__c);
              if (string.isNotBlank(strKey))
                strKey += (':'+(objOldOcc.Level_of_Care__c).trim().tolowerCase());
            }
            if (string.isNotBlank(objOldOcc.Apartment__c)){
              setUnitId.add(objOldOcc.Apartment__c);
              if (string.isNotBlank(strKey))
                strKey += (':'+string.valueOf(Id.valueOf(string.valueOf(objOldOcc.Apartment__c))));
            }
            if (string.isNotBlank(strKey))
              mapIdKey.put(objOcc.Id,strKey);
            if (string.isNotBlank(objOcc.Resident__c)){
              setResident.add(objOcc.Resident__c);
            }
          }
        }
        if (!lstOcc.isEmpty()) if (!setOppId.isEmpty()) if (!mapIdKey.isEmpty()){
          for (Occupancy__c tmpOcc : [SELECT Id, Apartment__c, Level_of_Care__c, Resident__c, Bed__c, RecordTypeId, Move_In_Date__c, 
             Last_Change_Date__c, Move_Out_Transfer_Type__c, Move_Out_Date__c, Source_Opportunity__c, Move_Out_Reason__c, Transfer_Apartment__c, Scheduled_Move_In_Date__c, Scheduled_Move_Out_Date__c
            FROM Occupancy__c WHERE Id NOT IN :setOccId AND Resident__c NOT IN :setResident AND Source_Opportunity__c IN :setOppId AND Apartment__c IN :setUnitId AND (Level_of_Care__c = null OR Level_of_Care__c IN :setLevelOfCare)]){
              string strKey = '';
              if (string.isNotBlank(tmpOcc.Source_Opportunity__c)){
                strKey += string.valueOf(Id.valueOf(string.valueOf(tmpOcc.Source_Opportunity__c)));
              }
              if (string.isNotBlank(tmpOcc.Level_of_Care__c)){
                if (string.isNotBlank(strKey))
                  strKey += (':'+(tmpOcc.Level_of_Care__c).trim().tolowerCase());
              }
              if (string.isNotBlank(tmpOcc.Apartment__c)){
                if (string.isNotBlank(strKey))
                  strKey += (':'+string.valueOf(Id.valueOf(string.valueOf(tmpOcc.Apartment__c))));
              }
              if (string.isNotBlank(strKey))
                mapKeyOccupancy.put(strKey,tmpOcc);
            }
          if (!mapKeyOccupancy.isEmpty()){
            list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>(); 
            for (Occupancy__c objOcc : lstOcc) if (mapIdKey.containsKey(objOcc.Id)) if (mapKeyOccupancy.containsKey(mapIdKey.get(objOcc.Id))){
              Occupancy__c objOldOcc = (Occupancy__c)trigger.oldMap.get(objOcc.Id);
              Occupancy__c objCoupleOcc = mapKeyOccupancy.get(mapIdKey.get(objOcc.Id));
              boolean changed = false;
              if (!isFldEqual(objOcc.Apartment__c,objOldOcc.Apartment__c)){
                objCoupleOcc.Apartment__c=objOcc.Apartment__c;
                changed = true;
              }
              if (!isFldEqual(objOcc.Level_of_Care__c,objOldOcc.Level_of_Care__c)){
                objCoupleOcc.Level_of_Care__c=objOcc.Level_of_Care__c;changed = true;
              }
              if (!isFldEqual(objOcc.Move_In_Date__c,objOldOcc.Move_In_Date__c)){
                objCoupleOcc.Move_In_Date__c=objOcc.Move_In_Date__c;changed = true;
              }
              if (!isFldEqual(objOcc.Move_Out_Date__c,objOldOcc.Move_Out_Date__c)){
                objCoupleOcc.Move_Out_Date__c=objOcc.Move_Out_Date__c;changed = true;
              }
              if (!isFldEqual(objOcc.Bed__c,objOldOcc.Bed__c)){
                objCoupleOcc.Bed__c=objOcc.Bed__c;changed = true;
              }
              if (!isFldEqual(objOcc.Move_Out_Reason__c,objOldOcc.Move_Out_Reason__c)){
                objCoupleOcc.Move_Out_Reason__c=objOcc.Move_Out_Reason__c;changed = true;
              }
              if (!isFldEqual(objOcc.Scheduled_Move_In_Date__c,objOldOcc.Scheduled_Move_In_Date__c)){
                objCoupleOcc.Scheduled_Move_In_Date__c=objOcc.Scheduled_Move_In_Date__c;changed = true;
              }
              if (!isFldEqual(objOcc.Scheduled_Move_Out_Date__c,objOldOcc.Scheduled_Move_Out_Date__c)){
                objCoupleOcc.Scheduled_Move_Out_Date__c=objOcc.Scheduled_Move_Out_Date__c;changed = true;
              }
              if (!isFldEqual(objOcc.Transfer_Apartment__c,objOldOcc.Transfer_Apartment__c)){
                objCoupleOcc.Transfer_Apartment__c=objOcc.Transfer_Apartment__c;changed = true;
              }
              if (!isFldEqual(objOcc.Transfer_Bed__c,objOldOcc.Transfer_Bed__c)){
                objCoupleOcc.Transfer_Bed__c=objOcc.Transfer_Bed__c;changed = true;
              }
              if (!isFldEqual(objOcc.Transfer_Level_of_Care__c,objOldOcc.Transfer_Level_of_Care__c)){
                objCoupleOcc.Transfer_Level_of_Care__c=objOcc.Transfer_Level_of_Care__c;changed = true;
              }
              if (changed){
                objCoupleOcc.Last_Change_Date__c=objOcc.Last_Change_Date__c;
                lstUpdateOcc.add(objCoupleOcc);
              }
            }
            if (!lstUpdateOcc.isEmpty())
              update lstUpdateOcc;
          }
        }
      }
  }

  private static void UpdateOccPrimaryFld(list<Occupancy__c> lstOcc, set<Id> setApartmentId){
    if (lstOcc!=null) if (setApartmentId!=null) if (!lstOcc.isEmpty()) if (!setApartmentId.isEmpty()){
      set<Id> setOccId = new set<Id>();
      for (Occupancy__c o : lstOcc)
        setOccId.add(o.Id);
      list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
      map<Id,list<Occupancy__c>> mapApptOcc = new map<Id,list<Occupancy__c>>();
      for (Occupancy__c tmpOcc : [SELECT Id, Apartment__c, Move_In_Date__c, Is_Primary__c FROM Occupancy__c WHERE Apartment__c IN :setApartmentId AND Move_In_Date__c != Null AND (Move_Out_Date__c = null OR Move_Out_Date__c > TODAY) ORDER BY Move_In_Date__c, Id]){
        if (mapApptOcc.containsKey(tmpOcc.Apartment__c))
          mapApptOcc.get(tmpOcc.Apartment__c).add(tmpOcc);
        else
          mapApptOcc.put(tmpOcc.Apartment__c,new list<Occupancy__c>{tmpOcc});
      }
      if (!mapApptOcc.isEmpty())
        for (Id ApptId : mapApptOcc.keySet()){
          if (mapApptOcc.get(ApptId).size()==1){
            if (mapApptOcc.get(ApptId).get(0).Is_Primary__c==false)
              if (!setOccId.contains(mapApptOcc.get(ApptId).get(0).Id)){
                mapApptOcc.get(ApptId).get(0).Is_Primary__c=true;
                lstUpdateOcc.add(mapApptOcc.get(ApptId).get(0));
              }
          }
          else{
            integer intnP = 0;
            for (Occupancy__c tmpOcc : mapApptOcc.get(ApptId))
              if (tmpOcc.Is_Primary__c)
                intnP++;
            if (intnP==0){
              for (Occupancy__c tmpOcc : mapApptOcc.get(ApptId))
                if (!setOccId.contains(tmpOcc.Id)){
                  tmpOcc.Is_Primary__c=true;
                  lstUpdateOcc.add(tmpOcc); break;
                }
            }
            else if (intnP>=2){
              for (Occupancy__c tmpOcc : mapApptOcc.get(ApptId))
                if (!setOccId.contains(tmpOcc.Id)){
                  tmpOcc.Is_Primary__c=false;
                  lstUpdateOcc.add(tmpOcc);
                  break;
                }
            }
          }
        }
        if (!lstUpdateOcc.isEmpty())
          update lstUpdateOcc;
    }
  }

  private static void CreateOccLogUpdate(list<Occupancy__c> lstOcc, set<Id> setApartmentId){
    if (lstOcc!=null)
      if (!lstOcc.isEmpty()){
        list<Id> lstOccId = new list<Id>();
        for (Occupancy__c objOcc : lstOcc)
          lstOccId.add(objOcc.Id);
        if (!lstOccId.isEmpty()){
          map<Id,Occupancy_Log__c> mapOccIdToLog = new map<Id,Occupancy_Log__c>();
          map<Id,Occupancy_Log__c> mapOccIdToLogMoveIn = new map<Id,Occupancy_Log__c>();
          for (Occupancy_Log__c oLog : [SELECT Id, Occupancy__c, Occupancy__r.Apartment__c, End_Date__c, Bed__c, Apartment__c, Level_of_Care__c, Resident__c, Start_Date__c, Move_Out_Reason__c FROM Occupancy_Log__c WHERE Occupancy__c IN :lstOccId ORDER By Occupancy__c, Id]){
            if (oLog.Start_Date__c!=null)
              if (oLog.End_Date__c==null)
                mapOccIdToLog.put(oLog.Occupancy__c, oLog);
            if (oLog.Apartment__c!=null){
              if (!mapOccIdToLogMoveIn.containsKey(oLog.Apartment__c)){
                if (oLog.Apartment__c==oLog.Occupancy__r.Apartment__c)
                  mapOccIdToLogMoveIn.put(oLog.Occupancy__c, oLog);
              }
              else if (oLog.Apartment__c!=oLog.Occupancy__r.Apartment__c)
                mapOccIdToLogMoveIn.clear();
            }
          }
          list<Occupancy_Log__c> lstLog = new list<Occupancy_Log__c>();
          Id TransferRecordTypeId = Null;
          try{TransferRecordTypeId = Occupancy_Log__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Transfer').getRecordTypeId();}catch (Exception e){system.debug(e);}
          for (Occupancy__c objOcc : lstOcc){
            boolean MoveOutFlag = false;
            Occupancy_Log__c objOccLogTemp = null;
            if (mapOccIdToLog.containsKey(objOcc.Id)){
              objOccLogTemp = mapOccIdToLog.get(objOcc.Id);
              if (isFldEqual(objOccLogTemp.Apartment__c,objOcc.Apartment__c))
                if (isFldEqual(objOccLogTemp.Level_of_Care__c,objOcc.Level_of_Care__c))
                  if (isFldEqual(objOccLogTemp.Resident__c,objOcc.Resident__c))
                    if (isFldEqual(objOccLogTemp.Bed__c,objOcc.Bed__c))
                      if (objOcc.Move_Out_Date__c != null)
                        MoveOutFlag = true;
            }
            boolean EditMoveInFlag = false;
            Occupancy_Log__c objOccLogTempM = null;
            if (mapOccIdToLogMoveIn.containsKey(objOcc.Id)){
              objOccLogTempM = mapOccIdToLogMoveIn.get(objOcc.Id);
              if (objOcc.Move_In_Date__c != null)
                if (objOccLogTempM.Start_Date__c != null)
                  if (objOccLogTempM.Start_Date__c != objOcc.Move_In_Date__c)
                    EditMoveInFlag = true;
            }
            if ((!MoveOutFlag)&&(!EditMoveInFlag)){
              Occupancy_Log__c oLog = new Occupancy_Log__c(Occupancy__c=objOcc.Id,
                      Apartment__c = objOcc.Apartment__c,
                      Level_of_Care__c = objOcc.Level_of_Care__c,
                      Resident__c = objOcc.Resident__c,
                      Bed__c = objOcc.Bed__c,
                      Start_Date__c = objOcc.Last_Change_Date__c!=null?objOcc.Last_Change_Date__c:date.today(),
                      RecordTypeId=TransferRecordTypeId);
              if (objOcc.Move_Out_Date__c != null){
                oLog.End_Date__c = objOcc.Move_Out_Date__c;
                oLog.Move_Out_Reason__c = objOcc.Move_Out_Reason__c;
              }
              lstLog.add(oLog);
              if (mapOccIdToLog.containsKey(objOcc.Id)){
                mapOccIdToLog.get(objOcc.Id).End_Date__c=oLog.Start_Date__c;
                lstLog.add(mapOccIdToLog.get(objOcc.Id));
              }
            }
            else if (MoveOutFlag){
              if (objOccLogTemp!=null){
                if (objOcc.Move_Out_Date__c != null){
                  objOccLogTemp.End_Date__c = objOcc.Move_Out_Date__c;
                  objOccLogTemp.Move_Out_Reason__c = objOcc.Move_Out_Reason__c;
                }
                if (EditMoveInFlag)
                  if (objOccLogTempM!=null)
                    if (objOccLogTempM==objOccLogTemp)
                      objOccLogTemp.Start_Date__c = objOcc.Move_In_Date__c;
                lstLog.add(objOccLogTemp);
              }
            }
            else if (EditMoveInFlag)
              if (objOccLogTempM!=null){
                objOccLogTempM.Start_Date__c = objOcc.Move_In_Date__c;
                lstLog.add(objOccLogTempM);
              }
          }
          if (!lstLog.isEmpty()){
            skipOccLogTrigger = true;
            upsert lstLog;
            skipOccLogTrigger = false;
            if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
              CallUpdateUnitStatus(new list<Id>(setApartmentId), false);
          }
        }
        UpdateOccPrimaryFld(lstOcc, setApartmentId);
        UpdateCurrentActiveOccupancy(lstOcc);
      }
  }

  private static void CreateOccLogInsert(list<Occupancy__c> lstOcc, set<Id> setApartmentId){
    list<Occupancy_Log__c> lstLog = new list<Occupancy_Log__c>();
    Id InitialMoveInRecordTypeId = Null;
    try{InitialMoveInRecordTypeId = Occupancy_Log__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Initial Move In').getRecordTypeId();}catch (Exception e){system.debug(e);}
    if (lstOcc!=null)
      if (!lstOcc.isEmpty())
        for (Occupancy__c objOcc : lstOcc){
            Occupancy_Log__c oLog = new Occupancy_Log__c(Occupancy__c=objOcc.Id,
                    Apartment__c = objOcc.Apartment__c,
                    Level_of_Care__c = objOcc.Level_of_Care__c,
                    Resident__c = objOcc.Resident__c,
                    Bed__c = objOcc.Bed__c,
                    Start_Date__c = objOcc.Move_In_Date__c!=null?objOcc.Move_In_Date__c:date.today(),
                    RecordTypeId=InitialMoveInRecordTypeId);
            lstLog.add(oLog);
        }
    if (!lstLog.isEmpty()){
      skipOccLogTrigger = true;
      insert lstLog;
      skipOccLogTrigger = false;
      if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
        CallUpdateUnitStatus(new list<Id>(setApartmentId), false);
    }
    UpdateOccPrimaryFld(lstOcc, setApartmentId);
    UpdateCurrentActiveOccupancy(lstOcc);
  }

  private static void CallCreateOccLogUpdate(list<Occupancy__c> lstOcc, set<Id> setApartmentId, boolean UseFuture){
    if ((Test.isRunningTest())||(system.isFuture())||(system.isBatch())||(!(UseFuture)))
      CreateOccLogUpdate(lstOcc, setApartmentId);
    else{
      list<Id> lstOccId = new list<Id>();
      for (Occupancy__c objOcc : lstOcc)
        lstOccId.add(objOcc.Id);
      FutureCreateOccLogUpdateId(lstOccId, setApartmentId);
    }
  }

  @future
  public static void FutureCreateOccLogUpdateId(list<Id> lstOccId, set<Id> setApartmentId){
    CreateOccLogUpdateId(lstOccId, setApartmentId);
  }

  private static void CreateOccLogUpdateId(list<Id> lstOccId, set<Id> setApartmentId){
    if (lstOccId!=null)
      if (!lstOccId.isEmpty()){
        list<Occupancy__c> lstOcc = [SELECT Id, Apartment__c, Level_of_Care__c, Resident__c, Bed__c, RecordTypeId, Move_In_Date__c, 
             Last_Change_Date__c, Move_Out_Transfer_Type__c, Move_Out_Date__c, Source_Opportunity__c, Move_Out_Reason__c
            FROM Occupancy__c WHERE Id IN :lstOccId];
        if (lstOcc!=null) if (!lstOcc.isEmpty())
            CreateOccLogUpdate(lstOcc, setApartmentId);
      }
  }

  private static boolean isFldEqual(object val1, object val2){
    if ((val1==null)&&(val2==null)) return true;
    else if ((val1==null)||(val2==null)) return false;
    else if (val1==val2) return true;
    else return false;
  }

  private static void CallCreateOccLogInsert(list<Occupancy__c> lstOcc, set<Id> setApartmentId, boolean UseFuture){
    if ((Test.isRunningTest())||(system.isFuture())||(system.isBatch())||(!(UseFuture)))
      CreateOccLogInsert(lstOcc, setApartmentId);
    else{
      list<Id> lstOccId = new list<Id>();
      for (Occupancy__c objOcc : lstOcc)
        lstOccId.add(objOcc.Id);
      FutureCreateOccLogInsertId(lstOccId, setApartmentId);
    }
  }

  @future
  public static void FutureCreateOccLogInsertId(list<Id> lstOccId, set<Id> setApartmentId){
    CreateOccLogInsertId(lstOccId, setApartmentId);
  }

  private static void CreateOccLogInsertId(list<Id> lstOccId, set<Id> setApartmentId){
    if (lstOccId!=null)
      if (!lstOccId.isEmpty()){
        list<Occupancy__c> lstOcc = [SELECT Id, Apartment__c, Level_of_Care__c, Resident__c, Bed__c, RecordTypeId, Move_In_Date__c, 
             Last_Change_Date__c, Move_Out_Transfer_Type__c, Move_Out_Date__c, Source_Opportunity__c  
            FROM Occupancy__c WHERE Id IN :lstOccId];
        if (lstOcc!=null) if (!lstOcc.isEmpty())
            CreateOccLogInsert(lstOcc, setApartmentId);
      }
  }

  public static boolean CalledOppTriggerOnce = false;
  public static void OppTrigger(boolean UseFuture){
    if (CalledOppTriggerOnce) return;
    list<Opportunity> lstOpp = new list<Opportunity>();
    if (trigger.isAfter)
      for (Opportunity objOpp : (list<Opportunity>)trigger.New) if (objOpp.Create_Occupancy__c){
        if (trigger.isInsert){
          if ((objOpp.Move_In_Date__c!=null)||(objOpp.Expected_Move_In_Date__c!=null))
            lstOpp.add(objOpp);
        }
        else if (trigger.isUpdate){
          if (  objOpp.Force_Occupancy_Trigger__c ||  (!(isFldEqual(objOpp.Move_In_Date__c,((Opportunity)trigger.oldMap.get(objOpp.Id)).Move_In_Date__c)))
            ||(!(isFldEqual(objOpp.Expected_Move_In_Date__c,((Opportunity)trigger.oldMap.get(objOpp.Id)).Expected_Move_In_Date__c)))
            )
            lstOpp.add(objOpp);
        }
      }
    if (!lstOpp.isEmpty()){
      CallCreateOccforOpp(lstOpp, UseFuture);
      CalledOppTriggerOnce=true;
    }
  }

  private static void CallCreateOccforOpp(list<Opportunity> lstOpp, boolean UseFuture){
    if ((Test.isRunningTest())||(system.isFuture())||(system.isBatch())||(!(UseFuture)))
      UpsertOccforOpp(lstOpp);
    else{
      list<Id> lstOppId = new list<Id>();
      for (Opportunity objOpp : lstOpp)
        lstOppId.add(objOpp.Id);
      FutureCreateOccforOppId(lstOppId);
    }
  }

  @future
  public static void FutureCreateOccforOppId(list<Id> lstOppId){
    CreateOccforOppId(lstOppId);
  }

  private static void CreateOccforOppId(list<Id> lstOppId){
    if (lstOppId!=null) 
      if (!lstOppId.isEmpty()){
        list<Opportunity> lstOpp = [SELECT Id, Name, Primary_Resident__c, Unit__c, Housing_Type__c, Move_In_Date__c, Expected_Move_In_Date__c, Second_Resident__c FROM Opportunity WHERE Id IN :lstOppId];
        if (lstOpp!=null) if (!lstOpp.isEmpty())
            UpsertOccforOpp(lstOpp);
      }
  }

  private static void UpsertOccforOpp(list<Opportunity> lstOpp){
    set<Id> setContId = new set<Id>();
    set<Id> setApartmentId = new set<Id>();
    set<Id> setOppId = new set<Id>();
    for (Opportunity objOpp : lstOpp){
      if (string.isNotBlank(objOpp.Primary_Resident__c))
        setContId.add(objOpp.Primary_Resident__c);
      if (string.isNotBlank(objOpp.Second_Resident__c))
        setContId.add(objOpp.Second_Resident__c);
      if (string.isNotBlank(objOpp.Unit__c))
        setApartmentId.add(objOpp.Unit__c);
      setOppId.add(objOpp.Id);
    }
    map<Id,string> mapContName = new map<Id,string>();
    if (!setContId.isEmpty())
      for (Contact cont : [SELECT Id, Name FROM Contact WHERE Id IN :setContId])
        mapContName.put(cont.Id, cont.Name);
    map<Id,string> mapApartmentName = new map<Id,string>();
    if (!setApartmentId.isEmpty())
      for (Unit__c oUnit : [SELECT Id, Name FROM Unit__c WHERE Id IN :setApartmentId])
        mapApartmentName.put(oUnit.Id, oUnit.Name);
    set<Id> setOccupiedUnits = new set<Id>();
    set<Id> setOccupiedOpps = new set<Id>();
    map<string,Occupancy__c> mapKeyOcc = new map<string,Occupancy__c>(); 
    for (Occupancy__c tmpOcc : [SELECT Apartment__c, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Transfer_Type__c, 
                    Move_Out_Date__c, Move_Out_Reason__c, Resident__c, Scheduled_Move_In_Date__c, Scheduled_Move_Out_Date__c, 
                    Source_Opportunity__c, Transfer_Apartment__c, Transfer_Bed__c, Last_Change_Date__c, 
                    Transfer_Level_of_Care__c, Name, Id FROM Occupancy__c 
                    WHERE Resident__c != Null AND (Apartment__c IN :setApartmentId OR Source_Opportunity__c IN :setOppId) ]){
      if (string.isNotBlank(tmpOcc.Apartment__c))
        if (tmpOcc.Move_In_Date__c!=null)
          if (tmpOcc.Move_Out_Date__c==null)
            setOccupiedUnits.add(tmpOcc.Apartment__c);
      if (string.isNotBlank(tmpOcc.Source_Opportunity__c)){
        setOccupiedOpps.add(tmpOcc.Source_Opportunity__c);
        mapKeyOcc.put(Id.valueOf(tmpOcc.Source_Opportunity__c)+':'+Id.valueOf(tmpOcc.Resident__c),tmpOcc);
      }
    }
    list<Occupancy__c> lstOcc = new list<Occupancy__c>();
    set<Id> setOccChk = new set<Id>();
    list<Occupancy__c> lstOccDel = new list<Occupancy__c>();
    Id InitialOccupancyRecordTypeId = Null;
    try{InitialOccupancyRecordTypeId = Occupancy__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Initial Occupancy').getRecordTypeId();}catch (Exception e){system.debug(e);}
    for (Opportunity objOpp : lstOpp) if (string.isNotBlank(objOpp.Primary_Resident__c)){ 
      if (!setOccupiedOpps.contains(objOpp.Id)){
        if ((objOpp.Move_In_Date__c!=null)||(objOpp.Expected_Move_In_Date__c!=null)){
          Occupancy__c objOcc = new Occupancy__c(Source_Opportunity__c=objOpp.Id, 
                        RecordTypeId = InitialOccupancyRecordTypeId,
                        Apartment__c=objOpp.Unit__c,
                        Level_of_Care__c=objOpp.Housing_Type__c,
                        Move_In_Date__c=objOpp.Move_In_Date__c,
                        Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c,
                        Resident__c=objOpp.Primary_Resident__c);
          string strName = '';
          if (string.isNotBlank(objOcc.Resident__c))
            if (mapContName.containsKey(objOcc.Resident__c))
              strName = mapContName.get(objOcc.Resident__c);
          if (string.isNotBlank(objOcc.Apartment__c))
            if (mapApartmentName.containsKey(objOcc.Apartment__c))
              strName = (string.isBlank(strName)?'':strName + ' : ') + mapApartmentName.get(objOcc.Apartment__c);
          if (objOcc.Move_In_Date__c!=null)
            strName = (string.isBlank(strName)?'':strName + ' : ') + datetime.newInstance(objOcc.Move_In_Date__c.year(),objOcc.Move_In_Date__c.month(),objOcc.Move_In_Date__c.day()).format('MMM dd, yyyy');
          else if (objOcc.Scheduled_Move_In_Date__c!=null)
            strName = (string.isBlank(strName)?'':strName + ' : ') + datetime.newInstance(objOcc.Scheduled_Move_In_Date__c.year(),objOcc.Scheduled_Move_In_Date__c.month(),objOcc.Scheduled_Move_In_Date__c.day()).format('MMM dd, yyyy');
          objOcc.Name = strName; 
          if (string.isNotBlank(objOpp.Second_Resident__c))
            objOcc.Is_Primary__c = true;
          else if (!setOccupiedUnits.contains(objOcc.Apartment__c))
            objOcc.Is_Primary__c = true;
          else objOcc.Is_Primary__c = false;
          lstOcc.add(objOcc);
          if (string.isNotBlank(objOpp.Second_Resident__c)){
            Occupancy__c objOccS = new Occupancy__c(Source_Opportunity__c=objOpp.Id, 
                          RecordTypeId = InitialOccupancyRecordTypeId,
                          Apartment__c=objOpp.Unit__c,
                          Level_of_Care__c=objOpp.Housing_Type__c,
                          Move_In_Date__c=objOpp.Move_In_Date__c,
                          Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c,
                          Resident__c=objOpp.Second_Resident__c);
            string strNameS = '';
            if (string.isNotBlank(objOccS.Resident__c))
              if (mapContName.containsKey(objOccS.Resident__c))
                strNameS = mapContName.get(objOccS.Resident__c);
            if (string.isNotBlank(objOccS.Apartment__c))
              if (mapApartmentName.containsKey(objOccS.Apartment__c))
                strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + mapApartmentName.get(objOccS.Apartment__c);
            if (objOccS.Move_In_Date__c!=null)
              strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + datetime.newInstance(objOccS.Move_In_Date__c.year(),objOccS.Move_In_Date__c.month(),objOccS.Move_In_Date__c.day()).format('MMM dd, yyyy');
            else if (objOccS.Scheduled_Move_In_Date__c!=null)
              strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + datetime.newInstance(objOccS.Scheduled_Move_In_Date__c.year(),objOccS.Scheduled_Move_In_Date__c.month(),objOccS.Scheduled_Move_In_Date__c.day()).format('MMM dd, yyyy');
            objOccS.Name = strNameS; 
            objOccS.Is_Primary__c = false;
            lstOcc.add(objOccS);
          }
        }
      }
      else{
        if ((objOpp.Move_In_Date__c!=null)||(objOpp.Expected_Move_In_Date__c!=null)){
          string strKey1 = Id.valueOf(objOpp.Id)+':'+Id.valueOf(objOpp.Primary_Resident__c);
          Occupancy__c objOcc = null;
          if (!mapKeyOcc.containsKey(strKey1)){
            objOcc = new Occupancy__c(Source_Opportunity__c=objOpp.Id, 
                        RecordTypeId = InitialOccupancyRecordTypeId,
                        Apartment__c=objOpp.Unit__c,
                        Level_of_Care__c=objOpp.Housing_Type__c,
                        Move_In_Date__c=objOpp.Move_In_Date__c,
                        Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c,
                        Resident__c=objOpp.Primary_Resident__c);
            string strName = '';
            if (string.isNotBlank(objOcc.Resident__c))
              if (mapContName.containsKey(objOcc.Resident__c))
                strName = mapContName.get(objOcc.Resident__c);
            if (string.isNotBlank(objOcc.Apartment__c))
              if (mapApartmentName.containsKey(objOcc.Apartment__c))
                strName = (string.isBlank(strName)?'':strName + ' : ') + mapApartmentName.get(objOcc.Apartment__c);
            if (objOcc.Move_In_Date__c!=null)
              strName = (string.isBlank(strName)?'':strName + ' : ') + datetime.newInstance(objOcc.Move_In_Date__c.year(),objOcc.Move_In_Date__c.month(),objOcc.Move_In_Date__c.day()).format('MMM dd, yyyy');
            else if (objOcc.Scheduled_Move_In_Date__c!=null)
              strName = (string.isBlank(strName)?'':strName + ' : ') + datetime.newInstance(objOcc.Scheduled_Move_In_Date__c.year(),objOcc.Scheduled_Move_In_Date__c.month(),objOcc.Scheduled_Move_In_Date__c.day()).format('MMM dd, yyyy');
            objOcc.Name = strName; 
            if (string.isNotBlank(objOpp.Second_Resident__c))
              objOcc.Is_Primary__c = true;
            else if (!setOccupiedUnits.contains(objOcc.Apartment__c))
              objOcc.Is_Primary__c = true;
            else objOcc.Is_Primary__c = false;
          }
          else{
            objOcc = mapKeyOcc.get(strKey1);
            if (objOcc.Apartment__c==null)
              objOcc.Apartment__c=objOpp.Unit__c;
            else if ((objOcc.Apartment__c!=objOpp.Unit__c)&&(objOcc.Move_In_Date__c==null))
              objOcc.Apartment__c=objOpp.Unit__c;
            objOcc.Move_In_Date__c=objOpp.Move_In_Date__c;
            objOcc.Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c;
          }
          if (objOcc!=null){
            if (string.isBlank(objOcc.Id))
              lstOcc.add(objOcc);
            else if (!setOccChk.contains(objOcc.Id)){
              lstOcc.add(objOcc);
              setOccChk.add(objOcc.Id);
            }
          }
          if (string.isNotBlank(objOpp.Second_Resident__c)){
            string strKey2 = Id.valueOf(objOpp.Id)+':'+Id.valueOf(objOpp.Second_Resident__c);
            Occupancy__c objOccS = null;
            if (!mapKeyOcc.containsKey(strKey2)){
              objOccS = new Occupancy__c(Source_Opportunity__c=objOpp.Id, 
                          RecordTypeId = InitialOccupancyRecordTypeId,
                          Apartment__c=objOpp.Unit__c,
                          Level_of_Care__c=objOpp.Housing_Type__c,
                          Move_In_Date__c=objOpp.Move_In_Date__c,
                          Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c,
                          Resident__c=objOpp.Second_Resident__c);
              string strNameS = '';
              if (string.isNotBlank(objOccS.Resident__c))
                if (mapContName.containsKey(objOccS.Resident__c))
                  strNameS = mapContName.get(objOccS.Resident__c);
              if (string.isNotBlank(objOccS.Apartment__c))
                if (mapApartmentName.containsKey(objOccS.Apartment__c))
                  strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + mapApartmentName.get(objOccS.Apartment__c);
              if (objOccS.Move_In_Date__c!=null)
                strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + datetime.newInstance(objOccS.Move_In_Date__c.year(),objOccS.Move_In_Date__c.month(),objOccS.Move_In_Date__c.day()).format('MMM dd, yyyy');
              else if (objOccS.Scheduled_Move_In_Date__c!=null)
                strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + datetime.newInstance(objOccS.Scheduled_Move_In_Date__c.year(),objOccS.Scheduled_Move_In_Date__c.month(),objOccS.Scheduled_Move_In_Date__c.day()).format('MMM dd, yyyy');
              objOccS.Name = strNameS; 
              objOccS.Is_Primary__c = false;
            }
            else{
              objOccS = mapKeyOcc.get(strKey2);
              
              if (objOccS.Apartment__c==null)
                objOccS.Apartment__c=objOpp.Unit__c;
              else if ((objOccS.Apartment__c!=objOpp.Unit__c)&&(objOccS.Move_In_Date__c==null))
                objOccS.Apartment__c=objOpp.Unit__c;
              objOccS.Move_In_Date__c=objOpp.Move_In_Date__c;
              objOccS.Scheduled_Move_In_Date__c=objOpp.Expected_Move_In_Date__c;
            }
            if (objOccS!=null){
              if (string.isBlank(objOccS.Id))
                lstOcc.add(objOccS);
              else if (!setOccChk.contains(objOccS.Id)){
                lstOcc.add(objOccS);
                setOccChk.add(objOccS.Id);
              }
            }
          }
        }
        else{
          string strKey1 = Id.valueOf(objOpp.Id)+':'+Id.valueOf(objOpp.Primary_Resident__c);
          Occupancy__c objOcc = null;
          if (mapKeyOcc.containsKey(strKey1)){
            objOcc = mapKeyOcc.get(strKey1);
            if (objOcc.Move_Out_Date__c==null) if (objOcc.Last_Change_Date__c==null){
              lstOccDel.add(objOcc);
            }
          }
          if (string.isNotBlank(objOpp.Second_Resident__c)){
            string strKey2 = Id.valueOf(objOpp.Id)+':'+Id.valueOf(objOpp.Second_Resident__c);
            Occupancy__c objOccS = null;
            if (mapKeyOcc.containsKey(strKey2)){
              objOccS = mapKeyOcc.get(strKey2);
              if (objOccS.Move_Out_Date__c==null) if (objOccS.Last_Change_Date__c==null){
                lstOccDel.add(objOccS);
              }
            }
          }
        }
      }
    }
    if (!lstOcc.isEmpty())
      upsert lstOcc;
    if (!lstOccDel.isEmpty())
      delete lstOccDel;
  }

  public static map<Id,StatusInfo> CalcUnitStatus(list<Id> lstUnitId){
    map<Id,set<string>> mapUnitStatusSet = new map<Id,set<string>>();
    map<Id,StatusInfo> mapUnitStatus = new map<Id,StatusInfo>();
    map<Id,StatusInfo> mapUnitStatusTemp = new map<Id,StatusInfo>();
    if (!lstUnitId.isEmpty()){
      date dtToday = date.today();
      map<Id,list<Occupancy__c>> mapUnitOcc = new map<Id,list<Occupancy__c>>();
      for (Occupancy__c oLog : [SELECT Apartment__c, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Transfer_Type__c, Move_Out_Date__c, 
                  Move_Out_Reason__c, Resident__c, Scheduled_Move_In_Date__c, Scheduled_Move_Out_Date__c, Source_Opportunity__c, Transfer_Apartment__c, 
                  Transfer_Bed__c, Last_Change_Date__c, Transfer_Level_of_Care__c, Name, Id FROM Occupancy__c 
                  WHERE (Apartment__c IN :lstUnitId OR Transfer_Apartment__c IN :lstUnitId) AND (Move_In_Date__c != null OR Scheduled_Move_In_Date__c != Null) 
                  AND (Move_Out_Date__c = null OR Move_Out_Date__c > :dtToday) ORDER BY Move_In_Date__c, Move_Out_Date__c ASC NULLS LAST]){
        if (string.isNotBlank(oLog.Apartment__c)){
          if (mapUnitOcc.containsKey(oLog.Apartment__c))
            mapUnitOcc.get(oLog.Apartment__c).add(oLog);
          else
            mapUnitOcc.put(oLog.Apartment__c,new list<Occupancy__c>{oLog});
        }
        if (string.isNotBlank(oLog.Transfer_Apartment__c)){
          if (mapUnitOcc.containsKey(oLog.Transfer_Apartment__c))
            mapUnitOcc.get(oLog.Transfer_Apartment__c).add(oLog);
          else
            mapUnitOcc.put(oLog.Transfer_Apartment__c,new list<Occupancy__c>{oLog});
        }
      }
      if (!mapUnitOcc.isEmpty()){
        for (Id UnitId : mapUnitOcc.keySet()){
          for (Occupancy__c oLog : mapUnitOcc.get(UnitId)){
            if (!(oLog.Apartment__c==UnitId)){
              if (oLog.Transfer_Apartment__c==UnitId) if (oLog.Transfer_Apartment__c!=oLog.Apartment__c) if (oLog.Last_Change_Date__c!=null){
                //mapUnitStatusSet.put(UnitId,new set<string>{'Reserved'});
                if (mapUnitStatusSet.containsKey(UnitId))
                  mapUnitStatusSet.get(UnitId).add('Reserved');
                else
                  mapUnitStatusSet.put(UnitId,new set<string>{'Reserved'});
                mapUnitStatusSet.get(UnitId).add(Id.valueOf(oLog.Resident__c));
                if (!mapUnitStatusTemp.containsKey(UnitId))
                  mapUnitStatusTemp.put(UnitId,new StatusInfo('Temp'));
                if ((mapUnitStatusTemp.get(UnitId).NextOccLog1==null)&&(mapUnitStatusTemp.get(UnitId).NextOccLog2==null))
                  mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                else if ((mapUnitStatusTemp.get(UnitId).NextOccLog2==null)){
                  if (oLog.Is_Primary__c){
                    mapUnitStatusTemp.get(UnitId).NextOccLog2=mapUnitStatusTemp.get(UnitId).NextOccLog1;
                    mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                  }
                  else
                    mapUnitStatusTemp.get(UnitId).NextOccLog2=oLog.Id;
                }
              }
            }
            else {
              if (oLog.Move_In_Date__c <= dtToday){
                if ((oLog.Move_Out_Date__c > dtToday)||(oLog.Move_Out_Date__c == null)){
                  if (mapUnitStatusSet.containsKey(UnitId))
                    mapUnitStatusSet.get(UnitId).add('Occupied');
                  else
                    mapUnitStatusSet.put(UnitId,new set<string>{'Occupied'});
                  if ((oLog.Move_Out_Date__c > dtToday)){
                    mapUnitStatusSet.get(UnitId).add('FutureEnd');
                  }
                  else{
                    boolean tempflag=false;
                    if (oLog.Scheduled_Move_Out_Date__c!=null)
                      mapUnitStatusSet.get(UnitId).add('FutureEnd');
                    else if (oLog.Last_Change_Date__c!=null)
                        if (oLog.Last_Change_Date__c> dtToday)
                            if (oLog.Transfer_Apartment__c!=oLog.Apartment__c)
                                if (oLog.Transfer_Apartment__c!=null){
                                    tempflag=true;
                                    mapUnitStatusSet.get(UnitId).add('FutureEnd');
                                }
                    if (!tempflag)
                        if (oLog.Scheduled_Move_Out_Date__c==null)
                            mapUnitStatusSet.get(UnitId).add('NullEnd');
                  }
                  mapUnitStatusSet.get(UnitId).add(Id.valueOf(oLog.Resident__c));
                  if (!mapUnitStatusTemp.containsKey(UnitId))
                    mapUnitStatusTemp.put(UnitId,new StatusInfo('Temp'));
                  if ((mapUnitStatusTemp.get(UnitId).CurrentOccLog1==null)&&(mapUnitStatusTemp.get(UnitId).CurrentOccLog2==null))
                    mapUnitStatusTemp.get(UnitId).CurrentOccLog1=oLog.Id;
                  else if ((mapUnitStatusTemp.get(UnitId).CurrentOccLog2==null)){
                    if (oLog.Is_Primary__c){
                      mapUnitStatusTemp.get(UnitId).CurrentOccLog2=mapUnitStatusTemp.get(UnitId).CurrentOccLog1;
                      mapUnitStatusTemp.get(UnitId).CurrentOccLog1=oLog.Id;
                    }
                    else
                      mapUnitStatusTemp.get(UnitId).CurrentOccLog2=oLog.Id;
                  }
                }
              }
              else{
                if (mapUnitStatusSet.containsKey(UnitId)){
                  if (!(mapUnitStatusSet.get(UnitId).contains(Id.valueOf(oLog.Resident__c)))){
                    //mapUnitStatusSet.get(UnitId).add('Reserved');
                    if (mapUnitStatusSet.containsKey(UnitId))
                      mapUnitStatusSet.get(UnitId).add('Reserved');
                    else
                      mapUnitStatusSet.put(UnitId,new set<string>{'Reserved'});
                    mapUnitStatusSet.get(UnitId).add(Id.valueOf(oLog.Resident__c));
                    if (!mapUnitStatusTemp.containsKey(UnitId))
                      mapUnitStatusTemp.put(UnitId,new StatusInfo('Temp'));
                    if ((mapUnitStatusTemp.get(UnitId).NextOccLog1==null)&&(mapUnitStatusTemp.get(UnitId).NextOccLog2==null))
                      mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                    else if ((mapUnitStatusTemp.get(UnitId).NextOccLog2==null)){
                      if (oLog.Is_Primary__c){
                        mapUnitStatusTemp.get(UnitId).NextOccLog2=mapUnitStatusTemp.get(UnitId).NextOccLog1;
                        mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                      }
                      else
                        mapUnitStatusTemp.get(UnitId).NextOccLog2=oLog.Id;
                    }
                  }
                  else{
                    if ((oLog.Move_Out_Date__c > dtToday)){
                      mapUnitStatusSet.get(UnitId).add('FutureEnd');
                    }
                    else{
                        boolean tempflag=false;
                        if (oLog.Scheduled_Move_Out_Date__c!=null)
                          mapUnitStatusSet.get(UnitId).add('FutureEnd');
                        else if (oLog.Last_Change_Date__c!=null)
                            if (oLog.Last_Change_Date__c> dtToday)
                                if (oLog.Transfer_Apartment__c!=oLog.Apartment__c)
                                    if (oLog.Transfer_Apartment__c!=null){
                                        tempflag=true;
                                        mapUnitStatusSet.get(UnitId).add('FutureEnd');
                                    }
                        if (!tempflag)
                            if (oLog.Scheduled_Move_Out_Date__c==null)
                                mapUnitStatusSet.get(UnitId).add('NullEnd');
                    }
                  }
                }
                else{
                  //mapUnitStatusSet.put(UnitId,new set<string>{'Reserved'});
                  if (mapUnitStatusSet.containsKey(UnitId))
                    mapUnitStatusSet.get(UnitId).add('Reserved');
                  else
                    mapUnitStatusSet.put(UnitId,new set<string>{'Reserved'});
                  mapUnitStatusSet.get(UnitId).add(Id.valueOf(oLog.Resident__c));
                  if (!mapUnitStatusTemp.containsKey(UnitId))
                    mapUnitStatusTemp.put(UnitId,new StatusInfo('Temp'));
                  if ((mapUnitStatusTemp.get(UnitId).NextOccLog1==null)&&(mapUnitStatusTemp.get(UnitId).NextOccLog2==null))
                    mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                  else if ((mapUnitStatusTemp.get(UnitId).NextOccLog2==null)){
                    if (oLog.Is_Primary__c){
                      mapUnitStatusTemp.get(UnitId).NextOccLog2=mapUnitStatusTemp.get(UnitId).NextOccLog1;
                      mapUnitStatusTemp.get(UnitId).NextOccLog1=oLog.Id;
                    }
                    else
                      mapUnitStatusTemp.get(UnitId).NextOccLog2=oLog.Id;
                  }
                }
              }
            }
          }
        }
      }
      for (Id UnitId : lstUnitId){
        if (mapUnitStatusSet.containsKey(UnitId)){
          set<string> setStatus = mapUnitStatusSet.get(UnitId);
          if (setStatus.contains('Reserved')){
            if (setStatus.contains('Occupied')){
              if (setStatus.contains('FutureEnd')){
                if (!setStatus.contains('NullEnd')){
                  mapUnitStatus.put(UnitId,new StatusInfo('On Notice - Reserved'));
                  if (mapUnitStatusTemp.containsKey(UnitId))
                    mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
                }
              }
              else{
                mapUnitStatus.put(UnitId,new StatusInfo('Occupied'));
                if (mapUnitStatusTemp.containsKey(UnitId))
                  mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
              }
            }
            else{
              mapUnitStatus.put(UnitId,new StatusInfo('Reserved'));
              if (mapUnitStatusTemp.containsKey(UnitId))
                mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
            }
          }
          else if (setStatus.contains('Occupied'))
            if (setStatus.contains('FutureEnd'))
              if (!setStatus.contains('NullEnd')){
                mapUnitStatus.put(UnitId,new StatusInfo('On Notice'));
                if (mapUnitStatusTemp.containsKey(UnitId))
                  mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
              }
          if (!mapUnitStatus.containsKey(UnitId)){
            if (setStatus.contains('Occupied')){
              mapUnitStatus.put(UnitId,new StatusInfo('Occupied'));
              if (mapUnitStatusTemp.containsKey(UnitId))
                mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
            }
            else{
              mapUnitStatus.put(UnitId,new StatusInfo('Vacant'));
              if (mapUnitStatusTemp.containsKey(UnitId))
                mapUnitStatus.get(UnitId).SetOccLogValues(mapUnitStatusTemp.get(UnitId));
            }
          }
        }
        else{
          mapUnitStatus.put(UnitId,new StatusInfo('Vacant'));
        }
      }
    }
    return mapUnitStatus;
  }

  public static void UpdateUnitStatus(list<Id> lstUnitId){
    map<string, list<Unit_Status__mdt>> mapSettingUnitStatus = GetUnitStatusSettings();
    if (!mapSettingUnitStatus.isEmpty()){
      map<Id,StatusInfo> mapUnitStatus = CalcUnitStatus(lstUnitId);
      if (!mapUnitStatus.isEmpty()){
        list<Unit__c> lstUnit = new list<Unit__c>(); 
        for (Unit__c oUnit : [SELECT Id, Name, Status__c, Current_Resident_Occupancy_1__c, Next_Resident_Occupancy_1__c, Current_Resident_Occupancy_2__c, Next_Resident_Occupancy_2__c FROM Unit__c WHERE Id IN :lstUnitId]){
          if (mapUnitStatus.containsKey(oUnit.Id)){
            if (mapSettingUnitStatus.containsKey(mapUnitStatus.get(oUnit.Id).strStatus)){
              for (Unit_Status__mdt oset : mapSettingUnitStatus.get(mapUnitStatus.get(oUnit.Id).strStatus)){
                boolean skip = false;
                if (string.isNotBlank(oset.Valid_Previous_Statuses__c)){
                  skip = true;
                  for (string strskipStatus : oset.Valid_Previous_Statuses__c.split(',')){
                    if (strskipStatus.trim().equalsIgnoreCase(oUnit.Status__c)){
                      skip = false;break;
                    }
                  }
                }
                if (!skip){
                  oUnit.Status__c = oset.MasterLabel;
                  oUnit.Current_Resident_Occupancy_1__c = mapUnitStatus.get(oUnit.Id).CurrentOccLog1;
                  oUnit.Current_Resident_Occupancy_2__c = mapUnitStatus.get(oUnit.Id).CurrentOccLog2;
                  oUnit.Next_Resident_Occupancy_1__c = mapUnitStatus.get(oUnit.Id).NextOccLog1;
                  oUnit.Next_Resident_Occupancy_2__c = mapUnitStatus.get(oUnit.Id).NextOccLog2;
                  lstUnit.add(oUnit);
                  break;
                }
              }
            }
          }
        }
        if (!lstUnit.isEmpty())
          update lstUnit;
      }
    }
  }

    public static string GetOppStage(string strScenario, Id oppRecordTypeId, string strLevelOfCare){
        string strStage = strScenario;
        string strRecType = '';
        if (string.isNotBlank(oppRecordTypeId)){
            Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
            if (rtMapById!=null) if (!rtMapById.isEmpty()) if (rtMapById.containsKey(oppRecordTypeId))
                strRecType = rtMapById.get(oppRecordTypeId).getName();
        }
        boolean mtdMatch = false;
        integer matchScore = 0;
        List<Occupancy_Opp_Stage__mdt> mcs = Occupancy_Opp_Stage__mdt.getAll().values();
        if (mcs!=null) if (!mcs.isEmpty()) for (Occupancy_Opp_Stage__mdt mtd : mcs) if (mtd.Scenario__c.equalsIgnoreCase(strScenario)){
            boolean match = true;
            integer score = 1;
            if (string.isNotBlank(mtd.Opp_Record_Type_Name__c)){
                if (mtd.Opp_Record_Type_Name__c.equalsIgnoreCase(strRecType)) score += 2;
                else match = false;
            }
            if (match) if (string.isNotBlank(mtd.Opp_Level_of_Care__c)){
                if (mtd.Opp_Level_of_Care__c.equalsIgnoreCase(strLevelOfCare)) score += 1;
                else match = false;
            }
            if (match) if (score>matchScore){
                mtdMatch=true;
                matchScore=score;
                strStage=mtd.Opp_Stage__c;
            }
        }
        return strStage;
    }

  public static boolean skipOccLogTrigger = false;
  public static void OccLogTrigger(boolean UseFuture){
    if (skipOccLogTrigger) return;
    if (trigger.isAfter){
      set<Id> setApartmentId = new set<Id>();
      if ((trigger.isInsert)||(trigger.isUpdate)){
        for (Occupancy_Log__c objOcc : (list<Occupancy_Log__c>)trigger.New)
          if (string.isNotBlank(objOcc.Apartment__c))
            setApartmentId.add(objOcc.Apartment__c);
      }
      else if ((trigger.isDelete))
        for (Occupancy_Log__c objOcc : (list<Occupancy_Log__c>)trigger.old) if (string.isNotBlank(objOcc.Apartment__c))
            setApartmentId.add(objOcc.Apartment__c);
      if (!setApartmentId.isEmpty())
        if (!(DisableTrigger.isDisabled('trigOccupancyUpdateUnitStatus')))
          CallUpdateUnitStatus(new list<Id>(setApartmentId), UseFuture);
    }
  }

  private static void CallUpdateUnitStatus(list<Id> lstUnitId, boolean UseFuture){
    if ((Test.isRunningTest())||(system.isFuture())||(system.isBatch())||(!(UseFuture)))
      UpdateUnitStatus(lstUnitId);
    else
      FutureUpdateUnitStatus(lstUnitId);
  }

  @future
  public static void FutureUpdateUnitStatus(list<Id> lstUnitId){UpdateUnitStatus(lstUnitId);}
  
  private static map<string, list<Unit_Status__mdt>> GetUnitStatusSettings(){
    map<string, list<Unit_Status__mdt>> mapKeyUnitStatus = new map<string, list<Unit_Status__mdt>>();
    for (Unit_Status__mdt oRollUp : [SELECT DeveloperName, MasterLabel, Scenario__c, Valid_Previous_Statuses__c FROM Unit_Status__mdt WHERE Scenario__c != 'Ignore']){
      if (mapKeyUnitStatus.containsKey(string.valueOf(oRollUp.Scenario__c)))
        mapKeyUnitStatus.get(string.valueOf(oRollUp.Scenario__c)).add(oRollUp);
      else
        mapKeyUnitStatus.put(string.valueOf(oRollUp.Scenario__c),new list<Unit_Status__mdt> {oRollUp});
    }
    return mapKeyUnitStatus;
  }

  private class StatusInfo {
    public StatusInfo(string strStatusValue){
      this.strStatus = strStatusValue;
      this.CurrentOccLog1 = null;
      this.CurrentOccLog2 = null;
      this.NextOccLog1 = null;
      this.NextOccLog2 = null;
    }
    public string strStatus;
    public Id CurrentOccLog1;
    public Id CurrentOccLog2;
    public Id NextOccLog1;
    public Id NextOccLog2;
    public void SetOccLogValues(StatusInfo tmp){
      if (tmp!=null){
        this.CurrentOccLog1=tmp.CurrentOccLog1;
        this.CurrentOccLog2=tmp.CurrentOccLog2;
        this.NextOccLog1=tmp.NextOccLog1;
        this.NextOccLog2=tmp.NextOccLog2;
      }
    }
  }
}