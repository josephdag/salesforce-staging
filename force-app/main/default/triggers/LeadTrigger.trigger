trigger LeadTrigger on Lead (after Update) {
    
    LeadTriggerHandler.leadOpportunityAddOppTeam(trigger.new, trigger.oldMap);
    
}