/*******************************************************
//Class: ActivityTriggerHandlerTest
//Created By: Bopsy Team
//Last Modified by: Bopsy Team {12/08/2021}
//Description: This is the test class for ActivityTriggerHandler 
/*******************************************/
@isTest
public class ActivityTriggerHandlerTest {
    
    @TestSetup
    public static void setup() {
        
        Lead testLead = new Lead();
        testLead.FirstName = 'James';
        testLead.LastName = 'Dane';
        testLead.Company = 'Test Company';
        insert testLead;
        
    }
    
    @isTest
    public static void updateNoOfTouchPointOnLeadTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Event testEvent = new Event();
        testEvent.WhoId = testLead.id;
        testEvent.StartDateTime = system.today();
        testEvent.EndDateTime = system.today()+5;
        
        test.startTest();
        insert testEvent;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(1, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void taskNoOfTouchPointOnLeadTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Task testTask = new Task();
        testTask.Subject='Donni';
        testTask.Status='Not Started';
        testTask.Priority='Normal';
        testTask.WhoId = testLead.Id;       
        
        test.startTest();
        insert testTask;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(1, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void taskEventOnLeadTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Task testTask = new Task();
        testTask.Subject='Donni';
        testTask.Status='Not Started';
        testTask.Priority='Normal';
        testTask.WhoId = testLead.Id;       
        
        Event testEvent = new Event();
        testEvent.WhoId = testLead.id;
        testEvent.StartDateTime = system.today();
        testEvent.EndDateTime = system.today()+5;
        insert testEvent;
        
        test.startTest();
        insert testTask;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(2, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void eventDeleteOnLeadTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Task testTask = new Task();
        testTask.Subject='Donni';
        testTask.Status='Not Started';
        testTask.Priority='Normal';
        testTask.WhoId = testLead.Id;       
        insert testTask;
        
        Event testEvent = new Event();
        testEvent.WhoId = testLead.id;
        testEvent.StartDateTime = system.today();
        testEvent.EndDateTime = system.today()+5;
        insert testEvent;
        
        test.startTest();
        delete testEvent;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(1, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void taskDeleteOnLeadTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Task testTask = new Task();
        testTask.Subject='Donni';
        testTask.Status='Not Started';
        testTask.Priority='Normal';
        testTask.WhoId = testLead.Id;       
        insert testTask;
        
        Event testEvent = new Event();
        testEvent.WhoId = testLead.id;
        testEvent.StartDateTime = system.today();
        testEvent.EndDateTime = system.today()+5;
        insert testEvent;
        
        test.startTest();
        delete testTask;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(1, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void removeLeadOnEventTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        
        Event testEvent = new Event();
        testEvent.WhoId = testLead.id;
        testEvent.StartDateTime = system.today();
        testEvent.EndDateTime = system.today()+5;
        insert testEvent;
        
        Task testTask = new Task();
        testTask.Subject='Donni';
        testTask.Status='Not Started';
        testTask.Priority='Normal';
        testTask.WhoId = testLead.Id;       
        insert testTask;
        
        test.startTest();
        testEvent.WhoId = null;
        update testEvent;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(1, testAssertLead.of_Touchpoints__c);
    }
    
    @isTest
    public static void bulkEventAndTaskTest() {
        
        Lead testLead = [SELECT Id FROM Lead];
        List<Event> testEventList = new List<Event>();
        List<Task> testTaskList = new List<Task>();
        
        for(Integer i = 0 ; i < 10; i++) {
            
            Event testEvent = new Event();
            testEvent.WhoId = testLead.id;
            testEvent.StartDateTime = system.today();
            testEvent.EndDateTime = system.today()+i;
            testEventList.add(testEvent);
            
            Task testTask = new Task();
            testTask.Subject='Donni' + i;
            testTask.Status='Not Started';
            testTask.Priority='Normal';
            testTask.WhoId = testLead.Id; 
            testTaskList.add(testTask);
            
        }
        
        test.startTest();
        insert testEventList;
        insert testTaskList;
        test.stopTest();
        
        //Assertions
        Lead testAssertLead = [SELECT Id, of_Touchpoints__c FROM Lead];
        System.assertEquals(20, testAssertLead.of_Touchpoints__c);
    }
    
}