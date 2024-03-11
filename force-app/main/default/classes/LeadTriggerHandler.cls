/**********************************************************
Class: LeadTriggerHandler 
LastModifiedBy: Bopsy 07/21/2021
Description: This is the handler class for Lead Trigger    
TestClass : LeadTriggerHandlerTest
***********************************************************/
public class LeadTriggerHandler {
    
    public static void leadOpportunityAddOppTeam(List<Lead> theNewLeadList, Map<Id, Lead> theOldMap) {
        
        Map<Lead, Id> theConvertedLeadId_OppMap = new Map<Lead, Id>();
        Map<Id, List<Id>> theOppId_TeamMemberIdList = new Map<Id, List<Id>>();
        List<OpportunityTeamMember> theOTMForInsertTeam = new List<OpportunityTeamMember>();
        List<Id> theLeadOwnerIdList = new List<Id>();
        
        for(Lead theLead : theNewLeadList) {
            
            if(theOldMap != null && theOldMap.get(theLead.Id).IsConverted != theLead.IsConverted && theLead.IsConverted && theLead.ConvertedOpportunityId != null) {
                theConvertedLeadId_OppMap.put(theLead, theLead.ConvertedOpportunityId);
                theLeadOwnerIdList.add(theLead.OwnerId);
            }
            
        }
       
        Map<Id, User> theUserMap = new Map<Id, User>([SELECT Id, UserRole.Name FROM User WHERE Id IN: theLeadOwnerIdList]);
        
        List<OpportunityTeamMember> theOTMList = [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN: theConvertedLeadId_OppMap.values()];
        for(OpportunityTeamMember theOTM: theOTMList) {
            
            if(!theOppId_TeamMemberIdList.Containskey(theOTM.OpportunityId)) {
                theOppId_TeamMemberIdList.put(theOTM.OpportunityId, new List<Id>{theOTM.UserId});
            } else {
                theOppId_TeamMemberIdList.get(theOTM.OpportunityId).add(theOTM.UserId);
            }
            
        }
        
        List<String> theSalesRepRoleStringList = new List<String>{'Regional Sales Director',  'Senior Sales Director - East', 'Senior Sales Director - West'};
        for(Lead theLead : theConvertedLeadId_OppMap.Keyset()) {
            
            if(!theOppId_TeamMemberIdList.ContainsKey(theLead.ConvertedOpportunityId) || (theOppId_TeamMemberIdList.ContainsKey(theLead.ConvertedOpportunityId) && !theOppId_TeamMemberIdList.get(theConvertedLeadId_OppMap.get(theLead)).Contains(theLead.OwnerId)) ) {
                
                if(theUserMap.get(theLead.OwnerId).UserRole.Name == 'Inside Sales Representative') {
                    OpportunityTeamMember theOTM = new OpportunityTeamMember();
                    theOTM.OpportunityId = theConvertedLeadId_OppMap.get(theLead);
                    theOTM.UserId = theLead.OwnerId;
                    theOTM.TeamMemberRole = 'Inside Sales Rep';
                    theOTMForInsertTeam.add(theOTM);
                } else if(theSalesRepRoleStringList.Contains(theUserMap.get(theLead.OwnerId).UserRole.Name)) {
                    OpportunityTeamMember theOTM = new OpportunityTeamMember();
                    theOTM.OpportunityId = theConvertedLeadId_OppMap.get(theLead);
                    theOTM.UserId = theLead.OwnerId;
                    theOTM.TeamMemberRole = 'Sales Rep';
                    theOTMForInsertTeam.add(theOTM);
                }
                
            }
            
        }
        
        if(!theOTMForInsertTeam.isEmpty()) insert theOTMForInsertTeam;
    }
}