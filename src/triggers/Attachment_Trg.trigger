trigger Attachment_Trg on Attachment (before insert,after insert,before update,after update) {
    Savepoint sp = Database.setSavepoint();
    try{ 
        if((Trigger.isUpdate ) && Trigger.isAfter)  
            GeneralTaskTriggerHandler.Attachment_AfterUpdate(Trigger.newMap,Trigger.OldMap);   
        
        if((Trigger.isInsert) && Trigger.isAfter)  
            GeneralTaskTriggerHandler.Attachment_Afterinsert(Trigger.new);   
    }
    catch(Exception e) {
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PLNTRG); 
    } 
}