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
				//var fNameAttValue = component.get("v.res.recTypeName");
				
                console.log('res ' + res); 
				
				
				//console.log('recTypeId ' + res[1]); 
				//console.log('Community ' + res[0]); 
				//component.set("v.Community",res[0]);
                Community = res[0];
				recTypeId = res[1];	
             //   alert(Community+recTypeId);
				
            }
			//console.log('After the block'); 
		//	var fieldName  = component.get("{!v.recTypeName}");
		
           var createRecordEvent = $A.get("e.force:createRecord");
        
           createRecordEvent.setParams({
			   
             "entityApiName": "Lead",
                "recordTypeId": recTypeId,  
             "defaultFieldValues": {
                'Community__c' : Community,
               'Not_Opened_After_Conversion_Yet__c': true,
               'Relationship_to_Prospect__c': 'Self',
               // 'Company': 'Computed on Save',
                //'Manual_Entry__c' : true,
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