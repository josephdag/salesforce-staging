/**********************************************************
Class: FieldServiceReportController 
LastModifiedBy: Bopsy 10/17/2023
Description: This is the extension class for FieldServiceReport VF Page   
TestClass : FieldServiceReportControllerTest
***********************************************************/

public class FieldServiceReportController {
    public Field_Service_Visit__c theFSV;
    //public RMA__c theRMA {set;get;}
    //public boolean theRMABoolean {set;get;}
    public List<wrapCT> theCTWrapList {set;get;}
    public FieldServiceReportController(ApexPages.StandardController stdController) {
        
        /*Id theRMAId = apexpages.currentpage().getparameters().get('theRadioId');
        if(theRMAId!= null) {
            theRMABoolean = true;
            this.theRMA = [SELECT Id, Product_Code_RMA__c, S_N_of_product_being_replaced__c, Description__c, Description_of_Issue__c, Quantity__c FROM RMA__c WHERE Id =: theRMAId ];
        }
        else {
            theRMABoolean = false;
        }*/
        this.theFSV = (Field_Service_Visit__c)stdController.getRecord();
        
        
        List<Calibrated_Tool__c> theCTList = this.fetchCTList(theFSV.Id);
        List<wrapCT> theWrapCTList = new List<wrapCT>();
        
        if(theCTList.size() > 4) {
            Integer index = 1;
            for(Calibrated_Tool__c theCT : theCTList) {
                wrapCT theWrap = new wrapCT();
                theWrap.theIndex = index;
                theWrap.theCT = theCT;
                if(theCT.Cal_Expiration_Date__c != null) theWrap.theCTDate = theCT.Cal_Expiration_Date__c.format();
                index++;
                theWrapCTList.add(theWrap);
            }
        } else {
            Integer index = 1;
            for(Integer i = 0; i < 4; i++) {
                wrapCT theWrap = new wrapCT();
                theWrap.theIndex = index;
                
                if(theCTList.size() >= index) {
                    theWrap.theCT = theCTList[index - 1];  
                    if(theCTList[index - 1].Cal_Expiration_Date__c != null) 
                        theWrap.theCTDate = theCTList[index - 1].Cal_Expiration_Date__c.format();
                } 
                index++;
                theWrapCTList.add(theWrap);
            }
        }
        theCTWrapList = theWrapCTList;
        
        Field_Service_Visit__c theFSVObj = [SELECT id, Name, Case__r.casenumber from Field_Service_Visit__c WHERE Id =: this.theFSV.Id];
        String yourFileName = 'ServiceReport_'+theFSVObj.Name+'_Case-'+theFSVObj.Case__r.CaseNumber+'.pdf';
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' +yourFileName);
    }
    
    public List<Calibrated_Tool__c> fetchCTList(String theFSVId) {
        
        List<Calibrated_Tool__c> theCTList = [SELECT Id, Calibrated_Tool_Description__c, Calibrated_Tool_Serial_Number__c, Cal_Expiration_Date__c FROM Calibrated_Tool__c WHERE Field_Service_Visit__c =: theFSVId];
        
        return theCTList;
    }
    
    public class wrapCT {
        public Calibrated_Tool__c theCT {get; set;}
        public Integer theIndex {get; set;} 
        public String theCTDate {get; set;} 
    } 
    
    /*@AuraEnabled
    public static wrapperRMAList getRMAInLC(String theFSVId) {
        Field_Service_Visit__c theFieldService = [SELECT Id, Case__c FROM Field_Service_Visit__c WHERE Id =: theFSVId];
        List<RMA__c> theRMAlist = [SELECT Id, Name FROM RMA__c WHERE Case__c =:theFieldService.Case__c Order By Name];
        
        wrapperRMAList theWrap = new wrapperRMAList();
        List<wrapperRMA> theWrapperList = new List<wrapperRMA>();
        
        Boolean theValue = false;
        for(RMA__c theRMA : theRMAlist) {
            
            wrapperRMA theWrapval = new wrapperRMA();
            theWrapval.label = theRMA.Name;
            theWrapval.value = theRMA.Id;
            if(theWrap.theFirstWrap == null) theWrap.theFirstWrap = theWrapval;
            else theWrapperList.add(theWrapval);
            
        }
        theWrap.theWrapperList = theWrapperList;
        
        
        return theWrap;
    }
    
    public Class wrapperRMA {
        
        @AuraEnabled
        public string label;
        @AuraEnabled
        public String value; 
        
    }
    
    public Class wrapperRMAList {
        
        @AuraEnabled
        public wrapperRMA theFirstWrap;
        @AuraEnabled
        public List<wrapperRMA> theWrapperList; 
        
    }*/
    
}