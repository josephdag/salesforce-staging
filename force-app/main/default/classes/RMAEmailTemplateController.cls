/*******************************************************
//Class: RMAEmailTemplateController
//Last Modified by: CloudConnex {10/12/2023}
//Description: This is the handler class for RMAVFPage
//Test Class: RMAEmailTemplateControllerTest
/*******************************************/
public class RMAEmailTemplateController {
    public Boolean theTrueValue {get;set;}
    public string RMAId {get;set;}
    
    public RMAEmailTemplateController() {
        theTrueValue = true;
    }
    
    public RMA__c getRMA(){
        List<RMA__c> theRMAList = new List<RMA__c>();
        
        theRMAList = [SELECT Id, Complaint__c, Name, Salesforce_Case__c, CreatedDate, Account_Name__c, Primary_Contact_Name__c, Physical_Address__c, Phone_Number__c,
                      Fax_Number__c, Email_Address__c, Address_to_Return_Devices_to__c, Reason_of_Return_Other__c, Reason_of_Return__c, Return_related_to_complaint_with_device__r.Complaint__c, 
                      Original_Order__c, Case__r.Account.Name, Case__r.CaseNumber, Complaint_Related_Details__c,RMA_Shipment__r.City__c,
                      RMA_Defective_Part__c, RMA_Defective_Part__r.Name, S_N_of_product_being_replaced__c, Description__c, Description_of_Issue__c, Quantity__c, Address_to_return_Device__c,
                      Benchmark_Electronics__c, Hyperfine__c,  RMA_Replacement_Part_Number__c, S_N_of_replacement_part__c , RMA_Return_Condition__c, Case__r.Contact.Name, Case__r.Contact_Office_Phone_number__c, 
                      Case__r.Reporting_s_Contact_Email_Address__c, RMA_Replacement_Part_Number__r.Name, RMA_Shipment__r.Attention_To__c, RMA_Shipment__r.Street__c, RMA_Shipment__r.State__c, RMA_Shipment__r.Zip_Code__c
                      FROM RMA__c WHERE Id =: RMAId];
        
        if(theRMAList.size() > 0) {
            return theRMAList[0];
        } else {
            return null;
        }
        
    }
    
    public RMAEmailTemplateController(ApexPages.StandardController stdController) {
        this.RMAId = stdController.getRecord().Id;
        RMA__c theRMA = [SELECT Id, Name, Case__r.CaseNumber FROM RMA__c WHERE Id =: this.RMAId];
        String yourFileName = theRMA.Name+'_'+theRMA.Case__r.CaseNumber+'_RMA form'+'.pdf';
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' +yourFileName);
    }
    
    public RMAEmailTemplateController(String theId) {
        this.RMAId = theId;
    }
    
}