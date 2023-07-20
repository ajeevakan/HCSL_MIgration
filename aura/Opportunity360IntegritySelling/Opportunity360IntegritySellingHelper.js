({
	callMakePrimaryContact: function(component, idOCR) {
        component.set("v.Spinner", true);
		var action = component.get("c.MakePrimaryContact");
        action.setParams({
           OCRId: idOCR
        });
        action.setCallback(this, function(data) {
           var strError = data.getReturnValue();
			component.set("v.Spinner", false);
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
                $A.get("e.force:refreshView").fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    callMakePrimaryResident: function(component, idOCR) {
        component.set("v.Spinner", true);
		var action = component.get("c.MakePrimaryResident");
        action.setParams({
           OCRId: idOCR
        });
        action.setCallback(this, function(data) {
           var strError = data.getReturnValue();
			component.set("v.Spinner", false);
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
                $A.get("e.force:refreshView").fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    callMakeSecondResident: function(component, idOCR) {
        component.set("v.Spinner", true);
		var action = component.get("c.MakeSecondResident");
        action.setParams({
           OCRId: idOCR
        });
        action.setCallback(this, function(data) {
           var strError = data.getReturnValue();
			component.set("v.Spinner", false);
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
                $A.get("e.force:refreshView").fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    callDemoteSecondResident: function(component, idOCR) {
        component.set("v.Spinner", true);
		var action = component.get("c.DemoteSecondResident");
        action.setParams({
           OCRId: idOCR
        });
        action.setCallback(this, function(data) {
           var strError = data.getReturnValue();
			component.set("v.Spinner", false);
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
                $A.get("e.force:refreshView").fire();
            }
        });  
        $A.enqueueAction(action);
    },

  
    
    callSetContactInactive: function(component, id_Contact, bool_Inactive, bool_Deceased, update_Deceased) {
        component.set("v.Spinner", true);
		var action = component.get("c.SetContactInactive");
        action.setParams({
           idContact: id_Contact,
           boolInactive: bool_Inactive,
           boolDeceased: bool_Deceased,
           updateDeceased: update_Deceased
        });
        action.setCallback(this, function(data) {
           var strError = data.getReturnValue();
			component.set("v.Spinner", false);
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
                $A.get("e.force:refreshView").fire();
            }
        });  
        $A.enqueueAction(action);
    },
})