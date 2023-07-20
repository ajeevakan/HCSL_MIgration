@isTest
public class BatchContactGroupDuplicateContactsTest {

    @isTest
    static void myUnitTest01(){
    
    Account acc = new Account();
    acc.Name = 'WICB';
    insert acc;

    List<Contact> contacts = new List<Contact>();

    for (Integer i=0;i<5;i++) {
        contacts.add(new Contact(firstname='first '+i, 
        lastname='Test', Email='test1@gmail.com', AccountID = acc.id));
    }
    insert contacts;
    
    Test.startTest();
    BatchContactGroupDuplicateContacts testBatch = new BatchContactGroupDuplicateContacts();
    Id batchId = Database.executeBatch(testBatch);
        
    List<Contact> conUpdatelst = new List<Contact>([SELECT Id, Email from COntact WHERE firstname = 'first 1']);
    
    for(Contact conObj: conUpdatelst){
        conObj.Email = '';
    }
    update conUpdatelst;
    
    Id batchId1 = Database.executeBatch(testBatch);
    Test.stopTest();
    
    }
        
    
    
}