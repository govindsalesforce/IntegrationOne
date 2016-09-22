public with sharing class CAPA {
    private transient final string CAPA_id;
    private transient CAPA__c capa{get; set;}
    public transient String availableImpactedSites{get;set;}
    public transient static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public transient static Map<id,Risk_Priority__c> RiskPriority;
    public transient static Map<id,Risk_Severity__c> RiskSeverity;
	public transient static Map<integer,string> dateMap;
    public transient static Map<id,User> User;
    public transient static List<CAPA_History__c> chisList;
    //General Task
    public transient General_Task__c invTask{get;set;}
    public transient String hasInvTask{get;set;}
    public transient General_Task__c implTask{get;set;}
    public transient String hasImplTask{get;set;}
    public transient General_Task__c erTask{get;set;}
    public transient String hasERTask{get;set;}
    public transient General_Task__c closTask{get;set;}
    public transient List<String> capaTasks {get;set;}
    public transient List<General_Task__c> allCAPAGnrlTasks{get;set;}
    //ADHOC TASK------------
    public transient List<General_Task__c> adhocTasks{get; set;}
    public transient General_Task__c addNewadhocTask{get; set;}
    public transient List<String> adhocTaskDetails{get;set;}
        
    public transient static Boolean isInvTaskPresent{get;set;}
    public transient static Boolean isImplTaskPresent{get;set;}
    public transient static Boolean isErPresent{get;set;}
    //Reference
    public Id capaId{get;set;}
    Public transient List<Non_Conformance__c> nonConf{get;set;}
    Public transient List<CAPA__c> capaList{get;set;}
    //CAPA__c capa;
    Public transient List<NC_CAPA__c> NCAPAList;
    Public transient List<CAPAJunction__c> CAPAJuncList;
    Set<Id> ncIds,capaIds;
    public transient string search{get;set;}
    public transient list<Non_Conformance__c> allNCs{get;set;}
    public transient list<CAPA__c> allCAPAs{get;set;}
    public transient Boolean allCheck{get;set;}
    public transient Boolean ncCheck{get;set;}
    public transient Boolean capaCheck{get;set;}
    public transient String capaOpenTaskSequence{get;set;}
    
    public CAPA(CAPA controller){
        
    }
    
    public CAPA__c getCAPA(){
        return capa;
    }
    
    public CAPA() {
    }
    public CAPA(NonConformance controller){
        
    }
    public boolean processInstanceQuried;
    public boolean isCapaOwnerSubmitter{get{
        if(processInstanceQuried==null){
            getProcessInstanceForCapa();   
        }
        return isCapaOwnerSubmitter;
    }set;}
    public boolean isChangeCapaOwnerApprover{get{
        if(processInstanceQuried==null){
            getProcessInstanceForCapa();
        }
     return isChangeCapaOwnerApprover;   
    }set;}
    
    public ProcessInstance getProcessInstanceForCapa(){
        	
            string Pending='Pending';
            system.debug('inside processInstances getApprover CAPA');
            String queryFieldSOfCAPAPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfCAPAPW);
            String queryFieldSOfCAPAPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
            system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfCAPAPI);
            String queryFieldSOfCAPAPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfCAPAPs);              
            if(queryFieldSOfCAPAPI!=null&&queryFieldSOfCAPAPI!=''&&queryFieldSOfCAPAPW!=null&&queryFieldSOfCAPAPW!=''&&queryFieldSOfCAPAPs!=null&&queryFieldSOfCAPAPs!=''){
                system.debug('inside processInstances if CAPA_id'+CAPA_id);
                List<ProcessInstance> CapaprocessInstances;
                CapaProcessInstances=database.query('Select  '+queryFieldSOfCAPAPI +', ( Select '+ queryFieldSOfCAPAPW +' from Workitems),( Select '+ queryFieldSOfCAPAPs +' from Steps) FROM ProcessInstance where TargetObjectId =:CAPA_id And Status =: Pending limit 1'); 
                processInstanceQuried=true;
                system.debug('inside processInstances CapaProcessInstances'+CapaProcessInstances);     
                for(ProcessInstance pi:CapaProcessInstances){
                    if(pi.SubmittedById==Userinfo.getUserId()){
                        isCapaOwnerSubmitter=true;
                    }
                    else{
                        isCapaOwnerSubmitter=false;
                    }
                    for(ProcessInstanceWorkitem wi:pi.Workitems){
                        system.debug('inside processInstances wi.actorid'+wi.actorid); 
                        if(wi.actorid==Userinfo.getUserId()){
                            system.debug('inside processInstances wi.actorid if inside'+Userinfo.getUserId());
                            isChangeCapaOwnerApprover=true;
                        }
                    }
                }
            }
        return null;
    }
    
    
    public static boolean can_reopen(CAPA__c capa){
        Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        CustomPermission can_reopen;
        List<SetupEntityAccess> setupEntities;
        String NSPrefix = dev_settings.Namespace_Prefix__c;
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CustomPermission', 'Id,DeveloperName,namespaceprefix');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            List<CustomPermission> customPermList = database.query('Select '+ queryFieldNames + ' FROM CustomPermission WHERE DeveloperName = \'Reopen_CAPA\' and namespaceprefix = :NSPrefix limit 1');
            can_reopen = customPermList[0];
            String canreopenId = can_reopen.id;
            String queryFieldNamesSetUpEntityAccess = QC_DynamicObjectHandler.getAccessibleFields('SetupEntityAccess', 'Id,SetupEntityId,ParentId');
            String queryFieldNamesPermissionSetAssignment = QC_DynamicObjectHandler.getAccessibleFields('PermissionSetAssignment','PermissionSetId');
            String LoggedInUser = UserInfo.getUserId();
            if(queryFieldNamesSetUpEntityAccess != null && queryFieldNamesSetUpEntityAccess != '' && queryFieldNamesPermissionSetAssignment != null && queryFieldNamesPermissionSetAssignment != '')
            {
                setupEntities = database.query('Select '+queryFieldNamesSetUpEntityAccess+' FROM SetupEntityAccess WHERE SetupEntityId = :canreopenId AND ParentId IN (SELECT '+queryFieldNamesPermissionSetAssignment+' FROM PermissionSetAssignment WHERE AssigneeId = :LoggedInUser)');
            }
        }
        
        return  (userinfo.getuserid() == capa.ownerid || (setupEntities != null && setupEntities.size() > 0));
    }
    
    public boolean getcan_reopen(){
        return true;
        //return can_reopen(capa);    
    }
    
    public CAPA(ApexPages.StandardController controller) {
        try{
            Schema.DescribeFieldResult fieldResult = CAPA__c.Sites_Impacted__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            availableImpactedSites ='';
            for( Schema.PicklistEntry f : ple){
                availableImpactedSites+=f.getValue()+',';
            }
            if (controller != null) {
                if (controller.getRecord() != null) {
                    this.CAPA_id = ((CAPA__c)controller.getRecord()).id;
                    system.debug('CAPA__c inside StandardController');
                }
            }
            if(CAPA_id!= '' && CAPA_id!= null) {  
                String fieldsToReturn ='';
                
                String namespacePrepend = '';
                if ('' != QC_custom_settings.getPrefix()) {
                    namespacePrepend =(QC_custom_settings.getPrefix()==null)?'': QC_custom_settings.getPrefix()+'__'; 
                }
                
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrepend + 'CAPA__c').getDescribe().fields.getMap();
                for( String fieldName : fieldMap.keySet() ) {
                    if(fieldsToReturn != '') {
                        fieldsToReturn += ', ';
                    }
                    fieldsToReturn += fieldName;
                    Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
                    String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
                    if (relationshipName != null && relationshipName.endsWith('__r')) {
                        fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
                        if (relationshipName.equals(namespacePrepend + 'Reported_By__r')) {
                            fieldsToReturn += ', ' + relationshipName + '.FirstName' + ', ' + relationshipName + '.LastName';
                        }
                    }
                }
                
                fieldsToReturn += ', Owner.Name,Owner.FirstName,Owner.LastName, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
                
                // Build query string
                String selectAllFieldsForCAPA = '';
                selectAllFieldsForCAPA += 'select ' + fieldsToReturn + ' from CAPA__c where id = \'' + CAPA_id + '\' limit 1';
                system.debug('Query is: ' + selectAllFieldsForCAPA);
                capa = database.query(selectAllFieldsForCAPA);
            } else {
                capa = new CAPA__c();
            }
            String capaId=((CAPA__c)controller.getRecord()).id;
    		populateCAPATasks(capaId);
            capaReference(capaId);
        }catch(Exception ex){
            System.debug('Exception In  CAPA    '+ex.getMessage());
        }
    }
    
    public void populateCAPATasks(String capaId){
        try{
            Map<Double,String> capaTaskWithSequence= new Map<Double,String>();
            Map<Double,List<General_Task__c>> allTaskWithSequence= new Map<Double,List<General_Task__c>>();
            //String capaId=((CAPA__c)controller.getRecord()).id;
            adhocTaskDetails=new List<String>();
            List<SObject> sObjects;
            String capaStatus=null;
            Map<String,List<General_Task__c>> allTasks= new Map<String,List<General_Task__c>>();
            
            List<General_Task__c> tmpTaskList;
            System.debug('CAPATaskController  capaId   '+capaId);
            capaTasks=new List<String>();
            List<General_Task__c> allTaskList;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Allowed_Days__c,Status__c,Due_Date__c,ChangeFieldApprovalStatus__c,New_Owner__r.Name,Note_To_Approver_Owner_DueDate__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Sequence_Position__c,OwnerId,Owner.Name,CAPA__c,RecordType.Name,CAPA__r.CAPA_Status__c,Note_To_Approver__c,CurrentApprovalSequenceNumber__c,Approval_Required__c,AdhocTask_Title__c,New_Due_Date__c,New_Owner__c,Add_Effectiveness_verificiation__c,Owner__r.Name,Investigation_Tools__c,Investigation_Summary__c,Objective_Evidence__c,Completed_By_Name__c,Completed_Date__c,Closure_Comment__c,CAPA_Effectiveness__c,Create_New_CAPA__c');
            if(queryFieldNames != null && queryFieldNames != ''){
		        for(General_Task__c genTask :Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE CAPA__c=:capaId ORDER BY Sequence_Position__c')){
		           allTaskList=allTasks.get(genTask.RecordType.Name);
		           if(allTaskList==null){
		           	   allTaskList=new List<General_Task__c>();
		           	   allTasks.put(genTask.RecordType.Name,allTaskList);
                       allTaskWithSequence.put(genTask.Sequence_Position__c,allTaskList);
		           }
		           allTaskList.add(genTask);   
		        }
		        System.debug('CAPATaskController allTasks    '+allTasks);
		             if(!allTasks.isEmpty()){
	                      //Investigation
	                       tmpTaskList=allTasks.get('Investigation');
	                       invTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
	                       if(invTask!=null){
	                          hasInvTask='Yes';
	                          capaOpenTaskSequence=(invTask.Status__c=='Open')?String.valueOf(invTask.Sequence_Position__c):capaOpenTaskSequence;
	                          capaTaskWithSequence.put(invTask.Sequence_Position__c,invTask.RecordType.Name+'@'+invTask.Status__c+'@'+String.valueOf(invTask.CurrentApprovalSequenceNumber__c)+'@'+invTask.Approval_Required__c+'@'+invTask.Id);
	                        isInvTaskPresent=false;
                              }else{
                               isInvTaskPresent=true;  
                              }
		                   //Implementation
		                   tmpTaskList=allTasks.get('Implementation');
		                   implTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
		                   if(implTask!=null){
		                        hasImplTask='Yes';
		                        capaOpenTaskSequence=(implTask.Status__c=='Open')?String.valueOf(implTask.Sequence_Position__c):capaOpenTaskSequence;
		                        capaTaskWithSequence.put(implTask.Sequence_Position__c,implTask.RecordType.Name+'@'+implTask.Status__c+'@'+String.valueOf(implTask.CurrentApprovalSequenceNumber__c)+'@'+implTask.Approval_Required__c+'@'+implTask.Id);
		                    isImplTaskPresent=false;
                              }else{
                               isImplTaskPresent=true;  
                              }
		                   //Effectiveness Review
		                   tmpTaskList=allTasks.get('EffectivenessReview');
		                   erTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
		                   if(erTask!=null){
		                        hasERTask='Yes';
		                        capaOpenTaskSequence=(erTask.Status__c=='Open')?String.valueOf(erTask.Sequence_Position__c):capaOpenTaskSequence;
		                        capaTaskWithSequence.put(erTask.Sequence_Position__c,erTask.RecordType.Name+'@'+erTask.Status__c+'@'+String.valueOf(erTask.CurrentApprovalSequenceNumber__c)+'@'+erTask.Approval_Required__c+'@'+erTask.Id);
		                    isErPresent=false;
                              }else{
                               isErPresent=true;  
                              }
	                       tmpTaskList=allTasks.get('Closure');
	                       closTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
	                       capaStatus=closTask.CAPA__r.CAPA_Status__c;
	                       capaTaskWithSequence.put(closTask.Sequence_Position__c,closTask.RecordType.Name+'@'+closTask.Status__c+'@'+String.valueOf(closTask.CurrentApprovalSequenceNumber__c)+'@'+closTask.Approval_Required__c+'@'+closTask.Id);
	                       //Adhoc task  
                           adhocTasks=allTasks.get('AdhocTask');
		                    if(adhocTasks!=null){
			                    for(General_Task__c adhocTask : adhocTasks){
			                    	adhocTaskDetails.add(adhocTask.RecordType.Name+'@'+adhocTask.AdhocTask_Title__c+'@'+adhocTask.Id+'@'+adhocTask.Status__c+'@'+adhocTask.CurrentApprovalSequenceNumber__c+'@'+adhocTask.Approval_Required__c);
			                        capaOpenTaskSequence=(adhocTask.Status__c=='Open')?String.valueOf(adhocTask.Sequence_Position__c):capaOpenTaskSequence;
			                    }
			                    adhocTasks=adhocTasks.isEmpty()?null:adhocTasks;
		                    }
		                    addNewadhocTask = new General_Task__c();
		                    System.debug('CAPATaskController  adhocTasks   '+adhocTasks);
		                   }
			}
            else{
            	System.debug('CAPATaskController  : No Acesss to object  General_Task__c and fields to get tasks'+queryFieldNames);
            }
            if(capaStatus!='Inworks' && hasInvTask==null && hasImplTask==null && closTask==null){
                hasInvTask='Yes';
                hasImplTask='Yes';
                hasERTask='Yes';
            }
            if(capaStatus=='Inworks' || capaStatus=='Closed' || capaStatus=='Reopened' || capaStatus=='Void'){
                capaTasks=new List<String>();
                if(capaTaskWithSequence.size()>0){
                    List<Double> seqList=new List<Double>(capaTaskWithSequence.keySet());
                    seqList.sort();
                    for(Double seq : seqList){
                        capaTasks.add(capaTaskWithSequence.get(seq));
                    }
                 }
            }
            allCAPAGnrlTasks = new List<General_Task__c>(); 
            List<Double> allSeqList=new List<Double>(allTaskWithSequence.keySet());
            allSeqList.sort();
            for(Double allseq : allSeqList){
                allCAPAGnrlTasks.addAll(allTaskWithSequence.get(allseq));
            }
           system.debug('CAPATaskController allSeqList-->'+allSeqList); 
           system.debug('CAPATaskController allCAPAGnrlTasks-->'+allCAPAGnrlTasks);
           System.debug('CAPATaskController  capaOpenTaskSequence   '+capaOpenTaskSequence);
           
        }catch(Exception ex){
            invTask=null;
            implTask=null;
            erTask=null;
            closTask=null;
            System.debug('Exception IN CAPATaskController  '+ex.getMessage());
        }
        System.debug('CAPATaskController invTask   '+ invTask+' erTask  '+erTask+' implTask   '+implTask+' closTask  '+closTask);
        System.debug('CAPATaskController hasInvTask   '+ hasInvTask+' hasERTask '+hasERTask+' hasImplTask  '+hasImplTask);
        System.debug('CAPATaskController capaTasks   '+ capaTasks);
    }
    
   /* public static void TriggerMethodBeforeUpdate(List<CAPA__c> newCapaList, Map<Id, CAPA__c> newCapaMap, List<CAPA__c> oldCapaList, Map<Id, CAPA__c> oldCapaMap) {
        try{
        	Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = Risk_Priority.getRiskPriorityGrid();
             For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c FROM Risk_Lookup__c LIMIT 1000]) {
                Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
            }
            for (CAPA__c newCapa : newCapaList) {
                if(newCapa.CAPA_Status__c == 'Closed' && newCapa.CAPA_Status__c != oldCapaMap.get(newCapa.Id).CAPA_Status__c) {
                    newCapa.Closed_Date__c = Date.Today();
                }
                 if (Severity_to_Occurrences_map.get(newCapa.Risk_Severity__c) != null) {
                    newCapa.Risk_Priority__c = Severity_to_Occurrences_map.get(newCapa.Risk_Severity__c).get(newCapa.Risk_Occurrence__c);
                }
            
                if(newCapa.Approval_Status__c=='Approved'&&oldCapaMap.get(newCapa.id).Approval_Status__c=='Pending Approval'){
                    newCapa.OwnerId=newCapa.New_Owner__c;
                    newCapa.New_Owner__c=null;
                }   
                else if(newCapa.Approval_Status__c=='Rejected'||newCapa.Approval_Status__c=='Recall'){
                    newCapa.New_Owner__c=null;
                }
            }
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.CAPA);
        }       
    }*/
    
    @RemoteAction
    public static boolean  submitApprovalRequestCAPAOwner(id ObjectId,string[] approverIds,string Comments,string ownerid){
        
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'id,Note_To_Approver__c,New_Owner__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Name');
        if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
            CAPA__c ca=database.query('Select '+ queryFieldSOfGT +' From CAPA__c where id=:ObjectId');
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
            ca.Approver_9__c=approverIds[((len-i)>0)?len-i:0]; 
            ca.Note_To_Approver__c=Comments; 
            system.debug('CAPA New_Owner__c'+ca.New_Owner__c);
            upsert ca;
            system.debug('CAPA New_Owner__c after upsert'+ca.New_Owner__c);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(Comments);
            req.setObjectId(ObjectId);
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
    
 
    
    @RemoteAction
    public static Integer followCAPA(String capaId,String userId){
    	try{
    		String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Followers__c');
    		if(queryFieldNames != null && queryFieldNames != ''){
    			List<CAPA__c> ca = Database.query('SELECT '+queryFieldNames+' FROM CAPA__c WHERE Id=:capaId');
    			if(!ca.isEmpty()){
    			  ca[0].Followers__c=(ca[0].Followers__c==null)?userId:(ca[0].Followers__c+';'+userId);
    			  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','Followers__c','update')){
    			   update ca;
    			   return 0;
    			  }
    			  else{
    			  	System.debug('CAPA followNC  No update access to the fields  '+queryFieldNames);
    			  }
    			}
    		}
    		else{
    		  System.debug('CAPA followNC  No access to the fields  '+queryFieldNames);
    		}
        }
    	catch(Exception ex){
    		System.debug('Exception In CAPA.followNC   '+ex.getMessage());
    	}
    	return -1;
    }
    
    @RemoteAction
    public static Integer unFollowCAPA(String capaId,String userId){
    	try{
    		String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Followers__c');
    		String newFollowers='';
    		String[] existingFollowers;
    		if(queryFieldNames != null && queryFieldNames != ''){
    			List<CAPA__c> ca = Database.query('SELECT '+queryFieldNames+' FROM CAPA__c WHERE Id=:capaId');
    			if(!ca.isEmpty()){
    			  existingFollowers=ca[0].Followers__c.split(';');
    			  for(String existingFollower : existingFollowers){
    			  	 if(userId.equalsIgnoreCase(existingFollower)){
    			  	 	continue;
    			  	 }
    			  	 newFollowers+=existingFollower;
    			  }
    			  ca[0].Followers__c=newFollowers;
    			  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','Followers__c','update')){
    			   update ca;
    			   return 0;
    			  }
    			  else{
    			  	System.debug('CAPA followCAPA  No update access to the fields  '+queryFieldNames);
    			  }
    			}
    		}
    		else{
    		  System.debug('CAPA followCAPA  No access to the fields  '+queryFieldNames);
    		}
        }
    	catch(Exception ex){
    		System.debug('Exception In CAPA.followCAPA   '+ex.getMessage());
    	}
    	return -1;
    }   
	
	@RemoteAction
    public static Map<String,Id> createCAPATasks(List<String> adhocTasks,Map<String,List<String>> taskData,String capaId,Boolean isSubmit,boolean isApprovalNeeded,boolean fromHeader){
        System.debug('CAPATaskController createCAPATasks tasks   '+taskData+'   taskData.keySet()   '+taskData.keySet() +'  capaId  '+capaId+' isSubmit   '+isSubmit+' isApprovalNeeded  '+isApprovalNeeded+' fromHeader   '+fromHeader);
        List<General_Task__c> tasks=new List<General_Task__c>();
        Map<String,General_Task__c> existingTaskMap=new Map<String,General_Task__c>();
        Map<String,General_Task__c> existingTaskWithId=new Map<String,General_Task__c>();
        List<String> data=null;
        General_Task__c task=null;
        Map<String,Id> result=new Map<String,Id>();
        Set<Id> capaGenTaskIds=new Set<Id>();
        try{
            List<General_Task__c> existingTasks=null;
            List<NC_General_Task__c> exstingNCGenTasks=null;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,CAPA__c,Status__c,RecordType.Name, Sequence_Position__c, Allowed_Days__c, Due_Date__c ,Note_To_Approver__c');
            if(queryFieldNames != null && queryFieldNames != ''){
            	Set<String> recTypes=taskData.keySet();
		        existingTasks=Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE CAPA__c=:capaId');
		        queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('CAPA_General_Task__c', 'CAPA__c,General_Task__c');
                if(queryFieldNames != null && queryFieldNames != ''){
                    for(CAPA_General_Task__c capaGenTask : Database.query('SELECT '+queryFieldNames+' FROM CAPA_General_Task__c WHERE CAPA__c=:capaId')){
                        capaGenTaskIds.add(capaGenTask.General_Task__c);
                    }
                }
                else{
                    System.debug('CAPATaskController.createCAPATasks  : No Acesss to object  createCAPATasks and fields for existingNCGenTasks    '+queryFieldNames);
                }
            }
		    if(!existingTasks.isEmpty()){
	                for(General_Task__c existingTask : existingTasks){
	                    existingTaskMap.put(existingTask.CAPA__c+'@'+String.valueOf(existingTask.RecordType.Name), existingTask);
	                    existingTaskWithId.put(existingTask.Id,existingTask);
	                }
            }
            for(String recordTypeName : taskData.keySet()){
	            data = taskData.get(recordTypeName);
	            task=existingTaskMap.get(capaId+'@'+recordTypeName);
	            task=(task==null)?new General_Task__c():task;
	            task.Sequence_Position__c=Integer.valueOf(data[0]);
	            task.OwnerId=data[1];
	            task.Allowed_Days__c=Integer.valueOf(data[2]);
	            task.Due_Date__c=(data[3]==null)?null:Date.parse(data[3]);
	            if(task.CAPA__c==null)
	                task.CAPA__c=capaId;
	            System.debug('Record Type  '+recordTypeName+'     Id  '+Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get(recordTypeName).getRecordTypeId());
	            task.RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get(recordTypeName).getRecordTypeId();
	            task.Status__c=(isSubmit)?'Created':task.Status__c;
	            if(!isApprovalNeeded){
                    task.Approval_Required__c='No';
                    task.Note_To_Approver__c='';
                }
	            tasks.add(task);
           } 
           System.debug('CAPATaskController createCAPATasks tasks '+tasks);
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
                    if(task.CAPA__c==null)
                         task.CAPA__c=capaId;
                    task.RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId();
                    task.Status__c=(isSubmit)?'Created':task.Status__c;
                    system.debug('tasks adding----------------------->'+task.Adhoc_Sequence__c+' '+task.Sequence_Position__c+' '+task.Owner__c+' '+ task.Due_Date__c+' '+task.AdhocTask_Title__c+' '+task.CAPA__c+' '+ task.RecordTypeId+' '+task.Status__c); 
                    tasks.add(task);
                    system.debug('tasks adding----------------------->'+Integer.valueOf(details[0])+' '+details[1]+' '+Integer.valueOf(details[2])+' '+Date.parse(details[3])+' '+details[4]+' '+capaId); 
                   
                }
            }
           if(!tasks.isEmpty()){
           	     
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,CAPA__c,RecordTypeId','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,RecordTypeId','update')){
                     if(isSubmit && !fromHeader){
                        if(tasks.size()==1 || tasks[0].RecordTypeId==Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()){ //Only CLosure Task Is Selected.
                            tasks[0].Status__c='Open';
                        }
                        else{
                           Integer minSeq=1000;
                           Integer actSeq;
                           for(General_Task__c seqChkTask : tasks){
                              System.debug('CAPATaskController createCAPATasks seqChkTask.RecordTypeId  '+seqChkTask.RecordTypeId+'   '+(seqChkTask.RecordTypeId!=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()));
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
                    System.debug('CAPATaskController createCAPATasks tasks with sequences....'+tasks);
                    upsert tasks;
                    List<CAPA_General_Task__c> capaGenTasks=new List<CAPA_General_Task__c>();
                    CAPA_General_Task__c capaGenTaskObj=null;
                    for(General_Task__c savedTask : tasks){
                            System.debug('CAPATaskController createCAPATasks savedTask '+savedTask+'   savedTask.Id   '+savedTask.Id);
                            if(!capaGenTaskIds.contains(savedTask.Id)){
                                capaGenTaskObj=new CAPA_General_Task__c();
                                capaGenTaskObj.General_Task__c=savedTask.Id;
                                capaGenTaskObj.CAPA__c=capaId;
                                capaGenTasks.add(capaGenTaskObj);
                            }
                            result.put(Schema.SObjectType.General_Task__c.RecordTypeInfosById.get(savedTask.RecordTypeId).getName(),savedTask.Id);
                    }
                  if(!isApprovalNeeded){
                      String closureTaskId=result.get('Closure');
                      queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'Id,Sequence_Position__c,Allowed_Days__c,Due_Date__c,User__c,General_Task__c');
                      List<Approver__c> existingApprovers=null;
                      if(queryFieldNames != null && queryFieldNames != ''){
                          existingApprovers=Database.query('SELECT '+queryFieldNames+' FROM Approver__c WHERE General_Task__c = : closureTaskId');
                      }
                      else{
                        System.debug('CAPATaskController createCAPATasks  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
                      }
                      if(!existingApprovers.isEmpty()){
                        if(Approver__c.sObjectType.getDescribe().isDeletable()){
                          delete existingApprovers;
                         }
                      }
                  }
                  if(!capaGenTasks.isEmpty()){
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_General_Task__c','General_Task__c,CAPA__c','create'))
                        insert capaGenTasks;
                     else{
                        System.debug('CAPATaskController createCAPATasks  : No Acesss to object  CAPA_General_Task__c');
                     }
                 }
            }
            else{
                  System.debug('CAPATaskController createCAPATasks  : No Acesss to object  General_Task__c fields  ');
            } 
          }
           	   if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,CAPA__c,RecordTypeId','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,RecordTypeId','update')){
           	       upsert tasks;
           	       
           	   }
          
        }
        catch(Exception ex){
            System.debug('Exception In CAPATaskController.createCAPATasks   '+ex.getMessage());
            result=null;
            
        }
        System.debug( 'CAPATaskController createCAPATasks result '+result);
        return result;
    }

	@RemoteAction
    public static List<String> getResolutionCodes(){
    	List<String> resList=new List<String>();
    	try{
    		 Schema.DescribeFieldResult fieldResult = CAPA__c.Resolution_Code__c.getDescribe();
			 List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		     for( Schema.PicklistEntry f : ple){
			        resList.add(f.getValue());
			  }
			   
    	}
    	catch(Exception ex){
    	  System.debug('Exception In CAPATaskController.getResolutionCodes   '+ex.getMessage());
    	  resList=new List<String>();
    	}
    	return resList;
    } 
    
     
    
    String queryFieldNamesNonConformance,queryFieldNamesCapa,cId,queryFieldNamesNcCapa,queryFieldNamesCAPAJunction;
    public void capaReference(String capaId){
        try{
            search='';
            capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
            // bringing all nc and capa details from junction object........
            queryFieldNamesNcCapa = QC_DynamicObjectHandler.getAccessibleFields('NC_CAPA__c','CAPA__c,Non_Conformance__c');
            if(queryFieldNamesNcCapa != null && queryFieldNamesNcCapa != ''){
                NCAPAList = database.query('SELECT '+queryFieldNamesNcCapa+' FROM NC_CAPA__c WHERE CAPA__c = :capaId');
            }
            System.debug('NCAPAList---------------------->'+NCAPAList);
            // gathering all ncs associated to CAPA.... in putting into SET
            ncIds = new Set<Id>();
            if(!NCAPAList.isEmpty()){
                for(NC_CAPA__c ncapa:NCAPAList){
                    ncIds.add(ncapa.Non_Conformance__c);
                }
            }
            
            // getting all non conformance records..... by querying from ncIds
            queryFieldNamesNonConformance = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c','Id,Name,NC_Type__c,NC_Owner_Name__c,NC_Source__c,NC_Status__c,CAPA_Number__c');
            if(queryFieldNamesNonConformance != null && queryFieldNamesNonConformance != ''){
                nonConf = database.query('SELECT '+queryFieldNamesNonConformance+' FROM Non_Conformance__c WHERE Id IN: ncIds');
            }
            queryFieldNamesCAPAJunction = QC_DynamicObjectHandler.getAccessibleFields('CAPAJunction__c','CAPAParent__c,CAPAChild__c');
            if(queryFieldNamesCAPAJunction != null && queryFieldNamesCAPAJunction != ''){
                CAPAJuncList = database.query('SELECT '+queryFieldNamesCAPAJunction+' FROM CAPAJunction__c WHERE CAPAParent__c = :capaId OR CAPAChild__c = :capaId');
            }
            System.debug('CAPAJuncList---------------------->'+CAPAJuncList);
            capaIds = new Set<Id>();
            if(!CAPAJuncList.isEmpty()){
                for(CAPAJunction__c capaJun:CAPAJuncList){
                    capaIds.add(capaJun.CAPAParent__c);
                    capaIds.add(capaJun.CAPAChild__c);
                }
                capaIds.remove(capaId);
                System.debug('capaIds---------------------->'+capaIds);
            }
            queryFieldNamesCapa = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','Id,Name,CAPA_Status__c,CAPA_Source__c,Title__c,Owner.Name,Closed__c');
            if(queryFieldNamesCapa != null && queryFieldNamesCapa != ''){
                capaList = database.query('SELECT '+queryFieldNamesCapa+' FROM CAPA__c WHERE Id IN: capaIds');
            }
            System.debug('capaList---------------------->'+capaList);
        }catch(Exception ex){
            System.debug('Exception In  reference    '+ex.getMessage());
        }         
    }
    
    @RemoteAction
    public static Integer saveXReferences(List<Id> deletedNCIds,List<Id> deletedCAPAIds,Id cpId,List<Id> selectedNCIds,List<Id> selectedCAPAIds){
        Savepoint sp;
        try{
            //List<CAPA__c> cList,cpList,selectedCAPAs;
            List<CAPAJunction__c> capaJunList,selectedCAPAJuncs;
            List<NC_CAPA__c> nccpList,selectedNCCAPAs;
            Set<id> existingNcs,existingCapas;
            String capaFields,ncapaFields,capaJunFields;
            ncapaFields = QC_DynamicObjectHandler.getAccessibleFields('NC_CAPA__c','Id,Non_Conformance__c,CAPA__c');
            //capaFields = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','Id,CAPA__c');
            capaJunFields = QC_DynamicObjectHandler.getAccessibleFields('CAPAJunction__c','Id,CAPAParent__c,CAPAChild__c');
            System.debug('deletedNCIds------------------------------->'+deletedNCIds+' capaId--------------->'+cpId);
            if(ncapaFields != null && ncapaFields != ''){
                nccpList = database.query('SELECT '+ncapaFields+'  FROM NC_CAPA__c WHERE Non_Conformance__c IN: deletedNCIds AND CAPA__c =: cpId');
                System.debug('nccpList------------------------------->'+nccpList);
            	if(!nccpList.isEmpty()){
            		delete nccpList;
            	}
            }
            
            /*if(!selectedNCIds.isEmpty()){
            	selectedNCCAPAs = new List<NC_CAPA__c>();
            	for(Id nId:selectedNCIds){
            		selectedNCCAPAs.add(new NC_CAPA__c(Non_Conformance__c = nId ,CAPA__c = cpId));
            	}
            	if(!selectedNCCAPAs.isEmpty()){
            		upsert selectedNCCAPAs;
            	}    
            }*/
            
            if(!selectedNCIds.isEmpty()){
            	if(ncapaFields != null && ncapaFields != ''){
            		selectedNCCAPAs = database.query('SELECT '+ncapaFields+' FROM NC_CAPA__c WHERE Non_Conformance__c IN: selectedNCIds AND CAPA__c =: cpId');
            	}
            	System.debug('selectedNCCAPAs------------------------------->'+selectedNCCAPAs);
            	System.debug('selectedNCIds------------------------------->'+selectedNCIds);
            	existingNcs = new Set<Id>();
        		if(!selectedNCCAPAs.isEmpty()){
					for(NC_CAPA__c ncapa:selectedNCCAPAs){
						existingNcs.add(ncapa.Non_Conformance__c);
					}
					for(Id n:selectedNCIds){
						if(!existingNcs.contains(n)){
							selectedNCCAPAs.add(new NC_CAPA__c(Non_Conformance__c = n ,CAPA__c = cpId));
						}	
					}
					if(!selectedNCCAPAs.isEmpty()){
        				upsert selectedNCCAPAs;
        			}
				}else{
    				selectedNCCAPAs = new List<NC_CAPA__c>();
        			for(Id nId:selectedNCIds){
        				selectedNCCAPAs.add(new NC_CAPA__c(Non_Conformance__c = nId ,CAPA__c = cpId));
        			}
        			if(!selectedNCCAPAs.isEmpty()){
        				upsert selectedNCCAPAs;
        			}
    			}
            }
            
            
        	
            /*if(capaFields != null && capaFields != ''){
               cList = database.query('SELECT '+capaFields+' FROM CAPA__c WHERE Id IN: deletedCAPAIds');
            }
            System.debug('cList------------------------------->'+cList);
            if(!cList.isEmpty()){
                cpList = new List<CAPA__c>();
            	for(CAPA__c c:cList){
                    c.CAPA__c = null;
                    cpList.add(c);
            	}
                upsert cpList;
            }*/
            if(capaJunFields != null && capaJunFields != ''){
               capaJunList = database.query('SELECT '+capaJunFields+'  FROM CAPAJunction__c WHERE (CAPAParent__c IN: deletedCAPAIds AND CAPAChild__c =: cpId) OR (CAPAChild__c IN: deletedCAPAIds AND CAPAParent__c =:cpId)' );
               if(!capaJunList.isEmpty()){
            		delete capaJunList;
               }
            }
                        
            if(!selectedCAPAIds.isEmpty()){
            	if(capaJunFields != null && capaJunFields != ''){
            		selectedCAPAJuncs = database.query('SELECT '+capaJunFields+'  FROM CAPAJunction__c WHERE (CAPAParent__c IN: selectedCAPAIds AND CAPAChild__c =: cpId) OR (CAPAChild__c IN: selectedCAPAIds AND CAPAParent__c =:cpId)' );
            	}
            	existingCapas = new Set<Id>();
            	if(!selectedCAPAJuncs.isEmpty()){
					for(CAPAJunction__c cJun:selectedCAPAJuncs){
						existingCapas.add(cJun.CAPAParent__c);
						existingCapas.add(cJun.CAPAChild__c);
					}
					existingCapas.remove(cpId);
					for(Id n:selectedCAPAIds){
						if(!existingCapas.contains(n)){
							selectedCAPAJuncs.add(new CAPAJunction__c(CAPAParent__c = n ,CAPAChild__c = cpId));
						}	
					}
					if(!selectedCAPAJuncs.isEmpty()){
            			upsert selectedCAPAJuncs;
            		}
				}else{
        			selectedCAPAJuncs = new List<CAPAJunction__c>();
            		for(Id c:selectedCAPAIds){
            			selectedCAPAJuncs.add(new CAPAJunction__c(CAPAParent__c = c ,CAPAChild__c = cpId));
            		}
            		if(!selectedCAPAJuncs.isEmpty()){
            			upsert selectedCAPAJuncs;
            		}
        		}
            }
            
            
            /*if(!selectedCAPAIds.isEmpty()){
            	selectedCAPAJuncs = new List<CAPAJunction__c>();
            	for(Id c:selectedCAPAIds){
            		selectedCAPAJuncs.add(new CAPAJunction__c(CAPAParent__c = cpId ,CAPAChild__c = c));
            	}
            	if(!selectedCAPAJuncs.isEmpty()){
            		upsert selectedCAPAJuncs;
            	}    
            }*/
            
        }catch(Exception ex){
            System.debug('Exception In CAPA_XReferenceController  getLineNumber '+ex.getLineNumber());
            System.debug('Exception In CAPA_XReferenceController  getCause '+ex.getCause());
            System.debug('Exception In CAPA_XReferenceController  getMessage '+ex.getMessage());
            System.debug('Exception In CAPA_XReferenceController  getStackTraceString '+ex.getStackTraceString());
            System.debug('Exception In CAPA_XReferenceController  getTypeName '+ex.getTypeName());
            Database.rollback(sp);
            return -1;
        }        
        return 0;
    }
    
    public void doSearch(){
        try{
            system.debug('allCheck--->'+allCheck);
            system.debug('ncCheck--->'+ncCheck);
            system.debug('capaCheck--->'+capaCheck);
            
            if(search==null || search==''){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, 'search term must be longer than one character:'));
                return;
            }
                      
            String ncFields=QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Name,Ownerid,Owner.Name,NC_Source__c,NC_Type__c,NC_Status__c');
            String capaFields= QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,name,CAPA_Status__c,CAPA_Source__c,Title__c,Owner.Name');
            
            String seachCondition = String.escapeSingleQuotes('%' + search + '%');
            system.debug('doSearch.seachCondition--->'+seachCondition);
            if(allCheck== true ||(ncCheck == false && allCheck == false && capaCheck == false)){
                if(ncFields != '' && ncFields!= NULL){
                    allNCs = Database.query('SELECT Id,Name,Ownerid,Owner.Name,NC_Source__c,NC_Type__c,NC_Status__c FROM Non_Conformance__c WHERE name LIKE :seachCondition OR NC_Status__c LIKE :seachCondition OR NC_Type__c LIKE :seachCondition OR NC_Source__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition');    //(List<Non_Conformance__c>)searchList[0];   
                	//system.debug('allNCs--->2'+allNCs);
                }
                if(capaFields != '' && capaFields!= NULL){
                    system.debug('doSearch.capaId....'+capaId);
                    allCAPAs = Database.query('SELECT Id,name,CAPA_Status__c,CAPA_Source__c,Title__c,Owner.Name FROM CAPA__c WHERE (Id !=: capaId) AND (NAME LIKE :seachCondition OR CAPA_Status__c LIKE :seachCondition OR CAPA_Source__c LIKE :seachCondition OR Title__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition)'); //(List<CAPA__c>)searchList[1];
                }
                
            }else
            if(ncCheck == true ||(ncCheck == false && allCheck == false && capaCheck == false)){
                //system.debug('ncCheck--->1'+allNCs);    
                
                if(ncFields != '' && ncFields!= NULL){
                    allNCs = Database.query('SELECT Id,Name,Ownerid,Owner.Name,NC_Source__c,NC_Type__c,NC_Status__c FROM Non_Conformance__c WHERE name LIKE :seachCondition OR NC_Status__c LIKE :seachCondition OR NC_Type__c LIKE :seachCondition OR NC_Source__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition');    //(List<Non_Conformance__c>)searchList[0];   
                    allCAPAs = new List<CAPA__c>();
                }
                //system.debug('allNCs--->1'+allNCs);
            }
        	else
            if((capaCheck == true) ||(ncCheck == false && allCheck == false && capaCheck == false)){
                //system.debug('capaCheck--->1'+capaCheck);    
                
                if(capaFields != '' && capaFields!= NULL){
                    allCAPAs = Database.query('SELECT Id,name,CAPA_Status__c,CAPA_Source__c,Title__c,Owner.Name FROM CAPA__c WHERE (Id !=: capaId) AND (NAME LIKE :seachCondition OR CAPA_Status__c LIKE :seachCondition OR CAPA_Source__c LIKE :seachCondition OR Title__c LIKE :seachCondition OR Owner.Name LIKE :seachCondition)'); //(List<CAPA__c>)searchList[1];
                    allNCs = new List<Non_Conformance__c>();
                }
                //system.debug('allCAPAs--->1'+allCAPAs);
            }
        }
        catch(Exception ex){
             System.debug('Exception In CAPA_XReferenceController   '+ex.getMessage());
        }
    }
    
    public List<CAPA__c> getCAPAListForDisplay()
    {
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Name,OwnerId,Owner.Name,CAPA_Status__c,Reported_By__r.Name, CAPA_Source__c,Title__c,Problem_Statement__c,Criticality__c,Reported_Date__c,Department__c,Sites_Impacted__c,CreatedDate,CreatedBy.Name,Reported_By__c,Occurance_Date__c,Department__r.Name');
        System.debug('getCAPAList.capaList  ');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            List<CAPA__c> capaList = database.query ('select ' + queryFieldNames + ' from CAPA__c where CAPA_Status__c != \'Closed\' ORDER BY createddate DESC');
            System.debug('getCAPAList.capaList  '+capaList);
            return capaList;
        }
        else{
            return null;
        }
    }
}