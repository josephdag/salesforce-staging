@isTest
public class RMATriggerHandlerTest {
    @TestSetup
    public static void setup() {
        
        Contact testCon = new Contact();
        testCon.LastName = 'TestName';
        testCon.Email = 'Test@test.com';
        insert testCon;        
        
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
        
        testCon.AccountId = testAcc.Id;
        update testCon;
        
        Case testCase = new Case();
        testCase.Origin = 'HRI';
        insert testCase;
        
        Case testCaseOne = new Case();
        testCaseOne.Origin = 'Email';
        insert testCaseOne;
        
        RMA_Shipment__c  ship = new RMA_Shipment__c();
        ship.recordtypeId = Schema.SObjectType.RMA_Shipment__c.getRecordTypeInfosByName().get('Shipment').getRecordTypeId();
        ship.Ship_To__c = 'Test';
        ship.City__c = 'city';
        insert ship;
        
        RMA__c rmaOne = new RMA__c();
        rmaOne.RMA_Shipment__c = ship.Id;
        rmaOne.Case__c = testCase.Id;
        insert rmaOne;
        
        RMA__c rma = new RMA__c();
        rma.RMA_Shipment__c = ship.Id;
        rma.Case__c = testCaseOne.Id;
        insert rma;
        
    }
    
    @isTest
    public static void unitPositiveTestCaseOne() {
        RMA__c rma = [SELECT Id, RMA_Shipment__c FROM RMA__c LIMIT 1];
        Test.startTest();
        rma.RMA_Shipment__c = null;
        update rma;
        Test.stopTest();
    }

}