({
	myAction : function(component, event, helper) {
        
        var community = '';
        var action = component.get("c.getCommunity");
        action.setCallback(this, function(data) {
           community = data.getReturnValue();

           var createRecordEvent = $A.get("e.force:createRecord");
        
           createRecordEvent.setParams({
             "entityApiName": "Lead",
             "defaultFieldValues": {
                'Community__c' : community,
                 'Not_Opened_After_Conversion_Yet__c': true,
               // 'Company': 'Computed on Save',
                //'Manual_Entry__c' : true,
                'AutoConvert__c': true
            }
        
           });
           $A.get("e.force:closeQuickAction").fire();
           createRecordEvent.fire();       
        });
        $A.enqueueAction(action);    
  
	
	}
    
    
})