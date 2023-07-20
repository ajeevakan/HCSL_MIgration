@isTest
public class AllscriptsJumpPointTest {

    public static testMethod void AllscriptsJumpPointTest() {
    
       Lead l = new Lead(FirstName = 'a0d93llllasd1', LastName = 'ZXXlldl23892340ldldl', Company = 'ZXXlldl23892340ldldl44');
       insert l;
        Test.startTest();
       ApexPages.StandardController ctlr = new ApexPages.StandardController(l);
       AllscriptsJumpPoint   ext    = new AllscriptsJumpPoint (ctlr);
       ext.ASUserName = 'myUserId';
       ext.ASPassword = 'myPassword';
       ext.saveUserName2();
       ext.savePassword2(); 
        Test.stopTest();
       
    }
}