// POST for message and GET for community
@RestResource(urlMapping='/Navihealth/*')
global with sharing class NavihealthApi {
	@httpPost
    global static Integer setMessage(String leadId, String hl7Body, Integer status, String response) {
        Message__c message = new Message__c();
        message.Source__c = 'Navihealth';
        
        // Find the newly created lead
        if (String.isNotBlank(leadId)){
            Lead lead = [SELECT Id FROM Lead WHERE Id=:leadId];
            if (lead != null)
                message.Lead__c = lead.Id;
        }
   		
        if (String.isNotBlank(hl7Body))
			message.Body_XML__c = hl7Body;
        
        if (status == 200 || status == 204){
            message.Success__c = true;
        } else {
            message.Success__c = false;
        }
        
        message.Response__c = response;
        
        try {
            insert message;
            return 200;
        } catch (DmlException e){
            System.debug(e.getMessage());
            return 400;
        }
    }
    
    @httpGet
    global static String getCommunityName(){
        RestRequest req = RestContext.request;
        String externalId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        list<community__c> comms = [SELECT Id, Name FROM Community__c WHERE Navihealth_Id__c=:externalId];
        if (comms.size() > 0)
            return comms[0].Name;
        else
        	return '';
    }
}