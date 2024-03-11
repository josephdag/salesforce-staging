/**********************************************************
Class: SetupAuditschedulableBatchTest
LastModifiedBy: Cloud Connex 04/11/2023
Description: This is Test class for the SetupAuditschedulableBatch     
*********************************************************/
@isTest
public class SetupAuditschedulableBatchTest {
    
    @isTest
    public static void testSetupAuditWithCustomQuery() { 
        
        SetupAuditTrailEmail__c theEmails = new SetupAuditTrailEmail__c();
        theEmails.Name = 'Audit Trail Emails';
        theEmails.Emails__c ='test@gmail.com,test1@gmail.com';
        insert theEmails;
        
        string testQuery = 'SELECT Id, Action, Display, Section, CreatedDate, CreatedBy.UserName, DelegateUser, ResponsibleNamespacePrefix, CreatedByContext, CreatedByIssuer FROM SetupAuditTrail ORDER BY CreatedDate DESC LIMIT 200';
        
        Test.startTest();
        SetupAuditschedulableBatch testAudit = new SetupAuditschedulableBatch(testQuery);
        Database.executeBatch(testAudit);
        
        Test.stopTest();
        
        //Assertion
        //Cannot assert the EmailInvocation here because internally according to SF, email is being sent via a future method.So EmailInvocation always shows 0.
    }
    
    @isTest
    public static void testSetupAuditWithOutCustomQuery() { 
        
        SetupAuditTrailEmail__c theEmails = new SetupAuditTrailEmail__c();
        theEmails.Name = 'Audit Trail Emails';
        theEmails.Emails__c ='test@gmail.com,test1@gmail.com';
        insert theEmails;
        
        Test.startTest();
        SetupAuditschedulableBatch testAudit = new SetupAuditschedulableBatch();
        Database.executeBatch(testAudit);
        Test.stopTest();
        
        //Assertion
        //Cannot assert the EmailInvocation here because internally according to SF, email is being sent via a future method.So EmailInvocation always shows 0.
    }
    
    
    @isTest
    public static void testSetupAuditWithSchedulable() { 
        
        SetupAuditTrailEmail__c theEmails = new SetupAuditTrailEmail__c();
        theEmails.Name = 'Audit Trail Emails';
        theEmails.Emails__c ='test@gmail.com,test1@gmail.com';
        insert theEmails;
        
        Test.startTest();
        //Execution
        SetupAuditschedulableBatch testSchedule = new SetupAuditschedulableBatch();
        testSchedule.execute(null);
        Test.stopTest();
        
        //Assertion
        //Cannot assert the EmailInvocation here because internally according to SF, email is being sent via a future method.So EmailInvocation always shows 0.
    }
    
}