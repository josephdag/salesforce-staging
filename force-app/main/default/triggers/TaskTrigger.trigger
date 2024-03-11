trigger TaskTrigger on Task (After insert, After Update, After Delete) {
    
    if(Trigger.IsAfter && Trigger.isDelete) {
        ActivityTriggerHandler.updateNoOfTouchPointOnLead((List<Sobject>)trigger.old,(Map<Id,Sobject>)trigger.oldMap,true);
    }else if(Trigger.IsAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ActivityTriggerHandler.updateNoOfTouchPointOnLead((List<Sobject>)trigger.new,(Map<Id,Sobject>)trigger.oldMap,false);
    }
    
}