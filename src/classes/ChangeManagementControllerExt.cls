/*
v1.0        Qualityze Inc(SS)           15-JUNE-2016            Initial Version.
                                                                                This class includes CR init and Doc Info methods belonging to Change Management.
v1.1        Qualityze Inc(ST)       13-AUG-2016     Created methods for cr_details
v1.2        Qualityze Inc(ST)       25-AUG-2016     Doc lists
v1.3        Qualityze Inc(SS)       17-sep-2016     meethod for impacted sites
*/
public with sharing class ChangeManagementControllerExt {

    
    
     //ADHOC TASK------------
    public transient List<General_Task__c> adhocTasks{get; set;}
    public transient General_Task__c addNewadhocTask{get; set;}
    public transient List<String> adhocTaskDetails{get;set;}
    public transient static Boolean isdcTaskPresent{get;set;}
    
    
     //General Task
      public transient General_Task__c dcTask{get;set;}
     public transient String hasdcTask{get;set;}
     public transient List<String> dcTasks {get;set;}
     public transient General_Task__c closTask{get;set;}
     public transient List<General_Task__c> allCRGnrlTasks{get;set;}
    
    
    public Change_Management__c changemanagement{get;set;}
    public String availableImpctedSites{get;set;}
    public transient id cmid;
    public transient List<Sub_Change_Management__c> documentList;
    public transient List<DocumentJunction__c> searchDocs;
    transient String queryDocumentFieldNames,queryDocJunFieldNames;
    public transient String dcOpenTaskSequence{get;set;}
    public transient List<String> types;
    public transient Integer documentListSize{get;set;}
    public transient List<Approver__c> changemanagementApprovers{get;set;}
    public transient String defaultdocumentName{get;set;}
    
    // complete action 
    public transient List<Document_Profile__c> Domncs;        
    public transient List<Sub_Change_Management__c> documents;
    public transient List<Document_Profile__c> docs;
    public transient String queryDocumentprofFieldNames;
	public transient Document_Profile__c docProf{get;set;}
    public Id getcmid(){
        return cmid;
    }
    
    //v1.1 start
    public ChangeManagementControllerExt(){
        
    }
    //v1.1 End
    
    public List<String> getTypes(){
        types = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document_Profile__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> docTypes = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : docTypes){
            if(f.getValue() != 'Expire'){
                types.add(f.getValue());
            }
        }
        return types; 
    }
    
    public List<Sub_Change_Management__c> getDocumentList(){
        queryDocumentFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,Name,Change_Management__c,Change_Management__r.Change_Justification__c,Change_Management__r.Change_Request_Scope__c,Document_Profile__c,Document_Name__c,Document_Profile__r.Name,Document_Profile__r.Document_Name__c,Current_Rev__c,New_Rev__c,Relation__c,Status__c,Type__c,Document_Profile__r.Document_Specific_Changes__c,Document_Profile__r.Action_Status__c,Owner__c,Document_Specific_Changes__c,isPrimary__c,isDocCreated__c');
        if(queryDocumentFieldNames != null && queryDocumentFieldNames != ''){
            documentList = Database.query('SELECT '+queryDocumentFieldNames+' FROM Sub_Change_Management__c WHERE Change_Management__c=:cmid');
        }   
        documentListSize = documentList.size(); 
        System.debug('ChangeManagement documentList-------------------------------------->'+documentList);
        return documentList;
    }
    
     public List<Sub_Change_Management__c> getDocuments(){
        boolean isCreated = false;
        queryDocumentprofFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,Name,Change_Management__c,Change_Management__r.Change_Justification__c,Change_Management__r.Change_Request_Scope__c,Document_Profile__c,Document_Profile_Name__c,Document_Name__c,Document_Profile__r.Name,Document_Profile__r.Document_Name__c,Current_Rev__c,New_Rev__c,Relation__c,Status__c,Type__c,Document_Profile__r.Action_Status__c,isDocCreated__c,Document_Specific_Changes__c,AssignedOwner__c,Owner__c,Document_Profile__r.OwnerId');
        documents = Database.query('SELECT '+queryDocumentprofFieldNames+' FROM Sub_Change_Management__c WHERE Change_Management__c=:cmid AND isDocCreated__c=:isCreated');
        System.debug('ChangeManagement documents are here---------------documents----------------------->'+documents);
        return documents;
    }
    
    public List<Document_Profile__c> getDocs(){
        boolean isCreated = true;
        //queryDocumentJunctionfield = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c', 'DocumentChild__c,DocumentParent__c');
        queryDocumentFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Type__c,Document_Name__c,Name,Status__c,Change_Management__c,Current_Rev__c,Relation__c,New_Rev__c,Document_Specific_Changes__c,Action_Status__c,Title__c,OwnerId,Owner.Name');
        docs = Database.query('SELECT '+queryDocumentFieldNames+' FROM Document_Profile__c WHERE Change_Management__c=:cmid');
        System.debug('ChangeManagement documents are here---------------docs----------------------->'+docs);
        return docs;
    }
    
    public List<Document_Profile__c> getDomncs(){
        boolean isCreated = true;
        queryDocumentprofFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Type__c,Document_Name__c,Name,Status__c,Current_Rev__c,Relation__c,New_Rev__c,Document_Specific_Changes__c,Action_Status__c');
        Domncs = Database.query('SELECT '+queryDocumentprofFieldNames+' FROM Document_Profile__c WHERE Status__c=\'Current\'');
        System.debug('ChangeManagement documents are here---------------docs----------------------->'+Domncs);
        return Domncs;
    }
      
     
     @RemoteAction     
     public Static Document_Profile__c getDocumentProfileName(String documentprofId){
      	  Document_Profile__c documentProfileName;
      	  String documentNames;
      	  String documentNameIfNew;
          if(String.isNotEmpty(documentprofId)){
          	   
          	 system.debug('documentprofId length is here'+ documentprofId.length());
          	if(documentprofId.length() == 15 || documentprofId.length() == 18){
              system.debug('documentprofId is here ' + documentprofId);
              String QueryFieldNamesforDocProf = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name');
               
               if(QueryFieldNamesforDocProf != null && QueryFieldNamesforDocProf != '') {
                  documentProfileName = database.query ('select ' + QueryFieldNamesforDocProf + ' from Document_Profile__c WHERE Id=:documentprofId');
                  system.debug('documentProfileName is coming here'+documentProfileName);
                  documentNames = String.valueOf(documentProfileName);
                  return documentProfileName;
                  system.debug('documentNames is converted or not'+documentNames);
                }
          	  } 
          	  else{
          	  	system.debug('came in else part if new document');
          	  	 documentNameIfNew = documentprofId;
          	    return new Document_Profile__c(Name=documentNameIfNew);
          	    system.debug('documentNameIfNew new document'+documentNameIfNew);
          	  }
          }
        return new Document_Profile__c();
      }
      
    /*   @RemoteAction     
     public Static Document_Profile__c checkForCrStatus(String documentSelected){
         Document_Profile__c dcmntSelcted  = new Document_Profile__c();
            if(String.isNotEmpty(documentSelected)){
             system.debug('documentSelected is here ' + documentSelected);
               
               String QueryFieldNamesDocJunct = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c', 'Id,Name,DocumentChild__c,DocumentParent__c');
               //if(QueryFieldNamesDocProf != null && QueryFieldNamesDocProf != '') {
                 //documentProfName = database.query ('select ' + QueryFieldNamesDocProf + ' from Document_Profile__c WHERE Id=:docprofId');
                //  system.debug('documentProfName is coming here'+documentProfName);
                  
                //}
            }
        
        return dcmntSelcted; 
      }*/ 
       
      
      @RemoteAction     
     public Static Document_Profile__c getDocumentCurrentRevision(String docprofId){
      	  Document_Profile__c documentProfName = new Document_Profile__c();
            if(String.isNotEmpty(docprofId)){
             system.debug('docprofId is here ' + docprofId);
               String QueryFieldNamesDocProf = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Current_Rev__c');
               if(QueryFieldNamesDocProf != null && QueryFieldNamesDocProf != '') {
                 documentProfName = database.query ('select ' + QueryFieldNamesDocProf + ' from Document_Profile__c WHERE Id=:docprofId');
                  system.debug('documentProfName is coming here'+documentProfName);
                  
                }
          }
        
        return documentProfName;
      }
    
    public List<DocumentJunction__c> getSearchDocs(){
        String status = 'Current';
        docProf = new Document_Profile__c();
        SearchDocs = new List<DocumentJunction__c>();
        String docProfIdInChangeMgmt = changemanagement.Document_Number__c;
        String docProftypeInChangeMgmt = changemanagement.Change_Type__c;
        queryDocumentFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Document_Name__c,Name,Status__c,Current_Rev__c,Relation__c,Owner.Name');
        queryDocJunFieldNames = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c', 'Id,DocumentChild__c,DocumentChild__r.Name,DocumentChild__r.Document_Name__c,DocumentParent__r.Name,DocumentParent__r.Document_Name__c,Current_Rev__c,Owner__c,Status__c,DocumentParent__c,RelationWithParent__c,RelationWithChild__c,Child_Revision__c,Child_Status__c,Parent_Status__c,Parent_Owner__c,Child_Owner__c');
        
        if(docProfIdInChangeMgmt != null || docProftypeInChangeMgmt != null){
            if(docProftypeInChangeMgmt != 'New'){
                if(queryDocJunFieldNames != null && queryDocJunFieldNames != ''){
                    searchDocs = Database.query('SELECT '+queryDocJunFieldNames+' FROM DocumentJunction__c WHERE (DocumentParent__c =: docProfIdInChangeMgmt OR DocumentChild__c =: docProfIdInChangeMgmt) AND (Parent_Status__c =:status AND Child_Status__c =:status)');
                    System.debug('SearchDocs------------------------------------>'+SearchDocs);
                }
                if(queryDocumentFieldNames != null && queryDocumentFieldNames != ''){
                    docProf = Database.query('SELECT '+queryDocumentFieldNames+' FROM Document_Profile__c WHERE Id =: docProfIdInChangeMgmt AND Status__c =:status');
                    System.debug('docProf------------------------------------>'+docProf);
                    defaultdocumentName = docProf.Name;
                }
            }else if(docProftypeInChangeMgmt == 'New'){
                defaultdocumentName = changemanagement.Document_Number__c;
            }
        }    
        
        return searchDocs;
    }
    
    // getting the Picklist values of impacted sites and all other fields and realationships on changeManagement object.
      public ChangeManagementControllerExt(ApexPages.StandardController controller) {
        try{
            cmid=controller.getRecord().id;
            system.debug('this is cmid' + cmid);
            this.changemanagementApprovers=new List<Approver__c>();
            /*Schema.DescribeFieldResult fieldResult = Change_Management__c.Impacted_Sites__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            availableImpctedSites='';
            for( Schema.PicklistEntry f : ple){
                availableImpctedSites += f.getValue()+',';
            } 
            system.debug('availableImpctedSites is here' + availableImpctedSites);
            */
            system.debug('cmid is here' + cmid);
            if(cmid!= null) {
                system.debug('cmid is here' + cmid);
                String fieldsToReturn ='';
                
                String namespacePrepend = '';
                if ('' != QC_custom_settings.getPrefix()) {
                    namespacePrepend =(QC_custom_settings.getPrefix()==null)?'': QC_custom_settings.getPrefix()+'__'; 
                }
                
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrepend + 'Change_Management__c').getDescribe().fields.getMap();
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
                    }
                }
                
                fieldsToReturn += ', Owner.Name,Owner.FirstName,Owner.LastName, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
                
                // Build query string
                String selectAllFieldsForChangeManagement = '',recordType = 'DocumentChange';
                String genTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,RecordType.Name,OwnerId'); 
                selectAllFieldsForChangeManagement += 'select ' + fieldsToReturn + ',(select '+genTaskFields+' from General_Tasks__r where RecordType.Name =: recordType) from Change_Management__c where id = \'' + cmid + '\' limit 1';
                system.debug('Query is: ' + selectAllFieldsForChangeManagement);
                changemanagement = database.query(selectAllFieldsForChangeManagement);
            } else {
                changemanagement = new Change_Management__c();
            }
                    
             String changemanagementId=((Change_Management__c)controller.getRecord()).id;
            system.debug(' This is changemanagementId if needed to create new instance' + changemanagementId);
            populateCRTasks(changemanagementId);
            populateCRApproverList(changemanagementId);
            
        } catch(Exception ex){
            System.debug('Exception In  Document    '+ex.getMessage());
        }
        
    }
     
    
     public void populateCRTasks(String changemanagementId){
        try{
            Map<Double,String> crTaskWithSequence= new Map<Double,String>();
            Map<Double,List<General_Task__c>> allTaskWithSequence= new Map<Double,List<General_Task__c>>();
            //String changemanagementId=((Change_Management__c)controller.getRecord()).id;
            adhocTaskDetails=new List<String>();
            List<SObject> sObjects;
            String dcStatus=null;
            Map<String,List<General_Task__c>> allTasks= new Map<String,List<General_Task__c>>();
            
            List<General_Task__c> tmpTaskList;
            System.debug('crTaskController  changemanagementId   '+changemanagementId);
            dcTasks=new List<String>();
            List<General_Task__c> allTaskList;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Allowed_Days__c,Status__c,Due_Date__c,ChangeFieldApprovalStatus__c,New_Owner__r.Name,Note_To_Approver_Owner_DueDate__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c,OwnerId,Owner.Name,Owner__c,OwnerName__c,Owner__r.Name,Change_Management__c,RecordType.Name,Change_Management__r.Status__c,Note_To_Approver__c,CurrentApprovalSequenceNumber__c,Approval_Required__c,AdhocTask_Title__c,New_Due_Date__c,New_Owner__c,Closure_Comment__c');
            system.debug('queryFieldNamess' +queryFieldNames); 
            if(queryFieldNames != null && queryFieldNames != ''){
                system.debug('entered');
                for(General_Task__c genTask :Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Change_Management__c=:changemanagementId ORDER BY Sequence_Position__c')){
                    system.debug('genTaskssss' +genTask); 
                    allTaskList=allTasks.get(genTask.RecordType.Name);
                   if(allTaskList==null){
                       allTaskList=new List<General_Task__c>();
                       allTasks.put(genTask.RecordType.Name,allTaskList);
                       allTaskWithSequence.put(genTask.Sequence_Position__c,allTaskList);
                       system.debug('allTaskWithSequence' +allTaskWithSequence); 
                   }
                   allTaskList.add(genTask);   
                    
                }
                System.debug('crTaskController allTasks    '+allTasks);
                     if(!allTasks.isEmpty()){
                          //DocumentChange
                           tmpTaskList=allTasks.get('DocumentChange');
                           dcTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                           if(dcTask!=null){
                              hasdcTask='Yes';
                               System.debug('hasdcTask'+dcTask);
                              dcOpenTaskSequence=(dcTask.Status__c=='Open')?String.valueOf(dcTask.Sequence_Position__c):dcOpenTaskSequence;
                              crTaskWithSequence.put(dcTask.Sequence_Position__c,dcTask.RecordType.Name+'@'+dcTask.Status__c+'@'+String.valueOf(dcTask.CurrentApprovalSequenceNumber__c)+'@'+dcTask.Approval_Required__c+'@'+dcTask.Id);
                            isdcTaskPresent=false;
                              }else{
                               isdcTaskPresent=true;  
                              }
                           tmpTaskList=allTasks.get('Closure');
                           closTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                           dcStatus=closTask.Change_Management__r.Status__c;
                           crTaskWithSequence.put(closTask.Sequence_Position__c,closTask.RecordType.Name+'@'+closTask.Status__c+'@'+String.valueOf(closTask.CurrentApprovalSequenceNumber__c)+'@'+closTask.Approval_Required__c+'@'+closTask.Id);
                           //Adhoc task  
                           adhocTasks=allTasks.get('AdhocTask');
                            if(adhocTasks!=null){
                                for(General_Task__c adhocTask : adhocTasks){
                                    adhocTaskDetails.add(adhocTask.RecordType.Name+'@'+adhocTask.AdhocTask_Title__c+'@'+adhocTask.Id+'@'+adhocTask.Status__c+'@'+adhocTask.CurrentApprovalSequenceNumber__c+'@'+adhocTask.Approval_Required__c);
                                    dcOpenTaskSequence=(adhocTask.Status__c=='Open')?String.valueOf(adhocTask.Sequence_Position__c):dcOpenTaskSequence;
                                }
                                adhocTasks=adhocTasks.isEmpty()?null:adhocTasks;
                            }
                            addNewadhocTask = new General_Task__c();

                           }
            }
            else{

            }
            if(dcStatus!='In Review' && hasdcTask==null && closTask==null){
                hasdcTask='Yes';
               
            }
            if(dcStatus=='Document Change Order' || dcStatus=='Closed' || dcStatus=='Void'){
                dcTasks=new List<String>();
                if(crTaskWithSequence.size()>0){
                    List<Double> seqList=new List<Double>(crTaskWithSequence.keySet());
                    seqList.sort();
                    for(Double seq : seqList){
                        dcTasks.add(crTaskWithSequence.get(seq));
                    }
                 }
            }
            allCRGnrlTasks = new List<General_Task__c>(); 
            List<Double> allSeqList=new List<Double>(allTaskWithSequence.keySet());
            allSeqList.sort();
            for(Double allseq : allSeqList){
                allCRGnrlTasks.addAll(allTaskWithSequence.get(allseq));
            }
           
        }catch(Exception ex){
            dcTask=null;
            closTask=null;
            System.debug('Exception IN TaskController  '+ex.getMessage());
        }
       
    }
    
    //WRITTEN BY SARATH Starting For Detail
    private void populateCRApproverList(String changemanagementId){
      try{
            DateTime dt;
            Map<Id,List<Approver__c>> approvers=new Map<Id,List<Approver__c>>(); 
            //approverSize=0;
            String queryFieldSOfCRM = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Allowed_Days__c,Status_Updated__c,User__c,User__r.Name,Approver_Name__c,Due_Date__c,Sequence_Position__c,Status__c,Change_Management__c');
            if(queryFieldSOfCRM!= null && queryFieldSOfCRM!= ''){                                                
                List<Approver__c> tempApprovers=null;    
                for(Approver__c approver : Database.query('Select '+ queryFieldSOfCRM +' From Approver__c where Change_Management__c=:changemanagementId')){
                    tempApprovers=approvers.get(approver.Change_Management__c);
                    if(tempApprovers==null){
                        tempApprovers=new List<Approver__c>();
                        approvers.put(approver.Change_Management__c,tempApprovers);
                    }
                    tempApprovers.add(approver);
                    if(approver.Change_Management__c==this.changemanagement.Id){
                        this.changemanagementApprovers.add(approver);
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
                    //for(Id crmId : changemanagementId){
                        userApprovers=new Map<id,Approver__c>();
                        users=new Set<Id>();
                        Secquence=0;
                        maxProcessInstance=0;
                        existingApprovers=approvers.get(changemanagementId);
                        if(existingApprovers!=null){
                            for(Approver__c ap : approvers.get(changemanagementId)){
                                    users.add(ap.User__c);
                                    userApprovers.put(ap.User__c,ap);
                                    userApproversMap.put(ap.Change_Management__c,userApprovers);
                                    usersMap.put(ap.Change_Management__c,users);
                            }
                        }
                    //}
                    List<ProcessInstance> processInstances;
                    ProcessInstances=database.query('Select  '+queryFieldSOfPI +',ProcessDefinition.Name, ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps  ORDER BY CreatedDate asc) FROM ProcessInstance where TargetObjectId =:changemanagementId AND Status!=\'Removed\' ORDER BY CreatedDate DESC');       
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

@RemoteAction
    public static Map<String,Id> createDOCTasks(List<String> adhocTasks,Map<String,List<String>> taskData,String changemanagementId,Boolean isSubmit,boolean isApprovalNeeded,boolean fromHeader){
     


        List<General_Task__c> tasks=new List<General_Task__c>();
        Map<String,General_Task__c> existingTaskMap=new Map<String,General_Task__c>();
        Map<String,General_Task__c> existingTaskWithId=new Map<String,General_Task__c>();
        List<String> data=null;
        General_Task__c task=null;
        Map<String,Id> result=new Map<String,Id>();
        Set<Id> capaGenTaskIds=new Set<Id>();
        try{
            List<General_Task__c> existingTasks=null;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Change_Management__c,Status__c,RecordType.Name, Sequence_Position__c, Allowed_Days__c, Due_Date__c ,Note_To_Approver__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                Set<String> recTypes=taskData.keySet();
                existingTasks=Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Change_Management__c=:changemanagementId');
                
            }
            if(!existingTasks.isEmpty()){
                    for(General_Task__c existingTask : existingTasks){
                        existingTaskMap.put(existingTask.Change_Management__c+'@'+String.valueOf(existingTask.RecordType.Name), existingTask);
                        existingTaskWithId.put(existingTask.Id,existingTask);
                    }
            }
            for(String recordTypeName : taskData.keySet()){
                data = taskData.get(recordTypeName);
                task=existingTaskMap.get(changemanagementId+'@'+recordTypeName);
                task=(task==null)?new General_Task__c():task;
                task.Sequence_Position__c=Integer.valueOf(data[0]);
                task.OwnerId=data[1];
                task.Allowed_Days__c=Integer.valueOf(data[2]);
                task.Due_Date__c=(data[3]==null)?null:Date.parse(data[3]);
                if(task.Change_Management__c==null)
                    task.Change_Management__c=changemanagementId;
                System.debug('Record Type  '+recordTypeName+'     Id  '+Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get(recordTypeName).getRecordTypeId());
                task.RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get(recordTypeName).getRecordTypeId();
                task.Status__c=(isSubmit)?'Created':task.Status__c;
                if(!isApprovalNeeded){
                    task.Approval_Required__c='No';
                    task.Note_To_Approver__c='';
                }
                tasks.add(task);
           } 

           //Add Adhoc Tasks if they are exist
           String[] details;
            if(!adhocTasks.isEmpty()){
                System.debug('inside adtask condition');
                for(String adhocTask : adhocTasks){
                    System.debug('inside adtask loop');
                    details = adhocTask.split('@');
                    System.debug('inside adtask loop details--->'+details);
                    task=(details[5]!='null')?existingTaskWithId.get(details[5]):new General_Task__c();
                    System.debug('inside adtask loop details task--->'+task);
                    task.Adhoc_Sequence__c=details[0];
                    //
                    //task.Sequence__c=details[0];
                    //
                    task.Sequence_Position__c=Integer.valueOf(details[0]);
                    task.OwnerId=details[1];
                    task.Allowed_Days__c=Integer.valueOf(details[2]);
                    task.Due_Date__c = (details[3]==null)?null:Date.parse(details[3]);
                    task.AdhocTask_Title__c = details[4];
                    if(task.Change_Management__c==null)
                         task.Change_Management__c=changemanagementId;
                    task.RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId();
                    task.Status__c=(isSubmit)?'Created':task.Status__c;
                    system.debug('tasks adding----------------------->'+task.Adhoc_Sequence__c+' '+task.Sequence_Position__c+' '+task.Owner__c+' '+ task.Due_Date__c+' '+task.AdhocTask_Title__c+' '+task.Change_Management__c+' '+ task.RecordTypeId+' '+task.Status__c); 
                    tasks.add(task);
                    system.debug('tasks adding----------------------->'+Integer.valueOf(details[0])+' '+details[1]+' '+Integer.valueOf(details[2])+' '+Date.parse(details[3])+' '+details[4]+' '+changemanagementId); 
                   
                }
            }
           if(!tasks.isEmpty()){
                 
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,Change_Management__c,RecordTypeId','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,RecordTypeId','update')){
                     if(isSubmit && !fromHeader){
                        if(tasks.size()==1 || tasks[0].RecordTypeId==Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()){ //Only CLosure Task Is Selected.
                            tasks[0].Status__c='Open';
                        }
                        else{
                           Integer minSeq=1000;
                           Integer actSeq;
                           for(General_Task__c seqChkTask : tasks){
                            //  System.debug('CAPATaskController createCAPATasks seqChkTask.RecordTypeId  '+seqChkTask.RecordTypeId+'   '+(seqChkTask.RecordTypeId!=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()));
                              if(seqChkTask.RecordTypeId!=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()){
                                 actSeq=Integer.valueOf(seqChkTask.Sequence_Position__c);
                                 if(actSeq<minSeq){
                                    minSeq=actSeq; 
                                 }
                              } 
                            }
                            for(General_Task__c seqTask : tasks){
                                if(Integer.valueOf(seqTask.Sequence_Position__c)==minSeq){
                                    seqTask.Status__c='Open';
                                }
                            }
                        }
                    }

                    upsert tasks;
                    
                    for(General_Task__c savedTask : tasks){

                          
                            result.put(Schema.SObjectType.General_Task__c.RecordTypeInfosById.get(savedTask.RecordTypeId).getName(),savedTask.Id);
                    }
                    
                  if(!isApprovalNeeded){
                      String closureTaskId=result.get('Closure');
                      queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,General_Task__c');
                      List<Approver__c> existingApprovers=null;
                      if(queryFieldNames != null && queryFieldNames != ''){
                          existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_Task__c = : closureTaskId');
                          system.debug('existing approvers' +existingApprovers);
                      }
                      else{

                      }
                      if(!existingApprovers.isEmpty()){
                        if(Approver__c.sObjectType.getDescribe().isDeletable()){
                          delete existingApprovers;
                         }
                      }
                  }
                 
            }
            else{

            } 
          }
               if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,Change_Management__c,RecordTypeId','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,RecordTypeId','update')){
                   upsert tasks;
                   
               }
          
        }
        catch(Exception ex){

            result=null;
            
        }

        return result;
        
    }

    
    
    @RemoteAction
    public static List<String> getdocResolutionCodes(){
        List<String> resList=new List<String>();
        try{
             Schema.DescribeFieldResult fieldResult = Change_Management__c.Resolution_Code__c.getDescribe();
             List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
             for( Schema.PicklistEntry f : ple){
                    resList.add(f.getValue());
              }
               
        }
        catch(Exception ex){
          System.debug('Exception In TaskController.getResolutionCodes   '+ex.getMessage());
          resList=new List<String>();
        }
        return resList;
    } 
    
    //Follow Changemanagement
@RemoteAction
public Static Integer followChangemanagement(String chmgid, String userid){
    try{
        System.debug('Changemanagement.followChangemanagement '+ chmgid+' ' +userid);
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Followers__c');
    if(queryFieldNames != null && queryFieldNames != ''){
        List<Change_Management__c> chmg = Database.query('SELECT '+queryFieldNames+' FROM Change_Management__c WHERE Id=:chmgid');
        if(!chmg.isEmpty()){
            
             chmg[0].Followers__c=(chmg[0].Followers__c==null)?userid:(chmg[0].Followers__c+';'+userid);
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Followers__c','update')){
                    update chmg;
                    return 0;
                }else{
                          System.debug('Change_Management__c followChangemanagement  No update access to the fields  '+queryFieldNames);
                       }
        }
    }else{
                    System.debug('Change_Management__c followChangemanagement  No update access to the fields  '+queryFieldNames);
                }       
    
    }catch(Exception ex){
        System.debug(ex);
    }
    
    return -1;
    
}
    
    //UnFolloe Changemanagement
    
       @RemoteAction
    public static Integer unfollowChangemanagement(String chmgid,String userId){
        try{
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Followers__c');
            String newFollowers='';
            String[] existingFollowers;
            if(queryFieldNames != null && queryFieldNames != ''){
                List<Change_Management__c> chmg = Database.query('SELECT '+queryFieldNames+' FROM Change_Management__c WHERE Id=:chmgid');
                if(!chmg.isEmpty()){
                  existingFollowers=chmg[0].Followers__c.split(';');
                  for(String existingFollower : existingFollowers){
                     if(userId.equalsIgnoreCase(existingFollower)){
                        continue;
                     }
                     newFollowers+=existingFollower;
                  }
                  chmg[0].Followers__c=newFollowers;
                  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Followers__c','update')){
                   update chmg;
                   return 0;
                  }
                  else{
                    System.debug('CAPA unfollowChangemanagement  No update access to the fields  '+queryFieldNames);
                  }
                }
            }
            else{
              System.debug('CAPA unfollowChangemanagement  No access to the fields  '+queryFieldNames);
            }
        }
        catch(Exception ex){
            System.debug('Exception In changemanagement.unfollowChangemanagement   '+ex.getMessage());
        }
        return -1;
    }   

    

    // doc info save
    @RemoteAction
    public static Integer saveDocInfo(List<String> deletedRecordIds,Map<String,Map<String,String>> dList,Id changeMgmtId){
        
        // deletion of doc records-------------------
        List<Sub_Change_Management__c> docList = new List<Sub_Change_Management__c>();
        String queryDocumentFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,Name,Change_Management__c,Document_Profile__c,Current_Rev__c,Document_Name__c,New_Rev__c,Relation__c,Status__c,Type__c,Document_Specific_Changes__c,Owner__c');
        if(!deletedRecordIds.isEmpty()){
            docList = Database.query('SELECT '+queryDocumentFieldNames+' FROM Sub_Change_Management__c WHERE Change_Management__c=:changeMgmtId AND Id IN :deletedRecordIds');
            Savepoint sp;
            try{
            	sp = Database.setSavepoint();
                if(!docList.isEmpty()){
                    if(Document_Profile__c.sObjectType.getDescribe().isDeletable()){
                        delete docList;
                    }
                }
            }catch(Exception ex){
                System.debug('Exception In document deletion of ChangeManagement.saveDocInfo  '+ex.getMessage());
                Database.rollback(sp);        
                return -1;
            } 
        }
        //-----------------------------------------
        
        // saving of doc records------------------------
        List<Sub_Change_Management__c> docInfoList = new List<Sub_Change_Management__c>();
        Sub_Change_Management__c doc;
        List<String> docName;
        System.debug('dList.size() '+dList.size());
        try{
        for(integer i=1;i<=dList.size();i++){
            doc = new Sub_Change_Management__c();
            doc.Type__c = dList.get('docInfoTbody'+i).get('Type');
            System.debug('Type__c ----------------------->'+doc.Type__c);
            if(doc.Type__c == 'New'){
                doc.Document_Name__c = dList.get('docInfoTbody'+i).get('Doc');
            }else{
                doc.Document_Profile__c = dList.get('docInfoTbody'+i).get('Doc');
            }
            doc.Change_Management__c = changeMgmtId;
            doc.Relation__c = dList.get('docInfoTbody'+i).get('Relation');
            doc.Document_Specific_Changes__c = dList.get('docInfoTbody'+i).get('SpecChanges');
            doc.Id = dList.get('docInfoTbody'+i).get('Id') != null ? dList.get('docInfoTbody'+i).get('Id') : doc.Id;
            if(dList.get('docInfoTbody'+i).get('isPrimary') != null){
                doc.isPrimary__c = true;
            }
            System.debug('the value of isPrimary ------------------------------>'+dList.get('docInfoTbody'+i).get('isPrimary'));
            docInfoList.add(doc);
        }
        }catch(Exception ex){
            System.debug('Exception changeManagement.saveDocInfo  '+ex.getMessage());
            System.debug('Exception ChangeManagement.saveDocInfo line number  '+ex.getLineNumber());
            return -1;
        }       
        if(!docInfoList.isEmpty()){
            Savepoint sp;
            try{
            	sp = Database.setSavepoint();
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Sub_Change_Management__c','Document_Name__c,Document_Profile__c,Change_Management__c,Type__c,Document_Specific_Changes__c,isPrimary__c','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('Sub_Change_Management__c','Document_Name__c,Document_Profile__c,Change_Management__c,Type__c,Document_Specific_Changes__c,isPrimary__c','update')){
                    upsert docInfoList;
                }
            }catch(Exception ex){
                System.debug('Exception In doc saving of ChangeManagement.saveDocInfo  '+ex.getMessage());
                System.debug('Exception In doc saving of ChangeManagement.saveDocInfo line number  '+ex.getLineNumber());
                Database.rollback(sp);
                return -1;
            }   
        }    
        //----------------------------------------------
        
        return 0;
    }
      /* v1.2  starts here  */
      
 @RemoteAction
   public static List<Document_Profile__c> savedocInfoDocSpecificChanges(String docAutoName,String dcType,String documentId,String chngemngementid,String subChngeMgntId,String subchangeStatus,String subChangecurrRevsn,String subchangeRelation,String DocProfSpecifcChanges,String DocCurrentRevNo,String ownerDocument){
        system.debug('changemanagemnt is here' +chngemngementid);

    List<Document_Profile__c> documentList = new List<Document_Profile__c>();
    
    String queryDocumentFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Change_Management__c,Initiating_Site__c,Business_Unit__c,Impacted_Sites__c,Applicable_Regulations__c,Effective_Date__c,Expire_After__c,Expiration_Date__c,Effectiveness_Review_In_Advance__c,Effectiveness_Review_Date__c,Grace_Period_for_Release__c,PreRelease_Duration_Date__c,Retention_Duration__c,Date_of_Purge__c,Automatically_Expire_Previous_Revision__c,Supersede_Previous_Revision__c,Auto_Expire__c,Collaboration_Review__c,Primary_File_Location__c,Primary_File_Name__c,Secondary_File_Name__c,Document_Type__c,Title__c,Description__c,Department__c,Product__c,Process__c,Type__c,Status__c,Current_Rev__c,New_Rev__c,Relation__c,Action_Status__c,Document_Specific_Changes__c,Owner.Name,Owner.Id');
     
    try{ 
       if(queryDocumentFieldNames != null && queryDocumentFieldNames != ''){
       	          //List<Document_Profile__c> docProfList = new List<Document_Profile__c>();
       	          
                             Document_Profile__c docmnt = new Document_Profile__c();
                             system.debug('updatable------is here-------------------------------'+DocProfSpecifcChanges);
                             
                             docmnt =  Database.query('SELECT '+queryDocumentFieldNames+' FROM Document_Profile__c WHERE Id=:documentId');
                             system.debug('docmnt is here' +docmnt);
                             Document_Profile__c newdocmnt = new Document_Profile__c();
                             newdocmnt = docmnt.clone(false,true,false,false);
                             
                             newdocmnt.Action_Status__c='Completed' ;
                             newdocmnt.Change_Management__c= chngemngementid;
                             newdocmnt.Type__c=dcType;  
                             system.debug('this is the one i nneedede'+dcType);
                             newdocmnt.Status__c='Draft';
                             newdocmnt.Current_Rev__c= subChangecurrRevsn;
                             newdocmnt.New_Rev__c= DocCurrentRevNo;
                             newdocmnt.Relation__c='';
                             newdocmnt.Document_Specific_Changes__c=DocProfSpecifcChanges;
                             newdocmnt.Name= docAutoName;
                             documentList.add(newdocmnt);
                 
        
    
    
         if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Document_Specific_Changes__c,Action_Status__c','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Id,Document_Specific_Changes__c,Action_Status__c','update'))
                         system.debug('updatable----------now comes here---------------------------');
                         upsert  documentList;
                         system.debug('documentList is here'+documentList);
                         Sub_Change_Management__c isDocCreatedFlag;
                         String querySubChangeFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,Current_Rev__c,New_Rev__c,isDocCreated__c');
                         if(querySubChangeFieldNames != null && querySubChangeFieldNames != ''){
                                      system.debug('querySubChangeFieldNames is here'+querySubChangeFieldNames);
                                      isDocCreatedFlag = Database.query('SELECT '+querySubChangeFieldNames+' FROM Sub_Change_Management__c WHERE Id=:subChngeMgntId');
                                      system.debug('isDocCreatedFlag is here'+isDocCreatedFlag);
     
                                      isDocCreatedFlag.isDocCreated__c=true;
                                      isDocCreatedFlag.New_Rev__c=subChangecurrRevsn;
                                    system.debug('isDocCreatedFlag consists of true'+isDocCreatedFlag);
                                     
                                     upsert isDocCreatedFlag;
                         }
                         DocumentJunction__c docJunc= new DocumentJunction__c();
                         String queryJuncObjFieldNames = QC_DynamicObjectHandler.getAccessibleFields('DocumentJunction__c', 'Id,Name,DocumentChild__c,DocumentParent__c,RelationWithParent__c');  
                             if(queryJuncObjFieldNames != null && queryJuncObjFieldNames != ''){
                                system.debug('queryJuncObjFieldNames is here'+queryJuncObjFieldNames);
                                docJunc.DocumentChild__c=documentList[0].Id;
                                docJunc.DocumentParent__c=documentId;
                                if(subchangeRelation != ''){
                                  docJunc.RelationWithParent__c = subchangeRelation;
                                }
                                
                                upsert docJunc;
                          }
       }
   }catch(Exception ex){
          System.debug('Exception In document insertion of ChangeManagement.savedocInfoDocSpecificChanges  '+ex.getMessage());

                    
    }
          system.debug('documentList is here' + documentList);
          return documentList;
    }
    
 
   
     @RemoteAction
 public static Integer updateGeneralTaskstatus(String gtID){
   General_Task__c  gnrltsk = new General_Task__c(); 
   try{     
String queryGeneraltskFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Status__c');
gnrltsk=  Database.query('SELECT '+queryGeneraltskFieldNames+' FROM General_Task__c WHERE Id=:gtID' );
  if(queryGeneraltskFieldNames != null && queryGeneraltskFieldNames != ''){  
                    system.debug('general task fields are here '+queryGeneraltskFieldNames);
                   gnrltsk.Status__c='Closed';
      update gnrltsk;
  }
   }catch(Exception ex){
          System.debug('Exception In generaltask status insertion of ChangeManagementControllerExt.updateGeneralTaskstatus  '+ex.getMessage());

        return -1;            

    }
  return 0;
}


    
    //V1.2 STARTS
    
    public ChangeManagementControllerExt(NonConformance controller){
        
    }
    public List<Change_Management__c> getCMListForDisplay()
    {
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Name,OwnerId,Owner.Name,Change_Request_Type__c,Source__c,Title__c,CreatedDate,CreatedBy.Name,Change_Justification__c,Due_Date__c,Impacted_Sites__c,Business_Unit__c,Initiating_Site__c,Initiating_Site__r.Name,Change_Request_Scope__c,Priority__c,Severity__c');
        System.debug('getCMListForDisplay.CMList  ');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            List<Change_Management__c> cmList = database.query ('select ' + queryFieldNames + ' from Change_Management__c where Status__c != \'Closed\' ORDER BY createddate DESC');
            System.debug('getCMListForDisplay.CMList  '+cmList);
            return cmList;
        }
        else{
            return null;
        }
    }
    //V1.2 END


// v1.3 start

public List<Manufacturing_Site__c> ImpactedSites{get{  
        system.debug('inside impacted sites');
        Id changeManagementId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('inside impacted sites DocProfileId'+changeManagementId);        
        Change_Management__c cM=[select id,Impacted_Sites__c from Change_Management__c where id=:changeManagementId];
        system.debug('inside impacted sites changeManagementId'+changeManagementId);        
        if(cM.Impacted_Sites__c!=null){         
            system.debug('Dp.Impacted_Sites__cdebug'+cM.Impacted_Sites__c);
            List<string> ManufacturingSites=string.valueOf(cM.Impacted_Sites__c).split(',');
            system.debug('inside impacted sites ManufacturingSites'+ManufacturingSites);    
            ImpactedSites=[select id,Name from Manufacturing_Site__c where id IN:ManufacturingSites];   
        }
        return ImpactedSites;
    }set;}
    
  
  
    @RemoteAction
 public static void deleteChangeRequestDocumentNumber(String changeRequestid){
   
	 if(String.isNotEmpty(changeRequestid)){ 
	   Change_Management__c chngemgmt = new Change_Management__c();
	   try{     
	     String queryChangeMangementFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Document_Number__c');
	     chngemgmt=  Database.query('SELECT '+queryChangeMangementFieldNames+' FROM General_Task__c WHERE Id=:changeRequestid' );
	    if(queryChangeMangementFieldNames != null && queryChangeMangementFieldNames != ''){  
	          system.debug('change mangement fields are here '+queryChangeMangementFieldNames);
	          chngemgmt.Document_Number__c ='';
	         if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Document_Number__c','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Document_Number__c','update')){           
	          update chngemgmt;
	          system.debug('change mangement Document Number updated field here '+chngemgmt);
	         }
	       }
	    }catch(Exception ex){
	          System.debug('Exception In changemanagment Document Number updation of ChangeManagementControllerExt.deleteChangeRequestDocumentNumber  '+ex.getMessage());
	
	           }
	        } 
	    
	   }
	   
	   @RemoteAction
	  public static List<Change_Management__c> checkForExistingChangeRequestDocumentNumber(String DocumentProfileId){
	  	
	  	List<Change_Management__c> changemanagemnt = new List<Change_Management__c>();
	     if(String.isNotEmpty(DocumentProfileId)){ 
	        
	           try{
	               String queryCMFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Name,Document_Number__c,Status__c ');
	               if(queryCMFieldNames != null && queryCMFieldNames != ''){
	               	  system.debug('queryCMFieldNames is accessible ');
	                  changemanagemnt=database.query('SELECT '+queryCMFieldNames+' FROM Change_Management__c WHERE Document_Number__c=:DocumentProfileId AND Status__c != \'Closed\' AND Status__c != \'Void\'');
	                  system.debug('changemanagemnt is here @@@@@@'+changemanagemnt);
	                  system.debug('changemanagemnt is here  >>>>>'+changemanagemnt.size()); 
	                   
	                            }
	                        
	              }catch(Exception ex){
	          system.debug('Exception In changemanagment Document Number updation of ChangeManagementControllerExt.deleteChangeRequestDocumentNumber  '+ex.getMessage());
	
	                      }     
	          }
	          return changemanagemnt;
	      }
	
	   
	 //v1.3 end   
}