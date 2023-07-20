({
    myAction : function(component, event, helper) {
        
        var recTypeId = '';
        var Community = '';
        var action = component.get("c.getRecType");
         
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
				console.log('res before setting' + res);
                //var res = data.getReturnValue();
                //component.set("v.strValues",res);
				var fNameAttValue = component.get("v.res.recTypeName");
				
                console.log('res ' + res); 
                
                
				recTypeId = res[1];
				Community = res[0];
				
				console.log('recTypeId ' + recTypeId); 
				console.log('Community ' + Community); 
                
            }

		   var fieldName  = component.get("{!v.recTypeName}");
			
           var createRecordEvent = $A.get("e.force:createRecord");
        
           createRecordEvent.setParams({
             "entityApiName": "Lead",
			  "recordTypeId": recTypeId,  
             "defaultFieldValues": {
                'Community__c' : Community,
                 'Not_Opened_After_Conversion_Yet__c': true,
               // 'Company': 'Computed on Save',
                //'Manual_Entry__c' : true,
                 'Initial_Activity_Type__c': 'Initial Call In',
                 'Initial_Activity_Result_Code__c': 'Completed',
                'AutoConvert__c': true
            }
        
           });
           $A.get("e.force:closeQuickAction").fire();
           createRecordEvent.fire();       
        });
        console.log('Outside setcallback');
        $A.enqueueAction(action);
    }
})