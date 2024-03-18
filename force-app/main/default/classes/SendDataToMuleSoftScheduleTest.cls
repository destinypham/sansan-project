@isTest(SeeAllData = false)
public class SendDataToMuleSoftScheduleTest {
    @isTest
    public static void executeTest() {
        Test.startTest();
            SendDataToMuleSoftSchedule schedule = new SendDataToMuleSoftSchedule();
            schedule.execute(null);
        Test.stopTest();
    }
}