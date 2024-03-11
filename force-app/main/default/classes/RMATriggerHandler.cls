/**********************************************************
Class: RMATriggerHandler 
CreatedBy: Bopsy 01/18/2023
Description: handler class of RMATrigger   
TestClass :
***********************************************************/
public class RMATriggerHandler {
    public static void checkForRMAShipmentChanges(List<RMA__c> newList, Map<Id, RMA__c> oldMap, Map<Id, RMA__c> newMap) {
        Map<Id, String> RMAToShipmentMap = new Map<Id, String>();
        for(RMA__c rec : newList){
            if(rec.RMA_Shipment__c == null && oldMap.get(rec.Id).RMA_Shipment__c != null){
                RMAToShipmentMap.put(rec.Id, oldMap.get(rec.Id).RMA_Shipment__c); 
                
            }
        }
        if(RMAToShipmentMap.size() > 0){
            List<Id> existingRMAShipmentIds = new List<Id>();
            for(RMA__c rec : [SELECT Id, RMA_Shipment__c FROM RMA__c WHERE RMA_Shipment__c IN:RMAToShipmentMap.values()]){   
                if(!existingRMAShipmentIds.contains(rec.RMA_Shipment__c) && !RMAToShipmentMap.containskey(rec.Id)){
                    existingRMAShipmentIds.add(rec.RMA_Shipment__c);   
                }
            }
            system.debug('*** existingRMAShipmentIds ***'+existingRMAShipmentIds);
            for(Id rmaId: RMAToShipmentMap.keyset()){
                if(!existingRMAShipmentIds.contains(RMAToShipmentMap.get(rmaId))){
                    newMap.get(rmaId).addError('This RMA Shipment Cannot be blanked out. Since it is related to only this RMA');
                }
            }
        }
    }
    
}