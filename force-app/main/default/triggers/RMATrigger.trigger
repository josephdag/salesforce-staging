trigger RMATrigger on RMA__c (before insert, before update) {
    if(trigger.isBefore && trigger.isUpdate) {
        RMATriggerHandler.checkForRMAShipmentChanges(trigger.new, trigger.oldmap, trigger.newmap);
    }
}