global class SendDataToExternalBatch implements Database.Batchable<sObject> {
    Map<Id, Contact> idContactMapBatch = new Map<Id, Contact>();
    global SendDataToExternalBatch(Map<Id, Contact> idContactMap) {
        idContactMapBatch = idContactMap;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, FirstName, LastName, External_Id__c FROM Contact WHERE Id in:IdContactMapBatch.keySet()]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        if (!scope.isEmpty()) {
            System.enqueueJob(new SendDataToExternalQueueable(scope));
            System.debug('contact: ' + scope) ;
        }
    }
    global void finish(Database.BatchableContext BC) {}
}