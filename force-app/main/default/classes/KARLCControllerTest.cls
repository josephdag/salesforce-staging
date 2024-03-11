/**********************************************************
Class: KARLCControllerTest
LastModifiedBy: Bopsy 08/08/2022
Description: This is Test class for the KARLCController     
***********************************************************/
@isTest
public class KARLCControllerTest {
    
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
        
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.AccountId = testAcc.Id;
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;
    }
    
    @isTest
    public static void fetchFieldSetInfoTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        Test.startTest();
        List<KARLCController.FieldSetwrapper> testFSW = KARLCController.fetchFieldSetInfo(testOpp.Id);
        Test.stopTest();
        System.assertEquals(6, testFSW.size());
    }
    
    @isTest
    public static void saveDataTest() {
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        testOpp.Travel_to_MSA_Field_Ride__c = true;
        testOpp.Schedule_Meetings__c = true;
        testOpp.Present_clinical_data__c = true;
        testOpp.Document_Pain_Points_in_Blue_Sheet_SF__c = 'Test Doc';
        testOpp.Update_use_cases__c = 'AMS';
        testOpp.Radiology_Meeting_Date__c = date.today();
        testOpp.Doc_contracting_process_in_Blue_sheet__c = 'Test';
        update testOpp;
        
        List<KARLCController.FieldSetwrapper> testFSW = KARLCController.fetchFieldSetInfo(testOpp.Id);
        
        Test.startTest();
        KARLCController.returnWrapper testReturn = KARLCController.saveData(JSON.serialize(testFSW), testOpp.Id);
        Test.stopTest();
        
        Opportunity testOpp1 = [SELECT Id, Name FROM Opportunity];
        System.assertEquals(testReturn.Name , testOpp1.Name);
    }
}