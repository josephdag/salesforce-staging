/*******************************************************
//Class: ActivityTriggerHandler
//Created By: Bopsy Team
//Last Modified by: Bopsy Team {12/08/2021}
//Description: This is the handler class for EventTrigger and TaskTrigger
//Test Class: ActivityTriggerHandlerTest
/*******************************************/
public class ActivityTriggerHandler {
    
    public static void updateNoOfTouchPointOnLead(List<Sobject> theActivityList, Map<Id,Sobject> theOldMap, Boolean isDeleted){
        
        Set<Id> theLeadIdSet = new Set<Id>();
        List<Lead> theLeadUpdateList = new List<Lead>();
        List<Sobject> theActivityLoopList; 
        
        if(!isDeleted) theActivityLoopList = theActivityList;
        else theActivityLoopList = theOldMap.values();
        
        for(Sobject theActivity : theActivityLoopList) {
            
            Sobject theOldActivity ;
            if(theOldMap != null) theOldActivity = theOldMap.get(String.valueOf(theActivity.get('Id')));
            
            if((String.valueOf(theActivity.get('WhoId')) != null && (String.valueOf(theActivity.get('WhoId')).Startswith('00Q')))
               || (theOldMap != null && ( String.valueOf(theActivity.get('WhoId')) !=  String.valueOf(theOldActivity.get('WhoId'))))) {
                   
                   theLeadIdSet.add(String.valueOf(theActivity.get('WhoId')));
                   
                   //Adding the Old Lead Id if an activity record is unrelated from the Lead
                   if((theOldMap != null && ( String.valueOf(theActivity.get('WhoId')) !=  String.valueOf(theOldActivity.get('WhoId'))))) {
                       theLeadIdSet.add(String.valueOf(theOldActivity.get('WhoId')));
                   }
                   
               }
            
        }
        
        List<Lead> theLeadList = [SELECT Id, of_Touchpoints__c, (SELECT Id, ActivityDate, Subject, WhoId FROM Events), (SELECT Id, ActivityDate, Subject, WhoId, Status FROM Tasks) FROM Lead WHERE Id IN : theLeadIdSet];
        Integer theEventCount, theTaskCount;
        
        for(Lead theLead : theLeadList) {
            
            if(theLead.Events != null) theEventCount = theLead.Events.size();
            else theEventCount = 0;
            
            if(theLead.Tasks != null) theTaskCount = theLead.Tasks.size();
            else theTaskCount = 0;
            
            if(theLead.of_Touchpoints__c != theEventCount + theTaskCount) {
                theLead.of_Touchpoints__c = theEventCount + theTaskCount;
                theLeadUpdateList.add(theLead);
            }
            
        }
        if(!theLeadUpdateList.isEmpty()) update theLeadUpdateList;
    }
}