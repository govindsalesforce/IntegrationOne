/*

v1.0     Qualityze Inc(SLVR)    23-JUNE-2016                     Initial Version.
                                                                                 This Test class includes Changemanagement,Document and Sub Change Management objects
v1.1.0  Qualityze Inc(ST)       02-AUG-2016     Test method for Document Deactive
v1.1.1  Qualityze Inc(ST)       09-AUG-2016     Test methods for Void Document Profile
v1.0.2   Qualityze Inc(PRG)     22-Aug-2016     Test Methods Updated for DocumentType.
v1.1.3  Qualityze Inc(ST)       19-AUG-2016     Test methods for Chronology
v1.1.4  Qualityze Inc(ST)       19-AUG-2016     Test methods for Audit
v1.1.5  Qualityze Inc(PRG)		19-SEP-2016		Test Method for CR Void
*/

@isTest(seeAllData=false)
public with sharing class DOC_Test {
public static List<User> userList;
    public static List<Change_Management__c> changeManagementList;
    public static List<Document_Profile__c> dprof;
    public static List<Manufacturing_Site__c> mnfctngSiteList;
    public static List<Document_Profile__c> documentList;
    public static List<General_Task__c> genTask;
    public static List<Change_Management__c> Cml;
    public static List<DocumentJunction__c> dJun;
    
    public static List<Document_Type__c> documentTypeList;
    public Static String reasonfor_active;
    
    public static void init(){
        userList = new List<User>();
        changeManagementList = new List<Change_Management__c>();
        dprof = new List<Document_Profile__c>();
        dJun = new List<DocumentJunction__c>();
        mnfctngSiteList= new List<Manufacturing_Site__c>();
        documentList= new List<Document_Profile__c>();
        genTask = new List<General_Task__c>();
        Cml= new List<Change_Management__c>();
    }
    public static void initData(){
        init();
        userList = new List<User>();
        Profile p = [select id FROM Profile WHERE Name ='System Administrator'];
        Profile SU = [select id FROM Profile WHERE Name ='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        system.debug('datestring is here' + dateString);
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;        
        userList.add(new User(
            FirstName = 'Selena', 
            LastName = 'Kyle',
            Username = uniqueName + 'Selena.Kyle@Gotham.com', 
            Email = 'CatSkills@Gotham.com', 
            Alias = 'Catwoman', 
            CommunityNickname = 'CatWomans', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US'
            
        ));
        insert userList;
        
        List<Number_scheme__c> numberScheme = new List<Number_scheme__c>();
        Number_scheme__c NS = new Number_scheme__c (Name = 'Default Document Number', Number_format__c = '000001',Prefix__c = 'DOC',Revision__c='1',Suffix__c='YYYY',Module__c='Document');
        if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Number_scheme__c','Number_format__c,Prefix__c,Revision__c,Suffix__c,Module__c','create')){
            insert NS;    
        }
        
        mnfctngSiteList.add(new Manufacturing_Site__c(
            Name='east india company'
        ));
        insert mnfctngSiteList;
        system.debug('mnfctngSiteList contains'+ mnfctngSiteList);
        
        dprof.add(new Document_Profile__c(
            Name = 'D-00067',
            Document_Name__c='brd',
            New_Rev__c='revision12',
            Relation__c='master',
            Required_Change__c='not required what should i do',
            Status__c='Current',
            Type__c ='Revise'
        ));
        dprof.add(new Document_Profile__c(
            Name = 'D-00068',
            Document_Name__c='brd',
            New_Rev__c='revision12',
            Relation__c='Sub Document',
            Required_Change__c='not required what should i do',
            Status__c='Current',
            Type__c ='Revise'
        ));
        insert dprof;
        
        dJun.add(new DocumentJunction__c(DocumentParent__c = dprof[0].Id ,DocumentChild__c = dprof[1].Id ));
        insert dJun;
        
        changeManagementList.add(new Change_Management__c(
            Change_Request_Type__c='Product',
            Source__c='Document',
            Title__c='dummy',
            Due_Date__c=Date.parse('1/4/2016'),
            ownerid=userList[0].Id,
            Initiating_Site__c=mnfctngSiteList[0].Id,
            Change_Request_Scope__c='thisis the data for testing purposeto see if my test class works fine',
            Change_Justification__c='Big Daddyyyyyyyyyyyyyyyyyyyyyyyyyy',
            Impacted_Sites__c='NewYork',
            Status__c='Draft',
            Document_Number__c= dprof[0].Name,
            Change_Type__c = 'Revise',
            Resolution_Code__c='Document Change Order'
        ));
        changeManagementList.add(new Change_Management__c(
            Change_Request_Type__c='Product',
            Source__c='Document',
            Title__c='dummy',
            Due_Date__c=Date.parse('1/4/2016'),
            ownerid=userList[0].Id,
            Initiating_Site__c=mnfctngSiteList[0].Id,
            Change_Request_Scope__c='thisis the data for testing purposeto see if my test class works fine',
            Change_Justification__c='Big Daddyyyyyyyyyyyyyyyyyyyyyyyyyy',
            Impacted_Sites__c='NewYork',
            Status__c='Void',
            Document_Number__c= 'Test Document',
            Change_Type__c = 'New',
            Resolution_Code__c='Document Change Order'
        ));
        
        insert changeManagementList;
        system.debug('changeManagementList is here' +changeManagementList);
        System.assert(changeManagementList!=null);
        
        
        genTask.add(new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Change_Management__c = changeManagementList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('DocumentChange').getRecordTypeId(),
            Status__c='Open'
        ));
        genTask.add(new General_Task__c(
            Sequence__c='15',
            Sequence_Position__c=15,
            Owner__c=userList[0].Id,
            Change_Management__c = changeManagementList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId(),
            Status__c='Open'
        ));
        genTask.add(new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            Change_Management__c = changeManagementList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
            Status__c='Open'
        ));
        upsert genTask;
        
        documentList.add(new Document_Profile__c(
            Change_Management__c=changeManagementList[0].Id,
            //Name='D-00011',
            Document_Name__c='brd',
            //Document_Specific_Changes__c='very very very very very very',
            New_Rev__c='revision12',
            Relation__c='master',
            Required_Change__c='not required what should i do',
            Status__c='Inworks',
            Type__c ='Revise'
        )) ; 
        
        insert documentList;
        system.debug('documentList is here' +documentList);
        
        reasonfor_active='Tesast reason data string';
        documentTypeList = new List<Document_Type__c>();
        documentTypeList.add(new Document_Type__c(
           // Name__c = 'Name',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
           // Initiating_Site__c = 'Other',
            Reason__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Status__c = 'Active',
            Business_Unit__c = 'BU1'
            //Created_Date__c = Date.today()
           
        ));
        documentTypeList.add(new Document_Type__c(
          //  Name__c = 'Name',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            //Initiating_Site__c = 'Other',
            Reason__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Status__c = 'Inactive',
            Business_Unit__c = 'BU1'
            //Created_Date__c = Date.today()
           
        ));
        upsert documentTypeList;
        
        //Attachment Object
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=documentTypeList[0].id;
        insert attach;
        
        
    }
    
    public static testMethod void CManagementControllerTest()
    {
        initData();
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(changeManagementList[0]);
        ChangeManagementControllerExt chmngment=new ChangeManagementControllerExt(sc);
        
        Test.stopTest();
    }
    
    public static testMethod void docReferenceTest()
    {
        initData();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(dprof[0]);
        DocumentProfileControllerExt dprofile=new DocumentProfileControllerExt(sc);
        dprofile.doSearch();
        Test.stopTest();
    }
    
    public static testMethod void saveDocInfoTest(){
        initData();
        List<Document_Profile__c> docs = new List<Document_Profile__c>();
        docs.add(new Document_Profile__c(Document_Name__c = 'Test Doc1',Status__c = 'Current'));
        docs.add(new Document_Profile__c(Document_Name__c = 'Test Doc2',Status__c = 'Current'));
        docs.add(new Document_Profile__c(Document_Name__c = 'Test Doc3',Status__c = 'Current'));
        insert docs;
        
        List<Sub_Change_Management__c> subChangeMgmt = new List<Sub_Change_Management__c>();
        subChangeMgmt.add(new Sub_Change_Management__c(Document_Profile__c = docs[0].Id,Change_Management__c=changeManagementList[0].Id,Type__c='Revise'));
        subChangeMgmt.add(new Sub_Change_Management__c(Document_Profile__c = docs[1].Id,Change_Management__c=changeManagementList[0].Id,Type__c='New'));
        subChangeMgmt.add(new Sub_Change_Management__c(Document_Profile__c = docs[2].Id,Change_Management__c=changeManagementList[0].Id,Type__c='Temp'));
        insert subChangeMgmt; 
        
        List<String> deletedDocs = new List<String>();
        deletedDocs.add(subChangeMgmt[2].Id); 
        
        Map<String,String> subDoc = new Map<String,String>();
        subDoc.put('Id',subChangeMgmt[1].Id);
        subDoc.put('Type','New');
        subDoc.put('CurRev','1.0');
        subDoc.put('Status',docs[0].Status__c);
        subDoc.put('Relation','Master');
        subDoc.put('Doc','Test Document');
        subDoc.put('isPrimary','true');
        subDoc.put('SpecChanges','this is test specification1');
        
        Map<String,String> subDoc1 = new Map<String,String>();
        subDoc1.put('Id',subChangeMgmt[0].Id);
        subDoc1.put('Type','Revise');
        subDoc1.put('CurRev','1.0');
        subDoc1.put('Status',docs[1].Status__c);
        subDoc1.put('Relation','Master');
        subDoc1.put('Doc',docs[1].Id);
        subDoc.put('isPrimary','false');
        subDoc.put('SpecChanges','this is test specification2');
        
        Map<String,Map<String,String>> dList = new Map<String,Map<String,String>>();
        dList.put('docInfoTbody1',subDoc);
        dList.put('docInfoTbody2',subDoc1);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id',changeManagementList[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(changeManagementList[0]);
        ChangeManagementControllerExt chmngment=new ChangeManagementControllerExt(sc);
        system.assertNotEquals(chmngment,null,'values are equal');
        Integer i=ChangeManagementControllerExt.saveDocInfo(deletedDocs,dList,changeManagementList[0].Id);
        system.assertEquals(i,0,'values are not equal');
        List<String> types = chmngment.getTypes();
        system.assertNotEquals(types,null,'values are equal');
        List<Sub_Change_Management__c> docList = chmngment.getDocumentList();
        system.assertNotEquals(docList,null,'values are equal');
        //List<Document_Profile__c> searchDocs = chmngment.getSearchDocs();
        //system.assertNotEquals(searchDocs,null,'values are equal');
        Id cmid = chmngment.getcmid();
        system.assertNotEquals(cmid,null,'values are equal');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(changeManagementList[1]);
        ChangeManagementControllerExt cm =new ChangeManagementControllerExt(sc1);
        //searchDocs = cm.getSearchDocs();
        //system.assertNotEquals(searchDocs,null,'values are equal');
        Test.stopTest();
        
    }
    
    public static testMethod void saveDocSpecChanges(){
        // calling the Remote action method (always static) for saving the doc_specific_changes.
        initData();
        Test.startTest();
        string docId = documentList[0].id;
        string DocSpecificChanges = documentList[0].Document_Specific_Changes__c;
       // ChangeManagementControllerExt.savedocInfoDocSpecificChanges('docId','DocSpecificChanges');
        Test.stopTest();
    }
     public static testMethod void CManagement_Test_getResolutionCodes(){
      initData();
       Test.startTest();
       try{
          ChangeManagementControllerExt.getdocResolutionCodes();
          System.assert(true);
       }
       catch(Exception ex){
         System.debug('Exception In   '+ex.getMessage());
         System.assert(false);
       }
       Test.stopTest();
   }
    
    
    public static testMethod void CManagement_ResolutionTasks()
    {
        initData();
        
        try{
        Map<String,List<String>>  tasks = new Map<String,List<String>>(); 
        List<String> adhocTasks = new List<String>();
        List<String> taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/5/2016');
        tasks.put('DocumentChange',taskDetails);
        
     
          
        taskDetails.add('5');
        taskDetails.add(userList[0].Id);
        taskDetails.add('3');
        taskDetails.add('2/17/2016');
        tasks.put('AdhocTask',taskDetails);
            
            
        taskDetails.add('200');
        taskDetails.add(userList[0].Id);
        taskDetails.add('20');
        taskDetails.add('4/20/2016');
        tasks.put('Closure',taskDetails);
        
            
        adhoctasks.add('10@'+userList[0].Id+'@1@2/14/2016@adhocTaskTest1@null');
        adhoctasks.add('20@'+userList[0].Id+'@2@2/15/2016@adhocTaskTest1@null');
        adhoctasks.add('30@'+userList[0].Id+'@3@2/16/2016@adhocTaskTest1@null');
        adhoctasks.add('40@'+userList[0].Id+'@4@2/17/2016@adhocTaskTest1@null');
        adhoctasks.add('50@'+userList[0].Id+'@5@2/18/2016@adhocTaskTest1@null');


        system.debug('createDOCTasks  '+tasks);
        system.debug('createDOCTasks changeManagementList[0]  '+changeManagementList[0]);
        
        Test.startTest();
          PageReference pageRef = Page.ChangeManagement;
          Test.setCurrentPage(pageRef);
          
         ApexPages.StandardController sc = new ApexPages.StandardController(changeManagementList[0]);
         ChangeManagementControllerExt chmngment=new ChangeManagementControllerExt(sc);
            
          Component_Handler cph = new Component_Handler(chmngment);
          Map<String,String> results= ChangeManagementControllerExt.createDOCTasks(adhocTasks, tasks,changeManagementList[0].Id,true,true,true);
          System.assert(!results.isEmpty());
          results=ChangeManagementControllerExt.createDOCTasks(adhocTasks, tasks,changeManagementList[1].Id,true,false,false);
          system.debug('DOC results...  '+results);
          System.assert(!results.isEmpty());
          
          
          //Boolean iaApproverCapa=chmngment.isChangeCapaOwnerApprover;
          //Boolean iasubmitterCapa=chmngment.isCapaOwnerSubmitter;
          //system.debug('debug iaApproverCapa'+iaApproverCapa);
          //chmngment.getProcessInstanceForCapa();
        
          System.assert(ChangeManagementControllerExt.createDOCTasks(taskDetails,tasks,Cml[0].Id,true,true,false).size()!=0);
          System.assert(ChangeManagementControllerExt.createDOCTasks(taskDetails,tasks,Cml[0].Id,true,false,false).size()!=0);
          System.assert(ChangeManagementControllerExt.createDOCTasks(null,null,null,null,null,null)==null);
          
          
        
        Test.stopTest();
    }
        
     catch(Exception ex){
        System.debug('Exception In   '+ex.getMessage());
      }
    }
    
    //v1.0.1 start
    public static testMethod void docType_Deactive(){
     initData();
     try{
           Test.startTest();
            Component_Handler dth = new Component_Handler();
            Boolean result1 = Component_Handler.updateDocTypeActiveDeactiveStatus(documentTypeList[0].id,reasonfor_active,'Active');
            system.assert(result1, 'DocType status is Deactive');
            Boolean result2 = Component_Handler.updateDocTypeActiveDeactiveStatus(documentTypeList[1].id,reasonfor_active,'Inactive'); 
            system.assert(result2, 'DocType status is Active');
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }      
    }
    //v1.0.1 End
    //v1.0.2 start
    public static testMethod void DocumentProfileControllerExtTest()    {
        initData();
        try{
            Test.startTest();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(documentList[0]);
            DocumentProfileControllerExt docProfile=new DocumentProfileControllerExt(sc);
            
            //String result10 =DocumentProfileControllerExt.revise(documentList[0].id,'A');
            //system.assertNotEquals(result10,null,'values are not equal');
            //String result11 =DocumentProfileControllerExt.temp(documentList[0].id,'A');
            //system.assertNotEquals(result11,null,'values are not equal');
            
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }  
    }
    
    public static testMethod void voidDocProfileTest(){
     initData();
     try{
           Test.startTest();
            Component_Handler dth = new Component_Handler();
            Boolean result1 = Component_Handler.voidDocumentProfile(documentList[0].id,reasonfor_active);
            system.assert(result1, 'DocumentProfile status is void');
            //Boolean result2 = Component_Handler.voidDocumentProfile(documentList[1].id,reasonfor_active); 
            //system.assert(result2, 'DocumentProfile status is Active');
            Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }      
    }
     //v.1.1.5 Start
    Public static testmethod void voidChngMngmntTest(){
     initData();
     try{
         Test.startTest();
         boolean voidcr = Component_Handler.voidChngMngmnt(changeManagementList[0].id,'Reason for void');
         system.assertEquals(voidcr,true);
         Test.stopTest();
         
     }catch(Exception e){
         System.debug(e.getMessage());
     }   
    }
   //v1.1.5 End
    public static testMethod void reOpenChngMngmntTest(){
     initData();
     Map<String,String> chngmngmntdata;
     Map<String,List<String>> tasks;
     try{
           Test.startTest();
           tasks = new Map<String,List<String>>();
           tasks.put('DocumentChange@'+ genTask[0].id,new List<String>());
           tasks.put('AdhocTask@'+ genTask[1].id,new List<String>());
         
            chngmngmntdata = new Map<String,String>();
            chngmngmntdata.put('Resolution_Code__c',changeManagementList[0].Resolution_Code__c);
            chngmngmntdata.put('Status__c ',changeManagementList[0].Status__c);
            chngmngmntdata.put('chngMgmtid',changeManagementList[0].id);
            
            Component_Handler dth = new Component_Handler();
            Boolean result1 = Component_Handler.reopenChngMngmntTasks(tasks,chngmngmntdata,reasonfor_active);
            system.assert(result1, 'DocumentProfile status is void');
            
         Test.stopTest();
           
        }catch(Exception e){
            System.debug(e.getMessage());
        }      
    }
    //v1.0.2 End
   
   /////////////////////////////////////////////////////
   //DocumentTypeControllerExt-STRAT
   /////////////////////////////////////////////////////
    public static testMethod void DocumentTypeControllerExtTest()    {
        initData();
        try{
              Test.startTest();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(documentTypeList[0]);
            DocumentTypeControllerExt doctype=new DocumentTypeControllerExt(sc);
            Blob b = Blob.valueOf('Test Data');  
      
            Attachment attachment = new Attachment();  
            attachment.ParentId = documentTypeList[0].id;  
            attachment.Name = 'Test Attachment for Parent';  
            attachment.Body = b;
            attachment.Description='Test@DocType';
            insert(attachment); 
            String athres= DocumentTypeControllerExt.uploadattachment(documentTypeList[0].id);
            system.assertequals(athres, documentTypeList[0].id);
            
            docType.getusercount();
            docType.getgroupcount();
            Component_Handler dth = new Component_Handler();
            String result1 = Component_Handler.cloneRecord(documentTypeList[0].id);
            
           
            system.assertNotEquals(result1, null,'Document exist');
            String result11 = DocumentTypeControllerExt.cloneDocTypeRecord(documentTypeList[0].id);
            system.assertNotEquals(result11, null,'Document exist');
            
            Attachment result2= DocumentTypeControllerExt.getAttachment(documentTypeList[0].id);
             system.assertEquals(result2, null,'Document exist');
           
            
            Integer result3 =DocumentTypeControllerExt.followdocumentType(documentTypeList[0].id,userList[0].id);
            system.assertEquals(result3,0,'values are not equal');
            Integer result4 =DocumentTypeControllerExt.unfollowDocumentType(documentTypeList[1].id,userList[0].id);
            system.assertEquals(result4,-1,'values are not equal');
            String formdata='[{"name":"sobj","value":"Document_Type__c"},{"name":"page","value":"documentType"},{"name":"Id","value":"a0f610000021GWHAA2"},{"name":"isEditable__c","value":"false"},{"name":"Title__c","value":"test data"},{"name":"Description__c","value":"test data"},{"name":"Business_Unit__c","value":"BU2"},{"name":"OwnerId","value":"00561000000djutAAA"},{"name":"Status__c","value":"Inactive"},{"name":"Watermark_Text__c","value":"test"},{"name":"Valid_Duration__c","value":"7"},{"name":"Categories__c","value":"Category1"},{"name":"Categories__c","value":"Category2"},{"name":"Categories__c","value":"Category3"},{"name":"Retention_Duration__c","value":"5"},{"name":"Grace_Period_for_Release__c","value":"6"},{"name":"Start_Effectiveness_Review_In_Advance__c","value":"8"},{"name":"Number_Scheme__c","value":"a0s61000001GEBhAAO"},{"name":"Expire_After__c","value":"9"}]';
            String result5=DocumentTypeControllerExt.SaveDocType(formdata,'Document_Type__c',false);
            system.assertNotequals(result5, Null, 'Document Created');
            String attachres = DocumentTypeControllerExt.uploadattachment(documentTypeList[0].id);
            system.assertNotequals(attachres, Null, 'Attachment deleted');
            String dcid =documentTypeList[0].id;
            String result55 = DocumentTypeControllerExt.AuthorisedEntityUsersSave('doctypeID','checknames','checkgrpsNames','checkviewusrsName','checkviewgropusrsName',false,true,'checkusrs','checkgrps','checkviewusrs','checkviewgropusrs');
            system.assertNotequals(result55, Null, 'AuthorisedEntityUsersSave');
            //getDocumentTypeClone
            DocumentTypeControllerExt docList = new DocumentTypeControllerExt();
            List<Document_Type__c> docs = docList.getDocumentTypeList();
            
            List<Document_Type__c> docclonelists = docList.getDocumentTypeClone();
            System.assertEquals(docclonelists.size(), 0);
            
            
            
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }  
    }
   /* public static testmethod void uploadattachmentTest(){
        try{
            Test.startTest();
           
            Test.stopTest();
        
        }catch(Exception e){
          System.debug(e.getMessage());
          
        }
    }
        public static  testmethod void getAttachmentTest(){
        try{
            Test.startTest();
            Attachment result= DocumentTypeControllerExt.getAttachment(documentTypeList[0].id);
            Test.stopTest();
        
        }catch(Exception e){
          System.debug(e.getMessage());
          
        } 
        }*/
   /////////////////////////////////////////////////////
   //DocumentTypeControllerExt-END
  /////////////////////////////////////////////////////
  
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// v1.1.3 BEGIN
// Class:Document_chronology_class
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    static testMethod void documentChronologyTest(){
        initData();
                
        Test.startTest();
        Component_Handler dtChro=new Component_Handler();
        
        List<Sub_Change_Management__c> docList = dtChro.getDocuments();
        system.assertNotEquals(docList,null,'values are equal');
        
        List<Document_Profile__c> dpList = dtChro.getDocs();
        system.assertNotEquals(dpList,null,'values are equal');
        
        dtChro.dtcid=documentTypeList[0].id;
        dtchro.dpcid=documentList[0].id;
        dtchro.cmcid=changeManagementList[0].id;
        for(Date cr:dtChro.getDTHistoryDate()){
            
        }
        system.debug('dtChro.getDTHistoryDate().size() = ' + dtChro.getDTHistoryDate().size());
        system.assertNotEquals(0,dtChro.getDTHistoryDate().size());
        
        for(Date dp:dtChro.getDPHistoryDate()){
            
        }
        system.debug('dtChro.getDPHistoryDate().size() = ' + dtChro.getDPHistoryDate().size());
        system.assertNotEquals(0,dtChro.getDPHistoryDate().size());
        
        
        system.debug('capaChro.getCMHistoryDate().size() = ' + dtChro.getCMHistoryDate().size());
        system.assertNotEquals(0,dtChro.getCMHistoryDate().size());
        
        test.stopTest();  
 } // end of Method

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// v1.1.3 END Document_chronology_class
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// v1.1.4 BEGIN
// Test for class: Document_AuditController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static testMethod void Doc_AuditTest(){
        initData();
        Test.startTest();
        
        Component_Handler audit = new Component_Handler();
        system.assertNotEquals(audit,null,'values are equal');
        List<Change_Management_History__c> cmHis = audit.getCMHistories();
        system.assertNotEquals(cmHis,null,'values are equal');
        
        List<Document_Type_History__c> dtHis = audit.getDTHistories();
        system.assertNotEquals(dtHis,null,'values are equal');
        
        List<Document_Profile_History__c> dpHis = audit.getDPHistories();
        system.assertNotEquals(dpHis,null,'values are equal');
        Test.stopTest();    
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// v1.1.4 END
// Test for class: CAPA_AuditController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: Document_ListForDisplay
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static testMethod void DocumentListTest() {
        initData();
        Test.startTest();
        
        ChangeManagementControllerExt obj = new ChangeManagementControllerExt();
        List<Change_Management__c> cmlists = obj.getCMListForDisplay();
        System.assertNotEquals(cmlists.size(), 0);
        
        DocumentProfileControllerExt docObj = new DocumentProfileControllerExt();
        List<Document_Profile__c> doclists = docObj.getDPListForDisplay();
        System.assertNotEquals(doclists.size(), 0);
        System.assertNotEquals(null, 0);
        
        DocumentTypeControllerExt docTypeObj = new DocumentTypeControllerExt();
        List<Document_Type__c> docTypelists = docTypeObj.getDocumentTypeList();
        System.assertNotEquals(docTypelists.size(), 0);
        System.assertNotEquals(null, 0);
        
        Test.stopTest();
            
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END Document_ListForDisplay
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    }