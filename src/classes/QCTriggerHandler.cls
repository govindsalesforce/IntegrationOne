/*
 
     v1.0  Qualityze Inc(BK)        03-MAY-2016    Initial Version.
                                                   This Trigger Handler  includes objects related to Quality Central
                                                   i.e Defect Cause ,Defect ,Process Defect ,Process Relationship ,Product Relationship
     v1.1  Qualityze Inc(Bk)        09-SEp-2016    Updated Version.

*/
public with sharing class QCTriggerHandler {
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // QC Defect Cause start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static void  DefectCause_BeforeTrigger(List<Defect_Cause__c> records){
        for(Defect_Cause__c pd: records)
        {
            pd.Defect_Cause_id__c= pd.Defect__c+'|'+pd.Cause__c;
        }
    }
    // QC Defect Cause End
    
    //QC Defect start
    public static void Defect_BeforeTrigger(List<Defect__c> records)
    {
       Defect_BeforeTrigger_PopulateDefectvalues(records);
    }
   
    public static void Defect_AfterTrigger(List<Defect__c> records)
    {
       Defect_AfterTrigger_UpdateAccountvalues(records);
    }
    
    public static void Defect_AfterTrigger_UpdateAccountvalues(List<Defect__c> records)
    {
      Set<Id> defectIds = new Set<Id>();

      for(Defect__c d: records)
      {
          defectIds.add(d.Id);
      }
      
      List<Account> accountListToUpdate = new List<Account>();
      Set<Id> AccountIds_SuspectEnabledYes = new Set<Id> ();
      Set<Id> AccountIds_SuspectEnabledNo = new Set<Id> ();
      
      if(defectIds.size() > 0)
      {     
          string NCProductDefectFields=QC_DynamicObjectHandler.getAccessibleFields('NC_Product_Defect__c','Id,Defect__c,Defect__r.Suspect_Enabled__c,Customer_Supplier__c,');
          List<NC_Product_Defect__c> NcProductDefectList = database.query('Select '+NCProductDefectFields+' from NC_Product_Defect__c where Defect__c IN: defectIds');
          for(NC_Product_Defect__c ncpd: NcProductDefectList )
          {
              if(!String.isEmpty(ncpd.Customer_Supplier__c) && ncpd.Defect__r.Suspect_Enabled__c == 'Yes')
              {
                 AccountIds_SuspectEnabledYes.add(ncpd.Customer_Supplier__c);     
              }
              else if(!String.isEmpty(ncpd.Customer_Supplier__c) && ncpd.Defect__r.Suspect_Enabled__c != 'Yes')
              {
                  AccountIds_SuspectEnabledNo.add(ncpd.Customer_Supplier__c);
              }
              
          }
            
          string AccountFields= QC_DynamicObjectHandler.getAccessibleFields('Account','Id,Suspect_Enabled__c');
          if(AccountIds_SuspectEnabledYes.size() > 0)
          {
              if(AccountFields!=null&&AccountFields!=''){                  
                  List<Account> accountList_SuspectEnabled = database.query('Select '+AccountFields+' from Account where Id IN: AccountIds_SuspectEnabledYes');
                  for(Account a: accountList_SuspectEnabled)
                  {
                      a.Suspect_Enabled__c = 'Yes';
                      accountListToUpdate.add(a);
                  }
              }
              
              
          }
          
          if(AccountIds_SuspectEnabledNo.size() > 0)
          {
              if(AccountFields!=null&&AccountFields!=''){  
                  List<Account> accountList_SuspectDisabled = database.query('Select '+AccountFields+' from Account where Id IN: AccountIds_SuspectEnabledNo');
                  for(Account a: accountList_SuspectDisabled)
                  {
                      a.Suspect_Enabled__c = 'No';
                      accountListToUpdate.add(a);
                  }
              }
           }
              
              if(accountListToUpdate.size() > 0)
              {
                  update accountListToUpdate;
              }
          } // Defect size If condition
    }// End of function
      
    
    public static void Defect_BeforeTrigger_PopulateDefectvalues(List<Defect__c> records)
    {
        Set<Id> DefectRecIds = new Set<Id>();
    
        for(Defect__c def : records)
        {
            if(def.Volume_total_as_Num__c != null || def.Count_Total_as_Num__c != null)
            {
                    DefectRecIds.add(def.Id);
            } // End of IF condition
   
        } // End of for Loop
        
        System.debug('-->DefectRecIds:'+DefectRecIds);
        
        List<Defect__c> DefectList = new List<Defect__c>();
        //Map<Id,String> defectId_DefectVolumeUnit = new Map<Id,String>();
        
        List<NC_Product_Defect__c> ncpdList = [Select Id,Createddate,Lastmodifieddate,defect__c,Product_Lot_Numbers__r.Lot_Quantity_Affected__c from NC_Product_Defect__c where Defect__c IN: DefectRecIds];
        
        // Iterate through defect and prepare list to uopdate defect for suspect flag
        for(Defect__c defct : records)
        {
            decimal defectQuantitycount = 0;
            integer defectCount=0;
            // iterate through nc product defect
            for(NC_Product_Defect__c ncpd: ncpdList)
            {
                if(ncpd.Defect__c == defct.Id )
                {
                    if(ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c != null && defct.Volume_Compare_Value__c > 0 && ncpd.Lastmodifieddate >= defct.Volume_Compare_Date__c)
                    {
                        System.debug('--> In volume loop'+ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c + '-->'+ defct.Volume_Compare_Value__c + '-->' +defct.Volume_Compare_Date__c);
                        defectQuantitycount += ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c; 
                        
                    }
                    if(defct.Count_Compare_value__c > 0 && ncpd.Lastmodifieddate >= defct.Count_Compare_Date__c)
                    {
                        System.debug('--> In count loop'+ncpd.Product_Lot_Numbers__r.Lot_Quantity_Affected__c + '-->'+ defct.Count_Compare_value__c + '-->' +defct.Count_Compare_Date__c);
                        defectCount++;
                    }
                }
            } // end of Inner for loop
        
            if(defectQuantitycount > = (decimal)defct.Volume_total_as_Num__c)
            {
                // Include defect to update suspct flag
                defct.Suspect_Enabled__c = 'Yes';
            }
            else if(defectCount >= defct.Count_Total_as_Num__c)
            {
               // Include defect to update suspct flag
                defct.Suspect_Enabled__c = 'Yes';
            }
            else
            {
                defct.Suspect_Enabled__c = 'No';
            }
        } // end of For Loop
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC Defect end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC Process Defect start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static void  ProcessDefect_BeforeTrigger(List<Process_Defect__c> records){
        for(Process_Defect__c pd: records)
        {
            pd.Process_Defect_Id__c= pd.Standard_Operational_Process__c+'|'+pd.Defect__c;
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC Process Defect end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC ProcessRelationship start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public static void ProcessRelationship_BeforeTrigger(List<Process_Relationship__c > records)
    {
        for(Process_Relationship__c pr: records)
        {
            
            pr.Process_Relationship_Id__c = pr.Standard_Operational_Process__c+'|'+pr.Operational_Process__c;
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC ProcessRelationship end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC Product Defect start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void ProductDefect_BeforeTrigger(List<Product_Defect__c > records)
    {
        for(Product_Defect__c pr: records)
        {
            pr.Product_Defect_Id__c= pr.Product__c+'|'+pr.Defect__c;
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC Product Defect End
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC ProductRelationship Start
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void ProductRelationship_BeforeTrigger(List<Product_Relationship__c> records)
    {
        for(Product_Relationship__c pr: records)
        {
            pr.Product_Relationship_Id__c= pr.Parent_Product__c+'|'+pr.Child_Product__c;
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //QC ProductRelationship end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //Number Scheme Default Number validation 
    // v1.1   start
    public static void Number_Scheme_AfterDeleteTrigger(Map<id,Number_Scheme__c> OldMap)
    {
        for(Number_Scheme__c  ns: OldMap.values())
        {
            if(ns.name=='Default Document Number'&&ns.Maxnumber__c==999999){//in case there is a need to delete this record Maxnumber__c==999999
                ns.Name.addError('cannot delete this record');//to restrict user to delete this record
            }else if(ns.Maxnumber__c!=null){
                ns.Name.addError('cannot delete this record This record is referred by other document profile ');
            }
        }
    }
    //v1.1  end
}