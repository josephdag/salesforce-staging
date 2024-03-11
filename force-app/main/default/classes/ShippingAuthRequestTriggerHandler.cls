/**********************************************************
Class: ShippingAuthRequestTriggerHandler 
LastModifiedBy: Bopsy 06/20/2022
Description: Controller class of SubmitForApproval LC.   
TestClass : ShippingAuthRequestTriggerHandlerTest
***********************************************************/

public class ShippingAuthRequestTriggerHandler {
    
    @AuraEnabled
    public static void automationForShipAuthRequest(String theRecordId) {
        
        Boolean IsSARUpdate = false;
        Map<String,List<Id>> theCountryMap = new Map<String,List<Id>>();
        List<Shipping_Authorization__c> theSAListToInsert = new List<Shipping_Authorization__c>();
        List<Authorized_Shipping_Location__c> theASLList = new List<Authorized_Shipping_Location__c>();
        EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name =: 'SAR request Declined'];
        //Opportunity theOpp;
        
        Shipping_Authorization_Request__c theSAR = [SELECT Id, RecordType.Name, Opportunity__c, Unit_Type__c, Opportunity__r.Name, Delivery_Address_Country__c, Ship_From_Country__c FROM Shipping_Authorization_Request__c WHERE Id =: theRecordId];
        
        /*if(theSAR.Opportunity__c != null) {
            theOpp = [SELECT Id, Name FROM Opportunity WHERE Id =: theSAR.Opportunity__c];
        }*/
        
        if(theSAR.Delivery_Address_Country__c != null && theSAR.RecordType.Name == 'Delivery') {
            theASLList = [SELECT Id, Country__c, Status__c FROM Authorized_Shipping_Location__c WHERE Country__c =: theSAR.Delivery_Address_Country__c AND Status__c = 'Active']; 
        }else if(theSAR.Ship_From_Country__c != null && theSAR.RecordType.Name == 'Return') {
            theASLList = [SELECT Id, Country__c, Status__c FROM Authorized_Shipping_Location__c WHERE Country__c =: theSAR.Ship_From_Country__c AND Status__c = 'Active']; 
        }
        
        for(Authorized_Shipping_Location__c theASL : theASLList) {
            
            if(theASL.Country__c != null && theASL.Status__c != null){
                if(!theCountryMap.containsKey(theASL.Country__c)) {
                    theCountryMap.put(theASL.Country__c,new List<Id>{theASL.Id});
                }else{
                    theCountryMap.get(theASL.Country__c).add(theASL.Id);
                }
            }
        }        
        
        if(theSAR.Unit_Type__c == 'Commercial' && ((theSAR.RecordType.Name == 'Delivery' && theSAR.Delivery_Address_Country__c != null && theCountryMap.containsKey(theSAR.Delivery_Address_Country__c)) || (theSAR.RecordType.Name == 'Return' && theSAR.Ship_From_Country__c != null && theCountryMap.containsKey(theSAR.Ship_From_Country__c)))) {
            List<Id> theASLListForCurrentSAR = new List<Id>();
            
            if(theSAR.RecordType.Name == 'Delivery'){
                theASLListForCurrentSAR = theCountryMap.get(theSAR.Delivery_Address_Country__c);
                
            }else if(theSAR.RecordType.Name == 'Return'){
                theASLListForCurrentSAR = theCountryMap.get(theSAR.Ship_From_Country__c);
            }
            
            for(Id theASLId : theASLListForCurrentSAR) {
                
                Shipping_Authorization__c theSA = new Shipping_Authorization__c();
                theSA.Authorized_Shipping_Location__c = theASLId;
                theSA.Shipping_Authorization_Request__c = theSAR.Id;
                theSAListToInsert.add(theSA);
                
                theSAR.Status__c = 'Pending Approval';
                IsSARUpdate = true;
            }
            if(!theSAListToInsert.isEmpty()){
                insert theSAListToInsert;
            }
            
        }else if(theSAR.Unit_Type__c == 'Research') {
            theSAR.Status__c = 'Pending Approval';
            IsSARUpdate = true;
        }else {
            
            theSAR.Status__c = 'Declined';
            IsSARUpdate = true;
            
            String theSubject = theEmailTemplate.Subject;
            if(theSAR.Opportunity__c != null) theSubject = theSubject.replace('{!Shipping_Authorization_Request__c.Opportunity__c}', theSAR.Opportunity__r.Name);
            theEmailTemplate.Subject = theSubject;
            
            String theBody = theEmailTemplate.Body;
            theBody = theBody.replace('{!Shipping_Authorization_Request__c.Link}',  System.URL.getSalesforceBaseURL().toExternalForm()+'/'+theSAR.Id);
            theEmailTemplate.Body = theBody;
            
            List<Messaging.singleEmailMessage> mailList = new List<Messaging.singleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
            email.setToAddresses( new List<String>{userinfo.getUserId()});
            email.setTemplateId(theEmailTemplate.Id);
            email.setPlainTextBody(theEmailTemplate.Body);
            email.setSubject(theEmailTemplate.Subject);
            email.setSaveAsActivity(false);
            List<Messaging.SendEmailResult> sendEmailResultList = Messaging.sendEmail(new List<Messaging.singleEmailMessage>{email});
            
        }
        
        if(IsSARUpdate){
            update theSAR;
        }
    }
    
    
    
    /* public static void automationForShipAuthRequest(List<Shipping_Authorization_Request__c> theSARList, Map<Id,Shipping_Authorization_Request__c> theOldMap) {

if((theOldMap == null && !CheckRecursive.IsautomationForShipAuthRequestAfterInsert) || (theOldMap != null && !CheckRecursive.IsautomationForShipAuthRequestAfterUpdate)) {

if(theOldMap == null){
CheckRecursive.IsautomationForShipAuthRequestAfterInsert = true;
}else if(theOldMap != null){
CheckRecursive.IsautomationForShipAuthRequestAfterUpdate = true;
}

Map<String,List<Id>> theCountryMap = new Map<String,List<Id>>();
List<String> theEmailAddressesList = new List<String>();
List<Shipping_Authorization__c> theSAListToInsert = new List<Shipping_Authorization__c>();
List<Shipping_Authorization_Request__c> theSARToUpdate = new List<Shipping_Authorization_Request__c>();
List<EmailWrapper> theWrapperList = new List<EmailWrapper>();
List<String> theCountryString = new List<String>();
EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name =: 'SAR request Declined'];
List<Id> theOppIdSet = new List<Id>();

for(Shipping_Authorization_Request__c theSAR : theSARList) {

theOppIdSet.add(theSAR.Opportunity__c);
if(theSAR.Delivery_Address_Country__c != null){
theCountryString.add(theSAR.Delivery_Address_Country__c);
}

}

Map<Id, Opportunity> theOppMap =  new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN: theOppIdSet]);

List<Authorized_Shipping_Location__c> theASLList = [SELECT Id, Country__c, Status__c FROM Authorized_Shipping_Location__c WHERE Country__c IN: theCountryString AND Status__c = 'Active']; 

for(Authorized_Shipping_Location__c theASL : theASLList){

if(theASL.Country__c != null && theASL.Status__c != null){
if(!theCountryMap.containsKey(theASL.Country__c)) {
theCountryMap.put(theASL.Country__c,new List<Id>{theASL.Id});
}else{
theCountryMap.get(theASL.Country__c).add(theASL.Id);
}
}

}        

for(Shipping_Authorization_Request__c theSAR : theSARList) { 

Shipping_Authorization_Request__c theCloneSAR  = new Shipping_Authorization_Request__c(Id = theSAR.Id);
if(theSAR.Unit_Type__c == 'Commercial' && theSAR.Delivery_Address_Country__c != null && theCountryMap.containsKey(theSAR.Delivery_Address_Country__c)) {
List<Id> theASLListForCurrentSAR = theCountryMap.get(theSAR.Delivery_Address_Country__c);
for(Id theASLId : theASLListForCurrentSAR) {

Shipping_Authorization__c theSA = new Shipping_Authorization__c();
theSA.Authorized_Shipping_Location__c = theASLId;
theSA.Shipping_Authorization_Request__c = theSAR.Id;
theSAListToInsert.add(theSA);

theCloneSAR.Status__c = 'Pending Approval';
theSARToUpdate.add(theCloneSAR);

}

}else if(theSAR.Unit_Type__c == 'Research') {
theCloneSAR.Status__c = 'Pending Approval';
theSARToUpdate.add(theCloneSAR);
} else {
theEmailAddressesList = new List<String>();
theEmailAddressesList.add(userinfo.getUserId());

String theSubject = theEmailTemplate.Subject;
if(theOppMap.containskey(theSAR.Opportunity__c)) theSubject = theSubject.replace('{!Shipping_Authorization_Request__c.Opportunity__c}', theOppMap.get(theSAR.Opportunity__c).Name);
theEmailTemplate.Subject = theSubject;

String theBody = theEmailTemplate.Body;
theBody = theBody.replace('{!Shipping_Authorization_Request__c.Link}',  System.URL.getSalesforceBaseURL().toExternalForm()+'/'+theSAR.Id);
theEmailTemplate.Body = theBody;

theWrapperList.add(new EmailWrapper(theEmailTemplate, theEmailAddressesList));
theCloneSAR.Status__c = 'Declined';
theSARToUpdate.add(theCloneSAR);
}

} 

if(!theSAListToInsert.isEmpty()) {
insert theSAListToInsert;
}

if(!theSARToUpdate.isEmpty()) {
if(System.isFuture() || System.isBatch()) {
ShippingAuthRequestTriggerHandler.updateSARHelper(theSARToUpdate);
}
else {
ShippingAuthRequestTriggerHandler.updateSARFutureHelper(JSON.serialize(theSARToUpdate));
}
}

if(!theWrapperList.isEmpty())  sendEmail(theWrapperList);
}
}

@future
public static void updateSARFutureHelper(String theSARStr) {

List<Shipping_Authorization_Request__c> theSARForUpdateList = (List<Shipping_Authorization_Request__c> )JSON.deserialize(theSARStr, List<Shipping_Authorization_Request__c> .class);
ShippingAuthRequestTriggerHandler.updateSARHelper(theSARForUpdateList);

}

public static void updateSARHelper(List<Shipping_Authorization_Request__c> theSARRequestList) {

if(!theSARRequestList.isEmpty()){
update theSARRequestList;
} 

}

public static void sendEmail(List<EmailWrapper> theWrapperList) {
List<Messaging.singleEmailMessage> mailList = new List<Messaging.singleEmailMessage>();
for(EmailWrapper theEmailWrap : theWrapperList) {
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
email.setToAddresses(theEmailWrap.theToAddressList);
email.setTemplateId(theEmailWrap.thetemplate.Id);
email.setPlainTextBody(theEmailWrap.thetemplate.Body);
email.setSubject(theEmailWrap.thetemplate.Subject);
email.setSaveAsActivity(false);
mailList.add(email);
}

if(!mailList.isEmpty()) {
List<Messaging.SendEmailResult> sendEmailResultList = Messaging.sendEmail(mailList);
}        

}

public class EmailWrapper{
public EmailTemplate thetemplate;
public List<String> theToAddressList;

public EmailWrapper(EmailTemplate theTempl, List<String> toAddressList) {
thetemplate = theTempl;
theToAddressList = toAddressList;

}
} */
}