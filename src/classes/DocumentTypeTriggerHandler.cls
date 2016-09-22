public class DocumentTypeTriggerHandler {
    
    public static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public static List<Document_Type_History__c> dthisList;
    public static Map<integer,string> dateMap;
    public static Map<id,User> User;
    
    
    
    public static void DocumentType_AfterTrigger(Map<id,Document_Type__c> newMap,Map<id,Document_Type__c> oldMap){
        try{
        system.debug('inside after trigger '+newMap);
        rt_Map = Document_Type__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        Map<id,Document_Type__c> afterupdateMap=new Map<id,Document_Type__c>();
                //========================================================update/insert
                system.debug('DocumentTypeTriggerHandler.oldMap');
                if(oldMap==null){
                   system.debug('inside after trigger oldMap'+oldMap); 
                   oldMap=new Map<id,Document_Type__c>(); 
                }  
                Map<id,Document_Type__c> afterinsertMap=new Map<id,Document_Type__c>();
                    for(Document_Type__c gt:newMap.values()){
                        if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                        	afterinsertMap.put(gt.id,gt) ; 
                        }
                        else{
                            afterupdateMap.put(gt.id,gt) ; 
                        }
                    }
                    dthisList=new List<Document_Type_History__c>();
        			system.debug(' before afterinsertMap');
                    afterinsert(afterinsertMap);
        			system.debug('after afterinsertMap');
        			system.debug('after afterinsertMap dthisList'+dthisList);
                    FieldHistoryTracking(afterupdateMap,oldMap);   
        			system.debug('after FieldHistoryTracking');
        			system.debug('after FieldHistoryTracking dthisList'+dthisList);
                    if(QC_DynamicObjectHandler.checkCreateUpdateAccess('Document_Type_History__c','oldValue__c,object__c,NewValue__c,Description__c,Parent__c,FieldName__c,Sub_Parent__c','create')){
                    insert dthisList;
                    }
        			system.debug('after FieldHistoryTracking dthisList'+dthisList);
            
                    
            }catch(Exception ex){
            System.debug('Exception In dtTriggerHandler.afterTrigger     '+ex.getMessage());
        } 
    }
    
    public static void FieldHistoryTracking(Map<id,Document_Type__c> newMap,Map<id,Document_Type__c> oldMap){
        try{
        Map<String, Schema.SObjectField> DT_Lable =Schema.SObjectType.Document_Type__c.fields.getMap();
            system.debug('DT_LableDT_Lable'+DT_Lable); 
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
        system.debug('inside field history tracking dthisList'+dthisList);
        if(dthisList==null||dthisList.isEmpty()){
        system.debug('inside field history tracking if dthisList'+dthisList);
        dthisList = new List<Document_Type_History__c>();    
        }        
        
        Document_Type_History__c dthis;
        string fieldApiname;
        id temp;
        string tempstore;            
        Set<string> fieldsetNames=new Set<string>(); 
        Set<string> DTfieldsetNames=new Set<string>(); 
   
            final List<Schema.FieldSetMember> trackedFields = SObjectType.Document_Type__c.FieldSets.Security_Fields.getFields();
            system.debug('trackedFields'+trackedFields);        
            for(Schema.FieldSetMember feildname:trackedFields){
                fieldsetNames.add(feildname.getFieldPath());
            }     
            final List<Schema.FieldSetMember> trackeddtFields = SObjectType.Document_Type__c.FieldSets.Document_Type_Fields.getFields(); 
        
        
        
            system.debug('trackeddtFields'+trackeddtFields);        
            for(Schema.FieldSetMember feildname:trackeddtFields){
                DTfieldsetNames.add(feildname.getFieldPath());
            }
            set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
        
           for(Document_Type__c dt:newMap.values()){ 
            System.debug('DocumentTypeTriggerHandler.DocumentTypeTriggerHandler. ');
            final Document_Type__c oldDT = oldmap.get(dt.Id);    
            Boolean resolution;                
            for(Schema.SObjectField feildname:Schema.SObjectType.Document_Type__c.fields.getMap().values()){
                resolution=true;
                fieldApiname=string.valueOf(feildname);
                if(DTfieldsetNames.contains(fieldApiname)){ 
                    if(dt.get(fieldApiname)!=oldDT.get(fieldApiname)){
                        dthis=new Document_Type_History__c();
                        if(DT_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                            dthis.FieldName__c=DT_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                        }
                        else{
                            dthis.FieldName__c=DT_Lable.get(fieldApiname).getDescribe().getLabel(); 
                        }
                        //dthis.FieldName__c=DT_Lable.get(fieldApiname).getDescribe().getLabel();
                        dthis.FieldApiName__c=fieldApiname;
                        if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                            System.debug('dt Sarath samsung5');
                            if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                if(oldDT.get(fieldApiname)!=null){
                                    mydate=date.valueOf(oldDT.get(fieldApiname));
                                    dthis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                }                                            
                                if(dt.get(fieldApiname)!=null){
                                    mydate=date.valueOf(dt.get(fieldApiname));
                                    dthis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                }
                                
                            }else{
                                dthis.oldValue__c=string.valueOf(oldDT.get(fieldApiname));
                                dthis.NewValue__c=string.valueOf(dt.get(fieldApiname));
                                
                            }
                            dthis.Sub_Parent__c='Details';
                            dthis.Parent__c=dt.id;
                            dthis.object__c='Document_Type__c';
                            dthisList.add(dthis);   
                            //resolution=false; 
                            System.debug('dthisList'+dthisList);
                        }                        
                        else
                        if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                            System.debug('DocumentTypeTriggerHandler. 2');
                                        dthis=new Document_Type_History__c();
                                        temp=string.valueOf(dt.get(fieldApiname));   
                                        dthis.FieldName__c=DT_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
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
                                            tempstore=string.valueOf(oldDT.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                dthis.oldValue__c=User.get(string.valueOf(oldDT.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(dt.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                dthis.NewValue__c=User.get(string.valueOf(dt.get(fieldApiname))).Name;   
                                            dthis.Sub_Parent__c='Details';
                            				dthis.Parent__c=dt.id;
                                            dthis.object__c='Document_Type__c';                                           
                                            dthisList.add(dthis); 
                                            system.debug('inside dt record');
                                        }
                        }
                    }
                }
                if((dt.CreatedDate==dt.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())!='Boolean')||(dt.CreatedDate!=dt.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())=='Boolean')||(dt.CreatedDate!=dt.LastModifiedDate&&String.valueOf(feildname.getDescribe().getType())!='Boolean')){
                if(dt.get(fieldApiname)!=oldDT.get(fieldApiname)){
                            system.debug('DocumentTypeTriggerHandler.'+fieldApiname+'fieldsetNames'+fieldsetNames);
                            if(fieldsetNames.contains(fieldApiname)){ 
                                system.debug('DocumentTypeTriggerHandler.1'+fieldApiname);
                                if(dt.get(fieldApiname)!=oldDT.get(fieldApiname)){
                                    system.debug('inside dt.get(fieldApiname)!=oldDT.get(fieldApiname) field history tracking'+fieldApiname);
                                    dthis=new Document_Type_History__c();
                                    dthis.FieldName__c=DT_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();                                                                
                                    dthis.FieldApiName__c=fieldApiname;                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldDT.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldDT.get(fieldApiname));
                                                dthis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(dt.get(fieldApiname)!=null){
                                                mydate=date.valueOf(dt.get(fieldApiname));
                                                dthis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            dthis.oldValue__c=string.valueOf(oldDT.get(fieldApiname));
                                            dthis.NewValue__c=string.valueOf(dt.get(fieldApiname));
                                            
                                        }
                                        dthis.Sub_Parent__c='Security';
                           				dthis.Parent__c=dt.id;
                                        dthis.object__c='Document_Type__c';
                                        dthisList.add(dthis);                        
                                    }
                                }
                            
                                }
                }
                }
                                                 
            }
        }
    	}catch(Exception ex){
        System.debug('Exception In dtTriggerHandler.FieldHistoryTracking     '+ex.getMessage());
    }
    }
    public static void afterinsert(Map<id,Document_Type__c> dts){
        if(dthisList==null||!dthisList.isEmpty()){
        	dthisList = new List<Document_Type_History__c>();    
        }
        
        map<id,Document_Type__c> insertOldMap=new map<id,Document_Type__c>();
        Document_Type_History__c dthis;
        for(Document_Type__c dt:dts.values()){
            insertOldMap.put(dt.id,new Document_Type__c());
            dthis=new Document_Type_History__c(); 
            dthis.Parent__c=dt.id;
            dthis.isCreated__c=true; 
            dthis.FieldName__c='Document Type';
            dthis.object__c='Document_Type__c';
            dthisList.add(dthis);
        } 
        system.debug('inside after trigger in dt record'+dthisList);
                
        FieldHistoryTracking(dts,insertOldMap);  
        for(Document_Type_History__c dth:dthisList){
            dth.isCreated__c=true;
        }
        
    }

}