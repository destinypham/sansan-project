global class SendDataToMuleSoftSchedule implements Schedulable {
    global SendDataToMuleSoftSchedule() {}

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new SendDataToMuleSoftBatch(), 100);
    }
}