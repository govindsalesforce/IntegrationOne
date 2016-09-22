trigger ChangeManagementTrigger on Change_Management__c (before insert, before update, after insert, after update) {
    
    Savepoint sp = Database.setSavepoint();
    try {  
        if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isBefore){
           ChangeManagementTriggerHandler.ChangeManagement_BeforeTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
           ChangeManagementTriggerHandler.ChangeManagement_AfterTrigger(Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
         }
    }
    catch(Exception e) {
        system.debug('inside Change Management '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    }   

}