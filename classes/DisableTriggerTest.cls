@isTest
public class DisableTriggerTest {
@isTest
    public static void Test001(){
        
        Disable_Trigger__c setting = new Disable_Trigger__c();
        setting.Disable_For_Users__c = UserInfo.getUsername();
        //system.debug('UserInfo.getUsername() ' + UserInfo.getUsername());
        setting.Name = 'Sample trigger';
        setting.Trigger_Disabled__c = TRUE;
        insert setting;
        
        Test.startTest();
        System.runAs(new user(ID = UserInfo.getUserID())){
        DisableTrigger.isDisabled('Sample trigger');
        }
        Test.stopTest();
        
    }
    @isTest
    public static void Test002(){
        
        Disable_Trigger__c setting = new Disable_Trigger__c();
        //setting.Disable_For_Users__c = 'Test@Test.com';
        setting.Name = 'Sample trigger';
        setting.Trigger_Disabled__c = TRUE;
        insert setting;
        
        Test.startTest();
        System.runAs(new user(ID = UserInfo.getUserID())){
        DisableTrigger.isDisabled('Sample trigger');
        }
        Test.stopTest();
        
    }
}