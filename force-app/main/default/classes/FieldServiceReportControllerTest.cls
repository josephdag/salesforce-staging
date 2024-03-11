/**********************************************************
Class: FieldServiceReportControllerTest
LastModifiedBy: Bopsy 08/08/2022
Description: This is Test class for the FieldServiceReportController     
***********************************************************/

@isTest
public class FieldServiceReportControllerTest {
    
    @testSetup
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
        
        Case testCase = new Case(Status ='New',
                                 Priority = 'Medium',
                                 AccountId = testAcc.Id,
                                 Origin = 'Email'); 
        insert testCase;
        
        Field_Service_Visit__c testFSV = new Field_Service_Visit__c();
        testFSV.Case__c = testCase.Id;
        insert testFSV;
    }
    
  /*  @isTest
    public static void fetchRMATest() {
        
        Field_Service_Visit__c testFSV = [SELECT Id FROM Field_Service_Visit__c];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testFSV);
        FieldServiceReportController testApex = new FieldServiceReportController(sc);
        test.stopTest();
        
        //Assertion
        System.assertEquals(false, testApex.theRMABoolean);
        
    }*/
    
  /*  @isTest
    public static void getRMAInLCTest() {
        Field_Service_Visit__c testFSV = [SELECT Id, Case__c FROM Field_Service_Visit__c];
        
        List<RMA__c> testRMAList = new List<RMA__c>();
        
        RMA__c testRMA = new RMA__c();
        testRMA.Case__c = testFSV.Case__c;
        testRMA.Product_Code_RMA__c = '1234';
        testRMAList.add(testRMA);
        
        RMA__c testRMA2 = new RMA__c();
        testRMA2.Case__c = testFSV.Case__c;
        testRMA2.Product_Code_RMA__c = '1234';
        testRMAList.add(testRMA2);
        insert testRMAList;
        
        test.startTest();
        FieldServiceReportController.wrapperRMAList testWrap = FieldServiceReportController.getRMAInLC(testFSV.Id);
        test.stopTest();
         
        //Assertion
        System.assertEquals(1, testWrap.theWrapperList.size());
    }*/
    
    @isTest
    public static void fetch4CTInListTest() {
        
        Field_Service_Visit__c testFSV = [SELECT Id FROM Field_Service_Visit__c];
        List<Calibrated_Tool__c> testCTList = new List<Calibrated_Tool__c>();
        for(Integer i = 0; i<2; i++) {
            Calibrated_Tool__c testCT = new Calibrated_Tool__c();
            testCT.Calibrated_Tool_Serial_Number__c = 'Test'+i;
            testCT.Field_Service_Visit__c = testFSV.Id;
            testCT.Cal_Expiration_Date__c = System.today();
            testCTList.add(testCT);
        }
        
        insert testCTList;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testFSV);
        FieldServiceReportController testApex = new FieldServiceReportController(sc);
        test.stopTest();
        
        //Assertion
        System.assertEquals(4, testApex.theCTWrapList.size());
        
    }
    
    @isTest
    public static void fetchMoreThan4CTInListTest() {
        Field_Service_Visit__c testFSV = [SELECT Id FROM Field_Service_Visit__c];
        List<Calibrated_Tool__c> testCTList = new List<Calibrated_Tool__c>();
        for(Integer i = 0; i<10; i++) {
            Calibrated_Tool__c testCT = new Calibrated_Tool__c();
            testCT.Calibrated_Tool_Serial_Number__c = 'Test'+i;
            testCT.Field_Service_Visit__c = testFSV.Id;
            testCT.Cal_Expiration_Date__c = System.today();
            testCTList.add(testCT);
        }
        
        insert testCTList;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testFSV);
        FieldServiceReportController testApex = new FieldServiceReportController(sc);
        test.stopTest();
        
        //Assertion
        System.assertEquals(10, testApex.theCTWrapList.size());
    }
}