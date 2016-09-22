/*
 * @description API class that exposes error handling.
 */
 global with sharing class ERR_Handler_API {
    
    global enum Context {
    	/* @description Non Conformance Management context. */
	    NCM,
	    /* @description Non Conformance Trigger Management context. */
	    NCMTRG, 
	    /* @description CAPA Management context. */
	    CAPA, 
	    /* @description Audit Management context. */
	    AUDIT, 
	    /* @description Complaint Management context. */
	    ISSUE, 
	    /* @description Document Management context. */
	    DOC, 
	    /* @description Training Management context. */
	    TRAIN, 
	    /* @description Change Management context. */
	    CM, 
	    /* @description Supplier Management context. */
	    SUP, 
	    /* @description Product context. */
	    PROD,
	    /* @description Product Trigger context. */
	    PRODTRG,
	    /* @description PLN Trigger context. */
	    PLNTRG, 
	    /* @description File Attachment context. */
	    FILE, 
	    /* @description Header context. */
	    HEAD, 
	    /* @description Process Relationship context. */
	    PRCREL, 
	    /* @description Product Relationship context. */
	    PRDREL,
	    /* @description Process Relationship Trigger context. */
	    PRCRELTRG, 
	    /* @description Product Relationship Trigger context. */
	    PRDRELTRG, 
	    /* @description Risk Priority context. */
	    RISK, 
	    /* @description Utility context. */
	    UTIL, 
	    /* @description Search context. */
	    FIND, 
	    /* @description Component context. */
	    COMP,
	    /* @description Schedulable context. */
	    SCH, 
	    /* @description Settings context. */
	    STTG
    }
     
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    global static void processError(Exception e, String context) {
        ERR_Handler.processError(e, context);
    }
}