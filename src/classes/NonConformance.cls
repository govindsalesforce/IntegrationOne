/*
 
     v1.0  Qualityze Inc(GP)        28-APR-2016    Initial Version.
                                                   This class includes products and resolution steps. 

*/
public with sharing class NonConformance { 

    public Id ncpid{get; set;}
   
   //General Task 
    public transient  General_Task__c contTask{get;set;}
    public transient  String hasContTask{get;set;}
    public transient General_Task__c dispTask{get;set;}
    public transient String hasDispTask{get;set;}
    public transient General_Task__c invTask{get;set;}
    public transient String hasInvTask{get;set;}
    public transient General_Task__c implTask{get;set;}
    public transient String hasImplTask{get;set;}
    public transient General_Task__c closTask{get;set;}
    public transient List<String> tasksWithSequences{get;set;}
    public transient Map<String,Integer> tasksWithStepNumber{get;set;}
    private transient String cloTaskStatus{get;set;}
    private transient String cloTaskId{get;set;}
    private transient String cloCurrentApproverSeq{get;set;}
    private transient String isCloApprovalNeeded{get;set;}
    private transient String conTaskStatus{get;set;}
    private transient String conCurrentApproverSeq{get;set;}
    private transient String isConApprovalNeeded{get;set;}
    private transient String implTaskStatus{get;set;}
    private transient String implCurrentApproverSeq{get;set;}
    private transient String isImplApprovalNeeded{get;set;}
    private transient String invTaskStatus{get;set;}
    private transient String invCurrentApproverSeq{get;set;}
    private transient String isInvApprovalNeeded{get;set;}
    private transient String dispTaskStatus{get;set;}
    private transient String dispCurrentApproverSeq{get;set;}
    private transient String isDispApprovalNeeded{get;set;}
    private transient List<Decimal> myList{get;set;}
    public transient String currentTask{get;set;}
    
    //ADHOC TASK------------
    public transient List<General_Task__c> adhocTasks{get; set;}
    public transient General_Task__c addNewadhocTask{get; set;}
    public transient  static Boolean isContTaskPresent{get;set;}
    public transient  static Boolean isDispTaskPresent{get;set;}
    public transient  static Boolean isInvTaskPresent{get;set;}
    public transient  static Boolean isImplTaskPresent{get;set;}
    //Get Least Sequence to Resolution Page
    public transient static Decimal leastSequence{get;set;}
    
     //ADHOC Task Details
    public transient List<String> adhocTaskDetails{get;set;}
    
    
    public transient List<NC_CAPA__c> ncReferences{get;set;}
    
	public NonConformance(NonConformance controller){
        
    }
	  //public string Non_Conformance_id{Get; set;}
	  private transient final string Non_Conformance_id;
	  private transient Non_Conformance__c nc{get; set;}
	  public Non_Conformance__c getNonConformance(){
	    return nc;
	  }
  
    public NonConformance() {
        
    }
    
    public static boolean can_reopen(non_conformance__c nc){
	    Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
	    CustomPermission can_reopen;
	    List<SetupEntityAccess> setupEntities;
	    String NSPrefix = dev_settings.Namespace_Prefix__c;
	
	    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CustomPermission', 'Id,DeveloperName,namespaceprefix');
	    if(queryFieldNames != null && queryFieldNames != '')
	    {
	        List<CustomPermission> customPermList = database.query('Select '+ queryFieldNames + ' FROM CustomPermission WHERE DeveloperName = \'Reopen_NC\' and namespaceprefix = :NSPrefix limit 1');
	        can_reopen = customPermList[0];
	        String careopenId = can_reopen.id;
	        String queryFieldNamesSetUpEntityAccess = QC_DynamicObjectHandler.getAccessibleFields('SetupEntityAccess', 'Id,SetupEntityId,ParentId');
	        String queryFieldNamesPermissionSetAssignment = QC_DynamicObjectHandler.getAccessibleFields('PermissionSetAssignment','PermissionSetId');
	        String LoggedInUser = UserInfo.getUserId();
	        if(queryFieldNamesSetUpEntityAccess != null && queryFieldNamesSetUpEntityAccess != '' && queryFieldNamesPermissionSetAssignment != null && queryFieldNamesPermissionSetAssignment != '')
	        {
	            setupEntities = database.query('Select '+queryFieldNamesSetUpEntityAccess+' FROM SetupEntityAccess WHERE SetupEntityId = :careopenId AND ParentId IN (SELECT '+queryFieldNamesPermissionSetAssignment+' FROM PermissionSetAssignment WHERE AssigneeId = :LoggedInUser)');
	        }
	    }
	    return  (nc.closed__c && (userinfo.getuserid() == nc.ownerid || (setupEntities != null && setupEntities.size() > 0)));
    }
    
    public boolean getcan_reopen(){
      return can_reopen(nc);    
    }
                            
    public NonConformance(ApexPages.StandardController controller) {
      try{
        if (controller != null) {
            if (controller.getRecord() != null) {
                this.Non_Conformance_id = ((non_Conformance__c)controller.getRecord()).id;
            }
        }
        if(Non_Conformance_id!= '' && Non_Conformance_id!= null) {
        // Get all fields
        String fieldsToReturn ='';
        
        String namespacePrepend = '';
        if ('' != QC_custom_settings.getPrefix()) {
            namespacePrepend =(QC_custom_settings.getPrefix()==null)?'': QC_custom_settings.getPrefix()+'__'; 
        }
        
        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrepend + 'Non_Conformance__c').getDescribe().fields.getMap();
        for( String fieldName : fieldMap.keySet() ) {
            if(fieldsToReturn != '') {
                fieldsToReturn += ', ';
            }
            fieldsToReturn += fieldName;
            Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
            String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
            if (relationshipName != null && relationshipName.endsWith('__r')) {
                fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
                if (relationshipName.equals(namespacePrepend + 'Reporter__r')) {
                    fieldsToReturn += ', ' + relationshipName + '.FirstName' + ', ' + relationshipName + '.LastName';
                }
            }
        }
        
        fieldsToReturn += ', Owner.Name, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
        
        // Build query string
        String selectAllFieldsForNC = '';
        selectAllFieldsForNC += 'select ' + fieldsToReturn + ' from Non_Conformance__c where id = \'' + Non_Conformance_id + '\' limit 1';
        system.debug('Query is: ' + selectAllFieldsForNC);
        nc = database.query(selectAllFieldsForNC);
    } else {
        nc = new non_Conformance__c();
    }
    String ncId=((Non_Conformance__c)controller.getRecord()).id;
    populateNCTasks(ncId);
    String pg=ApexPages.currentPage().getParameters().get('pg');
    System.debug('NonConformance  pg  '+pg);
    
    if(pg=='nc_reference'){
    	populateNCReferences(ncId);
    }
    
   }catch(Exception ex){
   	   System.debug('Exception In  NonConformance    '+ex.getMessage());
   } 
   
  }
 
    public Integer getTotalTasks(){
          return (tasksWithSequences!=null)? tasksWithSequences.size():0;
    }
    public Integer getContainmentTaskStep(){
        return (tasksWithStepNumber!=null) ? tasksWithStepNumber.get('Containment@'+conTaskStatus+'@'+conCurrentApproverSeq+'@'+isConApprovalNeeded) : 0;
    }
    public Integer getImplementationTaskStep(){
        return (tasksWithStepNumber!=null) ? tasksWithStepNumber.get('Implementation@'+implTaskStatus+'@'+implCurrentApproverSeq+'@'+isImplApprovalNeeded) : 0;
    }
    public Integer getInvestigationTaskStep(){
        return (tasksWithStepNumber!=null) ? tasksWithStepNumber.get('Investigation@'+invTaskStatus+'@'+invCurrentApproverSeq+'@'+isInvApprovalNeeded) : 0;
    }
    public Integer getDispositionTaskStep(){
        return (tasksWithStepNumber!=null) ? tasksWithStepNumber.get('Disposition@'+dispTaskStatus+'@'+dispCurrentApproverSeq+'@'+isDispApprovalNeeded) : 0;
    }
    public Integer getClosureTaskStep(){
       return (tasksWithStepNumber!=null) ? tasksWithStepNumber.get('Closure@'+cloTaskStatus+'@'+cloCurrentApproverSeq+'@'+isCloApprovalNeeded) : 0; 
    }
    public void populateNCTasks(String ncId){
    	try{
    	    Map<Double,List<String>> createdTasksWithSeq= new Map<Double,List<String>>();
        	adhocTaskDetails=new List<String>();
        	leastSequence = 0;
            Map<String,List<General_Task__c>> allTasks=new Map<String,List<General_Task__c>>();
            List<General_Task__c> allTaskList=null;
            List<String> createdTasks=null;
            currentTask=ApexPages.currentPage().getParameters().get('task'); 
            List<SObject> sObjects;
            General_Task__c genTaskObj;
            String ncStatus=null;
            System.debug('NonConformance.populateNCTasks  ncId   '+ncId);
            List<SObject> tmpTaskList;
            myList = new List<Decimal>();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Allowed_Days__c,Note_To_Approver_Owner_DueDate__c ,Initial_Submitter__c ,AdhocTask_Title__c,New_Due_Date__c ,New_Owner__c,New_Owner__r.Name,Due_Date__c,Status__c,Sequence_Position__c,ChangeFieldApprovalStatus__c , Owner__c,OwnerName__c,Owner__r.Name,Investigation_Tools__c,Investigation_Summary__c,OwnerId,Owner.Name,Non_Conformance__c,RecordType.Name,Note_To_Approver__c,Non_Conformance__r.NC_Status__c,Add_Effectiveness_verificiation__c,CurrentApprovalSequenceNumber__c,Approval_Required__c');
            //String leastSeqFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Sequence_Position__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                    for(SObject sobj : Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Non_Conformance__c=:ncId  ORDER BY Id DESC LIMIT 999')){
                    	    genTaskObj=(General_Task__c)sobj;
                    	    allTaskList=allTasks.get(genTaskObj.RecordType.Name);
                    	    if(allTaskList==null){
                    	    	allTaskList=new List<General_Task__c>();
                    	    	allTasks.put(genTaskObj.RecordType.Name,allTaskList);
                    	    }
                    	    allTaskList.add(genTaskObj);
                    }
                    System.debug('NonConformance allTasks    '+allTasks);
                    if(!allTasks.isEmpty()){
                    	tmpTaskList=allTasks.get('Containment');
                        contTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                        if(contTask!=null){
	                        hasContTask='Yes';
	                        if(contTask.Status__c!=null){
	                            createdTasks=createdTasksWithSeq.get(contTask.Sequence_Position__c);
	                            if(createdTasks==null){
	                                createdTasks=new List<String>();
	                                createdTasksWithSeq.put(contTask.Sequence_Position__c,createdTasks);
	                            }
	                            conCurrentApproverSeq=String.valueOf(contTask.CurrentApprovalSequenceNumber__c);
	                            conTaskStatus=contTask.Status__c;
	                            isConApprovalNeeded=contTask.Approval_Required__c;
	                            createdTasks.add(contTask.RecordType.Name+'@'+conTaskStatus+'@'+conCurrentApproverSeq+'@'+isConApprovalNeeded+'@'+contTask.Id);
	                        }
                            isContTaskPresent=false;
                        }else{
                          isContTaskPresent=true;  
                        }
                        tmpTaskList=allTasks.get('Disposition');
                        dispTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                        if(dispTask!=null){
	                        hasDispTask='Yes';
	                        if(dispTask.Status__c!=null){
	                            createdTasks=createdTasksWithSeq.get(dispTask.Sequence_Position__c);
	                            if(createdTasks==null){
	                                createdTasks=new List<String>();
	                                createdTasksWithSeq.put(dispTask.Sequence_Position__c,createdTasks);
	                            }
	                            dispCurrentApproverSeq=String.valueOf(dispTask.CurrentApprovalSequenceNumber__c);
	                            dispTaskStatus=dispTask.Status__c;
	                            isDispApprovalNeeded=dispTask.Approval_Required__c;
	                            createdTasks.add(dispTask.RecordType.Name+'@'+dispTaskStatus+'@'+dispCurrentApproverSeq+'@'+isDispApprovalNeeded+'@'+dispTask.Id);
	                        }
	                        isDispTaskPresent=false;
                       }else{
                         isDispTaskPresent=true; 
                       }
                    //Investigation
                       tmpTaskList=allTasks.get('Investigation');
                       invTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                       if(invTask!=null){
                        hasInvTask='Yes';
                        if(invTask.Status__c!=null){
                            createdTasks=createdTasksWithSeq.get(invTask.Sequence_Position__c);
                            if(createdTasks==null){
                                createdTasks=new List<String>();
                                createdTasksWithSeq.put(invTask.Sequence_Position__c,createdTasks);
                            }
                            invCurrentApproverSeq=String.valueOf(invTask.CurrentApprovalSequenceNumber__c);
                            invTaskStatus=invTask.Status__c;
                            isInvApprovalNeeded=invTask.Approval_Required__c;
                            createdTasks.add(invTask.RecordType.Name+'@'+invTaskStatus+'@'+invCurrentApproverSeq+'@'+isInvApprovalNeeded+'@'+invTask.Id);
                        }
                        isInvTaskPresent=false;
                      }else{
                       isInvTaskPresent=true;  
                      }
                    //Implementation
                    tmpTaskList=allTasks.get('Implementation');
                    implTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                    if(implTask!=null){
                        hasImplTask='Yes';
                        if(implTask.Status__c!=null){
                            createdTasks=createdTasksWithSeq.get(implTask.Sequence_Position__c);
                            if(createdTasks==null){
                                createdTasks=new List<String>();
                                createdTasksWithSeq.put(implTask.Sequence_Position__c,createdTasks);
                            }
                            implCurrentApproverSeq=String.valueOf(implTask.CurrentApprovalSequenceNumber__c);
                            implTaskStatus=implTask.Status__c;
                            isImplApprovalNeeded=implTask.Approval_Required__c;
                            createdTasks.add(implTask.RecordType.Name+'@'+implTaskStatus+'@'+implCurrentApproverSeq+'@'+isImplApprovalNeeded+'@'+implTask.Id);
                        }
                        isImplTaskPresent=false;
                    }else{
                       isImplTaskPresent=true; 
                    }
                    tmpTaskList=allTasks.get('Closure');
                    closTask=tmpTaskList==null?null:(General_Task__c)tmpTaskList[0];
                    if(closTask!=null){
	                    ncStatus=closTask.Non_Conformance__r.NC_Status__c;
	                    cloTaskStatus=closTask.Status__c;
	                    cloCurrentApproverSeq=String.valueOf(closTask.CurrentApprovalSequenceNumber__c);
	                    isCloApprovalNeeded=closTask.Approval_Required__c;
	                    cloTaskId=closTask.Id;
                    }
                    //Adhoc task  
                    adhocTasks=allTasks.get('AdhocTask');
                    if(adhocTasks!=null){
	                    for(General_Task__c adhocTask : adhocTasks){
	                    	adhocTaskDetails.add(adhocTask.RecordType.Name+'@'+adhocTask.AdhocTask_Title__c+'@'+adhocTask.Id+'@'+adhocTask.Status__c+'@'+adhocTask.CurrentApprovalSequenceNumber__c+'@'+adhocTask.Approval_Required__c);
	                    }
	                    adhocTasks=adhocTasks.isEmpty()?null:adhocTasks;
                    }
                    addNewadhocTask = new General_Task__c();
                        
                  	for(List<General_Task__c> genTaskList: allTasks.values()){
                         for(General_Task__c genTask : genTaskList ){
                              if(genTask.RecordType.Name !='Closure'){
                                if(genTask.Status__c=='Open' || genTask.Status__c=='Pending Approval' || genTask.Status__c=='Pending ActionPlan' ||  genTask.Status__c=='Disposition Pending Completion'){
                                    myList.add(genTask.Sequence_Position__c);
                                }
                              }
                         }
                	}
                	myList.sort();
                    if(!myList.isEmpty()){
                      leastSequence = myList.get(myList.size()-1);
                    }else{
                	 leastSequence = 0;    
                    }
                	System.debug('all tasks-----leastsequences--------->'+allTasks);
                	System.debug('all tasks-----myList--------->'+myList);
               }
           }
            else{
                System.debug('NonConformance.populateNCTasks  : No Acesss to object  General_Task__c and fields to get tasks'+queryFieldNames);
            }
            if(ncStatus!='NC Workflow' && hasContTask==null && hasDispTask==null &&  hasInvTask==null && hasImplTask==null && closTask==null){
                hasContTask='Yes';
                hasDispTask='Yes';
                hasInvTask='Yes';
                hasImplTask='Yes';
            }
            System.debug('NonConformance.populateNCTasks createdTasksWithSeq    '+createdTasksWithSeq);
            if(ncStatus=='NC Workflow' || ncStatus=='Closed' || ncStatus=='Reopened' || ncStatus=='Void'){
                tasksWithSequences=new List<String>();
                if(createdTasksWithSeq.size()>0){
                    List<Double> seqList=new List<Double>(createdTasksWithSeq.keySet());
                    seqList.sort();
                    for(Double seq : seqList){
                        tasksWithSequences.addAll(createdTasksWithSeq.get(seq));
                    }
                 }
                 tasksWithSequences.add('Closure@'+cloTaskStatus+'@'+cloCurrentApproverSeq+'@'+isCloApprovalNeeded+'@'+cloTaskId);
                 Integer resStep=3;
                 tasksWithStepNumber=new Map<String,Integer>();
                 for(String task : tasksWithSequences){
                        resStep++;
                        tasksWithStepNumber.put(task,resStep);
                 }
                 resStep++;
                 tasksWithStepNumber.put('nc_details',resStep);
            }
          
        }catch(Exception ex){
            contTask=null;
            dispTask=null;
            invTask=null;
            implTask=null;
            closTask=null;
            System.debug('Exception IN NonConformance.populateNCTasks  '+ex.getMessage());
        }
        System.debug('NonConformance.populateNCTasks contTask   '+contTask+'   dispTask  '+ dispTask+'  invTask   '+ invTask+'  implTask   '+implTask+' closTask  '+closTask);
        System.debug('NonConformance.populateNCTasks hasContTask   '+hasContTask+'   hasDispTask  '+ dispTask+'  hasInvTask   '+ invTask+'  hasImplTask  '+hasImplTask);
        System.debug('NonConformance.populateNCTasks tasksWithStepNumber  '+tasksWithStepNumber+'   tasksWithSequences   '+tasksWithSequences);
        System.debug('NonConformance.populateNCTasks adhocTaskDetails    '+adhocTaskDetails);
 
    }
    
    public void populateNCReferences(String ncId){
       try{
       	   ncReferences=new List<NC_CAPA__c>();
       	   String queryFieldNamesNCCAPA = QC_DynamicObjectHandler.getAccessibleFields('NC_CAPA__c','Id,CAPA__r.Name,CAPA__r.CAPA_Status__c,CAPA__r.CAPA_Source__c,CAPA__r.Title__c,CAPA__r.Owner.Name,Non_Conformance__c');
           if(queryFieldNamesNCCAPA!=null && queryFieldNamesNCCAPA!=''){
           	   ncReferences=database.query('SELECT '+queryFieldNamesNCCAPA+' FROM NC_CAPA__c WHERE Non_Conformance__c = :ncId'); 
           }
           System.debug('NonConformance.populateNCReferences ncReferences    '+ncReferences);
       }
       catch(Exception ex){
       	  System.debug('Exception In NonConformance.populateNCReferences   '+ex.getMessage());
       	  ERR_Handler.processError(ex, ERR_Handler_API.Context.NCM);
       }
    }
   
    @RemoteAction
    public static Integer followNC(String ncId,String userId){
    	try{
    		String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Followers__c');
    		if(queryFieldNames != null && queryFieldNames != ''){
    			List<Non_Conformance__c> ncs = Database.query('SELECT '+queryFieldNames+' FROM Non_Conformance__c WHERE Id=:ncId');
    			if(!ncs.isEmpty()){
    			  ncs[0].Followers__c=(ncs[0].Followers__c==null)?userId:(ncs[0].Followers__c+';'+userId);
    			  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','Followers__c','update')){
    			   update ncs;
    			   return 0;
    			  }
    			  else{
    			  	System.debug('NonConformance followNC  No update access to the fields  '+queryFieldNames);
    			  }
    			}
    		}
    		else{
    		  System.debug('NonConformance followNC  No access to the fields  '+queryFieldNames);
    		}
        }
    	catch(Exception ex){
    		System.debug('Exception In NonConformance.followNC   '+ex.getMessage());
    	}
    	return -1;
    }
    
    @RemoteAction
    public static Integer unFollowNC(String ncId,String userId){
    	try{
    		String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Followers__c');
    		String newFollowers='';
    		String[] existingFollowers;
    		if(queryFieldNames != null && queryFieldNames != ''){
    			List<Non_Conformance__c> ncs = Database.query('SELECT '+queryFieldNames+' FROM Non_Conformance__c WHERE Id=:ncId');
    			if(!ncs.isEmpty()){
    			  existingFollowers=ncs[0].Followers__c.split(';');
    			  for(String existingFollower : existingFollowers){
    			  	 if(userId.equalsIgnoreCase(existingFollower)){
    			  	 	continue;
    			  	 }
    			  	 newFollowers+=existingFollower;
    			  }
    			  ncs[0].Followers__c=newFollowers;
    			  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','Followers__c','update')){
    			   update ncs;
    			   return 0;
    			  }
    			  else{
    			  	System.debug('NonConformance followNC  No update access to the fields  '+queryFieldNames);
    			  }
    			}
    		}
    		else{
    		  System.debug('NonConformance followNC  No access to the fields  '+queryFieldNames);
    		}
        }
    	catch(Exception ex){
    		System.debug('Exception In NonConformance.followNC   '+ex.getMessage());
    	}
    	return -1;
    }
    
    @RemoteAction
    public static Map<String,String> createNCTasks(List<String> adhocTasks,Map<String,List<String>> taskData,String ncId,boolean isSubmit,boolean isApprovalNeeded,boolean fromHeader){
        System.debug('NonConformance createNCTasks tasks   '+taskData+'   taskData.keySet()   '+taskData.keySet()+'    isSubmit   '+isSubmit);
        fromHeader=(fromHeader==null)?false:fromHeader;
        List<General_Task__c> tasks=new List<General_Task__c>();
        Map<String,General_Task__c> existingTaskMap=new Map<String,General_Task__c>();
        Map<String,General_Task__c> existingTaskWithId=new Map<String,General_Task__c>();
        List<String> data=null;
        General_Task__c task=null;
        Map<String,String> result=new Map<String,String>();
        Set<Id> ncGenTaskIds=new Set<Id>();
        String queryFieldNames;
        try{
            List<General_Task__c> existingTasks=null;
            List<NC_General_Task__c> exstingNCGenTasks=null;
            queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Non_Conformance__c,Status__c,RecordType.Name, Sequence_Position__c, Allowed_Days__c, Due_Date__c ,Note_To_Approver__c');
            if(queryFieldNames != null && queryFieldNames != ''){
                Set<String> recTypes=taskData.keySet();
                existingTasks=Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Non_Conformance__c=:ncId');
                queryFieldNames=QC_DynamicObjectHandler.getAccessibleFields('NC_General_Task__c', 'Non_Conformance__c,General_Task__c');
                 if(queryFieldNames != null && queryFieldNames != ''){
                    exstingNCGenTasks=Database.query('SELECT '+queryFieldNames+' FROM NC_General_Task__c WHERE Non_Conformance__c=:ncId');
                    for(NC_General_Task__c ncGenTask : exstingNCGenTasks){
                        ncGenTaskIds.add(ncGenTask.General_Task__c);
                    }
                 }
                 else{
                    System.debug('NonConformance.createNCTasks  : No Acesss to object  NC_General_Task__c and fields for existingNCGenTasks    '+queryFieldNames);
                 }
            }
            else{
              System.debug('NonConformance.createNCTasks  : No Acesss to object  General_Task__c and fields for existingGenTasks   '+queryFieldNames);
            }
            System.debug('NonConformance createNCTasks existingTasks   '+existingTasks);
            if(!existingTasks.isEmpty()){
                for(General_Task__c existingTask : existingTasks){
                    existingTaskMap.put(existingTask.Non_Conformance__c+'@'+String.valueOf(existingTask.RecordType.Name), existingTask);
                    existingTaskWithId.put(existingTask.Id,existingTask);
                }
            }
            for(String recordTypeName : taskData.keySet()){
                data = taskData.get(recordTypeName);
                task=existingTaskMap.get(ncId+'@'+recordTypeName);
                task=(task==null)?new General_Task__c():task;
                task.Sequence__c=data[0];
                task.Sequence_Position__c=Integer.valueOf(data[0]);
                task.OwnerId=data[1];
                task.Allowed_Days__c=Integer.valueOf(data[2]);
                task.Due_Date__c=(data[3]==null)?null:Date.parse(data[3]);
                if(task.Non_Conformance__c==null)
                    task.Non_Conformance__c=ncId;
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
                    if(task.Non_Conformance__c==null)
                         task.Non_Conformance__c=ncId;
                    task.RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId();
                    task.Status__c=(isSubmit)?'Created':task.Status__c;
                    system.debug('tasks adding----------------------->'+task.Adhoc_Sequence__c+' '+task.Sequence_Position__c+' '+task.Owner__c+' '+ task.Due_Date__c+' '+task.AdhocTask_Title__c+' '+task.Non_Conformance__c+' '+ task.RecordTypeId+' '+task.Status__c); 
                    tasks.add(task);
                    system.debug('tasks adding----------------------->'+Integer.valueOf(details[0])+' '+details[1]+' '+Integer.valueOf(details[2])+' '+Date.parse(details[3])+' '+details[4]+' '+ncId); 
                   
                }
            }
            
            
            System.debug('NonConformance.createNCTasks tasks----> '+ tasks);
            
            if(!tasks.isEmpty()){
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,Non_Conformance__c,RecordTypeId','create') && QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Sequence__c,Status__c,Sequence_Position__c,Owner__c,Allowed_Days__c,Due_Date__c,RecordTypeId','update')){
                     if(isSubmit && !fromHeader){
                        if(tasks.size()==1 || tasks[0].RecordTypeId==Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()){ //Only CLosure Task Is Selected.
                            tasks[0].Status__c='Open';
                        }
                        else{
                           Integer minSeq=1000;
                           Integer actSeq;
                           for(General_Task__c seqChkTask : tasks){
                              System.debug('NonConformance createNCTasks seqChkTask.RecordTypeId  '+seqChkTask.RecordTypeId+'   '+(seqChkTask.RecordTypeId!=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId()));
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
                    System.debug('NonConformance createNCTasks tasks with sequences....'+tasks);
                    upsert tasks;
                    List<NC_General_Task__c> ncGenTasks=new List<NC_General_Task__c>();
                    NC_General_Task__c ncGenTaskObj=null;
                    for(General_Task__c savedTask : tasks){
                            System.debug('NonConformance createNCTasks savedTask '+savedTask+'   savedTask.Id   '+savedTask.Id);
                            if(!ncGenTaskIds.contains(savedTask.Id)){
                                ncGenTaskObj=new NC_General_Task__c();
                                ncGenTaskObj.General_Task__c=savedTask.Id;
                                ncGenTaskObj.Non_Conformance__c=ncId;
                                ncGenTasks.add(ncGenTaskObj);
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
                        System.debug('NonConformance.createNCTasks  : No Acesss to object  Approver__c and fields for existingApprovers '+queryFieldNames);
                      }
                      if(!existingApprovers.isEmpty()){
                        if(Approver__c.sObjectType.getDescribe().isDeletable()){
                          delete existingApprovers;
                         }
                      }
                  }
                  if(!ncGenTasks.isEmpty()){
                     if(QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_General_Task__c','General_Task__c,Non_Conformance__c','create'))
                        insert ncGenTasks;
                     else{
                        System.debug('NonConformance.createNCTasks  : No Acesss to object  NC_General_Task__c');
                     }
                 }
            }
            else{
                  System.debug('NonConformance.createNCTasks  : No Acesss to object  General_Task__c fields  ');
            } 
          }
           
        }
        catch(Exception ex){
            System.debug('Exception In NonConformance.createNCTasks   '+ex.getMessage());
            
        }
        System.debug(' NonConformance createNCTasks result '+result);
        return result;
    }
    
    
    //ADHOC TASK--------------------
     @RemoteAction
    public static Map<String,List<String>> getAdhocData(String typeofapprover){
        Schema.DescribeFieldResult fieldResult = General_Task__c.Adhoc_Sequence__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String,List<String>> dataMap=new Map<String,List<String>>();
        List<String> data =new List<String>();
        for( Schema.PicklistEntry f : ple){
            data.add(f.getValue());
        }
        dataMap.put('seqs',data);
      
        String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id,Name');
        Set<id> approvergroupid=new set<id>();  
        
        string approvalaccessiable=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName'); //Added this for overcoming the field level security while creating managed package
        
        if(approvalaccessiable!=null && approvalaccessiable!='') {
            set<id> UserSetid=new set<id>();           
            List<Group> groups=Database.query(' select '  + approvalaccessiable +   ' from Group where DeveloperName =:typeofapprover ');
            for(Group g : groups){
                UserSetid.add(g.id);
            }
            vfsearch.FinaluserIDSet=new set<id>();
            vfsearch.getUserIds(UserSetid);  
            approvergroupid.addAll(vfsearch.FinaluserIDSet);         
        }
         List<User> users = new List<User>();
     
        if(queryFieldNamesUsers !=null && queryFieldNamesUsers != ''){
           users=Database.query('SELECT ' + queryFieldNamesUsers + ' FROM User WHERE id IN:approvergroupid ORDER BY Id limit 100');
        }    
        data =new List<String>();
        for(User user : users){
             data.add(user.Id+'@'+user.Name);
        }
        
        dataMap.put('usrs',data);
       
        System.debug(' NonConformance.getAdhocData  ------------------->dataMap   '+dataMap);
        return dataMap; 
    }
    //-------------------
    
    @remoteAction
  public static boolean deleteProduct(string id){
    Savepoint sp = Database.setSavepoint();
    List<NC_Product__c> prods;
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('NC_Product__c', 'id');
    if(queryFieldNames != null && queryFieldNames != '')
    {
        prods = database.query('Select '+ queryFieldNames +' from NC_Product__c where id = :id');
    }
    //List<NC_Product__c> prods = [select id from NC_Product__c where id = :id];
    try{
     if(prods != null && prods.size() > 0)
        {
            if(NC_Product__c.sObjectType.getDescribe().isDeletable())
            {
                delete prods; 
            }
        }
        return true;
    }catch(exception e){
      Database.rollback(sp);
      ERR_Handler.processError(e, ERR_Handler_API.Context.PROD);        
      return false;
    } 
  }
  
  @remoteAction
  public static boolean deleteBatch(string id){
    Savepoint sp = Database.setSavepoint();
    List<Product_Lot_Numbers__c> b;
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Product_Lot_Numbers__c', 'id');
    if(queryFieldNames != null && queryFieldNames != '')
    {
        b = database.query('Select '+ queryFieldNames +' from Product_Lot_Numbers__c where id = :id');
    }

    //List<Product_Lot_Numbers__c> b = [select id from Product_Lot_Numbers__c where id = :id];
    try{
         if(b != null && b.size() > 0)
          {
                if(Product_Lot_Numbers__c.sObjectType.getDescribe().isDeletable())
                {   
                    delete b; 
                }
          }
        return true;
    }catch(exception e){
      Database.rollback(sp);
      ERR_Handler.processError(e, ERR_Handler_API.Context.PROD);        
      return false;
    } 
  }
  
  @RemoteAction
public static NC_Product__c getRemoteNCP(String ncpid){
  
  if(ncpid != null )
    {
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('NC_Product__c', 'id,Product__r.Product_Number__c,Product__r.Name,Manufacturing_Site__r.Name,Defect_Count__c,Defect_Count_Unique__c,Non_Conformance__r.Defect__r.Name,Non_Conformance__r.Product__c,Non_Conformance__r.Product__r.Name,Non_Conformance__r.Initiating_Site__c,Non_Conformance__r.Initiating_Site__r.Name,Non_Conformance__r.Closed__c,Product__c,Manufacturing_Site__c,Primary_Product__c,Non_Conformance__r.NC_Type__c');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            List<NC_Product__c> ncpList = database.query('Select '+ queryFieldNames +' from NC_Product__c where id = :ncpid limit 1');
            return ncpList[0];
        }
        else
        {
            return new NC_Product__c();
        }
    
    }
  else
    return new NC_Product__c();  
}

public NC_Product__c getNCP(){
   return getRemoteNCP(ncpid);
}

@RemoteAction
public static Product_Lot_Numbers__c getLot(string lotid){

 if(lotid != null)
    {
     String queryFieldSOfNCPD = QC_DynamicObjectHandler.getAccessibleFields('NC_Product_Defect__c', 'Id,Defect__c,Defect__r.Name');
     String queryFieldSOfNCPLTN = QC_DynamicObjectHandler.getAccessibleFields('Product_Lot_Numbers__c', 'id,Defect_Codes__c,Defect_Count__c,Lot_Bacth_Number__c,Lot_Quantity_Affected__c,NC_Product__r.Non_Conformance__r.Product__c,NC_Product__c,UOM__c');
     
       if(queryFieldSOfNCPD != null && queryFieldSOfNCPD != '' && queryFieldSOfNCPLTN != null && queryFieldSOfNCPLTN != '')
        {
             List<Product_Lot_Numbers__c> plnList = database.query('Select '+ queryFieldSOfNCPLTN +', (select ' + queryFieldSOfNCPD + ' from NC_Product_Defects__r) from Product_Lot_Numbers__c where id = :lotid limit 1');
             return plnList[0];
        }
        else
        {
            return new Product_Lot_Numbers__c();
        }
     
      
    }
    else
        return new Product_Lot_Numbers__c();  
}

public List<Product_Lot_Numbers__c> getLots(){
  if(ncpid != null )
    {
     String queryFieldSOfNCPD = QC_DynamicObjectHandler.getAccessibleFields('NC_Product_Defect__c', 'Id,Defect__c,Defect__r.Name');
     String queryFieldSOfNCPLTN = QC_DynamicObjectHandler.getAccessibleFields('Product_Lot_Numbers__c', 'Id,Defect_Codes__c,Defect_Count__c,Lot_Bacth_Number__c,Lot_Quantity_Affected__c,NC_Product__r.Non_Conformance__r.Product__c,NC_Product__c,UOM__c');
     
     if(queryFieldSOfNCPD != null && queryFieldSOfNCPD != '' && queryFieldSOfNCPLTN != null && queryFieldSOfNCPLTN != '')
     {
        return database.query('Select '+ queryFieldSOfNCPLTN +', (select ' + queryFieldSOfNCPD + ' from NC_Product_Defects__r) from Product_Lot_Numbers__c where NC_Product__c = :ncpid');
     }
     else
     {
        return new List<Product_Lot_Numbers__c>();
     }
    
    }
   else
     return new List<Product_Lot_Numbers__c>();
}

public List<Non_Conformance__c> getNCList()
{
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Name,OwnerId,Owner.Name,NC_Type__c,NC_Source__c,Product__r.Name,Process__r.Name,Defect__r.Name,BusinessUnit__c,Initiating_Site__r.Name,CreatedDate,CreatedBy.Name,NC_Status__c,Occurance_Date__c');
    
    if(queryFieldNames != null && queryFieldNames != '')
    {
        List<Non_Conformance__c> ncList = database.query ('select ' + queryFieldNames + ' from Non_Conformance__c where NC_Status__c != \'Closed\' ORDER BY createddate DESC LIMIT 10000');
        return ncList;
     }
     else
         return null;
}

@RemoteAction

public static String createNCCAPAJunction(String ncId,String ncName,String defectStatement,String capaNumber){
	try{
		String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Name,CAPA_Source__c,Source_Number__c,Problem_Statement__c');
		NC_CAPA__c ncCapa;
		if(queryFieldNames!=null && queryFieldNames!=''){
			List<CAPA__c> capaList=Database.query('SELECT '+queryFieldNames+' FROM CAPA__c WHERE Name=:capaNumber');
			queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('NC_CAPA__c', 'Non_Conformance__c,CAPA__c');
			if(!capaList.isEmpty()){
				  String capaId=capaList[0].Id;
				  List<NC_CAPA__c> ncCapaList=Database.query('SELECT '+queryFieldNames+' FROM NC_CAPA__c WHERE Non_Conformance__c=:ncId AND CAPA__c=:capaId');
				  ncCapa=ncCapaList.isEmpty()?new NC_CAPA__c():ncCapaList[0];
				  ncCapa.Non_Conformance__c=ncId;
				  ncCapa.CAPA__c=capaList[0].Id;
				  
				  upsert ncCapa;
				  
				  capaList[0].CAPA_Source__c='NCR';
				  capaList[0].Source_Number__c=ncName;
				  capaList[0].Problem_Statement__c=defectStatement;
				  
				  upsert capaList[0];
				  
			}
		}
		System.debug('NonConformance.createNCCAPAJunction  ncCapa '+ncCapa);
		return ncCapa==null?'':ncCapa.CAPA__c;
	}
	catch(Exception ex){
		System.debug('Exception In NonConformance.createNCCAPAJunction  '+ex.getMessage());
		return '';
	}
}

@RemoteAction
public static String createCAPAFromNC(String ncId,String ncNumber,String problemStmt){
        CAPA__c capa=null;
        try{
             String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Name,CAPA_Source__c,Source_Number__c,Problem_Statement__c');
             if(queryFieldNames != null && queryFieldNames != ''){
                  capa=new CAPA__c();
                  capa.Source_Number__c=ncNumber;
                  capa.CAPA_Source__c='NCR';
                  capa.Problem_Statement__c=problemStmt;
                  insert capa;
                  String capaName='';
                  String capaId=capa.Id;
                  List<CAPA__c> capaList=Database.query('SELECT '+queryFieldNames+' FROM CAPA__c WHERE Id =:capaId');
                  capaName=capaList.isEmpty()?'':capaList[0].Name;
                  queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Name,CAPA_Number__c,NC_Resolution_Code__c');
                  if(queryFieldNames != null && queryFieldNames != ''){
                  	  List<Non_Conformance__c> ncList=Database.query('SELECT '+queryFieldNames+' FROM Non_Conformance__c WHERE Id =:ncId');
                  	  System.debug('NonConformance.createCAPAFromNC    ncList  '+ncList+'   capaName   '+capaName+'  capa.Id  '+capa.Id);
                  	  if(!ncList.isEmpty()){
                  	  	  ncList[0].CAPA_Number__c=capaName;
                  	  	  ncList[0].NC_Resolution_Code__c='Addressed through CAPA';
                  	  	  ncList[0].New_Capa_Number__c=capaName;
                 	  	  update ncList[0];
                  	  }
                  }
                  System.debug('NonConformance.createCAPAFromNC    capa  '+capa+'   id   '+capa.Id);
             }
             else{
               System.debug('NonConformance.createCAPAFromNC  : No Acesss to object  CAPA__c and fields for existingGenTasks   '+queryFieldNames);
             }
            
        }
        catch(Exception ex){
             System.debug('Exception In NonConformance.createCAPAFromNC   '+ex.getMessage());
        }
        return (capa==null)?'':capa.Id;
    }

	

}