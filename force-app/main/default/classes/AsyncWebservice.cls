@RestResource(urlMapping='/updateContact') // url
global without sharing class AsyncWebservice {

    // Biến khóa để kiểm soát quá trình xử lý
    private static Boolean isProcessing = false;

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        String jsonBody = request.requestBody.toString().trim();
        System.debug('jsonBody: ' + jsonBody);
        // Kiểm tra xem có đang xử lý không trước khi bắt đầu xử lý yêu cầu mới
        if(!isProcessing) {
            isProcessing = true; // Đặt biến isProcessing thành true để khóa quá trình xử lý
            processWebhookAsync(jsonBody);
            RestContext.response.statusCode = 200; // HTTP Status Code 200: Success
            RestContext.response.responseBody = Blob.valueOf('Update records successfully!');
        } else {
            // Nếu có đang xử lý, trả về lỗi hoặc thông báo rằng quá trình xử lý đang diễn ra
            // có thể trả về một thông báo HTTP hoặc thêm nó vào response
            RestContext.response.statusCode = 429; // HTTP Status Code 429: Too Many Requests
            RestContext.response.addHeader('Retry-After', '60'); // Thử lại sau 60 giây
            RestContext.response.responseBody = Blob.valueOf('Too Many Requests. Please try again later.');
        }
    }
    // Thay vì sử dụng đồng bộ ta dùng bất đồng bộ để xử lý
    @future(callout = true)
    public static void processWebhookAsync(String jsonBody){
        System.enqueueJob(new ProcessContactWebhook(jsonBody));
    }
    /* Code hiện tại chỉ xử lý một request tại một thời điểm. Để xử lý nhiều request cùng lúc, ta có thể sử dụng các
    hàng đợi như Queueable để đảm bảo rằng nhiều request có thể được xử lý song song.*/
    global class ProcessContactWebhook implements Queueable {
        private String jsonBody;

        global ProcessContactWebhook(String jsonBody) {
            this.jsonBody = jsonBody;
        }

        global void execute(QueueableContext context) {
            Savepoint sp = Database.setSavepoint();
            List<Contact> contactsToUpdate = new List<Contact>();
            Map<String, Contact> externalIdToContactMap = new Map<String, Contact>();
            Set<String> externalIds = new Set<String>();
            List<ContactData> contactDatas = new List<ContactData>();

            try {
                List<DataWrapper> dataList = (List<DataWrapper>)System.JSON.deserialize(jsonBody, List<DataWrapper>.class);
                System.debug('dataList: ' + dataList);
                for (DataWrapper wrapper : dataList) {
                    for (ContactData data : wrapper.data) {
                        externalIds.add(data.ExternalId);
                        contactDatas.add(data);
}
                }
                System.debug('externalIds: ' + externalIds);

                // Query bằng cách sử dụng External Id
                for (Contact contact : [SELECT Id, FirstName, LastName, External_Id__c
                                        FROM Contact
                                        WHERE External_Id__c IN :externalIds]) {
                    externalIdToContactMap.put(contact.External_Id__c, contact);
                }

                System.debug('externalIdToContactMap: ' + externalIdToContactMap);

                // Kiểm tra và update fields
                for (ContactData data : contactDatas) {
                    Contact contact = externalIdToContactMap.get(data.ExternalId);
                    if (contact != null) {
                        contact.FirstName = data.FirstName;
                        contact.LastName = data.LastName;
                        contactsToUpdate.add(contact);
                    }
                }
                System.debug('contactsToUpdate: ' + contactsToUpdate);
                // Thực hiện DML
                if (!contactsToUpdate.isEmpty()) {
                    update contactsToUpdate;
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('An error occurred: ' + e.getMessage());
            } finally {
                // Sau khi xử lý xong, đặt lại biến isProcessing thành false để mở khóa cho yêu cầu tiếp theo
                isProcessing = false;
            }
        }
    }

    // Build Wrapper cho Contact
    global class ContactData {
        public String ExternalId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
    }

    // Build Wrapper cho Data
    global class DataWrapper {
        public List<ContactData> data { get; set; }

    }

}