trigger CAPA on CAPA__c (before insert, before update, after insert, after update) {
	Savepoint sp = Database.setSavepoint();
	try {
		if(Trigger.isBefore && Trigger.isUpdate) {
			CapaTriggerHandler.TriggerMethodBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
		}
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            CapaTriggerHandler.afterTrigger(Trigger.newMap,Trigger.oldMap);
        }
	}
	catch(Exception e) {
	    Database.rollback(sp);
	    ERR_Handler.processError(e, ERR_Handler_API.Context.CAPA);
	}	
}