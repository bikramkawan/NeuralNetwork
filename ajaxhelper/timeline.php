


<?php



$id = 5;
// $surgemin=$_GET['surgemin'];
// $surgemax =$_GET['surgemax'];
// $swaymin=$_GET['swaymin'];
// $swaymax =$_GET['swaymax'];
// $timedur = $_GET['timedur'];
// $rpmmin= $_GET['rpmmin'];
// $rpmmax= $_GET['rpmmax'];
// $headmin= $_GET['headmin'];
// $headmax = $_GET['headmax'];
// $posx1 = $_GET['posx1'];
// $posy1 = $_GET['posy1'];
// $posx2= $_GET['posx2'];
// $posy2=$_GET['posy2'];

// $surgemin= -0.0269;
// $surgemax = 6.5988;
// $swaymin= -0.4968;
// $swaymax = 0.6673;
// $timedur = 1050;
// $rpmmin= -40;
// $rpmmax= 60;
// $headmin=  16.3350;
// $headmax = 242;
// $posx1 = 0.0857;//East
// $posy1 = -90; //NOrth
// $posx2= 359.8784;
// $posy2=80;


$surgemin= -0.5;
$surgemax = 6;
$swaymin= -0.5;
$swaymax = 1;
$timedur = 1050;
$rpmmin= -40;
$rpmmax= 60;
$headmin=  16.3350;
$headmax = 242;
$posx1 = 0.08;//East
$posy1 = -100; //NOrth
$posx2= 400;
$posy2=100;

// $rpmmin= 16;
// $rpmmax= 61;
// $headmin= 80;
// $headmax = 85;
// $posx1 = -5.784123;
// $posy1 = 79.861738;
// $posx2= -6.784123;
// $posy2=89.810752;
//$id= 50;

echo $speedmin;
mysql_connect("localhost","root","root");
mysql_select_db("Thesis");


//$sql1 ="SELECT * FROM simship where id < ".$id.""; 

// $sql1 = "SELECT * FROM simship WHERE  ( rpm BETWEEN ".$rpmmin." AND ".$rpmmax.")
// OR ( posx BETWEEN ".$posx1." AND ".$posx2.") 
// OR (posy BETWEEN ".$posy1." AND ".$posy2.")
// OR (heading BETWEEN ".$headmin." AND ".$headmax.")";

$sql1 = "SELECT * FROM timelinenew WHERE  ( Surge_Velocity BETWEEN ".$surgemin." AND ".$surgemax.")
OR ( Sway_Velocity BETWEEN ".$swaymin." AND ".$swaymax.") 
OR (Position_X BETWEEN ".$posx1." AND ".$posx2.")
OR (Position_Y BETWEEN ".$posy1." AND ".$posy2.")
OR (Heading BETWEEN ".$headmin." AND ".$headmax.")
";
//$sql1 ="SELECT * FROM tmpdate where (datetag BETWEEN '".$fromdate."' AND '".$todate."') AND speed <=".$speed1.;


 
 $sth=mysql_query($sql1);


 $encode = array();

while($r=mysql_fetch_assoc($sth)) {
  
    $encode[]= array( 'id'=>$r['id'],'content'=>$r['id'],'start'=>$r['datelog']); 
    //$encode[]= array( 'id'=>$r['id'],'content'=>$r['id'],'start'=>$r['datelog']); 
    
    //echo $encode[$i]['id']."<br>";
    //echo $encode[$i]['start']."   i=".$i."j=".$j."<br>";  
   

}

$encode1=array();
$count=0;
 $idarray[$count]=$count;
 $endcount=0;
 $b=0;
  $tmpendcount=0;
  $arrayCounter =  array();
  $rightcount = 0;

for ($i=0; $i <sizeof($encode) ; $i++) { 
  //echo $i."Integer"."         ".$encode[($i)]['start']."<br>";

  $startdate = $encode[($i)]['start'];
  $strStart= strtotime($encode[($i)]['start']);
  $strEnd=strtotime($encode[($i+1)]['start']);
  $diffdate=($strEnd)-($strStart);
//echo "<br>(Start ID=".$i.")(Start Date=".$strStart.")(End id=".($i+1).")(End DateTime= ".$strEnd.")(Diff=".$diffdate.")<br>";
  

    if($diffdate > $timedur ){
        $rightCount++;
        $arrayCounter[]=array(
                          "id"=> "'".$rightCount."'",
                         // "content"=>" ",
                           "content"=>"'".$rightCount."'",
                          "start"=>$encode[($i)]['start'],
                          "end"=>$encode[($i+1)]['start']
                             );
     
     $tmpi= $i;
   //  echo "Latest---->".$rightCount.")".$encode[($tempi+1)]['start']."<br>";



    }


  
}
//echo "<pre>";
//print_r( $arrayCounter);
//echo sizeof($idarray);

//$b= json_encode($rows);
//echo json_encode($encode1); 
// $arr = array('a' => 1, 'b' => 2, 'c' => 3, 'd' => 4, 'e' => 5);
   echo json_encode($arrayCounter);
?>