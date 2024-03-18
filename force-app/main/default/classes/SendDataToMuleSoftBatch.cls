

global class SendDataToMuleSoftBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {


    public SendDataToMuleSoftBatch() {}


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, FirstName, LastName'
                        + ' FROM Contact'
                        + ' WHERE Title__c = \'Mule Soft\'';
        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<Contact> contacts) {
        List<Contact_PL__e> platformEvents = new List<Contact_PL__e>();
        try {
            System.debug('contacts: ' + contacts);
            if (!contacts.isEmpty()) {
                for (Contact contact : contacts) {
                    Contact_PL__e contactPL = new Contact_PL__e(Id__c = contact.Id, First_Name__c = contact.FirstName, Last_Name__c = contact.LastName);
                    platformEvents.add(contactPL);
                }

                System.debug('platformEvents: ' + platformEvents);
                if (!platformEvents.isEmpty()) {
                    List<Database.SaveResult> results = EventBus.publish(platformEvents);
                }
            }
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
        }
    }

    
    global void finish(Database.BatchableContext BC) {}
}