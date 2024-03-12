public with sharing class ContactWebservice {
    public static HttpResponse getContact() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setEndpoint('https://64ae072db470006a5ec68c6a.mockapi.io/contact');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        response = http.send(request);
        return response;
    }

    public static HttpResponse searchContact(String contactName) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();

        request.setEndpoint('https://64ae072db470006a5ec68c6a.mockapi.io/contact?name=' + contactName.replaceAll(' ', '%20'));
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');
        response = http.send(request);
        return response;
    }
}