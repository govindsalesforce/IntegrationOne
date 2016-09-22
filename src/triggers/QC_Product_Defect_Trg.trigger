trigger QC_Product_Defect_Trg on Product_Defect__c(before insert,before update) {
      if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
         QCTriggerHandler.ProductDefect_BeforeTrigger(Trigger.New);
        }
}