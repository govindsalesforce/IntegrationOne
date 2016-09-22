trigger DocumentProfileTrigger on Document_Profile__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
 
    Savepoint sp = Database.setSavepoint();
    try {  
        if(Trigger.isbefore && (Trigger.isUpdate)) {
        DocumentProfileTriggerHandler.DocumentProfile_BeforeTrigger(Trigger.newMap,Trigger.oldMap);
        }
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
           DocumentProfileTriggerHandler.DocumentProfile_AfterTrigger(Trigger.newMap,Trigger.oldMap);
         }
    }
    catch(Exception e) {
        system.debug('inside Document Profile '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    }   
    /*----Document Revise and Temp story Trigger (Start)----*/
     if(Trigger.isUpdate && Trigger.isAfter){
        DocumentProfileTriggerHandler.UpdateRevised(Trigger.new);
        DocumentProfileTriggerHandler.UpdateTemp(Trigger.new);
     }
    /*----Document Revise and Temp story Trigger (Stop)----*/
    if(Trigger.isInsert && Trigger.isbefore){
        DocumentProfileTriggerHandler.DocumentProfile_BeforeInsertTrigger(Trigger.new); 
    }
    
}