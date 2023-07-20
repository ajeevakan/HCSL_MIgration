@isTest
private class TLGJsonInterfaceTest {

    @isTest
    static void Test001() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
        string strInterfaceName = 'APFM_Test';
//        TLG_Json_Interface__mdt Interfacemdt = new TLG_Json_Interface__mdt(DeveloperName=strInterfaceName,MasterLabel=strInterfaceName,Target_Object__c='Lead');
//        insert Interfacemdt;
//        TLG_Json_Interface_Mapping__mdt Mappingmdt01 = new TLG_Json_Interface_Mapping__mdt(DeveloperName=strInterfaceName+' PartnerPropertyId',MasterLabel=strInterfaceName+' PartnerPropertyId', Json_Interface_Name__c=strInterfaceName);
//        Mappingmdt01.Source_Field__c='PartnerPropertyId';
//        Mappingmdt01.Target_Field__c='Community__c';
//        Mappingmdt01.Translation_Object__c='Community__c';
//        Mappingmdt01.Translation_Value_Field__c='Name';
//        Mappingmdt01.Trnaslation_Match_Field__c='PartnerPropertyId__c';
//        insert Mappingmdt01;
        Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='YorkPlace');
        insert oCommunity; 
        string strJson = '{"SourceFilter":"apfm","LeadId":1,"PartnerPropertyId":"YorkPlace",'+
                  '"ApfmPropertyId":139887,"InquiryDate":"2017-08-03T00:00:00",'+
                  '"InquiryMethod":null,"PropertyName":"YorkPlace",'+
                  '"PropertyPostalRegion":"CO","ReferralType":1,"DesiredZip":"76180",'+
                  '"ReferralDate":"2017-08-03T00:00:00",'+
                  '"ReferralDateTime":"2017-08-03T10:05:30",'+
                  '"AdvisorFirstName":"Rita","AdvisorLastName":"Madrid","AdvisorFax":"null",'+
                  '"AdvisorEmail":"ritam_test@aplaceformom.com","AdvisorReferralNote":"Oliviawouldlikemoreinfo...",'+
                  '"AdvisorTollFree":"5553332268","AdvisorWorkPhone":null,"TourDate":null,"TourDateAlternative":null,'+
                  '"PrimaryContactFirstName":"nancy1","PrimaryContactLastName":"hurley1",'+
                  '"PrimaryContactAddress1":"12334thStreet","PrimaryContactCity":"Portland",'+
                  '"PrimaryContactState":"","PrimaryContactPostalCode":"","PrimaryContactCountry":"US",'+
                  '"PrimaryContactEmail":"nh1@thisistest.org","PrimaryContactHomePhone":"5551231001",'+
                  '"PrimaryContactCellPhone":null,"PrimaryContactWorkPhone":null,"PrimaryContactFaxPhone":null,'+
                  '"PrimaryContactResidentRelationshipId":32,"PrimaryContactResidentRelationship":"Cousin",'+
                  '"ResidentContactFirstName":"ben1","ResidentContactLastName":"hurley1",'+
                  '"ResidentContactAddress1":"3002ndStreetN","ResidentContactCity":null,"ResidentContactState":null,'+
                  '"ResidentContactPostalCode":"","ResidentContactCountry":"US","ResidentContactEmail":"",'+
                  '"ResidentContactHomePhone":null,"ResidentContactCellPhone":"555123100",'+
                  '"ResidentContactWorkPhone":null,"ResidentContactFaxPhone":"55154443335","ProfileAge":70,'+
                  '"ProfileActivityPreferences":null,"ProfileAssistanceBathing":false,'+
                  '"ProfileAssistanceToileting":false,"ProfileAssistanceToiletingFollowup":null,'+
                  '"ProfileBathroomReminderNeeded":null,"ProfileBathroomPhysicalDifficulties":null,'+
                  '"ProfileDisability":null,"ProfileIncontinenceTypeBladder":null,"ProfileIncontinenceTypeBowel":null,'+
                  '"ProfileMedicalHistory":null,"ProfileMedicalDiagnoses":null,"ProfileMedication":null,'+
                  '"ProfileOtherAccommodations":null,"ProfileOtherAssistance":null,"ProfileOtherLivingSituation":null,'+
                  '"ProfileOtherPreferences":null,"ProfileReasonsForSearch":null,"ProfileSleepingHabits":null,'+
                  '"ProfileSpecialCare":null,"ProfileVeteran":false,"ProfileTimeframeId":null,'+
                  '"ProfileTimeframe":null,"ProfileWheelchairAssistanceId":null,"ProfileWheelchairAssistance":null,'+
                  '"ProfileWheelchairMoveFrom":null,"ProfileWheelchairSelfPropel":null,"ProfileTakingMedicationId":3,'+
                  '"ProfileTakingMedication":"Yes-theyneedhelptakingtheirmedications",'+
                  '"ProfileMaritalStatusCode":"M","ProfileMaritalStatus":"Married","ProfileLivingSituationId":41,'+
                  '"ProfileLivingSituation":"Home (with services)","ProfileMemoryLossId":49,"ProfileMemoryLoss":false,'+
                  '"ProfileMemoryDiagnosisId":null,"ProfileMemoryDiagnosis":null,"ProfileMemoryCombativeId":null,'+
                  '"ProfileMemoryCombative":null,"ProfileBudgetId":7,"ProfileBudget":"$3;000-$3;999",'+
                  '"ProfileGenderCode":"F","ProfileGender":"Female","ProfileAmbulationId":12,'+
                  '"ProfileAmbulation":"Independent","ProfileDiabeticCareNeedsId":33,"ProfileDiabeticCareNeeds":"NotDiabetic",'+
                  '"ProfileFundingTypeId":3,"ProfileFundingType":"Private","ProfileLengthCareNeededId":null,"ProfileLengthCareNeeded":null,'+
                  '"ProfileAlternateFundingTypes":["Familywillingtocontribute"]}';
    Test.startTest();
    TLGJsonInterface.Submit( strInterfaceName,  strJson);
    Test.stopTest();
        for (lead ld : [SELECT Id, Name, FirstName, LastName, Community__c,  AnnualRevenue, Inquiry_Date__c, Email FROM Lead]){
          system.debug(ld);
        }
      TLGJsonInterface.Submit( strInterfaceName,  strJson);
    }
    
    /*@isTest
    static void apfmRefServiceTest1() 
     {
      string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      // create test data here
      RestRequest req = new RestRequest();
      RestResponse res = new RestResponse();
      String pyLoad = '{"SourceFilter":"apfm","LeadId":1,"PartnerPropertyId":"YorkPlace",'+
                  '"ApfmPropertyId":139887,"InquiryDate":"2017-08-03T00:00:00",'+
                  '"InquiryMethod":null,"PropertyName":"YorkPlace",'+
                  '"PropertyPostalRegion":"CO","ReferralType":1,"DesiredZip":"76180",'+
                  '"ReferralDate":"2017-08-03T00:00:00",'+
                  '"ReferralDateTime":"2017-08-03T10:05:30",'+
                  '"AdvisorFirstName":"Rita","AdvisorLastName":"Madrid","AdvisorFax":"null",'+
                  '"AdvisorEmail":"ritam_test@aplaceformom.com","AdvisorReferralNote":"Oliviawouldlikemoreinfo...",'+
                  '"AdvisorTollFree":"5553332268","AdvisorWorkPhone":null,"TourDate":null,"TourDateAlternative":null,'+
                  '"PrimaryContactFirstName":"nancy1","PrimaryContactLastName":"hurley1",'+
                  '"PrimaryContactAddress1":"12334thStreet","PrimaryContactCity":"Portland",'+
                  '"PrimaryContactState":"","PrimaryContactPostalCode":"","PrimaryContactCountry":"US",'+
                  '"PrimaryContactEmail":"nh1@thisistest.org","PrimaryContactHomePhone":"5551231001",'+
                  '"PrimaryContactCellPhone":null,"PrimaryContactWorkPhone":null,"PrimaryContactFaxPhone":null,'+
                  '"PrimaryContactResidentRelationshipId":32,"PrimaryContactResidentRelationship":"Cousin",'+
                  '"ResidentContactFirstName":"ben1","ResidentContactLastName":"hurley1",'+
                  '"ResidentContactAddress1":"3002ndStreetN","ResidentContactCity":null,"ResidentContactState":null,'+
                  '"ResidentContactPostalCode":"","ResidentContactCountry":"US","ResidentContactEmail":"",'+
                  '"ResidentContactHomePhone":null,"ResidentContactCellPhone":"555123100",'+
                  '"ResidentContactWorkPhone":null,"ResidentContactFaxPhone":"55154443335","ProfileAge":70,'+
                  '"ProfileActivityPreferences":null,"ProfileAssistanceBathing":false,'+
                  '"ProfileAssistanceToileting":false,"ProfileAssistanceToiletingFollowup":null,'+
                  '"ProfileBathroomReminderNeeded":null,"ProfileBathroomPhysicalDifficulties":null,'+
                  '"ProfileDisability":null,"ProfileIncontinenceTypeBladder":null,"ProfileIncontinenceTypeBowel":null,'+
                  '"ProfileMedicalHistory":null,"ProfileMedicalDiagnoses":null,"ProfileMedication":null,'+
                  '"ProfileOtherAccommodations":null,"ProfileOtherAssistance":null,"ProfileOtherLivingSituation":null,'+
                  '"ProfileOtherPreferences":null,"ProfileReasonsForSearch":null,"ProfileSleepingHabits":null,'+
                  '"ProfileSpecialCare":null,"ProfileVeteran":false,"ProfileTimeframeId":null,'+
                  '"ProfileTimeframe":null,"ProfileWheelchairAssistanceId":null,"ProfileWheelchairAssistance":null,'+
                  '"ProfileWheelchairMoveFrom":null,"ProfileWheelchairSelfPropel":null,"ProfileTakingMedicationId":3,'+
                  '"ProfileTakingMedication":"Yes-theyneedhelptakingtheirmedications",'+
                  '"ProfileMaritalStatusCode":"M","ProfileMaritalStatus":"Married","ProfileLivingSituationId":41,'+
                  '"ProfileLivingSituation":"Home (with services)","ProfileMemoryLossId":49,"ProfileMemoryLoss":false,'+
                  '"ProfileMemoryDiagnosisId":null,"ProfileMemoryDiagnosis":null,"ProfileMemoryCombativeId":null,'+
                  '"ProfileMemoryCombative":null,"ProfileBudgetId":7,"ProfileBudget":"$3;000-$3;999",'+
                  '"ProfileGenderCode":"F","ProfileGender":"Female","ProfileAmbulationId":12,'+
                  '"ProfileAmbulation":"Independent","ProfileDiabeticCareNeedsId":33,"ProfileDiabeticCareNeeds":"NotDiabetic",'+
                  '"ProfileFundingTypeId":3,"ProfileFundingType":"Private","ProfileLengthCareNeededId":null,"ProfileLengthCareNeeded":null,'+
                  '"ProfileAlternateFundingTypes":["Familywillingtocontribute"]}';
      req.requestURI = '/services/apexrest/apfmReferral/';  //Request URL
      req.httpMethod = 'POST';
      req.requestBody = Blob.valueof(pyLoad);
      RestContext.request = req;
      RestContext.response= res;
      String resp = apfmRefService.doPost();
     }*/
     
     @isTest
    static void Test002() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
        string strInterfaceName = 'APFM_Test';
//        TLG_Json_Interface__mdt Interfacemdt = new TLG_Json_Interface__mdt(DeveloperName=strInterfaceName,MasterLabel=strInterfaceName,Target_Object__c='Lead');
//        insert Interfacemdt;
//        TLG_Json_Interface_Mapping__mdt Mappingmdt01 = new TLG_Json_Interface_Mapping__mdt(DeveloperName=strInterfaceName+' PartnerPropertyId',MasterLabel=strInterfaceName+' PartnerPropertyId', Json_Interface_Name__c=strInterfaceName);
//        Mappingmdt01.Source_Field__c='PartnerPropertyId';
//        Mappingmdt01.Target_Field__c='Community__c';
//        Mappingmdt01.Translation_Object__c='Community__c';
//        Mappingmdt01.Translation_Value_Field__c='Name';
//        Mappingmdt01.Trnaslation_Match_Field__c='PartnerPropertyId__c';
//        insert Mappingmdt01;
        Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='YorkPlace');
        insert oCommunity; 
        
        string strJson = '{"SourceFilter":"apfm","LeadId":1,"PartnerPropertyId":"YorkPlace",'+
                  '"ApfmPropertyId":139887,"InquiryDate":"2017-08-03T00:00:00",'+
                  '"InquiryMethod":null,"PropertyName":"YorkPlace",'+
                  '"PropertyPostalRegion":"CO","ReferralType":1,"DesiredZip":"76180",'+
                  '"ReferralDate":"2017-08-03T00:00:00",'+
                  '"ReferralDateTime":"2017-08-03T10:05:30",'+
                  '"AdvisorFirstName":"Rita","AdvisorLastName":"Madrid","AdvisorFax":"null",'+
                  '"AdvisorEmail":"ritam_test@aplaceformom.com","AdvisorReferralNote":"Oliviawouldlikemoreinfo...",'+
                  '"AdvisorTollFree":"5553332268","AdvisorWorkPhone":null,"TourDate":null,"TourDateAlternative":null,'+
                  '"PrimaryContactFirstName":"nancy1","PrimaryContactLastName":"hurley1",'+
                  '"PrimaryContactAddress1":"12334thStreet","PrimaryContactCity":"Portland",'+
                  '"PrimaryContactState":"","PrimaryContactPostalCode":"","PrimaryContactCountry":"US",'+
                  '"PrimaryContactEmail":"nh1@thisistest.org","PrimaryContactHomePhone":"5551231001",'+
                  '"PrimaryContactCellPhone":null,"PrimaryContactWorkPhone":null,"PrimaryContactFaxPhone":null,'+
                  '"PrimaryContactResidentRelationshipId":32,"PrimaryContactResidentRelationship":"Cousin",'+
                  '"ResidentContactFirstName":"ben1","ResidentContactLastName":"hurley1",'+
                  '"ResidentContactAddress1":"3002ndStreetN","ResidentContactCity":null,"ResidentContactState":null,'+
                  '"ResidentContactPostalCode":"","ResidentContactCountry":"US","ResidentContactEmail":"",'+
                  '"ResidentContactHomePhone":null,"ResidentContactCellPhone":"555123100",'+
                  '"ResidentContactWorkPhone":null,"ResidentContactFaxPhone":"55154443335","ProfileAge":70,'+
                  '"ProfileActivityPreferences":null,"ProfileAssistanceBathing":false,'+
                  '"ProfileAssistanceToileting":false,"ProfileAssistanceToiletingFollowup":null,'+
                  '"ProfileBathroomReminderNeeded":null,"ProfileBathroomPhysicalDifficulties":null,'+
                  '"ProfileDisability":null,"ProfileIncontinenceTypeBladder":null,"ProfileIncontinenceTypeBowel":null,'+
                  '"ProfileMedicalHistory":null,"ProfileMedicalDiagnoses":null,"ProfileMedication":null,'+
                  '"ProfileOtherAccommodations":null,"ProfileOtherAssistance":null,"ProfileOtherLivingSituation":null,'+
                  '"ProfileOtherPreferences":null,"ProfileReasonsForSearch":null,"ProfileSleepingHabits":null,'+
                  '"ProfileSpecialCare":null,"ProfileVeteran":false,"ProfileTimeframeId":null,'+
                  '"ProfileTimeframe":null,"ProfileWheelchairAssistanceId":null,"ProfileWheelchairAssistance":null,'+
                  '"ProfileWheelchairMoveFrom":null,"ProfileWheelchairSelfPropel":null,"ProfileTakingMedicationId":3,'+
                  '"ProfileTakingMedication":"Yes-theyneedhelptakingtheirmedications",'+
                  '"ProfileMaritalStatusCode":"M","ProfileMaritalStatus":"Married","ProfileLivingSituationId":41,'+
                  '"ProfileLivingSituation":"Home (with services)","ProfileMemoryLossId":49,"ProfileMemoryLoss":false,'+
                  '"ProfileMemoryDiagnosisId":null,"ProfileMemoryDiagnosis":null,"ProfileMemoryCombativeId":null,'+
                  '"ProfileMemoryCombative":null,"ProfileBudgetId":7,"ProfileBudget":"$3;000-$3;999",'+
                  '"ProfileGenderCode":"F","ProfileGender":"Female","ProfileAmbulationId":12,'+
                  '"ProfileAmbulation":"Independent","ProfileDiabeticCareNeedsId":33,"ProfileDiabeticCareNeeds":"NotDiabetic",'+
                  '"ProfileFundingTypeId":3,"ProfileFundingType":"Private","ProfileLengthCareNeededId":null,"ProfileLengthCareNeeded":null,'+
                  '"ProfileAlternateFundingTypes":["Familywillingtocontribute"]}';
    
    TLGJsonInterface.Submit( strInterfaceName,  strJson);
    
    TLG_Integration_Submission__c tlg = new TLG_Integration_Submission__c();
    tlg.Processed__c = true;
    tlg.Interface_Name__c = 'test';
    tlg.json__c = strJson;
    insert tlg;
    
    Id SubId = null;
    for (TLG_Integration_Submission__c sub : [SELECT Id, Interface_Name__c, json__c, Processed__c, Error__c, Error_Description__c, RecordId__c FROM TLG_Integration_Submission__c WHERE (Processed__c = true) LIMIT 1]){
        SubId = sub.Id;
        sub.Processed__c=false;
        update sub;
    }
    Test.startTest();
    TLGJsonInterface.ReSubmit( SubId);
    Test.stopTest();
    }
    
    /*@isTest
    static void Test001Caring() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        Lead objLead = new Lead(Community__c=strCOMM1,Email='useR@example.com',Phone='415-555-1212 X762',FirstName='Izzy',LastName='Inquirer',Inquiry_Date__c=date.today(),Company='Computed on Convert');
        insert objLead;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "'+'DFW123'+'", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
        //map<string,string> resp = caringRefService.doPost();
         Test.stopTest();
        //system.debug(resp);
    }*/
    
   /* @isTest
    static void Test001CaringB() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        Lead objLead = new Lead(Community__c=strCOMM1,Email='useR1@example.com',Phone='415-555-1212 X762',FirstName='Izzy',LastName='Inquirer',Inquiry_Date__c=date.today(),Company='Computed on Convert');
        insert objLead;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "'+'DFW123'+'", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
        //map<string,string> resp = caringRefService.doPost();
         Test.stopTest();
        //system.debug(resp);
    }*/
    
   @isTest
    static void Test002Caring() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "DFW123", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
        //map<string,string> resp = caringRefService.doPost();
         Test.stopTest();
        //system.debug(resp);
    }
    
    @isTest
    static void Test002Caring_B() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "DFW123", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req1.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req1.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        req1.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
         Test.startTest();
        //map<string,string> resp = caringRefService.doPost();
         Test.stopTest();
        RestContext.request = req1;
        RestContext.response= res1;
        //map<string,string> resp1 = caringRefService.doPost();
        //system.debug(resp1);
    }
    
    @isTest
    static void Test003Caring() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "DFW123", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
        string strJsonUpdate = '{ "lead_id": "67899", "tour_date": "10/31/2019", "tour_time": "14:00:00","notes":"test notes","xyz":"xyz","note":"test note" }';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
        //map<string,string> resp = caringRefService.doPost();
         Test.startTest();
        RestRequest requ = new RestRequest();
        RestResponse resu = new RestResponse();
        requ.requestURI = '/services/apexrest/caringReferralUpdate/';  //Request URL
        requ.httpMethod = 'POST';
        requ.requestBody = Blob.valueof(strJsonUpdate);
        RestContext.request = requ;
        RestContext.response= resu;
        //map<string,string> respu = caringUpdateRefService.doPost();
         Test.stopTest();
        //system.debug(respu);
    }
    
   /* @isTest
    static void Test001Batch() 
    {
        Id curuserid = UserInfo.getUserId();
        string strCommName = null;
        for (User objUser : [select id, name, ProfileId, userroleid, userrole.name from user where Id = :curuserid])
            strCommName = objUser.userrole.name;
        //Account acc = new Account(Sales_Status__c='Committed (Deposit)', Unique_Caring_Lead_Id__c='1234', Community__c=strCommName);
        Account acc = new Account( Unique_Caring_Lead_Id__c='1234', Community__c=strCommName);
        acc.Name = 'Test Account';
        insert acc;
        List<Task> lstTask = new List<Task>();
        
        Contact c = new Contact();
        c.LastName = 'Test';
        c.AccountId = acc.Id;
        insert c;
        
        Campaign camp = new Campaign();
        camp.IsActive = true;
        camp.Name = 'Test';
        insert camp;
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = c.Id;
        cm.CampaignId = camp.Id;
        insert cm;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Move In';
      
        insert opp;
        SchedulableContext SC = null;
        (new BatchCaringUpdate()).execute(SC);
    }*/
    
    /*@isTest
    static void Test005Caring() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123',Primary_User_for_Community__c=userinfo.getuserId());
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "DFW123", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
        string strJsonUpdate = '{ "lead_id": "67899", "tour_date": "10/31/2019", "tour_time": "14:00:00","notes":"test notes","xyz":"xyz","note":"test note" }';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
        //map<string,string> resp = caringRefService.doPost();
        Id LeadId=null;
        for (Lead ld : [SELECT Id, OwnerId, Reassign_To__c,AutoConvert__c, owner.name FROM Lead]){
            system.debug(ld.owner.name+':'+ld.ownerid);
            //ld.OwnerId = userinfo.getUserId();
            LeadId=ld.Id;
            ld.Reassign_To__c=userinfo.getUserId();
            ld.AutoConvert__c=true;
            system.debug(ld.owner.name+':'+ld.ownerid);
            update ld;
        }
        //for (Lead ld : [SELECT Id, OwnerId, Reassign_To__c, owner.name FROM Lead])
        //    system.debug(ld.owner.name+':'+ld.ownerid);
        
        ///
        Database.LeadConvert[] leadsToConvert = new Database.LeadConvert[1];
          integer i = 0;
          for (i = 0; i < 1; ++i) {
             {
                leadsToConvert[i] = new Database.LeadConvert();
                leadsToConvert[i].setConvertedStatus('Qualified');
                //leadsToConvert[i].setDoNotCreateOpportunity(True);
                leadsToConvert[i].setLeadId(LeadId);
             }
          }
//          List<Database.LeadConvertResult> lcResults = Database.convertLead(leadsToConvert);
          integer j = 0;
        ///
        Test.startTest(); 
        RestRequest requ = new RestRequest();
        RestResponse resu = new RestResponse();
        requ.requestURI = '/services/apexrest/caringReferralUpdate/';  //Request URL
        requ.httpMethod = 'POST';
        requ.requestBody = Blob.valueof(strJsonUpdate);
        RestContext.request = requ;
        RestContext.response= resu;
        //map<string,string> respu = caringUpdateRefService.doPost();
         Test.stopTest();
        //system.debug(respu);
    }*/
    
    /*@isTest
    static void Test005CaringB() {
        string strCOMM1 = '';
        string strCOMM2 = '';
        integer icountt=0;
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()){
            icountt++;
            if (icountt==1)
                strCOMM1 = f.getValue();
            else if (icountt==2)
                strCOMM2 = f.getValue();
            else break;
        }
      Community__c oCommunity = new Community__c(Name=strCOMM1,PartnerPropertyId__c='DFW123');
        insert oCommunity; 
        string strInterfaceName = 'CARINGTEST';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
      string strJson = '{ \n ' + 
      '  "referral_source": "Caring.com", \n ' + 
      '  "community_id": "DFW123", \n ' + 
      '  "source_id": "67899", \n ' + 
      '  "inquirer_first_name": "Izzy", \n ' + 
      '  "inquirer_middle_name": "Michaela", \n ' + 
      '  "inquirer_last_name": "Inquirer", \n ' + 
      '  "inquirer_phone": "415-555-1212 x762", \n ' + 
      '  "inquirer_email": "user@example.com", \n ' + 
      '  "resident_first_name": "Ronny", \n ' + 
      '  "resident_middle_name": "Alfredo", \n ' + 
      '  "resident_last_name": "Resident", \n ' + 
      '  "relationship": "son", \n ' + 
      '  "note": "Here is a new referral from Caring.com\\n\\nWe appreciate feedback on our leads.\\nTest1: To provide feedback, please click:  https://portal.caring.com/referrals/20d9553fff869c0c92dded98bf9ed1f\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n\\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do\\neiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad\\nminim veniam, quis nostrud exercitation ullamco laboris nisi ut\\naliquip ex ea commodo consequat. Duis aute irure dolor in\\nreprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\\npariatur. Excepteur sint occaecat cupidatat non proident, sunt in\\nculpa qui officia deserunt mollit anim id est laborum\\n", \n ' + 
      '  "tour_date": "9/1/2018", \n ' + 
      '  "tour_time": "14:30:00", \n ' + 
      '  "advisor_name": "Annie Advisor", \n ' + 
      '"advisor_email": "aadvisor-leads@caring.com", \n ' + 
      '  "advisor_phone": "415-555-1222 x1292", \n ' + 
      '  "prefer_email": "false", \n ' + 
      '  "resident_age": 80, \n ' + 
      '  "current_living_situation": "Alone", \n ' + 
      '  "current_location": "Dallas, TX", \n ' + 
      '  "reason_for_moving": "Care Needs", \n ' + 
      '  "projected_move_in_date": "7/2017", \n ' + 
      '  "openness_to_moving": "ready_to_move", \n ' + 
      '  "memory_care_needed": "Minor", \n ' + 
      '  "mobility": "self_sufficient", \n ' + 
      '  "cooking": "Yes", \n ' + 
      '  "cleaning": "Yes", \n ' + 
      '  "bathing": "No assistance needed", \n ' + 
      '  "medications": "Assistance needed", \n ' + 
      '  "diabetic": "Diabetic no assistance needed", \n ' + 
      '  "driving": "No", \n ' + 
      '  "veterans_benefits": "Yes", \n ' + 
      '  "veterans_benefit_amount": 1200, \n ' + 
      '  "budget_maximum": 3000, \n ' + 
      '  "budget_minimum": 2000, \n ' + 
      '  "has_long_term_care_insurance": "No", \n ' + 
      '  "budget_savings": 80000, \n ' + 
      '  "budget_family_contribution": 1000, \n ' + 
      '  "budget_social_security": 1200, \n ' + 
      '  "budget_home_sale": 78000, \n ' + 
      '  "budget_annuities": 1000 \n ' + 
      '} \n ';
        string strJsonUpdate = '{ "lead_id": "67899", "tour_date": "10/31/2019", "tour_time": "14:00:00","notes":"test notes","xyz":"xyz","note":"test note" }';
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
    //TLGJsonInterface.Submit( strInterfaceName,  strJson);
      req.requestURI = '/services/apexrest/caringReferral/';  //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(strJson);
        RestContext.request = req;
        RestContext.response= res;
        //map<string,string> resp = caringRefService.doPost();
        Id LeadId=null;
        for (Lead ld : [SELECT Id, OwnerId, Reassign_To__c,AutoConvert__c, owner.name FROM Lead]){
            system.debug(ld.owner.name+':'+ld.ownerid);
            //ld.OwnerId = userinfo.getUserId();
            LeadId=ld.Id;
            ld.Reassign_To__c=userinfo.getUserId();
            ld.AutoConvert__c=true;
            system.debug(ld.owner.name+':'+ld.ownerid);
            update ld;
        }
        //for (Lead ld : [SELECT Id, OwnerId, Reassign_To__c, owner.name FROM Lead])
        //    system.debug(ld.owner.name+':'+ld.ownerid);
        
        ///
        Database.LeadConvert[] leadsToConvert = new Database.LeadConvert[1];
          integer i = 0;
          for (i = 0; i < 1; ++i) {
             {
                leadsToConvert[i] = new Database.LeadConvert();
                leadsToConvert[i].setConvertedStatus('Qualified');
                //leadsToConvert[i].setDoNotCreateOpportunity(True);
                leadsToConvert[i].setLeadId(LeadId);
             }
          }
//          List<Database.LeadConvertResult> lcResults = Database.convertLead(leadsToConvert);
          integer j = 0;
        ///
        Test.startTest(); 
        RestRequest requ = new RestRequest();
        RestResponse resu = new RestResponse();
        requ.requestURI = '/services/apexrest/caringReferralUpdate/';  //Request URL
        requ.httpMethod = 'POST';
        requ.requestBody = Blob.valueof(strJsonUpdate);
        RestContext.request = requ;
        RestContext.response= resu;
        //map<string,string> respu = caringUpdateRefService.doPost();
         Test.stopTest();
        //system.debug(respu);
    }*/
}