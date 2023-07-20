({
	myAction : function(component, event, helper) {
      
	},
    
    cancelAccountMerge : function(component, event, helper) {
    //    var acctId = component.get("v.simpleRecord.Account_to_Keep__c");
         var acctId = component.get("v.simpleRecord.Start_from_Opportunity__c");
        component.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                console.log("Record is deleted.");
                // Close the Quick Action
                $A.get("e.force:closeQuickAction").fire();
                // Navigate back to Account to Keep
                var navEvt = $A.get("e.force:navigateToSObject");
    					navEvt.setParams({
      					"recordId": acctId
   						 });
    			navEvt.fire();
                
            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
            }
        }));
            

	}
 
    
})