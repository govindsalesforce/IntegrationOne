trigger QC_Defect_Cause_Trg on Defect_Cause__c (before insert,before update) {

    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore)
    QCTriggerHandler.DefectCause_BeforeTrigger(trigger.new);

}