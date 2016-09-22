trigger SubChangeManagementTrigger on Sub_Change_Management__c (before insert, before update, after insert, after update) {
    
    Savepoint sp = Database.setSavepoint();
    try {  
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
           SubChangeManagementTriggerHandler.SubChangeManagement_AfterTrigger(Trigger.newMap,Trigger.oldMap);
        }
    }
    catch(Exception e) {
        system.debug('inside Change Management '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    }   

}