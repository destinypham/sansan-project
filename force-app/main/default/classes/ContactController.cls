public without sharing class ContactController {
    public static List<Contact> contactList;

    @AuraEnabled(Cacheable = true)
    public static List<Contact> searchContact(String contactName, String companyName) {
        contactName = '%' + contactName + '%';
        companyName = '%' + companyName + '%';
        list<Contact> listContact = [SELECT Id, Name, Company_Name__c FROM Contact WHERE Name LIKE :contactName OR Company_Name__c LIKE :companyName];

        if(listContact.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return listContact;
    }

    @AuraEnabled
    public static String updateContact(List<Contact> contacts) {
        String message = 'Failed';
        System.debug(contacts);
        try {
            if (contacts != null && !contacts.isEmpty()) {
                contactList = new List<Contact>();
                contactList.addAll(contacts);
                updateContacts(contactList);
                message = 'Success';
            } else {
                message = 'No contacts provided';
            }
        } catch (Exception ex) {
            System.debug('An error occurred while updating contacts: ' + ex.getMessage());
        }
        return message;
    }

    public static void updateContacts(List<Contact> contactList) {
        System.debug('contactList: ' + contactList);
        update contactList;
    }


    @AuraEnabled
    public static String insertLeads(List<Lead> leads) {
        String message = 'Failed';
        System.debug(leads);
        try {
            if (leads != null && !leads.isEmpty()) {
                LeadController.insertLead(leads);
                message = 'Success';
            } else {
                message = 'No leads provided';
            }
        } catch (Exception ex) {
            System.debug('An error occurred while insert leads: ' + ex.getMessage());
        }
        return message;
    }
}