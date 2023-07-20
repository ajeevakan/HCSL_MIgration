@RestResource(urlMapping='/webservice')
global without sharing class apexWebservice {
	@HttpPost
    global static String doPost(){
      String submissionString = null;
  
        string strInterfaceName = 'Website';
        String resp;
        RestRequest req = RestContext.request;
        String referral = req.requestBody.toString();
        submissionString = referral;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // Set the recipients of the email
        List<String> toAddresses = new List<String>{ 'manjaka.andriamasinoro@lansdalegroup.com' };
        email.setToAddresses(toAddresses);
        
        // Set the email's subject
        email.setSubject('New CallRail Webhook Notification');
        
        // Set the body of the email
        email.setPlainTextBody(submissionString);
        
        // Send the email
        Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

        resp = 'Complete';
        return resp;
      
    }
}