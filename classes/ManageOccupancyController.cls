public class ManageOccupancyController {
    
    @auraEnabled
  public static list<OccInfo> GetOccupancies(Id OppId){
    list<OccInfo> lstOccupancy = new list<OccInfo>();
    if (string.isNotBlank(OppId)){
      date dtNextMonth = date.today().addMonths(1);
      Map<String,Schema.RecordTypeInfo> rtMapByName = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName();
      for (Occupancy__c occ : [SELECT Id, Name, Apartment__c, Apartment__r.Name, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Resident__r.Name, Resident__r.AccountId, Community__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c!=null ORDER BY Id]){
        OccInfo objOccInfo = new OccInfo(occ); 
        lstOccupancy.add(objOccInfo);
      }
    }
    return lstOccupancy;
  }
    
    @auraEnabled
  public static list<PendingChange> GetPendingChanges(Id OppId){
    list<PendingChange> lstPC = new list<PendingChange>();
    for (Occupancy__c occ: [SELECT Id, Resident__r.Name, Apartment__c, Apartment__r.Name, Move_In_Date__c, Move_Out_Date__c, Scheduled_Move_In_Date__c, Scheduled_Move_Out_Date__c, Last_Change_Date__c, Transfer_Apartment__c, Transfer_Apartment__r.Name FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Resident__c != null ORDER BY Id]){
      if (occ.Move_In_Date__c==null){
        if (occ.Scheduled_Move_In_Date__c!=null){
          PendingChange pc = new PendingChange();
          pc.strType = 'Move In';
          pc.dtDate = occ.Scheduled_Move_In_Date__c;
          pc.strDate = pc.dtDate.format();
          pc.strResident = occ.Resident__r.Name;
          if (string.isNotBlank(occ.Apartment__c))
            pc.strApartment = occ.Apartment__r.Name;
          lstPC.add(pc);
        }
      }
      else if (occ.Move_Out_Date__c==null){
        if (occ.Scheduled_Move_Out_Date__c!=null){
          PendingChange pc = new PendingChange();
          pc.strType = 'Move Out';
          pc.dtDate = occ.Scheduled_Move_Out_Date__c;
          pc.strDate = pc.dtDate.format();
          pc.strResident = occ.Resident__r.Name;
          if (string.isNotBlank(occ.Apartment__c))
            pc.strApartment = occ.Apartment__r.Name;
          lstPC.add(pc);
        }
        else if (((occ.Last_Change_Date__c!=null)&&(string.isNotBlank(occ.Transfer_Apartment__c)))){
          PendingChange pc = new PendingChange();
          pc.strType = 'Transfer';
          pc.dtDate = occ.Last_Change_Date__c;
          pc.strDate = pc.dtDate.format();
          pc.strResident = occ.Resident__r.Name;
          if (string.isNotBlank(occ.Transfer_Apartment__c))
            pc.strApartment = occ.Transfer_Apartment__r.Name;
          lstPC.add(pc);
        }
      }
    }
    if (!lstPC.isEmpty())
      lstPC.sort();
    return lstPC;    
  }
    
    private static boolean ShowMoveInForStage(string strStage){
    boolean retVal = true;
    if (string.isNotBlank(strStage)){
      list<string> lstStage = (list<string>)JSON.deserialize(System.Label.OppStagesMoveInNotAllowed, list<string>.class);//new list<string> {'Approach','Interview','Demonstrate','Validate','Negotiate','Closed-Lost Lead'};
      for (string STG : lstStage)
        if (STG.equalsIgnoreCase(strStage)){
          retVal=false;break;
        }
    }
    return retVal;
  }

    @auraEnabled
  public static list<string> GetButtonNames(Id OppId){
    set<string> lstReturn = new set<string>();
    if (string.isNotBlank(OppId)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c, StageName, AccountId FROM Opportunity WHERE Id = :OppId]){ //Promissory_Note_Outstanding__c
        if (string.isNotBlank(opp.Community__c))  if (string.isNotBlank(opp.Primary_Resident__c)) { //if (string.isNotBlank(opp.Unit__c)) if (string.isNotBlank(opp.Care_Level__c))
          //boolean btnMoveIn = false;
          //boolean btnMoveInWPND = false; //Move In with Promissory Note
          boolean btnScheduleMoveIn = false;
          boolean btnScheduleMoveOut = false;
          boolean btnMoveOut = false;
          boolean btnScheduleTransfer = false;
          boolean btnTransfer = false;
          boolean btnPayPromissoryNotinFull = false;
             boolean PrimaryResidentMovedIn = false;
          boolean SecondResidentMovedIn = false;
          boolean PrimaryResidentScheduledMovedIn = false;
          boolean SecondResidentScheduledMovedIn = false;
          boolean PrimaryResidentMovedOut = false;
          boolean SecondResidentMovedOut = false;
          OccupancyTabSetting occTabSetting = new OccupancyTabSetting();
          for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Name, Scheduled_Move_In_Date__c, Scheduled_Move_Out_Date__c, Last_Change_Date__c, Transfer_Apartment__c  FROM Occupancy__c WHERE Source_Opportunity__c = :OppId]){
            if (opp.Primary_Resident__c==occ.Resident__c){
              if (occ.Move_In_Date__c!=null){
                PrimaryResidentMovedIn = true;
                if (occ.Move_Out_Date__c!=null)
                  PrimaryResidentMovedOut=true;
              }
              else if (occ.Scheduled_Move_In_Date__c!=null)
                PrimaryResidentScheduledMovedIn=true;
            }
            else if (opp.Second_Resident__c==occ.Resident__c){
              if (occ.Move_In_Date__c!=null){
                SecondResidentMovedIn = true;
                if (occ.Move_Out_Date__c!=null)
                  SecondResidentMovedOut=true;
              }
              else if (occ.Scheduled_Move_In_Date__c!=null)
                SecondResidentScheduledMovedIn=true;
            }
            if (string.isNotBlank(occ.Resident__c))
            if (occ.Move_In_Date__c!=null)
              if (occ.Move_Out_Date__c==null){
                if (occ.Scheduled_Move_Out_Date__c!=null){
                  lstReturn.add('Cancel Scheduled Move Out');
                }
                else if (((occ.Last_Change_Date__c!=null)&&(occ.Transfer_Apartment__c!=null))){
                  lstReturn.add('Cancel Scheduled Transfer');
                }
              }
          }
//          if (opp.Promissory_Note_Outstanding__c)
//            btnPayPromissoryNotinFull = true;
          if ((PrimaryResidentMovedIn==false)||((SecondResidentMovedIn==false)&&(opp.Second_Resident__c!=null))){
            //if (!(PrimaryResidentScheduledMovedIn||SecondResidentScheduledMovedIn))
            //  lstReturn.add('Schedule Move-In'); 
            if (ShowMoveInForStage(opp.Stagename)){
              lstReturn.add('Move-In');
            //  lstReturn.add('Move-In with Promissory Note');
            }
          }
          if (PrimaryResidentScheduledMovedIn && SecondResidentScheduledMovedIn)
            if (occTabSetting.Enable_Remove_Prospect)
              lstReturn.add('Remove Prospect');
          if (!PrimaryResidentMovedOut)
            if (!SecondResidentMovedOut)
              if (PrimaryResidentMovedIn || PrimaryResidentScheduledMovedIn)
                if (!SecondResidentMovedIn)
                  if (!SecondResidentScheduledMovedIn)
                    if (string.isNotBlank(opp.AccountId))
                      if (string.isNotBlank(opp.Primary_Resident__c))
                        for (Contact cont : [SELECT Id FROM Contact WHERE Prospect__c = true AND AccountId = :opp.AccountId AND Id != :opp.Primary_Resident__c LIMIT 1])
                          if (occTabSetting.Enable_Add_Missing_Resident)
                            lstReturn.add('Add Missing Resident');
          if (PrimaryResidentMovedIn || SecondResidentMovedIn){
            if (!((PrimaryResidentMovedOut || (!PrimaryResidentMovedIn)) && (SecondResidentMovedOut || (!SecondResidentMovedIn)))){
              //if (btnPayPromissoryNotinFull)
              //  lstReturn.add('Pay Promissory Note in Full');
              lstReturn.add('Schedule Move-Out');
              lstReturn.add('Move-Out');
              lstReturn.add('Schedule Transfer');
              lstReturn.add('Transfer');
            }
            if (PrimaryResidentMovedOut || SecondResidentMovedOut)
              if (occTabSetting.Enable_Reverse_Move_Out)
                lstReturn.add('Reverse Move-Out');
          }
          //else if (('Depositor').equalsIgnoreCase(opp.StageName)){
          //  lstReturn.add('Cancel Deposit');
          //  if (occTabSetting.Enable_Reset_Deposit)
          //    lstReturn.add('Reset/Correct Deposit');
          //}
          else if (!(('Cancelled').equalsIgnoreCase(opp.StageName)||('Closed-Lost Lead').equalsIgnoreCase(opp.StageName))){
            //lstReturn.add('Cancel Opportunity');
          }
        }
        else if (!(('Cancelled').equalsIgnoreCase(opp.StageName)||('Closed-Lost Lead').equalsIgnoreCase(opp.StageName))){
          //lstReturn.add('Cancel Opportunity');
        }
      }
    }
    return new list<string>(lstReturn);
  }

    @auraEnabled
  public static MoveInFormParams GetMoveInFormParams(Id OppId, string MoveInType){
    MoveInFormParams obj = new MoveInFormParams();
    obj.strMoveInType=MoveInType;
    if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Amount, Community__c, Unit__c, Unit__r.Name, Unit__r.Status__c, Unit__r.Housing_Type__c, Primary_Resident__c, Primary_Resident__r.Name, Second_Resident__c, Second_Resident__r.Name, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){ //Forecasted_Entrance_Fee__c
        if (string.isNotBlank(opp.Community__c))
          obj.strCommunity=opp.Community__c;
        if (string.isNotBlank(opp.Housing_Type__c))
          obj.strLevelOfCare=opp.Housing_Type__c;
        //if (string.isNotBlank(opp.Arbitration_Agreement__c))
        //  obj.strArbitrationAgreement=opp.Arbitration_Agreement__c;
        //else
        //obj.strArbitrationAgreement='';
        if (string.isNotBlank(opp.Unit__c)){
          obj.idApartment=opp.Unit__c;
          obj.strApartment=GetApptDesc(opp.Unit__r.Name,opp.Unit__r.Status__c);
          if (string.isBlank(obj.strLevelOfCare))
            obj.strLevelOfCare = string.valueOf(opp.Unit__r.Housing_Type__c);
        }
        if (string.isNotBlank(opp.Primary_Resident__c)){
          obj.idPrimaryResident=opp.Primary_Resident__c;
          obj.strPrimaryResident=opp.Primary_Resident__r.Name;
        }
        if (string.isNotBlank(opp.Second_Resident__c)){
          obj.idSecondResident=opp.Second_Resident__c;
          obj.strSecondResident=opp.Second_Resident__r.Name;
        }
        Schema.DescribeFieldResult FA = Unit__c.Housing_Type__c.getDescribe();
        Schema.sObjectField TA = FA.getSObjectField();
        List<PicklistEntry> entriesLoC = TA.getDescribe().getPicklistValues();
        obj.lstLevelOfCare = new list<PickListOption>();
        for (PicklistEntry pe : entriesLoC){
          string strTemp = pe.getValue();
          PickListOption OptionA = new PickListOption();
          OptionA.label=strTemp;
          OptionA.value=strTemp;
          obj.lstLevelOfCare.add(OptionA);
        }
                if (string.isBlank(obj.strLevelOfCare))
                    if (!obj.lstLevelOfCare.isEmpty())
                      obj.strLevelOfCare = obj.lstLevelOfCare.get(0).value;
        //Schema.DescribeFieldResult FAg = Opportunity.Arbitration_Agreement__c.getDescribe();
        //Schema.sObjectField TAg = FAg.getSObjectField();
        //List<PicklistEntry> entriesAA = TAg.getDescribe().getPicklistValues();
        //obj.lstArbitrationAgreement = new list<PickListOption>();
        //PickListOption OptionAb = new PickListOption();
        //OptionAb.label='';
        //OptionAb.value='';
        //obj.lstArbitrationAgreement.add(OptionAb);
        //for (PicklistEntry pe : entriesAA){
        //  string strTemp = pe.getValue();
        //  PickListOption OptionA = new PickListOption();
        //  OptionA.label=strTemp;
        //  OptionA.value=strTemp;
        //  obj.lstArbitrationAgreement.add(OptionA);
        //}
        obj.lstApartment = GetApartments(obj.strCommunity,obj.strLevelOfCare,obj.idApartment,OppId,true);
        obj.isAmountRequired=false;
//        for (Transaction__c tr : [SELECT Id,Type__c FROM Transaction__c WHERE Opportunity__c = :OppId AND Type__c In ('Community Fee','10% Deposit') ]){
//          if (('Community Fee').equalsIgnoreCase(tr.Type__c)){
//            obj.isAmountRequired=false;
//            break;
//          }
//          else if (('10% Deposit').equalsIgnoreCase(tr.Type__c)){
//            obj.isAmountRequired=true;
//            break;
//          }
//        }
        //obj.dblRebatableAmount=calcRefundAmt(opp.Contract_Type__c,opp.Amount);
        obj.strDefaultAmount ='';
//        if (string.isNotBlank(MoveInType))
//          if (!(MoveInType.startswithIgnoreCase('Promissory')))
//            if (opp.Forecasted_Entrance_Fee__c!=null)
//              obj.strDefaultAmount = string.valueOf(opp.Forecasted_Entrance_Fee__c);
      }
    return obj;
  }
    
    @auraEnabled
  public static list<PickListOption> GetApartments(string strCommunity, string strLevelOfCare, Id idApartment, Id OppId, boolean filterOccupied){
    list<PickListOption> lstApartment = new list<PickListOption>();
    PickListOption OptionB = new PickListOption();
    OptionB.label='';
    OptionB.value='';
    lstApartment.add(OptionB);
    list<Id> lstUnitId = new list<Id>();
    if (string.isNotBlank(idApartment))
      lstUnitId.add(idApartment);
    if (string.isNotBlank(strCommunity)){
      if (filterOccupied) if (string.isNotBlank(OppId))
        for (Opportunity opp : [SELECT AccountId, Id FROM Opportunity WHERE Id = :OppId AND AccountId != null LIMIT 1])
          for (Occupancy__c occ : [SELECT Id, Resident__c, Apartment__c FROM Occupancy__c WHERE (Source_Opportunity__c = :OppId OR Resident__r.AccountId = :opp.AccountId)  AND Move_In_Date__c != null AND Move_In_Date__c <= today AND (Move_Out_Date__c = null OR Move_Out_Date__c > today) AND Apartment__c != null])
            lstUnitId.add(occ.Apartment__c);
      List<String> strCommList = New List<String>();      
      strCommList.add(strCommunity);
      for (Community_Affinity__c ac: [select Id, Affinity_Community__c from Community_Affinity__c  where Community__r.Name = : strCommunity])  
         if (ac.Affinity_Community__c != null)
            strCommList.add(ac.Affinity_Community__c); 
            
      string CommListForQuery = ' ( ';
      for (String s :  strCommList)
         CommListForQuery = CommListForQuery  + '\'' + s + '\',';
      CommListForQuery = CommListForQuery.left(CommListForQuery.length()-1);    
      CommListForQuery = CommListForQuery + ') ';   
      System.Debug('MANAGE OCC CONTROLLER:CommListForQuery -  ' + CommListForQuery );
      string strQuery = 'SELECT Id, Name, Status__c FROM Unit__c WHERE ('+(filterOccupied?'( Status__c LIKE \'Vacant%\' OR Status__c LIKE \'Reserved\') AND ':'')+' Community__c in ' + CommListForQuery  + (string.isNotBlank(strLevelOfCare)?' AND Housing_Type__c = \'' + strLevelOfCare + '\'':'')+') ' + 
        (!(lstUnitId.isEmpty())?' OR Id IN :lstUnitId ':'')+ ' ORDER BY Name';
      System.Debug('MANAGE OCC CONTROLLER:strQuery  -  ' + strQuery  );
      for (Unit__c ut : (list<Unit__c>)database.query(strQuery)){
        PickListOption OptionA = new PickListOption();
        OptionA.label=GetApptDesc(ut.Name,ut.Status__c);
        OptionA.value=Id.valueOf(ut.Id);
        lstApartment.add(OptionA);
      }
    }
    return lstApartment;
  }
    
    private static string GetApptDesc(string strName, string strStatus){
    string str='';
    if (string.isNotBlank(strName))
      str=string.valueOf(strName).trim();
    if (string.isNotBlank(strStatus))
      str = str + ' (' + string.valueOf(strStatus).trim() + ')';
    return str;
  }
    
    @auraEnabled
  public static string MoveIn(Id OppId, string MoveInType, string strMoveInDate, Id idApartment, string dblAmount, string strPromissoryNoteDue, string strRefund, string strArbitrationAgreement){
    decimal dblAmount1=null;
    if (string.isNotBlank(dblAmount))
      dblAmount1=decimal.valueOf(dblAmount);
    string strReturn = '';
    date dtMoveInDate=null;
    date dtPromissoryNoteDue=null;
    if (string.isNotBlank(strMoveInDate))
      dtMoveInDate = date.valueOf(strMoveInDate);
    if (string.isNotBlank(strPromissoryNoteDue))
      dtPromissoryNoteDue = date.valueOf(strPromissoryNoteDue);
    try{
      if (string.isNotBlank(OppId))
        for (Opportunity opp : [SELECT Id, Community__c, Primary_Resident__c, Second_Resident__c, Move_In_Date__c, Unit__c, Expected_Move_In_Date__c, Room_Vacant_Before_Move_In__c, StageName, AccountId, Housing_Type__c, RecordTypeId FROM Opportunity WHERE Id = :OppId]){ //Rebatable_Refund_Amount__c
          boolean updateOpp = false;
          if (string.isNotBlank(idApartment))
            if (idApartment!=opp.Unit__c){
              opp.Unit__c=idApartment;
              updateOpp=true;
            }
          //if (string.isNotBlank(strArbitrationAgreement))
          //  opp.Arbitration_Agreement__c=strArbitrationAgreement;
          //else
          //  opp.Arbitration_Agreement__c=null;
          if (opp.Move_In_Date__c==null) if (dtMoveInDate!=null){
            opp.Move_In_Date__c=dtMoveInDate;
            opp.Expected_Move_In_Date__c=null;
            opp.StageName=OccTrigHelper.GetOppStage('Move In', opp.RecordTypeId, opp.Housing_Type__c);
            if (string.isNotBlank(opp.Unit__c))
              for (Unit__c objUnit : [SELECT Id, Status__c FROM Unit__c WHERE Id = :opp.Unit__c AND Status__c != Null])
                if ((string.valueOf(objUnit.Status__c).startsWithIgnoreCase('Vacant'))||(string.valueOf(objUnit.Status__c).startsWithIgnoreCase('Reserved')))
                  opp.Room_Vacant_Before_Move_In__c=true;
            updateOpp=true;
          }
//          if (string.isNotBlank(strRefund)){
//            if (string.isNotBlank(idApartment))
//              for (Unit__c oUnit : [SELECT Id, Housing_Type__c, Level_of_Care_formula__c FROM Unit__c WHERE Id = :idApartment AND Housing_Type__c != null])
//              if (('Independent Living').equalsIgnoreCase(oUnit.Level_of_Care_formula__c)){
//                opp.Rebatable_Refund_Amount__c=decimal.valueOf(strRefund);
//                updateOpp=true;
//              }
//          }
          if (updateOpp){
            list<Id> lstResId = new list<Id>();
            if (string.isNotBlank(opp.Primary_Resident__c))
              lstResId.add(opp.Primary_Resident__c);
            if (string.isNotBlank(opp.Second_Resident__c))
              lstResId.add(opp.Second_Resident__c);
            string strVVErr = ValidateUnitVacancy(opp.Unit__c, OppId,lstResId, opp.Move_In_Date__c, opp.AccountId);
            if (string.isNotBlank(strVVErr))
              return strVVErr;
            else
              update opp;
          }
          if (dblAmount1!=null) if (dblAmount1>0){
            Transaction__c tran = new Transaction__c(Amount__c=dblAmount1,  
                                //Estimated_Move_In_Date__c=dtMoveInDate,
                                //Move_In_Date__c=dtMoveInDate,
                                Opportunity__c=OppId,
                                Type__c='Remaining Amount',
                                Transaction_Date__c=date.today());
            //if (string.isNotBlank(MoveInType))
            //  if (MoveInType.startsWithIgnoreCase('Promissory')){
            //    //if (dtPromissoryNoteDue!=null)
            //    //  tran.Promissory_Note_Due_Date__c=dtPromissoryNoteDue;
            //    //tran.Promissory_Note_Outstanding__c=true;
            //    tran.Type__c='Promissory Note Deposit';
            //  }
            insert tran;
          }
        }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    private static string ValidateUnitVacancy(Id UnitId, Id OppId, list<Id> lstResId, date dtMoveIn, Id AccId){
    string strRetVal = '';
    if (string.isNotBlank(UnitId))
      if (string.isNotBlank(OppId))
        if (lstResId!=null)
          if (!lstResId.isEmpty())
            if (dtMoveIn!=null)
              for (Occupancy__c occ : [SELECT Id, Resident__r.Name, Apartment__r.Name FROM Occupancy__c WHERE Apartment__c = :UnitId AND (Source_Opportunity__c = null OR Source_Opportunity__c != :OppId) AND (Resident__c != null AND Resident__c NOT IN :lstResId AND Resident__r.AccountId != :AccId) AND Move_In_Date__c != null AND Move_In_Date__c <= :dtMoveIn AND (Move_Out_Date__c = null OR Move_Out_Date__c > :dtMoveIn) LIMIT 1])
                strRetVal = 'Apartment ' + occ.Apartment__r.Name + ' is already occupied by ' + occ.Resident__r.Name;
    return strRetVal;
  }
    
    @auraEnabled
  public static MoveOutFormParams GetMoveOutFormParams(Id OppId){
    MoveOutFormParams obj = new MoveOutFormParams();
    if (string.isNotBlank(OppId)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){
        for (Occupancy__c occ : [SELECT Id, Move_Out_Reason__c, Scheduled_Move_Out_Date__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Resident__r.Name, Name  FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){
          if (Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c)){
            obj.idPrimaryResident=occ.Resident__c;
            obj.strPrimaryResident=occ.Resident__r.Name;
          }
          else if (Id.valueOf(occ.Resident__c).equals(opp.Second_Resident__c)){
            obj.idSecondResident=occ.Resident__c;
            obj.strSecondResident=occ.Resident__r.Name;
          }
          if (occ.Scheduled_Move_Out_Date__c!=null)
            if ((string.isBlank(obj.strDefaultMoveOutDate))||(Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c))){
              obj.strDefaultMoveOutDate=datetime.newInstance(occ.Scheduled_Move_Out_Date__c.Year(),occ.Scheduled_Move_Out_Date__c.Month(),occ.Scheduled_Move_Out_Date__c.Day()).format('yyyy-MM-dd');
              if (string.isNotBlank(occ.Move_Out_Reason__c))
                obj.strDefaultMoveOutReason=occ.Move_Out_Reason__c;
            }
        }
        Schema.DescribeFieldResult FA = Occupancy__c.Move_Out_Reason__c.getDescribe();
        Schema.sObjectField TA = FA.getSObjectField();
        List<PicklistEntry> entriesLoC = TA.getDescribe().getPicklistValues();
        obj.lstMoveOutReason = new list<PickListOption>();
        PickListOption OptionB = new PickListOption();
        OptionB.label='';
        OptionB.value='';
        obj.lstMoveOutReason.add(OptionB);
        for (PicklistEntry pe : entriesLoC){
          string strTemp = pe.getValue();
          PickListOption OptionA = new PickListOption();
          OptionA.label=strTemp;
          OptionA.value=strTemp;
          obj.lstMoveOutReason.add(OptionA);
        }
      }
    }
    return obj;
  }
    
    @auraEnabled
  public static CancelScheduledMoveOutFormParams GetCancelScheduledMoveOutFormParams(Id OppId){
    CancelScheduledMoveOutFormParams obj = new CancelScheduledMoveOutFormParams();
    if (string.isNotBlank(OppId)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Scheduled_Move_Out_Date__c, Move_Out_Date__c, Resident__c, Resident__r.Name, Name  FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null AND Scheduled_Move_Out_Date__c != null]){
          if (Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c)){
            obj.idPrimaryResident=occ.Resident__c;
            obj.strPrimaryResident=occ.Resident__r.Name;
          }
          else if (Id.valueOf(occ.Resident__c).equals(opp.Second_Resident__c)){
            obj.idSecondResident=occ.Resident__c;
            obj.strSecondResident=occ.Resident__r.Name;
          }
        }
      }
    }
    return obj;
  }
    
    @auraEnabled
  public static CancelScheduledMoveOutFormParams GetCancelScheduledTransferFormParams(Id OppId){
    CancelScheduledMoveOutFormParams obj = new CancelScheduledMoveOutFormParams();
    if (string.isNotBlank(OppId)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Resident__r.Name, Name, Last_Change_Date__c, Transfer_Apartment__c  FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null AND ((Last_Change_Date__c!=null) AND (Transfer_Apartment__c!=null))]){
          if (Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c)){
            obj.idPrimaryResident=occ.Resident__c;
            obj.strPrimaryResident=occ.Resident__r.Name;
          }
          else if (Id.valueOf(occ.Resident__c).equals(opp.Second_Resident__c)){
            obj.idSecondResident=occ.Resident__c;
            obj.strSecondResident=occ.Resident__r.Name;
          }
        }
      }
    }
    return obj;
  }
    
    @auraEnabled
  public static string MoveOut(Id OppId, string MoveOutType, string strMoveOutDate, string strMoveOutReason, Id idPrimaryResident, Id idSecondResident, string strRefund){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId)) if (string.isNotBlank(strMoveOutDate)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c  FROM Opportunity WHERE Id = :OppId]){
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        boolean RefundSet = false;
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Scheduled_Move_Out_Date__c, Move_Out_Reason__c, Transfer_Apartment__c, Transfer_Level_of_Care__c, Last_Change_Date__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){ //Rebatable_Refund_Amount__c
          boolean flag=false;
          if (string.isNotBlank(idPrimaryResident))
            if (idPrimaryResident.equals(occ.Resident__c))
              flag=true;
          if (!flag)
            if (string.isNotBlank(idSecondResident))
              if (idSecondResident.equals(occ.Resident__c))
                flag=true;
          if (flag){
            if (('Move-Out').equalsIgnoreCase(MoveOutType))
              occ.Move_Out_Date__c=date.valueOf(strMoveOutDate);
            else if (('Schedule Move-Out').equalsIgnoreCase(MoveOutType)){
              occ.Scheduled_Move_Out_Date__c=date.valueOf(strMoveOutDate);
              occ.Transfer_Apartment__c=null;
              occ.Transfer_Level_of_Care__c=null;
              occ.Last_Change_Date__c=null;
            }
            occ.Move_Out_Reason__c=strMoveOutReason;
//            if (!RefundSet)
//              if (string.isNotBlank(strRefund)){
//                occ.Rebatable_Refund_Amount__c=decimal.valueOf(strRefund);
//                RefundSet=true;
//              }
            lstOcc.add(occ);
          }
        }
        if (!lstOcc.isEmpty())
          update lstOcc;
      }
//      if (string.isNotBlank(strRefund))
//        UpdateOppRefund(OppId,decimal.valueOf(strRefund));
      }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static string CancelScheduledMoveOut(Id OppId, Id idPrimaryResident, Id idSecondResident){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c  FROM Opportunity WHERE Id = :OppId]){
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Scheduled_Move_Out_Date__c, Move_Out_Reason__c, Transfer_Apartment__c, Transfer_Level_of_Care__c, Last_Change_Date__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){
          boolean flag=false;
          if (string.isNotBlank(idPrimaryResident))
            flag = (idPrimaryResident.equals(occ.Resident__c));
          if (!flag)
            if (string.isNotBlank(idSecondResident))
              if (idSecondResident.equals(occ.Resident__c))
                flag=true;
          if (flag){
            occ.Scheduled_Move_Out_Date__c=null;
            occ.Transfer_Apartment__c=null;
            occ.Transfer_Level_of_Care__c=null;
            occ.Last_Change_Date__c=null;
            occ.Move_Out_Reason__c=null;
            lstOcc.add(occ);
          }
        }
        if (!lstOcc.isEmpty())
          update lstOcc;
      }
    }
    catch(Exception exc){ strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static string Transfer(Id OppId, string TransferType, string strTransferDate, string strLevelOfCare, Id idApartment, Id idPrimaryResident, Id idSecondResident, string strRefund, string strAddEntranceFee){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId)) if (string.isNotBlank(strTransferDate)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c, AccountId FROM Opportunity WHERE Id = :OppId]){ //Additional_Entrance_Fee__c
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        boolean RefundSet = false;
        list<Id> lstResId = new list<Id>();
        if (string.isNotBlank(opp.Primary_Resident__c))
          lstResId.add(opp.Primary_Resident__c);
        if (string.isNotBlank(opp.Second_Resident__c))
          lstResId.add(opp.Second_Resident__c);
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Transfer_Apartment__c, Transfer_Level_of_Care__c, Last_Change_Date__c, Apartment__c, Level_of_Care__c, Scheduled_Move_Out_Date__c, Scheduled_Move_In_Date__c FROM Occupancy__c  WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){ //Rebatable_Refund_Amount__c
          boolean flag=false; 
          if (string.isNotBlank(idPrimaryResident))
            if (idPrimaryResident.equals(occ.Resident__c))
              flag=true;
          if (!flag)
            if (string.isNotBlank(idSecondResident))
              flag = (idSecondResident.equals(occ.Resident__c));
          if (flag){
            if (('Transfer').equalsIgnoreCase(TransferType)){
              string strVVErr = ValidateUnitVacancy(idApartment, OppId,lstResId, date.valueOf(strTransferDate), opp.AccountId);
              if (string.isNotBlank(strVVErr))
                return strVVErr;
              occ.Move_In_Date__c=date.valueOf(strTransferDate);
              occ.Apartment__c = idApartment;
              occ.Level_of_Care__c=strLevelOfCare;
              occ.Move_Out_Date__c=null;
              occ.Transfer_Apartment__c=null;
              occ.Transfer_Level_of_Care__c=null;
              occ.Last_Change_Date__c=null;
              occ.Scheduled_Move_Out_Date__c=null;
              occ.Scheduled_Move_In_Date__c=null;
            }
            else if (('Schedule Transfer').equalsIgnoreCase(TransferType)){
              occ.Transfer_Apartment__c=idApartment;
              occ.Transfer_Level_of_Care__c=strLevelOfCare;
              occ.Last_Change_Date__c=date.valueOf(strTransferDate);
            }
//            if (!RefundSet)
//              if (string.isNotBlank(strRefund)){
//                occ.Rebatable_Refund_Amount__c=decimal.valueOf(strRefund);
//                RefundSet=true;
//              }
            lstOcc.add(occ);
          }
        }
        if (!lstOcc.isEmpty())
          update lstOcc;
      }
      }
//      if (string.isNotBlank(strAddEntranceFee))
//        UpdateOppAdditionalEntranceFee(OppId,decimal.valueOf(strAddEntranceFee),TransferType, date.valueOf(strTransferDate));
      //if (string.isNotBlank(strRefund))
      //  UpdateOppRefund(OppId,decimal.valueOf(strRefund));
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static string CancelScheduledTransfer(Id OppId, Id idPrimaryResident, Id idSecondResident){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){ //Additional_Entrance_Fee__c
        list<Occupancy__c> lstOcc = new list<Occupancy__c>();
        boolean RefundSet = false;
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Transfer_Apartment__c, Transfer_Level_of_Care__c, Apartment__c, Level_of_Care__c, Scheduled_Move_Out_Date__c, Scheduled_Move_In_Date__c, Last_Change_Date__c FROM Occupancy__c  WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){ //Rebatable_Refund_Amount__c
          boolean flag=false;
          if (string.isNotBlank(idPrimaryResident))
            if (idPrimaryResident.equals(occ.Resident__c))
              flag=true;
          if (!flag)
            if (string.isNotBlank(idSecondResident))
              flag = (idSecondResident.equals(occ.Resident__c));
          if (flag){
            occ.Transfer_Apartment__c=null;
            occ.Transfer_Level_of_Care__c=null;
            occ.Last_Change_Date__c=null;
            lstOcc.add(occ);
          }
        }
        if (!lstOcc.isEmpty())
          update lstOcc;
      }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static TransferFormParams GetTransferFormParams(Id OppId){
    TransferFormParams obj = new TransferFormParams();
    if (string.isNotBlank(OppId)){
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c FROM Opportunity WHERE Id = :OppId]){
        obj.strCommunity=opp.Community__c;
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Move_Out_Date__c, Resident__c, Resident__r.Name, Name, Transfer_Apartment__c, Transfer_Level_of_Care__c, Last_Change_Date__c  FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_In_Date__c != null AND Move_Out_Date__c = null AND Resident__c != null]){
          if (Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c)){
            obj.idPrimaryResident=occ.Resident__c;
            obj.strPrimaryResident=occ.Resident__r.Name;
          }
          else if (Id.valueOf(occ.Resident__c).equals(opp.Second_Resident__c)){
            obj.idSecondResident=occ.Resident__c;
            obj.strSecondResident=occ.Resident__r.Name;
          }
          if (string.isNotBlank(occ.Transfer_Apartment__c))
            if ((string.isBlank(obj.idDefaultApartment))||(Id.valueOf(occ.Resident__c).equals(opp.Primary_Resident__c))){
              obj.idDefaultApartment=string.valueOf(Id.valueOf(occ.Transfer_Apartment__c));
              obj.strDefaultLevelOfCare=occ.Transfer_Level_of_Care__c;
              if (occ.Last_Change_Date__c!=null){
                obj.strDefaultTransferDate=datetime.newInstance(occ.Last_Change_Date__c.Year(),occ.Last_Change_Date__c.Month(),occ.Last_Change_Date__c.Day()).format('yyyy-MM-dd');
              }
            }
        }
        Schema.DescribeFieldResult FA = Occupancy__c.Level_of_Care__c.getDescribe();
        Schema.sObjectField TA = FA.getSObjectField();
        List<PicklistEntry> entriesLoC = TA.getDescribe().getPicklistValues();
        obj.lstLevelOfCare = new list<PickListOption>();
        PickListOption OptionB = new PickListOption();
        OptionB.label='';
        OptionB.value='';
        obj.lstLevelOfCare.add(OptionB);
        for (PicklistEntry pe : entriesLoC){
          string strTemp = pe.getValue();
          PickListOption OptionA = new PickListOption();
          OptionA.label=strTemp;
          OptionA.value=strTemp;
          obj.lstLevelOfCare.add(OptionA);
        }
      }
    }
    return obj;
  }
    
    @auraEnabled
  public static string AddSecondResident(Id OppId, Id ResidentId, string strMoveInDate, string strLevelOfCare, Id idApartment, boolean isScheduled){
    string strReturn = '';
    date dtMoveInDate=null;
    if (string.isNotBlank(strMoveInDate))
      dtMoveInDate = date.valueOf(strMoveInDate);
    try{
      if (string.isNotBlank(OppId))
        for (Opportunity opp : [SELECT Id, Community__c, Primary_Resident__c, Second_Resident__c FROM Opportunity WHERE Id = :OppId]){
          Id InitialOccupancyRecordTypeId = Null;
          try{InitialOccupancyRecordTypeId = Occupancy__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Initial Occupancy').getRecordTypeId();}catch (Exception e){system.debug(e);}
          string strNameS = '';
          if (string.isNotBlank(ResidentId))
            for(Contact cont : [SELECT Id, Name FROM Contact WHERE Id = :ResidentId])
              strNameS = cont.Name;
          if (string.isNotBlank(idApartment))
            for (Unit__c oUnit : [SELECT Id, Name FROM Unit__c WHERE Id = :idApartment])
            strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + oUnit.Name;
          if (dtMoveInDate!=null)
            strNameS = (string.isBlank(strNameS)?'':strNameS + ' : ') + datetime.newInstance(dtMoveInDate.year(),dtMoveInDate.month(),dtMoveInDate.day()).format('MMM dd, yyyy');
          Occupancy__c objOcc = new Occupancy__c(Source_Opportunity__c=OppId, 
            RecordTypeId = InitialOccupancyRecordTypeId,
            Apartment__c=idApartment,
            Level_of_Care__c=strLevelOfCare,
            Move_In_Date__c=isScheduled?null:dtMoveInDate,
            Scheduled_Move_In_Date__c=isScheduled?dtMoveInDate:null,
            Resident__c=ResidentId,
            Is_Primary__c=false,
            Name=strNameS);
          insert objOcc;
          if (opp.Second_Resident__c!=ResidentId){
            opp.Second_Resident__c=ResidentId;
            update opp;
          }
        }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static AddSecondResidentFormParams GetAddSecondResidentFormParams(Id OppId){
    AddSecondResidentFormParams objParam = new AddSecondResidentFormParams();
    if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Community__c, Unit__c, Primary_Resident__c, Second_Resident__c, Housing_Type__c, AccountId FROM Opportunity WHERE Id = :OppId])
        for (Occupancy__c occ : [SELECT Id, Move_In_Date__c, Resident__c, Name, Scheduled_Move_In_Date__c, Apartment__c, Apartment__r.Name, Apartment__r.Status__c, Level_of_Care__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_Out_Date__c = null AND ((Move_In_Date__c != null) OR (Scheduled_Move_In_Date__c != null)) order by Id DESC Limit 1]){
          for (Contact cont : [SELECT Id, Name FROM Contact WHERE Prospect__c = true AND AccountId = :opp.AccountId AND Id != :occ.Resident__c ORDER BY Id LIMIT 2]){
            if (string.isBlank(objParam.idResident1)){
              objParam.idResident1=cont.Id;
              objParam.strResident1=cont.Name;
            }
            else if (string.isBlank(objParam.idResident2)){
              objParam.idResident2=cont.Id;
              objParam.strResident2=cont.Name;
            }
          }
          objParam.strCommunity=opp.Community__c;
          objParam.idApartment=occ.Apartment__c;
          objParam.strLevelOfCare=occ.Level_of_Care__c;
          objParam.strApartment=GetApptDesc(occ.Apartment__r.Name,occ.Apartment__r.Status__c);
          if ((occ.Move_In_Date__c==null)&&(occ.Scheduled_Move_In_Date__c!=null)){
            objParam.isScheduled=true;
            objParam.strMoveInDate=datetime.newInstance(occ.Scheduled_Move_In_Date__c.Year(),occ.Scheduled_Move_In_Date__c.Month(),occ.Scheduled_Move_In_Date__c.Day()).format('yyyy-MM-dd');
          }
          else{
            objParam.strMoveInDate=datetime.newInstance(occ.Move_In_Date__c.Year(),occ.Move_In_Date__c.Month(),occ.Move_In_Date__c.Day()).format('yyyy-MM-dd');
          }
          Schema.DescribeFieldResult FA = Unit__c.Housing_Type__c.getDescribe();
          Schema.sObjectField TA = FA.getSObjectField();
          List<PicklistEntry> entriesLoC = TA.getDescribe().getPicklistValues();
          objParam.lstLevelOfCare = new list<PickListOption>();
          for (PicklistEntry pe : entriesLoC){
            string strTemp = pe.getValue();
            PickListOption OptionA = new PickListOption();
            OptionA.label=strTemp;
            OptionA.value=strTemp;
            objParam.lstLevelOfCare.add(OptionA);
          }
          objParam.lstApartment = GetApartments(objParam.strCommunity,objParam.strLevelOfCare,objParam.idApartment,OppId,true);
        }
    return objParam;
  }
    
    @auraEnabled
  public static ReverseMoveOutFormParams GetReverseMoveOutFormParams(Id OppId){
    ReverseMoveOutFormParams objParam = new ReverseMoveOutFormParams();
    if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Primary_Resident__c, Second_Resident__c FROM Opportunity WHERE Id = :OppId AND (Primary_Resident__c != null or Second_Resident__c != null)])
        for (Occupancy__c occ : [SELECT Id, Resident__c, Resident__r.Name, Apartment__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_Out_Date__c != null AND Move_In_Date__c != null AND Resident__c!=null ORDER By Id LIMIT 2]){
          if (string.isBlank(objParam.strResident1)){
            objParam.idResident1=occ.Resident__c;
            objParam.strResident1=occ.Resident__r.Name;
          }
          else{
            objParam.idResident2=occ.Resident__c;
            objParam.strResident2=occ.Resident__r.Name;
          }
        }
    return objParam;
  }
    
    @auraEnabled
  public static RemoveProspectFormParams GetRemoveProspectFormParams(Id OppId){
    RemoveProspectFormParams objParam = new RemoveProspectFormParams();
    map<Id,string> mapResident = new map<Id,string>();
    if (string.isNotBlank(OppId))
      for (Opportunity opp : [SELECT Id, Primary_Resident__c, Second_Resident__c FROM Opportunity WHERE Id = :OppId AND Primary_Resident__c != null]){
        for (Occupancy__c occ : [SELECT Id, Resident__c, Resident__r.Name, Apartment__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_Out_Date__c = null AND ((Move_In_Date__c != null) OR (Scheduled_Move_In_Date__c != null)) AND Resident__c!=null])
          mapResident.put(occ.Resident__c,occ.Resident__r.Name);
        if (mapResident.size()>1)
          for (Id resId : mapResident.keySet()){
            if (resId==opp.Primary_Resident__c){
              objParam.idResident1=resId;
              objParam.strResident1=mapResident.get(resId);
            }
            else if (string.isBlank(objParam.strResident2)){
              objParam.idResident2=resId;
              objParam.strResident2=mapResident.get(resId);
            }
          }
      }
    return objParam;
  }
    
    @auraEnabled
  public static string ReverseMoveOut(Id OppId, string Resident1Id, string Resident2Id){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId)) 
        if ((string.isNotBlank(Resident1Id))||(string.isNotBlank(Resident2Id)))
        for (Opportunity opp : [SELECT Id, Community__c, Primary_Resident__c, Second_Resident__c, Move_Out_Discharge_Date__c, Move_Out_Reason__c, Stagename, RecordTypeId, Housing_Type__c  FROM Opportunity WHERE Id = :OppId]){
          list<Occupancy__c> lstOccMoveOut = new list<Occupancy__c>();
          set<Id> setUnitId = new set<Id>();
          for (Occupancy__c occ : [SELECT Id, Resident__c, Apartment__c, Move_Out_Date__c, Move_Out_Reason__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_Out_Date__c != null AND Move_In_Date__c != null AND Resident__c!=null ORDER By Id LIMIT 2]){
            if (string.isNotBlank(Resident1Id))
              if (Resident1Id==occ.Resident__c){
                lstOccMoveOut.add(occ);
                if (string.isNotBlank(occ.Apartment__c))
                  setUnitId.add(occ.Apartment__c);
                continue;
              }
            if (string.isNotBlank(Resident2Id))
              if (Resident2Id==occ.Resident__c){
                lstOccMoveOut.add(occ);
                if (string.isNotBlank(occ.Apartment__c))
                  setUnitId.add(occ.Apartment__c);
                continue;
              }
          }
          if (!lstOccMoveOut.isEmpty()){
            if (!setUnitId.isEmpty()){
              set<Id> setResId = new set<Id>();
              if (string.isNotBlank(opp.Primary_Resident__c))
                setResId.add(Id.valueOf(opp.Primary_Resident__c));
              if (string.isNotBlank(opp.Second_Resident__c))
                setResId.add(Id.valueOf(opp.Second_Resident__c));
              if (!setResId.isEmpty())
                for (Occupancy__c occ : [SELECT Id, Resident__c, Resident__r.Name, Apartment__c, Apartment__r.Name, Source_Opportunity__c FROM Occupancy__c WHERE Resident__c NOT IN :setResId AND Apartment__c IN :setUnitId AND Move_In_Date__c != null AND Move_Out_Date__c = null LIMIT 1])
                  strReturn = 'Cannot Reverse Move-Out because unit ' + occ.Apartment__r.Name + ' is occupied by ' + occ.Resident__r.Name;
            }
            if (string.isBlank(strReturn)){
              for (Occupancy__c occ : lstOccMoveOut){
                occ.Move_Out_Reason__c=null;
                occ.Move_Out_Date__c=null;
              }
              update lstOccMoveOut;
              opp.Move_Out_Discharge_Date__c=null;
              opp.Move_Out_Reason__c=null;
                            opp.StageName=OccTrigHelper.GetOppStage('Move In', opp.RecordTypeId, opp.Housing_Type__c);
              update opp;
            }
          }
        }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }
    
    @auraEnabled
  public static string RemoveProspect(Id OppId, Id ResidentId){
    string strReturn = '';
    try{
      if (string.isNotBlank(OppId)) 
        if (string.isNotBlank(ResidentId))
        for (Opportunity opp : [SELECT Id, Community__c, Primary_Resident__c, Second_Resident__c FROM Opportunity WHERE Id = :OppId]){
          Occupancy__c occPrimary = null;
          Occupancy__c occRemove = null;
          Id PrimaryResidentId = null;
          Id SecondResidentId = null;
          for (Occupancy__c occ : [SELECT Id, Resident__c, Apartment__c, Is_Primary__c FROM Occupancy__c WHERE Source_Opportunity__c = :OppId AND Move_Out_Date__c = null AND ((Move_In_Date__c != null) OR (Scheduled_Move_In_Date__c != null)) AND Resident__c!=null]){
            if (occ.Resident__c==ResidentId){
              occRemove=occ;
              SecondResidentId=occ.Resident__c;
            }
            else if (occPrimary==null){
              occPrimary=occ;
              PrimaryResidentId=occ.Resident__c;
              occ.Is_Primary__c=true;
            }
          }
          list<Contact> lstContact = new list<Contact>();
          for (Contact cont : [SELECT Id, Primary_Contact__c, Prospect__c, Relationship_to_Prospect__c FROM Contact WHERE Id = :PrimaryResidentId OR Id = :SecondResidentId]){
            if (cont.Id==PrimaryResidentId){
              cont.Primary_Contact__c=true;
              cont.Relationship_to_Prospect__c='Self';
              cont.Prospect__c=true;
            }
            else if (cont.Id==SecondResidentId){
              cont.Primary_Contact__c=false;
              cont.Prospect__c=false;
              if (('Self').equalsIgnoreCase(cont.Relationship_to_Prospect__c))
              cont.Relationship_to_Prospect__c=null;
            }
            lstContact.add(cont);
          }
          opp.Primary_Resident__c=PrimaryResidentId;
          opp.Second_Resident__c=null;
          update opp;
          update lstContact;
          delete occRemove;
          update occPrimary;
        }
    }
    catch(Exception exc){strReturn = exc.getmessage()+ ' . :#' + string.valueOf(exc.getLineNumber());
    }
    return strReturn;
  }

    
    public class OccupancyTabSetting{
    public boolean Enable_Remove_Prospect;
    public boolean Enable_Add_Missing_Resident;
    public boolean Enable_Reset_Deposit;
    public boolean Enable_Reverse_Move_Out;
    public boolean Enable_Add_Temporary_SNF_Stay;
    public boolean Enable_Add_Temporary_Respite_Stay;
    public OccupancyTabSetting(){
      Enable_Remove_Prospect=false;
      Enable_Add_Missing_Resident=false;
      Enable_Reset_Deposit=false;
      Enable_Reverse_Move_Out=false;
      Enable_Add_Temporary_SNF_Stay=false;
      Enable_Add_Temporary_Respite_Stay=false;
      Occupancy_Tab_Setting__c cs = Occupancy_Tab_Setting__c.getinstance();
      if (cs!=null){
        if (cs.Enable_Remove_Prospect__c==true){
          if (string.isNotBlank(cs.Remove_Prospect_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Remove_Prospect_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Remove_Prospect=true;
                    break;
                  }
          }
          else Enable_Remove_Prospect=true;
        }
        if (cs.Enable_Add_Missing_Resident__c==true){
          if (string.isNotBlank(cs.Add_Missing_Resident_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Add_Missing_Resident_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Add_Missing_Resident=true;
                    break;
                  }
          }
          else Enable_Add_Missing_Resident=true;
        }
        if (cs.Enable_Reset_Deposit__c==true){
          if (string.isNotBlank(cs.Reset_Deposit_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Reset_Deposit_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Reset_Deposit=true;
                    break;
                  }
          }
          else Enable_Reset_Deposit=true;
        }
        if (cs.Enable_Reverse_Move_Out__c==true){
          if (string.isNotBlank(cs.Reverse_Move_Out_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Reverse_Move_Out_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Reverse_Move_Out=true;
                    break;
                  }
          }
          else Enable_Reverse_Move_Out=true;
        }
        if (cs.Enable_Add_Temporary_SNF_Stay__c==true){
          if (string.isNotBlank(cs.Add_Temporary_SNF_Stay_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Add_Temporary_SNF_Stay_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Add_Temporary_SNF_Stay=true;
                    break;
                  }
          }
          else Enable_Add_Temporary_SNF_Stay=true;
        }
        if (cs.Enable_Add_Temporary_Respite_Stay__c==true){
          if (string.isNotBlank(cs.Add_Temporary_Respite_Stay_User_Names__c)){
            list<string> lstUN = new list<string>();
            string strCUN = UserInfo.getUserName();
            lstUN = cs.Add_Temporary_Respite_Stay_User_Names__c.split(',');
            if (lstUN!=null) 
              if (!lstUN.isEmpty())
                for (string str : lstUN)
                  if (str.trim().equalsIgnorecase(strCUN)){
                    Enable_Add_Temporary_Respite_Stay=true;
                    break;
                  }
          }
          else Enable_Add_Temporary_Respite_Stay=true;
        }
      }
    }
  }
    
    public class RemoveProspectFormParams{
    @auraEnabled
    public Id idResident1;
    @auraEnabled
    public Id idResident2;
    @auraEnabled
    public string strResident1;
    @auraEnabled
    public string strResident2;
    public RemoveProspectFormParams(){
      strResident1='';
      strResident2='';
      idResident1=null;
      idResident2=null;
    }
  }

  public class ReverseMoveOutFormParams{
    @auraEnabled
    public Id idResident1;
    @auraEnabled
    public Id idResident2;
    @auraEnabled
    public string strResident1;
    @auraEnabled
    public string strResident2;
    public ReverseMoveOutFormParams(){
      strResident1='';
      strResident2='';
      idResident1=null;
      idResident2=null;
    }
  }

  public class AddSecondResidentFormParams{
    @auraEnabled
    public string strCommunity;
    @auraEnabled
    public Id idResident1;
    @auraEnabled
    public Id idResident2;
    @auraEnabled
    public string strResident1;
    @auraEnabled
    public string strResident2;
    @auraEnabled
    public Id idApartment;
    @auraEnabled
    public string strLevelOfCare;
    @auraEnabled
    public string strApartment;
    @auraEnabled
    public string strMoveInDate;
    @AuraEnabled
    public list<PickListOption> lstLevelOfCare;
    @AuraEnabled
    public list<PickListOption> lstApartment;
    @AuraEnabled
    public boolean isScheduled;
    public AddSecondResidentFormParams(){
      strCommunity='';
      strResident1='';
      strResident2='';
      strLevelOfCare='';
      strApartment='';
      strMoveInDate='';
      isScheduled=false;
    }
  }

  public class MoveOutFormParams{
    @AuraEnabled
    public list<PickListOption> lstMoveOutReason;
    @auraEnabled
    public Id idPrimaryResident;
    @auraEnabled
    public Id idSecondResident;
    @auraEnabled
    public string strPrimaryResident;
    @auraEnabled
    public string strSecondResident;
    @auraEnabled
    public string strDefaultMoveOutDate;
    @auraEnabled
    public string strDefaultMoveOutReason;
    public MoveOutFormParams(){
      strDefaultMoveOutDate='';
      strDefaultMoveOutReason='';
      strSecondResident='';
      strPrimaryResident='';
    }
  }

  public class CancelScheduledMoveOutFormParams{
    @auraEnabled
    public Id idPrimaryResident;
    @auraEnabled
    public Id idSecondResident;
    @auraEnabled
    public string strPrimaryResident;
    @auraEnabled
    public string strSecondResident;
  }

  public class TransferFormParams{
    @auraEnabled
    public string strCommunity;
    @AuraEnabled
    public list<PickListOption> lstLevelOfCare;
    @auraEnabled
    public Id idPrimaryResident;
    @auraEnabled
    public Id idSecondResident;
    @auraEnabled
    public string strPrimaryResident;
    @auraEnabled
    public string strSecondResident;
    @auraEnabled
    public string strDefaultLevelOfCare;
    @auraEnabled
    public string idDefaultApartment;
    @auraEnabled
    public string strDefaultTransferDate;
    public TransferFormParams(){
      strDefaultTransferDate='';
      strDefaultLevelOfCare='';
      idDefaultApartment='';
    }
  }

  public class CancelDepositFormParams{
    @auraEnabled
    public string strCommunity;
    @auraEnabled
    public string strCancelDate;
    @auraEnabled
    public string strCancelReason;
    @AuraEnabled
    public list<PickListOption> lstCancelReason;
    @auraEnabled
    public decimal dblRefundAmount;
    @auraEnabled
    public string strCompetitor;
    @AuraEnabled
    public list<PickListOption> lstCompetitor;
    public CancelDepositFormParams(){
      strCommunity='';
      strCancelDate='';
      strCancelReason='';
      dblRefundAmount=null;
      strCompetitor='';
    }
  }

  public class MoveInFormParams{
    @auraEnabled
    public string strCommunity;
    @auraEnabled
    public string strMoveInDate;
    @auraEnabled
    public Id idApartment;
    @auraEnabled
    public string strLevelOfCare;
    @auraEnabled
    public string strApartment;
    @auraEnabled
    public string strPrimaryResident;
    @auraEnabled
    public string strSecondResident;
    @auraEnabled
    public Id idPrimaryResident;
    @auraEnabled
    public Id idSecondResident;
    @auraEnabled
    public string strPromissoryNoteDue;
    @auraEnabled
    public string strMoveInType; 
    @AuraEnabled
    public list<PickListOption> lstLevelOfCare;
    @AuraEnabled
    public list<PickListOption> lstApartment;
    @auraEnabled
    public boolean isAmountRequired;
    @auraEnabled
    public decimal dblRebatableAmount;
    @auraEnabled
    public string strDefaultAmount;
    //@auraEnabled
    //public string strArbitrationAgreement;
    //@AuraEnabled
    //public list<PickListOption> lstArbitrationAgreement;
  }

  public class PickListOption{
    @AuraEnabled
    public string value;
    @AuraEnabled
    public string label;
    }

  public class OccInfo{
    public OccInfo(Occupancy__c occ){
      this.Id='';
      this.Name='';
      this.ApartmentId='';
      this.ApartmentName='';
      this.Community='';
      this.LevelofCare='';
      this.MoveInDate='';
      this.MoveOutDate='';
      this.ResidentId='';
      this.ResidentName='';
      this.ResidentAccountId='';
      this.SNFRecordTypeId='';
      this.RespiteRecordTypeId='';
      this.Enable_Add_Temporary_SNF_Stay=false;
      this.Enable_Add_Temporary_Respite_Stay=false;
      this.SNFOppCloseDate='';
      if (occ!=null){
        this.Id=string.valueOf(occ.Id);
        this.Name=occ.Name;
        if (string.isNotBlank(occ.Community__c))
          this.Community=occ.Community__c;
        if (string.isNotBlank(occ.Apartment__c)){
          this.ApartmentId=string.valueOf(occ.Apartment__c);
          this.ApartmentName=occ.Apartment__r.Name;
        } 
        if (string.isNotBlank(occ.Level_of_Care__c))
          this.LevelofCare=occ.Level_of_Care__c;
        if (occ.Move_In_Date__c!=null)
          this.MoveInDate=occ.Move_In_Date__c.format();
        if (occ.Move_Out_Date__c!=null)
          this.MoveOutDate=occ.Move_Out_Date__c.format();
        if (string.isNotBlank(occ.Resident__c)){
          this.ResidentId=string.valueOf(occ.Resident__c);
          this.ResidentName=occ.Resident__r.Name;
          if (string.isNotBlank(occ.Resident__r.AccountId))
            this.ResidentAccountId=string.valueOf(occ.Resident__r.AccountId);
        }
      }
    }
    @AuraEnabled
      public string Id;
    @AuraEnabled
      public string Name;
    @AuraEnabled
      public string Community;
    @AuraEnabled
      public string ApartmentName;
    @AuraEnabled
      public string ApartmentId;
    @AuraEnabled
      public string LevelofCare;
    @AuraEnabled
      public string MoveInDate;
    @AuraEnabled
      public string MoveOutDate;
    @AuraEnabled
      public string ResidentName;
    @AuraEnabled
      public string ResidentAccountId;
    @AuraEnabled
      public string ResidentId;
    @AuraEnabled
      public string SNFRecordTypeId;
    @AuraEnabled
      public string RespiteRecordTypeId;
    @AuraEnabled
    public boolean Enable_Add_Temporary_SNF_Stay;
    @AuraEnabled
    public boolean Enable_Add_Temporary_Respite_Stay;
    @AuraEnabled
    public string SNFOppCloseDate;
  }

  public class PendingChange implements Comparable{
    @AuraEnabled
    public string strResident;
    @AuraEnabled
    public string strDate;
    @AuraEnabled
    public date dtDate;
    @AuraEnabled
    public string strType;
    @AuraEnabled
    public string strApartment;
    public Integer compareTo(Object other){
      date otherdtDate = ((PendingChange)other).dtDate;
      if (dtDate == otherdtDate) return 0;
      if (dtDate > otherdtDate) return 1;
      return -1;
    }
    }

}