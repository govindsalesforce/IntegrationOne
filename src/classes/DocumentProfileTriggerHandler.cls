/*
v1.1   Qualityze Inc(BK)       25-AUG-2016      Document Flow
v1.2   Qualityze Inc(BK)       25-AUG-2016      Recall
*/
public class DocumentProfileTriggerHandler {
    
    public static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public static List<Document_Profile_History__c> dphisList;
    public static List<Change_Management_History__c> cmhisList;
    public static Map<integer,string> dateMap;
    public static Map<id,User> User;
    public static Map<id,Manufacturing_Site__c> manufacturingSite;
    
    
    //----Before trigger--start
        @future
    public static void SubmitForApprovalProcess(List<id> Objectids,map<id,id> Userid){
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
    // number scheme by balu
    
        public static void DocumentProfile_BeforeInsertTrigger(List<Document_Profile__c> docList){
            List<document_type__c> dtlist=new List<document_type__c>();
            set<id> dtids=new set<id>();
            set<id> nsids=new set<id>();
            for(Document_Profile__c dp:docList){
                dtids.add(dp.document_type__c);
                
            }
            list<Number_Scheme__c> NSlist;
            Map<id,document_type__c> DTMap;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'id,Number_Scheme__c');        
            if(queryFieldNames != null && queryFieldNames != ''){                 
                dtlist = database.query('Select '+ queryFieldNames +' from Document_Type__c where id IN:dtids ');
                DTMap=new Map<id,document_type__c>(dtlist); 
            }         
            for(document_type__c dt:dtlist){
                nsids.add(dt.Number_Scheme__c);
            }
            Map<id,Number_Scheme__c> NSMap ;
            Number_Scheme__c defaultNumberScheme;
            queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Number_Scheme__c', 'id,Number_format__c ,Prefix__c,Suffix__c,Revision__c,MAXNUMBER__c ');        
            if(queryFieldNames != null && queryFieldNames != ''){ 
                NSlist= database.query('Select '+ queryFieldNames +' from Number_Scheme__c  where id IN:nsids');
                NSMap =new Map<id,Number_Scheme__c>(NSlist);            
                string docName='Default Document Number';
                defaultNumberScheme=database.query('Select '+ queryFieldNames +' from Number_Scheme__c  where Name =: docName limit 1');
                if(defaultNumberScheme==null){
                        List<Number_scheme__c> numberScheme = new List<Number_scheme__c>();
                        Number_scheme__c NS = new Number_scheme__c (Name = 'Default Document Number', Number_format__c = '000001',Prefix__c = 'DOC',Revision__c='1',Suffix__c='YYYY',Module__c='Document');
                        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Number_scheme__c','Number_format__c,Prefix__c,Revision__c,Suffix__c,Module__c','create')){
                            insert NS;    
                        }    
                        defaultNumberScheme=NS;            
                }
            }   
            for(Document_Profile__c dp:docList){
                if(dp.document_type__c!=null&&DTMap.containsKey(dp.document_type__c)&&DTMap.get(dp.document_type__c).Number_Scheme__c!=null){
                    system.debug('inside if condition baluuu'+dp.name);
                    if(dp.Name==null){
                    system.debug('inside if condition baluuu');
                        if(NSMap.containsKey(DTMap.get(dp.document_type__c).Number_Scheme__c )){
                            if(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c ).Prefix__c!=''){
                                dp.Name=NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c ).Prefix__c+'-';
                            } 
                            if(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Number_format__c!=null){
                            
                                if((NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c)==NULL){
                                    NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c=integer.valueof(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Number_format__c);
                                }
                                if((NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c)!=NULL){
                                ++NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c;
                                    string formate=string.valueOf(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Number_format__c);
                                    string formateMax=string.valueOf(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c);
                                    system.debug('formate'+formate);
                                    system.debug('formateMax'+formateMax);
                                    system.debug('formateMax'+formateMax.length());
                                    system.debug('formate'+formate.length());
                                    system.debug('formate==='+(formate.length()-formateMax.length()));                                                                                                                                                
                                    integer len=formate.length()-formateMax.length();
                                    if((len)>0){
                                    system.debug('formate after fi'+formate.length());                                        
                                        for(integer i=0;i<=len;i++){
                                            dp.Name+='0';            
                                        }
                                    }
                                    dp.Name+=string.valueOf(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).MAXNUMBER__c);
                                    
                                }
                            } 
                            if(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Suffix__c!=''){
                            
                                if(NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Suffix__c=='YYYY'||NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Suffix__c=='yyyy'){
                                dp.Name+='-'+string.Valueof(System.Today().year());
                                }else{
                                dp.Name+='-'+NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Suffix__c;
                                }
                                 dp.Current_Rev__c=NSMap.get(DTMap.get(dp.document_type__c).Number_Scheme__c).Revision__c;
                            }
                           
                        }
                    }
                }else if(dp.Name==null){
                    system.debug('inside if condition baluuu');

                            if(defaultNumberScheme.Prefix__c!=''){
                                dp.Name=defaultNumberScheme.Prefix__c+'-';
                            } 
                            if(defaultNumberScheme.Number_format__c!=null){
                            
                                if((defaultNumberScheme.MAXNUMBER__c)==NULL){
                                    defaultNumberScheme.MAXNUMBER__c=integer.valueof(defaultNumberScheme.Number_format__c);
                                }
                                if((defaultNumberScheme.MAXNUMBER__c)!=NULL){
                                ++defaultNumberScheme.MAXNUMBER__c;                                
                                    string formate=string.valueOf(defaultNumberScheme.Number_format__c);
                                    string formateMax=string.valueOf(defaultNumberScheme.MAXNUMBER__c);
                                    system.debug('formate'+formate);
                                    system.debug('formateMax'+formateMax);
                                    system.debug('formateMax'+formateMax.length());
                                    system.debug('formate'+formate.length());
                                    system.debug('formate==='+(formate.length()-formateMax.length()));                                                                                                                                                
                                    integer len=formate.length()-formateMax.length();
                                    if((len)>0){
                                    system.debug('formate after fi'+formate.length());                                        
                                        for(integer i=0;i<len;i++){
                                            dp.Name+='0';            
                                        }
                                    }
                                    dp.Name+=string.valueOf(defaultNumberScheme.MAXNUMBER__c);
                                    
                                }
                            } 
                            if(defaultNumberScheme.Suffix__c!=''){
                                if(defaultNumberScheme.Suffix__c=='YYYY'||defaultNumberScheme.Suffix__c=='yyyy'){
                                dp.Name+='-'+string.Valueof(System.Today().year());
                                }else{
                                dp.Name+='-'+defaultNumberScheme.Suffix__c;
                                }
                            }
                            dp.Current_Rev__c=defaultNumberScheme.Revision__c;
                        
                    }
            }
            NSMap.put(defaultNumberScheme.id,defaultNumberScheme);
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Number_Scheme__c', 'MAXNUMBER__c','update')){
                update NSMap.Values();
            }
        }
    // number scheme by balu
    public static void DocumentProfile_BeforeTrigger(Map<id,Document_Profile__c> newMap, Map<id,Document_Profile__c> oldMap){

        List<Document_Profile__c> SubmiforApprovalDPList=new List<Document_Profile__c>();
        /*---v1.1-- start --*/
        List<General_Task__c> generaltasks;
        set<id> genTaskIds=new set<id>();        
        Map<id,General_Task__c> genMap=new Map<id,General_Task__c>();
        genTaskIds.addAll(newMap.keySet());
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Sequence__c,Sequence_Position__c,status__c,RecordTypeId,RecordType.Name,Add_Effectiveness_verificiation__c,Document_Profile__c');        
        if(queryFieldNames != null && queryFieldNames != ''){                 
            generaltasks = database.query('Select '+ queryFieldNames +' from General_Task__c where Document_Profile__c IN:genTaskIds ');            
        }        
        for(General_Task__c gt:generaltasks){            
            genMap.put(gt.Document_Profile__c,gt);
        }
        /*---v1.1-- end --*/
        for(Document_Profile__c  Dp:newMap.values()){
            //if(((oldMap.get(Dp.id).Approval_Status__c=='Pending Approval'&&Dp.Approval_Status__c=='Pending Approval'&&Dp.isLocked__c==false&&oldMap.get(Dp.id).isLocked__c))||(Dp.Approval_Required__c&&Dp.Submit__c=='Submit'&&oldmap.get(Dp.id).Submit__c!='Submit')){
            if(((oldMap.get(Dp.id).Approval_Status__c=='Pending Approval'&&Dp.Approval_Status__c=='Pending Approval'&&Dp.isLocked__c==false&&oldMap.get(Dp.id).isLocked__c))){
                SubmiforApprovalDPList.add(Dp);
            }
            // updated for change owner start
                if(dp.Approval_Status__c == 'Closed' && dp.Approval_Status__c != OldMap.get(dp.Id).Approval_Status__c) {
                    system.debug('Inside document profile if first');
                    dp.Closed_Date__c = Date.Today();
                }
                if(dp.ApprovalProcess__c!='Document Approval'){
                if(dp.Approval_Status__c=='Approved'&&OldMap.get(dp.id).Approval_Status__c=='Pending Approval'){
                    system.debug('Inside document profile if first change ower');
                    dp.OwnerId=dp.New_Owner__c;
                    dp.New_Owner__c=null;
                }   
                else if(dp.Approval_Status__c=='Rejected'||dp.Approval_Status__c=='Recall'){
                    dp.New_Owner__c=null;
                }
                }
           // updated for change owner end                 
        }
        if(!SubmiforApprovalDPList.isEmpty()){
            DocumentProfileSubmitForApprovalProcess(SubmiforApprovalDPList,true);
        }

        

        List<general_task__c> EffectiveNessReviewTasks=new List<general_task__c>();
        
        Id EffectivenessReviewRecordTypeId = Schema.SObjectType.General_Task__c.getRecordTypeInfosByName().get('EffectivenessReview').getRecordTypeId();
       /*---v1.1-- start --*/

        
        for(Document_Profile__c Dp:newMap.values()){
            system.debug('Approval_Required__cApproval_Required__c'+Dp.Approval_Required__c);
            
         
            /*
            
            if(Dp.status__c=='Draft'&&!DP.Approval_Required__c&&Dp.Submit__c=='Submit'&&oldmap.get(Dp.id).Submit__c!='Submit'&&(
                ((Dp.Approval_Status__c=='Reject'||Dp.Approval_Status__c=='Recall')&&Dp.Approval_Status__c==Oldmap.get(Dp.id).Approval_Status__c)
                ||((Dp.Approval_Status__c!='Reject'||Dp.Approval_Status__c!='Recall')))){
            */
              if(Dp.status__c=='Draft'&&!DP.Approval_Required__c&&Dp.Submit__c=='Submit'&&(
                ((Dp.Approval_Status__c=='Reject'||Dp.Approval_Status__c=='Recall')&&Dp.Approval_Status__c==Oldmap.get(Dp.id).Approval_Status__c)
                ||((Dp.Approval_Status__c!='Reject'||Dp.Approval_Status__c!='Recall')))){
                Dp.Submit__c='Save';
                if((Dp.Pre_Release_Duration_Date__c>system.today()||Dp.Pre_Release_Duration_Date__c==null)&&Dp.Effective_Date__c>system.today()){
                    Dp.Status__c='Completed';                    
                }
                else if(Dp.Pre_Release_Duration_Date__c==system.today()){
                    Dp.Status__c='Prerelease';                    
                }                
                if(Dp.Effective_Date__c!=null&&Dp.Status__c==Oldmap.get(dp.id).status__c){
                    if(Dp.Effective_Date__c==system.today()){
                        Dp.Status__c='Current';
                    }
                }
                    if(Dp.Effective_Date__c==system.today()){
                        Dp.Status__c='Current';
                    }
                if(dp.Expire_After__c!=null){
                    dp.Expiration_Date__c=dp.Effective_Date__c.addDays((integer)dp.Expire_After__c);    
                }
                
                if(dp.Retention_Duration__c!=null){
                    dp.Date_of_Purge__c=dp.Expiration_Date__c.addDays((integer)dp.Retention_Duration__c);    
                }
                
                if(dp.Effectiveness_Review_In_Advance__c!=null){
                    dp.Effectiveness_Review_Date__c=dp.Expiration_Date__c.addDays((((integer)dp.Effectiveness_Review_In_Advance__c))* -1);                    
                }

                if(dp.Expiration_Date__c==system.today()){
                    dp.status__C='Expired';                    
                }
                if(dp.Date_of_Purge__c==system.today()){
                    dp.status__C='Obsolete';                    
                }
                system.debug('inside Effectiveness_Review_Date__c '+dp.Effectiveness_Review_Date__c);
                if( dp.Effectiveness_Review_Date__c==system.today()&&!genMap.containsKey(dp.id)){        
                    system.debug('inside Effectiveness_Review_Date__c');
                    EffectiveNessReviewTasks.add(new general_task__c(RecordTypeId=EffectivenessReviewRecordTypeId,status__c='Open',Due_Date__C=dp.Expiration_Date__c,Document_Profile__c=dp.id,Allowed_Days__c=20));
                }
            }
            else if(dp.Approval_Process_Complete__c&&!oldMap.get(dp.id).Approval_Process_Complete__c){// added after approval
                if( dp.Effectiveness_Review_Date__c==system.today()&&!genMap.containsKey(dp.id)&&!dp.auto_expire__c){  //added by balu auto expire !dp.auto_expire__c      
                    system.debug('inside Effectiveness_Review_Date__c');
                    EffectiveNessReviewTasks.add(new general_task__c(RecordTypeId=EffectivenessReviewRecordTypeId,status__c='Open',Due_Date__C=dp.Expiration_Date__c,Document_Profile__c=dp.id,Allowed_Days__c=20));
                }
            }
            //==updated by baluu effect on current
            system.debug('inside Effective_Date__c');
                if(Dp.Status__c=='Current'&&oldmap.get(Dp.id).status__c!='Current'){
                    Dp.Effective_Date__c=system.today();       
                    if(dp.Expire_After__c!=null){
                        dp.Expiration_Date__c=dp.Effective_Date__c.addDays((integer)dp.Expire_After__c);    
                    }      
                    if(dp.Retention_Duration__c!=null){
                        dp.Date_of_Purge__c=dp.Expiration_Date__c.addDays((integer)dp.Retention_Duration__c);    
                    }   
                    if(dp.Effectiveness_Review_In_Advance__c!=null){
                        dp.Effectiveness_Review_Date__c=dp.Expiration_Date__c.addDays((((integer)dp.Effectiveness_Review_In_Advance__c))* -1);                    
                    }       
                    if(dp.Pre_Release_Duration_Date__c!=null&&dp.Pre_Release_Duration_Date__c<system.today()){
                        if(dp.Effective_Date__c>dp.Pre_Release_Duration_Date__c){
                        dp.Grace_Period_for_Release__c=dp.Pre_Release_Duration_Date__c.daysBetween(dp.Effective_Date__c);
                        }else{
                        dp.Grace_Period_for_Release__c=null;
                        dp.Pre_Release_Duration_Date__c=null;
                        }              
                    }else{
                        dp.Grace_Period_for_Release__c=null;
                        dp.Pre_Release_Duration_Date__c=null;
                    }                                  
                }
                if(Dp.Status__c=='Expired'&&oldmap.get(Dp.id).status__c!='Expired'){
                    dp.Expiration_Date__c=system.today();
                    if(dp.Retention_Duration__c!=null){
                        dp.Date_of_Purge__c=dp.Expiration_Date__c.addDays((integer)dp.Retention_Duration__c);    
                    }                  
                }
                Dp.Submit__c='Save' ;    //version  v1.2          
        }
        
        
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c', 'ownerid,RecordTypeId,Document_Profile__c,Allowed_Days__c','Create')){
            if(!EffectiveNessReviewTasks.isEmpty()){
            insert EffectiveNessReviewTasks;    
            }
            
        }
        
        /*---v1.1-- start --*/
    }
    
    
    //-----------sequential approval process
    public static void DocumentProfileSubmitForApprovalProcess(List<Document_Profile__c> DPs,Boolean initialSubmitter){
        List<id> approveObjids=new List<id>();
        map<id,id> approveObjidsSub=new map<id,id>();
        id submitter;
        set<id> ncids=new set<id>();            
        list<id> Approvers= new list<id>();
        Set<Id> DocProfIds = (new Map<Id,SObject>(DPs)).keySet();
        Decimal current;
        boolean flag;
        id DocProfileId;
        list<Approver__c> DocProfApprovers;
        map<id,List<Approver__c>> DocProfApproversMap=new map<id,List<Approver__c>>();
        list<Approver__c> tempApprovers;
        //=========retriving approvers for assiging next sequence approval process  
        String queryFieldSOfAP = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,Sequence_Position__c,Document_Profile__c,User__c');     
        if(queryFieldSOfAP!=null&&queryFieldSOfAP!=''){
            DocProfApprovers=database.query('Select '+ queryFieldSOfAP +' from Approver__c where Document_Profile__c IN: DocProfIds');      //fetching approvers related to current DocProferal task 
            
            for(Document_Profile__c DP:DPs){                        //grouping DocProferal task and approvers related to them
                tempApprovers=new list<Approver__c>();
                for(Approver__c apprs:DocProfApprovers){
                    if(apprs.Document_Profile__c==DP.id){
                        tempApprovers.add(apprs);
                    }
                }
                DocProfApproversMap.put(DP.id,tempApprovers);
            }
        }        
        
        
        
        //List<DocProferal_Sub_Task__c> ActionPlanList=new List<DocProferal_Sub_Task__c>();
        for(Document_Profile__c Dp:DPs){
            
            if(Dp.CurrentApprovalSequenceNumber__c==null){
                Dp.CurrentApprovalSequenceNumber__c=0;
            }
            current=Dp.CurrentApprovalSequenceNumber__c;
            flag=false;
            DocProfileId=Dp.id;                 
            for(Approver__c appr:DocProfApproversMap.get(DocProfileId)){                        //to find next approvers
                if(appr.Sequence_Position__c>Dp.CurrentApprovalSequenceNumber__c){ 
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
            
            if(current==Dp.CurrentApprovalSequenceNumber__c){                               //if no next higher approver
                current=current+1000; 
            }
            integer len=Approvers.size();
            if(flag){
                system.debug(flag+'flag after Sequence_Position__c current'+current);
                Dp.CurrentApprovalSequenceNumber__c=current;
                integer i=1;    
                Dp.Initial_Submitter__c=Dp.Ownerid;
                Dp.Approver__c=Approvers[len-1];i++;                                                    
                Dp.Approver_1__c=Approvers[((len-i>0)?len-i:0)];i++;                                       
                Dp.Approver_2__c=Approvers[((len-i)>0)?len-i:0];i++;                                             
                Dp.Approver_3__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_4__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_5__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_6__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_7__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_8__c=Approvers[((len-i)>0)?len-i:0];i++;
                Dp.Approver_9__c=Approvers[((len-i)>0)?len-i:0]; 
                
                if(initialSubmitter){
                    submitter=Dp.Initial_Submitter__c;                                                      
                }
                else{
                    submitter=Dp.Ownerid;
                }
                approveObjidsSub.put(Dp.id, Dp.Initial_Submitter__c);
                approveObjids.add(Dp.id);                                             
                // submitForApproval(Dp.id,submitter);
            }
            
            if(Approvers.isEmpty()&&DP.ApprovalProcess__c=='Document Approval'){
                system.debug('inside Approver is Empty');
                Dp.Approval_Process_Complete__c=true;
                Dp.Approval_Status__c='Approved';
                //Dp.CurrentApprovalSequenceNumber__c=0;
                if(Dp.Grace_Period_for_Release__c!=null){
                //    Dp.Pre_Release_Duration_Date__c=system.today().addDays((integer)dp.Grace_Period_for_Release__c);  
                }
                if(Dp.Effective_Date__c!=null&&DP.Status__c!='Current'){
                    if(Dp.Effective_Date__c<=system.today()){
                        Dp.Status__c='Current';
                        Dp.Effective_Date__c=system.today();
                    }
                }
                if(dp.Pre_Release_Duration_Date__c!=null&&dp.Pre_Release_Duration_Date__c<=system.today()&&DP.Status__c!='Current'&&Dp.Effective_Date__c>system.today()){
                        Dp.Status__c='Prerelease'; 
                        dp.Pre_Release_Duration_Date__c=system.today();
                        
                        dp.Grace_Period_for_Release__c=dp.Pre_Release_Duration_Date__c.daysBetween(dp.Effective_Date__c);                       
                        if(Integer.valueOf(dp.Grace_Period_for_Release__c)<0){
                        dp.Grace_Period_for_Release__c=(Integer.valueOf(dp.Grace_Period_for_Release__c)*-1);                        
                        }
                }else if(Dp.Status__c!='Current'){
                        Dp.Status__c='Approved';                      
                }
               
                if(dp.Expire_After__c!=null){
                    dp.Expiration_Date__c=dp.Effective_Date__c.addDays((integer)dp.Expire_After__c);    
                }
                
                if(dp.Retention_Duration__c!=null){
                    dp.Date_of_Purge__c=dp.Expiration_Date__c.addDays((integer)dp.Retention_Duration__c);    
                }
                
                if(dp.Effectiveness_Review_In_Advance__c!=null){
                    dp.Effectiveness_Review_Date__c=dp.Expiration_Date__c.addDays((((integer)dp.Effectiveness_Review_In_Advance__c))* -1);                    
                }

            }
            Approvers.clear();
            
        }
        //upsert ActionPlanList;
        //
        if(!approveObjids.isEmpty()){
            system.debug('inside before submit');
            SubmitForApprovalProcess(approveObjids,approveObjidsSub);
        }
        //closeNC(ncids);//closing NC based on Closure with after Approval
    }
    //-----------sequential approval process end
    
    //----Before Trigger --End
    
       
     public static void FieldHistoryTracking(Map<id,Document_Profile__c> newMap,Map<id,Document_Profile__c> oldMap){
        try{
        Map<String, Schema.SObjectField> DP_Lable =Schema.SObjectType.Document_Profile__c.fields.getMap();
            system.debug('DP_LableDP_Lable'+DP_Lable); 
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
        system.debug('inside field history tracking dphisList'+dphisList);
        if(dphisList==null||dphisList.isEmpty()){
            system.debug('inside field history tracking if dphisList'+dphisList);
            dphisList = new List<Document_Profile_History__c>();    
        }  
        
        if(cmhisList==null||cmhisList.isEmpty()){
            system.debug('inside field history tracking if dphisList'+dphisList);
            cmhisList = new List<Change_Management_History__c>();    
        } 
        
        Document_Profile_History__c dphis;
        Change_Management_History__c cmhis;
        string fieldApiname;
        id temp;
        string tempstore;            
        Set<string> fieldsetNames=new Set<string>(); 
        Set<string> DPfieldsetNames=new Set<string>();
        Set<string> fieldsetSecNames=new Set<string>();
   
            final List<Schema.FieldSetMember> trackedFields = SObjectType.Document_Profile__c.FieldSets.Document_Detail_Fields.getFields();
            system.debug('trackedFields'+trackedFields);        
               for(Schema.FieldSetMember feildname:trackedFields){
               fieldsetNames.add(feildname.getFieldPath());
            }     
            final List<Schema.FieldSetMember> trackeddpFields = SObjectType.Document_Profile__c.FieldSets.Document_Profile_Fields.getFields(); 
        
            final List<Schema.FieldSetMember> trackedSecFields = SObjectType.Document_Profile__c.FieldSets.Security_Fields.getFields();
            system.debug('trackedSecFields'+trackedSecFields);        
               for(Schema.FieldSetMember feildname:trackedSecFields){
               fieldsetSecNames.add(feildname.getFieldPath());
            }
        
            system.debug('trackeddpFields'+trackeddpFields);        
            for(Schema.FieldSetMember feildname:trackeddpFields){
                DPfieldsetNames.add(feildname.getFieldPath());
            }
            set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
        
        for(Document_Profile__c dp:newMap.values()){ 
            System.debug('DocumentProfileTriggerHandler11 ');
            final Document_Profile__c oldDP = oldmap.get(dp.Id);    
            Boolean resolution;                
            for(Schema.SObjectField feildname:Schema.SObjectType.Document_Profile__c.fields.getMap().values()){
                resolution=true;
                fieldApiname=string.valueOf(feildname);
                system.debug('DocumentProfileTriggerHandler DPfieldsetNames'+fieldApiname+'fieldsetNames'+DPfieldsetNames);
                if(DPfieldsetNames.contains(fieldApiname)){ 
                    if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                        dphis=new Document_Profile_History__c();
                        if(DP_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                            dphis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                        }
                        else{
                            dphis.FieldName__c=DP_Lable.get(fieldApiname).getDescribe().getLabel(); 
                        }
                        //dphis.FieldName__c=DP_Lable.get(fieldApiname).getDescribe().getLabel();
                        dphis.FieldApiName__c=fieldApiname;
                        if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                            System.debug('dp DocumentProfileTriggerHandler check');
                            if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                if(oldDP.get(fieldApiname)!=null){
                                    mydate=date.valueOf(oldDP.get(fieldApiname));
                                    dphis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                }                                            
                                if(dp.get(fieldApiname)!=null){
                                    mydate=date.valueOf(dp.get(fieldApiname));
                                    dphis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                }
                                
                            }else{
                                dphis.oldValue__c=string.valueOf(oldDP.get(fieldApiname));
                                dphis.NewValue__c=string.valueOf(dp.get(fieldApiname));
                                
                            }
                            dphis.Sub_Parent__c='Init';
                            dphis.Parent__c=dp.id;
                            dphis.object__c='Document_Profile__c';
                            dphisList.add(dphis);   
                            //resolution=false; 
                            System.debug('dphisList'+dphisList);
                        }                        
                        else
                        if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                            System.debug('dp 2');
                                        dphis=new Document_Profile_History__c();
                                        temp=string.valueOf(dp.get(fieldApiname));   
                                        dphis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
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
                                            tempstore=string.valueOf(oldDP.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                dphis.oldValue__c=User.get(string.valueOf(oldDP.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(dp.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                dphis.NewValue__c=User.get(string.valueOf(dp.get(fieldApiname))).Name;   
                                            dphis.Sub_Parent__c='Init';
                                            dphis.Parent__c=dp.id;
                                            dphis.object__c='Document_Profile__c';                                           
                                            dphisList.add(dphis); 
                                            system.debug('inside dp record');
                                        }
                        }
                    }
                }
                //system.debug('DocumentProfileTriggerHandler1'+dp.CreatedDate+'dp.LastModifiedDate'+dp.LastModifiedDate);
                
                if((dp.CreatedDate==dp.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())!='Boolean')||(dp.CreatedDate!=dp.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())=='Boolean')||(dp.CreatedDate!=dp.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())!='Boolean')){
                if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                            system.debug('DocumentProfileTriggerHandler1'+fieldApiname+'fieldsetNames'+fieldsetNames);
                            if(fieldsetNames.contains(fieldApiname)){ 
                                system.debug('DocumentProfileTriggerHandler2'+fieldApiname);
                                if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                                    system.debug('inside dp.get(fieldApiname)!=oldDP.get(fieldApiname) field history tracking'+fieldApiname);
                                    dphis=new Document_Profile_History__c();
                                    dphis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();                                                                
                                    dphis.FieldApiName__c=fieldApiname;                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE' && fieldApiname!=(Prefix+'Impacted_Sites__c')){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldDP.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldDP.get(fieldApiname));
                                                dphis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(dp.get(fieldApiname)!=null){
                                                mydate=date.valueOf(dp.get(fieldApiname));
                                                dphis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            dphis.oldValue__c=string.valueOf(oldDP.get(fieldApiname));
                                            dphis.NewValue__c=string.valueOf(dp.get(fieldApiname));
                                            
                                        }
                                        dphis.Sub_Parent__c='DocumentDetails';
                                        dphis.Parent__c=dp.id;
                                        dphis.object__c='Document_Profile__c';
                                        dphisList.add(dphis);                        
                                    }
                                    /////////////////
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE' && fieldApiname==(Prefix+'Impacted_Sites__c')){  
                                    system.debug('string. inside after reference');
                                    
                                    dphis=new Document_Profile_History__c();
                                    dphis.FieldName__c=DP_Lable.get(fieldApiname).getDescribe().getLabel();
                                    dphis.FieldApiName__c=fieldApiname; 
                                        system.debug('inside dp'+dp);
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
                                                
                                                System.debug('TEMPSTORE:string.valueOf'+string.valueOf(oldDP.get(fieldApiname)));
                                                if(oldDP.get(fieldApiname)!=null){
                                                if((!(string.valueOf(oldDP.get(fieldApiname))==''||string.valueOf(oldDP.get(fieldApiname))==null)&&!manufacturingSite.isEmpty()))
                                                dphis.oldValue__c='';
                                                    for(string Imps:string.valueOf(oldDP.get(fieldApiname)).split(',')){
                                                    dphis.oldValue__c+=manufacturingSite.get(Imps).Name+',';    
                                                    }
                                                }
                                                if((!(string.valueOf(dp.get(fieldApiname))==''||string.valueOf(dp.get(fieldApiname))==null))&&!manufacturingSite.isEmpty())
                                                    dphis.NewValue__c='';
                                                    for(string Imps:string.valueOf(DP.get(fieldApiname)).split(',')){
                                                    dphis.NewValue__c+=manufacturingSite.get(Imps).Name+',';    
                                                    }   
                                                    
                                                    dphis.newValue__c.removeEnd(',');
                                                
                                                dphis.Sub_Parent__c='DocumentDetails';
                                                dphis.Parent__c=dp.id;
                                                dphis.object__c='Document_Profile__c';
                                                dphisList.add(dphis);  
                                            }
                                        }
                                    ////////////////
                                }
                            
                         }
                }
                    
                    if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                            system.debug('sarath DocumentProfileTriggerHandler1'+fieldApiname+'fieldsetSecNames'+fieldsetSecNames);
                            if(fieldsetSecNames.contains(fieldApiname)){ 
                                system.debug('sarath DocumentProfileTriggerHandler2'+fieldApiname);
                                if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                                    system.debug('sarath inside dp.get(fieldApiname)!=oldDP.get(fieldApiname) field history tracking'+fieldApiname);
                                    dphis=new Document_Profile_History__c();
                                    dphis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();                                                                
                                    dphis.FieldApiName__c=fieldApiname;                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldDP.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldDP.get(fieldApiname));
                                                dphis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(dp.get(fieldApiname)!=null){
                                                mydate=date.valueOf(dp.get(fieldApiname));
                                                dphis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            dphis.oldValue__c=string.valueOf(oldDP.get(fieldApiname));
                                            dphis.NewValue__c=string.valueOf(dp.get(fieldApiname));
                                            
                                        }
                                        dphis.Sub_Parent__c='Security';
                                        dphis.Parent__c=dp.id;
                                        dphis.object__c='Document_Profile__c';
                                        dphisList.add(dphis);                        
                                    }
                                }
                            
                         }
                }
                }
                ////////////////
                if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)&& dp.get('Change_Management__c')!=NULL){
                            system.debug('Change_Management__c DocumentProfileTriggerHandler1'+fieldApiname+'DPfieldsetNames'+DPfieldsetNames);
                            if(DPfieldsetNames.contains(fieldApiname)){ 
                                
                                if(dp.get(fieldApiname)!=oldDP.get(fieldApiname)){
                                    cmhis=new Change_Management_History__c();
                                    if(DP_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                                        cmhis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                                    }
                                    else{
                                        cmhis.FieldName__c=DP_Lable.get(fieldApiname).getDescribe().getLabel(); 
                                    }
                                    //cmhis.FieldName__c=DP_Lable.get(fieldApiname).getDescribe().getLabel();
                                    cmhis.FieldApiName__c=fieldApiname;
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        System.debug('dp DocumentProfileTriggerHandler check');
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldDP.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldDP.get(fieldApiname));
                                                cmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(dp.get(fieldApiname)!=null){
                                                mydate=date.valueOf(dp.get(fieldApiname));
                                                cmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            cmhis.oldValue__c=string.valueOf(oldDP.get(fieldApiname));
                                            cmhis.NewValue__c=string.valueOf(dp.get(fieldApiname));
                                            
                                        }
                                        cmhis.Sub_Parent__c='DocumentChange';
                                        cmhis.Parent__c=(Id)dp.get('Change_Management__c');
                                        cmhis.object__c='General_Task__c';
                                        cmhisList.add(cmhis);   
                                        //resolution=false; 
                                        System.debug('cmhisList'+cmhisList);
                                    }                        
                                    else
                                        if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                                            System.debug('dp 2');
                                            cmhis=new Change_Management_History__c();
                                            temp=string.valueOf(dp.get(fieldApiname));   
                                            cmhis.FieldName__c=DP_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
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
                                                tempstore=string.valueOf(oldDP.get(fieldApiname));
                                                if(!(tempstore==''||tempstore==null))
                                                    cmhis.oldValue__c=User.get(string.valueOf(oldDP.get(fieldApiname))).Name;
                                                tempstore=string.valueOf(dp.get(fieldApiname));
                                                if(!(tempstore==''||tempstore==null))
                                                    cmhis.NewValue__c=User.get(string.valueOf(dp.get(fieldApiname))).Name;   
                                                cmhis.Sub_Parent__c='DocumentChange';
                                                cmhis.Parent__c=(Id)dp.get('Change_Management__c');
                                                cmhis.object__c='General_Task__c';                                           
                                                cmhisList.add(cmhis); 
                                                system.debug('inside dp record');
                                            }
                        }
                    }
                                
                         }
                }
                //////////
                                                 
            
            }
        }
        }catch(Exception ex){
        System.debug('Exception In dpTriggerHandler.FieldHistoryTracking     '+ex.getMessage());
    }
    }
    
    
    
    public static void DocumentProfile_AfterTrigger(Map<id,Document_Profile__c> newMap,Map<id,Document_Profile__c> oldMap){
        try{
        system.debug('inside after trigger '+newMap);
        rt_Map = Document_Profile__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        Map<id,Document_Profile__c> afterupdateMap=new Map<id,Document_Profile__c>();
                //========================================================update/insert
                system.debug('oldMap');
                if(oldMap==null){
                   system.debug('inside after trigger oldMap'+oldMap); 
                   oldMap=new Map<id,Document_Profile__c>(); 
                }  
                Map<id,Document_Profile__c> afterinsertMap=new Map<id,Document_Profile__c>();
                    for(Document_Profile__c gt:newMap.values()){
                        if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                            afterinsertMap.put(gt.id,gt) ; 
                        }
                        else{
                            afterupdateMap.put(gt.id,gt) ; 
                        }
                    }
                    dphisList=new List<Document_Profile_History__c>();
                    system.debug(' before afterinsertMap');
                    afterinsert(afterinsertMap);
                    system.debug('after afterinsertMap');
                    system.debug('after afterinsertMap dphisList'+dphisList);
                    FieldHistoryTracking(afterupdateMap,oldMap);   
                    system.debug('after FieldHistoryTracking');
                    system.debug('after FieldHistoryTracking dphisList'+dphisList);
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
                    insert dphisList;
                    }
            
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
                    insert cmhisList;
                    }
                    system.debug('after FieldHistoryTracking dphisList'+dphisList);
                    system.debug('after FieldHistoryTracking cmhisListcmhisList'+cmhisList);
                    DocumentProfile_IsAfter_UpdateGeneralTaskOwner(newMap,oldMap);
            }catch(Exception ex){
            System.debug('Exception In dpTriggerHandler.afterTrigger     '+ex.getMessage());
        } 
    }
    
    public static void afterinsert(Map<id,Document_Profile__c> dps){
        if(dphisList==null||!dphisList.isEmpty()){
            dphisList = new List<Document_Profile_History__c>();    
        }
        
        if(cmhisList==null||!cmhisList.isEmpty()){
            cmhisList = new List<Change_Management_History__c>();    
        }
        map<id,Document_Profile__c> insertOldMap=new map<id,Document_Profile__c>();
        Document_Profile_History__c dphis;
        Change_Management_History__c cmhis;
        for(Document_Profile__c dp:dps.values()){
            insertOldMap.put(dp.id,new Document_Profile__c());
            dphis=new Document_Profile_History__c(); 
            dphis.Parent__c=dp.id;
            dphis.isCreated__c=true; 
            dphis.FieldName__c='Document Profile';
            dphis.object__c='Document_Profile__c';
            dphisList.add(dphis);
            
            cmhis=new Change_Management_History__c(); 
            cmhis.Parent__c=(Id)dp.get('Change_Management__c');
            cmhis.isCreated__c=true; 
            cmhis.FieldName__c='Document Profile';
            cmhis.object__c='General_Task__c';
            cmhis.Sub_Parent__c='DocumentChange';
            cmhisList.add(cmhis);
        } 
        system.debug('inside after trigger in dp record'+dphisList);
                
        FieldHistoryTracking(dps,insertOldMap);  
        for(Document_Profile_History__c dph:dphisList){
            dph.isCreated__c=true;
        }
        
        for(Change_Management_History__c cmh:cmhisList){
            cmh.isCreated__c=true;
        }
        
    }
    
    public static void DocumentProfile_IsAfter_UpdateGeneralTaskOwner(Map<id,Document_Profile__c> updateDocumentProfileMap,Map<id,Document_Profile__c> oldMap){
        set<id> dpids=new set<id>();
        for(Document_Profile__c dp:updateDocumentProfileMap.values()){            
            if(oldMap!=null&&oldMap.get(dp.id)!=null){
                if(dp.Ownerid!=oldMap.get(dp.id).Ownerid){
                    dpids.add(dp.id);
                }    
            }
            
        }
        if(!dpids.isEmpty()){
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Document_Profile__c,Owner__c,');
            if(queryFieldNames!=null||queryFieldNames!=''){
                system.debug('inside updateGeneralTaskOwner before query');
                List<General_Task__c> gts=database.query('Select  '+ queryFieldNames +' From General_Task__c where Document_Profile__c IN:dpids');
                system.debug('inside updateGeneralTaskOwner after query');
                for(General_Task__c gt:gts){
                    system.debug('inside updateGeneralTaskOwner before update inside for gts'+gt.Owner__c);
                    gt.ParentOwner__c=updateDocumentProfileMap.get(gt.Document_Profile__c).ownerid;
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
     /*----Document Revise and Temp story Trigger Helper(Start)----*/
    public static void UpdateRevised(List<Document_Profile__c> Newincomming) {
        List<string> childRecords = new List<string>();
        List<Document_Profile__c> parentRecords = new List<Document_Profile__c>();
        List<Document_Profile__c> DList = new List<Document_Profile__c>();
        List<Id> childRecordsID = new List<Id>();
        for(Document_Profile__c a : Newincomming)
        {
            if(a.name != null && a.Status__c == 'Current' && a.isRevise__c == false && a.isTemp__c == false){
            childRecords.add(a.name);
            childRecordsID.add(a.Id);
            }
        }
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,status__c,isRevise__c,isTempRevise__c,Current_Rev__c,Automatically_Expire_Previous_Revision__c');
        //List<Document_Profile__c> DList = [select id,name,ReviseCheck__c,Status__c from Document_Profile__c where name IN : childRecords AND Status__c = 'Current' ];
         String status = 'Current';
        if(queryFieldNames != null && queryFieldNames != '')
        {
        for(Document_Profile__c b : database.query ('select ' + queryFieldNames + ' from Document_Profile__c where  name IN : childRecords AND Status__c =: status AND Id NOT IN : childRecordsID LIMIT 1000'))
        {
            if(b.isRevise__c == True && b.Automatically_Expire_Previous_Revision__c == False){
            b.Status__c = 'Revised';
           
        }else if(b.isRevise__c == True && b.Automatically_Expire_Previous_Revision__c == True){
            b.Status__c = 'Expired';
           
        }
            b.isRevise__c = false;
            b.isTempRevise__c = false;
            parentRecords.add(b);
        }
        }
 if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,Document_Name__c,isRevise__c,isTempRevise__c,Document_Type__c,Status__c','update')){
                   update parentRecords;
             
        }
        else{
                        System.debug('No Acesss to object  Document_Profile__c');
                     }
        //update parentRecords;
   }
    
    public static void UpdateTemp(List<Document_Profile__c> Newincomming) {
        List<string> childRecords = new List<string>();
        List<Document_Profile__c> parentRecords = new List<Document_Profile__c>();
        List<Document_Profile__c> DList = new List<Document_Profile__c>();
        List<Id> childRecordsID = new List<Id>();
        for(Document_Profile__c a : Newincomming)
        {
            if(a.name != null && a.Status__c == 'Expired' && a.isTemp__c == True){
            childRecords.add(a.name);
            childRecordsID.add(a.Id);
            }
        }
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,status__c,isRevise__c,isTemp__c,isTempRevise__c,Current_Rev__c');
       //List<Document_Profile__c> DList = [select id,name,ReviseCheck__c,Status__c from Document_Profile__c where name IN : childRecords AND Status__c = 'Current' ];
        String status = 'Current';
        if(queryFieldNames != null && queryFieldNames != '')
        {   
    for(Document_Profile__c b : database.query ('select ' + queryFieldNames + ' from Document_Profile__c where  name IN : childRecords AND Status__c =: status AND Id NOT IN : childRecordsID LIMIT 1000'))
        {
            if(b.isTempRevise__c == True){
           
            b.isTempRevise__c = false;
            parentRecords.add(b);
            }
        } 
        
        }
 if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Profile__c','Current_Rev__c,Document_Name__c,isRevise__c,isTempRevise__c,isTemp__c,Document_Type__c,Status__c','update')){
                   update parentRecords;
             
        }
        else{
                        System.debug('No Acesss to object  Document_Profile__c');
                     }
        //update DObject;
   }
    /*----Document Revise and Temp story Trigger Helper(Stop)----*/

}