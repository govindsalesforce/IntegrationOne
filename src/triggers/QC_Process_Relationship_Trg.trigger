trigger QC_Process_Relationship_Trg on Process_Relationship__c (before insert, before update) {
    Savepoint sp = Database.setSavepoint();
    try{
          if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
              QCTriggerHandler.ProcessRelationship_BeforeTrigger(Trigger.New);
    }
    catch(Exception e) {
       Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PRCRELTRG);
    }   
}