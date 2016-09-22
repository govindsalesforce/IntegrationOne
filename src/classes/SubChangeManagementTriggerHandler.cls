public class SubChangeManagementTriggerHandler {
    
    public static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public static List<Change_Management_History__c> scmhisList;
    public static Map<integer,string> dateMap;
    public static Map<id,User> User;
    
    
    public static void SubChangeManagement_AfterTrigger(Map<id,Sub_Change_Management__c> newMap,Map<id,Sub_Change_Management__c> oldMap){
        try{
        system.debug('inside after trigger '+newMap);
        rt_Map = Sub_Change_Management__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        Map<id,Sub_Change_Management__c> afterupdateMap=new Map<id,Sub_Change_Management__c>();
                //========================================================update/insert
                system.debug('oldMap');
                if(oldMap==null){
                   system.debug('inside after trigger oldMap'+oldMap); 
                   oldMap=new Map<id,Sub_Change_Management__c>(); 
                }  
                Map<id,Sub_Change_Management__c> afterinsertMap=new Map<id,Sub_Change_Management__c>();
                    for(Sub_Change_Management__c gt:newMap.values()){
                        if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                        	afterinsertMap.put(gt.id,gt) ; 
                        }
                        else{
                            afterupdateMap.put(gt.id,gt) ; 
                        }
                    }
                    scmhisList=new List<Change_Management_History__c>();
        			system.debug(' before afterinsertMap');
                    afterinsert(afterinsertMap);
        			system.debug('after afterinsertMap');
        			system.debug('after afterinsertMap scmhisList'+scmhisList);
                    FieldHistoryTracking(afterupdateMap,oldMap);   
        			system.debug('after FieldHistoryTracking');
        			system.debug('after FieldHistoryTracking scmhisList inside subchangeManagement'+scmhisList);
            		system.debug('after FieldHistoryTracking scmhisList inside subchangeManagement'+scmhisList.size());
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Change_Management_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
                    insert scmhisList;
                    }
        			system.debug('after FieldHistoryTracking scmhisList size'+scmhisList.size());
            
                    
            }catch(Exception ex){
            System.debug('Exception In scmTriggerHandler.afterTrigger     '+ex.getMessage());
        } 
    }
    
    public static void FieldHistoryTracking(Map<id,Sub_Change_Management__c> newMap,Map<id,Sub_Change_Management__c> oldMap){
        try{
        Map<String, Schema.SObjectField> SCM_Lable =Schema.SObjectType.Sub_Change_Management__c.fields.getMap();
            system.debug('SCM_LableSCM_Lable'+SCM_Lable); 
        String qry;
        String queryFieldNames; 
        
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
        system.debug('inside field history tracking scmhisList'+scmhisList);
        if(scmhisList==null||scmhisList.isEmpty()){
        system.debug('inside field history tracking if scmhisList'+scmhisList);
        scmhisList = new List<Change_Management_History__c>();    
        }        
        
        Change_Management_History__c scmhis;
        string fieldApiname;
        id temp;
        string tempstore;            
        Set<string> fieldsetNames=new Set<string>(); 
        Set<string> CMfieldsetNames=new Set<string>(); 
   
            //final List<Schema.FieldSetMember> trackedFields = SObjectType.Sub_Change_Management__c.FieldSets.ResolutionFields.getFields();
           // system.debug('trackedFields'+trackedFields);        
            //for(Schema.FieldSetMember feildname:trackedFields){
            //    fieldsetNames.add(feildname.getFieldPath());
            //}     
            final List<Schema.FieldSetMember> trackedscmFields = SObjectType.Sub_Change_Management__c.FieldSets.Sub_Change_Management_Fields.getFields(); 
        
        
        
            system.debug('trackedscmFields'+trackedscmFields);        
            for(Schema.FieldSetMember feildname:trackedscmFields){
                CMfieldsetNames.add(feildname.getFieldPath());
            }
            //set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
        
        for(Sub_Change_Management__c scm:newMap.values()){ 
            final Sub_Change_Management__c oldCM = oldmap.get(scm.Id);    
            Boolean resolution;                
            for(Schema.SObjectField feildname:Schema.SObjectType.Sub_Change_Management__c.fields.getMap().values()){
                resolution=true;
                fieldApiname=string.valueOf(feildname);
                if(CMfieldsetNames.contains(fieldApiname)){ 
                    if(scm.get(fieldApiname)!=oldCM.get(fieldApiname)){
                        scmhis=new Change_Management_History__c();
                        if(SCM_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                            scmhis.FieldName__c=SCM_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                        }
                        else{
                            scmhis.FieldName__c=SCM_Lable.get(fieldApiname).getDescribe().getLabel(); 
                        }
                        //scmhis.FieldName__c=SCM_Lable.get(fieldApiname).getDescribe().getLabel();
                        scmhis.FieldApiName__c=fieldApiname;
                        if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                            System.debug('scm Sarath samsung5');
                            if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                if(oldCM.get(fieldApiname)!=null){
                                    mydate=date.valueOf(oldCM.get(fieldApiname));
                                    scmhis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                }                                            
                                if(scm.get(fieldApiname)!=null){
                                    mydate=date.valueOf(scm.get(fieldApiname));
                                    scmhis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                }
                                
                            }else{
                                scmhis.oldValue__c=string.valueOf(oldCM.get(fieldApiname));
                                scmhis.NewValue__c=string.valueOf(scm.get(fieldApiname));
                                
                            }
                            scmhis.Sub_Parent__c='DocumentInfo';
                            scmhis.Parent__c=scm.Change_Management__c;
                            scmhis.object__c='Sub_Change_Management__c';
                            scmhisList.add(scmhis);   
                            //resolution=false; 
                            System.debug('cmhisList'+scmhisList);
                        }                        
                        else
                        if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                            System.debug('scm 2');
                                        scmhis=new Change_Management_History__c();
                                        temp=string.valueOf(scm.get(fieldApiname));   
                                        scmhis.FieldName__c=SCM_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
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
                                                scmhis.oldValue__c=User.get(string.valueOf(oldCM.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(scm.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                scmhis.NewValue__c=User.get(string.valueOf(scm.get(fieldApiname))).Name;   
                                            scmhis.Sub_Parent__c='DocumentInfo';
                            				scmhis.Parent__c=scm.Change_Management__c;
                                            scmhis.object__c='Sub_Change_Management__c';                                           
                                            scmhisList.add(scmhis); 
                                            system.debug('inside scm record');
                                        }
                        }
                    }
                }
                
                                                 
            }
        }
    	}catch(Exception ex){
        System.debug('Exception In scmTriggerHandler.FieldHistoryTracking     '+ex.getMessage());
    }
    }
    
    public static void afterinsert(Map<id,Sub_Change_Management__c> scms){
        if(scmhisList==null||!scmhisList.isEmpty()){
        	scmhisList = new List<Change_Management_History__c>();    
        }
        
        map<id,Sub_Change_Management__c> insertOldMap=new map<id,Sub_Change_Management__c>();
        Change_Management_History__c scmhis;
        for(Sub_Change_Management__c scm:scms.values()){
            insertOldMap.put(scm.id,new Sub_Change_Management__c());
            scmhis=new Change_Management_History__c(); 
            scmhis.Parent__c=scm.Change_Management__c;
            scmhis.isCreated__c=true; 
            scmhis.FieldName__c='Sub Change Management';
            scmhis.object__c='Sub_Change_Management__c';
            scmhisList.add(scmhis);
        } 
        system.debug('inside after trigger in scm record'+scmhisList);
                
        FieldHistoryTracking(scms,insertOldMap);  
        for(Change_Management_History__c scmh:scmhisList){
            scmh.isCreated__c=true;
        }
        
    }

}