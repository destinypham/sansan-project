@isTest(SeeAllData = false)
public class SendDataToMuleSoftBatchTest {
    @TestSetup
    static void setUpData(){
        Contact contact = createContact();
    }

    @isTest
    public static void testExecuteMethod() {
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Title__c FROM Contact WHERE Title__c = 'Mule Soft'];
        Test.startTest();
            SendDataToMuleSoftBatch sendDataToMuleSoftBatch = new SendDataToMuleSoftBatch();
            Database.QueryLocator queryLocator = sendDataToMuleSoftBatch.start(null);
            sendDataToMuleSoftBatch.execute(null, contacts);
            sendDataToMuleSoftBatch.finish(null);
        Test.stopTest();
    }

    private static Contact createContact() {
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            Title__c = 'Mule Soft'
        );
        insert contact;
        return contact;
    }
}