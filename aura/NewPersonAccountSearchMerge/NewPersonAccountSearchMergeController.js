({
	myAction : function(component, event, helper) {
      
	},
    
    newAccountMerge : function(component, event, helper) {
        var oppId = component.get("v.recordId");
 
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_PA_Contact_Pair__c",
           "defaultFieldValues": {
            'Start_from_Opportunity__c': oppId
         }
         
      });
       
      createRecordEvent.fire();
   //  var dismissActionPanel = $A.get("e.force:closeQuickAction");
   //   dismissActionPanel.fire();   

	}
 
    
})