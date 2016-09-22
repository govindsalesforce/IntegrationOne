trigger Disposition_Product_Trg on Disposition_Product__c (before insert,before update,after insert, after update,after delete) {
 Savepoint sp = Database.setSavepoint();
    //try{ 
          
        if((Trigger.isInsert ) && Trigger.isAfter)  
              GeneralTaskTriggerHandler.DispProduct_Afterinsert(Trigger.newMap);   
        if((Trigger.isUpdate) && Trigger.isAfter)
               GeneralTaskTriggerHandler.DispProduct_AfterUpdate(Trigger.newMap,Trigger.oldMap);  
        
        if(Trigger.isdelete && Trigger.isAfter){
               GeneralTaskTriggerHandler.DispProduct_Afterdelete(Trigger.old);
        }               
        
    //}
    //catch(Exception e) {
    //    Database.rollback(sp);
    //    ERR_Handler.processError(e, ERR_Handler_API.Context.PRCRELTRG);
    //}
}