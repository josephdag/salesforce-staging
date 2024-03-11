/**********************************************************
Class: customLookUpControllerTest
LastModifiedBy: Bopsy 05/05/2022
Description: This is Test class for the customLookUpController     
***********************************************************/

@isTest
public class customLookUpControllerTest {
@isTest
    public static void fetchLookUpValuesTest() {
        test.startTest();
        List<Object> testList = customLookUpController.fetchLookUpValues('Test','Opportunity');
        test.stopTest();
        System.assertEquals(0, testList.size());
    }
}