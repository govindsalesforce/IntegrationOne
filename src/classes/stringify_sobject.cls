public with sharing class stringify_sobject{

private sObject s{Get; set;}
private  Map<String,Schema.SObjectField> fmap{get; set;}
private Set<String> sObjectFields{get;set;}

public stringify_sobject(){
 try{
	String sobjType=ApexPages.currentPage().getParameters().get('sobj');
	System.debug('stringify_sobject  getSobj   sobjType   '+sobjType);
	SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjType);
	System.debug('stringify_sobject  getSobj   sobjectType   '+sobjectType);
	s = sobjectType.newSobject();
    fmap =  new Map<String,Schema.SObjectField>();
    //System.debug('JSON_Serializer  getSobj   s.getsObjectType().getDescribe().fields.getMap().values()   '+s.getsObjectType().getDescribe().fields.getMap().values());
    sObjectFields=new Set<String>();
    for(Schema.SObjectField sobjField : s.getsObjectType().getDescribe().fields.getMap().values()){
    	fmap.put(String.valueOf(sobjField),sobjField);
    }
    System.debug('stringify_sobject  getSobj   fmap   '+fmap);
 }
 catch(Exception ex){
 	System.debug('Exception In  stringify_sobject   '+ex.getMessage()); 
 }
  
}

public string getSobj(){
	
   for(string str:apexpages.currentpage().getparameters().keyset()){
    if(fmap.containsKey(str)){
      Schema.DescribeFieldResult dfr = fmap.get(str).getDescribe();
      system.debug('Field: ' + str);
      if(dfr.isUpdateable() || dfr.getType().Name() == 'Reference' || dfr.getType().Name() == 'Id'){
        string val = apexpages.currentpage().getparameters().get(str); 
        system.debug('Field: ' + str);
        system.debug('Value: ' + val);
        if(val.length() == 0){
          if(dfr.isNillable()){
            s.put(str, null);
            }
        }else{
         if(!apexpages.currentpage().getparameters().containskey('Id') || dfr.isUpdateable() || dfr.getType().Name() == 'Id') {
          if(dfr.getType().Name() == 'boolean')
            s.put(str, boolean.valueof(apexpages.currentpage().getparameters().get(str)));
          else if(dfr.getType().Name() == 'date')
            s.put(str, date.valueOf(apexpages.currentpage().getparameters().get(str)));
          else if(dfr.getType().Name() == 'double')
            s.put(str, double.valueof(apexpages.currentpage().getparameters().get(str)));
          else if(dfr.getType().Name() == 'integer')
            s.put(str, integer.valueof(apexpages.currentpage().getparameters().get(str)));
          else if(dfr.getType().Name() == 'time')
            s.put(str, datetime.valueof(apexpages.currentpage().getparameters().get(str)));
          else if(dfr.getType().Name() == 'Id'){
            if(apexpages.currentpage().getparameters().get(str).length() > 0)
              s.put(str, apexpages.currentpage().getparameters().get(str));
          }else
            s.put(str, apexpages.currentpage().getparameters().get(str));
         }
          
        }
      }
    } else {
        system.debug('BEN_WUZ_HERE: Value with key "' + str + '" is ignored');
    }
  }
  System.debug('stringify_sobject.getSobj  JSON.serialize(s)  '+JSON.serialize(s));
  return JSON.serialize(s);
}
}