/**********************************************************
Class: SetupAuditschedulableBatch 
LastModifiedBy: Cloud Connex 04/27/2023
Description: batch class to send the excel email to the current user for setupAudittrail record.
TestClass : SetupAuditschedulableBatchTest
***********************************************************/
public class SetupAuditschedulableBatch implements database.batchable<SObject>, Schedulable, Database.Stateful{
    
    public string query;
    public List<SetupAuditTrail> theAllSetupAuditTrailList = new List<SetupAuditTrail>();
    
    public SetupAuditschedulableBatch() {
        query = 'SELECT Id, Action, Display, Section, CreatedDate, CreatedBy.UserName, DelegateUser, ResponsibleNamespacePrefix, CreatedByContext, CreatedByIssuer FROM SetupAuditTrail WHERE CreatedDate = THIS_QUARTER ORDER BY CreatedDate DESC'+(Test.isRunningTest()?' LIMIT 200':'');
    }
    
    public SetupAuditschedulableBatch(String query) {
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SetupAuditTrail> theSetupAuditTrailList){     
        
        theAllSetupAuditTrailList.addAll(theSetupAuditTrailList);
        
    }
    
    public void finish(Database.BatchableContext bc){
        
        String theExcelLine = '';
        for(SetupAuditTrail theSetupAudit : theAllSetupAuditTrailList){
            theExcelLine += theSetupAudit.CreatedDate + ',' + theSetupAudit.CreatedBy.UserName + ',' + theSetupAudit.Section + ',' + theSetupAudit.Action + ',' + theSetupAudit.Display+'\n';
        }
        
        String contentForExcel = 'Timestamp, User, Section, Action, Details \n' + theExcelLine;
        SetupAuditTrailEmail__c theEmails = SetupAuditTrailEmail__c.getValues('Audit Trail Emails');
        List<String> theEmailList = new List<String>();
        if(theEmails != null){
            List<String> res = theEmails.Emails__c.split(',', 0);
            theEmailList.addAll(res);
        }
        theEmailList.add(userInfo.getUserEmail());

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = theEmailList;
        message.subject = 'All information from SetupAuditTrail object';
        message.plainTextBody = '';
        Messaging.EmailFileAttachment theAttachment = new Messaging.EmailFileAttachment();
        theAttachment.setFileName('SetupAuduitTrial.csv');
        theAttachment.setBody(Blob.valueOf(contentForExcel));
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{theAttachment});
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
        
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SetupAuditschedulableBatch(), 200);
        
    }
}