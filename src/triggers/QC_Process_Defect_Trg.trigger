trigger QC_Process_Defect_Trg on Process_Defect__c (before insert,before update) {
      if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
          QCTriggerHandler.ProcessDefect_BeforeTrigger(Trigger.New);
         }
}