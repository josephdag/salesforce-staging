/**********************************************************
Class: FeedItemTriggerHandler 
LastModifiedBy: Bopsy 03/29/2022
Description: Handler class for FeedItemTrigger
***********************************************************/
public class FeedItemTriggerHandler {
    
    public static void sendMailToCaseOwner(List<FeedItem> theFeedItemList) {
        
        List<String> theEmailAddressesList = new List<String>();
        List<CaseTriggerHandler.EmailWrapper> theWrapperList = new List<CaseTriggerHandler.EmailWrapper>();
        EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name =: 'EmailToCaseOwnerOnPost'];
        Set<Id> theCaseIdSet = new Set<Id>();
        Set<Id> theUserIdSet = new Set<Id>();
        List<FeedItem> theFeedItemForCaseList = new List<FeedItem>();
        
        for(FeedItem theFI : theFeedItemList) {
            
            if(theFI.ParentId != null && String.valueOf(theFI.ParentId).startsWith('500') && theFI.Type == 'TextPost') {
                theCaseIdSet.add(theFI.ParentId);
                theFeedItemForCaseList.add(theFI);  
                theUserIdSet.add(theFI.CreatedById);
            }
            
        }
        if(!theCaseIdSet.isEmpty()) {
            Map<Id, User> theuserMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: theUserIdSet]);
            Map<Id, Case> theCaseIdMap =  new Map<Id, Case>([SELECT Id, OwnerId, Owner.Name, CaseNumber FROM Case WHERE Id IN: theCaseIdSet]);
            
            for(FeedItem theFI : theFeedItemForCaseList) {
                theEmailAddressesList = new List<String>();
                if(String.valueOf(theCaseIdMap.get(theFI.ParentId).OwnerId).startsWith('00G')) {
                    theEmailAddressesList.add('support@hyperfine.io');
                }else{
                    theEmailAddressesList.add(theCaseIdMap.get(theFI.ParentId).OwnerId);
                }
                                
                String theSubject = theEmailTemplate.Subject;
                theSubject = theSubject.replace('(Case Number)', theCaseIdMap.get(theFI.ParentId).CaseNumber);
                theEmailTemplate.Subject = theSubject;
                String theBody = theEmailTemplate.Body;
                if(theCaseIdMap.Containskey(theFI.ParentId) && theCaseIdMap.get(theFI.ParentId) != null && theCaseIdMap.get(theFI.ParentId).Owner != null) theBody = theBody.replace('(Insert Case OwnerId)', theCaseIdMap.get(theFI.ParentId).Owner.Name);
                theBody = theBody.replace('(CaseNumber)', '<a href="'+  URL.getSalesforceBaseUrl().toExternalForm()+'/'+theFI.ParentId+'">'+theCaseIdMap.get(theFI.ParentId).CaseNumber+'</a>');
                theBody = theBody.replace('(Post OwnerId)', theuserMap.get(theFI.CreatedById).Name);
                theBody = theBody.replace('(Post Description)', theFI.Body);
                
                theEmailTemplate.Body = theBody;
                theWrapperList.add(new CaseTriggerHandler.EmailWrapper(theEmailTemplate, theEmailAddressesList));
            }
            
            if(!theWrapperList.isEmpty())  CaseTriggerHandler.sendEmail(theWrapperList);
        }
    }
    
}