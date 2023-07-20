({
	myAction : function(component, event, helper) {
      
	},
    
    newAccountMerge : function(component, event, helper) {
    
          var oppId = component.get("v.recordId");
        var householdId = component.get("v.simpleRecord.Primary_Household__c");
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_Account__c",
         "defaultFieldValues": {
             'Start_from_Opportunity__c': oppId,
               'Account_to_Keep__c': householdId
         }
      });
       
      createRecordEvent.fire();
   //  var dismissActionPanel = $A.get("e.force:closeQuickAction");
   //   dismissActionPanel.fire();   

	}
 
    
})