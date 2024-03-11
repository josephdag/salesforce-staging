/**********************************************************
Class: BlueSheetLCController
LastModifiedBy: Bopsy 10/11/2022
Description: Controller Class of BlueSheetLC Lightning Component    
TestClass : BlueSheetLCControllerTest
***********************************************************/
public class BlueSheetLCController {
    
    @AuraEnabled
    public static MainWrapper fetchData(String recordId) {
         Opportunity theOpp = [SELECT Id, BAA_notes__c, Key_Information_Text_1__c, Why_are_they_acquiring_Swoop__c, BAA__c, blue_sheet_last_modified__c, 
                              Amount, Submitted__c, CloseDate, Approved__c, Requested_Ship_Date__c, PO_Approval_Local_Regional_National__c, 
                              Sales_Process_Step__c, StageName, Customer_Pain_Point_1__c, Customer_Pain_Point_2__c, Customer_Pain_Point_3__c,
                              Customer_Pain_Point_4__c, Customer_Pain_Point_5__c, Smart_Goal_1__c, Smart_Goal_2__c, Smart_Goal_3__c, Smart_Goal_4__c, 
                              Smart_Goal_5__c, Use_Case_Location_1__c, Use_Case_Location_2__c, Use_Case_Location_3__c, Use_Case_Location_4__c, 
                              Use_Case_Location_5__c, Use_Case_Location_6__c, Use_Case_Location_7__c, Use_Case_Location_8__c, Use_Case_Location_9__c, 
                              Use_Case_Location_10__c, Use_Case_Location_11__c, Use_Case_Location_12__c, Probelm_We_re_Solving_1__c, 
                              Probelm_We_re_Solving_2__c, Probelm_We_re_Solving_3__c, Probelm_We_re_Solving_4__c, Probelm_We_re_Solving_5__c,
                              Probelm_We_re_Solving_6__c, Probelm_We_re_Solving_7__c, Probelm_We_re_Solving_8__c, Probelm_We_re_Solving_9__c, 
                              Probelm_We_re_Solving_10__c, Probelm_We_re_Solving_11__c, Probelm_We_re_Solving_12__c, Clinical_Champion_ID_d__c, 
                              Secondary_Champion_ID_d__c, Customer_Needs_ID_d__c, Swoop_Solution_Presented__c, Executive_Level_Champion_ID_d__c,
                              ROI_Reviewed_Approved__c, IT_Engaged__c, QC_Audit_paper_on_site_Complete__c, Legal_Red_Line_T_s_C_s_Review__c, 
                              Timeline_Agreed_To__c, Radiology_buy_in_support__c, Customer_Success_Engaged__c, Clinical_Champion_ID_d_Notes__c,
                              Secondary_Champion_ID_d_Notes__c, Customer_Needs_ID_d_Notes__c, Swoop_Solution_Presented_Notes__c,
                              Executive_Level_Champion_ID_d_Notes__c, ROI_Reviewed_Approved_Notes__c, IT_Engaged_Notes__c, AccountId, Account.Name,
                              QC_Audit_paper_on_site_Complete_Notes__c, Legal_Red_Line_T_s_C_s_Review_Notes__c, Timeline_Agreed_To_Notes__c,
                              Radiology_buy_in_support_Notes__c, Customer_Success_Engaged_Notes__c, Risks_Challenges_to_Deal_1__c,
                              Risks_Challenges_to_Deal_2__c, Risks_Challenges_to_Deal_3__c, Risks_Challenges_to_Deal_4__c,
                              Risks_Challenges_to_Deal_5__c, Key_Information_for_Success_1__c, Key_Information_for_Success_2__c,
                              Key_Information_for_Success_3__c, Key_Information_for_Success_4__c, Key_Information_for_Success_5__c,
                              Key_Information_Text_2__c, Key_Information_Text_3__c, Key_Information_Text_4__c,
                              Key_Information_Text_5__c, Deal_Rip__c, Market_Segment_Text__c, of_Systems__c, 
                              (SELECT Id, Role, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Id, Contact.Title, Contact.Phone, Notes__c FROM OpportunityContactRoles)
                              FROM Opportunity WHERE Id =:recordId];
        
        MainWrapper theWrapper = new MainWrapper();
        theWrapper.theOpp = theOpp;
        
        Map<String, List<String>> theObjectFieldMap = new Map<String, List<String>>();
        theObjectFieldMap.put('Contact', New List<String> {'Name', 'FirstName', 'LastName', 'Title',  'Phone', 'Email'});
        theObjectFieldMap.put('OpportunityContactRole', New List<String>{'Role', 'Notes__c' });
        
        List<RowWrapper> theRowWrapperList = new List<RowWrapper>();
        for(OpportunityContactRole theOCR : theOpp.OpportunityContactRoles) {
            
            RowWrapper theRow = new RowWrapper();
            List<FieldWrapper> theFieldWrapperList = new List<FieldWrapper>();
            
            for(String theObjectName :  theObjectFieldMap.keyset()) { 
                
                for(String thefieldAPIName :  theObjectFieldMap.get(theObjectName)) {
                    
                    String theFieldtype = String.valueof(Schema.getGlobalDescribe().get(theObjectName).getDescribe().fields.getMap().get(thefieldAPIName).getDescribe().getType());
                    FieldWrapper theFieldWrapper = new FieldWrapper();
                    theFieldWrapper.Fieldtype = String.valueOf(theFieldtype);
                    theFieldWrapper.FieldAPIName = thefieldAPIName;
                    
                    String thevalue = '';
                    if(theObjectName == 'Contact') {
                        thevalue = (String) theOCR.getSobject('Contact').get(thefieldAPIName);                        
                    }
                    else {
                        thevalue = String.valueOf(theOCR.get(thefieldAPIName));
                    }
                    theFieldWrapper.value = thevalue;
                    theFieldWrapper.OldValue = thevalue;
                    
                    if(theFieldtype.equalsIgnoreCase('PICKLIST')) {
                        theFieldWrapper.thepicklist = pickList(theObjectName, thefieldAPIName, theFieldtype);
                    }
                    theFieldWrapperList.add(theFieldWrapper);
                    
                }
            }
            
            FieldWrapper theContactIdField = new FieldWrapper();
            theContactIdField.value = theOCR.Contact.Id;
            theContactIdField.FieldAPIName =  'ContactId';
            theFieldWrapperList.add(theContactIdField);
            
            FieldWrapper theOCRIdField = new FieldWrapper();
            theOCRIdField.value = theOCR.Id;
            theOCRIdField.FieldAPIName =  'OCRId';
            theFieldWrapperList.add(theOCRIdField);
            
            theRow.theFields = theFieldWrapperList;
            theRowWrapperList.add(theRow);
            
        }
        
        theWrapper.AllRows = theRowWrapperList;
        return theWrapper;
        
    }
    
    public static List<String> pickList(String strObjectName, String strPicklistField, String thetype) {
        
        List<String> thePickVal = new List<String>(); 
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(strPicklistField).getDescribe();
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        for (Schema.PicklistEntry objPickList : picklistvalues) {
            
            thePickVal.add(objPickList.getLabel());
            
        }
        return thePickVal;
        
    }
    
    @AuraEnabled
    public static void saveData(String recordData, String OppId) {
        Map<String, List<String>> theObjectFieldMap = new Map<String, List<String>>();
        theObjectFieldMap.put('Contact', New List<String> {'FirstName', 'LastName', 'Title',  'Phone', 'Email', 'ContactId'});
        theObjectFieldMap.put('OpportunityContactRole', New List<String>{'Role', 'Notes__c', 'OCRId' });
        
        List<RowWrapper> theRowsWrapper = (List<RowWrapper>)JSON.deserialize(recordData, List<RowWrapper>.class);
        List<Contact> theContactUpdateList = new List<Contact>();
        List<OpportunityContactRole> theOCRUpdateList = new List<OpportunityContactRole>();
        
        for(RowWrapper theRow : theRowsWrapper) {
            
            Boolean isOCRUpdate = false;
            Boolean isContactUpdate = false;
            Contact theCon = new Contact();
            OpportunityContactRole theOCR = new OpportunityContactRole();
            
            for(FieldWrapper theField : theRow.theFields) {
                
                if(theObjectFieldMap.get('Contact').Contains(theField.FieldAPIName)) {
                    if(theField.value != theField.OldValue) {
                        if(theField.FieldAPIName == 'ContactId') {
                            theCon.put('Id', theField.value);
                        } else {
                            theCon.put(theField.FieldAPIName, theField.value);
                            isContactUpdate = true;
                        }
                    }
                } else {
                    if(theField.value != theField.OldValue) {
                        if(theField.FieldAPIName == 'OCRId') {
                            theOCR.put('Id', theField.value);
                        } else {
                            theOCR.put(theField.FieldAPIName, theField.value);
                            isOCRUpdate = true;
                        }
                    }
                }
            }
            if(isOCRUpdate) theOCRUpdateList.add(theOCR);
            if(isContactUpdate) theContactUpdateList.add(theCon);
            
        }
        try{
            if(!theOCRUpdateList.isempty()) update theOCRUpdateList;
            if(!theContactUpdateList.isempty()) update theContactUpdateList;
          
        }catch(Exception e){
            
        }
    }
    
    @AuraEnabled
    public static void deleteOCRRecords(String OCRId) {
        OpportunityContactRole theOCR = [Select Id FROM OpportunityContactRole Where Id =: OCRId];
        delete theOCR;
    }
    
    public class MainWrapper {
        @AuraEnabled
        public Opportunity theOpp;
        @AuraEnabled
        public List<RowWrapper> AllRows;
    }
    
    public class RowWrapper {
        @AuraEnabled
        public List<FieldWrapper> theFields;
    }
    
    public class FieldWrapper {
        @AuraEnabled
        public String Fieldtype;
        @AuraEnabled
        public List<String> thepicklist;
        @AuraEnabled
        public String FieldAPIName;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String OldValue;
    }
    
}