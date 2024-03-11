trigger FeedItemTrigger on FeedItem (after insert) {

    FeedItemTriggerHandler.sendMailToCaseOwner(trigger.new);
    
}