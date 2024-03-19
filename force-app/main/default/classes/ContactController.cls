public without sharing class ContactController{
    public static List<Contact> contactList;
    @AuraEnabled(Cacheable = true)
    public static List<Map<String, String>> getContact(){
        HttpResponse httpResponse = ContactWebservice.getContact();
        String responseBody = httpResponse.getBody();
        return handleData(responseBody);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Map<String, String>> searchContact(String contactName){
        HttpResponse httpResponse = ContactWebservice.searchContact(contactName.trim());
        String responseBody = httpResponse.getBody();
        return handleData(responseBody);
    }

    @AuraEnabled
    public static String updateContact(List<Map<String, String>> contacts){
        List<Contact> contactList = new List<Contact>();
        List<Contact> newContactList = new List<Contact>();
        List<Contact> updateContactList = new List<Contact>();
        Set<String> externalIds = new Set<String>();
        Contact newContact;
        String message = 'Failed';
        try{
            if (contacts != null && !contacts.isEmpty()){
                for (Map<String, String> contactData : contacts){
                    newContact = new Contact();
                    newContact.External_Id__c = contactData.get('id');
                    newContact.FirstName = convertNameToFirstName(contactData.get('name'));
                    newContact.LastName = convertNameToLastName(contactData.get('name'));
                    externalIds.add(contactData.get('id'));
                    contactList.add(newContact);
                }
                handleCheckContact(contactList, newContactList, updateContactList, externalIds);

                if (!newContactList.isEmpty()){
                    insert newContactList;
                }

                if (!updateContactList.isEmpty()){
                    updateContact(updateContactList);
                }

                message = 'Success';
            } else{
                message = 'No contacts provided';
            }
        } catch (Exception ex){
            System.debug('An error occurred while updating contacts: ' + ex.getMessage());
        }
        return message;
    }

    private static void updateContact(List<Contact> contacts){
        Set<String> externalIds = new Set<String>();
        Map<String, String> mapContactToUpdateFirstName = new Map<String, String>();
        Map<String, String> mapContactToUpdateLastName = new Map<String, String>();
        List<Contact> contactToUpdate = new List<Contact>();
        for (contact contact : contacts){
            externalIds.add(contact.External_Id__c);
            mapContactToUpdateFirstName.put(contact.External_Id__c, contact.FirstName);
            mapContactToUpdateLastName.put(contact.External_Id__c, contact.LastName);
        }
        contactToUpdate = getContactByExternalId(externalIds);
        for (contact contact : contactToUpdate){
            if (mapContactToUpdateFirstName.containsKey(contact.External_Id__c)){
                contact.FirstName = mapContactToUpdateFirstName.get(contact.External_Id__c);
            }
            if (mapContactToUpdateLastName.containsKey(contact.External_Id__c)){
                contact.LastName = mapContactToUpdateLastName.get(contact.External_Id__c);
            }
        }
        update contactToUpdate;
    }

    @AuraEnabled
    public static String insertLeads(List<Lead> leads){
        String message = '';
        try{
            if (leads != null && !leads.isEmpty()){
                message = LeadController.insertLead(leads);
            } else{
                message = 'No leads provided';
            }
        } catch (Exception ex){
            System.debug('An error occurred while insert leads: ' + ex.getMessage());
        }
        return message;
    }

    private static List<Map<String, String>> handleData(String jsonResponse){
        List<Map<String, String>> contacts = new List<Map<String, String>>();
        List<Object> parsedJson = ContactWrapper.parseData(jsonResponse);
        if (String.isNotBlank(jsonResponse)){
            for (Object obj : parsedJson){
                Map<String, Object> contactMap = (Map<String, Object>)obj;
                Map<String, String> contact = new Map<String, String>();
                String contactName = (String) contactMap.get('name');
                String id = (String) contactMap.get('id');
                contact.put('id', id);
                contact.put('name', contactName);
                contacts.add(contact);
            }
        }
        return contacts;
    }

    private static String convertNameToFirstName(String contactName){
        if (String.isNotBlank(contactName)){
            List<String> nameParts = contactName.split(' ');
            if (nameParts.size() > 0){
                return nameParts.remove(0);
            } else{
                return '';
            }
        } else{
            return '';
        }
    }

    private static String convertNameToLastName(String contactName){
        String lastName = '';
        if (String.isNotBlank(contactName)){
            List<String> nameParts = contactName.split(' ');
            if (nameParts.size() <= 1){
                return '';
            } else{
                for (Integer i = 0; i < nameParts.size(); i++){
                    if (i > 0){
                        lastName += nameParts[i] + ' ';
                    }
                }
                return lastName.trim();
            }
        } else{
            return '';

        }
    }

    private static List<Contact> getContactByExternalId(Set<String> externalIds){
        return [SELECT Id, External_Id__c, FirstName, LastName
                FROM Contact
                WHERE External_Id__c IN:externalIds];
    }

    private static void handleCheckContact(List<Contact> contactList, List<Contact> newContactList, List<Contact> updateContactList, Set<String> externalIds){
        List<Contact> contacts = getContactByExternalId(externalIds);
        Set<String> externalIdsSet = new Set<String>();

        for (Contact contact : contacts){
            externalIdsSet.add(contact.External_Id__c);
        }

        for (Contact contact : contactList){
            if (externalIdsSet.contains(contact.External_Id__c)){
                updateContactList.add(contact);
            } else{
                newContactList.add(contact);
            }
        }
    }

    @AuraEnabled
    public static Boolean newContact(String firstName, String lastName, String accountId){
        Boolean result = true;
        try{
            Contact contact = new Contact(
                firstName = firstName,
                lastName = lastName,
                AccountId = accountId
            );
            if (contact != null) {
                insert contact;
            }
        } catch(Exception e) {
            result = false;
        }
        return result;
    }

}