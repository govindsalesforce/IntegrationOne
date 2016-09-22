trigger NC_General_Task_TRG on General_Task__c (before insert,before update,after insert, after update,after delete) {
  Savepoint sp = Database.setSavepoint();
    try{
         if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isBefore)
              GeneralTaskTriggerHandler.GeneralTask_BeforeTrigger(Trigger.new, Trigger.oldMap);    
          
        if((Trigger.isInsert||Trigger.isUpdate) && Trigger.isAfter) 
               GeneralTaskTriggerHandler.GeneralTask_AfterTrigger(Trigger.newMap,Trigger.oldMap,Trigger.isInsert,Trigger.isUpdate);   
        
        //if((Trigger.isInsert&& Trigger.isAfter)
           
        
        if(Trigger.isdelete && Trigger.isAfter){
               GeneralTaskTriggerHandler.GeneralTask_Afterdelete(Trigger.old);
        }               
        
    }
    catch(Exception e) {
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PRCRELTRG);
    }  
}