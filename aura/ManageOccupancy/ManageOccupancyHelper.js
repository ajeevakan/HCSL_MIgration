({
	GetButtonNames : function(cmp) {
		var action = cmp.get("c.GetButtonNames");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
			cmp.set("v.lstButtons", data.getReturnValue());
		});
        cmp.set("v.lstButtons", undefined);
		$A.enqueueAction(action);

        var action2 = cmp.get("c.GetPendingChanges");
		action2.setParams({
			OppId: cmp.get("v.recordId")
		});
		action2.setCallback(this, function(data){
			cmp.set("v.lstPendingChange", data.getReturnValue());
		});
        cmp.set("v.lstPendingChange", undefined);
		$A.enqueueAction(action2);
        
        var action1 = cmp.get("c.GetOccupancies");
		action1.setParams({
			OppId: cmp.get("v.recordId")
		});
		action1.setCallback(this, function(data){
			cmp.set("v.lstOccupancy", data.getReturnValue());
            this.getShowAddCol(cmp);
		});
        cmp.set("v.lstOccupancy", undefined);
		$A.enqueueAction(action1);
	},
    
    GetButtonNamesRefresh : function(cmp) {
		var action = cmp.get("c.GetButtonNames");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
			cmp.set("v.lstButtons", data.getReturnValue());
		});
        cmp.set("v.lstButtons", undefined);
		$A.enqueueAction(action);
        
        var action2 = cmp.get("c.GetPendingChanges");
		action2.setParams({
			OppId: cmp.get("v.recordId")
		});
		action2.setCallback(this, function(data){
			cmp.set("v.lstPendingChange", data.getReturnValue());
		});
        cmp.set("v.lstPendingChange", undefined);
		$A.enqueueAction(action2);
        
        var action1 = cmp.get("c.GetOccupancies");
		action1.setParams({
			OppId: cmp.get("v.recordId")
		});
		action1.setCallback(this, function(data){
			cmp.set("v.lstOccupancy", data.getReturnValue());
            this.getShowAddCol(cmp);
            $A.get("e.force:refreshView").fire();
		});
        cmp.set("v.lstOccupancy", undefined);
		$A.enqueueAction(action1);
	},
    
    GetMoveInFormParams : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetMoveInFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId"),
            MoveInType: cmp.get("v.ActionType")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.MoveInFormParams", data.getReturnValue());
			cmp.set("v.dblAmount", cmp.get("v.MoveInFormParams").strDefaultAmount);
            console.log(cmp.get("v.MoveInFormParams"));
            console.log(cmp.get("v.MoveInFormParams").idApartment);
            if ((cmp.get("v.MoveInFormParams").idApartment===undefined)||(cmp.get("v.MoveInFormParams").idApartment==="")||(cmp.get("v.MoveInFormParams").idApartment===null))
                cmp.set("v.MoveInUnitDisable", false);
            else
                cmp.set("v.MoveInUnitDisable", true);
            console.log(cmp.get("v.MoveInUnitDisable"));
		});
		$A.enqueueAction(action);
	},
    
    GetCancelDepositFormParams : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetCancelDepositFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.CancelDepositFormParams", data.getReturnValue());
		});
		$A.enqueueAction(action);
	},
    
    GetAddSecondResidentFormParams : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetAddSecondResidentFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.AddSecondResidentFormParams", data.getReturnValue());
            if (!((cmp.get("v.AddSecondResidentFormParams").idResident1==null)||(cmp.get("v.AddSecondResidentFormParams").idResident1==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.AddSecondResidentFormParams").idResident2==null)||(cmp.get("v.AddSecondResidentFormParams").idResident2==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
		});
		$A.enqueueAction(action);
	},
    
    GetRemoveProspectFormParams : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetRemoveProspectFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.RemoveProspectFormParams", data.getReturnValue());
            if (!((cmp.get("v.RemoveProspectFormParams").idResident1==null)||(cmp.get("v.RemoveProspectFormParams").idResident1==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.RemoveProspectFormParams").idResident2==null)||(cmp.get("v.RemoveProspectFormParams").idResident2==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
		});
		$A.enqueueAction(action);
	},
    
    GetReverseMoveOutFormParams : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetReverseMoveOutFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.ReverseMoveOutFormParams", data.getReturnValue());
            if (!((cmp.get("v.ReverseMoveOutFormParams").idResident1==null)||(cmp.get("v.ReverseMoveOutFormParams").idResident1=="")||(cmp.get("v.ReverseMoveOutFormParams").idResident1==undefined))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.ReverseMoveOutFormParams").idResident2==null)||(cmp.get("v.ReverseMoveOutFormParams").idResident2=="")||(cmp.get("v.ReverseMoveOutFormParams").idResident2==undefined))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
		});
		$A.enqueueAction(action);
	},
	
	GetMoveOutFormParams : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetMoveOutFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
            var oMoveOutFormParams = data.getReturnValue();
            cmp.set("v.MoveOutFormParams", oMoveOutFormParams);
            if ((oMoveOutFormParams.strDefaultMoveOutDate==undefined)||(oMoveOutFormParams.strDefaultMoveOutDate==""))
                cmp.set("v.dtMoveOut", undefined);
            else
                cmp.set("v.dtMoveOut", oMoveOutFormParams.strDefaultMoveOutDate);
            if ((oMoveOutFormParams.strDefaultMoveOutReason==undefined)||(oMoveOutFormParams.strDefaultMoveOutReason==""))
                cmp.set("v.strMoveOutReason", "");
            else
                cmp.set("v.strMoveOutReason", oMoveOutFormParams.strDefaultMoveOutReason);
			if (!((cmp.get("v.MoveOutFormParams").idPrimaryResident==null)||(cmp.get("v.MoveOutFormParams").idPrimaryResident==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.MoveOutFormParams").idSecondResident==null)||(cmp.get("v.MoveOutFormParams").idSecondResident==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
            //this.GetRebatableRefundParams(cmp);
		});
		$A.enqueueAction(action);
	},
	
	GetCancelScheduledMoveOutFormParams : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetCancelScheduledMoveOutFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
			cmp.set("v.Spinner", false);
			cmp.set("v.CancelScheduledMoveOutFormParams", data.getReturnValue());
			if (!((cmp.get("v.CancelScheduledMoveOutFormParams").idPrimaryResident==null)||(cmp.get("v.CancelScheduledMoveOutFormParams").idPrimaryResident==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.CancelScheduledMoveOutFormParams").idSecondResident==null)||(cmp.get("v.CancelScheduledMoveOutFormParams").idSecondResident==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
		});
		$A.enqueueAction(action);
	},
	
	GetCancelScheduledTransferFormParams : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetCancelScheduledTransferFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
			cmp.set("v.Spinner", false);
			cmp.set("v.CancelScheduledTransferFormParams", data.getReturnValue());
			if (!((cmp.get("v.CancelScheduledTransferFormParams").idPrimaryResident==null)||(cmp.get("v.CancelScheduledTransferFormParams").idPrimaryResident==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.CancelScheduledTransferFormParams").idSecondResident==null)||(cmp.get("v.CancelScheduledTransferFormParams").idSecondResident==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
			}
		});
		$A.enqueueAction(action);
	},
	/*
    GetPNoteFormParams : function(cmp){
        cmp.set("v.dblPNoteAmount", undefined);
		cmp.set("v.strPNoteDate", "");
		cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetPromissoryNoteDueAmt");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
			cmp.set("v.dblPNoteAmount", data.getReturnValue());
		});
		$A.enqueueAction(action);
    },
    */
	GetTransferFormParams : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetTransferFormParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
            cmp.set("v.Spinner", false);
            var oTransferFormParams = data.getReturnValue();
            cmp.set("v.TransferFormParams", oTransferFormParams);
            if ((oTransferFormParams.strDefaultTransferDate=="")||(oTransferFormParams.strDefaultTransferDate==undefined))
                cmp.set("v.dtTransfer", undefined);
            else
                cmp.set("v.dtTransfer", oTransferFormParams.strDefaultTransferDate);
            
            if ((oTransferFormParams.strDefaultLevelOfCare=="")||(oTransferFormParams.strDefaultLevelOfCare==undefined))
                cmp.set("v.strLevelofCare", "");
            else
                cmp.set("v.strLevelofCare", oTransferFormParams.strDefaultLevelOfCare);
            if ((oTransferFormParams.idDefaultApartment=="")||(oTransferFormParams.idDefaultApartment==undefined))
                cmp.set("v.idApartment", "");
            else
                cmp.set("v.idApartment", oTransferFormParams.idDefaultApartment);
            cmp.set("v.lstApartment", undefined);
            if (!((cmp.get("v.TransferFormParams").idPrimaryResident==null)||(cmp.get("v.TransferFormParams").idPrimaryResident==""))){
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", true);
			}
			else{
				cmp.set("v.checkedRes1", false);
				cmp.set("v.showRes1", false);
			}
			if (!((cmp.get("v.TransferFormParams").idSecondResident==null)||(cmp.get("v.TransferFormParams").idSecondResident==""))){
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", true);
			}
			else{
				cmp.set("v.checkedRes2", false);
				cmp.set("v.showRes2", false);
            }
            if (!((oTransferFormParams.strDefaultLevelOfCare=="")||(oTransferFormParams.strDefaultLevelOfCare==undefined)))
                this.getlstApartmentTX(cmp);
            //this.GetRebatableRefundParams(cmp);
		});
		$A.enqueueAction(action);
	},
    /*
    GetRebatableRefundParams : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.GetRebatableRefundParams");
		action.setParams({
			OppId: cmp.get("v.recordId")
		});
		action.setCallback(this, function(data){
			cmp.set("v.Spinner", false);
			cmp.set("v.RebatableRefundParams", data.getReturnValue());
            this.CalcShowRebatableRefund(cmp);
		});
        cmp.set("v.RebatableRefundParams", undefined);
		$A.enqueueAction(action);
	},
    
    CalcShowRebatableRefund : function(cmp) {
        cmp.set("v.showRebatableRefund", false);
        cmp.set("v.showAddEntranceFee", false);
		var ResidentialLiving = $A.get("Label.c.Residential_Living");
        var RebatableRefundParams = cmp.get("v.RebatableRefundParams");
        console.log(RebatableRefundParams);
        var amtExist = false;
        if (!(RebatableRefundParams==undefined))
            if (!(RebatableRefundParams.dblRefundAmount==undefined))
                if ((RebatableRefundParams.dblRefundAmount>0))
                    amtExist=true;
        if (RebatableRefundParams){
            var ActionType = cmp.get("v.ActionType");
            if ((ActionType=="Schedule Move-Out")||(ActionType=="Move-Out")){
                if (cmp.get("v.checkedRes1"))
                    if (amtExist)//(ResidentialLiving==RebatableRefundParams.strPrimaryLevelOfCare)
                        if (RebatableRefundParams.isPrimaryApartmentSingle){
                            var showRebatableRefund = true;
                            if (RebatableRefundParams.idSecondResident!="")
                                if (RebatableRefundParams.idSecondApartment==RebatableRefundParams.idPrimaryApartment){
                                    if (!cmp.get("v.checkedRes2"))
                                        showRebatableRefund=false;
                                }
                            cmp.set("v.showRebatableRefund", showRebatableRefund);
                        }
                if (!cmp.get("v.showRebatableRefund"))
                    if (cmp.get("v.checkedRes2"))
                        if (amtExist)//(ResidentialLiving==RebatableRefundParams.strSecondLevelOfCare)
                            if (RebatableRefundParams.isSecondApartmentSingle){
                                var showRebatableRefund = true;
                                if (RebatableRefundParams.idPrimaryResident!="")
                                    if (RebatableRefundParams.idSecondApartment==RebatableRefundParams.idPrimaryApartment){
                                        if (!cmp.get("v.checkedRes1"))
                                            showRebatableRefund=false;
                                    }
                                cmp.set("v.showRebatableRefund", showRebatableRefund);
                            }
            }
            else if ((ActionType=="Schedule Transfer")||(ActionType=="Transfer")){
                var strLevelofCare = cmp.get("v.strLevelofCare");
                if (cmp.get("v.checkedRes1"))
                    //if (amtExist)
                    {//(ResidentialLiving==RebatableRefundParams.strPrimaryLevelOfCare)
                        if (ResidentialLiving!=strLevelofCare){
                            if (RebatableRefundParams.isPrimaryApartmentSingle){
                                if (amtExist){
                                    var showRebatableRefund = true;
                                    if (RebatableRefundParams.idSecondResident!="")
                                        if (RebatableRefundParams.idSecondApartment==RebatableRefundParams.idPrimaryApartment){
                                            if (!cmp.get("v.checkedRes2"))
                                                showRebatableRefund=false;
                                        }
                                    cmp.set("v.showRebatableRefund", showRebatableRefund);
                                }
                        	}
                        }
                        else{
                            cmp.set("v.showAddEntranceFee", true);
                            cmp.set("v.dblAddEntranceFee", undefined);
                        }
                    }
                if (!cmp.get("v.showRebatableRefund"))
                    if (cmp.get("v.checkedRes2"))
                        //if (amtExist)
                        {//(ResidentialLiving==RebatableRefundParams.strSecondLevelOfCare)
                            if (ResidentialLiving!=strLevelofCare){
                                if (amtExist){
                                    if (RebatableRefundParams.isSecondApartmentSingle){
                                        var showRebatableRefund = true;
                                        if (RebatableRefundParams.idPrimaryResident!="")
                                            if (RebatableRefundParams.idSecondApartment==RebatableRefundParams.idPrimaryApartment){
                                                if (!cmp.get("v.checkedRes1"))
                                                    showRebatableRefund=false;
                                            }
                                        cmp.set("v.showRebatableRefund", showRebatableRefund);
                                    }
                            	}
                            }
                            else{
                                cmp.set("v.showAddEntranceFee", true);
                                cmp.set("v.dblAddEntranceFee", undefined);
                            }
                        }
            }
        }
    },
    */
    getlstApartment : function(cmp) {
        var strCommunity1 = cmp.get("v.MoveInFormParams").strCommunity;
        var strLevelOfCare1 = cmp.get("v.MoveInFormParams").strLevelOfCare;
        var boolContinue = false;
        var boolfilterOccupied = true;
        if (!((strCommunity1==null)||(strCommunity1=="")))
            if (!((strLevelOfCare1==null)||(strLevelOfCare1=="")))
                boolContinue = true;
        if (boolContinue){
        	cmp.set("v.Spinner", true);
            var action = cmp.get("c.GetApartments");
            action.setParams({
                strCommunity: strCommunity1,
                strLevelOfCare: strLevelOfCare1,
                OppId: cmp.get("v.recordId"),
                filterOccupied: boolfilterOccupied
            });
            action.setCallback(this, function(data){
                cmp.set("v.MoveInFormParams.idApartment", "");
                cmp.set("v.MoveInFormParams.lstApartment", data.getReturnValue());
                cmp.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": "Level of Care is blank."
            });
            console.log("ERROR: " + strError);
            cmp.set("v.MoveInFormParams.idApartment", "");
            cmp.set("v.MoveInFormParams.lstApartment", [{value:"",label:""}]);
            resultsToast.fire();
        }
    },
    
    getlstApartmentT : function(cmp) {
        var strCommunity1 = cmp.get("v.TransferFormParams").strCommunity;
        var strLevelOfCare1 = cmp.get("v.strLevelofCare");
        var boolContinue = false;
        var boolfilterOccupied = true;
        var ActionType = cmp.get("v.ActionType");
        if ((ActionType=="Schedule Transfer"))
        boolfilterOccupied=false;
        if (!((strCommunity1==null)||(strCommunity1=="")))
            if (!((strLevelOfCare1==null)||(strLevelOfCare1=="")))
                boolContinue = true;
        if (boolContinue){
        	cmp.set("v.Spinner", true);
            var action = cmp.get("c.GetApartments");
            action.setParams({
                strCommunity: strCommunity1,
                strLevelOfCare: strLevelOfCare1,
                OppId: cmp.get("v.recordId"),
                filterOccupied: boolfilterOccupied
            });
            action.setCallback(this, function(data){
                cmp.set("v.idApartment", "");
                cmp.set("v.lstApartment", data.getReturnValue());
                cmp.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": "Level of Care is blank."
            });
            console.log("ERROR: " + strError);
            cmp.set("v.idApartment", "");
            cmp.set("v.lstApartment", [{value:"",label:""}]);
            resultsToast.fire();
        }
    },

    getlstApartmentTX : function(cmp) {
        var strCommunity1 = cmp.get("v.TransferFormParams").strCommunity;
        var strLevelOfCare1 = cmp.get("v.strLevelofCare");
        var boolContinue = false;
        var boolfilterOccupied = true;
        var ActionType = cmp.get("v.ActionType");
        if ((ActionType=="Schedule Transfer"))
        boolfilterOccupied=false;
        if (!((strCommunity1==null)||(strCommunity1=="")))
            if (!((strLevelOfCare1==null)||(strLevelOfCare1=="")))
                boolContinue = true;
        if (boolContinue){
        	cmp.set("v.Spinner", true);
            var action = cmp.get("c.GetApartments");
            action.setParams({
                strCommunity: strCommunity1,
                strLevelOfCare: strLevelOfCare1,
                idApartment: cmp.get("v.idApartment"),
                OppId: cmp.get("v.recordId"),
                filterOccupied: boolfilterOccupied
            });
            action.setCallback(this, function(data){
                //cmp.set("v.idApartment", "");
                cmp.set("v.lstApartment", data.getReturnValue());
                cmp.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": "Level of Care is blank."
            });
            console.log("ERROR: " + strError);
            cmp.set("v.idApartment", "");
            cmp.set("v.lstApartment", [{value:"",label:""}]);
            resultsToast.fire();
        }
    },
    
    getlstApartmentA : function(cmp) {
        var strCommunity1 = cmp.get("v.AddSecondResidentFormParams").strCommunity;
        var strLevelOfCare1 = cmp.get("v.AddSecondResidentFormParams").strLevelOfCare;
        var boolContinue = false;
        if (!((strCommunity1==null)||(strCommunity1=="")))
            if (!((strLevelOfCare1==null)||(strLevelOfCare1=="")))
                boolContinue = true;
        if (boolContinue){
        	cmp.set("v.Spinner", true);
            var action = cmp.get("c.GetApartments");
            action.setParams({
                strCommunity: strCommunity1,
                strLevelOfCare: strLevelOfCare1,
                OppId: cmp.get("v.recordId"),
                filterOccupied: true
            });
            action.setCallback(this, function(data){
                cmp.set("v.AddSecondResidentFormParams.idApartment", "");
                cmp.set("v.AddSecondResidentFormParams.lstApartment", data.getReturnValue());
                cmp.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": "Level of Care is blank."
            });
            console.log("ERROR: " + strError);
            cmp.set("v.AddSecondResidentFormParams.idApartment", "");
            cmp.set("v.AddSecondResidentFormParams.lstApartment", [{value:"",label:""}]);
            resultsToast.fire();
        }
    },
    
    MoveInCancel : function(cmp) {
        cmp.set("v.ActionType", "");
        cmp.set("v.dblAmount", "");
    },
    /*
    PNoteValidate : function(cmp) {
        var dblPNoteAmount = cmp.get("v.dblPNoteAmount");
        var strPNoteDate = cmp.get("v.strPNoteDate");
        var boolContinue = false;
        var strError = "";
        if (((strPNoteDate==null)||(strPNoteDate=="")))
            strError = "Date is blank.";
        else if (((dblPNoteAmount==null)||(dblPNoteAmount=="")||(dblPNoteAmount==undefined)))
            strError = "Amount is blank.";
        else 
            boolContinue = true;
        if (boolContinue){
            this.PayPromissoryNote(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    PayPromissoryNote : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.PayPromissoryNote");
		action.setParams({
			OppId: cmp.get("v.recordId"),
            dblAmount: cmp.get("v.dblPNoteAmount"),
            strPromissoryNoteDate: cmp.get("v.strPNoteDate")
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                cmp.set("v.dblPNoteAmount", "");
                cmp.set("v.strPNoteDate", "");
                this.GetButtonNamesRefresh(cmp);
            }
		});
		$A.enqueueAction(action);
	},
    */
    
    CancelDepositValidate : function(cmp,SetAccountStatustoLost){
        var strCancelDate = cmp.get("v.CancelDepositFormParams").strCancelDate;
        var strCancelReason = cmp.get("v.CancelDepositFormParams").strCancelReason;
        var strError = "";
        var boolContinue = false;
        if (((strCancelDate==null)||(strCancelDate=="")||(strCancelDate==undefined)))
            strError = "Cancel Date is blank.";
        else if (((strCancelReason==null)||(strCancelReason=="")||(strCancelReason==undefined)))
            strError = "Cancel Reason is blank."
        else boolContinue = true;
        
        if (boolContinue){
            this.CancelDeposit(cmp,SetAccountStatustoLost);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    MoveInValidate : function(cmp) {
        console.log(cmp.get("v.MoveInFormParams"));
        var strCommunity = cmp.get("v.MoveInFormParams").strCommunity;
        var strLevelOfCare = cmp.get("v.MoveInFormParams").strLevelOfCare;
        var strMoveInDate = cmp.get("v.MoveInFormParams").strMoveInDate;
        var idApartment = cmp.get("v.MoveInFormParams").idApartment;
//        var strArbitrationAgreement = cmp.get("v.MoveInFormParams").strArbitrationAgreement;
        var dblAmount =  cmp.get("v.dblAmount");
        var boolContinue = false;
        var strError = "";
        if (((strLevelOfCare==null)||(strLevelOfCare=="")))
            strError = "Level of Care is blank.";
//        if (((strArbitrationAgreement==null)||(strArbitrationAgreement=="")))
//            strError = "Arbitration Agreement is blank.";
        else if (((idApartment==null)||(idApartment=="")))
            strError = "Apartment is blank.";
        else if (((strMoveInDate==null)||(strMoveInDate=="")))
            strError = "Move-In-Date is blank.";
        else if (((dblAmount==null)||(dblAmount=="")||(dblAmount==undefined))){
            if (cmp.get("v.MoveInFormParams.isAmountRequired"))
            	strError = "Amount is blank.";
            else 
                boolContinue = true;
        }
        else boolContinue = true;
        if (boolContinue){
            var varDate = new Date(strMoveInDate);
            var today = new Date();
            if(varDate > today){
                strError = "Move-In Date is in future.";
                boolContinue = false;
            }
        }
        if (boolContinue){
            this.MoveIn(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    SetPromissoryNoteDue : function(cmp){
    	var ActionType = cmp.get("v.ActionType");
    	if ((ActionType=="Promissory Note Deposit")){
        	var strMoveInDate = cmp.get("v.MoveInFormParams").strMoveInDate;
        	if (!(((strMoveInDate==null)||(strMoveInDate=="")||(strMoveInDate==undefined)))){
        		//var strPromissoryNoteDue = cmp.get("v.MoveInFormParams").strPromissoryNoteDue;
        		//if ((((strPromissoryNoteDue==null)||(strPromissoryNoteDue=="")||(strPromissoryNoteDue==undefined))))
        		{
        			var varDate = new Date(strMoveInDate);
        			varDate.setDate(varDate.getDate() + 80);
        			var strDate = varDate.toISOString().slice(0, 10);
        			cmp.set("v.MoveInFormParams.strPromissoryNoteDue",strDate);
        		}
        	}
        }
    },
    
    CancelDeposit : function(cmp, bSetAccountStatustoLost){
        var dblRefundAmount = "";
        if (!(cmp.get("v.CancelDepositFormParams").dblRefundAmount==undefined))
            dblRefundAmount=""+cmp.get("v.CancelDepositFormParams").dblRefundAmount;
        cmp.set("v.Spinner", true);
        var action = cmp.get("c.CancelDeposit");
        action.setParams({
			OppId: cmp.get("v.recordId"),
            strCancelDate: cmp.get("v.CancelDepositFormParams").strCancelDate,
            strCancelReason: cmp.get("v.CancelDepositFormParams").strCancelReason,
            strRefundAmount: dblRefundAmount,
            strCompetitor: cmp.get("v.CancelDepositFormParams").strCompetitor,
            SetAccountStatustoLost: bSetAccountStatustoLost
		});
        action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
            if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
            }
		});
		$A.enqueueAction(action);
    },
    
    ResetDeposit : function(cmp){
        cmp.set("v.Spinner", true);
        var action = cmp.get("c.ResetDeposit");
        action.setParams({
			OppId: cmp.get("v.recordId")
		});
        action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
            if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
            }
		});
		$A.enqueueAction(action);
    },
    
    MoveIn : function(cmp) {
        var dblRebatableAmount = "";
        var dblAmount = "";
        if (!(cmp.get("v.MoveInFormParams").dblRebatableAmount==undefined))
            dblRebatableAmount=""+cmp.get("v.MoveInFormParams").dblRebatableAmount;
        if (!(cmp.get("v.dblAmount")==undefined))
            dblAmount=""+cmp.get("v.dblAmount");
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.MoveIn");
		action.setParams({
			OppId: cmp.get("v.recordId"),
            MoveInType: cmp.get("v.ActionType"),
            strMoveInDate: cmp.get("v.MoveInFormParams").strMoveInDate,
            idApartment: cmp.get("v.MoveInFormParams").idApartment,
            dblAmount: dblAmount,
            strPromissoryNoteDue: cmp.get("v.MoveInFormParams").strPromissoryNoteDue,
            strRefund: dblRebatableAmount,
            strArbitrationAgreement: ""
		}); //cmp.get("v.MoveInFormParams").strArbitrationAgreement
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
            if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                cmp.set("v.dblAmount", "");
                this.GetButtonNamesRefresh(cmp);
            }
			
		});
		$A.enqueueAction(action);
	},
	
	MoveOutValidate : function(cmp){
        var strMoveOutReason = cmp.get("v.strMoveOutReason");
        var dtMoveOut = cmp.get("v.dtMoveOut");
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (((strMoveOutReason==null)||(strMoveOutReason=="")))
            strError = "Move-Out Reason is blank.";
        else if (((dtMoveOut==null)||(dtMoveOut=="")||(dtMoveOut==undefined)))
            strError = "Move-Out Date is blank.";
        else if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        //else boolContinue = true;
        else{
            var ActionType = cmp.get("v.ActionType");
            if ((ActionType=="Move-Out")){
                var varDate = new Date(dtMoveOut);
                var today = new Date();
                if(varDate > today){
                    strError = "Move-Out Date is in future.";
                }
                else
                    boolContinue = true;
            }
            else
            	boolContinue = true;
        }
        if (boolContinue){
            this.MoveOut(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    AddSecondResidentValidate : function(cmp){
        
        var strLevelOfCare = cmp.get("v.AddSecondResidentFormParams").strLevelOfCare;
        var idApartment = cmp.get("v.AddSecondResidentFormParams").idApartment;
        var strMoveInDate = cmp.get("v.AddSecondResidentFormParams").strMoveInDate;
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (((strLevelOfCare==null)||(strLevelOfCare=="")||(strLevelOfCare==undefined)))
            strError = "Level of Care is blank.";
        else if (((idApartment==null)||(idApartment=="")||(idApartment==undefined)))
            strError = "Apartment is blank.";
        else if (((strMoveInDate==null)||(strMoveInDate=="")||(strMoveInDate==undefined)))
            strError = "Move-In Date is blank.";
        else if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else if ((checkedRes1&&checkedRes2))
        	strError = "Only one Resident can be checked.";
        //else boolContinue = true;
        else{
            var isScheduled = cmp.get("v.AddSecondResidentFormParams.isScheduled");
            if ((isScheduled==false)){
                var varDate = new Date(strMoveInDate);
                var today = new Date();
                if(varDate > today){
                    strError = "Move-In Date is in future.";
                    boolContinue = false;
                }
                else boolContinue = true;
            }
            else
            	boolContinue = true;
        }
        if (boolContinue){
            this.AddSecondResident(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    AddSecondResident : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.AddSecondResident");
		var Resident_Id;
        if (cmp.get("v.showRes1")){
			if (cmp.get("v.checkedRes1"))
				Resident_Id=cmp.get("v.AddSecondResidentFormParams").idResident1;
        }
		else if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				Resident_Id=cmp.get("v.AddSecondResidentFormParams").idResident2;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            ResidentId: Resident_Id,
            strMoveInDate: cmp.get("v.AddSecondResidentFormParams").strMoveInDate,
            strLevelOfCare: cmp.get("v.AddSecondResidentFormParams").strLevelOfCare,
            idApartment: cmp.get("v.AddSecondResidentFormParams").idApartment,
            isScheduled: cmp.get("v.AddSecondResidentFormParams").isScheduled
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
                //$A.get('e.force:refreshView').fire();
            }
			
		});
		$A.enqueueAction(action);
	},
    
    RemoveProspectValidate : function(cmp){
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else if ((checkedRes1&&checkedRes2))
        	strError = "Only one Resident can be checked.";
        else boolContinue = true;
        if (boolContinue){
            this.RemoveProspect(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    RemoveProspect : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.RemoveProspect");
		var Resident_Id;
        if (cmp.get("v.showRes1")){
			if (cmp.get("v.checkedRes1"))
				Resident_Id=cmp.get("v.RemoveProspectFormParams").idResident1;
            else if (cmp.get("v.showRes2"))
				if (cmp.get("v.checkedRes2"))
					Resident_Id=cmp.get("v.RemoveProspectFormParams").idResident2;
        }
		else if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				Resident_Id=cmp.get("v.RemoveProspectFormParams").idResident2;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            ResidentId: Resident_Id
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
                //$A.get('e.force:refreshView').fire();
            }
			
		});
		$A.enqueueAction(action);
	},
    
    ReverseMoveOutValidate : function(cmp){
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else boolContinue = true;
        if (boolContinue){
            this.ReverseMoveOut(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    ReverseMoveOut : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.ReverseMoveOut");
		var Resident_Id1="";
        var Resident_Id2="";
        if (cmp.get("v.showRes1"))
			if (cmp.get("v.checkedRes1"))
				Resident_Id1=cmp.get("v.ReverseMoveOutFormParams").idResident1;
        if (cmp.get("v.showRes2"))
            if (cmp.get("v.checkedRes2"))
                Resident_Id2=cmp.get("v.ReverseMoveOutFormParams").idResident2;
        action.setParams({
			OppId: cmp.get("v.recordId"),
            Resident1Id: Resident_Id1,
            Resident2Id: Resident_Id2
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
                //$A.get('e.force:refreshView').fire();
            }
		});
		$A.enqueueAction(action);
	},
	
	MoveOut : function(cmp) {
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.MoveOut");
		var PrimaryResidentId;
		var SecondResidentId;
        var sRefund = "";
        if (cmp.get("v.showRebatableRefund"))
            if (cmp.get("v.RebatableRefundParams"))
                if (cmp.get("v.RebatableRefundParams.dblRefundAmount"))
                    sRefund = sRefund + cmp.get("v.RebatableRefundParams.dblRefundAmount");
		if (cmp.get("v.showRes1"))
			if (cmp.get("v.checkedRes1"))
				PrimaryResidentId=cmp.get("v.MoveOutFormParams").idPrimaryResident;
		if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				SecondResidentId=cmp.get("v.MoveOutFormParams").idSecondResident;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            MoveOutType: cmp.get("v.ActionType"),
            strMoveOutDate: cmp.get("v.dtMoveOut"),
            strMoveOutReason: cmp.get("v.strMoveOutReason"),
            idPrimaryResident: PrimaryResidentId,
            idSecondResident: SecondResidentId,
            strRefund: sRefund
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
                //$A.get('e.force:refreshView').fire();
            }
			
		});
		$A.enqueueAction(action);
	},
	
	CancelScheduledMoveOutValidate : function(cmp){
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else boolContinue = true;
        if (boolContinue){
            this.CancelScheduledMoveOut(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
	
	CancelScheduledMoveOut : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.CancelScheduledMoveOut");
		var PrimaryResidentId;
		var SecondResidentId;
		if (cmp.get("v.showRes1"))
			if (cmp.get("v.checkedRes1"))
				PrimaryResidentId=cmp.get("v.CancelScheduledMoveOutFormParams").idPrimaryResident;
		if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				SecondResidentId=cmp.get("v.CancelScheduledMoveOutFormParams").idSecondResident;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            idPrimaryResident: PrimaryResidentId,
            idSecondResident: SecondResidentId
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
            }
			
		});
		$A.enqueueAction(action);
	},
	
	CancelScheduledTransferValidate : function(cmp){
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else boolContinue = true;
        if (boolContinue){
            this.CancelScheduledTransfer(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
	
	CancelScheduledTransfer : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.CancelScheduledTransfer");
		var PrimaryResidentId;
		var SecondResidentId;
		if (cmp.get("v.showRes1"))
			if (cmp.get("v.checkedRes1"))
				PrimaryResidentId=cmp.get("v.CancelScheduledTransferFormParams").idPrimaryResident;
		if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				SecondResidentId=cmp.get("v.CancelScheduledTransferFormParams").idSecondResident;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            idPrimaryResident: PrimaryResidentId,
            idSecondResident: SecondResidentId
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
            }
			
		});
		$A.enqueueAction(action);
	},
    
    TransferValidate : function(cmp){
        var strLevelofCare = cmp.get("v.strLevelofCare");
        var idApartment = cmp.get("v.idApartment");
        var dtTransfer = cmp.get("v.dtTransfer");
        var checkedRes1 = cmp.get("v.checkedRes1");
        var checkedRes2 = cmp.get("v.checkedRes2");
        var boolContinue = false;
        var strError = "";
        if (((strLevelofCare==null)||(strLevelofCare=="")))
            strError = "Level of Care is blank.";
        else if (((idApartment==null)||(idApartment=="")))
            strError = "Apartment is blank.";
        else if (((dtTransfer==null)||(dtTransfer=="")||(dtTransfer==undefined)))
            strError = "Transfer Date is blank.";
        else if (!(checkedRes1||checkedRes2))
        	strError = "Resident is Not checked.";
        else{
            var ActionType = cmp.get("v.ActionType");
            if ((ActionType=="Transfer")){
                var varDate = new Date(dtTransfer);
                var today = new Date();
                if(varDate > today){
                    strError = "Transfer Date is in future.";
                }
                else
                    boolContinue = true;
            }
            else
            	boolContinue = true;
        }
        if (boolContinue){
            this.Transfer(cmp);
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "ERROR",
                "type":"error",
                "message": strError
            });
            console.log("ERROR: " + strError);
            resultsToast.fire();
        }
    },
    
    AddTempSNFStay : function(cmp, occid){
        var lstOccupancy = ((cmp.get("v.lstOccupancy")));
        for (var i = 0; i < lstOccupancy.length; i++){
            var occ = lstOccupancy[i];
            if (occ.Id==occid){
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                 "entityApiName": "Opportunity",
                   'recordTypeId': occ.SNFRecordTypeId,
                 "defaultFieldValues": {
                    'AccountId': occ.ResidentAccountId,
                     'Name': occ.Name,
                      'CloseDate': occ.SNFOppCloseDate,
                     'StageName':'Active',   
                     'Primary_Resident__c': occ.ResidentId,
                     'Housing_Type__c': 'Skilled Nursing',
                     'Community__c': occ.Community
                 }
                });
                createRecordEvent.fire();
            }
            
        }
    },
    
    AddTempRespiteStay : function(cmp, occid){
        var lstOccupancy = ((cmp.get("v.lstOccupancy")));
        for (var i = 0; i < lstOccupancy.length; i++){
            var occ = lstOccupancy[i];
            if (occ.Id==occid){
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                 "entityApiName": "Opportunity",
                   'recordTypeId': occ.RespiteRecordTypeId,
                 "defaultFieldValues": {
                    'AccountId': occ.ResidentAccountId,
                     'Name': occ.Name,
                      'CloseDate': occ.SNFOppCloseDate,
                     'StageName':'Active',   
                     'Primary_Resident__c': occ.ResidentId,
                     'Community__c': occ.Community
                 }
                });
                createRecordEvent.fire();
            }
            
        }
    },
    
    getShowAddCol : function(cmp){
        cmp.set("v.ShowAddCol",false);
        var lstOccupancy = (cmp.get("v.lstOccupancy"));
        if (lstOccupancy)
            for (var i = 0; i < lstOccupancy.length; i++){
                var occ = lstOccupancy[i];
                if (occ.Enable_Add_Temporary_SNF_Stay || occ.Enable_Add_Temporary_Respite_Stay){
                    cmp.set("v.ShowAddCol",true);
                    break;
                }
            }
    },
    
    Transfer : function(cmp){
        cmp.set("v.Spinner", true);
		var action = cmp.get("c.Transfer");
		var PrimaryResidentId;
		var SecondResidentId;
        var sRefund = "";
        var sAddEntranceFee="";
        if (cmp.get("v.showAddEntranceFee"))
            if (cmp.get("v.dblAddEntranceFee"))
                sAddEntranceFee = sAddEntranceFee + cmp.get("v.dblAddEntranceFee");
        if (cmp.get("v.showRebatableRefund"))
            if (cmp.get("v.RebatableRefundParams"))
                if (cmp.get("v.RebatableRefundParams.dblRefundAmount"))
                    sRefund = sRefund + cmp.get("v.RebatableRefundParams.dblRefundAmount");
		if (cmp.get("v.showRes1"))
			if (cmp.get("v.checkedRes1"))
				PrimaryResidentId=cmp.get("v.TransferFormParams").idPrimaryResident;
		if (cmp.get("v.showRes2"))
			if (cmp.get("v.checkedRes2"))
				SecondResidentId=cmp.get("v.TransferFormParams").idSecondResident;
		action.setParams({
			OppId: cmp.get("v.recordId"),
            TransferType: cmp.get("v.ActionType"),
            strTransferDate: cmp.get("v.dtTransfer"),
            strLevelOfCare: cmp.get("v.strLevelofCare"),
            idApartment: cmp.get("v.idApartment"),
            idPrimaryResident: PrimaryResidentId,
            idSecondResident: SecondResidentId,
            strRefund: sRefund,
            strAddEntranceFee : sAddEntranceFee
		});
		action.setCallback(this, function(data){
            var strError = data.getReturnValue();
			cmp.set("v.Spinner", false);
			if (!((strError==null)||(strError==""))){
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					"title": "ERROR",
					"type":"error",
					"message": strError
				});
				console.log("ERROR: " + strError);
				resultsToast.fire();
			}
			else{
                cmp.set("v.ActionType", "");
                this.GetButtonNamesRefresh(cmp);
                //$A.get('e.force:refreshView').fire();
            }
			
		});
		$A.enqueueAction(action);
	}
	
})