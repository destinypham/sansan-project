public with sharing class ContactWrapper {
    public static List<Object> parseData(String jsonWrapper) {
        List<Object> parsedJson = (List<Object>)System.JSON.deserializeUntyped(jsonWrapper);
        return parsedJson;
    }
}
