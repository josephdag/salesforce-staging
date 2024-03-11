/**********************************************************
Class: CasePostEmailNotification
LastModifiedBy: Joseph Dag 2/1/2024
Description: This is the class for sending post notification emails to mentioned users   
TestClass : CasePostEmailNotificationTest
***********************************************************/


public with sharing class CasePostEmailNotification {

    @InvocableMethod (label = 'Send Chatter Email' 
                      description = 'Sens Email for Chatter' 
                      category = 'Chatter Email')
    public static void sendEmailtoContacts(List<campaignInfos> emailInfos){
        system.debug('inside of method 1');
        Id postId = emailInfos[0].posId;
        Id csId = emailInfos[0].caseId;
        Set<Id> setUsrId = new Set<Id>();
        String communityId = null;
        List<String> lstEmail = new List<String>();
        Case parentCase = [SELECT Id, AccountId, Account.Name, Subject FROM Case WHERE Id=:csId LIMIT 1];
        ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(communityId, postId);
        
        List < ConnectApi.MessageSegment > messageSegments = feedItem.body.messageSegments;
        for ( ConnectApi.MessageSegment messageSegment : messageSegments ) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = ( ConnectApi.MentionSegment ) messageSegment;
                setUsrId.add(mentionSegment.record.Id);
            }
        }
        List<User> userEmails = [SELECT Id, Email FROM User WHERE Id IN: setUsrId];
        for (User usr : userEmails) {
            lstEmail.add(usr.Email);
        }
        String recordPageLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+csId+'">Case Record Page Detail</a><br/>';
        String commentLink = '<a href="'+ URL.getOrgDomainURL().toExternalForm()+'/'+postId+'">Post Comment</a><br/>Thank you';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Chatter Post Email Notification');
        email.setHtmlBody('You Have a new Chatter Post on the Case record, <br/> Case Subject : '+ parentCase.Subject+ '<br/> Case Account Name: '+ parentCase.Account.Name+'<br/> Please click the link below to view the details of the Case record. <br/>'+recordPageLink + 'You can click the link below to add a comment to the post <br/>'+commentLink);
        email.SetToaddresses(lstEmail);
        system.debug('inside of method 1'+ lstEmail);


        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        } catch (Exception ex) {
            system.debug(ex.getMessage());
        }
    }
    public class campaignInfos{
        @InvocableVariable(label = 'caseId' Description = 'caseId' required = true)
        public Id caseId;
        @InvocableVariable(label = 'posId' Description = 'posId' required = true)
        public Id posId;
    }

}