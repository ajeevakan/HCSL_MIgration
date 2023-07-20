({
	do_init : function(component, event, helper) {
        var action = component.get("c.getDupInfo");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            component.set("v.DupInfo", data.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})