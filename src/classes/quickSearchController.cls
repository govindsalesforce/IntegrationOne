//**
//Quick Search controller
//Used to approve all tasks and changes
/*  
    v1.0        Qualityze Inc(MK)           9-SEPT-2016         
*/
public with sharing class quickSearchController {

transient public String docPrereleaseFilter{get;set;}
transient public String docCurrentFilter{get;set;}
transient public string sObjectName{get;set;}
transient public string docBookmarkFilter {get; Set;}
transient public String openNCFilter{get;set;}
transient public String workflowNCFilter{get;set;}
transient public String openCAPAFilter{get;set;}
    
 public quickSearchController(){
    }
    
public List<String> getSearchListValues(String ObjName, String FieldSetName,String returnType)
{
    List<String> returnList = new List<String> ();
    if(!string.isEmpty(ObjName) && !string.isEmpty(FieldSetName))
    {
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(ObjName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(FieldSetName);
        
        for(Schema.FieldSetMember m : fieldSetObj.getFields())
        {
            if(returnType == 'LABEL')
              returnList.add(m.getLabel());
            if(returnType == 'API')
              returnList.add(m.getFieldPath());
        }
    }
    return returnList;
}// end of function


public List<String> getHeaderLabels()
{
    List<String> tableHeaderLabelsList = new List<String>();
    if(sObjectName == 'Documents')
    {
        tableHeaderLabelsList= getSearchListValues('Document_Profile__c','Document_Search_List_Fields','LABEL');
    }
    if(sObjectName == 'NC')
    {
        tableHeaderLabelsList= getSearchListValues('Non_Conformance__c','NC_Search_List_Fields','LABEL');
    }

    return tableHeaderLabelsList;
}
public List<String> getTableFieldAPINames()
{
    List<String> tableFieldAPINameList = new List<String>();
    if(sObjectName == 'Documents')
    {
        tableFieldAPINameList= getSearchListValues('Document_Profile__c','Document_Search_List_Fields','API');
    }
    if(sObjectName == 'NC')
    {
        tableFieldAPINameList= getSearchListValues('Non_Conformance__c','NC_Search_List_Fields','API');
    }
    return tableFieldAPINameList;
}

 public List<Document_Profile__c> getDPList()
  {
    List<Document_Profile__c> dpList = new List<Document_Profile__c>();
    System.debug('-->sObjectName :'+sObjectName);
    System.debug('-->docPrereleaseFilter:'+docPrereleaseFilter);
    System.debug('-->docCurrentFilter:'+docCurrentFilter);
    System.debug('-->docBookmarkFilter:'+docBookmarkFilter);
    String loggedInUserId=UserInfo.getUserId();
    Set<String> StatusValues = new Set<String>();
    if(!string.isEmpty(docPrereleaseFilter))
        StatusValues.add(docPrereleaseFilter);
    if(!string.isEmpty(docCurrentFilter))
        StatusValues.add(docCurrentFilter);
    System.debug('-->StatusValues :'+StatusValues+'-->'+StatusValues.isEmpty());

    List<String> serachfieldList = getSearchListValues('Document_Profile__c','Document_Search_List_Fields','API');
    System.debug('-->serachfieldList :'+serachfieldList);

    String SearchString;
    if(serachfieldList.size() > 0)
    {
        SearchString = string.join(serachfieldList,',');
    //SearchString = SearchString + ',Id,Owner.Name,ContentVersionId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Primary_File_Name__c,Followers__c';
     SearchString = SearchString + ',Id,Owner.Name,ContentVersionId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Primary_File_Name__c,Followers__c,Name,Current_Rev__c,Title__c,Document_Type_Name__c,Owner_Name__c,Product_Name__c,Process_Name__c,Status__c,Effective_Date__c,Expiration_Date__c';
    }
    else
        SearchString = 'Id,Owner.Name,ContentVersionId__c,SecondaryContentVersionId__c,Secondary_File_Name__c,Primary_File_Name__c,Followers__c,Name,Current_Rev__c,Title__c,Document_Type_Name__c,Owner_Name__c,Product_Name__c,Process_Name__c,Status__c,Effective_Date__c,Expiration_Date__c';

    System.debug('-->SearchString :'+ SearchString);

    Set<String> SearchStringSet = new Set<String>(SearchString.split(','));
    List<String> FinalSearchStringList = new List<String>(SearchStringSet);
    String FinalSearchString = string.join(FinalSearchStringList,',');

    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c',FinalSearchString);

    if(sObjectName == 'Documents')
    {
        System.debug('-->Inside sObjectName:'+sObjectName);
        
        if(queryFieldNames != null && queryFieldNames != '')
        {
            if(!StatusValues.isEmpty() && string.isEmpty(docBookmarkFilter))
                dpList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Status__c IN: StatusValues LIMIT 1000');
            else if(StatusValues.isEmpty() && !string.isEmpty(docBookmarkFilter))
                dpList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Followers__c INCLUDES (\''+loggedInUserId+'\') LIMIT 1000');
            else if(!StatusValues.isEmpty() && !string.isEmpty(docBookmarkFilter))
                dpList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where (Status__c IN: StatusValues OR Followers__c INCLUDES (\''+loggedInUserId+'\'))  LIMIT 1000');
            else
              dpList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c LIMIT 1000');
                
             System.debug('-->First dpList :'+dpList);
            return dpList;
         }
         else
         {
             return dpList;
          }
    }
    else
     {
        System.debug('-->Third dpList :'+dpList);
         return dpList;
      }
  }
  
  public Pagereference searchDPList()
  {
      return null;
  }

 public List<Non_Conformance__c> getNCList()
{
    System.debug('-->Inside sObjectName:'+sObjectName);
    List<String> searchfieldList = getSearchListValues('Non_Conformance__c','NC_Search_List_Fields','API');
    String SearchString;
    //serachfieldList.remove(null);
    SearchString = string.join(searchfieldList,',');
    SearchString = SearchString + ',Id,CreatedBy.Name,Owner.Name';

    System.debug('-->SearchString :'+ SearchString);

   // String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c', 'Name,OwnerId,Owner.Name,NC_Type__c,NC_Source__c,Product__r.Name,Process__r.Name,Defect__r.Name,BusinessUnit__c,Initiating_Site__r.Name,CreatedDate,CreatedBy.Name,NC_Status__c,Occurance_Date__c');
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Non_Conformance__c',SearchString);
    List<Non_Conformance__c> ncList = new List<Non_Conformance__c>();
     if(sObjectName == 'NC')
    {
        if(queryFieldNames != null && queryFieldNames != '')
        {
            if(string.isEmpty(openNCFilter) && string.isEmpty(workflowNCFilter))
                ncList = database.query ('select ' + queryFieldNames + ' from Non_Conformance__c ORDER BY createddate DESC LIMIT 9999');
            else if(!string.isEmpty(openNCFilter) && string.isEmpty(workflowNCFilter))
                ncList = database.query ('select ' + queryFieldNames + ' from Non_Conformance__c where NC_Status__c != \'Closed\' ORDER BY createddate DESC LIMIT 9999');
            else if(string.isEmpty(openNCFilter) && !string.isEmpty(workflowNCFilter))
                ncList = database.query ('select ' + queryFieldNames + ' from Non_Conformance__c where NC_Status__c =: workflowNCFilter  ORDER BY createddate DESC LIMIT 9999');
            else
                ncList = database.query ('select ' + queryFieldNames + ' from Non_Conformance__c ORDER BY createddate DESC LIMIT 9999');
            return ncList;
         }
         else
             return ncList;
    }
    else
    {
        return ncList;
    }
}



 public List<CAPA__c> getCAPAList()
{
    System.debug('-->Inside sObjectName:'+sObjectName);
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('CAPA__c', 'Id,Name,OwnerId,Owner.Name,CAPA_Status__c,Reported_By__r.Name, CAPA_Source__c,Title__c,Problem_Statement__c,Criticality__c,Reported_Date__c,Department__c,Sites_Impacted__c,CreatedDate,CreatedBy.Name,Reported_By__c,Occurance_Date__c,Department__r.Name');
    List<CAPA__c> capaList = new List<CAPA__c>();
     if(sObjectName == 'CAPA')
    {
        if(queryFieldNames != null && queryFieldNames != '')
        {
            if(!string.isEmpty(openCAPAFilter))
                capaList = database.query ('select ' + queryFieldNames + ' from CAPA__c where CAPA_Status__c != \'Closed\' ORDER BY createddate DESC LIMIT 9999');
            else
                capaList = database.query ('select ' + queryFieldNames + ' from CAPA__c ORDER BY createddate DESC LIMIT 9999');
            return capaList;
         }
         else
             return capaList;
    }
    else
    {
        return capaList;
    }
}


@RemoteAction
public static pagereference bookMarkdocremotefunc(String docprofileId, String bookmarkValue)
{
    String queryFieldNames = QC_DynamicObjectHandler.getAccessibleFields('Document_Profile__c', 'Id,Followers__c');
    System.debug('-->Inside bookMarkDoc:'+docprofileId);
    String loggedInUserId=UserInfo.getUserId();
    List<Document_Profile__c> dpList = new List<Document_Profile__c>();
    if(!String.isBlank(docprofileId) && !String.isEmpty(docprofileId))
    {
         if(queryFieldNames != null && queryFieldNames != '')
        {
                dpList = database.query ('select ' + queryFieldNames + ' from Document_Profile__c where Id=:docprofileId limit 9999');
                System.debug('-->Inside bookMarkDoc dpList:'+dpList);
                System.debug('-->Oustide IF :'+ dpList[0].Followers__c);
                if(bookmarkValue == 'bookmark')
                 {
                    if(dpList != null && dpList.size() > 0 &&  dpList[0].Followers__c != null && !dpList[0].Followers__c.contains(loggedInUserId) )
                    {
                            System.debug('-->Inside IF :'+ dpList[0].Followers__c);
                            dpList[0].Followers__c = dpList[0].Followers__c+';'+loggedInUserId;
                            
                    }
                    else
                        dpList[0].Followers__c = loggedInUserId;
                }// End of if
                if(bookmarkValue == 'remove')
                {
                    if(dpList != null && dpList.size() > 0 &&  dpList[0].Followers__c != null && dpList[0].Followers__c.contains(loggedInUserId) )
                    {
                            List<String> follwersStr = dpList[0].Followers__c.split(',');
                            Set<String> follwersSet = new Set<String>(follwersStr);
                            follwersSet.remove(loggedInUserId);
                            List<String> follwersStrList = new List<String>(follwersSet);
                            String followerString = string.join(follwersStrList,',');
                            dpList[0].Followers__c = followerString;
                            
                    }
                }

                System.debug('-->Followers__c :'+ dpList[0].Followers__c);
                update dpList;
        }// End of If condition
    }
    
    return null;
}

}