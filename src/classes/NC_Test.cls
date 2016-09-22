/*
 
     v1.0  Qualityze Inc(TS)        05-MAY-2016    Initial Version.
                                                   This Test class includes all NC,general tasks

*/

@isTest(seeAllData=false)
public with sharing class NC_Test{
    // Risky Objects
    // Detection
    //public static Risk_Detection__c easyDetect; 
    //public static Risk_Detection__c difficultDetect;
    //public static List<Risk_Detection__c> detectionProbabilitiesList;
    // Occurence
    public static Risk_Occurrence__c unlikelyOccur;
    public static Risk_Occurrence__c likelyOccur;
    public static List<Risk_Occurrence__c> occurrenceProbabilitiesList;
    // Severity
    public static Risk_Severity__c notSoSevere;
    public static Risk_Severity__c verySevere;
    public static List<Risk_Severity__c> severityLevelsList;
    // Priority
    public static Risk_Priority__c lowPriority;
    public static Risk_Priority__c mediumPriority;
    public static Risk_Priority__c highPriority;
    public static List<Risk_Priority__c> riskPrioritiesList;  
    // Lookup
    // Without Detection Probability
    public static Risk_Lookup__c unlikelyOccur_notSoSevere;
    public static Risk_Lookup__c unlikelyOccur_verySevere;
    public static Risk_Lookup__c likelyOccur_notSoSevere;
    public static Risk_Lookup__c likelyOccur_verySevere;
    // With Detection Probability
    //public static Risk_Lookup__c unlikelyOccur_notSoSevere_easyDetect;
    //public static Risk_Lookup__c unlikelyOccur_verySevere_easyDetect;
    //public static Risk_Lookup__c likelyOccur_notSoSevere_easyDetect;
    //public static Risk_Lookup__c likelyOccur_verySevere_easyDetect;
    //public static Risk_Lookup__c unlikelyOccur_notSoSevere_difficultDetect;
    //public static Risk_Lookup__c unlikelyOccur_verySevere_difficultDetect;
    //public static Risk_Lookup__c likelyOccur_notSoSevere_difficultDetect;
    //public static Risk_Lookup__c likelyOccur_verySevere_difficultDetect;
    public static List<Risk_Lookup__c> riskLookupsListwithOUTdetection;
    //public static List<Risk_Lookup__c> riskLookupsListWITHdectection;
    
    
    // Pulling From Risky Objects so we'll call it
    // FRisky Objects
    public static List<Non_Conformance__c> nonConformancesList;
    public static List<Defect__c> defectList;
    public static List<Process__c> processList;
    public static List<User> userList;

    public static List<General_Task__c> genTaskList;
    public static List<Product__c> productList;
    public static List<Defect__c> defectListNCT;
    
    public static List<General_Sub_Task__c> actionplanList;
    public static List<Action_Plan_Root_Cause__c> aprcList;
    
    public static void init() {
            
        Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        //dev_settings.Namespace_Prefix__c = 'QPMS';
        //dev_settings.Namespace_Prefix__c = 'QPMSQC2';
        dev_settings.Namespace_Prefix__c = '';
        //dev_settings.Namespace_Prefix__c = 'QPMSQCTEST';
        dev_settings.API_Version__c = '33.0';
        upsert dev_settings;        
        
        QC_settings__c qc_settings = QC_settings__c.getOrgDefaults();
    //qc_settings.Instance_Name__c = 'na16';
    qc_settings.Instance_Name__c = 'na22';
    qc_settings.Connected_App_consumer_key__c = 'abc';
    qc_settings.Connected_App_consumer_secret__c = '123';
    qc_settings.Enable_CAPA__c = true;
    qc_settings.Enable_NC__c = true;
    qc_settings.Enable_DOC__c = true;
    upsert qc_settings;
        
        
        unlikelyOccur = new Risk_Occurrence__c(Name = 'Unlikely to occur', Number__c = 1);
        likelyOccur = new Risk_Occurrence__c(Name = 'Likely to occur', Number__c = 2);
        occurrenceProbabilitiesList = new List<Risk_Occurrence__c>();
        occurrenceProbabilitiesList.add(unlikelyOccur);
        occurrenceProbabilitiesList.add(likelyOccur);
        insert occurrenceProbabilitiesList;

        notSoSevere = new Risk_Severity__c(Name = 'Not so severe', Number__c = 1);
        verySevere = new Risk_Severity__c(Name = 'Very severe', Number__c = 2);
        severityLevelsList = new List<Risk_Severity__c>();
        severityLevelsList.add(notSoSevere);
        severityLevelsList.add(verySevere);
        insert severityLevelsList;
        
        lowPriority = new Risk_Priority__c(Name = 'Low Priority', Number__c = 1);
        mediumPriority = new Risk_Priority__c(Name = 'Medium Priority', Number__c = 2);
        highPriority = new Risk_Priority__c(Name = 'High Priority', Number__c = 3);
        riskPrioritiesList = new List<Risk_Priority__c>();
        riskPrioritiesList.add(lowPriority);
        riskPrioritiesList.add(mediumPriority);
        riskPrioritiesList.add(highPriority);
        insert riskPrioritiesList;
        
        unlikelyOccur_notSoSevere = new Risk_Lookup__c(
            Occurrence_Probability__c = unlikelyOccur.Id, 
            Severity_Level__c = notSoSevere.Id, 
            Risk_Priority__c = lowPriority.Id);
        unlikelyOccur_verySevere = new Risk_Lookup__c(
            Occurrence_Probability__c = unlikelyOccur.Id, 
            Severity_Level__c = verySevere.Id, 
            Risk_Priority__c = mediumPriority.Id);
        likelyOccur_notSoSevere = new Risk_Lookup__c(
            Occurrence_Probability__c = likelyOccur.Id, 
            Severity_Level__c = notSoSevere.Id, 
            Risk_Priority__c = mediumPriority.Id);
        likelyOccur_verySevere = new Risk_Lookup__c(
            Occurrence_Probability__c = likelyOccur.Id, 
            Severity_Level__c = verySevere.Id, 
            Risk_Priority__c = highPriority.Id);
//        unlikelyOccur_notSoSevere_easyDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = unlikelyOccur.Id, 
//            Severity_Level__c = notSoSevere.Id, 
//            Risk_Priority__c = lowPriority.Id,
//            Detection_Probability__c = easyDetect.Id);
//        unlikelyOccur_verySevere_easyDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = unlikelyOccur.Id, 
//            Severity_Level__c = verySevere.Id, 
//            Risk_Priority__c = mediumPriority.Id,
//            Detection_Probability__c = easyDetect.Id);
//        likelyOccur_notSoSevere_easyDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = likelyOccur.Id, 
//            Severity_Level__c = notSoSevere.Id, 
//            Risk_Priority__c = mediumPriority.Id,
//            Detection_Probability__c = easyDetect.Id);
//        likelyOccur_verySevere_easyDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = likelyOccur.Id, 
//            Severity_Level__c = verySevere.Id, 
//            Risk_Priority__c = highPriority.Id,
//            Detection_Probability__c = easyDetect.Id);
//        unlikelyOccur_notSoSevere_difficultDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = unlikelyOccur.Id, 
//            Severity_Level__c = notSoSevere.Id, 
//            Risk_Priority__c = lowPriority.Id,
//            Detection_Probability__c = difficultDetect.Id);
//        unlikelyOccur_verySevere_difficultDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = unlikelyOccur.Id, 
//            Severity_Level__c = verySevere.Id, 
//            Risk_Priority__c = mediumPriority.Id,
//            Detection_Probability__c = difficultDetect.Id);
//        likelyOccur_notSoSevere_difficultDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = likelyOccur.Id, 
//            Severity_Level__c = notSoSevere.Id, 
//            Risk_Priority__c = mediumPriority.Id,
//            Detection_Probability__c = difficultDetect.Id);
//        likelyOccur_verySevere_difficultDetect = new Risk_Lookup__c(
//            Occurrence_Probability__c = likelyOccur.Id, 
//            Severity_Level__c = verySevere.Id, 
//            Risk_Priority__c = highPriority.Id,
//            Detection_Probability__c = difficultDetect.Id);
        riskLookupsListwithOUTdetection = new List<Risk_Lookup__c>();
        riskLookupsListwithOUTdetection.add(unlikelyOccur_notSoSevere);
        riskLookupsListwithOUTdetection.add(unlikelyOccur_verySevere);
        riskLookupsListwithOUTdetection.add(likelyOccur_notSoSevere);
        riskLookupsListwithOUTdetection.add(likelyOccur_verySevere);
//        riskLookupsListWITHdectection = new List<Risk_Lookup__c>();
//        riskLookupsListWITHdectection.add(unlikelyOccur_notSoSevere_easyDetect);
//        riskLookupsListWITHdectection.add(unlikelyOccur_verySevere_easyDetect);
//        riskLookupsListWITHdectection.add(likelyOccur_notSoSevere_easyDetect);
//        riskLookupsListWITHdectection.add(likelyOccur_verySevere_easyDetect);
//        riskLookupsListWITHdectection.add(unlikelyOccur_notSoSevere_difficultDetect);
//        riskLookupsListWITHdectection.add(unlikelyOccur_verySevere_difficultDetect);
//        riskLookupsListWITHdectection.add(likelyOccur_notSoSevere_difficultDetect);
//        riskLookupsListWITHdectection.add(likelyOccur_verySevere_difficultDetect);
        
        nonConformancesList = new List<Non_Conformance__c>();
        defectList = new List<Defect__c>();
        defectList.add(new Defect__c(
            Name = 'Crack in space/time continuum 2', 
            Defect_Code__c = '1.32 Gigawattss!',
            Suspect_Enabled__c='Yes',  
            Active__c = True
        ));
        //insert defectList;
        try{
        system.debug('inside before upsert defectList'); 
        upsert defectList;    
        }catch(exception e){
            system.debug('inside nonconformance test upsert defectList'+e); 
        }
        
        processList = new List<Process__c>();
        processList.add(new Process__c(
            Name = 'Lie about cake to all test subjects'
        ));
        insert processList;
        userList = new List<User>();
        Profile p = [select id FROM Profile WHERE Name ='System Administrator'];
        Profile SU = [select id FROM Profile WHERE Name ='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;        
        userList.add(new User(
            FirstName = 'Selena', 
            LastName = 'Kyle',
            Username = uniqueName + 'Selena.Kyle@Gotham.com', 
            Email = 'CatSkills@Gotham.com', 
            Alias = 'Catwoman', 
            CommunityNickname = 'CatWoman', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US'
            
        ));
        
        orgId = UserInfo.getOrganizationId();
        dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt; 
        userList.add(new User(
            FirstName = 'Bruce', 
            LastName = 'Wayne',
            Username = uniqueName + 'Bruce.Wayne@Gotham.com', 
            Email = 'Dective@Gotham.com', 
            Alias = 'Batman', 
            CommunityNickname = 'DC', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = SU.Id, 
            LanguageLocaleKey = 'en_US'
        ));
        insert userList;
    }
    
    static void initWithOUTDetection() {
        init();
        insert riskLookupsListwithOUTdetection;
    }
    
    
    public static void initData(){
           init();
            productList=new List<Product__c>();
            productList.add(new Product__c(Name='Test Prod',Product_Number__c='1111'));
            
            upsert productList;

            nonConformancesList.add(new Non_Conformance__c(

            Risk_Occurrence__c = likelyOccur.Id,
            Risk_Severity__c = verySevere.Id,
            Defect__c = defectList[0].Id,
            Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            NC_Source__c = 'Other',
            Occurance_Date__c = Date.today(),
            Other_Source__c = 'The other other white meat',
            NC_Type__c = 'Process',
            Process__c = processList[0].Id,
            Reporter__c = userList[0].Id,
            NC_Status__c='NC Workflow',
            NC_Resolution_Code__c='NC Workflow',
            //CAPA_Number__c='CAPA-0123',
            Followers__c=UserInfo.getUserId()
        ));
        
        insert nonConformancesList;
            
            genTaskList=new List<General_Task__c>();
            
            genTaskList.add(new General_Task__c(
                Sequence__c='10',
                Sequence_Position__c=10,
                Owner__c=userList[0].Id,
                Allowed_Days__c=4,
                Due_Date__c=Date.parse('1/9/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Containment').getRecordTypeId(),
                Status__c='Open'
             ));
            
            genTaskList.add(new General_Task__c(
                Sequence__c='10',
                Sequence_Position__c=10,
                Owner__c=userList[0].Id,
                Allowed_Days__c=4,
                Due_Date__c=Date.parse('1/9/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Disposition').getRecordTypeId(),
                Status__c='Open'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='20',
                Sequence_Position__c=20,
                Owner__c=userList[0].Id,
                Allowed_Days__c=5,
                Due_Date__c=Date.parse('1/10/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Investigation').getRecordTypeId(),
                Status__c='Open'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='30',
                Sequence_Position__c=30,
                Owner__c=userList[0].Id,
                Allowed_Days__c=6,
                Due_Date__c=Date.parse('1/11/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Implementation').getRecordTypeId(),
                Status__c='Open'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='40',
                Sequence_Position__c=40,
                Owner__c=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
                Status__c='Open'
             ));
             
             genTaskList.add(new General_Task__c(
                Sequence__c='40',
                Sequence_Position__c=40,
                Owner__c=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId(),
                Status__c='Open'
             ));
            
            insert genTaskList;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: NC_Header
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public Static String reasonfor_reopen;
    public static Boolean isClosurePending;
    public static Map<String, String> genTaskIds;
    public static Map<String,List<String>> tasks ;
    public static Map<String,String> ncData;
    public static List<General_Sub_Task__c> acps;
    public static List<General_Sub_Task__c> dispsecs;

   public static void nc_headerData(){
      init();
      reasonfor_reopen='Tesast reason data string';
      nonConformancesList = new List<Non_Conformance__c>();
      nonConformancesList.add(new Non_Conformance__c(
                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                Process__c = processList[0].Id,
                Reporter__c =userList[0].Id,
                NC_Status__c='Closed',
                Reopen_Date__c=Date.parse('1/9/2016'),
                Reopen_By__c=userList[0].Id,
                ownerid=userList[0].Id,
                NC_Workflow_Status__c='Open',
                NC_Resolution_Code__c='NC Workflow'
                
            ));
            nonConformancesList.add(new Non_Conformance__c(
                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                Process__c = processList[0].Id,
                Reporter__c =userList[0].Id,
                NC_Status__c='open',
                Reopen_Date__c=Date.parse('1/9/2016'),
                Reopen_By__c=userList[0].Id,
                ownerid=userList[0].Id,
                NC_Workflow_Status__c='Open',
                NC_Resolution_Code__c='NC Workflow'
                
            )); 
        nonConformancesList.add(new Non_Conformance__c(
                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                Process__c = processList[0].Id,
                Reporter__c =userList[0].Id,
                NC_Status__c='Void',
                Reopen_Date__c=Date.parse('1/9/2016'),
                Reopen_By__c=userList[0].Id,
                ownerid=userList[0].Id,
                NC_Workflow_Status__c='Closed',
                NC_Resolution_Code__c='NC Workflow'
                
            )); 
        nonConformancesList.add(new Non_Conformance__c(
                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                Process__c = processList[0].Id,
                Reporter__c =userList[0].Id,
                NC_Status__c='Void',
                Reopen_Date__c=Date.parse('1/9/2016'),
                Reopen_By__c=userList[0].Id,
                ownerid=userList[0].Id,
                NC_Workflow_Status__c='Closed',
                NC_Resolution_Code__c='Discarded' 
                
            ));
            upsert nonConformancesList;
            Map<String,List<sObject>> childobjs = new Map<String,List<sObject>>();
            genTaskIds = new Map<String, String>();
        
            genTaskList=new List<General_Task__c>();
            
            genTaskList.add(new General_Task__c(
                Sequence__c='10',
                Sequence_Position__c=10,
                OwnerId=userList[0].Id,
                Allowed_Days__c=4,
                Due_Date__c=Date.parse('1/9/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Containment').getRecordTypeId(),
                Status__c='Closed'
             ));
            
            genTaskList.add(new General_Task__c(
                Sequence__c='10',
                Sequence_Position__c=10,
                OwnerId=userList[0].Id,
                Allowed_Days__c=4,
                Due_Date__c=Date.parse('1/9/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Disposition').getRecordTypeId(),
                Status__c='Closed'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='20',
                Sequence_Position__c=20,
                OwnerId=userList[0].Id,
                Allowed_Days__c=5,
                Due_Date__c=Date.parse('1/10/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Investigation').getRecordTypeId(),
                Status__c='Closed'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='30',
                Sequence_Position__c=30,
                OwnerId=userList[0].Id,
                Allowed_Days__c=6,
                Due_Date__c=Date.parse('1/11/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Implementation').getRecordTypeId(),
                Status__c='Closed'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='40',
                Sequence_Position__c=40,
                OwnerId=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
                Status__c='Closed'
             ));
             genTaskList.add(new General_Task__c(
                Sequence__c='40',
                AdhocTask_Title__c='TestTitle',
                Sequence_Position__c=40,
                OwnerId=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                Non_Conformance__c=nonConformancesList[0].Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId(),
                Status__c='Closed'
             ));
            
            insert genTaskList;
            System.debug('genTaskList in test class----->'+genTaskList);
            genTaskIds.put('Containment', genTaskList[0].id);
            genTaskIds.put('Disposition', genTaskList[1].id);
            genTaskIds.put('Investigation', genTaskList[2].id);
            genTaskIds.put('Implementation', genTaskList[3].id);
            genTaskIds.put('Closure', genTaskList[4].id);
            System.debug('genTaskIds---------->'+genTaskIds);
        
        // disposition clild tasks
           dispsecs = new List<General_Sub_Task__c>();
        
           dispsecs.add(new General_Sub_Task__c(Disposition_Type__c = 'Rework',
                        Assigned_Disposition_Qty__c = 7,
                        Assigned_User__c = userList[0].Id,
                        Due_Date__c = Date.parse('9/1/2016'),
                        Disposition_Instruction__c = 'Dispo instruction',
                        Complete__c = 'No',
                        General_Task__c = genTaskList[1].Id,
                        Disposition_Type_Status__c = 'Completed'
                       ));
          dispsecs.add(new General_Sub_Task__c(Disposition_Type__c = 'SCRAP',
                        Assigned_Disposition_Qty__c = 7,
                        Assigned_User__c = userList[0].Id,
                        Due_Date__c = Date.parse('9/1/2016'),
                        Disposition_Instruction__c = 'Dispo instruction',
                        Complete__c = 'No',
                        General_Task__c = genTaskList[1].Id,
                        Disposition_Type_Status__c = 'Completed'
                       ));
        insert dispsecs;
        //Action plans 
            acps = new List<General_Sub_Task__c>();
            acps.add(new  General_Sub_Task__c(Title__c = 'The other other white meat',
                                       Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       Type__c = 'Correction',
                                       Assigned_User__c = userList[0].Id,
                                       Due_Date__c = Date.today(),
                                       Complete__c = 'Yes',
                                       Completed_By__c = userList[0].Id,
                                       Completed_Date__c = Date.today(),
                                       Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       General_Task__c = genTaskList[3].id,
                                       Action_Plan_Status__c ='Complete'
                     ));
            acps.add(new  General_Sub_Task__c(Title__c = 'The other other white meat',
                                       Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       Type__c = 'Correction',
                                       Assigned_User__c = userList[0].Id,
                                       Due_Date__c = Date.today(),
                                       Complete__c = 'Yes',
                                       Completed_By__c = userList[0].Id,
                                       Completed_Date__c = Date.today(),
                                       Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       General_Task__c = genTaskList[3].id,
                                       Action_Plan_Status__c ='Pending'
                     ));
            insert acps;
            tasks = new Map<String,List<String>>();
            List<String> dispchlildtasksIds =  new List<String>();
            dispchlildtasksIds.add(dispsecs[0].id);
            dispchlildtasksIds.add(dispsecs[1].id);
            List<String> impchlildtasksIds =  new List<String>();
            impchlildtasksIds.add(acps[0].id);
            impchlildtasksIds.add(acps[1].id);
            tasks.put('Containment@'+ genTaskList[0].id,new List<String>());
            tasks.put('Disposition@'+ genTaskList[1].id,dispchlildtasksIds);
            tasks.put('Investigation@'+ genTaskList[2].id,new List<String>());
            tasks.put('Implementation@'+ genTaskList[3].id,impchlildtasksIds);
            System.debug('tasks from test class------>'+tasks);
            ncData = new Map<String,String>();
            ncData.put('NC_Resolution_Code__c','NC Workflow');
            ncData.put('NC_Status__c','NC Workflow');
            ncData.put('Reopen_By__c',userList[0].Id);
            ncData.put('ncid',nonConformancesList[0].id);
       
    }
    
    public static testMethod void NCTaskControllerTest()
    {
        //initdata();
        nc_headerData();
        nonConformancesList[0].NC_Status__c='NC Workflow';
        
        upsert nonConformancesList;
         
        List<String> adhocTasks = new List<String>();
        List<String> taskDetails=null;
        tasks=new Map<String,List<String>>();
        taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/9/2016');
        tasks.put('Containment',taskDetails);
            
        taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/9/2016');
        tasks.put('Disposition',taskDetails);
            
        taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/9/2016');
        tasks.put('Investigation',taskDetails);
            
        taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/9/2016');
        tasks.put('Implementation',taskDetails);
        
        taskDetails=new List<String>();
        taskDetails.add('20');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/9/2016');
        tasks.put('Closure',taskDetails);
        
        taskDetails=new List<String>();
        taskDetails.add('5');
        taskDetails.add(userList[0].Id);
        taskDetails.add('3');
        taskDetails.add('2/17/2016');
        tasks.put('AdhocTask',taskDetails);
        
        adhoctasks.add('10@'+userList[0].Id+'@1@2/14/2016@adhocTaskTest1@null');
        adhoctasks.add('20@'+userList[0].Id+'@2@2/15/2016@adhocTaskTest1@null');
        adhoctasks.add('30@'+userList[0].Id+'@3@2/16/2016@adhocTaskTest1@null');
        adhoctasks.add('40@'+userList[0].Id+'@4@2/17/2016@adhocTaskTest1@null');
        adhoctasks.add('50@'+userList[0].Id+'@5@2/18/2016@adhocTaskTest1@null');

        


         Test.startTest();
            Map<String,String> results=NonConformance.createNCTasks(adhocTasks, tasks,nonConformancesList[0].Id,true,true,true);
            System.assert(!results.isEmpty());
            results=NonConformance.createNCTasks(adhocTasks, tasks,nonConformancesList[0].Id,true,false,false);
            system.debug('NCTaskControllerTest results...  '+results);
            System.assert(!results.isEmpty());
			
        	ApexPages.StandardController sc = new ApexPages.StandardController(nonConformancesList[0]);
            NonConformance ncTaskCont=new NonConformance(sc);
            Component_Handler cph = new Component_Handler(ncTaskCont);
       		integer I1 = ncTaskCont.getContainmentTaskStep();
            system.debug('ncTaskCont.I1'+I1);
            system.debug('ncTaskCont.getContainmentTaskStep()'+ncTaskCont.getContainmentTaskStep());
            integer I2 = ncTaskCont.getImplementationTaskStep();
            integer I3 = ncTaskCont.getInvestigationTaskStep();
            integer I4 = ncTaskCont.getDispositionTaskStep();
            integer I5 = ncTaskCont.getClosureTaskStep();
            integer I6 = ncTaskCont.getTotalTasks();
            //System.assert(I1>=0);
            //System.assert(I2>=0);
            //System.assert(I3>=0);
            //System.assert(I4>=0);
            //System.assert(I5>=0);
            //System.assert(I6>=0);

			Map<String,List<String>> adhocData=NonConformance.getAdhocData('NC_Task_Owner');
            System.assert(adhocData!=null);

        Test.stopTest();

    }
    
    public static testMethod void NC_Header_Test_followNC(){
        //init();
        nc_headerData();
        try{
            Test.startTest(); 
            Integer result1 = Component_Handler.followNC(nonConformancesList[0].id, userList[0].Id);
            System.assertNotEquals(1,result1);
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    public static testMethod void NC_Header_Test_unFollowNC(){
        //init();
        nc_headerData();
        try{
            Test.startTest(); 
            Integer result1 = Component_Handler.unFollowNC(nonConformancesList[0].id, userList[0].Id);
            System.assertNotEquals(1,result1);
            Integer result2 = Component_Handler.unFollowNC(null, userList[0].Id);
            System.assertNotEquals(1,result1);
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: NonConformance_can_reopen
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static testMethod void NonConformance_can_reopen() {
        initWithOUTDetection();
        Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        //dev_settings.Namespace_Prefix__c = 'QPMS';
        //dev_settings.Namespace_Prefix__c = 'QPMSQC2';
        dev_settings.Namespace_Prefix__c = '';
        //dev_settings.Namespace_Prefix__c = 'QPMSQCTEST';
        dev_settings.API_Version__c = '33.0';
        upsert dev_settings;
        
        Non_Conformance__c nc = new Non_Conformance__c(
            Defect__c = defectList[0].Id,
            Full_Description__c = 'Test description',
            NC_Source__c = 'Other',
            Occurance_Date__c = Date.today(),
            Reported_Date__c = Date.today(),
            Other_Source__c = 'The other other white meat',
            NC_Type__c = 'Process',
            Process__c = processList[0].Id,
            Reporter__c = userList[0].Id
        );
        nonConformancesList.add(nc);
        insert nonConformancesList;        
        
        ApexPages.StandardController std1=new ApexPages.StandardController(nc);
        
        
                
        Test.startTest();
        
        NonConformance constructorOnly = new NonConformance();
        System.assertNotEquals(constructorOnly, null);
        
        NonConformance nc_for_test = new NonConformance(std1);
        Boolean result_from_test = nc_for_test.getcan_reopen();
        System.assertEquals(false, result_from_test);
        
        Boolean result = NonConformance.can_reopen(nc);
        System.assertEquals(false, result);
        
        Test.stopTest();    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END NonConformance.can_reopen
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: NonConformance.deleteProduct,NonConformance.deleteBatch
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static testMethod void NC_Product_FormTest() {
        initWithOUTDetection();
        Test.startTest();
        Non_Conformance__c nc = new Non_Conformance__c(

            Risk_Occurrence__c = likelyOccur.Id,
            Risk_Severity__c = verySevere.Id,
            Defect__c = defectList[0].Id,
            Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            NC_Source__c = 'Other',
            Occurance_Date__c = Date.today(),
            Other_Source__c = 'The other other white meat',
            NC_Type__c = 'Process',
            Process__c = processList[0].Id,
            Reporter__c = userList[0].Id
        );
        nonConformancesList.add(nc);
        
        insert nonConformancesList;
        
        Product__c pr = new Product__c();
        pr.Name = 'TEST PRODUCT';
        pr.Product_Code__c = 'PRODUCT'+System.now();
        insert pr;
        
        NC_Product__c ncp = new NC_Product__c();
        ncp.Product__c = pr.Id;
        ncp.Non_Conformance__c =nonConformancesList[0].Id;
        insert ncp; 
        
       Product_Lot_Numbers__c plt = new Product_Lot_Numbers__c();
       plt.NC_Product__c = ncp.Id;
       plt.UOM__c = 'EA';
       plt.Lot_Bacth_Number__c = '25';
       insert plt;
       
        Component_Handler obj = new Component_Handler();
        obj.ncProductId = ncp.Id;
        
        NC_Product__c ncprec = NonConformance.getRemoteNCP(ncp.id);  
        List<Product_Lot_Numbers__c> lotList = obj.getLots();
    	obj.getNCP();
        Product_Lot_Numbers__c pltn = NonConformance.getLot(plt.Id);
        
        system.assertNotEquals(null,lotList);
        system.assertNotEquals(null,pltn);
        
        Component_Handler obj1 = new Component_Handler();
        obj1.ncProductId = null;
        NC_Product__c ncprec1 = NonConformance.getRemoteNCP(null);  
        List<Product_Lot_Numbers__c> lotList1 = obj1.getLots();
        
        system.assertNotEquals(null,ncprec1);
        system.assertNotEquals(null,lotList1);
    
    	ApexPages.StandardController std1=new ApexPages.StandardController(nc);
        NonConformance nc_prod_object = new NonConformance(std1);
        system.assertNotEquals(null,nc_prod_object);
        boolean delProdResult = NonConformance.deleteProduct(ncprec.id);
        system.assert(delProdResult);
        boolean delBatchResult = NonConformance.deleteBatch(plt.id);
        system.assert(delBatchResult);
        
        Test.stopTest();        
    }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END NonConformance.deleteProduct,NonConformance.deleteBatch
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// data for sub tasks
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////     
    
        public static List<General_Task__c> Containments;
        public static List<General_Task__c> Investigations;
        public static List<General_Task__c> Implementations;
        public static List<General_Task__c> Dispositions;
        public static List<General_Task__c> Closures;
        public static List<General_Task__c> AdhocTasks;
        public static List<General_Sub_Task__c> AdhocTaskActions;
        public static List<General_Sub_Task__c> ContainmentActions;
        static testMethod void initGeneralTasks(){
            List<General_Task__c> gentask=new List<General_Task__c>();
            init();
            Non_Conformance__c ncf=new Non_Conformance__c(

                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                NC_Status__c='NC Workflow',
                Process__c = processList[0].Id,
                Reporter__c = userList[0].Id
            );
            nonConformancesList.add(ncf);

            Non_Conformance__c ncf1=new Non_Conformance__c(

                Defect__c = defectList[0].Id,
                Full_Description__c = 'NC2',
                NC_Source__c = 'Other', 
                Occurance_Date__c = Date.today()-1,
                Other_Source__c = 'The other other white meat2',
                NC_Type__c = 'Process',
                NC_Status__c='NC Workflow',
                Process__c = processList[0].Id,
                Reporter__c = userList[0].Id
            );
            nonConformancesList.add(ncf1);             
            insert nonConformancesList;
            
            //test.starttest();          
            Containments=new List<General_Task__c>(); 
            Investigations=new List<General_Task__c>(); 
            Implementations=new List<General_Task__c>(); 
            Dispositions=new List<General_Task__c>(); 
            Closures=new List<General_Task__c>();
            AdhocTasks=new List<General_Task__c>();
            

            list<General_Task__c> gts=new List<General_Task__c>(); 
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c containment = new General_Task__c(Non_Conformance__c=nc.id,status__c='Open',Allowed_Days__c=3,Sequence_Position__c=10,Sequence__c='10');
                containment.RecordTypeId=Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Containment').getRecordTypeId();
                Containments.add(containment);
            }  
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c Investigation= new General_Task__c(Non_Conformance__c=nc.id,Allowed_Days__c=3,Sequence_Position__c=20,Sequence__c='20');
                Investigation.RecordTypeId= Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Investigation').getRecordTypeId();
                Investigations.add(Investigation);
            }                      
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c disposition = new General_Task__c(Non_Conformance__c=nc.id,Allowed_Days__c=3,Sequence_Position__c=20,Sequence__c='20');
                disposition.RecordTypeId= Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Disposition').getRecordTypeId();
                Dispositions.add(disposition);
            }
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c implementation = new General_Task__c(Non_Conformance__c=nc.id,Allowed_Days__c=3,Sequence_Position__c=20,Sequence__c='20');
                implementation.RecordTypeId= Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
                implementations.add(implementation);
            }
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c Closure = new General_Task__c(Non_Conformance__c=nc.id,Allowed_Days__c=3,status__c='Created',Sequence_Position__c=30,Sequence__c='30');
                Closure.RecordTypeId= Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Closure').getRecordTypeId();
                Closures.add(Closure);
            }
              
            //list<General_Task__c> gts=new List<General_Task__c>(); 
            for(non_conformance__c nc:nonConformancesList){
                General_Task__c AdhocTask = new General_Task__c(Non_Conformance__c=nc.id,Allowed_Days__c=3);
                AdhocTask.RecordTypeId=Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('AdhocTask').getRecordTypeId();
                AdhocTask.Approver__c=userList[0].Id;                                                    
                AdhocTask.Approver_1__c=userList[0].Id;                                    
                AdhocTask.Approver_2__c=userList[0].Id;                                             
                AdhocTask.Approver_3__c=userList[0].Id;
                AdhocTask.Approver_4__c=userList[0].Id;
                AdhocTask.Approver_5__c=userList[0].Id;
                AdhocTask.Approver_6__c=userList[0].Id;
                AdhocTask.Approver_7__c=userList[0].Id;
                AdhocTask.Approver_8__c=userList[0].Id;
                AdhocTask.Approver_9__c=userList[0].Id; 
                AdhocTasks.add(AdhocTask);
            }  
            
            System.debug('-->Containments Size:'+Containments.size()+'-->Containments'+Containments);
            System.debug('-->nonConformancesList Size:'+nonConformancesList.size()+'-->nonConformancesList'+nonConformancesList);
            gentask.addAll(Containments);
            gentask.addAll(Investigations);
            gentask.addAll(Dispositions);
            gentask.addAll(implementations);
            gentask.addAll(Closures);
            gentask.addAll(AdhocTasks);  
            insert gentask;     
           
           // test.stoptest();
            }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// data for sub tasks
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: Approvalclass
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

static testMethod void NC_SubmitforApprovalTest() {
          initGeneralTasks();

          Test.startTest();
          ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]); 
          Approvalclass NCGTD=new Approvalclass(std1);
          Approvalclass NCG=new Approvalclass();
          Approvalclass NCGT=new Approvalclass(nonConformancesList[0]);
          
          
          
          string[] approverIds=new List<String>();
            approverIds.add(userList[0].id);
            
            List<Approver__c> ApprList=new List<Approver__c>();
            Approver__c apr=new Approver__c(General_task__c=Containments[0].id);
            apr.Sequence_Position__c=10;
            apr.Due_Date__c=system.today();
            apr.User__c=userList[0].id;
            apr.Allowed_Days__c=3; 
            ApprList.add(apr);
            Approver__c appr=new Approver__c(General_task__c=Containments[0].id);
            appr.Sequence_Position__c=20;
            appr.Due_Date__c=system.today();
            appr.User__c=userList[0].id;  
            appr.Allowed_Days__c=3;
            ApprList.add(appr);     
          
          System.debug('-->Containments Size:'+Containments.size()+'-->Containments'+Containments);
          System.debug('-->Containments:'+Containments[0].id+'-->userList:'+userList[0].id+'-->approverIds:'+approverIds);
          Boolean result=Approvalclass.submitApprovalRequest(Containments[0].id,userList[0].id,approverIds,'Dark Side will Rise','Owner__c',userList[0].id,'2/12/16');
          system.assertEquals(true,result);
          Boolean result2=Approvalclass.submitApprovalRequest(Containments[1].id,userList[0].id,approverIds,'Dark Side will Rise','Due_Date__c',userList[0].id,'2/12/16');
          system.assertEquals(true,result2);
          List<ProcessInstance> expectedProcessInstance=Approvalclass.getApprover(Containments[0].id);
          system.assertNotEquals(0,expectedProcessInstance.size());
          
          Boolean result3 = GeneralTaskController.updateCurretnRecord(Containments[1].id,'Containment','OpenANDApprovalRequire');
          Boolean result4 = GeneralTaskController.updateCurretnRecord(Containments[1].id,'Containment','OpenANDApprovalNotRequire');
          Boolean result5 = GeneralTaskController.updateCurretnRecord(Containments[1].id,'Containment','Closed');
          Boolean result6 = GeneralTaskController.updateCurretnRecord(Implementations[0].id,'Implementation','Pending ActionPlan');
          Boolean result7 = GeneralTaskController.updateCurretnRecord(Implementations[0].id,'Implementation','Closed');
          system.assertEquals(true,result3);
          system.assertEquals(true,result4);
          system.assertEquals(true,result5);
          system.assertEquals(true,result6);
          system.assertEquals(true,result7);
          
           General_Task__c gt=new General_Task__c();
          
          PageReference pageRefC = Page.nc_task;
          Test.setCurrentPage(pageRefC );          
          ApexPages.currentPage().getParameters().put('id', Containments[0].Non_conformance__c);
          ApexPages.currentPage().getParameters().put('type', 'Containment');
          std1=new ApexPages.StandardController(gt); 
          NCGTD=new Approvalclass(std1);
          result =NCGTD.getisApprover();
          system.assertNOTEquals(null,result); 
          
          PageReference pageRefIn = Page.nc_task;
          Test.setCurrentPage(pageRefIn );          
          ApexPages.currentPage().getParameters().put('id', Investigations[0].Non_conformance__c);
          ApexPages.currentPage().getParameters().put('type', 'Investigation');
          NCGTD=new Approvalclass(std1);
          result =NCGTD.getisApprover();
          system.assertNOTEquals(null,result);
          
          PageReference pageRefD=Page.nc_task;
          Test.setCurrentPage(pageRefD);          
          ApexPages.currentPage().getParameters().put('id', Dispositions[0].Non_conformance__c);
          ApexPages.currentPage().getParameters().put('type', 'Disposition'); 
          NCGTD=new Approvalclass(std1);
          result =NCGTD.getisApprover();
          system.assertNOTEquals(null,result);
          
          PageReference pageRef = Page.nc_task;
          Test.setCurrentPage(pageRef);          
          ApexPages.currentPage().getParameters().put('id', implementations[0].Non_conformance__c);
          ApexPages.currentPage().getParameters().put('type', 'Implementation');
          NCGTD=new Approvalclass(std1);
          result =NCGTD.getisApprover();
          system.assertNOTEquals(null,result);
          
          PageReference pageRefCl = Page.nc_task;
          Test.setCurrentPage(pageRefCl);          
          ApexPages.currentPage().getParameters().put('id', Closures[0].Non_conformance__c);
          ApexPages.currentPage().getParameters().put('type', 'Closure');
          NCGTD=new Approvalclass(std1);
          result =NCGTD.getisApprover();      
          system.assertNOTEquals(null,result); 
          Test.stopTest();                          
           

    } 
    
    
     static testMethod void NC_ApprovalHisotry_Test() {
            initGeneralTasks();
            test.startTest(); 
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments('Comments');
            req.setObjectId(AdhocTasks[0].id);
            req.setSubmitterId(userList[0].Id);
            Approval.ProcessResult results = Approval.process(req);           
            Component_Handler nc_approvalHistory_object=new Component_Handler();
            nc_approvalHistory_object.objectId=AdhocTasks[0].id;
            system.assertNotEquals(null,nc_approvalHistory_object.getApprovalHistory()); 
            system.assertNotEquals(null,nc_approvalHistory_object.PDs); 
            
           Approvalclass NC_ApprovalList_object=new Approvalclass();
           system.assertNotEquals(null,NC_ApprovalList_object.getApproverList());
            test.stopTest();  
            
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END Approvalclass
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  


    public static void initContainmentActions() {
            initGeneralTasks();
            ContainmentActions=new List<General_Sub_Task__c>();
            upsert Containments;
            for(General_Task__c gt:Containments){   
                General_Sub_Task__c contAction=new General_Sub_Task__c();
                contAction.General_Task__c=gt.id;    
                ContainmentActions.add(contAction); 
                General_Sub_Task__c contAction2=new General_Sub_Task__c();
                contAction2.General_Task__c=gt.id; 
                contAction2.Completed_By__c=userList[0].id;   
                contAction2.Sub_Task_Detail__c='Revenge Of The Sith';
                ContainmentActions.add(contAction2);                
            }
            
        

                insert ContainmentActions;             
        }
        
    static testMethod void NC_ContainmentActions_Test() {
        initContainmentActions();
        try{
            test.startTest();        
            ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]);
            //GeneralTaskController    NC_ContainmentActions_object = new GeneralTaskController(std1);
            //system.assertNotEquals(null,NC_ContainmentActions_object); 
            Integer i;
            Component_Handler Cont=new Component_Handler();
            Cont.generalTaskId = Containments[0].id;
            i = Cont.getContainmentActionData();
            i = Cont.getContainmentActionsSize();
            Cont.loadContainmentActions(); 
            Component_Handler.getContainmentAction(ContainmentActions[0].id);
            boolean delContResult = Component_Handler.deleteContainmentAction(Containments[0].id);
            system.assert(delContResult ); 
            test.stopTest();
        }catch(Exception ex){
            System.debug('?xception In NC_Test.NC_ContainmentActions_Test   '+ex.getMessage());
        }  
            
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: GeneralTaskController(DispositionController) 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    

    public static General_Sub_Task__c dispSec; 
    public static General_Sub_Task__c dispSection; //
    public static Map<String,String> dispSecMap;
    public static Map<String,String> dispSectionMap;//
    public static List<Disposition_Product__c> dispoProdList;
    public static Map<String,Map<String,String>> productDetails;
    public static Map<String,Map<String,String>> dispProductDetails;//
    public static Map<String,Map<String,String>> dispositionArray;
    public static List<Id> deletedRowIds;
    public static List<Id> deletedRowId;
    public static List<Id> deletedRows;
    public static Boolean submitWithApproval;
    public static Boolean appCheck;
    public static List<Defect__c> defectListDISPCNT;
    public static List<Process__c> processListDISPCNT;
    public static List<String> productsDISPCNT;
    public static Product_Lot_Numbers__c prodLot;//
    public static NC_Product__c ncProductDISPCNT;//
    public static List<Approver__c> approversDISPCNT;

public static testMethod void DispositionControllerTest()
{
     initGeneralTasks();

     productList=new List<Product__c>();
     productList.add(new Product__c(Name='Test Prod',Product_Number__c='1111'));
            
     upsert productList;

    ncProductDISPCNT = new NC_Product__c(Product__c = productlist[0].Id,Non_Conformance__c = nonConformancesList[0].Id);
    insert ncProductDISPCNT;
    prodLot = new Product_Lot_Numbers__c(NC_Product__c = ncProductDISPCNT.Id,Lot_Quantity_Affected__c = 8);
    insert prodLot;
    
    for (General_Task__c gc: Dispositions)
    {
        gc.Sequence__c='10';
        gc.Sequence_Position__c=10;
        gc.Owner__c=userList[0].Id;
        gc.Allowed_Days__c = 6;
        gc.Due_Date__c=Date.parse('1/9/2016');
        gc.Approver__c=userList[0].Id;
    }
    
    update Dispositions;

    dispSection = new General_Sub_Task__c(
    Disposition_Type__c = 'Scrap',
    Assigned_Disposition_Qty__c = 10,
    Assigned_User__c = userList[0].Id,
    Due_Date__c = Date.parse('1/9/2016'),
    Disposition_Instruction__c = 'Scrap Dispo instruction',
    Complete__c = 'Yes',
    Completed_Date__c = Date.parse('1/6/2016'),
    Completed_By__c = userList[0].Id,
    Completion_Comment__c = 'Scrap Completed instruction',  
    General_Task__c = Dispositions[0].Id
    );
    insert dispSection;
        dispositionArray = new Map<String,Map<String,String>>();
        dispSectionMap = new Map<String,String>();
        dispSectionMap.put('Disposition_Type__c', dispSection.Disposition_Type__c);
        dispSectionMap.put('Assigned_Disposition_Qty__c',String.valueOf(dispSection.Assigned_Disposition_Qty__c));
        dispSectionMap.put('Assigned_User__c',dispSection.Assigned_User__c);
        dispSectionMap.put('Due_Date__c',String.valueOf('09 Jan 2016'));
        dispSectionMap.put('Disposition_Instruction__c',dispSection.Disposition_Instruction__c);
        dispSectionMap.put('Complete__c',dispSection.Complete__c);
        dispSectionMap.put('Completed_Date__c',String.valueOf('06 Jan 2016'));
        dispSectionMap.put('Completed_By__c',dispSection.Completed_By__c);
        dispSectionMap.put('Completion_Comment__c',dispSection.Completion_Comment__c);
        dispSectionMap.put('General_Task__c',dispSection.General_Task__c);
        dispSectionMap.put('Id',dispSection.Id);
        dispSectionMap.put('Dispo','dispo0');
        dispositionArray.put('dispo0',dispSectionMap);
        
        List<Disposition_Product__c> dispoProductList = new List<Disposition_Product__c>();
        Disposition_Product__c dispProd;
        dispProd = new Disposition_Product__c();
        dispProd.NC_ProductId__c = ncProductDISPCNT.Id;
        dispProd.NC_Product__c = 'Galaxy';
        dispProd.Product_Batch__c = 'NCPLN-38';
        dispProd.Defect_Quantity__c = 6;
        dispProd.Dispose_Quantity__c = 4;
        dispProd.Pending_Quantity__c = 2;
        dispProd.General_Sub_Task__c = dispSection.Id;
        dispoProductList.add(dispProd);
        insert dispoProductList;
        
        dispProductDetails = new Map<String,Map<String,String>>();
        Map<String,String> dispProductMap = new Map<String,String>();
        for(integer i=0;i<dispoProductList.size();i++){
            dispProductMap.put('NC_ProductId__c', String.valueOf(dispoProductList.get(i).get('NC_ProductId__c')));
            dispProductMap.put('NC_Product__c', String.valueOf(dispoProductList.get(i).get('NC_Product__c')));
            dispProductMap.put('Product_Batch__c', String.valueOf(dispoProductList.get(i).get('Product_Batch__c')));
            dispProductMap.put('Defect_Quantity__c', String.valueOf(dispoProductList.get(i).get('Defect_Quantity__c')));
            dispProductMap.put('Dispose_Quantity__c', String.valueOf(dispoProductList.get(i).get('Dispose_Quantity__c')));
            dispProductMap.put('Pending_Quantity__c', String.valueOf(dispoProductList.get(i).get('Pending_Quantity__c')));
            dispProductMap.put('General_Sub_Task__c', String.valueOf(dispoProductList.get(i).get('General_Sub_Task__c')));
            dispProductMap.put('Dispo','dispo0');
            dispProductDetails.put('ProductDetails'+i,dispProductMap);
        }
    
        deletedRows = new List<Id>();

        
        dispSec = new General_Sub_Task__c(
        Disposition_Type__c = 'Rework',
        Assigned_Disposition_Qty__c = 7,
        Assigned_User__c = userList[0].Id,
        Due_Date__c = Date.parse('1/9/2016'),
        Disposition_Instruction__c = 'Rework Dispo instruction',
        Complete__c = 'No',
        General_Task__c = Dispositions[1].Id
        );
        insert dispSec;

        dispSecMap = new Map<String,String>();
        dispSecMap.put('Disposition_Type__c', dispSec.Disposition_Type__c);
        dispSecMap.put('Assigned_Disposition_Qty__c',String.valueOf(dispSec.Assigned_Disposition_Qty__c));
        dispSecMap.put('Assigned_User__c',dispSec.Assigned_User__c);
        dispSecMap.put('Due_Date__c',String.valueOf('09 Jan 2016'));
        dispSecMap.put('Disposition_Instruction__c',dispSec.Disposition_Instruction__c);
        dispSecMap.put('Complete__c',dispSec.Complete__c);
        dispSecMap.put('General_Task__c',dispSec.General_Task__c);
        dispSecMap.put('Id',dispSec.Id);
        
        dispoProdList = new List<Disposition_Product__c>();
        Map<String,String> dispProdMap = new Map<String,String>();
        dispProd = new Disposition_Product__c();
        dispProd.NC_ProductId__c = ncProductDISPCNT.Id;
        dispProd.NC_Product__c = 'galaxy';
        dispProd.Product_Batch__c = 'NCPLN-38';
        dispProd.Defect_Quantity__c = 6;
        dispProd.Dispose_Quantity__c = 4;
        dispProd.Pending_Quantity__c = 2;
        dispProd.General_Sub_Task__c = dispSec.Id;
        dispoProdList.add(dispProd);
        
        dispProd = new Disposition_Product__c();
        dispProd.NC_ProductId__c = ncProductDISPCNT.Id;
        dispProd.NC_Product__c = 'Iphone';
        dispProd.Product_Batch__c = 'NCPLN-39';
        dispProd.Defect_Quantity__c = 6;
        dispProd.Dispose_Quantity__c = 4;
        dispProd.Pending_Quantity__c = 2;
        dispProd.General_Sub_Task__c = dispSec.Id;
        dispoProdList.add(dispProd);
        
        dispProd = new Disposition_Product__c();
        dispProd.NC_ProductId__c = ncProductDISPCNT.Id;
        dispProd.NC_Product__c = 'galaxy67';
        dispProd.Product_Batch__c = 'NCPLN-40';
        dispProd.Defect_Quantity__c = 6;
        dispProd.Dispose_Quantity__c = 4;
        dispProd.Pending_Quantity__c = 2;
        dispProd.General_Sub_Task__c = dispSec.Id;
        dispoProdList.add(dispProd);
        
        insert dispoProdList;
        System.debug('dispoProdList--------------------------------------------------->'+dispoProdList);
        
        productDetails = new Map<String,Map<String,String>>();
        for(integer i=0;i<dispoProdList.size();i++){
            dispProdMap.put('NC_ProductId__c', String.valueOf(dispoProdList.get(i).get('NC_ProductId__c')));
            dispProdMap.put('NC_Product__c', String.valueOf(dispoProdList.get(i).get('NC_Product__c')));
            dispProdMap.put('Product_Batch__c', String.valueOf(dispoProdList.get(i).get('Product_Batch__c')));
            dispProdMap.put('Defect_Quantity__c', String.valueOf(dispoProdList.get(i).get('Defect_Quantity__c')));
            dispProdMap.put('Dispose_Quantity__c', String.valueOf(dispoProdList.get(i).get('Dispose_Quantity__c')));
            dispProdMap.put('Pending_Quantity__c', String.valueOf(dispoProdList.get(i).get('Pending_Quantity__c')));
            dispProdMap.put('General_Sub_Task__c', String.valueOf(dispoProdList.get(i).get('General_Sub_Task__c')));
            dispProdMap.put('Dispo','dispo0');
            productDetails.put('ProductDetails'+i,dispProdMap);
        }
        
        // for a single deleted
        Id dispId = String.valueOf(dispoProdList.get(0).get('Id'));
        deletedRowId = new List<Id>();
        deletedRowId.add(dispId);
        submitWithApproval = true;
        appCheck = true;
        
        // for list of deleted rows in a row
        dispId = String.valueOf(dispoProdList.get(1).get('Id'));
        deletedRowIds = new List<Id>();
        deletedRowIds.add(dispId);
        dispId = String.valueOf(dispoProdList.get(2).get('Id'));
        deletedRowIds.add(dispId);
        
        productsDISPCNT = new List<String>();
        productsDISPCNT.add(productList[0].Id+'@Iphone');
        // ----------- End of test Data ------------------------


        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(nonConformancesList[1]);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nonConformancesList[1].id);
    	ApexPages.currentPage().getParameters().put('type','Disposition');
        ApexPages.StandardController sCon = new ApexPages.StandardController(nonConformancesList[0]);
        system.assertNotEquals(sCon,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nonConformancesList[0].id);
        GeneralTaskController disp = new GeneralTaskController(sc);
        system.assertNotEquals(disp,null,'values are equal');
        GeneralTaskController dis = new GeneralTaskController(sCon);
        system.assertNotEquals(dis,null,'values are equal');
        Component_Handler addDisp = new Component_Handler();
        //NC_Disposition_Form dispForm = new NC_Disposition_Form();
        System.debug('testDisposition ------------------------------------------------------> '+disp);

        Integer i = GeneralTaskController.saveDisposition(Dispositions[0].Id,dispositionArray,productDetails,deletedRowId,submitWithApproval,appCheck);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.saveDisposition(Dispositions[1].Id,dispositionArray,productDetails,deletedRowIds,submitWithApproval,false);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.saveDisposition(Dispositions[0].Id,dispositionArray,dispProductDetails,deletedRows,submitWithApproval,false);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.checkDispositionCompletionStatus(Dispositions[1].Id);
        system.assertEquals(i,-1,'values are not equal');
        i = GeneralTaskController.checkDispositionCompletionStatus(Dispositions[0].Id);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.updateDispositionApprovalRequired(Dispositions[0].Id,true);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.updateDispositionApprovalRequired(Dispositions[1].Id,false);
        system.assertEquals(i,0,'values are not equal');
        Map<String,List<String>> dataMap = Component_Handler.getDispositionData(nonConformancesList[1].id);
        system.assertNotEquals(dataMap,null,'values are equal');
        i = Component_Handler.removeDisposition(dispSec.Id);
        system.assertEquals(i,0,'values are not equal');
        List<String> userData = Component_Handler.getAuthorizedUsers('NC_Task_Owner'); 
        system.assertNotEquals(userData,null,'values are equal');
        i = Component_Handler.savePendingDisposition(dispSectionMap.get('Id'),'Yes',dispSectionMap.get('Completed_By__c'),String.valueOf('06 Jan 2016'),'Completed');
        system.assertEquals(i,0,'values are not equal');
        //AddDispositonController.updateDispositionStatus(genTask.Id);
        i = Component_Handler.updateDispositionStatus(Dispositions[1].Id);
        system.assertEquals(i,0,'values are not equal');
        dataMap = Component_Handler.getProductBatch(productsDISPCNT);
        system.assertNotEquals(dataMap,null,'values are equal');
        //dispForm.getapproversDISPCNT();
        Test.stopTest();

}

static void dispData(){
        initData();
        product = new Product__c(Name = 'Lie about cake to all test subjects');
        insert product;
        
             
        ncProduct = new NC_Product__c(Product__c = product.Id,Non_Conformance__c = nonConformancesList[0].Id);
        insert ncProduct;
        prodLot = new Product_Lot_Numbers__c(NC_Product__c = ncProduct.Id,Lot_Quantity_Affected__c = 8);
        insert prodLot;
        
        genTask = new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Non_Conformance__c = nonConformancesList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/9/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Disposition').getRecordTypeId(),
            Status__c='Open'
        );
        insert genTask;
        
        dispSection = new General_Sub_Task__c(
            Disposition_Type__c = 'Scrap',
            Assigned_Disposition_Qty__c = 10,
            Assigned_User__c = userList[0].Id,
            Due_Date__c = Date.parse('1/9/2016'),
            Disposition_Instruction__c = 'Scrap Dispo instruction',
            Complete__c = 'Yes',
            Completed_Date__c = Date.parse('1/6/2016'),
            Completed_By__c = userList[0].Id,
            Completion_Comment__c = 'Scrap Completed instruction',  
            General_Task__c = genTask.Id
        );
        insert dispSection;
        
        List<Disposition_Product__c> dispoProductList = new List<Disposition_Product__c>();
        Disposition_Product__c dispProd;
        dispProd = new Disposition_Product__c();
        dispProd.NC_ProductId__c = ncProduct.Id;
        dispProd.NC_Product__c = 'Galaxy';
        dispProd.Product_Batch__c = 'NCPLN-38';
        dispProd.Defect_Quantity__c = 6;
        dispProd.Dispose_Quantity__c = 4;
        dispProd.Pending_Quantity__c = 2;
        dispProd.General_Sub_Task__c = dispSection.Id;
        dispoProductList.add(dispProd);
        insert dispoProductList;
        
        
    }
    
    
    public static testMethod void DispositionFormTest(){
        dispData();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(nonConformancesList[0]);
        system.assertNotEquals(nonConformancesList[0],null,'values are equal');
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nonConformancesList[0].id);
        Integer i;
        Component_Handler Cont=new Component_Handler();
        Cont.disposition = genTask;
        i = Cont.getDispositionSectionData();

        //NC_Disposition_Form dispForm = new NC_Disposition_Form();
        //system.assertNotEquals(dispForm,null,'values are equal');
        //dispForm.ncdid = dispSection.id;
        //List<General_Sub_Task__c> dispList = dispForm.CAS;
        //system.assertNotEquals(dispList,null,'values are equal');
        //dispList = null;
        //dispList = dispForm.CAS;
        //system.assertNotEquals(dispList,null,'values are equal');
        Test.stopTest();
    }
    

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END GeneralTaskController.DispositionController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static Product__c product;
    public static General_Task__c genTask;
    public static NC_Product__c ncProduct;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: NC_Investigation_Form 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void initInvestigationData(){
         initData();
            
        
            generalTask = new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Non_Conformance__c = nonConformancesList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/9/2016'),
            ChangeFieldApprovalStatus__c='Approve',
            New_Due_Date__c = Date.today(),
            Investigation_Tools__c ='tool1',
            Investigation_Summary__c =  'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            New_Owner__c = userList[0].Id,
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Investigation').getRecordTypeId(),
            Status__c='Created'
        );
        insert generalTask;
        product = new Product__c( 
        Name = 'TEST PRODUCT',
        Product_Code__c = 'PRODUCT'+System.now());
        insert product;
        causeList =new List<Cause__c>();
        causeList.add(new Cause__c(
                    Cause_Code__c = 'defect 1',
                    Type__c='Product'
                    ));
        Cause__c nocauseid =null;
        insert causeList;            
        rootCauseList = new List<General_Sub_Task__c>();
        rootCauseList.add(new General_Sub_Task__c(
                Against__c = 'Product',
                Cause_Code__c = causeList[0].Id,
                Cause_Code_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                Defect__c = defectList[0].Id,
                Defect_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"' ,
                General_Task__c = generalTask.Id ,
                Product__c = product.Id,
                Process__c = processList[0].Id
             ));
        insert rootCauseList;
        System.debug('rootCauseList----------------->'+rootCauseList);
       approvers = new List<Approver__c>();
       approvers.add(new Approver__c(
            Allowed_Days__c = 7,
            Status_Updated__c =Date.parse('1/9/2016'),
            User__c=userList[0].Id,
            Due_Date__c=Date.parse('1/9/2016'),
            Sequence_Position__c= 10,
            Status__c='Approved'
       )) ;
        insert approvers;
      
     
    }
    
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
 // BEGIN
 // Test for class: GeneralTaskController.NC_Investigation_Form
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   public static General_Task__c generalTask;
    public static List<General_Sub_Task__c> rootCauseList;
    public static List<Cause__c> causeList;

    public static List<Approver__c> approvers;
   
    
   
   public static testMethod void NC_Investigation_Test() {
    initInvestigationData();
     ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]);  
       try{
          Test.startTest();
               /*upsert generalTask;
               GeneralTaskController ncinv1 = new GeneralTaskController(std1);
               ncinv1.genTask = generalTask;
               ncinv1.ncpid=generalTask.id;
               System.debug('ncinv1.ncpid-------->'+ncinv1.ncpid);    
               System.assertNotEquals(null, ncinv1.genTask);
               GeneralTaskController ncinv2 = new GeneralTaskController(null);
               ncinv2.genTask = null;
               System.assertEquals(null, ncinv2.genTask);*/
               
               Integer i;
               Component_Handler Cont=new Component_Handler();
               Cont.investigation = genTaskList[2];
               i = Cont.getRootCauseData();
               Component_Handler.getRootCause(nonConformancesList[0].id);
           	   System.assertNotEquals(null,i);
           Test.stopTest();   
       }catch(Exception e){
            System.debug('NC_Investigation_Test.Exception'+e.getMessage());
        }
          
   }
    
    public static testMethod void  NC_Investigation_Test_getRemoteRoot_Cause(){
       initInvestigationData();
      ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]);
     
        try{
          Test.startTest();
         General_Sub_Task__c rc1 = GeneralTaskController.getRemoteRoot_Cause(rootCauseList[0].id);
         System.debug('rc------------>'+rc1);
         System.assertNotEquals(null, rc1);
         General_Sub_Task__c rc2 = GeneralTaskController.getRemoteRoot_Cause(null);
         System.assertEquals(new  General_Sub_Task__c(), rc2);  
        Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
      
    }
    public static testMethod void NC_Investigation_Test_getRRemoteRoot_Cause(){
        initInvestigationData();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',nonConformancesList[0].id);
        ApexPages.currentPage().getParameters().put('type','Investigation');
        ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]);
        GeneralTaskController ncinvestform = new GeneralTaskController(std1);
        system.debug('ncinvestform--------------------------->'+ncinvestform);
        List<General_Sub_Task__c> rclist = ncinvestform.getRRemoteRoot_Cause();
        system.debug('rclist--------------------------->'+rclist);
        System.assertNotEquals(null, rclist);
        if(rclist == null)
        System.assert(false, new  List<General_Sub_Task__c>());
        GeneralTaskController noncid = new GeneralTaskController(null);
        List<General_Sub_Task__c> norclist = noncid.getRRemoteRoot_Cause();
        System.assertNotEquals(null, norclist);
         Test.stopTest();
    }
    
    public static testMethod void NC_Investigation_Test_getCauseDetails(){
        initInvestigationData();
        try{
          Test.startTest();
           Cause__c cause1 =  GeneralTaskController.getCauseDetails(causeList[0].id);
           System.assertNotEquals(null, cause1);
            Cause__c cause2 =  GeneralTaskController.getCauseDetails(null);
            System.assertNotEquals(null, cause2);
          Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }  
    }
    public static testMethod void NC_Investigation_Test_getDefectDetails(){
    initInvestigationData();
     try{
          Test.startTest();
           Defect__c defect1 =  GeneralTaskController.getDefectDetails(defectList[0].Id);
           System.assertNotEquals(null, defect1);
           Defect__c defect2 =  GeneralTaskController.getDefectDetails(null);
           System.assertNotEquals(null, defect2);
          Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }     
    }
    
    public static testMethod void NC_Investigation_Test_updateInvestigationTask(){
     initInvestigationData();
     try{
          Test.startTest();
           Boolean result1 = GeneralTaskController.updateInvestigationTask(generalTask.id, generalTask.Investigation_Summary__c, generalTask.Investigation_Tools__c,true,true);
           System.assert(result1);
           Boolean result2 = GeneralTaskController.updateInvestigationTask(generalTask.id, generalTask.Investigation_Summary__c, generalTask.Investigation_Tools__c,false,true);
           System.assert(result2);
          Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }    
    }
    public static testMethod void NC_Investigation_Test_deleteRootCause(){
     initInvestigationData();
      try{
          Test.startTest();
           Boolean result1 = GeneralTaskController.deleteRootCause(rootCauseList[0].id); 
           System.assert(result1);
           Boolean result2 = GeneralTaskController.deleteRootCause(null);
           System.assert(result2);
          
           Boolean result3 = Component_Handler.deleteRootCause(rootCauseList[0].id); 
           System.assert(result3);
           Boolean result4 = Component_Handler.deleteRootCause(null);
           System.assert(result4);
          
          Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }      
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// End
// Test for class: GeneralTaskController.NC_InvestigationController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: GeneralTaskController.NC_ActionPlanController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static Non_Conformance__c nonConf;
    public static Non_Conformance__c nConf;
    public static General_Sub_Task__c apSec;
    public static General_Sub_Task__c actplanSection;
    public static Map<String,String> apSecMap;
    public static Map<String,String> actplanSectionMap;
    public static List<String> products;
    
    static void ncData(){
        product = new Product__c(Name = 'Lie about cake to all test subjects');
        insert product;
        
        userList = new List<User>();
        Profile p = [select id FROM Profile WHERE Name ='System Administrator'];
        userList.add(new User(
            FirstName = 'Selena', 
            LastName = 'Kyle',
            Username = 'Selena.Kyle@Gotham.com', 
            Email = 'CatSkills@Gotham.com', 
            Alias = 'Catwoman', 
            CommunityNickname = 'CatWomans', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US'
        ));
        insert userList;
        
        defectList = new List<Defect__c>();
        defectList.add(new Defect__c(
            Name = 'Crack in space/time continuum', 
            Defect_Code__c = '1.21 Gigawatts!'
        ));
        upsert defectList;
        
        processList = new List<Process__c>();
        processList.add(new Process__c(
            Name = 'Lie about cake to all test subjects'
        ));
        insert processList;
        
        nConf = new Non_Conformance__c(
        Defect__c = defectList[0].Id,
        Full_Description__c  = 'First defect',
        NC_Source__c = 'Source 1',
        NC_Type__c = 'Process',
        Process__c =  processList[0].Id,
        Occurance_Date__c = Date.parse('1/4/2016'),
        Other_Source__c = 'XYZ',
        Reporter__c = userList[0].Id,
        Reported_Date__c = Date.parse('1/4/2016'),
        Risk_Description__c = 'Risk Description 1'
        );
        insert nConf;
        
        genTask = new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Non_Conformance__c = nConf.Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Disposition').getRecordTypeId(),
            Status__c='Open'
        );
        insert genTask;
        
        rootCauseList = new List<General_Sub_Task__c>();
            rootCauseList.add(new General_Sub_Task__c(
            General_Task__c = genTask.Id 
        ));
        insert rootCauseList;
        
        Action_Plan_Root_Cause__c aprc = new Action_Plan_Root_Cause__c(
            Task_Root_Cause__c = rootCauseList[0].id
        );
        
        actplanSection = new General_Sub_Task__c(
            Title__c = 'The other other white meat',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Type__c = 'Correction',
            Assigned_User__c = userList[0].Id,
            Associated_Root_Causes__c = rootCauseList[0].id,
            Due_Date__c = Date.parse('1/4/2016'),
            Complete__c = 'Yes',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/9/2016'),
            Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask.id
        );
        insert actplanSection;
        
        actplanSectionMap = new Map<String,String>();
        actplanSectionMap.put('Title__c', actplanSection.Title__c);
        actplanSectionMap.put('Description__c',actplanSection.Description__c);
        actplanSectionMap.put('Type__C',actplanSection.Type__C);
        actplanSectionMap.put('Assigned_User__c',actplanSection.Assigned_User__c);
        actplanSectionMap.put('Due_Date__c',String.valueOf('04 Jan 2016'));
        actplanSectionMap.put('Associated_Root_Causes__c',actplanSection.Associated_Root_Causes__c);
        actplanSectionMap.put('Completed__c',actplanSection.Complete__c);
        actplanSectionMap.put('Completed_Date__c',String.valueOf('09 Jan 2016'));
        actplanSectionMap.put('Completed_By__c',actplanSection.Completed_By__c);
        actplanSectionMap.put('Completion_Comments__c',actplanSection.Completion_Comments__c);
        actplanSectionMap.put('General_Task__c',actplanSection.General_Task__c);
        actplanSectionMap.put('Id',actplanSection.Id);
        
        
        
        //======================
        
        nonConf = new Non_Conformance__c(
        Defect__c = defectList[0].Id,
        Full_Description__c  = 'First defect',
        NC_Source__c = 'Source 1',
        NC_Type__c = 'Process',
        Process__c =  processList[0].Id,
        Occurance_Date__c = Date.parse('1/4/2016'),
        Other_Source__c = 'XYZ',
        Reporter__c = userList[0].Id,
        Reported_Date__c = Date.parse('1/4/2016'),
        Risk_Description__c = 'Risk Description 1'
        );
        insert nonConf;
        
        generalTask = new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Non_Conformance__c = nConf.Id,
            Allowed_Days__c = 6,
            Due_Date__c= Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Implementation').getRecordTypeId(),
            Status__c='Pending ActionPlan'
        );
        insert generalTask;
        
        rootCauseList = new List<General_Sub_Task__c>();
            rootCauseList.add(new General_Sub_Task__c(
            General_Task__c = generalTask.Id 
        ));
        insert rootCauseList;
        
        Action_Plan_Root_Cause__c aprc1 = new Action_Plan_Root_Cause__c(
            Task_Root_Cause__c = rootCauseList[0].id
        );
        
        apSec = new General_Sub_Task__c(
            Title__c = 'The other other white meat',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Type__c = 'Correction',
            Assigned_User__c = userList[0].Id,
            Associated_Root_Causes__c = rootCauseList[0].id,
            Due_Date__c = Date.parse('1/4/2016'),
            Complete__c = 'No',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/4/2016'),
            General_Task__c = generalTask.id
        );
        insert apSec;
        
        apSecMap = new Map<String,String>();
        apSecMap.put('Title__c', apSec.Title__c);
        apSecMap.put('Description__c',apSec.Description__c);
        apSecMap.put('Type__C',apSec.Type__C);
        apSecMap.put('Assigned_User__c',apSec.Assigned_User__c);
        apSecMap.put('Due_Date__c',String.valueOf('04 Jan 2016'));
        apSecMap.put('Associated_Root_Causes__c',apSec.Associated_Root_Causes__c);
        apSecMap.put('Completed__c',apSec.Complete__c);
        apSecMap.put('Completed_Date__c',String.valueOf('04 Jan 2016'));
        apSecMap.put('Completed_By__c',apSec.Completed_By__c);
        apSecMap.put('General_Task__c',apSec.General_Task__c);
        apSecMap.put('Id',apSec.Id);
        
        submitWithApproval = true;
        appCheck = true;
        
    }
 
    public static testMethod void testActionPlan(){
        //QC_Test.initDevOnlySettings();
        ncData();
        Test.startTest();
        
        causeList = new List<Cause__c>();
            causeList.add(new Cause__c(
               Cause_Code__c = 'First Cause',
               Type__c='Product'
        ));
        insert causeList;
        
        rootCauseList = new List<General_Sub_Task__c>();
            rootCauseList.add(new General_Sub_Task__c(
            Cause_Code__c = causeList[0].Id,
            General_Task__c = generalTask.Id 
        ));
        insert rootCauseList;
        
        Action_Plan_Root_Cause__c aprc = new Action_Plan_Root_Cause__c(
            Task_Root_Cause__c = rootCauseList[0].id,
            Task_Action_Plan__c = apSec.id
        );
        
        upsert aprc;
        delete aprc;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(nonConf);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nonConf.id);
        ApexPages.currentPage().getParameters().put('type','Implementation');
        ApexPages.StandardController sCon = new ApexPages.StandardController(nConf);
        system.assertNotEquals(sCon,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nConf.id);
        GeneralTaskController addaplan = new GeneralTaskController(sc);
        system.assertNotEquals(addaplan,null,'values are equal');
        GeneralTaskController addactPlan = new GeneralTaskController(sCon);
        system.assertNotEquals(addactPlan,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',nConf.id);
        GeneralTaskController addaplan1 = new GeneralTaskController();
        Integer i;
        i = GeneralTaskController.saveActionPlan(generalTask.Id,actplanSectionMap,submitWithApproval,appCheck);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.saveActionPlan(generalTask.Id,actplanSectionMap,false,false);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.saveActionPlan(genTask.Id,apSecMap,submitWithApproval,false);
        system.assertEquals(i,0,'values are not equal');
        
        i = GeneralTaskController.saveActionPlan(genTask.Id,apSecMap,false,true);
        system.assertEquals(i,0,'values are not equal');
        
        i = GeneralTaskController.updateAPApprovalRequired(genTask.Id,true);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.updateAPApprovalRequired(genTask.Id,false);
        system.assertEquals(i,0,'values are not equal');
       
        Map<String,List<String>> dataMap = Component_Handler.getActionPlanUserData('NC_Task_Owner'); 
        system.assertNotEquals(dataMap,null,'values are equal');
        
        List<String> userData = Component_Handler.getAuthorizedUsers('NC_Task_Owner');
        system.assertNotEquals(userData,null,'values are equal');
        
        boolean delapResult = Component_Handler.deleteActionPlan(apSec.id);
        system.assert(delapResult);
        
        boolean recallgt = GeneralTaskController.RecallwithoutApproval(generalTask.id,generalTask.Status__c);
        system.assert(recallgt);
        
        i = Component_Handler.savePendingActionPlan(actplanSectionMap.get('Id'),'Yes',actplanSectionMap.get('Completed_By__c'),String.valueOf('04 Jan 2016'),'Completed');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        i = Component_Handler.completePendingActionPlan(actplanSectionMap.get('Id'),'Yes',actplanSectionMap.get('Completed_By__c'),String.valueOf('04 Jan 2016'),'Completed');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        //List<String> displayRC = Component_Handler.displayAssocRootCauses(nConf.id,'NC');
        //system.assertNotEquals(displayRC,null,'values are equal');
        
        Component_Handler Cont=new Component_Handler();
        Cont.implementation = generalTask;
        i = Cont.getActionPlanData();
                       
        Test.stopTest();
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: GeneralTaskController.NC_ActionPlanController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: GeneralTaskController.AdhocTask
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
         public static void initAdhocTaskActions() {
            initGeneralTasks();
            AdhocTaskActions=new List<General_Sub_Task__c>();
            upsert AdhocTasks;
            for(General_Task__c gt:AdhocTasks){   
                General_Sub_Task__c contAction=new General_Sub_Task__c();
                contAction.General_Task__c=gt.id;    
                AdhocTaskActions.add(contAction); 
                General_Sub_Task__c contAction2=new General_Sub_Task__c();
                contAction2.General_Task__c=gt.id; 
                contAction2.Completed_By__c=userList[0].id;   
                contAction2.Sub_Task_Detail__c='Revenge Of The Sith';
                AdhocTaskActions.add(contAction2);                
            }
            
            insert AdhocTaskActions;             
        }
        
        static testMethod void NC_AdhocTaskActions_Test() {
            initAdhocTaskActions();
           try{
            test.startTest();        
            ApexPages.StandardController std1=new ApexPages.StandardController(nonConformancesList[0]);
            GeneralTaskController NC_AdhocTaskActions_object = new GeneralTaskController(std1);
            system.assertNotEquals(null,NC_AdhocTaskActions_object); 
            //boolean delAdhocResult = Component_Handler.deleteAdhocAction(AdhocTaskActions[0].id);
            //system.assert(delAdhocResult);
            
            test.stopTest();
           }catch(Exception ex){
              System.debug('?xception In NC_Test.NC_AdhocTaskActions_Test   '+ex.getMessage());
           }  
            
        }
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: GeneralTaskController.AdhocTask
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Class:NC_GeneralTaskDispatcher
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
static testMethod void NC_GeneralTaskDispatcher_Test() {
         initGeneralTasks();
             
          General_Task__c gt=new General_Task__c();
          Test.startTest();
          PageReference pageRefC = Page.NC_GeneralTask_Dispatcher;
          Test.setCurrentPage(pageRefC );          
          ApexPages.currentPage().getParameters().put('id', Containments[0].id);
          ApexPages.StandardController std1=new ApexPages.StandardController(gt); 
          GeneralTaskController  NCGTD=new GeneralTaskController(std1);
          PageReference result =NCGTD.getRedir();
          system.assertNOTEquals(null,result); 
          
          PageReference pageRefIn = Page.NC_GeneralTask_Dispatcher;
          Test.setCurrentPage(pageRefIn );          
          ApexPages.currentPage().getParameters().put('id', Investigations[0].id);
          NCGTD=new GeneralTaskController(std1);
          result =NCGTD.getRedir();
          system.assertNOTEquals(null,result);
          
          PageReference pageRefD= Page.NC_GeneralTask_Dispatcher;
          Test.setCurrentPage(pageRefD);          
          ApexPages.currentPage().getParameters().put('id', Dispositions[0].id); 
          NCGTD=new GeneralTaskController(std1);
          result =NCGTD.getRedir();
          system.assertNOTEquals(null,result);
          
          PageReference pageRef = Page.NC_GeneralTask_Dispatcher;
          Test.setCurrentPage(pageRef);          
          ApexPages.currentPage().getParameters().put('id', implementations[0].id);
          NCGTD=new GeneralTaskController(std1);
          result =NCGTD.getRedir();
          system.assertNOTEquals(null,result);
          
          PageReference pageRefCl = Page.NC_GeneralTask_Dispatcher;
          Test.setCurrentPage(pageRefCl);          
          ApexPages.currentPage().getParameters().put('id', Closures[0].id);
          NCGTD=new GeneralTaskController(std1);
          result =NCGTD.getRedir();      
          system.assertNOTEquals(null,result);  
          Test.stopTest();                                      
         }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END NC_GeneralTaskDispatcher
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//start Attachment history tracking
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static testMethod void Attachment_History_Controller_Test(){
          initData();
         // QC_Test.initData();
         // QC_Test.initData_for_Dashboard_Controller();
                        
          Blob b = Blob.valueOf('Test Data');  
          
          Attachment attachment = new Attachment();  
          attachment.ParentId =genTaskList[0].Non_conformance__c;  
          attachment.Name = 'TestAttachment forParent';  
          attachment.Body = b;  
          attachment.Description='update Attachment@dex';
          insert(attachment);  
          attachment.Description='update Attachment@hello';
          try{
             upsert attachment;
             System.assert(true);
          }
          catch(Exception ex){
                System.debug('Exception In NC_Test.NC_ApprovalChartController()   '+ex.getMessage());
                System.assert(false);
          }
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EnD Attachment history tracking
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Begin NC_RC_Trg_Cls

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 static void NC_RC_Trg_Cls_Test_Test_Data() { 
     Non_Conformance__c ncf=new Non_Conformance__c(
               

               Defect__c = defectList[0].Id,
               Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
               NC_Source__c = 'Other',
               Occurance_Date__c = Date.today(),
               Other_Source__c = 'The other other white meat',
               NC_Type__c = 'Process',
               Process__c = processList[0].Id,
               Reporter__c = userList[0].Id
           );
           nonConformancesList.add(ncf);   
        upsert nonConformancesList;    
       General_Task__c Investigation = new General_Task__c(Non_Conformance__c=nonConformancesList[0].id,Allowed_Days__c=3,status__c='Pending Approval',isLocked__c=true);
       Investigation.RecordTypeId=Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('Investigation').getRecordTypeId();
        insert Investigation;
        
         List<Approver__c> ApprList=new List<Approver__c>();
            Approver__c apr=new Approver__c(General_task__c=Investigation.id);
            apr.Sequence_Position__c=10;
            apr.Due_Date__c=system.today();
            apr.User__c=userList[0].id;
            apr.Allowed_Days__c=3;
            ApprList.add(apr);
            Approver__c appr=new Approver__c(General_task__c=Investigation.id);
            appr.Sequence_Position__c=20;
            appr.Due_Date__c=system.today();
            appr.User__c=userList[0].id;  
            appr.Allowed_Days__c=3;
            ApprList.add(appr);      
        insert ApprList;
        causeList =new List<Cause__c>();
         causeList.add(new Cause__c(
                    Cause_Code__c = 'defect 1',
                    Type__c='Process'
                    ));
        insert causeList;
        General_Sub_Task__c rc=new General_Sub_Task__c(
                Against__c = 'Process',
                Cause_Code__c = causeList[0].Id,
                Cause_Code_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                Defect__c = defectList[0].Id,
                Defect_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"' ,
                General_Task__c = Investigation.id ,
                Process__c = processList[0].Id
             );
        Test.startTest();
        insert rc;  
        update rc;
        delete rc;
     	delete Investigation;
        Test.stopTest(); 
          
    }
     static testmethod void NC_RootCause_Test(){
      try{
        init();
         System.runAs(userList[0]) {
        NC_RC_Trg_Cls_Test_Test_Data();
         }
         System.runAs(userList[1]) {
         //NC_AdhocTask_Action_Form_Test_Data();
         }
         System.assert(true);
      }
      catch(Exception ex){
         System.debug('Exception In NC_Test.NC_RootCause_Test()  '+ex.getMessage());
         System.assert(false);
      }         
     }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// End NC_RC_Trg_Cls

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Begin NC_Product_defect_Trg_testMethod

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static testMethod void NC_Product_defect_Trg_testMethod() {
        
        //initWithOUTDetection();
        initData();
        
        
        Product__c pr = new Product__c();
        pr.Name = 'TEST PRODUCT';
        pr.Product_Code__c = 'PRODUCT'+System.now();
        insert pr;
        
        NC_Product__c ncp = new NC_Product__c();
        ncp.Product__c = pr.Id;
        ncp.Non_Conformance__c =nonConformancesList[0].Id;
        insert ncp; 
        
        Product_Lot_Numbers__c plt = new Product_Lot_Numbers__c();
        plt.NC_Product__c = ncp.Id;
        plt.UOM__c = 'EA';
        plt.Lot_Bacth_Number__c = '25';
        insert plt;
                
        Defect__c dfct = new Defect__c();
        dfct.Name = 'Crack in space/time continuum';
        dfct.Defect_Code__c = 'Button Stuck';
        insert dfct;
        
        test.startTest();
        
        NC_Product_Defect__c PD=new NC_Product_Defect__c();
        PD.Defect__c = dfct.Id;
        PD.Product_Lot_Numbers__c = plt.Id;
        
        insert PD;
        
        system.assertNotEquals(null, PD);
        test.stopTest();
    }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// End NC_Product_defect_Trg_testMethod

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Begin Component_Handler.NC_Header

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static testMethod void NC_Header_Test_getNC() {
    
    nc_headerData();
        try{
           Test.startTest();
            system.debug('Inside getnc test class-->'+nonConformancesList[0]);
            ApexPages.StandardController ncobj=new ApexPages.StandardController(nonConformancesList[0]); 
            system.debug('ncobj------->'+ncobj);
            system.debug('ncid------->'+ nonConformancesList[0].id);
            Component_Handler nch1 = new Component_Handler();
            nch1.ncid=nonConformancesList[0].id;
            Non_Conformance__c nc1 = nch1.getNc();
             system.assertNotEquals(null, nc1);
            Component_Handler nch2 = new Component_Handler();
            Non_Conformance__c nc2 = nch2.getNc();
            system.assertNotEquals(null, nc2);
            Test.stopTest();
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    public static testMethod void NC_Header_Test_reopenNCTasks(){
    nc_headerData();
      try{
           Test.startTest();
            Boolean result1 = Component_Handler.reopenNCTasks(tasks,ncData,reasonfor_reopen);
            system.assertEquals(true, result1);
            Boolean result2 = Component_Handler.reopenNCTasks(null,null,reasonfor_reopen);
            system.assertEquals(true, result2);
          	
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }  
    }
    public static testMethod void NC_Header_Test_reopenNC(){
     nc_headerData();
     try{
           Test.startTest();
            Component_Handler nch = new Component_Handler();
            Boolean result1 = Component_Handler.reopenNC(reasonfor_reopen,nonConformancesList[0].id,'NC Workflow','Closed');
            system.assert(result1, 'tasks and NC reopened');
            Boolean result2 = Component_Handler.reopenNC(reasonfor_reopen,nonConformancesList[2].id,'Closed','Closed');
            system.assert(result2, 'NC reopened');
            Boolean result3 = Component_Handler.reopenNC(reasonfor_reopen,nonConformancesList[2].id,'NC Workflow','open');
            system.assert(result3, 'NC reopened tasks for open nc');
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }      
    }
    
    public static testMethod void NC_Header_Test_voidNC(){
     nc_headerData();
     try{
           Test.startTest();
            Component_Handler nch = new Component_Handler();
            Boolean result1 = Component_Handler.voidNC(nonConformancesList[2].id,reasonfor_reopen);
            System.debug('NC_Header_Test_voidNC  result1  '+result1);
            system.assert(result1, ' NC Vodid');
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }     
    }
    public static testMethod void NC_Header_Test_voidNCTasks(){
     nc_headerData();
      try{
           Test.startTest();
            Boolean result1 = Component_Handler.voidNCTasks(tasks,nonConformancesList[0].id,reasonfor_reopen);
            system.assert(result1, ' NC tasks Void');
            
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }    
    }
    public static testMethod void NC_Header_Test_closeNC(){
     nc_headerData();
     try{
           Test.startTest();
            Boolean result1 = Component_Handler.closeNC(nonConformancesList[0].id,reasonfor_reopen);
            system.assert(result1, 'Close NC');
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }    
    }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END Component_Handler.NC_Header
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static testMethod void Component_Hendler_Test(){
    //nc_headerData();
    initGeneralTasks();
     Component_Handler nch = new Component_Handler();
     Integer i;
     i=nch.getTaskData();
     System.assertEquals(i,0);
        
     }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: NonConformanceList
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static testMethod void NonConformanceListTest() {
        initWithOUTDetection();
        Test.startTest();
        nonConformancesList.add(new Non_Conformance__c(
            Defect__c = defectList[0].Id,
            Full_Description__c = 'Test description',
            NC_Source__c = 'Other',
            Occurance_Date__c = Date.today(),
            Reported_Date__c = Date.today(),
            Other_Source__c = 'The other other white meat',
            NC_Type__c = 'Process',
            Process__c = processList[0].Id,
            Reporter__c = userList[0].Id
        ));
        
        insert nonConformancesList;
        
        NonConformance obj = new NonConformance();
        List<Non_Conformance__c> nclist = obj.getNCList();
        System.assertNotEquals(nclist.size(), 0);
        Test.stopTest();
        
    
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END NonConformanceList
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Begin NonConformance_createNCCAPAJunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    public static testMethod void NonConformance_createNCCAPAJunction(){
       CAPA_Test.capaTestData();
       initData(); 
        
       Test.startTest();
        String capaListId=CAPA_Test.capaList[0].id;
        List<CAPA__c> capas=Database.query('SELECT Name FROM CAPA__c WHERE id=:capaListId');
        String result = NonConformance.createNCCAPAJunction(nonConformancesList[0].id,'NonConformance','NonConformance',capas[0].name);
        system.assertNotEquals(null,result);
        Test.stopTest();
        
        
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// End NonConformance_createNCCAPAJunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Begin NonConformance_createCAPAFromNC
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    public static testMethod void NonConformance_createCAPAFromNC(){
       CAPA_Test.capaTestData();
       initData(); 
        
       Test.startTest();
       
        String result = NonConformance.createCAPAFromNC(nonConformancesList[0].id,'NonConformance','NonConformance'); 
        system.assertNotEquals(null,result);
        Test.stopTest();
        
        
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// End NonConformance_createCAPAFromNC
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Class: Component_Handler for Chronology
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

 static testMethod void nc_chronology_class_test_method(){
            init();
            Non_Conformance__c ncf=new Non_Conformance__c(

                Defect__c = defectList[0].Id,
                Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                NC_Source__c = 'Other',
                Occurance_Date__c = Date.today(),
                Other_Source__c = 'The other other white meat',
                NC_Type__c = 'Process',
                Process__c = processList[0].Id,
                Reporter__c = userList[0].Id
            );
            nonConformancesList.add(ncf);

            insert nonConformancesList;

          Test.startTest();
          Component_Handler NCChro=new Component_Handler();
          NCChro.nccid=nonConformancesList[0].id;
          for(Date cr:NCChro.getHistoryDate()){
          
          }
          system.debug('NCChro.getHistoryDate().size() = ' + NCChro.getHistoryDate().size());
          system.assertNotEquals(0,NCChro.getHistoryDate().size());
          Component_Handler auditController=new Component_Handler();
          auditController.ncId=nonConformancesList[0].Id;
          system.assert(auditController.getHistories().size()>0);
          test.stopTest();  
 } // end of Method

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END Component_Handler for Chronology
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    

}