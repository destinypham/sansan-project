public with sharing class LeadController{
    public static String insertLead(List<Lead> leads){
        Set<String> externalIds = new Set<String>();
        Set<String> leadHasExist = new Set<String>();
        List<Lead> newLeads = new List<Lead>();
        String messageResponse = '';
        if (leads != null && !leads.isEmpty()){
            for (Lead lead : leads){
                externalIds.add(lead.id);
            }
            leadIsExist(leads, externalIds, leadHasExist, newLeads);
            if (!newLeads.isEmpty()){
                insert newLeads;
            }

            if (leadHasExist.size() > 0){
                for (String message : leadHasExist){
                    messageResponse += message + ', ';
                }
                messageResponse = messageResponse.removeEnd(',') + 'already exist in Lead!';
            } else{
                messageResponse = 'successfully!';
            }
        } else {
            messageResponse = 'No leads provided';
        }
        return messageResponse;
    }

    private static void leadIsExist(List<Lead> leads, Set<String> externalIds, Set<String> leadHasExist, List<Lead> newLeads){
        List<Lead> leadList = getLeadByExternalId(externalIds);
        Set<String> externalIdsSet = new Set<String>();
        Lead newLead;
        for (Lead lead : leadList){
            externalIdsSet.add(lead.External_Id__c);
        }
        for (Lead lead : leads){
            if (externalIdsSet.contains(lead.id)){
                leadHasExist.add(lead.id);
            } else{
                newLead = new Lead();
                newLead.External_Id__c = lead.id;
                newLead.FirstName = convertNameToFirstName(lead.name);
                newLead.LastName = convertNameToLastName(lead.name);
                newlead.Company = 'LWC';
                newLeads.add(newLead);
            }
        }
    }

    private static List<Lead> getLeadByExternalId(Set<String> externalIds){
        return [SELECT Id, External_Id__c, FirstName, LastName
                FROM Lead
                WHERE External_Id__c IN:externalIds];
    }

    private static String convertNameToFirstName(String leadName){
        if (String.isNotBlank(leadName)){
            List<String> nameParts = leadName.split(' ');
            if (nameParts.size() > 0){
                return nameParts.remove(0);
            } else{
                return '';
            }
        } else{
            return '';
        }
    }

    private static String convertNameToLastName(String leadName){
        String lastName = '';
        if (String.isNotBlank(leadName)){
            List<String> nameParts = leadName.split(' ');
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

}