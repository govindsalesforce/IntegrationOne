/*
v1.0                                            Qualityze Inc(GKS)                      13-JUL-2016                             Initial Version.

v1.1                                            Qualityze Inc(PRG)                      11-AUG-2016                             updeted getattachment



*/

public with sharing class DocumentTypeControllerExt {
    //v1.0-START
    public transient id doctypeid{get;set;}
    public transient id CurrentuserId;
    public transient List<Document_Profile__c> documentList{get;set;}
    public transient Document_Type__c DocType{get;set;}
    public transient String availableCategories{get;set;}
    public transient List<Document_Type__c> documentTypeClone;
    //public transient List<Document_type__c> documentTypeCreate;
    //v1.0-END
     public transient List<User> userList{get;set;}
    public transient List<Group> groupList{get;set;}
    
    public DocumentTypeControllerExt(){
        
    }
    public DocumentTypeControllerExt(ApexPages.StandardController controller)
        //V1.0-START
    {
        try{
            doctypeid=controller.getRecord().id;
            system.debug('this is doctypeid' + doctypeid);
            //START-availableCategories
            Schema.DescribeFieldResult fieldResult = Document_Type__c.Categories__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            availableCategories='';
            for( Schema.PicklistEntry f : ple){
                availableCategories += f.getValue()+',';
            } 
            system.debug('availableCategories is here' + availableCategories);
            //End-availableCategories
            
            if(doctypeid!= null) {
                system.debug('doctypeid is here' + doctypeid);
                String fieldsToReturn ='';
                
                String namespacePrepend = '';
                if ('' != QC_custom_settings.getPrefix()) {
                    namespacePrepend =(QC_custom_settings.getPrefix()==null)?'': QC_custom_settings.getPrefix()+'__'; 
                }
                
                Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrepend + 'Document_Type__c').getDescribe().fields.getMap();
                for( String fieldName : fieldMap.keySet() ) {
                    if(fieldsToReturn != '') {
                        fieldsToReturn += ', ';
                    }
                    fieldsToReturn += fieldName;
                    system.debug(' this is FieldsToReturn' + fieldsToReturn);
                    Schema.SObjectField fieldMetadata = fieldMap.get(fieldName);
                    String relationshipName = fieldMetadata.getDescribe().getRelationshipName();
                    system.debug('This is relationshipName' + relationshipName);
                    if (relationshipName != null && relationshipName.endsWith('__r')) {
                        fieldsToReturn += ', ' + relationshipName + '.id' + ', ' + relationshipName + '.name';
                        if (relationshipName.equals(namespacePrepend + 'Reported_By__r')) {
                            fieldsToReturn += ', ' + relationshipName + '.FirstName' + ', ' + relationshipName + '.LastName';
                        }
                    }
                }
                
                fieldsToReturn += ', Owner.Name,Owner.FirstName,Owner.LastName, CreatedBy.Name, CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.Name';
                
                // Build query string
                String selectAllFieldsForDOCTYPE= '';
                selectAllFieldsForDOCTYPE += 'select ' + fieldsToReturn + ' from Document_Type__c where id = \'' + doctypeid + '\' limit 1';
                system.debug('Query is: ' + selectAllFieldsForDOCTYPE);
                DocType = database.query(selectAllFieldsForDOCTYPE);
            } else {
                DocType = new Document_Type__c();
            }
            
            userrecords(); 
            groupsrecords();
            
            
        } catch(Exception ex){
            System.debug('Exception In  Document    '+ex.getMessage());
        }
        //V1.0-END
        //Doc list starts
        if(doctypeid != null)
        {
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,OwnerId,Owner.Name,Document_Name__c,Title__c,Status__c,Current_Rev__c,Release_Date__c,Expiration_Date__c,Document_Type__c,Effective_Date__c');
        if(queryFieldNames != null && queryFieldNames != '')
        {
            documentList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Document_Type__c =: doctypeid LIMIT 1000');
             }
        }
        else{
            documentList = new List<Document_Profile__c>();
        }
        
    } 
    //Doc list ENDS
    
    /*public List<Document_Profile__c> getdocumentList(){
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Name,OwnerId,Owner.Name,Document_Name__c,Status__c,Current_Rev__c,Release_Date__c,Expiration_Date__c,Document_Type__c');
      if(queryFieldNames != null && queryFieldNames != '')
    {
        
        
       List<Document_Profile__c> documentList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c ');
      //List<Document_Profile__c> documentList = [select Id,Name,OwnerId,Owner.Name,Document_Name__c,Status__c,Current_Rev__c,Release_Date__c,Expiration_Date__c,Document_Type__c from Document__c WHERE Document_Type__c = 'a0k360000035Kte'];    
      return documentList; 
     }
     else
        return null;
    }*/
    
    public List<Document_Type__c> getDocumentTypeList(){
        
          String queryDocQueryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,Name,OwnerId,Owner.Name,Business_Unit__c,Categories__c,Title__c,CreatedDate,CreatedBy.Name,Description__c,Initiating_Site__c,Initiating_Site__r.name,Reason__c,Status__c');
             if(queryDocQueryFieldNames != null && queryDocQueryFieldNames != '') {
                   
                    system.debug('inside qyery fields balu'+queryDocQueryFieldNames);
                    List<Document_Type__c> documentTypeList = database.query ('select ' + queryDocQueryFieldNames + ' from Document_Type__c ');
                    system.debug('inside qyery fields'+documentTypeList);
                    return documentTypeList;
                    
                 }
                 else
                   return null;
    
     }
     
     public List<Document_Type__c> getDocumentTypeClone(){
        
        system.debug('inside function');
            String IdodDoc =  ApexPages.currentPage().getParameters().get('id');
            if(String.isNotEmpty(IdodDoc)){
                system.debug('IdodDoc is here ' + IdodDoc);
                String queryDocQueryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,Name,OwnerId,Owner.Name,Business_Unit__c,Categories__c,Description__c,Reason__c,Status__c,Title__c,Document_Owner__c,Document_Status__c,Expire_After__c,Followers__c,Footer__c,Grace_Period_for_Release__c,Header__c,isEditable__c,Left_vertically__c,Number_Scheme__c,Protected_Draft__c,Retention_Duration__c,Right_vertically__c,Secondary_Format__c,Start_Effectiveness_Review_In_Advance__c,Supersede_Previous_Revision__c,Valid_Duration__c,Watermark_Text__c,Automatically_Expire_Previous_Revision__c');
                system.debug('queryDocQueryFieldNames is here'+queryDocQueryFieldNames);
                 if(queryDocQueryFieldNames != null && queryDocQueryFieldNames != '') {
                       documentTypeClone  = database.query ('select ' + queryDocQueryFieldNames + ' from Document_Type__c WHERE Id=:IdodDoc');
                        system.debug('documentTypecominfromClone is coming here'+documentTypeClone);
                        
                        
                 }
            }
            return documentTypeClone; 
     }
  
    
   /////////////// written by satish  start//////////////////
    
    public void userrecords(){
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('User', 'Id,Name');
        if(queryFieldNames != null && queryFieldNames != ''){
       
           CurrentuserId = UserInfo.getUserId();
            
        userList = [SELECT Id,name FROM User WHERE isActive =: true And id !=:CurrentuserId limit 10000 ];

            system.debug('users list'+userList);
        
       }
      }
    
    
    public void groupsrecords(){
        
        String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,Name');
        
         if(queryFieldNames != null && queryFieldNames != ''){
             
   
             groupList = [SELECT Id,name FROM Group WHERE Type = 'Regular' limit 10000];

             
            
           
        }
             
          
             
         
        
    
    }
    
    
    public integer getusercount(){
     
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'Id,Name');
          if(queryFieldNames != null && queryFieldNames != '')
          {
            return [SELECT count() FROM user WHERE isActive =: true And id !=:CurrentuserId limit 10000];
          }
          else
            {
              return 0;
            }
        
      
}
    
     public integer getgroupcount(){
     
          String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,Name');
          if(queryFieldNames != null && queryFieldNames != '')
          {
            return [SELECT count() FROM Group WHERE Type = 'Regular' limit 10000]; 
          }
          else
            {
              return 0;
            }
        
      
}
    
    
     @RemoteAction
    public static string AuthorisedEntityUsersSave(string doctypeID,string checknames,string checkgrpsNames,string checkviewusrsName,string checkviewgropusrsName,boolean isSubmitted,boolean security,string checkusrs,string checkgrps,string checkviewusrs,string checkviewgropusrs){
      

         Savepoint sp; 
        try{
            
            String queryFieldS = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'id,isEditable__c');
      
          if(isSubmitted == true || isSubmitted==false){
         Document_Type__c dtobj = new Document_Type__c();

        if(queryFieldS!= null && queryFieldS!= ''){
            
            dtobj=database.query('SELECT '+queryFieldS+' FROM Document_Type__c WHERE Id=:doctypeID');
            dtobj.isEditable__c=isSubmitted;
        
           update dtobj;
            
        }
        } 
            
            
            system.debug('security values------->'+security);
            Document_Type__c securityobj = new Document_Type__c();
              String queryFieldNamessecuirty = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,Enable_Security__c');
     if(queryFieldNamessecuirty != null && queryFieldNamessecuirty != '')
        {
       securityobj= database.query ('select ' + queryFieldNamessecuirty + ' from Document_Type__c where Id =: doctypeID  LIMIT 1');
       securityobj.Enable_Security__c = security;
        }
            
        update securityobj;
            
            
            
        system.debug('IID' + doctypeID);
        system.debug('UUsers' + checkusrs);
        Document_Type__c doctypeSecurity = new Document_Type__c();
        //Document_Type__c copyvar = new Document_Type__c();
       String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,name,Authorised_Entity_Users__c,Authorised_Entity_Users_Name__c,Authorised_Entity_Groups__c,Viewonly_Entity_Users__c,Viewonly_Entity_Groups__c');
        system.debug('ZZZZZZZ'+queryFieldNames);
        if(queryFieldNames != null && queryFieldNames != '')
        {
         doctypeSecurity = database.query ('select ' + queryFieldNames + ' from Document_Type__c where Id =: doctypeID  LIMIT 1');
        }
       
        


       
        system.debug('Current doc Type' + doctypeSecurity.name);
        checkusrs = checkusrs.removeStart('[');
        checkusrs = checkusrs.removeEnd(']');
        checknames = checknames.removeStart('[');
        checknames = checknames.removeEnd(']');    
        checkgrps = checkgrps.removeStart('[');
        checkgrps = checkgrps.removeEnd(']');
        checkgrpsNames = checkgrpsNames.removeStart('[');
        checkgrpsNames = checkgrpsNames.removeEnd(']');    
        checkviewusrs = checkviewusrs.removeStart('[');
        checkviewusrs = checkviewusrs.removeEnd(']');
        checkviewusrsName = checkviewusrsName.removeStart('[');
        checkviewusrsName = checkviewusrsName.removeEnd(']');    
        checkviewgropusrs = checkviewgropusrs.removeStart('[');
        checkviewgropusrs = checkviewgropusrs.removeEnd(']');
        checkviewgropusrsName = checkviewgropusrsName.removeStart('[');
        checkviewgropusrsName = checkviewgropusrsName.removeEnd(']');    
        
        doctypeSecurity.Authorised_Entity_Users__c = checkusrs;
        doctypeSecurity.Authorised_Entity_Groups__c = checkgrps;
        doctypeSecurity.Viewonly_Entity_Users__c = checkviewusrs;
        doctypeSecurity.Viewonly_Entity_Groups__c = checkviewgropusrs;
        doctypeSecurity.Authorised_Entity_Users_Name__c = checknames;
        doctypeSecurity.Authorised_Entity_Groups_Name__c = checkgrpsNames;
        doctypeSecurity.Viewonly_Entity_Users_Name__c = checkviewusrsName;
        doctypeSecurity.Viewonly_Entity_Groups_Name__c = checkviewgropusrsName;
            
            
           
        system.debug('Selected Users IDs' + doctypeSecurity);
            
        
       
        //update copyvar1;
       if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type__c','Authorised_Entity_Users__c,Authorised_Entity_Groups__c,Viewonly_Entity_Users__c,Viewonly_Entity_Groups__c','update') ){
                   update doctypeSecurity;
        }
        else{
                        System.debug('No Acesss to object  Document_Type__c');
                     }
        
        return doctypeSecurity.Id;            
        
    
        }
         catch(exception ex){
        
         Database.rollback(sp);
         System.debug('Exception In Component_Handler.deleteContainmentAction  '+ex.getMessage());        
        
       
       }
    return null;
        
    }
    
    
    
    
      /////////////// written by satish  end//////////////////
    
    
    
    
  //v1.0.1-START
   @RemoteAction
   public Static String SaveDocType(string jP,string cob,Boolean isAttachmentExist){
     system.debug(JSON.deserializeUntyped(jP));
      // system.debug('attachmentBody-->'+attachmentBody);
       //system.debug('attachmentName-->'+attachmentName);
    JSONparser parser = JSON.createparser(jP);
    system.debug(parser+'***');
    List<name_value> name_valuelist = new List<name_value>();
    map<string,string> m=new map<string,string>();
    List<string> st;
    String query;
    
        
                                                                    
    
    //sObject  nc=new capa__c();
    
    while (parser.nextToken() != null) 
    {
       if (parser.getCurrentToken() == JSONToken.START_ARRAY)
        {
          while(parser.nextToken() != null)
          {
             if(parser.getCurrentToken() == JSONToken.START_OBJECT)
             {
                name_value sto = (name_value)parser.readValueAs(name_value.class);
                name_valuelist.add(sto);
                 
                 string a=m.get(sto.name);
                 if(a=='' || a==null)
                 {
                     m.put(sto.name,sto.value); 
                 }
                 else
                 {
                   a= a+';'+sto.value;  
                   m.put(sto.name,a);
                 }
                /* if(m.containsKey(sto.name))
                 {
                   string a=m.get(sto.name);
                    a= a+';'+sto.value;
                     m.put(sto.name,a);
                     system.debug(a+'****@@@ ');
                 }
                 else{   
                        //m.put(sto.name,st.add(string.valueof(sto.value)));
                         m.put(sto.name,sto.value);
                        //nc.put(sto.name,sto.value);
                     }*/
                       
                
    
                 
                
                System.debug('*****Serialized storage: ' + name_valuelist);
            }
        }
         
        
        }
        System.debug(m+'%%%%%%%%%%%');
    }
    SObjectType nctype = Schema.getGlobalDescribe().get(m.get('sobj'));
    string capaobject=cob;
    // Convert to schema.sObjectType
    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(capaobject);
    // Create an instance of that type
    Sobject nc = convertType.newSObject();
    List<Schema.FieldSetMember> schemaset;
    string Fls_obj_name;
    if(nc.getsObjectType() == capa__c.sObjectType)
    {
        //system.debug('************************s'+nc.getsObjectType());
     // schemaset=SObjectType.capa__c.FieldSets.CAPA_save.getFields();
        Fls_obj_name='capa__c';
        //SObjectType.non_conformance__c.FieldSets.Non_Conformance_fields.getFields();
       System.debug(schemaset+'schemaset');
    }
    else if(nc.getsObjectType() == non_conformance__c.sObjectType)
    {   
        Fls_obj_name='non_conformance__c';
       // schemaset=SObjectType.non_conformance__c.FieldSets.Nc_Save.getFields();
    }
    else if(nc.getsObjectType() == Document_Type__c.sObjectType){
         Fls_obj_name='Document_Type__c';
         schemaset=SObjectType.Document_Type__c.FieldSets.DocType_Save.getFields();
         System.debug('schemaset----------------------->'+schemaset);
    }
    
   
    
   for ( Schema.FieldSetMember s : schemaset )
    {  
        
        system.debug('inside first for loop');
        for(string j:m.keySet())
        {   
            
            system.debug('Svalue:'+s+'|'+'jvalue'+j);
            

            if(string.valueof(s.getFieldPath())==j){
              
                if(query==null && j!='Id'){
                    query=j;
                }
                else if(j!='Id'){
                    query=query+','+j;
                    system.debug('query'+query+'jvalue'+j);
                }  
                    
                        system.debug('inside third for loop='+s.getType());
                        if(string.valueof(s.getType())=='DATE')
                        {
                            if(m.get(j)!='')
                            {
                                system.debug('****inside date****1');
                                system.debug('m.get(j)***'+m.get(j));
                                nc.put(j,date.valueof(m.get(j)));
                                system.debug('****inside date****');
                             }
                        }
                          else if(string.valueof(s.getType())=='Integer')
                            {
                                if(m.get(j)!='')
                                {
                                    system.debug('****inside Integer****1');
                                    system.debug('m.get(j)***'+m.get(j));
                                    nc.put(j,integer.valueof(m.get(j).trim()));
                                    system.debug('****inside Integer****');
                                 }
                            } 
                           else if(string.valueof(s.getType())=='Double')
                            {
                                if(m.get(j)!='')
                                {
                                    system.debug('****inside Double****');
                                    system.debug('m.get(j)***'+m.get(j));
                                    nc.put(j,Double.valueof(m.get(j)));
                                    system.debug('****inside Double****');
                                 }
                            } 
                           else  if(string.valueof(s.getType())=='Decimal')
                            {
                                if(m.get(j)!='')
                                {
                                    system.debug('****inside Decimal****1');
                                    system.debug('m.get(j)***'+m.get(j));
                                    nc.put(j,decimal.valueof(m.get(j)));
                                    system.debug('****inside Decimal****');
                                 }
                            } 
                           else if(string.valueof(s.getType())=='Boolean')
                            {
                                if(m.get(j)!='')
                                {
                                    system.debug('****inside Boolean****1');
                                    system.debug('m.get(j)***'+m.get(j));
                                    nc.put(j,Boolean.valueof(m.get(j)));
                                    system.debug('****inside Boolean****');
                                 }
                            } 
                            else if(string.valueof(s.getType())=='REFERENCE')
                            {
                                if(m.get(j)!='')
                                {
                                    system.debug('****inside REFERENCE****1');
                                    system.debug('m.get(j) reference***'+m.get(j));
                                    nc.put(j,Id.valueof(m.get(j)));
                                    system.debug('****inside REFERENCE****');
                                 }
                            } 
                          
              else
                  {  
                    system.debug('check for ID====='+j); 
                            if(j=='Id')
                            {
                                   if(m.get(j)!='')
                                   {
                                     nc.put(j,m.get(j));
                                     system.debug('inside id block');
                                   }
                            }
                           else
                           {
                                nc.put(j,m.get(j));
                               system.debug(nc.put(j,m.get(j))+'****inside string****** ');
                           }
                   
                }  
                
            }
        }
    }
    system.debug(nc+'Final nc object');
    string ncid;
     if(QC_DynamicObjectHandler.checkCreateUpdateAccess(Fls_obj_name,query,'create') && QC_DynamicObjectHandler.checkCreateUpdateAccess(Fls_obj_name,query,'update')){
     system.debug('inside FLs@@@--->'+nc);
     upsert nc;
     }
          if(!isAttachmentExist){
          uploadattachment(nc.id);
           return nc.id;
       }else{
           return nc.id;
       }
    
   
   }
   
    public static string uploadattachment(Id parentid){
        system.debug('DocumentTypeControllerExt uploadattachment parentid  '+parentid);
        try{
        Attachment attachment =  getAttachment(parentid);
            if(attachment!=null){
                 //Required to check FL--TODO
                delete attachment;
                
                attachment = new Attachment();
            }else{
            attachment = new Attachment();  
            }
       /* attachment.Body = attachmentBody;
        attachment.Name = attachmentName;
        attachment.Description=attachmentName+'@DocType';
        attachment.ParentId = parentid;
        
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Attachment','Body,Name,Description,ParentId','create')){ 
        insert attachment;
        }*/
        }catch(Exception ex){
            System.debug('Exception DocumentTypeControllerExt  uploadattachment   '+ex.getMessage());
        }
       return parentid;  
    }
    @RemoteAction
     Public static Attachment getAttachment(String docidId) {
        string doctypeQueryFields= QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id');
        string queryFieldNamesattachment=QC_DynamicObjectHandler.getAccessibleFields('Attachment', 'Id,Name,Description');
        List<Attachment> attachments;
        
       if((queryFieldNamesattachment != null && queryFieldNamesattachment != '') &&(doctypeQueryFields !=null && doctypeQueryFields!='')){
        string query ='SELECT '+queryFieldNamesattachment+' FROM Attachment  WHERE Parentid IN (Select '+doctypeQueryFields+' from Document_Type__c   WHERE id = :docidId ) AND Description LIKE \'%@DocType\'';
        attachments = Database.query(query);
       
      
       }
             /* List<Attachment> attachments = 
                [SELECT Id, Name ,Description FROM Attachment 
                 WHERE Parentid IN 
                   (Select Id from Document_Type__c 
                    WHERE id = :docidId  
                          ) AND Description LIKE '%@DocType'];*/
        system.debug('Get approratiate attachment');
         //system.debug(attachments);
        if(attachments.isEmpty()) {
            return null;
        } else {
            
            Attachment attachment=attachments[0];
            system.debug(attachment);
            return attachment;
        }
    }
    
    Public class name_value{
        string name;
        string value;
        
    }
   //v1.0.1-END
    
    
    
  //Follow DocType
@RemoteAction
public Static Integer followdocumentType(String docid, String userid){
    try{
    system.debug('followdoctype--' + docid+' ' +userid);
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Id,Followers__c');
    if(queryFieldNames != null && queryFieldNames != ''){
        List<Document_Type__c> doctype = Database.query('SELECT '+ queryFieldNames + ' FROM Document_Type__c WHERE Id=:docid');
        if(!doctype.isEmpty()){
            
             doctype[0].Followers__c=(doctype[0].Followers__c==null)?userid:(doctype[0].Followers__c+';'+userid);
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type__c','Followers__c','update')){
                    update doctype;
                    return 0;
                }else{
                      System.debug('Document__c followdoc  No update access to the fields  '+queryFieldNames);
                       }
        }
    }else{
                    System.debug('Document__c followdoc  No update access to the fields  '+queryFieldNames);
                }       
    
    }catch(Exception ex){
        System.debug(ex);
    }
    
    return -1;
    
}
    
    //UnFollow Doctype
    
       @RemoteAction
    public static Integer unfollowDocumentType(String docid,String userId){
        /*try{
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Type__c', 'Followers__c');
            String newFollowers='';
            String[] existingFollowers;
            if(queryFieldNames != null && queryFieldNames != ''){
                List<Document_Type__c> doctype = Database.query('SELECT '+queryFieldNames+' FROM Document_Type__c WHERE Id=:docid');
                if(!doctype.isEmpty()){
                  existingFollowers=doctype[0].Followers__c.split(';');
                  for(String existingFollower : existingFollowers){
                     if(userId.equalsIgnoreCase(existingFollower)){
                        continue;
                     }
                     newFollowers+=existingFollower;
                  }
                  doctype[0].Followers__c=newFollowers;
                  if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type__c','Followers__c','update')){
                   update doctype;
                   return 0;
                  }
                  else{
                    System.debug('Document__c followdoc  No update access to the fields  '+queryFieldNames);
                  }
                }
            }
            else{
              System.debug('Document__c followdoc  No access to the fields  '+queryFieldNames);
            }
        }
        catch(Exception ex){
            System.debug('Exception In followdoc   '+ex.getMessage());
        }*/
        return -1;
    }
    
     public DocumentTypeControllerExt(NonConformance controller){}
     
     
      @RemoteAction
     public static string cloneDocTypeRecord(string curPageId){
        
        
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
    
    
}