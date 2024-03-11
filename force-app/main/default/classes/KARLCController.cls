/**********************************************************
Class: KARLCController 
LastModifiedBy: Bopsy 05/23/2022
Description: Controller Class of KARLC Lightning Component    
TestClass : KARLCControllerTest
***********************************************************/
public class KARLCController {
    
    @AuraEnabled
    public static List<FieldSetwrapper> fetchFieldSetInfo(String recordId) {
        
        Map<String, String> theMap = new Map<String,String>();
        theMap.put('Target_Prepare_the_Market','Target/Prepare the Market');
        theMap.put('Clinical_Selling','Clinical Selling');
        theMap.put('Clinical_Validation','Clinical Validation');
        theMap.put('Executive_Selling','Executive Selling');
        theMap.put('Executive_Validation','Executive Validation');
        theMap.put('Closed_Won','Closed Won');        
        
        String strObjectApiName = 'Opportunity';
        List<Schema.FieldSetMember> fieldDefSetMemberList = new List<Schema.FieldSetMember>();
        Opportunity theOPP = fetchOpportunityData(recordId);
        
        List<FieldSetwrapper> theReturnWrapper = new List<FieldSetwrapper>(); 
        for(String theFieldSet : theMap.keyset()) {
            
            FieldSetwrapper theFieldSetwrapper = new FieldSetwrapper();
            theFieldSetwrapper.FieldSetName = theMap.get(theFieldSet);
            fieldDefSetMemberList = readFieldSet(theFieldSet,strObjectApiName);
            List<wrapper> theWrapperList = new List<wrapper>();
            
            for(Schema.FieldSetMember thefield : fieldDefSetMemberList){ 
                
                wrapper theWrapper = new wrapper();
                theWrapper.Fieldtype = String.valueOf(thefield.getType());
                theWrapper.FieldAPIName = thefield.getFieldPath();
                theWrapper.value = String.valueOf(theOPP.get(thefield.getFieldPath()));
                theWrapper.FieldLabelName = thefield.getLabel();
                
                if(theWrapper.Fieldtype.equalsIgnoreCase('PICKLIST')) {
                    theWrapper.thepicklist = KARLCController.pickList(strObjectApiName, theWrapper.FieldAPIName, theWrapper.Fieldtype);
                } 
                else if(theWrapper.Fieldtype.equalsIgnoreCase('MULTIPICKLIST')) {
                    
                    List<String> theStringList = KARLCController.pickList(strObjectApiName, theWrapper.FieldAPIName, theWrapper.Fieldtype);
                    List<MultiPickListWrapper> thePickListWrapList = new List<MultiPickListWrapper>();
                    for(String theStr : theStringList) {
                        MultiPickListWrapper thePicklistWrapper = new MultiPickListWrapper();
                        thePicklistWrapper.label = theStr;
                        thePicklistWrapper.value = theStr;
                        thePickListWrapList.add(thePicklistWrapper);
                    }
                    theWrapper.theMultipicklist = thePickListWrapList;
                    String theFieldValue = String.valueOf(theOPP.get(thefield.getFieldPath()));
                    List<String> theFieldValueList;
                    if(theFieldValue != null) theFieldValueList = theFieldValue.split(';');
                    theWrapper.theMultiPicklistvalues = theFieldValueList;
                } 
                else if(theWrapper.Fieldtype.equalsIgnoreCase('REFERENCE')) {
                    theWrapper.theObjectName = getObjectName(thefield.getFieldPath());
                    theWrapper.theObjectvalue = getRecord( getObjectName(thefield.getFieldPath()), String.valueOf(theOPP.get(thefield.getFieldPath())));
                } 
                else if(theWrapper.Fieldtype.equalsIgnoreCase('BOOLEAN')) {
                    theWrapper.theBooleanValue = Boolean.valueOf(String.valueOf(theOPP.get(thefield.getFieldPath())));
                }
                
                theWrapperList.add(theWrapper); 
                
            }
            
            theFieldSetwrapper.theFields = theWrapperList;
            theReturnWrapper.add(theFieldSetwrapper);
        }
        return theReturnWrapper;
    }
    
    @AuraEnabled
    public static Opportunity fetchOpportunityData(String recordId) {
        List<String> listOfFieldSetApiNames = new List<String>{'Clinical_Selling','Clinical_Validation','Closed_Won','Executive_Selling','Executive_Validation','Target_Prepare_the_Market'};
        String strObjectApiName = 'Opportunity';
        List<String> theFieldList = new List<String>();
        
        for(String thefieldSet : listOfFieldSetApiNames ) {
            
            List<Schema.FieldSetMember> fieldSetMemberList = readFieldSet(thefieldSet,strObjectApiName);
            for(Schema.FieldSetMember theFSMember : fieldSetMemberList) {
                
                theFieldList.add(theFSMember.getFieldPath());
                
            }
            
        }
        String theQuery = 'SELECT Id';
        for(String thefield : theFieldList) {
           
            theQuery += ','+ thefield;
        
        }
        theQuery += ' FROM Opportunity WHERE Id =: recordId limit 1';
        return database.query(theQuery);
    }
    
    @AuraEnabled
    public static returnWrapper saveData(String obj, String recordId) {
        
        try{
            List<FieldSetwrapper> theWrapperList = (List<FieldSetwrapper>)JSON.deserialize(obj, List<FieldSetwrapper>.class);
           Opportunity theOpp = new Opportunity();
            
            for(FieldSetwrapper theFS : theWrapperList) {
                for(wrapper theField : theFS.theFields) {
                    Schema.SobjectField theFieldIsEditable = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(theField.FieldAPIName);
                     if(!theFieldIsEditable.getDescribe().isUpdateable()) {
                       continue;
                    }
                    else if(theField.Fieldtype.equalsIgnoreCase('Date')  && theField.value != null ) {
                        theOpp.put(theField.FieldAPIName, Date.valueOf(String.valueOf(theField.value)));
                    }
                    else if((theField.Fieldtype.equalsIgnoreCase('String') || theField.Fieldtype.equalsIgnoreCase('TextArea')) && theField.value != null) {
                        theOpp.put(theField.FieldAPIName, String.valueOf(theField.value));
                    } 
                    else if(theField.Fieldtype.equalsIgnoreCase('REFERENCE') && theField.theObjectvalue != null) {
                        theOpp.put(theField.FieldAPIName, String.valueOf(theField.theObjectvalue.get('Id')));
                    }
                    else if(theField.Fieldtype.equalsIgnoreCase('BOOLEAN')) {
                         theOpp.put(theField.FieldAPIName, theField.theBooleanValue);
                    } 
                    else if((theField.Fieldtype.equalsIgnoreCase('Decimal') || theField.Fieldtype.equalsIgnoreCase('currency')) && theField.value != null) {
                        theOpp.put(theField.FieldAPIName, Decimal.valueOf(String.valueOf(theField.value)));
                    }
                    else if(theField.Fieldtype.equalsIgnoreCase('DateTime')  && theField.value != null){
                        theOpp.put(theField.FieldAPIName, DateTime.valueOf((String.valueOf(theField.value).replace('T', ' '))));
                    }
                    else if(theField.Fieldtype.equalsIgnoreCase('MULTIPICKLIST')  && theField.theMultiPicklistvalues != null){
                        String theFinalValue = '';
                        for(String thePickListValue : theField.theMultiPicklistvalues) {
                            
                            theFinalValue = theFinalValue + thePickListValue + ';';
                            
                        }
                        theOpp.put(theField.FieldAPIName, theFinalValue);
                    } 
                    else {
                        theOpp.put(theField.FieldAPIName, String.valueOf(theField.value));
                    }
                    
                }
                
            } 
            theOpp.Id = recordId;
            
            update theOpp;
            Opportunity theOpportunity = [SELECT Name FROM Opportunity WHERE Id=:recordId];
            returnWrapper theReturnWrapper = new returnWrapper();
            theReturnWrapper.Name = theOpportunity.Name;
            theReturnWrapper.recId = theOpp.Id;  
            return theReturnWrapper;
        }
        catch(Exception e) {
            
            System.debug('Error:==>'+e.getLineNumber());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    public static List<String> pickList(String strObjectName, String strPicklistField, String thetype) {
        
        List<String> thePickVal = new List<String>(); 
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(strPicklistField).getDescribe();
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
       
        if(thetype != 'MULTIPICKLIST') {
            thePickVal.add('');
        }
        
        for (Schema.PicklistEntry objPickList : picklistvalues) {
           
            thePickVal.add(objPickList.getLabel());
       
        }
        return thePickVal;
    }
    
    
    public static String getObjectName (String fieldName) {
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get(fieldName).getDescribe();
        
        for(Schema.SObjectType reference : f.getReferenceTo()) {
            
            return reference.getDescribe().getName();
        
        }
        
        return null;
    }
    
    public static Map<String, String> getRecord(String ObjectName, String theId) {
        Map<String, String> theMap = new Map<String, String>();
        if(theId != null) {
            String theQuery = 'SELECT Id, Name FROM '+ ObjectName +' WHERE Id =: theId';
            Sobject theData = Database.query(theQuery);
            theMap.put('Id', String.valueOf(theData.get('Id')));
            theMap.put('Name', String.valueOf(theData.get('Name')));
        }
        return theMap;
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    public class returnWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String recId;
    }
    
    public class FieldSetwrapper {
        @AuraEnabled
        public String FieldSetName;
        @AuraEnabled
        public List<wrapper> theFields;
    }
    
    public class wrapper {
        @AuraEnabled
        public String Fieldtype;
        @AuraEnabled
        public List<String> thepicklist;
        @AuraEnabled
        public List<multiPickListWrapper> theMultipicklist;
        @AuraEnabled
        public String theObjectName;
        @AuraEnabled
        public String FieldAPIName;
        @AuraEnabled
        public boolean theBooleanValue;
        @AuraEnabled
        public String FieldLabelName;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public List<String> theMultiPicklistvalues;
        @AuraEnabled
        public Map<String, String> theObjectvalue;
    }
    
    public class multiPickListWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}