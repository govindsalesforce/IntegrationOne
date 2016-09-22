/*
v1.0    Qualityze Inc(ST)      29-JUL-2016      Initial Version.
                                                This class contains all Document Profile related code.
v1.1   Qualityze Inc(ST)       25-AUG-2016      Doc lists
v1.2   Qualityze Inc(ST)       25-AUG-2016      Doc Details
*/
public with sharing class DocumentProfileControllerExt {
    
    public Document_Profile__c documentProfile{get;set;}
    public Document_Profile__c DocumentProfiles{get;set;}
    public transient id dmid{get;set;}
     public transient id CurrentuserId;
    public transient string search{get;set;}
    public transient list<Non_Conformance__c> allNCs{get;set;}
    public transient list<CAPA__c> allCAPAs{get;set;}
    public transient list<Document_Profile__c> allDocs{get;set;}
    public transient Boolean allCheck{get;set;}
    public transient Boolean ncCheck{get;set;}
    public transient Boolean capaCheck{get;set;}
    public transient Boolean docCheck{get;set;}
    public transient List<DocumentJunction__c> nonConf{get;set;}
    public transient List<DocumentJunction__c> docList{get;set;}
    public transient List<DocumentJunction__c> capaList{get;set;}
    public transient List<DocumentJunction__c> docJunList;
    public transient List<Document_Profile__c> copyRevision{get;set;}
    public transient List<Document_type__c> documentTypeCreate;
    public transient string RevisionField{get;set;}
    public transient List<Approver__c>  documentProfileApprovers{get;set;}
    public transient List<User> userList{get;set;}
    public transient List<Group> groupList{get;set;}
    public transient List<Change_Management__c> CmList{get;set;}
    public transient string gid{get;set;}
    public transient General_Task__c gTask_cr{set;get;}
    public transient integer efMaplength;
    public transient List<General_Task__c> efrgenTaskId{get;set;}
    public transient List<General_Task__c> collgenTaskId{get;set;}
    public transient List<Document_Profile__c> documentReviseHistoryList{get;set;}
    public transient List<Document_Profile__c> documentReviseHistoryList1{get;set;}
    public integer getefMaplength()
    {
        efMaplength=efMap.size();
        return efMaplength;
    }
    public transient integer efMaplength_cr;
    public integer getefMaplength_cr()
    {
        efMaplength_cr=efMap.size();
        return efMaplength_cr;
    } 
    
    String queryFieldNamesDocJun;
    
    public void doSearch(){ 
        try{
            system.debug('allCheck--->'+allCheck);
            system.debug('ncCheck--->'+ncCheck);
            system.debug('capaCheck--->'+capaCheck); 
            system.debug('docCheck--->'+docCheck);
            
            if(search==null || search==''){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, 'search term must be longer than one character:'));
                return;
            }
                      
            String ncFields=QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Name,Ownerid,Owner.Name,NC_Source__c,NC_Type__c,NC_Status__c');
            String capaFields= QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,name,CAPA_Status__c,CAPA_Source__c,Title__c,Owner.Name');
            String docFields= QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Current_Rev__c,Type__c,Relation__c,Status__c,Owner.Name,Title__c');
            String Status = 'Current';
            String seachCondition = String.escapeSingleQuotes('%' + search + '%');
            system.debug('doSearch.seachCondition--->'+seachCondition);
            if(allCheck== true ||(ncCheck == false && allCheck == false && capaCheck == false && docCheck == false)){
                if(ncFields != '' && ncFields!= NULL){
                    allNCs = Database.query('SELECT '+ncFields+' FROM Non_Conformance__c WHERE name LIKE :seachCondition OR NC_Status__c LIKE :seachCondition OR NC_Type__c LIKE :seachCondition OR NC_Source__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition');    //(List<Non_Conformance__c>)searchList[0];   
                    //system.debug('allNCs--->2'+allNCs);
                }
                if(capaFields != '' && capaFields!= NULL){
                    allCAPAs = Database.query('SELECT '+capaFields+' FROM CAPA__c WHERE NAME LIKE :seachCondition OR CAPA_Status__c LIKE :seachCondition OR CAPA_Source__c LIKE :seachCondition OR Title__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition'); //(List<CAPA__c>)searchList[1];
                }
                if(docFields != '' && docFields != NULL){
                    allDocs = Database.query('SELECT '+docFields+' FROM Document_Profile__c WHERE (Id !=: dmid) AND (NAME LIKE :seachCondition OR Current_Rev__c LIKE :seachCondition OR Type__c LIKE :seachCondition OR Status__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition) AND Status__c =: Status'); //(List<Document_Profile__c>)searchList[2];
                }
                
            }else
            if(ncCheck == true ||(ncCheck == false && allCheck == false && capaCheck == false && docCheck == false)){
                //system.debug('ncCheck--->1'+allNCs);    
                
                if(ncFields != '' && ncFields!= NULL){
                    allNCs = Database.query('SELECT '+ncFields+' FROM Non_Conformance__c WHERE name LIKE :seachCondition OR NC_Status__c LIKE :seachCondition OR NC_Type__c LIKE :seachCondition OR NC_Source__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition');    //(List<Non_Conformance__c>)searchList[0];   
                    allCAPAs = new List<CAPA__c>();
                    allDocs = new List<Document_Profile__c>();
                }
                //system.debug('allNCs--->1'+allNCs);
            }
            else
            if((capaCheck == true) ||(ncCheck == false && allCheck == false && capaCheck == false && docCheck == false)){
                //system.debug('capaCheck--->1'+capaCheck);    
                
                if(capaFields != '' && capaFields!= NULL){
                    allCAPAs = Database.query('SELECT '+capaFields+' FROM CAPA__c WHERE NAME LIKE :seachCondition OR CAPA_Status__c LIKE :seachCondition OR CAPA_Source__c LIKE :seachCondition OR Title__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition'); //(List<CAPA__c>)searchList[1];
                    allNCs = new List<Non_Conformance__c>();
                    allDocs = new List<Document_Profile__c>();
                }
                //system.debug('allCAPAs--->1'+allCAPAs);
            }
            else
            if((docCheck == true) ||(ncCheck == false && allCheck == false && capaCheck == false && docCheck == false)){
                //system.debug('capaCheck--->1'+capaCheck);    
                
                if(docFields != '' && docFields != NULL){
                    allDocs = Database.query('SELECT '+docFields+' FROM Document_Profile__c WHERE (Id !=: dmid) AND (NAME LIKE :seachCondition OR Current_Rev__c LIKE :seachCondition OR Type__c LIKE :seachCondition OR Status__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition) AND Status__c =: Status'); //(List<Document_Profile__c>)searchList[2];
                    allNCs = new List<Non_Conformance__c>();
                    allCAPAs = new List<CAPA__c>();
                }
                //system.debug('allCAPAs--->1'+allCAPAs);
            }
            
        }
        catch(Exception ex){
             System.debug('Exception In DocumentProfileControllerExt   '+ex.getMessage());
        }
    }
    
    public DocumentProfileControllerExt(ApexPages.StandardController controller){
        
         try{
             
                
                        
            dmid=controller.getRecord().id;
            system.debug('this is dmid' + dmid);
            this.documentProfileApprovers=new List<Approver__c>();
            if(dmid!= null) {
                system.debug('dmid is here' + dmid);
                String fieldsToReturn ='';
                
                String namespacePrepend = '';
                if ('' != QC_custom_settings.getPrefix()) {
                    namespacePrepend =(QC_custom_settings.getPrefix()==null)?'': QC_custom_settings.getPrefix()+'__'; 
                }
                
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrepend + 'Document_Profile__c').getDescribe().fields.getMap();
                for( String fieldName : fieldMap.keySet() ) {
                    if(fieldsToReturn != '') {
                        fieldsToReturn += ', ';
                    }
                    fieldsToReturn += fieldName;
                    system.debug(' this is FieldsToReturn' + fieldsToReturn);
                    Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
                    String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
                    system.debug('This is relationshipName' + relationshipName);
                    if (relationshipName != null && relationshipName.endsWith('__r')) {
                        fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
                        if (relationshipName.equals(namespacePrepend + 'Reported_By__r')) {
                            fieldsToReturn += ', ' + relationshipName + '.FirstName' + ', ' + relationshipName + '.LastName';
                        }
                         if (relationshipName.equals(namespacePrepend + 'Document_Type__r')) {
                            fieldsToReturn += ', ' + relationshipName + '.Authorised_Entity_Users__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Authorised_Entity_Groups__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Viewonly_Entity_Users__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Viewonly_Entity_Groups__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Authorised_Entity_Users_Name__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Authorised_Entity_Groups_Name__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Viewonly_Entity_Users_Name__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Viewonly_Entity_Groups_Name__c' ;
                            fieldsToReturn += ', ' + relationshipName + '.Title__c' ;// update recent need to check later
                            
                        } 
                    }
                }
                
                fieldsToReturn += ', Owner.Name,Owner.FirstName,Owner.LastName, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
                
                // Build query string
                String selectAllFieldsForDocumentManagement = '';
                selectAllFieldsForDocumentManagement += 'select ' + fieldsToReturn + ' from Document_Profile__c where id = \'' + dmid + '\' limit 1';
                system.debug('Query is: ' + selectAllFieldsForDocumentManagement);
                documentProfile = database.query(selectAllFieldsForDocumentManagement);
                docReference(dmid);
                 userrecords();
                 groupsrecords();
            } else {
                documentProfile = new Document_Profile__c();
            }
                    
             String documentProfileId=((Document_Profile__c)controller.getRecord()).id;
             system.debug(' This is documentProfileId if needed to create new instance' + documentProfileId);
             cmrecords(documentProfileId,documentProfile.name);
             populateDPApproverList(documentProfileId);
             
             ////////////////////
             docprofid=ApexPages.currentPage().getParameters().get('id');
            system.debug('docprofid'+docprofid);
            DocumentProfiles= (Document_Profile__c)controller.getRecord();
        
                //loggedinUser
                loggedinUserName = [select Id, name from User where Id = :UserInfo.getUserId()].name;
                string queryFieldsDocProfile=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','Id,New_Owner__c,Document_Status__c,Owner.Name,OwnerId,New_Expiration_Date__c,Expiration_Date__c,CreatedById,CreatedDate,UD_Date__c,Title__c,Document_Type__r.Name,Department__c,Department__r.Name,Product__c,Product__r.Name,Process__c,Approval_Status__c,Process__r.Name,UD_Text__c,UD_RichText__c,Description__c,Document_Type__c,Status__c,Pre_Release_Duration_Date__c,Effectiveness_Review_Date__c,Date_of_Purge__c,ContentDocumentId__c,Initiating_Site__c,Initiating_Site__r.Name,Business_Unit__c,Grace_Period_for_Release__c,Expire_After__c,Effectiveness_Review_In_Advance__c,Retention_Duration__c,Effective_Date__c');
                system.debug('queryFieldsDocProfile');
                
                if(docprofid != null && queryFieldsDocProfile!=null && queryFieldsDocProfile!=''){ 
                    DocumentProfiles = database.query('SELECT '+queryFieldsDocProfile+' from Document_Profile__c where Id = :docprofid');
                   //DocumentProfiles=[Select Id,New_Owner__c,Document_Status__c,Owner.Name,OwnerId,New_Expiration_Date__c,Expiration_Date__c,CreatedById,CreatedDate,UD_Date__c,Title__c,Document_Type__r.Name,Department__c,Department__r.Name,Product__c,Product__r.Name,Process__c,Approval_Status__c,Process__r.Name,UD_Text__c,UD_RichText__c,Description__c,Document_Type__c,Status__c,Pre_Release_Duration_Date__c,Effectiveness_Review_Date__c,Date_of_Purge__c,ContentDocumentId__c,Initiating_Site__c,Initiating_Site__r.Name,Business_Unit__c,Grace_Period_for_Release__c,Expire_After__c,Effectiveness_Review_In_Advance__c,Retention_Duration__c,Effective_Date__c  from Document_profile__c where Id =:docprofid];
                    
                }
             system.debug('docprofid'+DocumentProfiles+'DocumentProfiles');
            
                string Doc_gtid=ApexPages.currentPage().getParameters().get('gtid_er');
                gid=ApexPages.currentPage().getParameters().get('gtid_er');
                string type=ApexPages.currentPage().getParameters().get('type');
                String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Collaboration_Title__c ,Primary_File_Location__c ,Record_Type_Name__c,New_Expiration_Date__c,Initial_Submitter__c,status__c,New_Due_Date__c,document_status__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c,Completed_date__c');
            
            
                if(queryFieldsGenapTask != null && queryFieldsGenapTask != ''){
                    efrgenTaskId = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Document_Profile__c=:docprofid and recordtype.name=\'EffectivenessReview\' order by createddate DESC');
                    collgenTaskId = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Document_Profile__c=:docprofid and recordtype.name=\'CollaborationReview\' order by createddate DESC');
                    
                    if( Doc_gtid!=''&& Doc_gtid!=null && docprofid!=null && Doc_gtid!='gt_init')
                    {
                      System.debug('Inside*****************');
                    gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :Doc_gtid');
                    string queryFieldsGtaskList=QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id,name,Initial_Submitter__c,status__c,New_Due_Date__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c');
                    
                    gTaskList=database.query('select  '+ queryFieldsGtaskList+'  from General_Task__c where status__c not in (\'Open\',\'Created\',\'Pending Approval\') and Document_Profile__c=:docprofid and id!=:Doc_gtid and recordtype.name=\'EffectivenessReview\' order by createddate');
                    system.debug('inside'+Doc_gtid);
                    system.debug(gTaskList+'gTaskList^^^');
                    
                    }
                    
                    if(Doc_gtid=='gt_init')
                    { 
                    
                        system.debug('inside notttttttt'+Doc_gtid);
                        string queryFieldsGtaskList=QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id,name,Initial_Submitter__c,status__c,New_Due_Date__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c');
                    
                    gTaskList=database.query('select  '+ queryFieldsGtaskList+'  from General_Task__c where status__c not in (\'Open\',\'Created\',\'Pending Approval\')  and   Document_Profile__c=:docprofid  and recordtype.name=\'EffectivenessReview\' order by createddate');
                    
                     system.debug(gTaskList+'gTaskList');
                    }
                }
                    // collabration changes
               string docGtidCr=ApexPages.currentPage().getParameters().get('gtid_cr');
               system.debug(docGtidCr+'docGtidCr');
                system.debug(Doc_gtid+'ddddddddddddd');
               String queryFieldsGenapTaskCr = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Collaboration_Title__c,Record_Type_Name__c ,Record_Type_Name__c,id,New_Expiration_Date__c,Primary_File_Location__c,Initial_Submitter__c,status__c,New_Due_Date__c,document_status__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c');
                if(queryFieldsGenapTaskCr != null && queryFieldsGenapTaskCr != ''){
                    if( docGtidCr!=''&& docGtidCr!=null && docprofid!=null && docGtidCr!='gt_init_cr')
                    {
                     gTask_cr = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :docGtidCr');
                     system.debug('****gTask_cr'+gTask_cr);
                      string queryFieldsGtaskList_cr=QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id,Collaboration_Title__c,name,Initial_Submitter__c,status__c,New_Due_Date__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c');
                    system.debug(Doc_gtid +'Doc_gtid **********');
                    gTaskList_cr=database.query('select  '+ queryFieldsGtaskList_cr+'  from General_Task__c where status__c not in (\'Open\',\'Created\',\'Pending Approval\') and status__c!= null and Document_Profile__c=:docprofid and id!=:docGtidCr and recordtype.name=\'CollaborationReview\' order by createddate');
                    system.debug('****gTaskList_cr'+gTaskList_cr);
                  
                    }
                    if(docGtidCr=='gt_init_cr')
                    { 
                    
                        system.debug('inside notttttttt'+Doc_gtid);
                        string queryFieldsGtaskList_cr=QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id,Collaboration_Title__c,name,Initial_Submitter__c,status__c,New_Due_Date__c,Approval_Required__c,Note_To_Approver__c,ChangeFieldApprovalStatus__c,Owner.name,Due_Date__c,Note_To_Approver_Owner_DueDate__c,Review_Description__c,New_Owner__c,ownerid,Approver__c,Approver_1__c ,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c');
                    
                    gTaskList_cr=database.query('select  '+ queryFieldsGtaskList_cr+'  from General_Task__c where status__c not in (\'Open\',\'Created\',\'Pending Approval\')   and recordtype.name=\'CollaborationReview\'  and Document_Profile__c=:docprofid  and Document_Profile__c!=null order by createddate');
                    
                     system.debug(gTaskList_cr+'gTaskList_cr****');
                    }
                    
                }
               
            //collabration changes
                        
                    
               
            
                 
                 getfg(); 
                 getfg1();
                 getfg2();
                 getcr1();
                 getcr();
                 getcr2();
                 getAppFinalHistory(); 
                 getAppFinalHistory_cr();
                 getNewBtfg();
                 getNewBtcr();
				 getMaxdate();
                 geter_message();
        
            
             ////////////////
             
            
        } catch(Exception ex){
            System.debug('Exception In  Document    '+ex.getMessage());
        }
        
        /*----------Document Revise and Temp story(Start)-------------*/
       /*  String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Current_Rev__c,Id,Name');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            system.debug('before QUERY' +documentProfile);
            string vq = documentProfile.Name;
            copyRevision = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Name =: vq ORDER BY CreatedDate DESC LIMIT 1');
        }
        if(!copyRevision.isEmpty())
        
        {
        RevisionField = copyRevision[0].Current_Rev__c;
        system.debug('value of REVISION FIELD' +RevisionField);  
        }
        else{
            copyRevision = new List<Document_Profile__c>();
        }*/
        
      
        /*----------Document Revise and Temp story(Stop)-------------*/
        //Document Revision History(Start)
        if(documentProfile.Name != null)
        {
            
        String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Status__c,Current_Rev__c,Expiration_Date__c,Effective_Date__c');
        if(queryFieldNames1 != null && queryFieldNames1 != '')
        {
            string docname = documentProfile.Name;
            string status = 'Current';
            documentReviseHistoryList = database.query ('select ' + queryFieldNames1 + ' from Document_Profile__c where Name =: docname AND Status__c =: status LIMIT 1000');
            system.debug('documentReviseHistoryList with sharing-->'+documentReviseHistoryList);
        }
            }
        else{
            documentReviseHistoryList = new List<Document_Profile__c>();
        }
       
        string docname = documentProfile.Name;
        documentHistoryExt dph1 = New documentHistoryExt();
        documentReviseHistoryList1 = dph1.dph(docname);
        system.debug('documentReviseHistoryList without sharing-->'+documentReviseHistoryList1);
         //Document Revision History(End)
                       
    }
    
    //by sanket
    public List<Document_Type__c> getDocumentTypeCreate(){
      
           system.debug('inside function');
           String docTypeIds =  ApexPages.currentPage().getParameters().get('doctypeId');
           if(String.isNotEmpty(docTypeIds)){
              system.debug('IdodDoc is here ' + docTypeIds);
              String queryDocQueryFieldNamesforDocProf = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,Name,Title__c');
              system.debug('queryDocQueryFieldNames is here'+queryDocQueryFieldNamesforDocProf);
              if(queryDocQueryFieldNamesforDocProf != null && queryDocQueryFieldNamesforDocProf != '') {
                  documentTypeCreate = database.query ('select ' + queryDocQueryFieldNamesforDocProf + ' from Document_Type__c WHERE Id=:docTypeIds');
                  system.debug('documentTypeCreate is coming here'+documentTypeCreate);
                  
                }
             
             }
             return documentTypeCreate;
                 
           
      }
     
    //by sanket 
    
    //WRITTEN BY SARATH Starting For Detail
    private void populateDPApproverList(String documentProfileId){
      try{
            DateTime dt;
            Map<Id,List<Approver__c>> approvers=new Map<Id,List<Approver__c>>(); 
            System.debug('populateDPApproverList.approvers'+approvers);
            //approverSize=0;
            String queryFieldSOfCRM = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Allowed_Days__c,Status_Updated__c,User__c,User__r.Name,Approver_Name__c,Due_Date__c,Sequence_Position__c,Status__c,Document_Profile__c');
            if(queryFieldSOfCRM!= null && queryFieldSOfCRM!= ''){                                                
                List<Approver__c> tempApprovers=null;    
                for(Approver__c approver : Database.query('Select '+ queryFieldSOfCRM +' From Approver__c where Document_Profile__c=:documentProfileId')){
                    tempApprovers=approvers.get(approver.Document_Profile__c);
                    if(tempApprovers==null){
                        tempApprovers=new List<Approver__c>();
                        approvers.put(approver.Document_Profile__c,tempApprovers);
                    }
                    tempApprovers.add(approver);
                    if(approver.Document_Profile__c==this.documentProfile.Id){
                        this.documentProfileApprovers.add(approver);
                    }
                }
                  
               // List<Approver__c> APS=null;
                String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,OriginalActorId,CreatedDate,actorid');
                String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,ElapsedTimeInDays,TargetObjectid,SubmittedById,CompletedDate, CreatedById,CreatedDate , Status');
                String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id,ElapsedTimeInDays,CreatedDate, StepStatus,OriginalActorId, Comments,Actorid');      
                if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
                    Map<id,Approver__c> userApprovers=null;
                    Map<Id,Map<id,Approver__c>> userApproversMap=new Map<Id,Map<id,Approver__c>>();
                    Set<Id> users=new Set<Id>();
                    Map<Id,Set<Id>> usersMap=new Map<Id,Set<Id>>();                   
                    Decimal Secquence=0;
                    integer maxProcessInstance=0;
                    List<Approver__c> existingApprovers=null;
                    //for(Id crmId : documentProfileId){
                        userApprovers=new Map<id,Approver__c>();
                        users=new Set<Id>();
                        Secquence=0;
                        maxProcessInstance=0;
                        existingApprovers=approvers.get(documentProfileId);
                        if(existingApprovers!=null){
                            for(Approver__c ap : approvers.get(documentProfileId)){
                                    users.add(ap.User__c);
                                    userApprovers.put(ap.User__c,ap);
                                    userApproversMap.put(ap.Document_Profile__c,userApprovers);
                                    usersMap.put(ap.Document_Profile__c,users);
                            }
                        }
                    //}
                    List<ProcessInstance> processInstances;
                    ProcessInstances=database.query('Select  '+queryFieldSOfPI +',ProcessDefinition.Name, ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps  ORDER BY CreatedDate asc) FROM ProcessInstance where TargetObjectId =:documentProfileId AND Status!=\'Removed\' ORDER BY CreatedDate DESC');       
                    Set<Id> userSet=null;
                    Approver__c userAppr=null;
                    Set<Id> workItemTasks=new Set<Id>();
                    Map<Id,Set<Id>> completedUsers=new Map<Id,Set<Id>>();
                    Set<Id> completedUserSet;
                    for(ProcessInstance pi:ProcessInstances){
                     if(pi.ProcessDefinition.Name !='Change Task Owner' && pi.ProcessDefinition.Name!='Change Due Date'){
                        for(ProcessInstanceWorkitem pw:pi.Workitems){
                            userSet=usersMap.get(pi.TargetObjectId);
                            workItemTasks.add(pi.TargetObjectId );
                            if(userSet!=null){
                             if(userSet.contains(pw.ActorId)){                            
                               userApproversMap.get(pi.TargetObjectId).get(pw.ActorId).Status__c='Pending';                                
                             }
                           }                       
                         }
                         boolean submitter=false;
                         for(ProcessInstanceStep ps:pi.Steps){
                          completedUserSet=completedUsers.get(pi.TargetObjectId);
                          completedUserSet=(completedUserSet==null)?new Set<Id>():completedUserSet;
                          if(!workItemTasks.contains(pi.TargetObjectId) && !completedUserSet.contains(ps.OriginalActorId)){
                            if(submitter){
                                userSet=usersMap.get(pi.TargetObjectId); 
                                if(userSet!=null){ 
                                    if(userSet.contains(ps.OriginalActorId)){   
                                        if(ps.ActorId==ps.OriginalActorId){
                                            userAppr=userApproversMap.get(pi.TargetObjectId).get(ps.ActorId);
                                            if(userAppr!=null)
                                                userAppr.Status__c=ps.StepStatus;
                                            if(ps.StepStatus!='Pending'){
                                                if(ps.ElapsedTimeInDays!=null){
                                                    dt=pi.CreatedDate;    
                                                    userApproversMap.get(pi.TargetObjectId).get(ps.ActorId).Status_Updated__c=date.newinstance(dT.year(), dT.month(), dT.day());                                        
                                                }
                                            }
                                        }
                                        else{
                                            userApproversMap.get(pi.TargetObjectId).get(ps.OriginalActorId).Status__c=ps.StepStatus;
                                            if(ps.StepStatus!='Pending'){
                                                if(ps.ElapsedTimeInDays!=null){
                                                    dt=pi.CreatedDate;    
                                                    userApproversMap.get(pi.TargetObjectId).get(ps.OriginalActorId).Status_Updated__c=date.newinstance(dT.year(), dT.month(), dT.day());                                        
                                                }
                                            }                                        
                                        }
                                        
       
                                    }
                                    completedUserSet=completedUsers.get(pi.TargetObjectId);
                                    if(completedUserSet==null){
                                          completedUserSet=new Set<Id>();
                                          completedUsers.put(pi.TargetObjectId,completedUserSet);
                                    }
                                    completedUserSet.add(ps.OriginalActorId);
                                }                                
                            }
                         }
                         else{
                            if(ps.ElapsedTimeInDays!=null){
                                dt=pi.CreatedDate;    
                                userApproversMap.get(pi.TargetObjectId).get(ps.OriginalActorId).Status_Updated__c=date.newinstance(dT.year(), dT.month(), dT.day());                                        
                             }
                            
                         }
                            submitter=true;
                         }
                        }
                        Integer appSeq=0;
                        Integer appPos=0;
                        List<Approver__c> workItemsApprovers=null;
                        System.debug('Component_Handler   workItemTasks   '+workItemTasks);
                        for(Id workItemTask : workItemTasks){
                            workItemsApprovers=approvers.get(workItemTask);
                            for(Integer pos=0; pos<workItemsApprovers.size();pos++){
                                if(workItemsApprovers[pos].Status__c=='Pending'){
                                    workItemsApprovers[pos].Status_Updated__c=null;
                                    for(Integer i=pos;i<workItemsApprovers.size();i++){
                                        workItemsApprovers[i].Status_Updated__c=null;
                                    }
                                    break;
                                }
                                workItemsApprovers[pos].Status__c='Approved';
                            }
                       }                            
                    }
            }                
                               
                
                
                
            }
        
      
      
    }
    catch(Exception ex){
        System.debug('Exception In Component_Handler.populateApproverList  '+ex.getMessage());
    }
  }
    //For Detail
    public void docReference(String dmid){
        
        try{
            System.debug('dmid: '+dmid);
            search='';
            //-------------------------------------------------------------------Start DOC NC-----------------------------------------------------------------------------------------------
            // bringing all nc,capa and doc details from junction object........
            queryFieldNamesDocJun = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c','Id,DocumentParent__c,DocumentParent__r.Name,RelationWithChild__c,RelationWithParent__c,Non_Conformance__c,Non_Conformance__r.Name,CAPA__c,CAPA__r.Name,DocumentChild__c,DocumentChild__r.Name,Current_Rev__c,NC_Type__c,Owner__c,Source__c,Status__c,Title__c,Child_Revision__c,Child_Status__c,Parent_Status__c,Child_Owner__c,Parent_Owner__c,Child_Title__c,Parent_Title__c');
            if(queryFieldNamesDocJun != null && queryFieldNamesDocJun != ''){
                docJunList = database.query('SELECT '+queryFieldNamesDocJun+' FROM DocumentJunction__c WHERE DocumentParent__c = :dmid OR DocumentChild__c = :dmid');
            }
            System.debug('docJunList---------------------->'+docJunList);
            
            if(!docJunList.isEmpty()){
                nonconf = new List<DocumentJunction__c>();
                capaList = new List<DocumentJunction__c>();
                docList = new List<DocumentJunction__c>();
                for(DocumentJunction__c docjn:docJunList){
                    if(String.isNotBlank(docjn.Non_Conformance__c)){
                        nonConf.add(docjn);
                    }
                    if(String.isNotBlank(docjn.CAPA__c)){
                        capaList.add(docjn);
                    }
                    if(String.isNotBlank(docjn.DocumentParent__c) && String.isNotBlank(docjn.DocumentChild__c)){
                        docList.add(docjn);
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Exception In  reference    '+ex.getMessage());
        }         
    }
    
    
   public void cmrecords(String documentProfileId, string name){
        
        system.debug('documentProfileId------------------>'+documentProfileId);
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Name,Source__c,Title__c,Owner.name,CreatedDate,Severity__c,Due_Date__c,Status__c,Current_Revision__c');
        if(queryFieldNames != null && queryFieldNames != ''){
        CmList = database.query('SELECT '+queryFieldNames+' FROM Change_Management__c where Document_Number__c =:documentProfileId ');
         system.debug('listvalues------------------------------------------>'+CmList);
       
        //select id,name from Change_Management__c where Document_Number__c = 'DOC-000107-2016'
        }
     }
    
     /////////////// written by satish  start//////////////////
    
    public void userrecords(){
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        if(queryFieldNames != null && queryFieldNames != ''){
       
        CurrentuserId = UserInfo.getUserId();
        system.debug('current user id is ' +CurrentuserId);

            
        userList = [SELECT Id,name FROM User WHERE isActive =: true And id !=:CurrentuserId limit 10000 ];

            system.debug('users list'+userList);
        
       }
      }
    
    
    public void groupsrecords(){
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,Name');
        
         if(queryFieldNames != null && queryFieldNames != ''){
             
   
             groupList = [SELECT Id,name FROM Group WHERE Type = 'Regular' limit 10000];

             
            
           
        }
        
       
    }
    
    
    public integer getusercount(){
     
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'Id,Name');
          if(queryFieldNames != null && queryFieldNames != '')
          {
                CurrentuserId = UserInfo.getUserId();
            return [SELECT count() FROM user WHERE isActive =: true And id !=:CurrentuserId limit 10000];
          }
          else
            {
              return 0;
            }
        
      
}
    
     public integer getgroupcount(){
     
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,Name');
          if(queryFieldNames != null && queryFieldNames != '')
          {
            return [SELECT count() FROM Group WHERE Type = 'Regular' limit 10000]; 
          }
          else
            {
              return 0;
            }
        
     
}
    
    
      @RemoteAction
    public static string AuthorisedEntityUsersSave(string doctypeID,string checkusrs,string checknames,string checkgrpsnames,string checkviewusrsName,string checkviewgropusrsName,boolean security,string checkgrps,string checkviewusrs,string checkviewgropusrs){
      
       
        Savepoint sp; 
        try{
            
            Document_Profile__c securityobj = new Document_Profile__c();
            
     String queryFieldS = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,Enable_Security__c,Authorised_Entity_Users__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Groups__c,Viewonly_Entity_Users__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c');
       
            if(queryFieldS != null && queryFieldS != '')
            {
                securityobj= database.query ('select ' + queryFieldS + ' from Document_Profile__c where Id =: doctypeID  LIMIT 1');
                securityobj.Enable_Security__c = security;
            }
            
            upsert securityobj; 
            
            
            
            
            if(queryFieldS!= null && queryFieldS!= ''){
           
         Document_Profile__c AuthUser = [select Id,name,Authorised_Entity_Users__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Viewonly_Entity_Users__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Groups__c from Document_Profile__c where Id =: doctypeID  LIMIT 1];
       
           system.debug('Current doc Type data' + AuthUser.Name);
           system.debug('Current doc Type' + checkusrs);
           if(checkusrs!= null && checkusrs != ''){
           checkusrs = checkusrs.removeStart('[');
           checkusrs = checkusrs.removeEnd(']');
           checknames = checknames.removeStart('[');
           checknames = checknames.removeEnd(']');   
           system.debug('DocumentProfileControllerExt. AuthorisedEntityUsersSave' + checkusrs);
           AuthUser.Authorised_Entity_Users__c = checkusrs.trim();
           AuthUser.Authorised_Entity_Users_Name__c = checknames.trim();
           }
           
            if(checkgrps!= null && checkgrps != ''){
                
                
            checkgrps = checkgrps.removeStart('[');
           checkgrps = checkgrps.removeEnd(']');
            checkgrpsnames = checkgrpsnames.removeStart('[');
           checkgrpsnames = checkgrpsnames.removeEnd(']');   
           system.debug('DocumentProfileControllerExt. AuthorisedEntityUsersSave' + checkusrs);
           AuthUser.Authorised_Entity_Groups__c = checkgrps.trim();
           AuthUser.Authorised_Entity_Groups_Name__c = checkgrpsnames.trim();
            }
            if(checkviewusrs!= null && checkviewusrs != ''){
                
                
            checkviewusrs = checkviewusrs.removeStart('[');
           checkviewusrs = checkviewusrs.removeEnd(']');
            checkviewusrsName = checkviewusrsName.removeStart('[');
           checkviewusrsName = checkviewusrsName.removeEnd(']');
           system.debug('DocumentProfileControllerExt. AuthorisedEntityUsersSave' + checkusrs);
           AuthUser.Viewonly_Entity_Users__c = checkviewusrs.trim();
           AuthUser.Viewonly_Entity_Users_Name__c = checkviewusrsName.trim();
            
            }
            if(checkviewgropusrs!= null && checkviewgropusrs != ''){
                
                
            checkviewgropusrs = checkviewgropusrs.removeStart('[');
           checkviewgropusrs = checkviewgropusrs.removeEnd(']');
            checkviewgropusrsName = checkviewgropusrsName.removeStart('[');
           checkviewgropusrsName = checkviewgropusrsName.removeEnd(']');
           system.debug('DocumentProfileControllerExt. AuthorisedEntityUsersSave' + checkusrs);
           AuthUser.Viewonly_Entity_Groups__c = checkviewgropusrs.trim();
           AuthUser.Viewonly_Entity_Groups_Name__c = checkviewgropusrsName.trim();
            
            }
            
            
           
           update AuthUser;
        
        
         
           
           
           list<string> UserAuthList = new list<string>();
           list<string> UsergroupList = new list<string>();
           list<string> ViewAuthList = new list<string>();
           list<string> ViewgroupList = new list<string>();
           
           
           UserAuthList = AuthUser.Authorised_Entity_Users__c.split(',');
           UsergroupList = AuthUser.Authorised_Entity_Groups__c.split (',');
           ViewAuthList = AuthUser.Viewonly_Entity_Users__c.split(',');
           ViewgroupList = AuthUser.Viewonly_Entity_Groups__c.split(',');
           
              List<Document_Profile__Share> AuthUsersCreate = new List<Document_Profile__Share>();
          if(UserAuthList.size()>0 ){
           for(string userIds : UserAuthList ){
              if(!string.isEmpty(userIds.trim())){
               Document_Profile__Share UserProfileShare = new Document_Profile__Share();
               UserProfileShare.ParentId=doctypeID;
               UserProfileShare.AccessLevel='Edit';
               UserProfileShare.UserOrGroupId=userIds.trim();
               AuthUsersCreate.add(UserProfileShare);
              } 
           }
          }
          if(UsergroupList.size()>0 ){
           for(string userIds : UsergroupList ){
            if(!string.isEmpty(userIds.trim())){
               Document_Profile__Share UserProfileShare = new Document_Profile__Share();
               UserProfileShare.ParentId=doctypeID;
               UserProfileShare.AccessLevel='Edit';
               UserProfileShare.UserOrGroupId=userIds.trim();
               AuthUsersCreate.add(UserProfileShare);
            } 
           }
          }
          
           
           
           if(ViewAuthList.size()>0 ){
           for(string userIds : ViewAuthList ){
            if(!string.isEmpty(userIds.trim())){
               Document_Profile__Share UserProfileShare = new Document_Profile__Share();
               UserProfileShare.ParentId=doctypeID;
               UserProfileShare.AccessLevel='Read';
               UserProfileShare.UserOrGroupId=userIds.trim();
               AuthUsersCreate.add(UserProfileShare);
            }  
           }
           }
          if(ViewgroupList.size()>0 ){
           for(string userIds : ViewgroupList ){
            if(!string.isEmpty(userIds.trim())){
               Document_Profile__Share UserProfileShare = new Document_Profile__Share();
               UserProfileShare.ParentId=doctypeID;
               UserProfileShare.AccessLevel='Read';
               UserProfileShare.UserOrGroupId=userIds.trim();
               AuthUsersCreate.add(UserProfileShare);
            }  
           } 
           }
           
           if( AuthUsersCreate != null && AuthUsersCreate.size() != 0 ) {
       
            insert AuthUsersCreate;
            
             }
                 
         
         
                   
        
        
        
        
        
        
        
        
        
         return AuthUser.Authorised_Entity_Users__c;
         return AuthUser.Authorised_Entity_Groups__c;
         return AuthUser.Viewonly_Entity_Users__c;
         return AuthUser.Viewonly_Entity_Groups__c;
         
         
        
            
        
    }
        }
         catch(exception ex){
        
         Database.rollback(sp);
         System.debug('Exception In Component_Handler.deleteContainmentAction  '+ex.getMessage());        
        
       
       }
    return null;
        
    }
    
    
    
    
    
    
      /////////////// written by satish  end//////////////////
    
    
  
    
   
    //Added by Gaurav for change document owner
   
    public boolean isDocOwnerSubmitter{get{
        if(processInstanceQuried==null){
            system.debug('controll');
            getProcessInstanceForDoc();   
        }
        return isDocOwnerSubmitter;
    }set;}
    
     public boolean processInstanceQuried;
     public boolean isChangeDocOwnerApprover{get{
        if(processInstanceQuried==null){
            getProcessInstanceForDoc();
        }
     return isChangeDocOwnerApprover;   
    }set;}
    
    public ProcessInstance getProcessInstanceForDoc(){
            
            string Pending='Pending';
            system.debug('inside processInstances getApprover DOC');
            String queryFieldSOfCAPAPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfCAPAPW);
            String queryFieldSOfCAPAPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
            system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfCAPAPI);
            String queryFieldSOfCAPAPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfCAPAPs);              
            if(queryFieldSOfCAPAPI!=null&&queryFieldSOfCAPAPI!=''&&queryFieldSOfCAPAPW!=null&&queryFieldSOfCAPAPW!=''&&queryFieldSOfCAPAPs!=null&&queryFieldSOfCAPAPs!=''){
               String DOC_id=ApexPages.currentPage().getParameters().get('Id');
                system.debug('inside processInstances if DOC_id'+DOC_id);
                List<ProcessInstance> CapaprocessInstances;
                CapaProcessInstances=database.query('Select  '+queryFieldSOfCAPAPI +', ( Select '+ queryFieldSOfCAPAPW +' from Workitems),( Select '+ queryFieldSOfCAPAPs +' from Steps) FROM ProcessInstance where TargetObjectId =:DOC_id And Status =: Pending limit 1'); 
                processInstanceQuried=true;
                system.debug('inside processInstances CapaProcessInstances'+CapaProcessInstances);     
                for(ProcessInstance pi:CapaProcessInstances){
                    if(pi.SubmittedById==Userinfo.getUserId()){
                        isDocOwnerSubmitter=true;
                    }
                    else{
                        isDocOwnerSubmitter=false;
                    }
                    for(ProcessInstanceWorkitem wi:pi.Workitems){
                        system.debug('inside processInstances wi.actorid'+wi.actorid); 
                        if(wi.actorid==Userinfo.getUserId()){
                            system.debug('inside processInstances wi.actorid if inside'+Userinfo.getUserId());
                            isChangeDocOwnerApprover=true;
                        }
                    }
                }
            }
        return null;
    }
   
    
     //Remoting for change document owner
   @RemoteAction
    public static boolean submitApprovalRequestDOCOwner(id ObjectId,string[] approverIds,string Comments,string ownerid){
        system.debug('controlls comes here');
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,Status__c,Note_To_Approver__c,New_Owner__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Name');
        system.debug('controlls');
        if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
            Document_Profile__c ca=database.query('Select '+ queryFieldSOfGT +' From Document_Profile__c where id=:ObjectId');
            system.debug('ca is here ' +ca);
            Integer len=approverIds.size();
            Savepoint sp;
            integer i=1;    
            ca.New_Owner__c=ownerid;
            ca.Approval_Status__c='';
            ca.Approver__c=approverIds[len-1];i++;                                                    
            ca.Approver_1__c=approverIds[((len-i>0)?len-i:0)];i++;                                       
            ca.Approver_2__c=approverIds[((len-i)>0)?len-i:0];i++;                                             
            ca.Approver_3__c=approverIds[((len-i)>0)?len-i:0];i++;
            ca.Approver_4__c=approverIds[((len-i)>0)?len-i:0];i++;
            ca.Approver_5__c=approverIds[((len-i)>0)?len-i:0];i++;
            ca.Approver_6__c=approverIds[((len-i)>0)?len-i:0];i++;
            ca.Approver_7__c=approverIds[((len-i)>0)?len-i:0];i++;
            ca.Approver_8__c=approverIds[((len-i)>0)?len-i:0];i++;  
            ca.Approver_9__c=approverIds[((len-i)>0)?len-i:0];i++;  
            ca.Note_To_Approver__c=Comments; 
            system.debug('DOC New_Owner__c'+ca.New_Owner__c);
            upsert ca;
            
            system.debug('DOC New_Owner__c after upsert'+ca.New_Owner__c);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(Comments);
            req.setObjectId(ObjectId);
            system.debug('objectid' +ObjectId);
            req.setSubmitterId(UserInfo.getUserId());
            
            
            Approval.ProcessResult results = Approval.process(req);        
            system.debug('result approval');
            system.debug(results.isSuccess());
            if(!results.isSuccess())
                Database.rollback(sp);
            return true;
        }
        else
            return false;
    } 
    
    //Follow DocManagement
    @RemoteAction
    public Static Integer followdocument(String docid, String userid){
        try{
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Followers__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                List<Document_Profile__c> doc = Database.query('SELECT '+queryFieldNames+' FROM Document_Profile__c WHERE Id=:docid');
                if(!doc.isEmpty()){
                    
                    doc[0].Followers__c=(doc[0].Followers__c==null)?userid:(doc[0].Followers__c+';'+userid);
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Followers__c','update')){
                        update doc;
                        return 0;
                    }else{
                        System.debug('Document_Profile__c followdoc  No update access to the fields  '+queryFieldNames);
                    }
                }
            }else{
                System.debug('Document_Profile__c followdoc  No update access to the fields  '+queryFieldNames);
            }       
            
        }catch(Exception ex){
            System.debug(ex);
        }
        
        return -1;
        
    } 
    
    //UnFollow Docmanagement
    
    @RemoteAction
    public static Integer unfollowDocument(String docid,String userId){
        try{
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Followers__c');
            String newFollowers='';
            String[] existingFollowers;
            if(queryFieldNames != null && queryFieldNames != ''){
                List<Document_Profile__c> doc = Database.query('SELECT '+queryFieldNames+' FROM Document_Profile__c WHERE Id=:docid');
                if(!doc.isEmpty()){
                    existingFollowers=doc[0].Followers__c.split(';');
                    for(String existingFollower : existingFollowers){
                        if(userId.equalsIgnoreCase(existingFollower)){
                            continue;
                        }
                        newFollowers+=existingFollower;
                    }
                    doc[0].Followers__c=newFollowers;
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Followers__c','update')){
                        update doc;
                        return 0;
                    }
                    else{
                        System.debug('Docprofile followdoc  No update access to the fields  '+queryFieldNames);
                    }
                }
            }
            else{
                System.debug('Docprofile followdoc  No access to the fields  '+queryFieldNames);
            }
        }
        catch(Exception ex){
            System.debug('Exception In followdoc   '+ex.getMessage());
        }
        return -1;
    }   
    
    @RemoteAction
    public static Integer saveDocReferences(List<Id> deletedIds,Id dpId,List<Id> selectedNCIds,List<Id> selectedDOCIds,List<Id> selectedCAPAIds,Map<id,Map<String,String>> docs){
        Savepoint sp;
        try{
            List<DocumentJunction__c> docJunList,selectedDocJun,onlyDocumentList;
            Set<id> existingIds;
            String docJunFields;
            docJunFields = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c','Id,DocumentParent__c,Non_Conformance__c,Non_Conformance__r.Name,CAPA__c,CAPA__r.Name,DocumentChild__c,DocumentChild__r.Name,Current_Rev__c,NC_Type__c,Owner__c,RelationWithParent__c,Source__c,Status__c,Title__c');
            System.debug('deletedIds------------------------------->'+deletedIds+' capaId--------------->'+dpId);
            
            if(!deletedIds.isEmpty()){
                if(docJunFields != null && docJunFields != ''){
                    docJunList = new List<DocumentJunction__c>();
                    docJunList = database.query('SELECT '+docJunFields+'  FROM DocumentJunction__c WHERE Id IN: deletedIds');
                    System.debug('docJunList------------------------------->'+docJunList);
                    if(!docJunList.isEmpty()){
                        if(DocumentJunction__c.sObjectType.getDescribe().isDeletable()){
                            delete docJunList;
                        }
                    }
                }
            }
           
            if(!selectedNCIds.isEmpty() || !selectedDOCIds.isEmpty() || !selectedCAPAIds.isEmpty()){
                if(docJunFields != null && docJunFields != ''){
                    selectedDocJun = new List<DocumentJunction__c>();
                    selectedDocJun = database.query('SELECT '+docJunFields+' FROM DocumentJunction__c WHERE (Non_Conformance__c IN: selectedNCIds OR CAPA__c IN: selectedCAPAIds OR DocumentParent__c IN: selectedDOCIds OR DocumentChild__c IN: selectedDOCIds) AND (DocumentChild__c =:dpId OR DocumentParent__c =:dpId)');
                }
                System.debug('selectedDocJun------------------------------->'+selectedDocJun);
                System.debug('selectedNCIds------------------------------->'+selectedNCIds);
                existingIds = new Set<Id>();
                if(!selectedDocJun.isEmpty()){
                    onlyDocumentList = new List<DocumentJunction__c>();
                    for(DocumentJunction__c docnc:selectedDocJun){
                        if(String.isNotBlank(docnc.Non_Conformance__c)){
                            existingIds.add(docnc.Non_Conformance__c);
                        }
                        if(String.isNotBlank(docnc.CAPA__c)){
                            existingIds.add(docnc.CAPA__c);
                        }
                        if(String.isNotBlank(docnc.DocumentParent__c) && String.isNotBlank(docnc.DocumentChild__c)){
                            existingIds.add(docnc.DocumentParent__c);
                            existingIds.add(docnc.DocumentChild__c);
                            onlyDocumentList.add(docnc);
                        }
                    }
                    selectedDocJun.clear();
                    for(Id n:selectedNCIds){
                        if(!existingIds.contains(n)){
                            selectedDocJun.add(new DocumentJunction__c(Non_Conformance__c = n ,DocumentParent__c = dpId));
                        }   
                    }
                    for(Id n:selectedCAPAIds){
                        if(!existingIds.contains(n)){
                            selectedDocJun.add(new DocumentJunction__c(CAPA__c = n ,DocumentParent__c = dpId));
                        }   
                    }
                    for(Id n:selectedDOCIds){
                        if(!existingIds.contains(n)){
                            selectedDocJun.add(new DocumentJunction__c(DocumentParent__c = dpId ,DocumentChild__c = n , RelationWithParent__c = docs.get(n).get('Relation')));
                        }else if(existingIds.contains(n)){
                            for(DocumentJunction__c dj : onlyDocumentList){
                                if(dj.DocumentParent__c == dpId && dj.DocumentChild__c == docs.get(n).get('Id')){
                                    dj.RelationWithParent__c = docs.get(n).get('Relation');
                                }
                            }
                        }   
                    }
                    if(!selectedDocJun.isEmpty()){
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('DocumentJunction__c','Non_Conformance__c,DocumentParent__c,DocumentChild__c,CAPA__c,RelationWithParent__c','create')){
                            insert selectedDocJun;
                        }
                    }
                    if(!onlyDocumentList.isEmpty()){
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('DocumentJunction__c','Non_Conformance__c,DocumentParent__c,DocumentChild__c,CAPA__c,RelationWithParent__c','update')){
                            update onlyDocumentList;
                        }
                    }
                    
                }else{
                    selectedDocJun = new List<DocumentJunction__c>();
                    for(Id nId:selectedNCIds){
                        selectedDocJun.add(new DocumentJunction__c(Non_Conformance__c = nId ,DocumentParent__c = dpId));
                    }
                    for(Id nId:selectedCAPAIds){
                        selectedDocJun.add(new DocumentJunction__c(CAPA__c = nId ,DocumentParent__c = dpId));
                    }
                    for(Id nId:selectedDOCIds){
                        selectedDocJun.add(new DocumentJunction__c(DocumentParent__c = dpId ,DocumentChild__c = nId,RelationWithParent__c = docs.get(nId).get('Relation')));
                    }
                    if(!selectedDocJun.isEmpty()){
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('DocumentJunction__c','Non_Conformance__c,DocumentParent__c,DocumentChild__c,CAPA__c,RelationWithParent__c','create')){
                            insert selectedDocJun;
                        }
                    }
                }
            }
        
        }catch(Exception ex){
            System.debug('Exception In DocumentProfileControllerExt  getLineNumber '+ex.getLineNumber());
            System.debug('Exception In DocumentProfileControllerExt  getTypeName '+ex.getTypeName());
            Database.rollback(sp);
            return -1;
        }        
        return 0;
    }    
    
    @RemoteAction
        public Static String createDocumentProfile(String docTypeid){ 
        system.debug('inside remoting'+docTypeid);
        String docID;
        try{
        
        List<Document_Profile__c> docprofile= new List<Document_Profile__c>();
        String queryDocProfFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Name,Id,OwnerId,Document_Type__c');
        
        system.debug('this is queryDocProfFieldNames'+queryDocProfFieldNames);
          if(queryDocProfFieldNames != null && queryDocProfFieldNames != ''){
          system.debug('inside the if query fields  nit blank');
                     //docprofile = Database.query('SELECT '+queryDocProfFieldNames+' FROM Document_Profile__c WHERE Document_Type__c=:docTypeid');
                     //system.debug('docProfile Id is ahere'+docprofile);
                     Document_Profile__c doc= new Document_Profile__c();
             doc.Document_Type__c = docTypeid;
            // docprofile.Owner.Name='Sanket';
             //docprofile.Name='test';
                     docprofile.add(doc);
         } //if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Document_Type__c','create')){
              system.debug('cdocprofile list is here'+docprofile);
              insert docprofile;
            
            // }
            docID = docprofile[0].Id;
            system.debug('docID is here'+docID);
        }catch(Exception ex){
            System.debug('Exception In createDocumentProfile   '+ex.getMessage());
            
            }
        return docID;
        }
    public static string docprofid{get;set;}
    public transient string loggedinUser{get;set;}
    public transient string loggedinUserName{get;set;}
    public transient General_Task__c gTask{set;get;}
    public transient list<General_Task__c> gTaskList{get;set;}
    public transient list<General_Task__c> gTaskList_cr{get;set;}
    public transient list<General_Task__c> ActiveGernalTasks{get;set;}
    public transient list<General_Task__c> ActiveGernalTasks_cr{get;set;}
    public transient List<Approver__c>oldApprovers{get;set;}
    public transient boolean fg=false;
    public transient boolean fg1=false;
    public transient boolean fg2=false;
    public transient boolean cr=false;
    public transient boolean cr1=false;
    public transient boolean cr2=false;
    public transient boolean NewBtfg;
    public transient boolean NewBtcr;
    Public boolean getNewBtfg()
    {
        
        String queryFieldsActiveGernalTasks = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id'); 
         if(queryFieldsActiveGernalTasks != null && queryFieldsActiveGernalTasks != ''){
            system.debug(queryFieldsActiveGernalTasks+'queryFieldsActiveGernalTasks');
         ActiveGernalTasks=database.query(' select '+ queryFieldsActiveGernalTasks +' from General_Task__c where status__c in(\'Open\',\'Pending Approval\',\'Created\') and Document_profile__c=:docprofid');
           system.debug(ActiveGernalTasks.size()+'***ActiveGernalTasks');
         }      
        if(ActiveGernalTasks.size()>0)
        {
            NewBtfg=false;
        }
        else{
            NewBtfg=true;
        }
        System.debug(NewBtfg+'***NewBtfg');
        return NewBtfg;
    }
    public boolean getfg()
    {  
        //system.debug(gTaskList+'gTaskList***First'+gTaskList.size());
        if(gTaskList!=null)
        {
             if(gTaskList.size()>0)
            {
               fg=true;
            }
            else
            {
                fg=false;
            }
        }
        return fg;
    }
     public boolean getfg1()
    {  
        system.debug(gTaskList+'gTaskList***');
        if(gTaskList!=null)
        {
             if(gTaskList.size()>1)
            {
               fg1=true;
            }
            else
            {
                fg1=false;
            }
        }
        return fg1;
    }
     public boolean getfg2()
    {  
        system.debug(gTaskList+'gTaskList***');
        if(gTaskList!=null)
        {
             if(gTaskList.size()>2)
            {
               fg2=true;
            }
            else
            {
                fg2=false;
            }
        }
        return fg2;
    }
    
    //crlist  visibility methods
    public boolean getcr()
    {  
        
        if(gTaskList_cr!=null)
        {
            system.debug(gTaskList_cr+'gTaskList***First_cr'+gTaskList_cr.size());
             if(gTaskList_cr.size()>0)
            {
               cr=true;
            }
            else
            {
                cr=false;
            }
        }
        return cr;
    }
    public boolean getcr1()
    {  
        
        if(gTaskList_cr!=null)
        { 
            system.debug(gTaskList_cr+'gTaskList***second'+gTaskList_cr.size());
             if(gTaskList_cr.size()>1)
            {
               cr1=true;
            }
            else
            {
                cr1=false;
            }
        }
        return cr1;
    }
    public boolean getcr2()
    {  
        //system.debug(gTaskList+'gTaskList***First'+gTaskList.size());
        if(gTaskList_cr!=null)
        {
             if(gTaskList_cr.size()>2)
            {
               cr2=true;
            }
            else
            {
                cr2=false;
            }
        }
        return cr2;
    }
     
    Public boolean getNewBtCr()
    {
        
        String queryFieldsActiveGernalTasks_cr = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id'); 
         if(queryFieldsActiveGernalTasks_cr != null && queryFieldsActiveGernalTasks_cr != ''){
            system.debug(queryFieldsActiveGernalTasks_cr+'queryFieldsActiveGernalTasks');
         ActiveGernalTasks_cr=database.query(' select '+ queryFieldsActiveGernalTasks_cr +' from General_Task__c where status__c in(\'Open\',\'Pending Approval\',\'Created\') and Document_profile__c=:docprofid');
           system.debug(ActiveGernalTasks_cr.size()+'***ActiveGernalTasks_cr'+ActiveGernalTasks_cr);
         }      
        if(ActiveGernalTasks_cr.size()>0)
        {
            NewBtcr=false;
        }
        else{
            NewBtcr=true;
        }
        System.debug(NewBtcr+'***NewBtcr');
        return NewBtcr;
    }
     
    
     
    
    
    
    public Document_Profile__c getDocumentProfile(){
        return DocumentProfiles;
    }
    
    public DocumentProfileControllerExt() {
    }
    public static date dateConversion(string dt)
    {   
        //dt=date.valueof(dt).format();
        system.debug(dt+'&&&&&&&&');
        list<string> cdate=dt.split('/');
        system.debug(cdate+'c');
        Integer myIntDate = integer.valueOf(cdate[0]);
        Integer myIntMonth = integer.valueOf(cdate[1]);
        Integer myIntYear = integer.valueOf(cdate[2]);
        Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
        system.debug(myIntDate+'myIntDate'+myIntMonth+'myIntMonth'+myIntYear+'myIntYear');
        return d;
    }
    
   //Update General task
    
   @RemoteAction
    public static  void UpdateGentask(String ep,string doc_st,String st1,Id st2,string dt,id dpid,Id gid)
    {
      
      Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId();
      
       //system.debug('Indise class');
       system.debug(gid+'gid');
       General_Task__c gt=new General_Task__c();
        
      string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','Review_Description__c,Document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
       system.debug('after access fields');
        Document_Profile__c docProf=new Document_Profile__c();
       string queryFieldsdoc=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','isRevise__c');
        if(queryFieldsdoc!=null && queryFieldsdoc!='')
        {
            docProf=database.query('select  ' +queryFieldsdoc+' from Document_profile__c where id=:dpid');
        }
       if(queryFieldsgt!=null && queryFieldsgt!='')
       {
       gt=database.query('select  ' +queryFieldsgt+' from General_task__c where id=:gid ');
       } 
         gt.Review_Description__c=st1;
         list<string> cdate=dt.split('/');
       
       
           Integer myIntDate = integer.valueOf(cdate[1]);
           Integer myIntMonth = integer.valueOf(cdate[0]);
           Integer myIntYear = integer.valueOf(cdate[2]);
           Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
   
       //System.debug('Month'+cdate[1]+'day'+cdate[0]+'year'+cdate[2]);
           gt.Completed_By__c=st2;
           gt.Completed_Date__c=d;
           gt.Status__c='Open';
           gt.Document_status__c=doc_st;
           gt.New_Expiration_Date__c=dateConversion(string.valueof(ep));
           gt.recordTypeid=recordTypeid;
          if(docProf.isRevise__c==true && doc_st=='Revise')
          {
              gt.status__c='Closed';
          }
           upsert gt;
       
       
    }
    //Save Gemeral task
    @RemoteAction
    public static  string SaveTask(string doc_st,String st1,Id st2,string dt,id st3, string dt1,id dpid,string ep)
    {
       system.debug('Indise class');
        Document_Profile__c docProf=new Document_Profile__c();
       string queryFieldsdoc=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','isRevise__c');
        if(queryFieldsdoc!=null && queryFieldsdoc!='')
        {
            docProf=database.query('select  ' +queryFieldsdoc+' from Document_profile__c where id=:dpid');
        }
       General_Task__c gt=new General_Task__c();
       
         //gt=[select id,Review_Description__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c from General_task__c where id=:gid ];
        //string recordTypeid=[select id FROM RecordType where name='effectivenessReview'].id;
         system.debug(Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId()+'recordTypeid');
         Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId();
         system.debug(recordTypeid+'recordTypeid');
     //string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,Document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
       
     //  if(queryFieldsgt!=null && queryFieldsgt!='')
       //{
      // gt=database.query('select' +queryFieldsgt+' from General_task__c where id=:gid ');
      // }
         gt.Review_Description__c=st1;
         list<string> cdate=dt.split('/');
       
       
           Integer myIntDate = integer.valueOf(cdate[1]);
           Integer myIntMonth = integer.valueOf(cdate[0]);
           Integer myIntYear = integer.valueOf(cdate[2]);
           Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
   
       System.debug('Month'+cdate[1]+'day'+cdate[0]+'year'+cdate[2]);
           gt.Completed_By__c=st2;
           gt.Completed_Date__c=d;
           gt.Status__c='Open';
           gt.Due_date__C=dateConversion(dt1);
           gt.Owner__c=st3;
           gt.Allowed_Days__c=10;
           gt.Document_status__c=doc_st;
           gt.Document_profile__c=dpid;
           system.debug(ep+'ep***');
           gt.New_Expiration_Date__c=dateConversion(string.valueof(ep));
           system.debug(ep+'ep*************1');
           gt.recordTypeid=recordTypeid;
         /* if(docProf.isRevise__c==true && doc_st=='Revise')
          {
              gt.status__c='Closed';
          }*/
           insert gt;
       
       return gt.id;
    
    }
    //submit general task
    @RemoteAction
    public static  void SubmitTask(string ep,String st1,Id st2,string dt,Id gid,boolean ch,string st3,Id dpid)
    {   
        
        
        
        system.debug(dpid+'Doc_pid');
        General_Task__c gt=new General_Task__c();
        string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,New_Expiration_Date__c,document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
       
       if(queryFieldsgt!=null && queryFieldsgt!='')
       {
       gt=database.query('select ' +queryFieldsgt+' from General_task__c where id=:gid ');
       }
        //gt=[select id,Review_Description__c,New_Expiration_Date__c,document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c from General_task__c where id=:gid ];
        gt.Review_Description__c=st1;
        list<string> cdate=dt.split('/');
           Integer myIntDate = integer.valueOf(cdate[1]);
           Integer myIntMonth = integer.valueOf(cdate[0]);
           Integer myIntYear = integer.valueOf(cdate[2]);
           Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
           gt.Completed_By__c=st2;
           gt.Completed_Date__c=d;
           gt.Task_Closed_Date__c=system.today();
           gt.document_status__c=st3;
           gt.New_Expiration_Date__c=dateConversion(string.valueof(ep));
           
           if(ch==false)
           { 
            system.debug('Inside if');
            gt.Status__c='closed';
           }
       update gt;
       
      // Document_Profile__c dp = [select Id,document_status__c,New_Owner__c,Status__c ,Owner.name,ownerid,Due_date__c,New_Expiration_Date__c,  Expiration_Date__c,CreatedByid,createddate from Document_Profile__c where id=:dpid];
        Document_Profile__c dp=new Document_Profile__c();
        String queryFieldsdp = QC_DynamicObjectHandler.getAccessibleFields ('Document_Profile__c','Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c');
        dp=database.query('select '+queryFieldsdp+' from Document_Profile__c where id=:dpid');
        system.debug(dp+'%%%%%%%%%');
       if(ch==false && (st3=='Keep Status Current'))
       {
            
             dp.Expiration_Date__c=dateConversion(string.valueof(ep));
             dp.New_Expiration_Date__c=gt.Task_Closed_Date__c;
             dp.status__c='Current';
             system.debug(dp.Document_status__c);
            
       }
      else if(ch==false && (st3=='Revise'))
       {    
           
            Set<String> contentVersionIdSet=new Set<String>();
            System.debug('inside debug');
            if(dp.isRevise__c==false)
           {
            //Id Doc_pid=ApexPages.currentPage().getParameters().get('id');
            system.debug(dpid+'&&&&');
            dp.status__c=st3;
            
            //Document_Profile__c dp = [select Id,name,New_Owner__c,Status__c ,Owner.name,ownerid,Due_date__c,New_Expiration_Date__c,   Expiration_Date__c,CreatedByid,createddate from Document_Profile__c where id=:dpid];
            Document_Profile__c dp_new=dp.clone(false,true,false,false);
            dp.isRevise__c=true;
            contentVersionIdSet.add(dp.ContentVersionId__c);
            contentVersionIdSet.add(dp.SecondaryContentVersionId__c);
            Map<String,List<String>> revisedContentVersions = Component_Handler.reviseContentDocument(contentVersionIdSet);
           List<String> contentVersions=null;
                            for(String orginalContentVersionId:revisedContentVersions.keySet()){
                            contentVersions=revisedContentVersions.get(orginalContentVersionId);
                            if(orginalContentVersionId==dp.ContentVersionId__c){
                                dp_new.ContentVersionId__c=contentVersions[0];
                                dp_new.ContentDocumentId__c=contentVersions[1];
                            }
                            else if(orginalContentVersionId==dp.SecondaryContentVersionId__c){
                                dp_new.SecondaryContentVersionId__c=contentVersions[0];
                                dp_new.SecondaryContentDocumentId__c=contentVersions[1];
                            }
                        }
            dp_new.status__c='Draft';
            dp_new.Current_Rev__c=getRevisionvalue(dp.Current_Rev__c);
            dp_new.name=dp.name;
            insert dp_new;
            System.debug(dp_new.id+'dp_new.id');
           }
           else
           {
               gt.Status__c='Closed';
               update gt;
           }
       }
       
      else if(ch==false && (st3=='Expire'))
       {
        dp.status__c='Expired';
        dp.Expiration_Date__c= dateConversion(string.valueof(ep));
       }
       update dp;
       system.debug(dp+'^^^^^^^^^^');
    }
    //New submit generaltask
     @RemoteAction
    public static  string newSubmitTask(string ep,String st1,Id st2,string dt,boolean ch,string st3,Id dpid,id st4, string dt1)
    {   
        
        
        
        system.debug(dpid+'Doc_pid');
        General_Task__c gt=new General_Task__c();
        gt.Review_Description__c=st1;
        Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId();
    
        
        list<string> cdate=dt.split('/');
           Integer myIntDate = integer.valueOf(cdate[1]);
           Integer myIntMonth = integer.valueOf(cdate[0]);
           Integer myIntYear = integer.valueOf(cdate[2]);
           Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
           gt.Completed_By__c=st2;
           gt.Completed_Date__c=d;
           gt.Task_Closed_Date__c=system.today();
           gt.Allowed_Days__c=10;
           gt.Document_Profile__c=dpid;
           gt.due_date__c=dateConversion(dt1);
           gt.recordtypeid=recordTypeid;
           gt.document_status__c=st3;
           gt.New_Expiration_Date__c=dateConversion(string.valueof(ep));
           if(ch==false)
           { 
            system.debug('Inside if');
            gt.Status__c='closed';
           }
            insert gt;
            system.debug(gt.id+'generaltaskid');
            //Document_Profile__c dp = [select Id,New_Owner__c,Status__c ,Owner.name,ownerid,Due_date__c,New_Expiration_Date__c,    Expiration_Date__c,CreatedByid,createddate from Document_Profile__c where id=:dpid];
             Document_Profile__c dp=new Document_Profile__c();
             dp=[select Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,ApprovalProcess__c,Approval_Process_Complete__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,CurrentApprovalSequenceNumber__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c from Document_Profile__c where id=:dpid];
            system.debug(dp+'dppppppppppppp'+DP.isRevise__c);
             //string queryFieldsdp = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c',' Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,ApprovalProcess__c,Approval_Process_Complete__c,Approval_Required__c,Approval_Status__c,Approved_Date__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Approver__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,Collaboration_Review__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,CurrentApprovalSequenceNumber__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Note_To_Approver__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c');
        string queryFieldsdp = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,ApprovalProcess__c,Approval_Process_Complete__c,Approval_Required__c,Approval_Status__c,Approved_Date__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Approver__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,Collaboration_Review__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,CurrentApprovalSequenceNumber__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Note_To_Approver__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c');
       
         if(queryFieldsdp!= null &&queryFieldsdp!='')
        {
          dp=database.query('select '+queryFieldsdp+' from Document_Profile__c where Id=:dpid');
        }
       if(ch==false && (st3=='Keep Status Current'))
       {
            
            dp.Expiration_Date__c=dateConversion(string.valueof(ep));
            dp.New_Expiration_Date__c=gt.Task_Closed_Date__c;
            dp.status__c='Current';
            update dp;
       }
       
       if(ch==false && (st3=='Expire'))
       {
         dp.status__c='Expired';
         dp.Expiration_Date__c=dateConversion(string.valueof(ep));
       }
        
       if(ch==false && (st3=='Revise'))
       {    
        System.debug('inside debug');
            Set<String> contentVersionIdSet=new Set<String>();
           if(dp.isRevise__c==false)
           {
            //Id Doc_pid=ApexPages.currentPage().getParameters().get('id');
            system.debug(dpid+'&&&&');
            //Document_Profile__c dp = [select Id,name,Current_Rev__c,Document_Profile_Auto_Number__c,New_Owner__c,Status__c ,Owner.name,ownerid,Due_date__c,New_Expiration_Date__c,   Expiration_Date__c,CreatedByid,createddate from Document_Profile__c where id=:dpid];
            
            dp.Status__c='Current';
           
            Document_Profile__c dp_new=dp.clone(false,true,false,false);
                dp.isRevise__c=true;
            dp_new.status__c='Draft';
            contentVersionIdSet.add(dp.ContentVersionId__c);
            contentVersionIdSet.add(dp.SecondaryContentVersionId__c);
            Map<String,List<String>> revisedContentVersions = Component_Handler.reviseContentDocument(contentVersionIdSet);
           List<String> contentVersions=null;
                            for(String orginalContentVersionId:revisedContentVersions.keySet()){
                            contentVersions=revisedContentVersions.get(orginalContentVersionId);
                            if(orginalContentVersionId==dp.ContentVersionId__c){
                                dp_new.ContentVersionId__c=contentVersions[0];
                                dp_new.ContentDocumentId__c=contentVersions[1];
                            }
                            else if(orginalContentVersionId==dp.SecondaryContentVersionId__c){
                                dp_new.SecondaryContentVersionId__c=contentVersions[0];
                                dp_new.SecondaryContentDocumentId__c=contentVersions[1];
                            }
                        }
            system.debug(dp.Current_Rev__c+'dp.Current_Rev__c');
            dp_new.Current_Rev__c=getRevisionvalue(string.valueof(dp.Current_Rev__c));
            insert dp_new;
            //dp_new.name=dp.name;
            update dp_new;
            
            System.debug(dp_new.id+'dp_new.id');
       }
           else
           {
                gt.status__c='Closed';
                update gt;
           }
    
       
     }
      update dp;
       return gt.id;
    
    }
    
    
    
    //V1.1 STARTS
    public DocumentProfileControllerExt(NonConformance controller){}
    
    public List<Document_profile__c> getDPListForDisplay()
    {
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_profile__c', 'Id,Status__c,Name,OwnerId,Owner.Name,Title__c,CreatedDate,CreatedBy.Name,Description__c,Impacted_Sites__c,Business_Unit__c,Initiating_Site__c,Initiating_Site__r.Name,Product__c,Product_Name__c,Process_Name__c,Process__c,Department__c,Department__r.Name,Document_Type__c,Document_Type__r.Title__c');
        System.debug('getDPListForDisplay.DPList  ');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            List<Document_profile__c> dpList = database.query ('select ' + queryFieldNames + ' from Document_profile__c where Status__c != \'Closed\' ORDER BY createddate DESC');
            System.debug('getDPListForDisplay.dpList  '+dpList);
            return dpList;
        }
        else{
            return null;
        }
    }
    //V1.1 END
   
           @RemoteAction
public Static Document_Profile__c updateActStatusOnNewDoc(String chManagmtId,String subChangeId,String NewDocumentId,String Documenttype,String documentChanges){ 
    system.debug('inside updateact remoting'+subChangeId);
    system.debug('NewDocumentId is here'+NewDocumentId);
    Document_Profile__c docActstatus;
    try{
            
            String queryDocProfilesFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Name,Id,Change_Management__c,Action_Status__c,Type__c,Status__c,Document_Specific_Changes__c');
            
            system.debug('this is queryDocProfilesFieldNames'+queryDocProfilesFieldNames);
            if(queryDocProfilesFieldNames != null && queryDocProfilesFieldNames != ''){
                 system.debug('inside the if fields are accessible');
                 docActstatus = Database.query('SELECT '+queryDocProfilesFieldNames+' FROM Document_Profile__c WHERE Id=:NewDocumentId');
                 system.debug('docActstatus is here'+docActstatus);
                 docActstatus.Change_Management__c=chManagmtId;
                 docActstatus.Type__c=Documenttype;
                 docActstatus.Status__c='Draft';
                 docActstatus.Action_Status__c='Completed';
                 docActstatus.Document_Specific_Changes__c= documentChanges;
                 //if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Action_Status__c','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Id,Action_Status__c','update')) 
                      
                    // system.debug('docActstatus is here inside update access'+docActstatus);
                     update docActstatus;
                     system.debug('docActstatus is here final'+docActstatus);
                     
               }
               
                Sub_Change_Management__c isDocCreatedBoolean;
                 String querySubChangeMgmtFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,isDocCreated__c');
                         if(querySubChangeMgmtFieldNames != null && querySubChangeMgmtFieldNames != ''){
                                      system.debug('querySubChangeMgmtFieldNames is here'+querySubChangeMgmtFieldNames);
                                      isDocCreatedBoolean = Database.query('SELECT '+querySubChangeMgmtFieldNames+' FROM Sub_Change_Management__c WHERE Id=:subChangeId');
                                      system.debug('isDocCreatedBoolean is here'+isDocCreatedBoolean);
     
                                      isDocCreatedBoolean.isDocCreated__c=true;
                                      system.debug('isDocCreatedBoolean consists of true'+isDocCreatedBoolean);
                                     
                                      upsert isDocCreatedBoolean;
                         }
            //system.debug('doc is here'+docActstatus);
    }catch(Exception ex){
            System.debug('Exception In updateActStatusOnNewDoc   '+ex.getMessage());
            
        }
    return docActstatus;
} 
   //*********************************************************************************************
public  class EffectivenessReview{
    
    public transient string owner{set;get;} 
    public transient string ownerName{set;get;} 
    public transient string documentStatus{set;get;}    
    public transient string revDescription{set;get;}
    public transient string Reviewer_Name{set;get;}
    public transient string status{set;get;}
    public transient date dueDate{set;get;}
    public transient date newExpirationDate{set;get;}   
    public transient date Approval_Date{set;get;}
    public transient date review{set;get;}
    public integer incrementer{get;set;}
    public string gtid{set;get;}
    public transient boolean show{get;set;}
    public transient string mssage{set;get;}
    public transient boolean showMsg{get;set;}
}
   public list<General_Task__c> gtDetails{get;set;}
    {
    gtDetails=new list<General_Task__c> ();
    }
    public  list<ProcessInstance> appHistory=new list<ProcessInstance>();
    public list<EffectivenessReview> efferevList=new list<EffectivenessReview>();
     public EffectivenessReview rev1{get;set;}
     public EffectivenessReview rev2{get;set;}
     public list<EffectivenessReview>er_rev1{get;set;}
     public list<EffectivenessReview>er_rev2{get;set;}
     {
     er_rev2=new list<EffectivenessReview>();
     er_rev1=new list<EffectivenessReview>();
     }
      Set<string> gtDubCheck{get;set;}
     Map<Id,EffectivenessReview> efMap = new Map<Id,EffectivenessReview>();
    ////v1.2 start
    Public Map<Id, EffectivenessReview> effRevHistory{get;set;}{
        effRevHistory = new Map<Id,EffectivenessReview>();
    }
    ////v1.2 end
     Public Map<Id, EffectivenessReview> getAppFinalHistory()
     {  string a=docprofid;
        system.debug('aaaaaaaaa'+a);
        gtDetails=[select Owner.id,id,owner.Name,Due_Date__c,Document_Status__c,Approval_Required__c,Task_Closed_Date__c,New_Expiration_Date__c,Review_Description__c,lastmodifieddate from General_Task__c where document_profile__c=:a  and status__c in('closed','rejected') and recordtypeid=:Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId()and id!=:gid order by createddate DESC ];
        system.debug(gtDetails+'gtDetails******');
        appHistory=[SELECT CompletedDate,CreatedById,CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance where TargetObjectId in(select id from General_task__c where document_profile__c=:a and Status__c in('closed','rejected') ) and  status!='removed']; 
        system.debug(docprofid+'docprofid**9'+appHistory);
        map<id,string> userlist=new map<id,string>();
        list<user> users=[select id,name from user];
        for(user u:users)
        {
            userlist.put(u.id,u.Name);
        }
     
     list<ProcessInstance> m = new list<ProcessInstance>([SELECT CompletedDate,CreatedById,CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance where TargetObjectId in(select id from General_task__c where document_profile__c=:docprofid and Status__c in('closed','rejected') ) and  status!='removed']); 
       
        Map <string ,ProcessInstance> pI=new Map <string ,ProcessInstance>();
      {
          for(ProcessInstance p:m)
          {
            pI.put(p.TargetObjectId,p);
            system.debug(p.TargetObjectId+'direct');
            system.debug(p+'direct');
            system.debug('docprofid***'+docprofid);
          }
      }
     
     
         integer i=0;
         
         system.debug(appHistory+'appHistory******');
         system.debug(pI+'pI******');
         
         //system.debug(pI.get(gtDetails[0].id)+'&&&&&'+gtDetails[0].id);
         System.debug(gtDetails+'length'+gtDetails.size());
         gtDubCheck=new set<string>();
        
         
         
         for(General_Task__c g:gtDetails)
         {
            system.debug(pI.get(string.valueof(g.id))+'###'+g.id);
            
            i++;
            system.debug(i+'ivalue');
            system.debug(gtDubCheck+'hh');
            
            if(i==1)
            
            {   
                system.debug(i+'ivalue');
                system.debug('inside******1'+g);
                rev1=new EffectivenessReview();
                rev1.Owner=g.owner.id;
                rev1.show=false;
                rev1.OwnerName=g.Owner.Name;
                rev1.dueDate=g.Due_Date__c;
                system.debug(g.Due_Date__c+'g.Due_Date__c');
                rev1.documentStatus=g.Document_status__c;
                rev1.newExpirationDate=g.New_Expiration_Date__c;
                rev1.revDescription=g.Review_description__c;
                rev1.review=g.Task_Closed_Date__c;
                if(g.Approval_Required__c=='yes')
              {
                 system.debug('inside******if');
                 rev1.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                 rev1.status=pI.get(string.valueof(g.id)).Status;
                  if(pI.get(string.valueof(g.id)).Status=='Pending')
                  {
                    rev1.show=false;
                    rev1.showMsg=true;
                    rev1.mssage='This review closed due to a draft revision of this document already exist.';
                    
                  }
                  else
                  {
                      rev1.show=true;
                      
                  }
                 rev1.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                  
              }
              else
              {
              rev1.Approval_Date=date.valueof(g.lastmodifieddate);
              }
                system.debug(rev1+'rev1******');
                er_rev1.add(rev1);
                //v1.2 start
                effRevHistory.put(g.id,rev1);
                //v1.2 end
            
            }
            else if(i==2)
            {   
                system.debug(i+'ivalue2');
                system.debug('inside******2');
                rev2=new EffectivenessReview();
                rev2.Owner=g.Owner.id;
                rev2.show=false;
                rev2.OwnerName=g.Owner.Name;
                rev2.dueDate=g.Due_Date__c;
                rev2.documentStatus=g.Document_status__c;
                rev2.newExpirationDate=g.New_Expiration_Date__c;
                rev2.revDescription=g.Review_description__c;
                if(g.Approval_Required__c=='yes')
              {
                 system.debug('inside******if');
                 rev2.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                 rev2.status=pI.get(string.valueof(g.id)).Status;
                
                 rev2.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                   if(pI.get(string.valueof(g.id)).Status=='Pending')
                  {
                    rev2.show=false;
                    rev2.showMsg=true;
                    rev2.mssage='This review closed due to A draft revision of this document already exist';
                    
                  }
                  else
                  {
                      rev2.show=true;
                      
                  }
              }
              else
              {
              rev2.Approval_Date=date.valueof(g.lastmodifieddate);
              }system.debug(rev2+'rev2******');
                rev2.review=g.Task_Closed_Date__c;
                er_rev2.add(rev2);
                 //v1.2 start
                effRevHistory.put(g.id,rev2);
                //v1.2 end
            
            }
            else if(i!=1 &&i!=2)
            {   system.debug(efMap+'efferevList**********set');
                    
                    
                    
                    system.debug(efferevList+'efferevList**********begin');
                    system.debug(efMap+'efferevList**********set');
                    
                    gtDubCheck.add(string.valueof(g.id));
                    system.debug(gtDubCheck+'efferevList**********setafter adding id'+g.id);
                    system.debug(i+'ivalueelse');
                    EffectivenessReview er=new EffectivenessReview();
                    er.show=false;
                    er.Owner=g.Owner.id;
                    er.OwnerName=g.Owner.Name;
                    er.gtid=g.id;
                    er.dueDate=g.Due_Date__c;
                    er.documentStatus=g.Document_status__c;
                    er.newExpirationDate=g.New_Expiration_Date__c;
                    er.revDescription=g.Review_description__c;
                    //system.debug(PI.get(string.valueof(g.id)).LastActorId+'I.get(string.valueof(g.id)).LastActorId');
                    if(g.Approval_Required__c=='yes')
                    {
                      er.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                      er.status=pI.get(g.id).status;
                        
                      er.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                        if(pI.get(string.valueof(g.id)).Status=='Pending')
                      {
                        er.show=false;
                        er.showMsg=true;
                        er.mssage=' This review closed due to a draft revision of this document already exist.';
                        
                      }
                      else
                      {
                          er.show=true;
                          
                      }      
                         er.review=g.Task_Closed_Date__c;
                    }
                    
                    else
                    {
                    er.Approval_Date=date.valueof(g.lastmodifieddate);
                    }
                    er.gtid=g.id;
                    er.incrementer=i;
                    
                    efferevList.add(er);
                    efMap.put(g.id,er);
                     //v1.2 start
                    effRevHistory.put(g.id,er);
                    //v1.2 end
                    //system.debug(efferevList+'efferevList**********'+efMap);
                    
              }
            
            
         }
         system.debug('efferevList**********mappppppppppp'+efMap);
         system.debug(efferevList+'efferevList**********');
         //return efferevList;
         return efMap;
     }
      @RemoteAction
     public Static string saveCR(string file,string title,string revdesc,id gtCrId)
     {  
         Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId();
         General_Task__c gt=new General_Task__c();
         //string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,Primary_File_Location__c,Collaboration_Title__c,Document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
         gt.Primary_File_Location__c=file;
         gt.Review_Description__c=revdesc;
         gt.Collaboration_Title__c=title;
         gt.document_profile__c=gtCrId;
         gt.Allowed_Days__c=10;
         gt.recordtypeid=recordTypeid;
         gt.status__c='Open';
          insert gt;
          
          return gt.id;
     }
     @RemoteAction
     public Static void updateGentaskCR(id gtask,string file,string title,string revdesc,id gtCrId)
     {  
         Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId();
         General_Task__c gt=new General_Task__c();
      
         string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,Primary_File_Location__c,Collaboration_Title__c,Document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
          if(queryFieldsgt!=null && queryFieldsgt!='')
          {
             gt=database.query(' select ' +queryFieldsgt+' from General_task__c where id=:gtask');
          }
         
         
         gt.Primary_File_Location__c=file;
         gt.Review_Description__c=revdesc;
         gt.Collaboration_Title__c=title;
         gt.document_profile__c=gtCrId;
         gt.Allowed_Days__c=10;
         gt.recordtypeid=recordTypeid;
         update gt;
          
          
     }
     
     @RemoteAction
      public Static string newSubmitCR(string file,string title,string revdesc,id gtCrId)
     {
        
         Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId();
         General_Task__c gt=new General_Task__c();
         //string queryFieldsgt = QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,Primary_File_Location__c,Collaboration_Title__c,Document_status__c,Completed_By__c,Completed_Date__c,Task_Closed_Date__c,Note_To_Approver__c,Status__c');
         gt.Primary_File_Location__c=file;
         gt.Review_Description__c=revdesc;
         gt.Collaboration_Title__c=title;
         gt.document_profile__c=gtCrId;
         gt.Allowed_Days__c=10;
         gt.recordtypeid=recordTypeid;
         gt.Task_Closed_Date__c=System.today();
        
         gt.status__c='Pending Approval';
        
         
          insert gt;
          
          return gt.id;
     
     }
     @RemoteAction
      public Static void SubmitCR(id gtask,string file,string title,string revdesc,id gtCrId)
     {
        
         
         Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId();
         General_Task__c gtcr=new General_Task__c();
         string queryFieldsgt = null;
            queryFieldsgt=QC_DynamicObjectHandler.getAccessibleFields('General_task__c','id,Review_Description__c,Task_Closed_Date__c,Primary_File_Location__c,Collaboration_Title__c,Document_status__c,Completed_By__c,Completed_Date__c,Note_To_Approver__c,Status__c');
          system.debug(queryFieldsgt+'queryFieldsgt');
         if(queryFieldsgt!=null && queryFieldsgt!='')
          {
             gtcr=database.query('select  ' +queryFieldsgt+' from General_task__c where id=:gtask');
          }
         
         
         gtcr.Primary_File_Location__c=file;
         gtcr.Review_Description__c=revdesc;
         gtcr.Collaboration_Title__c=title;
         gtcr.document_profile__c=gtCrId;
         gtcr.Allowed_Days__c=10;
         gtcr.recordtypeid=recordTypeid;
         gtcr.Task_Closed_Date__c=system.today();
          
         gtcr.status__c='Pending Approval';
         
         update gtcr;
     }
      public  class CollaborationReview{
        
          public transient string revDescription{set;get;}
          public transient string Reviewer_Name{set;get;}
          public transient string status{set;get;}
          public transient string primaryfilepath{set;get;}
          public transient string title{set;get;}
          public transient date Approval_Date{set;get;} 
          public transient integer incrementer{set;get;}
          public transient boolean show{get;set;}
          
          public string gtid{set;get;}  
        }
        Public list<General_Task__c> gtDetails_cr=new list<General_Task__c>();
        public list<ProcessInstance> appHistory_cr=new list<ProcessInstance>();
        public list<CollaborationReview> efferevList_cr=new list<CollaborationReview>();
        public CollaborationReview rev1_cr{get;set;}
        public CollaborationReview rev2_cr{get;set;}
    
        ////v1.2 start
        Public Map<Id, CollaborationReview> collRevHistory{get;set;}{
            collRevHistory = new Map<Id,CollaborationReview>();
        }
        ////v1.2 end
        Public Map<Id, CollaborationReview> getAppFinalHistory_cr()
        {  
            Map<Id,CollaborationReview> crMap = new Map<Id,CollaborationReview>();
            string a=docprofid;
            system.debug('aaaaaaaaaa'+a);
            Id recordTypeid = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId();
            gtDetails_cr=[select Owner.id,Approval_Required__c,id,Due_Date__c,Document_Status__c,Task_Closed_Date__c,Primary_File_Location__c,Collaboration_Title__c,New_Expiration_Date__c,Review_Description__c,lastmodifieddate from General_Task__c where document_profile__c=:a  and status__c in('Closed','rejected') and status__c!=null and recordtypeid=:Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('CollaborationReview').getRecordTypeId() and id!=:ApexPages.currentPage().getParameters().get('gtid_cr')];
            system.debug(gtDetails_cr+'gtDetails_cr****');
            appHistory_cr=[SELECT CompletedDate,CreatedById,CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance where TargetObjectId in(select id from General_task__c where document_profile__c=:a and Status__c in('closed','rejected') and recordtypeid=:recordtypeid ) and  status!='removed'];
            list<user> users=[select id,name from user];
            map<id,string> userlist=new map<id,string>();
            for(user u:users)
            {
                userlist.put(u.id,u.Name);
            }
            
            list<ProcessInstance> m = new list<ProcessInstance>([SELECT CompletedDate,CreatedById,CreatedDate,Id,IsDeleted,LastActorId,LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById,SystemModstamp,TargetObjectId FROM ProcessInstance where TargetObjectId in(select id from General_task__c where document_profile__c=:docprofid and Status__c in('closed','rejected') ) and  status!='removed']); 
            Map <string ,ProcessInstance> pI=new Map <string ,ProcessInstance>(); 
            for(ProcessInstance p:m)
            {
            pI.put(p.TargetObjectId,p);
            system.debug(p.TargetObjectId+'direct');
            system.debug(p+'direct');
            system.debug('docprofid***'+docprofid);
            }
          
          integer i=0;
          for(General_Task__c g:gtDetails_cr)
         {
            i++;
            if(i==1)
            {
                rev1_cr=new CollaborationReview();
                rev1_cr.revDescription=g.Review_description__c;
                rev1_cr.title=g.Collaboration_Title__c;
                if(g.Approval_Required__c=='yes')
                    {
                        system.debug('details****'+g.id);
                        rev1_cr.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                        rev1_cr.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                        rev1_cr.status=pI.get(string.valueof(g.id)).Status;
                        rev1_cr.show=false;
                    
                    }
                else
                {
                 rev1_cr.Approval_Date=date.valueof(g.lastmodifieddate);
                }
                rev1_cr.primaryfilepath=g.Primary_File_Location__c;
                rev1_cr.incrementer=i;
                rev1_cr.gtid=g.id;
                //v1.2 start
                collRevHistory.put(g.id,rev1_cr);
                //v1.2 end
                system.debug(rev1_cr+'*************rev1_c');
                      
             }
         else if(i==2)
         {
            rev2_cr=new CollaborationReview();
            rev2_cr.title=g.Collaboration_Title__c;
            rev2_cr.revDescription=g.Review_description__c;
            rev2_cr.primaryfilepath=g.Primary_File_Location__c;
            if(g.Approval_Required__c=='yes')
                    {
                     rev2_cr.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                     rev2_cr.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                     rev2_cr.status=pI.get(string.valueof(g.id)).Status;
                     rev2_cr.show=true;
                    
                    }
                else
                {
                   rev2_cr.Approval_Date=date.valueof(g.lastmodifieddate);
                 }
             rev2_cr.incrementer=i;
             //v1.2 start
                collRevHistory.put(g.id,rev2_cr);
                //v1.2 end
         }
         else{
                   CollaborationReview cr=new CollaborationReview();
                    cr.title=g.Collaboration_Title__c;
                    cr.revDescription=g.Review_description__c;
                    cr.primaryfilepath=g.Primary_File_Location__c;
                    if(g.Approval_Required__c=='yes')
                    {
                        cr.Approval_Date=date.valueof(pI.get(string.valueof(g.id)).CompletedDate);
                        cr.Reviewer_Name=userlist.get(pI.get(string.valueof(g.id)).LastActorId);
                        cr.status=pI.get(string.valueof(g.id)).Status;
                        cr.show=true;
                    
                    }
                else
                {
                 
                cr.Approval_Date=date.valueof(g.lastmodifieddate);
                    
                }
                    
                 cr.incrementer=i;
                 efferevList_cr.add(cr);
                 cr.gtid=g.id;
                 //v1.2 start
                 collRevHistory.put(g.id,cr);
                 //v1.2 end
                 crMap.put(g.id,cr);
                
                 system.debug(crMap+'crMap************');
                    
                    
              
        
         }
         

         }
        return crMap;  
            
             
        }
        
         public Static String getRevisionvalue(String revVal)
{
    Integer[] vals;
    Integer[] revie = new Integer[]{};
    String tmp = revVal;
    vals = tmp.getChars();
    Integer vaslize =vals.size()-1;
    for(integer i=0;i<vals.size();i++){
    System.debug(vals[i]+''+vaslize);
            if(i==vaslize){
            system.debug('Increment');
         
             if(vals[i] == Integer.valueOf('90')){
                revie.add(65);
                revie.add(65); 
             }else{
               revie.add(vals[i]+1);  
             }
            
        }else{
         revie.add(vals[i]);   
        }
}
System.debug('revie'+revie);
 
System.debug(String.fromCharArray(revie));
return String.fromCharArray(revie);
}

    public date Maxdate;
    Public  string er_message;
    Public date getMaxdate(){   
        if(	DocumentProfiles.Pre_Release_Duration_Date__c!=null)
            Maxdate=DocumentProfiles.Pre_Release_Duration_Date__c;
        else{
            Maxdate=DocumentProfiles.Effective_Date__c;
        }
        return Maxdate;
        
    }
    Public string geter_message(){   
        if(	DocumentProfiles.Pre_Release_Duration_Date__c!=null)
            
            er_message='Due date should not be greater than Pre-Release date';
        
        else
        {
            er_message='Due date should not be greater than Effective date';
        }
        return er_message;
        
} 

 public without sharing class documentHistoryExt {
   
   
     //Document Revision History(Start)
     public list<Document_Profile__c> dph(string docname){
      List<Document_Profile__c> documentReviseHistoryList2 = New List<Document_Profile__c>();
     if(docname != null)
        { 
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Status__c,Current_Rev__c,Expiration_Date__c,Effective_Date__c,Enable_Security__c');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            //string docname = documentProfile.Name;
            documentReviseHistoryList2 = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Name =: docname LIMIT 1000');
             }
        }
        else{
            documentReviseHistoryList2 = new List<Document_Profile__c>();
        }
        //Document Revision History
       return documentReviseHistoryList2;
    }
    
}
    //Document Revision History(End)
    
     public List<Manufacturing_Site__c> ImpactedSites{get{  
        system.debug('inside impacted sites');
        Id ProfileId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('inside impacted sites DocProfileId'+ProfileId);        
        Document_Profile__c Dp=[select id,Impacted_Sites__c from Document_Profile__c where id=:ProfileId];
        system.debug('inside impacted sites DocProfileId'+ProfileId);        
        if(Dp.Impacted_Sites__c!=null){         
            system.debug('Dp.Impacted_Sites__cdebug'+Dp.Impacted_Sites__c);
            List<string> ManufacturingSites=string.valueOf(Dp.Impacted_Sites__c).split(',');
            system.debug('inside impacted sites ManufacturingSites'+ManufacturingSites);    
            ImpactedSites=[select id,Name from Manufacturing_Site__c where id IN:ManufacturingSites];   
        }
        return ImpactedSites;
    }set;}
  
}