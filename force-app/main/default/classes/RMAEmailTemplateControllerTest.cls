/*******************************************************
//Class: RMAEmailTemplateControllerTest
//Last Modified by: Bopsy Team {08/01/2022}
//Description: This is the Test class for RMAEmailTemplateController & RMADefAndReplRelatedListLCController
/*******************************************/
@isTest
public class RMAEmailTemplateControllerTest {
    
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
        
    }
    
    @isTest
    public static void getRMANullTest() {
        
        test.startTest();
        RMAEmailTemplateController testApexObj = new RMAEmailTemplateController();
        RMA__c testRMA = testApexObj.getRMA();
        test.stopTest();
        
        //Assertion
        System.assertEquals(null, testRMA);
    }
    
    @isTest
    public static void sendAttachRMAPDFEmailTest() {
        
        Case testCase = [SELECT Id FROM Case];
        
        RMA_Part__c testRMAPart = new RMA_Part__c();
        testRMAPart.Name = '123456';
        testRMAPart.Category__c = 'Critical Accessory';
        insert testRMAPart;
        
        RMA__c testRMA = new RMA__c();
        testRMA.Case__c = testCase.Id;
        testRMA.RMA_Defective_Part__c = testRMAPart.Id;
        insert testRMA;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testRMA);
        RMAEmailTemplateController testRMAPlan = new RMAEmailTemplateController(sc);
        
        RMAEmailTemplateController testRETC = new RMAEmailTemplateController(testRMA.Id);
        
        test.startTest();
        testRMAPlan.RMAId = testRMA.Id;
        RMA__c testAssertRMA = testRMAPlan.getRMA();
        test.stopTest();
        
        //Assertion
        System.assertEquals(testRMA.Id, testAssertRMA.Id);
    }
    
}