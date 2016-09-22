//Approval process controller
//Used to approve all tasks and changes
/*  
    v1.0        Qualityze Inc(BK)           25-AUG-2016         Updated Version: change Field Request.
    v1.1        Qualityze Inc(SG)            5-AUG-2016          Condition added
    v1.2        Qualityze Inc(GP)           20-SEP-2016        To Add DOCUMENT and Change Management Approval list in dashboard
	v1.3        Qualityze Inc(BK)           21-SEP-2016        To Approval Submit Method 
*/

public with sharing class Approvalclass {
 string Currentpage;
    id objectid;
    boolean flag;
    boolean isApprover;
    public Boolean getisApprover(){
         system.debug('getisApprover==>'); 
        isApprover=false;
        if(flag){
            flag=false;
            string RecordType;
            
           if(ApexPages.currentPage().getParameters().get('gtid')!=null){
                objectid=ApexPages.currentPage().getParameters().get('gtid');                 
            }  
            if(objectid==null){
                String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,RecordType.Name,Name');
                if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
                    String ncid=ApexPages.currentPage().getParameters().get('id');
                    system.debug('ncidncidncid'+ncid);
                    system.debug('ncidncidncidRecordType'+RecordType);
                    if(RecordType==null){
                        RecordType=ApexPages.currentPage().getParameters().get('type');
                    }
                    //v1.1 start
                    if(ncid!=null && ncid!='')
                    {
                     List<General_Task__c> GT=database.query('Select '+ queryFieldSOfGT +' From General_Task__c where Non_conformance__c=:ncid AND RecordType.Name=:RecordType LIMIT 1000');                    
                     if(!gt.isEmpty())
                        objectid=GT[0].id;
                    }
                    //v1.1end
                }
            }
            
            string Pending='Pending';
            system.debug('inside processInstances getApprover');
            String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
            String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
            system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
            String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
            system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
            if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
                system.debug('inside processInstances if');
                List<ProcessInstance> processInstances;
                ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance where TargetObjectId =:objectid And Status =: Pending limit 1'); 
                
                system.debug('inside processInstances ProcessInstances'+ProcessInstances);     
                for(ProcessInstance pi:ProcessInstances){
                    for(ProcessInstanceWorkitem wi:pi.Workitems){
                        system.debug('inside processInstances wi.actorid'+wi.actorid); 
                        if(wi.actorid==Userinfo.getUserId()){
                            system.debug('inside processInstances wi.actorid if inside'+Userinfo.getUserId());
                            isApprover=true;
                        }
                    }
                }
            }
            system.debug('inside processInstances wi.actorid if isApprover'+isApprover);
            return isApprover;
        }
        return isApprover;
    }
    public Approvalclass(){
        flag=true;
    }
    
    public Approvalclass(Non_Conformance__c controller){
        flag=true;
    } 
    public Approvalclass(ApexPages.StandardController controller){
        flag=true;
    }   
    
    @RemoteAction
    public static boolean  submitApprovalRequest(id ObjectId,id SubmitterId, string[] approverIds,string Comments,String Field,String FieldValue,string duedate){
        
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Note_To_Approver_Owner_DueDate__c,Note_To_Approver__c,Due_Date__c,New_Due_Date__c,New_Owner__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Name');
        if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
            General_Task__c GT=database.query('Select '+ queryFieldSOfGT +' From General_Task__c where id=:ObjectId LIMIT 10000');
            Integer len=approverIds.size();
            Savepoint sp=Database.setSavepoint();
            if(Field=='Ownerid'){
                GT.New_Owner__c=FieldValue;
                system.debug('inside Field==New_Owner__c'+GT.New_Owner__c);
            }
            else{
                
                Date due_date = Date.parse(duedate);
                GT.New_Due_Date__c=due_date;
                system.debug('inside Field==New_Owner__c'+GT.New_Owner__c);
            }
            GT.Change_Owner__c=true;
            integer i=1;                                               
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
            GT.Note_To_Approver_Owner_DueDate__c=Comments; 
            GT.Initial_Submitter__c=UserInfo.getUserId();
            system.debug('GeneralTask New_Owner__c'+GT.New_Owner__c);
            system.debug('GeneralTask Initial_Submitter__c'+GT.Initial_Submitter__c);
            upsert GT;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(Comments);
            req.setObjectId(ObjectId);
            req.setSubmitterId(SubmitterId);
            
            
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
    /*- v1.0   start--change Field Request*/
    /*	v1.3	start	*/
    @RemoteAction
    public static boolean  genSubmitApprovalRequest(id ObjectId){        
        String queryFieldSOfDP = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,Note_To_Approver__c,New_Owner__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Name');
        String queryFieldSOfAP = QC_DynamicObjectHandler.getAccessibleFields('approver__c', 'id,User__c,Sequence_Position__c');
        if(queryFieldSOfDP!=null&&queryFieldSOfDP!=''){
            Document_Profile__c DP=database.query('Select '+ queryFieldSOfDP +' From Document_Profile__c where id=:ObjectId LIMIT 1');
            
            List<approver__c> oldapproverIds=database.query('Select '+ queryFieldSOfAP +' From approver__c where Document_Profile__c=:ObjectId ORDER BY Sequence_Position__c ASC LIMIT 1000');
            integer sec= Integer.valueOf(oldapproverIds[0].Sequence_Position__c);
            List<approver__c> approverIds=database.query('Select '+ queryFieldSOfAP +' From approver__c where Document_Profile__c=:ObjectId AND Sequence_Position__c=:sec  LIMIT 1000');
            Integer len=approverIds.size();
            Savepoint sp=Database.setSavepoint();
            integer i=1;                       
            system.debug('approverIds[len-i].Sequence_Position__c	'+approverIds[len-i].Sequence_Position__c);                         
            DP.CurrentApprovalSequenceNumber__c=approverIds[len-i].Sequence_Position__c;  
            

            DP.Approver__c=approverIds[len-1].User__c;i++;                                                    
            DP.Approver_1__c=approverIds[((len-i>0)?len-i:0)].User__c;i++;                                       
            DP.Approver_2__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;                                             
            DP.Approver_3__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_4__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_5__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_6__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_7__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_8__c=approverIds[((len-i)>0)?len-i:0].User__c;i++;
            DP.Approver_9__c=approverIds[((len-i)>0)?len-i:0].User__c;             
            DP.Initial_Submitter__c=UserInfo.getUserId();
            upsert DP;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(DP.Note_To_Approver__c);
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
    /*	v1.3	end	*/
    @RemoteAction
    public static boolean  ChangeFieldRequest(id recordid, string[] approverIds,string Comments,String Field,string NewValue,string FieldType,string WithApproval,string Label){
        Schema.SObjectType token = recordid.getSObjectType();
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields(string.valueOf(token),''+Field+',' +'id,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Name');
        if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
            sObject record=database.query('Select '+ queryFieldSOfGT +' From '+string.valueOf(token)+' where id=:recordid LIMIT 10000');
            Integer len=approverIds.size();
            Savepoint sp = Database.setSavepoint();   

            system.debug('WithApproval'+WithApproval);
            if(!boolean.valueOf(WithApproval)){                
                try
                {
                        if(FieldType=='Boolean'){
                            record.put(Field, Boolean.valueOf(NewValue));
                        }else if(FieldType.containsIgnoreCase('Date')){
                            NewValue=NewValue.removeStartIgnoreCase('UXT');
                            DateTime dt = DateTime.newInstance(long.valueOf(NewValue));
                            dt=dt.addDays(1);
                            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
                            record.put(Field,myDate);
                            record.put('Note_To_Approver_Owner_DueDate__c',Comments);                
                            system.debug('inside  '+record);
                        }else if(FieldType.containsIgnoreCase('DateTime')){
                            DateTime dt = DateTime.newInstance(long.valueOf(NewValue));
                            dt=dt.addDays(1);
                        }if(FieldType.containsIgnoreCase('reference')){
                            record.put(Field,NewValue);     
                            record.put('Note_To_Approver_Owner_DueDate__c',Comments);       
                        }
                    update record; 
                    return true;  
                    
                }
                catch(exception ex){
                    system.debug('inside Approval Request');
                    return false;
                }
                 
            }
            //record.Change_Owner__c=true;
            if(FieldType.containsIgnoreCase('reference')){
                record.put('New_Owner__c',NewValue);     
                record.put('ChangeFieldApprovalStatus__c','');                     
                record.put('Note_To_Approver_Owner_DueDate__c',Comments);       
            }
            integer i=1;                                               
            record.put('Approver__c', approverIds[len-1]);i++;                                                    
            record.put('Approver_1__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_2__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_3__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_4__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_5__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_6__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_7__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_8__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Approver_9__c',approverIds[((len-i>0)?len-i:0)]);i++;
            record.put('Initial_Submitter__c',UserInfo.getUserId());
            update record;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(Comments);
            req.setObjectId(recordId);
            req.setSubmitterId(userinfo.getUserId());
            
            
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
    /*--v1.0   end-change Field Request*/
    
    @RemoteAction
    public static boolean submitApprovalResponse(id ObjectId,string comments,string action,String Field){
       Savepoint sp = Database.setSavepoint();
        System.debug(action+'actionaction');
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(comments);
        req.setAction(action);
        String queryFieldSOfPR = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id');
        if(queryFieldSOfPR!=null&&queryFieldSOfPR!=''){
            List<ProcessInstanceWorkitem> PIT;
            if(action!='Removed'){
                id userid=UserInfo.getUserId();
                PIT=database.query('Select '+ queryFieldSOfPR +' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:ObjectId and ActorId =:userid');            
            }
            else{
                PIT=database.query('Select '+ queryFieldSOfPR +' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:ObjectId ');            
            }
            req.setWorkitemId(PIT[0].id);
            system.debug('^^^^^^^^^^^'+req);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            system.debug('result'+result);
            if(ObjectId.getSobjectType()==general_task__c.sObjectType){
	            if(result.getInstanceStatus()=='Rejected'){
	                system.debug('&&&&&&&&');
	                //String queryFieldgt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', '  Document_profile__c,status__c,Record_Type_Name__c');
	            
	                system.debug('$$$$$$$$$$$$$$$$$$$');
	                String queryFieldgt = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Record_Type_Name__c,Document_Profile__c');
	                String queryFieldgt_DOC = QC_DynamicObjectHandler.getAccessibleFields('Document_profile__c', 'Status__c');
	              if(queryFieldgt!=null&&queryFieldgt!='' && queryFieldgt_DOC!=null && queryFieldgt_DOC!=''){
	                    system.debug('Select '+queryFieldgt+'   from  General_task__c where id=:ObjectId'+ObjectId);
	                General_Task__c gt=database.query('Select '+ queryFieldgt +'  from  General_Task__c Where Id=:ObjectId');
	                system.debug(gt+'***');
	                    if(gt.Record_Type_Name__c=='EffectivenessReview' ||gt.Record_Type_Name__c=='CollaborationReview')
	                    {
	                        gt.Status__c='Rejected';
	                        system.debug(gt+'***');
	                        update gt;
	                    }
	                    else
	                    {
	                    system.debug(gt+'***rollback');
	                
	                    Database.rollback(sp);
	                    }   
	                }
	                
	               
	                
	               
	            }
            }
        }
        
        return true;
    }
    
    
    
    @RemoteAction
    public static List<ProcessInstance> getApprover(id Objectid){
        string Pending='Pending';
        system.debug('inside processInstances getApprover');
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
        system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
        system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            system.debug('inside processInstances if');
            List<ProcessInstance> processInstances;
            ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance where TargetObjectId =:Objectid And Status =: Pending limit 1'); 
            //  List<Product_Lot_Numbers__c> plnList = database.query('Select '+ queryFieldSOfNCPLTN +', (select ' + queryFieldSOfNCPD + ' from NC_Product_Defects__r) from Product_Lot_Numbers__c where id = :lotid limit 1');
            
            return ProcessInstances;
        }
        return null;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //NC ApprovalList Start
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
       public list<General_Task__c> getApproverList(){
        Map<id,General_Task__c> gtsMap;
        List<General_Task__c> gts;
        List<Approver__c> aprs;
        Map<id,List<Approver__c>> aprsMap;
        set<id> toApprovegentask=getGenraltaskids();
        List<Approver__c> apr;
        String queryFieldSOfAPL = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Due_Date__c,CurrentApprovalSequenceNumber__c,non_conformance__c,,Initial_Submitter__c,Status__c ,New_Owner__c,owner__r.Name ,New_Due_Date__c,Initial_Submitter__r.Name,Note_To_Approver_Owner_DueDate__c,Note_to_Approver__c,RecordTypeId,RecordType.Name,non_conformance__r.Name,');
            if(queryFieldSOfAPL!= null && queryFieldSOfAPL!= ''){ 
              string PendingApproval='Pending Approval';
              string Pending='Pending';  
                Boolean trueFlag=true;
              gts=database.query('Select  '+queryFieldSOfAPL +' from General_Task__c where id=:toApprovegentask AND Non_Conformance__c!=null'); 
              gtsMap=new Map<id,General_Task__c>(gts);        
              String queryFieldSOfAPs = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_task__c,Sequence_Position__c,Due_Date__c,User__c');
                if(queryFieldSOfAPs!= null && queryFieldSOfAPs!= ''){ 
                    set<id> gentaskids=gtsMap.keySet();
                    aprs=database.query('Select  '+queryFieldSOfAPs +' from Approver__c where General_Task__c IN:gentaskids'); 
                    aprsMap=new Map<id,List<Approver__c>>();
                    for(General_Task__c gt:gtsMap.values()){    //==========================================this  is to show  duedate 
                        for(Approver__c ap:aprs){  
                            if(ap.General_Task__c==gt.id){
                                apr=new List<Approver__c>();
                                apr.add(ap);                                
                            }

                        }                    
                        aprsMap.put(gt.id,apr);
                    }
                }
                for(General_Task__c gt:gtsMap.values()){
                    if(aprsMap.get(gt.id)!=null){
                        for(Approver__c ap:aprsMap.get(gt.id)){
                            if(ap.Sequence_Position__c==gt.CurrentApprovalSequenceNumber__c){
                                gt.Due_Date__c=ap.Due_Date__c;
                            }
                        }
                    }
                }
               return  gtsMap.values();
            }
        
        else
            return new List<General_Task__c>();
    }
    
    public Map<id,User> User{get;set;}
    Public Map<id,id> submitted{get;set;}
    public set<id> getGenraltaskids(){
        set<id> userids=new set<id>();
        submitted=new Map<id,id>();
        set<id> genids=new set<id>();
        string Pending='Pending';
        system.debug('inside processInstances getApprover');
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
        system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
            system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            system.debug('inside processInstances if');
        List<ProcessInstance> processInstances;
        id usid=UserInfo.getUserId();            
        ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems where actorid=:usid),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance Where  Status =: Pending '); 
            for(ProcessInstance PI:ProcessInstances){
                for(ProcessInstanceWorkitem wi:PI.Workitems){
                   genids.add(PI.TargetObjectid);
                }                  
                userids.add(PI.SubmittedById);
                submitted.put(PI.TargetObjectid, PI.SubmittedById);
            }
                User=new Map<id,User>();
                String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'id,Name');            
                if(queryFieldNames != null && queryFieldNames != '')
                {
                    String qry='select ' + queryFieldNames + ' FROM User where id in:userids';
                    LIST<User> ulist=database.query (qry);
                    User.putAll(ulist);                
                }
            return genids;
        }
        return null;
    }
    //////////////////////////////////////////////////////////////////////////////////
    //NC Approval list END
    //////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////
    //CAPA Approval list Start
    //////////////////////////////////////////////////////////////////////////////////
    
        public Map<id,sObject> TargetParent{get;set;}
        public list<General_Task__c> getCAPAApproverList(){
        Map<id,General_Task__c> gtsMap;
        List<General_Task__c> gts;
        List<CAPA__c> capas;
        Map<id,Capa__c> capaMaps;
        List<Approver__c> aprs;
        Map<id,List<Approver__c>> aprsMap;
        set<id> toApprovegentask=getTargetObjectids();
        TargetParent=new Map<id,sObject>();
        List<Approver__c> apr;
        String queryFieldSOfAPL = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Due_Date__c,CurrentApprovalSequenceNumber__c,non_conformance__c,CAPA__c,Initial_Submitter__c,Status__c ,New_Owner__c,owner__r.Name ,New_Due_Date__c,Initial_Submitter__r.Name,Note_To_Approver_Owner_DueDate__c,Note_to_Approver__c,RecordTypeId,RecordType.Name,non_conformance__r.Name,CAPA__r.Name');
            if(queryFieldSOfAPL!= null && queryFieldSOfAPL!= ''){ 
              string PendingApproval='Pending Approval';
              string Pending='Pending';  
                Boolean trueFlag=true;
              gts=database.query('Select  '+queryFieldSOfAPL +' from General_Task__c where id=:toApprovegentask AND CAPA__c != null'); 
              gtsMap=new Map<id,General_Task__c>(gts);        
              
        String queryFieldNamesCapa = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c',  'id, ownerid, owner.Name');        
                if(queryFieldNamesCapa!= null && queryFieldNamesCapa!= ''){ 
                capas=database.query('Select  '+queryFieldNamesCapa +' from CAPA__c where id=:toApprovegentask '); 
                
                capaMaps=new Map<id,capa__c>(capas);
                }    
              system.debug('TargetParent inside'+TargetParent);  
              String queryFieldSOfAPs = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_task__c,Sequence_Position__c,Due_Date__c,User__c');
                if(queryFieldSOfAPs!= null && queryFieldSOfAPs!= ''){ 
                    set<id> gentaskids=new set<id>();
                    gentaskids.addAll(gtsMap.keySet());
                    gentaskids.addAll(capaMaps.keySet());
                    aprs=database.query('Select  '+queryFieldSOfAPs +' from Approver__c where General_Task__c IN:gentaskids'); 
                    aprsMap=new Map<id,List<Approver__c>>();
                    for(General_Task__c gt:gtsMap.values()){    //==========================================this  is to show  duedate 
                        for(Approver__c ap:aprs){  
                            if(ap.General_Task__c==gt.id){
                                apr=new List<Approver__c>();
                                apr.add(ap);                                
                            }

                        }                    
                        aprsMap.put(gt.id,apr);
                    }
                }
                for(General_Task__c gt:gtsMap.values()){
                    if(aprsMap.get(gt.id)!=null){
                        for(Approver__c ap:aprsMap.get(gt.id)){
                            if(ap.Sequence_Position__c==gt.CurrentApprovalSequenceNumber__c){
                                gt.Due_Date__c=ap.Due_Date__c;
                            }
                        }
                    }
                }
               TargetParent.putAll(gts); 
               TargetParent.putAll(capas);
               return  gtsMap.values();
            }
        
        else
            return new List<General_Task__c>();
    }

   
        
    public set<id> getTargetObjectids(){
        system.debug('inside getTargetObjectids');
        set<id> userids=new set<id>();
        submitted=new Map<id,id>();
        Set<Id> allTargetIds=new Set<Id>();
        set<id> genids=new set<id>();
        string Pending='Pending';
        system.debug('inside processInstances getApprover');
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
        system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
            system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            system.debug('inside processInstances if');
        List<ProcessInstance> processInstances;
        id usid=UserInfo.getUserId();            
        ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems where actorid=:usid),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance Where  Status =: Pending '); 
        for(ProcessInstance PI:ProcessInstances){
                for(ProcessInstanceWorkitem wi:PI.Workitems){
                   allTargetIds.add(PI.TargetObjectid);
                    system.debug('inside getTargetObjectids PI.TargetObjectid'+PI.TargetObjectid);
                }                  
         }
         String queryFieldNamesGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,recordtype.Name,CAPA__c');
         if(queryFieldNamesGT!=null && queryFieldNamesGT!=''){
            for(General_Task__c genTask : Database.query('SELECT '+queryFieldNamesGT+' FROM General_Task__c where Id IN :allTargetIds AND CAPA__c!=null')){
                    genids.add(genTask.Id);
            }
         }
         for(ProcessInstance procInst:ProcessInstances){
                userids.add(procInst.SubmittedById);
                submitted.put(procInst.TargetObjectid, procInst.SubmittedById);
         }
                
        User=new Map<id,User>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'id,Name');            
        if(queryFieldNames != null && queryFieldNames != '')
        {
            String qry='select ' + queryFieldNames + ' FROM User where id in:userids';
            LIST<User> ulist=database.query (qry);
            User.putAll(ulist);                
        }
         return allTargetIds;
        }
        return null;
    }
    //////////////////////////////////////////////////////////////////////////////////
    //CAPA Approval list End
    //////////////////////////////////////////////////////////////////////////////////
    
    
      
  //v1.2 start
    public List<General_Task__c> getDOCApproverList(){
        
        Map<Id,General_Task__c> genTaskMap;
        List<General_Task__c> genTasks;
        
        List<Document_Profile__c> docProfiles;
        Map<Id,Document_Profile__c> documentProfileMap;
        
        List<Approver__c> approvers;
        Map<Id,List<Approver__c>> approversMap;
        
        Set<Id> toApprovegentask=getTargetObjectids();
        System.debug('ApprovalClass getDOCApproverList  toApprovegentask   ' + toApprovegentask);
        TargetParent=new Map<Id,SObject>();
        List<Approver__c> apr;
        
        String genTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Due_Date__c,CurrentApprovalSequenceNumber__c,Document_Profile__c,Document_Profile__r.Name,Initial_Submitter__c,Status__c ,New_Owner__c,owner__r.Name ,New_Due_Date__c,Initial_Submitter__r.Name,Note_To_Approver_Owner_DueDate__c,Note_to_Approver__c,RecordTypeId,RecordType.Name');
        if(genTaskFields!= null && genTaskFields!= ''){ 
               String PendingApproval='Pending Approval';
               String Pending='Pending';  
               Boolean trueFlag=true;
               genTasks=database.query('Select  '+genTaskFields +' from General_Task__c where id=:toApprovegentask AND Document_Profile__c != null'); 
               genTaskMap=new Map<id,General_Task__c>(genTasks);        
               String docProfileFields = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c',  'id,Name , RecordType.Name, Note_To_Approver__c ,ownerid, owner.Name,Due_Date__c,Status__c,New_Owner__c,ApprovalProcess__c');        
               if(docProfileFields!= null && docProfileFields!= ''){ 
                    docProfiles=database.query('Select  '+docProfileFields +' from Document_Profile__c where id=:toApprovegentask '); 
                    documentProfileMap=new Map<id,Document_Profile__c>(docProfiles);
               }    
              system.debug('TargetParent inside'+TargetParent);  
              String queryFieldSOfAPs = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_task__c,Sequence_Position__c,Due_Date__c,User__c');
                if(queryFieldSOfAPs!= null && queryFieldSOfAPs!= ''){ 
                    set<id> gentaskids=new set<id>();
                    gentaskids.addAll(genTaskMap.keySet());
                    gentaskids.addAll(documentProfileMap.keySet());
                    approvers=database.query('Select  '+queryFieldSOfAPs +' from Approver__c where General_Task__c IN:gentaskids'); 
                    approversMap=new Map<id,List<Approver__c>>();
                    for(General_Task__c gt:genTaskMap.values()){    //==========================================this  is to show  duedate 
                        for(Approver__c ap:approvers){  
                            if(ap.General_Task__c==gt.id){
                                apr=new List<Approver__c>();
                                apr.add(ap);                                
                            }

                        }                    
                        approversMap.put(gt.id,apr);
                    }
                }
                for(General_Task__c gt:genTaskMap.values()){
                    if(approversMap.get(gt.id)!=null){
                        for(Approver__c ap:approversMap.get(gt.id)){
                            if(ap.Sequence_Position__c==gt.CurrentApprovalSequenceNumber__c){
                                gt.Due_Date__c=ap.Due_Date__c;
                            }
                        }
                    }
                }
               TargetParent.putAll(genTasks); 
               TargetParent.putAll(docProfiles);
               System.debug('ApprovalClass  getDOCApproverList   genTaskMap   '+genTaskMap);
               //return  genTaskMap.values();
               return TargetParent.values();
       }
       else
        return new List<General_Task__c>();
    }
    
     ////////CM Approval list starts///////////////////////////////////////////////////////  
  /////////////////////////////////////////////////////////////////////////////////////
    public List<General_Task__c> getCMApproverList(){
        Map<Id,General_Task__c> genTaskMap;
        List<General_Task__c> genTasks;
        
        List<Change_Management__c> cmList;
        Map<Id,Change_Management__c> cmMap;
        
        List<Approver__c> approvers;
        Map<Id,List<Approver__c>> approversMap;
        
        Set<Id> toApprovegentask=getTargetObjectids();
        System.debug('ApprovalClass getCMApproverList  toApprovegentask   ' + toApprovegentask);
        TargetParent=new Map<Id,SObject>();
        List<Approver__c> apr;
        
        String genTaskFields = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Due_Date__c,CurrentApprovalSequenceNumber__c,Change_Management__c,Change_Management__r.Name,Initial_Submitter__c,Status__c ,New_Owner__c,owner__r.Name ,New_Due_Date__c,Initial_Submitter__r.Name,Note_To_Approver_Owner_DueDate__c,Note_to_Approver__c,RecordTypeId,RecordType.Name');
        if(genTaskFields!= null && genTaskFields!= ''){ 
               String PendingApproval='Pending Approval';
               String Pending='Pending';  
               Boolean trueFlag=true;
               genTasks=database.query('Select  '+genTaskFields +' from General_Task__c where id=:toApprovegentask AND Change_Management__c != null'); 
               genTaskMap=new Map<id,General_Task__c>(genTasks);        
               String cmFields = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c',  'id,Name , RecordType.Name, Note_To_Approver__c ,ownerid, owner.Name,Due_Date__c,Status__c,New_Owner__c ');        
               if(cmFields!= null && cmFields!= ''){ 
                    cmList=database.query('Select  '+cmFields +' from Change_Management__c where id=:toApprovegentask '); 
                    cmMap=new Map<id,Change_Management__c>(cmList);
               }    
              system.debug('TargetParent inside'+TargetParent);  
              String queryFieldSOfAPs = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_task__c,Sequence_Position__c,Due_Date__c,User__c');
                if(queryFieldSOfAPs!= null && queryFieldSOfAPs!= ''){ 
                    set<id> gentaskids=new set<id>();
                    gentaskids.addAll(genTaskMap.keySet());
                    gentaskids.addAll(cmMap.keySet());
                    approvers=database.query('Select  '+queryFieldSOfAPs +' from Approver__c where General_Task__c IN:gentaskids'); 
                    approversMap=new Map<id,List<Approver__c>>();
                    for(General_Task__c gt:genTaskMap.values()){    //==========================================this  is to show  duedate 
                        for(Approver__c ap:approvers){  
                            if(ap.General_Task__c==gt.id){
                                apr=new List<Approver__c>();
                                apr.add(ap);                                
                            }

                        }                    
                        approversMap.put(gt.id,apr);
                    }
                }
                for(General_Task__c gt:genTaskMap.values()){
                    if(approversMap.get(gt.id)!=null){
                        for(Approver__c ap:approversMap.get(gt.id)){
                            if(ap.Sequence_Position__c==gt.CurrentApprovalSequenceNumber__c){
                                gt.Due_Date__c=ap.Due_Date__c;
                            }
                        }
                    }
                }
               TargetParent.putAll(genTasks); 
               TargetParent.putAll(cmList);
               System.debug('ApprovalClass  getCMApproverList   genTaskMap   '+genTaskMap);
               return TargetParent.values();
       }
       else
        return new List<General_Task__c>();
    }
    
    
    
    //v1.2 end

    
           string Currentpagee;
           id objectidd;
           boolean flagg;
           boolean isApproverr;   
    
          public Boolean getisApproverr(){ 
         isApproverr=false;
        if(flagg){
            flagg=false;
            string RecordType;
            
           if(ApexPages.currentPage().getParameters().get('crid')!=null){
                objectidd=ApexPages.currentPage().getParameters().get('crid');                 
            }  
    
             if(objectidd==null){
                String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,RecordType.Name,Name');
                if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
                    id cmid=ApexPages.currentPage().getParameters().get('id');
                    system.debug('ncidncidncid'+cmid);
                    system.debug('ncidncidncidRecordType'+RecordType);
                    if(RecordType==null){
                        RecordType=ApexPages.currentPage().getParameters().get('type');
                    }
                    Change_Management__c GT=database.query('Select '+ queryFieldSOfGT +' From Change_Management__c where Change_Management__c=:cmid AND RecordType.Name=:RecordType LIMIT 1000');                    
                    objectidd=GT.id;
                }
            }
            
             string pending='Pending';            
             String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
             String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
             String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
                
                  if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!='')
                  {
                   List<ProcessInstance> processInstances;
                   ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance where TargetObjectId =:objectid And Status =: Pending limit 1'); 
                      
                       for(ProcessInstance pi:ProcessInstances){
                    for(ProcessInstanceWorkitem wi:pi.Workitems){
                        system.debug('inside processInstances wi.actorid'+wi.actorid); 
                        if(wi.actorid==Userinfo.getUserId()){
                            system.debug('inside processInstances wi.actorid if inside'+Userinfo.getUserId());
                            isApproverr=true;
                        }
                    }
                }
            }
             system.debug('inside processInstances wi.actorid if isApprover'+isApproverr);
            return isApproverr; 

        }
              return isApproverr;
          }  
          
    //@Remote action for submit approval Request
     @RemoteAction
     public static boolean  submitforApprovalRequest(id ObjectId,id SubmitterId, string[] approverIds,string Comments,String Field,String FieldValue,string duedate){
        
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,Note_To_Approver__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Name');
        if(queryFieldSOfGT!=null&&queryFieldSOfGT!=''){
            Change_Management__c GT=database.query('Select '+ queryFieldSOfGT +' From Change_Management__c where id=:ObjectId LIMIT 10000');
            Integer len=approverIds.size();
            Savepoint sp;
            if(Field=='Ownerid'){
                GT.New_Owner__c=FieldValue;
                system.debug('inside Field==New_Owner__c'+GT.New_Owner__c);
            }
            else{
                
                Date due_date = Date.parse(duedate);
                GT.New_Due_Date__c=due_date;
                system.debug('inside Field==New_Owner__c'+GT.New_Owner__c);
            }
            //GT.Change_Owner__c=true; 
            integer i=1;                                               
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
            GT.Note_To_Approver_Owner_DueDate__c=Comments; 
            GT.Initial_Submitter__c=UserInfo.getUserId();
            system.debug('GeneralTask New_Owner__c'+GT.New_Owner__c);
            system.debug('GeneralTask Initial_Submitter__c'+GT.Initial_Submitter__c);
            upsert GT;
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setProcessDefinitionNameOrId('Change_Due_Date ');
            req.setComments(Comments);
            req.setObjectId(ObjectId);
            req.setSubmitterId(SubmitterId);
            
            
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
         
    
    //@Remote action for submit approval response
    @RemoteAction
    public static boolean submitforApprovalResponse(id ObjectId,string comments,string action,String Field){
        Savepoint sp;
        
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(comments);
        req.setAction(action);
        String queryFieldSOfPR = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id');
        if(queryFieldSOfPR!=null&&queryFieldSOfPR!=''){
            List<ProcessInstanceWorkitem> PIT;
            if(action!='Removed'){
                id userid=UserInfo.getUserId();
                PIT=database.query('Select '+ queryFieldSOfPR +' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:ObjectId and ActorId =:userid');            
            }
            else{
                PIT=database.query('Select '+ queryFieldSOfPR +' FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId=:ObjectId ');            
            }
            req.setWorkitemId(PIT[0].id);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            if(!result.isSuccess()){
                Database.rollback(sp);
            }
        }
        
        return true;
    } 
     
    
    //@Remote action for getting approver
    @RemoteAction
     public static List<ProcessInstance> getCMApprover(id Objectid){
        string Pending='Pending';
        system.debug('inside processInstances getApprover');
        String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
        String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
        system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
        String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
        system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
        system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
        if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
            system.debug('inside processInstances if');
            List<ProcessInstance> processInstances;
            ProcessInstances=database.query('Select  '+queryFieldSOfPI +', ( Select '+ queryFieldSOfPW +' from Workitems),( Select '+ queryFieldSOfPs +' from Steps) FROM ProcessInstance where TargetObjectId =:Objectid And Status =: Pending limit 1'); 
            //  List<Product_Lot_Numbers__c> plnList = database.query('Select '+ queryFieldSOfNCPLTN +', (select ' + queryFieldSOfNCPD + ' from NC_Product_Defects__r) from Product_Lot_Numbers__c where id = :lotid limit 1');
            
            return ProcessInstances;
        }
        return null;
    }
      
}