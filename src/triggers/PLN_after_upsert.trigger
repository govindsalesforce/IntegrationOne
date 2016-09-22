trigger PLN_after_upsert on Product_Lot_Numbers__c (after insert, after update,after delete) {

        
        if(Trigger.isAfter && !Trigger.isDelete){
            NonConformanceTriggerHandler.ProductLotNumbers_IsAfter(Trigger.New);
        }
        
        if(Trigger.isInsert && Trigger.isafter)
        {
            NonConformanceTriggerHandler.ProductLotNumbers_AfterInsertTrigger(Trigger.New);
        }    
        if((Trigger.isUpdate) && Trigger.isAfter)
            NonConformanceTriggerHandler.ProductLotNumbers_AfterUpdate(Trigger.newMap,Trigger.oldMap,Trigger.New);  
        
        if(Trigger.isdelete && Trigger.isAfter){
            NonConformanceTriggerHandler.ProductLotNumbers_Afterdelete(Trigger.old);
        }                
  
}