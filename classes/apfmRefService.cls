@RestResource(urlMapping='/apfmReferral')
global without sharing class apfmRefService {
    @HttpPost
    global static String doPost(){
      String submissionString = null;
      try {
        string strInterfaceName = 'APFM';
        String resp;
        RestRequest req = RestContext.request;
        String referral = req.requestBody.toString();
        submissionString = referral;

        if(referral != null) if (referral.trim() != ''){
            TLGJsonInterface.Submit(strInterfaceName, referral);
        }
        resp = 'Complete';
        return resp;
        } catch (Exception e) {
           External_Submission_Error__c ese = new External_Submission_Error__c(Submission__c = submissionString,Error__c = e.getMessage(),Source__c = 'APFM');
           insert ese; return e.getMessage();
        }
    }
}