/*
  v1.0      Qualityze Inc(GP)       06-MAY-2016     Initial Version.
                                                    This class contains all component related code.
                                           
  v1.1      Qualityze Inc(SB)       05-JUL-2016     Created methods for new component(wiz_crApproval).
  v1.1.1    Qualityze Inc(SLVR)     29-JUL-2016     Added Constructor.
  v1.1.2    Qualityze Inc(ST)       02-AUG-2016     Created methods for Document Deactive
  v1.1.3    Qualityze Inc(ST)       09-AUG-2016     Created methods for Void Document Profile
  v1.1.4    Qualityze Inc(ST)       10-AUG-2016     Created methods for Reopen Tasks 
  v1.1.5    Qualityze Inc(ST)       11-AUG-2016     Created methods for ChangeManagement Chronology
  v1.1.6    Qualityze Inc(ST)       13-AUG-2016     Created methods for cr_details
  v1.1.7    Qualityze Inc(GP)       14-AUG-2016     Added Codebase related to checkIn & checkOut functionality
  v1.1.8    Qualityze Inc(ST)       19-AUG-2016     Created methods for Audit for DocumentModule
  v1.1.9    Qualityze Inc(BK)       22-AUG-2016     Created methods for DocumentProfile in DocumentModule
  v1.1.10   Qualityze Inc(ST)       02-sEP-2016     Created methods for Steps(ChangeManagement)
  v1.1.11   Qualityze Inc(ST)       10-sEP-2016     Approval History
  v1.1.12   Qualityze Inc(GP)       16-SEP-2016     Added Codebase For Revise contentDocument
  V1.1.13   Qualityze Inc(PRG)      19-SEP-2016		Created Method for changerequest void
*/
public with sharing class Component_Handler {
    public transient Map<id,User> User{get;set;}
    public transient List<General_Task__c> adhocs{get;set;}
    public transient List<Id> generalTaskIds;
    public transient Id generalTaskId{get;set;}
  // public transient list<Document_Type__c> clorecords{get;set;}
    
    //NC Product Id
    
    public Id ncProductId{get;set;}
    
    //Containment
    public transient General_Task__c containment{get;set;}
    public transient List<General_Sub_Task__c> containmentActions{get;set;}
    public transient List<Approver__c> containmentApprovers{get;set;}
    public transient ProcessInstance containmentChangeProcess{get;set;}
    
    //Disposition
    public transient General_Task__c disposition{get;set;}
    public transient List<General_Sub_Task__c> dispositionSections{get;set;}
    public transient List<Approver__c> dispositionApprovers{get;set;}
    public transient ProcessInstance dispositionChangeProcess{get;set;}
    
    //Investigation
    public transient General_Task__c investigation{get;set;}
    public transient List<General_Sub_Task__c> rootCauses{get;set;}
    public transient List<Approver__c> investigationApprovers{get;set;}
    public transient ProcessInstance investigationChangeProcess{get;set;}
    
    //Implementation
    public transient General_Task__c implementation{get;set;}
    public transient List<General_Sub_Task__c> actionPlans{get;set;}
    public transient List<Approver__c> implementationApprovers{get;set;}
    public transient ProcessInstance implementationChangeProcess{get;set;}
    
    //EffectivenessReview
    public transient General_Task__c effectivenessReview{get;set;}
    public transient List<General_Sub_Task__c> verificationPlans{get;set;}
    public transient List<Approver__c> effectivenessReviewApprovers{get;set;}
    public transient ProcessInstance effectivenessReviewChangeProcess{get;set;}
    
    //Adhoc
    public transient General_Task__c adhoc{get;set;}
    public transient Map<Id,List<General_Sub_Task__c>> adhocActions{get;set;}
    public transient Map<Id,Integer> adhocActionsSize{get;set;}
    public transient Map<Id,Integer> approversSize{get;set;}
    public transient Map<Id,List<Approver__c>> adhocApprovers{get;set;}
    public transient Map<Id,ProcessInstance> adhocChangeProcess{get;set;}
    
    //Closure
    public transient General_Task__c closure{get;set;}
    public transient List<Approver__c> closureApprovers{get;set;}
    public transient ProcessInstance closureChangeProcess{get;set;}
    
    //DocumentChange
    //v1.1.6 start
    public transient General_Task__c documentChange{get;set;}
    public transient List<Approver__c> documentChangeApprovers{get;set;}
    public transient ProcessInstance documentChangeChangeProcess{get;set;}
    //v1.1.6 end
    
    //v1.1.7 start
    
    private transient List<ContentVersion> contentVersionList;
    private transient Id documentTemplateId;
    public transient Document_Profile__c documentProfileRecord{get;set;}
    //v1.1.7 end
    //Document Revise History
    public transient List<Document_Profile__c> documentReviseHistoryList;
    public transient List<Document_Profile__Share> AuthusersList{get;set;}
    //Document Revise History
     //Document Revise/Temp
    public transient List<Document_Profile__c> copyRevision{get;set;}
    public string RevisionField{get;set;}
    public Document_Profile__c documentProfile{get;set;}
     //Document Revise/Temp
    
    public Component_Handler(NonConformance controller){
    }
    
    public Component_Handler(CAPA controller){
    }
    
    //start v1.1.1-------------
    public Component_Handler(ChangeManagementControllerExt controller){
    }
    //end  v1.1.1--------------
    
    public Component_Handler(FileAttachmentController controller){
    }
    
    public Component_Handler(){
        System.debug('Component_Handler documentProfileRecord   '+documentProfileRecord);
    }
    
    //Added By Gaurav
     public Component_Handler(DocumentProfileControllerExt controller){
         
    }
    
    // v1.1.7 start
    
   public List<ContentVersion> getContentVersions(){
        System.debug('Component_Handler.getContentVersion documentProfileRecord  '+documentProfileRecord);
        if(documentProfileRecord!=null && contentVersionList==null){
          String queryFields=QC_DynamicObjectHandler.getAccessibleFields('ContentVersion', 'Id, Title, Description,FileType,ContentDocumentId,Owner.Name,VersionNumber,PathOnClient,FileExtension,CreatedDate');
          String contentDocumentId=documentProfileRecord.ContentDocumentId__c;
          if(queryFields!=null && queryFields!=''){
             contentVersionList= Database.query('SELECT '+queryFields+' FROM ContentVersion WHERE ContentDocumentId=:contentDocumentId ORDER BY CreatedDate DESC');    
          }
        }
        return contentVersionList; 
    }
    
    
    public String getDocTempateId(){
         
         if(documentProfileRecord!=null && documentTemplateId==null){
             String documentProfileId=documentProfileRecord.Id;
             String queryFields=QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id,ParentId');
             String queryFieldsDF=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Document_Type__c');
             if(queryFields!=null && queryFields!='' && queryFieldsDF!=null && queryFieldsDF!=''){
                 List<Attachment> attachments=Database.query('SELECT '+queryFields+' FROM Attachment WHERE ParentId IN (SELECT Document_Type__c FROM Document_Profile__c WHERE Id=:documentProfileId) ORDER BY Id DESC LIMIT 1');
                 if(!attachments.isEmpty()){
                    documentTemplateId=attachments[0].Id;
                 }
             }
        }
        return documentTemplateId;
    }
    
    // v1.1.7  end
    //Document Revision History
   /* public List<Document_Profile__c> getdocumentReviseHistory(){
         
         System.debug('getdocumentReviseHistory=>'+documentProfileRecord);
     if(documentProfileRecord!=null){
        String docName =documentProfileRecord.Name;
        set<Id> dochistoryIds = new set<Id>();
        //List<Id> docAuthId = new List<Id>();
        if(docName != null)
        {
            
        String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Status__c,Current_Rev__c,Expiration_Date__c,Effective_Date__c');
        if(queryFieldNames1 != null && queryFieldNames1 != '')
        {
            documentReviseHistoryList = database.query ('select ' + queryFieldNames1 + ' from Document_Profile__c Where Name =: docName  LIMIT 1000');
            for(Document_Profile__c dc : documentReviseHistoryList){
              dochistoryIds.add(dc.Id);   
            } 
            
            System.debug('dochistoryIds->'+dochistoryIds);
           
        }
            }
        
        else{
            documentReviseHistoryList = new List<Document_Profile__c>();
        }
        if(dochistoryIds != null)
        {
            
        String queryFieldNames2 = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__Share', 'Id,ParentId,UserOrGroupId');
        if(queryFieldNames2 != null && queryFieldNames2 != '')
        {
            AuthusersList = database.query ('select ' + queryFieldNames2 + ' from Document_Profile__Share Where ParentId IN : dochistoryIds');
            
            
            System.debug('AuthusersList->'+AuthusersList);
           // System.debug('AuthusersList->'+docAuthId);
           
        }
            }
        
        else{
            AuthusersList = new List<Document_Profile__Share>();
        }
     }
        return documentReviseHistoryList;
    }*/
    //Document Revision History
    
     //v1.1.12 start
    
   public static Map<String,List<String>> reviseContentDocument(Set<String> contentVersionIds){
   	 Map<String,List<String>> revisedContentVersionIdMap=new Map<String,List<String>>();
   	 try{
   	 	String queryFieldsContentVersion= QC_DynamicObjectHandler.getAccessibleFields('ContentVersion', 'Id,VersionData,Title,pathOnClient,ContentDocumentId');
   	 	Map<Id,ContentVersion> revisedContentVersions=new Map<Id,ContentVersion>();
   	 	Set<Id> revisedContentVersionIdSet=new Set<Id>();
   	 	ContentVersion contentVersion=null;
   	 	
   	 	List<String> revisedContentVersionList=null;
   	 	if(queryFieldsContentVersion != null && queryFieldsContentVersion != ''){
   	 		for(ContentVersion cntVersion : Database.query('SELECT '+queryFieldsContentVersion+' FROM ContentVersion WHERE Id IN :contentVersionIds LIMIT 999')){
   	 			 System.debug(' Component_Handler.reviseDocumentContent cntVersion '+cntVersion);
   	 			 contentVersion=new ContentVersion();
   	 			 contentVersion.Title=cntVersion.Title;
   	 			 contentVersion.pathOnClient=cntVersion.pathOnClient;
   	 			 contentVersion.VersionData=cntVersion.VersionData;
   	 			 revisedContentVersions.put(cntVersion.Id,contentVersion);
   	 	    }
   	 	    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('ContentVersion','VersionData,Title,pathOnClient','create')){
   	 	    	System.debug(' Component_Handler.reviseDocumentContent insert revisedContentVersions ');
   	 	    	insert revisedContentVersions.values();
   	 	    }
   	 	
   	 	String revisedcontentVersionId=null;
   	 	for(String currentContentVersionId : revisedContentVersions.keySet()){
   	        revisedcontentVersionId=revisedContentVersions.get(currentContentVersionId).Id;
   	        revisedContentVersionIdSet.add(revisedcontentVersionId);
   	        revisedContentVersionList=new List<String>();
   	        revisedContentVersionList.add(revisedcontentVersionId);
   	        revisedContentVersionIdMap.put(currentContentVersionId,revisedContentVersionList);    
   	 	}
   	 	if(!revisedContentVersionList.isEmpty()){
	   	 	for(ContentVersion cntVersion : Database.query('SELECT '+queryFieldsContentVersion+' FROM ContentVersion WHERE Id IN :revisedContentVersionIdSet LIMIT 999')){
	   	 		   for(List<String> cvList :revisedContentVersionIdMap.values()){
	   	 		   	  if(new Set<String>(cvList).contains(cntVersion.Id)){
	   	 		   	  	  cvList.add(cntVersion.ContentDocumentId);
	   	 		   	  }
	   	 		    }
	   	    }
   	 	}
        }
   	 	System.debug('Component_Handler  reviseDocumentContent  revisedContentVersionIdMap '+revisedContentVersionIdMap);
   	 }
   	 catch(Exception ex){
   	 	System.debug('Exception In Component_Handler.reviseDocumentContent   '+ex.getMessage());
   	 }
   	 return revisedContentVersionIdMap;
   }
   
   //v1.1.12 end
   
   //Begin : wiz_task_details 
    public Integer getTaskData(){
        try{
            this.generalTaskIds=new List<Id>();
            
            //Containment
            this.containmentActions=new List<General_Sub_Task__c>();
            this.containmentApprovers=new List<Approver__c>();
            //this.containmentChangeProcess=new ProcessInstance();
            
            //Disposition
            this.dispositionSections=new List<General_Sub_Task__c>();
            this.dispositionApprovers=new List<Approver__c>();
            //this.dispositionChangeProcess=new ProcessInstance();
            
            //Investigation
            this.rootCauses=new List<General_Sub_Task__c>();
            this.investigationApprovers=new List<Approver__c>();
            //this.investigationChangeProcess=new ProcessInstance();
            
            //Implementation
            this.actionPlans=new List<General_Sub_Task__c>();
            this.implementationApprovers=new List<Approver__c>();
            //this.implementationChangeProcess=new ProcessInstance();
            
            //EffectivenessReview
            this.verificationPlans=new List<General_Sub_Task__c>();
            this.effectivenessReviewApprovers=new List<Approver__c>();
            
            //Adhoc
            this.adhocActions =new Map<Id,List<General_Sub_Task__c>>();
            this.adhocActionsSize=new Map<Id,Integer>();
            this.approversSize=new Map<Id,Integer>();
            this.adhocApprovers=new Map<Id,List<Approver__c>>();
            this.adhocChangeProcess=new Map<Id,ProcessInstance>();
            
            //Closure
            this.closureApprovers=new List<Approver__c>();
            //this.closureChangeProcess=new ProcessInstance();
            
            // v1.1.6 start DocumentChange
            this.documentChangeApprovers=new List<Approver__c>();
            // v1.1.6 end
            
            if(this.containment!=null){
                this.generalTaskIds.add(this.containment.Id);
            }
            
            if(this.disposition!=null){
                this.generalTaskIds.add(this.disposition.Id);
            }
            
            if(this.investigation!=null){
                this.generalTaskIds.add(this.investigation.Id);
            }
            
            if(this.implementation!=null){
                this.generalTaskIds.add(this.implementation.Id);
            }
            
            if(this.effectivenessReview!=null){
                this.generalTaskIds.add(this.effectivenessReview.Id);
            }
            
            if(this.adhocs!=null){
                for(General_Task__c adhocTask : this.adhocs){
                    this.generalTaskIds.add(adhocTask.Id);
                    this.adhocActions.put(adhocTask.Id,new List<General_Sub_Task__c>());
                    this.adhocApprovers.put(adhocTask.Id,new List<Approver__c>());
                    this.adhocChangeProcess.put(adhocTask.Id,new ProcessInstance());
                }
            }
            
            if(this.closure!=null){
                this.generalTaskIds.add(this.closure.Id);
            }
            
            //v1.1.6 start
            if(this.documentChange!=null){
                this.generalTaskIds.add(this.documentChange.Id);
            }
            //v1.1.6 end
            
            populateSubTasks();
            populateApproverList();
            populateChangeProcess();
            
            System.debug('Component_Handler.getTaskData  this.containmentChangeProcess    '+this.containmentChangeProcess);
            System.debug('Component_Handler.getTaskData  this.dispositionChangeProcess    '+this.dispositionChangeProcess);
            System.debug('Component_Handler.getTaskData  this.investigationChangeProcess  '+this.investigationChangeProcess);
            System.debug('Component_Handler.getTaskData  this.implementationChangeProcess '+this.implementationChangeProcess);
            System.debug('Component_Handler.getTaskData  this.adhocChangeProcess     '+this.adhocChangeProcess);
            System.debug('Component_Handler.getTaskData  this.closureChangeProcess    '+this.closureChangeProcess);
                   
            return 0;
        }   
        catch(Exception ex){
            System.debug('Exception In Component_Handler.getTaskData    '+ex.getMessage());
            return -1;
        }
    }
 
    private void populateSubTasks(){
        try{
           String queryFields=QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Completed_By__r.Name,Completed_By__c,Completed_Date__c,Sub_Task_Detail__c,Disposition_Type__c,Assigned_User__c,Assign_User__c,Assigned_User__r.Name,Disposition_Instruction__c,Complete__c,Completion_Comment__c,Completion_Comments__c,Assigned_Disposition_Qty__c,Due_Date__c,Disposition_Type_Status__c,Title__c,Action_Plan_Status__c,Associated_Root_Cause_Name__c,Statement__c,Description__c,Type__c,Associated_Root_Causes__c,Completed__c,Against__c,Cause_Code__r.Name,Cause_Code_Description__c,Defect__r.Name,Defect_Description__c,General_Task__c,General_Task__r.Name,Process__r.Name,Product__r.Name,Plan_Statement__c,RecordType.Name ');
           String queryFieldSOfNCAPRCS = QC_DynamicObjectHandler.getAccessibleFields('Action_Plan_Root_Cause__c','Id,Task_Root_Cause__c,Task_Root_Cause__r.Name,Task_Root_Cause__r.Cause_Code_Name__c');
           String queryFieldSOfNCDP = QC_DynamicObjectHandler.getAccessibleFields('Disposition_Product__c', 'Id,Pending_Quantity__c,Defect_Quantity__c,NC_ProductId__c,NC_Product__c,General_Sub_Task__c,Dispose_Quantity__c,Product_Batch__c');
           
           if(queryFields!=null && queryFields!='' && queryFieldSOfNCAPRCS!=null && queryFieldSOfNCAPRCS!='' && queryFieldSOfNCDP!=null && queryFieldSOfNCDP!=''){
               for(General_Sub_Task__c generalSubTask : Database.query('SELECT '+ queryFields +',(SELECT ' + queryFieldSOfNCDP + ' FROM Disposition_Products__r LIMIT 999),(SELECT ' + queryFieldSOfNCAPRCS + ' from Action_Plans_Root_Causes__r LIMIT 999) FROM General_Sub_Task__c where General_Task__c IN :generalTaskIds LIMIT 999')){
                   if(generalSubTask.RecordType.Name=='Containment Actions' && generalSubTask.General_Task__c==this.containment.Id){
                       System.debug('Component_Handler.populateSubTasks Containment Action    '+generalSubTask+'  General Task  '+generalSubTask.General_Task__r.Name+'  Record Type  '+generalSubTask.RecordType.Name);
                       this.containmentActions.add(generalSubTask);
                   }
                   else if(generalSubTask.RecordType.Name=='Disposition Section'){
                       this.dispositionSections.add(generalSubTask);
                   }
                   else if(generalSubTask.RecordType.Name=='Root Cause'){
                       this.rootCauses.add(generalSubTask);
                   }
                   else if(generalSubTask.RecordType.Name=='Action Plan'){
                       this.actionPlans.add(generalSubTask);
                   }
                   else if(generalSubTask.RecordType.Name=='Verification Plans'){
                       this.verificationPlans.add(generalSubTask);
                   }
                   else if(generalSubTask.RecordType.Name=='AdhocTask Actions'){
                       this.adhocActions.get(generalSubTask.General_Task__c).add(generalSubTask);
                   }
                   
                   
               }
           }
 
        }
        catch(Exception ex){
            System.debug('Exception In Component_Handler.populateSubTasks    '+ex.getMessage());
        }
    }
    
    private void populateApproverList(){
      try{
            DateTime dt;
            Map<Id,List<Approver__c>> approvers=new Map<Id,List<Approver__c>>(); 
            //approverSize=0;
            String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Allowed_Days__c,Status_Updated__c,User__c,User__r.Name,Approver_Name__c,Due_Date__c,Sequence_Position__c,Status__c,General_Task__c,General_Task__r.RecordType.Name');
            if(queryFieldSOfNCC!= null && queryFieldSOfNCC!= ''){                                                
                List<Approver__c> tempApprovers=null;    
                for(Approver__c approver : Database.query('Select '+ queryFieldSOfNCC +' From Approver__c where General_Task__c IN :generalTaskIds order By Sequence_Position__c')){
                    tempApprovers=approvers.get(approver.General_Task__c);
                    if(tempApprovers==null){
                        tempApprovers=new List<Approver__c>();
                        approvers.put(approver.General_Task__c,tempApprovers);
                    }
                    tempApprovers.add(approver);
                    if(approver.General_Task__r.RecordType.Name=='Containment' && approver.General_Task__c==this.containment.Id){
                        this.containmentApprovers.add(approver);
                    }
                    else if(approver.General_Task__r.RecordType.Name=='Disposition' && approver.General_Task__c==this.disposition.Id){
                        this.dispositionApprovers.add(approver);
                    }
                    else if(approver.General_Task__r.RecordType.Name=='Investigation' && approver.General_Task__c==this.investigation.Id){
                        this.investigationApprovers.add(approver);
                    }
                    else if(approver.General_Task__r.RecordType.Name=='Implementation' && approver.General_Task__c==this.implementation.Id){
                        this.implementationApprovers.add(approver);
                    }
                    else if(approver.General_Task__r.RecordType.Name=='EffectivenessReview' && approver.General_Task__c==this.effectivenessReview.Id){
                        this.effectivenessReviewApprovers.add(approver);
                    }
                    else if(approver.General_Task__r.RecordType.Name=='AdhocTask'){
                       this.adhocApprovers.get(approver.General_Task__c).add(approver);    
                    }
                    else if(approver.General_Task__r.RecordType.Name=='Closure' && approver.General_Task__c==this.closure.Id){
                       this.closureApprovers.add(approver);    
                    }
                    //v1.1.6 start
                    else if(approver.General_Task__r.RecordType.Name=='DocumentChange' && approver.General_Task__c==this.documentChange.Id){
                       this.documentChangeApprovers.add(approver);    
                    }
                    //v1.1.6 end
                    
                    
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
                    for(Id gtId : generalTaskIds){
                        userApprovers=new Map<id,Approver__c>();
                        users=new Set<Id>();
                        Secquence=0;
                        maxProcessInstance=0;
                        existingApprovers=approvers.get(gtId);
                        if(existingApprovers!=null){
                            for(Approver__c ap : approvers.get(gtId)){
                                    users.add(ap.User__c);
                                    userApprovers.put(ap.User__c,ap);
                                    userApproversMap.put(ap.General_Task__c,userApprovers);
                                    usersMap.put(ap.General_Task__c,users);
                            }
                        }
                    }
                    List<ProcessInstance> processInstances;
                    String chgTaskOwner='Change Task Owner';
                    String chgDueDate='Change Due Date';
                    ProcessInstances=database.query('Select  '+queryFieldSOfPI +',ProcessDefinition.Name, ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps  ORDER BY CreatedDate asc) FROM ProcessInstance where TargetObjectId IN :generalTaskIds AND Status!=\'Removed\' ORDER BY CreatedDate DESC');       
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
  private void  populateChangeProcess(){
      try{
        Set<id> userids=new Set<id>();
        Set<Id> adhocIds=new Set<Id>();
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,OriginalActorId,CreatedDate ,actorid');
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,ElapsedTimeInDays,TargetObjectid,SubmittedById,CompletedDate, CreatedById,CreatedDate ,Status,');
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id,ElapsedTimeInDays,OriginalActorid,CreatedDate, StepStatus, Comments,Actorid');  
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            List<ProcessInstance> processInstances;
            String chgTaskOwner='Change Task Owner';
            String chgDueDate='Change Due Date';            
            ProcessInstances=database.query('Select  '+queryFieldSOfPI +',ProcessDefinition.Name,( Select '+ queryFieldSOfPW +' from Workitems order by  createdDate  ASC ),( Select '+ queryFieldSOfPs +' from Steps order by  createdDate ASC) FROM ProcessInstance where TargetObjectId IN :generalTaskIds  Order by createdDate Desc'); 
            System.debug('Component_Handler.populateChangeProcess   processInstances  '+processInstances);      
            for(ProcessInstance Pi:ProcessInstances){
             if(pi.ProcessDefinition.Name =='Change Task Owner' || pi.ProcessDefinition.Name=='Change Due Date'){   
                userids.add(Pi.SubmittedById);
                for(ProcessInstanceStep ps:Pi.Steps){
                    userids.add(ps.OriginalActorid);
                }
                for(ProcessInstanceWorkitem pw:Pi.Workitems){
                    userids.add(pw.OriginalActorid);
                }
                if(this.containment!=null && this.containment.Id==pi.TargetObjectId && this.containmentChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess Containment ');
                        this.containmentChangeProcess=pi;
                }
                else if(this.disposition!=null && this.disposition.Id==pi.TargetObjectId && this.dispositionChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess Disposition ');
                        this.dispositionChangeProcess=pi;
                }
                else if(this.investigation!=null && this.investigation.Id==pi.TargetObjectId && this.investigationChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess Investigation ');
                        this.investigationChangeProcess=pi;
                }
                else if(this.implementation!=null && this.implementation.Id==pi.TargetObjectId && this.implementationChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess Implementation ');
                        this.implementationChangeProcess=pi;
                }
                else if(this.effectivenessReview!=null && this.effectivenessReview.Id==pi.TargetObjectId && this.effectivenessReviewChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess EffectivenessReview ');
                        this.effectivenessReviewChangeProcess=pi;
                }
                else if(this.closure!=null && this.closure.Id==pi.TargetObjectId && this.closureChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess Closure ');
                        this.closureChangeProcess=pi;
                }
                //v1.1.6 start
                else if(this.documentChange!=null && this.documentChange.Id==pi.TargetObjectId && this.documentChangeChangeProcess==null){
                        System.debug('Component_Handler.populateChangeProcess documentChange ');
                        this.documentChangeChangeProcess=pi;
                } 
                //v1.1.6 end
                else{
                       if(!adhocIds.contains(pi.TargetObjectId)){
                            System.debug('Component_Handler.populateChangeProcess Adhoc ');
                            this.adhocChangeProcess.put(pi.TargetObjectId,pi);
                            adhocIds.add(pi.TargetObjectId);
                       }
                }
                
             }
            }
            
            User=new Map<id,User>();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'id,Name');            
            if(queryFieldNames != null && queryFieldNames != ''){
                String qry='select ' + queryFieldNames + ' FROM User where id in:userids';
                LIST<User> ulist=database.query (qry);
                User.putAll(ulist);                
            }
            
            
           
        }
      
      }catch(Exception ex){
          System.debug('Exception In Component_Handler.populateChangeProcess  '+ex.getMessage());
      }
                
    
    
 
  }
  
  //End : wiz_task_details
  
  
  //Begin : wiz_added_product
  public NC_Product__c getNCP(){
      try{
           NonConformance nc =new NonConformance();
           nc.ncpId=this.ncProductId;
           return nc.getNCP();
      }catch(Exception ex){
          System.debug('Exception In Component_Handler.getNCP  '+ex.getMessage());
          return null;
      }
 }
 
 public List<Product_Lot_Numbers__c> getLots(){
        try{
           NonConformance nc =new NonCOnformance();
           nc.ncpId=this.ncProductId;
           return nc.getLots();
        }catch(Exception ex){
          System.debug('Exception In Component_Handler.getLots  '+ex.getMessage());
          return null;
        }
  
 }
 //End :wiz_added_product
 
 //Begin : wiz_add_containment_action  and  wiz_added_containment_action
 public Integer getContainmentActionData(){
    try{
        if(this.generalTaskId!=null){
         String gTaskId=this.generalTaskId;
         String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,CreatedDate ,Completed_By__r.Name,Completed_By__c,Completed_Date__c,Sub_Task_Detail__c');
         if(queryFieldSOfNCC !=null && queryFieldSOfNCC != ''){
            this.containmentActions = database.query('select '+queryFieldSOfNCC+' from General_Sub_Task__c where General_Task__c =:gTaskId');
         }    
        }
        System.debug(' Component_Handler.getActionPlanData this.containmentActions  '+this.containmentActions);
        return 0;
    }
    catch(Exception ex){
         System.debug('Exception In Component_Handler.getContainmentActionData  '+ex.getMessage());
          return -1;
    }
 }
 
 public void  loadContainmentActions(){
        System.debug(' Component_Handler.loadContainmentActions this.generalTaskId  '+this.generalTaskId);
        try{
            if(this.generalTaskId!=null){
             String gTaskId=this.generalTaskId;
             String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Completed_By__r.Name,Completed_By__c,Completed_Date__c,Sub_Task_Detail__c');
             if(queryFieldSOfNCC !=null && queryFieldSOfNCC != ''){
                this.containmentActions = database.query('select '+queryFieldSOfNCC+' from General_Sub_Task__c where General_Task__c =:gTaskId');
             }    
        }
        System.debug(' Component_Handler.loadContainmentActions this.containmentActions  '+this.containmentActions);
        
    }
    catch(Exception ex){
         System.debug('Exception In Component_Handler.loadContainmentActions  '+ex.getMessage());
         
    }
       
}

public Integer getContainmentActionsSize(){
    if(this.containmentActions==null)
      return 0;
    return this.containmentActions.size();
}






@RemoteAction
public static boolean deleteContainmentAction(string id){
    Savepoint sp;   
    try{
        sp = Database.setSavepoint();
        String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id');
        if(queryFieldSOfNCC!= null && queryFieldSOfNCC!= ''){
              List<General_Sub_Task__c> CAS = database.query('Select '+ queryFieldSOfNCC +' From  General_Sub_Task__c where id = :id');
              if(CAS.size() > 0){
                if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                    delete CAS;
                }
              }
        }
        return true;
    }
    catch(exception ex){
      Database.rollback(sp);
      System.debug('Exception In Component_Handler.deleteContainmentAction  '+ex.getMessage());        
      return false;
    } 
  }
 
@RemoteAction
public static General_Sub_Task__c getContainmentAction(String containmentActionId){
  try{
      if(containmentActionId != null ){
         String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Completed_By__r.Name,Completed_By__c,Completed_Date__c,Sub_Task_Detail__c');
         if(queryFieldSOfNCC!= null && queryFieldSOfNCC!= ''){
            return database.query('Select '+ queryFieldSOfNCC +' From General_Sub_Task__c where id=:containmentActionId');
         }
      }
  }catch(Exception ex){
     System.debug('Exception In Component_Handler.getContainmentAction  '+ex.getMessage());
  }
  return new General_Sub_Task__c();
}

//End : wiz_add_containment_action  and  wiz_added_containment_action

//Begin :wiz_add_actionplan,wiz_capa_add_actionplan
 
 public Integer getActionPlanData(){
    try{
        if(implementation!=null){
         String gTaskId=implementation.Id;
         String queryFieldNamesapSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Title__c,CreatedDate,Statement__c,Description__c,Associated_Root_Cause_Name__c,Action_Plan_Status__c,Type__c,Assigned_User__r.Name,Due_Date__c,Associated_Root_Causes__c,Complete__c,Completed__c,Completed_By__r.Name,Completed_Date__c,Completion_Comments__c,General_Task__c,RecordType.DeveloperName ');
         if(queryFieldNamesapSec !=null && queryFieldNamesapSec != ''){
            this.actionPlans = database.query('select '+queryFieldNamesapSec+' from General_Sub_Task__c where General_Task__c =:gTaskId AND RecordType.DeveloperName=\'Action_Plan\'');
         }    
        }
        System.debug(' Component_Handler.getActionPlanData this.actionPlans  '+this.actionPlans);
        return 0;
    }
    catch(Exception ex){
         System.debug('Exception In Component_Handler.getActionPlanData  '+ex.getMessage());
          return -1;
    }
 }
 
 @RemoteAction
    public static Map<String,List<String>> getActionPlanUserData(String roleGroup){
       
       try{ 
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        List<String> data =new List<String>();
        List<User> users;
        String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id,Name');
        
         //---code added for showing 'assigned to' field user values based on NC task groups
        Boolean active = true;
        String role = (roleGroup==null)?'NC_Task_Owner':roleGroup;
        string queryfieldNamesGroups=QC_DynamicObjectHandler.getAccessibleFields('group','id,DeveloperName');
        Set<id> actionPlanGroupid=new set<id>(); 
        
       if(queryfieldNamesGroups!=null && queryfieldNamesGroups!='') {
           
        group groupid2=Database.query(' select ' + queryfieldNamesGroups + ' from group where DeveloperName =:role ') ;
        set<id> UserSetid1=new set<id>();
        UserSetid1.add(groupid2.id);
        vfsearch.FinaluserIDSet=new set<id>();
        vfsearch.getUserIds(UserSetid1);  
        actionPlanGroupid.addAll(vfsearch.FinaluserIDSet);      
        } 
        
         if(queryFieldNamesUsers !=null && queryFieldNamesUsers != ''){       
          users=Database.query('SELECT ' +queryFieldNamesUsers+ ' FROM User WHERE id IN:actionPlanGroupid ORDER BY Id limit 100');
         
        }    
       
        data =new List<String>();
        for(User user : users){
            data.add(user.Id+'@'+user.Name);
        }
        dataMap.put('usrs',data);
                    
        return dataMap;
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.getActionPlanUserData  '+ex.getMessage());
          return null;
       }
    }
    
    @RemoteAction
    public static List<String> getAuthorizedUsers(String roleGroup){
      try{
        List<String> data;
        List<User> users=new List<User>();
        String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id,Name');
        //---------------------------------------------------------------------------added/changed on 3oth Nov
        //---code added for showing 'assigned to' field user values based on NC task groups
        Boolean active = true;
        String role = (roleGroup==null)?'NC_Task_Owner':roleGroup;
        string queryfieldNamesGroups=QC_DynamicObjectHandler.getAccessibleFields('group','id,DeveloperName');
        Set<id> dispositiongroupid=new set<id>(); 
        
        if(queryfieldNamesGroups!=null && queryfieldNamesGroups!='') {
           
        group groupid2=Database.query(' select ' + queryfieldNamesGroups + ' from group where DeveloperName =:role ') ;
        set<id> UserSetid1=new set<id>();
        UserSetid1.add(groupid2.id);
        vfsearch.FinaluserIDSet=new set<id>();
        vfsearch.getUserIds(UserSetid1);  
        dispositiongroupid.addAll(vfsearch.FinaluserIDSet);      
        } 
        
         if(queryFieldNamesUsers !=null && queryFieldNamesUsers != ''){       
          users=Database.query('SELECT ' +queryFieldNamesUsers+ ' FROM User WHERE id IN:dispositiongroupid ORDER BY Id limit 100');
         
        }   
        data =new List<String>();
        for(User user : users){
            data.add(user.Id+'@'+user.Name);
        }
        
        return data;
      }
      catch(Exception ex){
         System.debug('Exception In Component_Handler.getAuthorizedUsers  '+ex.getMessage());
          return null;
      }
    }
    
    @RemoteAction
    public static List<String> displayAssocRootCauses(Id rcid,String module){
     try{
        String invest = 'Investigation'; 
        module=module==null?'NC':module;
        String General_Task_fieldList = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordTypeID,RecordType.Name');
        List<String> ids = new List<String>();
        if(General_Task_fieldList != null && General_Task_fieldList != '')
        {  
            General_Task__c gts = (module=='NC')?database.query('select ' + General_Task_fieldList + ' from General_Task__c where Non_Conformance__c =: rcid and RecordType.Name =: invest Limit 1'):database.query('select ' + General_Task_fieldList + ' from General_Task__c where CAPA__c =: rcid and RecordType.Name =: invest Limit 1');
            string Root_Cause_fieldList = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Cause_Code_Name__c');
            if(Root_Cause_fieldList != null && Root_Cause_fieldList != '') 
            {
                id gt = gts.id;
                for(General_Sub_Task__c rcs : database.query('select ' + Root_Cause_fieldList + ' from General_Sub_Task__c where General_Task__c =:gt')){
                    system.debug('Root_Cause_fieldList'+Root_Cause_fieldList+'rcs'+rcs);
                    ids.add(rcs.id+'@'+rcs.Cause_Code_Name__c);
                }
            }
            system.debug('ids'+ids); 
        }
        return ids;
     }
     catch(Exception ex){
         System.debug('Exception In Component_Handler.displayAssocRootCauses  '+ex.getMessage());
         return null;
      }   
    }
    
    
    @RemoteAction
  public static boolean deleteActionPlan(string id){
       Savepoint sp;
       try{
            sp = Database.setSavepoint(); 
            List<General_Sub_Task__c> APS;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Title__c'); 
            System.debug('queryFieldNames'+queryFieldNames);
            if(queryFieldNames != null && queryFieldNames != '')
            {
                APS = database.query('Select '+ queryFieldNames +' from General_Sub_Task__c where id = :id');
                if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                        delete APS; 
                }
            }
            return true;
      }catch(exception ex){
          Database.rollback(sp);
          System.debug('Exception In Component_Handler.deleteActionPlan  '+ex.getMessage());        
          return false;
      } 
 }
 
  private static Date parseLongDate(String dateString){
        Map <String, Integer> months = new Map <String, Integer> {'jan'=>1, 'feb'=>2, 'mar'=>3, 'apr'=>4, 'may'=>5, 'jun'=>6, 'jul'=>7, 'aug'=>8, 'sep'=>9, 'oct'=>10, 'nov'=>11, 'dec'=>12};
        List <String> dateParts = dateString.toLowerCase().split(' ');
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = months.get(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        Date parsedDate = Date.newInstance(year,month,day);
        return parsedDate;
    }
  
  @RemoteAction
    public static Integer savePendingActionPlan(Id apSecId,String completed,String completedBy,String completionDate,String completionComment){
      try{
        General_Sub_Task__c apSecObj;
        String queryFieldNamesapSecTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Title__c,Statement__c,Description__c,Action_Plan_Status__c,Type__c,Assigned_User__r.Name,Due_Date__c,Associated_Root_Causes__c,Completed__c,Completed_By__r.Name,Completed_Date__c,Completion_Comments__c,Pend_Save_ActionPlan__c,General_Task__c');
        if(queryFieldNamesapSecTask != null && queryFieldNamesapSecTask != ''){
            apSecObj = database.query('SELECT '+queryFieldNamesapSecTask+' from General_Sub_Task__c where Id = :apSecId');
            apSecObj.Id = apSecId;
            apSecObj.Complete__c = completed;
            apSecObj.Completed_By__c = completedBy;
            apSecObj.Completed_Date__c = parseLongDate(completionDate);
            apSecObj.Completion_Comments__c = completionComment;
            apSecObj.Pend_Save_ActionPlan__c = 'No';
            upsert apSecObj;
            system.debug('apSecObj.Id....'+apSecObj.Id+'  apSecObj.Completed__c....'+apSecObj.Complete__c+'  apSecObj.Completed_By__c....'+apSecObj.Completed_By__c+'   apSecObj.Completion_Comments__c...'+apSecObj.Completion_Comments__c+'  apSecObj.Pend_Save_ActionPlan__c..'+apSecObj.Pend_Save_ActionPlan__c);
        }
        return 0;
      }catch(exception ex){
          System.debug('Exception In Component_Handler.savePendingActionPlan  '+ex.getMessage());        
          return -1;
      } 
    }
    
    @RemoteAction
    public static Integer completePendingActionPlan(Id apSecId,String completed,String completedBy,String completionDate,String completionComment){
      try{
        General_Sub_Task__c apSecObj;
        Set<String> actionPlanStatus = new Set<String>();
        Boolean result; 
        //String queryFieldActionPlans = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Action_Plan_Status__c,General_Task__c');
        String queryFieldNamesapSecTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Title__c,Statement__c,Description__c,Action_Plan_Status__c,Type__c,Assigned_User__r.Name,Due_Date__c,Associated_Root_Causes__c,Completed__c,Completed_By__r.Name,Completed_Date__c,Completion_Comments__c,Pend_Save_ActionPlan__c,General_Task__c');
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','id,Status__c,Non_Conformance__c');
        if(queryFieldNamesapSecTask != null && queryFieldNamesapSecTask != ''){
                        
            apSecObj = database.query('SELECT '+queryFieldNamesapSecTask+' from General_Sub_Task__c where Id = :apSecId');
            id gtid=apSecObj.General_Task__c;
            General_Task__c gtsid = database.query('Select '+ queryFieldSOfGT +' from General_Task__c where id =: gtid');
            
            apSecObj.Id = apSecId;
            apSecObj.Complete__c = completed;
            apSecObj.Completed_By__c = completedBy;
            apSecObj.Completed_Date__c = parseLongDate(completionDate);
            apSecObj.Completion_Comments__c = completionComment;
            apSecObj.Pend_Save_ActionPlan__c = 'yes';
            upsert apSecObj;
            system.debug('apSecObj.Id....'+apSecObj.Id+'  apSecObj.Completed__c....'+apSecObj.Complete__c+'  apSecObj.Completed_By__c....'+apSecObj.Completed_By__c+'   apSecObj.Completion_Comments__c...'+apSecObj.Completion_Comments__c+'  apSecObj.Pend_Save_ActionPlan__c..'+apSecObj.Pend_Save_ActionPlan__c);
             
            List<General_Sub_Task__c> actplans = database.query('SELECT '+queryFieldNamesapSecTask+' from General_Sub_Task__c where General_Task__c = : gtid');
            System.debug('actplans---------------------------------------->'+actplans);
                for(General_Sub_Task__c aps:actplans){
                    actionPlanStatus.add(aps.Action_Plan_Status__c);
                }
                System.debug('actionPlanStatus---------------------------------------->'+actionPlanStatus);
                result = actionPlanStatus.contains('Pending');
                if(!result){
                    gtsid.Status__c = 'Closed';
                }
                else{
                    gtsid.Status__c = 'Pending ActionPlan';
                }
                upsert gtsid;
                System.debug('gtsid.Status__c---------------------------------------->'+gtsid.Status__c);
        }
        return 0;
      }catch(Exception ex){
          System.debug('Exception In Component_Handler.completePendingActionPlan  '+ex.getMessage());        
          return -1;
      }
    }
    
    //End :wiz_add_actionplan,wiz_capa_add_actionplan
    
    //Begin: wiz_add_diposition
    
    public Integer getDispositionSectionData(){
    try{
         if(this.disposition!=null){
             String gTaskId=disposition.Id;
             String queryFieldNamesDispoSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,Disposition_Type__c,Disposition_Type_Status__c,Assigned_Disposition_Qty__c,Assigned_User__r.Name,Due_Date__c,Disposition_Instruction__c,Complete__c,Completed_By__r.Name,Completed_Date__c,Completion_Comment__c,General_Task__c');
             String queryFieldSOfNCDP = QC_DynamicObjectHandler.getAccessibleFields('Disposition_Product__c', 'Id,Pending_Quantity__c,Defect_Quantity__c,NC_ProductId__c,NC_Product__c,General_Sub_Task__c,Dispose_Quantity__c,Product_Batch__c');
             if(queryFieldNamesDispoSec !=null && queryFieldNamesDispoSec != '' && queryFieldSOfNCDP !=null && queryFieldSOfNCDP!=''){
                String dispositionSection='Disposition Section';
                this.dispositionSections = database.query('select '+queryFieldNamesDispoSec+' ,(SELECT ' + queryFieldSOfNCDP + ' FROM Disposition_Products__r LIMIT 999) FROM General_Sub_Task__c where General_Task__c =:gTaskId AND RecordType.Name=:dispositionSection');
             }    
             System.debug(' Component_Handler.getDispositionSectionData this.dispositionSections  '+this.dispositionSections);
             return 0;
        }
        return -1;
     }
     catch(Exception ex){
         System.debug('Exception In Component_Handler.getDispositionSectionData  '+ex.getMessage());
          return -1;
     }
    }
    
     @RemoteAction
    public static Map<String,List<String>> getDispositionData(String ncid){
     
        Schema.DescribeFieldResult fieldResult = General_Sub_Task__c.Disposition_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
     try{
        List<String> data =new List<String>();
        for( Schema.PicklistEntry f : ple){
            data.add(f.getValue());
        }
        dataMap.put('dispoType',data);
        
        List<User> users=new List<User>();
        String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id,Name');
        //---code added for showing 'assigned to' field user values based on NC task groups
        Boolean active = true;
        String role = 'NC_Task_Owner';
        string queryfieldNamesGroups=QC_DynamicObjectHandler.getAccessibleFields('group','id,DeveloperName');
        Set<id> dispositiongroupid=new set<id>(); 
        
       if(queryfieldNamesGroups!=null && queryfieldNamesGroups!='') {
           
        group groupid2=Database.query(' select ' + queryfieldNamesGroups + ' from group where DeveloperName =:role ') ;
        set<id> UserSetid1=new set<id>();
        UserSetid1.add(groupid2.id);
        vfsearch.FinaluserIDSet=new set<id>();
        vfsearch.getUserIds(UserSetid1);  
        dispositiongroupid.addAll(vfsearch.FinaluserIDSet);      
        } 
        
         if(queryFieldNamesUsers !=null && queryFieldNamesUsers != ''){       
          users=Database.query('SELECT ' +queryFieldNamesUsers+ ' FROM User WHERE id IN:dispositiongroupid ORDER BY Id limit 100');
         
        }   
        
        data =new List<String>();
        for(User user : users){
            data.add(user.Id+'@'+user.Name);
        }
        dataMap.put('usrs',data);
        
        String queryFieldNamesProducts;
        List<NC_Product__c> products;
        queryFieldNamesProducts = QC_DynamicObjectHandler.getAccessibleFields('NC_Product__c','id,Name,Product__r.name');
        if(queryFieldNamesProducts !=null && queryFieldNamesProducts != ''){
            products= database.query('Select '+queryFieldNamesProducts+' from NC_Product__c where Non_Conformance__c = :ncId');
        }        
        data =new List<String>();
        for(NC_Product__c product : products){
            data.add(product.id+'@'+product.Product__r.name);
        }
        dataMap.put('prod',data);
     }catch(Exception ex){
          System.debug('Exception In Component_Handler.getDispositionData  '+ex.getMessage());        
         
     }
     return dataMap;
    }
    
    @RemoteAction
    public static Map<String,List<String>> getProductBatch(List<String> nc_product){
      Map<String,List<String>> dataMap=new Map<String,List<String>>();
      try{
        List<String> data =new List<String>();
        List<Product_Lot_Numbers__c> productBatch;
        List<String> productId = new List<String>();
        List<String> split;
        for(integer i=0;i<nc_product.size();i++){
            split = nc_product.get(i).split('@');
            productId.add(split[0]);
        }
        String queryFieldNamesProdLot = QC_DynamicObjectHandler.getAccessibleFields('Product_Lot_Numbers__c','id,NC_Product__c,Name,Lot_Quantity_Affected__c');
        if(queryFieldNamesProdLot !=null && queryFieldNamesProdLot != ''){
            productBatch = database.query('Select '+queryFieldNamesProdLot+' from Product_Lot_Numbers__c where NC_Product__c IN :productId');
        }    
        for(Product_Lot_Numbers__c prodBat : productBatch){
            data.add(prodBat.NC_Product__c+'|'+prodBat.Name+'|'+prodBat.Lot_Quantity_Affected__c);
        }
        dataMap.put('prodBat',data);
        system.debug('AddDispositonController-------------------->>------------------->dataMap----->'+dataMap);
      }catch(Exception ex){
          System.debug('Exception In Component_Handler.getProductBatch  '+ex.getMessage());        
      }
        return dataMap;
        
    }
    
    @RemoteAction
    public static Integer removeDisposition(String dispSecId){
        List<General_Sub_Task__c> dispSecs;
        String queryFieldNamesRemoveSec =  QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,Disposition_Type__c,Assigned_Disposition_Qty__c,Assigned_User__r.Name,Due_Date__c,Disposition_Instruction__c,Complete__c,Completed_By__r.Name,Completed_Date__c,Completion_Comment__c,General_Task__c');
        try{
            if(queryFieldNamesRemoveSec !=null && queryFieldNamesRemoveSec != ''){    
                dispSecs = database.query('select '+queryFieldNamesRemoveSec+' from General_Sub_Task__c WHERE Id=:dispSecId');
                if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                        delete dispSecs; 
                        return 0;
                }
                return -1;
            }    
            return -1;
        }catch(Exception ex){
            System.debug('Exception Component_Handler.removeDisposition    '+ex.getMessage());
            return -1;
        }
    }
    
    @RemoteAction
    public static Integer savePendingDisposition(Id dispSecId,String completed,String completedBy,String completionDate,String completionComment){
      try{
        General_Sub_Task__c dispoSecObj;
        String queryFieldNamesDispSecTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Disposition_Type__c,Disposition_Type_Status__c,Assigned_Disposition_Qty__c,Assigned_User__r.Name,Due_Date__c,Disposition_Instruction__c,Complete__c,Completed_By__r.Name,Completed_Date__c,Completion_Comment__c,General_Task__c');
        if(queryFieldNamesDispSecTask != null && queryFieldNamesDispSecTask != ''){
            dispoSecObj = database.query('SELECT '+queryFieldNamesDispSecTask+' from General_Sub_Task__c where Id = :dispSecId');
            dispoSecObj.Id = dispSecId;
            dispoSecObj.Complete__c = completed;
            dispoSecObj.Completed_By__c = completedBy;
            dispoSecObj.Completed_Date__c = parseLongDate(completionDate);
            dispoSecObj.Completion_Comment__c = completionComment;
            dispoSecObj.RecordTypeId=QC_settings__c.getOrgDefaults().Disposition_Section_RecordTypeId__c;
            upsert dispoSecObj;
        }
        return 0;
      }catch(Exception ex){
        System.debug('Exception In Component_Handler.savePendingDisposition   '+ex.getMessage());
        return -1;
      }
    }
    
    @RemoteAction
    public static Integer updateDispositionStatus(Id generalTaskId){
        Boolean flag = false;
        String queryFieldsDispSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Complete__c,Disposition_Type_Status__c');
        String queryFieldsGenDispTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Approval_Required__c');
        Set<String> dispSecStatus = new Set<String>();
        General_Task__c gTask;
        if(queryFieldsDispSec != null && queryFieldsDispSec != ''){
           List<General_Sub_Task__c> dispSec = database.query('SELECT '+queryFieldsDispSec+' from General_Sub_Task__c where General_Task__c = :generalTaskId');
           List<General_Sub_Task__c> dispSecIdsToUpdate = new List<General_Sub_Task__c>();
            for(General_Sub_Task__c dSec:dispSec){
                if(dSec.Complete__c == 'Yes'){
                   dSec.Disposition_Type_Status__c = 'Completed';
                   dispSecIdsToUpdate.add(dSec); 
                }
                dispSecStatus.add(dSec.Disposition_Type_Status__c);               
            }
            if(!dispSecIdsToUpdate.isEmpty()){
                upsert dispSecIdsToUpdate;
            }
            System.debug('dispSecStatus=====================================> '+dispSecStatus);
        }    
        if(queryFieldsGenDispTask != null && queryFieldsGenDispTask != ''){
            Boolean result = dispSecStatus.contains('Pending');
            System.debug('dispSecStatus.contains(Pending)==================================> '+result);
            gTask = database.query('SELECT '+queryFieldsGenDispTask+' from General_Task__c where Id = :generalTaskId');
            System.debug('gTask.Status__c==================================> '+gTask.Status__c);
            if(gTask.Status__c == 'Disposition Pending Completion' && result){
                System.debug('inside gTask.Status__c == Disposition Pending Completion && flag = true');
                gTask.Status__c = 'Disposition Pending Completion';
            }else if(gTask.Status__c == 'Disposition Pending Completion' && !result){    
                System.debug('inside gTask.Status__c == Disposition Pending Completion && flag = false');
                gTask.Status__c = 'Closed';
            }else if(gTask.Status__c == 'Closed' && !result){
                System.debug('inside gTask.Status__c == Closed && !result');
                gTask.Status__c = 'Closed';
            }else if(gTask.Status__c == 'Closed' && result){
                System.debug('inside gTask.Status__c == Closed && result');
                gTask.Status__c = 'Disposition Pending Completion';
            }else{
                System.debug('inside gTask.Status__c == Open');
                gTask.Status__c = 'Open';
            }    
            upsert gTask;
        }
        return 0;
    }
    
    //End: wiz_add_diposition
    
    //Begin : wiz_add_rootcause_action , wiz_added_rootcause_action and wiz_capa_add_rootcause
    
    public Integer getRootCauseData(){
       try{
            if(this.investigation!=null){
                 String gTaskId=this.investigation.Id;
                 String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Against__c,Cause_Code__r.Name,Cause_Code_Description__c,Defect__r.Name,Defect_Description__c,General_Task__c,Process__r.Name,Product__r.Name');   
                 if(queryFieldNames != null && queryFieldNames != ''){
                     this.rootCauses=Database.query('select ' + queryFieldNames + ' from General_Sub_Task__c where General_Task__c = :gTaskId');   
                 }
             }
             return 0;
        }
        catch(Exception ex){
             System.debug('Exception In Component_Handler.getRootCauseData  '+ex.getMessage());
             return -1;
        }
    }
    
    @RemoteAction
    public static General_Sub_Task__c getRootCause(String rcid){
       String qry;
       List<General_Sub_Task__c> rootCauses=null;
       try{
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Against__c,Cause_Code__r.Name,Cause_Code_Description__c,Defect__r.Name,Defect_Description__c,General_Task__c,Process__r.Name,Product__r.Name');
         if(queryFieldNames != null && queryFieldNames != ''){
             rootCauses =Database.query('select ' + queryFieldNames + ' from General_Sub_Task__c where id = :rcid limit 1');
         }
       }catch(Exception ex){
            System.debug('Exception In Component_Handler.getRootCause  '+ex.getMessage());
       }
       return (rootCauses==null || rootCauses.isEmpty())?new General_Sub_Task__c():rootCauses[0]; 
         
    }
    
    @RemoteAction
    public static boolean deleteRootCause(string id){
        Savepoint sp = Database.setSavepoint();
        List<General_Sub_Task__c> rc = [select id from General_Sub_Task__c where id = :id];
        try{
            if(rc != null && rc.size() > 0){
              if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                delete rc; 
              }
            }
            return true;
        }catch(exception ex){
            Database.rollback(sp);
            System.debug('Exception In Component_Handler.deleteRootCause  '+ex.getMessage());      
            return false;
        } 
    }
    
   @RemoteAction
    public static Map<String,List<String>> getCauseCodes(){
         Map<String,List<String>> dataMap=new Map<String,List<String>>();
         List<String> data =new List<String>();
         String queryFieldNamesCauses = QC_DynamicObjectHandler.getAccessibleFields('Cause__c','Id,Name');
         List<Cause__c> causes = new List<Cause__c>();
         if(queryFieldNamesCauses !=null && queryFieldNamesCauses != ''){
              causes=Database.query('SELECT ' + queryFieldNamesCauses + ' FROM Cause__c WHERE Type__c=\'CAPA\' AND Active__c = true  limit 100');
         }
        for(Cause__c cs : causes){
             data.add(cs.Id+'@'+cs.Name);
        }
        dataMap.put('causes',data);
        system.debug('causecode date---->'+dataMap);
        return dataMap;
    }
    //End : wiz_add_rootcause_action , wiz_added_rootcause_action and wiz_capa_add_rootcause
    
    //Begin : wiz_capa_add_verificationplan
    
    public Integer getVerificationPlanData(){
        try{
            if(effectivenessReview!=null){
             String gTaskId=effectivenessReview.Id;
             String queryFieldNamesvpSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Due_Date__c,Plan_Statement__c,General_Task__c,RecordType.DeveloperName');
             if(queryFieldNamesvpSec !=null && queryFieldNamesvpSec != ''){
                this.verificationPlans = database.query('select '+queryFieldNamesvpSec+' from General_Sub_Task__c where General_Task__c =:gTaskId AND RecordType.DeveloperName=\'Verification_Plans\'');
             }    
            }
            System.debug(' Component_Handler.getVerificationPlanData this.verificationPlans  '+this.verificationPlans);
            return 0;
        }
        catch(Exception ex){
             System.debug('Exception In Component_Handler.getVerificationPlanData  '+ex.getMessage());
              return -1;
        }
     }
     
     //End : wiz_capa_add_verificationplan
    
    @RemoteAction
    public static boolean deleteEffectivenessVerificationPlan(string id){    
       Savepoint sp = Database.setSavepoint();
       try{
        List<General_Sub_Task__c> eps;
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id');
        if(queryFieldNames != null && queryFieldNames != ''){
            eps = database.query('Select '+ queryFieldNames +' from General_Sub_Task__c where id = :id');
        }
        if(eps != null && eps.size() > 0){
           if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                    delete EPS; 
           }
        }
        return true;
        }catch(exception ex){
           Database.rollback(sp);
           System.debug('Exception In Component_Handler.deleteEffectivenessVerificationPlan  '+ex.getMessage());        
           return false;
       } 
        
    }
    
    /*    v1.1 Qualityze Inc(SB)  */
    
       //Begin:wiz_crapproval    
    
    
    
    @RemoteAction
   public static Map<String,List<String>>getCrApprovalData(String taskId,String typeofapprover){
        List<String> data=null;
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Sequence__c');
        if(queryFieldNames != null && queryFieldNames != ''){
                Schema.DescribeFieldResult fieldResult = Change_Management__c.Sequence__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
                data =new List<String>();
                for( Schema.PicklistEntry f : ple){
                    data.add(f.getValue());
                } 
                dataMap.put('sequences',data);
             System.debug('valueofdatamap'+dataMap);
        }
        else{
               System.debug('Component_Handler.getApprovalData  : No Acesss to object  Change_Management__c and fields for sequence '+queryFieldNames);
        }
        queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        //creating a set for holding set of ids of users present in the nc approval group
        Set<id> approvergroupid=new set<id>();  
        
        System.debug('approvergroupid'+approvergroupid);
        
        string approvalaccessiable=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName'); //Added this for overcoming the field level security while creating managed package
       
        
        
        if(approvalaccessiable!=null && approvalaccessiable!='') {
            set<id> UserSetid=new set<id>();           
            group groupid1=Database.query(' select '  + approvalaccessiable +   ' from Group where DeveloperName =:typeofapprover ');   
            UserSetid.add(groupid1.id);
            vfsearch.FinaluserIDSet=new set<id>();
            vfsearch.getUserIds(UserSetid);  
            approvergroupid.addAll(vfsearch.FinaluserIDSet);    
            
        }
        
        if(queryFieldNames != null && queryFieldNames != ''){
            List<User> users=Database.query('SELECT ' + queryFieldNames + ' FROM User WHERE id IN:approvergroupid ORDER BY Id limit 100');
            data =new List<String>();
            for(User user : users){
                data.add(user.Id+'@'+user.Name);
            }
            dataMap.put('usersdata',data);
            
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  Change_Management__c and fields for users '+queryFieldNames);
        }
       
        queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,User__r.Name,Change_Management__c,Change_Management__r.Note_To_Approver__c');
        if(queryFieldNames != null && queryFieldNames != ''){
            List<Approver__c> approvers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE Change_Management__c = : taskId ORDER BY ID');
            data=new List<String>();
            for(Approver__c approver : approvers ){
                data.add(approver.Id+'@'+approver.Sequence_Position__c+'@'+approver.Allowed_Days__c+'@'+approver.Due_Date__c+'@'+approver.User__c+'@'+approver.User__r.Name+'@'+approver.Change_Management__c+'@'+approver.Change_Management__r.Note_To_Approver__c);
            }
            dataMap.put('approversData',data);
             System.debug('valueofdatamap2'+dataMap);

        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  Approver__c and fields for approvers '+queryFieldNames);
        }
        return dataMap; 
       
       
   }
    
     @RemoteAction
    public static Integer saveCrApprovalData(Map<String,List<String>> approvalDetails,String taskId,Boolean isSubmitForApproval){
        System.debug('Component_Handler.saveApprovalData  approvalDetails   '+approvalDetails);
        Savepoint sp;
        try{
         List<Approver__c> existingApprovers=null;
         List <Change_Management__c> genTasks=null;
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Due_Date__c,Note_To_Approver__c,OwnerId');
         if(queryFieldNames != null && queryFieldNames != ''){
             genTasks=Database.query('SELECT '+queryFieldNames+' FROM Change_Management__c WHERE Id=:taskId LIMIT 1');
             List<String> approvalNote=approvalDetails.get('Approval_Note');
             for(Change_Management__c task : genTasks){
                 System.debug('ApprovalController.saveApprovalData  task  '+task);
                 task.Note_To_Approver__c=(approvalNote==null)?null:approvalNote[0];
                 task.Approval_Required__c='Yes';
                 task.Approver__c=task.OwnerId;
             }
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Change_Management__c and fields genTasks '+queryFieldNames);
         }
         queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,Change_Management__c');
         if(queryFieldNames != null && queryFieldNames != ''){
            existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE Change_Management__c = : taskId');
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
         }
         
         List<Approver__c> approvers=new List<Approver__c>();
       
         String[] details;
         List<String> approvalData=approvalDetails.get('Approval');
         if(approvalData.size()>Integer.valueOf(QC_custom_settings.getMaxApprovers())){
             System.debug('Cannot Have More Than 5 Approvers');
             return -1;
         }
         Approver__c approver;
         List<Id> approverIds =new List<Id>();
         Integer sequence=10000; 
         for(String approverDetail : approvalData){
             details=approverDetail.split('@');
             approver=new Approver__c();
             approver.Sequence_Position__c=Integer.valueOf(details[0]);
             approver.User__c=details[1];
             approver.Allowed_Days__c=Integer.valueOf(details[2]);
             approver.Due_Date__c=Date.parse(details[3]);
             approver.Change_Management__c=taskId;
             approvers.add(approver);
             if(sequence==Integer.valueOf(details[0])){
                approverIds.add(details[1]); 
             }
             else if(sequence>Integer.valueOf(details[0])){
                 approverIds.clear();
                 sequence=Integer.valueOf(details[0]);
                 approverIds.add(details[1]);
            }
         }
         sp = Database.setSavepoint();
         if(genTasks!=null && !genTasks.isEmpty()){
           if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Note_To_Approver__c','update')){
                    update genTasks;
           }
           else{
             System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for genTasks ');
           }
         } 
         if(existingApprovers!=null && !existingApprovers.isEmpty()){
            if(Approver__c.sObjectType.getDescribe().isDeletable()){
                   delete existingApprovers;
            }
            else{
              System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers');
            }
         }
         if(!approvers.isEmpty()){
          if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Approver__c','Sequence_Position__c,User__c,Allowed_Days__c,Due_Date__c,Change_Management__c','create')){
            insert approvers;
          }
          else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for insert Approvers');
          }
         }
         if(isSubmitForApproval){
         List<string> approverNote=approvalDetails.get('Approval_Note');
             system.debug('submit for approval'+approverNote);
                 submitCrForApproval(taskId,approverIds,sequence,(approverNote==null)?null:approverNote[0]);
         }
         return 0;
        }catch(Exception ex){
            System.debug('Exception In Component_Handler.saveApprovalData   '+ex.getMessage());
            Database.rollback(sp);
            return -1;
        }
    }
    
     public static void submitCrForApproval(string taskId,list<id> approverIds,Integer sequence,string comments){
        Change_Management__c GT=[select id,Approver__c,Initial_Submitter__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c from Change_Management__c where id=:taskId]; 
                Integer len=approverIds.size();
                 Integer i=1;
                 GT.Approver__c=approverIds[len-1];i++;                                                    
                 GT.Approver_1__c=approverIds[((len-i>0)?len-i:0)];i++;                                       
                 GT.Approver_2__c=approverIds[((len-i)>0)?len-i:0];i++;                                             
                 GT.Approver_3__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_4__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_5__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_6__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_7__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_8__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_9__c=approverIds[((len-i)>0)?len-i:0]; 
               // GT.Note_To_Approver__c=approvalNote[0]; 
                GT.Initial_Submitter__c=UserInfo.getUserId();   
                GT.CurrentApprovalSequenceNumber__c =sequence;   
              //  system.debug('GeneralTask'+GT.New_Owner__c);
                upsert GT;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
               // req.setProcessDefinitionNameOrId('ContainmentTask');
                req.setComments(comments);
               // req.setSkipEntryCriteria(true);
                req.setObjectId(GT.id);
                req.setSubmitterId(UserInfo.getUserId());
                Approval.ProcessResult results = Approval.process(req); 

        
    }
    
    
    
    
       
    
     //End:wiz_crapproval
     
   /*   v1.1 Qualityze Inc(SB)  */
         
     
    
    
    
    //En : wiz_capa_add_verificationplan
    
    //Begin:wiz_approval
    @RemoteAction
    public static Map<String,List<String>>getApprovalData(String taskId,String typeofapprover){
        List<String> data=null;
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Sequence__c');
        if(queryFieldNames != null && queryFieldNames != ''){
                Schema.DescribeFieldResult fieldResult = General_Task__c.Sequence__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                data =new List<String>();
                for( Schema.PicklistEntry f : ple){
                    data.add(f.getValue());
                }
                dataMap.put('seqs',data);
        }
        else{
               System.debug('Component_Handler.getApprovalData  : No Acesss to object  General_Task__c and fields for sequence '+queryFieldNames);
        }
        queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        //creating a set for holding set of ids of users present in the nc approval group
        Set<id> approvergroupid=new set<id>();  
        
        string approvalaccessiable=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName'); //Added this for overcoming the field level security while creating managed package
        
        if(approvalaccessiable!=null && approvalaccessiable!='') {
            set<id> UserSetid=new set<id>();           
            group groupid1=Database.query(' select '  + approvalaccessiable +   ' from Group where DeveloperName =:typeofapprover ');   
            UserSetid.add(groupid1.id);
            vfsearch.FinaluserIDSet=new set<id>();
            vfsearch.getUserIds(UserSetid);  
            approvergroupid.addAll(vfsearch.FinaluserIDSet);         
        }
        
        if(queryFieldNames != null && queryFieldNames != ''){
            List<User> users=Database.query('SELECT ' + queryFieldNames + ' FROM User WHERE id IN:approvergroupid ORDER BY Id limit 100');
            data =new List<String>();
            for(User user : users){
                data.add(user.Id+'@'+user.Name);
            }
            dataMap.put('usrs',data);
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  General_Task__c and fields for users '+queryFieldNames);
        }
         if(!String.isEmpty(taskId) && taskId!=null){                     // v1.1 qualityze Inc (SB)     21-jul-2016  added check for approval data
        queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,User__r.Name,General_Task__c,General_Task__r.Note_To_Approver__c');
        if(queryFieldNames != null && queryFieldNames != ''){
            List<Approver__c> approvers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_Task__c = : taskId ORDER BY ID');
            data=new List<String>();
            for(Approver__c approver : approvers ){
                data.add(approver.Id+'@'+approver.Sequence_Position__c+'@'+approver.Allowed_Days__c+'@'+approver.Due_Date__c+'@'+approver.User__c+'@'+approver.User__r.Name+'@'+approver.General_Task__c+'@'+approver.General_Task__r.Note_To_Approver__c);
            }
            dataMap.put('apprs',data);
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  Approver__c and fields for approvers '+queryFieldNames);
        }
         }
        return dataMap; 
    }
    @RemoteAction
    public static Integer saveApprovalData(Map<String,List<String>> approvalDetails,String taskId,Boolean isSubmitForApproval){
        System.debug('Component_Handler.saveApprovalData  approvalDetails   '+approvalDetails);
        Savepoint sp;
        try{
         List<Approver__c> existingApprovers=null;
         List <General_Task__c> genTasks=null;
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Allowed_Days__c, Due_Date__c, Sequence_Position__c, Owner__c,OwnerName__c,Note_To_Approver__c,OwnerId');
         if(queryFieldNames != null && queryFieldNames != ''){
             genTasks=Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Id=:taskId LIMIT 1');
             List<String> approvalNote=approvalDetails.get('Approval_Note');
             for(General_Task__c task : genTasks){
                 System.debug('ApprovalController.saveApprovalData  task  '+task);
                 task.Note_To_Approver__c=(approvalNote==null)?null:approvalNote[0];
                 task.Approval_Required__c='Yes';
                 task.Approver__c=task.OwnerId;
             }
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  General_Task__c and fields genTasks '+queryFieldNames);
         }
         queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,General_Task__c');
         if(queryFieldNames != null && queryFieldNames != ''){
            existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_Task__c = : taskId');
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
         }
         
         List<Approver__c> approvers=new List<Approver__c>();
       
         String[] details;
         List<String> approvalData=approvalDetails.get('Approval');
         if(approvalData.size()>Integer.valueOf(QC_custom_settings.getMaxApprovers())){
             System.debug('Cannot Have More Than 5 Approvers');
             return -1;
         }
         Approver__c approver;
         List<Id> approverIds =new List<Id>();
         Integer sequence=10000; 
         for(String approverDetail : approvalData){
             details=approverDetail.split('@');
             approver=new Approver__c();
             approver.Sequence_Position__c=Integer.valueOf(details[0]);
             approver.User__c=details[1];
             approver.Allowed_Days__c=Integer.valueOf(details[2]);
             approver.Due_Date__c=Date.parse(details[3]);
             approver.General_Task__c=taskId;
             approvers.add(approver);
             if(sequence==Integer.valueOf(details[0])){
                approverIds.add(details[1]); 
             }
             else if(sequence>Integer.valueOf(details[0])){
                 approverIds.clear();
                 sequence=Integer.valueOf(details[0]);
                 approverIds.add(details[1]);
            }
         }
         sp = Database.setSavepoint();
         if(genTasks!=null && !genTasks.isEmpty()){
           if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Note_To_Approver__c','update')){
                    update genTasks;
           }
           else{
             System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for genTasks ');
           }
         } 
         if(existingApprovers!=null && !existingApprovers.isEmpty()){
            if(Approver__c.sObjectType.getDescribe().isDeletable()){
                   delete existingApprovers;
            }
            else{
              System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers');
            }
         }
         if(!approvers.isEmpty()){
          if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Approver__c','Sequence_Position__c,User__c,Allowed_Days__c,Due_Date__c,General_Task__c','create')){
            insert approvers;
          }
          else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for insert Approvers');
          }
         }
         if(isSubmitForApproval){
         List<string> approverNote=approvalDetails.get('Approval_Note');
                 submitForApproval(taskId,approverIds,sequence,(approverNote==null)?null:approverNote[0]);
         }
         return 0;
        }catch(Exception ex){
            System.debug('Exception In Component_Handler.saveApprovalData   '+ex.getMessage());
            Database.rollback(sp);
            return -1;
        }
    }
     public static void submitForApproval(string taskId,list<id> approverIds,Integer sequence,string comments){
        General_Task__c GT=[select id,Approver__c,Initial_Submitter__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c from General_Task__c where id=:taskId]; 
                Integer len=approverIds.size();
                 Integer i=1;
                 GT.Approver__c=approverIds[len-1];i++;                                                    
                 GT.Approver_1__c=approverIds[((len-i>0)?len-i:0)];i++;                                       
                 GT.Approver_2__c=approverIds[((len-i)>0)?len-i:0];i++;                                             
                 GT.Approver_3__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_4__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_5__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_6__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_7__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_8__c=approverIds[((len-i)>0)?len-i:0];i++;
                 GT.Approver_9__c=approverIds[((len-i)>0)?len-i:0]; 
               // GT.Note_To_Approver__c=approvalNote[0]; 
                GT.Initial_Submitter__c=UserInfo.getUserId();   
                GT.CurrentApprovalSequenceNumber__c =sequence;   
                system.debug('GeneralTask'+GT.New_Owner__c);
                upsert GT;
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
               // req.setProcessDefinitionNameOrId('ContainmentTask');
                req.setComments(comments);
               // req.setSkipEntryCriteria(true);
                req.setObjectId(GT.id);
                req.setSubmitterId(UserInfo.getUserId());
                Approval.ProcessResult results = Approval.process(req); 

        
    }
    
    //End:wiz_approval
    
    //Begin:digital_signature
    
    @RemoteAction
    public static boolean doVerify(string password){     
         
        String clientId = QC_custom_settings.getConsumerKey();
        String clientSecret =QC_custom_settings.getConsumerSecret();
        
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+ userinfo.getusername() +'&password='+password;

        // WARNING: Your password gets saved to your debug logs if you do this
        //system.debug('doVerify(): password = "' + password + '"');
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint('https://login.salesforce.com/services/oauth2/token');//Note if my domain is set up use the proper domain name else use login.salesforce.com for prod or developer or test.salesforce.com for sandbox instance
        
        HttpResponse res = h.send(req);
        system.debug(res.getbody());
        
        OAuth2 authinfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        return (authinfo.id != null && authinfo.id != null);
    }
        /*To get aouthentication detail Wrapper*/
    public class OAuth2{
     public String id{get;set;}

    }
    
    ////End:wiz_approval
 
    //Begin : nc_chronology
    
    public id nccid{get;set;}
    public Map<Date,nc_history> chronology_nc{get;set;}
    public set<Date> getHistoryDate(){ 
        system.debug('inside for getHistoryDate');
        set<Date> chronologyDate=new set<Date>();
        String queryFieldSOfNCH = QC_DynamicObjectHandler.getAccessibleFields('NC_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Non_Conformance__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfNCH!= null && queryFieldSOfNCH!= ''){            
            
            system.debug('if(queryFieldSOfNCH!= null && queryFieldSOfNCH!'+nccid);
            List<NC_History__c> nhs=new List<NC_History__c>();
            nc_history history;
            chronology_nc=new  Map<Date , nc_history>();
            for(NC_History__c nch: database.query('Select '+ queryFieldSOfNCH +' From NC_History__c where Non_Conformance__c =:nccid Order By CreatedDate DESC ')){  
  
                system.debug('inside for loop Chronology');
                if(chronology_nc.get(nch.CreatedDate.Date())!=null){  
                               if(nch.Object__c=='Non_Conformance__c'){
                                    if(nch.Parent__c=='Resolution'){
                                        chronology_nc.get(nch.CreatedDate.Date()).resolution.add(nch); 
                                    }
                                    else{
                                        chronology_nc.get(nch.CreatedDate.Date()).init.add(nch); 
                                    }                  
                                }                       
                                else if(nch.Object__c=='NC_Product__c'||nch.Object__c=='Product_Lot_Numbers__c'){
                                    chronology_nc.get(nch.CreatedDate.Date()).products.add(nch); 
                                }                 
                                else if(nch.Object__c=='General_Sub_Task__c'||nch.Object__c=='General_Task__c'||nch.Object__c=='Disposition_Product__c'||nch.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(nch.Parent__c=='Containment'||nch.Parent__c=='Containment Actions'){
                                        chronology_nc.get(nch.CreatedDate.Date()).containment.add(nch); 
                                    }
                                    else if(nch.Parent__c=='Investigation'||nch.Parent__c=='Root Cause')
                                    {                    
                                        chronology_nc.get(nch.CreatedDate.Date()).investigation.add(nch); 
                                    }   
                                    else if(nch.Parent__c=='Disposition'||nch.Parent__c=='Disposition Section')
                                    {                  
                                        chronology_nc.get(nch.CreatedDate.Date()).disposition.add(nch); 
                                    } 
                                    else if(nch.Parent__c=='Implementation'||nch.Parent__c=='Action Plan')
                                    {                    
                                        chronology_nc.get(nch.CreatedDate.Date()).implementaion.add(nch); 
                                    }   
                                    else if(nch.Parent__c=='Closure')
                                    {               
                                        chronology_nc.get(nch.CreatedDate.Date()).Closure.add(nch); 
                                    }   
                                    else if(nch.Parent__c=='AdhocTask'||nch.Parent__c=='AdhocTask Actions')
                                    {                   
                                        chronology_nc.get(nch.CreatedDate.Date()).Adhoc.add(nch); 
                                    }  
                                    
                                }                     
                }
                else{
                    history=new nc_history();   
                    history.currentDate=nch.CreatedDate.Date();
                    history.init=new List<NC_History__c>(); 
                    history.products=new List<NC_History__c>(); 
                    history.resolution=new List<NC_History__c>(); 
                    history.containment=new List<NC_History__c>(); 
                    history.disposition=new List<NC_History__c>(); 
                    history.implementaion=new List<NC_History__c>(); 
                    history.investigation=new List<NC_History__c>(); 
                    history.Adhoc=new List<NC_History__c>(); 
                    history.Closure=new List<NC_History__c>(); 
                    
                    
                                    
 
                                    
                               if(nch.Object__c=='Non_Conformance__c'){
                                    if(nch.Parent__c=='Resolution'){
                                        history.resolution.add(nch);
                                    }
                                    else{
                                        history.init.add(nch);
                                    }                  
                                }                       
                                else if(nch.Object__c=='NC_Product__c'||nch.Object__c=='Product_Lot_Numbers__c'){
                                        history.products.add(nch);                   
                                }                 
                                else if(nch.Object__c=='General_Sub_Task__c'||nch.Object__c=='General_Task__c'||nch.Object__c=='Disposition_Product__c'||nch.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(nch.Parent__c=='Containment'||nch.Parent__c=='Containment Actions'){
                                        history.containment.add(nch);                   
                                    }
                                    else if(nch.Parent__c=='Investigation'||nch.Parent__c=='Root Cause')
                                    {
                                        history.investigation.add(nch);                      
                                    }   
                                    else if(nch.Parent__c=='Disposition'||nch.Parent__c=='Disposition Section')
                                    {
                                        history.disposition.add(nch);                     
                                    } 
                                    else if(nch.Parent__c=='Implementation'||nch.Parent__c=='Action Plan')
                                    {
                                        history.implementaion.add(nch);                      
                                    }   
                                    else if(nch.Parent__c=='Closure')
                                    {
                                        history.Closure.add(nch);                      
                                    }   
                                    else if(nch.Parent__c=='AdhocTask'||nch.Parent__c=='AdhocTask Actions')
                                    {
                                        history.Adhoc.add(nch);                      
                                    }  
                                    
                                } 
                                    
                                chronology_nc.put(nch.CreatedDate.Date(),history);                                                     
                        }
                
                
            
            chronologyDate.addAll(chronology_nc.keySet());
            //chronologyDate.sort();

            }
            
                   
            
           return chronologyDate;  
        }
        else{
        return new set<Date>();    
        }
        system.debug('outside for loop Chronology');
        return new set<Date>(); 
    }
    
    
    
    
    public class nc_history{
        public date currentDate{get;set;}
        public List<NC_History__c> init{get;set;}
        public List<NC_History__c> products{get;set;}
        public List<NC_History__c> resolution{get;set;}
        public List<NC_History__c> containment{get;set;}
        public List<NC_History__c> disposition{get;set;}
        public List<NC_History__c> implementaion{get;set;}
        public List<NC_History__c> investigation{get;set;}
        public List<NC_History__c> Adhoc{get;set;}
        public List<NC_History__c> Closure{get;set;}
    }    
    //Begin : nc_chronology
    
    //Begin : capa_chronology
    
    public id capacid{get;set;}
    public Map<Date,capa_history> chronology_capa{get;set;}
    public set<Date> getCAPAHistoryDate(){ 
        system.debug('inside for getHistoryDate');
        set<Date> chronologyDate=new set<Date>();
        String queryFieldSOfcapah = QC_DynamicObjectHandler.getAccessibleFields('CAPA_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,CAPA__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfcapah!= null && queryFieldSOfcapah!= ''){            
            
            system.debug('if(queryFieldSOfcapah!= null && queryFieldSOfcapah!'+capacid);
            List<CAPA_History__c> nhs=new List<CAPA_History__c>();
            capa_history history;
            chronology_capa=new  Map<Date , capa_history>();
            for(CAPA_History__c capah: database.query('Select '+ queryFieldSOfcapah +' From CAPA_History__c where CAPA__c =:capacid Order By CreatedDate DESC ')){  
  
                system.debug('inside for loop Chronology');
                if(chronology_capa.get(capah.CreatedDate.Date())!=null){  
                               if(capah.Object__c=='CAPA__c'){
                                    if(capah.Parent__c=='Resolution'){
                                        chronology_capa.get(capah.CreatedDate.Date()).resolution.add(capah); 
                                    }
                                    else{
                                        chronology_capa.get(capah.CreatedDate.Date()).init.add(capah); 
                                    }                  
                                }                       
                                else if(capah.Object__c=='General_Sub_Task__c'||capah.Object__c=='General_Task__c'||capah.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(capah.Parent__c=='Investigation'||capah.Parent__c=='Root Cause@Investigation')//@Investigation
                                    {                    
                                        chronology_capa.get(capah.CreatedDate.Date()).investigation.add(capah); 
                                    }   
                                    else if(capah.Parent__c=='Implementation'||capah.Parent__c=='Action Plan@Implementation' || capah.Parent__c=='Verification Plans@Implementation')//@Implementation
                                    {                    
                                        chronology_capa.get(capah.CreatedDate.Date()).implementaion.add(capah); 
                                    } 
                                    else if(capah.Parent__c=='EffectivenessReview'||capah.Parent__c=='Verification Plans@EffectivenessReview')//@EffectivenessReview
                                    {                  
                                        chronology_capa.get(capah.CreatedDate.Date()).effectivenessreview.add(capah); 
                                    } 
                                    else if(capah.Parent__c=='Closure')
                                    {               
                                        chronology_capa.get(capah.CreatedDate.Date()).Closure.add(capah); 
                                    }   
                                    else if(capah.Parent__c=='AdhocTask'||capah.Parent__c=='AdhocTask Actions@AdhocTask')//@AdhocTask
                                    {                   
                                        chronology_capa.get(capah.CreatedDate.Date()).Adhoc.add(capah); 
                                    }
                                     
                                    
                                }                     
                }
                else{
                    history=new capa_history();   
                    history.currentDate=capah.CreatedDate.Date();
                    history.init=new List<CAPA_History__c>(); 
                    history.resolution=new List<CAPA_History__c>(); 
                    history.effectivenessreview=new List<CAPA_History__c>(); 
                    history.implementaion=new List<CAPA_History__c>(); 
                    history.investigation=new List<CAPA_History__c>(); 
                    history.Adhoc=new List<CAPA_History__c>(); 
                    history.Closure=new List<CAPA_History__c>(); 
                    
                    
                                    
 
                                    
                               if(capah.Object__c=='CAPA__c'){
                                    if(capah.Parent__c=='Resolution'){
                                        history.resolution.add(capah);
                                    }
                                    else{
                                        history.init.add(capah);
                                    }                  
                                }                       
                                else if(capah.Object__c=='General_Sub_Task__c'||capah.Object__c=='General_Task__c'||capah.Object__c=='Disposition_Product__c'||capah.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(capah.Parent__c=='Investigation'||capah.Parent__c=='Root Cause@Investigation')
                                    {
                                        history.investigation.add(capah);                      
                                    }   
                                    else if(capah.Parent__c=='EffectivenessReview'||capah.Parent__c=='Verification Plans@EffectivenessReview')
                                    {
                                        history.effectivenessreview.add(capah);                     
                                    } 
                                    else if(capah.Parent__c=='Implementation'||capah.Parent__c=='Action Plan@Implementation'||capah.Parent__c=='Verification Plans@Implementation')
                                    {
                                        history.implementaion.add(capah);                      
                                    }   
                                    else if(capah.Parent__c=='Closure')
                                    {
                                        history.Closure.add(capah);                      
                                    }   
                                    else if(capah.Parent__c=='AdhocTask'||capah.Parent__c=='AdhocTask Actions@AdhocTask')
                                    {
                                        history.Adhoc.add(capah);                       
                                    }  
                                    
                                    
                                } 
                                    
                                chronology_capa.put(capah.CreatedDate.Date(),history);                                                     
                        }
                
                
            
            chronologyDate.addAll(chronology_capa.keySet());
            //chronologyDate.sort();

            }
            
                   
            
           return chronologyDate;  
        }
        else{
        return new set<Date>();    
        }
        system.debug('outside for loop Chronology');
        return new set<Date>(); 
    }
    
    
    
    
    public class capa_history{
        public date currentDate{get;set;}
        public List<CAPA_History__c> init{get;set;}
        public List<CAPA_History__c> resolution{get;set;}
        public List<CAPA_History__c> effectivenessreview{get;set;}
        public List<CAPA_History__c> implementaion{get;set;}
        public List<CAPA_History__c> investigation{get;set;}
        public List<CAPA_History__c> Adhoc{get;set;}
        public List<CAPA_History__c> Closure{get;set;}
        
    }
    //End : capa_chronology
    
    //Begin: NC_Header
    
    public transient string ncid{Get; set;}
    public transient List<Non_Conformance__c> ncList;
    public transient List<Non_Conformance__c> ncListforVoid;
    public transient List<General_Task__c> adhoctaskList;
    public transient List<General_Task__c> adhocVoidList;
    Set<Id>  gtids=new Set<Id>();
    public transient  Map<String,List<sObject>> childobjs{get; set;}
    public transient Boolean ischildobjsEmpty{get;set;}
    public transient  Map<String,List<sObject>> childobjs_Void{get; set;}
    public transient Map<String, String> gtaskIds{get;set;}
    public transient Map<String,String> adhocTskIds{get;set;}
    public transient Boolean isadhocTskIdsEmpty{get;set;}
    public transient Map<String, String> gtaskIds_Void{get;set;}
    public transient Map<String, String> adhocTskIds_void{get;set;}
    public transient List<General_Task__c> closureTask{get;set;}
    public transient Boolean isClosurePending{get;set;}
    
    
    public Non_Conformance__c getNC(){
        System.debug('Begin   ncList   '+ncList);
        if(ncid != '' && ncid != null)
        { 
          if(ncList==null){
            childobjs =new Map<String,List<sObject>>();
            childobjs_Void =new Map<String,List<sObject>>();
            gtaskIds_Void = new Map<String, String>();
            gtaskIds =new Map<String, String>();
            closureTask=new List<General_Task__c>();
            adhocTskIds = new Map<String,String>();
            adhocTskIds_void = new Map<String, String>();
            String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id,Reopen_Date__c,CreatedDate,Reopen_By__c,ownerid,owner.Name,closed__c,createdbyid,createdby.firstname,createdby.lastname,Age__c,NC_Status__c,NC_Workflow_Status__c,NC_Resolution_Code__c,NC_Type__c, Name,Initiating_Site_name__c,Workflow__c,Followers__c');
            String queryFieldNames2 = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,Non_Conformance__c,RecordType.Name,Status__c,AdhocTask_Title__c');
            //return [select id, ownerid, closed__c, createdbyid, createdby.firstname, createdby.lastname, Age__c, NC_Status__c, NC_Type__c, Name, Initiating_Site_name__c, (SELECT Id,Name,RecordType.Name,Status__c FROM General_Tasks__r where RecordType.Name != 'Closure')  from Non_Conformance__c where id = :ncid limit 1];
            if(queryFieldNames1 != null && queryFieldNames1 != '' && queryFieldNames2 != null && queryFieldNames2 != '')
            {
                ncList = database.query('select '+ queryFieldNames1+', (SELECT '+ queryFieldNames2+' FROM General_Tasks__r)' +' from Non_Conformance__c where id =: ncid limit 1');
                for(General_Task__c gt: ncList[0].General_Tasks__r){
                    if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c =='Closed'){
                        gtids.add(gt.id);
                        childobjs.put(gt.RecordType.Name, new List<sObject>());
                        gtaskIds.put(gt.RecordType.Name,gt.Id);
                    } 
                    if(gt.RecordType.Name == 'Closure' && gt.Status__c =='Pending Approval'){
                        closureTask.add(gt);
                    }
                    if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c =='Closed'){
                        adhocTskIds.put(gt.Id,gt.AdhocTask_Title__c);
                    }
                    if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c !='Void'){
                         childobjs_Void.put(gt.RecordType.Name, new List<sObject>());
                         gtaskIds_Void.put(gt.RecordType.Name,gt.Id);
                    }
                    if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c !='Void'){
                        adhocTskIds_void.put(gt.Id,gt.AdhocTask_Title__c);
                    }
                    
                    
                }
                if(childobjs.isEmpty()){
                   ischildobjsEmpty =true; 
                }
                if(adhocTskIds.isEmpty()){
                  isadhocTskIdsEmpty=true;  
                }
                
                String actionPlansqueryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Name,General_Task__c,General_Task__r.RecordType.Name,Title__c,Action_Plan_Status__c'); 
                if(actionPlansqueryFieldNames != null && actionPlansqueryFieldNames != '')
                {
                    System.debug('Component_Handler getNC  gtids  '+gtids);
                    List<General_Sub_Task__c> actionPlans =  database.query('select '+ actionPlansqueryFieldNames+' From General_Sub_Task__c Where General_Task__c IN :gtids AND General_Task__r.RecordType.Name=\'Implementation\' AND Action_Plan_Status__c =\'Complete\'');
                    System.debug('action plans--------------->'+actionPlans);
                    System.debug('Component_Handler childobjs   '+childobjs);
                    if (!actionPlans.isEmpty()) {
                        List<sObject> apList=childobjs.get('Implementation');
                        System.debug('NCHeader   apList ------>  '+apList);
                        for(General_Sub_Task__c actionpaln : actionPlans){
                            apList.add(actionpaln);
                        }
                        
                    } 
                }
                // List<General_Sub_Task__c> actionPlans = [select id,Name,General_Task__c From General_Sub_Task__c Where General_Task__c IN :gtids];
                String dispositionSectionFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Name,General_Task__c,General_Task__r.RecordType.Name,Disposition_Type_Status__c,Disposition_Type__c'); 
                if(dispositionSectionFieldNames != null && dispositionSectionFieldNames != ''){
                    List<General_Sub_Task__c> dispSections =  database.query('select '+ dispositionSectionFieldNames+' From General_Sub_Task__c Where General_Task__c IN :gtids AND General_Task__r.RecordType.Name=\'Disposition\' AND Disposition_Type_Status__c =\'Completed\'');
                    System.debug('dispSections--------------->'+dispSections);
                    if (!dispSections.isEmpty()) {
                        List<sObject> disList=childobjs.get('Disposition');
                        System.debug('Component_Handler   disList ------>  '+disList);
                        for(General_Sub_Task__c dispSection : dispSections){
                            disList.add(dispSection);
                        }
                        
                        
                    } 
                    
                }
                //List<General_Sub_Task__c> dispSections =  [select id,Name,General_Task__c,Disposition_Type_Status__c From General_Sub_Task__c Where General_Task__c IN :gtids AND Disposition_Type_Status__c ='Completed'];
                system.debug('clild objs-------------->'+childobjs); 
            }
            
                
          }
        }
           
            
            //System.debug('NC_Header  ncList[0]   '+ncList[0]);
            return (ncList==null || ncList.isEmpty())?new Non_Conformance__c():ncList[0]; 
        }
    
    
    @RemoteAction
    public static boolean reopenNCTasks(Map<String,List<String>> tasks,Map<String,String> ncData,String reasonforreopen){
        
        System.debug('Component_Handler.reopenNCTasks  ncData------------------------> '+ncData);
         set<Id> implementIds = new  set<Id>();
         set<Id> disopIds = new  set<Id>();
         set<Id> taskIds = new set<Id>();
        if(!tasks.isEmpty() && ncData.get('NC_Resolution_Code__c')=='NC Workflow'){
               system.debug(tasks);
                //String ReopenBy = ncList[0].Reopen_By__c;
               
              
               
                for( String rc : tasks.keySet()){
                    taskIds.add(rc.split('@')[1]);
                    if(rc.split('@')[0] == 'Implementation'){
                        for(List<String> ctkid : tasks.Values()){
                            for(String impid: ctkid){
                                implementIds.add(impid);
                            }
                        }
                    }
                  
                    if(rc.split('@')[0] == 'Disposition'){
                        for(List<String> ctkid : tasks.Values()){
                            for(String impid: ctkid){
                                disopIds.add(impid);
                            }
                        }
                    }
                    
                    system.debug(rc.split('@')[1]);
                    
                }
                system.debug('implementIds---->'+implementIds); 
                system.debug('disopIds---->'+disopIds);
                system.debug('taskId-------->'+taskIds);
                //reopen implemetation- action plan childs
                if(!implementIds.isEmpty()){
                    List<General_Sub_Task__c> actionPlans;
                    try{
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Action_Plan_Status__c,Pend_Save_ActionPlan__c');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            String qry='select ' + queryFieldNames + ' FROM General_Sub_Task__c WHERE Id IN :implementIds';
                            System.debug('qry   '+qry);
                            actionPlans= database.query (qry);
                        }  
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenNCTasks  '+ex.getMessage());
                    }  
                    for(General_Sub_Task__c ap : actionPlans ){
                        ap.Action_Plan_Status__c = 'Pending';
                        ap.Pend_Save_ActionPlan__c = 'No';
                    }
                    if(!actionPlans.isEmpty()){
                        
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Sub_Task__c','Action_Plan_Status__c,Pend_Save_ActionPlan__c', 'update'))
                        {
                            update actionPlans; 
                        }
                    } 
                }
               //reopen disposition childs 
                if(!disopIds.isEmpty()){
                    List<General_Sub_Task__c> dispActions;
                    try{
                        String dispqueryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Disposition_Type_Status__c');
                        if(dispqueryFieldNames != null && dispqueryFieldNames != ''){
                            String qry2='select ' + dispqueryFieldNames + ' FROM General_Sub_Task__c WHERE Id IN :disopIds';
                            System.debug('qry2   '+qry2);
                            dispActions = database.query(qry2);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenNCTasks  '+ex.getMessage());
                    } 
                    for(General_Sub_Task__c dp : dispActions ){
                        dp.Disposition_Type_Status__c = 'Pending';
                        //dp.Complete__c = 'No';
                    }
                    if(!dispActions.isEmpty()){
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Sub_Task__c','Disposition_Type_Status__c', 'update')){
                            update dispActions; 
                        }   
                    }
                    
                }  
                 
               //reopen tasks 
                System.debug('!taskIds.isEmpty()------------->'+taskIds.isEmpty());
                if(!taskIds.isEmpty()){
                  
                     //Non_Conformance__c nc = getNCRecord(ncid);
                    List<General_Task__c> gTasks;
                    try{
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordType.Name,Due_Date__c,Non_Conformance__c,Allowed_Days__c,Status__c,Task_Reopen_Date__c,Task_Reopen_By__c');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            String gtqry='SELECT ' + queryFieldNames + ' FROM General_Task__c WHERE Id IN :taskIds';
                        
                            gTasks= database.query (gtqry);
                        } 
                        System.debug('gTasks to update------------------>'+gTasks);
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenNCTasks.update generaltask---->  '+ex.getMessage());
                    }  
                    
                    List<NC_History__c> ncHistories=new List<NC_History__c>();
                    NC_History__c history;
                    for(General_Task__c gt : gTasks ){
                        gt.Status__c = 'Open';
                        gt.Due_Date__c = Date.today()+Integer.valueOf(gt.Allowed_Days__c);
                        gt.Task_Reopen_Date__c = Date.today();
                        gt.Task_Reopen_By__c = UserInfo.getUserId();
                        //
                        //
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update'))
                            {
                                history=new NC_History__c();
                                history.Non_Conformance__c =gt.Non_Conformance__c;
                                history.NewValue__c = reasonforreopen;
                                history.Object__c = 'General_Task__c';
                                history.FieldApiName__c='Status__c';
                                history.FieldName__c='ReopenReason';
                                history.Parent__c = gt.RecordType.Name;
                                system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                                ncHistories.add(history);
                                system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                            }
                        //
                        //
                        
                    }
                        
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,Due_Date__c,Task_Reopen_Date__c,Task_Reopen_By__c', 'update'))
                        {
                            update gTasks;
                            system.debug('ncHistories QC_DynamicObjectHandler reasonupdate before insert Genetic tasks'+ncHistories);
                            insert ncHistories;
                            
                        }
                        System.debug('**end of update of general tasks**');
                   
                    
                }
                
                
                //--TODO - Set Closure task status to diabled--//
               
                if((!taskIds.isEmpty()||ncData.get('NC_Resolution_Code__c')=='NC Workflow')){
                    String closureTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,RecordType.Name,Status__c,Non_Conformance__c,CurrentApprovalSequenceNumber__c');
                    Id ncid = ncData.get('ncid');
                    List<General_Task__c> cTask;
                    try{
                        if(closureTaskFields != null && closureTaskFields != '')
                        {
                            String closureqry='SELECT '+ closureTaskFields+' FROM General_Task__c where Non_Conformance__c =: ncid and RecordType.Name = \'Closure\' limit 1';
                            cTask = database.query(closureqry);
                             System.debug('closure object======>'+cTask);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In NC_Header.reopenNCTasks  '+ex.getMessage());
                    }
                    for(General_Task__c ct : cTask ){
                        ct.Status__c = 'Created';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                }
            reopenNC(reasonforreopen,ncData.get('ncid'), ncData.get('NC_Resolution_Code__c'), ncData.get('NC_Status__c'));  //reopen checks if the Nc is closed or not if it closed it will reopen along with nc_workflow_satus
            return true;  
        }
        else{
             //--TODO - Set Closure task status to diabled--//
               
                if((!taskIds.isEmpty()||ncData.get('NC_Resolution_Code__c')=='NC Workflow')){
                    String closureTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,RecordType.Name,Status__c,Non_Conformance__c,CurrentApprovalSequenceNumber__c');
                    Id ncid = ncData.get('ncid');
                    List<General_Task__c> cTask;
                    try{
                        if(closureTaskFields != null && closureTaskFields != '')
                        {
                            String closureqry='SELECT '+ closureTaskFields+' FROM General_Task__c where Non_Conformance__c =: ncid and RecordType.Name = \'Closure\' limit 1';
                            cTask = database.query(closureqry);
                             System.debug('closure object======>'+cTask);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenNCTasks  '+ex.getMessage());
                    }
                    for(General_Task__c ct : cTask ){
                        ct.Status__c = 'Created';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                }
            
            //---TODO--REOPEN NC IF No TASKS ARE THERE 
           reopenNC(reasonforreopen,ncData.get('ncid'), ncData.get('NC_Resolution_Code__c'),ncData.get('NC_Status__c')); //reopen checks if the Nc is closed or not if it closed it will reopen only nc
          return true; 
        }
     
    }
   
   
    @RemoteAction
    public static Boolean reopenNC(String reasonforreopen,string recordid, String ncresolutioncode, String ncstatus){
        Savepoint sp = Database.setSavepoint();
       System.debug('reasonforreopen----->'+reasonforreopen);
        try {
            if(ncstatus =='Closed'){
            Non_Conformance__c nc =new Non_Conformance__c();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c','id,NC_Status__c,Reopen_Date__c,Reopen_By__c,NC_Workflow_Status__c');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<Non_Conformance__c> ncList = database.query('Select '+ queryFieldNames +' from Non_Conformance__c where id = :recordid limit 1');
                 nc = ncList [0];
                if(ncresolutioncode != 'NC Workflow' && ncstatus == 'Closed' ){
                    nc.NC_Status__c = 'Reopened';
                    nc.Reopen_Date__c = Date.today();
                    nc.Reopen_By__c = UserInfo.getUserId();
                }
                if(ncresolutioncode == 'NC Workflow' && ncstatus == 'Closed')
                    nc.NC_Status__c = 'Reopened';
                    nc.Reopen_Date__c = Date.today();
                    nc.Reopen_By__c = UserInfo.getUserId();
                    nc.NC_Workflow_Status__c = 'Open';
                }
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','NC_Status__c,NC_Workflow_Status__c,Reopen_By__c,Reopen_Date__c', 'update'))
                {
                    update nc;
                    
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update')){
                     NC_History__c reasonupdate = new NC_History__c();
                     reasonupdate.Non_Conformance__c =recordid ;
                     reasonupdate.NewValue__c = reasonforreopen;
                     reasonupdate.Object__c = 'Non_Conformance__c';
                     reasonupdate.FieldApiName__c='Status__c';
                     reasonupdate.FieldName__c='ReopenReason';
                     reasonupdate.Parent__c='Resolution'; 
                     system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                     
                     insert reasonupdate;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                    }
                   
                   
                }
            }/*else{
                
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update'))
                {
                    system.debug('QC_DynamicObjectHandler reasonupdate ');
                    NC_History__c reasonupdate = new NC_History__c();
                    reasonupdate.Non_Conformance__c =recordid ;
                    reasonupdate.NewValue__c = reasonforreopen;
                    reasonupdate.Object__c = 'General_Task__c';
                    reasonupdate.FieldApiName__c='Status__c';
                    reasonupdate.FieldName__c='ReopenReason';
                    reasonupdate.Parent__c='ReopenTasks';
                   

                    system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                    insert reasonupdate;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                }
            }*/
             return true;
        }catch(Exception e) {
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }
        
    }

    @RemoteAction
    public static boolean voidNC(string recordid,String voidReason){
        Savepoint sp = Database.setSavepoint();

        try 
        {
                Non_Conformance__c nc =new Non_Conformance__c();
                List<general_task__c> genTasks;
                String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id,NC_Status__c,NC_Workflow_Status__c');    
                List<Non_Conformance__c> ncList = database.query('Select '+ queryFieldNames +' from Non_Conformance__c where id = :recordid limit 1');
                 nc = ncList [0];
                 nc.NC_Status__c = 'Void';
                 nc.NC_Workflow_Status__c = 'Void';
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','NC_Status__c,NC_Workflow_Status__c', 'update'))
                {
                   
                    String queryFieldNamesNcGt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,non_conformance__c,status__c,recordtypeid,recordtype.Name');
                    if(queryFieldNamesNcGt != null && queryFieldNamesNcGt != ''){
                        genTasks= database.query('Select '+ queryFieldNamesNcGt +' from General_Task__c where non_conformance__c=:recordid Limit 100');  
                        for(general_task__c genTask:genTasks){
                            genTask.status__c='Void';
                        }
                        System.debug('-->Update genTask');
                        update genTasks;
                    }  
                   System.debug('-->Update NC'); 
                   update nc;
                   if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update')){
                     List<NC_History__c> voidupdateList=new List<NC_History__c>();
                     NC_History__c voidupdate = new NC_History__c();
                     voidupdate.Non_Conformance__c =recordid ;
                     voidupdate.NewValue__c = voidReason;
                     voidupdate.Object__c = 'Non_Conformance__c';
                     voidupdate.FieldApiName__c='Status__c';
                     voidupdate.FieldName__c='VoidReason';
                     voidupdate.Parent__c='Resolution'; 
                     system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                        voidupdateList.add(voidupdate);
                     NC_History__c voidupdategen;
                       for(General_Task__c genTask:genTasks){
                           voidupdategen = new NC_History__c();
                           voidupdategen.Non_Conformance__c =recordid ;
                           voidupdategen.NewValue__c = voidReason;
                           voidupdategen.Object__c = 'General_Task__c';
                           voidupdategen.FieldApiName__c='NC_Status__c';
                           voidupdategen.FieldName__c='VoidReason';
                           voidupdategen.Parent__c=genTask.RecordType.Name; 
                           voidupdateList.add(voidupdategen);                           
                       }

                     insert voidupdateList;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                    }
                   
                    
                }
                
                
                return true;
          
        }
        catch(Exception e) {
            System.debug('-->Exception In Component_Handler.VoidNC:'+e);
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }
        
    }


@RemoteAction
    public static boolean voidNCTasks(Map<String,List<String>> tasks,string recordid,String voidReason)
    {
        Savepoint sp = Database.setSavepoint();
          try{
                system.debug('-->tasks:'+tasks);
               
                set<Id> taskIds = new set<Id>();
               
                for( String rc : tasks.keySet())
                    {
                        taskIds.add(rc.split('@')[1]);
                    }
                system.debug('taskId-------->'+taskIds);

                List<General_Task__c> gTasks = new List<General_Task__c>();
                try{
                    String queryFieldNamesGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordType.Name,Status__c,Non_Conformance__c');
                    
                    if(queryFieldNamesGT != null && queryFieldNamesGT != '' && taskIds != null && taskIds.size() > 0)
                    {
                        String gtqry='SELECT ' + queryFieldNamesGT + ' FROM General_Task__c WHERE Non_Conformance__c =: recordid and Id IN: taskIds';
                    
                        gTasks= database.query (gtqry);
                        System.debug('-->gTasks:'+gTasks);
                    } 
                }catch(Exception ex){
                    System.debug('Exception In NC_Header.voidNCTasks.update generaltask---->  '+ex.getMessage());
                }
               List<NC_History__c> ncHistories=new List<NC_History__c>(); 
                NC_History__c history;
              if(gTasks != null && gTasks.size() > 0)
              {
                List<General_Task__c> updateGTList = new List<General_Task__c>();
                for(General_Task__c gt : gTasks ){
                    gt.Status__c = 'Void';
                    updateGTList.add(gt);
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update'))
                            {
                                history=new NC_History__c();
                                history.Non_Conformance__c =gt.Non_Conformance__c;
                                history.NewValue__c = voidReason;
                                history.Object__c = 'General_Task__c';
                                history.FieldApiName__c='Status__c';
                                history.FieldName__c='VoidReason';
                                history.Parent__c = gt.RecordType.Name;
                                system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                                ncHistories.add(history);
                                system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                            }
                }
               
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c', 'update'))
                {
                    System.debug('-->Update TASKS');
                    update updateGTList;
                    insert ncHistories;
                }
                System.debug('-->Update TASKS after update:'+updateGTList);
              }

            return true;
          }catch(Exception e){
                Database.rollback(sp);
                ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);

                return false;
          }
}


    
    
    
    @RemoteAction
    public static Boolean closeNC(string recordid,string closeReason){
        Savepoint sp = Database.setSavepoint();
        try {
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<Non_Conformance__c> ncList = database.query('Select '+ queryFieldNames +' from Non_Conformance__c where id = :recordid limit 1');
                //Non_Conformance__c nc = [select id from Non_Conformance__c where id = :recordid limit 1];
                Non_Conformance__c nc = ncList[0];
                nc.NC_Status__c = 'Closed';
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','NC_Status__c', 'update'))
                {
                    update nc;
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update')){
                     NC_History__c closeupdate = new NC_History__c();
                     closeupdate.Non_Conformance__c =recordid ;
                     closeupdate.NewValue__c = closeReason;
                     closeupdate.Object__c = 'Non_Conformance__c';
                     closeupdate.FieldApiName__c='Status__c';
                     closeupdate.FieldName__c='CloseReason';
                     closeupdate.Parent__c='Resolution'; 
                     system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                     
                     insert closeupdate;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                    }
                }
            }
            
           return true;   
        }
        catch(Exception e) {
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }  
      
    }
    
     @RemoteAction
  public static Integer followNC(String ncId,String userId){
       try{
          return NonConformance.followNC(ncId,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.followNC   '+ex.getMessage());
          return -1;
       }
   }
   
   @RemoteAction
   public static Integer unFollowNC(String ncId,String userId){
       try{
          return NonConformance.unFollowNC(ncId,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.unFollowNC   '+ex.getMessage());
          return -1;
       }
    }
    
    //End: NC_Header
    
    //Begin:CAPA_Header
    
    public string capa_id{Get; set;}
    public List<CAPA__c> capaList;
    public Map<String, String> capaadhoctasks{get;set;}
    public CAPA__c getCAPA(){
        System.debug('Begin   capaList   '+capaList);
        if(capa_id != '' && capa_id != null)
        { 
            if(capaList==null){
                system.debug('Inside If condition of get capa ******');
                childobjs =new Map<String,List<sObject>>();
                childobjs_Void =new Map<String,List<sObject>>();
                gtaskIds_Void = new Map<String, String>();
                gtaskIds =new Map<String, String>();
                closureTask=new List<General_Task__c>();
                adhocTskIds = new Map<String, String>();
                capaadhoctasks =new Map<String, String>();
                adhocTskIds_void = new Map<String, String>();
                String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c',  'id, ownerid, owner.Name, createdbyid, createdby.firstname, createdby.lastname, CAPA_Age__c, Name, CAPA_Status__c, Reported_Date__c,Reopen_By__c,Resolution_Code__c,Followers__c,CreatedDate,Approval_Status__c,Is_In_Works__c,CAPA_Phase__c,Sites_Impacted__c,Closed__c');
                String queryFieldNames2 = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,CAPA__c,RecordType.Name,Status__c,AdhocTask_Title__c');
                //return [select id, ownerid, closed__c, createdbyid, createdby.firstname, createdby.lastname, Age__c, NC_Status__c, NC_Type__c, Name, Initiating_Site_name__c, (SELECT Id,Name,RecordType.Name,Status__c FROM General_Tasks__r where RecordType.Name != 'Closure')  from Non_Conformance__c where id = :ncid limit 1];
                if(queryFieldNames1 != null && queryFieldNames1 != '' && queryFieldNames2 != null && queryFieldNames2 != '')
                {
                    capaList = database.query('select '+ queryFieldNames1+', (SELECT '+ queryFieldNames2+' FROM General_Tasks__r) from CAPA__c where id =: capa_id limit 1');
                    //system.debug('capaList--->'+capaList);
                    for(General_Task__c gt: capaList[0].General_Tasks__r){
                        if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c =='Closed'){
                            gtids.add(gt.id);
                            childobjs.put(gt.RecordType.Name, new List<sObject>());
                            gtaskIds.put(gt.RecordType.Name,gt.Id);
                        } 
                        if(gt.RecordType.Name == 'Closure' && gt.Status__c =='Pending Approval'){
                            closureTask.add(gt);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c =='Closed'){
                            system.debug('*******Inside adhoc close check*********'+gt.RecordType.Name+' '+gt.Status__c);
                            adhocTskIds.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c =='Closed'){
                            capaadhoctasks.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c !='Void'){
                            childobjs_Void.put(gt.RecordType.Name, new List<sObject>());
                            gtaskIds_Void.put(gt.RecordType.Name,gt.Id);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c !='Void'){
                            adhocTskIds_void.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        
                        
                    }
                    
                    if(childobjs.isEmpty()){
                        ischildobjsEmpty =true; 
                    }
                    if(adhocTskIds.isEmpty()){
                        isadhocTskIdsEmpty=true; 
                    }
                    String actionPlansqueryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Name,Title__c,Action_Plan_Status__c,Complete__c,RecordType.Name');
                    if(actionPlansqueryFieldNames != null && actionPlansqueryFieldNames != '')
                    {
                        List<General_Sub_Task__c> actionPlans =  database.query('select '+ actionPlansqueryFieldNames+' From General_Sub_Task__c Where General_Task__c IN :gtids AND Action_Plan_Status__c =\'Complete\' AND RecordType.Name=\'Action Plan\'');
                        System.debug('action plans--------------->'+actionPlans);
                        if (!actionPlans.isEmpty()) {
                            List<sObject> apList=childobjs.get('Implementation');
                            for(General_Sub_Task__c actionpaln : actionPlans){
                                apList.add(actionpaln);
                            }
                            
                        } 
                    }
                    system.debug('clild objs-------------->'+childobjs); 
                    system.debug('adhocTskIds---------->'+adhocTskIds);
                    system.debug('adhocTskIds_void-------->'+adhocTskIds_void);
                }
                
                
            }
        }
        
        
       // System.debug('CAPA_Header capaList[0]   '+capaList[0]);
        return (capaList==null || capaList.isEmpty())?new CAPA__c():capaList[0]; 
        
    }
    
    @Remoteaction
    public static boolean reopenTasks(Map<String,List<String>> tasks,Map<String,String> capadata,String reasonforreopen){
        system.debug('reopenTasks------>'+tasks+' '+capadata+' '+reasonforreopen);
        set<Id> implementIds = new  set<Id>();
        set<Id> taskIds = new set<Id>();
        if(!tasks.isEmpty()){
            for( String rc : tasks.keySet()){
                taskIds.add(rc.split('@')[1]);
                if(rc.split('@')[0] == 'Implementation'){
                    for(List<String> ctkid : tasks.Values()){
                        for(String impid: ctkid){
                            implementIds.add(impid);
                        }
                    }
                }
                system.debug(rc.split('@')[1]);   
            }
            system.debug('implementIds---->'+implementIds); 
            system.debug('taskId-------->'+taskIds);
            //reopen implemetation- action plan childs
            if(!implementIds.isEmpty()){
                List<General_Sub_Task__c> actionPlans;
                try{
                    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Action_Plan_Status__c,Pend_Save_ActionPlan__c');
                    if(queryFieldNames != null && queryFieldNames != '')
                    {
                        String qry='select ' + queryFieldNames + ' FROM General_Sub_Task__c WHERE Id IN :implementIds';
                        System.debug('qry   '+qry);
                        actionPlans= database.query (qry);
                    }  
                }catch(Exception ex){
                    System.debug('Exception In Component_Handler.reopenNCTasks  '+ex.getMessage());
                }  
                for(General_Sub_Task__c ap : actionPlans ){
                    ap.Action_Plan_Status__c = 'Pending';
                    ap.Pend_Save_ActionPlan__c = 'No';
                }
                if(!actionPlans.isEmpty()){
                    
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Sub_Task__c','Action_Plan_Status__c,Pend_Save_ActionPlan__c', 'update'))
                    {
                        update actionPlans; 
                    }
                } 
            }
            
                           
               //reopen tasks 
                System.debug('!taskIds.isEmpty()------------->'+taskIds.isEmpty());
                if(!taskIds.isEmpty()){
                  
                     //Non_Conformance__c nc = getNCRecord(ncid);
                    
                    List<General_Task__c> gTasks;
                    try{
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordType.Name,Due_Date__c,CAPA__c,Allowed_Days__c,Status__c,Task_Reopen_Date__c,Task_Reopen_By__c');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            String gtqry='SELECT ' + queryFieldNames + ' FROM General_Task__c WHERE Id IN :taskIds';
                        
                            gTasks= database.query (gtqry);
                        } 
                        System.debug('gTasks to update------------------>'+gTasks);
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenCAPATasks.update generaltask---->  '+ex.getMessage());
                    }  
                    
                    List<CAPA_History__c> capaHistories=new List<CAPA_History__c>();
                    CAPA_History__c history;
                    for(General_Task__c gt : gTasks ){
                        gt.Status__c = 'Open';
                        gt.Due_Date__c = Date.today()+Integer.valueOf(gt.Allowed_Days__c);
                        gt.Task_Reopen_Date__c = Date.today();
                        gt.Task_Reopen_By__c = UserInfo.getUserId();
                        //
                        //
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update'))
                            {
                                history=new CAPA_History__c();
                                history.CAPA__c =gt.CAPA__c;
                                history.NewValue__c = reasonforreopen;
                                history.Object__c = 'General_Task__c';
                                history.FieldApiName__c='Status__c';
                                history.FieldName__c='ReopenReason';
                                history.Parent__c = gt.RecordType.Name;
                                system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                                capaHistories.add(history);
                                system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                            }
                        //
                        //
                        
                    }
                        
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,Due_Date__c,Task_Reopen_Date__c,Task_Reopen_By__c', 'update'))
                        {
                            update gTasks;
                            system.debug('ncHistories QC_DynamicObjectHandler reasonupdate before insert Genetic tasks'+capaHistories);
                            insert capaHistories;
                            
                        }
                        System.debug('**end of update of general tasks**');
                   
                    
                }
                //--TODO - Set Closure task status to diabled--//
               
                if((!taskIds.isEmpty()||capadata.get('Resolution_Code__c')=='CAPA Workflow')){
                    
                    String closureTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,RecordType.Name,Status__c,CAPA__c,CurrentApprovalSequenceNumber__c');
                    Id capaid = capadata.get('capaid');
                    List<General_Task__c> cTask;
                    try{
                        if(closureTaskFields != null && closureTaskFields != '')
                        {
                            String closureqry='SELECT '+ closureTaskFields+' FROM General_Task__c where CAPA__c =: capaid and RecordType.Name = \'Closure\' limit 1';
                            cTask = database.query(closureqry);
                             System.debug('closure object======>'+cTask);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenNCTasks  '+ex.getMessage());
                    }
                    for(General_Task__c ct : cTask ){
                     
                        ct.Status__c = 'Created';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                } 
           
            //---TODO--REOPEN NC IF No TASKS ARE THERE 
           reopenCAPA('reasonforreopen',capadata.get('capaid'), capadata.get('Resolution_Code__c'),capadata.get('CAPA_Status__c')); //reopen checks if the CAPA is closed or not if it closed it will reopen only nc
          return true;   
            
        } else{
             //--TODO - Set Closure task status to diabled--//
               String closureTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,RecordType.Name,Status__c,CAPA__c,CurrentApprovalSequenceNumber__c');
                    Id capaid = capadata.get('capaid');
                    List<General_Task__c> cTask;
                    try{
                        if(closureTaskFields != null && closureTaskFields != '')
                        {
                            String closureqry='SELECT '+ closureTaskFields+' FROM General_Task__c where CAPA__c =: capaid and RecordType.Name = \'Closure\' limit 1';
                            cTask = database.query(closureqry);
                             System.debug('closure object======>'+cTask);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In capa_header.reopenNCTasks  '+ex.getMessage());
                    } 
                if((!taskIds.isEmpty()&&capadata.get('Resolution_Code__c')=='CAPA Workflow')){
                   system.debug('If tasks selected  ');
                    for(General_Task__c ct : cTask ){
                        ct.Status__c = 'Created';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                }
             if((taskIds.isEmpty()&&capadata.get('Resolution_Code__c')=='CAPA Workflow')){
                   system.debug('If no tasks selected');
                    for(General_Task__c ct : cTask ){
                        ct.Status__c = 'Open';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                }
            
            //---TODO--REOPEN NC IF No TASKS ARE THERE 
            reopenCAPA('reasonforreopen',capadata.get('capaid'), capadata.get('Resolution_Code__c'),capadata.get('CAPA_Status__c')); //reopen checks if the CAPA is closed or not if it closed it will reopen only nc
          return true; 
        }
     
        
       
    }
    
    
    
    
    @RemoteAction
    public static void reopenCAPA(string reasonforreopen, string recordid, string resolutioncode,string capastatus){
        system.debug('reopencapafunc');
        system.debug('reasonforreopen--->'+reasonforreopen+'  recordid--> '+recordid+' resolutioncode--> '+resolutioncode);
        Savepoint sp = Database.setSavepoint();
        try {
           if(capastatus =='Closed'){
            CAPA__c capaobj = new CAPA__c();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','id,CAPA_Status__c ,Reopen_Date__c,Reopen_By__c,Resolution_Code__c ');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<CAPA__c> capaList = database.query('Select '+ queryFieldNames +' from CAPA__c where id = :recordid limit 1');
                 capaobj = capaList [0];
                if(resolutioncode != 'CAPA Workflow' && capastatus == 'Closed' ){
                     system.debug('<---------resolutioncode  != CAPA Workflow capastatus == Closed------------->');
                    capaobj.CAPA_Status__c = 'Reopened';
                    capaobj.Reopen_Date__c = Date.today();
                    capaobj.Reopen_By__c = UserInfo.getUserId();
                    capaobj.Resolution_Code__c = resolutioncode;
                }
                else if(resolutioncode == 'CAPA Workflow' && capastatus == 'Closed'){
                    system.debug('<---------resolutioncode == CAPA Workflow && capastatus == Closed------------->');
                    capaobj.CAPA_Status__c = 'Reopened';
                    capaobj.Reopen_Date__c = Date.today();
                    capaobj.Reopen_By__c = UserInfo.getUserId();
                    capaobj.Resolution_Code__c = 'CAPA Workflow';
                }
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','CAPA_Status__c,Resolution_Code__c,Reopen_By__c,Reopen_Date__c', 'update'))
                {
                    update capaobj;
                 system.debug('after reopen capa');   
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update')){
                     CAPA_History__c reasonupdate = new CAPA_History__c();
                     reasonupdate.CAPA__c =recordid ;
                     reasonupdate.NewValue__c = reasonforreopen;
                     reasonupdate.Object__c = 'CAPA__c';
                     reasonupdate.FieldApiName__c='CAPA_Status__c';
                     reasonupdate.FieldName__c='ReopenReason';
                     reasonupdate.Parent__c='Resolution'; 
                     system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                     
                     insert reasonupdate;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                    }
                   
                   
                }
            }
            /*String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'id');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<CAPA__c> capaList = database.query('Select '+ queryFieldNames +' from CAPA__c where id = :recordid limit 1');
                CAPA__c capa = capaList [0];
                //capa.Status__c = 'Reopened';
                //if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','Status__c', 'update'))
                //{
                //update capa;
                //}
            }*/
        }
        }//try
        catch(Exception e) {
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
        }       
    }
    
    public boolean getcan_reopen(){
        return CAPA.can_reopen(getCAPA());
    }
    @RemoteAction
    public static boolean voidCAPATasks(Map<String,List<String>> tasks,string recordid,String voidReason)
    {
        
        
        Savepoint sp = Database.setSavepoint();
          try{
                system.debug('-->tasks:'+tasks);
               
                set<Id> taskIds = new set<Id>();
               
                for( String rc : tasks.keySet())
                    {
                        taskIds.add(rc.split('@')[1]);
                    }
                system.debug('taskId-------->'+taskIds);

                List<General_Task__c> gTasks = new List<General_Task__c>();
                try{
                    String queryFieldNamesGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordType.Name,Status__c,CAPA__c');
                    
                    if(queryFieldNamesGT != null && queryFieldNamesGT != '' && taskIds != null && taskIds.size() > 0)
                    {
                        String gtqry='SELECT ' + queryFieldNamesGT + ' FROM General_Task__c WHERE CAPA__c =: recordid and Id IN: taskIds';
                    
                        gTasks= database.query (gtqry);
                        System.debug('-->gTasks:'+gTasks);
                    } 
                }catch(Exception ex){
                    System.debug('Exception In Component_Handler.voidNCTasks.update generaltask---->  '+ex.getMessage());
                }
               List<CAPA_History__c> ncHistories=new List<CAPA_History__c>(); 
                CAPA_History__c history;
              if(gTasks != null && gTasks.size() > 0)
              {
                List<General_Task__c> updateGTList = new List<General_Task__c>();
                for(General_Task__c gt : gTasks ){
                    gt.Status__c = 'Void';
                    updateGTList.add(gt);
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update'))
                            {
                                history=new CAPA_History__c();
                                history.CAPA__c =gt.CAPA__c;
                                history.NewValue__c = voidReason;
                                history.Object__c = 'General_Task__c';
                                history.FieldApiName__c='Status__c';
                                history.FieldName__c='VoidReason';
                                history.Parent__c = gt.RecordType.Name;
                                system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                                ncHistories.add(history);
                                system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                            }
                }
               
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c', 'update'))
                {
                    System.debug('-->Update TASKS');
                    update updateGTList;
                    insert ncHistories;
                }
                System.debug('-->Update TASKS after update:'+updateGTList);
              }

            return true;
          }catch(Exception e){
                Database.rollback(sp);
                ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);

                return false;
          }

    }
    
    @RemoteAction 
    public static boolean voidCAPA(string recordid,String voidReason){
        Savepoint sp = Database.setSavepoint();

        try 
        {
                CAPA__c capa =new CAPA__c();
                List<general_task__c> genTasks;
                String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','id,CAPA_Status__c ,Reopen_Date__c,Reopen_By__c,Resolution_Code__c ');
                List<CAPA__c> capaList = database.query('Select '+ queryFieldNames +' from CAPA__c where id = :recordid limit 1');
                 capa = capaList [0];
                 capa.CAPA_Status__c = 'Void';
                
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','CAPA_Status__c', 'update'))
                {
                   
                    String queryFieldNamesNcGt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,CAPA__c,status__c,recordtypeid,recordtype.Name');
                    if(queryFieldNamesNcGt != null && queryFieldNamesNcGt != ''){
                        genTasks= database.query('Select '+ queryFieldNamesNcGt +' from General_Task__c where CAPA__c=:recordid Limit 100');  
                        for(general_task__c genTask:genTasks){
                            genTask.status__c='Void';
                        }
                        System.debug('-->Update genTask');
                        update genTasks;
                    }  
                   System.debug('-->Update NC'); 
                   update capa;
                   if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_History__c','Parent__c,NewValue__c,Object__c,FieldName__c', 'update')){
                     List<CAPA_History__c> voidupdateList=new List<CAPA_History__c>();
                     CAPA_History__c voidupdate = new CAPA_History__c();
                     voidupdate.CAPA__c =recordid ;
                     voidupdate.NewValue__c = voidReason;
                     voidupdate.Object__c = 'CAPA__c';
                     voidupdate.FieldApiName__c='CAPA_Status__c';
                     voidupdate.FieldName__c='VoidReason';
                     voidupdate.Parent__c='Resolution'; 
                     system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                        voidupdateList.add(voidupdate);
                     CAPA_History__c voidupdategen;
                       for(General_Task__c genTask:genTasks){
                           voidupdategen = new CAPA_History__c();
                           voidupdategen.CAPA__c =recordid ;
                           voidupdategen.NewValue__c = voidReason;
                           voidupdategen.Object__c = 'General_Task__c';
                           voidupdategen.FieldApiName__c='Status__c';
                           voidupdategen.FieldName__c='VoidReason';
                           voidupdategen.Parent__c=genTask.RecordType.Name; 
                           voidupdateList.add(voidupdategen);                           
                       }

                     insert voidupdateList;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                    }
                   
                    
                }
                
                
                return true;
          
        }
        catch(Exception e) {
            System.debug('-->Exception In Component_Handler.VoidNC:'+e);
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }

    }
  
    @RemoteAction
    public static Boolean closeCAPAtask(string recordid,string closereason){
         Savepoint sp = Database.setSavepoint();
        try{
             String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'id,CAPA_Status__c ');
            if(queryFieldNames != null && queryFieldNames != ''){
               system.debug('insideclose');
               
               List<CAPA__c> capaList = database.query('Select '+ queryFieldNames +' from CAPA__c where id = :recordid limit 1');
               CAPA__c capa =new CAPA__c();
               system.debug('capaList--->'+capaList);
               capa = capaList[0];
               capa.CAPA_Status__c  = 'Closed';
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','CAPA_Status__c ', 'update'))
                {
                system.debug('beforeclose-->'+capa);
                update capa;
                system.debug('afetrclose');
                }
            }
             return true;   
        }catch(Exception e) {
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }   
     
    }

  @RemoteAction
  public static Integer followCAPA(String capaId,String userId){
       try{
          return CAPA.followCAPA(capaId,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.followCAPA   '+ex.getMessage());
          return -1;
       }
   }
   
   @RemoteAction
   public static Integer unFollowCAPA(String capaId,String userId){
       try{
          return CAPA.unFollowCAPA(capaId,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.unFollowCAPA   '+ex.getMessage());
          return -1;
       }
    }
    
    //End:CAPA_Header
    
    //Begin: Changemanagement_Header
    public string CHMG_Id{Get;Set;}
    public List<Change_Management__c> CHAMG_list;
    public Map<String, String> chngmgtadhoctasks{get;set;}

    public Change_Management__c getCHMG(){
        if(CHMG_Id != '' && CHMG_Id != null)
        { 
            if(CHAMG_list==null){
                
                childobjs =new Map<String,List<sObject>>();
                childobjs_Void =new Map<String,List<sObject>>();
                gtaskIds_Void = new Map<String, String>();
                gtaskIds =new Map<String, String>();
                closureTask=new List<General_Task__c>();
                adhocTskIds = new Map<String, String>();
                chngmgtadhoctasks =new Map<String, String>();
                adhocTskIds_void = new Map<String, String>();
 
                String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c','Id,Name,CreatedDate,Owner.Name,Age__c,Resolution_Code__c,Status__c,Phase__c ,Source__c,RecordType.Name,Followers__c,Change_Request_Type__c ');
                if(queryFieldNames1 != null && queryFieldNames1 != '' ){
                    CHAMG_list = database.query('select '+ queryFieldNames1+' from Change_Management__c where id =: CHMG_Id limit 1');
                    system.debug('CHAMG_list1---->'+CHAMG_list);
                    
                }
                
                String queryFieldNames2 = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,Change_Management__c,RecordType.Name,Status__c,AdhocTask_Title__c,New_Due_Date__c ');
                if(queryFieldNames1 != null && queryFieldNames1 != '' && queryFieldNames2 != null && queryFieldNames2 != '')
                {
                    CHAMG_list = database.query('select '+ queryFieldNames1+', (SELECT '+ queryFieldNames2+' FROM General_Tasks__r) from Change_Management__c where id =: CHMG_Id limit 1');
                    system.debug('CHAMG_list2--->'+CHAMG_list);
                    for(General_Task__c gt: CHAMG_list[0].General_Tasks__r){
                        if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c =='Closed'){
                            gtids.add(gt.id);
                            childobjs.put(gt.RecordType.Name, new List<sObject>());
                            gtaskIds.put(gt.RecordType.Name,gt.Id);
                        } 
                        if(gt.RecordType.Name == 'Closure' && gt.Status__c =='Pending Approval'){
                            closureTask.add(gt);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c =='Closed'){
                            system.debug('*******Inside adhoc close check*********'+gt.RecordType.Name+' '+gt.Status__c);
                            adhocTskIds.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c =='Closed'){
                            chngmgtadhoctasks.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        if(gt.RecordType.Name != 'Closure' && gt.RecordType.Name != 'AdhocTask' && gt.Status__c !='Void'){
                            childobjs_Void.put(gt.RecordType.Name, new List<sObject>());
                            gtaskIds_Void.put(gt.RecordType.Name,gt.Id);
                        }
                        if(gt.RecordType.Name == 'AdhocTask' && gt.Status__c !='Void'){
                            adhocTskIds_void.put(gt.AdhocTask_Title__c,gt.Id);
                        }
                        
                        
                    }
                    
                    if(childobjs.isEmpty()){
                        ischildobjsEmpty =true; 
                    }
                    if(adhocTskIds.isEmpty()){
                        isadhocTskIdsEmpty=true; 
                    }
                    
                    system.debug('clild objs-------------->'+childobjs); 
                    system.debug('adhocTskIds---------->'+adhocTskIds);
                    //system.debug('adhocTskIds_void-------->'+adhocTskIds_void);
                }
            }
        }
        
        return (CHAMG_list==null || CHAMG_list.isEmpty())?new Change_Management__c():CHAMG_list[0];
    }
    
  @RemoteAction
  public static Integer followChangemanagement(String chmgid,String userId){
       try{
          return ChangeManagementControllerExt.followChangemanagement(chmgid,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.followChangemanagement   '+ex.getMessage());
          return -1;
       }
   }
   
    @RemoteAction
   public static Integer unfollowChangemanagement(String chmgid,String userId){
       try{
          return ChangeManagementControllerExt.unfollowChangemanagement(chmgid,userId);
       }
       catch(Exception ex){
          System.debug('Exception In Component_Handler.unfollowChangemanagement   '+ex.getMessage());
          return -1;
       }
    }
   
    //End : Changemanagement_Header
    
   //Begin:Document_header
    
   public string doc_Id{get;set;}
   public list<Document_Profile__c> doc_list;
   
     public Document_Profile__c getdoc(){
        if(doc_Id!=null && doc_Id!='') 
        {
            if(doc_list==null) 
            {
            string querydocheaderfields=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','Id,Name,Owner.Name,CreatedDate,Status__c,Current_Rev__c,Type__c,Effective_Date__c,Expiration_Date__c,Followers__c,Document_Type__r.Name,Document_Type__r.Title__c,Approval_Status__c,isTemp__c,isTempRevise__c,isRevise__c,New_Rev__c,Action_Status__c,Title__c,CD_Customer__c,CD_Customer__r.Name');    
            system.debug('doc values' +querydocheaderfields) ;
            if(querydocheaderfields!=null && querydocheaderfields!='') {
            doc_list=Database.query(' select ' + querydocheaderfields + ' from Document_Profile__c where id = :doc_Id limit 1');                 
            System.debug('doc_list' +doc_list); 
            }                   
        }
     }
        
     return (doc_list==null || doc_list.isEmpty())?new Document_Profile__c():doc_list[0] ;          
        
     }
    
  @RemoteAction
  public static Integer followDocument(String docid,String userId){
       try{
         return DocumentProfileControllerExt.followdocument(docid,userId);
       }
       catch(Exception ex){
       System.debug('Exception In Component_Handler.followDocument '+ex.getMessage());
          return -1;
       }
   }
   
    @RemoteAction
   public static Integer unfollowDocument(String docid,String userId){
       try{
          return DocumentProfileControllerExt.unfollowDocument(docid,userId);
       }
       catch(Exception ex){
       System.debug('Exception In Component_Handler.unfollowDocument   '+ex.getMessage());
          return -1;
       }   
   }
  
  //End:Document_header
  
  
  //Begin:Make Doc Current  (Code Added by Gaurav for doc made current)
    
    
    @RemoteAction    
    Public static boolean DocmadeCurrent(string docrecordID,string ReasonForChange){
        system.debug('@@@@inside function');
        Savepoint sp = Database.setSavepoint();
       
        try {
        
        Document_Profile__c DOC=new Document_Profile__c();
        string queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','id,Type__c,Status__c ,Effective_Date__c,Expiration_Date__c,Approval_Status__c,Release_Date__c,Document_Type__r.Name,Approval_Required__c');
        system.debug('values ' +queryFieldNames);
        List<Document_Profile__c> DocList = database.query('Select '+ queryFieldNames +' from Document_Profile__c where id = :docrecordID limit 1');
        system.debug('query field names values' +DocList);
            
        DOC=DocList[0];
        DOC.Status__c='Prerelease';
        DOC.Reason_for_Change__c='ReasonForChange';
        
       if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Status__c', 'update'))
       {
          String queryFieldNamesNcGt = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,status__c,Approval_Status__c'); 
           
           if(queryFieldNamesNcGt != null && queryFieldNamesNcGt != ''){
              for(Document_Profile__c document:DocList)    
              {
                   
                  document.Status__c='Current'; 
                 // document.Reason_for_Change__c='';
              }  
             System.debug('-->Update status');
             //update DocList; update by balu
      }
         System.debug('-->Update status to current');
         update DOC;
        
       if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','NewValue__c,Object__c,FieldName__c', 'update')){
          List<Document_Profile_History__c> CurrentUpdateList= new List<Document_Profile_History__c>();
          Document_Profile_History__c CurrentUpdate= new Document_Profile_History__c();
           CurrentUpdate.Parent__c =docrecordID ;
           CurrentUpdate.Object__c = 'Document_Profile__c';
           CurrentUpdate.FieldApiName__c='Status__c';
           CurrentUpdate.NewValue__c=ReasonForChange;
           CurrentUpdate.FieldName__c='ReasonForChange';
           CurrentUpdateList.add(CurrentUpdate);
      
          insert CurrentUpdateList;
          system.debug('QC_DynamicObjectHandler reasonupdate  after insert' +CurrentUpdateList); 
     }
    }       
        return true;
        }    
      
     catch(Exception excep) {
            System.debug('-->Exception In Component_Handler:'+excep);
            Database.rollback(sp);
            ERR_Handler.processError(excep, ERR_Handler_API.Context.HEAD);
            return false;
        }
    
}   
    
    //End:Make doc current
    
 
   //Begin:Document Type Header 
    
    Public string doctype_id{get;set;}
    public list<Document_Type__c> doctypelist;
    
    public Document_Type__c getDocType() {
        
       if(doctype_id!=null && doctype_id!='')
       {
          if(doctypelist==null)
          {
          string doctypequerynames=QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c','Id,Name,Owner.Name,Status__c,createdDate,Business_Unit__c,Initiating_Site__r.Name,Followers__c,isEditable__c '); 
           system.debug('doctype values' +doctypequerynames);
           if(doctypequerynames!=null && doctypequerynames!='') 
           {
           doctypelist=Database.query(' select ' + doctypequerynames + ' from Document_Type__c where id = :doctype_id limit 1');   
            system.debug('doctype list values' +doctypelist);                  
               
           }              
          }                     
       }
        
  return (doctypelist==null || doctypelist.isEmpty())? new Document_Type__c():doctypelist[0];        
        
   }
       
  @RemoteAction
  public static Integer followDocumentType(String docid,String userId){
       try{
        return DocumentTypeControllerExt.followdocumentType(docid,userId);
       }
       catch(Exception ex){
          return -1;
       }
       return 0;
   }
   
    @RemoteAction
   public static Integer unfollowDocumentType(String docid,String userId){
       try{
          return DocumentTypeControllerExt.unfollowDocumentType(docid,userId);
       }
       catch(Exception ex){
          return -1;
       }   
   }  
    
   //End:Document type header    
    
    
    //Begin : wizard_steps
    
    public transient Object generic_object{Get; Set;}
    public transient integer step_number {Get; Set;}
    public transient List<String> createdTasks{get;set;}
    public transient Step closureStep{get;set;}
    public transient Step referenceStep{get;set;}
    public transient Integer adhocTaskSize{get;set;}
    public transient String adhocTaskContent{get;set;}
    public transient String genericTaskActiveClass{get;set;}
    public transient List<String> adhocTasks{get;set;}
    public transient String detailsLink{get;set;}
    public String module{get;set;}
    public class step{
        public String active_class {Get; Set;}
        public String label_text {Get; Set;}
        public boolean display_left_connector_line {Get; Set;}
        public String href_url {Get; Set;}
        public String inside_text {Get; Set;}
        public String statusMark{get;set;}
        public String tooltip{get;set;}
    }
    
   public List<step> getSteps() {
       List<step> steps;
       try{
        if (generic_object == null) {
            return null;
        }
        if (generic_object instanceof Non_Conformance__c) {
            module='NC';
            Non_Conformance__c specific_object = (Non_Conformance__c)generic_object;
            steps = getSteps_Non_Conformance();
            if(specific_object!=null && specific_object.NC_Resolution_Code__c!=null && specific_object.NC_Resolution_Code__c.equalsIgnoreCase('NC Workflow') && (specific_object.NC_Status__c.equalsIgnoreCase('NC Workflow') || specific_object.NC_Status__c.equalsIgnoreCase('Closed') || specific_object.NC_Status__c.equalsIgnoreCase('Void') || specific_object.NC_Status__c.equalsIgnoreCase('Reopened')) &&adhocTasks!=null){
               adhocTaskContent=getAdhocTasks(specific_object.Id);
            }
            System.debug('wizard_steps getSteps NC adhocTaskContent   '+adhocTaskContent);
            detailsLink='/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_details';
        } else if (generic_object instanceof CAPA__c) {
            module='CAPA';
            CAPA__c specific_object = (CAPA__c)generic_object;
            steps = getSteps_CAPA();
            
            system.debug('specific_object'+specific_object.CAPA_Status__c);
            if(specific_object!=null && specific_object.Resolution_Code__c!=null && specific_object.Resolution_Code__c.equalsIgnoreCase('CAPA Workflow') && (specific_object.CAPA_Status__c.equalsIgnoreCase('Inworks') || specific_object.CAPA_Status__c.equalsIgnoreCase('Closed') || specific_object.CAPA_Status__c.equalsIgnoreCase('Void') || specific_object.CAPA_Status__c.equalsIgnoreCase('Reopened')) &&adhocTasks!=null){
               adhocTaskContent=getAdhocTasks(specific_object.Id);
            }
            System.debug('wizard_steps getSteps CAPA adhocTaskContent   '+adhocTaskContent);
            detailsLink='/apex/CAPA?id=' + specific_object.Id+'&pg=capa_details';
        } 
           ////////////////v1.1.10 start
           else if (generic_object instanceof Change_Management__c) {
            module='ChangeManagement';
            Change_Management__c specific_object = (Change_Management__c)generic_object;
            steps = getSteps_Change_Management();
            
            system.debug(' ChangeManagement specific_object '+specific_object.Status__c+'   specific_object.Status__c   '+specific_object.Status__c+'  adhocTasks'+adhocTasks);
            system.debug(' ChangeManagement specific_object.Resolution_Code__c '+specific_object.Resolution_Code__c);
            if(specific_object!=null && specific_object.Resolution_Code__c!=null && specific_object.Resolution_Code__c.equalsIgnoreCase('Document Change Order') && (specific_object.Status__c.equalsIgnoreCase('Document Change Order')|| (specific_object.Status__c.equalsIgnoreCase('Closed') || specific_object.Status__c.equalsIgnoreCase('Void') || specific_object.Status__c.equalsIgnoreCase('Reopened')) &&adhocTasks!=null)){
                
                adhocTaskContent=getAdhocTasks(specific_object.Id);
                system.debug('adhocTaskContent.....'+adhocTaskContent);
            }
            System.debug(' ChangeManagement wizard_steps getSteps ChangeManagement adhocTaskContent   '+adhocTaskContent);
            detailsLink='/apex/ChangeManagement?id=' + specific_object.Id+'&pg=cr_details';
        } 
           /////////////////v1.1.10 end
       }catch(Exception ex){
           System.debug('Exception In Component_Handler getSteps()  '+ex.getMessage());
       }
        
        
        return steps;
    }
    
    private String getAdhocTasks(Id specificObjectId){
        String[] adhocTaskDetails;
        String adhocTaskData='<small class="wiz-dropdown">';//'<small><a href='#'>Task 1</a> <br> Task 2 <br> <a href='#'>Task 3</a> <br> <a href='#'>Task 4</a> <br> <a href='#'>Task 5</a> <br></small>';
        genericTaskActiveClass='gray-back';
        boolean allAdhocTasksCompleted=true;
        String adhocTaskIcon='';
        String page;//=(module=='NC')?'nc_task':'capa_task';
        try{
            //v1.1.10 start
            if(module=='NC'){
                page = 'nc_task';
            }else if(module=='CAPA'){
                page = 'capa_task';
            }else if(module=='ChangeManagement'){
                page = 'ChangeManagementtask';
            }
            //v1.1.10 end
            genericTaskActiveClass= (page=='ChangeManagementtask')?'gray':'gray-back';
            for(String adhocTaskDetail:adhocTasks){
              adhocTaskDetails=adhocTaskDetail.split('@');
              if(adhocTaskDetails[3]=='Open'){
                adhocTaskIcon='<i class="fa fa-circle blue"></i>&nbsp;';
                if(adhocTaskDetails[4] != null && adhocTaskDetails[4].contains('999999')){
                      adhocTaskIcon='<i class="fa fa-circle red"></i>&nbsp;';
                     
                }
                else if(adhocTaskDetails[4] != null && adhocTaskDetails[4].contains('99999')){
                      adhocTaskIcon='<i class="fa fa-circle gray"></i>&nbsp;';
                      
                }
                  
                 //adhocTaskData+='<a href="/apex/nc_adhoctask?id='+specific_object.Id+'&gtid='+adhocTaskDetails[2]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
                 adhocTaskData+='<a href="/apex/'+page+'?id='+specificObjectId+'&gtid='+adhocTaskDetails[2]+'&type='+adhocTaskDetails[0]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
                 genericTaskActiveClass= (page=='ChangeManagementtask')?'blue':'blue-back';
                 allAdhocTasksCompleted=false;
              }
              else if(adhocTaskDetails[3]=='Pending Approval'){
                 adhocTaskIcon='<i class="fa fa-circle yellow"></i>&nbsp;';
                 adhocTaskData+='<a href="/apex/'+page+'?id='+specificObjectId+'&gtid='+adhocTaskDetails[2]+'&type='+adhocTaskDetails[0]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
                 genericTaskActiveClass=(page=='ChangeManagementtask')?'blue':'blue-back';
                 allAdhocTasksCompleted=false;
              }
              else if(adhocTaskDetails[3]=='Created'){
                 adhocTaskIcon='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                 adhocTaskData+='<a href="/apex/'+page+'?id='+specificObjectId+'&gtid='+adhocTaskDetails[2]+'&type='+adhocTaskDetails[0]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
                 allAdhocTasksCompleted=false;
              }
              else if(adhocTaskDetails[3]=='Closed'){
                 adhocTaskIcon=('Yes'==adhocTaskDetails[5])?'<i class="fa fa-circle green"></i>&nbsp;':'<i class="fa fa-check green"></i>&nbsp;';
                 adhocTaskData+='<a href="/apex/'+page+'?id='+specificObjectId+'&gtid='+adhocTaskDetails[2]+'&type='+adhocTaskDetails[0]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
              }
              else if(adhocTaskDetails[3]=='Void'){
                 adhocTaskIcon='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                 adhocTaskData+='<a href="/apex/'+page+'?id='+specificObjectId+'&gtid='+adhocTaskDetails[2]+'&type='+adhocTaskDetails[0]+'">'+adhocTaskIcon+adhocTaskDetails[1].escapeHtml4()+'</a><br>';
                 genericTaskActiveClass=(page=='ChangeManagementtask')?'gray':'gray-back';
                 allAdhocTasksCompleted=false;
              }
            }
            adhocTaskData+='</small>';
            if(allAdhocTasksCompleted){
              genericTaskActiveClass=(page=='ChangeManagementtask')?'green':'green-back';//'green-back';  
            }
            adhocTaskSize=this.adhocTasks.size();
            
        }
        catch(Exception ex){
            System.debug('Exception In getAdhocTasks  '+ex.getMessage());
            adhocTaskData='';
        }
        return adhocTaskData;
    }
    
    public List<step> getSteps_Non_Conformance() {
        List<step> steps = new List<step>();
        Non_Conformance__c specific_object = (Non_Conformance__c)generic_object;
        System.debug('getSteps_Non_Conformance  specific_object  '+specific_object);
        String ncStatus=specific_object.NC_Status__c;
        boolean status_closed = specific_object.NC_Status__c.equalsIgnoreCase('Closed')|| specific_object.NC_Status__c.equalsIgnoreCase('NC Workflow');
        step currentStep;
        
        // Step 1
        currentStep = new step();
        currentStep.active_class = 'gray-back';
        if(step_number >= 1 || ncStatus=='Reopened' ||ncStatus=='Open'){ currentStep.active_class = 'blue-back'; }
        if(status_closed) { currentStep.active_class = 'green-back'; }
        if('Void'.equalsIgnoreCase(ncStatus)){currentStep.active_class = 'gray-back';}
        currentStep.label_text = 'Initiation';
        currentStep.display_left_connector_line = false;
        currentStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_init';
        currentStep.inside_text = 'ico-initiation';
        steps.Add(currentStep);
        
        // Step 2
        currentStep = new step();
        currentStep.active_class = 'gray-back';
        if(step_number >= 2|| ncStatus=='Reopened' ||ncStatus=='Open') { currentStep.active_class = 'blue-back'; }
        if(status_closed) { currentStep.active_class = 'green-back'; }
        currentStep.label_text = 'Product';
        currentStep.display_left_connector_line = true;
        if( ((step_number >= 3 || ncStatus=='Reopened' ||ncStatus=='Open') && status_closed == false) || status_closed == true) {
            currentStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_products';   
        }
        if('Void'.equalsIgnoreCase(ncStatus)){currentStep.active_class = 'gray-back';currentStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_products';}
        currentStep.inside_text = 'ico-products';
        steps.Add(currentStep);
        
        // Step 3
        currentStep = new step();
        currentStep.active_class = 'gray-back';
        if (step_number >= 3|| ncStatus=='Reopened') { currentStep.active_class = 'blue-back'; }
        if( status_closed) { currentStep.active_class = 'green-back'; }
        currentStep.label_text = 'Resolution';
        currentStep.display_left_connector_line = true;
        if( ((step_number >= 3 || ncStatus=='Reopened') && status_closed == false) || status_closed == true) {
            currentStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_resolution'; 
        }
        if('Void'.equalsIgnoreCase(ncStatus)){currentStep.active_class = 'gray-back';currentStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_resolution';}
        currentStep.inside_text = 'ico-resolution';
        steps.Add(currentStep);
        
        //Reference
        referenceStep = new step();
        referenceStep.active_class = 'gray-back';
        if (step_number >= 3 || status_closed ) { referenceStep.active_class = 'blue-back'; }
        if( specific_object.NC_Status__c.equalsIgnoreCase('Closed')) { referenceStep.active_class = 'green-back'; }
        referenceStep.label_text = 'Reference';
        referenceStep.display_left_connector_line = true;
        if( (step_number >= 3 && status_closed == false) || status_closed == true) {
            referenceStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_reference';    
        }
        if('Void'.equalsIgnoreCase(ncStatus)){referenceStep.active_class = 'gray-back';referenceStep.href_url = '/apex/NonConformance?id=' + specific_object.Id+'&pg=nc_reference';}
        referenceStep.inside_text = 'ico-x-ref';
        
        Integer stepNum=3;
        String[] taskStatus;
        String insideIcon=null;
        if(specific_object!=null && specific_object.NC_Resolution_Code__c!=null && specific_object.NC_Resolution_Code__c.equalsIgnoreCase('NC Workflow') && createdTasks!=null){
          for(String taskDetail:createdTasks){
                System.debug('wizard_steps   getSteps_Non_Conformance taskDetail  '+taskDetail);
                taskStatus=taskDetail.split('@');
                stepNum++;
                currentStep = new step();
                currentStep.active_class = 'gray-back';
                if (stepNum==step_number||!taskStatus[1].equalsIgnoreCase('Created')) { 
                   if(taskStatus[1].equalsIgnoreCase('Open') || taskStatus[1].equalsIgnoreCase('Pending ActionPlan') || taskStatus[1].equalsIgnoreCase('Disposition Pending Completion')){
                        currentStep.active_class = 'blue-back';
                        if(taskStatus[2] != null && taskStatus[2].contains('999999')){
                          currentStep.statusMark='red';
                          currentStep.tooltip='Rejected';
                        }
                        else if(taskStatus[2] != null && taskStatus[2].contains('99999')){
                          currentStep.statusMark='gray';
                          currentStep.tooltip='Approval Stopped';
                        }
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Pending Approval')){
                      currentStep.active_class = 'blue-back';
                      currentStep.statusMark='yellow';
                      currentStep.tooltip='Approval Started';
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Closed')){
                      currentStep.active_class = 'blue-green';
                      currentStep.statusMark=(taskStatus[3]=='Yes')?'green':'';
                      currentStep.tooltip=(taskStatus[3]=='Yes')?'Approved':'Closed';
                    }
                    
                }
                insideIcon='ico-'+taskStatus[0].toLowerCase();
                currentStep.label_text = taskStatus[0];
                currentStep.display_left_connector_line = true;
                if(stepNum==step_number || taskStatus[1]!=null) {
                     currentStep.href_url = '/apex/nc_task?id=' + specific_object.Id+'&gtid='+taskStatus[4]+'&type='+taskStatus[0]; 
                }
                currentStep.inside_text =insideIcon;
                if('Closure'.equalsIgnoreCase(currentStep.label_text)){
                    closureStep=currentStep;
                }
                else{
                   steps.Add(currentStep);
                }
           }
        }
        stepNum++;
        System.debug('wizard_steps getSteps_Non_Conformance  stepNum   '+stepNum+'  step_number  '+step_number);
        
        System.debug('wizard_steps getSteps_Non_Conformance  steps   '+steps);
        return steps;
    }
    public List<step> getSteps_CAPA() {
       
        List<step> steps = new List<step>();
        try{
        CAPA__c specific_object = (CAPA__c)generic_object;
        system.debug('specific_object'+specific_object.CAPA_Status__c);
        String capaStatus=specific_object.CAPA_Status__c;
        boolean status_closed = specific_object.CAPA_Status__c.equalsIgnoreCase('Closed') || specific_object.CAPA_Status__c.equalsIgnoreCase('Inworks');
        step currentStep;
        String[] taskStatus;
        String insideIcon=null;
        // Step 1
        currentStep = new step();
        currentStep.active_class = 'gray-back';
        if(step_number >= 1){ currentStep.active_class = 'blue-back'; }
        if(status_closed) { currentStep.active_class = 'green-back'; }
        if('Void'.equalsIgnoreCase(capaStatus)){currentStep.active_class = 'gray-back';}
        currentStep.label_text = 'Initiation';
        currentStep.display_left_connector_line = false;
        currentStep.href_url = '/apex/CAPA?id=' + specific_object.Id+'&pg=capa_init';
        currentStep.inside_text = 'ico-initiation';
        steps.Add(currentStep);
        
        // Step 2
        currentStep = new step();
        currentStep.active_class = 'gray-back';
        if (step_number >= 2) { currentStep.active_class = 'blue-back'; }
        if( status_closed) { currentStep.active_class = 'green-back'; }
        currentStep.label_text = 'Resolution';
        currentStep.display_left_connector_line = true;
        if( (step_number >= 3 && status_closed == false) || status_closed == true) {
            currentStep.href_url = '/apex/CAPA?id=' + specific_object.Id+'&pg=capa_resolution'; 
        }
        if('Void'.equalsIgnoreCase(capaStatus)){currentStep.active_class = 'gray-back';currentStep.href_url = '/apex/capa_resolution?id=' + specific_object.Id+'&pg=capa_resolution';}
        currentStep.inside_text = 'ico-resolution';
        steps.Add(currentStep);
        
        //Reference
        referenceStep = new step();
        referenceStep.active_class = 'gray-back';
        if (step_number >= 3) { referenceStep.active_class = 'blue-back'; }
        if( specific_object.CAPA_Status__c.equalsIgnoreCase('Closed')) { referenceStep.active_class = 'green-back'; }
        referenceStep.label_text = 'Reference';
        referenceStep.display_left_connector_line = true;
        if( (step_number >= 3 && status_closed == false) || status_closed == true) {
            referenceStep.href_url = '/apex/CAPA?id=' + specific_object.Id+'&pg=capa_reference';    
        }
        if('Void'.equalsIgnoreCase(capaStatus)){referenceStep.active_class = 'gray-back';referenceStep.href_url = '/apex/CAPA?id=' + specific_object.Id+'&pg=capa_xreference';}
        referenceStep.inside_text = 'ico-x-ref';
        
        String pageName='';     
        Integer stepNum=2;
        if(specific_object!=null && specific_object.Resolution_Code__c!=null && specific_object.Resolution_Code__c.equalsIgnoreCase('CAPA Workflow') && createdTasks!=null){
          for(String taskDetail:createdTasks){
                taskStatus=taskDetail.split('@');
                stepNum++;
                currentStep = new step();
                currentStep.active_class = 'gray-back';
                if (stepNum==step_number||!taskStatus[1].equalsIgnoreCase('Created')) { 
                   if(taskStatus[1].equalsIgnoreCase('Open') || taskStatus[1].equalsIgnoreCase('Pending ActionPlan') || taskStatus[1].equalsIgnoreCase('Disposition Pending Completion')){
                        currentStep.active_class = 'blue-back';
                        if(taskStatus[2] != null && taskStatus[2].contains('999999')){
                          currentStep.statusMark='red';
                          currentStep.tooltip='Rejected';
                        }
                        else if(taskStatus[2] != null && taskStatus[2].contains('99999')){
                          currentStep.statusMark='gray';
                          currentStep.tooltip='Approval Stopped';
                        }
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Pending Approval')){
                      currentStep.active_class = 'blue-back';
                      currentStep.statusMark='yellow';
                      currentStep.tooltip='Approval Started';
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Closed')){
                      currentStep.active_class = 'blue-green';
                      currentStep.statusMark=(taskStatus[3]=='Yes')?'green':'';
                      currentStep.tooltip=(taskStatus[3]=='Yes')?'Approved':'Closed';
                    }
                    
                }
                insideIcon=('EffectivenessReview'.equalsIgnoreCase(taskStatus[0]))?'ico-eff-verification':'ico-'+taskStatus[0].toLowerCase();
                currentStep.label_text = 'EffectivenessReview'.equalsIgnoreCase(taskStatus[0])?'Effectiveness Review':taskStatus[0];
                currentStep.display_left_connector_line = true;
                if(stepNum==step_number || taskStatus[1]!=null) {
                     currentStep.href_url = '/apex/capa_task?id=' + specific_object.Id+'&gtid='+taskStatus[4]+'&type='+taskStatus[0];   
                }
                currentStep.inside_text =insideIcon;
                if('Closure'.equalsIgnoreCase(currentStep.label_text)){
                    closureStep=currentStep;
                }
                else{
                   steps.Add(currentStep);
                }
           }
        }
        }catch(Exception ex){
            System.debug('Exception In Component_Handler.getSteps_CAPA   '+ex.getMessage());
        }
        
        return steps;
    }
    
    /////////////////////////////////v1.1.10 start////////////////////////////////////////////////////////////
    public List<step> getSteps_Change_Management() {
        List<step> steps = new List<step>();
        Change_Management__c specific_object = (Change_Management__c)generic_object;
        System.debug('getSteps_Change_Management  specific_object  '+specific_object);
        String cmStatus=specific_object.Status__c;
        boolean status_closed = specific_object.Status__c.equalsIgnoreCase('Closed')|| specific_object.Status__c.equalsIgnoreCase('Document Change Order');
        step currentStep;
        
        // Step 1
        currentStep = new step();
        currentStep.active_class = 'gray';
        if(step_number >= 1 || cmStatus=='Reopened' ||cmStatus=='Open'){ currentStep.active_class = 'blue'; }
        if(status_closed) { currentStep.active_class = 'green'; }
        if('Void'.equalsIgnoreCase(cmStatus)){currentStep.active_class = 'gray';}
        currentStep.label_text = 'Change Request';
        currentStep.display_left_connector_line = false;
        currentStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=cr_init';
        currentStep.inside_text = 'icon doc-cr-init';
        steps.Add(currentStep);
        
        // Step 2
        currentStep = new step();
        currentStep.active_class = 'gray';
        if(step_number >= 2|| cmStatus=='Reopened' ||cmStatus=='Open') { currentStep.active_class = 'blue'; }
        if(status_closed) { currentStep.active_class = 'green'; }
        currentStep.label_text = 'Document Information';
        currentStep.display_left_connector_line = true;
        if( ((step_number >= 3 || cmStatus=='Reopened' ||cmStatus=='Open') && status_closed == false) || status_closed == true) {
            currentStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=doc_info';   
        }
        if('Void'.equalsIgnoreCase(cmStatus)){currentStep.active_class = 'gray';currentStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=doc_info';}
        currentStep.inside_text = 'icon doc-cr-doc-info';//icon doc-cr-doc-info
        steps.Add(currentStep);
        
        // Step 3
        currentStep = new step();
        currentStep.active_class = 'gray';
        if (step_number >= 3|| cmStatus=='Reopened') { currentStep.active_class = 'blue'; }
        if( status_closed) { currentStep.active_class = 'green'; }
        currentStep.label_text = 'Resolution';
        currentStep.display_left_connector_line = true;
        if( ((step_number >= 3 || cmStatus=='Reopened' ||cmStatus=='Open') && status_closed == false) || status_closed == true) {
            currentStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=cr_resolution'; 
        }
        if('Void'.equalsIgnoreCase(cmStatus)){currentStep.active_class = 'gray';currentStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=cr_resolution';}
        currentStep.inside_text = 'icon doc-cr-resolution';
        steps.Add(currentStep);
        
        //Reference
        /*referenceStep = new step();
        referenceStep.active_class = 'gray-back';
        if (step_number >= 3 || status_closed ) { referenceStep.active_class = 'blue-back'; }
        if( specific_object.Status__c.equalsIgnoreCase('Closed')) { referenceStep.active_class = 'green-back'; }
        referenceStep.label_text = 'Reference';
        referenceStep.display_left_connector_line = true;
        if( (step_number >= 3 && status_closed == false) || status_closed == true) {
            referenceStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=nc_reference';    
        }
        if('Void'.equalsIgnoreCase(cmStatus)){referenceStep.active_class = 'gray-back';referenceStep.href_url = '/apex/ChangeManagement?id=' + specific_object.Id+'&pg=nc_reference';}
        referenceStep.inside_text = 'ico-x-ref';*/
        
        Integer stepNum=3;
        String[] taskStatus;
        String insideIcon=null;
        System.debug('wizard_steps   getSteps_Change_Management specific_object  '+specific_object+'  specific_object.Resolution_Code__c'+specific_object.Resolution_Code__c);
        if(specific_object!=null && specific_object.Resolution_Code__c!=null && specific_object.Resolution_Code__c.equalsIgnoreCase('Document Change Order') && createdTasks!=null){
          for(String taskDetail:createdTasks){
                System.debug('wizard_steps   getSteps_Change_Management taskDetail  '+taskDetail);
                taskStatus=taskDetail.split('@');
                stepNum++;
                currentStep = new step();
                currentStep.active_class = 'gray';
                if (stepNum==step_number||!taskStatus[1].equalsIgnoreCase('Created')) { 
                   if(taskStatus[1].equalsIgnoreCase('Open') || taskStatus[1].equalsIgnoreCase('Pending Action Completion') ){
                        currentStep.active_class = 'blue';
                        if(taskStatus[2] != null && taskStatus[2].contains('999999')){
                          currentStep.statusMark='red';
                          currentStep.tooltip='Rejected';
                        }
                        else if(taskStatus[2] != null && taskStatus[2].contains('99999')){
                          currentStep.statusMark='gray';
                          currentStep.tooltip='Approval Stopped';
                        }
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Pending Approval')){
                      currentStep.active_class = 'blue';
                      currentStep.statusMark='yellow';
                      currentStep.tooltip='Approval Started';
                    }
                    else if(taskStatus[1].equalsIgnoreCase('Closed')){
                      currentStep.active_class = 'green';
                      currentStep.statusMark=(taskStatus[3]=='Yes')?'green':'';
                      currentStep.tooltip=(taskStatus[3]=='Yes')?'Approved':'Closed';
                    }
                    
                }
                insideIcon='icon doc-cr-change-task';//+taskStatus[0].toLowerCase();
                currentStep.label_text = taskStatus[0];
                currentStep.display_left_connector_line = true;
                system.debug('stepNum '+stepNum+'  step_number '+step_number+'  taskStatus[1]'+taskStatus[1]);
                if(stepNum==step_number || taskStatus[1]!=null) {
                     system.debug('sarath stepNum '+stepNum+'  step_number '+step_number+'  taskStatus[4]'+taskStatus[4]+' specific_object.Id'+specific_object.Id);
                     currentStep.href_url = '/apex/ChangeManagementTask?id=' + specific_object.Id+'&gtid='+taskStatus[4]+'&type='+taskStatus[0]; 
                }
                currentStep.inside_text =insideIcon;
                if('Closure'.equalsIgnoreCase(currentStep.label_text)){
                    closureStep=currentStep;
                }
                else{
                   steps.Add(currentStep);
                }
           }
        }
        stepNum++;
        System.debug('wizard_steps getSteps_Change_Management  stepNum   '+stepNum+'  step_number  '+step_number);
        
        System.debug('wizard_steps getSteps_Change_Management  steps   '+steps);
        return steps;
    }
    ///////////////////////////v1.1.10 end/////////////////////////////////////////////////////////////////////
    
    //End : wizard_steps
    
    //Begin : nc_audit
   
    public List<NC_History__c> getHistories(){
        
        String queryFieldSOfNCH = QC_DynamicObjectHandler.getAccessibleFields('NC_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Non_Conformance__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfNCH!= null && queryFieldSOfNCH!= ''){
            return database.query('Select '+ queryFieldSOfNCH +' From NC_History__c where Non_Conformance__c  =:ncid  ORDER BY CreatedDate DESC limit 1000');
        }
        else{
        return new List<NC_History__c>();    
        }
        
    }
    
    //End : nc_audit
    
    //Begin : capa_audit
    public id capaid{get;set;}
    public List<CAPA_History__c> getCAPAHistories(){
        String queryFieldSOfCAPAH = QC_DynamicObjectHandler.getAccessibleFields('CAPA_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,CAPA__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfCAPAH!= null && queryFieldSOfCAPAH!= ''){
            return database.query('Select '+ queryFieldSOfCAPAH +' From CAPA_History__c where CAPA__c  =:capaid  ORDER BY CreatedDate DESC limit 1000');
        }
        else{
        return new List<CAPA_History__c>();    
        }
    }
    //End : capa_audit
    
    
    // v1.1.8 Audit Start
    //Begin : Chanege Management audit
    public id cmid{get;set;}
    public List<Change_Management_History__c> getCMHistories(){
        String cmid=(this.cmid==null)?ApexPages.currentPage().getParameters().get('id'):this.cmid;
        String queryFieldSOfCMH = QC_DynamicObjectHandler.getAccessibleFields('Change_Management_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfCMH!= null && queryFieldSOfCMH!= ''){
            return database.query('Select '+ queryFieldSOfCMH +' From Change_Management_History__c where Parent__c  =:cmid  ORDER BY CreatedDate DESC limit 1000');
        }
        else{
        return new List<Change_Management_History__c>();    
        }
    }
    //End : Chanege Management audit
    
    //Begin : Document Type audit
    public id dtid{get;set;}
    public List<Document_Type_History__c> getDTHistories(){
        String dtid=(this.dtid==null)?ApexPages.currentPage().getParameters().get('id'):this.dtid;
        String queryFieldSOfDTH = QC_DynamicObjectHandler.getAccessibleFields('Document_Type_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfDTH!= null && queryFieldSOfDTH!= ''){
            return database.query('Select '+ queryFieldSOfDTH +' From Document_Type_History__c where Parent__c  =:dtid  ORDER BY CreatedDate DESC limit 1000');
        }
        else{
        return new List<Document_Type_History__c>();    
        }
    }
    //End : Document Type audit
    
     //Begin : Document Type audit
    public id dpid{get;set;}
    public List<Document_Profile_History__c> getDPHistories(){
        String dpid=(this.dpid==null)?ApexPages.currentPage().getParameters().get('id'):this.dpid;
        String queryFieldSOfDPH = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfDPH!= null && queryFieldSOfDPH!= ''){
            return database.query('Select '+ queryFieldSOfDPH +' From Document_Profile_History__c where Parent__c  =:dpid  ORDER BY CreatedDate DESC limit 1000');
        }
        else{
        return new List<Document_Profile_History__c>();    
        }
    }
    //End : Document Type audit
    // v1.1.8 Audit End
     
     
    //Begin : wiz_approvalHistory
    public id objectId{get;set;}
    
    
    Public Map<id,ProcessDefinition> PDs{get;set;}
    public List<ProcessInstance> getApprovalHistory(){
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,OriginalActorId,CreatedDate ,actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,ProcessDefinitionId,SubmittedById, CreatedById , Status');
        system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus,OriginalActorId ,CreatedDate , Comments,Actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
            system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            system.debug('inside processInstances if');
        List<ProcessInstance> processInstances;
        ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems ORDER BY CreatedDate DESC),( Select '+ queryFieldSOfPs +' from Steps ORDER BY CreatedDate DESC ) FROM ProcessInstance where TargetObjectId =:Objectid ORDER BY CreatedDate DESC limit 1000'); 
        
            set<id> pdids=new set<id>();
            set<id> userids=new set<id>();
            for(ProcessInstance pi:ProcessInstances){
                pdids.add(pi.ProcessDefinitionId);
                userids.add(pi.SubmittedById);
                userids.add(pi.CreatedById);
                for(ProcessInstanceWorkitem wi:pi.Workitems){
                userids.add(wi.OriginalActorId);
                userids.add(wi.actorid);                    
                }
                for(ProcessInstanceStep iS:pi.Steps){
                userids.add(iS.OriginalActorId);
                userids.add(iS.Actorid);                    
                }                
            }
            String queryFieldSOfPIds = QC_DynamicObjectHandler.getAccessibleFields('ProcessDefinition', 'Id,DeveloperName,');
            if(queryFieldSOfPIds!=null&&queryFieldSOfPIds!=''){
            //v1.1.11        start
                List<ProcessDefinition> PDlist=database.query('Select  Id,Name,DeveloperName from ProcessDefinition Where Id IN:pdids'); 
            //  List<ProcessDefinition> PDlist=[Select  Id,DeveloperName from ProcessDefinition Where Id IN:pdids];
            //v1.1.11        end     
                PDs=new Map<id,ProcessDefinition>(PDlist);
            }
            
            User=new Map<id,User>();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'id,Name');            
            if(queryFieldNames != null && queryFieldNames != '')
            {
                String qry='select ' + queryFieldNames + ' FROM User where id in:userids';
                LIST<User> ulist=database.query (qry);
                User.putAll(ulist);                
            }
            
            return ProcessInstances;
        }
        return new List<ProcessInstance>();
    }
    
    //Begin : wiz_approvalHistory
    
    
    //Begin : GetRiskPriorityData
    
        // Justification for "...FROM Risk_Lookup__c LIMIT 1000]" in each SOQL statement
    // Limits on  the queries are based on the following assumptions
    // 1. The Risk_Severity object contains no more than 10 records
    // 2. The Risk_Occurrence object contains no more than 10 records
    // When those two assumptions are met the maximum number of records in Risk_Lookup is 100
    // This number number is multiplied by 10 to add a safety margin
    
    @RemoteAction
    public static Map<ID, Map<ID, ID>> getRiskPriorityGrid(){
        try{
            Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = new Map<ID, Map<ID, ID>>();
           
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Lookup__c','Id,Severity_Level__c,Occurrence_Probability__c,Risk_Priority__c');
                
           // For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c FROM Risk_Lookup__c LIMIT 1000]) {
            if(queryFieldNames != null && queryFieldNames != '')
            {
                  For(Risk_Lookup__c riskLookup : database.query('SELECT '+ queryFieldNames +' FROM Risk_Lookup__c LIMIT 1000')) 
                  {
                    if (Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c) == null) 
                    {
                        Severity_to_Occurrences_map.put(riskLookup.Severity_Level__c, new Map<ID, ID>{riskLookup.Occurrence_Probability__c => riskLookup.Risk_Priority__c});
                    }
                    else
                    {
                        Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
                    }
                 }
            }
            return Severity_to_Occurrences_map;
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.RISK);
            return null;
        }
    }
    
    @RemoteAction
    public static Map<ID, Map<ID, String>> getRiskPriorityNameGrid(){
        try{
            Map<ID, Map<ID, String>> Severity_to_Occurrences_map = new Map<ID, Map<ID, String>>();
            
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Lookup__c','Id,Severity_Level__c,Occurrence_Probability__c,Risk_Priority__c,Risk_Priority__r.Name');
            if(queryFieldNames != null && queryFieldNames != '')
            {
            //For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c, Risk_Priority__r.Name FROM Risk_Lookup__c LIMIT 1000]) {
                For(Risk_Lookup__c riskLookup : database.query('SELECT '+ queryFieldNames +' FROM Risk_Lookup__c LIMIT 1000')) 
                {
                    if (Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c) == null) 
                    {
                        Severity_to_Occurrences_map.put(riskLookup.Severity_Level__c, new Map<ID, String>{riskLookup.Occurrence_Probability__c => riskLookup.Risk_Priority__r.Name});
                    }
                    else
                    {
                        Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__r.Name);
                    }
                }
            }
            return Severity_to_Occurrences_map;         
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.RISK);
            return null;
        }       
    }
    
    @RemoteAction
    public static Map<ID, Map<ID, Risk_Priority__c>> getRiskPriorityGridAll(){
        try{
            String table = 'Risk_Priority__c';
            String query_string = 'SELECT ';
            List<String> table_list = new List<String>();
            table_list.add(table);
            
            Set<String> table_rows = schema.describeSObjects(table_list)[0].fields.getMap().keyset();
            for(String row : table_rows){
                query_string += row + ',';
            }
            query_string = query_string.removeEnd(','); //remove trailing comma
            query_string += ' FROM ' + table;
            
            Map<ID, Risk_Priority__c> riskPriorities = new Map<ID, Risk_Priority__c>((List<Risk_Priority__c>)Database.query(query_string));
            
    
            
            Map<ID, Map<ID, Risk_Priority__c>> Severity_to_Occurrences_map = new Map<ID, Map<ID, Risk_Priority__c>>();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Lookup__c','Id,Severity_Level__c,Occurrence_Probability__c,Risk_Priority__c');
            
            if(queryFieldNames != null && queryFieldNames != '')
            {
           // For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c FROM Risk_Lookup__c LIMIT 1000]) {
                  For(Risk_Lookup__c riskLookup : database.query('SELECT '+ queryFieldNames +' FROM Risk_Lookup__c LIMIT 1000')) 
                  {
                    if (Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c) == null) 
                    {
                        Severity_to_Occurrences_map.put(riskLookup.Severity_Level__c, new Map<ID, Risk_Priority__c>
                        {
                            riskLookup.Occurrence_Probability__c => riskPriorities.get(riskLookup.Risk_Priority__c)
                        });
                    }
                    else
                    {
                        Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskPriorities.get(riskLookup.Risk_Priority__c));
                    }
                 }
            }
            return Severity_to_Occurrences_map;
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.RISK);
            return null;
        }                
    }  
    
    public static void TriggerMethod(List<Non_Conformance__c> nclist){
        try{
            // TODO: The method needs to be able to conditionally consider Risk Detection as a third input to the Risk Priority lookup.
            //Map<ID, Map<ID, Map<ID, ID>>> Risk_Lookup_map_WITH_detection = new Map<ID, Map<ID, Map<ID, ID>>>();
            
            Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = getRiskPriorityGrid();

            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Lookup__c','Id,Severity_Level__c,Occurrence_Probability__c,Risk_Priority__c');
            
            if(queryFieldNames != null && queryFieldNames != '')
            {
                    For(Risk_Lookup__c riskLookup : database.query('SELECT '+ queryFieldNames +' FROM Risk_Lookup__c LIMIT 1000')) 
                    {
                        Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
                    }
                    
                    For (Non_Conformance__c parent : nclist)
                    {
                        if (Severity_to_Occurrences_map.get(parent.Risk_Severity__c) != null) 
                        {
                            parent.Risk_Priority__c = Severity_to_Occurrences_map.get(parent.Risk_Severity__c).get(parent.Risk_Occurrence__c);
                        }
                    }
            }
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.RISK);
        }       
    }
    //End : GetRiskPriorityData
    //v1.1.2 start
     @RemoteAction 
    public static boolean updateDocTypeActiveDeactiveStatus(string recordid,String deActiveDocTypeReason,string status){ 
        Savepoint sp = Database.setSavepoint();
        try{
            
            //Document_Type__c docType = new Document_Type__c();
            system.debug('Remoting values are deActiveDocTypeReason'+deActiveDocTypeReason+'status'+status+'recordid'+recordid);
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c','id,Status__c,Reason__c ');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<Document_Type__c> doctypelist = database.query('Select '+ queryFieldNames + ' From Document_Type__c where id = :recordid limit 1');
                //docType = doctypelist[0];
                for(Document_Type__c dts:doctypelist){
                    if(status == 'Active'){
                        dts.Status__c = 'Inactive';
                    }else{
                        dts.Status__c = 'Active';
                    }
                    dts.Reason__c = deActiveDocTypeReason;
                }
                
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type__c','Status__c,Reason__c', 'update')){
                    update doctypelist;
                }
                
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type_History__c','NewValue__c,Object__c,FieldName__c,FieldApiName__c,Parent__c,Sub_Parent__c', 'update')){
                    List<Document_Type_History__c> dtupdateList=new List<Document_Type_History__c>();
                    Document_Type_History__c docupdate = new Document_Type_History__c();
                    docupdate.Parent__c =recordid ;
                    docupdate.NewValue__c = deActiveDocTypeReason;
                    docupdate.Object__c = 'Document_Type__c';
                    docupdate.FieldApiName__c='Status__c';
                    docupdate.FieldName__c='Reason';
                     
                    system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                    dtupdateList.add(docupdate);
                    
                    insert dtupdateList;
                }
            }
            return true;
        }catch(Exception ex){
            Database.rollback(sp);
            System.debug('Exception In FileAttachmentController updateAttachments   '+ex.getMessage());
            return false;
        }
    }
    //v1.1.2 end
    
    @RemoteAction
     public static string cloneRecord(string curPageId){
        
        
        Document_Type__c dtobj = new Document_Type__c();
        
         Savepoint sp; 
        try{
            
     String queryFieldSOfDoc = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'id,isEditable__c');
       
        if(queryFieldSOfDoc!= null && queryFieldSOfDoc!= ''){
            
        dtobj=database.query('SELECT '+queryFieldSOfDoc+' FROM Document_Type__c WHERE Id=:curPageId');
        
        
        dtobj.isEditable__c=false;
        
        upsert dtobj; 
        
        return curPageId;
            
        }
        }
        catch(exception ex){
        
         Database.rollback(sp);
         System.debug('Exception In Component_Handler.deleteContainmentAction  '+ex.getMessage());        
        
       
       }
        
        
        
        
     return null;
     }
    
     
    
    //v1.1.3 start
    @RemoteAction 
    public static boolean voidDocumentProfile(string recordid,String voidReason){
        Savepoint sp = Database.setSavepoint();
        
        try 
        {
            System.debug('-->voidDocumentProfile.recordid'+recordid+'   voidReason'+voidReason);
            Document_Profile__c docProfile =new Document_Profile__c();
            List<general_task__c> genTasks;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','id,Status__c ');
            List<Document_Profile__c> docProfileList = database.query('Select '+ queryFieldNames +' from Document_Profile__c where id = :recordid limit 1');
            docProfile = docProfileList [0];
            docProfile.Status__c = 'Void';
            
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Status__c', 'update')){
                String queryFieldNamesDPGt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Document_Profile__c,status__c,recordtypeid,recordtype.Name');
                if(queryFieldNamesDPGt != null && queryFieldNamesDPGt != ''){
                    genTasks= database.query('Select '+ queryFieldNamesDPGt +' from General_Task__c where Document_Profile__c=:recordid Limit 100');  
                    for(general_task__c genTask:genTasks){
                        genTask.status__c='Void';
                    }
                    System.debug('-->Update genTask');
                    update genTasks;
                }  
                System.debug('-->Update docProfile'+docProfile.Status__c); 
                update docProfile;
                System.debug('-->Update docProfile'+docProfile.Status__c); 
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','NewValue__c,Object__c,FieldName__c,FieldApiName__c', 'update')){
                    List<Document_Profile_History__c> voidupdateList=new List<Document_Profile_History__c>();
                    Document_Profile_History__c voidupdate = new Document_Profile_History__c();
                    voidupdate.Parent__c =recordid ;
                    voidupdate.NewValue__c = voidReason;
                    voidupdate.Object__c = 'Document_Profile__c';
                    voidupdate.FieldApiName__c='Status__c';
                    voidupdate.FieldName__c='VoidReason';
                    //voidupdate.Parent__c='Resolution'; 
                    system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                    voidupdateList.add(voidupdate);
                    Document_Profile_History__c voidupdategen;
                    for(General_Task__c genTask:genTasks){
                        voidupdategen = new Document_Profile_History__c();
                        voidupdategen.Parent__c =recordid ;
                        voidupdategen.NewValue__c = voidReason;
                        voidupdategen.Object__c = 'General_Task__c';
                        voidupdategen.FieldApiName__c='Status__c';
                        voidupdategen.FieldName__c='VoidReason';
                        voidupdategen.Sub_Parent__c=genTask.RecordType.Name; 
                        voidupdateList.add(voidupdategen);                           
                    }
                    
                    insert voidupdateList;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                }
                
                
            }
            
            
            return true;
            
        }
        catch(Exception e) {
            System.debug('-->Exception In Component_Handler.VoidNC:'+e);
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }
        
    }
    //v1.1.3 end
    //v1.1.3 end
    //v1.1.4 start
     @Remoteaction
    public static boolean reopenChngMngmntTasks(Map<String,List<String>> tasks,Map<String,String> chngMgmtData,String reasonforreopen){
        
        set<Id> taskIds = new set<Id>();
        if(!tasks.isEmpty()){
            for( String rc : tasks.keySet()){
                taskIds.add(rc.split('@')[1]);
                system.debug(rc.split('@')[1]);   
            }
            
            System.debug('!taskIds.isEmpty()------------->'+taskIds.isEmpty());
                if(!taskIds.isEmpty()){
                  
                     //Non_Conformance__c nc = getNCRecord(ncid);
                    
                    List<General_Task__c> gTasks;
                    try{
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,RecordType.Name,Due_Date__c,Sequence_Position__c,Change_Management__c,Allowed_Days__c,Status__c,Task_Reopen_Date__c,Task_Reopen_By__c');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            String gtqry='SELECT ' + queryFieldNames + ' FROM General_Task__c WHERE Id IN :taskIds';
                        
                            gTasks= database.query (gtqry);
                        } 
                        System.debug('gTasks to update------------------>'+gTasks);
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopenCAPATasks.update generaltask---->  '+ex.getMessage());
                    }  
                    
                    List<Change_Management_History__c> cmHistories=new List<Change_Management_History__c>();
                    Change_Management_History__c history;
                    
                    Integer minSeq=1000;
                    Integer actSeq=0;
                    Map<Integer,List<General_Task__c>> tasksWithSequence=new Map<Integer,List<General_Task__c>>(); 
                    List<General_Task__c> taskList=null;
                    
                    
                    for(General_Task__c gt : gTasks ){
                        
                        gt.Status__c='Created';
                         system.debug('tasksWithSequence.Integer.valueOf(gt.Sequence_Position__c)'+Integer.valueOf(gt.Sequence_Position__c));
                        system.debug('tasksWithSequence.Integer.valueOf(gt.Allowed_Days__c))'+Integer.valueOf(gt.Allowed_Days__c));
                        actSeq=Integer.valueOf(gt.Sequence_Position__c);
                        if(actSeq<minSeq){
                            minSeq=actSeq;
                        }
                        //gt.Status__c = 'Open';
                        gt.Due_Date__c = Date.today()+Integer.valueOf(gt.Allowed_Days__c);
                        gt.Task_Reopen_Date__c = Date.today();
                        gt.Task_Reopen_By__c = UserInfo.getUserId();
                        //
                        //
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','FieldApiName__c,NewValue__c,Object__c,FieldName__c', 'update'))
                            {
                                history=new Change_Management_History__c();
                                history.Parent__c =gt.CAPA__c;
                                history.NewValue__c = reasonforreopen;
                                history.Object__c = 'General_Task__c';
                                history.FieldApiName__c='Status__c';
                                history.FieldName__c='ReopenReason';
                                history.Sub_Parent__c = gt.RecordType.Name;
                                system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                                cmHistories.add(history);
                                system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                            }
                        //
                        //
                        system.debug('tasksWithSequence.tasklist'+tasksWithSequence.get(actSeq));
                    taskList=tasksWithSequence.get(actSeq);
                        if(taskList==null){
                            taskList=new List<General_Task__c>();
                            tasksWithSequence.put(actSeq,taskList);
                        }
                        taskList.add(gt);
                        
                        
                    }
                    
                    for(General_Task__c seqTask : tasksWithSequence.get(minSeq)){
                          seqTask.Status__c='Open';
                    }
                        
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,Due_Date__c,Task_Reopen_Date__c,Task_Reopen_By__c', 'update'))
                        {
                            update gTasks;
                            system.debug('cmHistories QC_DynamicObjectHandler reasonupdate before insert Genetic tasks'+gTasks[0].Status__c);
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,FieldName__c','create')){
                            insert cmHistories;
                            }
                        }
                        System.debug('**end of update of general tasks**');
                   
                    
                } 
             //--TODO - Set Closure task status to diabled--//
               
                if((!taskIds.isEmpty()||chngMgmtData.get('Resolution_Code__c')=='DocumentRecord')){
                    String closureTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,RecordType.Name,Status__c,Change_Management__c,CurrentApprovalSequenceNumber__c');
                    Id cmid = chngMgmtData.get('chngMgmtid');
                    List<General_Task__c> cTask;
                    try{
                        if(closureTaskFields != null && closureTaskFields != '')
                        {
                            String closureqry='SELECT '+ closureTaskFields+' FROM General_Task__c where Change_Management__c =: cmid and RecordType.Name = \'Closure\' limit 1';
                            cTask = database.query(closureqry);
                             System.debug('closure object======>'+cTask);
                        }
                        
                    }catch(Exception ex){
                        System.debug('Exception In Component_Handler.reopen ChangemanagementTasks  '+ex.getMessage());
                    }
                    for(General_Task__c ct : cTask ){
                        ct.Status__c = 'Created';
                        ct.CurrentApprovalSequenceNumber__c=0;
                    } 
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,CurrentApprovalSequenceNumber__c', 'update')){
                        update cTask; 
                    } 
                    
                } 
                
                ID recordid = chngMgmtData.get('chngMgmtid');
                String chngmngmntstatus = chngMgmtData.get('Status__c');
                String resolutioncode = chngMgmtData.get('Resolution_Code__c');
                if(chngmngmntstatus =='Closed'){
                    Change_Management__c chmgobj = new Change_Management__c();
                    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c','id,Status__c,Resolution_Code__c ');
                    if(queryFieldNames != null && queryFieldNames != '')
                    {
                        List<Change_Management__c> chmgList = database.query('Select '+ queryFieldNames +' from Change_Management__c where id = :recordid limit 1');
                         chmgobj = chmgList [0];
                        if(chngmngmntstatus == 'Closed' ){
                             system.debug('<---------resolutioncode  != Document Change Order chngmngmntstatus == Closed------------->');
                            chmgobj.Status__c = 'Document Change Order';
                            //chmgobj.Resolution_Code__c = resolutioncode;
                        //}
                        //else if(resolutioncode == 'Document Change Order' && chngmngmntstatus == 'Closed'){
                        //    system.debug('<---------resolutioncode == Document Change Order && chngmngmntstatus == Closed------------->');
                        //    chmgobj.Status__c = 'Document Change Order';
                        //    chmgobj.Resolution_Code__c = 'Document Change Order';
                        }  
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Status__c,Resolution_Code__c', 'update'))
                        {
                            update chmgobj;
                         }
                    }
                    
                }
            
           
            //---TODO--REOPEN NC IF No TASKS ARE THERE 
            
        }
        return true; 
    }
    //v1.1.4 end
    
    //v1.1.5 start
    
    //Begin : ChangeManagement_chronology
    
    public id cmcid{get;set;}
    public Map<Date,cm_history> chronology_cm{get;set;}
    public set<Date> getCMHistoryDate(){ 
        system.debug('inside for getHistoryDate');
        set<Date> chronologyDate=new set<Date>();
        String queryFieldSOfCMH = QC_DynamicObjectHandler.getAccessibleFields('Change_Management_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfCMH!= null && queryFieldSOfCMH!= ''){            
            
            system.debug('if(queryFieldSOfCMH!= null && queryFieldSOfCMH!'+cmcid);
            //List<Change_Management_History__c> nhs=new List<Change_Management_History__c>();
            cm_history history;
            chronology_cm=new  Map<Date , cm_history>();
            for(Change_Management_History__c cmh: database.query('Select '+ queryFieldSOfCMH +' From Change_Management_History__c where Parent__c =:cmcid Order By CreatedDate DESC ')){  
  
                system.debug('inside for loop Chronology');
                if(chronology_cm.get(cmh.CreatedDate.Date())!=null){  
                               if(cmh.Object__c=='Change_Management__c'){
                                    if(cmh.Sub_Parent__c=='Resolution'){
                                        chronology_cm.get(cmh.CreatedDate.Date()).resolution.add(cmh); 
                                    }
                                    else{
                                        chronology_cm.get(cmh.CreatedDate.Date()).init.add(cmh); 
                                    }                  
                                }
                                else if(cmh.Object__c=='Sub_Change_Management__c'){
                                    system.debug('inside for loop Chronology2 '+cmh.Object__c);
                                    chronology_cm.get(cmh.CreatedDate.Date()).DocumentInfo.add(cmh); 
                                                      
                                }                       
                                else if(cmh.Object__c=='General_Sub_Task__c'||cmh.Object__c=='General_Task__c'||cmh.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(cmh.Sub_Parent__c=='DocumentChange')
                                    {                    
                                        chronology_cm.get(cmh.CreatedDate.Date()).DocumentChange.add(cmh); 
                                    }   
                                    //else if(cmh.Sub_Parent__c=='CompleteActionPlan')
                                    //{               
                                    //    chronology_cm.get(cmh.CreatedDate.Date()).CompleteActionPlan.add(cmh); 
                                    //} 
                                    else if(cmh.Sub_Parent__c=='Closure')
                                    {               
                                        chronology_cm.get(cmh.CreatedDate.Date()).Closure.add(cmh); 
                                    }   
                                    else if(cmh.Sub_Parent__c=='AdhocTask'||cmh.Sub_Parent__c=='AdhocTask Actions')
                                    {                   
                                        chronology_cm.get(cmh.CreatedDate.Date()).Adhoc.add(cmh); 
                                    }
                                     
                                    
                                }                     
                }
                else{
                    history=new cm_history();   
                    history.currentDate=cmh.CreatedDate.Date();
                    history.init=new List<Change_Management_History__c>(); 
                    history.DocumentInfo=new List<Change_Management_History__c>(); 
                    history.resolution=new List<Change_Management_History__c>(); 
                    history.DocumentChange=new List<Change_Management_History__c>(); 
                    //history.CompleteActionPlan=new List<Change_Management_History__c>(); 
                    history.Adhoc=new List<Change_Management_History__c>(); 
                    history.Closure=new List<Change_Management_History__c>(); 
                    
                    
                                    
 
                                    
                               if(cmh.Object__c=='Change_Management__c'){
                                    if(cmh.Sub_Parent__c=='Resolution'){
                                        history.resolution.add(cmh);
                                    }
                                    else{
                                        history.init.add(cmh);
                                    }                  
                                }
                                else if(cmh.Object__c=='Sub_Change_Management__c'){
                                        history.DocumentInfo.add(cmh);
                                }    
                                else if(cmh.Object__c=='General_Task__c'){
                                    if(cmh.Sub_Parent__c=='DocumentChange')
                                    {                    
                                        history.DocumentChange.add(cmh);
                                    }  
                                    //else if(cmh.Sub_Parent__c=='CompleteActionPlan')
                                    //{               
                                    //    history.CompleteActionPlan.add(cmh);
                                    //}
                                    else if(cmh.Sub_Parent__c=='Closure')
                                    {               
                                        history.Closure.add(cmh);
                                    }   
                                    else if(cmh.Sub_Parent__c=='AdhocTask'||cmh.Sub_Parent__c=='AdhocTask Actions')
                                    {                   
                                        history.Adhoc.add(cmh);
                                    }                                    
                                    
                                } 
                                    
                                chronology_cm.put(cmh.CreatedDate.Date(),history);                                                     
                        }
                
                
            
            chronologyDate.addAll(chronology_cm.keySet());
            //chronologyDate.sort();

            }
            
                   
            
           return chronologyDate;  
        }
        else{
        return new set<Date>();    
        }
        system.debug('outside for loop Chronology');
        return new set<Date>(); 
    }
    
    
    
    
    public class cm_history{
        public date currentDate{get;set;}
        public List<Change_Management_History__c> init{get;set;}
        public List<Change_Management_History__c> DocumentInfo{get;set;}
        public List<Change_Management_History__c> resolution{get;set;}
        public List<Change_Management_History__c> DocumentChange{get;set;}
        //public List<Change_Management_History__c> CompleteActionPlan{get;set;}
        public List<Change_Management_History__c> Adhoc{get;set;}
        public List<Change_Management_History__c> Closure{get;set;}
        
    }
    //End : ChangeManagement_chronology
    
    //Begin : DocumentType_chronology
    public id dtcid{get;set;}
    public Map<Date,doctype_history> chronology_dt{get;set;}
    public set<Date> getDTHistoryDate(){ 
        system.debug('inside for getHistoryDate');
        set<Date> chronologyDate=new set<Date>();
        String queryFieldSOfDTH = QC_DynamicObjectHandler.getAccessibleFields('Document_Type_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfDTH!= null && queryFieldSOfDTH!= ''){            
            
            system.debug('if(queryFieldSOfDTH!= null && queryFieldSOfDTH!'+dtcid);
            //List<Document_Type_History__c> nhs=new List<Document_Type_History__c>();
            doctype_history history;
            chronology_dt=new  Map<Date , doctype_history>();
            for(Document_Type_History__c cmh: database.query('Select '+ queryFieldSOfDTH +' From Document_Type_History__c where Parent__c =:dtcid Order By CreatedDate DESC ')){  
  
                system.debug('inside for loop Chronology');
                if(chronology_dt.get(cmh.CreatedDate.Date())!=null){  
                               if(cmh.Object__c=='Document_Type__c'){
                                    if(cmh.Sub_Parent__c=='Security'){
                                        chronology_dt.get(cmh.CreatedDate.Date()).security.add(cmh); 
                                    }
                                    else{
                                        chronology_dt.get(cmh.CreatedDate.Date()).Details.add(cmh); 
                                    }                  
                                }                       
                                                    
                }
                else{
                    history=new doctype_history();   
                    history.currentDate=cmh.CreatedDate.Date();
                    history.Details=new List<Document_Type_History__c>(); 
                    history.security=new List<Document_Type_History__c>(); 
                    
                    
                                    
 
                                    
                               if(cmh.Object__c=='Change_Management__c'){
                                    if(cmh.Sub_Parent__c=='Security'){
                                        history.security.add(cmh);
                                    }
                                    else{
                                        history.Details.add(cmh);
                                    }                  
                                }                       
                                                                    
                                chronology_dt.put(cmh.CreatedDate.Date(),history);                                                     
                        }
                
                
            
            chronologyDate.addAll(chronology_dt.keySet());
            

            }
            
           return chronologyDate;  
        }
        else{
        return new set<Date>();    
        }
        system.debug('outside for loop Chronology');
        return new set<Date>(); 
    }
    
    
    
    
    public class doctype_history{
        public date currentDate{get;set;}
        public List<Document_Type_History__c> Details{get;set;}
        public List<Document_Type_History__c> security{get;set;} 
        
    }
    
    //End : Document_Type_chronology
     //Begin : DocumentProfile_chronology
    
    public id dpcid{get;set;}
    public Map<Date,dp_history> chronology_dp{get;set;}
    public set<Date> getDPHistoryDate(){ 
        system.debug('inside for getHistoryDate');
        set<Date> chronologyDate=new set<Date>();
        String queryFieldSOfDPH = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile_History__c', 'FieldName__c,isDeleted__c,Description__c ,Object__c,Parent__c,isCreated__c,Sub_Parent__c,OldValue__c,NewValue__c,CreatedDate,CreatedById,CreatedBy.Name');
        if(queryFieldSOfDPH!= null && queryFieldSOfDPH!= ''){            
            
            system.debug('if(queryFieldSOfDPH!= null && queryFieldSOfDPH!'+dpcid);
            //List<Document_Profile_History__c> nhs=new List<Document_Profile_History__c>();
            dp_history history;
            chronology_dp=new  Map<Date , dp_history>();
            for(Document_Profile_History__c dph: database.query('Select '+ queryFieldSOfDPH +' From Document_Profile_History__c where Parent__c =:dpcid Order By CreatedDate DESC ')){  
  
                system.debug('inside for loop Chronology');
                if(chronology_dp.get(dph.CreatedDate.Date())!=null){  
                               if(dph.Object__c=='Document_Profile__c'){
                                    if(dph.Sub_Parent__c=='DocumentDetails'){
                                        chronology_dp.get(dph.CreatedDate.Date()).DocumentDetails.add(dph); 
                                    }
                                    else{
                                        chronology_dp.get(dph.CreatedDate.Date()).init.add(dph); 
                                    }  
                                    if(dph.Sub_Parent__c=='Security'){
                                        chronology_dp.get(dph.CreatedDate.Date()).Security.add(dph); 
                                    }
                                }                       
                                else if(dph.Object__c=='General_Sub_Task__c'||dph.Object__c=='General_Task__c'||dph.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(dph.Sub_Parent__c=='EffectivenessReview')
                                    {                    
                                        chronology_dp.get(dph.CreatedDate.Date()).EffectivenessReview.add(dph); 
                                    }   
                                    if(dph.Sub_Parent__c=='CollaborationReview')
                                    {                    
                                        chronology_dp.get(dph.CreatedDate.Date()).CollaborationReview.add(dph); 
                                    }
                                   
                                     
                                    
                                }                     
                }
                else{
                    history=new dp_history();   
                    history.currentDate=dph.CreatedDate.Date();
                    history.init=new List<Document_Profile_History__c>(); 
                    history.DocumentDetails=new List<Document_Profile_History__c>();
                    history.Security=new List<Document_Profile_History__c>(); 
                    history.EffectivenessReview=new List<Document_Profile_History__c>();
                    history.CollaborationReview=new List<Document_Profile_History__c>();
                    
                    
                    
                                    
 
                                    
                               if(dph.Object__c=='Document_Profile__c'){
                                    if(dph.Sub_Parent__c=='Resolution'){
                                        history.DocumentDetails.add(dph);
                                    }
                                    else{
                                        history.init.add(dph);
                                    }  
                                    if(dph.Sub_Parent__c=='Security'){
                                        history.Security.add(dph);
                                    }
                                }                       
                                else if(dph.Object__c=='General_Sub_Task__c'||dph.Object__c=='General_Task__c'||dph.Object__c=='Disposition_Product__c'||dph.Object__c=='Action_Plan_Root_Cause__c'){
                                    if(dph.Sub_Parent__c=='EffectivenessReview')
                                    {                    
                                        history.EffectivenessReview.add(dph);
                                    }   
                                    if(dph.Sub_Parent__c=='CollaborationReview')
                                    {                    
                                        history.CollaborationReview.add(dph);
                                    } 
                                                                     
                                    
                                } 
                                    
                                chronology_dp.put(dph.CreatedDate.Date(),history);                                                     
                        }
                
                
            
            chronologyDate.addAll(chronology_dp.keySet());
            

            }
            
                   
            
           return chronologyDate;  
        }
        else{
        return new set<Date>();    
        }
        system.debug('outside for loop Chronology');
        return new set<Date>(); 
    }
    
    
    
    
    public class dp_history{
        public date currentDate{get;set;}
        public List<Document_Profile_History__c> init{get;set;}
        public List<Document_Profile_History__c> DocumentDetails{get;set;}
        public List<Document_Profile_History__c> Security{get;set;}
        public List<Document_Profile_History__c> EffectivenessReview{get;set;}
        public List<Document_Profile_History__c> CollaborationReview{get;set;}
        
        
    }
    //End : DocumentProfile_chronology
    
    
    //v1.1.5 end
    //v1.1.6 cr_details start
    public List<Sub_Change_Management__c> getDocuments(){
        try{
           ChangeManagementControllerExt chmg =new ChangeManagementControllerExt(); 
           chmg.cmid=this.documentChange.Change_Management__r.id;
           return chmg.getDocuments();
        }catch(Exception ex){
          System.debug('Exception In Component_Handler.getDocumentList  '+ex.getMessage());
          return null;
        }
    }
    
    public List<Document_Profile__c> getDocs(){
        try{
           ChangeManagementControllerExt chmg =new ChangeManagementControllerExt();
           chmg.cmid=this.documentChange.Change_Management__r.id;
           return chmg.getDocs(); 
        }catch(Exception ex){
          System.debug('Exception In Component_Handler.getDocumentList  '+ex.getMessage());
          return null;
        }
    
    }
 //v1.1.6 cr_details end
     //==========written by balu start
    @RemoteAction 
    public static sObject getRecord(id recordid){
        sobject record;
        string fieldsToReturn='';
        Schema.SObjectType token = recordid.getSObjectType();
        system.debug('inside getRecord '+token);
        system.debug('inside getRecord '+string.valueOf(token));
        
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(string.valueOf(token) ).getDescribe().fields.getMap();
        for( String fieldName : fieldMap.keySet() ) {
            if(fieldsToReturn != '') {
                fieldsToReturn += ', ';
            }
            fieldsToReturn += fieldName;
            Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
            String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
            if (relationshipName != null && relationshipName.endsWith('__r')) {
                fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
            }
        }
        
        fieldsToReturn += ', Owner.Name, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
        
        // Build query string
        String selectAllFieldsForNC = '';
        selectAllFieldsForNC += 'select ' + fieldsToReturn + ' from '+string.valueOf(token)+' where id = \'' + recordid + '\' limit 1';
        system.debug('Query is: ' + selectAllFieldsForNC);
        record = database.query(selectAllFieldsForNC);        
        return record;
        
    }
    public transient Id DocumentTypeId{get;set;}
    public Document_Type__c documentType{get{
                system.debug('inside getdocumentType DocumentTypeId'+DocumentTypeId);
        return (Document_Type__c)getRecord(DocumentTypeId);
        
    }set;}
   /* public Document_Type__c getdocumentType(){
        system.debug('inside getdocumentType DocumentTypeId'+DocumentTypeId);
        return (Document_Type__c)getRecord(DocumentTypeId);
    }*/
    public string ApplicableRegulations{get{
        Schema.DescribeFieldResult fieldResult = Document_Profile__c.Applicable_Regulations__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        ApplicableRegulations='';
        for( Schema.PicklistEntry f : ple){
            ApplicableRegulations+= f.getValue()+',';
        }  
        return ApplicableRegulations;
    }set;}
    public id ProfileId{get;set;}
    public List<Manufacturing_Site__c> ImpactedSites{get{  
        system.debug('inside impacted sites');
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
    //  v1.1.9 start
     @RemoteAction
    public static Integer saveWizApprovalData(Map<String,List<String>> approvalDetails,id recordid,Boolean isSubmitForApproval){
        System.debug('Component_Handler.saveApprovalData  approvalDetails   '+approvalDetails);
        Savepoint sp;
        try{
            List<Approver__c> existingApprovers=null;
            List <SObject> sObjects=null;
            
            Schema.SObjectType token = recordid.getSObjectType();
            
            System.debug('component handler   token  '+token+'string.valueOf(token)'+string.valueOf(token));
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields(string.valueOf(token), 'Id,Allowed_Days__c,Note_To_Approver__c,OwnerId');
            if(queryFieldNames != null && queryFieldNames != ''){
                sObjects=Database.query('SELECT '+queryFieldNames+' FROM '+string.valueOf(token)+' WHERE Id=:recordid LIMIT 1');
                List<String> approvalNote=approvalDetails.get('Approval_Note');
                for(sObject record : sObjects){
                    System.debug('ApprovalController.saveApprovalData  task  '+record);
                    record.put('Note_To_Approver__c', (approvalNote==null)?null:approvalNote[0]);
                    record.put('Approval_Required__c',true);
                    record.put('Approver__c', record.get('OwnerId'));
                }
            }
            else{
                System.debug('Component_Handler.saveApprovalData  : No Acesss to object  General_Task__c and fields genTasks '+queryFieldNames);
            }
            queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,General_Task__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE '+string.valueOf(token)+' = : recordid');
            }
            else{
                System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
            }
            
            List<Approver__c> approvers=new List<Approver__c>();
            
            String[] details;
            List<String> approvalData=approvalDetails.get('Approval');
            if(approvalData.size()>Integer.valueOf(QC_custom_settings.getMaxApprovers())){
                System.debug('Cannot Have More Than 5 Approvers');
                return -1;
            }
            Approver__c approver;
            List<Id> approverIds =new List<Id>();
            Integer sequence=10000; 
            for(String approverDetail : approvalData){
                details=approverDetail.split('@');
                approver=new Approver__c();
                approver.Sequence_Position__c=Integer.valueOf(details[0]);
                approver.User__c=details[1];
                approver.Allowed_Days__c=Integer.valueOf(details[2]);
                DateTime dt = DateTime.newInstance(long.valueOf(details[3]));
                //dt=dt.addDays(1);
                system.debug('inside date approver +'+dt);
                approver.Due_Date__c=dt.date(); 
                if(string.valueOf(token)=='General_Task__c'){
                    approver.General_Task__c=recordid;
                }else if(string.valueOf(token)=='Document_Profile__c'){
                    system.debug('inside if Document_Profile__c '+string.valueOf(token));
                    approver.Document_Profile__c=recordid;
                }
                approvers.add(approver);
                if(sequence==Integer.valueOf(details[0])){
                    approverIds.add(details[1]); 
                }
                else if(sequence>Integer.valueOf(details[0])){
                    approverIds.clear();
                    sequence=Integer.valueOf(details[0]);
                    approverIds.add(details[1]);
                }
            }
            sp = Database.setSavepoint();
            if(sObjects!=null && !sObjects.isEmpty()){
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess(string.valueOf(token),'Note_To_Approver__c','update')){
                    update sObjects;
                }
                else{
                    System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for genTasks ');
                }
            } 
            if(existingApprovers!=null && !existingApprovers.isEmpty()){
                if(Approver__c.sObjectType.getDescribe().isDeletable()){
                    delete existingApprovers;
                }
                else{
                    System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers');
                }
            }
            if(!approvers.isEmpty()){
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Approver__c','Sequence_Position__c,User__c,Allowed_Days__c,Due_Date__c,General_Task__c','create')){
                    insert approvers;
                }
                else{
                    System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for insert Approvers');
                }
            }
            if(isSubmitForApproval){
                List<string> approverNote=approvalDetails.get('Approval_Note');
                DynsubmitForApproval(recordid,approverIds,sequence,(approverNote==null)?null:approverNote[0]);
            }
            return 0;
        }catch(Exception ex){
            System.debug('Exception In Component_Handler.saveApprovalData   '+ex.getMessage());
            Database.rollback(sp);
            return -1;
        }
    }
    public static void DynsubmitForApproval(id recordid,list<id> approverIds,Integer sequence,string comments){
        Schema.SObjectType token = recordid.getSObjectType();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields(string.valueOf(token), 'id,Approver__c,Initial_Submitter__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c');
        sobject obj=Database.query('SELECT '+queryFieldNames+' FROM '+string.valueOf(token)+' WHERE Id=:recordid LIMIT 1');
        Integer len=approverIds.size();
        Integer i=1;
        obj.put('Approver__c', approverIds[len-1]);i++;
        obj.put('Approver_1__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_2__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_3__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_4__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_5__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_6__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_7__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_8__c', approverIds[((len-i>0)?len-i:0)]);i++;
        obj.put('Approver_9__c', approverIds[((len-i>0)?len-i:0)]);
        // GT.Note_To_Approver__c=approvalNote[0]; 
        obj.put('Initial_Submitter__c', UserInfo.getUserId());
        obj.put('CurrentApprovalSequenceNumber__c',sequence)  ;
        update obj;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        // req.setProcessDefinitionNameOrId('ContainmentTask');
        req.setComments(comments);
        // req.setSkipEntryCriteria(true);
        req.setObjectId(recordid);
        req.setSubmitterId(UserInfo.getUserId());
        Approval.ProcessResult results = Approval.process(req); 
        
        
    }
    @RemoteAction
    public static Map<String,List<String>>getDynApprovalData(id recordid,String typeofapprover){
        List<String> data=null;
        Schema.SObjectType token = recordid.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = token.getDescribe(); //describe the sobject
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields(string.valueOf(token), 'Sequence__c');
        if(queryFieldNames != null && queryFieldNames != ''){
            
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Sequence__c').getDescribe().getPickListValues(); 
            
            //  Schema.DescribeFieldResult fieldResult = token.Sequence__c.getDescribe();
            //    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            data =new List<String>();
            for( Schema.PicklistEntry f : pick_list_values){
                data.add(f.getValue());
            }
            dataMap.put('seqs',data);
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  General_Task__c and fields for sequence '+queryFieldNames);
        }
        queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        //creating a set for holding set of ids of users present in the nc approval group
        Set<id> approvergroupid=new set<id>();  
        
        string approvalaccessiable=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName'); //Added this for overcoming the field level security while creating managed package
        
        if(approvalaccessiable!=null && approvalaccessiable!='') {
            set<id> UserSetid=new set<id>();           
            group groupid1=Database.query(' select '  + approvalaccessiable +   ' from Group where DeveloperName =:typeofapprover ');   
            UserSetid.add(groupid1.id);
            vfsearch.FinaluserIDSet=new set<id>();
            vfsearch.getUserIds(UserSetid);  
            approvergroupid.addAll(vfsearch.FinaluserIDSet);         
        }
        
        if(queryFieldNames != null && queryFieldNames != ''){
            List<User> users=Database.query('SELECT ' + queryFieldNames + ' FROM User WHERE id IN:approvergroupid ORDER BY Id limit 100');
            data =new List<String>();
            for(User user : users){
                data.add(user.Id+'@'+user.Name);
            }
            dataMap.put('usrs',data);
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  General_Task__c and fields for users '+queryFieldNames);
        }
        if(!String.isEmpty(recordid) && recordid!=null){                     // v1.1 qualityze Inc (SB)     21-jul-2016  added check for approval data
            queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,User__r.Name,General_Task__c,General_Task__r.Note_To_Approver__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                List<Approver__c> approvers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE '+string.valueOf(token)+' = : recordid ORDER BY ID');
                data=new List<String>();
                for(Approver__c approver : approvers ){
                    data.add(approver.Id+'@'+approver.Sequence_Position__c+'@'+approver.Allowed_Days__c+'@'+approver.Due_Date__c+'@'+approver.User__c+'@'+approver.User__r.Name+'@'+approver.General_Task__c+'@'+approver.General_Task__r.Note_To_Approver__c);
                }
                dataMap.put('apprs',data);
            }
            else{
                System.debug('Component_Handler.getApprovalData  : No Acesss to object  Approver__c and fields for approvers '+queryFieldNames);
            }
        }
        return dataMap; 
    }
     @RemoteAction
    public static Boolean DelApprovalData(id recordid){
    string ObjName;
    Schema.SObjectType token = recordid.getSObjectType();
    Savepoint sp;   
    try{
        sp = Database.setSavepoint();
        String queryFieldSOfNCC = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id');
        if(queryFieldSOfNCC!= null && queryFieldSOfNCC!= ''){
              List<Approver__c> CAS = database.query('Select '+ queryFieldSOfNCC +' From  Approver__c where '+ string.valueOf(token)+' = :recordid');
              if(CAS.size() > 0){
                if(Approver__c.sObjectType.getDescribe().isDeletable()){
                    delete CAS;
                }
              }
        }
        return true;
    }
    catch(exception ex){
      Database.rollback(sp);
      System.debug('Exception In Component_Handler.getDynDelApprovalData  '+ex.getMessage());        
      return false;
    }
    }   
    //  v1.1.9 end
    //==========written by balu end
    
    //v1.1.7 start
     @RemoteAction
    public static List<ContentVersion> populateContentVersions(String contentVersionId ) {
        if(String.isNotBlank(contentVersionId) && contentVersionId!=null){
          return fillContentVersions(contentVersionId);
        }
        return new List<ContentVersion>();
    }
   private static List<ContentVersion> fillContentVersions(String versionId) {
        List<ContentVersion>  latestContentVersion;
        String queryFields=QC_DynamicObjectHandler.getAccessibleFields('ContentVersion', 'Id, Title, Description,FileType,ContentDocumentId,Owner.Name,VersionNumber,PathOnClient,FileExtension,CreatedDate');
        String queryFieldsCD=QC_DynamicObjectHandler.getAccessibleFields('ContentDocument', 'Id');
        if(queryFields!=null && queryFields!='' && queryFieldsCD!=null && queryFieldsCD!=''){
           latestContentVersion= Database.query('SELECT '+queryFields+' from ContentVersion WHERE ContentDocumentId IN (SELECT '+queryFieldsCD+' FROM ContentDocument WHERE LatestPublishedVersionId=:versionId) ORDER BY CreatedDate DESC LIMIT 1');
        }
        return latestContentVersion;
   }
  //v1.1.7 end
  //
  @RemoteAction
    public static Integer saveGtApprovalData(Map<String,List<String>> approvalDetails,String taskId,Boolean isSubmitForApproval){
        System.debug('Component_Handler.saveApprovalData  approvalDetails   '+approvalDetails);
        Savepoint sp;
        try{
         List<Approver__c> existingApprovers=null;
         List <General_task__c> genTasks=null;
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_task__c', 'Id,Due_Date__c,Note_To_Approver__c,OwnerId');
         if(queryFieldNames != null && queryFieldNames != ''){
             genTasks=Database.query('SELECT '+queryFieldNames+' General_task__c WHERE Id=:taskId LIMIT 1');
             List<String> approvalNote=approvalDetails.get('Approval_Note');
             for(General_task__c task : genTasks){
                 System.debug('ApprovalController.saveApprovalData  task  '+task);
                 task.Note_To_Approver__c=(approvalNote==null)?null:approvalNote[0];
                 task.Approval_Required__c='Yes';
                 task.Approver__c=task.OwnerId;
             }
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Change_Management__c and fields genTasks '+queryFieldNames);
         }
         queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,General_task__c');
         if(queryFieldNames != null && queryFieldNames != ''){
            existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_task__c = : taskId');
         }
         else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
         }
         
         List<Approver__c> approvers=new List<Approver__c>();
       
         String[] details;
         List<String> approvalData=approvalDetails.get('Approval');
         if(approvalData.size()>Integer.valueOf(QC_custom_settings.getMaxApprovers())){
             System.debug('Cannot Have More Than 5 Approvers');
             return -1;
         }
         Approver__c approver;
         List<Id> approverIds =new List<Id>();
         Integer sequence=10000; 
         for(String approverDetail : approvalData){
             details=approverDetail.split('@');
             approver=new Approver__c();
             approver.Sequence_Position__c=Integer.valueOf(details[0]);
             approver.User__c=details[1];
             approver.Allowed_Days__c=Integer.valueOf(details[2]);
             approver.Due_Date__c=Date.parse(details[3]);
             approver.general_task__c=taskId;
             system.debug(taskId+'taskId');
             approvers.add(approver);
             if(sequence==Integer.valueOf(details[0])){
                approverIds.add(details[1]); 
             }
             else if(sequence>Integer.valueOf(details[0])){
                 approverIds.clear();
                 sequence=Integer.valueOf(details[0]);
                 approverIds.add(details[1]);
            }
         }
         sp = Database.setSavepoint();
         if(genTasks!=null && !genTasks.isEmpty()){
           if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_task__c','Note_To_Approver__c','update')){
                    update genTasks;
           }
           else{
             System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for genTasks ');
           }
         } 
         if(existingApprovers!=null && !existingApprovers.isEmpty()){
            if(Approver__c.sObjectType.getDescribe().isDeletable()){
                   delete existingApprovers;
            }
            else{
              System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for existingApprovers');
            }
         }
         if(!approvers.isEmpty()){
          if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Approver__c','Sequence_Position__c,User__c,Allowed_Days__c,Due_Date__c,General_task__c','create')){
            insert approvers;
          }
          else{
            System.debug('Component_Handler.saveApprovalData  : No Acesss to object  Approver__c and fields for insert Approvers');
          }
         }
         if(isSubmitForApproval){
         List<string> approverNote=approvalDetails.get('Approval_Note');
             system.debug('submit for approval'+approverNote);
                 submitCrForApproval(taskId,approverIds,sequence,(approverNote==null)?null:approverNote[0]);
         }
         return 0;
        }catch(Exception ex){
            System.debug('Exception In Component_Handler.saveApprovalData   '+ex.getMessage());
            Database.rollback(sp);
            return -1;
        }
    }
    @RemoteAction
   public static Map<String,List<String>>getGtApprovalData(String taskId,String typeofapprover){
        List<String> data=null;
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_task__c', 'Sequence__c');
        if(queryFieldNames != null && queryFieldNames != ''){
                Schema.DescribeFieldResult fieldResult = General_Task__c.Sequence__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
                data =new List<String>();
                for( Schema.PicklistEntry f : ple){
                    data.add(f.getValue());
                } 
                dataMap.put('sequences',data);
             System.debug('valueofdatamap'+dataMap);
        }
        else{
               System.debug('Component_Handler.getApprovalData  : No Acesss to object  Change_Management__c and fields for sequence '+queryFieldNames);
        }
        queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        //creating a set for holding set of ids of users present in the nc approval group
        Set<id> approvergroupid=new set<id>();  
        
        System.debug('approvergroupid'+approvergroupid);
        
        string approvalaccessiable=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName'); //Added this for overcoming the field level security while creating managed package
       
        
        
        if(approvalaccessiable!=null && approvalaccessiable!='') {
            set<id> UserSetid=new set<id>();           
            group groupid1=Database.query(' select '  + approvalaccessiable +   ' from Group where DeveloperName =:typeofapprover ');   
            UserSetid.add(groupid1.id);
            vfsearch.FinaluserIDSet=new set<id>();
            vfsearch.getUserIds(UserSetid);  
            approvergroupid.addAll(vfsearch.FinaluserIDSet);    
            
        }
        
        if(queryFieldNames != null && queryFieldNames != ''){
            List<User> users=Database.query('SELECT ' + queryFieldNames + ' FROM User WHERE id IN:approvergroupid ORDER BY Id limit 100');
            data =new List<String>();
            for(User user : users){
                data.add(user.Id+'@'+user.Name);
            }
            dataMap.put('usersdata',data);
            
        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  Change_Management__c and fields for users '+queryFieldNames);
        }
       
        queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,User__r.Name,General_task__c,General_Task__r.Note_To_Approver__c');
        if(queryFieldNames != null && queryFieldNames != ''){
            List<Approver__c> approvers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_Task__c = : taskId ORDER BY ID');
            data=new List<String>();
            for(Approver__c approver : approvers ){
                data.add(approver.Id+'@'+approver.Sequence_Position__c+'@'+approver.Allowed_Days__c+'@'+approver.Due_Date__c+'@'+approver.User__c+'@'+approver.User__r.Name+'@'+approver.General_Task__c+'@'+approver.General_task__r.Note_To_Approver__c);
            }
             dataMap.put('approversData',data);
             System.debug('valueofdatamap2'+dataMap);

        }
        else{
            System.debug('Component_Handler.getApprovalData  : No Acesss to object  Approver__c and fields for approvers '+queryFieldNames);
        }
        return dataMap; 
       
       
   }
    
   /*----------Document Revise and Temp story(Start)-------------*/
       @RemoteAction
    public static string revisecheck(string r,string r2){
         Document_Profile__c  copyRevision;
         Document_Profile__c rcheck = new Document_Profile__c();
        string RevisionField='';
   // Document_Profile__c rcheck=[select id,isRevise__c,isTempRevise__c from Document_Profile__c where Id =: r];
        
        String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,isRevise__c,isTempRevise__c');
        system.debug('Accessible fields'+queryFieldNames1);
        if(queryFieldNames1 != null && queryFieldNames1 != '')
        {
         rcheck = database.query ('select ' + queryFieldNames1 + ' from Document_Profile__c where Id =: r');
        }
        system.debug('values revised' + rcheck);
       
        if(rcheck.isRevise__c ){
             return 'true';          
        }else{
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Current_Rev__c,Id,Name');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            copyRevision = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Name =: r2 ORDER BY CreatedDate DESC LIMIT 1');
        }
        
       if(copyRevision!=null){
         RevisionField = copyRevision.Current_Rev__c;
        system.debug('value of REVISION FIELD' +RevisionField);  
        }
        else{
            copyRevision = new Document_Profile__c();
        }
            
            
            return 'false'+'-'+RevisionField;
            
        }
    }
    
    
       @RemoteAction
    public static string tempcheck(string r,string r2){
        Document_Profile__c  copyRevision;
        Document_Profile__c tcheck = new Document_Profile__c();
        string RevisionField='';
    //Document_Profile__c tcheck=[select id,isTempRevise__c from Document_Profile__c where Id =: r];
        
        String queryFieldNames1 = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,isRevise__c,isTempRevise__c');
        system.debug('Accessible fields'+queryFieldNames1);
        if(queryFieldNames1 != null && queryFieldNames1 != '')
        {
         tcheck = database.query ('select ' + queryFieldNames1 + ' from Document_Profile__c where Id =: r');
        }
        system.debug('values revised' + tcheck);
        
        
        if(tcheck.isTempRevise__c){
             return 'true';          
        }else{
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Current_Rev__c,Id,Name');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            copyRevision = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Name =: r2 ORDER BY CreatedDate DESC LIMIT 1');
        }
        
       if(copyRevision!=null){
         RevisionField = copyRevision.Current_Rev__c;
        system.debug('value of REVISION FIELD' +RevisionField);  
        }
        else{
            copyRevision = new Document_Profile__c();
        }
            
            
            return 'false'+'-'+RevisionField;
            
        }
    }
    
    
    
    @RemoteAction
    public static string revise(string r3,string next){
        Document_Profile__c AuthEntity = new Document_Profile__c();
        List<DocumentJunction__c> docJunList = new List<DocumentJunction__c>();
        List<DocumentJunction__c> newdocJunList = new List<DocumentJunction__c>();
        Set<String> contentVersionIdSet=new Set<String>();
       system.debug('qqq'+r3);
        system.debug('qq1'+next);
        //AuthEntity = [select Id,name,status__c,Current_Rev__c from Document_Profile__c where Id =: r3  LIMIT 1];
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,Approved_Date__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c');
        //String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','Action_Status__c,Allowed_Days__c,ApprovalProcess__c,Approval_Required__c,Approval_Status__c,Approved_Date__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver__c,Automatically_Expire_Previous_Revision__c,Business_Unit__c,Categories__c,Change_Management__c,Closed_Date__c,Current_Rev__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Specific_Changes__c,Document_Status__c,Document_Type__c,Effective_Date__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Initiating_Site__c,IsDeleted,isTemp__c,Left_vertically__c,Name,Name__c,New_Owner__c,New_Rev__c,Note_To_Approver__c,Numbering_Scheme__c,Pre_Release_Duration_Date__c,Process__c,Product__c,Protected_Draft__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,isRevise__c,Right_vertically__c,Secondary_Format__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Supersede_Previous_Revision__c,SystemModstamp,Title__c,Type__c,UD_Date__c,UD_Picklist__c,UD_RichText__c,UD_Text__c,Valid_Duration__c,Watermark_Text__c');
        system.debug('ZZZZZZZ'+queryFieldNames);
        if(queryFieldNames != null && queryFieldNames != '')
        {
            AuthEntity = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Id =: r3  LIMIT 1');
        }
        system.debug('values revised' + AuthEntity);
               Document_Profile__c documentProfile = AuthEntity.clone(false, true, false, false);
        system.debug('ssssssss' +documentProfile);
        AuthEntity.isRevise__c = True;
        //update AuthEntity;
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,Document_Name__c,Document_Type__c,Status__c,isRevise__c','update')){
                   update AuthEntity;
        }
        else{
                        System.debug('DocumentProfileControllerExt REVISE Button Update Original: No Acesss to object  Document_Profile__c');
                     }
        documentProfile.Status__c = 'Draft';
        documentProfile.Current_Rev__c = next;
        documentProfile.isRevise__c = False;
        
        contentVersionIdSet.add(AuthEntity.ContentVersionId__c);
        contentVersionIdSet.add(AuthEntity.SecondaryContentVersionId__c);
        Map<String,List<String>> revisedContentVersions = reviseContentDocument(contentVersionIdSet);
        List<String> contentVersions=null;
        for(String orginalContentVersionId:revisedContentVersions.keySet()){
        	contentVersions=revisedContentVersions.get(orginalContentVersionId);
        	if(orginalContentVersionId==AuthEntity.ContentVersionId__c){
        		documentProfile.ContentVersionId__c=contentVersions[0];
        		documentProfile.ContentDocumentId__c=contentVersions[1];
        	}
        	else if(orginalContentVersionId==AuthEntity.SecondaryContentVersionId__c){
        	    documentProfile.SecondaryContentVersionId__c=contentVersions[0];
        	    documentProfile.SecondaryContentDocumentId__c=contentVersions[1];
        	}
        }
        
        System.debug('Component_Handler.revise   revisedContentVersions '+revisedContentVersions);
        //insert documentProfile;
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,Document_Name__c,Document_Type__c,Status__c','create')){
                   insert documentProfile;
        }
        else{
                        System.debug('DocumentProfileControllerExt REVISE Button Insert Revised: No Acesss to object  Document_Profile__c');
                     }
        system.debug('ssssssss1' +documentProfile.Id);

         return documentProfile.Id;
    }
    
    @RemoteAction
    public static string temp(string rid,string next){
        Document_Profile__c AuthEntity = new Document_Profile__c();
        Set<String> contentVersionIdSet=new Set<String>();
        //AuthEntity = [select Id,name,status__c,Current_Rev__c,TempStop__c from Document_Profile__c where Id =: rid  LIMIT 1];
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,Approved_Date__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Approver__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            AuthEntity = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Id =: rid  LIMIT 1');
        }
        system.debug('values revised' + AuthEntity.Name);
        Document_Profile__c documentProfile = AuthEntity.clone(false, true, false, false);
        AuthEntity.isTempRevise__c = True;
        //update copyvar1;
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,isTempRevise__c,Document_Name__c,Document_Type__c,Status__c,isRevise__c','update')){
                   update AuthEntity;
        }
        else{
                        System.debug('DocumentProfileControllerExt REVISE Button Update Original: No Acesss to object  Document_Profile__c');
                     }
        documentProfile.Status__c = 'Draft';
        documentProfile.Current_Rev__c = next;
        documentProfile.isTemp__c = True;
        documentProfile.isTempRevise__c = False; 
         contentVersionIdSet.add(AuthEntity.ContentVersionId__c);
        contentVersionIdSet.add(AuthEntity.SecondaryContentVersionId__c);
        Map<String,List<String>> revisedContentVersions = reviseContentDocument(contentVersionIdSet);
        List<String> contentVersions=null;
        for(String orginalContentVersionId:revisedContentVersions.keySet()){
        	contentVersions=revisedContentVersions.get(orginalContentVersionId);
        	if(orginalContentVersionId==AuthEntity.ContentVersionId__c){
        		documentProfile.ContentVersionId__c=contentVersions[0];
        		documentProfile.ContentDocumentId__c=contentVersions[1];
        	}
        	else if(orginalContentVersionId==AuthEntity.SecondaryContentVersionId__c){
        	    documentProfile.SecondaryContentVersionId__c=contentVersions[0];
        	    documentProfile.SecondaryContentDocumentId__c=contentVersions[1];
        	}
        }
        
        System.debug('Component_Handler.revise   revisedContentVersions '+revisedContentVersions);
        //insert documentProfile;
        //update AuthEntity;
         if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,Document_Name__c,Document_Type__c,Status__c,isTemp__c,isTempRevise__c','create')){
                   insert documentProfile;
             
        }
        else{
                        System.debug('DocumentProfileControllerExt TEMP Button Insert Temporary Revised: No Acesss to object  Document_Profile__c');
                     }
        
        return documentProfile.Id;
    }
    
    /*----------Document Revise and Temp story(Stop)-------------*/  
    
    //v1.1.13 start
    @Remoteaction
    public static boolean voidChngMngmnt(String chmgid, String voidreason){
        system.debug('vvvv'+chmgid+'--'+voidreason);
         Savepoint sp = Database.setSavepoint();
        
        try 
        {
            System.debug('-->voidDocumentProfile.recordid'+chmgid+'   voidReason'+voidreason);
            Change_Management__c cmreq =new Change_Management__c();
            List<general_task__c> genTasks;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c','id,Status__c ');
            List<Change_Management__c> cmreqList = database.query('Select '+ queryFieldNames +' from Change_Management__c where id = :chmgid limit 1');
            cmreq = cmreqList [0];
            cmreq.Status__c = 'Void';
            
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Status__c', 'update')){
                String queryFieldNamesDPGt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Change_Management__c,status__c,recordtypeid,recordtype.Name');
                if(queryFieldNamesDPGt != null && queryFieldNamesDPGt != ''){
                    genTasks= database.query('Select '+ queryFieldNamesDPGt +' from General_Task__c where Change_Management__c=:chmgid Limit 100');  
                    for(general_task__c genTask:genTasks){
                        genTask.status__c='Void';
                    }
                    System.debug('-->Update genTask');
                    update genTasks;
                }  
                System.debug('-->Update cmreq'+cmreq.Status__c); 
                update cmreq;
                System.debug('-->Update cmreq'+cmreq.Status__c); 
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','NewValue__c,Object__c,FieldName__c,FieldApiName__c', 'update')){
                    List<Change_Management_History__c> voidupdateList=new List<Change_Management_History__c>();
                    Change_Management_History__c voidupdate = new Change_Management_History__c();
                    voidupdate.Parent__c =chmgid ;
                    voidupdate.NewValue__c = voidreason;
                    voidupdate.Object__c = 'Change_Management__c';
                    voidupdate.FieldApiName__c='Status__c';
                    voidupdate.FieldName__c='VoidReason';
                    //voidupdate.Parent__c='Resolution'; 
                    system.debug('QC_DynamicObjectHandler reasonupdate before insert');
                    voidupdateList.add(voidupdate);
                    Change_Management_History__c voidupdategen;
                    for(General_Task__c genTask:genTasks){
                        voidupdategen = new Change_Management_History__c();
                        voidupdategen.Parent__c =chmgid;
                        voidupdategen.NewValue__c = voidreason;
                        voidupdategen.Object__c = 'General_Task__c';
                        voidupdategen.FieldApiName__c='Status__c';
                        voidupdategen.FieldName__c='VoidReason';
                        voidupdategen.Sub_Parent__c=genTask.RecordType.Name; 
                        voidupdateList.add(voidupdategen);                           
                    }
                    
                    insert voidupdateList;
                    system.debug('QC_DynamicObjectHandler reasonupdate  after insert');
                }
                
                
            }
            
            
            return true;
            
        }
        catch(Exception e) {
            System.debug('-->Exception In Component_Handler.VoidCR:'+e);
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.HEAD);
            return false;
        }
        
       
        
    }
    //v1.1.13 end

    
}