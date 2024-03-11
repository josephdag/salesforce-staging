/**********************************************************
Class: BatchUpdateAcntOwnerWithTerriOwnerTest
LastModifiedBy: Bopsy 08/08/2022
Description: This is Test class for the BatchUpdateAcntOwnerWithTerriOwner     
***********************************************************/
@istest
public class BatchUpdateAcntOwnerWithTerriOwnerTest {
    
    @testSetup
    public static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name =: 'System Administrator']; 
        User u = new User(Alias = 'standt', Email='testOrg@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUserOnly123455@testorg.com');
        Territory2 testTerritory ;
        User testUser; 
        System.runAs(u) {    
            List<Account> testAcntListToInsert = new List<Account>();
            for(Integer i =0; i < 1; i++) {
                Account testAcc = new Account();
                testAcc.name = 'Test Update Acount';
                testAcc.Phone = '8866674854454';
                testAcc.Website = 'testAcc.com';
                testAcc.BillingCity = 'Summit';
                testAcc.BillingCountry = 'United States';
                testAcc.BillingState = 'New Jersey';
                testAcc.BillingStreet = '11 Overlook Road';
                testAcc.BillingPostalCode = '07901';
                testAcntListToInsert.add(testAcc);
            }
            insert testAcntListToInsert;
            
            Territory2Type testTerritoryType = [SELECT Id, DeveloperName FROM Territory2Type WHERE DeveloperName =: 'Territory_by_State'];
            Territory2Model terrModel;
            terrModel = [SELECT Id, DeveloperName, Name FROM Territory2Model WHERE DeveloperName =: 'Hyperfine_Territory_Model_V3'];
            if(terrModel == null) {
                terrModel = new Territory2Model();
                terrModel .DeveloperName = 'Hyperfine_Territory_Model_V3';
                terrModel.Name = 'Hyperfine Territory Model V3';
                insert terrModel ;
            }        
            
            testTerritory = new Territory2();
            testTerritory.AccountAccessLevel =  'EDIT';
            testTerritory.CaseAccessLevel = 'EDIT';
            testTerritory.OpportunityAccessLevel = 'READ';
            testTerritory.DeveloperName = 'United_Kingdom1';
            testTerritory.Name = 'United Kingdom1';
            testTerritory.Territory2ModelId = terrModel.Id;
            testTerritory.Territory2TypeId = testTerritoryType.Id;
            insert testTerritory;
        }
        
        UserTerritory2Association testUserTerrAssociation = new UserTerritory2Association();
        testUserTerrAssociation.Territory2Id = testTerritory.Id;
        testUserTerrAssociation.UserId = UserInfo.getUserId();
        insert testUserTerrAssociation;
        
    }
    
    @istest
    public static void testToUpdateAcntOwnerIdWithTerritoryOwner(){
        
        List<Account> testAcntList = [SELECT Id, OwnerId, Owner.Name FROM Account];
        
        Territory2 testTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName =: 'United_Kingdom1'];
        List<Group> theListOfGroupWithTerritory = [SELECT Id, RelatedId FROM Group WHERE Type='Territory' AND RelatedId =: testTerritory.Id];
        
        List<AccountShare> testAcntSharetoInsert = new List<AccountShare>();
        for(Account testAcnt : testAcntList){
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = testAcnt.Id;
            accountShare.UserOrGroupId = theListOfGroupWithTerritory[0].Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'EDIT';      
            testAcntSharetoInsert.add(accountShare);
        }
        insert testAcntSharetoInsert;
        
        test.startTest();
        BatchUpdateAcntOwnerWithTerriOwner testBatch = new BatchUpdateAcntOwnerWithTerriOwner();
        database.executeBatch(testBatch);
        test.stopTest();
        
        List<Account> testAcntforAssertion = [SELECT Id, OwnerId FROM Account];
        for(Account testAcnt : testAcntforAssertion) {
            system.assertNotEquals(Userinfo.getUserId(), testAcnt.OwnerId);
        }
    }
    
    @istest
    public static void testToUpdateAcntOwnerIdWithTerritoryOwnerSchdulable(){
        
        List<Account> testAcntList = [SELECT Id, OwnerId, Owner.Name FROM Account];
        
        Territory2 testTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName =: 'United_Kingdom1'];
        List<Group> theListOfGroupWithTerritory = [SELECT Id, RelatedId FROM Group WHERE Type='Territory' AND RelatedId =: testTerritory.Id];
        
        List<AccountShare> testAcntSharetoInsert = new List<AccountShare>();
        for(Account testAcnt : testAcntList){
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = testAcnt.Id;
            accountShare.UserOrGroupId = theListOfGroupWithTerritory[0].Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'EDIT';      
            testAcntSharetoInsert.add(accountShare);
            
        }
        insert testAcntSharetoInsert;
        
        test.startTest();
        BatchUpdateAcntOwnerWithTerriOwner testBatch = new BatchUpdateAcntOwnerWithTerriOwner();
        testBatch.execute(null);
        test.stopTest();
        
        List<Account> testAcntforAssertion = [SELECT Id, OwnerId FROM Account];
        for(Account testAcnt : testAcntforAssertion) {
            system.assertNotEquals(Userinfo.getUserId(), testAcnt.OwnerId);
        }
    }
    
    @istest
    public static void testToUpdateAcntOwnerIdWithTerritoryOwnerParametrized(){
        
        List<Account> testAcntList = [SELECT Id, OwnerId, Owner.Name FROM Account];
        
        Territory2 testTerritory = [SELECT Id FROM Territory2 WHERE DeveloperName =: 'United_Kingdom1'];
        List<Group> theListOfGroupWithTerritory = [SELECT Id, RelatedId FROM Group WHERE Type='Territory' AND RelatedId =: testTerritory.Id];
        Set<Id> theAcntIds = new Set<Id>();
        List<AccountShare> testAcntSharetoInsert = new List<AccountShare>();
        for(Account testAcnt : testAcntList){
            AccountShare accountShare = new AccountShare();
            accountShare.AccountId = testAcnt.Id;
            accountShare.UserOrGroupId = theListOfGroupWithTerritory[0].Id;
            accountShare.AccountAccessLevel = 'Edit';
            accountShare.CaseAccessLevel = 'Edit';
            accountShare.OpportunityAccessLevel = 'EDIT';      
            testAcntSharetoInsert.add(accountShare);
            theAcntIds.add(testAcnt.Id);
            
        }
        insert testAcntSharetoInsert;
        
        test.startTest();
        BatchUpdateAcntOwnerWithTerriOwner testBatch = new BatchUpdateAcntOwnerWithTerriOwner(theAcntIds);
        database.executeBatch(testBatch);
        test.stopTest();
        
        List<Account> testAcntforAssertion = [SELECT Id, OwnerId FROM Account];
        for(Account testAcnt : testAcntforAssertion) {
            system.assertNotEquals(Userinfo.getUserId(), testAcnt.OwnerId);
        }
    }
}