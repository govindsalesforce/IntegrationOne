trigger DocumentTypeTrigger on Document_Type__c (before insert, before update, after insert, after update) {
    
    Savepoint sp = Database.setSavepoint();
    try {  
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
           DocumentTypeTriggerHandler.DocumentType_AfterTrigger(Trigger.newMap,Trigger.oldMap);
         }
    }
    catch(Exception e) {
        system.debug('inside Document Type '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    }   

}