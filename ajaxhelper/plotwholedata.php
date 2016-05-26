 <?php
// $con=mysql_connect("localhost","root","root") or die("Failed to connect with database!!!!");
// mysql_select_db("Thesis", $con); 
// // The Chart table contains two fields: weekly_task and percentage
// // This example will display a pie chart. If you need other charts such as a Bar chart, you will need to modify the code a little to make it work with bar chart and other charts
// $sth = mysql_query("SELECT * FROM shipdata");

 mysql_connect("localhost","root","root");
  mysql_select_db("Thesis");
 

  $action=$_GET["action"];
// 

  $fromdate2 = $_GET["fromdate2"];
  $todate2=$_GET["todate2"];
  $attribute = $_GET["attribute"];
 
  if($action=="showcomment"){
    $sql ="SELECT id,".$attribute." FROM wholedata WHERE (datelog BETWEEN '".$fromdate2."' AND '".$todate2."') ";


     $sth=mysql_query($sql);

   
    // exit;
  // $sth = mysql_query("SELECT * FROM shipdata");




$rows = array();
//flag is not needed
$flag = true;
$table = array();
$table['cols'] = array(

    // Labels for your chart, these represent the column titles
    // Note that one column is in "string" format and another one is in "number" format as pie chart only required "numbers" for calculating percentage and string will be used for column title
   // array('label' => 'id', 'type' => 'number'),
    array('label' => 'hello', 'type' => 'number'),
    array('label' => $attribute, 'type' => 'number')
    
);

$rows = array();
while($r = mysql_fetch_assoc($sth)) {
    $temp = array();

    // the following line will be used to slice the Pie chart
  // $temp[] = array('v' => (int) $r['id']); 


    // Values of each slice
     $temp[] = array('v' => (int) $r['id']); 

   $temp[] = array('v' => (float) $r[$attribute]); 
    
    $rows[] = array('c' => $temp);
}

$table['rows'] = $rows;
$jsonTable = json_encode($table);
echo $jsonTable;
}
exit();
?>