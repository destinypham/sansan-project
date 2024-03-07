public with sharing class LeadController {
    public static void insertLead(List<Lead> leads) {
        if (leads != null && !leads.isEmpty()) {
            List<Lead> leadsToUpdate = convertNameToLastNameFirstName(leads);
            insert leadsToUpdate;
        }
    }

    public static List<Lead> convertNameToLastNameFirstName(List<Lead> leads) {
        List<Lead> updatedLeads = new List<Lead>();
        for (Lead lead : leads) {
            if (lead.Name != null) {
                List<String> nameParts = lead.Name.split(' ');
                if (nameParts.size() > 0) {
                    lead.FirstName = nameParts.remove(0);
                    lead.LastName = String.join(nameParts, ' ');
                } else {
                    lead.LastName = lead.Name;
                }
                updatedLeads.add(lead);
            }
        }
        return updatedLeads;
    }
}