// POST for message and GET for community
@RestResource(urlMapping='/Allscripts/*')
global with sharing class AllscriptsApi {
	@httpPost
    global static Integer setMessage(String leadId, String xmlBody, Integer status, String response) {
        Message__c message = new Message__c();
        
        // Find the newly created lead
        if (String.isNotBlank(leadId)){
            Lead lead = [SELECT Id FROM Lead WHERE Id=:leadId];
            if (lead != null)
                message.Lead__c = lead.Id;
        }
   		
        if (String.isNotBlank(xmlBody))
            // Remove SSN from payload
        	message.Body_XML__c = AllscriptsApi.removeLabResults(xmlBody);
			//message.Body_XML__c = xmlBody;
        
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
    
    private static String removeLabResults(String xml){
        return xml.replaceAll('(?<=LabResults>)([\\s\\S]*?)(?=</ns0:LabResults)', '');
    }
    
    @httpGet
    global static String getCommunityName(){
        RestRequest req = RestContext.request;
        String externalId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Community__c community = [SELECT Id, Name FROM Community__c WHERE Allscripts_Id__c=:externalId];
        if (community != null)
            return community.Name;
        else
        	return '';
    }
}