({
	myAction : function(component, event, helper) {
      
	},
    
    newAccountMerge : function(component, event, helper) {
        var oppId = component.get("v.recordId");
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_Opportunity_Pair__c",
           "defaultFieldValues": {
            'Opportunity_to_Keep__c': oppId
         }
         
      });
       
      createRecordEvent.fire();
   //  var dismissActionPanel = $A.get("e.force:closeQuickAction");
   //   dismissActionPanel.fire();   

	}
 
    
})