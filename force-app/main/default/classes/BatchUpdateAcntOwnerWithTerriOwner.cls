/**********************************************************
Class: BatchUpdateAcntOwnerWithTerriOwner 
LastModifiedBy: Bopsy 01/17/2022
Description: Batch class to updates the Account Owner with the related territory owner
TestClass : BatchUpdateAcntOwnerWithTerriOwnerTest
***********************************************************/
global class BatchUpdateAcntOwnerWithTerriOwner implements database.batchable<SObject>,Schedulable {
    
    Set<Id> theAcntIds = new Set<Id>();
    global BatchUpdateAcntOwnerWithTerriOwner(){
        
    }
    
    global BatchUpdateAcntOwnerWithTerriOwner(Set<Id> theAcntIds){
        this.theAcntIds = theAcntIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, OwnerId FROM Account ';  
        if(!theAcntIds.isEmpty()){
            query += 'WHERE Id IN :theAcntIds';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.BatchableContext BC, List<Account> theAccList) { 
        
        Map<Id,Id> theAcntWithUserGroupIdMap = new Map<Id,Id>();
        Map<Id,Id> theMapOfgroup = new Map<Id,Id>();
        Map<Id,Id> theTerritoryWithUserMap = new Map<Id,Id>();
        Map<Id,Account> theAcntToUpdates = new Map<Id,Account>();
        
        List<AccountShare> theListOfAcntShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE (RowCause = 'Territory' OR RowCause = 'TerritoryManual') AND AccountId IN : theAccList];
        for(AccountShare theAcntShare : theListOfAcntShare){
            theAcntWithUserGroupIdMap.put(theAcntShare.AccountId, theAcntShare.UserOrGroupId);        
        }       
        
        List<Group> theListOfGroupWithTerritory = [SELECT Id, RelatedId FROM Group WHERE Type='Territory' AND Id IN: theAcntWithUserGroupIdMap.Values()];
        for(Group theGroup : theListOfGroupWithTerritory){
            theMapOfgroup.put(theGroup.Id, theGroup.RelatedId);        
        }
        
        List<UserTerritory2Association> theUserTerritoryList = [SELECT UserId, Territory2Id, IsActive, Id FROM UserTerritory2Association WHERE IsActive = true AND Territory2Id IN : theMapOfgroup.values()];
        for(UserTerritory2Association theUserTerritory : theUserTerritoryList) {
            theTerritoryWithUserMap.put(theUserTerritory.Territory2Id, theUserTerritory.UserId);              
        }   
        
        for(Account theAcnt : theAccList) {
            
            if(theAcntWithUserGroupIdMap.Containskey(theAcnt.Id) && theAcnt.OwnerId != theTerritoryWithUserMap.get(theMapOfgroup.get(theAcntWithUserGroupIdMap.get(theAcnt.Id))) ){
                theAcnt.OwnerId = theTerritoryWithUserMap.get(theMapOfgroup.get(theAcntWithUserGroupIdMap.get(theAcnt.Id)));
                theAcntToUpdates.put(theAcnt.Id,theAcnt);
            }
            
        }
        
        if(!theAcntToUpdates.isEmpty()) update theAcntToUpdates.values();
        
    }
    
    global void finish(database.BatchableContext BC){
        
    }   
    
    global void execute(SchedulableContext sc) {
        BatchUpdateAcntOwnerWithTerriOwner thebatch = new BatchUpdateAcntOwnerWithTerriOwner();
        database.executeBatch(thebatch);
    }
}