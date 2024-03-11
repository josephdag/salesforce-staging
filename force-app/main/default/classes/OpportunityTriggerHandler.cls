/**********************************************************
Class: OpportunityTriggerHandler 
LastModifiedBy: Bopsy 07/27/2021
Description: This is the handler class for Opportunity Trigger    
TestClass : OpportunityTriggerHandlerTest
***********************************************************/
public class OpportunityTriggerHandler {
    
    public static void addOppTeam(List<Opportunity> theNewOppList, Map<Id, Opportunity> theOldMap) {
        
        List<Opportunity> theOwnerChangedOppList = new List<Opportunity>();
        List<OpportunityTeamMember> theOTMForInsertTeam = new List<OpportunityTeamMember>();
        Map<Id, List<Id>> theOppId_TeamMemberIdList = new Map<Id, List<Id>>();
        List<Id> theOppOwnerIdList = new List<Id>();
        for(Opportunity theNewOpp : theNewOppList) {
            
            if(theOldMap != null && theNewOpp.OwnerId != theOldMap.get(theNewOpp.Id).OwnerId) {
                theOwnerChangedOppList.add(theNewOpp);
                theOppOwnerIdList.add(theNewOpp.OwnerId);
            }
            
        }
        List<OpportunityTeamMember> theOTMList = [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN: theOwnerChangedOppList];
        Map<Id, User> theUserMap = new Map<Id, User>([SELECT Id, UserRole.Name FROM User WHERE Id IN: theOppOwnerIdList]);
        
        for(OpportunityTeamMember theOTM: theOTMList) {
            
            if(!theOppId_TeamMemberIdList.Containskey(theOTM.OpportunityId)) {
                theOppId_TeamMemberIdList.put(theOTM.OpportunityId, new List<Id>{theOTM.UserId});
            } else {
                theOppId_TeamMemberIdList.get(theOTM.OpportunityId).add(theOTM.UserId);
            }
            
        }
        
        List<String> theSalesRepRoleStringList = new List<String>{'Regional Sales Director',  'Senior Sales Director - East', 'Senior Sales Director - West', 'Inside Sales Representative'};
            
            for(Opportunity theOpp : theOwnerChangedOppList) {
                
                if(!theOppId_TeamMemberIdList.ContainsKey(theOpp.Id) || (theOppId_TeamMemberIdList.ContainsKey(theOpp.Id) && !theOppId_TeamMemberIdList.get(theOpp.Id).Contains(theOpp.OwnerId)) ) {
                    if(theSalesRepRoleStringList.Contains(theUserMap.get(theOpp.OwnerId).UserRole.Name)) {
                        OpportunityTeamMember theOTM = new OpportunityTeamMember();
                        theOTM.OpportunityId = theOpp.Id;
                        theOTM.UserId = theOpp.OwnerId;
                        theOTM.TeamMemberRole = 'Sales Rep';
                        theOTMForInsertTeam.add(theOTM);
                    }
                }
                
            }
        
        if(!theOTMForInsertTeam.isEmpty()) insert theOTMForInsertTeam;
    }
    
}