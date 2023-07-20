@isTest
public class AllscriptsApiTest {
	@isTest
    public static void AllscriptsApiTest (){
        Lead l = new Lead();
        l.LastName = 'Test';
        insert l;
        
        Test.startTest();
        Integer status = AllscriptsApi.setMessage(l.Id, 'Test Body', 200, '');
        Test.stopTest();
        
        System.assertEquals(200, status);
    }
}