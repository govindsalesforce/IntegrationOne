/* @description Helps determine if errors occurred during the DML operations performed during the transaction, and with 
 * the necessary storing and notification of these errors.
 */ 
public with sharing class ERR_Handler {
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
                   This method should be used from inside the NPSP package, instead of the same one with that same name
                   that takes a String instead of an Enum as the second parameter.
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    public static void processError(Exception e, ERR_Handler_API.Context context) {     
        processError(e, context.name());   
    }
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception, stores it in the database (if enabled), and sends error
    *              notifications (if enabled).
    * @param e Exception to create error record from.
    * @return context The context the exception was raised on.
    */
    public static void processError(Exception e, String context) {     
        if(e != null) {         
            Error__c error = createError(e);
            processErrors(new Error__c[]{error}, context);
        }   
    }
    
    /*******************************************************************************************************
    * @description Stores errors in the database (if enabled), and sends error notifications (if enabled).
    * @param errorRecords The errors to store.
    * @param context The context the errors were raised on.
    * @return void
    */
    public static void processErrors(List<Error__c> errorRecords, String context) {
        
        if(errorRecords != null && errorRecords.size() > 0) {
            if(ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorRecords[0].Full_Message__c));
            }
                    
            if(QC_custom_settings.getErrorSettings().Store_Errors_On__c) {
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Error__c','Context_Type__c,Error_Type__c,Full_Message__c,Object_Type__c,Stack_Trace__c,Record_URL__c,Posted_in_Chatter__c,Email_Sent__c,Datetime__c','create'))
                {
                   Database.insert(errorRecords, false);
                }
            }
            //ERR_Notifier takes care of checking the settings itself.
            ERR_Notifier.sendErrorNotifications(context);
        }
    }
    
    /*******************************************************************************************************
    * @description Creates an error record from an exception.
    * @param e Exception to create error record from.
    * @return Error__c Error record.
    */
    private static Error__c createError(Exception e) {
        Error__c error = new Error__c();
        error.Datetime__c = System.now();        
        error.Error_Type__c = e.getTypeName();
        error.Full_Message__c = e.getMessage();
        //Putting it into a local string to see if that helps storing the stack trace when we
        //are in a managed package.
        String stackTrace = e.getStackTraceString();
        String message = 'No stacktrace available at the time of saving the record. ';
        
        error.Stack_Trace__c = message + stackTrace;
        return error;
    }
}