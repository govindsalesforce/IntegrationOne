global class wiz_date_controller{

String InitDateValueString;
String InitDateISOString;

public datetime getInitDateValue(){
   return system.now();
}
public void setInitDateValue(dateTime d){

  if(d != null){
  InitDateValueString = d.format('dd MMM yyyy', 'GMT');
  InitDateISOString = d.format('yyyy-MM-dd\'T\'hh:mm:ss.sss\'Z\'', 'GMT');

  }
}

public String getInitDateValueString()
{
return InitDateValueString;
}

public String getInitDateISOString(){
  return InitDateISOString;
}

public void setInitDateValueString() {
//InitDateValueString= InitDateValue.format('dd/MM/yyyy');
System.debug('-->InitDateValue:'+InitDateValueString);
}

 
 public wiz_date_controller(){
// System.debug('-->InitDateValue:'+InitDateValue);
}

}