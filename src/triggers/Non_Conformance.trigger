trigger Non_Conformance on Non_Conformance__c (before insert, before update, after insert, after update) {
    Savepoint sp = Database.setSavepoint();
    try {  
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
           NonConformanceTriggerHandler.NonConformance_BeforeTrigger(Trigger.new,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
        }
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            NonConformanceTriggerHandler.NonConformance_AfterTrigger(Trigger.new,Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);
         }
    }
    catch(Exception e) {
        system.debug('inside Non Confromance '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    }   
}