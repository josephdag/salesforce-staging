/**********************************************************
Class: BlueSheetLCControllerTest
LastModifiedBy: Bopsy 10/06/2022
Description: This is Test class for the BlueSheetLCController     
***********************************************************/
@isTest
public class BlueSheetLCControllerTest {
    
    @TestSetup
    public static void setup() {
        Account testAcc = new Account();
        testAcc.name = 'Test Update Acount';
        testAcc.Phone = '8866674854454';
        testAcc.Website = 'testAcc.com';
        testAcc.BillingCity = 'Summit';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingState = 'New Jersey';
        testAcc.BillingStreet = '11 Overlook Road';
        testAcc.BillingPostalCode = '07901';
        insert testAcc;
        
        Contact testCont = new Contact();
        testCont.FirstName = 'Paul';
        testCont.LastName  = 'Test';
        testCont.AccountId = testAcc.id;
        insert testCont;
        
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.Use_Case__c = 'Other';
        testOpp.Other_Use_Cases__c = 'test';
        testOpp.Site_of_Care__c = 'ICU';
        testOpp.Amount = 100;
        testOpp.AccountId = testAcc.Id;
        testOpp.StageName = 'Target/Prepare the Market';
        insert testOpp;
        
        OpportunityContactRole TestOCR = new OpportunityContactRole();
        TestOCR.ContactId = testCont.Id;
        TestOCR.OpportunityId = testOpp.Id;
        TestOCR.IsPrimary = TRUE;
        TestOCR.Role = 'Decision Maker';
        insert TestOCR;
        
    }
    
    @isTest
    public static void fetchDataTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        Test.startTest();
        BlueSheetLCController.MainWrapper theOpp = BlueSheetLCController.fetchData(testOpp.Id);
        Test.stopTest();
        System.assert(theOpp != null);
    }
    
     @isTest
    public static void saveDataTest() {
        Opportunity testOpp = [SELECT Id, blue_sheet_last_modified__c FROM Opportunity];
        Contact testCon = [SELECT Id FROM Contact];
        OpportunityContactRole testOCR = [SELECT Id FROM OpportunityContactRole];
        String recordData = '[{"theFields":[{"FieldAPIName":"ContactId","value":"'+testCon.Id+'"},{"FieldAPIName":"OCRId","value":"'+testOCR.Id+'"},{"FieldAPIName":"Name","Fieldtype":"STRING","OldValue":"testName 1","value":"testName 1"},{"FieldAPIName":"Title","Fieldtype":"STRING","OldValue":"TEST tITE","value":"TEST tITE"},{"FieldAPIName":"Phone","Fieldtype":"PHONE","OldValue":"12345685961","value":"12345685931"},{"FieldAPIName":"Email","Fieldtype":"EMAIL","OldValue":"test@test.com2","value":"test@test.com"},{"FieldAPIName":"Role","Fieldtype":"PICKLIST","OldValue":"Clinical Champion","thepicklist":["Business User","Clinical Champion","Decision Maker","Demo Attendee","Economic Buyer","Economic Decision Maker","Evaluator","Executive Sponsor","Influencer","Key Stakeholder","Other","Technical Buyer"],"value":"Clinical Champion"},{"FieldAPIName":"Notes__c","Fieldtype":"TEXTAREA"}]}]'; 
        
        Test.startTest();
        BlueSheetLCController.saveData(recordData, testOpp.Id);
        Test.stopTest();
       
    }
    
    @isTest
    public static void deleteOCRRecordsTest() {
        OpportunityContactRole theOCR = [Select Id FROM OpportunityContactRole];
        BlueSheetLCController.deleteOCRRecords(theOCR.Id);
    }
}