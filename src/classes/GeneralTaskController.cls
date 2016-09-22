/*
 
v1.0		Qualityze Inc(BK)		02-MAY-2016		Initial Version.
                                                   	This class includes all general tasks
v2.0		Qualityze Inc(BK)		21-MAY-2016		Updated Version.
													This class includes all general tasks (Capa)
v2.0.1		Qualityze Inc(SB)		19-jul-2016		Updated Version .
v2.0.2		Qualityze Inc(SLVR)		27-JUL-2016		Added 'DocumentChange' 

v2.0.3		Qualityze Inc(PRG)		29-JUL-2016		Added 'cr_saveClosureTask                                                   
v2.0.4		Qualityze Inc(SLVR)		16-SEP-2016		Added 'Pending Action Completion'
*/

public with sharing class GeneralTaskController {

    public GeneralTaskController(){
           
                   
    }
    
    public GeneralTaskController (ApexPages.StandardController controller) {
    	id auditid=ApexPages.currentPage().getParameters().get('auditid');
        string pagename=Apexpages.currentPage().getUrl();
        if(auditid!=null&&pagename.containsIgnoreCase('audit_trail')){
            return;
        }
        Id gtid=ApexPages.currentPage().getParameters().get('gtid');
        Id ncId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));

        
        string type=ApexPages.currentPage().getParameters().get('type');
        
      
        
        
        //nonconformance
        if(String.valueOf(ncId.getSobjectType()).containsIgnoreCase('Non_Conformance__c')){
        ////////////////////////////////////////////////////////////////
        //NC Disposition constuctor start
        ////////////////////////////////////////////////////////////////
        if(type.containsIgnoreCase('Disposition')){
        try{            
        
        queryFieldNamesGenTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Due_Date__c,Sequence_Position__c,CreatedDate,ownerid,Owner.Name,RecordTypeId,RecordType.Name,Status__c,Approver_1__c,Approver_2__c,Initial_Submitter__c ,Approval_Required__c ,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,ChangeFieldApprovalStatus__c,Approver__c ,Note_To_Approver__c,New_Due_Date__c ,New_Owner__c,New_Owner__r.Name  ,Owner__r.name,Note_To_Approver_Owner_DueDate__c,CurrentApprovalSequenceNumber__c');
        if(queryFieldNamesGenTask != null && queryFieldNamesGenTask != ''&&recordType!=null){
            gDispTask = database.query('SELECT '+queryFieldNamesGenTask+' from General_Task__c where Non_Conformance__r.Id = :ncId AND id=:gtid');
        }
        queryFieldNamesNcr = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c','ownerid');
        if(queryFieldNamesNcr !=null && queryFieldNamesNcr != ''){
            ncr = database.query('select '+queryFieldNamesNcr+' from Non_Conformance__c where Id = :ncId');
        }   
        }
        catch(Exception ex){
            System.debug('Exception In NC_Disposition_Form   '+ex.getMessage())    ;
        }  
        }
        //NC Disposition constuctor end
        
        //NC Investigation constuctor start
        if(type.containsIgnoreCase('Investigation')){
        try{
            ncId=((Non_Conformance__c)controller.getRecord()).id;
            System.debug('ncId------------------->'+ncId);
            List<General_Task__c> genTasks;
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Status__c,Ownerid,Owner.Name,CreatedDate,ChangeFieldApprovalStatus__c,New_Due_Date__c,Allowed_Days__c,Due_Date__c,Investigation_Tools__c,Investigation_Summary__c,New_Owner__c,New_Owner__r.Name,Sequence_Position__c,RecordType.Name,Owner__c,Owner__r.Name,OwnerName__c,Note_To_Approver__c,Approval_Required__c,Approver__c,Approver_1__c,Approver_2__c,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c ,Note_To_Approver_Owner_DueDate__c ,Initial_Submitter__c ');
            
             if(queryFieldNames != null && queryFieldNames != '')
            {
                String qry='select ' + queryFieldNames + ' from General_Task__c where Non_Conformance__c=:ncId AND RecordType.Name=\'Investigation\' ORDER BY Id DESC LIMIT 1';
                System.debug('qry   '+qry);
                genTasks= database.query (qry);
                                
            }
           
            if(!genTasks.isEmpty()){
                genTask=genTasks[0];
            }
        }catch(Exception ex){
            System.debug('Exception In NC_Investigation_Form   '+ex.getMessage())    ;
        }        
        }
        
        //NC Investigation constuctor end
        }
        
        
        //   capa
        else if(String.valueOf(ncId.getSobjectType()).containsIgnoreCase('capa__c')){
        
        //Capa Adhoc Task constuctor end
        if(type.containsIgnoreCase('AdhocTask')){
       try{
            capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
            gtId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('gtid'));
            queryFieldNamesGenTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,CreatedDate,AdhocTask_Title__c,Due_Date__c,Sequence_Position__c,CAPA__c,ownerid,Owner.Name,RecordTypeId,RecordType.Name,Status__c,Approver_1__c,Approver_2__c,Initial_Submitter__c ,Approval_Required__c ,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,ChangeFieldApprovalStatus__c,Approver__c ,Note_To_Approver__c,New_Due_Date__c ,New_Owner__c,New_Owner__r.Name  ,Owner__r.name,Note_To_Approver_Owner_DueDate__c');
            queryFieldNamesAdhocTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,RecordTypeId,RecordType.Name,Completed_By__c,Completed_By__r.Name,Sub_Task_Detail__c,Completed_Date__c,General_Task__c');
            if(queryFieldNamesGenTask != null && queryFieldNamesGenTask != ''){
                adhocTask = database.query('SELECT '+queryFieldNamesGenTask+' FROM General_Task__c WHERE CAPA__c = :capaId AND Id = :gtId AND RecordType.Name=:adhocTaskrecordType');
            }
            
            if(queryFieldNamesAdhocTask != null && queryFieldNamesAdhocTask != ''){
                adhocTaskActions = database.query('SELECT '+queryFieldNamesAdhocTask+' FROM General_Sub_Task__c WHERE RecordType.Name=:adhocTaskActionsRecordType AND General_Task__c =: gtId');
            }
       }catch(Exception ex){
           System.debug('Exception In NC_Adhoc Task_Form   '+ex.getMessage())    ;
       }    
       }
        //Capa Adhoc Task constuctor end
       
        //Capa Implementation Task constuctor start
       if(type.containsIgnoreCase('Implementation')){
       system.debug('Implementation constructur');
           try{
            Id gTaskId;
            capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
            /*queryFieldNamesCapar = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','Owner.Id,CreatedDate');
            if(queryFieldNamesCapar !=null && queryFieldNamesCapar != ''){
                capa = database.query('select '+queryFieldNamesCapar+' from CAPA__c where Id = :capaId');
            }*/
            
            queryFieldNamesGenTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','Id,Due_Date__c,New_Due_Date__c,Status__c,CreatedDate,ChangeFieldApprovalStatus__c');
            if(queryFieldNamesGenTask !=null && queryFieldNamesGenTask != ''){
                actionplanTask = database.query('select '+queryFieldNamesGenTask+' from General_Task__c where RecordType.Name=\'Implementation\' AND CAPA__r.Id = :capaId ');
                gTaskId = actionplanTask.Id;
            }
            
            queryFieldNamesapSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Title__c,CreatedDate,Statement__c,Description__c,Associated_Root_Cause_Name__c,Action_Plan_Status__c,Type__c,Assigned_User__r.Name,Due_Date__c,Associated_Root_Causes__c,Complete__c,Completed__c,Completed_By__r.Name,Completed_Date__c,Completion_Comments__c,General_Task__c,RecordType.Name');
            if(queryFieldNamesapSec !=null && queryFieldNamesapSec != ''){
                actionplanSec = database.query('select '+queryFieldNamesapSec+' from General_Sub_Task__c where RecordType.Name=\'Action Plan\' AND General_Task__c =:gTaskId');
            }  
            system.debug('inside implementation constructur actionplanSec '+actionplanSec);
            queryFieldNamesefvpSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','id,Due_Date__c,Plan_Statement__c,General_Task__c');
            if(queryFieldNamesefvpSec !=null && queryFieldNamesefvpSec != ''){
                efvplanSec = database.query('select '+queryFieldNamesefvpSec+' from General_Sub_Task__c where RecordType.Name=\'Verification Plans\'  AND General_Task__c =:gTaskId');
            }
            system.debug('inside implementation constructur efvplanSec '+efvplanSec);
            actionplanSecMap = new Map<Id,General_Sub_Task__c>();
            capa_EffectiveVeriFication_setMapActionPlanData();
            
            efvplanSecMap = new Map<Id,General_Sub_Task__c>();
            capa_EffectiveVeriFication_setMapEffectiveVerificationPlanData();
        }catch(Exception ex){
            System.debug('Exception In NC_ActionPlanController   '+ex.getMessage());
        }
		}
        //Capa Implementation Task constuctor end
        
        //Capa Effectiveness Review Task constuctor end
        if(type.containsIgnoreCase('EffectivenessReview')){
        try{
            
        
        List<General_Task__c> implementationIds;
        Id genId,ImplId;
        capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
        queryFieldNamesReviewTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Plan_Statement__c,RecordTypeId,RecordType.Name,General_Task__c');
        queryFieldNamesEffectCheckPlan = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','Id,RecordTypeId,RecordType.Name');
        queryFieldNamesGenTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Completed_Date__c,CreatedDate,Completed_By__c,Completed_By__r.Name,Due_Date__c,Sequence_Position__c,CAPA__c,ownerid,Owner.Name,RecordTypeId,RecordType.Name,Status__c,Approver_1__c,Approver_2__c,Initial_Submitter__c ,Approval_Required__c ,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,ChangeFieldApprovalStatus__c,Approver__c ,Note_To_Approver__c,New_Due_Date__c ,New_Owner__c,New_Owner__r.Name  ,Owner__r.name,Note_To_Approver_Owner_DueDate__c,Objective_Evidence__c,CurrentApprovalSequenceNumber__c');
        //General Task record of type Effectiveness Review
        if(queryFieldNamesGenTask != null && queryFieldNamesGenTask != ''){
            effectTask = database.query('SELECT '+queryFieldNamesGenTask+' FROM General_Task__c WHERE CAPA__c = :capaId AND RecordType.Name=:effectReviewTaskrecordType');
        }
        System.debug('CAPA_Effectiveness_Review_Task effectTask---------------------------->'+effectTask);
        
        //General Sub Task records of type Verification Plan associated to Effectiveness Review
        genId = effectTask.Id;
        System.debug('CAPA_Effectiveness_Review_Task genId---------------------------->'+genId);
        if(queryFieldNamesReviewTask !=null && queryFieldNamesReviewTask != ''){
            effectReviewTask = database.query('SELECT '+queryFieldNamesReviewTask+' FROM General_Sub_Task__c WHERE General_Task__c = :genId AND RecordType.Name = :effectVerificationPlansRecordType');
        }
        System.debug('CAPA_Effectiveness_Review_Task effectReviewTask---------------------------->'+effectReviewTask);
        
        //General Sub Task record Id of type Implementation
        if(queryFieldNamesEffectCheckPlan !=null && queryFieldNamesEffectCheckPlan != ''){
            implementationIds = database.query('SELECT '+queryFieldNamesEffectCheckPlan+' FROM General_Task__c WHERE CAPA__c = :capaId AND RecordType.Name=:ImplementationRecordType');
        }
        System.debug('CAPA_Effectiveness_Review_Task implementationId---------------------------->'+implementationIds);
        
        if(!implementationIds.isEmpty()){
            ImplId = implementationIds[0].Id;
            //General Sub Task records of type Verification Plan associated to Implementation
            if(queryFieldNamesReviewTask !=null && queryFieldNamesReviewTask != ''){
                effectiveCheckPlan = database.query('SELECT '+queryFieldNamesReviewTask+' FROM General_Sub_Task__c WHERE General_Task__c = :ImplId AND RecordType.Name = :effectVerificationPlansRecordType');
            }
            System.debug('CAPA_Effectiveness_Review_Task effectiveCheckPlan---------------------------->'+effectiveCheckPlan);
        }
        }catch(Exception ex){
            System.debug('Exception In Capa Effectiveness Review  '+ex.getMessage());
        }
		}
        //Capa Effectiveness Review Task constuctor end
        
        //Capa Investigation Review Task constuctor end
        if(type.containsIgnoreCase('EffectivenessReview')){
		 try{
           capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
            system.debug('capaid----->'+capaId);
            List<SObject> invobj;
             List<SObject> implobj;
            String ncStatus=null;
            System.debug('CAPATask  capaId   '+capaId);
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Allowed_Days__c,Status__c,Due_Date__c,ChangeFieldApprovalStatus__c,Sequence_Position__c, Owner__c,OwnerName__c,CAPA__c,RecordType.Name,Note_To_Approver__c,CurrentApprovalSequenceNumber__c');
            system.debug('queryFieldNames ---------------------->'+queryFieldNames );
            system.debug('*** before rootcause query ****');
            String rootcausequeryFields =  QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Cause_Code__c,Cause_Code_Description__c,Cause_Code__r.Name');
            system.debug('rootcausequeryFields ---------------------->'+rootcausequeryFields );
            if(queryFieldNames != null && queryFieldNames != ''){
            system.debug('*****inside if of queryFieldNames  capa inv');
            
                invobj=Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE CAPA__c=:capaId AND RecordType.Name=\'Investigation\' ORDER BY Id DESC LIMIT 1');
                if(!invobj.isEmpty()){
                 system.debug('*****inside if of queryFieldNames  capa inv is empty');
                 capaInvTask = new General_Task__c();
                 capaInvTask=(General_Task__c)invobj[0];
                 system.debug('capaInvTask---------------->'+capaInvTask);
                 system.debug('capaInvTask ID---------------->'+capaInvTask.Id);
                }
               
               
            }
           
            else{
                System.debug('CAPA_InvestigationController  : No Acesss to object  General_Task__c and fields to get tasks'+queryFieldNames);
            }
            String invtaskid = capaInvTask.Id;
            if(rootcausequeryFields != null && rootcausequeryFields != ''){
                  rootcauseList  = new List<General_Sub_Task__c>();
                  system.debug('Inside rootcause query*******invtaskid  '+capaInvTask.Id+' '+invtaskid );
                  rootcauseList = Database.query('SELECT '+rootcausequeryFields+' FROM General_Sub_Task__c where General_Task__c =:invtaskid AND RecordType.Name=\'Root Cause\' ');
           } 
             
            rootCauseMap = new Map<Id,General_Sub_Task__c>();
        for(General_Sub_Task__c secObj:rootcauseList){
            rootCauseMap.put(secObj.Id,secObj);// disposition section records
          }
        }catch(Exception ex){
           
           capaInvTask=null;
           //implTask=null;
           rootcauseList =null;
            System.debug('Exception IN CAPA_InvestigationController  '+ex.getMessage()+' '+ ex.getLineNumber());
        }
        }
        //Capa Investigation Review Task constuctor end
        
        
        }
        
        // Change Management starts here  
        
         else if(String.valueOf(ncId.getSobjectType()).containsIgnoreCase('Change_Management__c')){
        // adhoctask starts here
         if(type.containsIgnoreCase('AdhocTask')){
             try{
                capaId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('id'));
               	 gtId = String.escapeSingleQuotes(Apexpages.currentPage().getParameters().get('gtid'));
                queryFieldNamesGenTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,CreatedDate,AdhocTask_Title__c,Due_Date__c,Sequence_Position__c,CAPA__c,ownerid,Owner.Name,RecordTypeId,RecordType.Name,Status__c,Approver_1__c,Approver_2__c,Initial_Submitter__c ,Approval_Required__c ,Approver_3__c,Approver_4__c,Approver_5__c,Approver_6__c,Approver_7__c,Approver_8__c,Approver_9__c,ChangeFieldApprovalStatus__c,Approver__c ,Note_To_Approver__c,New_Due_Date__c ,New_Owner__c,New_Owner__r.Name  ,Owner__r.name,Note_To_Approver_Owner_DueDate__c');
                queryFieldNamesAdhocTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,RecordTypeId,RecordType.Name,Completed_By__c,Completed_By__r.Name,Sub_Task_Detail__c,Completed_Date__c,General_Task__c');
               if(queryFieldNamesGenTask != null && queryFieldNamesGenTask != ''){
                   adhocTask = database.query('SELECT '+queryFieldNamesGenTask+' FROM General_Task__c WHERE Change_Management__c = :capaId AND Id = :gtId AND RecordType.Name=:adhocTaskrecordType');
                   }
            
               if(queryFieldNamesAdhocTask != null && queryFieldNamesAdhocTask != ''){
                   adhocTaskActions = database.query('SELECT '+queryFieldNamesAdhocTask+' FROM General_Sub_Task__c WHERE RecordType.Name=:adhocTaskActionsRecordType AND General_Task__c =: gtId');
                   }
                
                
                }catch(Exception ex){
                     System.debug('Exception In ChangeManagement Adhoc Task Form   '+ex.getMessage())    ;
         
              }
         
           }
         
        }
        
    }

    
    

	//=================================NonConformance===========
    
    ////////////////////////////////////////////////////////////////////
    //NC disposition   start (DispositionController)
    ////////////////////////////////////////////////////////////////////
   public transient General_Task__c gDispTask{get;set;}
    public transient static General_Sub_Task__c dispoSecObj;
    public transient static Disposition_Product__c  dispoProdObj;
    public transient static List<Disposition_Product__c> dispoProdObjects;
    public transient static List<Disposition_Product__c> dispoProdDeleteObjects;
    public transient static List<Disposition_Product__c> dispoProdDel;
    public transient Non_Conformance__c ncr{get;set;}
    transient String queryFieldNamesGenTask,queryFieldNamesNcr,queryFieldNamesClosure;
    transient static String queryFieldsToBeDeleted;
    transient String recordType = 'Disposition';

    

    
       @RemoteAction
    public static Integer saveDisposition(Id dispoTask,Map<String,Map<String,String>> dispositionDetails,Map<String,Map<String,String>> productDetails,List<Id> deletedRowIds,Boolean SubmitwithApproval,Boolean appReqChecked){//appReqChecked,SubmitwithApproval added on 30th dec
        Savepoint sp;
        try{
            if(SubmitwithApproval){
                String queryFieldsGenDispTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Approver__c,Approval_Required__c,isSubmitted__c');
                General_Task__c gTask;
                gTask = database.query('SELECT '+queryFieldsGenDispTask+' from General_Task__c where Id = :dispoTask');
                gTask.isSubmitted__c = 'True';
                String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id');
                List<User> us;
                us = database.query('Select '+queryFieldNamesUsers+' from User where isActive=true');
                if(appReqChecked){
                    gTask.Approval_Required__c = 'Yes';
                    gtask.Approver__c = us[0].Id;
                }else{
                    gTask.Approval_Required__c = 'No';
                }
                upsert gTask;
            }
            System.debug('saveDisposition dispositionDetails ------------------------------------------DispositionController---->>>   '+dispositionDetails);
            System.debug('dispositionDetails.size()-------------------- '+dispositionDetails.size());
            List<General_Sub_Task__c> dispoSecList = new List<General_Sub_Task__c>();
            for(integer i=0;i<dispositionDetails.size();i++){
                dispoSecObj = new General_Sub_Task__c();
                dispoSecObj.Disposition_Type__c = dispositionDetails.get('dispo'+i).get('Disposition_Type__c');
                System.debug('dispositionDetails.get(dispo'+i+').get(Disposition_Type__c)------------------------'+dispositionDetails.get('dispo'+i).get('Disposition_Type__c'));    
                dispoSecObj.Assigned_Disposition_Qty__c = Decimal.valueOf(dispositionDetails.get('dispo'+i).get('Assigned_Disposition_Qty__c'));
                dispoSecObj.Assigned_User__c = dispositionDetails.get('dispo'+i).get('Assigned_User__c');
                dispoSecObj.Due_Date__c = parseLongDate(dispositionDetails.get('dispo'+i).get('Due_Date__c'));
                dispoSecObj.Disposition_Instruction__c = dispositionDetails.get('dispo'+i).get('Disposition_Instruction__c');
                dispoSecObj.Complete__c = dispositionDetails.get('dispo'+i).get('Complete__c');
                if(dispositionDetails.get('dispo'+i).get('Completion_Comment__c') == '' || dispositionDetails.get('dispo'+i).get('Completion_Comment__c') == null || dispoSecObj.Complete__c == 'No'){
                    dispoSecObj.Complete__c = 'No';
                }else{
                    dispoSecObj.Complete__c = 'Yes';
                }
                if(dispoSecObj.Complete__c == 'Yes'){
                    dispoSecObj.Disposition_Type_Status__c = 'Completed';
                    dispoSecObj.Completed_Date__c = parseLongDate(dispositionDetails.get('dispo'+i).get('Completed_Date__c'));
                    dispoSecObj.Completed_By__c = dispositionDetails.get('dispo'+i).get('Completed_By__c');
                    dispoSecObj.Completion_Comment__c = dispositionDetails.get('dispo'+i).get('Completion_Comment__c');
                }else{
                    dispoSecObj.Disposition_Type_Status__c = 'Pending';
                    dispoSecObj.Completion_Comment__c = '';
                    dispoSecObj.Completed_Date__c = null;
                    dispoSecObj.Completed_By__c = null;
                }
                dispoSecObj.General_Task__c = dispoTask;
                dispoSecObj.Approval_Completed__c = 'No';
                dispoSecObj.Id = dispositionDetails.get('dispo'+i).get('Id') != null ? dispositionDetails.get('dispo'+i).get('Id') : dispoSecObj.Id;
                dispoSecObj.RecordTypeId=QC_settings__c.getOrgDefaults().Disposition_Section_RecordTypeId__c;
                dispoSecList.add(dispoSecObj);
            }
            if(!dispoSecList.isEmpty()){
            	upsert dispoSecList;
            }    
            System.debug('saveDisposition dispoSecList----------------- '+dispoSecList);    
            dispoProdObjects = new List<Disposition_Product__c>();
            Boolean present;
            String dispoType;
            for(integer j=0;j<productDetails.size();j++){
                dispoProdObj = new Disposition_Product__c();
                dispoProdObj.NC_ProductId__c = productDetails.get('ProductDetails'+j).get('NC_ProductId__c');
                dispoProdObj.NC_Product__c = productDetails.get('ProductDetails'+j).get('NC_Product__c');
                dispoProdObj.Product_Batch__c = productDetails.get('ProductDetails'+j).get('Product_Batch__c');
                dispoProdObj.Defect_Quantity__c = Decimal.valueOf(productDetails.get('ProductDetails'+j).get('Defect_Quantity__c'));
                dispoProdObj.Dispose_Quantity__c = Decimal.valueOf(productDetails.get('ProductDetails'+j).get('Dispose_Quantity__c'));
                dispoProdObj.Pending_Quantity__c = Decimal.valueOf(productDetails.get('ProductDetails'+j).get('Pending_Quantity__c'));
                present = dispositionDetails.containsKey(productDetails.get('ProductDetails'+j).get('Dispo'));// checking wether dispositionDetails contains particular 'divId' or not 
                if(present){// if dispositionDetails holds the 'divId' then proceeding further
                    for(integer i=0;i<dispositionDetails.size();i++){// iterating over dispositionDetails
                        if(dispositionDetails.get('dispo'+i).get('Dispo') == productDetails.get('ProductDetails'+j).get('Dispo')){//checking the 'divid' of both products and dipositiondetails
                            dispoType = dispositionDetails.get('dispo'+i).get('Disposition_Type__c');//getting the 'Disposition Type' of the divId from dispositiondetails
                            if(dispoType == dispoSecList[i].Disposition_Type__c){// checking the 'Disposition Type' present in dipsoSectList
                                dispoProdObj.General_Sub_Task__c = dispoSecList[i].Id; // if 'Disposition Type' is matched then assigning the 'id' of dispoSecList to 'disposition Product'
                            }
                        }    
                    }
                }    
                //dispoProdObj.General_Sub_Task__c = 
                dispoProdObj.Id = productDetails.get('ProductDetails'+j).get('Id') != null ? productDetails.get('ProductDetails'+j).get('Id') : dispoProdObj.Id;
                dispoProdObjects.add(dispoProdObj);
            }
            
            queryFieldsToBeDeleted = QC_DynamicObjectHandler.getAccessibleFields('Disposition_Product__c','Id,NC_ProductId__c,NC_Product__c,Product_Batch__c,Defect_Quantity__c,Dispose_Quantity__c,Pending_Quantity__c,General_Sub_Task__c');
            if(!deletedRowIds.isEmpty()){
                System.debug('deletedRowIds------------------------------------------------------------------->'+deletedRowIds);
                if(deletedRowIds.size()>0 && deletedRowIds.size() == 1){
                    dispoProdDel = new List<Disposition_Product__c>();
                    dispoProdDel = database.query('SELECT '+queryFieldsToBeDeleted+' from Disposition_Product__c where Id IN : deletedRowIds');
                    System.debug('dispoProdDel------------------------------------------------------------------->'+dispoProdDel);
                    if(!dispoProdDel.isEmpty()){
                        delete dispoProdDel;
                    }    
                }else if(deletedRowIds.size()>1 && !deletedRowIds.isEmpty()){
                    dispoProdDeleteObjects = new List<Disposition_Product__c>();
                    Id rowId;
                    for(integer i=0;i<deletedRowIds.size();i++){
                        rowId = deletedRowIds.get(i);
                        dispoProdDel = new List<Disposition_Product__c>();
                        dispoProdDel = database.query('SELECT '+queryFieldsToBeDeleted+' from Disposition_Product__c where Id =: rowId');
                        System.debug('dispoProdDel------inside multi------------------------------------------------------------->'+dispoProdDel);
                        if(!dispoProdDel.isEmpty()){
                            dispoProdDeleteObjects.add(dispoProdDel[0]);
                        }    
                    }
                    if(!dispoProdDeleteObjects.isEmpty()){
                        delete dispoProdDeleteObjects;
                    }    
                }
            } 
            if(!dispoProdObjects.isEmpty()){
            	upsert dispoProdObjects;
            }    
            return 0;
        }catch(Exception ex){
            System.debug('Exception In DispositionController  getLineNumber '+ex.getLineNumber());
            System.debug('Exception In DispositionController  getCause '+ex.getCause());
            System.debug('Exception In DispositionController  getMessage '+ex.getMessage());
            System.debug('Exception In DispositionController  getStackTraceString '+ex.getStackTraceString());
            System.debug('Exception In DispositionController  getTypeName '+ex.getTypeName());
            Database.rollback(sp);
            return -1;
        }        
    }
    @RemoteAction
    public static Integer checkDispositionCompletionStatus(Id generalTaskId){
        Boolean flag;
        String queryFieldsDispSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Disposition_Type_Status__c');
        String queryFieldsGenDispTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Approval_Required__c,isSubmitted__c');
        General_Task__c gTask;
        gTask = database.query('SELECT '+queryFieldsGenDispTask+' from General_Task__c where Id = :generalTaskId');
        if(queryFieldsDispSec != null && queryFieldsDispSec != ''){
           List<General_Sub_Task__c> dispSec = database.query('SELECT '+queryFieldsDispSec+' from General_Sub_Task__c where General_Task__c = :generalTaskId');
            for(General_Sub_Task__c dSec:dispSec){
                if(dSec.Disposition_Type_Status__c != 'Completed'){
                    if(queryFieldsGenDispTask != null && queryFieldsGenDispTask != ''){
                        gTask.Status__c = 'Disposition Pending Completion';
                        gTask.Approval_Required__c = 'No';
                    	gTask.Note_To_Approver__c='';
                    	List<Approver__c> apps;
                    	String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                    	if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                        	apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:generalTaskId');            
                    	}                            
                    	if(apps != null && apps.size() > 0)
                    	{
                        	if(Approver__c.sObjectType.getDescribe().isDeletable())
                        	{
                            	delete apps;
                        	}
                    	}
                        upsert gTask;
                        return -1;
                    }
                }else{
                    flag = true;
                }
            }
            if(flag){
                if(queryFieldsGenDispTask != null && queryFieldsGenDispTask != ''){
                    gTask = database.query('SELECT '+queryFieldsGenDispTask+' from General_Task__c where Id = :generalTaskId');
                    gTask.Status__c = 'Closed';
                    gTask.Approval_Required__c = 'No';
                    gTask.Note_To_Approver__c='';
                    List<Approver__c> apps;
                    String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                    if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                        apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:generalTaskId');            
                    }                            
                    if(apps != null && apps.size() > 0)
                    {
                        if(Approver__c.sObjectType.getDescribe().isDeletable())
                        {
                            delete apps;
                        }
                    }
                    upsert gTask;
                }
            }
                
        }
        return 0;
    }
    
    @RemoteAction
    public static Integer updateDispositionApprovalRequired(Id generalTaskId,Boolean flag){
        String queryFieldsGenDispTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Approval_Required__c,Approval_Process_Complete__c');
        String queryFieldsDispSec = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Approval_Completed__c,Disposition_Type_Status__c,General_Task__c');
        General_Task__c gTask;
        List<General_Sub_Task__c> dispSecList;
        List<General_Sub_Task__c> dispSecToBeUpdate;
        if(queryFieldsGenDispTask != null && queryFieldsGenDispTask != ''){
            gTask = database.query('SELECT '+queryFieldsGenDispTask+' from General_Task__c where Id = :generalTaskId');
            System.debug('inside gTask.Status__c == Open');
            if(gTask.Status__c == 'Created'){
              gTask.Status__c = 'Created';
            }else{
              gTask.Status__c = 'Open';
            }
            dispSecList = database.query('SELECT '+queryFieldsDispSec+' from General_Sub_Task__c where General_Task__c = :generalTaskId');
            dispSecToBeUpdate = new List<General_Sub_Task__c>();
            if(flag){
                gTask.Approval_Required__c = 'Yes';
            }else{
                gTask.Approval_Required__c = 'No';
                gTask.Note_To_Approver__c='';
                List<Approver__c> apps;
                String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:generalTaskId');            
                }                            
                if(apps != null && apps.size() > 0)
                {
                    if(Approver__c.sObjectType.getDescribe().isDeletable())
                    {
                        delete apps;
                    }
                }
            }    
            gTask.isSubmitted__c = 'False';
            gTask.Approval_Process_Complete__c = false;
            for(General_Sub_Task__c disp:dispSecList){
                disp.Approval_Completed__c = '';
                dispSecToBeUpdate.add(disp);
            }
            upsert dispSecToBeUpdate;
            upsert gTask;
        }    
        return 0;
    }    
    ////////////////////////////////////////////////////////////////////
    //NC disposition   end (DispositionController)
    ////////////////////////////////////////////////////////////////////    
    
    ////////////////////////////////////////////////////////////////////
    //NC Implementation   start (NC_ActionPlanController)
    //////////////////////////////////////////////////////////////////// 
   public transient Id ncId{get;set;}
   public transient General_Task__c actionplanTask{get;set;}
   public transient static General_Sub_Task__c actplanObj;
   public transient List<General_Sub_Task__c> actionplanSec;
   public transient Map<Id,General_Sub_Task__c> actionplanSecMap{get;set;}
   //String queryFieldNamesGenTask,queryFieldNamesapSec,queryFieldNamesNcr;
   transient string queryFieldNamesapSec;
   //String recordType = 'Implementation';
   
       
    
   
    
     @RemoteAction
    public static Integer saveActionPlan(Id actplanTask,Map<String,String> actoionPlanDetails,Boolean SubmitwithApproval,Boolean appReqChecked){
            Savepoint sp;
            System.debug('SubmitwithApproval...'+SubmitwithApproval+'appReqChecked...'+appReqChecked+'actplanTask...'+actplanTask); 
            if(!SubmitwithApproval){
                System.debug('SubmitwithApproval...'+SubmitwithApproval);
                String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Approval_Required__c,isSubmitted__c,Approver__c');
                General_Task__c gTask;
                gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :actplanTask');
                gTask.isSubmitted__c = 'True';
                List<User> us = [Select Id from User limit 1];
                if(appReqChecked){
                    gTask.Approval_Required__c = 'Yes';
                    gtask.Approver__c = us[0].Id;
                }else{
                    gTask.Approval_Required__c = 'No';
                    gTask.Note_To_Approver__c='';
                    List<Approver__c> apps;
                    String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                    if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                        apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:actplanTask');            
                    }                            
                    if(apps != null && apps.size() > 0)
                    {
                        if(Approver__c.sObjectType.getDescribe().isDeletable())
                        {
                            delete apps;
                        }
                    }                    
                }
                upsert gTask;
                System.debug('gTask.Approval_Required__c...'+gTask.Approval_Required__c+'gtask.Approver__c...'+gtask.Approver__c);
            }
            actplanObj = new General_Sub_Task__c();
            system.debug('actplanTask...'+actplanTask);
            //actplanObj.Id = actoionPlanDetails.get('Id');    
            actplanObj.Title__c = actoionPlanDetails.get('Title__c');
            actplanObj.Description__c = actoionPlanDetails.get('Description__c');
            actplanObj.Type__c = actoionPlanDetails.get('Type__c');    
            actplanObj.Assigned_User__c = actoionPlanDetails.get('Assigned_User__c');
            actplanObj.Due_Date__c = parseLongDate(actoionPlanDetails.get('Due_Date__c'));
            actplanObj.Associated_Root_Causes__c = actoionPlanDetails.get('Associated_Root_Causes__c');
            actplanObj.Complete__c = actoionPlanDetails.get('Completed__c');
            //actplanObj.Completed_By__c = actoionPlanDetails.get('Completed_By__c');
            //actplanObj.Completed_Date__c = parseLongDate(actoionPlanDetails.get('Completed_Date__c'));
            //actplanObj.Completion_Comments__c = actoionPlanDetails.get('Completion_Comments__c');
            if(actplanObj.Complete__c == 'Yes'){
                actplanObj.Completed_Date__c = parseLongDate(actoionPlanDetails.get('Completed_Date__c'));
                actplanObj.Completed_By__c = actoionPlanDetails.get('Completed_By__c');
                actplanObj.Completion_Comments__c = actoionPlanDetails.get('Completion_Comments__c');
            }else{
                actplanObj.Completion_Comments__c = '';
                actplanObj.Completed_Date__c = null;
                actplanObj.Completed_By__c = null;
            }
            actplanObj.Associated_Root_Cause_Name__c = actoionPlanDetails.get('Associated_Root_Cause_Name__c');
            actplanObj.General_Task__c = actplanTask;
          actplanObj.Pend_Save_ActionPlan__c = 'Yes';
          actplanObj.RecordTypeId=QC_settings__c.getOrgDefaults().Action_Plan_RecordTypeId__c;
            actplanObj.Id = actoionPlanDetails.get('Id') != null ? actoionPlanDetails.get('Id') : actplanObj.Id;
            system.debug('actplanObj.Type__c ...'+actplanObj.Type__c);
        if(actplanObj.Id != NULL || actplanObj.Id != ''){
           upsert actplanObj; 
        }
        else{
        insert actplanObj;
        }
        return 0;
        
    }
    
    
    
    
       @RemoteAction
    public static Integer updateAPApprovalRequired(Id generalTaskId,Boolean flag){
        String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Approval_Required__c,Approval_Process_Complete__c');
        General_Task__c gTask;
        if(queryFieldsGenapTask != null && queryFieldsGenapTask != ''){
            gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :generalTaskId');
            //System.debug('inside gTask.Status__c == Open');
            //gTask.Status__c = 'Open';
            if(flag){
                gTask.Approval_Required__c = 'Yes';
            }else{
                gTask.Approval_Required__c = 'No';
                gTask.Note_To_Approver__c='';
                List<Approver__c> apps;
                String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:generalTaskId');            
                }                            
                if(apps != null && apps.size() > 0)
                {
                    if(Approver__c.sObjectType.getDescribe().isDeletable())
                    {
                        delete apps;
                    }
                }                
            }    
            //-------------------------------------------
            //gTask.Approval_Process_Complete__c = true;
            upsert gTask;
            System.debug('gTask.Approval_Required__c'+gTask.Approval_Required__c);
        }    
        return 0;
    }
    
    @RemoteAction
    public static Boolean RecallwithoutApproval(string taskId,string status){
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Status__c');
        if(queryFieldSOfGT != null && queryFieldSOfGT != ''){
           
            List<General_Task__c> GT = database.query('Select '+ queryFieldSOfGT +' from General_Task__c where id =: taskId');
            system.debug('status of generaltask'+status);
            if(status=='Pending ActionPlan'){
                  GT[0].Status__c='Open';
            }
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c', 'update'))
            {
                update GT;
            }
            System.debug('update GT'+GT[0].Status__c);
        }
       
       return true; 
    }
    
    
    
    ////////////////////////////////////////////////////////////////////
    //NC Implementation   end (NC_ActionPlanController)
    ////////////////////////////////////////////////////////////////////         
    
    ////////////////////////////////////////////////////////////////////
    //NC Investigation start (NC_Investigation_Form)
    ////////////////////////////////////////////////////////////////////
    public transient Id ncpid{get; set;}
    Public transient General_Task__c genTask{get;set;}
    

    @RemoteAction
    public static General_Sub_Task__c getRemoteRoot_Cause(String rcid){
        
             String qry;
            try{
             String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Against__c,Cause_Code__r.Name,Cause_Code_Description__c,Defect__r.Name,Defect_Description__c,General_Task__c,Process__r.Name,Product__r.Name');
               if(queryFieldNames != null && queryFieldNames != '')
            {
              qry='select ' + queryFieldNames + ' from General_Sub_Task__c where id = :rcid limit 1';
                          
            }
            }catch(Exception ex){
            System.debug('Exception In NC_Investigation_Form   '+ex.getMessage());
        }  
         if(rcid != null )
        return database.query(qry);
        
    
        else
            return new  General_Sub_Task__c();  
        //return null;
    }
    
    @remoteAction
    public static boolean deleteRootCause(string id){
        Savepoint sp = Database.setSavepoint();
        List<General_Sub_Task__c> rc = [select id from General_Sub_Task__c where id = :id];
        try{
            if(rc != null && rc.size() > 0)
                if(General_Sub_Task__c.sObjectType.getDescribe().isDeletable()){
                delete rc; 
                }
            return true;
        }catch(exception e){
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.PROD);      
            return false;
        } 
    }
    public  List<General_Sub_Task__c> getRRemoteRoot_Cause(){
         String qry;
        try{
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'id,Against__c,Cause_Code__r.Name,Cause_Code_Description__c,Defect__r.Name,Defect_Description__c,General_Task__c,Process__r.Name,Product__r.Name');   
           if(queryFieldNames != null && queryFieldNames != '')
            {
             qry='select ' + queryFieldNames + ' from General_Sub_Task__c where General_Task__c = :ncpid';   
             System.debug('qry from getRRemoteRoot_Cause rootcause------->'+qry); 
            }
            
        }catch(Exception ex){
            System.debug('Exception In NC_Investigation_Form   '+ex.getMessage());
        }  
        if(ncpid != null )
         return database.query(qry);
        else
            return new  List<General_Sub_Task__c>();  
        //return null;
    }
    
    @RemoteAction
    public static Cause__c getCauseDetails(String causeId){
        String qry;
         try{
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Cause__c', 'id,Cause_Description__c');   
           if(queryFieldNames != null && queryFieldNames != '')
            {
             qry='select ' + queryFieldNames + ' from Cause__c where id = :causeId limit 1';   
             System.debug('qry from getCauseDetails------->'+qry); 
            }
            
        }catch(Exception ex){
            System.debug('Exception In NC_Investigation_Form   '+ex.getMessage());
        } 
        
        if(causeId!=null){
            System.debug('inside NC_Investigation_Form getCauseDetails'+causeId);
            return database.query(qry);
           /* return [select id,
                    Cause_Description__c
                    from Cause__c where id = :causeId limit 1]; */
        }else{
            return new Cause__c();
        }
    }  
    
    @RemoteAction
    public static Defect__c getDefectDetails(String defectId){
         String qry;
         try{
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Defect__c', 'id,Defect_Description__c');   
           if(queryFieldNames != null && queryFieldNames != '')
            {
             qry='select ' + queryFieldNames + ' from Defect__c where id = :defectId limit 1';   
             System.debug('qry from getCauseDetails------->'+qry); 
            }
            
        }catch(Exception ex){
            System.debug('Exception In NC_Investigation_Form   '+ex.getMessage());
        } 
        if(defectId!=null){
            System.debug('inside NC_Investigation_Form getDefectDetails'+defectId);
            return database.query(qry);
            /*return [select id,
                    Defect_Description__c
                    from Defect__c where id = :defectId limit 1]; */
        }else{
            return new Defect__c();
        }
    }
   
    @RemoteAction
    public static Boolean updateInvestigationTask(String gtId, String invSummary, String invTool,Boolean appReqChecked,Boolean isClose){
     General_Task__c gt;
        system.debug('updateInvestigationTask.gt--------------------->' + gtId +' '+ invSummary+ ' ' +invTool);
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Investigation_Summary__c,Investigation_Tools__c,Approval_Required__c,approver__c');
        if(queryFieldNames != null && queryFieldNames != '')
            {
              List<General_Task__c> gTasks= database.query('select ' + queryFieldNames + ' from General_Task__c where Id = :gtId');   
              gt = gTasks[0];
              gt.Investigation_Summary__c = invSummary.trim();
              gt.Investigation_Tools__c = invTool;
                if(appReqChecked){
                  System.debug('appReqChecked--------------->'+appReqChecked)  ;
                    gt.Approval_Required__c = 'Yes';
                    gt.approver__c=UserInfo.getUserId();
                }else{
                    gt.Approval_Required__c = 'No';
                    gt.Note_To_Approver__c='';
                    List<Approver__c> apps;
                    String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                    if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                        apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:gtId');            
                    }                            
                    if(apps != null && apps.size() > 0)
                    {
                        if(Approver__c.sObjectType.getDescribe().isDeletable())
                        {
                            delete apps;
                        }
                    }                    
                    
                    
                }
                if(isClose){
                    gt.status__c='Closed';
                }
                                                           
            }
            
       
        System.debug('updateInvestigationTask--------------------->'+gt);
           if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Investigation_Summary__c,Investigation_Tools__c,Approval_Required__c,approver__c', 'update'))
             {
                update gt;
             }
        System.debug('after gt');               
        return true;
    }
    
    
     Public transient Map<id,User> User{get;set;}

    ////////////////////////////////////////////////////////////////////
    //NC Investigation END (NC_Investigation_Form)
    ////////////////////////////////////////////////////////////////////

    
    //====================CAPA==================================
    
    
    ////////////////////////////////////////////////////////////////////
    //CAPA AdhocTask Start (CAPA_AdhocTaskController)
    ////////////////////////////////////////////////////////////////////
        Id capaId{get;set;}
        public List<General_Task__c> adhocTask{get;set;}
        //String queryFieldNamesGenTask;
        string queryFieldNamesAdhocTask;
        String adhocTaskrecordType = 'AdhocTask';
        String adhocTaskActionsRecordType = 'AdhocTask Actions';
        public List<General_Sub_Task__c> adhocTaskActions{get;set;}
        
        @RemoteAction
        public static Integer CAPA_AdhocTask_saveAdhocActions(Id adhocTaskId, Map<String,Map<String,String>> adhocActions){ 
            Savepoint sp;
            try{
                System.debug('CAPA_AdhocTaskController saveAdhocActions------------------------------> '+adhocActions);
                List<General_Sub_Task__c> adhocTaskActionList = new List<General_Sub_Task__c>();
                General_Sub_Task__c aTaskAction;
                General_Task__c genTask = new General_Task__c();
                for(integer i=1;i<=adhocActions.size();i++){
                    aTaskAction = new General_Sub_Task__c();
                    aTaskAction.General_Task__c = adhocTaskId;
                    aTaskAction.Id = adhocActions.get('adhocAction'+i).get('id') != null ? adhocActions.get('adhocAction'+i).get('id'): aTaskAction.Id;
                    aTaskAction.RecordTypeId = QC_settings__c.getOrgDefaults().AdhocTask_Actions_RecordTypeId__c;
                    aTaskAction.Completed_By__c = adhocActions.get('adhocAction'+i).get('completedBy');
                    aTaskAction.Sub_Task_Detail__c = adhocActions.get('adhocAction'+i).get('detail');
                    aTaskAction.Completed_Date__c = Date.parse(adhocActions.get('adhocAction'+i).get('completedDate'));
                    adhocTaskActionList.add(aTaskAction);
                }
                if(!adhocTaskActionList.isEmpty()){
                    upsert adhocTaskActionList;
                }
                return 0;
            }catch(Exception ex){
                System.debug('Exception In CAPA_AdhocTaskController  getLineNumber '+ex.getLineNumber());
                System.debug('Exception In CAPA_AdhocTaskController  getCause '+ex.getCause());
                System.debug('Exception In CAPA_AdhocTaskController  getMessage '+ex.getMessage());
                System.debug('Exception In CAPA_AdhocTaskController  getStackTraceString '+ex.getStackTraceString());
                System.debug('Exception In CAPA_AdhocTaskController  getTypeName '+ex.getTypeName());
                Database.rollback(sp);
                return -1;
            }        
        }
        
        
        @RemoteAction
        public static Integer changeMgmt_AdhocTask_saveAdhocActions(Id adhocTaskId, Map<String,Map<String,String>> adhocActions){ 
            Savepoint sp;
            try{
                System.debug('CAPA_AdhocTaskController saveAdhocActions------------------------------> '+adhocActions);
                List<General_Sub_Task__c> adhocTaskActionList = new List<General_Sub_Task__c>();
                General_Sub_Task__c aTaskAction;
                General_Task__c genTask = new General_Task__c();
                for(integer i=1;i<=adhocActions.size();i++){
                    aTaskAction = new General_Sub_Task__c();
                    aTaskAction.General_Task__c = adhocTaskId;
                    aTaskAction.Id = adhocActions.get('adhocAction'+i).get('id') != null ? adhocActions.get('adhocAction'+i).get('id'): aTaskAction.Id;
                    aTaskAction.RecordTypeId = QC_settings__c.getOrgDefaults().AdhocTask_Actions_RecordTypeId__c;
                    aTaskAction.Completed_By__c = adhocActions.get('adhocAction'+i).get('completedBy');
                    aTaskAction.Sub_Task_Detail__c = adhocActions.get('adhocAction'+i).get('detail');
                    aTaskAction.Completed_Date__c = Date.parse(adhocActions.get('adhocAction'+i).get('completedDate'));
                    adhocTaskActionList.add(aTaskAction);
                }
                if(!adhocTaskActionList.isEmpty()){
                    upsert adhocTaskActionList;
                }
                return 0;
            }catch(Exception ex){
                System.debug('Exception In CAPA_AdhocTaskController  getLineNumber '+ex.getLineNumber());
                System.debug('Exception In CAPA_AdhocTaskController  getCause '+ex.getCause());
                System.debug('Exception In CAPA_AdhocTaskController  getMessage '+ex.getMessage());
                System.debug('Exception In CAPA_AdhocTaskController  getStackTraceString '+ex.getStackTraceString());
                System.debug('Exception In CAPA_AdhocTaskController  getTypeName '+ex.getTypeName());
                Database.rollback(sp);
                return -1;
            }        
        }
        
    /*
        @RemoteAction
        public static List<String> getCapaTaskOwners(){
            List<String> data;
            List<User> users=new List<User>();
            String queryFieldNamesUsers = QC_DynamicObjectHandler.getAccessibleFields('User','Id,Name');
            Boolean active = true;
            String role = 'CAPA_Task_Owner';
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
        */
        @RemoteAction
        public static Integer Capa_AdhocTask_deleteAdhocAction(Id divId){
            Savepoint sp;
            try{
                String queryFieldNamesAdhocAction = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,RecordTypeId,RecordType.Name,Completed_By__c,Completed_By__r.Name,Sub_Task_Detail__c,Completed_Date__c,General_Task__c');
                List<General_Sub_Task__c> adhocActions;
                if(queryFieldNamesAdhocAction !=null && queryFieldNamesAdhocAction != ''){
                    adhocActions = database.query('SELECT '+queryFieldNamesAdhocAction+' FROM General_Sub_Task__c WHERE Id = :divId');
                }
                if(!adhocActions.isEmpty()){
                    delete adhocActions;
                }    
                return 0;
            }catch(Exception ex){
                System.debug('Exception CAPA_AdhocTaskController.deleteAdhocAction   '+ex.getMessage());
                Database.rollback(sp);
                return -1;
            }
        }
        
        
         @RemoteAction
        public static Integer changeMgmt_AdhocTask_deleteAdhocAction(Id divId){
            Savepoint sp;
            try{
                String queryFieldNamesAdhocAction = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,RecordTypeId,RecordType.Name,Completed_By__c,Completed_By__r.Name,Sub_Task_Detail__c,Completed_Date__c,General_Task__c');
                List<General_Sub_Task__c> adhocActions;
                if(queryFieldNamesAdhocAction !=null && queryFieldNamesAdhocAction != ''){
                    adhocActions = database.query('SELECT '+queryFieldNamesAdhocAction+' FROM General_Sub_Task__c WHERE Id = :divId');
                }
                if(!adhocActions.isEmpty()){
                    delete adhocActions;
                }    
                return 0;
            }catch(Exception ex){
                System.debug('Exception CAPA_AdhocTaskController.deleteAdhocAction   '+ex.getMessage());
                Database.rollback(sp);
                return -1;
            }
        }
    
    ////////////////////////////////////////////////////////////////////
    //CAPA AdhocTask END (CAPA_AdhocTaskController)
    ////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////
    //CAPA Implementation END (CAPA_ActionPlanController)
    ////////////////////////////////////////////////////////////////////
    string queryFieldNamesCapar,queryFieldNamesefvpSec;
    public List<General_Sub_Task__c> efvplanSec;
    
    public Map<Id,General_Sub_Task__c> efvplanSecMap{get;set;}
    //public CAPA__c capa{get;set;} 
    
    public void capa_EffectiveVeriFication_setMapActionPlanData(){
        Set<String> actionplanSecId=new Set<String>();
        for(General_Sub_Task__c secObj:actionplanSec){
            actionplanSecMap.put(secObj.Id,secObj);// ActionPlan section 
            actionplanSecId.add(secObj.Id);
        }
    }
    public void capa_EffectiveVeriFication_setMapEffectiveVerificationPlanData(){
        Set<String> efvplanSecId=new Set<String>();
        for(General_Sub_Task__c secObj:efvplanSec){
            efvplanSecMap.put(secObj.Id,secObj);// EffectiveVerificationPlan section 
            efvplanSecId.add(secObj.Id);
        }
    }
    @RemoteAction
    public static Integer Capa_ActionPlan_saveActionPlan(List<List<String>> aplist, String impltaskId,Boolean SubmitwithApproval,Boolean appReqChecked,String efvpchecked){
        
        Savepoint sp;
        Boolean efvplan;
        System.debug('SubmitwithApproval...'+SubmitwithApproval+'appReqChecked...'+appReqChecked+'impltaskId...'+impltaskId+'  efvpchecked..'+efvpchecked); 
        
        System.debug('SubmitwithApproval...'+SubmitwithApproval);
        String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Approval_Required__c,isSubmitted__c,Approver__c,Add_Effectiveness_verificiation__c');
        General_Task__c gTask;
        gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :impltaskId');
        if(!SubmitwithApproval){ 
            System.debug('SubmitwithApproval...'+SubmitwithApproval+'isSubmitted__c'+gTask.isSubmitted__c);
            gTask.isSubmitted__c = 'True';
            List<User> us = [Select Id from User limit 1];
            if(appReqChecked){
                gTask.Approval_Required__c = 'Yes';
                gtask.Approver__c = us[0].Id;
            }else{
                gTask.Approval_Required__c = 'No';
                gTask.Note_To_Approver__c='';
                List<Approver__c> apps;
                String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:impltaskId');            
                }                            
                if(apps != null && apps.size() > 0)
                {
                    if(Approver__c.sObjectType.getDescribe().isDeletable())
                    {
                        delete apps;
                    }
                }                  
            }
        }
        if(efvpchecked == 'Yes'){
            efvplan = true; 
        }else{
            efvplan = false;
        }
        gtask.Add_Effectiveness_verificiation__c = efvplan;
        
        upsert gTask;
        System.debug('gTask.Approval_Required__c...'+gTask.Approval_Required__c+'gtask.Approver__c...'+gtask.Approver__c+'  gtask.Add_Effectiveness_verificiation__c..'+gtask.Add_Effectiveness_verificiation__c);
        
        
        System.debug('aplist to save---------->'+aplist);
               
        List<General_Sub_Task__c> apObjs = new List<General_Sub_Task__c>();
        System.debug('aplist size--------->'+aplist.size());
        
        Integer apcount = aplist.size();
        for(Integer i=0;i<apcount;i++){
        	General_Sub_Task__c actplanObjs = new General_Sub_Task__c();
            system.debug('actplanObjs before assigne'+aplist);
            system.debug('actplanObjs before assigne'+aplist[i]);
            actplanObjs.Id = aplist[i][11]!='null'?Id.valueOf(aplist[i][11]): actplanObjs.id;
            actplanObjs.Type__c = aplist[i][0];   
            actplanObjs.Title__c = aplist[i][1];
            actplanObjs.Description__c = aplist[i][2];
            actplanObjs.Associated_Root_Causes__c = aplist[i][3];
            actplanObjs.Associated_Root_Cause_Name__c = aplist[i][4]; 
            actplanObjs.Assigned_User__c = aplist[i][5];
            actplanObjs.Due_Date__c = parseLongDate(aplist[i][6]);
            system.debug('aplist[i][7]'+aplist[i][7]);
            actplanObjs.Complete__c = aplist[i][7];
            if(actplanObjs.Complete__c == 'Yes'){
                actplanObjs.Completed_By__c = aplist[i][8];
                actplanObjs.Completed_Date__c = parseLongDate(aplist[i][9]);
                actplanObjs.Completion_Comments__c = aplist[i][10];
            }else{
                actplanObjs.Completed_By__c = null;
                actplanObjs.Completed_Date__c = null;
                actplanObjs.Completion_Comments__c = '';
            }
            actplanObjs.General_Task__c = impltaskId;
            actplanObjs.Pend_Save_ActionPlan__c = 'Yes';
            actplanObjs.RecordTypeId=QC_custom_settings.getActionPlanId();
            system.debug('actplanObjs.Type__c ...'+actplanObjs.Type__c);
            
            apObjs.add(actplanObjs);
        }
        system.debug('apObjs----------->'+apObjs);
        upsert apObjs; 
        System.debug('Objects created success............');
        
        return 0;
    }
    
    @RemoteAction
    public static Integer CAPA_EffectiveVerification_saveEfvpPlan(List<List<String>> efvplist, String impltaskId){
        System.debug('efvplist to save---------->'+efvplist);
        System.debug('impltaskId--------->'+impltaskId);
       
        List<General_Sub_Task__c> efvpobjs = new List<General_Sub_Task__c>();
        System.debug('efvplist size--------->'+efvplist.size());
		Integer efvpcount = efvplist.size();
        for (Integer i = 0; i <efvpcount; i++) {
            System.debug('efvplist['+i+']----------->'+efvplist[i]);
			General_Sub_Task__c efvp = new General_Sub_Task__c();
            efvp.id =efvplist[i][1]!='null'?Id.valueOf(efvplist[i][1]): efvp.id;
            efvp.Plan_Statement__c=efvplist[i][0];
            efvp.General_Task__c = impltaskId;
            efvp.RecordTypeId=QC_custom_settings.getVerificationPlanId();
            efvpobjs.add(efvp);
        }
        
        system.debug('efvpobjs----------->'+efvpobjs);
        upsert  efvpobjs;
        System.debug('Objects created success............');
        return 0;
        
    }
    @RemoteAction
    public static Boolean Capa_Implementation_RecallwithoutApproval(string taskId,string status){
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Status__c,isSubmitted__c');
        if(queryFieldSOfGT != null && queryFieldSOfGT != ''){
           
            List<General_Task__c> GT = database.query('Select '+ queryFieldSOfGT +' from General_Task__c where id =: taskId');
            system.debug('status of generaltask'+status);
            if(status=='Pending ActionPlan'){
                  GT[0].Status__c='Open';
                  GT[0].isSubmitted__c = 'False';
            }
            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c,isSubmitted__c', 'update'))
            {
                update GT;
            }
            System.debug('update GT'+GT[0].Status__c);
        }
       
       return true; 
    }
    
    @RemoteAction
    public static Integer Capa_Implementation_updateApprovalRequired(Id generalTaskId,Boolean flag){
        String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c,Approval_Required__c,Approval_Process_Complete__c');
        General_Task__c gTask;
        if(queryFieldsGenapTask != null && queryFieldsGenapTask != ''){
            gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :generalTaskId');
            //System.debug('inside gTask.Status__c == Open');
            //gTask.Status__c = 'Open';
            if(flag){
                gTask.Approval_Required__c = 'Yes';
            }else{
                gTask.Approval_Required__c = 'No';
            }    
            //-------------------------------------------
            //gTask.Approval_Process_Complete__c = true;
            upsert gTask;
            System.debug('gTask.Approval_Required__c'+gTask.Approval_Required__c);
        }    
        return 0;
    }
    ////////////////////////////////////////////////////////////////////
    //CAPA Implementation END (CAPA_ActionPlanController)
    ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //CAPA Investigation  Start (CAPA_ActionPlanController)
    ////////////////////////////////////////////////////////////////////   
    public static General_Task__c capaInvTask{get;set;}    
    public static  Map<Id,General_Sub_Task__c> rootCauseMap{get;set;}
    public static List<General_Sub_Task__c> rootcauseList{get;set;}
    @RemoteAction
    public static Boolean Capa_update_InvestigationCurrentRecord(Id generalTaskId){
        System.debug('generalTaskId'+generalTaskId);
        String queryFieldsGenapTask = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Status__c');
        General_Task__c gTask;
        if(queryFieldsGenapTask != null && queryFieldsGenapTask != ''){
            gTask = database.query('SELECT '+queryFieldsGenapTask+' from General_Task__c where Id = :generalTaskId');
            System.debug('before gTask.Status__c'+gTask.Status__c);
            gTask.Status__c = 'Closed';
               
            upsert gTask;
            System.debug('After gTask.Status__c'+gTask.Status__c);
        }    
        return true;
    }
    
    @RemoteAction
    public static Boolean CAPA_Investigation_saveRootCauses(List<List<String>> rclist, String invtaskId,String invSummary, String invTool,Boolean appReqChecked,Boolean SubmitwithApproval){
        System.debug('rclist to save---------->'+rclist);
        //system.debug('existingcauses---------->'+existingcauses);
        System.debug('invtaskId--------->'+invtaskId+'<-------invSummary---------------->'+invSummary+'invTool--------->'+invTool);
       // Map<String,General_Sub_Task__c> existingTaskWithId=new Map<String,General_Sub_Task__c>();
        List<General_Sub_Task__c> rcobjs = new List<General_Sub_Task__c>();
        System.debug('rclist size--------->'+rclist.size());
		Integer causecount = rclist.size();
       for (Integer i = 0; i <causecount; i++) {
            System.debug('rclist['+i+']----------->'+rclist[i]);
			General_Sub_Task__c rcause = new General_Sub_Task__c();
            rcause.id =rclist[i][2]!='null'?Id.valueOf(rclist[i][2]): rcause.id;
            rcause.Cause_Code__c =rclist[i][0];
            rcause.Cause_Code_Description__c=rclist[i][1];
            rcause.General_Task__c = invtaskId;
            rcause.RecordTypeId=QC_custom_settings.getRootCauseId();
            rcobjs.add(rcause);
        }
         General_Task__c gt;
         String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Investigation_Summary__c,Investigation_Tools__c,Approval_Required__c,approver__c'); 
      	 if(queryFieldNames != null && queryFieldNames != '')
         {
             List<General_Task__c> gTasks= database.query('select ' + queryFieldNames + ' from General_Task__c where Id = :invtaskId');
             gt = gTasks[0];
             gt.Investigation_Summary__c = invSummary.trim();
             gt.Investigation_Tools__c = invTool;
             if(appReqChecked){
                 System.debug('appReqChecked--------------->'+appReqChecked)  ;
                 gt.Approval_Required__c = 'Yes';
                 gt.approver__c=UserInfo.getUserId();
             }else{
                    gt.Approval_Required__c = 'No';
                    gt.Note_To_Approver__c='';
                    List<Approver__c> apps;
                    String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                    if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                        apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:invtaskId');            
                    }                            
                    if(apps != null && apps.size() > 0)
                    {
                        if(Approver__c.sObjectType.getDescribe().isDeletable())
                        {
                            delete apps;
                        }
                    }                    
                    
                    
                }
            
             
             
         }
         System.debug('updateInvestigationTask--------------------->'+gt);
           if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','status__c,Investigation_Summary__c,Investigation_Tools__c,Approval_Required__c,approver__c,Note_To_Approver__c', 'update'))
             {
                update gt;
             }
        
        
        system.debug('rcobjs----------->'+rcobjs);
        upsert  rcobjs;
        System.debug('Objects created success............');
        return true;
        
    }
    ////////////////////////////////////////////////////////////////////
    //CAPA Investigation  END (CAPA_ActionPlanController)
    //////////////////////////////////////////////////////////////////// 
    
    ////////////////////////////////////////////////////////////////////
    //CAPA EffectivenessReview  start (CAPA_ActionPlanController)
    //////////////////////////////////////////////////////////////////// 
    public General_Task__c effectTask{get;set;}
    public List<General_Sub_Task__c> effectReviewTask{get;set;}
    public List<General_Sub_Task__c> effectiveCheckPlan{get;set;}
    String queryFieldNamesReviewTask,queryFieldNamesEffectCheckPlan;
    String effectReviewTaskrecordType = 'EffectivenessReview';
    String effectVerificationPlansRecordType = 'Verification Plans';
    String ImplementationRecordType = 'Implementation';    
    @RemoteAction
    public static Integer Capa_EffectivenessReview_saveVerificationPlans(Id effectTask, Map<String,Map<String,String>> verificationPlans,Map<String,String> effectivenessReviewDetails){
        Savepoint sp;
        try{
            List<General_Sub_Task__c> verificationPlanList = new List<General_Sub_Task__c>();
            General_Sub_Task__c verificationPlan;
            General_Task__c genTask = new General_Task__c();
            for(integer i=1;i<=verificationPlans.size();i++){
                verificationPlan = new General_Sub_Task__c();
                verificationPlan.General_Task__c = effectTask;
                verificationPlan.Id = verificationPlans.get('plan'+i).get('id') != null ? verificationPlans.get('plan'+i).get('id'): verificationPlan.Id;
                verificationPlan.RecordTypeId=QC_custom_settings.getVerificationPlanId();
                verificationPlan.Plan_Statement__c = verificationPlans.get('plan'+i).get('planStmt');
                verificationPlanList.add(verificationPlan);
            }
            if(!verificationPlanList.isEmpty()){
                upsert verificationPlanList;
            }
            
            genTask.Objective_Evidence__c = effectivenessReviewDetails.get('objectiveEvidence');
            genTask.Completed_By__c = effectivenessReviewDetails.get('completedBy');
            genTask.Completed_Date__c = Date.parse(effectivenessReviewDetails.get('completedDate'));
            //genTask.Allowed_Days__c = 5;
            genTask.Id = effectTask;
            upsert genTask;        
            return 0;
        }catch(Exception ex){
            System.debug('Exception In CAPA_Effectiveness_Review_Task  getLineNumber '+ex.getLineNumber());
            System.debug('Exception In CAPA_Effectiveness_Review_Task  getCause '+ex.getCause());
            System.debug('Exception In CAPA_Effectiveness_Review_Task  getMessage '+ex.getMessage());
            System.debug('Exception In CAPA_Effectiveness_Review_Task  getStackTraceString '+ex.getStackTraceString());
            System.debug('Exception In CAPA_Effectiveness_Review_Task  getTypeName '+ex.getTypeName());
            Database.rollback(sp);
            return -1;
        }        
    }

	@RemoteAction
    public static Integer Capa_EffectivenessReview_deleteVerificationPlan(Id verificationId){
        Savepoint sp;
        try{
            String queryFieldNamesVerificationTask = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c','Id,Plan_Statement__c');
            List<General_Sub_Task__c> verificationPlans;
            if(queryFieldNamesVerificationTask !=null && queryFieldNamesVerificationTask != ''){
            	verificationPlans = database.query('SELECT '+queryFieldNamesVerificationTask+' FROM General_Sub_Task__c WHERE Id = :verificationId');
        	}
            if(!verificationPlans.isEmpty()){
            	delete verificationPlans;
            }    
            return 0;
        }catch(Exception ex){
            System.debug('Exception CAPA_Effectiveness_Review_Task.deleteVerificationPlan   '+ex.getMessage());
            Database.rollback(sp);
            return -1;
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    //CAPA EffectivenessReview  start (CAPA_ActionPlanController)
    //////////////////////////////////////////////////////////////////// 
    
    ////////////////////////////////////////////////////////////////////
    //CAPA Closure  start (saveClosureTask)
    //////////////////////////////////////////////////////////////////// 
	@RemoteAction
    public static Integer Capa_Closure_saveClosureTask(Id capaId,String recordType,String capaEffect,String createCapa,String closureComment,Boolean approvalCheck,Boolean submitWithApproval){
    	Savepoint sp;
        try{
        	General_Task__c closure;
        	Id taskId;
        	List<General_Task__c> closureList = new List<General_Task__c>();
        	String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','Id,CAPA_Effectiveness__c,CAPA__c,Status__c,Approval_Required__c,Create_New_CAPA__c,Note_To_Approver__c,Closure_Comment__c,RecordType.Name,RecordTypeId');
        	if(queryFieldNames != null && queryFieldNames != ''){
            	closure = Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE CAPA__c=:capaId AND RecordType.Name =:recordType');
            	taskId = closure.Id;
            	closure.CAPA_Effectiveness__c = capaEffect;
            	if(capaEffect == 'Effective'){
            		closure.Create_New_CAPA__c = 'No';
            	}else{
                	closure.Create_New_CAPA__c = createCapa;
            	}    
            	closure.Closure_Comment__c = closureComment;
            	if(!approvalCheck){
                	closure.Approval_Required__c = 'No';
                	closure.Note_To_Approver__c = '';
                	if(submitWithApproval){
                		closure.Status__c = 'Closed';
                	}    
                	List<Approver__c> apps;
                	String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                	if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    	apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:taskId');            
                	}                            
                	if(apps != null && apps.size() > 0)
                	{
                    	if(Approver__c.sObjectType.getDescribe().isDeletable())
                    	{
                        	delete apps;
                    	}
                	}
            	}
                
            
            	closureList.add(closure);    
        	}
			if(!closureList.isEmpty()){    
        		upsert closureList;
        	}    
        	return 0;
        }catch(Exception ex){
            Database.rollback(sp);
            return -1;
        }    
    }
	////////////////////////////////////////////////////////////////////
    //CAPA Closure  end (saveClosureTask)
    ////////////////////////////////////////////////////////////////////     
    
    
    ////////////////////////////////////////////////////////////////////
    //others
    ////////////////////////////////////////////////////////////////////
    @RemoteAction
    public static Boolean updateCurretnRecord(string taskId,string RecordType,string status){
        String queryFieldSOfGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Approval_Required__c,isSubmitted__c,status__c,Non_Conformance__c');
        String queryFieldSOfAP = QC_DynamicObjectHandler.getAccessibleFields('General_Sub_Task__c', 'Id,Action_Plan_Status__c,Submit_WithOut_Approval__c,Assigned_User__c,Assigned_User__r.Name,Assigned_User__r.email');
        
        
        if(RecordType == 'Implementation'){
            if(queryFieldSOfGT != null && queryFieldSOfGT != '' && queryFieldSOfAP != null && queryFieldSOfAP != '')
            {    
                String htmlBody=null;
                System.debug('General_Task__c'+taskid);   
                List<General_Sub_Task__c> apTasks = database.query('Select '+ queryFieldSOfAP +' from General_Sub_Task__c where General_Task__c = :taskId');
                List<General_Task__c> gts = database.query('Select '+ queryFieldSOfGT +' from General_Task__c where id =: taskId');
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Boolean isTaskCompleted=true;    
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c,isSubmitted__c', 'update'))
                {
                    gts[0].Approval_Required__c='No';
                    gts[0].isSubmitted__c='True';
                    System.debug('gts[0].Approval_Required__c '+gts[0].Approval_Required__c+'isSubmitted__c...'+gts[0].isSubmitted__c); 
                    update gts;
                    System.debug('gts[0].Approval_Required__c '+gts[0].Approval_Required__c+'isSubmitted__c---'+gts[0].isSubmitted__c); 
                }
                System.debug(apTasks);
                for(General_Sub_Task__c aps: apTasks){ 
                    if(aps.Action_Plan_Status__c == 'Pending'){
                        System.debug(aps.Action_Plan_Status__c+'<---------is Pending---------->'+aps.Assigned_User__r.Name);
                        gts[0].Status__c = 'Pending ActionPlan';
                        aps.Submit_WithOut_Approval__c = 'Yes';
                        System.debug('aps1.Submit_WithOut_Approval__c----  '+aps.Submit_WithOut_Approval__c);
                        isTaskCompleted=isTaskCompleted?false:isTaskCompleted;
                        
                        upsert aps;
                    }
                    System.debug('Email_for_Action_Plan_Status_is_Open   mails  '+mails);
                }    
                if(isTaskCompleted){
                    gts[0].Status__c = 'Closed';
                }
                //=====================================nullify approvers
                List<Approver__c> apps;
                String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:taskId');            
                }                            
                if(apps != null && apps.size() > 0)
                {
                    if(Approver__c.sObjectType.getDescribe().isDeletable())
                    {
                        delete apps;
                    }
                }
                //======================================
                if(!gts.isEmpty()){
                    update gts;  
                }
                
                
                return true;
            }
            return false;
        }else{
            if(queryFieldSOfGT!= null && queryFieldSOfGT!= ''){
                
                list<General_Task__c> GT=database.query('Select '+ queryFieldSOfGT +' FROM General_Task__c where id=:taskId');
                system.debug('status of generaltask'+status);
                /* removed by ram 
                if(status=='Closed'){
                    GT[0].Approval_Required__c='NO';
                    GT[0].status__c='Closed';
                }
                else{
                    if(status=='OpenANDApprovalRequire'){
                        //GT[0].status__c='Open';
                    }    
                    else{
                        if(status=='OpenANDApprovalNotRequire'){
                            //GT[0].status__c='Open';
                            GT[0].Approval_Required__c='NO';
                        }  
                    }
                }     */  
                // added by ram start
                if(status=='Closed'){
                    GT[0].Approval_Required__c='NO';
                    GT[0].status__c='Closed';
                    GT[0].Note_To_Approver__c='';
                }else if(status=='Openfalse'){
                    GT[0].Approval_Required__c='NO';
                    GT[0].Note_To_Approver__c='';
                    GT[0].status__c='Open';
                }else if(status=='Opentrue'){
                	//----v2.0.2 START --------
                	if(RecordType == 'DocumentChange'){
                		GT[0].Approval_Required__c='NO';
	                    GT[0].Note_To_Approver__c='';
	                    GT[0].status__c='Pending Action Completion';
                	}//---v2.0.2 END-----------
                	else{
	                    GT[0].Approval_Required__c='NO';
	                    GT[0].Note_To_Approver__c='';
	                    GT[0].status__c='Closed';
                	}
                }else if(status=='Createdfalse'){
                    GT[0].Approval_Required__c='NO';
                    GT[0].Note_To_Approver__c='';
                    GT[0].status__c='Created';
                }else if(status=='Pending Action Completion'){ //----v2.0.4 START --------
                	GT[0].Approval_Required__c='NO';
                    GT[0].Note_To_Approver__c='';
                    GT[0].status__c='Open';
                }else{//----v2.0.4 END --------
                    if(status=='OpenANDApprovalRequire'){
                        //GT[0].status__c='Open';
                    }    
                    else{
                        if(status=='OpenANDApprovalNotRequire'){
                            //GT[0].status__c='Open';
                            GT[0].Approval_Required__c='NO';
                            GT[0].Note_To_Approver__c='';
                        }  
                    }
                }   
                // added by ram end
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','status__c', 'update')&&QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Approval_Required__c', 'update'))
                {
                    update GT;
                }
                
                List<Approver__c> apps;
                String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:taskId');            
                }                            
                if(apps != null && apps.size() > 0)
                {
                    if(Approver__c.sObjectType.getDescribe().isDeletable())
                    {
                        delete apps;
                    }
                }
                
                return true;
            }
            else{
                return false;  
            }
        }
    }
    
    public  static Date parseLongDate(String dateString){
        Map <String, Integer> months = new Map <String, Integer> {'jan'=>1, 'feb'=>2, 'mar'=>3, 'apr'=>4, 'may'=>5, 'jun'=>6, 'jul'=>7, 'aug'=>8, 'sep'=>9, 'oct'=>10, 'nov'=>11, 'dec'=>12};
        List <String> dateParts = dateString.toLowerCase().split(' ');
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = months.get(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        Date parsedDate = Date.newInstance(year,month,day);
        return parsedDate;
    }
    
    @RemoteAction
    public static List<String> getCAPATaskOwners(){
    	return Component_Handler.getAuthorizedUsers('CAPA_Task_Owner');
        
    }
    
     @RemoteAction
    public static List<String> getChangeMgmtTaskOwners(){
    	return Component_Handler.getAuthorizedUsers('CR_Task_Owner');
        
    }
    
    public List<Capa_history__c> getcapahistories(){
        system.debug('inside histories capa');
        string capahistoryfields,capaid;
        capaid=ApexPages.currentPage().getParameters().get('auditid');        
            if(capaid==null||capaid==''){
                return null;
            }
        string queryfieldNamesGroups=QC_DynamicObjectHandler.getAccessibleFields('Capa_history__c','isDeleted__c,CreatedBy.Name, isCreated__c,Parent__c, OwnerId, OldValue__c, Object__c, NewValue__c, Name, Id, FieldName__c, FieldApiName__c, Description__c, CreatedDate, CreatedById, CAPA__c');
        if(queryfieldNamesGroups!=null&&queryfieldNamesGroups!=''){
            return Database.query('SELECT ' +queryfieldNamesGroups+ ' FROM Capa_history__c WHERE capa__c =:capaid');    
        }
        return null;
    }
  ////////////////////////////////////////////////////////////////////////////////////////////
  //others
  ////////////////////////////////////////////////////////////////////////////////////////////
  
    ////////////////////////////////////////////////////////////////////
    //GenertalTask Dispatcher start
    /////////////////////////////////////////////////////////////////////

    public PageReference getRedir() {

        General_Task__c c;
        Id gtid=ApexPages.currentPage().getParameters().get('id');
        if(gtid==null){
            return null;
        }
        String queryFieldNamesNc = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,CAPA__c,Change_Management__C,non_conformance__c,Document_profile__c,recordtypeid,recordtype.Name'); 
        
         // v2.0.1  Qualityze Inc(SB) added Change_Management__C Api name in above string
         
        if(queryFieldNamesNc != null && queryFieldNamesNc != ''){
            c= database.query('Select '+ queryFieldNamesNc +' from General_Task__c where id=:gtid Limit 1');  
        }  

        PageReference newPage;
        if(c.CAPA__c!=null){
            newPage = Page.capa_task;
            newPage.getParameters().put('id', c.CAPA__c);
            
            newPage.getParameters().put('gtid', c.id);
            newPage.getParameters().put('type', c.recordtype.Name);
        }
        else if(c.non_conformance__c!=null){       // v2.0.1  Qualityze Inc(SB) changed(condition) here
        	newPage = Page.nc_task;            
            newPage.getParameters().put('id', c.non_conformance__c);
            
            newPage.getParameters().put('gtid', c.id);
            newPage.getParameters().put('type', c.recordtype.Name);
        }
        
       // v2.0.1  Qualityze Inc(SB) start
       
        else if(c.change_Management__C!=null){
        	newPage = Page.ChangeManagementTask;            
            newPage.getParameters().put('id', c.change_Management__C);
            /*newPage.getParameters().put('type', 'DocumentChange');
            if(c.recordtype.Name=='AdhocTask'){
            newPage.getParameters().put('pg', 'adhoc_task');
            }else{
            newPage.getParameters().put('pg', 'doc_change');
            }*/
            
            newPage.getParameters().put('gtid', c.id);
            newPage.getParameters().put('type', c.recordtype.Name);
            //type=DocumentChange&pg=doc_change
        }
        // v2.0.1  Qualityze Inc(SB) end
        
        
        
        
        if(c.Document_profile__c!=null){
            newPage = Page.DocumentProfileTask;
            newPage.getParameters().put('id', c.Document_profile__c);
            if(c.recordtype.Name=='CollaborationReview'){
                system.debug('getRedir getRedir CollaborationReview '+c.recordtype.Name);
                newPage.getParameters().put('gtid_cr', c.id);
            	newPage.getParameters().put('type', c.recordtype.Name);
            }else if(c.recordtype.Name=='EffectivenessReview'){
                system.debug('getRedir getRedir EffectivenessReview '+c.recordtype.Name);
                newPage.getParameters().put('gtid_er', c.id);
            	newPage.getParameters().put('type', c.recordtype.Name);
            }
            
        }
        return newPage.setRedirect(true);

    }
    
    private final ApexPages.StandardController controller;
    /////////////////////////////////////////////////////////////////////
    //GenertalTask Dispatcher End
    /////////////////////////////////////////////////////////////////////
    
      ///////////////////////////////////////////////////////////////////// 
    //ChangeManagement Closure-Start-v2.0.3
    /////////////////////////////////////////////////////////////////////
    
    @RemoteAction
    public static boolean cr_saveClosureTask(Id crId,String recordType,string closurecomment,Boolean approvalCheck,Boolean submitWithApproval){
    	//Id capaId,String recordType,String capaEffect,String createCapa,String closureComment,Boolean approvalCheck,Boolean submitWithApproval
    	system.debug(closurecomment+'--crId--'+crId+'--approvalCheck--'+approvalCheck+'--submitWithApproval--'+submitWithApproval);
    	Savepoint sp;
        try{
        	General_Task__c closure;
        	Id taskId;
        	List<General_Task__c> closureList = new List<General_Task__c>();
        	String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c','Id,Change_Management__c,Status__c,Approval_Required__c,Note_To_Approver__c,Closure_Comment__c,RecordType.Name,RecordTypeId');
        	if(queryFieldNames != null && queryFieldNames != ''){
            	closure = Database.query('SELECT '+queryFieldNames+' FROM General_Task__c WHERE Change_Management__c=:crId AND RecordType.Name =:recordType');
            	taskId = closure.Id;
            	  
            	closure.Closure_Comment__c = closureComment;
            	if(!approvalCheck){
                	closure.Approval_Required__c = 'No';
                	closure.Note_To_Approver__c = '';
                	if(submitWithApproval){
                		closure.Status__c = 'Closed';
                	}    
                	List<Approver__c> apps;
                	String queryFieldSOfAPR = QC_DynamicObjectHandler.getAccessibleFields('Approver__c', 'id,General_Task__c');         
                	if(queryFieldSOfAPR !=null&&queryFieldSOfAPR !=''){         
                    	apps=database.query('Select '+ queryFieldSOfAPR +' from Approver__c where General_Task__c=:taskId');            
                	}                            
                	if(apps != null && apps.size() > 0)
                	{
                    	if(Approver__c.sObjectType.getDescribe().isDeletable())
                    	{
                        	delete apps;
                    	}
                	}
            	}
                
            
            	closureList.add(closure);    
        	}
			if(!closureList.isEmpty()){    
        		upsert closureList;
        	}    
        	return true;
        }catch(Exception ex){
            Database.rollback(sp);
            return false;
        }    								
    }
      ///////////////////////////////////////////////////////////////////// 
    //ChangeManagement Closure-End-v2.0.3
    /////////////////////////////////////////////////////////////////////
}