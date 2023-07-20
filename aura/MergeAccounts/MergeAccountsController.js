({
	initAction : function(component, event, helper) {
        
	},
    
    CompleteAction : function(component, event, helper) {
   
            var action = component.get("c.MergeAccounts");
            action.setParams({
                SearchMergeId: component.get("v.recordId") 
            });
            action.setCallback(this, function(data) {
                var state = data.getState();
                if(state === "SUCCESS") {
                    var strMsg = data.getReturnValue();
                    if (strMsg==""){
                        $A.get("e.force:closeQuickAction").fire();
                        // Navigate back to Account to Keep
                        var navEvt = $A.get("e.force:navigateToSObject");
    					navEvt.setParams({
      					"recordId": component.get("v.simpleRecord.Account_to_Keep__c")
   						 });
    					navEvt.fire();
                        
                       // $A.get('e.force:refreshView').fire();
                    }
                    else{ 
                        console.log('ERROR: ' + strMsg);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                        "title": "ERROR",
                        "message": strMsg
                        });
                        toastEvent.fire();    	
                    }
                }
                else if (state === "ERROR") {
                    var errors = data.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                component.set("v.Spinner", false);
            });
            component.set("v.Spinner", true);
            $A.enqueueAction(action);
        
	},
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})