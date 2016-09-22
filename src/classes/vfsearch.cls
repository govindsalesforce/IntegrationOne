/*
 v1.0	 	Qualityze Inc(ST)     	02-AUG-2016  	Add Some check for DocumentType DocumentProfileCreation. 
V1.0.1		Qualityze Inc(PRG)     	26-AUG-2016  	Added Module filter for Documenttype.
*/
public with sharing class vfsearch{

  public string js;
  public string getjs(){ System.debug('About to return js = ' + js); return js; }
  public vfsearch(){ }
  
  public static Set<Id> FinaluserIDSet;
  public Static Set<Id> FinalUserRoleIdSet;
  Public Static string NameSpace;
  public static set<id> ParentProids;
    public static Map<id,set<id>> ChildParent;
    public static Void  getParentIds(Set<Id> Children,string NC_Type){
        
        set<id> parentids=new set<id>();
        if(NC_Type=='Product'){
            if(ChildParent==null){
                string ProductRelationshipAccessible=QC_DynamicObjectHandler.getAccessibleFields('Product_Relationship__c', 'id,Parent_Product__c,Child_Product__c');                
                if(ProductRelationshipAccessible!=null && ProductRelationshipAccessible!='') {
                    ChildParent=new MAP<id,set<id>>();
                    set<id> newset;
                    for(Product_Relationship__c prod:Database.query('Select ' + ProductRelationshipAccessible + ' from Product_Relationship__c where  Child_Product__c !=null Limit 999')){
                        if(ChildParent.containsKey(prod.Child_Product__c)){
                            ChildParent.get(prod.Child_Product__c).add(prod.Parent_Product__c);
                        }
                        else{
                            newset=new set<id>();
                            newset.add(prod.Parent_Product__c);
                            ChildParent.put(prod.Child_Product__c,newset);
                        }
                        
                    }
                }
            }
            for(id id:Children){
                if(ChildParent.get(id)!=null){
                    ParentProids.addAll(ChildParent.get(id));                  
                    getParentIds(ChildParent.get(id),'Product');                    
                }
            }
            
            
        }else{
            if(ChildParent==null){
                string ProductRelationshipAccessible=QC_DynamicObjectHandler.getAccessibleFields('Process_Relationship__c', 'id,Operational_Process__c,Standard_Operational_Process__c');                
                if(ProductRelationshipAccessible!=null && ProductRelationshipAccessible!='') {
                    ChildParent=new MAP<id,set<id>>();
                    set<id> newset;
                    for(Process_Relationship__c proc:Database.query('Select ' + ProductRelationshipAccessible + ' from Process_Relationship__c where  Operational_Process__c !=null Limit 999')){
                        if(ChildParent.containsKey(proc.Operational_Process__c)){
                            ChildParent.get(proc.Operational_Process__c).add(proc.Standard_Operational_Process__c);
                        }
                        else{
                            newset=new set<id>();
                            newset.add(proc.Standard_Operational_Process__c);
                            ChildParent.put(proc.Operational_Process__c,newset);
                        }
                        
                    }
                }
            }
            for(id id:Children){
                if(ChildParent.get(id)!=null){
                    ParentProids.addAll(ChildParent.get(id));                
                    getParentIds(ChildParent.get(id),'Process');                    
                }
            }            
        }
        
    } 
   /* public static Set<Id> getParentIds(Set<Id> Children,string NC_Type){
        List<Product_Relationship__c> parentsPROD;
        List<Process_Relationship__c> parentsPROC;
        set<id> parentids=new set<id>();
        if(NC_Type=='Product'){
            string ProductRelationshipAccessible=QC_DynamicObjectHandler.getAccessibleFields('Product_Relationship__c', 'id,Parent_Product__c');
            
            if(ProductRelationshipAccessible!=null && ProductRelationshipAccessible!='') {
                parentsPROD = Database.query('Select ' + ProductRelationshipAccessible + ' from Product_Relationship__c where  Child_Product__c IN: Children ');    
                if(!parentsPROD.isEmpty()){
                    for(Product_Relationship__c pr:parentsPROD){
                        parentids.add(pr.Parent_Product__c);
                    }
                    ParentProids.addAll(parentids);
                    getParentIds(parentids,'Product');
                }
            }
        }else{
            string ProcessRelationshipAccessible=QC_DynamicObjectHandler.getAccessibleFields('Process_Relationship__c', 'id,Standard_Operational_Process__c');
            
            if(ProcessRelationshipAccessible!=null && ProcessRelationshipAccessible!='') {
                parentsPROC = Database.query('Select ' + ProcessRelationshipAccessible + ' from Process_Relationship__c where  Operational_Process__c IN: Children ');  
                if(!parentsPROC.isEmpty()){
                    for(Process_Relationship__c pr:parentsPROC){
                        parentids.add(pr.Standard_Operational_Process__c);
                    }
                    ParentProids.addAll(parentids);
                    getParentIds(parentids,'Process');
                }                
            }
        }
        return new Set<id>();
    }  */
public static Set<Id> getUserIds(Set<Id> groupId )
{
    Set<Id> subGroupIds = new Set<ID>();
    FinalUserRoleIdSet=new Set<ID>();
    List<GroupMember> grmList = new List<GroupMember>();
   

    string groupmemberaccessible=QC_DynamicObjectHandler.getAccessibleFields('GroupMember', 'id,GroupId,UserOrGroupId');
    
   if(groupmemberaccessible!=null && groupmemberaccessible!='') {
   grmList = Database.query('Select ' + groupmemberaccessible + ' from GroupMember where  GroupId IN: groupId ');   
   }
        for(GroupMember gm : grmList)
    {
        String tempUserOrGroupId = gm.UserOrGroupId;
        if(tempUserOrGroupId.startsWith('005'))
        {
            FinaluserIDSet.add(gm.UserOrGroupId);
        }
        if(tempUserOrGroupId.startsWith('00G'))
        {
            subGroupIds.add(gm.UserOrGroupId);
        }
        
    }// end of For loop
   
    List<Group> groupRecords = new List<Group>();
    Set<ID> UserRoleIdSet = new Set<Id>();
    if(subGroupIds.size() > 0)
    {
        Set<Id> childGroupIdsSet =  new Set<ID>();
        string groupmemberaccessible1=QC_DynamicObjectHandler.getAccessibleFields('Group', 'Id,DeveloperName,RelatedId,Type');
        if(groupmemberaccessible1!=null && groupmemberaccessible1!='') {
         groupRecords= Database.query(' Select '  + groupmemberaccessible1 +  ' from Group Where Id IN:subGroupIds ');
        }

      
        for(Group g: groupRecords)
        {
            if(g.Type == 'Role')
            {
                UserRoleIdSet.add(g.RelatedId);
            }
            if(g.Type == 'RoleAndSubordinates')
            {
                FinalUserRoleIdSet.add(g.RelatedId);
            }
            if(g.Type == 'Regular')
            {
                childGroupIdsSet.add(g.Id);
            }
          
        }// end of For Loop
    
        if(UserRoleIdSet.size() > 0 || FinalUserRoleIdSet.size() > 0)
        {
            Set<Id> roleIdSet = new Set<Id>();
            if(FinalUserRoleIdSet.size() > 0)
            {
                roleIdSet.addAll(FinalUserRoleIdSet);
            }
            if(UserRoleIdSet.size() > 0)
                roleIdSet.addAll(UserRoleIdSet);

            System.debug('-->roleIdSet: '+ roleIdSet);
            System.debug('-->roleIdSet Size: '+ roleIdSet.size());
            
            string rolememberaccessible=QC_DynamicObjectHandler.getAccessibleFields('User', 'id,isActive,UserRoleId');
            if(rolememberaccessible!='null'  && rolememberaccessible!='') {
                List<User> userList=Database.query(' Select ' + rolememberaccessible + ' from User where isActive=true and UserRoleId IN: roleIdSet ');
            
           

            for(User u: userList)
            {
                FinaluserIDSet.add(u.id);
            }
          
         
        }// end of If
    } 
        if(childGroupIdsSet.size() > 0)
        {
            FinaluserIDSet.addAll(getUserIds(childGroupIdsSet));
        }
    }
       
    system.debug('@----' +FinaluserIDSet);
    return FinaluserIDSet;
  
 } // end of Function
    
public void getchildRoleIds(Set<Id> roleIds)
{
    Set<Id> subroleIds = new Set<ID>();
    
    List<UserRole> userRoleList = new List<UserRole>();
    string userroleaccessible=QC_DynamicObjectHandler.getAccessibleFields('UserRole','Id,ParentRoleId');
    
       if(userroleaccessible!='null' && userroleaccessible!='')  {
          userRoleList=Database.query(' Select ' + userroleaccessible + ' from UserRole where ParentRoleId IN: roleIds ');
    
    
       }
 
    if(userRoleList.size() > 0)
    {
        for(UserRole ur: userRoleList)
        {
            if(!string.isEmpty(ur.ParentRoleId))
            {
                FinalUserRoleIdSet.add(ur.Id);
                subroleIds.add(ur.Id);
            }
          
        }// end of For loop
        
        if(subroleIds.size() > 0)
            getchildRoleIds(subroleIds);
 
    }// end of If

}
  
  public void vfsearchAction(){  
  System.debug('Entered vfsearchAction()...');
  NameSpace=Dev_Only__c.getOrgDefaults().Namespace_Prefix__c;
      System.debug('Before IF Entered NameSpace...'+NameSpace);
      if(NameSpace!=null && NameSpace!=''){
          NameSpace+='__';          
      }else{
          NameSpace='';
      }
  System.debug('Entered NameSpace...'+NameSpace);
  String TOU=apexpages.currentpage().getparameters().get('tou');
      Set<Id> allGroupIDs=new Set<Id>();
      System.debug('value of TOU is'  +TOU);

//**** MaheshK Included below custom setting code ****
List<QC_VfsearchQueries__c> vfsearchQueries = QC_VfsearchQueries__c.getall().values(); // get list of all custom setting values
     
   if(apexpages.currentpage().getparameters().get('type') == 'sosl'){

       String soslSearchTerm = apexpages.currentpage().getparameters().get('qsearchterm');
       system.debug ('Line 16: soslSearchTerm = ' + soslSearchTerm);
       String queryTable = apexpages.currentpage().getparameters().get('qt');
       String filterValue;
       if (null != apexpages.currentpage().getparameters().get('filtervalue')) {
         filterValue = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('filtervalue'));
       }
       String allStringsInOne;
       if (null != apexpages.currentpage().getparameters().get('allstringsinone')) {
         allStringsInOne = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('allstringsinone'));
       }
       
       String soslEscapedSearchTerm = String.escapeSingleQuotes(soslSearchTerm);
       String soslEscapedQueryString;
       string soslObjName;
       string soslFieldNames;      
       List<List<sobject>> results; 
       
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           if(setting.Type__c == 'sosl' && setting.ObjectName__c == queryTable) {
            soslObjName = setting.ObjectName__c;
            soslFieldNames = setting.QueryFields__c;        
           }
        }
        if(soslObjName != null && soslObjName != '' && soslFieldNames != null && soslFieldNames != '')
         {
                String soslAccessibleFieldNames = QC_DynamicObjectHandler.getAccessibleFields(soslObjName,soslFieldNames);

                if(soslAccessibleFieldNames != null && soslAccessibleFieldNames != '')
                 {
                    soslEscapedQueryString = 'FIND \'' + soslEscapedSearchTerm + '*\' IN ALL FIELDS RETURNING ' + soslObjName + '(' + soslAccessibleFieldNames;

                        // Below SOSL is for Account object which will segregate based on recordtypes 
                         if(queryTable == 'Account')
                         {
                             if(filterValue != null && filterValue != ''){
                                 soslEscapedQueryString += ' where Recordtype.DeveloperName = ' + '\''+ filterValue + '\' AND Active__c= true )';
                                 system.debug('inside '+soslEscapedQueryString);
                             }else{
                                 soslEscapedQueryString += ' where  Active__c= true)';
                             }
                         }
                        
                        if(queryTable == 'User')
                        {
                          soslEscapedQueryString += ' where isActive = true';
                          if(TOU!=NULL &&  TOU!='')                                                     
                          {    
                           FinaluserIDSet=new set<id>();
                           system.debug('if(TOU!=NULL&&TOU!=)'+TOU);
                           String grpAccessibleFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Group','Id,Developername');
                           if(grpAccessibleFieldNames!=null && grpAccessibleFieldNames!=''){
                                List<Group> groups=database.query('select '+grpAccessibleFieldNames+' from group where Developername =:TOU'); 
                                     Set<Id> grIDSet = new Set<Id>();
                                     for(Group g : groups){
                                        grIDSet.add(g.id);
                                     }
                               getUserIds(grIDSet);
                           }                            
                           soslEscapedQueryString+= ' AND ID IN: FinaluserIDSet'; 
                           system.debug('@sosl-------' +soslEscapedQueryString);
                          }
                          soslEscapedQueryString+=')'; 
                          system.debug('About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
                         results = search.query(soslEscapedQueryString);
                        }
                     else if(queryTable == 'Account') {
                     // soslEscapedQueryString+=  ' AND Active__c= \'yes\')';
                     system.debug('About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
	                   results = search.query(soslEscapedQueryString);
	                 }
	                 //v1.0 start
	                else if(queryTable == 'Document_Type__c'){
	                    soslEscapedQueryString+=  ' where Status__c=\'Active\')';
	                    system.debug('Document_Type__c.About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
	                    results = search.query(soslEscapedQueryString);
	                }
	                //v1.0 end
	                 //v1.0.2 start
	                else if(queryTable == 'Document_Profile__c'){
	                    soslEscapedQueryString+=  ' where Status__c=\'Current\')';
	                    system.debug('Document_Type__c.About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
	                    results = search.query(soslEscapedQueryString);
	                }
	                
	                else if(queryTable == 'Non_Conformance__c'){
	                    soslEscapedQueryString+=  ' where NC_Status__c=\'Closed\')';
	                    system.debug('Document_Type__c.About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
	                    results = search.query(soslEscapedQueryString);
	                }
	                //v1.0.2 end
	                // v1.0.3 start
	                   else if(queryTable == 'CAPA__c'){
	                    soslEscapedQueryString+=  ' where CAPA_Status__c=\'Open\')';
	                    system.debug('Document_Type__c.About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
	                    results = search.query(soslEscapedQueryString);
	                }
	            
	                // v1.0.3 end
	                  //V1.0.1_Start
                  else if(queryTable == 'Number_Scheme__c'){
                      soslEscapedQueryString += ' where Module__c=\''+filterValue+'\')';
                       system.debug('Number_Scheme__c.About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
                       results = search.query(soslEscapedQueryString);
                  }
                    //v1.0.1-END
	                 else
                        {
                            soslEscapedQueryString += ' where Active__c= true)';
                            system.debug('About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
                             results = search.query(soslEscapedQueryString);
                        }
                                              
                 }
         }
        
       if(String.isNotBlank(allStringsInOne)){
            system.debug('BEN_WUZ_HERE: Entered isNotBlank(allStringsInOne) conditional');
            String fieldsToReturn ='';
            for( String fieldName : Schema.getGlobalDescribe().get(allStringsInOne).getDescribe().fields.getMap().keySet() ) {
                if(fieldsToReturn != '') {
                    fieldsToReturn += ', ';
                }
                fieldsToReturn += fieldName;
            }
            String AccessibLeFields = QC_DynamicObjectHandler.getAccessibleFields(allStringsInOne,fieldsToReturn);
            if(AccessibLeFields != null && AccessibLeFields != '')
           {
                soslEscapedQueryString = 'FIND \''+ soslEscapedSearchTerm + '*\' IN ALL FIELDS RETURNING '+ allStringsInOne + ' (' + AccessibLeFields +')';
                system.debug('About to execute search.query(soslEscapedQueryString); where soslEscapedQueryString = \'' + soslEscapedQueryString + '\'');
                results = search.query(soslEscapedQueryString);                
           }
       }


       
       system.debug(results.size());
       for(List<sobject> l:results){
         system.debug(l.size());
       }
       
       try{
         system.debug(results);
         system.debug(results[0]);
         js = JSON.serialize(results[0]);
       }catch(exception e){
         ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
         system.debug(e.getmessage());
         js = JSON.serialize(new List<sObject>());
       }
       system.debug(js);
     }
     
     else if(apexpages.currentpage().getparameters().get('type') == 'prodsoql'){
       String productid = apexpages.currentpage().getparameters().get('id');
       Set<Id> ids = new set<Id>();
       String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Product_Defect__c','id, Product__c, Defect__c, Defect__r.Name');       
       
       if(queryFieldNames != null && queryFieldNames != '')
         {
           if(ParentProids==null){
               ParentProids=new set<id>(); 
           } 
            set<id> product = new set<id>();
            product.add(productid);
            getParentIds(product,'Product'); 
            ParentProids.add(productid);
            system.debug('outside fro loop defect product soql');
            for(Product_Defect__c d:database.query ('select ' + queryFieldNames + ' from Product_Defect__c where Product__c IN :ParentProids AND Defect__r.nc_type__c=\'Product\'')){
            ids.add(d.Defect__c);
            system.debug('inside fro loop defect product soql');
            system.debug(d.Defect__c);
            }
         }
       
       String queryFieldNamesDefects = QC_DynamicObjectHandler.getAccessibleFields('Defect__c','id,product_Count__c,nc_type__c,Active__c');
       if(queryFieldNamesDefects != null && queryFieldNamesDefects != '')
         {
            if(ids.isEmpty())
            for(Defect__c d:database.query('select ' + queryFieldNamesDefects + ' from Defect__c where  nc_type__c = \'Product\' and Active__c = true')){            
             ids.add(d.id);
             }
         }

       string s;
       string prodsoqlObjName;
       string prodsoqlFieldNames;

       //*** Get the query value from custom setting ******
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           if(setting.Type__c == 'prodsoql') {
            prodsoqlObjName = setting.ObjectName__c;
            prodsoqlFieldNames = setting.QueryFields__c;            
           }
        }
        
        if( prodsoqlObjName != null && prodsoqlObjName != '' && prodsoqlFieldNames != null && prodsoqlFieldNames != '')
         {
            String prodsoqlFieldNamesAccessible = QC_DynamicObjectHandler.getAccessibleFields(prodsoqlObjName, prodsoqlFieldNames);
        
            if(prodsoqlFieldNamesAccessible != null && prodsoqlFieldNamesAccessible != '')
             {
                s = 'Select ' + prodsoqlFieldNamesAccessible + ' from ' + prodsoqlObjName;

                 if(ids.size() > 0){
                     s += ' where id IN :ids and Active__c = true';
                 }       
                else{
                    s += ' where nc_Type__c=\'Product\' and Active__c = true';
                }
                   try{
                     system.debug('SOMETHING UNIQUE line 88: s = ' + s);
                     js = JSON.serialize(database.query(s));
                   }catch(exception e){
                     ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
                     js = JSON.serialize(new List<sObject>());
                   }           
             }  
         }
       

       
     }
     
     else if(apexpages.currentpage().getparameters().get('type') == 'prodsosl'){
       String productid = apexpages.currentpage().getparameters().get('id');
       String soslQueryString;
       String soslSearchTerm =  apexpages.currentpage().getparameters().get('qsearchterm');
       String queryTable = apexpages.currentpage().getparameters().get('qt');
       
       String soslEscapedSearchTerm = String.escapeSingleQuotes(soslSearchTerm);
       
       Set<Id> ids = new set<Id>();
       string product_defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Product_Defect__c', 'id, Product__c, Defect__c, Defect__r.Name');
       
       if(product_defect_fieldList != null && product_defect_fieldList != '')
       {     
           if(ParentProids==null){
               ParentProids=new set<id>(); 
           }
             set<id> product = new set<id>();
             product.add(productid);
             getParentIds(product,'Product'); 
             ParentProids.add(productid);
            for(Product_Defect__c d:database.query('select ' + product_defect_fieldList + ' from Product_Defect__c where Product__c IN :ParentProids AND Defect__r.nc_type__c=\'Product\'')) 
            {
                ids.add(d.Defect__c);          
            }
         }
       
       string defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Defect__c', 'id, product_Count__c, nc_type__c,Active__c');
       if(defect_fieldList != null && defect_fieldList != '')
         {
            if(ids.isEmpty())
            for(Defect__c d:database.query('select ' + defect_fieldList + ' from Defect__c where  nc_type__c = \'Product\' and Active__c = true')) 
            {            
            system.debug(d.nc_type__c);
            ids.add(d.id);
            }
         }

       string prodsoslObjName;
       string prodsoslFieldNames;
         
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           if(setting.Type__c == 'prodsosl' && setting.ObjectName__c == queryTable) {
            
            prodsoslObjName = setting.ObjectName__c;
            prodsoslFieldNames = setting.QueryFields__c;
           }

        }
        
        if(prodsoslObjName != null && prodsoslObjName != '' && prodsoslFieldNames != null && prodsoslFieldNames != '')
         {
            String prodsoslFieldNamesAccessible = QC_DynamicObjectHandler.getAccessibleFields(prodsoslObjName, prodsoslFieldNames);
            if( prodsoslFieldNamesAccessible != null && prodsoslFieldNamesAccessible != '')
             {
                soslQueryString = 'FIND \'' + soslEscapedSearchTerm + '*\' IN ALL FIELDS RETURNING ' + prodsoslObjName + '(' + prodsoslFieldNamesAccessible;
               
                if(ids.size() > 0){
                 soslQueryString += ' where id IN :ids and Active__c = true';
                }        
                else{
                   soslQueryString += ' where nc_Type__c=\'Product\' and Active__c = true';
                }
               soslQueryString += ')';
               try{
                 system.debug('SOMETHING UNIQUE line 123: soslQueryString = ' + soslQueryString);
                 js = JSON.serialize(search.query(soslQueryString)[0]);
               }catch(exception e){
                 ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
                 system.debug(e.getMessage());
                 js = JSON.serialize(new List<sObject>());
               }               
             }
               system.debug('-->MK prodsosl:'+soslQueryString);
         }

       system.debug(js);
       
     }
     //************************************** code added for process *********************
      else if(apexpages.currentpage().getparameters().get('type') == 'procsoql'){
       String processid = apexpages.currentpage().getparameters().get('id');   
       Set<Id> ids = new set<Id>();
       string Process_Defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Process_Defect__c', 'id, Defect__c, Standard_Operational_Process__c, Defect__r.Name');
       
       if(Process_Defect_fieldList != null && Process_Defect_fieldList != '')
        {
            if(ParentProids==null){
                ParentProids=new set<id>(); 
            }
            set<id> product = new set<id>();
            product.add(processid);
            getParentIds(product,'Process'); 
            ParentProids.add(processid);
            for(Process_Defect__c d:database.query('select ' + Process_Defect_fieldList + ' from Process_Defect__c where Standard_Operational_Process__c IN :ParentProids AND Defect__r.nc_type__c=\'Process\'')) 
            {
                ids.add(d.Defect__c);
            }
        }
       
       string Defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Defect__c', 'id, process_Count__c, nc_type__c,Active__c');
       
       if(Defect_fieldList != null && Defect_fieldList != '')
        {
            if(ids.isEmpty())
            for(Defect__c d:database.query('select ' + Defect_fieldList + ' from Defect__c where  nc_type__c = \'Process\' and Active__c = true')) 
            {
            system.debug(d.nc_type__c);
            ids.add(d.id);
            }
        }
         
       string s;
       string procsoqlObjName;
       string procsoqlFieldNames;       
        //*** Get the query value from custom setting ******
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           if(setting.Type__c == 'procsoql') {
            procsoqlObjName = setting.ObjectName__c;
            procsoqlFieldNames = setting.QueryFields__c;             
           }
        }
        
        if(procsoqlObjName != null && procsoqlObjName != '' && procsoqlFieldNames != null && procsoqlFieldNames != '')
          {
                String procsoqlFieldNamesAccessible = QC_DynamicObjectHandler.getAccessibleFields(procsoqlObjName, procsoqlFieldNames);
                if(procsoqlFieldNamesAccessible != null && procsoqlFieldNamesAccessible != '')
                {
                    s = 'Select ' + procsoqlFieldNamesAccessible + ' from ' + procsoqlObjName;

                   if(ids.size() > 0){
                     s += ' where id IN :ids and Active__c = true';
                   }        
                   else{
                     s += ' where nc_Type__c=\'Process\' and Active__c = true';
                    }
                   try{
                     js = JSON.serialize(database.query(s));
                   }catch(exception e){
                     ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
                     js = JSON.serialize(new List<sObject>());
                   }
                }
               system.debug('-->MK procsoql:'+s);
         }
       
     }
     
     else if(apexpages.currentpage().getparameters().get('type') == 'procsosl'){
       String processid = apexpages.currentpage().getparameters().get('id');
       String soslQueryString;
       String soslSearchTerm =  apexpages.currentpage().getparameters().get('qsearchterm');
       String queryTable = apexpages.currentpage().getparameters().get('qt');
       
       String soslEscapedSearchTerm = String.escapeSingleQuotes(soslSearchTerm);
       
       Set<Id> ids = new set<Id>();
       string Process_Defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Process_Defect__c', 'id, Standard_Operational_Process__c, Defect__c, Defect__r.Name');
       if(Process_Defect_fieldList != null && Process_Defect_fieldList != '')
         {
            if(ParentProids==null){
                ParentProids=new set<id>(); 
            }
            set<id> product = new set<id>();
            product.add(processid);
            getParentIds(product,'Process'); 
            ParentProids.add(processid);             
            for(Process_Defect__c d:database.query('select ' + Process_Defect_fieldList + ' from Process_Defect__c where Standard_Operational_Process__c IN :ParentProids AND Defect__r.nc_type__c=\'Process\'')) 
            {
                ids.add(d.Defect__c);
            }
         }
        
       string Defect_fieldList = QC_DynamicObjectHandler.getAccessibleFields('Defect__c', 'id, process_Count__c, nc_type__c,Active__c');
       if(Defect_fieldList != null && Defect_fieldList !='')
         {
             if(ids.isEmpty())
            for(Defect__c d:database.query('select ' + Defect_fieldList + ' from Defect__c where nc_type__c = \'Process\' and Active__c = true')) 
            {
                ids.add(d.id);
            }
         }
       
       string procsoslObjName;
       string procsoslFieldNames;  
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           if(setting.Type__c == 'procsosl' && setting.ObjectName__c == queryTable) {
            
            procsoslObjName = setting.ObjectName__c;
            procsoslFieldNames = setting.QueryFields__c;
           }
        }
        if(procsoslObjName != null && procsoslObjName != '' && procsoslFieldNames != null && procsoslFieldNames !='')
         {
                string procsoslFieldNamesAccessible = QC_DynamicObjectHandler.getAccessibleFields(procsoslObjName, procsoslFieldNames);
                if(procsoslFieldNamesAccessible != null && procsoslFieldNamesAccessible !='')
                {
                    soslQueryString = 'FIND \'' + soslEscapedSearchTerm + '\' IN ALL FIELDS RETURNING ' + procsoslObjName + '(' + procsoslFieldNamesAccessible;
            
                   if(ids.size() > 0){
                     soslQueryString += ' where id IN :ids and Active__c = true';
                   }         
                   else{
                     soslQueryString += ' where nc_Type__c=\'Process\' and Active__c = true';
                    }
                   soslQueryString += ')';
                   system.debug(soslQueryString );
                   try{
                     js = JSON.serialize(search.query(soslQueryString)[0]);
                   }catch(exception e){
                     ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
                     system.debug(e.getMessage());
                     js = JSON.serialize(new List<sObject>());
                   }
                }
         }


       system.debug(js);
       
     }
       //************************************** code added for defect *********************
    else if(apexpages.currentpage().getparameters().get('type') == 'defcsoql'){
       String defectid = apexpages.currentpage().getparameters().get('id');
       String causetype=apexpages.currentpage().getparameters().get('causetype');
        String soslQueryString;
       String soslSearchTerm =  apexpages.currentpage().getparameters().get('qsearchterm');
       String queryTable = apexpages.currentpage().getparameters().get('qt');
       Set<Id> ids = new set<Id>();
       System.debug('vfsearch defcsoql defectid '+defectid+' queryTable   '+queryTable);
       
       String defectCauseFieldList = QC_DynamicObjectHandler.getAccessibleFields('Defect_Cause__c', 'id,Cause__c,Defect__c,Defect__r.Name');
       
       if(defectCauseFieldList!=null && defectCauseFieldList!=''){
          for(Defect_Cause__c d: Database.query('Select '+defectCauseFieldList+' from Defect_Cause__c where Defect__c = :defectid'))
               ids.add(d.Cause__c);
       }
       else{
          System.debug('vfsearch   no access for defectCauseFieldList   '+defectCauseFieldList);
       }
       
       String causeFieldList= QC_DynamicObjectHandler.getAccessibleFields('Cause__c', 'Id,Name,Cause_Code__c');
      
       if(causeFieldList!=null && causeFieldList!=''){
          if(ids.isEmpty())
          for(Cause__c d:Database.query('SELECT '+causeFieldList+' from Cause__c WHERE  Type__c=:causetype')){
             ids.add(d.id);
          }
       }
       else{
         System.debug('vfsearch   no access for causeFieldList   '+causeFieldList);
       }
         
       String soslEscapedSearchTerm = (soslSearchTerm!=null)?String.escapeSingleQuotes(soslSearchTerm):null;
       String searchType=soslEscapedSearchTerm==null?'defcsoql':'defcsosl';
       System.debug('Testing Entered NameSpace...'+NameSpace);  
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           System.debug('defcsoql setting.Type__c    '+setting.Type__c+'   setting.ObjectName__c '+setting.ObjectName__c+'    queryTable    '+queryTable);
           System.debug(setting.Type__c == searchType && setting.ObjectName__c == queryTable);
           
           if(setting.Type__c == searchType && setting.ObjectName__c == queryTable){
            
            soslQueryString = (searchType=='defcsoql')?'SELECT Id,Name,'+NameSpace+'Cause_Code__c FROM '+NameSpace+'Cause__c': 'FIND \'' + soslEscapedSearchTerm + '*\' IN ALL FIELDS RETURNING '+NameSpace+'Cause__c(Id,Name,'+NameSpace+'Cause_Code__c';
           }
        }
        
       if(ids.size() > 0){ 
         soslQueryString += ' where id IN :ids AND  Type__c=:causetype AND Active__c = true';
       }
        else{
         soslQueryString += ' where Type__c=:causetype AND Active__c = true';
        }
       
       system.debug(' soql searchType   '+searchType+'  and query   '+soslQueryString);
       List<Cause__c> causeList=new List<Cause__c>();
       if(causeFieldList!=null && causeFieldList!=''){
           if('defcsosl'==searchType){
              soslQueryString+=')';
               causeList=search.query(soslQueryString)[0];
           }
           else{
               
               if(soslQueryString != null && soslQueryString != '')
                  causeList=Database.query(soslQueryString);
           } 
       }
       system.debug(' sosl searchType   '+searchType+'  and query   '+soslQueryString+'  causeList  '+causeList+' ids '+ids);
      
       
       try{
         js = JSON.serialize(causeList);
          
       }catch(exception e){
         ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
         system.debug(e.getMessage());
         js = JSON.serialize(new List<sObject>());
       }
       system.debug(js);
      
     }
       
     // **************** Below code is to get the picklist values *********************
else if(apexpages.currentpage().getparameters().get('type') == 'picklist'){
    
    String field_name = apexpages.currentpage().getparameters().get('fieldname');
    String object_name = apexpages.currentpage().getparameters().get('objectname');
    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(object_name);
    Sobject genericObject = convertType.newSObject();

    List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
   // List<String> picklistValues = new List<String>(); //new list for holding all of the picklist options
   Map<String, String> picklistValues = new Map <String, String>();
     /* if (first_val != null) { //if there is a first value being provided
        options.add(new selectOption(first_val, first_val)); //add the first option
      }*/
      Schema.sObjectType sobject_type = genericObject.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                   
            options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            //picklistValues.add(a.getValue());
            if (a.isDefaultValue())
                picklistValues.put(a.getValue(),'default');
            else
                picklistValues.put(a.getValue(),'');
      }
      
      try{
            system.debug('picklist values: options = ' + options);
            system.debug('picklist values: JSON.serialize = ' + JSON.serialize(picklistValues));
            js = JSON.serialize(picklistValues);

       }catch(exception e){
         ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
         js = JSON.serialize(new List<sObject>());
       } 
}
//********************************************************************************
   
     else{
      System.debug('WHEN TYPE IS NOT FOUND  THIS BLOCK IS EXECUTED');
      try{

        //*** Get the query value from custom setting ******
       
       String queryTable = apexpages.currentpage().getparameters().get('qt');
       String orderBy = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('o'));
       String filterValue = '';
       if (apexpages.currentpage().getparameters().get('filtervalue') != null) {
           filterValue = String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('filtervalue'));
       }
       System.debug('VF Search vfSearchAction  queryTable  '+queryTable);
       String finalquery;
       string soqlObjName;
       string soqlFieldNames;       
       for(QC_VfsearchQueries__c setting: vfsearchQueries)
        {
           System.debug(' VF Search vfSearchAction setting.ObjectName__c  '+setting.ObjectName__c+' setting.Type__c   '+setting.Type__c);
           if(setting.ObjectName__c == queryTable && setting.Type__c != 'sosl') {
            soqlObjName = setting.ObjectName__c;
            soqlFieldNames = setting.QueryFields__c;
           }
        }
        
        System.debug('VF Search vfSearchAction  soqlObjName  '+soqlObjName+'   soqlFieldNames  '+soqlFieldNames);
        
        if (String.isNotBlank(soqlObjName) && String.isNotBlank(soqlFieldNames)) {
            string soqlFieldNamesAccessible = QC_DynamicObjectHandler.getAccessibleFields(soqlObjName, soqlFieldNames);
            
            if(soqlFieldNamesAccessible != null && soqlFieldNamesAccessible != '')
              {
                    finalquery = 'select ' + soqlFieldNamesAccessible + ' from ' + soqlObjName;
                    
                    if(queryTable == 'Account' && (filterValue != null && filterValue != ''))
                    {
                        	// finalquery += ' where Recordtype.DeveloperName =' + '\''+ filterValue + '\' AND Active__c=\'Yes\'';
                             finalquery += ' where Recordtype.DeveloperName =' + '\''+ filterValue + '\' AND Active__c=true';
                    }
                    else if(queryTable == 'User')
                    {
                            finalquery += ' where isActive = true ';
                           //For NC owner group            
                            if(TOU!=NULL &&  TOU!='')                                                   
                             {    
                                 FinaluserIDSet=new set<id>();
                                 FinalUserRoleIdSet = new Set<Id>();
                                 
                                 string soqlFieldNamesAccessiblegroup = QC_DynamicObjectHandler.getAccessibleFields('group', 'id,Developername');            
                                 if(soqlFieldNamesAccessiblegroup != null && soqlFieldNamesAccessiblegroup != ''){
                                     
                                     List<Group> groups=database.query('select '+soqlFieldNamesAccessiblegroup+' from group where Developername =:TOU'); 
                                     Set<Id> grIDSet = new Set<Id>();
                                     for(Group g : groups){
                                        grIDSet.add(g.id);
                                     }
                                     getUserIds(grIDSet);
                                     getchildRoleIds(FinalUserRoleIdSet); 
                                   
                                     finalquery+='AND ID IN: FinaluserIDSet';   //Returning the final set
                                                                  
                                 }                                   
         
                              } 
                          system.debug('user soql block ending--->'+finalquery);
                    }
                     else if(queryTable == 'Document_Profile__c'){
                    	finalquery += ' where Status__c=\'Current\'';
                    }
                    //v1.0.3 start
                     else if(queryTable == 'Non_Conformance__c'){
                    	finalquery += ' where NC_Status__c=\'Closed\'';
                    }
                    
                     else if(queryTable == 'CAPA__c'){
                    	finalquery += ' where CAPA_Status__c=\'Open\'';
                    }
                    //v1.0.3 end
                    //v1.0 start
                    else if(queryTable == 'Document_Type__c'){
                        finalquery += ' where Status__c=\'Active\'';
                    }
                    //v1.0 end
                    
                    //V1.0.1
                  else if(queryTable == 'Number_Scheme__c'){
                      finalquery += ' where Module__c=\''+filterValue+'\'';
                  }
                    //v1.0.1
                  	else{
                    	finalquery+=' where Active__c=true';
                    }
                    if(orderBy != null && orderBy != '') {
                        finalquery += ' order by '+orderBy;                 
                    }
                    finalquery += ' limit 100';
                    system.debug('-->finalquery:'+finalquery);
                    js = JSON.serialize(database.query(finalquery));
              }
        }
       
     /// ****** End of code ************************
        
       }catch(exception e){
         ERR_Handler.processError(e, ERR_Handler_API.Context.FIND);
         js = JSON.serialize(new LIst<sObject>());
       }
     }
  }
}