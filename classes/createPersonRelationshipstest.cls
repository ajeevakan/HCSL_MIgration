@isTest
private class createPersonRelationshipstest {
    static testMethod void createPersonRelationshipstest(){
    
        String hhRecordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Household').getRecordTypeId();
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String rcrecordTypeId  = Schema.getGlobalDescribe().get('HealthCloudGA__ReciprocalRole__c').getDescribe().getRecordTypeInfosByName().get('Contact Role').getRecordTypeId();
        Id pcId;
        
        List<HealthCloudGA__ReciprocalRole__c> lstrr = new  List<HealthCloudGA__ReciprocalRole__c>();
        
        HealthCloudGA__ReciprocalRole__c robj = new HealthCloudGA__ReciprocalRole__c();
        robj.Name = 'Son';
        robj.HealthCloudGA__InverseRole__c = 'Parent';
        robj.RecordTypeID = rcrecordTypeId;
        robj.HealthCloudGA__CreateInverseRole__c = true;
        robj.HEALTHCLOUDGA__RELATIONSHIPTYPE__C = 'Contact Contact Relation';
        lstrr.add(robj);
        
        HealthCloudGA__ReciprocalRole__c robj2 = new HealthCloudGA__ReciprocalRole__c();
        robj2.Name = 'Friend';
        robj2.HealthCloudGA__InverseRole__c = 'Other Relative';
        robj2.RecordTypeID = rcrecordTypeId;
        robj2.HealthCloudGA__CreateInverseRole__c = true;
        robj2.HEALTHCLOUDGA__RELATIONSHIPTYPE__C = 'Contact Contact Relation';
        lstrr.add(robj2);
        
                HealthCloudGA__ReciprocalRole__c robj3 = new HealthCloudGA__ReciprocalRole__c();
        robj3.Name = 'Spouse';
        robj3.HealthCloudGA__InverseRole__c = 'Spouse';
        robj3.RecordTypeID = rcrecordTypeId;
        robj3.HealthCloudGA__CreateInverseRole__c = true;
        robj3.HEALTHCLOUDGA__RELATIONSHIPTYPE__C = 'Contact Contact Relation';
        lstrr.add(robj3);
        
                        HealthCloudGA__ReciprocalRole__c robj4 = new HealthCloudGA__ReciprocalRole__c();
        robj4.Name = 'Self';
        robj4.HealthCloudGA__InverseRole__c = 'Self';
        robj4.RecordTypeID = rcrecordTypeId;
        robj4.HealthCloudGA__CreateInverseRole__c = true;
        robj4.HEALTHCLOUDGA__RELATIONSHIPTYPE__C = 'Contact Contact Relation';
        lstrr.add(robj4);
        
        insert lstrr;
        system.Debug('Test Class Debug: lstrr: ' + lstrr);
        List<HealthCloudGA__ReciprocalRole__c> insertedRR = [select Id, Name from HealthCloudGA__ReciprocalRole__c];
        system.Debug('Test Class Debug: insertedRR  ' + insertedRR );
        
        Account accPer1 = new Account();
        accPer1.FirstName='Test FName';
        accPer1.LastName='Test LName';
        accPer1.RecordTypeID = recordTypeId;
        accPer1.Relationship_to_Prospect__pc = 'Self';
        //accPer1.Related_Main_Prospect__c = hhaobj1.id;
        insert accPer1;
        
        Account hhaobj = new Account();
        hhaobj.Name = 'Test Account';
        hhaobj.RecordTypeID = hhRecordTypeId;
        //hhaobj.ParentId = accPer1.Id;
        insert hhaobj;
        
     
        
        for(Account accobj: [select Id, PersonContactId from Account where Id =: accPer1.Id])
        {
            pcId = accobj.PersonContactId;
        }
        
        AccountContactRelation acobj = new AccountContactRelation();
        acobj.ContactId = pcId;
        acobj.AccountId = hhaobj.id;
        insert acobj;
        
        Opportunity Opp = new Opportunity (Name = 'RR Opportunity');
        Opp.AccountId = accPer1.Id ;
        Opp.CloseDate = Date.Today();
        Opp.StageName = 'Initial Tour';
        insert Opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = pcId;
        ocr.OpportunityId = Opp.id;
        insert ocr;
        
        test.starttest();
        
        List<Account> lstAccount = new List<Account>();
        
        Account accPer= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonMailingStreet='test@yahoo.com',
          PersonMailingPostalCode='12345',
          PersonMailingCity='SFO',
          PersonEmail='test@yahoo.com',
          PersonHomePhone='1234567',
          PersonMobilePhone='12345678',
          Relationship_to_Prospect__pc = 'Son',
          Related_Main_Prospect__c = accPer1.id,
          Created_From_Opportunity__pc = Opp.Id
        ); 
        lstAccount.add(accPer); 
        
        Account accPer2 = new Account();
        accPer2.FirstName='Test1 FName';
        accPer2.LastName='Test1 LName';
        accPer2.RecordTypeID = recordTypeId;
       accPer2.Related_Main_Prospect__c = accPer1.id;
        accPer2.Created_From_Opportunity__pc = Opp.Id;
        accPer2.Relationship_to_Prospect__pc = 'Self';
        accPer2.Created_From_Opportunity_Action__pc = 'Add Primary Resident';
        lstAccount.add(accPer2); 

        Account accPer3 = new Account();
        accPer3.FirstName='Test2 FName';
        accPer3.LastName='Test2 LName';
        accPer3.RecordTypeID = recordTypeId;
        accPer3.Related_Main_Prospect__c = accPer1.id;
        accPer3.Created_From_Opportunity__pc = Opp.Id;
        accPer3.Relationship_to_Prospect__pc = 'Friend';
        accPer3.Created_From_Opportunity_Action__pc = 'Add Second Resident';
        lstAccount.add(accPer3); 
        
        insert lstAccount;
        
        test.stoptest();

       
                
    }
}