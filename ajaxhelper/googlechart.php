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

  $fromdate = $_GET["fromdate"];
  $todate=$_GET["todate"];
  $speed1 = $_GET["speedlimit"];
 
  if($action=="showcomment"){
    //$sql ="SELECT * FROM nnresults WHERE (datelog BETWEEN '".$fromdate."' AND '".$todate."') AND (id BETWEEN 2500 AND 3000) ";
    $sql ="SELECT * FROM nnresults WHERE (datelog BETWEEN '2016-02-20' AND '2016-02-21') AND (id BETWEEN 2700 AND 2850) ";

    //echo "$sql";
     $sth=mysql_query($sql);
    //exit;
  // $sth = mysql_query("SELECT * FROM shipdata");




$rows = array();
//flag is not needed
$flag = true;
$table = array();
$table['cols'] = array(

    // Labels for your chart, these represent the column titles
    // Note that one column is in "string" format and another one is in "number" format as pie chart only required "numbers" for calculating percentage and string will be used for column title
   // array('label' => 'id', 'type' => 'number'),
    array('label' => 'Output Longitude', 'type' => 'number'),
    array('label' => 'Output', 'type' => 'number'),
    array('label' => 'Output', 'type' => 'number'),
    array('label' => 'Target ', 'type' => 'number')
);

$rows = array();
while($r = mysql_fetch_assoc($sth)) {
    $temp = array();

    // the following line will be used to slice the Pie chart
  // $temp[] = array('v' => (int) $r['id']); 


    // Values of each slice
   $temp[] = array('v' => (float) $r['inputx']); 
    $temp[] = array('v' => (float) $r['inputy']);
    $temp[] = array('v' => (float) $r['outputx']); 
    $temp[] = array('v' => (float) $r['outputy']);  
    $rows[] = array('c' => $temp);
}

$table['rows'] = $rows;
$jsonTable = json_encode($table);
echo $jsonTable;
}
exit();
?>