trigger QC_Product_Relationship_Trg  on Product_Relationship__c (before insert, before update) {
    Savepoint sp = Database.setSavepoint();
    try{
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
              QCTriggerHandler.ProductRelationship_BeforeTrigger(Trigger.New);
    }
    catch(Exception e) {
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PRDRELTRG);
    }   
}