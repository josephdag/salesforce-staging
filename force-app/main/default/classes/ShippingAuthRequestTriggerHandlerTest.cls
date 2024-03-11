/**********************************************************
Class: ShippingAuthRequestTriggerHandlerTest
LastModifiedBy: Bopsy 08/08/2022
Description: This is Test class for the ShippingAuthRequestTriggerHandler     
***********************************************************/

@istest
public class ShippingAuthRequestTriggerHandlerTest {
    
    @testSetup
    public static void test_setup(){
        
        List<Authorized_Shipping_Location__c> testASLToInsert = new List<Authorized_Shipping_Location__c>();
        Authorized_Shipping_Location__c testASL = new Authorized_Shipping_Location__c();
        testASL.Country__c = 'United States';
        testASL.Name = 'testASLExisting';
        testASL.Status__c = 'Active';
        testASLToInsert.add(testASL);
        
        Authorized_Shipping_Location__c testASL1 = new Authorized_Shipping_Location__c();
        testASL1.Country__c = 'United States';
        testASL1.Name = 'testASLExisting1';
        testASL1.Status__c = 'Inactive';
        testASLToInsert.add(testASL1);
        
        insert testASLToInsert;        
        
    }
    
    @istest
    public static void testtoCreateSAforExistingASL() {
         

        Id devRecordTypeId = Schema.SObjectType.Shipping_Authorization_Request__c.getRecordTypeInfosByName().get('Delivery').getRecordTypeId();
        
        Shipping_Authorization_Request__c testSAR = new Shipping_Authorization_Request__c();
        testSAR.Delivery_Address_Country__c = 'United States';
        testSAR.Unit_Type__c = 'Commercial';
        testSAR.RecordTypeId = devRecordTypeId;
        insert testSAR;
        
        test.startTest();
        ShippingAuthRequestTriggerHandler.automationForShipAuthRequest(testSAR.Id);
        test.stopTest();
        
        //Assertion
        Authorized_Shipping_Location__c testASLForAssertion = [SELECT Id FROM Authorized_Shipping_Location__c WHERE Status__c = 'Active'];
        Shipping_Authorization__c testSAListForAssertion = [SELECT Id, Authorized_Shipping_Location__c FROM Shipping_Authorization__c WHERE Shipping_Authorization_Request__c =: testSAR.Id];
        Shipping_Authorization_Request__c testSARListForAssertion = [SELECT Id, Status__c FROM Shipping_Authorization_Request__c WHERE Id =: testSAR.Id];
        
        system.assertEquals(testASLForAssertion.Id, testSAListForAssertion.Authorized_Shipping_Location__c);
        system.assertEquals('Pending Approval', testSARListForAssertion.Status__c);
        
    }
    
    @istest
    public static void testtoNotCreateSAforExistingASLAndSendEmail() {
        
        List<Shipping_Authorization_Request__c> testSARToInsert = new List<Shipping_Authorization_Request__c>();
        Shipping_Authorization_Request__c testSAR = new Shipping_Authorization_Request__c();
        testSAR.Delivery_Address_Country__c = 'Australia';
        testSAR.Unit_Type__c = 'Commercial';
        insert testSAR;    
        
        Integer theEmailInvocation = 0;
        test.startTest();
        ShippingAuthRequestTriggerHandler.automationForShipAuthRequest(testSAR.Id);
        theEmailInvocation = Limits.getEmailInvocations();
        test.stopTest();
        
        //Assertion
        Shipping_Authorization_Request__c testSARListForAssertion = [SELECT Id, Status__c FROM Shipping_Authorization_Request__c ];
        system.assertEquals('Declined', testSARListForAssertion.Status__c);
        system.assertEquals(1, theEmailInvocation);
    }
    
    @istest
    public static void testtoStatusPendingApprovalForResearch() {
        
        Shipping_Authorization_Request__c testSAR = new Shipping_Authorization_Request__c();
        testSAR.Delivery_Address_Country__c = 'United States';
        testSAR.Unit_Type__c = 'Research';
        insert testSAR;
        
        test.startTest();
        ShippingAuthRequestTriggerHandler.automationForShipAuthRequest(testSAR.Id);
        test.stopTest();
        
        Shipping_Authorization_Request__c testSARListForAssertion = [SELECT Id, Status__c FROM Shipping_Authorization_Request__c];
        system.assertEquals('Pending Approval', testSARListForAssertion.Status__c);
        
    }
}