trigger ContactTrigger on Contact (before insert, after update) {
	Map<Id, Contact> idContactMap = new Map<Id, Contact>();
    for(Contact contact : Trigger.New){
            idContactMap.put(contact.Id, contact);
    }
    if(IdContactMap.size() > 0){
        Database.executeBatch(new SendDataToExternalBatch(IdContactMap));
    }
}