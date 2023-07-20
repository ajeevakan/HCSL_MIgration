({
	myAction : function(component, event, helper) {
        
     
		var action = component.get("c.getContacts");
        action.setParams({
           recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
           component.set("v.Contacts", data.getReturnValue());
        });
      
        
      
        var action2 = component.get("c.getActivities");
        action2.setParams({
           recordId: component.get("v.recordId")
        });
        action2.setCallback(this, function(data) {
           component.set("v.ActivityList", data.getReturnValue());
        });
        
    //     var action3 = component.get("c.getTask");
    //    action3.setParams({
    //       recordId: component.get("v.recordId")
    //    });
   //     action3.setCallback(this, function(data) {
    //       component.set("v.activity", data.getReturnValue());
    //    });
        
        
         var action4 = component.get("c.getOpp");
        action4.setParams({
           recordId: component.get("v.recordId")
        });
        action4.setCallback(this, function(data) {
           component.set("v.opportunity", data.getReturnValue());
        });
        
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
 // $A.enqueueAction(action3);
        $A.enqueueAction(action4);
	},
    // NOTE THE COMMA ABOVE BETWEEN FUNCTION DEFINITIONS
    newOppTask: function(component, event, helper) {
      var idxv = event.getSource().get("v.value")  
      var createRecordEvent = $A.get("e.force:createRecord");
      var todayvar = new Date();  
        var day = todayvar.getDate();
  var monthIndex = todayvar.getMonth()+1;
  var year = todayvar.getFullYear();
var today = year +'-' + monthIndex  + '-' + day;
      createRecordEvent.setParams({
         "entityApiName": "Task",
         "defaultFieldValues": {
            'WhatId' : component.get("v.opportunity.Id"),
             'WhoId' : idxv,
             'ActivityDate': today
         },
          "navigationLocation":"LOOKUP"
        
      });
      createRecordEvent.fire(); 
    },
    
      newOppEvent: function(component, event, helper) {
      var idxv = event.getSource().get("v.value")  
      var createRecordEvent = $A.get("e.force:createRecord");
          
    //   var windowRedirect = window.location.href; // Current Page URL 
      createRecordEvent.setParams({
         "entityApiName": "Event",
         "defaultFieldValues": {
            'WhatId' : component.get("v.opportunity.Id"),
             'WhoId' : idxv
         },
          "navigationLocation":"LOOKUP"
          
          //,
   // "panelOnDestroyCallback": function(event) {
   //     window.location.href = windowRedirect; // Return to the page where the record was created
  //  }
        
      });
      createRecordEvent.fire(); 
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
    
     editContact: function (component, event, helper) {
        var idxv = event.getSource().get("v.value");  
     //   var idxv = event.target.id;
        var navEvt = $A.get("e.force:editRecord");
        navEvt.setParams({
            "recordId": idxv
        });
        navEvt.fire();
    },
    
    goToOpp: function (component, event, helper) {
        var idxv = event.getSource().get("v.value");  
      //  var idxv = event.target.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idxv
        });
        navEvt.fire();
    },
    
     editOpp: function (component, event, helper) {
        var idxv = event.getSource().get("v.value");  
     //   var idxv = event.target.id;
        var navEvt = $A.get("e.force:editRecord");
        navEvt.setParams({
            "recordId": idxv
        });
        navEvt.fire();
    },
    
     newContact: function(component, event, helper) {
      var createRecordEvent = $A.get("e.force:createRecord");
      createRecordEvent.setParams({
         "entityApiName": "Contact",
        // "recordTypeId": '012360000008KtFAAU',
         "defaultFieldValues": {
            'AccountId' : component.get("v.opportunity.AccountId")
         },
          "navigationLocation":"LOOKUP"
        
      });
      createRecordEvent.fire(); 
    },
    
 
   
})