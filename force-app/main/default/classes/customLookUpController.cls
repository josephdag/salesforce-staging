/**********************************************************
Class: customLookUpController 
LastModifiedBy: Bopsy 06/15/2022
Description: This class is use for Show lookup fields    
TestClass : customLookUpControllerTest
***********************************************************/
public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        
        String searchKey = '%' + searchKeyWord + '%';
        
        List <sObject> returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}