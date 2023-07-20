@isTest
private class CreateStatusesTest  {
    static testMethod void testcreateStatuses(){
        Campaign cmp = new Campaign();
        cmp.Name = 'cmp3091983';
        test.startTest();
        insert cmp;
        test.stopTest();
    }
}