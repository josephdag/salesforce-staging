/**********************************************************
Class: OpportunityTriggerHandlerTest
LastModifiedBy: Bopsy 08/08/2022
Description: This is Test class for the OpportunityTriggerHandler     
***********************************************************/
@isTest
public class OpportunityTriggerHandlerTest {
    
    @TestSetup 
    public static void setup() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE Name =: 'Regional Sales Director' limit 1];
        
        List<User> testUserList = new List<User>();
        
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = testUserRole.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testtest1Bobsystandt@testtest.com');
        testUserList.add(testUser);
        
        UserRole testUserRole2 = [SELECT Id FROM UserRole WHERE Name =: 'Inside Sales Representative' limit 1];
        
        User testUser2 = new User(Alias = 'standt', Email='standardusersec@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = testUserRole2.Id, 
                                  TimeZoneSidKey='America/Los_Angeles', UserName='standardusersec123@testtest.com');
        testUserList.add(testUser2);
        insert testUserList;
        
        
    }
    
    @isTest 
    public static void addOppTeamOwnerChangeTest() {
        
        User testActiveUser = [SELECT Id FROM User WHERE IsActive = true AND UserName = 'testtest1Bobsystandt@testtest.com'];
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        testOpp.StageName = 'Target/Prepare the Market';
        insert testOpp;
        testopp.OwnerId = testActiveUser.Id;
        
        Test.startTest(); 
        update testOpp;
        Test.stopTest();   
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id, UserId, Name FROM OpportunityTeamMember];
        List<Opportunity> testOppAssertion = [SELECT Id, OwnerId, StageName FROM Opportunity];
        
        //Assertion
        System.assertEquals(1, testOTMAssertion.size());
        System.assertEquals(testOTMAssertion[0].UserId, testOppAssertion[0].OwnerId);
    }
    
    @isTest 
    public static void oppNameChangeTest() {
        
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        testOpp.StageName = 'Target/Prepare the Market';
        insert testOpp;
        
        testOpp.Name = 'NewTest1';
        
        Test.startTest(); 
        update testOpp;
        Test.stopTest();   
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id FROM OpportunityTeamMember];
        //Assertion
        System.assertEquals(0,testOTMAssertion.size());
    }
    
    @isTest 
    public static void newOppTeamCreateTest() {
        
        Opportunity testOpp = new  Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp 2';
        testOpp.StageName='Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testopp;
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id FROM OpportunityTeamMember];
        System.assertEquals(0,testOTMAssertion.size());
        
        User testActiveUser = [SELECT Id FROM User WHERE IsActive = true AND UserName = 'testtest1Bobsystandt@testtest.com'];
        testopp.OwnerId = testActiveUser.Id;
        
        test.startTest();
        update testOpp;
        test.stopTest();
        
        List<OpportunityTeamMember> testOTMAssertionSecondList =[SELECT Id, UserId, Name FROM OpportunityTeamMember];
        Opportunity testOppAssertion = [SELECT Id, OwnerId, StageName FROM Opportunity WHERE Name =: 'test opp 2'];
        //Assert
        System.assertEquals(1, testOTMAssertionSecondList.size());
        System.assertEquals(testOTMAssertionSecondList[0].UserId, testOppAssertion.OwnerId);
    }
    
    @isTest 
    public static void newOpp2TeamCreateTest() {
        
        User testActiveUser = [SELECT Id FROM User WHERE IsActive = true AND UserName = 'testtest1Bobsystandt@testtest.com'];
        
        Opportunity testOpp = new  Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp 2';
        testOpp.StageName='Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testopp;
        
        OpportunityTeamMember testOTM = new OpportunityTeamMember();
        testOTM.OpportunityId = testopp.Id;
        testOTM.UserId = testActiveUser.Id;
        testOTM.TeamMemberRole = 'Sales Rep';
        insert testOTM;
        
        testopp.OwnerId = testActiveUser.Id;
        test.startTest();
        update testOpp;
        test.stopTest();
        
        List<OpportunityTeamMember> testOTMAssertionSecondList =[SELECT Id, UserId, Name FROM OpportunityTeamMember];
        Opportunity testOppAssertion = [SELECT Id, OwnerId, StageName FROM Opportunity WHERE Name =: 'test opp 2'];
        //Assert
        System.assertEquals(1, testOTMAssertionSecondList.size());
        System.assertEquals(testOTMAssertionSecondList[0].UserId, testOppAssertion.OwnerId);
    }
    
    @isTest 
    public static void addISROppTeamOwnerChangeTest() {
        
        User testActiveUser = [SELECT Id FROM User WHERE IsActive = true AND Email = 'standardusersec@testorg.com'];
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        testOpp.StageName = 'Target/Prepare the Market';
        insert testOpp;
        testopp.OwnerId = testActiveUser.Id;
        
        Test.startTest(); 
        update testOpp;
        Test.stopTest();   
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id, UserId, Name, TeamMemberRole FROM OpportunityTeamMember];
        List<Opportunity> testOppAssertion = [SELECT Id, OwnerId, StageName FROM Opportunity];
        
        //Assertion
        System.assertEquals(1, testOTMAssertion.size());
        System.assertEquals(testOTMAssertion[0].UserId, testOppAssertion[0].OwnerId);
        System.assertEquals('Sales Rep', testOTMAssertion[0].TeamMemberRole);
    }
}