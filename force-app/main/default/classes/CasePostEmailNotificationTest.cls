/**********************************************************
Test Class: CasePostEmailNotificationTest
LastModifiedBy: Joseph Dag 2/13/2024
Description: This is the test class for sending post notification emails to mentioned users   
Class : CasePostEmailNotification
***********************************************************/

@isTest(SeeAllData=true)
public with sharing class CasePostEmailNotificationTest {
    

    @isTest
    public static void sendEmailtoContactsTest(){

        Case cs = new Case();
        cs.Subject = 'Apex Case Test Class';
        insert cs;

        FeedItem feed = new FeedItem();
        feed.ParentId = cs.Id;
        feed.Body = '2222 Message which you want to post @My Village';
        insert feed;

        List<CasePostEmailNotification.campaignInfos> lstCmpInfos = new List<CasePostEmailNotification.campaignInfos>();  

        CasePostEmailNotification.campaignInfos cmpInfo = new CasePostEmailNotification.campaignInfos();
            cmpInfo.caseId = cs.Id;
            cmpInfo.posId = feed.Id;
            lstCmpInfos.add(cmpInfo);

            Test.startTest();
            CasePostEmailNotification.sendEmailtoContacts(lstCmpInfos);
            Integer numnerOfEmails = Limits.getEmailInvocations();
            Test.stopTest();
    
            System.assertEquals(0, numnerOfEmails);

        }
}