/**********************************************************
Class: FeedItemTriggerHandlerTest 
LastModifiedBy: Bopsy 08/08/2022
Description: Test Class for FeedItemTriggerHandler
***********************************************************/
@isTest
public class FeedItemTriggerHandlerTest {
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
        
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        insert testCase;
        
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAcc.id;
        testOpp.Name = 'AbC';
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.CloseDate = Date.today();
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;
    }
    
    @isTest
    public static void sendMailToCaseOwnerTest(){
        Case testCase = [SELECT Id FROM Case limit 1];
        FeedItem testFI = new FeedItem();
        testFI.ParentId = testCase.id;
        testFI.Body = 'If this works im gonna be very happy';
        
        test.startTest();
        insert testFI;   
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void sendMailToCaseOwnerNegTest(){
        Opportunity testOpp = [SELECT Id FROM Opportunity];
        FeedItem testFI = new FeedItem();
        testFI.ParentId = testOpp.Id;
        testFI.Body = 'If this works im gonna be very happy';
        
        test.startTest();
        insert testFI;
        
        //Assertion
        System.assertEquals(0, Limits.getEmailInvocations());
        test.stopTest();
    }
}