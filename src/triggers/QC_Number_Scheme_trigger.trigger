trigger QC_Number_Scheme_trigger on Number_Scheme__c (before delete) {

    Savepoint sp = Database.setSavepoint();
    try {
        if(Trigger.isdelete) {
            QCTriggerHandler.Number_Scheme_AfterDeleteTrigger(Trigger.oldMap);
        }
    }
    catch(Exception e) {
        system.debug('inside Number Scheme '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.NCMTRG);
    } 
}