trigger NC_Product_defect_Trg on NC_Product_Defect__c (before insert, before update) {

      if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
      {
              NonConformanceTriggerHandler.NCProductDefect_BeforeTrigger(Trigger.New);
       }   
       
    
}