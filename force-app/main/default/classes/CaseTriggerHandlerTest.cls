/**********************************************************
Class: CaseTriggerHandlerTest 
LastModifiedBy: Bopsy 07/27/2022
Description: test Class for CaseTriggerHandler
***********************************************************/
@isTest
public class CaseTriggerHandlerTest {
    
    @testSetup
    public static void setup() {
        
        User testUser = [SELECT Id FROM User LIMIT 1];
        Account testAcc = new Account();
        testAcc.name = 'Test Update Acount';
        testAcc.Phone = '8866674854454';
        testAcc.Website = 'testAcc.com';
        testAcc.BillingCity = 'Summit';
        testAcc.BillingCountry = 'United States';
        testAcc.BillingState = 'New Jersey';
        testAcc.BillingStreet = '11 Overlook Road';
        testAcc.BillingPostalCode = '07901';
        testAcc.CSS_Primary__c = testUser.Id;
        testAcc.CSS_Secondary__c = testUser.Id;
        insert testAcc;
    }
    
    @isTest
    public static void testCase1() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Case_Category__c = 'Deployment';
        insert  testCase;
        
        test.startTest();
        testCase.Case_Category__c = 'Feature Request';
        update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testCase2() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Case_Category__c = 'Deployment';
        testCase.Reason = 'Storage';
        insert  testCase;
        
        test.startTest();
        testCase.Case_Category__c = 'Feature Request';
        testCase.Reason = 'Scanning';
        update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testCase3() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin='Email';
        testCase.Case_Category__c = null;
        insert testCase;
        
        test.startTest();
        testCase.Case_Category__c = 'Deployment';
        Update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testCase4() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Case_Reason_Comment__c = 'Test Comment';
        insert testCase;
        
        test.startTest();
        testCase.Case_Reason_Comment__c = 'Change Case Reason Comment';
        Update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    
    @isTest
    public static void testCase5() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Preventive_Action__c = 'Test Preventive Action';
        insert testCase;
        
        test.startTest();
        testCase.Preventive_Action__c = 'Change Preventive Action';
        Update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testCase6() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Priority = 'Severity 2';
        insert testCase;
        
        test.startTest();
        testCase.Priority = 'Severity 1';
        Update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testCase7() {
        
        Account testAcc = [SELECT Id FROM Account];
        Case testCase = new Case();
        testCase.AccountId = testAcc.Id;
        testCase.Origin = 'Email';
        testCase.Reason = 'Storage';
        insert testCase;
        
        test.startTest();
        testCase.Reason = 'Scanning';
        Update testCase;
        
        //Assertion
        System.assertEquals(1, Limits.getEmailInvocations());
        test.stopTest();
    }
    
    @isTest
    public static void testupdateCaseFromRelatedAsset() {
        
        Account testAcc = [SELECT Id FROM Account];
        
        Asset testAsset = new Asset();
        testAsset.Name = 'test Asset name';
        testAsset.Type_of_account__c = 'Commercial';
        testAsset.AccountId = testAcc.Id;
        testAsset.SerialNumber = 'test Asset name';
        testAsset.Description = 'test Description';
        testAsset.Build_ID__c = 'testBuild';
        testAsset.Software_Version__c = '8.3';
        insert testAsset;
        
        Case testCase = new Case();
        testCase.Origin = 'Email';
        testCase.Reason = 'Storage';
        insert testCase;
        
        test.startTest();
        testCase.top_level_main_serial_number__c = 'test Asset name';
        Update testCase;
        test.stopTest();
        
        //Assertion
        Case testCaseForAssertion = [SELECT Id, Type, AccountId, Scanner_HW_Version__c, Software_Version__c FROM Case WHERE Id =: testCase.Id];
        System.assertEquals(testAcc.Id, testCaseForAssertion.AccountId);
        System.assertEquals(testAsset.Type_of_account__c, testCaseForAssertion.Type);
        System.assertEquals(testAsset.Description, testCaseForAssertion.Scanner_HW_Version__c);
        System.assertEquals(testAsset.Software_Version__c, testCaseForAssertion.Software_Version__c);
        
    }
    
    @isTest
    public static void testunmatchAssetNamewithTopLevel() {
        
        Account testAcc = [SELECT Id FROM Account];
        
        Asset testAsset = new Asset();
        testAsset.Name = 'test Asset name1';
        testAsset.Type_of_account__c = 'Commercial';
        testAsset.AccountId = testAcc.Id;
        testAsset.SerialNumber = 'test Asset name1';
        insert testAsset;
        
        Case testCase = new Case();
        testCase.Origin = 'Email';
        testCase.Reason = 'Storage';
        insert testCase;
        
        test.startTest();
        testCase.top_level_main_serial_number__c = 'test Asset name';
        Update testCase;
        test.stopTest();
        
        //Assertion
        Case testCaseForAssertion = [SELECT Id, Type, AccountId FROM Case WHERE Id =: testCase.Id];
        System.assertNotEquals(testAcc.Id, testCaseForAssertion.AccountId);
        System.assertNotEquals(testAsset.Type_of_account__c, testCaseForAssertion.Type);
        
    }
}