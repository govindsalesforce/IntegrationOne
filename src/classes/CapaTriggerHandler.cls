public with sharing class CapaTriggerHandler {
    public static Map<ID,Schema.RecordTypeInfo> rt_Map;
    public static void TriggerMethodBeforeUpdate(List<CAPA__c> newCapaList, Map<Id, CAPA__c> newCapaMap, List<CAPA__c> oldCapaList, Map<Id, CAPA__c> oldCapaMap) {
        try{
            Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = Component_Handler.getRiskPriorityGrid();
            For(Risk_Lookup__c riskLookup : [SELECT Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c FROM Risk_Lookup__c LIMIT 1000]) {
                Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
            }
            for (CAPA__c newCapa : newCapaList) {
                if(newCapa.CAPA_Status__c == 'Closed' && newCapa.CAPA_Status__c != oldCapaMap.get(newCapa.Id).CAPA_Status__c) {
                    newCapa.Closed_Date__c = Date.Today();
                }
                if (Severity_to_Occurrences_map.get(newCapa.Risk_Severity__c) != null) {
                    newCapa.Risk_Priority__c = Severity_to_Occurrences_map.get(newCapa.Risk_Severity__c).get(newCapa.Risk_Occurrence__c);
                }
                
                if(newCapa.Approval_Status__c=='Approved'&&oldCapaMap.get(newCapa.id).Approval_Status__c=='Pending Approval'){
                    newCapa.OwnerId=newCapa.New_Owner__c;
                    newCapa.New_Owner__c=null;
                }   
                else if(newCapa.Approval_Status__c=='Rejected'||newCapa.Approval_Status__c=='Recall'){
                    newCapa.New_Owner__c=null;
                }
            }
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.CAPA);
        }       
    }   
    public static void AfterTrigger(Map<id,CAPA__c> newMap,Map<id,CAPA__c> oldMap){
        try{
        system.debug('inside after trigger '+newMap);
        rt_Map = CAPA__c.sObjectType.getDescribe().getRecordTypeInfosById();    
        Map<id,CAPA__c> afterupdateMap=new Map<id,CAPA__c>();
                //========================================================update/insert
                system.debug('oldMap');
                if(oldMap==null){
                   system.debug('inside after trigger oldMap'+oldMap); 
                   oldMap=new Map<id,CAPA__c>(); 
                }  
                Map<id,CAPA__c> afterinsertMap=new Map<id,CAPA__c>();
                    for(CAPA__c gt:newMap.values()){
                        if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                        	afterinsertMap.put(gt.id,gt) ; 
                        }
                        else{
                            afterupdateMap.put(gt.id,gt) ; 
                        }
                    }
                    chisList=new List<CAPA_History__c>();
        			system.debug(' before afterinsertMap');
                    afterinsert(afterinsertMap);
        			system.debug('after afterinsertMap');
        			system.debug('after afterinsertMap chisList'+chisList);
                    FieldHistoryTracking(afterupdateMap,oldMap);   
        			system.debug('after FieldHistoryTracking');
        			system.debug('after FieldHistoryTracking chisList'+chisList);
                    insert chisList;
        			system.debug('after FieldHistoryTracking chisList'+chisList);
            }catch(Exception ex){
            System.debug('Exception In CapaTriggerHandler.afterTrigger     '+ex.getMessage());
        } 
    }
    
    public static Map<id,Risk_Priority__c> RiskPriority;
    public static Map<id,Risk_Severity__c> RiskSeverity;
	public static Map<integer,string> dateMap;
    public static Map<id,User> User;
    public static List<CAPA_History__c> chisList;
    
    public static void FieldHistoryTracking(Map<id,CAPA__c> newMap,Map<id,CAPA__c> oldMap){
        try{
        Map<String, Schema.SObjectField> Capa_Lable =Schema.SObjectType.CAPA__c.fields.getMap();
            system.debug('Capa_LableCapa_Lable'+Capa_Lable); 
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
        system.debug('inside field history tracking chisList'+chisList);
        if(chisList==null||chisList.isEmpty()){
        system.debug('inside field history tracking if chisList'+chisList);
        chisList = new List<CAPA_History__c>();    
        }        
        
        CAPA_History__c chis;
        string fieldApiname;
        id temp;
        string tempstore;            
        Set<string> fieldsetNames=new Set<string>(); 
        Set<string> CAPAfieldsetNames=new Set<string>(); 
   
            final List<Schema.FieldSetMember> trackedFields = SObjectType.CAPA__c.FieldSets.ResolutionFields.getFields();
            system.debug('trackedFields'+trackedFields);        
            for(Schema.FieldSetMember feildname:trackedFields){
                fieldsetNames.add(feildname.getFieldPath());
            }     
            final List<Schema.FieldSetMember> trackedCAPAFields = SObjectType.CAPA__c.FieldSets.CAPA_Fields.getFields(); 
        
        
        
            system.debug('trackedCAPAFields'+trackedCAPAFields);        
            for(Schema.FieldSetMember feildname:trackedCAPAFields){
                CAPAfieldsetNames.add(feildname.getFieldPath());
            }
            set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
        
        for(CAPA__c capa:newMap.values()){ 
            System.debug('Sarath ');
            final CAPA__c oldcapa = oldmap.get(capa.Id);    
            Boolean resolution;                
            for(Schema.SObjectField feildname:Schema.SObjectType.CAPA__c.fields.getMap().values()){
                resolution=true;
                fieldApiname=string.valueOf(feildname);
                if(CAPAfieldsetNames.contains(fieldApiname)){ 
                    if(capa.get(fieldApiname)!=oldcapa.get(fieldApiname)){
                        chis=new CAPA_History__c();
                        if(Capa_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                            chis.FieldName__c=Capa_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                        }
                        else{
                            chis.FieldName__c=Capa_Lable.get(fieldApiname).getDescribe().getLabel(); 
                        }
                        //chis.FieldName__c=Capa_Lable.get(fieldApiname).getDescribe().getLabel();
                        chis.FieldApiName__c=fieldApiname;
                        if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                            System.debug('Capa Sarath samsung5');
                            if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                if(oldcapa.get(fieldApiname)!=null){
                                    mydate=date.valueOf(oldcapa.get(fieldApiname));
                                    chis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                }                                            
                                if(capa.get(fieldApiname)!=null){
                                    mydate=date.valueOf(capa.get(fieldApiname));
                                    chis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                }
                                
                            }else{
                                chis.oldValue__c=string.valueOf(oldcapa.get(fieldApiname));
                                chis.NewValue__c=string.valueOf(capa.get(fieldApiname));
                                
                            }
                            chis.CAPA__c=capa.id;
                            chis.Parent__c='Init';
                            chis.object__c='CAPA__c';
                            chisList.add(chis);   
                            //resolution=false; 
                            System.debug('chisList'+chisList);
                        }                        
                        else
                        if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){
                            System.debug('Capa 2');
                                        chis=new CAPA_History__c();
                                        temp=string.valueOf(capa.get(fieldApiname));   
                                        chis.FieldName__c=CAPA_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
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
                                            tempstore=string.valueOf(oldcapa.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                chis.oldValue__c=User.get(string.valueOf(oldcapa.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(capa.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                chis.NewValue__c=User.get(string.valueOf(capa.get(fieldApiname))).Name;   
                                            chis.CAPA__c=capa.id;
                                            chis.Parent__c='Init';
                                            chis.object__c='CAPA__c';                                           
                                            chisList.add(chis); 
                                            system.debug('inside capa record');
                                        }
                        }
                    }
                }
                if(capa.get(fieldApiname)!=oldcapa.get(fieldApiname)){
                            system.debug('celkon'+fieldApiname+'fieldsetNames'+fieldsetNames);
                            if(fieldsetNames.contains(fieldApiname)){ 
                                system.debug('celkon1'+fieldApiname);
                                if(capa.get(fieldApiname)!=oldcapa.get(fieldApiname)){
                                    system.debug('inside capa.get(fieldApiname)!=oldcapa.get(fieldApiname) field history tracking'+fieldApiname);
                                    chis=new CAPA_History__c();
                                    chis.FieldName__c=CAPA_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();                                                                
                                    chis.FieldApiName__c=fieldApiname;                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldcapa.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldcapa.get(fieldApiname));
                                                chis.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(capa.get(fieldApiname)!=null){
                                                mydate=date.valueOf(capa.get(fieldApiname));
                                                chis.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            chis.oldValue__c=string.valueOf(oldcapa.get(fieldApiname));
                                            chis.NewValue__c=string.valueOf(capa.get(fieldApiname));
                                            
                                        }
                                        chis.CAPA__c=capa.id;
                                        chis.Parent__c='Resolution';
                                        chis.object__c='CAPA__c';
                                        chisList.add(chis);                        
                                    }
                                }
                            else
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){  
                                    system.debug('string. inside after reference');
                                    
                                    chis=new CAPA_History__c();
                                    chis.FieldName__c=CAPA_Lable.get(fieldApiname).getDescribe().getLabel();
                                    chis.FieldApiName__c=fieldApiname;                                        
                                    temp=string.valueOf(capa.get(fieldApiname));                                    
                                    if(null!=string.valueOf(capa.get(fieldApiname)))
                                    if(temp.getSObjectType().getDescribe().getName()=='Risk_Priority__c'){
                                        //                  
                                        if(RiskPriority!=null){
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
                                        
                                        
                                        
                                        tempstore=string.valueOf(oldcapa.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null)&&!RiskPriority.isEmpty()))
                                        chis.oldValue__c=RiskPriority.get(string.valueOf(oldcapa.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(capa.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskPriority.isEmpty())
                                        chis.NewValue__c=RiskPriority.get(string.valueOf(capa.get(fieldApiname))).Name;   
                                        chis.CAPA__c=capa.id;
                                        chis.Parent__c='Invesitgation';
                                        chis.object__c='CAPA__c';
                                        chisList.add(chis);  
                                    }
                                    if(temp.getSObjectType().getDescribe().getName()=='Risk_Severity__c'){
                                        //
                                        
                                        if(RiskSeverity!=null){
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
                                        tempstore=string.valueOf(oldcapa.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                        chis.oldValue__c=RiskSeverity.get(string.valueOf(oldcapa.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(capa.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                        chis.NewValue__c=RiskSeverity.get(string.valueOf(capa.get(fieldApiname))).Name;   
                                        chis.CAPA__c=capa.id;
                                        chis.Parent__c='Investigation';
                                        chis.object__c='CAPA__c'; 
                                        chisList.add(chis);  
                                    } 
                                }
                                }
                }
                                                 
            }
        }
    	}catch(Exception ex){
        System.debug('Exception In CapaTriggerHandler.FieldHistoryTracking     '+ex.getMessage());
    }
    }
    public static void afterinsert(Map<id,CAPA__c> capas){
        if(chisList==null||!chisList.isEmpty()){
        	chisList = new List<CAPA_History__c>();    
        }
        
        map<id,CAPA__c> insertOldMap=new map<id,CAPA__c>();
        CAPA_History__c chis;
        for(CAPA__c capa:capas.values()){
            insertOldMap.put(capa.id,new CAPA__c());
            chis=new CAPA_History__c(); 
            chis.CAPA__c=capa.id;
            chis.isCreated__c=true; 
            chis.FieldName__c='capa';
            chis.object__c='CAPA__c';
            chisList.add(chis);
        } 
        system.debug('inside after trigger in capa record'+chisList);
                
        FieldHistoryTracking(capas,insertOldMap);  
        for(CAPA_History__c capah:chisList){
            capah.isCreated__c=true;
        }
        
    }
}