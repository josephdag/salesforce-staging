trigger OpportunityTrigger on Opportunity (after Update) {
    
    OpportunityTriggerHandler.addOppTeam(trigger.new, trigger.oldMap);
    
}