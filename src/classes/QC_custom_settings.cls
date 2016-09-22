// @description Helper class that retrieves custom settings and sets defaults.
public with sharing class QC_custom_settings {
    
    public static String customLabelKeys{get;set;}
    public static Map<String,Custom_Labels__c> customLabels{get;set;}
    //To get all custom field details of custom setting Custom_Fields__c
    static{
    	customLabelKeys='';
    	customLabels=Custom_Labels__c.getAll();
    	for(String key : customLabels.keySet()){
    		customLabelKeys+=key;
    	}
    }
    public static String FilterKeys{get;set;}
    public static Map<String,Lookup_Filter__c> LookupFilter{get;set;}
    public static Map<String,String> Subkey{get;set;}
    //To get all custom field details of custom setting Custom_Fields__c
    static{
        FilterKeys='';
        LookupFilter=new Map<String,Lookup_Filter__c>();
        Subkey=new Map<String,String>();
        for(Lookup_Filter__c LF : Lookup_Filter__c.getAll().values()){
            FilterKeys+=LF.Object_Name__c;
            LookupFilter.put(LF.Field_Name__c, LF);
            if(!Subkey.containsKey(string.valueof(LF.Object_Name__c))){	
                
                Subkey.put(string.valueof(LF.Object_Name__c),(string.valueof(LF.Field_Name__c)));
            }else{
                
                Subkey.put(string.valueof(LF.Object_Name__c), Subkey.get(string.valueof(LF.Object_Name__c))+string.valueof(LF.Field_Name__c));
            }
        }
        
        system.debug('FilterKeys=='+FilterKeys);
        system.debug('Subkey=='+Subkey);
    }
    
    public QC_custom_settings(NonConformance controller){}
    
    //Usage in VisualForce Page --> {! $Setup.Dev_Only__c.Namespace_Prefix__c }
    public static string getPrefix(){
       return Dev_Only__c.getOrgDefaults().Namespace_Prefix__c;
    }
    
    public static string getAPI_Version(){
        return Dev_Only__c.getOrgDefaults().API_Version__c;
    }
    
    public static string getServer(){
       return QC_settings__c.getOrgDefaults().Instance_Name__c;
    }
    
    public static String getConsumerKey(){
        return QC_settings__c.getOrgDefaults().Connected_App_consumer_key__c;
    }
    
    public static String getConsumerSecret(){
       return QC_settings__c.getOrgDefaults().Connected_App_consumer_secret__c; 
    }
    
    public static Integer getMaxApprovers(){
      return Integer.valueOf(QC_settings__c.getOrgDefaults().Max_Approvers__c);
    }
    
    public static Boolean getDigitalSignatureNeeded(){
        return Boolean.valueOf(QC_settings__c.getOrgDefaults().Is_Digital_Signature_Needed__c);
    }
    
    public static Boolean getNeedAdditionalResolutionCodes(){
        return Boolean.valueOf(QC_settings__c.getOrgDefaults().Need_Additional_Resolution_Codes__c);
    }
    
    public static Boolean getExternalSystemCapaReferenceNeeded(){
    	return Boolean.valueOf(QC_settings__c.getOrgDefaults().Is_External_System_Capa_Reference_Needed__c);
    }
    
    
    public static Integer getNumberOfDaysForAlerts(){
        system.debug('Integer.valueOf(QC_settings__c.getOrgDefaults().Number_Of_Days_For_Alerts__c)   '+Integer.valueOf(QC_settings__c.getOrgDefaults().Number_Of_Days_For_Alerts__c));
        return Integer.valueOf(QC_settings__c.getOrgDefaults().Number_Of_Days_For_Alerts__c);
    }
    
    public static String getRootCauseId(){
       return QC_settings__c.getOrgDefaults().Root_Cause_RecordTypeId__c; 
    }
    
    public static String getActionPlanId(){
       return QC_settings__c.getOrgDefaults().Action_Plan_RecordTypeId__c; 
    }
    
    public static String getVerificationPlanId(){
       return QC_settings__c.getOrgDefaults().Verification_Plan_RecordTypeId__c; 
    }
    
    public static String getAdhocId(){
       return QC_settings__c.getOrgDefaults().AdhocTask_Actions_RecordTypeId__c; 
    }
    
    public static Boolean getEnableNC(){
    	return Boolean.valueOf(QC_settings__c.getOrgDefaults().Enable_NC__c);
    }
    
    public static Boolean getEnableCAPA(){
        return Boolean.valueOf(QC_settings__c.getOrgDefaults().Enable_CAPA__c);
    }
    
    public static Boolean getEnableDOC(){
        return Boolean.valueOf(QC_settings__c.getOrgDefaults().Enable_DOC__c);
    }
    
    public QC_custom_settings() {
        
    }
    
    public QC_custom_settings(ApexPages.StandardController controller) {
        
    }
    
    public QC_custom_settings(Component_Handler controller) {
        
    }
    
    public QC_custom_settings(FileAttachmentController controller){
        
    }
    
    public QC_custom_settings(CAPA controller){
        
    }
    
     public QC_custom_settings(DocumentProfileControllerExt controller){
        
    }
    
    //storing user-level custom settings in-memory to avoid trying to insert/update them 
    //twice and thus trigger the "duplicate OwnerId" error
    static Error_Settings__c errorSettings;
    
    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static Error_Settings__c orgErrorSettings;    
    
    /*******************************************************************************************************
    * @description Returns the default Error Handling settings. 
    * @return Error_Settings__c Custom settings record for Error Handling configuration. At the org level, if no user 
    * level settings are defined. The ID field should be checked to determine if the returned record already
    * exists or doesn't exist in the database.
    */
    public static Error_Settings__c getErrorSettings() {
        if(Test.isRunningTest() && errorSettings == null) {
            errorSettings = new Error_Settings__c();
            configErrorSettings(errorSettings, null);
        } else if(errorSettings == null) {
            errorSettings = Error_Settings__c.getInstance();
            if(errorSettings.Id == null)
                errorSettings = getOrgErrorSettings();
        }    
        return errorSettings;
    }
    
    /*******************************************************************************************************
    * @description Returns the org-level Error settings. Default org-level settings will be created 
    * if none exist. Meant to be called only from settings page and install script.
    * @return Error_Settings__c Org-level settings for Errors.
    */
    public static Error_Settings__c getOrgErrorSettings() {
        if(orgErrorSettings == null) {
            orgErrorSettings = Error_Settings__c.getOrgDefaults();
            if(orgErrorSettings.Id == null) {
                configErrorSettings(orgErrorSettings, null);
                if(!Test.isRunningTest())
                    upsert orgErrorSettings;
            }
        }
        return orgErrorSettings;
    }
    
    private static void configErrorSettings(Error_Settings__c es, String notificationsTo) {   
        es.Store_Errors_On__c = true;
        es.Error_Notifications_On__c = true;
        es.Error_Notifications_To__c = ERR_Notifier.NotificationOptions.sysAdmins;
        es.Disable_Error_Handling__c = false;
        es.Enable_Debug__c = false;
    }
    
    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, 
    * but all other methods will see these settings as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Error_Settings__c The configured settings.
    **/
    public static Error_Settings__c getErrorSettingsForTests(Error_Settings__c mySettings) {
        if(errorSettings == null)
           errorSettings = new Error_Settings__c();
           
        errorSettings.Error_Notifications_On__c = mySettings.Error_Notifications_On__c;   
        errorSettings.Error_Notifications_To__c = mySettings.Error_Notifications_To__c;
        errorSettings.Store_Errors_On__c = mySettings.Store_Errors_On__c;
        orgErrorSettings = errorSettings;
        return errorSettings;  
    }   
    
    public static string removeNamespaceFromFieldName(string fieldNameThatMightHaveANamespace) {
        string stringToReturn = '';
        string namespacePrefix = getPrefix();
        if (string.isBlank(namespacePrefix)) {
            // No namespace detected in the environment so won't even try to remove the namespace
            return fieldNameThatMightHaveANamespace;
        }
        string namespacePrefixWithUnderscores = namespacePrefix + '__';
        // need to ask mahesh
        if(fieldNameThatMightHaveANamespace.startsWithIgnoreCase(namespacePrefixWithUnderscores)){
            stringToReturn = fieldNameThatMightHaveANamespace.removeStart(namespacePrefixWithUnderscores);
        }else{
        	stringToReturn = fieldNameThatMightHaveANamespace;    
        }
        
        return stringToReturn;
    }
}