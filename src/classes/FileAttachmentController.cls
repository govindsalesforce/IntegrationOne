/*
v1.0						Qualityze Inc(GP)									Initial Version.
																				
v1.1						Qualityze Inc(SLVR)			11-JUL-2016		 		Added Change_Management__c to getshowaddAttachments

v1.2						Qualityze Inc(ST)			02-AUG-2016		 		Added Document_Profile__c to getshowaddAttachments
*/
global with sharing class FileAttachmentController
{
    public FileAttachmentController(ApexPages.StandardController controller) {
    }

    public transient Attachment tAttachment{get;set;}
    public transient string attachFileName{get;set;}
    public transient string attachFileDesc{get;set;}
    public transient Id sObjId{get;set;}
    public transient boolean showPageMsg{get;set;}
    public transient string errMsg{get;set;}
    public transient boolean showFileMeta{get;set;}
    public transient boolean showAddButton{get;set;}
    
    public FileAttachmentController(){
        //initialize attachment container
        tAttachment = new Attachment();
        //sObjId=ApexPages.currentPage().getParameters().get('id');
        //system.debug('sObjId--->'+sObjId);
        showFileMeta=false;
        showPageMsg=false;
        sObjId=ApexPages.currentPage().getParameters().get('id');
    }

    public string delAttachId{get;set;}
    public static string staticDelAttachId{get;set;}
    
    public void DeleteAttachment(){ 
        Savepoint sp = Database.setSavepoint();
                try{
                    if(delAttachId != null)
                    {
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            List<Attachment> AttList = database.query('Select '+ queryFieldNames + ' From Attachment where id=:delAttachId');
                            Attachment updateAttach = AttList[0];
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Attachment','Description','update')){
                                updateAttach.Name='Deleted@'+updateAttach.Name;
                                update updateAttach;
                            }
                        }
                        //Attachment delAttach = [Select Id From Attachment where id=:delAttachId];
                                  
                    }
                }
                catch(Exception e) {
                    Database.rollback(sp);
                    ERR_Handler.processError(e, ERR_Handler_API.Context.FILE);
                }                
    }
    
    public static void StaticDeleteAttachment(){ 
        Savepoint sp = Database.setSavepoint();
                try{
                    if(staticDelAttachId != null)
                    {
                        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id,Name');
                        if(queryFieldNames != null && queryFieldNames != '')
                        {
                            List<Attachment> AttList = database.query('Select '+ queryFieldNames + ' From Attachment where id=:staticDelAttachId');
                            //Attachment delAttach = [Select Id From Attachment where id=:staticDelAttachId];
                            Attachment updateAttach = AttList[0];
                            if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Attachment','Name','update')){
                                updateAttach.Name='Deleted@'+updateAttach.Name;
                                update updateAttach;
                            }
                        }
                    }
                }
                catch(Exception e) {
                    Database.rollback(sp);
                    ERR_Handler.processError(e, ERR_Handler_API.Context.FILE);
                }                
    }

    public integer getAttachmentCountForParent(){
        sObjId=ApexPages.currentPage().getParameters().get('id');
        System.debug('FileAttachmentController getAttachmentCountForParent sObjId  '+sObjId);
        if(sObjId!=null)
        {
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id,Name,ParentId');
          if(queryFieldNames != null && queryFieldNames != '')
          {
            return [SELECT count() FROM Attachment WHERE ParentId=: sObjId AND (NOT Name LIKE 'Deleted@%')];
          }
          else
            {
              return 0;
            }
        }
        else
        {
            return 0;
        }
    }
    
    @RemoteAction
    public static integer getAttachmentCountForParent(String parentId, String attachId){
        //sObjId=ApexPages.currentPage().getParameters().get('id');
        staticDelAttachId = attachId;
        StaticDeleteAttachment();
        if(parentId!=null)
        {
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id,Name,ParentId');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                return [SELECT count() FROM Attachment WHERE ParentId=: parentId AND (NOT Name LIKE 'Deleted@%')];
            }
            else
            {
                return 0;
            }
        }
        else
        {
            return 0;
        }
    }
    
    @RemoteAction
    public static integer updateAttachment(String attachId,String attachName,String attachDesc){
        Savepoint sp = Database.setSavepoint();
        try{
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'ParentId,OwnerId,Name,Id,Description,ContentType, CreatedDate');
            if(queryFieldNames != null && queryFieldNames != '')
            {
                List<Attachment> attList = database.query('Select '+ queryFieldNames + ' From Attachment where Id=:attachId AND Name=:attachName');
                if(attList.size()==1){
                	if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Attachment','Description','update')){
                		attList[0].Description=attachDesc;
                		update attList;
                		return 0;
                	}
                	else{
                		System.debug('FileAttachmentController updateAttachments no field access ');
                		return -1;
                	}
                }
                System.debug('FileAttachmentController updateAttachments  attList '+attList);
                return -1;
            }
            System.debug('FileAttachmentController updateAttachments no access for query fields');
            return -1;
                //Attachment delAttach = [Select Id From Attachment where id=:delAttachId];
        }
        catch(Exception ex) {
            Database.rollback(sp);
            System.debug('Exception In FileAttachmentController updateAttachments   '+ex.getMessage());
            return -1;
        }
    }
    
    public void DummyDoNothingFunction() {
        return;
    }
    
    public boolean getShowAttachmentForParent(){
        sObjId=ApexPages.currentPage().getParameters().get('id');
        if(sObjId!=null)
               return true;
        else
            return false;
    }
    
   public boolean getshowaddAttachments(){
       sObjId=ApexPages.currentPage().getParameters().get('id');
       if (sObjId == null) {
           showAddButton = false;
           return showAddButton;
       }
       string Status;
       string NSName = QC_custom_settings.getPrefix();
       string NSPrefix = '';
       if (!String.isBlank(NSName)) {
           NSPrefix = NSName + '__';
       }
       string typeOfId = sObjId.getSobjectType().getDescribe().getName();
       if (typeOfId == NSPrefix + 'Non_Conformance__c') {
           String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c','id,NC_Status__c');
           if(queryFieldNames != null && queryFieldNames != '')
           {
               List<Non_Conformance__c> ncList = database.query('Select '+ queryFieldNames + ' from Non_Conformance__c where id=:sObjId');
               Status = ncList[0].NC_Status__c;
           }
           system.debug('-->'+Status);
           if(Status != '' && Status != 'Closed' && Status != 'Void') {
               showAddButton = true;
           } else {
               showAddButton = false;
           }
       }else if (typeOfId == NSPrefix + 'CAPA__c') {
           String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c','id,CAPA_Status__c');
           if(queryFieldNames != null && queryFieldNames != '')
           {
               List<CAPA__c> capaList = database.query('Select '+ queryFieldNames + ' from CAPA__c where id=:sObjId');
               Status = capaList[0].CAPA_Status__c;
           }
           system.debug('Status-->'+Status);
           if(Status != '' && Status != 'Closed' && Status != 'Void') {
               showAddButton = true;
           } else {
               showAddButton = false;
           }
       // v1.1 start     
       }else if (typeOfId == NSPrefix + 'Change_Management__c') {
           String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Change_Management__c','id,Status__c');
           if(queryFieldNames != null && queryFieldNames != '')
           {
               List<Change_Management__c> changeMgmt = database.query('Select '+ queryFieldNames + ' from Change_Management__c where id=:sObjId');
               Status = changeMgmt[0].Status__c;
           }
           system.debug('Status-->'+Status);
           if(Status != '' && Status != 'Closed' && Status != 'Void') {
               showAddButton = true;
           } else {
               showAddButton = false;
           } 
       }
       // v1.1 end v1.2 start
       else if (typeOfId == NSPrefix + 'Document_Profile__c') {
           String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c','id,Status__c');
           if(queryFieldNames != null && queryFieldNames != '')
           {
               List<Document_Profile__c> docProfile = database.query('Select '+ queryFieldNames + ' from Document_Profile__c where id=:sObjId');
               Status = docProfile[0].Status__c;
           }
           system.debug('Status-->'+Status);
           if(Status != '' && Status != 'Closed' && Status != 'Void') {
               showAddButton = true;
           } else {
               showAddButton = false;
           } 
       }
       //v1.2 end
       return showAddButton;
   }
   
   public Map<String,List<Attachment>> getAttachmentsForParent(){
        sObjId=ApexPages.currentPage().getParameters().get('id');
        System.debug('   FileAttachmentController  getAttachmentsForParent  sObjId  '+sObjId);
        Map<String,List<Attachment>> attachmentsForParent=new Map<String,List<Attachment>>();
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'ParentId,OwnerId,Name,Id,Description,ContentType, CreatedDate');
        if(queryFieldNames != null && queryFieldNames != ''){
            List<Attachment> existingAttachments=Database.query('SELECT '+queryFieldNames+' From Attachment WHERE ParentId =: sObjId AND (NOT Name LIKE \'Deleted@%\') order by CreatedDate desc');
            String step;
            String[] descs;
            List<Attachment> attachments=null;
            for(Attachment a: existingAttachments){
                descs=a.Description.split('@');
                step=(descs.size()==1)?'--':descs[descs.size()-1];
                //step=description.isNumeric() ? description : 'N.A.';
                attachments=attachmentsForParent.get(step);
                if(attachments==null){
                    attachments=new List<Attachment>();
                    attachmentsForParent.put(step,attachments);
                }
                attachments.add(a);
           }
        }
        return attachmentsForParent;
   }
}