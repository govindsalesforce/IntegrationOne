/*
     v1.0    Qualityze_Inc(GP)                       Initial Version
    
     v1.0.1  Qualityze_Inc(GP)      13-JUL-2016      To fix issue 00740 : Update Dashboard to show Change Capa Owner Approvals
    
     v1.1   Qualityze_Inc(GP)      09-AUG-2016       To fix issue 00781 : Configurable Dashboard / Sidebar Menu.
    
                                                     Need to display on dashboard / sidebar based on the configuration set in custom settings(QC_Settings)

														1.Enable NC setting displays the data related to NC.
														2.Enable CAPA setting displays the data related to CAPA.   
														
	v1.2   Qualityze_Inc(GP)     18-AUG-2016       To Add Document Owner Dashboard. 
    
*/
public with sharing class Dashboard_Controller{ 
	public Map<String,List<General_Task__c>> ncTasks{get;set;}
	public Map<String,List<General_Task__c>> capaTasks{get;set;}
	public Map<String,List<Document_Profile__c>> docProfiles{get;set;}
	public Map<String,List<General_Task__c>> docTasks{get;set;}
	public Map<String,List<General_Task__c>> cmTasks{get;set;}
    
	
	public List<General_Task__c> allNCTasks{get;set;}
	public List<General_Task__c> allCAPATasks{get;set;}
	public List<General_Task__c> allCMTasks{get;set;}
	public List<ActionItemWrapper> cmActionItems{get;set;}
	public List<General_Task__c> allDOCTasks{get;set;}
	public List<Document_Profile__c> allDOCProfiles{get;set;}
    
    public List<General_Sub_Task__c> dispSecs{get;set;}
    public List<General_Sub_Task__c> actionPlans{get;set;}
    public List<General_Sub_Task__c> capaActionPlans{get;set;}
    
    public List<NoteWrapper> notes{get;set;}
    
    public List<String> alerts{get;set;}
    public List<String> capaAlerts{get;set;}
    public List<String> docAlerts{get;set;}
    public List<String> cmAlerts{get;set;}
    
    public List<String> updates{get;set;}
    public List<String> capaUpdates{get;set;}
    public List<String> docUpdates{get;set;}
    public List<String> cmUpdates{get;set;}
    
    private static List<ProcessInstanceWorkitem> PendingapprovalList{get;set;}
    
    //v1.1 start
    private static Boolean isNCDashboardEnabled;
    private static Boolean isCAPADashboardEnabled;
    private static Boolean isDOCDashboardEnabled;
    //v1.1 end
    
    static{
      //v1.1 start
      isNCDashboardEnabled=QC_custom_settings.getEnableNC();
      isCAPADashboardEnabled=QC_custom_settings.getEnableCAPA();
      isDOCDashboardEnabled=QC_custom_settings.getEnableDOC();
      PendingapprovalList=new List<ProcessInstanceWorkitem>();
      //v1.1 end
      if(isNCDashboardEnabled || isCAPADashboardEnabled || isDOCDashboardEnabled){ // //v1.1
    	String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,OriginalActorId,actorid');
        //system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
        //system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String processDefFieldNames =QC_DynamicObjectHandler.getAccessibleFields('ProcessDefinition', 'DeveloperName,Name');
        String userId=UserInfo.getUserId();
        if(queryFieldSOfPW != null && queryFieldSOfPW != '' && queryFieldSOfPI != null && queryFieldSOfPI != '' && processDefFieldNames != null && processDefFieldNames != '' ){
	       PendingapprovalList = new List<ProcessInstanceWorkitem>([Select ProcessInstance.TargetObjectId,ProcessInstance.ProcessDefinition.DeveloperName,ProcessInstance.ProcessDefinition.Name,ProcessInstance.Status, OriginalActorId, ActorId  from ProcessInstanceWorkitem where  ProcessInstance.Status= 'Pending' and OriginalActorId = :userId]);
        }
      }
        
    }
    
    public Dashboard_Controller(){
     Integer taskSize=0;
     Integer capaTaskSize=0;
      try{
      	if(isNCDashboardEnabled || isCAPADashboardEnabled || isDOCDashboardEnabled){ //v1.1
      	   Map<String,List<Sub_Change_Management__c>> tempCMActionItems=new Map<String,List<Sub_Change_Management__c>>();
      	   String queryFieldNames =QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Name,Non_Conformance__c,Non_Conformance__r.Name,Non_Conformance__r.NC_Status__c,Non_Conformance__r.Followers__c,Non_Conformance__r.LastModifiedDate,Non_Conformance__r.OwnerId,CAPA__c,CAPA__r.Name,CAPA__r.CAPA_Status__c,CAPA__r.Followers__c,CAPA__r.LastModifiedDate,CAPA__r.OwnerId,Change_Management__c,Change_Management__r.Name,Change_Management__r.Status__c,Change_Management__r.Followers__c,Change_Management__r.LastModifiedDate,Change_Management__r.OwnerId,Document_Profile__c,Document_Profile__r.Name,Document_Profile__r.Status__c,Document_Profile__r.Followers__c,Document_Profile__r.LastModifiedDate,Document_Profile__r.OwnerId,Document_Profile__r.Current_Rev__c,Owner__c,OwnerId,Status__c,RecordType.Name,Sequence_Position__c,Age__c,Allowed_Days__c, Due_Date__c ,Task_Closed_Date__c,Note_To_Approver__c,CurrentApprovalSequenceNumber__c,New_Owner__c,LastModifiedDate');
           String SubTasks = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Completed__c,Action_Plan_Status__c,RecordType.Name,Name,Non_Conformance__c,Capa__c,General_Task__c,General_Task__r.Non_Conformance__r.Name,General_Task__r.CAPA__r.Name,Disposition_Type__c,LastModifiedDate,Completed_Date__c,Assigned_User__c,Disposition_Type_Status__c,Due_Date__c,Age__c,Complete__c');
           
           String loggedInUserId=UserInfo.getUserId();
           String taskStatus='Closed';
           String complteStatus='Yes';
           
           dispSecs=new List<General_Sub_Task__c>();
           actionPlans=new List<General_Sub_Task__c>();
           capaActionPlans=new List<General_Sub_Task__c>();
           String dueDate=null;
           Set<Id> loggedInUserNCs=new Set<Id>();
           
           alerts=new List<String>();
           capaAlerts=new List<String>();
           docAlerts=new List<String>();
           cmAlerts=new List<String>();
           
	       Map<DateTime,List<String>> dataByLastModifiedDateForAlerts=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForAlertsForCAPA=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForAlertsForDOC=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForAlertsForCM=new Map<DateTime,List<String>>();
	       
	       List<String> dataListForAlerts=null;
	       
	       updates=new List<String>();
	       capaUpdates=new List<String>();
	       docUpdates=new List<String>();
	       cmUpdates=new List<String>();
	       
	       Map<DateTime,List<String>> dataByLastModifiedDate=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForCAPA=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForDOC=new Map<DateTime,List<String>>();
	       Map<DateTime,List<String>> dataByLastModifiedDateForCM=new Map<DateTime,List<String>>();
	       
	       List<String> dataList=null;
	       
	       String ncFields=isNCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Id,Name,NC_Status__c,Followers__c,LastModifiedDate,OwnerId'):'';//v1.1
	       List<Non_Conformance__c> allNCList;
	       Integer numberOfDaysForAlerts=QC_custom_settings.getNumberOfDaysForAlerts();
	       numberOfDaysForAlerts=numberOfDaysForAlerts!=null?numberOfDaysForAlerts:10;
	       Integer recordAge=0;
	       String searchFollowers='(\''+loggedInUserId+'\')';
	       Set<Id> followingNCs=new Set<Id>();
	       if(ncFields !=null && ncFields!=''){
       	    //allNCList=Database.query('SELECT '+ncFields+',(SELECT '+queryFieldNames+' FROM General_Tasks__r) FROM Non_Conformance__c');
       	    for(Non_Conformance__c nc : Database.query('SELECT '+ncFields+' FROM Non_Conformance__c WHERE OwnerId=:loggedInUserId OR Followers__c INCLUDES (\''+loggedInUserId+'\') ORDER By CreatedDate LIMIT 1000')){
	       	    if(nc.OwnerId==loggedInUserId){
	                  loggedInUserNCs.add(nc.Id);
	                  //System.debug('Date.today()   '+Date.today()+' nc.LastModifiedDate   '+nc.LastModifiedDate);
	                  recordAge = Date.today().daysBetween(date.valueof(nc.LastModifiedDate));
	                  if(recordAge<=numberOfDaysForAlerts){
		                  if('Open'.equalsIgnoreCase(nc.NC_Status__c)){
				                 //System.debug(nc.Name+' - Created');
				                 dataListForAlerts=dataByLastModifiedDateForAlerts.get(nc.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(nc.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+nc.Id+'">'+nc.Name+'</a> - Created');
				          }
				          else if('Reopened'.equalsIgnoreCase(nc.NC_Status__c)){
				          	     //System.debug(nc.Name+' - Reopened');
				                 dataListForAlerts=dataByLastModifiedDateForAlerts.get(nc.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(nc.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+nc.Id+'">'+nc.Name+'</a> - Reopened');
				          }
					      else if('NC Workflow'.equalsIgnoreCase(nc.NC_Status__c)){
					             //System.debug(nc.Name+' - Submitted For Workflow');
				                 dataListForAlerts=dataByLastModifiedDateForAlerts.get(nc.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(nc.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+nc.Id+'">'+nc.Name+'</a> - Submitted For Workflow');
					     }
					     else if('Closed'.equalsIgnoreCase(nc.NC_Status__c)){
					             //System.debug(nc.Name+' - Closed');
				                 dataListForAlerts=dataByLastModifiedDateForAlerts.get(nc.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(nc.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+nc.Id+'">'+nc.Name+'</a> - Closed');
					    }
					    else if('Void'.equalsIgnoreCase(nc.NC_Status__c)){
					             //System.debug(nc.Name+' - Voided');
				                 dataListForAlerts=dataByLastModifiedDateForAlerts.get(nc.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(nc.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+nc.Id+'">'+nc.Name+'</a> - Voided');
					    }
	               }
				}
				if(nc.Followers__c!=null  && nc.Followers__c.contains(loggedInUserId)){
					
				  followingNCs.add(nc.Id);
				  if('Open'.equalsIgnoreCase(nc.NC_Status__c)){
			                 //System.debug(nc.Name+' - Created');
			                 dataList=dataByLastModifiedDate.get(nc.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(nc.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+nc.Id+'">'+nc.Name+'</a> - Created');
	              }
	              else if('Reopened'.equalsIgnoreCase(nc.NC_Status__c)){
			                 //System.debug(nc.Name+' - Reopened');
			                 dataList=dataByLastModifiedDate.get(nc.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(nc.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+nc.Id+'">'+nc.Name+'</a> - Reopened');
	              }
		          else if('NC Workflow'.equalsIgnoreCase(nc.NC_Status__c)){
		             //System.debug(nc.Name+' - Submitted For WorkFlow');
		             dataList=dataByLastModifiedDate.get(nc.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(nc.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+nc.Id+'">'+nc.Name+'</a> - Submitted For WorkFlow');
		          }
		          else if('Closed'.equalsIgnoreCase(nc.NC_Status__c)){
		             //System.debug(nc.Name+' - Closed');
		             dataList=dataByLastModifiedDate.get(nc.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(nc.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+nc.Id+'">'+nc.Name+'</a> -  Closed');
		         }
		         else if('Void'.equalsIgnoreCase(nc.NC_Status__c)){
		             //System.debug(nc.Name+' - Voided');
		             dataList=dataByLastModifiedDate.get(nc.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(nc.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+nc.Id+'">'+nc.Name+'</a> -  Voided');
		         }
	          }
	          
       	    }
	       }else{
	       	 System.debug('Dashboard_Controller  : No Acesss to object  Non_Conformance__c and fields to get tasks   '+ncFields);
	       }
	       
	       String capaFields=isCAPADashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Name,CAPA_Status__c,Followers__c,LastModifiedDate,OwnerId'):''; //v1.1
	       Set<Id> loggedInUserCAPAs=new Set<Id>();
	       Set<Id> followingCAPAs=new Set<Id>();
	       if(capaFields !=null && capaFields!=''){
       	    //allNCList=Database.query('SELECT '+ncFields+',(SELECT '+queryFieldNames+' FROM General_Tasks__r) FROM Non_Conformance__c');
       	    for(CAPA__c capa : Database.query('SELECT '+capaFields+' FROM CAPA__c WHERE OwnerId=:loggedInUserId OR Followers__c INCLUDES (\''+loggedInUserId+'\') ORDER By CreatedDate  LIMIT 1000')){
	       	    //System.debug('Dashboard_Controller capa.Followers__c  '+capa.Followers__c);
	       	    if(capa.OwnerId==loggedInUserId){
	                  loggedInUserCAPAs.add(capa.Id);
	                  //System.debug('Date.today()   '+Date.today()+' capa.LastModifiedDate   '+capa.LastModifiedDate);
	                  recordAge = Date.today().daysBetween(date.valueof(capa.LastModifiedDate));
	                  if(recordAge<=numberOfDaysForAlerts){
		                  if('Open'.equalsIgnoreCase(capa.CAPA_Status__c)){
				                 //System.debug(capa.Name+' - Created');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(capa.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(capa.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+capa.Id+'">'+capa.Name+'</a> - Created');
				          }
				          else if('Reopened'.equalsIgnoreCase(capa.CAPA_Status__c)){
				          	     //System.debug(capa.Name+' - Reopened');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(capa.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(capa.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+capa.Id+'">'+capa.Name+'</a> - Reopened');
				          }
					      else if('Inworks'.equalsIgnoreCase(capa.CAPA_Status__c)){
					             //System.debug(capa.Name+' - Submitted For Workflow');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(capa.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(capa.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+capa.Id+'">'+capa.Name+'</a> - Submitted For Workflow');
					     }
					     else if('Closed'.equalsIgnoreCase(capa.CAPA_Status__c)){
					             //System.debug(capa.Name+' - Closed');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(capa.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(capa.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+capa.Id+'">'+capa.Name+'</a> - Closed');
					    }
					    else if('Void'.equalsIgnoreCase(capa.CAPA_Status__c)){
					             //System.debug(capa.Name+' - Voided');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(capa.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(capa.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+capa.Id+'">'+capa.Name+'</a> - Voided');
					    }
	               }
				}
				if(capa.Followers__c!=null  && capa.Followers__c.contains(loggedInUserId)){
					
				  followingCAPAs.add(capa.Id);
				  if('Open'.equalsIgnoreCase(capa.CAPA_Status__c)){
			                 //System.debug(capa.Name+' - Created');
			                 dataList=dataByLastModifiedDateForCAPA.get(capa.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(capa.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+capa.Id+'">'+capa.Name+'</a> - Created');
	              }
	              else if('Reopened'.equalsIgnoreCase(capa.CAPA_Status__c)){
			                 //System.debug(capa.Name+' - Reopened');
			                 dataList=dataByLastModifiedDateForCAPA.get(capa.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(capa.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+capa.Id+'">'+capa.Name+'</a> - Reopened');
	              }
		          else if('Inworks'.equalsIgnoreCase(capa.CAPA_Status__c)){
		             //System.debug(capa.Name+' - Submitted For WorkFlow');
		             dataList=dataByLastModifiedDateForCAPA.get(capa.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(capa.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+capa.Id+'">'+capa.Name+'</a> - Submitted For WorkFlow');
		          }
		          else if('Closed'.equalsIgnoreCase(capa.CAPA_Status__c)){
		             //System.debug(capa.Name+' - Closed');
		             dataList=dataByLastModifiedDateForCAPA.get(capa.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(capa.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+capa.Id+'">'+capa.Name+'</a> -  Closed');
		         }
		         else if('Void'.equalsIgnoreCase(capa.CAPA_Status__c)){
		             //System.debug(capa.Name+' - Voided');
		             dataList=dataByLastModifiedDateForCAPA.get(capa.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(capa.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+capa.Id+'">'+capa.Name+'</a> -  Voided');
		         }
	          }
	          
	          
       	    }
       	    //System.debug('Dashboard_Controller dataByLastModifiedDateForCAPA   '+dataByLastModifiedDateForCAPA);
	       }else{
	       	 System.debug('Dashboard_Controller  : No Acesss to object  CAPA__c and fields to get tasks   '+capaFields);
	       }
	       
	       //v1.2 start
	       
	       String docProfileFields=isDOCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,Status__c,Age__c,Expiration_Date__c,Followers__c,LastModifiedDate,OwnerId,TempStop__c,Document_Status__c'):''; //v1.1
	       
	       Set<Id> loggedInUserDocProfiles=new Set<Id>();
	       Map<Id,Document_Profile__c> loggedInUserDocProfileMap=new Map<Id,Document_Profile__c>();
	       Set<Id> followingDocProfiles=new Set<Id>();
	       if(docProfileFields !=null && docProfileFields!=''){
       	    docProfiles=new Map<String,List<Document_Profile__c>>();
       	    docTasks=new Map<String,List<General_Task__c>>();
       	    allDOCProfiles=new List<Document_Profile__c>();
       	    allDOCTasks=new List<General_Task__c>();
       	    List<Document_Profile__c> docProfileList=null;
       	    List<Document_Profile__c> docTaskList=null;
       	    for(Document_Profile__c docProfile : Database.query('SELECT '+docProfileFields+' FROM Document_Profile__c WHERE OwnerId=:loggedInUserId OR Followers__c INCLUDES (\''+loggedInUserId+'\')  ORDER By CreatedDate LIMIT 1000')){
	       	    //System.debug('Dashboard_Controller docProfile.Followers__c  '+docProfile.Followers__c);
	       	    
	       	    if(docProfile.OwnerId==loggedInUserId){
	       	    	  System.debug(' docProfile.Sub_Change_Management__r    '+docProfile.Sub_Change_Management__r);
	                  loggedInUserDocProfiles.add(docProfile.Id);
	                  
	                  //System.debug('Date.today()   '+Date.today()+' docProfile.LastModifiedDate   '+docProfile.LastModifiedDate);
	                  //if(docProfile.Document_Status__c){
	                  	//if(docProfile.Status__c!='Expired' && docProfile.Status__c!='Obsolete'){
		                  docProfileList=docProfiles.get((docProfile.TempStop__c)?'Temp':docProfile.Status__c);    
	                      if(docProfileList==null){
		                            docProfileList=new List<Document_Profile__c>();
	                                //docProfiles.put((docProfile.TempStop__c)?'Temp':docProfile.Status__c,docProfileList);
	                                docProfiles.put(docProfile.Status__c,docProfileList);
		                  }
		                  docProfileList.add(docProfile);
		                  allDOCProfiles.add(docProfile);
	                  	//}
	                  //}
	                  recordAge = Date.today().daysBetween(date.valueof(docProfile.LastModifiedDate));
	                  if(recordAge<=numberOfDaysForAlerts){
		                  if('Draft'.equalsIgnoreCase(docProfile.Status__c)){
				                 //System.debug(docProfile.Name+' - Draft');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Draft');
				          }
				          else if('Inworks'.equalsIgnoreCase(docProfile.Status__c)){
				          	     //System.debug(docProfile.Name+' - Inworks');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Inworks');
				          }
					      else if('Prerelease'.equalsIgnoreCase(docProfile.Status__c)){
					             //System.debug(docProfile.Name+' - Prerelease');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Prerelease');
					     }
					     else if('Current'.equalsIgnoreCase(docProfile.Status__c)){
					             //System.debug(docProfile.Name+' - Current');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Current');
					    }
					    else if('Preexpire'.equalsIgnoreCase(docProfile.Status__c)){
					             //System.debug(docProfile.Name+' - Preexpire');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - PreExpired');
					    }
					   else if('Revised'.equalsIgnoreCase(docProfile.Status__c)){
					             //System.debug(docProfile.Name+' - Revised');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Revised');
					    }
					    else if('Obsolete'.equalsIgnoreCase(docProfile.Status__c)){
					             //System.debug(docProfile.Name+' - Obsolete');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(docProfile.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(docProfile.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> -  Obsolete');
					    }
					    
	               }
				}
				if(docProfile.Followers__c!=null  && docProfile.Followers__c.contains(loggedInUserId)){
				  System.debug('Dashboard Controller  docProfile.Followers__c   '+docProfile.Followers__c);	
				  followingDocProfiles.add(docProfile.Id);
				  if('Draft'.equalsIgnoreCase(docProfile.Status__c)){
			                 //System.debug(docProfile.Name+' - Created');
			                 dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Created');
	              }
	              else if('Inworks'.equalsIgnoreCase(docProfile.Status__c)){
			                 //System.debug(docProfile.Name+' - Reopened');
			                 dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Submitted for workflow');
	              }
		          else if('Prerelease'.equalsIgnoreCase(docProfile.Status__c)){
		             //System.debug(docProfile.Name+' - Submitted For WorkFlow');
		             dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> - Prereleased');
		          }
		          else if('Current'.equalsIgnoreCase(docProfile.Status__c)){
		             //System.debug(docProfile.Name+' - Closed');
		             dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> -  become current');
		         }
		         else if('Preexpire'.equalsIgnoreCase(docProfile.Status__c)){
		             //System.debug(docProfile.Name+' - Voided')
		             dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> -  Preexpired');
		         }
		         else if('Revised'.equalsIgnoreCase(docProfile.Status__c)){
		             //System.debug(docProfile.Name+' - Closed');
		             dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> -  Revised');
		         }
		         else if('Obsolete'.equalsIgnoreCase(docProfile.Status__c)){
		             //System.debug(docProfile.Name+' - Voided')
		             dataList=dataByLastModifiedDateForDOC.get(docProfile.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(docProfile.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+docProfile.Id+'">'+docProfile.Name+'</a> -  become Obsolete');
		         }
	          }
	          
	          
       	    }
       	    System.debug('Dashboard_Controller dataByLastModifiedDateForDOC   '+dataByLastModifiedDateForDOC);
	       }
	     else{
	       	 System.debug('Dashboard_Controller  : No Acesss to object Document_Profile__c   and fields to get tasks   '+docProfileFields);
	       }
	       
	       
	       String cmFields=isDOCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'Id,Name,Status__c,Followers__c,LastModifiedDate,OwnerId'):'';
	       String subChgMgmtFields=isDOCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('Sub_Change_Management__c', 'Id,Document_Profile__c,Document_Profile__r.OwnerId,Change_Management__c,Change_Management__r.Name,Change_Management__r.Age__c,Change_Management__r.Due_Date__c,Type__c'):''; 
	       String newType='New',reviseType='Revise',tempType='Temp';
	       Set<Id> loggedInCMS=new Set<Id>();
	       Set<Id> followingCMS=new Set<Id>();
	       List<Sub_Change_Management__c> cmActionItemList=new List<Sub_Change_Management__c>(); 
	       if(cmFields !=null && cmFields!='' && subChgMgmtFields!=null && subChgMgmtFields!=''){
       	    //cmTasks=new Map<String,List<Change_Management__c>>();
       	    //allCMTasks=new List<Change_Management__c>();
       	    cmActionItems=new List<ActionItemWrapper>();
       	    List<Change_Management__c> cmList=null;
       	    for(Change_Management__c changeManagement : Database.query('SELECT '+cmFields+',(SELECT '+subChgMgmtFields+' FROM Sub_Change_Management__r WHERE TYPE__c=:newType OR TYPE__c=:reviseType OR TYPE__c=:tempType) FROM Change_Management__c  ORDER By Due_Date__c LIMIT 1000')){
	       	   //System.debug('Dashboard_Controller changeManagement.Followers__c  '+changeManagement.Followers__c);
	       	   System.debug('Dashboard_Controller changeManagement.Sub_Change_Management__r  '+changeManagement.Sub_Change_Management__r);
	       	   for(Sub_Change_Management__c subChangeManagement : changeManagement.Sub_Change_Management__r){
	                  	  cmActionItemList=tempCMActionItems.get(changeManagement.Id);
	                  	  if(cmActionItemList==null){
	                  	  	  cmActionItemList=new List<Sub_Change_Management__c>();
	                  	  	  tempCMActionItems.put(changeManagement.Id,cmActionItemList);
	                  	  }
	                  	  cmActionItemList.add(subChangeManagement);
	            }
	       	    if(changeManagement.OwnerId==loggedInUserId){
	                  loggedInCMS.add(changeManagement.Id);
	                  recordAge = Date.today().daysBetween(date.valueof(changeManagement.LastModifiedDate));
	                  if(recordAge<=numberOfDaysForAlerts){
		                  if('Open'.equalsIgnoreCase(changeManagement.Status__c)){
				                 //System.debug(changeManagement.Name+' - Created');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Created');
				          }
				          else if('Document Change Order'.equalsIgnoreCase(changeManagement.Status__c)){
				          	     //System.debug(capa.Name+' - Reopened');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Submitted For Workflow');
				          }
					      else if('In Review'.equalsIgnoreCase(changeManagement.Status__c)){
					             //System.debug(capa.Name+' - Submitted For Workflow');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - is In Review');
					     }
					     else if('Pending Approval'.equalsIgnoreCase(changeManagement.Status__c)){
					             //System.debug(capa.Name+' - Submitted For Workflow');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Submitted For Approval');
					     }
					     else if('Closed'.equalsIgnoreCase(changeManagement.Status__c)){
					             //System.debug(capa.Name+' - Closed');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Closed');
					    }
					    else if('Void'.equalsIgnoreCase(changeManagement.Status__c)){
					             //System.debug(capa.Name+' - Voided');
				                 dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(changeManagement.LastModifiedDate);
				                 if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(changeManagement.LastModifiedDate,dataListForAlerts);}
				                 dataListForAlerts.add('fa fa-send info-blue@<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Voided');
					    }
					    
	               }
				}
				if(changeManagement.Followers__c!=null  && changeManagement.Followers__c.contains(loggedInUserId)){
				  System.debug('Dashboard Controller  changeManagement.Followers__c   '+changeManagement.Followers__c);	
				  followingCMS.add(changeManagement.Id);
				  if('Open'.equalsIgnoreCase(changeManagement.Status__c)){
			                 //System.debug(docProfile.Name+' - Created');
			                 dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Created');
	              }
	              else if('Document Change Order'.equalsIgnoreCase(changeManagement.Status__c)){
			                 //System.debug(docProfile.Name+' - Reopened');
			                 dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Submitted for workflow');
	              }
	              else if('Pending Approval'.equalsIgnoreCase(changeManagement.Status__c)){
			                 //System.debug(docProfile.Name+' - Reopened');
			                 dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
			                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
			                 dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Submitted for approval');
	              }
		          else if('In Review'.equalsIgnoreCase(changeManagement.Status__c)){
		             //System.debug(changeManagement.Name+' - Submitted For WorkFlow');
		             dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> - Is In Review');
		          }
		          else if('Closed'.equalsIgnoreCase(changeManagement.Status__c)){
		             //System.debug(docProfile.Name+' - Closed');
		             dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> -  Closed');
		         }
		         else if('Void'.equalsIgnoreCase(changeManagement.Status__c)){
		             //System.debug(docProfile.Name+' - Voided')
		             dataList=dataByLastModifiedDateForCM.get(changeManagement.LastModifiedDate);
	                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(changeManagement.LastModifiedDate,dataList);}
		             dataList.add('<a href="/'+changeManagement.Id+'">'+changeManagement.Name+'</a> -  Voided');
		         }
		         
	          }
	          
	          
       	    }
       	   System.debug('Dashboard_Controller dataByLastModifiedDateForCM   '+dataByLastModifiedDateForCM);
	       }else{
	       	 System.debug('Dashboard_Controller  : No Acesss to object Change_Management__c   and fields to get tasks   '+docProfileFields);
	       }
	       
	       //v1.2 end
	       
	       
           
           if(queryFieldNames != null && queryFieldNames != '' && SubTasks!=null && SubTasks!=''){
                 ncTasks=new Map<String,List<General_Task__c>>();
                 capaTasks=new Map<String,List<General_Task__c>>();
                 cmTasks=new Map<String,List<General_Task__c>>();
                 
                 allNCTasks=new List<General_Task__c>();
                 allCAPATasks=new List<General_Task__c>();
                 allCMTasks=new List<General_Task__c>();
                 
                 List<General_Task__c> genericTasks=null;
                 for(General_Task__c genTask:Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE OwnerId=:loggedInUserId OR Non_Conformance__c IN:followingNCs OR CAPA__c IN:followingCAPAs OR Change_Management__c IN :followingCMS  ORDER BY Due_Date__c LIMIT 1000')){
                   if(genTask.Non_Conformance__c!=null){
                        if(genTask.OwnerId==loggedInUserId && genTask.Status__c!='Closed' && genTask.Status__c!='Void' && genTask.Due_Date__c!=null){
                              genericTasks=ncTasks.get(genTask.RecordType.Name);    
                              if(genericTasks==null){
	                            genericTasks=new List<General_Task__c>();
                                ncTasks.put(genTask.RecordType.Name,genericTasks);
	                          }
	                          taskSize++;
	                          genericTasks.add(genTask);
	                          allNCTasks.add(genTask);
	                     }
	                     if(genTask.OwnerId==loggedInUserId){
	                     	        //System.debug('Date.today()   '+Date.today()+' getTask.LastModifiedDate  '+genTask.LastModifiedDate);
									 recordAge = date.valueof(genTask.LastModifiedDate).daysBetween(Date.today());
					                 if(recordAge<=numberOfDaysForAlerts){
					                   if(genTask.Non_Conformance__c!=null){
									       if('Created'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                        }
					                        else if('Open'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' Opened');
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           if(genTask.CurrentApprovalSequenceNumber__c==999999){
					                           	  dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is Rejected');
					                           }
					                           else if(genTask.CurrentApprovalSequenceNumber__c==99999){
					                           	 dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is Recalled');
					                           }
					                           else{
							                     dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> '+genTask.RecordType.Name+' is Opened');
					                           }
					                        }
					                        else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__r.Id+'">'+genTask.Non_Conformance__r.Name+'</a> - Containment submitted for approval');
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-send info-blue@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> -  '+genTask.RecordType.Name+' is submitted for approval');
					                        }
					                        else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - Containment is closed');
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-folder info-green@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is closed');
					                        }
					                        else if('Void'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                        }
					                        if(genTask.New_Owner__c!=null && genTask.New_Owner__c!=genTask.OwnerId){
					                           //System.debug('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - Containment Owner Chagned From '+genTask.OwnerId+' to '+genTask.New_Owner__c);
					                           dataListForAlerts=dataByLastModifiedDateForAlerts.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-male info-blue@<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+genTask.RecordType.Name+' Owner Changed');
					                        }
					                 }
					                 
	                               }
	                            }
	                            if(followingNCs.contains(genTask.Non_Conformance__c)){
	                             if('?reated'.equalsIgnoreCase(genTask.Status__c)){
					                                 //System.debug(genTask.Non_Conformance__r.Name+' - '+ genTask.RecordType.Name +' is created');
					                                 dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
					                                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(genTask.LastModifiedDate,dataList);}
					                                            dataList.add('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+ genTask.RecordType.Name +' is created'); 
							      }
					              else if('Open'.equalsIgnoreCase(genTask.Status__c)){
					                               //System.debug(genTask.Non_Conformance__r.Name+' - '+ genTask.RecordType.Name +' is Opened');
					                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
					                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(genTask.LastModifiedDate,dataList);}
					                               dataList.add('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+ genTask.RecordType.Name +' is Opened'); 
					              }
					              else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
					                               //System.debug(genTask.Non_Conformance__r.Name+' - '+ genTask.RecordType.Name +' is submitted for approval');
					                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
					                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(genTask.LastModifiedDate,dataList);}
					                               dataList.add('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+ genTask.RecordType.Name +' is submitted for approval'); 
					              }
					              else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
					                               //System.debug(genTask.Non_Conformance__r.Name+' - '+ genTask.RecordType.Name +' is  Closed');
					                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
					                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(genTask.LastModifiedDate,dataList);}
					                               dataList.add('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+ genTask.RecordType.Name +' is Closed'); 
					              }
					              else if('Void'.equalsIgnoreCase(genTask.Status__c)){
					                               //System.debug(genTask.Non_Conformance__r.Name+' - '+ genTask.RecordType.Name +' is  Voided');
					                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
					                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDate.put(genTask.LastModifiedDate,dataList);}
					                               dataList.add('<a href="/'+genTask.Non_Conformance__c+'">'+genTask.Non_Conformance__r.Name+'</a> - '+ genTask.RecordType.Name +' is Voided'); 
					              }
	                            }
                        }
                       
					                 
					                 if(genTask.CAPA__c!=null){
                       	                  if(genTask.OwnerId==loggedInUserId && genTask.Status__c!='Closed' && genTask.Status__c!='Void' && genTask.Due_Date__c!=null){
				                              genericTasks=capaTasks.get(genTask.RecordType.Name);    
				                              if(genericTasks==null){
					                            genericTasks=new List<General_Task__c>();
				                                capaTasks.put(genTask.RecordType.Name,genericTasks);
					                          }
					                          capaTaskSize++;
					                          genericTasks.add(genTask);
					                          allCAPATasks.add(genTask);
	                                      }
					                 	  if('Created'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                        }
					                        else if('Open'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' Opened');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           if(genTask.CurrentApprovalSequenceNumber__c==999999){
					                           	  dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is Rejected');
					                           }
					                           else if(genTask.CurrentApprovalSequenceNumber__c==99999){
					                           	 dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is Recalled');
					                           }
					                           else{
							                     dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> '+genTask.RecordType.Name+' is Opened');
					                           }
					                        }
					                        else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment submitted for approval');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-send info-blue@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> -  '+genTask.RecordType.Name+' is submitted for approval');
					                        }
					                        else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment is closed');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-folder info-green@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is closed');
					                        }
					                        else if('Void'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                        }
					                        if(genTask.New_Owner__c!=null && genTask.New_Owner__c!=genTask.OwnerId){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment Owner Chagned From '+genTask.OwnerId+' to '+genTask.New_Owner__c);
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCAPA.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCAPA.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-male info-blue@<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' Owner Changed');
					                        }
					                        if(followingCAPAs.contains(genTask.CAPA__c)){
					                             if('?reated'.equalsIgnoreCase(genTask.Status__c)){
									                                 //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is created');
									                                 dataList=dataByLastModifiedDateForCAPA.get(genTask.LastModifiedDate);
									                                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(genTask.LastModifiedDate,dataList);}
									                                            dataList.add('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+ genTask.RecordType.Name +' is created'); 
											      }
									              else if('Open'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is Opened');
									                               dataList=dataByLastModifiedDateForCAPA.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+ genTask.RecordType.Name +' is Opened'); 
									              }
									              else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is submitted for approval');
									                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+ genTask.RecordType.Name +' is submitted for approval'); 
									              }
									              else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is  Closed');
									                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+ genTask.RecordType.Name +' is Closed'); 
									              }
									              else if('Void'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is  Voided');
									                               dataList=dataByLastModifiedDate.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCAPA.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+ genTask.RecordType.Name +' is Voided'); 
									              }
	                                       }
					                 }
					                 //v1.2 start
					                 if(genTask.Change_Management__c!=null){
					                 	  
					                    
                       	                  if(genTask.OwnerId==loggedInUserId && genTask.Status__c!='Closed' && genTask.Status__c!='Void' && genTask.Due_Date__c!=null){
				                              genericTasks=cmTasks.get(genTask.RecordType.Name); 
				                              
				                              if(genericTasks==null){
					                            genericTasks=new List<General_Task__c>();
				                                cmTasks.put(genTask.RecordType.Name,genericTasks);
					                          }
					                          //capaTaskSize++;
					                          genericTasks.add(genTask);
					                          allCMTasks.add(genTask);
	                                      }
					                 	  if('Created'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                        }
					                        else if('Open'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' Opened');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           if(genTask.CurrentApprovalSequenceNumber__c==999999){
					                           	  dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' is Rejected');
					                           }
					                           else if(genTask.CurrentApprovalSequenceNumber__c==99999){
					                           	 dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' is Recalled');
					                           }
					                           else{
							                     dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> '+genTask.RecordType.Name+' is Opened');
					                           }
					                        }
					                        else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment submitted for approval');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-send info-blue@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> -  '+genTask.RecordType.Name+' is submitted for approval');
					                        }
					                        else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment is closed');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-folder info-green@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' is closed');
					                        }
					                        else if('Void'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                        }
					                        if(genTask.New_Owner__c!=null && genTask.New_Owner__c!=genTask.OwnerId){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.CAPA__r.Name+'</a> - Containment Owner Chagned From '+genTask.OwnerId+' to '+genTask.New_Owner__c);
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForCM.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForCM.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-male info-blue@<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+genTask.RecordType.Name+' Owner Changed');
					                        }
					                        if(followingCMs.contains(genTask.Change_Management__c)){
					                             if('Created'.equalsIgnoreCase(genTask.Status__c)){
									                                 //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is created');
									                                 dataList=dataByLastModifiedDateForCM.get(genTask.LastModifiedDate);
									                                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(genTask.LastModifiedDate,dataList);}
									                                            dataList.add('<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+ genTask.RecordType.Name +' is created'); 
											      }
									              else if('Open'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is Opened');
									                               dataList=dataByLastModifiedDateForCM.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+ genTask.RecordType.Name +' is Opened'); 
									              }
									              else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is submitted for approval');
									                               dataList=dataByLastModifiedDateForCM.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+ genTask.RecordType.Name +' is submitted for approval'); 
									              }
									              else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is  Closed');
									                               dataList=dataByLastModifiedDateForCM.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+ genTask.RecordType.Name +' is Closed'); 
									              }
									              else if('Void'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.CAPA__r.Name+' - '+ genTask.RecordType.Name +' is  Voided');
									                               dataList=dataByLastModifiedDateForCM.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForCM.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Change_Management__c+'">'+genTask.Change_Management__r.Name+'</a> - '+ genTask.RecordType.Name +' is Voided'); 
									              }
	                                       }
					                 }
					                 
					                 if(genTask.Document_Profile__c!=null){
					                 	  
					                      System.debug('Dashboard Controller Document Profile genTask genTask.Document_Profile__r.Current_Rev__c '+genTask.Document_Profile__r.Current_Rev__c);
                       	                  if(genTask.OwnerId==loggedInUserId && genTask.Status__c!='Closed' && genTask.Status__c!='Void'){
				                              genericTasks=docTasks.get(genTask.RecordType.Name); 
				                              
				                              if(genericTasks==null){
					                            genericTasks=new List<General_Task__c>();
				                                docTasks.put(genTask.RecordType.Name,genericTasks);
					                          }
					                          //capaTaskSize++;
					                          genericTasks.add(genTask);
					                          allDOCTasks.add(genTask);
	                                      }
					                 	  if('Created'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is created');
					                        }
					                        else if('Open'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.CAPA__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' Opened');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           if(genTask.CurrentApprovalSequenceNumber__c==999999){
					                           	  dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is Rejected');
					                           }
					                           else if(genTask.CurrentApprovalSequenceNumber__c==99999){
					                           	 dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is Recalled');
					                           }
					                           else{
							                     dataListForAlerts.add('fa fa-edit info-orange@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> '+genTask.RecordType.Name+' is Opened');
					                           }
					                        }
					                        else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - Containment submitted for approval');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-send info-blue@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> -  '+genTask.RecordType.Name+' is submitted for approval');
					                        }
					                        else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - Containment is closed');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-folder info-green@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is closed');
					                        }
					                        else if('Void'.equalsIgnoreCase(genTask.Status__c)){
					                           //System.debug('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
							                   dataListForAlerts.add('fa fa-edit info-gray@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' is voided');
					                        }
					                        if(genTask.New_Owner__c!=null && genTask.New_Owner__c!=genTask.OwnerId){
					                           //System.debug('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - Containment Owner Chagned From '+genTask.OwnerId+' to '+genTask.New_Owner__c);
					                           dataListForAlerts=dataByLastModifiedDateForAlertsForDOC.get(genTask.LastModifiedDate);
					                           if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlertsForDOC.put(genTask.LastModifiedDate,dataListForAlerts);}
					                           dataListForAlerts.add('fa fa-male info-blue@<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+genTask.RecordType.Name+' Owner Changed');
					                        }
					                        if(followingDocProfiles.contains(genTask.Document_Profile__c)){
					                             if('Created'.equalsIgnoreCase(genTask.Status__c)){
									                                 //System.debug(genTask.Document_Profile__r.Name+' - '+ genTask.RecordType.Name +' is created');
									                                 dataList=dataByLastModifiedDateForDOC.get(genTask.LastModifiedDate);
									                                 if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(genTask.LastModifiedDate,dataList);}
									                                            dataList.add('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+ genTask.RecordType.Name +' is created'); 
											      }
									              else if('Open'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.Document_Profile__r.Name+' - '+ genTask.RecordType.Name +' is Opened');
									                               dataList=dataByLastModifiedDateForDOC.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+ genTask.RecordType.Name +' is Opened'); 
									              }
									              else if('Pending Approval'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.Document_Profile__r.Name+' - '+ genTask.RecordType.Name +' is submitted for approval');
									                               dataList=dataByLastModifiedDateForDOC.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+ genTask.RecordType.Name +' is submitted for approval'); 
									              }
									              else if('Closed'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.Document_Profile__r.Name+' - '+ genTask.RecordType.Name +' is  Closed');
									                               dataList=dataByLastModifiedDateForDOC.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+ genTask.RecordType.Name +' is Closed'); 
									              }
									              else if('Void'.equalsIgnoreCase(genTask.Status__c)){
									                               //System.debug(genTask.Document_Profile__r.Name+' - '+ genTask.RecordType.Name +' is  Voided');
									                               dataList=dataByLastModifiedDateForDOC.get(genTask.LastModifiedDate);
									                               if(dataList==null) {dataList=new List<String>();dataByLastModifiedDateForDOC.put(genTask.LastModifiedDate,dataList);}
									                               dataList.add('<a href="/'+genTask.Document_Profile__c+'">'+genTask.Document_Profile__r.Name+'</a> - '+ genTask.RecordType.Name +' is Voided'); 
									              }
	                                       }
					                 }
					                 //v1.2 end
	               }
	               for(General_Sub_Task__c genSubTask : Database.query('SELECT '+SubTasks+' FROM General_Sub_Task__c WHERE Assigned_User__c=:loggedInUserId AND (RecordType.Name=\'Disposition Section\' OR RecordType.Name=\'Action Plan\') AND Due_Date__c !=NULL  ORDER BY Due_Date__c  LIMIT 1000')){
	                	if(genSubTask.Non_Conformance__c!=null){
		                	if(genSubTask.Disposition_Type_Status__c!='Completed' && genSubTask.RecordType.Name=='Disposition Section'){
		                		dispSecs.add(genSubTask);
		                	}
		                	else if(genSubTask.Action_Plan_Status__c!='Complete' && genSubTask.RecordType.Name=='Action Plan'){
		                		actionPlans.add(genSubTask);
		                	}
	                	}
	                	else if(genSubTask.CAPA__c!=null){
	                		if(genSubTask.Action_Plan_Status__c!='Complete' && genSubTask.RecordType.Name=='Action Plan'){
		                		capaActionPlans.add(genSubTask);
		                	}
	                	}
                  }       
	     }
	    else{
            System.debug('Dashboard_Controller  : No Acesss to object  General_Task__c and fields to get tasks   '+queryFieldNames +' and sub tasks   '+SubTasks); //v1.1
        }
	    //System.debug('Dashboard_Controller updates  '+updates);
        //System.debug('Dashboard_Controller ncTasks   '+ncTasks+' all tasks size '+taskSize);
        //System.debug('Dashboard_Controller   dispSecs   '+dispSecs);
        //System.debug('Dashboard_Controller   actionPlans   '+actionPlans);
       //*********************************************************************************************************************        
        String queryFieldNamesNCPD = isNCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('NC_Product_Defect__c', 'Id,Non_Conformance__c,NC_Number__c,Defect__c,Defect__r.Name,Customer_Supplier__c,Customer_Supplier__r.Name,Defect__r.Suspect_Enabled__c,LastModifiedDate'):''; //v1.1
        if(queryFieldNamesNCPD != null && queryFieldNamesNCPD != ''){
                  String suspectEnabledflag='Yes';
                  //System.debug('--loggedInUserNCs:'+loggedInUserNCs);
                  Set<String> loggedInUserNCs_15Digit = new Set<String>();
                  for(String s: loggedInUserNCs)
                  {
                        String tempString = s.left(15);
                        loggedInUserNCs_15Digit.add(tempString);
                  }
                  //System.debug('--loggedInUserNCs_15Digit:'+loggedInUserNCs_15Digit);
                  //System.debug('--suspectEnabledflag:'+suspectEnabledflag);
                  //List<NC_Product_Defect__c> ncProdDefects=Database.query('SELECT '+queryFieldNamesNCPD +' FROM NC_Product_Defect__c WHERE Non_Conformance__c IN :loggedInUserNCs_15Digit AND Defect__r.Suspect_Enabled__c =: suspectEnabledflag AND LastModifiedDate >= LAST_N_DAYS:' + numberOfDaysForAlerts +' ORDER BY LastModifiedDate DESC');
                  //System.debug(' --> Dashboard_Controller prodDefects   '+ncProdDefects);
                  Set<Id> suspectedDefects=new Set<Id>();
                  for(NC_Product_Defect__c ncProd : Database.query('SELECT '+queryFieldNamesNCPD +' FROM NC_Product_Defect__c WHERE Non_Conformance__c IN :loggedInUserNCs_15Digit AND Defect__r.Suspect_Enabled__c =: suspectEnabledflag AND LastModifiedDate >= LAST_N_DAYS:' + numberOfDaysForAlerts +' ORDER BY LastModifiedDate DESC LIMIT 1000')){
                    if(!suspectedDefects.contains(ncProd.Defect__c)){
                     //System.debug('Defect   '+ncProd.Defect__r.Name+' suspected');
                     dataListForAlerts=dataByLastModifiedDateForAlerts.get(ncProd.LastModifiedDate);
                     if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(ncProd.LastModifiedDate,dataListForAlerts);}
                     dataListForAlerts.add('fa fa-exclamation-triangle info-red@Defect <a href="/'+ncProd.Defect__c+'">'+ncProd.Defect__r.Name.escapeHtml4()+'</a> Suspected');
                     if(ncProd.Customer_Supplier__r.Name != null){
                        dataListForAlerts=dataByLastModifiedDateForAlerts.get(ncProd.LastModifiedDate);
                        if(dataListForAlerts==null) {dataListForAlerts=new List<String>();dataByLastModifiedDateForAlerts.put(ncProd.LastModifiedDate,dataListForAlerts);}
                        dataListForAlerts.add('fa fa-exclamation-triangle info-red@<a href="/'+ncProd.Defect__c+'"> Customer/Supplier '+ncProd.Customer_Supplier__r.Name.escapeHtml4()+'</a> Suspected');
                     }
                     suspectedDefects.add(ncProd.Defect__c);
                    }
                  }
        }
        
        //*********************************************************************************************************************
       
       
       //System.debug('loggedInUserNCs   '+loggedInUserNCs);
       
       String documentChangeFields=isDOCDashboardEnabled?QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Change_Management__c,Change_Management__r.Due_Date__c,Change_Management__r.Age__c,Document_Profile__r.OwnerId,Document_Profile__c,RecordType.Name,OwnerId'):'';
       String documentChangeRecordType='DocumentChange';
       String documentChangeStatus='Closed';
       if(documentChangeFields!=null && documentChangeFields!=''){
       	  for(General_Task__c changeOrder : Database.query('SELECT '+documentChangeFields+' FROM General_Task__c WHERE Change_Management__c!=null AND Status__c!=:documentChangeStatus AND RecordType.Name=:documentChangeRecordType ORDER BY Change_Management__r.Due_Date__c')){
       	      cmActionItemList=tempCMActionItems.get(changeOrder.Change_Management__c); 
              if(cmActionItemList!=null && !cmActionItemList.isEmpty()){
              	 ActionItemWrapper actionItemWrapper=null;
              	 for(Sub_Change_Management__c cmActionItem :cmActionItemList){
              	      if(cmActionItem.Document_Profile__c==null){
              	      	 if(changeOrder.OwnerId==loggedInUserId){
              	      	 	actionItemWrapper=new ActionItemWrapper();
              	      	 	actionItemWrapper.cmId=cmActionItem.Change_Management__c;
              	      	 	actionItemWrapper.cmName=cmActionItem.Change_Management__r.Name;
              	      	 	actionItemWrapper.taskId=changeOrder.Id;
              	      	 	actionItemWrapper.dueDate=cmActionItem.Change_Management__r.Due_Date__c;
              	      	 	actionItemWrapper.age=cmActionItem.Change_Management__r.Age__c;
              	      	 	actionItemWrapper.taskType=cmActionItem.Type__c;
              	      	 	cmActionItems.add(actionItemWrapper);
              	      	 }
              	      }
              	      else if(cmActionItem.Document_Profile__r.OwnerId==loggedInUserId){
              	      	    actionItemWrapper=new ActionItemWrapper();
              	      	 	actionItemWrapper.cmId=cmActionItem.Change_Management__c;
              	      	 	actionItemWrapper.cmName=cmActionItem.Change_Management__r.Name;
              	      	 	actionItemWrapper.taskId=changeOrder.Id;
              	      	 	actionItemWrapper.dueDate=cmActionItem.Change_Management__r.Due_Date__c;
              	      	 	actionItemWrapper.age=cmActionItem.Change_Management__r.Age__c;
              	      	 	actionItemWrapper.taskType=cmActionItem.Type__c;
              	      	 	cmActionItems.add(actionItemWrapper);
              	     }
              	  } 
              }
       	  }
       	  
       }
        
       List<DateTime> createDateList = new List<DateTime>();
	   createDateList.addAll(dataByLastModifiedDate.keySet());
	   createDateList.sort();
	   for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String updatePerDate  : dataByLastModifiedDate.get(createDateList[i])){
		 	  updates.add(updatePerDate);
		 	}
	  }
	  
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForCAPA.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String updatePerDate  : dataByLastModifiedDateForCAPA.get(createDateList[i])){
		 	  capaUpdates.add(updatePerDate);
		 	}
	  }
	  //v1.2 start
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForDOC.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String updatePerDate  : dataByLastModifiedDateForDOC.get(createDateList[i])){
		 	  docUpdates.add(updatePerDate);
		 	}
	  }
	  
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForCM.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String updatePerDate  : dataByLastModifiedDateForCM.get(createDateList[i])){
		 	  cmUpdates.add(updatePerDate);
		 	}
	  }
	  //v1.2 end
      
      createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForAlerts.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String alertPerDate  : dataByLastModifiedDateForAlerts.get(createDateList[i])){
		 	  alerts.add(alertPerDate);
		 	}
	  }
	  
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForAlertsForCAPA.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String alertPerDate  : dataByLastModifiedDateForAlertsForCAPA.get(createDateList[i])){
		 	  capaAlerts.add(alertPerDate);
		 	}
	  }
	  //v1.2 start
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForAlertsForDOC.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String alertPerDate  : dataByLastModifiedDateForAlertsForDOC.get(createDateList[i])){
		 	  docAlerts.add(alertPerDate);
		 	}
	  }
	  
	  createDateList = new List<DateTime>();
	  createDateList.addAll(dataByLastModifiedDateForAlertsForCM.keySet());
	  createDateList.sort();
	  for(Integer i=createDateList.size()-1;i>=0;i--){
		 	for(String alertPerDate  : dataByLastModifiedDateForAlertsForCM.get(createDateList[i])){
		 	  cmAlerts.add(alertPerDate);
		 	}
	  }
	  //v1.2 end
	  
      notes=fillNotes();
      //System.debug('Dashboard_Controller  ncTasks  '+ncTasks+' updates   '+updates+' alerts   '+alerts+' notes   '+notes);
      //System.debug('Dashboard_Controller  capaTasks  '+capaTasks+' capaUpdates   '+capaUpdates+' capaAlerts   '+capaAlerts);
      //System.debug('Dashboard_Controller  capaUpdates   '+capaUpdates);
      //System.debug('Dashboard_Controller  allNCTasks   '+allNCTasks);
      //System.debug('Dashboard_Controller  docProfiles  '+docProfiles);
      //System.debug('Dashboard_Controller  allDOCProfiles   '+allDOCProfiles);
      //System.debug('Dashboard_Controller  docUpdates   '+docUpdates);
     // System.debug('Dashboard_Controller  cmAlerts   '+cmAlerts);
      //System.debug('Dashboard_Controller  cmUpdates   '+cmUpdates);
      //System.debug('Dashboard_Controller  cmTasks   '+cmTasks);
     // System.debug('Dashboard_Controller  allCMTasks   '+allCMTasks);
     //System.debug('Dashboard_Controller  docTasks  '+docTasks);
     //System.debug('Dashboard_Controller  allDOCTasks   '+allDOCTasks);
     
     System.debug('Dashboard_Controller  cmActionItems   '+cmActionItems);
     
     }
         else{
     	System.debug(' Dashboard_Controller No Access To Any Dashboard ');
     }
   }
   catch(Exception ex){
         System.debug('Exception In Dashboard_Controller  '+ex.getMessage());
   }
  }
  
  public List<Schema.PicklistEntry> getDocProfileStatuses(){
  	     List<Schema.PicklistEntry> statusList=null;
  	     try{
  	     	statusList=Document_Profile__c.Status__c.getDescribe().getPicklistValues();
  	     }catch(Exception ex){
  	     	 System.debug('Exception In Dashboard_Controller.getDocProfileStatuses()  '+ex.getMessage());
  	     }
  	     return statusList;
  }
  
  
   
    
    @RemoteAction
    public static List<NoteWrapper> saveNotes(String noteDesc){
        List<NoteWrapper> notes=new List<NoteWrapper>();
        if(isNCDashboardEnabled || isCAPADashboardEnabled || isDOCDashboardEnabled){ //v1.1  //v1.2 isDOCDashboardEnabled check added
        try{
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Note__c','Description__c','create')){
              Note__c note=new Note__c();
              note.Description__c=noteDesc;
              insert note;
              notes=fillNotes();
            }
        }
        catch(Exception ex){
            System.debug('Exception In Dashboard_Controller  '+ex.getMessage());
        }
      }
        return notes;
    }
    
    @RemoteAction
    public static List<NoteWrapper> deleteNotes(String noteId){
       String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Note__c', 'Id,Name,Description__c,CreatedById,LastModifiedDate');
       List<NoteWrapper> notes=new List<NoteWrapper>();
       if(isNCDashboardEnabled || isCAPADashboardEnabled){ //v1.1
	       try{
	           if(queryFieldNames != null && queryFieldNames != '' || isDOCDashboardEnabled){ //v1.2 isDOCDashboardEnabled check added
	                 String loggedInUserId=UserInfo.getUserId();
	                 List<Note__c> noteToBeDeleted=Database.query('SELECT '+queryFieldNames+' FROM Note__c WHERE Id=:noteId ORDER BY Id DESC');
	                 //System.debug('Dashboard_Controller.deleteNotes noteToBeDeleted   '+noteToBeDeleted);
	                 if(!noteToBeDeleted.isEmpty() && Note__c.sObjectType.getDescribe().isDeletable()){
	                    delete noteToBeDeleted;
	                    notes=fillNotes();
	                 }
	           }
	           else{
	                System.debug('Dashboard_Controller  deleteNotes: No Acesss to object  Note__c and fields to get tasks'+queryFieldNames);
	           }    
	       }catch(Exception ex){
	          System.debug('Exception In Dashboard_Controller.deleteNotes  '+ex.getMessage());
	       }
       }
       //System.debug('Dashboard_Controller deleteNotes '+notes);
       return notes;
    }
    
    private static List<NoteWrapper> fillNotes(){
       //System.debug('Dashboard_Controller getNotes   getting the notes  ');
       List<NoteWrapper> notes=new List<NoteWrapper>();
       if(isNCDashboardEnabled || isCAPADashboardEnabled || isDOCDashboardEnabled){ //v1.1 //v1.2 isDOCDashboardEnabled check added
	       String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Note__c', 'Id,Name,Description__c,CreatedById,LastModifiedDate');
	       NoteWrapper noteWrapper=null;
	       if(queryFieldNames != null && queryFieldNames != ''){
	             String loggedInUserId=UserInfo.getUserId();
	             for(Note__c note :Database.query('SELECT '+queryFieldNames+' FROM Note__c WHERE CreatedById=:loggedInUserId ORDER BY LastModifiedDate DESC LIMIT 1000')){
	             	noteWrapper=new NoteWrapper();
	             	noteWrapper.id=note.Id;
	             	noteWrapper.description=note.Description__c;
	             	noteWrapper.LastModifiedDate=String.valueOf(note.LastModifiedDate);
	             	notes.add(noteWrapper);
	             }
	       }
	       else{
	            System.debug('Dashboard_Controller  fillNotes: No Acesss to object  Note__c and fields to get tasks'+queryFieldNames);
	       }
	       //System.debug('Dashboard_Controller fillNotes '+notes);
       }
      return notes;
    }
    
    public class NoteWrapper{
    	public String id{get;set;}
    	public String LastModifiedDate{get;set;}
    	public String description{get;set;}
    }
    
    public class ActionItemWrapper{
       public String cmId{get;set;}
       public String cmName{get;set;}
       public String taskId{get;set;}
       public String taskType{get;set;}
       public Date   dueDate{get;set;}
       public Decimal age{get;set;}
    }
    
    
    
     
    @RemoteAction 
    public static List<PieWedgeData> generatePieData(String module) {
    	if(module=='NC'){
    	  return generateNCPieData();
        }
    	else if(module=='CAPA'){
          return generateCAPAPieData();
    	}
    	//v1.2 start
    	else if(module=='DOC'){
    	  return generateDOCPieData();
    	}
    	else if(module=='CM'){
    	  return generateCMPieData();
    	}
    	//v1.2 end
    	return new List<PieWedgeData>();
    	
		    
    }
    
    private static List<PieWedgeData> generateNCPieData() {
    	List<PieWedgeData> data = new List<PieWedgeData>();
		    Decimal containment=0;
		    Decimal Investigation= 0;
		    Decimal Disposition= 0;
		    Decimal Implementation= 0;
		    Decimal adhoc=0;
		    Decimal Closure= 0;
		    Decimal ChangeOwner= 0;
		    Decimal ChangeDueDate= 0;
		    String queryFieldNamesGT = (isNCDashboardEnabled)?QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,recordtype.Name,Non_Conformance__c'):'';//v1.1
		    Map<Id,General_Task__c> genTasks=new Map<Id,General_Task__c>();
		    General_Task__c genTask=new General_Task__c();
		    set<id> tasksIds = new set<Id>();
	        for(ProcessInstanceWorkitem pi: PendingapprovalList)
	        {
	            if(pi.ProcessInstance.TargetObjectId != null)
	                tasksIds.add(pi.ProcessInstance.TargetObjectId);
	                
                 //System.debug('-->Process Developer Name:'+pi.ProcessInstance.ProcessDefinition.DeveloperName);
                 //System.debug('-->Process Name:'+pi.ProcessInstance.ProcessDefinition.Name);
	        }
	        
	        if(tasksIds.size() > 0)
	        {
	           if(queryFieldNamesGT!=null&&queryFieldNamesGT!=''){
	           	                
	            for(General_Task__c gr: Database.query('SELECT '+queryFieldNamesGT+' FROM General_Task__c where Id IN :tasksIds AND Non_Conformance__c!=null'))
	            {
	                genTasks.put(gr.Id,gr);
	            }
	           }
	         }
	         
	         if(PendingapprovalList.size() > 0 && genTasks.size() > 0)
	         {
	             for(ProcessInstanceWorkitem piwi: PendingapprovalList)
	             {
	             	     genTask=genTasks.get(piwi.ProcessInstance.TargetObjectId);
	             	     if(genTask!=null){
		                     if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Task Owner')
			                      ChangeOwner++;
			                 else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Due Date')
			                      ChangeDueDate++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Containment')
			                      containment++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Disposition')
			                      Disposition++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Implementation')
			                      Implementation++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'AdhocTask')
			                      adhoc++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Closure')
			                      Closure++;
			                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Investigation')
			                      Investigation++;
	             	     }
	             	 
	             }
	             
	         }
	         
	        	        
	        if(Containment > 0 || Disposition > 0 || Implementation > 0 || Closure > 0 || Investigation > 0 || adhoc>0 || ChangeOwner> 0 || ChangeDueDate > 0)
	        {
	            if(Containment > 0)
	            data.add(new PieWedgeData('Containment('+Containment+')',Containment));
	            if(Disposition> 0)
	            data.add(new PieWedgeData('Disposition('+Disposition+')',Disposition));        
	            if(Implementation> 0)
	            data.add(new PieWedgeData('Implementation('+Implementation+')',Implementation));
	            if(adhoc>0)
	            data.add(new PieWedgeData('Adhoc('+adhoc+')',adhoc));
	            if(Closure> 0)
	            data.add(new PieWedgeData('Closure('+Closure+')',Closure));
	            if(Investigation> 0)
	            data.add(new PieWedgeData('Investigation('+Investigation+')',Investigation));
	            if(ChangeOwner> 0)
	            data.add(new PieWedgeData('Change Owner('+ChangeOwner+')',ChangeOwner));
	            if(ChangeDueDate> 0)
	            data.add(new PieWedgeData('Change Due Date('+ChangeDueDate+')',ChangeDueDate));
	               
	         }
        

         return data;
    }
    
    private static List<PieWedgeData> generateCAPAPieData() {
		    List<PieWedgeData> data = new List<PieWedgeData>();
		    Decimal Investigation= 0;
		    Decimal Implementation= 0;
		    Decimal effectivenessReview= 0;
		    Decimal adhoc=0;
		    Decimal Closure= 0;
		    Decimal ChangeOwner= 0;
		    Decimal ChangeDueDate= 0;
		    Decimal changeCAPAOwner= 0;
		    String queryFieldNamesGT = (isCAPADashboardEnabled)?QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,recordtype.Name,CAPA__c'):''; //v1.1
		    Map<Id,General_Task__c> genTasks=new Map<Id,General_Task__c>();
		    General_Task__c genTask=new General_Task__c();
		    set<id> tasksIds = new set<Id>();
	        for(ProcessInstanceWorkitem pi: PendingapprovalList)
	        {
	            if(pi.ProcessInstance.TargetObjectId != null)
	                tasksIds.add(pi.ProcessInstance.TargetObjectId);
	                
                 //System.debug('-->Process Developer Name:'+pi.ProcessInstance.ProcessDefinition.DeveloperName);
                 //System.debug('-->Process Name:'+pi.ProcessInstance.ProcessDefinition.Name);
	        }
	        
	        if(tasksIds.size() > 0)
	        {
	           if(queryFieldNamesGT!=null&&queryFieldNamesGT!=''){
	           	                
	            for(General_Task__c gr: Database.query('SELECT '+queryFieldNamesGT+' FROM General_Task__c where Id IN :tasksIds AND CAPA__c!=null'))
	            {
	                genTasks.put(gr.Id,gr);
	            }
	           }
	         }
	         
	         if(PendingapprovalList.size() > 0) //v1.0.1
	         {
	             for(ProcessInstanceWorkitem piwi: PendingapprovalList)
	             {
	             	  /*v1.0.1 start*/
	             	  if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change CAPA Owner'){
		                      changeCAPAOwner++;
	             	  }
	             	  /*v1.0.1 end*/
	             	  else if(genTasks.get(piwi.ProcessInstance.TargetObjectId)!=null){
	                     if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Task Owner')
		                      ChangeOwner++;
		                 else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Due Date')
		                      ChangeDueDate++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Implementation')
		                      Implementation++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'AdhocTask')
		                      adhoc++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Closure')
		                      Closure++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Investigation')
		                      Investigation++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'EffectivenessReview')
		                      effectivenessReview++;
	             	   }
	             	 
	             }
	             
	         }
	         
	        	        
	        if(Implementation > 0 || Closure > 0 || Investigation > 0 || adhoc>0 || ChangeOwner> 0 || changeCAPAOwner > 0|| ChangeDueDate > 0 || effectivenessReview>0)
	        {
	            if(Implementation> 0)
	            data.add(new PieWedgeData('Implementation('+Implementation+')',Implementation));
	            if(adhoc>0)
	            data.add(new PieWedgeData('Adhoc('+adhoc+')',adhoc));
	            if(Closure> 0)
	            data.add(new PieWedgeData('Closure('+Closure+')',Closure));
	            if(Investigation> 0)
	            data.add(new PieWedgeData('Investigation('+Investigation+')',Investigation));
	            if(effectivenessReview> 0)
	            data.add(new PieWedgeData('Effectiveness Review('+effectivenessReview+')',effectivenessReview));
	            if(changeCAPAOwner> 0)
	            data.add(new PieWedgeData('Change CAPA Owner('+changeCAPAOwner+')',changeCAPAOwner));
	            if(ChangeOwner> 0)
	            data.add(new PieWedgeData('Change Owner('+ChangeOwner+')',ChangeOwner));
	            if(ChangeDueDate> 0)
	            data.add(new PieWedgeData('Change Due Date('+ChangeDueDate+')',ChangeDueDate));
	               
	         }
        

         return data;
    }
    
    //v1.2 start
    
    private static List<PieWedgeData> generateDOCPieData() {
    	List<PieWedgeData> data = new List<PieWedgeData>();
    	Decimal ChangeOwner=0;
    	Decimal ChangeDueDate=0;
    	Decimal documentApproval= 0;
    	Decimal documentChangeOwnerApproval=0;
    	Decimal collaborationReview= 0;
    	Decimal effectivenessReview= 0;
    	String queryFieldNamesGT = (isDOCDashboardEnabled)?QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,recordtype.Name,Document_Profile__c'):''; //v1.1
	    Map<Id,General_Task__c> genTasks=new Map<Id,General_Task__c>();
	    General_Task__c genTask=new General_Task__c();
	    set<id> tasksIds = new set<Id>();
        for(ProcessInstanceWorkitem pi: PendingapprovalList)
        {
            if(pi.ProcessInstance.TargetObjectId != null)
                tasksIds.add(pi.ProcessInstance.TargetObjectId);
                
             //System.debug('-->Process Developer Name:'+pi.ProcessInstance.ProcessDefinition.DeveloperName);
             //System.debug('-->Process Name:'+pi.ProcessInstance.ProcessDefinition.Name);
        }
        
        if(tasksIds.size() > 0)
        {
           if(queryFieldNamesGT!=null&&queryFieldNamesGT!=''){
           	                
            for(General_Task__c gr: Database.query('SELECT '+queryFieldNamesGT+' FROM General_Task__c where Id IN :tasksIds AND Document_Profile__c!=null'))
            {
                genTasks.put(gr.Id,gr);
            }
           }
         }
		if(PendingapprovalList.size() > 0){
	        for(ProcessInstanceWorkitem piwi: PendingapprovalList){
	             	  
	             	  if(piwi.ProcessInstance.ProcessDefinition.Name == 'Document Approval'){
		                      documentApproval++;
	             	  }
	             	  else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Document change Owner'){
	             	  	     documentChangeOwnerApproval++;
	             	  }
	             	  else if(genTasks.get(piwi.ProcessInstance.TargetObjectId)!=null){
	                     if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Task Owner')
		                      ChangeOwner++;
		                 else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Due Date')
		                      ChangeDueDate++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'CollaborationReview')
		                      collaborationReview++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'EffectivenessReview')
		                      effectivenessReview++;
		    }
	             	  
	      }
	   }
	   if(documentApproval>0){
	   	  data.add(new PieWedgeData('Document ('+documentApproval+')',documentApproval));
	   }
	   if(documentChangeOwnerApproval>0){
	   	 data.add(new PieWedgeData('Document Change Onwer ('+documentChangeOwnerApproval+')',documentChangeOwnerApproval));
	   }
	   if(effectivenessReview> 0){
	      data.add(new PieWedgeData('Effectiveness Review('+effectivenessReview+')',effectivenessReview));
	   }
	   if(collaborationReview> 0){
	      data.add(new PieWedgeData('Collaboration Review('+collaborationReview+')',collaborationReview));
	   }
	   if(ChangeOwner> 0){
	     data.add(new PieWedgeData('Change Owner('+ChangeOwner+')',ChangeOwner));
	   }
	   if(ChangeDueDate> 0){
	      data.add(new PieWedgeData('Change Due Date('+ChangeDueDate+')',ChangeDueDate));
	   }
	   
	   return data;
   } 
   
   private static List<PieWedgeData> generateCMPieData() {
    	List<PieWedgeData> data = new List<PieWedgeData>();
    	Decimal cmApproval= 0;
    	Decimal cmChangeOwnerApproval=0;
    	Decimal documentChangeTask= 0;
	    Decimal adhoc= 0;
	    Decimal closure= 0;
	    Decimal ChangeOwner= 0;
	    Decimal ChangeDueDate= 0;
	    String queryFieldNamesGT = (isDOCDashboardEnabled)?QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,recordtype.Name,Change_Management__c'):''; //v1.1
	    Map<Id,General_Task__c> genTasks=new Map<Id,General_Task__c>();
	    General_Task__c genTask=new General_Task__c();
	    set<id> tasksIds = new set<Id>();
        for(ProcessInstanceWorkitem pi: PendingapprovalList)
        {
            if(pi.ProcessInstance.TargetObjectId != null)
                tasksIds.add(pi.ProcessInstance.TargetObjectId);
                
             //System.debug('-->Process Developer Name:'+pi.ProcessInstance.ProcessDefinition.DeveloperName);
             //System.debug('-->Process Name:'+pi.ProcessInstance.ProcessDefinition.Name);
        }
        
        if(tasksIds.size() > 0)
        {
           if(queryFieldNamesGT!=null&&queryFieldNamesGT!=''){
           	                
            for(General_Task__c gr: Database.query('SELECT '+queryFieldNamesGT+' FROM General_Task__c where Id IN :tasksIds AND Change_Management__c!=null'))
            {
                genTasks.put(gr.Id,gr);
            }
           }
         }
		if(PendingapprovalList.size() > 0){
	        for(ProcessInstanceWorkitem piwi: PendingapprovalList){
	             	  
	             	  if(piwi.ProcessInstance.ProcessDefinition.Name == 'ChangeRequest'){
		                      cmApproval++;
	             	  }
	             	  else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Owner'){
	             	  	  cmChangeOwnerApproval++;
	             	  }
	             	  else if(genTasks.get(piwi.ProcessInstance.TargetObjectId)!=null){
	                     if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Task Owner')
		                      ChangeOwner++;
		                 else if(piwi.ProcessInstance.ProcessDefinition.Name == 'Change Due Date')
		                      ChangeDueDate++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'DocumentChange')
		                      documentChangeTask++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'AdhocTask')
		                      adhoc++;
		                 else if(genTasks.get(piwi.ProcessInstance.TargetObjectId).recordtype.Name == 'Closure')
		                      closure++;
		                 
	             	   }
	             	  
	        }
	   }
	   
	   	if(cmApproval>0)
	   	  data.add(new PieWedgeData('Change Management ('+cmApproval+')',cmApproval));
	   	if(cmChangeOwnerApproval>0)
	   	  data.add(new PieWedgeData('Change Management Change Owner ('+cmChangeOwnerApproval+')',cmChangeOwnerApproval));
	   	if(adhoc>0)
          data.add(new PieWedgeData('Adhoc('+adhoc+')',adhoc));
        if(closure> 0)
           data.add(new PieWedgeData('Closure('+closure+')',closure));
        if(documentChangeTask> 0)
           data.add(new PieWedgeData('Document Change('+documentChangeTask+')',documentChangeTask));
        if(ChangeOwner> 0)
           data.add(new PieWedgeData('Change Owner('+ChangeOwner+')',ChangeOwner));
        if(ChangeDueDate> 0)
           data.add(new PieWedgeData('Change Due Date('+ChangeDueDate+')',ChangeDueDate));
	   
	   return data;
   }    
        
    //v1.2 end
    
        
   // Wrapper class
    public class PieWedgeData {
        public String name { get; set; }
        public Decimal data { get; set; }
        public PieWedgeData(String name, Decimal data) {
            this.name = name;
            this.data = data;
        }
    }
    // ---------------------- End of chart code ------------------------------------------
	

}