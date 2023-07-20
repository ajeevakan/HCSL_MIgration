({
    myAction : function(component, event, helper) {
        
        var action = component.get("c.getDupContacts");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            component.set("v.Contacts", data.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
     mergeContact: function (component, event, helper) {
        var idxv = event.getSource().get("v.value")  
        var actionAPI = component.find("quickActionAPI");
         var fields = { Merge_to_Contact__c : {Id: idxv}, Create_New_Opportunity__c : {value: true}};
         var args = { actionName :"Lead.Merge_With_Existing_Contact", entityName: "Lead", targetFields: fields, submitOnSuccess: false }; 
       actionAPI.setActionFieldValues(args).then(function(){
         //   actionAPI.invokeAction(args);
        
        }).catch(function(e) {
            if (e.errors) {
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
            }
    });
    },
    
    mergeOpp: function (component, event, helper) {
        var idxv = event.getSource().get("v.value")  
       // alert(idxv);
        var arrayOfParams = [];
        arrayOfParams = idxv.split(',');
       // alert(arrayOfParams[0]);
      //  alert(arrayOfParams[1]);      
        var actionAPI = component.find("quickActionAPI");
        var fields = { Merge_to_Contact__c : {Id: arrayOfParams[0]}, Add_ReInquiry_to_Opportunity__c : {Id: arrayOfParams[1]}};
        var args = { actionName :"Lead.Merge_With_Existing_Contact", entityName: "Lead", targetFields: fields, submitOnSuccess: false }; 
       actionAPI.setActionFieldValues(args).then(function(){
         //   actionAPI.invokeAction(args);
        
        }).catch(function(e) {
            if (e.errors) {
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
            }
    });
    },
    
     handleMenuSelect: function(component, event, helper) {
    	var selectedMenuItemValue = event.getParam("value");
        var arrayOfParams = selectedMenuItemValue.split(",");
        if (arrayOfParams[2]=="NewConMergeHH"){
            var actionAPI = component.find("quickActionAPI");
            var fields = {  Add_to_Household_of_Opportunity__c : {Id: arrayOfParams[1]}};
            var args = { actionName :"Lead.New_Contact_Opportunity_Existing_Household", entityName: "Lead", targetFields: fields, submitOnSuccess: false }; 
            actionAPI.setActionFieldValues(args).then(function(){
         //   actionAPI.invokeAction(args);
        
           }).catch(function(e) {
               if (e.errors) {
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
               }
          });
           
        }
        else if (arrayOfParams[2]=="NewConMergeOpp"){
            var actionAPI = component.find("quickActionAPI");
            var fields = {  Add_ReInquiry_to_Opportunity__c : {Id: arrayOfParams[1]}};
            var args = { actionName :"Lead.New_Contact_Existing_Opportunity", entityName: "Lead", targetFields: fields, submitOnSuccess: false }; 
            actionAPI.setActionFieldValues(args).then(function(){
         //   actionAPI.invokeAction(args);
        
           }).catch(function(e) {
               if (e.errors) {
                // If the specified action isn't found on the page, 
                // show an error message in the my component 
               }
          });
        }   
	},
    
    goToContact: function (component, event, helper) {
        //   var idxv = event.getSource().get("v.value");  
        var idxv = event.target.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idxv
        });
        navEvt.fire();
    }
    
    
})