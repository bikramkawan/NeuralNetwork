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
   // $sql ="SELECT * FROM nnresults WHERE (datelog BETWEEN '".$fromdate."' AND '".$todate."') AND (id BETWEEN 2000 AND 6000) ";
   $sql ="SELECT * FROM finalresult WHERE (datelog BETWEEN '2013-11-18' AND '2013-11-18') ";

 
//$sql1 ="SELECT * FROM tmpdate where (datetag BETWEEN '".$fromdate."' AND '".$todate."') AND speed <=".$speed1."";

 $sth=mysql_query($sql);



 $encode = array();

while($r=mysql_fetch_assoc($sth)) {
  
     $encode[]= array( 'X'=>$r['inputx'],'Z'=>$r['inputy'],'X1'=>$r['outputx'],'Z1'=>$r['outputy']); 
    
    //echo $encode[$i]['id']."<br>";
    //echo $encode[$i]['start']."   i=".$i."j=".$j."<br>";  
   

}


//echo "<pre>";
//print_r( $arrayCounter);
//echo sizeof($idarray);

//$b= json_encode($rows);
//echo json_encode($encode1); 
// $arr = array('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5);
   echo json_encode($encode);
 }
?>