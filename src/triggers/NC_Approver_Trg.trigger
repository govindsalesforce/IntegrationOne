trigger NC_Approver_Trg on Approver__c (after insert, after update,after delete,before insert,before update) {


    Savepoint sp = Database.setSavepoint();
    try{ 
        if((Trigger.isInsert ) && Trigger.isAfter)  
            GeneralTaskTriggerHandler.Approver_AfterInsert(Trigger.new);   
        if((Trigger.isUpdate) && Trigger.isAfter)
            GeneralTaskTriggerHandler.Approver_AfterUpdate(Trigger.newMap,Trigger.oldMap);  
        
        if(Trigger.isdelete && Trigger.isAfter){
            GeneralTaskTriggerHandler.Approver_Afterdelete(Trigger.old);
        }           
    
        }
    catch(Exception e) {
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PLNTRG);
    }   
}