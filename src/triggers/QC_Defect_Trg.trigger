trigger QC_Defect_Trg on Defect__c (before insert,before update,after insert,after update) {
    try{        
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
        {
            QCTriggerHandler.Defect_BeforeTrigger(Trigger.New);
        }   
    }catch(Exception e){
        system.debug('Exception in beforetrigger QC_Defect_Trg on Defect__c '+e);
    }
        try{    
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isafter)
    {
          QCTriggerHandler.Defect_AfterTrigger(Trigger.New);
    }     
      }catch(Exception e){
        system.debug('Exception in aftertrigger QC_Defect_Trg on Defect__c '+e);
    }
 }