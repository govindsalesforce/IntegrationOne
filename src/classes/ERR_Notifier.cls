// * @description Notifies specific users or groups by email when error occur.
public with sharing class ERR_Notifier{

    public static NotificationOptions notificationOptions = new NotificationOptions();
    
    /*******************************************************************************************************
    * @description Inner class with different types of notification options: user, all system
    *              administrators.
    */
    public class NotificationOptions {
        public final String sysAdmins = 'All Sys Admins';
        public final String user = '005';  //specific user (should be a system admin)
    }

    /*******************************************************************************************************
    * @description Sends error notifications to the receivers specified in the settings, if error notifications are enabled, with
    *              all the existing error records that have not been included in previous error notifications.
    * @param context The context that triggered the error notification.
    * @return void
    */
    public static void sendErrorNotifications(String context) {
        Error_Settings__c errorSettings = QC_custom_settings.getErrorSettings();
        String errorNotifRecipient = errorSettings.Error_Notifications_To__c;
            
        if (errorSettings.Error_Notifications_On__c == true && errorNotifRecipient != null) {
            //We will send email
            List<String> sendList = new List<String>();
            if (errorNotifRecipient instanceof id && errorNotifRecipient.startsWith(NotificationOptions.user)) {
                List<User> useremaillist = new List<User>();
                String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,email');
                if(queryFieldNames != null && queryFieldNames != '')
                {
                    useremaillist = database.query('Select '+ queryFieldNames +' from User where id = :errorNotifRecipient and isActive = true');
                    //useremaillist = [select email from User where id = :errorNotifRecipient and isActive = true];
                    for (User u : useremaillist){
                        sendList.add(u.email);
                    }
                }
            } 
            else if(errorNotifRecipient == NotificationOptions.sysAdmins) {
                String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,email,ProfileId');
                if(queryFieldNames != null && queryFieldNames != '')
                {
                    list<User> sysadminlist = database.query('Select '+ queryFieldNames +' from User where User.Profile.Name = \'System Administrator\' and isActive = true');
                    //list<User> sysadminlist = [select email from User where User.Profile.Name = 'System Administrator' and isActive = true];
                    for (User u : sysadminlist) {
                        sendList.add(u.email);
                    }
                }
            }
            sendEmailNotifications(context, sendList);
        }
    }

    /*******************************************************************************************************
    * @description Sends error email notifications.
    * @param context The context that triggered the error notification
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    private static void sendEmailNotifications(String context, List<String> sendList) {
        if (!system.isBatch() && !system.isFuture() && Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
            //We cannot pass the context, because only primitive types can be passed to future methods.
            sendErrorQueueEmailNotificationFuture(sendList);
        } else if (system.isFuture()) {
            sendErrorQueueEmailNotification(context, sendList);
        }
    }

    /*******************************************************************************************************
    * @description Sends error email notifications in a future (asynchronously). It will send an email with all the 
    *              existing error records not already sent in a notification.
    * @param context The context that triggered the error notification.
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    @future
    private static void sendErrorQueueEmailNotificationFuture(List<String> sendList) {
        sendErrorQueueEmailNotification(null, sendList);
    }

    /*******************************************************************************************************
    * @description Sends error email notifications synchronously. It will send an email with all the existing error
    *              records not already sent in a notification.
    * @param context The context that triggered the error notification.
    * @param sendList The list of email addresses to send notifications to.
    * @return void
    */
    private static void sendErrorQueueEmailNotification(String context, List<String> sendList) {
       String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Error__c','Id,Error_Type__c,Datetime__c,Full_Message__c,Record_URL__c,Context_Type__c,Stack_Trace__c');
       List<Error__c> errors;
       if(queryFieldNames != null && queryFieldNames != '')
       {
            errors = database.query('Select '+ queryFieldNames +' from Error__c where Email_Sent__c = false');
       }
       
       /* List<Error__c> errors = [select Id, Error_Type__c, Datetime__c, Full_Message__c, Record_URL__c, Context_Type__c,
                                        Stack_Trace__c from Error__c where Email_Sent__c = false]; */

        if (!errors.isEmpty() && !sendList.isEmpty()) {
            Messaging.SingleEmailMessage sme = createEmailMessage(context, errors, sendList);
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sme}); // Temporarily comment if error SINGLE_EMAIL_LIMIT_EXCEEDED is received

            for(Error__c error : errors) {
                error.Email_Sent__c = true;
            }

            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Error__c','Email_Sent__c', 'update')) {
                update errors;
            }
        }
    }

    /*******************************************************************************************************
    * @description Creates the email message to send as error notification.
    * @param context The context that triggered the error notification.
    * @param errorList The list of errors to include in the email.
    * @param sendList The list of email recipients.
    * @return 
    */
    private static Messaging.SingleEmailMessage createEmailMessage(String context, List<Error__c> errorList, List<String> sendList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setReplyTo('system@qualityze.com');
        mail.setSenderDisplayName('Qualityze Inc.');
        mail.setSubject('QPMS Error');
        string bodyString = 'Organization: ' + UserInfo.getOrganizationName() + '(' + UserInfo.getOrganizationId() + ')\n';
        bodyString += 'User: ' + UserInfo.getUserName() + '(' + UserInfo.getUserId() + ')';
        bodyString += '\n\nErrors:';
        Integer i = 1;
        for (Error__c error : errorList){
            bodystring += '\n\n----------\n Error #' + i + ': \n' + getErrorMessageBody(error);
            i++;
        }
        mail.setPlainTextBody(bodyString);
        mail.setToAddresses(sendList); 
        return mail;        
    }

    /*******************************************************************************************************
    * @description Creates the body of the error message for a specific error record.
    * @param error The error record to create the message string from.
    * @return String The string representing the error record.
    */
    private static String getErrorMessageBody(Error__c error) {
        String body = '\nError Type: ' + error.Error_Type__c;
        body += '\nError Date: ' + error.Datetime__c;
        body += '\nMessage: "' + error.Full_Message__c + '"';
        if(error.Record_URL__c != null)
            body += '\n' + error.Record_URL__c;
        if(error.Context_Type__c != null)
            body += '\nContext: ' + error.Context_Type__c;
        body += '\n\nStack Trace:\n ' + error.Stack_Trace__c;
        return body;
    }
}