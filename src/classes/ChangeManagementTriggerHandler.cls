public class ChangeManagementTriggerHandler {
    
    public static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public static List<Change_Management_History__c> cmhisList;
    public static Map<integer,string> dateMap;
    public static Map<id,User> User;
    public static Map<id,Risk_Priority__c> RiskPriority;
    public static Map<id,Risk_Severity__c> RiskSeverity;
    public static Map<id,Manufacturing_Site__c> manufacturingSite;
    public static Map<id,Document_Profile__c> DocumentNumber;
    
    public static void ChangeManagement_BeforeTrigger(List<Change_Management__c> newCMList, Map<Id, Change_Management__c> newCMMap, List<Change_Management__c> oldCMList, Map<Id, Change_Management__c> oldCMMap) {
        try{
            Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = Component_Handler.getRiskPriorityGrid();
            For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c FROM Risk_Lookup__c LIMIT 1000]) {
                Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
            }

            
            ///////////////////////////
            set<id> cmtaskIds=new set<id>();
            List<Change_Management__c> insertList=new List<Change_Management__c>();
            Map<id,Change_Management__c> newMap=new Map<id,Change_Management__c>();
            set<id> ParentOwnerUpdates=new set<id>();
            
            for(Change_Management__c CM:newCMList) {
                system.debug('cmlist value....' +newCMList);
                system.debug('cmlist value....' +string.valueOf(CM.Document_Number__c)+'=='+string.valueOf(Document_profile__c.getSObjectType()));
                string dcid=CM.Document_Number__c;
                if((dcid.length() == 15 || dcid.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', dcid)) {      
                    if(dcid.startswith(Document_profile__c.SObjectType.getDescribe().getKeyPrefix())){
                    id tempCM=CM.Document_Number__c;             
                    system.debug('cmlist value...sObjectType.' +tempCM.getSObjectType());
                    if(tempCM.getSObjectType()==Document_profile__c.getSObjectType()){                      
                    CM.Document_Profile__c=CM.Document_Number__c;
                    }              
                    }
                }

                if(CM.id!=null){
                    
                    
                        if(CM.ChangeFieldApprovalStatus__c=='Approved'&&oldCMMap.get(CM.id).ChangeFieldApprovalStatus__c=='Pending Approval'){
                            CM.OwnerId=CM.New_Owner__c;
                            CM.New_Owner__c=null;
                        }   
                        else if(CM.ChangeFieldApprovalStatus__c=='Rejected'||CM.ChangeFieldApprovalStatus__c=='Recall'){
                            CM.New_Owner__c=null;
                        }   
                    
                    
                    newMap.put(CM.id, CM);    
                }
                else{
                    insertList.add(CM);
                }
            }       
            cmtaskIds.addAll(newMap.keySet());
            List<Change_Management__c> crtasks;
            
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,Sequence__c,Sequence_Position__c,Status__c,Phase__c,Resolution_Code__c');        
            if(queryFieldNames != null && queryFieldNames != ''){            
                crtasks = database.query('Select '+ queryFieldNames +' from Change_Management__c where id NOT IN:cmtaskIds');
            }
            
            if(crtasks==null){
                crtasks=new List<Change_Management__c>();
            }      
            
            crtasks.addAll(newCMList);                   
            
            CMTaskBeforeUpdate(newMap,oldCMMap,crtasks); 
            CMTaskBeforeinsert(insertList,ParentOwnerUpdates); 
            ////////////////////////////
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.cm);
        }       
    }
    //for approval process
    @future
    public static void CRTASKSubmitForApproval(List<id> Objectids,Map<id,id> Userid) {
        system.debug('Objectids' +Objectids);
        List<Approval.ProcessSubmitRequest> LSTprocess=new List<Approval.ProcessSubmitRequest>();
        for(id Objectid:Objectids){
            Approval.ProcessSubmitRequest REQ = new Approval.ProcessSubmitRequest();
            REQ.setComments('Automate Approval Process');
            REQ.setObjectId(Objectid);
            REQ.setSubmitterId(Userid.get(Objectid));
            LSTprocess.add(REQ);      
        }
        List<Approval.ProcessResult> RES = Approval.process(LSTprocess);
    } 
    
    //Logic for capturing the changeManagement workflow resolution status based on current status of record
    
    public static void CMTaskUpdateParent(set<id> parentids,set<id> ChangeManagementWorkflowStatus){
        if(!parentids.isEmpty()||!ChangeManagementWorkflowStatus.isEmpty()){
            parentids.addAll(ChangeManagementWorkflowStatus);
            
            String queryFieldNamesCM = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,Status__c,Resolution_Code__c');
            if(queryFieldNamesCM != null && queryFieldNamesCM != ''){
                List<Change_Management__c> cms= database.query('Select '+ queryFieldNamesCM +' from Change_Management__c where id IN : parentids'); 
                
                if(!cms.isEmpty()){
                    for(Change_Management__c cm:cms){
                        if(ChangeManagementWorkflowStatus.contains(cm.id)){                         
                            cm.Resolution_Code__c ='Document Change Order';
                        }
                        
                        else{                          
                           // cm.Status__c='Closed';
                            cm.Resolution_Code__c =  'No Action Required';
                        }
                    }
                    upsert cms;    
                }
            }           
        }            
    } 
    
    public static void CMTaskBeforeinsert(List<Change_Management__c> gtsinsert,set<id> ncs){
        
        if(!ncs.isEmpty()){
            
            String queryFieldNamesNc = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c', 'id,ownerid,');
            if(queryFieldNamesNc != null && queryFieldNamesNc != ''){
                
                List<Change_Management__c> nccs= database.query('Select '+ queryFieldNamesNc +' from Change_Management__c where id IN:ncs');  
                if(!nccs.isEmpty()){
                    
                    Map<id,Change_Management__c> ncMap=new Map<id,Change_Management__c>(nccs);
                    for(Change_Management__c gt:gtsinsert){
                        // gt.ParentOwner__c=ncMap.get(gt.Change_Management__c).ownerid;
                    }                            
                }             
            }            
        }                    
        
    }   
    
    //Process Instance
    
    private static Map<id,ProcessInstance> processInstancesmap;
    private static void GeneralTaskApprovalComments(List<Change_Management__c> gts){
        set<id> Objectids=new set<id>();
        for(Change_Management__c gt:gts){
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
                for(Change_Management__c gt:gts){
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
    
    
    
    Public static void CMTaskBeforeUpdate(Map<id,Change_Management__c> newMap, Map<id,Change_Management__c> oldMap,List<Change_Management__c> crtasks){                      
        
        CMTaskStatusUpdate(newMap.values(),oldMap,crtasks);
    }  
    
    
    public static void CMTaskStatusUpdate(List<Change_Management__c> gts, Map<id,Change_Management__c> oldMap,List<Change_Management__c> crtasks){
        
        list<Change_Management__c> updateStatusFormSecquence=new list<Change_Management__c>(); //Defined for checking next phase 
        list<Change_Management__c> getSubmitApproval=new list<Change_Management__c>();   
        Change_Management__c Oldgt;
        set<id> Parentidset=new set<id>();
        
        for(Change_Management__c gt:gts){
            
            Oldgt=oldMap.get(gt.id);
            if(Oldgt.ChangeFieldApprovalStatus__c=='Pending Approval'){       
                
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
                }
                else if(gt.ChangeFieldApprovalStatus__c=='Recall'){
                    gt.New_Due_Date__c=null;
                    gt.New_Owner__c=null;
                    gt.Note_To_Approver_Owner_DueDate__c=null;
                }
            }
            
            system.debug('before if '+OldGT.Status__c+''+GT.isLocked__c+''+OldGT.isLocked__c+''+GT.CurrentApprovalSequenceNumber__c+' '+GT.CurrentApprovalSequenceNumber__c);
            if(OldGT.Status__c=='Pending Approval'&&GT.isLocked__c==false&&OldGT.isLocked__c==true&& !(GT.CurrentApprovalSequenceNumber__c==99999||GT.CurrentApprovalSequenceNumber__c==999999)){
                
                system.debug('in side Pending Approval GT.CurrentApprovalSequenceNumber__c'+getSubmitApproval);
                getSubmitApproval.add(gt);                                                            
                system.debug('in side Pending Approval'+getSubmitApproval);
            }   
        }
        
        if(!getSubmitApproval.isEmpty()){
            system.debug('getSubmitApproval'+getSubmitApproval);
            
            CRTaskSubmitForApprovalProcess(getSubmitApproval,false);      //For checking Sequential Approval Process   
        }
        
        
        
        
        //Begin -code for updateNextPhase
        
        for(Change_Management__c gt:gts){
            Oldgt=oldMap.get(gt.id);
            system.debug('inside before check OldGT.Status__c'+OldGT.Status__c+' GT.Status__c '+GT.Status__c);
            
            if((OldGT.Status__c!='Closed'&&GT.Status__c=='Closed')||(OldGT.Status__c=='Open'&&GT.Status__c=='Closed')){
                system.debug('inside before updateStatusFormSecquence');
                updateStatusFormSecquence.add(GT);
            }     
            
        }
        
        set<id> CMWorkFlowStatusInReview=new set<id>();
        if(!Parentidset.isEmpty()||!CMWorkFlowStatusInReview.isEmpty()){
            system.debug('inside  chack Parentidset'+Parentidset+'CMWorkFlowStatusInReview'+CMWorkFlowStatusInReview);
            CMTaskUpdateParent(Parentidset,CMWorkFlowStatusInReview);//closing NC based on Closure without Approval Last method of before Update
        }
    }
    
    //Approval Process Submission
    
    public static void CRTaskSubmitForApprovalProcess(List<Change_Management__c> CMs,Boolean initialSubmitter){
        List<id> approveObjids=new List<id>();
        map<id,id> approveObjidsSub=new map<id,id>();
        id submitter;
        set<id> cmids=new set<id>();            
        list<id> Approvers= new list<id>();
        Set<Id> CRIds = (new Map<Id,SObject>(CMs)).keySet();
        Decimal current;
        boolean flag;
        id CMTaskid;
        list<Approver__c> cmApprovers;
        list<Approver__c> tempApprovers;
        map<id,List<Approver__c>> genApproversMap=new map<id,List<Approver__c>>();
        system.debug('cmids'+cmids);
        //=========retriving approvers for assiging next sequence approval process  
        String queryFieldSOfAP = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Sequence_Position__c,Change_Management__c,User__c');     
        if(queryFieldSOfAP!=null&&queryFieldSOfAP!=''){
            cmApprovers=database.query('Select '+ queryFieldSOfAP +' from Approver__c where Change_Management__c IN: CRIds');  
            
            for(Change_Management__c CT:CMs){                      
                tempApprovers=new list<Approver__c>();
                for(Approver__c apprs:cmApprovers){
                    if(apprs.Change_Management__c==CT.id){
                        tempApprovers.add(apprs);
                    }
                }
                genApproversMap.put(CT.id,tempApprovers);
            }
        }
        
        
        for(Change_Management__c GT:CMs){
            
            if(GT.CurrentApprovalSequenceNumber__c==null){
                GT.CurrentApprovalSequenceNumber__c=0;
            }
            current=GT.CurrentApprovalSequenceNumber__c;
            flag=false;
            CMTaskid=gt.id;                 
            for(Approver__c appr:genApproversMap.get(CMTaskid)){           
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
            
            if(current==GT.CurrentApprovalSequenceNumber__c){           
                current=current+1000; 
            }
            integer len=Approvers.size();
            system.debug(flag+'flag after Sequence_Position__c current'+current);
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
                
            }
            if(Approvers.isEmpty()){               
                GT.Approver_process_complete__c=true;
                
                
                if(( GT.Resolution_Code__c=='Document Change Order' ) ) {
                   // GT.Status__c='Document Change Order'; 
                    GT.Status__c='Open';
                    GT.Phase__c='Workflow';
                    
                }         
                else if((GT.Resolution_Code__c=='No Action Required' )) {
                    
                    GT.Status__c='Closed'; 
                    GT.Phase__c='Workflow';
                }
                else{
                    GT.Phase__c='Workflow';
                   // GT.Status__c='Document Change Order';
                }   
                
            }
            
            Approvers.clear();
            
        }
        if(!approveObjids.isEmpty())
            CRTASKSubmitForApproval(approveObjids,approveObjidsSub);        
    }
    //////////////////////////
    public static void ChangeManagement_AfterTrigger(Map<id,Change_Management__c> newMap,Map<id,Change_Management__c> oldMap,boolean isInsert,boolean IsUpdate){
        try{
            
            //for Approvalprocess
            List<Change_Management__c> chlist=newMap.values();
            set<Id> chlistid=new set<Id>();
            
            if(chlist!=null) {
                for(Change_Management__c chmg:chlist) {
                    if(chmg.Approver_process_complete__c==true && chmg.Status__c=='Pending Approval') 
                    {
                        chlistid.add(chmg.Id);
                    }
                }            
            }
            // Approvalprocess
            system.debug('inside after trigger '+newMap);
            rt_Map = Change_Management__c.sObjectType.getDescribe().getRecordTypeInfosById();    
            Map<id,Change_Management__c> afterupdateMap=new Map<id,Change_Management__c>();
            //========================================================update/insert
            system.debug('oldMap');
            if(oldMap==null){
                system.debug('inside after trigger oldMap'+oldMap); 
                oldMap=new Map<id,Change_Management__c>(); 
            }  
            Map<id,Change_Management__c> afterinsertMap=new Map<id,Change_Management__c>();
            for(Change_Management__c gt:newMap.values()){
                if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                    afterinsertMap.put(gt.id,gt) ; 
                }
                else{
                    afterupdateMap.put(gt.id,gt) ; 
                }
            }
            cmhisList=new List<Change_Management_History__c>();
            system.debug(' before afterinsertMap');
            afterinsert(afterinsertMap);
            system.debug('after afterinsertMap');
            system.debug('after afterinsertMap cmhisList'+cmhisList);
            FieldHistoryTracking(afterupdateMap,oldMap);   
            system.debug('after FieldHistoryTracking');
            system.debug('after FieldHistoryTracking cmhisList'+cmhisList);
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
                insert cmhisList;
            }
            system.debug('after FieldHistoryTracking cmhisList'+cmhisList);
            
            changeManagement_IsAfter_UpdateGeneralTaskOwner(newMap,oldMap);
        }catch(Exception ex){
            System.debug('Exception In cmTriggerHandler.afterTrigger     '+ex.getMessage());
        } 
    }
    
    public static void FieldHistoryTracking(Map<id,Change_Management__c> newMap,Map<id,Change_Management__c> oldMap){
        try{
            Map<String, Schema.SObjectField> CM_Lable =Schema.SObjectType.Change_Management__c.fields.getMap();
            system.debug('CM_LableCM_Lable'+CM_Lable); 
            String qry;
            String queryFieldNames; 
            String Prefix =  QC_custom_settings.getPrefix();
            
            if(Prefix!=null){
                Prefix+='__';
            }else{
                Prefix='';
            }
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
            system.debug('inside field history tracking cmhisList'+cmhisList);
            if(cmhisList==null||cmhisList.isEmpty()){
                system.debug('inside field history tracking if cmhisList'+cmhisList);
                cmhisList = new List<Change_Management_History__c>();    
            }        
            
            Change_Management_History__c cmhis;
            string fieldApiname;
            id temp;
            string tempstore;            
            Set<string> fieldsetNames=new Set<string>(); 
            Set<string> CMfieldsetNames=new Set<string>(); 
            
            final List<Schema.FieldSetMember> trackedFields = SObjectType.Change_Management__c.FieldSets.ResolutionFields.getFields();
            system.debug('trackedFields'+trackedFields);        
            for(Schema.FieldSetMember feildname:trackedFields){
                fieldsetNames.add(feildname.getFieldPath());
            }     
            final List<Schema.FieldSetMember> trackedcmFields = SObjectType.Change_Management__c.FieldSets.Change_Management_Fields.getFields(); 
            
            
            
            system.debug('trackedcmFields'+trackedcmFields);        
            for(Schema.FieldSetMember feildname:trackedcmFields){
                CMfieldsetNames.add(feildname.getFieldPath());
            }
            set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
            
            for(Change_Management__c cm:newMap.values()){ 
                final Change_Management__c oldCM = oldmap.get(cm.Id);    
                Boolean resolution;                
                for(Schema.SObjectField feildname:Schema.SObjectType.Change_Management__c.fields.getMap().values()){
                    resolution=true;
                    fieldApiname=string.valueOf(feildname);
                    if(CMfieldsetNames.contains(fieldApiname)){ 
                        if(cm.get(fieldApiname)!=oldCM.get(fieldApiname)){
                            cmhis=new Change_Management_History__c();
                            if(CM_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                                cmhis.FieldName__c=CM_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                            }
                            else{
                                cmhis.FieldName__c=CM_Lable.get(fieldApiname).getDescribe().getLabel(); 
                            }
                            //cmhis.FieldName__c=CM_Lable.get(fieldApiname).getDescribe().getLabel();
                            cmhis.FieldApiName__c=fieldApiname;
                            System.debug('PicklistValue '+feildname.getDescribe().getPickListValues());
                            if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE' && (fieldApiname!=(Prefix+'Impacted_Sites__c')&&fieldApiname!=(Prefix+'Document_Number__c'))){
                                System.debug('cm Sarath samsung5'+fieldApiname);
                                if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                    if(oldCM.get(fieldApiname)!=null){
                                        mydate=date.valueOf(oldCM.get(fieldApiname));
                                        cmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                    }                                            
                                    if(cm.get(fieldApiname)!=null){
                                        mydate=date.valueOf(cm.get(fieldApiname));
                                        cmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                    }
                                    
                                }else{
                                    cmhis.oldValue__c=string.valueOf(oldCM.get(fieldApiname));
                                    cmhis.NewValue__c=string.valueOf(cm.get(fieldApiname));
                                    
                                }
                                cmhis.Sub_Parent__c='Init';
                                cmhis.Parent__c=cm.id;
                                cmhis.object__c='Change_Management__c';
                                cmhisList.add(cmhis);   
                                //resolution=false; 
                                System.debug('cmhisList'+cmhisList);
                            }
                            /////////////////////////////////////////////////////
                             if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE' && (fieldApiname==(Prefix+'Impacted_Sites__c')|| fieldApiname==(Prefix+'Document_Number__c'))){  
                                    system.debug('string. inside after reference');
                                    
                                    cmhis=new Change_Management_History__c();
                                    cmhis.FieldName__c=CM_Lable.get(fieldApiname).getDescribe().getLabel();
                                    cmhis.FieldApiName__c=fieldApiname; 
                                        system.debug('inside '+manufacturingSite);
                                        if(fieldApiname==Prefix+'Impacted_Sites__c'){
                                              if(manufacturingSite==null){
                                                    manufacturingSite=new Map<id,Manufacturing_Site__c>(); 
                                                    queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Manufacturing_Site__c', 'id,Name');            
                                                    if(queryFieldNames != null && queryFieldNames != '')
                                                    {
                                                        qry='select ' + queryFieldNames + ' FROM Manufacturing_Site__c Limit 1000';
                                                        LIST<Manufacturing_Site__c> ulist=database.query (qry);
                                                        manufacturingSite.putAll(ulist);                
                                                    }           
                                                }                                        
                                                
                                                System.debug('TEMPSTORE:string.valueOf'+string.valueOf(oldCM.get(fieldApiname)));
                                            if(oldCM.get(fieldApiname)!=null){
                                                System.debug('TEMPSTORE:string.valueOf 2'+oldCM.get(fieldApiname));
                                                if((!(string.valueOf(oldCM.get(fieldApiname))==''||string.valueOf(oldCM.get(fieldApiname))==null)&&!manufacturingSite.isEmpty()))
                                                cmhis.oldValue__c='';
                                                    for(string Imps:string.valueOf(oldCM.get(fieldApiname)).split(',')){
                                                    cmhis.oldValue__c+=manufacturingSite.get(Imps).Name+',';    
                                                    }
                                            }
                                                System.debug('TEMPSTORE:string.valueOf2'+string.valueOf(cm.get(fieldApiname)));    
                                                System.debug('TEMPSTORE:string.valueOf3'+oldCM.get(fieldApiname));  
                                            if(cm.get(fieldApiname)!=null){
                                                if((!(string.valueOf(cm.get(fieldApiname))==''||string.valueOf(cm.get(fieldApiname))==null))&&!manufacturingSite.isEmpty())
                                                    cmhis.NewValue__c='';
                                                    for(string Imps:string.valueOf(cm.get(fieldApiname)).split(',')){
                                                        System.debug('manufacturingSite.get(Imps).Name'+manufacturingSite.get(Imps).Name);
                                                    cmhis.NewValue__c+=manufacturingSite.get(Imps).Name+',';     
                                                    }   
                                                    
                                                    cmhis.newValue__c.removeEnd(',');
                                            }
                                                cmhis.Sub_Parent__c='Init';
                                                cmhis.Parent__c=cm.id;
                                                cmhis.object__c='Change_Management__c';
                                                cmhisList.add(cmhis);  
                                            }
                                            //////////////
                                 			if(fieldApiname==Prefix+'Document_Number__c'){
                                                system.debug('inside Document_Number__c1'+fieldApiname);
                                                if(DocumentNumber==null){
                                                    system.debug('inside Document_Number__c2'+DocumentNumber);
                                                    DocumentNumber=new Map<id,Document_Profile__c>(); 
                                                    queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'id,Name');            
                                                    if(queryFieldNames != null && queryFieldNames != '')
                                                    {
                                                        qry='select ' + queryFieldNames + ' FROM Document_Profile__c Limit 1000';
                                                        LIST<Document_Profile__c> ulist=database.query (qry);
                                                        DocumentNumber.putAll(ulist);                
                                                    }           
                                                }                                        
                                                
                                                System.debug('TEMPSTORE:string.valueOf'+string.valueOf(oldCM.get(fieldApiname)));
                                                
                                                string dcid=(string.valueOf(oldCM.get(fieldApiname))!=null)?(string.valueOf(oldCM.get(fieldApiname))):'';
                                                system.debug('===dcid.length()=='+dcid.length());
                                                if((dcid.length() == 15 || dcid.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', dcid)) {       
                                                    if(dcid.startswith(Document_profile__c.SObjectType.getDescribe().getKeyPrefix())){
                                                        id tempCM=oldCM.Document_Number__c;             
                                                        system.debug('cmlist value...sObjectType.' +tempCM.getSObjectType());
                                                        if(tempCM.getSObjectType()==Document_profile__c.getSObjectType()){                      
                                                            
                                                            if(oldCM.get(fieldApiname)!=null){
                                                                System.debug('TEMPSTORE:string.valueOf 2'+oldCM.get(fieldApiname));
                                                                if((!(string.valueOf(oldCM.get(fieldApiname))==''||string.valueOf(oldCM.get(fieldApiname))==null)&&!DocumentNumber.isEmpty()))
                                                                    cmhis.oldValue__c='';
                                                                cmhis.oldValue__c=DocumentNumber.get(string.valueOf(oldCM.get(fieldApiname))).Name;
                                                            }                                                                                                                                                          
                                                        }              
                                                    }
                                                }    
                                                else{
                                                    cmhis.oldValue__c=string.valueOf(oldCM.get(fieldApiname));                                                
                                                }
                                                dcid=string.valueOf(cm.get(fieldApiname));
                                                if((dcid.length() == 15 || dcid.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', dcid)) {      
                                                    if(dcid.startswith(Document_profile__c.SObjectType.getDescribe().getKeyPrefix())){
                                                        id tempCM=CM.Document_Number__c;             
                                                        system.debug('cmlist value...sObjectType.' +tempCM.getSObjectType());
                                                        if(tempCM.getSObjectType()==Document_profile__c.getSObjectType()){  
                                                            if((!(string.valueOf(cm.get(fieldApiname))==''||string.valueOf(cm.get(fieldApiname))==null))&&!DocumentNumber.isEmpty())
                                                                cmhis.NewValue__c='';
                                                            cmhis.NewValue__c=DocumentNumber.get(string.valueOf(cm.get(fieldApiname))).Name;
                                                            //cmhis.newValue__c.removeEnd(',');  
                                                        }
                                                    }
                                                }else{
                                                    cmhis.newValue__c=string.valueOf(cm.get(fieldApiname));                                                                                                    
                                                }
                                                
                                                cmhis.Sub_Parent__c='Init';
                                                cmhis.Parent__c=cm.id;
                                                cmhis.object__c='Change_Management__c';
                                                cmhisList.add(cmhis);  
                                            }
                                 ///////////////////////////////////
                                        }
                            ////////////////////
                            else
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                    System.debug('cm 2');
                                    cmhis=new Change_Management_History__c();
                                    temp=string.valueOf(cm.get(fieldApiname));   
                                    cmhis.FieldName__c=CM_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                                    if(temp.getSObjectType().getDescribe().getName()=='User'&&(fieldApiname=='Reported_By__c'||fieldApiname=='Approver__c')){
                                        //
                                        if(User==null){
                                            User=new Map<id,User>();
                                            queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'id,Name');            
                                            if(queryFieldNames != null && queryFieldNames != '')
                                            {
                                                qry='select ' + queryFieldNames + ' FROM user';
                                                LIST<USER> ulist=database.query (qry);
                                                User.putAll(ulist);                
                                            }    
                                        }                                                                                        
                                        //
                                        tempstore=string.valueOf(oldCM.get(fieldApiname));
                                        if(!(tempstore==''||tempstore==null))
                                            cmhis.oldValue__c=User.get(string.valueOf(oldCM.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(cm.get(fieldApiname));
                                        if(!(tempstore==''||tempstore==null))
                                            cmhis.NewValue__c=User.get(string.valueOf(cm.get(fieldApiname))).Name;   
                                        cmhis.Sub_Parent__c='Init';
                                        cmhis.Parent__c=cm.id;
                                        cmhis.object__c='Change_Management__c';                                           
                                        cmhisList.add(cmhis); 
                                        system.debug('inside cm record');
                                    }
                                }
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){  
                                    system.debug('string. inside after reference');
                                    
                                    cmhis=new Change_Management_History__c();
                                    cmhis.FieldName__c=CM_Lable.get(fieldApiname).getDescribe().getLabel();
                                    cmhis.FieldApiName__c=fieldApiname;                                        
                                    temp=string.valueOf(cm.get(fieldApiname));                                    
                                    if(null!=string.valueOf(cm.get(fieldApiname)))
                                        System.debug('ChangeManagementTriggerHandler.1'+temp.getSObjectType().getDescribe().getName());
                                        if(temp.getSObjectType().getDescribe().getName()=='Risk_Priority__c'){
                                            System.debug('ChangeManagementTriggerHandler.2'+temp.getSObjectType().getDescribe().getName());                  
                                            if(RiskPriority==null){
                                                RiskPriority=new Map<id,Risk_Priority__c>(); 
                                                queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Priority__c', 'id,Name');            
                                                if(queryFieldNames != null && queryFieldNames != '')
                                                {
                                                    qry='select ' + queryFieldNames + ' FROM Risk_Priority__c';
                                                    LIST<Risk_Priority__c> ulist=database.query (qry);
                                                    RiskPriority.putAll(ulist);                
                                                }           
                                            }                                        
                                            //
                                            
                                            
                                            
                                            tempstore=string.valueOf(oldCM.get(fieldApiname));
                                            if((!(tempstore==''||tempstore==null)&&!RiskPriority.isEmpty()))
                                                cmhis.oldValue__c=RiskPriority.get(string.valueOf(oldCM.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(cm.get(fieldApiname));
                                            if((!(tempstore==''||tempstore==null))&&!RiskPriority.isEmpty())
                                                cmhis.NewValue__c=RiskPriority.get(string.valueOf(cm.get(fieldApiname))).Name;   
                                            cmhis.Sub_Parent__c='Init';
                                            cmhis.Parent__c=cm.id;
                                            cmhis.object__c='Change_Management__c';
                                            cmhisList.add(cmhis);  
                                        }
                                    System.debug('ChangeManagementTriggerHandler.RiskSeverity1'+temp.getSObjectType().getDescribe().getName());
                                    if(temp.getSObjectType().getDescribe().getName()=='Risk_Severity__c'){
                                        //
                                        System.debug('ChangeManagementTriggerHandler.RiskSeverity2'+temp.getSObjectType().getDescribe().getName());
                                        if(RiskSeverity==null){
                                            System.debug('ChangeManagementTriggerHandler.RiskSeverity5');
                                            RiskSeverity=new Map<id,Risk_Severity__c>();   
                                            queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Risk_Severity__c', 'id,Name');            
                                            if(queryFieldNames != null && queryFieldNames != '')
                                            {
                                                qry='select ' + queryFieldNames + ' FROM Risk_Severity__c';
                                                LIST<Risk_Severity__c> ulist=database.query (qry);
                                                RiskSeverity.putAll(ulist);                
                                            }
                                        }                                        
                                        
                                        //
                                        tempstore=string.valueOf(oldCM.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                            cmhis.oldValue__c=RiskSeverity.get(string.valueOf(oldCM.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(cm.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                            cmhis.NewValue__c=RiskSeverity.get(string.valueOf(cm.get(fieldApiname))).Name;   
                                        cmhis.Sub_Parent__c='Init';
                                        cmhis.Parent__c=cm.id;
                                        cmhis.object__c='Change_Management__c'; 
                                        cmhisList.add(cmhis);  
                                    } 
                                }
                        }
                    }
                    if(cm.get(fieldApiname)!=oldCM.get(fieldApiname)){
                        system.debug('celkon'+fieldApiname+'fieldsetNames'+fieldsetNames);
                        if(fieldsetNames.contains(fieldApiname)){ 
                            system.debug('celkon1'+fieldApiname);
                            if(cm.get(fieldApiname)!=oldCM.get(fieldApiname)){
                                system.debug('inside cm.get(fieldApiname)!=oldCM.get(fieldApiname) field history tracking'+fieldApiname);
                                cmhis=new Change_Management_History__c();
                                cmhis.FieldName__c=CM_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();                                                                
                                cmhis.FieldApiName__c=fieldApiname;                                
                                if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                    if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                        if(oldCM.get(fieldApiname)!=null){
                                            mydate=date.valueOf(oldCM.get(fieldApiname));
                                            cmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                        }                                            
                                        if(cm.get(fieldApiname)!=null){
                                            mydate=date.valueOf(cm.get(fieldApiname));
                                            cmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                        }
                                        
                                    }else{
                                        cmhis.oldValue__c=string.valueOf(oldCM.get(fieldApiname));
                                        cmhis.NewValue__c=string.valueOf(cm.get(fieldApiname));
                                        
                                    }
                                    cmhis.Sub_Parent__c='Resolution';
                                    cmhis.Parent__c=cm.id;
                                    cmhis.object__c='Change_Management__c';
                                    cmhisList.add(cmhis);                        
                                }
                            }
                            
                        }
                    }
                    
                }
            }
        }catch(Exception ex){
            System.debug('Exception In cmTriggerHandler.FieldHistoryTracking     '+ex.getMessage());
        }
    }
    
    public static void afterinsert(Map<id,Change_Management__c> cms){
        if(cmhisList==null||!cmhisList.isEmpty()){
            cmhisList = new List<Change_Management_History__c>();    
        }
        
        map<id,Change_Management__c> insertOldMap=new map<id,Change_Management__c>();
        Change_Management_History__c cmhis;
        for(Change_Management__c cm:cms.values()){
            insertOldMap.put(cm.id,new Change_Management__c());
            cmhis=new Change_Management_History__c(); 
            cmhis.Parent__c=cm.id;
            cmhis.isCreated__c=true; 
            cmhis.FieldName__c='Change Management';
            cmhis.object__c='Change_Management__c';
            cmhisList.add(cmhis);
        } 
        system.debug('inside after trigger in cm record'+cmhisList);
        
        FieldHistoryTracking(cms,insertOldMap);  
        for(Change_Management_History__c cmh:cmhisList){
            cmh.isCreated__c=true;
        }
        
    }
    
    public static void changeManagement_IsAfter_UpdateGeneralTaskOwner(Map<id,Change_Management__c> updateChangeManagementMap,Map<id,Change_Management__c> oldMap){
        set<id> cmids=new set<id>();
        for(Change_Management__c cm:updateChangeManagementMap.values()){            
            if(oldMap!=null&&oldMap.get(cm.id)!=null){
                if(cm.Ownerid!=oldMap.get(cm.id).Ownerid){
                    cmids.add(cm.id);
                }    
            }
            
        }
        if(!cmids.isEmpty()){
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Change_Management__c,Owner__c,');
            if(queryFieldNames!=null||queryFieldNames!=''){
                system.debug('inside updateGeneralTaskOwner before query');
                List<General_Task__c> gts=database.query('Select  '+ queryFieldNames +' From General_Task__c where Change_Management__c IN:cmids');
                system.debug('inside updateGeneralTaskOwner after query');
                for(General_Task__c gt:gts){
                    system.debug('inside updateGeneralTaskOwner before update inside for gts'+gt.Owner__c);
                    gt.ParentOwner__c=updateChangeManagementMap.get(gt.Change_Management__c).ownerid;
                    system.debug('inside updateGeneralTaskOwner before update gts inside for'+gt.Owner__c);
                }
                if(!gts.isEmpty())
                {
                    system.debug('inside updateGeneralTaskOwner before update gts');
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','ParentOwner__c','update'))
                    {
                        update gts;
                    }
                    system.debug('inside updateGeneralTaskOwner after update gts');
                }
            }            
        }
        
    }
}