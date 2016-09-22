/*
Description : This is postInstall script to load custom setting , severity, probabaility etc. data.
Author: MaheshK
Release 1.2 

v1.3   Qualityze Inc(BK)       09-sep-2016      Default Numberscheme
*/
global class PostInstallClass implements InstallHandler {

  global void onInstall(InstallContext context) {

    if(context.previousVersion() == null) {
        //*********** Set values of protected custom settings              ****************
        List<Dev_Only__c> DevOnlyList = new List<Dev_Only__c>();
        
        Dev_Only__c DevOnlySetting = new Dev_Only__c(
            API_Version__c = '33.0',
            //Namespace_Prefix__c = 'QPMS'
            //Namespace_Prefix__c = 'QPMSQC2'
            Namespace_Prefix__c = ''
        );
        
        DevOnlyList.add(DevOnlySetting);
        
        if(DevOnlyList.size() > 0)
        {
            insert DevOnlyList;
        }
        
        populateSearchQueriesCustomSetting();
        populateQCSettingCustomSetting();
       

    //**********Create Risk Occurancer data *****************************
    List<Risk_Occurrence__c> occurrenceProbabilitiesList = new List<Risk_Occurrence__c>();

    Risk_Occurrence__c Rare = new Risk_Occurrence__c(Name = 'rare', Number__c = 1);
    Risk_Occurrence__c Unlikely = new Risk_Occurrence__c(Name = 'Unlikely', Number__c = 2);
    Risk_Occurrence__c Possible = new Risk_Occurrence__c(Name = 'Possible', Number__c = 3);
    Risk_Occurrence__c Likely = new Risk_Occurrence__c(Name = 'Likely', Number__c = 4);
    Risk_Occurrence__c AlmostCertain = new Risk_Occurrence__c(Name = 'Almost Certain', Number__c = 5);
    occurrenceProbabilitiesList.add(Rare);
    occurrenceProbabilitiesList.add(Unlikely);
    occurrenceProbabilitiesList.add(Possible);
    occurrenceProbabilitiesList.add(Likely);
    occurrenceProbabilitiesList.add(AlmostCertain);
    
    if(occurrenceProbabilitiesList.size() > 0)
    {
        insert occurrenceProbabilitiesList;
    }

    //**********Create Risk Priority data *******************************************
    List<Risk_Priority__c> riskPriorityList = new List<Risk_Priority__c>();
    Risk_Priority__c Low = new Risk_Priority__c (Name= 'Low', NUMBER__C = 1, THRESHOLD_ACTION__C = 'Default to No CAPA Required',DESCRIPTION__C = 'OK for now');
    Risk_Priority__c Medium = new Risk_Priority__c (Name= 'Medium', NUMBER__C = 2, THRESHOLD_ACTION__C = 'Default to Yes CAPA Required',DESCRIPTION__C = 'Follow management instruction');
    Risk_Priority__c High = new Risk_Priority__c (Name= 'High', NUMBER__C = 3, THRESHOLD_ACTION__C = 'Default to Yes CAPA Required',DESCRIPTION__C = 'Highest management decision is required urgently.');
    Risk_Priority__c Extreme = new Risk_Priority__c (Name= 'Extreme', NUMBER__C = 4, THRESHOLD_ACTION__C = 'Force Yes CAPA Required',DESCRIPTION__C = 'ACT NOW - Urgent');
    riskPriorityList.add(Low);
    riskPriorityList.add(Medium);
    riskPriorityList.add(High);
    riskPriorityList.add(Extreme);

    if(riskPriorityList.size() > 0)
    {
        insert riskPriorityList;
    }
    
    //**********Create Risk Severity data *******************************************
    List<Risk_Severity__c> riskSeverityList = new List<Risk_Severity__c>();
    Risk_Severity__c Insignificant = new Risk_Severity__c (Name= 'Insignificant', NUMBER__C= 1);
    Risk_Severity__c Minor = new Risk_Severity__c (Name= 'Minor', NUMBER__C= 2);
    Risk_Severity__c Moderate = new Risk_Severity__c (Name= 'Moderate', NUMBER__C= 3);
    Risk_Severity__c Major = new Risk_Severity__c (Name= 'Major', NUMBER__C= 4);
    Risk_Severity__c Catastrophic = new Risk_Severity__c (Name= 'Catastrophic', NUMBER__C= 5);
    riskSeverityList.add(Insignificant);
    riskSeverityList.add(Minor);
    riskSeverityList.add(Moderate);
    riskSeverityList.add(Major);
    riskSeverityList.add(Catastrophic);

    if(riskSeverityList.size() > 0)
    {
        insert riskSeverityList;
    }

    //**********Create Risk Lookup data *******************************************
    List<Risk_Lookup__c> riskLookupList = new List<Risk_Lookup__c>();

    Risk_Lookup__c RL1 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = AlmostCertain.id, SEVERITY_LEVEL__C = Insignificant.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL2 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = AlmostCertain.id, SEVERITY_LEVEL__C = Minor.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL3 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = AlmostCertain.id, SEVERITY_LEVEL__C = Major.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL4 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = AlmostCertain.id, SEVERITY_LEVEL__C = Moderate.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL5 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = AlmostCertain.id, SEVERITY_LEVEL__C = Catastrophic.id, RISK_PRIORITY__C = Extreme.id);

    Risk_Lookup__c RL6 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Likely.id, SEVERITY_LEVEL__C = Major.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL7 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Likely.id, SEVERITY_LEVEL__C = Insignificant.id, RISK_PRIORITY__C = Medium.id);
    Risk_Lookup__c RL8 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Likely.id, SEVERITY_LEVEL__C = Minor.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL9 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Likely.id, SEVERITY_LEVEL__C = Catastrophic.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL10 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Likely.id, SEVERITY_LEVEL__C = Moderate.id, RISK_PRIORITY__C = High.id);

    Risk_Lookup__c RL11 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Possible.id, SEVERITY_LEVEL__C = Moderate.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL12 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Possible.id, SEVERITY_LEVEL__C = Insignificant.id, RISK_PRIORITY__C = Low.id);
    Risk_Lookup__c RL13 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Possible.id, SEVERITY_LEVEL__C = Minor.id, RISK_PRIORITY__C = Medium.id);
    Risk_Lookup__c RL14 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Possible.id, SEVERITY_LEVEL__C = Catastrophic.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL15 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Possible.id, SEVERITY_LEVEL__C = Major.id, RISK_PRIORITY__C = Extreme.id);

    Risk_Lookup__c RL16 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Rare.id, SEVERITY_LEVEL__C = Major.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL17 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Rare.id, SEVERITY_LEVEL__C = Minor.id, RISK_PRIORITY__C = Low.id);
    Risk_Lookup__c RL18 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Rare.id, SEVERITY_LEVEL__C = Moderate.id, RISK_PRIORITY__C = Medium.id);
    Risk_Lookup__c RL19 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Rare.id, SEVERITY_LEVEL__C = Catastrophic.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL20 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Rare.id, SEVERITY_LEVEL__C = Insignificant.id, RISK_PRIORITY__C = Low.id);

    Risk_Lookup__c RL21 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Unlikely.id, SEVERITY_LEVEL__C = Major.id, RISK_PRIORITY__C = High.id);
    Risk_Lookup__c RL22 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Unlikely.id, SEVERITY_LEVEL__C = Minor.id, RISK_PRIORITY__C = Low.id);
    Risk_Lookup__c RL23 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Unlikely.id, SEVERITY_LEVEL__C = Insignificant.id, RISK_PRIORITY__C = Low.id);
    Risk_Lookup__c RL24 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Unlikely.id, SEVERITY_LEVEL__C = Catastrophic.id, RISK_PRIORITY__C = Extreme.id);
    Risk_Lookup__c RL25 = new Risk_Lookup__c (OCCURRENCE_PROBABILITY__C = Unlikely.id, SEVERITY_LEVEL__C = Moderate.id, RISK_PRIORITY__C = Medium.id);

    riskLookupList.add(RL1);
    riskLookupList.add(RL2);
    riskLookupList.add(RL3);
    riskLookupList.add(RL4);
    riskLookupList.add(RL5);
    riskLookupList.add(RL6);
    riskLookupList.add(RL7);
    riskLookupList.add(RL8);
    riskLookupList.add(RL9);
    riskLookupList.add(RL10);
    riskLookupList.add(RL11);
    riskLookupList.add(RL12);
    riskLookupList.add(RL13);
    riskLookupList.add(RL14);
    riskLookupList.add(RL15);
    riskLookupList.add(RL16);
    riskLookupList.add(RL17);
    riskLookupList.add(RL18);
    riskLookupList.add(RL19);
    riskLookupList.add(RL20);
    riskLookupList.add(RL21);
    riskLookupList.add(RL22);
    riskLookupList.add(RL23);
    riskLookupList.add(RL24);
    riskLookupList.add(RL25);
    
    if(riskLookupList.size() > 0)
    {
        insert riskLookupList;
    }

	
	//**********create default numbering scheme  *******************************************
	//v1.3 start
        List<Number_scheme__c> numberScheme = new List<Number_scheme__c>();
        Number_scheme__c NS = new Number_scheme__c (Name = 'Default Document Number', Number_format__c = '000001',Prefix__c = 'DOC',Revision__c='1',Suffix__c='YYYY',Module__c='Document');
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Number_scheme__c','Number_format__c,Prefix__c,Revision__c,Suffix__c,Module__c','create')){
            insert NS;    
        }
	//v1.3  end
    }// End Of IF 
  }
  public static void populateSearchQueriesCustomSetting() {
        //*********** Load QPMSQC2__QC_VfsearchQueries__c custom setting data ****************
        List<QC_VfsearchQueries__c> VfsearchQueriesList = new List<QC_VfsearchQueries__c>();
        
        QC_VfsearchQueries__c Account = new QC_VfsearchQueries__c (Name= 'Account', OBJECTNAME__C='Account', QueryFields__c='Id,Name', TYPE__C =  '');
        QC_VfsearchQueries__c AccountSOSL = new QC_VfsearchQueries__c (Name= 'AccountSOSL', OBJECTNAME__C='Account',  QueryFields__c='Id,Name', TYPE__C =  'sosl');
        QC_VfsearchQueries__c BusinessEntity  = new QC_VfsearchQueries__c (Name= 'BusinessEntity', OBJECTNAME__C='Business_Entity__c', QueryFields__c='Id,Name', TYPE__C =  '');
        QC_VfsearchQueries__c BusinessEntitySOSL = new QC_VfsearchQueries__c (Name= 'BusinessEntitySOSL', OBJECTNAME__C='Business_Entity__c', QueryFields__c='Id,Name', TYPE__C =  'sosl');
        QC_VfsearchQueries__c Defect = new QC_VfsearchQueries__c (Name= 'Defect', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  '');
        QC_VfsearchQueries__c DefectSOSL = new QC_VfsearchQueries__c (Name= 'DefectSOSL', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  'sosl');
        QC_VfsearchQueries__c ManufacturingSite = new QC_VfsearchQueries__c (Name= 'ManufacturingSite', OBJECTNAME__C='Manufacturing_Site__c', QueryFields__c='Id,Name', TYPE__C =  '' );
        QC_VfsearchQueries__c ManufacturingSiteSOSL = new QC_VfsearchQueries__c (Name= 'ManufacturingSiteSOSL', OBJECTNAME__C='Manufacturing_Site__c', QueryFields__c='Id,Name',TYPE__C =  'sosl');
        QC_VfsearchQueries__c Process = new QC_VfsearchQueries__c (Name= 'Process', OBJECTNAME__C='Process__c', QueryFields__c='Id,Name,Process_Code__c', TYPE__C =  '' );
        QC_VfsearchQueries__c ProcessSOSL = new QC_VfsearchQueries__c (Name= 'ProcessSOSL', OBJECTNAME__C='Process__c', QueryFields__c='Id,Name,Process_Code__c', TYPE__C =  'sosl');
        QC_VfsearchQueries__c Process_Defect = new QC_VfsearchQueries__c (Name= 'Process_Defect', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  'procsoql');
        QC_VfsearchQueries__c Process_DefectSOSL = new QC_VfsearchQueries__c (Name= 'Process_DefectSOSL', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  'procsosl');
        QC_VfsearchQueries__c Product = new QC_VfsearchQueries__c (Name= 'Product', OBJECTNAME__C='Product__c', TYPE__C =  '', QueryFields__c='Id,Name,Product_Code__c');
        QC_VfsearchQueries__c Product_Defect = new QC_VfsearchQueries__c (Name= 'Product_Defect', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  'prodsoql');
        QC_VfsearchQueries__c Product_DefectSOSL = new QC_VfsearchQueries__c (Name= 'Product_DefectSOSL', OBJECTNAME__C='Defect__c', QueryFields__c='Id,Name,Defect__c', TYPE__C =  'prodsosl');
        QC_VfsearchQueries__c ProductSOSL = new QC_VfsearchQueries__c (Name= 'ProductSOSL', OBJECTNAME__C='Product__c', QueryFields__c='Id,Name,Product_Code__c', TYPE__C =  'sosl');
        QC_VfsearchQueries__c RiskOccurance = new QC_VfsearchQueries__c (Name= 'Risk Occurance', OBJECTNAME__C='Risk_Occurrence__c', QueryFields__c='Id,Name,Number__c', TYPE__C =  '');
        QC_VfsearchQueries__c RiskOccuranceSOSL = new QC_VfsearchQueries__c (Name= 'Risk OccuranceSOSL', OBJECTNAME__C='Risk_Occurrence__c', QueryFields__c='Id,Name,Number__c', TYPE__C =  'sosl' );
        QC_VfsearchQueries__c RiskSeverity = new QC_VfsearchQueries__c (Name= 'Risk Severity', OBJECTNAME__C='Risk_Severity__c', QueryFields__c='Id,Name,Number__c', TYPE__C =  '');
        QC_VfsearchQueries__c RiskSeveritySOSL = new QC_VfsearchQueries__c (Name= 'Risk SeveritySOSL', OBJECTNAME__C='Risk_Severity__c', QueryFields__c='Id,Name,Number__c', TYPE__C =  'sosl');
        QC_VfsearchQueries__c CAPA = new QC_VfsearchQueries__c (Name= 'CAPA', OBJECTNAME__C='CAPA__c', QueryFields__c='Id,Name', TYPE__C =  '');
        QC_VfsearchQueries__c CAPASOSL = new QC_VfsearchQueries__c (Name= 'CAPASOSL', OBJECTNAME__C='CAPA__c', QueryFields__c='Id,Name', TYPE__C =  'sosl');
        QC_VfsearchQueries__c User = new QC_VfsearchQueries__c (Name= 'User', OBJECTNAME__C='User', QueryFields__c='Id,Name', TYPE__C =  '');
        QC_VfsearchQueries__c UserSOSL = new QC_VfsearchQueries__c (Name= 'UserSOSL', OBJECTNAME__C='User', QueryFields__c='Id,Name', TYPE__C =  'sosl');
        QC_VfsearchQueries__c DocumentType = new QC_VfsearchQueries__c (Name= 'Document Type', OBJECTNAME__C='Document_Type__c', QueryFields__c='Id,Name,Title__c', TYPE__C =  '');
        QC_VfsearchQueries__c DocumentTypeSOSL = new QC_VfsearchQueries__c (Name= 'Document TypeSOSL', OBJECTNAME__C='Document_Type__c', QueryFields__c='Id,Name,Title__c', TYPE__C =  'sosl');
        QC_VfsearchQueries__c DocumentProfile = new QC_VfsearchQueries__c (Name= 'Document Profile', OBJECTNAME__C='Document_Profile__c', QueryFields__c='Id,Name', TYPE__C =  '');
        QC_VfsearchQueries__c DocumentProfileSOSL = new QC_VfsearchQueries__c (Name= 'Document ProfileSOSL', OBJECTNAME__C='Document_Type__c', QueryFields__c='Id,Name', TYPE__C =  'sosl');
        QC_VfsearchQueries__c RiskPriority = new QC_VfsearchQueries__c(Name='Risk Priority',OBJECTNAME__C='Risk_Priority__c',QueryFields__c='Id,Name,Number__c',TYPE__C='');
        QC_VfsearchQueries__c RiskPrioritySOSL = new QC_VfsearchQueries__c(Name='Risk PrioritySOSL',OBJECTNAME__C='Risk_Priority__c',QueryFields__c='Id,Name,Number__c',TYPE__C='sosl');  
	    
      // ******************** Below code is for release 2.0 ***********************************************************************************
        QC_VfsearchQueries__c Cause = new QC_VfsearchQueries__c(Name='Cause',OBJECTNAME__C='Cause__c',QueryFields__c='Id,Name,Cause_Code__c',TYPE__C='');
        QC_VfsearchQueries__c CauseSOSL = new QC_VfsearchQueries__c(Name='CauseSOSL',OBJECTNAME__C='Cause__c',QueryFields__c='Id,Name,Cause_Code__c',TYPE__C='sosl');
        QC_VfsearchQueries__c DefectCause = new QC_VfsearchQueries__c(Name='Defect Cause',OBJECTNAME__C='Cause__c',QueryFields__c='Id,Name,Cause_Code__c',TYPE__C='defcsoql');
        QC_VfsearchQueries__c DefectCauseSOSL = new QC_VfsearchQueries__c(Name='Defect CauseSOSL',OBJECTNAME__C='Cause__c',QueryFields__c='Id,Name,Cause_Code__c',TYPE__C='defcsosl');
        

        // ***************************************************************************************************************************************
        
        
        QC_VfsearchQueries__c NumberScheme= new QC_VfsearchQueries__c(Name='NumberScheme',OBJECTNAME__C='Number_Scheme__c',QueryFields__c='Id,Name',TYPE__C='');
        QC_VfsearchQueries__c NumberSchemeSOSL= new QC_VfsearchQueries__c(Name='NumberSchemeSOSL',OBJECTNAME__C='Number_Scheme__c',QueryFields__c='Id,Name',TYPE__C='sosl');  
 
      
        VfsearchQueriesList.add(Account);
        VfsearchQueriesList.add(AccountSOSL);
        VfsearchQueriesList.add(BusinessEntity);
        VfsearchQueriesList.add(BusinessEntitySOSL);
        VfsearchQueriesList.add(Defect);
        VfsearchQueriesList.add(DefectSOSL);
        VfsearchQueriesList.add(ManufacturingSite);
        VfsearchQueriesList.add(ManufacturingSiteSOSL);
        VfsearchQueriesList.add(Process);
        VfsearchQueriesList.add(ProcessSOSL);
        VfsearchQueriesList.add(Process_Defect);
        VfsearchQueriesList.add(Process_DefectSOSL);
        VfsearchQueriesList.add(Product);
        VfsearchQueriesList.add(Product_Defect);
        VfsearchQueriesList.add(Product_DefectSOSL);
        VfsearchQueriesList.add(ProductSOSL);
        VfsearchQueriesList.add(RiskOccurance);
        VfsearchQueriesList.add(RiskOccuranceSOSL);
        VfsearchQueriesList.add(RiskSeverity);
        VfsearchQueriesList.add(RiskSeveritySOSL);
        VfsearchQueriesList.add(User);
        VfsearchQueriesList.add(UserSOSL);
        VfsearchQueriesList.add(Cause);
        VfsearchQueriesList.add(CauseSOSL);
        VfsearchQueriesList.add(DefectCause);
        VfsearchQueriesList.add(DefectCauseSOSL);
        VfsearchQueriesList.add(CAPA);
        VfsearchQueriesList.add(CAPASOSL);
        VfsearchQueriesList.add(DocumentType);
        VfsearchQueriesList.add(DocumentTypeSOSL);
		VfsearchQueriesList.add(DocumentProfile);
        VfsearchQueriesList.add(DocumentProfileSOSL);
        VfsearchQueriesList.add(RiskPriority);
        VfsearchQueriesList.add(RiskPrioritySOSL);
        VfsearchQueriesList.add(NumberScheme);
        VfsearchQueriesList.add(NumberSchemeSOSL);
        
  

        if(VfsearchQueriesList.size() > 0)
        {
            insert VfsearchQueriesList;
        }   
  }
  
  public static void populateQCSettingCustomSetting(){
        Schema.DescribeSObjectResult schmLUCs = Schema.SObjectType.General_Sub_Task__c;
        Map<String,Schema.RecordTypeInfo> GeneralSubTasksTypeInfos = schmLUCs.getRecordTypeInfosByName();
        Id AP_RectypeID = GeneralSubTasksTypeInfos.get('Action Plan').getRecordTypeId();
        Id ADT_RectypeID = GeneralSubTasksTypeInfos.get('AdhocTask Actions').getRecordTypeId();
        Id Cont_RectypeID = GeneralSubTasksTypeInfos.get('Containment Actions').getRecordTypeId();
        Id DS_RectypeID = GeneralSubTasksTypeInfos.get('Disposition Section').getRecordTypeId();
        Id RC_RectypeID = GeneralSubTasksTypeInfos.get('Root Cause').getRecordTypeId();
        Id VP_RectypeID = GeneralSubTasksTypeInfos.get('Verification Plans').getRecordTypeId(); 
         
         List<QC_settings__c> QC_settingsList = new List<QC_settings__c>();
            QC_settings__c QC_settings = new QC_settings__c(
                    Action_Plan_RecordTypeId__c=AP_RectypeID,
                    AdhocTask_Actions_RecordTypeId__c=ADT_RectypeID,
                    Containment_Action_RecordTypeId__c=Cont_RectypeID,
                    Disposition_Section_RecordTypeId__c =DS_RectypeID,
                    Root_Cause_RecordTypeId__c=RC_RectypeID,
                    Verification_Plan_RecordTypeId__c=VP_RectypeID,
                    Max_Approvers__c=10,
                    Is_Due_Date_Validation_Needed__c=true,
                    Is_Digital_Signature_Needed__c=false,
                    Connected_App_consumer_key__c='Need to replace with Connected APP consumer Key',
                    Connected_App_consumer_secret__c='Need to replace with connected app consumer secret',
                    Instance_Name__c='na30'
             );
        
        QC_settingsList.add(QC_settings);
        
        if(QC_settingsList.size() > 0)
        {
            insert QC_settingsList;
        }
  } // end of function
}