global class BatchHandler implements Database.Batchable<sObject>{
        
        global BatchHandler(){
            // Batch Constructor
        }
        
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            Date mydate=system.today();
            //below line updated by balu by adding another filter for effective auto expire
            string Obsolete='Obsolete';
            string Current='Current';
            string Prerelease='Prerelease';
            boolean truevar=true;
            //String query ='select id,status__c from Document_Profile__c where (status__c!= \'Obsolete\' AND  Date_of_Purge__c=: mydate)OR(status__c!= \'Current\' AND  Effective_Date__c=: mydate)OR(Auto_expire=:true and Expiration_Date__c =:mydate )OR(status__c!= \'Prerelease\' AND  Pre_Release_Duration_Date__c=: mydate) ';
            String query ='select id,status__c,Auto_Expire__c,Effective_Date__c,Expiration_Date__c,Pre_Release_Duration_Date__c,Date_of_Purge__c from Document_Profile__c where (status__c!=: Obsolete AND  Date_of_Purge__c=: mydate)OR(status__c!=:Current AND  Effective_Date__c=: mydate) OR(Auto_expire__c=:truevar and Expiration_Date__c =:mydate )OR(status__c!=: Prerelease AND  Pre_Release_Duration_Date__c=: mydate) ';
            system.debug('inside Qc_Batch class '+query);
            return Database.getQueryLocator(query);
        }
        
        // Execute Logic
        global void execute(Database.BatchableContext BC, List<sObject> objs){
            Schema.SObjectType token;
            string namespace=qc_custom_settings.getPrefix();
            if(namespace!=null){
            namespace+='__';
            }else{
            namespace='';
            }
            if(objs!=null&&!objs.isEmpty()){           
                token = objs[0].Id.getSObjectType();    
            }
            Document_profile__C  d;
            Date mydate=system.today();
            if(string.valueOf(token).containsIgnoreCase(namespace+'Document_profile__C')){
                for(sObject obj :objs){
                		if(obj.get(namespace+'Effective_Date__c')==mydate){
                        obj.put(namespace+'Status__c','Current');
                		}
                		if(obj.get(namespace+'Pre_Release_Duration_Date__c')==mydate){
                        obj.put(namespace+'Status__c','Prerelease');
                		}
                		if(obj.get(namespace+'Date_of_Purge__c')==mydate){
                        obj.put(namespace+'Status__c','Obsolete');
                		}
                		if(obj.get(namespace+'Expiration_Date__c')==mydate&&obj.get(namespace+'Auto_expire__c')==true){
                		obj.put(namespace+'Status__c','Expired');
                		}		
                }
            }
            update objs;
        }
        
        global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish,if you want to send email to you then write code here 
            //This code will execute in last when all record are updated
        }
}