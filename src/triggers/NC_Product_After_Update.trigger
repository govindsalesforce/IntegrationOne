trigger NC_Product_After_Update on NC_Product__c (after update,after insert) {
    Savepoint sp = Database.setSavepoint();
    try {  
      Set<Id> ncpids = new set<Id>();
      for(NC_Product__c ncp:trigger.new){
          if(trigger.oldmap!=null&&trigger.oldmap.keyset().contains(ncp.id))// line added by balu
          if(trigger.oldmap.get(ncp.id).Product__c != ncp.product__c && ncp.product__c != null)
              ncpids.add(ncp.id);
      }
        
      List<Product_Lot_Numbers__c> todelete = [select id from Product_Lot_Numbers__c where NC_Product__c IN :ncpids];
      if(todelete.size() > 0)
        delete todelete;
        
        //==============================================
        if((Trigger.isInsert ) && Trigger.isAfter)  
            NonConformanceTriggerHandler.NCProduct_AfterInsert(Trigger.newMap);   
        if((Trigger.isUpdate) && Trigger.isAfter)
            NonConformanceTriggerHandler.NCProduct_AfterUpdate(Trigger.newMap,Trigger.oldMap);          
        if(Trigger.isdelete && Trigger.isAfter){
            NonConformanceTriggerHandler.NCProduct_Afterdelete(Trigger.old);
        }
        
        
    }
    catch(Exception e) {
        system.debug('Exception in NC_Product__c NC_Product_After_Update '+e);
        Database.rollback(sp);
        ERR_Handler.processError(e, ERR_Handler_API.Context.PRODTRG);
    }   
}