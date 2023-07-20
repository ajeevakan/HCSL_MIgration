({
	do_Init : function(component, event, helper) {
		helper.GetButtonNames(component);
	},
    
    do_Refresh : function(component, event, helper) {
		helper.GetButtonNames(component);
        component.set("v.ActionType", "");
        component.set("v.dblAmount", "");
	},
    
    do_Btn : function(component, event, helper) {
		var target = event.getSource().get("v.label");
        if (target=="Move-In"){
            component.set("v.ActionType", "Regular");
            helper.GetMoveInFormParams(component);
        }
//        else if (target=="Move-In with Promissory Note"){
//            component.set("v.ActionType", "Promissory Note Deposit");
//            helper.GetMoveInFormParams(component);
//        }
        else if (target=="Schedule Move-Out"){
            component.set("v.ActionType", "Schedule Move-Out");
            helper.GetMoveOutFormParams(component);
        }
        else if (target=="Move-Out"){
            component.set("v.ActionType", "Move-Out");
            helper.GetMoveOutFormParams(component);
        }
        else if (target=="Schedule Transfer"){
            component.set("v.ActionType", "Schedule Transfer");
            helper.GetTransferFormParams(component);
        }
        else if (target=="Transfer"){
            component.set("v.ActionType", "Transfer");
            helper.GetTransferFormParams(component);
        }
//        else if (target=="Pay Promissory Note in Full"){
//            component.set("v.ActionType", "Pay Promissory Note in Full");
//            helper.GetPNoteFormParams(component);
//        }
        else if (target=="Cancel Scheduled Move Out"){
            component.set("v.ActionType", "Cancel Scheduled Move Out");
            helper.GetCancelScheduledMoveOutFormParams(component);
        }
        else if (target=="Cancel Scheduled Transfer"){
            component.set("v.ActionType", "Cancel Scheduled Transfer");
            helper.GetCancelScheduledTransferFormParams(component);
        }
        else if (target=="Add Missing Resident"){
            component.set("v.ActionType", "Add Missing Resident");
            helper.GetAddSecondResidentFormParams(component);
        }
        else if (target=="Remove Prospect"){
            component.set("v.ActionType", "Remove Prospect");
            helper.GetRemoveProspectFormParams(component);
        }
        else if (target=="Reverse Move-Out"){
            component.set("v.ActionType", "Reverse Move-Out");
            helper.GetReverseMoveOutFormParams(component);
        }
        else if (target=="Cancel Deposit"){
            component.set("v.ActionType", "Cancel Deposit");
            helper.GetCancelDepositFormParams(component);
        }
        else if (target=="Cancel Opportunity"){
            component.set("v.ActionType", "Cancel Opportunity");
            helper.GetCancelDepositFormParams(component);
        }
        else if (target=="Reset/Correct Deposit"){
            component.set("v.ActionType", "Reset/Correct Deposit");
        }
	}
    ,
    do_MoveInCancel : function(component, event, helper) {
        helper.MoveInCancel(component);
	}
    ,
    do_MoveIn : function(component, event, helper) {
        helper.MoveInValidate(component);
	}
    ,
    do_MoveOut : function(component, event, helper) {
        helper.MoveOutValidate(component);
	}
    ,
    do_AddSecondResident : function(component, event, helper) {
        helper.AddSecondResidentValidate(component);
	}
    ,
    do_RemoveProspect : function(component, event, helper) {
        helper.RemoveProspectValidate(component);
	}
    ,
    do_ReverseMoveOut : function(component, event, helper) {
        helper.ReverseMoveOutValidate(component);
	}
    ,
    onChange_LevelofCare : function(component, event, helper) {
        helper.getlstApartment(component);
        //helper.CalcShowRebatableRefund(component);
	}
	,
    onChange_LevelofCareA : function(component, event, helper) {
        helper.getlstApartmentA(component);
        //helper.CalcShowRebatableRefund(component);
	}
	,
    onChange_LevelofCareT : function(component, event, helper) {
        helper.getlstApartmentT(component);
        //helper.CalcShowRebatableRefund(component);
	}
    /*,
    onChange_SetPromissoryNoteDue : function(component, event, helper) {
        helper.SetPromissoryNoteDue(component);
	}*/
    ,
    do_Transfer : function(component, event, helper) {
        helper.TransferValidate(component);
	}
    ,
    do_CancelScheduledTransfer : function(component, event, helper) {
        helper.CancelScheduledTransferValidate(component);
	}
    ,
    do_CancelScheduledMoveOut : function(component, event, helper) {
        helper.CancelScheduledMoveOutValidate(component);
	}
    ,
    do_CancelDeposit : function(component, event, helper) {
        helper.CancelDepositValidate(component,false);
	}
    ,
    do_ResetDeposit : function(component, event, helper) {
        helper.ResetDeposit(component);
	}
    ,
    do_CancelDepositSetAccLost : function(component, event, helper) {
        helper.CancelDepositValidate(component,true);
	}
    ,
    SNFStay : function(component, event, helper){ 
       var occid = event.currentTarget.dataset.id; //event.srcElement.name;
        //console.log("SNF: "+occid);
       helper.AddTempSNFStay(component,occid);
	}
    ,
    RespiteStay : function(component, event, helper){ 
        var occid = event.currentTarget.dataset.id; //event.srcElement.name;
       //console.log("Respite: "+occid);
       helper.AddTempRespiteStay(component,occid);
	}
    /*,
    onChange_CalcShowRebatableRefund : function(component, event, helper) {
        helper.CalcShowRebatableRefund(component);
	}
    ,
    do_PNote : function(component, event, helper) {
        helper.PNoteValidate(component);
	}
    */
})