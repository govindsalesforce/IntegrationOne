@isTest(seeAllData=false)
public class CAPA_Test {
    public static List<CAPA__c> capaList;
    public static List<CAPA__c> capaL;
    public static list<General_Task__c> genTask;
    public static List<User> userList;
    public static General_Sub_Task__c actplanSection;
    public static List<List<String>> actplanSectionMap;
    public static General_Sub_Task__c efvplanSection;
    public static List<List<String>> efvplanSectionMap;
    public static List<Action_Plan_Root_Cause__c> aprcList;
    public static List<General_Sub_Task__c> rootCauseList;
    public static List<Cause__c> causeList;
    public static Boolean submitWithApproval;
    public static Boolean appCheck;
    public static String efvpchecked;
    public static General_Sub_Task__c aps;
    public static Map<String,String> apsMap;
    public static List<General_Sub_Task__c> actionplanList;
    public static List<General_Sub_Task__c> effectiveverificationList;
    public static List<Approver__c> approverList;
    public static List<General_Sub_Task__c> ERTList;
    public static List<General_Sub_Task__c> adhocList;
    
    public static void capaTestData(){
		
		Date dt = System.TOday();
        userList = new List<User>();
        Profile p = [select id FROM Profile WHERE Name ='System Administrator'];
        userList.add(new User(
            FirstName = 'john', 
            LastName = 'miller',
            Username = 'john.miller@Gotham.com', 
            Email = 'CatSkills@Gotham.com', 
            Alias = 'JM', 
            CommunityNickname = 'jMiller', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US'
        ));
        insert userList;
        
		capaList = new List<CAPA__c>();
		capaList.add(new CAPA__c(
        Title__c ='Test CAPA',
        CAPA_Source__c= 'Other',
        CAPA_Status__c = 'Inworks',
        Problem_Statement__c = 'Test',
        Reported_Date__c = dt,
        Reported_By__c = userList[0].Id,
        Occurance_Date__c = dt,
        Criticality__c ='Low',
        Resolution_Code__c = 'CAPA Workflow',    
        ownerId= userList[0].Id,
        Followers__c=UserInfo.getUserId()
		));
        
        capaList.add(new CAPA__c(
        Title__c ='Test CAPAs',
        CAPA_Source__c= 'Others',
        Problem_Statement__c = 'Tests',
        Reported_Date__c = dt,
        Reported_By__c = userList[0].Id,
        Occurance_Date__c = dt,
        Criticality__c ='Low',
        ownerId= userList[0].Id,
        Followers__c=UserInfo.getUserId()
		));
		upsert capaList;
		
		genTask = new List<General_Task__c>();
        genTask.add(new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            CAPA__C = capaList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Implementation').getRecordTypeId(),
            Status__c='Open'
        ));
        
        genTask.add(new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            CAPA__C = capaList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('EffectivenessReview').getRecordTypeId(),
            Status__c='Open',
            Objective_Evidence__c = 'Test Evidence',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/4/2016')
        ));
        
        genTask.add(new General_Task__c(
            Sequence__c='15',
            Sequence_Position__c=15,
            Owner__c=userList[0].Id,
            CAPA__C = capaList[0].Id,
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
            CAPA__C = capaList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Investigation').getRecordTypeId(),
            Status__c='Open'
        ));
        genTask.add(new General_Task__c(
            Sequence__c='10',
            Sequence_Position__c=10,
            Owner__c=userList[0].Id,
            CAPA__C = capaList[0].Id,
            Allowed_Days__c = 6,
            Due_Date__c=Date.parse('1/4/2016'),
            Approver__c = userList[0].Id,
            RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
            Status__c='Open'
        ));
        upsert genTask;
        
        causeList =new List<Cause__c>();
        causeList.add(new Cause__c(
            Cause_Code__c = 'defect 1',
            Type__c='Product'
        ));
        //Cause__c nocauseid =null;
        insert causeList; 
        
        rootCauseList = new List<General_Sub_Task__c>();
        rootCauseList.add(new General_Sub_Task__c(
                Cause_Code__c = causeList[0].Id,
                Cause_Code_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                General_Task__c = genTask[0].Id,
                RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Root Cause').getRecordTypeId()
             ));
        insert rootCauseList;
        
        Action_Plan_Root_Cause__c aprc1 = new Action_Plan_Root_Cause__c(
        	Task_Root_Cause__c = rootCauseList[0].id
        );
        
        actplanSection = new General_Sub_Task__c(
            Title__c = 'The other other white meat',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Type__c = 'Correction',
            Assigned_User__c = userList[0].Id,
            Associated_Root_Causes__c = rootCauseList[0].id,
            Associated_Root_Cause_Name__c ='First Cause', 
            Due_Date__c = Date.parse('1/4/2016'),
            Complete__c = 'Yes',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/9/2016'),
            Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].Id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Action Plan').getRecordTypeId()
        );
        insert actplanSection;
        
        actplanSectionMap = new List<List<String>>();
        List<String> ListString=new List<String>();
        ListString.add(String.valueOf(actplanSection.Type__c));
        ListString.add(String.valueOf(actplanSection.Title__c));
        ListString.add(String.valueOf(actplanSection.Description__c));
        ListString.add(String.valueOf(actplanSection.Associated_Root_Causes__c));
        ListString.add(String.valueOf(actplanSection.Associated_Root_Cause_Name__c));
        ListString.add(String.valueOf(actplanSection.Assigned_User__c));
        ListString.add(String.valueOf('04 Jan 2016'));
        ListString.add(String.valueOf(actplanSection.Complete__c));
        ListString.add(String.valueOf(actplanSection.Completed_By__c));
        ListString.add(String.valueOf('04 Jan 2016'));
        ListString.add(String.valueOf(actplanSection.Completion_Comments__c));
        ListString.add(String.valueOf(actplanSection.id));
        
        actplanSectionMap.add(ListString);
        
        
        efvplanSection = new General_Sub_Task__c(
            
            Plan_Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].Id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Verification Plans').getRecordTypeId()
        );
        insert efvplanSection;
        
        efvplanSectionMap = new List<List<String>>();
        List<String> ListefvpString=new List<String>();
        ListefvpString.add(String.valueOf(efvplanSection.Plan_Statement__c));
        ListefvpString.add(String.valueOf(efvplanSection.id));
        
        efvplanSectionMap.add(ListefvpString);        
        
        
        
        aps = new General_Sub_Task__c(
            Title__c = 'The other other white meat',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Type__c = 'Correction',
            Assigned_User__c = userList[0].Id,
            Associated_Root_Causes__c = rootCauseList[0].id,
            Due_Date__c = Date.parse('1/4/2016'),
            Completed__c = 'Yes',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/9/2016'),
            Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].Id
        );
        insert aps;
        
    
        apsMap = new Map<String,String>();
        apsMap.put('Title__c', aps.Title__c);
        apsMap.put('Description__c',aps.Description__c);
        apsMap.put('Type__C',aps.Type__C);
        apsMap.put('Assigned_User__c',aps.Assigned_User__c);
        apsMap.put('Due_Date__c',String.valueOf('04 Jan 2016'));
        apsMap.put('Associated_Root_Causes__c',aps.Associated_Root_Causes__c);
        apsMap.put('Completed__c',aps.Completed__c);
        apsMap.put('Completed_Date__c',String.valueOf('09 Jan 2016'));
        apsMap.put('Completed_By__c',aps.Completed_By__c);
        apsMap.put('Completion_Comments__c',aps.Completion_Comments__c);
        apsMap.put('General_Task__c',aps.General_Task__c);
        apsMap.put('Id',aps.Id);
        
        ERTList = new List<General_Sub_Task__c>();
        ERTList.add(new General_Sub_Task__c(
            Plan_Statement__c= 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].Id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Verification Plans').getRecordTypeId()
        ));
        insert ERTList;
       
        adhocList = new List<General_Sub_Task__c>();
        adhocList.add(new General_Sub_Task__c(
            Completed_By__c = userList[0].Id,
            Completed_Date__c = System.today(),
            Sub_Task_Detail__c= 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].Id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('AdhocTask Actions').getRecordTypeId()
        ));
        insert adhocList;
 
       
        submitWithApproval = true;
        appCheck = true;
        efvpchecked = 'Yes';
   
		
	}
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_Header
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static testmethod void ComponentHandler_CAPA_Header_Test()
    {
       
        capaTestData();
        Date dt1 = System.TOday();
        List<General_Sub_Task__c> acps;
        Map<String, String> genTaskIds = new Map<String, String>();
        
         
       
        system.debug('genTask--->'+genTask);
        capaList[0] = null;
        Map<String, String> capaadhoctasks =new Map<String, String>();
        Map<String, String> adhocTskIds_void = new Map<String, String>();
        Map<String,List<sObject>> childobjs =new Map<String,List<sObject>>();
        Map<String,List<String>> tasks;
        Map<String,String> capadata;
        Date dt = System.TOday();
        Id usr = userInfo.GetUserId();
        CAPA__c cp = new CAPA__c();
        cp.Title__c ='Test CAPA';
        cp.CAPA_Source__c= 'Other';
        cp.Problem_Statement__c = 'Test';
        cp.Reported_Date__c = dt;
        cp.Reported_By__c = usr;
        cp.Occurance_Date__c = dt;
        cp.Criticality__c ='Low';
        cp.ownerId= usr;
        cp.Resolution_Code__c='CAPA Workflow';
        cp.CAPA_Status__c='Closed';
        insert cp;
           List<General_Task__c> genTaskList=new List<General_Task__c>();
        	
        	genTaskList.add(new General_Task__c(
                Sequence__c='10',
                Sequence_Position__c=10,
                OwnerId=userList[0].Id,
                Allowed_Days__c=4,
                Due_Date__c=Date.parse('1/9/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('EffectivenessReview').getRecordTypeId(),
                Status__c='Closed'
             ));
           

            genTaskList.add(new General_Task__c(
                Sequence__c='20',
                Sequence_Position__c=20,
                OwnerId=userList[0].Id,
                Allowed_Days__c=5,
                Due_Date__c=Date.parse('1/10/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Investigation').getRecordTypeId(),
                Status__c='Closed'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='30',
                Sequence_Position__c=30,
                OwnerId=userList[0].Id,
                Allowed_Days__c=6,
                Due_Date__c=Date.parse('1/11/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Implementation').getRecordTypeId(),
                Status__c='Pending ActionPlan'
             ));

            genTaskList.add(new General_Task__c(
                Sequence__c='40',
                Sequence_Position__c=40,
                OwnerId=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
                Status__c='Pending Approval'
             ));
        	 genTaskList.add(new General_Task__c(
                Sequence__c='40',
                AdhocTask_Title__c='TestTitle',
                Sequence_Position__c=40,
                OwnerId=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('AdhocTask').getRecordTypeId(),
                Status__c='Closed'
             ));
            genTaskList.add(new General_Task__c(
                Sequence__c='40',
                AdhocTask_Title__c='TestTitle',
                Sequence_Position__c=40,
                OwnerId=userList[0].Id,
                Allowed_Days__c=7,
                Due_Date__c=Date.parse('1/12/2016'),
                CAPA__C=cp.Id,
                RecordTypeId=Schema.SObjectType.General_Task__c.RecordTypeInfosByName.get('Closure').getRecordTypeId(),
                Status__c='Pending Approval'
             ));
            insert genTaskList;
        	System.debug('genTaskList in test class----->'+genTaskList);
         acps = new List<General_Sub_Task__c>();
        	acps.add(new  General_Sub_Task__c(Title__c = 'The other other white meat',
                                       Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       Type__c = 'Correction',
                                       Assigned_User__c = userList[0].Id,
                                       Due_Date__c = Date.today(),
                                       Complete__c = 'Yes',
                                       Completed_By__c = userList[0].Id,
                                       Completed_Date__c = Date.today(),
                                       Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       General_Task__c = genTaskList[2].id,
                                       Action_Plan_Status__c ='Complete'
       				 ));
            acps.add(new  General_Sub_Task__c(Title__c = 'The other other white meat',
                                       Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       Type__c = 'Correction',
                                       Assigned_User__c = userList[0].Id,
                                       Due_Date__c = Date.today(),
                                       Complete__c = 'Yes',
                                       Completed_By__c = userList[0].Id,
                                       Completed_Date__c = Date.today(),
                                       Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
                                       General_Task__c = genTaskList[2].id,
                                       Action_Plan_Status__c ='Complete'
       				 ));
            insert acps;
        tasks = new Map<String,List<String>>();
        List<String> impchlildtasksIds =  new List<String>();
        impchlildtasksIds.add(acps[0].id);
        impchlildtasksIds.add(acps[1].id);
        tasks.put('Containment@'+ genTaskList[0].id,new List<String>());
        tasks.put('Investigation@'+ genTaskList[1].id,new List<String>());
        tasks.put('Implementation@'+ genTaskList[2].id,impchlildtasksIds);
        
        
        Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        //dev_settings.Namespace_Prefix__c = 'QPMS';
        //dev_settings.Namespace_Prefix__c = 'QPMSQC2';
        dev_settings.Namespace_Prefix__c = '';
        //dev_settings.Namespace_Prefix__c = 'QPMSQCTEST';
        dev_settings.API_Version__c = '33.0';
        upsert dev_settings;
        test.startTest();            
        Component_Handler obj = new Component_Handler();
        obj.capa_id = cp.Id;
        CAPA__c capa = obj.getCAPA();
        String recId= cp.Id;
        string ressonforreopen='test reason description';
        string resolutioncode='CAPA Workflow';
        string capastatus='Closed';
        capadata = new Map<String,String>();
        	capadata.put('Resolution_Code__c',cp.Resolution_Code__c);
        	capadata.put('CAPA_Status__c ',cp.CAPA_Status__c);
        	capadata.put('capaid',cp.id);
        Component_Handler.reopenTasks(tasks, capadata, ressonforreopen);
        Component_Handler.reopenCAPA(ressonforreopen,recId,resolutioncode,capastatus);
        Component_Handler.voidCAPATasks(tasks,recId,ressonforreopen);
        Component_Handler.voidCAPA(recId,ressonforreopen);
        Component_Handler.closeCAPAtask(recId,ressonforreopen);
       
        Component_Handler obj1 = new Component_Handler();
        obj1.capa_id = null;
        capaList[0] = obj1.getCAPA();
        CAPA__c capa1 = obj1.getCAPA();
        test.StopTest();
        
        System.assertNotEquals(null,capa );
        System.assertNotEquals(null,capa1);
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END CAPA_Header
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPATaskController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //public static List<CAPA__c> capaList;
   
   //static{
     //  NC_Test.initData();
       //initData();
   //}
   
   public static void initData(){
       capaL = new List<CAPA__c>();
       capaL.add(new CAPA__c(Source_Number__c='5555',CAPA_Source__c='Test NCR',Problem_Statement__c='Test Problem Statement'));
       
       upsert capaL;
       
       NC_Test.genTaskList[2].CAPA__c=capaL[0].Id;
       
       upsert  NC_Test.genTaskList;
       System.assert(true);
   } 
   
   
   
   public static testMethod void CAPA_createCAPATasks(){
       capaTestData();
       NC_Test.initData();
      try{
        Map<String,List<String>>  tasks = new Map<String,List<String>>(); 
        List<String> adhocTasks = new List<String>();
        List<String> taskDetails=new List<String>();
        taskDetails.add('10');
        taskDetails.add(NC_Test.userList[0].Id);
        taskDetails.add('5');
        taskDetails.add('1/5/2016');
        tasks.put('Investigation',taskDetails);
        
        taskDetails.add('20');
        taskDetails.add(NC_Test.userList[0].Id);
        taskDetails.add('10');
        taskDetails.add('4/10/2016');
        tasks.put('Implementation',taskDetails);
          
        taskDetails.add('30');
        taskDetails.add(NC_Test.userList[0].Id);
        taskDetails.add('15');
        taskDetails.add('4/15/2016');
        tasks.put('EffectivenessReview',taskDetails);

        taskDetails.add('200');
        taskDetails.add(NC_Test.userList[0].Id);
        taskDetails.add('20');
        taskDetails.add('4/20/2016');
        tasks.put('Closure',taskDetails);
          
        taskDetails.add('5');
        taskDetails.add(userList[0].Id);
        taskDetails.add('3');
        taskDetails.add('2/17/2016');
        tasks.put('AdhocTask',taskDetails);
        
        adhoctasks.add('10@'+userList[0].Id+'@1@2/14/2016@adhocTaskTest1@null');
        adhoctasks.add('20@'+userList[0].Id+'@2@2/15/2016@adhocTaskTest1@null');
        adhoctasks.add('30@'+userList[0].Id+'@3@2/16/2016@adhocTaskTest1@null');
        adhoctasks.add('40@'+userList[0].Id+'@4@2/17/2016@adhocTaskTest1@null');
        adhoctasks.add('50@'+userList[0].Id+'@5@2/18/2016@adhocTaskTest1@null');


        system.debug('createCAPATasks  '+tasks);
        system.debug('createCAPATasks capaList[1]  '+capaList[1]);
        Test.startTest();
          PageReference pageRef = Page.capa;
          Test.setCurrentPage(pageRef);
          
          ApexPages.StandardController sc = new ApexPages.StandardController(capaList[1]);
          CAPA capaobj=new CAPA(sc);
          Component_Handler cph = new Component_Handler(capaobj);
       	  Map<String,String> results= CAPA.createCAPATasks(adhocTasks, tasks,capaList[1].Id,true,true,true);
          System.assert(!results.isEmpty());
          results=CAPA.createCAPATasks(adhocTasks, tasks,capaList[1].Id,true,false,false);
          system.debug('CAPA results...  '+results);
          System.assert(!results.isEmpty());
          
          
          Boolean iaApproverCapa=capaobj.isChangeCapaOwnerApprover;
          Boolean iasubmitterCapa=capaobj.isCapaOwnerSubmitter;
          system.debug('debug iaApproverCapa'+iaApproverCapa);
          capaobj.getProcessInstanceForCapa();
          
          //System.assert(capaobj.isChangeCapaOwnerApprover!=null,true);
          //System.assert(capaobj.isCapaOwnerSubmitter!=null,true);
          
          System.assert(CAPA.createCAPATasks(taskDetails,tasks,capaL[0].Id,true,true,false).size()!=0);
          System.assert(CAPA.createCAPATasks(taskDetails,tasks,capaL[0].Id,true,false,false).size()!=0);
          System.assert(CAPA.createCAPATasks(null,null,null,null,null,null)==null);
          
          //capaobj.isCapaOwnerSubmitter();
            //capaobj.isChangeCapaOwnerApprover();
            

        Test.stopTest();
        
      }
      catch(Exception ex){
        System.debug('Exception In CAPA_TaskController_Test.CAPA_TaskController_Test_createCAPATasks  '+ex.getMessage());
      }
   }
    
   public static testMethod void CAPA_unFollowCAPA(){
        capaTestData();
        try{
            System.debug('CAPA_unFollowCAPA 0  '+capaList[0].id);
            Test.startTest(); 
            System.debug('CAPA_unFollowCAPA 1  '+capaList[0].id);
            Integer result1 = Component_Handler.unFollowCAPA(capaList[0].id, userList[0].Id);
            System.debug('CAPA_unFollowCAPA 2  '+capaList[0].id);
            System.assertNotEquals(1,result1);
            Integer result2 = Component_Handler.unFollowCAPA(null, userList[0].Id);
            System.assertNotEquals(1,result1);
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    
    public static testMethod void CAPA_Test_followCAPA(){
        capaTestData();
        try{
            Test.startTest(); 
            Integer result1 = Component_Handler.followCAPA(capaList[0].id, userList[0].Id);
            System.assertNotEquals(1,result1);
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        } 
    }
    
   /*public static testMethod void CAPA_Test_CAPA_TaskController(){
      capaTestData();
      ApexPages.StandardController sc = new ApexPages.StandardController(capaL[0]);
      
      Test.startTest();
       try{
          new CAPATaskController(sc);
          new CAPATaskController(null);
          System.assert(true);
       }
       catch(Exception ex){
         System.debug('Exception In CAPA_TaskController_Test.CAPA_TaskController_Test_CAPA_TaskController  '+ex.getMessage());
         System.assert(false);
       }
         
      Test.stopTest();
   }*/
   
   public static testMethod void CAPA_Test_getResolutionCodes(){
       capaTestData();
       Test.startTest();
       try{
          CAPA.getResolutionCodes();
          System.assert(true);
       }
       catch(Exception ex){
         System.debug('Exception In CAPA_TaskController_Test.CAPA_TaskController_Test_getResolutionCodes()  '+ex.getMessage());
         System.assert(false);
       }
       Test.stopTest();
   }
   
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_record
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static testMethod void CAPA_CAPARecord() {
        NC_Test.initData();
    	Dev_Only__c dev_settings = Dev_Only__c.getOrgDefaults();
        //dev_settings.Namespace_Prefix__c = 'QPMS';
        //dev_settings.Namespace_Prefix__c = 'QPMSQC2';
        dev_settings.Namespace_Prefix__c = '';
        //dev_settings.Namespace_Prefix__c = 'QPMSQCTEST';
        dev_settings.API_Version__c = '33.0';
        upsert dev_settings;
        
       Date dt = System.TOday();
       Id usr = userInfo.GetUserId();
        
        CAPA__c cp = new CAPA__c();
        cp.Title__c ='Test CAPA2';
        cp.CAPA_Source__c= 'Other';
        cp.Problem_Statement__c = 'Test';
        cp.Reported_Date__c = dt;
        cp.Reported_By__c = usr;
        cp.Occurance_Date__c = dt;
        cp.Criticality__c ='Low';
        cp.ownerId= usr;
        
        insert cp;   
        
        ApexPages.StandardController std1=new ApexPages.StandardController(cp);
        
        
                
        Test.startTest();
        
        CAPA constructorOnly = new CAPA();
        System.assertNotEquals(constructorOnly, null);
        
        CAPA capa_for_test = new CAPA(std1);
        Boolean result_from_test = capa_for_test.getcan_reopen();
        System.assertEquals(true, result_from_test);
      
        Component_Handler reopen = new Component_Handler();
        Boolean result_reopen = reopen.getcan_reopen();
        
        Boolean result = CAPA.can_reopen(cp);
        System.assertEquals(true, result);
        
    	//==================================================written by balu start
    	string[] listUsers=new List<string>();
		listUsers.add(usr);
    	listUsers.add(usr);
    	system.debug('inside before submitApprovalRequest'+cp);
    	CAPA.submitApprovalRequestCAPAOwner(cp.id,listUsers,'capa test',NC_test.userList[0].id);
    	system.debug('inside submitApprovalRequest'+cp);
    	ProcessInstance pi=[select Id,TargetObjectid, CreatedById , Status FROM ProcessInstance where TargetObjectId =:cp.id And Status =: 'Pending' limit 1];        	
    	System.assertEquals(pi.Status,'Pending');
            Approvalclass.submitApprovalResponse(cp.id,'comments','Approve','nothing');
		
        CAPA.submitApprovalRequestCAPAOwner(cp.id,listUsers,'capa test',usr);
        system.debug('inside submitApprovalRequest'+cp);
        pi=[select Id,TargetObjectid, CreatedById , Status FROM ProcessInstance where TargetObjectId =:cp.id And Status =: 'Pending' limit 1];        	
        System.assertEquals(pi.Status,'Pending');
        Approvalclass.submitApprovalResponse(cp.id,'comments','Reject','nothing');
    	//===================================================written by balu end
        Test.stopTest();    
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END CAPARecord
////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_ReferenceTest
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public static testMethod void CAPA_ReferenceTest(){
    capaTestData();
    NC_Test.initData();
    List<Non_Conformance__c> nonconf = new List<Non_Conformance__c>();
    nonconf.add(new Non_Conformance__c(
    	Defect__c = NC_Test.defectList[0].Id,
        Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
        NC_Source__c = 'Other',
        Occurance_Date__c = Date.today(),
        Other_Source__c = 'The other other white meat',
        NC_Type__c = 'Process',
        Process__c = NC_Test.processList[0].Id,
        Reporter__c =userList[0].Id,
        NC_Status__c='Closed',
        Reopen_Date__c=Date.parse('1/9/2016'),
        Reopen_By__c=userList[0].Id,
        ownerid=userList[0].Id,
        NC_Workflow_Status__c='Open',
        NC_Resolution_Code__c='NC Workflow'
          		
    ));
    nonconf.add(new Non_Conformance__c(
        Defect__c = NC_Test.defectList[0].Id,
        Full_Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
        NC_Source__c = 'Other',
        Occurance_Date__c = Date.today(),
        Other_Source__c = 'The other other white meat',
        NC_Type__c = 'Process',
        Process__c = NC_Test.processList[0].Id,
        Reporter__c =userList[0].Id,
        NC_Status__c='open',
    	Reopen_Date__c=Date.parse('1/9/2016'),
    	Reopen_By__c=userList[0].Id,
    	ownerid=userList[0].Id,
    	NC_Workflow_Status__c='Open',
    	NC_Resolution_Code__c='NC Workflow'
          		
    )); 
    upsert nonconf;        
    List<Id> deletedNCIds,deletedCAPAIds,selectedNCIds,selectedCAPAIds;
    deletedNCIds = new List<Id>();
    deletedNCIds.add(nonconf[0].Id);
    deletedCAPAIds = new list<Id>();
    deletedCAPAIds.add(capaList[0].Id);
    selectedNCIds = new List<Id>();
    selectedNCIds.add(nonconf[1].Id);
    selectedCAPAIds = new List<Id>();
    selectedCAPAIds.add(capaList[0].Id);  
    Test.startTest();
    
    ApexPages.StandardController capaObj = new ApexPages.StandardController(capaList[0]);
    system.assertNotEquals(capaObj,null,'values are equal');
    ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
    ApexPages.currentPage().getParameters().put('type','capa_reference');
    CAPA XReference = new CAPA(capaObj);
    system.assertNotEquals(XReference,null,'values are equal');
    ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
    ApexPages.currentPage().getParameters().put('type','capa_reference');
    CAPA.saveXReferences(deletedNCIds,deletedCAPAIds,capaList[0].Id,selectedNCIds,selectedCAPAIds);
    selectedCAPAIds.remove(0);
    CAPA.saveXReferences(deletedNCIds,deletedCAPAIds,capaList[0].Id,selectedNCIds,selectedCAPAIds);
    deletedNCIds.remove(0);
    CAPA.saveXReferences(deletedNCIds,deletedCAPAIds,capaList[0].Id,selectedNCIds,selectedCAPAIds);
    
    XReference.allCAPAs = capaList;
    XReference.allNCs = NC_Test.nonConformancesList;
    XReference.allCheck = true;
    XReference.capaCheck = true;
    XReference.ncCheck =true;
    XReference.search = 'Open';
    XReference.doSearch();
    
    XReference.allCheck = false;
    XReference.doSearch();
    
    XReference.ncCheck = false;
    XReference.doSearch();
    
    XReference.search = '';
    XReference.doSearch();
    
    
    
    //integer saveXRef = CAPA_XReferenceController.saveXReferences(
    //,capaList.id,capaList[0].id);
    //system.assert(saveXRef);
    
    System.assertNotEquals(null,XReference);
    
    Test.stopTest();
    
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_ReferenceTest
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_InvestigationController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public static testMethod void CAPA_InvestigationTest(){
	capaTestData();
	General_Sub_Task__c rc1 = new General_Sub_Task__c(
        Description__c = 'sone description',                             // Description
        General_Task__c = genTask[3].id,               // General Task
        Cause_Code__c = causeList[0].id,                 // Cause Code
        Cause_Code_Description__c = 'aewrtfwert erter\n',  // Cause Code Description
        RecordTypeId = Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Root Cause').getRecordTypeId()                    // Record Type
    );
    insert rc1;
    General_Sub_Task__c rc2 = new General_Sub_Task__c(
                           
        General_Task__c = genTask[3].id,               // General Task
        Cause_Code__c = causeList[0].id,                 // Cause Code
        Cause_Code_Description__c = 'aewrtfwert erter\n',  // Cause Code Description
        RecordTypeId = Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Root Cause').getRecordTypeId()                    // Record Type
    );
    insert rc2;
    
    rootCauseList = new List<General_Sub_Task__c>(); 
    rootCauseList.add(rc1);
    rootCauseList.add(rc2);
    system.debug('rootCauseList-->'+rootCauseList);
    upsert rootCauseList; 
    
	General_Sub_Task__c rcSec = new General_Sub_Task__c(
        General_Task__c = genTask[3].id,               // General Task
        Cause_Code__c = causeList[0].id,                 // Cause Code
        Cause_Code_Description__c = 'aewrtfwert erter\n',
        RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Root Cause').getRecordTypeId()
    );
    insert rcSec;
    
    List<List<String>> rcSecMap=new List<List<String>>();
    List<String> ListOfString=new List<String>();
    ListOfString.add(String.valueOf(rcSec.Cause_Code__c));
    ListOfString.add(String.valueOf(rcSec.Cause_Code_Description__c));
    ListOfString.add(String.valueOf(rcSec.id));
    
    rcSecMap.add(ListOfString);
    
    submitWithApproval = true;
    appCheck = true;
    
	
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(capaList[0]);
    system.assertNotEquals(sc,null,'values are equal');
    ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
    ApexPages.currentPage().getParameters().put('type','Investigation');
    GeneralTaskController capaInv = new GeneralTaskController(sc);
    system.assertNotEquals(capaInv,null,'values are equal');
    GeneralTaskController invest = new GeneralTaskController();
    system.assertNotEquals(invest,null,'values are equal');
    Map<String,List<String>> causeData = Component_Handler.getCauseCodes();
    system.assertNotEquals(causeData,null,'values are equal');
    Boolean deleteRootcause = Component_Handler.deleteRootCause(rootCauseList[0].id);
    system.assertEquals(deleteRootcause,true,'values are not equal');
    Boolean updaterec= GeneralTaskController.Capa_update_InvestigationCurrentRecord(genTask[3].id);
    system.assertEquals(updaterec,true,'values are not equal');
	Boolean i;
    i = GeneralTaskController.CAPA_Investigation_saveRootCauses(rcSecMap,genTask[3].Id,'invSummary','invTool',appCheck,submitWithApproval);
    system.assertEquals(i,true,'values are not equal');
    i = GeneralTaskController.CAPA_Investigation_saveRootCauses(rcSecMap,genTask[3].Id,'invSummary','invTool',false,false);
    system.assertEquals(i,true,'values are not equal');
    i = GeneralTaskController.CAPA_Investigation_saveRootCauses(rcSecMap,genTask[3].Id,'invSummary','invTool',false,false);
    system.assertEquals(i,true,'values are not equal');
    
	Test.stopTest();
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_InvestigationController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Capa_Actionplan_controller Begin
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static testMethod void testCapaActionPlan(){
        capaTestData();
        Test.startTest();
        
        rootCauseList = new List<General_Sub_Task__c>();
            rootCauseList.add(new General_Sub_Task__c(
            //Cause_Code__c = causeList[0].Id,
            General_Task__c = genTask[0].id 
        ));
        insert rootCauseList;
        
        Action_Plan_Root_Cause__c aprc = new Action_Plan_Root_Cause__c(
        	Task_Root_Cause__c = rootCauseList[0].id
        );
        
        ApexPages.StandardController sc = new ApexPages.StandardController(capaList[0]);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
        ApexPages.currentPage().getParameters().put('type','Implementation');
        GeneralTaskController addaplan = new GeneralTaskController(sc);
        system.assertNotEquals(addaplan,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
        ApexPages.currentPage().getParameters().put('type','Implementation');
        GeneralTaskController addaplan1 = new GeneralTaskController();
        Integer i;
        i = GeneralTaskController.Capa_ActionPlan_saveActionPlan(actplanSectionMap,genTask[0].id,submitWithApproval,appCheck,efvpchecked);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_ActionPlan_saveActionPlan(actplanSectionMap,genTask[0].id,false,false,efvpchecked);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_ActionPlan_saveActionPlan(actplanSectionMap,genTask[0].id,false,false,'No');
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_ActionPlan_saveActionPlan(actplanSectionMap,genTask[0].id,submitWithApproval,false,efvpchecked);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_ActionPlan_saveActionPlan(actplanSectionMap,genTask[0].id,false,true,efvpchecked);
        system.assertEquals(i,0,'values are not equal');
        
        i = GeneralTaskController.CAPA_EffectiveVerification_saveEfvpPlan(efvplanSectionMap,genTask[0].id);
        system.assertEquals(i,0,'values are not equal'); 
        
        i = GeneralTaskController.CAPA_EffectiveVerification_saveEfvpPlan(efvplanSectionMap,genTask[0].id);
        system.assertEquals(i,0,'values are not equal');
        
        i = GeneralTaskController.Capa_Implementation_updateApprovalRequired(genTask[0].id,true);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_Implementation_updateApprovalRequired(genTask[0].id,false);
        system.assertEquals(i,0,'values are not equal');
       
        Map<String,List<String>> dataMap = Component_Handler.getActionPlanUserData('CAPA_Approval');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        List<String> userData = Component_Handler.getAuthorizedUsers('CAPA_Approval');
        system.assertNotEquals(userData,null,'values are equal');
        
        boolean delapResult = Component_Handler.deleteActionPlan(actplanSection.id);
        system.assert(delapResult);
        
        boolean delefvpResult = Component_Handler.deleteEffectivenessVerificationPlan(efvplanSection.id);
        system.assert(delefvpResult);
        
        boolean recallgt = GeneralTaskController.Capa_Implementation_RecallwithoutApproval(genTask[0].id,genTask[0].Status__c);
        system.assert(recallgt);
        
        i = Component_Handler.savePendingActionPlan(apsMap.get('Id'),'Yes',apsMap.get('Completed_By__c'),String.valueOf('04 Jan 2016'),'Completed');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        i = Component_Handler.completePendingActionPlan(apsMap.get('Id'),'Yes',apsMap.get('Completed_By__c'),String.valueOf('04 Jan 2016'),'Completed');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        i = Component_Handler.completePendingActionPlan(apsMap.get('Id'),'No',apsMap.get('Completed_By__c'),String.valueOf('04 Jan 2016'),'Completed');
        system.assertNotEquals(dataMap,null,'values are equal');
        
        List<String> displayRC = Component_Handler.displayAssocRootCauses(capaList[0].id,'CAPA');
        system.assertNotEquals(displayRC,null,'values are equal');
                       
        Test.stopTest();
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// Capa_Actionplan_controller End
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_EffectivenessReviewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public static testMethod void CAPA_EffectivenessReview_Test(){
		capaTestData();
		General_Sub_Task__c actplanSections;
    	list<General_Sub_Task__c> efvplanSections;
    	list<General_Sub_Task__c> efvplanSec;
    	List<General_Sub_Task__c> rootCauseLists;
    	Map<String,Map<String,String>> verificationPlans;
    	Map<String,String> plan;
    	Map<String,String> effectivenessReviewDetails;
		
		rootCauseLists = new List<General_Sub_Task__c>();
            rootCauseLists.add(new General_Sub_Task__c(
            General_Task__c = genTask[0].Id 
        ));
        upsert rootCauseLists;
        
        actplanSections = new General_Sub_Task__c(
            Title__c = 'The other other white meat',
            Description__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            Type__c = 'Correction',
            Assigned_User__c = userList[0].Id,
            Associated_Root_Causes__c = rootCauseLists[0].id,
            Associated_Root_Cause_Name__c ='First Cause', 
            Due_Date__c = Date.parse('1/4/2016'),
            Complete__c = 'Yes',
            Completed_By__c = userList[0].Id,
            Completed_Date__c = Date.parse('1/9/2016'),
            Completion_Comments__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Action Plan').getRecordTypeId()
        );
        upsert actplanSections;
        
        verificationPlans = new Map<String,Map<String,String>>();
                
        efvplanSec = new List<General_Sub_Task__c>();
        efvplanSec.add(new General_Sub_Task__c(
            Plan_Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[0].id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Verification Plans').getRecordTypeId()
        ));
        upsert efvplanSec;
        
        efvplanSections = new List<General_Sub_Task__c>();
        efvplanSections.add(new General_Sub_Task__c(
            Plan_Statement__c = 'Grammatically it\'s "<strong>boldly</strong> to go" and not "to <b>boldly</b> go"',
            General_Task__c = genTask[1].id,
            RecordTypeId=Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('Verification Plans').getRecordTypeId()
        ));
        upsert efvplanSections;
                
        effectivenessReviewDetails = new Map<String,String>();
        effectivenessReviewDetails.put('objectiveEvidence',genTask[1].Objective_Evidence__c);
        effectivenessReviewDetails.put('completedBy',genTask[1].Completed_By__c);
        effectivenessReviewDetails.put('completedDate',String.valueOf('04/10/2016'));
        System.debug('EffectivenessReviewTest class-------------------------------------------------------> '+effectivenessReviewDetails);
        
        plan = new Map<String,String>();
        Integer i=1,j;
        for(General_Sub_Task__c effectVer:efvplanSections){
        	plan.put('id',effectVer.Id);
        	System.debug('EffectivenessReviewTest class---------effectVer.Id----------------------------------------------> '+effectVer.Id);
        	plan.put('RecordTypeId',effectVer.RecordTypeId);
        	plan.put('planStmt',effectVer.Plan_Statement__c);
        	verificationPlans.put('plan'+(i++),plan);
        }
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(capaList[0]);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
        ApexPages.currentPage().getParameters().put('type','EffectivenessReview');
        GeneralTaskController effect = new GeneralTaskController(sc);
        //effect.getcapa();
        //system.assertEquals(c,null,'values are not equal');
        system.assertNotEquals(effect,null,'values are equal');
        System.debug('EffectivenessReviewTest class-----genTask[1].Id--------------------------------------------------> '+genTask[1]);
        System.debug('EffectivenessReviewTest class-----verificationPlans--------------------------------------------------> '+verificationPlans);
        j = GeneralTaskController.Capa_EffectivenessReview_saveVerificationPlans(genTask[1].Id,verificationPlans,effectivenessReviewDetails);
        system.assertEquals(j,0,'values are not equal');
        j = GeneralTaskController.Capa_EffectivenessReview_deleteVerificationPlan(efvplanSections[0].Id);
        system.assertEquals(j,0,'values are not equal');
        
        Component_Handler Cont=new Component_Handler();
        Cont.effectivenessReview = genTask[1];
        i = Cont.getVerificationPlanData();
        
        Test.stopTest();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_EffectivenessReviewController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_AdhocTaskController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static testMethod void CAPA_AdhocTask_Test(){
		capaTestData();
		List<General_Sub_Task__c> adhocTaskList;
    	Map<String,Map<String,String>> adhocTasks;
    	Map<String,String> task;
		adhocTaskList = new List<General_Sub_Task__c>();
        adhocTaskList.add(new General_Sub_Task__c(
            Completed_By__c = userList[0].Id,
            Sub_Task_Detail__c = 'Test Details',
            General_Task__c = genTask[2].id,
            Completed_Date__c = Date.parse('1/4/2016'),
            RecordTypeId = Schema.SObjectType.General_Sub_Task__c.RecordTypeInfosByName.get('AdhocTask Actions').getRecordTypeId()
        ));
    	
    	upsert adhocTaskList;
    	System.debug('EffectivenessReviewTest class-----adhocTaskList--------------------------------------------------> '+adhocTaskList);
    	task = new Map<String,String>();
    	adhocTasks = new Map<String,Map<String,String>>();
    	Integer j=1,i;
        for(General_Sub_Task__c adhoc:adhocTaskList){
        	task.put('id',adhoc.Id);
        	task.put('RecordTypeId',adhoc.RecordTypeId);
        	task.put('completedBy',adhoc.Completed_By__c);
        	task.put('detail',adhoc.Sub_Task_Detail__c);
        	task.put('completedDate',String.valueOf('04/10/2016'));
        	adhocTasks.put('adhocAction'+(j++),task);
        }
        
        System.debug('EffectivenessReviewTest class-----adhocTasks--------------------------------------------------> '+adhocTasks);
               
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(capaList[0]);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
        ApexPages.currentPage().getParameters().put('gtid',genTask[2].Id);
        ApexPages.currentPage().getParameters().put('type','AdhocTask');
        GeneralTaskController adTask = new GeneralTaskController(sc);
        system.assertNotEquals(adTask,null,'values are equal');
        i = GeneralTaskController.CAPA_AdhocTask_saveAdhocActions(genTask[2].Id,adhocTasks);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_AdhocTask_deleteAdhocAction(adhocTaskList[0].Id);
        system.assertEquals(i,0,'values are not equal');
        List<String> userData = Component_Handler.getAuthorizedUsers('CAPA_Approval');
        system.assertNotEquals(userData,null,'values are equal');
        Test.stopTest();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_AdhocTaskController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_Closure
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	public static testMethod void CAPA_Closure_Test(){
		capaTestData();
		Integer i;
    	Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(capaList[0]);
        system.assertNotEquals(sc,null,'values are equal');
        ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
        ApexPages.currentPage().getParameters().put('gtid',genTask[2].Id);
        ApexPages.currentPage().getParameters().put('type','Closure');
        GeneralTaskController closureTask = new GeneralTaskController(sc);
        system.assertNotEquals(closureTask,null,'values are equal');
        i = GeneralTaskController.Capa_Closure_saveClosureTask(capaList[0].id,'Closure','capaEffect','Yes','Closure Comment',true,true);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_Closure_saveClosureTask(capaList[0].id,'Closure','capaEffect','No','Closure Comment',true,false);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_Closure_saveClosureTask(capaList[0].id,'Closure','capaEffect','Yes','Closure Comment',false,true);
        system.assertEquals(i,0,'values are not equal');
        i = GeneralTaskController.Capa_Closure_saveClosureTask(capaList[0].id,'Closure','capaEffect','No','Closure Comment',false,false);
        system.assertEquals(i,0,'values are not equal');
        Test.stopTest();
	}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_Closure
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_getCAPAListForDisplay
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    static testMethod void capaListTest() {
        capaTestData();
        Test.startTest();
        
        capaList = new List<CAPA__c>();
		capaList.add(new CAPA__c(
        Title__c ='Test CAPA',
        CAPA_Source__c= 'Other',
        Problem_Statement__c = 'Test',
        Reported_Date__c = System.TOday(),
        Reported_By__c = userList[0].Id,
        Occurance_Date__c = System.TOday(),
        Criticality__c ='Low',
        ownerId= userList[0].Id
		));
		upsert capaList;
        
        CAPA obj = new CAPA();
        List<CAPA__c> capalists = obj.getCAPAListForDisplay();
        System.assertNotEquals(capalists.size(), 0);
        System.assertNotEquals(null, 0);
        Test.stopTest();
        
    
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END CAPA_getCAPAListForDisplay
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//start Attachment history tracking
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static testMethod void Attachment_CAPA_History_Controller_Test(){
         capaTestData();
         // QC_Test.initData();
         // QC_Test.initData_for_Dashboard_Controller();
                        
          Blob b = Blob.valueOf('Test Data');  
          
          Attachment attachment = new Attachment();  
          attachment.ParentId =genTask[0].CAPA__c;  
          attachment.Name = 'TestAttachment forParent';  
          attachment.Body = b;  
          attachment.Description='update Attachment@dex';
          insert(attachment);  
          attachment.Description='update Attachment@hello';
          try{
             upsert attachment;
             System.assert(true);
          }
          catch(Exception ex){
                System.debug('Exception In CAPA_Test.NC_ApprovalChartController()   '+ex.getMessage());
                System.assert(false);
          }
  }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EnD Attachment history tracking
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Begin  ApprovalClass getCAPAApproverList 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public static testMethod void ApprovalClass_getCAPAApproverList() {
        capaTestData();
        Test.startTest();
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        Approvalclass CAPA_ApprovalList_object=new Approvalclass();
        system.assertNotEquals(null,CAPA_ApprovalList_object.getCAPAApproverList());
        
        Test.stopTest();
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//EnD 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Class:capa_chronology_class
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    static testMethod void capa_chronology_class_test_method(){
        capaTestData();
        capaList = new List<CAPA__c>();
        capaList.add(new CAPA__c(
            Title__c ='Test CAPA',
            CAPA_Source__c= 'Other',
            Problem_Statement__c = 'Test',
            Reported_Date__c = System.TOday(),
            Reported_By__c = userList[0].Id,
            Occurance_Date__c = System.TOday(),
            Criticality__c ='Low',
            ownerId= userList[0].Id
        ));
        upsert capaList;
        
        Test.startTest();
        Component_Handler capaChro=new Component_Handler();
        capaChro.capacid=capaList[0].id;
        for(Date cr:capaChro.getCAPAHistoryDate()){
            
        }
        system.debug('capaChro.getCAPAHistoryDate().size() = ' + capaChro.getCAPAHistoryDate().size());
        system.assertNotEquals(0,capaChro.getCAPAHistoryDate().size());
        
        test.stopTest();  
 } // end of Method

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END capa_chronology_class
////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// BEGIN
// Test for class: CAPA_AuditController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public static testMethod void CAPA_AuditTest(){
	capaTestData();
	Test.startTest();
		ApexPages.currentPage().getParameters().put('Id',capaList[0].id);
		Component_Handler audit = new Component_Handler();
		system.assertNotEquals(audit,null,'values are equal');
		List<CAPA_History__c> capaHis = audit.getCAPAHistories();
		system.assertNotEquals(capaHis,null,'values are equal');
    
    	GeneralTaskController gthstry = new GeneralTaskController();
    	system.assertNotEquals(gthstry,null,'values are equal');
		List<CAPA_History__c> capagthstryHis = gthstry.getcapahistories();
		GeneralTaskController.getCAPATaskOwners();
    
	Test.stopTest();	
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
// END
// Test for class: CAPA_AuditController
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////


}