public class SendDataToExternalHelper {
    
	public static HttpResponse requestToExternal(String endPoint, String jsonBody, String accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String authorizationHeader = 'Bearer ' + accessToken;
        request.setMethod('POST');
        request.setEndpoint(endPoint);
        request.setBody(jsonBody);
        request.setHeader('Authorization', authorizationHeader);
        response = http.send(request);
        return response;
    }

    public static String buildData(List<Contact> contacts) {
        Map<String, List<Object>> mapData = new Map<String, List<Object>>();
        List<Object> contactList = new List<Object>();

        for (Contact contact : contacts) {
            Map<String, Object> contactData = new Map<String, Object>();
            contactData.put('ExternalId', contact.External_Id__c);
            contactData.put('FirstName', contact.FirstName);
            contactData.put('LastName', contact.LastName);
            contactList.add(contactData);
            System.debug('contactData: ' + contactData) ;
           
        }
        mapData.put('data', contactList);
        System.debug('contactList: ' + contactList) ;
        System.debug('mapData: ' + mapData) ;
        System.debug('mapData11: ' + System.JSON.serialize(new List<Object>{mapData})) ;
        return System.JSON.serialize(new List<Object>{mapData});

    }
}