({
	myAction : function(component, event, helper) {
		var action = component.get("c.getOpportunity");
        action.setParams({
           recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
           component.set("v.oppId", data.getReturnValue());
            var opportunityId = component.get("v.oppId");
       // alert(opportunityId);
            if (opportunityId != null)   {
         var navEvent = $A.get("e.force:navigateToSObject");  
         navEvent.setParams({
        "recordId": opportunityId,   
        "slideDevName": "detail"
    });
                navEvent.fire();  }   
            
        });
        
         $A.enqueueAction(action);
        
	}
})