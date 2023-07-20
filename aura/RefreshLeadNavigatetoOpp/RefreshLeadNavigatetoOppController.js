({
  recordUpdated : function(component, event, helper) {

    var changeType = event.getParams().changeType;

    if (changeType === "ERROR") { /* handle error; do this first! */ }
    else if (changeType === "LOADED") { /* handle record load */ }
    else if (changeType === "REMOVED") { /* handle record removal */ }
    else if (changeType === "CHANGED") { 
      /* handle record change; reloadRecord will cause you to lose your current record, including any changes you’ve made */ 
    
    
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
      
      
    }
})