global class Scheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      BatchHandler b = new BatchHandler (); 
      //Parameters of ExecuteBatch(context,BatchSize)
      database.executebatch(b,100); 
   }
}