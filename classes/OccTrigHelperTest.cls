@isTest
public class OccTrigHelperTest {

    @isTest
    public static void myUnitTest01() {
        integer n = 1;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        string strHousing_Type = 'Residential Living';
        integer k1=0;
        for(Schema.PicklistEntry f : Opportunity.Housing_Type__c.getDescribe().getPicklistValues()){
            strHousing_Type = f.getValue();
            k1++;
            if (k1==1) 
            	break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<n;i++){
            Account acc = new Account();//Preferred_Housing_Type__c=strHousing_Type
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<n;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id,Status__c = 'Vacant');//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            u.Housing_Type__c=strHousing_Type;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity(Amount=1000,Reporting_Community__c=ocomm.Id);
            o.Housing_Type__c = strHousing_Type;
            o.Name = lstContact1[i].FirstName + ' Opp ' + i;
            o.StageName = 'Prospecting';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today().AddDays(-2);
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.AccountId=lstContact1[i].AccountId;
            system.debug(o);
            lstOpportunity.add(o);
        }
        
        Test.startTest();
        insert lstOpportunity;
        OccTrigHelper.CalledOppTriggerOnce = false;
        Test.stopTest();

        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Bed__c=lstBed2.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }

        update lstUpdateOcc;

        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
        }
        system.assertEquals(mapOppIdOcc.keySet().size(),n);
        system.assertEquals(mapOccIdLog.keySet().size(),n*2);
        for (Id oppId : mapOppIdOcc.keySet()){
            list<Occupancy__c> lstOccupancy = mapOppIdOcc.get(oppId);
            system.assertEquals(lstOccupancy.size(),2);
            integer nPrimary = 0;
            for (Occupancy__c occ : lstOccupancy){
                list<Occupancy_Log__c> lstLog = mapOccIdLog.get(occ.Id);
                system.debug('++++');
                system.debug(lstLog);
                system.assertEquals(lstLog.size(),2);
                if (occ.Is_Primary__c) nPrimary++;
            }
            system.assertEquals(nPrimary,1);
        }
    }
    
    @isTest
    static void myUnitTest02() {
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<n;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<n;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            //o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        insert lstOpportunity;
        integer c=0;
        for ( Occupancy__c occ : [SELECT Apartment__c,Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c,Source_Opportunity__r.Name, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            system.debug(occ);
            c++;
        }
        system.assertEquals(c, 0);

        for (Opportunity o : lstOpportunity)
            o.Move_In_Date__C = Date.Today();
        Test.startTest();
        OccTrigHelper.CalledOppTriggerOnce = false;
        update lstOpportunity;
        OccTrigHelper.CalledOppTriggerOnce = false;
        Test.stopTest();

        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                system.debug('A '+k);
                occ.Bed__c=lstBed2.get(k).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                system.debug('B '+k);
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }

        update lstUpdateOcc;

        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
        }
        system.assertEquals(mapOppIdOcc.keySet().size(),n);
        system.assertEquals(mapOccIdLog.keySet().size(),n*2);
        for (Id oppId : mapOppIdOcc.keySet()){
            list<Occupancy__c> lstOccupancy = mapOppIdOcc.get(oppId);
            system.assertEquals(lstOccupancy.size(),2);
            integer nPrimary = 0;
            for (Occupancy__c occ : lstOccupancy){
                list<Occupancy_Log__c> lstLog = mapOccIdLog.get(occ.Id);
                system.debug('++++');
                system.debug(lstLog);
                system.assertEquals(lstLog.size(),2);
                if (occ.Is_Primary__c) nPrimary++;
            }
            system.assertEquals(nPrimary,1);
        }
    }
    
    @isTest
    static void myUnitTest03() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();

        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }

        update lstUpdateOcc;
        mapOppIdOcc.clear();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
            }
            else {
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
            }
        }
        
        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
        }
    //    system.assertEquals(mapOppIdOcc.keySet().size(),n);
     //   system.assertEquals(mapOccIdLog.keySet().size(),n*2);
        for (Id oppId : mapOppIdOcc.keySet()){
            list<Occupancy__c> lstOccupancy = mapOppIdOcc.get(oppId);
          //  system.assertEquals(lstOccupancy.size(),2);
            integer nPrimary = 0;
            for (Occupancy__c occ : lstOccupancy){
                list<Occupancy_Log__c> lstLog = mapOccIdLog.get(occ.Id);
                system.debug('++++'+occ.Apartment__r.Name);
                system.debug(occ);
            //    system.assertequals(lstLog.size(),2);
                if (occ.Is_Primary__c) nPrimary++;
            }
         //   system.assertEquals(nPrimary,2);
        }
    }
    
    @isTest
    static void myUnitTest04() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();

        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Move_Out_Date__c=date.today().addDays(0);
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }

        update lstUpdateOcc;
        mapOppIdOcc.clear();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
            }
            else {
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
            }
        }
        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
        }
        system.assertEquals(mapOppIdOcc.keySet().size(),n);
        system.assertEquals(mapOccIdLog.keySet().size(),n*2);
        for (Id oppId : mapOppIdOcc.keySet()){
            list<Occupancy__c> lstOccupancy = mapOppIdOcc.get(oppId);
            system.assertEquals(lstOccupancy.size(),2);
            integer nPrimary = 0;
            for (Occupancy__c occ : lstOccupancy){
                list<Occupancy_Log__c> lstLog = mapOccIdLog.get(occ.Id);
                system.debug('++++'+occ.Apartment__r.Name);
                system.debug(occ);
                //system.assertequals(lstLog.size(),2);
                if (occ.Is_Primary__c) nPrimary++;
            }
            //system.assertEquals(nPrimary,2);
        }
    }
    
    @isTest
    static void myUnitTest05() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        lstUpdateOcc.clear();
        mapOppIdOcc.clear();
        k=0;
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k).Id;
                occ.Bed__c=lstBed2.get(k).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                //occ.Level_of_Care__c=null;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                //lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        mapOppIdOcc.clear();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
            }
            else {
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
            }
        }
        
        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
        }
        system.assertEquals(mapOppIdOcc.keySet().size(),n);
        system.assertEquals(mapOccIdLog.keySet().size(),n*2);
        for (Id oppId : mapOppIdOcc.keySet()){
            list<Occupancy__c> lstOccupancy = mapOppIdOcc.get(oppId);
            system.assertEquals(lstOccupancy.size(),2);
            integer nPrimary = 0;
            for (Occupancy__c occ : lstOccupancy){
                list<Occupancy_Log__c> lstLog = mapOccIdLog.get(occ.Id);
                system.debug('++++'+occ.Apartment__r.Name);
                system.debug(occ);
                system.debug(lstLog.size());
                //system.assertequals(lstLog.size(),3);
                if (occ.Is_Primary__c) nPrimary++;
            }
            system.assertEquals(nPrimary,1);
        }
    }
    
    @isTest
    static void myUnitTest06() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        lstUpdateOcc.clear();
        mapOppIdOcc.clear();
        k=0;
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k).Id;
                occ.Bed__c=lstBed2.get(k).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                //occ.Level_of_Care__c=null;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                //lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        mapOppIdOcc.clear();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
            }
            else {
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
            }
        }
        list<Occupancy_Log__c> lstUpdateLog = new list<Occupancy_Log__c>();
        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c, Start_Date__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
            log.Start_Date__c = log.Start_Date__c.addDays(1); 
            lstUpdateLog.add(log);
        }
        update lstUpdateLog;
        
        lstOpportunity.get(0).Move_In_Date__C=Date.Today().addDays(1);
        OccTrigHelper.CalledOppTriggerOnce = false;
        update lstOpportunity.get(0);
    }
    
    @isTest
    static void myUnitTest07() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Expected_Move_In_Date__c = Date.Today().addDays(5);
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Scheduled_Move_In_Date__c=date.today().addDays(2);
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
    }
    
    @isTest
    static void myUnitTest08() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<(m);i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        for (integer i =m;i<(m+5);i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__c = Date.Today().addDays(-5);
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        integer v = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            v++;
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Transfer_Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Transfer_Apartment__c=lstUnit[v].Id;
                occ.Last_change_Date__c=date.today();
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
    }
    
    @isTest
    static void myUnitTest09() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k+n).Id;
                occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        lstUpdateOcc.clear();
        mapOppIdOcc.clear();
        k=0;
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                occ.Apartment__c=lstUnit.get(k).Id;
                occ.Bed__c=lstBed2.get(k).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                //occ.Level_of_Care__c=null;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                //lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        mapOppIdOcc.clear();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
            }
            else {
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
            }
        }
        list<Occupancy_Log__c> lstUpdateLog = new list<Occupancy_Log__c>();
        for ( Occupancy_Log__c log : [SELECT Id, Occupancy__c, Start_Date__c FROM Occupancy_Log__c]){
            if (mapOccIdLog.containsKey(log.Occupancy__c))
                mapOccIdLog.get(log.Occupancy__c).add(log);
            else mapOccIdLog.put(log.Occupancy__c,new list<Occupancy_Log__c>{log});
            log.Start_Date__c = log.Start_Date__c.addDays(1); 
            lstUpdateLog.add(log);
        }
        update lstUpdateLog;
        
        lstOpportunity.get(0).Move_In_Date__C=null;
        OccTrigHelper.CalledOppTriggerOnce = false;
        update lstOpportunity.get(0);
    }
    
    @isTest
    static void myUnitTest10() {
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<n;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<n;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        insert lstOpportunity;
        Test.startTest();
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apply_Change_to_Couple__c, Apartment__c, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c LIMIT 1]){
            {
                occ.Apartment__c = lstUnit[k+2].Id;
                occ.Apply_Change_to_Couple__c = true;
                lstUpdateOcc.add(occ);
            }
       }
        update lstUpdateOcc;
        Test.stopTest();
    }
    
    @isTest
    static void myUnitTest11() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                //occ.Apartment__c=lstUnit.get(k+n).Id;
                //occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                //lstUpdateOcc.add(occ);
                k++;
            }
            else {
                //occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                occ.Move_Out_Date__c=date.today();
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        lstUpdateOcc.clear();
        mapOppIdOcc.clear();
        k=0;
        
    }
    
    @isTest
    static void myUnitTest12() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        Test.startTest();
        insert lstOpportunity;
        Test.stopTest();
        
        
        map<Id,list<Occupancy__c>> mapOppIdOcc = new map<Id,list<Occupancy__c>>();
        map<Id,list<Occupancy_Log__c>> mapOccIdLog = new map<Id,list<Occupancy_Log__c>>();
        integer k = 0;
        list<Occupancy__c> lstUpdateOcc = new list<Occupancy__c>();
        for ( Occupancy__c occ : [SELECT Apartment__c, Apartment__r.Name, Bed__c, Is_Primary__c, Level_of_Care__c, Move_In_Date__c, Move_Out_Date__c, Resident__c, Source_Opportunity__c, Id FROM Occupancy__c WHERE Source_Opportunity__c != null order by Source_Opportunity__c]){
            if (mapOppIdOcc.containsKey(occ.Source_Opportunity__c)){
                //occ.Apartment__c=lstUnit.get(k+n).Id;
                //occ.Bed__c=lstBed2.get(k+n).Id;
                mapOppIdOcc.get(occ.Source_Opportunity__c).add(occ);
                occ.Move_Out_Date__c=date.today();
                lstUpdateOcc.add(occ);
                k++;
            }
            else {
                //occ.Bed__c=lstBed1.get(k).Id;
                mapOppIdOcc.put(occ.Source_Opportunity__c,new list<Occupancy__c>{occ});
                occ.Move_Out_Date__c=date.today();
                lstUpdateOcc.add(occ);
            }
        }
        update lstUpdateOcc;
        lstUpdateOcc.clear();
        mapOppIdOcc.clear();
        k=0;
        
    }
    
   @isTest
    static void myUnitTest13() {
        integer m = 10;
        integer n = 5;
        string strCOMM1 = '';
        for(Schema.PicklistEntry f : Opportunity.Community__c.getDescribe().getPicklistValues()) if (f.getValue().length()>3){
            strCOMM1 = f.getValue();
            break;
        }
        Community__c ocomm = new Community__c(Name=strCOMM1);
        insert ocomm;
        //Floor_Plan__c fp = new Floor_Plan__c(Community_Id__c = ocomm.Id, Name='FP01',Community__c=strCOMM1,Floor_Plan_Type__c='FP Type');
        //insert fp;
        list<Unit__c> lstUnit = new list<Unit__c>();
        list<Account> lstAccount = new list<Account>();
        list<Contact> lstContact = new list<Contact>(); 
        list<Contact> lstContact1 = new list<Contact>();
        list<Contact> lstContact2 = new list<Contact>();
        list<Bed__c> lstBed = new list<Bed__c>();        
        list<Bed__c> lstBed1 = new list<Bed__c>();
        list<Bed__c> lstBed2 = new list<Bed__c>();
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        for (integer i =0;i<m;i++){
            Account acc = new Account();
            acc.Name = 'New Account ' + i;
            acc.Community__c = strCOMM1;
            lstAccount.add(acc);
        }
        insert lstAccount;
        for (integer i =0;i<m;i++){
            Unit__c u = new Unit__c (Community_Id__c = ocomm.Id);//Floor_Plan_Id__c=fp.Id,
            u.Name = 'Test' + string.valueOf(i);
            u.Community__c = strCOMM1;
            lstUnit.add(u);
            Bed__c obed1 = new Bed__c(Name='Bed A ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            Bed__c obed2 = new Bed__c(Name='Bed B ' + string.valueOf(i), Room_Name__c='Test' + string.valueOf(i), Community__c = ocomm.Id);
            lstBed.add(obed1);
            lstBed.add(obed2);
            lstBed1.add(obed1);
            lstBed2.add(obed2);
            Contact c = new Contact(FirstName = 'Abc' + string.valueOf(i), LastName = 'Bcd' + string.valueOf(i), Prospect__c = True, Relationship_To_Prospect__C = 'Self', AccountId = lstAccount.get(i).Id);
            Contact c2 = new Contact(FirstName = 'Efg' + string.valueOf(i), LastName = 'Fgh' + string.valueOf(i), Prospect__C = True, Relationship_To_Prospect__C = 'Spouse', AccountId = lstAccount.get(i).Id);
            lstContact.add(c);
            lstContact.add(c2);
            lstContact1.add(c);
            lstContact2.add(c2);
        }
        insert lstUnit;
        insert lstBed;
        insert lstContact;
        for (integer i =0;i<n;i++){
            Opportunity o = new Opportunity();
            o.Name = 'New Opp ' + i;
            o.StageName = 'Active';
            o.CloseDate = Date.Today();
            o.Move_In_Date__C = Date.Today();
            o.Unit__c = lstUnit[i].Id;
            o.Community__c = strCOMM1;
            o.Primary_Resident__c=lstContact1[i].Id;
            o.Second_Resident__c=lstContact2[i].Id;
            o.Housing_Type__c='Residential Living';
            lstOpportunity.add(o);
        }
        insert lstOpportunity;
        Test.startTest();
        delete lstOpportunity;
        Test.stopTest();
        
        
        
        
    }
}