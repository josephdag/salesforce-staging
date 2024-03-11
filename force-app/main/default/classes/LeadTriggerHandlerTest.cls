/**********************************************************
Class: LeadTriggerHandlerTest 
LastModifiedBy: Bopsy 08/08/2022
Description: This is the test class for LeadTriggerHandler
***********************************************************/
@isTest
public class LeadTriggerHandlerTest {
    
    @TestSetup 
    public static void setup() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
        UserRole testUserRole = [SELECT Id FROM UserRole WHERE Name =: 'Regional Sales Director' limit 1];
        UserRole testISRUserRole = [SELECT Id FROM UserRole WHERE Name =: 'Inside Sales Representative' limit 1];
        
        List<User> testUserList = new List<User>();
        
        User testUser = new User(Alias = 'standt', Email='ISRstandarduser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = testISRUserRole.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='ISRtesttest1@testtest.com');
        testUserList.add(testUser);
        
        User testRSDUser = new User(Alias = 'standt', Email='RSDstandarduser@testorg.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = testProfile.Id, UserRoleId = testUserRole.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='RSDtesttest1@testtest.com');
        testUserList.add(testRSDUser);
        
        User testUser2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = testProfile.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testtest1Bobsystandt@testtest.com');
        testUserList.add(testUser2);
        
        insert testUserList;
    }
    
    @isTest
    public static void leadOpportunityAddISROppTeamTest(){
        
        User testUser = [SELECT Id FROM User WHERE Email = : 'ISRstandarduser@testorg.com']; 
        
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
        
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Sample';
        testLead.Company = 'Testing Sample Co'; 
        testLead.OwnerId = testUser.ID;
        testLead.Phone = '8866674854454';
        testLead.Website = 'testAcc.com';
        testLead.city = 'Summit';
        testLead.Country = 'United States';
        testLead.State = 'New Jersey';
        testLead.Street = '11 Overlook Road';
        testLead.PostalCode = '07901';
        insert testLead;
        
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = System.today();
        testOpp.Name = 'test opp';
        testOpp.AccountId = testAcc.Id;
        //testOpp.StageName = 'Qualification';
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;
        
        Database.LeadConvert lc = new database.LeadConvert();
        leadStatus convertStatus = [SELECT Id, APIName FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.APIName);
        lc.setLeadId(testLead.Id);
        lc.setOpportunityId(testOpp.Id);
        lc.setAccountId(testAcc.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id, UserId, TeamMemberRole FROM OpportunityTeamMember];
        
        //Assert
        System.assertEquals(1, testOTMAssertion.size());
        System.assertEquals('Inside Sales Rep', testOTMAssertion[0].TeamMemberRole);
        
    }
    
    @isTest
    public static void leadOpportunityAddSROppTeamCreateTest(){
        
        User testUser = [SELECT Id FROM User WHERE UserName =: 'RSDtesttest1@testtest.com'];

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
        //testOpp.StageName = 'Qualification';
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;        
        
        Lead testLead = new Lead();
        testLead.FirstName = 'James';
        testLead.LastName = 'Dane';
        testLead.Company = 'Test Company';
        testLead.LeadSource = 'GetTimely Online';
        testLead.OwnerId = testUser.Id;
        testLead.Phone = '8866674854454';
        testLead.Website = 'testAcc.com';
        testLead.city = 'Summit';
        testLead.Country = 'United States';
        testLead.State = 'New Jersey';
        testLead.Street = '11 Overlook Road';
        testLead.PostalCode = '07901';
        testLead.Status = 'New';
        
        Test.startTest(); 
        insert testLead;
        Test.stopTest();
        
        Database.LeadConvert lc = new database.LeadConvert();
        leadStatus convertStatus = [SELECT Id, APIName FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.APIName);
        lc.setLeadId(testLead.Id);
        lc.setOpportunityId(testOpp.Id);
        lc.setAccountId(testAcc.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        List<OpportunityTeamMember> testOTMAssertion =[SELECT Id, UserId, TeamMemberRole FROM OpportunityTeamMember];
        //Assert
        System.assertEquals(1, testOTMAssertion.size());
        System.assertEquals('Sales Rep', testOTMAssertion[0].TeamMemberRole);
        
    }
    
    @isTest
    public static void leadOpportunityAddNoRoleOppTeamTest(){
        User testUser = [SELECT Id FROM User WHERE UserName =: 'RSDtesttest1@testtest.com'];
        
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
        //testOpp.StageName = 'Qualification';
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;
        
        Lead testLead = new Lead();
        testLead.FirstName = 'James';
        testLead.LastName = 'Dane';
        testLead.Company = 'Test Company';
        testLead.LeadSource = 'GetTimely Online';
        testLead.OwnerId = testUser.Id;
        testLead.Phone = '8866674854454';
        testLead.Website = 'testAcc.com';
        testLead.city = 'Summit';
        testLead.Country = 'United States';
        testLead.State = 'New Jersey';
        testLead.Street = '11 Overlook Road';
        testLead.PostalCode = '07901';
        testLead.Status = 'New';
        insert testLead;
        
        User testUser2 = [SELECT Id FROM User WHERE UserName =: 'testtest1Bobsystandt@testtest.com'];     
        testLead.OwnerId = testUser2.Id;
        update testLead;
        
        test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        leadStatus convertStatus = [SELECT Id, APIName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.APIName);
        lc.setLeadId(testLead.Id);
        lc.setOpportunityId(testOpp.Id);
         lc.setAccountId(testAcc.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        test.stopTest();
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id, UserId FROM OpportunityTeamMember];
        //Assert
        System.assertEquals(0, testOTMAssertion.size());
    }
    
    @isTest
    public static void leadOppAlreadyAddOppTeamUpdateTest(){
        User testUser = [SELECT Id FROM User WHERE Email = : 'ISRstandarduser@testorg.com']; 
        
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
        //testOpp.StageName = 'Qualification';
        testOpp.StageName = 'Target/Prepare the Market';
        testOpp.Use_Case__c  = 'Stroke';
        testOpp.Other_Use_Cases__c = 'Test Use';
        testOpp.Site_of_Care__c  = 'ICU';
        testOpp.Amount = 1000;
        insert testOpp;
        
        OpportunityTeamMember testOTM = new OpportunityTeamMember();
        testOTM.OpportunityId = testOpp.Id;
        testOTM.UserId = testUser.Id;
        testOTM.TeamMemberRole = 'Sales Rep';
        insert testOTM;
        
        Lead testLead = new Lead();
        testLead.FirstName = 'James';
        testLead.LastName = 'Dane';
        testLead.Company = 'Test Company';
        testLead.LeadSource = 'GetTimely Online';
        testLead.OwnerId = testUser.Id;
        testLead.Status = 'New';
        insert testLead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        leadStatus convertStatus = [SELECT Id, APIName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.APIName);
        lc.setLeadId(testLead.Id);
        lc.setOpportunityId(testOpp.Id);
        lc.setAccountId(testAcc.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        List<OpportunityTeamMember> testOTMAssertion = [SELECT Id, UserId FROM OpportunityTeamMember];
        List<Opportunity> Opp = [SELECT Id FROM Opportunity];
        //Assert
        System.assertEquals(1, Opp.size());
        System.assertEquals(1, testOTMAssertion.size());
    }
    
}