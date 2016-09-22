/*

v1.0    Qualityze Inc(BK)       03-MAY-2016     Initial Version
                                                This Trigger Handler  includes General Task ,general sub task,Attachment,Approver,Action Plan Root Cause and Disposition product related methods
v2.0    Qualityze Inc(BK)       21-MAY-2016     Updated Version for capa.
v2.1    Qualityze Inc(BK)       06-JUN-2016     BUG-FIX :BUG-00561(LINE :494-494)
v2.1.1  Qualityze Inc(SLVR)     27-JUL-2016     Added 'Pending Action Completion' to General Task
v2.1.2  Qualityze Inc(BK)       12-08-2016      For ChangeManagement Flow
v2.1.3  Qualityze Inc(ST)       19-08-2016      For Document module Chronology
*/
public with sharing class GeneralTaskTriggerHandler {
    
    //common variable
    public static Map<integer,string> dateMap;   
    public static Boolean Work_Flow_Status_Update_Trigger_Helper_isTriggerFired; 
    public static boolean con_flag;
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // general Task Trigger Handler start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @future
    public static void GeneralTaskSubmitForApproval(List<id> Objectids,map<id,id> Userid){  
        system.debug('Objectids'+Objectids);
        List<Approval.ProcessSubmitRequest> lstprocess=new List<Approval.ProcessSubmitRequest>();
        for(id Objectid:Objectids){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Automate Approval Process');
            req.setObjectId(Objectid);
            req.setSubmitterId(Userid.get(Objectid));
            lstprocess.add(req);      
        }
        List<Approval.ProcessResult> results = Approval.process(lstprocess);
    }
    public static void GeneralTaskUpdateParent(set<id> parentids,set<id> clonecapa,set<id> NCWorkFlowStatusInReview){
        system.debug('NCWorkFlowStatusInReviewNCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
        if(!parentids.isEmpty()||!NCWorkFlowStatusInReview.isEmpty()){
            system.debug('have acess before accessing ');
            parentids.addAll(NCWorkFlowStatusInReview);
            String queryFieldNamesNc = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id,NC_Status__c,NC_Workflow_Status__c');
            if(queryFieldNamesNc != null && queryFieldNamesNc != ''){
                system.debug('have acess access accessing ');
                List<Non_Conformance__c> ncs= database.query('Select '+ queryFieldNamesNc +' from Non_Conformance__c where id IN:parentids');  
                if(!ncs.isEmpty()){
                    //this is clsoure
                    system.debug('inside GeneralTaskUpdateParent parentids'+parentids);
                    system.debug('inside GeneralTaskUpdateParent NCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
                    for(Non_Conformance__c nc:ncs){
                        if(NCWorkFlowStatusInReview.contains(nc.id)){
                            nc.NC_Workflow_Status__c ='In Review';
                        }else{
                            nc.NC_Status__c='Closed';
                            nc.NC_Workflow_Status__c =  'Closed';
                        }
                    }
                    upsert ncs;                                    
                }
            }
            
            
            //-----v2.1.2-----start
            
            String queryFieldNamesCM = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,Status__c');
            if(queryFieldNamesCM != null && queryFieldNamesCM != ''){
                system.debug('have acess access accessing ');
                List<Change_Management__c> cms= database.query('Select '+ queryFieldNamesCM +' from Change_Management__c where id IN:parentids');  
                if(!cms.isEmpty()){
                    //this is clsoure
                    system.debug('inside GeneralTaskUpdateParent parentids'+parentids);
                    system.debug('inside GeneralTaskUpdateParent NCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
                    for(Change_Management__c cm:cms){
                    cm.status__c='Closed';
                    }
                    upsert cms;                                    
                }
            }
            
            //-----v2.1.2-----end
            
            
            
            
            
            String queryFieldNamesCAPA = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'id,CAPA_Status__c,CAPA_Phase__c');
            if(queryFieldNamesCAPA != null && queryFieldNamesCAPA != ''){
                system.debug('have acess access accessing ');
                set<id> capaid=new set<id>();
                capa__c newcapa;
                capaid.addAll(parentids);
                capaid.addAll(clonecapa);
                string strfeildname;
                List<id> clonecapaList=new List<id>(clonecapa);
                List<Schema.FieldSetMember> fieldsetlist = SObjectType.CAPA__c.FieldSets.CAPA_Fields.getFields();
                system.debug('fieldsetlist-->'+fieldsetlist);
                String fieldList ='';
                for(Schema.FieldSetMember f : fieldsetlist) {
                    fieldList += ','+ f.getFieldPath();
                }
                system.debug('dynamic field list-->'+fieldList);
                system.debug('select '+ queryFieldNamesCAPA+''+fieldList+' from CAPA__c where id IN:capaid');
                List<CAPA__c> capas= database.query('select '+ queryFieldNamesCAPA+' '+fieldList+' from CAPA__c where id IN:capaid');  
                List<CAPA__c> newcapas = new List<CAPA__c>();
                
                if(!capas.isEmpty()){
                    //this is clsoure
                    for( CAPA__c capa:capas){
                        capa.CAPA_Status__c='Closed';
                        capa.CAPA_Phase__c='Closed';
                        newcapas.add(capa);
                        //capa.CAPA_Workflow_Status__c = 'Closed';
                        system.debug('before insert cloned for'+clonecapa);
                        if(clonecapa.contains(capa.id)){
                            system.debug('after insert cloned for');
                            newcapa= capa.clone(false, true);
                            newcapa.CAPA_Status__c='Open';
                            newcapas.add(newcapa);
                        }
                    }
                    system.debug('newcapas-->'+newcapas);
                    upsert newcapas;          
                    system.debug('after insert cloned capas');
                    Id parentId;
                    Id childId;
                    CAPAJunction__c capajuncobj; 
                    CAPAJunction__c capaj;
                    List<CAPAJunction__c> CAPAJunctionList=new List<CAPAJunction__c>();
                    integer count=0;
                    for(CAPA__c cap:newcapas){
                        if(!capaid.contains(cap.id)){
                            system.debug('inside juncion child obj creation-->'+cap);
                            system.debug('inside juncion child obj creation-->'+cap.id);
                            capaj = new  CAPAJunction__c();
                            capaj.CAPAChild__c = cap.id;
                            capaj.CAPAParent__c=clonecapaList[Count];
                            CAPAJunctionList.add(capaj);
                            count++;
                        }                       
                    }//end of for loop
                    insert CAPAJunctionList;

                }
            }       
        }
        
    }
    public static set<id>  GeneralTaskUpdateNextPhase(List<General_Task__c> gts,List<General_Task__c> toupdate,List<General_Task__c> triggeredgts){
        system.debug('inside updatenext phase ');
        Map<id,General_Task__c> triggeredmap=new Map<id,General_Task__c>(triggeredgts);
        set<id> NCWorkFlowStatusInReview=new set<id>();
        List<General_Task__c> newgt;
        List<General_Task__c> toUpsertgt=new List<General_Task__c>();
        Map<id,List<General_Task__c>> genraltasksOfNc=new Map<id,List<General_Task__c>>();  
        General_Task__c closure;        
        boolean Alltasksareclosed;
        id parent;
        //non conformance map  
        for(General_Task__c gt:toupdate){                                                           //populating nc map             
            
            //---v2.1.2 start
            //parent=gt.Non_Conformance__c==null?gt.CAPA__c:gt.Non_Conformance__c;
            parent=gt.Non_Conformance__c==null?(gt.CAPA__c==null?gt.Change_Management__c:gt.CAPA__c):gt.Non_Conformance__c;
            //---v2.1.2 end
            if(genraltasksOfNc.containsKey(parent)){
                genraltasksOfNc.get(parent).add(gt);
            }
            else{
                newgt=new List<General_Task__c>();
                newgt.add(gt); 
                genraltasksOfNc.put(parent,newgt); 
            }  
        }
        Decimal current;
        boolean continueforLoop=false;
        for(General_Task__c gt:gts){                                        //loop for current closed tasks
            //---v2.1.2 start
            //parent=gt.Non_Conformance__c==null?gt.CAPA__c:gt.Non_Conformance__c;
            parent=gt.Non_Conformance__c==null?(gt.CAPA__c==null?gt.Change_Management__c:gt.CAPA__c):gt.Non_Conformance__c;
            //---v2.1.2 end
            
            
            
            system.debug('inside General Task secquence');
            current=0;
            continueforLoop=false;
            
            for(General_Task__c g:genraltasksOfNc.get(parent)){      //loop to get next  secquence number of the successor  task 
                
                system.debug('genraltasksOfNc'+g);
                if(g.Sequence_Position__c >gt.Sequence_Position__c){ 
                    if((g.Sequence_Position__c<current||current==0)&&g.Status__c!='Closed'&&g.Status__c!='Void'){
                        current=g.Sequence_Position__c;    
                    }                
                }
                if(g.Sequence_Position__c==gt.Sequence_Position__c&&g.id!=gt.id&&g.Status__c!=gt.Status__c){
                    continueforLoop=true;
                }                
            }
            
            
            if(continueforLoop){                                                    //if they have no successor  task 
                continue;
            }
            Alltasksareclosed=true;
            for(General_Task__c g:genraltasksOfNc.get(parent)){      //get the successor tasks
                
                system.debug('inside genraltasksOfNc genraltasksOfNc current'+current);
                if(current==g.Sequence_Position__c&&g.Status__c=='Created'&&!GeneralTaskRt_map.get(g.recordTypeID).getName().containsIgnoreCase('Closure')){
                    g.Status__c='Open';
                    if(!triggeredmap.containsKey(g.id)&&current==g.Sequence_Position__c){       //filtering tasks that are not in the triggered one
                        system.debug('inside genraltasksOfNc genraltasksOfNc record'+g);
                        toUpsertgt.add(g);
                    }
                }
                if((g.Status__c!='Void')&&(g.Status__c!='Closed')&&!GeneralTaskrt_map.get(g.recordTypeID).getName().containsIgnoreCase('Closure')){
                    system.debug('closure should not open'+g);
                    Alltasksareclosed=false;
                }
                if(GeneralTaskrt_map.get(g.recordTypeID).getName().containsIgnoreCase('Closure')){
                    system.debug('current closure '+g);
                    system.debug('current closure '+triggeredmap.containsKey(g.Id));
                    closure=g;
                }
                
                
            }
            system.debug('inside genraltasksOfNc Alltasksareclosed'+Alltasksareclosed);
            if(closure!=null)
                if(closure.Status__c=='Created'&&Alltasksareclosed){        // open Closure if all tasks are closed
                    closure.Status__c='Open';
                    if(closure.Non_Conformance__c!=null){
                    NCWorkFlowStatusInReview.add(closure.Non_Conformance__c);
                        system.debug('inside genraltasksOfNc genraltasksOfNc NCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
                    }
                    if(!triggeredmap.containsKey(closure.id)){       //filtering tasks that are not in the triggered one
                        system.debug('inside genraltasksOfNc genraltasksOfNc closure'+closure);
                        
                        toUpsertgt.add(closure);
                    }
                }
            closure=null;
            
            
        }// end of loop  
        
        if(!toUpsertgt.isEmpty())
            update toUpsertgt;              //updating the opening tasks
        return NCWorkFlowStatusInReview;
        
    }
    //============================================================update next phase new end
    public static Map<ID,Schema.RecordTypeInfo> GeneralTaskrt_Map; 
    
    
    public static void GeneralTask_BeforeTrigger(List<General_Task__c> gtList, Map<id,General_Task__c> oldMap){
        GeneralTaskrt_Map = General_Task__c.sObjectType.getDescribe().getRecordTypeInfosById();
        set<id> ParentIds=new set<id>();
        set<id> ParentOwnerUpdates=new set<id>();
        set<id> gentaskIds=new set<id>();
        List<General_Task__c> insertList=new List<General_Task__c>();
        Map<id,General_Task__c> newMap=new Map<id,General_Task__c>();
        for(General_Task__c g:gtList){
            g.Record_Type_Name__c=GeneralTaskrt_Map.get(g.recordTypeID).getName();                              //updated by sarath for chronology
            if(!GeneralTaskRt_map.get(g.recordTypeID).getName().containsIgnoreCase('Closure')){                 //filtering if they are not closure
                //----v2.1.2 start
                //ParentIds.add(g.Non_Conformance__c==null?g.CAPA__c:g.Non_Conformance__c);
                ParentIds.add(g.Non_Conformance__c==null?(g.CAPA__c==null?g.Change_Management__c:g.CAPA__c):g.Non_Conformance__c);
                //---v2.1.2 end
            }
            
            if(g.id!=null){
                newMap.put(g.id, g);    
            }
            else{
                insertList.add(g);
                ParentOwnerUpdates.add(g.Non_Conformance__c==null?g.CAPA__c:g.Non_Conformance__c);
            }
            
        }
        gentaskIds.addAll(newMap.keySet());
        List<General_Task__c> generaltasks;                                                         //these general tasks required for update closure
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Sequence__c,Sequence_Position__c,status__c,Change_Management__c,RecordTypeId,RecordType.Name,Add_Effectiveness_verificiation__c,CAPA__c,Non_Conformance__c');        
        if(queryFieldNames != null && queryFieldNames != ''&&!ParentIds.isEmpty()){     
            //----v2.1.2 start
            //generaltasks = database.query('Select '+ queryFieldNames +' from General_Task__c where (Non_Conformance__c IN:ParentIds OR CAPA__c IN:ParentIds) AND id NOT IN:gentaskIds');
            //
            generaltasks = database.query('Select '+ queryFieldNames +' from General_Task__c where (Non_Conformance__c IN:ParentIds OR CAPA__c IN:ParentIds OR Change_Management__c IN:ParentIds ) AND id NOT IN:gentaskIds');
            //----v2.1.2 end
        }
        system.debug('beforeTrigger generaltasks'+generaltasks);
        if(generaltasks==null){
            generaltasks=new List<General_Task__c>();
        }
        generaltasks.addAll(gtList);
        
        //==================================================
        GeneralTaskBeforeUpdate(newMap,oldMap,ParentIds,generaltasks);                    
        
        GeneralTaskBeforeinsert(insertList,ParentOwnerUpdates); 
        //==========================================================
        
        //beforeUpdate(newMap,oldMap,nonConformanceIds,generaltasks);
        
    }
    
    
    public static void GeneralTaskBeforeinsert(List<General_Task__c> gtsinsert,set<id> ncs){
        
        if(!ncs.isEmpty()){
            system.debug('have acess before accessing ');
            String queryFieldNamesNc = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id,ownerid,');
            if(queryFieldNamesNc != null && queryFieldNamesNc != ''){
                system.debug('have acess access accessing ');
                List<Non_Conformance__c> nccs= database.query('Select '+ queryFieldNamesNc +' from Non_Conformance__c where id IN:ncs');  
                if(!nccs.isEmpty()){
                    //this is clsoure
                    Map<id,Non_Conformance__c> ncMap=new Map<id,Non_Conformance__c>(nccs);
                    for(General_task__c gt:gtsinsert){
                        gt.ParentOwner__c=ncMap.get(gt.Non_Conformance__c).ownerid;
                    }                            
                }
                List<CAPA__C> capas= database.query('Select '+ queryFieldNamesNc +' from CAPA__C where id IN:ncs');  
                if(!nccs.isEmpty()){
                    //this is clsoure
                    Map<id,CAPA__C> capaMap=new Map<id,CAPA__C>(capas);
                    for(General_task__c gt:gtsinsert){
                        if(gt.CAPA__C!=null)
                            gt.ParentOwner__c=capaMap.get(gt.CAPA__C).ownerid;
                    }                            
                }
            }            
        }                    
        
    }
    
    private static Map<id,ProcessInstance> processInstancesmap;
    private static void GeneralTaskApprovalComments(List<General_task__c> gts){
        set<id> Objectids=new set<id>();
        for(General_task__c gt:gts){
            Objectids.add(gt.id);
        }
        if(processInstancesmap==null){
            string Removed='Removed';
            string Rejected='Rejected';
            system.debug('inside processInstances getApprover');
            String queryFieldSOfPW = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceWorkitem', 'id,actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPW'+queryFieldSOfPW);
            String queryFieldSOfPI = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstance', 'Id,TargetObjectid,SubmittedById, CreatedById , Status');
            system.debug('inside processInstances getApprover queryFieldSOfPI'+queryFieldSOfPI);
            String queryFieldSOfPs = QC_DynamicObjectHandler.getAccessibleFields('ProcessInstanceStep', 'Id, StepStatus, Comments,Actorid');
            system.debug('inside processInstances getApprover queryFieldSOfPs'+queryFieldSOfPs);        
            system.debug('inside processInstances if'+queryFieldSOfPW+''+queryFieldSOfPI+''+queryFieldSOfPs);        
            system.debug('inside processInstances if');            
            List<ProcessInstance> processInstances;
            processInstancesmap=new Map<id,processInstance>();
            if(queryFieldSOfPI!=null&&queryFieldSOfPI!=''&&queryFieldSOfPW!=null&&queryFieldSOfPW!=''&&queryFieldSOfPs!=null&&queryFieldSOfPs!=''){
                string qry='Select  '+queryFieldSOfPI +' ,( Select ' + queryFieldSOfPs + ' from Steps ORDER BY CreatedDate ASC limit 1)  FROM ProcessInstance where  TargetObjectId IN:Objectids  ORDER BY CreatedDate ASC limit 1000';                                
                for(ProcessInstance pi:database.query(qry)){
                    processInstancesmap.put(pi.TargetObjectId, pi);                    
                }
                for(General_task__c gt:gts){
                    system.debug('inside for loop');
                    if(processInstancesmap.containsKey(gt.id)){
                        system.debug('process Instance'+gt.id);
                        if(!processInstancesmap.get(gt.id).Steps.isEmpty()){
                            system.debug('processInstancesmapprocessInstancesmap'+processInstancesmap.get(gt.id).Steps[0].Comments);
                            if(processInstancesmap.get(gt.id).Steps[0].StepStatus=='Rejected'||processInstancesmap.get(gt.id).Steps[0].StepStatus=='Removed' ){
                                gt.Rejection_Comments__c=processInstancesmap.get(gt.id).Steps[0].Comments;             
                            }
                            else{
                                if(processInstancesmap.get(gt.id).Steps[0].StepStatus=='Approved'){
                                    gt.Approver_Comments__c=processInstancesmap.get(gt.id).Steps[0].Comments; 
                                }
                            }
                            
                        }
                    }
                }
            }            
        }
    }
    
    
    
    
    public static void GeneralTaskBeforeUpdate(Map<id,General_Task__c> newMap, Map<id,General_Task__c> oldMap,set<id> nonConformanceIds,List<General_Task__c> generaltasks){                    
         Map<ID, Document_profile__c> Dp = new Map<ID, Document_profile__c>([SELECT Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,ApprovalProcess__c,Approval_Process_Complete__c,Approval_Required__c,Approval_Status__c,Approved_Date__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,Approver__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,Collaboration_Review__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,CurrentApprovalSequenceNumber__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Note_To_Approver__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submitted_Date__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c FROM Document_Profile__c where Id in(select document_profile__c from General_task__c  where recordtype.name in ('EffectivenessReview','CollaborationReview'))]);
    
        List<Non_Conformance__c> ncsupdate=new List<Non_Conformance__c>();        
        String queryFieldNamesNc = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'id,NC_Status__c');   
        if(queryFieldNamesNc != null && queryFieldNamesNc != ''){
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,status__c,RecordTypeId,RecordType.Name,Add_Effectiveness_verificiation__c,Non_Conformance__c');
            string ClosureName='Closure';                                                       //List<General_Task__c> Closures= database.query('Select '+ queryFieldNames +' from General_Task__c where Non_Conformance__c IN:nonConformanceIds AND RecordType.Name=:ClosureName');
            Map<id,General_Task__c> cls=new Map<id,General_Task__c>();                          //closure tasks
            for(General_Task__c clos:generaltasks){
                if(clos.RecordType.Name=='Closure')
                    cls.put(clos.Non_Conformance__c, clos);                
            }
            List<General_Task__c> autoapprovalClsoure=new List<General_Task__c>();
            //List<General_Task__c> Clsupdate=new List<General_Task__c>();     
            
            General_Task__c closure;
            for(General_Task__c gt:newMap.values()){                                            //filtering tasks
                
                
                if(gt.Due_Date__c!=oldMap.get(gt.id).Due_Date__c&&gt.status__c!=''&&gt.status__c!=null){ 
                    gt.Allowed_Days__c=gt.Allowed_Days__c+((oldMap.get(gt.id).Due_Date__c.daysBetween(gt.Due_Date__c)));  
                    system.debug('Due_Date__c   Allowed_Days__c');
                    system.debug(gt.Allowed_Days__c);
                }
                //}
                //=============================================================================================updating allow days end
                if(gt.Document_Profile__c!=null){
                if(Dp.get(gt.Document_Profile__c).isRevise__c==true && gt.Status__c=='Pending Approval' && gt.Document_Status__c=='Revise')//For EffectivenessReview Document Profile
                    {  
                      if(gt.Record_Type_Name__c=='EffectivenessReview')
                      {    
                         
                          gt.Status__c='Closed';
                      }
                    }
            	}
                if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Closure')&&gt.Approval_Required__c=='Yes' &&!gt.Add_Effectiveness_verificiation__c&&oldMap.get(gt.Id).Status__c!='Pending Approval'&&oldMap.get(gt.Id).Status__c!='Open'&&gt.Status__c=='Open'&&oldMap.get(gt.Id).Status__c!='Closed'){  
                    gt.CurrentApprovalSequenceNumber__c=0;
                    autoapprovalClsoure.add(gt);                                                             
                    system.debug('inside autoapprovalClsoure for autoapprovalClsoure'+autoapprovalClsoure);
                }
                system.debug('before loop for ');
            }
            
            if(!autoapprovalClsoure.isEmpty()){
                //submitForApprovalProcess(autoapprovalClsoure,false);     
                GeneralTaskStatusUpdate(newMap.values(),oldMap,generaltasks,autoapprovalClsoure);
            }
            else{
                GeneralTaskStatusUpdate(newMap.values(),oldMap,generaltasks,null);
            }
            
            
        }
        /*
for(General_Task__c gt:newMap.values()){
if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Closure')){
if(gt.New_Due_Date__c==null&&gt.New_Owner__c==null){
if(gt.isLocked__c){
gt.Status__c='Pending Approval';
}
}
}
}*/
    }
    
    public static void GeneralTaskStatusUpdate(List<General_Task__c> gts, Map<id,General_Task__c> oldMap,List<General_Task__c> generaltasks,List<General_Task__c> ClosureAutoApproval){
        
        
        
        
        List<General_Task__c> GenTaskForApprovalComments= new List<General_Task__c>();
        list<General_Task__c> updateStatusFormSecquence=new list<General_Task__c>();
        set<id> Parentidset=new set<id>();                                                              // non conformance for closing nc after closure
        set<id> capaclone=new set<id>();
        list<General_Task__c> getSubmitApproval=new list<General_Task__c>();                        //to submit for sequenciaal approval process
        if(ClosureAutoApproval!=null)
            getSubmitApproval.addAll(ClosureAutoApproval);
        General_Task__c Oldgt;
        
        
        for(General_Task__c gt:gts){
            
            Oldgt=oldMap.get(gt.id);
            if(Oldgt.ChangeFieldApprovalStatus__c=='Pending'){                                  //this is for change Duedate and change Owner
                if(gt.ChangeFieldApprovalStatus__c=='Approve'){
                    if(gt.New_Owner__c!=null){
                        gt.Ownerid=gt.New_Owner__c;
                        gt.New_Owner__c=null;
                        gt.Note_To_Approver_Owner_DueDate__c=null;   
                    }
                    else if(gt.New_Due_Date__c!=null){ 
                        gt.Due_Date__c=gt.New_Due_Date__c;
                        gt.New_Due_Date__c=null;
                    }    
                    gt.ChangeFieldApprovalStatus__c='None';
                    gt.Note_To_Approver_Owner_DueDate__c=null;
                }
                else if(gt.ChangeFieldApprovalStatus__c=='Reject'){
                    gt.New_Due_Date__c=null;
                    gt.New_Owner__c=null;
                    gt.Note_To_Approver_Owner_DueDate__c=null;
                }//added
                else if(gt.ChangeFieldApprovalStatus__c=='Recall'){
                    gt.New_Due_Date__c=null;
                    gt.New_Owner__c=null;
                    gt.Note_To_Approver_Owner_DueDate__c=null;
                }//added
            }
            
            if(OldGT.Status__c=='Pending Approval'&&GT.isLocked__c==false&&OldGT.isLocked__c==true&&(GT.CurrentApprovalSequenceNumber__c==99999||GT.CurrentApprovalSequenceNumber__c==999999)){
                GenTaskForApprovalComments.add(GT);
            }
            if(OldGT.Status__c=='Pending Approval'&&GT.isLocked__c==false&&OldGT.isLocked__c==true&& !(GT.CurrentApprovalSequenceNumber__c==99999||GT.CurrentApprovalSequenceNumber__c==999999)){
                //GT.CurrentApprovalSequenceNumber__c==999999   means   rejected  and 99999 means recalled
                system.debug('in side Pending Approval GT.CurrentApprovalSequenceNumber__c'+getSubmitApproval);
                getSubmitApproval.add(GT);                                                            
                system.debug('in side Pending Approval'+getSubmitApproval);
            }   
            /*
            if(OldGT.Status__c!='Closed'&&GT.Status__c=='Closed'&&GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Closure')){
                system.debug('inside if condition close NC 32');
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','NC_Status__c,NC_Workflow_Status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {   
                    system.debug('inside after if condition close NC 23');
                    Parentidset.add(GT.Non_Conformance__c);              
                }
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','CAPA_Status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {   
                    system.debug('inside after if condition close NC 23');
                    Parentidset.add(GT.CAPA__c);
                    //if(OldGT.CAPA_Effectiveness__c!='Not Effective'&&GT.CAPA_Effectiveness__c=='Not Effective') UPDATE THIS WITH BELOW LINE BY BALU
                    if(GT.Create_New_CAPA__c=='Yes'&&OldGT.Status__c!='Closed'&&GT.Status__c=='Closed')
                        capaclone.add(GT.CAPA__c);
                }
            }*/
        }
        
        GeneralTaskApprovalComments(GenTaskForApprovalComments);
        if(!getSubmitApproval.isEmpty()){
            system.debug('getSubmitApproval'+getSubmitApproval);
            GeneralTaskSubmitForApprovalProcess(getSubmitApproval,true);           // sequential approval Process 
        }
        //Begin - Newly added code for updateNextPhase 
        for(General_Task__c gt:gts){                                    //not redundant loop  checking after  submiting  for approval if it is the last approver  
             Oldgt=oldMap.get(gt.id);//recently added
            system.debug('inside before check OldGT.Status__c'+OldGT.Status__c+' GT.Status__c '+GT.Status__c);
            if((OldGT.Status__c!='Closed'&&GT.Status__c=='Closed')||(OldGT.Status__c=='Open'&&GT.Status__c=='Void')){
                system.debug('inside before updateStatusFormSecquence');
                updateStatusFormSecquence.add(GT);
            } 
            if(OldGT.Status__c!='Closed'&&GT.Status__c=='Closed'&&GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Closure')){
                system.debug('inside if condition close NC');
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Non_Conformance__c','NC_Status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {
                    system.debug('inside after if condition close NC');
                    Parentidset.add(GT.Non_Conformance__c);
                }
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA__c','CAPA_Status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {   
                    system.debug('inside after if condition close capa ');
                    Parentidset.add(GT.CAPA__c);
                    if(GT.CAPA_Effectiveness__c=='Not Effective'&&GT.Create_New_CAPA__c=='Yes'&&OldGT.Status__c!='Closed'&&GT.Status__c=='Closed')
                    capaclone.add(GT.CAPA__c);                    
                } 
                
                //-------v2.1.2--start
                
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management__c','Status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {   
                    system.debug('inside after if condition close capa ');
                    Parentidset.add(GT.Change_Management__c);                    
                }                
                
                //---------v2.1.2-end
            }            
        }
        set<id> NCWorkFlowStatusInReview=new set<id>();
        NCWorkFlowStatusInReview=GeneralTaskUpdateNextPhase(updateStatusFormSecquence,generaltasks,gts);        //there should be a closure check
        //End
         system.debug('inside  chack Parentidset'+Parentidset+'NCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
        if(!Parentidset.isEmpty()||!NCWorkFlowStatusInReview.isEmpty()){
            system.debug('inside  chack Parentidset'+Parentidset+'NCWorkFlowStatusInReview'+NCWorkFlowStatusInReview);
            GeneralTaskUpdateParent(Parentidset,capaclone,NCWorkFlowStatusInReview);//closing NC based on Closure without Approval Last method of before Update
        }
            
    }
    
    public static void GeneralTaskSubmitForApprovalProcess(List<General_Task__c> GTs,Boolean initialSubmitter){
        List<id> approveObjids=new List<id>();
        Map<id,List<General_Sub_Task__c>> genSubTask=new Map<id,List<General_Sub_Task__c>>();
        map<id,id> approveObjidsSub=new map<id,id>();
        id submitter;
        set<id> ncids=new set<id>();            
        list<id> Approvers= new list<id>();
        Set<Id> genIds = (new Map<Id,SObject>(GTs)).keySet();
        Decimal current;
        boolean flag;
        id GeneraTaskid;
        list<Approver__c> genApprovers;
        map<id,List<Approver__c>> genApproversMap=new map<id,List<Approver__c>>();
        list<Approver__c> tempApprovers;
        //=========retriving approvers for assiging next sequence approval process  
        String queryFieldSOfAP = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Sequence_Position__c,General_Task__c,User__c');     
        if(queryFieldSOfAP!=null&&queryFieldSOfAP!=''){
            genApprovers=database.query('Select '+ queryFieldSOfAP +' from Approver__c where General_Task__c IN: genIds');      //fetching approvers related to current general task 
            
            for(General_Task__c GT:GTs){                        //grouping general task and approvers related to them
                tempApprovers=new list<Approver__c>();
                for(Approver__c apprs:genApprovers){
                    if(apprs.General_Task__c==GT.id){
                        tempApprovers.add(apprs);
                    }
                }
                genApproversMap.put(GT.id,tempApprovers);
            }
        }
        
        List<General_Sub_Task__c> tempSubTask;
        String queryFieldSOfdst = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,General_Task__c,Disposition_Type_Status__c,Complete__c,Completed__c,Submit_WithOut_Approval__c,RecordType.Name');
        if(queryFieldSOfdst!=null&&queryFieldSOfdst!=''){            
            for(General_Sub_Task__c sudTsk:database.query('Select '+ queryFieldSOfdst +' from General_Sub_Task__c where General_Task__c IN: genIds')){
                if(genSubTask.containsKey(sudTsk.General_Task__c)){
                    genSubTask.get(sudTsk.General_Task__c).add(sudTsk);
                }
                else{
                    tempSubTask=new List<General_Sub_Task__c>();
                    tempSubTask.add(sudTsk);
                    genSubTask.put(sudTsk.General_Task__c, tempSubTask);
                }
                
            }
        }
        
        
        
        
        //List<General_Sub_Task__c> ActionPlanList=new List<General_Sub_Task__c>();
        for(General_Task__c GT:GTs){
            
            if(GT.CurrentApprovalSequenceNumber__c==null){
                GT.CurrentApprovalSequenceNumber__c=0;
            }
            current=GT.CurrentApprovalSequenceNumber__c;
            flag=false;
            GeneraTaskid=gt.id;                 
            for(Approver__c appr:genApproversMap.get(GeneraTaskid)){                        //to find next approvers
                if(appr.Sequence_Position__c>GT.CurrentApprovalSequenceNumber__c){ 
                    if(flag==false){
                        current=appr.Sequence_Position__c;
                    }
                    if(current>appr.Sequence_Position__c){
                        current=appr.Sequence_Position__c;
                        Approvers.clear();
                    }
                    else if(current==appr.Sequence_Position__c){                        
                        Approvers.add(appr.User__c);
                    }
                    flag=true;
                }                                            
            }
            
            if(current==GT.CurrentApprovalSequenceNumber__c){                               //if no next higher approver
                current=current+1000; 
            }
            integer len=Approvers.size();
            if(flag){
                system.debug(flag+'flag after Sequence_Position__c current'+current);
                GT.CurrentApprovalSequenceNumber__c=current;
                integer i=1;    
                GT.Initial_Submitter__c=GT.Ownerid;
                GT.Approver__c=Approvers[len-1];i++;                                                    
                GT.Approver_1__c=Approvers[((len-i>0)?len-i:0)];i++;                                       
                GT.Approver_2__c=Approvers[((len-i)>0)?len-i:0];i++;                                             
                GT.Approver_3__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_4__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_5__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_6__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_7__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_8__c=Approvers[((len-i)>0)?len-i:0];i++;
                GT.Approver_9__c=Approvers[((len-i)>0)?len-i:0]; 
                
                if(initialSubmitter){
                    submitter=GT.Initial_Submitter__c;                                                      
                }
                else{
                    submitter=GT.Ownerid;
                }
                approveObjidsSub.put(GT.id, GT.Initial_Submitter__c);
                approveObjids.add(GT.id);                                             
                // submitForApproval(GT.id,submitter);
            }
            
            if(Approvers.isEmpty()){
                system.debug('inside Approver is Empty');
                GT.Approval_Process_Complete__c=true;
                GT.status__c='Closed';
                if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Disposition')){
                    for(General_Sub_Task__c ds:genSubTask.get(GT.id)){
                        if(ds.Disposition_Type_Status__c=='Pending'&&ds.RecordType.Name=='Disposition Section'){
                            GT.status__c='Disposition Pending Completion';                                
                        } 
                    }
                //-----v2.1.1 START----------      
                }else if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('DocumentChange')){
                    GT.status__c='Pending Action Completion';
                }//-----v2.1.1 END-----------
                else{
                    if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Implementation')){
                        for(General_Sub_Task__c ds:genSubTask.get(GT.id)){
                            if(ds.Complete__c!='Yes'&&ds.RecordType.Name=='Action Plan'){
                                GT.status__c='Pending ActionPlan';
                                //ds.Submit_WithOut_Approval__c='Yes';
                                
                                //ActionPlanList.add(ds);
                                System.debug('ds.Submit_WithOut_Approval__c------------------------------->'+ds.Submit_WithOut_Approval__c+'GT.status__c------>'+GT.status__c);
                            } 
                        }  
                    }                    
                    else{
                        if(GeneralTaskRt_map.get(gt.recordTypeID).getName().containsIgnoreCase('Closure')){
                            //    ncids.add(GT.Non_Conformance__c);                                    
                        }                                    
                    }
                }
                
            }
            Approvers.clear();
            
        }
        //upsert ActionPlanList;
        //
        if(!approveObjids.isEmpty())
            GeneralTaskSubmitForApproval(approveObjids,approveObjidsSub);
        //closeNC(ncids);//closing NC based on Closure with after Approval
    }
    
    //=========================================================================================================================
    public static List<NC_History__c> GeneralTaskhisList;
    public static List<CAPA_History__c> GeneralTaskchisList;
    //v2.1.3 start
    public static List<Change_Management_History__c> GeneralTaskcmhisList;
    public static List<Document_Profile_History__c> GeneralTaskdphisList;
    //v2.1.3 end
    
    public static void GeneralTask_AfterTrigger(Map<id,General_Task__c> newMap,Map<id,General_Task__c> oldMap,boolean isInsert,boolean IsUpdate){                                               
        //=================================================================-
        GeneralTaskrt_Map = General_Task__c.sObjectType.getDescribe().getRecordTypeInfosById();
        //=================================================================
        //
        //
        //----------------------code written by Ram----------------------------------------                
        List<General_Task__c> genTask = newMap.values();
        System.debug('genTask values '+genTask);
        Set<id> genTaskIds = new Set<id>();
        if(genTask != null){
            System.debug('genTask in generalTask trigger '+genTask);
            for(General_Task__c gen:genTask){
                if(gen.Approval_Process_Complete__c==true && gen.status__c=='Disposition Pending Completion'){
                    genTaskIds.add(gen.Id);
                }
            }
            System.debug('genTaskIds '+genTaskIds);
            if(!genTaskIds.isEmpty()){
                GeneralTaskUpdateDispositionSection(genTaskIds);
            }
        }
        
        //-----------------------code written by Sarath----------------------------------
        if(genTask != null){
           // genTask.clear(); 
            System.debug('genTask in generalTask trigger '+genTask);
            for(General_Task__c gen:genTask){
                if(gen.Approval_Process_Complete__c==true && gen.status__c=='Pending ActionPlan'){
                    genTaskIds.add(gen.Id);
                }
            }
            System.debug('genTaskIds '+genTaskIds);
            if(!genTaskIds.isEmpty()){
                GeneralTaskUpdateActionPlanSection(genTaskIds);
            }    
        }                 
        //
        //
        //=================================================================
        //========================================================update/insert
        GeneralTaskhisList=new List<NC_History__c>();
        GeneralTaskchisList=new List<CAPA_History__c>();
        //v2.1.3 start
        GeneralTaskcmhisList=new List<Change_Management_History__c>();
        GeneralTaskdphisList=new List<Document_Profile_History__c>();
        //v2.1.3 end
        Map<id,General_Task__c> afterupdateMap=new Map<id,General_Task__c>();
        //========================================================update/insert
        system.debug('oldMap');
        if(oldMap==null){
            oldMap=new Map<id,General_Task__c>(); 
        }  
        Map<id,General_Task__c> afterinsertMap=new Map<id,General_Task__c>();
        for(General_Task__c gt:newMap.values()){
            if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                afterinsertMap.put(gt.id,gt) ; 
            }
            else{
                afterupdateMap.put(gt.id,gt) ; 
            }
        }
        GeneralTaskhisList=new List<NC_History__c>();
        GeneralTaskchisList=new List<CAPA_History__c>();
        //v2.1.3 start
        GeneralTaskcmhisList=new List<Change_Management_History__c>();
        GeneralTaskdphisList=new List<Document_Profile_History__c>();
        //v2.1.3 end
        GeneralTaskAfterinsert(afterinsertMap);
        GeneralTaskFieldHistoryTracking(afterupdateMap,oldmap);                
        insert GeneralTaskhisList;
        insert GeneralTaskchisList;
        //v2.1.3 start
        insert GeneralTaskcmhisList;
        insert GeneralTaskdphisList;
        //v2.1.3 end
        //
        //
        Map<ID, Document_profile__c> Dp = new Map<ID, Document_profile__c>([SELECT Action_Status__c,Age__c,Allowed_Days__c,Applicable_Regulations__c,Authorised_Entity_Groups_Name__c,Authorised_Entity_Groups__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Users__c,Automatically_Expire_Previous_Revision__c,Auto_Expire__c,Business_Unit__c,Categories__c,CD_Customer_Name__c,CD_Customer__c,Change_Management_Name__c,Change_Management__c,Closed_Date__c,ContentDocumentId__c,ContentVersionId__c,CreatedById,CreatedDate,Created_Date__c,Current_Rev__c,Date_of_Purge__c,Department_Name__c,Department__c,Description__c,Document_Name__c,Document_Owner__c,Document_Profile_Auto_Number__c,Document_Specific_Changes__c,Document_Status__c,Document_Type_Name__c,Document_Type__c,Due_Date__c,Effectiveness_Review_Date__c,Effectiveness_Review_In_Advance__c,Effective_Date__c,Enable_Security__c,Expiration_Date__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,Id,Impacted_Sites__c,Initial_Submitter__c,Initiating_Site_Name__c,Initiating_Site__c,IsDeleted,isLocked__c,isRevise__c,isTempRevise__c,isTemp__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Left_vertically__c,Name,Name__c,New_Expiration_Date__c,New_Owner__c,New_Rev__c,Numbering_Scheme__c,OwnerId,Owner_Name__c,PreRelease_Duration_Date__c,Pre_Release_Duration_Date__c,Primary_File_Location__c,Primary_File_Name__c,Process_Name__c,Process__c,Product_Name__c,Product__c,Protected_Draft__c,Reason_for_Change__c,Reason__c,Relation__c,Release_Date__c,Required_Change__c,Retention_Duration__c,Right_vertically__c,SecondaryContentDocumentId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Secondary_Format__c,Sequence__c,Start_Effectiveness_Review_In_Advance__c,Status__c,Submit__c,Supersede_Previous_Revision__c,SystemModstamp,TempStop__c,Title__c,Type__c,UD_Date__c,UD_Region__c,UD_RichText__c,UD_Sites__c,UD_Text__c,Valid_Duration__c,Viewonly_Entity_Groups_Name__c,Viewonly_Entity_Groups__c,Viewonly_Entity_Users_Name__c,Viewonly_Entity_Users__c,Watermark_Text__c FROM Document_Profile__c where Id in(select document_profile__c from General_task__c  where recordtype.name in('EffectivenessReview','CollaborationReview'))]);
        Map<ID,ContentDocument > conDoc=new Map<ID,ContentDocument>([SELECT ArchivedById,ArchivedDate,ContentModifiedDate,ContentSize,CreatedById,CreatedDate,Description,FileExtension,FileType,Id,IsArchived,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LatestPublishedVersionId,OwnerId,PublishStatus,Title FROM ContentDocument]);
        List<Document_profile__c> DPlist=new List<Document_profile__c> ();
        if(genTask != null){
            System.debug('genTask in generalTask trigger__srilakshmi '+genTask);
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            list<General_Task__c> gt=new list<General_Task__c>();
            for(General_Task__c gen:genTask){
                
                system.debug(gen.recordtype.name+'gen.recordtype.name'+GeneralTaskRt_map.get(gen.recordTypeID).getName());
                if(GeneralTaskRt_map.get(gen.recordTypeID).getName()=='EffectivenessReview')
                {   
                    
                    Set<String> contentVersionIdSet=new Set<String>();
                    if(gen.Approval_Required__c=='yes' && gen.status__c=='closed'){
                        Document_profile__c dps=Dp.get(gen.Document_profile__c);
                            //[select name,status__c,Current_Rev__c,Document_Name__c,Document_Type__c from document_profile__c where id=:gen.Document_profile__c];
                        system.debug(gen.Document_profile__c+'gen.Document_profile__c');
                        if(gen.Document_status__c=='Keep Status Current')
                        {   
                            
                            dps.status__c='Current';
                            dps.expiration_date__c=gen.new_expiration_date__c;
                            
                            
                        }
                        else if(gen.Document_status__c=='Expire')
                        {
                            dps.status__c='Expired';
                            dps.expiration_date__c=gen.new_expiration_date__c;
                            system.debug('*****');
                        }
                        else if(gen.Document_status__c=='Revise')
                        {   
                            if(dps.isRevise__c==false)
                           {
                            dps.status__c='Current';
                            
                            Document_profile__c clone_dp=dps.clone(false,true,false,false);
                            dps.isRevise__c=true;
                            clone_dp.status__c='Draft';
                            clone_dp.Current_Rev__c=DocumentProfileControllerExt.getRevisionvalue(string.valueof(dps.Current_Rev__c));
                            contentVersionIdSet.add(dps.ContentVersionId__c);
                            contentVersionIdSet.add(dps.SecondaryContentVersionId__c);
                            Map<String,List<String>> revisedContentVersions = Component_Handler.reviseContentDocument(contentVersionIdSet);
                            List<String> contentVersions=null;
                            for(String orginalContentVersionId:revisedContentVersions.keySet()){
                            contentVersions=revisedContentVersions.get(orginalContentVersionId);
                            if(orginalContentVersionId==dps.ContentVersionId__c){
                                clone_dp.ContentVersionId__c=contentVersions[0];
                                clone_dp.ContentDocumentId__c=contentVersions[1];
                            }
                            else if(orginalContentVersionId==dps.SecondaryContentVersionId__c){
                                clone_dp.SecondaryContentVersionId__c=contentVersions[0];
                                clone_dp.SecondaryContentDocumentId__c=contentVersions[1];
                            }
                        }
                            insert clone_dp;
                            system.debug(clone_dp.id+'clone_dp');
                             }
                             else
                            {
                                //gen.Status__c='Closed';
                                
                                //gt=gt.add(gen);
                                //gt[0].status__c='Void';
                            }
                             
                        }
                       
                        DPlist.add(dps);
                        
                        update dps;
                    }
                    
                    
                }
                else if(GeneralTaskRt_map.get(gen.recordTypeID).getName()=='CollaborationReview' && gen.status__c=='Pending Approval' &&  con_flag!=true)
                {
                    
                   /* FeedItem post = new FeedItem();
                    post.ParentId = gen.id; 
                    post.Body = gen.Review_description__c;
                    insert post;*/
                    system.debug('Chatter');
                   set<string> users=new set<string> ();
                    users.add(gen.Approver__c);
                    users.add(gen.Approver_1__c);users.add(gen.Approver_2__c);users.add(gen.Approver_3__c);users.add(gen.Approver_4__c);users.add(gen.Approver_5__c);
                    users.add(gen.Approver_6__c);users.add(gen.Approver_7__c);users.add(gen.Approver_8__c);users.add(gen.Approver_9__c);
                    if(gen.Approver__c!=null ||gen.Approver_1__c!=null||gen.Approver_2__c!=null||gen.Approver_3__c!=null||gen.Approver_4__c!=null || gen.Approver_5__c!=null  ||gen.Approver_6__c!=null ||gen.Approver_7__c!=null ||gen.Approver_8__c!=null ||gen.Approver_9__c!=null)
                    {
                     system.debug(users.size()+'users.size()$$');
                     system.debug(users+'Userssssssssss');
                     
                     ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                          system.debug('********************'+Dp.get(gen.Document_profile__c));

                     ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                     ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                     messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                     textSegmentInput.text = 'Document Number :'+Dp.get(gen.Document_profile__c).Name+'\n'+'Title :'+gen.Collaboration_Title__c+'\n'+'Collaboration Review initiated  '+'\n'+'Description :'+gen.review_description__c;
                    system.debug('********************'+Dp.get(gen.Document_profile__c).Name);
                     messageBodyInput.messageSegments.add(textSegmentInput);
                     for(string s:users)
                     {
                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.id=s;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                     
                     }

                 
            
                        feedItemInput.body = messageBodyInput;
                        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        feedItemInput.subjectId =gen.id;
                        System.debug(feedItemInput+'feedItemInput@@@@@@@@@');
                        ConnectApi.FeedElement feedElement =  ConnectApi.ChatterFeeds.postFeedElement(null,feedItemInput, null);
                         con_flag=true;
                        System.debug(feedItemInput+'feedElement**************'+con_flag);
                        list<General_Task__Feed> fi=[select id from General_Task__Feed where ParentId=:gen.id];
                        if(fi.size()>1)
                        {
                            delete fi[0];
                        }
                    }
                    
               } 
                else if(GeneralTaskRt_map.get(gen.recordTypeID).getName()=='CollaborationReview' && gen.status__c=='Open')
                {
                   list<General_Task__Feed> fi=[select id from General_Task__Feed where ParentId=:gen.id];
                   system.debug(fi+'UUUUUU');
                delete fi;
                }
                
           }
            
            Update DPlist;
            
        }
        

    }
    
    //------------------method written by Ram--------------------------------------------------------------
    
    @future
    public static void GeneralTaskUpdateDispositionSection(Set<Id> genTaskIds){
        System.debug('Inside updateDispositionSection  genTaskIds   '+genTaskIds);
        List<General_Sub_Task__c> dispSec;
        List<General_Sub_Task__c> dispSecList = new List<General_Sub_Task__c>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Approval_Completed__c,Disposition_Type_Status__c,General_Task__c');
        if(queryFieldNames != null && queryFieldNames != ''){
            dispSec = database.query('SELECT '+ queryFieldNames +' FROM General_Sub_Task__c WHERE General_Task__c IN :genTaskIds');
            for(General_Sub_Task__c disp:dispSec){
                disp.Approval_Completed__c = 'Yes';
                dispSecList.add(disp);
            }
            System.debug('dispSecList------------------------------------> '+dispSecList);
            upsert dispSecList;
        }
        
    }
    
    //--------------------method written by Sarath---------------------------------------------------------
    
    @future
    public static void GeneralTaskUpdateActionPlanSection(Set<Id> genTaskIds){
        System.debug('Inside updateActionPlanSection  genTaskIds   '+genTaskIds);
        List<General_Sub_Task__c> apSec;
        List<General_Sub_Task__c> apSecList = new List<General_Sub_Task__c>();
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Action_Plan_Status__c ,Submit_WithOut_Approval__c,General_Task__c');
        
        if(queryFieldNames != null && queryFieldNames != ''){
            apSec = database.query('SELECT '+ queryFieldNames +' FROM General_Sub_Task__c WHERE General_Task__c IN :genTaskIds');
            for(General_Sub_Task__c ap:apSec){
                ap.Submit_WithOut_Approval__c = 'No';
                apSecList.add(ap);  
            }
            System.debug('apSecList------------------------------------> '+apSecList);
            upsert apSecList;
        }   
        
    }
    
    
    //=========================================================================================   
    public static void GeneralTaskFieldHistoryTracking(Map<id,General_Task__c> newMap,Map<id,General_Task__c> oldMap){
        //v2.1.3 start
        Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        String NSPrefix ='';
        if( dev_settings.Namespace_Prefix__c!=''&&dev_settings.Namespace_Prefix__c!=null){
            NSPrefix=+'__';
        }
        //v2.1.3 end
        Map<id,User> User=new Map<id,User>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'id,Name');            
        if(queryFieldNames != null && queryFieldNames != '')
        {
            String qry='select ' + queryFieldNames + ' FROM user';
            LIST<USER> ulist=database.query (qry);
            User.putAll(ulist);                
        }            
        Map<String, Schema.SObjectField> General_Task_Lable =Schema.SObjectType.General_Task__c.fields.getMap();
        list<General_Task__c> ncs=new list<General_Task__c>();   
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        Change_Management_History__c cmhis;
        Document_Profile_History__c dphis;
        //v2.1.3 end
        
        string fieldApiname;
        
        id temp;
        string tempstore;
        Boolean flag=true;
        set<id> Objectids=new set<id>(newMap.keySet());
        dateMap=new map<integer,string>();
        dateMap.put(1,'Jan');
        dateMap.put(2,'Feb');
        dateMap.put(3,'Mar');
        dateMap.put(4,'Apr');
        dateMap.put(5,'May');
        dateMap.put(6,'Jun');
        dateMap.put(7,'July');
        dateMap.put(8,'Aug');
        dateMap.put(9,'Sep');
        dateMap.put(10,'Oct');
        dateMap.put(11,'Nov');
        dateMap.put(12,'Dec');
        date mydate;
        
        
        final List<Schema.FieldSetMember> trackedGTFields =
            SObjectType.general_Task__C.FieldSets.generalTaskfields.getFields();
        Set<string> gtfieldsetNames=new Set<string>(); 
        for(Schema.FieldSetMember feildname:trackedGTFields){
            gtfieldsetNames.add(feildname.getFieldPath());
        }              
        
        
        
        for(General_Task__c gt:newMap.values()){         
            final General_Task__c oldNc = oldmap.get(gt.Id);           
            for(Schema.SObjectField feildname:Schema.SObjectType.General_Task__c.fields.getMap().values()){
                flag=true;
                fieldApiname=string.valueOf(feildname);
                if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&gtfieldsetNames.contains(fieldApiname)){
                    system.debug('gtfieldsetNames.contains(fieldApiname)'+gtfieldsetNames.contains(fieldApiname));
                    if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                        system.debug('gt.get(fieldApiname)   '+gt.get(fieldApiname));
                        if(gt.Non_Conformance__c!=null){
                            his=new NC_History__c();
                            his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            his.FieldApiName__c=fieldApiname;
                            
                            if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                system.debug('string.valueOf(gt.get(fieldApiname)'+string.valueOf(gt.get(fieldApiname))+'gt.get(fieldApiname)'+gt.get(fieldApiname)+'fieldApiname'+fieldApiname);
                                temp=string.valueOf(gt.get(fieldApiname));
                                system.debug('string. inside before if'+temp);
                                if(temp==null){
                                    system.debug('string. inside inside before if'+temp);
                                    temp=string.valueOf(oldNc.get(fieldApiname));                                       
                                }
                                system.debug('string. inside after if');
                                if(temp.getSObjectType().getDescribe().getName()=='User'){
                                    system.debug('string. inside after if');
                                    tempstore=string.valueOf(oldNc.get(fieldApiname));
                                    if(!(tempstore==null)){
                                        his.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;                                            
                                    }
                                    //his.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                    tempstore=string.valueOf(gt.get(fieldApiname));
                                    if(!(tempstore==null)){
                                        his.NewValue__c=User.get(string.valueOf(gt.get(fieldApiname))).Name;                                              
                                    }
                                    if(fieldApiname.startsWith('Approve')){
                                        his.Non_Conformance__c=gt.non_conformance__c;
                                        his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel()+'hidden';
                                        his.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName()+'hidden';                                               
                                    }else{
                                        his.Non_Conformance__c=gt.non_conformance__c;
                                        his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                        his.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();                                            
                                    }
                                    
                                    his.object__c='General_Task__c';
                                    if(gt.Status__c==''){
                                        his.object__c='Non_Conformance__c';
                                        his.Parent__c='Resolution';                                            
                                    }
                                    GeneralTaskhisList.add(his);    
                                    flag=false;
                                }
                            }
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                his=new NC_History__c();
                                if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                    if(oldNc.get(fieldApiname)!=null){
                                        mydate=date.valueOf(oldNc.get(fieldApiname));
                                        his.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                    }                                            
                                    if(gt.get(fieldApiname)!=null){
                                        mydate=date.valueOf(gt.get(fieldApiname));
                                        his.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                    }
                                    
                                }else{
                                    his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                    his.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                }                                    
                                his.Non_Conformance__c=gt.non_conformance__c;
                                his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                his.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                                his.object__c='General_Task__c';
                                if(gt.Status__c==''){
                                    his.object__c='Non_Conformance__c';
                                    his.Parent__c='Resolution';                                            
                                }                                    
                                GeneralTaskhisList.add(his);
                            }
                            
                        }else 
                            if(gt.CAPA__c!=null){
                                chis=new CAPA_History__c();
                                chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                chis.FieldApiName__c=fieldApiname;
                                
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                    system.debug('string.valueOf(gt.get(fieldApiname)'+string.valueOf(gt.get(fieldApiname))+'gt.get(fieldApiname)'+gt.get(fieldApiname)+'fieldApiname'+fieldApiname);
                                    temp=string.valueOf(gt.get(fieldApiname));
                                    if(temp==null){
                                        temp=string.valueOf(oldNc.get(fieldApiname));                                       
                                    }
                                    if(temp.getSObjectType().getDescribe().getName()=='User'){
                                        tempstore=string.valueOf(oldNc.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            chis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;                                            
                                        }
                                        //chis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(gt.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            chis.NewValue__c=User.get(string.valueOf(gt.get(fieldApiname))).Name;                                              
                                        }
                                        if(fieldApiname.startsWith('Approve')){
                                            chis.CAPA__c=gt.CAPA__c;
                                            chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel()+'hidden';
                                            chis.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName()+'hidden';                                               
                                        }else{
                                            chis.CAPA__c=gt.CAPA__c;
                                            chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                            chis.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();                                            
                                        }
                                        
                                        chis.object__c='General_Task__c';
                                        if(gt.Status__c==''){
                                            chis.object__c='CAPA__c';
                                            chis.Parent__c='Resolution';                                            
                                        }
                                        GeneralTaskchisList.add(chis);    
                                        flag=false;
                                    }
                                }
                                if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                    chis=new CAPA_History__c();
                                    if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                        if(oldNc.get(fieldApiname)!=null){
                                            mydate=date.valueOf(oldNc.get(fieldApiname));
                                            chis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                        }                                            
                                        if(gt.get(fieldApiname)!=null){
                                            mydate=date.valueOf(gt.get(fieldApiname));
                                            chis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                        }
                                        
                                    }else{
                                        chis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                        chis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                    }                                    
                                    chis.CAPA__c=gt.CAPA__c;
                                    chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                    chis.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                                    chis.object__c='General_Task__c';
                                    if(gt.Status__c==''){
                                        chis.object__c='CAPA__c';
                                        chis.Parent__c='Resolution';                                            
                                    }                                    
                                    GeneralTaskchisList.add(chis);
                                    
                                    
                                }                                                   
                            }  
                        //v2.1.3 start
                            /////////////////////////Change_Management__c
                          else 
                            if(gt.Change_Management__c!=null){
                                cmhis=new Change_Management_History__c();
                                cmhis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                cmhis.FieldApiName__c=fieldApiname;
                                
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                    system.debug('string.valueOf(gt.get(fieldApiname)'+string.valueOf(gt.get(fieldApiname))+'gt.get(fieldApiname)'+gt.get(fieldApiname)+'fieldApiname'+fieldApiname);
                                    temp=string.valueOf(gt.get(fieldApiname));
                                    if(temp==null){
                                        temp=string.valueOf(oldNc.get(fieldApiname));                                       
                                    }
                                    if(temp.getSObjectType().getDescribe().getName()=='User'){
                                        tempstore=string.valueOf(oldNc.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            cmhis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;                                            
                                        }
                                        //cmhis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(gt.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            cmhis.NewValue__c=User.get(string.valueOf(gt.get(fieldApiname))).Name;                                              
                                        }
                                        if(fieldApiname.startsWith('Approve')){
                                            cmhis.Parent__c=gt.Change_Management__c;
                                            cmhis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel()+'hidden';
                                            cmhis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName()+'hidden';                                               
                                        }else{
                                            cmhis.Parent__c=gt.Change_Management__c;
                                            cmhis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                            cmhis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();                                           
                                        }
                                        
                                        cmhis.object__c='General_Task__c';
                                        if(gt.Status__c==''){
                                            cmhis.object__c='Change_Management__c';
                                            cmhis.Sub_Parent__c='Resolution';                                            
                                        }
                                        GeneralTaskcmhisList.add(cmhis);    
                                        flag=false;
                                    }
                                }
                                if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                    cmhis=new Change_Management_History__c();
                                    if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                        if(oldNc.get(fieldApiname)!=null){
                                            mydate=date.valueOf(oldNc.get(fieldApiname));
                                            cmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                        }                                            
                                        if(gt.get(fieldApiname)!=null){
                                            mydate=date.valueOf(gt.get(fieldApiname));
                                            cmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                        }
                                        
                                    }else{
                                        cmhis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                        cmhis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                    }                                    
                                    cmhis.Parent__c=gt.Change_Management__c;
                                    cmhis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                    cmhis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                                    cmhis.object__c='General_Task__c';
                                    if(gt.Status__c==''){
                                        cmhis.object__c='Change_Management__c';
                                        cmhis.Sub_Parent__c='Resolution';                                            
                                    }                                    
                                    GeneralTaskcmhisList.add(cmhis);
                                    
                                    
                                }                                                   
                            }  
                        ///////////////////Change_Management__c
                        /////////////////////////Document Profile
                          else 
                            if(gt.Document_Profile__c!=null){
                                dphis=new Document_Profile_History__c();
                                dphis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                dphis.FieldApiName__c=fieldApiname;
                                
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                    system.debug('string.valueOf(gt.get(fieldApiname)'+string.valueOf(gt.get(fieldApiname))+'gt.get(fieldApiname)'+gt.get(fieldApiname)+'fieldApiname'+fieldApiname);
                                    temp=string.valueOf(gt.get(fieldApiname));
                                    if(temp==null){
                                        temp=string.valueOf(oldNc.get(fieldApiname));                                       
                                    }
                                    if(temp.getSObjectType().getDescribe().getName()=='User'){
                                        tempstore=string.valueOf(oldNc.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            dphis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;                                            
                                        }
                                        //dphis.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(gt.get(fieldApiname));
                                        if(!(tempstore==null)){
                                            dphis.NewValue__c=User.get(string.valueOf(gt.get(fieldApiname))).Name;                                              
                                        }
                                        if(fieldApiname.startsWith('Approve')){
                                            dphis.Parent__c=gt.Document_Profile__c;
                                            dphis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel()+'hidden';
                                            dphis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName()+'hidden';                                               
                                        }else{
                                            dphis.Parent__c=gt.Document_Profile__c;
                                            dphis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                            dphis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();                                            
                                        }
                                        
                                        dphis.object__c='General_Task__c';
                                        if(gt.Status__c==''){
                                            dphis.object__c='Document_Profile__c';
                                            dphis.Sub_Parent__c='Resolution';                                            
                                        }
                                        GeneralTaskdphisList.add(dphis);    
                                        flag=false;
                                    }
                                }
                                if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                    dphis=new Document_Profile_History__c();
                                    if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                        if(oldNc.get(fieldApiname)!=null){
                                            mydate=date.valueOf(oldNc.get(fieldApiname));
                                            dphis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                        }                                            
                                        if(gt.get(fieldApiname)!=null){
                                            mydate=date.valueOf(gt.get(fieldApiname));
                                            dphis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                        }
                                        
                                    }else{
                                        dphis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                        dphis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                    }                                    
                                    dphis.Parent__c=gt.Document_Profile__c;
                                    dphis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                    dphis.Sub_Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                                    dphis.object__c='General_Task__c';
                                    if(gt.Status__c==''){
                                        dphis.object__c='Document_Profile__c';
                                        dphis.Sub_Parent__c='Resolution';                                            
                                    }                                    
                                    GeneralTaskdphisList.add(dphis);
                                    
                                    
                                }                                                   
                            } 
                        ///////////////////Document Profile
                            
                            //v2.1.3 end 
                    }
                }
                
            }          
            //==============================================================For approval history start
            /*  
if(gt.get('isLocked__c')==true){
system.debug('outside processInstances if'+ProcessInstances);
NC_History__c aphis=new NC_History__c();
aphis.object__c='ProcessInstance';
aphis.Parent__c='General_task';
//if(gt.Status__c!=oldgt.get('Status__c'))
aphis.FieldName__c=(gt.Status__c=='Pending Approval')?'Task Approval':( gt.New_Owner__c!=null)?'Change Owner Approval':'Change DueDate Approval';
//aphis.FieldName__c='next step';
aphis.Non_Conformance__c=gt.Non_conformance__c;
aphis.FieldApiName__c=ProcessInstancesmap.get(gt.id).id;
aphis.NewValue__c='ProcessInstance';
aphis.OldValue__c=gt.Status__c;
system.debug('ProcessInstances history'+aphis);
hisList.add(aphis);

}
*/
            
            //==============================================================For approval history end
        }  
        
    }
    
    public static void GeneralTaskAfterinsert(Map<id,General_Task__c> gts){   
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        Change_Management_History__c cmhis;
        Document_Profile_History__c dphis;
        //v2.1.3 end
        map<id,General_Task__c> insertOldMap=new map<id,General_Task__c>();
        for(General_Task__c gt:gts.values()){
            if(gt.Non_Conformance__c!=null){
                insertOldMap.put(gt.id,new General_Task__c());
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isCreated__c=true; 
                his.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                his.object__c='Non_Conformance__c';
                his.Parent__c='Resolution';
                //his.object__c='General_Task__c';
                //his.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();            
                GeneralTaskhisList.add(his);
            }else 
             //v2.1.3 start
                if(gt.CAPA__c!=null){
                    insertOldMap.put(gt.id,new General_Task__c());
                    chis=new CAPA_History__c(); 
                    chis.CAPA__c=gt.CAPA__c;
                    chis.isCreated__c=true; 
                    chis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                    chis.object__c='CAPA__c';
                    chis.Parent__c='Resolution';
                    GeneralTaskchisList.add(chis);
                }else
                    if(gt.Change_Management__c!=null){
                        insertOldMap.put(gt.id,new General_Task__c());
                        cmhis=new Change_Management_History__c(); 
                        cmhis.Parent__c=gt.Change_Management__c;
                        cmhis.isCreated__c=true; 
                        cmhis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                        cmhis.object__c='Change_Management__c';
                        cmhis.Sub_Parent__c='Resolution';
                        GeneralTaskcmhisList.add(cmhis);
                    }else
                    if(gt.Document_Profile__c!=null){
                        insertOldMap.put(gt.id,new General_Task__c());
                        dphis=new Document_Profile_History__c(); 
                        dphis.Parent__c=gt.Document_Profile__c;
                        dphis.isCreated__c=true; 
                        dphis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                        dphis.object__c='Document_Profile__c';
                        dphis.Sub_Parent__c='DocumentDetails';
                        GeneralTaskdphisList.add(dphis);
                    }
             //v2.1.3 end    
        }
        GeneralTaskFieldHistoryTracking(gts,insertOldMap);  
        for(NC_History__c nch:GeneralTaskhisList){
            nch.isCreated__c=true;
        }
        for(CAPA_History__c capah:GeneralTaskchisList){
            capah.isCreated__c=true;
        }
        //v2.1.3 start
        for(Change_Management_History__c cmh:GeneralTaskcmhisList){
            cmh.isCreated__c=true;
        }
        for(Document_Profile_History__c dph:GeneralTaskdphisList){
            dph.isCreated__c=true;
        }
        //v2.1.3 end
        
    }
    
    public static void GeneralTask_Afterdelete(list<General_Task__c> gts){
        GeneralTaskrt_Map  = General_Task__c.sObjectType.getDescribe().getRecordTypeInfosById();
        List<NC_History__c> hisdelList=new List<NC_History__c>();     
        List<CAPA_History__c> chisdelList = new List<CAPA_History__c>();
        //v2.1.3 start
        List<Change_Management_History__c> cmhisdelList = new List<Change_Management_History__c>();
        List<Document_profile_History__c> dphisdelList = new List<Document_profile_History__c>();
        ////v2.1.3 end
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        Change_Management_History__c cmhis;
        Document_profile_History__c dphis;
        //v2.1.3 end
        for(General_Task__c gt:gts){
            if(gt.Non_Conformance__c!=null){
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isdeleted__c=true; 
                his.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                his.object__c='Non_Conformance__c';
                his.Parent__c='Resolution';
                //his.object__c='General_Task__c';
                //his.Parent__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                hisdelList.add(his);
            }else if(gt.CAPA__c!=''&&gt.CAPA__c!=null){
                system.debug('inside after trigger  afterdelete'+gt.CAPA__c);
                chis=new CAPA_History__c(); 
                chis.CAPA__c=gt.CAPA__c;
                chis.isdeleted__c=true; 
                chis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                chis.object__c='CAPA__c';
                chis.Parent__c='Resolution';
                chisdelList.add(chis);
                
            }
            //v2.1.3 start
            else if(gt.Change_Management__c!=''&&gt.Change_Management__c!=null){
                system.debug('inside after trigger  afterdelete'+gt.Change_Management__c);
                cmhis=new Change_Management_History__c(); 
                cmhis.Parent__c=gt.Change_Management__c;
                cmhis.isdeleted__c=true; 
                cmhis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                cmhis.object__c='Change_Management__c';
                cmhis.Sub_Parent__c='Resolution';
                cmhisdelList.add(cmhis);
            }
            else if(gt.Document_profile__c!=''&&gt.Document_profile__c!=null){
                system.debug('inside after trigger  afterdelete'+gt.Document_profile__c);
                dphis=new Document_profile_History__c(); 
                dphis.Parent__c=gt.Document_profile__c;
                dphis.isdeleted__c=true; 
                dphis.FieldName__c=GeneralTaskRt_map.get(gt.recordTypeID).getName();
                dphis.object__c='Document_profile__c';
                dphis.Sub_Parent__c='DocumentDetails';
                dphisdelList.add(dphis);
            }
            //v2.1.3 end
        }
        if(!hisdelList.isEmpty())
            insert hisdelList;     
        if(!chisdelList.isEmpty())
            insert chisdelList;  
        //v2.1.3 start
        if(!cmhisdelList.isEmpty())
            insert cmhisdelList;  
        if(!dphisdelList.isEmpty())
            insert dphisdelList;
        //v2.1.3 start          
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // general Task Trigger Handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // general sub task Trigger handler start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static Map<ID,Schema.RecordTypeInfo> GeneralSubTaskrt_Map; 
    
    
    public static void GeneralSubTask_BeforeTrigger(List<General_Sub_Task__c> ChGenTasks){
        
        for(General_Sub_Task__c ChGenTask:ChGenTasks){
            if(ChGenTask.Assigned_User__c!=null){
                ChGenTask.Ownerid=ChGenTask.Assigned_User__c;    
            }
            else if(ChGenTask.Completed_By__c!=null){
                ChGenTask.Ownerid=ChGenTask.Completed_By__c;  
            }
            
        }
    }
    public static void GeneralSubTask_AfterTrigger(Map<id,General_Sub_Task__c> newMap,Map<id,General_Sub_Task__c> oldMap){
        system.debug('inside after trigger '+newMap);
        GeneralSubTaskrt_Map = General_Sub_Task__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        for(General_Sub_Task__c st:newMap.values()){
            if(oldMap!=null){
                if(!oldMap.containsKey(st.id)){
                    oldMap.put(st.id,new General_Sub_Task__c());
                }
            }
            else{
                oldMap=new map<id,General_Sub_Task__c>();
                oldMap.put(st.id,new General_Sub_Task__c());
            }
            
            
        }
        
        InsertUpdateActionPlans(newMap.values());
        updateActionPlans(newMap.values());
        system.debug('inside after trigger  for');
        GeneralSubTask_IsAfter_FieldHistoryTracking(newMap,oldMap);
        system.debug('inside after trigger  InsertUpdateActionPlans');
        
    }
    public static void updateActionPlans(List<General_Sub_Task__c> records)
    {
        Set<Id> RootCauseRecIds = new Set<Id>();
        
        for(General_Sub_Task__c pln : records)
        {
            if(pln.Associated_Root_Causes__c != null && pln.Associated_Root_Causes__c != '')
            {
                List<String> rootcauseIdsStr = pln.Associated_Root_Causes__c.split(',',0);
                for(String s: rootcauseIdsStr)
                {
                    RootCauseRecIds.add(s);
                }
            } // End of IF condition
            
        } // End of for Loop
        
        System.debug('-->RootCauseRecIds:'+RootCauseRecIds);
        
        
    } // End of function
    
    public static void InsertUpdateActionPlans(List<General_Sub_Task__c> records)
    {
        Savepoint sp = Database.setSavepoint();
        //try{  
        //Get AP Ids
        Map<Id, Set<String>> dmap = new Map<Id, Set<String>>();
        for(General_Sub_Task__c pln: records){
            dmap.put(pln.id, new Set<String>());   
        }
        
        //Get existing Action_Plan_Root_Cause__c
        List<Action_Plan_Root_Cause__c> todelete = new List<Action_Plan_Root_Cause__c>();
        List<Action_Plan_Root_Cause__c> toupdate = new List<Action_Plan_Root_Cause__c>();
        set<Id> ids = new set<Id>();
        for(Action_Plan_Root_Cause__c d:[select id,Task_Action_Plan__c,Task_Action_Plan__r.Associated_Root_Causes__c,Task_Root_Cause__c from Action_Plan_Root_Cause__c where Task_Action_Plan__c IN :dmap.keyset()]){
            
            if(d.Task_Action_Plan__r.Associated_Root_Causes__c != null && d.Task_Action_Plan__r.Associated_Root_Causes__c != ''){
                if(!ids.contains(d.Task_Root_Cause__c) &&  d.Task_Action_Plan__r.Associated_Root_Causes__c.contains(d.Task_Root_Cause__c)){   
                    dmap.get(d.Task_Action_Plan__c).add(d.Task_Root_Cause__c);
                    ids.add(d.Task_Root_Cause__c);
                    toupdate.add(d);
                    
                }
                else
                    todelete.add(d); 
            }
            
        }
        system.debug('Delete Size:' + todelete.size());
        //Create Action_Plan_Root_Cause__c
        List<Action_Plan_Root_Cause__c> toinsert = new List<Action_Plan_Root_Cause__c>();
        for(General_Sub_Task__c pln: records){
            
            if(pln.Associated_Root_Causes__c != null && pln.Associated_Root_Causes__c != ''){
                List<String> rootcauseids = pln.Associated_Root_Causes__c.split(',');
                for(string s:rootcauseids){
                    if(!dmap.get(pln.id).contains(s))
                        toinsert.add(new Action_Plan_Root_Cause__c(
                            Task_Root_Cause__c = s,
                            Task_Action_Plan__c = pln.id
                        ));
                    
                }
            }
        }
        
        if(todelete.size() > 0)
            delete todelete;
        if(toinsert.size() > 0)
            insert toinsert; 
        if(toupdate.size() > 0)
            update toupdate;
        //}
        // catch(Exception e) {
        //     Database.rollback(sp);
        //      ERR_Handler.processError(e, ERR_Handler_API.Context.PLNTRG);
        //  }
    }
    public static void GeneralSubTask_IsAfter_FieldHistoryTracking(Map<id,General_Sub_Task__c> newMap,Map<id,General_Sub_Task__c> oldMap){
        Map<id,User> User=new Map<id,User>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'id,Name');            
        if(queryFieldNames != null && queryFieldNames != '')
        {
            String qry='select ' + queryFieldNames + ' FROM user';
            LIST<USER> ulist=database.query (qry);
            User.putAll(ulist);                
        } 
        
        String Prefix =  QC_custom_settings.getPrefix();
        //v2.1.3 start
        if(Prefix!=null){
            Prefix+='__';
        }else{
            Prefix='';
        }
        //v2.1.3 start
        Map<String, Schema.SObjectField> General_Sub_Task_Lable =Schema.SObjectType.General_Sub_Task__c.fields.getMap();
        list<General_Sub_Task__c> ncs=new list<General_Sub_Task__c>();   
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        Change_Management_History__c cmhis;
        //v2.1.3 end
        string fieldApiname;
        dateMap=new map<integer,string>();
        dateMap.put(1,'Jan');
        dateMap.put(2,'Feb');
        dateMap.put(3,'Mar');
        dateMap.put(4,'Apr');
        dateMap.put(5,'May');
        dateMap.put(6,'Jun');
        dateMap.put(7,'July');
        dateMap.put(8,'Aug');
        dateMap.put(9,'Sep');
        dateMap.put(10,'Oct');
        dateMap.put(11,'Nov');
        dateMap.put(12,'Dec');
        date mydate;            
        id temp;
        Boolean flag=true;
        set<id> Objectids=new set<id>(newMap.keySet());
        List<NC_History__c> GeneralSubTaskhisList=new List<NC_History__c>();
        List<CAPA_History__c> GeneralSubTaskchisList = new List<CAPA_History__c>();
        //v2.1.3 start
        List<Change_Management_History__c> GeneralSubTaskcmhisList = new List<Change_Management_History__c>();
        //v2.1.3 end
        for(General_Sub_Task__c gt:newMap.values()){   
            if(gt.Non_Conformance__c!='' && gt.Non_Conformance__c!=null){
                final General_Sub_Task__c oldNc = oldmap.get(gt.Id);           
                for(Schema.SObjectField feildname:Schema.SObjectType.General_Sub_Task__c.fields.getMap().values()){
                    flag=true;
                    fieldApiname=string.valueOf(feildname);
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&fieldApiname!='Id'){
                        if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                            his=new NC_History__c();
                            his.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            his.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                his=new NC_History__c();  
                                if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                    if(oldNc.get(fieldApiname)!=null){
                                        mydate=date.valueOf(oldNc.get(fieldApiname));
                                        his.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                    }                                            
                                    if(gt.get(fieldApiname)!=null){
                                        mydate=date.valueOf(gt.get(fieldApiname));
                                        his.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                    }
                                    
                                }else{
                                    his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                    his.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                }                                      
                                his.Non_Conformance__c=gt.non_conformance__c;
                                his.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                his.Parent__c=GeneralSubTaskRt_map.get(gt.recordTypeID).getName();
                                his.object__c='General_Sub_Task__c';                           
                                GeneralSubTaskhisList.add(his);
                            }
                            
                        }                            
                    }
                    
                }          
            }else if(gt.CAPA__c!='' && gt.CAPA__c!=null){ 
                final General_Sub_Task__c oldCapa = oldmap.get(gt.Id);   
                for(Schema.SObjectField feildname:Schema.SObjectType.General_Sub_Task__c.fields.getMap().values()){
                    flag=true;
                    fieldApiname=string.valueOf(feildname);
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&fieldApiname!='Id'){
                        if(gt.get(fieldApiname)!=oldCapa.get(fieldApiname)){
                            system.debug('inside FieldHistoryTracking CAPA__c'+gt.CAPA__c);
                            chis=new CAPA_History__c();
                            chis.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            chis.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'&&flag){
                                chis=new CAPA_History__c();  
                                if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                    if(oldCapa.get(fieldApiname)!=null){
                                        mydate=date.valueOf(oldCapa.get(fieldApiname));
                                        chis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                    }                                        
                                    if(gt.get(fieldApiname)!=null){
                                        mydate=date.valueOf(gt.get(fieldApiname));
                                        chis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());            
                                    }
                                    
                                }else{
                                    chis.oldValue__c=string.valueOf(oldCapa.get(fieldApiname));
                                    chis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                }                                      
                                chis.CAPA__c = gt.CAPA__c;
                                system.debug('gt.General_Task__r.RecordType'+gt.General_Task__r.RecordType);
                                chis.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                chis.Parent__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName()+'@'+gt.Parent_Task__c;
                                chis.object__c='General_Sub_Task__c';            
                                GeneralSubTaskchisList.add(chis);
                                system.debug('chis.FieldName__c'+chis.FieldName__c);
                                
                            } 
                            
                        }
                    }
                    
                }
                
            }
            //v2.1.3 start
            else if(gt.Change_Management__c!='' && gt.Change_Management__c!=null){ 
                final General_Sub_Task__c oldCM = oldmap.get(gt.Id);   
                for(Schema.SObjectField feildname:Schema.SObjectType.General_Sub_Task__c.fields.getMap().values()){
                    flag=true;
                    fieldApiname=string.valueOf(feildname);
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&fieldApiname!='Id'){
                        if(gt.get(fieldApiname)!=oldCM.get(fieldApiname)){
                            system.debug('inside FieldHistoryTracking Change_Management__c'+gt.Change_Management__c);
                            cmhis=new Change_Management_History__c();
                            cmhis.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            cmhis.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE' &&flag &&  fieldApiname!=(Prefix+'Change_Management__c') && fieldApiname!=(Prefix+'General_Task_Name__c') && fieldApiname!=(Prefix+'Non_Conformance_Owner__c') && fieldApiname!=(Prefix+'Assign_User__c')){
                                cmhis=new Change_Management_History__c();  
                                if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                    if(oldCM.get(fieldApiname)!=null){
                                        mydate=date.valueOf(oldCM.get(fieldApiname));
                                        cmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                    }                                        
                                    if(gt.get(fieldApiname)!=null){
                                        mydate=date.valueOf(gt.get(fieldApiname));
                                        cmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());            
                                    }
                                    
                                }else{
                                    cmhis.oldValue__c=string.valueOf(oldCM.get(fieldApiname));
                                    cmhis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                }                                      
                                cmhis.Parent__c=gt.Change_Management__c;
                                system.debug('gt.General_Task__r.RecordType'+gt.General_Task__r.RecordType);
                                cmhis.FieldName__c=General_Sub_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                cmhis.Sub_Parent__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName();
                                cmhis.object__c='General_Sub_Task__c';            
                                GeneralSubTaskcmhisList.add(cmhis);
                                system.debug('cmhis.FieldName__c'+cmhis.FieldName__c);
                                
                            } 
                            
                            
                        }
                    }
                    
                }
                
            } 
            //v2.1.3 end
            
        }  // exit for loop
        if(!GeneralSubTaskhisList.isEmpty()){
            insert GeneralSubTaskhisList;    
        }
        if(!GeneralSubTaskchisList.isEmpty()){
            insert GeneralSubTaskchisList;    
        }
        
        //v2.1.3 start
        if(!GeneralSubTaskcmhisList.isEmpty()){
            insert GeneralSubTaskcmhisList;    
        }
        //v2.1.3 end
        
    }
    
    public static void GeneralSubTask_Afterdelete(list<General_Sub_Task__c> gts){
        GeneralSubTaskRt_map  = General_Sub_Task__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        List<NC_History__c> hisdelList=new List<NC_History__c>();       
        List<CAPA_History__c> chisdelList = new List<CAPA_History__c>(); 
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        List<Change_Management_History__c> cmhisdelList = new List<Change_Management_History__c>();
        Change_Management_History__c cmhis;
        //v2.1.3 end
        for(General_Sub_Task__c gt:gts){
            if(gt.Non_Conformance__c!=null){
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isdeleted__c=true; 
                his.FieldName__c=GeneralSubTaskRt_map.get(gt.recordTypeID).getName();
                his.object__c='General_Sub_Task__c';
                his.Parent__c=GeneralSubTaskRt_map.get(gt.recordTypeID).getName();
                //his.object__c='General_Sub_Task__c';
                //his.Parent__c=rt_map.get(gt.recordTypeID).getName();
                hisdelList.add(his);
            }else if(gt.CAPA__c!=''&&gt.CAPA__c!=null){
                system.debug('inside after trigger afterdelete'+gt.CAPA__c);
                chis=new CAPA_History__c(); 
                chis.CAPA__c=gt.CAPA__c;
                chis.isdeleted__c=true; 
                chis.FieldName__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName();
                chis.object__c='General_Sub_Task__c';
                chis.Parent__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName()+'@'+gt.Parent_Task__c;
                chisdelList.add(chis);
                system.debug('gt.General_Task__r.RecordType'+gt.Parent_Task__c); 
            }
            //v2.1.3 start
            else if(gt.Change_Management__c!=''&&gt.Change_Management__c!=null){
                system.debug('inside after trigger afterdelete'+gt.CAPA__c);
                cmhis=new Change_Management_History__c(); 
                cmhis.Parent__c=gt.Change_Management__c;
                cmhis.isdeleted__c=true; 
                cmhis.FieldName__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName();
                cmhis.object__c='General_Sub_Task__c';
                cmhis.Sub_Parent__c=GeneralSubTaskrt_Map.get(gt.recordTypeID).getName();
                cmhisdelList.add(cmhis);
                system.debug('gt.General_Task__r.RecordType'+gt.Parent_Task__c); 
            }
            //v2.1.3 end
        }
        if(!hisdelList.isEmpty())
            insert hisdelList; 
        if(!chisdelList.isEmpty())
            insert chisdelList; 
        //v2.1.3 start
        if(!cmhisdelList.isEmpty())
            insert cmhisdelList; 
        //v2.1.3 end
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // general sub task Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Disposition product Trigger handler start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static List<NC_History__c> DispProducthisList;
    public static void DispProduct_AfterUpdate(Map<id,Disposition_Product__c > newMap,Map<id,Disposition_Product__c > oldMap){
        DispProductHisList=new List<NC_History__c>();
        DispProductFieldHistoryTracking(newMap,oldMap);
        insert DispProductHisList;
    }
    
    
    public static void DispProductFieldHistoryTracking(Map<id,Disposition_Product__c > newMap,Map<id,Disposition_Product__c > oldMap){
        system.debug('FieldHistoryTracking');
        Map<String, Schema.SObjectField> Product_Lot_Numbers_Lable =Schema.SObjectType.Disposition_Product__c.fields.getMap();
        list<Disposition_Product__c > ncs=new list<Disposition_Product__c >();    
        DispProductHisList=new List<NC_History__c>();
        NC_History__c his;
        string fieldApiname;
        string temp;
        dateMap=new map<integer,string>();
        dateMap.put(1,'Jan');
        dateMap.put(2,'Feb');
        dateMap.put(3,'Mar');
        dateMap.put(4,'Apr');
        dateMap.put(5,'May');
        dateMap.put(6,'Jun');
        dateMap.put(7,'July');
        dateMap.put(8,'Aug');
        dateMap.put(9,'Sep');
        dateMap.put(10,'Oct');
        dateMap.put(11,'Nov');
        dateMap.put(12,'Dec');
        date mydate;
        for(Disposition_Product__c  gt:newMap.values()){         
            final Disposition_Product__c  oldNc = oldmap.get(gt.Id);           
            for(Schema.SObjectField feildname:Schema.SObjectType.Disposition_Product__c.fields.getMap().values()){
                fieldApiname=string.valueOf(feildname);
                if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&fieldApiname!='Id'&&String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                    if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                        his=new NC_History__c();
                        his.FieldName__c=Product_Lot_Numbers_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                        his.FieldApiName__c=fieldApiname;
                        system.debug('inside field type Disposition_Product__c');
                        // if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){                            
                        //     fieldApiname=fieldApiname+'.Name';     
                        // }
                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                            if(oldNc.get(fieldApiname)!=null){
                                mydate=date.valueOf(oldNc.get(fieldApiname));
                                his.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                            }                                            
                            if(gt.get(fieldApiname)!=null){
                                mydate=date.valueOf(gt.get(fieldApiname));
                                his.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                            }
                            
                        }else{
                            if(oldNc.get(fieldApiname)!=null){
                                his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                            }
                            if(gt.get(fieldApiname)!=null){
                                his.NewValue__c=string.valueOf(gt.get(fieldApiname));  
                            }
                        }
                        
                        his.Non_Conformance__c=gt.non_conformance__c;
                        his.Parent__c='Disposition';
                        his.object__c='Disposition_Product__c';
                        DispProductHisList.add(his);                        
                    }                            
                }
                
            }          
            
        }  
        
    }
    public static void DispProduct_Afterinsert(Map<id,Disposition_Product__c> gts){
        
        DispProductHisList=new List<NC_History__c>();
        NC_History__c his;
        map<id,Disposition_Product__c> insertOldMap=new map<id,Disposition_Product__c>();
        for(Disposition_Product__c gt:gts.values()){     
            insertOldMap.put(gt.id,new Disposition_Product__c());
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isCreated__c=true; 
            his.FieldName__c='Disposition Product';
            his.object__c='Disposition_Product__c';
            DispProductHisList.add(his);
        }
        DispProductFieldHistoryTracking(gts,insertOldMap);  
        for(NC_History__c nch:DispProductHisList){
            nch.isCreated__c=true;
        }
        insert DispProductHisList; 
        
    }
    
    public static void DispProduct_Afterdelete(list<Disposition_Product__c> gts){
        List<NC_History__c> DispProductHisdelList=new List<NC_History__c>();        
        NC_History__c his;
        for(Disposition_Product__c gt:gts){
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isdeleted__c=true; 
            his.FieldName__c='Disposition Product';
            his.object__c='Disposition_Product__c';
            DispProductHisdelList.add(his);
        }
        insert DispProductHisdelList;          
    }    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Disposition product Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ActionPlan Root Cause Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<NC_History__c> ActionPlanRootCausehisList;
    public static List<CAPA_History__c> ActionPlanRootCausechisList;
    public static void ActionPlanRootCause_Afterupdate(Map<id,Action_Plan_Root_Cause__c> newMap,Map<id,Action_Plan_Root_Cause__c> oldMap){
        ActionPlanRootCausehisList=new List<NC_History__c>();
        ActionPlanRoot_IsAfter_FieldHistoryTracking(newMap,oldMap);
        insert ActionPlanRootCausehisList;
    }
    
    
    public static void ActionPlanRoot_IsAfter_FieldHistoryTracking(Map<id,Action_Plan_Root_Cause__c > newMap,Map<id,Action_Plan_Root_Cause__c > oldMap){
        Map<String, Schema.SObjectField> General_Task_Lable =Schema.SObjectType.Action_Plan_Root_Cause__c .fields.getMap();
        list<Action_Plan_Root_Cause__c > ncs=new list<Action_Plan_Root_Cause__c >();  
        if(ActionPlanRootCausehisList==null)
        ActionPlanRootCausehisList=new List<NC_History__c>();
        ActionPlanRootCausechisList=new List<CAPA_History__c>();
        NC_History__c his;
        CAPA_History__c chis;    
        string fieldApiname;
        
        for(Action_Plan_Root_Cause__c  gt:newMap.values()){
            if(gt.Non_Conformance__c!=''&&gt.Non_Conformance__c!=null){ 
                final Action_Plan_Root_Cause__c  oldNc = oldmap.get(gt.Id);           
                for(Schema.SObjectField feildname:Schema.SObjectType.Action_Plan_Root_Cause__c .fields.getMap().values()){
                    fieldApiname=string.valueOf(feildname);
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                        if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                            his=new NC_History__c();
                            his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            his.FieldApiName__c=fieldApiname;
                            his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                            his.NewValue__c=string.valueOf(gt.get(fieldApiname));
                            his.Non_Conformance__c=gt.non_conformance__c;
                            his.Parent__c='Implementation';
                            his.object__c='Action_Plan_Root_Cause__c';
                            ActionPlanRootCausehisList.add(his);                        
                        }                            
                    }
                    
                }          
            }else if(gt.CAPA__c!=''&&gt.CAPA__c!=null){ 
                final Action_Plan_Root_Cause__c  oldcapa = oldmap.get(gt.Id);           
                for(Schema.SObjectField feildname:Schema.SObjectType.Action_Plan_Root_Cause__c .fields.getMap().values()){
                    fieldApiname=string.valueOf(feildname);
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                        if(gt.get(fieldApiname)!=oldcapa.get(fieldApiname)){
                            chis=new CAPA_History__c();
                            chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            chis.FieldApiName__c=fieldApiname;
                            chis.oldValue__c=string.valueOf(oldcapa.get(fieldApiname));
                            chis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                            chis.CAPA__c=gt.CAPA__c;
                            chis.Parent__c='Implementation';
                            chis.object__c='Action_Plan_Root_Cause__c';
                            ActionPlanRootCausechisList.add(chis);                        
                        }                            
                    }
                    
                }          
                
            } 
        }  
        
    }
    public static void ActionPlanRootCause_Afterinsert(Map<id,Action_Plan_Root_Cause__c > gts){
        
        CAPA_History__c chis;  
        if(ActionPlanRootCausehisList==null)
        ActionPlanRootCausehisList=new List<NC_History__c>();   
        ActionPlanRootCausechisList=new List<CAPA_History__c>();   
        NC_History__c his;
        system.debug('iscreated in Implementation');
        
        //MAP<id,Action_Plan_Root_Cause__c> insertActionPlanRootCause=new MAP<id,Action_Plan_Root_Cause__c>();
        for(Action_Plan_Root_Cause__c  gt:gts.values()){
            
            //insertActionPlanRootCause.put(gt.id,new Action_Plan_Root_Cause__c());
            if(gt.Non_Conformance__c!=''&&gt.Non_Conformance__c!=null){
                system.debug('iscreated in Implementation');
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isCreated__c=true; 
                his.Parent__c='Implementation';
                his.FieldName__c='Created';
                his.object__c='Action Plan Root Cause';
                ActionPlanRootCausehisList.add(his);
            }else if(gt.CAPA__c!=''&&gt.CAPA__c!=null){ 
                chis=new CAPA_History__c(); 
                chis.CAPA__c=gt.CAPA__c;
                chis.isCreated__c=true; 
                chis.Parent__c='Implementation';
                chis.FieldName__c='Created';
                chis.object__c='Action Plan Root Cause';
                ActionPlanRootCausechisList.add(chis);
            }

            
        }//for loop ends
        //ActionPlanRoot_IsAfter_FieldHistoryTracking(gts,insertActionPlanRootCause);
        
        if(!ActionPlanRootCausehisList.isEmpty())
        insert ActionPlanRootCausehisList;     
        if(!ActionPlanRootCausechisList.isEmpty())
        insert ActionPlanRootCausechisList;     
        
    }
    
    public static void ActionPlanRootCause_Afterdelete(list<Action_Plan_Root_Cause__c > gts){
        ActionPlanRootCausehisList=new List<NC_History__c>();   
        CAPA_History__c chis;  
        ActionPlanRootCausechisList=new List<CAPA_History__c>();
        NC_History__c his;
        for(Action_Plan_Root_Cause__c  gt:gts){
            
            if(gt.Non_Conformance__c!=''&&gt.Non_Conformance__c!=null){
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isdeleted__c=true; 
                his.FieldName__c='Action Plan Root Cause';
                his.Parent__c='Implementation';
                his.object__c='Action_Plan_Root_Cause__c ';
                ActionPlanRootCausehisList.add(his);
            }else if(gt.CAPA__c!=''&&gt.CAPA__c!=null){ 
                chis=new CAPA_History__c(); 
                chis.CAPA__c = gt.CAPA__c;
                chis.isdeleted__c=true; 
                chis.FieldName__c='Action Plan Root Cause';
                chis.Parent__c='Implementation';
                chis.object__c='Action_Plan_Root_Cause__c ';
                ActionPlanRootCausechisList.add(chis);
            }
            
        }
        if(!ActionPlanRootCausehisList.isEmpty())
            insert ActionPlanRootCausehisList;     
        if(!ActionPlanRootCausechisList.isEmpty())
            insert ActionPlanRootCausechisList;          
    }  
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ActionPlan Root Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Approver  Trigger handler start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void Approver_Afterupdate(Map<id,Approver__c> newMap,Map<id,Approver__c> oldMap){
        ApproverhisList=new List<NC_History__c>();
        ApproverchisList=new List<CAPA_History__c>();
        //v2.1.3 start
        ApprovercmhisList = new List<Change_Management_History__c>();
        ApproverdphisList = new List<Document_profile_History__c>();
        //v2.1.3 end
        Approver_IsAfter_FieldHistoryTracking(newMap,oldMap);
        insert ApproverhisList;
        insert ApproverchisList;
        //v2.1.3 start
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
            insert ApprovercmhisList;   
        }
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
            insert ApproverdphisList; 
        }
        ////v2.1.3 start
    }
    public static List<NC_History__c> ApproverhisList;
    public static List<CAPA_History__c> ApproverchisList;
    //v2.1.3 start
    public static List<Change_Management_History__c> ApprovercmhisList;
    public static List<Document_Profile_History__c> ApproverdphisList;
    //v2.1.3 end
    public static void Approver_IsAfter_FieldHistoryTracking(Map<id,Approver__c  > newMap,Map<id,Approver__c  > oldMap){
        Map<String, Schema.SObjectField> General_Task_Lable =Schema.SObjectType.Approver__c  .fields.getMap();
        list<Approver__c  > ncs=new list<Approver__c  >(); 
        if(ApproverhisList==null)
        ApproverhisList=new List<NC_History__c>();
        NC_History__c his;
        string fieldApiname;
        CAPA_History__c chis; 
        //v2.1.3 start
        Change_Management_History__c cmhis;
        Document_Profile_History__c dphis;
        //v2.1.3 end
        
        for(Approver__c   gt:newMap.values()){         
            final Approver__c   oldNc = oldmap.get(gt.Id);  
            
            for(Schema.SObjectField feildname:Schema.SObjectType.Approver__c.fields.getMap().values()){
                fieldApiname=string.valueOf(feildname);
                if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                    if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                        if(gt.Non_conformance__c!=''&&gt.Non_conformance__c!=null){
                            his=new NC_History__c();
                            his.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            his.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                his.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                his.Non_Conformance__c=gt.non_conformance__c;
                                his.Parent__c=gt.Parent_name__c;
                                his.object__c='General_Task__c';
                                ApproverhisList.add(his);                        
                            }
                        }else if(gt.Parent_Object__c!=''&&gt.Parent_Object__c!=null){                             
                            chis=new CAPA_History__c(); 
                            chis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            chis.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                chis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                chis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                chis.CAPA__c = gt.Parent_Object__c;
                                chis.Parent__c=gt.Parent_name__c;
                                chis.object__c='General_Task__c ';
                                ApproverchisList.add(chis);
                            }
                        }////v2.1.3 start
                        else if(gt.Change_Management__c!=''&&gt.Change_Management__c!=null){                             
                            cmhis=new Change_Management_History__c(); 
                            cmhis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            cmhis.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                cmhis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                cmhis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                cmhis.Parent__c = gt.Change_Management__c;
                                cmhis.Sub_Parent__c=gt.Parent_name__c;
                                cmhis.object__c='General_Task__c ';
                                ApprovercmhisList.add(cmhis);
                            }
                        }
                        else if(gt.Document_Profile__c!=''&&gt.Document_Profile__c!=null){                             
                            dphis=new Document_Profile_History__c(); 
                            dphis.FieldName__c=General_Task_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            dphis.FieldApiName__c=fieldApiname;
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                dphis.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                dphis.NewValue__c=string.valueOf(gt.get(fieldApiname));
                                dphis.Parent__c = gt.Document_Profile__c;
                                dphis.Sub_Parent__c=gt.Parent_name__c;
                                dphis.object__c='General_Task__c ';
                                ApproverdphisList.add(dphis);
                            }
                        }
                        /////v2.1.3 end


                    }                            
                }
                
            }          
            
        }  
       // insert ApproverhisList;
        
    }
    public static void Approver_Afterinsert(list<Approver__c> gts){
        if(ApproverhisList==null)
        ApproverhisList=new List<NC_History__c>();  
        if(ApproverchisList==null)
        ApproverchisList=new List<CAPA_History__c>();  
        if(ApprovercmhisList==null)
        ApprovercmhisList=new List<Change_Management_History__c>();  
        if(ApproverdphisList==null)
        ApproverdphisList=new List<Document_Profile_History__c>();  
        NC_History__c his;
        CAPA_History__c chis;
        //v2.1.3 start
        Change_Management_History__c cmhis;
        Document_Profile_History__c dphis;
        //v2.1.3 end
        system.debug('iscreated in Implementation');
        Map<id,Approver__c> insertapprover=new Map<id,Approver__c>();
        for(Approver__c gt:gts){
            system.debug('inside for loop Approver');
            if(gt.Non_Conformance__c!=null){
                insertapprover.put(gt.id, new Approver__c());
                system.debug('iscreated in Implementation');
                his=new NC_History__c(); 
                his.Non_Conformance__c=gt.Non_conformance__c;
                his.isCreated__c=true; 
                his.Parent__c=gt.Parent_name__c;
                his.FieldName__c='Approver';
                his.object__c='General_Task__c';
                ApproverhisList.add(his);
            }
            else if(gt.Parent_Object__c!=''&&gt.Parent_Object__c!=null){ 
                insertapprover.put(gt.id, new Approver__c());
                system.debug('iscreated in Implementation');
                chis=new CAPA_History__c(); 
                chis.Capa__c=gt.Parent_Object__c;
                chis.isCreated__c=true; 
                chis.Parent__c=gt.Parent_name__c;
                chis.FieldName__c='Approver';
                chis.object__c='General_Task__c';
                ApproverchisList.add(chis);
            }
            ////v2.1.3 start
            else if(gt.Change_Management__c!=''&&gt.Change_Management__c!=null){ 
                insertapprover.put(gt.id, new Approver__c());
                system.debug('iscreated in Change_Management__c');
                cmhis=new Change_Management_History__c(); 
                cmhis.Parent__c=gt.Change_Management__c;
                cmhis.isCreated__c=true; 
                cmhis.Sub_Parent__c=gt.Parent_name__c;
                cmhis.FieldName__c='Approver';
                cmhis.object__c='General_Task__c';
                ApprovercmhisList.add(cmhis);
            }
            else if(gt.Document_Profile__c!=''&&gt.Document_Profile__c!=null){ 
                insertapprover.put(gt.id, new Approver__c());
                system.debug('iscreated in Document_Profile__c');
                dphis=new Document_Profile_History__c(); 
                dphis.Parent__c=gt.Document_Profile__c;
                dphis.isCreated__c=true; 
                dphis.Sub_Parent__c=gt.Parent_name__c;
                dphis.FieldName__c='Approver';
                dphis.object__c='General_Task__c';
                ApproverdphisList.add(dphis);
            }
            //v2.1.3 end
        }
        Map<id,Approver__c> approverNewMap=new Map<id,Approver__c>(gts);
        Approver_IsAfter_FieldHistoryTracking(approverNewMap,insertapprover);  
        for(NC_History__c nch:ApproverhisList){
            nch.isCreated__c=true;
        }
        for(CAPA_History__c nch:ApproverchisList){
            nch.isCreated__c=true;
        }
        //v2.1.3 start
        for(Change_Management_History__c cmh:ApprovercmhisList){
            cmh.isCreated__c=true;
        }
        for(Document_Profile_History__c dph:ApproverdphisList){
            dph.isCreated__c=true;
        }
        //v2.1.3 end
        if(!ApproverhisList.isEmpty())
        insert ApproverhisList;     
        if(!ApproverchisList.isEmpty())
        insert ApproverchisList;
        
        //v2.1.3 start
        if(!ApprovercmhisList.isEmpty())
        insert ApprovercmhisList;
        if(!ApproverdphisList.isEmpty())
        insert ApproverdphisList;
        //v2.1.3 end
    }
    
    public static void Approver_Afterdelete(list<Approver__c> gts){
        system.debug('isdeleted in containment');
        List<NC_History__c> ApproverdelhisList=new List<NC_History__c>();  
        //v2.1.3 start
        List<CAPA_History__c> ApproverdelchisList=new List<CAPA_History__c>(); 
        List<Change_Management_History__c> ApproverdelcmhisList=new List<Change_Management_History__c>();
        List<Document_Profile_History__c> ApproverdeldphisList=new List<Document_Profile_History__c>();
        //v2.1.3 end
        NC_History__c his;
        //v2.1.3 start
        CAPA_History__c chis;
        Change_Management_History__c cmhis;
        Document_Profile_History__c dphis;
        
        for(Approver__c gt:gts){
            if(gt.Non_Conformance__c!=null){
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isdeleted__c=true; 
            his.FieldName__c='Approver';
            his.Parent__c=gt.Parent_name__c;
            his.object__c='General_Task__c ';
            }
            else if(gt.Parent_Object__c!=''&&gt.Parent_Object__c!=null){ 
                chis=new CAPA_History__c(); 
                chis.Capa__c=gt.Parent_Object__c;
                chis.isdeleted__c=true; 
                chis.Parent__c=gt.Parent_name__c;
                chis.FieldName__c='Approver';
                chis.object__c='General_Task__c';
            }
            ///////////
            else if(gt.Change_Management__c!=''&&gt.Change_Management__c!=null){ 
                cmhis=new Change_Management_History__c(); 
                cmhis.Parent__c=gt.Change_Management__c;
                cmhis.isdeleted__c=true; 
                cmhis.Sub_Parent__c=gt.Parent_name__c;
                cmhis.FieldName__c='Approver';
                cmhis.object__c='General_Task__c';
            }
            
            else if(gt.Document_Profile__c!=''&&gt.Document_Profile__c!=null){ 
                dphis=new Document_Profile_History__c(); 
                dphis.Parent__c=gt.Document_Profile__c;
                dphis.isdeleted__c=true; 
                dphis.Sub_Parent__c=gt.Parent_name__c;
                dphis.FieldName__c='Approver';
                dphis.object__c='General_Task__c';
            }
        }
        insert ApproverdelhisList;
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('CAPA_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,CAPA__c','create')){
        insert ApproverdelchisList;
        }
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
        insert ApproverdelcmhisList;
        }
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
        insert ApproverdeldphisList;          
        }
        //v2.1.3 end
    }   
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Approver  Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Attachment  Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    public static void Attachment_AfterUpdate(Map<id,Attachment> Newattachments,Map<id,Attachment> Oldattachments){
        AttachmentFieldHistoryTracking(Newattachments,Oldattachments);
    }
    
    public static void AttachmentFieldHistoryTracking(Map<id,Attachment> newMap,Map<id,Attachment> oldMap){
        Map<String, Schema.SObjectField> Attachment_Lable =Schema.SObjectType.Attachment.fields.getMap();
        list<Attachment> ncs=new list<Attachment>();    
        List<NC_History__c> hisList=new List<NC_History__c>();
        NC_History__c his;
        string fieldApiname;
        List<CAPA_History__c> capaHisList=new List<CAPA_History__c>();
        CAPA_History__c capaHis;
        //v2.1.3 start
        List<Change_Management_History__c> cmHisList=new List<Change_Management_History__c>();
        Change_Management_History__c cmHis;
        List<Document_Type_History__c> dtHisList=new List<Document_Type_History__c>();
        Document_Type_History__c dtHis;  
        List<Document_Profile_History__c> dpHisList=new List<Document_Profile_History__c>();
        Document_Profile_History__c dpHis;  
        //v2.1.3 end
        
        
        for(Attachment gt:newMap.values()){         
            final Attachment oldNc = oldmap.get(gt.Id);           
            for(Schema.SObjectField feildname:Schema.SObjectType.Attachment.fields.getMap().values()){
                fieldApiname=string.valueOf(feildname);
                if(String.valueOf(gt.ParentId.getSobjectType()).containsIgnoreCase('Non_Conformance__c')){
                    if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                        if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                            his=new NC_History__c();
                            his.Description__c=gt.id;
                            his.FieldName__c='Attachment/'+Attachment_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                            his.FieldApiName__c=fieldApiname;    
                            if(string.valueOf(gt.Name).startsWith('Deleted@')&&string.valueOf(fieldApiname)=='Name'){
                                his.isDeleted__c=true;
                                his.oldValue__c=string.valueOf(gt.Name).removeStart('Deleted@'); 
                            }
                            else{
                                his.oldValue__c=(string.valueOf(oldNc.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(oldNc.get(fieldApiname)).substringBeforeLast('@'):'None';    
                                his.NewValue__c=(string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!=null||string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@'):'None';
                            }     
                            his.Non_Conformance__c=string.valueOf(gt.ParentId);                                
                            his.Parent__c=gt.Description.substringAfterLast('@');
                            his.object__c=(string.valueOf(gt.get(fieldApiname)).endsWith('@Resolution')?'Non_Conformance__c':(string.valueOf(gt.get(fieldApiname)).endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));                                    
                            hisList.add(his); 
                            
                        }
                    }
                }   else if(String.valueOf(gt.ParentId.getSobjectType()).containsIgnoreCase('CAPA__c')){
                    final Attachment oldCapa = oldmap.get(gt.Id);           
                    for(Schema.SObjectField feildnamea:Schema.SObjectType.Attachment.fields.getMap().values()){
                        fieldApiname=string.valueOf(feildnamea);
                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                            if(gt.get(fieldApiname)!=oldCapa.get(fieldApiname)){
                                capaHis=new CAPA_History__c();
                                capaHis.Description__c=gt.id;
                                capaHis.FieldName__c='Attachment/'+Attachment_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                capaHis.FieldApiName__c=fieldApiname;    
                                if(string.valueOf(gt.Name).startsWith('Deleted@')&&string.valueOf(fieldApiname)=='Name'){
                                    capaHis.isDeleted__c=true;
                                    capaHis.oldValue__c=string.valueOf(gt.Name).removeStart('Deleted@'); 
                                }
                                else{
                                    capaHis.oldValue__c=(string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@'):'None';    
                                    capaHis.NewValue__c=(string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!=null||string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@'):'None';
                                }     
                                capaHis.CAPA__c=string.valueOf(gt.ParentId);                                
                                capaHis.Parent__c=gt.Description.substringAfterLast('@');
                                capaHis.object__c=(string.valueOf(gt.get(fieldApiname)).endsWith('@Resolution')?'Non_Conformance__c':(string.valueOf(gt.get(fieldApiname)).endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));                                    
                                capaHisList.add(capaHis); 
                                
                            }                            
                        }
                        
                    }
                }
                //v2.1.3 start
                  else if(String.valueOf(gt.ParentId.getSobjectType()).containsIgnoreCase('Change_Management__c')){
                    final Attachment oldCapa = oldmap.get(gt.Id);           
                    for(Schema.SObjectField feildnamea:Schema.SObjectType.Attachment.fields.getMap().values()){
                        fieldApiname=string.valueOf(feildnamea);
                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                            if(gt.get(fieldApiname)!=oldCapa.get(fieldApiname)){
                                cmHis=new Change_Management_History__c();
                                cmHis.Description__c=gt.id;
                                cmHis.FieldName__c='Attachment/'+Attachment_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                cmHis.FieldApiName__c=fieldApiname;    
                                if(string.valueOf(gt.Name).startsWith('Deleted@')&&string.valueOf(fieldApiname)=='Name'){
                                    cmHis.isDeleted__c=true;
                                    cmHis.oldValue__c=string.valueOf(gt.Name).removeStart('Deleted@'); 
                                }
                                else{
                                    cmHis.oldValue__c=(string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@'):'None';    
                                    cmHis.NewValue__c=(string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!=null||string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@'):'None';
                                }     
                                cmHis.Parent__c=string.valueOf(gt.ParentId);                                
                                cmHis.Sub_Parent__c=gt.Description.substringAfterLast('@');
                                cmHis.object__c=(string.valueOf(gt.get(fieldApiname)).endsWith('@Resolution')?'Change_Management__c':(string.valueOf(gt.get(fieldApiname)).endsWith('@Document Information')?'Document_Profile__c':'General_Task__c'));                                    
                                cmHisList.add(cmHis); 
                                
                            }                            
                        }
                        
                    }
                } 
                
                else if(String.valueOf(gt.ParentId.getSobjectType()).containsIgnoreCase('Document_Type__c')){
                    final Attachment oldCapa = oldmap.get(gt.Id);           
                    for(Schema.SObjectField feildnamea:Schema.SObjectType.Attachment.fields.getMap().values()){
                        fieldApiname=string.valueOf(feildnamea);
                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                            if(gt.get(fieldApiname)!=oldCapa.get(fieldApiname)){
                                dtHis=new Document_Type_History__c();
                                dtHis.Description__c=gt.id;
                                dtHis.FieldName__c='DocumentType Template/'+Attachment_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                dtHis.FieldApiName__c=fieldApiname;    
                                if(string.valueOf(gt.Name).startsWith('Deleted@')&&string.valueOf(fieldApiname)=='Name'){
                                    dtHis.isDeleted__c=true;
                                    dtHis.oldValue__c=string.valueOf(gt.Name).removeStart('Deleted@'); 
                                }
                                else{
                                    dtHis.oldValue__c=(string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@'):'None';    
                                    dtHis.NewValue__c=(string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!=null||string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@'):'None';
                                }     
                                dtHis.Parent__c=string.valueOf(gt.ParentId);                                
                                dtHis.Sub_Parent__c=gt.Description.substringAfterLast('@');
                                dtHis.object__c=(string.valueOf(gt.get(fieldApiname)).endsWith('@Init')?'Document_Type__c':(string.valueOf(gt.get(fieldApiname)).endsWith('@Document Information')?'Document_Type__c':'General_Task__c'));                                    
                                dtHisList.add(dtHis); 
                                
                            }                            
                        }
                        
                    }
                } 
                
                else if(String.valueOf(gt.ParentId.getSobjectType()).containsIgnoreCase('Document_Profile__c')){
                    final Attachment oldCapa = oldmap.get(gt.Id);           
                    for(Schema.SObjectField feildnamea:Schema.SObjectType.Attachment.fields.getMap().values()){
                        fieldApiname=string.valueOf(feildnamea);
                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                            if(gt.get(fieldApiname)!=oldCapa.get(fieldApiname)){
                                dpHis=new Document_Profile_History__c();
                                dpHis.Description__c=gt.id;
                                dpHis.FieldName__c='Attachment/'+Attachment_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                dpHis.FieldApiName__c=fieldApiname;    
                                if(string.valueOf(gt.Name).startsWith('Deleted@')&&string.valueOf(fieldApiname)=='Name'){
                                    dpHis.isDeleted__c=true;
                                    dpHis.oldValue__c=string.valueOf(gt.Name).removeStart('Deleted@'); 
                                }
                                else{
                                    dpHis.oldValue__c=(string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(oldCapa.get(fieldApiname)).substringBeforeLast('@'):'None';    
                                    dpHis.NewValue__c=(string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!=null||string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@')!='')?string.valueOf(gt.get(fieldApiname)).substringBeforeLast('@'):'None';
                                }     
                                dpHis.Parent__c=string.valueOf(gt.ParentId);                                
                                dpHis.Sub_Parent__c=gt.Description.substringAfterLast('@');
                                dpHis.object__c=(string.valueOf(gt.get(fieldApiname)).endsWith('@Resolution')?'Document_Profile__c':(string.valueOf(gt.get(fieldApiname)).endsWith('@Document Information')?'Document_Profile__c':'General_Task__c'));                                    
                                dpHisList.add(dpHis); 
                                
                            }                            
                        }
                        
                    }
                } 
                 //v2.1.3 end                 
                
            }
            
        }  // end of loop          
        
        
        
        if(!hisList.isEmpty()){
            insert hisList;
        }
        if(!capaHisList.isEmpty()){
            insert capaHisList;
        } 
        
        //v2.1.3 start
        if(!cmHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
              insert cmHisList;
            }
        }
        
        if(!dtHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
              insert dtHisList;
            }
        }
        if(!dpHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
              insert dpHisList;
            }
        }
        //v2.1.3 end 
        
    }
    public static void Attachment_Afterinsert(list<Attachment> gts){
        
        List<CAPA_History__c> capaHisList=new List<CAPA_History__c>();
        List<NC_History__c> hisList=new List<NC_History__c>();    
        //v2.1.3 start
        List<Change_Management_History__c> cmHisList=new List<Change_Management_History__c>();
        List<Document_Type_History__c> dtHisList=new List<Document_Type_History__c>();
        List<Document_Profile_History__c> dpHisList=new List<Document_Profile_History__c>();
        //v2.1.3 end
        NC_History__c his;
        CAPA_History__c capaHis;
        //v2.1.3 start
        Change_Management_History__c cmHis;
        Document_Type_History__c dtHis;
        Document_Profile_History__c dpHis;
        //v2.1.3 end
        for(Attachment  a:gts){
            if(String.valueOf(a.ParentId.getSobjectType()).containsIgnoreCase('Non_Conformance__c')){
                his=new NC_History__c(); 
                his.Description__c=a.id;
                his.Non_Conformance__c=a.ParentId;
                his.isCreated__c=true; 
                his.Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                his.FieldName__c='Attachment/Description';
                his.NewValue__c=((a.Description.substringBeforeLast('@')!=null||a.Description.substringBeforeLast('@')!='')?a.Description.substringBeforeLast('@'):'None');
                his.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                hisList.add(his); 
                his=new NC_History__c(); 
                his.Non_Conformance__c=a.ParentId;
                his.isCreated__c=true; 
                his.Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                his.FieldName__c='Attachment/File Name';
                his.NewValue__c=a.Name;
                his.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                hisList.add(his);
            }else if(String.valueOf(a.ParentId.getSobjectType()).containsIgnoreCase('CAPA__c')){
                capaHis=new CAPA_History__c(); 
                capaHis.Description__c=a.id;
                capaHis.CAPA__c=a.ParentId;
                capaHis.isCreated__c=true; 
                capaHis.Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                capaHis.FieldName__c='Attachment/Description';
                capaHis.NewValue__c=((a.Description.substringBeforeLast('@')!=null||a.Description.substringBeforeLast('@')!='')?a.Description.substringBeforeLast('@'):'None');
                capaHis.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                capaHisList.add(capaHis); 
                capaHis=new CAPA_History__c(); 
                capaHis.CAPA__c=a.ParentId;
                capaHis.isCreated__c=true; 
                capaHis.Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                capaHis.FieldName__c='Attachment/File Name';
                capaHis.NewValue__c=a.Name;
                capaHis.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                capaHisList.add(capaHis);
            } 
            //v2.1.3 start
            else if(String.valueOf(a.ParentId.getSobjectType()).containsIgnoreCase('Change_Management__c')){
                cmHis=new Change_Management_History__c(); 
                cmHis.Description__c=a.id;
                cmHis.Parent__c=a.ParentId;
                cmHis.isCreated__c=true; 
                cmHis.Sub_Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                cmHis.FieldName__c='Attachment/Description';
                cmHis.NewValue__c=((a.Description.substringBeforeLast('@')!=null||a.Description.substringBeforeLast('@')!='')?a.Description.substringBeforeLast('@'):'None');
                cmHis.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                cmHisList.add(cmHis); 
                cmHis=new Change_Management_History__c(); 
                cmHis.Parent__c=a.ParentId;
                cmHis.isCreated__c=true; 
                cmHis.Sub_Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                cmHis.FieldName__c='Attachment/File Name';
                cmHis.NewValue__c=a.Name;
                cmHis.object__c=(a.Description.endsWith('@Resolution')?'Non_Conformance__c':(a.Description.endsWith('@Product Information')?'NC_Product__c':'General_Task__c'));
                cmHisList.add(cmHis);
            }else if(String.valueOf(a.ParentId.getSobjectType()).containsIgnoreCase('Document_Profile__c')){
                dpHis=new Document_Profile_History__c(); 
                dpHis.Description__c=a.id;
                dpHis.Parent__c=a.ParentId;
                dpHis.isCreated__c=true; 
                dpHis.Sub_Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                dpHis.FieldName__c='Attachment/Description';
                dpHis.NewValue__c=((a.Description.substringBeforeLast('@')!=null||a.Description.substringBeforeLast('@')!='')?a.Description.substringBeforeLast('@'):'None');
                dpHis.object__c=(a.Description.endsWith('@Resolution')?'Document_Profile__c':'General_Task__c');
                dpHisList.add(dpHis); 
                dpHis=new Document_Profile_History__c(); 
                dpHis.Parent__c=a.ParentId;
                dpHis.isCreated__c=true; 
                dpHis.Sub_Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                dpHis.FieldName__c='Attachment/File Name';
                dpHis.NewValue__c=a.Name;
                dpHis.object__c=(a.Description.endsWith('@Resolution')?'Document_Profile__c':'General_Task__c');
                dpHisList.add(dpHis); 
            }else if(String.valueOf(a.ParentId.getSobjectType()).containsIgnoreCase('Document_Type__c')){
                /*dtHis=new Document_Type_History__c(); 
                dtHis.Description__c=a.id;
                dtHis.Parent__c=a.ParentId;
                dtHis.isCreated__c=true; 
                dtHis.Sub_Parent__c=((string.valueOf(a.Description).substringAfterLast('@')!=''||string.valueOf(a.Description).substringAfterLast('@')!=null)?string.valueOf(a.Description).substringAfterLast('@'):'NONE');
                dtHis.FieldName__c='DocumentType Template/Description';
                dtHis.NewValue__c=((a.Description.substringBeforeLast('@')!=null||a.Description.substringBeforeLast('@')!='')?a.Description.substringBeforeLast('@'):'None');
                dtHis.object__c='Document_Type__c';
                dtHisList.add(dtHis); */
                dtHis=new Document_Type_History__c(); 
                dtHis.Parent__c=a.ParentId;
                dtHis.isCreated__c=true; 
                dtHis.Sub_Parent__c='Details';
                dtHis.FieldName__c='DocumentType Template/File Name';
                dtHis.NewValue__c=a.Name;
                dtHis.object__c='Document_Type__c';
                dtHisList.add(dtHis); 
            }
            
            //v2.1.3 end     
        }// end for loop
        if(!hisList.isEmpty()){
            insert hisList;
        }     
        if(!capaHisList.isEmpty()){
            insert capaHisList;
        } 
        
        //v2.1.3 start
        if(!cmHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
            insert cmHisList;
            }
        }
        if(!dpHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
            insert dpHisList;
            }
        }
        if(!dtHisList.isEmpty()){
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
            insert dtHisList;
            }
        }
        //v2.1.3 end 
        
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Attachment Trigger handler end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////        
}