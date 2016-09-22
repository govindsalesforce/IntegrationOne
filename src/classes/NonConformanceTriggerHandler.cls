public with sharing class NonConformanceTriggerHandler {
    
    /*
    
    v1.0  Qualityze Inc(BK)        04-MAY-2016    Initial Version.
    This class includes triggers for Objects Non Conformance,NC Product,NC Defect,NC Product Defect AND Product Lot Numbers
    
    */
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //NonConformance trigger Handler start
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void NonConformance_BeforeTrigger(List<Non_Conformance__c> ncList, Map<Id,Non_Conformance__c> oldMap,boolean isInsert,boolean IsUpdate){
        // ************** Below code is to avoid NC Change owner if NC status is closed ********
           if(IsUpdate)
           {
               for(Non_Conformance__c nc: ncList)
               {
                 if((nc.NC_Status__c == 'Closed' || nc.NC_Status__c == 'Void') && nc.OwnerId != oldMap.get(nc.Id).ownerId) 
                 {
                     nc.addError('You cannot Change Owner of Closed / Void NC Record. Please check selected NC records.');
                 }
               }// end of For loop
           }// end of If for IsUpdate
        // ******************* End of Code of NC change owner **********************************
       try{
            // TODO: The method needs to be able to conditionally consider Risk Detection as a third input to the Risk Priority lookup.
            //Map<ID, Map<ID, Map<ID, ID>>> Risk_Lookup_map_WITH_detection = new Map<ID, Map<ID, Map<ID, ID>>>();
            
            Map<ID, Map<ID, ID>> Severity_to_Occurrences_map = Component_Handler.getRiskPriorityGrid();
           
               String queryFieldNamesNC = QC_DynamicObjectHandler.getAccessibleFields('Risk_Lookup__c', 'Id, Severity_Level__c, Occurrence_Probability__c, Risk_Priority__c');
               String ncqry;
               if(queryFieldNamesNC != null && queryFieldNamesNC != '')
               {
                   ncqry='SELECT ' + queryFieldNamesNC + ' FROM Risk_Lookup__c LIMIT 1000';
                              
                    For(Risk_Lookup__c riskLookup : database.query(ncqry)) {
                        Severity_to_Occurrences_map.get(riskLookup.Severity_Level__c).put(riskLookup.Occurrence_Probability__c, riskLookup.Risk_Priority__c);
                    }
               }

           
            For (Non_Conformance__c parent : ncList){
                if (Severity_to_Occurrences_map.get(parent.Risk_Severity__c) != null) {
                    parent.Risk_Priority__c = Severity_to_Occurrences_map.get(parent.Risk_Severity__c).get(parent.Risk_Occurrence__c);
                }
            }
        }
        catch(Exception e) {
            ERR_Handler.processError(e, ERR_Handler_API.Context.RISK);
        }       
    
  }
  
  
    public static void NonConformance_IsAfter_UpdateGeneralTaskOwner(Map<id,Non_Conformance__c> updateNcMap,Map<id,Non_Conformance__c> oldMap){
        set<id> ncids=new set<id>();
        for(Non_Conformance__c nc:updateNcMap.values()){
            if(nc.Ownerid!=oldMap.get(nc.id).Ownerid){
                ncids.add(nc.id);
            }
        }
        if(!ncids.isEmpty()){
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'id,Non_Conformance__c,Owner__c,');
            if(queryFieldNames!=null||queryFieldNames!=''){
                system.debug('inside updateGeneralTaskOwner before query');
                List<General_Task__c> gts=database.query('Select  '+ queryFieldNames +' From General_Task__c where Non_Conformance__c IN:ncids');
                system.debug('inside updateGeneralTaskOwner after query');
                for(General_Task__c gt:gts){
                    system.debug('inside updateGeneralTaskOwner before update inside for gts'+gt.Owner__c);
                    gt.ParentOwner__c=updateNcMap.get(gt.Non_Conformance__c).ownerid;
                    system.debug('inside updateGeneralTaskOwner before update gts inside for'+gt.Owner__c);
                }
                if(General_Task__c.sObjectType.getDescribe().isUpdateable()&&!gts.isEmpty())
                {
                    system.debug('inside updateGeneralTaskOwner before update gts');
                    update gts;
                    system.debug('inside updateGeneralTaskOwner after update gts');
                }
            }            
        }

    }
    
    
  public static void NonConformance_AfterTrigger(List<Non_Conformance__c>ncList,Map<Id,Non_Conformance__c> newMap,Map<Id,Non_Conformance__c> oldMap,boolean isInsert,boolean IsUpdate){
       List<NC_Product__c> prods = new List<NC_Product__c>();
       Map<Id, Boolean> pmap = new map<Id, Boolean>();
       for(Non_Conformance__c nc:newMap.values()){
         pmap.put(nc.id, false);
       }
       
       for(NC_Product__c ncp:[select id, non_conformance__c, primary_product__c from NC_Product__c where Non_Conformance__c IN :pmap.keyset() and primary_product__c = true]){
         pmap.put(ncp.non_conformance__c, true);
       }
       for(Non_Conformance__c nc:newMap.values()){
          if(nc.product__c != null && (isInsert || (oldMap.get(nc.id).product__c != nc.product__c && !pmap.get(nc.id)))){
          prods.add(
            new NC_Product__c(
               Manufacturing_Site__c = nc.Initiating_Site__c,
               Non_Conformance__c = nc.id,
               Product__c = nc.product__c
            )
          );
         }
       }
       if(prods.size() > 0)
         insert prods;
       
       List<Product_Lot_Numbers__c> plns = new List<Product_Lot_Numbers__c>();
       Map<Id, Non_Conformance__c> ncmap = new Map<Id, Non_Conformance__c>();
       
       for(NC_Product__c p:prods){
         Non_Conformance__c nc = newMap.get(p.Non_Conformance__c);
         plns.add(new Product_Lot_Numbers__c(
           NC_Product__c = p.id,
           Defect_Codes__c = NC.Defect__c
         ));
         ncmap.put(p.id, nc);  
       }
       
     if(plns.size() > 0)
         insert plns;
         
      // ---- Below code is to update NC child records if NC updated as Void ----
      set<Id> ncrecIdSet = new Set<Id>();
      if(IsUpdate)
      {
          for(Non_Conformance__c nc: ncList)
          {
              if(nc.NC_Status__c == 'Void')
              {
                  ncrecIdSet.add(nc.Id);
              }
          }
          
                    
          if(ncrecIdSet != null && ncrecIdSet.size() > 0)
          {
              List<General_Task__c> gTasks = new List<General_Task__c>();
              String queryFieldNamesGT = QC_DynamicObjectHandler.getAccessibleFields('General_Task__c', 'Id,Status__c,Non_Conformance__c');
                    
                    if(queryFieldNamesGT != null && queryFieldNamesGT != '')
                    {
                        String gtqry='SELECT ' + queryFieldNamesGT + ' FROM General_Task__c WHERE Non_Conformance__c =: ncrecIdSet';
                    
                        gTasks= database.query (gtqry);
                        System.debug('-->gTasks:'+gTasks);
                    } 
              
              if(gTasks != null && gTasks.size() > 0)
              {
                //List<General_Task__c> updateGTList = new List<General_Task__c>();
                for(General_Task__c gt : gTasks){
                    gt.Status__c = 'Void';
                    //updateGTList.add(gt);
                }
                    
                if(QC_DynamicObjectHandler.checkCreateUpdateAccess('General_Task__c','Status__c', 'update'))
                {
                   // update updateGTList;
                    update gTasks;
                }
              }
          } // End of IF condition for ncrecIdSet
       }
      // ------ End of code -------------------------------------------------------   
           //=================================================================================================history tracking
                 Map<id,Non_Conformance__c> afterupdateMap=new Map<id,Non_Conformance__c>();
                //========================================================update/insert
                system.debug('oldMap');
                if(oldMap==null){
                   oldMap=new Map<id,Non_Conformance__c>(); 
                }  
                Map<id,Non_Conformance__c> afterinsertMap=new Map<id,Non_Conformance__c>();
                    for(Non_Conformance__c gt:newMap.values()){
                        if(oldMap.get(gt.id)==null||!oldMap.containsKey(gt.id)){
                        afterinsertMap.put(gt.id,gt) ; 
                        }
                        else{
                            afterupdateMap.put(gt.id,gt) ; 
                        }
                    }
                    NonConformancehisList=new List<NC_History__c>();
                    NonConformance_Afterinsert(afterinsertMap);
                    NonConformance_IsAfter_FieldHistoryTracking(afterupdateMap,oldMap);   
                    NonConformance_IsAfter_UpdateGeneralTaskOwner(afterupdateMap,oldMap);
                    insert NonConformancehisList;
   }
    
  //===========================================FieldHistory Tracking
        public static Map<integer,string> dateMap;
        public static Map<id,User> User; 
        public static Map<id,Risk_Priority__c> RiskPriority;
        public static Map<id,Risk_Severity__c> RiskSeverity;
        public static List<NC_History__c> NonConformancehisList;
        public static void NonConformance_IsAfter_FieldHistoryTracking(Map<id,Non_Conformance__c> newMap,Map<id,Non_Conformance__c> oldMap){
             
        Map<String, Schema.SObjectField> Non_conformance_Lable =Schema.SObjectType.Non_conformance__c.fields.getMap();
            system.debug('Non_conformance_LableNon_conformance_Lable'+Non_conformance_Lable); 
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
        NC_History__c his;
        string fieldApiname;
        id temp;
        string tempstore;            
        Set<string> fieldsetNames=new Set<string>(); 
        Set<string> NCfieldsetNames=new Set<string>(); 
   
            final List<Schema.FieldSetMember> trackedFields =
                SObjectType.Non_Conformance__c.FieldSets.ResolutionFields.getFields();
            system.debug('trackedFields'+trackedFields);        
            for(Schema.FieldSetMember feildname:trackedFields){
                fieldsetNames.add(feildname.getFieldPath());
            }     
            final List<Schema.FieldSetMember> trackedNCFields =
                SObjectType.Non_Conformance__c.FieldSets.Non_Conformance_fields.getFields();
            system.debug('trackedFields'+trackedNCFields);        
            for(Schema.FieldSetMember feildname:trackedNCFields){
                NCfieldsetNames.add(feildname.getFieldPath());
            }
            set<Schema.FieldSetMember>  trsckedFieldsSet=new Set<Schema.FieldSetMember>(trackedFields);
            system.debug('RiskPriority'+RiskPriority);
            system.debug('RiskSeverity'+RiskSeverity);
            for(Non_Conformance__c nc:newMap.values()){         
                    final Non_Conformance__c oldNc = oldmap.get(nc.Id);    
                    Boolean resolution;                
                    for(Schema.SObjectField feildname:Schema.SObjectType.Non_conformance__c.fields.getMap().values()){
                        resolution=true;
                        fieldApiname=string.valueOf(feildname);
                        if(fieldsetNames.contains(fieldApiname)){       
                            if(nc.get(fieldApiname)!=oldNc.get(fieldApiname)){
                                    his=new NC_History__c();
                                    if(Non_conformance_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                                                                    
                                        his.FieldName__c=Non_conformance_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                                    }
                                    else{
                                        his.FieldName__c=Non_conformance_Lable.get(fieldApiname).getDescribe().getLabel(); 
                                    }
                                    //his.FieldName__c=Non_conformance_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel();
                                    his.FieldApiName__c=fieldApiname;
                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldNc.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldNc.get(fieldApiname));
                                                his.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(Nc.get(fieldApiname)!=null){
                                                mydate=date.valueOf(Nc.get(fieldApiname));
                                                his.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                            his.NewValue__c=string.valueOf(nc.get(fieldApiname));
                                            
                                        }
                                        his.Non_Conformance__c=nc.id;
                                        his.Parent__c='Resolution';
                                        his.object__c='Non_conformance__c';
                                        NonConformancehisList.add(his);   
                                        resolution=false; 
                                    }
                                else
                                if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){  
                                    system.debug('string. inside after reference');
                                    his=new NC_History__c();
                                    his.FieldName__c=Non_conformance_Lable.get(fieldApiname).getDescribe().getLabel();
                                    his.FieldApiName__c=fieldApiname;    
                                    system.debug('temp'+temp);                                    
                                    temp=string.valueOf(nc.get(fieldApiname));
                                    system.debug('temp'+temp);                                    
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
                                        
                                        
                                        
                                        tempstore=string.valueOf(oldNc.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null)&&!RiskPriority.isEmpty()))
                                        his.oldValue__c=RiskPriority.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(nc.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskPriority.isEmpty())
                                        his.NewValue__c=RiskPriority.get(string.valueOf(nc.get(fieldApiname))).Name;   
                                        his.Non_Conformance__c=nc.id;
                                        his.Parent__c='Resolution';
                                        his.object__c='Non_conformance__c';
                                        NonConformancehisList.add(his);  
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
                                        tempstore=string.valueOf(oldNc.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                        his.oldValue__c=RiskSeverity.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                        tempstore=string.valueOf(nc.get(fieldApiname));
                                        if((!(tempstore==''||tempstore==null))&&!RiskSeverity.isEmpty())
                                        his.NewValue__c=RiskSeverity.get(string.valueOf(nc.get(fieldApiname))).Name;   
                                        his.Non_Conformance__c=nc.id;
                                        his.Parent__c='Resolution';
                                        his.object__c='Non_conformance__c'; 
                                        NonConformancehisList.add(his);  
                                    }                                    
                                }                                 
                                
                                }                                 
                            }
                        else

                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&NCfieldsetNames.contains(fieldApiname)){
                                if(nc.get(fieldApiname)!=oldNc.get(fieldApiname)){
                                    his=new NC_History__c();
                                    his.FieldName__c=Non_conformance_Lable.get((fieldApiname)).getDescribe().getLabel();                                                                
                                    his.FieldApiName__c=fieldApiname;                                
                                    if(String.valueOf(feildname.getDescribe().getType())!='REFERENCE'){
                                        if(String.valueOf(feildname.getDescribe().getType())=='Date'||String.valueOf(feildname.getDescribe().getType())=='Datetime'){
                                            if(oldNc.get(fieldApiname)!=null){
                                                mydate=date.valueOf(oldNc.get(fieldApiname));
                                                his.oldValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());    
                                            }                                            
                                            if(Nc.get(fieldApiname)!=null){
                                                mydate=date.valueOf(Nc.get(fieldApiname));
                                                his.NewValue__c=string.valueOf(mydate.day()+' '+dateMap.get(mydate.month())+' '+mydate.year());                                                
                                            }
                                            
                                        }else{
                                            his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                            his.NewValue__c=string.valueOf(nc.get(fieldApiname));
                                            
                                        }
                                        his.Non_Conformance__c=nc.id;
                                        his.Parent__c='Non-Conformance';
                                        his.object__c='Non_conformance__c';
                                        NonConformancehisList.add(his);                        
                                    }
                                    
                                    if(String.valueOf(feildname.getDescribe().getType())=='REFERENCE'){  
                                        his=new NC_History__c();
                                        temp=string.valueOf(nc.get(fieldApiname));   
                                        for(string sbjf:Non_conformance_Lable.keySet()){
                                            system.debug('inside field set '+sbjf);
                                        }
                                        for(Schema.SObjectField sbjf:Non_conformance_Lable.values()){
                                            system.debug('inside field valuse '+sbjf);
                                        }                                            
                                        if(Non_conformance_Lable.containsKey(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname))){                                           	
                                            his.FieldName__c=Non_conformance_Lable.get(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)).getDescribe().getLabel(); 
                                        }
                                        else{
                                        	his.FieldName__c=Non_conformance_Lable.get(fieldApiname).getDescribe().getLabel(); 
                                        }
                                        if(temp.getSObjectType().getDescribe().getName()=='User'&&(fieldApiname=='Reporter__c'||fieldApiname=='Approver__c')){
                                            //
                                            if(User!=null){
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
                                            tempstore=string.valueOf(oldNc.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                his.oldValue__c=User.get(string.valueOf(oldNc.get(fieldApiname))).Name;
                                            tempstore=string.valueOf(nc.get(fieldApiname));
                                            if(!(tempstore==''||tempstore==null))
                                                his.NewValue__c=User.get(string.valueOf(nc.get(fieldApiname))).Name;   
                                            his.Non_Conformance__c=nc.id;
                                            his.Parent__c='Non-Conformance';
                                            his.object__c='Non_conformance__c';                                           
                                            NonConformancehisList.add(his);  
                                        }
                                    }
                                }                             
                        }

                    }          
                
            }  
        
    }
    public static void NonConformance_Afterinsert(Map<id,Non_Conformance__c> ncs){
      
        map<id,Non_Conformance__c> insertOldMap=new map<id,Non_Conformance__c>();
        NC_History__c his;
        for(Non_Conformance__c nc:ncs.values()){
            insertOldMap.put(nc.id,new Non_Conformance__c());
            his=new NC_History__c(); 
            his.Non_Conformance__c=nc.id;
            his.isCreated__c=true; 
            his.FieldName__c='Non Conformance';
            his.object__c='Non_conformance__c';
            NonConformancehisList.add(his);
        }  
        NonConformance_IsAfter_FieldHistoryTracking(ncs,insertOldMap);  
        for(NC_History__c nch:NonConformancehisList){
            nch.isCreated__c=true;
        }
        
    }
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //NonConformance trigger Handler end
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //NC Product Defect trigger Handler start
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     public static void NCProductDefect_BeforeTrigger(List<NC_Product_Defect__c> records)
     {
         NCproductDefect_IsBefore_fieldUpdates(records);
     }
    
    public static void NCproductDefect_IsBefore_fieldUpdates(List<NC_Product_Defect__c> records)
    {
        for(NC_Product_Defect__c ncpd: records)
        {
            System.debug('-->CustomerSupplier__c:'+ncpd.CustomerSupplier__c);
            ncpd.Customer_Supplier__c = ncpd.CustomerSupplier__c; 
        }
    }
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //NC Product Defect trigger Handler end
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //NC Product trigger Handler end
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
    public static List<NC_History__c> NCProducthisList;
    public static void NCProduct_Afterupdate(Map<id,NC_Product__c> newMap,Map<id,NC_Product__c> oldMap){   
        NCProducthisList=new List<NC_History__c>();   
        NCProduct_IsAfter_FieldHistoryTracking(newMap,oldMap);        
        insert NCProducthisList;
    }
    
    
        public static void NCProduct_IsAfter_FieldHistoryTracking(Map<id,NC_Product__c> newMap,Map<id,NC_Product__c> oldMap){
        Map<String, Schema.SObjectField> General_Task_Lable =Schema.SObjectType.NC_Product__c.fields.getMap();
        list<NC_Product__c> ncs=new list<NC_Product__c>();    
        NC_History__c his;
            string fieldApiname;
            

            for(NC_Product__c gt:newMap.values()){         
                    final NC_Product__c oldNc = oldmap.get(gt.Id);           
                    for(Schema.SObjectField feildname:Schema.SObjectType.NC_Product__c.fields.getMap().values()){
                        fieldApiname=string.valueOf(feildname);
                        if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'&&fieldApiname!='Id'){
                            if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                                his=new NC_History__c();
                                his.FieldName__c=General_Task_Lable.get(fieldApiname).getDescribe().getLabel();
                                his.FieldApiName__c=fieldApiname;

                                    if(oldNc.get(fieldApiname)!=null){
                                        his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                                    }
                                    if(gt.get(fieldApiname)!=null){
                                        his.NewValue__c=string.valueOf(gt.get(fieldApiname));  
                                    }
                                his.Non_Conformance__c=gt.non_conformance__c;
                                his.Parent__c='Product';
                                his.object__c='NC_Product__c';
                                NCProducthisList.add(his);                        
                            }                            
                        }

                    }          
                
            }  
        
    }
    public static void NCProduct_Afterinsert(Map<id,NC_Product__c> gts){
        NCProducthisList=new List<NC_History__c>();    
        map<id,NC_Product__c> insertOldMap=new map<id,NC_Product__c>();
        NC_History__c his;
        for(NC_Product__c gt:gts.values()){
            insertOldMap.put(gt.id,new NC_Product__c());
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isCreated__c=true; 
            his.FieldName__c='Product';
            his.object__c='NC_Product__c';
            NCProducthisList.add(his);
        }
        NCProduct_IsAfter_FieldHistoryTracking(gts,insertOldMap);  
        for(NC_History__c nch:NCProducthisList){
            nch.isCreated__c=true;
        }     
        insert NCProducthisList;
    }
            
    public static void NCProduct_Afterdelete(list<NC_Product__c> gts){
        List<NC_History__c> delhisList=new List<NC_History__c>();        
        NC_History__c his;
        for(NC_Product__c gt:gts){
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isdeleted__c=true; 
            his.FieldName__c='Product';
            his.object__c='NC_Product__c';
            NCProducthisList.add(his);
        }
        insert delhisList;          
    } 
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //NC Product trigger Handler end
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Product Lot Numbers  trigger Handler end
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
	public static void ProductLotNumbers_IsAfter(List<Product_Lot_Numbers__c> records){
	 try{
		Set<Id>  Unique_NC_Product_ids=new Set<Id>();
		Set<Id> plnIds = new Set<Id>();
		if (records != null){
			for(Product_Lot_Numbers__c pln:records){
				Unique_NC_Product_ids.add(pln.NC_Product__c);
			}
		}
		if (Unique_NC_Product_ids.size() < 1){
			System.debug('Unique_NC_Product_ids had a size that was less than 1');
			return;
		}
		List<NC_Product__c> NC_Product_List_For_Update = new List<NC_Product__c>();
		//Set<Id>  ncProductIds=Unique_NC_Product_ids.keySet();
		NC_Product__c ncProduct=null;
	    Map<Id,Integer> ncProductDefectSize=new Map<Id,Integer>();
		List<NC_Product_Defect__c> NC_Product_Defect_List=new List<NC_Product_Defect__c>();
		
		List<Product_Lot_Numbers__c> Product_Lot_Numbers_List=new List<Product_Lot_Numbers__c>();
		String ncProductQueryFields=QC_DynamicObjectHandler.getAccessibleFields('NC_Product__c', 'Id');
		String ncProductDefectQueryFields=QC_DynamicObjectHandler.getAccessibleFields('NC_Product_Defect__c', 'Id,Defect__c');
		String plnQueryFields=QC_DynamicObjectHandler.getAccessibleFields('Product_Lot_Numbers__c', 'Id,NC_Product__c');
		if(ncProductQueryFields!=null && ncProductQueryFields!='' && ncProductDefectQueryFields!=null && ncProductDefectQueryFields!=''&&  plnQueryFields!=null && plnQueryFields!=''){
			Map<Id,NC_Product__c> ncProductMap=new Map<Id,NC_Product__c>([SELECT Id,(SELECT id FROM Product_Lot_Numbers__r), Defect_Count_Unique__c FROM NC_Product__c WHERE id IN :Unique_NC_Product_ids]);
			for(id ncProdId:Unique_NC_Product_ids){
				for(Product_Lot_Numbers__c pln:ncProductMap.get(ncProdId).Product_Lot_Numbers__r){
				    plnIds.add(pln.Id);
				}
		    }
			Product_Lot_Numbers_List = Database.query('SELECT NC_Product__c,(SELECT id, Defect__c FROM NC_Product_Defects__r) FROM Product_Lot_Numbers__c  WHERE id IN :plnIds  LIMIT 1000');
			System.debug(Product_Lot_Numbers_List);
			Integer defectSize=0;
			for(Product_Lot_Numbers__c pln:Product_Lot_Numbers_List){
			    defectSize=ncProductDefectSize.get(pln.NC_Product__c);
			    ncProductDefectSize.put(pln.NC_Product__c,(defectSize==null)?pln.NC_Product_Defects__r.size():defectSize+pln.NC_Product_Defects__r.size());
			}
			for(id ncProdId:Unique_NC_Product_ids){
			    ncProduct=ncProductMap.get(ncProdId);
		        ncProduct.Defect_Count_Unique__c = ncProductDefectSize.get(ncProdId);
			    NC_Product_List_For_Update.add(ncProduct);
		   }
		   if(!NC_Product_List_For_Update.isEmpty() && QC_DynamicObjectHandler.checkCreateUpdateAccess('NC_Product__c','Defect_Count_Unique__c', 'update')){
		     update NC_Product_List_For_Update;
		   }
		}
	 }catch(Exception ex){
	 	 System.debug('Exception In NonConformanceTriggerHandler.ProductLotNumbers_IsAfter   '+ex.getMessage());
	 }
	   
	}
	
    public static void ProductLotNumbers_AfterUpdate(Map<id,Product_Lot_Numbers__c> newMap,Map<id,Product_Lot_Numbers__c> oldMap,List<Product_Lot_Numbers__c> records){
        
        ProductLotNumbersInsertUpdateLotNumbers(records);
        ProductLotNumbersupdateDefectSuspectFlag(records);
        ProductLotNumbersFieldHistoryTracking(newMap,oldMap);
    }
    
    public static void ProductLotNumbers_AfterInsertTrigger(List<Product_Lot_Numbers__c> records)
    {
       ProductLotNumbersInsertUpdateLotNumbers(records);
       ProductLotNumbersupdateDefectSuspectFlag(records);
       ProductLotNumbersAfterinsertHistoryTracking(records);
    }
    
    public static void ProductLotNumbersUpdateDefectSuspectFlag(List<Product_Lot_Numbers__c> records)
    {
        Set<Id> DefectRecIds = new Set<Id>();
    
        for(Product_Lot_Numbers__c pln : records)
        {
            if(pln.Defect_Codes__c != null && pln.Defect_Codes__c != '')
            {
                List<String> defectIdsStr = pln.Defect_Codes__c.split(',',0);
                for(String s: defectIdsStr)
                {
                    DefectRecIds.add(s);
                }
            } // End of IF condition
   
        } // End of for Loop
        
        System.debug('-->DefectRecIds:'+DefectRecIds);
        
        List<Defect__c> DefectList = new List<Defect__c>();
        //Map<Id,String> defectId_DefectVolumeUnit = new Map<Id,String>();
        
        if(defectrecIDs != null && defectrecIDs.size() > 0)
        {
            DefectList = [Select Id,Createddate,Lastmodifieddate,Count_Compare_value__c,Volume_Compare_Value__c,Count_Compare_Date__c,Volume_Compare_Date__c,Name,Volume_total_as_Num__c,Volume_Total_Time_as_Num__c,Volume_Total_Time_Unit__c,Count_Total_as_Num__c,NC_Defect_Total_Count__c from Defect__c where Id IN: DefectRecIds];
        }
        
        List<NC_Product_Defect__c> ncpdList = [Select Id,defect__c,Createddate,Lastmodifieddate,Product_Lot_Numbers__r.Lot_Quantity_Affected__c from NC_Product_Defect__c where Defect__c IN: DefectRecIds];
        
        List<Defect__c> defectUpdateList = new List<Defect__c>();
        // Iterate through defect and prepare list to uopdate defect for suspect flag
        for(Defect__c defct : DefectList)
        {
            decimal defectQuantitycount = 0;
            integer defectCount=0;
            // iterate through nc product defect
            for(NC_Product_Defect__c ncpd: ncpdList)
            {
                if(ncpd.Defect__c == defct.Id)
                {
                    if(ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c != null && defct.Volume_Compare_Value__c > 0 && ncpd.Lastmodifieddate >= defct.Volume_Compare_Date__c)
                    {
                        defectQuantitycount += ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c; 
                        
                    }
                    if(defct.Count_Compare_value__c > 0 && ncpd.Lastmodifieddate >= defct.Count_Compare_Date__c)
                    {
                        defectCount++;
                    }
                }
            } // end of Inner for loop
            
            
            if(defectQuantitycount > = (decimal)defct.Volume_total_as_Num__c)
            {
                // Include defect to update suspct flag
                defct.Suspect_Enabled__c = 'Yes';
                defectUpdateList.add(defct);
            }
            else if(defectCount >= defct.Count_Total_as_Num__c)
            {
                // Include defect to update suspct flag
                defct.Suspect_Enabled__c = 'Yes';
                defectUpdateList.add(defct);
            }
            else
            {
                defct.Suspect_Enabled__c = 'No';
                defectUpdateList.add(defct);
            }
        } // end of For Loop
        
        if(defectUpdateList != null && defectUpdateList.size() > 0)
        {
            update defectUpdateList;
        }
        
   } // End of function
    
    public static void ProductLotNumbersInsertUpdateLotNumbers(List<Product_Lot_Numbers__c> records)
    {
         Savepoint sp = Database.setSavepoint();
        try{  
          //Get PLN Ids
          Map<Id, Set<String>> dmap = new Map<Id, Set<String>>();
          for(Product_Lot_Numbers__c pln: records){
            dmap.put(pln.id, new Set<String>());   
          }
          
          //Get existing NC_Product_Defects__c
          List<NC_Product_Defect__c> todelete = new List<NC_Product_Defect__c>();
          List<NC_Product_Defect__c> toupdate = new List<NC_Product_Defect__c>();
          set<Id> ids = new set<Id>();
          for(NC_Product_Defect__c d:[select id, Product_Lot_Numbers__c, Product_Lot_Numbers__r.Defect_Codes__c, Defect__c from NC_Product_Defect__c where Product_Lot_Numbers__c IN :dmap.keyset()]){
           
           if(d.Product_Lot_Numbers__r.Defect_Codes__c != null && d.Product_Lot_Numbers__r.Defect_Codes__c != ''){
            if(!ids.contains(d.defect__c) &&  d.Product_Lot_Numbers__r.Defect_Codes__c.contains(d.Defect__c)){   
              dmap.get(d.Product_Lot_Numbers__c).add(d.Defect__c);
              ids.add(d.Defect__c);
              toupdate.add(d);
              
            }
            else
              todelete.add(d); 
           }
           
          }
          system.debug('Delete Size:' + todelete.size());
          //Create NC_Product_Defects__c
          List<NC_Product_Defect__c> toinsert = new List<NC_Product_Defect__c>();
          for(Product_Lot_Numbers__c pln: records){
            
            if(pln.Defect_Codes__c != null && pln.Defect_Codes__c != ''){
              List<String> defectids = pln.defect_codes__c.split(',');
              for(string s:defectids){
                if(!dmap.get(pln.id).contains(s))
                  toinsert.add(new NC_Product_Defect__c(
                    Defect__c = s,
                    Product_Lot_Numbers__c = pln.id
                  ));
              
              }
            }
          }
          
          if(todelete.size() > 0)
            delete todelete;
          if(toinsert.size() > 0)
            insert toinsert; 
          if(toupdate.size() > 0)
             update toupdate;
        }
        catch(Exception e) {
            Database.rollback(sp);
            ERR_Handler.processError(e, ERR_Handler_API.Context.PLNTRG);
        }
    }
    
    
    public static void ProductLotNumbersFieldHistoryTracking(Map<id,Product_Lot_Numbers__c> newMap,Map<id,Product_Lot_Numbers__c> oldMap){
        system.debug('FieldHistoryTracking');    
        Map<id,Defect__c> Defects=new Map<id,Defect__c>();
            String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('user', 'id,Name');            
            if(queryFieldNames != null && queryFieldNames != '')
            {
                String qry='select ' + queryFieldNames + ' FROM Defect__c';
                LIST<Defect__c> dlist=database.query (qry);
                Defects.putAll(dlist);                
            }             
        List<String> defectids=new List<String>();
        
        Map<String, Schema.SObjectField> Product_Lot_Numbers_Lable =Schema.SObjectType.Product_Lot_Numbers__c.fields.getMap();
        list<Product_Lot_Numbers__c> ncs=new list<Product_Lot_Numbers__c>();    
        List<NC_History__c> hisList=new List<NC_History__c>();
        NC_History__c his;
        string fieldApiname;
        string temp;
        for(Product_Lot_Numbers__c gt:newMap.values()){         
            final Product_Lot_Numbers__c oldNc = oldmap.get(gt.Id);           
            for(Schema.SObjectField feildname:Schema.SObjectType.Product_Lot_Numbers__c.fields.getMap().values()){
                fieldApiname=string.valueOf(feildname);
                if(fieldApiname!='LastModifiedDate'&&fieldApiname!='SystemModstamp'){
                    if(gt.get(fieldApiname)!=oldNc.get(fieldApiname)){
                        his=new NC_History__c();
                        his.FieldName__c='Product Lot Numbers /';
                        system.debug('inside pln trg Numbers');
                        his.FieldName__c+=Product_Lot_Numbers_Lable.get(fieldApiname).getDescribe().getLabel();
                        his.FieldApiName__c=fieldApiname;
                        system.debug('inside pln trg Product_Lot_Numbers_Lable');
                        his.oldValue__c=string.valueOf(oldNc.get(fieldApiname));
                        his.NewValue__c=string.valueOf(gt.get(fieldApiname));  
                        system.debug('inside defect fieldApiname'+fieldApiname);
                        if(QC_custom_settings.removeNamespaceFromFieldName(fieldApiname)=='Defect_Codes__c'){
                            his.oldValue__c='';
                            system.debug('inside pln trg cDefect_Codes__cls');
                            if(oldNc.get(fieldApiname)!=null){
                                defectids=string.valueOf(oldNc.get(fieldApiname)).split(',');
                                for(String id:defectids){
                                    his.oldValue__c+=Defects.get(id).Name+',';
                                }                                
                            }

                            system.debug('inside pln trg defectids');
                            his.NewValue__c='';
                            if(gt.get(fieldApiname)!=null){
                                defectids=string.valueOf(gt.get(fieldApiname)).split(',');
                                for(String id:defectids){
                                    his.NewValue__c+=Defects.get(id).Name+',';
                                }                                                            
                            }

                        }
                       //     fieldApiname=fieldApiname+'.Name';     
                       // } 
                        his.Non_Conformance__c=gt.non_conformance__c;
                        his.Parent__c='NC Product';
                        his.object__c='Product_Lot_Numbers__c';
                        hisList.add(his);                        
                    }                            
                }
                
            }          
            
        }  
        insert hisList;
        
    }
    public static void ProductLotNumbersAfterinsertHistoryTracking(list<Product_Lot_Numbers__c> gts){

        List<NC_History__c> hisList=new List<NC_History__c>();        
        NC_History__c his;
        for(Product_Lot_Numbers__c gt:gts){
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isCreated__c=true; 
            his.FieldName__c='Product Lot Numbers';
            his.Parent__c='NC Product';            
            his.object__c='Product_Lot_Numbers__c';
            hisList.add(his);
        }
        insert hisList;     
        
    }
            
    public static void ProductLotNumbers_Afterdelete(list<Product_Lot_Numbers__c> gts){
        List<NC_History__c> hisList=new List<NC_History__c>();        
        NC_History__c his;
        for(Product_Lot_Numbers__c gt:gts){
            his=new NC_History__c(); 
            his.Non_Conformance__c=gt.Non_conformance__c;
            his.isdeleted__c=true; 
            his.Parent__c='NC Product';            
            his.FieldName__c='Product Lot Numbers';
            his.object__c='Product_Lot_Numbers__c';
            hisList.add(his);
        }
        insert hisList; 
        ProductLotNumbers_IsAfter(gts);
    }    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Product Lot Numbers trigger  Handler end
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
}