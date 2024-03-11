/**********************************************************
Class: CaseTriggerHandler 
LastModifiedBy: Cloud Connex 08/01/2023
Description: handler class of CaseTrigger   
TestClass :CaseTriggerHandlerTest
***********************************************************/
public class CaseTriggerHandler {
    
    public static void sendEmailOnFieldChange(List<Case> theCaseList, Map<Id, Case> theOldMap) {
        
        List<EmailWrapper> theWrapperList = new List<EmailWrapper>();
        List<String> theEmailAddressesList = new List<String>();
        Map<String, String> theFieldMap = new Map<String, String>();
        Schema.FieldSet fieldSetObj = Schema.getGlobalDescribe().get('Case').getDescribe().FieldSets.getMap().get('Notification_Fields');
        Set<Id> theUserIdSet = new Set<Id>();
        
        EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name =: 'Case has been Modified HTML'];
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()) {
            
            theFieldMap.put(fieldSetMemberObj.getFieldPath(), fieldSetMemberObj.getLabel());
            
        }
        
        for(Case theCase : theCaseList) {
            
            for(String theField : theFieldMap.keySet()) {
                
                if(theCase.get(theField) != theOldMap.get(theCase.Id).get(theField)) {
                    theUserIdSet.add(theCase.OwnerId);
                } 
                
            }
            
        }
        
        Map<Id, User> theuserMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: theUserIdSet]);
        
        for(Case theCase : theCaseList) {
            
            if(theuserMap.ContainsKey(theCase.OwnerId)) {
                theEmailAddressesList = new List<String>();
                theEmailAddressesList.add(theCase.OwnerId);
                
                String theSubject = theEmailTemplate.Subject;
                theSubject = theSubject.replace('(CaseNumber)', theCase.CaseNumber);
                theEmailTemplate.Subject = theSubject;
                
                String theBody = theEmailTemplate.Body;
                theBody = theBody.replace('(insert Case OwnerId)', theuserMap.get(theCase.OwnerId).Name);
                theBody = theBody.replace('(CaseNumber)', '<a href="'+  URL.getSalesforceBaseUrl().toExternalForm()+'/'+theCase.Id +'">'+theCase.CaseNumber+'</a>');
                Integer theIndex = 1;
                
                for(String theField : theFieldMap.keySet()) {
                    
                    if(theCase.get(theField) != theOldMap.get(theCase.Id).get(theField)) {
                        theBody = theBody + '<br/>';
                        theBody = theBody + theIndex + '. '+ theFieldMap.get(theField) + ' - '+ theCase.get(theField);
                        theIndex++;
                    }
                    
                }
                theEmailTemplate.Body = theBody;
                theWrapperList.add(new EmailWrapper(theEmailTemplate, theEmailAddressesList));
            }
            
        }
        
        if(!theWrapperList.isEmpty())  sendEmail(theWrapperList);
    }
    
    public static void sendEmail(List<EmailWrapper> theWrapperList) {
        List<Messaging.singleEmailMessage> mailList = new List<Messaging.singleEmailMessage>();
        for(EmailWrapper theEmailWrap : theWrapperList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            email.setToAddresses(theEmailWrap.theToAddressList);
            email.setTemplateId(theEmailWrap.thetemplate.Id);
            email.setHtmlBody(theEmailWrap.thetemplate.Body);
            //email.setPlainTextBody(theEmailWrap.thetemplate.Body);
            email.setSubject(theEmailWrap.thetemplate.Subject);
            email.setSaveAsActivity(false);
            mailList.add(email);
        }
        
        if(!mailList.isEmpty()) {
            List<Messaging.SendEmailResult> sendEmailResultList = Messaging.sendEmail(mailList);
        }
        
    }
    
    public class EmailWrapper {
        public EmailTemplate thetemplate;
        public List<String> theToAddressList;
        
        public EmailWrapper(EmailTemplate theTempl, List<String> toAddressList) {
            thetemplate = theTempl;
            theToAddressList = toAddressList;
        }
    }
    
    public static void updateCaseFromRelatedAsset(List<Case> theCaseList, Map<Id,Case> theCaseMap) {
        
        Set<String> theSerialNumberSet = new Set<String>();
        Map<String, Asset> theAssetAndNameMap = new Map<String, Asset>();
        
        for(Case theCase : theCaseList) {
            
            if(theCase.top_level_main_serial_number__c != null && (theCaseMap == null || theCaseMap.get(theCase.Id).top_level_main_serial_number__c != theCase.top_level_main_serial_number__c)) {
                theSerialNumberSet.add(theCase.top_level_main_serial_number__c);
            }
            
        }
        
        List<Asset> theCaseRelatedAsset = [SELECT Id, Opportunity_Type__c, Build_ID__c, Software_Version__c, Description, SerialNumber, Name, Type_of_account__c, AccountId, Scanner_Version_in_Dashboard__c,
                                           Ngrok__c, upload_connect_diagnostics__c, Upload_connect_Hyperfine_PACS__c, Upload_connect_Local_PACS__c, Proxy_server__c, City_of_scanner__c, State_of_scanner__c,
                                           country_of_scanner__c, Telemetry_Upload__c, Device_rawdata_upload__c, Elastic_Filebeat__c, Allow_AI_Processing__c 
                                           FROM Asset WHERE SerialNumber IN: theSerialNumberSet AND SerialNumber != null];
        
        for(Asset theAsset : theCaseRelatedAsset) {
            theAssetAndNameMap.put(theAsset.SerialNumber, theAsset);
        }
        
        for(Case theCase : theCaseList) {
            
            if(theAssetAndNameMap.containskey(theCase.top_level_main_serial_number__c)) {
                theCase.AccountId = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).AccountId;
                theCase.Type = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Type_of_account__c;
                theCase.Scanner_HW_Version__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Description;
                theCase.Software_Version__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Software_Version__c;
                theCase.Build_ID__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Build_ID__c;
                theCase.Opportunity_Type_picklist__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Opportunity_Type__c;
                //Added By Ajith for the PS-3616
                theCase.Scanner_Version_in_Dashboard__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Scanner_Version_in_Dashboard__c;
                theCase.Ngrok__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Ngrok__c;
                theCase.upload_connect_diagnostics__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).upload_connect_diagnostics__c;
                theCase.Upload_connect_Hyperfine_PACS__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Upload_connect_Hyperfine_PACS__c;
                theCase.Upload_connect_Local_PACS__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Upload_connect_Local_PACS__c;
                theCase.Proxy_server__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Proxy_server__c;
                theCase.City_of_scanner__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).City_of_scanner__c;
                theCase.State_of_scanner__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).State_of_scanner__c;
                theCase.country_of_scanner__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).country_of_scanner__c;
                theCase.Telemetry_Upload__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Telemetry_Upload__c;
                theCase.Device_rawdata_upload__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Device_rawdata_upload__c;
                theCase.Elastic_Filebeat__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Elastic_Filebeat__c;
                theCase.Allow_AI_Processing__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Allow_AI_Processing__c;
                theCase.Related_Asset__c = theAssetAndNameMap.get(theCase.top_level_main_serial_number__c).Id;
            } else if(theCase.top_level_main_serial_number__c == null && (theCaseMap ==null || theCaseMap.get(theCase.Id).top_level_main_serial_number__c != theCase.top_level_main_serial_number__c)) {
               theCase.Related_Asset__c = null;
            }
            
        }
        
    }
    
}