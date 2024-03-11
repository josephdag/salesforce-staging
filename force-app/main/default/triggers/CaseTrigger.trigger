trigger CaseTrigger on Case (after Update , before insert, before update) {

    if(trigger.isAfter && trigger.isUpdate){
        CaseTriggerHandler.sendEmailOnFieldChange(trigger.new, trigger.oldMap);
    }
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        CaseTriggerHandler.updateCaseFromRelatedAsset(trigger.new,trigger.oldmap);
    }
}