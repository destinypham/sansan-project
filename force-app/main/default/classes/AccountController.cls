public with sharing class AccountController{
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts(String firstName, String lastName){
        System.debug('Name: ' + firstName + ' ' + lastName);
        lastName = '%' + lastName + '%';
        firstName = '%' + firstName + '%';
        return [SELECT Id, Name
                FROM Account    
                WHERE Name LIKE: firstName OR Name LIKE: lastName];
    }

}