trigger General_Sub_Task_Trg on General_Sub_Task__c (before insert,before update,after insert,after update,after delete) {
  Savepoint sp = Database.setSavepoint();
    try{
         if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isBefore)
              GeneralTaskTriggerHandler.GeneralSubTask_BeforeTrigger(Trigger.new);   
        if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter)
            GeneralTaskTriggerHandler.GeneralSubTask_AfterTrigger(Trigger.newMap,Trigger.OldMap);
        if(Trigger.isdelete && Trigger.isAfter){
               GeneralTaskTriggerHandler.GeneralSubTask_Afterdelete(Trigger.old);
        }              
    }
    catch(Exception e) {
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PRCRELTRG);
    }  
}