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
    },
    
    goToContact: function (component, event, helper) {
        //   var idxv = event.getSource().get("v.value");  
        var idxv = event.target.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idxv
        });
        navEvt.fire();
    },
    
    mergeHousehold: function (component, event, helper) {
        var idxv = event.getSource().get("v.value")  
       // alert(idxv);
        var arrayOfParams = [];
        arrayOfParams = idxv.split(',');
       // alert(arrayOfParams[0]);
      //  alert(arrayOfParams[1]);  
      ////
        var oppId = component.get("v.recordId");
        var householdId = arrayOfParams[0];
        var householdIdDup = arrayOfParams[1];
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_Account__c",
           "defaultFieldValues": {
            'Start_from_Opportunity__c': oppId,
            'Account_to_Keep__c': householdId,
            'Account_to_Merge__c': householdIdDup
         }
         
      });
       
      createRecordEvent.fire();
      
    },
    
    mergeContact : function(component, event, helper) {
        var idxv = event.getSource().get("v.value")  
       // alert(idxv);
        var arrayOfParams = [];
        arrayOfParams = idxv.split(',');
       // alert(arrayOfParams[0]);
      //  alert(arrayOfParams[1]);  
      ////
        var oppId = component.get("v.recordId");
        var contactId = arrayOfParams[0];
        var contactIdDup = arrayOfParams[1];
        
 
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_PA_Contact_Pair__c",
           "defaultFieldValues": {
            'Start_from_Opportunity__c': oppId,
            'Contact_to_Keep__c': contactId,
            'Contact_to_Merge__c': contactIdDup
         }
         
      });
       
      createRecordEvent.fire();
     

	},
    
    mergeOpp : function(component, event, helper) {
        var idxv = event.getSource().get("v.value")  
       // alert(idxv);
        var arrayOfParams = [];
        arrayOfParams = idxv.split(',');
       // alert(arrayOfParams[0]);
      //  alert(arrayOfParams[1]);  
      ////
        
        var oppId = arrayOfParams[0];
        var oppIdDup = arrayOfParams[1];
	  var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Search_Merge_Duplicate_Opportunity_Pair__c",
           "defaultFieldValues": {
            'Opportunity_to_Keep__c': oppId,
            'Opportunity_to_Merge__c': oppIdDup
         }
         
      });
       
      createRecordEvent.fire();
   
	}
})