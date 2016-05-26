


<?php




// $rpmmin= 16;
// $rpmmax= 61;
// $headmin= 80;
// $headmax = 85;
// $posx1 = -5.784123;
// $posy1 = 79.861738;
// $posx2= -6.784123;
// $posy2=89.810752;
//$id= 50;

mysql_connect("localhost","root","root");
mysql_select_db("Thesis");


//$sql1 ="SELECT * FROM simship where id < ".$id.""; 

  $sql ="SELECT * FROM finalresult ";
//$sql1 ="SELECT * FROM tmpdate where (datetag BETWEEN '".$fromdate."' AND '".$todate."') AND speed <=".$speed1."";

 $sth=mysql_query($sql);



 $encode = array();

while($r=mysql_fetch_assoc($sth)) {
  
     $encode[]= array( 'X'=>$r['inputx'],'Z'=>$r['inputy']); 
    
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
?>