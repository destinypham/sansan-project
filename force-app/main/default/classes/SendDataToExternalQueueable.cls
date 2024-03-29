global class SendDataToExternalQueueable implements System.Queueable, Database.AllowsCallouts {
    List<Contact> contacts;

    global SendDataToExternalQueueable(List<Contact> contacts) {
        this.contacts = contacts;
    }

    global void execute(System.QueueableContext context) {
        String endPoint = label.endpoint;
        String accessToken = SendDataToExternalHelper.getToken();
        String jsonBody = SendDataToExternalHelper.buildData(contacts);

        HttpResponse response = SendDataToExternalHelper.requestToExternal(endPoint, jsonBody, accessToken);

        if (response.getStatusCode() == 200) {
            System.debug('Callout successful!');
        } else {
            System.debug('Callout failed with status code: ' + response.getStatusCode());
        }
    }
}