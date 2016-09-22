trigger NC_Action_Plan_Root_Cause_Trg_Cls  on Action_Plan_Root_Cause__c (after insert, after update,after delete,before insert,before update) {

  Savepoint sp = Database.setSavepoint();
  try{  
       if((Trigger.isInsert ) && Trigger.isAfter)  
            GeneralTaskTriggerHandler.ActionPlanRootCause_AfterInsert(Trigger.newMap);   
        if((Trigger.isUpdate) && Trigger.isAfter)
            GeneralTaskTriggerHandler.ActionPlanRootCause_Afterupdate(Trigger.newMap,Trigger.oldMap);  
        
        if(Trigger.isdelete && Trigger.isAfter){
            GeneralTaskTriggerHandler.ActionPlanRootCause_Afterdelete(Trigger.old);
        }     
    }
  catch(Exception e) {
      Database.rollback(sp);
      ERR_Handler.processError(e, ERR_Handler_API.Context.PLNTRG);
  }    

}